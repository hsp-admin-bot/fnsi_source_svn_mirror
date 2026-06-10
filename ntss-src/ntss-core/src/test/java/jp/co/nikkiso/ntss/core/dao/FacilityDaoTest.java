package jp.co.nikkiso.ntss.core.dao;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

/**
 * {@link FacilityDao} のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:dao.script/FacilityDaoTest.before.sql")
public class FacilityDaoTest {

  @Autowired
  private FacilityDao target;

  /**
   * selectUseFunctionByFacilityCd()の検証.
   * <p>
   * 条件：該当データあり
   * 結果：施設マスタから指定した施設コードの使用可能機能が取得できること
   * </p>
   */
  @Test
  public void test_selectUseFunctionByFacilityCd_正常_データあり() {
    // arrange
    final String facilityCd = "900001";

    // action
    final List<String> result = target.selectUseFunctionByFacilityCd(facilityCd);

    // assert
    assertThat(result).isNotEmpty();
    assertThat(result)
      .hasSize(4)
      .containsExactly("001", "002", "003", "004");
  }

  /**
   * selectUseFunctionByFacilityCd()の検証.
   * <p>
   * 条件：該当データなし（空配列）
   * 結果：空の配列が取得できること
   * </p>
   */
  @Test
  public void test_selectUseFunctionByFacilityCd_正常_データなし_空配列() {
    // arrange
    final String facilityCd = "900002";

    // action
    final List<String> result = target.selectUseFunctionByFacilityCd(facilityCd);

    // assert
    assertThat(result).isEmpty();
  }

  /**
   * selectUseFunctionByFacilityCd()の検証.
   * <p>
   * 条件：該当データなし（NULL）
   * 結果：空の配列が取得できること
   * </p>
   */
  @Test
  public void test_selectUseFunctionByFacilityCd_正常_データなし_NULL() {
    // arrange
    final String facilityCd = "900003";

    // action
    final List<String> result = target.selectUseFunctionByFacilityCd(facilityCd);

    // assert
    assertThat(result).isEmpty();
  }

  /**
   * selectUseFunctionByFacilityCd()の検証.
   * <p>
   * 条件：該当施設なし
   * 結果：空の配列が取得できること
   * </p>
   */
  @Test
  public void test_selectUseFunctionByFacilityCd_正常_該当施設なし() {
    // arrange
    final String facilityCd = "900004";

    // action
    final List<String> result = target.selectUseFunctionByFacilityCd(facilityCd);

    // assert
    assertThat(result).isEmpty();
  }
}
