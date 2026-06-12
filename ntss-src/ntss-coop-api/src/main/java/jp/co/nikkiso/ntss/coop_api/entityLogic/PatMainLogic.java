package jp.co.nikkiso.ntss.coop_api.entityLogic;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import org.apache.commons.collections4.CollectionUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import tools.jackson.databind.JavaType;

import jp.co.nikkiso.ntss.coop_api.service.LogService;
import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.coop_api.utils.CheckNecessaryParamUtil;
import jp.co.nikkiso.ntss.coop_api.utils.ClockWrapper;
import jp.co.nikkiso.ntss.coop_api.utils.EntityCreatorUtil;
import jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants;
import jp.co.nikkiso.ntss.coop_api.utils.ListReplacerUtil;
import jp.co.nikkiso.ntss.coop_api.utils.MaxCtlNoUtil;
import jp.co.nikkiso.ntss.core.dao.MstDeviceSetInfoDefaultDao;
import jp.co.nikkiso.ntss.core.dao.MstImplantDao;
import jp.co.nikkiso.ntss.core.dao.MstInfectionDao;
import jp.co.nikkiso.ntss.core.dao.MstPatMemoDao;
import jp.co.nikkiso.ntss.core.dao.MstTabooAllergyDao;
import jp.co.nikkiso.ntss.core.dao.MstUserAuthenticationDao;
import jp.co.nikkiso.ntss.core.entity.DeviceSetInfo;
import jp.co.nikkiso.ntss.core.entity.MstPatMemo;
import jp.co.nikkiso.ntss.core.entity.MstUserAuthentication;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;

/**
 * 電文から抽出した項目に基づき、{@link PatMain}エンティティを作成するクラス。
 */
@Component
public class PatMainLogic implements EntityLogic {

  private static final String[] DAYS_OF_WEEK = {
      "1", "2", "3", "4", "5", "6", "7"
  };

  @Autowired
  private MstPatMemoDao mstPatMemoDao;

  @Autowired
  private MstUserAuthenticationDao mstUserAuthenticationDao;

  @Autowired
  private MstTabooAllergyDao mstTabooAllergyDao;

  @Autowired
  private MstInfectionDao mstInfectionDao;

  @Autowired
  private MstImplantDao mstImplantDao;

  @Autowired
  private MstDeviceSetInfoDefaultDao mstDeviceSetInfoDefaultDao;

  @Autowired
  private LogService logService;

  @Autowired
  private ClockWrapper clockWrapper;

  /**
   * マップからエンティティを作成する。
   *
   * @param paramMap カラム名とカラム値のマップ
   * @return エンティティ
   * @see jp.co.nikkiso.ntss.coop_api.entityLogic.EntityLogic#createEntity(java.util.Map)
   */
  @Override
  public Object createEntity(Map<String, Object> paramMap) {
    return EntityCreatorUtil.createEntity(PatMain.class, paramMap);
  }

  /**
   * pat_mainテーブルに登録する値を編集する。（新規登録時用）
   *
   * @param facilityCd 施設コード
   * @param paramMap 電文から抽出した項目のマップ
   * @see jp.co.nikkiso.ntss.coop_api.entityLogic.EntityLogic#check(java.lang.String, java.util.Map)
   */
  @Override
  public void check(String facilityCd, Map<String, Object> paramMap) {
    checkCommon(facilityCd, paramMap);

    // pat_memo_info
    checkPatMemoInfo(facilityCd, "pat_memo_info", paramMap, null);

    // charge_staff_info
    checkChargeStaffInfo(facilityCd, "charge_staff_info", paramMap, null);

    // pat_group_info
    // 対象外

    // taboo_allergy_info
    checkTabooAllergyInfo(facilityCd, "taboo_allergy_info", paramMap, null);

    // infect_info
    checkInfectInfo(facilityCd, "infect_info", paramMap, null);

    // implant_info
    checkImplantInfo(facilityCd, "implant_info", paramMap, null);

    // 新規登録の場合のみ、tare_info、off_water_info、device_set_infoを設定する。

    // tare_info
    makeTareInfo(facilityCd, "tare_info", paramMap);

    // off_water_info
    makeOffWaterInfo(facilityCd, "off_water_info", paramMap);

    // device_set_info
    makeDeviceSetInfo(facilityCd, "device_set_info", paramMap);

    // reg_date
    Timestamp now = new Timestamp(clockWrapper.getClockMillis());
    paramMap.put("reg_date", now);
  }

