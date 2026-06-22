package jp.co.nikkiso.ntss.device_edge.web.rest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.device_edge.service.ComsvReloadNextPatService;
import jp.co.nikkiso.ntss.device_edge.service.LogService;

@RestController
@RequestMapping("/api/comsv_reload_npat")

public class ComsvReloadNextPatResource {

  @Autowired
  private LogService logService;

  /**
   * 通信サーバ用一斉次患者更新
   * @param facility_cd
   * @param body
   */
  @Autowired
  private ComsvReloadNextPatService comsvReloadNextPatService;

  @PostMapping("/{facility_cd}/{device_edge_no}")
  public int Response(
    @PathVariable(name = "facility_cd", required = false) String facility_cd,
    @PathVariable("device_edge_no") Integer device_edge_no) {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setDeviceEdgeNo(device_edge_no.toString());
    eventLogMessage.setLogMessage("一斉次患者更新[" + facility_cd + "]:[" + device_edge_no + "]");
    eventLogMessage.setFacilityCd(facility_cd);
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    int ret = comsvReloadNextPatService.reloadNextPat(facility_cd, device_edge_no);

    //return HttpStatus.OK;
    return ret;
  }

}
