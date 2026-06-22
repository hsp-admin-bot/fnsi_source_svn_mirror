package jp.co.nikkiso.ntss.admin_web.service.ordmain;

import tools.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.response.ordMain.OrdMainResponse;
import jp.co.nikkiso.ntss.admin_web.service.OrdMainService;
import jp.co.nikkiso.ntss.admin_web.service.PatInfoService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.ordmain.util.CommonUtils;
import jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.model.PatTreatmentPatternDelta;
import jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.model.PatTreatmentPatternFieldEnum;
import jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.model.PatTreatmentPatternJsonbField;
import jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.model.PatTreatmentPatternKey;
import jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.model.PatTreatmentPatternUpdateModeEnum;
import jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.model.PatTreatmentPatternUpsert;
import jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.service.PatTreatmentPatternService;
import jp.co.nikkiso.ntss.admin_web.service.utils.MasterCacheHandler;
import jp.co.nikkiso.ntss.admin_web.service.utils.StrUtils;
import jp.co.nikkiso.ntss.admin_web.web.rest.OrdMainResource;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.IndicationUtils;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallCommonUtil;
import jp.co.nikkiso.ntss.admin_web.web.rest.validation.ApiEntityOrdMain;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.DBAppWebAPIDao;
import jp.co.nikkiso.ntss.core.dao.OrdChecklistDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatIndApproveDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.entity.MedicineLatestNo;
import jp.co.nikkiso.ntss.core.entity.MstMedicateTiming;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatIndApprove;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.PatTreatmentPattern;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.service.ordMaterialSaveService.OrdMaterialSaveService;
import org.apache.commons.lang3.StringUtils;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.ObjectUtils;

import jakarta.annotation.Resource;
import java.net.URISyntaxException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.concurrent.ExecutorService;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Service
public class OrdMainMediInfoServiceImpl implements OrdMainMediInfoService {

  @Autowired
  private OrdMainDao ordMainDao;
  @Autowired
  private PatIndApproveDao patIndApproveDao;
  @Autowired
  private OrdChecklistDao ordChecklistDao;
  @Autowired
  private WebApiCallCommonUtil webApiCallCommonUtil;
  @Autowired
  private PatInfoService patInfoService;
  @Autowired
  OrdMainService ordMainService;
  @Autowired
  private LogService logService;
  @Autowired
  private PatPersonalMainDao patPersonalMainDao;
  @Autowired
  private OrdMaterialSaveService ordMaterialSaveService;
  @Autowired
  private PatTreatmentPatternService patTreatmentPatternService;
  @Autowired
  private DBAppWebAPIDao dBAppWebAPIDao;
  @Resource(name = "crawlExecutorPool")
  private ExecutorService threadExecutor;

