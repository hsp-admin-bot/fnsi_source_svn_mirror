package jp.co.nikkiso.ntss.core.dao;

import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstWeightScale;

/**
 * 体重測定設定のDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MstWeightScaleDao {

  @Select
  MstWeightScale selectByFacility(String facilityCd);

  @Select
  MstWeightScale selectByWeightScaleCd(Integer weightScaleCd);

  @Insert
  int insert(MstWeightScale param);

  @Update
  int update(MstWeightScale param);

}
