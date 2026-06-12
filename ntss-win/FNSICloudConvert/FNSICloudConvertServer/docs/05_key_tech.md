# 05 関鍵技術実装文書

> **言語**: Java 25 (Amazon Corretto 25)
> **フレームワーク**: Spring Boot 4.0.6 / Spring Framework 7.0.x

---

## 1. pg_dump / pg_restore コマンド構築（ProcessBuilder）

`pg_dump` と `pg_restore` を Java の `ProcessBuilder` で呼び出す。テーブル名・DB 接続情報などはコマンドライン引数として渡す（シェルを経由しないため shell injection のリスクなし）。

```java
package com.fnsi.cloudconverter.migration.pg;

import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class PgDumpServiceImpl implements PgDumpService {

    /**
     * pg_dump -Fd 形式でテーブルをダンプ
     *
     * 実行コマンド例:
     *   pg_dump -Fd -j 4 --no-acl --no-owner
     *           --table=order_tbl
     *           --where="facility_cd IN ('FAC001','FAC002')"
     *           -f /tmp/migration/job1/pg_dump/db1/order_tbl
     *           -d postgresql://user:pass@host:5432/transit_db_1
     */
    @Override
    public DumpResult dump(PgTableConfig config,
                           List<String> facilityCodes,
                           Path outputDir,
                           DbConnectionInfo dbConn) throws IOException {

        // テーブル名のホワイトリスト検証（SQL インジェクション防止）
        TableNameValidator.validate(config.getName());

        // WHERE 節の生成（施設コードはパラメータ化）
        String whereClause = buildWhereClause(config.getWhereTemplate(), facilityCodes);

        Path tableOutputDir = outputDir.resolve(config.getName());
        Files.createDirectories(tableOutputDir);

        List<String> command = new ArrayList<>(List.of(
            "pg_dump",
            "-Fd",                          // ディレクトリ形式
            "-j", "4",                      // 並列ダンプ（CPU コア数に合わせて調整）
            "--no-acl",
            "--no-owner",
            "--table", config.getName(),
            "-f", tableOutputDir.toString()
        ));

        if (whereClause != null && !whereClause.isBlank()) {
            command.add("--where");
            command.add(whereClause);
        }

        command.add("-d");
        command.add(dbConn.toJdbcUrl());    // postgresql://user:pass@host:5432/dbname

        ProcessBuilder pb = new ProcessBuilder(command);
        pb.redirectErrorStream(true);
        pb.environment().put("PGPASSWORD", dbConn.getPassword()); // 環境変数でパスワード渡し

        return executeProcess(pb, config.getName(), "pg_dump");
    }

    /**
     * pg_restore -Fd 形式でダンプを DB にリストア
     *
     * 実行コマンド例:
     *   pg_restore -Fd -j 8 --no-acl --no-owner
     *              -d postgresql://user:pass@host:5432/prod_db
     *              /tmp/migration/job1/pg_dump/order_tbl
     */
    @Override
    public RestoreResult restore(Path dumpDir,
                                  DbConnectionInfo targetDb,
                                  int parallelJobs) throws IOException {

        List<String> command = List.of(
            "pg_restore",
            "-Fd",
            "-j", String.valueOf(parallelJobs),
            "--no-acl",
            "--no-owner",
            "--exit-on-error",
            "-d", targetDb.toJdbcUrl(),
            dumpDir.toString()
        );

        ProcessBuilder pb = new ProcessBuilder(command);
        pb.redirectErrorStream(true);
        pb.environment().put("PGPASSWORD", targetDb.getPassword());

        return executeProcess(pb, dumpDir.getFileName().toString(), "pg_restore");
    }

    /** WHERE 節構築: 施設コードのバインドパラメータ化 */
    private String buildWhereClause(String template, List<String> facilityCodes) {
        if (template == null || facilityCodes == null || facilityCodes.isEmpty()) {
            return null;
        }
        // 施設コードをシングルクォートで囲んでカンマ区切り
        // ホワイトリスト検証: facility_cd は英数字+ハイフンのみ
        String codeList = facilityCodes.stream()
            .map(FacilityCodeValidator::validateAndQuote)  // 検証 + シングルクォート付与
            .collect(Collectors.joining(","));
        return template.replace(":facilityList", codeList);
    }

    /** ProcessBuilder の実行と終了コード確認 */
    private <T> T executeProcess(ProcessBuilder pb, String target, String cmd) throws IOException {
        Process process = pb.start();
        String output = new String(process.getInputStream().readAllBytes(), StandardCharsets.UTF_8);
        int exitCode = process.waitFor();
        if (exitCode != 0) {
            throw new MigrationProcessException(
                String.format("%s failed for %s (exit code: %d): %s", cmd, target, exitCode, output));
        }
        return (T) new DumpResult(target, exitCode, output);
    }
}
```

