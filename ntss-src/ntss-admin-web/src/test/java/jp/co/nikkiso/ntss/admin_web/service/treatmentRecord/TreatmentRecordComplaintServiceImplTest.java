package jp.co.nikkiso.ntss.admin_web.service.treatmentRecord;

import static org.hamcrest.Matchers.is;
import static org.junit.Assert.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

import java.sql.Timestamp;

import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.test.context.junit4.SpringRunner;

import jp.co.nikkiso.ntss.core.dao.TreatmentRecordComplaintDao;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordComplaint;
import jp.co.nikkiso.ntss.core.exception.NotExistException;

@RunWith(SpringRunner.class)
@SpringBootTest
public class TreatmentRecordComplaintServiceImplTest {

  /**
   * テスト対象クラス
   */
  @Autowired
  private TreatmentRecordComplaintService target;

  /**
   * 治療記録用愁訴処置のDaoインタフェース.
   */
  @MockBean
  private TreatmentRecordComplaintDao complaintDao;

  /**
   * 例外の発生をテストするためのルール
   */
  @Rule
  public ExpectedException expectedException = ExpectedException.none();

  /**
   * getTreatmentRecordComplaint()の検証.
   *
   * 条件：治療記録マスタに存在するOrdNoをもつレコードを指定する
   * 結果：愁訴処置情報を取得できること
   */
  @Test
  public void test_getTreatmentRecordComplaint_成功() {
    // arrange
    final Long ordNo = 1L;

    final Timestamp rstStartDate = Timestamp.valueOf("2019-05-29 13:00:00");
    final Timestamp rstEndDate = Timestamp.valueOf("2019-05-29 18:00:00");
    final String rstComplaintInfo = "[{\"cd\": 11, \"name\": \"name11\"}, {\"cd\": 2, \"name\": \"name2\"}]";
    final String rstTreatmentInfo = "[{\"cd\": 12, \"name\": \"name12\"}, {\"cd\": 2, \"name\": \"name2\"}]";
    final String rstTreatStaffInfo = "[{\"cd\": 13, \"name\": \"name13\"}, {\"cd\": 2, \"name\": \"name2\"}]";

    TreatmentRecordComplaint complaint = new TreatmentRecordComplaint();
    complaint.setRstStartDate(rstStartDate);
    complaint.setRstEndDate(rstEndDate);
    complaint.setRstComplaintInfo(rstComplaintInfo);
    complaint.setRstTreatmentInfo(rstTreatmentInfo);
    complaint.setRstTreatStaffInfo(rstTreatStaffInfo);
    given(complaintDao.selectTreatmentRecordComplaintByOrdNo(any())).willReturn(complaint);

    // action
    TreatmentRecordComplaint result = target.getTreatmentRecordComplaint(ordNo);

    // assert
    assertThat(result.getRstStartDate(), is(rstStartDate));
    assertThat(result.getRstEndDate(), is(rstEndDate));
    assertThat(result.getRstComplaintInfo(), is(rstComplaintInfo));
    assertThat(result.getRstTreatmentInfo(), is(rstTreatmentInfo));
    assertThat(result.getRstTreatStaffInfo(), is(rstTreatStaffInfo));

    verify(complaintDao, times(1)).selectTreatmentRecordComplaintByOrdNo(ordNo);
  }

  /**
   * getTreatmentRecordComplaint()の検証.
   *
   * 条件：治療記録マスタに存在しないOrdNoを指定する
   * 結果：NotExistExceptionがThrowされること
   */
  @Test
  public void test_getTreatmentRecordComplaint_失敗() {
    // arrange
    final Long ordNo = 1L;
    given(complaintDao.selectTreatmentRecordComplaintByOrdNo(any())).willThrow(EmptyResultDataAccessException.class);

    // action
    // assert
    expectedException.expect(NotExistException.class);
    expectedException.expectMessage("存在しない治療情報のオーダ番号を指定されています。");
    target.getTreatmentRecordComplaint(ordNo);

    verify(complaintDao, times(1)).selectTreatmentRecordComplaintByOrdNo(ordNo);
  }

