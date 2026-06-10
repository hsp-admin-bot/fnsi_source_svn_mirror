package jp.co.nikkiso.ntss.admin_web.service.statusList;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.request.patientCapture.JournalCreateRequestPayload;
import jp.co.nikkiso.ntss.admin_web.request.statusList.CheckAfterWeightRequest;
import jp.co.nikkiso.ntss.admin_web.response.deviceEdgeOrder.DeviceEdgeOrderResponse;
import jp.co.nikkiso.ntss.admin_web.response.statusList.AllConfirmResponse;
import jp.co.nikkiso.ntss.admin_web.service.AsyncService;
import jp.co.nikkiso.ntss.admin_web.service.SelectHistoryUtils;
import jp.co.nikkiso.ntss.admin_web.service.autoPrint.AutoPrintService;
import jp.co.nikkiso.ntss.admin_web.service.deviceEdgeOrder.DeviceEdgeOrderService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallCommonUtil;
import jp.co.nikkiso.ntss.api.service.PatMainAcceptanceStatusInfo.PatMainAcceptanceStatusInfoService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstBedDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstReportDao;
import jp.co.nikkiso.ntss.core.dao.MstTreatmentDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.entity.MstBed;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstReport;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainForWeightInd;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.service.ordMaterialSaveService.OrdMaterialSaveService;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import org.json.JSONObject;
import org.seasar.doma.jdbc.Config;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import org.springframework.aop.framework.AopProxyUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestTemplate;

import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.nio.charset.StandardCharsets;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Base64;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.TimeZone;
import java.util.regex.Pattern;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end

@Service
public class DialysisConfirmServiceImpl implements DialysisConfirmService {

  //add #9616 帳票印刷失敗通知がされない 李 start
  @Value("${ntss.admin-web.web-api.url}/util/notificationReciever")
  private String webApi;
  //add #9616 帳票印刷失敗通知がされない 李 end

  @Autowired
  private WebApiCallCommonUtil webApiCallCommonUtil;
  @Autowired
  private SelectHistoryUtils selectHistoryUtils;

  @Autowired
  private PatMainAcceptanceStatusInfoService patMainAcceptanceStatusInfoService;

  @Autowired
  private OrdMaterialSaveService ordMaterialSaveService;

  @Autowired
  private AutoPrintService autoPrintService;
  @Autowired
  private AsyncService asyncService;
  @Autowired
  private DeviceEdgeOrderService deviceEdgeOrderService;

  @Autowired
  OrdMainDao ordMainDao;
  @Autowired
  PatMainDao patMainDao;

  @Autowired
  MstBedDao mstBedDao;

  @Autowired
  MstReportDao mstReportDao;

  @Autowired
  MstTreatmentDao mstTreatmentDao;

  @Autowired
  MstPersonalUserDao mstPersonalUserDao;

  @Autowired
  MstFacilitySettingDao mstFacilitySettingDao;

  @Autowired
  LogService logService;

  @Autowired
  private EventLoggerFactory eventLoggerFactory;
  @Autowired
  private LogServiceCore logServiceCore;
  @Autowired
  private ObjectMapper mapper;

