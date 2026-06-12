package jp.co.nikkiso.ntss.device_edge.service;

import java.io.IOException;
import java.net.URISyntaxException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Objects;

import jp.co.nikkiso.ntss.api.service.conditionSend.ConditionSendResultService;
import jp.co.nikkiso.ntss.core.dao.MntScaleBedStateDao;
import jp.co.nikkiso.ntss.core.entity.MntScaleBedState;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.NotificationDefinition;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.SendCondition.WeightScaleClass;
import jp.co.nikkiso.ntss.core.dao.ComsvOrdMainDao;
import jp.co.nikkiso.ntss.core.dao.ComsvOrdWeightScaleDao;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.OrdWeightScaleDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.OrdWeightScale;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvOrdMain;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvOrdWeightScale;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.device_edge.WebApiCallProperties;
import jp.co.nikkiso.ntss.device_edge.response.comsvSendCondition.ComsvSendConditionResponse;
import jp.co.nikkiso.ntss.device_edge.service.Utility.PatNameInfo;
import jp.co.nikkiso.ntss.device_edge.service.Utility.PatNameUtilityService;
import jp.co.nikkiso.ntss.device_edge.service.indApprove.IndApproveService;
import jp.co.nikkiso.ntss.device_edge.service.webSocketNotify.WebSocketNotifyService;
import jp.co.nikkiso.ntss.device_edge.web.rest.util.WebApiCallCommonUtil;
import lombok.AllArgsConstructor;

@Service
public class ComsvSendConditionServiceImpl implements ComsvSendConditionService {

  /**
   * ObjectMapper.
   */

  @Autowired
  private LogService logService;

  @Autowired
  private ComsvOrdMainDao comsvOrdMainDao;
  @Autowired
  private PatPersonalMainDao patPersonalMainDao;
  @Autowired
  private MntMachineStateDao mntMachineStateDao;
  @Autowired
  private ComsvOrdCheckListService comsvOrdCheckListService;
  @Autowired
  private ComsvOrdWeightScaleDao comsvOrdWeightScaleDao;
  @Autowired
  OrdWeightScaleDao ordWeightScaleDao;
  @Autowired
  WebSocketNotifyService sendWsMsg;

  @Autowired
  IndApproveService indApproveService;
  @Autowired
  PatNameUtilityService patNameUtilityService;

  @Autowired
  WebApiCallProperties webApiCallProperties;
  @Autowired
  WebApiCallCommonUtil webApiCallCommonUtil;

  @Autowired
  ConditionSendResultService conditionSendResultService;
  // #11987 2026.02.16 add スケールベッド状態書込み用 TDC片口 start
  @Autowired
  private MntScaleBedStateDao mntScaleBedStateDao;
  // #11987 2026.02.16 add スケールベッド状態書込み用 TDC片口 end

