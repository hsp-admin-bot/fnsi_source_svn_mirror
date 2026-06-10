package jp.co.nikkiso.ntss.admin_web.service.master;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;

import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.entity.custom.ReferenceCombo;
import jp.co.nikkiso.ntss.core.entity.custom.ReferenceComboTargetTable;
import jp.co.nikkiso.ntss.core.exception.InvalidSchemaDefinitionException;

@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:resource.service/ReferenceComboServiceImplTest.before.sql")
public class ReferenceComboServiceImplTest {
  /**
   * テスト対象クラス
   */
  @Autowired
  private ReferenceComboService target;

  /**
   * 例外の発生をテストするためのルール
   */
  @Rule
  public ExpectedException expectedException = ExpectedException.none();

  /**
   * buildメソッドの検証
   *
   * 条件：参照型コンボの定義あり、参照先のマスタにデータあり
   * 結果：マスタ定義の並び順に準拠したデータを取得できること
   */
  @Test
  public void test_build_正常_参照型コンボの実際の値を取得できること_順番はマスタ定義テーブルと一致すること() {
    // arrange
    final String facilityCd = "001";
    final String masterPhysicalName = "mst_test_table";
    final String referencedColumnName = "die_name";
    final String displayColumnName = "memo";
    final String identifier = "die_cd";

    ReferenceComboTargetTable targetTable
      = new ReferenceComboTargetTable(masterPhysicalName, referencedColumnName, displayColumnName, identifier);

    // action
    List<ReferenceCombo> list = target.build(facilityCd, targetTable);

    // assert
    assertThat(list).hasSize(3);

    ReferenceCombo combo1 = list.get(0);
    assertThat(combo1.getReferencedValue()).isEqualTo("name1");
    assertThat(combo1.getDisplayValue()).isEqualTo("memo1");
    assertThat(combo1.getIdentifierValue()).isEqualTo(1L);

    ReferenceCombo combo5 = list.get(1);
    assertThat(combo5.getReferencedValue()).isEqualTo("name5");
    assertThat(combo5.getDisplayValue()).isEqualTo("memo5");
    assertThat(combo5.getIdentifierValue()).isEqualTo(5L);

    ReferenceCombo combo4 = list.get(2);
    assertThat(combo4.getReferencedValue()).isEqualTo("name4");
    assertThat(combo4.getDisplayValue()).isEqualTo("memo4");
    assertThat(combo4.getIdentifierValue()).isEqualTo(4L);
  }

  /**
   * buildメソッドの検証
   *
   * 条件：参照型コンボの定義あり、参照先のマスタにデータなし
   * 結果：空のリストを取得できること
   */
  @Test
  public void test_build_正常_マスタにレコードが存在しない場合は空のリストを返すこと() {
    // arrange
    final String facilityCd = "002";
    final String masterPhysicalName = "mst_m_notice";
    final String referencedColumnName = "machine_record_cd";
    final String displayColumnName = "machine_record_message";
    final String identifier = "machine_record_cd";

    ReferenceComboTargetTable targetTable
      = new ReferenceComboTargetTable(masterPhysicalName, referencedColumnName, displayColumnName, identifier);

    // action
    List<ReferenceCombo> list = target.build(facilityCd, targetTable);

    // assert
    assertThat(list).isEmpty();
  }

  /**
   * buildメソッドの検証
   *
   * 条件：マスタ定義テーブルの施設コードが一致せず
   * 結果：空のリストを取得できること
   */
  @Test
  public void test_build_正常_マスタ定義に施設コードが一致するマスタが存在しない場合は空のリストを返すこと() {
    // arrange
    final String facilityCd = "999";
    final String masterPhysicalName = "mst_test_table";
    final String referencedColumnName = "die_name";
    final String displayColumnName = "memo";
    final String identifier = "die_cd";

    ReferenceComboTargetTable targetTable
      = new ReferenceComboTargetTable(masterPhysicalName, referencedColumnName, displayColumnName, identifier);

    // action
    List<ReferenceCombo> combos = target.build(facilityCd, targetTable);

    // assert
    assertThat(combos).isEmpty();
  }

