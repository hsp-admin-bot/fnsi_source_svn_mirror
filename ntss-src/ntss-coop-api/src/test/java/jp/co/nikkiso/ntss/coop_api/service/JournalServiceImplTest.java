package jp.co.nikkiso.ntss.coop_api.service;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.junit.Assert.assertNotEquals;
import static org.junit.Assert.assertThat;
import static org.junit.Assert.fail;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.anyString;
import static org.mockito.BDDMockito.doReturn;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.times;
import static org.mockito.BDDMockito.verify;

import java.sql.Timestamp;
import java.util.Base64;
import java.util.List;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.boot.test.mock.mockito.SpyBean;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.api.service.report.ReportService;
import jp.co.nikkiso.ntss.coop_api.request.JournalCreateRequest;
import jp.co.nikkiso.ntss.coop_api.request.JournalUpdateRequest;
import jp.co.nikkiso.ntss.coop_api.utils.ClockWrapper;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants.AnaResult;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants.CoopResult;
import jp.co.nikkiso.ntss.core.dao.MstTreatmentDao;
import jp.co.nikkiso.ntss.core.dao.OrdCoopNoDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.SysCoopJournalDao;
import jp.co.nikkiso.ntss.core.dao.SysCoopNoDao;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import jp.co.nikkiso.ntss.core.exception.NtssException;

@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:resource.script/JournalServiceImplTest/JournalServiceImplTest.db5.before.sql")
public class JournalServiceImplTest extends BaseServiceTest {
  @SpyBean
  JournalServiceImpl service;

  @SpyBean
  SysCoopJournalDao sysCoopJournalDao;

  @SpyBean
  OrdCoopNoDao ordCoopNoDao;

  @SpyBean
  SysCoopNoDao sysCoopNoDao;

  @SpyBean
  PatPersonalMainDao patPersonalMainDao;

  @SpyBean
  MstTreatmentDao mstTreatmentDao;

  @MockBean
  ClockWrapper clockWrapper;

  @SpyBean
  ReportService reportService;

  @Test(expected = NotExistException.class)
  public void 正常系_ジャーナル更新_更新対象となるデータが存在しないのでthrowされる() {
    JournalUpdateRequest expect = new JournalUpdateRequest();
    service.update(expect);
  }

  @Test()
  public void 正常系_ジャーナル更新_変換配信どちらも未処理で更新される() {
    Long ctlNo = 1L;
    String anaResult = AnaResult.UNPROCESS.getResult();
    String coopResult = CoopResult.UNPROCESS.getResult();
    String dumpPath = "";
    Long userId = 123L;
    JournalUpdateRequest expect = 更新リクエストテストデータ作成(ctlNo, anaResult, coopResult, dumpPath, userId);
    SysCoopJournal actual = service.update(expect);

    assertThat(actual.getCtlNo(), is(1L));
    assertThat(actual.getAnaResult(), is(expect.getAnaResult()));
    assertThat(actual.getCoopResult(), is(expect.getCoopResult()));
    assertThat(actual.getDumpPath(), is(expect.getDumpPath()));
    assertThat(actual.getUserId(), is(expect.getUserId()));
  }

  @Test()
  public void 正常系_ジャーナル更新_変換ステータスが処理中に変更されたら_変換開始日時が指定した日時に切り替わる() {
    Long ctlNo = 1L;
    String anaResult = AnaResult.PROCESSING.getResult();
    String coopResult = CoopResult.UNPROCESS.getResult();
    String dumpPath = "";
    Long userId = 123L;
    JournalUpdateRequest expect = 更新リクエストテストデータ作成(ctlNo, anaResult, coopResult, dumpPath, userId);

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());

    SysCoopJournal before = sysCoopJournalDao.selectByPK(expect.getCtlNo());
    SysCoopJournal actual = service.update(expect);

    assertThat(actual.getCtlNo(), is(1L));
    assertThat(actual.getAnaResult(), is(expect.getAnaResult()));
    assertThat(actual.getCoopResult(), is(expect.getCoopResult()));
    assertThat(actual.getDumpPath(), is(expect.getDumpPath()));
    assertThat(actual.getUserId(), is(expect.getUserId()));
    assertThat(actual.getInAnaDate(), is(Timestamp.valueOf(getExpectMockTime())));
    assertThat(actual.getOutAnaDate(), is(Timestamp.valueOf(getExpectTime())));
    assertThat(actual.getInRegDate(), is(Timestamp.valueOf(getExpectTime())));
    assertThat(actual.getOutRegDate(), is(Timestamp.valueOf(getExpectTime())));