  @Transactional
  @Override
  public OrdMainResponse createOrdMainMediInfo(List<ApiEntityOrdMain.ValiOrdMedi> bodyDataList) {
    OrdMainResponse response = new OrdMainResponse();
    ApiEntityOrdMain.ValiOrdMedi firstBodyData = bodyDataList.get(0);
    // 選択された日付+曜日の処理
    String startDate = firstBodyData.getStart_date().replaceAll("-", "");
    String endDate = firstBodyData.getEnd_date().replaceAll("-", "");
    String facilityCd = firstBodyData.getFacility_cd();
    String patId = firstBodyData.getPat_id();
    List<Integer> weeksArray = IndicationUtils.getWeekPattern(firstBodyData.getWeeks());
    String ind_user_id = null;
    String upd_user_id = null;
    List<OrdMain> updatePreOrdMains = new ArrayList<>();

    List<Integer> indTreatmentCds = new ArrayList<>();
    List<Long> indKurCds = new ArrayList<>();
    try {
      indTreatmentCds = CommonUtils.getValueList(firstBodyData.getInd_treatment_cd());
      indKurCds = CommonUtils.getLongList(firstBodyData.getInd_kur_cd());
    } catch (JSONException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("エラー発生：" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, StringUtils.EMPTY, LoggingConstant.SERVICE_NAME.FNSI, null);
    }

    // event log更新用
    Map<String, List<Object>> resultAllChangedDataInfoList = new HashMap<>();
    Map<String, List<Object>> resultAllChangeBeforeDataInfoList = new HashMap<>();

    try {
      // 更新対象ordNo List取得
      updatePreOrdMains = ordMainDao.selectUpdateTarget(
        Long.parseLong(firstBodyData.getPat_id()),
        firstBodyData.getFacility_cd(),
        startDate,
        endDate,
        weeksArray,
        indTreatmentCds,
        indKurCds,
        null
      );
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (!StringUtils.isEmpty(facilityCd)) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang end
    }

    if ("2".equals(firstBodyData.getUpdate_flag())) {
      updatePreOrdMains = updatePreOrdMains.stream().filter(ord -> "0".equals(ord.getRstDialysisState())).collect(Collectors.toList());
    }

    JSONArray ordDatesJson = new JSONArray(firstBodyData.getInd_dates());
    Set<String> ordDates = IntStream.range(0, ordDatesJson.length())
      .mapToObj(ordDatesJson::getString)
      .collect(Collectors.toUnmodifiableSet());
    updatePreOrdMains = updatePreOrdMains.stream()
      .filter(o -> ordDates.contains(o.getTreatDate())).toList();

    if (updatePreOrdMains.isEmpty()) {
      return response;
    }

    CommonUtils.addToMapList(resultAllChangeBeforeDataInfoList, "ord_main", updatePreOrdMains);

    // 変更内容を実績にも反映する
    String isRstUpdate = firstBodyData.getIs_rst_update();

    List<Long> updateOrdNoList = updatePreOrdMains.stream().map(OrdMain::getOrdNo).collect(Collectors.toList());
    // medicine_latest_noからmedi_info_noを取得する
    Long mediInfoNo = ordMainDao.lockMaxIndMediInfoNo(facilityCd, patId);
    LocalDateTime now = LocalDateTime.now();
    Timestamp nowTs = Timestamp.valueOf(now);
    ordMainDao.updatePatMedicineNo(
      new MedicineLatestNo(firstBodyData.getFacility_cd(), Long.valueOf(firstBodyData.getPat_id()),
        bodyDataList.size(), nowTs, nowTs
        , AdminWebConstant.FlagType.FLAG_ON, AdminWebConstant.FlagType.FLAG_OFF)
    );
    Map<Long, String> mediNoMap = new HashMap<>();

    MasterCacheHandler masterCacheHandler = MasterCacheHandler.get();

    MstPersonalUser effectUserInfo = null;
    // 治療中
    boolean isInTreatment = updatePreOrdMains.stream().anyMatch(o -> "3".equals(o.getRstDialysisState()));
    if (Boolean.parseBoolean(isRstUpdate) && isInTreatment) {
      FacilitySettingInfo facilitySettingInfo = masterCacheHandler.getFacilitySettingInfo(facilityCd, "3020");
      if (facilitySettingInfo != null && facilitySettingInfo.getValue() != null) {
        effectUserInfo = masterCacheHandler.getMstPersonalUser(Long.parseLong(facilitySettingInfo.getValue()));
      }
    }

    JSONArray addMediJson = new JSONArray();
    for (ApiEntityOrdMain.ValiOrdMedi bodyData : bodyDataList) {
      JSONObject editMediJson = new JSONObject(bodyData.getInd_info());
      if (null == upd_user_id) {
        upd_user_id = StrUtils.getStrFromJSONObject(editMediJson, "upd_user_id");
        ind_user_id = StrUtils.getStrFromJSONObject(editMediJson, "ind_user_id");
        editMediJson.put("ind_user_id", Long.valueOf(ind_user_id));
        editMediJson.put("upd_user_id", Long.valueOf(upd_user_id));
      }
      if (null != upd_user_id && !StringUtils.EMPTY.equals(upd_user_id)) {
        MstPersonalUser updMstPersonalUser = masterCacheHandler.getMstPersonalUser(Long.valueOf(upd_user_id));
        if (updMstPersonalUser != null) {
          editMediJson.put("upd_user_last_name", updMstPersonalUser.getUserLastName());
          editMediJson.put("upd_user_first_name", updMstPersonalUser.getUserFirstName());
        }
      }
      mediInfoNo++;
      // シーケンス番号をリユース
      editMediJson.put("no", mediInfoNo);
      if ("false".equals(bodyData.getIs_deadline())) {
        // 投与薬剤情報を格納
        mediNoMap.put(mediInfoNo, StrUtils.getStrFromJSONObject(editMediJson, "cd"));
      }
      if (Boolean.parseBoolean(isRstUpdate) && effectUserInfo != null) {
        // 投与実施者コード
        editMediJson.put("effect_user_id", effectUserInfo.getUserId());
        // 投与実施者名_姓
        editMediJson.put("effect_user_last_name", effectUserInfo.getUserLastName());
        // 投与実施者名_名
        editMediJson.put("effect_user_first_name", effectUserInfo.getUserFirstName());
      }
      addMediJson.put(editMediJson);
    }

    // main db更新
    List<OrdMain> updatedOrdMains = ordMainDao.updateOrdMainMediInfoWithAdd(updateOrdNoList,
      addMediJson.toString(), isRstUpdate, ind_user_id, upd_user_id);

    CommonUtils.addToMapList(resultAllChangedDataInfoList, "ord_main", updatedOrdMains);

    if (updatedOrdMains.isEmpty()) {
      return response;
    }

    if (!mediNoMap.isEmpty()) {
      List<String> updatedMediList = updatedOrdMains.stream().map(OrdMain::getIndMediInfo).toList();
      JSONArray updatedMediJson = new JSONArray();
      Set<Long> addedNoSet = new HashSet<>();
      updatedMediList.forEach(m -> {
        JSONArray indMediJsonArr = new JSONArray(ObjectUtils.isEmpty(m)? "[]" : m);
        for (int i = 0; i < indMediJsonArr.length(); i++) {
          JSONObject jsonObj = indMediJsonArr.getJSONObject(i);
          Long no = Long.parseLong(jsonObj.get("no").toString());

          if (mediNoMap.containsKey(no) && addedNoSet.add(no)) {
            updatedMediJson.put(indMediJsonArr.getJSONObject(i));
          }
        }
      });

      // 必須なパラメータを設定する
      PatTreatmentPatternKey key = new PatTreatmentPatternKey(
        Long.parseLong(patId),
        facilityCd,
        indTreatmentCds,
        indKurCds,
        weeksArray,
        null,
        new HashMap<>()
      );
      PatTreatmentPatternUpsert upsert = new PatTreatmentPatternUpsert(key);
      upsert.addJsonbUpdate(PatTreatmentPatternFieldEnum.IND_MEDI_INFO, new PatTreatmentPatternJsonbField(
        PatTreatmentPatternUpdateModeEnum.MERGE, updatedMediJson.toString()));
      PatTreatmentPatternDelta delta = new PatTreatmentPatternDelta();
      delta.getUpdates().add(upsert);

      // パタン共通を呼びだす
      Map<PatTreatmentPatternService.RESULT_TYPE, List<PatTreatmentPattern>> responseMap =
        patTreatmentPatternService.applyPatTreatmentPatterns(delta);

      // log_event記入用更新前値を設定する
      if (responseMap.containsKey(PatTreatmentPatternService.RESULT_TYPE.OLD)) {
        CommonUtils.addToMapList(resultAllChangeBeforeDataInfoList,
          "pat_treatment_pattern",
          responseMap.get(PatTreatmentPatternService.RESULT_TYPE.OLD));
      }
      // log_event記入用更新後値を設定する
      if (responseMap.containsKey(PatTreatmentPatternService.RESULT_TYPE.NEW)) {
        CommonUtils.addToMapList(resultAllChangedDataInfoList,
          "pat_treatment_pattern",
          responseMap.get(PatTreatmentPatternService.RESULT_TYPE.NEW));
      }
    }

    // ord_checklist
    if (updatedOrdMains.stream().anyMatch(o -> !"0".equals(o.getRstDialysisState()))) {
      ordMainService.updateOrdChecklistByActionBeCurrent(OrdMainResource.OrdMainActionForChecklist.TREATPLAN_MEDICINE_CREATE, updateOrdNoList);
    } else {
      ordChecklistDao.bulkUpdateByOrdNoList(facilityCd, updateOrdNoList);
    }

    // pat_ind_approve更新
    try {
      updateContentChangeSingleWithNotification(updateOrdNoList);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (!StringUtils.isEmpty(facilityCd)) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }

    // ord_material_save更新
    if (Boolean.parseBoolean(isRstUpdate)) {
      ordMaterialSaveService.bulkUpdateByOrdNoInCondMediEquip(updatePreOrdMains.stream().map(OrdMain::getOrdNo).toList());
    } else {
      ordMaterialSaveService.bulkUpdateByOrdNoInMedi(updatePreOrdMains.stream().map(OrdMain::getOrdNo).toList());
    }

    if (isInTreatment) {
      //システム時間を取得
      int sysTimeMin = now.getHour() * 60 + now.getMinute();
      String sysDate = LocalDate.now().format(DateTimeFormatter.BASIC_ISO_DATE);
      List<OrdMain> doRegisterNotificationOrdMains = updatedOrdMains.stream()
        .filter(o -> "3".equals(o.getRstDialysisState()) && o.getTreatDate().equals(sysDate)).toList();
      // 変更内容を実績にも反映する、治療状況が[3]、且つ治療日が今日の場合
      if (Boolean.parseBoolean(isRstUpdate) && !doRegisterNotificationOrdMains.isEmpty()) {
        PatPersonalMain patPersonalMain = null;
        Map<String, Object> namesMap = null;
        OrdMain updatedOrdMain = doRegisterNotificationOrdMains.get(0);
        JSONArray indMediArray = new JSONArray(updatedOrdMain.getIndMediInfo());
        JSONArray rstMediArray = new JSONArray(updatedOrdMain.getRstMediInfo());
        for (int i = 0; i < indMediArray.length(); i++) {
          JSONObject medi = indMediArray.getJSONObject(i);
          Long mediNo = Long.parseLong(medi.get("no").toString());
          if (mediNoMap.containsKey(mediNo)) {
            // システム時間＞＝治療開始時間+投与タイミングの時間の場合、有効な投与タイミングメッセージを通知メッセージテーブルにを登録
            doRegisterNotification(medi, rstMediArray, masterCacheHandler, sysTimeMin,
              updatedOrdMain, patPersonalMain, namesMap);
          }
        }
      }
    }
    response.setResultAllChangeBeforeDataInfoList(resultAllChangeBeforeDataInfoList);
    response.setResultAllChangedDataInfoList(resultAllChangedDataInfoList);
    response.setProcResult("SUCCESS");
    return response;
  }

