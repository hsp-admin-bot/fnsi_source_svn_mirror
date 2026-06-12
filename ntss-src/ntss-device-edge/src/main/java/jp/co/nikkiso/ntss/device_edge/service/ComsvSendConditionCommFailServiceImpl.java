package jp.co.nikkiso.ntss.device_edge.service;

import java.io.IOException;
import java.math.BigDecimal;
import java.net.URISyntaxException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.google.common.base.Strings;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.ComsvOrdMainDao;
import jp.co.nikkiso.ntss.core.dao.ComsvOrdWeightScaleDao;
import jp.co.nikkiso.ntss.core.dao.DBAppWebAPIDao;
import jp.co.nikkiso.ntss.core.dao.DBAppWebAPIUserDao;
import jp.co.nikkiso.ntss.core.dao.MstDialyzerDao;
import jp.co.nikkiso.ntss.core.dao.MstHolidayDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.dao.MstVaDao;
import jp.co.nikkiso.ntss.core.dao.OperateStatusDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.OrdWeightScaleDao;
import jp.co.nikkiso.ntss.core.dao.PatExamMainDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.PatUniqueDao;
import jp.co.nikkiso.ntss.core.dao.TmpCommFailureRecoveryDao;
import jp.co.nikkiso.ntss.core.entity.MstDialyzer;
import jp.co.nikkiso.ntss.core.entity.MstVa;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.OrdWeightScale;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.PatUnique;
import jp.co.nikkiso.ntss.core.entity.TmpCommFailureRecovery;
import jp.co.nikkiso.ntss.core.entity.custom.ComTypeAndFormatCd;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvOrdMain;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvOrdWeightScale;
import jp.co.nikkiso.ntss.core.entity.custom.MstEquipmentMstMedicine;
import jp.co.nikkiso.ntss.device_edge.service.Utility.PatNameInfo;
import jp.co.nikkiso.ntss.device_edge.service.Utility.PatNameUtilityService;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.util.ObjectUtils;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.NotificationDefinition;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.SendCondition.WeightScaleClass;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.device_edge.WebApiCallProperties;
import jp.co.nikkiso.ntss.device_edge.response.checkList.ChecklistUpdateResponse;
import jp.co.nikkiso.ntss.device_edge.response.comsvSendCondition.ComsvSendConditionResponse;
import jp.co.nikkiso.ntss.device_edge.service.indApprove.IndApproveService;
import jp.co.nikkiso.ntss.device_edge.service.webSocketNotify.WebSocketNotifyService;
import jp.co.nikkiso.ntss.device_edge.web.rest.util.WebApiCallCommonUtil;


import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
import jp.co.nikkiso.ntss.api.request.AdditionCalculationRequest;
import jp.co.nikkiso.ntss.api.service.additionInfo.AdditionCalculationService;

@Service
public class ComsvSendConditionCommFailServiceImpl implements ComsvSendConditionCommFailService {

  /**
   * ObjectMapper.
   */

  @Autowired
  private LogService logService;

  @Autowired
  private ComsvOrdMainDao comsvOrdMainDao;
//  @Autowired
//  private ComsvPatRelatedDao comsvPatRelatedDao;
//  @Autowired
//  private MntMachineStateDao mntMachineStateDao;
  @Autowired
  private ComsvOrdCheckListService comsvOrdCheckListService;
  @Autowired
  private ComsvOrdWeightScaleDao comsvOrdWeightScaleDao;
  @Autowired
  WebSocketNotifyService sendWsMsg;

  @Autowired
  IndApproveService indApproveService;

  @Autowired
  WebApiCallProperties webApiCallProperties;
  @Autowired
  WebApiCallCommonUtil webApiCallCommonUtil;

  // add AWSとDEの通信断からの復旧 --趙-- start
  @Autowired
  DBAppWebAPIDao dBAppWebAPIDao;

  @Autowired
  TmpCommFailureRecoveryDao tmpCommFailureRecoveryDao;

  @Autowired
  private PatMainDao patMainDao;

  @Autowired
  private PatUniqueDao patUniqueDao;

  @Autowired
  private PatPersonalMainDao patPersonalMainDao;

  @Autowired
  private DBAppWebAPIUserDao dBAppWebAPIUserDao;

  @Autowired
  private MstMachineDao mstMachineDao;

  @Autowired
  private OperateStatusDao operateStatusDao;

  @Autowired
  private OrdWeightScaleDao ordWeightScaleDao;

  @Autowired
  private PatNameUtilityService patNameUtilityService;

  /* del by chamaojia 2026-05-07 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
  // private STATUS enumStatus;
  /* del by chamaojia 2026-05-07 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
  // add AWSとDEの通信断からの復旧 --趙-- end

  // add FNSI-分類不一致判断の追加 徐 start
  @Autowired
  private MstDialyzerDao mstDialyzerDao;

  @Autowired
  private MstVaDao mstVaDao;

  @Autowired
  private OrdMainDao ordMainDao;
  // add FNSI-分類不一致判断の追加 徐 end

  @Autowired
  MstHolidayDao mstHolidayDao;

  @Autowired
  PatExamMainDao patExamMainDao;

  @Autowired
  private AdditionCalculationService additionCalculationService;

  @Override
  //@Transactional
  public int sendConditionProc(String facility_cd, String json) throws ParseException, URISyntaxException, IOException {

    JSONObject receiveData= new JSONObject(json);

    int ret;
    String machine_type_cd = receiveData.get("machine_type_cd").toString();
    String machine_serial = receiveData.get("machine_serial").toString();
    String machine_format = receiveData.get("machine_format").toString();
    String send_date = receiveData.get("send_date").toString();
    String dial_status = "1";

//    // 装置状態管理の条件送信日時更新
//    MntMachineState state = new MntMachineState();
//    state.setFacilityCd(facility_cd);
//    state.setMachineTypeCd(machine_type_cd);
//    state.setMachineSerial(machine_serial);
//    String machine_status = receiveData.get("machine_status").toString();
//    state.setMachineStatus(Integer.parseInt(machine_status));
//    if (send_date.equals("null")) {
//      state.setCondSendDate(null);
//    } else {
//      Timestamp sendTime = new Timestamp(new SimpleDateFormat("yyyyMMddHHmmss").parse(send_date).getTime());
//      state.setCondSendDate(sendTime);
//    }
//    ret = mntMachineStateDao.updateCondSend(state);
//      EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setMachineTypeCd(machine_type_cd);
//    eventLogMessage.setLogMessage("装置状態管理の条件送信日時更新 = " + ret);
//    eventLogMessage.setFacilityCd(facility_cd);
//    //FNSI-修正 ログ対応 xiebzh add start
//    eventLogMessage.setInvokeClass(this.getClass().getName());
//    //FNSI-修正 ログ対応 xiebzh add end

//    logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
//    if ( machine_format.equals("F") || machine_format.equals("V") || machine_format.equals("W") ) {
//      // オフライン又は共通プロトコルの場合
//      // mod 実績：治療状況（ord_main.rst_dialysis_state）の状態変更 高 start
//      // dial_status = "2";
//      dial_status = "1";
//      // 治療中フラグを「１」である場合
//      if(dialysisFlag.equals("1")) {
//        dial_status = "3";
//      }
//      // mod 実績：治療状況（ord_main.rst_dialysis_state）の状態変更 高 end
//      // 装置状態管理の条件確認日時更新
//      if (send_date.equals("null")) {
//        state.setCondSetDate(null);
//        state.setIsPatVerified("0");
//      } else {
//        Timestamp setTime = new Timestamp(new SimpleDateFormat("yyyyMMddHHmmss").parse(send_date).getTime());
//        state.setCondSetDate(setTime);
//        state.setIsPatVerified("1");
//      }
//      ret = mntMachineStateDao.updateCondSet(state);
//      eventLogMessage.setLogMessage("装置状態管理の条件確認日時更新 = " + ret);
//      eventLogMessage.setFacilityCd(facility_cd);
//      logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
//    }
    // add AWSとDEの通信断からの復旧 --趙-- start
    if ( machine_format.equals("F") || machine_format.equals("V") || machine_format.equals("W") ) {
      // オフライン又は共通プロトコルの場合
      // mod 実績：治療状況（ord_main.rst_dialysis_state）の状態変更 高 start
      // dial_status = "2";
      dial_status = "1";
      // mod 実績：治療状況（ord_main.rst_dialysis_state）の状態変更 高 end
    }
    // add AWSとDEの通信断からの復旧 --趙-- end
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
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("治療情報の条件送信日時更新 = " + ret);
    eventLogMessage.setFacilityCd(facility_cd);
    logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
    // 条件送信時のチェックリスト実績作成・更新
    try {
      ChecklistUpdateResponse resChk = comsvOrdCheckListService.createOrdChecklistSendCondition(facility_cd, Long.parseLong(ord_no));
      if (resChk.isSuccess) {
        eventLogMessage.setLogMessage("チェックリスト実績作成");
        eventLogMessage.setSqlIdentification("(facility_cd = " + facility_cd + ",or_no = " + ord_no);
        eventLogMessage.setFacilityCd(facility_cd);
        logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI,"comsvOrdCheckListService/createOrdChecklistSendCondition");
      } else {
        eventLogMessage.setLogMessage("チェックリスト実績作成失敗[" + resChk.errorMessage +"]");
        eventLogMessage.setSqlIdentification("(facility_cd = " + facility_cd + ",or_no = " + ord_no);
        eventLogMessage.setFacilityCd(facility_cd);
        logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI,"comsvOrdCheckListService/createOrdChecklistSendCondition");
      }
    } catch (Exception e) {
      eventLogMessage.setLogMessage("チェックリスト実績作成エラー[" + e.getMessage() + "]");
      eventLogMessage.setFacilityCd(facility_cd);
      logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
    }

    // 指示展開（WebApi側のREST APIを呼び出す
    ComsvSendConditionResponse resApi = callSendCondCommFail(facility_cd, machine_type_cd, machine_serial);

    ComsvOrdWeightScale scale = new ComsvOrdWeightScale();
    String scale_no = receiveData.get("send_ctrl").toString();
    scale.setWeightScaleNo(Long.parseLong(scale_no));
    if ( resApi.isSuccess == true ) {
      // 指示展開処理成功
      scale.setWeightScaleStatus(WeightScaleClass.SEND_OK);
      scale.setMessage(null);
    }
    else {
      // 指示展開処理失敗
      scale.setWeightScaleStatus(WeightScaleClass.SEND_NG);
      scale.setMessage("指示展開処理失敗:" + (resApi.errorMessage != null ? resApi.errorMessage : "不明なエラー"));
      eventLogMessage.setLogMessage("指示展開処理失敗:" + (resApi.exMessage != null ? resApi.exMessage : "不明なエラー"));
      eventLogMessage.setFacilityCd(facility_cd);
      logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
    }
    ret = comsvOrdWeightScaleDao.updateStatus(scale);
    eventLogMessage.setLogMessage("体重計測定実績のステータス、メッセージ更新 = " + ret);
    eventLogMessage.setFacilityCd(facility_cd);
    logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);

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
      } catch (Exception e) {
        eventLogMessage.setLogMessage("通知失敗:" + e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      }

    }

    ret = indApproveService.IndApprovedForStatusMap(ord.getOrdNo());
    eventLogMessage.setLogMessage("条件送信時の指示確認状況更新 = " + ret);
    eventLogMessage.setFacilityCd(facility_cd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    return ret;
  }

//  @AllArgsConstructor
//  @SuppressWarnings("unused")
//  private class webApiPayload {
//    public String facility_cd;
//    public String machine_type_cd;
//    public String machine_serial;
//  }

//  @Autowired
//  private ObjectMapper mapper;
//  /**
//   * WebApi側のREST APIを呼び出す処理
//   * @param facilityCd 施設コード
//   * @param machineTypeCd 装置種別
//   * @param machineSerial 装置シリアル
//   * @return
//   * @throws URISyntaxException
//   * @throws IOException
//   */
//  private ComsvSendConditionResponse callWebApiSendCond(String facilityCd, String machineTypeCd,
//                                                        String machineSerial) throws URISyntaxException, IOException {
//
//    ComsvSendConditionResponse res = new ComsvSendConditionResponse();
//
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
//      .post(uri)
//      .contentType(MediaType.APPLICATION_JSON)
//      .header("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK")
//      .body(json);
//
//    ResponseEntity<String> result = null;
//    try {
//      // API呼び出し
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage("指示展開API呼び出し");
//      eventLogMessage.setMachineTypeCd(machineTypeCd);
//      eventLogMessage.setFacilityCd(facilityCd);
//      //FNSI-修正 ログ対応 xiebzh add start
//      eventLogMessage.setInvokeClass(this.getClass().getName());
//      //FNSI-修正 ログ対応 xiebzh add end
//      logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
//      result = restTemplate.exchange(requestEntity, String.class);
//      if (result.getStatusCode() == HttpStatus.OK) {
//        res.isSuccess = true;
//        eventLogMessage.setLogMessage("指示展開API呼び出し成功 = " + HttpStatus.OK);
//        eventLogMessage.setFacilityCd(facilityCd);
//        logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
//      } else {
//        // APIエラー
//        res.isSuccess = false;
//        eventLogMessage.setLogMessage("指示展開API呼び出し失敗 = " + result.getStatusCode());
//        eventLogMessage.setFacilityCd(facilityCd);
//        logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
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
//      logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
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
//      logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
//      res.isSuccess = false;
//      res = getApiErrorMessage(res, e.getResponseBodyAsString(), e.getStatusCode());
//    } catch(Exception e) {
//      // API呼び出しエラー
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage("指示展開API呼び出しエラー = " + e.getMessage());
//      eventLogMessage.setFacilityCd(facilityCd);
//      //FNSI-修正 ログ対応 xiebzh add start
//      eventLogMessage.setInvokeClass(this.getClass().getName());
//      //FNSI-修正 ログ対応 xiebzh add end
//      logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
//      res.isSuccess = false;
//      res = getApiErrorMessage(res, "", null);
//    }
//
//    return res;
//  }
//  /**
//   * YED製APIからエラーメッセージを取得
//   * @param res
//   * @param result
//   * @return
//   */
//  private ComsvSendConditionResponse getApiErrorMessage(ComsvSendConditionResponse res, String responseBody, HttpStatus httpStatus) {
//    if (responseBody != null && responseBody.length() > 3) {
//      try {
//        JsonNode node = mapper.readTree(responseBody);
//        res.errorMessage = node.get("retMsg").asText("");
//        res.exMessage = node.get("retLogMsg").asText("");
//        if (Objects.equals(res.errorMessage, "null")) {
//          res.exMessage = "API内部エラー";
//          res.errorMessage = "内部エラー";
//        }
//      } catch (Exception e) {
//
//        EventLogMessage eventLogMessage = new EventLogMessage();
//        eventLogMessage.setLogMessage("外部API返り値エラー:" + e.getMessage());
//        //FNSI-修正 ログ対応 xiebzh add start
//        eventLogMessage.setInvokeClass(this.getClass().getName());
//        //FNSI-修正 ログ対応 xiebzh add end
//        logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
//        res.exMessage = "外部API返り値エラー:" + e.getMessage();
//        res.errorMessage = "処理エラー";
//      }
//      if (httpStatus != null && httpStatus != HttpStatus.OK) {
//        res.exMessage += "(HTTP " + httpStatus + ")";
//      }
//    }
//    return res;
//  }

