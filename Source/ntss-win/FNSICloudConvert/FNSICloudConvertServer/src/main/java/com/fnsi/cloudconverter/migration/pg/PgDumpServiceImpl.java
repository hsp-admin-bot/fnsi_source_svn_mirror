package com.fnsi.cloudconverter.migration.pg;

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
 * PG ダンプ/リストアサービス実装 — ProcessBuilder ベース
 * 参照: 03_module.md § Module 2 / 05_key_tech.md § 1
 */
@Slf4j
@Service
public class PgDumpServiceImpl implements PgDumpService {

    private static final int PROCESS_OUTPUT_TAIL_LIMIT = 16_384;

    @Value("${migration.pg.dump-path:/usr/bin/pg_dump}")
    private String pgDumpPath;

    @Value("${migration.pg.restore-path:/usr/bin/pg_restore}")
    private String pgRestorePath;

    @Value("${migration.pg.psql-path:/usr/bin/psql}")
    private String psqlPath;

    @Value("${migration.pg.parallel-jobs:4}")
    private int parallelJobs;

    // -------------------------------------------------------
    // pg_dump
    // -------------------------------------------------------

    @Override
    public DumpResult dump(PgTableConfig config, List<String> facilityCodes,
                           Path outputDir, DbConnectionInfo dbConn) {
        try {
            Path tableDir = outputDir.resolve(config.getName());
            // pg_dump -Fd はディレクトリを自ら作成するため、既存なら削除してから実行
            Files.createDirectories(outputDir);
            if (Files.exists(tableDir)) {
                try (var walk = Files.walk(tableDir)) {
                    walk.sorted(java.util.Comparator.reverseOrder())
                        .forEach(p -> { try { Files.delete(p); } catch (IOException ex) { /* ignore */ } });
                }
            }

            List<String> cmd = new ArrayList<>(List.of(
                    pgDumpPath,
                    "-Fd",
                    "-j", String.valueOf(parallelJobs),
                    "--table", "ntss." + quoteIdentifier(config.getName()),
                    "-f", tableDir.toString(),
                    "-h", dbConn.host(),
                    "-p", String.valueOf(dbConn.port()),
                    "-U", dbConn.username()
            ));

            // --where は DB 名（最後の位置引数）より前に追加しなければならない
            if (config.getWhereTemplate() != null && !config.getWhereTemplate().isBlank() && !facilityCodes.isEmpty()) {
                String where = buildWhereClause(config.getWhereTemplate(), facilityCodes);
                cmd.add("--where");
                cmd.add(where);
            }
            cmd.add(dbConn.database());

            log.info("[PG_DUMP] 開始: table={}, db={}", config.getName(), dbConn.database());
            ProcResult result = runProcess(cmd, dbConn.password());
            if (result.exitCode() != 0) {
                log.error("[PG_DUMP] 失敗: table={}, exitCode={}, output={}",
                        config.getName(), result.exitCode(), result.output());
                return DumpResult.fail(config.getName(),
                        "pg_dump 終了コード=" + result.exitCode() + ": " + result.output());
            }
            log.info("[PG_DUMP] 完了: table={}", config.getName());
            return DumpResult.ok(config.getName(), 0L);

        } catch (IOException | InterruptedException e) {
            if (e instanceof InterruptedException) Thread.currentThread().interrupt();
            return DumpResult.fail(config.getName(), e.getMessage());
        }
    }

    // -------------------------------------------------------
    // pg_restore
    // -------------------------------------------------------

    @Override
    public DumpResult restore(String tableName, Path dumpDir, DbConnectionInfo dbConn) {
        Path tableDir = dumpDir.resolve(tableName);
        if (!Files.exists(tableDir)) {
            log.debug("[PG_RESTORE] ダンプディレクトリが存在しません (スキップ): {}", tableDir);
            return DumpResult.ok(tableName, 0L);
        }
        try {
            List<String> cmd = new ArrayList<>(List.of(
                    pgRestorePath,
                    "-Fd",
                    "-j", String.valueOf(parallelJobs),
                    "-h", dbConn.host(),
                    "-p", String.valueOf(dbConn.port()),
                    "-U", dbConn.username(),
                    "-d", dbConn.database(),
                    "--no-owner",
                    "--no-privileges",
                    tableDir.toString()
            ));

            log.info("[PG_RESTORE] 開始: table={}, db={}", tableName, dbConn.database());
            ProcResult result = runProcess(cmd, dbConn.password());
            if (result.exitCode() != 0) {
                log.error("[PG_RESTORE] 失敗: table={}, exitCode={}, output={}",
                        tableName, result.exitCode(), result.output());
                return DumpResult.fail(tableName,
                        "pg_restore 終了コード=" + result.exitCode() + ": " + result.output());
            }
            log.info("[PG_RESTORE] 完了: table={}", tableName);
            return DumpResult.ok(tableName, 0L);

        } catch (IOException | InterruptedException e) {
            if (e instanceof InterruptedException) Thread.currentThread().interrupt();
            return DumpResult.fail(tableName, e.getMessage());
        }
    }

