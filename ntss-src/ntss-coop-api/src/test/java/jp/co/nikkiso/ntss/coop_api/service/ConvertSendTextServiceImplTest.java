package jp.co.nikkiso.ntss.coop_api.service;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.not;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.junit.Assert.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.doReturn;
import static org.mockito.BDDMockito.doThrow;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.times;
import static org.mockito.BDDMockito.verify;

import java.io.UnsupportedEncodingException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.boot.test.mock.mockito.SpyBean;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.coop_api.utils.ClockWrapper;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants.AnaResult;
import jp.co.nikkiso.ntss.core.dao.SysCoopJournalDao;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;
import jp.co.nikkiso.ntss.core.exception.NtssException;

@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:resource.script/ConvertSendServiceImplTest/ConvertSendServiceImplTest.db5.before.sql")
public class ConvertSendTextServiceImplTest extends BaseServiceTest {
  @SpyBean
  ConvertSendTextServiceImpl service;
  @SpyBean
  ConvertSendCommonServiceImpl commonServiceImpl;
  @MockBean
  ClockWrapper clockWrapper;
  @Autowired
  SysCoopJournalDao sysCoopJournalDao;

  @Test
  public void 正常系_送信版電文変換_固定値HOGE_データ長同じ_固定値通りに電文作成される() {
    String facilityCd = "TEST01";
    String coopCd = "TEST_CD";
    byte[] expect = "HOGE".getBytes();

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    doReturn(new ArrayList<>()).when(commonServiceImpl).requestNtssApi(any());

    service.createTelegram(sysCoopJournal);

    assertThat(sysCoopJournal.getDump(), notNullValue());
    assertThat(sysCoopJournal.getDump(), is(expect));
    assertThat(sysCoopJournal.getDumpPath(), nullValue());

    assert_ジャーナルが更新されていない(facilityCd, coopCd);
  }

  @Test
  public void 正常系_送信版電文変換_固定値HOGE_データ長6桁で2byte余り_paddingはデフォルト_HOGEスペース2桁で電文作成される() {
    String facilityCd = "TEST02";
    String coopCd = "TEST_CD";
    byte[] expect = "HOGE  ".getBytes();

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    doReturn(new ArrayList<>()).when(commonServiceImpl).requestNtssApi(any());

    service.createTelegram(sysCoopJournal);

    assertThat(sysCoopJournal.getDump(), notNullValue());
    assertThat(sysCoopJournal.getDump(), is(expect));
    assertThat(sysCoopJournal.getDumpPath(), nullValue());

    assert_ジャーナルが更新されていない(facilityCd, coopCd);
  }

  @Test
  public void 正常系_送信版電文変換_固定値HOGE_データ長6桁で2byte余り_paddingは左ゼロ埋め_00HOGEで電文作成される() {
    String facilityCd = "TEST03";
    String coopCd = "TEST_CD";
    byte[] expect = "00HOGE".getBytes();

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    doReturn(new ArrayList<>()).when(commonServiceImpl).requestNtssApi(any());

    service.createTelegram(sysCoopJournal);

    assertThat(sysCoopJournal.getDump(), notNullValue());
    assertThat(sysCoopJournal.getDump(), is(expect));
    assertThat(sysCoopJournal.getDumpPath(), nullValue());

    assert_ジャーナルが更新されていない(facilityCd, coopCd);
  }

  @Test
  public void 正常系_送信版電文変換_固定値HOGE_データ長6桁で2byte余り_paddingは右ゼロ埋め_HOGE00で電文作成される() {
    String facilityCd = "TEST04";
    String coopCd = "TEST_CD";
    byte[] expect = "HOGE00".getBytes();

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    doReturn(new ArrayList<>()).when(commonServiceImpl).requestNtssApi(any());

    service.createTelegram(sysCoopJournal);

    assertThat(sysCoopJournal.getDump(), notNullValue());
    assertThat(sysCoopJournal.getDump(), is(expect));
    assertThat(sysCoopJournal.getDumpPath(), nullValue());

    assert_ジャーナルが更新されていない(facilityCd, coopCd);
  }

