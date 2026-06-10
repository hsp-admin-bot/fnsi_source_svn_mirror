package jp.co.nikkiso.ntss.device_edge.web.rest;

import java.io.IOException;
import java.net.URISyntaxException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;

import com.google.common.base.Strings;
import io.micrometer.core.instrument.util.StringUtils;
import jp.co.nikkiso.ntss.core.dao.ComsvOrdMainDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.TmpCommFailureRecoveryDao;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.TmpCommFailureRecovery;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvOrdMain;
import jp.co.nikkiso.ntss.device_edge.constant.Constant;
import jp.co.nikkiso.ntss.device_edge.request.deviceEdgeOrder.DeviceEdgeOrderRequest;
import jp.co.nikkiso.ntss.device_edge.response.deviceEdgeOrder.DeviceEdgeOrderResponse;
import jp.co.nikkiso.ntss.device_edge.response.sendConditionCancel.SendConditionCancelResponse;
import jp.co.nikkiso.ntss.device_edge.service.ComsvOrdMainService;
import jp.co.nikkiso.ntss.device_edge.service.ComsvReloadNextPatServiceImpl;
import jp.co.nikkiso.ntss.device_edge.service.LogService;
import jp.co.nikkiso.ntss.device_edge.service.MntMachineStateService;
import jp.co.nikkiso.ntss.device_edge.service.TmpCommFailureRecoverySevice;
import jp.co.nikkiso.ntss.device_edge.service.deviceEdgeOrder.DeviceEdgeOrderService;
import jp.co.nikkiso.ntss.device_edge.service.sendConditionCancel.SendConditionCancelService;
import jp.co.nikkiso.ntss.device_edge.service.webSocketNotify.PayloadBuilder;
import jp.co.nikkiso.ntss.device_edge.service.webSocketNotify.WebSocketNotifyService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvMntMachineState;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.device_edge.service.webSocketNotify.WebSocketNotifyService.SendTarget;

@RestController
@RequestMapping("/api/comsv_state")

public class ComsvMntMachineStateResource {

  @Autowired
  private LogService logService;

  /**
   * 通信サーバ用装置状態管理
   */
  @Autowired
  private MntMachineStateService comsvMntMachineStateService;

  @Autowired
  WebSocketNotifyService sendWsMsg;

  // add AWSとDEの通信断からの復旧 --趙-- start
  /**
   * 通信サーバ用装置状態管理(AWSとDEの通信断からの復旧)
   */
  @Autowired
  private TmpCommFailureRecoverySevice tmpCommFailureRecoverySevice;
  // add AWSとDEの通信断からの復旧 --趙-- end

  // add AWSとDEの通信断からの復旧 --高-- start
  @Autowired
  private TmpCommFailureRecoveryDao tmpCommFailureRecoveryDao;
  // add AWSとDEの通信断からの復旧 --高-- end
  // add 10964 ????患者が作成された際にチェックリストマスタのデータが取得できていない。 関  start
  @Autowired
  MntMachineStateService mntMachineStateService;

  @Autowired
  ComsvOrdMainDao comsvOrdMainDao;

  @Autowired
  SendConditionCancelService sendConditionCancelService;

  @Autowired
  MstMachineDao mstMachineDao;

  @Autowired
  ComsvOrdMainService comsvOrdMainService;

  @Autowired
  OrdMainDao ordMainDao;

  @Autowired
  private ComsvReloadNextPatServiceImpl comsvReloadNextPatServiceImpl;
  // add 10964 ????患者が作成された際にチェックリストマスタのデータが取得できていない。 関  end

