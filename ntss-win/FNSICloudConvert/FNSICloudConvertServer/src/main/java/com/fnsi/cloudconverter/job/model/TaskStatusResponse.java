package com.fnsi.cloudconverter.job.model;

import java.time.Instant;

/**
 * Task ステータスレスポンス (02_api.md § 8)
 */
public record TaskStatusResponse(
        long taskId,
        String taskName,
        String phase,
        String tableName,
        String status,
        int retryCount,
        Long estimatedRows,
        Long affectedRows,
        Instant startedAt,
        Instant finishedAt,
        String lastError
) {}