  @Test
  public void 正常系_送信版電文変換_固定値HOGE_データ長6桁で2byte余り_paddingは左スペース埋め_左スペース2桁HOGEで電文作成される() {
    String facilityCd = "TEST05";
    String coopCd = "TEST_CD";
    byte[] expect = "  HOGE".getBytes();

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    doReturn(new ArrayList<>()).when(commonServiceImpl).requestNtssApi(any());

    service.createTelegram(sysCoopJournal);

    assertThat(sysCoopJournal.getDump(), notNullValue());
    assertThat(sysCoopJournal.getDump(), is(expect));
    assertThat(sysCoopJournal.getDumpPath(), nullValue());

    assert_ジャーナルが更新されていない(facilityCd, coopCd);
  }

  @Test
  public void 正常系_送信版電文変換_固定値HOGE_データ長6桁で2byte余り_paddingは右スペース埋め_HOGE右スペース2桁で電文作成される() {
    String facilityCd = "TEST06";
    String coopCd = "TEST_CD";
    byte[] expect = "HOGE  ".getBytes();

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    doReturn(new ArrayList<>()).when(commonServiceImpl).requestNtssApi(any());

    service.createTelegram(sysCoopJournal);

    assertThat(sysCoopJournal.getDump(), notNullValue());
    assertThat(sysCoopJournal.getDump(), is(expect));
    assertThat(sysCoopJournal.getDumpPath(), nullValue());

    assert_ジャーナルが更新されていない(facilityCd, coopCd);
  }

  @Test
  public void 正常系_送信版電文変換_固定値HOGE_データ長6桁で2byte余り_paddingは左全角スペース埋め_左全角スペース1桁HOGEで電文作成される() throws UnsupportedEncodingException {
    String facilityCd = "TEST29";
    String coopCd = "TEST_CD";
    byte[] expect = "　HOGE".getBytes("SJIS");

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    doReturn(new ArrayList<>()).when(commonServiceImpl).requestNtssApi(any());

    service.createTelegram(sysCoopJournal);

    assertThat(sysCoopJournal.getDump(), notNullValue());
    assertThat(sysCoopJournal.getDump(), is(expect));
    assertThat(sysCoopJournal.getDumpPath(), nullValue());

    assert_ジャーナルが更新されていない(facilityCd, coopCd);
  }

  @Test
  public void 正常系_送信版電文変換_固定値HOGE_データ長6桁で2byte余り_paddingは右全角スペース埋め_HOGE右全角スペース1桁で電文作成される() throws UnsupportedEncodingException {
    String facilityCd = "TEST30";
    String coopCd = "TEST_CD";
    byte[] expect = "HOGE　".getBytes("SJIS");

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    doReturn(new ArrayList<>()).when(commonServiceImpl).requestNtssApi(any());

    service.createTelegram(sysCoopJournal);

    assertThat(sysCoopJournal.getDump(), notNullValue());
    assertThat(sysCoopJournal.getDump(), is(expect));
    assertThat(sysCoopJournal.getDumpPath(), nullValue());

    assert_ジャーナルが更新されていない(facilityCd, coopCd);
  }

  @Test(expected = NtssException.class)
  public void 異常系_送信版電文変換_固定値HOGE_データ長5桁で1byte余り_paddingは2byteの全角スペースが入らないため変換ステータスがエラーとなる() {
    String facilityCd = "TEST31";
    String coopCd = "TEST_CD";

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    doReturn(new ArrayList<>()).when(commonServiceImpl).requestNtssApi(any());

    service.createTelegram(sysCoopJournal);
  }

