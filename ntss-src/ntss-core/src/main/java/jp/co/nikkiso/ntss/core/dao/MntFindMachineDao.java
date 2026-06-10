package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MntFindMachine;

/**
 * 検出した装置のDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MntFindMachineDao {

  @Select
  List<MntFindMachine> selectAll();

  @Insert
  int insert(MntFindMachine mntFindMachine);

  @Delete
  int delete(MntFindMachine mntFindMachine);

  @Update
  int update(MntFindMachine mntFindMachine);

  @Select
  List<MntFindMachine> selectByFacilityCd(String facilityCd);

  @Delete(sqlFile = true)
  int deleteByFacilityCd(String facilityCd);
}
