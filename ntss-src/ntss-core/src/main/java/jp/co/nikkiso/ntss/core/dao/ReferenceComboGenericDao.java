package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import java.util.StringJoiner;

import org.seasar.doma.Dao;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.Config;
import org.seasar.doma.jdbc.builder.SelectBuilder;

import jp.co.nikkiso.ntss.core.entity.custom.ReferenceCombo;
import jp.co.nikkiso.ntss.core.entity.custom.ReferenceComboTargetTable;

/**
 * 参照型コンボの汎用Daoインターフェース
 */
@ConfigAutowireable
@Dao
public interface ReferenceComboGenericDao {

  /**
   * @param targetTable 参照先マスタの構造定義データ
   * @param codes mst_selectorから取得したcodeの配列
   * @return 参照先マスタの該当データ
   */
  public default List<ReferenceCombo> selectTargetTableByCode(ReferenceComboTargetTable targetTable, List<Long> codes) {

    final String masterPhysicalName = targetTable.getName();
    final String referencedColumnName = targetTable.getReferencedColumn();
    final String displayColumnName = targetTable.getDisplayColumn();
    final String identifier = targetTable.getIdentifier();

    // codeをカンマ区切りの文字列に変換
    StringJoiner stringJoiner = new StringJoiner(",");
    codes.stream().forEach(code -> stringJoiner.add(code.toString()));
    final String codesAsString = stringJoiner.toString();

    // SQLを組み立て、実行
    final SelectBuilder selectBuilder = SelectBuilder.newInstance(Config.get(this));
    selectBuilder
      .sql("SELECT ")
      .sql(referencedColumnName + " as referenced_value, ")
      .sql(displayColumnName + " as display_value, ")
      .sql(identifier + " as identifier_value")
      .sql(" FROM ")
      .sql(masterPhysicalName)
      .sql(" WHERE ")
      .sql(identifier + " in ")
      .sql("( ")
      .sql(codesAsString)
      .sql(" )");

    return selectBuilder.getEntityResultList(ReferenceCombo.class);
  }
}