  @Test(expected = NtssException.class)
  public void 異常系_送信版電文変換_固定値HOGE_データ長6桁で2byte余り_paddingは存在しない値のため変換ステータスがエラーとなる() {
    String facilityCd = "TEST32";
    String coopCd = "TEST_CD";

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    doReturn(new ArrayList<>()).when(commonServiceImpl).requestNtssApi(any());

    service.createTelegram(sysCoopJournal);
  }

  @Test
  public void 正常系_送信版電文変換_固定長HOGEと固定長オカレンス固定長OCCリピートなし_HOGEOCCで電文作成される() {
    String facilityCd = "TEST07";
    String coopCd = "TEST_CD";
    byte[] expect = "HOGEOCC".getBytes();

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    List<Map<String, Object>> dataSetList = detailIdがut_roop_1とdetail_001というキーで11111の値を持つデータセットモックデータ作成();
    doReturn(dataSetList).when(commonServiceImpl).requestNtssApi(any());

    service.createTelegram(sysCoopJournal);

    assertThat(sysCoopJournal.getDump(), notNullValue());
    assertThat(sysCoopJournal.getDump(), is(expect));
    assertThat(sysCoopJournal.getDumpPath(), nullValue());

    assert_ジャーナルが更新されていない(facilityCd, coopCd);
  }

  @Test
  public void 正常系_送信版電文変換_固定長HOGEとオカレンス固定長OCCリピート2回_HOGEOCCOCCで電文作成される() {
    String facilityCd = "TEST08";
    String coopCd = "TEST_CD";
    byte[] expect = "HOGEOCCOCC".getBytes();

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    List<Map<String, Object>> dataSetList = detailIdがut_roop_1とdetail_001というキーで11111の値を持つデータセットモックデータ作成();
    dataSetList.addAll(detailIdがut_roop_1とdetail_001というキーで22222の値を持つデータセットモックデータ作成());
    doReturn(dataSetList).when(commonServiceImpl).requestNtssApi(any());

    service.createTelegram(sysCoopJournal);

    assertThat(sysCoopJournal.getDump(), notNullValue());
    assertThat(sysCoopJournal.getDump(), is(expect));
    assertThat(sysCoopJournal.getDumpPath(), nullValue());

    assert_ジャーナルが更新されていない(facilityCd, coopCd);
  }

  @Test
  public void 正常系_送信版電文変換_固定長HOGEとオカレンス固定長OCCデータ長3byte_パディング指定なし_HOGE1スペース2桁OCCで電文作成される() {
    String facilityCd = "TEST09";
    String coopCd = "TEST_CD";
    byte[] expect = "HOGE1  OCC".getBytes();

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    List<Map<String, Object>> dataSetList = detailIdがut_roop_1とdetail_001というキーで11111の値を持つデータセットモックデータ作成();
    doReturn(dataSetList).when(commonServiceImpl).requestNtssApi(any());

    service.createTelegram(sysCoopJournal);

    assertThat(sysCoopJournal.getDump(), notNullValue());
    assertThat(sysCoopJournal.getDump(), is(expect));
    assertThat(sysCoopJournal.getDumpPath(), nullValue());

    assert_ジャーナルが更新されていない(facilityCd, coopCd);
  }

  @Test
  public void 正常系_送信版電文変換_固定長HOGEとオカレンス固定長OCCデータ長3byte_パディングは左全角スペース_HOGE全角スペース1桁1OCCで電文作成される() throws UnsupportedEncodingException {
    String facilityCd = "TEST33";
    String coopCd = "TEST_CD";
    byte[] expect = "HOGE　1OCC".getBytes("SJIS");

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    List<Map<String, Object>> dataSetList = detailIdがut_roop_1とdetail_001というキーで11111の値を持つデータセットモックデータ作成();
    doReturn(dataSetList).when(commonServiceImpl).requestNtssApi(any());

    service.createTelegram(sysCoopJournal);

    assertThat(sysCoopJournal.getDump(), notNullValue());
    assertThat(sysCoopJournal.getDump(), is(expect));
    assertThat(sysCoopJournal.getDumpPath(), nullValue());

    assert_ジャーナルが更新されていない(facilityCd, coopCd);
  }