  @Transactional
  @Override
  public OrdMainResponse updateOrdMainMediInfo(ApiEntityOrdMain.ValiOrdMedi bodyData, List<OrdMain> updatePreOrdMains) {
    OrdMainResponse response = new OrdMainResponse();
    // 選択された日付+曜日の処理
    String facilityCd = bodyData.getFacility_cd();
    String patId = bodyData.getPat_id();
    List<Integer> weeksArray = IndicationUtils.getWeekPattern(bodyData.getWeeks());

    // event log更新用
    Map<String, List<Object>> resultAllChangedDataInfoList = new HashMap<>();
    Map<String, List<Object>> resultAllChangeBeforeDataInfoList = new HashMap<>();

    // 変更内容を実績にも反映する
    String isRstUpdate = bodyData.getIs_rst_update();

    List<Long> updateOrdNoList = updatePreOrdMains.stream().map(OrdMain::getOrdNo).toList();

    JSONObject editMediJson = new JSONObject(bodyData.getInd_info());
    String oldMediNo = editMediJson.get("no").toString();
    LocalDateTime now = LocalDateTime.now();
    Timestamp nowTs = Timestamp.valueOf(now);
    if ("true".equals(bodyData.getIs_edit_other_amount())) {
      // medicine_latest_noからmedi_info_noを取得する
      Long mediInfoNo = ordMainDao.lockMaxIndMediInfoNo(facilityCd, patId);
      ordMainDao.updatePatMedicineNo(
        new MedicineLatestNo(bodyData.getFacility_cd(), Long.valueOf(bodyData.getPat_id()),
          1, nowTs, nowTs
          , AdminWebConstant.FlagType.FLAG_ON, AdminWebConstant.FlagType.FLAG_OFF)
      );

      // シーケンス番号をリユース
      editMediJson.put("no", mediInfoNo + 1);
    }

    MasterCacheHandler masterCacheHandler = MasterCacheHandler.get();
    MstPersonalUser effectUserInfo = null;
    // 治療中
    boolean isInTreatment = updatePreOrdMains.stream().anyMatch(o -> "3".equals(o.getRstDialysisState()));
    if (Boolean.parseBoolean(isRstUpdate) && isInTreatment) {
      FacilitySettingInfo facilitySettingInfo = masterCacheHandler.getFacilitySettingInfo(facilityCd, "3020");
      if (facilitySettingInfo != null && facilitySettingInfo.getValue() != null) {
        effectUserInfo = masterCacheHandler.getMstPersonalUser(Long.parseLong(facilitySettingInfo.getValue()));
      }
    }

    String ind_user_id = StrUtils.getStrFromJSONObject(editMediJson, "ind_user_id");
    String upd_user_id = StrUtils.getStrFromJSONObject(editMediJson, "upd_user_id");
    if (!StringUtils.EMPTY.equals(upd_user_id)) {
      editMediJson.put("ind_user_id", Long.valueOf(ind_user_id));
      editMediJson.put("upd_user_id", Long.valueOf(upd_user_id));
      MstPersonalUser updMstPersonalUser = masterCacheHandler.getMstPersonalUser(Long.valueOf(upd_user_id));
      if (updMstPersonalUser != null) {
        editMediJson.put("upd_user_last_name", updMstPersonalUser.getUserLastName());
        editMediJson.put("upd_user_first_name", updMstPersonalUser.getUserFirstName());
      }
    }
    if (Boolean.parseBoolean(isRstUpdate) && effectUserInfo != null) {
      // 投与実施者コード
      editMediJson.put("effect_user_id", effectUserInfo.getUserId());
      // 投与実施者名_姓
      editMediJson.put("effect_user_last_name", effectUserInfo.getUserLastName());
      // 投与実施者名_名
      editMediJson.put("effect_user_first_name", effectUserInfo.getUserFirstName());
    }

    // main db更新
    List<OrdMain> updatedOrdMains = ordMainDao.updateOrdMainMediInfoWithUpd(
      updateOrdNoList,
      editMediJson.toString(),
      bodyData.getTreat_dates(),
      bodyData.getIs_edit_other_amount(),
      weeksArray,
      oldMediNo,
      isRstUpdate,
      ind_user_id,
      upd_user_id);

    CommonUtils.addToMapList(resultAllChangedDataInfoList, "ord_main", updatedOrdMains);

    if (updatedOrdMains.isEmpty()) {
      return response;
    }

    // pat_treatment_pattern
    if ("false".equals(bodyData.getIs_deadline())) {
      List<Integer> indTreatmentCds = CommonUtils.getValueList(bodyData.getInd_treatment_cd());
      List<Long> indKurCds = CommonUtils.getLongList(bodyData.getInd_kur_cd());
      // 必須なパラメータを設定する
      Map<String, String> otherConditions = new HashMap<>();
      otherConditions.put("old_medi_no", oldMediNo);
      otherConditions.put("is_edit_other_amount", bodyData.getIs_edit_other_amount());
      otherConditions.put("medi_week", String.join(",", weeksArray.stream().map(String::valueOf).toList()));
      PatTreatmentPatternKey key = new PatTreatmentPatternKey(
        Long.parseLong(patId),
        facilityCd,
        indTreatmentCds,
        indKurCds,
        new ArrayList<>(),
        null,
        otherConditions
      );
      PatTreatmentPatternUpsert upsert = new PatTreatmentPatternUpsert(key);
      upsert.addJsonbUpdate(PatTreatmentPatternFieldEnum.IND_MEDI_INFO, new PatTreatmentPatternJsonbField(
        PatTreatmentPatternUpdateModeEnum.MERGE, editMediJson.toString()));
      PatTreatmentPatternDelta delta = new PatTreatmentPatternDelta();
      delta.getUpdates().add(upsert);

      // パタン共通を呼びだす
      Map<PatTreatmentPatternService.RESULT_TYPE, List<PatTreatmentPattern>> responseMap =
        patTreatmentPatternService.applyPatTreatmentPatterns(delta);

      // log_event記入用更新前値を設定する
      if (responseMap.containsKey(PatTreatmentPatternService.RESULT_TYPE.OLD)) {
        CommonUtils.addToMapList(resultAllChangeBeforeDataInfoList,
          "pat_treatment_pattern",
          responseMap.get(PatTreatmentPatternService.RESULT_TYPE.OLD));
      }
      // log_event記入用更新後値を設定する
      if (responseMap.containsKey(PatTreatmentPatternService.RESULT_TYPE.NEW)) {
        CommonUtils.addToMapList(resultAllChangedDataInfoList,
          "pat_treatment_pattern",
          responseMap.get(PatTreatmentPatternService.RESULT_TYPE.NEW));
      }
    }

    List<Long> updatedOrdNoList = updatedOrdMains.stream().map(OrdMain::getOrdNo).toList();

    // ord_checklist
    if (updatedOrdMains.stream().anyMatch(o -> !"0".equals(o.getRstDialysisState()))) {
      ordMainService.updateOrdChecklistByActionBeCurrent(OrdMainResource.OrdMainActionForChecklist.TREATPLAN_MEDICINE_UPDATE, updateOrdNoList);
    } else {
      ordChecklistDao.bulkUpdateByOrdNoList(facilityCd, updateOrdNoList);
    }

    // pat_ind_approve更新
    try {
      updateContentChangeSingleWithNotification(updateOrdNoList);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (!StringUtils.isEmpty(facilityCd)) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }

    // ord_material_save更新
    if (Boolean.parseBoolean(isRstUpdate)) {
      ordMaterialSaveService.bulkUpdateByOrdNoInCondMediEquip(updatedOrdNoList);
    } else {
      ordMaterialSaveService.bulkUpdateByOrdNoInMedi(updatedOrdNoList);
    }

    if (isInTreatment) {
      //システム時間を取得
      int sysTimeMin = now.getHour() * 60 + now.getMinute();
      String sysDate = LocalDate.now().format(DateTimeFormatter.BASIC_ISO_DATE);
      List<OrdMain> doRegisterNotificationOrdMains = updatedOrdMains.stream()
        .filter(o -> "3".equals(o.getRstDialysisState()) && o.getTreatDate().equals(sysDate)).toList();
      if (Boolean.parseBoolean(isRstUpdate) && !doRegisterNotificationOrdMains.isEmpty() ) {

        List<Long> ordMainNoList = doRegisterNotificationOrdMains.stream().map(OrdMain::getOrdNo).toList();

        // 更新前のord_mainをフィルターする
        List<OrdMain> preUpdInTreatmentOrdMains = updatePreOrdMains.stream()
          .filter(o -> ordMainNoList.contains(o.getOrdNo())).toList();

        for (OrdMain o : preUpdInTreatmentOrdMains) {
          Optional<OrdMain> updOrdMainOpt = doRegisterNotificationOrdMains.stream()
            .filter(updOrd -> o.getOrdNo().compareTo(updOrd.getOrdNo()) == 0).findFirst();
          if (updOrdMainOpt.isEmpty()) {
            continue;
          }
          OrdMain updOrdMain = updOrdMainOpt.get();
          // 更新前の投薬情報を取得する
          JSONArray mediJson = new JSONArray(ObjectUtils.isEmpty(o.getIndMediInfo()) ? "[]" : o.getIndMediInfo());
          for (int i = 0; i < mediJson.length(); i++) {
            if (mediJson.getJSONObject(i).get("no").equals(oldMediNo) &&
              !mediJson.getJSONObject(i).get("timing_cd").equals(editMediJson.get("timing_cd"))) {
              PatPersonalMain patPersonalMain = null;
              Map<String, Object> namesMap = null;
              JSONArray rstMediArray = new JSONArray(updOrdMain.getRstMediInfo());
              // システム時間＞＝治療開始時間+投与タイミングの時間の場合、有効な投与タイミングメッセージを通知メッセージテーブルにを登録
              doRegisterNotification(mediJson.getJSONObject(i), rstMediArray, masterCacheHandler, sysTimeMin,
                updOrdMain, patPersonalMain, namesMap);
            }
          }
        }
      }
    }

    response.setResultAllChangeBeforeDataInfoList(resultAllChangeBeforeDataInfoList);
    response.setResultAllChangedDataInfoList(resultAllChangedDataInfoList);
    response.setProcResult("SUCCESS");
    return response;
  }

