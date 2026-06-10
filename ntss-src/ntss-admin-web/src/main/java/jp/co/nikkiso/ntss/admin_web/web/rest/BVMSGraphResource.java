package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.io.ByteArrayInputStream;
import java.math.BigDecimal;
import java.net.URL;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.validation.Valid;

import jp.co.nikkiso.ntss.admin_web.service.MstInfoService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.api.constant.ReportConstant;
import jp.co.nikkiso.ntss.api.service.utils.AsposeCellsUtils;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstDialyzerDao;
import jp.co.nikkiso.ntss.core.dao.MstEquipmentClassDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineClassDao;
import jp.co.nikkiso.ntss.core.dao.OrdPrescriptionDao;
import jp.co.nikkiso.ntss.core.entity.MstDialyzer;
import jp.co.nikkiso.ntss.core.entity.MstEquipmentClass;
import jp.co.nikkiso.ntss.core.entity.MstMedicineClass;
import jp.co.nikkiso.ntss.core.entity.OrdPrescription;
import org.apache.commons.collections4.map.HashedMap;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ResourceLoader;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.BVMSFilterDTO;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.bv.BVGraphDTO;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.ddm.DDMGraphDTO;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.ht.HtGraphDTO;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.rr.RRGraphDTO;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.rr.RRGraphFilterDTO;
import jp.co.nikkiso.ntss.admin_web.response.creatingReport.ReportHtmlResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.bvms.BVGraphService;
import jp.co.nikkiso.ntss.admin_web.service.bvms.BVMSReportChartService;
import jp.co.nikkiso.ntss.admin_web.service.bvms.DDMGraphService;
import jp.co.nikkiso.ntss.admin_web.service.bvms.HtGraphService;
import jp.co.nikkiso.ntss.admin_web.service.bvms.RRGraphService;
import jp.co.nikkiso.ntss.admin_web.service.print.PrinterService;
import jp.co.nikkiso.ntss.api.service.report.ReportChartService.ChartImageType;
import jp.co.nikkiso.ntss.api.service.report.ReportService;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import lombok.NonNull;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;

@RestController
@RequestMapping(Uri.BVMS)
public class BVMSGraphResource {

    @Autowired
    private BVGraphService bvService;

    @Autowired
    private DDMGraphService ddmService;

    @Autowired
    private HtGraphService htService;

    @Autowired
    private RRGraphService rrService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

    /**
     * プリンターService.
     */
    @Autowired
    private PrinterService printerService;

  @Autowired
  private OrdMainDao ordMainDao;

  @Autowired
  private MstInfoService mstInfoService;
  @Autowired
  private MstEquipmentClassDao mstEquipmentClassDao;
  @Autowired
  private MstMedicineClassDao mstMedicineClassDao;
  @Autowired
  private MstDialyzerDao mstDialyzerDao;
  @Autowired
  private OrdPrescriptionDao ordPrescriptionDao;

