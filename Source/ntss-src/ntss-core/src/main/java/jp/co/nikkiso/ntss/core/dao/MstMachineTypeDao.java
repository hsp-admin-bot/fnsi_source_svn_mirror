package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstMachineType;

/**
 * 型式マスタのDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MstMachineTypeDao {
  
  @Select
  List<MstMachineType> selectAll();

  @Select
  MstMachineType selectByTypeCd(String machineTypeCd);
  
  @Insert
  int insert(MstMachineType mstMachineType);
  
  @Delete
  int delete(MstMachineType mstMachineType);
  
  @Update
  int update(MstMachineType mstMachinetype);
  
}
