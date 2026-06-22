package jp.co.nikkiso.ntss.device_edge.web.rest;

import java.text.ParseException;
import java.util.Arrays;

import jp.co.nikkiso.ntss.device_edge.service.LogEventUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.device_edge.constant.Constant.WebSocketTopic;
import jp.co.nikkiso.ntss.device_edge.service.ComsvOrdWeightScaleService;
import jp.co.nikkiso.ntss.device_edge.service.LogService;
import jp.co.nikkiso.ntss.device_edge.service.webSocketNotify.PayloadBuilder;
import jp.co.nikkiso.ntss.device_edge.service.webSocketNotify.WebSocketNotifyService;
import jp.co.nikkiso.ntss.device_edge.service.webSocketNotify.WebSocketNotifyService.SendTarget;
import jp.co.nikkiso.ntss.device_edge.web.rest.util.WebApiCallCommonUtil;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;

@RestController
@RequestMapping("/api/comsv_ord")

public class ComsvOrdWeightScaleResource {

  @Autowired
  private LogService logService;

  @Autowired
  WebSocketNotifyService sendWsMsg;

  @Autowired
  WebApiCallCommonUtil webApiCallCommonUtil;

  @Autowired
  private ComsvOrdWeightScaleService comsvOrdWeightScaleService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End


  /**
   * 通信サーバ用体重計測定実績のステータス、メッセージ更新
   * @param facilityCd
   * @param weightScaleNo
   * @param weightScaleStatus
   * @return
   * @throws ParseException
   */
  @PutMapping("/weight_scale/{facility_cd}/{weight_scale_no}/{weight_scale_status}/{message}")
  public ResponseEntity<Void> updateSendDate(
      @PathVariable("facility_cd") String facilityCd,
      @PathVariable("weight_scale_no") Long weightScaleNo,
      @PathVariable("weight_scale_status") Integer weightScaleStatus,
      @PathVariable(name = "message", required = false) String message) throws ParseException {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "//api/comsv_ord" + "/weight_scale";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      Arrays.asList(weightScaleNo, weightScaleStatus,message));
    // wp アプリケーションログの適正化 Add End

//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage("API PUT CALLED = " + facilityCd + " " + weightScaleNo + " " + weightScaleStatus + " " + message);
//    eventLogMessage.setFacilityCd(facilityCd);
//    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    boolean ret = comsvOrdWeightScaleService.updateSendCondStatus(facilityCd, weightScaleNo, weightScaleStatus, message);

    if (ret) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),"", AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
        Arrays.asList(weightScaleNo, weightScaleStatus,message));
      // wp アプリケーションログの適正化 Add End
      return ResponseEntity.ok().build();
    } else {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
        Arrays.asList(weightScaleNo, weightScaleStatus,message));
      // wp アプリケーションログの適正化 Add End
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return ResponseEntity.badRequest().build();
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }
  }

  /**
   * 画面への結果通知……。
   * @param facility_cd
   * @param weight_scale_no
   * @return
   */
  @PostMapping("/weight_scale/notify/{facility_cd}/{weight_scale_no}")
  public ResponseEntity<?> notifyResult(
      @PathVariable("facility_cd") String facility_cd,
      @PathVariable("weight_scale_no") Long weight_scale_no) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "//api/comsv_ord" + "/weight_scale";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, facility_cd,
      weight_scale_no);
    // wp アプリケーションログの適正化 Add End

    String topic = PayloadBuilder.BuildSendConditionResultTopic(WebSocketTopic.WeightState.SEND_RESULT, facility_cd);

    String payload = String.valueOf(weight_scale_no);

    // ブラウザあてにWebsocket通知
    Boolean bres = false;
    if (sendWsMsg.sendMsg(SendTarget.browser, facility_cd, null, topic, payload)) {
      bres = true;
    }
    String res = "{ \"websocket_send_responce\":" + bres.toString() + "}";

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, facility_cd,
      weight_scale_no);
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(res, HttpStatus.OK);
  }

  /**
   * クラス名取得
   */
  private String getClassName() {
    return this.getClass().getName();
  }

  /**
   * メソッド名取得
   */
  private String getMethodName() {
    return Thread.currentThread().getStackTrace()[2].getMethodName();
  }

}
