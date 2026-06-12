package com.fnsi.cloudconverter.task;

import com.fnsi.cloudconverter.job.entity.MigrationTask;
import com.fnsi.cloudconverter.job.model.TaskStatus;

import java.util.concurrent.Callable;

/**
 * Task 実行エンジン (03_module.md § Module 13)
 */
public interface TaskExecutorService {
    /**
     * Task を実行する（リトライ込み）
     */
    TaskResult execute(MigrationTask task, Callable<TaskResult> action);

    /**
     * Task のステータスを更新する
     */
    void updateStatus(long taskId, TaskStatus status, String errorMsg);
}
