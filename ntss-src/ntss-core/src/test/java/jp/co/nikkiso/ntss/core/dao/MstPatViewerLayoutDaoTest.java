package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.custom.MstPatViewerLayoutMonitorItem;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.nullValue;
import static org.junit.Assert.assertThat;
import static org.junit.Assert.assertTrue;

/**
 * {@link MstPatViewerLayoutDao} のテストクラス
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
public class MstPatViewerLayoutDaoTest {

  /**
   * テスト対象クラス
   */
  @Autowired
  private MstPatViewerLayoutDao mstPatViewerLayoutDao;

  /**
   * {@link MstPatViewerLayoutDao#selectMonitorItem(String)} の検証
   *
   * <p>
   *   条件:取得データ無し
   *   結果:空の配列が返却される事
   * </p>
   */
  @Test
  @Sql( "classpath:dao.script/MstPatViewerLayoutDaoTestDelete.before.sql")
  public void test_selectMonitorItem_正常_データなし() {
    // 事前準備
    String facilityCd = "0001";
    // 実行
    List<MstPatViewerLayoutMonitorItem> result = mstPatViewerLayoutDao.selectMonitorItem(facilityCd,null);
    // 検証
    assertTrue(result.isEmpty());
  }

  /**
   * {@link MstPatViewerLayoutDao#selectMonitorItem(String)} の検証
   *
   * <p>
   *   条件:指定された施設コードに該当する{@link jp.co.nikkiso.ntss.core.entity.MstAddMonitor}が存在する事
   *   結果:sys_monitor_item と mst_add_monitor のリストが取得出来る事
   * </p>
   */
  @Test
  @Sql( "classpath:dao.script/MstPatViewerLayoutDaoTest.before.sql")
  public void test_selectMonitorItem_正常_データあり() {
    // 事前準備
    String facilityCd = "1001";
    // 実行
    List<MstPatViewerLayoutMonitorItem> result = mstPatViewerLayoutDao.selectMonitorItem(facilityCd,null);
    // 検証
    assertThat(result.size(), is(233 - 6)); // is_dispが初期値0のもの6件
    // sys_monitor_item の件数チェック
    List<MstPatViewerLayoutMonitorItem> sysMonitorItem =
      result.stream()
        .filter(r -> r.getTableType() == 1)
        .collect(Collectors.toList());
    assertThat(sysMonitorItem.size(), is(230 - 6)); // is_dispが初期値0のもの6件
    // mst_add_monitor の件数チェック
    List<MstPatViewerLayoutMonitorItem> mstAddMonitorItem =
      result.stream()
        .filter(r -> r.getTableType() == 2)
        .collect(Collectors.toList());
    assertThat(mstAddMonitorItem.size(), is(3));

    // 並び順のチェック
    // ・vital_monitor_class（昇順）
    // ・table_type（昇順）
    // ・moni_data_no（昇順）
    assertThat(result.get(0).getVitalMonitorClass(), is("1"));
    assertThat(result.get(0).getTableType(), is(1));
    assertThat(result.get(0).getMoniDataNo(), is("-2"));
    assertThat(result.get(0).getVitalMonitorItemName(), is("SpO2"));
    assertThat(result.get(0).getMoniDataType(), nullValue());
    assertThat(result.get(0).getMoniDataNoSort(), is(-2L));
    assertThat(result.get(0).getPurificationType(), nullValue());

    assertThat(result.get(5).getVitalMonitorClass(), is("1"));
    assertThat(result.get(5).getTableType(), is(1));
    assertThat(result.get(5).getMoniDataNo(), is("93"));
    assertThat(result.get(5).getVitalMonitorItemName(), is("脈拍"));
    assertThat(result.get(5).getMoniDataType(), nullValue());
    assertThat(result.get(5).getMoniDataNoSort(), is(93L));
    assertThat(result.get(5).getPurificationType(), nullValue());

    assertThat(result.get(6).getVitalMonitorClass(), is("1"));
    assertThat(result.get(6).getTableType(), is(1));
    assertThat(result.get(6).getMoniDataNo(), is("94"));
    assertThat(result.get(6).getVitalMonitorItemName(), is("体温"));
    assertThat(result.get(6).getMoniDataType(), nullValue());
    assertThat(result.get(6).getMoniDataNoSort(), is(94L));
    assertThat(result.get(6).getPurificationType(), nullValue());

    assertThat(result.get(7).getVitalMonitorClass(), is("1"));
    assertThat(result.get(7).getTableType(), is(2));
    assertThat(result.get(7).getMoniDataNo(), is("0"));
    assertThat(result.get(7).getVitalMonitorItemName(), is("サンプル0"));
    assertThat(result.get(7).getMoniDataType(), nullValue());
    assertThat(result.get(7).getMoniDataNoSort(), is(0L));
    assertThat(result.get(7).getPurificationType(), nullValue());

    assertThat(result.get(9).getVitalMonitorClass(), is("2"));
    assertThat(result.get(9).getTableType(), is(1));
    assertThat(result.get(9).getMoniDataNo(), is("0"));
    assertThat(result.get(9).getVitalMonitorItemName(), is("工程"));
    assertThat(result.get(9).getMoniDataType(), nullValue());
    assertThat(result.get(9).getMoniDataNoSort(), is(0L));
    assertThat(result.get(9).getPurificationType(), nullValue());
  }

  /**
   * {@link MstPatViewerLayoutDao#selectMonitorItem(String)} の検証
   *
   * <p>
   *   条件:バイタルモニタ項目追加マスタにデータ無し
   *   結果:モニタ項目(sys_monitor_item)のみのデータが返される事
   * </p>
   */
  @Test
  public void test_selectMonitorItem_正常_バイタルモニタ項目追加マスタにデータなし() {
    // 事前準備
    String facilityCd = "1001";
    // 実行
    List<MstPatViewerLayoutMonitorItem> result = mstPatViewerLayoutDao.selectMonitorItem(facilityCd,null);
    // 検証
    assertThat(result.size(), is(230 - 6)); // is_dispが初期値0のもの6件
    // テーブル種別に2のデータが含まれていない事を確認
    List<MstPatViewerLayoutMonitorItem> mstAddMonitorItem =
      result.stream()
        .filter(r -> r.getTableType() == 2)
        .collect(Collectors.toList());
    assertTrue(mstAddMonitorItem.isEmpty());
  }

  /**
   * {@link MstPatViewerLayoutDao#selectMonitorItem(String)} の検証
   *
   * <p>
   *   条件:特殊浄化のモニタ項目が登録されている
   *   結果:特殊浄化のモニタ項目も返却される事
   * </p>
   */
  @Test
  @Sql( "classpath:dao.script/MstPatViewerLayoutDaoTestPurification.before.sql")
  @Sql( "classpath:dao.script/MstPatViewerLayoutDaoTest.before.sql")
  public void test_selectMonitorItem_正常_特殊浄化が含まれている場合() {
    // 事前準備
    String facilityCd = "1001";
    // 実行
    List<MstPatViewerLayoutMonitorItem> result = mstPatViewerLayoutDao.selectMonitorItem(facilityCd,null);
    // 検証
    assertThat(result.size(), is(235 - 6)); // is_dispが初期値0のもの6件
    // sys_monitor_item の件数チェック
    List<MstPatViewerLayoutMonitorItem> sysMonitorItem =
      result.stream()
        .filter(r -> r.getTableType() == 1)
        .collect(Collectors.toList());
    assertThat(sysMonitorItem.size(), is(232 - 6)); // is_dispが初期値0のもの6件
    // sys_monitor_item の件数チェック(透析装置)
    List<MstPatViewerLayoutMonitorItem> sysMonitorItemMachine =
      result.stream()
        .filter(r -> r.getTableType() == 1 && r.getMoniDataType() == null)
        .collect(Collectors.toList());
    assertThat(sysMonitorItemMachine.size(), is(99 - 6)); // is_dispが初期値0のもの6件
    // sys_monitor_item の件数チェック(特殊浄化)
    List<MstPatViewerLayoutMonitorItem> sysMonitorItemPurification =
      result.stream()
        .filter(r -> r.getTableType() == 1 && "Z".equals(r.getMoniDataType()))
        .collect(Collectors.toList());
    assertThat(sysMonitorItemPurification.size(), is(133));

    // mst_add_monitor の件数チェック
    List<MstPatViewerLayoutMonitorItem> mstAddMonitorItem =
      result.stream()
        .filter(r -> r.getTableType() == 2)
        .collect(Collectors.toList());
    assertThat(mstAddMonitorItem.size(), is(3));
  }

  /**
   * {@link MstPatViewerLayoutDao#selectMonitorItem(String)} の検証
   *
   * <p>
   *   条件:複数の特殊浄化装置種別のモニタ項目が登録されている
   *   結果:特殊浄化のモニタ項目も返却される事
   * </p>
   */
  @Test
  @Sql( "classpath:dao.script/MstPatViewerLayoutDaoTest.before.sql")
  public void test_selectMonitorItem_正常_複数の特殊浄化装置種別が含まれている場合() {
    // 事前準備
    String facilityCd = "1001";
    // 実行
    List<MstPatViewerLayoutMonitorItem> result = mstPatViewerLayoutDao.selectMonitorItem(facilityCd,null);
    // 検証
    assertThat(result.size(), is(233 - 6)); // is_dispが初期値0のもの6件
    // sys_monitor_item の件数チェック
    List<MstPatViewerLayoutMonitorItem> sysMonitorItem =
      result.stream()
        .filter(r -> r.getTableType() == 1)
        .collect(Collectors.toList());
    assertThat(sysMonitorItem.size(), is(230 - 6)); // is_dispが初期値0のもの6件
    // sys_monitor_item の件数チェック(透析装置)
    List<MstPatViewerLayoutMonitorItem> sysMonitorItemMachine =
      result.stream()
        .filter(r -> r.getTableType() == 1 && r.getMoniDataType() == null)
        .collect(Collectors.toList());
    assertThat(sysMonitorItemMachine.size(), is(99 - 6)); // is_dispが初期値0のもの6件
    // sys_monitor_item の件数チェック(特殊浄化)
    List<MstPatViewerLayoutMonitorItem> sysMonitorItemPurification =
      result.stream()
        .filter(r -> r.getTableType() == 1 && "Z".equals(r.getMoniDataType()))
        .collect(Collectors.toList());
    assertThat(sysMonitorItemPurification.size(), is(131));

    // mst_add_monitor の件数チェック
    List<MstPatViewerLayoutMonitorItem> mstAddMonitorItem =
      result.stream()
        .filter(r -> r.getTableType() == 2)
        .collect(Collectors.toList());
    assertThat(mstAddMonitorItem.size(), is(3));

    // 特殊浄化の並び順のチェック
    // 特殊浄化装置種別の並び順は下記の通りであること
    //  シグマ
    //  KM8900
    //  iQ
    //  KM9000
    assertThat(result.get(95).getVitalMonitorClass(), is("2"));
    assertThat(result.get(95).getTableType(), is(1));
    assertThat(result.get(95).getMoniDataNo(), is("Z11"));
    assertThat(result.get(95).getVitalMonitorItemName(), is("[ACHΣ]治療モード"));
    assertThat(result.get(95).getMoniDataType(), is("Z"));
    assertThat(result.get(95).getMoniDataNoSort(), is(11L));
    assertThat(result.get(95).getPurificationType(), is(1));

    assertThat(result.get(96).getVitalMonitorClass(), is("2"));
    assertThat(result.get(96).getTableType(), is(1));
    assertThat(result.get(96).getMoniDataNo(), is("Z21"));
    assertThat(result.get(96).getVitalMonitorItemName(), is("[ACHΣ]工程状態"));
    assertThat(result.get(96).getMoniDataType(), is("Z"));
    assertThat(result.get(96).getMoniDataNoSort(), is(21L));
    assertThat(result.get(96).getPurificationType(), is(1));

    assertThat(result.get(97).getVitalMonitorClass(), is("2"));
    assertThat(result.get(97).getTableType(), is(1));
    assertThat(result.get(97).getMoniDataNo(), is("Z31"));
    assertThat(result.get(97).getVitalMonitorItemName(), is("[ACHΣ]除水速度"));
    assertThat(result.get(97).getMoniDataType(), is("Z"));
    assertThat(result.get(97).getMoniDataNoSort(), is(31L));
    assertThat(result.get(97).getPurificationType(), is(1));

    assertThat(result.get(140).getVitalMonitorClass(), is("2"));
    assertThat(result.get(140).getTableType(), is(1));
    assertThat(result.get(140).getMoniDataNo(), is("Z12"));
    assertThat(result.get(140).getVitalMonitorItemName(), is("[KM8900]測定値TMP"));
    assertThat(result.get(140).getMoniDataType(), is("Z"));
    assertThat(result.get(140).getMoniDataNoSort(), is(12L));
    assertThat(result.get(140).getPurificationType(), is(2));

    assertThat(result.get(163).getVitalMonitorClass(), is("2"));
    assertThat(result.get(163).getTableType(), is(1));
    assertThat(result.get(163).getMoniDataNo(), is("Z13"));
    assertThat(result.get(163).getVitalMonitorItemName(), is("[iQ21]治療経過時間"));
    assertThat(result.get(163).getMoniDataType(), is("Z"));
    assertThat(result.get(163).getMoniDataNoSort(), is(13L));
    assertThat(result.get(163).getPurificationType(), is(3));

    assertThat(result.get(189).getVitalMonitorClass(), is("2"));
    assertThat(result.get(189).getTableType(), is(1));
    assertThat(result.get(189).getMoniDataNo(), is("Z14"));
    assertThat(result.get(189).getVitalMonitorItemName(), is("[KM9000]測定値TMP圧"));
    assertThat(result.get(189).getMoniDataType(), is("Z"));
    assertThat(result.get(189).getMoniDataNoSort(), is(14L));
    assertThat(result.get(189).getPurificationType(), is(4));
  }
}
