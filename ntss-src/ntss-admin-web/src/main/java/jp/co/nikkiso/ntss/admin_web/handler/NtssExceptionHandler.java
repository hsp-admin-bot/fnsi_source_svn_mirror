package jp.co.nikkiso.ntss.admin_web.handler;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage;
import jp.co.nikkiso.ntss.admin_web.response.error.ErrorResponse;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.exception.DataSourceInconsistencyException;
import jp.co.nikkiso.ntss.core.exception.InvalidSchemaDefinitionException;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import jp.co.nikkiso.ntss.core.exception.RequiredException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import lombok.NonNull;
import lombok.extern.slf4j.Slf4j;
import org.seasar.doma.jdbc.OptimisticLockException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.sql.SQLException;

import static jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage.Error.DB_UPDATE_ERROR;
import static jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage.Error.INVALID_SCHEMA_DEFINITION_ERROR;
import static jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage.Error.NOT_EXIST_ERROR;
import static jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage.Error.OPTIMISTIC_LOCK_ERROR;
import static jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage.Error.REQUIRED_ERROR;
import static jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage.Error.RUNTIME_EXECUTION_ERROR;
import static jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage.Error.SQL_EXECUTION_ERROR;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;


/**
 * NTSS例外ハンドラクラス.
 */
@RestControllerAdvice
@Slf4j
public class NtssExceptionHandler extends ResponseEntityExceptionHandler {

  /**
  * ロギングのServiceインタフェース.
  */
  @Autowired
  private LogService logService;

  /**
   * データソース間不整合例外を処理する.
   * @param e 例外オブジェクト
   * @param request リクエストオブジェクト
   * @return {@link ResponseEntity}
   */
  @ExceptionHandler(DataSourceInconsistencyException.class)
  public ResponseEntity<?> handleDataSourceInconsistencyException(Exception e, WebRequest request) {
    // ログ出力
    // 例外オブジェクトには不整合が発生したユーザーIDを持っているが、ログには出力しない
    EventLogMessage eventLogMessage = new EventLogMessage();
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
    eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
		logService.log(LogLevel.ERROR, eventLogMessage,null, null, null);
    return createErrorResponse(e, DB_UPDATE_ERROR, request);
  }

  /**
   * SQL例外を処理する.
   * @param e 例外オブジェクト
   * @param request リクエストオブジェクト
   * @return {@code ResponseEntity}
   */
  @ExceptionHandler(SQLException.class)
  public ResponseEntity<?> handleSqlException(Exception e, WebRequest request) {
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
    eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
		logService.log(LogLevel.ERROR, eventLogMessage,null, null, null);
    return createErrorResponse(e, SQL_EXECUTION_ERROR, request);
  }

  /**
   * スキーマ情報の定義誤り例外を処理する.
   * @param e 例外オブジェクト
   * @param request リクエストオブジェクト
   * @return {@code ResponseEntity}
   */
  @ExceptionHandler(InvalidSchemaDefinitionException.class)
  public ResponseEntity<?> handleInvalidSchemaDefinitionException(Exception e, WebRequest request) {
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
    eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
		logService.log(LogLevel.ERROR, eventLogMessage,null, null, null);
    return createErrorResponse(e, INVALID_SCHEMA_DEFINITION_ERROR, request);
  }

  /**
   * 必須チェックに引っかかった例外を処理する.
   * @param e 例外オブジェクト
   * @param request リクエストオブジェクト
   * @return {@code ResponseEntity}
   */
  @ExceptionHandler(RequiredException.class)
  public ResponseEntity<?> handleRequiredException(Exception e, WebRequest request) {
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
    eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
		logService.log(LogLevel.ERROR, eventLogMessage,null, null, null);
    return createErrorResponse(e, REQUIRED_ERROR, request);
  }

  /**
   * 該当データ無し例外を処理する.
   * @param e 例外オブジェクト
   * @param request リクエストオブジェクト
   * @return {@code ResponseEntity}
   */
  @ExceptionHandler(NotExistException.class)
  public ResponseEntity<?> handleNotExistException(Exception e, WebRequest request) {
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
    eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
		logService.log(LogLevel.ERROR, eventLogMessage,null, null, null);
    return createErrorResponse(e, NOT_EXIST_ERROR, request);
  }

  /**
   * 楽観的排他制御の例外を処理する.
   * @param e 例外オブジェクト
   * @param request リクエストオブジェクト
   * @return {@code ResponseEntity}
   */
  @ExceptionHandler(OptimisticLockException.class)
  public ResponseEntity<?> handleOptimisticLockException(Exception e, WebRequest request) {
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
    eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
		logService.log(LogLevel.ERROR, eventLogMessage,null, null, null);
    return createErrorResponse(e, OPTIMISTIC_LOCK_ERROR, request);
  }

  //FNSI-修正 ログ対応 xiebzh add start
  /**
   * ランタイムの例外を処理する.
   * @param e 例外オブジェクト
   * @param request リクエストオブジェクト
   * @return {@code ResponseEntity}
   */
  @ExceptionHandler(RuntimeException.class)
  public ResponseEntity<?> runtimeException(Exception e, WebRequest request) {
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
    logService.log(LogLevel.ERROR, eventLogMessage,null, null, null);
    return createErrorResponse(e, RUNTIME_EXECUTION_ERROR, request);
  }

  /**
   * ランタイムの例外を処理する.
   * @param e 例外オブジェクト
   * @param request リクエストオブジェクト
   * @return {@link ResponseEntity}
   */
  @ExceptionHandler(Exception.class)
  public ResponseEntity<?> handleAllException(Exception e, WebRequest request) {
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
    logService.log(LogLevel.ERROR, eventLogMessage,null, null, null);
    return createErrorResponse(e, RUNTIME_EXECUTION_ERROR, request);
  }
  //FNSI-修正 ログ対応 xiebzh add end

  /**
   * {@code ResponseEntity}を生成する.
   * @param ex 例外オブジェクト
   * @param error エラーメッセージ情報
   * @param request リクエストオブジェクト
   * @return {@link ResponseEntity}
   */
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<?> createErrorResponse(
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang end
          @NonNull Exception ex,
          @NonNull AdminWebMessage.Error error,
          @NonNull WebRequest request) {
    // add by shiyw : 异常栈输出至ResponseBody, 仅提交uat环境，方便大家根快速定位错误 start
    StringBuffer strbuff = new StringBuffer();
    for (StackTraceElement stet : ex.getStackTrace()) {
      strbuff.append(stet + "--n--");
    }
    String message = error.getMessage() + "--n--" + ex.getMessage() + "--n--" + strbuff;
    // add by shiyw : 异常栈输出至ResponseBody, 仅提交uat环境，方便大家根快速定位错误 end
//    return handleExceptionInternal(ex, new ErrorResponse(error.getMessage()), null, error.getHttpStatus(), request);
    return handleExceptionInternal(ex, new ErrorResponse(message), null, error.getHttpStatus(), request);
  }

  //FNSI-修正 ログ対応 xiebzh add start
  /**
   * エラーメッセージ取得
   * @return
   */
  private String getErrorMessage(Exception e) {
    if (!StringUtils.isEmpty(e.getMessage())) {
      return e.getMessage();
    }
    StringWriter stringWriter= new StringWriter();
    PrintWriter writer= new PrintWriter(stringWriter);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang start
//      e.printStackTrace();
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang end
    StringBuffer buffer = stringWriter.getBuffer();
    return buffer.toString();
  }
  //FNSI-修正 ログ対応 xiebzh add end
}
