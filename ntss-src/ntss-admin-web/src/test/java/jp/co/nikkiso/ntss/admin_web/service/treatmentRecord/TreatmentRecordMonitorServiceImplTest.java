package jp.co.nikkiso.ntss.admin_web.service.treatmentRecord;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.not;
import static org.hamcrest.Matchers.nullValue;
import static org.hamcrest.Matchers.samePropertyValuesAs;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.times;
import static org.mockito.BDDMockito.verify;

import java.sql.Timestamp;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordResult;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.junit4.SpringRunner;

import jp.co.nikkiso.ntss.core.dao.TreatmentRecordDao;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordMonitor;

@RunWith(SpringRunner.class)
@SpringBootTest
public class TreatmentRecordMonitorServiceImplTest {
  /**
   * テスト対象クラス
   */
  @Autowired
  private TreatmentRecordMonitorService target;

  /**
   * 治療情報のMockBean.
   */
  @MockBean
  private TreatmentRecordDao treatmentRecordDao;

  /**
   * {@link OrdMainDao}のMockBean
   */
  @MockBean
  private OrdMainDao ordMainDao;

  /**
   * {@link MstPersonalUserDao} のMockBean
   */
  @MockBean
  private MstPersonalUserDao mstPersonalUserDao;

  /**
   * 例外の発生をテストするためのルール
   */
  @Rule
  public ExpectedException expectedException = ExpectedException.none();

  /**
   * モニタ情報のテストデータを作成します.
   * @param bioMoniCtlNo 生体モニタリング管理番号
   * @param occurDate 発生日時
   * @return {@link TreatmentRecordMonitor} を返す.
   */
  private TreatmentRecordMonitor getMonitor(Long bioMoniCtlNo, Timestamp occurDate) {
    return getMonitor(bioMoniCtlNo, occurDate, null);
  }

  /**
   * モニタ情報のテストデータを作成します.
   * @param bioMoniCtlNo 生体モニタリング管理番号
   * @param occurDate 発生日時
   * @param userId 利用者ID(更新者IDとして設定)
   * @return {@link TreatmentRecordMonitor} を返す.
   */
  private TreatmentRecordMonitor getMonitor(Long bioMoniCtlNo, Timestamp occurDate, Long userId) {
    TreatmentRecordMonitor mniMonitor = new TreatmentRecordMonitor();
    mniMonitor.setBioMoniCtlNo(bioMoniCtlNo);
    mniMonitor.setMonitorData("[{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]");
    mniMonitor.setOccurDate(occurDate);
    mniMonitor.setIsDel("0");
    mniMonitor.setUpdStaffId(userId);
    return mniMonitor;
  }

