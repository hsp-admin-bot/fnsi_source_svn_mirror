package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstComplaint;

/**
 * 愁訴マスタのDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MstComplaintDao {

  /**
   * 指定された施設コードに一致する愁訴マスタを取得します.
   *
   * @param facilityCd 施設コード
   * @return 愁訴マスタ
   */
  @Select
  List<MstComplaint> selectAllByFacilityCd(String facilityCd);

  /**
   * 愁訴マスタを追加.
   * @param mstComplaint 愁訴マスタEntity
   * @return 追加件数
   */
  @Insert
  int insertComplaint(MstComplaint mstComplaint);

  /**
   * 愁訴マスタを更新.
   * @param mstComplaint 愁訴マスタEntity
   * @return 更新件数
   */
  @Update
  int updateComplaint(MstComplaint mstComplaint);

  /**
   * insert時のシリアル値を取得します.
   * @return
   */
  @Select
  Integer selectCurrentSeq();
}
