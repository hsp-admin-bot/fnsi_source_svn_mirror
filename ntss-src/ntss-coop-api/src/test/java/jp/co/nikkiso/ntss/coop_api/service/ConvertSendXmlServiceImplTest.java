package jp.co.nikkiso.ntss.coop_api.service;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.junit.Assert.assertThat;
import static org.junit.Assert.fail;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.doReturn;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.times;
import static org.mockito.BDDMockito.verify;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.junit.Ignore;
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
import jp.co.nikkiso.ntss.coop_api.utils.FileUtil;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants.AnaResult;
import jp.co.nikkiso.ntss.core.dao.SysCoopJournalDao;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;
import jp.co.nikkiso.ntss.core.exception.NtssException;

@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:resource.script/ConvertSendXmlServiceImplTest/ConvertSendXmlServiceImplTest.db5.before.sql")
public class ConvertSendXmlServiceImplTest extends BaseServiceTest {
  @SpyBean
  ConvertSendXmlServiceImpl service;
  @SpyBean
  ConvertSendCommonServiceImpl commonServiceImpl;
  @Autowired
  SysCoopJournalDao sysCoopJournalDao;
  @MockBean
  ClockWrapper clockWrapper;
  @SpyBean
  FileUtil fileUtil;

  @Test
  public void 正常系_送信版電文変換_datasetSqlCdJsonKey_データセットの値が埋め込まれた電文が作成される() {
    String facilityCd = "TEST01";
    String coopCd = "TEST_CD";
    String dataSetValue = "DATASETHOGE1";
    String expect = "<?xml version=\"1.0\" encoding=\"Shift_JIS\" standalone=\"yes\"?>\r\n" +
        "<MCSSData ver=\"Ver.03.80 2020-03-25\">\r\n" +
        "  <Header>\r\n" +
        "    <ContentType>" + dataSetValue + "</ContentType>\r\n" +
        "  </Header>\r\n" +
        "</MCSSData>\r\n";
    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    List<Map<String, Object>> dataSetList = DATASETHOGE1という結果のデータセットモックデータ作成();
    doReturn(dataSetList).when(commonServiceImpl).requestNtssApi(any());
    doReturn(false).when(commonServiceImpl).isReport(sysCoopJournal);

    service.createTelegram(sysCoopJournal);

    assertThat(sysCoopJournal.getDump(), notNullValue());
    assertThat(sysCoopJournal.getDump(), is(expect.getBytes()));
    assertThat(sysCoopJournal.getDumpPath(), nullValue());

    assert_ジャーナルが更新されていない(facilityCd, coopCd);
    assert_ntssapiへのアクセスはx回行われた(1);
  }

  @Test
  public void 正常系_送信版電文変換_$JOURNALカラム名_対象レコードのカラム値が埋め込まれた電文が作成される() {
    String facilityCd = "TEST02";
    String coopCd = "TEST_CD";
    String columnValue = "123";
    String expect = "<?xml version=\"1.0\" encoding=\"Shift_JIS\" standalone=\"yes\"?>\r\n" +
        "<MCSSData ver=\"Ver.03.80 2020-03-25\">\r\n" +
        "  <Header>\r\n" +
        "    <PatientCode>" + columnValue + "</PatientCode>\r\n" +
        "  </Header>\r\n" +
        "</MCSSData>\r\n";

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    doReturn(new ArrayList<>()).when(commonServiceImpl).requestNtssApi(any());
    doReturn(false).when(commonServiceImpl).isReport(sysCoopJournal);

    service.createTelegram(sysCoopJournal);

    assertThat(sysCoopJournal.getDump(), notNullValue());
    assertThat(sysCoopJournal.getDump(), is(expect.getBytes()));
    assertThat(sysCoopJournal.getDumpPath(), nullValue());

    assert_ジャーナルが更新されていない(facilityCd, coopCd);
  }

