package jp.co.nikkiso.ntss.core.dao;

import static org.hamcrest.Matchers.is;
import static org.junit.Assert.assertThat;

import java.sql.Timestamp;

import jp.co.nikkiso.ntss.core.entity.OrdMain;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.entity.TreatmentRecordComplaint;

/**
 * {@link TreatmentRecordComplaintDao} のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:dao.script/TreatmentRecordComplaintDaoTest.before.sql")
public class TreatmentRecordComplaintDaoTest {

  /**
   * テスト対象Daoインターフェース
   */
  @Autowired
  private TreatmentRecordComplaintDao target;

  /**
   * 治療記録Daoインターフェース.
   */
  @Autowired
  private OrdMainDao ordMainDao;

  /**
   * selectTreatmentRecordComplaintByOrdNo()の検証.
   * <p>
   * 条件：該当データあり
   * 結果：該当データを取得できること
   * </p>
   */
  @Test
  public void test_selectTreatmentRecordComplaintByOrdNo_正常_該当データあり() {
    // arrange
    final Long ordNo = 1L;
    final Timestamp rstStartDate = Timestamp.valueOf("2019-05-29 13:00:00");
    final Timestamp rstEndDate = Timestamp.valueOf("2019-05-29 18:00:00");
    final String rstComplaintInfo = "[{\"cd\": 11, \"name\": \"name11\"}, {\"cd\": 2, \"name\": \"name2\"}]";
    final String rstTreatmentInfo = "[{\"cd\": 12, \"name\": \"name12\"}, {\"cd\": 2, \"name\": \"name2\"}]";
    final String rstTreatStaffInfo = "[{\"cd\": 13, \"name\": \"name13\"}, {\"cd\": 2, \"name\": \"name2\"}]";

    // action
    TreatmentRecordComplaint result = target.selectTreatmentRecordComplaintByOrdNo(ordNo);

    // assert
    assertThat(result.getOrdNo(), is(ordNo));
    assertThat(result.getRstStartDate(), is(rstStartDate));
    assertThat(result.getRstEndDate(), is(rstEndDate));
    assertThat(result.getRstComplaintInfo(), is(rstComplaintInfo));
    assertThat(result.getRstTreatmentInfo(), is(rstTreatmentInfo));
    assertThat(result.getRstTreatStaffInfo(), is(rstTreatStaffInfo));
    assertThat(result.getUpDate(), is(Timestamp.valueOf("2019-03-01 13:00:00")));
    assertThat(result.getRegDate(), is(Timestamp.valueOf("2019-03-01 13:10:00")));
  }

  /**
   * selectTreatmentRecordComplaintByOrdNo()の検証.
   * <p>
   * 条件：OrdNoに該当するレコードが存在しない
   * 結果：EmptyResultDataAccessException例外が投げられること
   * </p>
   */
  @Test(expected = EmptyResultDataAccessException.class)
  public void test_selectTreatmentRecordComplaintByOrdNo_異常_該当データなし() {
    // arrange
    final long ordNo = 9999L;

    // action
    // assert
    target.selectTreatmentRecordComplaintByOrdNo(ordNo);
  }

  /**
   * selectTreatmentRecordComplaintByOrdNo()の検証.
   * <p>
   * 条件：該当データ削除済み
   * 結果：EmptyResultDataAccessException例外が投げられること
   * </p>
   */
  @Test(expected = EmptyResultDataAccessException.class)
  public void test_selectTreatmentRecordComplaintByOrdNo_異常_該当データ削除済み() {
    // arrange
    final long ordNo = 2L;

    // action
    // assert
    target.selectTreatmentRecordComplaintByOrdNo(ordNo);
  }

  /**
   * updateTreatmentRecordComplaint()の検証.
   * <p>
   * 条件：該当データあり
   * 結果：該当データを更新できること
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordComplaint_正常() {
    // arrange
    final long ordNo = 1L;

    // フィクスチャとは異なる時間を設定する。（更新されないことの確認）
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

    // action
    final int updatedRowCount = target.updateTreatmentRecordComplaint(ordNo, treatmentRecordComplaint);
    final TreatmentRecordComplaint updatedComplaint = target.selectTreatmentRecordComplaintByOrdNo(ordNo);

    // assert
    assertThat(updatedRowCount, is(1));
    assertThat(updatedComplaint.getRstStartDate(), is(Timestamp.valueOf("2019-05-29 13:00:00")));
    assertThat(updatedComplaint.getRstEndDate(), is(Timestamp.valueOf("2019-05-29 18:00:00")));
    assertThat(updatedComplaint.getRstComplaintInfo(), is(rstComplaintInfoForUpdate));
    assertThat(updatedComplaint.getRstTreatmentInfo(), is(rstTreatmentInfoForUpdate));
    assertThat(updatedComplaint.getRstTreatStaffInfo(), is(rstTreatStaffInfoForUpdate));
  }

  /**
   * updateTreatmentRecordComplaint()の検証.
   * <p>
   * 条件：該当データなし
   * 結果：更新結果が0件となること
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordComplaint_異常_該当データなし() {
    // arrange
    final long ordNo = 999L;

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

    // action
    final int updatedRowCount = target.updateTreatmentRecordComplaint(ordNo, treatmentRecordComplaint);

    // assert
    assertThat(updatedRowCount, is(0));
  }

  /**
   * updateTreatmentRecordComplaint()の検証.
   * <p>
   * 条件：該当データ削除済み
   * 結果：更新結果が0件となること
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordComplaint_異常_該当データ削除済み() {
    // arrange
    final long ordNo = 2L;

    // フィクスチャとは異なる時間を設定する。（更新されないことの確認）
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

    // action
    final int updatedRowCount = target.updateTreatmentRecordComplaint(ordNo, treatmentRecordComplaint);

    // assert
    assertThat(updatedRowCount, is(0));
  }

  /**
   * updateTreatmentRecordComplaint()の検証.
   * <p>
   * 条件：過去実績のデータを更新する.
   * 結果：版番号と版番号更新フラグが更新されること.
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordComplaint_正常_版番号_版番号更新フラグ_更新する() {

    // 事前準備
    Long ordNo = 100001L;

    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    assertThat(ordMain.getRstEdition(), is(0));
    assertThat(ordMain.getRstIsUpdateEdition(), is("0"));
    assertThat(ordMain.getRstDialysisState(), is("6"));

    // 実行
    TreatmentRecordComplaint entity = target.selectTreatmentRecordComplaintByOrdNo(ordNo);
    int updateCount = target.updateTreatmentRecordComplaint(ordNo, entity);

    // 検証(更新件数)
    assertThat(updateCount, is(1));

    // 検証
    OrdMain updated = ordMainDao.selectByOrdNo(ordNo);
    assertThat(updated.getRstEdition(), is(0));
    assertThat(updated.getRstIsUpdateEdition(), is("0"));
    assertThat(updated.getRstDialysisState(), is("6"));
    // 検証：確定フラグが更新されていない事
    assertThat(updated.getIsConfirm(), is("0"));
  }

  /**
   * updateTreatmentRecordComplaint()の検証.
   * <p>
   * 条件：過去実績以外のデータを更新する.
   * 結果：版番号と版番号更新フラグが更新されないこと.
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordComplaint_正常_版番号_版番号更新フラグ_更新しない() {

    // 事前準備
    Long ordNo = 100002L;

    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    assertThat(ordMain.getRstEdition(), is(0));
    assertThat(ordMain.getRstIsUpdateEdition(), is("0"));
    assertThat(ordMain.getRstDialysisState(), is("1"));

    // 実行
    TreatmentRecordComplaint entity = target.selectTreatmentRecordComplaintByOrdNo(ordNo);
    int updateCount = target.updateTreatmentRecordComplaint(ordNo, entity);

    // 検証(更新件数)
    assertThat(updateCount, is(1));

    // 検証
    OrdMain updated = ordMainDao.selectByOrdNo(ordNo);
    assertThat(updated.getRstEdition(), is(0));
    assertThat(updated.getRstIsUpdateEdition(), is("0"));
    assertThat(updated.getRstDialysisState(), is("1"));
  }

}
