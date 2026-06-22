package jp.co.nikkiso.ntss.device_edge.web.rest;

import com.google.common.base.Strings;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.LogObjectUtils;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
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
  private LogServiceCore logServiceCore;

  //mod Input comsv log to mongo db. --趙-- start
  //　ログ出力
//  @PostMapping(LoggingConstant.MONGO_LOG.ACCESS_URI)
//  public ResponseEntity<Void> output(HttpServletRequest request,
//                                     @PathVariable(LoggingConstant.MONGO_LOG.ACCESS_URI_PARAM) String strLogLevel,
//                                     @RequestBody EventLogMessage eventLogMessage) {
  @PostMapping(LoggingConstant.MONGO_LOG.ACCESS_URI)
  public ResponseEntity<Void> output(HttpServletRequest request,
                                     @PathVariable(LoggingConstant.MONGO_LOG.ACCESS_URI_PARAM) String strLogLevel,
                                     @RequestBody String body) {

    EventLogMessage eventLogMessage = new EventLogMessage();

    try {
      String[] info = body.split(",");

      if (Strings.isNullOrEmpty(info[1]) == false) {
        eventLogMessage.setFacilityCd(info[1]);
      }

      if (Strings.isNullOrEmpty(info[4]) == false) {
        eventLogMessage.setDeviceEdgeNo(info[4]);
      }

      if (Strings.isNullOrEmpty(info[6]) == false) {
        eventLogMessage.setMachineType(info[6]);
      }

      if (Strings.isNullOrEmpty(info[7]) == false) {
        eventLogMessage.setDeviceEdgeSerialNo(info[7]);
      }

      if (Strings.isNullOrEmpty(info[9]) == false) {
        eventLogMessage.setFunctionCd(info[9]);
      }

      // The log Message show after log level.
      if (Strings.isNullOrEmpty(info[12]) == false) {
        int index = body.indexOf(info[12]);
        String logMessage = body.substring(index + 8);
        if (Strings.isNullOrEmpty(logMessage) == false) {
          eventLogMessage.setLogMessage(logMessage);
        }
        if (info[12].equals("[DEBUG]")) {
          strLogLevel = "debug";
        } else if (info[12].equals("[ERROR]")) {
          strLogLevel = "error";
        } else {
          strLogLevel = "info";
        }
      }
      //mod Input comsv log to mongo db. --趙-- end

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
        LoggingConstant.MODULE_NAME.NTSS_DEVICE_EDGE,
        LoggingConstant.SERVICE_NAME.REMS,
        null);

      ResponseEntity<Void> ret = new ResponseEntity<>(HttpStatus.OK);
      return ret;
    } catch (Exception e) {
      eventLogMessage.setLogMessage("ERROR:" + e.getMessage());
      logServiceCore.log(
        LogLevel.ERROR,
        eventLogMessage,
        null,
        LoggingConstant.MODULE_NAME.NTSS_DEVICE_EDGE,
        LoggingConstant.SERVICE_NAME.REMS,
        null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
}
