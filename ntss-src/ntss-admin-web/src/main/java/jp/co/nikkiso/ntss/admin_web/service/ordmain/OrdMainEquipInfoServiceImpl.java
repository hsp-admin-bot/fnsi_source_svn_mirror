package jp.co.nikkiso.ntss.admin_web.service.ordmain;

import jp.co.nikkiso.ntss.core.entity.EquipmentLatestNo;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatIndApprove;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.PatTreatmentPattern;
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
import jp.co.nikkiso.ntss.core.dao.OrdChecklistDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatIndApproveDao;
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

import java.sql.Timestamp;
import java.time.Instant;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Service
public class OrdMainEquipInfoServiceImpl implements OrdMainEquipInfoService {

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
  private OrdMainService ordMainService;
  @Autowired
  private LogService logService;
  @Autowired
  private OrdMaterialSaveService ordMaterialSaveService;
  @Autowired
  private PatTreatmentPatternService patTreatmentPatternService;

  @Transactional
  @Override
  public OrdMainResponse createOrdMainEquipInfo(List<ApiEntityOrdMain.ValiOrdEquip> bodyDataList) {
    OrdMainResponse response = new OrdMainResponse();
    ApiEntityOrdMain.ValiOrdEquip firstBodyData = bodyDataList.get(0);
    // 選択された日付+曜日の処理
    String startDate = firstBodyData.getStart_date().replaceAll("-", StringUtils.EMPTY);
    String endDate = firstBodyData.getEnd_date().replaceAll("-", StringUtils.EMPTY);
    List<Integer> weeksArray = IndicationUtils.getWeekPattern(firstBodyData.getWeeks());
    String facilityCd = firstBodyData.getFacility_cd();
    String patId = firstBodyData.getPat_id();
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
        Long.parseLong(patId),
        facilityCd,
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

    if (updatePreOrdMains.isEmpty()) {
      return response;
    }

    CommonUtils.addToMapList(resultAllChangeBeforeDataInfoList, "ord_main", updatePreOrdMains);

    // 変更内容を実績にも反映する
    String isRstUpdate = firstBodyData.getIs_rst_update();

    List<Long> updateOrdNoList = updatePreOrdMains.stream().map(OrdMain::getOrdNo).collect(Collectors.toList());

    MasterCacheHandler masterCacheHandler = MasterCacheHandler.get();

    int addEquipCount = 0;
    for (ApiEntityOrdMain.ValiOrdEquip bodyData : bodyDataList) {
      JSONObject checkEquipJson = new JSONObject(bodyData.getInd_info());
      if (checkEquipJson.has("cd") && !checkEquipJson.isNull("cd")) {
        addEquipCount++;
      }
    }

    Long nextEquipNo = null;
    if (addEquipCount > 0) {
      ordMainDao.lockMaxIndEquipInfoNo(facilityCd, patId);
      Timestamp nowTs = Timestamp.from(Instant.now());
      ordMainDao.updatePatEquipmentNo(
        new EquipmentLatestNo(
          facilityCd,
          Long.valueOf(patId),
          addEquipCount,
          nowTs,
          nowTs,
          AdminWebConstant.FlagType.FLAG_ON,
          AdminWebConstant.FlagType.FLAG_OFF));
      long maxEquipNo = ordMainDao.selectIndEquipInfoNo(facilityCd, patId);
      nextEquipNo = maxEquipNo - addEquipCount + 1;
    }

    JSONArray addEquipJson = new JSONArray();
    for (ApiEntityOrdMain.ValiOrdEquip bodyData : bodyDataList) {
      JSONObject editEquipJson = new JSONObject(bodyData.getInd_info());
      if (!editEquipJson.has("cd") || editEquipJson.isNull("cd")) {
        continue;
      }
      if (nextEquipNo != null) {
        editEquipJson.put("no", nextEquipNo++);
      }
      editEquipJson.put("auto_insert", bodyData.getAuto_insert());
      if (null == upd_user_id) {
        upd_user_id = StrUtils.getStrFromJSONObject(editEquipJson, "upd_user_id");
        ind_user_id = StrUtils.getStrFromJSONObject(editEquipJson, "ind_user_id");
        editEquipJson.put("ind_user_id", Long.valueOf(ind_user_id));
        editEquipJson.put("upd_user_id", Long.valueOf(upd_user_id));
      }
      if (null != upd_user_id && !StringUtils.EMPTY.equals(upd_user_id)) {
        MstPersonalUser updMstPersonalUser = masterCacheHandler.getMstPersonalUser(Long.valueOf(upd_user_id));
        if (updMstPersonalUser != null) {
          editEquipJson.put("upd_user_last_name", updMstPersonalUser.getUserLastName());
          editEquipJson.put("upd_user_first_name", updMstPersonalUser.getUserFirstName());
        }
      }
      addEquipJson.put(editEquipJson);
    }

    // main db更新
    List<OrdMain> updatedOrdMains = ordMainDao.updateOrdMainEquipInfo(
      updateOrdNoList,
      DUAL_TYPE.add.name(),
      StringUtils.EMPTY,
      StringUtils.EMPTY,
      addEquipJson.toString(),
      isRstUpdate,
      ind_user_id,
      upd_user_id);

    CommonUtils.addToMapList(resultAllChangedDataInfoList, "ord_main", updatedOrdMains);

    if (updatedOrdMains.isEmpty()) {
      return response;
    }

    if ("false".equals(firstBodyData.getIs_deadline())) {
      // 必須なパラメータを設定する
      Map<String, String> otherConditions = new HashMap<>();
      otherConditions.put("dual_type", DUAL_TYPE.add.name());
      otherConditions.put("upd_old_key", StringUtils.EMPTY);
      otherConditions.put("auto_insert_amount", StringUtils.EMPTY);

      PatTreatmentPatternKey key = new PatTreatmentPatternKey(
        Long.parseLong(patId),
        facilityCd,
        indTreatmentCds,
        indKurCds,
        weeksArray,
        null,
        otherConditions
      );
      PatTreatmentPatternUpsert upsert = new PatTreatmentPatternUpsert(key);
      upsert.addJsonbUpdate(PatTreatmentPatternFieldEnum.IND_EQUIP_INFO, new PatTreatmentPatternJsonbField(
        PatTreatmentPatternUpdateModeEnum.MERGE, addEquipJson.toString()));
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
      ordMainService.updateOrdChecklistByActionBeCurrent(OrdMainResource.OrdMainActionForChecklist.TREATPLAN_EQUIPMENT_CREATE, updateOrdNoList);
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
      ordMaterialSaveService.bulkUpdateByOrdNoInCondMediEquip(updateOrdNoList);
    } else {
      ordMaterialSaveService.bulkUpdateByOrdNoInEquip(updateOrdNoList);
    }

    response.setResultAllChangeBeforeDataInfoList(resultAllChangeBeforeDataInfoList);
    response.setResultAllChangedDataInfoList(resultAllChangedDataInfoList);
    response.setProcResult("SUCCESS");
    return response;
  }

