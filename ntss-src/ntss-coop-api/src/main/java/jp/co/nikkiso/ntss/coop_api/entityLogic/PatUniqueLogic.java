package jp.co.nikkiso.ntss.coop_api.entityLogic;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.commons.collections.CollectionUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import jp.co.nikkiso.ntss.coop_api.service.LogService;
import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.coop_api.utils.CheckNecessaryParamUtil;
import jp.co.nikkiso.ntss.coop_api.utils.ClockWrapper;
import jp.co.nikkiso.ntss.coop_api.utils.EntityCreatorUtil;
import jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants;
import jp.co.nikkiso.ntss.coop_api.utils.MaxCtlNoUtil;
import jp.co.nikkiso.ntss.core.dao.MstDiseaseDao;
import jp.co.nikkiso.ntss.core.entity.PatUnique;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;

/**
 * 電文から抽出した項目に基づき、{@link PatUnique}エンティティを作成するクラス。
 */
@Component
public class PatUniqueLogic implements EntityLogic {

  @Autowired
  private MstDiseaseDao mstDiseaseDao;

  @Autowired
  private ClockWrapper clockWrapper;

  @Autowired
  private LogService logService;

  /**
   * マップからエンティティを作成する。
   *
   * @param paramMap カラム名とカラム値のマップ
   * @return エンティティ
   * @see jp.co.nikkiso.ntss.coop_api.entityLogic.EntityLogic#createEntity(java.util.Map)
   */
  @Override
  public PatUnique createEntity(Map<String, Object> paramMap) {
    return EntityCreatorUtil.createEntity(PatUnique.class, paramMap);
  }

  /**
   * 電文から抽出した項目をチェックおよび編集する。（新規登録時用）
   *
   * @param facilityCd 施設コード
   * @param paramMap 電文から抽出した項目のマップ
   * @see jp.co.nikkiso.ntss.coop_api.entityLogic.EntityLogic#check(java.lang.String, java.util.Map)
   */
  @Override
  public void check(String facilityCd, Map<String, Object> paramMap) {
    checkCommon(facilityCd, paramMap);

    checkMedicalHstInfo(facilityCd, "medical_hst_info", paramMap, null);

    checkPhysicalInfo(facilityCd, "physical_info", paramMap, null);

    Timestamp now = new Timestamp(clockWrapper.getClockMillis());
    paramMap.put("reg_date", now);
  }

  /**
   * 電文から抽出した項目をチェックおよび編集する。（更新時用）
   *
   * @param facilityCd 施設コード
   * @param paramMap 電文から抽出した項目のマップ
   * @param entity 対象テーブルから取得したエンティティ（更新の場合に使用）
   * @see jp.co.nikkiso.ntss.coop_api.entityLogic.EntityLogic#check(java.lang.String, java.util.Map, java.lang.Object)
   */
  @Override
  public void check(String facilityCd, Map<String, Object> paramMap, Object entity) {
    checkCommon(facilityCd, paramMap);

    PatUnique pu = (PatUnique) entity;

    // pat_idの必須チェック
    Long patId = (Long) paramMap.get("pat_id");
    CheckNecessaryParamUtil.checkRequired("pat_id", patId);

    // ### medical_hst_info（既往歴）
    // disease_cdでmst_diseaseマスタ照合
    String medicalHstInfoStr = pu.getMedical_hst_info();

    checkMedicalHstInfo(facilityCd, "medical_hst_info", paramMap, medicalHstInfoStr);

    // ### in_out_visit_history_info(入外・転入出情報)
    // - 対象外

    // ### physical_info(身体情報)
    // jsonkey`exam_date`の項目がない場合、or `exam_date`の最大値より小さい場合には連携しない。
    String physicalInfoStr = pu.getPhysical_info();
    checkPhysicalInfo(facilityCd, "physical_info", paramMap, physicalInfoStr);
  }

  /**
   * insert/updateの共通チェック処理。
   *
   * @param facilityCd 施設コード
   * @param paramMap 電文から抽出した項目のマップ
   */
  private void checkCommon(String facilityCd, Map<String, Object> paramMap) {
    // pat_idの必須チェック
    Long patId = (Long) paramMap.get("pat_id");
    CheckNecessaryParamUtil.checkRequired("pat_id", patId);

    // ### medical_care_info（共通診療情報）
    // ⇒pat_mainに移動。

    // ### in_out_visit_history_info(入外・転入出情報)
    // - 対象外

    // ### is_del, up_date, reg_date
    // 他に倣って登録
    // （pat_personal_main等、BaseEntityを継承していないエンティティのテーブルは独自に設定する必要がある。）
    paramMap.putIfAbsent("is_del", JournalConvertConstants.LOGICAL_DELETE_FLAG_OFF);
    Timestamp now = new Timestamp(clockWrapper.getClockMillis());
    paramMap.put("up_date", now);
  }