  @Test
  public void 正常系_送信版電文変換_DATASETHOGE1という結果が入っているデータセット1つ_DATASETHOGE1で電文作成される() {
    String facilityCd = "TEST10";
    String coopCd = "TEST_CD";
    byte[] expect = "DATASETHOGE1".getBytes();

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    List<Map<String, Object>> dataSetList = DATASETHOGE1という結果のデータセットモックデータ作成();
    doReturn(dataSetList).when(commonServiceImpl).requestNtssApi(any());

    service.createTelegram(sysCoopJournal);

    assertThat(sysCoopJournal.getDump(), notNullValue());
    assertThat(sysCoopJournal.getDump(), is(expect));
    assertThat(sysCoopJournal.getDumpPath(), nullValue());

    assert_ジャーナルが更新されていない(facilityCd, coopCd);
  }

  @Test
  public void 正常系_送信版電文変換_DATASETHOGE1にDATASETHOGE2と異なるSQLCODEのデータセット2つ_DATASETHOGE1DATASETHOGE2で電文作成される() {
    String facilityCd = "TEST11";
    String coopCd = "TEST_CD";
    byte[] expect = "DATASETHOGE1DATASETHOGE2".getBytes();

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    List<Map<String, Object>> dataSetResultByDATASETHOGE1 = DATASETHOGE1という結果のデータセットモックデータ作成();
    List<Map<String, Object>> dataSetResultByDATASETHOGE2 = DATASETHOGE2という結果のデータセットモックデータ作成();
    doReturn(dataSetResultByDATASETHOGE1, dataSetResultByDATASETHOGE2).when(commonServiceImpl).requestNtssApi(any());

    service.createTelegram(sysCoopJournal);

    assertThat(sysCoopJournal.getDump(), notNullValue());
    assertThat(sysCoopJournal.getDump(), is(expect));
    assertThat(sysCoopJournal.getDumpPath(), nullValue());

    assert_ジャーナルが更新されていない(facilityCd, coopCd);
  }


  @Test(expected = NtssException.class)
  public void 異常系_送信版電文変換_固定値_コロンがないレイアウトフォーマットが来る_変換ステータスがエラーとなる() {
    String facilityCd = "TEST12";
    String coopCd = "TEST_CD";

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    doReturn(new ArrayList<>()).when(commonServiceImpl).requestNtssApi(any());

    service.createTelegram(sysCoopJournal);
  }

  @Test
  public void 正常系_送信版電文変換_データセット_拡張設定がないのにデータセットからの出力設定がある_スペース12桁で電文作成される() {
    String facilityCd = "TEST13";
    String coopCd = "TEST_CD";
    byte[] expect = "            ".getBytes();

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    doReturn(new HashMap<>()).when(commonServiceImpl).createRequestAndRequestByDataSetApi(any(), any(), any());

    service.createTelegram(sysCoopJournal);

    assertThat(sysCoopJournal.getDump(), notNullValue());
    assertThat(sysCoopJournal.getDump(), is(expect));
    assertThat(sysCoopJournal.getDumpPath(), nullValue());

    assert_ジャーナルが更新されていない(facilityCd, coopCd);
  }

  @Test(expected = NtssException.class)
  public void 異常系_送信版電文変換_データセット_データセット結果はあるがドットがないレイアウトフォーマットが来る_変換ステータスがエラーとなる() {
    String facilityCd = "TEST14";
    String coopCd = "TEST_CD";

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    doReturn(DATASETHOGE1という結果のデータセットモックデータ作成()).when(commonServiceImpl).requestNtssApi(any());

    service.createTelegram(sysCoopJournal);
  }

