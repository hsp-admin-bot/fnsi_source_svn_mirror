package com.fnsi.cloudconverter.logupload;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Comparator;
import java.util.UUID;
import java.util.stream.Stream;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class ClientLogUploadServiceTest {

    private Path tempDir;

    @AfterEach
    void tearDown() throws Exception {
        if (tempDir == null || Files.notExists(tempDir)) {
            return;
        }

        try (Stream<Path> stream = Files.walk(tempDir)) {
            stream.sorted(Comparator.reverseOrder())
                    .forEach(path -> {
                        try {
                            Files.deleteIfExists(path);
                        } catch (Exception e) {
                            throw new RuntimeException(e);
                        }
                    });
        }
    }

    @Test
    void writesCurrentDateLogIntoTodayDirectory() throws Exception {
        tempDir = createTempDir();
        ClientLogUploadProperties properties = properties(tempDir.resolve("{1}").toString());
        ClientLogUploadService service = new ClientLogUploadService(properties);
        String today = LocalDate.now().format(DateTimeFormatter.BASIC_ISO_DATE);

        ClientLogUploadResponse response = service.upload("FNSICloudConvertClient", "hello".getBytes(StandardCharsets.UTF_8), today);

        Path expected = tempDir.resolve("today").resolve("FNSICloudConvertClient_" + today + ".log");
        assertThat(response.success()).isTrue();
        assertThat(response.path()).isEqualTo(expected.normalize().toString());
        assertThat(Files.readString(expected)).isEqualTo("hello");
    }

    @Test
    void writesHistoricalLogIntoDateDirectory() throws Exception {
        tempDir = createTempDir();
        ClientLogUploadProperties properties = properties(tempDir.resolve("{1}").toString());
        ClientLogUploadService service = new ClientLogUploadService(properties);

        ClientLogUploadResponse response = service.upload("FNSICloudConvertClient", "history".getBytes(StandardCharsets.UTF_8), "20260331");

        Path expected = tempDir.resolve("20260331").resolve("FNSICloudConvertClient_20260331.log");
        assertThat(response.success()).isTrue();
        assertThat(response.path()).isEqualTo(expected.normalize().toString());
        assertThat(Files.readString(expected)).isEqualTo("history");
    }

    @Test
    void returnsEmptyBodyWithoutWritingFile() throws Exception {
        tempDir = createTempDir();
        ClientLogUploadProperties properties = properties(tempDir.resolve("{1}").toString());
        ClientLogUploadService service = new ClientLogUploadService(properties);

        ClientLogUploadResponse response = service.upload("FNSICloudConvertClient", new byte[0], null);

        assertThat(response.success()).isTrue();
        assertThat(response.path()).isNull();
        assertThat(response.message()).isEqualTo("empty body");
        assertThat(Files.list(tempDir)).isEmpty();
    }

    @Test
    void rejectsInvalidDateFormat() throws Exception {
        tempDir = createTempDir();
        ClientLogUploadProperties properties = properties(tempDir.resolve("{1}").toString());
        ClientLogUploadService service = new ClientLogUploadService(properties);

        assertThatThrownBy(() -> service.upload("FNSICloudConvertClient", new byte[] {1}, "2026-04-03"))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("yyyyMMdd");
    }

    @Test
    void sanitizesIllegalFileNameCharacters() throws Exception {
        tempDir = createTempDir();
        ClientLogUploadProperties properties = properties(tempDir.resolve("{1}").toString());
        ClientLogUploadService service = new ClientLogUploadService(properties);

        ClientLogUploadResponse response = service.upload("client:tool/name", "x".getBytes(StandardCharsets.UTF_8), "20260331");

        Path expected = tempDir.resolve("20260331").resolve("client_tool_name_20260331.log");
        assertThat(response.path()).isEqualTo(expected.normalize().toString());
        assertThat(Files.exists(expected)).isTrue();
    }

    private ClientLogUploadProperties properties(String template) {
        ClientLogUploadProperties properties = new ClientLogUploadProperties();
        properties.getStorage().setPath(template);
        return properties;
    }

    private Path createTempDir() throws Exception {
        Path root = Paths.get("build", "tmp", "client-log-upload-tests").toAbsolutePath().normalize();
        Files.createDirectories(root);
        return Files.createDirectories(root.resolve(UUID.randomUUID().toString()));
    }
}
