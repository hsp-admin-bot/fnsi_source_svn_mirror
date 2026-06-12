package com.fnsi.cloudconverter.job.model;

import java.time.Instant;
import java.util.List;

/**
 * JOB 再開レスポンス (02_api.md § 11)
 */
public record ResumeJobResponse(
        long jobId,
        String status,
        String message,
        List<ResumedTaskInfo> resumedTasks,
        List<ResumedTaskInfo> skippedTasks,
        Instant resumedAt
) {
    public record ResumedTaskInfo(
            long taskId,
            String taskName,
            String previousStatus,
            String newStatus
    ) {}
}
