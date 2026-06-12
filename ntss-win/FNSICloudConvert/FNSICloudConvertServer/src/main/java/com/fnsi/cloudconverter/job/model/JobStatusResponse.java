package com.fnsi.cloudconverter.job.model;

import java.time.Instant;
import java.util.List;

/**
 * JOB ステータスレスポンス (02_api.md § 8)
 */
public record JobStatusResponse(
        long jobId,
        String jobName,
        String direction,
        String status,
        Instant startedAt,
        Instant finishedAt,
        long elapsedSeconds,
        List<TaskStatusResponse> tasks,
        JobProgressResponse progress
) {}
