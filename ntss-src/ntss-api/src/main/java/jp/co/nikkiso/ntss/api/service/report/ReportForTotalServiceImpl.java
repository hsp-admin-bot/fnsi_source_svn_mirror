package jp.co.nikkiso.ntss.api.service.report;
// add #11973 日常点検一覧帳票が正常に出せない limingzhe start
import com.aspose.cells.SaveFormat;
import com.aspose.cells.Workbook;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.api.constant.ReportConstant;
import jp.co.nikkiso.ntss.api.domain.report.ReportXmlClassificationDataCode;
import jp.co.nikkiso.ntss.api.domain.report.ReportXmlFilterTable;
import jp.co.nikkiso.ntss.api.domain.report.ReportXmlGroup;
import jp.co.nikkiso.ntss.api.domain.report.ReportXmlParam;
import jp.co.nikkiso.ntss.api.domain.report.ReportXmlTmplRepeat;
import jp.co.nikkiso.ntss.api.domain.report.ReportXmlTotalTable;
import jp.co.nikkiso.ntss.api.service.LogService;
import jp.co.nikkiso.ntss.api.service.SysDataSetService;
import jp.co.nikkiso.ntss.api.service.utils.ReportUtils;
import jp.co.nikkiso.ntss.api.service.utils.ReportZipFile;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstReportDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.OrdPrescriptionDao;
import jp.co.nikkiso.ntss.core.dao.PatEventDao;
import jp.co.nikkiso.ntss.core.entity.MstReport;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.utils.NtssUtils;
import lombok.extern.slf4j.Slf4j;
import org.jsoup.Jsoup;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;
import javax.script.ScriptException;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Base64;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutionException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

import static java.util.stream.Collectors.toList;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * 帳票の複数集計出力Service実装クラス.
 */
@Service
@Slf4j
public class ReportForTotalServiceImpl implements ReportForTotalService {
  /**
   * 帳票出力情報のKey項目に使用する複数ページ区切り文字列.
   */
  private static final String MULTIPLE_PAGES_SEPARATOR = "#";
  /**
   * 複数セットの計上票の出力最大ページ数
   */
  private static final Integer SET_MAX_PAGE = 100;

  @Autowired
  ReportServiceImpl reportServiceImpl;

  @Autowired
  ReportTotalService reportOutPutUtil;

  /**
   * SysDataSetから帳票出力情報を取得するServiceインタフェース.
   */
  @Autowired
  private SysDataSetService sysDataSetService;

  @Autowired
  private ReportWithAsposeApiService reportWithAsposeApiService;

  /**
   * 帳票ファイル取得のServiceインタフェース.
   */
  @Autowired
  private ReportS3Service reportS3Service;

  @Autowired
  ReportService reportService;

  @Autowired
  private LogService logService;

  /**
   * 帳票マスタのDaoインタフェース.
   */
  @Autowired
  private MstReportDao mstReportDao;
  // add #12324 紹介状の出力時にpat_eventを参照する zhao start
  /**
   * 患者イベントのDaoインタフェース.
   */
  @Autowired
  private PatEventDao patEventDao;
  // add #12324 紹介状の出力時にpat_eventを参照する zhao end

  // add #11276 キー日付に対するデータ引き当て仕様対応 高　start
  @Autowired
  private OrdMainDao rdMainDao;

  @Autowired
  private OrdPrescriptionDao ordPrescriptionDao;
  // add #11276 キー日付に対するデータ引き当て仕様対応 高　end
  // add #12402 紹介状の編集で画像の追加や差し替えができない zhao start
  /**
   * イメージ
   */
  @Value("${ntss.pat-event.s3-bucket:#{null}}")
  private String s3BucketForImage;
  // add #12402 紹介状の編集で画像の追加や差し替えができない zhao end
  /**
   * 印刷情報 を取得するsql_cd
   */
  private static final Long PRINT_INFO_CODE = 0L;
  /**
   * 外来合計 を取得するsql_cd
   */
  private static final long SQL_CD_OUT_PAT_CNT = 150L;
  /**
   * 入院合計 を取得するsql_cd
   */
  private static final long SQL_CD_HOSP_PAT_CNT = 151L;

  private static final String PAT_ID_TO_C = "patIdToC";

  /**
   * 帳票定義XMLを取得します.
   *
   * @param mstReport     帳票マスタEntity
   * @param reportZipFile 帳票Zipファイル
   * @return 帳票定義XML
   */
  private String getReportXml(MstReport mstReport, ReportZipFile reportZipFile) {
    // 帳票定義XMLファイルを取得する
    String reportXml = reportZipFile.getFileToString(mstReport.getReportPath().getXmlFilename());
    if (StringUtils.isEmpty(reportXml)) {
      List<String> fileList = reportZipFile.getFileToString();
      throw new NtssException("帳票定義XMLファイルを取得できません。"
        + "MstReport:[" + mstReport.getReportPath().getXmlFilename() + "]"
        + " ReportZipFile:[" + fileList.toString() + "]"
      );
    }
    return reportXml;
  }

  /**
   * 帳票Zipファイルを取得します.
   *
   * @param mstReport 帳票マスタEntity
   * @return 帳票Zipファイル
   */
  private ReportZipFile getReportZip(MstReport mstReport) {
    return new ReportZipFile(
      reportS3Service.getReportFile(
        mstReport.getReportPath().getBucket(),
        mstReport.getReportPath().getReportZip(),
        mstReport.getUpDate()));
  }

  // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe start
  @Override
  public byte[] getReportExcelFileForIntroductionReport(Long reportCd, Map<String, Object> dataKey) {
    // mod #12650 登録済み紹介状が帳票マスタ削除の影響を受けるのは不適切 zhao start
    //MstReport mstReport = mstReportDao.selectByCd(reportCd);
    MstReport mstReport = mstReportDao.selectByReportCd(reportCd);
    // mod #12650 登録済み紹介状が帳票マスタ削除の影響を受けるのは不適切 zhao end
    if(dataKey.containsKey("ctlNo") && !"undefined".equals(dataKey.get("ctlNo"))){
      MstReport.ReportHstInfo hstInfo = mstReport.getReportHstInfo();
      for (MstReport.Item item: hstInfo.getItems()){
        if(item.getCtlNo().equals(dataKey.get("ctlNo"))){
          MstReport.ReportPath re = new MstReport.ReportPath();
          re.setReportZip(item.getReportZip());
          re.setBucket(item.getBucket());
          re.setXlsxZip(item.getXlsxZip());
          re.setXmlFilename(item.getXmlFilename());
          re.setHtmlFilename(item.getHtmlFilename());
          re.setXlsxFilename(item.getXlsxFilename());
          mstReport.setReportPath(re);
        }
      }
    }
    if(dataKey.containsKey("isUpdate") && !"undefined".equals(dataKey.get("isUpdate"))){
      MstReport.ReportHstInfo hstInfo = mstReport.getReportHstInfo();
      MstReport.Item item = hstInfo.getItems().get(hstInfo.getItems().size()-1);
      MstReport.ReportPath re = new MstReport.ReportPath();
      re.setReportZip(item.getReportZip());
      re.setBucket(item.getBucket());
      re.setXlsxZip(item.getXlsxZip());
      re.setXmlFilename(item.getXmlFilename());
      re.setHtmlFilename(item.getHtmlFilename());
      re.setXlsxFilename(item.getXlsxFilename());
      mstReport.setReportPath(re);
    }
    // S3から帳票定義XML、帳票デザインExcelが格納されたZipファイルを取得する
    ReportZipFile reportZipFile = getReportZip(mstReport);
    // SqlCodeをもとに帳票に出力する情報を取得する
    String reportXml = this.getReportXml(mstReport, reportZipFile);
    List<ReportXmlParam> params = ReportUtils.getParamElements(reportXml);
    String getColWidth = "";
    String getRowHeight = "";
    if (params.size() > 0) {
      getColWidth = "";
      getRowHeight = "";
      for (int p = 0; p < params.size(); p++) {
        if ("".equals(params.get(p).getDataCode()) && "byte[]".equals(params.get(p).getDataType())) {
          getColWidth = params.get(p).getColWidth();
          getRowHeight = params.get(p).getRowHeight();
        }
      }
    }

    long startTime = System.currentTimeMillis();
    Map<String, Long> patIdToCMap = new HashMap<>();
    Map<String, String> htmlIdCountMap = new HashMap<>();
    Map<String, String> calcResult = new HashMap<>();
    createTotalReportHtml(mstReport, dataKey, patIdToCMap, htmlIdCountMap, params);
    if(null != dataKey.get("IntroLetterReportPrinte") && (Boolean)dataKey.get("IntroLetterReportPrinte")){
      Map<String,Object> htmlCheckMap = (Map<String,Object>)dataKey.get("htmlTemplate");
      for (Map.Entry<String,Object> entry : htmlCheckMap.entrySet()) {
        htmlIdCountMap.put(entry.getKey(),entry.getValue().toString());
      }
    }
    reportServiceImpl.getQRContentInfo(params, dataKey, htmlIdCountMap);
    long endTime = System.currentTimeMillis();
    long executionTime = (endTime - startTime);
    System.err.println("createTotalReportHtml总耗时 total: （秒）" + executionTime / 1000 + " milli");

    try{
      long startTimeWorkbook = System.currentTimeMillis();
      // mod #12324 紹介状の出力時にpat_eventを参照する zhao start
      //com.aspose.cells.Workbook wb = reportWithAsposeApiService.getReportExcelWorkbook(mstReport, reportZipFile, params, htmlIdCountMap, calcResult, null, dataKey, getColWidth, getRowHeight);
      com.aspose.cells.Workbook wb = new Workbook();
      if(dataKey.containsKey("moveFlag")){
        List<Map<String, String>> reportOutputInfoList = new ArrayList<>();
        editLetterInfoForScreenDisplay(params, reportOutputInfoList, dataKey);
        wb = reportWithAsposeApiService.getReportExcelWorkbookForIntroductionReport(mstReport, reportZipFile, params,
          reportOutputInfoList, calcResult, null, dataKey, getColWidth, getRowHeight);
      } else {
        wb = reportWithAsposeApiService.getReportExcelWorkbook(mstReport, reportZipFile, params, htmlIdCountMap,
          calcResult, null, dataKey, getColWidth, getRowHeight);
      }
      // mod #12324 紹介状の出力時にpat_eventを参照する zhao end
      wb.calculateFormula(true);
      // 一時ファイルに出力
      ByteArrayOutputStream o = new ByteArrayOutputStream();
      wb.save(o, SaveFormat.XLSX);
      wb.dispose();
      long endTimeWorkbook = System.currentTimeMillis();
      long executionTimeWorkbook = (endTimeWorkbook - startTimeWorkbook);
      System.err.println("getReportExcelWorkbook总耗时 total: " + executionTimeWorkbook + " （ms）");

      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setFacilityCd(mstReport.getFacilityCd());
      eventLogMessage.setLogMessage("紹介状 createTotalReportHtml总耗时 total: " + executionTime + " （ms）");
      logService.log(LogLevel.INFO, eventLogMessage,LoggingConstant.FUNCTION_CODE.FUNC_REPORT_MENU, LoggingConstant.SERVICE_NAME.FNSI, null);
      eventLogMessage.setLogMessage("紹介状 getReportExcelWorkbook总耗时 total: " + executionTimeWorkbook + " （ms）");
      logService.log(LogLevel.INFO, eventLogMessage,LoggingConstant.FUNCTION_CODE.FUNC_REPORT_MENU, LoggingConstant.SERVICE_NAME.FNSI, null);

      return o.toByteArray();
    } catch (Exception e) {
      // エラーメッセージ
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage("帳票Excelファイルの出力に失敗しました。：" + ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      throw new NtssException("帳票Excelファイルの出力に失敗しました。");
    }
  }
  // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe end

  // add #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe start
  @Override
  public byte[] getReportExcelFileForOneTotal(Long reportCd, Map<String, Object> dataKey) {
    MstReport mstReport = mstReportDao.selectByCd(reportCd);
    // S3から帳票定義XML、帳票デザインExcelが格納されたZipファイルを取得する
    ReportZipFile reportZipFile = getReportZip(mstReport);
    // SqlCodeをもとに帳票に出力する情報を取得する
    String reportXml = this.getReportXml(mstReport, reportZipFile);
    List<ReportXmlParam> params = ReportUtils.getParamElements(reportXml);
    String getColWidth = "";
    String getRowHeight = "";
    if (params.size() > 0) {
      getColWidth = "";
      getRowHeight = "";
      for (int p = 0; p < params.size(); p++) {
        if ("".equals(params.get(p).getDataCode()) && "byte[]".equals(params.get(p).getDataType())) {
          getColWidth = params.get(p).getColWidth();
          getRowHeight = params.get(p).getRowHeight();
        }
      }
    }

    long startTime = System.currentTimeMillis();
    Map<String, Long> patIdToCMap = new HashMap<>();
    Map<String, String> htmlIdCountMap = new HashMap<>();
    Map<String, String> calcResult = new HashMap<>();
    // add #11299 「##=」型の計算式で「[##データ項目]」を参照するとエラーになる 高 start
//    createTotalReportHtml(mstReport, dataKey, patIdToCMap, htmlIdCountMap);
    createTotalReportHtml(mstReport, dataKey, patIdToCMap, htmlIdCountMap, params);
    // add #11299 「##=」型の計算式で「[##データ項目]」を参照するとエラーになる 高 end
    if(null != dataKey.get("IntroLetterReportPrinte") && (Boolean)dataKey.get("IntroLetterReportPrinte")){
      Map<String,Object> htmlCheckMap = (Map<String,Object>)dataKey.get("htmlTemplate");
      for (Map.Entry<String,Object> entry : htmlCheckMap.entrySet()) {
        htmlIdCountMap.put(entry.getKey(),entry.getValue().toString());
      }
    }
    long endTime = System.currentTimeMillis();
    long executionTime = (endTime - startTime);
    System.err.println("createTotalReportHtml总耗时 total: （秒）" + executionTime / 1000 + " milli");

    try{
      long startTimeWorkbook = System.currentTimeMillis();
      com.aspose.cells.Workbook wb = reportWithAsposeApiService.getReportExcelWorkbook(mstReport, reportZipFile, params, htmlIdCountMap, calcResult, null, dataKey, getColWidth, getRowHeight);
      wb.calculateFormula(true);
      // 一時ファイルに出力
      ByteArrayOutputStream o = new ByteArrayOutputStream();
      wb.save(o, SaveFormat.XLSX);
      wb.dispose();
      long endTimeWorkbook = System.currentTimeMillis();
      long executionTimeWorkbook = (endTimeWorkbook - startTimeWorkbook);
      System.err.println("getReportExcelWorkbook总耗时 total: " + executionTimeWorkbook + " （ms）");

      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setFacilityCd(mstReport.getFacilityCd());
      eventLogMessage.setLogMessage("単集計 createTotalReportHtml总耗时 total: " + executionTime + " （ms）");
      logService.log(LogLevel.INFO, eventLogMessage,LoggingConstant.FUNCTION_CODE.FUNC_REPORT_MENU, LoggingConstant.SERVICE_NAME.FNSI, null);
      eventLogMessage.setLogMessage("単集計 getReportExcelWorkbook总耗时 total: " + executionTimeWorkbook + " （ms）");
      logService.log(LogLevel.INFO, eventLogMessage,LoggingConstant.FUNCTION_CODE.FUNC_REPORT_MENU, LoggingConstant.SERVICE_NAME.FNSI, null);

      return o.toByteArray();
    } catch (Exception e) {
      // エラーメッセージ
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage("帳票Excelファイルの出力に失敗しました。：" + ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      throw new NtssException("帳票Excelファイルの出力に失敗しました。");
    }
  }
  // add #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe end

  @Override
  public byte[] getReportExcelFileForMultiTotal(Long reportCd, Map<String, Object> dataKey) {
    MstReport mstReport = mstReportDao.selectByCd(reportCd);
    // S3から帳票定義XML、帳票デザインExcelが格納されたZipファイルを取得する
    ReportZipFile reportZipFile = getReportZip(mstReport);
    // SqlCodeをもとに帳票に出力する情報を取得する
    String reportXml = this.getReportXml(mstReport, reportZipFile);
    List<ReportXmlParam> params = ReportUtils.getParamElements(reportXml);
    String getColWidth = "";
    String getRowHeight = "";
    if (params.size() > 0) {
      getColWidth = "";
      getRowHeight = "";
      for (int p = 0; p < params.size(); p++) {
        if ("".equals(params.get(p).getDataCode()) && "byte[]".equals(params.get(p).getDataType())) {
          getColWidth = params.get(p).getColWidth();
          getRowHeight = params.get(p).getRowHeight();
        }
      }
    }

    long startTime = System.currentTimeMillis();
    dataKey.put("facilityCd", mstReport.getFacilityCd());

    Map<String, Long> patIdToCMap = new HashMap<>();
    Map<String, String> htmlIdCountMap = new HashMap<>();
    Map<String, String> calcResult = new HashMap<>();
    // add #11299 「##=」型の計算式で「[##データ項目]」を参照するとエラーになる 高 start
//    createTotalReportHtml(mstReport, dataKey, patIdToCMap, htmlIdCountMap);
    createTotalReportHtml(mstReport, dataKey, patIdToCMap, htmlIdCountMap, params);
    // add #11299 「##=」型の計算式で「[##データ項目]」を参照するとエラーになる 高 end
    long endTime = System.currentTimeMillis();
    long executionTime = (endTime - startTime);
    System.err.println("createTotalReportHtml总耗时 total: （秒）" + executionTime / 1000 + " milli");

    try{
      long startTimeWorkbook = System.currentTimeMillis();
      com.aspose.cells.Workbook wb = reportWithAsposeApiService.getReportExcelWorkbook(mstReport, reportZipFile, params, htmlIdCountMap, calcResult, null, dataKey, getColWidth, getRowHeight);
      wb.calculateFormula(true);
      // 一時ファイルに出力
      ByteArrayOutputStream o = new ByteArrayOutputStream();
      wb.save(o, SaveFormat.XLSX);
      wb.dispose();
      long endTimeWorkbook = System.currentTimeMillis();
      long executionTimeWorkbook = (endTimeWorkbook - startTimeWorkbook);
      System.err.println("getReportExcelWorkbook总耗时 total: " + executionTimeWorkbook + " （ms）");

      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setFacilityCd(mstReport.getFacilityCd());
      eventLogMessage.setLogMessage("複数集計 createTotalReportHtml总耗时 total: " + executionTime + " （ms）");
      logService.log(LogLevel.INFO, eventLogMessage,LoggingConstant.FUNCTION_CODE.FUNC_REPORT_MENU, LoggingConstant.SERVICE_NAME.FNSI, null);
      eventLogMessage.setLogMessage("複数集計 getReportExcelWorkbook总耗时 total: " + executionTimeWorkbook + " （ms）");
      logService.log(LogLevel.INFO, eventLogMessage,LoggingConstant.FUNCTION_CODE.FUNC_REPORT_MENU, LoggingConstant.SERVICE_NAME.FNSI, null);

      return o.toByteArray();
    } catch (Exception e) {
      // エラーメッセージ
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage("帳票Excelファイルの出力に失敗しました。：" + ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      throw new NtssException("帳票Excelファイルの出力に失敗しました。");
    }
  }

  /**
   * 集計帳票情報(HTML)の取得.
   *
   * @param mstReport 出力する帳票マスタ情報
   * @param dataKey   帳票出力データを取得する為のパラメータ情報
   * @return 帳票HTML
   */
  private void createTotalReportHtml(MstReport mstReport,
                                    Map<String, Object> dataKey,
                                    Map<String, Long> patIdToCMap,
                                    Map<String, String> outPutHtml,
                                     // add #11299 「##=」型の計算式で「[##データ項目]」を参照するとエラーになる 高 start
                                     List<ReportXmlParam> params
                                     // add #11299 「##=」型の計算式で「[##データ項目]」を参照するとエラーになる 高 end
                                      ) {
    // S3から帳票定義XML、帳票デザインHTMLが格納されたZipファイルを取得.
    ReportZipFile reportZipFile = getReportZip(mstReport);
    // 帳票定義XMLを取得.
    String reportXml = getReportXml(mstReport, reportZipFile);
    // 作成したhtmlを格納する変数
    // テンプレート有無(true:テンプレートあり、false:テンプレートなし)
    boolean hasTemplate = false;
    try {
      hasTemplate = hasTemplate(reportXml);
    } catch (NtssException ex) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(ex));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      eventLogMessage.setFacilityCd(mstReport.getFacilityCd());
      logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
      // テンプレート有無の判定に失敗した場合、空のhtmlを返す.
      throw new NtssException("帳票テンプレートにTemplateが含まれているかどうかを判定する際にエラーが発生しました");
    }

    // 帳票定義XMLのparam要素のリストを取得.
    List<ReportXmlParam> reportXmlParamsList = ReportUtils.getParamElements(reportXml);
    // テンプレート内のパラメータを格納する変数
    List<ReportXmlParam> paramsInTempl = new ArrayList<ReportXmlParam>();
    // テンプレート外のパラメータを格納する変数
    List<ReportXmlParam> paramsOutTempl = new ArrayList<ReportXmlParam>();
    // テンプレート内と外のparam要素を各リストに追加
    reportXmlParamsList.forEach(reportXmlParam -> {
      if (!StringUtils.isEmpty(reportXmlParam.getIsInTmpl()) &&
        reportXmlParam.getIsInTmpl().equals(ReportXmlParam.IS_IN_TMPL_YES)) {
        paramsInTempl.add(reportXmlParam);
      } else {
        paramsOutTempl.add(reportXmlParam);
      }
    });
    if (paramsInTempl.isEmpty()) {
      hasTemplate = false;
    }

    Map<String, String> calcResult = new HashMap<>();
    // add #11299 「##=」型の計算式で「[##データ項目]」を参照するとエラーになる 高 start
    List<ReportXmlParam> paramsOutTemplBk = new ArrayList<>();
    // add #11299 「##=」型の計算式で「[##データ項目]」を参照するとエラーになる 高 end
    if (hasTemplate) {
      // テンプレート内の処理

      Integer reportClass = mstReport.getReportClass() == null ? 0 : mstReport.getReportClass();
      //単集計の帳票タイプ区分（[1：紹介状集計]）
      //複数集計の帳票タイプ区分（[1：スケジュール表,2：週間薬剤集計表, 3：水質調査一覧, 4:日常点検一覧]）
      Integer reportType = mstReport.getReportType() == null ? 0 : mstReport.getReportType();

      ReportXmlTotalTable totalTable = paramsInTempl.get(0).getReportXmlTotalTable();

      String totalUnitV = totalTable.getUnitV();
      String totalUnitVAddr = totalTable.getUnitVAddress();
      String totalUnitH = totalTable.getUnitH();
      String totalUnitHAddr = totalTable.getUnitHAddress();
      String totalUnitDate = totalTable.getUnitDate();
      // mod #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe start
//      String effectDateFlag = "1";
//      if(reportClass == 11){
//        if(reportType == 3) effectDateFlag = "0";
//        else if(reportType == 2) {
//          if(!dataKey.containsKey("functionCd") && dataKey.get("specifyDate") != null) effectDateFlag = "0";
//        }
//      }
//      else if(reportClass == 10){
//        effectDateFlag = "1";
//      }
//      else {
//        throw new NtssException("帳票の種類が間違っています。");
//      }
      String effectDataVFlag = StringUtils.isEmpty(totalTable.getEffectDataV()) ? "0" : totalTable.getEffectDataV();
      // mod #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe end
      // add #12218 集計の縦単位でも値のない行が出力できない limingzhe start
      String effectDataHFlag = StringUtils.isEmpty(totalTable.getEffectDataH()) ? "0" : totalTable.getEffectDataH();
      // add #12218 集計の縦単位でも値のない行が出力できない limingzhe end
      String totalContents = totalTable.getContents();
      String totalContentsType = StringUtils.isEmpty(totalTable.getContentsType()) ? "" : totalTable.getContentsType();
      String totalConversion = totalTable.getConversion();
      String totalCountH = StringUtils.isEmpty(totalTable.getCountH()) ? "0" : totalTable.getCountH();
      String totalCountV = StringUtils.isEmpty(totalTable.getCountV()) ? "0" : totalTable.getCountV();
      Map<String, String> param2 = new HashMap<>();
      param2.put("totalUnitV", totalUnitV);
      param2.put("totalUnitVAddr", totalUnitVAddr);
      param2.put("totalUnitH", totalUnitH);
      param2.put("totalUnitHAddr", totalUnitHAddr);
      param2.put("totalUnitDate", totalUnitDate);
      // mod #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe start
      //param2.put("effectDateFlag", effectDateFlag);
      param2.put("effectDataVFlag", effectDataVFlag);
      // mod #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe end
      // add #12218 集計の縦単位でも値のない行が出力できない limingzhe start
      param2.put("effectDataHFlag", effectDataHFlag);
      // add #12218 集計の縦単位でも値のない行が出力できない limingzhe end
      param2.put("totalContents", totalContents);
      param2.put("totalContentsType", totalContentsType);
      param2.put("totalConversion", totalConversion);
      param2.put("totalCountH", totalCountH);
      param2.put("totalCountV", totalCountV);
      param2.put("reportType", String.valueOf(reportType));
      param2.put("reportClass", String.valueOf(reportClass));

      ReportXmlTmplRepeat tmplRepeatAll = paramsInTempl.get(0).getReportXmlTmplRepeat();

      String tmplId = tmplRepeatAll.getId();
      Integer repeatH = tmplRepeatAll.getRepeatCountH(); // 横方向繰り返し数
      Integer repeatV = tmplRepeatAll.getRepeatCountV(); // 縦方向繰り返し数
      String direction = tmplRepeatAll.getDirection();
      String isNewPage = String.valueOf(tmplRepeatAll.getIsNewPage()); // 改ページ
      // add #11813 紹介状出力時、手打ち入力した導入施設名が表示されない limingzhe start
      if (dataKey.get("newPageCountFlag") != null) isNewPage = "0";
      // add #11813 紹介状出力時、手打ち入力した導入施設名が表示されない limingzhe end
      Map<String, Object> tmplRepeat = new HashMap<>();
      tmplRepeat.put("tmplId", tmplId);
      tmplRepeat.put("repeatCountH", repeatH);
      tmplRepeat.put("repeatCountV", repeatV);
      tmplRepeat.put("direction", direction);
      tmplRepeat.put("isNewPage", isNewPage);

      createReportForTotal(
        mstReport,
        paramsOutTempl,
        paramsInTempl,
        dataKey,
        param2, //totalSet
        tmplRepeat, //tmplSet
        patIdToCMap,
        outPutHtml,
        calcResult,
        // add #11299 「##=」型の計算式で「[##データ項目]」を参照するとエラーになる 高 start
        paramsOutTemplBk
        // add #11299 「##=」型の計算式で「[##データ項目]」を参照するとエラーになる 高 end
      );
    } else {
      // ---------------------------------------
      // テンプレート外の値を埋め込む処理
      // --------------------------------------
      createReportOutTemplate(
        mstReport,
        paramsOutTempl,
        dataKey,
        patIdToCMap,
        outPutHtml,
        calcResult,
        // add #11299 「##=」型の計算式で「[##データ項目]」を参照するとエラーになる 高 start
        paramsOutTemplBk
        // add #11299 「##=」型の計算式で「[##データ項目]」を参照するとエラーになる 高 end
      );
    }
    // add #11299 「##=」型の計算式で「[##データ項目]」を参照するとエラーになる 高 start
    params.clear();
    params.addAll(paramsOutTemplBk);
    params.addAll(paramsInTempl);
    // add #11299 「##=」型の計算式で「[##データ項目]」を参照するとエラーになる 高 end
  }

  /**
   * 与えられた帳票定義xml内にテンプレート繰り返しが含まれあるか否かを返す.
   * 繰り返しの判断はreport要素のhasTmplで判断する.
   * "0" : テンプレート繰り返しなし
   * "1" : テンプレート繰り返しあり
   *
   * @param reportXml 帳票定義xml
   * @return true : テンプレート繰り返しあり、false : テンプレート繰り返しなし
   * @throws NtssException テンプレート繰り返しの判定に失敗した場合(帳票定義xmlの解析に失敗等)
   */
  private boolean hasTemplate(String reportXml) throws NtssException {
    // 帳票定義XMLにinputStream
    InputStream inputStream = null;
    try {
      // 帳票定義XMLを読み込む.
      inputStream = new ByteArrayInputStream(reportXml.getBytes(StandardCharsets.UTF_8));
      // 帳票定義Xmlをパース
      org.w3c.dom.Document document = ReportUtils.getDomDocument(inputStream);
      // report要素を取得する
      NodeList nodeReport = document.getElementsByTagName("report");
      Element repElement = (Element) nodeReport.item(0);
      if (Objects.isNull(repElement)) {
        return false;
      }
      String strHasTmpl = repElement.getAttribute("hasTmpl");
      return !StringUtils.isEmpty(strHasTmpl) && strHasTmpl.equals("1");
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("report xml parse param failed.");
      logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
      throw new NtssException("帳票定義xmlからテンプレート有無の判定に失敗しました", e.getCause());
    } finally {
      Optional.ofNullable(inputStream).ifPresent(is -> {
        try {
          is.close();
        } catch (IOException e) {
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("帳票定義XMLのinputStreamを閉じる事が出来ませんでした。");
          logService.log(LogLevel.DEBUG, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
        }
      });
    }
  }

  private void createReportForTotal(
    MstReport mstReport,
    List<ReportXmlParam> paramsOutTempl,
    List<ReportXmlParam> paramsInTempl,
    Map<String, Object> dataKey,
    Map<String, String> totalTable,
    Map<String, Object> tmplRepeat,
    Map<String, Long> patIdToCMap,
    Map<String, String> outPutHtml,
    Map<String, String> calcResult,
    // add #11299 「##=」型の計算式で「[##データ項目]」を参照するとエラーになる 高 start
    List<ReportXmlParam> paramsOutTemplBk
    // add #11299 「##=」型の計算式で「[##データ項目]」を参照するとエラーになる 高 end
  ) {
    // テンプレート内のデータを取得する為のdataKeyを取得
    // add #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe start
    getInOfTemplateDataKey(dataKey);
    // add #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe end
    List<Map<String, Object>> dataKeyInOfTemplateList = (List<Map<String, Object>>) dataKey.get(ReportConstant.ReportDataKey.TEMPLATE_PARAMS);
    Map<String, Object> dataKeyOutTempl = getOutOfTemplateDataKey(dataKeyInOfTemplateList.get(0));

    // 集計帳票で集計横、縦単位のパラメータを格納する変数
    List<ReportXmlParam> paramsOutTemplForCount = new ArrayList();

    // 集計帳票で集計範囲外のパラメータを格納する変数
    List<ReportXmlParam> paramsOutTemplNoCount = new ArrayList();

    Integer pOutCount = splitDiffUseParams(totalTable, paramsOutTempl, paramsOutTemplForCount, paramsOutTemplNoCount);
    if(pOutCount != paramsOutTempl.size()) return;

    // 集計帳票でテンプレート内の単位項目の値を埋め込む処理
    Map<Long, List<Map<String, Object>>> reportInfoForTempl = new HashMap<>();

    // 集計帳票で集計横、縦の単位項目の値を埋め込む処理
    Map<Long, List<Map<String, Object>>> reportInfoForOutTempl = new HashMap<>();

    long startTimegetReportInfoInTempl = System.currentTimeMillis();
    if(paramsOutTemplForCount != null && paramsOutTemplForCount.size() > 0){
      // add #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe start
      // mod #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe start
//      if(totalTable.get("reportClass").equals("11")){
//        if(totalTable.get("reportType").equals("2") && !dataKey.containsKey("functionCd") && dataKey.get("specifyDate") != null){
      if((totalTable.get("reportClass").equals("11") && totalTable.get("reportType").equals("2"))
        || (totalTable.get("reportClass").equals("9") && totalTable.get("reportType").equals("1"))
      ){
        if(!dataKey.containsKey("functionCd") && dataKey.get("specifyDate") != null){
      // mod #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe end
          String specifyDate = String.valueOf(dataKey.get("specifyDate")).replace("/", "").replace("-", "");
          String[] result = reportServiceImpl.getStartAndEndDayByDate(specifyDate);
          if(result[0] != null && result[1] != null) {
            String fromDate =  result[0];
            String toDate = result[1];
            dataKeyOutTempl.put(ReportConstant.ReportDataKey.DATE_FROM, fromDate);
            dataKeyOutTempl.put(ReportConstant.ReportDataKey.DATE_TO, toDate);
            List<Long> patIdList = (List<Long>)dataKeyOutTempl.getOrDefault(ReportConstant.ReportDataKey.PAT_IDS, new ArrayList<>());
            List<Map<String, Object>> paramList = reportServiceImpl.getOrdNosbyDataKey(String.valueOf(dataKey.get(ReportConstant.ReportDataKey.FACILITY_CD)), patIdList, fromDate, toDate);
            List<Long> ordNos = new ArrayList<>();
            for (int i = 0; i < paramList.size(); i++) {
              ordNos.addAll((List<Long>)paramList.get(i).get(ReportConstant.ReportDataKey.ORD_NOS));
            }
            if(ordNos != null && ordNos.size() > 0){
              dataKeyOutTempl.put(ReportConstant.ReportDataKey.ORD_NO, ordNos.get(0));
              dataKeyOutTempl.put(ReportConstant.ReportDataKey.ORD_NOS, ordNos);
            }
          }
        }
      }
      // add #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe end

      reportInfoForOutTempl = getReportInfo(paramsOutTemplForCount, dataKeyOutTempl);
      // add #10531 検査日と検査区分がフィルタを超えて繰り返される limingzhe start
      reportServiceImpl.filterReportInfobyParam(paramsOutTemplForCount, reportInfoForOutTempl);
      // add #10531 検査日と検査区分がフィルタを超えて繰り返される limingzhe end
      String inoutDispFormat = "";
      Map<String, String> UnitHMap = getTotalTableUnitSet(totalTable, 0);
      for(String key : UnitHMap.keySet()){
        ReportXmlParam param = getParambyId(paramsOutTempl, key);
        if(param == null) continue;
        if(!param.getDataType().equals(ReportXmlParam.DATA_TYPE_DATE_TIME)) continue;
        inoutDispFormat = param.getDispFormat();
      }
      getMoveInOutTotalInfo(
        reportInfoForOutTempl,
        String.valueOf(dataKeyOutTempl.get(ReportConstant.ReportDataKey.DATE_FROM)),
        String.valueOf(dataKeyOutTempl.get(ReportConstant.ReportDataKey.DATE_TO)),
        inoutDispFormat != null && !inoutDispFormat.equals("") ? totalTable.get("totalUnitDate") : "日",
        inoutDispFormat != null && !inoutDispFormat.equals("") ? inoutDispFormat :
          // mod #12194 機器保守項目のフィルタ設定が帳票出力時に反映しない limingzhe start
          //"yyyy-MM-dd"
          "yyyy/MM/dd"
          // mod #12194 機器保守項目のフィルタ設定が帳票出力時に反映しない limingzhe end
      );

      reportInfoForTempl.putAll(reportInfoForOutTempl);
      List<ReportXmlParam> paramsTemp = new ArrayList<>();
      paramsTemp.addAll(paramsInTempl);
      paramsTemp.addAll(paramsOutTemplForCount);
      paramsTemp.stream().forEach(param -> {
        Long sqlCode;
        if (null != param.getSqlCode() && param.getSqlCode().equals("")) {
          sqlCode = Long.valueOf(0);
        } else {
          sqlCode = Long.valueOf(param.getSqlCode());
        }
        // sqlCodeをもとに出力情報を取得する
        if(reportInfoForTempl.containsKey(sqlCode)) {
          List<Map<String, Object>> tmpList = reportInfoForTempl.get(sqlCode);
          // フィルタ処理を行う
          // mod #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe start
          //List<Map<String, Object>> filteredList = reportServiceImpl.filterReportInfo(param, tmpList);
          List<Map<String, Object>> filteredList = new ArrayList<>();
          if(!StringUtils.isEmpty(param.getFilterType()) && param.getFilterType().contains("Null")) {
            filteredList = tmpList;
          }
          else {
            filteredList = reportServiceImpl.filterReportInfo(param, tmpList);
          }
          // mod #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe end
          // フィルタ処理の結果がEmptyの場合
          if (filteredList.isEmpty()) {
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage("帳票：フィルタ結果した結果が空");
            logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
            return;
          }

          // mod #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe start
//          filteredList.stream().forEach(info -> {
//            // mod #11123 複数集計で平均、最大値、最小値のとき値のないセルにも0が出るのはNG limingzhe start
//            // String value = reportServiceImpl.formatValue(param, info.get(param.getDataCode()));
//            String value = String.valueOf(info.get(param.getDataCode()));
//            // mod #11123 複数集計で平均、最大値、最小値のとき値のないセルにも0が出るのはNG limingzhe end
//            value = reportServiceImpl.convertValue(param, value);
//            // add #11571 「患者名（姓のみ）+同姓フラグ」が同姓同名フラグになっている sunsy start
//            if ("first_name_is_same".equals(param.getDataCode())) {
//              value = info.get("pat_last_name") != null ? info.get("pat_last_name") + value : value;
//            }
//            if ("pat_name_is_same".equals(param.getDataCode())) {
//              value = info.get("pat_name") != null ? info.get("pat_name") + value : value;
//            }
//            // add #11571 「患者名（姓のみ）+同姓フラグ」が同姓同名フラグになっている sunsy end
//            if (value != null && !"null".equals(value)) {
//              value = reportServiceImpl.addLineBreak(value, param);
//              info.put(param.getDataCode(), value);
//            }
//          });
          // add #12529 機器保守カテゴリの装置情報項目が足りていない limingzhe start
          Set<Map<String, Object>> filteredSet = new HashSet<>(filteredList);
          // add #12529 機器保守カテゴリの装置情報項目が足りていない limingzhe end
          for (Map<String, Object> info : tmpList) {
            // mod #12529 機器保守カテゴリの装置情報項目が足りていない limingzhe start
            //if (!filteredList.contains(info))
            if (!filteredSet.contains(info))
            // mod #12529 機器保守カテゴリの装置情報項目が足りていない limingzhe end
            {
              info.put(param.getDataCode(), "");
            }
            else {
              String value = String.valueOf(info.get(param.getDataCode()));
              value = reportServiceImpl.convertValue(param, value);
              // add #12538 日常点検／定期点検のデータ項目補完 limingzhe start
              if(param.getDataCode().equals("layout_group_ans") && value.length() >= 1){
                String convValue = reportServiceImpl.convertValue(param, value.substring(0,1));
                value = convValue.concat(value.substring(1));
              }
              // add #12538 日常点検／定期点検のデータ項目補完 limingzhe end
              // mod #12239 スケジュール表画面のフラグ表現で帳票では出力できないものがある sunsy start
//              if ("first_name_is_same".equals(param.getDataCode())) {
//                value = info.get("pat_last_name") != null ? info.get("pat_last_name") + value : value;
//              }
//              if ("pat_name_is_same".equals(param.getDataCode())) {
//                value = info.get("pat_name") != null ? info.get("pat_name") + value : value;
//              }
              if (param.getDataCode().contains("first_name_is")) {
                String patLastName = info.get("pat_last_name") != null
                  ? info.get("pat_last_name").toString()
                  : "";

                boolean hasValue = value != null && !value.isEmpty();
                boolean hasPatLastName = !patLastName.isEmpty();

                // 状況1:value（変換値）が空、実在の患者姓がある場合、実在の患者姓のみ出力
                if (!hasValue && hasPatLastName) {
                  value = patLastName;
                }

                // 状況2:value（変換値）有り
                else if (hasValue) {

                  // value中に「患者名」がある場合
                  if (value.contains("患者名")) {
                    if (hasPatLastName) {
                      // 患者姓がある → 置換
                      value = value.replace("患者名", patLastName);
                    } else {
                      // 患者姓がない → 全体を空にする
                      value = "";
                    }
                  }

                  // 「患者名」が無いのに患者姓が存在する → エラー
                  else if (hasPatLastName) {
                    value = "変換エラー";
                  }
                }
              }

              if (param.getDataCode().contains("pat_name_is")) {
                String patName = info.get("pat_name") != null
                  ? info.get("pat_name").toString()
                  : "";

                boolean hasValue = value != null && !value.isEmpty();
                boolean hasPatName = !patName.isEmpty();

                // 状況1:value（変換値）が空、実在の患者名がある場合、実在の患者名のみ出力
                if (!hasValue && hasPatName) {
                  value = patName;
                }

                // 状況2:value（変換値）有り
                else if (hasValue) {

                  // value中に「患者名」がある場合
                  if (value.contains("患者名")) {
                    if (hasPatName) {
                      // 患者名がある → 置換
                      value = value.replace("患者名", patName);
                    } else {
                      // 患者名がない → 全体を空にする
                      value = "";
                    }
                  }

                  // 「患者名」が無いのに患者名が存在する → エラー
                  else if (hasPatName) {
                    value = "変換エラー";
                  }
                }
              }
              // mod #12239 スケジュール表画面のフラグ表現で帳票では出力できないものがある sunsy end
              if (value != null && !"null".equals(value)) {
                value = reportServiceImpl.addLineBreak(value, param);
                // add #12536 機器保守.日常点検(詳細無し).点検日を集計単位に含んでいるとシステムエラー limingzhe start
                if(value.equals(String.valueOf(info.get(param.getDataCode()))) && !(info.get(param.getDataCode()) instanceof String)) continue;
                // add #12536 機器保守.日常点検(詳細無し).点検日を集計単位に含んでいるとシステムエラー limingzhe end
                info.put(param.getDataCode(), value);
              }
            }
          }
          reportInfoForTempl.put(sqlCode, tmpList);
          // mod #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe end
        }
      });

      // mod #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe start
      //paramsOutTemplForCount = reportServiceImpl.paramsReplaceTmpValue(paramsOutTemplForCount, reportInfoForOutTempl);
      paramsOutTemplForCount = reportServiceImpl.paramsReplaceSqlCode(paramsOutTemplForCount, reportInfoForOutTempl);
      // mod #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe end
      reportInfoForOutTempl = reportServiceImpl.getChangeList(reportInfoForOutTempl, paramsOutTemplForCount);
    }
    long endTimegetReportInfoInTempl = System.currentTimeMillis();

    // 集計帳票で集計範囲外の単位項目の値を埋め込む処理
    Map<Long, List<Map<String, Object>>> reportInfoForOutTemplNoCount = new HashMap<>();

    long startTimegetReportInfoNoCount = System.currentTimeMillis();
    if(paramsOutTemplNoCount != null && paramsOutTemplNoCount.size() > 0){

      // mod #11276 キー日付に対するデータ引き当て仕様対応 高　start
      if (dataKey.get("reportClass").equals(9)) {
        ReportZipFile reportZipFile = getReportZip(mstReport);
        String reportXml = getReportXml(mstReport, reportZipFile);
        Map<String, List<ReportXmlParam>> paramsGroup = new HashMap<>();
        paramsGroup.put("Other", new ArrayList<ReportXmlParam>());
        // 指示
        Map<String, List<ReportXmlParam>> paramsGroupInd = new HashMap<>();
        paramsGroupInd.put("Ind", new ArrayList<ReportXmlParam>());
        // 実績
        Map<String, List<ReportXmlParam>> paramsGroupRst = new HashMap<>();
        paramsGroupRst.put("Rst", new ArrayList<ReportXmlParam>());
        // 処方
        Map<String, List<ReportXmlParam>> paramsGroupIsu = new HashMap<>();
        paramsGroupIsu.put("Isu", new ArrayList<ReportXmlParam>());
        // 処方(最新)
        Map<String, List<ReportXmlParam>> paramsGroupIsuNew = new HashMap<>();
        paramsGroupIsuNew.put("IsuNew", new ArrayList<ReportXmlParam>());
        for (ReportXmlParam reParam: paramsOutTemplNoCount){
          if (!reParam.getDataPath().contains("指示")
            && !reParam.getDataPath().contains("実績")
            && !reParam.getDataPath().contains("処方")
            && !reParam.getDataPath().contains("処方(最新)")) {
            paramsGroup.get("Other").add(reParam);
          } else {
            groupInfoIntroductionReportParam(reParam, paramsGroupInd, paramsGroupRst, paramsGroupIsu, paramsGroupIsuNew);
          }
        }
        // Other
        selectReportInfoIntroductionReportTmplOut(reportXml, paramsGroup, dataKey, mstReport.getFacilityCd(), reportInfoForOutTemplNoCount);
        // 指示 (paramsGroupInd)
        selectReportInfoIntroductionReportTmplOut(reportXml, paramsGroupInd, dataKey, mstReport.getFacilityCd(), reportInfoForOutTemplNoCount);
        // 実績 (paramsGroupRst)
        selectReportInfoIntroductionReportTmplOut(reportXml, paramsGroupRst, dataKey, mstReport.getFacilityCd(), reportInfoForOutTemplNoCount);
        // 処方 (paramsGroupIsu)
        selectReportInfoIntroductionReportTmplOut(reportXml, paramsGroupIsu, dataKey, mstReport.getFacilityCd(), reportInfoForOutTemplNoCount);
        // 処方(最新) (paramsGroupIsuNew)
        selectReportInfoIntroductionReportTmplOut(reportXml, paramsGroupIsuNew, dataKey, mstReport.getFacilityCd(), reportInfoForOutTemplNoCount);
      } else {
        reportInfoForOutTemplNoCount = getReportInfo(paramsOutTemplNoCount, dataKey);
      }
//      reportInfoForOutTemplNoCount = getReportInfo(paramsOutTemplNoCount, dataKey);
      // mod #11276 キー日付に対するデータ引き当て仕様対応 高　end
      // add #10531 検査日と検査区分がフィルタを超えて繰り返される limingzhe start
      reportServiceImpl.filterReportInfobyParam(paramsOutTemplNoCount, reportInfoForOutTemplNoCount);
      // add #10531 検査日と検査区分がフィルタを超えて繰り返される limingzhe end
      getMoveInOutTotalInfo(
        reportInfoForOutTemplNoCount,
        String.valueOf(dataKey.get(ReportConstant.ReportDataKey.DATE_FROM)),
        String.valueOf(dataKey.get(ReportConstant.ReportDataKey.DATE_TO)),
        "日",
        // mod #12194 機器保守項目のフィルタ設定が帳票出力時に反映しない limingzhe start
        //"yyyy-MM-dd"
        "yyyy/MM/dd"
        // mod #12194 機器保守項目のフィルタ設定が帳票出力時に反映しない limingzhe end
      );
      // add #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe start
      if(dataKey.get("specifyDate") == null){
        if (dataKey.containsKey(ReportConstant.ReportDataKey.DATE) && !StringUtils.isEmpty(dataKey.get(ReportConstant.ReportDataKey.DATE))) {
          dataKey.put("specifyDate", dataKey.get(ReportConstant.ReportDataKey.DATE).toString().replace("/", "").replace("-", ""));
        }
      }
      // add #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe end
      List<Map<String, Object>> rec = reportServiceImpl.getPrintedInfo(paramsOutTemplNoCount, dataKey, reportInfoForOutTemplNoCount);
      reportInfoForOutTemplNoCount.put(PRINT_INFO_CODE, rec);

      // mod #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe start
      //paramsOutTemplNoCount = reportServiceImpl.paramsReplaceTmpValue(paramsOutTemplNoCount, reportInfoForOutTemplNoCount);
      paramsOutTemplNoCount = reportServiceImpl.paramsReplaceSqlCode(paramsOutTemplNoCount, reportInfoForOutTemplNoCount);
      // mod #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe end

      reportInfoForOutTemplNoCount = reportServiceImpl.getChangeList(reportInfoForOutTemplNoCount, paramsOutTemplNoCount);

      // 集計帳票で集計範囲外の最大ページ数
      int pageOtherNum = 0; // ページあたりに表示される最大数
      for (ReportXmlParam param : paramsOutTemplNoCount) {
        int pNumByPage = 0;
        Long sqlCode;
        if(param.getSqlCode() != null && param.getSqlCode().equals("")){
          sqlCode=Long.valueOf(0);
        }else{
          sqlCode = Long.valueOf(param.getSqlCode());
        }
        List<Map<String, Object>> filteredList = reportServiceImpl.filterReportInfo(param, reportInfoForOutTemplNoCount.get(sqlCode));
        int dataNum = filteredList != null ? filteredList.size() : 0;
        if(param.getReportXmlGroup() != null){
          if(param.getReportXmlGroup().getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_YES){
            int repeatMax = param.getReportXmlGroup().getRepeatMax();
            pNumByPage = dataNum / repeatMax + ((dataNum % repeatMax) > 0 ? 1 : 0);
          } else {
            if(dataNum > 0) pNumByPage = 1;
          }
        } else {
          if(dataNum > 0) pNumByPage = 1;
        }
        if(pNumByPage > pageOtherNum) pageOtherNum = pNumByPage;
      }
      System.err.println("***********************************************");
      System.err.println("集計帳票で集計範囲外のページング数の計算：" + pageOtherNum);
      System.err.println("***********************************************");
      // 最大ページ数判定
      if (pageOtherNum > SET_MAX_PAGE) {
        // 指定例外のスロー、メッセージの指定を促す
        throw new NtssException("ExceedingMaxPageSetting," + pageOtherNum);
      }
    }
    long endTimegetReportInfoNoCount = System.currentTimeMillis();

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(mstReport.getFacilityCd());
    long executionTimegetReportInfoInTempl = (endTimegetReportInfoInTempl - startTimegetReportInfoInTempl);
    System.err.println("getReportInfoInTempl total: " + executionTimegetReportInfoInTempl + " （ms）");
    eventLogMessage.setLogMessage("複数集計 getReportInfoInTempl total: " + executionTimegetReportInfoInTempl + " （ms）");
    logService.log(LogLevel.INFO, eventLogMessage,LoggingConstant.FUNCTION_CODE.FUNC_REPORT_MENU, LoggingConstant.SERVICE_NAME.FNSI, null);
    long executionTimegetReportInfoNoCount = (endTimegetReportInfoNoCount - startTimegetReportInfoNoCount);
    System.err.println("getReportInfoNoCount total: " + executionTimegetReportInfoNoCount + " （ms）");
    eventLogMessage.setLogMessage("複数集計 getReportInfoNoCount total: " + executionTimegetReportInfoNoCount + " （ms）");
    logService.log(LogLevel.INFO, eventLogMessage,LoggingConstant.FUNCTION_CODE.FUNC_REPORT_MENU, LoggingConstant.SERVICE_NAME.FNSI, null);

    long startTimegetKeyValueInTempl = System.currentTimeMillis();
    Map<String, String> reportOutputInfoForOutTempl = convertDataCodeToIdForTotal(paramsInTempl, paramsOutTemplForCount, reportInfoForTempl, dataKeyOutTempl, totalTable, tmplRepeat);
    // 計算式をもとに算出した結果を適用するidとclassのMapを作成する
    calcResult.putAll(reportServiceImpl.getCalcResult(paramsOutTemplForCount, reportInfoForOutTempl, reportOutputInfoForOutTempl));
    if (Integer.parseInt(tmplRepeat.get("repeatCountH").toString()) > 1 && Integer.parseInt(tmplRepeat.get("repeatCountV").toString()) > 1) {
      outPutHtml.putAll(reportOutputInfoForOutTempl);
    }
    long endTimegetKeyValueInTempl = System.currentTimeMillis();

    long startTimegetKeyValueNoCount = System.currentTimeMillis();
    Map<String, String> reportOutputInfoForOutTempl2 = convertDataCodeToId(paramsOutTemplNoCount, reportInfoForOutTemplNoCount, mstReport.getReportClass(), mstReport.getReportType(), patIdToCMap, dataKey);
    // 計算式をもとに算出した結果を適用するidとclassのMapを作成する
    calcResult.putAll(reportServiceImpl.getCalcResult(paramsOutTemplNoCount, reportInfoForOutTemplNoCount, reportOutputInfoForOutTempl2));
    if (reportOutputInfoForOutTempl2.size() > 0) {
      outPutHtml.putAll(reportOutputInfoForOutTempl2);
    }

    // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe start
    ReportCommonUtil.pageAndPageCount(outPutHtml,paramsOutTemplNoCount,dataKey);
    // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe end
    // mod #12125 文字列型の組み合わせが正しく表示されない場合がある limingzhe start
//    // add #11738 印刷情報を使った計算式があると改頁やPDF出力が失敗する 高 start
//    // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe start
//    int totalPages = getPageCount(outPutHtml);
//    // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe end
//    for (ReportXmlParam reportXmlParam : paramsOutTempl){
//      if (reportXmlParam.getFormula().contains(ReportConstant.ReportPrintedInfo.TOTALPAGES)
//        && reportXmlParam.getFormula().contains(ReportConstant.ReportPrintedInfo.CURRENTPAGE)) {
//        if(totalPages > 0) outPutHtml.remove(reportXmlParam.getId());
//        for (int i = 1; i <= totalPages ; i++) {
//          String printedInfo = reportXmlParam.getFormula()
//            .replace(ReportConstant.ReportPrintedInfo.CURRENTPAGE,String.valueOf(i))
//            .replace(ReportConstant.ReportPrintedInfo.TOTALPAGES,String.valueOf(totalPages));
//          printedInfo = parseExcelStyle(printedInfo);
//          outPutHtml.put(String.format("%d%s%s",i,MULTIPLE_PAGES_SEPARATOR,reportXmlParam.getId()), printedInfo);
//        }
//      }
//    }
//    // add #11738 印刷情報を使った計算式があると改頁やPDF出力が失敗する 高 end
    reportServiceImpl.getPagesForExcel(outPutHtml,paramsOutTempl);
    // mod #12125 文字列型の組み合わせが正しく表示されない場合がある limingzhe end
    // add #11299 「##=」型の計算式で「[##データ項目]」を参照するとエラーになる 高 start
    paramsOutTemplBk.addAll(paramsOutTemplForCount);
    paramsOutTemplBk.addAll(paramsOutTemplNoCount);
    // add #11299 「##=」型の計算式で「[##データ項目]」を参照するとエラーになる 高 end
    long endTimegetKeyValueNoCount = System.currentTimeMillis();

    long executionTimegetKeyValueInTempl = (endTimegetKeyValueInTempl - startTimegetKeyValueInTempl);
    System.err.println("getKeyValueInTempl总耗时 total: " + executionTimegetKeyValueInTempl + " （ms）");
    eventLogMessage.setLogMessage("複数集計 getKeyValueInTempl总耗时 total: " + executionTimegetKeyValueInTempl + " （ms）");
    logService.log(LogLevel.INFO, eventLogMessage,LoggingConstant.FUNCTION_CODE.FUNC_REPORT_MENU, LoggingConstant.SERVICE_NAME.FNSI, null);
    long executionTimegetKeyValueNoCount = (endTimegetKeyValueNoCount - startTimegetKeyValueNoCount);
    System.err.println("getKeyValueNoCount total: " + executionTimegetKeyValueNoCount + " （ms）");
    eventLogMessage.setLogMessage("複数集計 getKeyValueNoCount total: " + executionTimegetKeyValueNoCount + " （ms）");
    logService.log(LogLevel.INFO, eventLogMessage,LoggingConstant.FUNCTION_CODE.FUNC_REPORT_MENU, LoggingConstant.SERVICE_NAME.FNSI, null);
  }

  // add #11276 キー日付に対するデータ引き当て仕様対応 高　start
  /**
   * dataPath の内容に基づいて、帳票パラメータを対応するグループに振り分ける処理。
   *
   * 分類ルール：
   * ・「指示」を含む場合 → Ind グループ
   * ・「実績」を含む場合 → Rst グループ
   * ・「処方(最新)」を含む場合 → IsuNew グループ
   * ・「処方」を含む場合 → Isu グループ
   *
   * ※「処方(最新)」は「処方」よりも先に判定しないと誤判定されるため、判定順に注意すること。
   *
   * @param reParam         帳票XMLパラメータ
   * @param paramsGroupInd 指示用パラメータグループ
   * @param paramsGroupRst 実績用パラメータグループ
   * @param paramsGroupIsu 処方用パラメータグループ
   * @param paramsGroupIsuNew 最新処方用パラメータグループ
   */
  private void groupInfoIntroductionReportParam(
    ReportXmlParam reParam,
    Map<String, List<ReportXmlParam>> paramsGroupInd,
    Map<String, List<ReportXmlParam>> paramsGroupRst,
    Map<String, List<ReportXmlParam>> paramsGroupIsu,
    Map<String, List<ReportXmlParam>> paramsGroupIsuNew
  ) {
    String dataPath = reParam.getDataPath();
    if (dataPath == null) {
      return;
    }

    if (dataPath.contains("指示")) {
      paramsGroupInd.get("Ind").add(reParam);
    } else if (dataPath.contains("実績")) {
      paramsGroupRst.get("Rst").add(reParam);
    } else if (dataPath.contains("処方(最新)")) {
      paramsGroupIsuNew.get("IsuNew").add(reParam);
    } else if (dataPath.contains("処方")) {
      paramsGroupIsu.get("Isu").add(reParam);
    }
  }
  /**
   *
   * ・紹介状　※常にテンプレート外
   *
   * tmpl（帳票テンプレート）外のデータを取得・編集する処理。
   *
   * 帳票XMLに定義されたパラメータ情報および抽出条件に基づき、
   * 患者単位で必要な帳票出力用データをデータベースから取得する。
   *
   * また、帳票種別（指示／実績／処方 等）に応じて、
   * key日付を基準とした前回／後回データの抽出制御を行い、
   * 取得した結果を帳票出力用データ構造に変換・統合する。
   *
   * 本処理は tmpl 内のSQL定義では取得できないデータ
   * （＝tmpl外データ）を補完する目的で実行される。
   *
   * @param reportXml   帳票テンプレートXML
   * @param paramsGroup 帳票パラメータのグルーピング情報
   * @param dataKey     帳票抽出用の検索キー
   * @param facilityCd  施設コード
   * @param reportInfo  帳票出力用データ格納先
   */
  private void selectReportInfoIntroductionReportTmplOut(String reportXml,
                                                         Map<String, List<ReportXmlParam>> paramsGroup,
                                                         Map<String, Object> dataKey,
                                                         String facilityCd,
                                                         Map<Long, List<Map<String, Object>>> reportInfo){
    // 帳票XMLからパラメータ定義を取得
    List<ReportXmlParam> params = ReportUtils.getParamElements(reportXml);
    // 実行対象となるSQLコード一覧
    List<String> sqlCodes = new ArrayList<>();
    // 元の検索キーをコピー（後続処理で書き換えるため）
    Map<String, Object> dataKeyNew = new HashMap<>();
    dataKeyNew.putAll(dataKey);
    // ord_main の ord_no（前回／後回）格納用
    List<Long> ordNoSNew = new ArrayList<>();
    // ord_prescription の ord_prescription_no （前回）格納用
    List<Long> ordPrescriptionNoSNew = new ArrayList<>();
    // 繰り返し出力対象の帳票パラメータ
    List<ReportXmlParam> reportParamsNew = new ArrayList<>();
    // 当日（yyyyMMdd形式）
    String todayYmd = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
    // ===== 指示 =====
    if (paramsGroup.get("Ind") != null) {
      // 対象SQLコードを取得
      sqlCodes = getSqlCode(paramsGroup.get("Ind"));
      // 繰り返し出力対象のパラメータのみ抽出
      reportParamsNew = paramsGroup.get("Ind").stream().filter(p -> p.getReportXmlTmplRepeat() != null && p.getReportXmlTmplRepeat().getId() != "").collect(toList());
      // 繰り返し指定がある場合、fromDate を当日に設定
      if (reportParamsNew.size() != 0) dataKeyNew.put("fromDate",todayYmd);
      // key日付以降で最も近い ord_main を取得（後回）
      Long ordNoNew = rdMainDao.selectOrdMainNearestFutureByKeyDate(Long.parseLong(String.valueOf(dataKeyNew.get("patId"))),
        String.valueOf(dataKeyNew.get("fromDate")).replace("/","").replace("-",""),
        facilityCd);
      ordNoSNew.add(ordNoNew);
      dataKeyNew.put("ordNos",ordNoSNew);
    }
    // ===== 実績 =====
    else if (paramsGroup.get("Rst") != null) {
      // 対象SQLコードを取得
      sqlCodes = getSqlCode(paramsGroup.get("Rst"));
      // 繰り返し出力対象のパラメータのみ抽出
      reportParamsNew = paramsGroup.get("Rst").stream().filter(p -> p.getReportXmlTmplRepeat() != null && p.getReportXmlTmplRepeat().getId() != "").collect(toList());
      // 繰り返し指定がある場合、fromDate を当日に設定
      if (reportParamsNew.size() != 0) dataKeyNew.put("fromDate",todayYmd);
      // key日付以前で最も近い ord_main を取得（前回）
      Long ordNoNew = rdMainDao.selectOrdMainNearestPastByKeyDate(Long.parseLong(String.valueOf(dataKeyNew.get("patId"))),
        String.valueOf(dataKeyNew.get("fromDate")).replace("/","").replace("-",""),
        facilityCd);
      ordNoSNew.add(ordNoNew);
      dataKeyNew.put("ordNos",ordNoSNew);
    }
    // ===== 処方 =====
    else if (paramsGroup.get("Isu") != null) {
      // 対象SQLコードを取得
      sqlCodes = getSqlCode(paramsGroup.get("Isu"));
      // 繰り返し出力対象のパラメータのみ抽出
      reportParamsNew = paramsGroup.get("Isu").stream().filter(p -> p.getReportXmlTmplRepeat() != null && p.getReportXmlTmplRepeat().getId() != "").collect(toList());
      // 繰り返し指定がある場合、fromDate を当日に設定
      if (reportParamsNew.size() != 0) dataKeyNew.put("fromDate",todayYmd);
      // key日付以前で最も近い ord_prescription を取得（前回）
      Long ordPrescriptionNoNew = ordPrescriptionDao.selectOrdPrescriptionNearestPastByKeyDateAndCd(Long.parseLong(String.valueOf(dataKeyNew.get("patId"))),
        String.valueOf(dataKeyNew.get("fromDate")).replace("/","").replace("-",""),
        facilityCd);
      ordPrescriptionNoSNew.add(ordPrescriptionNoNew);
      dataKeyNew.put("ordPrescriptionNos",ordPrescriptionNoSNew);
    }
    // ===== 処方(最新) =====
    else if (paramsGroup.get("IsuNew") != null) {
      // 対象SQLコードを取得
      sqlCodes = getSqlCode(paramsGroup.get("IsuNew"));
      // 繰り返し出力対象のパラメータのみ抽出
      reportParamsNew = paramsGroup.get("IsuNew").stream().filter(p -> p.getReportXmlTmplRepeat() != null && p.getReportXmlTmplRepeat().getId() != "").collect(toList());
      // 繰り返し指定がある場合、fromDate を当日に設定
      if (reportParamsNew.size() != 0) dataKeyNew.put("fromDate",todayYmd);
      // key日付以前で最も近い処方の fromDate を取得
      String issueDateNew = ordPrescriptionDao.selectOrdPrescriptionNearestPastByKeyDateAndFromDate(Long.parseLong(String.valueOf(dataKeyNew.get("patId"))),
        String.valueOf(dataKeyNew.get("fromDate")).replace("/","").replace("-",""),
        String.valueOf(dataKeyNew.get("facilityCd")));
      // 取得した fromDate で再設定
      dataKeyNew.put("fromDate",issueDateNew);
      // key日付以前で最も近い ord_prescription を取得（前回）
      Long ordPrescriptionNoNew = ordPrescriptionDao.selectOrdPrescriptionNearestPastByKeyDateAndCd(Long.parseLong(String.valueOf(dataKeyNew.get("patId"))),
        String.valueOf(dataKeyNew.get("fromDate")).replace("/","").replace("-",""),
        facilityCd);
      ordPrescriptionNoSNew.add(ordPrescriptionNoNew);
      dataKeyNew.put("ordPrescriptionNos",ordPrescriptionNoSNew);
    } else {
      // 対象SQLコードを取得
      sqlCodes = getSqlCode(paramsGroup.get("Other"));
    }

    // SQL 実行
    Map<Long, List<Map<String, Object>>> reportInfoIndex = sysDataSetService.getSqlDataForOnePatient(sqlCodes, dataKeyNew);

    // 印字用情報の生成
    List<Map<String, Object>> rec = reportServiceImpl.getPrintedInfo(params, dataKey, reportInfoIndex);
    reportInfoIndex.put(PRINT_INFO_CODE, rec);
    // テンプレート値の置換
    params = reportServiceImpl.paramsReplaceTmpValue(params, reportInfoIndex);
    // 帳票出力用にリスト構造を変換
    reportInfoIndex = reportServiceImpl.getChangeList(reportInfoIndex, params);

    // 既存の帳票出力結果にマージ
    for (Long key : reportInfoIndex.keySet()) {
      if (reportInfo.containsKey(key)) {
        reportInfo.get(key).addAll(reportInfoIndex.get(key));
      } else {
        reportInfo.put(key, reportInfoIndex.get(key));
      }
    }
  }
  // add #11276 キー日付に対するデータ引き当て仕様対応 高　end

  private void createReportOutTemplate(
    MstReport mstReport,
    List<ReportXmlParam> paramsOutTemplNoCount,
    Map<String, Object> dataKey,
    Map<String, Long> patIdToCMap,
    Map<String, String> outPutHtml,
    Map<String, String> calcResult,
    // add #11299 「##=」型の計算式で「[##データ項目]」を参照するとエラーになる 高 start
    List<ReportXmlParam> paramsOutTemplBk
    // add #11299 「##=」型の計算式で「[##データ項目]」を参照するとエラーになる 高 end
  ){
    // add #12324 紹介状の出力時にpat_eventを参照する zhao start
    getNoTemplateDataKey(dataKey);
    // add #12324 紹介状の出力時にpat_eventを参照する zhao end
    // 集計帳票で集計範囲外の単位項目の値を埋め込む処理
    Map<Long, List<Map<String, Object>>> reportInfoForOutTemplNoCount = new HashMap<>();
    // add #11738 印刷情報を使った計算式があると改頁やPDF出力が失敗する 高 start
    List<ReportXmlParam> paramsOutTemplNo = new ArrayList<>();
    paramsOutTemplNo.addAll(paramsOutTemplNoCount);
    // add #11738 印刷情報を使った計算式があると改頁やPDF出力が失敗する 高 end

    long startTimegetReportInfoNoCount = System.currentTimeMillis();
    if(paramsOutTemplNoCount != null && paramsOutTemplNoCount.size() > 0){
      // mod #12163 "一般撮影.放射線検査予定"項目が、複数集計帳票だと出力されない limingzhe start
      // reportInfoForOutTemplNoCount = getReportInfo(paramsOutTemplNoCount, dataKey);
      List<String> sqlCodes = getSqlCode(paramsOutTemplNoCount);
      Map<String, List<String>> sqlCodesGroup = new HashMap<>();
      // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe start
      sqlCodesGroup.put("mongo_multiple", new ArrayList<String>());
      sqlCodesGroup.put("mongo_single", new ArrayList<String>());
      // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe end
      sqlCodesGroup.put("patId", new ArrayList<String>());
      sqlCodesGroup.put("ordNo", new ArrayList<String>());
      // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe start
      sqlCodesGroup.put("ordPrescriptionNo", new ArrayList<String>());
      // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe end
      sqlCodesGroup.put("multiple", new ArrayList<String>());
      sqlCodesGroup.put("Other", new ArrayList<String>());
      for(String sqlCode: sqlCodes){
        // mod #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe start
//        if(sysDataSetService.isMongDBSqlSearch(Long.parseLong(sqlCode)))
//          sqlCodesGroup.get("mongo").add(sqlCode);
        if(sysDataSetService.isMongDBSqlSearch(Long.parseLong(sqlCode))){
          if(sysDataSetService.distinParaOnlybyParam(Long.parseLong(sqlCode), "patIds"))
            sqlCodesGroup.get("mongo_multiple").add(sqlCode);
          else
            sqlCodesGroup.get("mongo_single").add(sqlCode);
        }
        // mod #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe end
        else if(sysDataSetService.distinParaOnlybyParam(Long.parseLong(sqlCode), "patIds"))
          sqlCodesGroup.get("multiple").add(sqlCode);
        else if(sysDataSetService.distinParaOnlybyParam(Long.parseLong(sqlCode), "ordNos"))
          sqlCodesGroup.get("multiple").add(sqlCode);
        else if(sysDataSetService.distinParaOnlybyParam(Long.parseLong(sqlCode), "ordNo"))
          sqlCodesGroup.get("ordNo").add(sqlCode);
        // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe start
        else if(sysDataSetService.distinParaOnlybyParam(Long.parseLong(sqlCode), "ordPrescriptionNo"))
          sqlCodesGroup.get("ordPrescriptionNo").add(sqlCode);
        // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe end
        else if(sysDataSetService.distinParaOnlybyPatId(Long.parseLong(sqlCode)))
          sqlCodesGroup.get("patId").add(sqlCode);
        else
          sqlCodesGroup.get("Other").add(sqlCode);
      }
      Map<String, List<ReportXmlParam>> paramsGroup = new HashMap<>();
      // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe start
      paramsGroup.put("mongo_multiple", new ArrayList<ReportXmlParam>());
      paramsGroup.put("mongo_single", new ArrayList<ReportXmlParam>());
      // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe end
      paramsGroup.put("patId", new ArrayList<ReportXmlParam>());
      paramsGroup.put("ordNo", new ArrayList<ReportXmlParam>());
      // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe start
      paramsGroup.put("ordPrescriptionNo", new ArrayList<ReportXmlParam>());
      // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe end
      paramsGroup.put("multiple", new ArrayList<ReportXmlParam>());
      // add #11276 キー日付に対するデータ引き当て仕様対応 高　start
      if (dataKey.get("reportClass").equals(9)) {
        ReportZipFile reportZipFile = getReportZip(mstReport);
        String reportXml = getReportXml(mstReport, reportZipFile);
        // 指示
        Map<String, List<ReportXmlParam>> paramsGroupInd = new HashMap<>();
        paramsGroupInd.put("Ind", new ArrayList<ReportXmlParam>());
        // 実績
        Map<String, List<ReportXmlParam>> paramsGroupRst = new HashMap<>();
        paramsGroupRst.put("Rst", new ArrayList<ReportXmlParam>());
        // 処方
        Map<String, List<ReportXmlParam>> paramsGroupIsu = new HashMap<>();
        paramsGroupIsu.put("Isu", new ArrayList<ReportXmlParam>());
        // 処方(最新)
        Map<String, List<ReportXmlParam>> paramsGroupIsuNew = new HashMap<>();
        paramsGroupIsuNew.put("IsuNew", new ArrayList<ReportXmlParam>());
        for (ReportXmlParam reParam: paramsOutTemplNoCount){
          if (!reParam.getDataPath().contains("指示")
            && !reParam.getDataPath().contains("実績")
            && !reParam.getDataPath().contains("処方")
            && !reParam.getDataPath().contains("処方(最新)")) {
            if(sqlCodesGroup.get("mongo_multiple").contains(reParam.getSqlCode())) {
              paramsGroup.get("mongo_multiple").add(reParam);
            }
            else if(sqlCodesGroup.get("mongo_single").contains(reParam.getSqlCode())) {
              paramsGroup.get("mongo_single").add(reParam);
            }
            else if(sqlCodesGroup.get("patId").contains(reParam.getSqlCode())) {
              paramsGroup.get("patId").add(reParam);
            }
            else if(sqlCodesGroup.get("ordNo").contains(reParam.getSqlCode())) {
              paramsGroup.get("ordNo").add(reParam);
            }
            else if(sqlCodesGroup.get("ordPrescriptionNo").contains(reParam.getSqlCode())) {
              paramsGroup.get("ordPrescriptionNo").add(reParam);
            }
            else {
              paramsGroup.get("multiple").add(reParam);
            }
          } else {
            groupInfoIntroductionReportParam(reParam, paramsGroupInd, paramsGroupRst, paramsGroupIsu, paramsGroupIsuNew);
          }
        }
        // 指示 (paramsGroupInd)
        selectReportInfoIntroductionReportTmplOut(reportXml, paramsGroupInd, dataKey, mstReport.getFacilityCd(), reportInfoForOutTemplNoCount);
        // 実績 (paramsGroupRst)
        selectReportInfoIntroductionReportTmplOut(reportXml, paramsGroupRst, dataKey, mstReport.getFacilityCd(), reportInfoForOutTemplNoCount);
        // 処方 (paramsGroupIsu)
        selectReportInfoIntroductionReportTmplOut(reportXml, paramsGroupIsu, dataKey, mstReport.getFacilityCd(), reportInfoForOutTemplNoCount);
        // 処方(最新) (paramsGroupIsuNew)
        selectReportInfoIntroductionReportTmplOut(reportXml, paramsGroupIsuNew, dataKey, mstReport.getFacilityCd(), reportInfoForOutTemplNoCount);
      } else {
        for (ReportXmlParam reParam: paramsOutTemplNoCount){
          if(sqlCodesGroup.get("mongo_multiple").contains(reParam.getSqlCode())) {
            paramsGroup.get("mongo_multiple").add(reParam);
          }
          else if(sqlCodesGroup.get("mongo_single").contains(reParam.getSqlCode())) {
            paramsGroup.get("mongo_single").add(reParam);
          }
          else if(sqlCodesGroup.get("patId").contains(reParam.getSqlCode())) {
            paramsGroup.get("patId").add(reParam);
          }
          else if(sqlCodesGroup.get("ordNo").contains(reParam.getSqlCode())) {
            paramsGroup.get("ordNo").add(reParam);
          }
          else if(sqlCodesGroup.get("ordPrescriptionNo").contains(reParam.getSqlCode())) {
            paramsGroup.get("ordPrescriptionNo").add(reParam);
          }
          else {
            paramsGroup.get("multiple").add(reParam);
          }
        }
      }
      // add #11276 キー日付に対するデータ引き当て仕様対応 高　end
      // del #11276 キー日付に対するデータ引き当て仕様対応 高　start
//      for (ReportXmlParam reParam: paramsOutTemplNoCount){
//        // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe start
//        if(sqlCodesGroup.get("mongo_multiple").contains(reParam.getSqlCode())) {
//          paramsGroup.get("mongo_multiple").add(reParam);
//        }
//        else if(sqlCodesGroup.get("mongo_single").contains(reParam.getSqlCode())) {
//          paramsGroup.get("mongo_single").add(reParam);
//        }
//        // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe end
//        else if(sqlCodesGroup.get("patId").contains(reParam.getSqlCode())) {
//          paramsGroup.get("patId").add(reParam);
//        }
//        else if(sqlCodesGroup.get("ordNo").contains(reParam.getSqlCode())) {
//          paramsGroup.get("ordNo").add(reParam);
//        }
//        // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe start
//        else if(sqlCodesGroup.get("ordPrescriptionNo").contains(reParam.getSqlCode())) {
//          paramsGroup.get("ordPrescriptionNo").add(reParam);
//        }
//        // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe end
//        else {
//          paramsGroup.get("multiple").add(reParam);
//        }
//      }
      // del #11276 キー日付に対するデータ引き当て仕様対応 高　end
      if(paramsGroup.get("multiple").size()>0){
        // mod #11276 キー日付に対するデータ引き当て仕様対応 高　start
        if (dataKey.get("reportClass").equals(9)) {
          Map<Long, List<Map<String, Object>>> reportInfoIndex = getReportInfo(paramsGroup.get("multiple"), dataKey);
          for (Long key : reportInfoIndex.keySet()) {
            if (reportInfoForOutTemplNoCount.containsKey(key)) {
              reportInfoForOutTemplNoCount.get(key).addAll(reportInfoIndex.get(key));
            } else {
              reportInfoForOutTemplNoCount.put(key, reportInfoIndex.get(key));
            }
          }
        } else {
          reportInfoForOutTemplNoCount = getReportInfo(paramsGroup.get("multiple"), dataKey);
        }
//        reportInfoForOutTemplNoCount = getReportInfo(paramsGroup.get("multiple"), dataKey);
        // mod #11276 キー日付に対するデータ引き当て仕様対応 高　end
      }
      // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe start
      if(paramsGroup.get("mongo_multiple").size()>0){
        Map<String, Object> dataKeyNew = new HashMap<>();
        try {
          dataKeyNew = reportServiceImpl.deepCopyMap(dataKey);
        } catch (IOException e) {
          throw new RuntimeException(e);
        } catch (ClassNotFoundException e) {
          throw new RuntimeException(e);
        }
        dataKeyNew.put(ReportConstant.ReportDataKey.DATE_TO, dataKey.get(ReportConstant.ReportDataKey.DATE_FROM));
        Map<Long, List<Map<String, Object>>> reportInfoIndex = getReportInfo(paramsGroup.get("mongo_multiple"), dataKeyNew);
        for (Long key : reportInfoIndex.keySet()) {
          if (reportInfoForOutTemplNoCount.containsKey(key)) {
            reportInfoForOutTemplNoCount.get(key).addAll(reportInfoIndex.get(key));
          } else {
            reportInfoForOutTemplNoCount.put(key, reportInfoIndex.get(key));
          }
        }
      }
      if(paramsGroup.get("mongo_single").size()>0) {
        List<Long> patIdList = (List<Long>)dataKey.getOrDefault(ReportConstant.ReportDataKey.PAT_IDS, new ArrayList<>());
        for (int i = 0; i < patIdList.size(); i++) {
          Map<String, Object> dataKeyNew = new HashMap<>();
          try {
            dataKeyNew = reportServiceImpl.deepCopyMap(dataKey);
          } catch (IOException e) {
            throw new RuntimeException(e);
          } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
          }
          dataKeyNew.put(ReportConstant.ReportDataKey.PAT_ID, patIdList.get(i));
          dataKeyNew.put(ReportConstant.ReportDataKey.DATE_TO, dataKey.get(ReportConstant.ReportDataKey.DATE_FROM));
          Map<Long, List<Map<String, Object>>> reportInfoIndex = getReportInfo(paramsGroup.get("mongo_single"), dataKeyNew);
          for (Long key : reportInfoIndex.keySet()) {
            if (reportInfoForOutTemplNoCount.containsKey(key)) {
              reportInfoForOutTemplNoCount.get(key).addAll(reportInfoIndex.get(key));
            } else {
              reportInfoForOutTemplNoCount.put(key, reportInfoIndex.get(key));
            }
          }
        }
      }
      // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe end
      if(paramsGroup.get("patId").size()>0) {
        List<Long> patIdList = (List<Long>)dataKey.getOrDefault(ReportConstant.ReportDataKey.PAT_IDS, new ArrayList<>());
        for (int i = 0; i < patIdList.size(); i++) {
          dataKey.put("patId", patIdList.get(i));
          Map<Long, List<Map<String, Object>>> reportInfoIndex = getReportInfo(paramsGroup.get("patId"), dataKey);
          for (Long key : reportInfoIndex.keySet()) {
            if (reportInfoForOutTemplNoCount.containsKey(key)) {
              reportInfoForOutTemplNoCount.get(key).addAll(reportInfoIndex.get(key));
            } else {
              reportInfoForOutTemplNoCount.put(key, reportInfoIndex.get(key));
            }
          }
        }
      }
      if(paramsGroup.get("ordNo").size()>0) {
        List<Long> patIdList = (List<Long>)dataKey.getOrDefault(ReportConstant.ReportDataKey.PAT_IDS, new ArrayList<>());
        List<Map<String, Object>> paramList = reportServiceImpl.getOrdNosbyDataKey(
          String.valueOf(dataKey.get(ReportConstant.ReportDataKey.FACILITY_CD)),
          patIdList,
          String.valueOf(dataKey.get(ReportConstant.ReportDataKey.DATE_FROM)),
          String.valueOf(dataKey.get(ReportConstant.ReportDataKey.DATE_TO))
        );

        for (int i = 0; i < paramList.size(); i++) {
          dataKey.put("patId", paramList.get(i).getOrDefault(ReportConstant.ReportDataKey.PAT_ID, 0));
          List<Long> ordNos = (List<Long>)paramList.get(i).getOrDefault(ReportConstant.ReportDataKey.ORD_NOS, new ArrayList<>());
          for (int j = 0; j < ordNos.size(); j++) {
            dataKey.put("ordNo", ordNos.get(j));
            Map<Long, List<Map<String, Object>>> reportInfoIndex = getReportInfo(paramsGroup.get("ordNo"), dataKey);
            for (Long key : reportInfoIndex.keySet()) {
              if (reportInfoForOutTemplNoCount.containsKey(key)) {
                reportInfoForOutTemplNoCount.get(key).addAll(reportInfoIndex.get(key));
              } else {
                reportInfoForOutTemplNoCount.put(key, reportInfoIndex.get(key));
              }
            }
          }
        }
      }
      // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe start
      if(paramsGroup.get("ordPrescriptionNo").size()>0) {
        List<Long> ordPrescriptionNos = (List<Long>)dataKey.getOrDefault(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NOS, new ArrayList<>());
        for (Long ordPrescriptionNo : ordPrescriptionNos) {
          dataKey.put(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NO, ordPrescriptionNo);
          Map<Long, List<Map<String, Object>>> reportInfoIndex = getReportInfo(paramsGroup.get("ordPrescriptionNo"), dataKey);
          for (Long key : reportInfoIndex.keySet()) {
            if (reportInfoForOutTemplNoCount.containsKey(key)) {
              reportInfoForOutTemplNoCount.get(key).addAll(reportInfoIndex.get(key));
            } else {
              reportInfoForOutTemplNoCount.put(key, reportInfoIndex.get(key));
            }
          }
        }
      }
      // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe end
      // mod #12163 "一般撮影.放射線検査予定"項目が、複数集計帳票だと出力されない limingzhe end
      getMoveInOutTotalInfo(
        reportInfoForOutTemplNoCount,
        String.valueOf(dataKey.get(ReportConstant.ReportDataKey.DATE_FROM)),
        String.valueOf(dataKey.get(ReportConstant.ReportDataKey.DATE_TO)),
        "日",
        // mod #12194 機器保守項目のフィルタ設定が帳票出力時に反映しない limingzhe start
        //"yyyy-MM-dd"
        "yyyy/MM/dd"
        // mod #12194 機器保守項目のフィルタ設定が帳票出力時に反映しない limingzhe end
      );
      List<Map<String, Object>> rec = reportServiceImpl.getPrintedInfo(paramsOutTemplNoCount, dataKey, reportInfoForOutTemplNoCount);
      reportInfoForOutTemplNoCount.put(PRINT_INFO_CODE, rec);

      // add #10531 検査日と検査区分がフィルタを超えて繰り返される limingzhe start
      reportServiceImpl.filterReportInfobyParam(paramsOutTemplNoCount, reportInfoForOutTemplNoCount);
      // add #10531 検査日と検査区分がフィルタを超えて繰り返される limingzhe end

      // mod #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe start
      //paramsOutTemplNoCount = reportServiceImpl.paramsReplaceTmpValue(paramsOutTemplNoCount, reportInfoForOutTemplNoCount);
      paramsOutTemplNoCount = reportServiceImpl.paramsReplaceSqlCode(paramsOutTemplNoCount, reportInfoForOutTemplNoCount);
      // mod #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe end

      reportInfoForOutTemplNoCount = reportServiceImpl.getChangeList(reportInfoForOutTemplNoCount, paramsOutTemplNoCount);

      // 集計帳票で集計範囲外の最大ページ数
      int pageOtherNum = 0; // ページあたりに表示される最大数
      for (ReportXmlParam param : paramsOutTemplNoCount) {
        int pNumByPage = 0;
        Long sqlCode;
        if(param.getSqlCode() != null && param.getSqlCode().equals("")){
          sqlCode=Long.valueOf(0);
        }else{
          sqlCode = Long.valueOf(param.getSqlCode());
        }
        List<Map<String, Object>> filteredList = reportServiceImpl.filterReportInfo(param, reportInfoForOutTemplNoCount.get(sqlCode));
        int dataNum = filteredList != null ? filteredList.size() : 0;
        if(param.getReportXmlGroup() != null){
          if(param.getReportXmlGroup().getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_YES){
            int repeatMax = param.getReportXmlGroup().getRepeatMax();
            pNumByPage = dataNum / repeatMax + ((dataNum % repeatMax) > 0 ? 1 : 0);
          } else {
            if(dataNum > 0) pNumByPage = 1;
          }
        } else {
          if(dataNum > 0) pNumByPage = 1;
        }
        if(pNumByPage > pageOtherNum) pageOtherNum = pNumByPage;
      }
      System.err.println("***********************************************");
      System.err.println("集計帳票で集計範囲外のページング数の計算：" + pageOtherNum);
      System.err.println("***********************************************");
      // 最大ページ数判定
      if (pageOtherNum > SET_MAX_PAGE) {
        // 指定例外のスロー、メッセージの指定を促す
        throw new NtssException("ExceedingMaxPageSetting," + pageOtherNum);
      }
    }
    long endTimegetReportInfoNoCount = System.currentTimeMillis();

    long startTimegetKeyValueNoCount = System.currentTimeMillis();
    Map<String, String> reportOutputInfoForOutTempl2 = convertDataCodeToId(paramsOutTemplNoCount, reportInfoForOutTemplNoCount, mstReport.getReportClass(), mstReport.getReportType(), patIdToCMap, dataKey);
    // 計算式をもとに算出した結果を適用するidとclassのMapを作成する
    calcResult.putAll(reportServiceImpl.getCalcResult(paramsOutTemplNoCount, reportInfoForOutTemplNoCount, reportOutputInfoForOutTempl2));
    if (reportOutputInfoForOutTempl2.size() > 0) {
      outPutHtml.putAll(reportOutputInfoForOutTempl2);
    }

    // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe start
    ReportCommonUtil.pageAndPageCount(outPutHtml,paramsOutTemplNoCount,dataKey);
    // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe end
    // mod #12125 文字列型の組み合わせが正しく表示されない場合がある limingzhe start
//    // add #11738 印刷情報を使った計算式があると改頁やPDF出力が失敗する 高 start
//    // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe start
//    int totalPages = getPageCount(outPutHtml);
//    // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe end
//    for (ReportXmlParam reportXmlParam : paramsOutTemplNo){
//      if (reportXmlParam.getFormula().contains(ReportConstant.ReportPrintedInfo.TOTALPAGES)
//        && reportXmlParam.getFormula().contains(ReportConstant.ReportPrintedInfo.CURRENTPAGE)) {
//        if(totalPages > 0) outPutHtml.remove(reportXmlParam.getId());
//        for (int i = 1; i <= totalPages ; i++) {
//          String printedInfo = reportXmlParam.getFormula()
//            .replace(ReportConstant.ReportPrintedInfo.CURRENTPAGE,String.valueOf(i))
//            .replace(ReportConstant.ReportPrintedInfo.TOTALPAGES,String.valueOf(totalPages));
//          printedInfo = parseExcelStyle(printedInfo);
//          outPutHtml.put(String.format("%d%s%s",i,MULTIPLE_PAGES_SEPARATOR,reportXmlParam.getId()), printedInfo);
//        }
//      }
//    }
//    // add #11738 印刷情報を使った計算式があると改頁やPDF出力が失敗する 高 end
    reportServiceImpl.getPagesForExcel(outPutHtml,paramsOutTemplNo);
    // mod #12125 文字列型の組み合わせが正しく表示されない場合がある limingzhe end
    // add #11299 「##=」型の計算式で「[##データ項目]」を参照するとエラーになる 高 start
    paramsOutTemplBk.addAll(paramsOutTemplNoCount);
    // add #11299 「##=」型の計算式で「[##データ項目]」を参照するとエラーになる 高 end
    long endTimegetKeyValueNoCount = System.currentTimeMillis();

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(mstReport.getFacilityCd());
    long executionTimegetReportInfoNoCount = (endTimegetReportInfoNoCount - startTimegetReportInfoNoCount);
    System.err.println("getReportInfoNoCount total: " + executionTimegetReportInfoNoCount + " （ms）");
    eventLogMessage.setLogMessage("複数集計 getReportInfoNoCount total: " + executionTimegetReportInfoNoCount + " （ms）");
    logService.log(LogLevel.INFO, eventLogMessage,LoggingConstant.FUNCTION_CODE.FUNC_REPORT_MENU, LoggingConstant.SERVICE_NAME.FNSI, null);
    long executionTimegetKeyValueNoCount = (endTimegetKeyValueNoCount - startTimegetKeyValueNoCount);
    System.err.println("getKeyValueNoCount total: " + executionTimegetKeyValueNoCount + " （ms）");
    eventLogMessage.setLogMessage("複数集計 getKeyValueNoCount total: " + executionTimegetKeyValueNoCount + " （ms）");
    logService.log(LogLevel.INFO, eventLogMessage,LoggingConstant.FUNCTION_CODE.FUNC_REPORT_MENU, LoggingConstant.SERVICE_NAME.FNSI, null);
  }

  // add #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe start
  /**
   * テンプレート内のデータキーを取得する.
   *
   * @param dataKey データキー
   * @return テンプレート内のデータキー
   */
  private void getInOfTemplateDataKey(Map<String, Object> dataKey) {
    List<Map<String, Object>> tmplParams = new ArrayList<Map<String, Object>>();
    Map<String, Object> tmplParam = new HashMap<>();
    if (dataKey.containsKey(ReportConstant.ReportDataKey.FACILITY_CD) && !StringUtils.isEmpty(dataKey.get(ReportConstant.ReportDataKey.FACILITY_CD))){
      tmplParam.put(ReportConstant.ReportDataKey.FACILITY_CD, dataKey.get(ReportConstant.ReportDataKey.FACILITY_CD));
    }

    // クール
    if (dataKey.containsKey(ReportConstant.ReportDataKey.KUR_CDS) && !StringUtils.isEmpty(dataKey.get(ReportConstant.ReportDataKey.KUR_CDS))){
      tmplParam.put(ReportConstant.ReportDataKey.KUR_CDS, dataKey.get(ReportConstant.ReportDataKey.KUR_CDS));
    }
    // ベッド
    if (dataKey.containsKey(ReportConstant.ReportDataKey.BED_CDS) && !StringUtils.isEmpty(dataKey.get(ReportConstant.ReportDataKey.BED_CDS))){
      tmplParam.put(ReportConstant.ReportDataKey.BED_CDS, dataKey.get(ReportConstant.ReportDataKey.BED_CDS));
    }

    // データ抽出条件
    if (dataKey.containsKey(ReportConstant.ReportDataKey.DATE) && !StringUtils.isEmpty(dataKey.get(ReportConstant.ReportDataKey.DATE))){
      tmplParam.put(ReportConstant.ReportDataKey.DATE, dataKey.get(ReportConstant.ReportDataKey.DATE));
    }
    if (dataKey.containsKey(ReportConstant.ReportDataKey.DATE_FROM) && !StringUtils.isEmpty(dataKey.get(ReportConstant.ReportDataKey.DATE_FROM))){
      tmplParam.put(ReportConstant.ReportDataKey.DATE_FROM, dataKey.get(ReportConstant.ReportDataKey.DATE_FROM));
    }
    if (dataKey.containsKey(ReportConstant.ReportDataKey.DATE_TO) && !StringUtils.isEmpty(dataKey.get(ReportConstant.ReportDataKey.DATE_TO))){
      tmplParam.put(ReportConstant.ReportDataKey.DATE_TO, dataKey.get(ReportConstant.ReportDataKey.DATE_TO));
    }

    // ダイアライザ
    if (dataKey.containsKey(ReportConstant.ReportDataKey.DIALYZER_IDS) && !StringUtils.isEmpty(dataKey.get(ReportConstant.ReportDataKey.DIALYZER_IDS))){
      tmplParam.put(ReportConstant.ReportDataKey.DIALYZER_IDS, dataKey.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
    }
    // 医療材料
    if (dataKey.containsKey(ReportConstant.ReportDataKey.EQUIPMENT_IDS) && !StringUtils.isEmpty(dataKey.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS))){
      tmplParam.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS, dataKey.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
    }
    // 薬剤
    if (dataKey.containsKey(ReportConstant.ReportDataKey.MEDICINE_IDS) && !StringUtils.isEmpty(dataKey.get(ReportConstant.ReportDataKey.MEDICINE_IDS))){
      tmplParam.put(ReportConstant.ReportDataKey.MEDICINE_IDS, dataKey.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
    }

    // 対象装置
    if (dataKey.containsKey(ReportConstant.ReportDataKey.MACHINE_NOS) && !StringUtils.isEmpty(dataKey.get(ReportConstant.ReportDataKey.MACHINE_NOS))){
      tmplParam.put(ReportConstant.ReportDataKey.MACHINE_NOS, dataKey.get(ReportConstant.ReportDataKey.MACHINE_NOS));
    }
    // 対象患者
    List<Long> patIds = new ArrayList<>();
    if (dataKey.get(ReportConstant.ReportDataKey.PAT_IDS) == null) {
      if(null != dataKey.get(ReportConstant.ReportDataKey.PAT_ID)){
        patIds.add((Long) dataKey.get(ReportConstant.ReportDataKey.PAT_ID));
        dataKey.put(ReportConstant.ReportDataKey.PAT_IDS, patIds);
      }
    } else {
      patIds = (List<Long>) dataKey.get(ReportConstant.ReportDataKey.PAT_IDS);
      if(null == dataKey.get(ReportConstant.ReportDataKey.PAT_ID) && patIds.size() > 0){
        dataKey.put(ReportConstant.ReportDataKey.PAT_ID, patIds.get(0));
      }
    }
    if (dataKey.containsKey(ReportConstant.ReportDataKey.PAT_ID) && !StringUtils.isEmpty(dataKey.get(ReportConstant.ReportDataKey.PAT_ID))){
      tmplParam.put(ReportConstant.ReportDataKey.PAT_ID, dataKey.get(ReportConstant.ReportDataKey.PAT_ID));
    }
    if (dataKey.containsKey(ReportConstant.ReportDataKey.PAT_IDS) && !StringUtils.isEmpty(dataKey.get(ReportConstant.ReportDataKey.PAT_IDS))){
      tmplParam.put(ReportConstant.ReportDataKey.PAT_IDS, dataKey.get(ReportConstant.ReportDataKey.PAT_IDS));
    }

    // オーダ番号
    List<Long> ordNos = new ArrayList<>();
    if (dataKey.get(ReportConstant.ReportDataKey.ORD_NOS) == null) {
      if(null != dataKey.get(ReportConstant.ReportDataKey.ORD_NO)){
        ordNos.add((Long) dataKey.get(ReportConstant.ReportDataKey.ORD_NO));
        dataKey.put(ReportConstant.ReportDataKey.ORD_NOS, ordNos);
      }
    } else {
      ordNos = (List<Long>) dataKey.get(ReportConstant.ReportDataKey.ORD_NOS);
      if(null == dataKey.get(ReportConstant.ReportDataKey.ORD_NO) && ordNos.size() > 0){
        dataKey.put(ReportConstant.ReportDataKey.ORD_NO, ordNos.get(0));
      }
    }
    if (dataKey.containsKey(ReportConstant.ReportDataKey.ORD_NO) && !StringUtils.isEmpty(dataKey.get(ReportConstant.ReportDataKey.ORD_NO))){
      tmplParam.put(ReportConstant.ReportDataKey.ORD_NO, dataKey.get(ReportConstant.ReportDataKey.ORD_NO));
    }
    if (dataKey.containsKey(ReportConstant.ReportDataKey.ORD_NOS) && !StringUtils.isEmpty(dataKey.get(ReportConstant.ReportDataKey.ORD_NOS))){
      tmplParam.put(ReportConstant.ReportDataKey.ORD_NOS, dataKey.get(ReportConstant.ReportDataKey.ORD_NOS));
    }
    // 検査
    if (dataKey.containsKey("selectExamSetCd") && !StringUtils.isEmpty(dataKey.get("selectExamSetCd"))){
      tmplParam.put("selectExamSetCd", dataKey.get("selectExamSetCd"));
    }
    if (dataKey.containsKey("regOrderClassList") && !StringUtils.isEmpty(dataKey.get("regOrderClassList"))){
      tmplParam.put("regOrderClassList", dataKey.get("regOrderClassList"));
    }
    // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe start
    // 処方
    List<Long> ordPrescriptionNos = new ArrayList<>();
    if (dataKey.get(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NOS) == null) {
      if(null != dataKey.get(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NO)){
        ordPrescriptionNos.add((Long) dataKey.get(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NO));
        dataKey.put(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NOS, ordPrescriptionNos);
      }
    } else {
      ordPrescriptionNos = (List<Long>) dataKey.get(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NOS);
      if(null == dataKey.get(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NO) && ordPrescriptionNos.size() > 0){
        dataKey.put(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NO, ordPrescriptionNos.get(0));
      }
    }
    if (dataKey.containsKey(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NO) && !StringUtils.isEmpty(dataKey.get(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NO))){
      tmplParam.put(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NO, dataKey.get(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NO));
    }
    if (dataKey.containsKey(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NOS) && !StringUtils.isEmpty(dataKey.get(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NOS))){
      tmplParam.put(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NOS, dataKey.get(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NOS));
    }
    // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe end

    tmplParams.add(tmplParam);
    dataKey.put(ReportConstant.ReportDataKey.TEMPLATE_PARAMS, tmplParams);
  }
  // add #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe end

  /**
   * テンプレート外のデータキーを取得する.
   *
   * @param dataKey データキー
   * @return テンプレート外のデータキー
   */
  private Map<String, Object> getOutOfTemplateDataKey(Map<String, Object> dataKey) {
    // テンプレート外の項目を読み込む
    Map<String, Object> dataKeyOut = new HashMap<String, Object>();
    // テンプレート外のdataKeyをdataKeyOutに設定する.
    List<Map<String, Object>> tmplParams = new ArrayList<Map<String, Object>>();
    boolean contains = dataKey.containsKey(ReportConstant.ReportDataKey.TEMPLATE_PARAMS);
    if (contains) {
      tmplParams = (List<Map<String, Object>>) dataKey.get(ReportConstant.ReportDataKey.TEMPLATE_PARAMS);
    }
    if (tmplParams.size() > 0) {
      Map<String, Object> tmplParam = new HashMap<>();
      tmplParam = tmplParams.get(0);
      dataKeyOut.put("ordNo", tmplParam.get("ordNo"));
      //パラメータkey値が統一されていないためデータを正しく取得できない問題を修正する
      if (dataKeyOut.get("ordNo") == null) {
        dataKeyOut.put("ordNo", tmplParam.get("ordNos"));
      }
      dataKeyOut.put("patId", tmplParam.get("patId"));
      dataKeyOut.put("date", tmplParam.get("date"));
      dataKeyOut.put("fromDate", tmplParam.get("fromDate"));
      dataKeyOut.put("toDate", tmplParam.get("toDate"));
      dataKeyOut.put("patIds", tmplParam.get("patIds"));
      dataKeyOut.put("facilityCd", tmplParam.get("facilityCd"));
      dataKeyOut.put("ordPrescriptionNos", tmplParam.get("ordPrescriptionNo"));
      dataKeyOut.put(ReportConstant.ReportDataKey.MEDICINE_IDS, tmplParam.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
      dataKeyOut.put(ReportConstant.ReportDataKey.DIALYZER_IDS, tmplParam.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
      dataKeyOut.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS, tmplParam.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
      dataKeyOut.put("treatDate", tmplParam.get("treatDate"));
      dataKeyOut.put("treat_date", tmplParam.get("treatDate"));
    }
    dataKey.entrySet().forEach(e -> {
      // dataKey名がテンプレート内のパラメータ名以外の場合は、テンプレート外と判断
      if (!e.getKey().equals(ReportConstant.ReportDataKey.TEMPLATE_PARAMS)) {
        if (dataKeyOut.get(e.getKey()) == null || dataKeyOut.get(e.getKey()).equals("")) {
          dataKeyOut.put(e.getKey(), e.getValue());
        }
      }
    });
    return dataKeyOut;
  }
  // add #12324 紹介状の出力時にpat_eventを参照する zhao start
  private void getNoTemplateDataKey(Map<String, Object> dataKey) {
    List<Long> patIds = new ArrayList<>();
    if (dataKey.get(ReportConstant.ReportDataKey.PAT_IDS) == null) {
      if(null != dataKey.get(ReportConstant.ReportDataKey.PAT_ID)){
        patIds.add((Long) dataKey.get(ReportConstant.ReportDataKey.PAT_ID));
        dataKey.put(ReportConstant.ReportDataKey.PAT_IDS, patIds);
      }
    } else {
      patIds = (List<Long>) dataKey.get(ReportConstant.ReportDataKey.PAT_IDS);
      if(null == dataKey.get(ReportConstant.ReportDataKey.PAT_ID) && patIds.size() > 0){
        dataKey.put(ReportConstant.ReportDataKey.PAT_ID, patIds.get(0));
      }
    }
    List<Long> ordNos = new ArrayList<>();
    if (dataKey.get(ReportConstant.ReportDataKey.ORD_NOS) == null) {
      if(null != dataKey.get(ReportConstant.ReportDataKey.ORD_NO)){
        ordNos.add((Long) dataKey.get(ReportConstant.ReportDataKey.ORD_NO));
        dataKey.put(ReportConstant.ReportDataKey.ORD_NOS, ordNos);
      }
    } else {
      ordNos = (List<Long>) dataKey.get(ReportConstant.ReportDataKey.ORD_NOS);
      if(null == dataKey.get(ReportConstant.ReportDataKey.ORD_NO) && ordNos.size() > 0){
        dataKey.put(ReportConstant.ReportDataKey.ORD_NO, ordNos.get(0));
      }
    }
    List<Long> ordPrescriptionNos = new ArrayList<>();
    if (dataKey.get(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NOS) == null) {
      if(null != dataKey.get(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NO)){
        ordPrescriptionNos.add((Long) dataKey.get(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NO));
        dataKey.put(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NOS, ordPrescriptionNos);
      }
    } else {
      ordPrescriptionNos = (List<Long>) dataKey.get(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NOS);
      if(null == dataKey.get(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NO) && ordPrescriptionNos.size() > 0){
        dataKey.put(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NO, ordPrescriptionNos.get(0));
      }
    }
  }
  // add #12324 紹介状の出力時にpat_eventを参照する zhao end
  /**
   * 計算式から <code>[SqlCode.データ項目コード]</code>を取得します.
   *
   * @param formula 計算式
   * @return <code>[SqlCode.データ項目コード]</code>のリスト
   */
  private List<String> getSqlCodeAndDataCodes(String formula) {
    List<String> result = new ArrayList<>();
    Matcher m = Pattern.compile("\\[([^\\[\\]]+)\\]").matcher(formula);
    while (m.find()) {
      result.add(m.group(1));
    }
    return result;
  }

  /**
   * Param要素情報からsqlCodeの値を取得します.
   *
   * @param params Param要素情報
   * @return SQLCODEのリスト
   */
  private List<String> getSqlCode(List<ReportXmlParam> params) {
    // sqlCodeの値を取得する
    List<String> sqlCodes = params.stream()
      .filter(p -> !StringUtils.isEmpty(p.getSqlCode()))
      .map(p -> p.getSqlCode())
      .collect(Collectors.toList());
    // formula属性に設定されているsqlCodeを取得する
    List<String> tmpList = new ArrayList<>();
    params.stream()
      .filter(p -> p.isFormulaToCalc())
      .forEach(p -> tmpList.addAll(getSqlCodeAndDataCodes(p.getFormula())));
    tmpList.stream().forEach(t -> {
      String[] tmps = t.split(Pattern.quote("."));
      if (tmps.length == 2) {
        sqlCodes.add(tmps[0]);
      }
    });
    // 重複は除外する
    return sqlCodes.stream().distinct().collect(toList());
  }

  /**
   * 帳票に出力する情報を取得します.
   *
   * @param params  Param要素情報
   * @param dataKey データ抽出キー
   * @return 帳票出力情報
   */
  private Map<Long, List<Map<String, Object>>> getReportInfo(List<ReportXmlParam> params, Map<String, Object> dataKey) {
    // SqlCodeをもとに帳票に出力する情報を取得する
    List<String> sqlCodes = getSqlCode(params);
    // 患者イベント 画像
    if (sqlCodes.contains("86")) {
      if (dataKey.containsKey(ReportConstant.ReportDataKey.DATE_FROM)) {
        dataKey.put("imageDateFrom", dateStr2dispDateStr(String.valueOf(dataKey.get(ReportConstant.ReportDataKey.DATE_FROM))));
      }
      if (!dataKey.containsKey(ReportConstant.ReportDataKey.DATE_TO)) {
        if (dataKey.containsKey(ReportConstant.ReportDataKey.DATE_FROM)) {
          dataKey.put("imageDateTo", dateStr2dispDateStr(String.valueOf(dataKey.get(ReportConstant.ReportDataKey.DATE_FROM))));
        }
      } else if (StringUtils.isEmpty(dataKey.get(ReportConstant.ReportDataKey.DATE_TO))) {
        if (dataKey.containsKey(ReportConstant.ReportDataKey.DATE_FROM)) {
          dataKey.put("imageDateTo", dateStr2dispDateStr(String.valueOf(dataKey.get(ReportConstant.ReportDataKey.DATE_FROM))));
        } else {
          dataKey.put("imageDateTo", dateStr2dispDateStr(String.valueOf(dataKey.get(ReportConstant.ReportDataKey.DATE_TO))));
        }
      } else {
        dataKey.put("imageDateTo", dateStr2dispDateStr(String.valueOf(dataKey.get(ReportConstant.ReportDataKey.DATE_TO))));
      }
    }
    // add #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe start
    if (sqlCodes.contains("197")){
      if (!dataKey.containsKey("selectExamSetCd")) {
        dataKey.put("selectExamSetCd", -1);
      }
    }
    if (!dataKey.containsKey("regOrderClassList")) {
      dataKey.put("regOrderClassList", new ArrayList<String>(Arrays.asList("1", "2", "0")));
    }
    // add #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe end
    Map<Long, List<Map<String, Object>>> finalReslut = new ConcurrentHashMap<>(sqlCodes.size());
    // Async Result Container
    Map<Long, CompletableFuture<List<Map<String, Object>>>> completableFutureMap =
      new ConcurrentHashMap<>(sqlCodes.size());
    // Maybe we should limit the length of the loop body
    for (String sqlCode : sqlCodes) {
      Long sqlKey = Long.parseLong(sqlCode);
      completableFutureMap.put(sqlKey, CompletableFuture.supplyAsync(
        () -> {
          try {
            // Call async method, place asynchronous results in the Async Result Container.
            return sysDataSetService.getDataListAsync(sqlKey, dataKey, null).get();
          } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
          } catch (ExecutionException e) {
            throw new RuntimeException(e);
          }
          return null;
        }
      ));
    }
    // Block all asynchronous threads to complete execution
    CompletableFuture.allOf(completableFutureMap.values().toArray(new CompletableFuture[0])).join();
    // Rebuild this result.
    completableFutureMap.forEach((key, value) -> {
      try {
        finalReslut.put(key, value.get());
      } catch (InterruptedException e) {
        Thread.currentThread().interrupt();
      } catch (ExecutionException e) {
        throw new RuntimeException(e);
      }
    });
    return finalReslut;
  }

  /**
   * @param params
   * @param List<id>
   * @return List<ReportXmlParam>
   */
  private static List<ReportXmlParam> getParamsbyIdList(List<ReportXmlParam> params, List<String> idList){
    List<ReportXmlParam> paramsTemp = new ArrayList<>();
    params.forEach(reportXmlParam -> {
      for(String id : idList){
        if (id.equals(reportXmlParam.getId())) {
          paramsTemp.add(reportXmlParam);
        }
      }
    });
    return paramsTemp;
  }

  /**
   * @param params
   * @param List<dataCode>
   * @return List<ReportXmlParam>
   */
  private static List<ReportXmlParam> getParamsbyDataCodeList(List<ReportXmlParam> params, List<String> dataCodeList){
    List<ReportXmlParam> paramsTemp = new ArrayList<>();
    params.forEach(reportXmlParam -> {
      for(String dataCd : dataCodeList){
        if (dataCd.equals(reportXmlParam.getDataCode())) {
          paramsTemp.add(reportXmlParam);
        }
      }
    });
    return paramsTemp;
  }

  /**
   * @param params
   * @param id
   * @return Param
   */
  private static ReportXmlParam getParambyId(List<ReportXmlParam> params, String id){
    ReportXmlParam param = null;
    List<ReportXmlParam> paramsbyId = params.stream().filter(p -> p.getId().equals(id)).collect(toList());
    if(paramsbyId != null && paramsbyId.size() > 0){
      param = paramsbyId.get(0);
    }
    return param;
  }

  /**
   * 集計内訳単位
   *
   * @param totalTable 集計内訳
   * @param flag 0:All 1:H 2:V
   * @return Map<dataCode, Address>
   */
  private static Map<String, String> getTotalTableUnitSet(Map<String, String> totalTable, Integer flag){
    Map<String, String> unitSet = new HashMap<>();

    List<String> strUnitVId = Arrays.asList(totalTable.get("totalUnitVAddr").split(",")).stream().collect(Collectors.toList());
    List<String> totalUnitVList = Arrays.asList(totalTable.get("totalUnitV").split(",")).stream().collect(Collectors.toList());

    List<String> strUnitHId = Arrays.asList(totalTable.get("totalUnitHAddr").split(",")).stream().collect(Collectors.toList());
    List<String> totalUnitHList = Arrays.asList(totalTable.get("totalUnitH").split(",")).stream().collect(Collectors.toList());

    if(flag == 1){
      if (strUnitHId.size() != totalUnitHList.size()) {
        throw new IllegalArgumentException("Lists must be of the same size");
      } else {
        unitSet = IntStream.range(0, totalUnitHList.size())
          .boxed()
          .collect(Collectors.toMap(
            i -> strUnitHId.get(i),
            i -> totalUnitHList.get(i),
            (existing, replacement) -> existing,
            LinkedHashMap::new
          ));
      }
    }
    else if(flag == 2){
      if (strUnitVId.size() != totalUnitVList.size()) {
        throw new IllegalArgumentException("Lists must be of the same size");
      } else {
        unitSet = IntStream.range(0, totalUnitVList.size())
          .boxed()
          .collect(Collectors.toMap(
            i -> strUnitVId.get(i),
            i -> totalUnitVList.get(i),
            (existing, replacement) -> existing,
            LinkedHashMap::new
          ));
      }
    }
    else {
      List<String> strUnitId = new ArrayList<>();
      strUnitId.addAll(strUnitVId);
      strUnitId.addAll(strUnitHId);
      List<String> totalUnitList = new ArrayList<>();
      totalUnitList.addAll(totalUnitVList);
      totalUnitList.addAll(totalUnitHList);
      if (strUnitId.size() != totalUnitList.size()) {
        throw new IllegalArgumentException("Lists must be of the same size");
      } else {
        unitSet = IntStream.range(0, totalUnitList.size())
          .boxed()
          .collect(Collectors.toMap(
            i -> strUnitId.get(i),
            i -> totalUnitList.get(i),
            (existing, replacement) -> existing,
            LinkedHashMap::new
          ));
      }
    }
    return unitSet;
  }

  /**
   * 横縦合計と総合計の配置位置を設定するための項目dataCode
   *
   * @param flag 0:All 1:H 2:V 3:A
   * @return List<dataCode>
   */
  private static List<String> getTotalValueAddrDataCode(Integer flag){
    List<String> dataCodeList = new ArrayList<>();
    if(flag == 1){
      dataCodeList.add("unit_H_total");
    }
    else if(flag == 2){
      dataCodeList.add("unit_V_total");
    }
    else if(flag == 3){
      dataCodeList.add("grand_total");
    }
    else {
      dataCodeList.add("unit_H_total");
      dataCodeList.add("unit_V_total");
      dataCodeList.add("grand_total");
    }
    return dataCodeList;
  }

  /**
   * 用途に応じて分ける
   *
   * @param totalTable 集計内訳
   * @param paramsOutTemplForCount 集計帳票で集計横、縦単位のパラメータを格納する変数
   * @param paramsOutTemplNoCount 集計帳票で集計範囲外のパラメータを格納する変数
   * @return params.size
   */
  private Integer splitDiffUseParams (
    Map<String, String> totalTable,
    List<ReportXmlParam> paramsOutTempl,
    List<ReportXmlParam> paramsOutTemplForCount,
    List<ReportXmlParam> paramsOutTemplNoCount
  ) {
    Map<String, String> totalUnitSet = getTotalTableUnitSet(totalTable, 0);

    List<ReportXmlParam> paramsTemp = new ArrayList<>();
    List<ReportXmlParam> paramsTemp2 = new ArrayList<>();
    if(totalUnitSet != null && totalUnitSet.size() > 0){
      List<String> dataCodeListbyTotal = getTotalValueAddrDataCode(0);
      List<String> dataCodeListbyInOut = getInOutTotalAddrDataCode(0);

      paramsOutTempl.forEach(reportXmlParam -> {
        boolean bHave = false;
        for(String dataCd : totalUnitSet.keySet()){
          if (dataCd.equals(reportXmlParam.getId()) && totalUnitSet.get(dataCd).equals(reportXmlParam.getDataCode())) {
            paramsTemp.add(reportXmlParam);
            bHave = true;
            break;
          }
        }
        if(!bHave){
          for(String dataCd : dataCodeListbyTotal){
            if (dataCd.equals(reportXmlParam.getDataCode())) {
              paramsTemp.add(reportXmlParam);
              bHave = true;
              break;
            }
          }
        }
        if(!bHave){
          for(String dataCd : dataCodeListbyInOut){
            if (dataCd.equals(reportXmlParam.getDataCode())) {
              paramsTemp.add(reportXmlParam);
              bHave = true;
              break;
            }
          }
        }
        if(!bHave) paramsTemp2.add(reportXmlParam);
      });
    }
    paramsOutTemplForCount.addAll(paramsTemp);
    paramsOutTemplNoCount.addAll(paramsTemp2);
    return paramsTemp.size() + paramsTemp2.size();
  }

  private Map<String, String> convertDataCodeToIdForTotal(
    List<ReportXmlParam> paramsInTempl,
    List<ReportXmlParam> paramsOutTempl,
    Map<Long, List<Map<String, Object>>> reportOutputInfo,
    Map<String, Object> dataKeyOutTempl,
    Map<String, String> totalTable,
    Map<String, Object> tmplRepeat
  ) {
    Map<String, String> result = new HashMap<>();

    long startTimeAggregateConfig = System.currentTimeMillis();

    String sqlCdInTempl = paramsInTempl.get(0).getSqlCode();
    if(!reportOutputInfo.containsKey(Long.parseLong(sqlCdInTempl)) || reportOutputInfo.get(Long.parseLong(sqlCdInTempl)) == null || reportOutputInfo.get(Long.parseLong(sqlCdInTempl)).size() == 0) return result;

    boolean bUnitHaveDate = false;

    // 縦の単位
    Map<String, String> UnitHMap = getTotalTableUnitSet(totalTable, 1);
    List<Map<String, Object>> rowKeys = new ArrayList<>();
    for(String key : UnitHMap.keySet()){
      ReportXmlParam param = getParambyId(paramsOutTempl, key);
      if(param == null) continue;
      Map<String, Object> unitSet = new HashMap<>();
      unitSet.put("dataCode", UnitHMap.get(key));
      unitSet.put("dataType", param.getDataType());
      unitSet.put("dispFormat", param.getDispFormat());
      unitSet.put("totalUnitDate", param.getDataType().equals(ReportXmlParam.DATA_TYPE_DATE_TIME) ? totalTable.get("totalUnitDate") : "");
      // mod #12218 集計の縦単位でも値のない行が出力できない limingzhe start
      //unitSet.put("effectDateFlag", param.getDataType().equals(ReportXmlParam.DATA_TYPE_DATE_TIME) ? totalTable.get("effectDateFlag") : "1");
      unitSet.put("unitDir", reportOutPutUtil.getResultShowDirection(1));
      unitSet.put("effectDataFlag", totalTable.get("effectDataHFlag"));
      // mod #12218 集計の縦単位でも値のない行が出力できない limingzhe end
      unitSet.put("fromDate", (String) dataKeyOutTempl.get(ReportConstant.ReportDataKey.DATE_FROM));
      unitSet.put("toDate", (String) dataKeyOutTempl.get(ReportConstant.ReportDataKey.DATE_TO));
      if(sqlCdInTempl.equals(param.getSqlCode())) {
        unitSet.put("reportInfo", null);
      }
      else {
        unitSet.put("reportInfo", reportOutputInfo.get(Long.parseLong(param.getSqlCode())));
      }
      if(param.getDataType().equals(ReportXmlParam.DATA_TYPE_DATE_TIME)) bUnitHaveDate = true;
      rowKeys.add(unitSet);
    }

    // 横の単位
    Map<String, String> UnitVMap = getTotalTableUnitSet(totalTable, 2);
    List<Map<String, Object>> columnKeys = new ArrayList<>();
    for(String key : UnitVMap.keySet()){
      ReportXmlParam param = getParambyId(paramsOutTempl, key);
      if(param == null) continue;
      Map<String, Object> unitSet = new HashMap<>();
      unitSet.put("dataCode", UnitVMap.get(key));
      unitSet.put("dataType", param.getDataType());
      unitSet.put("dispFormat", param.getDispFormat());
      unitSet.put("totalUnitDate", param.getDataType().equals(ReportXmlParam.DATA_TYPE_DATE_TIME) ? totalTable.get("totalUnitDate") : "");
      // mod #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe start
      // unitSet.put("effectDateFlag", param.getDataType().equals(ReportXmlParam.DATA_TYPE_DATE_TIME) ? totalTable.get("effectDateFlag") : "1");
      unitSet.put("unitDir", reportOutPutUtil.getResultShowDirection(2));
      unitSet.put("effectDataFlag", totalTable.get("effectDataVFlag"));
      // mod #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe end
      unitSet.put("fromDate", (String) dataKeyOutTempl.get(ReportConstant.ReportDataKey.DATE_FROM));
      unitSet.put("toDate", (String) dataKeyOutTempl.get(ReportConstant.ReportDataKey.DATE_TO));
      if(sqlCdInTempl.equals(param.getSqlCode())) {
        unitSet.put("reportInfo", null);
      }
      else {
        unitSet.put("reportInfo", reportOutputInfo.get(Long.parseLong(param.getSqlCode())));
      }
      if(param.getDataType().equals(ReportXmlParam.DATA_TYPE_DATE_TIME)) bUnitHaveDate = true;
      columnKeys.add(unitSet);
    }

    String totalContents = totalTable.get("totalContents");
    String totalContentsType = totalTable.get("totalContentsType");
    String contents = reportOutPutUtil.getTotalContentsType(totalContents, totalContentsType);
    String direction = reportOutPutUtil.getTmplRepeatDirection(Integer.parseInt(String.valueOf(tmplRepeat.get("direction"))));

    Map<String, String> totalDefaultOrderFlag = getTotalDefaultOrderFlag(Long.parseLong(sqlCdInTempl));
    Map<String, String> ordKeys = new HashMap<>();
    for(String key : UnitHMap.values()){
      if(totalDefaultOrderFlag.containsKey(key)){
        ordKeys.put(key, totalDefaultOrderFlag.get(key));
      }
    }
    for(String key : UnitVMap.values()){
      if(totalDefaultOrderFlag.containsKey(key)){
        ordKeys.put(key, totalDefaultOrderFlag.get(key));
      }
    }

    Map<String, Object> config = new HashMap<>();
    config.put("rowKeys", rowKeys);
    config.put("columnKeys", columnKeys);
    config.put("direction", direction);
    config.put("outputTypes", List.of(contents));
    config.put("targetKey", paramsInTempl.get(0).getDataCode());
    // add #11123 複数集計で平均、最大値、最小値のとき値のないセルにも0が出るのはNG limingzhe start
    config.put("totalDataType", paramsInTempl.get(0).getDataType());
    config.put("totalDispFormat", paramsInTempl.get(0).getDispFormat());
    // add #11123 複数集計で平均、最大値、最小値のとき値のないセルにも0が出るのはNG limingzhe end
    config.put("totalConversion", totalTable.get("totalConversion"));
    config.put("ordKeys", ordKeys);

    long endTimeAggregateConfig = System.currentTimeMillis();

    long startTimeExcelCellOutputConfig = System.currentTimeMillis();
    Integer repeatCountH = Integer.parseInt(tmplRepeat.get("repeatCountH").toString());
    Integer repeatCountV = Integer.parseInt(tmplRepeat.get("repeatCountV").toString());

    String tmplId = tmplRepeat.get("tmplId").toString();
    String dispLength = paramsInTempl.get(0).getDispLength().equals("") ? "0" : paramsInTempl.get(0).getDispLength();
    String isNewPage = String.valueOf(tmplRepeat.get("isNewPage"));

    List<Map<String, String>> dateRanges = new ArrayList<>();
    // 縦の単位
    for(String key : UnitHMap.keySet()){
      ReportXmlParam param = getParambyId(paramsOutTempl, key);
      if(param == null) continue;

      Map<String, String> unitSet = new HashMap<>();
      unitSet.put("unitDir", reportOutPutUtil.getResultShowDirection(1));
      unitSet.put("repeatAddress", param.getRepeatAddress());
      unitSet.put("dataType", param.getDataType());
      // mod #11985 定期点検一覧帳票が正常に出せない limingzhe start
      //unitSet.put("dispFormat", param.getDispFormat());
      unitSet.put("dispFormat", ReportTotalService.getUnitDispFormatForExcel(totalTable.get("totalUnitDate"), param.getDispFormat()));
      // mod #11985 定期点検一覧帳票が正常に出せない limingzhe end
      dateRanges.add(unitSet);
    }

    // 横の単位
    for(String key : UnitVMap.keySet()){
      ReportXmlParam param = getParambyId(paramsOutTempl, key);
      if(param == null) continue;

      Map<String, String> unitSet = new HashMap<>();
      unitSet.put("unitDir", reportOutPutUtil.getResultShowDirection(2));
      unitSet.put("repeatAddress", param.getRepeatAddress());
      unitSet.put("dataType", param.getDataType());
      // mod #11985 定期点検一覧帳票が正常に出せない limingzhe start
      //unitSet.put("dispFormat", param.getDispFormat());
      unitSet.put("dispFormat", ReportTotalService.getUnitDispFormatForExcel(totalTable.get("totalUnitDate"), param.getDispFormat()));
      // mod #11985 定期点検一覧帳票が正常に出せない limingzhe end
      dateRanges.add(unitSet);
    }

    List<Map<String, String>> totalValueRanges = new ArrayList<>();
    // ##集計.縦合計.合計値
    boolean bHaveTotalValueV = false;
    List<String> dataCodeListH = getTotalValueAddrDataCode(1);
    List<ReportXmlParam> paramsForTotalValueAddrH = getParamsbyDataCodeList(paramsOutTempl, dataCodeListH);
    for(ReportXmlParam param : paramsForTotalValueAddrH){
      if(param == null) continue;

      Map<String, String> unitSet = new HashMap<>();
      unitSet.put("unitDir", reportOutPutUtil.getResultShowDirection(1));
      unitSet.put("repeatAddress", param.getRepeatAddress());
      unitSet.put("dataType", param.getDataType());
      unitSet.put("dispFormat", param.getDispFormat());
      totalValueRanges.add(unitSet);
      bHaveTotalValueV = true;
    }

    // ##集計.横合計.合計値
    boolean bHaveTotalValueH = false;
    List<String> dataCodeListV = getTotalValueAddrDataCode(2);
    List<ReportXmlParam> paramsForTotalValueAddrV = getParamsbyDataCodeList(paramsOutTempl, dataCodeListV);
    for(ReportXmlParam param : paramsForTotalValueAddrV){
      if(param == null) continue;

      Map<String, String> unitSet = new HashMap<>();
      unitSet.put("unitDir", reportOutPutUtil.getResultShowDirection(2));
      unitSet.put("repeatAddress", param.getRepeatAddress());
      unitSet.put("dataType", param.getDataType());
      unitSet.put("dispFormat", param.getDispFormat());
      totalValueRanges.add(unitSet);
      bHaveTotalValueH = true;
    }

    // ##集計.総合計.合計値
    List<String> dataCodeListA = getTotalValueAddrDataCode(3);
    List<ReportXmlParam> paramsForTotalValueAddrA = getParamsbyDataCodeList(paramsOutTempl, dataCodeListA);
    for(ReportXmlParam param : paramsForTotalValueAddrA){
      if(param == null) continue;

      Map<String, String> unitSet = new HashMap<>();
      unitSet.put("unitDir", reportOutPutUtil.getResultShowDirection(0));
      unitSet.put("repeatAddress", param.getId());
      unitSet.put("dataType", param.getDataType());
      unitSet.put("dispFormat", param.getDispFormat());
      totalValueRanges.add(unitSet);
    }

    // add #11973 日常点検一覧帳票が正常に出せない limingzhe 0825 start
    if(totalValueRanges != null && totalValueRanges.size() > 0){
      List<String> totalDir = totalValueRanges.stream().map(map -> map.get("unitDir")).collect(Collectors.toList());
      if(totalDir.contains(reportOutPutUtil.getResultShowDirection(1))) totalTable.put("totalCountH", "1");
      if(totalDir.contains(reportOutPutUtil.getResultShowDirection(2))) totalTable.put("totalCountV", "1");
    }
    // add #11973 日常点検一覧帳票が正常に出せない limingzhe 0825 end

    List<Map<String, Object>> otherTotalRanges = new ArrayList<>();
    // ##週間.医材.入院合計 / ##週間.医材.外来合計
    List<String> dataCodeListInOut = getInOutTotalAddrDataCode(0);
    List<ReportXmlParam> paramsForTotalValueAddrInOut = getParamsbyDataCodeList(paramsOutTempl, dataCodeListInOut);
    for(ReportXmlParam param : paramsForTotalValueAddrInOut){
      if(param == null) continue;
      if(!reportOutputInfo.containsKey(Long.parseLong(param.getSqlCode()))) continue;
      Map<String, Object> unitSet = new HashMap<>();
      unitSet.put("dataCode", param.getDataCode());
      unitSet.put("unitDir", reportOutPutUtil.getResultShowDirection(2));
      unitSet.put("repeatAddress", param.getRepeatAddress());
      unitSet.put("dataType", param.getDataType());
      unitSet.put("dispFormat", param.getDispFormat());
      unitSet.put("reportInfo", reportOutputInfo.get(Long.parseLong(param.getSqlCode())));
      // add #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe start
      unitSet.put("dateName", "reg_date");
      // add #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe end
      otherTotalRanges.add(unitSet);
    }

    Map<String, Object> configOutput = new HashMap<>();
    configOutput.put("tmplId", tmplId);
    configOutput.put("direction", direction);
    configOutput.put("repeatCountH", repeatCountH);
    configOutput.put("repeatCountV", repeatCountV);
    configOutput.put("dispLength", dispLength);
    configOutput.put("isNewPage", isNewPage);
    configOutput.put("totalContents", contents);
    configOutput.put("totalDataType", paramsInTempl.get(0).getDataType());
    configOutput.put("totalFormat", paramsInTempl.get(0).getDispFormat());
    configOutput.put("totalCountH", totalTable.get("totalCountH"));
    configOutput.put("totalCountV", totalTable.get("totalCountV"));
    configOutput.put("tableCount", totalTable.get("totalCountH").equals("1") && totalTable.get("totalCountH").equals("1") ? "1" : "0");
    configOutput.put("dateRanges", dateRanges);
    configOutput.put("totalValueRanges", totalValueRanges);
    configOutput.put("otherTotalRanges", otherTotalRanges);

    long endTimeExcelCellOutputConfig = System.currentTimeMillis();

    if(!bUnitHaveDate){
      if(dataKeyOutTempl.get(ReportConstant.ReportDataKey.DATE_FROM).equals(dataKeyOutTempl.get(ReportConstant.ReportDataKey.DATE_TO))) bUnitHaveDate = true;
      // add #12383 クラス「検査結果(フィルタなし)」が複数集計にない limingzhe start
      if(StringUtils.isEmpty(getTotalDefaultDateFlag(Long.parseLong(sqlCdInTempl)))){
        bUnitHaveDate = true;
      }
      // add #12383 クラス「検査結果(フィルタなし)」が複数集計にない limingzhe end
    }

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd((String)dataKeyOutTempl.get(ReportConstant.ReportDataKey.FACILITY_CD));
    long executionTimeAggregateConfig = (endTimeAggregateConfig - startTimeAggregateConfig);
    System.err.println("getAggregateConfig total: " + executionTimeAggregateConfig + " （ms）");
    eventLogMessage.setLogMessage("複数集計 getAggregateConfig total: " + executionTimeAggregateConfig + " （ms）");
    logService.log(LogLevel.INFO, eventLogMessage,LoggingConstant.FUNCTION_CODE.FUNC_REPORT_MENU, LoggingConstant.SERVICE_NAME.FNSI, null);
    long executionTimeExcelCellOutputConfig = (endTimeExcelCellOutputConfig - startTimeExcelCellOutputConfig);
    System.err.println("getExcelCellOutputConfig total: " + executionTimeExcelCellOutputConfig + " （ms）");
    eventLogMessage.setLogMessage("複数集計 getExcelCellOutputConfig total: " + executionTimeExcelCellOutputConfig + " （ms）");
    logService.log(LogLevel.INFO, eventLogMessage,LoggingConstant.FUNCTION_CODE.FUNC_REPORT_MENU, LoggingConstant.SERVICE_NAME.FNSI, null);

    List<ReportTotalService.AggregationResult> totalResultList = new ArrayList<>();
    List<Integer> pageStartList = new ArrayList<>();
    if(bUnitHaveDate){

      long startTimeAggregationResult = System.currentTimeMillis();
      ReportTotalService.AggregationResult totalResult = reportOutPutUtil.aggregate(
        config,
        reportOutputInfo.get(Long.parseLong(sqlCdInTempl))
      );

//      totalResult.mainTable.forEach(System.out::println);
//
//      totalResult.rowName.forEach(System.out::println);
//
//      totalResult.columnName.forEach(System.out::println);
//
//      totalResult.rowSummary.forEach(System.out::println);
//
//      totalResult.columnSummary.forEach(System.out::println);
//
      pageStartList.add(0);
      int pageTotalNum;
      if ("1".equals(isNewPage)) {
        // 横方向の最大数の計算
        int CountV = (totalTable.get("totalCountV").equals("1") && !bHaveTotalValueV) ? 1 : 0;
        int largeWidth = totalResult.columnName.size() + CountV;
        // 縦方向の最大数の計算
        int CountH = (totalTable.get("totalCountH").equals("1") && !bHaveTotalValueH) ? 1 : 0;
        int largeHeight = totalResult.rowName.size() + CountH;
        pageTotalNum = calculateSmallTables(largeWidth, largeHeight, repeatCountH, repeatCountV);
      } else {
        // 改页しない，デフォルト1ページ
        pageTotalNum = 1;
      }
      System.err.println("***********************************************");
      System.err.println("ページング数の計算：" + pageTotalNum);
      System.err.println("***********************************************");
      // 最大ページ数判定
      if (pageTotalNum > SET_MAX_PAGE) {
        // 指定例外のスロー、メッセージの指定を促す
        throw new NtssException("ExceedingMaxPageSetting," + pageTotalNum);
      }
      totalResultList.add(totalResult);
      long endTimeAggregationResult = System.currentTimeMillis();

      long executionTimeAggregationResult = (endTimeAggregationResult - startTimeAggregationResult);
      System.err.println("AggregationResult total: " + executionTimeAggregationResult + " （ms）");
      eventLogMessage.setLogMessage("複数集計 AggregationResult total: " + executionTimeAggregationResult + " （ms）");
      logService.log(LogLevel.INFO, eventLogMessage,LoggingConstant.FUNCTION_CODE.FUNC_REPORT_MENU, LoggingConstant.SERVICE_NAME.FNSI, null);
    }
    else {
      String dateName = getTotalDefaultDateFlag(Long.parseLong(sqlCdInTempl));
      Set<String> dateS = reportOutPutUtil.getAllDateKeyRange(
        (String) dataKeyOutTempl.get(ReportConstant.ReportDataKey.DATE_FROM),
        (String) dataKeyOutTempl.get(ReportConstant.ReportDataKey.DATE_TO),
        "日",
        // mod #12194 機器保守項目のフィルタ設定が帳票出力時に反映しない limingzhe start
        //"yyyyMMdd"
        "yyyy/MM/dd"
        // mod #12194 機器保守項目のフィルタ設定が帳票出力時に反映しない limingzhe end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
        ,logService);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
      int pageTotalNum = 0;
      Object[] dateArray = dateS.toArray();
      for(int i = 0; i < dateArray.length; i++){
        List<Map<String, Object>> filteredInfoByDate = new ArrayList<>();
        if(StringUtils.isEmpty(dateName)){
          filteredInfoByDate = reportOutputInfo.get(Long.parseLong(sqlCdInTempl));
          if(i > 0) break;
        } else {
          // mod #12194 機器保守項目のフィルタ設定が帳票出力時に反映しない limingzhe start
          //String date = String.valueOf(dateArray[i]);
          String date = DateFormat(String.valueOf(dateArray[i]));
          // mod #12194 機器保守項目のフィルタ設定が帳票出力時に反映しない limingzhe end
          filteredInfoByDate = reportOutputInfo.get(Long.parseLong(sqlCdInTempl)).stream()
            .filter(map -> {
              Object dateValue = map.get(dateName);
              return (dateValue != null && (date.equals(DateFormat(String.valueOf(dateValue))) || dateValue.equals("")));
            })
            .collect(Collectors.toList());
        }
        // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
        if(filteredInfoByDate == null || filteredInfoByDate.size() == 0) continue;
        // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end

        long startTimeAggregationResult = System.currentTimeMillis();
        ReportTotalService.AggregationResult totalResult = reportOutPutUtil.aggregate(
          config,
          filteredInfoByDate
        );

//        totalResult.mainTable.forEach(System.out::println);
//
//        totalResult.rowName.forEach(System.out::println);
//
//        totalResult.columnName.forEach(System.out::println);
//
//        totalResult.rowSummary.forEach(System.out::println);
//
//        totalResult.columnSummary.forEach(System.out::println);
//
        pageStartList.add(pageTotalNum);
        if ("1".equals(isNewPage)) {
          // 横方向の最大数の計算
          int CountV = (totalTable.get("totalCountV").equals("1") && !bHaveTotalValueV) ? 1 : 0;
          int largeWidth = totalResult.columnName.size() + CountV;
          // 縦方向の最大数の計算
          int CountH = (totalTable.get("totalCountH").equals("1") && !bHaveTotalValueH) ? 1 : 0;
          int largeHeight = totalResult.rowName.size() + CountH;
          pageTotalNum += calculateSmallTables(largeWidth, largeHeight, repeatCountH, repeatCountV);
        } else {
          // 改页しない，デフォルト1ページ
          pageTotalNum = 1;
        }
        System.err.println("***********************************************");
        System.err.println("ページング数の計算：" + pageTotalNum);
        System.err.println("***********************************************");
        // 最大ページ数判定
        if (pageTotalNum > SET_MAX_PAGE) {
          // 指定例外のスロー、メッセージの指定を促す
          throw new NtssException("ExceedingMaxPageSetting," + pageTotalNum);
        }
        totalResultList.add(totalResult);
        long endTimeAggregationResult = System.currentTimeMillis();

        long executionTimeAggregationResult = (endTimeAggregationResult - startTimeAggregationResult);
        System.err.println("AggregationResult total: " + executionTimeAggregationResult + " （ms）");
        eventLogMessage.setLogMessage("複数集計 AggregationResult total: " + executionTimeAggregationResult + " （ms）");
        logService.log(LogLevel.INFO, eventLogMessage,LoggingConstant.FUNCTION_CODE.FUNC_REPORT_MENU, LoggingConstant.SERVICE_NAME.FNSI, null);

        if("0".equals(isNewPage)) break;
      }
    }

    long startTime_calcExcelAddressFromData = System.currentTimeMillis();
    List<ReportTotalService.ExcelCellOutput> excelCellOutput = new ArrayList<>();
    // add #11985 定期点検一覧帳票が正常に出せない limingzhe start
    List<ReportTotalService.ExcelCellOutput> excelCellOutputUnit = new ArrayList<>();
    List<ReportTotalService.ExcelCellOutput> excelCellOutputTotal = new ArrayList<>();
    // add #11985 定期点検一覧帳票が正常に出せない limingzhe end
    for (int i = 0; i < totalResultList.size(); i++){
      ReportTotalService.AggregationResult totalResult = totalResultList.get(i);
      if(pageStartList.size() > i) configOutput.put("pageStart", pageStartList.get(i));
      // mod #11985 定期点検一覧帳票が正常に出せない limingzhe start
      // excelCellOutput.addAll(reportOutPutUtil.calcExcelAddressFromData(configOutput, totalResult));
      ReportTotalService.ExcelCellOutputForTotal totalInfo = reportOutPutUtil.calcExcelAddressFromData(configOutput, totalResult);
      excelCellOutput.addAll(totalInfo.output);
      excelCellOutputUnit.addAll(totalInfo.outputUnit);
      excelCellOutputTotal.addAll(totalInfo.outputTotal);
      // mod #11985 定期点検一覧帳票が正常に出せない limingzhe end
    }
    long endTime_calcExcelAddressFromData = System.currentTimeMillis();

    long startTime_getKeyValueResult = System.currentTimeMillis();
    excelCellOutput.stream().forEach(p -> {
      String key = String.format("%d%s%s@%s", p.page, MULTIPLE_PAGES_SEPARATOR, p.cell, p.reference.get("dataType"));
      String value = p.value;
      result.put(key, value);
    });
    // add #11985 定期点検一覧帳票が正常に出せない limingzhe start
    excelCellOutputUnit.stream().forEach(p -> {
      String key = String.format("%d%s%s@%s", p.page, MULTIPLE_PAGES_SEPARATOR, p.cell, p.reference.get("dataType"));
      if(p.reference.containsKey("dispFormat") && !StringUtils.isEmpty(p.reference.get("dispFormat"))){
        key = String.format("%s@%s", key, p.reference.get("dispFormat"));
      }
      String value = p.value;
      result.put(key, value);
    });
    excelCellOutputTotal.stream().forEach(p -> {
      String key = String.format("%d%s%s@%s", p.page, MULTIPLE_PAGES_SEPARATOR, p.cell, p.reference.get("dataType"));
      String value = p.value;
      result.put(key, value);
    });
    // add #11985 定期点検一覧帳票が正常に出せない limingzhe end
    long endTime_getKeyValueResult = System.currentTimeMillis();

    long executionTime_calcExcelAddressFromData = (endTime_calcExcelAddressFromData - startTime_calcExcelAddressFromData);
    System.err.println("calcExcelAddressFromData total: " + executionTime_calcExcelAddressFromData + " （ms）");
    eventLogMessage.setLogMessage("複数集計 calcExcelAddressFromData total: " + executionTime_calcExcelAddressFromData + " （ms）");
    logService.log(LogLevel.INFO, eventLogMessage,LoggingConstant.FUNCTION_CODE.FUNC_REPORT_MENU, LoggingConstant.SERVICE_NAME.FNSI, null);
    long executionTime_getKeyValueResult = (endTime_getKeyValueResult - startTime_getKeyValueResult);
    System.err.println("getKeyValueResult total: " + executionTime_getKeyValueResult + " （ms）");
    eventLogMessage.setLogMessage("複数集計 getKeyValueResult total: " + executionTime_getKeyValueResult + " （ms）");
    logService.log(LogLevel.INFO, eventLogMessage,LoggingConstant.FUNCTION_CODE.FUNC_REPORT_MENU, LoggingConstant.SERVICE_NAME.FNSI, null);

    // 実際の改ページ数,改ページの正確性を計算するために、ここで及び2回の検証を行った
    int pageTotal = getPageCount(result);
    System.err.println("********************************");
    System.err.println("実際の改ページ数：" + pageTotal);
    System.err.println("********************************");

    return result;
  }

  /**
   * @return Map<dataCode, flag>
   */
  private static Map<String, String> getTotalDefaultOrderFlag(Long sqlCode){
    Map<String, String> paramFlag = new HashMap<>();
    if(sqlCode == 152l){
      paramFlag.put("kur_name", "kur_disp_order");
    }
    // add #12383 クラス「検査結果(フィルタなし)」が複数集計にない limingzhe start
    if(sqlCode == 197l){
      paramFlag.put("reg_order_class", "reg_order_class_sort");
    }
    // add #12383 クラス「検査結果(フィルタなし)」が複数集計にない limingzhe end
    return paramFlag;
  }

  /**
   * 横と縦の単位がどちらも文字列の場合に使用される日付dataCode
   *
   * @param sqlCode
   * @return dataCode
   */
  private static String getTotalDefaultDateFlag(Long sqlCode){
    if(sqlCode == 108l){
      return "mainte_date";
    }
    else if(sqlCode == 109l){
      return "mainte_date";
    }
    return "";
  }

  /**
   * 入院と外来合計
   *
   * @param fromDate
   * @param toDate
   * @param totalUnitDate
   * @param dispFormat 日付型横単位の書式
   * @param reportInfo
   */
  private void getMoveInOutTotalInfo(
    Map<Long, List<Map<String, Object>>> reportInfo,
    String fromDate,
    String toDate,
    String totalUnitDate,
    String dispFormat
  ){
    if (!reportInfo.containsKey(SQL_CD_HOSP_PAT_CNT) && !reportInfo.containsKey(SQL_CD_OUT_PAT_CNT)) return;
    List<Map<String, Object>> reportInfoForDis = null;
    if(reportInfo.get(SQL_CD_HOSP_PAT_CNT) != null) reportInfoForDis = reportInfo.get(SQL_CD_HOSP_PAT_CNT);
    if(reportInfo.get(SQL_CD_OUT_PAT_CNT) != null) reportInfoForDis = reportInfo.get(SQL_CD_OUT_PAT_CNT);

    Map<String, List<Map<String, Object>>> groupedByDate = reportInfoForDis.stream()
      .filter(p -> p.get("treat_date") != null)
      .collect(Collectors.groupingBy(map -> (String) map.get("treat_date")));

    Set<String> dateKeys = reportOutPutUtil.getAllDateKeyRange(
      fromDate,
      toDate,
      totalUnitDate,
      dispFormat
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    ,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end

    //入院と外来の初期化
    List<Map<String, Object>> newList = new ArrayList<>(); //入院
    List<Map<String, Object>> outList = new ArrayList<>(); //外来
    List<Map<String, Object>> dieList = new ArrayList<>(); //死亡
    for (String key : dateKeys) {
      Map<String, Object> newMap = new HashMap<>();
      newMap.put("hosp_pat_cnt", 0);
      newMap.put("reg_date", key);
      newList.add(newMap);

      Map<String, Object> outMap = new HashMap<>();
      outMap.put("out_pat_cnt", 0);
      outMap.put("reg_date", key);
      outList.add(outMap);

      Map<String, Object> dieMap = new HashMap<>();
      dieMap.put("die_pat_cnt", 0);
      dieMap.put("reg_date", key);
      dieList.add(dieMap);
    }

    Map<Long, List<Map<String, Object>>> groupedByPat =  reportInfoForDis.stream()
      .filter(p -> p.get("pat_id") != null)
      .collect(Collectors.groupingBy(map -> (Long) map.get("pat_id")));

    for(Long pId : groupedByPat.keySet()){
      List<Map<String, Object>> inoutInfo = groupedByPat.get(pId);
      if(inoutInfo == null || inoutInfo.size() == 0) continue;
      // fromDate~toDate 入院/外来 あり
      List<Map<String, Object>> inList = inoutInfo.stream()
        .filter(p -> p.get("move_in_out_name") != null)
        .sorted(Comparator.comparingLong(p -> Long.parseLong(String.valueOf(p.get("in_out_date")))))
        .collect(Collectors.toList());

      if(inList.size() > 0){
        Map<String, String> inoutStateMap = new HashMap<>();
        for (int i = 0; i < newList.size(); i++) {
          String lastInOut = "外来";
          for(int j = 0; j < inList.size(); j++){
            if(inList.get(j).get("last_move_in_out_name") != null){
              lastInOut = String.valueOf(inList.get(j).get("last_move_in_out_name"));
            }
          }
          inoutStateMap.put(String.valueOf(newList.get(i).get("reg_date")), lastInOut);
        }
        for(int j = 0; j < inList.size(); j++){
          String date = reportOutPutUtil.transformDateForUnitSet(String.valueOf(inList.get(j).get("in_out_date")), totalUnitDate, dispFormat);
          int indStart = 0;
          for (int i = 0; i < newList.size(); i++) {
            if(String.valueOf(newList.get(i).get("reg_date")).equals(date)){
              indStart = i;
            }
          }
          for (int i = indStart; i < newList.size(); i++) {
            inoutStateMap.put(String.valueOf(newList.get(i).get("reg_date")), String.valueOf(inList.get(j).get("move_in_out_name")));
          }
        }
        for (int i = 0; i < newList.size(); i++) {
          for(int j = 0; j < inoutInfo.size(); j++){
            String treat_date = reportOutPutUtil.transformDateForUnitSet(String.valueOf(inoutInfo.get(j).get("treat_date")), totalUnitDate, dispFormat);
            if(String.valueOf(newList.get(i).get("reg_date")).equals(treat_date)){
              if(inoutStateMap.containsKey(String.valueOf(dieList.get(i).get("reg_date")))
                && "死亡".equals(inoutStateMap.get(String.valueOf(dieList.get(i).get("reg_date"))))
              ){
                Integer startIndex = Integer.parseInt(dieList.get(i).get("die_pat_cnt").toString()) + 1;
                dieList.get(i).put("die_pat_cnt", startIndex);
              }
              else if(inoutStateMap.containsKey(String.valueOf(newList.get(i).get("reg_date")))
                && "入院".equals(inoutStateMap.get(String.valueOf(newList.get(i).get("reg_date"))))
              ){
                Integer startIndex = Integer.parseInt(newList.get(i).get("hosp_pat_cnt").toString()) + 1;
                newList.get(i).put("hosp_pat_cnt", startIndex);
              }
            }
          }
        }
      }
      else {
        // fromDate~toDate 入院/外来ない & 予定あり
        if("死亡".equals(String.valueOf(inoutInfo.get(0).get("last_move_in_out_name")))){
          for (int i = 0; i < dieList.size(); i++) {
            for(int j = 0; j < inoutInfo.size(); j++){
              String treat_date = reportOutPutUtil.transformDateForUnitSet(String.valueOf(inoutInfo.get(j).get("treat_date")), totalUnitDate, dispFormat);
              if(String.valueOf(dieList.get(i).get("reg_date")).equals(treat_date)){
                Integer startIndex = Integer.parseInt(dieList.get(i).get("die_pat_cnt").toString()) + 1;
                dieList.get(i).put("die_pat_cnt", startIndex);
              }
            }
          }
        }
        else if("入院".equals(String.valueOf(inoutInfo.get(0).get("last_move_in_out_name")))){
          for (int i = 0; i < newList.size(); i++) {
            for(int j = 0; j < inoutInfo.size(); j++){
              String treat_date = reportOutPutUtil.transformDateForUnitSet(String.valueOf(inoutInfo.get(j).get("treat_date")), totalUnitDate, dispFormat);
              if(String.valueOf(newList.get(i).get("reg_date")).equals(treat_date)){
                Integer startIndex = Integer.parseInt(newList.get(i).get("hosp_pat_cnt").toString()) + 1;
                newList.get(i).put("hosp_pat_cnt", startIndex);
              }
            }
          }
        }
      }
    }

    //入院処理
    if (reportInfo.containsKey(SQL_CD_HOSP_PAT_CNT)) {
      for (int i = 0; i < newList.size(); i++) {
        String date =  newList.get(i).get("reg_date").toString();
        newList.get(i).put("reg_date", date);
      }
      reportInfo.put(SQL_CD_HOSP_PAT_CNT, newList);
    }

    //外来処理
    if (reportInfo.containsKey(SQL_CD_OUT_PAT_CNT)){
      Map<String, Integer> dateMap = new HashMap<>();
      for(String sDate : groupedByDate.keySet()){
        String date = reportOutPutUtil.transformDateForUnitSet(sDate, totalUnitDate, dispFormat);
        dateMap.put(date, groupedByDate.get(sDate).size());
      }
      Integer patNum = 0;
      for (int i = 0; i < outList.size(); i++) {
        String date =  outList.get(i).get("reg_date").toString();
        outList.get(i).put("reg_date", date);
        if(dateMap.containsKey(date)){
          patNum = Integer.parseInt(dateMap.get(date).toString());
        }
        else {
          patNum = 0;
        }
        Integer hospCount = Integer.parseInt(newList.get(i).get("hosp_pat_cnt").toString());
        Integer dieCount = Integer.parseInt(dieList.get(i).get("die_pat_cnt").toString());
        Integer startIndex = patNum > hospCount ? patNum - hospCount - dieCount : 0;
        outList.get(i).put("out_pat_cnt", startIndex);
      }
      reportInfo.put(SQL_CD_OUT_PAT_CNT,outList);
    }
  }

  /**
   * 入院と外来合計の配置位置を設定するための項目dataCode
   *
   * @param flag 0:All 1:in 2:out
   * @return List<dataCode>
   */
  private static List<String> getInOutTotalAddrDataCode(Integer flag){
    List<String> dataCodeList = new ArrayList<>();
    if(flag == 1){
      dataCodeList.add("hosp_pat_cnt");
    }
    else if(flag == 2){
      dataCodeList.add("out_pat_cnt");
    }
    else {
      dataCodeList.add("hosp_pat_cnt");
      dataCodeList.add("out_pat_cnt");
    }
    return dataCodeList;
  }

  /**
   * 切断できる表の数を計算する
   *
   * @param largeWidth
   * @param largeHeight
   * @param smallWidth
   * @param smallHeight
   * @return
   */
  private int calculateSmallTables(int largeWidth, int largeHeight, int smallWidth, int smallHeight) {
    // 横方向と縦方向の表の数を計算する
    int horizontalCount = (int) Math.ceil((double) largeWidth / smallWidth);
    int verticalCount = (int) Math.ceil((double) largeHeight / smallHeight);
    // 合計テーブル数の計算
    return horizontalCount * verticalCount;
  }

  /**
   * ページ総数を取得します.
   *
   * @param reportOutputInfo 帳票出力情報
   * @return ページ総数
   */
  private int getPageCount(Map<String, String> reportOutputInfo) {
    return reportOutputInfo.keySet().stream()
      .filter(r -> r.indexOf(MULTIPLE_PAGES_SEPARATOR) >= 0)
      .map(r -> r.substring(0, r.indexOf(MULTIPLE_PAGES_SEPARATOR)))
      .map(Integer::valueOf)
      .max(Comparator.comparingInt(v -> v))
      .orElse(1);
  }

  private Map<String, String> convertDataCodeToId(List<ReportXmlParam> params, Map<Long, List<Map<String, Object>>> reportOutputInfo, Integer type, Integer reportType,
                                                  Map<String, Long> patIdToCMap, Map<String, Object> dataKey) {
    Map<String, String> paramIds = new HashMap<>();
    Map<String, String> result = new HashMap<>();

    Map<String, List<ReportXmlParam>> groupedParams = params.stream()
      .filter(p -> !StringUtils.isEmpty(p.getId()))
      .collect(Collectors.groupingBy(p -> p.getSqlCode()));

    List<String> sqlCodes = getSqlCode(params);
    List<Long> sqlCode1 = new ArrayList<Long>();
    for (String sql : sqlCodes) {
      sqlCode1.add(Long.valueOf(sql));
    }
    Collections.sort(sqlCode1);
    LinkedHashMap<String, List<ReportXmlParam>> newGroupe = new LinkedHashMap<>();
    for (Long sql : sqlCode1) {
      if (groupedParams.get(sql.toString()) != null) {
        newGroupe.put(sql.toString(), groupedParams.get(sql.toString()));
      }
    }
    // データ項目コード -> id属性値 に変換した情報を設定する
    newGroupe.entrySet().forEach(groupedParam -> {
      //各ループ開始resultで追加されたデータ数を記録する
      int resultSize = result.size();

      Long sqlCode;
      if (null != groupedParam.getKey() && groupedParam.getKey().equals("")) {
        sqlCode = Long.valueOf(0);
      } else {
        sqlCode = Long.valueOf(groupedParam.getKey());
      }
      // sqlCodeをもとに出力情報を取得する
      List<Map<String, Object>> tmpList = reportOutputInfo.get(sqlCode);

      Map<String, Object> dataKeyValues = new HashMap<>();
      if (tmpList != null && tmpList.size() > 0) {
        if (tmpList.get(0).containsKey("pat_last_name_id")) {
          for (int i = 0; i < tmpList.size(); i++) {
            Long patIdToC = 0L;
            if (patIdToCMap.get(PAT_ID_TO_C) != null) {
              patIdToC = patIdToCMap.get(PAT_ID_TO_C);
            }
            if (patIdToC != null && patIdToC.equals(tmpList.get(i).get("patId"))) {
              dataKeyValues = tmpList.get(i);
              break;
            }
          }
        }
      }
      if (tmpList != null && !tmpList.isEmpty()) {
        List<ReportXmlParam> list = groupedParam.getValue().stream()
          .filter(param -> StringUtils.isEmpty(param.getGroupId()) && "1".equals(param.getIsNewPage()) && !param.isTmplRepeat()).collect(toList());
        // 単一項目に対する処理を行う
        if (tmpList.size() > 1 && list != null && list.size() > 0) {
          groupedParam.getValue().stream()
            .filter(param -> StringUtils.isEmpty(param.getGroupId()) && !param.isTmplRepeat())
            .forEach(param -> {
              for (int i = 0; i < tmpList.size(); i++) {
                // add #11813 紹介状出力時、手打ち入力した導入施設名が表示されない limingzhe start
                if (dataKey.get("newPageCountFlag") != null && (i + 1) > 1) continue;
                // add #11813 紹介状出力時、手打ち入力した導入施設名が表示されない limingzhe end
                Map<String, Object> tmpMap = tmpList.get(i);
                // 出力する内容を取得する
                String value = reportServiceImpl.formatValue(param, tmpMap.get(param.getDataCode()));
                value = reportServiceImpl.convertValue(param, value);
                if (value != null && !"null".equals(value)) {
                  result.put(String.format("%d%s", i + 1, MULTIPLE_PAGES_SEPARATOR) + param.getId(), reportServiceImpl.addLineBreak(value, param));
                } else {
                  result.put(String.format("%d%s", i + 1, MULTIPLE_PAGES_SEPARATOR) + param.getId(), "");
                }
              }
            })
          ;
        } else {
          Map<String, Object> tmpMap = tmpList.get(0);
          groupedParam.getValue().stream()
            .filter(param -> StringUtils.isEmpty(param.getGroupId()) && !param.isTmplRepeat())
            .forEach(param -> {
              // 出力する内容を取得する
              String value = reportServiceImpl.formatValue(param, tmpMap.get(param.getDataCode()));
              value = reportServiceImpl.convertValue(param, value);
              if (value != null && !"null".equals(value)) {
                result.put(param.getId(), reportServiceImpl.addLineBreak(value, param));
              } else {
                result.put(param.getId(), "");
              }
            })
          ;
        }
        Map<String, Object> finalDataKeyValues = dataKeyValues;
        // 複数項目に対する処理を行う
        groupedParam.getValue().stream()
          .filter(param -> !StringUtils.isEmpty(param.getGroupId()) && !param.isTmplRepeat())
          .forEach(param -> {
            // フィルタ処理を行う
            List<Map<String, Object>> filteredList = reportServiceImpl.filterReportInfo(param, tmpList);
            // フィルタ処理の結果がEmptyの場合
            if (filteredList.isEmpty()) {
              EventLogMessage eventLogMessage = new EventLogMessage();
              eventLogMessage.setLogMessage("帳票：フィルタ結果した結果が空");
              logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
              return;
            }
            // 1ページの繰り返し件数を取得する
            ReportXmlGroup group = param.getReportXmlGroup();
            Integer repeatOfPage;
            if (group != null && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_YES) {
              repeatOfPage = (filteredList.size() > group.getRepeatMax()) ? group.getRepeatMax() : filteredList.size();
            } else {
              repeatOfPage = filteredList.size();
            }
            // ページ数分、以下の処理を行う
            int limitCount = repeatOfPage;
            Integer repeatMax = (group != null && group.getRepeatMax() != null) ? group.getRepeatMax() : 1;
            for (Integer pageCount = 0; pageCount <= (filteredList.size() / repeatOfPage); pageCount++) {
              // add #11813 紹介状出力時、手打ち入力した導入施設名が表示されない limingzhe start
              if (dataKey.get("newPageCountFlag") != null && (pageCount + 1) > 1) continue;
              // add #11813 紹介状出力時、手打ち入力した導入施設名が表示されない limingzhe end
              int skipCount = pageCount * limitCount;
              // id属性値をkey、出力値をvalue に設定する（複数項目の場合、id属性値に連番を付加する）
              List<Map<String, Object>> outputInfos = filteredList.stream().skip(skipCount).limit(limitCount).collect(toList());
              int n = 0;
              List<ReportXmlFilterTable> filters = param.getReportXmlFilters();
              String strDate = "";
              for (Integer i = 0; i < outputInfos.size(); i++) {
                if (n >= repeatMax) {
                  // 帳票定義XMLで指定されている繰り返し回数を超えた場合、残りのデータは出力しない
                  break;
                }
                // del #10531 検査日と検査区分がフィルタを超えて繰り返される limingzhe start
//                String outputData = "";
//                Set<String> keysSet = outputInfos.get(i).keySet();
//                if (!keysSet.isEmpty()) {
//                  String key = keysSet.toArray(new String[0])[0];
//                  outputData = String.valueOf(outputInfos.get(i).get(key));
//                }
//
//                List<String> PatientEvents = new ArrayList<String>() {
//                  {
//                    for (int i = 84; i <= 94; i++) {
//                      this.add(i + "");
//                    }
//                  }
//                };
//                if (filters == null || filters.size() == 0 || (outputData.equals(filters.get(0).getCode()) && !outputData.isEmpty()) || PatientEvents.contains(param.getSqlCode())) {
                  // del #10531 検査日と検査区分がフィルタを超えて繰り返される limingzhe end
                  String key = "";
                  // mod #12231 グループ繰り返しOFFの項目群が2ページ目に1ページ目と同じ内容にならない 高 start
                  String pageStr = "";
                  if (!StringUtils.isEmpty(param.getReportXmlGroup()) && param.getReportXmlGroup().getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_YES) {
                    pageStr = String.format("%d%s", pageCount + 1, MULTIPLE_PAGES_SEPARATOR);
                  }
//                  String pageStr = String.format("%d%s", pageCount + 1, MULTIPLE_PAGES_SEPARATOR);
                  // mod #12231 グループ繰り返しOFFの項目群が2ページ目に1ページ目と同じ内容にならない 高 end
                  key = String.format("%s%s-%d", pageStr, param.getId(), n + 1);
                  if (finalDataKeyValues.size() > 0) {
                    if ("pat_last_name".equals(param.getDataCode()) || "first_name_is_same".equals(param.getDataCode()) || "pat_name".equals(param.getDataCode())) {
                      String valueA = reportServiceImpl.formatValue(param, finalDataKeyValues.get(param.getDataCode()));
                      valueA = reportServiceImpl.convertValue(param, valueA);
                      if ("first_name_is_same".equals(param.getDataCode())) {
                        valueA = finalDataKeyValues.get("pat_last_name") + " " + valueA;
                      }
                      if (valueA != null && !"".equals(valueA)) {
                        result.put(param.getId() + "-1", reportServiceImpl.addLineBreak(valueA, param));
                      } else {
                        result.put(param.getId() + "-1", "");
                      }
                    }
                  } else {
                    String value = reportServiceImpl.formatValue(param, outputInfos.get(i).get(param.getDataCode()));
                    value = reportServiceImpl.convertValue(param, value);
                    // add #12538 日常点検／定期点検のデータ項目補完 limingzhe start
                    if(param.getDataCode().equals("layout_group_ans") && value.length() >= 1){
                      String convValue = reportServiceImpl.convertValue(param, value.substring(0,1));
                      value = convValue.concat(value.substring(1));
                    }
                    // add #12538 日常点検／定期点検のデータ項目補完 limingzhe end
                    // add #11571 「患者名（姓のみ）+同姓フラグ」が同姓同名フラグになっている sunsy start
                    // add #12239 スケジュール表画面のフラグ表現で帳票では出力できないものがある sunsy start
//if ("first_name_is_same".equals(param.getDataCode())) {
//                      value = outputInfos.get(i).get("pat_last_name") != null ? outputInfos.get(i).get("pat_last_name") + value : value;
//                    }
//                    if ("pat_name_is_same".equals(param.getDataCode())) {
//                      value = outputInfos.get(i).get("pat_name") != null ? outputInfos.get(i).get("pat_name") + value : value;
//                    }
                    if (param.getDataCode().contains("first_name_is")) {
                      String patLastName = outputInfos.get(i).get("pat_last_name") != null
                        ? outputInfos.get(i).get("pat_last_name").toString()
                        : "";

                      boolean hasValue = value != null && !value.isEmpty();
                      boolean hasPatLastName = !patLastName.isEmpty();

                      // 状況1:value（変換値）が空、実在の患者姓がある場合、実在の患者姓のみ出力
                      if (!hasValue && hasPatLastName) {
                        value = patLastName;
                      }

                      // 状況2:value（変換値）有り
                      else if (hasValue) {

                        // value中に「患者名」がある場合
                        if (value.contains("患者名")) {
                          if (hasPatLastName) {
                            // 患者姓がある → 置換
                            value = value.replace("患者名", patLastName);
                          } else {
                            // 患者姓がない → 全体を空にする
                            value = "";
                          }
                        }

                        // 「患者名」が無いのに患者姓が存在する → エラー
                        else if (hasPatLastName) {
                          value = "変換エラー";
                        }
                      }
                    }

                    if (param.getDataCode().contains("pat_name_is")) {
                      String patName = outputInfos.get(i).get("pat_name") != null
                        ? outputInfos.get(i).get("pat_name").toString()
                        : "";

                      boolean hasValue = value != null && !value.isEmpty();
                      boolean hasPatName = !patName.isEmpty();

                      // 状況1:value（変換値）が空、実在の患者名がある場合、実在の患者名のみ出力
                      if (!hasValue && hasPatName) {
                        value = patName;
                      }

                      // 状況2:value（変換値）有り
                      else if (hasValue) {

                        // value中に「患者名」がある場合
                        if (value.contains("患者名")) {
                          if (hasPatName) {
                            // 患者名がある → 置換
                            value = value.replace("患者名", patName);
                          } else {
                            // 患者名がない → 全体を空にする
                            value = "";
                          }
                        }

                        // 「患者名」が無いのに患者名が存在する → エラー
                        else if (hasPatName) {
                          value = "変換エラー";
                        }
                      }
                    }
                    // add #12239 スケジュール表画面のフラグ表現で帳票では出力できないものがある sunsy end
                    // add #11571 「患者名（姓のみ）+同姓フラグ」が同姓同名フラグになっている sunsy end
                    //
                    // del #10385 患者イベント(画像)の出力が不正 高 start
//                    if (param.getIsImage().equals("true") && null != value && !value.equals("") && !value.equals("null")) {
//                      value = "(place)" + value;
//                    }
                    // del #10385 患者イベント(画像)の出力が不正 高 end
                    if (value != null && !"null".equals(value) && !"".equals(value)) {
                      if (!result.containsKey(key)) {
                        result.put(key, reportServiceImpl.addLineBreak(value, param));
                      }
                    } else {
                      if (!result.containsKey(key)) {
                        result.put(key, "");
                      }
                    }
                  }
                  n = n + 1;
                // del #10531 検査日と検査区分がフィルタを超えて繰り返される limingzhe start
//                }
                // del #10531 検査日と検査区分がフィルタを超えて繰り返される limingzhe end
              }
            }
          });
        int tmplCount = 0;
        int tmplLoopCount = 1;

        for (ReportXmlParam param : groupedParam.getValue()) {
          if (!(!StringUtils.isEmpty(param.getGroupId()) && param.isTmplRepeat())) {
            continue;
          }
          if (sqlCode != 31L) {
            List<Map<String, Object>> filteredList = reportServiceImpl.filterReportInfo(param, tmpList);
            if (filteredList.isEmpty()) {
              EventLogMessage eventLogMessage = new EventLogMessage();
              eventLogMessage.setLogMessage("帳票：フィルタ結果した結果が空");
              logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
              return;
            }
            ReportXmlTmplRepeat tmplRepeat = param.getReportXmlTmplRepeat();
            ReportXmlGroup group = param.getReportXmlGroup();
            Integer repeatOfPage;
            if (group != null && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_YES) {
              repeatOfPage = (filteredList.size() > group.getRepeatMax()) ? group.getRepeatMax() : filteredList.size();
            } else {
              if (!StringUtils.isEmpty(param.getReportXmlTmplRepeat().getId())) {
                repeatOfPage = (filteredList.size() > param.getReportXmlTmplRepeat().getRepeatMax()) ? param.getReportXmlTmplRepeat().getRepeatMax() : filteredList.size();
              } else {
                repeatOfPage = filteredList.size();
              }
            }
            int limitCount = repeatOfPage;
            Integer repeatMax = (group != null && group.getRepeatMax() != null) ? group.getRepeatMax() : 1;
            for (Integer pageCount = 0; pageCount <= (filteredList.size() / repeatOfPage); pageCount++) {
              int skipCount = pageCount * limitCount;
              List<Map<String, Object>> outputInfos = filteredList.stream().skip(skipCount).limit(limitCount).collect(toList());
              int n = 0;
              List<ReportXmlFilterTable> filters = param.getReportXmlFilters();
              for (Integer i = 0; i < outputInfos.size(); i++) {
                String outputData = "";
                Set<String> keysSet = outputInfos.get(i).keySet();
                String keyCode = keysSet.toArray(new String[0])[0];
                outputData = String.valueOf(outputInfos.get(i).get(keyCode));

                if (filters == null || filters.size() == 0 || (outputData.equals(filters.get(0).getCode()) && !outputData.isEmpty())) {
                  String pageStr = String.format("%d%s", pageCount + 1, MULTIPLE_PAGES_SEPARATOR);
                  String keyTmpl = String.format("%s-%d", tmplRepeat.getId(), tmplCount);
                  String keyParam = String.format("%s-%s", param.getId(), tmplLoopCount++);
                  String key = String.format("%s%s.%s", pageStr, keyTmpl, keyParam);
                  String value = reportServiceImpl.formatValue(param, outputInfos.get(i).get(param.getDataCode()));
                  value = reportServiceImpl.convertValue(param, value);
                  paramIds.put(param.getId(), param.getId());
                  if (value != null && !"null".equals(value)) {
                    result.put(key, reportServiceImpl.addLineBreak(value, param));
                  } else {
                    result.put(key, "");
                  }
                  n = n + 1;
                }
              }
            }
          }
        }
        // sqlCodeをもとに出力情報を取得する
        List<Map<String, Object>> oldTmpList = new ArrayList<>();
        oldTmpList.addAll(tmpList);
        // テンプレート繰り返しに対する処理を行う
        groupedParam.getValue().stream().filter(param -> (StringUtils.isEmpty(param.getGroupId()) && param.isTmplRepeat()))
          .forEach(param -> {
              int startPrintPos = 1;
              // 検査結果表示のフィルタ表示
              List<ReportXmlFilterTable> filters = param.getReportXmlFilters();
              if (filters != null && filters.size() > 0) {
                // コードを取得する
                String itemCode = String.valueOf(filters.get(0).getCode());
                // 透析前
                String before = filters.get(0).getBefore();
                // 透析後
                String after = filters.get(0).getAfter();
                List<Map<String, Object>> newTmpList = new ArrayList<>();
                for (int i = 0; i < oldTmpList.size(); i++) {
                  String tmpItemCode = String.valueOf(oldTmpList.get(i).get("item_cd"));
                  if (tmpItemCode.equals(itemCode)) {
                    if ("1".equals(before) && "0".equals(after)) {
                      // ALB(前）
                      if ("1".equals(String.valueOf(oldTmpList.get(i).get("reg_order_class")))) {
                        newTmpList.add(oldTmpList.get(i));
                      }
                    } else if ("0".equals(before) && "1".equals(after)) {
                      // ALB(後）
                      if ("2".equals(String.valueOf(oldTmpList.get(i).get("reg_order_class")))) {
                        newTmpList.add(oldTmpList.get(i));
                      }
                    } else {
                      newTmpList.add(oldTmpList.get(i));
                    }
                  }
                }
                // 登録時検査日時の最新時刻でソート
                Collections.sort(newTmpList, new Comparator<Map<String, Object>>() {
                  public int compare(Map<String, Object> o1, Map<String, Object> o2) {
                    String v1 = o1.get("reg_exam_date").toString();
                    String v2 = o2.get("reg_exam_date").toString();
                    int cp1 = v2.compareTo(v1);
                    if (cp1 == 0) {
                      return 0;
                    } else {
                      return cp1;
                    }
                  }
                });
                tmpList.clear();
                for (int i = 0; i < newTmpList.size(); i++) {
                  tmpList.add(newTmpList.get(i));
                }
              }
              ReportXmlTmplRepeat tmplRepeat = param.getReportXmlTmplRepeat();
              String tmplRepeatadd = tmplRepeat.getId();
              if (tmplRepeatadd != null) {
                String[] Id = tmplRepeatadd.split(":");
                if (Id.length == 2) {
                  String str = Id[0];
                  String[] Ids = str.split("\\d");
                  int onei = Ids[0].length();
                  String strA = str.substring(0, onei);
                  String str2 = Id[1];
                  String[] Ids2 = str2.split("\\d");
                  int twoi = Ids2[0].length();
                  String strB = str2.substring(0, twoi);
                  if (strA.equals(strB)) {
                    if (!paramIds.containsKey(param.getId())) {
                      convertDataCodeToIdRepeatTmpl(result, tmpList, param, startPrintPos, false);
                    }
                  } else {
                    convertDataCodeToIdRepeatTmpl(result, tmpList, param, startPrintPos, false);
                  }
                } else {
                  convertDataCodeToIdRepeatTmpl(result, tmpList, param, startPrintPos, false);
                }
              } else {
                convertDataCodeToIdRepeatTmpl(result, tmpList, param, startPrintPos, false);
              }
            });
      }
      //sqlCodeが空ではないが、データを書き込めない場合の解決 (適切な修正案が見つかった場合は、このセグメントコードを削除できます)
      //今回のサイクルでデータが何も書き込まれていない場合は、
      // ①reportOutputInfo、②dataKeyから、
      //本来書き込む可能性のあるデータを見つけて書き込むことを順番に試みます
      if (resultSize == result.size()) {
        groupedParam.getValue().forEach(param -> {
          List<Map<String, Object>> info = reportOutputInfo.get(Long.valueOf(param.getSqlCode()));
          info = reportServiceImpl.filterReportInfo(param, info);
          String key = param.getId();
          if (!param.getSqlCode().equals("")) {
            key += "-1";
          }
          if (info != null && info.size() > 0) {
            //reportOutputInfoの最初のデータから優先的に検索
            result.put(key, reportServiceImpl.formatValue(param, info.get(0).get(param.getDataCode())));
          } else if (dataKey.containsKey(param.getDataCode())) {
            //dataKeyのデータを追加しようとします
            result.put(key, reportServiceImpl.formatValue(param, dataKey.get(param.getDataCode())));
          }
        });
      }
    });

    Map<String, String> map = new HashMap<>();
    for (String position : result.keySet()) {
      if (position.split("#").length == 1) {
        map.put(position, result.get(position));
        continue;
      }
      Matcher n = ReportUtils.getPositionRegex().matcher(position);
      if (n.matches()) {
        map.put(position, result.get(position));
        continue;
      }
      Matcher m = ReportUtils.getPositionRegexTmpl().matcher(position);
      if (!m.matches()) {
        continue;
      }
      String cellAddress = m.group(3);
      String range = m.group(1).substring(m.group(1).indexOf("#") + 1);
      if (isWithinRange(cellAddress.split(":")[0].split("-")[0], range)) {
        map.put(position, result.get(position));
      }
    }
    return map;
  }

  /**
   * テンプレート繰り返しのデータ項目をid属性値に変換します.
   *
   * @param result        idごとの値コレクション. Map<id, 値>
   * @param tmpList       値コレクション. List<Map<SQLコード, 値>>
   * @param param         帳票定義XMLのParam要素.
   * @param startPrintPos 印刷開始テンプレート位置.
   */
  private void convertDataCodeToIdRepeatTmpl(Map<String, String> result,
                                             List<Map<String, Object>> tmpList,
                                             ReportXmlParam param,
                                             int startPrintPos,
                                             boolean isLabel) {
    ReportXmlTmplRepeat tmplRepeat = param.getReportXmlTmplRepeat();
    Integer repeatOfPage;
    if (tmplRepeat != null && tmplRepeat.getIsNewPage() == ReportXmlTmplRepeat.IS_NEW_PAGE_YES) {
      repeatOfPage = (tmpList.size() > tmplRepeat.getRepeatMax()) ? tmplRepeat.getRepeatMax() : tmpList.size();
    } else {
      repeatOfPage = tmpList.size();
    }
    // ページ数分、以下の処理を行う
    int limitCount = repeatOfPage;
    Integer repeatMax = (tmplRepeat != null && tmplRepeat.getRepeatMax() != null) ? tmplRepeat.getRepeatMax() : 1;
    int startPos = startPrintPos;
    for (Integer pageCount = 0; pageCount <= ((tmpList.size() + startPrintPos) / repeatOfPage); pageCount++) {
      int skipCount = pageCount * limitCount;
      if (startPrintPos != 1 && pageCount > 0 && startPrintPos + tmpList.size() > repeatMax) {
        skipCount = repeatMax * pageCount - startPrintPos + 1;
      }
      List<Map<String, Object>> outputInfos = tmpList.stream().skip(skipCount).limit(limitCount).collect(toList());
      for (Integer i = 0; i < outputInfos.size(); i++) {
        if (i + startPos > repeatMax) {
          // 帳票定義XMLで指定されている繰り返し回数を超えた場合、残りのデータは出力しない
          // 印刷開始位置を指定して呼び出されている場合、2ページ目以降は先頭のテンプレートから印刷するために印刷開始位置を1にする
          startPos = 1;
          break;
        }
        String keyPage = String.format("%d%s", pageCount + 1, MULTIPLE_PAGES_SEPARATOR);
        String keyTmpl = String.format("%s-%d", tmplRepeat.getId(), i + startPos);
        String keyParam = String.format("%s%s", param.getId(), StringUtils.isEmpty(param.getGroupId()) ? "" : "-1");
        String key = String.format("%s%s.%s", keyPage, keyTmpl, keyParam);
        String value;
        String dataCode;
        if (outputInfos.get(i).size() == 0) {
          result.put(key, "");
          continue;
        }
        if (!StringUtils.isEmpty(param.getParticular()) && param.getParticular().equals("Label") && null != outputInfos.get(i).get("class_name")) {
          // 分類別情報の場合に読むSQLコードを変える
          // 分類別情報
          final String classNo = outputInfos.get(i).get("class_ename").toString();
          final ReportXmlClassificationDataCode reportXmlClassificationDataCode = param.getReportXmlClassificationDataCodes().get(classNo);
          if (reportXmlClassificationDataCode != null) {
            dataCode = reportXmlClassificationDataCode.getDataCode();
            if (dataCode.isEmpty()) {
              // 固定文字列
              value = reportXmlClassificationDataCode.getFixString();
            } else {
              // dataCode指定
              value = reportServiceImpl.formatValue(param, outputInfos.get(i).get(dataCode));
              value = reportServiceImpl.convertValue(param, value);
            }
          } else {
            value = "";
          }
        } else {
          value = reportServiceImpl.formatValue(param, outputInfos.get(i).get(param.getDataCode()));
          value = reportServiceImpl.convertValue(param, value);
        }
        if ("null".equals(value)) {
          value = "";
        }
        result.put(key, reportServiceImpl.addLineBreak(value, param));
      }
    }
  }

  private static boolean isWithinRange(String cellAddress, String range) {
    String[] rangeParts = range.split(":");
    String startAddress = rangeParts[0];
    String endAddress = rangeParts[rangeParts.length - 1];
    // Parse the cell address to get the row and column numbers
    int cellRow = Integer.parseInt(cellAddress.replaceAll("[^\\d]", ""));
    int cellColumn = columnLetterToNumber(cellAddress.replaceAll("[^A-Za-z]", ""));

    // Parse the start and end addresses to get their row and column numbers
    int startRow = Integer.parseInt(startAddress.replaceAll("[^\\d]", ""));
    int startColumn = columnLetterToNumber(startAddress.replaceAll("[^A-Za-z]", ""));
    int endRow = Integer.parseInt(endAddress.replaceAll("[^\\d]", ""));
    int endColumn = columnLetterToNumber(endAddress.replaceAll("[^A-Za-z]", ""));
    // Check if the cell address is within the range
    return (cellRow >= startRow && cellRow <= endRow && cellColumn >= startColumn && cellColumn <= endColumn);
  }

  private static int columnLetterToNumber(String columnLetter) {
    int columnNumber = 0;
    int length = columnLetter.length();
    for (int i = 0; i < length; i++) {
      char c = columnLetter.charAt(i);
      columnNumber = columnNumber * 26 + (c - 'A' + 1);
    }
    return columnNumber;
  }

  /**
   * yyyyMMdd -> yyyy/MM/dd
   *
   * @param yyyymmdd
   * @return
   */
  private String dateStr2dispDateStr(String yyyymmdd) {
    if (yyyymmdd.length() == 8) {
      String year = yyyymmdd.substring(0, 4);
      String month = yyyymmdd.substring(4, 6);
      String day = yyyymmdd.substring(6);
      String treatDateFormatted = year + "/" + month + "/" + day;
      return treatDateFormatted;
    } else {
      return yyyymmdd;
    }
  }

  /**
   * 日付型のフォーマット処理
   *
   * @param value
   * @return
   */
  private static String DateFormat(String value) {
    value = value.replaceAll("[^0-9]", "");
    if (value.length() > 8) {
      value = value.substring(0, 8);
    }
    return value;
  }

  // add #11738 印刷情報を使った計算式があると改頁やPDF出力が失敗する 高 start
  /**
   * 数式を評価するメソッド（JavaScriptエンジンを使用）
   *
   * */
  public static String evalMath(String expr) {
    // JavaScriptエンジンを取得
    ScriptEngine engine = new ScriptEngineManager().getEngineByName("JavaScript");
    try {
      // 数式を評価して結果を取得
      Object result = engine.eval(expr);
      return result.toString();
    } catch (ScriptException e) {
      // 計算失敗時にランタイム例外をスロー
      throw new RuntimeException("計算式計算ミスです: " + expr, e);
    }
  }

  /**
   * Excel風の文字列を解析して数式を評価するメソッド
   *
   * */
  public static String parseExcelStyle(String input) {
    // ダブルクォーテーションを削除
    input = input.replace("\"", "");

    // 「&」で文字列を分割（Excelでの文字列連結を模倣）
    String[] parts = input.split("&");

    // 結果を組み立てるためのStringBuilder
    StringBuilder result = new StringBuilder();

    for (String part : parts) {
      part = part.trim(); // 前後の空白を削除

      // 数式のパターンにマッチする場合は評価（例: 2+3 や (5*2)-1 など）
      if (part.matches(".*[\\d)]+[+\\-*/]+[\\d(].*")) {
        part = evalMath(part); // 数式を評価
      }

      // 結果に追加
      result.append(part);
    }

    // 完成した文字列を返す
    return result.toString();
  }
  // add #11738 印刷情報を使った計算式があると改頁やPDF出力が失敗する 高 end
  // add #12324 紹介状の出力時にpat_eventを参照する zhao start
  /**
   * 登録済みデータがあればpat_event.letter_infoを出力する。
   * @param params テンプレート
   * @param reportOutputInfoList 帳票出力情報
   * @param dataKey データ抽出キー
   */
  private void editLetterInfoForScreenDisplay (List<ReportXmlParam> params,
                                               List<Map<String, String>> reportOutputInfoList,
                                               Map<String, Object> dataKey){
    // letterDataがあるかどうか
    if(!dataKey.containsKey("letterDataList")){
      return;
    }
    // 紹介状データを取得する
    ObjectMapper objectMapper = new ObjectMapper();
    List<String> letterDataList = new LinkedList<>();
    if(null != dataKey.get("letterDataList")){
      letterDataList = (List<String>) dataKey.get("letterDataList");
    }
    for (int i = 0; i < letterDataList.size(); i++) {
      Map<String, String> reportOutputInfo = new HashMap<String, String>();
      JsonNode letterDataNode = objectMapper.valueToTree(letterDataList.get(i));
      // JSON文字列から、キーと値を取得する
      Iterator<Map.Entry<String, JsonNode>> fields = letterDataNode.fields();
      while (fields.hasNext()) {
        Map.Entry<String, JsonNode> field = fields.next();
        // キーを取得する
        String fieldName = field.getKey();
        // 値を取得する
        JsonNode fieldValue = field.getValue();
        String value = "";
        // 取得した値はJSON文字列かつ、valueを含める場合、値を取得する
        if (fieldValue.isObject() && fieldValue.has("value")) {
          value = fieldValue.path("value").asText();
        } else {
          value = fieldValue.asText();
        }
        // HTMLタグを除く
        value = Jsoup.parse(value).text();
        // add #12402 紹介状の編集で画像の追加や差し替えができない zhao start
        value = getImageFromS3(value, dataKey.get("facilityCd").toString());
        // add #12402 紹介状の編集で画像の追加や差し替えができない zhao end
        // イメージの場合、パースを設定する
        if (fieldValue.isObject() && fieldValue.has("path")) {
          // add #12402 紹介状の編集で画像の追加や差し替えができない zhao start
          if(!StringUtils.isEmpty(fieldValue.path("path").asText())){
            // add #12402 紹介状の編集で画像の追加や差し替えができない zhao end
            value = fieldValue.path("path").asText();
            // add #12402 紹介状の編集で画像の追加や差し替えができない zhao start
          }
          // add #12402 紹介状の編集で画像の追加や差し替えができない zhao end
        }
        reportOutputInfo.put(formatKey(params, fieldName), value);
      }
      reportOutputInfoList.add(reportOutputInfo);
    }
  }
  /**
   * 登録済みデータがあればpat_event.letter_infoを出力する。
   * @param params テンプレート
   * @param key キー
   * @return editKey 編集後キー（1#L20@decimal）
   */
  private String formatKey(List<ReportXmlParam> params, String key){
    // テンプレート内のパラメータを格納する変数
    List<ReportXmlParam> paramsInTempl = new ArrayList<ReportXmlParam>();
    // テンプレート内と外のparam要素を各リストに追加
    params.forEach(reportXmlParam -> {
      if (!StringUtils.isEmpty(reportXmlParam.getIsInTmpl()) &&
        reportXmlParam.getIsInTmpl().equals(ReportXmlParam.IS_IN_TMPL_YES)) {
        paramsInTempl.add(reportXmlParam);
      }
    });
    // XML内容をループする
    for (ReportXmlParam param : paramsInTempl) {
      // repeatAddressを取得する
      if (param.getRepeatAddress() != null && !param.getRepeatAddress().isEmpty()) {
        String[] cells = param.getRepeatAddress().split(",");
        if (cells != null && cells.length > 0) {
          for (String cell : cells) {
            if (key.equals(cell)) {
              String editKey = "";
              if(!StringUtils.isEmpty(param.getDataType())){
                editKey = String.format("%d%s%s@%s", 1, MULTIPLE_PAGES_SEPARATOR, cell, param.getDataType());
              }
              if(!StringUtils.isEmpty(param.getDispFormat())){
                editKey = String.format("%d%s%s@%s", 1, MULTIPLE_PAGES_SEPARATOR, cell, param.getDataType());
                editKey = String.format("%s@%s", editKey, param.getDispFormat());
              }
              return StringUtils.isEmpty(editKey) ? key:editKey;
            }
          }
        }
      }
    }
    return key;
  }
  // add #12324 紹介状の出力時にpat_eventを参照する zhao end
  // add #12402 紹介状の編集で画像の追加や差し替えができない zhao start
  /**
   * S3からイメージを取得する
   * @param path パース
   * @param facilityCd 施設コード
   */
  private String getImageFromS3(String path, String facilityCd){
    if (StringUtils.isEmpty(path)) {
      return path;
    }
    if(path.contains("/") && path.contains("/image/")){
      // Getting images from S3 service
      String bucket = String.format(s3BucketForImage, facilityCd);
      byte[] excelBytes = reportS3Service.getOutputFileData(bucket, path);
      if (excelBytes == null || excelBytes.length == 0) {
        return path;
      }
      bucket = Base64.getEncoder().encodeToString(excelBytes);
      bucket = String.format("data:image/png+xml;base64,%s", bucket);
      return bucket;
    }
    return path;
  }
  // add #12402 紹介状の編集で画像の追加や差し替えができない zhao end
}
// add #11973 日常点検一覧帳票が正常に出せない limingzhe end
