package jp.co.nikkiso.ntss.admin_web.service.treatmentRecord;

import jp.co.nikkiso.ntss.core.dao.TreatmentRecordDao;
import jp.co.nikkiso.ntss.core.dao.TreatmentRecordOrdTreatConditionDao;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordDeviceSetInfo;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordSetting;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.test.context.junit4.SpringRunner;

import java.sql.Timestamp;
import java.util.Arrays;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.tuple;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

/**
 * TreatmentRecordSettingServiceImplのテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
public class TreatmentRecordSettingServiceImplTest {

  /**
   * テスト対象サービス.
   */
  @Autowired
  private TreatmentRecordSettingService target;

  /**
   * 設定値読み込み履歴のMockBean.
   */
  @MockBean
  private TreatmentRecordOrdTreatConditionDao treatmentRecordOrdTreatConditionDao;

  /**
   * 治療情報のMockBean.
   */
  @MockBean
  private TreatmentRecordDao treatmentRecordDao;

  /**
   * 例外の発生をテストするためのルール
   */
  @Rule
  public ExpectedException expectedException = ExpectedException.none();

  /**
   * getOrdTreatConditionByOrdNo()の検証.
   *
   * 条件：なし
   * 結果：設定値読み込み履歴を取得できること
   */
  @Test
  public void test_getOrdTreatConditionByOrdNo_正常() {
    // arrange
    final long ordNo = 1L;
    given(treatmentRecordOrdTreatConditionDao.selectTreatmentRecordSettingsByOrdNo(anyLong()))
      .willReturn(Arrays.asList(
        new TreatmentRecordSetting(
          Timestamp.valueOf("2019-06-13 09:00:00.000")
          , "{\"a\": \"aaa\", \"b\": \"bbb\"}"
          , (short)0
        ),
        new TreatmentRecordSetting(
          Timestamp.valueOf("2019-06-14 11:40:00.000")
          , "{\"a\": \"aaa\", \"b\": \"bbb\"}"
          , (short)1
        )
      )
    );

    // action
    final List<TreatmentRecordSetting> result = target.getOrdTreatConditionByOrdNo(ordNo);

    // assert
    assertThat(result)
      .hasSize(2)
      .extracting(
        TreatmentRecordSetting::getReceiveDate
        , TreatmentRecordSetting::getTreatCondition
        , TreatmentRecordSetting::getTreatClass
      )
      .containsExactly(
        tuple(
          Timestamp.valueOf("2019-06-13 09:00:00.000")
          , "{\"a\": \"aaa\", \"b\": \"bbb\"}"
          , (short)0
        )
        , tuple(
          Timestamp.valueOf("2019-06-14 11:40:00.000")
          , "{\"a\": \"aaa\", \"b\": \"bbb\"}"
          , (short)1
        )
      )
    ;
    verify(treatmentRecordOrdTreatConditionDao, times(1))
      .selectTreatmentRecordSettingsByOrdNo(ordNo);
  }

  /**
   * getTreatmentRecordDeviceSetInfoByOrdNo()の検証.
   *
   * 条件：治療記録マスタに存在するOrdNoをもつレコードを指定する
   * 結果：装置設定情報を取得できること
   */
  @Test
  public void test_getTreatmentRecordDeviceSetInfoByOrdNo_成功() {
    // arrange
    final long ordNo = 1L;
    given(treatmentRecordDao.selectTreatmentRecordDeviceSetInfoByOrdNo(anyLong()))
      .willReturn(
        new TreatmentRecordDeviceSetInfo(
//          "{\"a\": \"aaa\", \"b\": \"bbb\"}"
           11L
          , "testFacilityCd"
        )
      );

    // action
    final TreatmentRecordDeviceSetInfo result = target.getTreatmentRecordDeviceSetInfoByOrdNo(ordNo);

    // assert
    assertThat(result).isNotNull();
    /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --start */
//    assertThat(result.getRstDeviceSetInfo()).isEqualTo("{\"a\": \"aaa\", \"b\": \"bbb\"}");
    /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --end */
    assertThat(result.getPatId()).isEqualTo(11L);
    assertThat(result.getFacilityCd()).isEqualTo("testFacilityCd");

    verify(treatmentRecordDao, times(1))
      .selectTreatmentRecordDeviceSetInfoByOrdNo(ordNo);
  }

  /**
   * getTreatmentRecordDeviceSetInfoByOrdNo()の検証.
   *
   * 条件：治療記録マスタに存在しないOrdNoを指定する
   * 結果：NotExistExceptionがThrowされること
   */
  @Test
  public void test_getTreatmentRecordDeviceSetInfoByOrdNo_失敗() {
    // arrange
    final Long ordNo = 1L;
    given(treatmentRecordDao.selectTreatmentRecordDeviceSetInfoByOrdNo(anyLong()))
      .willThrow(EmptyResultDataAccessException.class);

    // action
    // assert
    expectedException.expect(NotExistException.class);
    expectedException.expectMessage("存在しない治療情報のオーダ番号を指定されています。");
    target.getTreatmentRecordDeviceSetInfoByOrdNo(ordNo);

    verify(treatmentRecordDao, times(1))
      .selectTreatmentRecordDeviceSetInfoByOrdNo(ordNo);
  }
}
