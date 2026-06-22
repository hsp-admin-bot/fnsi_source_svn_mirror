package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import java.util.Map;

import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.custom.MstFacilityWithSchExtStartEndTime;

/**
 * 施設マスタのDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MstFacilityDao extends MasterDao<Map<String, Object>> {

  @Select
  List<MstFacility> selectAll();

  @Select
  List<MstFacility> selectAll(SelectOptions options);

  // add 10712 日次スケジュール自動延長処理の除外考慮修正 zkm start
  @Select
  List<MstFacility> selectAllOrderByMstSelector();
  // add 10712 日次スケジュール自動延長処理の除外考慮修正 zkm end

  @Select
  List<MstFacility> selectAllOrderBy(String orderBy);

  @Select
  List<MstFacilityWithSchExtStartEndTime> selectAllWithSchExtStartEndTime();

  @Select
  MstFacility selectByCd(String facilityCd);

  @Select
  String selectNameByCd(String facilityCd);

  @Insert(sqlFile = true)
  int insert(MstFacility mstFacility);

  @Delete
  int delete(MstFacility mstFacility);

  @Update(sqlFile = true)
  int update(MstFacility mstFacility);

  @Delete(sqlFile = true)
  int deleteByCd(String facilityCd);

  @Update(sqlFile = true)
  int updateUseFunction(MstFacility mstFacility);

  @Update(sqlFile = true)
  int updateAdvancedSettings(MstFacility mstFacility);

  @Select
  List<MstFacility> selectAllSortByKana();

  @Select
  MstFacility selectByAddvancedSettingCodeAndFacilityCd(String advancedSettingCode, String facilityCd);

  @Select
  List<MstFacility> selectAllWithoutCancelFacilities(SelectOptions options);

  @Select
  List<MstFacility> selectByFacilityCds(List<String> facilityCds);

  // add FNSI-改修内容 イベント一覧の日付直下に、施設名を表示する dou start
  @Select
  String getFacilityNameByCd(String facilityCd);
  // add FNSI-改修内容　イベント一覧の日付直下に、施設名を表示する dou end

  // add FNSI-3922 投薬指示機能が施設拡張設定のON\OFF制御に反映していない liumx start
  /**
   * cdによる取得mst_facility
   * @param facilityCd 施設コード
   * @return 施設コード情報
   */
  @Select
  List<MstFacility> getFacilityInfoByCd(String facilityCd);
  // add FNSI-3922 投薬指示機能が施設拡張設定のON\OFF制御に反映していない liumx end
  // add 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou start
  @Select
  List<String> selectByName (String keyWord, boolean searchFlag);
  // add 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou end
  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen start
  @Select
  List<MstFacility> selectNamesByCd (List<String> facilityCds);
  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end

  // add #12462 患者情報共有->けいれつしせつ start
  @Select
  List<MstFacility> selectFacilityByFunctionCd (String facilityCd);
  // add #12462 患者情報共有->けいれつしせつ end

  /**
   * mst-list-compose 用：施設マスタ
   */
  @Select
  List<Map<String, Object>> selectAllStatus(Map<String, String> params);
}