  @Test(expected = NtssException.class)
  public void 異常系_送信版電文変換_データセット_データセットへのアクセスでNtssExceptionが発生する_変換ステータスがエラーとなる() {
    String facilityCd = "TEST10";
    String coopCd = "TEST_CD";
    // システム日時をモック化

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    doThrow(NtssException.class).when(commonServiceImpl).requestNtssApi(any());
    service.createTelegram(sysCoopJournal);
  }

  @Test
  public void 正常系_送信版電文変換_固定値$SYSDATE_20191010で電文作成される() {
    String facilityCd = "TEST15";
    String coopCd = "TEST_CD";
    byte[] expect = "20191010".getBytes();

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    doReturn(getExpectMockClock()).when(clockWrapper).getClock();

    service.createTelegram(sysCoopJournal);

    assertThat(sysCoopJournal.getDump(), notNullValue());
    assertThat(sysCoopJournal.getDump(), is(expect));
    assertThat(sysCoopJournal.getDumpPath(), nullValue());

    assert_ジャーナルが更新されていない(facilityCd, coopCd);
  }

  @Test
  public void 正常系_送信版電文変換_固定値$SYSTIME_100000で電文作成される() {
    String facilityCd = "TEST16";
    String coopCd = "TEST_CD";
    byte[] expect = "100000".getBytes();

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

   // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    doReturn(getExpectMockClock()).when(clockWrapper).getClock();

    service.createTelegram(sysCoopJournal);

    assertThat(sysCoopJournal.getDump(), notNullValue());
    assertThat(sysCoopJournal.getDump(), is(expect));
    assertThat(sysCoopJournal.getDumpPath(), nullValue());

    assert_ジャーナルが更新されていない(facilityCd, coopCd);
  }

  @Test
  public void 正常系_送信版電文変換_SQLCODEに紐づいた結果が空のデータセット_長さ12byte_スペース12桁で電文作成される() {
    String facilityCd = "TEST10";
    String coopCd = "TEST_CD";
    byte[] expect = "            ".getBytes();

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

   // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    List<Map<String, Object>> dataSetList = new ArrayList<>();
    Map<String, Object> dataSetResult = new HashMap<>();
    dataSetResult.put("test_dataset_result", "");
    dataSetList.add(dataSetResult);
    doReturn(dataSetList).when(commonServiceImpl).requestNtssApi(any());

    service.createTelegram(sysCoopJournal);

    assertThat(sysCoopJournal.getDump(), notNullValue());
    assertThat(sysCoopJournal.getDump(), is(expect));
    assertThat(sysCoopJournal.getDumpPath(), nullValue());

    assert_ジャーナルが更新されていない(facilityCd, coopCd);
    assert_ntssapiへのアクセスは1回行われた();
  }

  @Test
  public void 正常系_送信版電文変換_固定長HOGEとオカレンス固定長OCCデータ長3byte_左ゼロ埋め_HOGE001OCCで電文作成される() {
    String facilityCd = "TEST17";
    String coopCd = "TEST_CD";
    byte[] expect = "HOGE001OCC".getBytes();

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    List<Map<String, Object>> dataSetList = detailIdがut_roop_1とdetail_001というキーで11111の値を持つデータセットモックデータ作成();
    doReturn(dataSetList).when(commonServiceImpl).requestNtssApi(any());

    service.createTelegram(sysCoopJournal);

    assertThat(sysCoopJournal.getDump(), notNullValue());
    assertThat(sysCoopJournal.getDump(), is(expect));
    assertThat(sysCoopJournal.getDumpPath(), nullValue());

    assert_ジャーナルが更新されていない(facilityCd, coopCd);
  }

