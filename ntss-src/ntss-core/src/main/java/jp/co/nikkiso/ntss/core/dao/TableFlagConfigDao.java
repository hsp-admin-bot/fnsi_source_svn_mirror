package jp.co.nikkiso.ntss.core.dao;
// add 10601 eventLog共通処理 gjn start
import jp.co.nikkiso.ntss.core.entity.TableFlagConfig;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import java.util.List;

/**
 * すべてのテーブルフラグ設定クラス
 */
@ConfigAutowireable
@Dao
public interface TableFlagConfigDao {

  @Select
  List<TableFlagConfig> selectAll();


}
// add 10601 eventLog共通処理 gjn end
