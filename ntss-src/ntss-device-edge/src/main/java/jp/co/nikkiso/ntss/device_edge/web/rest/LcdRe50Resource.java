package jp.co.nikkiso.ntss.device_edge.web.rest;

import java.util.Objects;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq50;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.device_edge.service.LogService;
import jp.co.nikkiso.ntss.device_edge.service.lcdReq.LcdReq50Service;

@RestController
@RequestMapping("/api/lcdreq50")
public class LcdRe50Resource {

  @Autowired
  private LogService logService;

  /**
   * 仮想端末情報(愁訴処置)の取得
   */
  @Autowired
  private LcdReq50Service lcdReq50Service;

  @GetMapping("/{facility_cd}")
  public ResponseEntity<?> getLcdReq(
      @PathVariable(name = "facility_cd", required = false) String facility_cd) {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("API GET CALLED CD = " + facility_cd);
    eventLogMessage.setFacilityCd(facility_cd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    if (!Objects.equals(facility_cd, "")) {
      try {
        LcdReq50 res = lcdReq50Service.selectAll(facility_cd);
        eventLogMessage.setLogMessage("O K " + res);
        eventLogMessage.setFacilityCd(facility_cd);
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
        return new ResponseEntity<>(res, HttpStatus.OK);
      } catch (Exception e) {
        eventLogMessage.setLogMessage("ERROR:" + e.getMessage());
        eventLogMessage.setFacilityCd(facility_cd);
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
        // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
        //return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
        return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
      }
    } else {
      eventLogMessage.setLogMessage("ERROR");
      eventLogMessage.setFacilityCd(facility_cd);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }
  }

}
