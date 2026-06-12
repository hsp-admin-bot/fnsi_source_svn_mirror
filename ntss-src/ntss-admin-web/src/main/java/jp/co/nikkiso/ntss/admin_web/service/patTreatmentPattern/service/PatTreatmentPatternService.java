package jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.service;

import tools.jackson.core.JacksonException;
import tools.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.model.PatTreatmentPatternDelta;
import jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.model.PatTreatmentPatternFieldEnum;
import jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.model.PatTreatmentPatternJsonbField;
import jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.model.PatTreatmentPatternKey;
import jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.model.PatTreatmentPatternUpsert;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.PatTreatmentPatternDao;
import jp.co.nikkiso.ntss.core.dto.pattreatmentpattern.EditDto;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.PatTreatmentPattern;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.apache.commons.collections4.CollectionUtils;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import static jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.model.PatTreatmentPatternUpdateModeEnum.MERGE;

@Service
public class PatTreatmentPatternService {

  @Autowired
  private PatTreatmentPatternDao patTreatmentPatternDao;

  @Autowired
  private LogService logService;

  private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();

  /**
   * 戻り値種類
   */
  public enum RESULT_TYPE {
    /**
     * 更新前
     */
    OLD,
    /**
     * 更新後
     */
    NEW,
  }

  @Transactional
  public Map<RESULT_TYPE, List<PatTreatmentPattern>> applyPatTreatmentPatterns(PatTreatmentPatternDelta delta) {

    Map<RESULT_TYPE, List<PatTreatmentPattern>> response = new HashMap<>();

    if (delta == null || delta.isEmpty()) {
      return response;
    }

    List<PatTreatmentPatternKey> keys = new ArrayList<>(delta.getUpdates()
      .stream().map(PatTreatmentPatternUpsert::getKey).toList());
    keys.addAll(delta.getDeletes());
    List<PatTreatmentPattern> updatePrePatTreatmentPatterns = searchPatTreatmentPattern(keys);
    // log_event記入用更新前値を設定する
    response.put(RESULT_TYPE.OLD, updatePrePatTreatmentPatterns);
    response.put(RESULT_TYPE.NEW, new ArrayList<>());

    // 新規登録
    handleInserts(delta, response);
    // 削除
    handleDeletes(delta, response);
    // 修正
    handleUpdates(delta, response);

    return response;
  }


  // ===================== insert =====================

  private void handleInserts(
    PatTreatmentPatternDelta delta,
    Map<RESULT_TYPE, List<PatTreatmentPattern>> response) {

    for (PatTreatmentPatternUpsert insert : delta.getInserts()) {
      if (!insert.hasUpdate()) {
        continue;
      }

      PatTreatmentPatternKey key = insert.getKey();
      Map<String, Object> basePatch = buildBasePatchForInsert(insert);
      Map<PatTreatmentPatternFieldEnum, PatTreatmentPatternJsonbField> updateMap = insert.getJsonbUpdates();
      EditDto editDto = editDtoBuilder(key, updateMap, basePatch);
      editDto.setTreatWeek(StringUtils.join(key.treatWeeks(), ","));

      List<PatTreatmentPattern> result =
        patTreatmentPatternDao.bulkInsert(key.facilityCd(), key.patId(), editDto);

      response.get(RESULT_TYPE.NEW).addAll(result);
    }
  }

  // ===================== update =====================

