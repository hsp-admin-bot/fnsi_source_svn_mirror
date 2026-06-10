package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.admin_web.response.OutputLogResponse;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.LogObjectUtils;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;


/**
 * Vueエラーログ出力用API
 */
@RestController
@Slf4j
@RequestMapping(Uri.LOGGING)
public class VueAppLogOutput {

  /**
   * ロギングのServiceインタフェース.
   */
  @Autowired
  private LogService logService;

  /**
   * {@link EventLoggerFactory} のファクトリクラス
   */
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  /**
   * ログを出力する.
   *
   * @param errorMessage ログメッセージ
   * @return {@link OutputLogResponse} を返却する.
   *         成功時：{@link OutputLogResponse#isSuccess} に <code>true</code>を設定.
   *         失敗時：{@link OutputLogResponse#isSuccess} に <code>false</code>を設定.
   *                ※エラーメッセージも設定.
   */
  @PutMapping("/vue/applog/error")
  public ResponseEntity<?> outputLog(
    @RequestBody Map errorMessage) {

    // レスポンス情報を生成
    OutputLogResponse response = new OutputLogResponse(null);

    // ログ出力情報がnullの場合
    if (errorMessage == null) {
      // 成功として扱う.
      return new ResponseEntity<>(response, HttpStatus.OK);
    }

    String message = convertString(errorMessage.get("logMessage"));

    if (StringUtils.isEmpty(message)) {
      // 成功として扱う.
      return new ResponseEntity<>(response, HttpStatus.OK);
    }

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(message);

    // 本アプリケーションが稼働しているIPアドレスを取得
    eventLogMessage.setEc2Identification(LogObjectUtils.getHostAddress());

    logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
    response.isSuccess = true;
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * String変換
   * @param obj 変換用オブジェクト
   * @return 変換したデータ
   */
  public String convertString(Object obj) {
    if (obj == null) {
      return "";
    }

    return obj.toString();
  }
}
