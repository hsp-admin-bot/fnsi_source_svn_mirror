package com.fnsi.cloudconverter.task;

import com.fnsi.cloudconverter.clear.online.file.OnlineFileClearService;
import com.fnsi.cloudconverter.clear.online.pg.OnlinePgClearService;
import com.fnsi.cloudconverter.clear.transit.file.TransitFileClearService;
import com.fnsi.cloudconverter.clear.transit.mongo.TransitMongoClearService;
import com.fnsi.cloudconverter.clear.transit.pg.TransitPgClearService;
import com.fnsi.cloudconverter.common.exception.MigrationBusinessException;
import com.fnsi.cloudconverter.job.FacilityLockService;
import com.fnsi.cloudconverter.job.entity.MigrationJob;
import com.fnsi.cloudconverter.job.entity.MigrationTask;
import com.fnsi.cloudconverter.job.model.CreateJobRequest;
import com.fnsi.cloudconverter.job.model.JobStatus;
import com.fnsi.cloudconverter.job.model.TaskStatus;
import com.fnsi.cloudconverter.job.repository.MigrationJobRepository;
import com.fnsi.cloudconverter.job.repository.MigrationTaskRepository;
import com.fnsi.cloudconverter.log.MigrationLogService;
import com.fnsi.cloudconverter.mapping.fk.repository.FkMigrationConfigRepository;
import com.fnsi.cloudconverter.mapping.fkmongo.repository.FkMongoMigrationConfigRepository;
import com.fnsi.cloudconverter.mapping.pk.PkMappingService;
import com.fnsi.cloudconverter.mapping.seq.SeqBatchService;
import com.fnsi.cloudconverter.migration.mongo.MongoCollectionConfig;
import com.fnsi.cloudconverter.migration.mongo.MongoConnectionInfo;
import com.fnsi.cloudconverter.migration.mongo.MongoDumpConfig;
import com.fnsi.cloudconverter.migration.mongo.MongoMigrationService;
import com.fnsi.cloudconverter.migration.mongo.MongoToolProfile;
import com.fnsi.cloudconverter.migration.mongo.StreamResult;
import com.fnsi.cloudconverter.migration.pg.DbConnectionInfo;
import com.fnsi.cloudconverter.migration.pg.DumpResult;
import com.fnsi.cloudconverter.migration.pg.PgDumpConfig;
import com.fnsi.cloudconverter.migration.pg.PgDumpService;
import com.fnsi.cloudconverter.migration.pg.PgTableConfig;
import com.fnsi.cloudconverter.onlinemongo.OnlineMongoAccessService;
import com.fnsi.cloudconverter.refresh.file.FileRenameRefreshService;
import com.fnsi.cloudconverter.refresh.mongo.MongoFkRefreshService;
import com.fnsi.cloudconverter.refresh.pg.FkRefreshService;
import com.fnsi.cloudconverter.util.archive.ArchiveService;
import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoDatabase;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;
import org.springframework.stereotype.Service;
import tools.jackson.databind.ObjectMapper;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Queue;
import java.util.Set;
import java.util.concurrent.Future;
import java.util.concurrent.atomic.AtomicLong;
import java.util.stream.Collectors;

@Service
public class JobExecutorServiceImpl implements JobExecutorService {

    private static final org.slf4j.Logger log = org.slf4j.LoggerFactory.getLogger(JobExecutorServiceImpl.class);
    private static final int PK_REFRESH_BATCH_SIZE = 5_000;
    // -------------------------------------------------------
    // 依存コンポーネント
    // -------------------------------------------------------

    @Autowired
    private MigrationJobRepository jobRepository;
    @Autowired
    private MigrationTaskRepository taskRepository;
    @Autowired
    private TaskExecutorService taskExecutorService;
    @Autowired
    private MigrationLogService logService;
    @Autowired
    private FacilityLockService facilityLockService;
    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private PgDumpService pgDumpService;
    @Autowired
    private MongoMigrationService mongoMigrationService;
    @Autowired
    private PkMappingService pkMappingService;
    @Autowired
    private SeqBatchService seqBatchService;
    @Autowired
    private FkRefreshService fkRefreshService;
    @Autowired
    private MongoFkRefreshService mongoFkRefreshService;
    @Autowired
    private FkMigrationConfigRepository fkMigrationConfigRepository;
    @Autowired
    private FkMongoMigrationConfigRepository fkMongoMigrationConfigRepository;
    @Autowired
    private FileRenameRefreshService fileRenameRefreshService;
    @Autowired
    private ArchiveService archiveService;

    @Autowired
    private OnlinePgClearService onlinePgClearService;
    @Autowired
    private TransitPgClearService transitPgClearService;
    @Autowired
    private TransitMongoClearService transitMongoClearService;
    @Autowired
    private OnlineFileClearService onlineFileClearService;
    @Autowired
    private TransitFileClearService transitFileClearService;
    @Autowired
    private OnlineMongoAccessService onlineMongoAccessService;

    @Autowired
    private PgDumpConfig pgDumpConfig;
    @Autowired
    private MongoDumpConfig mongoDumpConfig;

    // Transit JdbcTemplates (ntss_db4/5/6)
    @Autowired
    @Qualifier("transitJdbc1")
    private JdbcTemplate transitJdbc1;
    @Autowired
    @Qualifier("transitJdbc2")
    private JdbcTemplate transitJdbc2;
    @Autowired
    @Qualifier("transitJdbc3")
    private JdbcTemplate transitJdbc3;

    // Converter DB JdbcTemplate (pk_mapping source)
    @Autowired
    @Qualifier("converterJdbc")
    private JdbcTemplate converterJdbc;

    // Online JdbcTemplates
    @Autowired
    @Qualifier("onlineDefaultJdbc")
    private JdbcTemplate onlineDefaultJdbc;
    @Autowired
    @Qualifier("onlinePersonalJdbc")
    private JdbcTemplate onlinePersonalJdbc;
    @Autowired
    @Qualifier("onlineAuthJdbc")
    private JdbcTemplate onlineAuthJdbc;

    // Transit DB connection info for ProcessBuilder
    @Autowired
    @Qualifier("transitDb1ConnInfo")
    private DbConnectionInfo transitDb1ConnInfo;
    @Autowired
    @Qualifier("transitDb2ConnInfo")
    private DbConnectionInfo transitDb2ConnInfo;
    @Autowired
    @Qualifier("transitDb3ConnInfo")
    private DbConnectionInfo transitDb3ConnInfo;

    // Online DB connection info for ProcessBuilder
    @Autowired
    @Qualifier("onlineDefaultConnInfo")
    private DbConnectionInfo onlineDefaultConnInfo;
    @Autowired
    @Qualifier("onlinePersonalConnInfo")
    private DbConnectionInfo onlinePersonalConnInfo;
    @Autowired
    @Qualifier("onlineAuthConnInfo")
    private DbConnectionInfo onlineAuthConnInfo;

    @Autowired
    @Qualifier("refreshJsonExecutor")
    private ThreadPoolTaskExecutor threadPoolTaskExecutor;

    // MongoClients
    @Autowired
    private MongoClient transitMongoClient;

    @Value("${transit.data.mongodb.connection-string}")
    private String transitMongoUri;

    @Value("${migration.storage.base-path:/tmp/migration}")
    private String basePath;

    @Value("${migration.storage.efs-path:/tmp/efs}")
    private String efsBasePath;

    /**
     * マイグレーション対象 DB 名リスト
     */
    private static final List<String> MIGRATION_DBS = List.of("ntss_db4", "ntss_db5", "ntss_db6");

    // -------------------------------------------------------
    // DB ルーティングヘルパー
    // -------------------------------------------------------

    private JdbcTemplate transitJdbcFor(String dbName) {
        return switch (dbName) {
            case "ntss_db4" -> transitJdbc1;
            case "ntss_db6" -> transitJdbc3;
            default -> transitJdbc2;   // ntss_db5
        };
    }

    private DbConnectionInfo transitConnInfoFor(String dbName) {
        return switch (dbName) {
            case "ntss_db4" -> transitDb1ConnInfo;
            case "ntss_db6" -> transitDb3ConnInfo;
            default -> transitDb2ConnInfo;  // ntss_db5
        };
    }

    private JdbcTemplate onlineJdbcFor(String dbName) {
        return switch (dbName) {
            case "ntss_db4" -> onlineAuthJdbc;
            case "ntss_db6" -> onlinePersonalJdbc;
            default -> onlineDefaultJdbc;  // ntss_db5
        };
    }

    private DbConnectionInfo onlineConnInfoFor(String dbName) {
        return switch (dbName) {
            case "ntss_db4" -> onlineAuthConnInfo;
            case "ntss_db6" -> onlinePersonalConnInfo;
            default -> onlineDefaultConnInfo; // ntss_db5
        };
    }

    private boolean tableExists(JdbcTemplate jdbc, String schemaName, String tableName) {
        Boolean exists = jdbc.queryForObject("SELECT EXISTS (" + "SELECT 1 FROM information_schema.tables " + "WHERE table_schema = ? AND table_name = ?)", Boolean.class, schemaName, tableName);
        return Boolean.TRUE.equals(exists);
    }


    // -------------------------------------------------------
    // 公開メソッド
    // -------------------------------------------------------