  /**
   * 確認ボタン押下時処理
   * ord_mainの初版確定、ステータス、版番号更新
   */
  @Override
  @Transactional
  public int updateCheckAfterWeight(CheckAfterWeightRequest ordInfo, Long sessionUserId, EventLogMessage eventLogMessage) {

    Date nowDate = new Date();
    int rtn = 0;

    // 投薬の実施状況を取得
    /// まず対象となるオーダー番号のリストを作成
    List<Long> ordNoList = new ArrayList<Long>();
    // #10338 2024.03.28 mod オーダー1件ずつの処理に改修 TDC片口 start
//    for (int lop = 0; lop < ordInfoList.size(); lop++) {
//      CheckAfterWeightRequest ordInfo = ordInfoList.get(lop);
//      ordNoList.add(ordInfo.getOrdNo());
//    }
    ordNoList.add(ordInfo.getOrdNo());
    // #10338 2024.03.28 mod オーダー1件ずつの処理に改修 TDC片口 end
    /// オーダー番号のリストに対応する投薬の実施状況を取得
    List<OrdMain> ordMainList = ordMainDao.selectMediInfoByNoList(ordNoList);
    //add #10196 Ord_Material_Save operation 20240126 ztc start
    // del 12250 ord_material_saveの処理を2回重複実行している zkm start
//    List<MaterialSaveCacheHandler.DiffResultContainer> diffMaterialSaveRstList = new ArrayList<>();
    // del 12250 ord_material_saveの処理を2回重複実行している zkm end
    //add #10196 Ord_Material_Save operation 20240126 ztc end
    // #10338 2024.03.28 mod オーダー1件ずつの処理に改修 TDC片口 start
//    for (int lop1 = 0; lop1 < ordInfoList.size(); lop1++) {
//      CheckAfterWeightRequest ordInfo = ordInfoList.get(lop1);
    Long ordNo = ordInfo.getOrdNo();
    Long userId = ordInfo.getUserId();

    // ordNoに対応したmediInfo(JSON文字列)を取得
    String mediInfo = "";
    for (OrdMain ordMain : ordMainList) {
      if (Objects.equals(ordMain.getOrdNo(), ordNo)) {
        mediInfo = ordMain.getRstMediInfo();
        break;
      }
    }

    // 未実施の投薬を実施にする場合
    if (ordInfo.isDoCompleteMedi() && !mediInfo.isEmpty()) {
      // mediInfo JSON文字列を更新
      mediInfo = this.updateMediInfoToComplete(mediInfo, nowDate, userId);
    }

    // add FNSI-改修内容追加OrdMain履歴 付 start
    getHistory(ordNo);
    // mangoDb-updateCheckAfterWeight-insertSuccess
    // add FNSI-改修内容追加OrdMain履歴 付 end

    // DB更新ログ出力ロジック wangzuo Start
    String tableNameCheck = "ord_main";
    // SQL検索条件
    StringBuffer wheresCheck = new StringBuffer();
    wheresCheck.append(" WHERE\n");
    wheresCheck.append(" ord_no = ").append(ordNo).append("\n");
    // logCommon設定
    DataUpdateLogCommonNew logCommonCheck = getLogCommon(ordMainDao, tableNameCheck, wheresCheck, eventLogMessage);
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResultCheck = logCommonCheck.setInfo();
    // DB更新ログ出力ロジック wangzuo End

    // #10337 2024.04.25 mod 治療ステータスと版確定フラグは先に更新されているので版番号とmediInfoのみ更新する TDC片口 start
    // ord_mainを更新
//    int result = ordMainDao.updateCheckAfterWeight(ordNo, mediInfo);
    int result = ordMainDao.updateMediInfoAndEditionUp(ordNo, mediInfo);
    // #10337 2024.04.25 mod 治療ステータスと版確定フラグは先に更新されているので版番号とmediInfoのみ更新する TDC片口 end

    OrdMain ordMainForConfirm = ordMainDao.selectByOrdNo(ordNo);
    // #10338 2024.04.02 mod スレッドではコンテキストを取得できないので方法を変える TDC片口 start
////      add 8074 【デグレ】ログに誤った利用者が記録される 関 start
//    NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
//    ordMainForConfirm.setLogUserId(user.getUserId().toString());
////      add 8074 【デグレ】ログに誤った利用者が記録される 関  end
    ordMainForConfirm.setLogUserId(sessionUserId.toString());
    // #10338 2024.04.02 mod スレッドではコンテキストを取得できないので方法を変える TDC片口 end
    ordMainForConfirm.setRstEditionDate(new Timestamp(System.currentTimeMillis()));

    ordMainForConfirm.setCurEditionDate(new Timestamp(System.currentTimeMillis()));
    //add FNSI-redmine5863&5865 fang start
    if (ordMainForConfirm.getRstEndDate() == null) {
      if (ordMainForConfirm.getRstInputClass() != null && "2".equals(String.valueOf(ordMainForConfirm.getRstInputClass()))) {
        String tempTreatDate = ordMainForConfirm.getTreatDate();
        String tempTreatStartTime = ordMainForConfirm.getIndTreatStartTime();
        if (tempTreatDate != null && tempTreatStartTime != null
          && !tempTreatDate.isEmpty() && !tempTreatStartTime.isEmpty()) {
          String tempTreatDateAndTIme = tempTreatDate + " " + tempTreatStartTime;
          SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd HHmm");
          try {
            Date tempDate = sdf.parse(tempTreatDateAndTIme);
            if (ordMainForConfirm.getRstCondInfo() != null) {
              JSONObject treatmentInfoObj = new JSONObject(ordMainForConfirm.getRstCondInfo());
              if (treatmentInfoObj.has("1")) {
                JSONObject treatmentTimeInfo = (JSONObject) treatmentInfoObj.get("1");
                if (treatmentTimeInfo.has("value")) {
// mod #6899 2022/8/10 治療状況リストで実績確定を行っても実績確定されず再度リストに表示される。 dou start
//                    Integer tempTreatTime = treatmentTimeInfo.getInt("value");
//                    if (tempTreatTime != null) {
//                      Calendar timeCalendar = Calendar.getInstance();
//                      timeCalendar.setTime(tempDate);
//                      timeCalendar.add(Calendar.MINUTE, tempTreatTime);
                  Object tempTreatTime = treatmentTimeInfo.get("value");
                  if (tempTreatTime != null && isInteger(String.valueOf(tempTreatTime))) {
                    Calendar timeCalendar = Calendar.getInstance();
                    timeCalendar.setTime(tempDate);
                    timeCalendar.add(Calendar.MINUTE, Integer.parseInt(String.valueOf(tempTreatTime)));
// mod #6899 2022/8/10 治療状況リストで実績確定を行っても実績確定されず再度リストに表示される。 dou end
                    ordMainForConfirm.setRstEndDate(new Timestamp(timeCalendar.getTimeInMillis()));
                  }
                }
              }
            }
          } catch (ParseException e) {
            eventLogMessage.setLogMessage("API updateCheckAfterWeight: build rst_end_date failure. " + e.getMessage());
            logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_TREATMENT_RECORD, LoggingConstant.SERVICE_NAME.REMS, null);
          }
        }
      }
    }
    //add FNSI-redmine5863&5865 fang end

