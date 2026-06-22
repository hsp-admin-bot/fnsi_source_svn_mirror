package com.fnsi.cloudconverter.logupload;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
@RequiredArgsConstructor
public class ClientLogUploadService {

    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.BASIC_ISO_DATE;
    private static final Pattern ILLEGAL_FILE_CHARS = Pattern.compile("[\\\\/:*?\"<>|]");
    private static final Pattern DATE_IN_FILE_NAME = Pattern.compile("(\\d{8})");

    private final ClientLogUploadProperties properties;

    public ClientLogUploadResponse upload(String appName, byte[] body, String logDate) throws IOException {
        if (body == null || body.length == 0) {
            return new ClientLogUploadResponse(true, null, "empty body");
        }

        LocalDate targetDate = resolveLogDate(logDate);
        String ymd = targetDate.format(DATE_FMT);
        String dateToken = targetDate.equals(LocalDate.now()) ? "today" : ymd;
        String safeAppName = sanitizeAppName(appName);
        String fileName = safeAppName + "_" + ymd + ".log";

        Path directory = resolveDirectory(dateToken);
        Files.createDirectories(directory);

        Path targetFile = directory.resolve(fileName);
        Files.write(
                targetFile,
                body,
                StandardOpenOption.CREATE,
                StandardOpenOption.TRUNCATE_EXISTING,
                StandardOpenOption.WRITE
        );

        return new ClientLogUploadResponse(true, targetFile.toString(), null);
    }

    public ClientLogUploadResponse uploadLegacy(int mode, String appName, String fileName, MultipartFile upFile)
            throws IOException {
        if (upFile == null || upFile.isEmpty()) {
            throw new IllegalArgumentException("upFile が空です");
        }
        if (mode < 0 || mode > 3) {
            throw new IllegalArgumentException("mode は 0-3 の範囲で指定してください: " + mode);
        }

        String safeAppName = sanitizeAppName(appName);
        String safeFileName = sanitizeFileName(fileName);
        byte[] body = upFile.getBytes();

        Path stagingFile = resolveLegacyStagingFile(safeAppName, safeFileName);
        Files.createDirectories(stagingFile.getParent());

        if (mode == 0 || mode == 1) {
            Files.write(
                    stagingFile,
                    body,
                    StandardOpenOption.CREATE,
                    StandardOpenOption.TRUNCATE_EXISTING,
                    StandardOpenOption.WRITE
            );
        } else {
            Files.write(
                    stagingFile,
                    body,
                    StandardOpenOption.CREATE,
                    StandardOpenOption.APPEND,
                    StandardOpenOption.WRITE
            );
        }

        Path resultPath = stagingFile;
        if (mode == 0 || mode == 3) {
            String dateToken = resolveDateTokenFromFileName(safeFileName);
            Path directory = resolveDirectory(dateToken);
            Files.createDirectories(directory);
            resultPath = directory.resolve(safeFileName);
            Files.move(stagingFile, resultPath, java.nio.file.StandardCopyOption.REPLACE_EXISTING);
        }

        return new ClientLogUploadResponse(true, resultPath.toString(), null);
    }

    Path resolveDirectory(String dateToken) {
        String rawPath = properties.getStorage().getPath();
        if (rawPath == null || rawPath.isBlank()) {
            throw new IllegalStateException("client-log.upload.storage.path が未設定です");
        }
        return Paths.get(rawPath.replace("{1}", dateToken)).normalize();
    }

    LocalDate resolveLogDate(String logDate) {
        if (logDate == null || logDate.isBlank()) {
            return LocalDate.now();
        }
        try {
            return LocalDate.parse(logDate, DATE_FMT);
        } catch (DateTimeParseException e) {
            throw new IllegalArgumentException("logDate は yyyyMMdd 形式で指定してください: " + logDate, e);
        }
    }

    String sanitizeAppName(String appName) {
        if (appName == null || appName.isBlank()) {
            return "unknown-app";
        }
        return ILLEGAL_FILE_CHARS.matcher(appName).replaceAll("_");
    }

    String sanitizeFileName(String fileName) {
        if (fileName == null || fileName.isBlank()) {
            return "unknown.log";
        }
        return ILLEGAL_FILE_CHARS.matcher(fileName).replaceAll("_");
    }

    Path resolveLegacyStagingFile(String appName, String fileName) {
        Path tempRoot = Paths.get(System.getProperty("java.io.tmpdir"), "fnsi-cloud-convert-client-log-upload");
        return tempRoot.resolve(appName).resolve(fileName).normalize();
    }

    String resolveDateTokenFromFileName(String fileName) {
        Matcher matcher = DATE_IN_FILE_NAME.matcher(fileName == null ? "" : fileName);
        if (!matcher.find()) {
            return "today";
        }

        String ymd = matcher.group(1);
        try {
            LocalDate date = LocalDate.parse(ymd, DATE_FMT);
            return date.equals(LocalDate.now()) ? "today" : ymd;
        } catch (DateTimeParseException e) {
            return "today";
        }
    }
}
