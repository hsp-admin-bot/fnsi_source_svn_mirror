package jp.co.nikkiso.ntss.coop_api.web.rest;

import static org.assertj.core.api.Assertions.fail;
import static org.hamcrest.Matchers.empty;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.notNullValue;
import static org.junit.Assert.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.anyInt;
import static org.mockito.BDDMockito.anyString;
import static org.mockito.BDDMockito.doThrow;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.times;
import static org.mockito.BDDMockito.verify;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.io.File;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Base64;
import java.util.Collection;
import java.util.List;
import java.util.stream.Collectors;

import org.apache.commons.codec.binary.Hex;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.boot.test.mock.mockito.SpyBean;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.coop_api.request.HealthUpdateRequest;
import jp.co.nikkiso.ntss.coop_api.request.JournalCreateRequest;
import jp.co.nikkiso.ntss.coop_api.request.JournalDeliveryRequest;
import jp.co.nikkiso.ntss.coop_api.request.JournalUpdateRequest;
import jp.co.nikkiso.ntss.coop_api.service.DeliveryService;
import jp.co.nikkiso.ntss.coop_api.service.HealthService;
import jp.co.nikkiso.ntss.coop_api.utils.AmazonS3Wrapper;
import jp.co.nikkiso.ntss.coop_api.utils.ClockWrapper;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants.AnaResult;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants.CoopResult;
import jp.co.nikkiso.ntss.core.dao.MntIfEdgeHealthmonDao;
import jp.co.nikkiso.ntss.core.dao.SysCoopJournalDao;
import jp.co.nikkiso.ntss.core.dao.SysCoopJournalWithMstCoopDistributeDao;
import jp.co.nikkiso.ntss.core.entity.MntIfEdgeHealthmon;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;
import jp.co.nikkiso.ntss.core.entity.custom.JournalDistribute;
import jp.co.nikkiso.ntss.core.exception.NtssException;

@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
@Sql("classpath:resource.script/JournalResourceTest/JournalResourceTest.db5.before.sql")
public class JournalResourceTest extends AbstractResourceTest {
  @SpyBean
  private DeliveryService deliveryService;

  @SpyBean
  private HealthService healthService;

  @MockBean
  AmazonS3Wrapper amazonS3Wrapper;

  @MockBean
  ClockWrapper clockWrapper;

  @SpyBean
  private SysCoopJournalDao sysCoopJournalDao;

  @Autowired
  private SysCoopJournalWithMstCoopDistributeDao sysCoopJournalWithMstCoopDistributeDao;

  @SpyBean
  private MntIfEdgeHealthmonDao mntIfEdgeHealthmonDao;

  @Test
  public void 正常系_ジャーナル更新API_リクエストパラメータ通り正しく登録されている_全部入力されている() {
    File expectFile = new File(
      getClass().getClassLoader().getResource("resource.json/JournalResourceTest/update_all.json").getFile());
    try {
      JournalUpdateRequest expect = ObjectMapperUtil.readFile(expectFile, JournalUpdateRequest.class);
      mockMvc
        .perform(post("/journal/update")
          .content(ObjectMapperUtil.write(expect))
          .contentType(MediaType.APPLICATION_JSON))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status", is(200)))
        .andExpect(jsonPath("$.ctl_no", is(expect.getCtlNo().intValue())))
        .andExpect(jsonPath("$.ana_result", is(expect.getAnaResult())))
        .andExpect(jsonPath("$.coop_result", is(expect.getCoopResult())))
        .andExpect(jsonPath("$.dump_path", is(expect.getDumpPath())))
        .andExpect(jsonPath("$.user_id", is(234)));
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang end
      fail("ジャーナル更新に失敗しました", e);
    }
  }

  @Test
  public void 異常系_ジャーナル更新API_ユーザIDがリクエストパラメータにない場合400を返す() {
    File expectFile = new File(getClass().getClassLoader()
      .getResource("resource.json/JournalResourceTest/update_error_user_id.json").getFile());
    try {
      JournalUpdateRequest expect = ObjectMapperUtil.readFile(expectFile, JournalUpdateRequest.class);
      mockMvc
        .perform(post("/journal/update")
          .content(ObjectMapperUtil.write(expect))
          .contentType(MediaType.APPLICATION_JSON))
        .andExpect(status().is(HttpStatus.BAD_REQUEST.value()))
        .andExpect(jsonPath("$.status", is(400)));
    } catch (Exception e) {
      fail("ジャーナル更新に失敗しました", e);
    }
  }

  @Test
  public void 正常系_ジャーナル作成API_連携システムオーダ番号が数値ではない場合エラーとならないこと() {
    File expectFile = new File(getClass().getClassLoader()
      .getResource("resource.json/JournalResourceTest/create_not_numeric_coop_ord_no.json").getFile());

    try {
      JournalCreateRequest expect = ObjectMapperUtil.readFile(expectFile, JournalCreateRequest.class);
      mockMvc
        .perform(post("/journal/create")
          .content(ObjectMapperUtil.write(expect))
          .contentType(MediaType.APPLICATION_JSON))
        .andExpect(status().is(HttpStatus.OK.value()))
        .andExpect(jsonPath("$.status", is(200)));
    } catch (Exception e) {
      fail("ジャーナル作成に失敗しました", e);
    }
  }

  @Test
  public void 正常系_ジャーナル作成API_連携システム患者番号が数値ではない場合エラーとならないこと() {
    File expectFile = new File(getClass().getClassLoader()
      .getResource("resource.json/JournalResourceTest/create_not_numeric_hosp_pat_id.json").getFile());

    try {
      JournalCreateRequest expect = ObjectMapperUtil.readFile(expectFile, JournalCreateRequest.class);
      mockMvc
        .perform(post("/journal/create")
          .content(ObjectMapperUtil.write(expect))
          .contentType(MediaType.APPLICATION_JSON))
        .andExpect(status().is(HttpStatus.OK.value()))
        .andExpect(jsonPath("$.status", is(200)));
    } catch (Exception e) {
      fail("ジャーナル作成に失敗しました", e);
    }
  }

