package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstAddressGroup;

/**
 * 宛先グループマスタのDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MstAddressGroupDao {
  
  @Select
  List<MstAddressGroup> selectAll();
  
  @Select
  MstAddressGroup selectByCd(String addressGroupCd);
  
  @Insert
  int insert(MstAddressGroup mstAddressGroup);
  
  @Delete
  int delete(MstAddressGroup mstAddressGroup);
  
  @Update
  int update(MstAddressGroup mstAddressGroup);
  
}
