package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.request.patientCapture.JournalCreateRequestPayload;
import jp.co.nikkiso.ntss.admin_web.response.ordMain.OrdMainResponse;
import jp.co.nikkiso.ntss.admin_web.service.IndHistoryMakeService;
import jp.co.nikkiso.ntss.admin_web.service.JournalService;
import jp.co.nikkiso.ntss.admin_web.service.MstInfoService;
import jp.co.nikkiso.ntss.admin_web.service.SelectHistoryUtils;
import jp.co.nikkiso.ntss.admin_web.service.indHistory.IndHistory;
import jp.co.nikkiso.ntss.admin_web.service.journal.JournalCreatePayloadService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.nextpat.NextPatService;
import jp.co.nikkiso.ntss.admin_web.service.ordmain.OrdMainEquipInfoService;
import jp.co.nikkiso.ntss.admin_web.service.ordmain.OrdMainIndService;
import jp.co.nikkiso.ntss.admin_web.service.ordmain.OrdMainMediInfoService;
import jp.co.nikkiso.ntss.admin_web.service.ordmain.check.OrdMainCondInfoCheck;
import jp.co.nikkiso.ntss.admin_web.service.ordmain.check.OrdMainOrdCheck;
import jp.co.nikkiso.ntss.admin_web.service.ordmain.util.CommonUtils;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.IndicationUtils;
import jp.co.nikkiso.ntss.admin_web.web.rest.validation.ApiEntityOrdMain;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstTreatmentDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.MstTreatmentSet;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang3.StringUtils;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.validation.ObjectError;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.net.URISyntaxException;
import java.text.ParseException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * オーダメインの{@link RestController}クラス
 */
@RestController
@RequestMapping(Uri.PATIENTS)
public class OrdMainImproveResource {

  public static final String MASSAGE_LIST = "msglist";
  @Autowired
  private OrdMainMediInfoService ordMainMediInfoService;
  @Autowired
  private OrdMainEquipInfoService ordMainEquipInfoService;
  @Autowired
  private OrdMainCondInfoCheck ordMainCondInfoCheck;
  @Autowired
  private IndHistoryMakeService indHistoryMakeService;
  @Autowired
  private OrdMainDao ordMainDao;
  @Autowired
  private MstTreatmentDao mstTreatmentDao;
  @Autowired
  private LogService logService;
  @Autowired
  private NextPatService nextPatService;
  @Autowired
  private JournalCreatePayloadService journalCreatePayloadService;
  @Autowired
  private JournalService journalService;
  @Autowired
  private SelectHistoryUtils selectHistoryUtils;
  @Autowired
  private PatMainDao patMainDao;
  @Autowired
  private OrdMainIndService ordMainIndService;
  @Autowired
  private OrdMainOrdCheck ordMainOrdCheck;
  @Autowired
  private MstInfoService mstInfoService;