  /**
   * getTreatmentRecordMonitors()の検証.
   *
   * 条件：指定されたオーダ番号に該当する装置モニタデータが存在する
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_getTreatmentRecordMonitors_正常() {
    // 事前準備
    Long ordNo = 10L;

    final TreatmentRecordResult treatmentRecordResult = new TreatmentRecordResult() {
      {
        setRstStartDate(Timestamp.valueOf("2019-05-24 12:05:15"));
      }
    };

    List<TreatmentRecordMonitor> mniMonitors = Arrays.asList(
      getMonitor(1L, Timestamp.valueOf("2019-05-24 12:03:00")), // ×
      getMonitor(2L, Timestamp.valueOf("2019-05-24 12:05:00")), // ×
      getMonitor(3L, Timestamp.valueOf("2019-05-24 12:05:01")), // 〇 12:05
      getMonitor(4L, Timestamp.valueOf("2019-05-24 12:06:00")), // ×
      getMonitor(5L, Timestamp.valueOf("2019-05-24 12:15:00")), // ×
      getMonitor(6L, Timestamp.valueOf("2019-05-24 12:19:59")), // ×
      getMonitor(7L, Timestamp.valueOf("2019-05-24 12:20:59")), // 〇 12:20
      getMonitor(8L, Timestamp.valueOf("2019-05-24 12:34:00")), // 〇 12:35
      getMonitor(9L, Timestamp.valueOf("2019-05-24 12:38:00")), // ×
      getMonitor(10L, Timestamp.valueOf("2019-05-24 12:40:00")), // 〇 12:50
      getMonitor(11L, Timestamp.valueOf("2019-05-24 13:05:00")), // 〇 13:05
      getMonitor(12L, Timestamp.valueOf("2019-05-24 13:25:00")), // ×
      getMonitor(13L, Timestamp.valueOf("2019-05-24 13:30:00")) // 〇　13:35
    );
    List<TreatmentRecordMonitor> expected = Arrays.asList(
        mniMonitors.get(2),
        mniMonitors.get(6),
        mniMonitors.get(7),
        mniMonitors.get(9),
        mniMonitors.get(10),
        mniMonitors.get(12)
    );

    // Mock化
    given(treatmentRecordDao.selectTreatmentRecordMonitors(ordNo)).willReturn(mniMonitors);
    given(treatmentRecordDao.selectTreatmentRecordResultByOrdNo(ordNo)).willReturn(treatmentRecordResult);

    // 実行
    List<TreatmentRecordMonitor> result = target.getTreatmentRecordMonitors(ordNo);

    // 検証
    verify(treatmentRecordDao, times(1)).selectTreatmentRecordMonitors(ordNo);
    verify(treatmentRecordDao, times(1)).selectTreatmentRecordResultByOrdNo(ordNo);
    assertThat(result, not(nullValue()));
    assertThat(result.size(), is(expected.size()));
    for (int i = 0; i < expected.size(); i++) {
      assertThat(result.get(i), samePropertyValuesAs(expected.get(i)));
    }
  }

  /**
   * getTreatmentRecordMonitors()の検証.
   *
   * 条件：指定されたオーダ番号に該当する装置モニタデータが存在する
   *       （透析開始日時以前にモニタデータがない場合）
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_getTreatmentRecordMonitors_正常_透析開始日時以前にモニタデータがない場合() {
    // 事前準備
    Long ordNo = 10L;

    final TreatmentRecordResult treatmentRecordResult = new TreatmentRecordResult() {
      {
        setRstStartDate(Timestamp.valueOf("2019-05-24 12:00:00"));
      }
    };

    List<TreatmentRecordMonitor> mniMonitors = Arrays.asList(
      getMonitor(1L, Timestamp.valueOf("2019-05-24 12:03:00")), // ×
      getMonitor(2L, Timestamp.valueOf("2019-05-24 12:05:00")), // ×
      getMonitor(3L, Timestamp.valueOf("2019-05-24 12:05:01")), // ×
      getMonitor(4L, Timestamp.valueOf("2019-05-24 12:06:00")), // ×
      getMonitor(5L, Timestamp.valueOf("2019-05-24 12:15:00")), // 〇 12:15
      getMonitor(6L, Timestamp.valueOf("2019-05-24 12:19:59")), // ×
      getMonitor(7L, Timestamp.valueOf("2019-05-24 12:20:59")), // 〇 12:30
      getMonitor(8L, Timestamp.valueOf("2019-05-24 12:34:00")), // ×
      getMonitor(9L, Timestamp.valueOf("2019-05-24 12:38:00")), // ×
      getMonitor(10L, Timestamp.valueOf("2019-05-24 12:40:00")), // 〇 12:45
      getMonitor(11L, Timestamp.valueOf("2019-05-24 13:05:00")), // 〇 13:15
      getMonitor(12L, Timestamp.valueOf("2019-05-24 13:25:00")), // ×
      getMonitor(13L, Timestamp.valueOf("2019-05-24 13:30:00")) // 〇　13:30
    );
    List<TreatmentRecordMonitor> expected = Arrays.asList(
        mniMonitors.get(4),
        mniMonitors.get(6),
        mniMonitors.get(9),
        mniMonitors.get(10),
        mniMonitors.get(12)
    );

    // Mock化
    given(treatmentRecordDao.selectTreatmentRecordMonitors(ordNo)).willReturn(mniMonitors);
    given(treatmentRecordDao.selectTreatmentRecordResultByOrdNo(ordNo)).willReturn(treatmentRecordResult);

    // 実行
    List<TreatmentRecordMonitor> result = target.getTreatmentRecordMonitors(ordNo);

    // 検証
    verify(treatmentRecordDao, times(1)).selectTreatmentRecordMonitors(ordNo);
    verify(treatmentRecordDao, times(1)).selectTreatmentRecordResultByOrdNo(ordNo);
    assertThat(result, not(nullValue()));
    assertThat(result.size(), is(expected.size()));
    for (int i = 0; i < expected.size(); i++) {
      assertThat(result.get(i), samePropertyValuesAs(expected.get(i)));
    }
  }

  /**
   * getTreatmentRecordMonitors()の検証.
   *
   * 条件：指定されたオーダ番号に該当する装置モニタデータが存在しない
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_getTreatmentRecordMonitors_正常_0件() {
    // 事前準備
    Long ordNo = 10L;

    final TreatmentRecordResult treatmentRecordResult = new TreatmentRecordResult() {
      {
        setRstStartDate(Timestamp.valueOf("2019-05-24 12:05:15"));
      }
    };

    // Mock化
    given(treatmentRecordDao.selectTreatmentRecordResultByOrdNo(ordNo)).willReturn(treatmentRecordResult);
    given(treatmentRecordDao.selectTreatmentRecordMonitors(ordNo)).willReturn(Collections.emptyList());

    // 実行
    List<TreatmentRecordMonitor> result = target.getTreatmentRecordMonitors(ordNo);

    // 検証
    verify(treatmentRecordDao, times(1)).selectTreatmentRecordResultByOrdNo(ordNo);
    verify(treatmentRecordDao, times(1)).selectTreatmentRecordMonitors(ordNo);
    assertThat(result, not(nullValue()));
    assertThat(result.size(), is(0));
  }

  /**
   * getTreatmentRecordMonitors()の検証.
   *
   * 条件：指定されたオーダ番号に該当する治療情報レコードが存在しない
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_getTreatmentRecordMonitors_正常_治療情報レコードが存在しない() {
    // 事前準備
    Long ordNo = 10L;

    // Mock化
    given(treatmentRecordDao.selectTreatmentRecordResultByOrdNo(ordNo)).willReturn(null);

    // 実行
    List<TreatmentRecordMonitor> result = target.getTreatmentRecordMonitors(ordNo);

    // 検証
    verify(treatmentRecordDao, times(1)).selectTreatmentRecordResultByOrdNo(ordNo);
    assertThat(result, not(nullValue()));
    assertThat(result.size(), is(0));
  }

  /**
   * getTreatmentRecordMonitors()の検証.
   *
   * 条件：指定されたオーダ番号に該当する治療情報レコードに治療開始日時が設定されていない
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_getTreatmentRecordMonitors_正常_治療開始日時が設定されていない() {
    // 事前準備
    Long ordNo = 10L;

    List<TreatmentRecordMonitor> mniMonitors = Arrays.asList(
      getMonitor(1L, Timestamp.valueOf("2019-05-24 12:03:00")),
      getMonitor(2L, Timestamp.valueOf("2019-05-24 12:05:00")),
      getMonitor(3L, Timestamp.valueOf("2019-05-24 12:05:01")),
      getMonitor(4L, Timestamp.valueOf("2019-05-24 12:06:00")),
      getMonitor(5L, Timestamp.valueOf("2019-05-24 12:15:00")),
      getMonitor(6L, Timestamp.valueOf("2019-05-24 12:19:59")),
      getMonitor(7L, Timestamp.valueOf("2019-05-24 12:20:59")),
      getMonitor(8L, Timestamp.valueOf("2019-05-24 12:34:00")),
      getMonitor(9L, Timestamp.valueOf("2019-05-24 12:38:00")),
      getMonitor(10L, Timestamp.valueOf("2019-05-24 12:40:00")),
      getMonitor(11L, Timestamp.valueOf("2019-05-24 13:05:00")),
      getMonitor(12L, Timestamp.valueOf("2019-05-24 13:25:00")),
      getMonitor(13L, Timestamp.valueOf("2019-05-24 13:30:00"))
    );

    // Mock化
    given(treatmentRecordDao.selectTreatmentRecordResultByOrdNo(ordNo)).willReturn(new TreatmentRecordResult());
    given(treatmentRecordDao.selectTreatmentRecordMonitors(ordNo)).willReturn(mniMonitors);

    // 実行
    List<TreatmentRecordMonitor> result = target.getTreatmentRecordMonitors(ordNo);

    // 検証
    verify(treatmentRecordDao, times(1)).selectTreatmentRecordResultByOrdNo(ordNo);
    verify(treatmentRecordDao, times(1)).selectTreatmentRecordMonitors(ordNo);
    assertThat(result, not(nullValue()));
    assertThat(result.size(), is(6));
  }

  /**
   * getTreatmentRecordMonitors()の検証.
   *
   * 条件：手修正されたモニタデータが含まれる事
   * 結果：手修正されたモニタデータが全て返却される事
   */
  @Test
  public void test_getTreatmentRecordMonitors_正常_手修正されたモニタデータが全て取得出来る事() {
    // 事前準備
    Long ordNo = 10L;
    Long userId_1 = 1L;
    Long userId_2 = 2L;

    // テスト用モニタデータ
    List<TreatmentRecordMonitor> mniMonitors = Arrays.asList(
      getMonitor(1L, Timestamp.valueOf("2019-05-24 12:03:00")), // 〇
      getMonitor(2L, Timestamp.valueOf("2019-05-24 12:05:00"), userId_1),
      getMonitor(3L, Timestamp.valueOf("2019-05-24 12:05:01"), userId_1),
      getMonitor(4L, Timestamp.valueOf("2019-05-24 12:06:00")), // ×
      getMonitor(5L, Timestamp.valueOf("2019-05-24 12:15:00")), // 〇
      getMonitor(6L, Timestamp.valueOf("2019-05-24 12:19:59"), userId_1),
      getMonitor(7L, Timestamp.valueOf("2019-05-24 12:20:59")), // 〇
      getMonitor(8L, Timestamp.valueOf("2019-05-24 12:34:00"), userId_1),
      getMonitor(9L, Timestamp.valueOf("2019-05-24 12:38:00")), // ×
      getMonitor(10L, Timestamp.valueOf("2019-05-24 12:40:00")),// 〇
      getMonitor(11L, Timestamp.valueOf("2019-05-24 13:05:00"), userId_2),
      getMonitor(12L, Timestamp.valueOf("2019-05-24 13:25:00")),// ×
      getMonitor(13L, Timestamp.valueOf("2019-05-24 13:30:00")) // 〇
    );

    // テスト用利用者マスタ
    MstPersonalUser mstPersonalUser = new MstPersonalUser();
    mstPersonalUser.setUserId(userId_1);
    mstPersonalUser.setUserLastName("テスト");
    mstPersonalUser.setUserFirstName("太郎");

    // Mock化
    given(treatmentRecordDao.selectTreatmentRecordResultByOrdNo(ordNo)).willReturn(new TreatmentRecordResult());
    given(treatmentRecordDao.selectTreatmentRecordMonitors(ordNo)).willReturn(mniMonitors);
    given(mstPersonalUserDao.selectById(userId_1)).willReturn(mstPersonalUser);
    given(mstPersonalUserDao.selectById(userId_2)).willReturn(null);

    // 実行
    List<TreatmentRecordMonitor> result = target.getTreatmentRecordMonitors(ordNo);

    // 検証
    verify(treatmentRecordDao, times(1)).selectTreatmentRecordResultByOrdNo(ordNo);
    verify(treatmentRecordDao, times(1)).selectTreatmentRecordMonitors(ordNo);
    verify(mstPersonalUserDao, times(4)).selectById(userId_1);
    verify(mstPersonalUserDao, times(1)).selectById(userId_2);
    assertThat(result, not(nullValue()));
    assertThat(result.size(), is(10));
    assertThat(result.get(0).getBioMoniCtlNo(), is(1L));
    assertThat(result.get(1).getBioMoniCtlNo(), is(2L));
    assertThat(result.get(1).getUserLastName(), is("テスト"));
    assertThat(result.get(1).getUserFirstName(), is("太郎"));
    assertThat(result.get(2).getBioMoniCtlNo(), is(3L));
    assertThat(result.get(2).getUserLastName(), is("テスト"));
    assertThat(result.get(2).getUserFirstName(), is("太郎"));
    assertThat(result.get(3).getBioMoniCtlNo(), is(5L));
    assertThat(result.get(4).getBioMoniCtlNo(), is(6L));
    assertThat(result.get(4).getUserLastName(), is("テスト"));
    assertThat(result.get(4).getUserFirstName(), is("太郎"));
    assertThat(result.get(5).getBioMoniCtlNo(), is(7L));
    assertThat(result.get(6).getBioMoniCtlNo(), is(8L));
    assertThat(result.get(6).getUserLastName(), is("テスト"));
    assertThat(result.get(6).getUserFirstName(), is("太郎"));
    assertThat(result.get(7).getBioMoniCtlNo(), is(10L));
    assertThat(result.get(8).getBioMoniCtlNo(), is(11L));
    assertThat(result.get(8).getUserLastName(), nullValue());
    assertThat(result.get(8).getUserFirstName(), nullValue());
    assertThat(result.get(9).getBioMoniCtlNo(), is(13L));
  }
}