    @Override
    @Async("migrationTaskExecutor")
    public void startAsync(long jobId, CreateJobRequest request) {
        log.info("[JOB_EXEC] 非同期実行開始: jobId={}", jobId);
        executeJob(jobId, request);
    }

    @Override
    @Async("migrationTaskExecutor")
    public void resumeAsync(long jobId) {
        log.info("[JOB_EXEC] 断点再開: jobId={}", jobId);
        MigrationJob job = findJob(jobId);
        CreateJobRequest request = deserializeJobParams(job.getJobParams());
        executeJob(jobId, request);
    }

    // -------------------------------------------------------
    // JOB 実行ループ
    // -------------------------------------------------------

    private void executeJob(long jobId, CreateJobRequest request) {
        MigrationJob job = findJob(jobId);
        List<String> facilityCodes = Arrays.asList(job.getFacilityCodes());

        job.setStatus(JobStatus.RUNNING);
        job.setStartedAt(Instant.now());
        jobRepository.save(job);
        logService.info(jobId, null, "JOB 実行開始: direction=" + job.getDirection());

        try {
            List<MigrationTask> pending = taskRepository.findByJobIdOrderByTaskId(jobId).stream().filter(t -> t.getStatus() == TaskStatus.PENDING).toList();

            for (MigrationTask task : pending) {
                TaskResult result = dispatchTask(task, job, request, facilityCodes);
                if (!result.success()) {
                    markJobFailed(jobId, "Task 失敗: " + task.getTaskName() + " — " + result.errorMessage());
                    facilityLockService.releaseLock(facilityCodes);
                    return;
                }
            }

            job = findJob(jobId);
            job.setStatus(JobStatus.DONE);
            job.setFinishedAt(Instant.now());
            jobRepository.save(job);
            facilityLockService.releaseLock(facilityCodes);
            pkMappingService.deleteByJobId(jobId);
            logService.info(jobId, null, "JOB 完了");
            log.info("[JOB_EXEC] 完了: jobId={}", jobId);

        } catch (Exception e) {
            log.error("[JOB_EXEC] 予期しないエラー: jobId={}", jobId, e);
            markJobFailed(jobId, "予期しないエラー: " + e.getMessage());
            facilityLockService.releaseLock(facilityCodes);
            logService.error(jobId, null, "JOB 予期しないエラー: " + e.getMessage(), e);
        }
    }

    // -------------------------------------------------------
    // Task ディスパッチ
    // -------------------------------------------------------

    private TaskResult dispatchTask(MigrationTask task, MigrationJob job, CreateJobRequest request, List<String> facilityCodes) {
        long jobId = job.getJobId();
        String name = task.getTaskName();
        prepareTaskEstimate(task, job, facilityCodes);
        log.info("[JOB_EXEC] Task 開始: jobId={}, task={}", jobId, name);

        return switch (name) {
            case "TASK1_PG_IMPORT" ->
                    taskExecutorService.execute(task, () -> off2on_task1PgImport(task, request, facilityCodes, jobId));
            case "TASK2_PK_MAPPING" ->
                    taskExecutorService.execute(task, () -> off2on_task2PkMapping(task, facilityCodes, jobId));
            case "TASK3_PK_REFRESH" -> taskExecutorService.execute(task, () -> pkRefresh(task, job));
            case "TASK4_FK_REFRESH" ->
                    taskExecutorService.execute(task, () -> fkRefresh(task, job, facilityCodes, jobId));
            case "TASK5_MONGO_IMPORT" ->
                    taskExecutorService.execute(task, () -> off2on_task5MongoImport(task, request, facilityCodes, jobId));
            case "TASK6_MONGO_FK_REFRESH" ->
                    taskExecutorService.execute(task, () -> mongoFkRefresh(task, jobId, transitMongoClient, transitMongoUri));
            case "TASK7_PG_EXPORT" ->
                    taskExecutorService.execute(task, () -> off2on_task7PgExport(task, facilityCodes, jobId));
            case "TASK8_PG_RESTORE_PROD" ->
                    taskExecutorService.execute(task, () -> off2on_task8PgRestoreProd(task, facilityCodes, jobId));
            case "TASK9_MONGO_EXPORT_IMPORT" ->
                    taskExecutorService.execute(task, () -> mongoExportImport(task, facilityCodes, jobId, transitMongoUri, onlineMongoAccessService.connectionUri(), true));
            case "TASK1_PG_EXPORT_PROD" ->
                    taskExecutorService.execute(task, () -> on2off_task1PgExportProd(task, facilityCodes, jobId));
            case "TASK2_PG_IMPORT_TRANSIT" ->
                    taskExecutorService.execute(task, () -> on2off_task2PgImportTransit(task, jobId));
            case "TASK3_MONGO_EXPORT_IMPORT" ->
                    taskExecutorService.execute(task, () -> mongoExportImport(task, facilityCodes, jobId, onlineMongoAccessService.connectionUri(), transitMongoUri, false));
            case "TASK4_PK_MAPPING" ->
                    taskExecutorService.execute(task, () -> on2off_task4PkMapping(task, request, facilityCodes, jobId));
            case "TASK5_PK_REFRESH" -> taskExecutorService.execute(task, () -> pkRefresh(task, job));
            case "TASK6_FK_REFRESH" ->
                    taskExecutorService.execute(task, () -> fkRefresh(task, job, facilityCodes, jobId));
            case "TASK7_MONGO_FK_REFRESH" ->
                    taskExecutorService.execute(task, () -> mongoFkRefresh(task, jobId, transitMongoClient, transitMongoUri));
            case "TASK8_PG_EXPORT_TRANSIT" ->
                    taskExecutorService.execute(task, () -> on2off_task8PgExportTransit(task, facilityCodes, jobId));
            case "TASK9_MONGO_EXPORT" ->
                    taskExecutorService.execute(task, () -> on2off_task9MongoExport(task, facilityCodes, jobId));
            case "TASK10_FILE_COPY" ->
                    taskExecutorService.execute(task, () -> task10FileCopy(task, request, facilityCodes, jobId, job.getDirection()));
            default -> TaskResult.fail(task.getTaskId(), name, "未知の Task 名: " + name);
        };
    }

    private void prepareTaskEstimate(MigrationTask task, MigrationJob job, List<String> facilityCodes) {
        long estimated = estimateTaskWorkUnits(task.getTaskName(), job.getDirection(), facilityCodes);
        if (estimated <= 0) {
            return;
        }

        MigrationTask persisted = taskRepository.findById(task.getTaskId()).orElse(task);
        persisted.setEstimatedRows(estimated);
        taskRepository.save(persisted);
        task.setEstimatedRows(estimated);
    }

    private long estimateTaskWorkUnits(String taskName, String direction, List<String> facilityCodes) {
        return switch (taskName) {
            case "TASK1_PG_IMPORT", "TASK1_PG_EXPORT_PROD", "TASK2_PG_IMPORT_TRANSIT", "TASK7_PG_EXPORT",
                 "TASK8_PG_EXPORT_TRANSIT", "TASK8_PG_RESTORE_PROD" -> countPgDumpTargets(direction);
            case "TASK3_MONGO_EXPORT_IMPORT", "TASK5_MONGO_IMPORT", "TASK9_MONGO_EXPORT", "TASK9_MONGO_EXPORT_IMPORT" ->
                    mongoDumpConfig.dumpTargets().size();
            case "TASK2_PK_MAPPING", "TASK4_PK_MAPPING", "TASK3_PK_REFRESH", "TASK5_PK_REFRESH" ->
                    countPkTargetTables(direction);
            case "TASK4_FK_REFRESH", "TASK6_FK_REFRESH" ->
                    fkMigrationConfigRepository.findByEnabledTrueOrderByExecutionOrderAsc().size();
            case "TASK6_MONGO_FK_REFRESH", "TASK7_MONGO_FK_REFRESH" ->
                    fkMongoMigrationConfigRepository.findByEnabledTrueOrderByExecutionOrderAscIdAsc().size();
            case "TASK10_FILE_COPY" -> facilityCodes == null ? 0 : facilityCodes.size();
            default -> 0;
        };
    }

    private long countPgDumpTargets(String direction) {
        return pgDumpConfig.tablesFor(direction).size();
    }

    private long countPkTargetTables(String direction) {
        return pgDumpConfig.tablesFor(direction).stream().filter(PgTableConfig::hasIdColumn).count();
    }

    private void logTaskUnitStart(MigrationTask task, String unitType, String unitName, int current, int total) {
        logService.info(task.getJobId(), task.getTaskId(), String.format("[%s] %s開始 (%d/%d): %s", task.getTaskName(), unitType, current, total, unitName));
    }

    private void logTaskUnitDone(MigrationTask task, String unitType, String unitName, int current, int total, long done, long expected) {
        if (expected <= 1) {
            logService.info(task.getJobId(), task.getTaskId(), String.format("[%s] %s完了 (%d/%d): %s", task.getTaskName(), unitType, current, total, unitName));
            return;
        }

        String countText = done + "/" + expected;
        logService.info(task.getJobId(), task.getTaskId(), String.format("[%s] %s完了 (%d/%d): %s [%s]", task.getTaskName(), unitType, current, total, unitName, countText));
    }