---

## 2. mongoexport | jq | mongoimport パイプライン呼び出し

`mongoexport` の出力を JVM 内でパイプして `jq 'del(._id)'` を通し、そのまま `mongoimport` に渡す。ProcessBuilder のパイプを使用。

```java
package com.fnsi.cloudconverter.migration.mongo;

@Service
public class MongoMigrationServiceImpl implements MongoMigrationService {

    /**
     * mongoexport | jq 'del(._id)' | mongoimport をストリームパイプで実行
     *
     * 実行コマンドイメージ:
     *   mongoexport --uri="mongodb://..." --db=transit_mongo --collection=orders
     *               --query='{"facility_cd":{"$in":["FAC001","FAC002"]}}'
     *   | jq 'del(._id)'
     *   | mongoimport --uri="mongodb://..." --db=prod_mongo --collection=orders
     *                 --drop
     */
    @Override
    public StreamResult exportAndImport(MongoCollectionConfig config,
                                         List<String> facilityCodes,
                                         MongoConnectionInfo sourceConn,
                                         MongoConnectionInfo targetConn) throws IOException {

        // mongoexport プロセス
        ProcessBuilder exportPb = new ProcessBuilder(
            "mongoexport",
            "--uri", sourceConn.getUri(),
            "--db", sourceConn.getDatabase(),
            "--collection", config.getName(),
            "--query", buildMongoQuery(config.getFilterField(), facilityCodes)
        );

        // jq プロセス（_id フィールド削除）
        ProcessBuilder jqPb = new ProcessBuilder("jq", "--compact-output", "del(._id)");

        // mongoimport プロセス
        ProcessBuilder importPb = new ProcessBuilder(
            "mongoimport",
            "--uri", targetConn.getUri(),
            "--db", targetConn.getDatabase(),
            "--collection", config.getName(),
            "--drop"        // 既存データを削除してインポート
        );

        // パイプ: export.stdout → jq.stdin → jq.stdout → import.stdin
        Process exportProcess = exportPb.start();
        Process jqProcess     = jqPb.start();
        Process importProcess = importPb.start();

        // export → jq のパイプをスレッドで繋ぐ
        Thread exportToJq = new Thread(() ->
            pipeStreams(exportProcess.getInputStream(), jqProcess.getOutputStream()));

        // jq → import のパイプをスレッドで繋ぐ
        Thread jqToImport = new Thread(() ->
            pipeStreams(jqProcess.getInputStream(), importProcess.getOutputStream()));

        exportToJq.start();
        jqToImport.start();

        int exportExit = exportProcess.waitFor();
        exportToJq.join();
        jqProcess.getOutputStream().close();

        int jqExit = jqProcess.waitFor();
        jqToImport.join();
        importProcess.getOutputStream().close();

        int importExit = importProcess.waitFor();

        if (exportExit != 0 || jqExit != 0 || importExit != 0) {
            throw new MigrationProcessException(
                String.format("Mongo pipeline failed: export=%d jq=%d import=%d",
                    exportExit, jqExit, importExit));
        }
        return new StreamResult(config.getName(), importExit);
    }

    /** MongoDB クエリ JSON 構築 */
    private String buildMongoQuery(String filterField, List<String> facilityCodes) {
        if (filterField == null || facilityCodes == null || facilityCodes.isEmpty()) {
            return "{}";
        }
        // JSON エスケープ済みの施設コードリストを生成
        String codesJson = facilityCodes.stream()
            .map(c -> "\"" + c.replace("\"", "\\\"") + "\"")
            .collect(Collectors.joining(",", "[", "]"));
        return String.format("{\"%s\":{\"$in\":%s}}", filterField, codesJson);
    }

    private void pipeStreams(InputStream in, OutputStream out) {
        try (in; out) {
            in.transferTo(out);
        } catch (IOException e) {
            Thread.currentThread().interrupt();
        }
    }
}
```

