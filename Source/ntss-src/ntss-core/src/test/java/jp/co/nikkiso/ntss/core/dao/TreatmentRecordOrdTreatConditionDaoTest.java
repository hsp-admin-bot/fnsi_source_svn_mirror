package jp.co.nikkiso.ntss.core.dao;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.tuple;

import jp.co.nikkiso.ntss.core.entity.TreatmentRecordSetting;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Timestamp;
import java.util.List;

/**
 * {@link TreatmentRecordOrdTreatConditionDao} のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:dao.script/TreatmentRecordOrdTreatConditionDaoTest.before.sql")
public class TreatmentRecordOrdTreatConditionDaoTest {

  /**
   * テスト対象Dao.
   */
  @Autowired
  private TreatmentRecordOrdTreatConditionDao target;

  /**
   * selectTreatmentRecordSettingsByOrdNo()の検証.
   * <p>
   * 条件：該当データあり
   * 結果：設定値読み込み履歴情報のリストが取得できること
   * </p>
   */
  @Test
  public void test_selectTreatmentRecordSettingsByOrdNo_正常_該当データあり() {
    // arrange
    final Long ordNo = 1L;

    // action
    List<TreatmentRecordSetting> result = target.selectTreatmentRecordSettingsByOrdNo(ordNo);

    // assert
    assertThat(result)
      .hasSize(4)
      .extracting(
        TreatmentRecordSetting::getReceiveDate
        , TreatmentRecordSetting::getTreatCondition
        , TreatmentRecordSetting::getTreatClass
      )
      .containsExactly(
        tuple(
          Timestamp.valueOf("2019-03-21 18:00:00.000")
          , "{\"a\": \"aaa\", \"b\": \"bbb\"}"
          , (short)2
        )
        , tuple(
          Timestamp.valueOf("2019-03-22 14:35:00.000")
          , "{\"a\": \"aaa\", \"b\": \"bbb\"}"
          , (short)0
        )
        , tuple(
          Timestamp.valueOf("2019-03-23 21:35:00.000")
          , "{\"a\": \"aaa\", \"b\": \"bbb\"}"
          , (short)1
        )
        , tuple(
          Timestamp.valueOf("2019-03-23 21:36:00.000")
          , "{\"a\": \"aaa\", \"b\": \"bbb\"}"
          , null
        )
      )
    ;
  }

  /**
   * selectTreatmentRecordSettingsByOrdNo()の検証.
   * <p>
   * 条件：該当データなし
   * 結果：空のリストを返すこと
   * </p>
   */
  @Test
  public void test_selectTreatmentRecordSettingsByOrdNo_正常_該当データなしの場合は空のリストを返すこと() {
    // arrange
    final Long ordNo = 2L;

    // action
    List<TreatmentRecordSetting> result = target.selectTreatmentRecordSettingsByOrdNo(ordNo);

    // assert
    assertThat(result).isEmpty();
  }
}