    @PostMapping("bvGraph/{ordNo}")
    public ResponseEntity<?> getBVGraph(@PathVariable Long ordNo, @Valid @RequestBody BVMSFilterDTO filter) {
      // wp アプリケーションログの適正化 Add Start
      String mappingUrl = Uri.BVMS + "/bvGraph";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
        ordNo);
      // wp アプリケーションログの適正化 Add End
        isOrdNoExsit(ordNo);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        ordNo);
      // wp アプリケーションログの適正化 Add End
        return new ResponseEntity<>(bvService.getGraph(ordNo, filter), HttpStatus.OK);
    }

    @PostMapping("ddmGraph/{ordNo}")
    public ResponseEntity<?> getDDMGraph(@PathVariable Long ordNo, @Valid @RequestBody BVMSFilterDTO filter) {
      // wp アプリケーションログの適正化 Add Start
      String mappingUrl = Uri.BVMS + "/ddmGraph";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
        ordNo);
      // wp アプリケーションログの適正化 Add End

        isOrdNoExsit(ordNo);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        ordNo);
      // wp アプリケーションログの適正化 Add End
        return new ResponseEntity<>(ddmService.getGraph(ordNo, filter), HttpStatus.OK);
    }

    @PostMapping("htGraph/{ordNo}")
    public ResponseEntity<?> getHtGraph(@PathVariable Long ordNo, @Valid @RequestBody BVMSFilterDTO filter) {

      // wp アプリケーションログの適正化 Add Start
      String mappingUrl = Uri.BVMS + "/htGraph";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
        ordNo);
      // wp アプリケーションログの適正化 Add End
        isOrdNoExsit(ordNo);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        ordNo);
      // wp アプリケーションログの適正化 Add End
        return new ResponseEntity<>(htService.getGraph(ordNo, filter), HttpStatus.OK);
    }

    @PostMapping("rrGraph/{ordNo}")
    public ResponseEntity<?> getRRGraph(@PathVariable Long ordNo, @Valid @RequestBody RRGraphFilterDTO filter) {
      // wp アプリケーションログの適正化 Add Start
      String mappingUrl = Uri.BVMS + "/rrGraph";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
        ordNo);
      // wp アプリケーションログの適正化 Add End
        isOrdNoExsit(ordNo);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        ordNo);
      // wp アプリケーションログの適正化 Add End
        return new ResponseEntity<>(rrService.getGraph(ordNo, filter), HttpStatus.OK);
    }

    @Autowired
    private ReportService reportService;

    @Autowired
    private BVMSReportChartService bvmsReportChartService;

    private final Long BVGRAPH_REPORT_CD = 1L;

  @Autowired
  ResourceLoader resourceLoader;

    @PostMapping("bvGraph/creating-report/{ordNo}")
    public ResponseEntity<?> printBVGraphReportHtml(@PathVariable("ordNo") Long ordNo,
            @RequestBody BVMSFilterDTO filter, @AuthenticationPrincipal NtssUser ntssUser) {

      // wp アプリケーションログの適正化 Add Start
      String mappingUrl = Uri.BVMS + "/bvGraph/creating-report";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
        ordNo);
      // wp アプリケーションログの適正化 Add End

        OrdMain ordInfo = getOrdInfo(ordNo);
        Map<String, Object> dataKey = new HashedMap<>();
        BVGraphDTO graph = bvService.getGraph(ordNo, filter);
        List<byte[]> bvmsChartData = bvmsReportChartService.getBVChart(ordNo, ChartImageType.PNG, graph, filter);
        dataKey.put("bvmsChartData", bvmsChartData);
        dataKey.put("ordNo", ordNo);
        dataKey.put("patId", getPatId(ordNo));
        dataKey.put("login", ntssUser.getUsername());
        createdDataKey(dataKey,ordInfo);
        // 帳票作成サービスの呼び出し
        String reportHtml = "";
        byte[] excelResult = reportService.getReportExcelFileForDialysisReport(BVGRAPH_REPORT_CD, dataKey);
        if (!(excelResult == null || excelResult.length == 0)) {
          ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(excelResult);
          URL url = null;
          try {
            url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
            reportHtml += AsposeCellsUtils.excelToSvg(byteArrayInputStream, url);
          } catch (Exception e) {
            throw new RuntimeException(e);
          }
        }
        // PDF格納先パスが指定されている場合は、HTMLをPDFに変換してS3にアップロードし、印刷要求を投げる
        if (!StringUtils.isEmpty(filter.getPdfPath())) {
            reportService.convertHtmlToPdf(reportHtml, filter.getPdfPath());
            printerService.sendPrintRequest(filter.getTargetPrinter(), filter.getPdfPath());
        }

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        ordNo);
      // wp アプリケーションログの適正化 Add End

        // レスポンス生成
        return new ResponseEntity<>(new ReportHtmlResponse(reportHtml, null), HttpStatus.OK);
    }

    @PostMapping("ddmGraph/creating-report/{ordNo}")
    public ResponseEntity<?> printDDMGraphReportHtml(@PathVariable("ordNo") Long ordNo,
            @RequestBody BVMSFilterDTO filter, @AuthenticationPrincipal NtssUser ntssUser) {

      // wp アプリケーションログの適正化 Add Start
      String mappingUrl = Uri.BVMS + "/ddmGraph/creating-report";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
        ordNo);
      // wp アプリケーションログの適正化 Add End

      OrdMain ordInfo = getOrdInfo(ordNo);
      Map<String, Object> dataKey = new HashedMap<>();
      DDMGraphDTO graph = ddmService.getGraph(ordNo, filter);
      List<byte[]> bvmsChartData = bvmsReportChartService.getDDMChart(ordNo, ChartImageType.PNG, graph, filter);
      dataKey.put("bvmsChartData", bvmsChartData);
      dataKey.put("ordNo", ordNo);
      dataKey.put("patId", getPatId(ordNo));
      dataKey.put("login", ntssUser.getUsername());
      createdDataKey(dataKey,ordInfo);
      // 帳票作成サービスの呼び出し
      String reportHtml = "";
      byte[] excelResult = reportService.getReportExcelFileForDialysisReport(BVGRAPH_REPORT_CD, dataKey);
      if (!(excelResult == null || excelResult.length == 0)) {
        ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(excelResult);
        URL url = null;
        try {
          url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
          reportHtml += AsposeCellsUtils.excelToSvg(byteArrayInputStream, url);
        } catch (Exception e) {
          throw new RuntimeException(e);
        }
      }
      // PDF格納先パスが指定されている場合は、HTMLをPDFに変換してS3にアップロードし、印刷要求を投げる
      if (!StringUtils.isEmpty(filter.getPdfPath())) {
        reportService.convertHtmlToPdf(reportHtml, filter.getPdfPath());
        printerService.sendPrintRequest(filter.getTargetPrinter(), filter.getPdfPath());
      }

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        ordNo);
      // wp アプリケーションログの適正化 Add End
      // レスポンス生成
      return new ResponseEntity<>(new ReportHtmlResponse(reportHtml, null), HttpStatus.OK);
    }

    @PostMapping("htGraph/creating-report/{ordNo}")
    public ResponseEntity<?> printHtGraphReportHtml(@PathVariable("ordNo") Long ordNo,
            @RequestBody BVMSFilterDTO filter, @AuthenticationPrincipal NtssUser ntssUser) {

      // wp アプリケーションログの適正化 Add Start
      String mappingUrl = Uri.BVMS + "/htGraph/creating-report";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
        ordNo);
      // wp アプリケーションログの適正化 Add End
      OrdMain ordInfo = getOrdInfo(ordNo);
      Map<String, Object> dataKey = new HashedMap<>();
      HtGraphDTO graph = htService.getGraph(ordNo, filter);
      List<byte[]> bvmsChartData = bvmsReportChartService.getHtChart(ordNo, ChartImageType.PNG, graph, filter);
      dataKey.put("bvmsChartData", bvmsChartData);
      dataKey.put("ordNo", ordNo);
      dataKey.put("patId", getPatId(ordNo));
      dataKey.put("login", ntssUser.getUsername());
      createdDataKey(dataKey,ordInfo);
      // 帳票作成サービスの呼び出し
      String reportHtml = "";
      byte[] excelResult = reportService.getReportExcelFileForDialysisReport(BVGRAPH_REPORT_CD, dataKey);
      if (!(excelResult == null || excelResult.length == 0)) {
        ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(excelResult);
        URL url = null;
        try {
          url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
          reportHtml += AsposeCellsUtils.excelToSvg(byteArrayInputStream, url);
        } catch (Exception e) {
          throw new RuntimeException(e);
        }
      }
      // PDF格納先パスが指定されている場合は、HTMLをPDFに変換してS3にアップロードし、印刷要求を投げる
      if (!StringUtils.isEmpty(filter.getPdfPath())) {
        reportService.convertHtmlToPdf(reportHtml, filter.getPdfPath());
        printerService.sendPrintRequest(filter.getTargetPrinter(), filter.getPdfPath());
      }

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        ordNo);
      // wp アプリケーションログの適正化 Add End
      // レスポンス生成
      return new ResponseEntity<>(new ReportHtmlResponse(reportHtml, null), HttpStatus.OK);
    }
    @PostMapping("rrGraph/creating-report/{ordNo}")
    public ResponseEntity<?> printRRGraphReportHtml(@PathVariable("ordNo") Long ordNo,
            @RequestBody RRGraphFilterDTO filter, @AuthenticationPrincipal NtssUser ntssUser) {

      // wp アプリケーションログの適正化 Add Start
      String mappingUrl = Uri.BVMS + "/rrGraph/creating-report";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
        ordNo);
      // wp アプリケーションログの適正化 Add End
      OrdMain ordInfo = getOrdInfo(ordNo);
      Map<String, Object> dataKey = new HashedMap<>();
      RRGraphDTO graph = rrService.getGraph(ordNo, filter);
      List<byte[]> bvmsChartData = bvmsReportChartService.getRRChart(ordNo, ChartImageType.PNG, graph, filter);
      dataKey.put("bvmsChartData", bvmsChartData);
      dataKey.put("ordNo", ordNo);
      dataKey.put("patId", getPatId(ordNo));
      dataKey.put("login", ntssUser.getUsername());
      createdDataKey(dataKey,ordInfo);
      // 帳票作成サービスの呼び出し
      String reportHtml = "";
      byte[] excelResult = reportService.getReportExcelFileForDialysisReport(BVGRAPH_REPORT_CD, dataKey);
      if (!(excelResult == null || excelResult.length == 0)) {
        ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(excelResult);
        URL url = null;
        try {
          url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
          reportHtml += AsposeCellsUtils.excelToSvg(byteArrayInputStream, url);
        } catch (Exception e) {
          throw new RuntimeException(e);
        }
      }
      // PDF格納先パスが指定されている場合は、HTMLをPDFに変換してS3にアップロードし、印刷要求を投げる
      if (!StringUtils.isEmpty(filter.getPdfPath())) {
        reportService.convertHtmlToPdf(reportHtml, filter.getPdfPath());
        printerService.sendPrintRequest(filter.getTargetPrinter(), filter.getPdfPath());
      }

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        ordNo);
      // wp アプリケーションログの適正化 Add End
      // レスポンス生成
      return new ResponseEntity<>(new ReportHtmlResponse(reportHtml, null), HttpStatus.OK);
    }
    @PostMapping("bvGraph/preview-report/{ordNo}")
    public ResponseEntity<?> previewBVGraphReportHtml(@PathVariable("ordNo") Long ordNo,
            @RequestBody BVMSFilterDTO filter, @AuthenticationPrincipal NtssUser ntssUser) {

      // wp アプリケーションログの適正化 Add Start
      String mappingUrl = Uri.BVMS + "/bvGraph/preview-report";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
        ordNo);
      // wp アプリケーションログの適正化 Add End
      OrdMain ordInfo = getOrdInfo(ordNo);
      Map<String, Object> dataKey = new HashedMap<>();
      BVGraphDTO graph = bvService.getGraph(ordNo, filter);
      List<byte[]> bvmsChartData = bvmsReportChartService.getBVChart(ordNo, ChartImageType.PNG, graph, filter);
      dataKey.put("bvmsChartData", bvmsChartData);
      dataKey.put("ordNo", ordNo);
      dataKey.put("patId", getPatId(ordNo));
      dataKey.put("login", ntssUser.getUsername());
      createdDataKey(dataKey,ordInfo);
      // 帳票作成サービスの呼び出し
      String reportHtml = "";
      byte[] excelResult = reportService.getReportExcelFileForDialysisReport(BVGRAPH_REPORT_CD, dataKey);
      if (!(excelResult == null || excelResult.length == 0)) {
        ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(excelResult);
        URL url = null;
        try {
          url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
          reportHtml += AsposeCellsUtils.excelToSvg(byteArrayInputStream, url);
        } catch (Exception e) {
          throw new RuntimeException(e);
        }
      }
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        ordNo);
      // wp アプリケーションログの適正化 Add End
      // レスポンス生成
      return new ResponseEntity<>(new ReportHtmlResponse(reportHtml, null), HttpStatus.OK);
    }
    @PostMapping("ddmGraph/preview-report/{ordNo}")
    public ResponseEntity<?> previewDDMGraphReportHtml(@PathVariable("ordNo") Long ordNo,
            @RequestBody BVMSFilterDTO filter, @AuthenticationPrincipal NtssUser ntssUser) {
      // wp アプリケーションログの適正化 Add Start
      String mappingUrl = Uri.BVMS + "/ddmGraph/preview-report";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
        ordNo);
      // wp アプリケーションログの適正化 Add End

      OrdMain ordInfo = getOrdInfo(ordNo);
      Map<String, Object> dataKey = new HashedMap<>();
      DDMGraphDTO graph = ddmService.getGraph(ordNo, filter);
      List<byte[]> bvmsChartData = bvmsReportChartService.getDDMChart(ordNo, ChartImageType.PNG, graph, filter);
      dataKey.put("bvmsChartData", bvmsChartData);
      dataKey.put("ordNo", ordNo);
      dataKey.put("patId", getPatId(ordNo));
      dataKey.put("login", ntssUser.getUsername());
      createdDataKey(dataKey,ordInfo);
      // 帳票作成サービスの呼び出し
      String reportHtml = "";
      byte[] excelResult = reportService.getReportExcelFileForDialysisReport(BVGRAPH_REPORT_CD, dataKey);
      if (!(excelResult == null || excelResult.length == 0)) {
        ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(excelResult);
        URL url = null;
        try {
          url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
          reportHtml += AsposeCellsUtils.excelToSvg(byteArrayInputStream, url);
        } catch (Exception e) {
          throw new RuntimeException(e);
        }
      }
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        ordNo);
      // wp アプリケーションログの適正化 Add End

      // レスポンス生成
      return new ResponseEntity<>(new ReportHtmlResponse(reportHtml, null), HttpStatus.OK);
    }
    @PostMapping("htGraph/preview-report/{ordNo}")
    public ResponseEntity<?> previewHtGraphReportHtml(@PathVariable("ordNo") Long ordNo,
            @RequestBody BVMSFilterDTO filter, @AuthenticationPrincipal NtssUser ntssUser) {
      // wp アプリケーションログの適正化 Add Start
      String mappingUrl = Uri.BVMS + "/htGraph/preview-report";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
        ordNo);
      // wp アプリケーションログの適正化 Add End

      OrdMain ordInfo = getOrdInfo(ordNo);
      Map<String, Object> dataKey = new HashedMap<>();
      HtGraphDTO graph = htService.getGraph(ordNo, filter);
      List<byte[]> bvmsChartData = bvmsReportChartService.getHtChart(ordNo, ChartImageType.PNG, graph, filter);
      dataKey.put("bvmsChartData", bvmsChartData);
      dataKey.put("ordNo", ordNo);
      dataKey.put("patId", getPatId(ordNo));
      dataKey.put("login", ntssUser.getUsername());
      createdDataKey(dataKey,ordInfo);
      // 帳票作成サービスの呼び出し
      String reportHtml = "";
      byte[] excelResult = reportService.getReportExcelFileForDialysisReport(BVGRAPH_REPORT_CD, dataKey);
      if (!(excelResult == null || excelResult.length == 0)) {
        ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(excelResult);
        URL url = null;
        try {
          url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
          reportHtml += AsposeCellsUtils.excelToSvg(byteArrayInputStream, url);
        } catch (Exception e) {
          throw new RuntimeException(e);
        }
      }
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        ordNo);
      // wp アプリケーションログの適正化 Add End

      // レスポンス生成
      return new ResponseEntity<>(new ReportHtmlResponse(reportHtml, null), HttpStatus.OK);
    }
    @PostMapping("rrGraph/preview-report/{ordNo}")
    public ResponseEntity<?> previewRRGraphReportHtml(@PathVariable("ordNo") Long ordNo,
            @RequestBody RRGraphFilterDTO filter, @AuthenticationPrincipal NtssUser ntssUser) {
      // wp アプリケーションログの適正化 Add Start
      String mappingUrl = Uri.BVMS + "/rrGraph/preview-report";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
        ordNo);
      // wp アプリケーションログの適正化 Add End

      OrdMain ordInfo = getOrdInfo(ordNo);
      Map<String, Object> dataKey = new HashedMap<>();
      RRGraphDTO graph = rrService.getGraph(ordNo, filter);
      List<byte[]> bvmsChartData = bvmsReportChartService.getRRChart(ordNo, ChartImageType.PNG, graph, filter);
      dataKey.put("bvmsChartData", bvmsChartData);
      dataKey.put("ordNo", ordNo);
      dataKey.put("patId", getPatId(ordNo));
      dataKey.put("login", ntssUser.getUsername());
      createdDataKey(dataKey,ordInfo);
      // 帳票作成サービスの呼び出し
      String reportHtml = "";
      byte[] excelResult = reportService.getReportExcelFileForDialysisReport(BVGRAPH_REPORT_CD, dataKey);
      if (!(excelResult == null || excelResult.length == 0)) {
        ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(excelResult);
        URL url = null;
        try {
          url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
          reportHtml += AsposeCellsUtils.excelToSvg(byteArrayInputStream, url);
        } catch (Exception e) {
          throw new RuntimeException(e);
        }
      }
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        ordNo);
      // wp アプリケーションログの適正化 Add End

      // レスポンス生成
      return new ResponseEntity<>(new ReportHtmlResponse(reportHtml, null), HttpStatus.OK);
    }

    @PostMapping("bvGraph/byUploadFile/{ordNo}")
    public ResponseEntity<?> getBVGraph(@PathVariable("ordNo") Long ordNo, //
            @RequestParam("files") MultipartFile file, //
            @RequestParam("graph1Y1From") BigDecimal graph1Y1From, @RequestParam("graph1Y1To") BigDecimal graph1Y1To,
            @RequestParam("graph1Y2From") BigDecimal graph1Y2From, @RequestParam("graph1Y2To") BigDecimal graph1Y2To,
            @RequestParam("graph2Y1From") BigDecimal graph2Y1From, @RequestParam("graph2Y1To") BigDecimal graph2Y1To,
            @RequestParam("graph2Y2From") BigDecimal graph2Y2From, @RequestParam("graph2Y2To") BigDecimal graph2Y2To) {

      // wp アプリケーションログの適正化 Add Start
      String mappingUrl = Uri.BVMS + "/bvGraph/byUploadFile";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(ordNo, file, graph1Y1From, graph1Y1To, graph1Y2From, graph1Y2To, graph2Y1From, graph2Y1To, graph2Y2From, graph2Y2To));
      // wp アプリケーションログの適正化 Add End

      BVMSFilterDTO filter = getBVMSFilterDTO(graph1Y1From, graph1Y1To, graph1Y2From, graph1Y2To, graph2Y1From,
        graph2Y1To, graph2Y2From, graph2Y2To, null, null);
      isOrdNoExsit(ordNo);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(ordNo, file, graph1Y1From, graph1Y1To, graph1Y2From, graph1Y2To, graph2Y1From, graph2Y1To, graph2Y2From, graph2Y2To));
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(bvService.getGraphByUploadFile(ordNo, file, filter), HttpStatus.OK);
    }
    @PostMapping("ddmGraph/byUploadFile/{ordNo}")
    public ResponseEntity<?> getDDMGraph(@PathVariable Long ordNo, @RequestParam("files") MultipartFile file,
            @RequestParam("graph1Y1From") BigDecimal graph1Y1From, @RequestParam("graph1Y1To") BigDecimal graph1Y1To,
            @RequestParam("graph1Y2From") BigDecimal graph1Y2From, @RequestParam("graph1Y2To") BigDecimal graph1Y2To,
            @RequestParam("graph2Y1From") BigDecimal graph2Y1From, @RequestParam("graph2Y1To") BigDecimal graph2Y1To,
            @RequestParam("graph2Y2From") BigDecimal graph2Y2From, @RequestParam("graph2Y2To") BigDecimal graph2Y2To) {
      // wp アプリケーションログの適正化 Add Start
      String mappingUrl = Uri.BVMS + "/ddmGraph/byUploadFile";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(ordNo, file, graph1Y1From, graph1Y1To, graph1Y2From, graph1Y2To, graph2Y1From, graph2Y1To, graph2Y2From, graph2Y2To));
      // wp アプリケーションログの適正化 Add End

        BVMSFilterDTO filter = getBVMSFilterDTO(graph1Y1From, graph1Y1To, graph1Y2From, graph1Y2To, graph2Y1From,
                graph2Y1To, graph2Y2From, graph2Y2To, null, null);
        isOrdNoExsit(ordNo);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(ordNo, file, graph1Y1From, graph1Y1To, graph1Y2From, graph1Y2To, graph2Y1From, graph2Y1To, graph2Y2From, graph2Y2To));
      // wp アプリケーションログの適正化 Add End

        return new ResponseEntity<>(ddmService.getGraphByUploadFile(ordNo, file, filter), HttpStatus.OK);
    }
    @PostMapping("htGraph/byUploadFile/{ordNo}")
    public ResponseEntity<?> getHtGraph(@PathVariable Long ordNo, @RequestParam("files") MultipartFile file,
            @RequestParam("graph1Y1From") BigDecimal graph1Y1From, @RequestParam("graph1Y1To") BigDecimal graph1Y1To,
            @RequestParam("graph1Y2From") BigDecimal graph1Y2From, @RequestParam("graph1Y2To") BigDecimal graph1Y2To,
            @RequestParam("graph2Y1From") BigDecimal graph2Y1From, @RequestParam("graph2Y1To") BigDecimal graph2Y1To,
            @RequestParam("graph2Y2From") BigDecimal graph2Y2From, @RequestParam("graph2Y2To") BigDecimal graph2Y2To) {
      // wp アプリケーションログの適正化 Add Start
      String mappingUrl = Uri.BVMS + "/htGraph/byUploadFile";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(ordNo, file, graph1Y1From, graph1Y1To, graph1Y2From, graph1Y2To, graph2Y1From, graph2Y1To, graph2Y2From, graph2Y2To));
      // wp アプリケーションログの適正化 Add End

      BVMSFilterDTO filter = getBVMSFilterDTO(graph1Y1From, graph1Y1To, graph1Y2From, graph1Y2To, graph2Y1From,
        graph2Y1To, graph2Y2From, graph2Y2To, null, null);
      isOrdNoExsit(ordNo);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(ordNo, file, graph1Y1From, graph1Y1To, graph1Y2From, graph1Y2To, graph2Y1From, graph2Y1To, graph2Y2From, graph2Y2To));
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(htService.getGraphByUploadFile(ordNo, file, filter), HttpStatus.OK);
    }
    @PostMapping("rrGraph/byUploadFile/{ordNo}")
    public ResponseEntity<?> getRRGraph(@PathVariable Long ordNo, @RequestParam("files") MultipartFile file,
            @RequestParam("graphY1From") BigDecimal graphY1From, @RequestParam("graphY1To") BigDecimal graphY1To) {
      // wp アプリケーションログの適正化 Add Start
      String mappingUrl = Uri.BVMS + "/rrGraph/byUploadFile";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(ordNo, file, graphY1From, graphY1To));
      // wp アプリケーションログの適正化 Add End

      RRGraphFilterDTO filter = getRRGraphFilterDTO(graphY1From, graphY1To, null, null);
      isOrdNoExsit(ordNo);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(ordNo, file, graphY1From, graphY1To));
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(rrService.getGraphByUploadFile(ordNo, file, filter), HttpStatus.OK);
    }

    @PostMapping("bvGraph/creating-report/byUploadFile/{ordNo}")
    public ResponseEntity<?> printBVGraphReportHtml(@PathVariable("ordNo") Long ordNo,
            @RequestParam("files") MultipartFile file, @RequestParam("graph1Y1From") BigDecimal graph1Y1From,
            @RequestParam("graph1Y1To") BigDecimal graph1Y1To, @RequestParam("graph1Y2From") BigDecimal graph1Y2From,
            @RequestParam("graph1Y2To") BigDecimal graph1Y2To, @RequestParam("graph2Y1From") BigDecimal graph2Y1From,
            @RequestParam("graph2Y1To") BigDecimal graph2Y1To, @RequestParam("graph2Y2From") BigDecimal graph2Y2From,
            @RequestParam("graph2Y2To") BigDecimal graph2Y2To, @RequestParam("targetPrinter") Long targetPrinter,
            @RequestParam("pdfPath") String pdfPath, @AuthenticationPrincipal NtssUser ntssUser) {
      // wp アプリケーションログの適正化 Add Start
      String mappingUrl = Uri.BVMS + "/bvGraph/creating-report/byUploadFile";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(ordNo, file, graph1Y1From, graph1Y1To, graph1Y2From, graph1Y2To, graph2Y1From, graph2Y1To, graph2Y2From, graph2Y2To, targetPrinter, pdfPath, ntssUser));
      // wp アプリケーションログの適正化 Add End

      OrdMain ordInfo = getOrdInfo(ordNo);
      Map<String, Object> dataKey = new HashedMap<>();
      BVMSFilterDTO filter = getBVMSFilterDTO(graph1Y1From, graph1Y1To, graph1Y2From, graph1Y2To, graph2Y1From,
        graph2Y1To, graph2Y2From, graph2Y2To, targetPrinter, pdfPath);
      BVGraphDTO graph = bvService.getGraphByUploadFile(ordNo, file, filter);
      List<byte[]> bvmsChartData = bvmsReportChartService.getBVChart(ordNo, ChartImageType.PNG, graph, filter);
      dataKey.put("bvmsChartData", bvmsChartData);
      dataKey.put("ordNo", ordNo);
      dataKey.put("patId", getPatId(ordNo));
      dataKey.put("login", ntssUser.getUsername());
      createdDataKey(dataKey,ordInfo);
      // 帳票作成サービスの呼び出し
      String reportHtml = "";
      byte[] excelResult = reportService.getReportExcelFileForDialysisReport(BVGRAPH_REPORT_CD, dataKey);
      if (!(excelResult == null || excelResult.length == 0)) {
        ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(excelResult);
        URL url = null;
        try {
          url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
          reportHtml += AsposeCellsUtils.excelToSvg(byteArrayInputStream, url);
        } catch (Exception e) {
          throw new RuntimeException(e);
        }
      }
      // PDF格納先パスが指定されている場合は、HTMLをPDFに変換してS3にアップロードし、印刷要求を投げる
      if (!StringUtils.isEmpty(filter.getPdfPath())) {
        reportService.convertHtmlToPdf(reportHtml, filter.getPdfPath());
        printerService.sendPrintRequest(filter.getTargetPrinter(), filter.getPdfPath());
      }

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(ordNo, file, graph1Y1From, graph1Y1To, graph1Y2From, graph1Y2To, graph2Y1From, graph2Y1To, graph2Y2From, graph2Y2To, targetPrinter, pdfPath, ntssUser));
      // wp アプリケーションログの適正化 Add End

      // レスポンス生成
      return new ResponseEntity<>(new ReportHtmlResponse(reportHtml, null), HttpStatus.OK);
    }
    @PostMapping("ddmGraph/creating-report/byUploadFile/{ordNo}")
    public ResponseEntity<?> printDDMGraphReportHtml(@PathVariable("ordNo") Long ordNo,
            @RequestParam("files") MultipartFile file, @RequestParam("graph1Y1From") BigDecimal graph1Y1From,
            @RequestParam("graph1Y1To") BigDecimal graph1Y1To, @RequestParam("graph1Y2From") BigDecimal graph1Y2From,
            @RequestParam("graph1Y2To") BigDecimal graph1Y2To, @RequestParam("graph2Y1From") BigDecimal graph2Y1From,
            @RequestParam("graph2Y1To") BigDecimal graph2Y1To, @RequestParam("graph2Y2From") BigDecimal graph2Y2From,
            @RequestParam("graph2Y2To") BigDecimal graph2Y2To, @RequestParam("targetPrinter") Long targetPrinter,
            @RequestParam("pdfPath") String pdfPath, @AuthenticationPrincipal NtssUser ntssUser) {

      // wp アプリケーションログの適正化 Add Start
      String mappingUrl = Uri.BVMS + "/ddmGraph/creating-report/byUploadFile";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(ordNo, file, graph1Y1From, graph1Y1To, graph1Y2From, graph1Y2To, graph2Y1From, graph2Y1To, graph2Y2From, graph2Y2To, targetPrinter, pdfPath, ntssUser));
      // wp アプリケーションログの適正化 Add End

      OrdMain ordInfo = getOrdInfo(ordNo);
      Map<String, Object> dataKey = new HashedMap<>();
      BVMSFilterDTO filter = getBVMSFilterDTO(graph1Y1From, graph1Y1To, graph1Y2From, graph1Y2To, graph2Y1From,
        graph2Y1To, graph2Y2From, graph2Y2To, targetPrinter, pdfPath);
      DDMGraphDTO graph = ddmService.getGraphByUploadFile(ordNo, file, filter);
      List<byte[]> bvmsChartData = bvmsReportChartService.getDDMChart(ordNo, ChartImageType.PNG, graph, filter);
      dataKey.put("bvmsChartData", bvmsChartData);
      dataKey.put("ordNo", ordNo);
      dataKey.put("patId", getPatId(ordNo));
      dataKey.put("login", ntssUser.getUsername());
      createdDataKey(dataKey,ordInfo);
      // 帳票作成サービスの呼び出し
      String reportHtml = "";
      byte[] excelResult = reportService.getReportExcelFileForDialysisReport(BVGRAPH_REPORT_CD, dataKey);
      if (!(excelResult == null || excelResult.length == 0)) {
        ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(excelResult);
        URL url = null;
        try {
          url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
          reportHtml += AsposeCellsUtils.excelToSvg(byteArrayInputStream, url);
        } catch (Exception e) {
          throw new RuntimeException(e);
        }
      }
      // PDF格納先パスが指定されている場合は、HTMLをPDFに変換してS3にアップロードし、印刷要求を投げる
      if (!StringUtils.isEmpty(filter.getPdfPath())) {
        reportService.convertHtmlToPdf(reportHtml, filter.getPdfPath());
        printerService.sendPrintRequest(filter.getTargetPrinter(), filter.getPdfPath());
      }

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(ordNo, file, graph1Y1From, graph1Y1To, graph1Y2From, graph1Y2To, graph2Y1From, graph2Y1To, graph2Y2From, graph2Y2To, targetPrinter, pdfPath, ntssUser));
      // wp アプリケーションログの適正化 Add End
      // レスポンス生成
      return new ResponseEntity<>(new ReportHtmlResponse(reportHtml, null), HttpStatus.OK);
    }
    @PostMapping("htGraph/creating-report/byUploadFile/{ordNo}")
    public ResponseEntity<?> printHtGraphReportHtml(@PathVariable("ordNo") Long ordNo,
            @RequestParam("files") MultipartFile file, @RequestParam("graph1Y1From") BigDecimal graph1Y1From,
            @RequestParam("graph1Y1To") BigDecimal graph1Y1To, @RequestParam("graph1Y2From") BigDecimal graph1Y2From,
            @RequestParam("graph1Y2To") BigDecimal graph1Y2To, @RequestParam("graph2Y1From") BigDecimal graph2Y1From,
            @RequestParam("graph2Y1To") BigDecimal graph2Y1To, @RequestParam("graph2Y2From") BigDecimal graph2Y2From,
            @RequestParam("graph2Y2To") BigDecimal graph2Y2To, @RequestParam("targetPrinter") Long targetPrinter,
            @RequestParam("pdfPath") String pdfPath, @AuthenticationPrincipal NtssUser ntssUser) {

      // wp アプリケーションログの適正化 Add Start
      String mappingUrl = Uri.BVMS + "/htGraph/creating-report/byUploadFile";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(ordNo, file, graph1Y1From, graph1Y1To, graph1Y2From, graph1Y2To, graph2Y1From, graph2Y1To, graph2Y2From, graph2Y2To, targetPrinter, pdfPath, ntssUser));
      // wp アプリケーションログの適正化 Add End

      OrdMain ordInfo = getOrdInfo(ordNo);
      Map<String, Object> dataKey = new HashedMap<>();
      BVMSFilterDTO filter = getBVMSFilterDTO(graph1Y1From, graph1Y1To, graph1Y2From, graph1Y2To, graph2Y1From,
        graph2Y1To, graph2Y2From, graph2Y2To, targetPrinter, pdfPath);
      HtGraphDTO graph = htService.getGraphByUploadFile(ordNo, file, filter);
      List<byte[]> bvmsChartData = bvmsReportChartService.getHtChart(ordNo, ChartImageType.PNG, graph, filter);
      dataKey.put("bvmsChartData", bvmsChartData);
      dataKey.put("ordNo", ordNo);
      dataKey.put("patId", getPatId(ordNo));
      dataKey.put("login", ntssUser.getUsername());
      createdDataKey(dataKey,ordInfo);
      // 帳票作成サービスの呼び出し
      String reportHtml = "";
      byte[] excelResult = reportService.getReportExcelFileForDialysisReport(BVGRAPH_REPORT_CD, dataKey);
      if (!(excelResult == null || excelResult.length == 0)) {
        ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(excelResult);
        URL url = null;
        try {
          url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
          reportHtml += AsposeCellsUtils.excelToSvg(byteArrayInputStream, url);
        } catch (Exception e) {
          throw new RuntimeException(e);
        }
      }
      // PDF格納先パスが指定されている場合は、HTMLをPDFに変換してS3にアップロードし、印刷要求を投げる
      if (!StringUtils.isEmpty(filter.getPdfPath())) {
        reportService.convertHtmlToPdf(reportHtml, filter.getPdfPath());
        printerService.sendPrintRequest(filter.getTargetPrinter(), filter.getPdfPath());
      }

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(ordNo, file, graph1Y1From, graph1Y1To, graph1Y2From, graph1Y2To, graph2Y1From, graph2Y1To, graph2Y2From, graph2Y2To, targetPrinter, pdfPath, ntssUser));
      // wp アプリケーションログの適正化 Add End
      // レスポンス生成
      return new ResponseEntity<>(new ReportHtmlResponse(reportHtml, null), HttpStatus.OK);
    }
    @PostMapping("rrGraph/creating-report/byUploadFile/{ordNo}")
    public ResponseEntity<?> printRRGraphReportHtml(@PathVariable("ordNo") Long ordNo,
            @RequestParam("files") MultipartFile file, @RequestParam("graphY1From") BigDecimal graphY1From,
            @RequestParam("graphY1To") BigDecimal graphY1To, @RequestParam("targetPrinter") Long targetPrinter,
            @RequestParam("pdfPath") String pdfPath, @AuthenticationPrincipal NtssUser ntssUser) {

      // wp アプリケーションログの適正化 Add Start
      String mappingUrl = Uri.BVMS + "/rrGraph/creating-report/byUploadFile";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(ordNo, file, graphY1From, graphY1To, targetPrinter, pdfPath, ntssUser));
      // wp アプリケーションログの適正化 Add End
      OrdMain ordInfo = getOrdInfo(ordNo);
      Map<String, Object> dataKey = new HashedMap<>();
      RRGraphFilterDTO filter = getRRGraphFilterDTO(graphY1From, graphY1To, targetPrinter, pdfPath);
      RRGraphDTO graph = rrService.getGraphByUploadFile(ordNo, file, filter);
      List<byte[]> bvmsChartData = bvmsReportChartService.getRRChart(ordNo, ChartImageType.PNG, graph, filter);
      dataKey.put("bvmsChartData", bvmsChartData);
      dataKey.put("ordNo", ordNo);
      dataKey.put("patId", getPatId(ordNo));
      dataKey.put("login", ntssUser.getUsername());
      createdDataKey(dataKey,ordInfo);
      // 帳票作成サービスの呼び出し
      String reportHtml = "";
      byte[] excelResult = reportService.getReportExcelFileForDialysisReport(BVGRAPH_REPORT_CD, dataKey);
      if (!(excelResult == null || excelResult.length == 0)) {
        ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(excelResult);
        URL url = null;
        try {
          url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
          reportHtml += AsposeCellsUtils.excelToSvg(byteArrayInputStream, url);
        } catch (Exception e) {
          throw new RuntimeException(e);
        }
      }
      // PDF格納先パスが指定されている場合は、HTMLをPDFに変換してS3にアップロードし、印刷要求を投げる
      if (!StringUtils.isEmpty(filter.getPdfPath())) {
        reportService.convertHtmlToPdf(reportHtml, filter.getPdfPath());
        printerService.sendPrintRequest(filter.getTargetPrinter(), filter.getPdfPath());
      }

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(ordNo, file, graphY1From, graphY1To, targetPrinter, pdfPath, ntssUser));
      // wp アプリケーションログの適正化 Add End
      // レスポンス生成
      return new ResponseEntity<>(new ReportHtmlResponse(reportHtml, null), HttpStatus.OK);
    }

    @PostMapping("bvGraph/preview-report/byUploadFile/{ordNo}")
    public ResponseEntity<?> previewBVGraphReportHtml(@PathVariable("ordNo") Long ordNo,
            @RequestParam("files") MultipartFile file, @RequestParam("graph1Y1From") BigDecimal graph1Y1From,
            @RequestParam("graph1Y1To") BigDecimal graph1Y1To, @RequestParam("graph1Y2From") BigDecimal graph1Y2From,
            @RequestParam("graph1Y2To") BigDecimal graph1Y2To, @RequestParam("graph2Y1From") BigDecimal graph2Y1From,
            @RequestParam("graph2Y1To") BigDecimal graph2Y1To, @RequestParam("graph2Y2From") BigDecimal graph2Y2From,
            @RequestParam("graph2Y2To") BigDecimal graph2Y2To, @AuthenticationPrincipal NtssUser ntssUser) {
      // wp アプリケーションログの適正化 Add Start
      String mappingUrl = Uri.BVMS + "/bvGraph/preview-report/byUploadFile";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(ordNo, file, graph1Y1From, graph1Y1To, graph1Y2From, graph1Y2To, graph2Y1From, graph2Y1To, graph2Y2From, graph2Y2To, ntssUser));
      // wp アプリケーションログの適正化 Add End

      OrdMain ordInfo = getOrdInfo(ordNo);
      Map<String, Object> dataKey = new HashedMap<>();
      BVMSFilterDTO filter = getBVMSFilterDTO(graph1Y1From, graph1Y1To, graph1Y2From, graph1Y2To, graph2Y1From,
        graph2Y1To, graph2Y2From, graph2Y2To, null, null);
      BVGraphDTO graph = bvService.getGraphByUploadFile(ordNo, file, filter);
      List<byte[]> bvmsChartData = bvmsReportChartService.getBVChart(ordNo, ChartImageType.PNG, graph, filter);
      dataKey.put("bvmsChartData", bvmsChartData);
      dataKey.put("ordNo", ordNo);
      dataKey.put("patId", getPatId(ordNo));
      dataKey.put("login", ntssUser.getUsername());
      createdDataKey(dataKey,ordInfo);
      // 帳票作成サービスの呼び出し
      String reportHtml = "";
      byte[] excelResult = reportService.getReportExcelFileForDialysisReport(BVGRAPH_REPORT_CD, dataKey);
      if (!(excelResult == null || excelResult.length == 0)) {
        ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(excelResult);
        URL url = null;
        try {
          url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
          reportHtml += AsposeCellsUtils.excelToSvg(byteArrayInputStream, url);
        } catch (Exception e) {
          throw new RuntimeException(e);
        }
      }
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(ordNo, file, graph1Y1From, graph1Y1To, graph1Y2From, graph1Y2To, graph2Y1From, graph2Y1To, graph2Y2From, graph2Y2To, ntssUser));
      // wp アプリケーションログの適正化 Add End

      // レスポンス生成
      return new ResponseEntity<>(new ReportHtmlResponse(reportHtml, null), HttpStatus.OK);
    }
    @PostMapping("ddmGraph/preview-report/byUploadFile/{ordNo}")
    public ResponseEntity<?> previewDDMGraphReportHtml(@PathVariable("ordNo") Long ordNo,
            @RequestParam("files") MultipartFile file, @RequestParam("graph1Y1From") BigDecimal graph1Y1From,
            @RequestParam("graph1Y1To") BigDecimal graph1Y1To, @RequestParam("graph1Y2From") BigDecimal graph1Y2From,
            @RequestParam("graph1Y2To") BigDecimal graph1Y2To, @RequestParam("graph2Y1From") BigDecimal graph2Y1From,
            @RequestParam("graph2Y1To") BigDecimal graph2Y1To, @RequestParam("graph2Y2From") BigDecimal graph2Y2From,
            @RequestParam("graph2Y2To") BigDecimal graph2Y2To, @AuthenticationPrincipal NtssUser ntssUser) {

      // wp アプリケーションログの適正化 Add Start
      String mappingUrl = Uri.BVMS + "/ddmGraph/preview-report/byUploadFile";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(ordNo, file, graph1Y1From, graph1Y1To, graph1Y2From, graph1Y2To, graph2Y1From, graph2Y1To, graph2Y2From, graph2Y2To, ntssUser));
      // wp アプリケーションログの適正化 Add End

      OrdMain ordInfo = getOrdInfo(ordNo);
      Map<String, Object> dataKey = new HashedMap<>();
      BVMSFilterDTO filter = getBVMSFilterDTO(graph1Y1From, graph1Y1To, graph1Y2From, graph1Y2To, graph2Y1From,
        graph2Y1To, graph2Y2From, graph2Y2To, null, null);
      DDMGraphDTO graph = ddmService.getGraphByUploadFile(ordNo, file, filter);
      List<byte[]> bvmsChartData = bvmsReportChartService.getDDMChart(ordNo, ChartImageType.PNG, graph, filter);
      dataKey.put("bvmsChartData", bvmsChartData);
      dataKey.put("ordNo", ordNo);
      dataKey.put("patId", getPatId(ordNo));
      dataKey.put("login", ntssUser.getUsername());
      createdDataKey(dataKey,ordInfo);
      // 帳票作成サービスの呼び出し
      String reportHtml = "";
      byte[] excelResult = reportService.getReportExcelFileForDialysisReport(BVGRAPH_REPORT_CD, dataKey);
      if (!(excelResult == null || excelResult.length == 0)) {
        ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(excelResult);
        URL url = null;
        try {
          url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
          reportHtml += AsposeCellsUtils.excelToSvg(byteArrayInputStream, url);
        } catch (Exception e) {
          throw new RuntimeException(e);
        }
      }
      // PDF格納先パスが指定されている場合は、HTMLをPDFに変換してS3にアップロードし、印刷要求を投げる
      if (!StringUtils.isEmpty(filter.getPdfPath())) {
        reportService.convertHtmlToPdf(reportHtml, filter.getPdfPath());
        printerService.sendPrintRequest(filter.getTargetPrinter(), filter.getPdfPath());
      }

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(ordNo, file, graph1Y1From, graph1Y1To, graph1Y2From, graph1Y2To, graph2Y1From, graph2Y1To, graph2Y2From, graph2Y2To, ntssUser));
      // wp アプリケーションログの適正化 Add End
      // レスポンス生成
      return new ResponseEntity<>(new ReportHtmlResponse(reportHtml, null), HttpStatus.OK);
    }

    @PostMapping("htGraph/preview-report/byUploadFile/{ordNo}")
    public ResponseEntity<?> previewHtGraphReportHtml(@PathVariable("ordNo") Long ordNo,
            @RequestParam("files") MultipartFile file, @RequestParam("graph1Y1From") BigDecimal graph1Y1From,
            @RequestParam("graph1Y1To") BigDecimal graph1Y1To, @RequestParam("graph1Y2From") BigDecimal graph1Y2From,
            @RequestParam("graph1Y2To") BigDecimal graph1Y2To, @RequestParam("graph2Y1From") BigDecimal graph2Y1From,
            @RequestParam("graph2Y1To") BigDecimal graph2Y1To, @RequestParam("graph2Y2From") BigDecimal graph2Y2From,
            @RequestParam("graph2Y2To") BigDecimal graph2Y2To, @AuthenticationPrincipal NtssUser ntssUser) {

      // wp アプリケーションログの適正化 Add Start
      String mappingUrl = Uri.BVMS + "/htGraph/preview-report/byUploadFile";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(ordNo, file, graph1Y1From, graph1Y1To, graph1Y2From, graph1Y2To, graph2Y1From, graph2Y1To, graph2Y2From, graph2Y2To, ntssUser));
      // wp アプリケーションログの適正化 Add End

      OrdMain ordInfo = getOrdInfo(ordNo);
      Map<String, Object> dataKey = new HashedMap<>();
      BVMSFilterDTO filter = getBVMSFilterDTO(graph1Y1From, graph1Y1To, graph1Y2From, graph1Y2To, graph2Y1From,
        graph2Y1To, graph2Y2From, graph2Y2To, null, null);
      HtGraphDTO graph = htService.getGraphByUploadFile(ordNo, file, filter);
      List<byte[]> bvmsChartData = bvmsReportChartService.getHtChart(ordNo, ChartImageType.PNG, graph, filter);
      dataKey.put("bvmsChartData", bvmsChartData);
      dataKey.put("ordNo", ordNo);
      dataKey.put("patId", getPatId(ordNo));
      dataKey.put("login", ntssUser.getUsername());
      createdDataKey(dataKey,ordInfo);
      // 帳票作成サービスの呼び出し
      String reportHtml = "";
      byte[] excelResult = reportService.getReportExcelFileForDialysisReport(BVGRAPH_REPORT_CD, dataKey);
      if (!(excelResult == null || excelResult.length == 0)) {
        ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(excelResult);
        URL url = null;
        try {
          url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
          reportHtml += AsposeCellsUtils.excelToSvg(byteArrayInputStream, url);
        } catch (Exception e) {
          throw new RuntimeException(e);
        }
      }
      // PDF格納先パスが指定されている場合は、HTMLをPDFに変換してS3にアップロードし、印刷要求を投げる
      if (!StringUtils.isEmpty(filter.getPdfPath())) {
        reportService.convertHtmlToPdf(reportHtml, filter.getPdfPath());
        printerService.sendPrintRequest(filter.getTargetPrinter(), filter.getPdfPath());
      }

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(ordNo, file, graph1Y1From, graph1Y1To, graph1Y2From, graph1Y2To, graph2Y1From, graph2Y1To, graph2Y2From, graph2Y2To, ntssUser));
      // wp アプリケーションログの適正化 Add End
      // レスポンス生成
      return new ResponseEntity<>(new ReportHtmlResponse(reportHtml, null), HttpStatus.OK);
    }
    @PostMapping("rrGraph/preview-report/byUploadFile/{ordNo}")
    public ResponseEntity<?> previewRRGraphReportHtml(@PathVariable("ordNo") Long ordNo,
            @RequestParam("files") MultipartFile file, @RequestParam("graphY1From") BigDecimal graphY1From,
            @RequestParam("graphY1To") BigDecimal graphY1To, @AuthenticationPrincipal NtssUser ntssUser) {
      // wp アプリケーションログの適正化 Add Start
      String mappingUrl = Uri.BVMS + "/rrGraph/preview-report/byUploadFile";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(ordNo, file, graphY1From, graphY1To, ntssUser));
      // wp アプリケーションログの適正化 Add End

      OrdMain ordInfo = getOrdInfo(ordNo);
      Map<String, Object> dataKey = new HashedMap<>();
      RRGraphFilterDTO filter = getRRGraphFilterDTO(graphY1From, graphY1To, null, null);
      RRGraphDTO graph = rrService.getGraphByUploadFile(ordNo, file, filter);
      List<byte[]> bvmsChartData = bvmsReportChartService.getRRChart(ordNo, ChartImageType.PNG, graph, filter);
      dataKey.put("bvmsChartData", bvmsChartData);
      dataKey.put("ordNo", ordNo);
      dataKey.put("patId", getPatId(ordNo));
      dataKey.put("login", ntssUser.getUsername());
      createdDataKey(dataKey,ordInfo);
      // 帳票作成サービスの呼び出し
      String reportHtml = "";
      byte[] excelResult = reportService.getReportExcelFileForDialysisReport(BVGRAPH_REPORT_CD, dataKey);
      if (!(excelResult == null || excelResult.length == 0)) {
        ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(excelResult);
        URL url = null;
        try {
          url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
          reportHtml += AsposeCellsUtils.excelToSvg(byteArrayInputStream, url);
        } catch (Exception e) {
          throw new RuntimeException(e);
        }
      }
      // PDF格納先パスが指定されている場合は、HTMLをPDFに変換してS3にアップロードし、印刷要求を投げる
      if (!StringUtils.isEmpty(filter.getPdfPath())) {
        reportService.convertHtmlToPdf(reportHtml, filter.getPdfPath());
        printerService.sendPrintRequest(filter.getTargetPrinter(), filter.getPdfPath());
      }

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(ordNo, file, graphY1From, graphY1To, ntssUser));
      // wp アプリケーションログの適正化 Add End
      // レスポンス生成
      return new ResponseEntity<>(new ReportHtmlResponse(reportHtml, null), HttpStatus.OK);
    }

    @NonNull
    private Long getPatId(Long ordNo) {
        OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
        if (ordMain == null) {
            throw new NtssException("システムで管理する一意なオーダ番号 : " + ordNo);
        }
        return ordMain.getPatId();
    }

    private void isOrdNoExsit(Long ordNo) {
        OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
        if (ordMain == null) {
            throw new NtssException("ordNo " + ordNo + " not exist.");
        }
    }

    private BVMSFilterDTO getBVMSFilterDTO(BigDecimal graph1Y1From, BigDecimal graph1Y1To, BigDecimal graph1Y2From,
            BigDecimal graph1Y2To, BigDecimal graph2Y1From, BigDecimal graph2Y1To, BigDecimal graph2Y2From,
            BigDecimal graph2Y2To, Long targetPrinter, String pdfPath) {
        BVMSFilterDTO filter = new BVMSFilterDTO();
        filter.setGraph1Y1From(graph1Y1From);
        filter.setGraph1Y1To(graph1Y1To);
        filter.setGraph1Y2From(graph1Y2From);
        filter.setGraph1Y2To(graph1Y2To);
        filter.setGraph2Y1From(graph2Y1From);
        filter.setGraph2Y1To(graph2Y1To);
        filter.setGraph2Y2From(graph2Y2From);
        filter.setGraph2Y2To(graph2Y2To);
        filter.setTargetPrinter(targetPrinter);
        filter.setPdfPath(pdfPath);
        return filter;
    }

    private RRGraphFilterDTO getRRGraphFilterDTO(BigDecimal graphY1From, BigDecimal graphY1To, Long targetPrinter,
            String pdfPath) {
        RRGraphFilterDTO filter = new RRGraphFilterDTO();
        filter.setGraphY1From(graphY1From);
        filter.setGraphY1To(graphY1To);
        filter.setTargetPrinter(targetPrinter);
        filter.setPdfPath(pdfPath);
        return filter;
    }

  /**
   * クラス名取得
   */
  private String getClassName() {
    return this.getClass().getName();
  }

  /**
   * メソッド名取得
   */
  private String getMethodName() {
    return Thread.currentThread().getStackTrace()[2].getMethodName();
  }

  private OrdMain getOrdInfo(Long ordNo) {
    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    if (ordMain == null) {
      throw new NtssException("ordNo " + ordNo + " not exist.");
    }
    return ordMain;
  }

  private Map<String,Object> createdDataKey(Map<String,Object> dataKey,OrdMain ordMain) {
    Map<String, List> searchList = this.searchMap(ordMain.getFacilityCd());
    dataKey.put("facilityCd", ordMain.getFacilityCd());
    dataKey.put("date", ordMain.getTreatDate());
    dataKey.put("fromDate", ordMain.getTreatDate());
    dataKey.put("toDate", ordMain.getTreatDate());
    dataKey.put("endDate", ordMain.getTreatDate());
    dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS, searchList.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
    dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS, searchList.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
    dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS, searchList.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));

    List<String> prescriptionClassList = new ArrayList<String>(Arrays.asList("1", "2"));
    dataKey.put("prescriptionClassList", prescriptionClassList);
    List<OrdPrescription> ordPrescriptionList = ordPrescriptionDao.selectResultByPatIdAndDateFromTo(
      Long.parseLong(String.valueOf(dataKey.get("patId"))),
      ordMain.getFacilityCd(),
      ordMain.getTreatDate(),
      ordMain.getTreatDate(),
      prescriptionClassList);
    List<Long> ordPrescriptionNos = new ArrayList<>();
    for (OrdPrescription rx : ordPrescriptionList) {
      ordPrescriptionNos.add(rx.getOrdPrescriptionNo());
    }
    dataKey.put(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NOS, ordPrescriptionNos);

    return dataKey;
  }

  public Map<String,List> searchMap (String facilityCd){
    Map<String,List>map= new HashMap<>();
    // ダイアライザマスタ
    List<MstDialyzer> dialyzerList = mstInfoService.findMstDialyzerAllByFacillityCd(facilityCd);
    if(null != dialyzerList && dialyzerList.size()>0){
      List<Integer>list =new ArrayList<>();
      for(MstDialyzer dl : dialyzerList){
        list.add(dl.getDialyzerCd());
      }
      map.put(ReportConstant.ReportDataKey.DIALYZER_IDS,list);
    }else{
      map.put(ReportConstant.ReportDataKey.DIALYZER_IDS,new ArrayList());
    }
    // 医療材料分類
    MstEquipmentClass params = new MstEquipmentClass();
    params.setFacilityCd(facilityCd);
    List<MstEquipmentClass> mstEquipmentClassList = mstEquipmentClassDao.selectAll(SelectOptions.get(), params);
    if(null != mstEquipmentClassList && mstEquipmentClassList.size()>0){
      List<Integer>list =new ArrayList<>();
      // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
      list.add(-1);
      // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
      for(MstEquipmentClass mec : mstEquipmentClassList){
        list.add(mec.getClassCd());
      }
      // mod 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
      // map.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,mstEquipmentClassList);
      map.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,list);
      // mod 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
    }else{
      map.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,new ArrayList());
    }

    // 薬剤分類
    MstMedicineClass medicineClass = new MstMedicineClass();
    medicineClass.setFacilityCd(facilityCd);
    List<MstMedicineClass> mstMedicineClassList = mstMedicineClassDao.selectAll(SelectOptions.get(),medicineClass);
    if(null != mstEquipmentClassList && mstEquipmentClassList.size()>0){
      List<Integer>list =new ArrayList<>();
      // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
      list.add(-1);
      // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
      for(MstMedicineClass mdc : mstMedicineClassList){
        list.add(mdc.getClassCd());
      }
      // mod 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
      // map.put(ReportConstant.ReportDataKey.MEDICINE_IDS,mstMedicineClassList);
      map.put(ReportConstant.ReportDataKey.MEDICINE_IDS,list);
      // mod 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
    }else{
      map.put(ReportConstant.ReportDataKey.MEDICINE_IDS,new ArrayList());
    }

    return map;
  }
}
