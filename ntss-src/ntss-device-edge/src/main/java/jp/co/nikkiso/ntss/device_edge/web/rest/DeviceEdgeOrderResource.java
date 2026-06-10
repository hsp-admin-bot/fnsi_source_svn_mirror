package jp.co.nikkiso.ntss.device_edge.web.rest;

import java.util.Objects;

import jp.co.nikkiso.ntss.device_edge.service.LogEventUtils;
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
import jp.co.nikkiso.ntss.device_edge.constant.Constant.Uri;
import jp.co.nikkiso.ntss.device_edge.constant.Constant.WebSocketTopic;
import jp.co.nikkiso.ntss.device_edge.request.deviceEdgeOrder.DeviceEdgeOrderRequest;
import jp.co.nikkiso.ntss.device_edge.response.deviceEdgeOrder.DeviceEdgeOrderResponse;
import jp.co.nikkiso.ntss.device_edge.service.LogService;
import jp.co.nikkiso.ntss.device_edge.service.deviceEdgeOrder.DeviceEdgeOrderService;
import jp.co.nikkiso.ntss.device_edge.service.webSocketNotify.PayloadBuilder;
import jp.co.nikkiso.ntss.device_edge.service.webSocketNotify.WebSocketNotifyService;
import jp.co.nikkiso.ntss.device_edge.service.webSocketNotify.WebSocketNotifyService.SendTarget;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@RestController
@RequestMapping(Uri.DEVICE_EDGE_ORDER)
public class DeviceEdgeOrderResource {

  @Autowired
  private LogService logService;

  @Autowired
  WebSocketNotifyService sendWsMsg;

  @Autowired
  DeviceEdgeOrderService deviceEdgeOrderService;
  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  private DeviceEdgeOrderResponse sendMessageToComServer(String facilityCd, Integer deviceEdgeNo, String topicKey,
      String payload) {

    String topic = PayloadBuilder.BuildTopic(topicKey, facilityCd, deviceEdgeNo);
    return sendMessage(facilityCd, deviceEdgeNo, topic, payload);
  }

  private DeviceEdgeOrderResponse sendMessage(String facilityCd, Integer deviceEdgeNo, String topic, String payload) {
    DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
    // EdgeあてにWebsocket通知
    if (sendWsMsg.sendMsg(SendTarget.main, facilityCd, deviceEdgeNo, topic, payload)) {
      res.isSuccess = true;
    } else {
      res.isSuccess = false;
      res.errorMessage = "通信サーバーへの通知失敗";
    }
    return res;
  }