    // add #8642 「治療記録>変更履歴の内容が不正」について、対応する。 dengshen start
    ordMainForConfirm.setUpdateFlg(false);
    // add #8642 「治療記録>変更履歴の内容が不正」について、対応する。 dengshen end
    ordMainDao.update(ordMainForConfirm);
    // add #8642 「治療記録>変更履歴の内容が不正」について、対応する。 dengshen start
    ordMainForConfirm.setUpdateFlg(true);
    // add #8642 「治療記録>変更履歴の内容が不正」について、対応する。 dengshen end

    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResultCheck && result > 0) {
      logCommonCheck.updateLog();
    }
    // DB更新ログ出力ロジック wangzuo End

    // add FNSI-改修内容追加OrdMain履歴 付 start
    selectHistoryUtils.insertMangoDbHistory(7, ordNo, null, new ArrayList<>(), new ArrayList<>(), null, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
      new ArrayList<>(), null, null);
    // mangoDb-updateIsConfirm-insertSuccess
    // add FNSI-改修内容追加OrdMain履歴 付 end

    // #10337 2024.05.16 del 確定フラグは更新済みなので更新処理を削除 TDC片口 start
//    // DB更新ログ出力ロジック wangzuo Start
//    String tableNameIs = "ord_main";
//    // SQL検索条件
//    StringBuffer wheresIs = new StringBuffer("");
//    wheresIs.append(" WHERE\n");
//    wheresIs.append(" is_confirm = '0'\n");
//    wheresIs.append(" and ord_no = " + ordNo + "\n");
//    // logCommon設定
//    DataUpdateLogCommonNew logCommonIs = getLogCommon(ordMainDao, tableNameIs, wheresIs, eventLogMessage);
//    // ログ出力カラム情報及び更新前データ情報取得
//    boolean setResultIs = logCommonIs.setInfo();
//    // DB更新ログ出力ロジック wangzuo End
//
//    // 版確定フラグを「1：確定」にする
//    int updateCountIs = ordMainDao.updateIsConfirm(ordNo, "0", "1");
//
//    // DB更新ログ出力ロジック wangzuo Start
//    // 更新後データ取得、差分あれば、log出力
//    if (setResultIs && updateCountIs > 0) {
//      logCommonIs.updateLog();
//    }
//    // DB更新ログ出力ロジック wangzuo End
    // #10337 2024.05.16 del 確定フラグは更新済みなので更新処理を削除 TDC片口 end

    // 治療記録を取得する
    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);

    //  del 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
    // add FNSI-改修内容追加ordChecklist処理 付 start
    //      if (Objects.equals(ordMain.getRstDialysisState(), "5")) {
    //        ordChecklistDao.updateRstClass(ordNo);
    //      }
    // add FNSI-改修内容追加ordChecklist処理 付 end
    //  del 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
    // 透析回数の取得
    Long dialCount = ordMain.getRstDialysisCnt() == null ? 0L : ordMain.getRstDialysisCnt();
    // 浄化治療回数の取得
    Long purificateCount = ordMain.getRstPurificationCnt() == null ? 0L : ordMain.getRstPurificationCnt();

    // オーダーの患者IDから患者基本情報を取得
    PatMain patMain = patMainDao.selectById(ordMain.getPatId());
    if (patMain != null) {
      String medicalCareInfo = patMain.getMedical_care_info() == null ? "{}" : patMain.getMedical_care_info();
      try {

        //
        JsonNode nodeMedicalCareInfo = mapper.readTree(medicalCareInfo);
        ObjectNode objectNode = nodeMedicalCareInfo.deepCopy();

        // 治療方法を取得して患者基本情報の透析回数か浄化治療回数を更新
        MstTreatment treat = mstTreatmentDao.selectByCd(ordMain.getRstTreatmentCd());
        if (treat.getDeviceMode().equals(9)) {
          // 特殊浄化：浄化治療回数「purification_count」
          objectNode.put("purification_count", purificateCount);
        } else {
          // 透析：透析回数「dialysis_count」
          objectNode.put("dialysis_count", dialCount);
          //add 6832 【デグレ】治療記録における特殊血液浄化回数が不正 周安寧　start
          // 患者通算透析奇数
          long patDialysisCount = objectNode.get("pat_dialysis_count") == null ? 0L : objectNode.get("pat_dialysis_count").asLong();

          objectNode.put("pat_dialysis_count", patDialysisCount + 1);
          //add 6832 【デグレ】治療記録における特殊血液浄化回数が不正 周安寧　end
        }

        // DB更新ログ出力ロジック wangzuo Start
        patMain.setPat_id(ordMain.getPatId());
        // DB更新ログ出力ロジック wangzuo End
        //add 6832 【デグレ】治療記録における特殊血液浄化回数が不正 周安寧　start
        patMain.setMedical_care_info(objectNode.toString());
        //add 6832 【デグレ】治療記録における特殊血液浄化回数が不正 周安寧　end
        // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
        LogEventUtils.setOperatorId(patMain,logService);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
        // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
        patMainDao.updateById(ordMain.getPatId(), patMain);
      } catch (Exception e) {
        eventLogMessage.setLogMessage("API updateCheckAfterWeight: update dialysis count failure. " + e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_TREATMENT_RECORD, LoggingConstant.SERVICE_NAME.REMS, null);
      }
    }

    // 患者ID
    Long patId = ordMain.getPatId();

    // pat_mainのステータスを更新
    // pat_mainのacceptance_status_infoを更新する。
    patMainAcceptanceStatusInfoService.update(patId, ordNo, CoreConstant.rstDialysisState.BEFORE_SEND_CONDITIOM, null, null);

    // #10338 2024.03.28 mod ここより以前に通信サーバーへの通知を行っている重複処理なので削除 TDC片口 start
