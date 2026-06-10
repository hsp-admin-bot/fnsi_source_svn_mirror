package jp.co.nikkiso.ntss.admin_web.service.treatmentRecord;

import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.TreatmentRecordDao;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordResultMerge;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.test.context.junit4.SpringRunner;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.samePropertyValuesAs;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.times;
import static org.mockito.BDDMockito.verify;

/**
 * TreatmentRecordResultMergeServiceImplのテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
public class TreatmentRecordResultMergeServiceImplTest {

  /**
   * テスト対象クラス.
   */
  @Autowired
  private TreatmentRecordResultMergeService target;

  /**
   * 治療情報のMockBean.
   */
  @MockBean
  private TreatmentRecordDao treatmentRecordDao;

  /**
   * 患者基本情報のMoclBean.
   */
  @MockBean
  private PatPersonalMainDao patPersonalMainDao;

  /**
   * 例外の発生をテストするためのルール.
   */
  @Rule
  public ExpectedException expectedException = ExpectedException.none();

  /**
   * getResultMergeList()の検証.
   *
   * 条件：指定されたオーダ番号に該当する治療記録（実績マージ情報）が存在する
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_getResultMergeList_正常_取得() {
    // 事前準備
    Long ordNo = 10L;
    List<TreatmentRecordResultMerge> resultMerges = Arrays.asList(
      getResultMergeDummyData(1L, 1L, null, "テスト患者1"),
      getResultMergeDummyData(2L, 1L, null, "テスト患者1"),
      getResultMergeDummyData(3L, 2L, null, null)
    );
    List<Long> patIds = resultMerges.stream().map(r -> r.getPatId()).distinct().collect(Collectors.toList());
    String facilityCd = "000001";
    List<PatPersonalMain> patPersonals = Arrays.asList(
      new PatPersonalMain() {
        {
          setPat_id(1L);
          setHosp_pat_id("000000000001");
          setPat_last_name("テスト");
          setPat_first_name("患者");
        }
      }
    );
    List<TreatmentRecordResultMerge> expected = Arrays.asList(
      getResultMergeDummyData(1L, 1L, "000000000001", "テスト 患者"),
      getResultMergeDummyData(2L, 1L, "000000000001", "テスト 患者"),
      getResultMergeDummyData(3L, 2L, null, null)
    );

    // Mock化
    given(treatmentRecordDao.selectTreatmentRecordResultMergeByOrdNo(ordNo)).willReturn(resultMerges);
    given(patPersonalMainDao.selectByIdListFacilityCd(patIds, facilityCd)).willReturn(patPersonals);

    // 実行
    List<TreatmentRecordResultMerge> result = target.getResultMergeList(ordNo, facilityCd);

    // 検証
    verify(treatmentRecordDao, times(1)).selectTreatmentRecordResultMergeByOrdNo(ordNo);
    assertThat(result, hasSize(3));
    assertThat(result.get(0), is(samePropertyValuesAs(expected.get(0))));
    assertThat(result.get(1), is(samePropertyValuesAs(expected.get(1))));
    assertThat(result.get(2), is(samePropertyValuesAs(expected.get(2))));
  }

  /**
   * getResultMergeList()の検証.
   *
   * 条件：指定されたオーダ番号に該当する治療記録（実績マージ情報）が存在しない
   * 結果：NotExistExceptionがThrowされること
   */
  @Test
  public void test_getResultMergeList_異常_該当データなし() {
    // 事前準備
    Long ordNo = 12L;
    String facilityCd = "000001";

    // Mock化
    given(treatmentRecordDao.selectTreatmentRecordResultMergeByOrdNo(ordNo)).willThrow(EmptyResultDataAccessException.class);

    // 実行
    // 検証
    expectedException.expect(NotExistException.class);
    expectedException.expectMessage("");
    target.getResultMergeList(ordNo, facilityCd);
  }

  /**
   * updateResultMerge()の検証.
   *
   * 条件：治療記録に存在するOrdNoをもつレコードを指定する
   * 結果：治療記録（実績マージ）の更新ができること
   */
  @Test
  public void test_updateResultMerge_成功_実績マージ情報の更新ができること() {
    // 事前準備
    final Long ordNo = 10L;
    final TreatmentRecordResultMerge beUpdatedTreatmentRecordResultMerge = getResultMergeDummyData(1L, 1L, "000000000001", "テスト患者1");
    beUpdatedTreatmentRecordResultMerge.setRstInputClass(2);
    beUpdatedTreatmentRecordResultMerge.setRstDialysisState("3");
    beUpdatedTreatmentRecordResultMerge.setRstTreatmentName("4");
    beUpdatedTreatmentRecordResultMerge.setRstKurCd(5L);
    beUpdatedTreatmentRecordResultMerge.setRstKurName("6");
    beUpdatedTreatmentRecordResultMerge.setRstBedCd(7L);
    beUpdatedTreatmentRecordResultMerge.setRstBedName("8");
    beUpdatedTreatmentRecordResultMerge.setRstMachineName("9");
    beUpdatedTreatmentRecordResultMerge.setRstCondSendDate(Timestamp.valueOf("2019-06-02 12:01:00"));
    beUpdatedTreatmentRecordResultMerge.setRstAcceptDate(Timestamp.valueOf("2019-06-03 12:01:00"));
    beUpdatedTreatmentRecordResultMerge.setRstStartDate(Timestamp.valueOf("2019-06-04 12:01:00"));
    beUpdatedTreatmentRecordResultMerge.setRstEndDate(Timestamp.valueOf("2019-06-05 12:01:00"));
    beUpdatedTreatmentRecordResultMerge.setRstReturnHomeDate(Timestamp.valueOf("2019-06-06 12:01:00"));
    beUpdatedTreatmentRecordResultMerge.setRstInOutClass(10);
    beUpdatedTreatmentRecordResultMerge.setRstDialysisCnt(11);
    beUpdatedTreatmentRecordResultMerge.setRstWardCd(12);
    beUpdatedTreatmentRecordResultMerge.setRstWardName("13");
    beUpdatedTreatmentRecordResultMerge.setRstCourseCd(14);
    beUpdatedTreatmentRecordResultMerge.setRstCourseName("15");
    beUpdatedTreatmentRecordResultMerge.setRstDw(BigDecimal.valueOf(16.0));
    beUpdatedTreatmentRecordResultMerge.setRstPunctureUserInfo("{\"value\": \"17\"}");
    beUpdatedTreatmentRecordResultMerge.setRstReturnUserInfo("{\"value\": \"18\"}");
    beUpdatedTreatmentRecordResultMerge.setRstChargeUserInfo("{\"value\": \"19\"}");
    beUpdatedTreatmentRecordResultMerge.setRstBloodCirculateTotal(BigDecimal.valueOf(20.0));
    beUpdatedTreatmentRecordResultMerge.setRstRunningTime(21);
    beUpdatedTreatmentRecordResultMerge.setRstKtV(BigDecimal.valueOf(22.0));
    beUpdatedTreatmentRecordResultMerge.setRecSetDate(Timestamp.valueOf("2019-06-07 12:01:00"));
    beUpdatedTreatmentRecordResultMerge.setSendCtlNo(23L);
    beUpdatedTreatmentRecordResultMerge.setBloodPurifierName("24");
    beUpdatedTreatmentRecordResultMerge.setPullLeaveAmount(BigDecimal.valueOf(25.0));
    beUpdatedTreatmentRecordResultMerge.setRstCondInfo("{\"value\": \"26\"}");
    beUpdatedTreatmentRecordResultMerge.setRstMediInfo("{\"value\": \"27\"}");
    beUpdatedTreatmentRecordResultMerge.setRstEquipInfo("{\"value\": \"28\"}");
    beUpdatedTreatmentRecordResultMerge.setRstIndCommentInfo("{\"value\": \"29\"}");
    beUpdatedTreatmentRecordResultMerge.setRstTareInfo("{\"value\": \"30\"}");
    beUpdatedTreatmentRecordResultMerge.setRstOffWaterInfo("{\"value\": \"31\"}");
//    beUpdatedTreatmentRecordResultMerge.setRstDeviceSetInfo("{\"value\": \"32\"}");// del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正
    beUpdatedTreatmentRecordResultMerge.setWeightScaleNo(33L);
    beUpdatedTreatmentRecordResultMerge.setRstWeightInfo("{\"value\": \"34\"}");
//    beUpdatedTreatmentRecordResultMerge.setRstVitalInfo("{\"value\": \"35\"}");
    beUpdatedTreatmentRecordResultMerge.setRstComplaintInfo("{\"value\": \"36\"}");
    beUpdatedTreatmentRecordResultMerge.setRstTreatmentInfo("{\"value\": \"37\"}");
    beUpdatedTreatmentRecordResultMerge.setRstTreatStaffInfo("{\"value\": \"38\"}");
    beUpdatedTreatmentRecordResultMerge.setRstRoundsInfo("{\"value\": \"39\"}");

    final ArgumentCaptor<Long> ordNoCaptor = ArgumentCaptor.forClass(Long.class);
    final ArgumentCaptor<TreatmentRecordResultMerge> updateCaptor = ArgumentCaptor.forClass(TreatmentRecordResultMerge.class);
    given(treatmentRecordDao.updateTreatmentRecordForResultMerge(ordNoCaptor.capture(), updateCaptor.capture())).willReturn(1);

    // 実行
    target.updateResultMerge(ordNo, beUpdatedTreatmentRecordResultMerge);

    // 検証
    final Long updatedOrdNo = ordNoCaptor.getValue();
    assertThat(updatedOrdNo, is(10L));
    final TreatmentRecordResultMerge updatedTreatmentRecordResultMerge = updateCaptor.getValue();
    assertThat(updatedTreatmentRecordResultMerge, is(beUpdatedTreatmentRecordResultMerge));
  }

  /**
   * updateResultMerge()の検証.
   *
   * 条件：治療記録に存在しないOrdNoをもつレコードを指定する
   * 結果：NotExistExceptionがThrowされること
   */
  @Test
  public void test_updateResultMerge_失敗_コードに一致する治療記録がない場合は例外が発生すること() {
    // arrange
    final Long ordNo = 12L;
    final TreatmentRecordResultMerge beUpdatedTreatmentRecordResultMerge = getResultMergeDummyData(1L, 1L, "000000000001", "テスト患者1");
    beUpdatedTreatmentRecordResultMerge.setRstInputClass(2);

    final ArgumentCaptor<Long> ordNoCaptor = ArgumentCaptor.forClass(Long.class);
    final ArgumentCaptor<TreatmentRecordResultMerge> updateCaptor = ArgumentCaptor.forClass(TreatmentRecordResultMerge.class);
    given(treatmentRecordDao.updateTreatmentRecordForResultMerge(ordNoCaptor.capture(), updateCaptor.capture())).willReturn(0);

    // 実行
    // 検証
    expectedException.expect(NotExistException.class);
    expectedException.expectMessage("存在しない治療情報のオーダ番号を指定されています。");
    target.updateResultMerge(ordNo, beUpdatedTreatmentRecordResultMerge);
    final Long updatedOrdNo = ordNoCaptor.getValue();
    assertThat(updatedOrdNo, is(12L));
    final TreatmentRecordResultMerge updatedTreatmentRecordResultMerge = updateCaptor.getValue();
    assertThat(updatedTreatmentRecordResultMerge, is(beUpdatedTreatmentRecordResultMerge));
  }

  /**
   * データ準備（実績マージ情報）.
   */
  private TreatmentRecordResultMerge getResultMergeDummyData(Long ordNo, Long patId, String hospPatId, String patName) {
    TreatmentRecordResultMerge dummyData = new TreatmentRecordResultMerge();
    dummyData.setOrdNo(ordNo);
    dummyData.setPatId(patId);
    dummyData.setHospPatId(hospPatId);
    dummyData.setPatName(patName);
    dummyData.setRstInputClass(1);
    dummyData.setRstDialysisState("2");
    dummyData.setRstTreatmentName("3");
    dummyData.setRstKurCd(4L);
    dummyData.setRstKurName("5");
    dummyData.setRstBedCd(6L);
    dummyData.setRstBedName("7");
    dummyData.setRstMachineName("8");
    dummyData.setRstCondSendDate(Timestamp.valueOf("2019-06-01 12:01:00"));
    dummyData.setRstAcceptDate(Timestamp.valueOf("2019-06-02 12:01:00"));
    dummyData.setRstStartDate(Timestamp.valueOf("2019-06-03 12:01:00"));
    dummyData.setRstEndDate(Timestamp.valueOf("2019-06-04 12:01:00"));
    dummyData.setRstReturnHomeDate(Timestamp.valueOf("2019-06-05 12:01:00"));
    dummyData.setRstInOutClass(9);
    dummyData.setRstDialysisCnt(10);
    dummyData.setRstWardCd(11);
    dummyData.setRstWardName("12");
    dummyData.setRstCourseCd(13);
    dummyData.setRstCourseName("14");
    dummyData.setRstDw(BigDecimal.valueOf(15.0));
    dummyData.setRstPunctureUserInfo("{\"value\": \"16\"}");
    dummyData.setRstReturnUserInfo("{\"value\": \"17\"}");
    dummyData.setRstChargeUserInfo("{\"value\": \"18\"}");
    dummyData.setRstBloodCirculateTotal(BigDecimal.valueOf(19.0));
    dummyData.setRstRunningTime(20);
    dummyData.setRstKtV(BigDecimal.valueOf(21.0));
    dummyData.setRecSetDate(Timestamp.valueOf("2019-06-06 12:01:00"));
    dummyData.setSendCtlNo(22L);
    dummyData.setBloodPurifierName("23");
    dummyData.setPullLeaveAmount(BigDecimal.valueOf(24.0));
    dummyData.setRstCondInfo("{\"value\": \"25\"}");
    dummyData.setRstMediInfo("{\"value\": \"26\"}");
    dummyData.setRstEquipInfo("{\"value\": \"27\"}");
    dummyData.setRstIndCommentInfo("{\"value\": \"28\"}");
    dummyData.setRstTareInfo("{\"value\": \"29\"}");
    dummyData.setRstOffWaterInfo("{\"value\": \"30\"}");
//    dummyData.setRstDeviceSetInfo("{\"value\": \"31\"}");// del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正
    dummyData.setWeightScaleNo(32L);
    dummyData.setRstWeightInfo("{\"value\": \"33\"}");
//    dummyData.setRstVitalInfo("{\"value\": \"34\"}");
    dummyData.setRstComplaintInfo("{\"value\": \"35\"}");
    dummyData.setRstTreatmentInfo("{\"value\": \"36\"}");
    dummyData.setRstTreatStaffInfo("{\"value\": \"37\"}");
    dummyData.setRstRoundsInfo("{\"value\": \"38\"}");
    return dummyData;
  }

}
