package com.fnsi.cloudconverter.transfer.model;

import java.time.Instant;

/**
 * ZIP アップロードレスポンス (02_api.md § 3)
 */
public record UploadResponse(
        String  uploadId,
        String  uploadType,
        String  storagePath,
        long    fileSize,
        Instant uploadedAt,
        String  message
) {}