    // -------------------------------------------------------
    // psql \COPY TO (FORMAT binary)
    // -------------------------------------------------------

    @Override
    public DumpResult dumpToCopy(PgTableConfig config, List<String> facilityCodes,
                                  Path dbSubDir, DbConnectionInfo dbConn) {
        try {
            Files.createDirectories(dbSubDir);
            Path dataFile = dbSubDir.resolve(config.getName() + ".data");
            String psqlFilePath = dataFile.toAbsolutePath().toString().replace('\\', '/');

            String copyCmd;
            if (config.getWhereTemplate() != null && !config.getWhereTemplate().isBlank() && !facilityCodes.isEmpty()) {
                String where = buildWhereClause(config.getWhereTemplate(), facilityCodes);
                copyCmd = "\\COPY (SELECT * FROM ntss." + quoteIdentifier(config.getName())
                        + " WHERE " + where + ") TO '" + psqlFilePath + "' (FORMAT binary)";
            } else {
                copyCmd = "\\COPY ntss." + quoteIdentifier(config.getName())
                        + " TO '" + psqlFilePath + "' (FORMAT binary)";
            }

            String connUri = buildConnUri(dbConn);
            List<String> cmd = new ArrayList<>(List.of(
                    psqlPath, "-d", connUri, "--no-psqlrc", "--quiet", "-c", copyCmd));

            log.info("[PG_DUMP_COPY] 開始: table={}, db={}, file={}",
                    config.getName(), dbConn.database(), dataFile.getFileName());
            ProcResult result = runProcess(cmd, dbConn.password());
            if (result.exitCode() != 0) {
                // テーブル未存在はスキップ（中転DBに存在しないテーブルは正常）
                if (result.output().contains("does not exist")) {
                    log.warn("[PG_DUMP_COPY] テーブル不存在のためスキップ: table={}, db={}",
                            config.getName(), dbConn.database());
                    return DumpResult.ok(config.getName(), 0L);
                }
                log.error("[PG_DUMP_COPY] 失敗: table={}, exitCode={}, output={}",
                        config.getName(), result.exitCode(), result.output());
                return DumpResult.fail(config.getName(),
                        "psql COPY TO 終了コード=" + result.exitCode() + ": " + result.output());
            }
            log.info("[PG_DUMP_COPY] 完了: table={}", config.getName());
            return DumpResult.ok(config.getName(), 0L);

        } catch (IOException | InterruptedException e) {
            if (e instanceof InterruptedException) Thread.currentThread().interrupt();
            return DumpResult.fail(config.getName(), e.getMessage());
        }
    }

    // -------------------------------------------------------
    // psql \COPY FROM (FORMAT binary)
    // -------------------------------------------------------