  /**
   * updateTreatmentRecordComplaint()の検証.
   *
   * 条件：なし
   * 結果：更新件数が返却されること
   */
  @Test
  public void test_updateTreatmentRecordComplaint_成功() {
    // arrange
    final long ordNo = 1L;

    final Timestamp rstStartDate = Timestamp.valueOf("2019-12-31 13:00:00");
    final Timestamp rstEndDate = Timestamp.valueOf("2019-12-31 18:00:00");
    final String rstComplaintInfoForUpdate
      = "[{\"cd\": 110, \"name\": \"name110\"}, {\"cd\": 201, \"name\": \"name201\"}]";
    final String rstTreatmentInfoForUpdate
      = "[{\"cd\": 120, \"name\": \"name120\"}, {\"cd\": 202, \"name\": \"name202\"}]";
    final String rstTreatStaffInfoForUpdate
      = "[{\"cd\": 130, \"name\": \"name130\"}, {\"cd\": 203, \"name\": \"name203\"}]";

    final TreatmentRecordComplaint treatmentRecordComplaint = new TreatmentRecordComplaint();
    treatmentRecordComplaint.setRstStartDate(rstStartDate);
    treatmentRecordComplaint.setRstEndDate(rstEndDate);
    treatmentRecordComplaint.setRstComplaintInfo(rstComplaintInfoForUpdate);
    treatmentRecordComplaint.setRstTreatmentInfo(rstTreatmentInfoForUpdate);
    treatmentRecordComplaint.setRstTreatStaffInfo(rstTreatStaffInfoForUpdate);

    given(complaintDao.updateTreatmentRecordComplaint(any(), any())).willReturn(1);

    // action
    final int updatedRowCount = target.updateTreatmentRecordComplaint(ordNo, treatmentRecordComplaint);

    // assert
    assertThat(updatedRowCount, is(1));
    verify(complaintDao, times(1)).updateTreatmentRecordComplaint(ordNo, treatmentRecordComplaint);
  }

  /**
   * updateTreatmentRecordComplaint()の検証.
   *
   * 条件：治療記録マスタに存在しないOrdNoを指定する.もしくは削除済みのOrdNoを指定する.
   * 結果：NotExistExceptionがThrowされること
   */
  @Test
  public void test_updateTreatmentRecordComplaint_失敗() {
    // arrange
    final long ordNo = 1L;

    final Timestamp rstStartDate = Timestamp.valueOf("2019-12-31 13:00:00");
    final Timestamp rstEndDate = Timestamp.valueOf("2019-12-31 18:00:00");
    final String rstComplaintInfoForUpdate
      = "[{\"cd\": 110, \"name\": \"name110\"}, {\"cd\": 201, \"name\": \"name201\"}]";
    final String rstTreatmentInfoForUpdate
      = "[{\"cd\": 120, \"name\": \"name120\"}, {\"cd\": 202, \"name\": \"name202\"}]";
    final String rstTreatStaffInfoForUpdate
      = "[{\"cd\": 130, \"name\": \"name130\"}, {\"cd\": 203, \"name\": \"name203\"}]";

    final TreatmentRecordComplaint treatmentRecordComplaint = new TreatmentRecordComplaint();
    treatmentRecordComplaint.setRstStartDate(rstStartDate);
    treatmentRecordComplaint.setRstEndDate(rstEndDate);
    treatmentRecordComplaint.setRstComplaintInfo(rstComplaintInfoForUpdate);
    treatmentRecordComplaint.setRstTreatmentInfo(rstTreatmentInfoForUpdate);
    treatmentRecordComplaint.setRstTreatStaffInfo(rstTreatStaffInfoForUpdate);

    given(complaintDao.updateTreatmentRecordComplaint(any(), any())).willReturn(0);

    // action
    // assert
    expectedException.expect(NotExistException.class);
    expectedException.expectMessage("存在しない治療情報のオーダ番号を指定されています。");
    target.updateTreatmentRecordComplaint(ordNo, treatmentRecordComplaint);
  }
}
