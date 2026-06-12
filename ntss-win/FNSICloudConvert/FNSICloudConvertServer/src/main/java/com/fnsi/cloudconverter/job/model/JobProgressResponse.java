package com.fnsi.cloudconverter.job.model;

/**
 * JOB 進捗サマリー (02_api.md § 8)
 */
public record JobProgressResponse(
        int totalTasks,
        int doneTasks,
        int runningTasks,
        int pendingTasks,
        int failedTasks,
        int percentComplete
) {}
