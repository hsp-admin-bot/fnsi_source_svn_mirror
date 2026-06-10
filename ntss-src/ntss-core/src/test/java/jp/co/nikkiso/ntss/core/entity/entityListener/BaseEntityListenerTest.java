package jp.co.nikkiso.ntss.core.entity.entityListener;

import jp.co.nikkiso.ntss.core.dao.TreatmentRecordDao;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordResult;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.dao.OptimisticLockingFailureException;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Timestamp;

import static org.hamcrest.Matchers.is;
import static org.junit.Assert.assertThat;

/**
 * {@link BaseEntityListener}のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:dao.script/BaseEntityListenerTest.before.sql")
public class BaseEntityListenerTest {

  /**
   * テスト対象Dao.
   */
  @Autowired
  private TreatmentRecordDao target;

  /**
   * 楽観的排他制御の検証.
   * <p>
   * 条件：楽観的排他エラーにならない更新情報が指定されていること
   * 結果：更新処理が行われること
   * </p>
   */
  @Test
  public void test_update_正常_楽観的排他制御_楽観的排他エラーにならない() {

    // 事前準備
    Long ordNo = 1L;
    TreatmentRecordResult entity = target.selectTreatmentRecordResultByOrdNo(ordNo);
    entity.setOrdNo(ordNo);
    entity.setUpDate(Timestamp.valueOf("2019-02-13 14:30:00.000"));

    // 実行
    int updateCount = target.updateTreatmentRecordForResult(ordNo, entity);

    // 検証
    assertThat(updateCount, is(1));
  }

  /**
   * 楽観的排他制御の検証.
   * <p>
   * 条件：楽観的排他エラーになる更新情報が指定されていること
   * 結果：楽観的排他エラーがスローされること
   * </p>
   */
  @Test(expected = OptimisticLockingFailureException.class)
  public void test_update_正常_楽観的排他制御_楽観的排他エラーになる() {

    // 事前準備
    Long ordNo = 1L;
    TreatmentRecordResult entity = target.selectTreatmentRecordResultByOrdNo(ordNo);
    entity.setOrdNo(ordNo);
    entity.setUpDate(Timestamp.valueOf("2019-02-14 14:30:00.000"));

    // 実行
    int updateCount = target.updateTreatmentRecordForResult(ordNo, entity);

    assertThat(updateCount, is(1));
  }

  /**
   * 楽観的排他制御の検証.
   * <p>
   * 楽観的排他制御の以下のテストケースは妥当なEntityがないため、ローカルでEntityクラスを一時的に修正しテストを実施した
   * ・Entityクラスにテーブル名が指定されていない
   * ・@Idが付与されているフィールドがない
   * ・@Idが付与されているフィールドが複数ある
   * </p>
   */

  /**
   * 楽観的排他制御の検証.
   * <p>
   * 条件：楽観的排他制御するための情報が不足していること
   * 結果：楽観的排他エラーとならず更新処理が行われること
   * </p>
   */
  @Test
  public void test_update_正常_楽観的排他制御_情報不足_ID項目() {

    // 事前準備
    Long ordNo = 1L;
    TreatmentRecordResult entity = target.selectTreatmentRecordResultByOrdNo(ordNo);
    entity.setOrdNo(null);
    entity.setUpDate(Timestamp.valueOf("2019-02-14 14:30:00.000"));

    // 実行
    int updateCount = target.updateTreatmentRecordForResult(ordNo, entity);

    // 検証
    assertThat(updateCount, is(1));
  }

  /**
   * 楽観的排他制御の検証.
   * <p>
   * 条件：楽観的排他制御するための情報が不足していること
   * 結果：楽観的排他エラーとならず更新処理が行われること
   * </p>
   */
  @Test
  public void test_update_正常_楽観的排他制御_情報不足_更新日時() {

    // 事前準備
    Long ordNo = 1L;
    TreatmentRecordResult entity = target.selectTreatmentRecordResultByOrdNo(ordNo);
    entity.setOrdNo(ordNo);
    entity.setUpDate(null);

    // 実行
    int updateCount = target.updateTreatmentRecordForResult(ordNo, entity);

    // 検証
    assertThat(updateCount, is(1));
  }

}
