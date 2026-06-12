package com.fnsi.cloudconverter.job.model;

import java.time.Instant;
import java.util.List;

/**
 * JOB 作成レスポンス (02_api.md § 7)
 */
public record CreateJobResponse(
        long jobId,
        String jobName,
        String direction,
        List<String> facilityCodes,
        String status,
        Instant createdAt,
        int estimatedTasks
) {}