    private void logTaskUnitSkip(MigrationTask task, String unitType, String unitName, int current, int total, String reason) {
        logService.info(task.getJobId(), task.getTaskId(), String.format("[%s] %sスキップ (%d/%d): %s%s", task.getTaskName(), unitType, current, total, unitName, (reason == null || reason.isBlank()) ? "" : " - " + reason));
    }

    // -------------------------------------------------------
    // off2on タスク実装
    // -------------------------------------------------------

    /**
     * TASK1: アップロードされた PG ダンプ (.data) を中転 DB へ COPY インポート
     */
    private TaskResult off2on_task1PgImport(MigrationTask task, CreateJobRequest req, List<String> codes, long jobId) throws Exception {
        String uploadId = req.uploadIds().pgDump();
        Path uploadDir = Paths.get(basePath, "uploads", uploadId);
        Path dumpDir = Paths.get(basePath, "jobs", String.valueOf(jobId), "pg_restore");

        Path zipFile = uploadDir.resolve("pg_dump.zip");
        Path srcDir = Files.exists(zipFile) ? archiveService.decompress(zipFile, dumpDir) : uploadDir;

        // ZIP 内のサブフォルダ名 (ntss_db4/ntss_db5/ntss_db6) が接続先 DB を示す。
        // ただし config に定義されたテーブルのみ対象（管理用内部テーブル等はスキップ）。
        List<Path> dbDirs;
        try (var s = Files.list(srcDir).filter(Files::isDirectory)) {
            dbDirs = s.toList();
        }
        log.info("[TASK1_PG_IMPORT] 解凍先: {}, DBサブフォルダ数: {}", srcDir, dbDirs.size());

        // Phase 1: 各テーブルを個別 TRUNCATE CASCADE（未作成テーブルは警告してスキップ）
        for (Path dbSubDir : dbDirs) {
            String dbName = dbSubDir.getFileName().toString();
            List<PgTableConfig> tables = pgDumpConfig.tablesForDb("off2on", dbName);
            log.info("[TASK1_PG_IMPORT] Phase1 TRUNCATE: db={}, テーブル数={}", dbName, tables.size());
            if (tables.isEmpty()) continue;

            JdbcTemplate jdbc = transitJdbcFor(dbName);
            int truncated = 0;
            for (PgTableConfig t : tables) {
                if (!tableExists(jdbc, "ntss", t.getName())) {
                    log.info("[TASK1_PG_IMPORT] TRUNCATEスキップ（テーブル未作成）: db={}, table={}", dbName, t.getName());
                    continue;
                }
                try {
                    jdbc.execute("TRUNCATE TABLE ntss.\"" + t.getName() + "\" CASCADE");
                    truncated++;
                } catch (Exception e) {
                    log.warn("[TASK1_PG_IMPORT] TRUNCATE失敗（スキップ）: db={}, table={}, reason={}", dbName, t.getName(), e.getMessage());
                }
            }
            log.info("[TASK1_PG_IMPORT] TRUNCATE完了: db={}, 成功={}/{}", dbName, truncated, tables.size());
        }

        // Phase 2: COPY FROM (.data) で各テーブルにデータ投入（FK 依存順）
        long total = 0;
        int totalCopyTables = dbDirs.stream().mapToInt(dbSubDir -> pgDumpConfig.tablesForDb("off2on", dbSubDir.getFileName().toString()).size()).sum();
        int copyIndex = 0;
        for (Path dbSubDir : dbDirs) {
            String dbName = dbSubDir.getFileName().toString();
            List<PgTableConfig> tables = pgDumpConfig.tablesForDb("off2on", dbName);
            log.info("[TASK1_PG_IMPORT] Phase2 COPY: db={}, config対象テーブル数={}", dbName, tables.size());

            // FK 親テーブルを先にインポートするためトポロジカルソート
            JdbcTemplate jdbcForSort = transitJdbcFor(dbName);
            tables = sortByFkDependency(tables, jdbcForSort);

            DbConnectionInfo connInfo = transitConnInfoFor(dbName);
            for (PgTableConfig cfg : tables) {
                copyIndex++;
                logTaskUnitStart(task, "テーブル", dbName + "/" + cfg.getName(), copyIndex, totalCopyTables);
                log.info("[TASK1_PG_IMPORT] COPY開始: db={}, table={}", dbName, cfg.getName());
                DumpResult r = pgDumpService.restoreFromCopy(cfg.getName(), dbSubDir, connInfo);
                if (!r.success())
                    return TaskResult.fail(task.getTaskId(), task.getTaskName(), "COPY 失敗: " + cfg.getName() + " / " + r.errorOutput());
                total += r.rows();
                log.info("[TASK1_PG_IMPORT] COPY完了: db={}, table={}", dbName, cfg.getName());
                logTaskUnitDone(task, "テーブル", dbName + "/" + cfg.getName(), copyIndex, totalCopyTables, r.rows(), 1);
            }
            log.info("[TASK1_PG_IMPORT] DB={} Phase2 完了", dbName);
        }
        return TaskResult.ok(task.getTaskId(), task.getTaskName(), total);
    }

    /**
     * TASK2 (off2on): 中転 DB の旧 PK → 在線生産 SEQ で新 PK を割り当て pk_mapping 生成
     */
    private TaskResult off2on_task2PkMapping(MigrationTask task, List<String> codes, long jobId) throws Exception {
        // リトライ時の重複を防ぐため既存マッピングを全削除してからインサート
        pkMappingService.deleteByJobId(jobId);
        log.info("[TASK2_PK_MAPPING] 既存マッピング削除完了: jobId={}", jobId);

        long total = 0;
        // sharedPkTable なし（独自シーケンス）を先に処理し、sharedPkTable あり（親依存）を後に処理
        List<PgTableConfig> pkTables = pgDumpConfig.tablesFor("off2on").stream().filter(PgTableConfig::hasIdColumn).sorted(Comparator.comparingInt(t -> (t.getSharedPkTable() != null && !t.getSharedPkTable().isBlank()) ? 1 : 0)).toList();
        log.info("[TASK2_PK_MAPPING] PK対象テーブル数: {}", pkTables.size());

        int pkIndex = 0;
        for (PgTableConfig cfg : pkTables) {
            pkIndex++;
            logTaskUnitStart(task, "PKテーブル", cfg.getName(), pkIndex, pkTables.size());
            log.info("[TASK2_PK_MAPPING] 開始: table={}, idColumn={}, db={}, sharedPkTable={}", cfg.getName(), cfg.getIdColumn(), cfg.getDb(), cfg.getSharedPkTable());
            JdbcTemplate jdbc = transitJdbcFor(cfg.getDb());
            List<Long> oldIds;
            try {
                oldIds = jdbc.queryForList("SELECT DISTINCT \"" + cfg.getIdColumn() + "\" FROM ntss.\"" + cfg.getName() + "\" ORDER BY \"" + cfg.getIdColumn() + "\"", Long.class);
            } catch (Exception e) {
                log.warn("[TASK2_PK_MAPPING] テーブル不存在またはクエリ失敗（スキップ）: table={}, reason={}", cfg.getName(), e.getMessage());
                continue;
            }
            log.info("[TASK2_PK_MAPPING] 中転DB旧ID取得: table={}, count={}", cfg.getName(), oldIds.size());

            // pkGroupTables が設定されている場合、追加テーブルの ID も合算する
            if (cfg.getPkGroupTables() != null && !cfg.getPkGroupTables().isEmpty()) {
                Set<Long> combined = new HashSet<>(oldIds);
                for (String groupTable : cfg.getPkGroupTables()) {
                    PgTableConfig groupCfg = pgDumpConfig.getTables().stream().filter(t -> groupTable.equals(t.getName())).findFirst().orElse(cfg);
                    String groupIdColumn = effectiveIdColumn(groupCfg, cfg);
                    try {
                        List<Long> groupIds = jdbc.queryForList("SELECT DISTINCT \"" + groupIdColumn + "\" FROM ntss.\"" + groupTable + "\" ORDER BY \"" + groupIdColumn + "\"", Long.class);
                        combined.addAll(groupIds);
                        log.info("[TASK2_PK_MAPPING] グループテーブルID追加: groupTable={}, count={}", groupTable, groupIds.size());
                    } catch (Exception e) {
                        log.warn("[TASK2_PK_MAPPING] グループテーブル取得失敗（スキップ）: groupTable={}, reason={}", groupTable, e.getMessage());
                    }
                }
                oldIds = combined.stream().sorted().collect(Collectors.toList());
                log.info("[TASK2_PK_MAPPING] 合計ID数（グループ込み）: table={}, count={}", cfg.getName(), oldIds.size());
            }

            if (oldIds.isEmpty()) {
                log.info("[TASK2_PK_MAPPING] データなし、スキップ: table={}", cfg.getName());
                continue;
            }

            if (cfg.getSharedPkTable() != null && !cfg.getSharedPkTable().isBlank()) {
                // 親テーブルのマッピングを流用（独自シーケンスなし）
                log.info("[TASK2_PK_MAPPING] 共有PK: table={}, 親テーブル={} のマッピング流用", cfg.getName(), cfg.getSharedPkTable());
                Map<Long, Long> parentMapping = pkMappingService.findMappings(cfg.getSharedPkTable(), oldIds);
                List<Long> filteredOldIds = new ArrayList<>();
                List<Long> resolvedNewIds = new ArrayList<>();
                for (Long id : oldIds) {
                    Long newId = parentMapping.get(id);
                    if (newId == null) {
                        log.warn("[TASK2_PK_MAPPING] 親マッピング未登録のためスキップ: table={}, parentTable={}, id={}", cfg.getName(), cfg.getSharedPkTable(), id);
                    } else {
                        filteredOldIds.add(id);
                        resolvedNewIds.add(newId);
                    }
                }
                oldIds = filteredOldIds;
                if (oldIds.isEmpty()) {
                    log.info("[TASK2_PK_MAPPING] マッピング対象なし、スキップ: table={}", cfg.getName());
                    continue;
                }
                log.info("[TASK2_PK_MAPPING] PKマッピング登録: table={}, oldMin={}, newMin={}", cfg.getName(), oldIds.get(0), resolvedNewIds.get(0));
                pkMappingService.insertBatch(cfg.getName(), oldIds, resolvedNewIds, jobId);
            } else {
                log.info("[TASK2_PK_MAPPING] 在線SEQから新ID取得: table={}, count={}", cfg.getName(), oldIds.size());
                long firstNewId = -1L;
                for (int start = 0; start < oldIds.size(); start += PK_REFRESH_BATCH_SIZE) {
                    int end = Math.min(start + PK_REFRESH_BATCH_SIZE, oldIds.size());
                    List<Long> oldIdBatch = oldIds.subList(start, end);
                    List<Long> newIdBatch = seqBatchService.fetchNextIds(cfg, oldIdBatch.size());
                    if (firstNewId < 0 && !newIdBatch.isEmpty()) {
                        firstNewId = newIdBatch.get(0);
                    }
                    pkMappingService.insertBatch(cfg.getName(), oldIdBatch, newIdBatch, jobId);
                }
                log.info("[TASK2_PK_MAPPING] PKマッピング登録: table={}, oldMin={}, newMin={}", cfg.getName(), oldIds.get(0), firstNewId);
            }

            total += oldIds.size();
            log.info("[TASK2_PK_MAPPING] 完了: table={}, count={}", cfg.getName(), oldIds.size());
            logTaskUnitDone(task, "PKテーブル", cfg.getName(), pkIndex, pkTables.size(), oldIds.size(), oldIds.size());
        }
        return TaskResult.ok(task.getTaskId(), task.getTaskName(), total);
    }

