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
import jp.co.nikkiso.ntss.core.entity.custom.ComsvMstExamItem;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.device_edge.service.LogService;
import jp.co.nikkiso.ntss.device_edge.service.master.ComsvMasterService;

@RestController
@RequestMapping("/api/comsv_exam/mst")

public class ComsvMstExamItemResource {

  @Autowired
  private LogService logService;

  /**
   * 通信サーバ用検査項目マスタの取得
   */
  @Autowired
  private ComsvMasterService comsvMstExamItemService;

  @GetMapping({ "/{facility_cd}" })
  public ResponseEntity<?> getComsvMstCheckList(
      @PathVariable(name = "facility_cd", required = false) String facility_cd) {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("API GET CALLED facility_cd = " + facility_cd);
    eventLogMessage.setFacilityCd(facility_cd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    if (!Objects.equals(facility_cd, "")) {
      List<ComsvMstExamItem> res = comsvMstExamItemService.fetchExamItem(facility_cd);
      eventLogMessage.setLogMessage("O K");
      eventLogMessage.setFacilityCd(facility_cd);
  	  logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return new ResponseEntity<>(res, HttpStatus.OK);
    } else {
      eventLogMessage.setLogMessage("ERROR");
      eventLogMessage.setFacilityCd(facility_cd);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

}
