package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.MstJob;
import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import java.util.List;
import java.util.Map;

/**
 * 利用者マスタのDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MstJobDao extends MasterDao<Map<String, Object>> {
  /**
   * 職種コードに紐づく職種情報を取得.
   * @param jobCd 職種コード
   * @return 職種情報
   */
  @Select
  List<MstJob> selectByCd(Long jobCd, SelectOptions options);
  /*add FNSI-改修内容掲示板外结No.10 任 start*/
  @Select
  List<MstJob> selectByCdGetName(String facilityCd);
  /*add FNSI-改修内容掲示板外结No.10 任 end*/

  /**
   * 対象施設の職種情報を全件取得.
   * @param facilityCd 施設コード
   * @return 職種情報
   */
  @Select
  List<MstJob> selectByFacilityCd(String facilityCd, SelectOptions options);

  /**
   * 新規職種を登録
   * @param mstJob 新規登録職種情報
   * @return 更新件数
   */
  @Insert
  int insertMstJob(MstJob mstJob);

  /**
  * 対象施設の職種情報を登録
  * @param facilityCd 施設コード
  * @return 更新件数
  */
  @Insert(sqlFile = true)
  int insertInitMstForFacility(String facilityCd, String defaultMenuSettings);
  /**
   * 各項目を更新.
   * @param mstJob 職種マスタEntity
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int update(MstJob mstJob);

  /**
   * デフォルトメニュー設定を更新.
   * @param mstJob 職種マスタEntity
   * @return 更新件数
   */
  @Update(include = {"defaultMenuSettings", "upDate"})
  int updateDefaultMenuSettings(MstJob mstJob);

  /**
   * デフォルト権限設定を更新.
   * @param mstJob 職種マスタEntity
   * @return 更新件数
   */
  @Update(include = {"defaultAuthorizedAuthorities", "upDate"})
  int updateDefaultAuthorizedAuthorities(MstJob mstJob);

  /**
   * 削除(is_disp='0'に更新).
   * @param jobCd 職種コード
   */
  @Update(sqlFile = true)
  int deleteByCd(String jobCd);

  /**
   * 職種マスタを取得する
   * @param facilityCd 施設コード
   */
  @Select
  List<MstJob> selectAll(String facilityCd);

  @Override
  @Select
  List<Map<String, Object>> selectAllStatus(Map<String, String> params);
}