  /**
   * 装置オプション読出し指示
   */
  @PostMapping("/read_option")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<?> PostOrderReadOption(@RequestBody DeviceEdgeOrderRequest request) {
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang end
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_ORDER + "/read_option";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
    try {
      DeviceEdgeOrderRequest targetInfo = deviceEdgeOrderService.findMissingData(request);
      String machineInfo = request.getMachineNo().toString();

      res = sendMessageToComServer(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(),
          WebSocketTopic.ComSv.READ_OPTION, machineInfo);

    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
  	  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (request != null && request.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(request.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
  	  logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      res.isSuccess = false;
      res.errorMessage = e.getMessage();
    }
    if (res.isSuccess) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } else {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 設定値読出し指示
   */
  @PostMapping("/read_setting_value")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<?> PostOrderReadSettingValue(@RequestBody DeviceEdgeOrderRequest request) {
// #9698 アプリケーションログの内容修正 20260401 mod yangxuewang end
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_ORDER + "/read_setting_value";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
    try {
      DeviceEdgeOrderRequest targetInfo = deviceEdgeOrderService.findMissingData(request);
      String machineInfo = PayloadBuilder.BuildMachineAndOrdNoPayload(targetInfo.getMachineNo(), targetInfo.getOrdNo());

      res = sendMessageToComServer(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(),
          WebSocketTopic.ComSv.READ_SETTING_VALUE, machineInfo);

    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (request != null && request.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(request.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      res.isSuccess = false;
      res.errorMessage = e.getMessage();
    }
    if (res.isSuccess) {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } else {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 次患者情報転送指示
   */
  @PostMapping("/send_next_pat")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<?> PostOrderSendNextPat(@RequestBody DeviceEdgeOrderRequest request) {
// #9698 アプリケーションログの内容修正 20260401 mod yangxuewang end
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_ORDER + "/send_next_pat";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End


    DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
    try {
      DeviceEdgeOrderRequest targetInfo = deviceEdgeOrderService.findMissingData(request);
      String machineInfo = PayloadBuilder.BuildMachineAndOrdNoPayload(request.getMachineNo(), request.getOrdNo());

      res = sendMessageToComServer(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(),
          WebSocketTopic.ComSv.SEND_NEXT_PAT, machineInfo);

    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (request != null && request.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(request.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      res.isSuccess = false;
      res.errorMessage = e.getMessage();
    }
    if (res.isSuccess) {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } else {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 通信サーバー設定更新指示
   */
  @PostMapping("/reload_comsv_setting")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<?> PostOrderReloadComsvSetting(@RequestBody DeviceEdgeOrderRequest request) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_ORDER + "/reload_comsv_setting";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
    try {
      DeviceEdgeOrderRequest targetInfo = request;
      if (request.getFacilityCd() == null || Objects.equals(request.getFacilityCd(), "")
          || request.getDeviceEdgeNo() == null) {
        targetInfo = deviceEdgeOrderService.findMissingData(request);
      }
      res = sendMessageToComServer(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(),
          WebSocketTopic.ComSv.RELOAD_COMSV_SETTING, "");

    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (request != null && request.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(request.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      res.isSuccess = false;
      res.errorMessage = e.getMessage();
    }
    if (res.isSuccess) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } else {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 愁訴処置マスタ更新指示
   */
  @PostMapping("/reload_complaint_master")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<?> PostOrderReloadTreatMaster(@RequestBody DeviceEdgeOrderRequest request) {
// #9698 アプリケーションログの内容修正 20260401 mod yangxuewang end
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_ORDER + "/reload_complaint_master";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
    try {
      DeviceEdgeOrderRequest targetInfo = request;
      if (request.getFacilityCd() == null || Objects.equals(request.getFacilityCd(), "")
          || request.getDeviceEdgeNo() == null) {
        targetInfo = deviceEdgeOrderService.findMissingData(request);
      }
      res = sendMessageToComServer(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(),
          WebSocketTopic.ComSv.RELOAD_TREAT_MASTER, "");

    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (request != null && request.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(request.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      res.isSuccess = false;
      res.errorMessage = e.getMessage();
    }
    if (res.isSuccess) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } else {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * スタッフマスタ更新指示
   */
  @PostMapping("/reload_staff_master")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<?> PostOrderReloadStaffMaster(@RequestBody DeviceEdgeOrderRequest request) {
// #9698 アプリケーションログの内容修正 20260401 mod yangxuewang end
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_ORDER + "/reload_staff_master";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
    try {
      DeviceEdgeOrderRequest targetInfo = request;
      if (request.getFacilityCd() == null || Objects.equals(request.getFacilityCd(), "")
          || request.getDeviceEdgeNo() == null) {
        targetInfo = deviceEdgeOrderService.findMissingData(request);
      }
      res = sendMessageToComServer(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(),
          WebSocketTopic.ComSv.RELOAD_STAFF_MASTER, "");

    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (request != null && request.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(request.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      res.isSuccess = false;
      res.errorMessage = e.getMessage();
    }
    if (res.isSuccess) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } else {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 未登録患者割付
   */
  @PostMapping("/set_unknown_pat")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<?> PostOrderSetUnknownPat(@RequestBody DeviceEdgeOrderRequest request) {
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang end
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_ORDER + "/set_unknown_pat";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
    try {
      DeviceEdgeOrderRequest targetInfo = deviceEdgeOrderService.findMissingData(request);
      String machineInfo = PayloadBuilder.BuildMachineAndOrdNoPayload(request.getMachineNo(), request.getOrdNo());

      res = sendMessageToComServer(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(),
          WebSocketTopic.ComSv.SET_UNKNOWN_PAT, machineInfo);

    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (request != null && request.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(request.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      res.isSuccess = false;
      res.errorMessage = e.getMessage();
    }
    if (res.isSuccess) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } else {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 条件送信キャンセル指示
   */
  @PostMapping("/cancel_condition")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<?> PostOrderCancelCondition(@RequestBody DeviceEdgeOrderRequest request) {
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang end
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_ORDER + "/cancel_condition";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End


    DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
    try {
      DeviceEdgeOrderRequest targetInfo = deviceEdgeOrderService.findMissingData(request);
      String machineInfo = request.getMachineNo().toString();

      res = sendMessageToComServer(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(),
          WebSocketTopic.ComSv.CANCEL_CONDITION, machineInfo);

    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (request != null && request.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(request.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      res.isSuccess = false;
      res.errorMessage = e.getMessage();
    }
    if (res.isSuccess) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } else {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 投薬指示変更指示
   */
  @PostMapping("/change_ind_medi")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<?> PostOrderChangeIndMedi(@RequestBody DeviceEdgeOrderRequest request) {
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang end
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_ORDER + "/change_ind_medi";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End


    DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
    try {
      DeviceEdgeOrderRequest targetInfo = deviceEdgeOrderService.findMissingData(request);
      String machineInfo = PayloadBuilder.BuildMachineAndOrdNoPayload(request.getMachineNo(), request.getOrdNo());

      res = sendMessageToComServer(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(),
          WebSocketTopic.ComSv.CHANGE_IND_MEDI, machineInfo);

    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
  	  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (request != null && request.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(request.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
  	  logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      res.isSuccess = false;
      res.errorMessage = e.getMessage();
    }
    if (res.isSuccess) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } else {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 後体重測定指示
   */
  @PostMapping("/after_weight")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<?> PostOrderAfterWeight(@RequestBody DeviceEdgeOrderRequest request) {
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang end
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_ORDER + "/after_weight";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
    try {
      DeviceEdgeOrderRequest targetInfo = deviceEdgeOrderService.findMissingData(request);
      String machineInfo = request.getMachineNo().toString();

      res = sendMessageToComServer(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(),
          WebSocketTopic.ComSv.AFTER_WEIGHT, machineInfo);

    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (request != null && request.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(request.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      res.isSuccess = false;
      res.errorMessage = e.getMessage();
    }
    if (res.isSuccess) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } else {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 治療状況確認指示
   */
  @PostMapping("/check_status")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<?> PostOrderCheckStatus(@RequestBody DeviceEdgeOrderRequest request) {
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang end
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_ORDER + "/check_status";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End


    DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
    try {
      DeviceEdgeOrderRequest targetInfo = deviceEdgeOrderService.findMissingData(request);
      String machineInfo = request.getMachineNo().toString();

      res = sendMessageToComServer(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(),
          WebSocketTopic.ComSv.CHECK_STATUS, machineInfo);

    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (request != null && request.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(request.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      res.isSuccess = false;
      res.errorMessage = e.getMessage();
    }
    if (res.isSuccess) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } else {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
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
