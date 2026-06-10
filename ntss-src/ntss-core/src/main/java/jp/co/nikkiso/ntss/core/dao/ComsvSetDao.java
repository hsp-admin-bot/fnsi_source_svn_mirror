package jp.co.nikkiso.ntss.core.dao;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.custom.ComsvSet;

/**
 * 通信サーバ設定のDaoインタフェース
 * @author Y.Takamura
 *
 */
@ConfigAutowireable
@Dao
public interface ComsvSetDao {
  @Select
  ComsvSet selectComsvSet(String facilityCd, Integer deviceEdgeNo);
}
