package jp.co.nikkiso.ntss.coop_api.entityLogic;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.apache.commons.collections4.CollectionUtils;
import org.apache.commons.collections4.MapUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import jp.co.nikkiso.ntss.coop_api.service.LogService;
import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.coop_api.utils.CheckNecessaryParamUtil;
import jp.co.nikkiso.ntss.coop_api.utils.ClockWrapper;
import jp.co.nikkiso.ntss.coop_api.utils.EntityCreatorUtil;
import jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants;
import jp.co.nikkiso.ntss.coop_api.utils.ListReplacerUtil;
import jp.co.nikkiso.ntss.coop_api.utils.MaxCtlNoUtil;
import jp.co.nikkiso.ntss.core.dao.MstDialysisDifficultyDao;
import jp.co.nikkiso.ntss.core.dao.MstDiseaseDao;
import jp.co.nikkiso.ntss.core.dao.MstRelationshipDao;
import jp.co.nikkiso.ntss.core.dao.MstSeverityDao;
import jp.co.nikkiso.ntss.core.dao.MstTransportDao;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;

/**
 * 電文から抽出した項目に基づき、{@link PatPersonalMain}エンティティを作成するクラス。
 */
@Component
public class PatPersonalMainLogic implements EntityLogic {

  /**
   * 透析困難情報（JSON形式項目）のキー
   */
  private static final String[] DIAL_DIFF_COM_INFO_KEYS = {
      "is_main",
      "is_dial_diff"
  };

  /**
   * 本人連絡先情報（JSON形式項目）のキー。
   */
  private static final String[] PAT_CONTACT_INFO_KEYS = {
      "zip_cd",
      "address",
      "tel1",
      "tel2",
      "fax",
      "e_mail",
      "work_name",
      "work_tel",
      "memo1",
      "memo2"
  };

  /**
   * 連絡先情報（JSON形式項目）のキー。
   */
  private static final String[] OTHER_CONTACT_INFO_KEYS = {
      "is_key_person",
      "pat_id",
      "last_name",
      "first_name",
      "last_name_kana",
      "first_name_kana",
      "relation_cd",
      "relation_name",
      "zip_cd",
      "address",
      "tel1",
      "tel2",
      "fax",
      "e_mail",
      "work_name",
      "work_tel",
      "memo1",
      "memo2"
  };
  /**
   * 半角スペース
   */
  private static final String EMPTY_HANKAKU_STR = " ";
  /**
   * 全角スペース
   */
  private static final String EMPTY_ZENKAKU_STR = "　";

  @Autowired
  private MstDiseaseDao mstDiseaseDao;

  @Autowired
  private MstDialysisDifficultyDao mstDialysisDifficultyDao;

  @Autowired
  private MstSeverityDao mstSeverityDao;

  @Autowired
  private MstTransportDao mstTransportDao;

  @Autowired
  private MstRelationshipDao mstRelationshipDao;

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
  public Object createEntity(Map<String, Object> paramMap) {
    return EntityCreatorUtil.createEntity(PatPersonalMain.class, paramMap);
  }

  /**
   * pat_personal_mainテーブルに登録する値をチェックし編集する。（新規登録時用）
   *
   * @param facilityCd 施設コード
   * @param paramMap 電文から抽出した項目のマップ
   * @see jp.co.nikkiso.ntss.coop_api.entityLogic.EntityLogic#check(java.lang.String, java.util.Map)
   */
  @Override
  public void check(String facilityCd, Map<String, Object> paramMap) {
    checkCommon(facilityCd, paramMap);

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(facilityCd + ":PatPersonalMainLogic.check insert");
    eventLogMessage.setFacilityCd(facilityCd);
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // dial_diff_com_info
    checkDialDiffComInfo(facilityCd, "dial_diff_com_info", paramMap, null);
    eventLogMessage.setLogMessage(facilityCd + ":PatPersonalMainLogic.check paramMap=" + paramMap);
    eventLogMessage.setFacilityCd(facilityCd);
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    checkOtherContactInfo(facilityCd, "other_contact_info", paramMap, null);
  }