  @Test
  public void 正常系_送信版電文変換_固定値ダブルクォートのエスケープにHOGE_ダブルクォートHOGEで電文作成される() {
    String facilityCd = "TEST18";
    String coopCd = "TEST_CD";
    byte[] expect = "\"HOGE".getBytes();

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    doReturn(new ArrayList<>()).when(commonServiceImpl).requestNtssApi(any());

    service.createTelegram(sysCoopJournal);

    assertThat(sysCoopJournal.getDump(), notNullValue());
    assertThat(sysCoopJournal.getDump(), is(expect));
    assertThat(sysCoopJournal.getDumpPath(), nullValue());

    assert_ジャーナルが更新されていない(facilityCd, coopCd);
  }

  @Test
  public void 正常系_送信版電文変換_固定値HOGE改行HOGE_HOGE改行HOGEで電文作成される() {
    String facilityCd = "TEST19";
    String coopCd = "TEST_CD";
    byte[] expect = "HOGE\rHOGE".getBytes();

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    doReturn(new ArrayList<>()).when(commonServiceImpl).requestNtssApi(any());

    service.createTelegram(sysCoopJournal);

    assertThat(sysCoopJournal.getDump(), notNullValue());
    assertThat(sysCoopJournal.getDump(), is(expect));
    assertThat(sysCoopJournal.getDumpPath(), nullValue());

    assert_ジャーナルが更新されていない(facilityCd, coopCd);
  }

  @Test(expected = NtssException.class)
  public void 異常系_送信版電文変換_固定値あいうえお_長さ2byte_電文長エラーとなり変換ステータスがエラーとなる() {
    String facilityCd = "TEST20";
    String coopCd = "TEST_CD";

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    doReturn(new ArrayList<>()).when(commonServiceImpl).requestNtssApi(any());

    service.createTelegram(sysCoopJournal);
  }

  @Test
  public void 正常系_送信版電文変換_電文長6byte_6スペース5桁となり変換ステータスがエラーとなる() {
    String facilityCd = "TEST21";
    String coopCd = "TEST_CD";
    byte[] expect = "6     ".getBytes();

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    doReturn(new ArrayList<>()).when(commonServiceImpl).requestNtssApi(any());

    service.createTelegram(sysCoopJournal);

    assertThat(sysCoopJournal.getDump(), notNullValue());
    assertThat(sysCoopJournal.getDump(), is(expect));
    assertThat(sysCoopJournal.getDumpPath(), nullValue());

    assert_ジャーナルが更新されていない(facilityCd, coopCd);
  }

  @Test
  public void 正常系_送信版電文変換_HOGE電文長6byte_HOGE10スペース4桁となり変換ステータスが処理中となる() {
    String facilityCd = "TEST22";
    String coopCd = "TEST_CD";
    byte[] expect = "HOGE10    ".getBytes();

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    doReturn(new ArrayList<>()).when(commonServiceImpl).requestNtssApi(any());

    service.createTelegram(sysCoopJournal);

    assertThat(sysCoopJournal.getDump(), notNullValue());
    assertThat(sysCoopJournal.getDump(), is(expect));
    assertThat(sysCoopJournal.getDumpPath(), nullValue());

    assert_ジャーナルが更新されていない(facilityCd, coopCd);
  }

  @Test
  public void 正常系_送信版電文変換_HOGE電文長6byte電文長6byte_HOGE16スペース4桁16スペース4桁となり変換ステータスが処理中となる() {
    String facilityCd = "TEST23";
    String coopCd = "TEST_CD";
    byte[] expect = "HOGE16    16    ".getBytes();

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    doReturn(new ArrayList<>()).when(commonServiceImpl).requestNtssApi(any());

    service.createTelegram(sysCoopJournal);

    assertThat(sysCoopJournal.getDump(), notNullValue());
    assertThat(sysCoopJournal.getDump(), is(expect));
    assertThat(sysCoopJournal.getDumpPath(), nullValue());

    assert_ジャーナルが更新されていない(facilityCd, coopCd);
  }