  /**
   * medical_hst_info（既往歴）を編集する。
   *
   * @param facilityCd 施設コード
   * @param keyName キー名（medical_hst_info固定想定）
   * @param paramMap 電文から抽出した内容
   * @param medicalHstInfoStr 既存レコードの既往歴（文字列）
   */
  private void checkMedicalHstInfo(String facilityCd, String keyName, Map<String, Object> paramMap,
      String medicalHstInfoStr) {
    Object obj = paramMap.get(keyName);
    if (obj == null) {
      return;
    }

    List<Map<String, Object>> medicalHstInfoMapList = ObjectMapperUtil.castToStringObjectMapList(obj);
    if (CollectionUtils.isEmpty(medicalHstInfoMapList)) {
      return;
    }

    List<Map<String, Object>> medicalHstInfo;
    if (StringUtils.isEmpty(medicalHstInfoStr)) {
      medicalHstInfo = new ArrayList<>();
    } else {
      try {
        medicalHstInfo = ObjectMapperUtil.readListOfMap(medicalHstInfoStr);
      } catch (IOException e) {
        throw new NtssException("pat_uniqueテーブルのmedical_hst_info（既往歴）更新でエラーが発生しました。", e);
      }
    }

    EventLogMessage eventLogMessage = new EventLogMessage();
    for (Map<String, Object> medicalHstInfoMap : medicalHstInfoMapList) {
      String diseaseCdStr = (String) medicalHstInfoMap.get("disease_cd");
      Integer diseaseCd = mstDiseaseDao.selectByInHospitalCd1(facilityCd, diseaseCdStr);

      eventLogMessage.setLogMessage("電文中の病名コード:["+ diseaseCdStr + "], マスタ参照後の病名コード:[" +  diseaseCd + "]");
      eventLogMessage.setFacilityCd(facilityCd);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      if (diseaseCd == null) {
        eventLogMessage.setLogMessage("病名マスタ中に病名コードが設定されていないため、既往歴の連携をスキップします。施設コード:[" + facilityCd + "], 病名コード:[" + diseaseCdStr + "]");
        eventLogMessage.setFacilityCd(facilityCd);
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
        eventLogMessage.setInvokeClass(this.getClass().getName());
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
        logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        medicalHstInfoMap.clear();
        paramMap.put(keyName, medicalHstInfoMap);
        return;
      }

      medicalHstInfoMap.put("disease_cd", diseaseCd);

      // - 新規登録時
      //  - 情報があれば新規登録
      //    - `ctrl_no`, `disp_order`は順に採番
      //    - `disease_cd`は`mst_disease`と突き合わせる
      //
      // - 更新時
      //  - `disease_cd`は`mst_disease`と突き合わせ、存在しなければ最後に追加<br/>存在すれば情報を更新する

      if (medicalHstInfo.isEmpty()) {
        insert(medicalHstInfoMap, medicalHstInfo);
      } else {
        update(medicalHstInfoMap, medicalHstInfo);
      }

      paramMap.put(keyName, medicalHstInfo);
    }
  }

  /**
   * 既往歴の新規登録処理。
   *
   * @param medicalHstInfoMap 電文から抽出した既往歴
   * @param medicalHstInfo 既存レコードの既往歴
   */
  private void insert(Map<String, Object> medicalHstInfoMap, List<Map<String, Object>> medicalHstInfo) {
    Long ctlNo = MaxCtlNoUtil.getCtlNoMax(medicalHstInfo) + 1;
    medicalHstInfoMap.put("ctl_no", ctlNo);
    medicalHstInfoMap.put("disp_order", ctlNo);

    medicalHstInfo.add(medicalHstInfoMap);
  }

  /**
   * 既往歴の更新処理。
   *
   * @param medicalHstInfoMap 電文から抽出した既往歴
   * @param medicalHstInfo 既存レコードの既往歴
   */
  private void update(Map<String, Object> medicalHstInfoMap, List<Map<String, Object>> medicalHstInfo) {
    Integer diseaseCd = (int) medicalHstInfoMap.get("disease_cd");
    Optional<Map<String, Object>> foundRecord = medicalHstInfo.stream()
        .filter(e -> diseaseCd.equals(intValue(e.get("disease_cd")))).findFirst();
    if (foundRecord.isPresent()) {
      Map<String, Object> record = foundRecord.get();
      Long ctlNo = MaxCtlNoUtil.longValue(record.get("ctl_no"));
      Long dispOrder = MaxCtlNoUtil.longValue(record.get("disp_order"));
      record.clear();
      record.putAll(medicalHstInfoMap);
      record.put("ctl_no", ctlNo);
      record.put("disp_order", dispOrder);
    } else {
      insert(medicalHstInfoMap, medicalHstInfo);
    }
  }