  private void handleUpdates(
    PatTreatmentPatternDelta delta,
    Map<RESULT_TYPE, List<PatTreatmentPattern>> response) {

    for (PatTreatmentPatternUpsert upsert : delta.getUpdates()) {
      if (!upsert.hasUpdate()) {
        continue;
      }
      PatTreatmentPatternKey key = upsert.getKey();
      Map<PatTreatmentPatternFieldEnum, PatTreatmentPatternJsonbField> updateMap =
        upsert.getJsonbUpdates();

      // 治療条件のみ変更の場合、特殊更新する
      if (updateMap.size() == 1 && updateMap.containsKey(PatTreatmentPatternFieldEnum.IND_COND_INFO)) {
        List<PatTreatmentPattern> updated = updateIndCondInfo(key, updateMap.get(PatTreatmentPatternFieldEnum.IND_COND_INFO));
        response.get(RESULT_TYPE.NEW).addAll(updated);
        continue;
      }
      // 治療方法のみ変更
      if (updateMap.size() == 1 && updateMap.containsKey(PatTreatmentPatternFieldEnum.TREATMENT_METHOD_ONLY)) {
        List<PatTreatmentPattern> updated = updateTreatmentMethodOnly(key);
        response.get(RESULT_TYPE.NEW).addAll(updated);
        continue;
      }

      EditDto editDto = editDtoBuilder(key, updateMap, new HashMap<>());
      List<PatTreatmentPattern> result =
        patTreatmentPatternDao.bulkUpdate(
          key.facilityCd(),
          key.patId(),
          CollectionUtils.isEmpty(key.treatWeeks()) ? List.of(0) : key.treatWeeks(),
          key.indTreatmentCds(),
          key.indKurCds(),
          editDto
        );
      response.get(RESULT_TYPE.NEW).addAll(result);
    }
  }

  // ===================== delete =====================

  private void handleDeletes(
    PatTreatmentPatternDelta delta,
    Map<RESULT_TYPE, List<PatTreatmentPattern>> response) {

    List<PatTreatmentPattern> deleteResults = new ArrayList<>();

    for (PatTreatmentPatternKey key : delta.getDeletes()) {

      List<PatTreatmentPattern> deleted =
        patTreatmentPatternDao.bulkDelete(
          key.facilityCd(),
          key.patId(),
          key.indTreatmentCds(),
          key.indKurCds(),
          key.treatWeeks()
        );
      deleteResults.addAll(deleted);
    }
    response.put(RESULT_TYPE.OLD, deleteResults);
  }

  private Map<String, Object> buildBasePatchForInsert(PatTreatmentPatternUpsert insert) {
    Map<String, Object> patch = new HashMap<>();

    if (insert.getTreatType() != null) {
      patch.put("treat_type", insert.getTreatType());
    }
    if (insert.getIndTreatmentCd() != null) {
      patch.put("ind_treatment_cd", insert.getIndTreatmentCd());
    }
    if (insert.getIndKurCd() != null) {
      patch.put("ind_kur_cd", insert.getIndKurCd());
    }
    if (StringUtils.isNotEmpty(insert.getIndTreatStartDate())) {
      patch.put("ind_treat_start_date", insert.getIndTreatStartDate());
    }
    return patch;
  }

  private EditDto editDtoBuilder(PatTreatmentPatternKey key,
    Map<PatTreatmentPatternFieldEnum, PatTreatmentPatternJsonbField> updateMap,
    Map<String, Object> patchMap) {
    EditDto editDto = new EditDto();
    updateMap.forEach((field, jsonbField) -> {
      if (StringUtils.isEmpty(editDto.getMode())) {
        editDto.setMode(jsonbField.mode().name());
      }
      patchMap.put(field.getColumnName(), jsonbField.value());
      Map<String, String> otherConditions = key.otherConditions();
      if (field == PatTreatmentPatternFieldEnum.IND_MEDI_INFO) {
        patchMap.put("is_medi_change", Boolean.FALSE.toString());
        if (!otherConditions.isEmpty()) {
          patchMap.put("is_medi_change", Boolean.TRUE.toString());
          if (otherConditions.containsKey("is_medi_stop")) {
            patchMap.put("is_medi_stop", otherConditions.get("is_medi_stop"));
          }
          if (otherConditions.containsKey("old_medi_no")) {
            patchMap.put("old_medi_no", otherConditions.get("old_medi_no"));
          }
          if (otherConditions.containsKey("is_edit_other_amount")) {
            patchMap.put("is_edit_other_amount", otherConditions.get("is_edit_other_amount"));
          }
          if (otherConditions.containsKey("medi_week")) {
            patchMap.put("medi_week", otherConditions.get("medi_week"));
          }
        }
      }
      if (field == PatTreatmentPatternFieldEnum.IND_EQUIP_INFO) {
        if (!otherConditions.isEmpty()) {
          if (otherConditions.containsKey("dual_type")) {
            patchMap.put("dual_type", otherConditions.get("dual_type"));
          }
          if (otherConditions.containsKey("upd_old_key")) {
            patchMap.put("upd_old_key", otherConditions.get("upd_old_key"));
          }
          if (otherConditions.containsKey("auto_insert_amount")) {
            patchMap.put("auto_insert_amount", otherConditions.get("auto_insert_amount"));
          }
        }
      }
      if (field == PatTreatmentPatternFieldEnum.TREATMENT_METHOD_SET_CHANGE) {
        if (!otherConditions.isEmpty()) {
          if (otherConditions.containsKey("ind_treatment_cd")) {
            patchMap.put("ind_treatment_cd", otherConditions.get("ind_treatment_cd"));
          }
        }
      }
    });
    try {
      editDto.setPatchJson(OBJECT_MAPPER.writeValueAsString(patchMap));
    } catch (JacksonException e) {
      throw new IllegalStateException("Failed to serialize patch JSON", e);
    }
    return editDto;
  }

