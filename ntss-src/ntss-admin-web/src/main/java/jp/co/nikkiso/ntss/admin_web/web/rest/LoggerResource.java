package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.response.OutputLogResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLogger;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogClass;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.LogObjectUtils;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.util.ObjectUtils;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import java.util.HashMap;
import java.util.Map;


/**
 * ログ出力用API
 */
@RestController
@Slf4j
@RequestMapping(Uri.LOGGING)
public class LoggerResource {

  /**
   * ロギングのServiceインタフェース.
   */
  @Autowired
  private LogService logService;

  /**
   * アプリケーションログ出力する為のパスパラメータ文字列
   */
  private final String LOG_CLASS_APP = "app";

  /**
   * イベントログ出力する為のパスパラメータ文字列
   */
  private final String LOG_CLASS_EVENT = "event";

  /**
   * 出力するログレベル(情報)
   */
  private final String LogLevel_INFO = "info";

  /**
   * 出力するログレベル(警告)
   */
  private final String LogLevel_WARN = "warn";

  /**
   * 出力するログレベル(エラー)
   */
  private final String LogLevel_ERROR = "error";

  /**
   * 出力するログレベル(デバッグ)
   */
  private final String LogLevel_DEBUG = "debug";

  /**
   * ログレベルのマッピング表
   *  key : restAPIのPathパラメータで送られてくるログレベル文字列
   *  value : ログレベル文字列に該当する{@link LogLevel}
   */
  private final Map<String, LogLevel> logLevelMap = new HashMap<String, LogLevel>(){
    {
      // 情報
      put(LogLevel_INFO, LogLevel.INFO);
      // 警告
      put(LogLevel_WARN, LogLevel.WARN);
      // エラー
      put(LogLevel_ERROR, LogLevel.ERROR);
      // デバッグ
      put(LogLevel_DEBUG, LogLevel.DEBUG);
    }
  };

  /**
   * {@link EventLoggerFactory} のファクトリクラス
   */
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  /**
   * ログを出力する.
   *
   * @param request {@link HttpServletRequest}
   * @param strLogClass 出力するログ区分(app or event)
   * @param strLogLevel 出力するログレベル(Info or warn or error or debug)
   * @param eventLogMessage ログメッセージ
   * @param ntssUser 利用者認証情報
   * @return {@link OutputLogResponse} を返却する.
   *         成功時：{@link OutputLogResponse#isSuccess} に <code>true</code>を設定.
   *         失敗時：{@link OutputLogResponse#isSuccess} に <code>false</code>を設定.
   *                ※エラーメッセージも設定.
   */
  @PutMapping("/{logClass}/{logLevel}")
  public ResponseEntity<?> outputLog(
    HttpServletRequest request,
    @PathVariable("logClass") String strLogClass,
    @PathVariable("logLevel") String strLogLevel,
    @Valid @RequestBody EventLogMessage eventLogMessage,
    @AuthenticationPrincipal NtssUser ntssUser) {

    // レスポンス情報を生成
    OutputLogResponse response = new OutputLogResponse(null);

    // ログ区分を列挙型に変換
    LogClass logClass = getLogClass(strLogClass);
    // ログレベルを列挙型に変換
    LogLevel logLevel = getLogLevel(strLogLevel);
    // 想定外のログ区分、ログレベルの場合
    if (StringUtils.isEmpty(logLevel) || StringUtils.isEmpty(logClass)) {
      // レスポンス情報
      response.isSuccess = false;
      response.errorMessage = String.format("ログ出力に失敗しました.ログ区分:[%s] ログレベル:[%s]", strLogClass ,strLogLevel);
      return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
    }

    // ログ出力情報がnullの場合
    if (ObjectUtils.isEmpty(eventLogMessage)) {
      // 成功として扱う.

      EventLogMessage eventLog = new EventLogMessage();
      eventLog.setLogMessage("ログ出力内容が未設定");
      logService.log(LogLevel.INFO, eventLog, null, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(new OutputLogResponse(true, null), HttpStatus.OK);
    }

    // 本アプリケーションが稼働しているIPアドレスを取得
    eventLogMessage.setEc2Identification(LogObjectUtils.getHostAddress());

    // ログ出力を依頼したクライアントIPアドレスを取得
    if (request != null) {
      // クライアントIP取得
      String clientIpAddress = request.getHeader("X-FORWARDED-FOR");
      if (StringUtils.isEmpty(clientIpAddress)) {
        clientIpAddress = request.getRemoteAddr();
      }
      eventLogMessage.setClientIp(clientIpAddress);
      // セッションID
      eventLogMessage.setSessionId(request.getRequestedSessionId());
    }
    // 利用者情報を設定
    if (ntssUser != null) {
      // 施設コード
      eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      // 利用者ID
      eventLogMessage.setUserId(ntssUser.getUserId().toString());
    }
    // ロガー取得
    EventLogger logger = eventLoggerFactory.getLogger(ntssUser.getFacilityCd(), logClass);

    // ログ出力
    // ※想定外のログレベルでここまで来る事がない為、switchのdefaultは記載しない.
    switch (logLevel) {
      case INFO:
        logger.info(eventLogMessage);
        break;
      case ERROR:
        logger.error(eventLogMessage);
        break;
      case WARN:
        logger.warn(eventLogMessage);
        break;
      case DEBUG:
        logger.debug(eventLogMessage);
        break;
    }
    response.isSuccess = true;
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * 与えられた文字列のログ区分から該当する列挙型を取得する.
   * 与えられた文字列がnullもしくは空文字の場合はnullを返却する.
   * また、{@link LogClass} にない場合もnullを返却する.
   *
   * @param strLogClass 文字列のログ区分
   * @return 文字列のログ区分に該当する {@link LogClass}
   */
  private LogClass getLogClass(String strLogClass) {
    // ログ区分がnulｌもしくは空文字の場合
    if (StringUtils.isEmpty(strLogClass)) {
      return null;
    }
    if (LOG_CLASS_APP.equals(strLogClass)) {
      return LogClass.APP;
    } else if (LOG_CLASS_EVENT.equals(strLogClass)) {
      return LogClass.APP;
    } else {
      return null;
    }
  }

  /**
   * 与えられた文字列のログレベルから該当する列挙型を取得する.
   * 与えられた文字列がnullもしくは空文字の場合はnullを返却する.
   * また、{@link LogLevel} にない場合もnullを返却する.
   *
   * @param strLogLevel 文字列のログレベル
   * @return 文字列のログレベルに該当する {@link LogLevel}
   */
  private LogLevel getLogLevel(String strLogLevel) {
    // ログレベルがnulｌもしくは空文字の場合
    //　ログレベルのマッピング表にない場合
    if (StringUtils.isEmpty(strLogLevel) ||
        !logLevelMap.containsKey(strLogLevel)) {
      return null;
    }
    return logLevelMap.get(strLogLevel);
  }
}