    // 念のため、更新前と突き合わせて値が更新されていることを確認する
    assertNotEquals(actual.getAnaResult(), before.getAnaResult());
  }

  @Test()
  public void 正常系_ジャーナル更新_変換ステータスが処理完了に変更されたら_変換終了日時が指定した日時に切り替わる() {
    Long ctlNo = 1L;
    String anaResult = AnaResult.DONE.getResult();
    String coopResult = CoopResult.UNPROCESS.getResult();
    String dumpPath = "";
    Long userId = 123L;
    JournalUpdateRequest expect = 更新リクエストテストデータ作成(ctlNo, anaResult, coopResult, dumpPath, userId);

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());

    SysCoopJournal before = sysCoopJournalDao.selectByPK(expect.getCtlNo());
    SysCoopJournal actual = service.update(expect);

    assertThat(actual.getCtlNo(), is(1L));
    assertThat(actual.getAnaResult(), is(expect.getAnaResult()));
    assertThat(actual.getCoopResult(), is(expect.getCoopResult()));
    assertThat(actual.getDumpPath(), is(expect.getDumpPath()));
    assertThat(actual.getInAnaDate(), is(Timestamp.valueOf(getExpectTime())));
    assertThat(actual.getOutAnaDate(), is(Timestamp.valueOf(getExpectMockTime())));
    assertThat(actual.getInRegDate(), is(Timestamp.valueOf(getExpectTime())));
    assertThat(actual.getOutRegDate(), is(Timestamp.valueOf(getExpectTime())));
    assertThat(actual.getUserId(), is(expect.getUserId()));

    // 念のため、更新前と突き合わせて値が更新されていることを確認する
    assertNotEquals(actual.getAnaResult(), before.getAnaResult());
  }

  @Test()
  public void 正常系_ジャーナル更新_配信ステータスが処理中に変更されたら_配信開始日時が指定した日時に切り替わる() {
    Long ctlNo = 1L;
    String anaResult = AnaResult.UNPROCESS.getResult();
    String coopResult = CoopResult.PROCESSING.getResult();
    String dumpPath = "";
    Long userId = 123L;
    JournalUpdateRequest expect = 更新リクエストテストデータ作成(ctlNo, anaResult, coopResult, dumpPath, userId);

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());

    SysCoopJournal before = sysCoopJournalDao.selectByPK(expect.getCtlNo());
    SysCoopJournal actual = service.update(expect);

    assertThat(actual.getCtlNo(), is(1L));
    assertThat(actual.getAnaResult(), is(expect.getAnaResult()));
    assertThat(actual.getCoopResult(), is(expect.getCoopResult()));
    assertThat(actual.getDumpPath(), is(expect.getDumpPath()));
    assertThat(actual.getInAnaDate(), is(Timestamp.valueOf(getExpectTime())));
    assertThat(actual.getOutAnaDate(), is(Timestamp.valueOf(getExpectTime())));
    assertThat(actual.getInRegDate(), is(Timestamp.valueOf(getExpectMockTime())));
    assertThat(actual.getOutRegDate(), is(Timestamp.valueOf(getExpectTime())));
    assertThat(actual.getUserId(), is(expect.getUserId()));

    // 念のため、更新前と突き合わせて値が更新されていることを確認する
    assertNotEquals(actual.getCoopResult(), before.getCoopResult());
  }

  @Test()
  public void 正常系_ジャーナル更新_配信ステータスが処理完了に変更されたら_配信終了日時が指定した日時に切り替わる() {
    Long ctlNo = 1L;
    String anaResult = AnaResult.UNPROCESS.getResult();
    String coopResult = CoopResult.DONE.getResult();
    String dumpPath = "";
    Long userId = 123L;
    JournalUpdateRequest expect = 更新リクエストテストデータ作成(ctlNo, anaResult, coopResult, dumpPath, userId);

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());

    SysCoopJournal before = sysCoopJournalDao.selectByPK(expect.getCtlNo());
    SysCoopJournal actual = service.update(expect);

    assertThat(actual.getCtlNo(), is(1L));
    assertThat(actual.getAnaResult(), is(expect.getAnaResult()));
    assertThat(actual.getCoopResult(), is(expect.getCoopResult()));
    assertThat(actual.getDumpPath(), is(expect.getDumpPath()));
    assertThat(actual.getInAnaDate(), is(Timestamp.valueOf(getExpectTime())));
    assertThat(actual.getOutAnaDate(), is(Timestamp.valueOf(getExpectTime())));
    assertThat(actual.getInRegDate(), is(Timestamp.valueOf(getExpectTime())));
    assertThat(actual.getOutRegDate(), is(Timestamp.valueOf(getExpectMockTime())));
    assertThat(actual.getUserId(), is(expect.getUserId()));

    // 念のため、更新前と突き合わせて値が更新されていることを確認する
    assertNotEquals(actual.getCoopResult(), before.getCoopResult());
  }

  @Test()
  public void 正常系_ジャーナル更新_両方のステータスが処理中に変更されたら_両方の開始日時が指定した日時に切り替わる() {
    Long ctlNo = 1L;
    String anaResult = AnaResult.PROCESSING.getResult();
    String coopResult = CoopResult.PROCESSING.getResult();
    String dumpPath = "";
    Long userId = 123L;
    JournalUpdateRequest expect = 更新リクエストテストデータ作成(ctlNo, anaResult, coopResult, dumpPath, userId);

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());

    SysCoopJournal before = sysCoopJournalDao.selectByPK(expect.getCtlNo());
    SysCoopJournal actual = service.update(expect);

    assertThat(actual.getCtlNo(), is(1L));
    assertThat(actual.getAnaResult(), is(expect.getAnaResult()));
    assertThat(actual.getCoopResult(), is(expect.getCoopResult()));
    assertThat(actual.getDumpPath(), is(expect.getDumpPath()));
    assertThat(actual.getInAnaDate(), is(Timestamp.valueOf(getExpectMockTime())));
    assertThat(actual.getOutAnaDate(), is(Timestamp.valueOf(getExpectTime())));
    assertThat(actual.getInRegDate(), is(Timestamp.valueOf(getExpectMockTime())));
    assertThat(actual.getOutRegDate(), is(Timestamp.valueOf(getExpectTime())));
    assertThat(actual.getUserId(), is(expect.getUserId()));

    // 念のため、更新前と突き合わせて値が更新されていることを確認する
    assertNotEquals(actual.getAnaResult(), before.getAnaResult());
    assertNotEquals(actual.getCoopResult(), before.getCoopResult());
  }

  @Test()
  public void 正常系_ジャーナル更新_両方のステータスが処理完了に変更されたら_両方の終了日時が指定した日時に切り替わる() {
    Long ctlNo = 1L;
    String anaResult = AnaResult.DONE.getResult();
    String coopResult = CoopResult.DONE.getResult();
    String dumpPath = "";
    Long userId = 123L;
    JournalUpdateRequest expect = 更新リクエストテストデータ作成(ctlNo, anaResult, coopResult, dumpPath, userId);

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());

    SysCoopJournal before = sysCoopJournalDao.selectByPK(expect.getCtlNo());
    SysCoopJournal actual = service.update(expect);

    assertThat(actual.getCtlNo(), is(1L));
    assertThat(actual.getAnaResult(), is(expect.getAnaResult()));
    assertThat(actual.getCoopResult(), is(expect.getCoopResult()));
    assertThat(actual.getDumpPath(), is(expect.getDumpPath()));
    assertThat(actual.getInAnaDate(), is(Timestamp.valueOf(getExpectTime())));
    assertThat(actual.getOutAnaDate(), is(Timestamp.valueOf(getExpectMockTime())));
    assertThat(actual.getInRegDate(), is(Timestamp.valueOf(getExpectTime())));
    assertThat(actual.getOutRegDate(), is(Timestamp.valueOf(getExpectMockTime())));
    assertThat(actual.getUserId(), is(expect.getUserId()));

    // 念のため、更新前と突き合わせて値が更新されていることを確認する
    assertNotEquals(actual.getAnaResult(), before.getAnaResult());
    assertNotEquals(actual.getCoopResult(), before.getCoopResult());
  }

  @Test()
  public void 正常系_ジャーナル更新_リクエストの電文パスがnullだと電文パスが更新されない() {
    Long ctlNo = 1L;
    String anaResult = AnaResult.UNPROCESS.getResult();
    String coopResult = CoopResult.UNPROCESS.getResult();
    String dumpPath = null;
    Long userId = 123L;
    JournalUpdateRequest expect = 更新リクエストテストデータ作成(ctlNo, anaResult, coopResult, dumpPath, userId);

    SysCoopJournal actual = service.update(expect);

    assertThat(actual.getCtlNo(), is(1L));
    assertThat(actual.getAnaResult(), is(expect.getAnaResult()));
    assertThat(actual.getCoopResult(), is(expect.getCoopResult()));
    assertNotEquals(actual.getDumpPath(), is(expect.getDumpPath()));
    assertThat(actual.getInAnaDate(), is(Timestamp.valueOf(getExpectTime())));
    assertThat(actual.getOutAnaDate(), is(Timestamp.valueOf(getExpectTime())));
    assertThat(actual.getInRegDate(), is(Timestamp.valueOf(getExpectTime())));
    assertThat(actual.getOutRegDate(), is(Timestamp.valueOf(getExpectTime())));
    assertThat(actual.getUserId(), is(expect.getUserId()));
  }


  @Test()
  public void 正常系_ジャーナル更新_リクエストの変換ステータスがnullだと変換ステータスが更新されない() {
    Long ctlNo = 1L;
    String anaResult = null;
    String coopResult = CoopResult.UNPROCESS.getResult();
    String dumpPath = "";
    Long userId = 123L;
    JournalUpdateRequest expect = 更新リクエストテストデータ作成(ctlNo, anaResult, coopResult, dumpPath, userId);

    SysCoopJournal actual = service.update(expect);

    assertNotEquals(actual.getAnaResult(), is(expect.getAnaResult()));
    assertThat(actual.getCoopResult(), is(expect.getCoopResult()));
    assertThat(actual.getDumpPath(), is(expect.getDumpPath()));
    assertThat(actual.getInAnaDate(), is(Timestamp.valueOf(getExpectTime())));
    assertThat(actual.getOutAnaDate(), is(Timestamp.valueOf(getExpectTime())));
    assertThat(actual.getInRegDate(), is(Timestamp.valueOf(getExpectTime())));
    assertThat(actual.getOutRegDate(), is(Timestamp.valueOf(getExpectTime())));
    assertThat(actual.getUserId(), is(expect.getUserId()));
  }


  @Test()
  public void 正常系_ジャーナル更新_リクエストの配信ステータスがnullだと配信ステータスが更新されない() {
    Long ctlNo = 1L;
    String anaResult = AnaResult.UNPROCESS.getResult();
    String coopResult = null;
    String dumpPath = "";
    Long userId = 123L;
    JournalUpdateRequest expect = 更新リクエストテストデータ作成(ctlNo, anaResult, coopResult, dumpPath, userId);

    SysCoopJournal actual = service.update(expect);

    assertThat(actual.getCtlNo(), is(1L));
    assertThat(actual.getAnaResult(), is(expect.getAnaResult()));
    assertNotEquals(actual.getCoopResult(), is(expect.getCoopResult()));
    assertThat(actual.getDumpPath(), is(expect.getDumpPath()));
    assertThat(actual.getInAnaDate(), is(Timestamp.valueOf(getExpectTime())));
    assertThat(actual.getOutAnaDate(), is(Timestamp.valueOf(getExpectTime())));
    assertThat(actual.getInRegDate(), is(Timestamp.valueOf(getExpectTime())));
    assertThat(actual.getOutRegDate(), is(Timestamp.valueOf(getExpectTime())));
    assertThat(actual.getUserId(), is(expect.getUserId()));
  }

  @Test
  public void 正常系_ジャーナル作成_全てのリクエストパラメータ通り正しく登録されている_indexなし() {
    Long ordNo = 100L;
    String coopOrdNo = "101";
    String hospPatId = "200";
    Long patId = 201L;
    String message64 = "VEVTVF9NT0NL";
    String anaResult = AnaResult.UNPROCESS.getResult();
    String coopResult = CoopResult.UNPROCESS.getResult();
    Long userId = 123L;
    String baseDate = "20200202";
    Timestamp tsBaseDate = Timestamp.valueOf("2020-02-02 00:00:00.0");

    // シーケンスはモック化
    given(sysCoopJournalDao.selectNextSeqCtlNo()).willReturn(2L);

    JournalCreateRequest expect = 作成リクエストテストデータ作成(ordNo, coopOrdNo, hospPatId, patId, message64, anaResult, coopResult, userId, baseDate);
    List<SysCoopJournal> actuals = service.insert(expect);

    assertThat(actuals.size(), is(1));

    SysCoopJournal actual = actuals.get(0);

    assertThat(actual.getFacilityCd(), is(expect.getFacilityCd()));
    assertThat(actual.getCtlNo(), is(2L));
    assertThat(actual.getCoopCd(), is(expect.getCoopCd()));
    assertThat(actual.getCoopCdIndex(), is(expect.getCoopCdIndex()));
    assertThat(actual.getCrud(), is(expect.getCrud()));
    assertThat(actual.getDirection(), is(expect.getDirection()));
    assertThat(actual.getOrdNo(), is(expect.getOrdNo()));
    assertThat(actual.getCoopOrdNo(), is(expect.getCoopOrdNo()));
    assertThat(actual.getHospPatId(), is(expect.getHospPatId()));
    assertThat(actual.getPatId(), is(expect.getPatId()));
    assertThat(actual.getAnaResult(), is(expect.getAnaResult()));
    assertThat(actual.getCoopResult(), is(expect.getCoopResult()));
    assertThat(actual.getDump(), is(Base64.getDecoder().decode(expect.getMessage64().getBytes())));
    assertThat(actual.getInAnaDate(), is(nullValue()));
    assertThat(actual.getOutAnaDate(), is(nullValue()));
    assertThat(actual.getInRegDate(), is(nullValue()));
    assertThat(actual.getOutRegDate(), is(nullValue()));
    assertThat(actual.getUserId(), is(expect.getUserId()));
    assertThat(actual.getBaseDate(), is(tsBaseDate));
  }


  @Test
  public void 正常系_ジャーナル作成_全てのリクエストパラメータ通り正しく登録されている_indexあり() {
    Long ordNo = 100L;
    String coopOrdNo = "101";
    String hospPatId = "200";
    Long patId = 201L;
    String message64 = "VEVTVF9NT0NL";
    String anaResult = AnaResult.UNPROCESS.getResult();
    String coopResult = CoopResult.UNPROCESS.getResult();
    Long userId = 123L;
    String baseDate = "20200202";
    Timestamp tsBaseDate = Timestamp.valueOf("2020-02-02 00:00:00.0");

    // シーケンスはモック化
    //given(sysCoopJournalDao.selectNextSeqCtlNo()).willReturn(2L);

    JournalCreateRequest expect = 作成リクエストテストデータ作成(ordNo, coopOrdNo, hospPatId, patId, message64, anaResult, coopResult, userId, baseDate);
    expect.setCoopCd("0");      // indexありのcoopCd
    List<SysCoopJournal> actuals = service.insert(expect);

    assertThat(actuals.size(), is(2));

    SysCoopJournal actual = actuals.get(0);
    SysCoopJournal actual_index = actuals.get(1);

    // indexなしのチェック
    assertThat(actual.getFacilityCd(), is(expect.getFacilityCd()));
    assertThat(actual.getCoopCd(), is(expect.getCoopCd()));
    assertThat(actual.getCoopCdIndex(), is(expect.getCoopCdIndex()));
    assertThat(actual.getCrud(), is(expect.getCrud()));
    assertThat(actual.getDirection(), is(expect.getDirection()));
    assertThat(actual.getOrdNo(), is(expect.getOrdNo()));
    assertThat(actual.getCoopOrdNo(), is(expect.getCoopOrdNo()));
    assertThat(actual.getHospPatId(), is(expect.getHospPatId()));
    assertThat(actual.getPatId(), is(expect.getPatId()));
    assertThat(actual.getAnaResult(), is(expect.getAnaResult()));
    assertThat(actual.getCoopResult(), is(expect.getCoopResult()));
    assertThat(actual.getDump(), is(Base64.getDecoder().decode(expect.getMessage64().getBytes())));
    assertThat(actual.getInAnaDate(), is(nullValue()));
    assertThat(actual.getOutAnaDate(), is(nullValue()));
    assertThat(actual.getInRegDate(), is(nullValue()));
    assertThat(actual.getOutRegDate(), is(nullValue()));
    assertThat(actual.getUserId(), is(expect.getUserId()));

    assertThat(actual.getFacilityCd(), is(actual_index.getFacilityCd()));
    assertThat(actual.getCoopCd(), is(actual_index.getCoopCd()));
    assertThat(actual_index.getCoopCdIndex(), is("index"));
    assertThat(actual.getCrud(), is(actual_index.getCrud()));
    assertThat(actual.getDirection(), is(actual_index.getDirection()));
    assertThat(actual.getOrdNo(), is(actual_index.getOrdNo()));
    assertThat(actual.getCoopOrdNo(), is(actual_index.getCoopOrdNo()));
    assertThat(actual.getHospPatId(), is(actual_index.getHospPatId()));
    assertThat(actual.getPatId(), is(actual_index.getPatId()));
    assertThat(actual.getAnaResult(), is(actual_index.getAnaResult()));
    assertThat(actual.getCoopResult(), is(actual_index.getCoopResult()));
    assertThat(actual.getDump(), is(actual_index.getDump()));
    assertThat(actual.getInAnaDate(), is(actual_index.getInAnaDate()));
    assertThat(actual.getOutAnaDate(), is(actual_index.getInAnaDate()));
    assertThat(actual.getInRegDate(), is(actual_index.getInAnaDate()));
    assertThat(actual.getOutRegDate(), is(actual_index.getInAnaDate()));
    assertThat(actual.getUserId(), is(actual_index.getUserId()));
    assertThat(actual.getBaseDate(), is(tsBaseDate));
  }

  @Test
  public void 正常系_ジャーナル作成_オーダ番号や患者番号がnullの場合は0で登録される() {
    Long ordNo = null;
    String coopOrdNo = null;
    String hospPatId = null;
    Long patId = null;
    String message64 = "VEVTVF9NT0NL";
    String anaResult = AnaResult.UNPROCESS.getResult();
    String coopResult = CoopResult.UNPROCESS.getResult();
    Long userId = 123L;
    String baseDate = "20200202";
    Timestamp tsBaseDate = Timestamp.valueOf("2020-02-02 00:00:00.0");

    // シーケンスはモック化
    given(sysCoopJournalDao.selectNextSeqCtlNo()).willReturn(2L);

    JournalCreateRequest expect = 作成リクエストテストデータ作成(ordNo, coopOrdNo, hospPatId, patId, message64, anaResult, coopResult, userId, baseDate);
    List<SysCoopJournal> actuals = service.insert(expect);

    assertThat(actuals.size(), is(1));
    SysCoopJournal actual = actuals.get(0);

    assertThat(actual.getFacilityCd(), is(expect.getFacilityCd()));
    assertThat(actual.getCtlNo(), is(2L));
    assertThat(actual.getCoopCd(), is(expect.getCoopCd()));
    assertThat(actual.getCoopCdIndex(), is(expect.getCoopCdIndex()));
    assertThat(actual.getCrud(), is(expect.getCrud()));
    assertThat(actual.getDirection(), is(expect.getDirection()));
    assertThat(actual.getOrdNo(), is(0L));
    assertThat(actual.getCoopOrdNo(), is("0"));
    assertThat(actual.getHospPatId(), is("0"));
    assertThat(actual.getPatId(), is(0L));
    assertThat(actual.getAnaResult(), is(expect.getAnaResult()));
    assertThat(actual.getCoopResult(), is(expect.getCoopResult()));
    assertThat(actual.getDump(), is(Base64.getDecoder().decode(expect.getMessage64().getBytes())));
    assertThat(actual.getInAnaDate(), is(nullValue()));
    assertThat(actual.getOutAnaDate(), is(nullValue()));
    assertThat(actual.getInRegDate(), is(nullValue()));
    assertThat(actual.getOutRegDate(), is(nullValue()));
    assertThat(actual.getUserId(), is(expect.getUserId()));
    assertThat(actual.getBaseDate(), is(tsBaseDate));
  }

  @Test
  public void 正常系_ジャーナル作成_電文がnullで登録される() {
    Long ordNo = 100L;
    String coopOrdNo = "101";
    String hospPatId = "200";
    Long patId = 201L;
    String message64 = null;
    String anaResult = AnaResult.UNPROCESS.getResult();
    String coopResult = CoopResult.UNPROCESS.getResult();
    Long userId = 123L;
    String baseDate = "20200202";
    Timestamp tsBaseDate = Timestamp.valueOf("2020-02-02 00:00:00.0");

    // シーケンスはモック化
    given(sysCoopJournalDao.selectNextSeqCtlNo()).willReturn(2L);

    JournalCreateRequest expect = 作成リクエストテストデータ作成(ordNo, coopOrdNo, hospPatId, patId, message64, anaResult, coopResult, userId, baseDate);
    List<SysCoopJournal> actuals = service.insert(expect);

    assertThat(actuals.size(), is(1));
    SysCoopJournal actual = actuals.get(0);

    assertThat(actual.getFacilityCd(), is(expect.getFacilityCd()));
    assertThat(actual.getCtlNo(), is(2L));
    assertThat(actual.getCoopCd(), is(expect.getCoopCd()));
    assertThat(actual.getCoopCdIndex(), is(expect.getCoopCdIndex()));
    assertThat(actual.getCrud(), is(expect.getCrud()));
    assertThat(actual.getDirection(), is(expect.getDirection()));
    assertThat(actual.getOrdNo(), is(expect.getOrdNo()));
    assertThat(actual.getCoopOrdNo(), is(expect.getCoopOrdNo()));
    assertThat(actual.getHospPatId(), is(expect.getHospPatId()));
    assertThat(actual.getPatId(), is(expect.getPatId()));
    assertThat(actual.getAnaResult(), is(expect.getAnaResult()));
    assertThat(actual.getCoopResult(), is(expect.getCoopResult()));
    assertThat(actual.getDump(), is(nullValue()));
    assertThat(actual.getInAnaDate(), is(nullValue()));
    assertThat(actual.getOutAnaDate(), is(nullValue()));
    assertThat(actual.getInRegDate(), is(nullValue()));
    assertThat(actual.getOutRegDate(), is(nullValue()));
    assertThat(actual.getUserId(), is(expect.getUserId()));
    assertThat(actual.getBaseDate(), is(tsBaseDate));
  }

  @Test
  public void 正常系_ジャーナル作成_変換ステータスが処理中で登録されたら_変換開始日時が指定した日時で登録される() {
    Long ordNo = 100L;
    String coopOrdNo = "101";
    String hospPatId = "200";
    Long patId = 201L;
    String message64 = null;
    String anaResult = AnaResult.PROCESSING.getResult();
    String coopResult = CoopResult.UNPROCESS.getResult();
    Long userId = 123L;
    String baseDate = "20200202";
    Timestamp tsBaseDate = Timestamp.valueOf("2020-02-02 00:00:00.0");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    // シーケンスはモック化
    given(sysCoopJournalDao.selectNextSeqCtlNo()).willReturn(2L);

    JournalCreateRequest expect = 作成リクエストテストデータ作成(ordNo, coopOrdNo, hospPatId, patId, message64, anaResult, coopResult, userId, baseDate);
    List<SysCoopJournal> actuals = service.insert(expect);

    assertThat(actuals.size(), is(1));
    SysCoopJournal actual = actuals.get(0);

    assertThat(actual.getFacilityCd(), is(expect.getFacilityCd()));
    assertThat(actual.getCtlNo(), is(2L));
    assertThat(actual.getCoopCd(), is(expect.getCoopCd()));
    assertThat(actual.getCoopCdIndex(), is(expect.getCoopCdIndex()));
    assertThat(actual.getCrud(), is(expect.getCrud()));
    assertThat(actual.getDirection(), is(expect.getDirection()));
    assertThat(actual.getOrdNo(), is(expect.getOrdNo()));
    assertThat(actual.getCoopOrdNo(), is(expect.getCoopOrdNo()));
    assertThat(actual.getHospPatId(), is(expect.getHospPatId()));
    assertThat(actual.getPatId(), is(expect.getPatId()));
    assertThat(actual.getAnaResult(), is(expect.getAnaResult()));
    assertThat(actual.getCoopResult(), is(expect.getCoopResult()));
    assertThat(actual.getDump(), is(nullValue()));
    assertThat(actual.getInAnaDate(), is(Timestamp.valueOf(getExpectMockTime())));
    assertThat(actual.getOutAnaDate(), is(nullValue()));
    assertThat(actual.getInRegDate(), is(nullValue()));
    assertThat(actual.getOutRegDate(), is(nullValue()));
    assertThat(actual.getUserId(), is(expect.getUserId()));
    assertThat(actual.getBaseDate(), is(tsBaseDate));
  }

  @Test
  public void 正常系_ジャーナル作成_変換ステータスが処理完了で登録されたら_変換終了日時が指定した日時で登録される() {
    Long ordNo = 100L;
    String coopOrdNo = "101";
    String hospPatId = "200";
    Long patId = 201L;
    String message64 = null;
    String anaResult = AnaResult.DONE.getResult();
    String coopResult = CoopResult.UNPROCESS.getResult();
    Long userId = 123L;
    String baseDate = "20200202";
    Timestamp tsBaseDate = Timestamp.valueOf("2020-02-02 00:00:00.0");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    // シーケンスはモック化
    given(sysCoopJournalDao.selectNextSeqCtlNo()).willReturn(2L);

    JournalCreateRequest expect = 作成リクエストテストデータ作成(ordNo, coopOrdNo, hospPatId, patId, message64, anaResult, coopResult, userId, baseDate);
    List<SysCoopJournal> actuals = service.insert(expect);

    assertThat(actuals.size(), is(1));
    SysCoopJournal actual = actuals.get(0);

    assertThat(actual.getFacilityCd(), is(expect.getFacilityCd()));
    assertThat(actual.getCtlNo(), is(2L));
    assertThat(actual.getCoopCd(), is(expect.getCoopCd()));
    assertThat(actual.getCoopCdIndex(), is(expect.getCoopCdIndex()));
    assertThat(actual.getCrud(), is(expect.getCrud()));
    assertThat(actual.getDirection(), is(expect.getDirection()));
    assertThat(actual.getOrdNo(), is(expect.getOrdNo()));
    assertThat(actual.getCoopOrdNo(), is(expect.getCoopOrdNo()));
    assertThat(actual.getHospPatId(), is(expect.getHospPatId()));
    assertThat(actual.getPatId(), is(expect.getPatId()));
    assertThat(actual.getAnaResult(), is(expect.getAnaResult()));
    assertThat(actual.getCoopResult(), is(expect.getCoopResult()));
    assertThat(actual.getDump(), is(nullValue()));
    assertThat(actual.getInAnaDate(), is(nullValue()));
    assertThat(actual.getOutAnaDate(), is(Timestamp.valueOf(getExpectMockTime())));
    assertThat(actual.getInRegDate(), is(nullValue()));
    assertThat(actual.getOutRegDate(), is(nullValue()));
    assertThat(actual.getUserId(), is(expect.getUserId()));
    assertThat(actual.getBaseDate(), is(tsBaseDate));
  }

  @Test
  public void 正常系_ジャーナル作成_配信ステータスが処理中で登録されたら_配信開始日時が指定した日時で登録される() {
    Long ordNo = 100L;
    String coopOrdNo = "101";
    String hospPatId = "200";
    Long patId = 201L;
    String message64 = null;
    String anaResult = AnaResult.UNPROCESS.getResult();
    String coopResult = CoopResult.PROCESSING.getResult();
    Long userId = 123L;
    String baseDate = "20200202";
    Timestamp tsBaseDate = Timestamp.valueOf("2020-02-02 00:00:00.0");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    // シーケンスはモック化
    given(sysCoopJournalDao.selectNextSeqCtlNo()).willReturn(2L);

    JournalCreateRequest expect = 作成リクエストテストデータ作成(ordNo, coopOrdNo, hospPatId, patId, message64, anaResult, coopResult, userId, baseDate);
    List<SysCoopJournal> actuals = service.insert(expect);

    assertThat(actuals.size(), is(1));
    SysCoopJournal actual = actuals.get(0);

    assertThat(actual.getFacilityCd(), is(expect.getFacilityCd()));
    assertThat(actual.getCtlNo(), is(2L));
    assertThat(actual.getCoopCd(), is(expect.getCoopCd()));
    assertThat(actual.getCoopCdIndex(), is(expect.getCoopCdIndex()));
    assertThat(actual.getCrud(), is(expect.getCrud()));
    assertThat(actual.getDirection(), is(expect.getDirection()));
    assertThat(actual.getOrdNo(), is(expect.getOrdNo()));
    assertThat(actual.getCoopOrdNo(), is(expect.getCoopOrdNo()));
    assertThat(actual.getHospPatId(), is(expect.getHospPatId()));
    assertThat(actual.getPatId(), is(expect.getPatId()));
    assertThat(actual.getAnaResult(), is(expect.getAnaResult()));
    assertThat(actual.getCoopResult(), is(expect.getCoopResult()));
    assertThat(actual.getDump(), is(nullValue()));
    assertThat(actual.getInAnaDate(), is(nullValue()));
    assertThat(actual.getOutAnaDate(), is(nullValue()));
    assertThat(actual.getInRegDate(), is(Timestamp.valueOf(getExpectMockTime())));
    assertThat(actual.getOutRegDate(), is(nullValue()));
    assertThat(actual.getUserId(), is(expect.getUserId()));
    assertThat(actual.getBaseDate(), is(tsBaseDate));
  }

  @Test
  public void 正常系_ジャーナル作成_配信ステータスが処理完了で登録されたら_配信終了日時が指定した日時で登録される() {
    Long ordNo = 100L;
    String coopOrdNo = "101";
    String hospPatId = "200";
    Long patId = 201L;
    String message64 = null;
    String anaResult = AnaResult.UNPROCESS.getResult();
    String coopResult = CoopResult.DONE.getResult();
    Long userId = 123L;
    String baseDate = "20200202";
    Timestamp tsBaseDate = Timestamp.valueOf("2020-02-02 00:00:00.0");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    // シーケンスはモック化
    given(sysCoopJournalDao.selectNextSeqCtlNo()).willReturn(2L);

    JournalCreateRequest expect = 作成リクエストテストデータ作成(ordNo, coopOrdNo, hospPatId, patId, message64, anaResult, coopResult, userId, baseDate);
    List<SysCoopJournal> actuals = service.insert(expect);

    assertThat(actuals.size(), is(1));
    SysCoopJournal actual = actuals.get(0);

    assertThat(actual.getFacilityCd(), is(expect.getFacilityCd()));
    assertThat(actual.getCtlNo(), is(2L));
    assertThat(actual.getCoopCd(), is(expect.getCoopCd()));
    assertThat(actual.getCoopCdIndex(), is(expect.getCoopCdIndex()));
    assertThat(actual.getCrud(), is(expect.getCrud()));
    assertThat(actual.getDirection(), is(expect.getDirection()));
    assertThat(actual.getOrdNo(), is(expect.getOrdNo()));
    assertThat(actual.getCoopOrdNo(), is(expect.getCoopOrdNo()));
    assertThat(actual.getHospPatId(), is(expect.getHospPatId()));
    assertThat(actual.getPatId(), is(expect.getPatId()));
    assertThat(actual.getAnaResult(), is(expect.getAnaResult()));
    assertThat(actual.getCoopResult(), is(expect.getCoopResult()));
    assertThat(actual.getDump(), is(nullValue()));
    assertThat(actual.getInAnaDate(), is(nullValue()));
    assertThat(actual.getOutAnaDate(), is(nullValue()));
    assertThat(actual.getInRegDate(), is(nullValue()));
    assertThat(actual.getOutRegDate(), is(Timestamp.valueOf(getExpectMockTime())));
    assertThat(actual.getUserId(), is(expect.getUserId()));
    assertThat(actual.getBaseDate(), is(tsBaseDate));
  }
  @Sql("classpath:resource.script/JournalServiceImplTest/JournalServiceImplTest.coopOrdNo.db5.before.sql")
  @Test
  public void 正常系_ジャーナル作成_連携オーダー番号が該当したら_該当する連携オーダ番号で登録される() {
    Long ordNo = 100L;
    String coopOrdNo = "101";
    String hospPatId = "200";
    Long patId = 201L;
    String message64 = null;
    String anaResult = AnaResult.UNPROCESS.getResult();
    String coopResult = CoopResult.UNPROCESS.getResult();
    Long userId = 123L;
    String baseDate = "20200202";
    Timestamp tsBaseDate = Timestamp.valueOf("2020-02-02 00:00:00.0");

    // シーケンスはモック化
    given(sysCoopJournalDao.selectNextSeqCtlNo()).willReturn(2L);

    JournalCreateRequest expect = 作成リクエストテストデータ作成(ordNo, coopOrdNo, hospPatId, patId, message64, anaResult, coopResult, userId, baseDate);
    List<SysCoopJournal> actuals = service.insert(expect);

    SysCoopJournal actual = actuals.get(0);

    assertThat(actual.getFacilityCd(), is(expect.getFacilityCd()));
    assertThat(actual.getCtlNo(), is(2L));
    assertThat(actual.getCoopCd(), is(expect.getCoopCd()));
    assertThat(actual.getCoopCdIndex(), is(expect.getCoopCdIndex()));
    assertThat(actual.getCrud(), is(expect.getCrud()));
    assertThat(actual.getDirection(), is(expect.getDirection()));
    assertThat(actual.getOrdNo(), is(expect.getOrdNo()));
    assertThat(actual.getCoopOrdNo(), is("A0000000002Z"));
    assertThat(actual.getHospPatId(), is(expect.getHospPatId()));
    assertThat(actual.getPatId(), is(expect.getPatId()));
    assertThat(actual.getAnaResult(), is(expect.getAnaResult()));
    assertThat(actual.getCoopResult(), is(expect.getCoopResult()));
    assertThat(actual.getDump(), is(nullValue()));
    assertThat(actual.getInAnaDate(), is(nullValue()));
    assertThat(actual.getOutAnaDate(), is(nullValue()));
    assertThat(actual.getInRegDate(), is(nullValue()));
    assertThat(actual.getOutRegDate(), is(nullValue()));
    assertThat(actual.getUserId(), is(expect.getUserId()));
    assertThat(actual.getBaseDate(), is(tsBaseDate));
  }

  @Sql("classpath:resource.script/JournalServiceImplTest/JournalServiceImplTest.coopOrdNo.db5.before.sql")
  @Test
  public void 正常系_ジャーナル作成_オーダ番号連携対象_区分が新規以外で現在の連携オーダ番号があるため同じ値を使用する() {
    Long ordNo = 100L;
    String coopOrdNo = "101";
    String hospPatId = "200";
    Long patId = 201L;
    String message64 = null;
    String anaResult = AnaResult.UNPROCESS.getResult();
    String coopResult = CoopResult.UNPROCESS.getResult();
    Long userId = 123L;
    String crud = "U";
    String baseDate = "20200202";
    Timestamp tsBaseDate = Timestamp.valueOf("2020-02-02 00:00:00.0");

    // シーケンスはモック化
    given(sysCoopJournalDao.selectNextSeqCtlNo()).willReturn(2L);

    JournalCreateRequest expect = 作成リクエストテストデータ作成(
      crud, ordNo, coopOrdNo, hospPatId, patId, message64, anaResult, coopResult, userId, baseDate);
    List<SysCoopJournal> actuals = service.insert(expect);

    SysCoopJournal actual = actuals.get(0);

    assertThat(actual.getFacilityCd(), is(expect.getFacilityCd()));
    assertThat(actual.getCtlNo(), is(2L));
    assertThat(actual.getCoopCd(), is(expect.getCoopCd()));
    assertThat(actual.getCoopCdIndex(), is(expect.getCoopCdIndex()));
    assertThat(actual.getCrud(), is(expect.getCrud()));
    assertThat(actual.getDirection(), is(expect.getDirection()));
    assertThat(actual.getOrdNo(), is(expect.getOrdNo()));
    assertThat(actual.getCoopOrdNo(), is("A0000000001Z"));
    assertThat(actual.getHospPatId(), is(expect.getHospPatId()));
    assertThat(actual.getPatId(), is(expect.getPatId()));
    assertThat(actual.getAnaResult(), is(expect.getAnaResult()));
    assertThat(actual.getCoopResult(), is(expect.getCoopResult()));
    assertThat(actual.getDump(), is(nullValue()));
    assertThat(actual.getInAnaDate(), is(nullValue()));
    assertThat(actual.getOutAnaDate(), is(nullValue()));
    assertThat(actual.getInRegDate(), is(nullValue()));
    assertThat(actual.getOutRegDate(), is(nullValue()));
    assertThat(actual.getUserId(), is(expect.getUserId()));
    assertThat(actual.getBaseDate(), is(tsBaseDate));

    verify(ordCoopNoDao, times(0)).updateIsDelIsDisp(any(), anyString(), any(), anyString(), anyString(), any(), anyString(), anyString());
    verify(sysCoopNoDao, times(0)).updateCurCoopOrdNo(any(), any(), any());
  }

  @Sql("classpath:resource.script/JournalServiceImplTest/JournalServiceImplTest.coopOrdNo.db5.before.sql")
  @Test
  public void 正常系_ジャーナル作成_オーダ番号連携対象_区分が新規以外で現在の連携オーダ番号がないため採番する() {
    Long ordNo = 100L;
    String coopOrdNo = "101";
    String hospPatId = "200";
    Long patId = 202L;
    String message64 = null;
    String anaResult = AnaResult.UNPROCESS.getResult();
    String coopResult = CoopResult.UNPROCESS.getResult();
    Long userId = 123L;
    String crud = "U";
    String baseDate = "20200202";
    Timestamp tsBaseDate = Timestamp.valueOf("2020-02-02 00:00:00.0");

    // シーケンスはモック化
    given(sysCoopJournalDao.selectNextSeqCtlNo()).willReturn(2L);

    JournalCreateRequest expect = 作成リクエストテストデータ作成(
      crud, ordNo, coopOrdNo, hospPatId, patId, message64, anaResult, coopResult, userId, baseDate);
    List<SysCoopJournal> actuals = service.insert(expect);

    SysCoopJournal actual = actuals.get(0);

    assertThat(actual.getFacilityCd(), is(expect.getFacilityCd()));
    assertThat(actual.getCtlNo(), is(2L));
    assertThat(actual.getCoopCd(), is(expect.getCoopCd()));
    assertThat(actual.getCoopCdIndex(), is(expect.getCoopCdIndex()));
    assertThat(actual.getCrud(), is(expect.getCrud()));
    assertThat(actual.getDirection(), is(expect.getDirection()));
    assertThat(actual.getOrdNo(), is(expect.getOrdNo()));
    assertThat(actual.getCoopOrdNo(), is("A0000000003Z"));
    assertThat(actual.getHospPatId(), is(expect.getHospPatId()));
    assertThat(actual.getPatId(), is(expect.getPatId()));
    assertThat(actual.getAnaResult(), is(expect.getAnaResult()));
    assertThat(actual.getCoopResult(), is(expect.getCoopResult()));
    assertThat(actual.getDump(), is(nullValue()));
    assertThat(actual.getInAnaDate(), is(nullValue()));
    assertThat(actual.getOutAnaDate(), is(nullValue()));
    assertThat(actual.getInRegDate(), is(nullValue()));
    assertThat(actual.getOutRegDate(), is(nullValue()));
    assertThat(actual.getUserId(), is(expect.getUserId()));
    assertThat(actual.getBaseDate(), is(tsBaseDate));

    verify(ordCoopNoDao, times(1)).updateIsDelIsDisp(any(), anyString(), any(), anyString(), anyString(), any(), anyString(), anyString());
    verify(sysCoopNoDao, times(1)).updateCurCoopOrdNo(any(), any(), any());
  }

  @Sql("classpath:resource.script/JournalServiceImplTest/JournalServiceImplTest.coopOrdNo.db5.before.sql")
  @Test
  public void 正常系_ジャーナル作成_オーダ番号連携対象_区分が削除のため今回は同じ値を使用し次回は採番する() {
    Long ordNo = 100L;
    String coopOrdNo = "101";
    String hospPatId = "200";
    Long patId = 201L;
    String message64 = null;
    String anaResult = AnaResult.UNPROCESS.getResult();
    String coopResult = CoopResult.UNPROCESS.getResult();
    Long userId = 123L;
    String crud = "D";
    String baseDate = "20200202";
    Timestamp tsBaseDate = Timestamp.valueOf("2020-02-02 00:00:00.0");

    // シーケンスはモック化
    given(sysCoopJournalDao.selectNextSeqCtlNo())
      .willReturn(2L)
      .willReturn(3L);

    // 新規以外で現在の連携オーダ番号があるため同じ値を使用する
    JournalCreateRequest expect = 作成リクエストテストデータ作成(
      crud, ordNo, coopOrdNo, hospPatId, patId, message64, anaResult, coopResult, userId, baseDate);
    List<SysCoopJournal> actuals = service.insert(expect);

    SysCoopJournal actual = actuals.get(0);

    assertThat(actual.getFacilityCd(), is(expect.getFacilityCd()));
    assertThat(actual.getCtlNo(), is(2L));
    assertThat(actual.getCoopCd(), is(expect.getCoopCd()));
    assertThat(actual.getCoopCdIndex(), is(expect.getCoopCdIndex()));
    assertThat(actual.getCrud(), is(expect.getCrud()));
    assertThat(actual.getDirection(), is(expect.getDirection()));
    assertThat(actual.getOrdNo(), is(expect.getOrdNo()));
    assertThat(actual.getCoopOrdNo(), is("A0000000001Z"));
    assertThat(actual.getHospPatId(), is(expect.getHospPatId()));
    assertThat(actual.getPatId(), is(expect.getPatId()));
    assertThat(actual.getAnaResult(), is(expect.getAnaResult()));
    assertThat(actual.getCoopResult(), is(expect.getCoopResult()));
    assertThat(actual.getDump(), is(nullValue()));
    assertThat(actual.getInAnaDate(), is(nullValue()));
    assertThat(actual.getOutAnaDate(), is(nullValue()));
    assertThat(actual.getInRegDate(), is(nullValue()));
    assertThat(actual.getOutRegDate(), is(nullValue()));
    assertThat(actual.getUserId(), is(expect.getUserId()));
    assertThat(actual.getBaseDate(), is(tsBaseDate));

    verify(ordCoopNoDao, times(1)).updateIsDelIsDisp(any(), anyString(), any(), anyString(), anyString(), any(), anyString(), anyString());
    verify(sysCoopNoDao, times(0)).updateCurCoopOrdNo(any(), any(), any());

    // 次回は 新規以外の場合でも 現在の連携オーダ番号を使用せず採番する
    crud = "U";
    expect = 作成リクエストテストデータ作成(
      crud, ordNo, coopOrdNo, hospPatId, patId, message64, anaResult, coopResult, userId, baseDate);
    actuals = service.insert(expect);
    actual = actuals.get(0);

    assertThat(actual.getFacilityCd(), is(expect.getFacilityCd()));
    assertThat(actual.getCtlNo(), is(3L));
    assertThat(actual.getCoopCd(), is(expect.getCoopCd()));
    assertThat(actual.getCoopCdIndex(), is(expect.getCoopCdIndex()));
    assertThat(actual.getCrud(), is(expect.getCrud()));
    assertThat(actual.getDirection(), is(expect.getDirection()));
    assertThat(actual.getOrdNo(), is(expect.getOrdNo()));
    assertThat(actual.getCoopOrdNo(), is("A0000000002Z"));
    assertThat(actual.getHospPatId(), is(expect.getHospPatId()));
    assertThat(actual.getPatId(), is(expect.getPatId()));
    assertThat(actual.getAnaResult(), is(expect.getAnaResult()));
    assertThat(actual.getCoopResult(), is(expect.getCoopResult()));
    assertThat(actual.getDump(), is(nullValue()));
    assertThat(actual.getInAnaDate(), is(nullValue()));
    assertThat(actual.getOutAnaDate(), is(nullValue()));
    assertThat(actual.getInRegDate(), is(nullValue()));
    assertThat(actual.getOutRegDate(), is(nullValue()));
    assertThat(actual.getUserId(), is(expect.getUserId()));
    assertThat(actual.getBaseDate(), is(tsBaseDate));

    verify(ordCoopNoDao, times(2)).updateIsDelIsDisp(any(), anyString(), any(), anyString(), anyString(), any(), anyString(), anyString());
    verify(sysCoopNoDao, times(1)).updateCurCoopOrdNo(any(), any(), any());
  }

  @Test(expected = NotExistException.class)
  public void 異常系_ジャーナル作成_検索対象となる連携設定データが存在しないのでthrowされる() {
    Long ordNo = 100L;
    String coopOrdNo = "101";
    String hospPatId = "200";
    Long patId = 201L;
    String message64 = "VEVTVF9NT0NL";
    String anaResult = AnaResult.UNPROCESS.getResult();
    String coopResult = CoopResult.UNPROCESS.getResult();
    Long userId = 123L;
    // 連携設定マスタに レコードが存在しない
    String facilityCd = "TEST02";
    String baseDate = "20200202";

    // シーケンスはモック化
    given(sysCoopJournalDao.selectNextSeqCtlNo()).willReturn(2L);

    JournalCreateRequest expect = 作成リクエストテストデータ作成(ordNo, coopOrdNo, hospPatId, patId, message64, anaResult, coopResult, userId, baseDate);
    expect.setFacilityCd(facilityCd);

    service.insert(expect);
  }

  @Test(expected = NotExistException.class)
  public void 異常系_ジャーナル作成_連携対象の電文種別ではないのでthrowされる() {
    Long ordNo = 100L;
    String coopOrdNo = "101";
    String hospPatId = "200";
    Long patId = 201L;
    String message64 = "VEVTVF9NT0NL";
    String anaResult = AnaResult.UNPROCESS.getResult();
    String coopResult = CoopResult.UNPROCESS.getResult();
    Long userId = 123L;
    // レコードに存在しない値
    String coopCd = "2";
    String baseDate = "20200202";

    // シーケンスはモック化
    given(sysCoopJournalDao.selectNextSeqCtlNo()).willReturn(2L);

    JournalCreateRequest expect = 作成リクエストテストデータ作成(ordNo, coopOrdNo, hospPatId, patId, message64, anaResult, coopResult, userId, baseDate);
    expect.setCoopCd(coopCd);

    service.insert(expect);
  }

  @Test
  public void 正常系_ジャーナル作成_受付番号採番可() {
    Long ordNo = 100L;
    String coopOrdNo = "101";
    String hospPatId = "200";
    Long patId = 201L;
    String message64 = "VEVTVF9NT0NL";
    String anaResult = AnaResult.UNPROCESS.getResult();
    String coopResult = CoopResult.UNPROCESS.getResult();
    Long userId = 123L;
    String baseDate = "20200202";

    // シーケンスはモック化
    given(sysCoopJournalDao.selectNextSeqCtlNo()).willReturn(2L);

    JournalCreateRequest expect = 作成リクエストテストデータ作成(ordNo, coopOrdNo, hospPatId, patId, message64, anaResult, coopResult, userId, baseDate);
    expect.setFacilityCd("TEST03");
    expect.setCoopCd("2");
    List<SysCoopJournal> actuals = service.insert(expect);

    assertThat(actuals.size(), is(1));

    SysCoopJournal actual = actuals.get(0);

    assertThat(actual.getFacilityCd(), is(expect.getFacilityCd()));
    assertThat(actual.getCtlNo(), is(2L));
    assertThat(actual.getCoopCd(), is(expect.getCoopCd()));
    assertThat(actual.getCoopCdIndex(), is(expect.getCoopCdIndex()));
    assertThat(actual.getCrud(), is(expect.getCrud()));
    assertThat(actual.getDirection(), is(expect.getDirection()));
    assertThat(actual.getOrdNo(), is(expect.getOrdNo()));
    assertThat(actual.getCoopOrdNo(), is(expect.getCoopOrdNo()));
    assertThat(actual.getHospPatId(), is(expect.getHospPatId()));
    assertThat(actual.getPatId(), is(expect.getPatId()));
    assertThat(actual.getAnaResult(), is(expect.getAnaResult()));
    assertThat(actual.getCoopResult(), is(expect.getCoopResult()));
    assertThat(actual.getDump(), is(Base64.getDecoder().decode(expect.getMessage64().getBytes())));
    assertThat(actual.getInAnaDate(), is(nullValue()));
    assertThat(actual.getOutAnaDate(), is(nullValue()));
    assertThat(actual.getInRegDate(), is(nullValue()));
    assertThat(actual.getOutRegDate(), is(nullValue()));
    assertThat(actual.getUserId(), is(expect.getUserId()));
    assertThat(actual.getAcceptNo(), is(1L));
  }

  @Test
  public void 正常系_ジャーナル作成_受付番号採番否() {
    Long ordNo = 100L;
    String coopOrdNo = "101";
    String hospPatId = "200";
    Long patId = 201L;
    String message64 = "VEVTVF9NT0NL";
    String anaResult = AnaResult.UNPROCESS.getResult();
    String coopResult = CoopResult.UNPROCESS.getResult();
    Long userId = 123L;
    String baseDate = "20200202";

    // シーケンスはモック化
    given(sysCoopJournalDao.selectNextSeqCtlNo()).willReturn(2L);

    JournalCreateRequest expect = 作成リクエストテストデータ作成(ordNo, coopOrdNo, hospPatId, patId, message64, anaResult, coopResult, userId, baseDate);
    expect.setFacilityCd("TEST04");
    expect.setCoopCd("2");
    List<SysCoopJournal> actuals = service.insert(expect);

    assertThat(actuals.size(), is(1));

    SysCoopJournal actual = actuals.get(0);

    assertThat(actual.getFacilityCd(), is(expect.getFacilityCd()));
    assertThat(actual.getCtlNo(), is(2L));
    assertThat(actual.getCoopCd(), is(expect.getCoopCd()));
    assertThat(actual.getCoopCdIndex(), is(expect.getCoopCdIndex()));
    assertThat(actual.getCrud(), is(expect.getCrud()));
    assertThat(actual.getDirection(), is(expect.getDirection()));
    assertThat(actual.getOrdNo(), is(expect.getOrdNo()));
    assertThat(actual.getCoopOrdNo(), is(expect.getCoopOrdNo()));
    assertThat(actual.getHospPatId(), is(expect.getHospPatId()));
    assertThat(actual.getPatId(), is(expect.getPatId()));
    assertThat(actual.getAnaResult(), is(expect.getAnaResult()));
    assertThat(actual.getCoopResult(), is(expect.getCoopResult()));
    assertThat(actual.getDump(), is(Base64.getDecoder().decode(expect.getMessage64().getBytes())));
    assertThat(actual.getInAnaDate(), is(nullValue()));
    assertThat(actual.getOutAnaDate(), is(nullValue()));
    assertThat(actual.getInRegDate(), is(nullValue()));
    assertThat(actual.getOutRegDate(), is(nullValue()));
    assertThat(actual.getUserId(), is(expect.getUserId()));
    assertThat(actual.getAcceptNo(), is(nullValue()));
  }


  /**
   * insert確認
   * mst_coop_facility.common_settingでレポート対象(report: true)の場合
   * report_typeが設定されていない場合はエラー
   * */
  @Test
  public void 異常系_ジャーナル作成_レポート対象でレポート未定義の場合エラー() {
    String facilityCd = "ERROR1";
    String coopCd = "rep_dial";
    String coopCdIndex = null;
    Long ordNo = 1L;
    String coopOrdNo = null;
    String hospPatId = null;
    Long patId = 1L;
    String message64 = null;
    String anaResult = AnaResult.UNPROCESS.getResult();
    String coopResult = CoopResult.UNPROCESS.getResult();
    Long userId = 123L;
    String baseDate = "20200202";
    JournalCreateRequest expect = 作成リクエストテストデータ作成(ordNo, coopOrdNo, hospPatId, patId, message64, anaResult, coopResult, userId, baseDate);
    expect.setFacilityCd(facilityCd);
    expect.setCoopCd(coopCd);
    expect.setCoopCdIndex(coopCdIndex);

    // directionがS(送信)かつ、hosp_pat_idが未設定の場合にpat_personal_main.hosp_pat_idを取得
    doReturn(患者データモック()).when(patPersonalMainDao).selectById(any());

    try {
      service.insert(expect);
      fail("エラー想定のためここには到達しない");
    } catch (NtssException e) {
      assertThat(e.getMessage(), is("レポート設定の定義が設定されていません。"));
    }
  }

  /**
   * insert確認
   * mst_coop_facility.common_settingでレポート対象(report: true)かつ、report_typeがxmlの場合
   * coop_cd_indexがxmlのレコードが作成される
   * */
  @Test
  public void 正常系_ジャーナル作成_レポート対象かつレポートタイプがXMLの場合() {
    String facilityCd = "TEST05";
    String coopCd = "rep_dial";
    String coopCdIndex = null;
    Long ordNo = 1L;
    String coopOrdNo = null;
    String hospPatId = null;
    Long patId = 1L;
    String message64 = null;
    String anaResult = AnaResult.UNPROCESS.getResult();
    String coopResult = CoopResult.UNPROCESS.getResult();
    Long userId = 123L;
    String baseDate = "20200202";
    JournalCreateRequest expect = 作成リクエストテストデータ作成(ordNo, coopOrdNo, hospPatId, patId, message64, anaResult, coopResult, userId, baseDate);
    expect.setFacilityCd(facilityCd);
    expect.setCoopCd(coopCd);
    expect.setCoopCdIndex(coopCdIndex);

    // シーケンスはモック化
    given(sysCoopJournalDao.selectNextSeqCtlNo()).willReturn(3L);

    // directionがS(送信)かつ、hosp_pat_idが未設定の場合にpat_personal_main.hosp_pat_idを取得
    doReturn(患者データモック()).when(patPersonalMainDao).selectById(any());

    try {
      List<SysCoopJournal> actuals = service.insert(expect);

      // XMLのレコードが作成される
      assertThat(actuals.size(), is(1));

      SysCoopJournal actual = actuals.get(0);
      assertThat(actual.getCtlNo(), is(3L));
      assertThat(actual.getFacilityCd(), is(expect.getFacilityCd()));
      assertThat(actual.getCoopCd(), is(expect.getCoopCd()));
      assertThat(actual.getCoopCdIndex(), is("xml"));
      assertThat(actual.getCrud(), is(expect.getCrud()));
      assertThat(actual.getDirection(), is(expect.getDirection()));
      assertThat(actual.getOrdNo(), is(expect.getOrdNo()));
      assertThat(actual.getCoopOrdNo(), is("0"));
      assertThat(actual.getHospPatId(), is("00001"));
      assertThat(actual.getPatId(), is(expect.getPatId()));
      assertThat(actual.getAnaResult(), is(expect.getAnaResult()));
      assertThat(actual.getCoopResult(), is(expect.getCoopResult()));
      assertThat(actual.getReportCd(), nullValue());
      assertThat(actual.getDumpPath(), nullValue());
      assertThat(actual.getDump(), nullValue());
      assertThat(actual.getInAnaDate(), nullValue());
      assertThat(actual.getOutAnaDate(), nullValue());
      assertThat(actual.getInRegDate(), nullValue());
      assertThat(actual.getOutRegDate(), nullValue());
      assertThat(actual.getUserId(), is(expect.getUserId()));
      assertThat(actual.getAcceptNo(), nullValue());

    } catch (NtssException e) {
      fail("想定外エラー");
    }
  }
  /**
   * insert確認
   * mst_coop_facility.common_settingでレポート対象(report: true)かつ、report_typeがpdfの場合
   * coop_cd_indexがpdfのレコードが作成される.
   * dump_pathにレコード名が設定される
   * */
  @Test
  public void 正常系_ジャーナル作成_レポート対象かつレポートタイプがPDFの場合() {
    String facilityCd = "TEST06";
    String coopCd = "rep_dial";
    String coopCdIndex = null;
    Long ordNo = 1L;
    String coopOrdNo = null;
    String hospPatId = null;
    Long patId = 1L;
    String message64 = null;
    String anaResult = AnaResult.UNPROCESS.getResult();
    String coopResult = CoopResult.UNPROCESS.getResult();
    Long userId = 123L;
    String baseDate = "20200202";
    JournalCreateRequest expect = 作成リクエストテストデータ作成(ordNo, coopOrdNo, hospPatId, patId, message64, anaResult, coopResult, userId, baseDate);
    expect.setFacilityCd(facilityCd);
    expect.setCoopCd(coopCd);
    expect.setCoopCdIndex(coopCdIndex);

    // シーケンスはモック化
    given(sysCoopJournalDao.selectNextSeqCtlNo()).willReturn(3L);
    // directionがS(送信)かつ、hosp_pat_idが未設定の場合にpat_personal_main.hosp_pat_idを取得
    doReturn(患者データモック()).when(patPersonalMainDao).selectById(any());
    // レポートコードの取得用のデータモック
    doReturn(治療情報データモック()).when(mstTreatmentDao).selectByOrdNo(any());
    // レポート作成のモック
    doReturn("<html></html>").when(reportService).getReportHtml(any(), any(), any(), any());
    // レポート作成
    doReturn(true).when(reportService).convertHtmlToPdf(any(), any());

    try {
      List<SysCoopJournal> actuals = service.insert(expect);

      // XMLとPDFのレコードが作成される
      assertThat(actuals.size(), is(1));

      SysCoopJournal actual = actuals.get(0);
      assertThat(actual.getCtlNo(), is(3L));
      assertThat(actual.getFacilityCd(), is(expect.getFacilityCd()));
      assertThat(actual.getCoopCd(), is(expect.getCoopCd()));
      assertThat(actual.getCoopCdIndex(), is("pdf"));
      assertThat(actual.getCrud(), is(expect.getCrud()));
      assertThat(actual.getDirection(), is(expect.getDirection()));
      assertThat(actual.getOrdNo(), is(expect.getOrdNo()));
      assertThat(actual.getCoopOrdNo(), is("0"));
      assertThat(actual.getHospPatId(), is("00001"));
      assertThat(actual.getPatId(), is(expect.getPatId()));
      assertThat(actual.getAnaResult(), is(expect.getAnaResult()));
      assertThat(actual.getCoopResult(), is(expect.getCoopResult()));
      assertThat(actual.getReportCd(), is(100L));
      assertThat(actual.getDumpPath(), notNullValue());
      assertThat(actual.getDump(), nullValue());
      assertThat(actual.getInAnaDate(), nullValue());
      assertThat(actual.getOutAnaDate(), nullValue());
      assertThat(actual.getInRegDate(), nullValue());
      assertThat(actual.getOutRegDate(), nullValue());
      assertThat(actual.getUserId(), is(expect.getUserId()));
      assertThat(actual.getAcceptNo(), nullValue());

    } catch (NtssException e) {
      fail("想定外エラー");
    }
  }
  /**
   * insert確認
   * mst_coop_facility.common_settingでレポート対象(report: true)かつ、report_typeがtarの場合
   * 帳票パスがdumpPathに設定されること
   * */
  @Test
  public void 正常系_ジャーナル作成_レポート対象かつレポートタイプがTARの場合() {
    String facilityCd = "TEST07";
    String coopCd = "rep_dial";
    String coopCdIndex = null;
    Long ordNo = 1L;
    String coopOrdNo = null;
    String hospPatId = null;
    Long patId = 1L;
    String message64 = null;
    String anaResult = AnaResult.UNPROCESS.getResult();
    String coopResult = CoopResult.UNPROCESS.getResult();
    Long userId = 123L;
    String baseDate = "20200202";
    JournalCreateRequest expect = 作成リクエストテストデータ作成(ordNo, coopOrdNo, hospPatId, patId, message64, anaResult, coopResult, userId, baseDate);
    expect.setFacilityCd(facilityCd);
    expect.setCoopCd(coopCd);
    expect.setCoopCdIndex(coopCdIndex);

    // シーケンスはモック化
    given(sysCoopJournalDao.selectNextSeqCtlNo()).willReturn(3L);
    // directionがS(送信)かつ、hosp_pat_idが未設定の場合にpat_personal_main.hosp_pat_idを取得
    doReturn(患者データモック()).when(patPersonalMainDao).selectById(any());
    // レポートコードの取得用のデータモック
    doReturn(治療情報データモック()).when(mstTreatmentDao).selectByOrdNo(any());
    // レポート作成のモック
    doReturn("<html></html>").when(reportService).getReportHtml(any(), any(), any(), any());
    // レポート作成
    doReturn(true).when(reportService).convertHtmlToPdf(any(), any());
    try {
      List<SysCoopJournal> actuals = service.insert(expect);

      // TARのレコードが作成される
      assertThat(actuals.size(), is(1));

      SysCoopJournal actual = actuals.get(0);
      assertThat(actual.getCtlNo(), is(3L));
      assertThat(actual.getFacilityCd(), is(expect.getFacilityCd()));
      assertThat(actual.getCoopCd(), is(expect.getCoopCd()));
      assertThat(actual.getCoopCdIndex(), is("tar"));
      assertThat(actual.getCrud(), is(expect.getCrud()));
      assertThat(actual.getDirection(), is(expect.getDirection()));
      assertThat(actual.getOrdNo(), is(expect.getOrdNo()));
      assertThat(actual.getCoopOrdNo(), is("0"));
      assertThat(actual.getHospPatId(), is("00001"));
      assertThat(actual.getPatId(), is(expect.getPatId()));
      assertThat(actual.getAnaResult(), is(expect.getAnaResult()));
      assertThat(actual.getCoopResult(), is(expect.getCoopResult()));
      assertThat(actual.getReportCd(), is(100L));
      assertThat(actual.getDumpPath(), notNullValue());
      assertThat(actual.getDump(), nullValue());
      assertThat(actual.getInAnaDate(), nullValue());
      assertThat(actual.getOutAnaDate(), nullValue());
      assertThat(actual.getInRegDate(), nullValue());
      assertThat(actual.getOutRegDate(), nullValue());
      assertThat(actual.getUserId(), is(expect.getUserId()));
      assertThat(actual.getAcceptNo(), nullValue());

    } catch (NtssException e) {
      fail("想定外エラー");
    }
  }

  /**
   * insert確認
   * mst_coop_facility.common_settingでレポート対象(report: true)かつ、report_typeがxmlpdfの場合
   * ３レコード作成されること(pdf, xml, listxml)
   * */
  @Test
  public void 正常系_レポート対象かつレポートタイプがxmlpdfの場合() {
    String facilityCd = "TEST08";
    String coopCd = "rep_dial";
    String coopCdIndex = null;
    Long ordNo = 1L;
    String coopOrdNo = null;
    String hospPatId = null;
    Long patId = 1L;
    String message64 = null;
    String anaResult = AnaResult.UNPROCESS.getResult();
    String coopResult = CoopResult.UNPROCESS.getResult();
    Long userId = 123L;
    String baseDate = "20200202";
    JournalCreateRequest expect = 作成リクエストテストデータ作成(ordNo, coopOrdNo, hospPatId, patId, message64, anaResult, coopResult, userId, baseDate);
    expect.setFacilityCd(facilityCd);
    expect.setCoopCd(coopCd);
    expect.setCoopCdIndex(coopCdIndex);

    // directionがS(送信)かつ、hosp_pat_idが未設定の場合にpat_personal_main.hosp_pat_idを取得
    doReturn(患者データモック()).when(patPersonalMainDao).selectById(any());
    // レポートコードの取得用のデータモック
    doReturn(治療情報データモック()).when(mstTreatmentDao).selectByOrdNo(any());
    // レポート作成のモック
    doReturn("<html></html>").when(reportService).getReportHtml(any(), any(), any(), any());
    // レポート作成
    doReturn(true).when(reportService).convertHtmlToPdf(any(), any());
    try {
      List<SysCoopJournal> actuals = service.insert(expect);

      // TARのレコードが作成される
      assertThat(actuals.size(), is(3));

      for (int i=0; i< actuals.size(); i++) {
        SysCoopJournal actual = actuals.get(i);
        assertThat(actual.getFacilityCd(), is(expect.getFacilityCd()));
        assertThat(actual.getCoopCd(), is(expect.getCoopCd()));
        if (i == 0) {
          assertThat(actual.getCoopCdIndex(), is("pdf"));
          assertThat(actual.getDumpPath(), notNullValue());
          assertThat(actual.getReportCd(), is(100L));
        } else if (i == 1){
          assertThat(actual.getCoopCdIndex(), is("xml"));
          assertThat(actual.getDumpPath(), nullValue());
          assertThat(actual.getReportCd(), nullValue());
        } else {
          assertThat(actual.getCoopCdIndex(), is("listxml"));
          assertThat(actual.getDumpPath(), nullValue());
          assertThat(actual.getReportCd(), nullValue());
        }
        assertThat(actual.getCrud(), is(expect.getCrud()));
        assertThat(actual.getDirection(), is(expect.getDirection()));
        assertThat(actual.getOrdNo(), is(expect.getOrdNo()));
        assertThat(actual.getCoopOrdNo(), is("0"));
        assertThat(actual.getHospPatId(), is("00001"));
        assertThat(actual.getPatId(), is(expect.getPatId()));
        assertThat(actual.getAnaResult(), is(expect.getAnaResult()));
        assertThat(actual.getCoopResult(), is(expect.getCoopResult()));
        assertThat(actual.getDump(), nullValue());
        assertThat(actual.getInAnaDate(), nullValue());
        assertThat(actual.getOutAnaDate(), nullValue());
        assertThat(actual.getInRegDate(), nullValue());
        assertThat(actual.getOutRegDate(), nullValue());
        assertThat(actual.getUserId(), is(expect.getUserId()));
        assertThat(actual.getAcceptNo(), nullValue());
      }
    } catch (NtssException e) {
      fail("想定外エラー");
    }
  }

  /**
   * insert確認
   * mst_coop_facility.common_settingでレポート対象(report: true)かつ、report_typeがpdfxmlの場合
   * ２レコード作成されること(pdf, xml)
   * */
  @Test
  public void 正常系_レポート対象かつレポートタイプがpdfxmlの場合() {
    String facilityCd = "TEST09";
    String coopCd = "rep_dial";
    String coopCdIndex = null;
    Long ordNo = 1L;
    String coopOrdNo = null;
    String hospPatId = null;
    Long patId = 1L;
    String message64 = null;
    String anaResult = AnaResult.UNPROCESS.getResult();
    String coopResult = CoopResult.UNPROCESS.getResult();
    Long userId = 123L;
    String baseDate = "20200202";
    JournalCreateRequest expect = 作成リクエストテストデータ作成(ordNo, coopOrdNo, hospPatId, patId, message64, anaResult, coopResult, userId, baseDate);
    expect.setFacilityCd(facilityCd);
    expect.setCoopCd(coopCd);
    expect.setCoopCdIndex(coopCdIndex);

    // directionがS(送信)かつ、hosp_pat_idが未設定の場合にpat_personal_main.hosp_pat_idを取得
    doReturn(患者データモック()).when(patPersonalMainDao).selectById(any());
    // レポートコードの取得用のデータモック
    doReturn(治療情報データモック()).when(mstTreatmentDao).selectByOrdNo(any());
    // レポート作成のモック
    doReturn("<html></html>").when(reportService).getReportHtml(any(), any(), any(), any());
    // レポート作成
    doReturn(true).when(reportService).convertHtmlToPdf(any(), any());
    try {
      List<SysCoopJournal> actuals = service.insert(expect);

      // TARのレコードが作成される
      assertThat(actuals.size(), is(2));

      for (int i=0; i< actuals.size(); i++) {
        SysCoopJournal actual = actuals.get(i);
        assertThat(actual.getFacilityCd(), is(expect.getFacilityCd()));
        assertThat(actual.getCoopCd(), is(expect.getCoopCd()));
        if (i == 0) {
          assertThat(actual.getCoopCdIndex(), is("pdf"));
          assertThat(actual.getDumpPath(), notNullValue());
          assertThat(actual.getReportCd(), is(100L));
        } else {
          assertThat(actual.getCoopCdIndex(), is("xml"));
          assertThat(actual.getDumpPath(), nullValue());
          assertThat(actual.getReportCd(), nullValue());
        }
        assertThat(actual.getCrud(), is(expect.getCrud()));
        assertThat(actual.getDirection(), is(expect.getDirection()));
        assertThat(actual.getOrdNo(), is(expect.getOrdNo()));
        assertThat(actual.getCoopOrdNo(), is("0"));
        assertThat(actual.getHospPatId(), is("00001"));
        assertThat(actual.getPatId(), is(expect.getPatId()));
        assertThat(actual.getAnaResult(), is(expect.getAnaResult()));
        assertThat(actual.getCoopResult(), is(expect.getCoopResult()));
        assertThat(actual.getDump(), nullValue());
        assertThat(actual.getInAnaDate(), nullValue());
        assertThat(actual.getOutAnaDate(), nullValue());
        assertThat(actual.getInRegDate(), nullValue());
        assertThat(actual.getOutRegDate(), nullValue());
        assertThat(actual.getUserId(), is(expect.getUserId()));
        assertThat(actual.getAcceptNo(), nullValue());
      }
    } catch (NtssException e) {
      fail("想定外エラー");
    }
  }

  private JournalCreateRequest 作成リクエストテストデータ作成(Long ordNo, String coopOrdNo, String hospPatId, Long patId, String message64, String anaResult, String coopResult, Long userId, String baseDate) {
    return 作成リクエストテストデータ作成("C", ordNo, coopOrdNo, hospPatId, patId, message64, anaResult, coopResult, userId, baseDate);
  }

  private JournalCreateRequest 作成リクエストテストデータ作成(String crud, Long ordNo, String coopOrdNo, String hospPatId, Long patId, String message64, String anaResult, String coopResult, Long userId, String baseDate) {
    JournalCreateRequest request = new JournalCreateRequest();
    request.setFacilityCd("TEST01");
    request.setCoopCd("1");
    request.setCoopCdIndex("K");
    request.setCrud(crud);
    request.setDirection("S");
    request.setOrdNo(ordNo);
    request.setCoopOrdNo(coopOrdNo);
    request.setHospPatId(hospPatId);
    request.setPatId(patId);
    request.setMessage64(message64);
    request.setAnaResult(anaResult);
    request.setCoopResult(coopResult);
    request.setUserId(userId);
    request.setBaseDate(baseDate);

    return request;
  }

  private JournalUpdateRequest 更新リクエストテストデータ作成(Long ctlNo, String anaResult, String coopResult, String dumpPath, Long userId) {
    JournalUpdateRequest request = new JournalUpdateRequest();
    request.setCtlNo(ctlNo);
    request.setAnaResult(anaResult);
    request.setCoopResult(coopResult);
    request.setDumpPath(dumpPath);
    request.setUserId(userId);

    return request;
  }

  private PatPersonalMain 患者データモック() {
    PatPersonalMain ppm = new PatPersonalMain();
    ppm.setHosp_pat_id("00001");
    return ppm;
  }

  private MstTreatment 治療情報データモック() {
    MstTreatment mt = new MstTreatment();
    mt.setReportId(100);
    return mt;
  }
}
