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
import jp.co.nikkiso.ntss.core.entity.custom.ComsvSet;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.device_edge.service.ComsvSetService;
import jp.co.nikkiso.ntss.device_edge.service.LogService;

@RestController
@RequestMapping("/api/comsv")

public class ComsvSetResource {

  @Autowired
  private LogService logService;

  /**
   * 通信サーバ設定の取得
   */
  @Autowired
  private ComsvSetService comsvSetService;

  @GetMapping({ "/{facility_cd}/{device_edge_no}" })
  public ResponseEntity<?> getComsvSet(
      @PathVariable(name = "facility_cd", required = false) String facility_cd,
      @PathVariable("device_edge_no") Integer device_edge_no) {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setDeviceEdgeNo(device_edge_no.toString());
    eventLogMessage.setLogMessage("API GET CALLED facility_cd = " + facility_cd + " device_edge_no = " + device_edge_no);
    eventLogMessage.setFacilityCd(facility_cd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    if (!Objects.equals(facility_cd, "") && device_edge_no > 0) {
      ComsvSet res = comsvSetService.selectComsvSet(facility_cd, device_edge_no);
      eventLogMessage.setLogMessage("O K");
      eventLogMessage.setFacilityCd(facility_cd);
  	  logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return new ResponseEntity<>(res, HttpStatus.OK);
    } else {
      eventLogMessage.setLogMessage("ERROR");
      eventLogMessage.setFacilityCd(facility_cd);
  	  logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

}