  @Test(expected = NtssException.class)
  public void 異常系_送信版電文変換_ジャーナルはあるがレイアウトがない_変換ステータスがエラーとなる() {
    String facilityCd = "TEST24";
    String coopCd = "TEST_CD";

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    doReturn(new ArrayList<>()).when(commonServiceImpl).requestNtssApi(any());

    service.createTelegram(sysCoopJournal);
  }

  @Test(expected = NtssException.class)
  public void 異常系_送信版電文変換_ジャーナルとレイアウトはあるがレイアウトDetailがない_変換ステータスがエラーとなる() {
    String facilityCd = "TEST25";
    String coopCd = "TEST_CD";

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    List<Map<String, Object>> dataSetResult = DATASETHOGE1という結果のデータセットモックデータ作成();
    doReturn(dataSetResult).when(commonServiceImpl).requestNtssApi(any());
    service.createTelegram(sysCoopJournal);
  }

  @Test
  public void 正常系_送信版電文変換_要素分回らなかったので1回ブランク埋め_HOGEオカレンスリピート2回OCC3byte_HOGEOCCスペース3桁となり変換ステータスが処理中となる() {
    String facilityCd = "TEST26";
    String coopCd = "TEST_CD";
    byte[] expect = "HOGEOCC   ".getBytes();

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    List<Map<String, Object>> dataSetResult = detailIdがut_roop_1とdetail_001というキーで11111の値を持つデータセットモックデータ作成();
    doReturn(dataSetResult).when(commonServiceImpl).requestNtssApi(any());

    service.createTelegram(sysCoopJournal);

    assertThat(sysCoopJournal.getDump(), notNullValue());
    assertThat(sysCoopJournal.getDump(), is(expect));
    assertThat(sysCoopJournal.getDumpPath(), nullValue());

    assert_ジャーナルが更新されていない(facilityCd, coopCd);
    assert_ntssapiへのアクセスは1回行われた();
  }

  @Test
  public void 正常系_送信版電文変換_detailレイアウトのオカレンスの中でdatasetが呼ばれる_オカレンス固定長OCCデータ長3byteにdataset11111_HOGE1スペース3桁OCC1スペース3桁11111となり変換ステータスが処理中となる() {
    String facilityCd = "TEST27";
    String coopCd = "TEST_CD";
    byte[] expect = "HOGE1   OCC1   11111".getBytes();

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    List<Map<String, Object>> dataSetResultByUtLoop1 = detailIdがut_roop_1とdetail_001というキーで11111の値を持つデータセットモックデータ作成();
    List<Map<String, Object>> dataSetResultByUtLoop2 = detailIdがut_roop_2とdetail_001というキーで11111の値を持つデータセットモックデータ作成();
    doReturn(dataSetResultByUtLoop1, dataSetResultByUtLoop2).when(commonServiceImpl).requestNtssApi(any());

    service.createTelegram(sysCoopJournal);

    assertThat(sysCoopJournal.getDump(), notNullValue());
    assertThat(sysCoopJournal.getDump(), is(expect));
    assertThat(sysCoopJournal.getDumpPath(), nullValue());

    assert_ジャーナルが更新されていない(facilityCd, coopCd);
    assert_ntssapiへのアクセスは2回行われた();
  }

  @Test
  public void 正常系_送信版電文変換_電文長計算を含むdetailレイアウトのオカレンスの中でdatasetが呼ばれる_オカレンス固定長OCCデータ長3byteにdataset11111_HOGE20スペース4桁1スペース3桁OCC1スペース3桁11111となり変換ステータスが処理中となる() {
    String facilityCd = "TEST28";
    String coopCd = "TEST_CD";
    byte[] expect = "HOGE26    1   OCC1   11111".getBytes();

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    List<Map<String, Object>> dataSetResultByUtLoop1 = detailIdがut_roop_1とdetail_001というキーで11111の値を持つデータセットモックデータ作成();
    List<Map<String, Object>> dataSetResultByUtLoop2 = detailIdがut_roop_2とdetail_001というキーで11111の値を持つデータセットモックデータ作成();
    doReturn(dataSetResultByUtLoop1, dataSetResultByUtLoop2).when(commonServiceImpl).requestNtssApi(any());

    service.createTelegram(sysCoopJournal);

    assertThat(sysCoopJournal.getDump(), notNullValue());
    assertThat(sysCoopJournal.getDump(), is(expect));
    assertThat(sysCoopJournal.getDumpPath(), nullValue());

    assert_ジャーナルが更新されていない(facilityCd, coopCd);
    assert_ntssapiへのアクセスは2回行われた();
  }