  @Override
  public int sendConditionProc(String facility_cd, String json) throws ParseException, URISyntaxException, IOException {

    JSONObject receiveData= new JSONObject(json);
    // add #8048 2022/11/16 【デグレ】測定状況が、条件送信が成功しても「条件送信指示中」の表示のままとなる dou start
    ComsvOrdWeightScale scale = new ComsvOrdWeightScale();
    String scale_no = receiveData.get("send_ctrl").toString();
    scale.setWeightScaleNo(Long.parseLong(scale_no));
    scale.setWeightScaleStatus(WeightScaleClass.SEND_OK);
    scale.setMessage(null);
    comsvOrdWeightScaleDao.updateStatus(scale);
    // add #8048 2022/11/16 【デグレ】測定状況が、条件送信が成功しても「条件送信指示中」の表示のままとなる dou end
    int ret;
    String machine_type_cd = receiveData.get("machine_type_cd").toString();
    String machine_serial = receiveData.get("machine_serial").toString();
    String machine_format = receiveData.get("machine_format").toString();
    String send_date = receiveData.get("send_date").toString();
    String dial_status = "1";

    // 装置状態管理の条件送信日時更新
    MntMachineState state = new MntMachineState();
    state.setFacilityCd(facility_cd);
    state.setMachineTypeCd(machine_type_cd);
    state.setMachineSerial(machine_serial);
    String machine_status = receiveData.get("machine_status").toString();
    state.setMachineStatus(Integer.parseInt(machine_status));
    if (send_date.equals("null")) {
      state.setCondSendDate(null);
    } else {
      Timestamp sendTime = new Timestamp(new SimpleDateFormat("yyyyMMddHHmmss").parse(send_date).getTime());
      state.setCondSendDate(sendTime);
    }
    ret = mntMachineStateDao.updateCondSend(state);
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setMachineTypeCd(machine_type_cd);
    eventLogMessage.setLogMessage("装置状態管理の条件送信日時更新 = " + ret);
    eventLogMessage.setFacilityCd(facility_cd);
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end

    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    if ( machine_format.equals("F") || machine_format.equals("V") || machine_format.equals("W") ) {
      // オフライン又は共通プロトコルの場合
      // mod 実績：治療状況（ord_main.rst_dialysis_state）の状態変更 高 start
      // dial_status = "2";
      dial_status = "1";
      // mod 実績：治療状況（ord_main.rst_dialysis_state）の状態変更 高 end
      // 装置状態管理の条件確認日時更新
      if (send_date.equals("null")) {
        state.setCondSetDate(null);
        state.setIsPatVerified("0");
      } else {
        Timestamp setTime = new Timestamp(new SimpleDateFormat("yyyyMMddHHmmss").parse(send_date).getTime());
        state.setCondSetDate(setTime);
        state.setIsPatVerified("1");
      }
      ret = mntMachineStateDao.updateCondSet(state);
      eventLogMessage.setLogMessage("装置状態管理の条件確認日時更新 = " + ret);
      eventLogMessage.setFacilityCd(facility_cd);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }

    // 治療情報の条件送信日時更新
    ComsvOrdMain ord = new ComsvOrdMain();
    String ord_no = receiveData.get("ord_no").toString();
    ord.setOrdNo(Long.parseLong(ord_no));
    ord.setDialState(dial_status);
    if (send_date.equals("null")) {
      ord.setSendDate(null);
    } else {
      Timestamp sendTime = new Timestamp(new SimpleDateFormat("yyyyMMddHHmmss").parse(send_date).getTime());
      ord.setSendDate(sendTime);
    }
    ret = comsvOrdMainDao.updateSendDate(ord);
    eventLogMessage.setLogMessage("治療情報の条件送信日時更新 = " + ret);
    eventLogMessage.setFacilityCd(facility_cd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    //  del 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
    // 条件送信時のチェックリスト実績作成・更新
    //    try {
    //      ChecklistUpdateResponse resChk = comsvOrdCheckListService.createOrdChecklistSendCondition(facility_cd, Long.parseLong(ord_no));
    //      if (resChk.isSuccess) {
    //        eventLogMessage.setLogMessage("チェックリスト実績作成");
    //        eventLogMessage.setSqlIdentification("(facility_cd = " + facility_cd + ",or_no = " + ord_no);
    //        eventLogMessage.setFacilityCd(facility_cd);
    //        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,"comsvOrdCheckListService/createOrdChecklistSendCondition");
    //      } else {
    //        eventLogMessage.setLogMessage("チェックリスト実績作成失敗[" + resChk.errorMessage +"]");
    //        eventLogMessage.setSqlIdentification("(facility_cd = " + facility_cd + ",or_no = " + ord_no);
    //        eventLogMessage.setFacilityCd(facility_cd);
    //        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,"comsvOrdCheckListService/createOrdChecklistSendCondition");
    //      }
    //    } catch (Exception e) {
    //      eventLogMessage.setLogMessage("チェックリスト実績作成エラー[" + e.getMessage() + "]");
    //      eventLogMessage.setFacilityCd(facility_cd);
    //      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    //    }
    //  del 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end

    // 指示展開（WebApi側のREST APIを呼び出す
    ComsvSendConditionResponse resApi = callWebApiSendCond(facility_cd, machine_type_cd, machine_serial);
    // mod #8048 2022/11/16 【デグレ】測定状況が、条件送信が成功しても「条件送信指示中」の表示のままとなる dou start
    //  ComsvOrdWeightScale scale = new ComsvOrdWeightScale();
    //  String scale_no = receiveData.get("send_ctrl").toString();
    //  scale.setWeightScaleNo(Long.parseLong(scale_no));
    //  if ( resApi.isSuccess == true ) {
    //    // 指示展開処理成功
    //    scale.setWeightScaleStatus(WeightScaleClass.SEND_OK);
    //    scale.setMessage(null);
    //  }
    //  else {
    if ( !resApi.isSuccess ) {
    // mod #8048 2022/11/16 【デグレ】測定状況が、条件送信が成功しても「条件送信指示中」の表示のままとなる dou end
      // 指示展開処理失敗
      scale.setWeightScaleStatus(WeightScaleClass.SEND_NG);
      scale.setMessage("指示展開処理失敗:" + (resApi.errorMessage != null ? resApi.errorMessage : "不明なエラー"));
      eventLogMessage.setLogMessage("指示展開処理失敗:" + (resApi.exMessage != null ? resApi.exMessage : "不明なエラー"));
      eventLogMessage.setFacilityCd(facility_cd);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }
    ret = comsvOrdWeightScaleDao.updateStatus(scale);
    eventLogMessage.setLogMessage("体重計測定実績のステータス、メッセージ更新 = " + ret);
    eventLogMessage.setFacilityCd(facility_cd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    if (Objects.equals(scale.getWeightScaleStatus(), WeightScaleClass.SEND_NG.intValue())) {
      // 通知機能を使用してフロントに条件送信失敗を通知する

      try {
        // 通知用の情報収集
        OrdWeightScale ordScale = ordWeightScaleDao.selectByCd(scale.getWeightScaleNo());

        PatNameInfo patNames = patNameUtilityService.fetchPatName(ordScale.getPatId());

        // 変換用JSONデータを作成
        JSONObject replaceData = new JSONObject();

        // 必要なJSONパラメータを追加
        replaceData.put("FACILITYCD", facility_cd);
        replaceData.put("BEDNAME", ordScale.getBedName());
        replaceData.put("PATID", Objects.isNull(ordScale.getPatId()) ? "" : ordScale.getPatId().toString());
        replaceData.put("LASTNAME", patNames.getLastName());
        replaceData.put("FIRSTNAME", patNames.getFirstName());

        webApiCallCommonUtil.registerNotification(NotificationDefinition.SEND_COND_NG, facility_cd, replaceData);
        comsvOrdWeightScaleDao.updateStatus(scale);
        updateScaleBedStateError(ordScale.getBedCd());
      } catch (Exception e) {
        eventLogMessage.setLogMessage("通知失敗:" + e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      }

    }

    ret = indApproveService.IndApprovedForStatusMap(ord.getOrdNo());
    // add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 shiyw 20240529 start
    /*
    条件付き送信の場合、pat _ ind _ approveテーブルの2つのフィールド：check_content、approve_contentを処理し、処理ロジック：
    1、フロントエンド条件：check _ content、approve _ contentにコンテンツがある場合（「」ではない）
    2、マスターを参照して小数点以下のビットを修正する
    3、単位連結処理
    例：透析液流量value=「5.0」、value=「5.00 mL/min」に処理する
     */
    indApproveService.indApprovedForCheckContentAndApproveContent(ord.getOrdNo());
    // add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 shiyw 20240529 end
    eventLogMessage.setLogMessage("条件送信時の指示確認状況更新 = " + ret);
    eventLogMessage.setFacilityCd(facility_cd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
	return ret;
  }

  @AllArgsConstructor
  @SuppressWarnings("unused")
  private class webApiPayload {
    public String facility_cd;
    public String machine_type_cd;
    public String machine_serial;
  }

  @Autowired
  private ObjectMapper mapper;
  /**
   * WebApi側のREST APIを呼び出す処理
   * @param facilityCd 施設コード
   * @param machineTypeCd 装置種別
   * @param machineSerial 装置シリアル
   * @return
   * @throws URISyntaxException
   * @throws IOException
   */
  private ComsvSendConditionResponse callWebApiSendCond(String facilityCd, String machineTypeCd,
      String machineSerial) throws URISyntaxException, IOException {

    ComsvSendConditionResponse res = new ComsvSendConditionResponse();

    // del 11454 時間外加算自動処理が機能していない zkm start
//    // 送信URI TODO: ymlから取得するようにする？
//    String baseUrl = webApiCallProperties.getUrl();
//    if (Objects.isNull(baseUrl) || baseUrl.isEmpty()) {
//      baseUrl = "http://localhost:8080/ntss-web-api";
//    }
//
//    URI uri = new URI(baseUrl + "/util/SendCondResult");
//    RestTemplate restTemplate = new RestTemplate();
//
//    // body作成
//    webApiPayload json = new webApiPayload(facilityCd, machineTypeCd, machineSerial);
//
//    // リクエスト作成
//    RequestEntity<webApiPayload> requestEntity = RequestEntity
//        .post(uri)
//        .contentType(MediaType.APPLICATION_JSON)
//        .header("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK")
//        .body(json);
//
//    ResponseEntity<String> result = null;
    // del 11454 時間外加算自動処理が機能していない zkm end
    try {
      // API呼び出し
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("指示展開API呼び出し");
      eventLogMessage.setMachineTypeCd(machineTypeCd);
      eventLogMessage.setFacilityCd(facilityCd);
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
	    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // mod 11454 時間外加算自動処理が機能していない zkm start
//      result = restTemplate.exchange(requestEntity, String.class);
      conditionSendResultService.mainProcessSendCondResult(facilityCd, machineTypeCd, machineSerial);
//      if (result.getStatusCode() == HttpStatus.OK) {
        res.isSuccess = true;
        eventLogMessage.setLogMessage("指示展開API呼び出し成功 = " + HttpStatus.OK);
        eventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
//      } else {
//        // APIエラー
//        res.isSuccess = false;
//        eventLogMessage.setLogMessage("指示展開API呼び出し失敗 = " + result.getStatusCode());
//        eventLogMessage.setFacilityCd(facilityCd);
//        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
//        if (result != null && result.hasBody() && result.getBody() != null) {
//          res = getApiErrorMessage(res, result.getBody(), HttpStatus.OK);
//        }
//      }
//    } catch(HttpServerErrorException e) {
//      // API呼び出しエラー 5xx
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage("指示展開API呼び出しエラー = " + e.getStatusCode());
//      eventLogMessage.setFacilityCd(facilityCd);
//      //FNSI-修正 ログ対応 xiebzh add start
//      eventLogMessage.setInvokeClass(this.getClass().getName());
//      //FNSI-修正 ログ対応 xiebzh add end
//      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
//      res.isSuccess = false;
//      res = getApiErrorMessage(res, e.getResponseBodyAsString(), e.getStatusCode());
//    } catch(HttpClientErrorException e) {
//      // API呼び出しエラー 4xx
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage("指示展開API呼び出しエラー = " + e.getStatusCode());
//      eventLogMessage.setFacilityCd(facilityCd);
//      //FNSI-修正 ログ対応 xiebzh add start
//      eventLogMessage.setInvokeClass(this.getClass().getName());
//      //FNSI-修正 ログ対応 xiebzh add end
//      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
//      res.isSuccess = false;
//      res = getApiErrorMessage(res, e.getResponseBodyAsString(), e.getStatusCode());
      // mod 11454 時間外加算自動処理が機能していない zkm end
    } catch(Exception e) {
      // API呼び出しエラー
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("指示展開API呼び出しエラー = " + e.getMessage());
      eventLogMessage.setFacilityCd(facilityCd);
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      res.isSuccess = false;
      res = getApiErrorMessage(res, "", null);
    }

    return res;
  }
  /**
   * YED製APIからエラーメッセージを取得
   * @param res
   * @param result
   * @return
   */
  private ComsvSendConditionResponse getApiErrorMessage(ComsvSendConditionResponse res, String responseBody, HttpStatus httpStatus) {
    if (responseBody != null && responseBody.length() > 3) {
      try {
        JsonNode node = mapper.readTree(responseBody);
        res.errorMessage = node.get("retMsg").asText("");
        res.exMessage = node.get("retLogMsg").asText("");
        if (Objects.equals(res.errorMessage, "null")) {
          res.exMessage = "API内部エラー";
          res.errorMessage = "内部エラー";
        }
      } catch (Exception e) {

        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("外部API返り値エラー:" + e.getMessage());
        //FNSI-修正 ログ対応 xiebzh add start
        eventLogMessage.setInvokeClass(this.getClass().getName());
        //FNSI-修正 ログ対応 xiebzh add end
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        res.exMessage = "外部API返り値エラー:" + e.getMessage();
        res.errorMessage = "処理エラー";
      }
      if (httpStatus != null && httpStatus != HttpStatus.OK) {
        res.exMessage += "(HTTP " + httpStatus + ")";
      }
    }
    return res;
  }

  /**
   * 条件送信エラー時にベッドがスケールベッドの場合は前体重送信エラー扱いにする
   * @param bedCd
   */
  private void updateScaleBedStateError(Long bedCd) {
    if (bedCd == null) { return; }
    MntScaleBedState state = mntScaleBedStateDao.selectByBedCd(bedCd);
    if (state == null) { return; }
    state.setBeforeSendStatus(1);
    mntScaleBedStateDao.update(state);
  }

}
