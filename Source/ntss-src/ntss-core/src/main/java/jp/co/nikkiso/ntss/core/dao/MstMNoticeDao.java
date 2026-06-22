package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstMNotice;

/**
 * 緊急発報マスタのDaoインタフェース,
 */
@ConfigAutowireable
@Dao
public interface MstMNoticeDao {
  
  @Select
  List<MstMNotice> selectAll();

  @Select
  MstMNotice selectByCd(String facilityCd, String machineRecordCd);

  @Select
  List<MstMNotice> selectByFacilityCd(String facilityCd);

  @Insert
  int insert(MstMNotice mstMNotice);

  @Delete
  int delete(MstMNotice mstMNotice);

  @Update
  int update(MstMNotice mstMNotice);

  /**  
  * 施設コードに紐付くレコードを削除.
  *
  * @param facilityCd 施設コード
  * @return 削除件数
  */
  @Delete(sqlFile = true)
  int deleteByFacilityCd(String facilityCd);

}