---

## 3. PK マッピング生成主ロジック（離線→在線）

テーブルごとに旧 ID 一覧を取得し、在線 RDS の SEQ から新 ID を一括取得して `pk_mapping` に INSERT する。

```java
package com.fnsi.cloudconverter.mapping.pk;

@Service
@RequiredArgsConstructor
public class PkMappingGeneratorService {

    private final JdbcTemplate transitJdbc;
    private final SeqBatchService seqBatchService;
    private final PkMappingService pkMappingService;
    private static final int BATCH_SIZE = 1000;

    /**
     * 離線→在線: 各テーブルの PK マッピングを生成
     *
     * ループ構造:
     *   テーブルリスト でループ
     *     → 中転 DB から旧 ID 一覧を取得
     *     → 在線 RDS SEQ から新 ID を件数分一括取得
     *     → pk_mapping テーブルにバッチ INSERT
     */
    public void generateMappings(List<String> tableNames, long jobId) {
        for (String tableName : tableNames) {
            log.info("[PK_MAPPING] テーブル {} の PK マッピング生成開始", tableName);

            // テーブル名のホワイトリスト検証（必須）
            TableNameValidator.validate(tableName);

            // 旧 ID 一覧を中転 DB から取得（ページング処理で大量データも対応）
            List<Long> oldIds = fetchOldIds(tableName);
            if (oldIds.isEmpty()) {
                log.info("[PK_MAPPING] {} は件数 0、スキップ", tableName);
                continue;
            }

            // 在線 RDS SEQ から新 ID を件数分一括取得
            List<Long> newIds = seqBatchService.fetchNextIds(tableName, oldIds.size());

            // バッチ INSERT（BATCH_SIZE 件ずつ）
            for (int i = 0; i < oldIds.size(); i += BATCH_SIZE) {
                int end = Math.min(i + BATCH_SIZE, oldIds.size());
                pkMappingService.insertBatch(
                    tableName,
                    oldIds.subList(i, end),
                    newIds.subList(i, end)
                );
            }

            log.info("[PK_MAPPING] {} 完了: {} 件のマッピングを生成", tableName, oldIds.size());
        }
    }

    /** 中転 DB から旧 ID 一覧を取得（ORDER BY id でページング） */
    private List<Long> fetchOldIds(String tableName) {
        // テーブル名は検証済みのため直接埋め込み（PreparedStatement でカラム名は指定不可）
        String sql = "SELECT id FROM \"" + tableName + "\" ORDER BY id";
        return transitJdbc.queryForList(sql, Long.class);
    }
}
```

---

## 4. FK 刷新主ロジック（COLUMN 型 / JSON 型）

### 4.1 COLUMN 型 FK

