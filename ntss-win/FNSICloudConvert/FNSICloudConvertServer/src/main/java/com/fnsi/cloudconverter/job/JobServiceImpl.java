package com.fnsi.cloudconverter.job;

import tools.jackson.databind.ObjectMapper;
import com.fnsi.cloudconverter.common.exception.JobNotFoundException;
import com.fnsi.cloudconverter.common.exception.MigrationBusinessException;
import com.fnsi.cloudconverter.job.entity.MigrationJob;
import com.fnsi.cloudconverter.job.entity.MigrationTask;
import com.fnsi.cloudconverter.job.model.*;
import com.fnsi.cloudconverter.job.repository.MigrationJobRepository;
import com.fnsi.cloudconverter.job.repository.MigrationTaskRepository;
import com.fnsi.cloudconverter.log.MigrationLogService;
import com.fnsi.cloudconverter.log.ServerLogQueryService;
import com.fnsi.cloudconverter.log.model.LogQueryResult;
import com.fnsi.cloudconverter.migration.pg.PgDumpConfig;
import com.fnsi.cloudconverter.migration.pg.PgTableConfig;
import com.fnsi.cloudconverter.task.JobExecutorService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.AuthenticationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * JOB 制御サービス実装
 * 参照: 03_module.md § Module 12 / 05_key_tech.md § 7,8
 */
@Service
@RequiredArgsConstructor
public class JobServiceImpl implements JobService {

    private static final org.slf4j.Logger log = org.slf4j.LoggerFactory.getLogger(JobServiceImpl.class);

    private static final DateTimeFormatter JOB_NAME_FMT =
            DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss");
    private static final Set<String> ONTOOFF_SEQ_DBS = Set.of("ntss_db5", "ntss_db6");

    private final MigrationJobRepository  jobRepository;
    private final MigrationTaskRepository taskRepository;
    private final FacilityLockService     facilityLockService;
    private final MigrationLogService     logService;
    private final ServerLogQueryService   serverLogQueryService;
    private final JobExecutorService      jobExecutorService;
    private final ObjectMapper            objectMapper;
    private final PgDumpConfig            pgDumpConfig;

    // -------------------------------------------------------
    // JOB 作成・起動 (02_api.md § 7)
    // -------------------------------------------------------

