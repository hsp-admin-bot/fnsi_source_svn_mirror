package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MntMachineRecordManage;

/**
 * 装置記録管理のDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MntMachineRecordManageDao {
  
  @Select
  List<MntMachineRecordManage> selectAll();
  
  @Select
  MntMachineRecordManage selectByManageNo(Long machineRecordManageNo);
  
  @Insert
  int insert(MntMachineRecordManage mntMachineRecordManage);
  
  @Delete
  int delete(MntMachineRecordManage mntMachineRecordManage);
  
  @Update
  int update(MntMachineRecordManage mntMachineRecordManage);
  
}