  private int intValue(Object obj) {
    if (obj == null) {
      return -1;
    }

    return (int) obj;
  }

  /**
   * physical_info（身体情報）を編集する。
   *
   * @param facilityCd 施設コード
   * @param keyName キー名（physical_info固定想定）
   * @param paramMap 電文から抽出した内容
   * @param physicalInfoStr 既存レコードの身体情報（文字列）
   */
  private void checkPhysicalInfo(String facilityCd, String keyName, Map<String, Object> paramMap,
      String physicalInfoStr) {
    Object obj = paramMap.get(keyName);
    if (obj == null) {
      return;
    }

    List<Map<String, Object>> physicalInfoMapList = ObjectMapperUtil.castToStringObjectMapList(obj);
    if (CollectionUtils.isEmpty(physicalInfoMapList)) {
      return;
    }

    Long ctlNo;
    List<Map<String, Object>> physicalInfo;

    if (StringUtils.isEmpty(physicalInfoStr)) {
      // 新規登録の場合は1固定
      physicalInfo = new ArrayList<>();
      ctlNo = 1L;
    } else {
      try {
        physicalInfo = ObjectMapperUtil.readListOfMap(physicalInfoStr);
        ctlNo = MaxCtlNoUtil.getCtlNoMax(physicalInfo) + 1;
      } catch (IOException e) {
        throw new NtssException("pat_uniqueテーブルのphysical_info（身体情報）更新でエラーが発生しました。", e);
      }
    }

    // 既存レコード中のexam_dateの最大値(B)
    Optional<Timestamp> examDateMax = physicalInfo.stream().map(e -> toTimestamp(e.get("exam_date")))
        .max(Comparator.naturalOrder());

    EventLogMessage eventLogMessage = new EventLogMessage();
    for (Map<String, Object> physicalInfoMap : physicalInfoMapList) {
      // exam_date項目が存在しない場合
      // DBに反映しない。
      if (!physicalInfoMap.containsKey("exam_date")) {
        eventLogMessage.setLogMessage("exam_date項目が存在しないため、身体情報の連携をスキップします。施設コード:[" + facilityCd + "]");
        eventLogMessage.setFacilityCd(facilityCd);
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
        eventLogMessage.setInvokeClass(this.getClass().getName());
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
        logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        continue;
      }

      // 電文から抽出したexam_dateの値(A)
      String examDateStr = (String) physicalInfoMap.get("exam_date");
      Timestamp examDate = toTimestamp(examDateStr);

      // (A)が(B)より小さい場合はDBに反映しない。
      if (examDateMax.isPresent() && examDate.compareTo(examDateMax.get()) < 0) {
        eventLogMessage.setLogMessage("exam_dateが既存データに対して最新でないため、身体情報の連携をスキップします。施設コード:[" + facilityCd + "]");
        eventLogMessage.setFacilityCd(facilityCd);
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
        eventLogMessage.setInvokeClass(this.getClass().getName());
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
        logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        continue;
      }

      physicalInfoMap.put("ctl_no", ctlNo);
      ++ctlNo;
      physicalInfo.add(physicalInfoMap);
    }

    paramMap.put(keyName, physicalInfo);
  }

  /**
   * オブジェクトが文字列の場合、Timestampに変換する。
   *
   * @param obj オブジェクト
   * @return Timestamp値。引数がnullの場合と文字列でない場合は1970/1/1 00:00:00を返す。
   */
  private Timestamp toTimestamp(Object obj) {
    if (obj == null || !(obj instanceof String)) {
      return new Timestamp(0);
    }

    String s = (String) obj;
    // add 2021-02-25 電文確認：日付の「/」を削除する。 孫 start
    s = s.replace("/", "");
    // add 2021-02-25 電文確認：日付の「/」を削除する。 孫 end
    Pattern p = Pattern.compile("^(\\d{4})(\\d{2})(\\d{2})");
    Matcher m = p.matcher(s);
    if (m.matches()) {
      s = String.join("-", m.group(1), m.group(2), m.group(3));
    }

    return Timestamp.valueOf(s + " 00:00:00");
  }
}
