package jp.co.nikkiso.ntss.coop_api.service;

import static org.assertj.core.api.Assertions.fail;
import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.notNullValue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.anyLong;
import static org.mockito.BDDMockito.anyString;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.times;
import static org.mockito.BDDMockito.verify;

import java.io.File;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.boot.test.mock.mockito.SpyBean;
import org.springframework.test.context.junit4.SpringRunner;

import com.amazonaws.util.Base64;

import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.coop_api.mapping.DeliveryResult;
import jp.co.nikkiso.ntss.coop_api.response.DeliveryResults;
import jp.co.nikkiso.ntss.coop_api.utils.AmazonS3Wrapper;
import jp.co.nikkiso.ntss.coop_api.utils.ClockWrapper;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.SysCoopJournalDao;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.custom.JournalDistribute;

@RunWith(SpringRunner.class)
@SpringBootTest
public class DeliveryServiceImplTest extends BaseServiceTest {
  @SpyBean
  DeliveryServiceImpl service;

  @MockBean
  AmazonS3Wrapper amazonS3Wrapper;

  @SpyBean
  SysCoopJournalDao sysCoopJournalDao;

  @MockBean
  ClockWrapper clockWrapper;

  @SpyBean
  PatPersonalMainDao patPersonalMainDao;

  @SpyBean
  OrdMainDao ordMainDao;

  @Test
  public void 正常系_S3経由_ジャーナルデータ1つある場合_1回S3接続処理が実行される() {
    try {
      // S3取得処理はモック化
      given(amazonS3Wrapper.getS3ObjectByteArray(anyString())).willReturn(getMockByteArray());
      List<JournalDistribute> journalDistributeList = getJournalDataList();
      File expectFile = new File(getClass().getClassLoader().getResource("resource.json/DeliveryServiceImplTest/journal_file_protocol.json").getFile());
      DeliveryResults expect = ObjectMapperUtil.readFile(expectFile, DeliveryResults.class);
      DeliveryResults actual = service.execute(journalDistributeList);
      assertion(actual, expect);
      verify(amazonS3Wrapper, times(1)).getS3ObjectByteArray(anyString());
      verify(sysCoopJournalDao, times(0)).updateByCoopResult(any(), anyString(), any());
    } catch (IOException e) {
      fail("ジャーナル配信処理に失敗しました。", e);
    }
  }

  @Test
  public void 正常系_S3経由_ジャーナルデータ2つある場合_2回S3接続処理が実行される() {
    try {
      // S3取得処理はモック化
      given(amazonS3Wrapper.getS3ObjectByteArray(anyString())).willReturn(getMockByteArray());
      List<JournalDistribute> journalDistributeList = getJournalDataListWithCoopIndex();
      File expectFile = new File(getClass().getClassLoader().getResource("resource.json/DeliveryServiceImplTest/array_journal_file_protocol_with_coop_index.json").getFile());
      DeliveryResults expect = ObjectMapperUtil.readFile(expectFile, DeliveryResults.class);
      DeliveryResults actual = service.execute(journalDistributeList );
      assertion(actual, expect);
      verify(amazonS3Wrapper, times(2)).getS3ObjectByteArray(anyString());
      verify(sysCoopJournalDao, times(0)).updateByCoopResult(any(), anyString(), any());
    } catch (IOException e) {
      fail("ジャーナル配信処理に失敗しました。", e);
    }
  }

  @Test
  public void 正常系_S3とDB混合_S3経由が2つあり残りはDBの場合_2回S3接続処理が実行される() {
    try {
      // S3取得処理はモック化
      given(amazonS3Wrapper.getS3ObjectByteArray(anyString())).willReturn(getMockByteArray());
      List<JournalDistribute> journalDistributeList = getJournalDataListCoopIndexAndDump();
      File expectFile = new File(getClass().getClassLoader().getResource("resource.json/DeliveryServiceImplTest/array_journal_file_protocol_with_coop_index_and_db_dump.json").getFile());
      DeliveryResults expect = ObjectMapperUtil.readFile(expectFile, DeliveryResults.class);
      DeliveryResults actual = service.execute(journalDistributeList);
      assertion(actual, expect);
      verify(amazonS3Wrapper, times(2)).getS3ObjectByteArray(anyString());
      verify(sysCoopJournalDao, times(0)).updateByCoopResult(any(), anyString(), any());
    } catch (IOException e) {
      fail("ジャーナル配信処理に失敗しました。", e);
    }
  }

