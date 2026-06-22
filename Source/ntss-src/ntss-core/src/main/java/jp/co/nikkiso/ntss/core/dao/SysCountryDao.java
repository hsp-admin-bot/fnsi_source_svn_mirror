package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import java.util.Map;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.SysCountry;

@ConfigAutowireable
@Dao
public interface SysCountryDao extends MasterDao<Map<String, Object>> {
  @Select
  List<Map<String, Object>> selectAllStatus(Map<String, String> params);

  @Select
  List<SysCountry> selectAll(SelectOptions options);

}
