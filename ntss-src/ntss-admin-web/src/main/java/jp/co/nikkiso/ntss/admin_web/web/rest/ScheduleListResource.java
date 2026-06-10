package jp.co.nikkiso.ntss.admin_web.web.rest;


import com.fasterxml.jackson.core.JsonProcessingException;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.request.patientCapture.JournalCreateRequestPayload;
import jp.co.nikkiso.ntss.admin_web.request.scheduleList.GetPatInfoForCheckListRequest;
import jp.co.nikkiso.ntss.admin_web.request.scheduleList.UpdateScheduleListDataRequest;
import jp.co.nikkiso.ntss.admin_web.request.scheduleList.UpdateScheduleListDataRequestList;
import jp.co.nikkiso.ntss.admin_web.request.scheduleList.UpdateScheduleListDataResponse;
import jp.co.nikkiso.ntss.admin_web.response.OtherScheduleListResponse;
import jp.co.nikkiso.ntss.admin_web.response.exam.ExamRequestResponse;
import jp.co.nikkiso.ntss.admin_web.response.rad.RadRequestResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.FacilitySettingService;
import jp.co.nikkiso.ntss.admin_web.service.IndHistoryMakeService;
import jp.co.nikkiso.ntss.admin_web.service.JournalService;
import jp.co.nikkiso.ntss.admin_web.service.OrdMainService;
import jp.co.nikkiso.ntss.admin_web.service.ScheduleListService;
import jp.co.nikkiso.ntss.admin_web.service.SelectHistoryUtils;
import jp.co.nikkiso.ntss.admin_web.service.exam.ExamRequestService;
import jp.co.nikkiso.ntss.admin_web.service.indHistory.IndHistory;
import jp.co.nikkiso.ntss.admin_web.service.indschedule.IndScheduleService;
import jp.co.nikkiso.ntss.admin_web.service.indschedule.IndScheduleServiceImpl;
import jp.co.nikkiso.ntss.admin_web.service.indschedule.dto.IndscheduleChangeUserSelectedInfo;
import jp.co.nikkiso.ntss.admin_web.service.journal.JournalCreatePayloadService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.nextpat.NextPatService;
import jp.co.nikkiso.ntss.admin_web.service.ordmain.check.OrdScheduleMoveCheck;
import jp.co.nikkiso.ntss.admin_web.service.rad.RadRequestService;
import jp.co.nikkiso.ntss.admin_web.service.sendConditionCancel.SendConditionCancelService;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallCommonUtil;
import jp.co.nikkiso.ntss.api.response.scheduleList.WeekPatternResponse;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dto.indSchedule.IndScheduleInfo;
import jp.co.nikkiso.ntss.core.entity.MstKur;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.OrdSchedule;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.logevent.EventLogOutputToMongoDBCommon;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.apache.commons.collections.CollectionUtils;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.Valid;
import java.net.URISyntaxException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * スケジュール表系
 */
//@Transactional
@RestController
@RequestMapping(Uri.SCHEDULE_LIST)
public class ScheduleListResource {

  @Autowired
  JdbcTemplate jdbcTemplate;

  //DB access
  @Autowired
  ScheduleListService scheduleListService;

  //条件送信キャンセル
  @Autowired
  SendConditionCancelService sendConditionCancelService;

  //WebAPIコール共通
  @Autowired
  WebApiCallCommonUtil webApiCallCommonUtil;

  @Autowired
  FacilitySettingService facilitySettingService;

  @Autowired
  ExamRequestService examRequestService;

  @Autowired
  RadRequestService radRequestService;

  @Autowired
  OrdMainResource ordMainResource;

  @Autowired
  LogService logService;

  @Autowired
  OrdMainService OrdMainService;

  @Autowired
  IndHistoryMakeService indHistoryMakeService;

  @Autowired
  private JournalService journalService;

  @Autowired
  private MntMachineStateDao mntMachineStateDao;

  // add #10601 スケジュール表動作不正 start
  @Autowired
  private IndScheduleService indScheduleService;

  @Autowired
  private SelectHistoryUtils selectHistoryUtils;

  @Autowired
  private JournalCreatePayloadService journalCreatePayloadService;

  /**
   * 次患者更新関連
   */
  @Autowired
  private NextPatService nextPatService;
  // add #10601 スケジュール表動作不正 end

  // add 10601 eventLog共通処理 gjn start
  @Autowired
  EventLogOutputToMongoDBCommon eventLogOutputToMongoDBCommon;
  // add 10601 eventLog共通処理 gjn end

  // mod #11716 曜日パターン変更の不正 関 start
  @Autowired
  OrdScheduleMoveCheck ordScheduleMoveCheck;
  // mod #11716 曜日パターン変更の不正 関 end
  @Transactional
  @GetMapping("/GetData")
  public String getSample(
    @RequestHeader(value = "sendValue", required = false) String sendValue,
    @RequestParam(name = "sendReqParam", required = false) String sendReqParam
  ) throws URISyntaxException {
    dbgPrint("TemplateResource:getSample:sendValue   :" + sendValue);
    dbgPrint("TemplateResource:getSample:sendReqParam:" + sendReqParam);
    return "OK";
  }

  @Transactional
  @PostMapping("/PostData")
  public String postSample(
    @RequestHeader(value = "sendValue", required = false) String sendValue,
    @Valid @RequestBody String bodydata
  ) {
    dbgPrint("TemplateResource:postSample:sendValue:" + sendValue);
    return "OK";
  }


