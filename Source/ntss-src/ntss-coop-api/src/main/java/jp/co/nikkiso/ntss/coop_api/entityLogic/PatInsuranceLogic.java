package jp.co.nikkiso.ntss.coop_api.entityLogic;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import jp.co.nikkiso.ntss.coop_api.service.LogService;
import jp.co.nikkiso.ntss.coop_api.utils.CheckNecessaryParamUtil;
import jp.co.nikkiso.ntss.coop_api.utils.EntityCreatorUtil;
import jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants;
import jp.co.nikkiso.ntss.coop_api.vendorLogic.PatInsuranceVendorLogic;
import jp.co.nikkiso.ntss.core.dao.MstCoopFacilityDao;
import jp.co.nikkiso.ntss.core.entity.MstCoopFacility;
import jp.co.nikkiso.ntss.core.entity.PatInsurance;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;

import static jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants.IS_ALREADY_REGISTERED;
import static jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants.VendorMode;

/**
 * 電文から抽出した項目に基づき、{@link PatInsurance}エンティティを作成するクラス。
 */
@Component
public class PatInsuranceLogic implements EntityLogic {

  @Autowired
  private MstCoopFacilityDao mstCoopFacilityDao;

  @Autowired
  PatInsuranceVendorLogic patInsuranceFujitsuLogic;

  @Autowired
  PatInsuranceVendorLogic patInsuranceNecLogic;

  @Autowired
  PatInsuranceVendorLogic patInsurancePanaLogic;

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
    return EntityCreatorUtil.createEntity(PatInsurance.class, paramMap);
  }

  /**
   * 電文から抽出した項目をチェックおよび編集する。（新規登録時用）
   *
   * @param facilityCd 施設コード
   * @param paramMap 電文から抽出した項目のマップ
   *
   * @see jp.co.nikkiso.ntss.coop_api.entityLogic.EntityLogic#check(java.lang.String, java.util.Map)
   */
  @Override
  public void check(String facilityCd, Map<String, Object> paramMap) {
    // # pat_insurance
    // 保険情報
    // - 各社レイアウト等非常に複雑なため完全に個別対応する
    // ⇒既存レコードの扱いもベンダー各社により異なる。
    //   そのため、本クラスでは必須項目のみチェックした後、ベンダーを判別して分岐する。

    // ## selectキー
    // pat_id : システムで管理する一意な患者ID
    // facility_cd : 施設コード

    // ### pat_id
    // - 必須項目
    Long patId = (Long) paramMap.get("pat_id");
    CheckNecessaryParamUtil.checkRequired("pat_id", patId);

    // ### facility_cd
    // - 必須項目
    CheckNecessaryParamUtil.checkRequired("facility_cd", facilityCd);

    // モード（ベンダー別）
    VendorMode mode = getVendorModeByFacilityCd(facilityCd);

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(facilityCd + ":vendorMode=[" + mode + "]");
    eventLogMessage.setFacilityCd(facilityCd);
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    switch (mode) {
      case FUJITSU:
        patInsuranceFujitsuLogic.check(facilityCd, patId, paramMap, null);
        break;
      case NEC:
        patInsuranceNecLogic.check(facilityCd, patId, paramMap, null);
        break;
      case PANA:
        patInsurancePanaLogic.check(facilityCd, patId, paramMap, null);
        break;
      default:
        throw new NtssException("連携対象外のベンダーが指定されています。");
    }

    paramMap.putIfAbsent("is_del", JournalConvertConstants.LOGICAL_DELETE_FLAG_OFF);

    // pat_insuranceのレコードを現状のRegisterServiceImplで登録するのは困難である。
    // 以下の理由による。
    // ・1電文から複数のレコードを登録する。
    // ・レコード間に参照関係があり、正しく設定する必要がある。
    // そのため、pat_insuranceのみAbstractPatInsuranceVendorLogicでレコードを登録し、
    // RegisterServiceImplの登録処理は抑制する。
    paramMap.put(IS_ALREADY_REGISTERED, true);
  }

  /**
   * 電文から抽出した項目をチェックおよび編集する。（更新時用）
   *
   * @param facilityCd 施設コード
   * @param paramMap 電文から抽出した項目のマップ
   * @param entity 対象テーブルから取得したエンティティ（更新の場合に使用）
   *
   * @see jp.co.nikkiso.ntss.coop_api.entityLogic.EntityLogic#check(java.lang.String, java.util.Map, java.lang.Object)
   */
  @Override
  public void check(String facilityCd, Map<String, Object> paramMap, Object entity) {
    check(facilityCd, paramMap);
  }

  /**
   * 施設コードからベンダーモードを取得する。
   *
   * @param facilityCd 施設コード
   * @return ベンダーモード
   */
  private VendorMode getVendorModeByFacilityCd(String facilityCd) {
    // mst_coop_facilityテーブルのcommon_settingsカラム、ins_modeキーの値を取得する。

    // mst_coop_facilityレコード取得
    MstCoopFacility mstCoopFacility = getMstCoopFacility(facilityCd);

    // common_settings取得
    MstCoopFacility.CommonSetting commonSetting = mstCoopFacility.getCommonSetting();
    String insMode = commonSetting.getInsMode();

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(facilityCd + ":PatInsuranceLogic:getVendorModeByFacilityCd vendorModeSetting=" + insMode);
    eventLogMessage.setFacilityCd(facilityCd);
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    // ベンダーモード取得
    return getVendorMode(facilityCd, insMode);
  }

  /**
   * 施設コードから連携設定マスタエンティティを取得する。
   *
   * @param facilityCd 施設コード
   * @return 連携設定マスタエンティティ
   */
  private MstCoopFacility getMstCoopFacility(String facilityCd) {
    MstCoopFacility mstCoopFacility = mstCoopFacilityDao.select(facilityCd);
    if (mstCoopFacility == null) {
      String errMsg = String.format("連携電文設定マスタに対応するレコードが存在しません。施設コード=[%s]", facilityCd);
      throw new NtssException(errMsg);
    }

    return mstCoopFacility;
  }

  /**
   * ベンダーモード設定からベンダーモードを取得する。
   *
   * @param facilityCd 施設コード
   * @param vendorModeStr ベンダーモード設定（文字列）
   * @return ベンダーモード
   */
  private VendorMode getVendorMode(String facilityCd, String vendorModeStr) {
    if (StringUtils.isEmpty(vendorModeStr)) {
      String errMsg = String.format("ベンダーモードが設定されていません。施設コード=[%s]",
          facilityCd, vendorModeStr);
      throw new NtssException(errMsg);
    }

    VendorMode mode = VendorMode.getByName(vendorModeStr);
    if (mode == null) {
      String errMsg = String.format("未対応のベンダーモードです。施設コード=[%s], ベンダー名=[%s]",
          facilityCd, vendorModeStr);
      throw new NtssException(errMsg);
    }

    return mode;
  }
}