    /**
     * TASK7 (off2on): 中転 DB から psql COPY エクスポート（DB 別サブフォルダ）
     */
    private TaskResult off2on_task7PgExport(MigrationTask task, List<String> codes, long jobId) throws Exception {
        Path exportDir = Paths.get(basePath, "jobs", String.valueOf(jobId), "pg_export");
        long total = 0;
        int totalExportTables = MIGRATION_DBS.stream().mapToInt(dbName -> pgDumpConfig.tablesForDb("off2on", dbName).size()).sum();
        int exportIndex = 0;
        for (String dbName : MIGRATION_DBS) {
            DbConnectionInfo connInfo = transitConnInfoFor(dbName);
            Path dbSubDir = exportDir.resolve(dbName);
            for (PgTableConfig cfg : pgDumpConfig.tablesForDb("off2on", dbName)) {
                exportIndex++;
                logTaskUnitStart(task, "テーブル", dbName + "/" + cfg.getName(), exportIndex, totalExportTables);
                DumpResult r = pgDumpService.dumpToCopy(cfg, codes, dbSubDir, connInfo);
                if (!r.success())
                    return TaskResult.fail(task.getTaskId(), task.getTaskName(), "COPY TO 失敗: " + cfg.getName() + " / " + r.errorOutput());
                total += r.rows();
                logTaskUnitDone(task, "テーブル", dbName + "/" + cfg.getName(), exportIndex, totalExportTables, r.rows(), 1);
            }
        }
        return TaskResult.ok(task.getTaskId(), task.getTaskName(), total);
    }

    /**
     * TASK8 (off2on): 在線生産 RDS へ psql COPY インポート
     */
    private TaskResult off2on_task8PgRestoreProd(MigrationTask task, List<String> codes, long jobId) throws Exception {
        Path exportDir = Paths.get(basePath, "jobs", String.valueOf(jobId), "pg_export");

        // CRITICAL チェック: whereTemplate=null のテーブルは TRUNCATE 禁止
        for (String dbName : MIGRATION_DBS) {
            for (PgTableConfig cfg : pgDumpConfig.tablesForDb("off2on", dbName)) {
                if (cfg.getWhereTemplate() == null) {
                    log.error("[TASK8_PG_RESTORE] ★★★ CRITICAL: whereTemplate=null のテーブルを検出しました。" + " TRUNCATE は実行しません。pg_dump_config.yaml を確認してください。" + " table={}, db={}", cfg.getName(), dbName);
                }
            }
        }

        // Phase3a: 全テーブルを facility_cd DELETE（逆順で子テーブルから先に削除して FK 違反を回避）
        String placeholders = codes.stream().map(c -> "?").collect(java.util.stream.Collectors.joining(","));
        Object[] codeParams = codes.toArray();

        // MIGRATION_DBS も逆順（ntss_db6 → ntss_db5）でクロス DB FK を考慮
        List<String> reversedDbs = new java.util.ArrayList<>(MIGRATION_DBS);
        java.util.Collections.reverse(reversedDbs);

        // Phase3a 総テーブル数を事前カウント
        int totalDeleteTables = reversedDbs.stream().mapToInt(db -> pgDumpConfig.allTablesWithTemplateForDb("off2on", db).size()).sum();
        int deleteIdx = 0;
        log.info("[TASK8_PG_RESTORE] Phase3a 開始: totalTables={}, codes={}", totalDeleteTables, codes);

        for (String dbName : reversedDbs) {
            JdbcTemplate jdbc = onlineJdbcFor(dbName);
            // dump: false のテーブルも含む全テーブル（whereTemplate あり）を逆順で DELETE
            List<PgTableConfig> tables = pgDumpConfig.allTablesWithTemplateForDb("off2on", dbName);
            List<PgTableConfig> reversedTables = new java.util.ArrayList<>(tables);
            java.util.Collections.reverse(reversedTables);
            for (PgTableConfig cfg : reversedTables) {
                deleteIdx++;
                try {
                    int deleted = jdbc.update("DELETE FROM ntss.\"" + cfg.getName() + "\" WHERE facility_cd IN (" + placeholders + ")", codeParams);
                    log.info("[TASK8_PG_RESTORE] [{}/{}] DELETE: table={}, deleted={}", deleteIdx, totalDeleteTables, cfg.getName(), deleted);
                } catch (org.springframework.jdbc.BadSqlGrammarException e) {
                    log.debug("[TASK8_PG_RESTORE] [{}/{}] DELETE スキップ（テーブル不存在）: table={}", deleteIdx, totalDeleteTables, cfg.getName());
                }
            }
        }

        // Phase3b: 全テーブルを COPY FROM（順方向で親テーブルから挿入して FK 制約を満たす）
        // 重複行は ON CONFLICT DO NOTHING でスキップ（restoreFromCopy が temp table 方式を使用）
        int totalCopyTables = MIGRATION_DBS.stream().mapToInt(db -> pgDumpConfig.tablesForDb("off2on", db).size()).sum();
        int copyIdx = 0;
        log.info("[TASK8_PG_RESTORE] Phase3b 開始: totalTables={}", totalCopyTables);

        long total = 0;
        for (String dbName : MIGRATION_DBS) {
            DbConnectionInfo connInfo = onlineConnInfoFor(dbName);
            Path dbSubDir = exportDir.resolve(dbName);
            for (PgTableConfig cfg : pgDumpConfig.tablesForDb("off2on", dbName)) {
                copyIdx++;
                log.info("[TASK8_PG_RESTORE] [{}/{}] COPY FROM 開始: table={}, db={}", copyIdx, totalCopyTables, cfg.getName(), dbName);
                DumpResult r = pgDumpService.restoreFromCopy(cfg.getName(), dbSubDir, connInfo);
                if (!r.success())
                    return TaskResult.fail(task.getTaskId(), task.getTaskName(), "COPY FROM(prod) 失敗: " + cfg.getName() + " / " + r.errorOutput());
                total += r.rows();
                log.info("[TASK8_PG_RESTORE] [{}/{}] 完了: table={}", copyIdx, totalCopyTables, cfg.getName());
            }
        }
        return TaskResult.ok(task.getTaskId(), task.getTaskName(), total);
    }

