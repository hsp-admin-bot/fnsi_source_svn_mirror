package jp.co.nikkiso.ntss.coop_api.service;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.not;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.junit.Assert.assertThat;
import static org.junit.Assert.fail;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.doReturn;
import static org.mockito.BDDMockito.given;

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
import org.springframework.test.context.jdbc.SqlConfig;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.coop_api.utils.ClockWrapper;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants.AnaResult;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.DataSourceName;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.TransactionManagerName;
import jp.co.nikkiso.ntss.core.dao.MstCoopFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopFilenameDao;
import jp.co.nikkiso.ntss.core.dao.SysCoopJournalDao;
import jp.co.nikkiso.ntss.core.entity.MstCoopFacility;
import jp.co.nikkiso.ntss.core.entity.MstCoopFacility.CommonSetting;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;
import jp.co.nikkiso.ntss.core.exception.NtssException;

/**
 * ConvertSendCommonServiceImpl のテスト<br>
 * 呼び出されている処理が多いため、JournalConvertSendResourceTest でテストする
 *
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:resource.script/ConvertSendServiceImplTest/ConvertSendServiceImplTest.db5.before.sql")
public class ConvertSendCommonServiceImplTest extends BaseServiceTest {
  @SpyBean
  ConvertSendCommonServiceImpl service;
  @MockBean
  ClockWrapper clockWrapper;
  @Autowired
  SysCoopJournalDao sysCoopJournalDao;
  @SpyBean
  MstCoopFacilityDao mstCoopFacilityDao;
  @SpyBean
  MstCoopFilenameDao mstCoopFilenameDao;

  @Test
  public void 正常系_送信版電文変換_電文登録_予め用意してあるジャーナルデータにDENBUNTESTという文字列がdumpに更新され変換ステータスは処理完了となる() {
    String facilityCd = "TEST01";
    String coopCd = "TEST_CD";
    byte[] expectDump = "DENBUNTEST".getBytes();
    String expectDumpPath = "test";

    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    SysCoopJournal expect = sysCoopJournalDao.select(facilityCd, coopCd,"", "C", "S");
    // 更新前に値を退避
    byte[] bakDump = expect.getDump();
    String bakDumpPath = expect.getDumpPath();
    // 更新する値を設定
    expect.setDump(expectDump);
    expect.setDumpPath(expectDumpPath);
    service.storeTelegram(expect);

    SysCoopJournal actual = sysCoopJournalDao.select(facilityCd, coopCd,"", "C", "S");
    assertThat(actual, notNullValue());
    assertThat(actual.getDump(), not(bakDump));
    assertThat(actual.getDump(), is(expectDump));
    assertThat(actual.getDumpPath(), not(bakDumpPath));
    assertThat(actual.getDumpPath(), is(expectDumpPath));

    assertThat(actual.getAnaResult(), is(AnaResult.DONE.getResult()));
    assertThat(actual.getOutAnaDate(), is(new Timestamp(getMockClockMillis())));
    assertThat(actual.getUpDate(), is(new Timestamp(getMockClockMillis())));
  }

  // 利用者マスタの取得
  @Sql(value = "classpath:resource.script/ConvertSendServiceImplTest/db4.before.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Test
  public void 正常系_利用者マスタ検索_テスト() {

    String userId = "1001";
    String distUserId = service.getAuthId(userId);

    // 取得結果
    assertThat(distUserId, is("dispUser"));
  }

  @Test
  public void 異常系_利用者マスタ検索_テスト() {

    String userId = "0";
    try {
      // 取得失敗時
      service.getAuthId(userId);
    } catch (NtssException e) {
      assertThat(e.getMessage(), is("利用者マスタのデータ取得に失敗しました。user_id:[0]"));
    }
  }


  @Test
  public void 正常系_利用者マスタ検索_nullはOK_テスト() {


    String userId = null;
    String distUserId = service.getAuthId(userId);

    // 取得結果
    assertThat(distUserId, is(""));
  }

  /**
   * isReportの確認
   * mst_coop_facilityが取得できない場合はエラーとなること
   * */
  @Test
  public void 異常系_施設連携設定が取得できない場合() {

    given(mstCoopFacilityDao.select(any())).willReturn(連携設定マスタ(0));

    try {
      service.isReport(journal("ini_dial"));
      fail("エラー想定のためここは通らない");
    } catch (NtssException e) {
      assertThat(e.getMessage(), is("施設連携設定が存在しません。"));
    }
  }

  /**
   * isReportの確認
   * mst_coop_facility.common_settingが取得できない場合はエラーとなること
   * */
  @Test
  public void 異常系_施設連携設定の共通設定がされていない場合() {

    given(mstCoopFacilityDao.select(any())).willReturn(連携設定マスタ(1));

    try {
      service.isReport(journal("ini_dial"));
      fail("エラー想定のためここは通らない");
    } catch (NtssException e) {
      assertThat(e.getMessage(), is("施設連携設定内の各機能共通設定が存在しません。"));
    }
  }

  /**
   * isReportの確認
   * mst_coop_facility.common_settingからcoopOrdCdが取得できない場合はエラーとなること
   * */
  @Test
  public void 異常系_施設連携設定のオーダ種別設定がされていない場合() {

    given(mstCoopFacilityDao.select(any())).willReturn(連携設定マスタ(2));

    try {
      service.isReport(journal("ini_dial"));
      fail("エラー想定のためここは通らない");
    } catch (NtssException e) {
      assertThat(e.getMessage(), is("オーダー種別設定が存在しません。"));
    }
  }

  /**
   * isReportの確認
   * mst_coop_facilityからレポート設定の取得
   * */
  @Test
  public void 正常系_レポートの判定() {

    boolean isReort = service.isReport(journal("ini_dial"));
    assertThat(isReort, is(false));

    isReort = service.isReport(journal("rep_dial"));
    assertThat(isReort, is(true));
  }

  /**
   * getFileNamesの確認
   * mst_coop_filenameが取得できない場合エラー
   * */
  @Test
  public void 異常系_ファイル名の取得() {

    given(mstCoopFilenameDao.select(any(),any(), any(), any())).willReturn(null);

    try {
      service.getFileNames(journal(""));
      fail("エラー想定のためここは通らない");
    } catch (NtssException e) {
      assertThat(e.getMessage(), is("外部連携用ファイル名が取得できません。"));
    }
  }

  /**
   * getFileNamesの確認
   * mst_coop_filenameの設定によりsys_data_setからファイル名を取得する
   * */
  @Test
  public void 正常系_ファイル名の取得() {

    List<Map<String, Object>> dataSetList = ファイル名データセットモックデータ();
    doReturn(dataSetList).when(service).requestNtssApi(any());

    try {
      Map<String, String> map = service.getFileNames(journal("rep_dial"));
      // requestNtssApiで取得したファイル名が設定される
      assertThat(map.get("pdfName"), is("sample.txt"));
      assertThat(map.get("dumpName"), is("sample.txt"));
      assertThat(map.get("compressionName"), is("sample.txt"));

    } catch (NtssException e) {
      fail("想定外エラー");
    }
  }

  /** 連携設定マスタのデータモック */
  private MstCoopFacility 連携設定マスタ(int level) {
    MstCoopFacility facility = new MstCoopFacility();
    if (level == 1) {
      return facility;
    }
    if (level == 2) {
      facility.setCommonSetting(new CommonSetting());
      return facility;
    }
    return null;
  }

  /** sys_coop_journalのデータモック */
  private SysCoopJournal journal(String coopCd) {
    SysCoopJournal journal = new SysCoopJournal();
    journal.setFacilityCd("TEST01");
    journal.setCoopCd(coopCd);
    journal.setCoopCdIndex("pdf");
    journal.setReportCd(1L);
    journal.setPatId(1L);
    journal.setOrdNo(1L);
    return journal;
  }

  /** api結果返却用モック */
  private List<Map<String, Object>> ファイル名データセットモックデータ() {
    Map<String, Object> dataSet = new HashMap<>();
    dataSet.put("filename", "sample.txt");
    List<Map<String, Object>> dataSetList = new ArrayList<>();
    dataSetList.add(dataSet);
    return dataSetList;
  }
}
