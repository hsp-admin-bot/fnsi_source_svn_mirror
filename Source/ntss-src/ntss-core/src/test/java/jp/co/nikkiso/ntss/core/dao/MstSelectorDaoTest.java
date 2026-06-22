package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.MstSelector;
import jp.co.nikkiso.ntss.core.entity.MstSelector.Item;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.not;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.junit.Assert.assertThat;

import java.util.List;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

/**
 * {@link MstSelectorDao} のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:dao.script/MstSelectorDaoTest.before.sql")
public class MstSelectorDaoTest {

  /**
   * テスト対象Dao.
   */
  @Autowired
  private MstSelectorDao target;

  /**
   * selectByName()の検証.
   * <p>
   * 条件：データが存在するマスターコードを指定 結果：結果が取得できること
   * </p>
   */
  @Test
  public void test_selectByName_正常_データあり() {
    // 実行
    MstSelector result = target.selectByName("000001", "mst_master1");

    // 検証
    assertThat(result, not(nullValue()));
    assertThat(result.getMasterPhysicalName(), is("mst_master1"));

    // 並び順情報
    List<Item> items = result.getOrderSettings().getItems();
    // 1件目
    assertThat(items.get(0).getCode(), is(3L));
    assertThat(items.get(0).getName(), is("商品C"));

    // 2件目
    assertThat(items.get(1).getCode(), is(2L));
    assertThat(items.get(1).getName(), is("商品B"));

    // 3件目
    assertThat(items.get(2).getCode(), is(1L));
    assertThat(items.get(2).getName(), is("商品A"));

  }

  /**
   * selectByName()の検証.
   * <p>
   * 条件：データが存在しないマスターコードを指定 結果：結果がnullになること
   * </p>
   */
  @Test
  public void test_selectByName_正常_データなし() {
    // 実行
    MstSelector result = target.selectByName("900001", "mst_master1");

    // 検証
    assertThat(result, is(nullValue()));
  }

  /**
   * insertSelector()の検証.
   * <p>
   * 条件：存在しないmst_selectorに対して指定した施設・マスタ名・登録コード・登録名を指定すると
   * 　　　それらをitemsを頭とするjsonキーとして1件保存される
   * </p>
   */
  @Test
  public void test_insertSelector_登録() {
    // 実行-データ無しを確認
    MstSelector result = target.selectByName("900001", "mst_testMaster1");
    // 検証
    assertThat(result, is(nullValue()));

    // 実行-データ作成
    target.insertSelector(1L,"テスト","900001","mst_testMaster1");

    // 検証
    result = target.selectByName("900001", "mst_testMaster1");
    assertThat(result, not(nullValue()));
    assertThat(result.getMasterPhysicalName(), is("mst_testMaster1"));

    // 並び順情報
    List<Item> items = result.getOrderSettings().getItems();
    // 1件目
    assertThat(items.get(0).getCode(), is(1L));
    assertThat(items.get(0).getName(), is("テスト"));

  }

  /**
   * addByOrderSettings()の検証.
   * <p>
   * 条件：指定したmst_selectorのorderSettingsのitems内に新しい情報を1組追加
   * </p>
   */
  @Test
  public void addByOrderSettings() {
    // 実行
    MstSelector result = target.selectByName("000001", "mst_master3");

    target.addByOrderSettings(4L, "商品D","000001", "mst_master3");

    result = target.selectByName("000001", "mst_master3");
    // 検証
    assertThat(result, not(nullValue()));
    assertThat(result.getMasterPhysicalName(), is("mst_master3"));

    // 並び順情報
    List<Item> items = result.getOrderSettings().getItems();
    // 1件目
    assertThat(items.get(0).getCode(), is(1L));
    assertThat(items.get(0).getName(), is("商品A"));
    // 2件目
    assertThat(items.get(1).getCode(), is(4L));
    assertThat(items.get(1).getName(), is("商品D"));
  }

}
