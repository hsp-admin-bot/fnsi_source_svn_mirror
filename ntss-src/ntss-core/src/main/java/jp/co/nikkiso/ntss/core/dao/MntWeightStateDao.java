package jp.co.nikkiso.ntss.core.dao;

import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MntWeightState;

/**
 * 体重計状態のDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MntWeightStateDao {

  @Select
  MntWeightState selectByWeightCd(Long weightCd);

  @Insert
  int insert(MntWeightState param);

  @Update
  int update(MntWeightState param);

  @Insert(sqlFile=true)
  int insertNewWeightCd(String facilityCd);
}
