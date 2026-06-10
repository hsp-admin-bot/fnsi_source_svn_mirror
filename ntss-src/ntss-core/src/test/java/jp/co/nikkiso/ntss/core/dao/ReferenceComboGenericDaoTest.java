package jp.co.nikkiso.ntss.core.dao;

import static java.util.Arrays.asList;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.tuple;

import java.util.List;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.entity.custom.ReferenceCombo;
import jp.co.nikkiso.ntss.core.entity.custom.ReferenceComboTargetTable;

/**
 * {@link ReferenceComboGenericDao}のテストクラス
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:dao.script/ReferenceComboGenericDaoTest.before.sql")
public class ReferenceComboGenericDaoTest {
  /**
   * テスト対象Dao
   */
  @Autowired
  private ReferenceComboGenericDao target;

  /**
   * selectTargetTableByCodeメソッドの検証
   *
   * 条件：該当データあり
   * 結果：指定したテーブルから、指定したコードのデータを取得できること
   */
  @Test
  public void test_selectTargetTableByCode_正常_該当データあり() {
    // arrange
    final String masterPhysicalName = "mst_test_table";
    final String referencedColumnName = "die_name";
    final String displayColumnName = "memo";
    final String identifier = "die_cd";
    final List<Long> codes = asList(1L, 2L, 4L);
    ReferenceComboTargetTable targetTable = new ReferenceComboTargetTable(
        masterPhysicalName,
        referencedColumnName,
        displayColumnName,
        identifier);

    // action
    List<ReferenceCombo> referenceCombos = target.selectTargetTableByCode(targetTable, codes);

    // assert
    assertThat(referenceCombos).hasSize(3);
    assertThat(referenceCombos)
      .extracting(
        ReferenceCombo::getReferencedValue,
        ReferenceCombo::getDisplayValue,
        ReferenceCombo::getIdentifierValue
      )
      .containsExactlyInAnyOrder(
        tuple("name1", "memo1", 1L),
        tuple("name2", "memo2", 2L),
        tuple("name4", "memo4", 4L)
      );
  }

  /**
   * selectTargetTableByCodeメソッドの検証
   *
   * 条件：該当データなし
   * 結果：空のリストを取得できること
   */
  @Test
  public void test_selectTargetTableByCode_正常_該当データなしの場合は空のリストを返すこと() {
    // arrange
    final String masterPhysicalName = "mst_test_table";
    final String referencedColumnName = "die_name";
    final String displayColumnName = "memo";
    final String identifier = "die_cd";
    final List<Long> codes = asList(999L);
    ReferenceComboTargetTable targetTable = new ReferenceComboTargetTable(
        masterPhysicalName,
        referencedColumnName,
        displayColumnName,
        identifier);

    // action
    List<ReferenceCombo> referenceCombos = this.target.selectTargetTableByCode(targetTable, codes);

    // assert
    assertThat(referenceCombos).isEmpty();

  }
}
