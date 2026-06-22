package jp.co.nikkiso.ntss.core.dao;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import java.util.List;
import java.util.Map;
@ConfigAutowireable
@Dao
public interface SysPrefecturesDao extends MasterDao<Map<String, Object>>{

  @Select
  List<Map<String, Object>> selectAllStatus(Map<String, String> params);
}
