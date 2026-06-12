package com.fnsi.cloudconverter.common;

import java.time.Instant;

/**
 * 共通エラーレスポンス（02_api.md 定義）
 */
public record ErrorResponse(
        Instant timestamp,
        int status,
        String error,
        String message,
        String path
) {
    public static ErrorResponse of(int status, String error, String message, String path) {
        return new ErrorResponse(Instant.now(), status, error, message, path);
    }
}
