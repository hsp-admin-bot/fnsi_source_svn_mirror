package com.fnsi.cloudconverter.onlinemongo;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fnsi.cloudconverter.migration.mongo.MongoCollectionConfig;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;

@Slf4j
@Component
public class DocDb4HelperRunner {

    private static final int PROCESS_OUTPUT_TAIL_LIMIT = 16_384;

    private final DocDb4HelperLocator helperLocator;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public DocDb4HelperRunner(DocDb4HelperLocator helperLocator) {
        this.helperLocator = helperLocator;
    }

    public ServerInfoResponse fetchServerInfo(String uri, int timeoutMs) {
        return runJsonCommand(
                List.of(
                        "server-info",
                        "--uri=" + uri,
                        "--timeoutMs=" + timeoutMs
                ),
                ServerInfoResponse.class
        );
    }

    public ClearResponse clearFacilityData(
            String uri,
            List<String> facilityCodes,
            List<MongoCollectionConfig> targets,
            int timeoutMs) {

        try {
            Path tempDir = Files.createTempDirectory("docdb4-helper-");
            Path facilityCodesFile = tempDir.resolve("facilityCodes.json");
            Path targetsFile = tempDir.resolve("targets.json");

            objectMapper.writeValue(facilityCodesFile.toFile(), facilityCodes);
            objectMapper.writeValue(targetsFile.toFile(), targets.stream()
                    .filter(cfg -> cfg.getFilterField() != null && !cfg.getFilterField().isBlank())
                    .map(cfg -> new ClearTarget(cfg.getName(), cfg.getFilterField()))
                    .toList());

            try {
                return runJsonCommand(
                        List.of(
                                "clear-facility-data",
                                "--uri=" + uri,
                                "--timeoutMs=" + timeoutMs,
                                "--facilityCodesFile=" + facilityCodesFile,
                                "--targetsFile=" + targetsFile
                        ),
                        ClearResponse.class
                );
            } finally {
                deleteQuietly(facilityCodesFile);
                deleteQuietly(targetsFile);
                deleteQuietly(tempDir);
            }
        } catch (IOException ex) {
            throw new IllegalStateException("Failed to prepare DocDB4 helper input files", ex);
        }
    }

    private <T> T runJsonCommand(List<String> args, Class<T> type) {
        List<String> command = new ArrayList<>();
        command.add(javaCommand());
        command.add("-Dfile.encoding=UTF-8");
        command.add("-Dsun.stdout.encoding=UTF-8");
        command.add("-Dsun.stderr.encoding=UTF-8");
        command.add("-jar");
        command.add(helperLocator.helperJar().toString());
        command.addAll(args);

        try {
            Process process = new ProcessBuilder(command)
                    .redirectErrorStream(true)
                    .start();
            StringBuilder outputTail = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream(), StandardCharsets.UTF_8))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    appendBounded(outputTail, line + System.lineSeparator(), PROCESS_OUTPUT_TAIL_LIMIT);
                }
            }
            String output = outputTail.toString().trim();
            int exitCode = process.waitFor();

            if (output.isBlank()) {
                throw new IllegalStateException("DocDB4 helper returned empty output, exitCode=" + exitCode);
            }

            log.debug("[DOCDB4_HELPER] command={}, exitCode={}, output={}", args.getFirst(), exitCode, output);
            String json = extractJsonPayload(output);
            return objectMapper.readValue(json, type);
        } catch (Exception ex) {
            throw new IllegalStateException("Failed to execute DocDB4 helper command: " + args.getFirst(), ex);
        }
    }

    private void appendBounded(StringBuilder buffer, String value, int limit) {
        if (value.length() >= limit) {
            buffer.setLength(0);
            buffer.append(value.substring(value.length() - limit));
            return;
        }
        int overflow = buffer.length() + value.length() - limit;
        if (overflow > 0) {
            buffer.delete(0, overflow);
        }
        buffer.append(value);
    }

    private String extractJsonPayload(String output) {
        List<String> lines = output.lines()
                .map(String::trim)
                .filter(line -> !line.isBlank())
                .toList();

        for (int i = lines.size() - 1; i >= 0; i--) {
            String line = lines.get(i);
            if (line.startsWith("{") && line.endsWith("}")) {
                return line;
            }
        }

        int lastJsonStart = output.lastIndexOf('{');
        if (lastJsonStart >= 0) {
            String candidate = output.substring(lastJsonStart).trim();
            if (candidate.startsWith("{") && candidate.endsWith("}")) {
                return candidate;
            }
        }

        throw new IllegalStateException("DocDB4 helper output did not contain JSON: " + abbreviate(output));
    }

    private String javaCommand() {
        String executable = System.getProperty("os.name", "").toLowerCase().contains("win")
                ? "java.exe"
                : "java";
        return Path.of(System.getProperty("java.home"), "bin", executable).toString();
    }

    private void deleteQuietly(Path path) {
        try {
            Files.deleteIfExists(path);
        } catch (IOException ignored) {
            log.debug("[DOCDB4_HELPER] temp cleanup skipped: {}", path);
        }
    }

    private String abbreviate(String value) {
        if (value == null) {
            return "";
        }
        String normalized = value.replaceAll("\\s+", " ").trim();
        if (normalized.length() <= 240) {
            return normalized;
        }
        return normalized.substring(0, 240) + "...";
    }

    public record ServerInfoResponse(
            boolean ok,
            String message,
            String serverVersion,
            Integer maxWireVersion) {
    }

    public record ClearResponse(
            boolean ok,
            String message,
            long totalDeleted,
            List<CollectionDeleteResult> results) {
    }

    public record CollectionDeleteResult(String name, long deleted) {
    }

    private record ClearTarget(String name, String filterField) {
    }
}