  private ComsvSendConditionResponse callSendCondCommFail(String facilityCd, String machineTypeCd, String machineSerial){

    String retLogMsg = "";
    String retMsg ="";
    boolean cryptoFlag = false ;        //false:暗号化しない(処理的には取得時に復号する)
    HashMap<PARAMKEY,Object> retVal = new HashMap<>();
    //クラス名の取得(ログ用)
    final String className = new Object(){}.getClass().getEnclosingClass().getName();
    //メソッド名の取得(ログ用)
    final String methodName = new Object(){}.getClass().getEnclosingMethod().getName();
    ComsvSendConditionResponse res = new ComsvSendConditionResponse();

    //開始ログ
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(className + "." + methodName + "の処理を開始しました。");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    if(Strings.isNullOrEmpty(facilityCd) || Strings.isNullOrEmpty(machineTypeCd)
      || Strings.isNullOrEmpty(machineSerial)) {

      //必要パラメータが渡されていないので終了
      String fmt = "渡されたパラメータが不正です。"+ facilityCd +"(%s) " + machineTypeCd+"(%s) "+ machineSerial +"(%s) " ;
      retLogMsg = String.format(fmt, facilityCd,machineTypeCd,machineSerial);
      retMsg = "装置が特定できません。";

      try {
        // ロールバック用の例外を投げる
        this.exitMethod(className,methodName,retLogMsg);
      }catch (RuntimeException e) {
        res.isSuccess = false;
        res.ex = e;
        res.exMessage =retLogMsg;
        res.errorMessage= retMsg;
        return res;
      }
    }

    TmpCommFailureRecovery tmpCommFailureRecovery = tmpCommFailureRecoveryDao.selectByKey(facilityCd, machineTypeCd, machineSerial);
    if( null == tmpCommFailureRecovery )
    {
      //tmpCommFailureRecoveryからのデータ取得に失敗
      String fmt = "tmpCommFailureRecoveryからのデータ取得に失敗しました facilityCd:%s machineTypeCd:%s machineSerial:%s"  ;
      retLogMsg = String.format(fmt, facilityCd, machineTypeCd, machineSerial) ;
      retMsg = "装置状態の取得に失敗しました。";
      try {
        // ロールバック用の例外を投げる
        this.exitMethod(className,methodName,retLogMsg);
      } catch (RuntimeException e) {
        res.isSuccess = false;
        res.ex = e;
        res.exMessage =retLogMsg;
        res.errorMessage= retMsg;
        return res;
      }
    }

    //現患者のpat_idを取得したTmpCommFailureRecoveryのレコードから取得する
    Long nowPatId = tmpCommFailureRecovery.getPatId() ;
    //ord_noを取得したTmpCommFailureRecoveryのレコードから取得する
    //注意:next_ord_noが今条件送信をしようとしている患者のもの
    Long ordNo = tmpCommFailureRecovery.getNextOrdNo() ;
    //対象ベッド透析状態確認
    //今の患者の治療状況のチェックを行う。「治療中」以上(治療が終わっていない)だと処理を中断する
    res.isSuccess = checkPatStatusNotUnderOperation(ordNo, facilityCd);
    eventLogMessage.setLogMessage("04：患者治療中有無(治療が終わってないなら処理中断)：" + res.isSuccess);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if( !res.isSuccess ) {
      //現患者の状態が治療中以上なので処理終了
      String fmt = "現患者の治療状況が治療中以上です(patId:%s)"  ;
      retLogMsg = String.format(fmt, nowPatId) ;
      retMsg = "現患者が治療開始済みです。";
      try {
        // ロールバック用の例外を投げる
        this.exitMethod(className,methodName,retLogMsg);
      } catch (RuntimeException e) {
        res.isSuccess = false;
        res.ex = e;
        res.exMessage =retLogMsg;
        res.errorMessage= retMsg;
        return res;
      }
    }

    //ord_mainのデータ取得
    OrdMain ordMainData = this.getOrdMainData(ordNo,retVal) ;
    eventLogMessage.setLogMessage("05：ord_mainの取得：" + ordMainData);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(null == ordMainData)
    {
      try {
        // ロールバック用の例外を投げる
        this.exitMethod(className,methodName,(String)retVal.get(PARAMKEY.RET_MSG));
      } catch (RuntimeException e) {
        res.isSuccess = false;
        res.ex = e;
        res.exMessage =retLogMsg;
        res.errorMessage= retMsg;
        return res;
      }
    }

    //ord_mainから患者IDを取得(次患者チェック用)
    Long patIdFromOrdMain = ordMainData.getPatId();

    //pat_idを取得したmnt_machine_stateのレコードから取得
    //注意:next_pat_idが今条件送信をしようとしている患者のもの
    Long nextPatId = tmpCommFailureRecovery.getNextPatid() ;


//
//    //特殊血液浄化オフラインフラグ更新機能
//    //※ここでは、値を決定するだけ(mnt_machine_state更新時に合わせて更新)
//    //mnt_machine_state:is_offlineの更新
//    //更新条件:通信フォーマットがF,V,W,Y,Z または治療方法が特殊浄化
//    //オフラインかどうかの確認 true:オフライン
//    boolean offlineFlag = conditionSendResultUtilService.checkOfflineOrNot(ordNo) ;
//    String isOffline = CONSTDEF.ONLINE.get() ;  //TODO:ONLINE初期化
//    eventLogMessage.setLogMessage("06：オフライン有無確認：" + offlineFlag);
//    eventLogMessage.setFacilityCd(facilityCd);
//    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
//    if(offlineFlag)
//    {
//      isOffline = CONSTDEF.OFFLINE.get() ;
//      //条件確認日時(患者確認日時)を設定
//      condSetDate = ts ;
//      //条件送信日時を設定(条件確認日時と同じ)
//      condSendDate = condSetDate ;
//      //患者確認済みフラグを確認済みに設定
//      isPatVerified = CONSTDEF.PATVERIFIED_DONE.get();
//    }


    //------------------------------------------------------------
    //条件送信患者が次患者と不一致でないかチェックする
    //ord_mainのpat_idとmnt_machine_stateのnext_pat_idの比較
    eventLogMessage.setLogMessage("07：条件送信患者が次患者と一致するか確認");
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("07：条件送信患者：" + patIdFromOrdMain);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("07：次患者：" + nextPatId);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(!patIdFromOrdMain.equals(nextPatId))
    {
      //条件送信患者が次患者と不一致
      String fmt = "条件送信患者が次患者と不一致です pat_id:%s next_pat_id:%s"  ;
      retLogMsg = String.format(fmt, patIdFromOrdMain,nextPatId) ;
      retMsg = "条件送信患者が次患者と不一致です"  ;
      try {
        // ロールバック用の例外を投げる
        this.exitMethod(className,methodName,retLogMsg);
      } catch (RuntimeException e) {
        res.isSuccess = false;
        res.ex = e;
        res.exMessage =retLogMsg;
        res.errorMessage= retMsg;
        return res;
      }
    }

    //値の格納
    //ord_mainを更新するために、ord_mainエンティティを組み立てる

//    try {
      //格納先:ordMainエンティティの組み立て
      OrdMain outOrdMain = this.buildResultOrdMainEntity(
        ordNo,
        ordMainData,
//        tmpCommFailureRecovery.getCondSendDate(),
        null,
        cryptoFlag,
        retVal
      );
//    } catch (RuntimeException e) {
//      res.isSuccess = false;
//      res.ex = e;
//      res.exMessage = (String)retVal.get(PARAMKEY.RET_LOG_MSG);
//      res.errorMessage = (String)retVal.get(PARAMKEY.RET_MSG);
//      return res;
//    }

    eventLogMessage.setLogMessage("08：ord_main更新に必要なoutOrdMain値：" + outOrdMain);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(null == outOrdMain)
    {
      //ordMainエンティティの組み立てに失敗
      String fmt = "ordMainエンティティの組み立てに失敗しました :%s"  ;
      retLogMsg = String.format(fmt, retVal.get(PARAMKEY.RET_LOG_MSG)) ;
      retMsg = (String)retVal.get(PARAMKEY.RET_MSG);
      try {
        // ロールバック用の例外を投げる
        this.exitMethod(className,methodName,retLogMsg);
      } catch (RuntimeException e) {
        res.isSuccess = false;
        res.ex = e;
        res.exMessage =retLogMsg;
        res.errorMessage= retMsg;
        return res;
      }
    }

    // DB更新
    //==================================================
    //対象ベッド透析状態確認
    //今の患者の治療状況のチェックを行う。「治療中」以上(治療が終わっていない)だと処理を中断する
    //==================================================
    res.isSuccess  = checkNowPatStatusNotUnderOperation(ordNo,facilityCd) ;
    eventLogMessage.setLogMessage("09：患者治療中有無(治療が終わってないなら処理中断)：" + res.isSuccess);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if( !res.isSuccess )
    {
      //現患者の状態が治療中以上なので処理終了
      String fmt = "現患者の治療状況が治療中以上です(patId:%s)"  ;
      retLogMsg = String.format(fmt, nowPatId) ;
      retMsg = "現患者の治療が終わっていません。"  ;
//      // エラーステータス設定
//      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
      try {
        // ロールバック用の例外を投げる
        this.exitMethod(className,methodName,retLogMsg);
      } catch (RuntimeException e) {
        res.isSuccess = false;
        res.ex = e;
        res.exMessage =retLogMsg;
        res.errorMessage= retMsg;
        return res;
      }
    }

    // add FNSI-分類不一致判断の追加 徐 start
    // 指示：治療条件情報
    String buf = outOrdMain.getRstCondInfo();
    JSONObject setCond = new JSONObject(buf);
    JSONObject condInfoJson = new JSONObject();
    JSONArray keys = setCond.names();

    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
    String sysDate = sdf.format(new Date());

    for (int i = 0; i < keys.length(); i++) {
      String key = keys.getString(i);
      JSONObject obj = setCond.getJSONObject(key);

      boolean checkFlg = false;

      // 医療材料
      if ((Integer.parseInt(key) >= 6 && Integer.parseInt(key) <= 11) || Integer.parseInt(key) == 13) {
        if (obj.has("value") && !"null".equals(obj.get("value").toString())) {
          MstEquipmentMstMedicine classType = this.getClassType((int)obj.get("value"), 0, facilityCd);
          if (classType != null) {
            if ("0".equals(classType.getIsDisp()) || "1".equals(classType.getIsDel())) {
              checkFlg = true;
            } else if (!Strings.isNullOrEmpty(classType.getUseEndDate())) {
              if (Integer.valueOf(sysDate) > Integer.valueOf(classType.getUseEndDate())) {
                checkFlg = true;
              }
            }
          } else {
            checkFlg = true;
          }
        }
      }
      // 薬剤
      if (Integer.parseInt(key) == 15 || Integer.parseInt(key) == 19 || Integer.parseInt(key) == 25) {
        if (obj.has("value") && !"null".equals(obj.get("value").toString())) {
          MstEquipmentMstMedicine classType = this.getClassType((int)obj.get("value"), 1, facilityCd);
          if (classType != null) {
            if ("0".equals(classType.getIsDisp()) || "1".equals(classType.getIsDel())) {
              checkFlg = true;
            } else if (!Strings.isNullOrEmpty(classType.getUseEndDate())) {
              if (Integer.valueOf(sysDate) > Integer.valueOf(classType.getUseEndDate())) {
                checkFlg = true;
              }
            }
          } else {
            checkFlg = true;
          }
        }
      }
      // ダイアライザ
      if (Integer.parseInt(key) == 5) {
        if (obj.has("value") && !"null".equals(obj.get("value").toString())) {
          MstDialyzer dialyzer = mstDialyzerDao.selectByDialyzerCd(SelectOptions.get(), (int)obj.get("value"));
          if (dialyzer != null) {
            if ("0".equals(dialyzer.getIsDisp())) {
              checkFlg = true;
            } else if (!Strings.isNullOrEmpty(dialyzer.getUseEndDate())) {
              if (Integer.valueOf(sysDate) > Integer.valueOf(dialyzer.getUseEndDate())) {
                checkFlg = true;
              }
            }
          } else {
            checkFlg = true;
          }
        }
      }
      // VA
      if (Integer.parseInt(key) == 2) {
        if (obj.has("value") && !"null".equals(obj.get("value").toString())) {
          MstVa mstVa = mstVaDao.selectByCd(Integer.valueOf((int)obj.get("value")));
          if (mstVa != null) {
            if ("0".equals(mstVa.getIsDisp())) {
              checkFlg = true;
            }
          } else {
            checkFlg = true;
          }
        }
      }

      JSONObject bufJson = new JSONObject();
      if (checkFlg) {
        condInfoJson.put(key, bufJson);

      } else {
        // 設定値
        bufJson.put("value", obj.has("value") ? obj.get("value") : JSONObject.NULL);
        // 翻訳1
        bufJson.put("value_name_1", obj.has("value_name_1") ? obj.get("value_name_1") : JSONObject.NULL);
        // 単位
        bufJson.put("unit", obj.has("unit") ? obj.get("unit") : JSONObject.NULL);
        // 薬剤区分
        bufJson.put("medicine_type", obj.has("medicine_type") ? obj.get("medicine_type") : JSONObject.NULL);
        // 指示者コード
        bufJson.put("ind_user_id", obj.has("ind_user_id") ? obj.get("ind_user_id") : JSONObject.NULL);
        // 指示者名_姓
        bufJson.put("ind_user_last_name", obj.has("ind_user_last_name") ? obj.get("ind_user_last_name") : JSONObject.NULL);
        // 指示者名_名
        bufJson.put("ind_user_first_name", obj.has("ind_user_first_name") ? obj.get("ind_user_first_name") : JSONObject.NULL);
        // 更新者コード
        bufJson.put("upd_user_id", obj.has("upd_user_id") ? obj.get("upd_user_id") : JSONObject.NULL);
        // 更新者名_姓
        bufJson.put("upd_user_last_name", obj.has("upd_user_last_name") ? obj.get("upd_user_last_name") : JSONObject.NULL);
        // 更新者名_名
        bufJson.put("upd_user_first_name", obj.has("upd_user_first_name") ? obj.get("upd_user_first_name") : JSONObject.NULL);
        // 登録区分
        bufJson.put("input_class", obj.has("input_class") ? obj.get("input_class") : JSONObject.NULL);
        // 編集可否フラグ
        bufJson.put("is_editable", obj.has("is_editable") ? obj.get("is_editable") : JSONObject.NULL);
        // 連携オーダ番号
        bufJson.put("cop_order_no", obj.has("cop_order_no") ? obj.get("cop_order_no") : JSONObject.NULL);
        condInfoJson.put(key, bufJson);
      }
    }
    outOrdMain.setRstCondInfo(condInfoJson.toString());

    // 投与薬剤情報
    buf = outOrdMain.getRstMediInfo();
    /* add by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --start */
    //JSONArray setMedi = new JSONArray(buf);
    JSONArray setMedi = new JSONArray(ObjectUtils.isEmpty(buf)? "[]" : buf);
    /* add by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --end */
    JSONArray mediInfoJson = new JSONArray();
    for (int i = 0; i < setMedi.length(); i++) {

      JSONObject obj = setMedi.getJSONObject(i);

      boolean checkFlg = false;

      if (obj.has("cd") && !"null".equals(obj.get("cd").toString())) {
        MstEquipmentMstMedicine classType = this.getClassType((int)obj.get("cd"), 1, facilityCd);
        if (classType != null) {
          if ("0".equals(classType.getIsDisp()) || "1".equals(classType.getIsDel())) {
            checkFlg = true;
          } else if (!Strings.isNullOrEmpty(classType.getUseEndDate())) {
            if (Integer.valueOf(sysDate) > Integer.valueOf(classType.getUseEndDate())) {
              checkFlg = true;
            }
          }
        } else {
          checkFlg = true;
        }
      }

      if (checkFlg) {
        continue;
      }

      JSONObject bufJson = new JSONObject();
      // 識別番号
      bufJson.put("no", obj.has("no") ? obj.get("no") : JSONObject.NULL);
      // 薬剤分類コード
      bufJson.put("class_cd", obj.has("class_cd") ? obj.get("class_cd") : JSONObject.NULL);
      // 薬剤分類名
      bufJson.put("class_name", obj.has("class_name") ? obj.get("class_name") : JSONObject.NULL);
      // 分類区分
      bufJson.put("class_type", obj.has("class_type") ? obj.get("class_type") : JSONObject.NULL);
      // 薬剤区分
      bufJson.put("medicine_type", obj.has("medicine_type") ? obj.get("medicine_type") : JSONObject.NULL);
      // 薬剤(調整薬剤)コード
      bufJson.put("cd", obj.has("cd") ? obj.get("cd") : JSONObject.NULL);
      // 薬剤名
      bufJson.put("name", obj.has("name") ? obj.get("name") : JSONObject.NULL);
      // 省略薬剤名
      bufJson.put("short_name",obj.has("short_name") ? obj.get("short_name") : JSONObject.NULL);
      // 単位
      bufJson.put("unit",obj.has("unit") ? obj.get("unit") : JSONObject.NULL);
      // 数量
      bufJson.put("amount",obj.has("amount") ? obj.get("amount") : JSONObject.NULL);
      // 初回投与日
      bufJson.put("init_date", obj.has("init_date") ? obj.get("init_date") : JSONObject.NULL);
      // 投与間隔
      bufJson.put("date_interval", obj.has("date_interval") ? obj.get("date_interval") : JSONObject.NULL);
      // 投与タイミングコード
      bufJson.put("timing_cd", obj.has("timing_cd") ? obj.get("timing_cd") : JSONObject.NULL);
      // 投与タイミング名
      bufJson.put("timing_name", obj.has("timing_name") ? obj.get("timing_name") : JSONObject.NULL);
      // 手技コード
      bufJson.put("procedure_cd", obj.has("procedure_cd") ? obj.get("procedure_cd") : JSONObject.NULL);
      // 手技名
      bufJson.put("procedure_name", obj.has("procedure_name") ? obj.get("procedure_name") : JSONObject.NULL);
      // コメント
      bufJson.put("comment", obj.has("comment") ? obj.get("comment") : JSONObject.NULL);
      // 指示者コード
      bufJson.put("ind_user_id", obj.has("ind_user_id") ? obj.get("ind_user_id") : JSONObject.NULL);
      // 指示者名_姓
      bufJson.put("ind_user_last_name", obj.has("ind_user_last_name") ? obj.get("ind_user_last_name") : JSONObject.NULL);
      // 指示者名_名
      bufJson.put("ind_user_first_name", obj.has("ind_user_first_name") ? obj.get("ind_user_first_name") : JSONObject.NULL);
      // 更新者コード
      bufJson.put("upd_user_id", obj.has("upd_user_id") ? obj.get("upd_user_id") : JSONObject.NULL);
      // 更新者名_姓
      bufJson.put("upd_user_last_name", obj.has("upd_user_last_name") ? obj.get("upd_user_last_name") : JSONObject.NULL);
      // 更新者名_名
      bufJson.put("upd_user_first_name", obj.has("upd_user_first_name") ? obj.get("upd_user_first_name") : JSONObject.NULL);
      // 登録区分
      bufJson.put("input_class", obj.has("input_class") ? obj.get("input_class") : JSONObject.NULL);
      // 編集可否フラグ
      bufJson.put("is_editable", obj.has("is_editable") ? obj.get("is_editable") : JSONObject.NULL);
      // 連携オーダ番号
      bufJson.put("cop_order_no", obj.has("cop_order_no") ? obj.get("cop_order_no") : JSONObject.NULL);
      // 投与実施フラグ
      bufJson.put("effect_flg", obj.has("effect_flg") ? obj.get("effect_flg") : JSONObject.NULL);
      // 投与実施日時
      bufJson.put("effect_date", obj.has("effect_date") ? obj.get("effect_date") : JSONObject.NULL);
      // 投与実施者コード
      bufJson.put("effect_user_id", obj.has("effect_user_id") ? obj.get("effect_user_id") : JSONObject.NULL);
      // 投与実施者名_姓
      bufJson.put("effect_user_last_name", obj.has("effect_user_last_name") ? obj.get("effect_user_last_name") : JSONObject.NULL);
      // 投与実施者名_名
      bufJson.put("effect_user_first_name", obj.has("effect_user_first_name") ? obj.get("effect_user_first_name") : JSONObject.NULL);
      mediInfoJson.put(bufJson);
    }
    outOrdMain.setRstMediInfo(mediInfoJson.toString());

    // 医療材料情報
    buf = outOrdMain.getRstEquipInfo();
    JSONArray setEquip = new JSONArray(buf);
    JSONArray equipInfoJson = new JSONArray();
    for (int i = 0; i < setEquip.length(); i++) {
      JSONObject obj = setEquip.getJSONObject(i);

      boolean checkFlg = false;

      if (obj.has("cd") && !"null".equals(obj.get("cd").toString())) {
        MstEquipmentMstMedicine classType = this.getClassType((int)obj.get("cd"), 0, facilityCd);
        if (classType != null) {
          if ("0".equals(classType.getIsDisp()) || "1".equals(classType.getIsDel())) {
            checkFlg = true;
          } else if (!Strings.isNullOrEmpty(classType.getUseEndDate())) {
            if (Integer.valueOf(sysDate) > Integer.valueOf(classType.getUseEndDate())) {
              checkFlg = true;
            }
          }
        } else {
          checkFlg = true;
        }
      }

      if (checkFlg) {
        continue;
      }

      JSONObject bufJson = new JSONObject();
      // 医療材料分類コード
      bufJson.put("class_cd", obj.has("class_cd") ? obj.get("class_cd") : JSONObject.NULL);
      // 医療材料分類名
      bufJson.put("class_name", obj.has("class_name") ? obj.get("class_name") : JSONObject.NULL);
      // 分類区分
      bufJson.put("class_type", obj.has("class_type") ? obj.get("class_type") : JSONObject.NULL);
      // 医療材料コード
      bufJson.put("cd", obj.has("cd") ? obj.get("cd") : JSONObject.NULL);
      // 医療材料名
      bufJson.put("name", obj.has("name") ? obj.get("name") : JSONObject.NULL);
      // 省略医療材料名
      bufJson.put("short_name", obj.has("short_name") ? obj.get("short_name") : JSONObject.NULL);
      // 穿刺針区分
      bufJson.put("needle_type", obj.has("needle_type") ? obj.get("needle_type") : JSONObject.NULL);
      // 数量
      bufJson.put("amount", obj.has("amount") ? obj.get("amount") : JSONObject.NULL);
      // 単位
      bufJson.put("unit", obj.has("unit") ? obj.get("unit") : JSONObject.NULL);
      // 指示者コード
      bufJson.put("ind_user_id", obj.has("ind_user_id") ? obj.get("ind_user_id") : JSONObject.NULL);
      // 指示者名_姓
      bufJson.put("ind_user_last_name", obj.has("ind_user_last_name") ? obj.get("ind_user_last_name") : JSONObject.NULL);
      // 指示者名_名
      bufJson.put("ind_user_first_name", obj.has("ind_user_first_name") ? obj.get("ind_user_first_name") : JSONObject.NULL);
      // 更新者コード
      bufJson.put("upd_user_id", obj.has("upd_user_id") ? obj.get("upd_user_id") : JSONObject.NULL);
      // 更新者名_姓
      bufJson.put("upd_user_last_name", obj.has("upd_user_last_name") ? obj.get("upd_user_last_name") : JSONObject.NULL);
      // 更新者名_名
      bufJson.put("upd_user_first_name", obj.has("upd_user_first_name") ? obj.get("upd_user_first_name") : JSONObject.NULL);
      // 登録区分
      bufJson.put("input_class", obj.has("input_class") ? obj.get("input_class") : JSONObject.NULL);
      // 編集可否フラグ
      bufJson.put("is_editable", obj.has("is_editable") ? obj.get("is_editable") : JSONObject.NULL);
      // 連携オーダ番号
      bufJson.put("cop_order_no", obj.has("cop_order_no") ? obj.get("cop_order_no") : JSONObject.NULL);
      // 医療材料区分
      bufJson.put("equip_type", obj.has("equip_type") ? obj.get("equip_type") : JSONObject.NULL);
      equipInfoJson.put(bufJson);
    }
    outOrdMain.setRstEquipInfo(equipInfoJson.toString());
    // add FNSI-分類不一致判断の追加 徐 end

    //----------------------------------------------
    //ord_mainの更新

    res.isSuccess = this.updateOrdMain(outOrdMain, retVal);
    eventLogMessage.setLogMessage("10：ord_main更新成功有無：" + res.isSuccess);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(!res.isSuccess)
    {
      try {
      // ロールバック用の例外を投げる
      this.exitMethod(className,methodName,(String)retVal.get(PARAMKEY.RET_LOG_MSG));
      } catch (RuntimeException e) {
        res.isSuccess = false;
        res.ex = e;
        res.exMessage =retLogMsg;
        res.errorMessage= retMsg;
        return res;
      }
    }


    //TODO:再送信時もステータス変更があるか確認
    //TODO:SQLの||(連結)の確認 →型指定のための表現だった。cast(as char)に置き換え
    //----------------------------------------------
    //ステータスの更新(ord_mainとpat_main)
    //ord_mainの実績:治療状況(rst_dialysis_state)を設定
    //  mst_machineのcom_typeに応じて決定
    //    0：通信なし(オフライン運用)、3：医器工V4 の場合⇒"2"：条件送信確認済み
    //    上記以外の場合⇒"1"：条件送信済
    //  ※当処理のord_main更新時点ですでに"2"：条件送信確認済み 以降の場合は変更しない(DAOのSQLで判定)
    //ord_mainの実績:条件送信日時(rst_cond_send_date)の更新(mnt_machine_stateの条件送信日時cond_send_dateで更新)
    //pat_mainの治療進捗状態(acceptance_status_info)(Json)のclassをord_mainの実績:治療状況と同値に設定
    //operateStatusUtil.changeTreatStatusOrdAndPat:
    //    ステータス                             ord_mainのステータス変更以外の処理
    //    1：条件送信済                ※実績：条件送信日時も設定。pat_mainは区分のみ設定(値は何もしない)

    //-----------------------------------------------------
    //通信種別に応じてrst_dialysis_stateの値を決定する
    eventLogMessage.setLogMessage("13：mst_machine取得開始");
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    ComTypeAndFormatCd comTypeAndFormatCd = mstMachineDao.selectComTypeAndFormatCd(facilityCd, machineTypeCd, machineSerial);
    if (comTypeAndFormatCd == null) {
      //mst_machineからのデータ取得に失敗
      String fmt = "mst_machineからのデータ取得に失敗しました facilityCd:%s machineTypeCd:%s machineSerial:%s"  ;
      retLogMsg = String.format(fmt, facilityCd, machineTypeCd, machineSerial) ;
      retMsg = "装置情報の取得に失敗しました。";
//      // エラーステータス設定
//      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
//      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
//      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg);
      try {
        // ロールバック用の例外を投げる
        this.exitMethod(className, methodName, retLogMsg);
      } catch (RuntimeException e) {
        res.isSuccess = false;
        res.ex = e;
        res.exMessage =retLogMsg;
        res.errorMessage= retMsg;
        return res;
      }
    }

    final int comType = Optional.ofNullable(comTypeAndFormatCd.getComType()).orElse(0);
    eventLogMessage.setLogMessage("13：mst_machine取得終了 通信種別：" + comType);
    eventLogMessage.setSqlIdentification("facilityCd = " + facilityCd + ",machineTypeCd=" + machineTypeCd + ",machineSerial=" + machineSerial);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, "MstMachineDao/selectComTypeAndFormatCd");
    String settingStatus = null ;
    if (0 == comType || 3 == comType) {
      //0：通信なし(オフライン運用)、3：医器工V4 の場合
      //"2"：条件送信確認済み とする
      // mod 実績：治療状況（ord_main.rst_dialysis_state）の状態変更 高 start
      // settingStatus = STATUS.ENSURE_SENDCOND.get();
      settingStatus = STATUS.DONE_SENDCOND.get();
      // mod 実績：治療状況（ord_main.rst_dialysis_state）の状態変更 高 end
    }
    else
    {
      //"1"：条件送信済 とする
      settingStatus = STATUS.DONE_SENDCOND.get();
    }
    res.isSuccess =  changeTreatStatusOrdAndPat(patIdFromOrdMain, ordNo, settingStatus, null, null) ;
    eventLogMessage.setLogMessage("13：ord_mainおよびpat_mainのステータスの更新成功有無：" + res.isSuccess);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("13：パラメータordNo：" + ordNo);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("13：パラメータsettingStatus：" + settingStatus);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(!res.isSuccess )
    {
      //ステータスの更新失敗
      retLogMsg = "ord_mainおよびpat_mainのステータスの更新に失敗しました" ;
      retMsg = "治療状況の更新に失敗しました。" ;
//      // エラーステータス設定
//      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
//      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
//      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg);
      try {
        // ロールバック用の例外を投げる
        this.exitMethod(className, methodName, retLogMsg);
      } catch (RuntimeException e) {
        res.isSuccess = false;
        res.ex = e;
        res.exMessage =retLogMsg;
        res.errorMessage= retMsg;
        return res;
      }
    }

    res.isSuccess = true;

//    //ロールバック確認用     TODO:済んだら削除
//    if(res.isSuccess) {
//      //わざと失敗 -> ここまでの更新が全てなかったことになるのが正常(ロールバックが実行された)
////       exitMethod(className,methodName,"ロールバック確認のためのコード");
//    }

    //----------------------------------------------
    //戻り値の返却
//    retVal.put(PARAMKEY.STATUS, HttpStatus.OK) ;
//    retVal.put(PARAMKEY.RET_MSG, retMsg) ;
//    retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;


//    //終了ログ
//    exitMethod(className,methodName,null);
    // 加算処理
    AdditionCalculationRequest request = new AdditionCalculationRequest();
    request.setFacilityCd(facilityCd);
    request.setOrdNo(ordNo);
    request.setPatId(patIdFromOrdMain);
    request.setEventId(3);
    additionCalculationService.calculationAddition(request);

