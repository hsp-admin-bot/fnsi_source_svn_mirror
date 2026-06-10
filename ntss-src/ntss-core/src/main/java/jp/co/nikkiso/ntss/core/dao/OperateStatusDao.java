package jp.co.nikkiso.ntss.core.dao;

import org.seasar.doma.Dao;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;


/**
 * 状態変更処理
 * 
 *
 */
@ConfigAutowireable
@Dao
public interface OperateStatusDao {
  
  @Update(sqlFile = true)
  int updatePatMainStatus(long ord_no,String status,boolean clearStatusFlag,boolean updateValueFlag);
  @Update(sqlFile = true)
  int updateOrdMainStatus(long ord_no,String status,boolean updateDateFlag);
  // add AWSとDEの通信断からの復旧 --趙-- start  
  @Update(sqlFile = true)
  int updateOrdMainStatusCommFail(long ord_no,String status);
  // add AWSとDEの通信断からの復旧 --趙-- end 
}
