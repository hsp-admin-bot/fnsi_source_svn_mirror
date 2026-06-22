package jp.co.nikkiso.ntss.coop_api.web.rest;

import jp.co.nikkiso.ntss.api.service.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * Loggerの設定再読み込み用API
 */
@RestController
@RequestMapping(LoggingConstant.LOGGER_RESET.REQUEST_MAPPING)
public class LoggerResetResource {

  /**
   * ロガー生成コンポーネント
   */
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
  @Autowired
  private LogService logService;
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end

  /**
   * Loggerの再設定フラグをオンにする
   */
  @GetMapping(LoggingConstant.LOGGER_RESET.ACCESS_URI)
  public ResponseEntity<?> flgOn() {
    try {
      eventLoggerFactory.resetFlg();
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

}
