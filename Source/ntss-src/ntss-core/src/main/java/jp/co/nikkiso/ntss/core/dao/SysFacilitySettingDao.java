package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.SysFacilitySetting;

@ConfigAutowireable
@Dao
public interface SysFacilitySettingDao {
  @Select
  List<SysFacilitySetting> selectAll(SelectOptions options);

  // ADD #8094 2023/02/05 BY HandsomeLin Start
  @Select
  SysFacilitySetting selectByFacilitySettingNo(String facilitySettingNo);
  // ADD #8094 2023/02/05 BY HandsomeLin End
}
