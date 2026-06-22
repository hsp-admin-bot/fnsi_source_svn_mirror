package com.fnsi.cloudconverter.migration.mongo;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Mongo ダンプ/リストアサービス実装 — ProcessBuilder ベース
 * BSON 形式（mongodump / mongorestore）のみ使用
 * 参照: 03_module.md § Module 3 / 05_key_tech.md § 2
 */
@Slf4j
@Service
public class MongoMigrationServiceImpl implements MongoMigrationService {

    private static final int PROCESS_OUTPUT_TAIL_LIMIT = 16_384;

    @Value("${migration.mongo.dump-path:/usr/bin/mongodump}")
    private String mongoDumpPath;

    @Value("${migration.mongo.restore-path:/usr/bin/mongorestore}")
    private String mongoRestorePath;

    @Value("${migration.mongo.docdb4.dump-path:${migration.mongo.dump-path:/usr/bin/mongodump}}")
    private String docDb4MongoDumpPath;

    @Value("${migration.mongo.docdb4.restore-path:${migration.mongo.restore-path:/usr/bin/mongorestore}}")
    private String docDb4MongoRestorePath;

    // -------------------------------------------------------
    // mongodump
    // -------------------------------------------------------

    @Override
    public StreamResult dump(MongoCollectionConfig config, List<String> facilityCodes,
                             Path outputDir, MongoConnectionInfo mongoConn) {
        return dump(config, facilityCodes, outputDir, mongoConn, MongoToolProfile.DEFAULT);
    }

    @Override
    public StreamResult dump(MongoCollectionConfig config, List<String> facilityCodes,
                             Path outputDir, MongoConnectionInfo mongoConn, MongoToolProfile toolProfile) {
        try {
            Files.createDirectories(outputDir);

            List<String> cmd = new ArrayList<>(List.of(
                    selectDumpPath(toolProfile),
                    "--host",       mongoConn.host(),
                    "--port",       String.valueOf(mongoConn.port()),
                    "--db",         mongoConn.database(),
                    "--collection", config.getName(),
                    "--out",        outputDir.toString()
            ));
            if (mongoConn.username() != null) {
                cmd.add("--username"); cmd.add(mongoConn.username());
                cmd.add("--authenticationDatabase"); cmd.add(mongoConn.database());
            }
            if (mongoConn.password() != null) {
                cmd.add("--password"); cmd.add(mongoConn.password());
            }

            // 施設フィルター（--queryFile 経由で渡す。Windows では --query の " が化けるため）
            Path queryFile = null;
            if (config.getFilterField() != null && facilityCodes != null && !facilityCodes.isEmpty()) {
                queryFile = Files.createTempFile("mongodump-query-", ".json");
                Files.writeString(queryFile, buildQuery(config.getFilterField(), facilityCodes),
                        StandardCharsets.UTF_8);
                cmd.add("--queryFile");
                cmd.add(queryFile.toString());
            }

            try {
                int exit = runProcess(cmd);
                if (exit != 0) {
                    return StreamResult.fail(config.getName(), "mongodump 終了コード=" + exit);
                }
                log.info("[MONGO_DUMP] 完了: collection={}", config.getName());
                return StreamResult.ok(config.getName(), 0L);
            } finally {
                if (queryFile != null) Files.deleteIfExists(queryFile);
            }

        } catch (IOException | InterruptedException e) {
            if (e instanceof InterruptedException) Thread.currentThread().interrupt();
            return StreamResult.fail(config.getName(), e.getMessage());
        }
    }

    // -------------------------------------------------------
    // mongorestore
    // -------------------------------------------------------

    @Override
    public StreamResult restoreCollection(String collectionName, Path bsonFile,
                                          MongoConnectionInfo mongoConn, boolean drop) {
        return restoreCollection(collectionName, bsonFile, mongoConn, drop, MongoToolProfile.DEFAULT);
    }

    @Override
    public StreamResult restoreCollection(String collectionName, Path bsonFile,
                                          MongoConnectionInfo mongoConn, boolean drop, MongoToolProfile toolProfile) {
        if (!Files.exists(bsonFile)) {
            return StreamResult.fail(collectionName, "BSON ファイルが存在しません: " + bsonFile);
        }
        try {
            List<String> cmd = new ArrayList<>(List.of(
                    selectRestorePath(toolProfile),
                    "--host",       mongoConn.host(),
                    "--port",       String.valueOf(mongoConn.port()),
                    "--db",         mongoConn.database(),
                    "--collection", collectionName,
                    bsonFile.toString()
            ));
            if (drop) {
                cmd.add(cmd.size() - 1, "--drop");
            }
            if (mongoConn.username() != null) {
                cmd.add("--username"); cmd.add(mongoConn.username());
                cmd.add("--authenticationDatabase"); cmd.add(mongoConn.database());
            }
            if (mongoConn.password() != null) {
                cmd.add("--password"); cmd.add(mongoConn.password());
            }

            int exit = runProcess(cmd);
            if (exit != 0) {
                return StreamResult.fail(collectionName, "mongorestore 終了コード=" + exit);
            }
            log.info("[MONGO_RESTORE] 完了: collection={}", collectionName);
            return StreamResult.ok(collectionName, 0L);

        } catch (IOException | InterruptedException e) {
            if (e instanceof InterruptedException) Thread.currentThread().interrupt();
            return StreamResult.fail(collectionName, e.getMessage());
        }
    }

    // -------------------------------------------------------
    // ユーティリティ
    // -------------------------------------------------------

    private String selectDumpPath(MongoToolProfile toolProfile) {
        return toolProfile == MongoToolProfile.DOCDB4_COMPAT ? docDb4MongoDumpPath : mongoDumpPath;
    }

    private String selectRestorePath(MongoToolProfile toolProfile) {
        return toolProfile == MongoToolProfile.DOCDB4_COMPAT ? docDb4MongoRestorePath : mongoRestorePath;
    }

    private int runProcess(List<String> cmd) throws IOException, InterruptedException {
        log.debug("[MONGO] コマンド: {}", String.join(" ", cmd));
        ProcessBuilder pb = new ProcessBuilder(cmd);
        pb.redirectErrorStream(true);
        Process p = pb.start();
        StringBuilder outputTail = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(p.getInputStream(), StandardCharsets.UTF_8))) {
            String line;
            while ((line = reader.readLine()) != null) {
                appendBounded(outputTail, line + System.lineSeparator(), PROCESS_OUTPUT_TAIL_LIMIT);
            }
        }
        int exit = p.waitFor();
        String output = outputTail.toString().trim();
        if (!output.isEmpty()) {
            if (exit == 0) log.debug("[MONGO] 出力: {}", output);
            else           log.error("[MONGO] エラー出力: {}", output);
        }
        return exit;
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

    /** MongoDB クエリ JSON 構築（施設コードフィルター） */
    private String buildQuery(String field, List<String> codes) {
        String codesJson = codes.stream()
                .map(c -> "\"" + c.replace("\"", "\\\"") + "\"")
                .collect(Collectors.joining(",", "[", "]"));
        return String.format("{\"%s\":{\"$in\":%s}}", field, codesJson);
    }
}
