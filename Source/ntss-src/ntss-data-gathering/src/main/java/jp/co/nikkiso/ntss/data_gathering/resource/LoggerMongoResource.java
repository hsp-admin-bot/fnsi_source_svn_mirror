package jp.co.nikkiso.ntss.data_gathering.resource;

import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.LogObjectUtils;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.data_gathering.service.LogService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jakarta.servlet.http.HttpServletRequest;

@RestController
@Slf4j
@RequestMapping(LoggingConstant.MONGO_LOG.REQUEST_MAPPING)
public class LoggerMongoResource {

  @Autowired
  private LogService logService;

  @Autowired
  private LogServiceCore logServiceCore;

  //　ログ出力
  @PostMapping(LoggingConstant.MONGO_LOG.ACCESS_URI)
  public ResponseEntity<Void> output(HttpServletRequest request,
                                     @PathVariable(LoggingConstant.MONGO_LOG.ACCESS_URI_PARAM) String strLogLevel,
                                     @RequestBody EventLogMessage eventLogMessage) {

    try {
      // ログレベルを列挙型に変換
      LogLevel logLevel = LogObjectUtils.getLogLevel(strLogLevel);
      // 想定外のログ区分、ログレベルの場合
      if (StringUtils.isEmpty(logLevel)) {
        // レスポンス情報
        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
      }

      logServiceCore.log(
        LogLevel.INFO,
        eventLogMessage,
        null,
        LoggingConstant.MODULE_NAME.NTSS_DATA_GATHERING,
        LoggingConstant.SERVICE_NAME.FNSI,
        null);

      ResponseEntity<Void> ret = new ResponseEntity<>(HttpStatus.OK);
      return ret;
    } catch (Exception e) {
      eventLogMessage.setLogMessage("ERROR:" + e.getMessage());
      logServiceCore.log(
        LogLevel.ERROR,
        eventLogMessage,
        null,
        LoggingConstant.MODULE_NAME.NTSS_DATA_GATHERING,
        LoggingConstant.SERVICE_NAME.FNSI,
        null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
}