  /**
   * スケジュールデータの更新処理
   *
   * @param request
   * @return
   * @throws URISyntaxException,RuntimeException
   */
  @Transactional
  @PutMapping("/updateScheduleListData")
  public ResponseEntity<List<String>> updateScheduleListData(
    @RequestBody UpdateScheduleListDataRequest request
  ) throws URISyntaxException, RuntimeException {
    /* add by yuqinlong  2023-02-02 [CodeOptimization] start  */
//    HttpStatus status = HttpStatus.OK;
//    List<String> listRet = new ArrayList<>();
//
//    //パラメータ
//    Long ordNo = request.getOrdNo();
//    String patId = request.getPatId();
//    String condTreatDate = request.getCondTreatDate();
//    String facilityCd = request.getFacilityCd();
//    String newTreatDate = request.getNewTreatDate();
//    Long kurCd = request.getKurCd();
//    Long bedCd = request.getBedCd();
//    Long indUserId = request.getIndUserId();
//    Long updUserId = request.getUpdUserId();
//
//    dbgPrint("ordNo:" + ordNo);
//    dbgPrint("condTreatDate:" + condTreatDate);
//    dbgPrint("facilityCd:" + facilityCd);
//    dbgPrint("newTreatDate:" + newTreatDate);
//    dbgPrint("kurCd:" + kurCd);
//    dbgPrint("bedCd:" + bedCd);
//
//    // 旧ord_mainデータ取得
//    OrdMain ordMain = OrdMainService.selectByOrdNo(ordNo);
//
//    //データを更新
//
//    int retCount = 0;
//
//    try {
//      retCount = scheduleListService.updateScheduleListData(
//        ordNo,
//        condTreatDate,
//        facilityCd,
//        newTreatDate,
//        kurCd,
//        bedCd
//      );
//    } catch (Exception e) {
//      //エラー
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
//      status = HttpStatus.INTERNAL_SERVER_ERROR;
//      throw new RuntimeException(e.getMessage());   //rollback
////      return new ResponseEntity<>(listRet, status);
//    }
//
//    dbgPrint("retCount:" + retCount);
//
//    if (retCount != 1) {
//      String retMsg = "ord_scheduleに更新対象のレコードが見つかりませんでした。ord_no:" + ordNo + " treat_date:" + condTreatDate + " facility_cd:" + facilityCd;
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(retMsg);
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
//      status = HttpStatus.INTERNAL_SERVER_ERROR;
//      throw new RuntimeException(retMsg);   //rollback
////      return new ResponseEntity<>(listRet, status);
//    }
//
//    try {
//      retCount = scheduleListService.updateOrdMainData(
//        ordNo,
//        condTreatDate,
//        facilityCd,
//        newTreatDate,
//        kurCd,
//        bedCd,
//        indUserId,
//        updUserId
//      );
//    } catch (Exception e) {
//      //エラー
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
//      status = HttpStatus.INTERNAL_SERVER_ERROR;
//
//      throw new RuntimeException(e.getMessage());   //rollback
////      return new ResponseEntity<>(listRet, status);
//    }
//
//    dbgPrint("retCount:" + retCount);
//
//    if (retCount != 1) {
//      String retMsg = "ord_mainに更新対象のレコードが見つかりませんでした。ord_no:" + ordNo + " treat_date:" + condTreatDate + " facility_cd:" + facilityCd;
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(retMsg);
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
//      status = HttpStatus.INTERNAL_SERVER_ERROR;
//      throw new RuntimeException(retMsg);   //rollback
////      return new ResponseEntity<>(listRet, status);
//    }
//
//    // 指示変更ありフラグの更新
//    try {
//      scheduleListService.changedIndData(ordNo, condTreatDate, newTreatDate);
//    } catch (Exception e) {
//      //エラー
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
//      status = HttpStatus.INTERNAL_SERVER_ERROR;
//      throw new RuntimeException(e.getMessage());   //rollback
//    }
//
//    // 検査依頼結果の移動及び削除処理
//    // FNSI-add 現行改善対応425 徐 start
////    String resExamChangeSetting = facilitySettingService.getFacilitySettingValue(
////      facilityCd,
////      FacilitySettingNo.EXAM_SCHEDULE_CHANGE
////    );
//    SimpleDateFormat ymd = new SimpleDateFormat("yyyyMMdd");
//    SimpleDateFormat hm = new SimpleDateFormat("HHmm");
//    String resExamChangeSetting = "";
//    // 施設設定マスタから 透析予定日変更時検査予定変更機能 の設定値を取得
//    resExamChangeSetting = facilitySettingService.getFacilitySettingValue(facilityCd, FacilitySettingNo.EXAM_SCHEDULE_CHANGE);
//    // 検査依頼変更締切り有無 1015
//    String examChangeOnOffWithOrder = facilitySettingService.getFacilitySettingValue(facilityCd, FacilitySettingNo.EXAM_CHANGE_ON_OFF_WITH_ORDER);
//    // 検査依頼変更締切り日数 1011
//    String examScheduleChangeLimitDay = facilitySettingService.getFacilitySettingValue(facilityCd, FacilitySettingNo.EXAM_SCHEDULE_CHANGE_LIMIT_DAY);
//    // 検査依頼変更締切り時間 1012
//    String examScheduleChangeLimitTime = facilitySettingService.getFacilitySettingValue(facilityCd, FacilitySettingNo.EXAM_SCHEDULE_CHANGE_LIMIT_TIME);
//    // 検査結果
//    boolean examStatus = false;
//    // 検査依頼日付加算
//    String newExamDateAdd = "";
//    // 時間
//    String newTime = "";
//    // 検査依頼強制選択型
//    boolean examForcedSelection = false;
//
//    Calendar rightNow = Calendar.getInstance();
//    rightNow.add(Calendar.DAY_OF_YEAR, Integer.valueOf(examScheduleChangeLimitDay));
//    Date dt = rightNow.getTime();
//    newExamDateAdd = ymd.format(dt);
//    newTime = hm.format(new Date());
//    List<PatExamMain> patListRet = examRequestService.FindPatExamMainByDateCd(Integer.valueOf(patId), condTreatDate, condTreatDate);
//    if (patListRet != null && patListRet.size() > 0) {
//      for (int i = 0; i < patListRet.size(); i++) {
//        PatExamMain items = patListRet.get(i);
//        if ("1".equals(items.getExamStatus())) {
//          examStatus = true;
//        }
//      }
//    }
//    if (!"4".equals(resExamChangeSetting)) {
//      if ("1".equals(examChangeOnOffWithOrder)) {
//        if (Integer.valueOf(condTreatDate) < Integer.valueOf(newExamDateAdd)) {
//          examForcedSelection = true;
//        } else if (Integer.valueOf(condTreatDate) == Integer.valueOf(newExamDateAdd)) {
//          if (Integer.valueOf(examScheduleChangeLimitTime.replace(":", "")) <= Integer.valueOf(newTime)) {
//            examForcedSelection = true;
//          } else {
//            if (examStatus) {
//              examForcedSelection = true;
//            }
//          }
//        } else {
//          if (examStatus) {
//            examForcedSelection = true;
//          }
//        }
//      } else {
//        if (examStatus) {
//          examForcedSelection = true;
//        }
//      }
//    } else {
//      examForcedSelection = true;
//    }
//    if (examForcedSelection) {
//      resExamChangeSetting = String.valueOf(request.getFacilitySetting1007SelectedVal());
//    }
//
//    String resRadChangeSetting = "";
//    // 施設設定マスタから 透析予定日変更時放射線検査予定変更機能 の設定値を取得
//    //    String resRadChangeSetting = facilitySettingService.getFacilitySettingValue(
////      facilityCd,
////      FacilitySettingNo.RAD_SCHEDULE_CHANGE
////    );
//    resRadChangeSetting = facilitySettingService.getFacilitySettingValue(facilityCd, FacilitySettingNo.RAD_SCHEDULE_CHANGE);
//    // 一般撮影検査依頼変更締切り有無 1016
//    String radChangeOnOffWithOrder = facilitySettingService.getFacilitySettingValue(facilityCd, FacilitySettingNo.RAD_CHANGE_ON_OFF_WITH_ORDER);
//    // 放射線検査依頼変更締切り日数 1013
//    String radScheduleChangeLimitDay = facilitySettingService.getFacilitySettingValue(facilityCd, FacilitySettingNo.RAD_SCHEDULE_CHANGE_LIMIT_DAY);
//    // 放射線検査依頼変更締切り時間 1014
//    String radScheduleChangeLimitTime = facilitySettingService.getFacilitySettingValue(facilityCd, FacilitySettingNo.RAD_SCHEDULE_CHANGE_LIMIT_TIME);
//    // 一般撮影日付加算
//    String newRadDateAdd = "";
//    // 一般撮影強制選択型
//    boolean radForcedSelection = false;
//    Calendar rightRadNow = Calendar.getInstance();
//    rightRadNow.add(Calendar.DAY_OF_YEAR, Integer.valueOf(radScheduleChangeLimitDay));
//    Date radDt = rightRadNow.getTime();
//    newRadDateAdd = ymd.format(radDt);
//
//    if (!"4".equals(resRadChangeSetting)) {
//      if ("1".equals(radChangeOnOffWithOrder)) {
//        if (Integer.valueOf(condTreatDate) < Integer.valueOf(newRadDateAdd)) {
//          radForcedSelection = true;
//        } else if (Integer.valueOf(condTreatDate) == Integer.valueOf(newRadDateAdd)) {
//          if (Integer.valueOf(radScheduleChangeLimitTime.replace(":", "")) <= Integer.valueOf(newTime)) {
//            radForcedSelection = true;
//          }
//        }
//      }
//    } else {
//      radForcedSelection = true;
//    }
//    if (radForcedSelection) {
//      resRadChangeSetting = String.valueOf(request.getFacilitySetting1008SelectedVal());
//    }
//
//    // FNSI-add 現行改善対応425 徐 end
//
//    // 変更前日付の整形 YYYYMMDD -> YYYY/MM/DD
//    String beforeDate = condTreatDate;
//    String bf_year = beforeDate.substring(0, 4);
//    String bf_month = beforeDate.substring(4, 6);
//    String bf_day = beforeDate.substring(6);
//    String beforeDateFormatted = bf_year + "/" + bf_month + "/" + bf_day;
//
//    // 変更後日付の整形 YYYYMMDD -> YYYY/MM/DD
//    String afterDate = newTreatDate;
//    String af_year = afterDate.substring(0, 4);
//    String af_month = afterDate.substring(4, 6);
//    String af_day = afterDate.substring(6);
//    String afterDateFormatted = af_year + "/" + af_month + "/" + af_day;
//
//    Map<String, String> paramsMoveInfo = new HashMap<String, String>();
//    paramsMoveInfo.put("patId", patId);
//    paramsMoveInfo.put("beforeDate", beforeDateFormatted);
//    paramsMoveInfo.put("afterDate", afterDateFormatted);
//
//    Map<String, String> paramsDeleteInfo = new HashMap<String, String>();
//    paramsDeleteInfo.put("patId", patId);
//    paramsDeleteInfo.put("date", beforeDateFormatted);
//    //add FNSI-8247 劉全航 start
//    paramsDeleteInfo.put("userId", updUserId.toString());
//    //add FNSI-8247 劉全航 end
//    List<Long> patIdList = new ArrayList<>();
//    patIdList.add(Long.parseLong(patId));
//    String startDate = "";
//    String endDate = "";
//    ExamRequestResponse examRequestResponse = examRequestService.createExamRequestResponse(patIdList, startDate, endDate, facilityCd);
//    RadRequestResponse radRequestResponse = radRequestService.createRadRequestResponse(patIdList, startDate, facilityCd);
//
//    // 検体検査が1件以上あった場合、日付を変更orキャンセルを行う
//    if (examRequestResponse.patExamMains.size() > 0) {
//      // 検体検査コードの取得
//      Long examMainCd = examRequestResponse.patExamMains.get(examRequestResponse.patExamMains.size() - 1).getExamMainCd();
//
//      // FNSI-mod 現行改善対応425 孫灝 20201117 start
//      // 施設設定により処理分岐(検体検査)
//      if (Integer.valueOf(condTreatDate) != Integer.valueOf(newTreatDate)) {
//        switchResExamChangeSetting(request, patId, facilityCd, updUserId, resExamChangeSetting, beforeDate, afterDate, paramsMoveInfo, paramsDeleteInfo, examRequestResponse, examMainCd);
//      }
//      // FNSI-mod 現行改善対応425 孫灝 20201117 end
//    }
//
//    // 放射線検査が1件以上あった場合、日付を変更orキャンセルを行う
//    if (radRequestResponse.patRadMains.size() > 0) {
//      // 放射線検査コードの取得
//      Long radResultCd = radRequestResponse.patRadMains.get(radRequestResponse.patRadMains.size() - 1).getRadResultCd();
//
//      // FNSI-mod 現行改善対応425 孫灝 20201203 start
//      // 施設設定により処理分岐(放射線検査)
//      if (Integer.valueOf(condTreatDate) != Integer.valueOf(newTreatDate)) {
//        switchResRadChangeSetting(request, patId, facilityCd, updUserId, resRadChangeSetting, beforeDate, afterDate, paramsMoveInfo, paramsDeleteInfo, radRequestResponse, radResultCd);
//      }
//      // FNSI-mod 現行改善対応425 孫灝 20201203 end
//    }
//
//    // add FNSI 1006 No.426 患者イベント変更機能 --Sanjingye SgetExistOrderun start
//
//    List<PatEvent> patEventList = scheduleListService.selectPatEventPeriod(facilityCd, patId, beforeDate);
//
//    if (patEventList.size() > 0) {
//
//      for (int pat = 0; pat < patEventList.size(); pat++) {
//        PatEvent pe = patEventList.get(pat);
//
//        int facilitySetting3005SelectedVal = request.getFacilitySetting3005SelectedVal();
//        switch (facilitySetting3005SelectedVal) {
//          // 変更された透析予定の日付に患者イベントのイベント開始日を変更
//          case 1:
//            try {
//              // Change pat event period
//              Calendar beforeC = Calendar.getInstance();
//              // Date before move.
//              beforeC.set(Integer.valueOf(bf_year), Integer.valueOf(bf_month) - 1, Integer.valueOf(bf_day));
//              Calendar afterC = Calendar.getInstance();
//              // Date after move
//              afterC.set(Integer.valueOf(af_year), Integer.valueOf(af_month) - 1, Integer.valueOf(af_day));
//
//              // Days of movement
//              int moveDays = afterC.get(Calendar.DAY_OF_YEAR) - beforeC.get(Calendar.DAY_OF_YEAR);
//
//              // New eventStartDate and eventEndDate
//              SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
//              pe.setEventStartDate(sdf.format(afterC.getTime()));
//
//              Date eventEndDate = sdf.parse(pe.getEventEndDate());
//              afterC.setTime(eventEndDate);
//              afterC.add(Calendar.DAY_OF_YEAR, moveDays);
//
//              pe.setEventEndDate(sdf.format(afterC.getTime()));
//
//              // update db pat_event
//              scheduleListService.updatePatEventPeriod(pe);
//
//            } catch (Exception e) {
//              //エラー
//              EventLogMessage eventLogMessage = new EventLogMessage();
//              eventLogMessage.setLogMessage(e.getMessage());
//              logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
//              throw new RuntimeException(e.getMessage());   //rollback
//            }
//            break;
//          // 中止
//          case 3:
//            try {
//              pe.setIsDel("1");
//              scheduleListService.updatePatEventIsDel(pe);
//            } catch (Exception e) {
//              //エラー
//              EventLogMessage eventLogMessage = new EventLogMessage();
//              eventLogMessage.setLogMessage(e.getMessage());
//              logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
//              throw new RuntimeException(e.getMessage());   //rollback
//            }
//            break;
//          default:
//            // 2.移動しない
//            break;
//        }
//      }
//    }
//
//    // add FNSI 1006 No.426 患者イベント変更機能 --Sanjingye Sun end
//
//    // 更新後開始時刻データ取得
//    String startTime = OrdMainService.getOrdIndTreatStartTime(ordNo);
//
//    // FNSI-add 対応401 孫灝 20201203 start
//    // sjy: Delete data from ord_checklist by ord_no where the value of rst_dialysis_state of ord_main is in 0,1,2
//    Integer beforBedCd = ordMain.getIndBedCd();
//    switch (ordMain.getRstDialysisState()) {
//      case "0":
//      case "1":
//      case "2":
//        // FIXME 1006 401 {sendConditionCancelService.doCancel} throws an exception 孫灝
////        sendConditionCancelService.doCancel(facilityCd, beforBedCd.longValue(), null, "2");
//        scheduleListService.deleteOrdCheckListByOrdNo(ordNo, facilityCd);
//        break;
//
//    }
//    // FNSI-add 対応401 孫灝 20201203 end
//
//    // 更新後治療情報スケジュール編集情報データの作成
//    ApiEntityOrdMain.ValiUpdateIndSchedule updBodyData = new ApiEntityOrdMain.ValiUpdateIndSchedule();
//    // ログ出力時現行仕様表示部
//    updBodyData.setFacility_cd(facilityCd);
//    updBodyData.setPat_id(ordMain.getPatId().toString());
//    updBodyData.setInd_start_date(ordMain.getTreatDate());
//    updBodyData.setInd_end_date(ordMain.getTreatDate());
//    updBodyData.setWeek_pattern(ordMain.getTreatWeek().toString());
//    updBodyData.setInd_kur_cd(ordMain.getIndKurCd().toString());
//    updBodyData.setInd_treatment_cd(ordMain.getIndTreatmentCd().toString());
//
//    // 更新後データ(更新後開始日は未定)
//    updBodyData.setEdit_ind_kur_cd(kurCd.toString());
//    updBodyData.setEdit_ind_treat_date(newTreatDate);
//    updBodyData.setEdit_ind_bed_cd(bedCd.toString());
//    updBodyData.setInd_user_id(indUserId.toString());
//    updBodyData.setUpd_user_id(updUserId.toString());
//    updBodyData.setIs_deadline("");
//
//    //該当する曜日を取得
//    Integer weekNum = ordMain.getTreatWeek().intValue();
//    List<Integer> weeksArray = Arrays.asList(weekNum);
//    List<OrdMain> ordMainList = Arrays.asList(ordMain);
//
//    //値がnullの場合はnullセット
//    if (Objects.isNull(startTime)) {
//      updBodyData.setEdit_ind_treat_start_time(null);
//    }
//    //文字列→時刻表記に変換して取得(nullの場合は"未登録"に変換)
//    else {
//      // 治療開始時刻 HHmm形式⇒HH:mm形式
//      SimpleDateFormat treatTimeFormat = new SimpleDateFormat("HHmm");
//      Date treatTimeDate = null;
//      try {
//        treatTimeDate = treatTimeFormat.parse(startTime);
//      } catch (ParseException e) {
//        e.printStackTrace();
//      }
//      updBodyData.setEdit_ind_treat_start_time(new SimpleDateFormat("HH:mm").format(treatTimeDate));
//    }
//
//    // 設定パラメータを作成
//    String paramTarget = "クール,治療開始時刻,ベッド,治療日";
//
//    // 指示履歴作成機能呼び出し
//    indHistoryMakeService.createScheduleHistory(updBodyData, "2", weeksArray, ordMainList, paramTarget);
//
//    return new ResponseEntity<>(listRet, status);

    return scheduleListService.updateScheduleListData(request);

    /* add by yuqinlong  2023-02-02 [CodeOptimization] end  */
  }