  @Test
  public void 正常系_ジャーナル作成API_リクエストパラメータ通り正しく登録されている_全部入力されている_index作成なし() {
    File expectFile = new File(
      getClass().getClassLoader().getResource("resource.json/JournalResourceTest/create_all.json").getFile());

    try {
      JournalCreateRequest expect = ObjectMapperUtil.readFile(expectFile, JournalCreateRequest.class);
      mockMvc
        .perform(post("/journal/create")
          .content(ObjectMapperUtil.write(expect))
          .contentType(MediaType.APPLICATION_JSON))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status", is(200)))
        .andExpect(jsonPath("$.result[0].facility_cd", is(expect.getFacilityCd())))
        .andExpect(jsonPath("$.result[0].coop_cd", is(expect.getCoopCd())))
        .andExpect(jsonPath("$.result[0].coop_cd_index", is(expect.getCoopCdIndex())))
        .andExpect(jsonPath("$.result[0].crud", is(expect.getCrud())))
        .andExpect(jsonPath("$.result[0].direction", is(expect.getDirection())))
        .andExpect(jsonPath("$.result[0].ord_no", is(expect.getOrdNo().intValue())))
        .andExpect(jsonPath("$.result[0].coop_ord_no", is(expect.getCoopOrdNo())))
        .andExpect(jsonPath("$.result[0].hosp_pat_id", is(expect.getHospPatId())))
        .andExpect(jsonPath("$.result[0].pat_id", is(expect.getPatId().intValue())))
        .andExpect(jsonPath("$.result[0].ana_result", is(expect.getAnaResult())))
        .andExpect(jsonPath("$.result[0].coop_result", is(expect.getCoopResult())))
        .andExpect(jsonPath("$.result[0].message64",
          is(new String(Base64.getDecoder().decode(expect.getMessage64().getBytes())))))
        .andExpect(jsonPath("$.result[0].user_id", is(123)))
        .andExpect(jsonPath("$.result[0].base_date", is("2020-06-02")));
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang end
      fail("ジャーナル作成に失敗しました", e);
    }
  }

  @Test
  public void 正常系_ジャーナル作成API_リクエストパラメータ通り正しく登録されている_全部入力されている_index作成あり() {
    File expectFile = new File(getClass().getClassLoader()
      .getResource("resource.json/JournalResourceTest/create_all_withindex.json").getFile());

    try {
      JournalCreateRequest expect = ObjectMapperUtil.readFile(expectFile, JournalCreateRequest.class);
      mockMvc
        .perform(post("/journal/create")
          .content(ObjectMapperUtil.write(expect))
          .contentType(MediaType.APPLICATION_JSON))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status", is(200)))
        .andExpect(jsonPath("$.result[0].facility_cd", is(expect.getFacilityCd())))
        .andExpect(jsonPath("$.result[0].coop_cd", is(expect.getCoopCd())))
        .andExpect(jsonPath("$.result[0].coop_cd_index", is(expect.getCoopCdIndex())))
        .andExpect(jsonPath("$.result[0].crud", is(expect.getCrud())))
        .andExpect(jsonPath("$.result[0].direction", is(expect.getDirection())))
        .andExpect(jsonPath("$.result[0].ord_no", is(expect.getOrdNo().intValue())))
        .andExpect(jsonPath("$.result[0].coop_ord_no", is(expect.getCoopOrdNo())))
        .andExpect(jsonPath("$.result[0].hosp_pat_id", is(expect.getHospPatId())))
        .andExpect(jsonPath("$.result[0].pat_id", is(expect.getPatId().intValue())))
        .andExpect(jsonPath("$.result[0].ana_result", is(expect.getAnaResult())))
        .andExpect(jsonPath("$.result[0].coop_result", is(expect.getCoopResult())))
        .andExpect(jsonPath("$.result[0].message64",
          is(new String(Base64.getDecoder().decode(expect.getMessage64().getBytes())))))
        .andExpect(jsonPath("$.result[0].user_id", is(123)))
        .andExpect(jsonPath("$.result[0].base_date", is("2020-06-02")))

        .andExpect(jsonPath("$.result[1].facility_cd", is(expect.getFacilityCd())))
        .andExpect(jsonPath("$.result[1].coop_cd", is(expect.getCoopCd())))
        .andExpect(jsonPath("$.result[1].coop_cd_index", is("index")))
        .andExpect(jsonPath("$.result[1].crud", is(expect.getCrud())))
        .andExpect(jsonPath("$.result[1].direction", is(expect.getDirection())))
        .andExpect(jsonPath("$.result[1].ord_no", is(expect.getOrdNo().intValue())))
        .andExpect(jsonPath("$.result[1].coop_ord_no", is(expect.getCoopOrdNo())))
        .andExpect(jsonPath("$.result[1].hosp_pat_id", is(expect.getHospPatId())))
        .andExpect(jsonPath("$.result[1].pat_id", is(expect.getPatId().intValue())))
        .andExpect(jsonPath("$.result[1].ana_result", is(expect.getAnaResult())))
        .andExpect(jsonPath("$.result[1].coop_result", is(expect.getCoopResult())))
        .andExpect(jsonPath("$.result[1].message64",
          is(new String(Base64.getDecoder().decode(expect.getMessage64().getBytes())))))
        .andExpect(jsonPath("$.result[1].user_id", is(123)))
        .andExpect(jsonPath("$.result[1].base_date", is("2020-06-02")));
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang end
      fail("ジャーナル作成に失敗しました", e);
    }
  }

  @Test
  public void 異常系_ジャーナル作成API_ユーザIDがリクエストパラメータにない場合400を返す() {
    File expectFile = new File(getClass().getClassLoader()
      .getResource("resource.json/JournalResourceTest/create_error_user_id.json").getFile());

    try {
      JournalCreateRequest expect = ObjectMapperUtil.readFile(expectFile, JournalCreateRequest.class);
      mockMvc
        .perform(post("/journal/create")
          .content(ObjectMapperUtil.write(expect))
          .contentType(MediaType.APPLICATION_JSON))
        .andExpect(status().is(HttpStatus.BAD_REQUEST.value()))
        .andExpect(jsonPath("$.status", is(400)));
    } catch (Exception e) {
      fail("ジャーナル作成に失敗しました", e);
    }
  }

  @Test
  public void 異常系_ジャーナル作成API_連携設定データが存在しない場合204を返す() {
    File expectFile = new File(getClass().getClassLoader()
      .getResource("resource.json/JournalResourceTest/create_error_facility_cd.json").getFile());

    try {
      JournalCreateRequest expect = ObjectMapperUtil.readFile(expectFile, JournalCreateRequest.class);
      mockMvc
        .perform(post("/journal/create")
          .content(ObjectMapperUtil.write(expect))
          .contentType(MediaType.APPLICATION_JSON))
        .andExpect(status().is(HttpStatus.NO_CONTENT.value()))
        .andExpect(jsonPath("$.status", is(204)));
    } catch (Exception e) {
      fail("ジャーナル作成に失敗しました", e);
    }
  }

