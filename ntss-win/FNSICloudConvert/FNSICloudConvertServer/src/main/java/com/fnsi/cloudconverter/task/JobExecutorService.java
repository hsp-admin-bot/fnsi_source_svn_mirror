package com.fnsi.cloudconverter.task;

import com.fnsi.cloudconverter.job.model.CreateJobRequest;

/**
 * JOB 実行オーケストレーター (03_module.md § Module 13)
 */
public interface JobExecutorService {
    /**
     * JOB を非同期で開始する
     */
    void startAsync(long jobId, CreateJobRequest request);

    /**
     * 断点再開: PENDING タスクから再開する
     */
    void resumeAsync(long jobId);

    /**
     * デバッグ用: 指定タスクを同期で単体実行する
     * @param jobId    対象 JOB ID（既存の JOB が必要）
     * @param taskName タスク名（例: TASK1_PG_IMPORT）
     * @return タスク実行結果
     */
    TaskResult runTaskSync(long jobId, String taskName);

    /**
     * デバッグ用: 指定タスクを非同期（別スレッド）で単体実行する。
     * 呼び出し側はすぐ返り、タスクはバックグラウンドで完走する。
     */
    void runTaskAsync(long jobId, String taskName);
}
