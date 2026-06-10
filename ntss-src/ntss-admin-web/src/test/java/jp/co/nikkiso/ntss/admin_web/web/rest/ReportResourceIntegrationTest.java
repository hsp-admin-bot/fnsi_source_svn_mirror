package jp.co.nikkiso.ntss.admin_web.web.rest;

import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.request.creatingReport.ReportByCdRequest;
import jp.co.nikkiso.ntss.admin_web.request.creatingReport.ReportRequest;
import jp.co.nikkiso.ntss.api.service.report.ReportS3Service;
import org.jsoup.Jsoup;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.restdocs.mockmvc.RestDocumentationRequestBuilders;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.transaction.annotation.Transactional;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Timestamp;
import java.util.HashMap;
import java.util.Map;

import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.collection.IsCollectionWithSize.hasSize;
import static org.mockito.BDDMockito.given;
import static org.springframework.restdocs.mockmvc.MockMvcRestDocumentation.document;
import static org.springframework.restdocs.payload.PayloadDocumentation.fieldWithPath;
import static org.springframework.restdocs.payload.PayloadDocumentation.requestFields;
import static org.springframework.restdocs.payload.PayloadDocumentation.responseFields;
import static org.springframework.restdocs.request.RequestDocumentation.parameterWithName;
import static org.springframework.restdocs.request.RequestDocumentation.pathParameters;
import static org.springframework.restdocs.snippet.Attributes.attributes;
import static org.springframework.restdocs.snippet.Attributes.key;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * ReportResourceの結合テストクラス
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
@Sql("classpath:resource.script/ReportResourceIntegrationTest.before.sql")
public class ReportResourceIntegrationTest extends AbstractResourceIntegrationTest {

  @Autowired
  private ObjectMapper objectMapper;

  /**
   * 帳票取得のServiceのMockBean.
   */
  @MockBean
  private ReportS3Service reportS3Service;