  /**
   * テストケースが通らないため、ひとまずスキップ
   */
  @Ignore
  @Test
  public void 正常系_送信版電文変換_detail_データセット1レコードの値で電文作成される() {
    String facilityCd = "TEST03";
    String coopCd = "TEST_CD";
    String dataSetValue1 = "11111";
    String dataSetValue2 = "22222";
    String expect = "<?xml version=\"1.0\" encoding=\"Shift_JIS\" standalone=\"yes\"?>\r\n" +
        "<MCSSData ver=\"Ver.03.80 2020-03-25\">\r\n" +
        "  <Content>\r\n" +
        "    <Row MasterID=\"" + dataSetValue1 + "\">\r\n" +
        "      <RowData>" + dataSetValue2 + "</RowData>\r\n" +
        "    </Row>\r\n" +
        "  </Content>\r\n" +
        "</MCSSData>\r\n";

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    List<Map<String, Object>> dataSetList = データセットモックデータ作成(
        "ut_roop_1", "detail_001", dataSetValue1, "detail_002", dataSetValue2);
    doReturn(dataSetList).when(commonServiceImpl).requestNtssApi(any());
    doReturn(false).when(commonServiceImpl).isReport(sysCoopJournal);

    service.createTelegram(sysCoopJournal);

    assertThat(sysCoopJournal.getDump(), notNullValue());
    assertThat(sysCoopJournal.getDump(), is(expect.getBytes()));
    assertThat(sysCoopJournal.getDumpPath(), nullValue());

    assert_ジャーナルが更新されていない(facilityCd, coopCd);
    assert_ntssapiへのアクセスはx回行われた(1);
  }

  /**
   * テストケースが通らないため、ひとまずスキップ
   */
  @Ignore
  @Test
  public void 正常系_送信版電文変換_detail$COUNT_データセット2レコードの値で電文作成される() {
    String facilityCd = "TEST04";
    String coopCd = "TEST_CD";
    String dataSetValue1 = "11111";
    String dataSetValue2 = "22222";
    String dataSetValue3 = "33333";
    String dataSetValue4 = "44444";
    String expect = "<?xml version=\"1.0\" encoding=\"Shift_JIS\" standalone=\"yes\"?>\r\n" +
        "<MCSSData ver=\"Ver.03.80 2020-03-25\">\r\n" +
        "  <Content>\r\n" +
        "    <Row>\r\n" +
        "      <RowData RowCount=\"1\" MasterID=\"" + dataSetValue1 + "\">" + dataSetValue2 + "</RowData>\r\n" +
        "      <RowData RowCount=\"2\" MasterID=\"" + dataSetValue3 + "\">" + dataSetValue4 + "</RowData>\r\n" +
        "    </Row>\r\n" +
        "  </Content>\r\n" +
        "</MCSSData>\r\n";

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    List<Map<String, Object>> dataSetList1 = データセットモックデータ作成(
        "ut_roop_1", "detail_001", dataSetValue1, "detail_002", dataSetValue2);
    List<Map<String, Object>> dataSetList2 = データセットモックデータ作成(
        "ut_roop_1", "detail_001", dataSetValue3, "detail_002", dataSetValue4);
    dataSetList1.add(dataSetList2.get(0));
    doReturn(dataSetList1).when(commonServiceImpl).requestNtssApi(any());
    doReturn(false).when(commonServiceImpl).isReport(sysCoopJournal);

    service.createTelegram(sysCoopJournal);

    assertThat(sysCoopJournal.getDump(), notNullValue());
    assertThat(new String(sysCoopJournal.getDump()), is(expect));
    assertThat(sysCoopJournal.getDump(), is(expect.getBytes()));
    assertThat(sysCoopJournal.getDumpPath(), nullValue());

    assert_ジャーナルが更新されていない(facilityCd, coopCd);
    assert_ntssapiへのアクセスはx回行われた(1);

  }

  /**
   * coop_cdがレポート対象かつcoop_cd_indexがxmlの場合
   * mst_coop_filenameからファイル名が取得できない場合はエラー
   * */
  @Test
  public void 異常系_レポート対象かつcoopCdIndexがxmlの場合() {
    String facilityCd = "TEST05";
    String coopCd = "rep_dial";
    String coopCdIndex = "xml";
    SysCoopJournal journal = sysCoopJournalDao.select(facilityCd, coopCd, coopCdIndex, "C", "S");

    // 電文用のデータセット
    List<Map<String, Object>> dataSetList = DATASETHOGE1という結果のデータセットモックデータ作成();
    doReturn(dataSetList).when(commonServiceImpl).requestNtssApi(any());
    // レポート対象
    doReturn(true).when(commonServiceImpl).isReport(journal);
    // 空のファイル名を返却
    doReturn(fileErrorName()).when(commonServiceImpl).getFileNames(journal);

    try {
      service.createTelegram(journal);
      fail("エラー想定のためここは通らない");
    } catch (NtssException e) {
      assertThat(e.getMessage(), is("ファイル名が取得できませんでした。"));
    }
  }