    return res;
  }

  /**
   *  条件送信結果処理を行う(ord_mainの組み立て)
   *
   * @param Long        ordNo               オーダー番号
   * @param OrdMain     ordMainData         ord_mainデータ
   * @param Timestamp   rstCondSendDate     実績条件送信日時
   * @param String      rstDialysisState    実績:治療状況(nullの時は何もしない)
   * @param boolean     cryptoFlag          false:暗号化しない(処理的には取得時に復号する)

   * @param retVal  PARAMKEY:value    パラメータ授受用
   *        PARAMKEY.STATUS     Httpステータス
   *        PARAMKEY.RET_MSG    メッセージ
   *        PARAMKEY.RET_LOG_MSG    詳細メッセージ
   * @return OrdMainエンティティ
   */
  private OrdMain buildResultOrdMainEntity(
    Long ordNo,
    OrdMain ordMainData,
//    Timestamp rstCondSendDate,
    String rstDialysisState,
    boolean cryptoFlag,
    Map<PARAMKEY, Object> retVal
  ) throws JSONException
  {
    //結果返却用     エラーメッセージ
    String retMsg = "", retLogMsg = "";

    //クラス名の取得(ログ用)
    final String className = new Object(){}.getClass().getEnclosingClass().getName();
    //メソッド名の取得(ログ用)
    final String methodName = new Object(){}.getClass().getEnclosingMethod().getName();

    //----------------------------------------------
    //DIの確認 ここから

//    /**
//     * ステータス変更用DI
//     */
//    if(null == operateStatusUtil) {
//      //DIに失敗
//      retMsg = "operateStatusUtilのDIに失敗しました"  ;
//      // エラーステータス設定
//      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
//      // エラーメッセージ設定
//      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
//      retVal.put(PARAMKEY.RET_LOG_MSG, retMsg) ;
//      //異常終了
//      return null;
//    }

//    /**
//     * DBアクセス 3010 DB6用DI
//     */
//    if(null == conditionSendResultUtilUserService) {
//      //DIに失敗
//      retMsg = "conditionSendResultUtilUserServiceのDIに失敗しました"  ;
//      // エラーステータス設定
//      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
//      // エラーメッセージ設定
//      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
//      retVal.put(PARAMKEY.RET_LOG_MSG, retMsg) ;
//      //異常終了
//      return null;
//    }
//
//    /**
//     * DBアクセス 3010 DB5用DI
//     */
//    if(null == conditionSendResultUtilService) {
//      //DIに失敗
//      retMsg = "conditionSendResultUtilServiceのDIに失敗しました"  ;
//      // エラーステータス設定
//      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
//      // エラーメッセージ設定
//      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
//      retVal.put(PARAMKEY.RET_LOG_MSG, retMsg) ;
//      //異常終了
//      return null;
//    };

    //DIの確認 ここまで
    //----------------------------------------------

    //開始ログ
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(className + "." + methodName + "の処理を開始しました。");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    //-----------------------------------------------------
    //値の収集 ここから

    //------------------------------------------------------------
    //ord_mainから患者IDを取得(次患者チェック用)
    Long patIdFromOrdMain = ordMainData.getPatId();

    Long nextPatId = patIdFromOrdMain;

    String facilityCd = ordMainData.getFacilityCd();

    //------------------------------------------------------------
    //条件送信済みかどうかの確認(ord_main:実績治療状況(rst_dialysis_state)が0以外)
    //現行ソースのコメント:透析番号が既に割り振られているかチェックを行う
    Long nowStatus = parseLong(ordMainData.getRstDialysisState()) ;

    boolean reSendFlag = false ;        //再送信フラグ true:再送信処理

    eventLogMessage.setLogMessage("07-1：対象患者確認");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("07-1：：患者ID：" + nextPatId);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("07-1：：患者状況：" + nowStatus);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(null != nowStatus  && nowStatus > 0)
    {
      reSendFlag = true ;

      //以下の処理は、初回送信時とほぼ同じなので、初回送信での処理にreSendFlagで判定して差分の処理を追加する

      //TODO:実績展開処理

      //      患者情報を取得
      //      クール情報取得
      //      患者CTR情報取得
      //      設定時にベースとなる時間を取得する
      //      体重計の測定時刻を取得する  　再送信が行われても一番最初に測定した時刻が入室時刻になるため
      //      透析スケジュールから、指示IDと治療方法コードと同日複数回を取得する
      //      透析実績 更新
      //      透析実績測定体重　更新、
      //      透析実績風袋補正　削除＆挿入
      //      透析実績除水量補正　削除＆挿入
      //      透析実績装置設定　削除＆挿入
      //      指示共通関数の初期化
      //      予定指示取得
      //      透析実績透析条件　削除＆挿入
      //      透析実績医療材料　削除＆挿入
      //      透析実績投薬　削除＆挿入　※投薬実施済みの薬剤は残して、実施済みでない投薬指示実績は削除する
      //      透析実績補足指示　削除＆挿入
      //      透析実績レセプトメモ　更新
      //      チェックリストに透析実績番号を入れる　更新
      //      透析スケジュールに実績透析番号を設定する　更新
      //      透析工程管理テーブルの透析予定開始時間から、透析時間を足して透析予定終了時間を算出する
      //      透析工程管理テーブル更新前に、対象ベッドの透析状態を確認
      //      透析中(運転開始 ～ 排液前)の場合、透析工程管理テーブル更新処理はスキップ
      //      透析工程に存在する全患者の透析状態を取得
      //      　全てがOKの場合は、透析工程管理に以下を設定する 　更新：・透析番号 ・患者ID　・透析予定終了時間
      //      ステータスを処理完了にする

      //TODO:ここで処理しない場合は、以下削除
      //      retMsg = "実績展開処理"  ;
      //      retVal.put(PARAMKEY.STATUS, HttpStatus.OK) ;
      //      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      //      return ;
    }

    //------------------------------------------------------------
    //実績：血液浄化装置名称   治療方法が「特殊浄化」の場合、固定文字列「血液浄化装置」を入れる
    //※ord_mainの項目(ord_main更新時に一緒に更新する)
    String bloodPurifierName = null ;

    eventLogMessage.setLogMessage("07-2：対象ord_no：" + ordNo);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    boolean isDeviceModeIsPureOrNot = checkDeviceModeIsPureOrNot(ordNo);
    if(isDeviceModeIsPureOrNot)
    {
      //治療方法が「特殊浄化」だったので、固定文言を格納
      bloodPurifierName = CONSTDEF.DISP_PURIFICATION.get();
    }

    //------------------------------------------------------------
    //pat_mainからのデータ取得 ※実績:装置設定のために装置設定を取得
    PatMain patMainData = getPatMainInfo(nextPatId) ;

    eventLogMessage.setLogMessage("07-3：patMain取得：" + patMainData);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(null == patMainData)
    {
      //pat_mainのデータ取得に失敗
      String fmt = "pat_mainのデータ取得に失敗しました  pat_id:%s"  ;
      retLogMsg = String.format(fmt, patIdFromOrdMain) ;
      retMsg = "患者取得に失敗しました。";
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
      //異常終了
      return null;
    }

    //------------------------------------------------------------
    //pat_uniqueからのデータ取得
    PatUnique patUniqueData = getPatUniqueInfo(nextPatId) ;

    eventLogMessage.setLogMessage("07-4：patUnique取得：" + patUniqueData);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(null == patUniqueData)
    {
      //pat_uniqueのデータ取得に失敗
      String fmt = "pat_uniqueのデータ取得に失敗しました  pat_id:%s"  ;
      retLogMsg = String.format(fmt, patIdFromOrdMain) ;
      retMsg = "患者身体情報の取得に失敗しました。"  ;
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
      //異常終了
      return null;
    }

    //共通診療情報の取得(pat_mainから)
    //共通診療情報から以下のコードを取得するため
    // 病棟コード
    // 診療科コード(透析実施科コード)

    //共通診療情報の取得
    String medicalCareInfo = patMainData.getMedical_care_info() ;

    //共通診療情報のJson化
    JSONObject medicalCareInfoJson = null ;
    eventLogMessage.setLogMessage("07-5：medicalCareInfo取得：" + medicalCareInfo);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    try {
      medicalCareInfoJson = new JSONObject(medicalCareInfo) ;
    }
    catch(Exception e)
    {
      medicalCareInfoJson = null ;
    }
    //実績：病棟コードの取得(nulllの可能性あり)
    Integer rstWardCd = parseInteger(getValueFromJson(medicalCareInfoJson,PARAMKEY.WARD_CD.get())) ;
    eventLogMessage.setLogMessage("07-6：病棟コード取得：" + rstWardCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    //実績：診療科コード(透析実施科コード)の取得(nulllの可能性あり)
    Integer rstCourseCd = parseInteger(getValueFromJson(medicalCareInfoJson,PARAMKEY.DIALYSIS_COURSE_CD.get())) ;
    eventLogMessage.setLogMessage("07-6：診療科コード取得：" + rstCourseCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    //実績：透析回数の取得(nullの可能性あり)
    Integer rstDialysisCnt = ordMainData.getRstDialysisCnt();
    Integer dialysisCnt = null;
    eventLogMessage.setLogMessage("07-6：特殊浄化フラグ：" + isDeviceModeIsPureOrNot);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if (isDeviceModeIsPureOrNot) {
      dialysisCnt = parseInteger(getValueFromJson(medicalCareInfoJson,PARAMKEY.PURIFICATION_COUNT.get()));
    } else {
      dialysisCnt = parseInteger(getValueFromJson(medicalCareInfoJson,PARAMKEY.DIALYSIS_COUNT.get()));
    }
    rstDialysisCnt = dialysisCnt == null ? 0 + 1: dialysisCnt + 1;
    eventLogMessage.setLogMessage("07-6：透析回数or浄化治療回数取得：" + rstDialysisCnt);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    //------------------------------------------------------------
    //病棟名および診療科名をDBから取得する
    // 取得したコードに紐付く名称を取得
    // 病棟コード->mst_ward.病棟名
    // 診療科コード(透析実施科コード)->mst_course.診療科名
    Map<String,Object> namesMapByCd = getWardAndCourseName(
      facilityCd,
      rstWardCd,
      rstCourseCd
    ) ;
    eventLogMessage.setLogMessage("07-6：病棟名および診療科名取得：" + namesMapByCd);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(null == namesMapByCd)
    {
      //病棟名または診療科名の取得失敗
      String fmt = "病棟名または診療科名の取得に失敗しました  施設コード:%s 病棟コード:%s 診療科コード:%s"  ;
      retLogMsg = String.format(fmt, facilityCd, rstWardCd, rstCourseCd) ;
      retMsg = "病棟名・診療科名の取得に失敗しました。"  ;
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg);
      //異常終了
      return null;
    }

    //実績：病棟名(mst_wardから)の取得
    String rstWardName = (String)namesMapByCd.get(PARAMKEY.WARD_NAME.get()) ;
    //実績：診療科名(mst_courceから)の取得
    String rstCourseName = (String)namesMapByCd.get(PARAMKEY.COURSE_NAME.get()) ;

    //実績：DW TODO:SQL取得への差し替えの場合あり
    //pat_uniqueの身体情報から取得する
    //身体情報はJson配列
    //以下の条件をすべて満たす配列要素(Json)のdwを採用する
    //1.最新の検査日付
    //2.dwに値が設定されている

    Double rstDw = (Double)null ;       //TODO:格納処理の開放

    JSONArray physical_info = null ;
    String ordMainTreatDate = ordMainData.getTreatDate();

    try {
      physical_info = new JSONArray(patUniqueData.getPhysical_info()) ;
    }
    catch(Exception e)
    {
      physical_info =  null ;
    }
    rstDw = parseDouble(getValueFromJson(
      getDataFromPhysicalInfo(physical_info,PARAMKEY.DW.get(), ordMainTreatDate),
      PARAMKEY.DW.get()
    )) ;
    eventLogMessage.setLogMessage("07-7：実績DW取得：" + rstDw);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(rstDw == null) rstDw = Double.valueOf(0);

    //------------------------------------------------------------
    //名称の取得
    //ord_mainの各コード項目の名称等を該当テーブルから取得する
    // 施設名       mst_facility
    // 治療方法名 mst_treatment
    // クール名      mst_kur
    // ベッド名       mst_bed
    // 装置番号    mst_bed
    // 装置名        mst_machine

    Map<String,Object> namesMap = getNamesFromDbs(ordNo) ;
    eventLogMessage.setLogMessage("07-8：ord_main項目名称等を該当テーブルから取得：" + namesMap);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(null == namesMap)
    {
      //名称の取得失敗
      String fmt = "名称の取得に失敗しました  ordNo:%s"  ;
      retLogMsg = String.format(fmt, ordNo) ;
      retMsg = "治療指示の各項目の名称取得に失敗しました。"  ;
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg);
      //異常終了
      return null;
    }

    //各名称の取り出し
    // 施設名
    String facilityName = (String)getValueFromMap(namesMap,PARAMKEY.FACILITY_NAME.get()) ;
    // 指示：治療方法名
    String indTreatmentName = (String)getValueFromMap(namesMap,PARAMKEY.TREATMANT_NAME.get()) ;
    // 指示：クール名
    String indKurName = (String)getValueFromMap(namesMap,PARAMKEY.KUR_NAME.get()) ;
    // 指示：ベッド名
    String indBedName = (String)getValueFromMap(namesMap,PARAMKEY.BED_NAME.get()) ;
    // 実績：装置番号(nullの場合あり)
    Long rstMachineNo = parseLong(getValueFromMap(namesMap,PARAMKEY.MACHINE_NO.get())) ;
    // 実績：装置名
    String rstMachineName = (String)getValueFromMap(namesMap,PARAMKEY.MACHINE_NAME.get()) ;
    eventLogMessage.setLogMessage("07-8：施設名：" + facilityName);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("07-8：治療方法名：" + indTreatmentName);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("07-8：クール名：" + indKurName);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("07-8：ベッド名：" + indBedName);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("07-8：装置番号：" + rstMachineNo);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("07-8：装置名：" + rstMachineName);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);

    // 実績：入外区分
    //  入外区分をpat_personal_mainから取得する(db6)
    Short rstInOutClass = null ;
    try {
      rstInOutClass = Short.valueOf(getInOutClassbyPatId(nextPatId).toString()) ;
    }
    catch(Exception e)
    {
      rstInOutClass = null ;
    }

    //実績：体重情報 rst_weight_info
    //体重情報(Json)を組み立てる

    String rstWeightInfo = null ;

    //TODO:済 2019.03.27 項目が変わっている。コメント追加
    //以下、フォーマット ※のところは値が入るところ。その他は入らない
    //  {
    //  "weight_before": null ,       //前体重                      ※
    //  "weight_before_date": null,   //前体重測定日時      ※ISO8601
    //  "weight_after": null,         //後体重                      ※
    //  "weight_after_date": null,    //後体重測定日時      ※ISO8601
    //  "ctr": null,                  //CTR            ※
    //  "ctr_measure_date": null,     //CTR測定日時            ※ISO8601
    //  "ctr_weight": null,           //CTR測定時体重        ※ISO8601
    //  "water_removal_target": null, //目標除水量
    //  "water_removal_rst":          //(Number)実績除水量,
    //  "add_total": null,            //除水積算値
    //  "add_water_total": null,      //補液積算値
    //  "kt_v_measure": null,         //Kt/V測定値
    //  "urr": null,                  //URR
    //  "weight_decreased":           //(Number)減少量
    //  "re_loop_rate_main":          //(Number)治療記録で選択された再循環率の番号を格納
    //  "re_loop_rate_1": { "date": null, "value": null },    // 再循環率(1回目)
    //  "re_loop_rate_2": { "date": null, "value": null },    // 再循環率(2回目)
    //  "re_loop_rate_3": { "date": null, "value": null },    // 再循環率(3回目)
    //  "re_loop_rate_4": { "date": null, "value": null },    // 再循環率(4回目)
    //  "re_loop_rate_5": { "date": null, "value": null }     // 再循環率(5回目)
    //  }

    String rstWeight = (String)ordMainData.getRstWeightInfo() ;
    rstWeight = null == rstWeight ? "{}" : rstWeight ;
    JSONObject rstWeightInfoJson = new JSONObject(rstWeight) ;

    //以下の4項目は、すでに入っている
    //何もしない 前体重,
    //何もしない 前体重測定日時 (*1)
    //何もしない 後体重
    //何もしない 後体重測定日時 (*1)

    //TODO:済 CTR関連の値の取得
    //pat_uniqueの身体情報から取得する
    //身体情報はJson配列
    //以下の条件をすべて満たす配列要素(Json)のctrを採用する
    //1.最新の検査日付
    //2.ctrに値が設定されている

    JSONObject ctrObj = getDataFromPhysicalInfo(physical_info,PARAMKEY.J_CTR.get(), ordMainTreatDate);
    eventLogMessage.setLogMessage("07-9：身体情報取得：" + ctrObj);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    Double ctr = (Double)null;                  //CTR
    ctr = parseDouble(getValueFromJson(
      ctrObj,
      PARAMKEY.J_CTR.get()
    )) ;
    eventLogMessage.setLogMessage("07-9：CTR取得：" + ctr);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    String ctrMeasureDate=(String)null;       //CTR測定日時(検査日時を採用)
    ctrMeasureDate = (String)getValueFromJson(
      ctrObj,
      PARAMKEY.J_CTR_EXAM_DATE.get()
    ) ;
    if (ctrMeasureDate != null) {
      Pattern pattern = Pattern.compile("T");
      Matcher matcher = pattern.matcher(ctrMeasureDate);
      ctrMeasureDate = matcher.find() ? ctrMeasureDate : ctrMeasureDate + "T00:00:00.000+09:00";
    }

    eventLogMessage.setLogMessage("07-9：CTR測定日時取得：" + ctrMeasureDate);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    Double ctrWeight = (Double)null;           //CTR測定時体重
    ctrWeight = parseDouble(getValueFromJson(
      ctrObj,
      PARAMKEY.J_CTR_WEIGHT.get()
    )) ;
    eventLogMessage.setLogMessage("07-9：CTR測定時体重取得：" + ctrWeight);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    rstWeightInfoJson.put(PARAMKEY.J_CTR.get(), ctr) ;
    rstWeightInfoJson.put(PARAMKEY.J_CTR_MEASURE_DATE.get(), ctrMeasureDate) ;
    rstWeightInfoJson.put(PARAMKEY.J_CTR_WEIGHT.get(), ctrWeight) ;

    //※キーの増減等があるため、キーの追加は保留(コメントアウトして残しておく)
    //以下の項目は存在していないはずだが、存在している場合も考慮する
    //キーの存在確認をおこない、なければキーを追加
    //    setJsonNonExistKeyAndValue(rstWeightInfoJson,PARAMKEY.J_WATER_REMOVAL_TARGET.get(),(String)null) ;
    //    setJsonNonExistKeyAndValue(rstWeightInfoJson,PARAMKEY.J_WATER_REMOVAL_TARGET.get(), (String)null) ;
    //    setJsonNonExistKeyAndValue(rstWeightInfoJson,PARAMKEY.J_ADD_TOTAL.get(), (String)null) ;
    //    setJsonNonExistKeyAndValue(rstWeightInfoJson,PARAMKEY.J_ADD_WATER_TOTAL.get(), (String)null) ;
    //    setJsonNonExistKeyAndValue(rstWeightInfoJson,PARAMKEY.J_KT_V_MEASURE.get(), (String)null) ;
    //    setJsonNonExistKeyAndValue(rstWeightInfoJson,PARAMKEY.J_URR.get(), (String)null) ;

    //条件送信タイミングで入っているはずなので、処理しない(コメントアウトして残しておく)
    //    for(int i = 1 ; i <= 5 ; i++)
    //    {
    //      JSONObject setJson = new JSONObject("{}") ;
    //      setJson.put(PARAMKEY.J_DATE.get(), (String)null);
    //      setJson.put(PARAMKEY.J_VALUE.get(), (String)null);
    //      setJsonNonExistKeyAndValue(rstWeightInfoJson,PARAMKEY.J_RE_LOOP_RATE_BASE.get()+i, (String)null);
    //    }

    rstWeightInfo = rstWeightInfoJson.toString() ;

    //"null" -> null に変換
    rstWeightInfo = parseJSONObjectNullToNormalNull(rstWeightInfo) ;
    eventLogMessage.setLogMessage("07-10：null置換");
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    //値の収集 ここまで
    //-----------------------------------------------------

    //-----------------------------------------------------
    //名前部分の置き換え ここから
    //id,cdだけが設定されている状態なので、対応する名称をテーブルから取得、設定する

    //各Jsonの指示者、更新者は、idだけが設定されている状態なので、
    //mst_personal_user(db6)から該当レコードを取得して
    //名前(姓)、名前(名)に設定する

    //置き換えのキー定義(idのキー名および名前(姓)、名前(名)のキー名)
    String[][] keys = {
      {"ind_user_id","ind_user_last_name","ind_user_first_name"},
      {"upd_user_id","upd_user_last_name","upd_user_first_name"}
    } ;

    //指示：治療予定指示者情報 ind_schedule_user_info
    //指示：治療予定指示者情報の指示者、更新者の姓名設定
    String indScheduleUserInfo = ordMainData.getIndScheduleUserInfo() ;
    eventLogMessage.setLogMessage("07-11：指示：治療予定指示者情報の指示者、更新者の姓名設定：パラメータチェック");
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("07-11：指示：治療予定指示者情報の指示者、更新者の姓名設定：パラメータチェック");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("07-11：keys" + keys);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("07-11：facilityCd" + facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("07-11：cryptoFlag" + cryptoFlag);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("07-11：CAT_JSON_PATTERN" + CAT_JSON_PATTERN.STRING);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    indScheduleUserInfo = fillNamesJson(
      indScheduleUserInfo,
      keys,
      facilityCd,
      cryptoFlag,
      CAT_JSON_PATTERN.STRING
    );

    if(null == indScheduleUserInfo)
    {
      //指示：治療予定指示者情報の指示者、更新者の姓名設定に失敗
      retLogMsg = "指示：治療予定指示者情報の指示者、更新者の姓名設定に失敗しました。"  ;
      retMsg = "治療予定指示者・更新者情報の取得に失敗しました。"  ;
//      // エラーステータス設定
//      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg);
      //異常終了
      return null;
    }

    dbgPrint("indScheduleUserInfo:" + indScheduleUserInfo);

    //------------------------------------------------------------
    //指示：治療条件情報             ind_cond_info               キー付きJson {"":{},"":{}・・・・,"":{}}

    //登録者、更新者の名前取得設定
    String indCondInfo = ordMainData.getIndCondInfo() ;
    eventLogMessage.setLogMessage("07-12：登録者、更新者の名前取得設定：パラメータチェック");
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("07-12：indCondInfo" + indCondInfo);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("07-12：CAT_JSON_PATTERN" + CAT_JSON_PATTERN.KEYVALUE);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    indCondInfo = fillNamesJson(
      indCondInfo,
      keys,
      facilityCd,
      cryptoFlag,
      CAT_JSON_PATTERN.KEYVALUE
    );

    if(null == indCondInfo)
    {
      //指示：治療条件情報の指示者、更新者の姓名設定に失敗
      retLogMsg = "指示：治療条件情報の指示者、更新者の姓名設定に失敗しました。"  ;
      retMsg = "治療条件指示者・更新者情報の取得に失敗しました。"  ;
//      // エラーステータス設定
//      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg);
      //異常終了
      return null;
    }

    dbgPrint("indCondInfo:" + indCondInfo);

    //指示：治療条件情報のJson化
    JSONObject jObj = new JSONObject(indCondInfo) ;

    //------------------------------------------------------------
    //指示：治療条件情報は、valueに値ではなくコードが設定されているものがあり、
    //その場合、コードに対応する名称を翻訳1フィールド(name_1)に設定する
    //(ダイアライザだけは、翻訳2フィールド(name_2)も設定する)
    //------------------------------------------------------------

    //------------------------------------------------------------
    //ダイアライザ系(mst_dialyzerから名称を取得する)
    //    5 ダイアライザ         mst_dialyzer.dialyzer_cd

    JSONObject itemObj = (JSONObject)jObj.get(DIALYSISCOND.COND_DIALYZER.get()) ;
    Integer dialyzerCd = this.parseInteger(getValueFromJson(itemObj,PARAMKEY.COND_VALUE.get())) ;

    //ダイアライザだけ名称が2個:型番(value_name_1用)とメーカー名(value_name_2用)を取得

    //取得したコードを元にダイアライザマスタから名称を取得(DBから)
    eventLogMessage.setLogMessage("07-13：ダイアライザマスタ取得：パラメータチェック");
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("07-13：facilityCd" + facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    eventLogMessage.setLogMessage("07-13：dialyzerCd" + dialyzerCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    Map<String,Object> dialyzerMap = getDialyzerNames(
      facilityCd,
      dialyzerCd) ;
    // TODO: 手動実績作成が失敗するので一旦コメントアウト
    // if(null == dialyzerMap)
    // {
    //   //ダイアライザマスタから名称取得に失敗
    //   retMsg = "ダイアライザマスタから名称取得に失敗しました。facilityCd:%s dialyzerCd:%s"  ;
    //   retMsg = String.format(retMsg, facilityCd,dialyzerCd) ;
    //   // エラーステータス設定
    //   retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
    //   // エラーメッセージ設定
    //   retVal.put(PARAMKEY.RET_MSG, retMsg) ;
    //   //異常終了
    //   return null;
    // }
    //翻訳1:型番
    itemObj.put(PARAMKEY.COND_NAME_1.get(), getValueFromMap(dialyzerMap,PARAMKEY.COND_MODEL_NUMBER.get())) ;
    //翻訳2:メーカー名
    itemObj.put(PARAMKEY.COND_NAME_2.get(), getValueFromMap(dialyzerMap,PARAMKEY.COND_MAKER.get())) ;

    //------------------------------------------------------------
    //医療材料系(mst_equipmentから名称を取得する)
    //    6 吸着カラム          mst_equipment.equipment_cd
    //    7 1次膜                 mst_equipment.equipment_cd
    //    8 2次膜                 mst_equipment.equipment_cd
    //    13 血液回路          mst_equipment.equipment_cd
    //    9 穿刺針(A針)  mst_equipment.equipment_cd
    //    10 穿刺針(V針) mst_equipment.equipment_cd
    //    11 穿刺針(SN)  mst_equipment.equipment_cd

    String[] itemListEqu = {
      //吸着カラム
      DIALYSISCOND.COND_ADSORB_EQUIPMENT.get(),
      //1次膜
      DIALYSISCOND.COND_FIRST_FILM.get(),
      //2次膜
      DIALYSISCOND.COND_SECOND_FILM.get(),
      //血液回路
      DIALYSISCOND.COND_BLOOD_CIRCUIT.get(),
      //穿刺針(せんししん)(A針)
      DIALYSISCOND.COND_PUNCTURE_NEEDLE_A.get(),
      //穿刺針(せんししん)(V針)
      DIALYSISCOND.COND_PUNCTURE_NEEDLE_V.get(),
      //穿刺針(せんししん)(SN針)
      DIALYSISCOND.COND_PUNCTURE_NEEDLE_SN.get()
    };

    boolean retEq = setIndCondInfoNames(PARAMKEY.COND_CAT_EQUIP.get(),facilityCd,itemListEqu,jObj) ;
    eventLogMessage.setLogMessage("07-14：医療材料の名称情報取得設定成功有無：" + retEq);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(!retEq)
    {
      //医療材料の名称情報取得設定に失敗
      retLogMsg = "医療材料の名称情報取得設定に失敗しました。" ;
      retMsg = "医療材料名の取得に失敗しました。" ;
//      // エラーステータス設定
//      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg);
      //異常終了
      return null;
    }

    //------------------------------------------------------------
    //VA系(mst_vaから名称を取得する)
    //    2 VA  mst_va.va_cd

    String[] itemListVA = {
      //VA
      DIALYSISCOND.COND_VA.get()
    };

    boolean retVa = setIndCondInfoNames(PARAMKEY.COND_CAT_VA.get(),facilityCd,itemListVA,jObj) ;
    eventLogMessage.setLogMessage("07-15：VAの名称情報取得設定成功有無：" + retVa);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(!retVa)
    {
      //VAの名称情報取得設定に失敗
      retLogMsg = "VAの名称情報取得設定に失敗しました。" ;
      retMsg = "VA名の取得に失敗しました。" ;
//      // エラーステータス設定
//      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg);
      //異常終了
      return null;
    }

    //------------------------------------------------------------
    //薬剤系(mst_medicineまたはmst_medicine_mixから名称を取得する)
    //1.薬剤区分(1: 通常薬剤、2: 調製薬剤)で取得先テーブルを選択して名称セット
    //    15 透析液             mst_medicine.medicine_cd or mst_preparation_medicine.preparation_medicine_cd
    //    19 補液                 mst_medicine.medicine_cd or mst_preparation_medicine.preparation_medicine_cd
    //    25 抗凝固剤         mst_medicine.medicine_cd or mst_preparation_medicine.preparation_medicine_cd

    String[] itemListMedic = {
      //透析液
      DIALYSISCOND.COND_DIALYZE_LIQUID.get(),
      //補液
      DIALYSISCOND.COND_REPLENISH_LIQUID.get(),
      //抗凝固剤
      DIALYSISCOND.COND_ANTICOAGULAN_LIQUID.get()
    };

    //overloaded method(setIndCondInfoNames) ※オーバーロードしてます
    //TODO:薬剤マスタまたは調製薬剤マスタからデータを取得する実装となっている。条件はjobjの当該項目medicineType。
    //TODO:調製薬剤が取られるのは実装時は抗凝固剤のみのため、透析液・補液の調製薬剤取得による動作保証無し
    boolean retMedic = setIndCondInfoNames(facilityCd,itemListMedic,jObj) ;
    eventLogMessage.setLogMessage("07-16：薬剤の名称情報取得設定成功有無：" + retMedic);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(!retMedic)
    {
      //薬剤の名称情報取得設定に失敗
      retLogMsg = "薬剤の名称情報取得設定に失敗しました。" ;
      retMsg = "薬剤名の取得に失敗しました。" ;
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg);
      //異常終了
      return null;
    }

    //------------------------------------------------------------
    //2.jobj(治療条件)に対して項目によってunit（単位)のセットとvalue(数値)に対する小数点以下桁数の付与処理を行う
    //    17 透析液使用数   15:透析液コードよりunit_second/unit及び unit_decimal_point_second/unit_decimal_pointを取得
    //    22 補液使用数     19:補液コードよりunit_second/unit及び unit_decimal_point_second/unit_decimal_pointを取得
    //    26 抗凝固剤ワンショット量   25:抗凝固剤コードよりunit及び unit_decimal_pointを取得
    //    27 抗凝固剤持続速度        25:抗凝固剤コードよりunit及び unit_decimal_pointを取得
    //    28 抗凝固剤持続総量        25:抗凝固剤コードよりunit及び unit_decimal_pointを取得
    //    ※透析液及び補液は調製薬剤にセットされない想定だが、セットされた場合にはレセ単位が無いため通常の値を表示する仕様としている

    String[] itemListUnitAndPoint = {
      //透析液使用数
      DIALYSISCOND.COND_DIALYZE_MEASURE.get(),
      //補液使用数
      DIALYSISCOND.COND_REPLENISH_USE.get(),
      //抗凝固剤ワンショット量
      DIALYSISCOND.COND_ANTICOAGULAN_ONESHOT.get(),
      //抗凝固剤持続速度
      DIALYSISCOND.COND_ANTICOAGULAN_SPEED.get(),
      //抗凝固剤持続総量
      DIALYSISCOND.COND_ANTICOAGULAN_TOTAL.get()
    };

    // 基本処理はsetIndCondInfoNamesをベースとし、nameの代わりにunit値とvalueの小数点桁数のセットを行う
    // TODO:薬剤マスタまたは調製薬剤マスタからデータを取得する実装となっている。
    //      条件はjobjの対応項目medicineType(例:透析液使用数なら対応する透析液のmedicineType)
    boolean retUnit = setIndCondInfoUnitAndPoint(facilityCd,itemListUnitAndPoint,jObj) ;
    eventLogMessage.setLogMessage("07-17：薬剤の単位及び小数点桁数制御：" + retUnit);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(!retUnit)
    {
      //薬剤の名称情報取得設定に失敗
      retLogMsg = "薬剤の単位及び小数点桁数制御設定に失敗しました。" ;
      retMsg = "薬剤情報の取得に失敗しました。" ;
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg);
      //異常終了
      return null;
    }

    //指示：治療条件情報のJson化したものをStringに戻す
    indCondInfo = jObj.toString();

    //------------------------------------------------------------
    //指示：投与薬剤情報             ind_medi_info              配列Json [{},{},・・・{}]

    String indMediInfo = ordMainData.getIndMediInfo() ;
    indMediInfo = fillNamesJson(
      indMediInfo,
      keys,
      facilityCd,
      cryptoFlag,
      CAT_JSON_PATTERN.DIM
    );

    eventLogMessage.setLogMessage("07-18：指示：投与薬剤情報の指示者、更新者の姓名設定：" + indMediInfo);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(null == indMediInfo)
    {
      //指示：投与薬剤情報の指示者、更新者の姓名設定に失敗
      retLogMsg = "指示：投与薬剤情報の指示者、更新者の姓名設定に失敗しました。"  ;
      retMsg = "投与薬剤情報の指示者、更新者の設定に失敗しました。"  ;
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg);
      //異常終了
      return null;
    }

    dbgPrint("indMediInfo:" + indMediInfo);

    //投与薬剤情報の穴埋め(ユーザ名関連以外)
    //  薬剤分類コード          mst_medicine.class_cd             or mst_preparation_medicine.class_cd
    //  薬剤分類名               mst_medicine_class.class_name
    //  分類区分                   mst_medicine_class.class_type
    //  薬剤名                       mst_medicine.medicine_name        or mst_preparation_medicine.preparation_medicine_name
    //  省略薬剤名               mst_medicine.medicine_short_name  or mst_preparation_medicine.preparation_medicine_short_name
    //  単位                           mst_medicine.unit                 or mst_preparation_medicine.unit
    //  投与タイミング名称     mst_medicate_timing.medicate_timing_name
    //  手技名称                   mst_procedure.pricedure_name
    //実施情報のキー追加   TODO:済 実績のみに入れるように制御
    //  投与実施フラグ  未実施 ※0：未実施、1：実施済み → 0
    //  投与実施日時 ※ISO8601形式 → null
    //  投与実施者コード → null
    //  投与実施者名_姓 → null
    //  投与実施者名_名 → null


    //実績：投与薬剤情報の格納変数
    String rstMediInfo = null ;
    //投与薬剤情報の穴埋め処理
    Map<String,String> mapMediInfo = setMedicineInfo(indMediInfo,rstMediInfo,facilityCd) ;
    eventLogMessage.setLogMessage("07-18：指示：投与薬剤情報の指示者、更新者の姓名設定：" + indMediInfo);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(null == mapMediInfo)
    {
      //指示：投与薬剤情報の名称設定に失敗
      retLogMsg = "指示：投与薬剤情報の名称設定に失敗しました。"  ;
      retMsg = "投与薬剤名の取得に失敗しました。"  ;
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg);
      //異常終了
      return null;
    }

    //指示:投与薬剤情報用の値の取得
    indMediInfo = mapMediInfo.get(PARAMKEY.MEDI_IND_INFO.get()) ;
    //実績:投与薬剤情報用の値の取得
    rstMediInfo = mapMediInfo.get(PARAMKEY.MEDI_RST_INFO.get()) ;

    //再送信の場合の追加処理
    if(reSendFlag && ordMainData.getRstMediInfo() != null)
    {
      //再送信時は、実績:投薬情報の投薬済み(投与実施フラグ:"1")の情報は残して、ここまでで名称穴埋め+実施情報の付加の終わっている実績:投薬情報へマージする
      eventLogMessage.setLogMessage("07-20-1：指示：投与薬剤情報：");
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      eventLogMessage.setLogMessage("07-20-1：ordMainData.getRstMediInfo()：" + ordMainData.getRstMediInfo());
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      eventLogMessage.setLogMessage("07-20-1：rstMediInfo：" + rstMediInfo);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      rstMediInfo = mergeRstMediIntoIndMedi(ordMainData.getRstMediInfo(),rstMediInfo) ;
    }

    //"null" -> null 変換
    indMediInfo = parseJSONObjectNullToNormalNull(indMediInfo) ;
    eventLogMessage.setLogMessage("07-20：null置換");
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    dbgPrint("indMediInfo:" + indMediInfo);


    //TODO:ここからレビュー再開2019.03.19
    //------------------------------------------------------------
    //指示：医療材料情報             ind_equip_info              配列Json [{},{},・・・{}]
    String indEquipInfo = ordMainData.getIndEquipInfo() ;
    indEquipInfo = fillNamesJson(
      indEquipInfo,
      keys,
      facilityCd,
      cryptoFlag,
      CAT_JSON_PATTERN.DIM
    );

    eventLogMessage.setLogMessage("07-21：医療材料情報の指示者、更新者の姓名設定" + indEquipInfo);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(null == indEquipInfo)
    {
      //指示：医療材料情報の指示者、更新者の姓名設定に失敗
      retLogMsg = "指示：医療材料情報の指示者、更新者の姓名設定に失敗しました。"  ;
      retMsg = "医療材料の指示者、更新者の取得に失敗しました。"  ;
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg);
      //異常終了
      return null;
    }

    dbgPrint("indEquipInfo:" + indEquipInfo);

    //指示：医療材料情報の穴埋め
    //  医療材料分類コード       mst_equipment.class_cd
    //  医療材料分類名            mst_equipment_class.class_name
    //  分類区分                        mst_equipment_class.class_type
    //  医療材料名                    mst_equipment.equipment_name
    //  省略医療材料名            mst_equipment.equipment_short_name
    //  単位                                mst_equipment.unit
    indEquipInfo = setEquipmentInfo(indEquipInfo,facilityCd) ;

    if(null == indEquipInfo)
    {
      //指示：医療材料情報の名称設定に失敗
      retLogMsg = "指示：医療材料情報の名称設定に失敗しました。"  ;
      retMsg = "医療材料名の取得に失敗しました。"  ;
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg);
      //異常終了
      return null;
    }

    //"null" -> null 変換
    indEquipInfo = parseJSONObjectNullToNormalNull(indEquipInfo) ;
    eventLogMessage.setLogMessage("07-22：null置換");
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    dbgPrint("indEquipInfo:" + indEquipInfo);

    //------------------------------------------------------------
    //指示：指示コメント情報           ind_ind_comment_info        配列Json [{},{},・・・{}]
    String indIndCommentInfo = ordMainData.getIndIndCommentInfo() ;
    indIndCommentInfo = fillNamesJson(
      indIndCommentInfo,
      keys,
      facilityCd,
      cryptoFlag,
      CAT_JSON_PATTERN.DIM
    );

    eventLogMessage.setLogMessage("07-23：指示：指示コメント情報の指示者、更新者の姓名設定" + indIndCommentInfo);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(null == indIndCommentInfo)
    {
      //指示：指示コメント情報の指示者、更新者の姓名設定に失敗
      retLogMsg = "指示：指示コメント情報の指示者、更新者の姓名設定に失敗しました。"  ;
      retMsg = "指示コメント情報の指示者、更新者の取得に失敗しました。"  ;
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg);
      //異常終了
      return null;
    }

    //"null" -> null 変換
    indIndCommentInfo = parseJSONObjectNullToNormalNull(indIndCommentInfo) ;
    eventLogMessage.setLogMessage("07-24：null置換");
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    dbgPrint("indIndCommentInfo:" + indIndCommentInfo);

    //名前部分の置き換え ここまで
    //-----------------------------------------------------

    // add FNSI-実績：登録区分の修正 徐 start
    //実績：登録区分 -> 「クライアントで手入力して作成」
    // Short rstInputClass = Short.valueOf(CONSTDEF.RST_INPUT_CLASS_MANUAL.get());
    //実績：登録区分 -> 通常(透析装置や通信サーバーなどを伴う治療)
    Short rstInputClass;
    if (Strings.isNullOrEmpty(rstDialysisState)) {
      // 実績：登録区分 -> 「透析装置や通信サーバーなどを伴う治療」
      rstInputClass = Short.valueOf(CONSTDEF.RST_INPUT_CLASS_DEFAULT.get());
    } else {
      //実績：登録区分 -> 「クライアントで手入力して作成」
      rstInputClass = Short.valueOf(CONSTDEF.RST_INPUT_CLASS_MANUAL.get());
    }
    // add FNSI-実績：登録区分の修正 徐 end
    eventLogMessage.setLogMessage("07-25：実績：登録区分取得" + rstInputClass);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    //-----------------------------------------------------
    //指示:風袋補正→実績:風袋補正への展開

    String rstTareInfo = extendIndTareInfoToRstTareInfo(
      ordMainData.getIndTareInfo(),
      ordMainData.getRstTareInfo()
    ) ;

    eventLogMessage.setLogMessage("07-26：指示:風袋補正→実績:風袋補正への展開" + rstTareInfo);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(null == rstTareInfo)
    {
      //指示:風袋補正→実績:風袋補正への展開に失敗
      retLogMsg = "指示:風袋補正→実績:風袋補正への展開に失敗しました。"  ;
      retMsg = "風袋情報の展開に失敗しました。"  ;
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg);
      //異常終了
      return null;
    }

    //風袋の実績展開 ここまで
    //-----------------------------------------------------


    //-----------------------------------------------------
    //指示:装置設定→実績:装置設定への展開 :TODO:済 2019.03.27 try-catch
    // 指示:装置設定とpat_mainの装置設定を単純マージして実績:装置設定へ設定する

    String rstDeviceSetInfo = extendIndDeviceSetInfoToRstDeviceSetInfo(
      ordMainData.getIndDeviceSetInfo(),
      patMainData.getDevice_set_info()
    ) ;

    eventLogMessage.setLogMessage("07-27：指示:装置設定→実績:装置設定への展開" + rstDeviceSetInfo);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if(null == rstDeviceSetInfo)
    {
      //指示:装置設定→実績:装置設定への展開に失敗
      retLogMsg = "指示:装置設定→実績:装置設定への展開に失敗しました。"  ;
      retMsg = "装置設定の展開に失敗しました。"  ;
      // エラーステータス設定
      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg);
      //異常終了
      return null;
    }

    //指示:装置設定→実績:装置設定への展開 ここまで
    //-----------------------------------------------------

    //-----------------------------------------------------
    //値の格納
    //ord_mainを更新するために、ord_mainエンティティを組み立てる

    //格納先:ordMainエンティティ
    eventLogMessage.setLogMessage("07-28：ord_main更新に必要なoutOrdMain値を作成開始(指示)");
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    OrdMain outOrdMain = new OrdMain() ;

    //システムで管理する一意なオーダ番号   ord_no
    //更新キーとしてセット
    outOrdMain.setOrdNo(ordNo) ;
    //変更しない       システムで管理する一意な患者ID    pat_id
    //変更しない       FNW+で管理する施設内の一意な患者ID    fn_pat_id
    //変更しない       治療日 treat_date
    //変更しない       治療曜日    treat_week
    //変更しない       施設コード   facility_cd
    //    施設名 facility_name
    outOrdMain.setFacilityName(facilityName);
    //変更しない           指示：VAコード    ind_va_cd
    //変更しない           指示：治療方法コード  ind_treatment_cd
    //    指示：治療方法名    ind_treatment_name
    outOrdMain.setIndTreatmentName(indTreatmentName);
    //変更しない               指示：クールコード   ind_kur_cd
    //    指示：クール名 ind_kur_name
    outOrdMain.setIndKurName(indKurName);
    //変更しない    指示：治療開始時刻   ind_treat_start_time
    //変更しない    指示：ベッドコード   ind_bed_cd
    //    指示：ベッド名 ind_bed_name
    outOrdMain.setIndBedName(indBedName);
    //    指示：治療予定指示者情報    ind_schedule_user_info
    outOrdMain.setIndScheduleUserInfo(indScheduleUserInfo);
    //    指示：治療条件情報   ind_cond_info
    outOrdMain.setIndCondInfo(indCondInfo);
    //    指示：投与薬剤情報   ind_medi_info
    outOrdMain.setIndMediInfo(indMediInfo);
    //    指示：医療材料情報   ind_equip_info
    outOrdMain.setIndEquipInfo(indEquipInfo);
    //    指示：指示コメント情報 ind_ind_comment_info
    outOrdMain.setIndIndCommentInfo(indIndCommentInfo);
    // add FNSI-身体情報のDWを取得して、ind_dwおよびrst_dwに展開保存する。 徐 start
    outOrdMain.setIndDw(BigDecimal.valueOf(rstDw));
    // add FNSI-身体情報のDWを取得して、ind_dwおよびrst_dwに展開保存する。 徐 end
    //変更しない        指示：風袋補正 ind_tare_info
    //変更しない        指示：除水補正 ind_off_water_info
    //変更しない        指示：装置設定情報   ind_device_set_info
    //変更しない        実績：FNW+透析番号 rst_fn_dialysis_no
    //変更しない        実績：関連透析番号   rst_relation_dialysis_no
    //変更しない        実績：版番号  rst_edition
    //変更しない        実績：版番号更新フラグ rst_is_update_edition
    //    実績：登録区分 rst_input_class
    outOrdMain.setRstInputClass(rstInputClass);
    //nullの場合なにもしない  OperateStateで設定     実績：治療状況 rst_dialysis_state
    if(null != rstDialysisState)
    {
      outOrdMain.setRstDialysisState(rstDialysisState);
    }
    eventLogMessage.setLogMessage("07-29：ord_main更新に必要なoutOrdMain値を作成開始(実績)");
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    //    実績：治療方法コード  rst_treatment_cd
    outOrdMain.setRstTreatmentCd(ordMainData.getIndTreatmentCd());
    //    実績：治療方法名    rst_treatment_name
    outOrdMain.setRstTreatmentName(outOrdMain.getIndTreatmentName());
    //    実績：クールコード   rst_kur_cd
    outOrdMain.setRstKurCd(ordMainData.getIndKurCd());
    //    実績：クール名 rst_kur_name
    outOrdMain.setRstKurName(outOrdMain.getIndKurName());
    //    実績：ベッドコード   rst_bed_cd
    //mod 8347【デグレ】????患者治療割り当てができない zhao start
    //outOrdMain.setRstBedCd(ordMainData.getIndBedCd());
    outOrdMain.setRstBedCd(ordMainData.getIndBedCd().longValue());
    //mod 8347【デグレ】????患者治療割り当てができない zhao end
    //    実績：ベッド名 rst_bed_name
    outOrdMain.setRstBedName(outOrdMain.getIndBedName());
    //    実績：装置番号 rst_machine_no
    outOrdMain.setRstMachineNo(rstMachineNo);
    //    実績：装置名  rst_machine_name
    outOrdMain.setRstMachineName(rstMachineName);
    //    実績：条件送信日時   rst_cond_send_date