  @Test
  public void 異常系_ジャーナル作成API_電文種別が連携対象でない場合204を返す() {
    File expectFile = new File(getClass().getClassLoader()
      .getResource("resource.json/JournalResourceTest/create_error_coop_cd.json").getFile());

    try {
      JournalCreateRequest expect = ObjectMapperUtil.readFile(expectFile, JournalCreateRequest.class);
      mockMvc
        .perform(post("/journal/create")
          .content(ObjectMapperUtil.write(expect))
          .contentType(MediaType.APPLICATION_JSON))
        .andExpect(status().is(HttpStatus.NO_CONTENT.value()))
        .andExpect(jsonPath("$.status", is(204)));
    } catch (Exception e) {
      fail("ジャーナル作成に失敗しました", e);
    }
  }

  @Test
  public void 正常系_配信API_1つのジャーナルデータがS3経由リクエストされたら_1回S3接続を行い_配信ステータスが応答待ちになる() {
    String facilityCd = "TEST01";
    byte[] mockByteArray = "TEST_MOCK".getBytes();
    try {
      // S3取得処理はモック化
      given(amazonS3Wrapper.getS3ObjectByteArray(anyString())).willReturn(mockByteArray);
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());

      // 配信対象をテスト実施前に取得し、実施後のデータ確認のため PK を保持する
      List<JournalDistribute> journalDistributeList = sysCoopJournalWithMstCoopDistributeDao
        .getDeliveryJournal(facilityCd, null);
      List<Long> ctlNoList = journalDistributeList.stream().map(e -> e.getCtlNo()).collect(Collectors.toList());

      mockMvc
        .perform(post("/journal/delivery")
          .content("{\"facility_cd\":\"" + facilityCd + "\"}")
          .contentType(MediaType.APPLICATION_JSON))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status", is(200)))
        .andExpect(jsonPath("$.result", hasSize(1)))
        .andExpect(jsonPath("$.result[0].journalInfo.coop_cd", is("1")))
        .andExpect(jsonPath("$.result[0].journalInfo.coop_cd_index", is("")))
        .andExpect(jsonPath("$.result[0].protocolInfo.protocol", is("file")))
        .andExpect(jsonPath("$.result[0].protocolInfo.address", is("C:\\work\\distination\\")))
        .andExpect(jsonPath("$.result[0].protocolInfo.renameWhenCopying", is("true")))
        .andExpect(jsonPath("$.result[0].protocolInfo.delete", is("true")))
        .andExpect(jsonPath("$.result[0].protocolInfo.dummy", is("true")))
        .andExpect(jsonPath("$.result[0].data.filename", is("TEST.txt")))
        .andExpect(jsonPath("$.result[0].data.dump", is(Hex.encodeHexString(mockByteArray))));

      journalDistributeList = sysCoopJournalWithMstCoopDistributeDao.getDeliveryJournal(facilityCd, null);
      assertThat(journalDistributeList, is(empty()));

      // 処理後のデータ確認
      assertThat(ctlNoList, hasSize(1));
      for (Long ctlNo : ctlNoList) {
        SysCoopJournal sysCoopJournal = sysCoopJournalDao.selectByPK(ctlNo);
        assertThat(sysCoopJournal.getAnaResult(), is("9"));
        assertThat(sysCoopJournal.getCoopResult(), is("8"));
        assertThat(sysCoopJournal.getInRegDate(), is(Timestamp.valueOf(getExpectMockTime())));
        assertThat(sysCoopJournal.getOutRegDate(), is(Timestamp.valueOf(getExpectTime())));
        assertThat(sysCoopJournal.getInAnaDate(), is(Timestamp.valueOf(getExpectTime())));
        assertThat(sysCoopJournal.getOutAnaDate(), is(Timestamp.valueOf(getExpectTime())));
        assertThat(sysCoopJournal.getUpDate(), is(Timestamp.valueOf(getExpectMockTime())));
      }

      verify(amazonS3Wrapper, times(1)).getS3ObjectByteArray(anyString());
      // 配信ステータス更新の呼び出し確認
      verify(sysCoopJournalDao, times(2)).updateByCoopResult(any(), anyString(), any());
      verify(sysCoopJournalDao, times(1)).updateByCoopResult(ctlNoList.toString(), "1", Timestamp.valueOf(getExpectMockTime()));
      verify(sysCoopJournalDao, times(1)).updateByCoopResult(ctlNoList.toString(), "8", Timestamp.valueOf(getExpectMockTime()));
    } catch (Exception e) {
      fail("電文処理に失敗しました", e);
    }
  }

  @Test
  public void 正常系_配信API_2つのジャーナルデータがS3経由でリクエストされたら_2回S3接続を行い_配信ステータスが応答待ちになる() {
    String facilityCd = "TEST02";
    byte[] mockByteArray = "TEST_MOCK".getBytes();
    try {
      // S3取得処理はモック化
      given(amazonS3Wrapper.getS3ObjectByteArray(anyString())).willReturn(mockByteArray);
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());

      // 配信対象をテスト実施前に取得し、実施後のデータ確認のため PK を保持する
      List<JournalDistribute> journalDistributeList = sysCoopJournalWithMstCoopDistributeDao
        .getDeliveryJournal(facilityCd, null);
      List<Long> ctlNoList = journalDistributeList.stream().map(e -> e.getCtlNo()).collect(Collectors.toList());

      mockMvc
        .perform(post("/journal/delivery")
          .content("{\"facility_cd\":\"" + facilityCd + "\"}")
          .contentType(MediaType.APPLICATION_JSON))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status", is(200)))
        .andExpect(jsonPath("$.result", hasSize(2)))
        .andExpect(jsonPath("$.result[0].journalInfo.coop_cd", is("1")))
        .andExpect(jsonPath("$.result[0].journalInfo.coop_cd_index", is("1")))
        .andExpect(jsonPath("$.result[0].protocolInfo.protocol", is("file")))
        .andExpect(jsonPath("$.result[0].protocolInfo.address", is("C:\\work\\distination\\")))
        .andExpect(jsonPath("$.result[0].protocolInfo.renameWhenCopying", is("true")))
        .andExpect(jsonPath("$.result[0].protocolInfo.delete", is("true")))
        .andExpect(jsonPath("$.result[0].protocolInfo.dummy", is("false")))
        .andExpect(jsonPath("$.result[0].data.filename", is("TEST.txt")))
        .andExpect(jsonPath("$.result[0].data.dump", is(Hex.encodeHexString(mockByteArray))))
        .andExpect(jsonPath("$.result[1].journalInfo.coop_cd", is("2")))
        .andExpect(jsonPath("$.result[1].journalInfo.coop_cd_index", is("")))
        .andExpect(jsonPath("$.result[1].protocolInfo.protocol", is("file")))
        .andExpect(jsonPath("$.result[1].protocolInfo.address", is("C:\\work\\distination\\")))
        .andExpect(jsonPath("$.result[1].protocolInfo.renameWhenCopying", is("true")))
        .andExpect(jsonPath("$.result[1].protocolInfo.delete", is("true")))
        .andExpect(jsonPath("$.result[1].protocolInfo.dummy", is("false")))
        .andExpect(jsonPath("$.result[1].data.filename", is("TEST.txt")))
        .andExpect(jsonPath("$.result[1].data.dump", is(Hex.encodeHexString(mockByteArray))));

      journalDistributeList = sysCoopJournalWithMstCoopDistributeDao.getDeliveryJournal(facilityCd, null);
      assertThat(journalDistributeList, is(empty()));

      // 処理後のデータ確認
      assertThat(ctlNoList, hasSize(2));
      for (Long ctlNo : ctlNoList) {
        SysCoopJournal sysCoopJournal = sysCoopJournalDao.selectByPK(ctlNo);
        assertThat(sysCoopJournal.getAnaResult(), is("9"));
        assertThat(sysCoopJournal.getCoopResult(), is("8"));
        assertThat(sysCoopJournal.getInRegDate(), is(Timestamp.valueOf(getExpectMockTime())));
        assertThat(sysCoopJournal.getOutRegDate(), is(Timestamp.valueOf(getExpectTime())));
        assertThat(sysCoopJournal.getInAnaDate(), is(Timestamp.valueOf(getExpectTime())));
        assertThat(sysCoopJournal.getOutAnaDate(), is(Timestamp.valueOf(getExpectTime())));
        assertThat(sysCoopJournal.getUpDate(), is(Timestamp.valueOf(getExpectMockTime())));
      }

      verify(amazonS3Wrapper, times(2)).getS3ObjectByteArray(anyString());
      // 配信ステータス更新の呼び出し確認
      verify(sysCoopJournalDao, times(2)).updateByCoopResult(any(), anyString(), any());
      verify(sysCoopJournalDao, times(1)).updateByCoopResult(ctlNoList.toString(), "1", Timestamp.valueOf(getExpectMockTime()));
      verify(sysCoopJournalDao, times(1)).updateByCoopResult(ctlNoList.toString(), "8", Timestamp.valueOf(getExpectMockTime()));
    } catch (Exception e) {
      fail("電文処理に失敗しました", e);
    }
  }

  @Test
  public void 正常系_配信API_配信対象がない場合は空のリストが返される() {
    String facilityCd = "TEST04";
    byte[] mockByteArray = "TEST_MOCK".getBytes();
    try {
      // S3取得処理はモック化
      given(amazonS3Wrapper.getS3ObjectByteArray(anyString())).willReturn(mockByteArray);
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());

      // 配信対象が存在しないことの確認
      List<JournalDistribute> journalDistributeList = sysCoopJournalWithMstCoopDistributeDao
        .getDeliveryJournal(facilityCd, null);
      assertThat(journalDistributeList, is(empty()));

      mockMvc
        .perform(post("/journal/delivery")
          .content("{\"facility_cd\":\"" + facilityCd + "\"}")
          .contentType(MediaType.APPLICATION_JSON))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status", is(200)))
        .andExpect(jsonPath("$.result", is(notNullValue())))
        .andExpect(jsonPath("$.result", hasSize(0)));

      // 呼び出し確認
      verify(amazonS3Wrapper, times(0)).getS3ObjectByteArray(anyString());
      verify(sysCoopJournalDao, times(0)).updateByCoopResult(any(), anyString(), any());
    } catch (Exception e) {
      fail("電文処理に失敗しました", e);
    }
  }

  @Test
  public void 異常系_配信API_施設コードがブランクの場合は400を返却する_電文送信もしない() {
    try {
      mockMvc
        .perform(post("/journal/delivery")
          .content("{\"facility_cd\":\"\"}")
          .contentType(MediaType.APPLICATION_JSON))
        .andExpect(status().is(HttpStatus.BAD_REQUEST.value()));
    } catch (Exception e) {
      fail("電文処理に失敗しました", e);
    }
  }

  @Test
  public void 異常系_配信API_1つのジャーナルデータが変換処理に失敗した場合_配信ステータスが内部エラーになる() {
    String facilityCd = "TEST08";
    byte[] mockByteArray = "TEST_MOCK".getBytes();
    try {
      // S3取得処理はモック化
      given(amazonS3Wrapper.getS3ObjectByteArray(anyString())).willReturn(mockByteArray);
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());

      // 配信対象をテスト実施前に取得し、実施後のデータ確認のため PK を保持する
      List<JournalDistribute> journalDistributeList = sysCoopJournalWithMstCoopDistributeDao
        .getDeliveryJournal(facilityCd, null);
      List<Long> ctlNoList = journalDistributeList.stream().map(e -> e.getCtlNo()).collect(Collectors.toList());

      mockMvc
        .perform(post("/journal/delivery")
          .content("{\"facility_cd\":\"" + facilityCd + "\"}")
          .contentType(MediaType.APPLICATION_JSON))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status", is(200)))
        .andExpect(jsonPath("$.result", is(notNullValue())))
        .andExpect(jsonPath("$.result", hasSize(0)));

      journalDistributeList = sysCoopJournalWithMstCoopDistributeDao.getDeliveryJournal(facilityCd, null);
      assertThat(journalDistributeList, is(empty()));

      // 処理後のデータ確認
      assertThat(ctlNoList, hasSize(1));
      for (Long ctlNo : ctlNoList) {
        SysCoopJournal sysCoopJournal = sysCoopJournalDao.selectByPK(ctlNo);
        assertThat(sysCoopJournal.getAnaResult(), is("9"));
        assertThat(sysCoopJournal.getCoopResult(), is("E1"));
        assertThat(sysCoopJournal.getInRegDate(), is(Timestamp.valueOf(getExpectMockTime())));
        assertThat(sysCoopJournal.getOutRegDate(), is(Timestamp.valueOf(getExpectTime())));
        assertThat(sysCoopJournal.getInAnaDate(), is(Timestamp.valueOf(getExpectTime())));
        assertThat(sysCoopJournal.getOutAnaDate(), is(Timestamp.valueOf(getExpectTime())));
        assertThat(sysCoopJournal.getUpDate(), is(Timestamp.valueOf(getExpectMockTime())));
      }

      verify(amazonS3Wrapper, times(0)).getS3ObjectByteArray(anyString());
      // 配信ステータス更新の呼び出し確認
      verify(sysCoopJournalDao, times(2)).updateByCoopResult(any(), anyString(), any());
      verify(sysCoopJournalDao, times(1)).updateByCoopResult(ctlNoList.toString(), "1", Timestamp.valueOf(getExpectMockTime()));
      verify(sysCoopJournalDao, times(1)).updateByCoopResult(ctlNoList.toString(), "E1", Timestamp.valueOf(getExpectMockTime()));
    } catch (Exception e) {
      fail("電文処理に失敗しました", e);
    }
  }

  @Test
  public void 正常系_ジャーナル更新API_ヘルスモニタ更新が呼ばれている_処理完了_エラー() {
    File expectFile = new File(
      getClass().getClassLoader().getResource("resource.json/JournalResourceTest/update_all.json").getFile());
    try {
      JournalUpdateRequest expect = ObjectMapperUtil.readFile(expectFile, JournalUpdateRequest.class);
      // 変換ステータス/通信ステータス のみ値を置き換える
      expect.setAnaResult(AnaResult.DONE.getResult());
      expect.setCoopResult(CoopResult.INTERNAL_ERROR_BY_NTSS.getResult());

      mockMvc
        .perform(post("/journal/update")
          .content(ObjectMapperUtil.write(expect))
          .contentType(MediaType.APPLICATION_JSON))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status", is(200)));

      verify(healthService, times(1)).update(any(JournalUpdateRequest.class));
      verify(healthService, times(1)).update(any(HealthUpdateRequest.class));
      verify(healthService, times(0)).update(any(JournalCreateRequest.class));
      verify(healthService, times(0)).update(any(JournalDeliveryRequest.class));

    } catch (Exception e) {
      fail("ジャーナル更新に失敗しました", e);
    }

  }

  @Test
  public void 正常系_ジャーナル更新API_ヘルスモニタ更新が呼ばれない_処理完了_未処理() {
    File expectFile = new File(
      getClass().getClassLoader().getResource("resource.json/JournalResourceTest/update_all.json").getFile());
    try {
      JournalUpdateRequest expect = ObjectMapperUtil.readFile(expectFile, JournalUpdateRequest.class);
      // 変換ステータス/通信ステータス のみ値を置き換える
      expect.setAnaResult(AnaResult.DONE.getResult());
      expect.setCoopResult(CoopResult.UNPROCESS.getResult());

      mockMvc
        .perform(post("/journal/update")
          .content(ObjectMapperUtil.write(expect))
          .contentType(MediaType.APPLICATION_JSON))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status", is(200)));

      verify(healthService, times(1)).update(any(JournalUpdateRequest.class));
      verify(healthService, times(0)).update(any(HealthUpdateRequest.class));
      verify(healthService, times(0)).update(any(JournalCreateRequest.class));
      verify(healthService, times(0)).update(any(JournalDeliveryRequest.class));

    } catch (Exception e) {
      fail("ジャーナル更新に失敗しました", e);
    }

  }

  @Test
  public void 正常系_ジャーナル更新API_ヘルスモニタ更新が呼ばれない_未処理_処理完了() {
    File expectFile = new File(
      getClass().getClassLoader().getResource("resource.json/JournalResourceTest/update_all.json").getFile());
    try {
      JournalUpdateRequest expect = ObjectMapperUtil.readFile(expectFile, JournalUpdateRequest.class);
      // 変換ステータス/通信ステータス のみ値を置き換える
      expect.setAnaResult(AnaResult.UNPROCESS.getResult());
      expect.setCoopResult(CoopResult.DONE.getResult());

      mockMvc
        .perform(post("/journal/update")
          .content(ObjectMapperUtil.write(expect))
          .contentType(MediaType.APPLICATION_JSON))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status", is(200)));

      verify(healthService, times(1)).update(any(JournalUpdateRequest.class));
      verify(healthService, times(0)).update(any(HealthUpdateRequest.class));
      verify(healthService, times(0)).update(any(JournalCreateRequest.class));
      verify(healthService, times(0)).update(any(JournalDeliveryRequest.class));

    } catch (Exception e) {
      fail("ジャーナル更新に失敗しました", e);
    }

  }

  @Test
  public void 異常系_ジャーナル更新API_ヘルスモニタ更新で対象なしワーニング() {
    File expectFile = new File(
      getClass().getClassLoader().getResource("resource.json/JournalResourceTest/update_all.json").getFile());
    try {
      JournalUpdateRequest expect = ObjectMapperUtil.readFile(expectFile, JournalUpdateRequest.class);
      // 変換ステータス/通信ステータス のみ値を置き換える
      expect.setAnaResult(AnaResult.DONE.getResult());
      expect.setCoopResult(CoopResult.INTERNAL_ERROR_BY_NTSS.getResult());

      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      // ヘルスモニタの検索結果をなしにする
      given(mntIfEdgeHealthmonDao.selectByFacilityAndIfEdgeNo(anyString(), anyInt())).willReturn(null);

      mockMvc
        .perform(post("/journal/update")
          .content(ObjectMapperUtil.write(expect))
          .contentType(MediaType.APPLICATION_JSON))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status", is(200)));

      verify(healthService, times(1)).update(any(JournalUpdateRequest.class));
      verify(healthService, times(1)).update(any(HealthUpdateRequest.class));
      verify(healthService, times(0)).update(any(JournalCreateRequest.class));
      verify(healthService, times(0)).update(any(JournalDeliveryRequest.class));

      SysCoopJournal sysCoopJournal = sysCoopJournalDao.selectByPK(expect.getCtlNo());
      assertThat(sysCoopJournal.getAnaResult(), is(expect.getAnaResult()));
      assertThat(sysCoopJournal.getCoopResult(), is(expect.getCoopResult()));
      assertThat(sysCoopJournal.getDumpPath(), is(expect.getDumpPath()));
      assertThat(sysCoopJournal.getUserId(), is(234L));
      assertThat(sysCoopJournal.getOutAnaDate(), is(Timestamp.valueOf(getExpectMockTime())));
    } catch (Exception e) {
      fail("ジャーナル更新に失敗しました", e);
    }
  }

  @Transactional(propagation = Propagation.NOT_SUPPORTED)
  @Test
  public void 異常系_ジャーナル更新API_ヘルスモニタ更新でエラー_リクエストパラメータ通りに登録されている() {
    File expectFile = new File(
      getClass().getClassLoader().getResource("resource.json/JournalResourceTest/update_all.json").getFile());
    try {
      JournalUpdateRequest expect = ObjectMapperUtil.readFile(expectFile, JournalUpdateRequest.class);
      // 変換ステータス/通信ステータス のみ値を置き換える
      expect.setAnaResult(AnaResult.DONE.getResult());
      expect.setCoopResult(CoopResult.INTERNAL_ERROR_BY_NTSS.getResult());

      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      // ヘルスモニタ更新をモック化
      doThrow(NtssException.class).when(healthService).update(any(HealthUpdateRequest.class));

      mockMvc
        .perform(post("/journal/update")
          .content(ObjectMapperUtil.write(expect))
          .contentType(MediaType.APPLICATION_JSON))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status", is(200)));

      verify(healthService, times(1)).update(any(JournalUpdateRequest.class));
      verify(healthService, times(1)).update(any(HealthUpdateRequest.class));
      verify(healthService, times(0)).update(any(JournalCreateRequest.class));
      verify(healthService, times(0)).update(any(JournalDeliveryRequest.class));

      SysCoopJournal sysCoopJournal = sysCoopJournalDao.selectByPK(expect.getCtlNo());
      assertThat(sysCoopJournal.getAnaResult(), is(expect.getAnaResult()));
      assertThat(sysCoopJournal.getCoopResult(), is(expect.getCoopResult()));
      assertThat(sysCoopJournal.getDumpPath(), is(expect.getDumpPath()));
      assertThat(sysCoopJournal.getUserId(), is(234L));
      assertThat(sysCoopJournal.getOutAnaDate(), is(Timestamp.valueOf(getExpectMockTime())));

      // ヘルスモニタは更新されていないこと
      List<MntIfEdgeHealthmon> mntIfEdgeHealthmon = new ArrayList<>((Collection) mntIfEdgeHealthmonDao
        .selectByFacilityAndIfEdgeNo(sysCoopJournal.getFacilityCd(), NtssCoopApiConstants.IF_EDGE_NO_DEFAULT));
      assertThat(mntIfEdgeHealthmon.get(0).getFacilityCd(), is(sysCoopJournal.getFacilityCd()));
      assertThat(mntIfEdgeHealthmon.get(0).getIfEdgeNo(), is(NtssCoopApiConstants.IF_EDGE_NO_DEFAULT));
      assertThat(mntIfEdgeHealthmon.get(0).getUpDate().toString(), is(Timestamp.valueOf("2019-12-10 13:00:03").toString()));
    } catch (Exception e) {
      fail("ジャーナル更新に失敗しました", e);
    }

  }

  @Test
  public void 正常系_ジャーナル作成API_ヘルスモニタ更新が呼ばれる_未処理_エラー() {
    File expectFile = new File(
      getClass().getClassLoader().getResource("resource.json/JournalResourceTest/create_all.json").getFile());

    try {
      JournalCreateRequest expect = ObjectMapperUtil.readFile(expectFile, JournalCreateRequest.class);
      // 変換ステータス/通信ステータス のみ値を置き換える
      expect.setAnaResult(AnaResult.UNPROCESS.getResult());
      expect.setCoopResult(CoopResult.DONE.getResult());

      mockMvc
        .perform(post("/journal/create")
          .content(ObjectMapperUtil.write(expect))
          .contentType(MediaType.APPLICATION_JSON))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status", is(200)));

      verify(healthService, times(1)).update(any(JournalCreateRequest.class));
      verify(healthService, times(1)).update(any(HealthUpdateRequest.class));
      verify(healthService, times(0)).update(any(JournalDeliveryRequest.class));
      verify(healthService, times(0)).update(any(JournalUpdateRequest.class));
    } catch (Exception e) {
      fail("ジャーナル作成に失敗しました", e);
    }
  }

  @Test
  public void 正常系_ジャーナル作成API_ヘルスモニタ更新が呼ばれない_未処理_未処理() {
    File expectFile = new File(
      getClass().getClassLoader().getResource("resource.json/JournalResourceTest/create_all.json").getFile());

    try {
      JournalCreateRequest expect = ObjectMapperUtil.readFile(expectFile, JournalCreateRequest.class);
      // 変換ステータス/通信ステータス のみ値を置き換える
      expect.setAnaResult(AnaResult.UNPROCESS.getResult());
      expect.setCoopResult(CoopResult.UNPROCESS.getResult());

      mockMvc
        .perform(post("/journal/create")
          .content(ObjectMapperUtil.write(expect))
          .contentType(MediaType.APPLICATION_JSON))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status", is(200)));

      verify(healthService, times(1)).update(any(JournalCreateRequest.class));
      verify(healthService, times(0)).update(any(HealthUpdateRequest.class));
      verify(healthService, times(0)).update(any(JournalDeliveryRequest.class));
      verify(healthService, times(0)).update(any(JournalUpdateRequest.class));
    } catch (Exception e) {
      fail("ジャーナル作成に失敗しました", e);
    }
  }

  @Test
  public void 正常系_ジャーナル作成API_ヘルスモニタ更新が呼ばれない_処理完了_処理完了() {
    File expectFile = new File(
      getClass().getClassLoader().getResource("resource.json/JournalResourceTest/create_all.json").getFile());

    try {
      JournalCreateRequest expect = ObjectMapperUtil.readFile(expectFile, JournalCreateRequest.class);
      // 変換ステータス/通信ステータス のみ値を置き換える
      expect.setAnaResult(AnaResult.DONE.getResult());
      expect.setCoopResult(CoopResult.DONE.getResult());

      mockMvc
        .perform(post("/journal/create")
          .content(ObjectMapperUtil.write(expect))
          .contentType(MediaType.APPLICATION_JSON))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status", is(200)));

      verify(healthService, times(1)).update(any(JournalCreateRequest.class));
      verify(healthService, times(0)).update(any(HealthUpdateRequest.class));
      verify(healthService, times(0)).update(any(JournalDeliveryRequest.class));
      verify(healthService, times(0)).update(any(JournalUpdateRequest.class));
    } catch (Exception e) {
      fail("ジャーナル作成に失敗しました", e);
    }
  }

  @Test
  public void 異常系_ジャーナル作成API_ヘルスモニタ更新で対象なし_ワーニング() {
    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    File expectFile = new File(
      getClass().getClassLoader().getResource("resource.json/JournalResourceTest/create_all.json").getFile());

    try {
      JournalCreateRequest expect = ObjectMapperUtil.readFile(expectFile, JournalCreateRequest.class);
      // 変換ステータス/通信ステータス のみ値を置き換える
      expect.setAnaResult(AnaResult.UNPROCESS.getResult());
      expect.setCoopResult(CoopResult.DONE.getResult());

      mockMvc
        .perform(post("/journal/create")
          .content(ObjectMapperUtil.write(expect))
          .contentType(MediaType.APPLICATION_JSON))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status", is(200)));

      verify(sysCoopJournalDao, times(1)).selectNextSeqCtlNo();
      verify(healthService, times(1)).update(any(JournalCreateRequest.class));
      verify(healthService, times(1)).update(any(HealthUpdateRequest.class));
      verify(healthService, times(0)).update(any(JournalDeliveryRequest.class));
      verify(healthService, times(0)).update(any(JournalUpdateRequest.class));

      SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(expect.getFacilityCd(), expect.getCoopCd(),
        expect.getCoopCdIndex(),
        expect.getCrud(), expect.getDirection());
      assertThat(sysCoopJournal.getFacilityCd(), is(expect.getFacilityCd()));
      assertThat(sysCoopJournal.getCoopCd(), is(expect.getCoopCd()));
      assertThat(sysCoopJournal.getCoopCdIndex(), is(expect.getCoopCdIndex()));
      assertThat(sysCoopJournal.getCrud(), is(expect.getCrud()));
      assertThat(sysCoopJournal.getDirection(), is(expect.getDirection()));
      assertThat(sysCoopJournal.getOrdNo(), is(expect.getOrdNo()));
      assertThat(sysCoopJournal.getCoopOrdNo(), is(expect.getCoopOrdNo()));
      assertThat(sysCoopJournal.getHospPatId(), is(expect.getHospPatId()));
      assertThat(sysCoopJournal.getPatId(), is(expect.getPatId()));
      assertThat(sysCoopJournal.getAnaResult(), is(expect.getAnaResult()));
      assertThat(sysCoopJournal.getCoopResult(), is(expect.getCoopResult()));
      assertThat(sysCoopJournal.getDump(), is(Base64.getDecoder().decode(expect.getMessage64().getBytes())));
      assertThat(sysCoopJournal.getUserId(), is(123L));
      assertThat(sysCoopJournal.getOutRegDate(), is(Timestamp.valueOf(getExpectMockTime())));

    } catch (Exception e) {
      fail("ジャーナル作成に失敗しました", e);
    }
  }

  @Transactional(propagation = Propagation.NOT_SUPPORTED)
  @Test
  public void 異常系_ジャーナル作成API_ヘルスモニタ更新でエラー_リクエストパラメータ通りに登録されている() {
    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
    // ヘルスモニタ更新をモック化
    doThrow(NtssException.class).when(healthService).update(any(HealthUpdateRequest.class));
    File expectFile = new File(
      getClass().getClassLoader().getResource("resource.json/JournalResourceTest/create_all.json").getFile());

    try {
      JournalCreateRequest expect = ObjectMapperUtil.readFile(expectFile, JournalCreateRequest.class);
      // 変換ステータス/通信ステータス のみ値を置き換える
      expect.setAnaResult(AnaResult.UNPROCESS.getResult());
      expect.setCoopResult(CoopResult.DONE.getResult());

      mockMvc
        .perform(post("/journal/create")
          .content(ObjectMapperUtil.write(expect))
          .contentType(MediaType.APPLICATION_JSON))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status", is(200)));

      verify(sysCoopJournalDao, times(1)).selectNextSeqCtlNo();
      verify(healthService, times(1)).update(any(JournalCreateRequest.class));
      verify(healthService, times(1)).update(any(HealthUpdateRequest.class));
      verify(healthService, times(0)).update(any(JournalDeliveryRequest.class));
      verify(healthService, times(0)).update(any(JournalUpdateRequest.class));

      SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(expect.getFacilityCd(), expect.getCoopCd(),
        expect.getCoopCdIndex(),
        expect.getCrud(), expect.getDirection());
      assertThat(sysCoopJournal.getFacilityCd(), is(expect.getFacilityCd()));
      assertThat(sysCoopJournal.getCoopCd(), is(expect.getCoopCd()));
      assertThat(sysCoopJournal.getCoopCdIndex(), is(expect.getCoopCdIndex()));
      assertThat(sysCoopJournal.getCrud(), is(expect.getCrud()));
      assertThat(sysCoopJournal.getDirection(), is(expect.getDirection()));
      assertThat(sysCoopJournal.getOrdNo(), is(expect.getOrdNo()));
      assertThat(sysCoopJournal.getCoopOrdNo(), is(expect.getCoopOrdNo()));
      assertThat(sysCoopJournal.getHospPatId(), is(expect.getHospPatId()));
      assertThat(sysCoopJournal.getPatId(), is(expect.getPatId()));
      assertThat(sysCoopJournal.getAnaResult(), is(expect.getAnaResult()));
      assertThat(sysCoopJournal.getCoopResult(), is(expect.getCoopResult()));
      assertThat(sysCoopJournal.getDump(), is(Base64.getDecoder().decode(expect.getMessage64().getBytes())));
      assertThat(sysCoopJournal.getUserId(), is(123L));
      assertThat(sysCoopJournal.getOutRegDate(), is(Timestamp.valueOf(getExpectMockTime())));

      // ヘルスモニタは更新されていないこと
      List<MntIfEdgeHealthmon> mntIfEdgeHealthmon = new ArrayList<>((Collection) mntIfEdgeHealthmonDao.selectByFacilityAndIfEdgeNo(expect.getFacilityCd(),
        NtssCoopApiConstants.IF_EDGE_NO_DEFAULT));
      assertThat(mntIfEdgeHealthmon.get(0).getFacilityCd(), is(expect.getFacilityCd()));
      assertThat(mntIfEdgeHealthmon.get(0).getIfEdgeNo(), is(NtssCoopApiConstants.IF_EDGE_NO_DEFAULT));
      assertThat(mntIfEdgeHealthmon.get(0).getUpDate().toString(), is(Timestamp.valueOf("2019-12-10 13:00:03").toString()));
    } catch (Exception e) {
      fail("ジャーナル作成に失敗しました", e);
    }
  }

  @Test
  public void 正常系_配信API_ヘルスモニタ更新が呼ばれている() {
    String facilityCd = "TEST01";
    byte[] mockByteArray = "TEST_MOCK".getBytes();
    try {
      // S3取得処理はモック化
      given(amazonS3Wrapper.getS3ObjectByteArray(anyString())).willReturn(mockByteArray);
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());

      mockMvc
        .perform(post("/journal/delivery")
          .content("{\"facility_cd\":\"" + facilityCd + "\"}")
          .contentType(MediaType.APPLICATION_JSON))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status", is(200)));

      verify(amazonS3Wrapper, times(1)).getS3ObjectByteArray(anyString());
      verify(healthService, times(1)).update(any(JournalDeliveryRequest.class));
      verify(healthService, times(1)).update(any(HealthUpdateRequest.class));
      verify(healthService, times(0)).update(any(JournalUpdateRequest.class));
      verify(healthService, times(0)).update(any(JournalCreateRequest.class));

    } catch (Exception e) {
      fail("電文処理に失敗しました", e);
    }
  }

  @Test
  public void 異常系_配信API_ヘルスモニタ更新で対象なしワーニング() {
    String facilityCd = "TEST03";
    byte[] mockByteArray = "TEST_MOCK".getBytes();
    try {
      // S3取得処理はモック化
      given(amazonS3Wrapper.getS3ObjectByteArray(anyString())).willReturn(mockByteArray);
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());

      // 配信対象をテスト実施前に取得し、実施後のデータ確認のため PK を保持する
      List<JournalDistribute> journalDistributeList = sysCoopJournalWithMstCoopDistributeDao
        .getDeliveryJournal(facilityCd, null);
      List<Long> ctlNoList = journalDistributeList.stream().map(e -> e.getCtlNo()).collect(Collectors.toList());

      mockMvc
        .perform(post("/journal/delivery")
          .content("{\"facility_cd\":\"" + facilityCd + "\"}")
          .contentType(MediaType.APPLICATION_JSON))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status", is(200)));

      verify(healthService, times(1)).update(any(JournalDeliveryRequest.class));
      verify(healthService, times(1)).update(any(HealthUpdateRequest.class));
      verify(healthService, times(0)).update(any(JournalUpdateRequest.class));
      verify(healthService, times(0)).update(any(JournalCreateRequest.class));

      journalDistributeList = sysCoopJournalWithMstCoopDistributeDao.getDeliveryJournal(facilityCd, null);
      assertThat(journalDistributeList, is(empty()));

      // 処理後のデータ確認
      assertThat(ctlNoList, hasSize(2));
      for (Long ctlNo : ctlNoList) {
        SysCoopJournal sysCoopJournal = sysCoopJournalDao.selectByPK(ctlNo);
        assertThat(sysCoopJournal.getAnaResult(), is("9"));
        assertThat(sysCoopJournal.getCoopResult(), is("8"));
        assertThat(sysCoopJournal.getInRegDate(), is(Timestamp.valueOf(getExpectMockTime())));
        assertThat(sysCoopJournal.getOutRegDate(), is(Timestamp.valueOf(getExpectTime())));
        assertThat(sysCoopJournal.getInAnaDate(), is(Timestamp.valueOf(getExpectTime())));
        assertThat(sysCoopJournal.getOutAnaDate(), is(Timestamp.valueOf(getExpectTime())));
        assertThat(sysCoopJournal.getUpDate(), is(Timestamp.valueOf(getExpectMockTime())));
      }
    } catch (Exception e) {
      fail("電文処理に失敗しました", e);
    }
  }

  @Transactional(propagation = Propagation.NOT_SUPPORTED)
  @Test
  public void 異常系_配信API_ヘルスモニタ更新でエラー_リクエストパラメータ通りに登録されている() {
    String facilityCd = "TEST07";
    byte[] mockByteArray = "TEST_MOCK".getBytes();
    try {
      // S3取得処理はモック化
      given(amazonS3Wrapper.getS3ObjectByteArray(anyString())).willReturn(mockByteArray);
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      // ヘルスモニタ更新をモック化
      doThrow(NtssException.class).when(healthService).update(any(HealthUpdateRequest.class));

      // 配信対象をテスト実施前に取得し、実施後のデータ確認のため PK を保持する
      List<JournalDistribute> journalDistributeList = sysCoopJournalWithMstCoopDistributeDao
        .getDeliveryJournal(facilityCd, null);
      List<Long> ctlNoList = journalDistributeList.stream().map(e -> e.getCtlNo()).collect(Collectors.toList());

      mockMvc
        .perform(post("/journal/delivery")
          .content("{\"facility_cd\":\"" + facilityCd + "\"}")
          .contentType(MediaType.APPLICATION_JSON))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status", is(200)));

      verify(healthService, times(1)).update(any(JournalDeliveryRequest.class));
      verify(healthService, times(1)).update(any(HealthUpdateRequest.class));
      verify(healthService, times(0)).update(any(JournalUpdateRequest.class));
      verify(healthService, times(0)).update(any(JournalCreateRequest.class));

      journalDistributeList = sysCoopJournalWithMstCoopDistributeDao.getDeliveryJournal(facilityCd, null);
      assertThat(journalDistributeList, is(empty()));

      // 処理後のデータ確認
      assertThat(ctlNoList, hasSize(1));
      for (Long ctlNo : ctlNoList) {
        SysCoopJournal sysCoopJournal = sysCoopJournalDao.selectByPK(ctlNo);
        assertThat(sysCoopJournal.getAnaResult(), is("9"));
        assertThat(sysCoopJournal.getCoopResult(), is("8"));
        assertThat(sysCoopJournal.getInRegDate(), is(Timestamp.valueOf(getExpectMockTime())));
        assertThat(sysCoopJournal.getOutRegDate(), is(Timestamp.valueOf(getExpectTime())));
        assertThat(sysCoopJournal.getInAnaDate(), is(Timestamp.valueOf(getExpectTime())));
        assertThat(sysCoopJournal.getOutAnaDate(), is(Timestamp.valueOf(getExpectTime())));
        assertThat(sysCoopJournal.getUpDate(), is(Timestamp.valueOf(getExpectMockTime())));
      }

      // ヘルスモニタは更新されていないこと
      List<MntIfEdgeHealthmon> mntIfEdgeHealthmon = new ArrayList<>((Collection) mntIfEdgeHealthmonDao.selectByFacilityAndIfEdgeNo(facilityCd,
        NtssCoopApiConstants.IF_EDGE_NO_DEFAULT));
      assertThat(mntIfEdgeHealthmon.get(0).getFacilityCd(), is(facilityCd));
      assertThat(mntIfEdgeHealthmon.get(0).getIfEdgeNo(), is(NtssCoopApiConstants.IF_EDGE_NO_DEFAULT));
      assertThat(mntIfEdgeHealthmon.get(0).getUpDate().toString(), is(Timestamp.valueOf("2019-12-10 13:00:03").toString()));
    } catch (Exception e) {
      fail("電文処理に失敗しました", e);
    }
  }
}