    /**
     * TASK5 (off2on): アップロードされた Mongo BSON ZIP を中転 Mongo へリストア
     */
    private TaskResult off2on_task5MongoImport(MigrationTask task, CreateJobRequest req, List<String> codes, long jobId) throws Exception {
        String uploadId = req.uploadIds().mongoDump();
        Path uploadDir = Paths.get(basePath, "uploads", uploadId);
        MongoConnectionInfo conn = MongoConnectionInfo.fromUri(transitMongoUri);
        MongoDatabase db = transitMongoClient.getDatabase(conn.database());

        transitMongoClearService.clearFacilityData(codes, db);

        // ZIP を解凍してから BSON ファイルを取得
        // クライアントは mongo_dump.zip (mongodump BSON) をアップロードする
        // ZIP 構造: {db}/{collection}.bson（mongodump 形式）
        Path mongoZip = uploadDir.resolve("mongo_dump.zip");
        Path extractDir = Paths.get(basePath, "jobs", String.valueOf(jobId), "mongo_extract");
        if (Files.exists(mongoZip)) {
            log.info("[TASK5_MONGO_IMPORT] ZIP 解凍: {} → {}", mongoZip, extractDir);
            archiveService.decompress(mongoZip, extractDir);
        } else {
            extractDir = uploadDir;
            log.warn("[TASK5_MONGO_IMPORT] mongo_dump.zip が存在しません、直接参照: {}", uploadDir);
        }

        // BSON ファイルは {extractDir}/{db}/{col}.bson に解凍される
        Path bsonDir = extractDir.resolve(conn.database());
        long total = 0;
        List<MongoCollectionConfig> mongoTargets = mongoDumpConfig.dumpTargets();
        int mongoIndex = 0;
        for (MongoCollectionConfig cfg : mongoTargets) {
            mongoIndex++;
            logTaskUnitStart(task, "コレクション", cfg.getName(), mongoIndex, mongoTargets.size());
            Path bsonFile = bsonDir.resolve(cfg.getName() + ".bson");
            if (!Files.exists(bsonFile)) {
                log.warn("[TASK5_MONGO_IMPORT] BSON ファイル未存在（スキップ）: {}", bsonFile);
                logTaskUnitSkip(task, "コレクション", cfg.getName(), mongoIndex, mongoTargets.size(), "BSON未存在");
                continue;
            }
            StreamResult r = mongoMigrationService.restoreCollection(cfg.getName(), bsonFile, conn, true);
            if (!r.success())
                return TaskResult.fail(task.getTaskId(), task.getTaskName(), "mongorestore 失敗: " + cfg.getName() + " / " + r.errorOutput());
            total += r.rows();
            logTaskUnitDone(task, "コレクション", cfg.getName(), mongoIndex, mongoTargets.size(), r.rows(), 1);
        }
        return TaskResult.ok(task.getTaskId(), task.getTaskName(), total);
    }

    // -------------------------------------------------------
    // on2off タスク実装
    // -------------------------------------------------------

    /**
     * TASK1 (on2off): 在線生産 RDS から psql COPY エクスポート（DB 別サブフォルダ）
     */
    private TaskResult on2off_task1PgExportProd(MigrationTask task, List<String> codes, long jobId) throws Exception {
        transitPgClearService.clearFacilityData(codes);
        Path rawDir = Paths.get(basePath, "jobs", String.valueOf(jobId), "pg_raw");
        long total = 0;
        int totalExportTables = MIGRATION_DBS.stream().mapToInt(dbName -> pgDumpConfig.tablesForDb("on2off", dbName).size()).sum();
        int exportIndex = 0;
        for (String dbName : MIGRATION_DBS) {
            DbConnectionInfo connInfo = onlineConnInfoFor(dbName);
            Path dbSubDir = rawDir.resolve(dbName);
            for (PgTableConfig cfg : pgDumpConfig.tablesForDb("on2off", dbName)) {
                exportIndex++;
                logTaskUnitStart(task, "テーブル", dbName + "/" + cfg.getName(), exportIndex, totalExportTables);
                DumpResult r = pgDumpService.dumpToCopy(cfg, codes, dbSubDir, connInfo);
                if (!r.success())
                    return TaskResult.fail(task.getTaskId(), task.getTaskName(), "COPY TO(prod) 失敗: " + cfg.getName() + " / " + r.errorOutput());
                total += r.rows();
                logTaskUnitDone(task, "テーブル", dbName + "/" + cfg.getName(), exportIndex, totalExportTables, r.rows(), 1);
            }
        }
        return TaskResult.ok(task.getTaskId(), task.getTaskName(), total);
    }

    /**
     * TASK2 (on2off): 中転 DB へ psql COPY インポート（DB 別サブフォルダから）
     */
    private TaskResult on2off_task2PgImportTransit(MigrationTask task, long jobId) throws Exception {
        Path rawDir = Paths.get(basePath, "jobs", String.valueOf(jobId), "pg_raw");

        // Phase 1: COPY 前に各テーブルを個別 TRUNCATE（重複防止）
        for (String dbName : MIGRATION_DBS) {
            JdbcTemplate jdbc = transitJdbcFor(dbName);
            List<PgTableConfig> tables = pgDumpConfig.tablesForDb("on2off", dbName);
            log.info("[TASK2_PG_IMPORT_TRANSIT] Phase1 TRUNCATE: db={}, テーブル数={}", dbName, tables.size());
            for (PgTableConfig cfg : tables) {
                if (!tableExists(jdbc, "ntss", cfg.getName())) {
                    log.info("[TASK2_PG_IMPORT_TRANSIT] TRUNCATEスキップ（テーブル未作成）: db={}, table={}", dbName, cfg.getName());
                    continue;
                }
                try {
                    jdbc.execute("TRUNCATE TABLE ntss.\"" + cfg.getName() + "\" CASCADE");
                } catch (Exception e) {
                    log.warn("[TASK2_PG_IMPORT_TRANSIT] TRUNCATE失敗（スキップ）: db={}, table={}, reason={}", dbName, cfg.getName(), e.getMessage());
                }
            }
        }

        // Phase 2: COPY FROM（FK 依存順）
        long total = 0;
        int totalImportTables = MIGRATION_DBS.stream().mapToInt(dbName -> pgDumpConfig.tablesForDb("on2off", dbName).size()).sum();
        int importIndex = 0;
        for (String dbName : MIGRATION_DBS) {
            DbConnectionInfo connInfo = transitConnInfoFor(dbName);
            Path dbSubDir = rawDir.resolve(dbName);
            List<PgTableConfig> tables2 = sortByFkDependency(pgDumpConfig.tablesForDb("on2off", dbName), transitJdbcFor(dbName));
            for (PgTableConfig cfg : tables2) {
                importIndex++;
                logTaskUnitStart(task, "テーブル", dbName + "/" + cfg.getName(), importIndex, totalImportTables);
                DumpResult r = pgDumpService.restoreFromCopy(cfg.getName(), dbSubDir, connInfo);
                if (!r.success())
                    return TaskResult.fail(task.getTaskId(), task.getTaskName(), "COPY FROM(transit) 失敗: " + cfg.getName() + " / " + r.errorOutput());
                total += r.rows();
                logTaskUnitDone(task, "テーブル", dbName + "/" + cfg.getName(), importIndex, totalImportTables, r.rows(), 1);
            }
        }
        return TaskResult.ok(task.getTaskId(), task.getTaskName(), total);
    }

    /**
     * TASK4 (on2off): seqStartMap を使い pk_mapping を生成
     */
    private TaskResult on2off_task4PkMapping(MigrationTask task, CreateJobRequest req, List<String> codes, long jobId) throws Exception {
        pkMappingService.deleteByJobId(jobId);
        log.info("[TASK4_PK_MAPPING] 既存マッピング削除完了: jobId={}", jobId);

        List<PgTableConfig> pkTables = pgDumpConfig.tablesFor("on2off").stream().filter(PgTableConfig::hasIdColumn).filter(cfg -> MIGRATION_DBS.contains(cfg.getDb())).sorted(Comparator.comparingInt(t -> (t.getSharedPkTable() != null && !t.getSharedPkTable().isBlank()) ? 1 : 0)).toList();
        log.info("[TASK4_PK_MAPPING] PK対象テーブル数: {}", pkTables.size());

        long total = 0;
        int pkIndex = 0;
        for (PgTableConfig cfg : pkTables) {
            pkIndex++;
            logTaskUnitStart(task, "PKテーブル", cfg.getName(), pkIndex, pkTables.size());
            log.info("[TASK4_PK_MAPPING] 開始: table={}, idColumn={}, db={}, sharedPkTable={}", cfg.getName(), cfg.getIdColumn(), cfg.getDb(), cfg.getSharedPkTable());
            JdbcTemplate jdbc = transitJdbcFor(cfg.getDb());
            List<Long> oldIds;
            try {
                oldIds = jdbc.queryForList("SELECT DISTINCT \"" + cfg.getIdColumn() + "\" FROM ntss.\"" + cfg.getName() + "\" ORDER BY \"" + cfg.getIdColumn() + "\"", Long.class);
            } catch (Exception e) {
                log.warn("[TASK4_PK_MAPPING] テーブル不存在またはクエリ失敗（スキップ）: table={}, reason={}", cfg.getName(), e.getMessage());
                continue;
            }

            if (cfg.getPkGroupTables() != null && !cfg.getPkGroupTables().isEmpty()) {
                Set<Long> combined = new HashSet<>(oldIds);
                for (String groupTable : cfg.getPkGroupTables()) {
                    PgTableConfig groupCfg = pgDumpConfig.getTables().stream().filter(t -> groupTable.equals(t.getName())).findFirst().orElse(cfg);
                    String groupIdColumn = effectiveIdColumn(groupCfg, cfg);
                    try {
                        List<Long> groupIds = jdbc.queryForList("SELECT DISTINCT \"" + groupIdColumn + "\" FROM ntss.\"" + groupTable + "\" ORDER BY \"" + groupIdColumn + "\"", Long.class);
                        combined.addAll(groupIds);
                        log.info("[TASK4_PK_MAPPING] グループテーブルID追加: groupTable={}, count={}", groupTable, groupIds.size());
                    } catch (Exception e) {
                        log.warn("[TASK4_PK_MAPPING] グループテーブル取得失敗（スキップ）: groupTable={}, reason={}", groupTable, e.getMessage());
                    }
                }
                oldIds = combined.stream().sorted().collect(Collectors.toList());
                log.info("[TASK4_PK_MAPPING] 合計ID数（グループ込み）: table={}, count={}", cfg.getName(), oldIds.size());
            }

            if (oldIds.isEmpty()) {
                log.info("[TASK4_PK_MAPPING] データなし、スキップ: table={}", cfg.getName());
                continue;
            }

            if (cfg.getSharedPkTable() != null && !cfg.getSharedPkTable().isBlank()) {
                log.info("[TASK4_PK_MAPPING] 共有PK: table={}, 親テーブル={} のマッピング流用", cfg.getName(), cfg.getSharedPkTable());
                Map<Long, Long> parentMapping = pkMappingService.findMappings(cfg.getSharedPkTable(), oldIds);
                if (parentMapping.isEmpty()) {
                    log.warn("[TASK4_PK_MAPPING] 親マッピングが空のためスキップ: table={}, sharedPkTable={}", cfg.getName(), cfg.getSharedPkTable());
                    continue;
                }
                List<Long> newIds = oldIds.stream().map(id -> {
                    Long newId = parentMapping.get(id);
                    if (newId == null)
                        throw new IllegalStateException("親マッピングに旧ID未登録: table=" + cfg.getSharedPkTable() + ", id=" + id);
                    return newId;
                }).toList();
                pkMappingService.insertBatch(cfg.getName(), oldIds, newIds, jobId);
            } else {
                if (req.seqStartMap() == null || !req.seqStartMap().containsKey(cfg.getName())) {
                    throw new IllegalStateException("seqStartMap に必要テーブルが存在しません: " + cfg.getName());
                }

                Long startSeq = req.seqStartMap().get(cfg.getName());
                if (startSeq == null || startSeq < 1) {
                    throw new IllegalStateException("seqStartMap の開始値が不正です: table=" + cfg.getName() + ", startSeq=" + startSeq);
                }

                log.info("[TASK4_PK_MAPPING] generateFromStartSeq: table={}, startSeq={}", cfg.getName(), startSeq);
                pkMappingService.generateFromStartSeq(cfg.getName(), oldIds, startSeq, jobId);
            }
            total += oldIds.size();
            logTaskUnitDone(task, "PKテーブル", cfg.getName(), pkIndex, pkTables.size(), oldIds.size(), oldIds.size());
        }
        return TaskResult.ok(task.getTaskId(), task.getTaskName(), total);
    }