//    outOrdMain.setRstCondSendDate(rstCondSendDate);
    //変更しない           実績：受付日時 rst_accept_date
    //変更しない           実績：治療開始日時   rst_start_date
    //変更しない           実績：治療終了日時   rst_end_date
    //変更しない           実績：帰宅日時 rst_return_home_date
    //    実績：入外区分 rst_in_out_class
    outOrdMain.setRstInOutClass(rstInOutClass);
    //    実績：透析回数 rst_dialysis_cnt
    outOrdMain.setRstDialysisCnt(rstDialysisCnt);
    //    実績：病棟コード    rst_ward_cd
    outOrdMain.setRstWardCd(rstWardCd);
    //    実績：病棟名  rst_ward_name
    outOrdMain.setRstWardName(rstWardName);
    //    実績：診療科コード   rst_course_cd
    // FNSI-add 診療科表示不正 徐 start
    // outOrdMain.setRstCourseCd(rstWardCd);
    outOrdMain.setRstCourseCd(rstCourseCd);
    // FNSI-add 診療科表示不正 徐 end
    //    実績：診療科名 rst_course_name
    outOrdMain.setRstCourseName(rstCourseName);
    //    実績：DW   rst_dw
    outOrdMain.setRstDw(BigDecimal.valueOf(rstDw));
    //変更しない              実績：穿刺者情報    rst_puncture_user_info
    //変更しない              実績：返血者情報    rst_return_user_info
    //変更しない              実績：担当者情報    rst_charge_user_info
    //変更しない              実績：血液循環積算値  rst_blood_circulate_total
    //変更しない              実績：透析運転時間   rst_running_time
    //変更しない              実績：Kt/V rst_kt_v
    //変更しない              実績：透析記録確認日時 rec_set_date
    //変更しない              実績：送信管理番号   send_ctl_no
    //    実績：血液浄化装置名称 blood_purifier_name
    outOrdMain.setBloodPurifierName(bloodPurifierName);
    //変更しない             実績：プログラム補液引き残し量 pull_leave_amount
    //    実績：治療条件情報   rst_cond_info
    // 目標体重が「-1」の場合、DWの値を設定
    // mod bug 6968 修正 chen start
    JSONObject rstCondInfo = null == outOrdMain.getIndCondInfo() ?
      new JSONObject() :
      new JSONObject(outOrdMain.getIndCondInfo());
    // JSONObject rstCondInfo = new JSONObject(outOrdMain.getIndCondInfo());
    // mod bug 6968 修正 chen end
    if (true == rstCondInfo.has(DIALYSISCOND.COND_TW.get())) {
      JSONObject twInfo = new JSONObject(rstCondInfo.get(DIALYSISCOND.COND_TW.get()).toString());
      if (
        "-1".equals(String.valueOf(getValueFromJson(twInfo, PARAMKEY.COND_VALUE.get()))) ||
          "null".equals(String.valueOf(getValueFromJson(twInfo, PARAMKEY.COND_VALUE.get())))
      ) {
        twInfo.put(PARAMKEY.COND_VALUE.get(), rstDw);
        rstCondInfo.put(DIALYSISCOND.COND_TW.get(), twInfo);
      }
    }
    outOrdMain.setRstCondInfo(rstCondInfo.toString());
    //    実績：投与薬剤情報   rst_medi_info
    outOrdMain.setRstMediInfo(rstMediInfo);
    //    実績：医療材料情報   rst_equip_info
    outOrdMain.setRstEquipInfo(outOrdMain.getIndEquipInfo());
    //    実績：指示コメント情報 rst_ind_comment_info
    outOrdMain.setRstIndCommentInfo(outOrdMain.getIndIndCommentInfo());
    //    実績：風袋補正 rst_tare_info
    outOrdMain.setRstTareInfo(rstTareInfo);
    //    実績：除水補正 rst_off_water_info
    outOrdMain.setRstOffWaterInfo(ordMainData.getIndOffWaterInfo());
    /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --start */
