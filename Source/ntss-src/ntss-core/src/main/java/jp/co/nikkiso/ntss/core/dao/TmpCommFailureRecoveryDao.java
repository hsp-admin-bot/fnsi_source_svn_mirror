package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.TmpCommFailureRecovery;
import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

/**
 * 装置状態管理のDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface TmpCommFailureRecoveryDao {

  @Select
  TmpCommFailureRecovery selectByKey(String facilityCd, String machineTypeCd, String machineSerial);

  @Insert
  int insert(TmpCommFailureRecovery param);

  @Delete
  int delete(TmpCommFailureRecovery param);

  @Update
  int update(TmpCommFailureRecovery param);


  /**
   * 装置の透析開始日時（AWSとDEの通信断からの復旧）を更新する
   * @param param 更新するデータ
   * @return
   */
  @Update(sqlFile = true)
  int updateTmpCommFailureRecoveryCommFail(TmpCommFailureRecovery param);

  //add 装置状態管理の削除方法を追加します(AWSとDEの通信断からの復旧) 劉 start
  /**
   * 装置状態管理の削除（対象の装置)(AWSとDEの通信断からの復旧)
   * @param facilityCd      施設コード
   * @param machineTypeCd   型式コード
   * @param machineSerial   製造番号
   * @return
   */
  @Delete(sqlFile = true)
  int deleteByKey(String facilityCd, String machineTypeCd, String machineSerial);
  //add 装置状態管理の削除方法を追加します(AWSとDEの通信断からの復旧) 劉 end
}