//    //add FNSI修正 305 房 start
//    if (Objects.equals(ordMain.getRstInputClass(), 1)) {
//      // comsv_settingの次患者切り替えタイミングの設定によりmnt_machine_stateの現患者クリアAPIを呼び出す
//      // 通信サーバーに後体重確認信号を通知
//      SendConditionResponse r = postSendAfterWeightWs(ordNo, facilityCd);
//      if (r.isSuccess) {
//        EventLogMessage eventLogMessage = new EventLogMessage();
//        eventLogMessage.setLogMessage("確認ボタン押下時処理：updateCheckAfterWeight() 通信サーバーへ通知しました。(ord_no:" + ordNo + ")");
//        logService.log(LogLevel.INFO, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_TREATMENT_RECORD, LoggingConstant.SERVICE_NAME.REMS, null);
//      } else {
//        EventLogMessage eventLogMessage = new EventLogMessage();
//        eventLogMessage.setLogMessage(
//          "確認ボタン押下時処理：updateCheckAfterWeight() 通信サーバーへの通知に失敗しました。(ord_no:" + ordNo + ")\n" + r.errorMessage);
//        logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_TREATMENT_RECORD, LoggingConstant.SERVICE_NAME.REMS, null);
//      }
//    }
//    //add FNSI修正 305 房 end
    // #10338 2024.03.28 mod ここより以前に通信サーバーへの通知を行っている重複処理なので削除 TDC片口 end

    rtn = rtn + result;
    // mod #9845 愁訴処置に入力した薬剤がord_material_saveに登録されない start
    //mod #10196 Ord_Material_Save operation 20240126 ztc start
//      ordMaterialSaveService.updateOrdMaterialSave(new OrdMaterialSaveDto(
    // del 12250 ord_material_saveの処理を2回重複実行している zkm start