```java
package com.fnsi.cloudconverter.refresh.pg;

@Service
@RequiredArgsConstructor
public class FkRefreshServiceImpl implements FkRefreshService {

    private final JdbcTemplate transitJdbc;
    private final FkConfigRepository fkConfigRepository;

    /**
     * COLUMN 型 FK の刷新
     *
     * 実行 SQL:
     *   UPDATE "order_detail" t
     *   SET "order_id" = pm.new_id
     *   FROM pk_mapping pm
     *   WHERE pm.table_name = 'order_tbl'
     *     AND t."order_id" = pm.old_id
     */
    @Override
    public int refreshColumnFk(FkMigrationConfig config) {
        // テーブル名・カラム名のホワイトリスト検証
        TableNameValidator.validate(config.getTableName());
        ColumnNameValidator.validate(config.getColumnName());

        String sql = String.format(
            "UPDATE \"%s\" t SET \"%s\" = pm.new_id " +
            "FROM pk_mapping pm " +
            "WHERE pm.table_name = ? AND t.\"%s\" = pm.old_id",
            config.getTableName(),
            config.getColumnName(),
            config.getColumnName()
        );

        int affected = transitJdbc.update(sql, config.getRefTable());
        log.info("[FK_REFRESH] COLUMN {}.{} 更新件数: {}",
            config.getTableName(), config.getColumnName(), affected);
        return affected;
    }

    /**
     * JSON 型 FK の刷新（jsonb_set を使用）
     *
     * 実行 SQL:
     *   UPDATE "order_tbl" t
     *   SET "payload" = jsonb_set(
     *       t."payload",
     *       '{items,itemId}',
     *       to_jsonb(pm.new_id)
     *   )
     *   FROM pk_mapping pm
     *   WHERE pm.table_name = 'item_tbl'
     *     AND (t."payload" #>> '{items,itemId}')::bigint = pm.old_id
     */
    @Override
    public int refreshJsonFk(FkMigrationConfig config) {
        TableNameValidator.validate(config.getTableName());
        ColumnNameValidator.validate(config.getJsonColumn());
        JsonPathValidator.validate(config.getJsonPath()); // '{items,itemId}' 形式の検証

        String sql = String.format(
            "UPDATE \"%s\" t " +
            "SET \"%s\" = jsonb_set(t.\"%s\", '%s', to_jsonb(pm.new_id)) " +
            "FROM pk_mapping pm " +
            "WHERE pm.table_name = ? " +
            "  AND (t.\"%s\" #>> '%s')::bigint = pm.old_id",
            config.getTableName(),
            config.getJsonColumn(), config.getJsonColumn(), config.getJsonPath(),
            config.getJsonColumn(), config.getJsonPath()
        );

        int affected = transitJdbc.update(sql, config.getRefTable());
        log.info("[FK_REFRESH] JSON {}.{}[{}] 更新件数: {}",
            config.getTableName(), config.getJsonColumn(), config.getJsonPath(), affected);
        return affected;
    }

    /**
     * 全 FK 刷新メインループ
     * execution_order 昇順で 1 外键参照ずつ逐次処理
     */
    @Override
    public FkRefreshResult refreshAll() {
        List<FkMigrationConfig> configs =
            fkConfigRepository.findByEnabledTrueOrderByExecutionOrderAsc();

        int totalAffected = 0;
        for (FkMigrationConfig config : configs) {
            int affected = switch (config.getFkType()) {
                case "COLUMN" -> refreshColumnFk(config);
                case "JSON"   -> refreshJsonFk(config);
                default -> throw new IllegalArgumentException("Unknown fkType: " + config.getFkType());
            };
            totalAffected += affected;
        }
        return new FkRefreshResult(configs.size(), totalAffected);
    }
}
```

---

## 5. MongoDB FK 刷新主ロジック（dot path + [] 配列サポート）

`field_path` が `orders[].items[].item_id` のような配列ネスト構造に対応する。

