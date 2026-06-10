package jp.co.nikkiso.ntss.core.dao;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

/**
 * {@link InformationSchemaDao} のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:dao.script/InformationSchemaDaoTest.before.sql")
public class InformationSchemaDaoTest {
  /**
   * テスト対象Dao
   */
  @Autowired
  private InformationSchemaDao target;

  /**
   * isTableExistメソッドの検証
   *
   * 条件：存在するテーブル物理名を指定する
   * 結果：trueを返すこと
   */
  @Test
  public void test_isTableExist_正常_存在するテーブル物理名を指定するとtrueを返すこと() {
    // arrange
    final String tableName = "info_schema_test_table";

    // action
    final boolean result = target.isTableExist(tableName);

    // assert
    assertThat(result).isTrue();
  }

  /**
   * isTableExistメソッドの検証
   *
   * 条件：存在しないテーブル物理名を指定する
   * 結果：falseを返すこと
   */
  @Test
  public void test_isTableExist_正常_存在しないテーブル物理名を指定するとfalseを返すこと() {
    // arrange
    final String tableName = "does_not_exist";

    // action
    final boolean result = target.isTableExist(tableName);

    // assert
    assertThat(result).isFalse();
  }

  /**
   * isColumnExistAtTableメソッドの検証
   *
   * 条件：存在するテーブル物理名と、存在するカラム物理名を指定する
   * 結果：trueを返すこと
   */
  @Test
  public void test_isColumnExistAtTable_正常_テーブルに存在するカラム物理名を指定するとtrueを返すこと() {
    // arrange
    final String tableName = "info_schema_test_table";
    final String columnName = "col1";

    // action
    final boolean result = target.isColumnExistAtTable(tableName, columnName);

    // assert
    assertThat(result).isTrue();
  }

  /**
   * isColumnExistAtTableメソッドの検証
   *
   * 条件：存在しないテーブル物理名と、存在するカラム物理名を指定する
   * 結果：falseを返すこと
   */
  @Test
  public void test_isColumnExistAtTable_正常_存在しないテーブル物理名を指定するとfalseを返すこと() {
    // arrange
    final String tableName = "does_not_exist";
    final String columnName = "col1";

    // action
    final boolean result = target.isColumnExistAtTable(tableName, columnName);

    // assert
    assertThat(result).isFalse();
  }

  /**
   * isColumnExistAtTableメソッドの検証
   *
   * 条件：存在するテーブル物理名と、存在しないカラム物理名を指定する
   * 結果：falseを返すこと
   */
  @Test
  public void test_isColumnExistAtTable_正常_テーブルに存在しないカラム物理名を指定するとfalseを返すこと() {
    // arrange
    final String tableName = "info_schema_test_table";
    final String columnName = "does_not_exist";

    // action
    final boolean result = target.isColumnExistAtTable(tableName, columnName);

    // assert
    assertThat(result).isFalse();
  }
}