  @Transactional
  @Override
  public OrdMainResponse deleteOrdMainMediInfo(ApiEntityOrdMain.ValiOrdMedi bodyData, List<OrdMain> updatePreOrdMains) {
    OrdMainResponse response = new OrdMainResponse();
    // 選択された日付+曜日の処理
    String facilityCd = bodyData.getFacility_cd();
    String patId = bodyData.getPat_id();
    // event log更新用
    Map<String, List<Object>> resultAllChangedDataInfoList = new HashMap<>();
    Map<String, List<Object>> resultAllChangeBeforeDataInfoList = new HashMap<>();

    // 変更内容を実績にも反映する
    String isRstUpdate = bodyData.getIs_rst_update();
    List<Long> updateOrdNoList = updatePreOrdMains.stream().map(OrdMain::getOrdNo).toList();
    JSONObject editMediJson = new JSONObject(bodyData.getInd_info());
    String ind_user_id = StrUtils.getStrFromJSONObject(editMediJson, "ind_user_id");
    String upd_user_id = StrUtils.getStrFromJSONObject(editMediJson, "upd_user_id");

    // main db更新
    List<OrdMain> updatedOrdMains = ordMainDao.updateOrdMainMediInfoWithDel(
      updateOrdNoList,
      editMediJson.toString(),
      isRstUpdate,
      ind_user_id,
      upd_user_id);

    CommonUtils.addToMapList(resultAllChangedDataInfoList, "ord_main", updatedOrdMains);

    if (updatedOrdMains.isEmpty()) {
      return response;
    }

    // 条件送信後の治療予定が更新されたチェック
    boolean hasDialysis = updatePreOrdMains.stream()
      .map(OrdMain::getRstDialysisState)
      .map(Integer::parseInt)
      .anyMatch(state -> state > 0);

    if (hasDialysis) {
      response.setMessageList(List.of("22020003"));
    }

    // pat_treatment_pattern
    if ("false".equals(bodyData.getIs_deadline())) {
      // 必須なパラメータを設定する
      Map<String, String> otherConditions = new HashMap<>();
      otherConditions.put("is_medi_stop", "true");
      PatTreatmentPatternKey key = new PatTreatmentPatternKey(
        Long.parseLong(patId),
        facilityCd,
        new ArrayList<>(),
        new ArrayList<>(),
        new ArrayList<>(),
        null,
        otherConditions
      );
      PatTreatmentPatternUpsert upsert = new PatTreatmentPatternUpsert(key);
      upsert.addJsonbUpdate(PatTreatmentPatternFieldEnum.IND_MEDI_INFO, new PatTreatmentPatternJsonbField(
        PatTreatmentPatternUpdateModeEnum.MERGE, editMediJson.toString()));
      PatTreatmentPatternDelta delta = new PatTreatmentPatternDelta();
      delta.getUpdates().add(upsert);

      // パタン共通を呼びだす
      Map<PatTreatmentPatternService.RESULT_TYPE, List<PatTreatmentPattern>> responseMap =
        patTreatmentPatternService.applyPatTreatmentPatterns(delta);

      // log_event記入用更新前値を設定する
      if (responseMap.containsKey(PatTreatmentPatternService.RESULT_TYPE.OLD)) {
        CommonUtils.addToMapList(resultAllChangeBeforeDataInfoList,
          "pat_treatment_pattern",
          responseMap.get(PatTreatmentPatternService.RESULT_TYPE.OLD));
      }
      // log_event記入用更新後値を設定する
      if (responseMap.containsKey(PatTreatmentPatternService.RESULT_TYPE.NEW)) {
        CommonUtils.addToMapList(resultAllChangedDataInfoList,
          "pat_treatment_pattern",
          responseMap.get(PatTreatmentPatternService.RESULT_TYPE.NEW));
      }
    }

    List<Long> updatedOrdNoList = updatedOrdMains.stream().map(OrdMain::getOrdNo).toList();

    // ord_checklist
    ordChecklistDao.bulkUpdateByOrdNoList(facilityCd, updateOrdNoList);

    // pat_ind_approve更新
    try {
      updateContentChangeSingleWithNotification(updateOrdNoList);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (!StringUtils.isEmpty(facilityCd)) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }

    // ord_material_save更新
    if (Boolean.parseBoolean(isRstUpdate)) {
      ordMaterialSaveService.bulkUpdateByOrdNoInCondMediEquip(updatedOrdNoList);
    } else {
      ordMaterialSaveService.bulkUpdateByOrdNoInMedi(updatedOrdNoList);
    }

    response.setResultAllChangeBeforeDataInfoList(resultAllChangeBeforeDataInfoList);
    response.setResultAllChangedDataInfoList(resultAllChangedDataInfoList);
    response.setProcResult("SUCCESS");
    return response;
  }