  // add #10601 スケジュール表動作不正 start
  /**
   * スケジュールデータの更新処理
   * @param request
   * @return
   * @throws URISyntaxException,RuntimeException
   */
  @PutMapping("/updateScheduleListData2")
  public ResponseEntity<UpdateScheduleListDataResponse> updateScheduleListData2(@RequestBody UpdateScheduleListDataRequestList request) throws URISyntaxException, RuntimeException {
    HttpStatus status = HttpStatus.OK;
    UpdateScheduleListDataResponse response = null;

    //パラメータ
    String facilityCd = request.getFacilityCd();
    Long indUserId = request.getIndUserId();
    Long updUserId = request.getUpdUserId();
    List<IndScheduleInfo> beforeIndScheduleInfoList = request.getBeforeIndScheduleInfoList();
    List<IndScheduleInfo> afterIndScheduleInfoList = request.getAfterIndScheduleInfoList();
    IndscheduleChangeUserSelectedInfo indscheduleChangeUserSelectedInfo = request.getIndscheduleChangeUserSelectedInfo();

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("facility_cd: " + facilityCd
      + " beforeIndScheduleInfoList: " + beforeIndScheduleInfoList.toString()
      + " afterIndScheduleInfoList: " + afterIndScheduleInfoList.toString()
      + " indscheduleChangeUserSelectedInfo: " + indscheduleChangeUserSelectedInfo.toString()
      + " ind_user_id: " + indUserId
      + " upd_user_id: " + updUserId
    );

    // mod #11716 曜日パターン変更の不正 関 start
    // check
    UpdateScheduleListDataResponse checkResponse = null;
    try {
      checkResponse = ordScheduleMoveCheck.checkOrdScheduleMove(beforeIndScheduleInfoList, afterIndScheduleInfoList, facilityCd,
        indscheduleChangeUserSelectedInfo, indUserId, updUserId);
    } catch (Exception e) {
      //エラー
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
      status = HttpStatus.INTERNAL_SERVER_ERROR;
      return new ResponseEntity<>(checkResponse, status);
    }

    if (checkResponse.getPROC_RESULT() != IndScheduleServiceImpl.PROC_RESULT.SUCCESS.toString()) {
      return new ResponseEntity<>(checkResponse, status);
    }

    // main DB 処理
    try {
      response = indScheduleService.updateIndSchedule2(facilityCd, beforeIndScheduleInfoList, afterIndScheduleInfoList,
        indscheduleChangeUserSelectedInfo, new WeekPatternResponse(), checkResponse, new ArrayList<>(), indUserId, updUserId);
    } catch (Exception e) {
      //エラー
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
      status = HttpStatus.INTERNAL_SERVER_ERROR;
      return new ResponseEntity<>(response, status);
    }
    // mod #11716 曜日パターン変更の不正 関 end

    if ("SUCCESS".equals(response.getPROC_RESULT())) {

      List<OrdMain> doCallNextPatOrdMainList = response.getDoCallNextPatOrdMainList();
      Map<String, List<Object>> resultAllChangedDataInfoList = response.getResultAllChangedDataInfoList();

      //指示履歴登録処理 MongoDB
      try {
        List<OrdMain> updatedOrdMainList = new ArrayList<>();
        if (resultAllChangedDataInfoList.containsKey("ord_main") && !resultAllChangedDataInfoList.get("ord_main").isEmpty()) {
          List<Object> ordMainObjects = resultAllChangedDataInfoList.get("ord_main");
          for (Object obj : ordMainObjects) {
            OrdMain ordMain = (OrdMain) obj;
            updatedOrdMainList.add(ordMain);
          }
        }

        List<IndHistory> indHistoryList = indScheduleService.createIndHistoryForIndSchedule(facilityCd, doCallNextPatOrdMainList, updatedOrdMainList);
        if (indHistoryList != null && !indHistoryList.isEmpty()) {
          indHistoryMakeService.createHistoryExecuteBatch(indHistoryList, "2");
        }
      } catch (Exception e) {
        //エラー
        eventLogMessage.setLogMessage("指示履歴登録処理 MongoDB " + e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
      }

      //ord_main変更履歴登録 MongoDB
      try {
        selectHistoryUtils.insertMangoDbHistoryBatchByOrdMainList(doCallNextPatOrdMainList);
      } catch (Exception e) {
        //エラー
        eventLogMessage.setLogMessage("ord_main変更履歴登録 MongoDB " + e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
      }

      // add 10601 eventLog共通処理 gjn start
      //write EventLog
      try {
        eventLogOutputToMongoDBCommon.makeEvebtLogToMongoByDataDiff(response.getResultAllChangeBeforeDataInfoList(), response.getResultAllChangedDataInfoList());
      } catch (Exception e) {
        //エラー
        eventLogMessage.setLogMessage("eventLog共通処理 " + e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
      }
      // add 10601 eventLog共通処理 gjn end

      // サービスの新しい次患者更新呼出統合処理を呼び出す
      try {
        nextPatService.CallNextPatChange(facilityCd, response.getDoCallNextPatOrdMainList());
      } catch (Exception e) {
        //エラー
        eventLogMessage.setLogMessage("サービスの新しい次患者更新呼出統合処理を呼び出す " + e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
      }

      // 連携関連呼出
      try {
        String actionMode = "SCHEDULE_LIST";
        List<Long> patIdList = new ArrayList<>();
        patIdList.addAll(beforeIndScheduleInfoList.stream().map(o -> o.getPatId()).collect(Collectors.toList()));
        patIdList.addAll(afterIndScheduleInfoList.stream().map(o -> o.getPatId()).filter(Objects::nonNull).collect(Collectors.toList()));
        List<JournalCreateRequestPayload> journalList = journalCreatePayloadService.createJournalPayload(facilityCd, response.getResultAllChangedDataInfoList(), response.getResultAllChangeBeforeDataInfoList(), patIdList, updUserId, actionMode);
        if (!CollectionUtils.isEmpty(journalList)) {
          journalService.callCreateJournalForCtrNo(journalList);
        }
      } catch (Exception e) {
        //エラー
        eventLogMessage.setLogMessage("連携関連呼出 " + e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
      }
    }
    else if("PARAM_ERR".equals(response.getPROC_RESULT())){
      status = HttpStatus.BAD_REQUEST;
    }

    return new ResponseEntity<>(response, status);
  }
  // add #10601 スケジュール表動作不正 end

  // FNSI-mod 現行改善対応425 孫灝 20201203 start
  private void switchResRadChangeSetting(@RequestBody UpdateScheduleListDataRequest request, String patId, String facilityCd, Long updUserId, String resRadChangeSetting, String beforeDate, String afterDate, Map<String, String> paramsMoveInfo, Map<String, String> paramsDeleteInfo, RadRequestResponse radRequestResponse, Long radResultCd) {
    switch (resRadChangeSetting) {
      case "1":
        // 変更された透析予定の日付に放射線検査の日付を変更
        switchResRadChangeSettingCase1(patId, facilityCd, updUserId, beforeDate, afterDate, paramsMoveInfo, radRequestResponse, radResultCd);
        break;
      case "2":
        // 透析予定日が変更/中止された場合、放射線検査をキャンセル
        switchResRadChangeSettingCase2(patId, facilityCd, updUserId, beforeDate, afterDate, paramsDeleteInfo, radRequestResponse, radResultCd);
        break;
      case "3":
        // 放射線検査への処理は行わない
        break;
      default:
        break;
    }
  }
  // FNSI-mod 現行改善対応425 孫灝 20201203 end

  // FNSI-mod 現行改善対応425 孫灝 20201203 start
  private void switchResRadChangeSettingCase2(String patId, String facilityCd, Long updUserId, String beforeDate, String afterDate, Map<String, String> paramsDeleteInfo, RadRequestResponse radRequestResponse, Long radResultCd) {
    try {
      radRequestService.updateIsDel(paramsDeleteInfo);
      journalService.callCreateJournal(
        radRequestResponse.radDateList,
        beforeDate,
        afterDate,
        facilityCd,
        radResultCd,
        updUserId,
        Long.parseLong(patId),
        // mod FNSI 1006 No.538 外部連携 start -- Sanjingye Sun 20210104
        "022010",
        "D"
        // mod FNSI 1006 No.538 外部連携 end -- Sanjingye Sun 20210104
      );
    } catch (Exception e) {
      //エラー
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
      throw new RuntimeException(e.getMessage());   //rollback
    }
  }
  // FNSI-mod 現行改善対応425 孫灝 20201203 end

  // FNSI-mod 現行改善対応425 孫灝 20201203 start
  private void switchResRadChangeSettingCase1(String patId, String facilityCd, Long updUserId, String beforeDate, String afterDate, Map<String, String> paramsMoveInfo, RadRequestResponse radRequestResponse, Long radResultCd) {
    try {
      //mod FNSI-8247 劉全航 start
//      radRequestService.updateRegRadDate(paramsMoveInfo);
//      journalService.callCreateJournal(
//        radRequestResponse.radDateList,
//        beforeDate,
//        afterDate,
//        facilityCd,
//        radResultCd,
//        updUserId,
//        Long.parseLong(patId),
//        // mod FNSI 1006 No.538 外部連携 start -- Sanjingye Sun 20210104
//        "022009",
//        "U"
//        // mod FNSI 1006 No.538 外部連携 end -- Sanjingye Sun 20210104
//      );
      int i = radRequestService.updateRegRadDate(paramsMoveInfo);
      if(i == 1){
        journalService.callCreateJournal(
          radRequestResponse.radDateList,
          beforeDate,
          afterDate,
          facilityCd,
          radResultCd,
          updUserId,
          Long.parseLong(patId),
          // mod FNSI 1006 No.538 外部連携 start -- Sanjingye Sun 20210104
          "022009",
          "U"
          // mod FNSI 1006 No.538 外部連携 end -- Sanjingye Sun 20210104
        );
      }
      //mod FNSI-8247 劉全航 end
    } catch (Exception e) {
      //エラー
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
      throw new RuntimeException(e.getMessage());   //rollback
    }
  }
  // FNSI-mod 現行改善対応425 孫灝 20201203 end

  // FNSI-mod 現行改善対応425 孫灝 20201117 start
  private void switchResExamChangeSetting(@RequestBody UpdateScheduleListDataRequest request, String patId, String facilityCd, Long updUserId, String resExamChangeSetting, String beforeDate, String afterDate, Map<String, String> paramsMoveInfo, Map<String, String> paramsDeleteInfo, ExamRequestResponse examRequestResponse, Long examMainCd) {
    switch (resExamChangeSetting) {
      case "1":
        // 変更された透析予定の日付に検体検査の日付を変更
        switchResExamChangeSettingCase1(patId, facilityCd, updUserId, beforeDate, afterDate, paramsMoveInfo, examRequestResponse, examMainCd);
        break;
      case "2":
        // 透析予定日が変更/中止された場合、検体検査をキャンセル
        switchResExamChangeSettingCase2(patId, facilityCd, updUserId, beforeDate, afterDate, paramsDeleteInfo, examRequestResponse, examMainCd);
        break;
      case "3":
        // 検体検査への処理は行わない
        break;
      default:
        break;
    }
  }
  // FNSI-mod 現行改善対応425 孫灝 20201117 end

  private void switchResExamChangeSettingCase2(String patId, String facilityCd, Long updUserId, String beforeDate, String afterDate, Map<String, String> paramsDeleteInfo, ExamRequestResponse examRequestResponse, Long examMainCd) {
    try {
      examRequestService.updateIsDel(paramsDeleteInfo);
      journalService.callCreateJournal(
        examRequestResponse.examDateList,
        beforeDate,
        afterDate,
        facilityCd,
        examMainCd,
        updUserId,
        Long.parseLong(patId),
        // mod FNSI 1006 No.538 外部連携 start -- Sanjingye Sun 20210104
        "021010",
        "D"
        // mod FNSI 1006 No.538 外部連携 end -- Sanjingye Sun 20210104
      );
    } catch (Exception e) {
      //エラー
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
      throw new RuntimeException(e.getMessage());   //rollback
    }
  }

  private void switchResExamChangeSettingCase1(String patId, String facilityCd, Long updUserId, String beforeDate, String afterDate, Map<String, String> paramsMoveInfo, ExamRequestResponse examRequestResponse, Long examMainCd) {
    try {
      //mod FNSI-8247 劉全航 start
//      examRequestService.updateRegExamDate(paramsMoveInfo);
//      journalService.callCreateJournal(
//        examRequestResponse.examDateList,
//        beforeDate,
//        afterDate,
//        facilityCd,
//        examMainCd,
//        updUserId,
//        Long.parseLong(patId),
//        // mod FNSI 1006 No.538 外部連携 start -- Sanjingye Sun 20210104
//        "021009",
//        "U"
//        // mod FNSI 1006 No.538 外部連携 end -- Sanjingye Sun 20210104
//      );
      int i = examRequestService.updateRegExamDate(paramsMoveInfo);
      if(i == 1){
        journalService.callCreateJournal(
          examRequestResponse.examDateList,
          beforeDate,
          afterDate,
          facilityCd,
          examMainCd,
          updUserId,
          Long.parseLong(patId),
          // mod FNSI 1006 No.538 外部連携 start -- Sanjingye Sun 20210104
          "021009",
          "U"
          // mod FNSI 1006 No.538 外部連携 end -- Sanjingye Sun 20210104
        );
      }
      //mod FNSI-8247 劉全航 end
    } catch (Exception e) {
      //エラー
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
      throw new RuntimeException(e.getMessage());   //rollback
    }
  }

  /**
   * 同一患者同一治療日同一クール同一治療方法のチェック
   *
   * @return Boolean true:存在した false:存在しなかった
   * @throws Exception
   */
  @Transactional
  @GetMapping("/checkSamePatDayKurMode")
  public ResponseEntity<Boolean> checkSamePatDayKurMode(
    @RequestParam(name = "ordNoList", required = true) String ordNoListStr,
    @RequestParam(name = "treatDateList", required = true) String treatDateListStr,
    @RequestParam(name = "kurCdList", required = true) String kurCdListStr
  ) throws URISyntaxException, RuntimeException {
    HttpStatus status = HttpStatus.OK;
    String[] baseListOrdNo = ordNoListStr.split("-");
    String[] baseListTreatDate = treatDateListStr.split("-");
    String[] baseListKurCd = kurCdListStr.split("-");
    Boolean ret = false;
    for (int i = 0; i < baseListOrdNo.length; i++) {
      ret = scheduleListService.checkSamePatDayKurMode(
        Long.parseLong(baseListOrdNo[i]),
        baseListTreatDate[i],
        Long.parseLong(baseListKurCd[i])
      );
      if (ret) {
        break;
      }
    }
    return new ResponseEntity<>(ret, status);
  }

  //mod FNSI-7122 劉全航 start
  @Transactional
  @GetMapping("/checkSamePatAndNoKur")
  public ResponseEntity<Boolean> checkSamePatAndNoKur(
    @RequestParam(name = "ordNo", required = true) String ordNo,
    @RequestParam(name = "treatDate", required = true) String treatDate){
    Boolean result = false;
    HttpStatus status = HttpStatus.OK;
    try{
      long no = Long.parseLong(ordNo);
      OrdMain ordMain = OrdMainService.selectByOrdNo(no);
      Long patId = ordMain.getPatId();
      Integer indTreatmentCd = ordMain.getIndTreatmentCd();
      List<OrdMain> ordMainList = OrdMainService.selectByPatId(patId);
      long count = ordMainList.stream().filter((o) -> o.getTreatDate().equals(treatDate) && o.getIndTreatmentCd().equals(indTreatmentCd) && o.getIndKurCd() == 0).count();
      result = count > 0;
    }catch (Exception e){
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
      return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
    }
    return new ResponseEntity<>(result, status);
  }
  //mod FNSI-7122 劉全航 end

  /**
   * 同一患者同一治療日同一クール同一治療方法のチェック
   *
   * @return Boolean true:存在した false:存在しなかった
   * @throws Exception
   */
  @Transactional
  @GetMapping("/checkPatExistance")
  // mod #11493 スケジュール表　更新不正 関 start
  public ResponseEntity<Boolean> checkPatExistance(
    @RequestParam(name = "ordNo", required = true) Long ordNo,
    @RequestParam(name = "treatDate", required = true) String treatDate,
    @RequestParam(name = "kurCd", required = true) Long kurCd,
    @RequestParam(name = "bedCd", required = true) Long bedCd,
    @RequestParam(name = "dialysisState", required = true) String dialysisState,
    @RequestParam(name = "isDummy", required = true) String isDummy

  ) throws URISyntaxException, RuntimeException {
    HttpStatus status = HttpStatus.OK;
    Boolean ret = false;
    ret = scheduleListService.checkPatExistance(
      ordNo,
      treatDate,
      kurCd,
      bedCd,
      dialysisState,
      isDummy
    );
    return new ResponseEntity<>(ret, status);
  }
  // mod #11493 スケジュール表　更新不正 関 end

  /**
   * ダミースケジュール操作APIの呼び出し
   *
   * @param ordNo   オーダー番号
   * @param opeMode モード "1":登録 "2":削除 "3":再作成(削除+作成)
   * @return
   */

  @Transactional
  @GetMapping("/operateDummySchedule")
  public ResponseEntity<String> operateDummySchedule(
    @RequestParam(name = "ordNo", required = true) Long ordNo,
    @RequestParam(name = "opeMode", required = true) String opeMode
  ) throws URISyntaxException, RuntimeException {
    List<Long> ordNoList = new ArrayList<Long>();
    ordNoList.add(ordNo);
    ResponseEntity<String> ret = webApiCallCommonUtil.operateDummySchedule(ordNoList, null, null, opeMode);

    return ret;
  }

  /**
   * ダミースケジュール操作APIの呼び出し
   *
   * @return
   */
  @Transactional
  @GetMapping("/operateAllDummySchedule")
  public ResponseEntity<String> operateAllDummySchedule(
    @RequestParam(name = "facilityCd", required = true) String facilityCd
  ) throws URISyntaxException, RuntimeException {
    /*mod #8495 by zhangruixue 2023-03-27  GC overhead limit exceeded start*/
//    List<Long> ordList = OrdMainService.selectByFacilityCd(facilityCd);
//    List<Long> ordNoList = new ArrayList<Long>();
//    for (OrdMain ordMain : ordList) {
//      ordNoList.add(ordMain.getOrdNo());
//    }
    List<Long> ordNoList = OrdMainService.selectByFacilityCd(facilityCd);
    /*mod #8495 by zhangruixue 2023-03-27  GC overhead limit exceeded end*/
    ResponseEntity<String> ret = webApiCallCommonUtil.operateDummySchedule(ordNoList, null, null, "3");

    return ret;
  }

  /**
   * 空きベッド検索APIの呼び出し
   *
   * @param facilityCd       施設コード
   * @param ordNo            オーダー番号
   * @param patId            患者ID
   * @param bedCd            ベッドコード
   * @param searchStartDate  治療日付(検索開始)
   * @param searchStartKurCd クールコード(検索開始)
   * @param isMoveTreatDate  治療日移動フラグ(true:移動あり、false:移動なし) ※nullの場合はデフォルト:falseを使用
   * @return ord_scheduleのリスト
   */

  @Transactional
  @GetMapping("/selectForSearchReservedBed")
  public ResponseEntity<List<OrdSchedule>> selectForSearchReservedBed(
    @RequestParam(name = "facilityCd", required = true) String facilityCd,
    @RequestParam(name = "ordNo", required = true) Long ordNo,
    @RequestParam(name = "patId", required = true) Long patId,
    @RequestParam(name = "bedCd", required = true) Long bedCd,
    @RequestParam(name = "searchStartDate", required = true) String searchStartDate,
    @RequestParam(name = "searchStartKurCd", required = true) Long searchStartKurCd,
    @RequestParam(name = "isMoveTreatDate", required = true) Boolean isMoveTreatDate
  ) throws URISyntaxException, RuntimeException {

    List<Long> ordNoList = Arrays.asList(ordNo);

    //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("facilityCd:" + facilityCd
      + " ordNoList:" + ordNoList
      + " patId:" + patId
      + " bedCd:" + bedCd
      + " searchStartDate:" + searchStartDate
      + " searchStartKurCd:" + searchStartKurCd
    );
    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
    //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end


    ResponseEntity<List<OrdSchedule>> ret = webApiCallCommonUtil.selectForSearchReservedBed(
      facilityCd,
      ordNoList,
      patId,
      bedCd,
      searchStartDate,
      searchStartKurCd,
      isMoveTreatDate
    );

    //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
    eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("ret:" + ret.toString());
    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
    //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end
    return ret;
  }

  //add #10601 スケジュール表動作不正 start
  @PostMapping("/selectForSearchReservedBed2")
  public ResponseEntity<List<OrdSchedule>> selectForSearchReservedBed2(@RequestBody UpdateScheduleListDataRequestList request) {


    ResponseEntity<List<OrdSchedule>> ret = scheduleListService.selectForSearchReservedBed2(request);

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("ret:" + ret.toString());
    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
    return ret;
  }
  //add #10601 スケジュール表動作不正 end

  /**
   * クールデータの取得処理
   *
   * @param facilityCd
   * @return
   * @throws URISyntaxException
   */
  @Transactional
  @GetMapping("/getKurData")
  public ResponseEntity<List<MstKur>> getKurDataFromDB(
    @RequestParam(name = "facilityCd", required = true) String facilityCd
  ) throws URISyntaxException {
    HttpStatus status = HttpStatus.OK;

    //DBからデータ取得

    List<MstKur> retList =
      scheduleListService.getKurNameList(facilityCd);

    return new ResponseEntity<>(retList, status);
  }

  /**
   * ベッド情報の取得 処理
   *
   * @param facilityCd
   * @return
   * @throws URISyntaxException
   */
  @Transactional
  @GetMapping("/getBedMaxCount")
  public ResponseEntity<List<Map<String, Object>>> getBedMaxCountFromDB(
    @RequestParam(name = "facilityCd", required = true) String facilityCd
  ) throws URISyntaxException {
    HttpStatus status = HttpStatus.OK;

    List<Map<String, Object>> retList = null;

    //DBからデータ取得

    retList =
      scheduleListService.getBedMaxCount(facilityCd);

    return new ResponseEntity<>(retList, status);
  }

  /**
   * 患者情報取得用(チェック用情報)
   *
   * @param ordNo
   * @return
   * @throws URISyntaxException
   */
  @Transactional
  @GetMapping("/getPatInfoForCheck")
  public ResponseEntity<Map<String, Object>> getPatInfoForCheckFromDB(
    @RequestParam(name = "ordNo", required = true) Long ordNo
  ) throws URISyntaxException {
    HttpStatus status = HttpStatus.OK;
    Map<String, Object> retMap = new HashMap<String, Object>();

    //患者情報の取得
    List<Map<String, Object>> retPatInfoList =
      scheduleListService.selectPatInfoForCheck(ordNo);

    retMap.put("patInfo", retPatInfoList);

    return new ResponseEntity<>(retMap, status);
  }

//  add by ShiHongda 2023-02-08 [optimize] --start /
  /**
   * 患者情報取得用(チェック用情報)
   *
   * @param req
   * @return
   * @throws URISyntaxException
   */
  //mod #12661 securify SQLインジェクション(High) まとめ zrx start
  @PostMapping("/getPatInfoForCheckList")
  public ResponseEntity<Map<String, Object>> getPatInfoForCheckListFromDB(
    @Valid @RequestBody GetPatInfoForCheckListRequest req
  ) throws URISyntaxException {
    HttpStatus status = HttpStatus.OK;
    Map<String, Object> retMap = new HashMap<String, Object>();

    List<Long> ordNoList = req.getOrdNoList()
      .stream()
      .map(Long::valueOf)
      .collect(Collectors.toList());

    //mod #12661 securify SQLインジェクション(High) まとめ zrx end

    //患者情報の取得
    List<Map<String, Object>> retPatInfoList =
      scheduleListService.selectPatInfoForListCheck(ordNoList);

    retMap.put("patInfoList", retPatInfoList);

    return new ResponseEntity<>(retMap, status);
  }
//  add by ShiHongda 2023-02-08 [optimize] --end /

  //add クールマスタ 王 start
  @GetMapping("/getAllDummyInfo")
  public ResponseEntity<Map<String, Object>> getPatInfoForCheckFromDB2(
    @RequestParam(name = "facilityCd", required = true) String facilityCd
  ) throws URISyntaxException {
    HttpStatus status = HttpStatus.OK;
    Map<String, Object> retMap = new HashMap<String, Object>();
    /*mod #8494 by zhangruixue 2023-03-27  GC overhead limit exceeded start*/
//    List<OrdMain> listRet = OrdMainService.selectByFacilityCd(facilityCd);
    List<Long> listRet = OrdMainService.selectByFacilityCd(facilityCd);

    for (int i = 0; i < listRet.size(); i++) {

//      Long id = listRet.get(i).getOrdNo();
      Long id = listRet.get(i);
      /*mod #8494 by zhangruixue 2023-03-27  GC overhead limit exceeded end*/
      //患者情報の取得
      List<Map<String, Object>> retPatInfoList =
        scheduleListService.selectPatInfoForCheck(id);

      retMap.put(id.toString(), retPatInfoList);
    }

    return new ResponseEntity<>(retMap, status);
  }
  //add クールマスタ 王 end


  /**
   * ベッド情報とクール情報の取得 処理
   *
   * @param facilityCd
   * @return
   * @throws URISyntaxException
   */
  @Transactional
  @GetMapping("/getBedAndKurInfo")
  public ResponseEntity<Map<String, Object>> getBedAndKurInfoFromDB(
    @RequestParam(name = "facilityCd", required = true) String facilityCd
  ) throws URISyntaxException {
    HttpStatus status = HttpStatus.OK;
    Map<String, Object> retMap = new HashMap<String, Object>();

    /* modify by yuqinlong  2023-02-02 [CodeOptimization] start  */
//    //ベッド情報の取得
//    List<Map<String, Object>> retBedList =
//      scheduleListService.getBedMaxCount(facilityCd);
//
//    //クール情報の取得
//    List<MstKur> retKurList =
//      scheduleListService.getKurNameList(facilityCd);
//
//    //ベッドグループ情報の取得
//    List<MstRoomBedGroup> retRoomBedGroupList =
//      scheduleListService.getRoomBedGroupList(facilityCd);
//
//    // FNSI-add 現行改善対応425 孫灝 20201117 start
//    // 施設設定マスタから 透析予定日変更時検査予定変更機能 の設定値を取得 1007
//    String resExamChangeSetting = facilitySettingService.getFacilitySettingValue(facilityCd, FacilitySettingNo.EXAM_SCHEDULE_CHANGE);
//
//    // 検査依頼変更締切り有無 1015
//    String examChangeOnOffWithOrder = facilitySettingService.getFacilitySettingValue(facilityCd, FacilitySettingNo.EXAM_CHANGE_ON_OFF_WITH_ORDER);
//
//    // 検査依頼変更締切り日数 1011
//    String examScheduleChangeLimitDay = facilitySettingService.getFacilitySettingValue(facilityCd, FacilitySettingNo.EXAM_SCHEDULE_CHANGE_LIMIT_DAY);
//
//    // 検査依頼変更締切り時間 1012
//    String examScheduleChangeLimitTime = facilitySettingService.getFacilitySettingValue(facilityCd, FacilitySettingNo.EXAM_SCHEDULE_CHANGE_LIMIT_TIME);
//
//    // 1007
//    retMap.put("setting1007", resExamChangeSetting);
//    // 1015
//    retMap.put("examChangeOnOffWithOrder", examChangeOnOffWithOrder);
//    // 1011
//    retMap.put("examScheduleChangeLimitDay", examScheduleChangeLimitDay);
//    // 1012
//    retMap.put("examScheduleChangeLimitTime", examScheduleChangeLimitTime);
//
//    // 1008
//    String radChangeSetting = facilitySettingService.getFacilitySettingValue(facilityCd, FacilitySettingNo.RAD_SCHEDULE_CHANGE);
//    // 一般撮影検査依頼変更締切り有無 1016
//    String radChangeOnOffWithOrder = facilitySettingService.getFacilitySettingValue(facilityCd, FacilitySettingNo.RAD_CHANGE_ON_OFF_WITH_ORDER);
//    // 放射線検査依頼変更締切り日数 1013
//    String radScheduleChangeLimitDay = facilitySettingService.getFacilitySettingValue(facilityCd, FacilitySettingNo.RAD_SCHEDULE_CHANGE_LIMIT_DAY);
//    // 放射線検査依頼変更締切り時間 1014
//    String radScheduleChangeLimitTime = facilitySettingService.getFacilitySettingValue(facilityCd, FacilitySettingNo.RAD_SCHEDULE_CHANGE_LIMIT_TIME);
//
//    retMap.put("setting1008", radChangeSetting);
//    // 1016
//    retMap.put("radChangeOnOffWithOrder", radChangeOnOffWithOrder);
//    // 1013
//    retMap.put("radScheduleChangeLimitDay", radScheduleChangeLimitDay);
//    // 1014
//    retMap.put("radScheduleChangeLimitTime", radScheduleChangeLimitTime);
//    // FNSI-add 現行改善対応425 孫灝 20201117 end
//
//    // add FNSI 1006 No.426 施設設定に患者イベントの治療スケジュール連動設定code取得 start --- 孙灏 20201215
//    String patEventChangeSetting = facilitySettingService.getFacilitySettingValue(
//      facilityCd,
//      FacilitySettingNo.PAT_EVENT_CHANGE
//    );
//    retMap.put("setting3005", patEventChangeSetting);
//    // add FNSI 1006 No.426 施設設定に患者イベントの治療スケジュール連動設定code取得 end --- 孙灏 20201215
//
//    //戻り値の組み立て
//    retMap.put("bed", retBedList);
//    retMap.put("kur", retKurList);
//    retMap.put("roombedgroup", retRoomBedGroupList);

    retMap = scheduleListService.getBedAndKurInfoFromDB(facilityCd);
    /* modify by yuqinlong  2023-02-02 [CodeOptimization] end  */

    return new ResponseEntity<>(retMap, status);
  }

  /**
   * 名前と入外区分(と院内表示用の患者ID)を補完する処理
   *
   * @param targetJson  補完する対象(JsonObject)
   * @param patInfoList 患者情報リスト
   * @return
   */
//  @Transactional
  private boolean addNameAndInout(
    JSONObject targetJson,
    List<PatPersonalMain> patInfoList
  ) {
    boolean ret = true;
    PatPersonalMain tmpPPM = null;
//    JSONObject tmpJObj = (JSONObject)jArry.get(i) ;

    //初期設定
    targetJson.put("patLastName", "");    //名前(姓)
    targetJson.put("patFirstName", "");   //名前(名)
    targetJson.put("inOutClass", "");     //入外区分
    targetJson.put("hospPatId", "");     //院内表示用の患者ID

    if (null != patInfoList) {//patInfoListが有効だった場合、検索
      if (targetJson.has("pat_id") && null != targetJson.get("pat_id")) {
        dbgPrint("■pat_id:" + targetJson.get("pat_id"));
        //該当情報を探す
        for (int j = 0; j < patInfoList.size(); j++) {
          if (patInfoList.get(j).getPat_id().equals(targetJson.get("pat_id"))) {
            //見つかった
            tmpPPM = patInfoList.get(j);
            break;
          }
        }

        //患者IDが一致する情報が見つかった場合、名前(姓)、名前名)、入外区分、院内表示用の患者IDをセットします
        if (null != tmpPPM) {
          targetJson.put("patLastName", tmpPPM.getPat_last_name());
          targetJson.put("patFirstName", tmpPPM.getPat_first_name());
          //入外区分のnull対策
          Integer inOutClass = tmpPPM.getIn_out_class();
          if (null == inOutClass) {
            //入外区分がnullの場合、外来として扱う
            inOutClass = 0;
          }
          targetJson.put("inOutClass", inOutClass);
          targetJson.put("hospPatId", tmpPPM.getHosp_pat_id());
        }
      }
    }

    return ret;
  }

  /**
   * ベッドデータ取得処理(1日分の取得&加工)
   *
   * @param treatDate  指定治療日
   * @param facilityCd 施設コード
   * @return
   * @throws URISyntaxException
   */
  @Transactional
  @GetMapping("/getScheduleList/1Day")
  @SuppressWarnings("unchecked")
  public ResponseEntity<List<String>> getScheduleListDataFromDB_DAO(
    @RequestParam(name = "treatDate", required = true) String treatDate,
    @RequestParam(name = "facilityCd", required = true) String facilityCd
  ) throws URISyntaxException {

//    /* modify by yuqinlong  2023-02-02 [CodeOptimization] start  */
//    //処理時間計測開始
//    long start = System.currentTimeMillis();
//
//    HttpStatus status = HttpStatus.OK;
//
//    //パラメータ
//    dbgPrint("treatDate:" + treatDate);
//    treatDate = treatDate.replaceAll("/", "");
//    dbgPrint("replaced treatDate:" + treatDate);
//    dbgPrint("facilityCd:" + facilityCd);
//
//    List<String> treatDateList = new ArrayList<>();
//    treatDateList.add(treatDate);
//    //メイン部分のベッド一覧取得
//    List<Map<String, Object>> retList = scheduleListService.getBedListMain(
//      facilityCd,
//      treatDateList
//    );
//
//    //取得内容確認 ここから   ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
//    dbgPrint(treatDate + ":retList.size():" + retList.size());
////
////      for(int i= 0 ; i < 2 ; i++)
////        for(int i= 0 ; i < retList.size() ; i++)
////      {
////        Map<String,Object> map = (Map<String,Object>)retList.get(i) ;
////
////
////        for (String key : map.keySet()) {
////          dbgPrint(key + " => " + map.get(key));
////        }
////      }
//    //取得内容確認 ここまで  ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
//
//    //未登録ベッド一覧取得
//    List<Map<String, Object>> retListNotYet = scheduleListService.getBedListNotYet(
//      facilityCd,
//      treatDateList
//    );
//
//    //取得内容確認 ここから   ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
//    dbgPrint(treatDate + ":retListNotYet.size():" + retListNotYet.size());
////
////        for(int i= 0 ; i < retListNotYet.size() ; i++)
////        {
////          Map<String,Object> map = (Map<String,Object>)retListNotYet.get(i) ;
////
////          for (String key : map.keySet()) {
////            dbgPrint(key + " => " + map.get(key));
////          }
////        }
//    //取得内容確認 ここまで  ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
//    //クール未登録一覧取得
//    List<Map<String, Object>> retListKurNotYet = scheduleListService.getBedListKurNotYet(
//      facilityCd,
//      treatDateList
//    );
//
//    //取得内容確認 ここから   ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
//    dbgPrint(treatDate + ":retListKurNotYet.size():" + retListKurNotYet.size());
//
//    for (int i = 0; i < retListKurNotYet.size(); i++) {
//      Map<String, Object> map = (Map<String, Object>) retListKurNotYet.get(i);
//
//      for (String key : map.keySet()) {
//        dbgPrint(key + " => " + map.get(key));
//      }
//    }
//    //取得内容確認 ここまで  ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
//
//    //----------------------------------------------------------
//    //患者情報の取得
//    //患者IDの収集
//    // 患者ID一覧格納用
//    List<Long> patIdList = new ArrayList<Long>();
//    // 施設コード一覧(一つだけ)格納用
//    List<String> facilityCdList = new ArrayList<String>();
//    facilityCdList.add(facilityCd);
//
//    //ベッド一覧のリスト
//    Object[] obj = {
//      retList,             //ベッド一覧
//      retListNotYet,       //未登録ベッド一覧
//      retListKurNotYet     //クール未登録一覧
//    };
//
//    //患者ID収集
//    List<Map<String, Object>> tmpList = null;
//    for (int j = 0; j < obj.length; j++) {
//      tmpList = (List<Map<String, Object>>) obj[j];
//      for (int i = 0; i < tmpList.size(); i++) {
//        if (null != tmpList.get(i).get("pat_id")) {
//          long patId = (long) tmpList.get(i).get("pat_id");
//          if (!patIdList.contains(patId)) {
//            patIdList.add(patId);
//          }
//        }
//      }
//    }
//    dbgPrint("patIdList.size():" + patIdList.size());
//
//
//    List<PatPersonalMain> patInfoList = null;
//    //パラメータのリストが0件より大きい場合のみ、DB検索する
//    if (0 != patIdList.size()) {
//      //患者情報の取得
//      patInfoList = scheduleListService.getPatInfoList(
//        facilityCdList,
//        patIdList
//      );
//    }
//
//    //------------------------------------------------------------------------
//    //データの加工
//
//    //DBから取得した値をJson化
//    // メイン部
//    JSONArray jArry = new JSONArray(retList);
//    // ベッド未登録
//    JSONArray jArryNotYet = new JSONArray(retListNotYet);
//    // クール未登録
//    JSONArray jArryKurNotYet = new JSONArray(retListKurNotYet);
//
//    //クールでデータを分ける
//
//    Map<String, Object> jObj = null;
//
//    long preKur = -1;
//    String preKurName = "";
//
//    int arrayIndex = 1;
//
//    JSONArray tmpArray = null;
//
//    JSONArray retArray = new JSONArray();
//    JSONArray retArrayNotYet = new JSONArray();
//    int retIndex = 0;
//    String[] kurNames = new String[10];
//    String[] kurNamesNotYet = new String[10];
//
//    //クールごとの振り分け(ベッドメイン部分)
//    try {
//      for (int i = 0; i < retList.size(); i++) {
//        //-------------------------------------------
//        //名前・入外区分の追加 ここから
//        JSONObject tmpJObj = (JSONObject) jArry.get(i);
//        addNameAndInout(tmpJObj, patInfoList);
//        //名前・入外区分の追加 ここまで
//        //------------------------------------------
//
//        jObj = retList.get(i);
//
//        if (!jObj.get("kur_cd").equals(preKur)) {
//          dbgPrint("クールが" + preKur + "から" + jObj.get("kur_cd") + "に切り替わった");
//          dbgPrint("クールが" + preKurName + "から" + jObj.get("kur_name") + "に切り替わった");
//
//          if (tmpArray != null) {
//            //格納
//            kurNames[retIndex] = preKurName;
//            retArray.put(retIndex, tmpArray);
//            ++retIndex;      //インデックスの増加タイミングがわかりやすいように分けて記述
//          }
//
//          preKur = (long) jObj.get("kur_cd");
//          preKurName = (String) jObj.get("kur_name");
//
//          tmpArray = new JSONArray();
//          arrayIndex = 1;      //番号0要素はvue側では使わないので番号1から格納
//        }
//
//        tmpArray.put(arrayIndex++, jArry.get(i));
//
////      dbgPrint("Map Ver "+jObj.get("no") + " name:" + jObj.get("patlastname") + " " + jObj.get("patfirstname"));
//      }
//      kurNames[retIndex] = preKurName;
//      retArray.put(retIndex++, tmpArray);
//    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
//    }
//
//    dbgPrint("retArray.length():" + retArray.length());
//
//    JSONArray retBuildArray = new JSONArray();
//    JSONObject buildJson = null;
//
//    //クールごとの振り分け(ベッド未登録部分)
//    try {
//      arrayIndex = 1;
//      jObj = null;
//      preKurName = "";
//      tmpArray = null;
//      preKur = -1;
//      retIndex = 0;
//
//      dbgPrint("retListNotYet.size():" + retListNotYet.size());
//      for (int i = 0; i < retListNotYet.size(); i++) {
//        //-------------------------------------------
//        //名前・入外区分の追加 ここから
//        JSONObject tmpJObj = (JSONObject) jArryNotYet.get(i);
//        addNameAndInout(tmpJObj, patInfoList);
//        //名前・入外区分の追加 ここまで
//        //------------------------------------------
//
//        jObj = retListNotYet.get(i);
//
//        if (Integer.parseInt(jObj.get("kur_cd").toString()) != preKur) {
//          dbgPrint("クールが" + preKur + "から" + jObj.get("kur_cd") + "に切り替わった");
//          dbgPrint("クールが" + preKurName + "から" + jObj.get("kur_name") + "に切り替わった");
//
//          if (tmpArray != null) {
//            //格納
//            dbgPrint("retIndex:" + retIndex);
//            kurNamesNotYet[retIndex] = preKurName;
//            retArrayNotYet.put(retIndex, tmpArray);
//            ++retIndex;      //インデックスの増加タイミングがわかりやすいように分けて記述
//          }
//          dbgPrint("jObj.get(\"kur_cd\"):" + jObj.get("kur_cd"));
//          preKur = Integer.parseInt(jObj.get("kur_cd").toString());
//          preKurName = (String) jObj.get("kur_name");
//
//          tmpArray = new JSONArray();
//          arrayIndex = 1;      //番号0要素はvue側では使わないので番号1から格納
//        }
//
//        tmpArray.put(arrayIndex++, jArryNotYet.get(i));
//
////      dbgPrint("Map Ver "+jObj.get("no") + " name:" + jObj.get("patlastname") + " " + jObj.get("patfirstname"));
//      }
//      kurNamesNotYet[retIndex] = preKurName;
//      retArrayNotYet.put(retIndex++, tmpArray);
//    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
//    }
//
//    //クール未登録部分 ※1日内でクールをまたいで乙型に配置
//
//    try {
//      JSONArray bedNotYetJson = null;
////      JSONArray kurNotYetJson = null ;
//
//      for (int i = 0; i < retArray.length(); i++) {
//        buildJson = new JSONObject();
//        buildJson.put("kur", kurNames[i]);
//        buildJson.put("beddata", retArray.get(i));
//
//        //クールが一致するものを探してputする
//        bedNotYetJson = new JSONArray();
//        for (int j = 0; j < retArrayNotYet.length(); j++) {
//          if (kurNamesNotYet[j].equals(kurNames[i])) {
//            bedNotYetJson = retArrayNotYet.getJSONArray(j);
//
//            //とりあえずクール未登録に値をセット(実験的コード)
////            kurNotYetJson = retArrayNotYet.getJSONArray(j) ;
//            break;
//          }
//        }
//        buildJson.put("bedNotYet", bedNotYetJson);
//        retBuildArray.put(i, buildJson);
//      }
//      //クール未登録の設定(とりあえず入れてみる)
//
////      kurNotYetJson = new JSONArray() ;
//      buildJson = new JSONObject();
//      buildJson.put("kur", "kurNotYet");
//      //0要素はnullなので、要素をひとつずつずらす
//      for (int index = jArryKurNotYet.length(); index > 0; index--) {
//        //-------------------------------------------
//        //名前・入外区分の追加 ここから
//        JSONObject tmpJObj = (JSONObject) jArryKurNotYet.get(index - 1);
//        addNameAndInout(tmpJObj, patInfoList);
//        //名前・入外区分の追加 ここまで
//        //------------------------------------------
//        jArryKurNotYet.put(index, tmpJObj);
//      }
//      //0要素にnullをセット
//      jArryKurNotYet.put(0, "");
//      buildJson.put("beddata", jArryKurNotYet);
//      retBuildArray.put(retArray.length(), buildJson);
//    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
//    }
//
//    //返却
//    List<String> listRet = new ArrayList<>();
//
//    try {
//
//      listRet.add(retBuildArray.toString());
//
//    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
//    }
//
//
//    //処理時間計測終了
//    long end = System.currentTimeMillis();
//    dbgPrint("getScheduleListDataFromDB_DAO 処理時間:" + (end - start) + "ms");
//
//    return new ResponseEntity<>(listRet, status);
    /* modify by yuqinlong  2023-02-02 [CodeOptimization] end  */

    return scheduleListService.getScheduleListDataFromDB_DAO(treatDate, facilityCd);
  }

  /**
   * ベッドデータ取得処理(数日分の取得&加工)
   *
   * @param treatDate  指定治療日(日付間を-区切りの日付け文字列yyyymmdd-yyyymmddd・・・・)
   * @param facilityCd 施設コード
   * @return
   * @throws URISyntaxException
   */
  @Transactional
  @GetMapping("/getScheduleList/Days")
  public ResponseEntity<List<String>> getScheduleListDataDaysFromDB(
    @RequestParam(name = "treatDate", required = true) String treatDate,
    @RequestParam(name = "facilityCd", required = true) String facilityCd
  ) throws URISyntaxException {

    //処理時間計測開始
    long start = System.currentTimeMillis();

    HttpStatus status = HttpStatus.OK;

    //返却
    List<String> listRet = new ArrayList<>();

    try {
      // FNSI-修正、パフォーマンス改善、#5559、#5768、#6050、xugj mod start
      listRet = getScheduleListDataFromDB(treatDate, facilityCd);
//      for (int d = 0; d < treatDateDim.length; d++) {
//        String retData = getScheduleListOneDayDataFromDB(treatDateDim[d], facilityCd);
//        listRet.add(retData);
//      }
      // FNSI-修正、パフォーマンス改善、#5559、#5768、#6050、xugj mod end
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
    }

    //処理時間計測終了
    long end = System.currentTimeMillis();
    dbgPrint("getScheduleListDataDaysFromDB 処理時間:" + (end - start) + "ms");

    return new ResponseEntity<>(listRet, status);
  }

  /**
   * 指定期間分のその他予定取得(検査予定、放射線検査予定、患者イベント、定期点検予定、水質管理予定)
   *
   * @param startDate 開始日
   * @param endDate   終了日
   * @return
   * @throws URISyntaxException
   */
  @Transactional
  @GetMapping("/getOtherScheduleList")
  public ResponseEntity<?> getOtherScheduleList(
    @RequestParam(name = "startDate", required = true) String startDate,
    @RequestParam(name = "endDate", required = true) String endDate,
    @AuthenticationPrincipal NtssUser ntssUser
  ) throws URISyntaxException {
    OtherScheduleListResponse res = null;
    try {
      res = scheduleListService.getOtherScheduleListByPeriod(startDate, endDate, ntssUser.getFacilityCd());
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("指定期間分のその他予定取得処理でエラー ：" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
    }
    return new ResponseEntity<>(res, HttpStatus.OK);
  }

  /**
   * ベッドデータ取得処理(1日分の取得&加工)
   *
   * @param treatDate  指定治療日
   * @param facilityCd 施設コード
   * @return
   * @throws URISyntaxException
   */
  @Transactional
  @SuppressWarnings("unchecked")
  public List<String> getScheduleListDataFromDB(
    String treatDate,
    String facilityCd
  ) throws Exception {

    //処理時間計測開始
    long start = System.currentTimeMillis();

    //パラメータ
    dbgPrint("treatDate:" + treatDate);
    treatDate = treatDate.replaceAll("/", "");
    dbgPrint("replaced treatDate:" + treatDate);
    dbgPrint("facilityCd:" + facilityCd);

    String[] treatDateDim = treatDate.split("-");
    List<String> treatDateList = Arrays.asList(treatDateDim);
    //メイン部分のベッド一覧取得
    List<Map<String, Object>> retList = scheduleListService.getBedListMain(
      facilityCd,
      treatDateList
    );

    //取得内容確認 ここから   ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
    dbgPrint(treatDate + ":retList.size():" + retList.size());
//
//      for(int i= 0 ; i < 2 ; i++)
//        for(int i= 0 ; i < retList.size() ; i++)
//      {
//        Map<String,Object> map = (Map<String,Object>)retList.get(i) ;
//
//
//        for (String key : map.keySet()) {
//          dbgPrint(key + " => " + map.get(key));
//        }
//      }
    //取得内容確認 ここまで  ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑

    //未登録ベッド一覧取得
    List<Map<String, Object>> retListNotYet = scheduleListService.getBedListNotYet(
      facilityCd,
      treatDateList
    );

    //取得内容確認 ここから   ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
    dbgPrint(treatDate + ":retListNotYet.size():" + retListNotYet.size());
//
//        for(int i= 0 ; i < retListNotYet.size() ; i++)
//        {
//          Map<String,Object> map = (Map<String,Object>)retListNotYet.get(i) ;
//
//          for (String key : map.keySet()) {
//            dbgPrint(key + " => " + map.get(key));
//          }
//        }
    //取得内容確認 ここまで  ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
    //クール未登録一覧取得
    List<Map<String, Object>> retListKurNotYet = scheduleListService.getBedListKurNotYet(
      facilityCd,
      treatDateList
    );

    //取得内容確認 ここから   ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
    dbgPrint(treatDate + ":retListKurNotYet.size():" + retListKurNotYet.size());

    for (int i = 0; i < retListKurNotYet.size(); i++) {
      Map<String, Object> map = (Map<String, Object>) retListKurNotYet.get(i);

      for (String key : map.keySet()) {
        dbgPrint(key + " => " + map.get(key));
      }
    }
    //取得内容確認 ここまで  ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑

    //----------------------------------------------------------
    //患者情報の取得
    //患者IDの収集
    // 患者ID一覧格納用
    List<Long> patIdList = new ArrayList<Long>();
    // 施設コード一覧(一つだけ)格納用
    List<String> facilityCdList = new ArrayList<String>();
    facilityCdList.add(facilityCd);

    //ベッド一覧のリスト
    Object[] obj = {
      retList,             //ベッド一覧
      retListNotYet,       //未登録ベッド一覧
      retListKurNotYet     //クール未登録一覧
    };

    //患者ID収集
    List<Map<String, Object>> tmpList = null;
    for (int j = 0; j < obj.length; j++) {
      tmpList = (List<Map<String, Object>>) obj[j];
      for (int i = 0; i < tmpList.size(); i++) {
        if (null != tmpList.get(i).get("pat_id")) {
          long patId = (long) tmpList.get(i).get("pat_id");
          if (!patIdList.contains(patId)) {
            patIdList.add(patId);
          }
        }
      }
    }
    dbgPrint("patIdList.size():" + patIdList.size());


    List<PatPersonalMain> patInfoList = null;
    //パラメータのリストが0件より大きい場合のみ、DB検索する
    if (0 != patIdList.size()) {
      //患者情報の取得
//      add 10061 by kangjie 20231120 start
//      patInfoList = scheduleListService.getPatInfoList(
//        facilityCdList,
//        patIdList
//      );
      patInfoList = scheduleListService.getPatPersonalMainDtoList(facilityCdList,patIdList);
    }

    //------------------------------------------------------------------------
    //データの加工

    //DBから取得した値をJson化
    // メイン部
    JSONArray jArry = new JSONArray(retList);
    // ベッド未登録
    JSONArray jArryNotYet = new JSONArray(retListNotYet);
    // クール未登録
    JSONArray jArryKurNotYet = new JSONArray(retListKurNotYet);

    //クールでデータを分ける

    Map<String, Object> jObj = null;

    long preKur = -1;
    String preKurName = "";

    int arrayIndex = 1;

    JSONArray tmpArray = null;

    JSONArray retArray = new JSONArray();
    JSONArray retArrayNotYet = new JSONArray();
    int retIndex = 0;
    String[] kurNames = new String[10];
    String[] kurNamesNotYet = new String[10];

    //クールごとの振り分け(ベッドメイン部分)
    try {
      for (int i = 0; i < retList.size(); i++) {
        //-------------------------------------------
        //名前・入外区分の追加 ここから
        JSONObject tmpJObj = (JSONObject) jArry.get(i);
        addNameAndInout(tmpJObj, patInfoList);
        //名前・入外区分の追加 ここまで
        //------------------------------------------

        jObj = retList.get(i);

        if (!jObj.get("kur_cd").equals(preKur)) {
          dbgPrint("クールが" + preKur + "から" + jObj.get("kur_cd") + "に切り替わった");
          dbgPrint("クールが" + preKurName + "から" + jObj.get("kur_name") + "に切り替わった");

          if (tmpArray != null) {
            //格納
            kurNames[retIndex] = preKurName;
            retArray.put(retIndex, tmpArray);
            ++retIndex;      //インデックスの増加タイミングがわかりやすいように分けて記述
          }

          preKur = (long) jObj.get("kur_cd");
          preKurName = (String) jObj.get("kur_name");

          tmpArray = new JSONArray();
          arrayIndex = 1;      //番号0要素はvue側では使わないので番号1から格納
        }

        tmpArray.put(arrayIndex++, jArry.get(i));

//      dbgPrint("Map Ver "+jObj.get("no") + " name:" + jObj.get("patlastname") + " " + jObj.get("patfirstname"));
      }
      kurNames[retIndex] = preKurName;
      retArray.put(retIndex++, tmpArray);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
    }

    dbgPrint("retArray.length():" + retArray.length());

    JSONArray retBuildArray = new JSONArray();
    JSONObject buildJson = null;

    //クールごとの振り分け(ベッド未登録部分)
    try {
      arrayIndex = 1;
      jObj = null;
      preKurName = "";
      tmpArray = null;
      preKur = -1;
      retIndex = 0;

      dbgPrint("retListNotYet.size():" + retListNotYet.size());
      for (int i = 0; i < retListNotYet.size(); i++) {
        //-------------------------------------------
        //名前・入外区分の追加 ここから
        JSONObject tmpJObj = (JSONObject) jArryNotYet.get(i);
        addNameAndInout(tmpJObj, patInfoList);
        //名前・入外区分の追加 ここまで
        //------------------------------------------

        jObj = retListNotYet.get(i);

        if (Integer.parseInt(jObj.get("kur_cd").toString()) != preKur) {
          dbgPrint("クールが" + preKur + "から" + jObj.get("kur_cd") + "に切り替わった");
          dbgPrint("クールが" + preKurName + "から" + jObj.get("kur_name") + "に切り替わった");

          if (tmpArray != null) {
            //格納
            dbgPrint("retIndex:" + retIndex);
            kurNamesNotYet[retIndex] = preKurName;
            retArrayNotYet.put(retIndex, tmpArray);
            ++retIndex;      //インデックスの増加タイミングがわかりやすいように分けて記述
          }
          dbgPrint("jObj.get(\"kur_cd\"):" + jObj.get("kur_cd"));
          preKur = Integer.parseInt(jObj.get("kur_cd").toString());
          preKurName = (String) jObj.get("kur_name");

          tmpArray = new JSONArray();
          arrayIndex = 1;      //番号0要素はvue側では使わないので番号1から格納
        }

        tmpArray.put(arrayIndex++, jArryNotYet.get(i));

//      dbgPrint("Map Ver "+jObj.get("no") + " name:" + jObj.get("patlastname") + " " + jObj.get("patfirstname"));
      }
      kurNamesNotYet[retIndex] = preKurName;
      retArrayNotYet.put(retIndex++, tmpArray);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
    }

    //クール未登録部分 ※1日内でクールをまたいで乙型に配置

    try {
      JSONArray bedNotYetJson = null;
//      JSONArray kurNotYetJson = null ;

      for (int i = 0; i < retArray.length(); i++) {
        buildJson = new JSONObject();
        buildJson.put("kur", kurNames[i]);
        buildJson.put("beddata", retArray.get(i));

        //クールが一致するものを探してputする
        bedNotYetJson = new JSONArray();
        for (int j = 0; j < retArrayNotYet.length(); j++) {
          if (kurNamesNotYet[j].equals(kurNames[i])) {
            bedNotYetJson = retArrayNotYet.getJSONArray(j);

            //とりあえずクール未登録に値をセット(実験的コード)
//            kurNotYetJson = retArrayNotYet.getJSONArray(j) ;
            break;
          }
        }
        buildJson.put("bedNotYet", bedNotYetJson);
        retBuildArray.put(i, buildJson);
      }
      //クール未登録の設定(とりあえず入れてみる)

//      kurNotYetJson = new JSONArray() ;
      buildJson = new JSONObject();
      buildJson.put("kur", "kurNotYet");
      //0要素はnullなので、要素をひとつずつずらす
      for (int index = jArryKurNotYet.length(); index > 0; index--) {
        //-------------------------------------------
        //名前・入外区分の追加 ここから
        JSONObject tmpJObj = (JSONObject) jArryKurNotYet.get(index - 1);
        addNameAndInout(tmpJObj, patInfoList);
        //名前・入外区分の追加 ここまで
        //------------------------------------------
        jArryKurNotYet.put(index, tmpJObj);
      }
      //0要素にnullをセット
      jArryKurNotYet.put(0, "");
      buildJson.put("beddata", jArryKurNotYet);
      retBuildArray.put(retArray.length(), buildJson);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
    }

    // FNSI-修正、パフォーマンス改善、#5559、#5768、#6050、xugj add start
    List<String> resultList = new ArrayList<>();

    // 治療日毎データ作成
    for (String treatDateTmp : treatDateList) {
      JSONArray retElement = new JSONArray();
      JSONObject retObj = null;
      for (int k = 0; k < retBuildArray.length(); k++) {
        JSONObject jsonObj = (JSONObject) retBuildArray.get(k);
        JSONArray jsonArrayBedNotYet = jsonObj.has("bedNotYet") ? jsonObj.getJSONArray("bedNotYet") : null;
        JSONArray jsonArrayBeddata = jsonObj.has("beddata") ? jsonObj.getJSONArray("beddata") : null;
        String jsonArrayKur = jsonObj.has("kur") ? (String) jsonObj.get("kur") : "";
        retObj = new JSONObject();
        // ベッド未登録データ
        if (jsonArrayBedNotYet != null) {
          JSONArray jsonArray = new JSONArray();
          if (jsonArrayBedNotYet.length() != 0) {
            int index = 1;
            for (int j = 0; j < jsonArrayBedNotYet.length(); j++) {
              if (j != 0) {
                JSONObject jsonObject = (JSONObject) jsonArrayBedNotYet.get(j);
                if (treatDateTmp.equals(jsonObject.get("treatDate"))) {
                  jsonArray.put(index, jsonObject);
                  index++;
                }
              }
            }
          }
          retObj.put("bedNotYet", jsonArray);
        }
        // ベッドデータ
        //mod #10601 スケジュール表動作不正 start
//        List<Long> bedCdList = new ArrayList<>();
        Map<Long,Long> bedCdMap = new HashMap<>();
        //mod #10601 スケジュール表動作不正 end
        JSONArray beddata = new JSONArray();
        if (jsonArrayBeddata != null) {
          JSONArray jsonArray = new JSONArray();
          if (jsonArrayBeddata.length() != 0) {
            int index = 1;
            for (int j = 0; j < jsonArrayBeddata.length(); j++) {
              if (j != 0) {
                JSONObject jsonObject = (JSONObject) jsonArrayBeddata.get(j);
                Long bedCd = (Long) jsonObject.get("bed_cd");
                // ベッドリスト作成
                if (bedCd != 0 && !bedCdMap.containsKey(bedCd)) {
                  bedCdMap.put(bedCd,(Long) jsonObject.get("No"));
                }
                // 予定リスト作成
                if (!jsonObject.has("treatDate") || treatDateTmp.equals(jsonObject.get("treatDate"))) {
                  JSONObject jObj1 = new JSONObject(jsonObject, JSONObject.getNames(jsonObject));
                  //治療日空白場合、当日を設定する
                  if (!jObj1.has("treatDate")) {
                    jObj1.put("treatDate", treatDateTmp);
                  }
                  jsonArray.put(index, jObj1);
                  index++;
                }
              }
            }

            // ベッドデータの補足
            // mod #8083 2022/11/18 患者情報の存在しない患者の予定が画面に反映されてしまう。 dou start
            // if (jsonArray.length() != 0) {
            if (jsonArray.length() != 0 && !"kurNotYet".equals(jsonArrayKur)) {
            // mod #8083 2022/11/18 患者情報の存在しない患者の予定が画面に反映されてしまう。 dou end
              //mod #10601 スケジュール表動作不正 start
              for (Map.Entry<Long, Long> entry : bedCdMap.entrySet()) {
                Long key = entry.getKey();
                Long value = entry.getValue();

                boolean existFlg = false;
                Long bedCd = key;
                for (int i = 1; i < jsonArray.length(); i++) {
                  JSONObject jsonObject = jsonArray.getJSONObject(i);
                  if (bedCd.longValue() == ((Long) jsonObject.get("bed_cd")).longValue()) {
                    existFlg = true;
                    break;
                  }
                }
                if (!existFlg) {
                  JSONObject jsonObject = new JSONObject();
                  jsonObject.put("No", value);
                  jsonObject.put("kur_cd", (Long) jsonArray.getJSONObject(1).get("kur_cd"));
                  jsonObject.put("bed_cd", bedCd);
                  jsonObject.put("hospPatId", "");
                  jsonObject.put("patLastName", "");
                  jsonObject.put("title", "");
                  jsonObject.put("patFirstName", "");
                  jsonObject.put("inOutClass", "");
                  jsonObject.put("treatDate", treatDateTmp);
                  jsonObject.put("kur_name", jsonArray.getJSONObject(1).get("kur_name"));
                  jsonArray.put(index, jsonObject);
                  index++;
                }
              }
//              for (int j = 0; j < bedCdList.size(); j++) {
//                boolean existFlg = false;
//                Long bedCd = bedCdList.get(j);
//                for (int i = 1; i < jsonArray.length(); i++) {
//                  JSONObject jsonObject = jsonArray.getJSONObject(i);
//                  if (bedCd.longValue() == ((Long) jsonObject.get("bed_cd")).longValue()) {
//                    existFlg = true;
//                    break;
//                  }
//                }
//                if (!existFlg) {
//                  JSONObject jsonObject = new JSONObject();
//                  jsonObject.put("No", Long.valueOf(String.valueOf(j + 1)));
//                  jsonObject.put("kur_cd", (Long) jsonArray.getJSONObject(1).get("kur_cd"));
//                  jsonObject.put("bed_cd", bedCd);
//                  jsonObject.put("hospPatId", "");
//                  jsonObject.put("patLastName", "");
//                  jsonObject.put("title", "");
//                  jsonObject.put("patFirstName", "");
//                  jsonObject.put("inOutClass", "");
//                  jsonObject.put("treatDate", treatDateTmp);
//                  jsonObject.put("kur_name", jsonArray.getJSONObject(1).get("kur_name"));
//                  jsonArray.put(index, jsonObject);
//                  index++;
//                }
//              }
              //mod #10601 スケジュール表動作不正 end
            }
          }

          // 「No」でソート処理
          // mod 10601 スケジュール表動作不正 関  start
          List<Long> listTmp = new ArrayList<>();
          List<JSONObject> list = new ArrayList<>();
          for (int i = 1; i < jsonArray.length(); i++) {
            JSONObject x = jsonArray.getJSONObject(i);
            if (!listTmp.contains(x.get("No"))) {
              listTmp.add((Long) x.get("No"));
              list.add(x);
            }
          }
          // mod 10601 スケジュール表動作不正 関  end

          Collections.sort(list, (JSONObject a, JSONObject b) -> {
            Long valA1 = 0L;
            Long valA2 = 0L;
            try {
              valA1 = (Long) a.get("No");
              valA2 = (Long) b.get("No");
            } catch (JSONException e) {
            }
            // ルール：昇順
            if (valA1.intValue() > valA2.intValue()) {
              return 1;
            } else {
              return -1;
            }
          });

          for (int i = 0; i < list.size(); i++) {
            beddata.put(i + 1, list.get(i));
          }
          retObj.put("beddata", beddata);
        }
        // クール設定
        retObj.put("kur", jsonArrayKur);

        // クールごとデータ設定
        retElement.put(k, retObj);
      }

      try {
        resultList.add(retElement.toString());
      } catch (Exception e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        if (facilityCd != null) {
          eventLogMessage.setFacilityCd(facilityCd);
        }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
        logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
      }
    }
    // FNSI-修正、パフォーマンス改善、#5559、#5768、#6050、xugj add end

    //処理時間計測終了
    long end = System.currentTimeMillis();
    dbgPrint("getScheduleListDataFromDB 処理時間:" + (end - start) + "ms");

    return resultList;
  }

  /**
   * デバッグ出力
   *
   * @param msg
   */
  private void dbgPrint(String msg) {
  }

  /**
   * 次患者更新APIの呼び出し
   *
   * @param beforeBedCd:変更前のベッドコード
   * @param afterBedCd:変更後のベッドコード
   * @param afterKurCd:変更後のクールコード
   * @return
   */

  @GetMapping("/SetNextPatInfo")
  public ResponseEntity<String> SetNextPatInfo(
    @RequestParam(name = "beforeBedCd", required = true) Long beforeBedCd,
    @RequestParam(name = "afterBedCd", required = true) Long afterBedCd,
    @RequestParam(name = "afterKurCd", required = true) Long afterKurCd
  ) {

    ResponseEntity<String> ret = null;
    JSONObject message = new JSONObject("{}");
    HttpStatus status = HttpStatus.OK;
    int set_next_pat = 0;
    int device_edge_order = 0;

    // 次患者更新処理
    LocalDateTime update = LocalDateTime.now();
    if (beforeBedCd != 0) {
      // 変更前のベッド
      try {
        ret = webApiCallCommonUtil.SetNextPatInfo(beforeBedCd, false, update);
        JSONObject json = new JSONObject(ret.getBody().toString());
        if (!json.has("isSuccess")) {
          // 次患者更新エラー処理
          set_next_pat++;
        } else if (ret.getStatusCode() != status) {
          device_edge_order++;
        }
      } catch (URISyntaxException e) {
        message.put("retMsg", e.getMessage());
        status = HttpStatus.BAD_REQUEST;
      } catch (RuntimeException e) {
        message.put("retMsg", e.getMessage());
        status = HttpStatus.BAD_REQUEST;
      }
    }

    if (afterBedCd != 0 && afterKurCd != 0 && beforeBedCd.compareTo(afterBedCd) != 0) {
      // 変更後(選択された)のベッド
      try {
        ret = webApiCallCommonUtil.SetNextPatInfo(afterBedCd, false, update);
        JSONObject json = new JSONObject(ret.getBody().toString());
        if (!json.has("isSuccess")) {
          // 次患者更新エラー処理
          set_next_pat++;
        } else if (ret.getStatusCode() != status) {
          device_edge_order++;
        }
      } catch (URISyntaxException e) {
        message.put("retMsg", e.getMessage());
        status = HttpStatus.BAD_REQUEST;
      } catch (RuntimeException e) {
        message.put("retMsg", e.getMessage());
        status = HttpStatus.BAD_REQUEST;
      }
    }

    message.put("set_next_pat", set_next_pat);
    message.put("device_edge_order", device_edge_order);

    return new ResponseEntity<String>(message.toString(), null, status);
  }

  @PostMapping("/callDoCancelSetNextPatInfo")
  public ResponseEntity<String> callDoCancelSetNextPatInfo(@RequestBody Map<String, String> bodyDate) {
    String facilityCd = bodyDate.get("facilityCd");
    Long beforeBedCd = Long.parseLong(bodyDate.get("beforeBedCd"));
    Long afterBedCd = Long.parseLong(bodyDate.get("afterBedCd"));
    Long targetOrdNo = Long.parseLong(bodyDate.get("targetOrdNo"));
    String message = "";
    HttpStatus status = HttpStatus.OK;

    try {
      LocalDateTime update = LocalDateTime.now();
      /* mod #5482 by zhangruixue 2023-03-02 スケジュール --start */
      OrdMain ordMain = OrdMainService.selectByOrdNo(targetOrdNo);
      //mod 7188 治療条件，装置設定を変更すると次患者が再送される start zhao
      //message = ordMainResource.callDoCancelSetNextPatInfo(facilityCd, beforeBedCd, afterBedCd, ordMain, false, update);
      List<Long> nextOrdNoList = new ArrayList<>();
      nextOrdNoList.add(ordMain.getOrdNo());
      // del #9116 【デグレ】スケジュール入れ替え時に操作した患者の次患者情報しか更新されない dou start
      // List<MntMachineState> machineStateList = mntMachineStateDao.selectByNextOrdNoAndNextPatId(ordMain.getPatId(),ordMain.getFacilityCd(),nextOrdNoList);
      // if(machineStateList.size()>0){
        // del #9116 【デグレ】スケジュール入れ替え時に操作した患者の次患者情報しか更新されない dou end
        message = ordMainResource.callDoCancelSetNextPatInfo(facilityCd, beforeBedCd, afterBedCd, ordMain, false, update);
      // }
      //mod 7188 治療条件，装置設定を変更すると次患者が再送される end zhao
      /* mod #5482 by zhangruixue 2023-03-02 スケジュール --end */

    } catch (RuntimeException e) {
      message = "「条件送信キャンセル」「次患者更新」処理失敗";
      status = HttpStatus.BAD_REQUEST;
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(message);
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
    }

    return new ResponseEntity<>(message, null, status);
  }

  /* add #10124 by zhangruixue 2023-12-28  --start */
  @PostMapping("/callDoCancel")
  public ResponseEntity<String> callDoCancel(@RequestBody Map<String, String> bodyDate) {
    String facilityCd = bodyDate.get("facilityCd");
    Long beforeBedCd = Long.parseLong(bodyDate.get("beforeBedCd"));
    Long afterBedCd = Long.parseLong(bodyDate.get("afterBedCd"));
    Long targetOrdNo = Long.parseLong(bodyDate.get("targetOrdNo"));
    String message = "";
    HttpStatus status = HttpStatus.OK;

    try {
      OrdMain ordMain = OrdMainService.selectByOrdNo(targetOrdNo);
      message = ordMainResource.callDoCancel(facilityCd, beforeBedCd, afterBedCd, ordMain);
    } catch (RuntimeException e) {
      message = "「条件送信キャンセル」「次患者更新」処理失敗";
      status = HttpStatus.BAD_REQUEST;
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(message);
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
    }

    return new ResponseEntity<>(message, null, status);
  }
  /* add #10124 by zhangruixue 2023-12-20  --end */
  /* del #10124 by zhangruixue 2023-12-28  --start */
  /* add #8582 by zhangruixue 2023-04-24  --start */
//  /**
//   * 予定 -> finishMoving
//   * @param bodyDate
//   * @return
//   */
//  @PostMapping("/finishMovingCallDoCancelSetNextPatInfo")
//  public ResponseEntity<String> finishMovingCallDoCancelSetNextPatInfo(@RequestBody Map<String, String> bodyDate) {
//    String facilityCd = bodyDate.get("facilityCd");
//    Long beforeBedCd = Long.parseLong(bodyDate.get("beforeBedCd"));
//    Long afterBedCd = Long.parseLong(bodyDate.get("afterBedCd"));
//    Long targetOrdNo = Long.parseLong(bodyDate.get("targetOrdNo"));
//    String message = "";
//    HttpStatus status = HttpStatus.OK;
//
//    try {
//      LocalDateTime update = LocalDateTime.now();
//      OrdMain ordMain = OrdMainService.selectByOrdNo(targetOrdNo);
//      message = ordMainResource.callDoCancelSetNextPatInfo(facilityCd, beforeBedCd, afterBedCd, ordMain, false, update);
//    } catch (RuntimeException e) {
//      message = "「条件送信キャンセル」「次患者更新」処理失敗";
//      status = HttpStatus.BAD_REQUEST;
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(message);
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
//      e.printStackTrace();
//    }
//
//    return new ResponseEntity<>(message, null, status);
//  }
  /* add #8582 by zhangruixue 2023-04-24  --end */
  /* del #10124 by zhangruixue 2023-12-28  --end */
  // add #11493 スケジュール表　更新不正 関 start
  /**
   * 同一患者同一治療日同一クール同一治療状況のチェック
   *
   * @return Boolean true:存在した false:存在しなかった
   * @throws Exception
   */
  @Transactional
  @PostMapping("/checkBatchMovePatExistance/{facilityCd}")
  public ResponseEntity<Boolean> checkBatchMovePatExistance(
    @PathVariable String facilityCd,
    @RequestBody String bodydata
  ) throws URISyntaxException, RuntimeException, JsonProcessingException {
    HttpStatus status = HttpStatus.OK;
    Boolean ret = false;
    ret = scheduleListService.checkBatchMovePatExistance(
      bodydata,
      facilityCd
    );
    return new ResponseEntity<>(ret, status);
  }
  // add #11493 スケジュール表　更新不正 関 end
}
