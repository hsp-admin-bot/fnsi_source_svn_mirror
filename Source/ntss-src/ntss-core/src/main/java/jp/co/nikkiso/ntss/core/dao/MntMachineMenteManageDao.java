package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MntMachineMenteManage;

/**
 * 装置メンテナンス管理のDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MntMachineMenteManageDao {
  
  @Select
  List<MntMachineMenteManage> selectAll();
  
  @Select
  MntMachineMenteManage selectByManageNo(Long machineMenteManageNo);
  
  @Insert
  int Insert(MntMachineMenteManage mntMachineMenteManage);
  
  @Delete
  int delete(MntMachineMenteManage mntMachineMenteManage);
  
  @Update
  int update(MntMachineMenteManage mntMachineMenteManage);

}
