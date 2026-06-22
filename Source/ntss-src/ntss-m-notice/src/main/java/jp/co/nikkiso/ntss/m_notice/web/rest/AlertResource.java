package jp.co.nikkiso.ntss.m_notice.web.rest;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.m_notice.packet.InvalidAlertFormatException;
import jp.co.nikkiso.ntss.m_notice.service.LogService;
import jp.co.nikkiso.ntss.m_notice.service.MNotice;
import jp.co.nikkiso.ntss.m_notice.web.dto.AlertDTO;

@RestController
public class AlertResource {

  @Autowired
  LogService logService;
  @Autowired
  private MNotice mNotice;

  @PostMapping("/api/alerts")
  public ResponseEntity<Void> alerts(@RequestBody AlertDTO alert) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to alerts : " +  alert);
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    mNotice.run(alert.getContentAsBytes());
    return ResponseEntity.ok().build();
  }

  // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
  //@ResponseStatus(HttpStatus.BAD_REQUEST)
  @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
  // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
  @ExceptionHandler(InvalidAlertFormatException.class)
  @ResponseBody
  public Map<String, Object> handleError(InvalidAlertFormatException e) {
    Map<String, Object> errorMap = new HashMap<>();
    errorMap.put("message", e.getMessage());
    // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
    //errorMap.put("status", HttpStatus.BAD_REQUEST);
    errorMap.put("status", HttpStatus.INTERNAL_SERVER_ERROR);
    // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    return errorMap;
  }
}