  /**
   * buildメソッドの検証
   *
   * 条件：マスタ定義テーブルに存在しないマスタを設定した場合
   * 結果：空のリストを取得できること
   */
  @Test
  public void test_build_正常_マスタ定義にマスタ名が一致するマスタが存在しない場合は空のリストを返すこと() {
    // arrange
    final String facilityCd = "001";
    final String masterPhysicalName = "mst_m_notice";
    final String referencedColumnName = "machine_record_message";
    final String displayColumnName = "email_name";
    final String identifier = "machine_record_cd";

    ReferenceComboTargetTable targetTable
      = new ReferenceComboTargetTable(masterPhysicalName, referencedColumnName, displayColumnName, identifier);

    // action
    List<ReferenceCombo> combos = target.build(facilityCd, targetTable);

    // assert
    assertThat(combos).isEmpty();
  }

  /**
   * buildメソッドの検証
   *
   * 条件：テーブルに存在しないカラムを設定した場合
   * 結果：InvalidSchemaDefinitionExceptionが発生すること
   */
  @Test
  public void test_build_異常_referencedColumnに存在しないカラム物理名を指定した場合は例外が発生すること() {
    // arrange
    final String facilityCd = "anything good";
    final String masterPhysicalName = "mst_test_table";
    final String referencedColumnName = "not_exist_column";
    final String displayColumnName = "memo";
    final String identifier = "die_cd";

    ReferenceComboTargetTable targetTable
      = new ReferenceComboTargetTable(masterPhysicalName, referencedColumnName, displayColumnName, identifier);

    // action
    // assert
    expectedException.expect(InvalidSchemaDefinitionException.class);
    expectedException.expectMessage("参照型コンボの設定に、存在しないカラムを指定しています。");
    target.build(facilityCd, targetTable);
  }

  /**
   * buildメソッドの検証
   *
   * 条件：テーブルに存在しないカラムを設定した場合
   * 結果：InvalidSchemaDefinitionExceptionが発生すること
   */
  @Test
  public void test_build_異常_displayColumnに存在しないカラム物理名を指定した場合は例外が発生すること() {
    // arrange
    final String facilityCd = "anything good";
    final String masterPhysicalName = "mst_test_table";
    final String referencedColumnName = "die_name";
    final String displayColumnName = "not_exist_column";
    final String identifier = "die_cd";

    ReferenceComboTargetTable targetTable
      = new ReferenceComboTargetTable(masterPhysicalName, referencedColumnName, displayColumnName, identifier);

    // action
    // assert
    expectedException.expect(InvalidSchemaDefinitionException.class);
    expectedException.expectMessage("参照型コンボの設定に、存在しないカラムを指定しています。");
    target.build(facilityCd, targetTable);
  }

  /**
   * buildメソッドの検証
   *
   * 条件：テーブルに存在しないカラムを設定した場合
   * 結果：InvalidSchemaDefinitionExceptionが発生すること
   */
  @Test
  public void test_build_異常_identifierに存在しないカラム物理名を指定した場合は例外が発生すること() {
    // arrange
    final String facilityCd = "anything good";
    final String masterPhysicalName = "mst_test_table";
    final String referencedColumnName = "die_name";
    final String displayColumnName = "memo";
    final String identifier = "not_exist_column";

    ReferenceComboTargetTable targetTable
      = new ReferenceComboTargetTable(masterPhysicalName, referencedColumnName, displayColumnName, identifier);

    // action
    // assert
    expectedException.expect(InvalidSchemaDefinitionException.class);
    expectedException.expectMessage("参照型コンボの設定に、存在しないカラムを指定しています。");
    target.build(facilityCd, targetTable);
  }

  /**
   * buildメソッドの検証
   *
   * 条件：存在しないテーブルを設定した場合
   * 結果：InvalidSchemaDefinitionExceptionが発生すること
   */
  @Test
  public void test_build_異常_存在しないマスタ物理名を指定した場合は例外が発生すること() {
    // arrange
    final String facilityCd = "anything good";
    final String masterPhysicalName = "not_exist_table";
    final String referencedColumnName = "die_name";
    final String displayColumnName = "memo";
    final String identifier = "die_cd";

    ReferenceComboTargetTable targetTable
      = new ReferenceComboTargetTable(masterPhysicalName, referencedColumnName, displayColumnName, identifier);

    // action
    // assert
    expectedException.expect(InvalidSchemaDefinitionException.class);
    expectedException.expectMessage("参照型コンボの設定に、存在しないマスタを指定しています。");
    target.build(facilityCd, targetTable);
  }
}