  @Test
  public void 正常系_配信ジャーナルが空の場合_空のリストが返される() {
    try {
      // S3取得処理はモック化
      given(amazonS3Wrapper.getS3ObjectByteArray(anyString())).willReturn(getMockByteArray());
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());

      List<JournalDistribute> journalDistributeList = new ArrayList<>();
      DeliveryResults actual = service.execute(journalDistributeList);

      assertThat(actual, is(notNullValue()));
      assertThat(actual.getStatus(), is(200));
      assertThat(actual.getResult(), is(notNullValue()));
      assertThat(actual.getResult(), hasSize(0));
      // 呼び出し確認
      verify(amazonS3Wrapper, times(0)).getS3ObjectByteArray(anyString());
      verify(sysCoopJournalDao, times(0)).updateByCoopResult(any(), anyString(), any());
    } catch (IOException e) {
      fail("ジャーナル配信処理に失敗しました。", e);
    }
  }

  @Test
  public void 異常系_変換処理に失敗した場合_E1での更新処理が実行される() {
    try {
      // S3取得処理はモック化
      given(amazonS3Wrapper.getS3ObjectByteArray(anyString())).willReturn(getMockByteArray());
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());

      List<JournalDistribute> journalDistributeList = getErrorJournalDataList();
      List<Long> ctlNoList = journalDistributeList.stream().map(e -> e.getCtlNo()).collect(Collectors.toList());

      DeliveryResults actual = service.execute(journalDistributeList);

      assertThat(actual, is(notNullValue()));
      assertThat(actual.getStatus(), is(200));
      assertThat(actual.getResult(), is(notNullValue()));
      assertThat(actual.getResult(), hasSize(0));
      assertThat(journalDistributeList.isEmpty(), is(true));
      // 呼び出し確認
      verify(amazonS3Wrapper, times(0)).getS3ObjectByteArray(anyString());
      verify(sysCoopJournalDao, times(1)).updateByCoopResult(ctlNoList.toString(), "E1", Timestamp.valueOf(getExpectMockTime()));
    } catch (IOException e) {
      fail("ジャーナル配信処理に失敗しました。", e);
    }
  }

  @Test
  public void 異常系_正常データと異常データが混合している場合_異常データ分はE1での更新処理が実行される() {
    try {
      // S3取得処理はモック化
      given(amazonS3Wrapper.getS3ObjectByteArray(anyString())).willReturn(getMockByteArray());
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      List<JournalDistribute> journalDistributeList = getErrorJournalDataList();
      List<Long> ctlNoList = journalDistributeList.stream().map(e -> e.getCtlNo()).collect(Collectors.toList());
      journalDistributeList.addAll(getJournalDataList());
      File expectFile = new File(getClass().getClassLoader().getResource("resource.json/DeliveryServiceImplTest/journal_file_protocol.json").getFile());
      DeliveryResults expect = ObjectMapperUtil.readFile(expectFile, DeliveryResults.class);

      DeliveryResults actual = service.execute(journalDistributeList);
      assertion(actual, expect);

      // 呼び出し確認
      verify(amazonS3Wrapper, times(1)).getS3ObjectByteArray(anyString());
      verify(sysCoopJournalDao, times(1)).updateByCoopResult(ctlNoList.toString(), "E1", Timestamp.valueOf(getExpectMockTime()));
    } catch (IOException e) {
      fail("ジャーナル配信処理に失敗しました。", e);
    }
  }

  /**
   * $HOSP_PAT_IDが置換されること確認
   * ※journal_distribute.distribute_settingの特定文字列の置換
   * */
  @Test
  public void 正常系_固定文字列の置換されることを確認() {
    try {
      // S3取得処理はモック化
      given(amazonS3Wrapper.getS3ObjectByteArray(anyString())).willReturn(getMockByteArray());
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());

      List<JournalDistribute> journalDistributeList = getJournalDataListReplace();
      File expectFile = new File(getClass().getClassLoader().getResource("resource.json/DeliveryServiceImplTest/journal_file_protocol_replace.json").getFile());
      DeliveryResults expect = ObjectMapperUtil.readFile(expectFile, DeliveryResults.class);

      DeliveryResults actual = service.execute(journalDistributeList);
      assertion(actual, expect);

      // 呼び出し確認
      verify(amazonS3Wrapper, times(1)).getS3ObjectByteArray(anyString());
      verify(sysCoopJournalDao, times(0)).updateByCoopResult(any(), anyString(), any());
    } catch (IOException e) {
      fail("ジャーナル配信処理に失敗しました。", e);
    }
  }

  /**
   * $HOSP_PAT_IDが置換されること確認
   * sys_coop_journalに患者番号が設定されていない場合、
   * オーダ番号から治療情報→患者基本情報で取得する
   * */
  public void 正常系_治療情報から患者情報を取得して固定文字列の置換確認() {
    try {
      // S3取得処理はモック化
      given(amazonS3Wrapper.getS3ObjectByteArray(anyString())).willReturn(getMockByteArray());
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      given(ordMainDao.selectByOrdNo(anyLong())).willReturn(getOrdMain());
      given(patPersonalMainDao.selectById(anyLong())).willReturn(getPatPersonalMain());

      List<JournalDistribute> journalDistributeList = getJournalDataListReplace2();
      File expectFile = new File(getClass().getClassLoader().getResource("resource.json/DeliveryServiceImplTest/journal_file_protocol_replace.json").getFile());
      DeliveryResults expect = ObjectMapperUtil.readFile(expectFile, DeliveryResults.class);

      DeliveryResults actual = service.execute(journalDistributeList);
      assertion(actual, expect);

      // 呼び出し確認
      verify(amazonS3Wrapper, times(1)).getS3ObjectByteArray(anyString());
      verify(sysCoopJournalDao, times(0)).updateByCoopResult(any(), anyString(), any());
    } catch (IOException e) {
      fail("ジャーナル配信処理に失敗しました。", e);
    }
  }

  /**
   * 患者番号(システム・連携用)、オーダ番号で表示用患者IDが取得できない場合エラーとする
   * */
  @Test
  public void 異常系_患者IDが取得できない場合_E1での更新処理が実行される() {
    try {
      // S3取得処理はモック化
      given(amazonS3Wrapper.getS3ObjectByteArray(anyString())).willReturn(getMockByteArray());
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());

      List<JournalDistribute> journalDistributeList = getJournalDataListReplaceError();
      List<Long> ctlNoList = journalDistributeList.stream().map(e -> e.getCtlNo()).collect(Collectors.toList());

      DeliveryResults actual = service.execute(journalDistributeList);

      assertThat(actual, is(notNullValue()));
      assertThat(actual.getStatus(), is(200));
      assertThat(actual.getResult(), is(notNullValue()));
      assertThat(actual.getResult(), hasSize(0));
      assertThat(journalDistributeList.isEmpty(), is(true));
      // 呼び出し確認
      verify(amazonS3Wrapper, times(0)).getS3ObjectByteArray(anyString());
      verify(sysCoopJournalDao, times(1)).updateByCoopResult(ctlNoList.toString(), "E1", Timestamp.valueOf(getExpectMockTime()));
    } catch (IOException e) {
      fail("ジャーナル配信処理に失敗しました。", e);
    }
  }

  private void assertion(DeliveryResults actual, DeliveryResults expect) {
    assertThat(actual, is(notNullValue()));
    assertThat(actual.getResult(), is(notNullValue()));
    assertThat(actual.getResult().isEmpty(), is(false));
    assertThat(actual.getResult().size(), is(expect.getResult().size()));

    for(int i = 0; i < actual.getResult().size(); i++) {
      DeliveryResult actualResult = actual.getResult().get(i);
      DeliveryResult expectResult = expect.getResult().get(i);

      assertThat(actualResult.getData(), is(notNullValue()));
      assertThat(actualResult.getJournalInfo(), is(notNullValue()));
      assertThat(actualResult.getProtocolInfo(), is(notNullValue()));

      assertThat(actualResult.getData().getFileName(), is(expectResult.getData().getFileName()));
      assertThat(actualResult.getData().getDump(), is(expectResult.getData().getDump()));

      assertThat(actualResult.getJournalInfo().getCtlNo(), is(expectResult.getJournalInfo().getCtlNo()));
      assertThat(actualResult.getJournalInfo().getCoopCd(), is(expectResult.getJournalInfo().getCoopCd()));
      assertThat(actualResult.getJournalInfo().getCoopCdIndex(), is(expectResult.getJournalInfo().getCoopCdIndex()));

      assertThat(actualResult.getProtocolInfo().getProtocol(), is(expectResult.getProtocolInfo().getProtocol()));
      assertThat(actualResult.getProtocolInfo().getAddress(), is(expectResult.getProtocolInfo().getAddress()));
      assertThat(actualResult.getProtocolInfo().getRenameWhenCopying(), is(expectResult.getProtocolInfo().getRenameWhenCopying()));
      assertThat(actualResult.getProtocolInfo().getDummy(), is(expectResult.getProtocolInfo().getDummy()));
      assertThat(actualResult.getProtocolInfo().getDelete(), is(expectResult.getProtocolInfo().getDelete()));
    }
  }

  private List<JournalDistribute> getJournalDataList() {
    List<JournalDistribute> journalDistributeList = new ArrayList<>();
    JournalDistribute journalDistribute = new JournalDistribute();
    journalDistribute.setFacilityCd("TEST01");
    journalDistribute.setCtlNo(1L);
    journalDistribute.setCoopCd("1");
    journalDistribute.setCoopCdIndex("");
    journalDistribute.setOrdNo(1L);
    journalDistribute.setHospPatId("000000000001");
    journalDistribute.setPatId(1L);
    journalDistribute.setDumpPath("TEST.txt");
    journalDistribute.setDistributeSetting("{\"protocolInfo\": {\"dummy\": \"\", \"delete\": \"\", \"address\": \"C:\\\\work\\\\distination\\\\\", \"protocol\": \"file\", \"renameWhenCopying\": \"\"}}");
    journalDistributeList.add(journalDistribute);
    return journalDistributeList;
  }

  private List<JournalDistribute> getJournalDataListWithCoopIndex() {
    List<JournalDistribute> journalDistributeList = getJournalDataList();
    JournalDistribute journalDistribute = new JournalDistribute();
    journalDistribute.setFacilityCd("TEST01");
    journalDistribute.setCtlNo(2L);
    journalDistribute.setCoopCd("2");
    journalDistribute.setCoopCdIndex("1");
    journalDistribute.setOrdNo(2L);
    journalDistribute.setHospPatId("000000000002");
    journalDistribute.setPatId(2L);
    journalDistribute.setDumpPath("TEST_COOP_INDEX.txt");
    journalDistribute.setDistributeSetting("{\"protocolInfo\": {\"dummy\": \"\", \"delete\": \"\", \"address\": \"C:\\\\work\\\\distination\\\\\", \"protocol\": \"file\", \"renameWhenCopying\": \"\"}}");
    journalDistributeList.add(journalDistribute);
    return journalDistributeList;
  }

  private List<JournalDistribute> getJournalDataListCoopIndexAndDump() {
    List<JournalDistribute> journalDistributeList = getJournalDataListWithCoopIndex();
    JournalDistribute journalDistribute = new JournalDistribute();
    journalDistribute.setFacilityCd("TEST01");
    journalDistribute.setCtlNo(3L);
    journalDistribute.setCoopCd("3");
    journalDistribute.setCoopCdIndex("1");
    journalDistribute.setOrdNo(3L);
    journalDistribute.setHospPatId("000000000003");
    journalDistribute.setPatId(3L);
    journalDistribute.setDumpPath("TEST_COOP_INDEX.txt");
    journalDistribute.setDump(Base64.decode("VEVTVF9NT0NL".getBytes()));
    journalDistribute.setDistributeSetting("{\"protocolInfo\": {\"dummy\": \"\", \"delete\": \"\", \"address\": \"C:\\\\work\\\\distination\\\\\", \"protocol\": \"file\", \"renameWhenCopying\": \"\"}}");
    journalDistributeList.add(journalDistribute);
    return journalDistributeList;
  }

  private byte[] getMockByteArray() {
    return "TEST_MOCK".getBytes();
  }

  private List<JournalDistribute> getErrorJournalDataList() {
    List<JournalDistribute> journalDistributeList = new ArrayList<>();
    JournalDistribute journalDistribute = new JournalDistribute();
    journalDistribute.setFacilityCd("TEST01");
    journalDistribute.setCtlNo(4L);
    journalDistribute.setCoopCd("4");
    journalDistribute.setCoopCdIndex("");
    journalDistribute.setOrdNo(4L);
    journalDistribute.setHospPatId("000000000004");
    journalDistribute.setPatId(4L);
    journalDistribute.setDumpPath("TEST.txt");
    journalDistribute.setDistributeSetting("{\"info\": {\"dummy\": \"\", \"delete\": \"\", \"address\": \"C:\\\\work\\\\distination\\\\\", \"protocol\": \"file\", \"renameWhenCopying\": \"\"}}");
    journalDistributeList.add(journalDistribute);

    journalDistribute = new JournalDistribute();
    journalDistribute.setFacilityCd("TEST01");
    journalDistribute.setCtlNo(5L);
    journalDistribute.setCoopCd("5");
    journalDistribute.setCoopCdIndex("");
    journalDistribute.setOrdNo(5L);
    journalDistribute.setHospPatId("000000000005");
    journalDistribute.setPatId(5L);
    journalDistribute.setDumpPath("TEST.txt");
    journalDistribute.setDistributeSetting("{\"protocolInfo\": {\"dmy\": \"\", \"delete\": \"\", \"address\": \"C:\\\\work\\\\distination\\\\\", \"protocol\": \"file\", \"renameWhenCopying\": \"\"}}");
    journalDistributeList.add(journalDistribute);

    return journalDistributeList;
  }

  private List<JournalDistribute> getJournalDataListReplace() {
    List<JournalDistribute> journalDistributeList = new ArrayList<>();
    JournalDistribute journalDistribute = new JournalDistribute();
    journalDistribute.setFacilityCd("TEST01");
    journalDistribute.setCtlNo(6L);
    journalDistribute.setCoopCd("6");
    journalDistribute.setCoopCdIndex("");
    journalDistribute.setOrdNo(6L);
    journalDistribute.setHospPatId("000000000006");
    journalDistribute.setPatId(6L);
    journalDistribute.setDumpPath("TEST.txt");
    journalDistribute.setDistributeSetting("{\"protocolInfo\": {\"dummy\": \"\", \"delete\": \"\", \"address\": \"C:\\\\work\\\\distination\\\\$HOSP_PAT_ID\", \"protocol\": \"file\", \"renameWhenCopying\": \"\"}}");
    journalDistributeList.add(journalDistribute);
    return journalDistributeList;
  }

  private List<JournalDistribute> getJournalDataListReplace2() {
    List<JournalDistribute> journalDistributeList = new ArrayList<>();
    JournalDistribute journalDistribute = new JournalDistribute();
    journalDistribute.setFacilityCd("TEST01");
    journalDistribute.setCtlNo(6L);
    journalDistribute.setCoopCd("6");
    journalDistribute.setCoopCdIndex("");
    journalDistribute.setOrdNo(6L);
    journalDistribute.setHospPatId(null);
    journalDistribute.setPatId(null);
    journalDistribute.setDumpPath("TEST.txt");
    journalDistribute.setDistributeSetting("{\"protocolInfo\": {\"dummy\": \"\", \"delete\": \"\", \"address\": \"C:\\\\work\\\\distination\\\\$HOSP_PAT_ID\", \"protocol\": \"file\", \"renameWhenCopying\": \"\"}}");
    journalDistributeList.add(journalDistribute);
    return journalDistributeList;
  }

  private List<JournalDistribute> getJournalDataListReplaceError() {
    List<JournalDistribute> journalDistributeList = new ArrayList<>();
    JournalDistribute journalDistribute = new JournalDistribute();
    journalDistribute.setFacilityCd("TEST01");
    journalDistribute.setCtlNo(6L);
    journalDistribute.setCoopCd("6");
    journalDistribute.setCoopCdIndex("");
    journalDistribute.setOrdNo(0L);
    journalDistribute.setHospPatId("");
    journalDistribute.setPatId(null);
    journalDistribute.setDumpPath("TEST.txt");
    journalDistribute.setDistributeSetting("{\"protocolInfo\": {\"dummy\": \"\", \"delete\": \"\", \"address\": \"C:\\\\work\\\\distination\\\\$HOSP_PAT_ID\", \"protocol\": \"file\", \"renameWhenCopying\": \"\"}}");
    journalDistributeList.add(journalDistribute);
    return journalDistributeList;
  }

  private OrdMain getOrdMain() {
    OrdMain om = new OrdMain();
    om.setPatId(6L);
    return om;
  }

  private PatPersonalMain getPatPersonalMain() {
    PatPersonalMain ppm = new PatPersonalMain();
    ppm.setPat_id(6L);
    ppm.setHosp_pat_id("000000000006");
    return ppm;
  }

}