  private void updateContentChangeSingleWithNotification(List<Long> ordNoList) throws Exception {
    List<OrdMain> ordMainList = ordMainDao.selectByOrdNoList(ordNoList);
    Map<Long, OrdMain> ordMainMap = ordMainList.stream().collect(Collectors.toMap(OrdMain::getOrdNo, o -> o));
    for (Long ordNo : ordNoList) {
      // 指示変更ありフラグの追加処理
      int patUpdateCount = patIndApproveDao.updateContentChangeSingle(ordNo, new PatIndApprove());
      // 更新できた場合、送信する
      if (patUpdateCount > 0) {
        registerUpdateContentChangeNotificationByOrdMain(ordMainMap.get(ordNo));
      }
    }
  }

  /**
   * 治療中指示変更送信
   *
   * @param ord OrdMain
   */
  private void registerUpdateContentChangeNotificationByOrdMain(OrdMain ord) throws Exception {
    // 条件送信後から後体重測定前までの間のみ処理する
    int dialysisState = Integer.parseInt(ord.getRstDialysisState());
    if (dialysisState >= 1 && dialysisState <= 4) {
      Long patId = ord.getPatId();
      String facilityCd = ord.getFacilityCd();
      String bedName = ord.getIndBedName() != null ? ord.getIndBedName() : "未登録";

      Map<String, String> patInfo = patInfoService.selectById(patId, facilityCd);
      ObjectMapper mapper = new ObjectMapper();
      PatPersonalMain patPersonalMain = mapper.readValue(patInfo.get("pat_personal_main"), PatPersonalMain.class);
      JSONObject replaceData = new JSONObject();
      replaceData.put("PATID", patId.toString());
      replaceData.put("LASTNAME", patPersonalMain.getPat_last_name());
      replaceData.put("FIRSTNAME", patPersonalMain.getPat_first_name());
      replaceData.put("BEDNAME", bedName);
      replaceData.put("FACILITYCD", facilityCd);
      replaceData.put("ORDNO", ord.getOrdNo().toString());
      webApiCallCommonUtil.registerNotification(CoreConstant.NotificationDefinition.INDICATION_CHANGE_IN_TREATMENT, facilityCd, replaceData);
    }
  }