  /**
   * 通信サーバ用装置状態管理の取得（施設の装置全て）
   */
  @GetMapping("/all/{facility_cd}")
  public ResponseEntity<?> getComsvStateAll(
      @PathVariable(name = "facility_cd", required = false) String facility_cd) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("API getComsvStateAll CALLED = " + facility_cd);
      eventLogMessage.setFacilityCd(facility_cd);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    if (!Objects.equals(facility_cd, "")) {
      List<ComsvMntMachineState> res = comsvMntMachineStateService.selectByFacilityCd(facility_cd);
      eventLogMessage.setLogMessage("O K getComsvStateAll");
      eventLogMessage.setFacilityCd(facility_cd);
  	  logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return new ResponseEntity<>(res, HttpStatus.OK);
    } else {
      eventLogMessage.setLogMessage("ERROR getComsvStateAll");
      eventLogMessage.setFacilityCd(facility_cd);
  	  logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 通信サーバ用装置状態管理の取得（対象の装置）
   */
  @GetMapping("/{facility_cd}/{machine_type_cd}/{machine_serial}")
  public ResponseEntity<?> getComsvState(
      @PathVariable(name = "facility_cd", required = false) String facility_cd,
      @PathVariable(name = "machine_type_cd", required = false) String machine_type_cd,
      @PathVariable(name = "machine_serial", required = false) String machine_serial) {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("API getComsvState CALLED = " + facility_cd + " " + machine_type_cd + " " + machine_serial);
    eventLogMessage.setFacilityCd(facility_cd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    if (!Objects.equals(facility_cd, "") && !Objects.equals(machine_type_cd, "")
        && !Objects.equals(machine_serial, "")) {
      ComsvMntMachineState res = comsvMntMachineStateService.selectMachineKey(facility_cd, machine_type_cd,
          machine_serial);
      eventLogMessage.setLogMessage("O K getComsvState");
      eventLogMessage.setFacilityCd(facility_cd);
  	  logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return new ResponseEntity<>(res, HttpStatus.OK);
    } else {
      eventLogMessage.setLogMessage("ERROR getComsvState");
      eventLogMessage.setFacilityCd(facility_cd);
  	  logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 通信サーバ用装置状態管理の条件送信日時更新
   * @param facility_cd
   * @param machine_type_cd
   * @param machine_serial
   * @param cond_send_date
   * @return
   * @throws ParseException
   */
  @PutMapping("/cond_send/{facility_cd}/{machine_type_cd}/{machine_serial}/{machine_status}/{cond_send_date}")
  public ResponseEntity<Void> updateCondSend(
      @PathVariable(name = "facility_cd", required = false) String facility_cd,
      @PathVariable(name = "machine_type_cd", required = false) String machine_type_cd,
      @PathVariable(name = "machine_serial", required = false) String machine_serial,
      @PathVariable("machine_status") int machine_status,
      @PathVariable(name = "cond_send_date", required = false) String cond_send_date) throws ParseException {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("API cond_send CALLED = " + facility_cd + " " + machine_type_cd + " " + machine_serial + " " + cond_send_date);
    eventLogMessage.setFacilityCd(facility_cd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    MntMachineState state = new MntMachineState();
    state.setFacilityCd(facility_cd);
    state.setMachineTypeCd(machine_type_cd);
    state.setMachineSerial(machine_serial);
    state.setMachineStatus(machine_status);
    if (cond_send_date.equals("null")) {
      state.setCondSendDate(null);
    } else {
      Timestamp sendTime = new Timestamp(new SimpleDateFormat("yyyyMMddHHmmss").parse(cond_send_date).getTime());
      state.setCondSendDate(sendTime);
    }
    int ret = comsvMntMachineStateService.updateCondSend(state);
    if (ret > 0) {
      // #8732 2023.06.06 add ログ強化 TDC片口 start
      eventLogMessage.setLogMessage("API cond_send success.");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // #8732 2023.06.06 add ログ強化 TDC片口 end
      return ResponseEntity.ok().build();
    } else {
      // #8732 2023.06.06 add ログ強化 TDC片口 start
      eventLogMessage.setLogMessage("API cond_send error.");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // #8732 2023.06.06 add ログ強化 TDC片口 end
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return ResponseEntity.badRequest().build();
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }
  }

  // add  装置のSTATUS状態更新方法の変更 --趙-- start
  /**
   * 通信サーバ用装置状態
   *
   * @param facility_cd
   * @param machine_type_cd
   * @param machine_serial
   * @return
   * @throws ParseException
   */
  @PutMapping("/updateMachineState/{facility_cd}/{machine_type_cd}/{machine_serial}/{machine_status}")
  public ResponseEntity<Void> updateMachineState(
    @PathVariable(name = "facility_cd", required = false) String facility_cd,
    @PathVariable(name = "machine_type_cd", required = false) String machine_type_cd,
    @PathVariable(name = "machine_serial", required = false) String machine_serial,
    @PathVariable("machine_status") int machine_status) throws ParseException {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("MACHINE STATUS CALLED = " + facility_cd + " " + machine_type_cd + " " + machine_serial);
    eventLogMessage.setFacilityCd(facility_cd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    MntMachineState state = new MntMachineState();
    state.setFacilityCd(facility_cd);
    state.setMachineTypeCd(machine_type_cd);
    state.setMachineSerial(machine_serial);
    state.setMachineStatus(machine_status);
    int ret = comsvMntMachineStateService.updateMachineState(state);
    // add  FNSI-画面リロードの修正 徐 start
    MntMachineState machineState = comsvMntMachineStateService.selectMachineState(state);
    String statusOrdNo = machine_status
      + "," + machineState.getOrdNo()
      + "," + machineState.getModel()
      + "," + machineState.getMachineSerial();
    if (ret > 0) {
      String topic = PayloadBuilder.BuildSendConditionResultTopic(Constant.WebSocketTopic.WeightState.MACHINE_RESULT, facility_cd);
      String payload = statusOrdNo;
      // ブラウザあてにWebsocket通知
      Boolean bres = false;
      if (sendWsMsg.sendMsg(SendTarget.browser, facility_cd, null, topic, payload)) {
        bres = true;
      }
      eventLogMessage.setLogMessage("Websocket通知 = " + bres);
      eventLogMessage.setFacilityCd(facility_cd);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
      // add  FNSI-画面リロードの修正 徐 end
      return ResponseEntity.ok().build();
    } else {
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return ResponseEntity.badRequest().build();
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }
  }
  // add 装置のSTATUS状態更新方法の変更 --趙-- end

  /**
   * 通信サーバ用装置状態管理の条件確認日時更新
   * @param facility_cd
   * @param machine_type_cd
   * @param machine_serial
   * @param cond_set_date
   * @return
   * @throws ParseException
   */
  @PutMapping("/cond_set/{facility_cd}/{machine_type_cd}/{machine_serial}/{machine_status}/{cond_set_date}")
  public ResponseEntity<Void> updateCondSet(
      @PathVariable(name = "facility_cd", required = false) String facility_cd,
      @PathVariable(name = "machine_type_cd", required = false) String machine_type_cd,
      @PathVariable(name = "machine_serial", required = false) String machine_serial,
      @PathVariable("machine_status") int machine_status,
      @PathVariable(name = "cond_set_date", required = false) String cond_set_date) throws ParseException {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("API cond_set CALLED = " + facility_cd + " " + machine_type_cd + " " + machine_serial + " " + cond_set_date);
    eventLogMessage.setFacilityCd(facility_cd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    MntMachineState state = new MntMachineState();
    state.setFacilityCd(facility_cd);
    state.setMachineTypeCd(machine_type_cd);
    state.setMachineSerial(machine_serial);
    state.setMachineStatus(machine_status);
    if (cond_set_date.equals("null")) {
      state.setCondSetDate(null);
      state.setIsPatVerified("0");
    } else {
      Timestamp setTime = new Timestamp(new SimpleDateFormat("yyyyMMddHHmmss").parse(cond_set_date).getTime());
      state.setCondSetDate(setTime);
      state.setIsPatVerified("1");
    }
    int ret = comsvMntMachineStateService.updateCondSet(state);
    if (ret > 0) {
      // #8732 2023.06.06 add ログ強化 TDC片口 start
      eventLogMessage.setLogMessage("API cond_set success.");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // #8732 2023.06.06 add ログ強化 TDC片口 end
      return ResponseEntity.ok().build();
    } else {
      // #8732 2023.06.06 add ログ強化 TDC片口 start
      eventLogMessage.setLogMessage("API cond_set error.");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // #8732 2023.06.06 add ログ強化 TDC片口 end
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return ResponseEntity.badRequest().build();
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }
  }

  /**
   * 通信サーバ用装置状態管理の透析開始日時更新
   * @param facility_cd
   * @param machine_type_cd
   * @param machine_serial
   * @param machine_status
   * @param start_date
   * @return
   * @throws ParseException
   */
  @PutMapping("/dial_start/{facility_cd}/{machine_type_cd}/{machine_serial}/{machine_status}/{start_date}")
  public ResponseEntity<Void> updateDialStart(
      @PathVariable(name = "facility_cd", required = false) String facility_cd,
      @PathVariable(name = "machine_type_cd", required = false) String machine_type_cd,
      @PathVariable(name = "machine_serial", required = false) String machine_serial,
      @PathVariable("machine_status") int machine_status,
      @PathVariable(name = "start_date", required = false) String start_date) throws ParseException {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("API dial_start CALLED = " + facility_cd + " " + machine_type_cd + " " + machine_serial + " " + machine_status
            + " " + start_date);
    eventLogMessage.setFacilityCd(facility_cd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    MntMachineState state = new MntMachineState();
    state.setFacilityCd(facility_cd);
    state.setMachineTypeCd(machine_type_cd);
    state.setMachineSerial(machine_serial);
    state.setMachineStatus(machine_status);
    if (start_date.equals("null")) {
      state.setStartDate(null);
    } else {
      Timestamp startTime = new Timestamp(new SimpleDateFormat("yyyyMMddHHmmss").parse(start_date).getTime());
      state.setStartDate(startTime);
    }
    int ret = comsvMntMachineStateService.updateDialStart(state);
    if (ret > 0) {
      // #8732 2023.06.06 add ログ強化 TDC片口 start
      eventLogMessage.setLogMessage("API dial_start success.");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // #8732 2023.06.06 add ログ強化 TDC片口 end
      return ResponseEntity.ok().build();
    } else {
      // #8732 2023.06.06 add ログ強化 TDC片口 start
      eventLogMessage.setLogMessage("API dial_start error.");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // #8732 2023.06.06 add ログ強化 TDC片口 end
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return ResponseEntity.badRequest().build();
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }
  }

  /**
   * 通信サーバ用装置状態管理の透析終了日時更新
   * @param facility_cd
   * @param machine_type_cd
   * @param machine_serial
   * @param machine_status
   * @param end_date
   * @return
   * @throws ParseException
   */
  @PutMapping("/dial_end/{facility_cd}/{machine_type_cd}/{machine_serial}/{machine_status}/{end_date}")
  public ResponseEntity<Void> updateDialEnd(
      @PathVariable(name = "facility_cd", required = false) String facility_cd,
      @PathVariable(name = "machine_type_cd", required = false) String machine_type_cd,
      @PathVariable(name = "machine_serial", required = false) String machine_serial,
      @PathVariable("machine_status") int machine_status,
      @PathVariable(name = "end_date", required = false) String end_date) throws ParseException {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("API dial_end CALLED = " + facility_cd + " " + machine_type_cd + " " + machine_serial + " " + machine_status
    + " " + end_date);
    eventLogMessage.setFacilityCd(facility_cd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    MntMachineState state = new MntMachineState();
    state.setFacilityCd(facility_cd);
    state.setMachineTypeCd(machine_type_cd);
    state.setMachineSerial(machine_serial);
    state.setMachineStatus(machine_status);
    if (end_date.equals("null")) {
      state.setEndDate(null);
    } else {
      Timestamp endTime = new Timestamp(new SimpleDateFormat("yyyyMMddHHmmss").parse(end_date).getTime());
      state.setEndDate(endTime);
    }
    int ret = comsvMntMachineStateService.updateDialEnd(state);
    if (ret > 0) {
      // #8732 2023.06.06 add ログ強化 TDC片口 start
      eventLogMessage.setLogMessage("API dial_end success.");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // #8732 2023.06.06 add ログ強化 TDC片口 end
      return ResponseEntity.ok().build();
    } else {
      // #8732 2023.06.06 add ログ強化 TDC片口 start
      eventLogMessage.setLogMessage("API dial_end error.");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // #8732 2023.06.06 add ログ強化 TDC片口 end
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return ResponseEntity.badRequest().build();
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }
  }

  /**
   * 通信サーバ用装置状態管理の装置ステータス一括更新
   * @param facility_cd
   * @param body
   */
  @PostMapping("/all_status/{facility_cd}")
  public HttpStatus Response(
	  @PathVariable(name = "facility_cd", required = false) String facility_cd,
      @RequestBody String body) throws ParseException {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("API all_status CALLED = " + facility_cd + " body = [" + body + "]");
    eventLogMessage.setFacilityCd(facility_cd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    int ret = comsvMntMachineStateService.updateAllStatus(facility_cd, body);
    if (ret > 0) {
      // #8732 2023.06.06 add ログ強化 TDC片口 start
      eventLogMessage.setLogMessage("API all_status success.");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // #8732 2023.06.06 add ログ強化 TDC片口 end
      return HttpStatus.OK;
    } else {
      // #8732 2023.06.06 add ログ強化 TDC片口 start
      eventLogMessage.setLogMessage("API all_status error.");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // #8732 2023.06.06 add ログ強化 TDC片口 end
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return HttpStatus.BAD_REQUEST;
      return HttpStatus.INTERNAL_SERVER_ERROR;
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }
  }

  // add AWSとDEの通信断からの復旧 --趙-- start
  /**
   * 通信サーバ用装置状態管理の取得（対象の装置)(AWSとDEの通信断からの復旧)
   */
  @GetMapping("/getComsvState_commfail/{facility_cd}/{machine_type_cd}/{machine_serial}")
  public ResponseEntity<?> getComsvStateCommFail(
    @PathVariable(name = "facility_cd", required = false) String facility_cd,
    @PathVariable(name = "machine_type_cd", required = false) String machine_type_cd,
    @PathVariable(name = "machine_serial", required = false) String machine_serial) {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("API GET CALLED = " + facility_cd + " " + machine_type_cd + " " + machine_serial);
    eventLogMessage.setFacilityCd(facility_cd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    if (!Objects.equals(facility_cd, "") && !Objects.equals(machine_type_cd, "")
      && !Objects.equals(machine_serial, "")) {
      TmpCommFailureRecovery res = tmpCommFailureRecoverySevice.selectMachineKeyCommFail(facility_cd, machine_type_cd,
        machine_serial);
      if(res != null) {
        eventLogMessage.setLogMessage("O K");
        eventLogMessage.setFacilityCd(facility_cd);
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
        return new ResponseEntity<>(res, HttpStatus.OK);
      }else{
        eventLogMessage.setLogMessage("ERROR");
        eventLogMessage.setFacilityCd(facility_cd);
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
        return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      }
    } else {
      eventLogMessage.setLogMessage("ERROR");
      eventLogMessage.setFacilityCd(facility_cd);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 通信サーバ用装置状態管理の取得（対象の装置)(AWSとDEの通信断からの復旧)
   */
  @PutMapping("/updateMachineState_commfail/{facility_cd}/{machine_type_cd}/{machine_serial}/{ord_no}/{pat_id}/{next_ord_no}/{next_pat_id}/{start_date}/{end_date}/{machine_status}")
  public ResponseEntity<?> updateMachineStateCommFail(
    @PathVariable(name = "facility_cd", required = false) String facilityCd,
    @PathVariable(name = "machine_type_cd", required = false) String machineTypeCd,
    @PathVariable(name = "machine_serial", required = false) String machineSerial,
    @PathVariable(name = "ord_no", required = false) Long ordNo,
    @PathVariable(name = "pat_id", required = false) Long patId,
    @PathVariable(name = "next_ord_no", required = false) Long nextOrdNo,
    @PathVariable(name = "next_pat_id", required = false) Long nextPatId,
    @PathVariable(name = "start_date", required = false) String startDate,
    @PathVariable(name = "end_date", required = false) String endDate,
    @PathVariable(name = "machine_status", required = false) Integer machineStatus
  ) throws ParseException {

      int ret = 0;
      EventLogMessage eventLogMessage = new EventLogMessage();

      if(Strings.isNullOrEmpty(facilityCd) || Strings.isNullOrEmpty(machineTypeCd) || Strings.isNullOrEmpty(machineSerial)){
        eventLogMessage.setLogMessage("updateMachineStateCommFail parameter error = " + "facilityCd=" + facilityCd + " " + "machineTypeCd ="+ machineTypeCd + " " + "machineSerial ="+ machineSerial);
        // #8732 2023.06.06 add ログ強化 TDC片口 start
        if (!Strings.isNullOrEmpty(facilityCd)) {
          eventLogMessage.setFacilityCd(facilityCd);
        }
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        // #8732 2023.06.06 add ログ強化 TDC片口 end
        return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      }
      // #8732 2023.06.06 add ログ強化 TDC片口 start
      eventLogMessage.setFacilityCd(facilityCd);
      eventLogMessage.setLogMessage("updateMachineStateCommFail start = " + "facilityCd=" + facilityCd + " " + "machineTypeCd ="+ machineTypeCd + " " + "machineSerial ="+ machineSerial);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // #8732 2023.06.06 add ログ強化 TDC片口 end
      // add 10964 ????患者が作成された際にチェックリストマスタのデータが取得できていない。 関  start
      // 装置番号から装置マスタ情報を取得
      MstMachine machine = null;
      machine = mstMachineDao.selectByCd(machineTypeCd, machineSerial, facilityCd);
      // 装置治療状態取得
      MntMachineState state = mntMachineStateService.selectByKey(machine.getFacilityCd(),
        machine.getMachineTypeCd(),
        machine.getMachineSerial());
      // add 10964 ????患者が作成された際にチェックリストマスタのデータが取得できていない。 関  start
      Long machineStateOrdNo = 0L;
      // add 10964 ????患者が作成された際にチェックリストマスタのデータが取得できていない。 関  end
      if (machine != null) {
        if (state != null) {
          // 現患者判定
          machineStateOrdNo = state.getOrdNo();
          if (machineStateOrdNo != null && !Objects.equals(machineStateOrdNo, ordNo)) {
            ComsvOrdMain ordMain = comsvOrdMainDao.selectByNo(machineStateOrdNo);
            if (ordMain != null) {
              if (Objects.equals(ordMain.getDialState(), Constant.OrdMainConst.DialysisState.AFTER_SEND)
                || Objects.equals(ordMain.getDialState(), Constant.OrdMainConst.DialysisState.CHECKED_SEND)) {
                // 治療状況が治療前(1,2)の場合、条件送信キャンセルを行う(DB更新のみ)
                SendConditionCancelResponse res = new SendConditionCancelResponse();
                try {
                  res = sendConditionCancelService.DoCancelDBAction(machineStateOrdNo, machine);
                } catch (Exception ex){
                  res.isSuccess = false;
                  res.errorMessage = ex.getMessage();
                  res.ex = ex;
                }
                if (!res.isSuccess) {
                  // 条件送信キャンセル失敗
                  eventLogMessage.setLogMessage("API updateMachineState_commfail DoCancelDBAction failed. error:" + res.errorMessage);
                  eventLogMessage.setMachineTypeCd(machine.getMachineTypeCd());
                  eventLogMessage.setPatId(patId.toString());
                  eventLogMessage.setSqlIdentification("ordNo = " + machineStateOrdNo + ",machine = " + machine);
                  eventLogMessage.setFacilityCd(machine.getFacilityCd());
                  logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
                }
              }
              else if (Objects.equals(ordMain.getDialState(), Constant.OrdMainConst.DialysisState.DIALYSIS)) {
                // 治療状況が治療中(3)の場合、治療終了処理を行う
                ordMain.setDialState(Constant.OrdMainConst.DialysisState.AFTER_DIALYSIS);
                Timestamp nowTime = Timestamp.valueOf(LocalDateTime.now());
                ordMain.setEndDate(nowTime);
                ret = comsvOrdMainService.updateEndDate(ordMain);
                if (ret <= 0) {
                  eventLogMessage.setLogMessage("治療終了処理失敗");
                  eventLogMessage.setFacilityCd(ordMain.getFacilityCd());
                  logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
                }
              }
            }
          }
        }
      }
      // add 10964 ????患者が作成された際にチェックリストマスタのデータが取得できていない。 関  end

      MntMachineState mntMachineState = new MntMachineState();
      mntMachineState.setFacilityCd(facilityCd);
      mntMachineState.setMachineTypeCd(machineTypeCd);
      mntMachineState.setMachineSerial(machineSerial);
      if(ordNo == 0)
        mntMachineState.setOrdNo(null);
      else
        mntMachineState.setOrdNo(ordNo);
      if(patId == 0)
        mntMachineState.setPatId(null);
      else
        mntMachineState.setPatId(patId);
      if(nextOrdNo == 0)
        mntMachineState.setNextOrdNo(null);
      else
        mntMachineState.setNextOrdNo(nextOrdNo);
      if(nextPatId == 0)
        mntMachineState.setNextPatid(null);
      else
        mntMachineState.setNextPatid(nextPatId);

      try{
          if (Strings.isNullOrEmpty(startDate) || startDate.equals("null")) {
            mntMachineState.setStartDate(null);
          } else {
            Timestamp startTime = new Timestamp(new SimpleDateFormat("yyyyMMddHHmmss").parse(startDate).getTime());
            mntMachineState.setStartDate(startTime);
          }

          if (Strings.isNullOrEmpty(endDate) || endDate.equals("null")) {
            mntMachineState.setEndDate(null);
          } else {
            Timestamp endTime = new Timestamp(new SimpleDateFormat("yyyyMMddHHmmss").parse(endDate).getTime());
            mntMachineState.setEndDate(endTime);
          }
        } catch (ParseException e) {
          eventLogMessage.setLogMessage("updateMachineState_commfail parameter startDate = " + startDate);
          // #8732 2023.06.06 add ログ強化 TDC片口 start
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          // #8732 2023.06.06 add ログ強化 TDC片口 end
          eventLogMessage.setLogMessage("updateMachineState_commfail parameter endDate = " + endDate);
          // #8732 2023.06.06 add ログ強化 TDC片口 start
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          // #8732 2023.06.06 add ログ強化 TDC片口 end
          return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }

        mntMachineState.setMachineStatus(machineStatus);
        mntMachineState.setNextKurCd(null);
        mntMachineState.setStartPlanDate(null);
        mntMachineState.setEndPlanDate(null);
        mntMachineState.setWeighBeforeDate(null);
        mntMachineState.setCondSendDate(null);
        mntMachineState.setCondSetDate(null);
        mntMachineState.setWeighAfterDate(null);
        mntMachineState.setTmpDeviceSetInfo(null);
        //add redmine #4863 劉 start
        mntMachineState.setIsPatVerified("0");
        //add redmine #4863 劉 end

      ret = comsvMntMachineStateService.updateMachineStateCommFail(mntMachineState);
      if(ret < 0){
        eventLogMessage.setFacilityCd(facilityCd);
        eventLogMessage.setLogMessage("updateMachineStateCommFail error.");
        // #8732 2023.06.06 add ログ強化 TDC片口 start
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        // #8732 2023.06.06 add ログ強化 TDC片口 end

        // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
        //return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
      }
      // add 10964 ????患者が作成された際にチェックリストマスタのデータが取得できていない。 関  start
      if (!Objects.equals(machineStateOrdNo, ordNo)) {
        ComsvOrdMain ordMain = comsvOrdMainDao.selectByNo(ordNo);
        // #11168 2024.10.11 mod 対象オーダーの有無確認 TDC片口 start
//        Integer dialState = !StringUtils.isBlank(ordMain.getDialState()) ? Integer.parseInt(ordMain.getDialState()) : -1;
        int dialState = (ordMain != null && !StringUtils.isBlank(ordMain.getDialState())) ? Integer.parseInt(ordMain.getDialState()) : -1;
        // #11168 2024.10.11 mod 対象オーダーの有無確認 TDC片口 end
        if (dialState >= 4) {
          try {
            comsvReloadNextPatServiceImpl.reloadNoNextPat(facilityCd, machineTypeCd, machineSerial);


            MstMachine mstMachineInfo = mstMachineDao.selectByCd(machineTypeCd, machineSerial, facilityCd);

            Integer deviceEdgeNo = mstMachineInfo.getDeviceEdgeNo();
            Long machineNo = mstMachineInfo.getMachineNo();

            DeviceEdgeOrderRequest deviceEdgeOrder = new DeviceEdgeOrderRequest();
            deviceEdgeOrder.setFacilityCd(facilityCd);
            deviceEdgeOrder.setDeviceEdgeNo(deviceEdgeNo);
            deviceEdgeOrder.setMachineNo(machineNo);

            this.PostOrderSendNextPat(deviceEdgeOrder);

          }catch (IOException | URISyntaxException e) {
            eventLogMessage.setFacilityCd(facilityCd);
            eventLogMessage.setLogMessage("callWebApiNextPat error.");
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
          }
        }
      }
      // add 10964 ????患者が作成された際にチェックリストマスタのデータが取得できていない。 関  end
      // #8732 2023.06.06 add ログ強化 TDC片口 start
      eventLogMessage.setLogMessage("updateMachineStateCommFail success.");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // #8732 2023.06.06 add ログ強化 TDC片口 end

      return new ResponseEntity<>(HttpStatus.OK);
  }

  // add 10964 ????患者が作成された際にチェックリストマスタのデータが取得できていない。 関  start
  @Autowired
  DeviceEdgeOrderService deviceEdgeOrderService;

  ResponseEntity<?> PostOrderSendNextPat(DeviceEdgeOrderRequest request) {

    DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
    try {
      DeviceEdgeOrderRequest targetInfo = deviceEdgeOrderService.findMissingData(request);
      String machineInfo = PayloadBuilder.BuildMachineAndOrdNoPayload(request.getMachineNo(), request.getOrdNo());

      res = sendMessageToComServer(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(),
        Constant.WebSocketTopic.ComSv.SEND_NEXT_PAT, machineInfo);

    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(e.getMessage());
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      res.isSuccess = false;
      res.errorMessage = e.getMessage();
    }
    if (res.isSuccess) {
      return new ResponseEntity<>(res, HttpStatus.OK);
    } else {
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }

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
  // add 10964 ????患者が作成された際にチェックリストマスタのデータが取得できていない。 関  end

  /**
   * 通信サーバ用装置状態管理の取得（対象の装置)(AWSとDEの通信断からの復旧)
   */
  @PutMapping("/updateProcessState_commfail/{facility_cd}/{machine_type_cd}/{machine_serial}/{process_state}")
  public ResponseEntity<?> updateProcessState(
    @PathVariable(name = "facility_cd", required = false) String facilityCd,
    @PathVariable(name = "machine_type_cd", required = false) String machineTypeCd,
    @PathVariable(name = "machine_serial", required = false) String machineSerial,
    @PathVariable(name = "process_state", required = false) String processState
  ) {

    int ret = 0;
    Integer isPreventiveMainte = 0;
    EventLogMessage eventLogMessage = new EventLogMessage();

    if(Strings.isNullOrEmpty(facilityCd) || Strings.isNullOrEmpty(machineTypeCd) || Strings.isNullOrEmpty(machineSerial)){
      eventLogMessage.setLogMessage("updateProcessState parameter error = " + "facilityCd=" + facilityCd + " " + "machineTypeCd ="+ machineTypeCd + " " + "machineSerial ="+ machineSerial);
      // #8732 2023.06.06 add ログ強化 TDC片口 start
      if (!Strings.isNullOrEmpty(facilityCd)) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // #8732 2023.06.06 add ログ強化 TDC片口 end
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
    // #8732 2023.06.06 add ログ強化 TDC片口 start
    eventLogMessage.setFacilityCd(facilityCd);
    eventLogMessage.setLogMessage("updateProcessState start = " + "facilityCd=" + facilityCd + " " + "machineTypeCd ="+ machineTypeCd + " " + "machineSerial ="+ machineSerial);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // #8732 2023.06.06 add ログ強化 TDC片口 end

    MntMachineState mntMachineState = new MntMachineState();
    mntMachineState.setFacilityCd(facilityCd);
    mntMachineState.setMachineTypeCd(machineTypeCd);
    mntMachineState.setMachineSerial(machineSerial);
    mntMachineState.setProcessState(processState);

    // 通信不良有無(工程状態が'99'の場合は「1:あり」、それ以外は「0:なし」)
    isPreventiveMainte = ("99".equals(processState)) ? 1 : 0;
    mntMachineState.setIsPreventiveMainte(isPreventiveMainte);

    ret = comsvMntMachineStateService.updateProcessState(mntMachineState);
    if(ret < 0){
      eventLogMessage.setFacilityCd(facilityCd);
      eventLogMessage.setLogMessage("updateProcessState error.");
      // #8732 2023.06.06 add ログ強化 TDC片口 start
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // #8732 2023.06.06 add ログ強化 TDC片口 end
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }
    // #8732 2023.06.06 add ログ強化 TDC片口 start
    eventLogMessage.setLogMessage("updateProcessState success.");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // #8732 2023.06.06 add ログ強化 TDC片口 end

    return new ResponseEntity<>(HttpStatus.OK);
  }

  /**
   * 通信サーバ用装置状態管理の取得（対象の装置)(AWSとDEの通信断からの復旧)
   */
  @PutMapping("/updateTmpCommFailureRecovery_commfail/{facility_cd}/{machine_type_cd}/{machine_serial}/{ord_no}" +
    "/{pat_id}/{next_ord_no}/{next_pat_id}/{start_date}/{end_date}")
  public ResponseEntity<?> updateTmpCommFailureRecoveryCommFail(
    @PathVariable(name = "facility_cd", required = false) String facilityCd,
    @PathVariable(name = "machine_type_cd", required = false) String machineTypeCd,
    @PathVariable(name = "machine_serial", required = false) String machineSerial,
    @PathVariable(name = "ord_no", required = false) Long ordNo,
    @PathVariable(name = "pat_id", required = false) Long patId,
    @PathVariable(name = "next_ord_no", required = false) Long nextOrdNo,
    @PathVariable(name = "next_pat_id", required = false) Long nextPatId,
    @PathVariable(name = "start_date", required = false) String startDate,
    @PathVariable(name = "end_date", required = false) String endDate
  ) throws ParseException {

    int ret = 0;
    EventLogMessage eventLogMessage = new EventLogMessage();

    if(Strings.isNullOrEmpty(facilityCd) || Strings.isNullOrEmpty(machineTypeCd) || Strings.isNullOrEmpty(machineSerial)){
      eventLogMessage.setLogMessage("updateMachineStateCommFail parameter error = " + "facilityCd=" + facilityCd + " " + "machineTypeCd ="+ machineTypeCd + " " + "machineSerial ="+ machineSerial);
      // #8732 2023.06.06 add ログ強化 TDC片口 start
      if (!Strings.isNullOrEmpty(facilityCd)) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // #8732 2023.06.06 add ログ強化 TDC片口 end
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
    // #8732 2023.06.06 add ログ強化 TDC片口 start
    eventLogMessage.setFacilityCd(facilityCd);
    eventLogMessage.setLogMessage("updateMachineStateCommFail start = " + "facilityCd=" + facilityCd + " " + "machineTypeCd ="+ machineTypeCd + " " + "machineSerial ="+ machineSerial);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // #8732 2023.06.06 add ログ強化 TDC片口 end

    TmpCommFailureRecovery tmpCommFailureRecovery = new TmpCommFailureRecovery();
    tmpCommFailureRecovery.setFacilityCd(facilityCd);
    tmpCommFailureRecovery.setMachineTypeCd(machineTypeCd);
    tmpCommFailureRecovery.setMachineSerial(machineSerial);
    if(ordNo == 0)
      tmpCommFailureRecovery.setOrdNo(null);
    else
      tmpCommFailureRecovery.setOrdNo(ordNo);
    if(patId == 0)
      tmpCommFailureRecovery.setPatId(null);
    else
      tmpCommFailureRecovery.setPatId(patId);
    if(nextOrdNo == 0)
      tmpCommFailureRecovery.setNextOrdNo(null);
    else
      tmpCommFailureRecovery.setNextOrdNo(nextOrdNo);
    if(nextPatId == 0)
      tmpCommFailureRecovery.setNextPatid(null);
    else
      tmpCommFailureRecovery.setNextPatid(nextPatId);

    try {
      if (Strings.isNullOrEmpty(startDate) || startDate.equals("null")) {
        tmpCommFailureRecovery.setStartDate(null);
      } else {
        Timestamp startTime = new Timestamp(new SimpleDateFormat("yyyyMMddHHmmss").parse(startDate).getTime());
        tmpCommFailureRecovery.setStartDate(startTime);
      }

      if (Strings.isNullOrEmpty(endDate) || endDate.equals("null")) {
        tmpCommFailureRecovery.setEndDate(null);
      } else {
        Timestamp endTime = new Timestamp(new SimpleDateFormat("yyyyMMddHHmmss").parse(endDate).getTime());
        tmpCommFailureRecovery.setEndDate(endTime);
      }

    } catch (ParseException e){
      eventLogMessage.setLogMessage("updateTmpCommFailureRecoveryCommFail parameter startDate = " + startDate);
      // #8732 2023.06.06 add ログ強化 TDC片口 start
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // #8732 2023.06.06 add ログ強化 TDC片口 end
      eventLogMessage.setLogMessage("updateTmpCommFailureRecoveryCommFail parameter error = " + endDate);
      // #8732 2023.06.06 add ログ強化 TDC片口 start
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // #8732 2023.06.06 add ログ強化 TDC片口 end
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }

    // mod AWSとDEの通信断からの復旧 --高-- start
    TmpCommFailureRecovery state = new TmpCommFailureRecovery();
    state = tmpCommFailureRecoveryDao.selectByKey(facilityCd, machineTypeCd, machineSerial);
    if (state != null) {
      ret = tmpCommFailureRecoverySevice.updateTmpCommFailureRecoveryCommFail(tmpCommFailureRecovery);
    }
    else {
      ret = tmpCommFailureRecoveryDao.insert(tmpCommFailureRecovery);
    }
    // mod AWSとDEの通信断からの復旧 --高-- end
    if(ret < 0){
      eventLogMessage.setFacilityCd(facilityCd);
      eventLogMessage.setLogMessage("updateTmpCommFailureRecoveryCommFail update data error.");
      // #8732 2023.06.06 add ログ強化 TDC片口 start
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // #8732 2023.06.06 add ログ強化 TDC片口 end
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }
    // #8732 2023.06.06 add ログ強化 TDC片口 start
    eventLogMessage.setLogMessage("updateTmpCommFailureRecoveryCommFail success.");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // #8732 2023.06.06 add ログ強化 TDC片口 end

    return new ResponseEntity<>(HttpStatus.OK);
  }

  //add 装置状態管理の削除方法を追加します(AWSとDEの通信断からの復旧) 劉 start
  /**
   * 通信サーバ用装置状態管理の削除（対象の装置)(AWSとDEの通信断からの復旧)
   */
  @PutMapping("/deleteTmpComm_commFail/{facility_cd}/{machine_type_cd}/{machine_serial}")
  public ResponseEntity<?> deleteTmpCommFailureRecovery(
    @PathVariable(name = "facility_cd", required = false) String facilityCd,
    @PathVariable(name = "machine_type_cd", required = false) String machineTypeCd,
    @PathVariable(name = "machine_serial", required = false) String machineSerial
  ) {

    EventLogMessage eventLogMessage = new EventLogMessage();
    if(Strings.isNullOrEmpty(facilityCd) || Strings.isNullOrEmpty(machineTypeCd) || Strings.isNullOrEmpty(machineSerial)){
      eventLogMessage.setLogMessage("deleteTmpCommFailureRecovery parameter error = " + "facilityCd=" + facilityCd + " " + "machineTypeCd ="+ machineTypeCd + " " + "machineSerial ="+ machineSerial);
      // #8732 2023.06.06 add ログ強化 TDC片口 start
      if (!Strings.isNullOrEmpty(facilityCd)) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // #8732 2023.06.06 add ログ強化 TDC片口 end
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
    // #8732 2023.06.06 add ログ強化 TDC片口 start
    eventLogMessage.setFacilityCd(facilityCd);
    eventLogMessage.setLogMessage("deleteTmpCommFailureRecovery start = " + "facilityCd=" + facilityCd + " " + "machineTypeCd ="+ machineTypeCd + " " + "machineSerial ="+ machineSerial);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // #8732 2023.06.06 add ログ強化 TDC片口 end

    int ret = tmpCommFailureRecoverySevice.deleteTmpCommFailureRecoveryByKey(facilityCd, machineTypeCd, machineSerial);
    if(ret < 0){
      eventLogMessage.setFacilityCd(facilityCd);
      eventLogMessage.setLogMessage("deleteTmpCommFailureRecovery error.");
      // #8732 2023.06.06 add ログ強化 TDC片口 start
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // #8732 2023.06.06 add ログ強化 TDC片口 end
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }
    // #8732 2023.06.06 add ログ強化 TDC片口 start
    eventLogMessage.setLogMessage("deleteTmpCommFailureRecovery success.");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // #8732 2023.06.06 add ログ強化 TDC片口 end

    return new ResponseEntity<>(HttpStatus.OK);
  }
  //add 装置状態管理の削除方法を追加します(AWSとDEの通信断からの復旧) 劉 end

  // add AWSとDEの通信断からの復旧 --趙-- end

}