  @Transactional
  @Override
  public OrdMainResponse updateOrdMainEquipInfo(ApiEntityOrdMain.ValiOrdEquip bodyData, List<OrdMain> updatePreOrdMains) {
    OrdMainResponse response = new OrdMainResponse();
    String facilityCd = bodyData.getFacility_cd();
    String patId = bodyData.getPat_id();

    // event log更新用
    Map<String, List<Object>> resultAllChangedDataInfoList = new HashMap<>();
    Map<String, List<Object>> resultAllChangeBeforeDataInfoList = new HashMap<>();

    // 変更内容を実績にも反映する
    String isRstUpdate = bodyData.getIs_rst_update();

    List<Long> updateOrdNoList = updatePreOrdMains.stream().map(OrdMain::getOrdNo).toList();

    String targetEquipCd = bodyData.getTarget_equip_edit();
    String targetEquipType = bodyData.getTarget_equip_edit_type();
    JSONObject editEquipJson = new JSONObject(bodyData.getInd_info());

    MasterCacheHandler masterCacheHandler = MasterCacheHandler.get();
    String ind_user_id = StrUtils.getStrFromJSONObject(editEquipJson, "ind_user_id");
    String upd_user_id = StrUtils.getStrFromJSONObject(editEquipJson, "upd_user_id");
    if (!StringUtils.EMPTY.equals(upd_user_id)) {
      editEquipJson.put("ind_user_id", Long.valueOf(ind_user_id));
      editEquipJson.put("upd_user_id", Long.valueOf(upd_user_id));
      MstPersonalUser updMstPersonalUser = masterCacheHandler.getMstPersonalUser(Long.valueOf(upd_user_id));
      if (updMstPersonalUser != null) {
        editEquipJson.put("upd_user_last_name", updMstPersonalUser.getUserLastName());
        editEquipJson.put("upd_user_first_name", updMstPersonalUser.getUserFirstName());
      }
    }

    // bodyData.getAuto_insert()= "1" => 穴埋め -> auto_insert => 0
    editEquipJson.put("auto_insert", Integer.parseInt(bodyData.getAuto_insert()) == 1 ? "0" : "1");

    JSONObject sendEquipInfo = new JSONObject(bodyData.getSend_equip_info());
    String dualType = DUAL_TYPE.upd.name();
    String newEquipCd = String.valueOf(editEquipJson.get("cd"));
    String oldEquipType = normalizeEquipType(targetEquipType);
    String newEquipType = normalizeEquipType(editEquipJson);
    if (!StringUtils.equals(targetEquipCd, newEquipCd) || !StringUtils.equals(oldEquipType, newEquipType)) {
      // 医材が変更された場合は、数量編集条件に関わらず置換扱い（del_add）で採番する。
      dualType = DUAL_TYPE.del_add.name();
    }
    if (DUAL_TYPE.del_add.name().equals(dualType)) {
      editEquipJson.put("no", ordMainService.selectMaxEquipInfoNo(facilityCd, patId));
    }
    String updOldKey = StringUtils.joinWith("_", targetEquipCd, targetEquipType);
    JSONArray updEquipJsonArr = new JSONArray();
    updEquipJsonArr.put(editEquipJson);

    String autoInsertAmount = "0";
    if (sendEquipInfo.has("amount") && !editEquipJson.has("amount")) {
      autoInsertAmount = sendEquipInfo.get("amount").toString();
    }

    // main db更新
    List<OrdMain> updatedOrdMains = ordMainDao.updateOrdMainEquipInfo(
      updateOrdNoList,
      dualType,
      updOldKey,
      autoInsertAmount,
      updEquipJsonArr.toString(),
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
      List<Integer> weeksArray = IndicationUtils.getWeekPattern(bodyData.getWeeks());
      // 必須なパラメータを設定する
      Map<String, String> otherConditions = new HashMap<>();
      otherConditions.put("dual_type", dualType);
      otherConditions.put("upd_old_key", updOldKey);
      otherConditions.put("auto_insert_amount", autoInsertAmount);
      PatTreatmentPatternKey key = new PatTreatmentPatternKey(
        Long.parseLong(patId),
        facilityCd,
        indTreatmentCds,
        indKurCds,
        weeksArray,
        null,
        otherConditions
      );
      PatTreatmentPatternUpsert upsert = new PatTreatmentPatternUpsert(key);
      upsert.addJsonbUpdate(PatTreatmentPatternFieldEnum.IND_EQUIP_INFO, new PatTreatmentPatternJsonbField(
        PatTreatmentPatternUpdateModeEnum.MERGE, updEquipJsonArr.toString()));
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
      ordMainService.updateOrdChecklistByActionBeCurrent(OrdMainResource.OrdMainActionForChecklist.TREATPLAN_EQUIPMENT_UPDATE, updateOrdNoList);
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
      ordMaterialSaveService.bulkUpdateByOrdNoInEquip(updatedOrdNoList);
    }

    response.setResultAllChangeBeforeDataInfoList(resultAllChangeBeforeDataInfoList);
    response.setResultAllChangedDataInfoList(resultAllChangedDataInfoList);
    response.setProcResult("SUCCESS");
    return response;
  }