  private void doRegisterNotification(JSONObject editMediJson, JSONArray rstMediInfo, MasterCacheHandler masterCacheHandler,
                                      int sysTimeMin, OrdMain ordMain, PatPersonalMain patPersonalMain, Map<String, Object> namesMap) {
    String effectFlg = "0";
    String no = editMediJson.get("no").toString();
    if (rstMediInfo != null) {
      JSONArray rstMediInfoStr = new JSONArray(rstMediInfo);
      for (int k = 0; k < rstMediInfoStr.length(); k++) {
        JSONObject rstMed = rstMediInfoStr.getJSONObject(k);
        if (rstMed.get("no").toString().equals(no)) {
          effectFlg = rstMed.get("effect_flg").toString();
        }
      }
    }
    if (effectFlg.equals("0")) {
      String medicateTimingCd = StrUtils.getStrFromJSONObject(editMediJson, "timing_cd");
      //投与タイミングを数値に変更します
      MstMedicateTiming mediTiming = null;
      if (medicateTimingCd != null && !medicateTimingCd.equals("null") && !medicateTimingCd.isEmpty()) {
        int mtcd = Integer.parseInt(medicateTimingCd);
        mediTiming = masterCacheHandler.getMstMedicateTimingByCd(mtcd);
      }
      if (!medicateTimingCd.equals("null")) {
        //データはあるの判定
        if (mediTiming != null) {
          int AlertTime = Objects.isNull(mediTiming.getAlertTime()) ? 0 : mediTiming.getAlertTime();
          //治療開始時間を取得
          String treatStartTime = ordMain.getIndTreatStartTime();
          int treatStartTimeH = Integer.parseInt(treatStartTime.substring(0, 2));
          int treatStartTimeM = Integer.parseInt(treatStartTime.substring(2));
          int treatStartTimeMin = treatStartTimeH * 60 + treatStartTimeM;

          //システム時間＞＝治療開始時間+投与タイミングの時間
          if (sysTimeMin >= (treatStartTimeMin + AlertTime)) {
            if (patPersonalMain == null) {
              patPersonalMain = patPersonalMainDao.selectById(ordMain.getPatId());
            }
            if (namesMap == null) {
              namesMap = dBAppWebAPIDao.selectNameDataFromVariousTbl(ordMain.getOrdNo());
            }
            this.registMedicalNotify(editMediJson, ordMain, namesMap, patPersonalMain, masterCacheHandler);
          }
        }
      }
    }
  }

