package jp.co.nikkiso.ntss.core.dao;


import jp.co.nikkiso.ntss.core.entity.custom.Machine;
import jp.co.nikkiso.ntss.core.entity.custom.NoticeCounts;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.MatcherAssert.assertThat;
import static org.junit.Assert.assertNull;

/**
 * {@link MntMachineStateDao} のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:dao.script/MntMachineStateDaoTest.before.sql")
public class MntMachineStateDaoTest {

  /**
   * テスト対象Dao.
   */
  @Autowired
  private MntMachineStateDao target;

  /**
   * selectMachinesByFacilityCd()の検証.
   * 条件：該当データなし
   */
  @Test
  public void test_selectMachinesByFacilityCd_該当データなし() {

    // 実行
    List<Machine> result = target.selectMachinesByFacilityCd("empty");

    // 検証
    assertThat(result.size(), is(0));

  }

  /**
   * selectMachinesByFacilityCd()の検証.
   * 条件；該当データ1件
   */
  @Test
  public void test_selectMachinesByFacilityCd_該当データ1件() {

    // 実行
    List<Machine> result = target.selectMachinesByFacilityCd("900002");

    // 検証
    assertThat(result.size(), is(1));
    Machine machine = result.get(0);
    assertThat(machine.getFacilityName(), is("テスト病院"));
    assertThat(machine.getFacilityCd(), is("900002"));
    assertThat(machine.getMachineTypeCd(), is("901"));
    assertThat(machine.getMachineSerial(), is("90000001"));
    assertThat(machine.getModel(), is("008"));
    assertThat(machine.getMachineName(), is("テスト装置1"));
    assertThat(machine.getBedName(), is("テストベッド1"));
    assertThat(machine.getProcessState(), is("01"));
    assertThat(machine.getMNoticeCnt(), is(0));
    assertThat(machine.getPreventiveMainteCnt(), is(0));
    assertThat(machine.getIsPreventiveMainte(), is(0));
    assertThat(machine.getServiceSupportCnt(), is(2));
    assertThat(machine.getComFormatCd(), is("A"));
    assertThat(machine.getComType(), is(1));
    assertThat(machine.getDeviceEdgeNo(), is(10));
    assertThat(machine.getIsFtp(), is("0"));
    assertThat(machine.getVersion(), is("1"));

  }

  /**
   * selectMachinesByFacilityCd()の検証.
   * 条件：該当データ複数
   */
  @Test
  public void test_selectMachineByFacilityCd_該当データ複数() {

    // 実行
    List<Machine> result = target.selectMachinesByFacilityCd("900004");

    // 検証
    assertThat(result.size(), is(2));
    assertThat(result.get(0).getFacilityCd(), is("900004"));
    assertThat(result.get(0).getMachineSerial(), is("90000041"));
    assertThat(result.get(0).getComFormatCd(), is("A"));
    assertThat(result.get(0).getIsFtp(), is("0"));
    assertThat(result.get(0).getServiceSupportCnt(), is(4));
    assertThat(result.get(0).getVersion(), is("1"));
    assertThat(result.get(1).getFacilityCd(), is("900004"));
    assertThat(result.get(1).getMachineSerial(), is("90000042"));
    assertThat(result.get(1).getComFormatCd(), is("R"));
    assertThat(result.get(1).getIsFtp(), is("1"));
    assertThat(result.get(1).getServiceSupportCnt(), is(5));
    assertThat(result.get(1).getVersion(), is("1"));


  }

  /**
   * selectMachinesByFacilityCd()の検証.
   * 条件：件数の列がnull
   * 結果：ゼロとして取得できること
   */
  @Test
  public void test_selectMachineByFacilityCd_件数nullはゼロ扱い() {

    // 実行
    List<Machine> result = target.selectMachinesByFacilityCd("900005");

    // 検証
    assertThat(result.size(), is(3));
    assertThat(result.get(0).getFacilityCd(), is("900005"));
    assertThat(result.get(0).getMNoticeCnt(), is(0));
    assertThat(result.get(0).getPreventiveMainteCnt(), is(0));
    assertThat(result.get(0).getServiceSupportCnt(), is(0));
    assertThat(result.get(1).getFacilityCd(), is("900005"));
    assertThat(result.get(1).getMNoticeCnt(), is(0));
    assertThat(result.get(1).getPreventiveMainteCnt(), is(1));
    assertThat(result.get(1).getServiceSupportCnt(), is(1));
    assertThat(result.get(2).getFacilityCd(), is("900005"));
    assertThat(result.get(2).getMNoticeCnt(), is(2));
    assertThat(result.get(2).getPreventiveMainteCnt(), is(0));
    assertThat(result.get(2).getServiceSupportCnt(), is(0));
  }

  /**
   * {@link MntMachineStateDao#selectNoticeCounts(String)} の検証.
   *
   * <p>
   *   条件:対象データが存在する事.
   *   結果:データが取得出来る事.
   * </p>
   */
  @Test
  public void test_selectNoticeCounts_正常() {
    // 事前準備
    String facilityCd = "900001";

    // 実行
    NoticeCounts result = target.selectNoticeCounts(facilityCd);

    // 検証
    assertThat(result.getMNoticeCnt(), is(0));
    assertThat(result.getComProblemCnt(), is(0));
    assertThat(result.getPreventiveCnt(), is(0));
    assertThat(result.getServiceSupportCnt(), is(2));
  }

  /**
   * {@link MntMachineStateDao#selectNoticeCounts(String)} の検証.
   *
   * <p>
   *   条件:対象データが存在しない事.
   *   結果:nullが返却される事.
   * </p>
   */
  @Test
  public void test_selectNoticeCounts_異常_データが存在しない場合() {
    // 事前準備
    String facilityCd = "test";

    // 実行
    NoticeCounts result = target.selectNoticeCounts(facilityCd);

    // 検証
    assertNull(result);
  }

  /**
   * {@link MntMachineStateDao#selectNoticeCounts(String)} の検証.
   *
   * <p>
   *   条件:対象データの件数に<code>null</code>が存在しない事.
   *   結果:ゼロ扱いで返却される事.
   * </p>
   */
  @Test
  public void test_selectNoticeCounts_異常_データにnull存在する場合() {
    // 事前準備
    String facilityCd = "900005";

    // 実行
    NoticeCounts result = target.selectNoticeCounts(facilityCd);

    // 検証
    assertThat(result.getMNoticeCnt(), is(1));
    assertThat(result.getComProblemCnt(), is(3));
    assertThat(result.getPreventiveCnt(), is(1));
    assertThat(result.getServiceSupportCnt(), is(1));
  }
}
