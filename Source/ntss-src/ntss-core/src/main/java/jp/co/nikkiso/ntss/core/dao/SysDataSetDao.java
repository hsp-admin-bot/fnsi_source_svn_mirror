package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import java.util.Map;

import org.seasar.doma.Dao;
import org.seasar.doma.MapKeyNamingType;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.builder.SelectBuilder;

import jp.co.nikkiso.ntss.core.entity.SysDataSet;

/**
 * データセットのDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface SysDataSetDao {

  /**
   * データセット取得.
   *
   * @param sqlCd  SQLコード
   * @return データセットエンティティ
   */
  @Select(ensureResult = true)
  SysDataSet selectByCd(Long sqlCd);

  /**
   * 指定されたselect文を実行.
   *
   * @param selectBuilder select文
   * @return 実行結果
   */
  public default List<Map<String, Object>> executeSql(SelectBuilder selectBuilder) {
    return selectBuilder.getMapResultList(MapKeyNamingType.NONE);
  }

  /**
   * 帳票用 データセット取得.
   *
   * @return データセットエンティティ
   */
  @Select(ensureResult = true)
  List<SysDataSet> selectForReport();

  /**
   * すべてのSysDataSetを選択
   * @param options
   * @param facilityCd 施設コード
   * @return リストにはデータセットのエンティティが含まれます。
   */
  @Select
  List<SysDataSet> selectAllSysDataSet();

  /**
   * 患者イベント リスト項目用データセット取得.
   *
   * @return データセットエンティティ
   */
  @Select
  List<SysDataSet> selectForPatEventList();

  /**
   * 患者イベント テキスト項目用データセット取得.
   *
   * @return データセットエンティティ
   */
  @Select
  List<SysDataSet> selectForPatEventText();
}
