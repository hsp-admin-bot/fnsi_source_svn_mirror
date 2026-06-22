package jp.co.nikkiso.ntss.api;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

import jp.co.nikkiso.ntss.api.service.LogService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import lombok.NonNull;
import lombok.extern.slf4j.Slf4j;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * NTSS-API例外ハンドラクラス.
 */
@RestControllerAdvice
@Slf4j
public class NtssApiExceptionHandler extends ResponseEntityExceptionHandler {

	@Autowired
	private LogService logService;
  /**
   * NTSS基底例外を処理する.
   * @param e 例外オブジェクト
   * @param request リクエストオブジェクト
   * @return {@code ResponseEntity}
   */
  @ExceptionHandler(NtssException.class)
  public ResponseEntity<?> handleNotExistException(Exception e, WebRequest request) {
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    return createErrorResponse(e, HttpStatus.BAD_REQUEST, request);
  }

  /**
   * 上記以外の例外を処理する.
   * @param e 例外オブジェクト
   * @param request リクエストオブジェクト
   * @return {@code ResponseEntity}
   */
  @ExceptionHandler(Exception.class)
  public ResponseEntity<?> handleSqlException(Exception e, WebRequest request) {
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    return createErrorResponse(e, HttpStatus.INTERNAL_SERVER_ERROR, request);
  }

  /**
   * {@code ResponseEntity}を生成する.
   * @param ex 例外オブジェクト
   * @param request リクエストオブジェクト
   * @return {@link ResponseEntity}
   */
  private ResponseEntity<?> createErrorResponse(
    @NonNull Exception ex,
    @NonNull HttpStatus status,
    @NonNull WebRequest request) {

    return handleExceptionInternal(ex, ex.getMessage(), null, status, request);
  }
}
