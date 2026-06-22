package jp.co.nikkiso.ntss.device_edge.web.rest;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq45;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.device_edge.service.LogService;
import jp.co.nikkiso.ntss.device_edge.service.lcdReq.LcdReqService;

@RestController
@RequestMapping("/api/lcdreq45")
public class LcdRe45Resource {

  @Autowired
  private LogService logService;

  /**
   * 仮想端末情報(メモ)の取得
   */
  @Autowired
  private LcdReqService lcdReqService;

  @GetMapping("/{pat_id}")
  public ResponseEntity<?> getLcdReq(
      @PathVariable("pat_id") long pat_id) {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setPatId(String.valueOf(pat_id));
    eventLogMessage.setLogMessage("API GET CALLED ID = " + pat_id);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    if (pat_id > 0) {
      List<LcdReq45> res = lcdReqService.lcdReq45SelectById(pat_id);
      eventLogMessage.setLogMessage("O K");
  	  logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return new ResponseEntity<>(res, HttpStatus.OK);
    } else {
      eventLogMessage.setLogMessage("ERROR");
  	  logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

}
