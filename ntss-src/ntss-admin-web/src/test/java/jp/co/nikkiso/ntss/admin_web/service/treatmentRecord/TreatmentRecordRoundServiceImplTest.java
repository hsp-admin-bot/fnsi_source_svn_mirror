package jp.co.nikkiso.ntss.admin_web.service.treatmentRecord;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.BDDMockito.any;
import static org.mockito.BDDMockito.anyLong;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.times;
import static org.mockito.BDDMockito.verify;

import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.test.context.junit4.SpringRunner;

import jp.co.nikkiso.ntss.core.dao.TreatmentRecordDao;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordRoundsInfo;
import jp.co.nikkiso.ntss.core.exception.NotExistException;

/**
 * TreatmentRecordRoundServiceImplのテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
public class TreatmentRecordRoundServiceImplTest {

  /**
   * テスト対象サービス.
   */
  @Autowired
  private TreatmentRecordRoundService target;

  /**
   * 治療情報のMockBean.
   */
  @MockitoBean
  private TreatmentRecordDao treatmentRecordDao;

  /**
   * 例外の発生をテストするためのルール
   */
  @Rule
  public ExpectedException expectedException = ExpectedException.none();

  /**
   * getTreatmentRecordRoundsInfoByOrdNo()の検証.
   *
   * 条件：治療記録マスタに存在するOrdNoをもつレコードを指定する
   * 結果：回診記録情報を取得できること
   */
  @Test
  public void test_getTreatmentRecordRoundsInfoByOrdNo_成功() {
    // arrange
    final long ordNo = 1L;
    TreatmentRecordRoundsInfo roundsInfo = new TreatmentRecordRoundsInfo();
    roundsInfo.setRstRoundsInfo("[{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]");
    given(treatmentRecordDao.selectTreatmentRecordRoundsInfoByOrdNo(anyLong()))
      .willReturn(roundsInfo);

    // action
    final TreatmentRecordRoundsInfo result = target.getTreatmentRecordRoundsInfoByOrdNo(ordNo);

    // assert
    assertThat(result).isNotNull();
    assertThat(result.getRstRoundsInfo()).isEqualTo("[{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]");

    verify(treatmentRecordDao, times(1))
      .selectTreatmentRecordRoundsInfoByOrdNo(ordNo);
  }

  /**
   * getTreatmentRecordRoundsInfoByOrdNo()の検証.
   *
   * 条件：治療記録マスタに存在しないOrdNoを指定する
   * 結果：NotExistExceptionがThrowされること
   */
  @Test
  public void test_getTreatmentRecordRoundsInfoByOrdNo_失敗() {
    // arrange
    final Long ordNo = 1L;
    given(treatmentRecordDao.selectTreatmentRecordRoundsInfoByOrdNo(anyLong()))
      .willThrow(EmptyResultDataAccessException.class);

    // action
    // assert
    expectedException.expect(NotExistException.class);
    expectedException.expectMessage("存在しない治療情報のオーダ番号を指定されています。");
    target.getTreatmentRecordRoundsInfoByOrdNo(ordNo);

    verify(treatmentRecordDao, times(1))
      .selectTreatmentRecordRoundsInfoByOrdNo(ordNo);
  }

  /**
   * updateTreatmentRecordRoundsInfo()の検証.
   *
   * 条件：治療情報に存在するOrdNoをもつレコードを指定する
   * 結果：回診記録情報の更新ができること
   */
  @Test
  public void test_updateTreatmentRecordRoundsInfo_成功_回診記録情報の更新ができること() {
    // arrange
    final Long ordNo = 1L;
    TreatmentRecordRoundsInfo beforeUpdateTreatmentRecordRoundsInfo = new TreatmentRecordRoundsInfo();
    beforeUpdateTreatmentRecordRoundsInfo.setRstRoundsInfo("[{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]");

    final ArgumentCaptor<Long> ordNoCaptor = ArgumentCaptor.forClass(Long.class);
    final ArgumentCaptor<TreatmentRecordRoundsInfo> updateCaptor = ArgumentCaptor.forClass(TreatmentRecordRoundsInfo.class);
    given(treatmentRecordDao.updateTreatmentRecordForRoundsInfo(ordNoCaptor.capture(), updateCaptor.capture())).willReturn(1);

    // action
    target.updateTreatmentRecordRoundsInfo(ordNo, beforeUpdateTreatmentRecordRoundsInfo);

    // assert
    final Long updatedOrdNo = ordNoCaptor.getValue();
    assertThat(updatedOrdNo).isEqualTo(1L);
    final TreatmentRecordRoundsInfo updateTreatmentRecordRoundsInfo = updateCaptor.getValue();
    assertThat(updateTreatmentRecordRoundsInfo).isEqualTo(beforeUpdateTreatmentRecordRoundsInfo);
  }

  /**
   * updateTreatmentRecordRoundsInfo()の検証.
   *
   * 条件：治療情報に存在しないOrdNoをもつレコードを指定する
   * 結果：NotExistExceptionがThrowされること
   */
  @Test
  public void test_updateTreatmentRecordRoundsInfo_失敗_コードに一致する治療情報がない場合は例外が発生すること() {
    // arrange
    final Long ordNo = 1L;
    TreatmentRecordRoundsInfo beforeUpdateTreatmentRecordRoundsInfo = new TreatmentRecordRoundsInfo();
    beforeUpdateTreatmentRecordRoundsInfo.setRstRoundsInfo("[{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]");

    given(treatmentRecordDao.updateTreatmentRecordForRoundsInfo(any(), any())).willReturn(0);

    // action
    // assert
    expectedException.expect(NotExistException.class);
    expectedException.expectMessage("存在しない治療情報のオーダ番号を指定されています。");
    target.updateTreatmentRecordRoundsInfo(ordNo, beforeUpdateTreatmentRecordRoundsInfo);
  }
}