  /**
   * pat_mainテーブルに登録する値を編集する。（更新時用）
   *
   * @param facilityCd 施設コード
   * @param paramMap 電文から抽出した項目のマップ
   * @param entity 対象テーブルから取得したエンティティ（更新の場合に使用）
   * @see jp.co.nikkiso.ntss.coop_api.entityLogic.EntityLogic#check(java.lang.String, java.util.Map, java.lang.Object)
   */
  @Override
  public void check(String facilityCd, Map<String, Object> paramMap, Object entity) {
    checkCommon(facilityCd, paramMap);

    // チェックと同時に、変換の必要なカラムは値を置き換える。
    // paramMap引数がDB登録/更新に使用される。

    // pat_idはparamMapに設定しておく。

    PatMain pm = (PatMain) entity;

    // pat_memo_info
    checkPatMemoInfo(facilityCd, "pat_memo_info", paramMap, pm.getPat_memo_info());

    // addition_info
    // 本体側の設計が未完のため現在非対応

    // charge_staff_info
    checkChargeStaffInfo(facilityCd, "charge_staff_info", paramMap, pm.getCharge_staff_info());

    // pat_group_info
    // 対象外

    // taboo_allergy_info
    checkTabooAllergyInfo(facilityCd, "taboo_allergy_info", paramMap, pm.getTaboo_allergy_info());

    // infect_info
    checkInfectInfo(facilityCd, "infect_info", paramMap, pm.getInfect_info());

    // implant_info
    checkImplantInfo(facilityCd, "implant_info", paramMap, pm.getImplant_info());
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

    // facility_cd
    CheckNecessaryParamUtil.checkRequired("facility_cd", facilityCd);
    // 本メソッドのfacilityCdは呼び出し元で与えるが、pat_main登録/更新時にはエンティティに設定されていなければならない。

    // acceptance_status_info
    // 連携対象外

    paramMap.putIfAbsent("is_del", JournalConvertConstants.LOGICAL_DELETE_FLAG_OFF);

    // up_date
    Timestamp now = new Timestamp(clockWrapper.getClockMillis());
    paramMap.put("up_date", now);
  }

  /**
   *
   * @param keyName
   * @param paramMap
   * @param patMemoInfoStr
   */
  private void checkPatMemoInfo(String facilityCd, String keyName, Map<String, Object> paramMap,
      String patMemoInfoStr) {
    String content = (String) paramMap.get("content");
    EventLogMessage eventLogMessage = new EventLogMessage();
    if (StringUtils.isEmpty(content)) {
      eventLogMessage.setLogMessage("患者メモにcontentが指定されていないため、チェックをスキップします。");
      eventLogMessage.setFacilityCd(facilityCd);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return;
    }

    MstPatMemo mpm = mstPatMemoDao.selectByContent(facilityCd, content);

    try {
      long ctlNo;
      List<Map<String, Object>> patMemoInfo;

      if (StringUtils.isEmpty(patMemoInfoStr)) {
        patMemoInfo = new ArrayList<>();
        ctlNo = 1L;
      } else {
        patMemoInfo = ObjectMapperUtil.readListOfMap(patMemoInfoStr);
        ctlNo = MaxCtlNoUtil.getCtlNoMax(patMemoInfo) + 1;
      }

      // ctl_no,title,contentの3要素を含むマップを作成する。
      Map<String, Object> m = createPatMemoInfoMap(ctlNo, mpm.getTitle(), mpm.getContent());
      patMemoInfo.add(m);

      paramMap.put(keyName, patMemoInfo);

    } catch (IOException e) {
      eventLogMessage.setLogMessage("患者メモ情報のエンティティの作成でエラーが発生しました。");
      eventLogMessage.setFacilityCd(facilityCd);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      throw new NtssException("患者メモ情報のエンティティの作成でエラーが発生しました。", e);
    }
  }

