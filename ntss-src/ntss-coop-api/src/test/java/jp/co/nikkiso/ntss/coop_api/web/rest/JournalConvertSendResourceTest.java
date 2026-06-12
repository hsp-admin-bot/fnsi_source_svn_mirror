package jp.co.nikkiso.ntss.coop_api.web.rest;

import static org.assertj.core.api.Assertions.fail;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.junit.Assert.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.doReturn;
import static org.mockito.BDDMockito.doThrow;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.times;
import static org.mockito.BDDMockito.verify;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.hamcrest.Matchers;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.bean.override.mockito.MockitoSpyBean;
import org.springframework.http.MediaType;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.SqlConfig;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.coop_api.request.JournalConvertReceiveRequest;
import jp.co.nikkiso.ntss.coop_api.service.ConvertCommonService;
import jp.co.nikkiso.ntss.coop_api.service.ConvertSendCommonService;
import jp.co.nikkiso.ntss.coop_api.utils.ClockWrapper;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants.AnaResult;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.DataSourceName;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.TransactionManagerName;
import jp.co.nikkiso.ntss.core.dao.SysCoopJournalDao;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;
import jp.co.nikkiso.ntss.core.exception.NtssException;

@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
@Sql("classpath:resource.script/JournalConvertSendResourceTest/JournalConvertSendResourceTest.db5.before.sql")
@Sql("classpath:resource.script/JournalConvertSendResourceTest/ConvertSendTextServiceImplTest.db5.before.sql")
@Sql(value = "classpath:resource.script/ConvertSendServiceImplTest/db4.before.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
public class JournalConvertSendResourceTest extends AbstractResourceTest {
  @MockitoSpyBean
  private ConvertSendCommonService convertSendService;
  @MockitoBean
  ClockWrapper clockWrapper;
  @MockitoSpyBean
  private SysCoopJournalDao sysCoopJournalDao;
  @MockitoSpyBean
  private ConvertCommonService convertCommonService;

  @Test
  public void 正常系_送信変換API_固定値HOGEのレイアウトで出力したいジャーナルが来る_HOGEという電文が作成され変換ステータスは処理完了となる() {
    String facilityCd = "TEST04";
    String coopCd = "1";
    byte[] expect = "HOGE".getBytes();
    try {
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      doReturn(new ArrayList<>()).when(convertSendService).requestNtssApi(any());

      ResultActions response = request(facilityCd);
      response.andExpect(status().isOk());

      assert_ジャーナルが処理完了かつ変換開始_終了時刻および更新日時が2019年10月10日10時0分0秒である(facilityCd, coopCd, expect);
    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  // auth_idの電文作成 TEXTがフォーマットの場合
  @Test
  public void 正常系_フォーマットTEXTの表示用利用者IDの電文作成() {
    String facilityCd = "TEST91";
    String expect = "dispUser    ";
    try {
      ResultActions response = request(facilityCd);
      response
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status").value(200))
        .andExpect(jsonPath("$.result").isArray())
        .andExpect(jsonPath("$.result", Matchers.hasSize(1)))
        .andExpect(jsonPath("$.result[0].ana_result").value("9"))
        .andExpect(jsonPath("$.result[0].message").value(""));

      // 作成電文の確認
      SysCoopJournal journal = sysCoopJournalDao.select(facilityCd, "ustxt", "", "C", "S");
      assertThat(journal.getDump(), is(expect.getBytes()));

    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  // auth_idの電文作成 XMLがフォーマットの場合
  @Test
  public void 正常系_フォーマットXML_Attributesの表示用利用者IDの電文作成() {
    String facilityCd = "TEST92";
    // 作成電文
    String expect = "<?xml version=\"1.0\" encoding=\"Shift_JIS\" standalone=\"yes\"?>\r\n"
                   + "<item name=\"auth\" value=\"dispUser\"/>\r\n";

    // レポート対象外
    doReturn(false).when(convertSendService).isReport(any());

    try {
      ResultActions response = request(facilityCd);
      response
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status").value(200))
        .andExpect(jsonPath("$.result").isArray())
        .andExpect(jsonPath("$.result", Matchers.hasSize(1)))
        .andExpect(jsonPath("$.result[0].ana_result").value("9"))
        .andExpect(jsonPath("$.result[0].message").value(""));

      // 作成電文の確認
      SysCoopJournal journal = sysCoopJournalDao.select(facilityCd, "usxml", "", "C", "S");
      assertThat(journal.getDump(), is(expect.getBytes()));

    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  @Test
  public void 正常系_フォーマットXML_Fragmentの表示用利用者IDの電文作成() {
    String facilityCd = "TEST93";
    String expect = "<?xml version=\"1.0\" encoding=\"Shift_JIS\" standalone=\"yes\"?>\r\n"
                   + "<MCSSData ver=\"Ver.03.80 2020-03-25\">\r\n"
                   + "  <Header>\r\n"
                   + "    <DrCd>dispUser</DrCd>\r\n"
                   + "  </Header>\r\n"
                   + "</MCSSData>\r\n";
    // レポート対象外
    doReturn(false).when(convertSendService).isReport(any());

    try {
      ResultActions response = request(facilityCd);
      response
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status").value(200))
        .andExpect(jsonPath("$.result").isArray())
        .andExpect(jsonPath("$.result", Matchers.hasSize(1)))
        .andExpect(jsonPath("$.result[0].ana_result").value("9"))
        .andExpect(jsonPath("$.result[0].message").value(""));

      // 作成電文の確認
      SysCoopJournal journal = sysCoopJournalDao.select(facilityCd, "usxml2", "", "C", "S");
      assertThat(journal.getDump(), is(expect.getBytes()));

    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  // レスポンスの内容確認 引数なし
  @Test
  public void 異常系_施設コード未設定_400エラーでリスエストパラメータエラー() {
    try {
      // 引数なし
      ResultActions response = request("");
      response
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.status").value(400))
        .andExpect(jsonPath("$.result").isArray())
        .andExpect(jsonPath("$.result", Matchers.hasSize(1)))
        .andExpect(jsonPath("$.result[0].message").value("リクエストパラメータが不正または不足しています。facility_cd:[]"));
    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  // レスポンスの内容確認 引数あり 未存在
  @Test
  public void 異常系_施設コード未存在_204エラーで対象件数なし() {
    try {
      ResultActions response = request("TESTXXX");
      response
        .andExpect(status().isNoContent())
        .andExpect(jsonPath("$.status").value(204))
        .andExpect(jsonPath("$.result").isArray())
        .andExpect(jsonPath("$.result", Matchers.hasSize(1)))
        .andExpect(jsonPath("$.result[0].message").value("送信対象の電文変換ジャーナルが存在しません。facility_cd:[TESTXXX]"));
    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  // 処理対象がチェックエラー時の結果出力
  @Test
  public void 異常系_更新処理前のエラー時でもDBが更新されること() {
    String facilityCd = "TEST99";

    try {
      ResultActions response = request(facilityCd);
      response
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status").value(200))
        .andExpect(jsonPath("$.result").isArray())
        .andExpect(jsonPath("$.result", Matchers.hasSize(1)))
        .andExpect(jsonPath("$.result[0].ana_result").value("E1"))
        .andExpect(jsonPath("$.result[0].message").value("電文変換レイアウトが設定されていません。施設コード:[TEST99], 送受信向き:[S], 電文種別:[error], 電文付帯情報:[], 電文種別補足コード:[cre]"));

      // DBが更新されていることを確認する
      SysCoopJournal journal = sysCoopJournalDao.select(facilityCd, "error", "", "C", "S");
      // 変換ステータス「内部エラー」
      assertThat(journal.getAnaResult(), is("E1"));
      // エラー時は処理完了日時(処理)は設定されないこと
      assertThat(journal.getOutAnaDate(), nullValue());

    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }


  // ConvertSendTextServiceImpl のレコード更新確認
  @Test
  public void 正常系_送信変換API_テキスト_固定値HOGE_データ長同じ_固定値通りに電文作成され変換ステータスが処理完了となる() {
    String facilityCd = "TEST01";
    String coopCd = "TEST_CD";
    byte[] expect = "HOGE".getBytes();

    try {
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      doReturn(new ArrayList<>()).when(convertSendService).requestNtssApi(any());

      ResultActions response = request(facilityCd);
      response.andExpect(status().isOk());

      assert_ジャーナルが処理完了かつ変換開始_終了時刻および更新日時が2019年10月10日10時0分0秒である(facilityCd, coopCd, expect);
    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  @Test
  public void 正常系_送信変換API_テキスト_固定値HOGE_データ長6桁で2byte余り_paddingはデフォルト_HOGEスペース2桁で電文作成され変換ステータスが処理完了となる() {
    String facilityCd = "TEST02";
    String coopCd = "TEST_CD";
    byte[] expect = "HOGE  ".getBytes();

    try {
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      doReturn(new ArrayList<>()).when(convertSendService).requestNtssApi(any());

      ResultActions response = request(facilityCd);
      response.andExpect(status().isOk());

      assert_ジャーナルが処理完了かつ変換開始_終了時刻および更新日時が2019年10月10日10時0分0秒である(facilityCd, coopCd, expect);
    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  @Test
  public void 正常系_送信変換API_テキスト_固定値HOGE_データ長6桁で2byte余り_paddingは左ゼロ埋め_00HOGEで電文作成され変換ステータスが処理完了となる() {
    String facilityCd = "TEST03";
    String coopCd = "TEST_CD";
    byte[] expect = "00HOGE".getBytes();

    try {
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      doReturn(new ArrayList<>()).when(convertSendService).requestNtssApi(any());

      ResultActions response = request(facilityCd);
      response.andExpect(status().isOk());

      assert_ジャーナルが処理完了かつ変換開始_終了時刻および更新日時が2019年10月10日10時0分0秒である(facilityCd, coopCd, expect);
    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  @Test
  public void 正常系_送信変換API_テキスト_固定値HOGE_データ長6桁で2byte余り_paddingは右ゼロ埋め_HOGE00で電文作成され変換ステータスが処理完了となる() {
    String facilityCd = "TEST34";
    String coopCd = "TEST_CD";
    byte[] expect = "HOGE00".getBytes();

    try {
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      doReturn(new ArrayList<>()).when(convertSendService).requestNtssApi(any());

      ResultActions response = request(facilityCd);
      response.andExpect(status().isOk());

      assert_ジャーナルが処理完了かつ変換開始_終了時刻および更新日時が2019年10月10日10時0分0秒である(facilityCd, coopCd, expect);
    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  @Test
  public void 正常系_送信変換API_テキスト_固定値HOGE_データ長6桁で2byte余り_paddingは左スペース埋め_左スペース2桁HOGEで電文作成され変換ステータスが処理完了となる() {
    String facilityCd = "TEST05";
    String coopCd = "TEST_CD";
    byte[] expect = "  HOGE".getBytes();

    try {
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      doReturn(new ArrayList<>()).when(convertSendService).requestNtssApi(any());

      ResultActions response = request(facilityCd);
      response.andExpect(status().isOk());

      assert_ジャーナルが処理完了かつ変換開始_終了時刻および更新日時が2019年10月10日10時0分0秒である(facilityCd, coopCd, expect);
    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  @Test
  public void 正常系_送信変換API_テキスト_固定値HOGE_データ長6桁で2byte余り_paddingは右スペース埋め_HOGE右スペース2桁で電文作成され変換ステータスが処理完了となる() {
    String facilityCd = "TEST06";
    String coopCd = "TEST_CD";
    byte[] expect = "HOGE  ".getBytes();

    try {
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      doReturn(new ArrayList<>()).when(convertSendService).requestNtssApi(any());

      ResultActions response = request(facilityCd);
      response.andExpect(status().isOk());

      assert_ジャーナルが処理完了かつ変換開始_終了時刻および更新日時が2019年10月10日10時0分0秒である(facilityCd, coopCd, expect);
    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  @Test
  public void 正常系_送信変換API_テキスト_固定値HOGE_データ長6桁で2byte余り_paddingは左全角スペース埋め_左全角スペース1桁HOGEで電文作成され変換ステータスが処理完了となる() {
    String facilityCd = "TEST29";
    String coopCd = "TEST_CD";
    try {
      byte[] expect = "　HOGE".getBytes("SJIS");

      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      doReturn(new ArrayList<>()).when(convertSendService).requestNtssApi(any());

      ResultActions response = request(facilityCd);
      response.andExpect(status().isOk());

      assert_ジャーナルが処理完了かつ変換開始_終了時刻および更新日時が2019年10月10日10時0分0秒である(facilityCd, coopCd, expect);
    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  @Test
  public void 正常系_送信変換API_テキスト_固定値HOGE_データ長6桁で2byte余り_paddingは右全角スペース埋め_HOGE右全角スペース1桁で電文作成され変換ステータスが処理完了となる() {
    String facilityCd = "TEST30";
    String coopCd = "TEST_CD";
    try {
      byte[] expect = "HOGE　".getBytes("SJIS");

      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      doReturn(new ArrayList<>()).when(convertSendService).requestNtssApi(any());

      ResultActions response = request(facilityCd);
      response.andExpect(status().isOk());

      assert_ジャーナルが処理完了かつ変換開始_終了時刻および更新日時が2019年10月10日10時0分0秒である(facilityCd, coopCd, expect);
    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  @Test
  public void 異常系_送信変換API_テキスト_固定値HOGE_データ長5桁で1byte余り_paddingは2byteの全角スペースが入らないため変換ステータスがエラーとなる() {
    String facilityCd = "TEST31";
    String coopCd = "TEST_CD";
    try {
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      doReturn(new ArrayList<>()).when(convertSendService).requestNtssApi(any());

      ResultActions response = request(facilityCd);
      response.andExpect(status().isOk());

      assert_ジャーナルがエラーかつ変換開始時刻および更新日時が2019年10月10日10時0分0秒である(facilityCd, coopCd);
    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  @Test
  public void 異常系_送信変換API_テキスト_固定値HOGE_データ長6桁で2byte余り_paddingは存在しない値のため変換ステータスがエラーとなる() {
    String facilityCd = "TEST32";
    String coopCd = "TEST_CD";
    try {
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      doReturn(new ArrayList<>()).when(convertSendService).requestNtssApi(any());

      ResultActions response = request(facilityCd);
      response.andExpect(status().isOk());

      assert_ジャーナルがエラーかつ変換開始時刻および更新日時が2019年10月10日10時0分0秒である(facilityCd, coopCd);
    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  @Test
  public void 正常系_送信変換API_テキスト_固定長HOGEと固定長オカレンス固定長OCCリピートなし_HOGEOCCで電文作成され変換ステータスが処理完了となる() {
    String facilityCd = "TEST07";
    String coopCd = "TEST_CD";
    byte[] expect = "HOGEOCC".getBytes();
    try {
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      List<Map<String, Object>> dataSetList = detailIdがut_roop_1とdetail_001というキーで11111の値を持つデータセットモックデータ作成();
      doReturn(dataSetList).when(convertSendService).requestNtssApi(any());

      ResultActions response = request(facilityCd);
      response.andExpect(status().isOk());

      assert_ジャーナルが処理完了かつ変換開始_終了時刻および更新日時が2019年10月10日10時0分0秒である(facilityCd, coopCd, expect);
    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  @Test
  public void 正常系_送信変換API_テキスト_固定長HOGEとオカレンス固定長OCCリピート2回_HOGEOCCOCCで電文作成され変換ステータスが処理完了となる() {
    String facilityCd = "TEST08";
    String coopCd = "TEST_CD";
    byte[] expect = "HOGEOCCOCC".getBytes();
    try {
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      List<Map<String, Object>> dataSetList = detailIdがut_roop_1とdetail_001というキーで11111の値を持つデータセットモックデータ作成();
      dataSetList.addAll(detailIdがut_roop_1とdetail_001というキーで22222の値を持つデータセットモックデータ作成());
      doReturn(dataSetList).when(convertSendService).requestNtssApi(any());

      ResultActions response = request(facilityCd);
      response.andExpect(status().isOk());

      assert_ジャーナルが処理完了かつ変換開始_終了時刻および更新日時が2019年10月10日10時0分0秒である(facilityCd, coopCd, expect);
    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  @Test
  public void 正常系_送信変換API_テキスト_固定長HOGEとオカレンス固定長OCCデータ長3byte_パディング指定なし_HOGE1スペース2桁OCCで電文作成され変換ステータスが処理完了となる() {
    String facilityCd = "TEST09";
    String coopCd = "TEST_CD";
    byte[] expect = "HOGE1  OCC".getBytes();
    try {
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      List<Map<String, Object>> dataSetList = detailIdがut_roop_1とdetail_001というキーで11111の値を持つデータセットモックデータ作成();
      doReturn(dataSetList).when(convertSendService).requestNtssApi(any());

      ResultActions response = request(facilityCd);
      response.andExpect(status().isOk());

      assert_ジャーナルが処理完了かつ変換開始_終了時刻および更新日時が2019年10月10日10時0分0秒である(facilityCd, coopCd, expect);
    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  @Test
  public void 正常系_送信変換API_テキスト_固定長HOGEとオカレンス固定長OCCデータ長3byte_パディングは左全角スペース_HOGE全角スペース1桁1OCCで電文作成され変換ステータスが処理完了となる() {
    String facilityCd = "TEST33";
    String coopCd = "TEST_CD";
    try {
      byte[] expect = "HOGE　1OCC".getBytes("SJIS");
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      List<Map<String, Object>> dataSetList = detailIdがut_roop_1とdetail_001というキーで11111の値を持つデータセットモックデータ作成();
      doReturn(dataSetList).when(convertSendService).requestNtssApi(any());

      ResultActions response = request(facilityCd);
      response.andExpect(status().isOk());

      assert_ジャーナルが処理完了かつ変換開始_終了時刻および更新日時が2019年10月10日10時0分0秒である(facilityCd, coopCd, expect);
    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  @Test
  public void 正常系_送信変換API_テキスト_DATASETHOGE1という結果が入っているデータセット1つ_DATASETHOGE1で電文作成され変換ステータスが処理完了となる() {
    String facilityCd = "TEST10";
    String coopCd = "TEST_CD";
    byte[] expect = "DATASETHOGE1".getBytes();
    try {
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      List<Map<String, Object>> dataSetResult = DATASETHOGE1という結果のデータセットモックデータ作成();
      doReturn(dataSetResult).when(convertSendService).requestNtssApi(any());

      ResultActions response = request(facilityCd);
      response.andExpect(status().isOk());

      assert_ジャーナルが処理完了かつ変換開始_終了時刻および更新日時が2019年10月10日10時0分0秒である(facilityCd, coopCd, expect);
      assert_ntssapiへのアクセスは1回行われた();
    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  @Test
  public void 正常系_送信変換API_テキスト_DATASETHOGE1にDATASETHOGE2と異なるSQLCODEのデータセット2つ_DATASETHOGE1DATASETHOGE2で電文作成され変換ステータスが処理完了となる() {
    String facilityCd = "TEST11";
    String coopCd = "TEST_CD";
    byte[] expect = "DATASETHOGE1DATASETHOGE2".getBytes();
    try {
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      List<Map<String, Object>> dataSetResultByDATASETHOGE1 = DATASETHOGE1という結果のデータセットモックデータ作成();
      List<Map<String, Object>> dataSetResultByDATASETHOGE2 = DATASETHOGE2という結果のデータセットモックデータ作成();
      doReturn(dataSetResultByDATASETHOGE1, dataSetResultByDATASETHOGE2).when(convertSendService).requestNtssApi(any());

      ResultActions response = request(facilityCd);
      response.andExpect(status().isOk());

      assert_ジャーナルが処理完了かつ変換開始_終了時刻および更新日時が2019年10月10日10時0分0秒である(facilityCd, coopCd, expect);
    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  @Test
  public void 異常系_送信変換API_テキスト_固定値_コロンがないレイアウトフォーマットが来る_変換ステータスがエラーとなる() {
    String facilityCd = "TEST12";
    String coopCd = "TEST_CD";
    try {
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      doReturn(new ArrayList<>()).when(convertSendService).requestNtssApi(any());

      ResultActions response = request(facilityCd);
      response.andExpect(status().isOk());

      assert_ジャーナルがエラーかつ変換開始時刻および更新日時が2019年10月10日10時0分0秒である(facilityCd, coopCd);
    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  @Test
  public void 正常系_送信変換API_テキスト_データセット_拡張設定がないのにデータセットからの出力設定がある_スペース12桁で電文作成され変換ステータスが処理完了となる() {
    String facilityCd = "TEST13";
    String coopCd = "TEST_CD";
    byte[] expect = "            ".getBytes();
    try {
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      doReturn(new HashMap<>()).when(convertSendService).createRequestAndRequestByDataSetApi(any(), any(), any());

      ResultActions response = request(facilityCd);
      response.andExpect(status().isOk());

      assert_ジャーナルが処理完了かつ変換開始_終了時刻および更新日時が2019年10月10日10時0分0秒である(facilityCd, coopCd, expect);
    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  @Test
  public void 異常系_送信変換API_テキスト_データセット_データセット結果はあるがドットがないレイアウトフォーマットが来る_変換ステータスがエラーとなる() {
    String facilityCd = "TEST14";
    String coopCd = "TEST_CD";
    try {
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      doReturn(DATASETHOGE1という結果のデータセットモックデータ作成()).when(convertSendService).requestNtssApi(any());

      ResultActions response = request(facilityCd);
      response.andExpect(status().isOk());

      assert_ジャーナルがエラーかつ変換開始時刻および更新日時が2019年10月10日10時0分0秒である(facilityCd, coopCd);
      assert_ntssapiへのアクセスは1回行われた();
    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  @Test
  public void 異常系_送信変換API_テキスト_データセット_データセットへのアクセスでNtssExceptionが発生する_変換ステータスがエラーとなる() {
    String facilityCd = "TEST10";
    String coopCd = "TEST_CD";
    try {
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      doThrow(NtssException.class).when(convertSendService).requestNtssApi(any());

      ResultActions response = request(facilityCd);
      response.andExpect(status().isOk());

      assert_ジャーナルがエラーかつ変換開始時刻および更新日時が2019年10月10日10時0分0秒である(facilityCd, coopCd);
      assert_ntssapiへのアクセスは1回行われた();
    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  @Test
  public void 正常系_送信変換API_テキスト_固定値$SYSDATE_20191010で電文作成され変換ステータスが処理完了となる() {
    String facilityCd = "TEST15";
    String coopCd = "TEST_CD";
    byte[] expect = "20191010".getBytes();
    try {
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      doReturn(getExpectMockClock()).when(clockWrapper).getClock();

      ResultActions response = request(facilityCd);
      response.andExpect(status().isOk());

      assert_ジャーナルが処理完了かつ変換開始_終了時刻および更新日時が2019年10月10日10時0分0秒である(facilityCd, coopCd, expect);
    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  @Test
  public void 正常系_送信変換API_テキスト_固定値$SYSTIME_100000で電文作成され変換ステータスが処理完了となる() {
    String facilityCd = "TEST16";
    String coopCd = "TEST_CD";
    byte[] expect = "100000".getBytes();
    try {
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      doReturn(getExpectMockClock()).when(clockWrapper).getClock();

      ResultActions response = request(facilityCd);
      response.andExpect(status().isOk());

      assert_ジャーナルが処理完了かつ変換開始_終了時刻および更新日時が2019年10月10日10時0分0秒である(facilityCd, coopCd, expect);
    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  @Test
  public void 正常系_送信変換API_テキスト_SQLCODEに紐づいた結果が空のデータセット_長さ12byte_スペース12桁で電文作成され変換ステータスが処理完了となる() {
    String facilityCd = "TEST10";
    String coopCd = "TEST_CD";
    byte[] expect = "            ".getBytes();
    try {
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      List<Map<String, Object>> dataSetList = new ArrayList<>();
      Map<String, Object> dataSetResult = new HashMap<>();
      dataSetResult.put("test_dataset_result", "");
      dataSetList.add(dataSetResult);
      doReturn(dataSetList).when(convertSendService).requestNtssApi(any());

      ResultActions response = request(facilityCd);
      response.andExpect(status().isOk());

      assert_ジャーナルが処理完了かつ変換開始_終了時刻および更新日時が2019年10月10日10時0分0秒である(facilityCd, coopCd, expect);
      assert_ntssapiへのアクセスは1回行われた();
    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  @Test
  public void 正常系_送信変換API_テキスト_固定長HOGEとオカレンス固定長OCCデータ長3byte_左ゼロ埋め_HOGE001OCCで電文作成され変換ステータスが処理完了となる() {
    String facilityCd = "TEST17";
    String coopCd = "TEST_CD";
    byte[] expect = "HOGE001OCC".getBytes();
    try {
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      List<Map<String, Object>> dataSetList = detailIdがut_roop_1とdetail_001というキーで11111の値を持つデータセットモックデータ作成();
      doReturn(dataSetList).when(convertSendService).requestNtssApi(any());

      ResultActions response = request(facilityCd);
      response.andExpect(status().isOk());

      assert_ジャーナルが処理完了かつ変換開始_終了時刻および更新日時が2019年10月10日10時0分0秒である(facilityCd, coopCd, expect);
    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  @Test
  public void 正常系_送信変換API_テキスト_固定値ダブルクォートのエスケープにHOGE_ダブルクォートHOGEで電文作成され変換ステータスが処理完了となる() {
    String facilityCd = "TEST18";
    String coopCd = "TEST_CD";
    byte[] expect = "\"HOGE".getBytes();
    try {
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      doReturn(new ArrayList<>()).when(convertSendService).requestNtssApi(any());

      ResultActions response = request(facilityCd);
      response.andExpect(status().isOk());

      assert_ジャーナルが処理完了かつ変換開始_終了時刻および更新日時が2019年10月10日10時0分0秒である(facilityCd, coopCd, expect);
    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  @Test
  public void 正常系_送信変換API_テキスト_固定値HOGE改行HOGE_HOGE改行HOGEで電文作成され変換ステータスが処理完了となる() {
    String facilityCd = "TEST19";
    String coopCd = "TEST_CD";
    byte[] expect = "HOGE\rHOGE".getBytes();
    try {
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      doReturn(new ArrayList<>()).when(convertSendService).requestNtssApi(any());

      ResultActions response = request(facilityCd);
      response.andExpect(status().isOk());

      assert_ジャーナルが処理完了かつ変換開始_終了時刻および更新日時が2019年10月10日10時0分0秒である(facilityCd, coopCd, expect);
    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  @Test
  public void 異常系_送信変換API_テキスト_固定値あいうえお_長さ2byte_電文長エラーとなり変換ステータスがエラーとなる() {
    String facilityCd = "TEST20";
    String coopCd = "TEST_CD";
    try {
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      doReturn(new ArrayList<>()).when(convertSendService).requestNtssApi(any());

      ResultActions response = request(facilityCd);
      response.andExpect(status().isOk());

      assert_ジャーナルがエラーかつ変換開始時刻および更新日時が2019年10月10日10時0分0秒である(facilityCd, coopCd);
    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  @Test
  public void 正常系_送信変換API_テキスト_電文長6byte_6スペース5桁となり変換ステータスが処理完了となる() {
    String facilityCd = "TEST21";
    String coopCd = "TEST_CD";
    byte[] expect = "6     ".getBytes();
    try {
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      doReturn(new ArrayList<>()).when(convertSendService).requestNtssApi(any());

      ResultActions response = request(facilityCd);
      response.andExpect(status().isOk());

      assert_ジャーナルが処理完了かつ変換開始_終了時刻および更新日時が2019年10月10日10時0分0秒である(facilityCd, coopCd, expect);
    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  @Test
  public void 正常系_送信変換API_テキスト_HOGE電文長6byte_HOGE10スペース4桁となり変換ステータスが処理完了となる() {
    String facilityCd = "TEST22";
    String coopCd = "TEST_CD";
    byte[] expect = "HOGE10    ".getBytes();
    try {
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      doReturn(new ArrayList<>()).when(convertSendService).requestNtssApi(any());

      ResultActions response = request(facilityCd);
      response.andExpect(status().isOk());

      assert_ジャーナルが処理完了かつ変換開始_終了時刻および更新日時が2019年10月10日10時0分0秒である(facilityCd, coopCd, expect);
    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  @Test
  public void 正常系_送信変換API_テキスト_HOGE電文長6byte電文長6byte_HOGE16スペース4桁16スペース4桁となり変換ステータスが処理完了となる() {
    String facilityCd = "TEST23";
    String coopCd = "TEST_CD";
    byte[] expect = "HOGE16    16    ".getBytes();
    try {
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      doReturn(new ArrayList<>()).when(convertSendService).requestNtssApi(any());

      ResultActions response = request(facilityCd);
      response.andExpect(status().isOk());

      assert_ジャーナルが処理完了かつ変換開始_終了時刻および更新日時が2019年10月10日10時0分0秒である(facilityCd, coopCd, expect);
    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  @Test
  public void 異常系_送信変換API_ジャーナルはあるがレイアウトがない_変換ステータスがエラーとなる() {
    String facilityCd = "TEST24";
    String coopCd = "TEST_CD";
    try {
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      doReturn(new ArrayList<>()).when(convertSendService).requestNtssApi(any());

      ResultActions response = request(facilityCd);
      response.andExpect(status().isOk());

      assert_ジャーナルがエラーかつ変換開始時刻および更新日時が2019年10月10日10時0分0秒である(facilityCd, coopCd);
    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  @Test
  public void 異常系_送信変換API_ジャーナルとレイアウトはあるがレイアウトDetailがない_変換ステータスがエラーとなる() {
    String facilityCd = "TEST25";
    String coopCd = "TEST_CD";
    try {
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      List<Map<String, Object>> dataSetResult = DATASETHOGE1という結果のデータセットモックデータ作成();
      doReturn(dataSetResult).when(convertSendService).requestNtssApi(any());

      ResultActions response = request(facilityCd);
      response.andExpect(status().isOk());

      assert_ジャーナルがエラーかつ変換開始時刻および更新日時が2019年10月10日10時0分0秒である(facilityCd, coopCd);
      assert_ntssapiへのアクセスは1回行われた();
    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  @Test
  public void 正常系_送信変換API_テキスト_要素分回らなかったので1回ブランク埋め_HOGEオカレンスリピート2回OCC3byte_HOGEOCCスペース3桁となり変換ステータスが処理完了となる() {
    String facilityCd = "TEST26";
    String coopCd = "TEST_CD";
    byte[] expect = "HOGEOCC   ".getBytes();
    try {
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      List<Map<String, Object>> dataSetResult = detailIdがut_roop_1とdetail_001というキーで11111の値を持つデータセットモックデータ作成();
      doReturn(dataSetResult).when(convertSendService).requestNtssApi(any());

      ResultActions response = request(facilityCd);
      response.andExpect(status().isOk());

      assert_ジャーナルが処理完了かつ変換開始_終了時刻および更新日時が2019年10月10日10時0分0秒である(facilityCd, coopCd, expect);
      assert_ntssapiへのアクセスは1回行われた();
    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  @Test
  public void 正常系_送信変換API_テキスト_detailレイアウトのオカレンスの中でdatasetが呼ばれる_オカレンス固定長OCCデータ長3byteにdataset11111_HOGE1スペース3桁OCC1スペース3桁11111となり変換ステータスが処理完了となる() {
    String facilityCd = "TEST27";
    String coopCd = "TEST_CD";
    byte[] expect = "HOGE1   OCC1   11111".getBytes();
    try {
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      List<Map<String, Object>> dataSetResultByUtLoop1 = detailIdがut_roop_1とdetail_001というキーで11111の値を持つデータセットモックデータ作成();
      List<Map<String, Object>> dataSetResultByUtLoop2 = detailIdがut_roop_2とdetail_001というキーで11111の値を持つデータセットモックデータ作成();
      doReturn(dataSetResultByUtLoop1, dataSetResultByUtLoop2).when(convertSendService).requestNtssApi(any());

      ResultActions response = request(facilityCd);
      response.andExpect(status().isOk());

      assert_ジャーナルが処理完了かつ変換開始_終了時刻および更新日時が2019年10月10日10時0分0秒である(facilityCd, coopCd, expect);
      assert_ntssapiへのアクセスは2回行われた();
    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  @Test
  public void 正常系_送信変換API_テキスト_電文長計算を含むdetailレイアウトのオカレンスの中でdatasetが呼ばれる_オカレンス固定長OCCデータ長3byteにdataset11111_HOGE20スペース4桁1スペース3桁OCC1スペース3桁11111となり変換ステータスが処理完了となる() {
    String facilityCd = "TEST28";
    String coopCd = "TEST_CD";
    byte[] expect = "HOGE26    1   OCC1   11111".getBytes();
    try {
      // システム日時をモック化
      given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());
      List<Map<String, Object>> dataSetResultByUtLoop1 = detailIdがut_roop_1とdetail_001というキーで11111の値を持つデータセットモックデータ作成();
      List<Map<String, Object>> dataSetResultByUtLoop2 = detailIdがut_roop_2とdetail_001というキーで11111の値を持つデータセットモックデータ作成();
      doReturn(dataSetResultByUtLoop1, dataSetResultByUtLoop2).when(convertSendService).requestNtssApi(any());

      ResultActions response = request(facilityCd);
      response.andExpect(status().isOk());

      assert_ジャーナルが処理完了かつ変換開始_終了時刻および更新日時が2019年10月10日10時0分0秒である(facilityCd, coopCd, expect);
      assert_ntssapiへのアクセスは2回行われた();
    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  @Test
  public void 正常系_データセットマージの電文作成() {
    String facilityCd = "TEST94";
    String expect = "<?xml version=\"1.0\" encoding=\"Shift_JIS\" standalone=\"yes\"?>\r\n"
          + "<Content>\r\n"
          + "  <Row>\r\n"
          + "    <INPUTDATA>item1</INPUTDATA>\r\n"
          + "  </Row>\r\n"
          + "  <Row>\r\n"
          + "    <INPUTDATA>item1</INPUTDATA>\r\n"
          + "  </Row>\r\n"
          + "  <Row>\r\n"
          + "    <INPUTDATA>item1</INPUTDATA>\r\n"
          + "  </Row>\r\n"
          + "  <Row>\r\n"
          + "    <INPUTDATA>item1</INPUTDATA>\r\n"
          + "  </Row>\r\n"
          + "</Content>\r\n";
    try {
      ResultActions response = request(facilityCd);
      response
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status").value(200))
        .andExpect(jsonPath("$.result").isArray())
        .andExpect(jsonPath("$.result", Matchers.hasSize(1)))
        .andExpect(jsonPath("$.result[0].ana_result").value("9"))
        .andExpect(jsonPath("$.result[0].message").value(""));

      // 作成電文の確認
      SysCoopJournal journal = sysCoopJournalDao.select(facilityCd, "0", "", "C", "S");
      assertThat(journal.getDump(), is(expect.getBytes()));

    } catch (Exception e) {
      fail("送信電文処理に失敗しました", e);
    }
  }

  private ResultActions request(String facilityCd) throws IOException, Exception {
    JournalConvertReceiveRequest req = new JournalConvertReceiveRequest();
    req.setFacilityCd(facilityCd);
    return mockMvc.perform(
        post("/journal/convert/send")
        .content(ObjectMapperUtil.write(req))
        .contentType(MediaType.APPLICATION_JSON));
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

  /**
   * 指定した {@code facilityCd、coopCd} を元に {@code SysCoopJournal} を取得し、更新項目の確認を行う
   * <ul>
   *    <li>対象のレコードが存在するか
   *    <li>{@code dump が expectDump と等しいか}
   *    <li>{@code ana_result} が {@link AnaResult#DONE} と等しいか
   *    <li>{@code in_ana_date、out_ana_date、up_date がモックで指定した日時と等しいか}
   * </ul>
   * @param facilityCd 施設コード
   * @param coopCd 電文種別
   * @param expectDump 期待する dump の値
   */
  private void assert_ジャーナルが処理完了かつ変換開始_終了時刻および更新日時が2019年10月10日10時0分0秒である(String facilityCd, String coopCd, byte[] expectDump) {
    SysCoopJournal journal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");
    assertThat(journal, notNullValue());
    assertThat(journal.getDump(), is(expectDump));
    assertThat(journal.getAnaResult(), is(AnaResult.DONE.getResult()));
    assertThat(journal.getInAnaDate(), is(new Timestamp(getMockClockMillis())));
    assertThat(journal.getOutAnaDate(), is(new Timestamp(getMockClockMillis())));
    assertThat(journal.getUpDate(), is(new Timestamp(getMockClockMillis())));
  }

  /**
   * 指定した {@code facilityCd、coopCd} を元に {@code SysCoopJournal} を取得し、更新項目の確認を行う
   * <ul>
   *    <li>対象のレコードが存在するか
   *    <li>{@code dump、out_ana_date が更新されていないか}
   *    <li>{@code ana_result} が {@link AnaResult#INTERNAL_ERROR} と等しいか
   *    <li>{@code in_ana_date、up_date がモックで指定した日時と等しいか}
   * </ul>
   * @param facilityCd 施設コード
   * @param coopCd 電文種別
   * @param expectDump 期待する dump の値
   */
  private void assert_ジャーナルがエラーかつ変換開始時刻および更新日時が2019年10月10日10時0分0秒である(String facilityCd, String coopCd) {
    SysCoopJournal journal = sysCoopJournalDao.select(facilityCd, coopCd, "", "C", "S");
    assertThat(journal, notNullValue());
    assertThat(journal.getDump(), nullValue());
    assertThat(journal.getAnaResult(), is(AnaResult.INTERNAL_ERROR.getResult()));
    assertThat(journal.getInAnaDate(), is(new Timestamp(getMockClockMillis())));
    assertThat(journal.getOutAnaDate(), is(Timestamp.valueOf(getExpectTime())));
    assertThat(journal.getUpDate(), is(new Timestamp(getMockClockMillis())));
    assertThat(journal.getDump(), nullValue());
  }

  private void assert_ntssapiへのアクセスは1回行われた() {
    assert_ntssapiへのアクセスはx回行われた(1);
  }

  private void assert_ntssapiへのアクセスは2回行われた() {
    assert_ntssapiへのアクセスはx回行われた(2);
  }

  private void assert_ntssapiへのアクセスはx回行われた(int count) {
    // ntss-apiへのアクセスは2回行われる
    verify(convertSendService, times(count)).requestNtssApi(any());
  }
}
