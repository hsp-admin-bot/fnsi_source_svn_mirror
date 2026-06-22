package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstHoliday;
import jp.co.nikkiso.ntss.core.entity.custom.HolidayDetail;

@ConfigAutowireable
@Dao
public interface MstHolidayDao {

  @Select
  List<MstHoliday> selectByFacilityCd(String facilityCd);

  @Select
  List<HolidayDetail> selectHolidayDetail(Integer holidayY);

  @Select
  int selectHolidayByTreatdate(Long ordNo, String facilityCd);

  @Delete(sqlFile = true)
  int deleteById(Long holidayCd);

}
