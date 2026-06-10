package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.Insert;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.MstFacilitySetting;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;


@ConfigAutowireable
@Dao
public interface MstFacilitySettingDao {

  /**
   * 施設設定マスタ全データ取得
   * @param options
   * @return 施設設定マスタ情報
   */
  @Select
  List<MstFacilitySetting> selectAll(SelectOptions options);

  /**
   * マスタメンテナンス用：施設コードと管理番号をもとに当該施設の現有効設定値を取得(マスタ値出力／マスタにない場合はシステムデフォルト値を表示)
   * 施設コード：必須　施設設定番号：nullの場合は条件から除外
   * 複数検索及び0件許容用
   * @param facilityCd 施設コード
   * @param facilitySettingNo 施設設定番号 (Null許容)
   * @return 共通施設設定情報
   */
  @Select
  List<FacilitySettingInfo> selectFacilitySetting(String facilityCd, String facilitySettingNo);

  /**
   * 個別コード取得用：施設コードと管理番号に紐づく施設設定を取得
   * @param facilityCd 施設コード
   * @param facilitySettingNo 施設設定番号
   * @return 施設設定
   */
  @Select
  FacilitySettingInfo getBySettingNoAndCd(String facilityCd, String facilitySettingNo);

  // add FNSI-7217 バッチ操作インターフェイスを追加します 查 start
  /**
   * 個別コード取得用：施設コードと管理番号に紐づく施設設定を取得(バッチ)
   * @param facilityCd 施設コード
   * @param facilitySettingNos 施設設定番号の集合
   * @return 施設設定
   */
  @Select
  List<FacilitySettingInfo> getByCdAndSettingNos(String facilityCd, List<String> facilitySettingNos);
  // add FNSI-7217 バッチ操作インターフェイスを追加します 查 end

  /**
   * 登録値を更新.
   * @param MstFacilitySetting 施設設定情報
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int update(MstFacilitySetting mstFacilitySetting);

  /**
   * 新規施設設定を登録
   * @param MstFacilitySetting 施設設定情報
   * @return 更新件数
   */
  @Insert(sqlFile = true)
  int insert(MstFacilitySetting mstFacilitySetting);

  @Select
  FacilitySettingInfo getValueSignInByFacilityCd(String facilityCd);

  // add #12462 患者情報共有->けいれつしせつ start
  @Select
  MstFacilitySetting getMstFacilitySettingByFacilityCd(String facilityCd);

  @Select
  String getAffiliatedFacilities(String facilityCd, String facilitySettingNo);

  @Select
  List<String> getFacilityToMe(String jsonValue, String facilitySettingNo);
  // add #12462 患者情報共有->けいれつしせつ end
  // add #12589 どこかで使用している帳票も削除出来てしまう sunsy start

  /**
   * 施設設定マスタNo.117に設定するデフォルト帳票のコードを取得
   * @param facilityCd
   * @return 帳票コード
   */
  @Select
  String getDefaultReportByFacilityCd(String facilityCd);
  // add #12589 どこかで使用している帳票も削除出来てしまう sunsy end
}