  /**
   * 通知メッセージの登録処理
   * 有効な投与タイミングメッセージを通知メッセージテーブルにを登録
   */
  private void registMedicalNotify(JSONObject editMediJson, OrdMain ordMain, Map<String, Object> namesMap,
                                   PatPersonalMain patPersonalMain, MasterCacheHandler masterCacheHandler) throws RuntimeException {
    MstMedicateTiming mediTiming = editMediJson.isNull("timing_cd") ?
      new MstMedicateTiming() : masterCacheHandler.getMstMedicateTimingByCd((int) editMediJson.get("timing_cd"));
    // 通知フラグ('1'：通知する)
    String isAlert = mediTiming.getIsAlert();
    String dialysisProgressCd = mediTiming.getDialysisProgressCd();
    if (isAlert != null && isAlert.equals("1")
      && dialysisProgressCd != null && dialysisProgressCd.equals("002")) {
      JSONObject replaceData = new JSONObject();
      if (!namesMap.isEmpty()) {
        // 指示：ベッド名
        String indBedName = namesMap.containsKey("bed_name")
          ? (namesMap.get("bed_name") != null ? namesMap.get("bed_name").toString() : "") : "";
        replaceData.put("BEDNAME", indBedName);
      }
      replaceData.put("LASTNAME", patPersonalMain.getPat_last_name());
      replaceData.put("FIRSTNAME", patPersonalMain.getPat_first_name());
      replaceData.put("ORDNO", String.valueOf(ordMain.getOrdNo()));
      replaceData.put("PATID", String.valueOf(ordMain.getPatId()));
      replaceData.put("FACILITYCD", ordMain.getFacilityCd());

      Integer cd = editMediJson.has("cd") ? editMediJson.getInt("cd") : null;
      Integer medicineType = editMediJson.has("medicine_type") ? editMediJson.getInt("medicine_type") : null;
      //取得したコードを元に薬剤情報から名称を取得(DBから)
      if (cd != null && medicineType != null) {
        Map<String, Object> mediMap = dBAppWebAPIDao.selectMedicineInfo(
          ordMain.getFacilityCd(),
          medicineType,
          cd
        );
        String medicineName = mediMap.containsKey("name") ? mediMap.get("name").toString() : "";
        replaceData.put("MEDICINENAME", medicineName);
      }

      threadExecutor.execute(() -> {
        try {
          webApiCallCommonUtil.registerNotification(CoreConstant
            .NotificationDefinition.MEDICINE_TYMING, ordMain.getFacilityCd(), replaceData);
        } catch (URISyntaxException e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          if (ordMain != null && ordMain.getFacilityCd() != null) {
            eventLogMessage.setFacilityCd(ordMain.getFacilityCd());
          }
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
        }
      });
    }
  }
}
