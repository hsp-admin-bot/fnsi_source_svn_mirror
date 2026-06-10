package jp.co.nikkiso.ntss.device_edge_updater.web.rest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.device_edge_updater.constant.Constant.Uri;
import jp.co.nikkiso.ntss.device_edge_updater.request.PlanInfoRequest;
import jp.co.nikkiso.ntss.device_edge_updater.service.LogService;
import jp.co.nikkiso.ntss.device_edge_updater.service.plan.PlanInfoService;

@RestController
@RequestMapping(Uri.PLAN)
public class PlanInfoResource {

  @Autowired
  PlanInfoService planInfoService;
  @Autowired
  LogService logService;

  /**
   * 予定情報を保存するREST API
   * @param bodydata
   * @return
   */
  @PostMapping("update")
  public ResponseEntity<?> setPlanInfo(@RequestBody PlanInfoRequest bodyData) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setDeviceEdgeNo(bodyData.getDeviceEdgeNo() == null ? null : bodyData.getDeviceEdgeNo().toString());
    eventLogMessage.setFacilityCd(bodyData.getFacilityCd());
    eventLogMessage.setLogMessage("CAll setPlanInfo [facility_cd:" + bodyData.getFacilityCd() + ", device_edge_no:"
        + bodyData.getDeviceEdgeNo() + ", seq_no:" + bodyData.getSeqNo() + ", plan_date:" + bodyData.getPlanDate() + "]");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    int result = planInfoService.savePlanInfo(bodyData.getFacilityCd(), bodyData.getDeviceEdgeNo(),
        bodyData.getSeqNo(), bodyData.getPlanDate());

    eventLogMessage.setLogMessage("RETURN setPlanInfo [result:" + result + "]");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    return new ResponseEntity<>(result, HttpStatus.OK);
  }
}
