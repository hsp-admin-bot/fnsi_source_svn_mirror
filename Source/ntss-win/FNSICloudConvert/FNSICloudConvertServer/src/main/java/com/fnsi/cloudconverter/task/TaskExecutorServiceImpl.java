package com.fnsi.cloudconverter.task;

import com.fnsi.cloudconverter.job.entity.MigrationTask;
import com.fnsi.cloudconverter.job.model.TaskStatus;
import com.fnsi.cloudconverter.job.repository.MigrationTaskRepository;
import com.fnsi.cloudconverter.log.MigrationLogService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.concurrent.Callable;

/**
 * Task 実行エンジン実装 — リトライ・ステータス管理
 * 参照: 03_module.md § Module 13 / 05_key_tech.md § 7
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class TaskExecutorServiceImpl implements TaskExecutorService {

    private final MigrationTaskRepository taskRepository;
    private final MigrationLogService     logService;

    @Value("${migration.task.retry-interval-ms:5000}")
    private long retryIntervalMs;

    @Override
    public TaskResult execute(MigrationTask task, Callable<TaskResult> action) {
        int maxRetry = task.getMaxRetry();
        int attempt  = 0;
        TaskOrderInfo orderInfo = resolveTaskOrder(task);

        // RUNNING にセット
        updateStatus(task.getTaskId(), TaskStatus.RUNNING, null);
        task = reloadTask(task.getTaskId());
        task.setStartedAt(Instant.now());
        taskRepository.save(task);

        logService.info(task.getJobId(), task.getTaskId(),
                "[" + task.getTaskName() + "] 開始 " + formatOrder(orderInfo)
                        + buildEstimateSuffix(task.getEstimatedRows()));

        while (attempt <= maxRetry) {
            try {
                TaskResult result = action.call();

                if (result.success()) {
                    // DONE にセット
                    MigrationTask done = reloadTask(task.getTaskId());
                    if (done.getStatus() == TaskStatus.FAILED) {
                        String interrupted = done.getLastError() != null ? done.getLastError() : "中断されました";
                        logService.warn(task.getJobId(), task.getTaskId(),
                                "[" + task.getTaskName() + "] 中断済みのため DONE へ更新しません: " + interrupted);
                        return TaskResult.fail(task.getTaskId(), task.getTaskName(), interrupted);
                    }

                    done.setStatus(TaskStatus.DONE);
                    done.setAffectedRows(result.affectedRows());
                    done.setFinishedAt(Instant.now());
                    taskRepository.save(done);

                    logService.info(task.getJobId(), task.getTaskId(),
                            "[" + task.getTaskName() + "] 完了 " + formatOrder(orderInfo)
                                    + ": " + formatDoneCount(result.affectedRows(), done.getEstimatedRows()));
                    return result;
                } else {
                    throw new RuntimeException(result.errorMessage());
                }

            } catch (Exception e) {
                attempt++;
                String errMsg = e.getMessage() != null ? e.getMessage() : e.getClass().getSimpleName();

                if (attempt > maxRetry) {
                    // FAILED にセット
                    updateStatus(task.getTaskId(), TaskStatus.FAILED, errMsg);
                    logService.error(task.getJobId(), task.getTaskId(),
                            "[" + task.getTaskName() + "] 失敗: " + errMsg, e);
                    return TaskResult.fail(task.getTaskId(), task.getTaskName(), errMsg);
                }

                // リトライ待機
                logService.warn(task.getJobId(), task.getTaskId(),
                        "[" + task.getTaskName() + "] リトライ " + attempt + "/" + maxRetry
                        + " " + formatOrder(orderInfo)
                        + ": " + errMsg);
                log.warn("[TASK] リトライ {}/{}: taskId={}, error={}", attempt, maxRetry,
                        task.getTaskId(), errMsg);

                // retryCount 更新
                MigrationTask t = reloadTask(task.getTaskId());
                t.setRetryCount(t.getRetryCount() + 1);
                taskRepository.save(t);

                try {
                    Thread.sleep(retryIntervalMs);
                } catch (InterruptedException ie) {
                    Thread.currentThread().interrupt();
                    return TaskResult.fail(task.getTaskId(), task.getTaskName(), "中断されました");
                }
            }
        }

        // ここには到達しないが念のため
        return TaskResult.fail(task.getTaskId(), task.getTaskName(), "不明なエラー");
    }

    private TaskOrderInfo resolveTaskOrder(MigrationTask task) {
        java.util.List<MigrationTask> tasks = taskRepository.findByJobIdOrderByTaskId(task.getJobId());
        int total = tasks.size();
        for (int i = 0; i < tasks.size(); i++) {
            if (tasks.get(i).getTaskId().equals(task.getTaskId())) {
                return new TaskOrderInfo(i + 1, total);
            }
        }
        return new TaskOrderInfo(0, total);
    }

    private String formatOrder(TaskOrderInfo info) {
        if (info.total <= 0 || info.index <= 0) {
            return "";
        }
        return "(" + info.index + "/" + info.total + ")";
    }

    private String buildEstimateSuffix(Long estimatedRows) {
        if (estimatedRows == null || estimatedRows <= 0) {
            return "";
        }
        return " 予定件数=" + estimatedRows;
    }

    private String formatDoneCount(long affectedRows, Long estimatedRows) {
        if (estimatedRows != null && estimatedRows > 0) {
            long done = affectedRows > 0 ? affectedRows : estimatedRows;
            return done + "/" + estimatedRows;
        }
        return "処理件数=" + affectedRows;
    }

    private record TaskOrderInfo(int index, int total) {}

    @Override
    @Transactional
    public void updateStatus(long taskId, TaskStatus status, String errorMsg) {
        MigrationTask t = reloadTask(taskId);
        t.setStatus(status);
        if (errorMsg != null) {
            t.setLastError(errorMsg);
        }
        if (status == TaskStatus.DONE || status == TaskStatus.FAILED) {
            t.setFinishedAt(Instant.now());
        }
        taskRepository.save(t);
    }

    private MigrationTask reloadTask(long taskId) {
        return taskRepository.findById(taskId)
                .orElseThrow(() -> new IllegalStateException("Task が見つかりません: " + taskId));
    }
}
