package com.fnsi.cloudconverter.job.model;

import java.time.Instant;

/**
 * JOB 中断レスポンス (02_api.md § 10)
 */
public record InterruptJobResponse(
        long jobId,
        String status,
        String message,
        String reason,
        Instant interruptedAt
) {}