  /**
   * pat_personal_mainテーブルに登録する値をチェックし編集する。（更新時用）
   *
   * @param facilityCd 施設コード
   * @param paramMap 電文から抽出した項目のマップ
   * @param entity 対象テーブルから取得したエンティティ（更新の場合に使用）
   * @throws NtssException チェックでエラーが発生した場合
   * @see jp.co.nikkiso.ntss.coop_api.entityLogic.EntityLogic#check(java.lang.String, java.util.Map, java.lang.Object)
   */
  @Override
  public void check(String facilityCd, Map<String, Object> paramMap, Object entity) {
    checkCommon(facilityCd, paramMap);
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(facilityCd + ":PatPersonalMainLogic.check update");
    eventLogMessage.setFacilityCd(facilityCd);
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    PatPersonalMain ppm = (PatPersonalMain) entity;

    // dial_diff_com_info
    checkDialDiffComInfo(facilityCd, "dial_diff_com_info", paramMap, ppm.getDial_diff_com_info());

    // other_contact_info
    checkOtherContactInfo(facilityCd, "other_contact_info", paramMap, ppm.getOther_contact_info());
  }

  /**
   * insert/updateの共通チェック処理。
   *
   * @param facilityCd 施設コード
   * @param paramMap 電文から抽出した項目のマップ
   */
  private void checkCommon(String facilityCd, Map<String, Object> paramMap) {
    // hosp_pat_idの必須チェック
    CheckNecessaryParamUtil.checkRequired("hosp_pat_id", paramMap);

    // pat_id
    // テーブルの主キーでありチェック不要

    // fn_pat_id
    // 対応不要

    // nkk_pat_id
    // 対応不要

    // facility_cd
    CheckNecessaryParamUtil.checkRequired("facility_cd", facilityCd);

    // pat_last_name, pat_first_name
    // CheckNecessaryParamUtil.check("pat_last_name", paramMap);
    // CheckNecessaryParamUtil.check("pat_first_name", paramMap);
    // 設計時に必須としたが、実データを分析したところ、氏名が与えられないケースがあった。
    // 必須とすると連携の運用手順に影響を与えるため、一旦必須を解除する。
    arrangePatName(paramMap);

    // pat_birthday
    getPatBirthday("pat_birthday", paramMap);

    // pat_sex
    // 項目抽出の段階でチェック済

    // nationality
    // 対応不要

    // pat_blood_type_abo, pat_blood_type_rh, pat_blood_type_serovar
    // 項目抽出の段階でチェック済

    // in_out_class
    // 項目抽出の段階でチェック済

    // is_die
    // 項目抽出の段階でチェック済

    // die_cd
    Integer dieCd = getDieCd(facilityCd, "die_cd", paramMap);
    paramMap.put("die_cd", dieCd);

    // severity_cd
    Integer severityCd = getSeverityCd(facilityCd, "severity_cd", paramMap);
    paramMap.put("severity_cd", severityCd);

    // transport_cd
    Integer transportCd = getTransportCd(facilityCd, "transport_cd", paramMap);
    paramMap.put("transport_cd", transportCd);

    // pat_contact_info
    checkPatContactInfo("pat_contact_info", paramMap);

    // vendor_contact_info
    // 対応不要

    // insurance_info
    // 対応不要（別テーブルに移動）

    // is_del
    paramMap.putIfAbsent("is_del", JournalConvertConstants.LOGICAL_DELETE_FLAG_OFF);

    // primary_disease_cd
    Integer primaryDiseaseCd = getPrimaryDiseaseCd(facilityCd, "primary_disease_cd", paramMap);
    paramMap.put("primary_disease_cd", primaryDiseaseCd);

    // temporary_dialysis_cd
    // 仕様不明。確定後に対応する。
  }

  /**
   * 死因コードを取得する。
   *
   * @param facilityCd
   * @param keyName
   * @param paramMap
   * @return
   */
  private Integer getDieCd(String facilityCd, String keyName, Map<String, Object> paramMap) {
    String dieCdStr = (String) paramMap.get(keyName);
    if (StringUtils.isEmpty(dieCdStr)) {
      return null;
    }

    dieCdStr = dieCdStr.trim();

    Integer diseaseCd = mstDiseaseDao.selectByInHospitalCd1(facilityCd, dieCdStr);

    if (diseaseCd == null) {
      String errMsg = String.format("病名コードが取得できません。 facilityCd:[%s], dieCd:[%s]", facilityCd, dieCdStr);
      throw new NtssException(errMsg);
    }

    return diseaseCd;
  }

  /**
   * 透析困難情報をチェックする。
   *
   * @param facilityCd
   * @param keyName
   * @param paramMap
   */
  private void checkDialDiffComInfo(String facilityCd, String keyName, Map<String, Object> paramMap,
      String dialDiffComInfoStr) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    Object obj = paramMap.get(keyName);
    if (obj == null) {
      return;
    }

    List<Map<String, Object>> dialDiffComInfoList = ObjectMapperUtil.castToStringObjectMapList(obj);
    if (CollectionUtils.isEmpty(dialDiffComInfoList)) {
      return;
    }