  @Transactional
  @Override
  public OrdMainResponse deleteOrdMainEquipInfo(ApiEntityOrdMain.ValiOrdEquip bodyData, List<OrdMain> updatePreOrdMains) {
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
    JSONObject editEquipJson = new JSONObject(bodyData.getInd_info());
    String ind_user_id = StrUtils.getStrFromJSONObject(editEquipJson, "ind_user_id");
    String upd_user_id = StrUtils.getStrFromJSONObject(editEquipJson, "upd_user_id");
    String targetEquipCd = bodyData.getTarget_equip_edit();
    String targetEquipType = bodyData.getTarget_equip_edit_type();
    String updOldkey = StringUtils.joinWith("_", targetEquipCd, targetEquipType);
    JSONArray deleteEquipJsonArr = new JSONArray();
    deleteEquipJsonArr.put(editEquipJson);

    // main db更新
    List<OrdMain> updatedOrdMains = ordMainDao.updateOrdMainEquipInfo(
      updateOrdNoList,
      DUAL_TYPE.del.name(),
      updOldkey,
      StringUtils.EMPTY,
      deleteEquipJsonArr.toString(),
      isRstUpdate,
      ind_user_id,
      upd_user_id);

    CommonUtils.addToMapList(resultAllChangedDataInfoList, "ord_main", updatedOrdMains);

    if (updatedOrdMains.isEmpty()) {
      return response;
    }

    // pat_treatment_pattern
    if ("false".equals(bodyData.getIs_deadline())) {
      // 必須なパラメータを設定する
      Map<String, String> otherConditions = new HashMap<>();
      otherConditions.put("dual_type", DUAL_TYPE.del.name());
      otherConditions.put("upd_old_key", updOldkey);
      otherConditions.put("auto_insert_amount", StringUtils.EMPTY);

      List<Integer> indTreatmentCds = CommonUtils.getValueList(bodyData.getInd_treatment_cd());
      List<Long> indKurCds = CommonUtils.getLongList(bodyData.getInd_kur_cd());
      List<Integer> weeksArray = IndicationUtils.getWeekPattern(bodyData.getWeeks());

      PatTreatmentPatternKey key = new PatTreatmentPatternKey(
        Long.parseLong(patId),
        facilityCd,
        indTreatmentCds,
        indKurCds,
        weeksArray,
        null,
        otherConditions
      );
      PatTreatmentPatternUpsert upsert = new PatTreatmentPatternUpsert(key);
      upsert.addJsonbUpdate(PatTreatmentPatternFieldEnum.IND_EQUIP_INFO, new PatTreatmentPatternJsonbField(
        PatTreatmentPatternUpdateModeEnum.MERGE, deleteEquipJsonArr.toString()));
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
      ordMaterialSaveService.bulkUpdateByOrdNoInEquip(updatedOrdNoList);
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
   * @throw Exception
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

  /**
   * ord_main更新用dualType処理種類(add, upd, del-add, del)
   */
  public enum DUAL_TYPE {
    /**
     * 追加
     */
    add,
    /**
     * 変更(数量のみ変更)
     */
    upd,
    /**
     * 医材変更
     */
    del_add,
    /**
     * 中止
     */
    del,
  }

  private String normalizeEquipType(String equipType) {
    if (StringUtils.isBlank(equipType) || "null".equalsIgnoreCase(equipType)) {
      return "0";
    }
    return equipType;
  }

  private String normalizeEquipType(JSONObject equipJson) {
    if (!equipJson.has("equip_type") || equipJson.isNull("equip_type")) {
      return "0";
    }
    return normalizeEquipType(String.valueOf(equipJson.get("equip_type")));
  }
}
