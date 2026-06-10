package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstWheelChair;

/**
 * 車いすマスタのDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MstWheelChairDao {

  @Select
  List<MstWheelChair> selectByFacility(String facilityCd, String isDisp, String isDel);

  @Select
  List<MstWheelChair> selectByPatId(Long patId, String isDisp, String isDel);

  @Select
  MstWheelChair selectByWheelChairCd(Long wheelChairCd, String isDisp, String isDel);

  @Select
  MstWheelChair selectByFacilityFnCd(String facilityCd, String fnWheelChairCd, String isDisp, String isDel);

  @Insert
  int insert(MstWheelChair param);

  @Update
  int update(MstWheelChair param);

}