```java
package com.fnsi.cloudconverter.refresh.mongo;

@Service
@RequiredArgsConstructor
public class MongoFkRefreshServiceImpl implements MongoFkRefreshService {

    private final PkMappingService pkMappingService;

    /**
     * Mongo ドキュメントの FK 刷新メインロジック
     *
     * field_path 例:
     *   "user_id"                    → トップレベルフィールド
     *   "order.created_by"           → ネストフィールド
     *   "items[].item_id"            → 配列内フィールド
     *   "orders[].items[].item_id"   → 多重ネスト配列内フィールド
     */
    @Override
    public MongoRefreshResult refreshByFieldPath(FkMongoMigrationConfig config,
                                                   MongoDatabase transitDb) {

        MongoCollection<Document> collection = transitDb.getCollection(config.getCollectionName());

        // pk_mapping から全マッピングを取得（Map<oldId, newId>）
        Map<Long, Long> mappings = pkMappingService.findAllMappings(config.getRefTableName());
        if (mappings.isEmpty()) return MongoRefreshResult.empty();

        // フィールドパスを解析（配列 [] の位置を特定）
        FieldPathParser.ParsedPath parsedPath = FieldPathParser.parse(config.getFieldPath());

        // コレクション内の全ドキュメントをイテレート（BulkWrite でバッチ更新）
        List<WriteModel<Document>> bulkOps = new ArrayList<>();
        int updatedCount = 0;

        try (MongoCursor<Document> cursor = collection.find().cursor()) {
            while (cursor.hasNext()) {
                Document doc = cursor.next();
                boolean modified = traverseAndReplace(doc, parsedPath.getSegments(), mappings);
                if (modified) {
                    bulkOps.add(new ReplaceOneModel<>(
                        Filters.eq("_id", doc.getObjectId("_id")), doc));
                    updatedCount++;
                }
                // バッチサイズに達したら BulkWrite 実行
                if (bulkOps.size() >= 500) {
                    collection.bulkWrite(bulkOps, new BulkWriteOptions().ordered(false));
                    bulkOps.clear();
                }
            }
        }
        if (!bulkOps.isEmpty()) {
            collection.bulkWrite(bulkOps, new BulkWriteOptions().ordered(false));
        }

        return new MongoRefreshResult(config.getCollectionName(), updatedCount);
    }

    /**
     * ドキュメントを再帰的に走査して ID を置換
     * @param obj  現在のオブジェクト（Document または List）
     * @param segments  パスセグメント配列（"[]" は配列展開を意味する）
     * @param mappings  旧 ID → 新 ID マッピング
     * @return ドキュメントが変更されたか
     */
    @SuppressWarnings("unchecked")
    private boolean traverseAndReplace(Object obj, String[] segments, Map<Long, Long> mappings) {
        if (obj == null || segments.length == 0) return false;

        String head = segments[0];
        String[] tail = Arrays.copyOfRange(segments, 1, segments.length);

        if (head.equals("[]")) {
            // 配列展開: 全要素に再帰適用
            if (!(obj instanceof List)) return false;
            boolean modified = false;
            for (Object item : (List<?>) obj) {
                modified |= traverseAndReplace(item, tail, mappings);
            }
            return modified;

        } else if (tail.length == 0) {
            // 末端フィールド: 旧 ID → 新 ID に置換
            if (!(obj instanceof Document doc)) return false;
            Object value = doc.get(head);
            if (!(value instanceof Number)) return false;
            Long oldId = ((Number) value).longValue();
            Long newId = mappings.get(oldId);
            if (newId != null && !newId.equals(oldId)) {
                doc.put(head, newId);
                return true;
            }
            return false;

        } else {
            // 中間フィールド: 再帰
            if (!(obj instanceof Document doc)) return false;
            return traverseAndReplace(doc.get(head), tail, mappings);
        }
    }
}

/** フィールドパスパーサー: "orders[].items[].item_id" → ["orders", "[]", "items", "[]", "item_id"] */
class FieldPathParser {
    public static ParsedPath parse(String fieldPath) {
        // "items[].item_id" → split by "." then "[]" の展開
        List<String> segments = new ArrayList<>();
        for (String part : fieldPath.split("\\.")) {
            if (part.endsWith("[]")) {
                segments.add(part.substring(0, part.length() - 2)); // フィールド名
                segments.add("[]");  // 配列展開マーカー
            } else {
                segments.add(part);
            }
        }
        return new ParsedPath(segments.toArray(new String[0]));
    }
    record ParsedPath(String[] segments) {}
}
```

---

## 6. 在線生産 SEQ 一括申請ロジック

在線生産 DB のシーケンスから必要件数分の連番を一括取得する。ネットワーク往復を最小化するため、1 回のクエリで全件取得する。