    /**
     * TASK8 (on2off): 中転 DB → COPY エクスポート → ZIP（クライアントダウンロード用）
     */
    private TaskResult on2off_task8PgExportTransit(MigrationTask task, List<String> codes, long jobId) throws Exception {
        Path exportDir = Paths.get(basePath, "jobs", String.valueOf(jobId), "output", "pg");
        long total = 0;
        int totalExportTables = MIGRATION_DBS.stream().mapToInt(dbName -> pgDumpConfig.tablesForDb("on2off", dbName).size()).sum();
        int exportIndex = 0;
        for (String dbName : MIGRATION_DBS) {
            DbConnectionInfo connInfo = transitConnInfoFor(dbName);
            Path dbSubDir = exportDir.resolve(dbName);
            for (PgTableConfig cfg : pgDumpConfig.tablesForDb("on2off", dbName)) {
                exportIndex++;
                logTaskUnitStart(task, "テーブル", dbName + "/" + cfg.getName(), exportIndex, totalExportTables);
                DumpResult r = pgDumpService.dumpToCopy(cfg, codes, dbSubDir, connInfo);
                if (!r.success())
                    return TaskResult.fail(task.getTaskId(), task.getTaskName(), "pg_dump(transit COPY) 失敗: " + cfg.getName() + " / " + r.errorOutput());
                total += r.rows();
                logTaskUnitDone(task, "テーブル", dbName + "/" + cfg.getName(), exportIndex, totalExportTables, r.rows(), 1);
            }
        }
        Path zipPath = Paths.get(basePath, "jobs", String.valueOf(jobId), "output", "pg_dump_job" + jobId + ".zip");
        archiveService.compress(exportDir, zipPath);
        return TaskResult.ok(task.getTaskId(), task.getTaskName(), total);
    }

    /**
     * TASK9 (on2off): 中転 Mongo → mongodump (BSON) → ZIP
     */
    private TaskResult on2off_task9MongoExport(MigrationTask task, List<String> codes, long jobId) throws Exception {
        // mongodump の --out ディレクトリ: 自動で {dumpRoot}/{db}/{col}.bson を生成する
        Path dumpRoot = Paths.get(basePath, "jobs", String.valueOf(jobId), "output", "mongo");
        MongoConnectionInfo conn = MongoConnectionInfo.fromUri(transitMongoUri);
        long total = 0;
        List<MongoCollectionConfig> mongoTargets = mongoDumpConfig.dumpTargets();
        int mongoIndex = 0;
        for (MongoCollectionConfig cfg : mongoTargets) {
            mongoIndex++;
            logTaskUnitStart(task, "コレクション", cfg.getName(), mongoIndex, mongoTargets.size());
            StreamResult r = mongoMigrationService.dump(cfg, codes, dumpRoot, conn, MongoToolProfile.DEFAULT);
            if (!r.success())
                return TaskResult.fail(task.getTaskId(), task.getTaskName(), "mongodump 失敗: " + cfg.getName() + " / " + r.errorOutput());
            total += r.rows();
            logTaskUnitDone(task, "コレクション", cfg.getName(), mongoIndex, mongoTargets.size(), r.rows(), 1);
        }
        // ZIP: dumpRoot/{db}/{col}.bson 構造ごと圧縮
        Path zipPath = Paths.get(basePath, "jobs", String.valueOf(jobId), "output", "mongo_dump_job" + jobId + ".zip");
        archiveService.compress(dumpRoot, zipPath);
        return TaskResult.ok(task.getTaskId(), task.getTaskName(), total);
    }

    // -------------------------------------------------------
    // 共通タスク実装
    // -------------------------------------------------------

    /**
     * PK 刷新（中転 DB の PK 値を pk_mapping に従い更新）
     */
    private TaskResult pkRefresh(MigrationTask task, MigrationJob job) {
        log.info("[TASK3_PK_REFRESH] : CopyPkMappingToLocal tasks start.");
        java.util.concurrent.CompletableFuture<Integer> f4 =
            java.util.concurrent.CompletableFuture.supplyAsync(()->{
                copyPkMappingToLocal(transitJdbc1, task.getTaskName(), job);
                return 0;
            },threadPoolTaskExecutor).exceptionally(ex -> {
                log.info("[TASK3_PK_REFRESH] : copyPkMappingToLocal for DB4 ERROR:", ex);
                return -1;
            });
        java.util.concurrent.CompletableFuture<Integer> f5 =
            java.util.concurrent.CompletableFuture.supplyAsync(()->{
                copyPkMappingToLocal(transitJdbc2, task.getTaskName(), job);
                return 0;
            },threadPoolTaskExecutor).exceptionally(ex -> {
                log.info("[TASK3_PK_REFRESH] : copyPkMappingToLocal for DB5 ERROR:", ex);
                return -1;
            });
        java.util.concurrent.CompletableFuture<Integer> f6 =
            java.util.concurrent.CompletableFuture.supplyAsync(()->{
                copyPkMappingToLocal(transitJdbc3, task.getTaskName(), job);
                return 0;
            },threadPoolTaskExecutor).exceptionally(ex -> {
                log.info("[TASK3_PK_REFRESH] : copyPkMappingToLocal for DB6 ERROR:", ex);
                return -1;
            });
        java.util.concurrent.CompletableFuture<Void> completableFuture = java.util.concurrent.CompletableFuture.allOf(f4, f5, f6);
        completableFuture.join();
        log.info("[TASK3_PK_REFRESH] : All copyPkMappingToLocal tasks finished.");


        List<Future<Integer>> futures = new ArrayList<>();
        String dir = job.getDirection();
        List<PgTableConfig> pkTables = pgDumpConfig.tablesFor(dir).stream().filter(PgTableConfig::hasIdColumn).toList();
        log.info("[TASK3_PK_REFRESH] 開始: 対象テーブル数={}", pkTables.size());
        AtomicLong total = new AtomicLong(0);
        int index = 0;
        for (PgTableConfig cfg : pkTables) {
            index++;
            int finalIndex = index;
            Future<Integer> future = threadPoolTaskExecutor.submit(() -> {
                logTaskUnitStart(task, "PK更新", cfg.getName(), total.intValue(), pkTables.size());
                JdbcTemplate jdbc = transitJdbcFor(cfg.getDb());
                int updated = 0;
                try {
                    String sql = String.format("""
                        WITH updated_rows AS (
                            SELECT
                                t.ctid,
                                pm.new_id
                            FROM ntss."%s" t
                            INNER JOIN ntss.pk_mapping_local pm
                                    ON pm.table_name = '%s'
                                   AND pm.old_id = t."%s"
                            WHERE t."%s" IS DISTINCT FROM pm.new_id
                        )
                        UPDATE ntss."%s" t
                           SET "%s" = ur.new_id
                          FROM updated_rows ur
                         WHERE t.ctid = ur.ctid
                        """, cfg.getName(), cfg.getName(), cfg.getIdColumn(), cfg.getIdColumn(), cfg.getName(), cfg.getIdColumn());
                    updated = jdbc.update(sql);
                    if (updated == 0) {
                        log.info("[TASK3_PK_REFRESH] スキップ（更新なし）: table={}, idColumn={}", cfg.getName(), cfg.getIdColumn());
                        logTaskUnitSkip(task, "PK更新", cfg.getName(), finalIndex, pkTables.size(), "更新なし");
                    } else {
                        log.info("[TASK3_PK_REFRESH] 完了: table={}, updated={}", cfg.getName(), updated);
                        logTaskUnitDone(task, "PK更新", cfg.getName(), finalIndex, pkTables.size(), updated, updated);
                    }
                } catch (Exception e) {
                    log.warn("[TASK3_PK_REFRESH] スキップ（エラー）: table={}, reason={}", cfg.getName(), e.getMessage());
                    logTaskUnitSkip(task, "PK更新", cfg.getName(), finalIndex, pkTables.size(), e.getMessage());
                }
                return updated;
            });
            futures.add(future);
        }

        for (Future<Integer> future : futures) {
            try {
                total.addAndGet(future.get());
            } catch (Exception e) {
                log.error("Refresh mapping task error", e);
            }
        }
        
        log.info("[TASK3_PK_REFRESH] 全テーブル完了: totalRows={}", total.get());
        return TaskResult.ok(task.getTaskId(), task.getTaskName(), total.get());
    }

