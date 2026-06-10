package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MntBatchManager;

/**
 * バッチ稼働状況管理のDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MntBatchManagerDao {
  
  /**
   * バッチ稼働状況を全件取得
   */
  @Select
  List<MntBatchManager> selectAll();

  /**
   * 管理番号を指定してバッチ稼働状況取得
   * @param ctlNo 管理番号 
   */
  @Select
  MntBatchManager selectByCtlNo(Integer ctlNo);

  /**
   * バッチ稼働状況を更新する
   * @param sysSystemDefine 更新情報
   */
  @Update(sqlFile = true)
  int updateProcessStatus(MntBatchManager param);
  
}
