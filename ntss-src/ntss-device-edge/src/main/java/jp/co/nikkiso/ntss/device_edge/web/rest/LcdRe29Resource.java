package jp.co.nikkiso.ntss.device_edge.web.rest;

import java.util.List;
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
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq29;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.device_edge.service.LogService;
import jp.co.nikkiso.ntss.device_edge.service.lcdReq.LcdReq29Service;

@RestController
@RequestMapping("/api/lcdreq29")
public class LcdRe29Resource {

  @Autowired
  private LogService logService;

  /**
   * 仮想端末情報(処置者)の取得
   */
  @Autowired
  private LcdReq29Service lcdReq29Service;

  @GetMapping("/{facility_cd}/{device_edge_no}")
  public ResponseEntity<?> getLcdReq(
      @PathVariable(name = "facility_cd", required = false) String facility_cd,
      @PathVariable(name = "device_edge_no") String device_edge_no) {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("API GET CALLED CD = " + facility_cd);
    eventLogMessage.setDeviceEdgeNo(device_edge_no);
    eventLogMessage.setFacilityCd(facility_cd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);

    if (!Objects.equals(facility_cd, "") && !Objects.equals(device_edge_no, "")) {
      try {
        int deviceEdgeNo = Integer.parseInt(device_edge_no);
        List<LcdReq29> res = lcdReq29Service.selectByFacilityCd(facility_cd, deviceEdgeNo);
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