    @Transactional
    @Override
    public CreateJobResponse createJob(CreateJobRequest request) {
        validateCreateRequest(request);

        // 施設ロック取得（競合時は 409 例外）
        facilityLockService.acquireLock(request.facilityCodes(), 0L /* 仮 */);

        // リクエストパラメータを JSON として保存（実行時に使用）
        String jobParamsJson;
        try {
            jobParamsJson = objectMapper.writeValueAsString(request);
        } catch (Exception e) {
            throw new MigrationBusinessException("job_params の JSON 変換に失敗しました", e);
        }

        // JOB レコード作成
        MigrationJob job = new MigrationJob();
        job.setDirection(request.direction());
        job.setFacilityCodes(request.facilityCodes().toArray(new String[0]));
        job.setStatus(JobStatus.INIT);
        job.setJobName(buildJobName(request.direction(), request.facilityCodes()));
        job.setJobParams(jobParamsJson);
        jobRepository.save(job);

        // ロックの locked_by を実際の jobId で更新
        facilityLockService.acquireLock(request.facilityCodes(), job.getJobId());

        // Task レコードを一括作成（PENDING）
        List<MigrationTask> tasks = buildTasks(job.getJobId(), request.direction());
        taskRepository.saveAll(tasks);

        log.info("[JOB] 作成完了: jobId={}, direction={}, facilities={}",
                job.getJobId(), request.direction(), request.facilityCodes());

        // 非同期で JOB 実行開始（トランザクションコミット後に実行 — コミット前に findJob すると見つからないため）
        long jobId = job.getJobId();
        TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
            @Override
            public void afterCommit() {
                jobExecutorService.startAsync(jobId, request);
            }
        });

        return new CreateJobResponse(
                job.getJobId(),
                job.getJobName(),
                job.getDirection(),
                request.facilityCodes(),
                job.getStatus().name(),
                job.getCreatedAt(),
                tasks.size()
        );
    }

    // -------------------------------------------------------
    // JOB ステータス取得 (02_api.md § 8)
    // -------------------------------------------------------

    @Transactional(readOnly = true)
    @Override
    public JobStatusResponse getJob(long jobId) {
        MigrationJob job = findJobOrThrow(jobId);
        List<MigrationTask> tasks = taskRepository.findByJobIdOrderByTaskId(job.getJobId());

        List<TaskStatusResponse> taskResponses = tasks.stream()
                .map(this::toTaskResponse).toList();

        JobProgressResponse progress = buildProgress(tasks);

        long elapsedSeconds = calcElapsed(job);

        return new JobStatusResponse(
                job.getJobId(), job.getJobName(), job.getDirection(),
                job.getStatus().name(), job.getStartedAt(), job.getFinishedAt(),
                elapsedSeconds, taskResponses, progress);
    }

    // -------------------------------------------------------
    // JOB 中断 (02_api.md § 10)
    // -------------------------------------------------------

    @Transactional
    @Override
    public InterruptJobResponse interruptJob(long jobId, String reason) {
        MigrationJob job = findJobOrThrow(jobId);

        if (job.getStatus() == JobStatus.DONE || job.getStatus() == JobStatus.FAILED) {
            throw new org.springframework.dao.InvalidDataAccessApiUsageException(
                    "JOB がすでに終了しています: status=" + job.getStatus());
        }

        job.setStatus(JobStatus.FAILED);
        job.setNote(reason);
        job.setFinishedAt(Instant.now());
        jobRepository.save(job);

        // 実行中の Task を FAILED に変更
        taskRepository.findByJobIdAndStatus(jobId, TaskStatus.RUNNING)
                .forEach(t -> {
                    t.setStatus(TaskStatus.FAILED);
                    t.setLastError("手動中断: " + reason);
                    t.setFinishedAt(Instant.now());
                    taskRepository.save(t);
                });

        facilityLockService.releaseLock(Arrays.asList(job.getFacilityCodes()));
        logService.warn(jobId, null, "JOB を手動中断しました: " + reason);

        log.info("[JOB] 中断: jobId={}, reason={}", jobId, reason);

        return new InterruptJobResponse(
                jobId, JobStatus.FAILED.name(),
                "JOB を手動中断しました", reason, Instant.now());
    }

    // -------------------------------------------------------
    // JOB 再開 (02_api.md § 11)
    // -------------------------------------------------------

    @Transactional
    @Override
    public ResumeJobResponse resumeJob(long jobId, ResumeJobRequest request) {
        MigrationJob job = findJobOrThrow(jobId);

        if (job.getStatus() != JobStatus.FAILED) {
            throw new org.springframework.dao.InvalidDataAccessApiUsageException(
                    "JOB が FAILED 状態ではありません: status=" + job.getStatus());
        }

        // FAILED タスクを PENDING にリセット
        List<MigrationTask> failedTasks = taskRepository
                .findByJobIdAndStatus(jobId, TaskStatus.FAILED);

        List<ResumeJobResponse.ResumedTaskInfo> resumedInfos;
        List<ResumeJobResponse.ResumedTaskInfo> skippedInfos = List.of();

        if (request != null && request.skipFailedTasks()) {
            // スキップモード: FAILED タスクを DONE にマーク
            failedTasks.forEach(t -> {
                t.setStatus(TaskStatus.DONE);
                taskRepository.save(t);
            });
            skippedInfos = failedTasks.stream()
                    .map(t -> new ResumeJobResponse.ResumedTaskInfo(
                            t.getTaskId(), t.getTaskName(), "FAILED", "DONE"))
                    .toList();
            resumedInfos = List.of();
        } else {
            // 通常モード: FAILED タスクを PENDING にリセット
            taskRepository.resetFailedTasks(jobId);
            resumedInfos = failedTasks.stream()
                    .map(t -> new ResumeJobResponse.ResumedTaskInfo(
                            t.getTaskId(), t.getTaskName(), "FAILED", "PENDING"))
                    .toList();
        }

        // JOB を RUNNING に戻す
        job.setStatus(JobStatus.RUNNING);
        job.setNote(request != null ? request.note() : null);
        jobRepository.save(job);

        String note = request != null ? request.note() : "";
        logService.info(jobId, null, "JOB を再開しました: " + note);

        // 非同期で断点再開
        jobExecutorService.resumeAsync(jobId);

        log.info("[JOB] 再開: jobId={}", jobId);

        return new ResumeJobResponse(
                jobId, JobStatus.RUNNING.name(), "JOB を再開しました",
                resumedInfos, skippedInfos, Instant.now());
    }

    // -------------------------------------------------------
    // ログ取得 (02_api.md § 9)
    // -------------------------------------------------------

    @Override
    public LogQueryResult getLogs(long jobId, long offset, int limit, String level, Long taskId) {
        MigrationJob job = findJobOrThrow(jobId);
        LogQueryResult fileLogResult = serverLogQueryService.fetchLogs(job, offset, limit);
        if (fileLogResult != null) {
            return fileLogResult;
        }
        return logService.fetchLogs(jobId, offset, limit, level, taskId);
    }

    // -------------------------------------------------------
    // プライベートメソッド
    // -------------------------------------------------------

    private MigrationJob findJobOrThrow(long jobId) {
        return jobRepository.findById(jobId)
                .orElseThrow(() -> new JobNotFoundException(jobId));
    }

    private void validateCreateRequest(CreateJobRequest req) {
        if (!"off2on".equals(req.direction()) && !"on2off".equals(req.direction())) {
            throw new IllegalArgumentException("direction は off2on または on2off である必要があります");
        }
        if ("off2on".equals(req.direction()) && req.uploadIds() == null) {
            throw new IllegalArgumentException("off2on JOB には uploadIds が必要です");
        }
        if ("on2off".equals(req.direction())) {
            validateOnToOffSeqStartMap(req.seqStartMap());
        }
    }

    private void validateOnToOffSeqStartMap(Map<String, Long> seqStartMap) {
        if (seqStartMap == null || seqStartMap.isEmpty()) {
            throw new IllegalArgumentException("on2off JOB には seqStartMap が必要です");
        }

        Set<String> requiredTables = pgDumpConfig.tablesFor("on2off").stream()
                .filter(PgTableConfig::hasIdColumn)
                .filter(cfg -> cfg.getSharedPkTable() == null || cfg.getSharedPkTable().isBlank())
                .filter(cfg -> ONTOOFF_SEQ_DBS.contains(cfg.getDb()))
                .map(PgTableConfig::getName)
                .collect(java.util.stream.Collectors.toSet());

        List<String> missing = requiredTables.stream()
                .filter(tableName -> !seqStartMap.containsKey(tableName))
                .sorted()
                .toList();
        if (!missing.isEmpty()) {
            throw new IllegalArgumentException(
                    "on2off JOB の seqStartMap に必要テーブルが不足しています: " + String.join(", ", missing));
        }

        List<String> invalid = requiredTables.stream()
                .filter(tableName -> seqStartMap.get(tableName) == null || seqStartMap.get(tableName) < 1)
                .sorted()
                .toList();
        if (!invalid.isEmpty()) {
            throw new IllegalArgumentException(
                    "on2off JOB の seqStartMap に 1 未満の値があります: " + String.join(", ", invalid));
        }
    }

    private String buildJobName(String direction, List<String> facilityCodes) {
        String fac = facilityCodes.isEmpty() ? "UNKNOWN" : facilityCodes.getFirst();
        return direction + "_" + fac + "_" + LocalDateTime.now().format(JOB_NAME_FMT);
    }

    /** direction に応じたタスクリストを生成 (01_flow.md § 2,3) */
    private List<MigrationTask> buildTasks(Long jobId, String direction) {
        record TaskDef(String name, String phase) {}

        List<TaskDef> defs = "off2on".equals(direction)
                ? List.of(
                    new TaskDef("TASK1_PG_IMPORT",          "IMPORT"),
                    new TaskDef("TASK2_PK_MAPPING",         "PK"),
                    new TaskDef("TASK3_PK_REFRESH",         "PK"),
                    new TaskDef("TASK4_FK_REFRESH",         "FK"),
                    new TaskDef("TASK5_MONGO_IMPORT",       "MONGO"),
                    new TaskDef("TASK6_MONGO_FK_REFRESH",   "MONGO"),
                    new TaskDef("TASK7_PG_EXPORT",          "EXPORT"),
                    new TaskDef("TASK8_PG_RESTORE_PROD",    "EXPORT"),
                    new TaskDef("TASK9_MONGO_EXPORT_IMPORT","MONGO"),
                    new TaskDef("TASK10_FILE_COPY",         "FILE"))
                : List.of(
                    new TaskDef("TASK1_PG_EXPORT_PROD",     "EXPORT"),
                    new TaskDef("TASK2_PG_IMPORT_TRANSIT",  "IMPORT"),
                    new TaskDef("TASK3_MONGO_EXPORT_IMPORT","MONGO"),
                    new TaskDef("TASK4_PK_MAPPING",         "PK"),
                    new TaskDef("TASK5_PK_REFRESH",         "PK"),
                    new TaskDef("TASK6_FK_REFRESH",         "FK"),
                    new TaskDef("TASK7_MONGO_FK_REFRESH",   "MONGO"),
                    new TaskDef("TASK8_PG_EXPORT_TRANSIT",  "EXPORT"),
                    new TaskDef("TASK9_MONGO_EXPORT",       "MONGO"),
                    new TaskDef("TASK10_FILE_COPY",         "FILE"));

        return defs.stream().map(d -> {
            MigrationTask t = new MigrationTask();
            t.setJobId(jobId);
            t.setTaskName(d.name());
            t.setPhase(d.phase());
            t.setStatus(TaskStatus.PENDING);
            return t;
        }).toList();
    }

    private TaskStatusResponse toTaskResponse(MigrationTask t) {
        return new TaskStatusResponse(
                t.getTaskId(), t.getTaskName(), t.getPhase(), t.getTableName(),
                t.getStatus().name(), t.getRetryCount(),
                t.getEstimatedRows(), t.getAffectedRows(),
                t.getStartedAt(), t.getFinishedAt(), t.getLastError());
    }

    private JobProgressResponse buildProgress(List<MigrationTask> tasks) {
        int total   = tasks.size();
        int done    = (int) tasks.stream().filter(t -> t.getStatus() == TaskStatus.DONE).count();
        int running = (int) tasks.stream().filter(t -> t.getStatus() == TaskStatus.RUNNING).count();
        int pending = (int) tasks.stream().filter(t -> t.getStatus() == TaskStatus.PENDING).count();
        int failed  = (int) tasks.stream().filter(t -> t.getStatus() == TaskStatus.FAILED).count();
        int pct     = total == 0 ? 0 : (done * 100 / total);
        return new JobProgressResponse(total, done, running, pending, failed, pct);
    }

    private long calcElapsed(MigrationJob job) {
        if (job.getStartedAt() == null) return 0;
        Instant end = job.getFinishedAt() != null ? job.getFinishedAt() : Instant.now();
        return end.getEpochSecond() - job.getStartedAt().getEpochSecond();
    }
}