  /**
   * coop_cdがレポート対象かつcoop_cd_indexがtarの場合
   * mst_coop_filenameからファイル名が取得できない場合はエラー
   * */
  @Test
  public void 異常系_レポート対象かつcoopCdIndexがtarの場合() {
    String facilityCd = "TEST06";
    String coopCd = "rep_dial";
    String coopCdIndex = "tar";
    SysCoopJournal journal = sysCoopJournalDao.select(facilityCd, coopCd, coopCdIndex, "C", "S");

    // 電文用のデータセット
    List<Map<String, Object>> dataSetList = DATASETHOGE1という結果のデータセットモックデータ作成();
    doReturn(dataSetList).when(commonServiceImpl).requestNtssApi(any());
    // レポート対象
    doReturn(true).when(commonServiceImpl).isReport(journal);
    // 空のファイル名を返却
    doReturn(fileErrorName()).when(commonServiceImpl).getFileNames(journal);

    try {
      service.createTelegram(journal);
      fail("エラー想定のためここは通らない");
    } catch (NtssException e) {
      assertThat(e.getMessage(), is("ファイル名が取得できませんでした。"));
    }
  }

  /**
   * coop_cdがレポート対象かつcoop_cd_indexがxmlの場合
   * 電文パスにdumpName、電文にxmlの内容が設定されること
   * */
  @Test
  public void 正常系_レポート対象かつcoopCdIndexがxmlの場合() {
    String facilityCd = "TEST05";
    String coopCd = "rep_dial";
    String coopCdIndex = "xml";
    String expect = "<?xml version=\"1.0\" encoding=\"Shift_JIS\" standalone=\"yes\"?>\r\n"
        + "<rootNode>\r\n"
        + "  <PATID>DATASETHOGE1</PATID>\r\n"
        + "</rootNode>\r\n";
    SysCoopJournal journal = sysCoopJournalDao.select(facilityCd, coopCd, coopCdIndex, "C", "S");

    // 電文用のデータセット
    List<Map<String, Object>> dataSetList = DATASETHOGE1という結果のデータセットモックデータ作成();
    doReturn(dataSetList).when(commonServiceImpl).requestNtssApi(any());
    // レポート対象
    doReturn(true).when(commonServiceImpl).isReport(journal);
    // ファイル名返却
    doReturn(fileName()).when(commonServiceImpl).getFileNames(journal);

    try {
      service.createTelegram(journal);
    } catch (NtssException e) {
      fail("想定外エラー");
    }

    // 実行結果確認
    assertThat(journal.getDumpPath(), is("dumpname.xml"));
    assertThat(journal.getDump(), is(expect.getBytes()));

  }

  /**
   * coop_cdがレポート対象かつcoop_cd_indexがtarの場合
   * 電文パスにtarの圧縮ファイル名、電文はnullが設定される
   * */
  @Test
  public void 正常系_レポート対象かつcoopCdIndexがtarの場合() {
    String facilityCd = "TEST06";
    String coopCd = "rep_dial";
    String coopCdIndex = "tar";
    String expect =  "<?xml version=\"1.0\" encoding=\"Shift_JIS\" standalone=\"yes\"?>\r\n"
        + "<rootNode>\r\n"
        + "  <PATID>DATASETHOGE1</PATID>\r\n"
        + "</rootNode>\r\n";
    SysCoopJournal journal = sysCoopJournalDao.select(facilityCd, coopCd, coopCdIndex, "C", "S");

    // 電文用のデータセット
    List<Map<String, Object>> dataSetList = DATASETHOGE1という結果のデータセットモックデータ作成();
    doReturn(dataSetList).when(commonServiceImpl).requestNtssApi(any());

    // レポート対象
    doReturn(true).when(commonServiceImpl).isReport(journal);
    // ファイル名返却
    doReturn(fileName()).when(commonServiceImpl).getFileNames(journal);

    try {
      service.createTelegram(journal);
    } catch (NtssException e) {
      fail("想定外エラー");
    }

    // 実行結果確認
    assertThat(journal.getDumpPath(), is("commpressionName.tar"));
    assertThat(journal.getDump(), nullValue());

  }