```java
package com.fnsi.cloudconverter.mapping.seq;

@Service
@RequiredArgsConstructor
public class SeqBatchServiceImpl implements SeqBatchService {

    private final JdbcTemplate onlineProdJdbc;  // 在線生産 RDS への接続

    /**
     * 指定テーブルのシーケンスから count 件の連番を一括取得
     *
     * 実行 SQL:
     *   SELECT nextval('"order_tbl_id_seq"')
     *   FROM generate_series(1, 15230)
     *
     * 1 回のクエリで全件取得 → ネットワーク往復コスト最小化
     */
    @Override
    public List<Long> fetchNextIds(String tableName, int count) {
        // テーブル名のホワイトリスト検証（必須）
        TableNameValidator.validate(tableName);

        String seqName = "\"" + tableName + "_id_seq\"";
        String sql = String.format(
            "SELECT nextval(%s) FROM generate_series(1, ?)", seqName);

        List<Long> ids = onlineProdJdbc.queryForList(sql, Long.class, count);

        log.info("[SEQ] テーブル {} から {} 件の SEQ を取得: {} 〜 {}",
            tableName, ids.size(), ids.get(0), ids.get(ids.size() - 1));
        return ids;
    }
}
```

---

## 7. Job/Task ステータスマシン + 有限リトライ機構

```java
package com.fnsi.cloudconverter.task;

@Service
@RequiredArgsConstructor
public class TaskExecutorServiceImpl implements TaskExecutorService {

    private final MigrationTaskRepository taskRepository;
    private final MigrationLogService logService;

    @Value("${migration.task.retry-interval-ms:5000}")
    private long retryIntervalMs;

    /**
     * Task を実行（有限リトライ付き）
     *
     * リトライ対象: 接続エラー（SQLException、MongoException）
     * 非リトライ対象: 業務ロジックエラー（MigrationBusinessException）
     */
    @Override
    public TaskResult execute(MigrationTask task, Callable<TaskResult> action) {
        updateStatus(task.getTaskId(), TaskStatus.RUNNING, null);

        while (true) {
            try {
                TaskResult result = action.call();
                // 成功
                updateStatus(task.getTaskId(), TaskStatus.DONE, null);
                logService.info(task.getTaskId(),
                    String.format("完了: %d 件処理", result.getAffectedRows()));
                return result;

            } catch (MigrationBusinessException e) {
                // 業務ロジックエラー: 即座に FAILED（リトライしない）
                handleFailure(task, e, false);
                throw e;

            } catch (Exception e) {
                // 接続エラー等: リトライ可能か判定
                task.setRetryCount(task.getRetryCount() + 1);
                taskRepository.save(task);

                if (task.getRetryCount() > task.getMaxRetry()) {
                    // リトライ上限超過: FAILED
                    handleFailure(task, e, true);
                    throw new TaskMaxRetryExceededException(task, e);
                }

                // リトライ間隔を待って再実行
                logService.warn(task.getTaskId(),
                    String.format("エラー発生（%d/%d 回目リトライ）: %s",
                        task.getRetryCount(), task.getMaxRetry(), e.getMessage()));
                try {
                    Thread.sleep(retryIntervalMs);
                } catch (InterruptedException ie) {
                    Thread.currentThread().interrupt();
                    throw new TaskInterruptedException(task, ie);
                }
            }
        }
    }

    private void handleFailure(MigrationTask task, Exception e, boolean logError) {
        updateStatus(task.getTaskId(), TaskStatus.FAILED, e.getMessage());
        if (logError) {
            logService.error(task.getTaskId(), "Task 失敗（リトライ上限超過）", e);
        } else {
            logService.error(task.getTaskId(), "業務エラーで Task 失敗", e);
        }
    }

    @Override
    public void updateStatus(long taskId, TaskStatus status, String errorMsg) {
        MigrationTask task = taskRepository.findById(taskId)
            .orElseThrow(() -> new EntityNotFoundException("Task not found: " + taskId));
        task.setStatus(status);
        task.setLastError(errorMsg);
        if (status == TaskStatus.RUNNING) {
            task.setStartedAt(Instant.now());
        } else if (status == TaskStatus.DONE || status == TaskStatus.FAILED) {
            task.setFinishedAt(Instant.now());
        }
        taskRepository.save(task);
    }
}
```

---

## 8. 同一施設並行ロック（DB 行ロック）

PostgreSQL の `SELECT FOR UPDATE NOWAIT` を使用して、同一施設の重複実行を DB レベルで防止する。

