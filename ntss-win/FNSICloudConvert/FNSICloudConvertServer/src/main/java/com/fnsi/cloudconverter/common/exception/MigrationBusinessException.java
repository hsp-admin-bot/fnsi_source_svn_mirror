package com.fnsi.cloudconverter.common.exception;

/**
 * 業務ロジックエラー（リトライ対象外）
 */
public class MigrationBusinessException extends RuntimeException {
    public MigrationBusinessException(String message) {
        super(message);
    }

    public MigrationBusinessException(String message, Throwable cause) {
        super(message, cause);
    }
}