  /**
   * 患者メモ情報のエントリを作成する。
   *
   * @param ctlNo 管理番号
   * @param title タイトル
   * @param content 内容
   * @return 患者メモ情報のエントリ
   */
  private Map<String, Object> createPatMemoInfoMap(long ctlNo, String title, String content) {
    Map<String, Object> result = new HashMap<>();

    result.put("ctl_no", ctlNo);
    result.put("title", title);
    result.put("content", content);

    return result;
  }

  /**
   * 担当スタッフ情報をチェックする。
   *
   * @param facilityCd 施設コード
   * @param keyName キー名（"charge_staff_info" 固定）
   * @param paramMap 電文から抽出した項目
   * @param chargeStaffInfo 既存PatMainレコード中の担当スタッフ情報
   */
  private void checkChargeStaffInfo(String facilityCd, String keyName, Map<String, Object> paramMap,
      String chargeStaffInfoStr) {
    // 担当スタッフ情報が抽出されていなければ何もしない。
    Object obj = paramMap.get(keyName);
    if (obj == null) {
      return;
    }

    // paramMapは以下の構造である。
    // キー=レイアウトのcol属性の値のうち、テーブルのカラム名。
    // 値=カラムに登録する値。カラムの型によりString, Long等異なる。カラムの型がjsonbである場合、値自体もマップである。
    // （値の型の共通のスーパークラスはObject）

    List<Map<String, Object>> chargeStaffInfoParamList = ObjectMapperUtil.castToStringObjectMapList(obj);
    if (CollectionUtils.isEmpty(chargeStaffInfoParamList)) {
      return;
    }

    // 既存レコードをリストに変換
    List<Map<String, Object>> chargeStaffInfoList;
    long ctlNo;

    if (StringUtils.isEmpty(chargeStaffInfoStr)) {
      chargeStaffInfoList = new ArrayList<>();
      ctlNo = 1;
    } else {
      try {
        chargeStaffInfoList = ObjectMapperUtil.readListOfMap(chargeStaffInfoStr);
        ctlNo = MaxCtlNoUtil.getCtlNoMax(chargeStaffInfoList) + 1;
      } catch (IOException e) {
        throw new NtssException("担当スタッフ情報チェックでエラーが発生しました。", e);
      }
    }

    EventLogMessage eventLogMessage = new EventLogMessage();
    // 電文抽出内容から追加
    for (Map<String, Object> chargeStaffInfoParam : chargeStaffInfoParamList) {
      String staffCd = (String) chargeStaffInfoParam.get("staff_cd");
      CheckNecessaryParamUtil.checkRequired("staff_cd", staffCd);

      MstUserAuthentication mua = mstUserAuthenticationDao.selectForLogin(staffCd, facilityCd);
      if (mua == null) {
        String errMsg = String.format("指定された担当スタッフレコードが存在しません。 facilityCd:[%s], staffCd:[%s]", facilityCd, staffCd);
        eventLogMessage.setLogMessage(errMsg);
        eventLogMessage.setFacilityCd(facilityCd);
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
        eventLogMessage.setInvokeClass(this.getClass().getName());
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        throw new NtssException(errMsg);
      }

      // 既存レコードとの照合

      Map<String, Object> recordMap = new HashMap<>(chargeStaffInfoParam);
      recordMap.put("staff_cd", mua.getUserId());

      if (!hasStaffCd(chargeStaffInfoList, mua.getUserId())) {
        // 新規のスタッフの場合のみ

        recordMap.put("ctl_no", ctlNo);
        recordMap.put("disp_order", ctlNo);

        // 主治医指定があればオンにする
        if (chargeStaffInfoParam.containsKey("is_main")) {
          recordMap.put("is_main", chargeStaffInfoParam.get("is_main"));
        }

        // 受持ち指定があればオンにする
        if (chargeStaffInfoParam.containsKey("is_charge")) {
          recordMap.put("is_charge", chargeStaffInfoParam.get("is_charge"));
        }

        chargeStaffInfoList.add(recordMap);
      }
    }

    paramMap.put(keyName, chargeStaffInfoList);
  }