    /**
     * FK 刷新（中転 DB の FK カラムを pk_mapping に従い更新）
     */
    private TaskResult fkRefresh(MigrationTask task, MigrationJob job, List<String> codes, long jobId) throws Exception {
        long updated = 0;
        String direction = job.getDirection();
        updated += fkRefreshService.refreshAll(transitJdbc1, codes, jobId, task.getTaskName(), direction, "ntss_db4", "db4");
        updated += fkRefreshService.refreshAll(transitJdbc2, codes, jobId, task.getTaskName(), direction, "ntss_db5", "db5");
        updated += fkRefreshService.refreshAll(transitJdbc3, codes, jobId, task.getTaskName(), direction, "ntss_db6", "db6");
        return TaskResult.ok(task.getTaskId(), task.getTaskName(), updated);
    }

    /**
     * Mongo FK 刷新
     */
    private TaskResult mongoFkRefresh(MigrationTask task, long jobId, MongoClient client, String uri) throws Exception {
        MongoDatabase db = client.getDatabase(MongoConnectionInfo.fromUri(uri).database());
        long updated = mongoFkRefreshService.refreshAll(db, jobId);
        return TaskResult.ok(task.getTaskId(), task.getTaskName(), updated);
    }

    /**
     * Mongo dump & restore（src → dst）BSON 形式
     */
    private TaskResult mongoExportImport(MigrationTask task, List<String> codes, long jobId, String srcUri, String dstUri, boolean onlineDestination) throws Exception {
        Path tmpDir = Paths.get(basePath, "jobs", String.valueOf(jobId), "mongo_tmp_" + task.getTaskId());
        MongoConnectionInfo srcConn = MongoConnectionInfo.fromUri(srcUri);
        MongoConnectionInfo dstConn = MongoConnectionInfo.fromUri(dstUri);
        List<MongoCollectionConfig> mongoTargets = mongoDumpConfig.dumpTargets();
        MongoToolProfile dumpToolProfile = onlineDestination ? MongoToolProfile.DEFAULT : onlineMongoAccessService.mongoToolProfile();
        MongoToolProfile restoreToolProfile = onlineDestination ? onlineMongoAccessService.mongoToolProfile() : MongoToolProfile.DEFAULT;

        // Step1: 全コレクションを先に dump（clear 前に実行してデータロストを防ぐ）
        int dumpIndex = 0;
        for (MongoCollectionConfig cfg : mongoTargets) {
            dumpIndex++;
            logTaskUnitStart(task, "コレクション", cfg.getName(), dumpIndex, mongoTargets.size());
            StreamResult dumpResult = mongoMigrationService.dump(cfg, codes, tmpDir, srcConn, dumpToolProfile);
            if (!dumpResult.success())
                return TaskResult.fail(task.getTaskId(), task.getTaskName(), "mongodump 失敗: " + cfg.getName() + " / " + dumpResult.errorOutput());
            logTaskUnitDone(task, "コレクション", cfg.getName(), dumpIndex, mongoTargets.size(), dumpResult.rows(), 1);
        }

        // Step2: dst の施設データをクリア（dump 完了後）
        if (onlineDestination) {
            onlineMongoAccessService.clearFacilityData(codes);
        } else {
            MongoDatabase dstDb = transitMongoClient.getDatabase(dstConn.database());
            transitMongoClearService.clearFacilityData(codes, dstDb);
        }

        // Step3: restore（--drop なし → 他施設データを保持したまま NKKSBR 分を追記）
        long total = 0;
        int restoreIndex = 0;
        for (MongoCollectionConfig cfg : mongoTargets) {
            restoreIndex++;
            logTaskUnitStart(task, "コレクション", cfg.getName(), restoreIndex, mongoTargets.size());
            Path bsonFile = tmpDir.resolve(srcConn.database()).resolve(cfg.getName() + ".bson");
            StreamResult restoreResult = mongoMigrationService.restoreCollection(cfg.getName(), bsonFile, dstConn, false, restoreToolProfile);
            if (!restoreResult.success())
                return TaskResult.fail(task.getTaskId(), task.getTaskName(), "mongorestore 失敗: " + cfg.getName() + " / " + restoreResult.errorOutput());
            total += restoreResult.rows();
            logTaskUnitDone(task, "コレクション", cfg.getName(), restoreIndex, mongoTargets.size(), restoreResult.rows(), 1);
        }
        return TaskResult.ok(task.getTaskId(), task.getTaskName(), total);
    }

    /**
     * TASK10: ファイルコピー＆PK フォルダ名置換
     */
    private TaskResult task10FileCopy(MigrationTask task, CreateJobRequest req, List<String> codes, long jobId, String direction) throws Exception {
        Path efsPath = Paths.get(efsBasePath);

        if ("off2on".equals(direction)) {
            if (req.uploadIds() == null || req.uploadIds().files() == null) {
                return TaskResult.ok(task.getTaskId(), task.getTaskName(), 0L);
            }
            Path uploadDir = Paths.get(basePath, "uploads", req.uploadIds().files());
            Path filesZip = uploadDir.resolve("files.zip");
            Path sourceDir;
            if (Files.exists(filesZip)) {
                Path extractDir = Paths.get(basePath, "jobs", String.valueOf(jobId), "files_extract");
                log.info("[TASK10_FILE_COPY] ZIP 解凍: {} → {}", filesZip, extractDir);
                archiveService.decompress(filesZip, extractDir);
                sourceDir = extractDir;
            } else {
                sourceDir = uploadDir;
                log.warn("[TASK10_FILE_COPY] files.zip が存在しません、直接参照: {}", uploadDir);
            }
            // カテゴリ別 PK 置換ルール
            // BBS/{bbs_id}/...          → bbs_info PK を翻訳
            // PEvent/{pat_id}/{event_id}/... → pat_main(pat_id) + pat_event PK を翻訳
            // Report/*, DEConf/*        → 翻訳なし（ルールに含めない）
            java.util.Map<String, java.util.List<String>> categoryRules = java.util.Map.of("BBS", java.util.List.of("bbs_info"), "PEvent", java.util.List.of("pat_main", "pat_event"));
            onlineFileClearService.clearFacilityFiles(codes, efsPath);
            long renamed = fileRenameRefreshService.copyWithCategoryRules(sourceDir, efsPath, categoryRules);
            return TaskResult.ok(task.getTaskId(), task.getTaskName(), renamed);

        } else {
            Path outputDir = Paths.get(basePath, "jobs", String.valueOf(jobId), "output", "files");
            transitFileClearService.clearFacilityFiles(codes, outputDir);
            long renamed = fileRenameRefreshService.copyAndRename(efsPath, outputDir, "mst_patient");
            Path zipPath = Paths.get(basePath, "jobs", String.valueOf(jobId), "output", "files_job" + jobId + ".zip");
            archiveService.compress(outputDir, zipPath);
            return TaskResult.ok(task.getTaskId(), task.getTaskName(), renamed);
        }
    }

    // -------------------------------------------------------
    // ユーティリティ
    // -------------------------------------------------------

