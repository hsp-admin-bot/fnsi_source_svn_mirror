package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;

import jp.co.nikkiso.ntss.core.entity.MntFacilityCancelStat;

/**
 * データベース（DB4, DB5, DB6）で共通の処理を規定するDAOインタフェース。
 * （施設解約用）
 *
 * @see MntFacilityCancelStatAuthDao
 * @see MntFacilityCancelStatDefaultDao
 * @see MntFacilityCancelStatPersonalDao
 */
@Dao
public interface MntFacilityCancelStatDao {
  // このインタフェースはデータベース指定（ConfigAutowireable～）を持たないことに注意する。
  // データベースはサブインタフェースで指定する。

  /**
   * facility_cdカラムを持つテーブルにつき、データベース名、テーブル名、
   * is_delカラム有無を取得する。
   *
   * @param excludedTableList 除外対象テーブル名のリスト
   * @return MntFacilityCancelStatのリスト
   */
  @Select
  List<MntFacilityCancelStat> select(List<String> excludedTableList);

  // データベースとテーブル名を指定するdeleteはDomaで記述できない。
  // Spring JdbcTemplateを使用して実装するため、ここではAPIを定義しない。
}