```java
package com.fnsi.cloudconverter.job;

@Service
@RequiredArgsConstructor
public class FacilityLockService {

    private final JdbcTemplate converterJdbc;

    /**
     * 施設ロックを取得する
     * 競合時は即座に例外をスロー（NOWAIT オプション）
     *
     * 使用方法:
     *   トランザクション内で呼び出すこと。
     *   トランザクション終了（COMMIT/ROLLBACK）時に自動解放される。
     *
     * @throws FacilityAlreadyLockedException 同一施設が処理中の場合
     */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void acquireLock(List<String> facilityCodes, long jobId) {
        for (String facilityCode : facilityCodes) {
            try {
                // FOR UPDATE NOWAIT: ロック取得できない場合は即座に例外
                converterJdbc.queryForObject(
                    "SELECT facility_cd FROM facility_lock " +
                    "WHERE facility_cd = ? FOR UPDATE NOWAIT",
                    String.class,
                    facilityCode
                );
                // ロック取得成功: locked_by を更新
                converterJdbc.update(
                    "UPDATE facility_lock SET locked_by = ?, locked_at = NOW() WHERE facility_cd = ?",
                    jobId, facilityCode
                );
            } catch (DataAccessException e) {
                if (isConcurrentLockError(e)) {
                    throw new FacilityAlreadyLockedException(
                        String.format("施設 %s は現在処理中です。しばらく後に再試行してください。", facilityCode));
                }
                throw e;
            }
        }
    }

    /** ロック解放（JOB 完了/失敗時に呼ぶ） */
    public void releaseLock(List<String> facilityCodes) {
        for (String facilityCode : facilityCodes) {
            converterJdbc.update(
                "UPDATE facility_lock SET locked_by = NULL, locked_at = NULL WHERE facility_cd = ?",
                facilityCode
            );
        }
    }

    private boolean isConcurrentLockError(DataAccessException e) {
        // PostgreSQL エラーコード 55P03: lock_not_available
        Throwable cause = e.getCause();
        return cause instanceof SQLException sqle
            && "55P03".equals(sqle.getSQLState());
    }
}
```

---

## 9. JWT 長タスク続約機構

長時間 JOB 実行中にクライアントが 1 秒ポーリングを行う際、JWT の有効期限が近づいたら自動的に新しいトークンを Response ヘッダーに添付して返す。

```java
package com.fnsi.cloudconverter.auth;

/**
 * JWT 自動続約フィルター
 * 全 API リクエストで動作: 残り有効期限 < threshold の場合に新トークンを返す
 */
@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtTokenProvider jwtTokenProvider;
    private final UserDetailsService userDetailsService;

    // 残り有効期限がこの値を下回ったら新トークン発行（デフォルト: 10分）
    @Value("${security.jwt.renew-threshold-minutes:10}")
    private long renewThresholdMinutes;

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                     HttpServletResponse response,
                                     FilterChain filterChain)
            throws ServletException, IOException {

        String token = extractToken(request);
        if (token != null && jwtTokenProvider.validateToken(token)) {
            // トークンを SecurityContext に設定
            String username = jwtTokenProvider.getUsernameFromToken(token);
            UserDetails userDetails = userDetailsService.loadUserByUsername(username);
            UsernamePasswordAuthenticationToken auth =
                new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());
            SecurityContextHolder.getContext().setAuthentication(auth);

            // 残り有効期限チェック
            long remainingMillis = jwtTokenProvider.getExpiryMillis(token) - System.currentTimeMillis();
            long thresholdMillis = renewThresholdMinutes * 60 * 1000;

            if (remainingMillis > 0 && remainingMillis < thresholdMillis) {
                // 新トークンを Response ヘッダーに添付
                String newToken = jwtTokenProvider.generateAccessToken(userDetails);
                response.setHeader("X-Renewed-Token", newToken);
                response.setHeader("X-Token-Expires-In",
                    String.valueOf(jwtTokenProvider.getExpiryMillis(newToken)));
                log.debug("[JWT] トークン自動続約: ユーザー={}, 残り={} ms", username, remainingMillis);
            }
        }

        filterChain.doFilter(request, response);
    }

    private String extractToken(HttpServletRequest request) {
        String header = request.getHeader("Authorization");
        if (header != null && header.startsWith("Bearer ")) {
            return header.substring(7);
        }
        return null;
    }
}
```

