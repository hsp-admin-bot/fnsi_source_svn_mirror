package jp.co.nikkiso.ntss.admin_web.web.rest;

import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.request.creatingReport.ReportByCdRequest;
import jp.co.nikkiso.ntss.admin_web.request.creatingReport.ReportRequest;
import jp.co.nikkiso.ntss.admin_web.response.creatingReport.PrinterInfo;
import jp.co.nikkiso.ntss.admin_web.service.FacilitySettingService;
import jp.co.nikkiso.ntss.admin_web.service.print.PrinterService;
import jp.co.nikkiso.ntss.api.service.report.ReportService;
import jp.co.nikkiso.ntss.core.entity.MstReport;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.notNullValue;
import static org.junit.Assert.assertThat;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyMap;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * ReportResourceのテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@WithMockUser
public class ReportResourceTest extends AbstractResourceTest {

  /**
   * ObjectMapper.
   */
  @Autowired
  private ObjectMapper mapper;

  /**
   * 帳票作成Service.
   */
  @MockBean
  private ReportService reportService;

  /**
   * 施設設定Service.
   */
  @MockBean
  private FacilitySettingService facilitySettingService;

  /**
   * プリンタService.
   */
  @MockBean
  private PrinterService printerService;

  /**
   * getMstReport()の検証.
   * <p>
   * 条件：成功 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser
  public void test_getMstReport_成功() throws Exception {
    // 事前準備
    final String funcCd = "001";
    final String facilityCd = "000001";
    final String previewFlg = "1";

    List<MstReport> mstReports = Arrays.asList(
      new MstReport() {
        {
          setReportCd(1L);
          setFacilityCd(facilityCd);
          setReportName("テスト帳票1");
          setReportPath(new MstReport.ReportPath() {
            {
              setBucket("バケット1");
            }
          });
          setReportClass(2);
          setReportType(3);
          //setExtractionCondition("抽出条件1");
          setDefaultPrinter(11L);
        }
      }
      , new MstReport() {
        {
          setReportCd(2L);
          setFacilityCd(facilityCd);
          setReportName("テスト帳票2");
          setReportPath(new MstReport.ReportPath() {
            {
              setBucket("バケット2");
            }
          });
          setReportClass(3);
          setReportType(4);
          //setExtractionCondition("抽出条件2");
          setDefaultPrinter(12L);
        }
      }
    );

    List<PrinterInfo> printerInfos = Arrays.asList(
      new PrinterInfo(1L, "プリンタ1", "表示プリンタ1"),
      new PrinterInfo(2L, "プリンタ2", "表示プリンタ2")
    );

    ArgumentCaptor<String> args1 = ArgumentCaptor.forClass(String.class);
    ArgumentCaptor<String> args2 = ArgumentCaptor.forClass(String.class);
    ArgumentCaptor<String> args3 = ArgumentCaptor.forClass(String.class);

    // Mock化
    given(reportService.getMstReport(args1.capture(), args2.capture(),null)).willReturn(mstReports);
    given(facilitySettingService.getFacilitySettingValue(args2.capture(), args3.capture())).willReturn(previewFlg);
    given(printerService.getPrinterInfos(args2.capture())).willReturn(printerInfos);

    // API実行
    // 検証
    mockMvc
      .perform(MockMvcRequestBuilders.get("/api/report/mst-report/{funcCd}", funcCd)
        .contentType(MediaType.APPLICATION_JSON_UTF8))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", notNullValue()))
      .andExpect(jsonPath("$.mstReports", hasSize(2)))
      .andExpect(jsonPath("$.mstReports[0].reportCd", is(1)))
      .andExpect(jsonPath("$.mstReports[0].reportName", is("テスト帳票1")))
      // reportPathの一部を検証
      .andExpect(jsonPath("$.mstReports[0].reportPath.bucket", is("バケット1")))
      .andExpect(jsonPath("$.mstReports[0].reportClass", is(2)))
      .andExpect(jsonPath("$.mstReports[0].reportType", is(3)))
      .andExpect(jsonPath("$.mstReports[0].extractionCondition", is("抽出条件1")))
      .andExpect(jsonPath("$.mstReports[0].defaultPrinter", is(11)))
      .andExpect(jsonPath("$.mstReports[1].reportCd", is(2)))
      .andExpect(jsonPath("$.mstReports[1].reportName", is("テスト帳票2")))
      .andExpect(jsonPath("$.mstReports[1].reportPath.bucket", is("バケット2")))
      .andExpect(jsonPath("$.mstReports[1].reportClass", is(3)))
      .andExpect(jsonPath("$.mstReports[1].reportType", is(4)))
      .andExpect(jsonPath("$.mstReports[1].extractionCondition", is("抽出条件2")))
      .andExpect(jsonPath("$.mstReports[1].defaultPrinter", is(12)))
      .andExpect(jsonPath("$.isPreview", is("1")))
      .andExpect(jsonPath("$.printerInfos[0].printerCd", is(1)))
      .andExpect(jsonPath("$.printerInfos[0].printerName", is("プリンタ1")))
      .andExpect(jsonPath("$.printerInfos[0].dispPrinterName", is("表示プリンタ1")))
      .andExpect(jsonPath("$.printerInfos[1].printerCd", is(2)))
      .andExpect(jsonPath("$.printerInfos[1].printerName", is("プリンタ2")))
      .andExpect(jsonPath("$.printerInfos[1].dispPrinterName", is("表示プリンタ2")))
    ;

    // 検証
    verify(reportService, times(1)).getMstReport(funcCd, facilityCd,null);
    verify(printerService, times(1)).getPrinterInfos(facilityCd);
    assertThat(args1.getValue(), is(funcCd));
    assertThat(args2.getValue(), is(facilityCd));
  }


  /**
   * getMstReport()の検証.
   * <p>
   * 条件：失敗 結果：失敗レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser
  public void test_getMstReport_失敗() throws Exception {
    // 事前準備
    final String funcCd = "001";
    final String facilityCd = "000001";

    // Mock化
    given(reportService.getMstReport(anyString(), anyString(),null)).willThrow(new NotExistException("帳票マスタが見つからない"));

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.get("/api/report/mst-report/{funcCd}", funcCd)
      .contentType(MediaType.APPLICATION_JSON_UTF8));

    // 検証
    verify(reportService, times(1)).getMstReport(funcCd, facilityCd,null);
    result
      .andExpect(status().isBadRequest());
  }

  /**
   * getReportHtml()の検証.
   * <p>
   * 条件：成功 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(userId = 99999L, facilityCd = "3")
  public void test_getReportHtml_成功() throws Exception {
    // 事前準備
    Integer reportClass = 1;
    Integer reportType = 2;
    Long reportCd = 4L;
    @SuppressWarnings("serial")
    Map<String, Object> dataKey = new HashMap<String, Object>() {
      {
        put("param1", "value1");
        put("param2", "value2");
        put("login", "username");
      }
    };
    Long targetPrinter = 1L;
    Long userId = 99999L;
    MstReport mstReport = new MstReport() {
      {
        setReportCd(reportCd);
      }
    };

    ReportRequest request = new ReportRequest();
    request.setReportClass(reportClass);
    request.setReportType(reportType);
    request.setDataKey(dataKey);
    request.setTargetPrinter(targetPrinter);
    String requestBody = mapper.writeValueAsString(request);

    String reportHtml = "<html></html>";

    ArgumentCaptor<Long> args1 = ArgumentCaptor.forClass(Long.class);
    @SuppressWarnings("unchecked")
    ArgumentCaptor<Map<String, Object>> args2 = ArgumentCaptor.forClass(Map.class);
    ArgumentCaptor<Long> args3 = ArgumentCaptor.forClass(Long.class);
    ArgumentCaptor<Long> args4 = ArgumentCaptor.forClass(Long.class);

    // Mock化
    given(reportService.getMstReport(anyInt(), anyInt(), anyString())).willReturn(mstReport);
    given(reportService.getReportHtml(args1.capture(), args2.capture(), args3.capture(), args4.capture()))
      .willReturn(reportHtml);

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.post("/api/report/creating-report")
      .contentType(MediaType.APPLICATION_JSON_UTF8).content(requestBody).with(csrf()));

    // 検証
    verify(reportService, times(1)).getReportHtml(anyLong(), anyMap(), anyLong(), anyLong());
    assertThat(args1.getValue(), is(reportCd));
    assertThat(mapper.writeValueAsString(args2.getValue()), is(mapper.writeValueAsString(dataKey)));
    assertThat(args3.getValue(), is(targetPrinter));
    assertThat(args4.getValue(), is(userId));

    String response = "{\"reportHtml\":\"<html></html>\",\"dataKey\":{\"login\":\"username\",\"param1\":\"value1\",\"param2\":\"value2\"}}";
    result.andExpect(status().isOk()).andExpect(content().string(response));
  }

  /**
   * getReportHtml()の検証.
   * <p>
   * 条件：失敗 結果：失敗レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser
  public void test_getReportHtml_失敗() throws Exception {
    // 事前準備
    Integer reportClass = 1;
    Integer reportType = 2;
    Long reportCd = 4L;
    @SuppressWarnings("serial")
    Map<String, Object> dataKey = new HashMap<String, Object>() {
      {
        put("param1", "value1");
        put("param2", "value2");
      }
    };
    Long targetPrinter = 1L;
    MstReport mstReport = new MstReport() {
      {
        setReportCd(reportCd);
      }
    };

    ReportRequest request = new ReportRequest();
    request.setReportClass(reportClass);
    request.setReportType(reportType);
    request.setDataKey(dataKey);
    request.setTargetPrinter(targetPrinter);
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    given(reportService.getMstReport(anyInt(), anyInt(), anyString())).willReturn(mstReport);
    given(reportService.getReportHtml(anyLong(), anyMap(), anyLong(), anyLong()))
      .willThrow(new NotExistException("帳票定義が不正です"));

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.post("/api/report/creating-report")
      .contentType(MediaType.APPLICATION_JSON_UTF8).content(requestBody).with(csrf()));

    // 検証
    verify(reportService, times(1)).getReportHtml(anyLong(), anyMap(), anyLong(), anyLong());
    result.andExpect(status().isBadRequest());
  }

  /**
   * getReportHtmlByCd()の検証.
   * <p>
   * 条件：成功 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(userId = 99999L)
  public void test_getReportHtmlByCd_成功() throws Exception {
    // 事前準備
    Long reportCd = 1L;
    @SuppressWarnings("serial")
    Map<String, Object> dataKey = new HashMap<String, Object>() {
      {
        put("param1", "value1");
        put("param2", "value2");
        put("login", "username");
      }
    };
    Long targetPrinter = 1L;
    Long userId = 99999L;

    ReportByCdRequest request = new ReportByCdRequest();
    request.setDataKey(dataKey);
    request.setTargetPrinter(targetPrinter);
    String requestBody = mapper.writeValueAsString(request);

    String reportHtml = "<html></html>";

    ArgumentCaptor<Long> args1 = ArgumentCaptor.forClass(Long.class);
    @SuppressWarnings("unchecked")
    ArgumentCaptor<Map<String, Object>> args2 = ArgumentCaptor.forClass(Map.class);
    ArgumentCaptor<Long> args3 = ArgumentCaptor.forClass(Long.class);
    ArgumentCaptor<Long> args4 = ArgumentCaptor.forClass(Long.class);

    // Mock化
    given(reportService.getReportHtml(args1.capture(), args2.capture(), args3.capture(), args4.capture()))
      .willReturn(reportHtml);

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.post("/api/report/creating-report/{reportCd}", reportCd)
      .contentType(MediaType.APPLICATION_JSON_UTF8).content(requestBody).with(csrf()));

    // 検証
    verify(reportService, times(1)).getReportHtml(anyLong(), anyMap(), anyLong(), anyLong());
    assertThat(args1.getValue(), is(reportCd));
    assertThat(mapper.writeValueAsString(args2.getValue()), is(mapper.writeValueAsString(dataKey)));
    assertThat(args3.getValue(), is(targetPrinter));
    assertThat(args4.getValue(), is(userId));

    String response = "{\"reportHtml\":\"<html></html>\",\"dataKey\":{\"login\":\"username\",\"param1\":\"value1\",\"param2\":\"value2\"}}";
    result.andExpect(status().isOk()).andExpect(content().string(response));
  }

  /**
   * getReportHtmlByCd()の検証.
   * <p>
   * 条件：失敗 結果：失敗レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser
  public void test_getReportHtmlByCd_失敗() throws Exception {
    // 事前準備
    Long reportCd = 1L;
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
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    given(reportService.getReportHtml(anyLong(), anyMap(), anyLong(), anyLong()))
      .willThrow(new NotExistException("帳票定義が不正です"));

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.post("/api/report/creating-report/{reportCd}", reportCd)
      .contentType(MediaType.APPLICATION_JSON_UTF8).content(requestBody).with(csrf()));

    // 検証
    verify(reportService, times(1)).getReportHtml(anyLong(), anyMap(), anyLong(), anyLong());
    result.andExpect(status().isBadRequest());
  }
}
