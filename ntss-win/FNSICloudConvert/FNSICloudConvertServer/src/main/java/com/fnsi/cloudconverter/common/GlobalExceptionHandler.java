package com.fnsi.cloudconverter.common;

import com.fnsi.cloudconverter.common.exception.FacilityAlreadyLockedException;
import com.fnsi.cloudconverter.common.exception.JobNotFoundException;
import com.fnsi.cloudconverter.common.exception.MigrationBusinessException;
import com.mongodb.MongoTimeoutException;
import org.hibernate.exception.JDBCConnectionException;
import jakarta.servlet.http.HttpServletRequest;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.CannotGetJdbcConnectionException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.transaction.CannotCreateTransactionException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.sql.SQLException;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(JobNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleJobNotFound(JobNotFoundException ex,
                                                           HttpServletRequest req) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ErrorResponse.of(404, "Not Found", ex.getMessage(), req.getRequestURI()));
    }

    @ExceptionHandler(FacilityAlreadyLockedException.class)
    public ResponseEntity<ErrorResponse> handleFacilityLocked(FacilityAlreadyLockedException ex,
                                                               HttpServletRequest req) {
        return ResponseEntity.status(HttpStatus.CONFLICT)
                .body(ErrorResponse.of(409, "Conflict", ex.getMessage(), req.getRequestURI()));
    }

    @ExceptionHandler(MigrationBusinessException.class)
    public ResponseEntity<ErrorResponse> handleBusinessError(MigrationBusinessException ex,
                                                              HttpServletRequest req) {
        return ResponseEntity.status(HttpStatus.UNPROCESSABLE_ENTITY)
                .body(ErrorResponse.of(422, "Unprocessable Entity", ex.getMessage(), req.getRequestURI()));
    }

    @ExceptionHandler(AuthenticationException.class)
    public ResponseEntity<ErrorResponse> handleAuth(AuthenticationException ex,
                                                    HttpServletRequest req) {
        if (isDatabaseUnavailable(ex)) {
            return serviceUnavailable(req);
        }
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ErrorResponse.of(401, "Unauthorized", ex.getMessage(), req.getRequestURI()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidation(MethodArgumentNotValidException ex,
                                                          HttpServletRequest req) {
        String msg = ex.getBindingResult().getFieldErrors().stream()
                .map(f -> f.getField() + ": " + f.getDefaultMessage())
                .reduce((a, b) -> a + ", " + b)
                .orElse("バリデーションエラー");
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ErrorResponse.of(400, "Bad Request", msg, req.getRequestURI()));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleAll(Exception ex, HttpServletRequest req) {
        if (isDatabaseUnavailable(ex)) {
            return serviceUnavailable(req);
        }
        log.error("予期しないエラー: {}", ex.getMessage(), ex);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ErrorResponse.of(500, "Internal Server Error",
                        "予期しないエラーが発生しました", req.getRequestURI()));
    }

    private ResponseEntity<ErrorResponse> serviceUnavailable(HttpServletRequest req) {
        return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                .body(ErrorResponse.of(503, "Service Unavailable",
                        "データベース接続待機中です。しばらくしてから再試行してください",
                        req.getRequestURI()));
    }

    private boolean isDatabaseUnavailable(Throwable ex) {
        Throwable current = ex;
        while (current != null) {
            if (current instanceof CannotGetJdbcConnectionException
                    || current instanceof CannotCreateTransactionException
                    || current instanceof JDBCConnectionException
                    || current instanceof MongoTimeoutException) {
                return true;
            }
            if (current instanceof SQLException sqlEx) {
                String state = sqlEx.getSQLState();
                if (state != null && state.startsWith("08")) {
                    return true;
                }
            }
            current = current.getCause();
        }
        return false;
    }
}