**クライアント側の処理**:
```
GET /jobs/{jobId} のレスポンスヘッダー確認
  → X-Renewed-Token が存在する場合、次回リクエストからそのトークンを使用
```

---

## 10. YAML 設定ファイル読み込みと direction フィルタリング

`pg_dump_config.yaml` の `direction` フィールドで、どちらの移行方向でそのテーブルを処理するかを制御する。

```java
package com.fnsi.cloudconverter.migration.pg;

/**
 * pg_dump_config.yaml の読み込みと direction フィルタリング
 *
 * direction 値:
 *   both   → 離線→在線 / 在線→離線 両方で処理
 *   off2on → 離線→在線 のみで処理
 *   on2off → 在線→離線 のみで処理
 *   (dump: false) → 処理対象外（direction に関係なくスキップ）
 */
@Configuration
@ConfigurationProperties(prefix = "pg-dump")
@Validated
public class PgDumpConfig {

    @Valid
    @NotEmpty
    private List<PgTableConfig> tables = new ArrayList<>();

    /**
     * 移行方向に応じたテーブル設定リストを返す
     * @param direction "off2on" または "on2off"
     */
    public List<PgTableConfig> getTablesForDirection(String direction) {
        return tables.stream()
            .filter(PgTableConfig::isDump)               // dump: false はスキップ
            .filter(t -> matchesDirection(t, direction)) // direction フィルタリング
            .collect(Collectors.toList());
    }

    private boolean matchesDirection(PgTableConfig config, String direction) {
        String d = config.getDirection();
        if (d == null) return true;  // direction 未指定は全方向で処理
        return switch (d.toLowerCase()) {
            case "both"   -> true;
            case "off2on" -> "off2on".equals(direction);
            case "on2off" -> "on2off".equals(direction);
            default -> {
                log.warn("[CONFIG] 不明な direction 値: '{}' テーブル: {}", d, config.getName());
                yield false;
            }
        };
    }
}

/** テーブル設定エンティティ */
public class PgTableConfig {
    @NotBlank
    private String name;           // テーブル名
    @NotBlank
    private String idColumn;       // PK カラム名
    private boolean dump = true;   // ダンプ対象か（デフォルト: true）
    private String whereTemplate;  // WHERE テンプレート
    private boolean toZip = false; // ZIP 圧縮するか
    private String direction = "both"; // both / off2on / on2off
}
```

**使用例（JobService 内）**:
```java
// 在線→離線 JOB の場合: direction = "on2off" のテーブルのみ取得
List<PgTableConfig> tables = pgDumpConfig.getTablesForDirection("on2off");
for (PgTableConfig table : tables) {
    pgDumpService.dump(table, facilityCodes, exportDir, dbKey);
}
```

**mongo_dump_config.yaml の対応（direction フィールドなし）**:

Mongo コレクションは `dump: true/false` のみで制御し、direction フィルタリングは不要（全方向で同じコレクションを使用）:
```java
public List<MongoCollectionConfig> getDumpTargets() {
    return collections.stream()
        .filter(MongoCollectionConfig::isDump)
        .collect(Collectors.toList());
}
```

---

## セキュリティ対策サマリー

| 対策 | 実装箇所 | 詳細 |
|------|--------|------|
| SQL インジェクション防止 | 全 SQL 生成箇所 | テーブル名・カラム名のホワイトリスト検証 + PreparedStatement |
| Shell インジェクション防止 | ProcessBuilder 使用 | 引数リスト渡し（シェル経由しない）|
| JWT 認証 | JwtAuthenticationFilter | 全 API リクエストで検証 |
| 施設並行ロック | FacilityLockService | DB 行ロック（FOR UPDATE NOWAIT）|
| パスワード保護 | ProcessBuilder | PGPASSWORD 環境変数で渡し（コマンド引数に露出しない）|
| 識別子クォート | 全 SQL | PostgreSQL 二重引用符で識別子を保護 |
