package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import jp.co.nikkiso.ntss.core.dto.mstWeight.ScaleBedSettingBedCd;
import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstWeight;

/**
 * 体重計のDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MstWeightDao {

  @Select
  List<MstWeight> selectByFacility(String facilityCd);

  @Select
  MstWeight selectByWeightCd(Long weightCd);

  @Select
  MstWeight selectByFacilityWeightNo(String facilityCd, Integer weightNo);

  @Select
  List<ScaleBedSettingBedCd> selectScaleBedSettingBedCdList(String facilityCd);

  @Insert
  int insert(MstWeight param);

  @Update
  int update(MstWeight param);

}
