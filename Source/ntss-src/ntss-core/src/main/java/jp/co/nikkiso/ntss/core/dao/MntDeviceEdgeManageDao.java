package jp.co.nikkiso.ntss.core.dao;

import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MntDeviceEdgeManage;

@ConfigAutowireable
@Dao
public interface MntDeviceEdgeManageDao {

  @Select
  MntDeviceEdgeManage selectByManageNo(Long manageNo);

  @Insert(excludeNull = true)
  int insertNewRecordManageNo(MntDeviceEdgeManage param);

  @Update
  int update(MntDeviceEdgeManage param);
}
