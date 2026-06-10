package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstFacility;

/**
 * 施設マスタのDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MstFacilityDao {

  @Select
  List<MstFacility> selectAllOrderBy(String orderBy);

  @Select
  String selectNameByCd(String facilityCd);
}