//    //    実績：装置設定情報   rst_device_set_info
//    outOrdMain.setRstDeviceSetInfo(rstDeviceSetInfo);
    /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --end */
    //    実績：体重情報 rst_weight_info   ※組み立てて入れる
    outOrdMain.setRstWeightInfo(rstWeightInfo);
    //変更しない                 実績：バイタル情報   rst_vital_info
    //変更しない                 実績：愁訴情報 rst_complaint_info
    //変更しない                 実績：愁訴処置情報   rst_treatment_info
    //変更しない                 実績：愁訴処置者情報  rst_treat_staff_info
    //変更しない                 実績：回診記録情報   rst_rounds_info
    //変更しない                 削除フラグ   is_del
    //    更新日時    up_date    SQLで更新
    //変更しない                 登録日時    reg_date

    //終了ログ
    this.exitMethod(className,methodName,null);

    return outOrdMain;
  }

  /**
   * メインメソッド終了処理
   *    終了ログを出力する。メッセージがnull以外の場合、RuntimeExceptionを投げる
   * @param className   クラス名
   * @param methodName  メソッド名
   * @param retMsg      メッセージ
   */
  void exitMethod(
    String className,
    String methodName,
    String retMsg
  )
  {
    String endMsg = className + "." + methodName + "の処理を終了しました。" ;

    if(null == retMsg)
    {
      //終了ログ
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(endMsg);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    }
    else
    {
      //メッセージがnullでなければRuntimeExceptionを投げる(Rollback用)
      //LogLevel.ERRORのログが出ます
      throw new RuntimeException(endMsg+":"+retMsg);
    }
  }

  /**
   * 定数の定義
   * 定数をenumで定義します
   */
  public static enum CONSTDEF {
    OFFLINE("1"),               //オフライン
    ONLINE("0"),                //オンライン

    MEDICINE_DEFAULT("1"),      //薬剤区分:通常薬剤
    MEDICINE_PREPARATION("2"),  //薬剤区分:調製薬剤

    MEDI_DONE("1"),      //投薬実施済み
    MEDI_NOTDONE("0"),   //投薬未実施

    PATVERIFIED_DONE("1"),      //患者確認済み
    PATVERIFIED_NOTDONE("0"),   //患者確認未確認

    DEVICE_MODE_PURIFICATION("9"),      //装置モード:特殊浄化("9")
    DISP_PURIFICATION("血液浄化装置"),    //装置モード:特殊浄化時の表示文言

    DEBUGFLAG("0"),             //デバッグ出力用フラグ "1":出力

    RST_INPUT_CLASS_DEFAULT("1"),   //登録区分：通常(透析装置や通信サーバーなどを伴う治療)
    RST_INPUT_CLASS_MANUAL("2"),    //登録区分：クライアントで手入力して作成

    ;
    //値格納用

    public String strKey = null ;

    //String型のコンストラクタ
    private CONSTDEF(String strKey) {
      this.strKey = strKey ;
    }

    //String型のGetter
    public String get() {
      return this.strKey ;
    }

  };

  /**
   * キー名の定義
   */
  public static enum PARAMKEY {
    STATUS("status"),               //HTTPステータス
    ERRMSG("errmsg"),               //エラーメッセージ
    MSG("msg"),               //エラーメッセージ
    RECEIVE_DATA("recive_data"),    //受信データ
    TMP_SETTING("tmpSetting"),     //装置一時設定
    WEIGHT_DATA("weightData"),     //体重計情報
    INSERT_COND("insertCond"),     //条件送信データ
    RET_MSG("retMsg"),             //返却メッセージ
    RET_LOG_MSG("retLogMsg"),             //返却メッセージ
    OFFWATER_CORRECT("offwaterCorrect"),//除水補正
    TARE_CORRECT("tareCorrect"),   //風袋補正
    PATID("pat_id"),                 //患者ID
    BED_CD("bed_cd"),               //ベッド番号
    KUR_CD("kur_cd"),               //クールコード
    TREAT_DATE("treat_date"),       //治療日
    ORD_NO("ordNo"),                //オーダー番号
    IND_COND_INFO("ind_cond_info"),      //指示：治療条件情報
    FACILITY_CD("facility_cd"),     //施設コード
    RST_MACHINE_NO("rst_machine_no"),   //実績：装置番号
    MACHINE_TYPE_CD("machine_type_cd"), //型式コード
    MACHINE_SERIAL("machine_serial"),    //製造番号
    VALUE("value"),                     //値
    CALVALUE("calValue"),                //計算値
    UPPER("UPPER"),                     //Kt/V　上限値
    UNDER("UNDER"),                     //Kt/V　下限値

    COND_NO("condNo"),                  //治療条件番号

    IND_OFF_WATER_INFO("ind_off_water_info"),   //除水補正値

    //装置マスタ
    TMP_CENTER_HD("tmp_center_hd"),     // TMPゼロ補正警報中点HD
    TMP_CENTER_ECUM("tmp_center_ecum"), // TMPゼロ補正警報中点ECUM
    TMP_CENTER_HDF("tmp_center_hdf"),   // TMPゼロ補正警報中点HDF
    TMP_CENTER_HF("tmp_center_hf"),     // TMPゼロ補正警報中点HF
    TMP_CENTER_HD_HO("tmp_center_hd_ho"),//TMP初期補正中点（HD+補液）
    TMP_CENTER_OHF("tmp_center_ohf"),   //TMP初期補正中点（OHF）
    TMP_CENTER_OHDF("tmp_center_ohdf"),   //TMP初期補正中点（OHDF）

    COM_FORMAT_CD("com_format_cd"), //通信フォーマット

    MACHINE_OPTION("machine_option"),   //装置オプション
    DEVICE_TYPE_NAME("machine_type"),   //機種タイプ

    //患者情報
    CALC_DIALYSIS_DATE("CALC_DIALYSIS_DATE"),   //体液量算出時治療日
    WEIGHT_BEFORE("WEIGHT_BEFORE"),             //前体重
    WEIGHT_AFTER("WEIGHT_AFTER"),               //後体重
    ADD_TOTAL("ADD_TOTAL"),                     //除水積算値

    PAT_LAST_NAME("pat_last_name"),             //患者名(姓)
    PAT_FIRST_NAME("pat_first_name"),           //患者名(名)

    CALC_DIALYSIS_TIME("CALC_DIALYSIS_TIME"),   //算出透析時間
    CALC_BLOOD_VOL("CALC_BLOOD_VOL"),           //算出血流量

    DEVICE_SET_INFO("device_set_info"),         //装置設定情報
    PHYSICAL_INFO("physical_info"),             //身体情報
    DW("dw"),                                   //DW(ドライウエイト)

    DEV("dev"),                                  //装置設定(dev)
    PAT("pat"),                                  //装置設定(pat)
    //除水
    OFF_WATER_NAME("name_"),        //除水項目名
    OFF_WATER_VALUE("weight_"),        //除水補正値

    EXAM_DATE("exam_date"),             //検査日時


    //透析量プログラム
    AFVPROG("AFVPROG"),                     //透析量プログラム設定
    AFVPROG_SYS("AFVPROG_SYS"),             //透析量プログラム設定(システム）
    AFVPROG_SYS_ON("AFVPROG_SYS_ON"),       //透析量プログラム使用フラグ
    //ダイアライザー情報
    UFR_WARNING_MAX("ufr_warning_max"), // 初期UFR警報上限
    UFR_WARNING_MIN("ufr_warning_min"), // 初期UFR警報下限
    UFR_WARNING_REDUCTION("ufr_warning_reduction"), // UFR低下率警報点
    UREACLEARANCE("urea_clearance"),   // 尿素クリアランス
    BLOODAMT("bloodamt"),               // 血流量
    ALQD_FLOOD_VOL("alqd_flood_vol"),   // 透析液量

    EXAM_ITEM_CD("EXAM_ITEM_CD"),           //BUN値

    DEVICE_MODE("device_mode") ,             //装置モード

    //施設名
    FACILITY_NAME("facility_name"),
    //指示：治療方法名
    TREATMANT_NAME("treatment_name"),
    //指示：クール名
    KUR_NAME("kur_name"),
    //指示：ベッド名
    BED_NAME("bed_name"),
    //実績：装置番号
    MACHINE_NO("machine_no"),
    //実績：装置名
    MACHINE_NAME("machine_name"),

    //pat_uniqueのカラムキー
    //共通診療情報
    MEDICAL_CARE_INFO("medical_care_info"),
    DIALYSIS_COURSE_CD("dialysis_course_cd"),   //共通診療情報:診療科マスタ.診療科コード　※透析実施科コード
    WARD_CD("ward_cd"),                         //共通診療情報:病棟マスタ.病棟コード
    WARD_NAME("ward_name"),                     //実績：病棟名(mst_ward)
    COURSE_NAME("course_name"),                 //実績：診療科名(mst_courceから)
    DIALYSIS_COUNT("dialysis_count"),           //実績：透析回数(mst_courceから)
    PURIFICATION_COUNT("purification_count"),   //実績：浄化治療回数(mst_courceから)

    //-----------------------------------
    //体重情報Jsonキー
    J_WEIGHT_BEFORE("weight_before")          ,   //前体重
    J_WEIGHT_BEFORE_DATE("weight_before_date"),   //前体重測定日時
    J_WEIGHT_AFTER("weight_after")            ,   //後体重
    J_WEIGHT_AFTER_DATE("weight_after_date")  ,   //後体重測定日時
    J_CTR("ctr"),                                 //CTR
    J_CTR_MEASURE_DATE("ctr_measure_date"),       //CTR測定日時(登録用)
    J_CTR_EXAM_DATE("exam_date"),                //CTR測定日時(取得用)
    J_CTR_WEIGHT("ctr_weight"),                   //CTR測定時体重
    J_WATER_REMOVAL_TARGET("water_removal_target"), //目標除水量
    J_ADD_TOTAL("add_total"),                     //除水積算値
    J_ADD_WATER_TOTAL("add_water_total"),         //補液積算値
    J_KT_V_MEASURE("kt_v_measure"),               //Kt/V測定値
    J_URR("urr"),                                 //URR
    J_RE_LOOP_RATE_BASE("re_loop_rate_"),         // 再循環率(キーのベース型。ループ用)
    J_RE_LOOP_RATE_1("re_loop_rate_1"),           // 再循環率(1回目)
    J_RE_LOOP_RATE_2("re_loop_rate_2"),           // 再循環率(2回目)
    J_RE_LOOP_RATE_3("re_loop_rate_3"),           // 再循環率(3回目)
    J_RE_LOOP_RATE_4("re_loop_rate_4"),           // 再循環率(4回目)
    J_RE_LOOP_RATE_5("re_loop_rate_5"),           // 再循環率(5回目)
    J_DATE("date"),     //測定日時
    J_VALUE("value"),   //測定値

    //-----------------------------------
    //指示:治療条件情報
    COND_CD("cd"),                  //コード(DBキー)
    COND_NAME("name"),              //名称(DBキー)

    COND_VALUE("value"),            //値
    COND_NAME_1("value_name_1"),    //翻訳1
    COND_NAME_2("value_name_2"),    //翻訳2
    COND_UNIT("unit"),              //単位（指示／調製薬剤）
    COND_UNIT_SECOND("unit_second"),//単位（レセ）

    COND_MODEL_NUMBER("model_number"),  //ダイアライザマスタ:型番
    COND_MAKER("maker"),                //ダイアライザマスタ:メーカー名

    COND_MEDICINE_TYPE("medicine_type"),   //薬剤区分 1: 通常薬剤、2: 調製薬剤

    COND_CAT_EQUIP("EQUIP"),        //処理区分:医療材料
    COND_CAT_VA("VA"),              //処理区分:VA


    //-----------------------------------
    //投与薬剤
    MEDI_NO("no"),                          //識別番号
    MEDI_MEDICENE_TYPE("medicine_type"),    //薬剤区分
    MEDI_CD("cd"),                          //薬剤(or 調整薬剤)コード
    MEDI_TIMING_CD("timing_cd"),            //投与タイミングコード
    MEDI_PROCEDURE_CD("procedure_cd"),      //手技コード

    MEDI_CLASS_CD("class_cd"),              //薬剤分類コード
    MEDI_CLASS_NAME("class_name"),          //薬剤分類名
    MEDI_CLASS_TYPE("class_type"),          //分類区分
    MEDI_NAME("name"),                      //薬剤名
    MEDI_SHORT_NAME("short_name"),          //省略薬剤名
    MEDI_UNIT("unit"),                      //単位

    MEDI_TIMING_NAME("timing_name"),        //投与タイミング名
    MEDI_PROCEDURE_NAME("procedure_name"),  //手技名

    MEDI_IND_INFO("indMediInfo"),       //指示
    MEDI_RST_INFO("rstMediInfo"),       //実績

    //実績に追加するキー
    MEDI_EFFECT_FLG("effect_flg"),          //投与実施フラグ ※0：未実施、1：実施済み
    MEDI_EFFECT_DATE("effect_date"),        //投与実施日時 ※ISO8601形式
    MEDI_EFFECT_USER_ID("effect_user_id"),  //投与実施者コード
    MEDI_EFFECT_USER_LAST_NAME("effect_user_last_name"),    //投与実施者名_姓
    MEDI_EFFECT_USER_FIRST_NAME("effect_user_first_name"),  //投与実施者名_名

    //-----------------------------------
    //医療材料
    EQUI_CD("cd"),                          //医療材料コード

    EQUI_CLASS_CD("class_cd"),              //医療材料分類コード
    EQUI_CLASS_NAME("class_name"),          //医療材料分類名
    EQUI_CLASS_TYPE("class_type"),          //分類区分
    EQUI_NAME("name"),                      //医療材料名
    EQUI_SHORT_NAME("short_name"),          //省略医療材料名
    EQUI_UNIT("unit"),                      //単位

    EQUI_EQUIPMENT_CD("equipment_cd"),      //医療材料コード(DB)
    EQUI_EQUIPMENT_NAME("equipment_name"),  //医療材料名(DB)
    EQUI_TYPE("equip_type"),                //医療材料区分(DB)



    ;

    //値格納用
    public String strKey = null ;

    //String型のコンストラクタ
    private PARAMKEY(String strKey) {
      this.strKey = strKey ;
    }

    //String型のGetter
    public String get() {
      return this.strKey ;
    }

  };

  /**
   * pat_unque情報の取得
   * @param pat_id  患者ID
   * @return 患者情報
   */
  public PatUnique getPatUniqueInfo(Long pat_id) {

    PatUnique ret = null ;

    List<Long> list = new ArrayList<Long>() ;
    list.add(pat_id) ;

    List<PatUnique> patUniqueList = patUniqueDao.selectByIdList(list) ;

    if(patUniqueList != null && patUniqueList.size() == 1)
    {
      ret = patUniqueList.get(0) ;
    }

    return  ret ;
  }

  /**
   * pat_main情報の取得
   * @param pat_id  患者ID
   * @return 患者情報
   */
  public PatMain getPatMainInfo(Long pat_id) {

    PatMain ret = null ;

    List<Long> list = new ArrayList<Long>() ;
    list.add(pat_id) ;

    List<PatMain> patMainList = patMainDao.selectByIdList(list) ;

    if(patMainList != null && patMainList.size() == 1)
    {
      ret = patMainList.get(0) ;
    }

    return  ret ;
  }

  /**
   * JSONObjectからの値の取得処理
   * 値が取得できない場合(キーが存在しないなど)はnullを返却する
   * @param jObj jsonオブジェクト
   * @param key  キー
   * @return 取得した値(キーが存在しない場合null)
   */
  private Object getValueFromJson(JSONObject jObj,String key)
  {
    Object ret = null ;

    try {
      //Jsonからキーを元に取得
      if(!jObj.isEmpty() && !jObj.isNull(key))
      {
        ret = jObj.get(key) ;
      }
    }
    catch(Exception e)
    {
      //例外が発生したので、戻り値をnullに設定
      ret = null ;
    }
    return ret ;
  }

  /**
   * Longへのパース処理
   * Longへパースできない場合はnullを返却する
   * @param inObj 入力
   * @return Long化した入力値(パースできない場合null)
   */
  private Long parseLong(Object inObj)
  {
    Long ret = null ;

    try {
      //Longにパース
      ret = Long.valueOf(String.valueOf(inObj)) ;
    }
    catch(Exception e)
    {
      //パースに失敗した場合null
      ret = null ;
    }

    return ret ;
  }

  /**
   * 病棟名、診療科名の取得
   * @param facility_cd 施設コード
   * @param ward_cd     病棟コード
   * @param course_cd   診療科コード
   * @return 名称
   *    key                 value
   *    ----------------+-------------
   *    ward_name           病棟名
   *    course_name         診療科名
   */
  public Map<String,Object> getWardAndCourseName(
    String facility_cd,
    Integer ward_cd,
    Integer course_cd
  ) {
    return dBAppWebAPIDao.selectWardAndCourseName(facility_cd, ward_cd, course_cd) ;
  }

  /**
   * 各名称取得用
   * @param ordNo オーダー番号
   * @return 名称
   * @throws Exception
   */
  public Map<String,Object> getNamesFromDbs(Long ordNo) {
    return dBAppWebAPIDao.selectNameDataFromVariousTbl(ordNo);
  }

  /**
   * 治療方法が特殊浄化かどうかの確認
   * @param ord_no  オーダー番号
   * @return true:治療方法が特殊浄化
   */
  public boolean checkDeviceModeIsPureOrNot(Long ord_no)
  {
    return dBAppWebAPIDao.checkDeviceModeIsPureOrNot(ord_no) ;
  }

  /**
   * Integerへのパース処理
   * Integerへパースできない場合はnullを返却する
   * @param inObj 入力
   * @return Integer化した入力値(パースできない場合null)
   */
  private Integer parseInteger(Object inObj)
  {
    Integer ret = null ;

    try {
      //Integerにパース
      ret = Integer.valueOf(String.valueOf(inObj)) ;
    }
    catch(Exception e)
    {
      //パースに失敗した場合null
      ret = null ;
    }

    return ret ;
  }

  /**
   * Doubleへのパース処理
   * Doubleへパースできない場合はnullを返却する
   * @param inObj 入力
   * @return Double化した入力値(パースできない場合null)
   */
  private Double parseDouble(Object inObj)
  {
    Double ret = null ;

    try {
      //Doubleにパース
      ret = Double.valueOf(String.valueOf(inObj)) ;
    }
    catch(Exception e)
    {
      //パースに失敗した場合null
      ret = null ;
    }

    return ret ;
  }

  /**
   * 身体情報からの値の取得処理
   * 身体情報を検査日時順に並べ替え、keyに対応する最新の値を含むJSONObjectを取得して返却する
   * WeightServiceImpl.java lastCtrMeasure(PhysicalInfo physicalInfo, String baseDate)同様の処理内容
   * @param physical_info 身体情報Json配列 [{},{},・・・,{}]
   * @param key 取得値のキー
   * @return 取得した値
   */
  private JSONObject getDataFromPhysicalInfo(
    JSONArray physical_info,
    String key,
    String ordMainTreatDate
  )
  {
    JSONObject ret = null ;
    LocalDateTime baseDateTime;
    if (ordMainTreatDate == null) {
      // ord_mainの治療日が存在しないなら
      // 現在日付+1日を設定
      baseDateTime = LocalDate.now().plusDays(1).atTime(0, 0);
    } else {
      try {
        LocalDate localBaseDate = LocalDate.parse(ordMainTreatDate, DateTimeFormatter.ofPattern("yyyyMMdd"));
        // ord_mainの治療日+1日を設定
        baseDateTime = localBaseDate.plusDays(1).atTime(0, 0);
      } catch (Exception ex) {
        baseDateTime = LocalDate.now().plusDays(1).atTime(0, 0);
      }
    }

    String sortKey = PARAMKEY.EXAM_DATE.get();

    //JSONArrayをList<JSONObject>化
    List<JSONObject> jsonList = new ArrayList<JSONObject>();
    for (int i = 0; i < physical_info.length(); i++) {
      jsonList.add(physical_info.getJSONObject(i));
    }

    //検査日時:降順に並べ替え(要素0が検査日時最新のデータという並び)
    jsonList.sort(
      (s1,s2)
        ->
        compareDateLong(
          getValueFromJson(s2,sortKey),
          getValueFromJson(s1,sortKey)
        )
    );

    final String format = "yyyy-MM-dd'T'HH:mm:ssXXX" ;
    final String formatLong = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX" ;

    //要素0～確認して、値があればその値を採用(最新の有効データを採用)
    for(int i = 0 ; i < jsonList.size() ; i++)
    {
      LocalDateTime examDateTime;
      try {
        //時間をlong値に変換
        String examDate = getValueFromJson(jsonList.get(i), sortKey).toString();
        Pattern pattern = Pattern.compile("T");
        Matcher matcher = pattern.matcher(examDate);
        String formatDate = matcher.find() ? examDate : examDate + "T00:00:00.000+09:00";
        DateTimeFormatter f = DateTimeFormatter.ofPattern(format);
        if (formatDate.length() > 25) {
          f = DateTimeFormatter.ofPattern(formatLong);
        }
        examDateTime = LocalDateTime.parse(formatDate, f);
      } catch(Exception e) {
        // 変換できなかったので次のデータの確認
        continue;
      }

      if (examDateTime.isAfter(baseDateTime) || examDateTime.isEqual(baseDateTime)) {
        // 治療日よりも後に登録したデータは無視(未来日.isAfter(基準日) :true)
        continue;
      }

      JSONObject tmpObj = jsonList.get(i) ;
      //キーが有るかの確認
      if(tmpObj.has(key))
      {
        //キーが有った場合、値が数値かを確認する
        Object value =  tmpObj.get(key) ;
        try {
          //Doubleに変換してみる
          Double.valueOf(String.valueOf(value)) ;
        }
        catch(Exception e)
        {
          // 変換できなかったので次のデータの確認
          continue ;
        }
        //戻り値が確定
        ret = tmpObj ;
        //ループ終了
        break ;
      }
    }

    return ret ;
  }

  /**
   * Mapからの値の取得処理
   * 値が取得できない場合(キーが存在しないなど)はnullを返却する
   * @param mapObj Mapオブジェクト
   * @param key  キー
   * @return 取得した値(キーが存在しない場合null)
   */
  private Object getValueFromMap(Map mapObj,String key)
  {
    Object ret = null ;

    try {
      //mapからキーを元に取得
      ret = mapObj.get(key) ;
    }
    catch(Exception e)
    {
      //例外が発生したので、戻り値をnullに設定
      ret = null ;
    }
    return ret ;
  }

  /*
   * 入外区分の取得
   * @param pat_id 患者ID
   * @return 入外区分
   */
  public Integer getInOutClassbyPatId(Long pat_id) {
    Integer ret = null ;

    List<Long> patIdList = new ArrayList<Long>() ;
    patIdList.add(pat_id) ;
    List<PatPersonalMain> list = patPersonalMainDao.selectByIdList(patIdList) ;

    if(null != list && 1 == list.size())
    {
      ret = list.get(0).getIn_out_class() ;
    }

    return ret ;
  }

  /**
   * JSONObjectのnullの置換処理
   * JSONObject.NULLは、Json文字列中では"null"という文字列になるので
   * これをただのnullに置き換える
   * @param inputStr 入力文字列
   * @return 置換後の文字列
   */
  String parseJSONObjectNullToNormalNull(String inputStr)
  {
    String ret = null;

    //置換元
    final String fromStr = "\"null\"" ;
    //置換先
    final String toStr = "null" ;

    //文字列置換実行
    return inputStr.replace(fromStr, toStr) ;
  }

  /**
   * Json処理カテゴリ定義
   * Jsonの構成パターンをenumで定義します
   */
  public enum CAT_JSON_PATTERN {
    STRING,
    KEYVALUE,
    DIM
  };

  /**
   * 各名称取得用
   * @param ordNo オーダー番号
   * @return 名称
   * @throws Exception
   */
  public List<String[]> getUsersNames(
    List<String> facilityCdList,
    List<Long> userIdList,
    boolean cryptoFlag)
  {
    List<String[]> retList = new ArrayList<String[]>() ;

    List<Map<String,Object>> retListFromDB = dBAppWebAPIUserDao.selectNamesFromPatPersonalMain(facilityCdList, userIdList, cryptoFlag);

    for(int i = 0 ; i < retListFromDB.size() ; i++)
    {
      String[] retStrDim = new String[3] ;
      retStrDim[0] = String.valueOf(retListFromDB.get(i).get("user_id")) ;
      retStrDim[1] = (String)retListFromDB.get(i).get("user_last_name") ;
      retStrDim[2] = (String)retListFromDB.get(i).get("user_first_name") ;
      retList.add(retStrDim) ;
    }

    return retList ;
  }

  /**
   * Json文字列中のユーザー名の置き換え処理
   * キーで指定されたidを元に名前の抽出を行い、キーで指定した名前(姓)、名前(名)の値を設定する
   * @param inObj 置き換え対象JSONObject
   * @param keys    キーの意味:{id,名前(姓),名前(名)}
   * @param facilityCd    施設コード
   * @param cryptoFlag    暗号/復号フラグ false:復号化したデータ
   * @return 名前部分を埋めた入力json文字列
   */
  Object fillNamesJson(
    Object inObj ,
    String[][] keys,
    String facilityCd,
    boolean cryptoFlag
  )
  {
    Object ret = null ;

    JSONObject jsonObj = null ;

    //渡されたオブジェクトの型判定
    if(inObj instanceof JSONObject)
    {
      //Jsonだった場合
      jsonObj = (JSONObject)inObj ;
    }
    else if(inObj instanceof String)
    {
      //文字列だったのでJsonオブジェクトにします
      jsonObj = new JSONObject((String)inObj) ;
    }
    //idの収集(名前取得時の引数)
    List<Long> userIdList = new ArrayList<Long>() ;

    Long userId = null ;
    for(int i = 0 ; i < keys.length ; i++)
    {
      if (!jsonObj.has(keys[i][0])) {
        continue;
      }
      Object tmpObj = jsonObj.get(keys[i][0]) ;

      //取得値をユーザIDとしてLongへパース
      userId = parseLong(tmpObj) ;

      //数値変換でエラーなので無視
      if(null == userId ) continue ;

      userIdList.add(userId) ;
    }

    //-----------------------------------------------
    //ユーザー情報の取得 from DB6 mst_personal_user

    //施設コード(引数)
    List<String> facilityCdList = new ArrayList<String>() ;
    facilityCdList.add(facilityCd) ;

    //戻り値の構成
    // {{"与えたid","名前(姓)","名前(名)"},・・・}

    //DBから取得
    List<String[]> namesList = getUsersNames(facilityCdList,userIdList,cryptoFlag);

    //穴埋め
    Long keyUserId = null ;
    for(int j = 0 ; j < keys.length ; j++)
    {
      keyUserId = parseLong(getValueFromJson(jsonObj,keys[j][0])) ;
      //longに変換できないので処理しない
      if(null == keyUserId) continue ;

      for(int i = 0 ; i < namesList.size() ; i++)
      {
        userId = Long.parseLong(namesList.get(i)[0]);
        if(userId.equals(keyUserId))
        {
          //名前の挿入
          jsonObj.put(keys[j][1], namesList.get(i)[1]) ;
          jsonObj.put(keys[j][2], namesList.get(i)[2]) ;
          break ;
        }
      }
    }

    ret = jsonObj;

    return ret ;
  }

  /**
   * Json文字列中のユーザー名の置き換え処理(拡張:オーバーロード)
   * キーで指定されたidを元に名前の抽出を行い、キーで指定した名前(姓)、名前(名)の値を設定する
   * @param inStr 設定先JSON文字列
   * @param keys    キーの意味:{id,名前(姓),名前(名)}
   * @param facilityCd    施設コード
   * @param cryptoFlag    暗号/復号フラグ false:復号化したデータ
   * @param pattern     処理パターン
   *                    STRING(プレーンなJson)
   *                    KEY(キーと値)
   *                    DIM(配列))
   * @return 名前部分を埋めた入力json文字列
   */
  private String fillNamesJson(
    String inStr ,
    String[][] keys,
    String facilityCd,
    boolean cryptoFlag,
    CAT_JSON_PATTERN pattern
  )
  {
    String ret = null ;

    //指定される処理パターン(Jsonの構成)による条件分け
    switch(pattern) {
      case STRING:      //プレーンなJson(キー:値,キー:値・・・)の場合の処理 {"":"","":"",・・・,"":""}
        //名称置き換え処理の呼び出し
        ret = fillNamesJson(
          inStr,
          keys,
          facilityCd,
          cryptoFlag
        ).toString();
        break ;
      case KEYVALUE:      //キーとJsonの場合の処理    {"":{},"":{},・・・・,"":{}}
        JSONObject jsonObj = null ;
        try {
          jsonObj = new JSONObject(inStr) ;
        }
        catch(Exception e)
        {
          ret = null ;
          break ;
        }

        //キーの数だけループします
        for(String key : jsonObj.keySet())
        {
          //JSONObjectを取得
          JSONObject tmpObj = jsonObj.getJSONObject(key) ;
          //名前置き換え処理の呼び出し
          tmpObj = (JSONObject)fillNamesJson(
            tmpObj,
            keys,
            facilityCd,
            cryptoFlag
          );
          //もとに戻す
          jsonObj.put(key, tmpObj) ;
        }

        ret = jsonObj.toString() ;
        break ;
      case DIM:      //Json配列の場合の処理     [{},{},・・・・,{}]
        JSONArray jsonArryObj = null ;
        try {
          /* mod by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --start */
          //jsonArryObj = new JSONArray(inStr) ;
          jsonArryObj = new JSONArray(ObjectUtils.isEmpty(inStr)? "[]" : inStr);
          /* mod by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --end */
          //配列の要素数だけループします
          for(int i = 0 ; i < jsonArryObj.length(); i++)
          {
            //JSONObjectを取得
            JSONObject tmpObj = (JSONObject)jsonArryObj.get(i) ;
            //名前置き換え処理の呼び出し
            tmpObj = (JSONObject)fillNamesJson(
              tmpObj,
              keys,
              facilityCd,
              cryptoFlag
            );
            //元のArrayに設定し直す
            jsonArryObj.put(i, tmpObj) ;
          }
          ret = jsonArryObj.toString() ;
        }
        catch(Exception e)
        {
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("例外発生：" + e.getMessage());
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
          ret =  null ;
        }

        break ;
      default:
        ret =  null ;
    }

    return ret ;
  }

  /**
   * デバッグ出力
   * CONSTDEF.DEBUGFLAGの値が"1"の場合、出力する
   * @param str 出力文字列
   */
  private void dbgPrint(String str)
  {
    //CONSTDEF.DEBUGFLAGの値を確認
    if(CONSTDEF.DEBUGFLAG.get().equals("1"))
    {
      //CONSTDEF.DEBUGFLAGが"1"だったので出力
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(str);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
    }

  }

  /**
   *
   * 透析条件項目定義
   * 2018/11/20現在の@治療条件項目に従い定義
   */
  public static enum DIALYSISCOND {
    //治療時間
    COND_TOTAL_TIME("1"),
    //VA
    COND_VA("2"),
    //目標体重
    COND_TW("3"),
    //除水量制限
    COND_REMOVE_WATER_LIMIT("4"),
    //ダイアライザ
    COND_DIALYZER("5"),
    //吸着カラム
    COND_ADSORB_EQUIPMENT("6"),
    //1次膜
    COND_FIRST_FILM("7"),
    //2次膜
    COND_SECOND_FILM("8"),
    //穿刺針(せんししん)(A針)
    COND_PUNCTURE_NEEDLE_A("9"),
    //穿刺針(せんししん)(V針)
    COND_PUNCTURE_NEEDLE_V("10"),
    //穿刺針(せんししん)(SN針)
    COND_PUNCTURE_NEEDLE_SN("11"),
    //シングルニードル使用
    COND_SINGLE_NEEDLE("12"),
    //血液回路
    COND_BLOOD_CIRCUIT("13"),
    //血流量
    COND_BLOOD_MEASURE("14"),
    //透析液
    COND_DIALYZE_LIQUID("15"),
    //透析液流量
    COND_DIALYZE_FLOW("16"),
    //透析液使用数
    COND_DIALYZE_MEASURE("17"),
    //透析液温度
    COND_DIALYZE_TEMPERATURE("18"),
    //補液
    COND_REPLENISH_LIQUID("19"),
    //補液量
    COND_REPLENISH_MEASURE("20"),
    //補液選択
    COND_REPLENISH_SELECT("21"),
    //補液使用数
    COND_REPLENISH_USE("22"),
    //補液温度
    COND_REPLENISH_TEMPERATURE("23"),
    //補液速度
    COND_REPLENISH_SPEED("24"),
    //抗凝固剤
    COND_ANTICOAGULAN_LIQUID("25"),
    //抗凝固剤ワンショット量
    COND_ANTICOAGULAN_ONESHOT("26"),
    //抗凝固剤持続速度
    COND_ANTICOAGULAN_SPEED("27"),
    //抗凝固剤持続総量
    COND_ANTICOAGULAN_TOTAL("28"),
    //IP使用選択
    COND_IP_SELECT("29"),
    //IPスタート
    COND_IP_START("30"),
    //IPワンショット量
    COND_IP_MEASURE("31"),
    //IP速度
    COND_IP_SPEED("32"),
    //IP速度最大値
    COND_IP_MAX_SPEED("33"),
    //自動ワンショット
    COND_IP_ONESHOT_START("34"),
    //IP電源自動切り
    COND_IP_AUTO_POWER_OFF("35"),
    //IP電源自動切り時間
    COND_IP_AUTO_POWER_OFF_TIME("36"),
    //IP電源OKモニタ切り
    COND_IP_AUTO_MONITOR_OFF("37"),
    //IP電源OKモニタ切り時間
    COND_IP_AUTO_MONITOR_OFF_TIME("38")
    ;
    //値格納領域
    //String
    private String strval ;

    //String型のコンストラクタ
    private DIALYSISCOND(String strval) {
      this.strval = strval ;
    }
    //String型のGetter
    public String get() {
      return this.strval ;
    }
  };

  /**
   * 指示情報の名称補完処理
   * @param target 対象処理区分  "EQUIP":医材  "VA":VA
   * @param facilityCd  施設コード
   * @param itemList 治療条件項目番号(リスト)
   * @param jObj 指示：治療条件情報Json
   * @return true:成功 false:失敗
   */
  private boolean setIndCondInfoNames(
    String target,
    String facilityCd,
    String[] initItemList,
    JSONObject jObj
  )
  {
    boolean ret = true ;

    try
    {
      List<String> setItemList = new ArrayList<String>(Arrays.asList(initItemList));
      for(int i = setItemList.size()-1 ; i >= 0 ; i--)
      {
        if (!jObj.has(setItemList.get(i))) {
          setItemList.remove(setItemList.get(i));
        }
      }
      String[] itemList = (String[]) setItemList.toArray(new String[setItemList.size()]);
      //処理対象用Listの準備
      List<JSONObject> objList = new ArrayList<JSONObject>(itemList.length)  ;
      //コードListの準備
      List<Integer> cdList = new ArrayList<Integer>(itemList.length)  ;
      //SQL条件用Listの準備
      List<Integer> sqlCdList = new ArrayList<Integer>(itemList.length)  ;

      for(int i = 0 ; i < itemList.length ; i++)
      {
        //処理対象のJsonのListへの格納
        objList.add((JSONObject)jObj.get(itemList[i])) ;
        //値(コード)の取得
        String value = String.valueOf(objList.get(i).get(PARAMKEY.COND_VALUE.get())) ;

        //値(コード)のInteger化
        Integer cd = parseInteger(value) ;
        cdList.add(cd); //コードリストへの追加
        if(null != cd)
        {
          //nullの場合以外をSQL条件用リストに追加 ※nullがあると、Domaのパースで実行時エラーになるためnullは追加しない
          sqlCdList.add(cd) ;
        }
      }

      //名称をまとめて取得
      List<Map<String,Object>> equipMapList = getNameListWithCase(
        target,
        facilityCd,
        sqlCdList) ;

      //処理対象リストを回して該当するCDを探して値をはめていきます
      for(int i = 0 ; i < cdList.size() ; i++)
      {
        if(null == cdList.get(i))
        {
          //コードがnullの場合はスキップ
          continue;
        }

        // 取得した名称Listのループ
        for(int j = 0 ; j < equipMapList.size() ; j++)
        {
          //  取得した名称のコードを取得
          Integer cd = this.parseInteger(String.valueOf(equipMapList.get(j).get(PARAMKEY.COND_CD.get()))) ;
          //  処理対象のコードと比較
          if(cdList.get(i).equals(cd))
          {
            //   コードが一致
            //   翻訳に名称をセットする
            objList.get(i).put(PARAMKEY.COND_NAME_1.get(), (String)equipMapList.get(j).get(PARAMKEY.COND_NAME.get())) ;
            break ;
          }
        }
      }
    }
    catch(Exception e)
    {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      ret = false ;
    }

    return ret ;
  }

  /*
   *    医療材料情報(名称)の取得
   * @param facility_cd     施設コード
   * @param cdList          医療材料コード(リスト)
   * @return mapリスト
   *           key            value
   *            equipment_cd    医療材料コード
   *            equipment_name  医療材料名
   */
  public List<Map<String,Object>> getNameListWithCase(
    String target,
    String facility_cd,
    List<Integer> cdList
  )
  {
    return dBAppWebAPIDao.selectNameListWithCase(target,facility_cd, cdList);
  }

  /**
   * 指示情報(薬剤)の名称補完処理 setIndCondInfoNames:overloaded
   * @param facilityCd  施設コード
   * @param itemList 治療条件項目番号(リスト)
   * @param jObj 処理対象の治療条件Json
   * @return true:正常 false:異常
   */
  private boolean setIndCondInfoNames(
    String facilityCd,
    String[] initItemList,
    JSONObject jObj
  )
  {

    boolean ret = true ;

    try
    {
      List<String> setItemList = new ArrayList<String>(Arrays.asList(initItemList));
      for(int i = setItemList.size()-1 ; i >= 0 ; i--)
      {
        if (!jObj.has(setItemList.get(i))) {
          setItemList.remove(setItemList.get(i));
        }
      }
      String[] itemList = (String[]) setItemList.toArray(new String[setItemList.size()]);

      //配列の要素数分ループ
      for(int i = 0 ; i < itemList.length ; i++)
      {
        // 対象の項目のJson
        JSONObject tmpObj = (JSONObject)jObj.get(itemList[i]) ;
        // 設定されている値を取得
        Integer cd = parseInteger(getValueFromJson(tmpObj,PARAMKEY.COND_VALUE.get()));
        // 設定されている薬剤区分を取得
        Integer type  = parseInteger(getValueFromJson(tmpObj,PARAMKEY.COND_MEDICINE_TYPE.get()));
        // DBからデータを取得
        Map<String,Object> medicineMap = getMedicineInfo(
          facilityCd,
          type,
          cd
        );
        // 翻訳にセット
        if(null != medicineMap)
        {
          tmpObj.put(PARAMKEY.COND_NAME_1.get(), (String)medicineMap.get(PARAMKEY.MEDI_NAME.get())) ;
          //TODO:単位保管場所はCDの保管場所と違うため一旦無効化
          //tmpObj.put(PARAMKEY.COND_UNIT.get(), (String)medicineMap.get(PARAMKEY.MEDI_UNIT.get()));
        }
      }
    }
    catch(Exception e)
    {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      ret = false ;
    }

    return ret ;
  }

  /*
   *    薬剤情報の取得
   * @param facility_cd     施設コード
   * @param medicine_type   薬剤区分
   * @param cd              薬剤(or 調整薬剤)コード
   */
  public Map<String,Object> getMedicineInfo(
    String facilityCd,
    Integer medicine_type,
    Integer cd
  ) {
    return dBAppWebAPIDao.selectMedicineInfo(
      facilityCd,
      medicine_type,
      cd
    );
  }

  /**
   * 指示情報(薬剤)の単位及び数量小数点補完処理 setIndCondInfoUnitAndPoint
   * @param facilityCd  施設コード
   * @param itemList 保管対象項目の一覧
   * @param jObj 処理対象の治療条件Json
   * @return true:正常 false:異常
   */
  private boolean setIndCondInfoUnitAndPoint(
    String facilityCd,
    String[] initItemList,
    JSONObject jObj
  )
  {

    boolean ret = true ;

    try
    {
      List<String> setItemList = new ArrayList<String>(Arrays.asList(initItemList));
      for(int i = setItemList.size()-1 ; i >= 0 ; i--)
      {
        if (!jObj.has(setItemList.get(i))) {
          setItemList.remove(setItemList.get(i));
        }
      }
      String[] itemList = (String[]) setItemList.toArray(new String[setItemList.size()]);

      //配列の要素数分ループ
      for(int i = 0 ; i < itemList.length ; i++)
      {
        // 対象項目のJson
        JSONObject tmpObj = (JSONObject)jObj.get(itemList[i]) ;
        Integer tmpId = Integer.parseInt(itemList[i]);

        // 対象項目のコード値を取得＆参照項目のコード値をセット
        Integer refId = null;
        switch(tmpId){
          case 17:
            // 透析液コード
            refId = 15;
            break;
          case 22:
            // 補液コード
            refId = 19;
            break;
          case 26:
          case 27:
          case 28:
            // 抗凝固剤コード
            refId = 25;
            break;
        }

        // 対象の参照項目Json
        JSONObject refObj = (JSONObject)jObj.get(Integer.toString(refId));

        Integer cd = parseInteger(getValueFromJson(refObj,PARAMKEY.COND_VALUE.get()));
        // 設定されている薬剤区分を取得
        Integer type  = parseInteger(getValueFromJson(refObj,PARAMKEY.COND_MEDICINE_TYPE.get()));

        // DBからデータを取得
        Map<String,Object> medicineMap = getMedicineInfo(
          facilityCd,
          type,
          cd
        );
        // 翻訳にセット
        if(null != medicineMap)
        {
          //jsonに追加するunit 透析液及び補液はレセ単位／抗凝固剤は指示単位
          if(tmpId == 17 || tmpId == 22){
            tmpObj.put(PARAMKEY.COND_UNIT.get(), (String)medicineMap.get(PARAMKEY.COND_UNIT_SECOND.get())) ;
            //TODO:小数点以下桁数制御によってコメント化項目の使用可否判断
            //tmpObj.put(PARAMKEY.COND_VALUE.get(),this.changeMedicineValue(String.valueOf(getValueFromJson(tmpObj,PARAMKEY.COND_VALUE.get())),5));
            //tmpObj.put("NumberTest1",10.000000000);
            //tmpObj.put("NumberTest2",Double.valueOf(10.000000000));
            //tmpObj.put("NumberTest3",new BigDecimal("10.000000000"));
          }
          else if(tmpId == 27){
            tmpObj.put(PARAMKEY.COND_UNIT.get(), (String)medicineMap.get(PARAMKEY.COND_UNIT.get()) + "/h" ) ;
            //tmpObj.put(PARAMKEY.COND_VALUE.get(),this.changeMedicineValue(String.valueOf(getValueFromJson(tmpObj,PARAMKEY.COND_VALUE.get())),5));
            //tmpObj.put("testCode",10.0000001);
          }
          else{
            tmpObj.put(PARAMKEY.COND_UNIT.get(), (String)medicineMap.get(PARAMKEY.COND_UNIT.get())) ;
            //tmpObj.put(PARAMKEY.COND_VALUE.get(),this.changeMedicineValue(String.valueOf(getValueFromJson(tmpObj,PARAMKEY.COND_VALUE.get())),5));
            //tmpObj.put("testCode",new BigDecimal("10.000000"));
          }
        }
      }
    }
    catch(Exception e)
    {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      ret = false ;
    }
    return ret ;
  }

  /**
   * 投与薬剤情報穴埋め処理
   * ※実績:投与薬剤情報は、指示:投与薬剤情報のディープコピー+実施情報
   * @param indMediInfo 指示:投与薬剤情報:JsonArray
   * @param rstMediInfo 実績:投与薬剤情報:null(指示:投与薬剤情報がコピーされる)
   * @param facilityCd 施設コード
   * @return 投与薬剤情報(失敗時null)
   *    PARAMKEY.MEDI_IND_INFO.get():指示:投与薬剤情報
   *    PARAMKEY.MEDI_RST_INFO.get():実績:投与薬剤情報
   */
  private Map<String,String> setMedicineInfo(
    String indMediInfo,
    String rstMediInfo,
    String facilityCd
  )
  {
    //戻り値
    Map<String,String> ret = new HashMap<String,String>() ;

    JSONArray jsonArry = new JSONArray(indMediInfo) ;

    for(int i = 0 ; i < jsonArry.length() ; i++)
    {

      //処理対象データ(Json)の取得(i番目の要素)
      JSONObject jObj = (JSONObject)jsonArry.get(i) ;

      //Jsonの構造
      //    {
      //      "no": 識別番号, (*1)                  更新しない
      //      "class_cd": 薬剤分類コード, (*3)       mst_medicine.class_cd
      //                                          mst_preparation_medicine.class_cd
      //      "class_name": 薬剤分類名, (*3)       mst_medicine_class.class_name
      //      "class_type": 分類区分, (*3)         mst_medicine_class.class_type
      //      "medicine_type": 薬剤区分, (*2)(*4)   判定に使用: 1: 通常薬剤mst_medicine、2: 調製薬剤mst_preparation_medicine
      //      "cd": 薬剤(調整薬剤)コード, (*2)         はいってる(薬剤区分によりコードの意味が変わる(テーブル切り替え))(抽出キー)
      //      "name": 薬剤名, (*3)                 mst_medicine.medicine_name
      //                                          mst_preparation_medicine.preparation_medicine_name
      //      "short_name": 省略薬剤名, (*3)       mst_medicine.medicine_short_name
      //                                          mst_preparation_medicine.preparation_medicine_short_name
      //      "unit": 単位, (*3)                  mst_medicine.unit
      //                                          mst_preparation_medicine.unit
      //      "amount": 数量, (*2)               更新しない
      //      "timing_cd": 投与タイミングコード, (*2)  更新しない
      //      "timing_name": 投与タイミング名, (*3)   mst_medicate_timing.medicate_timing_name
      //      "procedure_cd": 手技コード, (*2)     更新しない
      //      "procedure_name": 手技名, (*3)      mst_procedure.pricedure_name
      //      "comment": コメント, (*2)              更新しない
      //      "ind_user_id": 指示者コード(利用者マスタ.利用者ID), (*2) 更新しない
      //      "ind_user_last_name": 指示者名_姓(利用者マスタ.利用者名_姓), (*3) 名前処理で一括処理(ここではしない)
      //      "ind_user_first_name": 指示者名_名(利用者マスタ.利用者名_名), (*3) 名前処理で一括処理(ここではしない)
      //      "upd_user_id": 更新者コード(利用者マスタ.利用者ID), (*2) 更新しない
      //      "upd_user_last_name": 更新者名_姓(利用者マスタ.利用者名_姓), (*3) 名前処理で一括処理(ここではしない)
      //      "upd_user_first_name": 更新者名_名(利用者マスタ.利用者名_名), (*3) 名前処理で一括処理(ここではしない)
      //      "input_class": 登録区分, (*2)(*5) 更新しない
      //      "is_editable": 編集可否フラグ, (*2)(*6) 更新しない
      //      "cop_order_no": 連携オーダ番号 (*7) 更新しない
      //    }, ・・・

      //コード収集

      //薬剤区分の取得
      Integer medicine_type = parseInteger(getValueFromJson(jObj,PARAMKEY.MEDI_MEDICENE_TYPE.get())) ;
      //薬剤(or 調整薬剤)コードの取得
      Integer cd = parseInteger(getValueFromJson(jObj,PARAMKEY.MEDI_CD.get())) ;
      //投与タイミングコードの取得
      Integer timing_cd = parseInteger(getValueFromJson(jObj,PARAMKEY.MEDI_TIMING_CD.get())) ;
      //手技コードの取得
      Integer procedure_cd = parseInteger(getValueFromJson(jObj,PARAMKEY.MEDI_PROCEDURE_CD.get())) ;

      //取得したコードを元に薬剤情報から名称を取得(DBから)
      Map<String,Object> mediMap = getMedicineInfo(
        facilityCd,
        medicine_type,
        cd) ;
      //Jsonにセット(名称穴埋め)
      //薬剤分類コード
      setJsonKeyAndValue(jObj, PARAMKEY.MEDI_CLASS_CD.get(), getValueFromMap(mediMap,PARAMKEY.MEDI_CLASS_CD.get()));
      //薬剤分類名
      setJsonKeyAndValue(jObj, PARAMKEY.MEDI_CLASS_NAME.get(), getValueFromMap(mediMap,PARAMKEY.MEDI_CLASS_NAME.get())) ;
      //分類区分
      setJsonKeyAndValue(jObj, PARAMKEY.MEDI_CLASS_TYPE.get(), getValueFromMap(mediMap,PARAMKEY.MEDI_CLASS_TYPE.get())) ;
      //薬剤名
      setJsonKeyAndValue(jObj, PARAMKEY.MEDI_NAME.get(), getValueFromMap(mediMap,PARAMKEY.MEDI_NAME.get())) ;
      //省略薬剤名
      setJsonKeyAndValue(jObj, PARAMKEY.MEDI_SHORT_NAME.get(), getValueFromMap(mediMap,PARAMKEY.MEDI_SHORT_NAME.get())) ;
      //単位
      setJsonKeyAndValue(jObj, PARAMKEY.MEDI_UNIT.get(), getValueFromMap(mediMap,PARAMKEY.MEDI_UNIT.get())) ;

      //投与タイミング
      String timing_name = getTimingName(
        facilityCd,
        timing_cd) ;

      //Jsonにセット(名称穴埋め)
      //投与タイミング名称
      jObj.put(PARAMKEY.MEDI_TIMING_NAME.get(), timing_name) ;

      //手技
      String procedure_name = getProcedureName(
        facilityCd,
        procedure_cd) ;

      //Jsonにセット(名称穴埋め)
      //手技名称
      jObj.put(PARAMKEY.MEDI_PROCEDURE_NAME.get(), procedure_name) ;
    }

    //----------------------------------------------------------------------
    //実績へ実施情報のキーを追加

    //  投与実施フラグ  未実施 ※0：未実施、1：実施済み → 0  effect_flg
    //  投与実施日時 ※ISO8601形式 → null            effect_date
    //  投与実施者コード → null                     effect_user_id
    //  投与実施者名_姓 → null                     effect_user_last_name
    //  投与実施者名_名 → null                     effect_user_first_name


    //指示->実績へのコピー(ディープコピー)
    JSONArray rstJsonArry = new JSONArray(jsonArry.toString()) ;

    for(int i = 0 ; i < rstJsonArry.length() ; i++)
    {
      //処理対象データ(Json)の取得(i番目の要素)
      JSONObject jObj = (JSONObject)rstJsonArry.get(i) ;

      //-------------------------------------------
      //実施情報のキー追加

      //投与実施フラグ  未実施 ※0：未実施、1：実施済み
      setJsonNonExistKeyAndValue(jObj,PARAMKEY.MEDI_EFFECT_FLG.get(),CONSTDEF.MEDI_NOTDONE.get()) ;
      //投与実施日時 ※ISO8601形式
      setJsonNonExistKeyAndValue(jObj,PARAMKEY.MEDI_EFFECT_DATE.get(),(String)null) ;
      //投与実施者コード
      setJsonNonExistKeyAndValue(jObj,PARAMKEY.MEDI_EFFECT_USER_ID.get(),(String)null) ;
      //投与実施者名_姓
      setJsonNonExistKeyAndValue(jObj,PARAMKEY.MEDI_EFFECT_USER_LAST_NAME.get(),(String)null) ;
      //投与実施者名_名
      setJsonNonExistKeyAndValue(jObj,PARAMKEY.MEDI_EFFECT_USER_FIRST_NAME.get(),(String)null) ;
    }

    //戻り値の組み立て
    ret.put(PARAMKEY.MEDI_IND_INFO.get(), parseJSONObjectNullToNormalNull(jsonArry.toString())) ;
    ret.put(PARAMKEY.MEDI_RST_INFO.get(), parseJSONObjectNullToNormalNull(rstJsonArry.toString())) ;

    return ret ;
  }

  /**
   * Jsonキー設定処理
   * キーの値を上書き設定する
   * 値がnullの場合は、JSONObject.NULLを値として設定する
   * @param jObj 設定先JSONObject
   * @param key キー
   * @param value 値
   */
  private void setJsonKeyAndValue(JSONObject jObj, String key, Object value) {
    if(null == value) {
      jObj.put(key, JSONObject.NULL) ;
    } else {
      jObj.put(key, value);
    }
  }

  /**
   * Jsonキー設定処理
   * キーが存在しない場合のみ値を設定する
   * 値がnullの場合は、JSONObject.NULLを値として設定する
   * @param jObj 設定先JSONObject
   * @param key キー
   * @param value 値
   */
  private void setJsonNonExistKeyAndValue(
    JSONObject jObj,
    String key,
    String value
  )
  {
    if(!jObj.has(key)) {
      //キーがない場合だけ追加
      if(null == value)
      {
        value = String.valueOf(JSONObject.NULL) ;
      }
      jObj.put(key, value) ;
    }
  }

  /*
   *    投与タイミング名の取得
   * @param facility_cd     施設コード
   * @param timing_cd       投与タイミングコード
   */
  public String getTimingName(
    String facility_cd,
    Integer timing_cd
  )
  {
    return dBAppWebAPIDao.selectTimingName(facility_cd, timing_cd) ;
  }

  /*
   *    手技名の取得
   * @param facility_cd     施設コード
   * @param name_cd         手技コード
   */
  public String getProcedureName(
    String facility_cd,
    Integer procedure_cd
  )
  {
    return dBAppWebAPIDao.selectProcedureName(facility_cd, procedure_cd) ;
  }

  /**
   * 投薬情報マージ処理
   * 処理概要:
   * 実績から投薬実施済みを残して、その他は削除。その後指示とマージする。
   * @param rstMediInfo 実績:投薬情報(Json配列文字列)
   * @param indMediInfo 指示:投薬情報(Json配列文字列)
   * @return マージされた指示:投薬情報(Json配列文字列)
   */
  private String mergeRstMediIntoIndMedi(
    String rstMediInfo,
    String indMediInfo
  )
  {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("07-18-2：投薬情報マージ処理開始");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    //実績のJsonArray化
    JSONArray rstArry;
    if (rstMediInfo == null) {
      rstArry = new JSONArray();
    } else {
      rstArry = new JSONArray(rstMediInfo);
    }

    //実績から投薬済み以外を削除(投薬済みだけ残す)
    int length = rstArry.length() ;
    for(int i = length -1  ; i >= 0  ; i--)
    {
      JSONObject tmpObj = rstArry.getJSONObject(i) ;
      //投与実施フラグの取得
      Object MediEffectFlg = getValueFromJson(tmpObj,PARAMKEY.MEDI_EFFECT_FLG.get()) ;
      String value;
      if (MediEffectFlg == null || String.valueOf(MediEffectFlg).equals("null")) {
        value = null;
      } else {
        value = (String)MediEffectFlg;
      }
      //投与実施フラグの確認
      if(null != value && !CONSTDEF.MEDI_DONE.get().equals(value))
      {
        // 投与実施フラグが存在&&投与実施フラグが実施済み以外
        // 投薬済みではないので削除
        rstArry.remove(i) ;
      }
    }

    //マージ作業
    //指示のJsonArray化
    JSONArray indArry;
    if (rstMediInfo == null) {
      indArry = new JSONArray();
    } else {
      indArry = new JSONArray(indMediInfo);
    }

    //指示の数だけループ
    for(int i = 0 ; i < indArry.length(); i++)
    {
      //指示の個別の投薬情報
      JSONObject indObj = indArry.getJSONObject(i) ;
      Object mediNo = getValueFromJson(indObj,PARAMKEY.MEDI_NO.get());
      //指示の識別番号取得
      Integer indNo;
      if (mediNo == null || String.valueOf(mediNo).equals("null")) {
        indNo = null;
      } else {
        indNo = parseInteger(mediNo);
      }


      //実績から同じ識別番号を探す
      for(int j = 0 ; j < rstArry.length(); j++)
      {
        //実績の個別の投薬情報
        JSONObject rstObj = rstArry.getJSONObject(j) ;
        //実績の識別番号取得
        Object medi_no = getValueFromJson(rstObj,PARAMKEY.MEDI_NO.get());
        Integer rstNo;
        if (medi_no == null || String.valueOf(medi_no).equals("null")) {
          rstNo = null;
        } else {
          rstNo = parseInteger(medi_no);
        }

        if(rstNo != null && rstNo.equals(indNo))
        {
          //同じ識別番号があったので、指示のJsonを実績のJsonで置き換え
          //処理上、元の配列から削除する(参照情報がなくなる)ためdeep copy)
          indArry.put(i,new JSONObject(rstObj.toString())) ;
          //実績のJsonArrayから、削除
          rstArry.remove(j) ;
          break ;
        }
      }
    }
    //一致しなかった実績の残りを指示に追加
    for(int i = 0 ; i < rstArry.length(); i++)
    {
      indArry.put(indArry.length(),rstArry.getJSONObject(i)) ;
    }

    //---------------------------------------
    //識別番号でソート

    String sortKey = PARAMKEY.MEDI_NO.get();

    //JSONArrayをList<JSONObject>化
    List<JSONObject> jsonList = new ArrayList<JSONObject>();
    for (int i = 0; i < indArry.length(); i++) {
      jsonList.add(indArry.getJSONObject(i));
    }

    //識別番号:昇順
    jsonList.sort(
      (s1,s2)
        ->
        parseInteger(getValueFromJson(s1,sortKey)) - parseInteger(getValueFromJson(s2,sortKey))
    );

    //再びJsonArray化
    JSONArray sortedJsonArray = new JSONArray() ;
    for (int i = 0; i < indArry.length(); i++) {
      sortedJsonArray.put(jsonList.get(i));
    }

    eventLogMessage.setLogMessage("07-18-2：投薬情報マージ処理終了");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    //指示を文字列化
    return sortedJsonArray.toString() ;
  }

  /**
   * 医療材料情報穴埋め処理
   * @param indEquipInfo 医療材料情報情報:JsonArray文字列
   * @param facilityCd 施設コード
   * @return String 医療材料情報(失敗時null)
   */
  private String setEquipmentInfo(
    String indEquipInfo,
    String facilityCd
  )
  {
    String ret = null ;

    JSONArray jsonArry = new JSONArray(indEquipInfo) ;

    for(int i = 0 ; i < jsonArry.length() ; i++)
    {
      //処理対象データ(Json)の取得(i番目の要素)
      JSONObject jObj = (JSONObject)jsonArry.get(i) ;

      //Jsonの構造
      //  {
      //    "class_cd": 医療材料分類コード, (*2)  mst_equipment.class_cd
      //    "class_name": 医療材料分類名, (*2)  mst_equipment_class.class_name
      //    "class_type": 分類区分, (*2)       mst_equipment_class.class_type
      //    "cd": 医療材料コード, (*1)           入っている(抽出キー)
      //    "name": 医療材料名, (*2)           mst_equipment.equipment_name
      //    "short_name": 省略医療材料名, (*2)  mst_equipment.equipment_short_name
      //    "needle_type": 穿刺針区分, (*3)    入力値(なにもしない)
      //    "amount": 数量, (*1)              入力値(なにもしない
      //    "unit": 単位, (*2)                 mst_equipment.unit
      //    "ind_user_id": 指示者コード(利用者マスタ.利用者ID), (*1) 更新しない
      //    "ind_user_last_name": 指示者名_姓(利用者マスタ.利用者名_姓), (*2) 名前処理で一括処理(ここではしない)
      //    "ind_user_first_name": 指示者名_名(利用者マスタ.利用者名_名), (*2) 名前処理で一括処理(ここではしない)
      //    "upd_user_id": 更新者コード(利用者マスタ.利用者ID), (*1) 更新しない
      //    "upd_user_last_name": 更新者名_姓(利用者マスタ.利用者名_姓), (*2) 名前処理で一括処理(ここではしない)
      //    "upd_user_first_name": 更新者名_名(利用者マスタ.利用者名_名), (*2) 名前処理で一括処理(ここではしない)
      //    "input_class": 登録区分, (*1)(*4) 更新しない
      //    "is_editable": 編集可否フラグ, (*1)(*5) 更新しない
      //    "cop_order_no": 連携オーダ番号 (*6) 更新しない
      //    "equip_type": 医療材料区分(0：医療材料、1：ダイアライザ)
      //  }

      //コード収集
      //医療材料区分の取得
      Integer equipType = parseInteger(getValueFromJson(jObj,PARAMKEY.EQUI_TYPE.get())) ;

      //医療材料コードの取得
      Integer cd = parseInteger(getValueFromJson(jObj,PARAMKEY.EQUI_CD.get())) ;

      if (equipType == 0) {
        //取得したコードを元に医療材料情報から名称を取得(DBから)
        Map<String,Object> mediMap = getEquipmentInfo(
          facilityCd,
          cd) ;

        //Jsonにセット(名称穴埋め)
        //医療材料分類コード
        setJsonKeyAndValue(jObj, PARAMKEY.EQUI_CLASS_CD.get(), getValueFromMap(mediMap,PARAMKEY.EQUI_CLASS_CD.get()));
        //医療材料分類名
        setJsonKeyAndValue(jObj, PARAMKEY.EQUI_CLASS_NAME.get(), getValueFromMap(mediMap,PARAMKEY.EQUI_CLASS_NAME.get()));
        //分類区分
        setJsonKeyAndValue(jObj, PARAMKEY.EQUI_CLASS_TYPE.get(), getValueFromMap(mediMap,PARAMKEY.EQUI_CLASS_TYPE.get()));
        //医療材料名
        setJsonKeyAndValue(jObj, PARAMKEY.EQUI_NAME.get(), getValueFromMap(mediMap,PARAMKEY.EQUI_NAME.get()));
        //省略医療材料名
        setJsonKeyAndValue(jObj, PARAMKEY.EQUI_SHORT_NAME.get(), getValueFromMap(mediMap,PARAMKEY.EQUI_SHORT_NAME.get()));
        //単位
        setJsonKeyAndValue(jObj, PARAMKEY.EQUI_UNIT.get(), getValueFromMap(mediMap,PARAMKEY.EQUI_UNIT.get()));

      } else if (equipType == 1) {
        //取得したコードを元にダイアライザ情報から名称を取得(DBから)
        Map<String,Object> mediMap = getDialyzerNames(
          facilityCd,
          cd) ;

        //Jsonにセット(名称穴埋め)
        //医療材料名
        setJsonKeyAndValue(jObj, PARAMKEY.EQUI_NAME.get(), getValueFromMap(mediMap,PARAMKEY.COND_MODEL_NUMBER.get()));

      }
    }
    ret = jsonArry.toString() ;

    return ret ;
  }

  /*
   *    医療材料情報の取得
   * @param facility_cd     施設コード
   * @param cd              医療材料コード
   */
  public Map<String,Object> getEquipmentInfo(
    String facility_cd,
    Integer cd
  ) {
    return dBAppWebAPIDao.selectEquipmentInfo(facility_cd, cd) ;
  }

  /*
   *    ダイアライザー情報(名称)の取得
   * @param facility_cd     施設コード
   * @param cd              ダイアライザコード
   * @return   key            value
   *            model_number    型番
   *            maker           メーカー名
   */
  public Map<String,Object> getDialyzerNames(
    String facility_cd,
    Integer cd
  ) {
    return dBAppWebAPIDao.selectDialyzerNames(facility_cd, cd) ;
  }

  /**
   * 風袋補正展開処理
   *  指示:風袋補正を実績:風袋補正に展開する。
   *      1.キー before,afterが実績になければ作成
   *          どちらにも、指示:風袋補正をそのままコピー
   *      2.name_1～name_5を上書き(or作成)
   *      ※車椅子関連の情報に関してはなにもしない(消さない。キーがなくても作成しない)
   *      ※実績展開時に車椅子関連の情報が存在するかどうかは不明
   *
   *  指示:風袋補正
   *    構造:
   *     {
   *       "name_1": "項目1名称", "weight_1": 項目1重さ(数値),
   *       "name_2": "項目2名称", "weight_2": 項目2重さ(数値),
   *       "name_3": "項目3名称", "weight_3": 項目3重さ(数値),
   *       "name_4": "項目4名称", "weight_4": 項目4重さ(数値),
   *        "name_5": "項目5名称", "weight_5": 項目5重さ(数値)
   *    }
   *  実績:風袋補正
   *    構造:
   *     {
   *       before: {
   *         "name_1": (String)"項目1名称", "weight_1": (Number)項目1重さ,
   *         "name_2": (String)"項目2名称", "weight_2": (Number)項目2重さ,
   *         "name_3": (String)"項目3名称", "weight_3": (Number)項目3重さ,
   *         "name_4": (String)"項目4名称", "weight_4": (Number)項目4重さ,
   *         "name_5": (String)"項目5名称", "weight_5": (Number)項目5重さ,
   *         "wheel_chair_cd" : (Number)"車いすマスタ.車いすコード",
   *         "wheel_chair_name": (String)"車いすマスタ.車いす名称",
   *         "wheel_chair_weight": (Number)"車いすマスタ.車いす重量"
   *       },
   *      after: { (beforeと同じ構造) }
   *     }
   * @param indTareInfo String 指示:風袋補正
   * @param rstTareInfo String 実績:風袋補正
   * @return String 実績:風袋補正
   */
  String extendIndTareInfoToRstTareInfo(
    String indTareInfo,
    String rstTareInfo
  )
  {
    //キー定義
    final String KEY_BEFORE = "before" ;    // キー:前体重測定時の風袋
    final String KEY_AFTER  = "after" ;     // キー:後体重測定時の風袋
    final String KEY_NAME   = "name_" ;     // キー:名称
    final String KEY_WEIGHT = "weight_" ;   // キー:重さ

    //指示:風袋補正 参照用(shallow copy用にfinalで固定。最終的にはdeep copy)
    JSONObject indTareInfoJson = null ;

    try {
      indTareInfoJson = new JSONObject(indTareInfo) ;
    }
    catch(Exception e)
    {
      //元になる情報がJsonパースできない
      //これは、終了させるレベルのエラーなので詳細ログを出力。nullを戻す
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("例外発生：" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      return null ;
    }

    // 構造があるかの確認(Jsonパースしてみて確認)
    JSONObject rstTareInfoJson = null ;

    try {
      //実績:風袋補正を取得&Json化(失敗した場合、catchで新規作成します)
      rstTareInfoJson = new JSONObject(rstTareInfo) ;

      //Jsonキー配列:前・後
      String[] keyItems = {
        KEY_BEFORE,
        KEY_AFTER
      } ;

      //beforeとafter分、ループ処理
      for(int index = 0 ; index < keyItems.length ; index++)
      {

        boolean errFlag = false ;       //エラーフラグ:true->エラー発生
        //キーが有るかの確認
        if(rstTareInfoJson.has(keyItems[index]))
        {
          // キーが有った

          //  キー内容の置き換え
          try {
            JSONObject setJson = (JSONObject)rstTareInfoJson.get(keyItems[index]) ;

            for(int i = 1 ; i <= 5 ; i++)
            {
              //   名称置き換え
              String key = KEY_NAME + i ;
              setJson.put(key, indTareInfoJson.get(key)) ;
              //   重さ置き換え
              key = KEY_WEIGHT + i ;
              setJson.put(key, indTareInfoJson.get(key)) ;
            }
          }
          catch(Exception e)
          {
            //パース失敗などのエラー発生
            errFlag = true ;
          }
        }
        else
        {
          //キーがなかった
          errFlag = true ;
        }

        if(errFlag)
        {
          // エラーが発生
          //  そのまま指示:風袋補正をShallow Copy
          rstTareInfoJson.put(keyItems[index], indTareInfoJson) ;
        }
      }
    }
    catch(Exception e)
    {
      //なにかあったら、上書きせずにエラー扱い
      if(null != rstTareInfo && 0 != rstTareInfo.length())
      {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("例外発生：" + e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
        return null ;
      }
      else
      {
        //なかったので新規作成
        rstTareInfoJson = new JSONObject("{}") ;
        // before分(そのまま指示:風袋補正をShallow Copy)
        rstTareInfoJson.put(KEY_BEFORE, indTareInfoJson) ;
        // after分(そのまま指示:風袋補正をShallow Copy)
        rstTareInfoJson.put(KEY_AFTER, indTareInfoJson) ;
      }
    }

    rstTareInfo = null ;

    if(null != rstTareInfoJson)
    {
      //String化(deep copy)
      rstTareInfo = rstTareInfoJson.toString() ;
    }
    return rstTareInfo ;
  }

  /**
   * 装置設定展開処理
   *  指示:装置設定とpat_main:装置設定をマージする
   *  ---------------------------------------
   *  指示:装置設定
   *    構造:
   *     {
   *       "dc": {},
   *       "na": {},
   *       "dia": {},
   *       "ufr": {},
   *       "ihdf": {},
   *       "qbqd": {},
   *       "vbufc": {}
   *    }
   *  pat_main:装置設定
   *    構造:
   *    {
   *       "bp": {},
   *       "bv": {},
   *       "ope": {},
   *       "pri": {},
   *       "war": {},
   *       "dfas": {},
   *       "ecum": {}
   *    }
   *  実績:装置設定
   *    構造:
   *     {
   *       "dc": {},
   *       "na": {},
   *       "dia": {},
   *       "ufr": {},
   *       "ihdf": {},
   *       "qbqd": {},
   *       "vbufc": {},
   *       "bp": {},
   *       "bv": {},
   *       "ope": {},
   *       "pri": {},
   *       "war": {},
   *       "dfas": {},
   *       "ecum": {}
   *    }
   * @param indDeviceSetInfo String 指示:装置設定
   * @param deviceSetInfoFromPatMain String pat_main:装置設定
   * @return String 実績:装置設定
   */
  String extendIndDeviceSetInfoToRstDeviceSetInfo(
    String indDeviceSetInfo,
    String deviceSetInfoFromPatMain
  )
  {
    String ret = null ;

    //指示:装置設定を元に実績:装置設定を組み立てる
    JSONObject rstDeviceSetInfoJson = null ;
    JSONObject deviceSetInfoFromPatMainJson = null ;

    try {
      // 指示:装置設定を元に実績:装置設定をJson化
      rstDeviceSetInfoJson = new JSONObject(indDeviceSetInfo) ;
      // ord_main:装置設定をJson化
      deviceSetInfoFromPatMainJson = new JSONObject(deviceSetInfoFromPatMain) ;

      //pat_main:装置設定のすべての要素を実績:装置設定に追加
      for(Iterator<String> i = deviceSetInfoFromPatMainJson.keys(); i.hasNext();)
      {
        String key = i.next() ;
        // 要素の取得&追加
        rstDeviceSetInfoJson.put(key, deviceSetInfoFromPatMainJson.get(key)) ;
      }

      ret = rstDeviceSetInfoJson.toString() ;
    }
    catch(Exception e)
    {
      //これは、終了させるレベルのエラーなので詳細ログを出力
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("例外発生：" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      ret = null ;
    }
    //実績:装置設定を返却
    return ret ;
  }

  /**
   * ISO8601日付の比較
   * 入力日付のフォーマットは、yyyy-MM-dd'T'HH:mm:ssX
   * @param s1  比較1
   * @param s2  比較2
   * @return
   *   s1 == s2 の場合は値0
   *   s1 <  s2 の場合は0より小さい値
   *   s1 >  s2 の場合は0より大きい値
   */
  private int compareDateLong(Object s1,Object s2)
  {
    String targetDate1 = null ;
    String targetDate2 = null ;

    final String format = "yyyy-MM-dd'T'HH:mm:ssXXX" ;
    final String formatLong = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX" ;

    try {
      //時間をlong値に変換
      String date1 = s1.toString();
      String date2 = s2.toString();
      Pattern pattern = Pattern.compile("T");
      Matcher matcher1 = pattern.matcher(date1);
      Matcher matcher2 = pattern.matcher(date2);

      String formatDate1 = matcher1.find() ? date1 : date1 + "T00:00:00.000+09:00";
      String formatDate2 = matcher2.find() ? date2 : date2 + "T00:00:00.000+09:00";

      DateTimeFormatter f1 = DateTimeFormatter.ofPattern(format);
      if (formatDate1.length() > 25) {
        f1 = DateTimeFormatter.ofPattern(formatLong);
      }
      DateTimeFormatter f2 = DateTimeFormatter.ofPattern(format);
      if (formatDate2.length() > 25) {
        f2 = DateTimeFormatter.ofPattern(formatLong);
      }

      LocalDateTime d1 = LocalDateTime.parse(formatDate1, f1);
      LocalDateTime d2 = LocalDateTime.parse(formatDate2, f2);

      DateTimeFormatter ff = DateTimeFormatter.ofPattern("yyyyMMddHHmm");
      targetDate1 = d1.format(ff);
      targetDate2 = d2.format(ff);
    }
    catch(Exception e)
    {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("例外発生：" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    }


    return targetDate1.compareTo(targetDate2);
  }

  /**
   * 指定患者の治療状況確認
   *  実績:治療状況が、治療中以上かどうかの確認
   * @param ord_no  オーダ番号
   * @param facility_cd  施設コード
   * @return false:治療中以上
   */
  private boolean checkNowPatStatusNotUnderOperation(
    Long ord_no,
    String facility_cd)
  {
    boolean ret = true ;

    //チェックメソッドの呼び出し
    ret = checkPatStatusNotUnderOperation(ord_no, facility_cd) ;

    return ret ;
  }

  /**
   * 指定した患者の治療状況の確認
   *  実績:治療状況が、治療中以上かどうかの確認
   * @param ord_no  オーダ番号
   * @param facility_cd  施設コード
   * @return true:治療中以上
   */
  public boolean checkPatStatusNotUnderOperation(Long ord_no,String facility_cd)
  {
    return dBAppWebAPIDao.checkPatStatusNotUnderOperation(ord_no, facility_cd);
  }

  /**
   *  ord_mainの更新
   *
   * @param Long        ordNo           オーダー番号
   * @param retVal  PARAMKEY:value    パラメータ授受用
   *        PARAMKEY.STATUS     Httpステータス
   *        PARAMKEY.RET_MSG    メッセージ
   *        PARAMKEY.RET_LOG_MSG    詳細メッセージ
   * @return boolean true:正常/false:異常
   */
  private boolean updateOrdMain(
    OrdMain outOrdMain,
    Map<PARAMKEY, Object> retVal
  )
  {
    //----------------------------------------------
    //ord_mainの更新

    int retInt = updateOrdMain(outOrdMain) ;
    if( 1 != retInt )
    {
      //ord_mainの更新失敗
      String retLogMsg = "ord_mainの更新に失敗しました ";
      String retMsg = "治療情報の更新に失敗しました ";
//      // エラーステータス設定
//      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
      // ロールバック用の例外を投げる
      return false;
    }

    return true;
  }

  /**
   * ord_mainの更新処理
   * @param ordMain  ord_mainエンティティクラス
   */
  public int updateOrdMain(OrdMain ordMain)
  {
    int ret = dBAppWebAPIDao.updateOrdMain(ordMain);

    return ret ;
  }

  //ステータス定義
  //ord_main 実績：治療状況rst_dialysis_stateの定義
  public enum STATUS {
    BEFORE_SENDCOND("0"),            //0:条件送信前
    DONE_SENDCOND("1"),              //1：条件送信済
    ENSURE_SENDCOND("2"),            //2：条件送信確認済み
    UNDER_TREATMENT("3"),            //3：治療中
    DONE_DRAINAGE("4"),              //4：排液済
    DONE_MEASURE_AFTER_WEIGHT("5"),  //5：後体重測定済み(実績未確定)
    ENSURE_AFTER_WEIGHT("6")         //6：後体重確認済み(過去実績)
    ;
    //値格納用

    public String strKey = null ;

    //String型のコンストラクタ
    private STATUS(String strKey) {
      this.strKey = strKey ;
    }

    //String型のGetter
    public String get() {
      return this.strKey ;
    }
  }

  /**
   * 実績治療状況ステータス変更処理
   * @param patId
   * @param ordNo オーダー番号
   * @param status ステータス
   *                ステータス                             ord_mainのステータス変更以外の処理
   *                0：条件送信前、                 ※0は、pat_mainの区分と値をクリア(null)
   *                1：条件送信済、                ※実績：条件送信日時も設定。pat_mainは区分のみ設定(値は何もしない)
   *                2：条件送信確認済み
   *                3：治療中、                        ※pat_mainの区分と値を設定する
   *                4：排液済、                         ※pat_mainの区分のみ設定する(値は何もしない)
   *                5：後体重測定済み(実績未確定)
   *                6：後体重確認済み(過去実績)  ※6は、pat_mainの区分と値をクリア(null)
   * @param startDateTime 治療開始日時
   * @param treatmentTime 治療時間[分]
   * @return true:成功 false:失敗
   */
  public boolean changeTreatStatusOrdAndPat(
    Long patId,
    Long ordNo,
    String status,
    Date startDateTime,
    String treatmentTime
  )
  {
    boolean ret = true ;

    //クラス名の取得(ログ用)
    final String className = new Object(){}.getClass().getEnclosingClass().getName();
    //メソッド名の取得(ログ用)
    final String methodName = new Object(){}.getClass().getEnclosingMethod().getName();

    //開始ログ
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(className + "." + methodName + "の処理を開始しました(pat_id:" + patId + " ord_no:" + ordNo + " status:" + status +")");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    //statusのenum化(switchで使用するため)
    STATUS enumStatus = getEnumByOrdinal(STATUS.class, Integer.parseInt(status));

    //ord_mainの条件送信日時更新フラグ(true:更新)
    boolean updateOrdMainSendDateFlag = false ;

    //pat_mainのステータスクリアフラグ(true:クリア)
    boolean clearPatMainStatusFlag = false ;
    //pat_mainのステータス(区分)更新フラグ(true:更新)
    boolean changePatMainClassFlag = false ;
    //pat_mainのステータス(値)更新フラグ(true:更新)
    boolean changePatMainValueFlag = false ;

    switch(enumStatus)
    {
//      case BEFORE_SENDCOND:     //0:条件送信前
//        //pat_mainクリア
//        clearPatMainStatusFlag = true ;
//        break;
      case DONE_SENDCOND:       //1：条件送信済
      case ENSURE_SENDCOND:     //2：条件送信確認済み
        //条件送信日時の更新(mnt_machine_stateの条件送信日時cond_send_dateで更新)
        //updateOrdMainSendDateFlag = true ;
        //pat_mainのステータスの区分を変更
//        changePatMainClassFlag = true ;
        break;
//      case UNDER_TREATMENT:     //3：治療中
//        //pat_mainのステータスの区分を変更
//        changePatMainClassFlag = true ;
//        //pat_mainのステータスの値を変更
//        changePatMainValueFlag = true ;
//        break;
//      case DONE_DRAINAGE:       //4：排液済
//        //pat_mainのステータスの区分を変更
//        changePatMainClassFlag = true ;
//        break;
//      case DONE_MEASURE_AFTER_WEIGHT://5：後体重測定済み(実績未確定)
//        //ord_mainのみ変更
//        break;
//      case ENSURE_AFTER_WEIGHT: //6：後体重確認済み(過去実績)
//        //pat_mainクリア
//        clearPatMainStatusFlag = true ;
//        break;
      default:
        //想定外の状態指定
        ret = false ;
    }

    if(ret)
    {
      //ord_mainの状態書き換え
      //DB(ord_main)の更新

      int retOrdMain = updateOrdMainStatus(
        ordNo,
        status
      );

      if(retOrdMain != 1)
        ret = false ;

//      //TODO:実績のクリア
//      //ステータスが0の場合、その他：指示->実績にコピーする部分はすべてクリア
//
//      if(ret && (clearPatMainStatusFlag || changePatMainClassFlag))
//      {
//        //DB(pat_main)の更新
//        try
//        {
//          int retPatMain = patMainAcceptanceStatusInfoService.update(patId, ordNo, status, startDateTime, treatmentTime);
//          if(retPatMain != 1)
//            ret = false;
//        }
//        catch(Exception e)
//        {
//          eventLogMessage.setLogMessage(className + "." + methodName + "の処理が失敗しました:"+ e.getMessage());
//          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
//          ret = false;
//        }
//      }
    }
    //終了ログ
    eventLogMessage.setLogMessage(className + "." + methodName + "の処理を終了しました(pat_id:" + patId + " ord_no:" + ordNo + " status:" + status +")");
    logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    return ret ;
  }

  /**
   * ord_mainの状態変更用
   * @param ord_no オーダー番号
   * @param status ステータス
   * @return update件数
   * @throws Exception
   */
  public int updateOrdMainStatus(
    long  ord_no,
    String status
  )
  {
    int ret = -1 ;

    ret = operateStatusDao.updateOrdMainStatusCommFail(ord_no, status);

    return ret ;
  }


  /**
   * Ordinal番号を元に対応するEnumを取得する
   * @param enumClass   enum定義クラス
   * @param ordinal     ordinal番号
   * @return Enum
   */
  public static <E extends Enum<E>> E getEnumByOrdinal(Class<E> enumClass, int ordinal) {
    E[] enumArray = enumClass.getEnumConstants();
    return enumArray[ordinal];
  }


  /**
   * ord_main情報の取得
   */
  public OrdMain getOrdMainInfo(Long ord_no) {
    return ordMainDao.selectByOrdNo(ord_no);
  }

  /**
   *  ord_mainの取得
   *
   * @param Long        ordNo           オーダー番号
   * @param retVal  PARAMKEY:value    パラメータ授受用
   *        PARAMKEY.STATUS     Httpステータス
   *        PARAMKEY.RET_MSG    メッセージ
   *        PARAMKEY.RET_LOG_MSG    詳細メッセージ
   * @return OrdMainエンティティ
   */
  private OrdMain getOrdMainData(
    Long ordNo,
    Map<PARAMKEY, Object> retVal
  ) throws JSONException
  {
    //ord_mainのデータ取得
    OrdMain ordMainData = getOrdMainInfo(ordNo) ;
    if(null == ordMainData)
    {
      //ord_mainからのデータ取得に失敗
      String fmt = "ord_mainからのデータ取得に失敗しました ordNo:%s"  ;
      String retLogMsg = String.format(fmt, ordNo) ;
      String retMsg = "治療情報の取得に失敗しました。"  ;
//      // エラーステータス設定
//      retVal.put(PARAMKEY.STATUS, HttpStatus.INTERNAL_SERVER_ERROR) ;
      // エラーメッセージ設定
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
      //※流れ的にこのreturnがなくても問題ないが、後に変更が入った場合のことを考えreturn nullしておく
      return null;
    }

    return ordMainData;
  }

  /**
   * 分類区分取得処理
   *
   * @param cd           医療材料コードと薬剤コード
   * @param classTypeflg 0:医療材料分類; 1:薬剤分類;
   * @param facilityCd   施設コード
   * @return classType
   */
  private MstEquipmentMstMedicine getClassType(int cd, int classTypeflg, String facilityCd) {
    MstEquipmentMstMedicine classType = new MstEquipmentMstMedicine();
    if (classTypeflg == 0) {
      classType = ordMainDao.selectClassTypeFromMstEquipment(cd, facilityCd);
    }
    if (classTypeflg == 1) {
      classType = ordMainDao.selectClassTypeFromMstMedicine(cd, facilityCd);
      if (classType == null) {
        classType = ordMainDao.selectClassTypeFromMstMedicineMix(cd, facilityCd);
      }
    }
    return classType;
  }
}