  @Test
  public void 正常系_基準日確認() {
    String facilityCd = "TEST34";
    String coopCd = "TEST_CD";
    byte[] expect = "20200202".getBytes();

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    doReturn(getExpectMockClock()).when(clockWrapper).getClock();

    service.createTelegram(sysCoopJournal);

    assertThat(sysCoopJournal.getDump(), notNullValue());
    assertThat(sysCoopJournal.getDump(), is(expect));
    assertThat(sysCoopJournal.getDumpPath(), nullValue());

    assert_ジャーナルが更新されていない(facilityCd, coopCd);
  }

  private List<Map<String, Object>> DATASETHOGE1という結果のデータセットモックデータ作成() {
    return データセットモックデータ作成("DATASETHOGE1");
  }

  private List<Map<String, Object>> DATASETHOGE2という結果のデータセットモックデータ作成() {
    return データセットモックデータ作成("DATASETHOGE2");
  }

  private List<Map<String, Object>> データセットモックデータ作成(String value) {
    Map<String, Object> dataSet = new HashMap<>();
    dataSet.put("test_dataset_result", value);
    List<Map<String, Object>> dataSetList = new ArrayList<>();
    dataSetList.add(dataSet);

    return dataSetList;
  }

  private List<Map<String, Object>> detailIdがut_roop_1とdetail_001というキーで11111の値を持つデータセットモックデータ作成() {
    return 繰返項目となるデータセットモックデータ("ut_roop_1", "11111");
  }

  private List<Map<String, Object>> detailIdがut_roop_1とdetail_001というキーで22222の値を持つデータセットモックデータ作成() {
    return 繰返項目となるデータセットモックデータ("ut_roop_1", "22222");
  }

  private List<Map<String, Object>> detailIdがut_roop_2とdetail_001というキーで11111の値を持つデータセットモックデータ作成() {
    return 繰返項目となるデータセットモックデータ("ut_roop_2", "11111");
  }

  private List<Map<String, Object>> 繰返項目となるデータセットモックデータ(String detailId, String value) {
    Map<String, Object> dataSet = new HashMap<>();
    dataSet.put("detail_id", detailId);
    dataSet.put("detail_001", value);
    List<Map<String, Object>> dataSetList = new ArrayList<>();
    dataSetList.add(dataSet);

    return dataSetList;
  }

  private void assert_ジャーナルが更新されていない(String facilityCd, String coopCd) {
    SysCoopJournal journal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");
    assertThat(journal, notNullValue());
    assertThat(journal.getAnaResult(), is(AnaResult.UNPROCESS.getResult()));
    assertThat(journal.getInAnaDate(), is(not(new Timestamp(getMockClockMillis()))));
    assertThat(journal.getUpDate(), is(not(new Timestamp(getMockClockMillis()))));
    assertThat(journal.getDump(), nullValue());
  }

  private void assert_ntssapiへのアクセスは1回行われた() {
    assert_ntssapiへのアクセスはx回行われた(1);
  }

  private void assert_ntssapiへのアクセスは2回行われた() {
    assert_ntssapiへのアクセスはx回行われた(2);
  }

  private void assert_ntssapiへのアクセスはx回行われた(int count) {
    // ntss-apiへのアクセスはx回行われる
    verify(commonServiceImpl, times(count)).requestNtssApi(any());
  }

}
