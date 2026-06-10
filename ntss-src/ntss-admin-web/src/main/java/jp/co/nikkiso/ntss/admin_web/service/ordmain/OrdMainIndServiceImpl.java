package jp.co.nikkiso.ntss.admin_web.service.ordmain;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.response.ordMain.OrdMainResponse;
import jp.co.nikkiso.ntss.admin_web.service.ordmain.util.CommonUtils;
import jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.model.PatTreatmentPatternDelta;
import jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.model.PatTreatmentPatternFieldEnum;
import jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.model.PatTreatmentPatternJsonbField;
import jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.model.PatTreatmentPatternKey;
import jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.model.PatTreatmentPatternUpdateModeEnum;
import jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.model.PatTreatmentPatternUpsert;
import jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.service.PatTreatmentPatternService;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.IndicationUtils;
import jp.co.nikkiso.ntss.admin_web.web.rest.validation.ApiEntityOrdMain;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstTreatmentDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.OrdScheduleDao;
import jp.co.nikkiso.ntss.core.dao.PatIndApproveDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dto.OrdMain.OrdMainCrudDto;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.PatTreatmentPattern;
import jp.co.nikkiso.ntss.core.service.ordMaterialSaveService.OrdMaterialSaveService;
import org.apache.commons.lang3.StringUtils;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

@Service
public class OrdMainIndServiceImpl implements OrdMainIndService {

  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;
  @Autowired
  private OrdScheduleDao ordScheduleDao;
  @Autowired
  private MstTreatmentDao mstTreatmentDao;
  @Autowired
  private OrdMainDao ordMainDao;
  @Autowired
  private PatIndApproveDao patIndApproveDao;
  @Autowired
  private PatPersonalMainDao patPersonalMainDao;
  @Autowired
  private OrdMaterialSaveService ordMaterialSaveService;
  @Autowired
  private PatTreatmentPatternService patTreatmentPatternService;

