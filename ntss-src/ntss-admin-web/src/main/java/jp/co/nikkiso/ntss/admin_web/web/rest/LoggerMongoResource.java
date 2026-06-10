package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.response.OutputLogResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.logevent.ILogEventService;
import jp.co.nikkiso.ntss.core.logevent.LogEventUtil;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
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

import javax.validation.Valid;

/**
 * ログ出力用API(Mongo)
 */
@RestController
@Slf4j
@RequestMapping(LoggingConstant.MONGO_LOG.REQUEST_MAPPING)
public class LoggerMongoResource {

  /**
   * ロギングのServiceインタフェース.
   */
  @Autowired
  private LogService logService;

  @Autowired
  private ILogEventService logEventService;

  /**
   * {@link EventLoggerFactory} のファクトリクラス
   */
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  /**
   * ログを出力する.
   *
   * @param strLogLevel 出力するログレベル(Info or warn or error or debug)
   * @param eventLogMessage ログメッセージ
   * @param ntssUser 利用者認証情報
   * @return {@link OutputLogResponse} を返却する.
   *         成功時：{@link OutputLogResponse#isSuccess} に <code>true</code>を設定.
   *         失敗時：{@link OutputLogResponse#isSuccess} に <code>false</code>を設定.
   *                ※エラーメッセージも設定.
   */
  @PutMapping(LoggingConstant.MONGO_LOG.ACCESS_URI)
  public ResponseEntity<?> outputLog(
    @PathVariable(LoggingConstant.MONGO_LOG.ACCESS_URI_PARAM) String strLogLevel,
    @Valid @RequestBody EventLogMessage eventLogMessage,
    @AuthenticationPrincipal NtssUser ntssUser) {

    try {
      // レスポンス情報を生成
      OutputLogResponse response = new OutputLogResponse(null);

      // ログレベルを列挙型に変換
      LogLevel logLevel = LogObjectUtils.getLogLevel(strLogLevel);
      // 想定外のログ区分、ログレベルの場合
      if (StringUtils.isEmpty(logLevel)) {
        // レスポンス情報
        response.isSuccess = false;
        response.errorMessage = String.format("ログ出力に失敗しました. ログレベル:[%s]", strLogLevel);
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

      // 利用者情報を設定
      if (ntssUser != null) {
        // 施設コード
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
        // 利用者ID
        eventLogMessage.setUserId(ntssUser.getUserId().toString());
      }

      logEventService.create(logLevel, LogEventUtil.getLogEvent(logLevel.name(), eventLogMessage));
      response.isSuccess = true;
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      eventLogMessage.setLogMessage("ERROR:" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.REMS, null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

}