  /**
   * 禁忌・アレルギー情報をチェックする。
   *
   * @param facilityCd 施設コード
   * @param keyName キー名（"taboo_allery_info"）
   * @param paramMap 電文から抽出した項目
   * @param tabooAllergyInfoStr 既存PatMainレコード中の禁忌・アレルギー情報
   */
  private void checkTabooAllergyInfo(String facilityCd, String keyName, Map<String, Object> paramMap,
      String tabooAllergyInfoStr) {
    final String KEY_TABOO_ALLERGY_CD = "taboo_allergy_cd";
    final String KEY_TABOO_ALLERGY_CLASS = "taboo_allergy_class";

    Object obj = paramMap.get(keyName);
    if (obj == null) {
      return;
    }

    List<Map<String, Object>> paramList = ObjectMapperUtil.castToStringObjectMapList(obj);
    if (CollectionUtils.isEmpty(paramList)) {
      return;
    }

    // 既存レコードをリストに変換
    List<Map<String, Object>> tabooAllergyInfo;

    if (StringUtils.isEmpty(tabooAllergyInfoStr)) {
      tabooAllergyInfo = new ArrayList<>();
    } else {
      try {
        tabooAllergyInfo = ObjectMapperUtil.readListOfMap(tabooAllergyInfoStr);
      } catch (IOException e) {
        throw new NtssException("禁忌・アレルギー情報チェックでエラーが発生しました。", e);
      }
    }

    for (Map<String, Object> param : paramList) {
      // taboo_allergy_cdとtaboo_allergy_classの一方のみが存在する場合はエラーとする。
      boolean isTabooAllergyCdSpecified = param.containsKey(KEY_TABOO_ALLERGY_CD);
      boolean isTabooAllertyClassSpecified = param.containsKey(KEY_TABOO_ALLERGY_CLASS);
      if (isTabooAllergyCdSpecified ^ isTabooAllertyClassSpecified) {
        throw new NtssException("taboo_allergy_cdとtaboo_allergy_classの一方のみが指定されています。");
      }

      String tabooAllergyCd = Objects.toString(param.get(KEY_TABOO_ALLERGY_CD), "");

      // 電文から抽出したアレルギーコード（taboo_allergy_cd）が""の場合
      // マスタ照合をスキップし、taboo_allergy_info内のエントリを作成しない。
      if (StringUtils.isEmpty(tabooAllergyCd)) {
        continue;
      }

      Integer tabooAllergyCdResult = mstTabooAllergyDao.selectByInHospitalCd1(facilityCd, tabooAllergyCd);
      param.put(KEY_TABOO_ALLERGY_CD, tabooAllergyCdResult);

      // taboo_allergy_cdがすでにある場合には上書き。なければ追加。
      ListReplacerUtil.replaceOrAdd(tabooAllergyInfo, param, KEY_TABOO_ALLERGY_CD);

      // TODO category_classの値により参照するマスタが異なる。
    }

    paramMap.put(keyName, tabooAllergyInfo);
  }

