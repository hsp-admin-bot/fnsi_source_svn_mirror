package com.fnsi.cloudconverter.job.model;

/**
 * JOB 再開リクエスト (02_api.md § 11)
 */
public record ResumeJobRequest(
        boolean skipFailedTasks,
        String note
) {}
