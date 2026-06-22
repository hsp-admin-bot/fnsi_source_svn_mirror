package jp.co.nikkiso.ntss.core.dao;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

/**
 * Information Schema用のDaoインターフェース
 */
@ConfigAutowireable
@Dao
public interface InformationSchemaDao {

  /**
   * 指定したテーブルが存在すればtrueを返す
   * @param tableName テーブル物理名
   * @return テーブルが存在すればtrue、存在しなければfalse
   */
  @Select
  boolean isTableExist(String tableName);

  /**
   * 指定したテーブル名に、指定したカラムが存在すればtrueを返す
   * @param tableName テーブル物理名
   * @param columnName カラム物理名
   * @return カラムが存在すればtrue、存在しなければfalse
   */
  @Select
  boolean isColumnExistAtTable(String tableName, String columnName);
}