  /**
   * getReportHtml()の検証
   * 条件: 帳票種別、帳票区分を指定する
   * 結果: 帳票HTMLがレスポンスとして返却されること
   */
  @Test
  @NtssMockUser(facilityCd = "00001")
  public void test_getReportHtml_成功() throws Exception {
    // arrange
    final Integer reportClass = 2;
    final Integer reportType = 3;
    @SuppressWarnings("serial")
    Map<String, Object> dataKey = new HashMap<String, Object>() {
      {
        put("param1", "value1");
        put("param2", "value2");
      }
    };
    Long targetPrinter = 1L;
    ReportRequest request = new ReportRequest();
    request.setReportClass(reportClass);
    request.setReportType(reportType);
    request.setDataKey(dataKey);
    request.setTargetPrinter(targetPrinter);
    final String requestBody = objectMapper.writeValueAsString(request);

    // S3からの取得箇所をMock化
    String zipPath = "テスト英字ファイル.zip";
    String bucket = "ntss-esm";
    String reportHtml = "<html></html>";
    Timestamp upDate = Timestamp.valueOf("2019-02-13 14:00:00");

    Path path = Paths.get(getClass().getClassLoader().getResource("resource.report/" + zipPath).toURI());
    byte[] bytes = Files.readAllBytes(path);

    org.jsoup.nodes.Document document = Jsoup.parse(reportHtml);
    String expected = document.html();

    // Mock化
    given(reportS3Service.getReportFile(bucket, zipPath, upDate)).willReturn(bytes);

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.post("/api/report/creating-report")
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf())
    );

    // assert
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$", notNullValue()))
      .andExpect(jsonPath("$.reportHtml", is("")))
      .andExpect(jsonPath("$.dataKey.param1", is("value1")))
      .andExpect(jsonPath("$.dataKey.param2", is("value2")))
      .andDo(document("report/creating-report/get/ok",
        requestFields(
          attributes(
            key("description").value("概要：指定された帳票種別、帳票区分に該当する帳票を取得するAPI"),
            key("operationTargetTable").value("操作対象テーブル：帳票マスタ (mst_report)")
          ),
          fieldWithPath("reportClass").description("帳票種別")
          , fieldWithPath("reportType").description("帳票区分")
          , fieldWithPath("dataKey.*").description("帳票抽出条件")
          , fieldWithPath("targetPrinter").description("出力先プリンタ")
          , fieldWithPath("pdfPath").description("PDF格納先パス(Amazon S3)")
          , fieldWithPath("excelPath").description("Excelファイル格納先パス(Amazon S3)")
        ),
        responseFields(
            attributes(
              key("description").value(""),
              key("operationTargetTable").value("")
            ),
          fieldWithPath("reportHtml").description("指定された帳票HTML")
          , fieldWithPath("dataKey.*").description("抽出キー")
        )
      ));
  }

  /**
   * getReportHtml()の検証
   * 条件: 帳票マスタに存在しない帳票種別、帳票区分を指定する
   * 結果: 失敗レスポンスが返却されること
   */
  @Test
  @NtssMockUser
  public void test_getReportHtml_失敗() throws Exception {
    // arrange
    final Integer reportClass = 9999;
    final Integer reportType = 9999;
    @SuppressWarnings("serial")
    Map<String, Object> dataKey = new HashMap<String, Object>() {
      {
        put("param1", "value1");
        put("param2", "value2");
      }
    };
    Long targetPrinter = 1L;
    ReportRequest request = new ReportRequest();
    request.setReportClass(reportClass);
    request.setReportType(reportType);
    request.setDataKey(dataKey);
    request.setTargetPrinter(targetPrinter);
    final String requestBody = objectMapper.writeValueAsString(request);

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.post("/api/report/creating-report")
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf())
    );

    // assert
    result.andExpect(status().isBadRequest())
      .andDo(document("report/creating-report/get/not-found"));
  }

  /**
   * getReportHtmlByCd()の検証
   * 条件: レポートコードを指定する
   * 結果: 帳票HTMLがレスポンスとして返却されること
   */
  @Test
  @NtssMockUser
  public void test_getReportHtmlByCd_成功() throws Exception {
    // arrange
    final Long reportCd = 1L;
    @SuppressWarnings("serial")
    Map<String, Object> dataKey = new HashMap<String, Object>() {
      {
        put("param1", "value1");
        put("param2", "value2");
      }
    };
    Long targetPrinter = 1L;
    ReportByCdRequest request = new ReportByCdRequest();
    request.setDataKey(dataKey);
    request.setTargetPrinter(targetPrinter);
    final String requestBody = objectMapper.writeValueAsString(request);

    // S3からの取得箇所をMock化
    String zipPath = "テスト英字ファイル.zip";
    String bucket = "ntss-esm";
    String reportHtml = "<html></html>";
    Timestamp upDate = Timestamp.valueOf("2019-02-13 14:00:00");

    Path path = Paths.get(getClass().getClassLoader().getResource("resource.report/" + zipPath).toURI());
    byte[] bytes = Files.readAllBytes(path);

    // Mock化
    given(reportS3Service.getReportFile(bucket, zipPath, upDate)).willReturn(bytes);

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.post("/api/report/creating-report/{reportCd}", reportCd)
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf())
    );

    // assert
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$", notNullValue()))
      .andExpect(jsonPath("$.reportHtml", is("")))
      .andExpect(jsonPath("$.dataKey.param1", is("value1")))
      .andExpect(jsonPath("$.dataKey.param2", is("value2")))
      .andDo(document("report/creating-report/get-report-cd/ok",
        pathParameters(
          parameterWithName("reportCd").description("[必須]レポートコード")
        ),
        requestFields(
          attributes(
            key("description").value("概要：指定されたレポートコードに該当する帳票を取得するAPI"),
            key("operationTargetTable").value("操作対象テーブル：帳票マスタ (mst_report)")
          ),
          fieldWithPath("isPreview").description("プレビューフラグ(\"0\":しない, \"1\":する)")
          , fieldWithPath("dataKey.*").description("帳票抽出条件")
          , fieldWithPath("targetPrinter").description("出力先プリンタ")
          , fieldWithPath("pdfPath").description("PDF格納先パス(Amazon S3)")
          , fieldWithPath("excelPath").description("Excelファイル格納先パス(Amazon S3)")
        ),
        responseFields(
          attributes(
            key("description").value(""),
            key("operationTargetTable").value("")
          ),
          fieldWithPath("reportHtml").description("指定された帳票HTML")
          , fieldWithPath("dataKey.*").description("抽出キー")
        )
      ));
  }

  /**
   * getReportHtmlByCd()の検証
   * 条件: 帳票マスタに存在しないレポートコードを指定する
   * 結果: 失敗レスポンスが返却されること
   */
  @Test
  @NtssMockUser
  public void test_getReportHtmlByCd_失敗() throws Exception {
    // arrange
    final Long reportCd = 9999L;
    @SuppressWarnings("serial")
    Map<String, Object> dataKey = new HashMap<String, Object>() {
      {
        put("param1", "value1");
        put("param2", "value2");
      }
    };
    Long targetPrinter = 1L;
    ReportByCdRequest request = new ReportByCdRequest();
    request.setDataKey(dataKey);
    request.setTargetPrinter(targetPrinter);
    final String requestBody = objectMapper.writeValueAsString(request);

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.post("/api/report/creating-report/{reportCd}", reportCd)
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf())
    );

    // assert
    result.andExpect(status().isBadRequest())
      .andDo(document("report/creating-report/get-report-cd/not-found"));
  }

  /**
   * getMstReport()の検証.
   *
   * 条件: 機能コードを指定する
   * 結果: 帳票マスタがレスポンスとして返却されること
   */
  @Test
  @NtssMockUser(facilityCd = "00001")
  public void test_getMstReport_成功() throws Exception {
    // arrange
    final String funcCd = "001";

    // action
    mockMvc
      .perform(RestDocumentationRequestBuilders.get("/api/report/mst-report/{funcCd}", funcCd)
        .contentType(MediaType.APPLICATION_JSON_UTF8))
      // assert
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", notNullValue()))
      .andExpect(jsonPath("$.mstReports", hasSize(2)))
      .andExpect(jsonPath("$.mstReports[0].reportCd", is(101)))
      .andExpect(jsonPath("$.mstReports[0].reportName", is("テスト帳票1")))
      // reportPathの一部を検証
      .andExpect(jsonPath("$.mstReports[0].reportPath.bucket", is("ntss-esm")))
      .andExpect(jsonPath("$.mstReports[0].reportClass", is(9)))
      .andExpect(jsonPath("$.mstReports[0].reportType", is(8)))
      .andExpect(jsonPath("$.mstReports[0].extractionCondition", is("[\"pat_id\", \"ord_no\"]")))
      .andExpect(jsonPath("$.mstReports[0].defaultPrinter", is(21)))
      .andExpect(jsonPath("$.mstReports[1].reportCd", is(102)))
      .andExpect(jsonPath("$.mstReports[1].reportName", is("テスト帳票2")))
      .andExpect(jsonPath("$.mstReports[1].reportPath.bucket", is("ntss-esm")))
      .andExpect(jsonPath("$.mstReports[1].reportClass", is(7)))
      .andExpect(jsonPath("$.mstReports[1].reportType", is(6)))
      .andExpect(jsonPath("$.mstReports[1].extractionCondition", is("[\"pat_id\"]")))
      .andExpect(jsonPath("$.mstReports[1].defaultPrinter", is(22)))
      .andExpect(jsonPath("$.isPreview", is("1")))
      .andExpect(jsonPath("$.printerInfos", hasSize(3)))
      .andExpect(jsonPath("$.printerInfos[0].printerCd", is(1)))
      .andExpect(jsonPath("$.printerInfos[0].printerName", is("name1")))
      .andExpect(jsonPath("$.printerInfos[0].dispPrinterName", is("dispName1")))
      .andExpect(jsonPath("$.printerInfos[1].printerCd", is(3)))
      .andExpect(jsonPath("$.printerInfos[1].printerName", is("name3")))
      .andExpect(jsonPath("$.printerInfos[1].dispPrinterName", is("dispName3")))
      .andExpect(jsonPath("$.printerInfos[2].printerCd", is(2)))
      .andExpect(jsonPath("$.printerInfos[2].printerName", is("name2")))
      .andExpect(jsonPath("$.printerInfos[2].dispPrinterName", is("dispName2")))
      .andDo(
        document("report/mst_report/get/ok",
          pathParameters(
            parameterWithName("funcCd").description("[必須]機能コード")
          ),
          responseFields(
            attributes(
              key("description").value("概要：指定された機能コードとサインインしているユーザーの施設コードに該当する帳票マスタを取得するAPI"),
              key("operationTargetTable").value("操作対象テーブル：機能帳票マスタ (mst_function_report)、帳票マスタ (mst_report)")
            ),
            fieldWithPath("mstReports").description("帳票マスタ情報")
            , fieldWithPath("mstReports[].reportCd").description("レポートコード")
            , fieldWithPath("mstReports[].facilityCd").ignored()
            , fieldWithPath("mstReports[].reportName").description("帳票名")
            , fieldWithPath("mstReports[].reportPath").description("3ファイルのフルパス")
            , fieldWithPath("mstReports[].reportPath.bucket").ignored()
            , fieldWithPath("mstReports[].reportPath.xlsx_zip").ignored()
            , fieldWithPath("mstReports[].reportPath.report_zip").ignored()
            , fieldWithPath("mstReports[].reportPath.xlsx_filename").ignored()
            , fieldWithPath("mstReports[].reportPath.html_filename").ignored()
            , fieldWithPath("mstReports[].reportPath.xml_filename").ignored()
            , fieldWithPath("mstReports[].reportClass").description("帳票種別")
            , fieldWithPath("mstReports[].reportType").description("帳票区分")
            , fieldWithPath("mstReports[].extractionCondition").description("抽出条件")
            , fieldWithPath("mstReports[].defaultPrinter").description("プリンター初期値")
            , fieldWithPath("mstReports[].isDisp").ignored()
            , fieldWithPath("mstReports[].isDel").ignored()
            , fieldWithPath("mstReports[].regDate").ignored()
            , fieldWithPath("mstReports[].upDate").ignored()
            , fieldWithPath("mstReports[].operatorId").description("操作者ID(ログ出力用)").optional()
            , fieldWithPath("mstReports[].targetFacilityCd").description("処理対象施設コード(ログ出力用)").optional()
            , fieldWithPath("mstReports[].additionalInfo").description("追加情報").optional()
            , fieldWithPath("isPreview").description("プレビューフラグ（\"1\":する \"0\":しない）")
            , fieldWithPath("printerInfos").description("プリンタ情報")
            , fieldWithPath("printerInfos[].printerCd").description("プリンタコード")
            , fieldWithPath("printerInfos[].printerName").description("プリンタ名")
            , fieldWithPath("printerInfos[].dispPrinterName").description("表示プリンタ名")
          )
        )
      )
    ;
  }

}
