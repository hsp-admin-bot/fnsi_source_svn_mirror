package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.MntMotionRecord;
import jp.co.nikkiso.ntss.core.entity.custom.GatheringDetail;
import jp.co.nikkiso.ntss.core.entity.custom.MNoticeDetail;
import jp.co.nikkiso.ntss.core.entity.custom.MotionRecord;
import jp.co.nikkiso.ntss.core.entity.custom.PreventiveDetail;
import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.MethodSorters;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Timestamp;
import java.util.List;

import static org.hamcrest.CoreMatchers.equalTo;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertThat;

/**
 * {@link MntMotionRecordDao } のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:dao.script/MntMotionRecordDaoTest.before.sql")
@FixMethodOrder(MethodSorters.JVM)
public class MntMotionRecordDaoTest {

  /**
   * テスト対象Dao.
   */
  @Autowired
  private MntMotionRecordDao target;

  /**
   * selectEventRegDate()の検証.
   * 条件: 取得結果0件
   */
  @Test
  public void test_selectEventRegDate_該当データなし() {

    // 実行
    List<String> result = target.selectEventRegDates("00000000", "900001", "901", "90000001");
    // 検証
    assertThat(result.size(), equalTo(0));

  }

  /**
   * selectEventRegDate()の検証.
   * 条件: 取得結果1件(基準日と一致)
   */
  @Test
  public void test_selectEventRegDate_取得結果1件() {

    // 実行
    List<String> result = target.selectEventRegDates("19800101", "900001", "901", "90000001");
    // 検証
    assertThat(result.size(), equalTo(1));
    assertThat(result.get(0), is("19800101"));

  }

  /**
   * selectEventRegDate()の検証.
   * 条件: 取得結果複数(基準日以前のものすべて)
   */
  @Test
  public void test_selectEventRegDate_取得結果複数() {

    // 実行
    List<String> result = target.selectEventRegDates("19801110", "900001", "901", "90000001");
    // 検証
    assertThat(result.size(), equalTo(10));
    assertThat(result.get(0), is("19801109"));
    assertThat(result.get(1), is("19801108"));
    assertThat(result.get(2), is("19801107"));
    assertThat(result.get(3), is("19801106"));
    assertThat(result.get(4), is("19801105"));
    assertThat(result.get(5), is("19801104"));
    assertThat(result.get(6), is("19801103"));
    assertThat(result.get(7), is("19801102"));
    assertThat(result.get(8), is("19801101"));
    assertThat(result.get(9), is("19800101"));

  }

  /**
   * selectByMachinesInfo()の検証.
   * 条件: 取得結果0件 (該当する施設コードなし)
   */
  @Test
  public void test_selectMachinesInfo_該当データなし_該当施設コードなし() {

    // 実行
    List<MotionRecord> motionRecords = target.selectByMachinesInfo("999999", "901", "90000001", "19800101", "19801231");
    // 検証
    assertThat(motionRecords.size(), equalTo(0));

  }

  /**
   * selectByMachinesInfo()の検証.
   * 条件: 取得結果0件 (該当する型式コードなし)
   */
  @Test
  public void test_selectMachinesInfo_該当データなし_該当型式コードなし() {

    // 実行
    List<MotionRecord> motionRecords = target.selectByMachinesInfo("900001", "999", "90000001", "19800101", "19801231");
    // 検証
    assertThat(motionRecords.size(), equalTo(0));

  }

  /**
   * selectByMachinesInfo()の検証.
   * 条件: 取得結果0件 (該当する製造番号なし)
   */
  @Test
  public void test_selectMachinesInfo_該当データなし_該当製造番号なし() {

    // 実行
    List<MotionRecord> motionRecords = target.selectByMachinesInfo("900001", "901", "99999999", "19800101", "19801231");
    // 検証
    assertThat(motionRecords.size(), equalTo(0));

  }

  /**
   * selectByMachinesInfo()の検証.
   * 条件: 取得結果0件 (該当する期間なし)
   */
  @Test
  public void test_selectMachinesInfo_該当データなし_該当期間なし() {

    // 実行
    List<MotionRecord> motionRecords = target.selectByMachinesInfo("900001", "901", "90000001", "20200101", "20201231");
    // 検証
    assertThat(motionRecords.size(), equalTo(0));

  }

  /**
   * selectByMachinesInfo()の検証.
   * 条件: 取得結果1件 (該当するデータ収集管理(mnt_gathering_manage)なし)
   */
  @Test
  public void test_selectByMachinesInfo_取得結果1件_該当データ収集管理なし() {

    // 実行
    List<MotionRecord> results = target.selectByMachinesInfo("900001", "901", "90000001", "19801001", "19801101");
    // 検証
    assertThat(results.size(), equalTo(1));
    assertThat(results.get(0), notNullValue());
    assertThat(results.get(0).getMotionRecordNo(), is(13L));
    assertThat(results.get(0).getEventRegDate(), is("1980/11/01"));
    assertThat(results.get(0).getEventRegTime(), is("00:00:00"));
    assertThat(results.get(0).getDataType(), is(1));
    assertThat(results.get(0).getTestType(), nullValue());
    assertThat(results.get(0).getMachineRecordMessage(), is("message0000000013"));
    assertThat(results.get(0).getIsCorrection(), is("1"));
    assertThat(results.get(0).getUserId(), is(3L));
    assertThat(results.get(0).getUserName(), nullValue());
    assertThat(results.get(0).getGatheringStatus(), nullValue());
  }

  /**
   * selectByMachinesInfo()の検証.
   * 条件: 取得結果1件 (該当するデータ収集管理(mnt_gathering_manage)あり)
   */
  @Test
  public void test_selectByMachinesInfo_取得結果1件_該当データ収集管理あり() {

    // 実行
    List<MotionRecord> results = target.selectByMachinesInfo("900002", "902", "90000002", "20141220", "20141230");
    // 検証
    assertThat(results.size(), equalTo(1));
    assertThat(results.get(0), notNullValue());
    assertThat(results.get(0).getMotionRecordNo(), is(91L));
    assertThat(results.get(0).getEventRegDate(), is("2014/12/30"));
    assertThat(results.get(0).getEventRegTime(), is("14:44:43"));
    assertThat(results.get(0).getDataType(), is(3));
    assertThat(results.get(0).getTestType(), nullValue());
    assertThat(results.get(0).getMachineRecordMessage(), is("message0000000091"));
    assertThat(results.get(0).getIsCorrection(), is("1"));
    assertThat(results.get(0).getUserId(), is(2L));
    assertThat(results.get(0).getUserName(), nullValue());
    assertThat(results.get(0).getGatheringStatus(), is(0));
  }

  /**
   * selectByMachinesInfo()の検証.
   * 条件: 取得結果複数 (並び順は、 発生日付の降順)
   */
  @Test
  public void test_selectByMachinesInfo_取得結果複数() {

    // 実行
    List<MotionRecord> results = target.selectByMachinesInfo("900002", "902", "90000002", "20141231", "20150110");
    // 検証
    assertThat(results.size(), equalTo(3));

    assertThat(results.get(0), notNullValue());
    assertThat(results.get(0).getMotionRecordNo(), is(94L));
    assertThat(results.get(0).getEventRegDate(), is("2015/01/01"));
    assertThat(results.get(0).getEventRegTime(), is("00:00:01"));
    assertThat(results.get(0).getDataType(), is(4));
    assertThat(results.get(0).getTestType(), is(1));
    assertThat(results.get(0).getMachineRecordMessage(), is("message0000000094"));
    assertThat(results.get(0).getIsCorrection(), is("0"));
    assertThat(results.get(0).getUserId(), is(5L));
    assertThat(results.get(0).getUserName(), nullValue());
    assertThat(results.get(0).getGatheringStatus(), is(2));

    assertThat(results.get(1), notNullValue());
    assertThat(results.get(1).getMotionRecordNo(), is(93L));
    assertThat(results.get(1).getEventRegDate(), is("2015/01/01"));
    assertThat(results.get(1).getEventRegTime(), is("00:00:00"));
    assertThat(results.get(1).getDataType(), is(6));
    assertThat(results.get(1).getTestType(), nullValue());
    assertThat(results.get(1).getMachineRecordMessage(), is("message0000000093"));
    assertThat(results.get(1).getIsCorrection(), is("1"));
    assertThat(results.get(1).getUserId(), is(4L));
    assertThat(results.get(1).getUserName(), nullValue());
    assertThat(results.get(1).getGatheringStatus(), nullValue());

    assertThat(results.get(2), notNullValue());
    assertThat(results.get(2).getMotionRecordNo(), is(92L));
    assertThat(results.get(2).getEventRegDate(), is("2014/12/31"));
    assertThat(results.get(2).getEventRegTime(), is("23:59:59"));
    assertThat(results.get(2).getDataType(), is(5));
    assertThat(results.get(2).getTestType(), nullValue());
    assertThat(results.get(2).getMachineRecordMessage(), is("message0000000092"));
    assertThat(results.get(2).getIsCorrection(), is("0"));
    assertThat(results.get(2).getUserId(), is(3L));
    assertThat(results.get(2).getUserName(), nullValue());
    assertThat(results.get(2).getGatheringStatus(), is(1));
  }

  /**
   * selectGatheringDetail()の検証.
   * 条件: 取得結果0件
   */
  @Test
  public void test_selectGatheringDetail_該当データなし() {
    // 実行
    GatheringDetail result = target.selectGatheringDetail(-1L);
    // 検証
    assertThat(result, nullValue());
  }

  /**
   * selectGatheringDetail()の検証.
   * 条件: 取得結果1件
   */
  @Test
  public void test_selectGatheringDetail_取得結果1件() {
    // 実行
    GatheringDetail result = target.selectGatheringDetail(4L);
    // 検証
    assertThat(result, notNullValue());
    assertThat(result.getMachineRecordMessage(), is("message0000000004"));
    assertThat(result.getGatheredUserId(), is(4L));
    assertThat(result.getUserName(), nullValue());
    assertThat(result.getFileData(), is("{\"key\": \"value\"}"));
  }

  /**
   * selectMNoticeDetail()の検証.
   * 条件: 取得結果0件
   */
  @Test
  public void test_selectMNoticeDetail_該当データなし() {
    // 実行
    MNoticeDetail result = target.selectMNoticeDetail(-1L);
    // 検証
    assertThat(result, nullValue());
  }

  /**
   * selectMNoticeDetail()の検証.
   * 条件: 取得結果1件
   */
  @Test
  public void test_selectMNoticeDetail_取得結果1件() {
    // 実行
    MNoticeDetail result = target.selectMNoticeDetail(10L);
    // 検証
    assertThat(result, notNullValue());
    assertThat(result.getMachineRecordCd(), is("0010"));
    assertThat(result.getDetailInfo(), is("AUX0010"));
    assertThat(result.getDestinationName(), is("9010"));
    assertThat(result.getEmailText(), is("メール本文0010"));
    assertThat(result.getCorrectedUserId(), is(5L));
    assertThat(result.getUserName(), nullValue());
    assertThat(result.getIsCorrection(), is("0"));
  }

  /**
   * selectPreventiveDetail()の検証.
   * 条件: 取得結果0件 (指定されたMotionRecordNoに該当するレコードなし)
   * ※パターン "該当するMotionRecordが持つuser_idに該当するmst_userなし"は、外部キー制約によりありえない。
   */
  @Test
  public void test_selectPreventiveDetail_該当データなし() {
    // 実行
    PreventiveDetail result = target.selectPreventiveDetail(-1L);
    // 検証
    assertThat(result, nullValue());
  }

  /**
   * selectPreventiveDetail()の検証.
   * 条件: 取得結果1件
   */
  @Test
  public void test_selectPreventiveDetail_取得結果1件() {
    // 実行
    PreventiveDetail result = target.selectPreventiveDetail(16L);
    // 検証
    assertThat(result, notNullValue());
    assertThat(result.getMachineRecordCd(), is("0016"));
    assertThat(result.getDetailInfo(), is("AUX0016"));
    assertThat(result.getCorrectedUserId(), is(1L));
    assertThat(result.getUserName(), nullValue());
    assertThat(result.getIsCorrection(), is("0"));
  }

  /**
   * {@link MntMotionRecordDao#updateServiceSupport(MntMotionRecord)}の検証.
   * <p>
   *   条件:なし.
   *   結果:正常に更新される事.
   * </p>
   */
  @Test
  public void test_updateServiceSupport_正常_更新データが存在する場合() {
    // 事前準備
    Long motionRecordNo = 100L;
    Long userId = 1L;
    String serviceType = "1";
    MntMotionRecord mntMotionRecord = new MntMotionRecord();
    mntMotionRecord.setMotionRecordNo(motionRecordNo);
    mntMotionRecord.setServiceSupportUserId(userId);
    mntMotionRecord.setServiceSupportType(serviceType);

    // 更新前のデータ取得
    MntMotionRecord before = target.selectByMotionRecordNo(motionRecordNo);
    // 実行
    int result = target.updateServiceSupport(mntMotionRecord);
    // 更新後のデータ取得
    MntMotionRecord after = target.selectByMotionRecordNo(motionRecordNo);

    // 検証
    assertThat(result, is(1));
    assertThat(after.getMotionRecordNo(), is(before.getMotionRecordNo()));
    assertThat(after.getServiceSupportType(), is(serviceType));
    assertThat(after.getServiceSupportUserId(), is(userId));
    assertNotNull(after.getServiceSupportUpDate());
  }

  /**
   * {@link MntMotionRecordDao#updateServiceSupport(MntMotionRecord)}の検証.
   * <p>
   *   条件:更新データが存在しない事.
   *   結果:例外が発生せず、更新されない事.
   * </p>
   */
  @Test
  public void test_updateServiceSupport_異常_更新データが存在しない場合() {
    // 事前準備
    Long motionRecordNo = 1000L;
    Long userId = 1L;
    String serviceType = "1";
    MntMotionRecord mntMotionRecord = new MntMotionRecord();
    mntMotionRecord.setMotionRecordNo(motionRecordNo);
    mntMotionRecord.setServiceSupportUserId(userId);
    mntMotionRecord.setServiceSupportType(serviceType);

    // 更新前のデータ取得
    MntMotionRecord before = target.selectByMotionRecordNo(motionRecordNo);
    // 実行
    int result = target.updateServiceSupport(mntMotionRecord);
    // 更新後のデータ取得
    MntMotionRecord after = target.selectByMotionRecordNo(motionRecordNo);

    // 検証
    assertNull(before);
    assertThat(result, is(0));
    assertNull(after);
  }

  /**
   * {link {@link MntMotionRecordDao#updateServiceSupportAll(MntMotionRecord)} の検証.
   * <p>
   *   条件:なし
   *   結果:正常にデータが更新される事.
   * </p>
   */
  @Test
  public void test_updateServiceSupportAll_正常() {
    // 事前準備
    String facilityCd = "900001";
    String machineTypeCd = "904";
    String machineSerial = "90000004";
    Long userId = 2L;

    MntMotionRecord mntMotionRecord = new MntMotionRecord();
    mntMotionRecord.setFacilityCd(facilityCd);
    mntMotionRecord.setMachineTypeCd(machineTypeCd);
    mntMotionRecord.setMachineSerial(machineSerial);
    mntMotionRecord.setServiceSupportUserId(userId);

    // 実行
    int result = target.updateServiceSupportAll(mntMotionRecord);

    // 検証
    assertThat(result , is(2));
    // 装置動作記録番号：101のチェック
    MntMotionRecord result1 = target.selectByMotionRecordNo(101L);
    assertThat(result1.getServiceSupportType(), is("2"));
    assertThat(result1.getServiceSupportUserId(), is(userId));
    assertNotNull(result1.getServiceSupportUpDate());
    // 装置動作記録番号：102のチェック
    MntMotionRecord result2 = target.selectByMotionRecordNo(102L);
    assertThat(result2.getServiceSupportType(), is("2"));
    assertThat(result2.getServiceSupportUserId(), is(1L));
    assertNotNull(result2.getServiceSupportUpDate());
    // 装置動作記録番号：103のチェック
    MntMotionRecord result3 = target.selectByMotionRecordNo(103L);
    assertThat(result3.getServiceSupportType(), is("2"));
    assertThat(result3.getServiceSupportUserId(), is(userId));
    assertNotNull(result3.getServiceSupportUpDate());
    // 装置動作記録番号：104のチェック
    MntMotionRecord result4 = target.selectByMotionRecordNo(104L);
    assertThat(result4.getServiceSupportType(), is("3"));
    assertThat(result4.getServiceSupportUserId(), is(2L));
    assertNull(result4.getServiceSupportUpDate());
    // 装置動作記録番号：105のチェック
    MntMotionRecord result5 = target.selectByMotionRecordNo(105L);
    assertThat(result5.getServiceSupportType(), is("0"));
    assertNull(result5.getServiceSupportUserId());
    assertNotNull(result5.getServiceSupportUpDate());
    // 装置動作記録番号：106のチェック
    MntMotionRecord result6 = target.selectByMotionRecordNo(106L);
    assertThat(result6.getServiceSupportType(), is("0"));
    assertNull(result6.getServiceSupportUserId());
    assertNotNull(result6.getServiceSupportUpDate());
    // 装置動作記録番号：107のチェック
    MntMotionRecord result7 = target.selectByMotionRecordNo(107L);
    assertThat(result7.getServiceSupportType(), is("0"));
    assertNull(result7.getServiceSupportUserId());
    assertNull(result7.getServiceSupportUpDate());
    // 装置動作記録番号：108のチェック
    MntMotionRecord result8 = target.selectByMotionRecordNo(108L);
    assertThat(result8.getServiceSupportType(), is("0"));
    assertNull(result8.getServiceSupportUserId());
    assertNotNull(result8.getServiceSupportUpDate());
    // 装置動作記録番号：109のチェック
    MntMotionRecord result9 = target.selectByMotionRecordNo(109L);
    assertThat(result9.getServiceSupportType(), is("0"));
    assertNull(result9.getServiceSupportUserId());
    assertNull(result9.getServiceSupportUpDate());
  }

  /**
   * {link {@link MntMotionRecordDao#updateServiceSupportAll(MntMotionRecord)} の検証.
   * <p>
   *   条件:更新データが存在しない事.
   *   結果:例外が発生せず、更新されない事.
   * </p>
   */
  @Test
  public void test_updateServiceSupportAll_異常_更新対象データが存在しない場合() {
    // 事前準備
    String facilityCd = "900009";
    String machineTypeCd = "904";
    String machineSerial = "90000004";
    Long userId = 2L;

    MntMotionRecord mntMotionRecord = new MntMotionRecord();
    mntMotionRecord.setFacilityCd(facilityCd);
    mntMotionRecord.setMachineTypeCd(machineTypeCd);
    mntMotionRecord.setMachineSerial(machineSerial);
    mntMotionRecord.setServiceSupportUserId(userId);

    // 実行
    int result = target.updateServiceSupportAll(mntMotionRecord);

    // 検証
    assertThat(result, is(0));
  }

  /**
   * {@link MntMotionRecordDao#selectMaxEventRegDateByFacilityCd(String, String, String, boolean)}の検証.
   *
   * <p>
   *   条件:該当データが存在する事
   *   結果:最大イベント日時が取得出来る事
   * </p>
   */
  @Test
  public void test_selectMaxEventRegDateByFacilityCd_正常_施設の対象データが存在する場合() {
    // 事前準備
    final String facilityCd = "900002";
    final boolean isNkkFacility = true;

    // 実行
    Timestamp result = target.selectMaxEventRegDateByFacilityCd(facilityCd, null, null, isNkkFacility);

    // 検証
    assertNotNull(result);
    assertThat(result, is(Timestamp.valueOf("2010-01-02 00:00:02")));

  }

  /**
   * {@link MntMotionRecordDao#selectMaxEventRegDateByFacilityCd(String, String, String, boolean)} の検証.
   *
   * <p>
   *   条件:該当データが存在しない事
   *   結果:<code>null</code>が取得出来る事
   * </p>
   */
  @Test
  public void test_selectMaxEventRegDateByFacilityCd_正常_施設の対象データが存在しない場合() {
    // 事前準備
    final String facilityCd = "900003";
    final boolean isNkkFacility = true;

    // 実行
    Timestamp result = target.selectMaxEventRegDateByFacilityCd(facilityCd, null, null, isNkkFacility);

    // 検証
    assertNull(result);
  }

  /**
   * {@link MntMotionRecordDao#selectMaxEventRegDateByFacilityCd(String, String, String, boolean)} の検証
   *
   * <p>
   *   条件:該当データが存在する事
   *   結果:装置の最大イベント日時が取得出来る事
   * </p>
   */
  @Test
  public void test_selectMaxEventRegDateFacilityCd_正常_装置の対象データが存在する場合_日機装施設以外() {
    // 事前準備
    final String facilityCd = "900005";
    final String machineTypeCd = "905";
    final String machineSerial = "90000005";
    final boolean isNkkFacility = false;

    // 実行
    Timestamp result = target.selectMaxEventRegDateByFacilityCd(facilityCd, machineTypeCd, machineSerial, isNkkFacility);

    // 検証
    assertNotNull(result);
    assertThat(result, is(Timestamp.valueOf("2020-06-19 00:00:01")));
  }

  /**
   * {@link MntMotionRecordDao#selectMaxEventRegDateByFacilityCd(String, String, String, boolean)} の検証
   *
   * <p>
   *   条件:該当データが存在しない事
   *   結果:<code>null</code>が取得出来る事
   * </p>
   */
  @Test
  public void test_selectMaxEventRegDateFacilityCd_正常_装置の対象データが存在しない場合_日機装施設以外() {
    // 事前準備
    final String facilityCd = "test";
    final String machineTypeCd = "999";
    final String machineSerial = "test_999";
    final boolean isNkkFacility = false;

    // 実行
    Timestamp result = target.selectMaxEventRegDateByFacilityCd(facilityCd, machineTypeCd, machineSerial, isNkkFacility);

    // 検証
    assertNull(result);
  }
}
