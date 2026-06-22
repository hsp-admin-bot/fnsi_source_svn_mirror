package jp.co.nikkiso.ntss.core.dao;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.groups.Tuple.tuple;

import jp.co.nikkiso.ntss.core.entity.TabDisplayNameAndContentsId;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * {@link MstPersonalTabDefineDao} のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:dao.script/MstPersonalTabDefineDaoTest.before.sql")
public class MstPersonalTabDefineDaoTest {

  /**
   * テスト対象Dao.
   */
  @Autowired
  private MstPersonalTabDefineDao target;

  /**
   * selectDisplayNameAndContentsIdByFacilityCd()の検証.
   *
   * <p>
   * 条件：データが存在する施設コードを指定
   * 結果：結果が取得できること（非表示のレコードは結果に含まれない）
   * </p>
   */
  @Test
  public void test_selectDisplayNameAndContentsIdByFacilityCd_正常_データあり() {
    // arrange
    final String facilityCd = "009999";

    // action
    final List<TabDisplayNameAndContentsId> result = target.selectDisplayNameAndContentsIdByFacilityCd(facilityCd);

    // assert
    assertThat(result)
      .isNotEmpty()
      .hasSize(2)
      .extracting(
        TabDisplayNameAndContentsId::getTabDefineCd,
        TabDisplayNameAndContentsId::getDisplayName,
        TabDisplayNameAndContentsId::getContentsId,
        TabDisplayNameAndContentsId::getMode
      )
      .containsExactly(
        tuple(3, "タブC", "tab-contents-C", "1")
        , tuple(1, "タブA", "tab-contents-A", "0")
      )
    ;
  }

  /**
   * selectDisplayNameAndContentsIdByFacilityCd()の検証.
   *
   * <p>
   * 条件：指定された施設コードにデータなし
   * 結果：空のリストを取得できること
   * </p>
   */
  @Test
  public void test_selectDisplayNameAndContentsIdByFacilityCd_正常_データなし() {
    // arrange
    final String facilityCd = "xxxxxx";

    // action
    final List<TabDisplayNameAndContentsId> result = target.selectDisplayNameAndContentsIdByFacilityCd(facilityCd);

    // assert
    assertThat(result).isEmpty();
  }

}