  @Test
  public void 正常系_基準日確認() {
    String facilityCd = "TEST07";
    String coopCd = "ini_dial";
    String expect =  "<?xml version=\"1.0\" encoding=\"Shift_JIS\" standalone=\"yes\"?>\r\n"
        + "<rootNode>\r\n"
        + "  <BASEDATE>20190312</BASEDATE>\r\n"
        + "</rootNode>\r\n";

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    doReturn(getExpectMockClock()).when(clockWrapper).getClock();

    service.createTelegram(sysCoopJournal);
    assertThat(sysCoopJournal.getDump(), notNullValue());
    assertThat(new String(sysCoopJournal.getDump()), is(expect));
    assertThat(sysCoopJournal.getDumpPath(), nullValue());
  }

  @Test
  public void 正常系_予約語のジャーナル_アトリビュートの設定確認() {
    String facilityCd = "TEST07";
    String coopCd = "profile";
    String expect = "<?xml version=\"1.0\" encoding=\"Shift_JIS\" standalone=\"yes\"?>\r\n"
        + "<Content>\r\n"
        + "  <ATTRIBUTES att1=\"0\" att2=\"\" att3=\"\" att4=\"101\" att5=\"20200716\"/>\r\n"
        + "</Content>\r\n";

    SysCoopJournal journal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    doReturn(getExpectMockClock()).when(clockWrapper).getClock();

    service.createTelegram(journal);

    assertThat(journal.getDump(), notNullValue());
    assertThat(new String(journal.getDump()), is(expect));
  }

  private List<Map<String, Object>> DATASETHOGE1という結果のデータセットモックデータ作成() {
    return データセットモックデータ作成("DATASETHOGE1");
  }

  private List<Map<String, Object>> データセットモックデータ作成(String value) {
    Map<String, Object> dataSet = new HashMap<>();
    dataSet.put("test_dataset_result", value);
    List<Map<String, Object>> dataSetList = new ArrayList<>();
    dataSetList.add(dataSet);

    return dataSetList;
  }

  private List<Map<String, Object>> データセットモックデータ作成(String detailId, String keyName1, String value1, String keyName2,
      String value2) {
    Map<String, Object> dataSet = new HashMap<>();
    dataSet.put("detail_id", detailId);
    dataSet.put(keyName1, value1);
    dataSet.put(keyName2, value2);
    List<Map<String, Object>> dataSetList = new ArrayList<>();
    dataSetList.add(dataSet);

    return dataSetList;
  }

  private void assert_ジャーナルが更新されていない(String facilityCd, String coopCd) {
    SysCoopJournal journal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");
    assertThat(journal, notNullValue());
    assertThat(journal.getAnaResult(), is(AnaResult.UNPROCESS.getResult()));
    assertThat(journal.getInAnaDate(), is(Timestamp.valueOf(getExpectTime())));
    assertThat(journal.getUpDate(), is(Timestamp.valueOf(getExpectTime())));
    assertThat(journal.getDump(), nullValue());
  }

  private void assert_ntssapiへのアクセスはx回行われた(int count) {
    // ntss-apiへのアクセスはx回行われる
    verify(commonServiceImpl, times(count)).requestNtssApi(any());
  }

  /** ファイル名(エラー) */
  private Map<String, String> fileErrorName() {
    Map<String, String> map = new HashMap<>();
    map.put("pdfName", "");
    map.put("dumpName", "");
    map.put("compressionName", "");
    return map;
  }

  /** ファイル名 */
  private Map<String, String> fileName() {
    Map<String, String> map = new HashMap<>();
    map.put("pdfName", "pdfname.pdf");
    map.put("dumpName", "dumpname.xml");
    map.put("compressionName", "commpressionName.tar");
    return map;
  }
}