//    MaterialSaveCacheHandler.DiffResultContainer diffMaterialSaveRst = ordMaterialSaveService.updateOrdMaterialSaveByDiff(new OrdMaterialSaveDto(
//      ordNo,
//      true,
//      true,
//      true,
//      true,
//      "2",
//      ordMain
//    ));
//    diffMaterialSaveRstList.add(diffMaterialSaveRst);
    // del 12250 ord_material_saveの処理を2回重複実行している zkm end
    // mod #9845 愁訴処置に入力した薬剤がord_material_saveに登録されない end
//    }
//    if (!diffMaterialSaveRstList.isEmpty()) {
    // mod 12250 ord_material_saveの処理を2回重複実行している zkm start
//    ordMaterialSaveService.batchProcessingData(diffMaterialSaveRstList);
    ordMaterialSaveService.bulkUpdateByOrdNoInCondMediEquipTreatment(Collections.singletonList(ordMain.getOrdNo()));
    // mod 12250 ord_material_saveの処理を2回重複実行している zkm end
//    }
    // #10338 2024.03.28 mod オーダー1件ずつの処理に改修 TDC片口 end
    //mod #10196 Ord_Material_Save operation 20240126 ztc end
    return rtn;
  }

  private String updateMediInfoToComplete(String mediInfo, Date nowDate, Long userId) {
    // ISO8601形式の日付文字列取得
    String nowDate_iso8601 = this.getDateString_iso8601(nowDate);
    // 戻り値格納用StringBuilder
    StringBuilder rtnBuilder = new StringBuilder();
    rtnBuilder.append("[");

    // JSON処理
    try {
      JsonNode jsonNode_array = mapper.readTree(mediInfo);

      for (int lop = 0; lop < jsonNode_array.size(); lop++) {
        JsonNode jsonNode = jsonNode_array.get(lop);
        // jsonNodeは読み取り専用のため、ObjectNodeに変換
        ObjectNode objectNode = jsonNode.deepCopy();

        if (objectNode.get("effect_flg").asInt() != 1) {
          // 値の変更
          objectNode.put("effect_flg", 1);
          objectNode.put("effect_date", nowDate_iso8601);
          objectNode.put("effect_user_id", userId);
          // userId に紐づく利用者情報を取得
          MstPersonalUser userInfo = mstPersonalUserDao.selectById(userId);
          if (userInfo != null) {
            objectNode.put("effect_user_last_name", userInfo.getUserLastName());
            objectNode.put("effect_user_first_name", userInfo.getUserFirstName());
          }
        }

        // objectNodeの文字列化
        rtnBuilder.append(mapper.writeValueAsString(objectNode));
        // 最後以外は区切りのカンマを追加
        if (lop != jsonNode_array.size() - 1) {
          rtnBuilder.append(",");
        }
      }
    } catch (IOException e) {
      // TODO 自動生成された catch ブロック
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }

    rtnBuilder.append("]");

    return rtnBuilder.toString();
  }

  private String getDateString_iso8601(Date date) {
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZZZ");
    sdf.setTimeZone(TimeZone.getTimeZone("JST"));
    String dateString = sdf.format(date);
    return dateString;
  }

  @Override
  public AllConfirmResponse autoPrint(CheckAfterWeightRequest ordInfo, String facilityCd, Long userId, String userName) {
    AllConfirmResponse allConfirmResponse = new AllConfirmResponse("");
    allConfirmResponse.isSuccess = true;
    Long bedCd = ordMainDao.selectByOrdNo(ordInfo.getOrdNo()).getRstBedCd();
    MstBed mstBed = null;
    String reportName = "";
    MstReport mr = new MstReport();
    String rstTreatmentCd = null;
    //add #9616 帳票印刷失敗通知がされない 李 start
    boolean isSuccessAutoPrint = true;
    // add #9616 帳票印刷失敗通知がされない 高　start
    try {
// add #9616 帳票印刷失敗通知がされない 高 2024/01/12　start
      mstBed = mstBedDao.selectByBedCd(bedCd, AdminWebConstant.FlagType.FLAG_ON, AdminWebConstant.FlagType.FLAG_OFF);
      if (!Objects.isNull(mstBed)) {
        if (AdminWebConstant.FlagType.FLAG_ON.equals(mstBed.getIsAutoprintCommit())) {
          // add #9616 帳票印刷失敗通知がされない 高 2024/01/12　end
          // 自動印刷
          allConfirmResponse.autoPrintResults = new ArrayList<>();

          // #10338 2024.03.28 mod オーダー1件ずつの処理に改修 TDC片口 start
//          for (CheckAfterWeightRequest ordInfo : request) {
          // add 9616 テンプレート繰返し時に元々値があるセルは上書きしないようにすること　吉 start
          OrdMainForWeightInd ord = ordMainDao.selectForWeightIndByOrdNo(ordInfo.getOrdNo());
          // add 9616 テンプレート繰返し時に元々値があるセルは上書きしないようにすること　吉 end

          // add #9616 帳票印刷失敗通知がされない 高　start
          if (ord != null) {
            if (ord.getRstTreatmentCd() != null) {
              rstTreatmentCd = String.valueOf(ord.getRstTreatmentCd());
            }
          }
          // add #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
          reportName = autoPrintGetReportName(rstTreatmentCd, mr, facilityCd);
          // add #9616 帳票印刷失敗通知がされない 高 2024/01/25　end

          // add #9616 帳票印刷失敗通知がされない 高　end

          try {
            AutoPrintService.AutoPrintResult printR = autoPrintService.reportAutoPrint(ordInfo.getOrdNo(), AutoPrintService.TimingEnum.commitEdition,
              userId, userName);
            allConfirmResponse.autoPrintResults.add(printR);
            // add FNSI-実績確定時自動印刷の修正 徐 start
            if (!com.amazonaws.util.StringUtils.isNullOrEmpty(printR.autoPrintErrorMessage)) {
              // add FNSI-実績確定時自動印刷の修正 徐 end
              EventLogMessage eventLogMessage = new EventLogMessage();
              eventLogMessage.setLogMessage(printR.autoPrintErrorMessage);
              logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
            }

            //add #9616 帳票印刷失敗通知がされない 李 start
            // mod 9616 テンプレート繰返し時に元々値があるセルは上書きしないようにすること　吉 start
            if (!printR.isSuccessAutoPrint && !Objects.equals(ord.getRstInputClass(), 2)) {
              // mod 9616 テンプレート繰返し時に元々値があるセルは上書きしないようにすること　吉 end
              isSuccessAutoPrint = printR.isSuccessAutoPrint;
            }
            //add #9616 帳票印刷失敗通知がされない 李 end
          } catch (Exception ex) {
            EventLogMessage eventLogMessage = new EventLogMessage();
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
            eventLogMessage.setLogMessage(ExcetionStackTraceToString(ex));
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
            logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
            // add 9616 テンプレート繰返し時に元々値があるセルは上書きしないようにすること　吉 start
            if (!Objects.equals(ord.getRstInputClass(), 2)) {
              // add 9616 テンプレート繰返し時に元々値があるセルは上書きしないようにすること　吉 end
              AutoPrintService.AutoPrintResult printR = new AutoPrintService.AutoPrintResult();
              printR.isAutoPrint = true;
              printR.isSuccessAutoPrint = false;
              printR.autoPrintErrorMessage = "帳票自動印刷失敗";
              allConfirmResponse.autoPrintResults.add(printR);

              //add #9616 帳票印刷失敗通知がされない 李 start
              isSuccessAutoPrint = printR.isSuccessAutoPrint;
              //add #9616 帳票印刷失敗通知がされない 李 end
              // add 9423 テンプレート繰返し時に元々値があるセルは上書きしないようにすること　吉 start
            }
            // add 9423 テンプレート繰返し時に元々値があるセルは上書きしないようにすること　吉 end
          }
//          }
          // #10338 2024.03.28 mod オーダー1件ずつの処理に改修 TDC片口 end

          //add #9616 帳票印刷失敗通知がされない 李 start
          if (!isSuccessAutoPrint) {
            // mod #9616 帳票印刷失敗通知がされない 高　start
//          saveNotiMessage("治療経過表","実際確認",ntssUser.getFacilityCd());
            // mod #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
            sendFailureNotification(reportName, facilityCd);
//            saveNotiMessage("治療経過表",reportName,ntssUser.getFacilityCd());
            // mod #9616 帳票印刷失敗通知がされない 高 2024/01/25　end
            // mod #9616 帳票印刷失敗通知がされない 高　end
            // add #9616 帳票印刷失敗通知がされない 高 2024/01/12　start
          }
          // add #9616 帳票印刷失敗通知がされない 高 2024/01/12　end
        }
      }
      //add #9616 帳票印刷失敗通知がされない 李 end
      return allConfirmResponse;
    } catch (Exception e) {
      // 例外発生時、BAD_REQUESTを返す
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST request error by updateCheckAfterWeight: " + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      allConfirmResponse.errorMessage = "データ更新エラー";
      allConfirmResponse.errDetail = e.getMessage();
      allConfirmResponse.isSuccess = false;

      //add #9616 帳票印刷失敗通知がされない 李 start
      // add #9616 帳票印刷失敗通知がされない 高 2024/01/12　start
      if (!Objects.isNull(mstBed)) {
        if (AdminWebConstant.FlagType.FLAG_ON.equals(mstBed.getIsAutoprintCommit())) {
          sendFailureNotification(reportName, facilityCd);
        }
        // add #9616 帳票印刷失敗通知がされない 高 2024/01/12　end
      }
      //add #9616 帳票印刷失敗通知がされない 李 end

      return allConfirmResponse;
    }
  }

  private void getHistory(Long ordNo) {
    selectHistoryUtils.insertMangoDbHistory(1, ordNo, null, new ArrayList<>(), new ArrayList<>(), null, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
      new ArrayList<>(), null, null);
  }

  /**
   * ログ出力共通クラス設定、取得
   *
   * @return logCommon ログ出力共通クラス
   */
  private DataUpdateLogCommonNew getLogCommon(Object dao, String tableName, StringBuffer whereStr, EventLogMessage eventLogMessage) {
    DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();
    logCommon.setEventLoggerFactory(eventLoggerFactory);
    logCommon.setLogServiceCore(logServiceCore);
    logCommon.setConfig(Config.get(dao));
    logCommon.setTableName(tableName);
    logCommon.setWhereStr(whereStr);
    logCommon.setCommonEventLogMessage(eventLogMessage);
    return logCommon;
  }

  public static boolean isInteger(String str) {
    Pattern pattern = Pattern.compile("^[-\\+]?[\\d]*$");
    return pattern.matcher(str).matches();
  }

  // add #9616 帳票印刷失敗通知がされない 高 2024/01/25　start

  /**
   * 400および117からReportCdでReportNameを取ります。(実際確認)
   *
   * @param rstTreatmentCd
   * @param mr
   * @param facilityCd
   * @return 帳票名です.
   */
  private String autoPrintGetReportName(String rstTreatmentCd, MstReport mr, String facilityCd) {
    boolean getReportNameFlag = true;
    String reportName = "";
    try {
      if (!StringUtils.isEmpty(rstTreatmentCd)) {
        getReportNameFlag = true;
        MstTreatment mstTreatment = mstTreatmentDao.selectByCd(Integer.valueOf(rstTreatmentCd));
        if (!StringUtils.isEmpty(mstTreatment.getReportIdAct())) {
          // 400
          // 実際確認ReportName取得します。
          mr = mstReportDao.selectByCd((long) mstTreatment.getReportIdAct());
        } else {
          // 117
          getReportNameFlag = false;
          FacilitySettingInfo facilitySettingInfo = mstFacilitySettingDao.getBySettingNoAndCd(facilityCd, CoreConstant.FacilitySettingNo.DEFAULT_REPORT_TEMPLATE);
          if (!StringUtils.isEmpty(facilitySettingInfo.getValue())) {
            Long reportCd = Long.parseLong(facilitySettingInfo.getValue());
            if (reportCd != 0) {
              mr = mstReportDao.selectByCd(reportCd);
            }
          }
        }
      }
    } catch (Exception ex) {
      // 400 -> errorの場合
      if (getReportNameFlag) {
        try {
          // 117
          FacilitySettingInfo facilitySettingInfo = mstFacilitySettingDao.getBySettingNoAndCd(facilityCd, CoreConstant.FacilitySettingNo.DEFAULT_REPORT_TEMPLATE);
          if (!StringUtils.isEmpty(facilitySettingInfo.getValue())) {
            Long reportCd = Long.parseLong(facilitySettingInfo.getValue());
            if (reportCd != 0) {
              mr = mstReportDao.selectByCd(reportCd);
            }
          }
        } catch (Exception ex1) {
        }
      }
    } finally {
      if (!StringUtils.isEmpty(mr) && !StringUtils.isEmpty(mr.getReportName())) {
        reportName = mr.getReportName();
      }
    }
    return reportName;
  }

  /**
   * 失敗通知を送ります.
   *
   * @param reportName
   * @param facilityCd
   */
  private void sendFailureNotification(String reportName, String facilityCd) {
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    JSONObject replaceData = new JSONObject();
    replaceData.put("REPORTTYPE", "治療経過表");
    replaceData.put("REPORTNAME", reportName);
    replaceData.put("UP_DATE", sdf.format(new Date()));
    JSONObject jsonBody = new JSONObject();
    jsonBody.put("notificationNo", CoreConstant.NotificationDefinition.PRINT_FAIL);
    jsonBody.put("facilityCd", facilityCd);
    // 変換用文字列のエンコード処理(UTF-8)
    String base64replaceData = new String(Base64.getEncoder().encode(replaceData.toString().getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8);
    jsonBody.put("replaceData", base64replaceData);
    saveNotiMessage(jsonBody);
  }
  // add #9616 帳票印刷失敗通知がされない 高 2024/01/25　end

  //add #9616 帳票印刷失敗通知がされない 李 start

  private void saveNotiMessage(JSONObject jsonBody) {
    try {
      URI uri = new URI(webApi);
      RestTemplate rt = new RestTemplate();
      RequestEntity<String> request = RequestEntity
        .post(uri)
        .contentType(MediaType.APPLICATION_JSON)
        .header("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK")
        .body(jsonBody.toString());
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
      long start = System.currentTimeMillis();
      ResponseEntity<Object> response = rt.exchange(request, Object.class);
      long cost = System.currentTimeMillis() - start;
      Map<String, Object> map = new HashMap<>();
      map.put("logType", "RESTTEMPLATE-LOG");
      map.put("className", "jp.co.nikkiso.ntss.admin_web.service.statusList.DialysisConfirmServiceImpl");
      map.put("methodName", "saveNotiMessage");
      map.put("method", request.getMethod());
      map.put("url", uri.getPath());
      map.put("headers", request.getHeaders());
      map.put("requestParameter", request.getBody());
      map.put("status",response.getStatusCode());
      map.put("cost", cost);
      map.put("result",response.getBody());
      EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
      restTemplateEventLogMessage.setLogMessage(toJson(map));
      logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
    } catch (URISyntaxException ureE) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
    }
  }
  //add #9616 帳票印刷失敗通知がされない 李 end

  /**
   * 外部連携
   *
   * @param request
   * @param facilityCd
   */
  @Override
  public void callJournal(CheckAfterWeightRequest request, String facilityCd) {
    if (request.getJournal() == null) {
      return;
    }
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(facilityCd);

    for (CheckAfterWeightRequest.JournalParameter param : request.getJournal()) {
      JournalCreateRequestPayload payload = new JournalCreateRequestPayload();
      payload.setFacilityCd(facilityCd);
      payload.setOrdNo(request.getOrdNo());
      payload.setOpeCd(param.getOpeCd());
      payload.setCrud(param.getCrud());
      payload.setUserId(param.getUserId());
      payload.setBaseDate(param.getBaseDate());
      payload.setPatId(param.getPatId());
      payload.setHospPatId(param.getHospPatId());

      eventLogMessage.setLogMessage("asyncService.sendExternalConnection()呼び出し ord_no: " + payload.getOrdNo() + ", ope_cd: " + payload.getOpeCd() + ", all params: " + payload);
      logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);

      asyncService.sendExternalConnection(payload);
    }
  }

  // #10518 2024.05.23 mod 患者指定で「実績確定・削除時装置レポート画像更新」通知を行う TDC片口 start
//  /**
//   * オフライン終了日時更新
//   *
//   * @param request    リクエストパラメータ
//   * @param facilityCd 施設コード
//   * @return 通知応答
//   */
//  @Override
//  public DeviceEdgeOrderResponse sendEndDateUpdateInfo(CheckAfterWeightRequest request, String facilityCd) {
//
//    DeviceEdgeOrderRequest req = new DeviceEdgeOrderRequest();
//    req.setFacilityCd(facilityCd);
//    req.setOrdNo(request.getOrdNo());
//
//    ordMainDao.selectPatIdByOrdNo(request.getOrdNo());
//
//    DeviceEdgeOrderRequest targetInfo = deviceEdgeOrderService.findMissingData(req);
//
//    return deviceEdgeOrderService.orderEndDateUpdate(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(),
//      targetInfo.getMachineNo());
//  }

  /** {@inheritDoc} */
  @Override
  public DeviceEdgeOrderResponse sendOrderAllReportUpdateByPatId(Long patId, String facilityCd) {

    return deviceEdgeOrderService.orderAllReportUpdateByPatId(facilityCd, patId);
  }
  // #10518 2024.05.23 mod 患者指定で「実績確定・削除時装置レポート画像更新」通知を行う TDC片口 end
}
