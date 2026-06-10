package jp.co.nikkiso.ntss.device_edge.web.rest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.device_edge.response.comsvOrdMain.DailyReportResponse;
import jp.co.nikkiso.ntss.device_edge.service.LogService;
import jp.co.nikkiso.ntss.device_edge.service.lcdReq.LcdReqService;

@RestController
@RequestMapping("/api/lcdreq40")
public class LcdRe40Resource {

  @Autowired
  private LogService logService;

  /**
   * 仮想端末情報(透析日報)の取得
   */
  @Autowired
  private LcdReqService lcdReqService;

  @GetMapping("/{ord_no}/{device_edge_no}")
  public ResponseEntity<?> getLcdReq(
      @PathVariable("ord_no") long ord_no,
      @PathVariable("device_edge_no") int device_edge_no) {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setDeviceEdgeNo(String.valueOf(device_edge_no));
    eventLogMessage.setLogMessage("API GET CALLED ID = " + ord_no);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    if (ord_no > 0) {
      DailyReportResponse res = lcdReqService.lcdReq40selectByNo(ord_no, device_edge_no);
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
