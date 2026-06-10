package jp.co.nikkiso.ntss.device_edge.web.rest;

import java.io.IOException;
import java.net.URISyntaxException;
import java.text.ParseException;

import jp.co.nikkiso.ntss.device_edge.service.ComsvSendConditionCommFailService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.device_edge.service.ComsvSendConditionService;
import jp.co.nikkiso.ntss.device_edge.service.LogService;

@RestController
@RequestMapping("/api/comsv_send_cond")

public class ComsvSendConditionResource {

  @Autowired
  private LogService logService;

  /**
   * 通信サーバ用条件送信更新
   * @param facility_cd
   * @param body
   */
  @Autowired
  private ComsvSendConditionService comsvSendConditionService;

  // add AWSとDEの通信断からの復旧 --趙-- start
  @Autowired
  private ComsvSendConditionCommFailService comsvSendConditionCommFailService;
  // add AWSとDEの通信断からの復旧 --趙-- end

  @PostMapping("/{facility_cd}")
  public ResponseEntity<Void> Response(
    @PathVariable(name = "facility_cd", required = false) String facility_cd,
    @RequestBody String body) throws ParseException, IOException, URISyntaxException {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("条件送信更新[" + facility_cd + "]:[" + body + "]");
    eventLogMessage.setFacilityCd(facility_cd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    int ret = comsvSendConditionService.sendConditionProc(facility_cd, body);
    if (ret > 0) {
      return ResponseEntity.ok().build();
    } else {
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return ResponseEntity.badRequest().build();
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }
  }

  // add AWSとDEの通信断からの復旧 --趙-- start
  @PostMapping("/comm_fail/{facility_cd}")
  public ResponseEntity<Void> ResponseCommFail(
    @PathVariable(name = "facility_cd", required = false) String facility_cd,
    @RequestBody String body) throws ParseException, IOException, URISyntaxException {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("条件送信更新[" + facility_cd + "]:[" + body + "]");
    eventLogMessage.setFacilityCd(facility_cd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    int ret = comsvSendConditionCommFailService.sendConditionProc(facility_cd, body);
    if (ret > 0) {
      return ResponseEntity.ok().build();
    } else {
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return ResponseEntity.badRequest().build();
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }
  }
  // add AWSとDEの通信断からの復旧 --趙-- end

}