  @Transactional
  @Override
  public OrdMainResponse createOrdByTreatSetCd(ApiEntityOrdMain.ValiCreateTreatPlan bodyData, PatMain patMain) {
    long patId = Long.parseLong(bodyData.getPat_id());
    String facilityCd = bodyData.getFacility_cd();
    OrdMainCrudDto dto = OrdMainCrudDto.builder()
      .patId(patId)
      .facilityCd(facilityCd)
      .treatmentSetCd(bodyData.getTreatment_set_cd())
      .treatMethodFlag(bodyData.getTreat_method_flag())
      .startDate(bodyData.getStart_date().replaceAll("-", ""))
      .indBedCd(0)
      .indKurCd(0)
      .indTreatStartTime(null)
      .upIndUserId(bodyData.getInd_user_id().longValue())
      .upUserId(bodyData.getUpd_user_id().longValue())
      .treatType(bodyData.getTreat_type())
      .treatDays(bodyData.getTreatDays())
      .build();

    // 指示：クールコード 未登録(固定)
    if (!(Objects.isNull(bodyData.getInd_kur_cd()) || "[]".equals(bodyData.getInd_kur_cd()))) {
      dto.setIndKurCd(Integer.valueOf(bodyData.getInd_kur_cd()
        .replace("[", StringUtils.EMPTY)
        .replace("]", StringUtils.EMPTY)));
    }
    // 指示：ベッドコード 未登録(固定)
    if (Objects.nonNull(bodyData.getInd_bed_cd())) {
      dto.setIndBedCd(Integer.valueOf(bodyData.getInd_bed_cd()));
    }
    // 治療開始時刻
    if (Objects.nonNull(bodyData.getInd_treat_start_time())) {
      bodyData.setInd_treat_start_time(bodyData.getInd_treat_start_time().replaceAll(":", StringUtils.EMPTY));
    }

    MstPersonalUser user = mstPersonalUserDao.selectById(bodyData.getInd_user_id().longValue());
    MstPersonalUser updUser = mstPersonalUserDao.selectById(bodyData.getUpd_user_id().longValue());
    PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(patId);
    dto.setFnPatId(patPersonalMain.getFn_pat_id());

    JSONObject userInfoJson = new JSONObject();
    {
      // 指示者コード
      userInfoJson.put("ind_user_id", bodyData.getInd_user_id());
      userInfoJson.put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
      userInfoJson.put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
      userInfoJson.put("upd_user_id", bodyData.getUpd_user_id());
      userInfoJson.put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
      userInfoJson.put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
    }

    List<OrdMain> createdOrdMains = ordMainDao.bulkInsertIndInfo(userInfoJson.toString(), dto);

    OrdMainResponse response = new OrdMainResponse();

    if (createdOrdMains.isEmpty()) {
      return response;
    }

    OrdMain createdOrdMain = createdOrdMains.stream()
      .min(Comparator.comparing(OrdMain::getTreatDate))
      .orElse(null);

    // event log更新用
    Map<String, List<Object>> resultAllChangedDataInfoList = new HashMap<>();
    Map<String, List<Object>> resultAllChangeBeforeDataInfoList = new HashMap<>();
    CommonUtils.addToMapList(resultAllChangedDataInfoList, "ord_main", createdOrdMains);

    // 患者治療パターン更新
    long startTimePattern = System.currentTimeMillis();
    if ("false".equals(bodyData.getIs_deadline())) {

      // 曜日パターン
      List<Integer> weekPattern = new ArrayList<>();
      if (null == bodyData.getUpdate_week_pattern()) {
        weekPattern = IndicationUtils.getWeekPattern(bodyData.getWeek_pattern());
      } else {
        JSONArray pattern = new JSONArray(bodyData.getUpdate_week_pattern());
        for (int i = 0; i < pattern.length(); i++) {
          weekPattern.add(pattern.getInt(i));
        }
      }
      // スケジュール情報
      String scheduleUserInfo = createdOrdMain.getIndScheduleUserInfo();
      JSONObject schUserInfoJson = new JSONObject(scheduleUserInfo);
      schUserInfoJson.put("ind_bed_cd", (null == dto.getIndBedCd()) ? 0 : dto.getIndBedCd());
      schUserInfoJson.put("ind_treat_start_time", (null == dto.getIndTreatStartTime()) ? JSONObject.NULL : dto.getIndTreatStartTime());

      // 必須なパラメータを設定する
      PatTreatmentPatternKey key = new PatTreatmentPatternKey(
        patId,
        facilityCd,
        null,
        null,
        weekPattern,
        null,
        new HashMap<>()
      );
      PatTreatmentPatternUpsert upsert = new PatTreatmentPatternUpsert(key);
      upsert.setIndTreatmentCd(createdOrdMain.getIndTreatmentCd());
      upsert.setIndKurCd(Long.valueOf(createdOrdMain.getIndKurCd()));
      upsert.setTreatType(createdOrdMain.getTreatType());
      upsert.setIndTreatStartDate(createdOrdMain.getTreatDate());
      upsert.addJsonbUpdate(PatTreatmentPatternFieldEnum.IND_COND_INFO, new PatTreatmentPatternJsonbField(
        PatTreatmentPatternUpdateModeEnum.OVERWRITE, createdOrdMain.getIndCondInfo()));
      upsert.addJsonbUpdate(PatTreatmentPatternFieldEnum.IND_MEDI_INFO, new PatTreatmentPatternJsonbField(
        PatTreatmentPatternUpdateModeEnum.OVERWRITE, createdOrdMain.getIndMediInfo()));
      upsert.addJsonbUpdate(PatTreatmentPatternFieldEnum.IND_EQUIP_INFO, new PatTreatmentPatternJsonbField(
        PatTreatmentPatternUpdateModeEnum.OVERWRITE, createdOrdMain.getIndEquipInfo()));
      upsert.addJsonbUpdate(PatTreatmentPatternFieldEnum.IND_COMMENT_INFO, new PatTreatmentPatternJsonbField(
        PatTreatmentPatternUpdateModeEnum.OVERWRITE, createdOrdMain.getIndIndCommentInfo()));
      upsert.addJsonbUpdate(PatTreatmentPatternFieldEnum.IND_DEVICE_SET_INFO, new PatTreatmentPatternJsonbField(
        PatTreatmentPatternUpdateModeEnum.OVERWRITE, createdOrdMain.getIndDeviceSetInfo()));
      upsert.addJsonbUpdate(PatTreatmentPatternFieldEnum.IND_SCH_INFO, new PatTreatmentPatternJsonbField(
        PatTreatmentPatternUpdateModeEnum.OVERWRITE, schUserInfoJson.toString()));
      PatTreatmentPatternDelta delta = new PatTreatmentPatternDelta();
      delta.getInserts().add(upsert);

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

    List<Long> createdOrdNoList = createdOrdMains.stream().map(OrdMain::getOrdNo).toList();

    // ord_schedule
    ordScheduleDao.insertOrdScheduleList(createdOrdMains);
    // pat_ind_approve
    patIndApproveDao.insertList(createdOrdNoList, facilityCd);
    // ord_material_save
    ordMaterialSaveService.bulkCreateByOrdNoInCondMediEquip(createdOrdNoList.get(0), createdOrdNoList);

    // 警告チェックを行う
    MstTreatment selectedTreat = mstTreatmentDao.selectByCd(createdOrdMain.getIndTreatmentCd());
    JSONObject condObj = new JSONObject(createdOrdMain.getIndCondInfo());
    JSONObject singleNeedleJSONObject = condObj.has("12") ? condObj.getJSONObject("12") : null;
    String singleNeedle = StringUtils.EMPTY;
    if (singleNeedleJSONObject != null) {
      singleNeedle = singleNeedleJSONObject.isNull("value") ? StringUtils.EMPTY
        : singleNeedleJSONObject.get("value").toString();
    }
    Set<String> warnSet = doWarnCheck(selectedTreat.getDeviceMode(), singleNeedle, patMain.getDevice_set_info());
    if (!warnSet.isEmpty()) {
      response.setMessageList(new ArrayList<>(warnSet));
    }

    response.setResultAllChangeBeforeDataInfoList(resultAllChangeBeforeDataInfoList);
    response.setResultAllChangedDataInfoList(resultAllChangedDataInfoList);
    response.setProcResult("SUCCESS");
    return response;
  }

  private Set<String> doWarnCheck(Integer deviceMode, String singleNeedle, String deviceSetInfo) {
    Set<String> warnSet = new HashSet<>();
    if (deviceSetInfo == null || deviceSetInfo.isEmpty()) {
      return warnSet;
    }
    JSONObject root = new JSONObject(deviceSetInfo);

    // TMP監視モード
    JSONObject tmpA = root
      .optJSONObject("war")
      .optJSONObject("dev")
      .optJSONObject("A");

    // TMP監視モード 0:TMP自動追従
    String tmpMonitoring = tmpA.get("240").toString();

    if (AdminWebConstant.Treatment.DeviceMode.AFBF.compareTo(deviceMode) == 0
      && "0".equals(tmpMonitoring)) {
      warnSet.add("12000019");
    }

    String ONE = "1";
    if (!ONE.equals(singleNeedle)) {
      // シングルニードルは使用しない場合、警告チェックを継続しない
      return warnSet;
    }

    JSONObject bvA = root
      .optJSONObject("bv")
      .optJSONObject("dev")
      .optJSONObject("A");

    // BV計_ブラッドボリューム計使用の選択
    // シングルニードル使用するの予定を作成する場合に、BV計使用する患者だった場合は注意メッセージ表示 1 :ON
    if (ONE.equals(bvA.get("267"))) {
      warnSet.add("12000017");
    }
    // アクセス再循環測定使用選択
    // シングルニードル使用するの予定を作成する場合に、アクセス再循環率使用する患者だった場合は注意メッセージ表示。 1 :ON
    if (ONE.equals(bvA.get("258"))) {
      warnSet.add("12000018");
    }
    return warnSet;
  }
}