  // add #12465 同患者同日同治療方法同クールの使用制限をしてもメッセージがでない zkm start
  /**
   * 治療予定登録 with 治療方法セットコード(新規登録時)
   *
   * @param bodyData 必要パラメータの記載されたJson文字列
   * @return ResponseEntity
   * @throws ParseException Exception
   * @throws JSONException Exception
   */
  @PostMapping("/ord/createByTreatSetCd")
  public ResponseEntity<String> createOrdByTreatSetCd(
    @Validated @RequestBody ApiEntityOrdMain.ValiCreateTreatPlan bodyData, BindingResult validationResult) throws JSONException, ParseException {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to insertByTreatSetCd OrdMain : " + bodyData.getTreatment_set_cd() + bodyData.getUp_date());
    logService.log(LogLevel.DEBUG, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
    eventLogMessage = new EventLogMessage();
    logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
    // バリデーションエラーチェック
    if (validationResult.hasErrors()) {
      // バリデーションエラーが発生した場合はパラメータ異常扱い
      eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("result:" + validationResult);
      logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      for (ObjectError error : validationResult.getFieldErrors()) {
        eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("error:" + error.getDefaultMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      }
      // 引数は、ボディデータ、ヘッダーデータ、ステータス
      return new ResponseEntity<>("パラメータエラー", null, HttpStatus.BAD_REQUEST);
    }

    PatMain patMain = patMainDao.selectById(Long.parseLong(bodyData.getPat_id()));

    if (null == patMain) {
      return new ResponseEntity<>("患者情報(pat_main)参照エラー", null, HttpStatus.BAD_REQUEST);
    }

    // チェック：スケジュール延長処理中の場合、処理を中止する
    String scheduleExtensionMsg = ordMainCondInfoCheck
      .validateScheduleExtension(bodyData.getIs_deadline(), patMain.getSch_ext_status());
    if (StringUtils.isNotEmpty(scheduleExtensionMsg)) {
      return new ResponseEntity<>(scheduleExtensionMsg, HttpStatus.OK);
    }

    // 治療方法セット取得
    List<MstTreatmentSet> listMstTreatSet = mstInfoService.findMstTreatmentSetByCd(Integer.parseInt(bodyData.getTreatment_set_cd()));
    if (1 != listMstTreatSet.size()) {
      return new ResponseEntity<>("治療方法セットマスタ参照エラー", null, HttpStatus.BAD_REQUEST);
    }

    MstTreatmentSet treatmentSet = listMstTreatSet.get(0);

    // 排他チェック
    String errorMsg = ordMainOrdCheck.validateTreatmentSetChangeForCreate(bodyData.getUp_date(), treatmentSet);

    EventLogMessage validateTreatmentSetChangeEventLogMessage = new EventLogMessage();
    validateTreatmentSetChangeEventLogMessage.setLogMessage("更新日時(引数(変換前)):" + bodyData.getUp_date());
    logService.log(LogLevel.INFO, validateTreatmentSetChangeEventLogMessage,
      StringUtils.EMPTY, LoggingConstant.SERVICE_NAME.FNSI, null);

    if (StringUtils.isNotEmpty(errorMsg)) {

      validateTreatmentSetChangeEventLogMessage.setLogMessage(errorMsg);
      logService.log(LogLevel.INFO, validateTreatmentSetChangeEventLogMessage, StringUtils.EMPTY, LoggingConstant.SERVICE_NAME.FNSI, null);

      return new ResponseEntity<>("排他エラー", null, HttpStatus.BAD_REQUEST);
    }

    JSONObject responseData = new JSONObject("{}");

    // スケジュール重複チェック
    String errorMsg2 = ordMainOrdCheck.validateScheduleScope(bodyData, treatmentSet.getTreatmentCd());
    if (StringUtils.isNotEmpty(errorMsg2)) {
      responseData.put("errorMessage", errorMsg2);
      return new ResponseEntity<>(responseData.toString(), null, HttpStatus.OK);
    }

    HttpStatus status = HttpStatus.OK;
    // main DB 処理
    OrdMainResponse response;
    try {
      response = ordMainIndService.createOrdByTreatSetCd(bodyData, patMain);
    } catch (Exception e) {
      //エラー
      EventLogMessage elm = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      elm.setLogMessage(ExcetionStackTraceToString(e));
      if (bodyData != null && bodyData.getFacility_cd() != null) {
        eventLogMessage.setFacilityCd(bodyData.getFacility_cd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, elm, LoggingConstant.FUNCTION_CODE.FUNC_PAT_VIEWER, LoggingConstant.SERVICE_NAME.FNSI, null);
      status = HttpStatus.INTERNAL_SERVER_ERROR;
      return new ResponseEntity<>(e.getMessage(), status);
    }

    String procResult = response.getProcResult();
    if ("SUCCESS".equals(procResult)) {
      responseData.put(MASSAGE_LIST, response.getMessageList());
      List<OrdMain> createdOrdMains = new ArrayList<>();
      Map<String, List<Object>> resultAllChangedDataInfoList = response.getResultAllChangedDataInfoList();
      if (resultAllChangedDataInfoList.containsKey("ord_main") && !resultAllChangedDataInfoList.get("ord_main").isEmpty()) {
        List<Object> ordMainObjects = resultAllChangedDataInfoList.get("ord_main");
        for (Object obj : ordMainObjects) {
          OrdMain ordMain = (OrdMain) obj;
          createdOrdMains.add(ordMain);
        }
      }

      JSONArray jsonArray = new JSONArray(
        createdOrdMains.stream()
          .map(OrdMain::getOrdNo)
          .toList()
      );
      responseData.put("ordNoList", jsonArray.toString());

      // 指示履歴未登録フラグがtrue立っていない場合のみ指示履歴を登録する
      if (indHistoryMakeService.isToMongo() && !" true".equals(bodyData.getIs_unregistered_history())) {
        indHistoryMakeService.createPlanHistory(bodyData, createdOrdMains.get(0),
          createdOrdMains.stream()
            .map(OrdMain::getTreatWeek).map(Short::intValue).distinct().toList());
      }

      // 最終日が未指定の場合にスケジュール延長最終日を更新
      if (
        null == patMain.getSch_ext_end_date() &&
          "false".equals(bodyData.getIs_deadline())
      ) {
        patMain.setSch_ext_end_date(bodyData.getEnd_date().replaceAll("-", ""));
        patMainDao.update(patMain);
      }

      // 連携関連呼出
      try {
        String actionMode;
        if (createdOrdMains.get(0).getIndKurCd() != 0) {
          actionMode = "STATUS_LIST_QUESTION_PAT";
          if (Objects.equals("STATUS_MAP", bodyData.getScrean_string())) {
            actionMode = "STATUS_MAP_QUESTION_PAT";
          }
        } else {
          actionMode = "PAT_VIEWER_PLAN";
        }
        String facilityCd = bodyData.getFacility_cd();
        Long updUserId = bodyData.getUpd_user_id().longValue();

        // 連携用、イベントログ用
        List<OrdMain> resultOrdMainChangedDataInfoList = new ArrayList<>(createdOrdMains);
        Map<String, List<Object>> journalResultAllChangedDataInfoList = new HashMap<>(); // 連携用、イベントログ用
        List<Object> objectList = new ArrayList<>(resultOrdMainChangedDataInfoList);
        journalResultAllChangedDataInfoList.put("ord_main", objectList);

        List<JournalCreateRequestPayload> journalList = journalCreatePayloadService
          .createJournalPayload(facilityCd, journalResultAllChangedDataInfoList, null,
            List.of(Long.parseLong(bodyData.getPat_id())), updUserId, actionMode);
        if (!CollectionUtils.isEmpty(journalList)) {
          journalService.callCreateJournalForCtrNo(journalList);
        }
      } catch (Exception e) {
        //エラー
        eventLogMessage.setLogMessage("連携関連呼出 " + e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_SCHEDULE_LIST,
          LoggingConstant.SERVICE_NAME.FNSI, null);
      }
    }
    return new ResponseEntity<>(responseData.toString(), null, status);
  }
  // add #12465 同患者同日同治療方法同クールの使用制限をしてもメッセージがでない zkm end

  // add #12471 ord_main.ind_medi_infoに不正データが登録される zkm start
  /**
   * 投薬一括追加
   *
   * @param bodyDataList 追加情報
   * @return ResponseEntity
   */
  @PostMapping("/medications/create")
  public ResponseEntity<String> createOrdMainMediInfo(
    @Validated @RequestBody List<ApiEntityOrdMain.ValiOrdMedi> bodyDataList) {

    ApiEntityOrdMain.ValiOrdMedi valiOrdMedi = bodyDataList.get(0);
    long patId = Long.parseLong(valiOrdMedi.getPat_id());
    PatMain patMain = patMainDao.selectById(patId);
    // チェック：スケジュール延長処理中の場合、治療条件変更を中止する
    String scheduleExtensionMsg = ordMainCondInfoCheck
      .validateScheduleExtension(valiOrdMedi.getIs_deadline(), patMain.getSch_ext_status());
    if (StringUtils.isNotEmpty(scheduleExtensionMsg)) {
      return new ResponseEntity<>(scheduleExtensionMsg, HttpStatus.OK);
    }

    HttpStatus status = HttpStatus.OK;

    // main DB 処理
    OrdMainResponse response;
    try {
      response = ordMainMediInfoService.createOrdMainMediInfo(bodyDataList);
    } catch (Exception e) {
      //エラー
      EventLogMessage elm = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      elm.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, elm, LoggingConstant.FUNCTION_CODE.FUNC_PAT_VIEWER, LoggingConstant.SERVICE_NAME.FNSI, null);
      status = HttpStatus.INTERNAL_SERVER_ERROR;
      return new ResponseEntity<>(e.getMessage(), status);
    }

    JSONObject responseData = new JSONObject("{}");
    String procResult = response.getProcResult();
    if ("SUCCESS".equals(procResult)) {
      // 更新前ord_mainリストを取得する
      List<OrdMain> updatePreOrdMainList = new ArrayList<>();
      Map<String, List<Object>> resultAllChangeBeforeDataInfoList = response.getResultAllChangeBeforeDataInfoList();
      if (resultAllChangeBeforeDataInfoList.containsKey("ord_main")
        && !resultAllChangeBeforeDataInfoList.get("ord_main").isEmpty()) {
        List<Object> ordMainObjects = resultAllChangeBeforeDataInfoList.get("ord_main");
        for (Object obj : ordMainObjects) {
          OrdMain ordMain = (OrdMain) obj;
          updatePreOrdMainList.add(ordMain);
        }
      }

      ApiEntityOrdMain.ValiOrdMedi firstBodyData = bodyDataList.get(0);
      if (indHistoryMakeService.isToMongo()) {
        String setLogDate = LocalDateTime.now()
          .format(DateTimeFormatter.ofPattern("yyyyMMddHHmmssSSS"));
        List<IndHistory> indHistoryList = new ArrayList<>();
        List<Integer> weeksArray = IndicationUtils.getWeekPattern(firstBodyData.getWeeks());
        for (ApiEntityOrdMain.ValiOrdMedi bodyData : bodyDataList) {
          //指示履歴用パラメータ
          IndHistory indHistory = indHistoryMakeService
            .createMedicineHistoryParams(bodyData, "1", weeksArray, new ArrayList<>());
          //指示履歴時刻設定
          indHistory.setLogDate(setLogDate);
          indHistoryList.add(indHistory);
        }
        if (!indHistoryList.isEmpty()) {
          //指示履歴登録処理
          indHistoryMakeService.createHistoryExecuteBatch(indHistoryList, "1");
        }
      }

      // ord_main_hst
      try {
        selectHistoryUtils.insertMangoDbHistoryBatch(updatePreOrdMainList.stream().map(OrdMain::getOrdNo).toList());
      } catch (Exception e) {
        //エラー
        EventLogMessage elm = new EventLogMessage();
        elm.setLogMessage("ord_main変更履歴登録 MongoDB " + e.getMessage());
        logService.log(LogLevel.ERROR, elm, LoggingConstant.FUNCTION_CODE.FUNC_PAT_VIEWER, LoggingConstant.SERVICE_NAME.FNSI, null);
      }

      String facilityCd = firstBodyData.getFacility_cd();
      String hospPatId = firstBodyData.getHosp_pat_id();
      // 連携関連呼出
      try {
        callCreateJournalWithMediEquip(updatePreOrdMainList, facilityCd, hospPatId,
          patId, firstBodyData.getInd_info(), "004113", "004023");
      } catch (Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
        //エラー
        EventLogMessage elm = new EventLogMessage();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
        elm.setLogMessage("連携関連呼出 " + ExcetionStackTraceToString(e));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
        logService.log(LogLevel.ERROR, elm, LoggingConstant.FUNCTION_CODE.FUNC_PAT_VIEWER, LoggingConstant.SERVICE_NAME.FNSI, null);
      }

      // 次患者
      try {
        nextPatService.CallNextPatChange(facilityCd, nextPatService.FilterNextPatInfo1or2ChangedForOrdMain(facilityCd, updatePreOrdMainList));
      } catch (Exception e) {
        //エラー
        EventLogMessage elm = new EventLogMessage();
        elm.setLogMessage("サービスの新しい次患者更新呼出統合処理を呼び出す " + e.getMessage());
        logService.log(LogLevel.ERROR, elm, LoggingConstant.FUNCTION_CODE.FUNC_PAT_VIEWER, LoggingConstant.SERVICE_NAME.FNSI, null);
      }
    }
    return new ResponseEntity<>(responseData.toString(), null, status);
  }

  /**
   * ind_medi_info更新処理
   *
   * @param bodyData 必要パラメータの記載されたJson文字列
   * @return 更新結果
   */
  @PostMapping("/medications/update")
  public ResponseEntity<String> updateOrdMainMediInfo(
    @Validated @RequestBody ApiEntityOrdMain.ValiOrdMedi bodyData,
    BindingResult validationResult
  ) throws URISyntaxException, JSONException, ArrayIndexOutOfBoundsException {
    long patId = Long.parseLong(bodyData.getPat_id());
    String facilityCd = bodyData.getFacility_cd();
    PatMain patMain = patMainDao.selectById(patId);
    // チェック：スケジュール延長処理中の場合、治療条件変更を中止する
    String scheduleExtensionMsg = ordMainCondInfoCheck
      .validateScheduleExtension(bodyData.getIs_deadline(), patMain.getSch_ext_status());
    if (StringUtils.isNotEmpty(scheduleExtensionMsg)) {
      return new ResponseEntity<>(scheduleExtensionMsg, HttpStatus.OK);
    }

    JSONObject responseData = new JSONObject("{}");
    HttpStatus status = HttpStatus.OK;

    // 選択された曜日の処理
    String startDate = bodyData.getStart_date().replaceAll("-", "");
    String endDate = bodyData.getEnd_date().replaceAll("-", "");
    List<Integer> indTreatmentCds = new ArrayList<>();
    List<Long> indKurCds = new ArrayList<>();
    try {
      indTreatmentCds = CommonUtils.getValueList(bodyData.getInd_treatment_cd());
      indKurCds = CommonUtils.getLongList(bodyData.getInd_kur_cd());
    } catch (JSONException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("エラー発生：" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, StringUtils.EMPTY, LoggingConstant.SERVICE_NAME.FNSI, null);
    }
    List<OrdMain> updatePreOrdMains = List.of();
    try {
      // 更新対象ordNo List取得
      updatePreOrdMains = ordMainDao.selectUpdateTarget(
        patId,
        facilityCd,
        startDate,
        endDate,
        Arrays.asList(1, 2, 3, 4, 5, 6, 7),
        indTreatmentCds,
        indKurCds,
        null
      );

      if ("2".equals(bodyData.getUpdate_flag())) {
        updatePreOrdMains = updatePreOrdMains.stream()
          .filter(ord -> "0".equals(ord.getRstDialysisState())).collect(Collectors.toList());
      }
      if (updatePreOrdMains.isEmpty()) {
        return new ResponseEntity<>(responseData.toString(), null, status);
      }

      // 更新対象ordNo List取得「削除フラグ（０：通常）」
      updatePreOrdMains = updatePreOrdMains
        .stream()
        .filter(item -> Objects.equals(item.getIsDel(), AdminWebConstant.FlagType.FLAG_OFF))
        .collect(Collectors.toList());
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (bodyData != null && bodyData.getFacility_cd() != null) {
        eventLogMessage.setFacilityCd(bodyData.getFacility_cd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
    }

    // main DB 処理
    OrdMainResponse response;
    try {
      // ord_main及び関連テーブル更新処理
      response = ordMainMediInfoService.updateOrdMainMediInfo(bodyData, updatePreOrdMains);
    } catch (Exception e) {
      //エラー
      EventLogMessage elm = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      elm.setLogMessage(ExcetionStackTraceToString(e));
      if (bodyData != null && bodyData.getFacility_cd() != null) {
        elm.setFacilityCd(bodyData.getFacility_cd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, elm, LoggingConstant.FUNCTION_CODE.FUNC_PAT_VIEWER, LoggingConstant.SERVICE_NAME.FNSI, null);
      status = HttpStatus.INTERNAL_SERVER_ERROR;
      return new ResponseEntity<>(e.getMessage(), status);
    }

    String procResult = response.getProcResult();
    if ("SUCCESS".equals(procResult)) {

      // responseに更新前ord_mainリストを補足する
      List<OrdMain> updatedOrdMainList = new ArrayList<>();
      Map<String, List<Object>> resultAllChangedDataInfoList = response.getResultAllChangedDataInfoList();
      if (resultAllChangedDataInfoList.containsKey("ord_main") && !resultAllChangedDataInfoList.get("ord_main").isEmpty()) {
        List<Object> ordMainObjects = resultAllChangedDataInfoList.get("ord_main");
        for (Object obj : ordMainObjects) {
          OrdMain ordMain = (OrdMain) obj;
          updatedOrdMainList.add(ordMain);
        }
      }

      // 更新されたOrdMain List
      List<Long> updatedOrdNoList = updatedOrdMainList.stream().map(OrdMain::getOrdNo).collect(Collectors.toList());
      updatePreOrdMains = updatePreOrdMains.stream().filter(pre -> updatedOrdNoList.contains(pre.getOrdNo())).toList();

      //指示履歴を登録
      try {
        List<Integer> weeksArray = IndicationUtils.getWeekPattern(bodyData.getWeeks());
        indHistoryMakeService.createMedicineHistory(bodyData, "2", weeksArray, updatePreOrdMains);
      } catch (Exception e) {
        //エラー
        EventLogMessage elm = new EventLogMessage();
        elm.setLogMessage("指示履歴登録処理 MongoDB " + e.getMessage());
        logService.log(LogLevel.ERROR, elm, LoggingConstant.FUNCTION_CODE.FUNC_PAT_VIEWER, LoggingConstant.SERVICE_NAME.FNSI, null);
      }

      // ord_main_hst
      try {
        selectHistoryUtils.insertMangoDbHistoryBatch(updatedOrdNoList);
      } catch (Exception e) {
        //エラー
        EventLogMessage elm = new EventLogMessage();
        elm.setLogMessage("ord_main変更履歴登録 MongoDB " + e.getMessage());
        logService.log(LogLevel.ERROR, elm, LoggingConstant.FUNCTION_CODE.FUNC_PAT_VIEWER, LoggingConstant.SERVICE_NAME.FNSI, null);
      }

      String hospPatId = bodyData.getHosp_pat_id();
      // 連携関連呼出
      try {
        callCreateJournalWithMediEquip(updatePreOrdMains, facilityCd, hospPatId,
          patId, bodyData.getInd_info(), "004114", "004024");
      } catch (Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
        //エラー
        EventLogMessage elm = new EventLogMessage();
        elm.setLogMessage("連携関連呼出 " + e.getMessage());
        logService.log(LogLevel.ERROR, elm, LoggingConstant.FUNCTION_CODE.FUNC_PAT_VIEWER, LoggingConstant.SERVICE_NAME.FNSI, null);
      }

      // 次患者情報１、次患者情報２にたいして変更が発生しているかをチェックし、次患者情報呼び出し統合処理を呼び出す

      try {
        nextPatService.CallNextPatChange(facilityCd, nextPatService.FilterNextPatInfo1or2ChangedForOrdMain(facilityCd, updatePreOrdMains));
      } catch (Exception e) {
        //エラー
        EventLogMessage elm = new EventLogMessage();
        elm.setLogMessage("サービスの新しい次患者更新呼出統合処理を呼び出す " + e.getMessage());
        logService.log(LogLevel.ERROR, elm, LoggingConstant.FUNCTION_CODE.FUNC_PAT_VIEWER, LoggingConstant.SERVICE_NAME.FNSI, null);
      }

      return new ResponseEntity<>(responseData.toString(), null, HttpStatus.OK);
    } else if ("PARAM_ERR".equals(procResult)) {
      status = HttpStatus.BAD_REQUEST;
    }
    return new ResponseEntity<>(responseData.toString(), null, status);
  }

  /**
   * ind_medi_info中止処理
   *
   * @param bodyData 必要パラメータの記載されたJson文字列
   * @return 更新結果
   */
  @PostMapping("/medications/delete")
  public ResponseEntity<String> deleteOrdMainMediInfo(
    @Validated @RequestBody ApiEntityOrdMain.ValiOrdMedi bodyData,
    BindingResult validationResult
  ) throws URISyntaxException, JSONException, ArrayIndexOutOfBoundsException {
    long patId = Long.parseLong(bodyData.getPat_id());
    String facilityCd = bodyData.getFacility_cd();
    PatMain patMain = patMainDao.selectById(patId);
    // チェック：スケジュール延長処理中の場合、治療条件変更を中止する
    String scheduleExtensionMsg = ordMainCondInfoCheck
      .validateScheduleExtension(bodyData.getIs_deadline(), patMain.getSch_ext_status());
    if (StringUtils.isNotEmpty(scheduleExtensionMsg)) {
      return new ResponseEntity<>(scheduleExtensionMsg, HttpStatus.OK);
    }

    JSONObject responseData = new JSONObject("{}");
    HttpStatus status = HttpStatus.OK;

    // 選択された曜日の処理
    String startDate = bodyData.getStart_date().replaceAll("-", "");
    String endDate = bodyData.getEnd_date().replaceAll("-", "");
    List<OrdMain> updatePreOrdMains = List.of();
    try {
      // 更新対象ordNo List取得
      updatePreOrdMains = ordMainDao.selectUpdateTarget(
        patId,
        facilityCd,
        startDate,
        endDate,
        List.of(0),
        List.of(),
        List.of(),
        null
      );

      if ("2".equals(bodyData.getUpdate_flag())) {
        updatePreOrdMains = updatePreOrdMains.stream()
          .filter(ord -> "0".equals(ord.getRstDialysisState())).collect(Collectors.toList());
      }
      if (updatePreOrdMains.isEmpty()) {
        return new ResponseEntity<>(responseData.toString(), null, status);
      }
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (bodyData != null && bodyData.getFacility_cd() != null) {
        eventLogMessage.setFacilityCd(bodyData.getFacility_cd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
    }

    // main DB 処理
    OrdMainResponse response;
    try {
      // ord_main及び関連テーブル更新処理
      response = ordMainMediInfoService.deleteOrdMainMediInfo(bodyData, updatePreOrdMains);
    } catch (Exception e) {
      //エラー
      EventLogMessage elm = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      elm.setLogMessage(ExcetionStackTraceToString(e));
      if (bodyData != null && bodyData.getFacility_cd() != null) {
        elm.setFacilityCd(bodyData.getFacility_cd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, elm, LoggingConstant.FUNCTION_CODE.FUNC_PAT_VIEWER, LoggingConstant.SERVICE_NAME.FNSI, null);
      status = HttpStatus.INTERNAL_SERVER_ERROR;
      return new ResponseEntity<>(e.getMessage(), status);
    }

    String procResult = response.getProcResult();
    if ("SUCCESS".equals(procResult)) {

      List<OrdMain> updatedOrdMainList = new ArrayList<>();
      Map<String, List<Object>> resultAllChangedDataInfoList = response.getResultAllChangedDataInfoList();
      if (resultAllChangedDataInfoList.containsKey("ord_main") && !resultAllChangedDataInfoList.get("ord_main").isEmpty()) {
        List<Object> ordMainObjects = resultAllChangedDataInfoList.get("ord_main");
        for (Object obj : ordMainObjects) {
          OrdMain ordMain = (OrdMain) obj;
          updatedOrdMainList.add(ordMain);
        }
      }

      List<Long> updatedOrdNoList = updatedOrdMainList.stream().map(OrdMain::getOrdNo).collect(Collectors.toList());
      updatePreOrdMains = updatePreOrdMains.stream().filter(pre -> updatedOrdNoList.contains(pre.getOrdNo())).toList();

      //指示履歴を登録
      try {
        List<Integer> weeksArray = IndicationUtils.getWeekPattern(bodyData.getWeeks());
        indHistoryMakeService.createMedicineHistory(bodyData, "2", weeksArray, updatePreOrdMains);
      } catch (Exception e) {
        //エラー
        EventLogMessage elm = new EventLogMessage();
        elm.setLogMessage("指示履歴登録処理 MongoDB " + e.getMessage());
        logService.log(LogLevel.ERROR, elm, LoggingConstant.FUNCTION_CODE.FUNC_PAT_VIEWER, LoggingConstant.SERVICE_NAME.FNSI, null);
      }

      // ord_main_hst
      try {
        selectHistoryUtils.insertMangoDbHistoryBatch(updatedOrdNoList);
      } catch (Exception e) {
        //エラー
        EventLogMessage elm = new EventLogMessage();
        elm.setLogMessage("ord_main変更履歴登録 MongoDB " + e.getMessage());
        logService.log(LogLevel.ERROR, elm, LoggingConstant.FUNCTION_CODE.FUNC_PAT_VIEWER, LoggingConstant.SERVICE_NAME.FNSI, null);
      }

      // 連携関連呼出
      try {
        callCreateJournalWithMediEquip(updatePreOrdMains, facilityCd, bodyData.getHosp_pat_id(),
          patId, bodyData.getInd_info(), "004115", "004025");
      } catch (Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
        //エラー
        EventLogMessage elm = new EventLogMessage();
        elm.setLogMessage("連携関連呼出 " + e.getMessage());
        logService.log(LogLevel.ERROR, elm, LoggingConstant.FUNCTION_CODE.FUNC_PAT_VIEWER, LoggingConstant.SERVICE_NAME.FNSI, null);
      }

      // 次患者情報１、次患者情報２にたいして変更が発生しているかをチェックし、次患者情報呼び出し統合処理を呼び出す

      try {
        nextPatService.CallNextPatChange(facilityCd, nextPatService.FilterNextPatInfo1or2ChangedForOrdMain(facilityCd, updatePreOrdMains));
      } catch (Exception e) {
        //エラー
        EventLogMessage elm = new EventLogMessage();
        elm.setLogMessage("サービスの新しい次患者更新呼出統合処理を呼び出す " + e.getMessage());
        logService.log(LogLevel.ERROR, elm, LoggingConstant.FUNCTION_CODE.FUNC_PAT_VIEWER, LoggingConstant.SERVICE_NAME.FNSI, null);
      }

      return new ResponseEntity<>(responseData.toString(), null, HttpStatus.OK);
    } else if ("PARAM_ERR".equals(procResult)) {
      status = HttpStatus.BAD_REQUEST;
    }
    return new ResponseEntity<>(responseData.toString(), null, status);
  }

  private void callCreateJournalWithMediEquip(List<OrdMain> updatePreOrdMainList, String facilityCd,
                                              String hospPatId, long patId, String indInfo,
                                              String opeCdWithKurNull, String opeCdWithKurNonNull) {
    List<Integer> treatCdList = updatePreOrdMainList.stream().map(OrdMain::getIndTreatmentCd).distinct().toList();
    List<MstTreatment> mstTreatList = treatCdList.stream().map(treatCd -> mstTreatmentDao.selectByCd(treatCd)).toList();
    List<JournalCreateRequestPayload> ctlNoList = new ArrayList<>();
    for (MstTreatment mstTreat : mstTreatList) {
      List<OrdMain> ordMainList = updatePreOrdMainList.stream()
        .filter(o -> o.getIndTreatmentCd().equals(mstTreat.getTreatmentCd())).toList();
      if (!ordMainList.isEmpty()) {
        // オペコードを設定する
        String opeCd;
        for (OrdMain ord : ordMainList) {
          if (ord.getIndKurCd() == null || ord.getIndKurCd().equals(0)) {
            opeCd = opeCdWithKurNull;
          } else {
            opeCd = opeCdWithKurNonNull;
          }
          JournalCreateRequestPayload journalCreateRequestPayload = new JournalCreateRequestPayload();
          journalCreateRequestPayload.setFacilityCd(facilityCd);
          journalCreateRequestPayload.setCrud("U");
          journalCreateRequestPayload.setHospPatId(hospPatId);
          journalCreateRequestPayload.setPatId(patId);
          JSONObject indInfoJson = new JSONObject(indInfo);
          journalCreateRequestPayload.setUserId(Long.valueOf(indInfoJson.get("ind_user_id").toString()));
          journalCreateRequestPayload.setOpeCd(opeCd);
          journalCreateRequestPayload.setOrdNo(ord.getOrdNo());
          journalCreateRequestPayload.setBaseDate(ord.getTreatDate());
          ctlNoList.add(journalCreateRequestPayload);
        }
      }
    }
    journalService.callCreateJournalForCtrNo(ctlNoList);
  }
  // add #12471 ord_main.ind_medi_infoに不正データが登録される zkm end

  // add #12455 条件送信後に医材変更＆実績反映すると数量が0になる zkm start
  /**
   * 医材一括追加
   *
   * @param bodyDataList 追加情報
   * @return ResponseEntity
   */
  @PostMapping("/equip/create")
  public ResponseEntity<String> createOrdMainEquipInfoBatch(
    @Validated @RequestBody List<ApiEntityOrdMain.ValiOrdEquip> bodyDataList) {

    ApiEntityOrdMain.ValiOrdEquip valiOrdEquip = bodyDataList.get(0);
    long patId = Long.parseLong(valiOrdEquip.getPat_id());
    String facilityCd = valiOrdEquip.getFacility_cd();
    PatMain patMain = patMainDao.selectById(patId);
    // チェック：スケジュール延長処理中の場合、治療条件変更を中止する
    String scheduleExtensionMsg = ordMainCondInfoCheck
      .validateScheduleExtension(valiOrdEquip.getIs_deadline(), patMain.getSch_ext_status());
    if (StringUtils.isNotEmpty(scheduleExtensionMsg)) {
      return new ResponseEntity<>(scheduleExtensionMsg, HttpStatus.OK);
    }

    HttpStatus status = HttpStatus.OK;

    // main DB 処理
    OrdMainResponse response;
    try {
      response = ordMainEquipInfoService.createOrdMainEquipInfo(bodyDataList);
    } catch (Exception e) {
      //エラー
      EventLogMessage elm = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      elm.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, elm, LoggingConstant.FUNCTION_CODE.FUNC_PAT_VIEWER, LoggingConstant.SERVICE_NAME.FNSI, null);
      status = HttpStatus.INTERNAL_SERVER_ERROR;
      return new ResponseEntity<>(e.getMessage(), status);
    }

    JSONObject responseData = new JSONObject("{}");
    String procResult = response.getProcResult();
    if ("SUCCESS".equals(procResult)) {
      // 更新前ord_mainリストを取得する
      List<OrdMain> updatePreOrdMainList = new ArrayList<>();
      Map<String, List<Object>> resultAllChangeBeforeDataInfoList = response.getResultAllChangeBeforeDataInfoList();
      if (resultAllChangeBeforeDataInfoList.containsKey("ord_main")
        && !resultAllChangeBeforeDataInfoList.get("ord_main").isEmpty()) {
        List<Object> ordMainObjects = resultAllChangeBeforeDataInfoList.get("ord_main");
        for (Object obj : ordMainObjects) {
          OrdMain ordMain = (OrdMain) obj;
          updatePreOrdMainList.add(ordMain);
        }
      }

      ApiEntityOrdMain.ValiOrdEquip firstBodyData = bodyDataList.get(0);
      if (indHistoryMakeService.isToMongo()) {
        String setLogDate = LocalDateTime.now()
          .format(DateTimeFormatter.ofPattern("yyyyMMddHHmmssSSS"));
        List<IndHistory> indHistoryList = new ArrayList<>();
        List<Integer> weeksArray = IndicationUtils.getWeekPattern(firstBodyData.getWeeks());
        for (ApiEntityOrdMain.ValiOrdEquip bodyData : bodyDataList) {
          //指示履歴用パラメータ
          IndHistory indHistory = indHistoryMakeService
            .createEquipmentHistoryParams(bodyData, "1", weeksArray, new ArrayList<>());
          //指示履歴時刻設定
          indHistory.setLogDate(setLogDate);
          indHistoryList.add(indHistory);
        }
        if (!indHistoryList.isEmpty()) {
          //指示履歴登録処理
          indHistoryMakeService.createHistoryExecuteBatch(indHistoryList, "1");
        }
      }

      // ord_main_hst
      try {
        selectHistoryUtils.insertMangoDbHistoryBatch(updatePreOrdMainList.stream().map(OrdMain::getOrdNo).toList());
      } catch (Exception e) {
        //エラー
        EventLogMessage elm = new EventLogMessage();
        elm.setLogMessage("ord_main変更履歴登録 MongoDB " + e.getMessage());
        logService.log(LogLevel.ERROR, elm, LoggingConstant.FUNCTION_CODE.FUNC_PAT_VIEWER, LoggingConstant.SERVICE_NAME.FNSI, null);
      }

      // 連携関連呼出
      try {
        callCreateJournalWithMediEquip(updatePreOrdMainList, facilityCd, firstBodyData.getHosp_pat_id(),
          patId, firstBodyData.getInd_info(), "004226", "004026");
      } catch (Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
        //エラー
        EventLogMessage elm = new EventLogMessage();
        elm.setLogMessage("連携関連呼出 " + e.getMessage());
        logService.log(LogLevel.ERROR, elm, LoggingConstant.FUNCTION_CODE.FUNC_PAT_VIEWER, LoggingConstant.SERVICE_NAME.FNSI, null);
      }

      // 次患者
      try {
        nextPatService.CallNextPatChange(facilityCd, nextPatService.FilterNextPatInfo1or2ChangedForOrdMain(facilityCd, updatePreOrdMainList));
      } catch (Exception e) {
        //エラー
        EventLogMessage elm = new EventLogMessage();
        elm.setLogMessage("サービスの新しい次患者更新呼出統合処理を呼び出す " + e.getMessage());
        logService.log(LogLevel.ERROR, elm, LoggingConstant.FUNCTION_CODE.FUNC_PAT_VIEWER, LoggingConstant.SERVICE_NAME.FNSI, null);
      }
    }
    return new ResponseEntity<>(responseData.toString(), null, status);
  }

  /**
   * ind_equip_info更新処理
   *
   * @param bodyData 必要パラメータの記載されたJson文字列
   * @return 更新結果
   * @throws URISyntaxException
   */
  @PostMapping("/equip/update")
  public ResponseEntity<String> updateOrdMainEquipInfo(
    @Validated @RequestBody ApiEntityOrdMain.ValiOrdEquip bodyData, BindingResult validationResult
  ) throws URISyntaxException, JSONException, ArrayIndexOutOfBoundsException {
    long patId = Long.parseLong(bodyData.getPat_id());
    String facilityCd = bodyData.getFacility_cd();
    PatMain patMain = patMainDao.selectById(patId);
    // チェック：スケジュール延長処理中の場合、治療条件変更を中止する
    String scheduleExtensionMsg = ordMainCondInfoCheck
      .validateScheduleExtension(bodyData.getIs_deadline(), patMain.getSch_ext_status());
    if (StringUtils.isNotEmpty(scheduleExtensionMsg)) {
      return new ResponseEntity<>(scheduleExtensionMsg, HttpStatus.OK);
    }

    JSONObject responseData = new JSONObject("{}");
    HttpStatus status = HttpStatus.OK;

    // 選択された曜日の処理
    String startDate = bodyData.getStart_date().replaceAll("-", StringUtils.EMPTY);
    String endDate = bodyData.getEnd_date().replaceAll("-", StringUtils.EMPTY);
    List<Integer> weeksArray = IndicationUtils.getWeekPattern(bodyData.getWeeks());
    List<Integer> indTreatmentCds = new ArrayList<>();
    List<Long> indKurCds = new ArrayList<>();
    try {
      indTreatmentCds = CommonUtils.getValueList(bodyData.getInd_treatment_cd());
      indKurCds = CommonUtils.getLongList(bodyData.getInd_kur_cd());
    } catch (JSONException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("エラー発生：" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, StringUtils.EMPTY, LoggingConstant.SERVICE_NAME.FNSI, null);
    }
    List<OrdMain> updatePreOrdMains = List.of();
    try {
      // 更新対象ordNo List取得
      updatePreOrdMains = ordMainDao.selectUpdateTarget(
        patId,
        facilityCd,
        startDate,
        endDate,
        weeksArray,
        indTreatmentCds,
        indKurCds,
        null
      );

      if ("2".equals(bodyData.getUpdate_flag())) {
        updatePreOrdMains = updatePreOrdMains.stream()
          .filter(ord -> "0".equals(ord.getRstDialysisState())).collect(Collectors.toList());
      }
      if (updatePreOrdMains.isEmpty()) {
        return new ResponseEntity<>(responseData.toString(), null, status);
      }
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (bodyData != null && bodyData.getFacility_cd() != null) {
        eventLogMessage.setFacilityCd(bodyData.getFacility_cd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
    }

    // main DB 処理
    OrdMainResponse response;
    try {
      // ord_main及び関連テーブル更新処理
      response = ordMainEquipInfoService.updateOrdMainEquipInfo(bodyData, updatePreOrdMains);
    } catch (Exception e) {
      //エラー
      EventLogMessage elm = new EventLogMessage();
      elm.setLogMessage(e.getMessage());
      logService.log(LogLevel.ERROR, elm, LoggingConstant.FUNCTION_CODE.FUNC_PAT_VIEWER, LoggingConstant.SERVICE_NAME.FNSI, null);
      status = HttpStatus.INTERNAL_SERVER_ERROR;
      return new ResponseEntity<>(e.getMessage(), status);
    }

    String procResult = response.getProcResult();
    if ("SUCCESS".equals(procResult)) {

      // responseに更新前ord_mainリストを補足する
      List<OrdMain> updatedOrdMainList = new ArrayList<>();
      Map<String, List<Object>> resultAllChangedDataInfoList = response.getResultAllChangedDataInfoList();
      if (resultAllChangedDataInfoList.containsKey("ord_main") && !resultAllChangedDataInfoList.get("ord_main").isEmpty()) {
        List<Object> ordMainObjects = resultAllChangedDataInfoList.get("ord_main");
        for (Object obj : ordMainObjects) {
          OrdMain ordMain = (OrdMain) obj;
          updatedOrdMainList.add(ordMain);
        }
      }

      // 更新されたOrdMain List
      List<Long> updatedOrdNoList = updatedOrdMainList.stream().map(OrdMain::getOrdNo).collect(Collectors.toList());
      updatePreOrdMains = updatePreOrdMains.stream().filter(pre -> updatedOrdNoList.contains(pre.getOrdNo())).toList();

      //指示履歴を登録
      try {
        if(indHistoryMakeService.isToMongo()){
          indHistoryMakeService.createEquipmentHistory(bodyData, "2", weeksArray, updatePreOrdMains);
        }
      } catch (Exception e) {
        //エラー
        EventLogMessage elm = new EventLogMessage();
        elm.setLogMessage("指示履歴登録処理 MongoDB " + e.getMessage());
        logService.log(LogLevel.ERROR, elm, LoggingConstant.FUNCTION_CODE.FUNC_PAT_VIEWER, LoggingConstant.SERVICE_NAME.FNSI, null);
      }

      // ord_main_hst
      try {
        selectHistoryUtils.insertMangoDbHistoryBatch(updatedOrdNoList);
      } catch (Exception e) {
        //エラー
        EventLogMessage elm = new EventLogMessage();
        elm.setLogMessage("ord_main変更履歴登録 MongoDB " + e.getMessage());
        logService.log(LogLevel.ERROR, elm, LoggingConstant.FUNCTION_CODE.FUNC_PAT_VIEWER, LoggingConstant.SERVICE_NAME.FNSI, null);
      }

      String hospPatId = bodyData.getHosp_pat_id();
      // 連携関連呼出
      try {
        callCreateJournalWithMediEquip(updatePreOrdMains, facilityCd, hospPatId,
          patId, bodyData.getInd_info(), "004227", "004027");
      } catch (Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang ende.printStackTrace();
        //エラー
        EventLogMessage elm = new EventLogMessage();
        elm.setLogMessage("連携関連呼出 " + e.getMessage());
        logService.log(LogLevel.ERROR, elm, LoggingConstant.FUNCTION_CODE.FUNC_PAT_VIEWER, LoggingConstant.SERVICE_NAME.FNSI, null);
      }

      // 次患者情報１、次患者情報２にたいして変更が発生しているかをチェックし、次患者情報呼び出し統合処理を呼び出す
      try {
        nextPatService.CallNextPatChange(facilityCd, nextPatService.FilterNextPatInfo1or2ChangedForOrdMain(facilityCd, updatePreOrdMains));
      } catch (Exception e) {
        //エラー
        EventLogMessage elm = new EventLogMessage();
        elm.setLogMessage("サービスの新しい次患者更新呼出統合処理を呼び出す " + e.getMessage());
        logService.log(LogLevel.ERROR, elm, LoggingConstant.FUNCTION_CODE.FUNC_PAT_VIEWER, LoggingConstant.SERVICE_NAME.FNSI, null);
      }

      return new ResponseEntity<>(responseData.toString(), null, HttpStatus.OK);
    } else if ("PARAM_ERR".equals(procResult)) {
      status = HttpStatus.BAD_REQUEST;
    }
    return new ResponseEntity<>(responseData.toString(), null, status);
  }

  /**
   * ind_equip_info中止処理
   *
   * @param bodyData 必要パラメータの記載されたJson文字列
   * @return 更新結果
   * @throws URISyntaxException
   */
  @PostMapping("/equip/delete")
  public ResponseEntity<String> deleteOrdMainEquipInfo(
    @Validated @RequestBody ApiEntityOrdMain.ValiOrdEquip bodyData,
    BindingResult validationResult
  ) throws URISyntaxException, JSONException, ArrayIndexOutOfBoundsException {
    long patId = Long.parseLong(bodyData.getPat_id());
    String facilityCd = bodyData.getFacility_cd();
    PatMain patMain = patMainDao.selectById(patId);
    // チェック：スケジュール延長処理中の場合、治療条件変更を中止する
    String scheduleExtensionMsg = ordMainCondInfoCheck
      .validateScheduleExtension(bodyData.getIs_deadline(), patMain.getSch_ext_status());
    if (StringUtils.isNotEmpty(scheduleExtensionMsg)) {
      return new ResponseEntity<>(scheduleExtensionMsg, HttpStatus.OK);
    }

    JSONObject responseData = new JSONObject("{}");
    HttpStatus status = HttpStatus.OK;

    // 選択された曜日の処理
    String startDate = bodyData.getStart_date().replaceAll("-", StringUtils.EMPTY);
    String endDate = bodyData.getEnd_date().replaceAll("-", StringUtils.EMPTY);
    List<Integer> weeksArray = IndicationUtils.getWeekPattern(bodyData.getWeeks());
    List<Integer> indTreatmentCds = new ArrayList<>();
    List<Long> indKurCds = new ArrayList<>();
    try {
      indTreatmentCds = CommonUtils.getValueList(bodyData.getInd_treatment_cd());
      indKurCds = CommonUtils.getLongList(bodyData.getInd_kur_cd());
    } catch (JSONException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("エラー発生：" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, StringUtils.EMPTY, LoggingConstant.SERVICE_NAME.FNSI, null);
    }

    List<OrdMain> updatePreOrdMains = List.of();
    try {
      // 更新対象ordNo List取得
      updatePreOrdMains = ordMainDao.selectUpdateTarget(
        patId,
        facilityCd,
        startDate,
        endDate,
        weeksArray,
        indTreatmentCds,
        indKurCds,
        null
      );

      if ("2".equals(bodyData.getUpdate_flag())) {
        updatePreOrdMains = updatePreOrdMains.stream()
          .filter(ord -> "0".equals(ord.getRstDialysisState())).collect(Collectors.toList());
      }
      if (updatePreOrdMains.isEmpty()) {
        return new ResponseEntity<>(responseData.toString(), null, status);
      }
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (bodyData != null && bodyData.getFacility_cd() != null) {
        eventLogMessage.setFacilityCd(bodyData.getFacility_cd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
    }

    // main DB 処理
    OrdMainResponse response;
    try {
      // ord_main及び関連テーブル更新処理
      response = ordMainEquipInfoService.deleteOrdMainEquipInfo(bodyData, updatePreOrdMains);
    } catch (Exception e) {
      //エラー
      EventLogMessage elm = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      elm.setLogMessage(ExcetionStackTraceToString(e));
      if (bodyData != null && bodyData.getFacility_cd() != null) {
        elm.setFacilityCd(bodyData.getFacility_cd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, elm, LoggingConstant.FUNCTION_CODE.FUNC_PAT_VIEWER, LoggingConstant.SERVICE_NAME.FNSI, null);
      status = HttpStatus.INTERNAL_SERVER_ERROR;
      return new ResponseEntity<>(e.getMessage(), status);
    }

    String procResult = response.getProcResult();
    if ("SUCCESS".equals(procResult)) {

      List<OrdMain> updatedOrdMainList = new ArrayList<>();
      Map<String, List<Object>> resultAllChangedDataInfoList = response.getResultAllChangedDataInfoList();
      if (resultAllChangedDataInfoList.containsKey("ord_main") && !resultAllChangedDataInfoList.get("ord_main").isEmpty()) {
        List<Object> ordMainObjects = resultAllChangedDataInfoList.get("ord_main");
        for (Object obj : ordMainObjects) {
          OrdMain ordMain = (OrdMain) obj;
          updatedOrdMainList.add(ordMain);
        }
      }

      List<Long> updatedOrdNoList = updatedOrdMainList.stream().map(OrdMain::getOrdNo).collect(Collectors.toList());
      updatePreOrdMains = updatePreOrdMains.stream().filter(pre -> updatedOrdNoList.contains(pre.getOrdNo())).toList();

      //指示履歴を登録
      try {
        indHistoryMakeService.createEquipmentHistory(bodyData, "3", weeksArray, updatePreOrdMains);
      } catch (Exception e) {
        //エラー
        EventLogMessage elm = new EventLogMessage();
        elm.setLogMessage("指示履歴登録処理 MongoDB " + e.getMessage());
        logService.log(LogLevel.ERROR, elm, LoggingConstant.FUNCTION_CODE.FUNC_PAT_VIEWER, LoggingConstant.SERVICE_NAME.FNSI, null);
      }

      // ord_main_hst
      try {
        selectHistoryUtils.insertMangoDbHistoryBatch(updatedOrdNoList);
      } catch (Exception e) {
        //エラー
        EventLogMessage elm = new EventLogMessage();
        elm.setLogMessage("ord_main変更履歴登録 MongoDB " + e.getMessage());
        logService.log(LogLevel.ERROR, elm, LoggingConstant.FUNCTION_CODE.FUNC_PAT_VIEWER, LoggingConstant.SERVICE_NAME.FNSI, null);
      }

      // 連携関連呼出
      try {
        callCreateJournalWithMediEquip(updatePreOrdMains, facilityCd, bodyData.getHosp_pat_id(),
          patId, bodyData.getInd_info(), "004228", "004028");
      } catch (Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
        //エラー
        EventLogMessage elm = new EventLogMessage();
        elm.setLogMessage("連携関連呼出 " + e.getMessage());
        logService.log(LogLevel.ERROR, elm, LoggingConstant.FUNCTION_CODE.FUNC_PAT_VIEWER, LoggingConstant.SERVICE_NAME.FNSI, null);
      }

      // 次患者情報１、次患者情報２にたいして変更が発生しているかをチェックし、次患者情報呼び出し統合処理を呼び出す

      try {
        nextPatService.CallNextPatChange(facilityCd, nextPatService.FilterNextPatInfo1or2ChangedForOrdMain(facilityCd, updatePreOrdMains));
      } catch (Exception e) {
        //エラー
        EventLogMessage elm = new EventLogMessage();
        elm.setLogMessage("サービスの新しい次患者更新呼出統合処理を呼び出す " + e.getMessage());
        logService.log(LogLevel.ERROR, elm, LoggingConstant.FUNCTION_CODE.FUNC_PAT_VIEWER, LoggingConstant.SERVICE_NAME.FNSI, null);
      }

      return new ResponseEntity<>(responseData.toString(), null, HttpStatus.OK);
    } else if ("PARAM_ERR".equals(procResult)) {
      status = HttpStatus.BAD_REQUEST;
    }
    return new ResponseEntity<>(responseData.toString(), null, status);
  }
  // add #12455 条件送信後に医材変更＆実績反映すると数量が0になる zkm end
}