    /**
     * FK 依存関係に基づいてテーブルをトポロジカルソートする（親テーブルが先）。
     * pg_catalog から FK 情報を取得し Kahn のアルゴリズムで並べ替える。
     * 循環参照や FK 情報取得失敗時は元の順序を維持する。
     */
    private List<PgTableConfig> sortByFkDependency(List<PgTableConfig> tables, JdbcTemplate jdbc) {
        if (tables.size() <= 1) return tables;
        Set<String> tableSet = tables.stream().map(PgTableConfig::getName).collect(Collectors.toSet());

        // pg_catalog から ntss スキーマ内 FK 依存を取得: child_table → parent_table
        Map<String, Set<String>> deps = new HashMap<>();      // child → set of parents
        Map<String, Set<String>> dependents = new HashMap<>(); // parent → set of children
        for (String t : tableSet) {
            deps.put(t, new HashSet<>());
            dependents.put(t, new HashSet<>());
        }

        try {
            String sql = "SELECT c.relname AS child_table, p.relname AS parent_table " + "FROM pg_constraint con " + "JOIN pg_class c ON con.conrelid = c.oid " + "JOIN pg_class p ON con.confrelid = p.oid " + "JOIN pg_namespace ns ON c.relnamespace = ns.oid " + "WHERE con.contype = 'f' AND ns.nspname = 'ntss' AND c.relname <> p.relname";
            jdbc.query(sql, rs -> {
                String child = rs.getString("child_table");
                String parent = rs.getString("parent_table");
                if (tableSet.contains(child) && tableSet.contains(parent)) {
                    deps.get(child).add(parent);
                    dependents.get(parent).add(child);
                }
            });
        } catch (Exception e) {
            log.warn("[SORT_FK] FK 依存取得失敗、元順序を維持: {}", e.getMessage());
            return tables;
        }

        // Kahn のアルゴリズム（in-degree = 0 のノードから順にキューへ）
        Map<String, Integer> inDegree = new HashMap<>();
        for (String t : tableSet) inDegree.put(t, deps.get(t).size());

        Queue<String> queue = new LinkedList<>();
        for (Map.Entry<String, Integer> e : inDegree.entrySet()) {
            if (e.getValue() == 0) queue.add(e.getKey());
        }

        Map<String, PgTableConfig> cfgMap = tables.stream().collect(Collectors.toMap(PgTableConfig::getName, t -> t));
        List<PgTableConfig> sorted = new ArrayList<>();
        while (!queue.isEmpty()) {
            String t = queue.poll();
            sorted.add(cfgMap.get(t));
            for (String child : dependents.get(t)) {
                int deg = inDegree.merge(child, -1, Integer::sum);
                if (deg == 0) queue.add(child);
            }
        }

        // 循環参照等で未処理のテーブルは末尾に追加
        Set<String> sortedNames = sorted.stream().map(PgTableConfig::getName).collect(Collectors.toSet());
        for (PgTableConfig t : tables) {
            if (!sortedNames.contains(t.getName())) sorted.add(t);
        }

        log.info("[SORT_FK] ソート完了: {}テーブル, 先頭5件={}", sorted.size(), sorted.stream().limit(5).map(PgTableConfig::getName).collect(Collectors.joining(",")));
        return sorted;
    }

    // -------------------------------------------------------
    // デバッグ用: タスク単体実行
    // -------------------------------------------------------

    @Override
    public TaskResult runTaskSync(long jobId, String taskName) {
        MigrationJob job = findJob(jobId);
        CreateJobRequest request = deserializeJobParams(job.getJobParams());
        List<String> facilityCodes = Arrays.asList(job.getFacilityCodes());

        MigrationTask task = taskRepository.findByJobIdOrderByTaskId(jobId).stream().filter(t -> t.getTaskName().equals(taskName)).findFirst().orElseThrow(() -> new IllegalArgumentException("タスクが見つかりません: jobId=" + jobId + ", taskName=" + taskName));

        log.info("[DEBUG] タスク単体実行: jobId={}, task={}", jobId, taskName);
        return dispatchTask(task, job, request, facilityCodes);
    }

    @Override
    @Async("migrationTaskExecutor")
    public void runTaskAsync(long jobId, String taskName) {
        log.info("[DEBUG] タスク非同期実行開始: jobId={}, taskName={}", jobId, taskName);
        try {
            TaskResult result = runTaskSync(jobId, taskName);
            log.info("[DEBUG] タスク非同期実行完了: jobId={}, taskName={}, success={}, rows={}", jobId, taskName, result.success(), result.affectedRows());
        } catch (Exception e) {
            log.error("[DEBUG] タスク非同期実行エラー: jobId={}, taskName={}", jobId, taskName, e);
        }
    }

    private String effectiveIdColumn(PgTableConfig tableConfig, PgTableConfig baseConfig) {
        if (tableConfig != null && tableConfig.hasIdColumn()) {
            return tableConfig.getIdColumn();
        }
        if (baseConfig != null && baseConfig.hasIdColumn()) {
            return baseConfig.getIdColumn();
        }
        throw new IllegalStateException("ID 列が未設定です: table=" + (tableConfig != null ? tableConfig.getName() : "<null>") + ", base=" + (baseConfig != null ? baseConfig.getName() : "<null>"));
    }

    private void markJobFailed(long jobId, String reason) {
        MigrationJob job = findJob(jobId);
        job.setStatus(JobStatus.FAILED);
        job.setFinishedAt(Instant.now());
        job.setNote(reason);
        jobRepository.save(job);
        log.warn("[JOB_EXEC] 失敗: jobId={}, reason={}", jobId, reason);
    }

    private MigrationJob findJob(long jobId) {
        return jobRepository.findById(jobId).orElseThrow(() -> new IllegalStateException("JOB が見つかりません: " + jobId));
    }

    private CreateJobRequest deserializeJobParams(String json) {
        if (json == null || json.isBlank()) {
            throw new MigrationBusinessException("job_params が設定されていません");
        }
        try {
            return objectMapper.readValue(json, CreateJobRequest.class);
        } catch (Exception e) {
            throw new MigrationBusinessException("job_params の解析失敗", e);
        }
    }

    /**
     * convert_db の pk_mapping を対象 DB の ntss.pk_mapping_local（永続テーブル）にコピー。
     * TEMP TABLE は接続プールで接続が変わると見えなくなるため永続テーブルを使用する。
     */
    private void copyPkMappingToLocal(JdbcTemplate targetJdbc, String taskName,MigrationJob job) {
        long start = System.currentTimeMillis();
        log.info("[{}] pk_mapping ローカルコピー開始", taskName);
        try {
            targetJdbc.execute("""
                    CREATE UNLOGGED TABLE IF NOT EXISTS ntss.pk_mapping_local (
                        old_id bigint,
                        new_id bigint,
                        table_name text
                    )
                    """);
            targetJdbc.execute("""
                    TRUNCATE TABLE ntss.pk_mapping_local
                    """);
            targetJdbc.execute("""
                    DROP INDEX IF EXISTS ntss.idx_pkm_local_lookup
                    """);
            targetJdbc.execute("""
                    SET synchronous_commit = OFF
                    """);
            Set<String> tableNames = new HashSet<>(targetJdbc.queryForList("""
                    SELECT relname
                    FROM pg_stat_user_tables
                    """, String.class));
            String querySql = """
                    SELECT
                        old_id,
                        new_id,
                        table_name
                    FROM pk_mapping WHERE job_id = ?
                    """;
            String insertSql = """
                    INSERT INTO ntss.pk_mapping_local (
                        old_id,
                        new_id,
                        table_name
                    )
                    VALUES (?, ?, ?)
                    """;
            List<long[]> idBatch = new ArrayList<>(PK_REFRESH_BATCH_SIZE);
            List<String> tableBatch = new ArrayList<>(PK_REFRESH_BATCH_SIZE);
            long[] copied = {0};
            converterJdbc.query(con -> {
                con.setAutoCommit(false);
                java.sql.PreparedStatement ps = con.prepareStatement(querySql);
                ps.setFetchSize(PK_REFRESH_BATCH_SIZE);
                ps.setLong(1, job.getJobId());
                return ps;
            }, rs -> {
                idBatch.add(new long[]{rs.getLong("old_id"), rs.getLong("new_id")});
                tableBatch.add(rs.getString("table_name"));
                if (idBatch.size() >= PK_REFRESH_BATCH_SIZE) {
                    flushBatch(targetJdbc, insertSql, idBatch, tableBatch);
                    copied[0] += idBatch.size();
                    idBatch.clear();
                    tableBatch.clear();
                }
            });
            if (!idBatch.isEmpty()) {
                flushBatch(targetJdbc, insertSql, idBatch, tableBatch);
                copied[0] += idBatch.size();
                idBatch.clear();
                tableBatch.clear();
            }
            targetJdbc.execute("""
                    CREATE INDEX idx_pkm_local_lookup
                    ON ntss.pk_mapping_local (
                        table_name,
                        old_id
                    )
                    """);
            targetJdbc.execute("""
                    ANALYZE ntss.pk_mapping_local
                    """);
            long cost = System.currentTimeMillis() - start;
            log.info("[{}] pk_mapping ローカルコピー完了: rows={}, cost={}ms", taskName, copied[0], cost);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    private void flushBatch(JdbcTemplate jdbc, String insertSql, List<long[]> idBatch, List<String> tableBatch) {
        jdbc.batchUpdate(insertSql, new org.springframework.jdbc.core.BatchPreparedStatementSetter() {
            @Override
            public void setValues(java.sql.PreparedStatement ps, int i) throws java.sql.SQLException {
                long[] ids = idBatch.get(i);
                ps.setLong(1, ids[0]);
                ps.setLong(2, ids[1]);
                ps.setString(3, tableBatch.get(i));
            }

            @Override
            public int getBatchSize() {
                return idBatch.size();
            }
        });
    }
}
