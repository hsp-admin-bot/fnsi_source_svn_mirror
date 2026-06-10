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
import jp.co.nikkiso.ntss.device_edge_updater.request.VersionRequest;
import jp.co.nikkiso.ntss.device_edge_updater.service.LogService;
import jp.co.nikkiso.ntss.device_edge_updater.service.version.VersionService;

@RestController
@RequestMapping(Uri.VERSION)
public class VersionResource {

  @Autowired
  VersionService versionService;
  @Autowired
  LogService logService;

  /**
   * バージョン情報を保存するREST API
   * @param bodydata
   * @return
   */
  @PostMapping("")
  public ResponseEntity<?> setVersionInfo(@RequestBody VersionRequest bodyData) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("CAll SetVersionInfo [facility_cd:" + bodyData.getFacilityCd() + ", device_edge_no:"
        + bodyData.getDeviceEdgeNo() + ", content:" + bodyData.getContent() + "]");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    int result = versionService.saveDeviceEdgeVersion(bodyData.getFacilityCd(), bodyData.getDeviceEdgeNo(),
        bodyData.getContent());

    eventLogMessage.setLogMessage("RETURN SetVersionInfo [result:" + result + "]");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    return new ResponseEntity<>(result, HttpStatus.OK);
  }
}