  private List<PatTreatmentPattern> updateIndCondInfo(
    PatTreatmentPatternKey key,
    PatTreatmentPatternJsonbField jsonbField) {

    if (!MERGE.equals(jsonbField.mode())) {
      return List.of();
    }

    Map<String, String> otherConditions = key.otherConditions();
    return patTreatmentPatternDao.bulkUpdateIndCondInfo(
      key.facilityCd(),
      key.patId(),
      key.treatWeeks(),
      key.indTreatmentCds(),
      key.indKurCds(),
      getFromMap(otherConditions, "antiCoagulantAmountTotalCalcFlg"),
      getFromMap(otherConditions, "indTreatCondIvMode"),
      jsonbField.value(),
      getFromMap(otherConditions, "answerFlg"),
      getFromMap(otherConditions, "accountItemCd"),
      getFromMap(otherConditions, "quantityBefore"),
      getFromMap(otherConditions, "quantityAfter")
    );
  }

  private List<PatTreatmentPattern> updateTreatmentMethodOnly(
    PatTreatmentPatternKey key) {

    Map<String, String> otherConditions = key.otherConditions();
    MstPersonalUser indUser = new MstPersonalUser();
    MstPersonalUser updUser = new MstPersonalUser();

    indUser.setUserId(Long.parseLong(getFromMap(otherConditions, "indUserId")));
    indUser.setUserLastName(getFromMap(otherConditions, "indUserLastName"));
    indUser.setUserFirstName(getFromMap(otherConditions, "indUserFirstName"));

    updUser.setUserId(Long.parseLong(getFromMap(otherConditions, "updUserId")));
    updUser.setUserLastName(getFromMap(otherConditions, "updUserLastName"));
    updUser.setUserFirstName(getFromMap(otherConditions, "updUserFirstName"));

    return patTreatmentPatternDao.updatePatTreatmentPatternTreatmentMethodOnly(
      key.facilityCd(),
      key.patId(),
      key.treatWeeks(),
      key.indTreatmentCds(),
      key.indKurCds(),
      Integer.parseInt(getFromMap(otherConditions, "editTreatmentCd")),
      indUser,
      updUser
    );
  }

  private String getFromMap(Map<String, String> map, String key) {
    if (map == null) {
      return StringUtils.EMPTY;
    }
    return map.getOrDefault(key, StringUtils.EMPTY);
  }

  public List<PatTreatmentPattern> searchPatTreatmentPattern(List<PatTreatmentPatternKey> keys) {
    keys = keys.stream().distinct().toList();
    List<PatTreatmentPattern> searchData = new ArrayList<>();
    keys.forEach(k -> {
      try {
        List<Integer> indTreatmentCdList =
          Optional.ofNullable(k.indTreatmentCds()).orElse(List.of());
        List<Long> indKurCdList =
          Optional.ofNullable(k.indKurCds()).orElse(List.of());
        // 該当患者治療パターン検索
        searchData.addAll(patTreatmentPatternDao.selectBySearchInfo(
          k.patId(),
          k.facilityCd(),
          indTreatmentCdList,
          indKurCdList,
          k.treatWeeks()));
      } catch (Exception e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("患者治療パターン検索処理に失敗しました key=:" + k + " error=" + e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      }
    });
    return searchData;
  }
}