  /**
   * 感染症情報をチェックする。
   *
   * @param facilityCd 施設コード
   * @param keyName キー名（"infect_info"）
   * @param paramMap 電文から抽出した項目
   * @param infectInfoStr 既存PatMainレコード中の感染症情報
   */
  private void checkInfectInfo(String facilityCd, String keyName, Map<String, Object> paramMap, String infectInfoStr) {
    final String KEY_INFECTION_CD = "infection_cd";
    final String KEY_INFECT = "infect";

    Object obj = paramMap.get(keyName);
    if (obj == null) {
      return;
    }

    List<Map<String, Object>> paramList = ObjectMapperUtil.castToStringObjectMapList(paramMap.get(keyName));
    if (CollectionUtils.isEmpty(paramList)) {
      return;
    }

    // 既存レコードをリストに変換
    List<Map<String, Object>> infectInfo;

    if (StringUtils.isEmpty(infectInfoStr)) {
      infectInfo = new ArrayList<>();
    } else {
      try {
        infectInfo = ObjectMapperUtil.readListOfMap(infectInfoStr);
      } catch (IOException e) {
        throw new NtssException("感染症情報チェックでエラーが発生しました。", e);
      }
    }

    for (Map<String, Object> param : paramList) {
      // infection_cdのマスタ照合と変換
      String infectionCd = Objects.toString(param.get(KEY_INFECTION_CD), "");
      String infect = Objects.toString(param.get(KEY_INFECT), "");

      // 電文から抽出した感染症コード（infection_cd）および結果コード（infect）が""の場合
      // マスタ照合をスキップし、infect_info内のエントリを作成しない。
      if (StringUtils.isEmpty(infectionCd) || StringUtils.isEmpty(infect)) {
        continue;
      }

      Integer infectionCdResult = mstInfectionDao.selectByInHospitalCd1(facilityCd, infectionCd);
      param.put(KEY_INFECTION_CD, infectionCdResult);

      // infection_cdがすでにある場合には上書き。なければ追加。
      ListReplacerUtil.replaceOrAdd(infectInfo, param, KEY_INFECTION_CD);
    }

    paramMap.put(keyName, infectInfo);
  }

  /**
   * インプラント情報をチェックする。
   *
   * @param facilityCd 施設コード
   * @param keyName キー名（"implant_info"）
   * @param paramMap 電文から抽出した項目
   * @param implantInfoStr 既存PatMainレコード中のインプラント情報
   */
  private void checkImplantInfo(String facilityCd, String keyName, Map<String, Object> paramMap,
      String implantInfoStr) {
    final String KEY_IMPLANT_CD = "implant_cd";

    Object obj = paramMap.get(keyName);
    if (obj == null) {
      return;
    }

    List<Map<String, Object>> paramList = ObjectMapperUtil.castToStringObjectMapList(paramMap.get(keyName));
    if (CollectionUtils.isEmpty(paramList)) {
      return;
    }

    // 既存レコードをリストに変換
    List<Map<String, Object>> implantInfo;

    if (StringUtils.isEmpty(implantInfoStr)) {
      implantInfo = new ArrayList<>();
    } else {
      try {
        implantInfo = ObjectMapperUtil.readListOfMap(implantInfoStr);
      } catch (IOException e) {
        throw new NtssException("インプラント情報チェックでエラーが発生しました。", e);
      }
    }

    for (Map<String, Object> param : paramList) {
      //      paramMap.put(keyName, param);

      // implant_cdのマスタ照合と変換
      String implantCd = (String) param.get(KEY_IMPLANT_CD);

      Integer implantCdResult = mstImplantDao.selectByInHospitalCd1(facilityCd, implantCd);
      param.put(KEY_IMPLANT_CD, implantCdResult);

      // implant_cdがすでにある場合には上書き。なければ追加。
      ListReplacerUtil.replaceOrAdd(implantInfo, param, KEY_IMPLANT_CD);
    }

    paramMap.put(keyName, implantInfo);
  }

  /**
   * 風袋補正情報のエントリを登録する。
   *
   * @param facilityCd 施設コード
   * @param keyName キー名（"tare_info"）
   * @param paramMap エンティティ作成用パラメータマップ
   */
  private void makeTareInfo(String facilityCd, String keyName, Map<String, Object> paramMap) {
    // 新規作成時のみ、mst_device_set_info.tare_infoを7日分設定する。

    List<DeviceSetInfo> infoList = mstDeviceSetInfoDefaultDao.selectTareAndOffWater(facilityCd);
    if (CollectionUtils.isEmpty(infoList)) {
      String errMsg = String.format("風袋補正情報の取得でエラーが発生しました。 施設コード:[%s]", facilityCd);
      throw new NtssException(errMsg);
    }

    DeviceSetInfo info = infoList.get(0);

    try {
      Map<String, Map<String, String>> result = make7DaysEntry(info.getTare_info());
      paramMap.put(keyName, result);

    } catch (IOException e) {
      String errMsg = String.format("風袋補正情報の取得でエラーが発生しました。 施設コード:[%s]", facilityCd);
      throw new NtssException(errMsg, e);
    }
  }

