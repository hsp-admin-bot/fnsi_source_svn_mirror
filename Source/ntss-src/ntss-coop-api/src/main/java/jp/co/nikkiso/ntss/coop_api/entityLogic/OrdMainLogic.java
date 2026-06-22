package jp.co.nikkiso.ntss.coop_api.entityLogic;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.CollectionUtils;

import tools.jackson.databind.JavaType;

import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.coop_api.utils.CheckNecessaryParamUtil;
import jp.co.nikkiso.ntss.coop_api.utils.ClockWrapper;
import jp.co.nikkiso.ntss.coop_api.utils.EntityCreatorUtil;
import jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants;
import jp.co.nikkiso.ntss.core.dao.MstDeviceSetInfoDefaultDao;
import jp.co.nikkiso.ntss.core.entity.DeviceSetInfo;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.exception.NtssException;

/**
 * 電文から抽出した項目に基づき、{@link OrdMain}エンティティを作成するクラス。
 */
@Component
public class OrdMainLogic implements EntityLogic {

  private static final String[] DAYS_OF_WEEK = {
      "1", "2", "3", "4", "5", "6", "7"
  };

  @Autowired
  private ClockWrapper clockWrapper;

  @Autowired
  private MstDeviceSetInfoDefaultDao mstDeviceSetInfoDefaultDao;

  /**
   * マップからエンティティを作成する。
   *
   * @param paramMap カラム名とカラム値のマップ
   * @return エンティティ
   * @see jp.co.nikkiso.ntss.coop_api.entityLogic.EntityLogic#createEntity(java.util.Map)
   */
  @Override
  public Object createEntity(Map<String, Object> paramMap) {
    return EntityCreatorUtil.createEntity(OrdMain.class, paramMap);
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
    // 共通チェック処理
    checkCommon(facilityCd, paramMap);

    // tare_info
    makeTareInfo(facilityCd, "ind_tare_info", paramMap);

    // off_water_info
    makeOffWaterInfo(facilityCd, "ind_off_water_info", paramMap);

    // device_set_info
    makeDeviceSetInfo(facilityCd, "ind_device_set_info", paramMap);
  }

  /**
   * 電文から抽出した項目をチェックおよび編集する。（更新時用）
   *
   * @param facilityCd 施設コード
   * @param paramMap 電文から抽出した項目のマップ
   * @param entity OrdMainエンティティ
   * @see jp.co.nikkiso.ntss.coop_api.entityLogic.EntityLogic#check(java.lang.String, java.util.Map, Object)
   */
  @Override
  public void check(String facilityCd, Map<String, Object> paramMap, Object entity) {
    checkCommon(facilityCd, paramMap);
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

    paramMap.putIfAbsent("is_del", JournalConvertConstants.LOGICAL_DELETE_FLAG_OFF);

    // up_date
    Timestamp now = new Timestamp(clockWrapper.getClockMillis());
    paramMap.put("up_date", now);
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
   * @param keyName キー名（"ind_device_set_info"）
   * @param paramMap エンティティ作成用パラメータマップ
   */
  private void makeDeviceSetInfo(String facilityCd, String keyName, Map<String, Object> paramMap) {
    // 新規作成時のみ、mst_device_set_info.device_set_infoを設定する。

    try {
      String setInfoStr = mstDeviceSetInfoDefaultDao.selectDeviceSetInfo(facilityCd);
      JavaType colType = ObjectMapperUtil.constructMapType(String.class, String.class);
      Map<String, String> template = ObjectMapperUtil.read(setInfoStr, colType);

      paramMap.put(keyName, template);
    } catch (IOException e) {
      String errMsg = String.format("装置設定情報の取得でエラーが発生しました。 施設コード:[%s]", facilityCd);
      throw new NtssException(errMsg, e);
    }
  }

}
