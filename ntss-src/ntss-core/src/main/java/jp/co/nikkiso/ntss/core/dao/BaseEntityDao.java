package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.BaseEntity;
import org.seasar.doma.Dao;
import org.seasar.doma.MapKeyNamingType;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.builder.SelectBuilder;

import java.util.List;
import java.util.Map;

/**
 * {@link BaseEntity}のDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface BaseEntityDao {

  /**
   * 指定されたselect文を実行します.
   * @param selectBuilder select文
   * @return 実行結果
   */
  default List<Map<String, Object>> executeSql(SelectBuilder selectBuilder) {
    return selectBuilder.getMapResultList(MapKeyNamingType.NONE);
  }

}
