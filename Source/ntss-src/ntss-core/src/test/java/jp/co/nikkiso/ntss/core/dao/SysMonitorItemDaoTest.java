package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.SysMonitorItem;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

/**
 * {@link SysMonitorItemDao}のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql( "classpath:dao.script/SysMonitorItemDaoTest.before.sql")
public class SysMonitorItemDaoTest {

  /**
   * {@link SysMonitorItemDao}
   */
  @Autowired
  SysMonitorItemDao target;

  /**
   * selectAllの検証.
   *
   * 条件：データが存在する
   * 結果：登録されている全データが取得出来る事
   */
  @Test
  public void test_selectAll_正常_データあり() {
    // 実行
    List<SysMonitorItem> result = target.selectAll();
    // 検証
    assertThat(result).hasSize(5);
    // 1件目
    SysMonitorItem sysMonitorItem1 = result.get(0);
    assertThat(sysMonitorItem1.getMoniDataNo()).isEqualTo("0");
    assertNull(sysMonitorItem1.getMoniDataType());
    assertThat(sysMonitorItem1.getMoniDataName()).isEqualTo("工程");
    assertThat(sysMonitorItem1.getMoniDataShortName()).isEqualTo("工程");
    assertThat(sysMonitorItem1.getDataType()).isEqualTo(0);
    assertThat(sysMonitorItem1.getDecimalFigure()).isEqualTo(0);
    assertNull(sysMonitorItem1.getUnit());
    assertThat(sysMonitorItem1.getUpper()).isEqualTo(new BigDecimal("11.00"));
    assertThat(sysMonitorItem1.getLower()).isEqualTo(new BigDecimal ("0.00"));
    assertThat(sysMonitorItem1.getIsDisp()).isEqualTo("1");
    assertThat(sysMonitorItem1.getVitalMonitorClass()).isEqualTo("2");
    assertThat(sysMonitorItem1.getConvItem()).isEqualTo("{\"1\": \"プリセット\", \"2\": \"洗浄\", \"3\": \"酸洗\", \"4\": \"消毒\", \"5\": \"滞留\", \"6\": \"液置換\", \"7\": \"準備回収\", \"8\": \"ガスパージ\", \"9\": \"排液\", \"10\": \"停止\", \"11\": \"運転\"}");
    assertThat(sysMonitorItem1.getRegDate()).isEqualTo(Timestamp.valueOf("2019-12-27 16:00:28"));
    assertThat(sysMonitorItem1.getUpDate()).isEqualTo(Timestamp.valueOf("2019-12-27 16:00:28"));
    // 2件目
    SysMonitorItem sysMonitorItem2 = result.get(1);
    assertThat(sysMonitorItem2.getMoniDataNo()).isEqualTo("1");
    assertNull(sysMonitorItem2.getMoniDataType());
    assertThat(sysMonitorItem2.getMoniDataName()).isEqualTo("経過時間");
    assertThat(sysMonitorItem2.getMoniDataShortName()).isEqualTo("経過");
    assertThat(sysMonitorItem2.getDataType()).isEqualTo(3);
    assertThat(sysMonitorItem2.getDecimalFigure()).isEqualTo(0);
    assertThat(sysMonitorItem2.getUnit()).isEqualTo("時分");
    assertThat(sysMonitorItem2.getUpper()).isEqualTo(new BigDecimal("1439.00"));
    assertThat(sysMonitorItem2.getLower()).isEqualTo(new BigDecimal ("0.00"));
    assertThat(sysMonitorItem2.getIsDisp()).isEqualTo("1");
    assertThat(sysMonitorItem2.getVitalMonitorClass()).isEqualTo("2");
    assertNull(sysMonitorItem2.getConvItem());
    assertThat(sysMonitorItem2.getRegDate()).isEqualTo(Timestamp.valueOf("2019-12-27 16:00:28"));
    assertThat(sysMonitorItem2.getUpDate()).isEqualTo(Timestamp.valueOf("2019-12-27 16:00:28"));
    // 3件目
    SysMonitorItem sysMonitorItem3 = result.get(2);
    assertThat(sysMonitorItem3.getMoniDataNo()).isEqualTo("2");
    assertNull(sysMonitorItem3.getMoniDataType());
    assertThat(sysMonitorItem3.getMoniDataName()).isEqualTo("経過時間(ECUM)");
    assertThat(sysMonitorItem3.getMoniDataShortName()).isEqualTo("経過(ECUM)");
    assertThat(sysMonitorItem3.getDataType()).isEqualTo(3);
    assertThat(sysMonitorItem3.getDecimalFigure()).isEqualTo(0);
    assertThat(sysMonitorItem3.getUnit()).isEqualTo("時分");
    assertThat(sysMonitorItem3.getUpper()).isEqualTo(new BigDecimal("1439.00"));
    assertThat(sysMonitorItem3.getLower()).isEqualTo(new BigDecimal ("0.00"));
    assertThat(sysMonitorItem3.getIsDisp()).isEqualTo("1");
    assertThat(sysMonitorItem3.getVitalMonitorClass()).isEqualTo("2");
    assertNull(sysMonitorItem3.getConvItem());
    assertThat(sysMonitorItem3.getRegDate()).isEqualTo(Timestamp.valueOf("2019-12-27 16:00:28"));
    assertThat(sysMonitorItem3.getUpDate()).isEqualTo(Timestamp.valueOf("2019-12-27 16:00:28"));
    // 4件目
    SysMonitorItem sysMonitorItem4 = result.get(3);
    assertThat(sysMonitorItem4.getMoniDataNo()).isEqualTo("3");
    assertThat(sysMonitorItem4.getMoniDataType()).isEqualTo("1");
    assertThat(sysMonitorItem4.getMoniDataName()).isEqualTo("残り時間(除水完了)");
    assertThat(sysMonitorItem4.getMoniDataShortName()).isEqualTo("残り(除水)");
    assertThat(sysMonitorItem4.getDataType()).isEqualTo(3);
    assertThat(sysMonitorItem4.getDecimalFigure()).isEqualTo(0);
    assertThat(sysMonitorItem4.getUnit()).isEqualTo("時分");
    assertThat(sysMonitorItem4.getUpper()).isEqualTo(new BigDecimal("1439.00"));
    assertThat(sysMonitorItem4.getLower()).isEqualTo(new BigDecimal ("0.00"));
    assertThat(sysMonitorItem4.getIsDisp()).isEqualTo("1");
    assertThat(sysMonitorItem4.getVitalMonitorClass()).isEqualTo("2");
    assertNull(sysMonitorItem4.getConvItem());
    assertThat(sysMonitorItem4.getRegDate()).isEqualTo(Timestamp.valueOf("2019-12-27 16:00:28"));
    assertThat(sysMonitorItem4.getUpDate()).isEqualTo(Timestamp.valueOf("2019-12-27 16:00:28"));
    // 5件目
    SysMonitorItem sysMonitorItem5 = result.get(4);
    assertThat(sysMonitorItem5.getMoniDataNo()).isEqualTo("4");
    assertThat(sysMonitorItem5.getMoniDataType()).isEqualTo("1");
    assertThat(sysMonitorItem5.getMoniDataName()).isEqualTo("残り時間(透析完了)");
    assertThat(sysMonitorItem5.getMoniDataShortName()).isEqualTo("残り(透析)");
    assertThat(sysMonitorItem5.getDataType()).isEqualTo(3);
    assertThat(sysMonitorItem5.getDecimalFigure()).isEqualTo(0);
    assertThat(sysMonitorItem5.getUnit()).isEqualTo("時分");
    assertThat(sysMonitorItem5.getUpper()).isEqualTo(new BigDecimal("1439.00"));
    assertThat(sysMonitorItem5.getLower()).isEqualTo(new BigDecimal ("0.00"));
    assertThat(sysMonitorItem5.getIsDisp()).isEqualTo("1");
    assertThat(sysMonitorItem5.getVitalMonitorClass()).isEqualTo("2");
    assertNull(sysMonitorItem5.getConvItem());
    assertThat(sysMonitorItem5.getRegDate()).isEqualTo(Timestamp.valueOf("2019-12-27 16:00:28"));
    assertThat(sysMonitorItem5.getUpDate()).isEqualTo(Timestamp.valueOf("2019-12-27 16:00:28"));
  }

  /**
   * selectAllの検証.
   *
   * 条件：データが存在しない事
   * 結果：空のリストが返却される事
   */
  @Test
  @Sql( "classpath:dao.script/SysMonitorItemDaoTestDelete.before.sql")
  public void test_selectAll_正常_データなし() {
    // 実行
    List<SysMonitorItem> result = target.selectAll();
    // 検証
    assertTrue(result.isEmpty());
  }

  /**
   * selectByMoniDataNoの検証.
   *
   * 条件：データが存在する
   * 結果：該当するデータが取得出来る事
   */
  @Test
  public void test_selectByMoniDataNo_正常_該当データあり() {
    // 事前準備
    final String moniDataNo = "1";
    // 実行
    SysMonitorItem result = target.selectByMoniDataNo(moniDataNo);
    // 検証
    assertNotNull(result);
    assertThat(result.getMoniDataNo()).isEqualTo("1");
    assertNull(result.getMoniDataType());
    assertThat(result.getMoniDataName()).isEqualTo("経過時間");
    assertThat(result.getMoniDataShortName()).isEqualTo("経過");
    assertThat(result.getDataType()).isEqualTo(3);
    assertThat(result.getDecimalFigure()).isEqualTo(0);
    assertThat(result.getUnit()).isEqualTo("時分");
    assertThat(result.getUpper()).isEqualTo(new BigDecimal("1439.00"));
    assertThat(result.getLower()).isEqualTo(new BigDecimal ("0.00"));
    assertThat(result.getIsDisp()).isEqualTo("1");
    assertThat(result.getVitalMonitorClass()).isEqualTo("2");
    assertNull(result.getConvItem());
    assertThat(result.getRegDate()).isEqualTo(Timestamp.valueOf("2019-12-27 16:00:28"));
    assertThat(result.getUpDate()).isEqualTo(Timestamp.valueOf("2019-12-27 16:00:28"));
  }

  /**
   * selectByMoniDataNoの検証.
   *
   * 条件：データが存在しない
   * 結果：nullが取得出来る事
   */
  @Test
  public void test_selectByMoniDataNo_正常_該当データなし() {
    // 事前準備
    final String moniDataNo = "999";
    // 実行
    SysMonitorItem result = target.selectByMoniDataNo(moniDataNo);
    // 検証
    assertNull(result);
  }

  /**
   * selectByMoniDataTypeの検証.
   *
   * 条件：データが存在する
   * 結果：該当するデータのリストが取得出来る事
   */
  @Test
  public void test_selectByMoniDataType_正常_該当データあり() {
    // 事前準備
    final String moniDataType = "1";
    // 実行
    List<SysMonitorItem> result = target.selectByMoniDataType(moniDataType);
    // 検証
    assertThat(result).hasSize(2);
    // 4件目
    SysMonitorItem sysMonitorItem1 = result.get(0);
    assertThat(sysMonitorItem1.getMoniDataNo()).isEqualTo("3");
    assertThat(sysMonitorItem1.getMoniDataType()).isEqualTo("1");
    assertThat(sysMonitorItem1.getMoniDataName()).isEqualTo("残り時間(除水完了)");
    assertThat(sysMonitorItem1.getMoniDataShortName()).isEqualTo("残り(除水)");
    assertThat(sysMonitorItem1.getDataType()).isEqualTo(3);
    assertThat(sysMonitorItem1.getDecimalFigure()).isEqualTo(0);
    assertThat(sysMonitorItem1.getUnit()).isEqualTo("時分");
    assertThat(sysMonitorItem1.getUpper()).isEqualTo(new BigDecimal("1439.00"));
    assertThat(sysMonitorItem1.getLower()).isEqualTo(new BigDecimal ("0.00"));
    assertThat(sysMonitorItem1.getIsDisp()).isEqualTo("1");
    assertThat(sysMonitorItem1.getVitalMonitorClass()).isEqualTo("2");
    assertNull(sysMonitorItem1.getConvItem());
    assertThat(sysMonitorItem1.getRegDate()).isEqualTo(Timestamp.valueOf("2019-12-27 16:00:28"));
    assertThat(sysMonitorItem1.getUpDate()).isEqualTo(Timestamp.valueOf("2019-12-27 16:00:28"));
    // 5件目
    SysMonitorItem sysMonitorItem2 = result.get(1);
    assertThat(sysMonitorItem2.getMoniDataNo()).isEqualTo("4");
    assertThat(sysMonitorItem2.getMoniDataType()).isEqualTo("1");
    assertThat(sysMonitorItem2.getMoniDataName()).isEqualTo("残り時間(透析完了)");
    assertThat(sysMonitorItem2.getMoniDataShortName()).isEqualTo("残り(透析)");
    assertThat(sysMonitorItem2.getDataType()).isEqualTo(3);
    assertThat(sysMonitorItem2.getDecimalFigure()).isEqualTo(0);
    assertThat(sysMonitorItem2.getUnit()).isEqualTo("時分");
    assertThat(sysMonitorItem2.getUpper()).isEqualTo(new BigDecimal("1439.00"));
    assertThat(sysMonitorItem2.getLower()).isEqualTo(new BigDecimal ("0.00"));
    assertThat(sysMonitorItem2.getIsDisp()).isEqualTo("1");
    assertThat(sysMonitorItem2.getVitalMonitorClass()).isEqualTo("2");
    assertNull(sysMonitorItem2.getConvItem());
    assertThat(sysMonitorItem2.getRegDate()).isEqualTo(Timestamp.valueOf("2019-12-27 16:00:28"));
    assertThat(sysMonitorItem2.getUpDate()).isEqualTo(Timestamp.valueOf("2019-12-27 16:00:28"));
  }

  /**
   * selectByMoniDataTypeの検証.
   *
   * 条件：データが存在しない
   * 結果：空のリストが取得出来る事
   */
  @Test
  public void test_selectByMoniDataType_正常_該当データなし() {
    // 事前準備
    final String moniDataType = "0";
    // 実行
    List<SysMonitorItem> result = target.selectByMoniDataType(moniDataType);
    // 検証
    assertTrue(result.isEmpty());
  }

  /**
   * selectByMoniDataTypeAndClassの検証.
   *
   * 条件：データが存在する
   * 結果：該当するデータのリストが取得出来る事
   */
  @Test
  public void test_selectByMoniDataTypeAndClass_正常_該当データあり() {
    // 事前準備
    final String moniDataType = "1";
    final String vitalMonitorClass = "2";
    // 実行
    List<SysMonitorItem> result = target.selectByMoniDataTypeAndClass(moniDataType, vitalMonitorClass);
    // 検証
    assertThat(result).hasSize(2);
    // 4件目
    SysMonitorItem sysMonitorItem1 = result.get(0);
    assertThat(sysMonitorItem1.getMoniDataNo()).isEqualTo("3");
    assertThat(sysMonitorItem1.getMoniDataType()).isEqualTo("1");
    assertThat(sysMonitorItem1.getMoniDataName()).isEqualTo("残り時間(除水完了)");
    assertThat(sysMonitorItem1.getMoniDataShortName()).isEqualTo("残り(除水)");
    assertThat(sysMonitorItem1.getDataType()).isEqualTo(3);
    assertThat(sysMonitorItem1.getDecimalFigure()).isEqualTo(0);
    assertThat(sysMonitorItem1.getUnit()).isEqualTo("時分");
    assertThat(sysMonitorItem1.getUpper()).isEqualTo(new BigDecimal("1439.00"));
    assertThat(sysMonitorItem1.getLower()).isEqualTo(new BigDecimal ("0.00"));
    assertThat(sysMonitorItem1.getIsDisp()).isEqualTo("1");
    assertThat(sysMonitorItem1.getVitalMonitorClass()).isEqualTo("2");
    assertNull(sysMonitorItem1.getConvItem());
    assertThat(sysMonitorItem1.getRegDate()).isEqualTo(Timestamp.valueOf("2019-12-27 16:00:28"));
    assertThat(sysMonitorItem1.getUpDate()).isEqualTo(Timestamp.valueOf("2019-12-27 16:00:28"));
    // 5件目
    SysMonitorItem sysMonitorItem2 = result.get(1);
    assertThat(sysMonitorItem2.getMoniDataNo()).isEqualTo("4");
    assertThat(sysMonitorItem2.getMoniDataType()).isEqualTo("1");
    assertThat(sysMonitorItem2.getMoniDataName()).isEqualTo("残り時間(透析完了)");
    assertThat(sysMonitorItem2.getMoniDataShortName()).isEqualTo("残り(透析)");
    assertThat(sysMonitorItem2.getDataType()).isEqualTo(3);
    assertThat(sysMonitorItem2.getDecimalFigure()).isEqualTo(0);
    assertThat(sysMonitorItem2.getUnit()).isEqualTo("時分");
    assertThat(sysMonitorItem2.getUpper()).isEqualTo(new BigDecimal("1439.00"));
    assertThat(sysMonitorItem2.getLower()).isEqualTo(new BigDecimal ("0.00"));
    assertThat(sysMonitorItem2.getIsDisp()).isEqualTo("1");
    assertThat(sysMonitorItem2.getVitalMonitorClass()).isEqualTo("2");
    assertNull(sysMonitorItem2.getConvItem());
    assertThat(sysMonitorItem2.getRegDate()).isEqualTo(Timestamp.valueOf("2019-12-27 16:00:28"));
    assertThat(sysMonitorItem2.getUpDate()).isEqualTo(Timestamp.valueOf("2019-12-27 16:00:28"));
  }

  /**
   * selectByMoniDataTypeAndClassの検証.
   *
   * 条件：データが存在する
   *      moniDataType = null
   * 結果：該当するデータのリストが取得出来る事
   */
  @Test
  public void test_selectByMoniDataTypeAndClass_正常_該当データあり_null() {
    // 事前準備
    final String vitalMonitorClass = "2";
    // 実行
    List<SysMonitorItem> result = target.selectByMoniDataTypeAndClass(null, vitalMonitorClass);
    // 検証
    assertThat(result).hasSize(3);
    // 1件目
    SysMonitorItem sysMonitorItem1 = result.get(0);
    assertThat(sysMonitorItem1.getMoniDataNo()).isEqualTo("0");
    assertNull(sysMonitorItem1.getMoniDataType());
    assertThat(sysMonitorItem1.getMoniDataName()).isEqualTo("工程");
    assertThat(sysMonitorItem1.getMoniDataShortName()).isEqualTo("工程");
    assertThat(sysMonitorItem1.getDataType()).isEqualTo(0);
    assertThat(sysMonitorItem1.getDecimalFigure()).isEqualTo(0);
    assertNull(sysMonitorItem1.getUnit());
    assertThat(sysMonitorItem1.getUpper()).isEqualTo(new BigDecimal("11.00"));
    assertThat(sysMonitorItem1.getLower()).isEqualTo(new BigDecimal ("0.00"));
    assertThat(sysMonitorItem1.getIsDisp()).isEqualTo("1");
    assertThat(sysMonitorItem1.getVitalMonitorClass()).isEqualTo("2");
    assertThat(sysMonitorItem1.getConvItem()).isEqualTo("{\"1\": \"プリセット\", \"2\": \"洗浄\", \"3\": \"酸洗\", \"4\": \"消毒\", \"5\": \"滞留\", \"6\": \"液置換\", \"7\": \"準備回収\", \"8\": \"ガスパージ\", \"9\": \"排液\", \"10\": \"停止\", \"11\": \"運転\"}");
    assertThat(sysMonitorItem1.getRegDate()).isEqualTo(Timestamp.valueOf("2019-12-27 16:00:28"));
    assertThat(sysMonitorItem1.getUpDate()).isEqualTo(Timestamp.valueOf("2019-12-27 16:00:28"));
    // 2件目
    SysMonitorItem sysMonitorItem2 = result.get(1);
    assertThat(sysMonitorItem2.getMoniDataNo()).isEqualTo("1");
    assertNull(sysMonitorItem2.getMoniDataType());
    assertThat(sysMonitorItem2.getMoniDataName()).isEqualTo("経過時間");
    assertThat(sysMonitorItem2.getMoniDataShortName()).isEqualTo("経過");
    assertThat(sysMonitorItem2.getDataType()).isEqualTo(3);
    assertThat(sysMonitorItem2.getDecimalFigure()).isEqualTo(0);
    assertThat(sysMonitorItem2.getUnit()).isEqualTo("時分");
    assertThat(sysMonitorItem2.getUpper()).isEqualTo(new BigDecimal("1439.00"));
    assertThat(sysMonitorItem2.getLower()).isEqualTo(new BigDecimal ("0.00"));
    assertThat(sysMonitorItem2.getIsDisp()).isEqualTo("1");
    assertThat(sysMonitorItem2.getVitalMonitorClass()).isEqualTo("2");
    assertNull(sysMonitorItem2.getConvItem());
    assertThat(sysMonitorItem2.getRegDate()).isEqualTo(Timestamp.valueOf("2019-12-27 16:00:28"));
    assertThat(sysMonitorItem2.getUpDate()).isEqualTo(Timestamp.valueOf("2019-12-27 16:00:28"));
    // 3件目
    SysMonitorItem sysMonitorItem3 = result.get(2);
    assertThat(sysMonitorItem3.getMoniDataNo()).isEqualTo("2");
    assertNull(sysMonitorItem3.getMoniDataType());
    assertThat(sysMonitorItem3.getMoniDataName()).isEqualTo("経過時間(ECUM)");
    assertThat(sysMonitorItem3.getMoniDataShortName()).isEqualTo("経過(ECUM)");
    assertThat(sysMonitorItem3.getDataType()).isEqualTo(3);
    assertThat(sysMonitorItem3.getDecimalFigure()).isEqualTo(0);
    assertThat(sysMonitorItem3.getUnit()).isEqualTo("時分");
    assertThat(sysMonitorItem3.getUpper()).isEqualTo(new BigDecimal("1439.00"));
    assertThat(sysMonitorItem3.getLower()).isEqualTo(new BigDecimal ("0.00"));
    assertThat(sysMonitorItem3.getIsDisp()).isEqualTo("1");
    assertThat(sysMonitorItem3.getVitalMonitorClass()).isEqualTo("2");
    assertNull(sysMonitorItem3.getConvItem());
    assertThat(sysMonitorItem3.getRegDate()).isEqualTo(Timestamp.valueOf("2019-12-27 16:00:28"));
    assertThat(sysMonitorItem3.getUpDate()).isEqualTo(Timestamp.valueOf("2019-12-27 16:00:28"));
  }

  /**
   * selectByMoniDataTypeAndClassの検証.
   *
   * 条件：データが存在しない
   * 結果：空のリストが取得出来る事
   */
  @Test
  public void test_selectByMoniDataTypeAndClass_正常_該当データなし() {
    // 事前準備
    final String vitalMonitorClass = "9";
    // 実行
    List<SysMonitorItem> result = target.selectByMoniDataTypeAndClass(null, vitalMonitorClass);
    // 検証
    assertTrue(result.isEmpty());
  }
}
