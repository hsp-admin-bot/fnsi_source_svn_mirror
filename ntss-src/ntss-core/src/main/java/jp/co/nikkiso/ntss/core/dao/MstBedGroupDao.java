package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstBedGroup;

/**
 * ベッドグループマスタのDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MstBedGroupDao {
  
  @Select
  List<MstBedGroup> selectAll();
  @Select
  List<MstBedGroup> selectByFacility(String facilityCd);

}
