package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.config.ConfigAutowireablePersonalDb;
import org.seasar.doma.Dao;
import org.seasar.doma.MapKeyNamingType;
import org.seasar.doma.jdbc.builder.SelectBuilder;

import java.util.List;
import java.util.Map;

/**
 * データセット（個人情報DB）のDaoインタフェース.
 */
@ConfigAutowireablePersonalDb
@Dao
public interface SysDataSetPersonalDao {

  /**
   * 指定されたselect文を実行.
   * 
   * @param selectBuilder select文
   * @return 実行結果
   */
  public default List<Map<String, Object>> executeSql(SelectBuilder selectBuilder) {
    return selectBuilder.getMapResultList(MapKeyNamingType.NONE);
  }
}