    // ctl_no
    List<Map<String, Object>> colValue;
    Long ctlNo;

    if (StringUtils.isEmpty(dialDiffComInfoStr)) {
      colValue = new ArrayList<>();
      ctlNo = 1L;
    } else {
      try {
        colValue = ObjectMapperUtil.readListOfMap(dialDiffComInfoStr);
        ctlNo = MaxCtlNoUtil.getCtlNoMax(colValue) + 1;
      } catch (IOException e) {
        String errMsg = String.format("透析困難情報のチェックでエラーが発生しました。 pat_personal_main.dial_diff_com_info:[%s]",
            dialDiffComInfoStr);
        eventLogMessage.setLogMessage(errMsg);
        eventLogMessage.setFacilityCd(facilityCd);
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
        eventLogMessage.setInvokeClass(this.getClass().getName());
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        throw new NtssException(errMsg, e);
      }
    }

    for (Map<String, Object> dialDiffComInfo : dialDiffComInfoList) {
      // 必須キーチェック
      checkRequiredKey(dialDiffComInfo);

      dialDiffComInfo.put("ctl_no", ctlNo);
      ++ctlNo;
      eventLogMessage.setLogMessage(facilityCd + ":PatPersonalMain.checkDialDiffComInfo dialDiffComInfo=" + dialDiffComInfo);
      eventLogMessage.setFacilityCd(facilityCd);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // dial_diff_cd
      Integer dialDiffCd = getDialysisDifficultyCd(facilityCd, keyName, paramMap);
      dialDiffComInfo.put("dial_diff_cd", dialDiffCd);

      // reg_date
      dialDiffComInfo.put("reg_date", clockWrapper.getClockMillis());

      ListReplacerUtil.replaceOrAdd(colValue, dialDiffComInfo, "dial_diff_cd");
      eventLogMessage.setLogMessage(facilityCd + ":PatPersonalMain.checkDialDiffComInfo colValue=" + colValue);
      eventLogMessage.setFacilityCd(facilityCd);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }

    paramMap.put(keyName, colValue);
  }

  /**
   * 透析困難情報の必須キーをチェックする。
   *
   * @param dialDiffComInfo 透析困難情報
   */
  private void checkRequiredKey(Map<String, Object> dialDiffComInfo) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    for (String k : DIAL_DIFF_COM_INFO_KEYS) {
      // キー自体がないのは問題ない。
      if (!dialDiffComInfo.containsKey(k)) {
        continue;
      }

      // キーがあるのに値がブランクなのはNG。
      Object v = dialDiffComInfo.get(k);
      if (v == null) {
        String errMsg = String.format("透析困難情報の項目のうち、キー[%s]に対する値が不正です。", k);
        eventLogMessage.setLogMessage(errMsg);
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
        eventLogMessage.setInvokeClass(this.getClass().getName());
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        throw new NtssException(errMsg);
      }
    }
  }

  /**
   * 透析困難コードを取得する。
   *
   * @param facilityCd 施設コード
   * @param paramMap
   * @return
   */
  private Integer getDialysisDifficultyCd(String facilityCd, String keyName, Map<String, Object> paramMap) {
    List<Map<String, Object>> l = ObjectMapperUtil.castToStringObjectMapList(paramMap.get(keyName));

    // TODO 複数個受信することがあるか?
    Map<String, Object> m = l.get(0);

    String diffCdStr = (String) m.get("dial_diff_com_info");
    // TODO ↑キー名誤り dial_diff_com_info → dial_diff_cd
    Integer dialysisDifficultyCd = mstDialysisDifficultyDao.selectByInHospitalCd1(facilityCd, diffCdStr);

    if (dialysisDifficultyCd == null) {
      String errMsg = String.format("透析困難コードが取得できません。 facility_cd:[%s], severity_cd:[%s]", facilityCd, diffCdStr);
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(errMsg);
      eventLogMessage.setFacilityCd(facilityCd);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      throw new NtssException(errMsg);
    }

    return dialysisDifficultyCd;
  }

  /**
   * 重症度コードを取得する。
   *
   * @param facilityCd 施設コード
   * @param keyName キー名
   * @param paramMap 電文から抽出した項目のマップ
   * @return
   */
  private Integer getSeverityCd(String facilityCd, String keyName, Map<String, Object> paramMap) {
    String severityCdStr = (String) paramMap.get(keyName);
    if (StringUtils.isEmpty(severityCdStr)) {
      return null;
    }

    Integer severityCd = mstSeverityDao.selectByInHospitalCd1(facilityCd, severityCdStr);

    if (severityCd == null) {
      String errMsg = String.format("重症度コードが取得できません。 facility_cd:[%s], severity_cd:[%s]", facilityCd, severityCdStr);
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(errMsg);
      eventLogMessage.setFacilityCd(facilityCd);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      throw new NtssException(errMsg);
    }

    return severityCd;
  }

  /**
   * 搬送区分コードを取得する。
   *
   * @param keyName
   * @param paramMap
   * @return
   */
  private Integer getTransportCd(String facilityCd, String keyName, Map<String, Object> paramMap) {
    String transportCdStr = (String) paramMap.get(keyName);
    if (StringUtils.isEmpty(transportCdStr)) {
      return null;
    }

    Integer transportCd = mstTransportDao.selectByInHospitalCd1(facilityCd, transportCdStr);

    if (transportCd == null) {
      String errMsg = String.format("搬送区分コードが取得できません。 facility_cd:[%s], transport_cd:[%s]", facilityCd, transportCdStr);
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(errMsg);
      eventLogMessage.setFacilityCd(facilityCd);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      throw new NtssException(errMsg);
    }

    return transportCd;
  }

  /**
   * 本人連絡先情報をチェックする。
   *
   * @param keyName
   * @param paramMap
   */
  private void checkPatContactInfo(String keyName, Map<String, Object> paramMap) {
    // 本人連絡先情報カラムはマップ構造。
    // 連携の場合は上書きする。

    Object obj = paramMap.get(keyName);
    if (obj == null) {
      return;
    }

    List<Map<String, Object>> patContactInfoList = ObjectMapperUtil.castToStringObjectMapList(obj);
    if (CollectionUtils.isEmpty(patContactInfoList)) {
      return;
    }

    Map<String, Object> patContactInfo = patContactInfoList.get(0);
    // pat_contact_infoには単一のマップを登録する。
    paramMap.put(keyName, patContactInfo);

    checkBlankValues(keyName, paramMap, PAT_CONTACT_INFO_KEYS);
  }

  /**
   * 連絡先情報をチェックする。
   *
   * @param keyName
   * @String facilityCd
   * @param paramMap
   * @param otherContactInfoStr pat_personal_infoテーブルから取得したother_contact_infoカラムの値
   */
  private void checkOtherContactInfo(String facilityCd, String keyName, Map<String, Object> paramMap,
      String otherContactInfoStr) {
    Object obj = paramMap.get(keyName);
    if (obj == null) {
      return;
    }

    checkBlankValues(keyName, paramMap, OTHER_CONTACT_INFO_KEYS);

    List<Map<String, Object>> l = ObjectMapperUtil.castToStringObjectMapList(obj);
    if (CollectionUtils.isEmpty(l)) {
      return;
    }

    List<Map<String, Object>> checkedList = new ArrayList<>();
    long ctlNo = MaxCtlNoUtil.getCtlNoMax(otherContactInfoStr);
    for (Map<String, Object> m : l) {
      // ctl_no, disp_orderの計算
      String ctlNoStr = String.valueOf(ctlNo);
      m.put("ctl_no", ctlNoStr);
      m.put("disp_order", ctlNoStr);
      ++ctlNo;

      // relation_cdの変換
      String relationCdStr = (String) m.get("relation_cd");
      Integer relationCd = getRelationCd(facilityCd, relationCdStr);
      m.put("relation_cd", String.valueOf(relationCd));

      // TODO relation_cdが指定されていない場合は本人として扱う。
      // →本人を示す続柄コードを取得する方法は何か。
      // （0固定、本人を示すフラグをmst_relationshipテーブルに追加、relationship_name='本人'で検索等）

      checkedList.add(m);
    }

    paramMap.put(keyName, checkedList);
  }

  /**
   * キーが指定されているが値がブランクである項目があるかチェックする。
   *
   * @param keyName
   * @param paramMap
   * @param keys 項目のキー名
   */
  private void checkBlankValues(String keyName, Map<String, Object> paramMap, String[] keys) {
    Object obj = paramMap.get(keyName);
    if (obj == null) {
      return;
    }

    // 空の場合は何もしない。
    if (obj instanceof List) {
      List<Map<String, Object>> l = ObjectMapperUtil.castToStringObjectMapList(obj);
      if (CollectionUtils.isEmpty(l)) {
        return;
      }
    }

    if (obj instanceof Map) {
      Map<String, Object> m = ObjectMapperUtil.castToStringObjectMap(obj);
      if (MapUtils.isEmpty(m)) {
        return;
      }
    }

    // TODO keysを使用したチェックを実施していない。
  }

  /**
   * 続柄コードを取得する。
   *
   * @param facilityCd 施設コード
   * @param keyName other_contact_info（JSON構造データ）内で続柄コードを示すフィールド名称
   * @param paramMap
   * @return 続柄コード
   */
  private Integer getRelationCd(String facilityCd, String relationCdStr) {
    Integer relationCd = mstRelationshipDao.selectByInHospitalCd1(facilityCd, relationCdStr);
    if (relationCd == null) {
      String errMsg = String.format("続柄コードが取得できません。 facilityCd:[%s], relationCd:[%s]", facilityCd, relationCdStr);
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(errMsg);
      eventLogMessage.setFacilityCd(facilityCd);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      throw new NtssException(errMsg);
    }

    return relationCd;
  }

  /**
   * 原疾患コードを取得する。
   *
   * @param facilityCd
   * @param keyName
   * @param paramMap
   * @return 原疾患コード
   */
  private Integer getPrimaryDiseaseCd(String facilityCd, String keyName, Map<String, Object> paramMap) {
    String primaryDiseaseCdStr = (String) paramMap.get("primary_disease_cd");
    if (StringUtils.isEmpty(primaryDiseaseCdStr)) {
      return null;
    }

    // TODO マスタ参照で解決すべきコードには、1カラムに対応するものとJSON内の1キーであるものが混在している。

    Integer result = mstDiseaseDao.selectByInHospitalCd1(facilityCd, primaryDiseaseCdStr);

    if (result == null) {
      String errMsg = String.format("病名コードが取得できません。 facilityCd:[%s], primaryDiseaseCd:[%s]", facilityCd,
          primaryDiseaseCdStr);
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(errMsg);
      eventLogMessage.setFacilityCd(facilityCd);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      throw new NtssException(errMsg);
    }

    return result;
  }

  /**
   * スペースを含む患者氏名を調整する
   * @param paramMap  電文から抽出した項目のマップ
   */
  private void arrangePatName(Map<String, Object> paramMap) {
    //患者氏名(漢字姓名)
    setPatName(paramMap, "pat_last_name", "pat_first_name", false);
    ////患者氏名(カタカナ姓名)
    setPatName(paramMap, "pat_last_name_kana", "pat_first_name_kana", false);
    //患者氏名(英字姓名)
    setPatName(paramMap, "pat_last_name_alpha", "pat_first_name_alpha", true);
  }

  /**
   * スペースを含む患者氏名を分割する
   * @param paramMap  電文から抽出した項目のマップ
   * @param lastNameKey 患者氏名(姓のキー)
   * @param firstNameKey 患者氏名(名のキー)
   * @param isAlpha 英字かどうか
   */
  private void setPatName(Map<String, Object> paramMap, String lastNameKey, String firstNameKey, boolean isAlpha) {
    //患者氏名(姓)
    String patLastName = (String)paramMap.get(lastNameKey);
    //患者氏名(名)
    String patFirstName = (String)paramMap.get(firstNameKey);
    //名が空ではない OR 姓が空の場合には対象外
    if (!StringUtils.isEmpty(patFirstName) || StringUtils.isEmpty(patLastName)) {
      return;
    }
    //半角、全角スペースを分割
    String regex = "[" + EMPTY_HANKAKU_STR + EMPTY_ZENKAKU_STR + "]";
    String[] patNameArray = patLastName.split(regex);
    if (patNameArray.length <= 1) {
      return;
    }
    //スペースが含まれている場合、分割対象
    if (patNameArray.length > 1) {
      //分割した姓
      String arrangedPatLastName;
      //英字姓名の場合は一番最後が姓
      //漢字、カタカナ姓名の場合は一番前が姓
      arrangedPatLastName = isAlpha ? patNameArray[patNameArray.length -1] : patNameArray[0];
      //分割した姓名をセットする
      paramMap.put(lastNameKey, StringUtils.trimWhitespace(arrangedPatLastName));
      paramMap.put(firstNameKey, StringUtils.trimWhitespace(patLastName.replace(arrangedPatLastName, "")));
    }
  }

  /**
   * 生年月日をDB登録用に変換
   *
   * @param keyName Mapのキー
   * @param paramMap Map
   * @return yyyyMMdd形式
   * */
  private void getPatBirthday(String keyName, Map<String, Object> paramMap) {
    if (!paramMap.containsKey(keyName)) {
      // mapに存在しない場合は何もしない
      return;
    }
    String date = (String)paramMap.get(keyName);
    if (StringUtils.isEmpty(date)) {
      return;
    }
    date = date.replaceAll("-", "");
    // yyyyMMdd
    paramMap.put(keyName, date);
  }
}
