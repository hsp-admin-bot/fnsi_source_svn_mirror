package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.MstCompTreatment;
import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import java.util.List;
import java.util.Map;

/**
 * 処置マスタのDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MstCompTreatmentDao extends MasterDao<Map<String, Object>> {

  /**
   * 指定された施設コードに一致する処置マスタを取得します.
   *
   * @param facilityCd 施設コード
   * @return {@link MstCompTreatment}のリスト
   */
  @Select
  List<MstCompTreatment> selectAllByFacilityCd(String facilityCd);

  /**
   * 処置マスタを追加.
   * @param mstCompTreatment 処置マスタEntity
   * @return 追加件数
   */
  @Insert
  int insertCompTreatment(MstCompTreatment mstCompTreatment);

  /**
   * 処置マスタを更新.
   * @param mstCompTreatment 処置マスタEntity
   * @return 更新件数
   */
  @Update
  int updateCompTreatment(MstCompTreatment mstCompTreatment);

  /**
   * insert時のシリアル値を取得します.
   * @return
   */
  @Select
  Integer selectCurrentSeq();

  @Override
  @Select
  List<Map<String, Object>> selectAllStatus(Map<String, String> params);
}