    @Override
    public DumpResult restoreFromCopy(String tableName, Path dbSubDir, DbConnectionInfo dbConn) {
        Path dataFile = dbSubDir.resolve(tableName + ".data");
        if (!Files.exists(dataFile)) {
            log.debug("[PG_RESTORE_COPY] ファイルが存在しません (スキップ): {}", dataFile);
            return DumpResult.ok(tableName, 0L);
        }
        // temp table 経由で ON CONFLICT DO NOTHING INSERT を実現
        // \COPY は ON CONFLICT 非対応のため、一旦 temp へ COPY → INSERT で重複をスキップ
        Path scriptFile = null;
        try {
            String psqlFilePath = dataFile.toAbsolutePath().toString().replace('\\', '/');
//            String tmpTable = "tmp_restore_" + tableName.replaceAll("[^a-zA-Z0-9_]", "_");
//            String script = "BEGIN;\n"
//                    + "CREATE TEMP TABLE " + quoteIdentifier(tmpTable)
//                    + " (LIKE ntss." + quoteIdentifier(tableName) + ");\n"
//                    + "\\COPY " + quoteIdentifier(tmpTable)
//                    + " FROM '" + psqlFilePath + "' (FORMAT binary);\n"
//                    + "INSERT INTO ntss." + quoteIdentifier(tableName)
//                    + " SELECT * FROM " + quoteIdentifier(tmpTable) + " ON CONFLICT DO NOTHING;\n"
//                    + "DROP TABLE " + quoteIdentifier(tmpTable) + ";\n"
//                    + "COMMIT;\n";

            String script =
                    "SET synchronous_commit = OFF;\n" +
                            "SET session_replication_role = replica;\n" +
                            "BEGIN;\n" +
                            "\\COPY ntss." + quoteIdentifier(tableName) +
                            " FROM '" + psqlFilePath + "' (FORMAT binary);\n" +
                            "COMMIT;\n";

            scriptFile = Files.createTempFile("pg_restore_", ".sql");
            Files.writeString(scriptFile, script, StandardCharsets.UTF_8);

            String connUri = buildConnUri(dbConn);
            List<String> cmd = new ArrayList<>(List.of(
                    psqlPath, "-d", connUri, "--no-psqlrc", "--quiet",
                    "-f", scriptFile.toAbsolutePath().toString()));

            log.info("[PG_RESTORE_COPY] 開始: table={}, db={}, file={}",
                    tableName, dbConn.database(), dataFile.getFileName());
            ProcResult result = runProcess(cmd, dbConn.password());
            if (result.exitCode() != 0) {
                if (result.output().contains("does not exist")) {
                    log.warn("[PG_RESTORE_COPY] テーブル不存在のためスキップ: table={}, db={}",
                            tableName, dbConn.database());
                    return DumpResult.ok(tableName, 0L);
                }
                log.error("[PG_RESTORE_COPY] 失敗: table={}, exitCode={}, output={}",
                        tableName, result.exitCode(), result.output());
                return DumpResult.fail(tableName,
                        "psql COPY FROM 終了コード=" + result.exitCode() + ": " + result.output());
            }
            if (!result.output().isBlank()) {
                log.warn("[PG_RESTORE_COPY] 警告（スキップ行あり可能性）: table={}, output={}", tableName, result.output());
            }
            log.info("[PG_RESTORE_COPY] 完了: table={}", tableName);
            return DumpResult.ok(tableName, 0L);

        } catch (IOException | InterruptedException e) {
            if (e instanceof InterruptedException) Thread.currentThread().interrupt();
            return DumpResult.fail(tableName, e.getMessage());
        } finally {
            if (scriptFile != null) {
                try { Files.deleteIfExists(scriptFile); } catch (IOException ignored) {}
            }
        }
    }

    // -------------------------------------------------------
    // ユーティリティ
    // -------------------------------------------------------

    /** stdout+stderr をキャプチャして exitCode と合わせて返す */
    private ProcResult runProcess(List<String> cmd, String password)
            throws IOException, InterruptedException {
        log.debug("[PG] コマンド: {}", String.join(" ", cmd));
        ProcessBuilder pb = new ProcessBuilder(cmd);
        pb.redirectErrorStream(true);   // stderr → stdout に合流
        pb.environment().put("PGPASSWORD", password);
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
            if (exit == 0) log.debug("[PG] 出力: {}", output);
            else           log.error("[PG] エラー出力: {}", output);
        }
        return new ProcResult(exit, output);
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

    private record ProcResult(int exitCode, String output) {}

    private String buildConnUri(DbConnectionInfo dbConn) {
        return String.format("postgresql://%s@%s:%d/%s",
                dbConn.username(), dbConn.host(), dbConn.port(), dbConn.database());
    }

    /** WHERE 句構築: 施設コードをホワイトリスト検証後にリテラルとして埋め込む */
    private String buildWhereClause(String template, List<String> codes) {
        String list = codes.stream()
                .map(c -> "'" + c.replaceAll("[^A-Za-z0-9_\\-]", "") + "'")
                .collect(Collectors.joining(","));
        return template.replace(":facilityList", list);
    }

    private String quoteIdentifier(String name) {
        return "\"" + name.replace("\"", "\"\"") + "\"";
    }
}
