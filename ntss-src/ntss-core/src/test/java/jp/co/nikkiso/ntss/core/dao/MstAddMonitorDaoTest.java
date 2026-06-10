package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.MstAddMonitor;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Timestamp;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

/**
 * {@link MstAddMonitorDao}のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql( "classpath:dao.script/MstAddMonitorDaoTest.before.sql")
public class MstAddMonitorDaoTest {

  /**
   * {@link MstAddMonitorDao}
   */
  @Autowired
  MstAddMonitorDao target;

  /**
   * selectAllByFacilityCdの検証.
   *
   * 条件：データが存在する施設コードを指定
   * 結果：結果が取得出来る事
   */
  @Test
  public void test_selectAllByFacilityCd_正常_該当データあり() {
    // テスト対象の施設コード
    final String facilityCd = "1001";
    // 実行
    final List<MstAddMonitor> result = target.selectAllByFacilityCd(facilityCd);
    // 検証
    assertThat(result).hasSize(5);
    // 1件目
    MstAddMonitor mstAddMonitor1 = result.get(0);
    assertThat(mstAddMonitor1.getVitalMonitorItemCd()).isEqualTo(0L);
    assertThat(mstAddMonitor1.getFacilityCd()).isEqualTo(facilityCd);
    assertThat(mstAddMonitor1.getVitalMonitorClass()).isEqualTo("1");
    assertThat(mstAddMonitor1.getVitalMonitorItemName()).isEqualTo("サンプル0");
    assertThat(mstAddMonitor1.getIsDisp()).isEqualTo("1");
    assertThat(mstAddMonitor1.getIsDel()).isEqualTo("0");
    assertThat(mstAddMonitor1.getRegDate()).isEqualTo(Timestamp.valueOf("2019-12-26 12:05:03"));
    assertThat(mstAddMonitor1.getUpDate()).isEqualTo(Timestamp.valueOf("2019-12-26 12:05:03"));
    // 2件目
    MstAddMonitor mstAddMonitor2 = result.get(1);
    assertThat(mstAddMonitor2.getVitalMonitorItemCd()).isEqualTo(1L);
    assertThat(mstAddMonitor2.getFacilityCd()).isEqualTo(facilityCd);
    assertThat(mstAddMonitor2.getVitalMonitorClass()).isEqualTo("1");
    assertThat(mstAddMonitor2.getVitalMonitorItemName()).isEqualTo("サンプル1");
    assertThat(mstAddMonitor2.getIsDisp()).isEqualTo("0");
    assertThat(mstAddMonitor2.getIsDel()).isEqualTo("0");
    assertThat(mstAddMonitor2.getRegDate()).isEqualTo(Timestamp.valueOf("2019-12-26 12:05:03"));
    assertThat(mstAddMonitor2.getUpDate()).isEqualTo(Timestamp.valueOf("2019-12-26 12:05:03"));
    // 3件目
    MstAddMonitor mstAddMonitor3 = result.get(2);
    assertThat(mstAddMonitor3.getVitalMonitorItemCd()).isEqualTo(2L);
    assertThat(mstAddMonitor3.getFacilityCd()).isEqualTo(facilityCd);
    assertThat(mstAddMonitor3.getVitalMonitorClass()).isEqualTo("2");
    assertThat(mstAddMonitor3.getVitalMonitorItemName()).isEqualTo("サンプル2");
    assertThat(mstAddMonitor3.getIsDisp()).isEqualTo("1");
    assertThat(mstAddMonitor3.getIsDel()).isEqualTo("0");
    assertThat(mstAddMonitor3.getRegDate()).isEqualTo(Timestamp.valueOf("2019-12-26 12:05:03"));
    assertThat(mstAddMonitor3.getUpDate()).isEqualTo(Timestamp.valueOf("2019-12-26 12:05:03"));
    // 4件目
    MstAddMonitor mstAddMonitor4 = result.get(3);
    assertThat(mstAddMonitor4.getVitalMonitorItemCd()).isEqualTo(3L);
    assertThat(mstAddMonitor4.getFacilityCd()).isEqualTo(facilityCd);
    assertThat(mstAddMonitor4.getVitalMonitorClass()).isEqualTo("2");
    assertThat(mstAddMonitor4.getVitalMonitorItemName()).isEqualTo("サンプル3");
    assertThat(mstAddMonitor4.getIsDisp()).isEqualTo("0");
    assertThat(mstAddMonitor4.getIsDel()).isEqualTo("0");
    assertThat(mstAddMonitor4.getRegDate()).isEqualTo(Timestamp.valueOf("2019-12-26 12:05:03"));
    assertThat(mstAddMonitor4.getUpDate()).isEqualTo(Timestamp.valueOf("2019-12-26 12:05:03"));
    // 5件目
    MstAddMonitor mstAddMonitor5 = result.get(4);
    assertThat(mstAddMonitor5.getVitalMonitorItemCd()).isEqualTo(4L);
    assertThat(mstAddMonitor5.getFacilityCd()).isEqualTo(facilityCd);
    assertThat(mstAddMonitor5.getVitalMonitorClass()).isEqualTo("1");
    assertThat(mstAddMonitor5.getVitalMonitorItemName()).isEqualTo("サンプル4");
    assertThat(mstAddMonitor5.getIsDisp()).isEqualTo("1");
    assertThat(mstAddMonitor5.getIsDel()).isEqualTo("0");
    assertThat(mstAddMonitor5.getRegDate()).isEqualTo(Timestamp.valueOf("2019-12-26 12:05:03"));
    assertThat(mstAddMonitor5.getUpDate()).isEqualTo(Timestamp.valueOf("2019-12-26 12:05:03"));
  }

  /**
   * selectAllByFacilityCdの検証.
   *
   * 条件：データが存在しない施設コードを指定
   * 結果：空のリストを取得出来る事
   */
  @Test
  public void test_selectAllByFacilityCd_正常_該当データなし() {
    // テスト対象の施設コード
    final String facilityCd = "9999";
    // 実行
    final List<MstAddMonitor> result = target.selectAllByFacilityCd(facilityCd);
    // 検証
    assertTrue(result.isEmpty());
  }

  /**
   * selectByCdの検証.
   *
   * 条件：データが存在するバイタル・モニタ項目コードを指定
   * 結果：該当するバイタル・モニタ項目情報が取得出来る事
   */
  @Test
  public void test_selectByCd_正常_該当データあり() {
    // テスト対象のバイタル・モニタ項目コード
    final Long vitalMonitorItemCd = 5L;
    // 実行
    final MstAddMonitor result = target.selectByCd(vitalMonitorItemCd);
    // 検証
    assertNotNull(result);
    assertThat(result.getVitalMonitorItemCd()).isEqualTo(vitalMonitorItemCd);
    assertThat(result.getFacilityCd()).isEqualTo("1002");
    assertThat(result.getVitalMonitorClass()).isEqualTo("2");
    assertThat(result.getVitalMonitorItemName()).isEqualTo("サンプル5");
    assertThat(result.getIsDisp()).isEqualTo("1");
    assertThat(result.getIsDel()).isEqualTo("0");
    assertThat(result.getRegDate()).isEqualTo(Timestamp.valueOf("2019-12-26 12:05:03"));
    assertThat(result.getUpDate()).isEqualTo(Timestamp.valueOf("2019-12-26 12:05:03"));
  }

  /**
   * selectByCdの検証.
   *
   * 条件：データが存在しないバイタル・モニタ項目コードを指定
   * 結果：nullが取得出来る事
   */
  @Test
  public void test_selectByCd_正常_該当データなし() {
    // テスト対象のバイタル・モニタ項目コード
    final Long vitalMonitorItemCd = 100L;
    // 実行
    final MstAddMonitor result = target.selectByCd(vitalMonitorItemCd);
    // 検証
    assertNull(result);
  }

  /**
   * selectByVitalMonitorClassの検証.
   *
   * 条件：データが存在する施設コード及びバイタル・モニタ区分を指定
   * 結果：該当するバイタル・モニタ項目情報のリストが取得出来る事
   */
  @Test
  public void test_selectByVitalMonitorClass_正常_該当データあり() {
    // テスト対象のバイタル・モニタ区分
    final String vitalMonitorClass = "1";
    // テスト対象の施設コード
    final String facilityCd = "1003";
    // 実行
    final List<MstAddMonitor> result = target.selectByVitalMonitorClass(facilityCd, vitalMonitorClass);
    // 検証
    assertThat(result).hasSize(5);
    // 1件目
    MstAddMonitor mstAddMonitor1 = result.get(0);
    assertThat(mstAddMonitor1.getVitalMonitorItemCd()).isEqualTo(11L);
    assertThat(mstAddMonitor1.getFacilityCd()).isEqualTo(facilityCd);
    assertThat(mstAddMonitor1.getVitalMonitorClass()).isEqualTo(vitalMonitorClass);
    assertThat(mstAddMonitor1.getVitalMonitorItemName()).isEqualTo("サンプル11");
    assertThat(mstAddMonitor1.getIsDisp()).isEqualTo("1");
    assertThat(mstAddMonitor1.getIsDel()).isEqualTo("0");
    assertThat(mstAddMonitor1.getRegDate()).isEqualTo(Timestamp.valueOf("2019-12-26 12:05:03"));
    assertThat(mstAddMonitor1.getUpDate()).isEqualTo(Timestamp.valueOf("2019-12-26 12:05:03"));
    // 2件目
    MstAddMonitor mstAddMonitor2 = result.get(1);
    assertThat(mstAddMonitor2.getVitalMonitorItemCd()).isEqualTo(12L);
    assertThat(mstAddMonitor2.getFacilityCd()).isEqualTo(facilityCd);
    assertThat(mstAddMonitor2.getVitalMonitorClass()).isEqualTo(vitalMonitorClass);
    assertThat(mstAddMonitor2.getVitalMonitorItemName()).isEqualTo("サンプル12");
    assertThat(mstAddMonitor2.getIsDisp()).isEqualTo("0");
    assertThat(mstAddMonitor2.getIsDel()).isEqualTo("0");
    assertThat(mstAddMonitor2.getRegDate()).isEqualTo(Timestamp.valueOf("2019-12-26 12:05:03"));
    assertThat(mstAddMonitor2.getUpDate()).isEqualTo(Timestamp.valueOf("2019-12-26 12:05:03"));
    // 3件目
    MstAddMonitor mstAddMonitor3 = result.get(2);
    assertThat(mstAddMonitor3.getVitalMonitorItemCd()).isEqualTo(13L);
    assertThat(mstAddMonitor3.getFacilityCd()).isEqualTo(facilityCd);
    assertThat(mstAddMonitor3.getVitalMonitorClass()).isEqualTo(vitalMonitorClass);
    assertThat(mstAddMonitor3.getVitalMonitorItemName()).isEqualTo("サンプル13");
    assertThat(mstAddMonitor3.getIsDisp()).isEqualTo("1");
    assertThat(mstAddMonitor3.getIsDel()).isEqualTo("0");
    assertThat(mstAddMonitor3.getRegDate()).isEqualTo(Timestamp.valueOf("2019-12-26 12:05:03"));
    assertThat(mstAddMonitor3.getUpDate()).isEqualTo(Timestamp.valueOf("2019-12-26 12:05:03"));
    // 4件目
    MstAddMonitor mstAddMonitor4 = result.get(3);
    assertThat(mstAddMonitor4.getVitalMonitorItemCd()).isEqualTo(14L);
    assertThat(mstAddMonitor4.getFacilityCd()).isEqualTo(facilityCd);
    assertThat(mstAddMonitor4.getVitalMonitorClass()).isEqualTo(vitalMonitorClass);
    assertThat(mstAddMonitor4.getVitalMonitorItemName()).isEqualTo("サンプル14");
    assertThat(mstAddMonitor4.getIsDisp()).isEqualTo("1");
    assertThat(mstAddMonitor4.getIsDel()).isEqualTo("0");
    assertThat(mstAddMonitor4.getRegDate()).isEqualTo(Timestamp.valueOf("2019-12-26 12:05:03"));
    assertThat(mstAddMonitor4.getUpDate()).isEqualTo(Timestamp.valueOf("2019-12-26 12:05:03"));
    // 5件目
    MstAddMonitor mstAddMonitor5 = result.get(4);
    assertThat(mstAddMonitor5.getVitalMonitorItemCd()).isEqualTo(15L);
    assertThat(mstAddMonitor5.getFacilityCd()).isEqualTo(facilityCd);
    assertThat(mstAddMonitor5.getVitalMonitorClass()).isEqualTo(vitalMonitorClass);
    assertThat(mstAddMonitor5.getVitalMonitorItemName()).isEqualTo("サンプル15");
    assertThat(mstAddMonitor5.getIsDisp()).isEqualTo("1");
    assertThat(mstAddMonitor5.getIsDel()).isEqualTo("0");
    assertThat(mstAddMonitor5.getRegDate()).isEqualTo(Timestamp.valueOf("2019-12-26 12:05:03"));
    assertThat(mstAddMonitor5.getUpDate()).isEqualTo(Timestamp.valueOf("2019-12-26 12:05:03"));
  }

  /**
   * selectByVitalMonitorClassの検証.
   *
   * 条件：データが存在しない施設コード及びバイタル・モニタ区分を指定
   * 結果：空のリストが取得出来る事
   */
  @Test
  public void test_selectByVitalMonitorClass_正常_該当データなし() {
    // テスト対象のバイタル・モニタ区分
    final String vitalMonitorClass = "1";
    // テスト対象の施設コード
    final String facilityCd = "9999";
    // 実行
    final List<MstAddMonitor> result = target.selectByVitalMonitorClass(facilityCd, vitalMonitorClass);
    // 検証
    assertTrue(result.isEmpty());
  }
}