  /**
   * 除水補正情報のエントリを登録する。
   *
   * @param facilityCd 施設コード
   * @param keyName キー名（"off_water_info"）
   * @param paramMap エンティティ作成用パラメータマップ
   */
  private void makeOffWaterInfo(String facilityCd, String keyName, Map<String, Object> paramMap) {
    // 新規作成時のみ、mst_device_set_info.off_water_infoを7日分設定する。

    List<DeviceSetInfo> infoList = mstDeviceSetInfoDefaultDao.selectTareAndOffWater(facilityCd);
    if (CollectionUtils.isEmpty(infoList)) {
      String errMsg = String.format("除水補正情報の取得でエラーが発生しました。 施設コード:[%s]", facilityCd);
      throw new NtssException(errMsg);
    }

    DeviceSetInfo info = infoList.get(0);

    try {
      Map<String, Map<String, String>> result = make7DaysEntry(info.getOff_water_info());
      paramMap.put(keyName, result);

    } catch (IOException e) {
      String errMsg = String.format("除水補正情報の取得でエラーが発生しました。 施設コード:[%s]", facilityCd);
      throw new NtssException(errMsg, e);
    }
  }

  /**
   * 1日分のエントリテンプレートから7日分のエントリを作成する。
   *
   * @param s テンプレート文字列
   * @return 7日分のエントリ
   * @throws IOException
   */
  private Map<String, Map<String, String>> make7DaysEntry(String s) throws IOException {
    JavaType colType = ObjectMapperUtil.constructMapType(String.class, String.class);
    Map<String, String> template = ObjectMapperUtil.read(s, colType);
    Map<String, Map<String, String>> result = new HashMap<>();

    for (String day : DAYS_OF_WEEK) {
      result.put(day, template);
    }

    return result;
  }

  /**
   * 装置設定情報のエントリを登録する。
   *
   * @param facilityCd 施設コード
   * @param keyName キー名（"off_water_info"）
   * @param paramMap エンティティ作成用パラメータマップ
   */
  private void makeDeviceSetInfo(String facilityCd, String keyName, Map<String, Object> paramMap) {
    // 新規作成時のみ、mst_device_set_info.device_set_infoを設定する。

    try {
      String setInfoStr = mstDeviceSetInfoDefaultDao.selectDeviceSetInfo(facilityCd);
      // mod 2021-02-09 電文確認：装置設定情報のMapのJavaTypeを修正する。 孫 start
//      JavaType colType = ObjectMapperUtil.constructMapType(String.class, String.class);
//      Map<String, String> template = ObjectMapperUtil.read(setInfoStr, colType);
      JavaType colType = ObjectMapperUtil.constructMapType(String.class, Object.class);
      Map<String, Object> template = ObjectMapperUtil.read(setInfoStr, colType);
      // mod 2021-02-09 電文確認：装置設定情報のMapのJavaTypeを修正する。 孫 end

      paramMap.put(keyName, template);
    } catch (IOException e) {
      String errMsg = String.format("装置設定情報の取得でエラーが発生しました。 施設コード:[%s]", facilityCd);
      throw new NtssException(errMsg, e);
    }
  }

  /**
   * スタッフコードが既存か判定する。
   *
   * @param chargeStaffInfo 担当スタッフ情報
   * @param staffCdStr スタッフコード
   * @return 既存であればtrue、存在しない場合はfalse
   */
  private boolean hasStaffCd(List<Map<String, Object>> chargeStaffInfo, Long staffCd) {
    if (CollectionUtils.isEmpty(chargeStaffInfo)) {
      return false;
    }

    return chargeStaffInfo.stream().anyMatch(e -> MaxCtlNoUtil.longValue(e.get("staff_cd")) == staffCd);
  }
}
