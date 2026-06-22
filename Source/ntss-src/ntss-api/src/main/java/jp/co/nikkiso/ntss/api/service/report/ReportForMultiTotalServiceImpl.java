//package jp.co.nikkiso.ntss.api.service.report;
//// mod 10546 複数集計出力時にサーバが高負荷になる gjn start
//import com.aspose.cells.SaveFormat;
//import com.aspose.cells.Worksheet;
//import jp.co.nikkiso.ntss.api.constant.ReportConstant;
//import jp.co.nikkiso.ntss.api.domain.report.*;
//import jp.co.nikkiso.ntss.api.service.LogService;
//import jp.co.nikkiso.ntss.api.service.SysDataSetService;
//import jp.co.nikkiso.ntss.api.service.utils.ReportUtils;
//import jp.co.nikkiso.ntss.api.service.utils.ReportZipFile;
//import jp.co.nikkiso.ntss.api.service.utils.TmpFileService;
//import jp.co.nikkiso.ntss.api.utils.AsposeExcelUtil;
//import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
//import jp.co.nikkiso.ntss.core.dao.*;
//import jp.co.nikkiso.ntss.core.entity.*;
//import jp.co.nikkiso.ntss.core.exception.NotExistException;
//import jp.co.nikkiso.ntss.core.exception.NtssException;
//import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
//import jp.co.nikkiso.ntss.core.logger.LogLevel;
//import jp.co.nikkiso.ntss.core.utils.NtssUtils;
//import lombok.extern.slf4j.Slf4j;
//import org.apache.poi.ss.usermodel.Sheet;
//import org.apache.poi.ss.usermodel.Workbook;
//import org.apache.poi.ss.usermodel.WorkbookFactory;
//import org.jsoup.Jsoup;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.beans.factory.annotation.Value;
//import org.springframework.stereotype.Service;
//import org.springframework.util.StringUtils;
//import org.w3c.dom.Element;
//import org.w3c.dom.NodeList;
//
//import javax.imageio.ImageIO;
//import javax.script.ScriptEngine;
//import javax.script.ScriptEngineManager;
//import javax.script.ScriptException;
//import java.awt.*;
//import java.awt.image.BufferedImage;
//import java.io.*;
//import java.math.BigDecimal;
//import java.nio.charset.StandardCharsets;
//import java.nio.file.Files;
//import java.nio.file.Path;
//import java.text.ParseException;
//import java.text.ParsePosition;
//import java.text.SimpleDateFormat;
//import java.time.LocalDate;
//import java.time.format.DateTimeFormatter;
//import java.time.temporal.ChronoUnit;
//import java.util.*;
//import java.util.List;
//import java.util.concurrent.*;
//import java.util.concurrent.atomic.AtomicBoolean;
//import java.util.concurrent.atomic.AtomicInteger;
//import java.util.concurrent.atomic.AtomicReference;
//import java.util.regex.Matcher;
//import java.util.regex.Pattern;
//import java.util.stream.Collectors;
//import java.util.stream.Stream;
//
//import static java.util.stream.Collectors.toList;
//import static java.util.stream.Collectors.toMap;
//
///**
// * 帳票の複数集計出力Service実装クラス.
// */
//@Service
//@Slf4j
//public class ReportForMultiTotalServiceImpl implements ReportForMultiTotalService {
//
//  private static final String PAT_ID_TO_C = "patIdToC";
//
//  /**
//   * 帳票出力情報のKey項目に使用する複数ページ区切り文字列.
//   */
//  private static final String MULTIPLE_PAGES_SEPARATOR = "#";
//
//  /**
//   * Excelシート名プレフィックス
//   */
//  private static final String SHEET_NAME_PREFIX = "ページ";
//
//  /**
//   * 週間医材集計表 を取得するsql_cd
//   */
//  private static final long SQL_CD_SUPPLIES_CNT = 149L;
//  /**
//   * 外来合計 を取得するsql_cd
//   */
//  private static final long SQL_CD_OUT_PAT_CNT = 150L;
//  /**
//   * 入院合計 を取得するsql_cd
//   */
//  private static final long SQL_CD_HOSP_PAT_CNT = 151L;
//  /**
//   * 複数セットの計上票の出力最大ページ数
//   */
//  private static final Integer SET_MAX_PAGE = 100;
//
//  // add #10857 帳票内に同項目が複数あると設定値を取り違える limingzhe start
//  private static final Long PRINT_INFO_CODE = 0L;
//
//  @Autowired
//  ReportServiceImpl reportServiceImpl;
//  // add #10857 帳票内に同項目が複数あると設定値を取り違える limingzhe end
//
//  // mod 10546 複数集計出力時にサーバが高負荷になる gjn start
//  /**
//   * 最大パラメータバイト制限
//   */
//  private static final Integer SQL_MAX_PARAM_BYTE = 65536;
//  // mod 10546 複数集計出力時にサーバが高負荷になる gjn end
//
//  /**
//   * 4種類の集計タイプ：（合計：total、最大値：max、最小値：min、平均値：avg、プロジェクト値：last）
//   */
//  private static final String TOTAL = "total";
//  private static final String MAX = "max";
//  private static final String MIN = "min";
//  private static final String AVG = "avg";
//  private static final String LAST = "last";
//
//  /**
//   * 計算用横縦集合計フィールド接続記号
//   */
//  private static final String CONNECTION_SYMBOL = "|";
//
//  /**
//   * 複数帳票の切替(10枚)
//   */
//  private AtomicInteger iLoop = new AtomicInteger(1);
//
//  /**
//   * 集計データサイズ判定用
//   */
//  AtomicBoolean totalListFlg = new AtomicBoolean(false);
//  private List<Map<Long, List<Map<String, Object>>>> totalDataList = new CopyOnWriteArrayList<>();
//  private List<String> strKurNameList = new CopyOnWriteArrayList<String>();
//
//  /**
//   * テンプレートの繰返回数(縦)
//   */
//  private AtomicInteger repeatCountH = new AtomicInteger(0);
//  /**
//   * テンプレートの繰返回数(横)
//   */
//  private AtomicInteger repeatCountV = new AtomicInteger(0);
//// del #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen start
//  // /**
//  //  * テンプレートの改頁
//  //  */
//  // private String isNewPage = "";
//  //
//  // /**
//  //  * 横の集計単位属性
//  //  */
//  // private String totalUnitV = "";
//  // /**
//  //  * 集計単位日付属性
//  //  */
//  // private String totalUnitDate = "";
//  // /**
//  //  * 縦の集計単位属性
//  //  */
//  // private String totalUnitH = "";
//  // /**
//  //  * 表示内容属性
//  //  */
//  // private String totalContents = "";
//  // /**
//  //  * 表示変換属性
//  //  */
//  // private String totalConversion = "";
//  // /**
//  //  * 縦の合計属性
//  //  */
//  // private String totalCountH = "";
//  // /**
//  //  * 横の合計属性
//  //  */
//  // private String totalCountV = "";
//  // del #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen end
//  /**
//   * 横の集計単位のList
//   */
//  private List<String> totalUnitVList = new CopyOnWriteArrayList<>();
//  /**
//   * 縦の合計属性のList
//   */
//  private List<String> totalUnitHList = new CopyOnWriteArrayList<>();
//
//  // del #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen start
//  // /**
//  //  * 横の合計属性の配列
//  //  */
//  // private String[][] arrtotalUnitV;
//  // del #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen end
//
////  public void setArrtotalUnitV(int row, int col, String value) {
////    synchronized (lock) {
////      arrtotalUnitV[row][col] = value;
////    }
////  }
////  public String getArrtotalUnitV(int row, int col) {
////    synchronized (lock) {
////      return arrtotalUnitV[row][col];
////    }
////  }
//  // del #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen start
//  // /**
//  //  * 縦の合計属性の配列
//  //  */
//  // private String[][] arrtotalUnitH;
//  // del #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen end
//
////  public void setArrtotalUnitH(int row, int col, String value) {
////    synchronized (lock) {
////      arrtotalUnitH[row][col] = value;
////    }
////  }
////  public String getArrtotalUnitH(int row, int col) {
////    synchronized (lock) {
////      return arrtotalUnitH[row][col];
////    }
////  }
//
//  /**
//   * 集計単位が日付形の判定用
//   */
//  private AtomicBoolean isDateType = new AtomicBoolean(false);
//
//
//
//  private static final String DISPLAY_HTML_ERROR = "ｴﾗｰ";
//
//  /**
//   * 計算式に基づく計算が失敗した場合に設定する文字列.
//   */
//  private static final String FAILED_CALC = "failed calc";
//
//  private static final String TMP_SKIP_COUNT = "tmpSkipCount";
//
//  /**
//   * 集計の合計を表示しない
//   */
//  private static final String TOTAL_COUNTS_DISPLAY_N = "0";
//  /**
//   * 集計の合計を表示する
//   */
//  private static final String TOTAL_COUNTS_DISPLAY_Y = "1";
//
//  /**
//   * 集計改ページ用のオフセット2
//   */
//  private static final int TOTAL_COUNTS_OFFSET_2 = 2;
//  /**
//   * 集計改ページ用のオフセット3
//   */
//  private static final int TOTAL_COUNTS_OFFSET_3 = 3;
//
//  /**
//   * 帳票マスタのDaoインタフェース.
//   */
//  @Autowired
//  private MstReportDao mstReportDao;
//
//  /**
//   * 帳票ファイル取得のServiceインタフェース.
//   */
//  @Autowired
//  private ReportS3Service reportS3Service;
//
//  @Autowired
//  ReportService reportService;
//
//  @Autowired
//  private LogService logService;
//
//  /**
//   * SysDataSetから帳票出力情報を取得するServiceインタフェース.
//   */
//  @Autowired
//  private SysDataSetService sysDataSetService;
//
//  /**
//   * 帳票のチャート生成のServiceインタフェース.
//   */
//  @Autowired
//  private ReportChartService reportChartService;
//
//  @Autowired
//  private TmpFileService tmpFileService;
//
//  /**
//   * 印刷ファイル作成の為の一時保存Path.
//   */
//  @Value("${ntss.report.createTmpDir}")
//  private String createTmpDir;
//
//  @Value("${ntss.pat-event.s3-bucket:#{null}}")
//  private String s3BucketforImage;
//
//  @Autowired
//  private PatPersonalMainDao patPersonalMainDao;
//
//  /**
//   * スケジュール表Dao.
//   */
//  @Autowired
//  private ScheduleListDao scheduleListDao;
//
//  // add #11260 テンプレート設定した帳票の出力で高負荷になることがある 房 start
//  @Autowired
//  private ReportWithAsposeApiService reportWithAsposeApiService;
//  // add #11260 テンプレート設定した帳票の出力で高負荷になることがある 房 end
//
//  /**
//   * 帳票定義XMLを取得します.
//   *
//   * @param mstReport     帳票マスタEntity
//   * @param reportZipFile 帳票Zipファイル
//   * @return 帳票定義XML
//   */
//  private String getReportXml(MstReport mstReport, ReportZipFile reportZipFile) {
//    // 帳票定義XMLファイルを取得する
//    String reportXml = reportZipFile.getFileToString(mstReport.getReportPath().getXmlFilename());
//    if (StringUtils.isEmpty(reportXml)) {
//      List<String> fileList = reportZipFile.getFileToString();
//      throw new NtssException("帳票定義XMLファイルを取得できません。"
//        + "MstReport:[" + mstReport.getReportPath().getXmlFilename() + "]"
//        + " ReportZipFile:[" + fileList.toString() + "]"
//      );
//    }
//    return reportXml;
//  }
//
//  /**
//   * 帳票Zipファイルを取得します.
//   *
//   * @param mstReport 帳票マスタEntity
//   * @return 帳票Zipファイル
//   */
//  private ReportZipFile getReportZip(MstReport mstReport) {
//    return new ReportZipFile(
//      reportS3Service.getReportFile(
//        mstReport.getReportPath().getBucket(),
//        mstReport.getReportPath().getReportZip(),
//        mstReport.getUpDate()));
//  }
//
//  /**
//   * 計算式から <code>[SqlCode.データ項目コード]</code>を取得します.
//   *
//   * @param formula 計算式
//   * @return <code>[SqlCode.データ項目コード]</code>のリスト
//   */
//  private List<String> getSqlCodeAndDataCodes(String formula) {
//    List<String> result = new ArrayList<>();
//    Matcher m = Pattern.compile("\\[([^\\[\\]]+)\\]").matcher(formula);
//    while (m.find()) {
//      result.add(m.group(1));
//    }
//    return result;
//  }
//
//  @Override
//  public byte[] getReportExcelFileForMultiTotal(Long reportCd, Map<String, Object> dataKey) {
//    MstReport mstReport = mstReportDao.selectByCd(reportCd);
//    Long ordNo = null;
//    // S3から帳票定義XML、帳票デザインExcelが格納されたZipファイルを取得する
//    ReportZipFile reportZipFile = getReportZip(mstReport);
//    // SqlCodeをもとに帳票に出力する情報を取得する
//    String reportXml = this.getReportXml(mstReport, reportZipFile);
//    List<ReportXmlParam> params = ReportUtils.getParamElements(reportXml);
//    String getColWidth = "";
//    String getRowHeight = "";
//    if (params.size() > 0) {
//      getColWidth = "";
//      getRowHeight = "";
//      for (int p = 0; p < params.size(); p++) {
//        if ("".equals(params.get(p).getDataCode()) && "byte[]".equals(params.get(p).getDataType())) {
//          getColWidth = params.get(p).getColWidth();
//          getRowHeight = params.get(p).getRowHeight();
//        }
//      }
//    }
//    String num = "";
//    for (ReportXmlParam param : params) {
//      List<ReportXmlFilterTable> filters = param.getReportXmlFilters();
//      if (filters == null || filters.size() == 0) {
//        continue;
//      }
//      num = filters.get(0).getCode();
//      dataKey.put("examItemCd", num);
//      break;
//    }
//    Map<Long, List<Map<String, Object>>> reportInfo = new HashMap<>();
//
//    Map<String, Long> patIdToCMap = new HashMap<>();
//    Map<String, String> htmlIdCountMap = new HashMap<>();
//    dataKey.put("facilityCd", mstReport.getFacilityCd());
//    long startTime = System.currentTimeMillis();
//    createTotalReportHtml(mstReport, dataKey, patIdToCMap, htmlIdCountMap);
//    long endTime = System.currentTimeMillis();
//    long executionTime = (endTime - startTime);
//    System.err.println("createTotalReportHtml总耗时 total: （秒）" + executionTime / 1000 + " milli");
//    // mod #10858 「##=[##データ項目」」の形式で null が出力される 杜 start
//    //final Map<String, String> calcResult = getCalcResult(params, reportInfo, htmlIdCountMap);
//    final Map<String, String> calcResult = new HashMap<>();
//    // mod #10858 「##=[##データ項目」」の形式で null が出力される 杜 end
//    // mod #11260 テンプレート設定した帳票の出力で高負荷になることがある 房 start
////    try (Workbook wb = reportService.getReportExcelWorkbook(mstReport, reportZipFile, params, htmlIdCountMap, calcResult, ordNo, dataKey, getColWidth, getRowHeight)) {
////      ByteArrayOutputStream bos = new ByteArrayOutputStream();
////      // add 10546 複数集計出力時にサーバが高負荷になる gjn start
////      // todo excelの計算式を有効にする
////      FormulaEvaluator evaluator = wb.getCreationHelper().createFormulaEvaluator();
////      evaluator.evaluateAll();
////      // add 10546 複数集計出力時にサーバが高負荷になる gjn end
////      try {
////        wb.write(bos);
////      } finally {
////        bos.close();
////      }
////      byte[] readAllBytes = bos.toByteArray();
////      return readAllBytes;
//    try{
//      com.aspose.cells.Workbook wb = reportWithAsposeApiService.getReportExcelWorkbook(mstReport, reportZipFile, params, htmlIdCountMap, calcResult, ordNo, dataKey, getColWidth, getRowHeight);
//      wb.calculateFormula(true);
//      // 一時ファイルに出力
//      ByteArrayOutputStream o = new ByteArrayOutputStream();
//      wb.save(o, SaveFormat.XLSX);
//      wb.dispose();
//      return o.toByteArray();
//    } catch (Exception e) {
//      // エラーメッセージ
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage("帳票Excelファイルの出力に失敗しました。：" + NtssUtils.ExcetionStackTraceToString(e));
//      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
//      throw new NtssException("帳票Excelファイルの出力に失敗しました。");
//    }
//    // mod #11260 テンプレート設定した帳票の出力で高負荷になることがある 房 end
//  }
//
//  /**
//   * 集計帳票情報(HTML)の取得.
//   *
//   * @param mstReport 出力する帳票マスタ情報
//   * @param dataKey   帳票出力データを取得する為のパラメータ情報
//   * @return 帳票HTML
//   */
//  public void createTotalReportHtml(MstReport mstReport,
//                                    Map<String, Object> dataKey,
//                                    Map<String, Long> patIdToCMap,
//                                    Map<String, String> outPutHtml) {
//    // S3から帳票定義XML、帳票デザインHTMLが格納されたZipファイルを取得.
//    ReportZipFile reportZipFile = getReportZip(mstReport);
//    // 帳票定義XMLを取得.
//    String reportXml = getReportXml(mstReport, reportZipFile);
//    // 作成したhtmlを格納する変数
//    // mod 10546 複数集計出力時にサーバが高負荷になる gjn start
//    //String html = "";
//    // mod 10546 複数集計出力時にサーバが高負荷になる gjn end
//    // htmlの<td>IDを格納する変数
//    //String key = "";
//    // テンプレート有無(true:テンプレートあり、false:テンプレートなし)
//    boolean hasTemplate = false;
//    // テンプレート有無のID
////    String dispID = "";
////    String strGroupId = "";
//    Map<Long, List<Map<String, Object>>> reportInfoForTempl = new HashMap<>();
//    //複数セットの帳票タイプ区分（[1：スケジュール表,2：週間薬剤集計表, 3：水質調査一覧]）
//    Integer reportType = mstReport.getReportType();
//    try {
//      hasTemplate = hasTemplate(reportXml);
//    } catch (NtssException ex) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(ex.getMessage());
//      eventLogMessage.setFacilityCd(mstReport.getFacilityCd());
//      logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
//      // テンプレート有無の判定に失敗した場合、空のhtmlを返す.
//      //return html;
//      throw new NtssException("帳票テンプレートにTemplateが含まれているかどうかを判定する際にエラーが発生しました");
//    }
//    // 帳票デザインHTMLファイルを取得する
//    String reportHtml = reportZipFile.getFileToString(mstReport.getReportPath().getHtmlFilename());
//
//    // 帳票定義XMLのparam要素のリストを取得.
//    List<ReportXmlParam> reportXmlParamsList = ReportUtils.getParamElements(reportXml);
//    // テンプレート内のパラメータを格納する変数
//    List<ReportXmlParam> paramsInTempl = new ArrayList<ReportXmlParam>();
//    // テンプレート外のパラメータを格納する変数
//    List<ReportXmlParam> paramsOutTempl = new ArrayList<ReportXmlParam>();
//    // テンプレート内と外のparam要素を各リストに追加
//    reportXmlParamsList.forEach(reportXmlParam -> {
//      if (!StringUtils.isEmpty(reportXmlParam.getIsInTmpl()) &&
//        reportXmlParam.getIsInTmpl().equals(ReportXmlParam.IS_IN_TMPL_YES)) {
//        paramsInTempl.add(reportXmlParam);
//      } else {
//        paramsOutTempl.add(reportXmlParam);
//      }
//    });
//    totalDataList.clear();
//    strKurNameList.clear();
//    //strTempData = new String[0][];
//    isDateType.set(false);
//    // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen start
//    // arrtotalUnitH = new String[0][];
//    // arrtotalUnitV = new String[0][];
//    String[][] arrtotalUnitH = new String[0][];
//    String[][] arrtotalUnitV = new String[0][];
//    String[][][] param1 = new String[2][][];
//    // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen end
//    Map<String, Integer> pageCountMap = new HashMap<String, Integer>();
//    pageCountMap.put("COUNT_PAGE_ROW", 1);
//    pageCountMap.put("COUNT_PAGE_LINE", 1);
//    pageCountMap.put("COUNT_ROW", 1);
//    pageCountMap.put("COUNT_LINE", 1);
//    pageCountMap.put("COUNT_PAGE", 1);
//    // 生成したhtmlを格納するリスト
//    List<String> newHtmlList = new ArrayList<>();
//    if (paramsInTempl.isEmpty()) {
//      hasTemplate = false;
//    }
//    // テンプレート内の処理
//    if (hasTemplate) {
//      // テンプレート内のデータを取得する為のdataKeyを取得
//      List<Map<String, Object>> dataKeyInOfTemplateList = (List<Map<String, Object>>) dataKey.get(ReportConstant.ReportDataKey.TEMPLATE_PARAMS);
//      // グループIDをキー、同じグループIDのparamのリストでマップ化
//      Map<String, List<ReportXmlParam>> groupIdListInTmpl =
//        paramsInTempl.stream()
//          .filter(param -> param.isTmplRepeat())
//          .collect(Collectors.groupingBy(ReportXmlParam::getGroupId));
//      // 出力しているテンプレートインデックス
//      // ※1テンプレート毎に処理する際のカレントテンプレートインデックス
//      Integer templateIndex = 1;
//      // 処理中に使用するテンプレートインデックス
//      Integer targetTemplateIndex = templateIndex;
//      ReportXmlTmplRepeat tmplRepeatAll = paramsInTempl.get(0).getReportXmlTmplRepeat();
//      repeatCountH.set(tmplRepeatAll.getRepeatCountH());
//      repeatCountV.set(tmplRepeatAll.getRepeatCountV());
//      // del #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen start
//      // isNewPage = String.valueOf(tmplRepeatAll.getIsNewPage());
//      // del #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen end
//      int lineFeed = repeatCountV.get();
//      ReportXmlTotalTable totalTable = paramsInTempl.get(0).getReportXmlTotalTable();
//// mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen start
//      // totalUnitV = totalTable.getUnitV();
//      // totalUnitDate = totalTable.getUnitDate();
//      // totalUnitH = totalTable.getUnitH();
//      // totalContents = totalTable.getContents();
//      // totalConversion = totalTable.getConversion();
//      // totalCountH = totalTable.getCountH();
//      // totalCountV = totalTable.getCountV();
//      String totalUnitV = totalTable.getUnitV();
//      String totalUnitDate = totalTable.getUnitDate();
//      String totalUnitH = totalTable.getUnitH();
//      String totalContents = totalTable.getContents();
//      String totalConversion = totalTable.getConversion();
//      String totalCountH = totalTable.getCountH();
//      String totalCountV = totalTable.getCountV();
//      Map<String, String> param2 = new HashMap<>();
//      param2.put("totalUnitV", totalUnitV);
//      param2.put("totalUnitDate", totalUnitDate);
//      param2.put("totalUnitH", totalUnitH);
//      param2.put("totalContents", totalContents);
//      param2.put("totalConversion", totalConversion);
//      param2.put("totalCountH", totalCountH);
//      param2.put("totalCountV", totalCountV);
//      // add #11950 複数集計帳票の印刷で出力可能なページ数だが100ページ制限となり出力できない。 limingzhe start
//      param2.put("effectDateFlag", mstReport.getReportType() == 3 ? "1" : "0");
//      // add #11950 複数集計帳票の印刷で出力可能なページ数だが100ページ制限となり出力できない。 limingzhe end
//      // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen end
//      // セットカウント内のデータ型
//      String InTemplType = paramsInTempl.get(0).getDataType();
//      // 集計内データ型集計内データ型がstringの場合は、「項目値」として帳票を出力するしかありません
//      if ("string".equals(InTemplType)) {
//        totalContents = "項目値";
//        // スケジュールテーブルは日の出力のみで、日曜日には出力できません（帳票ツールの配置が日曜日であっても）
//        if (reportType == 1 && "曜日".equals(totalUnitDate)) {
//          totalUnitDate = "日";
//        }
//      }
//      // 集計単位を取得する
//      totalUnitVList = Arrays.asList(totalUnitV.replace("##", "").split(",")).stream().distinct().collect(Collectors.toList());
//      totalUnitHList = Arrays.asList(totalUnitH.replace("##", "").split(",")).stream().distinct().collect(Collectors.toList());
//      // セルID取得
//      // 横の集計単位のIDList
//      List<String> strUnitVId = getTotalId(totalUnitVList, paramsOutTempl);
//      // 縦の合計属性のIDList
//      List<String> strUnitHId = getTotalId(totalUnitHList, paramsOutTempl);
//      // セルIDにより、集計単位順を編集する
//      if (strUnitVId.size() > 0) {
//        totalUnitVList = getTotalDataCode(strUnitVId, paramsOutTempl);
//      }
//      if (strUnitHId.size() > 0) {
//        totalUnitHList = getTotalDataCode(strUnitHId, paramsOutTempl);
//      }
//      // 集計データに横の集計単位と縦の集計単位を編集する
//      String[][] strB = new String[0][];
//      List<String[][]> strBList = new ArrayList<>();
//      // 行数データ
//      int Lines;
//      // 列数データ
//      int Column;
//      // param要素のsqlCd
//      Long sqlCd = 0l;
//      // 改行計数
//      int linesCount = 0;
//
//      // データキーからテンプレート外の項目を取得
//      // ※テンプレート有無に関わらず、このデータキーは使用する
//      Map<String, Object> dataKeyOutTempl = getOutOfTemplateDataKey(dataKeyInOfTemplateList.get(0));
//      // add 11010 スケジュール表出力時の処理が不足している gjn start
//      if (!dataKeyOutTempl.containsKey("patIds") && dataKey.containsKey("patIds")) {
//        dataKeyOutTempl.put("patIds", dataKey.get("patIds"));
//      }
//      // add 11010 スケジュール表出力時の処理が不足している gjn end
//      // ---------------------------------------
//      // テンプレート外の値を埋め込む処理
//      // --------------------------------------
//      // mod 10546 複数集計出力時にサーバが高負荷になる gjn start
//      createPatientReportHtmlOutTemplateForCount(
//        mstReport,
//        reportZipFile, //add
//        reportHtml, //add
//        reportXmlParamsList,
//        paramsOutTempl,
//        dataKeyOutTempl,
//        pageCountMap,
//        dataKey,
//        reportInfoForTempl,
//        outPutHtml,
//        paramsInTempl,
//        dataKeyInOfTemplateList);
//      // 一番最初に展開する為のhtml
//      //html = htmlList.get(0);
//      // mod 10546 複数集計出力時にサーバが高負荷になる gjn end
//
//      // 集計データに横の集計単位と縦の集計単位を編集する
//      Map<String, Object> inOfTemplateList = dataKeyInOfTemplateList.get(0);
//      inOfTemplateList.put("regOrderClassList", dataKey.get("regOrderClassList"));  //regOrderClassList(透析前、透析後、その他)の条件を追加し、条件を絞り込みます。
//      /**
//       * 帳票テンプレートに基づいて絵表を配置する、
//       * 縦テーブルの前後に2つ多く作成し、縦1つ目は放集計項目、縦1つ目は放集計外の合計、
//       * 横テーブルは、集計外合計（縦）のために1つ多く作成されます
//       * これを類推すると、横縦に位置を入れ替えると、多く作られた表は、集計の外も逆さまにすればよい
//       */
//      // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen start
//      // strB = infostrB(paramsInTempl, inOfTemplateList, paramsOutTempl, reportInfoForTempl);
//      // add 11010 スケジュール表出力時の処理が不足している gjn start
//      strB = infostrB(paramsInTempl, inOfTemplateList, reportInfoForTempl, param1, param2, dataKey);
//      // add 11010 スケジュール表出力時の処理が不足している gjn end
//      arrtotalUnitH = param1[0];
//      arrtotalUnitV = param1[1];
//      // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen end
//      // 表のコピーを描画
//      String[][] b = new String[strB.length][];
//
//      // 前回編集済み集計データのセット用配列，只在第一次copy strB
//      if (strB.length != 0) {
//        for (int i = 0; i < strB.length; i++) {
//          b[i] = new String[strB[i].length];
//          System.arraycopy(strB[i], 0, b[i], 0, strB[i].length);
//        }
//      }
//      // mod 10546 複数集計出力時にサーバが高負荷になるgjn start
//      // 行数取得
//      Lines = !Objects.isNull(strB) ? strB.length : 0;
//      totalListFlg.set(true);
//      // 複数集計の場合、前回編集済み集計データを保存する (b[0][]の最初の要素をstrBに割り当てる[0][])
//      if (b != null && b.length != 0) {
//        strB[0] = new String[b[0].length];
//        System.arraycopy(b[0], 0, strB[0], 0, b[0].length);
//      }
//      // 列数取得
//      Column = Lines==0 ? 0 : strB[0].length;
//      if (Lines == 0 && Column == 0) {
//        return;
//      }
//      // mod 10546 複数集計出力時にサーバが高負荷になる gjn end
//      // 改行計数を計算する
//      linesCount = Lines - TOTAL_COUNTS_OFFSET_2;
//      // 集計データ行数＞印字行数の場合、改行計数が印字行数を設定する。
//      if (Lines >= lineFeed + TOTAL_COUNTS_OFFSET_2) {
//        linesCount = lineFeed;
//      }
//      // 1テンプレートに出力する情報を取得.
//      // ※SQLの実行結果によっては、1テンプレートでは収まらない件数が取得される場合がある.
//      Map<Long, List<Map<String, Object>>> reportInfoForInTempl = totalDataList.get(0);
//      // グループ毎に処理
//      for (String groupId : groupIdListInTmpl.keySet()) {
//        // テンプレートインデックス
//        targetTemplateIndex = templateIndex;
//        // グループIDに該当するparamのリストを取得
//        List<ReportXmlParam> paramListByGroupId = groupIdListInTmpl.get(groupId);
//        if (paramListByGroupId.isEmpty()) {
//          continue;
//        }
//        // テンプレートに埋め込むデータを保持するマップ
//        //  key : 値を埋め込むhtmlのid属性
//        //  value : 埋め込む値
//        //Map<String, String> reportOutputInfoForInTempl = new HashMap<>();
//
//        // レコードインデックス
//        int recIndex = 0;
//        // add #11293 【標準帳票】水質検査帳票の課題対応 吉 start
//        List<String> countResulList = new ArrayList<>();
//        // add #11293 【標準帳票】水質検査帳票の課題対応 吉 end
//        if (totalListFlg.get() && reportInfoForInTempl.size() > 0) {
//          while (true) {
//            // 初期化フラグ
//            boolean isCont = false;
//            // 1つのグループIDの処理
//            // 同一グループIDに属するparam要素を1つずつ処理
//            for (int index2 = 0; index2 < paramListByGroupId.size(); index2++) {
//              // paramを取得
//              ReportXmlParam param = paramListByGroupId.get(index2);
//              // sqlCdが未登録
//              if (StringUtils.isEmpty(param.getSqlCode())) {
//                continue;
//              }
//              // param要素のsqlCdを取得
//              sqlCd = Long.parseLong(param.getSqlCode());
//              // sqlCdの検索結果を取得
//              List<Map<String, Object>> reportInfo = reportInfoForInTempl.get(sqlCd);
//              if (reportInfo == null) {
//                sqlCd = 0L;
//                for (Map.Entry<Long, List<Map<String, Object>>> m : reportInfoForInTempl.entrySet()) {
//                  if (!StringUtils.isEmpty(m.getValue().get(0).get(param.getDataCode()))) {
//                    sqlCd = m.getKey();
//                    break;
//                  }
//                }
//                if (sqlCd == 0L) {
//                  continue;
//                } else {
//                  reportInfo = reportInfoForInTempl.get(sqlCd);
//                }
//              }
//              if (param.getReportXmlGroup() != null && param.getReportXmlGroup().getReportXmlFilters().size() != 0) {
//                List<Map<String, Object>> filteredList = reportServiceImpl.filterReportInfo(param, reportInfoForInTempl.get(sqlCd));
//                if (!filteredList.isEmpty()) {
//                  reportInfoForInTempl.get(sqlCd).clear();
//                  reportInfoForInTempl.get(sqlCd).addAll(filteredList);
//                }
//              }
//              // 検索結果件数 <= recIndex の場合は次のparamを処理
//              // ※同一グループIDで、param要素毎にsqlCdの結果の件数が異なる為
//              //   このチェックで、sqlCdの検索結果の件数を超えないかをチェックする.
//              if (reportInfo.size() <= recIndex) {
//                continue;
//              }
//
//              // 複数縦の合計属性の編集処理
//              int n = 1;
//              if (isDateType.get()) {
//                for (int i = 1; i < arrtotalUnitV.length; i++) {
//                  for (int j = 0; j < totalDataList.get(0).get(sqlCd).size(); j++) {
//                    Map<String, Object> record = totalDataList.get(0).get(sqlCd).get(j);
//                    if (arrtotalUnitV[0][n].equals(record.get(arrtotalUnitV[0][0]))) {
//                      arrtotalUnitV[i][n] = String.valueOf(record.get(arrtotalUnitV[i][0]));
//                    } else {
//                      continue;
//                    }
//                    if (n > arrtotalUnitV[0].length - 1) {
//                      break;
//                    }
//                    n = n + 1;
//                  }
//                  n = 1;
//                }
//              } else {
//                // add #11293 水質検査帳票の課題対応 2025/04/16 limingzhe start
//                if(sqlCd == 127l){
//                  Map<Long, List<Map<String, Object>>> infoInTempl = totalDataList.get(0).get(sqlCd).stream()
//                    .collect(Collectors.groupingBy(item -> Long.parseLong(item.get("survey_point_cd").toString()), LinkedHashMap::new, Collectors.toCollection(ArrayList::new)));
//                  for (int i = 1; i < arrtotalUnitH.length; i++) {
//                    for (Long pId : infoInTempl.keySet()) {
//                      List<Map<String, Object>> recordList = infoInTempl.get(pId);
//                      if(recordList.size() > 0){
//                        arrtotalUnitH[i][n] = String.valueOf(recordList.get(0).get(arrtotalUnitH[i][0]));
//                      }
//                      n = n + 1;
//                    }
//                    n = 1;
//                  }
//                }
//                else {
//                // add #11293 水質検査帳票の課題対応 2025/04/16 limingzhe end
//                  for (int i = 1; i < arrtotalUnitH.length; i++) {
//                    for (int j = 0; j < totalDataList.get(0).get(sqlCd).size(); j++) {
//                      Map<String, Object> record = totalDataList.get(0).get(sqlCd).get(j);
//                      if (arrtotalUnitH[0][n].equals(record.get(arrtotalUnitH[0][0]))) {
//                        // 正常値範囲の特別な編集処理
//                        if ("normal_value".equals(arrtotalUnitH[i][0])) {
//                          if ((!"".equals(record.get("upper")) && !"null".equals(record.get("upper"))) && ("".equals(record.get("lower")) || "null".equals(record.get("lower")))) {
//                            arrtotalUnitH[i][n] = record.get("upper") + "以下";
//                          } else if (("".equals(record.get("upper")) || "null".equals(record.get("upper"))) && (!"".equals(record.get("lower")) && !"null".equals(record.get("lower")))) {
//                            arrtotalUnitH[i][n] = record.get("lower") + "以上";
//                          } else if (!"".equals(record.get("upper")) && !"null".equals(record.get("upper")) && !"".equals(record.get("lower")) && !"null".equals(record.get("lower"))) {
//                            arrtotalUnitH[i][n] = record.get("lower") + "～" + record.get("upper");
//                          } else {
//                            arrtotalUnitH[i][n] = "";
//                          }
//                        } else {
//                          arrtotalUnitH[i][n] = String.valueOf(record.get(arrtotalUnitH[i][0]));
//                        }
//                      } else {
//                        continue;
//                      }
//                      if (n > arrtotalUnitH[0].length - 1) {
//                        break;
//                      }
//                      n = n + 1;
//                    }
//                    n = 1;
//                  }
//                // add #11293 水質検査帳票の課題対応 2025/04/16 limingzhe start
//                }
//                // add #11293 水質検査帳票の課題対応 2025/04/16 limingzhe end
//              }
//              // 初期化フラグをtrueに変更
//              isCont = true;
//              // paramに登録されているsqlCdに該当する1レコードを取得
//              Map<String, Object> record = reportInfoForInTempl.get(sqlCd).get(recIndex);
//              // add #11293 【標準帳票】水質検査帳票の課題対応 吉 start
//              if(sqlCd == 127L && "".equals(record.get(param.getDataCode()))){
//                if(countResulList.size()>0){
//                  String numi = countResulList.get(countResulList.size()-1);
//                  int j = Integer.valueOf(numi.split("_")[1]);
//                  int i = Integer.valueOf(numi.split("_")[0]);
//                  int conunt = Column-3;
//                  if(i == conunt || conunt == 1){
//                    countResulList.add(1+"_"+(j+1));
//                  }else{
//                    countResulList.add((i+1)+"_"+j);
//                  }
//                }else{
//                  countResulList.add(1+"_"+1);
//                }
//                targetTemplateIndex = targetTemplateIndex + 1;
//                break;
//              }
//              // add #11293 【標準帳票】水質検査帳票の課題対応 吉 end
//              // 縦の集計単位を取得する
//              String valueTotalUnitH = "";
//              if (isDateType.get()) {
//                valueTotalUnitH = reportServiceImpl.formatValue(param, record.get(totalUnitVList.get(0)));
//              } else {
//                valueTotalUnitH = reportServiceImpl.formatValue(param, record.get(totalUnitHList.get(0)));
//              }
//              if ("null".equals(valueTotalUnitH)) {
//                valueTotalUnitH = reportServiceImpl.formatValue(param, record.get(param.getDataCode()));
//              }
//              valueTotalUnitH = reportServiceImpl.convertValue(param, valueTotalUnitH);
//
//              // 表示内容を取得する
//              String valueNoLoop = "";
//              if (sqlCd == 95L && ("rst_in_out_class".equals(param.getDataCode()) || "in_out_class".equals(param.getDataCode()))) {
//                if (StringUtils.isEmpty(record.get("rst_in_out_class"))) {
//                  valueNoLoop = reportServiceImpl.formatValue(param, record.get("in_out_class"));
//                  if ("3".equals(valueNoLoop)) {
//                    valueNoLoop = "";
//                  } else {
//                    valueNoLoop = reportServiceImpl.convertValue(param, valueNoLoop) + "（予定）";
//                    valueTotalUnitH = valueNoLoop;
//                  }
//                } else {
//                  valueNoLoop = reportServiceImpl.formatValue(param, record.get("rst_in_out_class"));
//                  if ("3".equals(valueNoLoop)) {
//                    valueNoLoop = "";
//                  } else {
//                    valueNoLoop = reportServiceImpl.convertValue(param, valueNoLoop) + "（実績）";
//                    valueTotalUnitH = valueNoLoop;
//                  }
//                }
//              } else {
//                valueNoLoop = reportServiceImpl.formatValue(param, record.get(param.getDataCode()));
//                valueNoLoop = reportServiceImpl.convertValue(param, valueNoLoop);
//              }
//              if (sqlCd == 152L) {
//                if (StringUtils.isEmpty(record.get("pat_name"))) {
//                  continue;
//                }
//                if ("first_name_is_same".equals(param.getDataCode())) {
//                  valueNoLoop = reportServiceImpl.formatValue(param, record.get("pat_last_name")) + valueNoLoop;
//                } else if ("pat_last_name".equals(param.getDataCode())) {
//                  valueNoLoop = reportServiceImpl.formatValue(param, record.get("pat_last_name"));
//                }
//                // add #11572 スケジュール表の同姓同名の再検討 sunsy start
//                if ("pat_name_is_same".equals(param.getDataCode())) {
//                  valueNoLoop = reportServiceImpl.formatValue(param, record.get("pat_name")) + valueNoLoop;
//                }
//                // add #11572 スケジュール表の同姓同名の再検討 sunsy end
//              }
//              // 帳票データの時間を取得する
//              String strTemplateListDate = DateFormat(String.valueOf(dataKeyInOfTemplateList.get(0).get("date")));
//              // 集計データの時間を取得
//              String strRecordDate = "";
//              if (isDateType.get()) {
//                strRecordDate = DateFormat(String.valueOf(record.get(totalUnitHList.get(0))));
//              } else {
//                if (isDate(String.valueOf(record.get(totalUnitVList.get(0))))) {
//                  strRecordDate = DateFormat(String.valueOf(record.get(totalUnitVList.get(0))));
//                  strRecordDate = strRecordDate.substring(0, 8);
//                } else {
//                  strRecordDate = String.valueOf(record.get(totalUnitVList.get(0)));
//                }
//              }
//              strTemplateListDate = strRecordDate;
//              String strKurName = "";
//              int totalUnitVIndex = 0;
//              switch (String.valueOf(sqlCd)) {
//                case "152":
//                  strKurName = reportServiceImpl.formatValue(param, record.get("kur_name"));
//                  strKurName = reportServiceImpl.convertValue(param, strKurName);
//                  // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen start
//                  // if (totalUnitindex("kur_name") != -1) {
//                  //   totalUnitVIndex = totalUnitindex("kur_name");H;
//                  if (totalUnitindex("kur_name", param1) != -1) {
//                    totalUnitVIndex = totalUnitindex("kur_name", param1);
//                    // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen end
//                  }
//                  break;
//                case "29":
//                case "197":
//                  strKurName = reportServiceImpl.formatValue(param, record.get("reg_order_class"));
//                  strKurName = reportServiceImpl.convertValue(param, strKurName);
//                  // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen start
//                  // totalUnitVIndex = totalUnitindex("reg_order_class");
//                  totalUnitVIndex = totalUnitindex("reg_order_class", param1);
//                  // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen end
//                  switch (strKurName) {
//                    case "1":
//                      strKurName = "透析前";
//                      break;
//                    case "2":
//                      strKurName = "透析後";
//                      break;
//                    default:
//                      strKurName = "その他";
//                      break;
//                  }
//                  if (!valueNoLoop.isEmpty()) {
//                    strTemplateListDate = strRecordDate;
//                  }
//                  break;
//                default:
//                  break;
//              }
//              if (strTemplateListDate.equals(strRecordDate)) {
//                if ("月".equals(totalUnitDate)) {
//                  strRecordDate = strRecordDate.substring(0, 6);
//                } else if ("年".equals(totalUnitDate)) {
//                  strRecordDate = strRecordDate.substring(0, 4);
//                }
//                if (isDateType.get()) {
//                  if (totalContents.equals("項目値")) {
//                    if ("decimal".equals(InTemplType)) {
//                      Map<String, Object> totalData = processData(reportInfoForInTempl.get(sqlCd), LAST, paramsInTempl, paramsOutTempl);
//                      for (int i = 1; i < Column - 1; i++) {
//                        for (int j = 1; j < Lines - 1; j++) {
//                          String totalDataKey = strB[0][i] + CONNECTION_SYMBOL + strB[j][0];
//                          // 配列内のstrecordDate日付のindexの位置付け
//                          int index = findIndex(strB[0], strB[0][i]);
//                          if (!StringUtils.isEmpty(totalTable.getConversion())) {
//                            strB[j][index] = totalTable.getConversion();
//                          } else {
//                            if (totalData.containsKey(totalDataKey)) {
//                              strB[j][index] = totalData.get(totalDataKey).toString();
//                            } else {
//                              //mod #10989 「0」を空白にしてほしいのは、集計＞表示内容が「合計」のときだけ。 杜 start
//                              //strB[j][index] = "0";
//                              strB[j][index] = "";
//                              //mod #10989 「0」を空白にしてほしいのは、集計＞表示内容が「合計」のときだけ。 杜 end
//                            }
//                          }
//                          if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountV)) {
//                            strB[j][Column - 1] = formatBigDecimal(strB[j][Column - 1], totalData.containsKey(totalDataKey) ? totalData.get(totalDataKey).toString() : "0");
//                          }
//                          if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                            strB[Lines - 1][i] = formatBigDecimal(strB[Lines - 1][i], totalData.containsKey(totalDataKey) ? totalData.get(totalDataKey).toString() : "0");
//                            strB[Lines - 1][0] = "合　計";
//                          }
//                          // 横縦外合計
//                          if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountV) && TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                            strB[Lines - 1][strB[0].length - 1] = formatBigDecimal(strB[Lines - 1][strB[0].length - 1], totalData.containsKey(totalDataKey) ? totalData.get(totalDataKey).toString() : "0");
//                          }
//                        }
//                      }
//                      // 初期化フラグをtrueに変更
//                      isCont = false;
//                    } else {
//                      boolean isOkV = false;
//                      for (int i = 0; i < Lines; i++) {
//                        if (isOkV) break;
//                        if (!strB[i][0].isEmpty() && strRecordDate.equals(strB[i][0])) {
//                          for (int j = 0; j < Column; j++) {
//                            if (isOkV) break;
//                            if (!valueTotalUnitH.isEmpty() && valueTotalUnitH.equals(strB[0][j])) {
//                              if (totalConversion.isEmpty()) {
//                                totalConversion = valueNoLoop;
//                              }
//                              if (!totalConversion.isEmpty()) {
//                                if (!strKurName.isEmpty()) {
//                                  if (strKurName.equals(arrtotalUnitH[totalUnitVIndex][i]) && !totalConversion.equals(strB[i][j])) {
//                                    strB[i][j] = totalConversion;
//                                    isOkV = true;
//                                    if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountV)) {
//                                      //strB[j][Column - 1] = String.valueOf(Integer.parseInt(strB[j][Column - 1]) + 1);
//                                      String strTotalV = StringUtils.isEmpty(strB[j][Column - 1]) ? "0" : strB[j][Column - 1];
//                                      strB[j][Column - 1] = String.valueOf(Integer.parseInt(strTotalV) + 1);
//                                    }
//                                    if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                                      //strB[Lines - 1][i] = String.valueOf(Integer.parseInt(strB[Lines - 1][i]) + 1);
//                                      strB[Lines - 1][0] = "合　計";
//                                      String strTotalH = StringUtils.isEmpty(strB[Lines - 1][i]) ? "0" : strB[Lines - 1][i];
//                                      strB[Lines - 1][i] = String.valueOf(Integer.parseInt(strTotalH) + 1);
//                                    }
//                                    // 横縦合計がすべて存在する場合は、総数量合計を行う
//                                    if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountV) && TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                                      String strTotalHV = StringUtils.isEmpty(strB[Lines - 1][strB[0].length - 1]) ? "0" : strB[Lines - 1][strB[0].length - 1];
//                                      strB[Lines - 1][strB[0].length - 1] = String.valueOf(Integer.parseInt(strTotalHV) + 1);
//                                    }
//                                  }
//                                } else {
//                                  if (!totalConversion.equals(strB[i][j]) && ("".equals(strB[i][j]) || "0".equals(strB[i][j]))) {
//                                    strB[i][j] = totalConversion;
//                                    isOkV = true;
//                                    if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountV)) {
//                                      //strB[i][Column - 1] = String.valueOf(Integer.parseInt(strB[i][Column - 1]) + 1);
//                                      String strTotalV = StringUtils.isEmpty(strB[i][Column - 1]) ? "0" : strB[i][Column - 1];
//                                      strB[i][Column - 1] = String.valueOf(Integer.parseInt(strTotalV) + 1);
//                                    }
//                                    if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                                      //strB[Lines - 1][j] = String.valueOf(Integer.parseInt(strB[Lines - 1][j]) + 1);
//                                      strB[Lines - 1][0] = "合　計";
//                                      String strTotalH = StringUtils.isEmpty(strB[Lines - 1][j]) ? "0" : strB[Lines - 1][j];
//                                      strB[Lines - 1][j] = String.valueOf(Integer.parseInt(strTotalH) + 1);
//                                    }
//                                    // 横縦合計がすべて存在する場合は、総数量合計を行う
//                                    if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountV) && TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                                      String strTotalHV = StringUtils.isEmpty(strB[Lines - 1][strB[0].length - 1]) ? "0" : strB[Lines - 1][strB[0].length - 1];
//                                      strB[Lines - 1][strB[0].length - 1] = String.valueOf(Integer.parseInt(strTotalHV) + 1);
//                                    }
//                                  }
//                                  targetTemplateIndex = targetTemplateIndex + 1;
//                                }
//                                totalConversion = totalTable.getConversion();
//                              }
//                            }
//                          }
//                        }
//                      }
//                    }
//                  } else if (totalContents.equals("合　計")) {
//                    Map<String, Object> totalData = processData(reportInfoForInTempl.get(sqlCd), TOTAL, paramsInTempl, paramsOutTempl);
//                    // 表示内容が合計の編集処理
//                    for (int i = 1; i < Column - 1; i++) {
//                      for (int j = 1; j < Lines - 1; j++) {
//                        String totalDataKey = strB[0][i] + CONNECTION_SYMBOL + strB[j][0];
//                        // 配列内のstrecordDate日付のindexの位置付け
//                        int index = findIndex(strB[0], strB[0][i]);
//                        if (!StringUtils.isEmpty(totalTable.getConversion())) {
//                          strB[j][index] = totalTable.getConversion();
//                        } else {
//                          if (totalData.containsKey(totalDataKey)) {
//                            strB[j][index] = totalData.get(totalDataKey).toString();
//                          } else {
//                            //mod #10989 「0」を空白にしてほしいのは、集計＞表示内容が「合計」のときだけ。 杜 start
//                            //strB[j][index] = "0";
//                            strB[j][index] = "";
//                            //mod #10989 「0」を空白にしてほしいのは、集計＞表示内容が「合計」のときだけ。 杜 end
//                          }
//                        }
//                        if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountV)) {
//                          strB[j][Column - 1] = formatBigDecimal(strB[j][Column - 1], totalData.containsKey(totalDataKey) ? totalData.get(totalDataKey).toString() : "0");
//                        }
//                        if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                          strB[Lines - 1][i] = formatBigDecimal(strB[Lines - 1][i], totalData.containsKey(totalDataKey) ? totalData.get(totalDataKey).toString() : "0");
//                          strB[Lines - 1][0] = "合　計";
//                        }
//                        // 横縦外合計
//                        if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountV) && TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                          strB[Lines - 1][strB[0].length - 1] = formatBigDecimal(strB[Lines - 1][strB[0].length - 1], totalData.containsKey(totalDataKey) ? totalData.get(totalDataKey).toString() : "0");
//                        }
//                      }
//                    }
//                    // 初期化フラグをtrueに変更
//                    isCont = false;
//                  } else if (totalContents.equals("最大値")) {
//                    // 表示内容が最大値の編集処理
//                    Map<String, Object> totalData = processData(reportInfoForInTempl.get(sqlCd), MAX, paramsInTempl, paramsOutTempl);
//                    for (int i = 1; i < Column - 1; i++) {
//                      for (int j = 1; j < Lines - 1; j++) {
//                        String totalDataKey = strB[0][i] + CONNECTION_SYMBOL + strB[j][0];
//                        // 配列内のstrecordDate日付のindexの位置付け
//                        int index = findIndex(strB[0], strB[0][i]);
//                        if (!StringUtils.isEmpty(totalTable.getConversion())) {
//                          strB[j][index] = totalTable.getConversion();
//                        } else {
//                          if (totalData.containsKey(totalDataKey)) {
//                            strB[j][index] = totalData.get(totalDataKey).toString();
//                          } else {
//                            strB[j][index] = "0";
//                          }
//                        }
//                        if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountV)) {
//                          strB[j][Column - 1] = formatBigDecimal(strB[j][Column - 1], totalData.containsKey(totalDataKey) ? totalData.get(totalDataKey).toString() : "0");
//                        }
//                        if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                          strB[Lines - 1][i] = formatBigDecimal(strB[Lines - 1][i], totalData.containsKey(totalDataKey) ? totalData.get(totalDataKey).toString() : "0");
//                          strB[Lines - 1][0] = "合　計";
//                        }
//                        // 横縦外合計
//                        if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountV) && TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                          strB[Lines - 1][strB[0].length - 1] = formatBigDecimal(strB[Lines - 1][strB[0].length - 1], totalData.containsKey(totalDataKey) ? totalData.get(totalDataKey).toString() : "0");
//                        }
//                      }
//                    }
//                    // 初期化フラグをtrueに変更
//                    isCont = false;
//                  } else if (totalContents.equals("最小値")) {
//                    // 表示内容が最小値の編集処理
//                    Map<String, Object> totalData = processData(reportInfoForInTempl.get(sqlCd), MIN, paramsInTempl, paramsOutTempl);
//                    for (int i = 1; i < Column - 1; i++) {
//                      for (int j = 1; j < Lines - 1; j++) {
//                        String totalDataKey = strB[0][i] + CONNECTION_SYMBOL + strB[j][0];
//                        // 配列内のstrecordDate日付のindexの位置付け
//                        int index = findIndex(strB[0], strB[0][i]);
//                        if (!StringUtils.isEmpty(totalTable.getConversion())) {
//                          strB[j][index] = totalTable.getConversion();
//                        } else {
//                          if (totalData.containsKey(totalDataKey)) {
//                            strB[j][index] = totalData.get(totalDataKey).toString();
//                          } else {
//                            strB[j][index] = "0";
//                          }
//                        }
//                        if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountV)) {
//                          strB[j][Column - 1] = formatBigDecimal(strB[j][Column - 1], totalData.containsKey(totalDataKey) ? totalData.get(totalDataKey).toString() : "0");
//                        }
//                        if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                          strB[Lines - 1][i] = formatBigDecimal(strB[Lines - 1][i], totalData.containsKey(totalDataKey) ? totalData.get(totalDataKey).toString() : "0");
//                          strB[Lines - 1][0] = "合　計";
//                        }
//                        // 横縦外合計
//                        if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountV) && TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                          strB[Lines - 1][strB[0].length - 1] = formatBigDecimal(strB[Lines - 1][strB[0].length - 1], totalData.containsKey(totalDataKey) ? totalData.get(totalDataKey).toString() : "0");
//                        }
//                      }
//                    }
//                    // 初期化フラグをtrueに変更
//                    isCont = false;
//                  } else if (totalContents.equals("平均値")) {
//                    // 表示内容が平均値の編集処理
//                    Map<String, Object> totalData = processData(reportInfoForInTempl.get(sqlCd), AVG, paramsInTempl, paramsOutTempl);
//                    for (int i = 1; i < Column - 1; i++) {
//                      for (int j = 1; j < Lines - 1; j++) {
//                        String totalDataKey = strB[0][i] + CONNECTION_SYMBOL + strB[j][0];
//                        // 配列内のstrecordDate日付のindexの位置付け
//                        int index = findIndex(strB[0], strB[0][i]);
//                        if (!StringUtils.isEmpty(totalTable.getConversion())) {
//                          strB[j][index] = totalTable.getConversion();
//                        } else {
//                          if (totalData.containsKey(totalDataKey)) {
//                            strB[j][index] = totalData.get(totalDataKey).toString();
//                          } else {
//                            strB[j][index] = "0";
//                          }
//                        }
//                        if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountV)) {
//                          strB[j][Column - 1] = formatBigDecimal(strB[j][Column - 1], totalData.containsKey(totalDataKey) ? totalData.get(totalDataKey).toString() : "0");
//                        }
//                        if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                          strB[Lines - 1][i] = formatBigDecimal(strB[Lines - 1][i], totalData.containsKey(totalDataKey) ? totalData.get(totalDataKey).toString() : "0");
//                          strB[Lines - 1][0] = "合　計";
//                        }
//                        // 横縦外合計
//                        if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountV) && TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                          strB[Lines - 1][strB[0].length - 1] = formatBigDecimal(strB[Lines - 1][strB[0].length - 1], totalData.containsKey(totalDataKey) ? totalData.get(totalDataKey).toString() : "0");
//                        }
//                      }
//                    }
//                    // 初期化フラグをtrueに変更
//                    isCont = false;
//                  }
//                } else {
//                  // 表示内容が項目値の編集処理
//                  if (totalContents.equals("項目値")) {
//                    //TODO 出力形式は集計内decimalタイプで、しかも日、曜日、月、年形式で出力する
//                    if ("decimal".equals(InTemplType)) {
//                      Map<String, Object> totalData = processData(reportInfoForInTempl.get(sqlCd), LAST, paramsInTempl, paramsOutTempl);
//                      for (int i = 1; i < Column - 1; i++) {
//                        for (int j = 1; j < Lines - 1; j++) {
//                          String totalDataKey = strB[0][i] + CONNECTION_SYMBOL + strB[j][0];
//                          // 配列内のstrecordDate日付のindexの位置付け
//                          int index = findIndex(strB[0], strB[0][i]);
//                          if (!StringUtils.isEmpty(totalTable.getConversion())) {
//                            strB[j][index] = totalTable.getConversion();
//                          } else {
//                            if (totalData.containsKey(totalDataKey)) {
//                              strB[j][index] = totalData.get(totalDataKey).toString();
//                            } else {
//                              //mod #10989 「0」を空白にしてほしいのは、集計＞表示内容が「合計」のときだけ。 杜 start
//                              //strB[j][index] = "0";
//                              strB[j][index] = "";
//                              //mod #10989 「0」を空白にしてほしいのは、集計＞表示内容が「合計」のときだけ。 杜 end
//                            }
//                          }
//                          if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountV)) {
//                            strB[j][Column - 1] = formatBigDecimal(strB[j][Column - 1], totalData.containsKey(totalDataKey) ? totalData.get(totalDataKey).toString() : "0");
//                          }
//                          if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                            strB[Lines - 1][i] = formatBigDecimal(strB[Lines - 1][i], totalData.containsKey(totalDataKey) ? totalData.get(totalDataKey).toString() : "0");
//                            strB[Lines - 1][0] = "合　計";
//                          }
//                          // 横縦外合計
//                          if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountV) && TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                            strB[Lines - 1][strB[0].length - 1] = formatBigDecimal(strB[Lines - 1][strB[0].length - 1], totalData.containsKey(totalDataKey) ? totalData.get(totalDataKey).toString() : "0");
//                          }
//                        }
//                      }
//                      // 初期化フラグをtrueに変更
//                      isCont = false;
//                      //TODO 集計内タイプ非decimal形式出力（現在はstring形式のみを考慮）
//                    } else {
//                      String strDate = "";
//                      boolean isOkH = false;
//                      for (int i = 0; i < Column; i++) {
//                        if (isOkH) break;
//                        if (!isDate(strRecordDate)) {
//                          if (strRecordDate.indexOf(dateToWeek(strB[0][i])) >= 0) {
//                            strDate = strB[0][i];
//                          }
//                        } else {
//                          strDate = strRecordDate;
//                        }
//                        if (!strB[0][i].isEmpty() && strDate.equals(strB[0][i])) {
//                          for (int j = 0; j < Lines; j++) {
//                            if (isOkH) break;
//                            if (!valueTotalUnitH.isEmpty() && valueTotalUnitH.equals(strB[j][0])) {
//                              if (totalConversion.isEmpty()) {
//                                totalConversion = valueNoLoop;
//                              }
//                              if (!totalConversion.isEmpty()) {
//                                if (!strKurName.isEmpty()) {
//                                  if (strKurName.equals(arrtotalUnitV[totalUnitVIndex][i]) && !totalConversion.equals(strB[j][i])) {
//                                    strB[j][i] = totalConversion;
//                                    isOkH = true;
//                                    if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountV)) {
//                                      String strTotalV = StringUtils.isEmpty(strB[j][Column - 1]) ? "0" : strB[j][Column - 1];
//                                      strB[j][Column - 1] = String.valueOf(Integer.parseInt(strTotalV) + 1);
//                                    }
//                                    if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                                      strB[Lines - 1][0] = "合　計";
//                                      String strTotalH = StringUtils.isEmpty(strB[Lines - 1][i]) ? "0" : strB[Lines - 1][i];
//                                      strB[Lines - 1][i] = String.valueOf(Integer.parseInt(strTotalH) + 1);
//                                    }
//                                    // 横縦合計がすべて存在する場合は、総数量合計を行う
//                                    if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountV) && TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                                      String strTotalHV = StringUtils.isEmpty(strB[Lines - 1][strB[0].length - 1]) ? "0" : strB[Lines - 1][strB[0].length - 1];
//                                      strB[Lines - 1][strB[0].length - 1] = String.valueOf(Integer.parseInt(strTotalHV) + 1);
//                                    }
//                                  }
//                                } else if (sqlCd != 152L) {
//                                  // add #11293 【標準帳票】水質検査帳票の課題対応 吉 start
//                                  if(sqlCd == 127L && countResulList.contains(i+"_"+j)){
//                                    continue;
//                                  }
//                                  // add #11293 【標準帳票】水質検査帳票の課題対応 吉 end
//                                  strB[j][i] = totalConversion;
//                                  // add #11293 【標準帳票】水質検査帳票の課題対応 吉 start
//                                  if(sqlCd == 127L){
//                                    countResulList.add(i+"_"+j);
//                                  }
//                                  // add #11293 【標準帳票】水質検査帳票の課題対応 吉 end
//                                  isOkH = true;
//                                  if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountV)) {
//                                    String strTotalV = StringUtils.isEmpty(strB[j][Column - 1]) ? "0" : strB[j][Column - 1];
//                                    strB[j][Column - 1] = String.valueOf(Integer.parseInt(strTotalV) + 1);
//                                  }
//                                  if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                                    String strTotalH = StringUtils.isEmpty(strB[Lines - 1][i]) ? "0" : strB[Lines - 1][i];
//                                    strB[Lines - 1][i] = String.valueOf(Integer.parseInt(strTotalH) + 1);
//                                  }
//                                  // 横縦合計がすべて存在する場合は、総数量合計を行う
//                                  if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountV) && TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                                    String strTotalHV = StringUtils.isEmpty(strB[Lines - 1][strB[0].length - 1]) ? "0" : strB[Lines - 1][strB[0].length - 1];
//                                    strB[Lines - 1][strB[0].length - 1] = String.valueOf(Integer.parseInt(strTotalHV) + 1);
//                                  }
//                                }
//                                targetTemplateIndex = targetTemplateIndex + 1;
//                              }
//                              totalConversion = totalTable.getConversion();
//                            }
//                          }
//                        }
//                      }
//                    }
//                  } else if (totalContents.equals("合　計")) {
//                    Map<String, Object> totalData = processData(reportInfoForInTempl.get(sqlCd), TOTAL, paramsInTempl, paramsOutTempl);
//                    // 表示内容が合計の編集処理
//                    for (int i = 1; i < Column - 1; i++) {
//                      for (int j = 1; j < Lines - 1; j++) {
//                        String totalDataKey = strB[0][i] + CONNECTION_SYMBOL + strB[j][0];
//                        // 配列内のstrecordDate日付のindexの位置付け
//                        int index = findIndex(strB[0], strB[0][i]);
//                        if (!StringUtils.isEmpty(totalTable.getConversion())) {
//                          strB[j][index] = totalTable.getConversion();
//                        } else {
//                          if (totalData.containsKey(totalDataKey)) {
//                            strB[j][index] = totalData.get(totalDataKey).toString();
//                          } else {
//                            //mod #10989 「0」を空白にしてほしいのは、集計＞表示内容が「合計」のときだけ。 杜 start
//                            //strB[j][index] = "0";
//                            strB[j][index] = "";
//                            //mod #10989 「0」を空白にしてほしいのは、集計＞表示内容が「合計」のときだけ。 杜 end
//                          }
//                        }
//                        if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountV)) {
//                          strB[j][Column - 1] = formatBigDecimal(strB[j][Column - 1], totalData.containsKey(totalDataKey) ? totalData.get(totalDataKey).toString() : "0");
//                        }
//                        if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                          strB[Lines - 1][i] = formatBigDecimal(strB[Lines - 1][i], totalData.containsKey(totalDataKey) ? totalData.get(totalDataKey).toString() : "0");
//                          strB[Lines - 1][0] = "合　計";
//                        }
//                        // 横縦外合計
//                        if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountV) && TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                          strB[Lines - 1][strB[0].length - 1] = formatBigDecimal(strB[Lines - 1][strB[0].length - 1], totalData.containsKey(totalDataKey) ? totalData.get(totalDataKey).toString() : "0");
//                        }
//                      }
//                    }
//                    // 初期化フラグをtrueに変更
//                    isCont = false;
//                  } else if (totalContents.equals("最大値")) {
//                    // 表示内容が最大値の編集処理
//                    Map<String, Object> totalData = processData(reportInfoForInTempl.get(sqlCd), MAX, paramsInTempl, paramsOutTempl);
//                    for (int i = 1; i < Column - 1; i++) {
//                      for (int j = 1; j < Lines - 1; j++) {
//                        String totalDataKey = strB[0][i] + CONNECTION_SYMBOL + strB[j][0];
//                        // 配列内のstrecordDate日付のindexの位置付け
//                        int index = findIndex(strB[0], strB[0][i]);
//                        if (!StringUtils.isEmpty(totalTable.getConversion())) {
//                          strB[j][index] = totalTable.getConversion();
//                        } else {
//                          if (totalData.containsKey(totalDataKey)) {
//                            strB[j][index] = totalData.get(totalDataKey).toString();
//                          } else {
//                            strB[j][index] = "0";
//                          }
//                        }
//                        if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountV)) {
//                          strB[j][Column - 1] = formatBigDecimal(strB[j][Column - 1], totalData.containsKey(totalDataKey) ? totalData.get(totalDataKey).toString() : "0");
//                        }
//                        if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                          strB[Lines - 1][i] = formatBigDecimal(strB[Lines - 1][i], totalData.containsKey(totalDataKey) ? totalData.get(totalDataKey).toString() : "0");
//                          strB[Lines - 1][0] = "合　計";
//                        }
//                        // 横縦外合計
//                        if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountV) && TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                          strB[Lines - 1][strB[0].length - 1] = formatBigDecimal(strB[Lines - 1][strB[0].length - 1], totalData.containsKey(totalDataKey) ? totalData.get(totalDataKey).toString() : "0");
//                        }
//                      }
//                    }
//                    // 初期化フラグをtrueに変更
//                    isCont = false;
//                  } else if (totalContents.equals("最小値")) {
//                    // 表示内容が最小値の編集処理
//                    Map<String, Object> totalData = processData(reportInfoForInTempl.get(sqlCd), MIN, paramsInTempl, paramsOutTempl);
//                    for (int i = 1; i < Column - 1; i++) {
//                      for (int j = 1; j < Lines - 1; j++) {
//                        String totalDataKey = strB[0][i] + CONNECTION_SYMBOL + strB[j][0];
//                        // 配列内のstrecordDate日付のindexの位置付け
//                        int index = findIndex(strB[0], strB[0][i]);
//                        if (!StringUtils.isEmpty(totalTable.getConversion())) {
//                          strB[j][index] = totalTable.getConversion();
//                        } else {
//                          if (totalData.containsKey(totalDataKey)) {
//                            strB[j][index] = totalData.get(totalDataKey).toString();
//                          } else {
//                            strB[j][index] = "0";
//                          }
//                        }
//                        if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountV)) {
//                          strB[j][Column - 1] = formatBigDecimal(strB[j][Column - 1], totalData.containsKey(totalDataKey) ? totalData.get(totalDataKey).toString() : "0");
//                        }
//                        if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                          strB[Lines - 1][i] = formatBigDecimal(strB[Lines - 1][i], totalData.containsKey(totalDataKey) ? totalData.get(totalDataKey).toString() : "0");
//                          strB[Lines - 1][0] = "合　計";
//                        }
//                        // 横縦外合計
//                        if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountV) && TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                          strB[Lines - 1][strB[0].length - 1] = formatBigDecimal(strB[Lines - 1][strB[0].length - 1], totalData.containsKey(totalDataKey) ? totalData.get(totalDataKey).toString() : "0");
//                        }
//                      }
//                    }
//                    // 初期化フラグをtrueに変更
//                    isCont = false;
//                  } else if (totalContents.equals("平均値")) {
//                    // 表示内容が平均値の編集処理
//                    Map<String, Object> totalData = processData(reportInfoForInTempl.get(sqlCd), AVG, paramsInTempl, paramsOutTempl);
//                    for (int i = 1; i < Column - 1; i++) {
//                      for (int j = 1; j < Lines - 1; j++) {
//                        String totalDataKey = strB[0][i] + CONNECTION_SYMBOL + strB[j][0];
//                        // 配列内のstrecordDate日付のindexの位置付け
//                        int index = findIndex(strB[0], strB[0][i]);
//                        if (!StringUtils.isEmpty(totalTable.getConversion())) {
//                          strB[j][index] = totalTable.getConversion();
//                        } else {
//                          if (totalData.containsKey(totalDataKey)) {
//                            strB[j][index] = totalData.get(totalDataKey).toString();
//                          } else {
//                            strB[j][index] = "0";
//                          }
//                        }
//                        if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountV)) {
//                          strB[j][Column - 1] = formatBigDecimal(strB[j][Column - 1], totalData.containsKey(totalDataKey) ? totalData.get(totalDataKey).toString() : "0");
//                        }
//                        if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                          strB[Lines - 1][i] = formatBigDecimal(strB[Lines - 1][i], totalData.containsKey(totalDataKey) ? totalData.get(totalDataKey).toString() : "0");
//                          strB[Lines - 1][0] = "合　計";
//                        }
//                        // 横縦外合計
//                        if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountV) && TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                          strB[Lines - 1][strB[0].length - 1] = formatBigDecimal(strB[Lines - 1][strB[0].length - 1], totalData.containsKey(totalDataKey) ? totalData.get(totalDataKey).toString() : "0");
//                        }
//                      }
//                    }
//                    // 初期化フラグをtrueに変更
//                    isCont = false;
//                  }
//                }
//              }
//            }
//            if (!isCont) {
//              break;
//            }
//            recIndex++;
//          }
//        }
//        // 集計帳票の出力編集処理
//        if (dataKeyInOfTemplateList.size() > 0) {
//          int count = 0;
//          //dispID = paramsInTempl.get(0).getReportXmlTmplRepeat().getId();
//          int lineCount = 1;
//          int columnCount = 1;
//          if (isDateType.get()) {
//            for (int i = columnCount; i < Column; i++) {
//              // 横の集計単位の編集処理
////                if (strUnitVId.size() > 0 && !strUnitVId.get(0).isEmpty() && strB[0][i] != "0") {
////                  key = String.format("%s-%d", strUnitVId.get(0), i);
////                  //reportOutputInfoForInTempl.put(key, strB[0][i]);
////                }
//              if (count > 0 && count >= linesCount * (i - columnCount)) {
//                count = (count + 1) + lineFeed - Lines;
//              }
//              for (int j = lineCount; j < Lines; j++) {
//                // 曜日指定の場合、日期を曜日へ変換する。
//                if ("曜日".equals(totalUnitDate)) {
//                  if (!strB[j][0].isEmpty() && 0 == dataKeyInOfTemplateList.size() - 1) {
//                    strB[j][0] = dateToWeek(strB[j][0]);
//                  }
//                }
//                // 日付編集
//                if ("日".equals(totalUnitDate) && strB[j][0] != "0" && strB[j][0] != "合　計" && i == Column - 1) {
//                  strB[j][0] = String.format("%s/%s(%s)",
//                    strB[j][0].substring(4, 6).replaceAll("^(0+)", ""),
//                    strB[j][0].substring(6, 8).replaceAll("^(0+)", ""),
//                    dateToWeek(strB[j][0]));
//                }
////                  if (!strUnitHId.get(0).isEmpty() && strB[j][0] != "0") {
////                    key = String.format("%s-%d", strUnitHId.get(0), j);
////                    //reportOutputInfoForInTempl.put(key, strB[j][0]);
////                  }
//                // 集計データ表示内容を編集処理
//                if (!totalContents.isEmpty()) {
//                  if (!totalContents.equals("項目値")) {
//                    if (i != 0 && j != 0 && !strB[j][i].contains(totalConversion) && 0 == dataKeyInOfTemplateList.size() - 1) {
//                      strB[j][i] = strB[j][i] + totalConversion;
//                    }
//                  }
//                }
//                // 縦の合計編集処理
////                  if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH) && j == Lines - 1) {
////                    key = String.format("%s-%d", strUnitHId.get(0), j);
////                    //reportOutputInfoForInTempl.put(key, "合計");
////                  }
//                // 横の合計編集処理
////                  if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountV) && i == Column - 1) {
////                    key = String.format("%s-%d", strUnitVId.get(0), i);
////                    //reportOutputInfoForInTempl.put(key, "合計");
////                  }
//                // htmlの<td>IDを編集処理
////                  if (strGroupId != "") {
////                    key = String.format("%s-%d.%s-1", dispID, ++count, dispID);
////                  } else {
////                    key = String.format("%s-%d.%s", dispID, ++count, dispID);
////                  }
//                // 最後データの編集処理
//                if (i == strB[0].length - 1 && j == strB.length - 1) {
//                  //reportOutputInfoForInTempl.put(key, "");
//                } else {
//                  // 合計表示しないとき、合計データが空を設定
//                  if (TOTAL_COUNTS_DISPLAY_N.equals(totalCountH)) {
//                    if (j == Lines - 1) {
//                      strB[j][i] = "";
//                    }
//                  }
//                  // 合計表示しないとき、合計データが空を設定
//                  if (TOTAL_COUNTS_DISPLAY_N.equals(totalCountV)) {
//                    if (i == Column - 1) {
//                      strB[j][i] = "";
//                    }
//                  }
//                  // データ毎に表示処理
//                  //reportOutputInfoForInTempl.put(key, strB[j][i]);
//                }
//              }
//            }
//          } else {
//            // 横の集計単位初期化処理
////              for (int n = 0; n < strUnitVId.size(); n++) {
////                String unitId = strUnitVId.get(n);
////                if (!unitId.isEmpty()) {
////                  String formatString = "%s-%d";
////                  for (int i = 1; i <= repeatCountH.get(); i++) {
////                    key = String.format(formatString, unitId, i);
////                    //reportOutputInfoForInTempl.put(key, "");
////                  }
////                }
////              }
//            // 縦の集計単位初期化処理
////              for (int n = 0; n < strUnitHId.size(); n++) {
////                String unitId = strUnitHId.get(n);
////                if (!unitId.isEmpty()) {
////                  String formatString = "%s-%d";
////                  for (int i = 1; i <= repeatCountV.get(); i++) {
////                    key = String.format(formatString, unitId, i);
////                    //reportOutputInfoForInTempl.put(key, "");
////                  }
////                }
////              }
//            // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen start
//            // int totalUnitVIndex = totalUnitindex("total_unitV");
//            // int totalUnitHIndex = totalUnitindex("total_unitH");
//            int totalUnitVIndex = totalUnitindex("total_unitV", param1);
//            int totalUnitHIndex = totalUnitindex("total_unitH", param1);
//            // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen end
//            if (totalUnitVIndex >= 0) {
//              for (int i = 1; i < Lines; i++) {
//                arrtotalUnitH[totalUnitVIndex][i] = strB[i][Column - 1];
//              }
//              arrtotalUnitH[totalUnitVIndex][Lines - 1] = "";
//            }
//            if (totalUnitHIndex >= 0) {
//              for (int j = 1; j < Column - 1; j++) {
//                arrtotalUnitV[totalUnitHIndex][j] = strB[Lines - 1][j];
//                arrtotalUnitV[totalUnitHIndex][Column - 1] = formatBigDecimal(arrtotalUnitV[totalUnitHIndex][Column - 1], strB[Lines - 1][j]);
//              }
//            }
//            for (int i = columnCount; i < Column; i++) {
//              // 曜日指定の場合、日期を曜日へ変換する。
//              if ("曜日".equals(totalUnitDate)) {
//                if (!strB[0][i].isEmpty()) {
//                  strB[0][i] = dateToWeek(strB[0][i]);
//                }
//              }
//              // mod 10989 集計機能の合計出力仕様の変更（複数集計）gjn start
//              // 日付編集
//              //if ("日".equals(totalUnitDate) && !strB[0][i].equals("0") && 0 == totalDataList.size() - 1) {
////                strB[0][i] = String.format("%s/%s(%s)",
////                  strB[0][i].substring(4, 6).replaceAll("^(0+)", ""),
////                  strB[0][i].substring(6, 8).replaceAll("^(0+)", ""),
////                  dateToWeek(strB[0][i]));
////                  if (strOldeDate.equals(strB[0][i]) && sqlCd == 152L) {
////                    strB[0][i] = "―";
////                  } else {
//              //strOldeDate = strB[0][i];
//              //}
//              //}
//              // mod 10989 集計機能の合計出力仕様の変更（複数集計）gjn end
//              // 横の集計単位の編集処理
////                if (!strUnitVId.get(0).isEmpty() && !strB[0][i].equals("0")) {
////                  key = String.format("%s-%d", strUnitVId.get(0), i);
////                  //reportOutputInfoForInTempl.put(key, strB[0][i]);
////                }
////                for (int n = 1; n < strUnitVId.size(); n++) {
////                  if (!strUnitVId.get(n).isEmpty() &&
////                    ("out_pat_cnt".equals(arrtotalUnitV[n][0]) ||
////                      "hosp_pat_cnt".equals(arrtotalUnitV[n][0]) ||
////                      "total_unitH".equals(arrtotalUnitV[n][0]) ||
////                      !arrtotalUnitV[n][i].equals("0"))) {
////                    key = String.format("%s-%d", strUnitVId.get(n), i);
////                    //reportOutputInfoForInTempl.put(key, arrtotalUnitV[n][i]);
////                  }
////                }
//              // 改行処理　行数＝（表示行数ー集計データ行数＋編集済み行数）
//              if (count > 0 && count >= linesCount * (i - columnCount)) {
//                count = lineFeed - Lines + (count + 1);
//              }
//              for (int j = lineCount; j < Lines; j++) {
//                // 縦の集計単の編集処理
//                for (int n = 0; n < strUnitHId.size(); n++) {
//                  if (!strUnitHId.get(n).isEmpty() && ("total_unitV".equals(arrtotalUnitH[n][0]) || !arrtotalUnitH[n][j].equals("0"))) {
//                    //key = String.format("%s-%d", strUnitHId.get(n), j);
//                    if (arrtotalUnitH[n][j].length() > 10 && sqlCd == 152L) {
//                      arrtotalUnitH[n][j] = arrtotalUnitH[n][j].substring(0, 10);
//                    }
//                    //reportOutputInfoForInTempl.put(key, arrtotalUnitH[n][j]);
//                  }
//                }
//                // 横の合計編集処理
////                  if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountV) && i == Column - 1) {
////                    key = String.format("%s-%d", strUnitVId.get(0), i);
////                    //reportOutputInfoForInTempl.put(key, "計");
////                  }
//                // htmlの<td>IDを編集処理
////                  key = (strGroupId != "") ?
////                    String.format("%s-%d.%s-1", dispID, ++count, dispID) :
////                    String.format("%s-%d.%s", dispID, ++count, dispID);
//                // 最後データの編集処理
//                if (i == strB[0].length - 1 && j == strB.length - 1) {
//                  //reportOutputInfoForInTempl.put(key, "");
//                } else {
//                  // データ毎に表示処理
//                  if (!totalContents.isEmpty() && !"項目値".equals(totalContents)) {
//                    if (i != 0 && j != 0 && !strB[j][i].contains(totalConversion) && 0 == dataKeyInOfTemplateList.size() - 1) {
//                      // 集計データ表示内容を編集処理
//                      strB[j][i] = strB[j][i] + totalConversion;
//                    }
//                  } else {
//                    if ("0".equals(strB[j][i])) {
//                      strB[j][i] = "";
//                    }
//                  }
//                  // 合計表示しないとき、合計データが空を設定
//                  if (TOTAL_COUNTS_DISPLAY_N.equals(totalCountH) || sqlCd == SQL_CD_SUPPLIES_CNT) {
//                    if (j == Lines - 1) {
//                      strB[j][i] = "";
//                    }
//                  }
//                  // 合計表示しないとき、合計データが空を設定
//                  if (TOTAL_COUNTS_DISPLAY_N.equals(totalCountV)) {
//                    if (i == Column - 1) {
//                      strB[j][i] = "";
//                    }
//                  }
//                  //reportOutputInfoForInTempl.put(key, strB[j][i]);
//                }
//              }
//            }
//          }
//          strBList.add(strB);
//        }
//      }
//      // mod 10546 複数集計出力時にサーバが高負荷になる gjn start
//      // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen start
//      // html = cerateReport(html, strBList, reportXmlParamsList, mstReport, reportZipFile, outPutHtml, true, pageCountMap);
//      // mod 10546 複数集計出力時にサーバが高負荷になる gjn start
//      cerateReport(strBList, reportXmlParamsList, mstReport, reportZipFile, outPutHtml, pageCountMap, param1, param2);
//      // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen end
//      //newHtmlList.add(html);
//      // 複数回数表示の場合、複数帳票の切替を初期化しません。
////      if (newHtmlList.size() < 10) {
////        iLoop.set(0);
////      }
//      // mod 10546 複数集計出力時にサーバが高負荷になる gjn end
//    } else {
//      // データキーからテンプレート外の項目を取得
//      // ※テンプレート有無に関わらず、このデータキーは使用する.
//      Map<String, Object> dataKeyOutTempl = getOutOfTemplateDataKey(dataKey);
//      String num = "";
//      for (ReportXmlParam param : paramsOutTempl) {
//        List<ReportXmlFilterTable> filters = param.getReportXmlFilters();
//        if (filters == null || filters.size() == 0) {
//          continue;
//        }
//        num = filters.get(0).getCode();
//        dataKeyOutTempl.put("examItemCd", num);
//        break;
//      }
//      // ---------------------------------------
//      // テンプレート外の値を埋め込む処理
//      // --------------------------------------
//      createPatientReportHtmlOutTemplate(
//        mstReport,
//        paramsOutTempl,
//        dataKeyOutTempl,
//        dataKey,
//        patIdToCMap,
//        outPutHtml
//      );
//      iLoop.set(0);
//    }
//  }
//
//  /**
//   * 横軸座標位置の位置決め
//   *
//   * @param arr
//   * @param target
//   * @return
//   */
//  public static int findIndex(String[] arr, String target) {
//    for (int i = 0; i < arr.length; i++) {
//      if (arr[i].equals(target)) {
//        return i; // ターゲット文字列を見つけてインデックス値を返す
//      }
//    }
//    return -1; // ターゲット文字列が見つかりませんでした。-1を返します。
//  }
//
//  /**
//   * 数値型の計算
//   *
//   * @param dataListInfo
//   * @param commType
//   * @param paramsInTempl
//   * @param paramsOutTempl
//   * @return
//   */
//  public Map<String, Object> processData(List<Map<String, Object>> dataListInfo, String commType, List<ReportXmlParam> paramsInTempl, List<ReportXmlParam> paramsOutTempl) {
//    Map<String, Object> finalResult = new HashMap<>();
//    Map<String, Map<String, Object>> result = new HashMap<>();
//    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
//
//    for (Map<String, Object> dataMap : dataListInfo) {
//      String aggregateV = "";
//      if (!StringUtils.isEmpty(totalUnitVList.get(0))) {
//        for (ReportXmlParam reportXmlParam : paramsOutTempl) {
//          if (totalUnitVList.get(0).equals(reportXmlParam.getDataCode())) {
//            String type = reportXmlParam.getDataType();
//            if ("DateTime".equals(type)) {
//              if (dataMap.get(totalUnitVList.get(0)) instanceof Date) {
//                Date treatDateObj = (Date) dataMap.get(totalUnitVList.get(0));
//                aggregateV = sdf.format(treatDateObj);
//              } else if (dataMap.get(totalUnitVList.get(0)) instanceof String) {
//                aggregateV = (String) dataMap.get(totalUnitVList.get(0));
//              }
//              break;
//            } else if ("string".equals(type)) {
//              aggregateV = (String) dataMap.get(totalUnitVList.get(0));
//              break;
//            }
//          }
//        }
//      } else {
//        return null;
//      }
//      String aggregateH = "";
//      if (!StringUtils.isEmpty(totalUnitHList.get(0))) {
//        for (ReportXmlParam reportXmlParam : paramsOutTempl) {
//          if (totalUnitHList.get(0).equals(reportXmlParam.getDataCode())) {
//            String type = reportXmlParam.getDataType();
//            if ("DateTime".equals(type)) {
//              Date treatDateObj = (Date) dataMap.get(totalUnitHList.get(0));
//              aggregateH = sdf.format(treatDateObj);
//              break;
//            } else if ("string".equals(type)) {
//              aggregateH = (String) dataMap.get(totalUnitHList.get(0));
//              break;
//            }
//          }
//        }
//      } else {
//        return null;
//      }
//      // 集计内のデータタ类型
//      String dataType = "";
//      // 初期化セット内decimalタイプ
//      BigDecimal amount = BigDecimal.ZERO;
//      // 初期化セット内stringタイプ
//      String comment = "";
//      // 初期化セット内dataTimeタイプ（現時点ではこのテンプレートはありませんので、しばらくは考慮しないでください）
//      LocalDate localDate;
//      // セットカウント内の値のフォーマット
//      String dispFormat = "";
//      // セット内には1つまでしか存在できないので、トラバースする必要はありません
//      if (paramsInTempl.size() > 0) {
//        dataType = paramsInTempl.get(0).getDataType();
//        String dataCode = paramsInTempl.get(0).getDataCode();
//        if ("decimal".equals(dataType)) {
//          dispFormat = paramsInTempl.get(0).getDispFormat();
//          // mod 10998 「週間.医材」の出力内容修正 gjn start
//          amount = new BigDecimal(!StringUtils.isEmpty(dataMap.get(dataCode)) ? (String) dataMap.get(dataCode) : "0");
//        } else if ("string".equals(dataType)) {
//          comment = !StringUtils.isEmpty(dataMap.get(dataCode)) ? (String) dataMap.get(dataCode) : "";
//        } else if ("DateTime".equals(dataType)) {
//          localDate = !StringUtils.isEmpty(dataMap.get(dataCode)) ? (LocalDate) dataMap.get(dataCode) : null;
//          // mod 10998 「週間.医材」の出力内容修正 gjn end
//        } else {
//          // 他のタイプはまず文字列で処理されます
//          comment = (String) dataMap.get(dataCode);
//        }
//      }
//      String groupKey = aggregateV + CONNECTION_SYMBOL + aggregateH;
//
//      if (StringUtils.isEmpty(dataType)) {
//        return null;
//      }
//      if (!result.containsKey(groupKey)) {
//        result.put(groupKey, new HashMap<>());
//        if (!"string".equals(dataType)) {
//          result.get(groupKey).put("totalAmount", amount);
//          result.get(groupKey).put("maxAmount", amount);
//          result.get(groupKey).put("minAmount", amount);
//          result.get(groupKey).put("avgAmount", amount);
//          result.get(groupKey).put("lastAmount", amount);
//          result.get(groupKey).put("count", 1);
//        } else {
//          result.get(groupKey).put("lastAmount", comment);
//          result.get(groupKey).put("count", 1);
//        }
//      } else {
//        if (!"string".equals(dataType)) {
//          BigDecimal totalAmount = (BigDecimal) result.get(groupKey).get("totalAmount");
//          BigDecimal maxAmount = (BigDecimal) result.get(groupKey).get("maxAmount");
//          BigDecimal minAmount = (BigDecimal) result.get(groupKey).get("minAmount");
//          int count = (int) result.get(groupKey).get("count");
//          totalAmount = totalAmount.add(amount);
//          maxAmount = maxAmount.max(amount);
//          minAmount = minAmount.min(amount);
//          // カウント値の更新
//          int updatedCount = count + 1;
//          result.get(groupKey).put("count", updatedCount);
//          // 更新されたカウントを使用して平均値を計算する
//          BigDecimal avgAmount = totalAmount.divide(BigDecimal.valueOf(updatedCount), 3, BigDecimal.ROUND_HALF_UP);
//          BigDecimal lastAmount = amount;
//          result.get(groupKey).put("totalAmount", totalAmount);
//          result.get(groupKey).put("maxAmount", maxAmount);
//          result.get(groupKey).put("minAmount", minAmount);
//          result.get(groupKey).put("avgAmount", avgAmount);
//          result.get(groupKey).put("lastAmount", lastAmount);
//        } else {
//          int count = (int) result.get(groupKey).get("count");
//          // カウント値の更新
//          int updatedCount = count + 1;
//          result.get(groupKey).put("count", updatedCount);
//          String lastComment = comment;
//          result.get(groupKey).put("lastAmount", lastComment);
//        }
//      }
//    }
//    // commTypeに応じた計算
//    switch (commType) {
//      // 合計
//      case "total":
//        result.forEach((key, value) -> {
//          //add #10989 「0」を空白にしてほしいのは、集計＞表示内容が「合計」のときだけ。start
//          if(value.get("totalAmount")instanceof BigDecimal && (((BigDecimal) value.get("totalAmount")).compareTo(BigDecimal.ZERO) == 0)){
//            finalResult.put(key, "");
//          }else{
//            finalResult.put(key, value.get("totalAmount"));
//          }
//          //add #10989 「0」を空白にしてほしいのは、集計＞表示内容が「合計」のときだけ。end
//        });
//        break;
//      // 最大値
//      case "max":
//        result.forEach((key, value) -> {
//          finalResult.put(key, value.get("maxAmount"));
//        });
//        break;
//      // 最小値
//      case "min":
//        result.forEach((key, value) -> {
//          finalResult.put(key, value.get("minAmount"));
//        });
//        break;
//      // 平均値
//      case "avg":
//        result.forEach((key, value) -> {
//          finalResult.put(key, value.get("avgAmount"));
//        });
//        break;
//      // 项目値
//      case "last":
//        result.forEach((key, value) -> {
//          finalResult.put(key, value.get("lastAmount"));
//        });
//        break;
//      default:
//        break;
//    }
//    return finalResult;
//  }
//
//
//  /**
//   * 与えられた帳票定義xml内にテンプレート繰り返しが含まれあるか否かを返す.
//   * 繰り返しの判断はreport要素のhasTmplで判断する.
//   * "0" : テンプレート繰り返しなし
//   * "1" : テンプレート繰り返しあり
//   *
//   * @param reportXml 帳票定義xml
//   * @return true : テンプレート繰り返しあり、false : テンプレート繰り返しなし
//   * @throws NtssException テンプレート繰り返しの判定に失敗した場合(帳票定義xmlの解析に失敗等)
//   */
//  private boolean hasTemplate(String reportXml) throws NtssException {
//    // 帳票定義XMLにinputStream
//    InputStream inputStream = null;
//    try {
//      // 帳票定義XMLを読み込む.
//      inputStream = new ByteArrayInputStream(reportXml.getBytes(StandardCharsets.UTF_8));
//      // 帳票定義Xmlをパース
//      org.w3c.dom.Document document = ReportUtils.getDomDocument(inputStream);
//      // report要素を取得する
//      NodeList nodeReport = document.getElementsByTagName("report");
//      Element repElement = (Element) nodeReport.item(0);
//      if (Objects.isNull(repElement)) {
//        return false;
//      }
//      String strHasTmpl = repElement.getAttribute("hasTmpl");
//      return !StringUtils.isEmpty(strHasTmpl) && strHasTmpl.equals("1");
//    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage("report xml parse param failed.");
//      logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
//      throw new NtssException("帳票定義xmlからテンプレート有無の判定に失敗しました", e.getCause());
//    } finally {
//      Optional.ofNullable(inputStream).ifPresent(is -> {
//        try {
//          is.close();
//        } catch (IOException e) {
//          EventLogMessage eventLogMessage = new EventLogMessage();
//          eventLogMessage.setLogMessage("帳票定義XMLのinputStreamを閉じる事が出来ませんでした。");
//          logService.log(LogLevel.DEBUG, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
//        }
//      });
//    }
//  }
//
//
//  /**
//   * 集計単位セルID取得
//   *
//   * @param totalUnitList
//   * @param paramsOutTempl
//   * @return
//   */
//  private List<String> getTotalId(List<String> totalUnitList, List<ReportXmlParam> paramsOutTempl) {
//    List<String> strUnitId = new ArrayList<>();
//    for (ReportXmlParam param : paramsOutTempl) {
//      // 集計単位のセルID取得
//      for (String list : totalUnitList) {
//        if (list.equals(param.getDataCode())) {
//          strUnitId.add(param.getId());
//          break;
//        }
//      }
//    }
//    // ソート処理
//    String[] arr = strUnitId.toArray(new String[0]);
//    Arrays.sort(arr, Comparator.<String, Character>comparing(s -> s.charAt(0))
//      .thenComparingInt(s -> Integer.parseInt(s.substring(1, s.substring(1).indexOf(":") < 0 ? s.length() : s.substring(1).indexOf(":") + 1))));
//    strUnitId = Arrays.asList(arr);
//    return strUnitId;
//  }
//
//
//  /**
//   * 集計単位順を編集する
//   *
//   * @param strUnitId
//   * @param paramsOutTempl
//   * @return
//   */
//  private List<String> getTotalDataCode(List<String> strUnitId, List<ReportXmlParam> paramsOutTempl) {
//    List<String> totalUnitList = new ArrayList<>();
//    for (ReportXmlParam param : paramsOutTempl) {
//      for (String list : strUnitId) {
//        if (list.equals(param.getId())) {
//          totalUnitList.add(param.getDataCode());
//          break;
//        }
//      }
//    }
//    return totalUnitList;
//  }
//
//
//  /**
//   * テンプレート外のデータキーを取得する.
//   *
//   * @param dataKey データキー
//   * @return テンプレート外のデータキー
//   */
//  private Map<String, Object> getOutOfTemplateDataKey(Map<String, Object> dataKey) {
//    // テンプレート外の項目を読み込む
//    Map<String, Object> dataKeyOut = new HashMap<String, Object>();
//    // テンプレート外のdataKeyをdataKeyOutに設定する.
//    List<Map<String, Object>> tmplParams = new ArrayList<Map<String, Object>>();
//    boolean contains = dataKey.containsKey(ReportConstant.ReportDataKey.TEMPLATE_PARAMS);
//    if (contains) {
//      tmplParams = (List<Map<String, Object>>) dataKey.get(ReportConstant.ReportDataKey.TEMPLATE_PARAMS);
//    }
//    if (tmplParams.size() > 0) {
//      Map<String, Object> tmplParam = new HashMap<>();
//      tmplParam = tmplParams.get(0);
//      dataKeyOut.put("ordNo", tmplParam.get("ordNo"));
//      //パラメータkey値が統一されていないためデータを正しく取得できない問題を修正する
//      if (dataKeyOut.get("ordNo") == null) {
//        dataKeyOut.put("ordNo", tmplParam.get("ordNos"));
//      }
//      dataKeyOut.put("patId", tmplParam.get("patId"));
//      dataKeyOut.put("date", tmplParam.get("date"));
//      dataKeyOut.put("fromDate", tmplParam.get("fromDate"));
//      dataKeyOut.put("toDate", tmplParam.get("toDate"));
//      dataKeyOut.put("patIds", tmplParam.get("patIds"));
//      dataKeyOut.put("facilityCd", tmplParam.get("facilityCd"));
//      dataKeyOut.put("ordPrescriptionNos", tmplParam.get("ordPrescriptionNo"));
//      dataKeyOut.put(ReportConstant.ReportDataKey.MEDICINE_IDS, tmplParam.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
//      dataKeyOut.put(ReportConstant.ReportDataKey.DIALYZER_IDS, tmplParam.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
//      dataKeyOut.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS, tmplParam.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
//      dataKeyOut.put("treatDate", tmplParam.get("treatDate"));
//      dataKeyOut.put("treat_date", tmplParam.get("treatDate"));
//    }
//    dataKey.entrySet().forEach(e -> {
//      // dataKey名がテンプレート内のパラメータ名以外の場合は、テンプレート外と判断
//      if (!e.getKey().equals(ReportConstant.ReportDataKey.TEMPLATE_PARAMS)) {
//        if (dataKeyOut.get(e.getKey()) == null || dataKeyOut.get(e.getKey()).equals("")) {
//          dataKeyOut.put(e.getKey(), e.getValue());
//        }
//      }
//    });
//    return dataKeyOut;
//  }
//
//  // add 10546 複数集計出力時にサーバが高負荷になる gjn start
//  private  <T> List<List<T>> splitList(List<T> list, int numGroups) {
//    List<List<T>> result = new ArrayList<>();
//    int size = list.size();
//    int groupSize = (int) Math.ceil((double) size / numGroups);
//
//    for (int i = 0; i < numGroups; i++) {
//      int start = i * groupSize;
//      int end = Math.min(start + groupSize, size);
//
//      result.add(new ArrayList<>(list.subList(start, end)));
//    }
//
//    return result;
//  }
//  // add 10546 複数集計出力時にサーバが高負荷になる gjn end
//
//  /**
//   * DB取值 by sqlCd
//   *
//   * @param mstReport
//   * @param reportZipFile
//   * @param reportHtml
//   * @param reportXmlParamsList
//   * @param paramsOutTempl
//   * @param dataKeyOutTempl
//   * @param pageCountMap
//   * @param dataKeyOut
//   * @param reportInfoForTempl
//   * @param outPutHtml
//   * @return
//   */
//  // mod 10546 複数集計出力時にサーバが高負荷になる gjn start
//  private void createPatientReportHtmlOutTemplateForCount(
//  // mod 10546 複数集計出力時にサーバが高負荷になる gjn end
//    MstReport mstReport,
//    ReportZipFile reportZipFile,
//    String reportHtml,
//    List<ReportXmlParam> reportXmlParamsList,
//    List<ReportXmlParam> paramsOutTempl,
//    Map<String, Object> dataKeyOutTempl,
//    Map<String, Integer> pageCountMap,
//    Map<String, Object> dataKeyOut,
//    Map<Long, List<Map<String, Object>>> reportInfoForTempl,
//    Map<String, String> outPutHtml,
//    List<ReportXmlParam> paramsInTempl,
//    List<Map<String, Object>> dataKeyInOfTemplateList) {
//    String getColWidth = "";
//    String getRowHeight = "";
//    if (reportXmlParamsList.size() > 0) {
//      for (int p = 0; p < reportXmlParamsList.size(); p++) {
//        if ("".equals(reportXmlParamsList.get(p).getDataCode()) && "byte[]".equals(reportXmlParamsList.get(p).getDataType())) {
//          getColWidth = reportXmlParamsList.get(p).getColWidth();
//          getRowHeight = reportXmlParamsList.get(p).getRowHeight();
//        }
//      }
//    }
//    // del 10546 複数集計出力時にサーバが高負荷になる gjn start
//    // 帳票デザイン
////    if (StringUtils.isEmpty(reportHtml)) {
////      EventLogMessage eventLogMessage = new EventLogMessage();
////      eventLogMessage.setLogMessage("帳票デザインHTMLファイルを取得できません。レポートコード : " + mstReport.getReportCd());
////      eventLogMessage.setFacilityCd(mstReport.getFacilityCd());
////      logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
////      // 空のHTMLを返却
////      return Collections.EMPTY_LIST;
////    }
//    // del 10546 複数集計出力時にサーバが高負荷になる gjn end
//    String num = "";
//    for (ReportXmlParam param : reportXmlParamsList) {
//      List<ReportXmlFilterTable> filters = param.getReportXmlFilters();
//      if (filters == null || filters.size() == 0) {
//        continue;
//      }
//      num = filters.get(0).getCode();
//      dataKeyOutTempl.put("examItemCd", num);
//      break;
//    }
//    dataKeyOutTempl.put("sqlTestSign", dataKeyOut.get("sqlTestSign"));
//    // add 10546 複数集計出力時にサーバが高負荷になる gjn start
//    Map<Long, List<Map<String, Object>>> reportInfoForOutTempl = new HashMap<>();
//    if (!dataKeyOutTempl.containsKey("ordNos") || Objects.isNull(dataKeyOutTempl.get("ordNos"))) {
//      // テンプレート外の領域にある項目にデータを当てはめる処理
//      reportInfoForOutTempl = getReportInfo(paramsOutTempl, dataKeyOutTempl);
//    } else {
//      List<Long> ordNosList = (List<Long>) dataKeyOutTempl.get("ordNos");
//      int totalByteLength = ordNosList.size() * Long.BYTES;
//      System.err.println("ord_noパラメータの総バイト長: " + totalByteLength + " byte");
//      Long sqlCodeCheckParams = Long.parseLong(paramsInTempl.get(0).getSqlCode());
//      // 現在sqlCdのsqlに@ordNosを含むパラメータの
//      if ((74L == sqlCodeCheckParams || 149L == sqlCodeCheckParams) && totalByteLength > SQL_MAX_PARAM_BYTE) {
//        // 除算結果を計算して上方向に整列する
//        double result = (double) totalByteLength / SQL_MAX_PARAM_BYTE;
//        int numGroups = (int) Math.ceil(result);
//        List<List<Long>> splitLists = splitList(ordNosList, numGroups);
//        // dataKeyOutTemplパラメータを再構築し、サブクエリ結果を結合します
//        List<List<Map<String, Object>>> totalListData = new ArrayList<>();
//        for (List<Long> sl : splitLists) {
//          Map<String, Object> dataKeyOutTempl_t = new HashMap<>();
//          dataKeyOutTempl_t.put("date", dataKeyOutTempl.get("date"));
//          dataKeyOutTempl_t.put("kurCdList ", dataKeyOutTempl.get("kurCdList"));
//          dataKeyOutTempl_t.put("weeks", dataKeyOutTempl.get("weeks"));
//          dataKeyOutTempl_t.put("diaIds", dataKeyOutTempl.get("diaIds"));
//          dataKeyOutTempl_t.put("patId", dataKeyOutTempl.get("patId"));
//          dataKeyOutTempl_t.put("toDate", dataKeyOutTempl.get("toDate"));
//          dataKeyOutTempl_t.put("ordNos", sl);
//          dataKeyOutTempl_t.put("eqIds", dataKeyOutTempl.get("eqIds"));
//          dataKeyOutTempl_t.put("fromDate", dataKeyOutTempl.get("fromDate"));
//          dataKeyOutTempl_t.put("medIds", dataKeyOutTempl.get("medIds"));
//          dataKeyOutTempl_t.put("machineNos", dataKeyOutTempl.get("machineNos"));
//          dataKeyOutTempl_t.put("ordNo", dataKeyOutTempl.get("ordNo"));
//          dataKeyOutTempl_t.put("sqlTestSign", dataKeyOutTempl.get("sqlTestSign"));
//          dataKeyOutTempl_t.put("facilityCd", dataKeyOutTempl.get("facilityCd"));
//          dataKeyOutTempl_t.put("patIds", dataKeyOutTempl.get("patIds"));
//          Map<Long, List<Map<String, Object>>> reportInfoForOutTempl_t = getReportInfo(paramsOutTempl, dataKeyOutTempl_t);
//          // 最初の検索後に予約して、他のsqlCdのクエリがないようにする
//          reportInfoForOutTempl = reportInfoForOutTempl_t;
//          // sqlCdに対応するデータを取り出す
//          List<Map<String, Object>> fdata = reportInfoForOutTempl_t.get(sqlCodeCheckParams);
//          totalListData.add(fdata);
//        }
//        // データのマージ
//        List<Map<String, Object>> mergedList = new ArrayList<>();
//        for (List<Map<String, Object>> innerList : totalListData) {
//          mergedList.addAll(innerList);
//        }
//        // マージされたデータを戻す
//        reportInfoForOutTempl.put(sqlCodeCheckParams, mergedList);
//      } else {
//        // テンプレート外の領域にある項目にデータを当てはめる処理
//        reportInfoForOutTempl = getReportInfo(paramsOutTempl, dataKeyOutTempl);
//      }
//    }
//    // add 10546 複数集計出力時にサーバが高負荷になる gjn end
//
//    //add #10998「週間.医材」の出力内容修正 杜 start
////入院と外来処理
//    if (reportInfoForOutTempl.containsKey(151L) || reportInfoForOutTempl.containsKey(150L)){
//      // del #11883 「##週間.医材.外来合計／入院合計」の集計対象がFNWと異なる limingzhe start
//      //Integer patNum = ((ArrayList)dataKeyOutTempl.get("patIds")).size();
//      // del #11883 「##週間.医材.外来合計／入院合計」の集計対象がFNWと異なる limingzhe end
//      List<Map<String, Object>> reportInfoForDis = null;
//      // del #11883 「##週間.医材.外来合計／入院合計」の集計対象がFNWと異なる limingzhe start
//      //List<Map<String, Object>> minTimePerId = null;
//      //minTimePerId = findMinTimeInHospitalForNonForeign(reportInfoForOutTempl.get(151L) != null ? reportInfoForOutTempl.get(151L) : reportInfoForOutTempl.get(150L));//只有入院的情况获取最小日期
//      //processList(reportInfoForOutTempl.get(151L) != null ? reportInfoForOutTempl.get(151L) : reportInfoForOutTempl.get(150L));//入院到外来期间替换成入院
//      // del #11883 「##週間.医材.外来合計／入院合計」の集計対象がFNWと異なる limingzhe end
//      reportInfoForDis = reportInfoForOutTempl.get(151L) != null ? reportInfoForOutTempl.get(151L) : reportInfoForOutTempl.get(150L);
//
//      // del #11883 「##週間.医材.外来合計／入院合計」の集計対象がFNWと異なる limingzhe start
////      for (int i = 0; i < reportInfoForDis.size(); i++) {
////        for (int j = 0; j < minTimePerId.size(); j++) {
////          if (reportInfoForDis.get(i).get("pat_id") == minTimePerId.get(j).get("pat_id")) {
////            reportInfoForDis.remove(i);
////          }
////        }
////      }
//      // del #11883 「##週間.医材.外来合計／入院合計」の集計対象がFNWと異なる limingzhe end
//
//      Integer startDate = Integer.parseInt(dataKeyOut.get("fromDate").toString());
//      Integer endDate = Integer.parseInt(dataKeyOut.get("toDate").toString());
//      DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
//      LocalDate dateStr = LocalDate.parse(dataKeyOut.get("fromDate").toString(), formatter);
//      LocalDate dateEnd = LocalDate.parse(dataKeyOut.get("toDate").toString(), formatter);
//      long daysBetween = ChronoUnit.DAYS.between(dateStr, dateEnd);
////入院と外来の初期化
//      List<Map<String, Object>> newList = new ArrayList<>(); //入院
//      List<Map<String, Object>> outList = new ArrayList<>(); //外来
//      // add #11898 ##週間.医材.外来合計／入院合計の集計仕様が不適切 limingzhe start
//      List<Map<String, Object>> dieList = new ArrayList<>(); //死亡
//      // add #11898 ##週間.医材.外来合計／入院合計の集計仕様が不適切 limingzhe end
//      LocalDate beginDate = dateStr;
//      for (int i = 0; i < daysBetween + 1; i++) {
//        Map<String, Object> outMap = new HashMap<>();
//        Map<String, Object> newMap = new HashMap<>();
//        newMap.put("hosp_pat_cnt", 0);
//        newMap.put("reg_date", Integer.parseInt(beginDate.toString().replace("-","")));
//        outMap.put("out_pat_cnt", 0);
//        outMap.put("reg_date", Integer.parseInt(beginDate.toString().replace("-","")));
//        outList.add(outMap);
//        newList.add(newMap);
//        // add #11898 ##週間.医材.外来合計／入院合計の集計仕様が不適切 limingzhe start
//        Map<String, Object> dieMap = new HashMap<>();
//        dieMap.put("die_pat_cnt", 0);
//        dieMap.put("reg_date", Integer.parseInt(beginDate.toString().replace("-","")));
//        dieList.add(dieMap);
//        // add #11898 ##週間.医材.外来合計／入院合計の集計仕様が不適切 limingzhe end
//        beginDate = beginDate.plusDays(1);
//      }
//
//      // del #11883 「##週間.医材.外来合計／入院合計」の集計対象がFNWと異なる limingzhe start
////一つ入院処理
////      if(minTimePerId.size() != 0) {
////        for (int j = 0; j < minTimePerId.size(); j++) {
////
////          Integer flg = Integer.parseInt(minTimePerId.get(j).get("reg_date").toString());
////          LocalDate flgDate = LocalDate.parse(minTimePerId.get(j).get("reg_date").toString(), formatter);
////
////          if (flg <= endDate && flg >= startDate) {
////            for (int i = (int) ChronoUnit.DAYS.between(dateStr, flgDate); i < daysBetween + 1; i++) {
////              Integer startIndex = Integer.parseInt(newList.get(i).get("hosp_pat_cnt").toString()) + 1;
////              newList.get(i).put("hosp_pat_cnt", startIndex);
////            }
////          }
////          if (flg < startDate) {
////            for (int i = 0; i < newList.size(); i++) {
////              Integer startIndex = Integer.parseInt(newList.get(i).get("hosp_pat_cnt").toString()) + 1;
////              newList.get(i).put("hosp_pat_cnt", startIndex);
////            }
////          }
////        }
////      }
//      // del #11883 「##週間.医材.外来合計／入院合計」の集計対象がFNWと異なる limingzhe end
//
////入院処理
//      // add #11883 「##週間.医材.外来合計／入院合計」の集計対象がFNWと異なる limingzhe start
//      Map<String, List<Map<String, Object>>> groupedByDate = reportInfoForDis.stream()
//        .filter(p -> p.get("treat_date") != null)
//        .collect(Collectors.groupingBy(map -> (String) map.get("treat_date")));
//
//      Map<Long, List<Map<String, Object>>> groupedByPat =  reportInfoForDis.stream()
//        .filter(p -> p.get("pat_id") != null)
//        .collect(Collectors.groupingBy(map -> (Long) map.get("pat_id")));
//      for(Long pId : groupedByPat.keySet()){
//        List<Map<String, Object>> inoutInfo = groupedByPat.get(pId);
//        if(inoutInfo == null || inoutInfo.size() == 0) continue;
//        // fromDate~toDate 入院/外来 あり
//        List<Map<String, Object>> inList = inoutInfo.stream().filter(p -> p.get("move_in_out_name") != null)
//          // add #11960 ##週間.医材.外来合計／入院合計の集計結果におかしい部分がある limingzhe start
//          .sorted(Comparator.comparingLong(p -> Long.parseLong(String.valueOf(p.get("in_out_date")))))
//          // add #11960 ##週間.医材.外来合計／入院合計の集計結果におかしい部分がある limingzhe end
//          .collect(Collectors.toList());
//        if(inList.size() > 0){
//          Map<String, String> inoutStateMap = new HashMap<>();
//          for (int i = 0; i < newList.size(); i++) {
//            // mod #11898 ##週間.医材.外来合計／入院合計の集計仕様が不適切 limingzhe start
//            //inoutStateMap.put(String.valueOf(newList.get(i).get("reg_date")), "入院".equals(String.valueOf(inList.get(0).get("last_move_in_out_name"))) ? "入院" : "外来");
//            // mod #11960 ##週間.医材.外来合計／入院合計の集計結果におかしい部分がある limingzhe start
//            //inoutStateMap.put(String.valueOf(newList.get(i).get("reg_date")), String.valueOf(inList.get(0).get("last_move_in_out_name")));
//            String lastInOut = "外来";
//            for(int j = 0; j < inList.size(); j++){
//              if(inList.get(j).get("last_move_in_out_name") != null){
//                lastInOut = String.valueOf(inList.get(j).get("last_move_in_out_name"));
//              }
//            }
//            inoutStateMap.put(String.valueOf(newList.get(i).get("reg_date")), lastInOut);
//            // mod #11960 ##週間.医材.外来合計／入院合計の集計結果におかしい部分がある limingzhe end
//            // mod #11898 ##週間.医材.外来合計／入院合計の集計仕様が不適切 limingzhe end
//          }
//          for(int j = 0; j < inList.size(); j++){
//            LocalDate flgDate = LocalDate.parse(String.valueOf(inList.get(j).get("in_out_date")), formatter);
//            for (int i = (int) ChronoUnit.DAYS.between(dateStr, flgDate); i < daysBetween + 1; i++) {
//              LocalDate newDate = dateStr.plusDays(i);
//              // mod #11898 ##週間.医材.外来合計／入院合計の集計仕様が不適切 limingzhe start
//              //inoutStateMap.put(newDate.format(formatter), "入院".equals(String.valueOf(inList.get(j).get("move_in_out_name"))) ? "入院" : "外来");
//              inoutStateMap.put(newDate.format(formatter), String.valueOf(inList.get(j).get("move_in_out_name")));
//              // mod #11898 ##週間.医材.外来合計／入院合計の集計仕様が不適切 limingzhe end
//            }
//          }
//          for (int i = 0; i < newList.size(); i++) {
//            for(int j = 0; j < inoutInfo.size(); j++){
//              if(String.valueOf(newList.get(i).get("reg_date")).equals(String.valueOf(inoutInfo.get(j).get("treat_date")))){
//                // add #11960 ##週間.医材.外来合計／入院合計の集計結果におかしい部分がある limingzhe start
//                if(inoutStateMap.containsKey(String.valueOf(dieList.get(i).get("reg_date")))
//                  && "死亡".equals(inoutStateMap.get(String.valueOf(dieList.get(i).get("reg_date"))))
//                ){
//                  Integer startIndex = Integer.parseInt(dieList.get(i).get("die_pat_cnt").toString()) + 1;
//                  dieList.get(i).put("die_pat_cnt", startIndex);
//                } else
//                // add #11960 ##週間.医材.外来合計／入院合計の集計結果におかしい部分がある limingzhe end
//                if(inoutStateMap.containsKey(String.valueOf(newList.get(i).get("reg_date")))
//                  && "入院".equals(inoutStateMap.get(String.valueOf(newList.get(i).get("reg_date"))))
//                ){
//                  Integer startIndex = Integer.parseInt(newList.get(i).get("hosp_pat_cnt").toString()) + 1;
//                  newList.get(i).put("hosp_pat_cnt", startIndex);
//                }
//                // del #11960 ##週間.医材.外来合計／入院合計の集計結果におかしい部分がある limingzhe start
////                // add #11898 ##週間.医材.外来合計／入院合計の集計仕様が不適切 limingzhe start
////                else if(inoutStateMap.containsKey(String.valueOf(dieList.get(i).get("reg_date")))
////                  && "死亡".equals(inoutStateMap.get(String.valueOf(dieList.get(i).get("reg_date"))))
////                ){
////                  Integer startIndex = Integer.parseInt(dieList.get(i).get("die_pat_cnt").toString()) + 1;
////                  dieList.get(i).put("die_pat_cnt", startIndex);
////                }
////                // add #11898 ##週間.医材.外来合計／入院合計の集計仕様が不適切 limingzhe end
//                // del #11960 ##週間.医材.外来合計／入院合計の集計結果におかしい部分がある limingzhe end
//              }
//            }
//          }
//        } else {
//          // fromDate~toDate 入院/外来ない & 予定あり
//          // add #11960 ##週間.医材.外来合計／入院合計の集計結果におかしい部分がある limingzhe start
//          if("死亡".equals(String.valueOf(inoutInfo.get(0).get("last_move_in_out_name")))){
//            for (int i = 0; i < dieList.size(); i++) {
//              for(int j = 0; j < inoutInfo.size(); j++){
//                if(String.valueOf(dieList.get(i).get("reg_date")).equals(String.valueOf(inoutInfo.get(j).get("treat_date")))){
//                  Integer startIndex = Integer.parseInt(dieList.get(i).get("die_pat_cnt").toString()) + 1;
//                  dieList.get(i).put("die_pat_cnt", startIndex);
//                }
//              }
//            }
//          } else
//          // add #11960 ##週間.医材.外来合計／入院合計の集計結果におかしい部分がある limingzhe end
//          if("入院".equals(String.valueOf(inoutInfo.get(0).get("last_move_in_out_name")))){
//            for (int i = 0; i < newList.size(); i++) {
//              for(int j = 0; j < inoutInfo.size(); j++){
//                if(String.valueOf(newList.get(i).get("reg_date")).equals(String.valueOf(inoutInfo.get(j).get("treat_date")))){
//                  Integer startIndex = Integer.parseInt(newList.get(i).get("hosp_pat_cnt").toString()) + 1;
//                  newList.get(i).put("hosp_pat_cnt", startIndex);
//                }
//              }
//            }
//          }
//        }
//      }
//      // add #11883 「##週間.医材.外来合計／入院合計」の集計対象がFNWと異なる limingzhe end
//
//      if (reportInfoForOutTempl.containsKey(151L)) {
//        for (int i = 0; i < newList.size(); i++) {
//          // del #11883 「##週間.医材.外来合計／入院合計」の集計対象がFNWと異なる limingzhe start
////          for (int j = 0; j < reportInfoForDis.size(); j++) {
////            if (Integer.parseInt(newList.get(i).get("reg_date").toString()) == Integer.parseInt(reportInfoForDis.get(j).get("reg_date").toString())
////              && "入院".equals(reportInfoForDis.get(j).get("move_in_out_name"))) {
////              Integer startIndex = Integer.parseInt(newList.get(i).get("hosp_pat_cnt").toString()) + 1;
////              newList.get(i).put("hosp_pat_cnt", startIndex);
////
////            }
////          }
//          // del #11883 「##週間.医材.外来合計／入院合計」の集計対象がFNWと異なる limingzhe end
//          String date =  newList.get(i).get("reg_date").toString();
//          newList.get(i).put("reg_date", date);
//        }
//        reportInfoForOutTempl.put(151L,newList);
//      }
//
////外来処理
//      if (reportInfoForOutTempl.containsKey(150L)){
//        // add #11883 「##週間.医材.外来合計／入院合計」の集計対象がFNWと異なる limingzhe start
//        Map<String, Integer> dateMap = new HashMap<>();
//        for(String sDate : groupedByDate.keySet()){
//          dateMap.put(sDate, groupedByDate.get(sDate).size());
//        }
//        Integer patNum = 0;
//        // add #11883 「##週間.医材.外来合計／入院合計」の集計対象がFNWと異なる limingzhe end
//        for (int i = 0; i < outList.size(); i++) {
//          String date =  outList.get(i).get("reg_date").toString();
//          outList.get(i).put("reg_date", date);
//          // mod #11883 「##週間.医材.外来合計／入院合計」の集計対象がFNWと異なる limingzhe start
//          //Integer startIndex =patNum - (Integer.parseInt(newList.get(i).get("hosp_pat_cnt").toString()));
//          if(dateMap.containsKey(date)){
//            patNum = Integer.parseInt(dateMap.get(date).toString());
//          }
//          // add #11960 ##週間.医材.外来合計／入院合計の集計結果におかしい部分がある limingzhe start
//          else {
//            patNum = 0;
//          }
//          // add #11960 ##週間.医材.外来合計／入院合計の集計結果におかしい部分がある limingzhe end
//          Integer hospCount = Integer.parseInt(newList.get(i).get("hosp_pat_cnt").toString());
//          // add #11898 ##週間.医材.外来合計／入院合計の集計仕様が不適切 limingzhe start
//          Integer dieCount = Integer.parseInt(dieList.get(i).get("die_pat_cnt").toString());
//          // add #11898 ##週間.医材.外来合計／入院合計の集計仕様が不適切 limingzhe end
//          // mod #11898 ##週間.医材.外来合計／入院合計の集計仕様が不適切 limingzhe start
//          //Integer startIndex = patNum > hospCount ? patNum - hospCount : 0;
//          Integer startIndex = patNum > hospCount ? patNum - hospCount - dieCount : 0;
//          // mod #11898 ##週間.医材.外来合計／入院合計の集計仕様が不適切 limingzhe end
//          // mod #11883 「##週間.医材.外来合計／入院合計」の集計対象がFNWと異なる limingzhe end
//          outList.get(i).put("out_pat_cnt", startIndex);
//        }
//        reportInfoForOutTempl.put(150L,outList);
//      }
//    }
//    //add #10998「週間.医材」の出力内容修正 杜 end
//
//    // add 11010 スケジュール表出力時の処理が不足している gjn start
//    /**
//     * functionCd区別機能によるチケットの枚数画面と帳票画面
//     * 機能帳票画面出力であればselectKurCdとbedCdsだけを見る;
//     * 帳票画面の出力であれば、kurCdListsとbedCdListsだけを見ます。
//     */
//    // 帳票画面のフィルタ条件
//    List<Long> kurCdLists = dataKeyOut.containsKey("kurCdLists") ? (List<Long>) dataKeyOut.get("kurCdLists") : new ArrayList<>();
//    List<Long> bedCdLists = dataKeyOut.containsKey("bedCdLists") ? (List<Long>) dataKeyOut.get("bedCdLists") : new ArrayList<>();
//    if (dataKeyOut.containsKey("functionCd") && !Objects.isNull(dataKeyOut.get("functionCd"))) { // 機能帳票
//      // デフォルト初期化
//      kurCdLists.clear();
//      bedCdLists.clear();
//      // 機能帳票選別条件
//      List<Integer> selectKurCd = dataKeyOut.containsKey("selectKurCd") ? (List<Integer>) dataKeyOut.get("selectKurCd") : new ArrayList<>();
//      List<Long> bedCds  = dataKeyOut.containsKey("bedCds") ? (List<Long>) dataKeyOut.get("bedCds") : new ArrayList<>();
//      if (selectKurCd != null && selectKurCd.size() > 0) {
//        selectKurCd.forEach(f -> {
//          kurCdLists.add(f.longValue());
//        });
//      }
//      if (bedCds != null && bedCds.size() > 0) {
//        bedCds.forEach(f -> {
//          bedCdLists.add(f);
//        });
//      }
//    }
//
//    if (reportInfoForOutTempl.containsKey(152L)) {
//      List<Map<String, Object>> oneFiveTwoInfo = reportInfoForOutTempl.get(152L);
//      List<Map<String, Object>> filteredInfo152;
//
//      if (kurCdLists != null && kurCdLists.size() > 0) {
//        filteredInfo152 = oneFiveTwoInfo.stream()
//          .filter(entry -> {
//            Long kurCd = (Long) entry.get("kur_cd");
//            return kurCdLists.contains(kurCd);
//          }).collect(Collectors.toList());
//      } else {
//        filteredInfo152 = oneFiveTwoInfo;
//      }
//
//      if (bedCdLists != null && bedCdLists.size() > 0) {
//        filteredInfo152 = filteredInfo152.stream()
//          .filter(entry -> {
//            Long bedCd = (Long) entry.get("bed_cd");
//            return bedCdLists.contains(bedCd);
//          }).collect(Collectors.toList());
//      }
//      // Streamを使用したリストのソート
//      SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMdd");
//      List<Map<String, Object>> sortedList = filteredInfo152.stream()
//        .sorted((m1, m2) -> {
//          // 最初にbed_disp_orderでソート
//          String bed_disp_order1 = (String) m1.get("bed_disp_order");
//          String bed_disp_order2 = (String) m2.get("bed_disp_order");
//          int bedNameComparison = bed_disp_order1.compareTo(bed_disp_order2);
//          if (bedNameComparison != 0) {
//            return bedNameComparison;
//          }
//          // treat_dateでソート
//          String treat_date1 = (String) m1.get("treat_date");
//          String treat_date2 = (String) m2.get("treat_date");
//          // 解析時間
//          try {
//            Date d1 = dateFormat.parse(treat_date1);
//            Date d2 = dateFormat.parse(treat_date2);
//            return d1.compareTo(d2);
//          } catch (ParseException e) {
//            throw new RuntimeException("日付解決に失敗しました", e);
//          }
//        }).collect(Collectors.toList());
//      reportInfoForOutTempl.put(152L, sortedList);
//    }
//    // mod 10546 複数集計出力時にサーバが高負荷になる gjn start
//    if (reportInfoForOutTempl.containsKey(153L) && kurCdLists != null && kurCdLists.size() > 0) {
//      // mod 10546 複数集計出力時にサーバが高負荷になる gjn end
//      List<Map<String, Object>> oneFiveThreeInfo = reportInfoForOutTempl.get(153L);
//      List<Map<String, Object>> filteredInfo153 = oneFiveThreeInfo.stream()
//        .filter(entry -> {
//          Long kurCd = (Long) entry.get("kur_cd");
//          return kurCdLists.contains(kurCd);
//        }).collect(Collectors.toList());
//      reportInfoForOutTempl.put(153L, filteredInfo153);
//    }
//    // add 11010 スケジュール表出力時の処理が不足している gjn end
//
//    // add #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen start
//    ReportXmlTotalTable totalTable = paramsInTempl.get(0).getReportXmlTotalTable();
//
//    String totalUnitV = totalTable.getUnitV();
//    String totalUnitDate = totalTable.getUnitDate();
//    String totalUnitH = totalTable.getUnitH();
//    String totalContents = totalTable.getContents();
//    String totalCountH = totalTable.getCountH();
//    String totalCountV = totalTable.getCountV();
//    String[][][] param1 = new String[2][][];
//    Map<String, String> param2 = new HashMap<>();
//    param2.put("totalUnitV", totalUnitV);
//    param2.put("totalUnitDate", totalUnitDate);
//    param2.put("totalUnitH", totalUnitH);
//    param2.put("totalContents", totalContents);
//    param2.put("totalCountH", totalCountH);
//    param2.put("totalCountV", totalCountV);
//    // add #11950 複数集計帳票の印刷で出力可能なページ数だが100ページ制限となり出力できない。 limingzhe start
//    param2.put("effectDateFlag", mstReport.getReportType() == 3 ? "1" : "0");
//    // add #11950 複数集計帳票の印刷で出力可能なページ数だが100ページ制限となり出力できない。 limingzhe end
//    // add #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen end
//    /**
//     * 縦の最大数と横の最大数、大きい表を確定して、横の縦の逆数は小さい表で、
//     * 大きい表を見ていくつの小さい表に転換することができて、転換の数は改ページ数です
//     */
//    int pageTotalNum;
//    // 改ページ
//    // add #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen start
//    ReportXmlTmplRepeat tmplRepeatAll = paramsInTempl.get(0).getReportXmlTmplRepeat();
//    String isNewPage = String.valueOf(tmplRepeatAll.getIsNewPage());
//    // add #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen end
//    // mod 10546 複数集計出力時にサーバが高負荷になる gjn start
//    // 横方向繰り返し数
//    Integer repeatCountH = paramsInTempl.get(0).getReportXmlTmplRepeat().getRepeatCountH();
//    // 縦方向繰り返し数
//    Integer repeatCountV = paramsInTempl.get(0).getReportXmlTmplRepeat().getRepeatCountV();
//    if ("1".equals(isNewPage)) {
//      Map<String, Object> inOfTemplateList = dataKeyInOfTemplateList.get(0);
//      // add 11010 スケジュール表出力時の処理が不足している gjn start
//      //String[][] drawDataGrid = infostrB(paramsInTempl, inOfTemplateList, paramsOutTempl, reportInfoForTempl, dataKeyOut);
//      String[][] drawDataGrid = calculateNumberOfPages(paramsInTempl, inOfTemplateList, reportInfoForOutTempl, param2, dataKeyOut);
//      // add 11010 スケジュール表出力時の処理が不足している gjn end
//      //todo 計算ページングに影響するため、集計の外部結合を計算する必要があります。(大きなテーブルで計算する)
//      // 横方向の最大数の計算
//      if (drawDataGrid != null && drawDataGrid.length > 0 && drawDataGrid[0] != null && drawDataGrid[0].length > 0) {
//        int largeWidth = drawDataGrid[0].length - TOTAL_COUNTS_OFFSET_2 + Integer.parseInt(totalCountV);
//        // 縦方向の最大数の計算
//        int largeHeight = drawDataGrid.length - TOTAL_COUNTS_OFFSET_2 + Integer.parseInt(totalCountH);
//        // 横方向繰り返し数
//        int smallWidth = repeatCountH;
//        // 縦方向繰り返し数
//        int smallHeight = repeatCountV;
//        pageTotalNum = calculateSmallTables(largeWidth, largeHeight, smallWidth, smallHeight);
//      } else {
//        pageTotalNum = 1;
//      }
//      // mod 10546 複数集計出力時にサーバが高負荷になる gjn end
//    } else {
//      // 改页しない，デフォルト1ページ
//      pageTotalNum = 1;
//    }
//    System.err.println("***********************************************");
//    System.err.println("ページング数の計算：" + pageTotalNum);
//    System.err.println("***********************************************");
//    // 最大ページ数判定
//    if (pageTotalNum > SET_MAX_PAGE) {
//      // 指定例外のスロー、メッセージの指定を促す
//      throw new NtssException("ExceedingMaxPageSetting," + pageTotalNum);
//    }
//
//    // add #10857 帳票内に同項目が複数あると設定値を取り違える limingzhe start
//    // mod #11009 カテゴリ「印刷情報」の優先対応 房 start
//    List<Map<String, Object>> rec = reportServiceImpl.getPrintedInfo(paramsOutTempl, dataKeyOut, reportInfoForOutTempl);
//    // mod #11009 カテゴリ「印刷情報」の優先対応 房 end
//    reportInfoForOutTempl.put(PRINT_INFO_CODE, rec);
//    paramsOutTempl = reportServiceImpl.paramsReplaceTmpValue(paramsOutTempl, reportInfoForOutTempl);
//    // add #10857 帳票内に同項目が複数あると設定値を取り違える limingzhe end
//    reportInfoForOutTempl = reportServiceImpl.getChangeList(reportInfoForOutTempl, paramsOutTempl);
//    // del #10857 帳票内に同項目が複数あると設定値を取り違える limingzhe start
////    int sqlCd = 0;
////    final String prtDt = "prt_dt";
////    final String login = "login";
////    final String kurl = "kurCdList";
////    final String bed = "bedCdListString";
////    final String freeWord = "freeWord";
////    final String treatDate = "treatDate";
////    final String expressCondCd = "expressCondCd";
////    final String medIds = "medIds";
////    final String eqIds = "eqIds";
////    final String period = "period";
////    final String kind = "kind";
////    final String weeks = "weeks";
////    final String stFromDate = ReportConstant.ReportDataKey.DATE_FROM;
////    final String stToDate = ReportConstant.ReportDataKey.DATE_TO;
//////    for (int i = 0; i < paramsOutTempl.size(); i++) {
//////      ReportXmlParam value = paramsOutTempl.get(i);
//////      if (value.getSqlCode().equals("") && (value.getDataCode().equals(prtDt) || value.getDataCode().equals(login) ||
//////        value.getDataCode().equals(kurl) || value.getDataCode().equals(bed) || value.getDataCode().equals(freeWord) || value.getDataCode().equals(treatDate) ||
//////        value.getDataCode().equals(expressCondCd) || value.getDataCode().equals(medIds) || value.getDataCode().equals(eqIds)
//////        || value.getDataCode().equals(period) || value.getDataCode().equals(kind) || value.getDataCode().equals(weeks)
//////        || value.getDataCode().equals(stFromDate) || value.getDataCode().equals(stToDate))
//////      ) {
//////        value = ReportXmlParam.of(value.getIsImage(), value.getRepeatAddress(), value.getId(), value.getDispType(), value.getDataCode(), value.getSqlCode(), value.getDataType(),
//////          value.getIsShrink(), value.getDispLength(), value.getFilterType(), value.getDispFormat(), value.getFormula(), value.getGroupId(),
//////          value.getIsInTmpl(), value.getIsNewPage(), value.getColWidth(), value.getRowHeight(),
//////          value.getRowCount(),
//////          value.getReportXmlFilters(), value.getReportXmlConvs(),
//////          value.getReportXmlGroup(), value.getReportXmlFormatConditions(), value.getFunction(), "",
//////          value.getReportXmlTmplRepeat(), value.getReportXmlTotalTable(), value.getParticular(), value.getReportXmlClassificationDataCodes());
//////        paramsOutTempl.set(i, value);
//////      }
//////    }
////    Map<String, Object> fieldValues = new HashMap<String, Object>();
////    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
////    fieldValues.put(prtDt, sdf.format(new Date()));
////    if (dataKeyOut.containsKey(login)) {
////      fieldValues.put(login, dataKeyOut.get(login));
////    }
////    if (dataKeyOut.containsKey(kurl)) {
////      fieldValues.put(kurl, dataKeyOut.get(kurl));
////    }
////    if (dataKeyOut.containsKey(bed)) {
////      fieldValues.put(bed, dataKeyOut.get(bed));
////    }
////    if (dataKeyOut.containsKey(freeWord)) {
////      fieldValues.put(freeWord, dataKeyOut.get(freeWord));
////    }
////    if (dataKeyOut.containsKey(treatDate)) {
////      fieldValues.put(treatDate, dataKeyOut.get(treatDate));
////    }
////    if (dataKeyOut.containsKey(expressCondCd)) {
////      fieldValues.put(expressCondCd, dataKeyOut.get(expressCondCd));
////    }
////    if (dataKeyOut.containsKey(medIds)) {
////      fieldValues.put(medIds, dataKeyOut.get(medIds));
////    }
////    if (dataKeyOut.containsKey(eqIds)) {
////      fieldValues.put(eqIds, dataKeyOut.get(eqIds));
////    }
////    if (dataKeyOut.containsKey(period)) {
////      fieldValues.put(period, dataKeyOut.get(period));
////    }
////    if (dataKeyOut.containsKey(kind)) {
////      fieldValues.put(kind, dataKeyOut.get(kind));
////    }
////    if (dataKeyOut.containsKey(weeks)) {
////      fieldValues.put(weeks, dataKeyOut.get(weeks));
////    }
////    if (dataKeyOut.containsKey(stFromDate)) {
////      fieldValues.put(stFromDate, dataKeyOut.get(stFromDate));
////    }
////    if (dataKeyOut.containsKey(stToDate)) {
////      fieldValues.put(stToDate, dataKeyOut.get(stToDate));
////    }
////    List<Map<String, Object>> rec;
////    final Long key = Long.valueOf(sqlCd);
////    if (reportInfoForOutTempl.containsKey(key)) {
////      rec = reportInfoForOutTempl.get(key);
////    } else {
////      rec = new ArrayList<Map<String, Object>>();
////    }
////    rec.add(fieldValues);
////    reportInfoForOutTempl.put(key, rec);
//    // del #10857 帳票内に同項目が複数あると設定値を取り違える limingzhe end
//    // オーダ番号をデータキーから取得.
//    Long ordNo = getOrdNoFromDataKey(dataKeyOutTempl);
//    // 帳票定義xmlを分解した結果からグラフIDを取得
//    Optional<String> graphId = getGraphId(paramsOutTempl);
//    Map<String, String> chartInfo = new HashMap<>();
//    // テンプレート外にグラフIDが埋め込まれている場合
//    // del #10633 【たくしん会】帳票のフォント問題 吉 start
////    if (graphId.isPresent()) {
////      // チャートを生成し、base64化する.
////      chartInfo = createChartImage(ordNo, graphId, dataKeyOutTempl, getColWidth, getRowHeight);
////    }
//    // del #10633 【たくしん会】帳票のフォント問題 吉 end
//    boolean doPatLastName = false;
//    for (int i = 0; i < paramsOutTempl.size(); i++) {
//      if ("pat_last_name".equals(paramsOutTempl.get(i).getDataCode())) {
//        doPatLastName = true;
//        break;
//      }
//    }
//    if (doPatLastName) {
//      for (List<Map<String, Object>> valueList : reportInfoForOutTempl.values()) {
//        for (int o = 0; o < valueList.size(); o++) {
//          if (valueList.get(o).containsKey("pat_last_name_id")) {
//            if ("".equals(valueList.get(o).get("patId")) && valueList.get(o).get("pat_last_name_id") == null) {
//              valueList.get(o).put("pat_last_name", "");
//            } else {
//              Long patId = Long.parseLong(valueList.get(o).get("patId").toString());
//              PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(patId);
//              valueList.get(o).put("pat_last_name", patPersonalMain.getPat_last_name());
//            }
//          }
//        }
//      }
//    }
//    Long sql_Cd = 0L;
//    for (ReportXmlParam xmlParam : paramsOutTempl) {
//      if (!StringUtils.isEmpty(totalUnitH) &&
//        // mod #11293 水質検査帳票の課題対応 limingzhe start
//        //(totalUnitH.indexOf(xmlParam.getDataCode()) >= 0 || totalUnitH.startsWith("##"))) {
//        ((totalUnitH.indexOf(xmlParam.getDataCode()) >= 0 && xmlParam.getSqlCode().length() > 0) || totalUnitH.startsWith("##"))) {
//        // mod #11293 水質検査帳票の課題対応 limingzhe end
//        sql_Cd = Long.parseLong(xmlParam.getSqlCode());
//        break;
//      }
//    }
//    for (Long outKey : reportInfoForOutTempl.keySet()) {
//      List<Map<String, Object>> valueList = reportInfoForOutTempl.get(sql_Cd);
//      if (outKey == sql_Cd && (valueList.size() == 0 || !StringUtils.isEmpty(valueList.get(0).get("ord_no")))) {
//        List<Map<String, Object>> tempdata = new ArrayList<>();
//        for (ReportXmlParam param : reportXmlParamsList) {
//          if (sql_Cd == 95L && ("rst_in_out_class".equals(param.getDataCode()) || "in_out_class".equals(param.getDataCode()))) {
//            List<Long> patIdList = (List<Long>) dataKeyOutTempl.get("patIds");
//            List<Map<String, Object>> tempdataNew = new ArrayList<>();
//            tempdataNew = sysDataSetService.getDataList(152L, dataKeyOutTempl);
//            for (int i = 0; i < patIdList.size(); i++) {
//              for (Map<String, Object> item : tempdataNew) {
//                if (!StringUtils.isEmpty(item.get("patId")) && patIdList.get(i).equals(item.get("patId"))) {
//                  tempdata.add(item);
//                }
//              }
//            }
//            reportInfoForOutTempl.put(sql_Cd, tempdata);
//          }
//        }
//        break;
//      }
//    }
//    reportInfoForTempl.putAll(reportInfoForOutTempl);
//    // regOrderClassList(透析前、透析後、その他)を追加します。
//    dataKeyOutTempl.put("regOrderClassList", dataKeyOut.get("regOrderClassList"));
//
//    // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen start
//    // Map<String, String> reportOutputInfoForOutTempl = convertDataCodeToIdForCount(paramsOutTempl, reportInfoForOutTempl, dataKeyOutTempl, mstReport, reportZipFile, pageCountMap);
//    // mod 10546 複数集計出力時にサーバが高負荷になる gjn start
//    Map<String, String> reportOutputInfoForOutTempl = convertDataCodeToIdForCount(paramsOutTempl, reportInfoForOutTempl, dataKeyOutTempl, mstReport, reportZipFile, pageCountMap, param2, isNewPage);
//    // mod 10546 複数集計出力時にサーバが高負荷になる gjn end
//    // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen end
//    // 計算式をもとに算出した結果を適用するidとclassのMapを作成する
//    final Map<String, String> calcResult = reportServiceImpl.getCalcResult(paramsOutTempl, reportInfoForOutTempl, reportOutputInfoForOutTempl);
//
//    // del 10546 複数集計出力時にサーバが高負荷になる gjn start
//    // 条件付き書式を適用するidとclassのMapを作成する
//    //Map<String, String> formatConditionInfo = createFormatConditionInfo(paramsOutTempl, reportOutputInfoForOutTempl, mstReport.getReportCd());
//    // del 10546 複数集計出力時にサーバが高負荷になる gjn end
//
//    // 縮小表示を適用するidとscaleのMapを作成する
//    // mod 10546 複数集計出力時にサーバが高負荷になる gjn start
//    //createResizeFontSizeInfoForCount(reportHtml, paramsOutTempl, reportOutputInfoForOutTempl, formatConditionInfo, reportXmlParamsList, mstReport, reportZipFile, pageCountMap);
//    // mod 10546 複数集計出力時にサーバが高負荷になる gjn end
//    // Excel関数がある場合、POIで実行した値を取得する
//    List<ReportXmlParam> functionParams = paramsOutTempl.stream().filter(e -> e.hasFunction()).collect(toList());
//    if (!functionParams.isEmpty()) {
//      // ApachePOIを使用して関数を実行
//      // mod #11260 テンプレート設定した帳票の出力で高負荷になることがある 房 start
////      try (Workbook wb = reportService.getReportExcelWorkbook(mstReport, reportZipFile, paramsOutTempl, reportOutputInfoForOutTempl, calcResult, ordNo, dataKeyOut, getColWidth, getRowHeight)) {
//      try{
//        // 式を評価する為の前準備
////        FormulaEvaluator evaluator = wb.getCreationHelper().createFormulaEvaluator();
//        com.aspose.cells.Workbook wb = reportWithAsposeApiService.getReportExcelWorkbook(mstReport, reportZipFile, paramsOutTempl, reportOutputInfoForOutTempl, calcResult, ordNo, dataKeyOut, getColWidth, getRowHeight);
//        for (int page = 1; ; page++) {
//          String prefix = String.format("%d%s", page, MULTIPLE_PAGES_SEPARATOR);
////          Sheet st = wb.getSheet(String.format("%s%d", SHEET_NAME_PREFIX, page));
//          Worksheet st = wb.getWorksheets().get(String.format("%s%d", SHEET_NAME_PREFIX, page));
//          if (st == null) {
//            break;
//          }
//          functionParams.forEach(param -> {
////            reportOutputInfoForOutTempl.put(
////              String.format("%s%s", prefix, param.getId()),
////              formatValue(param, ReportUtils.getFormulaResultValue(st, evaluator, param.getId())));
//            reportOutputInfoForOutTempl.put(
//              String.format("%s%s", prefix, param.getId()),
//              reportServiceImpl.formatValue(param, AsposeExcelUtil.getFormulaResultValue(st, param.getId())));
//          });
//        }
//      } catch (Exception e) {
//        EventLogMessage eventLogMessage = new EventLogMessage();
//        eventLogMessage.setLogMessage("帳票：関数処理に失敗しました。" + NtssUtils.ExcetionStackTraceToString(e));
//        eventLogMessage.setFacilityCd(mstReport.getFacilityCd());
//        logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
//      }
//      // mod #11260 テンプレート設定した帳票の出力で高負荷になることがある 房 end
//    }
//    // mod 10546 複数集計出力時にサーバが高負荷になる gjn start
//    if (repeatCountH > 1 && repeatCountV > 1) {
//      outPutHtml.putAll(reportOutputInfoForOutTempl);
//    }
//    // mod 10546 複数集計出力時にサーバが高負荷になる gjn end
//
//    // del 10546 複数集計出力時にサーバが高負荷になる gjn start
////    List<String> htmlList = getReflectReportHtmlForCount(
////      reportHtml,
////      reportOutputInfoForOutTempl,
////      calcResult,
////      formatConditionInfo,
////      chartInfo,
////      resizeFontSizeInfo,
////      reportXmlParamsList,
////      mstReport,
////      pageCountMap,
////      reportZipFile);
//    //return htmlList;
//    // del 10546 複数集計出力時にサーバが高負荷になる gjn
//  }
//
//  //add #10998「週間.医材」の出力内容修正 杜 start
//  public static List<Map<String, Object>> findMinTimeInHospitalForNonForeign(List<Map<String, Object>> list) {
//
//    Set<Object> idsSeen = new HashSet<>();
//    List<Map<String, Object>> result = new ArrayList<>();
//
//    for (int i = 0; i < list.size(); i++) {
//      if (list.get(i).containsKey("pat_id")) {
//        Object id = list.get(i).get("pat_id");
//        if ("入院".equals(list.get(i).get("move_in_out_name")) && idsSeen.add(id)) {
//            result.add(list.get(i));
//        }else if(result.size()!=0 && id.equals(list.get(i-1).get("pat_id")) && idsSeen.add(id) == false){
//          result.remove(list.get(i-1));
//          break;
//        }
//      }
//    }
//
//    return result;
//  }
//  public static void processList(List<Map<String, Object>> list) {
//    Object currentId = null;
//    boolean isInHospital = false;
//
//    for (int i = 0; i < list.size(); i++) {
//      Map<String, Object> map = list.get(i);
//      Object id = map.get("pat_id");
//      Object name = map.get("move_in_out_name");
//
//      if (id != null && !id.equals(currentId)) {
//        currentId = id;
//        isInHospital = false;
//      }
//
//      if ("入院".equals(name)) {
//        isInHospital = true;
//      } else if ("外来".equals(name)) {
//        isInHospital = false;
//      } else if (isInHospital && name == null) {
//        map.put("move_in_out_name", "入院");
//      }
//
//    }
//  }
//  //add #10998「週間.医材」の出力内容修正 杜 end
//
//  /**
//   * 切断できる表の数を計算する
//   *
//   * @param largeWidth
//   * @param largeHeight
//   * @param smallWidth
//   * @param smallHeight
//   * @return
//   */
//  public int calculateSmallTables(int largeWidth, int largeHeight, int smallWidth, int smallHeight) {
//    // 横方向と縦方向の表の数を計算する
//    int horizontalCount = (int) Math.ceil((double) largeWidth / smallWidth);
//    int verticalCount = (int) Math.ceil((double) largeHeight / smallHeight);
//    // 合計テーブル数の計算
//    return horizontalCount * verticalCount;
//  }
//
//  /**
//   * 帳票に出力する情報を取得します.
//   *
//   * @param params  Param要素情報
//   * @param dataKey データ抽出キー
//   * @return 帳票出力情報
//   */
//  private Map<Long, List<Map<String, Object>>> getReportInfo(List<ReportXmlParam> params, Map<String, Object> dataKey) {
//    // SqlCodeをもとに帳票に出力する情報を取得する
//    List<String> sqlCodes = getSqlCode(params);
//    // 患者イベント 画像
//    if (sqlCodes.contains("86")) {
//      if (dataKey.containsKey(ReportConstant.ReportDataKey.DATE_FROM)) {
//        dataKey.put("imageDateFrom", dateStr2dispDateStr(String.valueOf(dataKey.get(ReportConstant.ReportDataKey.DATE_FROM))));
//      }
//      if (!dataKey.containsKey(ReportConstant.ReportDataKey.DATE_TO)) {
//        if (dataKey.containsKey(ReportConstant.ReportDataKey.DATE_FROM)) {
//          dataKey.put("imageDateTo", dateStr2dispDateStr(String.valueOf(dataKey.get(ReportConstant.ReportDataKey.DATE_FROM))));
//        }
//      } else if (StringUtils.isEmpty(dataKey.get(ReportConstant.ReportDataKey.DATE_TO))) {
//        if (dataKey.containsKey(ReportConstant.ReportDataKey.DATE_FROM)) {
//          dataKey.put("imageDateTo", dateStr2dispDateStr(String.valueOf(dataKey.get(ReportConstant.ReportDataKey.DATE_FROM))));
//        } else {
//          dataKey.put("imageDateTo", dateStr2dispDateStr(String.valueOf(dataKey.get(ReportConstant.ReportDataKey.DATE_TO))));
//        }
//      } else {
//        dataKey.put("imageDateTo", dateStr2dispDateStr(String.valueOf(dataKey.get(ReportConstant.ReportDataKey.DATE_TO))));
//      }
//    }
//    if (sqlCodes.contains("16") || sqlCodes.contains(159)) {
//      dataKey.remove("patId");
//    }
//    if (sqlCodes.contains("115") || sqlCodes.contains("116")) {
//      if (!dataKey.containsKey("ordNo")) {
//        dataKey.put("ordNo", dataKey.get("ordNos"));
//      }
//    }
//    Map<Long, List<Map<String, Object>>> finalReslut = new ConcurrentHashMap<>(sqlCodes.size());
//    // Async Result Container
//    Map<Long, CompletableFuture<List<Map<String, Object>>>> completableFutureMap =
//      new ConcurrentHashMap<>(sqlCodes.size());
//    // Maybe we should limit the length of the loop body
//    for (String sqlCode : sqlCodes) {
//      Long sqlKey = Long.parseLong(sqlCode);
//      completableFutureMap.put(sqlKey, CompletableFuture.supplyAsync(
//        () -> {
//          try {
//            // Call async method, place asynchronous results in the Async Result Container.
//            return sysDataSetService.getDataListAsync(sqlKey, dataKey, null).get();
//          } catch (InterruptedException e) {
//            Thread.currentThread().interrupt();
//          } catch (ExecutionException e) {
//            throw new RuntimeException(e);
//          }
//          return null;
//        }
//      ));
//    }
//    // Block all asynchronous threads to complete execution
//    CompletableFuture.allOf(completableFutureMap.values().toArray(new CompletableFuture[0])).join();
//    // Rebuild this result.
//    completableFutureMap.forEach((key, value) -> {
//      try {
//        finalReslut.put(key, value.get());
//      } catch (InterruptedException e) {
//        Thread.currentThread().interrupt();
//      } catch (ExecutionException e) {
//        throw new RuntimeException(e);
//      }
//    });
//    return finalReslut;
//  }
//
//
//  /**
//   * Param要素情報からsqlCodeの値を取得します.
//   *
//   * @param params Param要素情報
//   * @return SQLCODEのリスト
//   */
//  private List<String> getSqlCode(List<ReportXmlParam> params) {
//    // sqlCodeの値を取得する
//    List<String> sqlCodes = params.stream()
//      .filter(p -> !StringUtils.isEmpty(p.getSqlCode()))
//      .map(p -> p.getSqlCode())
//      .collect(Collectors.toList());
//    // formula属性に設定されているsqlCodeを取得する
//    List<String> tmpList = new ArrayList<>();
//    params.stream()
//      .filter(p -> p.isFormulaToCalc())
//      .forEach(p -> tmpList.addAll(getSqlCodeAndDataCodes(p.getFormula())));
//    tmpList.stream().forEach(t -> {
//      String[] tmps = t.split(Pattern.quote("."));
//      if (tmps.length == 2) {
//        sqlCodes.add(tmps[0]);
//      }
//    });
//    // 重複は除外する
//    return sqlCodes.stream().distinct().collect(toList());
//  }
//
//  /**
//   * yyyyMMdd -> yyyy/MM/dd
//   *
//   * @param yyyymmdd
//   * @return
//   */
//  private String dateStr2dispDateStr(String yyyymmdd) {
//    if (yyyymmdd.length() == 8) {
//      String year = yyyymmdd.substring(0, 4);
//      String month = yyyymmdd.substring(4, 6);
//      String day = yyyymmdd.substring(6);
//      String treatDateFormatted = year + "/" + month + "/" + day;
//      return treatDateFormatted;
//    } else {
//      return yyyymmdd;
//    }
//  }
//
//
//  /**
//   * データキーからオーダ番号を取得する.
//   * データキーにオーダ番号が存在しない場合は、「0」を返却する.
//   *
//   * @param dataKey データキー
//   * @return オーダ番号
//   */
//  private Long getOrdNoFromDataKey(Map<String, Object> dataKey) {
//    // マップから取り出したオーダ番号を格納する変数.
//    Long ordNo = 0L;
//    // データキーにオーダ番号がない場合
//    if (!dataKey.containsKey(ReportConstant.ReportDataKey.ORD_NO)) {
//      return ordNo;
//    }
//    // オーダ番号を取得.
//    Object objOrdNo = dataKey.get(ReportConstant.ReportDataKey.ORD_NO);
//    // 本来はLong型を期待しているが、Integer型で設定された場合は、
//    // Integer型からLong型に変換する.
//    if (objOrdNo instanceof Integer) {
//      ordNo = ((Integer) objOrdNo).longValue();
//    } else if (objOrdNo instanceof Long) {
//      ordNo = (Long) objOrdNo;
//    }
//    return ordNo;
//  }
//
//  /**
//   * グラフ項目のIDを取得します.
//   *
//   * @param params Param要素情報
//   * @return グラフ項目のID
//   */
//  private Optional<String> getGraphId(List<ReportXmlParam> params) {
//    return params.stream()
//      .filter(e -> e.getGroupId().indexOf("グラフ") >= 0)
//      .map(e -> e.getId())
//      .findFirst();
//  }
//
//
//  /**
//   * チャートイメージを作成し、base64に変換する.
//   *
//   * @param ordNo   オーダ番号
//   * @param graphId グラフID
//   * @param dataKey データキー
//   * @return 作成したグラフIDをキーとし、チャートイメージをBase64化した文字列のマップ
//   */
//  // del #10633 【たくしん会】帳票のフォント問題 吉 start
////  private Map<String, String> createChartImage(Long ordNo, Optional<String> graphId, Map<String, Object> dataKey, String getColWidth, String getRowHeight) {
////    // チャート画像のデータを格納する変数.
////    Map<String, String> chartInfo = new HashMap<>();
////    // チャート画像を取得
////    List<byte[]> imageData = createChartImageResByte(ordNo, dataKey, getColWidth, getRowHeight);
////    chartInfo = imageData.stream()
////      .collect(toMap(
////        e -> String.format("%d%s%s-1", imageData.indexOf(e) + 1, MULTIPLE_PAGES_SEPARATOR, graphId.get()),
////        e -> Base64.getEncoder().encodeToString(e)
////      ));
////    return chartInfo;
////  }
//// del #10633 【たくしん会】帳票のフォント問題 吉 end
//
//  /**
//   * チャートイメージを作成し、バイト列で返す.
//   *
//   * @param ordNo   オーダ番号
//   * @param dataKey データキー
//   * @return チャートイメージのバイト列
//   */
//  // del #10633 【たくしん会】帳票のフォント問題 吉 start
////  private List<byte[]> createChartImageResByte(Long ordNo, Map<String, Object> dataKey, String getColWidth, String getRowHeight) {
////    List<byte[]> imageData = new LinkedList<>();
////    // 0 table Height    1 highchars  Height  2 width
////    List<Integer> countSize = reportChartService.getTableHeight(ordNo, ReportChartService.ChartImageType.PNG, getColWidth, getRowHeight);
////    int countWidth = 0;
////    int tableHeight = 0;
////    int charHeight = 0;
////    int countHeight = 0;
////    if (null != countSize && countSize.size() > 0) {
////      if (countSize.size() > 2) {
////        countWidth = countSize.get(2);
////        tableHeight = countSize.get(0);
////        charHeight = countSize.get(1);
////      } else {
////        countWidth = countSize.get(0);
////        countHeight = countSize.get(1);
////      }
////    }
////    // モニタ項目Grid取得
////    List<byte[]> monitorGridImageData = new ArrayList<>();
////    if (null != countSize && countSize.size() > 0) {
////      monitorGridImageData = reportChartService.getMonitorGridData(ordNo,
////        ReportChartService.ChartImageType.PNG, countWidth, tableHeight, dataKey.get("facilityCd").toString());
////    }
////    if (null != countSize && countSize.size() == 2) {
////      try {
////        if (null != monitorGridImageData && monitorGridImageData.size() > 0) {
////          InputStream in = new ByteArrayInputStream(monitorGridImageData.get(0));
////          BufferedImage bimage = ImageIO.read(in);
////          tableHeight = bimage.getHeight();
////          charHeight = countHeight - tableHeight;
////        }
////      } catch (IOException e) {
////        throw new NtssException("帳票のモニタデータの画像ファイルの出力に失敗しました。");
////      }
////    }
////    if (null == countSize || countSize.size() == 0) {
////      countWidth = Integer.valueOf(getColWidth);
////      charHeight = Integer.valueOf(getRowHeight);
////    }
////    // グラフの生成
////    List<byte[]> chartData = dataKey.containsKey(ReportConstant.ReportDataKey.BVMS_CHART_DATA)
////      ? (List<byte[]>) dataKey.get(ReportConstant.ReportDataKey.BVMS_CHART_DATA)
////      : reportChartService.getVitalChartData(ordNo, ReportChartService.ChartImageType.PNG,
////      countWidth, charHeight, dataKey.get("facilityCd").toString(), dataKey.get("highchatIsNewPage").toString());
////    if (chartData != null && monitorGridImageData != null) {
////      // バイタル画像の復元
////      for (int index = 0; index < chartData.size(); index++) {
////        byte[] vitalChart = chartData.get(index);
////        byte[] gridImageData = null;
////        if (index < monitorGridImageData.size()) {
////          gridImageData = monitorGridImageData.get(index);
////        }
////        try {
////          BufferedImage vitalImage = ImageIO.read(new ByteArrayInputStream(vitalChart));
////          BufferedImage gridImage = null;
////          if (gridImageData != null) {
////            gridImage = ImageIO.read(new ByteArrayInputStream(gridImageData));
////          }
////          // 画像ファイルの横幅
////          int iw = vitalImage.getWidth();
////          // 画像ファイルの縦幅
////          int ih = vitalImage.getHeight() + (gridImage == null ? 0 : gridImage.getHeight());
////          BufferedImage img = new BufferedImage(iw, ih, BufferedImage.TYPE_INT_ARGB);
////          Graphics graphics = img.getGraphics();
////          // バイタル画像を追加
////          graphics.drawImage(vitalImage, 0, 0, null);
////          // モニタ
////          int count = reportChartService.getVitalChartDataLen(ordNo);
////          if (gridImage != null) {
////            int removeIw = 0;
////            if (count == 6 && count < 4) {
////              removeIw = 7;
////            } else if (count == 5) {
////              removeIw = 4;
////            } else {
////              removeIw = 5;
////            }
////            graphics.drawImage(gridImage, 0, vitalImage.getHeight() - 7, iw - removeIw, gridImage.getHeight(), null);
////          }
////          Path imagePath = tmpFileService.createTmpDirectoryAndFile(createTmpDir, "nkk-report-image", ".png");
////          if (ImageIO.write(img, "png", imagePath.toFile())) {
////            byte[] imageByteArray = Files.readAllBytes(imagePath);
////            // ファイルを削除
////            imagePath.toFile().delete();
////            imageData.add(imageByteArray);
////          }
////        } catch (IOException e) {
////          e.printStackTrace();
////        } catch (Exception e) {
////          e.printStackTrace();
////        }
////      }
////    } else if (chartData != null) {
////      // モニタ項目Grid画像が存在せず、グラフ画像だけの場合は、グラフ画像のみ返す
////      imageData = chartData;
////    }
////    return imageData;
////  }
//  // del #10633 【たくしん会】帳票のフォント問題 吉 del
//  /**
//   * 日付型のフォーマット処理
//   *
//   * @param value
//   * @return
//   */
//  public static String DateFormat(String value) {
//    value = value.replaceAll("[^0-9]", "");
//    if (value.length() > 8) {
//      value = value.substring(0, 8);
//    }
//    return value;
//  }
//
//  /**
//   * 日付型の判定処理
//   *
//   * @param value
//   * @return
//   */
////  public static boolean isDate(String value) {
////    SimpleDateFormat sdf = null;
////    ParsePosition pos = new ParsePosition(0);
////    if (value == null) {
////      return false;
////    }
////    try {
////      value = value.replaceAll("[^0-9]", "");
////      if (value.length() > 8) {
////        value = value.substring(0, 8);
////      }
////      sdf = new SimpleDateFormat("yyyyMMdd");
////      sdf.setLenient(false);
////      Date date = sdf.parse(value, pos);
////      if (date == null) {
////        return false;
////      } else {
////        if (pos.getIndex() > sdf.format(date).length()) {
////          return false;
////        }
////        return true;
////      }
////    } catch (Exception e) {
////      e.printStackTrace();
////      return false;
////    }
////  }
//  public static boolean isDate(String value) {
//    if (value == null || value.isEmpty()) {
//      return false;
//    }
//    // Use ThreadLocal to reuse SimpleDateFormat safely
//    ThreadLocal<SimpleDateFormat> threadLocalSdf = ThreadLocal.withInitial(() -> {
//      SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
//      sdf.setLenient(false);
//      return sdf;
//    });
//    try {
//      // Remove non-digit characters
//      String cleanedValue = value.replaceAll("\\D", "");
//
//      // Truncate to first 8 characters
//      if (cleanedValue.length() > 8) {
//        cleanedValue = cleanedValue.substring(0, 8);
//      }
//      // Parse the date
//      ParsePosition pos = new ParsePosition(0);
//      Date date = threadLocalSdf.get().parse(cleanedValue, pos);
//      // Check parsed date validity
//      if (date == null || pos.getIndex() != cleanedValue.length()) {
//        return false;
//      }
//      return true;
//    } catch (Exception e) {
//      // Handle specific exceptions if needed, avoid printing stack trace in production
//      e.printStackTrace();
//      return false;
//    }
//  }
//
//
//  /**
//   * 表示配列のインデックス取得
//   *
//   * @param strDataType
//   * @return
//   */
//  // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen start
//  // private int totalUnitindex(String strDataType) {
//  private int totalUnitindex(String strDataType, String[][][] arrtotalUnit) {
//    String[][] arrtotalUnitV = arrtotalUnit[0];
//    String[][] arrtotalUnitH = arrtotalUnit[1];
//    // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen end
//    int index = -1;
//    for (int n = 0; n < arrtotalUnitV.length; n++) {
//      if (arrtotalUnitV[n][0].equals(strDataType)) {
//        index = n;
//      }
//    }
//    for (int n = 0; n < arrtotalUnitH.length; n++) {
//      if (arrtotalUnitH[n][0].equals(strDataType)) {
//        index = n;
//      }
//    }
//    return index;
//  }
//
//
//  //  public static String formatDouble(double d) {
////    BigDecimal bg = new BigDecimal(d);
////    double num = bg.doubleValue();
////    if (Math.round(num) - num == 0) {
////      return String.valueOf((long) num);
////    }
////    return String.valueOf(num);
////  }
//  public static String formatDouble(double d) {
//    BigDecimal bg = BigDecimal.valueOf(d);
//    if (bg.scale() <= 0) {
//      return String.valueOf(bg.longValue());  // If the BigDecimal is effectively an integer, return as long
//    } else {
//      return String.valueOf(bg.stripTrailingZeros());  // Otherwise, return with trailing zeros removed
//    }
//  }
//
//  //  public static String formatBigDecimal(String strS, String strE) {
////    if (strS.isEmpty()) {
////      strS = "0";
////    }
////    if (strE.isEmpty()) {
////      strE = "0";
////    }
////    BigDecimal bgS = new BigDecimal(strS);
////    BigDecimal bgE = new BigDecimal(strE);
////    return String.valueOf(bgS.add(bgE));
////  }
//  public static String formatBigDecimal(String strS, String strE) {
//    // Handling null values or empty strings by defaulting to "0"
//    BigDecimal bgS = new BigDecimal(strS.isEmpty() ? "0" : strS);
//    BigDecimal bgE = new BigDecimal(strE.isEmpty() ? "0" : strE);
//    // Performing the addition directly and returning the result as a string
//    return bgS.add(bgE).toString();
//  }
//
//  /**
//   * 曜日取得
//   *
//   * @param datetime
//   * @return
//   */
//  public static String dateToWeek(String datetime) {
//    if (!isDate(datetime)) {
//      return datetime;
//    }
//    datetime = datetime.replace("-", "").replace("/", "");
//    SimpleDateFormat f = new SimpleDateFormat("yyyyMMdd");
//    String[] weekDays = {"日", "月", "火", "水", "木", "金", "土"};
//    Calendar cal = Calendar.getInstance();
//    Date date;
//    try {
//      date = f.parse(datetime);
//      cal.setTime(date);
//    } catch (ParseException e) {
//      e.printStackTrace();
//    }
//    int w = cal.get(Calendar.DAY_OF_WEEK) - 1;
//    if (w < 0)
//      w = 0;
//    return weekDays[w];
//  }
//
//  // mod 10546 複数集計出力時にサーバが高負荷になる gjn start
//  private void cerateReport(
//    //String html,
//    List<String[][]> strBList,
//    List<ReportXmlParam> reportXmlParamsList,
//    MstReport mstReport,
//    ReportZipFile reportZipFile,
//    Map<String, String> outPutHtml,
//    //boolean isUseAsposeCells,
//    // mod 10546 複数集計出力時にサーバが高負荷になる gjn end
//    // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen start
//    // Map<String, Integer> pageCountMap) {
//    Map<String, Integer> pageCountMap,
//    String[][][] param1,
//    Map<String, String> param2) {
//
//    String totalCountV = param2.get("totalCountV");
//    // mod 10989 集計機能の合計出力仕様の変更（複数集計）gjn start
//    String totalCountH = param2.get("totalCountH");
//    // mod 10989 集計機能の合計出力仕様の変更（複数集計）gjn end
//    String[][] arrtotalUnitH = param1[0];
//    String[][] arrtotalUnitV = param1[1];
//    // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen end
//    int pageTotal = pageCountMap.get("COUNT_PAGE");
//    int pageTotalV = pageCountMap.get("COUNT_PAGE_LINE");
//    int pageTotalH = pageCountMap.get("COUNT_PAGE_ROW");
//    int rowMax = 1;
//    int lineMax = 1;
//    Map<String, String> idLst = new HashMap<>();
//    Workbook wb = getReportWorkbook(mstReport, reportZipFile);
//    Sheet baseSt = wb.getSheet("設定");
//    String reportH = baseSt.getRow(30).getCell(0).toString().split(",")[0];
//    String reportV = baseSt.getRow(31).getCell(0).toString().split(",")[0];
//    String direction = baseSt.getRow(18).getCell(0).toString().split(",")[0];
//    for (ReportXmlParam report : reportXmlParamsList) {
//      ReportXmlGroup group = report.getReportXmlGroup();
//      if (group == null) {
//        if (report.getReportXmlTmplRepeat() != null &&
//          report.getId().equals(report.getReportXmlTmplRepeat().getId()) && "1".equals(report.getIsInTmpl())) {
//          idLst.put("REPORT_VALUE", report.getId());
//        }
//        continue;
//      }
//      if (reportH.equals(report.getDataCode()) && "0".equals(report.getIsInTmpl())) {
//        rowMax = report.getReportXmlGroup().getRepeatMax();
//        idLst.put(reportH, report.getId());
//      } else if (reportV.equals(report.getDataCode()) && "0".equals(report.getIsInTmpl())) {
//        lineMax = report.getReportXmlGroup().getRepeatMax();
//        idLst.put(reportV, report.getId());
//      } else if (group.getRepeatMax().equals(1) && "1".equals(report.getIsInTmpl())) {
//        idLst.put("REPORT_VALUE", report.getId());
//      }
//      if (reportV.startsWith("##")) {
//        lineMax = baseSt.getRow(31).getCell(0).toString().split(",").length;
//      }
//      if (reportH.startsWith("##")) {
//        rowMax = baseSt.getRow(30).getCell(0).toString().split(",").length;
//      }
//      if (arrtotalUnitH.length > 1) {
//        for (int i = 0; i < arrtotalUnitH.length; i++) {
//          if (arrtotalUnitH[i][0].equals(report.getDataCode())) {
//            idLst.put(arrtotalUnitH[i][0], report.getId());
//          }
//        }
//      }
//      if (arrtotalUnitV.length > 1) {
//        for (int i = 0; i < arrtotalUnitV.length; i++) {
//          if (arrtotalUnitV[i][0].equals(report.getDataCode())) {
//            idLst.put(arrtotalUnitV[i][0], report.getId());
//          }
//        }
//      }
//    }
//    // del 10546 複数集計出力時にサーバが高負荷になる gjn start
////    if (strBList.size() == 0) {
////      // 帳票デザインHTMLをパースする
////      org.jsoup.nodes.Document document = Jsoup.parse(html);
////      org.jsoup.nodes.Element baseElement = document.getElementsByTag("body").first();
////      outPutHtml.entrySet().stream()
////        .forEach(r ->
////          Optional.ofNullable(
////            baseElement.getElementById(r.getKey())).ifPresent(e -> {
////            if (e.children().size() == 0) {
////              e.text(r.getValue());
////            } else {
////              e.children().get(0).text(r.getValue());
////            }
////          }));
////      return document.html();
////    }
//    // mod 10546 複数集計出力時にサーバが高負荷になる gjn end
//    String[] tatleH = new String[strBList.get(0)[0].length - 1];
//    String[] tatleV = new String[strBList.get(0).length - 1];
//
//    for (int i = 0; i < tatleH.length; i++) {
//      if (!"0".equals(strBList.get(0)[0][i + 1])) {
//        tatleH[i] = strBList.get(0)[0][i + 1];
//      } else {
//        if (TOTAL_COUNTS_DISPLAY_N.equals(totalCountV)) {
//          tatleH[i] = "";
//        } else {
//          tatleH[i] = "合　計";
//        }
//        if (reportXmlParamsList.get(0).getSqlCode().equals("197")) {
//          tatleH[i] = "";
//        }
//      }
//    }
//    for (int i = 0; i < tatleV.length; i++) {
//      if (!"0".equals(strBList.get(0)[i + 1][0])) {
//        tatleV[i] = strBList.get(0)[i + 1][0];
//      } else {
//        tatleV[i] = "";
//      }
//    }
////    boolean countFlgH = false;
////    for (int i = 1; i < strBList.get(0)[0].length - 1; i++) {
////      if ("".equals(strBList.get(0)[strBList.get(0).length - 1][i])) {
////        countFlgH = true;
////      }
////      if (countFlgH) {
////        strBList.get(0)[strBList.get(0).length - 1][strBList.get(0)[0].length - 1] = "";
////        break;
////      }
////    }
////    boolean countFlgV = false;
////    for (int i = 1; i < strBList.get(0).length - 1; i++) {
////      if ("".equals(strBList.get(0)[i][strBList.get(0)[i].length - 1])) {
////        countFlgV = true;
////      }
////      if (countFlgV) {
////        strBList.get(0)[strBList.get(0).length - 1][0] = "";
////        break;
////      }
////    }
//    System.err.println("===================================================================");
//    System.err.println("  今回の改ページ総数：" + pageTotal);
//    System.err.println("===================================================================");
//
//    // add 10989 集計機能の合計出力仕様の変更（複数集計） gjn start
//    ReportXmlParam reportXmlParamIn = reportXmlParamsList.stream().filter(f -> ("1".equals(f.getIsInTmpl()))).collect(toList()).get(0);
//    final String inTempFormat = reportXmlParamIn.getDispFormat();
//    // add 10989 集計機能の合計出力仕様の変更（複数集計） gjn end
//
//    int pageH = 0;
//    int pageV = 0;
//    // add 10546 複数集計出力時にサーバが高負荷になる gjn start
//    Integer repeatCountH = reportXmlParamIn.getReportXmlTmplRepeat().getRepeatCountH();
//    Integer repeatCountV = reportXmlParamIn.getReportXmlTmplRepeat().getRepeatCountV();
//    // add 10546 複数集計出力時にサーバが高負荷になる gjn end
//    for (int page = 1; page <= pageTotal; page++) {
//      // mod 10989 集計機能の合計出力仕様の変更（複数集計）gjn start
//      int totalIsOkV = 0;
//      int totalIsOkH = 0;
//      int hengTotatlFalg = 1;
//      int count = 1;
//      int repeatAddressHNum = 0;
//      // 横縦集合計外の合計に標識が存在するかどうか
//      boolean isHV = false;
//      if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH) && TOTAL_COUNTS_DISPLAY_Y.equals(totalCountV)) {
//        isHV = true;
//      }
//      // 横方向操作の逆隣接セル位置の取得
//      String dataCodeV = reportV;
//      String[] repeatAddressV = reportXmlParamsList.stream()
//        .filter(f -> dataCodeV.equals(f.getDataCode())).distinct().collect(toList())
//        .get(0).getRepeatAddress().split(",");
//      String end = repeatAddressV[repeatAddressV.length-1];
//      String endEnd = end.contains(":") ? end.split(":")[0] : end;
//      String maxNumV = endEnd.replaceAll("\\D+", "");
//      // 縦合計開始点（合計位置）
//      String outExcelIndexH = end.replaceAll("\\d+", String.valueOf(Integer.parseInt(maxNumV)+1));
//      // 縦方向操作で隣接するセルの位置を取得するには
//      String dataCodeH = reportH;
//      String[] repeatAddressH = reportXmlParamsList.stream()
//        .filter(f -> dataCodeH.equals(f.getDataCode())).distinct().collect(toList())
//        .get(0).getRepeatAddress().split(",");
//
//      String num = getNextHorizontalCell(repeatAddressH[repeatAddressH.length-1]).replaceAll("\\D+", "");
//      String strV = getNextHorizontalCell(repeatAddressH[repeatAddressH.length-1]).replaceAll("\\d+", "");
//      // 横合計開始点（合計位置）
//      String outExcelIndex = strV + num;
//      // 横合計の最初の開始座標点を取得する
//      String minH  = repeatAddressV[0].contains(":") ? repeatAddressV[0].split(":")[0] : repeatAddressV[0];
//      String minNum = minH.replaceAll("\\D+", "");
//      String outExcelIndexV = strV + minNum;
//
//      // 横縦集合の計外合計の合計の座標位置を計算する
//      String totalSumIndex = strV +  (Integer.parseInt(maxNumV)+1);
//
//      String value = "";
//      String key = "";
//      // 縦合計の判定
//      if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH) && (strBList.get(0).length-2) % lineMax == 0) {
//        totalIsOkH = 1;
//      }
//      if ("N".equals(direction)) { //TODO N型改ページ
//        if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountV) && (strBList.get(0)[0].length-2) % rowMax == 0) {  //todo N形改ページ倍数系
//          totalIsOkV = 1;
//          for (int h = 1 + (pageH * rowMax); h <= rowMax * (pageH + 1) + totalIsOkV; h++) {
//            for (int v = 1 + (pageV * lineMax); v <= lineMax * (pageV + 1); v++) {
//              if (h > tatleH.length || v > tatleV.length) {
//                value = "";
//              } else {
//                value = strBList.get(0)[v][h];
//              }
//              if (strBList.get(0)[0].length - 1 == h && TOTAL_COUNTS_DISPLAY_Y.equals(totalCountV)) {
//                if (v == strBList.get(0).length - 1 && h == strBList.get(0)[v].length - 1) {
//                  value = "";
//                }
//                if (hengTotatlFalg == 1) {
//                  key = String.format("%d#%s-%d", page, outExcelIndexV, 1);
//                  hengTotatlFalg++;
//                } else {
//                  String nextRowRangeV = getNextRowRange(outExcelIndexV);
//                  key = String.format("%d#%s-%d", page, nextRowRangeV, 1);
//                  outExcelIndexV = nextRowRangeV;
//                }
//                value = totalNumFormat(inTempFormat, value);
//                // カウント外合計であると判定された行はcount++論理を実行しない
//                if (h < rowMax * (pageH + 1) + totalIsOkV) {
//                  count++;
//                }
//              } else if (strBList.get(0).length - 1 == v && h <= strBList.get(0)[v].length - 1
//                && TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                if (repeatAddressHNum < repeatAddressH.length) {
//                  String nextRowRangeH = repeatAddressH[repeatAddressHNum].replaceAll("\\d+", String.valueOf(Integer.parseInt(maxNumV) + 1));
//                  key = String.format("%d#%s-%d", page, nextRowRangeH, 1);
//                  repeatAddressHNum++;
//                  // 縦合計時空間値にデフォルトで0を割り当てる
//                  if (StringUtils.isEmpty(value)) {
//                    value = "0";
//                  }
//                  value = totalNumFormat(inTempFormat, value);
//                  // 最後の値が合計であると判断し、集計に表示されるべきではありません
//                  if (v == strBList.get(0).length-1 && h == strBList.get(0)[v].length-1) {
//                    value = "";
//                  }
//                  // カウント外合計であると判定された行はcount++論理を実行しない
//                  if (h < rowMax * (pageH + 1) + totalIsOkV) {
//                    count++;
//                  }
//                } else {
//                  continue;
//                }
//              } else {
//                key = String.format("%d#%s-%d.%s-1", page, idLst.get("REPORT_VALUE"), count++, idLst.get("REPORT_VALUE"));
//              }
//              outPutHtml.put(key, value);
//            }
//          }
//        } else { //todo N字改ページ正常系
//          for (int h = 1 + (pageH * rowMax); h <= rowMax * (pageH + 1); h++) {
//            for (int v = 1 + (pageV * lineMax); v <= lineMax * (pageV + 1); v++) {
//              if (h > tatleH.length || v > tatleV.length) {
//                value = "";
//              } else {
//                value = strBList.get(0)[v][h];
//              }
//              if (strBList.get(0)[0].length - 1 == h && TOTAL_COUNTS_DISPLAY_Y.equals(totalCountV)) {
//                if (v == strBList.get(0).length - 1 && h == strBList.get(0)[v].length - 1) {
//                  value = "";
//                }
//                if (hengTotatlFalg == 1) {
//                  key = String.format("%d#%s-%d", page, outExcelIndexV, 1);
//                  hengTotatlFalg++;
//                } else {
//                  String nextRowRangeV = getNextRowRange(outExcelIndexV);
//                  key = String.format("%d#%s-%d", page, nextRowRangeV, 1);
//                  outExcelIndexV = nextRowRangeV;
//                }
//                value = totalNumFormat(inTempFormat, value);
//                count++;
//              } else if (strBList.get(0).length - 1 == v && h <= strBList.get(0)[v].length - 1
//                && TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                if (repeatAddressHNum < repeatAddressH.length) {
//                  String nextRowRangeH = repeatAddressH[repeatAddressHNum].replaceAll("\\d+", String.valueOf(Integer.parseInt(maxNumV) + 1));
//                  key = String.format("%d#%s-%d", page, nextRowRangeH, 1);
//                  repeatAddressHNum++;
//                  // 縦合計時空間値にデフォルトで0を割り当てる
//                  if (StringUtils.isEmpty(value)) {
//                    value = "0";
//                  }
//                  value = totalNumFormat(inTempFormat, value);
//                  // 最後の値が合計であると判断し、集計に表示されるべきではありません
//                  if (v == strBList.get(0).length-1 && h == strBList.get(0)[v].length-1) {
//                    value = "";
//                  }
//                  count++;
//                } else {
//                  continue;
//                }
//              } else {
//                // 最後の値が合計であると判断し、集計に表示されるべきではありません
//                if (v == strBList.get(0).length-1 && h == strBList.get(0)[v].length-1) {
//                  value = "";
//                }
//                key = String.format("%d#%s-%d.%s-1", page, idLst.get("REPORT_VALUE"), count++, idLst.get("REPORT_VALUE"));
//              }
//              outPutHtml.put(key, value);
//            }
//          }
//        }
//        //todo N型->縦合計が表示であり、縦表示数と縦操作逆数が幾何倍である場合は、縦合計表示を強制する必要がある
//        if (totalIsOkH == 1) {
//          for (int h = 1 + (pageH * rowMax); h <= rowMax * (pageH + 1); h++) {
//            for (int v = 1 + (pageV * lineMax); v <= lineMax * (pageV + 1) + totalIsOkH; v++) {
//              if (h > tatleH.length || v > tatleV.length) {
//                value = "";
//              } else {
//                value = strBList.get(0)[v][h];
//              }
//              if (strBList.get(0).length - 1 == v && h <= strBList.get(0)[v].length - 1
//                && TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                if (repeatAddressHNum < repeatAddressH.length) {
//                  String nextRowRangeH = repeatAddressH[repeatAddressHNum].replaceAll("\\d+", String.valueOf(Integer.parseInt(maxNumV) + 1));
//                  key = String.format("%d#%s-%d", page, nextRowRangeH, 1);
//                  repeatAddressHNum++;
//                  // 縦合計時空間値にデフォルトで0を割り当てる
//                  if (StringUtils.isEmpty(value)) {
//                    value = "0";
//                  }
//                  value = totalNumFormat(inTempFormat, value);
//                  // 最後の値が合計であると判断し、集計に表示されるべきではありません
//                  if (v == strBList.get(0).length-1 && h == strBList.get(0)[v].length-1) {
//                    value = "";
//                  }
//                  outPutHtml.put(key, value);
//                }
//              }
//            }
//          }
//        }
//      } else { //TODO Z字改ページ
//        if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountV) && (strBList.get(0)[0].length-2) % rowMax == 0) { //todo Z形改ページ倍数系
//          totalIsOkV = 1;
//          for (int v = 1 + (pageV * lineMax); v <= lineMax * (pageV + 1); v++) {
//            for (int h = 1 + (pageH * rowMax); h <= rowMax * (pageH + 1) + totalIsOkV; h++) {
//              if (h > tatleH.length || v > tatleV.length) {
//                value = "";
//              } else {
//                value = strBList.get(0)[v][h];
//              }
//              if (strBList.get(0)[0].length - 1 == h && TOTAL_COUNTS_DISPLAY_Y.equals(totalCountV)) {
//                if (v == strBList.get(0).length - 1 && h == strBList.get(0)[v].length - 1) {
//                  value = "";
//                }
//                if (hengTotatlFalg == 1) {
//                  key = String.format("%d#%s-%d", page, outExcelIndexV, 1);
//                  hengTotatlFalg++;
//                } else {
//                  String nextRowRangeV = getNextRowRange(outExcelIndexV);
//                  key = String.format("%d#%s-%d", page, nextRowRangeV, 1);
//                  outExcelIndexV = nextRowRangeV;
//                }
//                value = totalNumFormat(inTempFormat, value);
//                // カウント外合計であると判定された行はcount++論理を実行しない
//                if (h < rowMax * (pageH + 1) + totalIsOkV) {
//                  count++;
//                }
//              } else if (strBList.get(0).length - 1 == v && h <= strBList.get(0)[v].length - 1
//                && TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                if (repeatAddressHNum < repeatAddressH.length) {
//                  String nextRowRangeH = repeatAddressH[repeatAddressHNum].replaceAll("\\d+", String.valueOf(Integer.parseInt(maxNumV) + 1));
//                  key = String.format("%d#%s-%d", page, nextRowRangeH, 1);
//                  repeatAddressHNum++;
//                  // 縦合計時空間値にデフォルトで0を割り当てる
//                  if (StringUtils.isEmpty(value)) {
//                    value = "0";
//                  }
//                  value = totalNumFormat(inTempFormat, value);
//                  // 最後の値が合計であると判断し、集計に表示されるべきではありません
//                  if (v == strBList.get(0).length-1 && h == strBList.get(0)[v].length-1) {
//                    value = "";
//                  }
//                  // カウント外合計であると判定された行はcount++論理を実行しない
//                  if (h < rowMax * (pageH + 1) + totalIsOkV) {
//                    count++;
//                  }
//                } else {
//                  continue;
//                }
//              } else {
//                key = String.format("%d#%s-%d.%s-1", page, idLst.get("REPORT_VALUE"), count++, idLst.get("REPORT_VALUE"));
//              }
//              outPutHtml.put(key, value);
//            }
//          }
//        } else { //todo Z字改ページ正常系
//          for (int v = 1 + (pageV * lineMax); v <= lineMax * (pageV + 1); v++) {
//            for (int h = 1 + (pageH * rowMax); h <= rowMax * (pageH + 1); h++) {
//              if (h > tatleH.length || v > tatleV.length) {
//                value = "";
//              } else {
//                value = strBList.get(0)[v][h];
//              }
//              if (strBList.get(0)[0].length - 1 == h && TOTAL_COUNTS_DISPLAY_Y.equals(totalCountV)) {
//                if (v == strBList.get(0).length - 1 && h == strBList.get(0)[v].length - 1) {
//                  value = "";
//                }
//                if (hengTotatlFalg == 1) {
//                  key = String.format("%d#%s-%d", page, outExcelIndexV, 1);
//                  hengTotatlFalg++;
//                } else {
//                  String nextRowRangeV = getNextRowRange(outExcelIndexV);
//                  key = String.format("%d#%s-%d", page, nextRowRangeV, 1);
//                  outExcelIndexV = nextRowRangeV;
//                }
//                value = totalNumFormat(inTempFormat, value);
//                count++;
//              } else if (strBList.get(0).length - 1 == v && h <= strBList.get(0)[v].length - 1
//                && TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                if (repeatAddressHNum < repeatAddressH.length) {
//                  String nextRowRangeH = repeatAddressH[repeatAddressHNum].replaceAll("\\d+", String.valueOf(Integer.parseInt(maxNumV) + 1));
//                  key = String.format("%d#%s-%d", page, nextRowRangeH, 1);
//                  repeatAddressHNum++;
//                  // 縦合計時空間値にデフォルトで0を割り当てる
//                  if (StringUtils.isEmpty(value)) {
//                    value = "0";
//                  }
//                  value = totalNumFormat(inTempFormat, value);
//                  // 最後の値が合計であると判断し、集計に表示されるべきではありません
//                  if (v == strBList.get(0).length-1 && h == strBList.get(0)[v].length-1) {
//                    value = "";
//                  }
//                  count++;
//                } else {
//                  continue;
//                }
//              } else {
//                // 最後の値が合計であると判断し、集計に表示されるべきではありません
//                if (v == strBList.get(0).length-1 && h == strBList.get(0)[v].length-1) {
//                  value = "";
//                }
//                key = String.format("%d#%s-%d.%s-1", page, idLst.get("REPORT_VALUE"), count++, idLst.get("REPORT_VALUE"));
//              }
//              outPutHtml.put(key, value);
//            }
//          }
//        }
//        //todo Z型->縦合計が表示であり、縦表示数と縦操作逆数が幾何倍である場合は、縦合計表示を強制する必要がある
//        if (totalIsOkH == 1) {
//          for (int v = 1 + (pageV * lineMax); v <= lineMax * (pageV + 1) + totalIsOkH; v++) {
//            for (int h = 1 + (pageH * rowMax); h <= rowMax * (pageH + 1); h++) {
//              if (h > tatleH.length || v > tatleV.length) {
//                value = "";
//              } else {
//                value = strBList.get(0)[v][h];
//              }
//              if (strBList.get(0).length - 1 == v && h <= strBList.get(0)[v].length - 1
//                && TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                if (repeatAddressHNum < repeatAddressH.length) {
//                  String nextRowRangeH = repeatAddressH[repeatAddressHNum].replaceAll("\\d+", String.valueOf(Integer.parseInt(maxNumV) + 1));
//                  key = String.format("%d#%s-%d", page, nextRowRangeH, 1);
//                  repeatAddressHNum++;
//                  // 縦合計時空間値にデフォルトで0を割り当てる
//                  if (StringUtils.isEmpty(value)) {
//                    value = "0";
//                  }
//                  value = totalNumFormat(inTempFormat, value);
//                  // 最後の値が合計であると判断し、集計に表示されるべきではありません
//                  if (v == strBList.get(0).length-1 && h == strBList.get(0)[v].length-1) {
//                    value = "";
//                  }
//                  outPutHtml.put(key, value);
//                }
//              }
//            }
//          }
//        }
//      }
//      // 横縦の集計外の合計の合計は、最終ページの固定位置にのみ表示されることが知られています
//      if (page == pageTotal) {
//        if (isHV) { // 横も縦も合計する
//          // 取得合計値
//          String totalSumValue = strBList.get(0)[strBList.get(0).length - 1][strBList.get(0)[0].length - 1];
//          key = String.format("%d#%s-%d", page, totalSumIndex, 1);
//          totalSumValue = totalNumFormat(inTempFormat, totalSumValue);
//          outPutHtml.put(key, totalSumValue);
//        } else { // 横縦に合計が1つだけ、または横縦に合計がない
//          key = String.format("%d#%s-%d", page, totalSumIndex, 1);
//          // 合計値を表示しない
//          outPutHtml.put(key, "");
//        }
//      }
//      // 横方向の繰り返し
//      reportH = baseSt.getRow(30).getCell(0).toString().split(",")[0];
//      for (int index = 0; index < arrtotalUnitV.length; index++) {
//        if (reportH.startsWith("##")) {
//          break;
//        }
//        for (int h = (pageH * rowMax); h < rowMax * (pageH + 1) + totalIsOkV; h++) {
//          if (h >= tatleH.length) {
//            value = "";
//          } else {
//            if (index > 0) {
//              if (h + 1 >= tatleH.length) {
//                value = "";
//              } else {
//                value = arrtotalUnitV[index][h + 1];
//                reportH = arrtotalUnitV[index][0];
//              }
//            } else {
//              value = tatleH[h];
//            }
//          }
//          // mod 10546 複数集計出力時にサーバが高負荷になる gjn start
//          if (repeatCountH > 1) {
//            key = String.format("%d#%s-%d", page, idLst.get(reportH), h + 1);
//          } else {
//            key = String.format("%d#%s-%d", page, idLst.get(reportH), 1);
//          }
//          // mod 10546 複数集計出力時にサーバが高負荷になる gjn end
//          if ("合　計".equals(value)) {
//            outPutHtml.put(key, "");
//            key = String.format("%d#%s-%d", page, outExcelIndex, 1);
//          }
//          outPutHtml.put(key, value);
//        }
//      }
//      // 縦方向の繰り返し
//      reportV = baseSt.getRow(31).getCell(0).toString().split(",")[0];
//      for (int index = 0; index < arrtotalUnitH.length; index++) {
//        if (reportV.startsWith("##")) {
//          break;
//        }
//        for (int v = (pageV * lineMax); v < lineMax * (pageV + 1) + totalIsOkH; v++) {
//          if (v >= tatleV.length) {
//            value = "";
//          } else {
//            if (index > 0) {
//              if (v + 1 >= tatleV.length) {
//                value = "";
//              } else {
//                value = arrtotalUnitH[index][v + 1];
//                reportV = arrtotalUnitH[index][0];
//              }
//            } else {
//              value = tatleV[v];
//            }
//          }
//          // mod 10546 複数集計出力時にサーバが高負荷になる gjn start
//          if (repeatCountV > 1) {
//            key = String.format("%d#%s-%d", page, idLst.get(reportV), v + 1);
//          } else {
//            key = String.format("%d#%s-%d", page, idLst.get(reportV), 1);
//          }
//          // mod 10546 複数集計出力時にサーバが高負荷になる gjn end
//          if ("合　計".equals(value)) {
//            outPutHtml.put(key, "");
//            key = String.format("%d#%s-%d", page, outExcelIndexH, 1);
//          }
//          outPutHtml.put(key, value);
//        }
//      }
//      // mod 10989 集計機能の合計出力仕様の変更（複数集計）gjn end
//      if ("N".equals(direction)) {
//        pageH = page / pageTotalV;
//        pageV = page % pageTotalV;
//      } else {
//        pageV = page / pageTotalH;
//        pageH = page % pageTotalH;
//      }
//    }
////    if (isUseAsposeCells) {
////      return "";
////    }
//    // del 10546 複数集計出力時にサーバが高負荷になる gjn start
////    // 帳票デザインHTMLをパースする
////    org.jsoup.nodes.Document document = Jsoup.parse(html);
////    org.jsoup.nodes.Element baseElement = document.getElementsByTag("body").first();
////    // 全ページ同じ内容を設定する内容をHTMLへ反映する
////    outPutHtml.entrySet().stream()
////      .forEach(r ->
////        Optional.ofNullable(
////          baseElement.getElementById(r.getKey())).ifPresent(e -> {
////          if (e.children().size() == 0) {
////            e.text(r.getValue());
////          } else {
////            e.children().get(0).text(r.getValue());
////          }
////        }));
////
////    return document.html();
//    // de 10546 複数集計出力時にサーバが高負荷になる gjn end
//  }
//
//
//  // add 10989 集計機能の合計出力仕様の変更（複数集計）gjn start
//
//  /***
//   * 次の縦セルの位置を取得
//   *（例：A 1またはA 1：B 1形式）
//   *
//   * @param range
//   * @return
//   */
//  public static String getNextRowRange(String range) {
//    if (range.contains(":")) {
//      String[] parts = range.split(":");
//      String start = parts[0];
//      String end = parts[1];
//      String startRow = extractRow(start);
//      String endRow = extractRow(end);
//      int newRowNumber = Integer.parseInt(startRow) + 1;
//      return replaceRow(start, newRowNumber) + ":" + replaceRow(end, newRowNumber);
//    } else {
//      String start = range;
//      String startRow = extractRow(start);
//      int newRowNumber = Integer.parseInt(startRow) + 1;
//      return replaceRow(start, newRowNumber);
//    }
//  }
//
//  private static String replaceRow(String cell, int newRowNumber) {
//    String column = cell.replaceAll("\\d", "");
//    return column + newRowNumber;
//  }
//
//
//  /**
//   * excelの横に隣接する次のセルの位置を取得
//   *
//   * @param cellOrRange
//   * @return
//   */
//  public static String getNextHorizontalCell(String cellOrRange) {
//    if (cellOrRange.contains(":")) {
//      String[] parts = cellOrRange.split(":");
//      String endCell = parts[1];
//      return getNextColumn(endCell);
//    } else {
//      return getNextColumn(cellOrRange);
//    }
//  }
//
//  private static String getNextColumn(String cell) {
//    String column = extractColumn(cell);
//    String rowNumber = extractRow(cell);
//    String nextColumn = getNextColumnLetter(column);
//    return nextColumn + rowNumber;
//  }
//
//  private static String extractColumn(String cell) {
//    return cell.replaceAll("\\d", "");
//  }
//
//  private static String extractRow(String cell) {
//    return cell.replaceAll("\\D", "");
//  }
//
//  private static String getNextColumnLetter(String column) {
//    int columnNumber = columnToNumber(column);
//    columnNumber++;
//    return numberToColumn(columnNumber);
//  }
//
//  private static int columnToNumber(String column) {
//    int number = 0;
//    for (char c : column.toCharArray()) {
//      number = number * 26 + (c - 'A' + 1);
//    }
//    return number;
//  }
//
//  private static String numberToColumn(int number) {
//    StringBuilder column = new StringBuilder();
//    while (number > 0) {
//      number--;
//      column.insert(0, (char) ('A' + number % 26));
//      number /= 26;
//    }
//    return column.toString();
//  }
//// add 10989 集計機能の合計出力仕様の変更（複数集計）gjn end
//
//
//
//  // add 10989 集計機能の合計出力仕様の変更（複数集計） gjn start
//  private String totalNumFormat(String formatStr, String value) {
//    if (StringUtils.isEmpty(formatStr) || StringUtils.isEmpty(value)) {
//      return value;
//    }
//    double number = Double.parseDouble(value);
//    return String.format(formatStr, number);
//  }
//  // add 10989 集計機能の合計出力仕様の変更（複数集計） gjn end
//
//
//  /**
//   * 帳票デザインExcelを取得します.
//   *
//   * @param mstReport     帳票マスタEntity
//   * @param reportZipFile 帳票Zipファイル
//   * @return 帳票デザインExcel(POI Workbook)
//   */
//  private Workbook getReportWorkbook(MstReport mstReport, ReportZipFile reportZipFile) {
//    // エクセルファイルを取得
//    byte[] excelData = reportZipFile.getFile(mstReport.getReportPath().getXlsxFilename());
//    if (Objects.isNull(excelData)) {
//      throw new NotExistException("帳票デザインExcelファイルを取得できません。");
//    }
//    try (InputStream is = new ByteArrayInputStream(excelData)) {
//      return WorkbookFactory.create(is);
//    } catch (IOException e) {
//      throw new NtssException("帳票デザインExcelファイルを取得できません。");
//    }
//  }
//
//  /**
//   * ページブレイクの文字列を取得する.
//   *
//   * @return ページブレイク用の文字列
//   */
//  private String getPageBreakString() {
//    return "<div style=\"page-break-before: always;page-break-inside:avoid;\" />";
//  }
//
//  /**
//   * 文字情報を取得します.
//   * <pre>
//   *     引数の文字列を1文字に分解した情報をリストで返却する.
//   *     1文字ごとに以下の情報を配列で保持する.
//   *     ・[0]：半角文字を 1 、全角文字を 2 とした文字数
//   *     ・[1]：文字列(1文字)
//   * </pre>
//   *
//   * @param value 文字列
//   * @return 文字情報のリスト
//   */
//  private List<Object[]> getCharInfos(String value) {
//    List<Object[]> charInfos = new ArrayList<>();
//    char[] chars = value.toCharArray();
//    for (Integer i = 0; i < chars.length; i++) {
//      char c = chars[i];
//      Integer length = ((c <= '\u007e') || (c == '\u00a5') || (c == '\u203e') || (c >= '\uff61' && c <= '\uff9f')) ? 1 : 2;
//      charInfos.add(new Object[]{length, c});
//    }
//    return charInfos;
//  }
//
//
//  /**
//   * 条件付き書式を適用するidとclassのMapを作成する.
//   *
//   * @param params           Param要素情報
//   * @param reportOutputInfo 帳票出力情報
//   * @param reportCd         レポートCD
//   * @return 条件付き書式を適用するidとclassのMap
//   */
//  private Map<String, String> createFormatConditionInfo(List<ReportXmlParam> params, Map<String, String> reportOutputInfo, Long reportCd) {
//    ScriptEngineManager sem = new ScriptEngineManager();
//    ScriptEngine engine = sem.getEngineByName("javascript");
//    // idとclassのMap
//    Map<String, String> formatConditionInfo = new HashMap<>();
//    // paramからFormatConditionが設定されているデータを対象とする
//    List<ReportXmlParam> hasFormatConditionParams = params.stream()
//      .filter(e -> !e.getReportXmlFormatConditions().isEmpty())
//      .collect(toList());
//    hasFormatConditionParams.forEach(p -> {
//      // paramのidでreportOutputInfoを絞り込む（複数行もあるのでリスト）
//      List<String> reportOutputInfoKey = reportOutputInfo.keySet().stream()
//        .filter(r -> r.contains(p.getId()))
//        .collect(toList());
//      // 値を評価する
//      reportOutputInfoKey.forEach(r -> {
//        String reportOutValue = reportOutputInfo.get(r);
//        for (ReportXmlFormatCondition reportXmlFormatCondition : p.getReportXmlFormatConditions()) {
//          // 評価式
//          String evaluationFormula = "";
//          // 値の文字列
//          String stringValue = "";
//          if (StringUtils.isEmpty(reportOutValue) == false) {
//            stringValue = reportOutValue;
//          }
//          // 評価値が空の場合は例外が発生するため評価値にシングルクォーテーションを付与し文字列で比較する
//          if (StringUtils.isEmpty(reportXmlFormatCondition.getValue())) {
//            evaluationFormula = String.format("'%s'%s''",
//              stringValue,
//              reportXmlFormatCondition.getComparisonOperator()
//            );
//          }
//          // 評価値にシングルクォーテーションが含まれる場合は文字列で比較する
//          else if (reportXmlFormatCondition.getValue().contains("'")) {
//            evaluationFormula = String.format("'%s'%s%s",
//              stringValue,
//              reportXmlFormatCondition.getComparisonOperator(),
//              reportXmlFormatCondition.getValue()
//            );
//          }
//          // 上記以外はそのまま比較する
//          else {
//            if (!StringUtils.isEmpty(stringValue)) {
//              evaluationFormula = String.format("%s%s%s",
//                stringValue,
//                reportXmlFormatCondition.getComparisonOperator(),
//                reportXmlFormatCondition.getValue()
//              );
//            }
//          }
//          try {
//            if (!StringUtils.isEmpty(evaluationFormula) && (boolean) engine.eval(evaluationFormula)) {
//              // idとclassのリストに追加
//              formatConditionInfo.put(r, reportXmlFormatCondition.getTextContent());
//              break;
//            }
//          } catch (ScriptException | ClassCastException e) {
//
//            EventLogMessage eventLogMessage = new EventLogMessage();
//            eventLogMessage.setLogMessage("条件付き書式の評価式に不備があります。レポートCD：[" + reportCd + "], セルID：[" + r + "], 評価式：[" + evaluationFormula + "], Exception message : " + e.getMessage());
//            logService.log(LogLevel.DEBUG, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
//          }
//        }
//      });
//    });
//    return formatConditionInfo;
//  }
//
//
//  private Map<String, String> convertDataCodeToIdForCount(
//    List<ReportXmlParam> params,
//    Map<Long, List<Map<String, Object>>> reportOutputInfo,
//    Map<String, Object> dataKeyOutTempl,
//    MstReport mstReport,
//    ReportZipFile reportZipFile,
//    // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen start
//    //Map<String, Integer> pageCountMap) {
//    Map<String, Integer> pageCountMap,
//    Map<String, String> param2,
//    // add 10546 複数集計出力時にサーバが高負荷になる gjn start
//    String isNewPage) {
//    // add 10546 複数集計出力時にサーバが高負荷になる gjn end
//    String totalCountH = param2.get("totalCountH");
//    String totalUnitDate = param2.get("totalUnitDate");
//    // add #11293 水質検査帳票の課題対応 limingzhe start
//    // mod #11950 複数集計帳票の印刷で出力可能なページ数だが100ページ制限となり出力できない。 limingzhe start
//    //param2.put("reportType", String.valueOf(mstReport.getReportType()));
//    param2.put("effectDateFlag", mstReport.getReportType() == 3 ? "1" : "0");
//    // mod #11950 複数集計帳票の印刷で出力可能なページ数だが100ページ制限となり出力できない。 limingzhe end
//    // add #11293 水質検査帳票の課題対応 limingzhe end
//    // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen end
//    Map<String, String> result = new HashMap<>();
//    Workbook wb = getReportWorkbook(mstReport, reportZipFile);
//    Sheet baseSt = wb.getSheet("設定");
//    String[] reportHs = baseSt.getRow(30).getCell(0).toString().split(",");
//    String[] reportVs = baseSt.getRow(31).getCell(0).toString().split(",");
//    String reportH = reportHs[0];
//    String reportV = reportVs[0];
//    final String reportH2 = reportHs.length > 1 ? reportHs[1] : "";
//    final String reportV2 = reportVs.length > 1 ? reportVs[1] : "";
//    String direction = baseSt.getRow(18).getCell(0).toString().split(",")[0];
//    // sqlCode属性値でグループ化したParam要素情報を取得する
//    Map<String, List<ReportXmlParam>> groupedParams = params.stream()
//      .filter(p -> !StringUtils.isEmpty(p.getId()))
//      .collect(Collectors.groupingBy(p -> p.getSqlCode()));
//    if (mstReport.getReportType() != null && mstReport.getReportType() == 2) {
//      // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen start
//      // outCompute(result, groupedParams, reportOutputInfo, dataKeyOutTempl, reportH, mstReport, pageCountMap);
//      outCompute(result, groupedParams, reportOutputInfo, dataKeyOutTempl, reportH, mstReport, pageCountMap, param2);
//      // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen end
//    }
//    // データ項目コード -> id属性値 に変換した情報を設定する
//    groupedParams.entrySet().forEach(groupedParam -> {
//      Long sqlCode;
//      if (null != groupedParam.getKey() && groupedParam.getKey().equals("")) {
//        sqlCode = Long.valueOf(0);
//      } else {
//        sqlCode = Long.valueOf(groupedParam.getKey());
//      }
//      // sqlCodeをもとに出力情報を取得する
//      List<Map<String, Object>> tmpList = reportOutputInfo.get(sqlCode);
//      Map<String, Object> dataKeyValues = new HashMap<>();
//      if (null != tmpList && tmpList.size() > 0 && tmpList.get(0).containsKey("pat_last_name_id")) {
//        for (int i = 0; i < tmpList.size(); i++) {
//          if (dataKeyOutTempl.get("patId").equals(tmpList.get(i).get("patId"))) {
//            dataKeyValues = tmpList.get(i);
//            break;
//          }
//        }
//      }
//      if (null != tmpList && !tmpList.isEmpty()) {
//        // 単一項目に対する処理を行う
//        Map<String, Object> tmpMap = tmpList.get(0);
//        groupedParam.getValue().stream()
//          .filter(param -> StringUtils.isEmpty(param.getGroupId()) && !param.isTmplRepeat())
//          .forEach(param -> {
//            // 出力する内容を取得する
//            String value = reportServiceImpl.formatValue(param, tmpMap.get(param.getDataCode()));
//            value = reportServiceImpl.convertValue(param, value);
//            if (value != null && !"null".equals(value)) {
//              // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
//              // result.put(param.getId(), addLineBreak(value, param.getDispLength(), param.getDataType()));
//              result.put(param.getId(), reportServiceImpl.addLineBreak(value, param));
//              // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
//            } else {
//              result.put(param.getId(), "");
//            }
//          });
//        // 複数項目に対する処理を行う
//        if (sqlCode == 152L || sqlCode == 153L) {
//          groupedParam.getValue().stream()
//            .filter(param -> !StringUtils.isEmpty(param.getGroupId()) && !param.isTmplRepeat())
//            .forEach(param -> {
//              // フィルタ処理を行う
//              List<Map<String, Object>> filteredList = reportServiceImpl.filterReportInfo(param, tmpList);
//              // 列、行のヘーダを取得する。
//              List<String> suppLiesLst = new ArrayList<>();
//              // 列、行の区分を取得する。
//              String dataCode = param.getDataCode();
//              for (int i = 0; i < reportVs.length; i++) {
//                if (reportVs[i].equals(dataCode)) {
//                  for (Map<String, Object> item : filteredList) {
//                    if (item.get(dataCode) != null) {
//                      suppLiesLst.add(item.get(dataCode).toString());
//                    }
//                  }
//                  suppLiesLst = suppLiesLst.stream().distinct().collect(Collectors.toList());
//                }
//              }
//              for (int j = 0; j < reportHs.length; j++) {
//                if (reportHs[j].equals(dataCode)) {
//                  int daysCount = 0;
//                  if ("treat_date".equals(reportHs[j])) {
//                    // 時間転換処理
//                    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
//                    Calendar bef = Calendar.getInstance();
//                    Calendar aft = Calendar.getInstance();
//                    try {
//                      bef.setTime(sdf.parse(dataKeyOutTempl.get("fromDate").toString().replaceAll("/", "")));
//                      aft.setTime(sdf.parse(dataKeyOutTempl.get("toDate").toString().replaceAll("/", "")));
//                    } catch (ParseException e) {
//                      e.printStackTrace();
//                    }
//                    int monthSection = aft.get(Calendar.MONTH) - bef.get(Calendar.MONTH);
//                    int yearSection = aft.get(Calendar.YEAR) - bef.get(Calendar.YEAR);
//                    // 集計単位日付属性により、配列の縦列サイズを計算する。
//                    int dateCount = 0;
//                    if ("月".equals(totalUnitDate)) {
//                      if (yearSection <= 0) {
//                        dateCount = monthSection + 2;
//                      } else {
//                        dateCount = 12 * yearSection + monthSection + 2;
//                      }
//                    } else if ("年".equals(totalUnitDate)) {
//                      dateCount = yearSection + 2;
//                    } else {
//                      // ”日”指定の場合、日付差を計算後で設定する。
//                      long time1 = bef.getTimeInMillis();
//                      long time2 = aft.getTimeInMillis();
//                      long between_days = (time2 - time1) / (1000 * 3600 * 24);
//                      dateCount = Integer.parseInt(String.valueOf(between_days)) + 2;
//                    }
//                    daysCount = dateCount - 1;
//                    if (TOTAL_COUNTS_DISPLAY_N.equals(totalCountH)) {
//                      for (int i = 0; i < dateCount - 1; i++) {
//                        Date date = bef.getTime();
//                        suppLiesLst.add(sdf.format(date));
//                        bef.add(Calendar.DATE, 1);
//                      }
//                    } else {
//                      for (int i = 0; i < dateCount; i++) {
//                        if (dateCount - 1 != i) {
//                          Date date = bef.getTime();
//                          suppLiesLst.add(sdf.format(date));
//                          bef.add(Calendar.DATE, 1);
//                        } else {
//                          suppLiesLst.add("合計");
//                        }
//                      }
//                    }
//                  } else {
//                    for (Map<String, Object> item : filteredList) {
//                      if (item.get(dataCode) != null) {
//                        suppLiesLst.add(item.get(dataCode).toString());
//                      }
//                    }
//                  }
//                  if (sqlCode == 152L) {
//                    suppLiesLst = suppLiesLst.stream().distinct().collect(Collectors.toList());
//                    List<String> kurNameList = new ArrayList<>();
//                    kurNameList.addAll(suppLiesLst);
//                    if ("kur_name".equals(reportHs[j])) {
//                      for (int i = 1; i < daysCount; i++) {
//                        suppLiesLst.addAll(kurNameList);
//                      }
//                    }
//                  }
//                }
//              }
//              if (!suppLiesLst.isEmpty()) {
//                // 1ページの繰り返し件数を取得する
//                ReportXmlGroup group = param.getReportXmlGroup();
//                Integer repeatOfPage;
//                if (group != null && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_YES) {
//                  repeatOfPage = (suppLiesLst.size() > group.getRepeatMax()) ? group.getRepeatMax() : suppLiesLst.size();
//                } else {
//                  repeatOfPage = suppLiesLst.size();
//                }
//                // 複数項目のページ数より、単一項目のページ数を設定する
//                int addPage = (suppLiesLst.size() % repeatOfPage) > 0 ? 1 : 0;
//                for (int i = 0; i < reportVs.length; i++) {
//                  if (reportVs[i].equals(dataCode)) {
//                    pageCountMap.replace("COUNT_PAGE_LINE", (suppLiesLst.size() / repeatOfPage) + addPage);
//                    pageCountMap.replace("COUNT_LINE", suppLiesLst.size());
//                  }
//                }
//                for (int j = 0; j < reportHs.length; j++) {
//                  if (reportHs[j].equals(dataCode)) {
//                    pageCountMap.replace("COUNT_PAGE_ROW", (suppLiesLst.size() / repeatOfPage) + addPage);
//                    pageCountMap.replace("COUNT_ROW", suppLiesLst.size());
//                  }
//                }
//                pageCountMap.replace("COUNT_PAGE", pageCountMap.get("COUNT_PAGE_LINE") * pageCountMap.get("COUNT_PAGE_ROW"));
//              }
//            });
//        } else {
//          //lambda式のチェック問題への対応です
//          // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen start
//          // this.pageCountCompute(params, reportHs, reportVs, reportOutputInfo, dataKeyOutTempl, pageCountMap);
//          this.pageCountCompute(params, reportHs, reportVs, reportOutputInfo, dataKeyOutTempl, pageCountMap, param2);
//          // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen end
//        }
//        //複数項目に対する処理を行う
//        Map<String, Object> finalDataKeyValues = dataKeyValues;
//        groupedParam.getValue().stream()
//          .filter(param -> !StringUtils.isEmpty(param.getGroupId()) && !param.isTmplRepeat())
//          .forEach(param -> {
//            // フィルタ処理を行う
//            List<Map<String, Object>> filteredList = reportServiceImpl.filterReportInfo(param, tmpList);
//            // フィルタ処理の結果がEmptyの場合
//            if (filteredList.isEmpty()) {
//              EventLogMessage eventLogMessage = new EventLogMessage();
//              eventLogMessage.setLogMessage("帳票：フィルタ結果した結果が空");
//              logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
//              return;
//            }
//            // 列、行のヘーダを取得する。
//            List<String> suppLiesLst = new ArrayList<>();
//            // 列、行の区分を取得する。
//            String dataCode = param.getDataCode();
//
//            if (sqlCode == 152L || sqlCode == 153L) {
//              for (int i = 0; i < reportVs.length; i++) {
//                if (reportVs[i].equals(dataCode)) {
//                  for (Map<String, Object> item : filteredList) {
//                    if (item.get(dataCode) != null) {
//                      suppLiesLst.add(item.get(dataCode).toString());
//                    }
//                  }
//                  suppLiesLst = suppLiesLst.stream().distinct().collect(Collectors.toList());
//                }
//              }
//              for (int j = 0; j < reportHs.length; j++) {
//                if (reportHs[j].equals(dataCode)) {
//                  int daysCount = 0;
//                  if ("treat_date".equals(reportHs[j])) {
//                    // 時間転換処理
//                    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
//                    Calendar bef = Calendar.getInstance();
//                    Calendar aft = Calendar.getInstance();
//                    try {
//                      bef.setTime(sdf.parse(dataKeyOutTempl.get("fromDate").toString().replaceAll("/", "")));
//                      aft.setTime(sdf.parse(dataKeyOutTempl.get("toDate").toString().replaceAll("/", "")));
//                    } catch (ParseException e) {
//                      e.printStackTrace();
//                    }
//                    int monthSection = aft.get(Calendar.MONTH) - bef.get(Calendar.MONTH);
//                    int yearSection = aft.get(Calendar.YEAR) - bef.get(Calendar.YEAR);
//                    // 集計単位日付属性により、配列の縦列サイズを計算する。
//                    int dateCount = 0;
//                    if ("月".equals(totalUnitDate)) {
//                      if (yearSection <= 0) {
//                        dateCount = monthSection + 2;
//                      } else {
//                        dateCount = 12 * yearSection + monthSection + 2;
//                      }
//                    } else if ("年".equals(totalUnitDate)) {
//                      dateCount = yearSection + 2;
//                    } else {
//                      // ”日”指定の場合、日付差を計算後で設定する。
//                      long time1 = bef.getTimeInMillis();
//                      long time2 = aft.getTimeInMillis();
//                      long between_days = (time2 - time1) / (1000 * 3600 * 24);
//                      dateCount = Integer.parseInt(String.valueOf(between_days)) + 2;
//                    }
//                    daysCount = dateCount - 1;
//                    if (TOTAL_COUNTS_DISPLAY_N.equals(totalCountH)) {
//                      for (int i = 0; i < dateCount - 1; i++) {
//                        Date date = bef.getTime();
//                        suppLiesLst.add(sdf.format(date));
//                        bef.add(Calendar.DATE, 1);
//                      }
//                    } else {
//                      for (int i = 0; i < dateCount; i++) {
//                        if (dateCount - 1 != i) {
//                          Date date = bef.getTime();
//                          suppLiesLst.add(sdf.format(date));
//                          bef.add(Calendar.DATE, 1);
//                        } else {
//                          suppLiesLst.add("合計");
//                        }
//                      }
//                    }
//                  } else {
//                    for (Map<String, Object> item : filteredList) {
//                      if (item.get(dataCode) != null) {
//                        suppLiesLst.add(item.get(dataCode).toString());
//                      }
//                    }
//                  }
//                  if (sqlCode == 152L) {
//                    suppLiesLst = suppLiesLst.stream().distinct().collect(Collectors.toList());
//                    List<String> kurNameList = new ArrayList<>();
//                    kurNameList.addAll(suppLiesLst);
//                    if ("kur_name".equals(reportHs[j])) {
//                      for (int i = 1; i < daysCount; i++) {
//                        suppLiesLst.addAll(kurNameList);
//                      }
//                    }
//                  }
//                }
//              }
//              // 1ページの繰り返し件数を取得する
//              ReportXmlGroup group = param.getReportXmlGroup();
//              Integer repeatOfPage;
//              if (group != null && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_YES) {
//                repeatOfPage = (suppLiesLst.size() > group.getRepeatMax()) ? group.getRepeatMax() : suppLiesLst.size();
//              } else if (group != null && group.getIsNewPage() != ReportXmlGroup.IS_NEW_PAGE_YES) {
//                repeatOfPage = (suppLiesLst.size() > group.getRepeatMax()) ? group.getRepeatMax() : suppLiesLst.size();
//              } else {
//                repeatOfPage = suppLiesLst.size();
//              }
//              // ページ数分、以下の処理を行う
//              int limitCount = repeatOfPage;
//              for (Integer pageLoopCount = 0; pageLoopCount < pageCountMap.get("COUNT_PAGE"); pageLoopCount++) {
//                int skipCount = pageLoopCount * limitCount;
//                // id属性値をkey、出力値をvalue に設定する（複数項目の場合、id属性値に連番を付加する）
//                List<String> outputInfos = suppLiesLst.stream().skip(skipCount).limit(limitCount).collect(toList());
//                if (outputInfos.size() == 0) {
//                  continue;
//                }
//                List<ReportXmlFilterTable> filters = param.getReportXmlFilters();
//                Integer loopKbn = 0;
//                if ("N".equals(direction)) {
//                  loopKbn = pageCountMap.get("COUNT_PAGE_LINE");
//                  for (int a = 0; a < reportVs.length; a++) {
//                    if (reportVs[a].equals(dataCode)) {
//                      for (Integer pageLoop = pageLoopCount; pageLoop < pageCountMap.get("COUNT_PAGE"); pageLoop = pageLoop + loopKbn) {
//                        int n = (pageLoopCount % loopKbn) * repeatOfPage;
//                        for (Integer i = 0; i < repeatOfPage; i++) {
//                          String pageStr = String.format("%d%s", pageLoop + 1, MULTIPLE_PAGES_SEPARATOR);
//                          String key = String.format("%s%s-%d", pageStr, param.getId(), n + 1);
//                          if (i >= outputInfos.size()) {
//                            result.put(key, "");
//                            n = n + 1;
//                            continue;
//                          }
//                          String outputData = String.valueOf(outputInfos.get(i));
//                          if (filters == null || filters.size() == 0 || (outputData.equals(filters.get(0).getCode()) && !outputData.isEmpty())) {
//                            String value = reportServiceImpl.formatValue(param, outputInfos.get(i));
//                            value = reportServiceImpl.convertValue(param, value);
//                            if (value != null && !"null".equals(value)) {
//                              // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
//                              // result.put(key, addLineBreak(value, param.getDispLength(), param.getDataType()));
//                              result.put(key, reportServiceImpl.addLineBreak(value, param));
//                              // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
//                            } else {
//                              result.put(key, "");
//                            }
//                            n = n + 1;
//                          }
//                        }
//                      }
//                    }
//                  }
//                  for (int j = 0; j < reportHs.length; j++) {
//                    if (reportHs[j].equals(dataCode)) {
//                      for (Integer pageLoop = pageLoopCount * loopKbn;
//                           pageLoop < pageCountMap.get("COUNT_PAGE") && pageLoop < (pageLoopCount + 1) * loopKbn;
//                           pageLoop++) {
//                        int n = skipCount;
//                        for (Integer i = 0; i < repeatOfPage; i++) {
//                          String pageStr = String.format("%d%s", pageLoop + 1, MULTIPLE_PAGES_SEPARATOR);
//                          String key = String.format("%s%s-%d", pageStr, param.getId(), n + 1);
//                          if (i >= outputInfos.size()) {
//                            result.put(key, "");
//                            n = n + 1;
//                            continue;
//                          }
//                          String outputData = String.valueOf(outputInfos.get(i));
//                          if (filters == null || filters.size() == 0 || (outputData.equals(filters.get(0).getCode()) && !outputData.isEmpty())) {
//                            String value = reportServiceImpl.formatValue(param, outputInfos.get(i));
//                            value = reportServiceImpl.convertValue(param, value);
//                            if (value != null && !"null".equals(value)) {
//                              // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
//                              // result.put(key, addLineBreak(value, param.getDispLength(), param.getDataType()));
//                              result.put(key, reportServiceImpl.addLineBreak(value, param));
//                              // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
//                            } else {
//                              result.put(key, "");
//                            }
//                            n = n + 1;
//                          }
//                        }
//                      }
//                    }
//                  }
//                } else {
//                  loopKbn = pageCountMap.get("COUNT_PAGE_ROW");
//                  for (int a = 0; a < reportVs.length; a++) {
//                    if (reportVs[a].equals(dataCode)) {
//                      for (Integer pageLoop = pageLoopCount * loopKbn;
//                           pageLoop < pageCountMap.get("COUNT_PAGE") && pageLoop < (pageLoopCount + 1) * loopKbn;
//                           pageLoop++) {
//                        int n = skipCount;
//                        for (Integer i = 0; i < repeatOfPage; i++) {
//                          String pageStr = String.format("%d%s", pageLoop + 1, MULTIPLE_PAGES_SEPARATOR);
//                          String key = String.format("%s%s-%d", pageStr, param.getId(), n + 1);
//                          if (i >= outputInfos.size()) {
//                            result.put(key, "");
//                            n = n + 1;
//                            continue;
//                          }
//                          String outputData = String.valueOf(outputInfos.get(i));
//                          if (filters == null || filters.size() == 0 || (outputData.equals(filters.get(0).getCode()) && !outputData.isEmpty())) {
//                            String value = reportServiceImpl.formatValue(param, outputInfos.get(i));
//                            value = reportServiceImpl.convertValue(param, value);
//                            if (value != null && !"null".equals(value)) {
//                              // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
//                              // result.put(key, addLineBreak(value, param.getDispLength(), param.getDataType()));
//                              result.put(key, reportServiceImpl.addLineBreak(value, param));
//                              // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
//                            } else {
//                              result.put(key, "");
//                            }
//                            n = n + 1;
//                          }
//                        }
//                      }
//                    }
//                  }
//                  for (int j = 0; j < reportHs.length; j++) {
//                    if (reportHs[j].equals(dataCode)) {
//                      for (Integer pageLoop = pageLoopCount; pageLoop < pageCountMap.get("COUNT_PAGE"); pageLoop = pageLoop + loopKbn) {
//                        int n = (pageLoopCount % loopKbn) * repeatOfPage;
//                        for (Integer i = 0; i < repeatOfPage; i++) {
//                          String pageStr = String.format("%d%s", pageLoop + 1, MULTIPLE_PAGES_SEPARATOR);
//                          String key = String.format("%s%s-%d", pageStr, param.getId(), n + 1);
//                          if (i >= outputInfos.size()) {
//                            result.put(key, "");
//                            n = n + 1;
//                            continue;
//                          }
//                          String outputData = String.valueOf(outputInfos.get(i));
//                          if (filters == null || filters.size() == 0 || (outputData.equals(filters.get(0).getCode()) && !outputData.isEmpty())) {
//                            String value = reportServiceImpl.formatValue(param, outputInfos.get(i));
//                            value = reportServiceImpl.convertValue(param, value);
//                            if (value != null && !"null".equals(value)) {
//                              // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
//                              // result.put(key, addLineBreak(value, param.getDispLength(), param.getDataType()));
//                              result.put(key, reportServiceImpl.addLineBreak(value, param));
//                              // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
//                            } else {
//                              result.put(key, "");
//                            }
//                            n = n + 1;
//                          }
//                        }
//                      }
//                    }
//                  }
//                }
//              }
//            } else {
//              if (reportV.equals(dataCode)) {
//                for (Map<String, Object> item : filteredList) {
//                  suppLiesLst.add(item.get(dataCode).toString());
//                }
//              } else if (reportH.equals(dataCode)) {
//                // add #11293 水質検査帳票の課題対応 limingzhe start
//                // mod #11950 複数集計帳票の印刷で出力可能なページ数だが100ページ制限となり出力できない。 limingzhe start
//                //if(mstReport.getReportType() == 3){
//                if(param2.get("effectDateFlag").equals("1")){
//                // mod #11950 複数集計帳票の印刷で出力可能なページ数だが100ページ制限となり出力できない。 limingzhe end
//                  for (Map<String, Object> item : filteredList) {
//                    suppLiesLst.add(item.get(dataCode).toString().replace("/", "").replace("-", ""));
//                  }
//                  if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                    suppLiesLst.add("合計");
//                  }
//                }
//                else{
//                // add #11293 水質検査帳票の課題対応 limingzhe end
//                  // 時間転換処理
//                  SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
//                  Calendar bef = Calendar.getInstance();
//                  Calendar aft = Calendar.getInstance();
//                  try {
//                    bef.setTime(sdf.parse(dataKeyOutTempl.get("fromDate").toString().replaceAll("/", "")));
//                    aft.setTime(sdf.parse(dataKeyOutTempl.get("toDate").toString().replaceAll("/", "")));
//                  } catch (ParseException e) {
//                    e.printStackTrace();
//                  }
//                  int monthSection = aft.get(Calendar.MONTH) - bef.get(Calendar.MONTH);
//                  int yearSection = aft.get(Calendar.YEAR) - bef.get(Calendar.YEAR);
//                  // 集計単位日付属性により、配列の縦列サイズを計算する。
//                  int dateCount = 0;
//                  if ("月".equals(totalUnitDate)) {
//                    if (yearSection <= 0) {
//                      dateCount = monthSection + 2;
//                    } else {
//                      dateCount = 12 * yearSection + monthSection + 2;
//                    }
//                  } else if ("年".equals(totalUnitDate)) {
//                    dateCount = yearSection + 2;
//                  } else {
//                    // ”日”指定の場合、日付差を計算後で設定する。
//                    long time1 = bef.getTimeInMillis();
//                    long time2 = aft.getTimeInMillis();
//                    long between_days = (time2 - time1) / (1000 * 3600 * 24);
//                    dateCount = Integer.parseInt(String.valueOf(between_days)) + 2;
//                  }
//                  if (TOTAL_COUNTS_DISPLAY_N.equals(totalCountH)) {
//                    for (int i = 0; i < dateCount - 1; i++) {
//                      Date date = bef.getTime();
//                      suppLiesLst.add(sdf.format(date));
//                      bef.add(Calendar.DATE, 1);
//                    }
//                  } else {
//                    for (int i = 0; i < dateCount; i++) {
//                      if (dateCount - 1 != i) {
//                        Date date = bef.getTime();
//                        suppLiesLst.add(sdf.format(date));
//                        bef.add(Calendar.DATE, 1);
//                      } else {
//                        suppLiesLst.add("合計");
//                      }
//                    }
//                  }
//                // add #11293 水質検査帳票の課題対応 limingzhe start
//                }
//                // add #11293 水質検査帳票の課題対応 limingzhe end
//              }
//              if (reportV2.equals(dataCode)) {
//                for (Map<String, Object> item : filteredList) {
//                  suppLiesLst.add(item.get(dataCode).toString());
//                }
//              }
//              if (reportH2.equals(dataCode)) {
//                for (Map<String, Object> item : filteredList) {
//                  if (item.get(dataCode) != null) {
//                    suppLiesLst.add(item.get(dataCode).toString());
//                  }
//                }
//              }
//              // add #11293 【標準帳票】水質検査帳票の課題対応 吉 start
//              if (sqlCode != 127L) {
//                // add #11293 【標準帳票】水質検査帳票の課題対応 吉 end
//                suppLiesLst = suppLiesLst.stream().distinct().collect(Collectors.toList());
//                // add #11293 【標準帳票】水質検査帳票の課題対応 吉 start
//              }
//              // add #11293 【標準帳票】水質検査帳票の課題対応 吉 end
//              // 1ページの繰り返し件数を取得する
//              ReportXmlGroup group = param.getReportXmlGroup();
//              Integer repeatOfPage;
//              if (group != null && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_YES) {
//                repeatOfPage = (suppLiesLst.size() > group.getRepeatMax()) ? group.getRepeatMax() : suppLiesLst.size();
//              } else if (group != null && group.getIsNewPage() != ReportXmlGroup.IS_NEW_PAGE_YES) {
//                repeatOfPage = (suppLiesLst.size() > group.getRepeatMax()) ? group.getRepeatMax() : suppLiesLst.size();
//              } else {
//                repeatOfPage = suppLiesLst.size();
//              }
//              // ページ数分、以下の処理を行う
//              int limitCount = repeatOfPage;
//              for (Integer pageLoopCount = 0; pageLoopCount < pageCountMap.get("COUNT_PAGE"); pageLoopCount++) {
//                int skipCount = pageLoopCount * limitCount;
//                // id属性値をkey、出力値をvalue に設定する（複数項目の場合、id属性値に連番を付加する）
//                List<String> outputInfos = suppLiesLst.stream().skip(skipCount).limit(limitCount).collect(toList());
//                if (outputInfos.size() == 0) {
//                  continue;
//                }
//                List<ReportXmlFilterTable> filters = param.getReportXmlFilters();
//                Integer loopKbn = 0;
//                if ("N".equals(direction)) {
//                  loopKbn = pageCountMap.get("COUNT_PAGE_LINE");
//                  if (reportV.equals(dataCode)) {
//                    for (Integer pageLoop = pageLoopCount; pageLoop < pageCountMap.get("COUNT_PAGE"); pageLoop = pageLoop + loopKbn) {
//                      int n = (pageLoopCount % loopKbn) * repeatOfPage;
//                      for (Integer i = 0; i < repeatOfPage; i++) {
//                        String pageStr = String.format("%d%s", pageLoop + 1, MULTIPLE_PAGES_SEPARATOR);
//                        String key = String.format("%s%s-%d", pageStr, param.getId(), n + 1);
//                        if (i >= outputInfos.size()) {
//                          result.put(key, "");
//                          n = n + 1;
//                          continue;
//                        }
//                        String outputData = String.valueOf(outputInfos.get(i));
//                        if (filters == null || filters.size() == 0 || (outputData.equals(filters.get(0).getCode()) && !outputData.isEmpty())) {
//                          String value = reportServiceImpl.formatValue(param, outputInfos.get(i));
//                          value = reportServiceImpl.convertValue(param, value);
//                          if (value != null && !"null".equals(value)) {
//                            // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
//                            // result.put(key, addLineBreak(value, param.getDispLength(), param.getDataType()));
//                            result.put(key, reportServiceImpl.addLineBreak(value, param));
//                            // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
//                          } else {
//                            result.put(key, "");
//                          }
//                          n = n + 1;
//                        }
//                      }
//                    }
//                  } else if (reportV2.equals(dataCode)) {
//                    if ("reg_order_class".equals(dataCode)) {
//                      Map<String, String> result1 = new HashMap<String, String>();
//                      result1.putAll(result);
//                      Set<String> set = result1.keySet();
//                      String value = "";
//                      strKurNameList.clear();
//                      Collections.sort(outputInfos);
//                      if ("0".equals(outputInfos.get(0))) {
//                        outputInfos.remove(0);
//                        outputInfos.add("0");
//                      }
//                      repeatOfPage = 0;
//                      for (String s : set) {
//                        if (result1.get(s).equals("合計") == false && result1.get(s).contains("/")) {
//                          repeatOfPage++;
//                        }
//                      }
//                      if (repeatOfPage != outputInfos.size()) {
//                        repeatOfPage = repeatOfPage * outputInfos.size();
//                      }
//                      int n = 0;
//                      for (Integer pageLoop = 0; pageLoop < pageCountMap.get("COUNT_PAGE"); pageLoop++) {
//                        for (Integer i = 0; i < repeatOfPage; i++) {
//                          if (i == group.getRepeatMax()) {
//                            repeatOfPage -= i;
//                            break;
//                          }
//                          String pageStr = String.format("%d%s", pageLoop + 1, MULTIPLE_PAGES_SEPARATOR);
//                          String key = String.format("%s%s-%d", pageStr, param.getId(), n + 1);
//                          String outputData = String.valueOf(outputInfos.get(n % outputInfos.size()));
//                          if (filters == null || filters.size() == 0 || (outputData.equals(filters.get(0).getCode()) && !outputData.isEmpty())) {
//                            value = reportServiceImpl.formatValue(param, outputData);
//                            value = reportServiceImpl.convertValue(param, value);
//                            if (value != null && !"null".equals(value)) {
//                              // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
//                              // result.put(key, addLineBreak(value, param.getDispLength(), param.getDataType()));
//                              result.put(key, reportServiceImpl.addLineBreak(value, param));
//                              // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
//                              if (outputInfos.size() != strKurNameList.size()) {
//                                strKurNameList.add(value);
//                              }
//                            } else {
//                              result.put(key, "");
//                            }
//                            n = n + 1;
//                          }
//                        }
//                      }
//                    } else {
//                      for (Integer pageLoop = pageLoopCount; pageLoop < pageCountMap.get("COUNT_PAGE"); pageLoop = pageLoop + loopKbn) {
//                        int n = (pageLoopCount % loopKbn) * repeatOfPage;
//                        for (Integer i = 0; i < repeatOfPage; i++) {
//                          String pageStr = String.format("%d%s", pageLoop + 1, MULTIPLE_PAGES_SEPARATOR);
//                          String key = String.format("%s%s-%d", pageStr, param.getId(), n + 1);
//                          if (i >= outputInfos.size()) {
//                            result.put(key, "");
//                            n = n + 1;
//                            continue;
//                          }
//                          String outputData = String.valueOf(outputInfos.get(i));
//                          if (filters == null || filters.size() == 0 || (outputData.equals(filters.get(0).getCode()) && !outputData.isEmpty())) {
//                            String value = reportServiceImpl.formatValue(param, outputInfos.get(i));
//                            value = reportServiceImpl.convertValue(param, value);
//                            if (value != null && !"null".equals(value)) {
//                              // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
//                              // result.put(key, addLineBreak(value, param.getDispLength(), param.getDataType()));
//                              result.put(key, reportServiceImpl.addLineBreak(value, param));
//                              // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
//                            } else {
//                              result.put(key, "");
//                            }
//                            n = n + 1;
//                          }
//                        }
//                      }
//                    }
//                  } else if (reportH.equals(dataCode)) {
//                    for (Integer pageLoop = pageLoopCount * loopKbn;
//                         pageLoop < pageCountMap.get("COUNT_PAGE") && pageLoop < (pageLoopCount + 1) * loopKbn;
//                         pageLoop++) {
//                      int n = skipCount;
//                      for (Integer i = 0; i < repeatOfPage; i++) {
//                        String pageStr = String.format("%d%s", pageLoop + 1, MULTIPLE_PAGES_SEPARATOR);
//                        String key = String.format("%s%s-%d", pageStr, param.getId(), n + 1);
//                        if (i >= outputInfos.size()) {
//                          result.put(key, "");
//                          n = n + 1;
//                          continue;
//                        }
//                        String outputData = String.valueOf(outputInfos.get(i));
//                        if (filters == null || filters.size() == 0 || (outputData.equals(filters.get(0).getCode()) && !outputData.isEmpty())) {
//                          String value = reportServiceImpl.formatValue(param, outputInfos.get(i));
//                          value = reportServiceImpl.convertValue(param, value);
//                          if (value != null && !"null".equals(value)) {
//                            // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
//                            // result.put(key, addLineBreak(value, param.getDispLength(), param.getDataType()));
//                            result.put(key, reportServiceImpl.addLineBreak(value, param));
//                            // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
//                          } else {
//                            result.put(key, "");
//                          }
//                          n = n + 1;
//                        }
//                      }
//                    }
//                  } else if (reportH2.equals(dataCode)) {
//                    Map<String, String> result1 = new HashMap<String, String>();
//                    result1.putAll(result);
//                    Set<String> set = result1.keySet();
//                    String value = "";
//                    strKurNameList.clear();
//                    Collections.sort(outputInfos);
//                    if (sqlCode == 197L) {
//                      if ("0".equals(outputInfos.get(0))) {
//                        outputInfos.remove(0);
//                        outputInfos.add("0");
//                      }
//                    }
//                    repeatOfPage = 0;
//                    for (String s : set) {
//                      if (result1.get(s).equals("合計") == false && result1.get(s).contains("/")) {
//                        repeatOfPage++;
//                      }
//                    }
//                    if (repeatOfPage != outputInfos.size() || sqlCode == 197L) {
//                      repeatOfPage = repeatOfPage * outputInfos.size();
//                    }
//                    int n = 0;
//                    for (Integer pageLoop = 0; pageLoop < pageCountMap.get("COUNT_PAGE"); pageLoop++) {
//                      for (Integer i = 0; i < repeatOfPage; i++) {
//                        if (i == group.getRepeatMax()) {
//                          repeatOfPage -= i;
//                          break;
//                        }
//                        String pageStr = String.format("%d%s", pageLoop + 1, MULTIPLE_PAGES_SEPARATOR);
//                        String key = String.format("%s%s-%d", pageStr, param.getId(), n + 1);
//                        String outputData = String.valueOf(outputInfos.get(n % outputInfos.size()));
//                        if (filters == null || filters.size() == 0 || (outputData.equals(filters.get(0).getCode()) && !outputData.isEmpty())) {
//                          value = reportServiceImpl.formatValue(param, outputData);
//                          value = reportServiceImpl.convertValue(param, value);
//                          if (value != null && !"null".equals(value)) {
//                            // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
//                            // result.put(key, addLineBreak(value, param.getDispLength(), param.getDataType()));
//                            result.put(key, reportServiceImpl.addLineBreak(value, param));
//                            // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
//                            if (outputInfos.size() != strKurNameList.size()) {
//                              strKurNameList.add(value);
//                            }
//                          } else {
//                            result.put(key, "");
//                          }
//                          n = n + 1;
//                        }
//                      }
//                    }
//                  }
//                } else {
//                  loopKbn = pageCountMap.get("COUNT_PAGE_ROW");
//                  if (reportV.equals(dataCode)) {
//                    for (Integer pageLoop = pageLoopCount * loopKbn;
//                         pageLoop < pageCountMap.get("COUNT_PAGE") && pageLoop < (pageLoopCount + 1) * loopKbn;
//                         pageLoop++) {
//                      int n = skipCount;
//                      for (Integer i = 0; i < repeatOfPage; i++) {
//                        String pageStr = String.format("%d%s", pageLoop + 1, MULTIPLE_PAGES_SEPARATOR);
//                        String key = String.format("%s%s-%d", pageStr, param.getId(), n + 1);
//                        if (i >= outputInfos.size()) {
//                          result.put(key, "");
//                          n = n + 1;
//                          continue;
//                        }
//                        String outputData = String.valueOf(outputInfos.get(i));
//                        if (filters == null || filters.size() == 0 || (outputData.equals(filters.get(0).getCode()) && !outputData.isEmpty())) {
//                          String value = reportServiceImpl.formatValue(param, outputInfos.get(i));
//                          value = reportServiceImpl.convertValue(param, value);
//                          if (value != null && !"null".equals(value)) {
//                            // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
//                            // result.put(key, addLineBreak(value, param.getDispLength(), param.getDataType()));
//                            result.put(key, reportServiceImpl.addLineBreak(value, param));
//                            // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
//                          } else {
//                            result.put(key, "");
//                          }
//                          n = n + 1;
//                        }
//                      }
//                    }
//                  } else if (reportV2.equals(dataCode)) {
//                    for (Integer pageLoop = pageLoopCount * loopKbn;
//                         pageLoop < pageCountMap.get("COUNT_PAGE") && pageLoop < (pageLoopCount + 1) * loopKbn;
//                         pageLoop++) {
//                      int n = skipCount;
//                      for (Integer i = 0; i < repeatOfPage; i++) {
//                        String pageStr = String.format("%d%s", pageLoop + 1, MULTIPLE_PAGES_SEPARATOR);
//                        String key = String.format("%s%s-%d", pageStr, param.getId(), n + 1);
//                        if (i >= outputInfos.size()) {
//                          result.put(key, "");
//                          n = n + 1;
//                          continue;
//                        }
//                        String outputData = String.valueOf(outputInfos.get(i));
//                        if (filters == null || filters.size() == 0 || (outputData.equals(filters.get(0).getCode()) && !outputData.isEmpty())) {
//                          String value = reportServiceImpl.formatValue(param, outputInfos.get(i));
//                          value = reportServiceImpl.convertValue(param, value);
//                          if (value != null && !"null".equals(value)) {
//                            // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
//                            // result.put(key, addLineBreak(value, param.getDispLength(), param.getDataType()));
//                            result.put(key, reportServiceImpl.addLineBreak(value, param));
//                            // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
//                          } else {
//                            result.put(key, "");
//                          }
//                          n = n + 1;
//                        }
//                      }
//                    }
//                  } else if (reportH.equals(dataCode)) {
//                    for (Integer pageLoop = pageLoopCount; pageLoop < pageCountMap.get("COUNT_PAGE"); pageLoop = pageLoop + loopKbn) {
//                      int n = (pageLoopCount % loopKbn) * repeatOfPage;
//                      for (Integer i = 0; i < repeatOfPage; i++) {
//                        String pageStr = String.format("%d%s", pageLoop + 1, MULTIPLE_PAGES_SEPARATOR);
//                        String key = String.format("%s%s-%d", pageStr, param.getId(), n + 1);
//                        if (i >= outputInfos.size()) {
//                          result.put(key, "");
//                          n = n + 1;
//                          continue;
//                        }
//                        String outputData = String.valueOf(outputInfos.get(i));
//                        if (filters == null || filters.size() == 0 || (outputData.equals(filters.get(0).getCode()) && !outputData.isEmpty())) {
//                          String value = reportServiceImpl.formatValue(param, outputInfos.get(i));
//                          value = reportServiceImpl.convertValue(param, value);
//                          if (value != null && !"null".equals(value)) {
//                            // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
//                            // result.put(key, addLineBreak(value, param.getDispLength(), param.getDataType()));
//                            result.put(key, reportServiceImpl.addLineBreak(value, param));
//                            // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
//                          } else {
//                            result.put(key, "");
//                          }
//                          n = n + 1;
//                        }
//                      }
//                    }
//                  } else if (reportH2.equals(dataCode)) {
//                    for (Integer pageLoop = pageLoopCount; pageLoop < pageCountMap.get("COUNT_PAGE"); pageLoop = pageLoop + loopKbn) {
//                      int n = (pageLoopCount % loopKbn) * repeatOfPage;
//                      for (Integer i = 0; i < repeatOfPage; i++) {
//                        String pageStr = String.format("%d%s", pageLoop + 1, MULTIPLE_PAGES_SEPARATOR);
//                        String key = String.format("%s%s-%d", pageStr, param.getId(), n + 1);
//                        if (i >= outputInfos.size()) {
//                          result.put(key, "");
//                          n = n + 1;
//                          continue;
//                        }
//                        String outputData = String.valueOf(outputInfos.get(i));
//                        if (filters == null || filters.size() == 0 || (outputData.equals(filters.get(0).getCode()) && !outputData.isEmpty())) {
//                          String value = reportServiceImpl.formatValue(param, outputInfos.get(i));
//                          value = reportServiceImpl.convertValue(param, value);
//                          if (value != null && !"null".equals(value)) {
//                            // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
//                            // result.put(key, addLineBreak(value, param.getDispLength(), param.getDataType()));
//                            result.put(key, reportServiceImpl.addLineBreak(value, param));
//                            // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
//                          } else {
//                            result.put(key, "");
//                          }
//                          n = n + 1;
//                        }
//                      }
//                    }
//                  }
//                }
//              }
//            }
//            if (mstReport.getReportClass() == 11 && finalDataKeyValues.size() > 0) {
//              if ("pat_last_name".equals(dataCode) || "first_name_is_same".equals(dataCode) || "pat_name".equals(dataCode)) {
//                String valueA = reportServiceImpl.formatValue(param, finalDataKeyValues.get(param.getDataCode()));
//                valueA = reportServiceImpl.convertValue(param, valueA);
//                if ("first_name_is_same".equals(param.getDataCode())) {
//                  valueA = finalDataKeyValues.get("pat_last_name") + " " + valueA;
//                }
//                if (valueA != null && !"".equals(valueA)) {
//                  // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
//                  // result.put(param.getId() + "-1", addLineBreak(valueA, param.getDispLength(), param.getDataType()));
//                  result.put(param.getId() + "-1", reportServiceImpl.addLineBreak(valueA, param));
//                  // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
//                } else {
//                  result.put(param.getId() + "-1", "");
//                }
//              }
//            }
//          });
//        groupedParam.getValue().stream()
//          .filter(param -> !StringUtils.isEmpty(param.getGroupId()) && param.isTmplRepeat())
//          .forEach(param -> {
//            List<Map<String, Object>> filteredList = reportServiceImpl.filterReportInfo(param, tmpList);
//            if (filteredList.isEmpty()) {
//              EventLogMessage eventLogMessage = new EventLogMessage();
//              eventLogMessage.setLogMessage("帳票：フィルタ結果した結果が空");
//              logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
//              return;
//            }
//            ReportXmlGroup group = param.getReportXmlGroup();
//            Integer repeatOfPage;
//            if (group != null && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_YES) {
//              repeatOfPage = (filteredList.size() > group.getRepeatMax()) ? group.getRepeatMax() : filteredList.size();
//            } else {
//              repeatOfPage = filteredList.size();
//            }
//            int limitCount = repeatOfPage;
//            Integer repeatMax = (group != null && group.getRepeatMax() != null) ? group.getRepeatMax() : 1;
//            for (Integer pageCount = 0; pageCount <= (filteredList.size() / repeatOfPage); pageCount++) {
//              int skipCount = pageCount * limitCount;
//              List<Map<String, Object>> outputInfos = filteredList.stream().skip(skipCount).limit(limitCount).collect(toList());
//              int n = 0;
//              List<ReportXmlFilterTable> filters = param.getReportXmlFilters();
//              for (Integer i = 0; i < outputInfos.size(); i++) {
//                if (n >= repeatMax) {
//                  break;
//                }
//                String outputData = "";
//                String mainteLayoutCd = "";
//                String mainteRecordCd = "";
//                String mainteUseCd = "";
//                String mainteDate = "";
//                if (mstReport.getExtractionCondition() != null) {
//                  mainteLayoutCd = mstReport.getExtractionCondition().getLayoutCD();
//                  mainteRecordCd = mstReport.getExtractionCondition().getRecordCD();
//                  mainteUseCd = mstReport.getExtractionCondition().getUseCD();
//                  mainteDate = (String) dataKeyOutTempl.get(ReportConstant.ReportDataKey.DATE);
//                }
//                if (!mainteLayoutCd.isEmpty()) {
//                  if (!DateFormat(String.valueOf(outputInfos.get(i).get("mainte_date"))).equals(mainteDate)) {
//                    continue;
//                  }
//                  if (String.valueOf(outputInfos.get(i).get("mainte_layout_cd")).equals(mainteLayoutCd)) {
//                    if ("2".equals(mainteUseCd)) {
//                      if (String.valueOf(outputInfos.get(i).get("tabindex")).equals(mainteRecordCd)) {
//                        outputData = String.valueOf(outputInfos.get(i).get("mainte_detail_cd"));
//                      }
//                    } else {
//                      outputData = String.valueOf(outputInfos.get(i).get("mainte_detail_cd"));
//                    }
//                  }
//                } else {
//                  Set<String> keysSet = outputInfos.get(i).keySet();
//                  if (!keysSet.isEmpty()) {
//                    String key = keysSet.toArray(new String[0])[0];
//                    outputData = String.valueOf(outputInfos.get(i).get(key));
//                  }
//                }
//                if (filters == null || filters.size() == 0 || (outputData.equals(filters.get(0).getCode()) && !outputData.isEmpty())) {
//                  String pageStr = String.format("%d%s", pageCount + 1, MULTIPLE_PAGES_SEPARATOR);
//                  String key = String.format("%s%s-%d", pageStr, param.getId(), n + 1);
//                  String value = reportServiceImpl.formatValue(param, outputInfos.get(i).get(param.getDataCode()));
//                  value = reportServiceImpl.convertValue(param, value);
//                  if (value != null && !"null".equals(value)) {
//                    // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
//                    // result.put(key, addLineBreak(value, param.getDispLength(), param.getDataType()));
//                    result.put(key, reportServiceImpl.addLineBreak(value, param));
//                    // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
//                  } else {
//                    result.put(key, "");
//                  }
//                  n = n + 1;
//                }
//              }
//            }
//          });
//        // テンプレート繰り返しに対する処理を行う
//        groupedParam.getValue().stream()
//          .filter(param -> param.isTmplRepeat())
//          .forEach(param -> {
//            int startPrintPos = 1;
//            if (reportOutputInfo.get(0l).get(0).get("stPos") != null) {
//              startPrintPos = (int) reportOutputInfo.get(0l).get(0).get("stPos");
//            }
//            convertDataCodeToIdRepeatTmpl(result, tmpList, param, startPrintPos, false);
//          });
//        if (sqlCode == 127L) {
//          String strID = "";
//          String dispid = "";
//          String machineid = "";
//          String typeid = "";
//          String pointid = "";
//          Map<String, String> newresult = new HashMap<>();
//          for (int i = 0; i < groupedParam.getValue().size(); i++) {
//            if ("point_disp_order".equals(groupedParam.getValue().get(i).getDataCode())) {
//              dispid = groupedParam.getValue().get(i).getId();
//            }
//            if ("machine_name".equals(groupedParam.getValue().get(i).getDataCode())) {
//              machineid = groupedParam.getValue().get(i).getId();
//            }
//            if ("survey_type_name".equals(groupedParam.getValue().get(i).getDataCode())) {
//              typeid = groupedParam.getValue().get(i).getId();
//            }
//            if ("point_name".equals(groupedParam.getValue().get(i).getDataCode())) {
//              pointid = groupedParam.getValue().get(i).getId();
//            }
//          }
//          for (Map.Entry entry : result.entrySet()) {
//            for (int j = 0; j < tmpList.size(); j++) {
//              if (entry.getValue().equals(tmpList.get(j).get("point_name"))) {
//                String key = "";
//                key = entry.getKey().toString().replace(pointid, dispid);
//                newresult.put(key, tmpList.get(j).get("point_disp_order").toString());
//                key = entry.getKey().toString().replace(pointid, machineid);
//                newresult.put(key, tmpList.get(j).get("machine_name").toString());
//                key = entry.getKey().toString().replace(pointid, typeid);
//                newresult.put(key, tmpList.get(j).get("survey_type_name").toString());
//                break;
//              }
//            }
//          }
//          for (Map.Entry entry : newresult.entrySet()) {
//            result.put(entry.getKey().toString(), entry.getValue().toString());
//          }
//        }
//      }
//    });
//    // add 10546 複数集計出力時にサーバが高負荷になる gjn start
//    // 実際の改ページ数,改ページの正確性を計算するために、ここで及び2回の検証を行った
//    if ("1".equals(isNewPage)) {
//      System.err.println("********************************");
//      System.err.println("実際の改ページ数：" + pageCountMap.get("COUNT_PAGE"));
//      System.err.println("********************************");
//      if (pageCountMap.get("COUNT_PAGE") > SET_MAX_PAGE) {
//        // 指定例外のスロー、メッセージの指定を促す
//        throw new NtssException("ExceedingMaxPageSetting," + pageCountMap.get("COUNT_PAGE"));
//      }
//    } else {
//      System.err.println("********************************");
//      System.err.println("実際の改ページ数：" + 1);
//      System.err.println("********************************");
//    }
//    // add #11103 カテゴリ「印刷情報」の項目追加と修正 sunsy start
//    int totalPages = 0;
//    for (String key : result.keySet()) {
//      if (key.contains("#")) {
//        int resultPageCount = Integer.parseInt(key.split("#")[0]);
//        totalPages = resultPageCount > totalPages ? resultPageCount : totalPages;
//      }
//    }
//    for (ReportXmlParam reportXmlParam : params) {
//      if (ReportConstant.ReportDataKey.currentPage.equals(reportXmlParam.getDataCode())) {
//        if(totalPages > 0) result.remove(reportXmlParam.getId());
//        for (int i = 1; i <= totalPages ; i++) {
//          result.put(String.format("%d%s%s-%s",i,MULTIPLE_PAGES_SEPARATOR,reportXmlParam.getId(),"1"),String.valueOf(i));
//        }
//      } else if (ReportConstant.ReportDataKey.totalPages.equals(reportXmlParam.getDataCode())) {
//        if(totalPages > 0) result.remove(reportXmlParam.getId());
//        for (int i = 1; i <= totalPages ; i++) {
//          result.put(String.format("%d%s%s-%s",i,MULTIPLE_PAGES_SEPARATOR,reportXmlParam.getId(),"1"),String.valueOf(totalPages));
//        }
//      }
//    }
//    return result;
//  }
//
//
//  /***
//   *　横の集計単位の編集処理
//   * out_pat_cnt
//   * hosp_pat_cnt
//   * total_unitH
//   * @param result         　　データを表示
//   * @param groupedParams   　　xml情報
//   * @param reportOutputInfo　　データを
//   * @param dataKeyOutTempl     基本情報
//   * @param reportH             横集計
//   * @param mstReport           帳票情報
//   */
//  private void outCompute(Map<String, String> result
//    , Map<String, List<ReportXmlParam>> groupedParams
//    , Map<Long, List<Map<String, Object>>> reportOutputInfo
//    , Map<String, Object> dataKeyOutTempl
//    , String reportH
//    , MstReport mstReport
//    // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen start
//    // , Map<String, Integer> pageCountMap) {
//    , Map<String, Integer> pageCountMap
//    , Map<String, String> param2) {
//    String totalCountH = param2.get("totalCountH");
//    String totalUnitDate = param2.get("totalUnitDate");
//    // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen end
//    // ページ数を取得する
//    Integer pageCount = pageCountMap.get("COUNT_PAGE");
//    List<String> unitVsLst = new ArrayList<>();
////del #11054 データクラス「週間.医材(分解)」の追加 杜 start
////    if (reportOutputInfo.get(149L) != null) {
////      for (Map<String, Object> item : reportOutputInfo.get(149L)) {
////        if (!StringUtils.isEmpty(item.get("supplies_name"))) {
////          unitVsLst.add(item.get("supplies_name").toString());
////        }
////      }
////      unitVsLst = unitVsLst.stream().distinct().collect(Collectors.toList());
////      if (unitVsLst.size() > repeatCountV.get() && pageCount == 1) {
////        pageCount = (int) Math.ceil((float) (unitVsLst.size()) / repeatCountV.get());
////      }
////    }
////    List<String> finalUnitVsLst = unitVsLst;
////    Integer finalPageCount = pageCount;
////del #11054 データクラス「週間.医材(分解)」の追加 杜 end
//    // 列、行のヘーダを取得する。
//    List<String> suppLiesLst = new ArrayList<>();
//    //add #11054 データクラス「週間.医材(分解)」の追加 杜 start
//    AtomicReference<Long> sqlCode = new AtomicReference<>(0L);
//    groupedParams.entrySet().forEach(groupedParam -> {
//        groupedParam.getValue().stream()
//          .filter(param -> !StringUtils.isEmpty(param.getGroupId()) && !param.isTmplRepeat())
//          .forEach(param -> {
//            String dataCode = param.getDataCode(); //　日付を集計
//            if (reportH.equals(dataCode)) {
//              if("149".equals(param.getSqlCode())|| "230".equals(param.getSqlCode())) {
//                sqlCode.set(Long.valueOf(param.getSqlCode()));
//              }
//              // 時間転換処理
//              SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
//              Calendar bef = Calendar.getInstance();
//              Calendar aft = Calendar.getInstance();
//              try {
//                bef.setTime(sdf.parse(dataKeyOutTempl.get("fromDate").toString().replace("/", "")));
//                aft.setTime(sdf.parse(dataKeyOutTempl.get("toDate").toString()));
//              } catch (ParseException e) {
//                e.printStackTrace();
//              }
//              int monthSection = aft.get(Calendar.MONTH) - bef.get(Calendar.MONTH);
//              int yearSection = aft.get(Calendar.YEAR) - bef.get(Calendar.YEAR);
//              // 集計単位日付属性により、配列の縦列サイズを計算する。
//              int dateCount = 0;
//              if ("月".equals(totalUnitDate)) {
//                if (yearSection <= 0) {
//                  dateCount = monthSection + 2;
//                } else {
//                  dateCount = 12 * yearSection + monthSection + 2;
//                }
//              } else if ("年".equals(totalUnitDate)) {
//                dateCount = yearSection + 2;
//              } else {
//                // ”日”指定の場合、日付差を計算後で設定する。
//                long time1 = bef.getTimeInMillis();
//                long time2 = aft.getTimeInMillis();
//                long between_days = (time2 - time1) / (1000 * 3600 * 24);
//                dateCount = Integer.parseInt(String.valueOf(between_days)) + 2;
//              }
//              for (int i = 0; i < dateCount; i++) {
//                if (dateCount - 1 != i) {
//                  Date date = bef.getTime();
//                  suppLiesLst.add(sdf.format(date));
//                  bef.add(Calendar.DATE, 1);
//                } else {
//                  if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                    suppLiesLst.add("合計");
//                  }
//                }
//              }
//            }
//          });
//      });
//    //add #11054 データクラス「週間.医材(分解)」の追加 杜 end
//     int[] totalHNum = new int[1];
//     int[] totalVNum = new int[1];
//    totalVNum[0] = 1;
//    totalHNum[0] = 1;
//    //add #11054 データクラス「週間.医材(分解)」の追加 杜 start
//    if (reportOutputInfo.get(Long.parseLong(String.valueOf(sqlCode))) != null) {
//      for (Map<String, Object> item : reportOutputInfo.get(Long.parseLong(String.valueOf(sqlCode)))) {
//        if (!StringUtils.isEmpty(item.get("supplies_name"))) {
//          unitVsLst.add(item.get("supplies_name").toString());
//        }
//      }
//      unitVsLst = unitVsLst.stream().distinct().collect(Collectors.toList());
//      if (unitVsLst.size() > repeatCountV.get() && pageCount == 1) {
//        pageCount = (int) Math.ceil((float) (unitVsLst.size()) / repeatCountV.get());
//      }
//    }
//    List<String> finalUnitVsLst = unitVsLst;
//    //add #11054 データクラス「週間.医材(分解)」の追加 杜 end
////add #10998 「週間.医材」の出力内容修正 杜 end
//    groupedParams.entrySet().forEach(groupedParam -> {
//      Long sqlCodes;
//      if (null != groupedParam.getKey() && groupedParam.getKey().equals("")) {
//        sqlCodes = 0L;
//      } else if("149".equals(groupedParam.getKey())|| "230".equals(groupedParam.getKey())) {
//        sqlCodes=Long.parseLong(String.valueOf(sqlCode));
//      }else{
//        sqlCodes = Long.parseLong(groupedParam.getKey());
//      }
//      // sqlCodeをもとに出力情報を取得する
//      List<Map<String, Object>> tmpList = reportOutputInfo.get(sqlCodes);
////add #10998 「週間.医材」の出力内容修正 杜 start
//        groupedParam.getValue().stream()
//          .filter(param -> !StringUtils.isEmpty(param.getGroupId()) && !param.isTmplRepeat())
//          .forEach(param -> {
//            String dataCode = param.getDataCode(); //　日付を集計
//    //del #11054 データクラス「週間.医材(分解)」の追加 杜 start
////            if (reportH.equals(dataCode)) {
////              // 時間転換処理
////              SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
////              Calendar bef = Calendar.getInstance();
////              Calendar aft = Calendar.getInstance();
////              try {
////                bef.setTime(sdf.parse(dataKeyOutTempl.get("fromDate").toString().replace("/", "")));
////                aft.setTime(sdf.parse(dataKeyOutTempl.get("toDate").toString()));
////              } catch (ParseException e) {
////                e.printStackTrace();
////              }
////              int monthSection = aft.get(Calendar.MONTH) - bef.get(Calendar.MONTH);
////              int yearSection = aft.get(Calendar.YEAR) - bef.get(Calendar.YEAR);
////              // 集計単位日付属性により、配列の縦列サイズを計算する。
////              int dateCount = 0;
////              if ("月".equals(totalUnitDate)) {
////                if (yearSection <= 0) {
////                  dateCount = monthSection + 2;
////                } else {
////                  dateCount = 12 * yearSection + monthSection + 2;
////                }
////              } else if ("年".equals(totalUnitDate)) {
////                dateCount = yearSection + 2;
////              } else {
////                // ”日”指定の場合、日付差を計算後で設定する。
////                long time1 = bef.getTimeInMillis();
////                long time2 = aft.getTimeInMillis();
////                long between_days = (time2 - time1) / (1000 * 3600 * 24);
////                dateCount = Integer.parseInt(String.valueOf(between_days)) + 2;
////              }
////              for (int i = 0; i < dateCount; i++) {
////                if (dateCount - 1 != i) {
////                  Date date = bef.getTime();
////                  suppLiesLst.add(sdf.format(date));
////                  bef.add(Calendar.DATE, 1);
////                } else {
////                  if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
////                    suppLiesLst.add("合計");
////                  }
////                }
////              }
////            }
//    //del #11054 データクラス「週間.医材(分解)」の追加 杜 end
//            try {
//              if ("total_unitH".equals(dataCode)) {
//                int[] total_unith_arr = new int[suppLiesLst.size()];
//                for (int i = 0; i < suppLiesLst.size(); i++) {
//                  for (int j = 0; j < tmpList.size(); j++) {
//                    if (suppLiesLst.get(i).equals(tmpList.get(j).get("supplies_base_date")) && (!"".equals(tmpList.get(j).get("supplies_name")))) {
//                      total_unith_arr[i] += Double.valueOf(StringUtils.isEmpty(tmpList.get(j).get("ind_rst_value")) ?
//                        "0" : (tmpList.get(j).get("ind_rst_value").toString())).intValue();
//                    } else {
//                      total_unith_arr[i] += 0;
//                    }
//                  }
//                }
//                if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                  if (suppLiesLst.contains("合計")) {
//                    int total = 0;
//                    for (int z = 0; z < total_unith_arr.length; z++) {
//                      total += (int) total_unith_arr[z];
//                    }
//                    total_unith_arr[total_unith_arr.length - 1] = total;
//                  }
//                }
//                if(param.getReportXmlGroup().getRepeatMax() < total_unith_arr.length) {
//                  int pageNum = total_unith_arr.length / param.getReportXmlGroup().getRepeatMax();
//                  int isLastPag = total_unith_arr.length % param.getReportXmlGroup().getRepeatMax();
//                  totalHNum[0] = isLastPag == 0 ? pageNum : pageNum+1;
//                }
//                //mod #10998 「週間.医材」の出力内容修正 杜 end
//              } else if ("out_pat_cnt".equals(dataCode)) {
//                int[] out_pat_cnt_arr = new int[suppLiesLst.size()];
//                for (int i = 0; i < suppLiesLst.size(); i++) {
//                  for (int j = 0; j < tmpList.size(); j++) {
//                    if (suppLiesLst.get(i).equals(tmpList.get(j).get("reg_date"))) {
//                      out_pat_cnt_arr[i] = Integer.parseInt(tmpList.get(j).get("out_pat_cnt").toString());
//                    }
//                  }
//                }
//                if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                  if (suppLiesLst.contains("合計")) {
//                    int total = 0;
//                    for (int z = 0; z < out_pat_cnt_arr.length; z++) {
//                      total += (int) out_pat_cnt_arr[z];
//                    }
//                    out_pat_cnt_arr[out_pat_cnt_arr.length - 1] = total;
//                  }
//                }
//                if(param.getReportXmlGroup().getRepeatMax() < out_pat_cnt_arr.length) {
//                  int pageNum = out_pat_cnt_arr.length / param.getReportXmlGroup().getRepeatMax();
//                  int isLastPag = out_pat_cnt_arr.length % param.getReportXmlGroup().getRepeatMax();
//                  totalHNum[0] = isLastPag == 0 ? pageNum : pageNum+1;
//                }
//                //mod #10998 「週間.医材」の出力内容修正 杜 end
//              } else if ("hosp_pat_cnt".equals(dataCode)) {
//                int[] hosp_pat_cnt_arr = new int[suppLiesLst.size()];
//                for (int i = 0; i < suppLiesLst.size(); i++) {
//                  for (int j = 0; j < tmpList.size(); j++) {
//                    if (suppLiesLst.get(i).equals(tmpList.get(j).get("reg_date"))) {
//                      hosp_pat_cnt_arr[i] = Integer.parseInt(tmpList.get(j).get("hosp_pat_cnt").toString());
//                    }
//                  }
//                }
//                if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                  if (suppLiesLst.contains("合計")) {
//                    int total = 0;
//                    for (int z = 0; z < hosp_pat_cnt_arr.length; z++) {
//                      total += (int) hosp_pat_cnt_arr[z];
//                    }
//                    hosp_pat_cnt_arr[hosp_pat_cnt_arr.length - 1] = total;
//                  }
//                }
//                if(param.getReportXmlGroup().getRepeatMax() < hosp_pat_cnt_arr.length) {
//                  int pageNum = hosp_pat_cnt_arr.length / param.getReportXmlGroup().getRepeatMax();
//                  int isLastPag = hosp_pat_cnt_arr.length % param.getReportXmlGroup().getRepeatMax();
//                  totalHNum[0] = isLastPag == 0 ? pageNum : pageNum+1;
//                }
//                //mod #10998 「週間.医材」の出力内容修正 杜 end
//              } else if ("total_unitV".equals(dataCode)) {
//                if (!finalUnitVsLst.isEmpty()) {
//                  int[] total_unith_arr = new int[finalUnitVsLst.size()];
//                  for (int i = 0; i < finalUnitVsLst.size(); i++) {
//                    for (int j = 0; j < tmpList.size(); j++) {
//                      if (finalUnitVsLst.get(i).equals(tmpList.get(j).get("supplies_name"))) {
//                        total_unith_arr[i] += Double.valueOf(StringUtils.isEmpty(tmpList.get(j).get("ind_rst_value")) ?
//                          "0" : (tmpList.get(j).get("ind_rst_value").toString())).intValue();
//                      } else {
//                        total_unith_arr[i] += 0;
//                      }
//                    }
//                  }
//                  int isLastPag = total_unith_arr.length % param.getReportXmlGroup().getRepeatMax();
//                  int pageNum = total_unith_arr.length / param.getReportXmlGroup().getRepeatMax();
//                  totalVNum[0] = isLastPag == 0 ? pageNum : pageNum+1;
//                }
//              }
//            } catch (Exception ex) {
//              EventLogMessage eventLogMessage = new EventLogMessage();
//              eventLogMessage.setLogMessage(ex.getMessage());
//              eventLogMessage.setFacilityCd(mstReport.getFacilityCd());
//              logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
//            }
//          });
////add #10998 「週間.医材」の出力内容修正 杜 end
//
//
//
//
//
//      groupedParam.getValue().stream()
//        .filter(param -> !StringUtils.isEmpty(param.getGroupId()) && !param.isTmplRepeat())
//        .forEach(param -> {
//          // 列、行の区分を取得する。
//          String dataCode = param.getDataCode();
//          try {
//            if ("total_unitH".equals(dataCode)) {
//              //mod 各種医材合計、医材合計が小数点以下のある値を計上していない start 杜
////                int[] total_unith_arr = new int[suppLiesLst.size()];
//              double[] total_unith_arr = new double[suppLiesLst.size()];
//              //mod 各種医材合計、医材合計が小数点以下のある値を計上していない end 杜
//              for (int i = 0; i < suppLiesLst.size(); i++) {
//                for (int j = 0; j < tmpList.size(); j++) {
//                  if (suppLiesLst.get(i).equals(tmpList.get(j).get("supplies_base_date")) && (!"".equals(tmpList.get(j).get("supplies_name")))) {
//                    total_unith_arr[i] += Double.valueOf(StringUtils.isEmpty(tmpList.get(j).get("ind_rst_value")) ?
//                      //mod 各種医材合計、医材合計が小数点以下のある値を計上していない start 杜
////                      "0" : (tmpList.get(j).get("ind_rst_value").toString())).intValue();
//                      "0" : (tmpList.get(j).get("ind_rst_value").toString()));
//                    //mod 各種医材合計、医材合計が小数点以下のある値を計上していない end 杜
//                  } else {
//                    total_unith_arr[i] += 0;
//                  }
//                }
//              }
//              if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                if (suppLiesLst.contains("合計")) {
//                  int total = 0;
//                  for (int z = 0; z < total_unith_arr.length; z++) {
//                    total += (int) total_unith_arr[z];
//                  }
//                  total_unith_arr[total_unith_arr.length - 1] = total;
//                }
//              }
//              //mod #10998 「週間.医材」の出力内容修正 杜 start
////                for (int i = 0; i < total_unith_arr.length; i++) {
////                  result.put(finalPageCount + "#" + param.getId() + "-" + (i + 1), String.valueOf(total_unith_arr[i]));
////                }
//              if(param.getReportXmlGroup().getRepeatMax() < total_unith_arr.length) {
//               int pageNum = total_unith_arr.length / param.getReportXmlGroup().getRepeatMax();
//               int isLastPag = total_unith_arr.length % param.getReportXmlGroup().getRepeatMax();
//               for(int j = 0; j < pageNum; j++){
//                 for(int i = 0; i<param.getReportXmlGroup().getRepeatMax(); i++){
//                     result.put((param.getReportXmlTmplRepeat().getDirection().equals("0") ?
//                       (j+1)*totalVNum[0] : (totalHNum[0] *totalVNum[0]- totalHNum[0]+j+1))+ "#" + param.getId() + "-" + (i + 1), String.valueOf(total_unith_arr[(j*param.getReportXmlGroup().getRepeatMax())+i]));
//                 }
//               }
//               if(isLastPag != 0){
//                 for (int i = 0; i < isLastPag; i++) {
//                   result.put(totalHNum[0] *totalVNum[0] + "#" + param.getId() + "-" + (i + 1), String.valueOf(total_unith_arr[pageNum*param.getReportXmlGroup().getRepeatMax()+i]));
//                 }
//               }
//              }else{
//                for (int i = 0; i < total_unith_arr.length; i++) {
//                  result.put(totalVNum[0] + "#" + param.getId() + "-" + (i + 1), String.valueOf(total_unith_arr[i]));
//                }
//              }
//              //mod #10998 「週間.医材」の出力内容修正 杜 end
//            } else if ("out_pat_cnt".equals(dataCode)) {
//              int[] out_pat_cnt_arr = new int[suppLiesLst.size()];
//              for (int i = 0; i < suppLiesLst.size(); i++) {
//                for (int j = 0; j < tmpList.size(); j++) {
//                  if (suppLiesLst.get(i).equals(tmpList.get(j).get("reg_date"))) {
//                    out_pat_cnt_arr[i] = Integer.parseInt(tmpList.get(j).get("out_pat_cnt").toString());
//                  }
//                }
//              }
//              if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                if (suppLiesLst.contains("合計")) {
//                  int total = 0;
//                  for (int z = 0; z < out_pat_cnt_arr.length; z++) {
//                    total += (int) out_pat_cnt_arr[z];
//                  }
//                  out_pat_cnt_arr[out_pat_cnt_arr.length - 1] = total;
//                }
//              }
//
//              //mod #10998 「週間.医材」の出力内容修正 杜 start
////              for (int i = 0; i < out_pat_cnt_arr.length; i++) {
////                result.put(finalPageCount + "#" + param.getId() + "-" + (i + 1), String.valueOf(out_pat_cnt_arr[i]));
////              }
//              if(param.getReportXmlGroup().getRepeatMax() < out_pat_cnt_arr.length) {
//                int pageNum = out_pat_cnt_arr.length / param.getReportXmlGroup().getRepeatMax();
//                int isLastPag = out_pat_cnt_arr.length % param.getReportXmlGroup().getRepeatMax();
//                for(int j = 0; j < pageNum; j++){
//                  for(int i = 0; i<param.getReportXmlGroup().getRepeatMax(); i++){
//                    result.put((param.getReportXmlTmplRepeat().getDirection().equals("0") ?
//                      (j+1)*totalVNum[0] : (totalHNum[0] *totalVNum[0]- totalHNum[0]+j+1))+ "#" + param.getId() + "-" + (i + 1), String.valueOf(out_pat_cnt_arr[(j*param.getReportXmlGroup().getRepeatMax())+i]));
//                  }
//                }
//                if(isLastPag != 0){
//                  for (int i = 0; i < isLastPag; i++) {
//                    result.put(totalHNum[0] *totalVNum[0] + "#" + param.getId() + "-" + (i + 1), String.valueOf(out_pat_cnt_arr[pageNum*param.getReportXmlGroup().getRepeatMax()+i]));
//                  }
//                }
//              }else{
//                for (int i = 0; i < out_pat_cnt_arr.length; i++) {
//                  result.put(totalVNum[0] + "#" + param.getId() + "-" + (i + 1), String.valueOf(out_pat_cnt_arr[i]));
//                }
//              }
//              //mod #10998 「週間.医材」の出力内容修正 杜 end
//            } else if ("hosp_pat_cnt".equals(dataCode)) {
//              int[] hosp_pat_cnt_arr = new int[suppLiesLst.size()];
//              for (int i = 0; i < suppLiesLst.size(); i++) {
//                for (int j = 0; j < tmpList.size(); j++) {
//                  if (suppLiesLst.get(i).equals(tmpList.get(j).get("reg_date"))) {
//                    hosp_pat_cnt_arr[i] = Integer.parseInt(tmpList.get(j).get("hosp_pat_cnt").toString());
//                  }
//                }
//              }
//              if (TOTAL_COUNTS_DISPLAY_Y.equals(totalCountH)) {
//                if (suppLiesLst.contains("合計")) {
//                  int total = 0;
//                  for (int z = 0; z < hosp_pat_cnt_arr.length; z++) {
//                    total += (int) hosp_pat_cnt_arr[z];
//                  }
//                  hosp_pat_cnt_arr[hosp_pat_cnt_arr.length - 1] = total;
//                }
//              }
//
//              //mod #10998 「週間.医材」の出力内容修正 杜 start
////              for (int i = 0; i < hosp_pat_cnt_arr.length; i++) {
////                result.put(finalPageCount + "#" + param.getId() + "-" + (i + 1), String.valueOf(hosp_pat_cnt_arr[i]));
////              }
//              if(param.getReportXmlGroup().getRepeatMax() < hosp_pat_cnt_arr.length) {
//                int pageNum = hosp_pat_cnt_arr.length / param.getReportXmlGroup().getRepeatMax();
//                int isLastPag = hosp_pat_cnt_arr.length % param.getReportXmlGroup().getRepeatMax();
//                for(int j = 0; j < pageNum; j++){
//                  for(int i = 0; i<param.getReportXmlGroup().getRepeatMax(); i++){
//                    result.put((param.getReportXmlTmplRepeat().getDirection().equals("0") ?
//                      (j+1)*totalVNum[0] : (totalHNum[0] *totalVNum[0]- totalHNum[0]+j+1))+ "#" + param.getId() + "-" + (i + 1), String.valueOf(hosp_pat_cnt_arr[(j*param.getReportXmlGroup().getRepeatMax())+i]));
//                  }
//                }
//                if(isLastPag != 0){
//                  for (int i = 0; i < isLastPag; i++) {
//                    result.put(totalHNum[0] *totalVNum[0] + "#" + param.getId() + "-" + (i + 1), String.valueOf(hosp_pat_cnt_arr[pageNum*param.getReportXmlGroup().getRepeatMax()+i]));
//                  }
//                }
//              }else{
//                for (int i = 0; i < hosp_pat_cnt_arr.length; i++) {
//                  result.put(totalVNum[0] + "#" + param.getId() + "-" + (i + 1), String.valueOf(hosp_pat_cnt_arr[i]));
//                }
//              }
//              //mod #10998 「週間.医材」の出力内容修正 杜 end
//            } else if ("total_unitV".equals(dataCode)) {
//              if (!finalUnitVsLst.isEmpty()) {
//                //mod 各種医材合計、医材合計が小数点以下のある値を計上していない start 杜
////                int[] total_unith_arr = new int[finalUnitVsLst.size()];
//                double[] total_unith_arr = new double[finalUnitVsLst.size()];
//                //mod 各種医材合計、医材合計が小数点以下のある値を計上していない end 杜
//                for (int i = 0; i < finalUnitVsLst.size(); i++) {
//                  for (int j = 0; j < tmpList.size(); j++) {
//                    if (finalUnitVsLst.get(i).equals(tmpList.get(j).get("supplies_name"))) {
//                      total_unith_arr[i] += Double.valueOf(StringUtils.isEmpty(tmpList.get(j).get("ind_rst_value")) ?
//                        //mod 各種医材合計、医材合計が小数点以下のある値を計上していない start 杜
////                        "0" : (tmpList.get(j).get("ind_rst_value").toString())).intValue();
//                        "0" : (tmpList.get(j).get("ind_rst_value").toString()));
//                      //mod 各種医材合計、医材合計が小数点以下のある値を計上していない end 杜
//                    } else {
//                      total_unith_arr[i] += 0;
//                    }
//                  }
//                }
////mod #10998 「週間.医材」の出力内容修正 杜 start
////              int n = 1;
//                int n = 0;
//                int isLastPag = total_unith_arr.length % param.getReportXmlGroup().getRepeatMax();
//                int pageNum = total_unith_arr.length / param.getReportXmlGroup().getRepeatMax();
////                for (int i = 0; i < total_unith_arr.length; i++) {
////                  if (i != 0 && (i % repeatCountV.get() == 0)) {
////                  n++;
////                  }
////                  result.put(n + "#" + param.getId() + "-" + (i + 1), String.valueOf(total_unith_arr[i]));
////                }
//                for(int j = 0; j < pageNum; j++){
//                  n = param.getReportXmlTmplRepeat().getDirection().equals("0") ? (totalHNum[0] *totalVNum[0]- totalVNum[0]+j+1) : n+totalHNum[0];
//                  for(int i = 0; i<param.getReportXmlGroup().getRepeatMax(); i++){
//
//                    result.put(n + "#" + param.getId() + "-" + (i + 1), String.valueOf(total_unith_arr[(j*param.getReportXmlGroup().getRepeatMax())+i]));
//
//                  }
//
//                }
//                if(isLastPag != 0){
//                  n = param.getReportXmlTmplRepeat().getDirection().equals("0") ? totalHNum[0] *totalVNum[0]: n+totalHNum[0];
//                  for (int i = 0; i < isLastPag; i++) {
//                    result.put(n + "#" + param.getId() + "-" + (i + 1), String.valueOf(total_unith_arr[pageNum*param.getReportXmlGroup().getRepeatMax()+i]));
//                  }
//                }
////mod #10998 「週間.医材」の出力内容修正 杜 end
//              }
//            }
//          } catch (Exception ex) {
//            EventLogMessage eventLogMessage = new EventLogMessage();
//            eventLogMessage.setLogMessage(ex.getMessage());
//            eventLogMessage.setFacilityCd(mstReport.getFacilityCd());
//            logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
//          }
//        });
//    });
//  }
//
//  /**
//   * ページ数を方法が追加されました。この方法はページ数に対応するだけで、返ってくる結果セットには影響しません。
//   * 7845、6691に対応します
//   *
//   * @param params
//   * @param reportHs
//   * @param reportVs
//   * @param reportOutputInfo
//   * @param dataKeyOutTempl
//   * @param pageCountMap
//   * @return
//   */
//  private Map<String, Integer> pageCountCompute(List<ReportXmlParam> params,
//                                                String[] reportHs,
//                                                String[] reportVs,
//                                                Map<Long, List<Map<String, Object>>> reportOutputInfo,
//                                                Map<String, Object> dataKeyOutTempl,
//    // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen start
//    //                                          Map<String, Integer> pageCountMap) {
//                                                Map<String, Integer> pageCountMap,
//                                                Map<String, String> param2) {
//    // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen end
//    int hsMax = 1;  // 横方向最大記録数
//    int vsMax = 1;  // 縦方向の最大値
//    int hsNumByPage = 1;  // ページあたりに表示される最大数
//    int vsNumByPage = 1;
//    for (ReportXmlParam param : params) {
//      for (String hs : reportHs) {
//        if (hs.equals(param.getDataCode())) {
//          hsNumByPage = param.getReportXmlGroup().getRepeatMax();
//          // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen start
//          // int dataNum = getDataCountNum(hs, param, reportOutputInfo, dataKeyOutTempl);
//          int dataNum = getDataCountNum(hs, param, reportOutputInfo, dataKeyOutTempl, param2);
//          // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen end
//          if ("result_exam_date".equals(hs) || "reg_order_class".equals(hs)) {
//            hsMax *= dataNum;
//          } else {
//            hsMax = dataNum > hsMax ? dataNum : hsMax;
//          }
//          int tempMaxNum = param.getReportXmlGroup().getRepeatMax();
//          hsNumByPage = tempMaxNum > hsNumByPage ? tempMaxNum : hsNumByPage;
//        }
//      }
//      for (String vs : reportVs) {
//        if (vs.equals(param.getDataCode())) {
//          vsNumByPage = param.getReportXmlGroup().getRepeatMax();
//          // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen start
//          // int dataNum = getDataCountNum(vs, param, reportOutputInfo, dataKeyOutTempl);
//          int dataNum = getDataCountNum(vs, param, reportOutputInfo, dataKeyOutTempl, param2);
//          // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen end
//          if ("result_exam_date".equals(vs) || "reg_order_class".equals(vs)) {
//            vsMax *= dataNum;
//          } else {
//            vsMax = dataNum > vsMax ? dataNum : vsMax;
//          }
//          int tempMaxNum = param.getReportXmlGroup().getRepeatMax();
//          vsNumByPage = tempMaxNum > vsNumByPage ? tempMaxNum : vsNumByPage;
//        }
//      }
//    }
//    int COUNT_PAGE_LINE = vsMax / vsNumByPage + ((vsMax % vsNumByPage) > 0 ? 1 : 0);
//    int COUNT_LINE = vsMax;
//    int COUNT_PAGE_ROW = hsMax / hsNumByPage + ((hsMax % hsNumByPage) > 0 ? 1 : 0);
//    int COUNT_ROW = hsMax;
//    int COUNT_PAGE = COUNT_PAGE_LINE * COUNT_PAGE_ROW;
//    pageCountMap.replace("COUNT_PAGE_LINE", COUNT_PAGE_LINE);
//    pageCountMap.replace("COUNT_LINE", COUNT_LINE);
//    pageCountMap.replace("COUNT_PAGE_ROW", COUNT_PAGE_ROW);
//    pageCountMap.replace("COUNT_ROW", COUNT_ROW);
//    pageCountMap.replace("COUNT_PAGE", COUNT_PAGE);
//    return pageCountMap;
//  }
//
//
//  /**
//   * dataCodeから対応するデータセットの数を取得します。
//   * 7845、6691に対応します
//   *
//   * @param dataCode
//   * @param param
//   * @param reportOutputInfo
//   * @param dataKeyOutTempl
//   * @return
//   */
//
//  private int getDataCountNum(String dataCode, ReportXmlParam param,
//                              Map<Long, List<Map<String, Object>>> reportOutputInfo,
//    // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen start
//    //                        Map<String, Object> dataKeyOutTempl) {
//                              Map<String, Object> dataKeyOutTempl,
//                              Map<String, String> param2) {
//    String totalCountH = param2.get("totalCountH");
//    String totalUnitDate = param2.get("totalUnitDate");
//    // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen end
//    // 列、行のヘーダを取得する。
//    Map<String, String> suppLiesLstMap = new HashMap<>();
//    if (dataCode.equals(param.getDataCode())) {
//      // sqlCodeをもとに出力情報を取得する
//      List<Map<String, Object>> tmpList = reportOutputInfo.get(Long.valueOf(param.getSqlCode()));
//      // フィルタ処理を行う
//      List<Map<String, Object>> filteredList = reportServiceImpl.filterReportInfo(param, tmpList);
//      if ("DateTime".equals(param.getDataType())) {
//        // 時間転換処理
//        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
//        Calendar bef = Calendar.getInstance();
//        Calendar aft = Calendar.getInstance();
//        try {
//          bef.setTime(sdf.parse(dataKeyOutTempl.get("fromDate").toString().replaceAll("/", "")));
//          aft.setTime(sdf.parse(dataKeyOutTempl.get("toDate").toString().replaceAll("/", "")));
//        } catch (ParseException e) {
//          e.printStackTrace();
//        }
//        int monthSection = aft.get(Calendar.MONTH) - bef.get(Calendar.MONTH);
//        int yearSection = aft.get(Calendar.YEAR) - bef.get(Calendar.YEAR);
//        // ⓸:集計単位日付属性により、配列の縦列サイズを計算する。　偏移量３：（縦の集計単位　＋　有効データ　＋　横の合計）
//        int dateCount = 0;
//        // add #11293 水質検査帳票の課題対応 limingzhe start
//        // mod #11950 複数集計帳票の印刷で出力可能なページ数だが100ページ制限となり出力できない。 limingzhe start
//        //if(param2.get("reportType").equals("3")){
//        if(param2.get("effectDateFlag").equals("1")){
//        // mod #11950 複数集計帳票の印刷で出力可能なページ数だが100ページ制限となり出力できない。 limingzhe end
//          for (Map<String, Object> item : filteredList) {
//            // 異なるテンプレートのプロパティフィールドに対応します。
//            if (null != item.get(dataCode)) {
//              if (!suppLiesLstMap.containsKey(item.get(dataCode).toString())) {
//                suppLiesLstMap.put(item.get(dataCode).toString(), item.get(dataCode).toString());
//              }
//            }
//          }
//        }
//        else {
//        // add #11293 水質検査帳票の課題対応 limingzhe end
//          if ("月".equals(totalUnitDate)) {
//            if (yearSection <= 0) {
//              dateCount = monthSection + 2;
//            } else {
//              dateCount = 12 * yearSection + monthSection + 2;
//            }
//          } else if ("年".equals(totalUnitDate)) {
//            dateCount = yearSection + 2;
//          } else {
//            // ”日”指定の場合、日付差を計算後で設定する。
//              long time1 = bef.getTimeInMillis();
//              long time2 = aft.getTimeInMillis();
//              long between_days = (time2 - time1) / (1000 * 3600 * 24);
//              //mod 10989 抽出条件-日付期間計算エラー gjn start
//              dateCount = Integer.parseInt(String.valueOf(between_days)) + 1;
//              //mod 10989 抽出条件-日付期間計算エラー gjn end
//          }
//        // add #11293 水質検査帳票の課題対応 limingzhe start
//        }
//        // add #11293 水質検査帳票の課題対応 limingzhe end
//        if (TOTAL_COUNTS_DISPLAY_N.equals(totalCountH)) {
//          for (int i = 0; i < dateCount - 1; i++) {
//            Date date = bef.getTime();
//            suppLiesLstMap.put(String.valueOf(i), sdf.format(date));
//            bef.add(Calendar.DATE, 1);
//          }
//        } else {
//          for (int i = 0; i < dateCount; i++) {
//            Date date = bef.getTime();
//            suppLiesLstMap.put(String.valueOf(i), sdf.format(date));
//
//            bef.add(Calendar.DATE, 1);
//          }
//        }
//      } else if ("reg_order_class".equals(param.getDataCode())) {
//        // 対応複数集計：regOrderClassListろ過条件です（透析前、透析後、その他）
//        ArrayList list = (ArrayList) dataKeyOutTempl.get("regOrderClassList");
//        return list.size();
//      } else {
//        // add #11950 複数集計帳票の印刷で出力可能なページ数だが100ページ制限となり出力できない。 limingzhe start
//        if(Long.valueOf(param.getSqlCode()) == 127l){
//          Map<Long, List<Map<String, Object>>> reportInfo = new HashMap<>();
//          reportInfo.put(Long.valueOf(param.getSqlCode()), filteredList);
//          List<String> list = dataList(reportInfo, Long.valueOf(param.getSqlCode()), param.getDataCode());
//          return list.size();
//        }else{
//        // add #11950 複数集計帳票の印刷で出力可能なページ数だが100ページ制限となり出力できない。 limingzhe end
//          if (filteredList != null) {
//            for (Map<String, Object> item : filteredList) {
//              // 異なるテンプレートのプロパティフィールドに対応します。
//              if (null != item.get(dataCode)) {
//                if (!suppLiesLstMap.containsKey(item.get(dataCode).toString())) {
//                  suppLiesLstMap.put(item.get(dataCode).toString(), item.get(dataCode).toString());
//                }
//              }
//            }
//          }
//        // add #11950 複数集計帳票の印刷で出力可能なページ数だが100ページ制限となり出力できない。 limingzhe start
//        }
//        // add #11950 複数集計帳票の印刷で出力可能なページ数だが100ページ制限となり出力できない。 limingzhe end
//      }
//    }
//    return suppLiesLstMap.size();
//  }
//
//
//  /**
//   * テンプレート繰り返しのデータ項目をid属性値に変換します.
//   *
//   * @param result        idごとの値コレクション. Map<id, 値>
//   * @param tmpList       値コレクション. List<Map<SQLコード, 値>>
//   * @param param         帳票定義XMLのParam要素.
//   * @param startPrintPos 印刷開始テンプレート位置.
//   */
//  private void convertDataCodeToIdRepeatTmpl(Map<String, String> result,
//                                             List<Map<String, Object>> tmpList,
//                                             ReportXmlParam param,
//                                             int startPrintPos,
//                                             boolean isLabel) {
//    ReportXmlTmplRepeat tmplRepeat = param.getReportXmlTmplRepeat();
//    Integer repeatOfPage;
//    if (tmplRepeat != null && tmplRepeat.getIsNewPage() == ReportXmlTmplRepeat.IS_NEW_PAGE_YES) {
//      repeatOfPage = (tmpList.size() > tmplRepeat.getRepeatMax()) ? tmplRepeat.getRepeatMax() : tmpList.size();
//    } else {
//      repeatOfPage = tmpList.size();
//    }
//    // ページ数分、以下の処理を行う
//    int limitCount = repeatOfPage;
//    Integer repeatMax = (tmplRepeat != null && tmplRepeat.getRepeatMax() != null) ? tmplRepeat.getRepeatMax() : 1;
//    int startPos = startPrintPos;
//    int loopCnt = startPrintPos;
//    Integer pageIndex = 1;
//    for (Integer pageCount = 0; pageCount <= ((tmpList.size() + startPrintPos) / repeatOfPage); pageCount++) {
//      int skipCount = pageCount * limitCount;
//      if (startPrintPos != 1 && pageCount > 0 && startPrintPos + tmpList.size() > repeatMax) {
//        skipCount = repeatMax * pageCount - startPrintPos + 1;
//      }
//      List<Map<String, Object>> outputInfos = tmpList.stream().skip(skipCount).limit(limitCount).collect(toList());
//      for (Integer i = 0; i < outputInfos.size(); i++) {
//        if (i + startPos > repeatMax) {
//          // 帳票定義XMLで指定されている繰り返し回数を超えた場合、残りのデータは出力しない
//          // 印刷開始位置を指定して呼び出されている場合、2ページ目以降は先頭のテンプレートから印刷するために印刷開始位置を1にする
//          startPos = 1;
//          break;
//        }
//        String keyPage = String.format("%d%s", pageCount + 1, MULTIPLE_PAGES_SEPARATOR);
//        String keyTmpl = String.format("%s-%d", tmplRepeat.getId(), i + startPos);
//        String keyParam = String.format("%s%s", param.getId(), StringUtils.isEmpty(param.getGroupId()) ? "" : "-1");
//        String key = String.format("%s%s.%s", keyPage, keyTmpl, keyParam);
//        String value;
//        String dataCode;
//        if (outputInfos.get(i).size() == 0) {
//          result.put(key, "");
//          continue;
//        }
//        if (!StringUtils.isEmpty(param.getParticular()) && param.getParticular().equals("Label") && null != outputInfos.get(i).get("class_name")) {
//          // 分類別情報の場合に読むSQLコードを変える
//          // 分類別情報
//          final String classNo = outputInfos.get(i).get("class_ename").toString();
//          final ReportXmlClassificationDataCode reportXmlClassificationDataCode = param.getReportXmlClassificationDataCodes().get(classNo);
//          if (reportXmlClassificationDataCode != null) {
//            dataCode = reportXmlClassificationDataCode.getDataCode();
//            if (dataCode.isEmpty()) {
//              // 固定文字列
//              value = reportXmlClassificationDataCode.getFixString();
//            } else {
//              // dataCode指定
//              value = reportServiceImpl.formatValue(param, outputInfos.get(i).get(dataCode));
//              value = reportServiceImpl.convertValue(param, value);
//            }
//          } else {
//            value = "";
//          }
//        } else {
//          value = reportServiceImpl.formatValue(param, outputInfos.get(i).get(param.getDataCode()));
//          value = reportServiceImpl.convertValue(param, value);
//        }
//        // add "null"の文字列修正 chen start
//        if ("null".equals(value)) {
//          value = "";
//        }
//        // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
//        // result.put(key, addLineBreak(value, param.getDispLength(), param.getDataType()));
//        result.put(key, reportServiceImpl.addLineBreak(value, param));
//        // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
//      }
//    }
//  }
//
//  /**
//   * 単患者帳票、複数患者帳票のテンプレート外のhtmlを生成する.
//   *
//   * @param mstReport       帳票マスタ
//   * @param paramsOutTempl  テンプレート外の帳票定義xmlのparam要素
//   * @param dataKeyOutTempl テンプレート外のデータを取得するする為のデータキー
//   * @return テンプレート外のhtmlリスト
//   */
//  private List<String> createPatientReportHtmlOutTemplate(MstReport mstReport,
//                                                          List<ReportXmlParam> paramsOutTempl,
//                                                          Map<String, Object> dataKeyOutTempl,
//                                                          Map<String, Object> dataKeyOut,
//                                                          Map<String, Long> patIdToCMap,
//                                                          Map<String, String> outPutHtml) {
//
//    // S3から帳票定義XML、帳票デザインHTMLが格納されたZipファイルを取得.
//    ReportZipFile reportZipFile = getReportZip(mstReport);
//    // 帳票デザインHTMLファイルを取得する
//    String reportHtml = reportZipFile.getFileToString(mstReport.getReportPath().getHtmlFilename());
//    String reportXml = getReportXml(mstReport, reportZipFile);
//    List<ReportXmlParam> params = ReportUtils.getParamElements(reportXml);
//    String getColWidth = "";
//    String getRowHeight = "";
//    if (params.size() > 0) {
//      getColWidth = "";
//      getRowHeight = "";
//      for (int p = 0; p < params.size(); p++) {
//        if ("".equals(params.get(p).getDataCode()) && "byte[]".equals(params.get(p).getDataType())) {
//          getColWidth = params.get(p).getColWidth();
//          getRowHeight = params.get(p).getRowHeight();
//        }
//      }
//    }
//    // 帳票デザイン
//    if (StringUtils.isEmpty(reportHtml)) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage("帳票デザインHTMLファイルを取得できません。レポートコード : " + mstReport.getReportCd());
//      eventLogMessage.setFacilityCd(mstReport.getFacilityCd());
//      logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
//      // 空のHTMLを返却
//      return Collections.EMPTY_LIST;
//    }
//    // テンプレート外の領域にある項目にデータを当てはめる処理
//    // add #10857 帳票内に同項目が複数あると設定値を取り違える limingzhe start
//    List<ReportXmlParam> paramsXML = paramsOutTempl != null ? deepCopy(paramsOutTempl) : new ArrayList<>();
//    // add #10857 帳票内に同項目が複数あると設定値を取り違える limingzhe end
//    Map<Long, List<Map<String, Object>>> reportInfoForOutTempl = getReportInfo(paramsOutTempl, dataKeyOutTempl);
//    // add #10857 帳票内に同項目が複数あると設定値を取り違える limingzhe start
//    // mod #11009 カテゴリ「印刷情報」の優先対応 房 start
//    List<Map<String, Object>> rec = reportServiceImpl.getPrintedInfo(paramsOutTempl, dataKeyOut, reportInfoForOutTempl);
//    // mod #11009 カテゴリ「印刷情報」の優先対応 房 end
//    reportInfoForOutTempl.put(PRINT_INFO_CODE, rec);
//    paramsOutTempl = reportServiceImpl.paramsReplaceTmpValue(paramsOutTempl, reportInfoForOutTempl);
//    // add #10857 帳票内に同項目が複数あると設定値を取り違える limingzhe end
//    reportInfoForOutTempl = reportServiceImpl.getChangeList(reportInfoForOutTempl, paramsOutTempl);
//    if (mstReport.getReportClass() == ReportConstant.ReportClass.MULTI_TOTAL_REPORT) {
//      for (Long outKey : reportInfoForOutTempl.keySet()) {
//        List<Map<String, Object>> valueList = reportInfoForOutTempl.get(outKey);
//        String strItem = "";
//        Boolean itemFlg = true;
//        for (Map<String, Object> item : valueList) {
//          if (StringUtils.isEmpty(strItem) && !StringUtils.isEmpty(item.get("ord_no"))) {
//            strItem = item.get("ord_no").toString();
//            itemFlg = false;
//            continue;
//          }
//          if (!StringUtils.isEmpty(item.get("ord_no")) && !strItem.equals(item.get("ord_no").toString())) {
//            itemFlg = false;
//            break;
//          } else {
//            itemFlg = true;
//          }
//        }
//        if (itemFlg && (valueList.size() == 0 || !StringUtils.isEmpty(valueList.get(0).get("ord_no")))) {
//          List<String> strList = new ArrayList<>();
//          strList = (List<String>) dataKeyOutTempl.get("ordNos");
//          List<Map<String, Object>> tempdata = new ArrayList<>();
//          // add #9558 機能帳票でパラメータが正しく渡されていない 杜天成 start
//          if (strList != null) {
//            // add #9558 機能帳票でパラメータが正しく渡されていない 杜天成 end
//            for (int i = 0; i < strList.size(); i++) {
//              dataKeyOutTempl.put("ordNo", strList.get(i));
//              // add #10857 帳票内に同項目が複数あると設定値を取り違える limingzhe start
//              paramsOutTempl = paramsXML;
//              // add #10857 帳票内に同項目が複数あると設定値を取り違える limingzhe end
//              reportInfoForOutTempl = getReportInfo(paramsOutTempl, dataKeyOutTempl);
//              // add #10857 帳票内に同項目が複数あると設定値を取り違える limingzhe start
//              // mod #11009 カテゴリ「印刷情報」の優先対応 房 start
//              List<Map<String, Object>> rec1 = reportServiceImpl.getPrintedInfo(paramsOutTempl, dataKeyOut, reportInfoForOutTempl);
//              // mod #11009 カテゴリ「印刷情報」の優先対応 房 end
//              reportInfoForOutTempl.put(PRINT_INFO_CODE, rec1);
//              paramsOutTempl = reportServiceImpl.paramsReplaceTmpValue(paramsOutTempl, reportInfoForOutTempl);
//              reportInfoForOutTempl = reportServiceImpl.getChangeList(reportInfoForOutTempl, paramsOutTempl);
//              // add #10857 帳票内に同項目が複数あると設定値を取り違える limingzhe end
//              if (reportInfoForOutTempl.get(outKey).size() > 0) {
//                for (Map<String, Object> item : reportInfoForOutTempl.get(outKey)) {
//                  tempdata.add(item);
//                }
//              }
//            }
//          }
//          reportInfoForOutTempl.put(outKey, tempdata);
//          break;
//        }
//      }
//    }
//    // del #10857 帳票内に同項目が複数あると設定値を取り違える limingzhe start
////    int sqlCd = 0;
////    final String prtDt = "prt_dt";
////    final String login = "login";
////    final String kurl = "kurCdList";
////    final String bed = "bedCdListString";
////    final String freeWord = "freeWord";
////    final String treatDate = "treatDate";
////    final String expressCondCd = "expressCondCd";
////    final String medIds = "medIds";
////    final String eqIds = "eqIds";
////    final String period = "period";
////    final String kind = "kind";
////    final String weeks = "weeks";
////    final String addDate = "add_date";
////    boolean flag = false;
////    final String stFromDate = ReportConstant.ReportDataKey.DATE_FROM;
////    final String stToDate = ReportConstant.ReportDataKey.DATE_TO;
////    for (int i = 0; i < paramsOutTempl.size(); i++) {
////      ReportXmlParam value = paramsOutTempl.get(i);
////      if (value.getSqlCode().equals("") && (value.getDataCode().equals(prtDt) || value.getDataCode().equals(login) ||
////        value.getDataCode().equals(kurl) || value.getDataCode().equals(bed) || value.getDataCode().equals(freeWord) || value.getDataCode().equals(treatDate) ||
////        value.getDataCode().equals(expressCondCd) || value.getDataCode().equals(medIds) || value.getDataCode().equals(eqIds)
////        || value.getDataCode().equals(period) || value.getDataCode().equals(kind) || value.getDataCode().equals(weeks)
////        || value.getDataCode().equals(stFromDate) || value.getDataCode().equals(stToDate))
////      ) {
////        value = ReportXmlParam.of(value.getIsImage(), value.getRepeatAddress(), value.getId(), value.getDispType(), value.getDataCode(), value.getSqlCode(), value.getDataType(),
////          value.getIsShrink(), value.getDispLength(), value.getFilterType(), value.getDispFormat(), value.getFormula(), value.getGroupId(),
////          value.getIsInTmpl(), value.getIsNewPage(), value.getColWidth(), value.getRowHeight(),
////          value.getRowCount(),
////          value.getReportXmlFilters(), value.getReportXmlConvs(),
////          value.getReportXmlGroup(), value.getReportXmlFormatConditions(), value.getFunction(), "",
////          value.getReportXmlTmplRepeat(), value.getReportXmlTotalTable(), value.getParticular(), value.getReportXmlClassificationDataCodes());
////        paramsOutTempl.set(i, value);
////      }
////      if (value.getDataCode().equals(addDate)) {
////        flag = true;
////      }
////    }
////    Map<String, Object> fieldValues = new HashMap<String, Object>();
////    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
////    fieldValues.put(prtDt, sdf.format(new Date()));
////    if (dataKeyOut.containsKey(login)) {
////      fieldValues.put(login, dataKeyOut.get(login));
////    }
////    if (dataKeyOut.containsKey(kurl)) {
////      fieldValues.put(kurl, dataKeyOut.get(kurl));
////    }
////    if (dataKeyOut.containsKey(bed)) {
////      fieldValues.put(bed, dataKeyOut.get(bed));
////    }
////    if (dataKeyOut.containsKey(freeWord)) {
////      fieldValues.put(freeWord, dataKeyOut.get(freeWord));
////    }
////    if (dataKeyOut.containsKey(treatDate)) {
////      fieldValues.put(treatDate, dataKeyOut.get(treatDate));
////    }
////    if (dataKeyOut.containsKey(expressCondCd)) {
////      fieldValues.put(expressCondCd, dataKeyOut.get(expressCondCd));
////    }
////    if (dataKeyOut.containsKey(medIds)) {
////      fieldValues.put(medIds, dataKeyOut.get(medIds));
////    }
////    if (dataKeyOut.containsKey(eqIds)) {
////      fieldValues.put(eqIds, dataKeyOut.get(eqIds));
////    }
////    if (dataKeyOut.containsKey(period)) {
////      fieldValues.put(period, dataKeyOut.get(period));
////    }
////    if (dataKeyOut.containsKey(kind)) {
////      fieldValues.put(kind, dataKeyOut.get(kind));
////    }
////    if (dataKeyOut.containsKey(weeks)) {
////      fieldValues.put(weeks, dataKeyOut.get(weeks));
////    }
////    if (flag) {
////      // ログイン名が上位から与えられていたら追加
////      String add = patEventDao.selectByPatIdAndUseType(Long.valueOf(dataKeyOut.get("patId").toString()), dataKeyOut.get(ReportConstant.ReportDataKey.FACILITY_CD).toString());
////      fieldValues.put(addDate, add);
////    }
////    if (dataKeyOut.containsKey(stFromDate)) {
////      fieldValues.put(stFromDate, dataKeyOut.get(stFromDate));
////    }
////    if (dataKeyOut.containsKey(stToDate)) {
////      fieldValues.put(stToDate, dataKeyOut.get(stToDate));
////    }
////    List<Map<String, Object>> rec;
////    final Long key = Long.valueOf(sqlCd);
////    if (reportInfoForOutTempl.containsKey(key)) {
////      rec = reportInfoForOutTempl.get(key);
////    } else {
////      rec = new ArrayList<Map<String, Object>>();
////    }
////    rec.add(fieldValues);
////    reportInfoForOutTempl.put(key, rec);
//    // del #10857 帳票内に同項目が複数あると設定値を取り違える limingzhe end
//    // オーダ番号をデータキーから取得.
//    Long ordNo = getOrdNoFromDataKey(dataKeyOutTempl);
//    // 帳票定義xmlを分解した結果からグラフIDを取得
//    Optional<String> graphId = getGraphId(paramsOutTempl);
//    Map<String, String> chartInfo = new HashMap<>();
//    // テンプレート外にグラフIDが埋め込まれている場合
//    // del #10633 【たくしん会】帳票のフォント問題 吉 start
////    if (graphId.isPresent()) {
////      // チャートを生成し、base64化する.
////      chartInfo = createChartImage(ordNo, graphId, dataKeyOutTempl, getColWidth, getRowHeight);
////    }
//// del #10633 【たくしん会】帳票のフォント問題 吉 end
//    boolean doPatLastName = false;
//    for (int i = 0; i < paramsOutTempl.size(); i++) {
//      if ("pat_last_name".equals(paramsOutTempl.get(i).getDataCode())) {
//        doPatLastName = true;
//        patIdToCMap.put(PAT_ID_TO_C, Long.parseLong(dataKeyOutTempl.get("patId").toString()));
//        break;
//      }
//    }
//    if (doPatLastName) {
//      for (List<Map<String, Object>> valueList : reportInfoForOutTempl.values()) {
//        for (int o = 0; o < valueList.size(); o++) {
//          if (valueList.get(o).containsKey("pat_last_name_id")) {
//            if ("".equals(valueList.get(o).get("patId")) && valueList.get(o).get("pat_last_name_id") == null) {
//              valueList.get(o).put("pat_last_name", "");
//            } else {
//              Long patId = Long.parseLong(valueList.get(o).get("patId").toString());
//              PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(patId);
//              valueList.get(o).put("pat_last_name", patPersonalMain.getPat_last_name());
//            }
//          }
//        }
//      }
//    }
//    Map<String, String> reportOutputInfoForOutTempl = convertDataCodeToId(paramsOutTempl, reportInfoForOutTempl,
//      mstReport.getReportClass(), mstReport.getReportType(), patIdToCMap, dataKeyOut, mstReport.getExtractionCondition());
//    final Map<String, String> calcResult = reportServiceImpl.getCalcResult(paramsOutTempl, reportInfoForOutTempl, reportOutputInfoForOutTempl);
//    // 条件付き書式を適用するidとclassのMapを作成する
//    Map<String, String> formatConditionInfo = createFormatConditionInfo(paramsOutTempl, reportOutputInfoForOutTempl, mstReport.getReportCd());
//    // 縮小表示を適用するidとscaleのMapを作成する
//    Map<String, String[]> resizeFontSizeInfo = createResizeFontSizeInfo(reportHtml, paramsOutTempl, reportOutputInfoForOutTempl, formatConditionInfo);
//    // Excel関数がある場合、POIで実行した値を取得する
//    List<ReportXmlParam> functionParams = paramsOutTempl.stream().filter(e -> e.hasFunction()).collect(toList());
//    if (!functionParams.isEmpty()) {
//      // mod #11260 テンプレート設定した帳票の出力で高負荷になることがある 房 start
////      try (Workbook wb = reportService.getReportExcelWorkbook(mstReport, reportZipFile, paramsOutTempl, reportOutputInfoForOutTempl, calcResult, ordNo, dataKeyOut, getColWidth, getRowHeight)) {
//      try{
//        com.aspose.cells.Workbook wb = reportWithAsposeApiService.getReportExcelWorkbook(mstReport, reportZipFile, paramsOutTempl, reportOutputInfoForOutTempl, calcResult, ordNo, dataKeyOut, getColWidth, getRowHeight);
//        // 式を評価する為の前準備
////        FormulaEvaluator evaluator = wb.getCreationHelper().createFormulaEvaluator();
//        for (int page = 1; ; page++) {
//          String prefix = String.format("%d%s", page, MULTIPLE_PAGES_SEPARATOR);
////          Sheet st = wb.getSheet(String.format("%s%d", SHEET_NAME_PREFIX, page));
//          Worksheet st = wb.getWorksheets().get(String.format("%s%d", SHEET_NAME_PREFIX, page));
//          if (st == null) {
//            break;
//          }
//          functionParams.forEach(param -> {
////            reportOutputInfoForOutTempl.put(
////              String.format("%s%s", prefix, param.getId()),
////              formatValue(param, ReportUtils.getFormulaResultValue(st, evaluator, param.getId())));
//            reportOutputInfoForOutTempl.put(
//              String.format("%s%s", prefix, param.getId()),
//              reportServiceImpl.formatValue(param, AsposeExcelUtil.getFormulaResultValue(st, param.getId())));
//          });
//        }
//      } catch (Exception e) {
//        EventLogMessage eventLogMessage = new EventLogMessage();
//        eventLogMessage.setLogMessage("帳票：関数処理に失敗しました。" + NtssUtils.ExcetionStackTraceToString(e));
//        eventLogMessage.setFacilityCd(mstReport.getFacilityCd());
//        logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
//      }
//      // mod #11260 テンプレート設定した帳票の出力で高負荷になることがある 房 end
//    }
//    outPutHtml.putAll(reportOutputInfoForOutTempl);
//    List<String> htmlList = getReflectReportHtml(
//      reportHtml,
//      reportOutputInfoForOutTempl,
//      calcResult,
//      formatConditionInfo,
//      chartInfo,
//      resizeFontSizeInfo,
//      mstReport.getFacilityCd()
//    );
//    return htmlList;
//  }
//
//  // テンプレート内の繰り返しで、枠内に収まらず次の項目に表示された場合に、位置補正を行う為に必要な値を格納するクラス
//  private class TmplCorrectData {
//    // key：元、value：補正後 / 形式：[ページ]#[ページ内のテンプレート位置] ( 例：1#2 )
//    Map<String, String> repNumList = new HashMap<>();
//    // 処理除外対象セルリスト
//    List<String> cellList = new ArrayList<String>();
//  }
//
//  private Map<String, String> convertDataCodeToId(List<ReportXmlParam> params, Map<Long, List<Map<String, Object>>> reportOutputInfo, Integer type, Integer reportType,
//                                                  Map<String, Long> patIdToCMap, Map<String, Object> dataKey, MstReport.Extraction extractionCondition) {
//    Map<String, String> paramIds = new HashMap<>();
//    TmplCorrectData tmplCorrectData = new TmplCorrectData();
//    Map<String, String> result = new HashMap<>();
//    List<Long> ordDataList = new ArrayList<>();
//    List<Object> ordNos = (List) dataKey.get("ordNos");
//    if (null != ordNos && ordNos.size() > 0) {
//      for (int i = 0; i < ordNos.size(); i++) {
//        if (ordNos.get(i) instanceof Long) {
//          Long ordNo = Long.parseLong(ordNos.get(i).toString());
//          ordDataList.add(ordNo);
//        } else if (ordNos.get(i) instanceof OrdMain) {
//          OrdMain ordMain = (OrdMain) ordNos.get(i);
//          ordDataList.add(ordMain.getOrdNo());
//        }
//      }
//    }
//    Map<String, List<ReportXmlParam>> groupIdListInTmpl =
//      params.stream()
//        .filter(param -> param.isTmplRepeat())
//        .collect(Collectors.groupingBy(ReportXmlParam::getGroupId));
//    Integer repeatTMax = 0;
//    String groupStr = "";
//    List doReportName = new ArrayList();
//    Map<String, Integer> tmpSkipCountMap = new HashMap<>();
//    tmpSkipCountMap.put(TMP_SKIP_COUNT, 0);
//    for (int count = 0; count < params.size(); count++) {
//      if ("medicine_name".equals(params.get(count).getDataCode())) {
//        repeatTMax = params.get(count).getReportXmlTmplRepeat().getRepeatMax();
//        groupStr = params.get(count).getGroupId();
//        break;
//      }
//    }
//    for (String doStr : groupIdListInTmpl.keySet()) {
//      if (groupStr.equals(doStr)) {
//        List<ReportXmlParam> doReportParam = groupIdListInTmpl.get(doStr);
//        for (int u = 0; u < doReportParam.size(); u++) {
//          doReportName.add(doReportParam.get(u).getDataCode());
//        }
//        break;
//      }
//    }
//    Map<String, List<ReportXmlParam>> groupedParams = params.stream()
//      .filter(p -> !StringUtils.isEmpty(p.getId()))
//      .collect(Collectors.groupingBy(p -> p.getSqlCode()));
//    List<String> sqlCodes = getSqlCode(params);
//    // mod #10857 帳票内に同項目が複数あると設定値を取り違える 高 start
////    List<Integer> sqlCode1 = new ArrayList<Integer>();
////    for (String sql : sqlCodes) {
////      sqlCode1.add(Integer.valueOf(sql));
////    }
////    Collections.sort(sqlCode1);
////    LinkedHashMap<String, List<ReportXmlParam>> newGroupe = new LinkedHashMap<>();
////    for (Integer sql : sqlCode1) {
////      if (groupedParams.get(sql.toString()) != null) {
////        newGroupe.put(sql.toString(), groupedParams.get(sql.toString()));
////      }
////    }
//    List<Long> sqlCode1 = new ArrayList<Long>();
//    for (String sql : sqlCodes) {
//      sqlCode1.add(Long.valueOf(sql));
//    }
//    Collections.sort(sqlCode1);
//    LinkedHashMap<String, List<ReportXmlParam>> newGroupe = new LinkedHashMap<>();
//    for (Long sql : sqlCode1) {
//      if (groupedParams.get(sql.toString()) != null) {
//        newGroupe.put(sql.toString(), groupedParams.get(sql.toString()));
//      }
//    }
//    // mod #10857 帳票内に同項目が複数あると設定値を取り違える 高 end
//    // データ項目コード -> id属性値 に変換した情報を設定する
//    newGroupe.entrySet().forEach(groupedParam -> {
//      //各ループ開始resultで追加されたデータ数を記録する
//      int resultSize = result.size();
//      Long sqlCode;
//      if (null != groupedParam.getKey() && groupedParam.getKey().equals("")) {
//        sqlCode = Long.valueOf(0);
//      } else {
//        sqlCode = Long.valueOf(groupedParam.getKey());
//      }
//      // sqlCodeをもとに出力情報を取得する
//      List<Map<String, Object>> tmpList = reportOutputInfo.get(sqlCode);
//      Map<String, Object> dataKeyValues = new HashMap<>();
//      if (tmpList != null && tmpList.size() > 0) {
//        if (tmpList.get(0).containsKey("pat_last_name_id")) {
//          for (int i = 0; i < tmpList.size(); i++) {
//            Long patIdToC = 0L;
//            if (patIdToCMap.get(PAT_ID_TO_C) != null) {
//              patIdToC = patIdToCMap.get(PAT_ID_TO_C);
//            }
//            if (patIdToC != null && patIdToC.equals(tmpList.get(i).get("patId"))) {
//              dataKeyValues = tmpList.get(i);
//              break;
//            }
//          }
//        }
//      }
//      if (tmpList != null && !tmpList.isEmpty()) {
//        List<ReportXmlParam> list = groupedParam.getValue().stream()
//          .filter(param -> StringUtils.isEmpty(param.getGroupId()) && "1".equals(param.getIsNewPage()) && !param.isTmplRepeat()).collect(toList());
//        // 単一項目に対する処理を行う
//        if (tmpList.size() > 1 && list != null && list.size() > 0) {
//          groupedParam.getValue().stream()
//            .filter(param -> StringUtils.isEmpty(param.getGroupId()) && !param.isTmplRepeat())
//            .forEach(param -> {
//              for (int i = 0; i < tmpList.size(); i++) {
//                Map<String, Object> tmpMap = tmpList.get(i);
//                // 出力する内容を取得する
//                String value = reportServiceImpl.formatValue(param, tmpMap.get(param.getDataCode()));
//                value = reportServiceImpl.convertValue(param, value);
//                if (value != null && !"null".equals(value)) {
//                  // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
//                  // result.put(String.format("%d%s", i + 1, MULTIPLE_PAGES_SEPARATOR) + param.getId(), addLineBreak(value, param.getDispLength(), param.getDataType()));
//                  result.put(String.format("%d%s", i + 1, MULTIPLE_PAGES_SEPARATOR) + param.getId(), reportServiceImpl.addLineBreak(value, param));
//                  // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
//                } else {
//                  result.put(String.format("%d%s", i + 1, MULTIPLE_PAGES_SEPARATOR) + param.getId(), "");
//                }
//              }
//            })
//          ;
//        } else {
//          Map<String, Object> tmpMap = tmpList.get(0);
//          groupedParam.getValue().stream()
//            .filter(param -> StringUtils.isEmpty(param.getGroupId()) && !param.isTmplRepeat())
//            .forEach(param -> {
//              // 出力する内容を取得する
//              String value = reportServiceImpl.formatValue(param, tmpMap.get(param.getDataCode()));
//              value = reportServiceImpl.convertValue(param, value);
//              if (value != null && !"null".equals(value)) {
//                // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
//                // result.put(param.getId(), addLineBreak(value, param.getDispLength(), param.getDataType()));
//                result.put(param.getId(), reportServiceImpl.addLineBreak(value, param));
//                // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
//              } else {
//                result.put(param.getId(), "");
//              }
//            })
//          ;
//        }
//        Map<String, Object> finalDataKeyValues = dataKeyValues;
//        // 複数項目に対する処理を行う
//        groupedParam.getValue().stream()
//          .filter(param -> !StringUtils.isEmpty(param.getGroupId()) && !param.isTmplRepeat())
//          .forEach(param -> {
//            // フィルタ処理を行う
//            List<Map<String, Object>> filteredList = reportServiceImpl.filterReportInfo(param, tmpList);
//            // フィルタ処理の結果がEmptyの場合
//            if (filteredList.isEmpty()) {
//              EventLogMessage eventLogMessage = new EventLogMessage();
//              eventLogMessage.setLogMessage("帳票：フィルタ結果した結果が空");
//              logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
//              return;
//            }
//            // 1ページの繰り返し件数を取得する
//            ReportXmlGroup group = param.getReportXmlGroup();
//            Integer repeatOfPage;
//            if (group != null && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_YES) {
//              repeatOfPage = (filteredList.size() > group.getRepeatMax()) ? group.getRepeatMax() : filteredList.size();
//            } else {
//              repeatOfPage = filteredList.size();
//            }
//            // ページ数分、以下の処理を行う
//            int limitCount = repeatOfPage;
//            String mainteLayoutCd = "";
//            String mainteRecordCd = "";
//            String mainteUseCd = "";
//            String mainteDate = "";
//            if (extractionCondition != null) {
//              mainteLayoutCd = extractionCondition.getLayoutCD();
//              mainteRecordCd = extractionCondition.getRecordCD();
//              mainteUseCd = extractionCondition.getUseCD();
//              mainteDate = (String) dataKey.get(ReportConstant.ReportDataKey.DATE);
//            }
//            Integer repeatMax = (group != null && group.getRepeatMax() != null) ? group.getRepeatMax() : 1;
//            for (Integer pageCount = 0; pageCount <= (filteredList.size() / repeatOfPage); pageCount++) {
//              int skipCount = pageCount * limitCount;
//              // id属性値をkey、出力値をvalue に設定する（複数項目の場合、id属性値に連番を付加する）
//              List<Map<String, Object>> outputInfos = filteredList.stream().skip(skipCount).limit(limitCount).collect(toList());
//              int n = 0;
//              List<ReportXmlFilterTable> filters = param.getReportXmlFilters();
//              Map<String, Object> showDataInfoTemp = new LinkedHashMap<>();
//              if (outputInfos.size() > 0 && "Category".equals(param.getFilterType())) {
//                outputInfos = reportServiceImpl.filterReportInfo(param, outputInfos);
//              }
//              String strDate = "";
//              List mediName = new ArrayList();
//              int page_offset = 0;
//              int sum_offset = 1;
//              for (Integer i = 0; i < outputInfos.size(); i++) {
//                if (n >= repeatMax) {
//                  // 帳票定義XMLで指定されている繰り返し回数を超えた場合、残りのデータは出力しない
//                  break;
//                }
//                String outputData = "";
//                if (!mainteLayoutCd.isEmpty()) {
//                  if (String.valueOf(outputInfos.get(i).get("mainte_layout_cd")).equals(mainteLayoutCd)) {
//                    if (repeatMax > 1) {
//                      if ("mainte_date".equals(param.getDataCode())) {
//                        if (DateFormat(String.valueOf(outputInfos.get(i).get("mainte_date"))).equals(strDate)) {
//                          continue;
//                        }
//                        strDate = DateFormat(String.valueOf(outputInfos.get(i).get("mainte_date")));
//                      }
//                    } else {
//                      if (!DateFormat(String.valueOf(outputInfos.get(i).get("mainte_date"))).equals(mainteDate)) {
//                        continue;
//                      }
//                    }
//                    if ("2".equals(mainteUseCd)) {
//                      if (String.valueOf(outputInfos.get(i).get("tabindex")).equals(mainteRecordCd)) {
//                        outputData = String.valueOf(outputInfos.get(i).get("mainte_detail_cd"));
//                      }
//                    } else {
//                      outputData = String.valueOf(outputInfos.get(i).get("mainte_detail_cd"));
//                    }
//                  } else {
//                    continue;
//                  }
//                } else {
//                  Set<String> keysSet = outputInfos.get(i).keySet();
//                  if (!keysSet.isEmpty()) {
//                    String key = keysSet.toArray(new String[0])[0];
//                    outputData = String.valueOf(outputInfos.get(i).get(key));
//                  }
//                }
//                List<String> PatientEvents = new ArrayList<String>() {
//                  {
//                    for (int i = 84; i <= 94; i++) {
//                      this.add(i + "");
//                    }
//                  }
//                };
//                if (filters == null || filters.size() == 0 || (outputData.equals(filters.get(0).getCode()) && !outputData.isEmpty()) || PatientEvents.contains(param.getSqlCode())) {
//                  String key = "";
//                  if (group != null && group.getRepeatMax() <= 1 && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_NO) {
//                    // グループ設定が存在しない、またはグループ設定の繰り返し回数が1以下且つテンプレート外の項目は、後続処理でページ毎出力されるようにidを設定する
//                    key = param.getId();
//                  } else {
//                    String pageStr = String.format("%d%s", pageCount + 1, MULTIPLE_PAGES_SEPARATOR);
//                    key = String.format("%s%s-%d", pageStr, param.getId(), n + 1);
//                  }
//                  if (finalDataKeyValues.size() > 0) {
//                    if ("pat_last_name".equals(param.getDataCode()) || "first_name_is_same".equals(param.getDataCode()) || "pat_name".equals(param.getDataCode())) {
//                      String valueA = reportServiceImpl.formatValue(param, finalDataKeyValues.get(param.getDataCode()));
//                      valueA = reportServiceImpl.convertValue(param, valueA);
//                      if ("first_name_is_same".equals(param.getDataCode())) {
//                        valueA = finalDataKeyValues.get("pat_last_name") + " " + valueA;
//                      }
//                      if (valueA != null && !"".equals(valueA)) {
//                        // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
//                        // result.put(param.getId() + "-1", addLineBreak(valueA, param.getDispLength(), param.getDataType()));
//                        result.put(param.getId() + "-1", reportServiceImpl.addLineBreak(valueA, param));
//                        // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
//                      } else {
//                        result.put(param.getId() + "-1", "");
//                      }
//                    }
//                  } else {
//                    String value = reportServiceImpl.formatValue(param, outputInfos.get(i).get(param.getDataCode()));
//                    value = reportServiceImpl.convertValue(param, value);
//                    //
//                    if (param.getIsImage().equals("true") && null != value && !value.equals("") && !value.equals("null")) {
//                      value = "(place)" + value;
//                    }
//                    String temp_str = "", key_str = "";
//                    int offset = 0, key_offset = 0;
//                    int max = param.getRepeatAddress().split(",").length;
//                    if (value != null && !"null".equals(value) && !"".equals(value)) {
//                      if (!result.containsKey(key)) {
//                        // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
//                        // result.put(key, addLineBreak(value, param.getDispLength(), param.getDataType()));
//                        result.put(key, reportServiceImpl.addLineBreak(value, param));
//                        // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
//                      }
//                    } else {
//                      if (!result.containsKey(key)) {
//                        result.put(key, "");
//                      }
//                    }
//                  }
//                  n = n + 1;
//                }
//              }
//            }
//          });
//        List<String> resultExamDateList = new ArrayList<>();
//        int tmplCount = 0;
//        int tmplLoopCount = 1;
//        Long ordNoChangeSave = 0L;
//        String mainteLayoutCd = "";
//        String mainteRecordCd = "";
//        String mainteUseCd = "";
//        String mainteDate = "";
//        if (extractionCondition != null) {
//          mainteLayoutCd = extractionCondition.getLayoutCD();
//          mainteRecordCd = extractionCondition.getRecordCD();
//          mainteUseCd = extractionCondition.getUseCD();
//          mainteDate = (String) dataKey.get(ReportConstant.ReportDataKey.DATE);
//        }
//        for (ReportXmlParam param : groupedParam.getValue()) {
//          if (!(!StringUtils.isEmpty(param.getGroupId()) && param.isTmplRepeat())) {
//            continue;
//          }
//          if (sqlCode != 31L) {
//            List<Map<String, Object>> filteredList = reportServiceImpl.filterReportInfo(param, tmpList);
//            if (filteredList.isEmpty()) {
//              EventLogMessage eventLogMessage = new EventLogMessage();
//              eventLogMessage.setLogMessage("帳票：フィルタ結果した結果が空");
//              logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
//              return;
//            }
//            ReportXmlGroup group = param.getReportXmlGroup();
//            Integer repeatOfPage;
//            if (group != null && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_YES) {
//              repeatOfPage = (filteredList.size() > group.getRepeatMax()) ? group.getRepeatMax() : filteredList.size();
//            } else {
//              if (!StringUtils.isEmpty(param.getReportXmlTmplRepeat().getId())) {
//                repeatOfPage = (filteredList.size() > param.getReportXmlTmplRepeat().getRepeatMax()) ? param.getReportXmlTmplRepeat().getRepeatMax() : filteredList.size();
//              } else {
//                repeatOfPage = filteredList.size();
//              }
//            }
//            int limitCount = repeatOfPage;
//            Integer repeatMax = (group != null && group.getRepeatMax() != null) ? group.getRepeatMax() : 1;
//            for (Integer pageCount = 0; pageCount <= (filteredList.size() / repeatOfPage); pageCount++) {
//              int skipCount = pageCount * limitCount;
//              List<Map<String, Object>> outputInfos = filteredList.stream().skip(skipCount).limit(limitCount).collect(toList());
//              int n = 0;
//              List<ReportXmlFilterTable> filters = param.getReportXmlFilters();
//              int count = 1;
//              for (Integer i = 0; i < outputInfos.size(); i++) {
//                if ((totalUnitVList != null && totalUnitHList != null) && !(totalUnitVList.size() > 0 && totalUnitHList.size() > 0)) {
//                  // ord_noを取得する。
//                  Long ordNo = outputInfos.get(i).get("ord_no") == null ? 0L : (Long) outputInfos.get(i).get("ord_no");
//                  // 新しい項目のループ始めるの場合、「tmplCount」に「0」を設定する。
//                  if (i == 0) {
//                    tmplCount = 0;
//                  }
//                  // 新しい患者のループ始めるの場合、「n」に「0」を設定する。
//                  if (!ordNoChangeSave.equals(ordNo)) {
//                    n = 0;
//                  }
//                  if (!ordNoChangeSave.equals(ordNo)) {
//                    ordNoChangeSave = ordNo;
//                    tmplCount += 1;
//                    tmplLoopCount = 1;
//                  }
//                  if (tmplLoopCount > repeatMax && ordNoChangeSave.equals(ordNo)) {
//                    tmplLoopCount++;
//                    continue;
//                  }
//                  if (n >= repeatMax) {
//                    break;
//                  }
//                }
//                String outputData = "";
//                if (!mainteLayoutCd.isEmpty()) {
//                  if (!DateFormat(String.valueOf(outputInfos.get(i).get("mainte_date"))).equals(mainteDate)) {
//                    continue;
//                  }
//                  if (String.valueOf(outputInfos.get(i).get("mainte_layout_cd")).equals(mainteLayoutCd)) {
//                    if ("2".equals(mainteUseCd)) {
//                      if (String.valueOf(outputInfos.get(i).get("tabindex")).equals(mainteRecordCd)) {
//                        outputData = String.valueOf(outputInfos.get(i).get("mainte_detail_cd"));
//                      }
//                    } else {
//                      outputData = String.valueOf(outputInfos.get(i).get("mainte_detail_cd"));
//                    }
//                  }
//                } else {
//                  Set<String> keysSet = outputInfos.get(i).keySet();
//                  String key = keysSet.toArray(new String[0])[0];
//                  outputData = String.valueOf(outputInfos.get(i).get(key));
//                }
//                if (filters == null || filters.size() == 0 || (outputData.equals(filters.get(0).getCode()) && !outputData.isEmpty())) {
//                  String pageStr = String.format("%d%s", pageCount + 1, MULTIPLE_PAGES_SEPARATOR);
//                  String key = null;
//                  if (totalUnitVList != null && totalUnitHList != null && totalUnitVList.size() > 0 && totalUnitHList.size() > 0) {
//                    key = String.format("%s%s-%d", pageStr, param.getId(), n + 1);
//                  } else {
//                    ReportXmlTmplRepeat tmplRepeat = param.getReportXmlTmplRepeat();
//                    String keyTmpl = String.format("%s-%d", tmplRepeat.getId(), tmplCount);
//                    String keyParam = String.format("%s-%s", param.getId(), tmplLoopCount++);
//                    key = String.format("%s%s.%s", pageStr, keyTmpl, keyParam);
//                  }
//                  String value = reportServiceImpl.formatValue(param, outputInfos.get(i).get(param.getDataCode()));
//                  value = reportServiceImpl.convertValue(param, value);
//                  paramIds.put(param.getId(), param.getId());
//                  if (value != null && !"null".equals(value)) {
//                    // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
//                    // result.put(key, addLineBreak(value, param.getDispLength(), param.getDataType()));
//                    result.put(key, reportServiceImpl.addLineBreak(value, param));
//                    // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
//                  } else {
//                    result.put(key, "");
//                  }
//                  n = n + 1;
//                }
//              }
//            }
//          }
//        }
//        // sqlCodeをもとに出力情報を取得する
//        List<Map<String, Object>> oldTmpList = new ArrayList<>();
//        oldTmpList.addAll(tmpList);
//        // テンプレート繰り返しに対する処理を行う
//        groupedParam.getValue().stream().filter(param -> (StringUtils.isEmpty(param.getGroupId()) && param.isTmplRepeat()))
//          .forEach(param -> {
//              int startPrintPos = 1;
//              if (reportOutputInfo.get(0l).get(0).get("stPos") != null) {
//                startPrintPos = (int) reportOutputInfo.get(0l).get(0).get("stPos");
//              }
//              boolean isLabel = false;
//              // 検査結果表示のフィルタ表示
//              List<ReportXmlFilterTable> filters = param.getReportXmlFilters();
//              if (filters != null && filters.size() > 0) {
//                // コードを取得する
//                String itemCode = String.valueOf(filters.get(0).getCode());
//                // 透析前
//                String before = filters.get(0).getBefore();
//                // 透析後
//                String after = filters.get(0).getAfter();
//                List<Map<String, Object>> newTmpList = new ArrayList<>();
//                for (int i = 0; i < oldTmpList.size(); i++) {
//                  String tmpItemCode = String.valueOf(oldTmpList.get(i).get("item_cd"));
//                  if (tmpItemCode.equals(itemCode)) {
//                    if ("1".equals(before) && "0".equals(after)) {
//                      // ALB(前）
//                      if ("1".equals(String.valueOf(oldTmpList.get(i).get("reg_order_class")))) {
//                        newTmpList.add(oldTmpList.get(i));
//                      }
//                    } else if ("0".equals(before) && "1".equals(after)) {
//                      // ALB(後）
//                      if ("2".equals(String.valueOf(oldTmpList.get(i).get("reg_order_class")))) {
//                        newTmpList.add(oldTmpList.get(i));
//                      }
//                    } else {
//                      newTmpList.add(oldTmpList.get(i));
//                    }
//                  }
//                }
//                // 登録時検査日時の最新時刻でソート
//                Collections.sort(newTmpList, new Comparator<Map<String, Object>>() {
//                  public int compare(Map<String, Object> o1, Map<String, Object> o2) {
//                    String v1 = o1.get("reg_exam_date").toString();
//                    String v2 = o2.get("reg_exam_date").toString();
//                    int cp1 = v2.compareTo(v1);
//                    if (cp1 == 0) {
//                      return 0;
//                    } else {
//                      return cp1;
//                    }
//                  }
//                });
//                tmpList.clear();
//                for (int i = 0; i < newTmpList.size(); i++) {
//                  tmpList.add(newTmpList.get(i));
//                }
//              }
//              ReportXmlTmplRepeat tmplRepeat = param.getReportXmlTmplRepeat();
//              String tmplRepeatadd = tmplRepeat.getId();
//              if (tmplRepeatadd != null) {
//                String[] Id = tmplRepeatadd.split(":");
//                if (Id.length == 2) {
//                  String str = Id[0];
//                  String[] Ids = str.split("\\d");
//                  int onei = Ids[0].length();
//                  String strA = str.substring(0, onei);
//                  String str2 = Id[1];
//                  String[] Ids2 = str2.split("\\d");
//                  int twoi = Ids2[0].length();
//                  String strB = str2.substring(0, twoi);
//                  if (strA.equals(strB)) {
//                    if (!paramIds.containsKey(param.getId())) {
//                      convertDataCodeToIdRepeatTmpl(result, tmpList, param, startPrintPos, isLabel);
//                    }
//                  } else {
//                    convertDataCodeToIdRepeatTmpl(result, tmpList, param, startPrintPos, isLabel);
//                  }
//                } else {
//                  convertDataCodeToIdRepeatTmpl(result, tmpList, param, startPrintPos, isLabel);
//                }
//              } else {
//                convertDataCodeToIdRepeatTmpl(result, tmpList, param, startPrintPos, isLabel);
//              }
//            });
//      }
//      //sqlCodeが空ではないが、データを書き込めない場合の解決 (適切な修正案が見つかった場合は、このセグメントコードを削除できます)
//      //今回のサイクルでデータが何も書き込まれていない場合は、
//      // ①reportOutputInfo、②dataKeyから、
//      //本来書き込む可能性のあるデータを見つけて書き込むことを順番に試みます
//      if (resultSize == result.size()) {
//        groupedParam.getValue().forEach(param -> {
//          List<Map<String, Object>> info = reportOutputInfo.get(Long.valueOf(param.getSqlCode()));
//          info = reportServiceImpl.filterReportInfo(param, info);
//          String key = param.getId();
//          if (!param.getSqlCode().equals("")) {
//            key += "-1";
//          }
//          if (info != null && info.size() > 0) {
//            //reportOutputInfoの最初のデータから優先的に検索
//            result.put(key, reportServiceImpl.formatValue(param, info.get(0).get(param.getDataCode())));
//          } else if (dataKey.containsKey(param.getDataCode())) {
//            //dataKeyのデータを追加しようとします
//            result.put(key, reportServiceImpl.formatValue(param, dataKey.get(param.getDataCode())));
//          }
//        });
//      }
//    });
//    // 補正データが存在する場合に処理を実施
//    if (tmplCorrectData.repNumList.size() > 0) {
//      // 降順にソートし、番号の大きい方(ページの後ろ)から処理を実施する
//      List<String> descKeyList = new ArrayList<>();
//      for (String keyStr : tmplCorrectData.repNumList.keySet()) {
//        descKeyList.add(keyStr);
//      }
//      Collections.sort(descKeyList, Collections.reverseOrder());
//      // 変更前key、変更後key を格納するリスト
//      Map<String, String> replaceKeyList = new HashMap<>();
//      for (String keyStr : descKeyList) {
//        // tmplCorrectData.repNumList の key と value が同じ場合は処理不要の為スキップ
//        String valueStr = tmplCorrectData.repNumList.get(keyStr);
//        if (keyStr.equals(valueStr)) {
//          continue;
//        }
//        // 応答データから変更するkeyを取得し、replaceKeyList に格納する
//        for (String resultKey : result.keySet()) {
//          // 正規表現に該当しない場合は処理対象のkeyではないためスキップ ( 該当するkeyの例：1#B7:L11-2.D11 )
//          if (!resultKey.matches("^[0-9]{1,}#.*-[0-9]{1,}\\..{2,}$")) {
//            continue;
//          }
//          // ページが異なる場合は処理をスキップ
//          String[] tmpKeyStr = keyStr.split(MULTIPLE_PAGES_SEPARATOR);
//          String keyPage = tmpKeyStr[0];
//          String keyNumber = tmpKeyStr[1];
//          String[] splitKeys = resultKey.split("\\.");
//          String[] splitPage = splitKeys[0].split(MULTIPLE_PAGES_SEPARATOR);
//          if (!splitPage[0].equals(keyPage)) {
//            continue;
//          }
//          // 「.」直前の -n が変更対象の番号ではなかった場合は処理をスキップ
//          int clipPoint = splitPage[1].indexOf("-") + 1;
//          String repeatNum = splitPage[1].substring(clipPoint);
//          if (!repeatNum.equals(keyNumber)) {
//            continue;
//          }
//          // 「.」より後ろのセルが、処理除外対象セルリストに含まれるものであった場合は処理をスキップ
//          boolean skipFlg = false;
//          for (String cellStr : tmplCorrectData.cellList) {
//            if (splitKeys[1].startsWith(cellStr)) {
//              skipFlg = true;
//            }
//          }
//          if (skipFlg) {
//            continue;
//          }
//          // 修正後のkey を　修正前のkey と合わせて格納
//          String[] tmpValueStr = valueStr.split(MULTIPLE_PAGES_SEPARATOR);
//          String valuePage = tmpValueStr[0];
//          String valueNumber = tmpValueStr[1];
//          String replaceKey = valuePage + MULTIPLE_PAGES_SEPARATOR + splitPage[1].substring(0, clipPoint) + valueNumber + "." + splitKeys[1];
//          replaceKeyList.put(resultKey, replaceKey);
//        }
//      }
//      // 格納データを退避し、key を変更して再登録
//      for (String beforeKey : replaceKeyList.keySet()) {
//        String tmpData = result.get(beforeKey);
//        result.remove(beforeKey);
//        result.put(replaceKeyList.get(beforeKey), tmpData);
//      }
//    }
//    Map<String, String> map = new HashMap<>();
//    for (String position : result.keySet()) {
//      if (position.split("#").length == 1) {
//        map.put(position, result.get(position));
//        continue;
//      }
//      Matcher n = ReportUtils.getPositionRegex().matcher(position);
//      if (n.matches()) {
//        map.put(position, result.get(position));
//        continue;
//      }
//      Matcher m = ReportUtils.getPositionRegexTmpl().matcher(position);
//      if (!m.matches()) {
//        continue;
//      }
//      String cellAddress = m.group(3);
//      String range = m.group(1).substring(m.group(1).indexOf("#") + 1);
//      if (isWithinRange(cellAddress.split(":")[0].split("-")[0], range)) {
//        map.put(position, result.get(position));
//      }
//    }
//    return map;
//  }
//
//  public static boolean isWithinRange(String cellAddress, String range) {
//    String[] rangeParts = range.split(":");
//    String startAddress = rangeParts[0];
//    String endAddress = rangeParts[rangeParts.length - 1];
//    // Parse the cell address to get the row and column numbers
//    int cellRow = Integer.parseInt(cellAddress.replaceAll("[^\\d]", ""));
//    int cellColumn = columnLetterToNumber(cellAddress.replaceAll("[^A-Za-z]", ""));
//
//    // Parse the start and end addresses to get their row and column numbers
//    int startRow = Integer.parseInt(startAddress.replaceAll("[^\\d]", ""));
//    int startColumn = columnLetterToNumber(startAddress.replaceAll("[^A-Za-z]", ""));
//    int endRow = Integer.parseInt(endAddress.replaceAll("[^\\d]", ""));
//    int endColumn = columnLetterToNumber(endAddress.replaceAll("[^A-Za-z]", ""));
//    // Check if the cell address is within the range
//    return (cellRow >= startRow && cellRow <= endRow && cellColumn >= startColumn && cellColumn <= endColumn);
//  }
//
//  public static int columnLetterToNumber(String columnLetter) {
//    int columnNumber = 0;
//    int length = columnLetter.length();
//    for (int i = 0; i < length; i++) {
//      char c = columnLetter.charAt(i);
//      columnNumber = columnNumber * 26 + (c - 'A' + 1);
//    }
//    return columnNumber;
//  }
//
//
//  /**
//   * 縮小表示を適用するidとscaleのMapを作成する.
//   *
//   * @param reportHtml          帳票デザインHTML
//   * @param params              Param要素情報
//   * @param reportOutputInfo    帳票出力情報
//   * @param formatConditionInfo 条件付き書式情報
//   * @return
//   */
//  private Map<String, String[]> createResizeFontSizeInfo(String reportHtml, List<ReportXmlParam> params, Map<String, String> reportOutputInfo, Map<String, String> formatConditionInfo) {
//    // styleからfont-sizeを取得
//    org.jsoup.nodes.Document document = Jsoup.parse(reportHtml);
//    org.jsoup.nodes.Element style = document.select("style").first();
//    if (style == null) {
//      return Collections.emptyMap();
//    }
//    if (!style.attributes().get("id").contains("_Styles")) {
//      int styleCount = document.select("style").size();
//      for (int i = 0; i < styleCount; i++) {
//        style = document.select("style").get(i);
//        if (style.attributes().get("id").contains("_Styles")) {
//          break;
//        }
//      }
//    }
//    Matcher cssMatcher = Pattern.compile("[.](\\w+)\\s*[{]([^}]+)[}]").matcher(style.html());
//    // classとfont-sizeのMap
//    Map<String, String> fontSizes = new HashMap<>();
//    while (cssMatcher.find()) {
//      String[] fontSizeStyles = cssMatcher.group(2).split(";", -1);
//      Arrays.stream(fontSizeStyles)
//        .filter(e -> e.contains(ReportXmlParam.FONT_SIZE_NAME))
//        .findFirst()
//        .ifPresent(e -> fontSizes.put(cssMatcher.group(1), e.substring(e.indexOf(":") + 1).replace("pt", "")));
//    }
//    // idとscaleのMap
//    Map<String, String[]> resizeFontSizeInfo = new HashMap<>();
//    // paramからisShrink="1"とcolWidthが設定されているデータを対象とする
//    params.stream()
//      .filter(r -> r.needShrink())
//      .forEach(p -> {
//        // 縮小率を算出する
//        String colWidthStr = p.getColWidth();
//        if (!StringUtils.isEmpty(colWidthStr)) {
//          Double colWidth = Double.parseDouble(colWidthStr);
//          // reportOutputInfoKeyのidと上記で算出したscaleをMapにputする
//          reportOutputInfo.keySet().stream()
//            .filter(r -> r.contains(p.isTmplRepeat() ? String.format(".%s", p.getId()) : p.getId()))
//            .forEach(r -> {
//              // idからclassを取得
//              org.jsoup.nodes.Element element = document.getElementById(r.substring(r.indexOf(MULTIPLE_PAGES_SEPARATOR) + 1));
//              String fontSizeStr = "";
//              if (null != element && null != element.getElementsByAttribute("class")) {
//                fontSizeStr = fontSizes.get(element.getElementsByAttribute("class").attr("class"));
//              }
//              // 条件付き書式に該当するclassにfont-sizeが含まれる場合はそちらを優先する
//              String formatConditionClass = formatConditionInfo.get(r);
//              String fontSizeByformatCondition = fontSizes.get(formatConditionClass);
//              if (!StringUtils.isEmpty(fontSizeByformatCondition)) {
//                fontSizeStr = fontSizeByformatCondition;
//              }
//              if (!StringUtils.isEmpty(fontSizeStr)) {
//                Double fontSize = Double.parseDouble(fontSizeStr);
//                // 縮小率算出
//                List<Object[]> charInfos = getCharInfos(reportOutputInfo.get(r));
//                Integer outPutInfoCount = charInfos.stream().mapToInt(v -> Integer.valueOf(v[0].toString())).sum();
//                if (fontSize > 0 && outPutInfoCount > 0) {
//                  // 文字カウント
//                  Double wordCount = colWidth / (fontSize * 0.75);
//                  // スケールを算出する
//                  Double scale = wordCount / outPutInfoCount;
//                  // 倍率補正（0.1以下用）
//                  Double correctScale = null;
//                  // スケールが0.1以下の場合は0.1とする
//                  if (scale < 0.1) {
//                    // 補正倍率を保持
//                    correctScale = 0.1 / scale;
//                    scale = 0.1;
//                  }
//                  //スケールが1未満の場合は縮小率Mapにputする
//                  if (scale < 1) {
//                    // 文字数列幅（0.1以下は補正しているため、colWidth/scaleとはしない）
//                    Double colWidthByWordCount = outPutInfoCount * fontSize * 0.75;
//                    // 文字列幅の半分
//                    Double halfColWidthByWordCount = colWidthByWordCount / 2;
//                    // 補正倍率がある場合は文字列幅を補正する
//                    if (correctScale != null) {
//                      halfColWidthByWordCount = halfColWidthByWordCount / correctScale;
//                    }
//                    // 0: scale, 1:translate
//                    String[] scaleInfo = {
//                      String.format("%.2f", scale),
//                      String.format("%.2f", (halfColWidthByWordCount * scale) - halfColWidthByWordCount)
//                    };
//                    resizeFontSizeInfo.put(r, scaleInfo);
//                  }
//                }
//              }
//            });
//        }
//      });
//    if (resizeFontSizeInfo.containsKey("A7:BB12-1.A10:F12-1")) {
//      String[] values = resizeFontSizeInfo.get("A7:BB12-1.A10:F12-1");
//      resizeFontSizeInfo.put("A7:BB12-2.A10:F12-1", values);
//      resizeFontSizeInfo.put("A7:BB12-3.A10:F12-1", values);
//      resizeFontSizeInfo.put("A7:BB12-4.A10:F12-1", values);
//      resizeFontSizeInfo.put("A7:BB12-5.A10:F12-1", values);
//      resizeFontSizeInfo.put("A7:BB12-6.A10:F12-1", values);
//      resizeFontSizeInfo.put("A7:BB12-7.A10:F12-1", values);
//      resizeFontSizeInfo.put("A7:BB12-8.A10:F12-1", values);
//      resizeFontSizeInfo.put("A7:BB12-9.A10:F12-1", values);
//      resizeFontSizeInfo.put("A7:BB12-10.A10:F12-1", values);
//      resizeFontSizeInfo.put("A7:BB12-11.A10:F12-1", values);
//      resizeFontSizeInfo.put("A7:BB12-12.A10:F12-1", values);
//      resizeFontSizeInfo.put("A7:BB12-13.A10:F12-1", values);
//      resizeFontSizeInfo.put("A7:BB12-14.A10:F12-1", values);
//      resizeFontSizeInfo.put("A7:BB12-15.A10:F12-1", values);
//      resizeFontSizeInfo.put("A7:BB12-16.A10:F12-1", values);
//      resizeFontSizeInfo.put("A7:BB12-17.A10:F12-1", values);
//      resizeFontSizeInfo.put("A7:BB12-18.A10:F12-1", values);
//      resizeFontSizeInfo.put("A7:BB12-19.A10:F12-1", values);
//      resizeFontSizeInfo.put("A7:BB12-20.A10:F12-1", values);
//    }
//    if (resizeFontSizeInfo.containsKey("A7:BB12-1.A7:F9-1")) {
//      String[] values = resizeFontSizeInfo.get("A7:BB12-1.A7:F9-1");
//      resizeFontSizeInfo.put("A7:BB12-2.A7:F9-1", values);
//      resizeFontSizeInfo.put("A7:BB12-3.A7:F9-1", values);
//      resizeFontSizeInfo.put("A7:BB12-4.A7:F9-1", values);
//      resizeFontSizeInfo.put("A7:BB12-5.A7:F9-1", values);
//      resizeFontSizeInfo.put("A7:BB12-6.A7:F9-1", values);
//      resizeFontSizeInfo.put("A7:BB12-7.A7:F9-1", values);
//      resizeFontSizeInfo.put("A7:BB12-8.A7:F9-1", values);
//      resizeFontSizeInfo.put("A7:BB12-9.A7:F9-1", values);
//      resizeFontSizeInfo.put("A7:BB12-10.A7:F9-1", values);
//      resizeFontSizeInfo.put("A7:BB12-11.A7:F9-1", values);
//      resizeFontSizeInfo.put("A7:BB12-12.A7:F9-1", values);
//      resizeFontSizeInfo.put("A7:BB12-13.A7:F9-1", values);
//      resizeFontSizeInfo.put("A7:BB12-14.A7:F9-1", values);
//      resizeFontSizeInfo.put("A7:BB12-15.A7:F9-1", values);
//      resizeFontSizeInfo.put("A7:BB12-16.A7:F9-1", values);
//      resizeFontSizeInfo.put("A7:BB12-17.A7:F9-1", values);
//      resizeFontSizeInfo.put("A7:BB12-18.A7:F9-1", values);
//      resizeFontSizeInfo.put("A7:BB12-19.A7:F9-1", values);
//      resizeFontSizeInfo.put("A7:BB12-20.A7:F9-1", values);
//    }
//    return resizeFontSizeInfo;
//  }
//
//
//  /**
//   * 帳票出力情報を帳票デザインHTMLへ反映し、1ページ毎のhtmlのリストを取得する.
//   *
//   * @param reportHtml          帳票デザインHTML
//   * @param reportOutputInfo    帳票出力情報
//   * @param calcResult          計算結果
//   * @param formatConditionInfo 条件付き書式情報
//   * @param chartInfo           チャート情報
//   * @param resizeFontSizeInfo  縮小表示情報
//   * @return 反映後の帳票デザインHTML
//   */
//  private List<String> getReflectReportHtml(
//    String reportHtml,
//    Map<String, String> reportOutputInfo,
//    Map<String, String> calcResult,
//    Map<String, String> formatConditionInfo,
//    Map<String, String> chartInfo,
//    Map<String, String[]> resizeFontSizeInfo,
//    String facilityCd
//  ) {
//    //lmy
//    List<String> values = new ArrayList<String>();
//    for (String key : reportOutputInfo.keySet()) {
//      if (reportOutputInfo.get(key).contains(("(place)"))) {
//        values.add(reportOutputInfo.get(key));
//      }
//    }
//    // 帳票デザインHTMLをパースする
//    org.jsoup.nodes.Document document = Jsoup.parse(reportHtml);
//    org.jsoup.nodes.Element baseElement = document.getElementsByTag("body").first();
//    // 全ページ同じ内容を設定する内容をHTMLへ反映する
//    reportOutputInfo.entrySet().stream()
//      .filter(r -> r.getKey().indexOf(MULTIPLE_PAGES_SEPARATOR) < 0)
//      .forEach(r -> Optional.ofNullable(baseElement.getElementById(r.getKey())).ifPresent(e -> e.text(r.getValue())));
//    // 帳票デザインHTMLへ計算結果を反映する
//    calcResult.entrySet().stream()
//      .filter(r -> r.getKey().indexOf(MULTIPLE_PAGES_SEPARATOR) < 0)
//      .forEach(r -> {
//        org.jsoup.nodes.Element element = baseElement.getElementById(r.getKey());
//        if (element != null) {
//          if (FAILED_CALC.equals(r.getValue())) {
//            element.text(DISPLAY_HTML_ERROR);
//            element.attr("style", "color: red;");
//          } else {
//            element.text(r.getValue());
//          }
//        }
//      });
//    // 帳票デザインHTMLへ条件付き書式を反映する（全ページ）
//    formatConditionInfo.entrySet().stream()
//      .filter(f -> !f.getKey().contains(MULTIPLE_PAGES_SEPARATOR))
//      .forEach(f -> {
//        org.jsoup.nodes.Element element = baseElement.getElementById(f.getKey());
//        element.addClass(f.getValue());
//      });
//    // 帳票デザインHTMLへ縮小表示を反映する（全ページ）
//    resizeFontSizeInfo.entrySet().stream()
//      .filter(f -> !f.getKey().contains(MULTIPLE_PAGES_SEPARATOR))
//      .forEach(f -> {
//        org.jsoup.nodes.Element element = baseElement.getElementById(f.getKey());
//        ReportUtils.appendTagFontSizeScale(element, f.getValue()[0], f.getValue()[1]);
//      });
//    // ページ数を取得する
//    Integer pageCount = Math.max(getPageCount(reportOutputInfo), getPageCount(chartInfo));
//    // ページ数分、複製する
//    List<org.jsoup.nodes.Element> pageElements = new ArrayList<>();
//    pageElements.add(baseElement);
//    for (Integer i = 1; i < pageCount; i++) {
//      pageElements.add(baseElement.clone());
//    }
//    // ページごとに異なる内容を設定する内容をHTMLへ反映する
//    for (Integer i = 0; i < pageElements.size(); i++) {
//      org.jsoup.nodes.Element element = pageElements.get(i);
//      Integer count = i;
//      // データをHTMLへ反映する
//      String pageStr = String.format("%d%s", count + 1, MULTIPLE_PAGES_SEPARATOR);
//      reportOutputInfo.entrySet().stream()
//        .filter(r -> r.getKey().startsWith(pageStr))
//        .forEach(r -> {
//          String key = r.getKey().replace(pageStr, "");
//          Optional.ofNullable(element.getElementById(key)).ifPresent(e -> e.text(r.getValue()));
//        });
//      // 条件付き書式をHTMLへ反映する
//      formatConditionInfo.entrySet().stream()
//        .filter(f -> f.getKey().startsWith(pageStr))
//        .forEach(f -> {
//          String key = f.getKey().replace(pageStr, "");
//          Optional.ofNullable(element.getElementById(key)).ifPresent(e -> e.addClass(f.getValue()));
//        });
//      // 縮小表示を反映する
//      resizeFontSizeInfo.entrySet().stream()
//        .filter(f -> f.getKey().startsWith(pageStr))
//        .forEach(f -> {
//          String key = f.getKey().replace(pageStr, "");
//          Optional.ofNullable(element.getElementById(key)).ifPresent(e -> {
//            ReportUtils.appendTagFontSizeScale(e, f.getValue()[0], f.getValue()[1]);
//          });
//        });
//      // バイタルグラフをHTMLに反映する
//      chartInfo.entrySet().stream()
//        .filter(r -> r.getKey().startsWith(pageStr))
//        .forEach(r -> {
//          String key = r.getKey().replace(pageStr, "");
//          String value = r.getValue();
//          Optional.ofNullable(element.getElementById(key)).ifPresent(e -> {
//            org.jsoup.nodes.Element chartElm = e.appendElement("img");
//            chartElm.attr("src", String.format("data:image/png+xml;base64,%s", value));
//            chartElm.attr("width", "100%");
//            chartElm.attr("height", "100%");
//          });
//        });
//      // 複数のページを[page-break]で結合する.
//      // リストの先頭要素をベースにし、bady部に追加する.
//      // 追加する際に[page-break]を設定する.
//      if (i > 0) {
//        baseElement.append(getPageBreakString());
//        baseElement.append(element.html());
//      }
//    }
//    // 作成したHTMLを文字列に変換し、リストに設定する.
//    List<String> htmlList = new ArrayList<>();
//    // 作成したHTMLを設定
//    htmlList.add(document.html());
//    // add #6009患者イベントのカテゴリについて 李 start
//    String s3BucketInFcd = String.format(s3BucketforImage, facilityCd);
//    // 画像を取得し出力内容に含める
//    List<String> res = new ArrayList<String>();
//    for (String html : htmlList) {
//      if (values.isEmpty() == false) {
//        for (String value : values) {
//          String path = value.substring(7, value.length());
//          String bucket = "";
//          // レスポンス用データ生成
//          byte[] content = reportS3Service.getOutputFileData(s3BucketInFcd, path);
//          bucket = Base64.getEncoder().encodeToString(content);
//          bucket = String.format("data:image/png+xml;base64,%s", bucket);
//          String used = "<img src='" + bucket + "' width='100%' height='100%'/>";
//          html = html.replace(value, used);
//        }
//      }
//      res.add(html);
//    }
//    return res.isEmpty() ? htmlList : res;
//  }
//
//  /**
//   * ページ総数を取得します.
//   *
//   * @param reportOutputInfo 帳票出力情報
//   * @return ページ総数
//   */
//  private int getPageCount(Map<String, String> reportOutputInfo) {
//    return reportOutputInfo.keySet().stream()
//      .filter(r -> r.indexOf(MULTIPLE_PAGES_SEPARATOR) >= 0)
//      .map(r -> r.substring(0, r.indexOf(MULTIPLE_PAGES_SEPARATOR)))
//      .map(Integer::valueOf)
//      .max(Comparator.comparingInt(v -> v))
//      .orElse(1);
//  }
//
//  /**
//   * 集計データ配列の初期化処理
//   *
//   * @param paramsInTempl           テンプレート内のパラメータを格納する変数
//   * @param dataKeyInOfTemplateList テンプレート内のデータを取得する為のdataKey
//   * @return 初期化した集計データ配列
//   */
//// mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen start
//  // public String[][] infostrB(
//  //   List<ReportXmlParam> paramsInTempl,
//  //   Map<String, Object> dataKeyInOfTemplateList,
//  //   List<ReportXmlParam> paramsOutTempl,
//  //   Map<Long, List<Map<String, Object>>> reportInfoForTempl) {
//  public String[][] infostrB(
//    List<ReportXmlParam> paramsInTempl,
//    Map<String, Object> dataKeyInOfTemplateList,
//    Map<Long, List<Map<String, Object>>> reportInfoForTempl,
//    String[][][] param1,
//    Map<String, String> param2,
//    // add 11010 スケジュール表出力時の処理が不足している gjn start
//    Map<String, Object> dataKey) {
//    // add 11010 スケジュール表出力時の処理が不足している gjn end
//    String[][] arrtotalUnitH;
//    String[][] arrtotalUnitV;
//    String totalUnitV = param2.get("totalUnitV");
//    String totalUnitDate = param2.get("totalUnitDate");
//    String totalUnitH = param2.get("totalUnitH");
//    String totalContents = param2.get("totalContents");
//    // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen end
//    // 集計のデータ配列図:
//    //============================================================//
//    //              横の集計単位  横の集計単位  横の集計単位  合計       //
//    // 縦の集計単位   集計データ    集計データ    集計データ   横の合計値  //
//    // 縦の集計単位   集計データ    集計データ    集計データ　　横の合計値  //
//    // 縦の集計単位   集計データ    集計データ    集計データ　　横の合計値  //
//    // 合計          縦の合計値    縦の合計値  　縦の合計値             //
//    //===========================================================//
//    int Lines = 0;
//    String strTemp = "";
//    String strDataType = "";
//    List<String> strList = new ArrayList<String>();
//    int Column = 0;
//    Long sqlCd = 0L;
//    String[][] strB;
//    Map<String, Object> record;
//    Map<Long, List<Map<String, Object>>> reportInfoForInTempl = null;
//    String num = "";
//    for (ReportXmlParam param : paramsInTempl) {
//      List<ReportXmlFilterTable> filters = param.getReportXmlFilters();
//      if (filters == null || filters.size() == 0) {
//        continue;
//      }
//      num = filters.get(0).getCode();
//      dataKeyInOfTemplateList.put("examItemCd", num);
//      break;
//    }
//    // ⓵:縦の集計単位の取得処理
//    // SQLでDBから集計データを取得する
//    if (reportInfoForTempl.size() > 0) {
//      reportInfoForInTempl = reportInfoForTempl;
//    } else {
//      reportInfoForInTempl = getReportInfo(paramsInTempl, dataKeyInOfTemplateList);
//    }
//    sqlCd = Long.parseLong(paramsInTempl.get(0).getSqlCode());
//    // add 10998 「週間.医材」の出力内容修正 gjn start
//    // infostrBの繰り返し呼び出しを回避するためのtotalDataListの修正
//    if (totalDataList.size() > 0) {
//      totalDataList.clear();
//    }
//    // add 10998 「週間.医材」の出力内容修正 gjn end
//    totalDataList.add(reportInfoForInTempl);
//    if (totalDataList.size() > 1 && (sqlCd == SQL_CD_SUPPLIES_CNT || sqlCd == 156L)) {
//      for (int i = 0; i < totalDataList.size(); i++) {
//        if (equalLists(totalDataList.get(i).get(sqlCd), reportInfoForInTempl.get(sqlCd))) {
//          return new String[Lines][Column];
//        }
//      }
//    }
//    if (!StringUtils.isEmpty(totalUnitH) && totalUnitH.startsWith("##")) {
//      strList = totalUnitHList;
//      isDateType.set(false);
//    } else if (!StringUtils.isEmpty(totalUnitV) && totalUnitV.startsWith("##")) {
//      strList = totalUnitVList;
//      isDateType.set(true);
//    } else {
//      if (reportInfoForInTempl.get(sqlCd) != null && reportInfoForInTempl.get(sqlCd).size() != 0) {
//        record = reportInfoForInTempl.get(sqlCd).get(0);
//        strTemp = String.valueOf(record.get(totalUnitHList.get(0)));
//        // 日付判定処理
//        if (isDate(strTemp) && totalUnitHList.get(0).equals("pat_id") == false) {
//          strDataType = totalUnitVList.get(0);
//          isDateType.set(true);
//        } else {
//          strDataType = totalUnitHList.get(0);
//          isDateType.set(false);
//        }
//        strList = dataList(reportInfoForInTempl, sqlCd, strDataType);
//        switch (String.valueOf(sqlCd)) {
//          case "152":
//            // mod 11010 スケジュール表出力時の処理が不足している gjn start
//            // 初期化ごとに繰り返し呼び出さない
//            strKurNameList.clear();
//            List<Long> kurCdLists = new ArrayList<>();
//            if (dataKey.containsKey("functionCd") && !Objects.isNull(dataKey.get("functionCd"))) {
//              List<Integer> kurCdListsTemp = dataKey.containsKey("selectKurCd") ? (List<Integer>) dataKey.get("selectKurCd") : null;
//              if (!Objects.isNull(kurCdListsTemp)) {
//                kurCdListsTemp.forEach(f -> {
//                  kurCdLists.add(f.longValue());
//                });
//              }
//            } else {
//              if (dataKey.containsKey("kurCdLists")) {
//                kurCdLists.addAll((List<Long>) dataKey.get("kurCdLists"));
//              }
//            }
//            // スケジュール表 全クール を取得する
//            List<MstKur> retList = scheduleListDao.selectKurNameList(String.valueOf(dataKeyInOfTemplateList.get("facilityCd")));
//            if (kurCdLists != null && kurCdLists.size() > 0 && retList != null && retList.size() > 0) {
//              for (Long kur : kurCdLists) {
//                for (MstKur mstKur : retList) {
//                  if (kur == mstKur.getKurCd().longValue()) {
//                    strKurNameList.add(mstKur.getKurName());
//                  }
//                }
//              }
//            } else {
//              for (MstKur list : retList) {
//                strKurNameList.add(list.getKurName());
//              }
//            }
//            // スケジュール表 予約数／ベッド未登録数 を取得する
////            if (!reportInfoForInTempl.containsKey("153L")) {
////              List<Map<String, Object>> res2 = sysDataSetService.getDataList(153L, dataKeyInOfTemplateList);
////              reportInfoForInTempl.put(153L, res2);
////            }
//            // mod 11010 スケジュール表出力時の処理が不足している gjn end
//            break;
//          case "197":
//            //クエリ条件を追加するフィルタリングです
//            //'1:透析前 2:透析後 0:その他
//            ArrayList<String> regOrderClassList = (ArrayList<String>) dataKeyInOfTemplateList.get("regOrderClassList");
//            regOrderClassList.forEach(reg -> {
//              if ("1".equals(reg)) {
//                strKurNameList.add("透析前");
//              }
//              if ("2".equals(reg)) {
//                strKurNameList.add("透析後");
//              }
//              if ("0".equals(reg)) {
//                strKurNameList.add("その他");
//              }
//            });
//            break;
//          default:
//            break;
//        }
//        strKurNameList = strKurNameList.stream().distinct().collect(Collectors.toList());
//      }
//    }
//    if (strList.size() == 0 || strList == null) {
//      return new String[Lines][Column];
//    }
//    // ⓶:配列の横列サイズを計算する。　偏移量２:（縦の集計単位　＋　縦の合計）
//    Lines = strList.size() + TOTAL_COUNTS_OFFSET_2;
//    // ⓷:縦の集計単位の取得処理
//    // 開始時間
//    String fromDate = DateFormat(String.valueOf(dataKeyInOfTemplateList.get("fromDate")));
//    // 終了時間
//    String toDate = DateFormat(String.valueOf(dataKeyInOfTemplateList.get("toDate")));
//    // 時間転換処理
//    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
//    Calendar bef = Calendar.getInstance();
//    Calendar aft = Calendar.getInstance();
//    int dateCount = 0;
//    // add #11293 水質検査帳票の課題対応 limingzhe start
//    List<String> strListV = new ArrayList<>();
//    // mod #11950 複数集計帳票の印刷で出力可能なページ数だが100ページ制限となり出力できない。 limingzhe start
////    if(sqlCd == 127l){
//    if(param2.get("effectDateFlag").equals("1")){
//    // mod #11950 複数集計帳票の印刷で出力可能なページ数だが100ページ制限となり出力できない。 limingzhe end
//      String[] tUnitV = totalUnitV.split(",");
//      if(tUnitV.length > 0){
//        strListV = dataList(reportInfoForInTempl, sqlCd, tUnitV[0]);
//        dateCount = strListV.size() + TOTAL_COUNTS_OFFSET_3;
//      }
//    } else {
//    // add #11293 水質検査帳票の課題対応 limingzhe end
//      try {
//        bef.setTime(sdf.parse(fromDate));
//        aft.setTime(sdf.parse(toDate));
//      } catch (ParseException e) {
//        e.printStackTrace();
//      }
//      int monthSection = aft.get(Calendar.MONTH) - bef.get(Calendar.MONTH);
//      int yearSection = aft.get(Calendar.YEAR) - bef.get(Calendar.YEAR);
//      // ⓸:集計単位日付属性により、配列の縦列サイズを計算する。　偏移量３：（縦の集計単位　＋　有効データ　＋　横の合計）
//      if ("月".equals(totalUnitDate)) {
//        if (yearSection <= 0) {
//          dateCount = monthSection + TOTAL_COUNTS_OFFSET_3;
//        } else {
//          dateCount = 12 * yearSection + monthSection + TOTAL_COUNTS_OFFSET_3;
//        }
//      } else if ("年".equals(totalUnitDate)) {
//        dateCount = yearSection + TOTAL_COUNTS_OFFSET_3;
//      } else {
//        // ”日”指定の場合、日付差を計算後で設定する。
//        long time1 = bef.getTimeInMillis();
//        long time2 = aft.getTimeInMillis();
//        long between_days = (time2 - time1) / (1000 * 3600 * 24);
//        dateCount = Integer.parseInt(String.valueOf(between_days)) + TOTAL_COUNTS_OFFSET_3;
//      }
//    // add #11293 水質検査帳票の課題対応 limingzhe start
//    }
//    // add #11293 水質検査帳票の課題対応 limingzhe end
//    // ⓹:配列の横列サイズと配列の縦列サイズにより、配列の初期化
//    Column = dateCount;
//    if (isDateType.get()) {
//      Column = Lines;
//      Lines = dateCount;
//      if (strKurNameList.size() > 0) {
//        Lines = (Lines - 2) * strKurNameList.size() + 2;
//      }
//    } else {
//      if (strKurNameList.size() > 0) {
//        Column = (Column - 2) * strKurNameList.size() + 2;
//      }
//    }
//    arrtotalUnitV = new String[totalUnitVList.size()][Column];
//    for (int i = 0; i < totalUnitVList.size(); i++) {
//      arrtotalUnitV[i][0] = totalUnitVList.get(i);
//      for (int j = 1; j < Column; j++) {
//        arrtotalUnitV[i][j] = "0";
//      }
//    }
//    arrtotalUnitH = new String[totalUnitHList.size()][Lines];
//    for (int i = 0; i < totalUnitHList.size(); i++) {
//      arrtotalUnitH[i][0] = totalUnitHList.get(i);
//      for (int j = 1; j < Lines; j++) {
//        arrtotalUnitH[i][j] = "0";
//      }
//    }
//    strB = new String[Lines][Column];
//    for (int i = 0; i < Lines; i++) {
//      for (int j = 0; j < Column; j++) {
//        strB[i][j] = "0";
//      }
//    }
//    if (totalContents.equals("項目値") && strKurNameList.size() > 0) {
//      for (int i = 1; i < Lines - 1; i++) {
//        for (int j = 1; j < Column - 1; j++) {
//          strB[i][j] = "";
//        }
//      }
//    }
//    strB[0][0] = "";
//    // ⓺:配列の横の集計単位の設定処理
//    try {
//      int years, months, mcount = 1;
//      if (isDateType.get()) {
//        for (int i = 1; i < Lines - 1; i++) {
//          // add #11293 水質検査帳票の課題対応 limingzhe start
//          // mod #11950 複数集計帳票の印刷で出力可能なページ数だが100ページ制限となり出力できない。 limingzhe start
////          if(sqlCd == 127l){
//          if(param2.get("effectDateFlag").equals("1")){
//          // mod #11950 複数集計帳票の印刷で出力可能なページ数だが100ページ制限となり出力できない。 limingzhe end
//            if(i-1 >= strListV.size()) continue;
//            strB[0][i] = strListV.get(i-1).replace("/", "").replace("-", "");
//            arrtotalUnitV[0][i] = strB[0][i];
//          } else {
//          // add #11293 水質検査帳票の課題対応 limingzhe end
//            if ("月".equals(totalUnitDate)) {
//              // 開始時間の日から増加する。　ただし、12ヶ月以上時年を変換する
//              if (bef.get(Calendar.MONTH) + i > 12) {
//                if (bef.get(Calendar.MONTH) + i - 12 * mcount > 12) {
//                  mcount++;
//                }
//                years = bef.get(Calendar.YEAR) + mcount;
//                months = bef.get(Calendar.MONTH) + i - 12 * mcount;
//              } else {
//                years = bef.get(Calendar.YEAR);
//                months = bef.get(Calendar.MONTH) + i;
//              }
//              strB[i][0] = years + String.format("%02d", months);
//            } else if ("年".equals(totalUnitDate)) {
//              // 開始時間の年から増加する
//              if (i == 1) {
//                strB[i][0] = fromDate.substring(0, 4);
//              } else {
//                bef.add(Calendar.YEAR, 1);
//                Date date = bef.getTime();
//                strB[i][0] = sdf.format(date).substring(0, 4);
//                bef.setTime(sdf.parse(strB[i][0] + "0101"));
//              }
//            } else {
//              // 開始時間の日から増加する
//              // add #6691 複数集計：対象項目の不足対応 夏 start
//              if (strKurNameList.size() > 0) {
//                if (i + strKurNameList.size() >= Lines) {
//                  break;
//                }
//                for (int n = 0; n < strKurNameList.size(); n++) {
//                  if (i == 1) {
//                    strB[i + n][0] = fromDate;
//                    arrtotalUnitH[0][i + n] = fromDate;
//                  } else {
//                    if (n == 0) {
//                      bef.add(Calendar.DATE, 1);
//                    }
//                    Date date = bef.getTime();
//                    strB[i + n][0] = sdf.format(date);
//                    arrtotalUnitH[0][i + n] = sdf.format(date);
//                    bef.setTime(sdf.parse(strB[i + n][0]));
//                  }
//                  if (arrtotalUnitH.length > 1) {
//                    arrtotalUnitH[1][i + n] = strKurNameList.get(n);
//                  }
//                }
//                i = i + strKurNameList.size() - 1;
//                strB[Lines - 1][1] = "";
//              } else {
//                if (i == 1) {
//                  strB[i][0] = fromDate;
//                } else {
//                  bef.add(Calendar.DATE, 1);
//                  Date date = bef.getTime();
//                  strB[i][0] = sdf.format(date);
//                  bef.setTime(sdf.parse(strB[i][0]));
//                }
//                arrtotalUnitH[0][i] = strB[i][0];
//              }
//            }
//          // add #11293 水質検査帳票の課題対応 limingzhe start
//          }
//          // add #11293 水質検査帳票の課題対応 limingzhe end
//        }
//      } else {
//        for (int i = 1; i < Column - 1; i++) {
//          // add #11293 水質検査帳票の課題対応 limingzhe start
//          // mod #11950 複数集計帳票の印刷で出力可能なページ数だが100ページ制限となり出力できない。 limingzhe start
////          if(sqlCd == 127l){
//          if(param2.get("effectDateFlag").equals("1")){
//          // mod #11950 複数集計帳票の印刷で出力可能なページ数だが100ページ制限となり出力できない。 limingzhe end
//            if(i-1 >= strListV.size()) continue;
//            strB[0][i] = strListV.get(i-1).replace("/", "").replace("-", "");
//            arrtotalUnitV[0][i] = strB[0][i];
//          } else {
//          // add #11293 水質検査帳票の課題対応 limingzhe end
//            if ("月".equals(totalUnitDate)) {
//              // 開始時間の日から増加する。　ただし、12ヶ月以上時年を変換する
//              if (bef.get(Calendar.MONTH) + i > 12) {
//                if (bef.get(Calendar.MONTH) + i - 12 * mcount > 12) {
//                  mcount++;
//                }
//                years = bef.get(Calendar.YEAR) + mcount;
//                months = bef.get(Calendar.MONTH) + i - 12 * mcount;
//              } else {
//                years = bef.get(Calendar.YEAR);
//                months = bef.get(Calendar.MONTH) + i;
//              }
//              strB[0][i] = years + String.format("%02d", months);
//            } else if ("年".equals(totalUnitDate)) {
//              // 開始時間の年から増加する
//              if (i == 1) {
//                strB[0][i] = fromDate.substring(0, 4);
//              } else {
//                bef.add(Calendar.YEAR, 1);
//                Date date = bef.getTime();
//                strB[0][i] = sdf.format(date).substring(0, 4);
//                bef.setTime(sdf.parse(strB[0][i] + "0101"));
//              }
//            } else {
//              // 開始時間の日から増加する
//              if (strKurNameList.size() > 0) {
//                if (i + strKurNameList.size() >= Column) {
//                  break;
//                }
//                for (int n = 0; n < strKurNameList.size(); n++) {
//                  if (i == 1) {
//                    strB[0][i + n] = fromDate;
//                    arrtotalUnitV[0][i + n] = fromDate;
//                  } else {
//                    if (n == 0) {
//                      bef.add(Calendar.DATE, 1);
//                    }
//                    Date date = bef.getTime();
//                    strB[0][i + n] = sdf.format(date);
//                    arrtotalUnitV[0][i + n] = sdf.format(date);
//                    bef.setTime(sdf.parse(strB[0][i + n]));
//                  }
//                  if (arrtotalUnitV.length > 1) {
//                    arrtotalUnitV[1][i + n] = strKurNameList.get(n);
//                  }
//                }
//                i = i + strKurNameList.size() - 1;
//                strB[1][Column - 1] = "";
//              } else {
//                if (i == 1) {
//                  strB[0][i] = fromDate;
//                } else {
//                  bef.add(Calendar.DATE, 1);
//                  Date date = bef.getTime();
//                  strB[0][i] = sdf.format(date);
//                  bef.setTime(sdf.parse(strB[0][i]));
//                }
//                arrtotalUnitV[0][i] = strB[0][i];
//              }
//            }
//          // add #11293 水質検査帳票の課題対応 limingzhe start
//          }
//          // add #11293 水質検査帳票の課題対応 limingzhe end
//        }
//      }
//    } catch (ParseException e) {
//      e.printStackTrace();
//    }
//    // ⓻:配列の縦の集計単位の設定処理
//    // 縦の合計してないの場合、配列の最終行も集計データを設定する。
//    for (int i = 1; i <= strList.size(); i++) {
//      if (isDateType.get()) {
//        strB[0][i] = strList.get(i - 1);
//      } else {
//        strB[i][0] = strList.get(i - 1);
//      }
//    }
//    int index = 0;
//    if (isDateType.get()) {
//      for (int j = 1; j <= strList.size(); j++) {
//        arrtotalUnitV[0][j] = strList.get(index++);
//      }
//    } else {
//      for (int j = 1; j <= strList.size(); j++) {
//        arrtotalUnitH[0][j] = strList.get(index++);
//      }
//    }
//    // add #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen start
//    String[][][] arrtotalUnit = new String[2][][];
//    arrtotalUnit[0] = arrtotalUnitV;
//    arrtotalUnit[1] = arrtotalUnitH;
//    // add #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen start
//    switch (String.valueOf(sqlCd)) {
//      // スケジュール表(２次元)の予約数と未登録数を編集する
//      case "152":
//        for (int j = 0; j < reportInfoForInTempl.get(153L).size(); j++) {
//          record = reportInfoForInTempl.get(153L).get(j);
//          for (int i = 1; i < arrtotalUnitV[0].length; i++) {
//            // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen start
//            // if (totalUnitindex("treat_date") == -1 || totalUnitindex("kur_name") == -1) {
//            //   continue;
//            // }
//            // if (arrtotalUnitV[totalUnitindex("treat_date")][i].equals(String.valueOf(record.get("treat_date")))
//            //   && arrtotalUnitV[totalUnitindex("kur_name")][i].equals(String.valueOf(record.get("kur_name")))) {
//            //   if (totalUnitindex("bed_unreg_count") >= 0) {
//            //     arrtotalUnitV[totalUnitindex("bed_unreg_count")][i] = String.valueOf(record.get("bed_unreg_count"));
//            //   }
//            //   if (totalUnitindex("count") >= 0) {
//            //     arrtotalUnitV[totalUnitindex("count")][i] = String.valueOf(record.get("count"));
//            if (totalUnitindex("treat_date", arrtotalUnit) == -1 || totalUnitindex("kur_name", arrtotalUnit) == -1) {
//              continue;
//            }
//            if (arrtotalUnitV[totalUnitindex("treat_date", arrtotalUnit)][i].equals(String.valueOf(record.get("treat_date")))
//              && arrtotalUnitV[totalUnitindex("kur_name", arrtotalUnit)][i].equals(String.valueOf(record.get("kur_name")))) {
//              if (totalUnitindex("bed_unreg_count", arrtotalUnit) >= 0) {
//                arrtotalUnitV[totalUnitindex("bed_unreg_count", arrtotalUnit)][i] = String.valueOf(record.get("bed_unreg_count"));
//              }
//              if (totalUnitindex("count", arrtotalUnit) >= 0) {
//                arrtotalUnitV[totalUnitindex("count", arrtotalUnit)][i] = String.valueOf(record.get("count"));
//                // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen end
//              }
//            }
//          }
//        }
//        break;
//      case "149":
//        if (reportInfoForInTempl.get(SQL_CD_OUT_PAT_CNT) != null && reportInfoForInTempl.get(SQL_CD_OUT_PAT_CNT).size() > 0) {
//          for (int j = 0; j < reportInfoForInTempl.get(SQL_CD_OUT_PAT_CNT).size(); j++) {
//            record = reportInfoForInTempl.get(SQL_CD_OUT_PAT_CNT).get(j);
//            for (int i = 1; i < arrtotalUnitV[0].length; i++) {
//              // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen start
//              // if (arrtotalUnitV[totalUnitindex("supplies_base_date")][i].equals(String.valueOf(record.get("reg_date")))) {
//              //   if (totalUnitindex("out_pat_cnt") >= 0) {
//              //     arrtotalUnitV[totalUnitindex("out_pat_cnt")][i] = String.valueOf(record.get("out_pat_cnt"));
//              //     arrtotalUnitV[totalUnitindex("out_pat_cnt")][arrtotalUnitV[0].length - 1] =
//              //       formatBigDecimal(String.valueOf(record.get("out_pat_cnt")),
//              //         arrtotalUnitV[totalUnitindex("out_pat_cnt")][arrtotalUnitV[0].length - 1]);
//              if (arrtotalUnitV[totalUnitindex("supplies_base_date", arrtotalUnit)][i].equals(String.valueOf(record.get("reg_date")))) {
//                if (totalUnitindex("out_pat_cnt", arrtotalUnit) >= 0) {
//                  arrtotalUnitV[totalUnitindex("out_pat_cnt", arrtotalUnit)][i] = String.valueOf(record.get("out_pat_cnt"));
//                  arrtotalUnitV[totalUnitindex("out_pat_cnt", arrtotalUnit)][arrtotalUnitV[0].length - 1] =
//                    formatBigDecimal(String.valueOf(record.get("out_pat_cnt")),
//                      arrtotalUnitV[totalUnitindex("out_pat_cnt", arrtotalUnit)][arrtotalUnitV[0].length - 1]);
//                  // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen end
//                }
//              }
//            }
//          }
//        }
//        if (reportInfoForInTempl.get(SQL_CD_HOSP_PAT_CNT) != null && reportInfoForInTempl.get(SQL_CD_HOSP_PAT_CNT).size() > 0) {
//          for (int j = 0; j < reportInfoForInTempl.get(SQL_CD_HOSP_PAT_CNT).size(); j++) {
//            record = reportInfoForInTempl.get(SQL_CD_HOSP_PAT_CNT).get(j);
//            for (int i = 1; i < arrtotalUnitV[0].length; i++) {
//              // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen start
//              // if (arrtotalUnitV[totalUnitindex("supplies_base_date")][i].equals(String.valueOf(record.get("reg_date")))) {
//              //   if (totalUnitindex("hosp_pat_cnt") >= 0) {
//              //     arrtotalUnitV[totalUnitindex("hosp_pat_cnt")][i] = String.valueOf(record.get("hosp_pat_cnt"));
//              //     arrtotalUnitV[totalUnitindex("hosp_pat_cnt")][arrtotalUnitV[0].length - 1] =
//              //       formatBigDecimal(String.valueOf(record.get("hosp_pat_cnt")),
//              //         arrtotalUnitV[totalUnitindex("hosp_pat_cnt")][arrtotalUnitV[0].length - 1]);
//              if (arrtotalUnitV[totalUnitindex("supplies_base_date", arrtotalUnit)][i].equals(String.valueOf(record.get("reg_date")))) {
//                if (totalUnitindex("hosp_pat_cnt", arrtotalUnit) >= 0) {
//                  arrtotalUnitV[totalUnitindex("hosp_pat_cnt", arrtotalUnit)][i] = String.valueOf(record.get("hosp_pat_cnt"));
//                  arrtotalUnitV[totalUnitindex("hosp_pat_cnt", arrtotalUnit)][arrtotalUnitV[0].length - 1] =
//                    formatBigDecimal(String.valueOf(record.get("hosp_pat_cnt")),
//                      arrtotalUnitV[totalUnitindex("hosp_pat_cnt", arrtotalUnit)][arrtotalUnitV[0].length - 1]);
//                  // mod #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen end
//                }
//              }
//            }
//          }
//        }
//        break;
//      default:
//        break;
//    }
//    // add #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen Start
//    param1[0] = arrtotalUnitH;
//    param1[1] = arrtotalUnitV;
//    // add #10546 システム内でstatic変数を使っている箇所の洗い出し dengshen end
//    return strB;
//  }
//
//
//  // add 10546 複数集計出力時にサーバが高負荷になる gjn start
//  /**
//   * 改ページ数の計算
//   *
//   * @param paramsInTempl
//   * @param dataKeyInOfTemplateList
//   * @param reportInfoForInTempl
//   * @param param2
//   * @param dataKey
//   * @return
//   */
//  public String[][] calculateNumberOfPages(
//    List<ReportXmlParam> paramsInTempl,
//    Map<String, Object> dataKeyInOfTemplateList,
//    Map<Long, List<Map<String, Object>>> reportInfoForInTempl,
//    Map<String, String> param2,
//    Map<String, Object> dataKey) {
//    String totalUnitDate = param2.get("totalUnitDate");
//    List<Map<Long, List<Map<String, Object>>>> totalDataList = new CopyOnWriteArrayList<>();
//    int Lines = 0;
//    String strTemp = "";
//    String strDataType = "";
//    List<String> strList = new ArrayList<String>();
//    int Column = 0;
//    Map<String, Object> record;
//    Long sqlCd = Long.parseLong(paramsInTempl.get(0).getSqlCode());
//    totalDataList.add(reportInfoForInTempl);
//    if (totalDataList.size() > 1 && (sqlCd == SQL_CD_SUPPLIES_CNT || sqlCd == 156L)) {
//      for (int i = 0; i < totalDataList.size(); i++) {
//        if (equalLists(totalDataList.get(i).get(sqlCd), reportInfoForInTempl.get(sqlCd))) {
//          return new String[Lines][Column];
//        }
//      }
//    }
//    if (reportInfoForInTempl.get(sqlCd) != null && reportInfoForInTempl.get(sqlCd).size() != 0) {
//      record = reportInfoForInTempl.get(sqlCd).get(0);
//      strTemp = String.valueOf(record.get(totalUnitHList.get(0)));
//      // 日付判定処理
//      if (isDate(strTemp) && totalUnitHList.get(0).equals("pat_id") == false) {
//        strDataType = totalUnitVList.get(0);
//        isDateType.set(true);
//      } else {
//        strDataType = totalUnitHList.get(0);
//        isDateType.set(false);
//      }
//      strList = dataList(reportInfoForInTempl, sqlCd, strDataType);
//      switch (String.valueOf(sqlCd)) {
//        case "152":
//          List<Long> kurCdLists = (List<Long>) dataKey.get("kurCdLists");
//          // スケジュール表 クール を取得する
//          List<MstKur> retList = scheduleListDao.selectKurNameList(String.valueOf(dataKeyInOfTemplateList.get("facilityCd")));
//          if (kurCdLists != null && kurCdLists.size() > 0) {
//            List<MstKur> retListFilter = retList.stream()
//              .filter(erv -> {
//                Long kurCd = !Objects.isNull(erv.getKurCd()) ? erv.getKurCd().longValue() : null;
//                return kurCdLists.contains(kurCd);
//              }).collect(toList());
//            for (MstKur list : retListFilter) {
//              strKurNameList.add(list.getKurName());
//            }
//          } else {
//            for (MstKur list : retList) {
//              strKurNameList.add(list.getKurName());
//            }
//          }
//          break;
//        case "197":
//          //クエリ条件を追加するフィルタリングです
//          //'1:透析前 2:透析後 0:その他
//          ArrayList<String> regOrderClassList = (ArrayList<String>) dataKeyInOfTemplateList.get("regOrderClassList");
//          regOrderClassList.forEach(reg -> {
//            if ("1".equals(reg)) {
//              strKurNameList.add("透析前");
//            }
//            if ("2".equals(reg)) {
//              strKurNameList.add("透析後");
//            }
//            if ("0".equals(reg)) {
//              strKurNameList.add("その他");
//            }
//          });
//          break;
//        default:
//          break;
//      }
//      strKurNameList = strKurNameList.stream().distinct().collect(Collectors.toList());
//    }
//
//    if (strList.size() == 0 || strList == null) {
//      return new String[Lines][Column];
//    }
//    // ⓶:配列の横列サイズを計算する。　偏移量２:（縦の集計単位　＋　縦の合計）
//    Lines = strList.size() + TOTAL_COUNTS_OFFSET_2;
//    // ⓷:縦の集計単位の取得処理
//    // add #11950 複数集計帳票の印刷で出力可能なページ数だが100ページ制限となり出力できない。 limingzhe start
//    int dateCount = 0;
//    // mod #11950 複数集計帳票の印刷で出力可能なページ数だが100ページ制限となり出力できない。 limingzhe start
////    if(sqlCd != 127l){
//     if(!param2.get("effectDateFlag").equals("1")){
//     // mod #11950 複数集計帳票の印刷で出力可能なページ数だが100ページ制限となり出力できない。 limingzhe end
//    // add #11950 複数集計帳票の印刷で出力可能なページ数だが100ページ制限となり出力できない。 limingzhe end
//      // 開始時間
//      String fromDate = DateFormat(String.valueOf(dataKeyInOfTemplateList.get("fromDate")));
//      // 終了時間
//      String toDate = DateFormat(String.valueOf(dataKeyInOfTemplateList.get("toDate")));
//      // 時間転換処理
//      SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
//      Calendar bef = Calendar.getInstance();
//      Calendar aft = Calendar.getInstance();
//      try {
//        bef.setTime(sdf.parse(fromDate));
//        aft.setTime(sdf.parse(toDate));
//      } catch (ParseException e) {
//        e.printStackTrace();
//      }
//      int monthSection = aft.get(Calendar.MONTH) - bef.get(Calendar.MONTH);
//      int yearSection = aft.get(Calendar.YEAR) - bef.get(Calendar.YEAR);
//      // ⓸:集計単位日付属性により、配列の縦列サイズを計算する。　偏移量３：（縦の集計単位　＋　有効データ　＋　横の合計）
//      if ("月".equals(totalUnitDate)) {
//        if (yearSection <= 0) {
//          dateCount = monthSection + TOTAL_COUNTS_OFFSET_3;
//        } else {
//          dateCount = 12 * yearSection + monthSection + TOTAL_COUNTS_OFFSET_3;
//        }
//      } else if ("年".equals(totalUnitDate)) {
//        dateCount = yearSection + TOTAL_COUNTS_OFFSET_3;
//      } else {
//        // ”日”指定の場合、日付差を計算後で設定する。
//        long time1 = bef.getTimeInMillis();
//        long time2 = aft.getTimeInMillis();
//        long between_days = (time2 - time1) / (1000 * 3600 * 24);
//        dateCount = Integer.parseInt(String.valueOf(between_days)) + TOTAL_COUNTS_OFFSET_3;
//      }
//    // add #11950 複数集計帳票の印刷で出力可能なページ数だが100ページ制限となり出力できない。 limingzhe start
//    } else {
//      if (isDateType.get()){
//        if(totalUnitHList.size() > 0) {
//          strList = dataList(reportInfoForInTempl, sqlCd, totalUnitHList.get(0));
//          dateCount = strList.size() + TOTAL_COUNTS_OFFSET_3;
//        }
//      } else {
//        if(totalUnitVList.size() > 0) {
//          strList = dataList(reportInfoForInTempl, sqlCd, totalUnitVList.get(0));
//          dateCount = strList.size() + TOTAL_COUNTS_OFFSET_3;
//        }
//      }
//    }
//    // add #11950 複数集計帳票の印刷で出力可能なページ数だが100ページ制限となり出力できない。 limingzhe end
//    // ⓹:配列の横列サイズと配列の縦列サイズにより、配列の初期化
//    Column = dateCount;
//    if (isDateType.get()) {
//      Column = Lines;
//      Lines = dateCount;
//      if (strKurNameList.size() > 0) {
//        Lines = (Lines - 2) * strKurNameList.size() + 2;
//      }
//    } else {
//      if (strKurNameList.size() > 0) {
//        Column = (Column - 2) * strKurNameList.size() + 2;
//      }
//    }
//    return new String[Lines][Column];
//  }
//  // add 10546 複数集計出力時にサーバが高負荷になる gjn end
//
//
//  /**
//   * 配列同じの判定処理
//   *
//   * @param one
//   * @param two
//   * @return true:配列同じ　false:配列不一致
//   */
//  public boolean equalLists(List<Map<String, Object>> one, List<Map<String, Object>> two) {
//    if (one == null && two == null) {
//      return true;
//    }
//    if ((one == null && two != null)
//      || one != null && two == null
//      || one.size() != two.size()) {
//      return false;
//    }
//    //to avoid messing the order of the lists we will use a copy
//    //as noted in comments by A. R. S.
//    one = new ArrayList<Map<String, Object>>(one);
//    two = new ArrayList<Map<String, Object>>(two);
//    return one.equals(two);
//  }
//
//  private List<String> dataList(Map<Long, List<Map<String, Object>>> reportInfoForInTempl, Long sqlCd, String strDataType) {
//    List<String> strList = new ArrayList<String>();
//    Map<String, Object> record;
//    String strTemp = "";
//    // add #11293 【標準帳票】水質検査帳票の課題対応 吉 start
//    List<String> jumpstrList = new ArrayList<String>();
//    // add #11293 【標準帳票】水質検査帳票の課題対応 吉 end
//    for (int j = 0; j < reportInfoForInTempl.get(sqlCd).size(); j++) {
//      record = reportInfoForInTempl.get(sqlCd).get(j);
//      strTemp = String.valueOf(record.get(strDataType) == null ? "" : record.get(strDataType));
//      // add #11293 【標準帳票】水質検査帳票の課題対応 吉 start
//      String jumpStr = "";
//      if(sqlCd == 127L){
//        if(!StringUtils.isEmpty(record.get("point_name"))){
//          jumpStr = record.get("point_name").toString();
//        }
//        if(!StringUtils.isEmpty(record.get("machine_name"))){
//          jumpStr = jumpStr+record.get("machine_name").toString();
//        }
//        if(!StringUtils.isEmpty(record.get("survey_type_name"))){
//          jumpStr = jumpStr+record.get("survey_type_name").toString();
//        }
//        if(!StringUtils.isEmpty(record.get("survey_point_cd"))){
//          jumpStr = jumpStr+record.get("survey_point_cd").toString();
//        }
//      }
//      // add #11293 【標準帳票】水質検査帳票の課題対応 吉 end
//      if (strList.size() == 0 && !strTemp.isEmpty()) {
//        strList.add(strTemp);
//        // add #11293 【標準帳票】水質検査帳票の課題対応 吉 start
//        jumpstrList.add(jumpStr);
//        // add #11293 【標準帳票】水質検査帳票の課題対応 吉 end
//      } else {
//        boolean flg = false;
//        // add #11293 【標準帳票】水質検査帳票の課題対応 吉 start
////        for (int i = 0; i < strList.size(); i++) {
////          if (strList.get(i).equals(strTemp)) {
////            flg = true;
////            break;
////          }
////        }
//        if(sqlCd != 127L || (sqlCd == 127L && "inspection_date_str".equals(strDataType))){
//          for (int i = 0; i < strList.size(); i++) {
//            if (strList.get(i).equals(strTemp)) {
//              flg = true;
//              break;
//            }
//          }
//        }else{
//          for (int i = 0; i < strList.size(); i++) {
//            if (jumpstrList.get(i).equals(jumpStr)) {
//              flg = true;
//              break;
//            }
//          }
//        }
//        // add #11293 【標準帳票】水質検査帳票の課題対応 吉 end
//        // 検索から同じではないデータを追加する
//        if (!flg && !strTemp.isEmpty()) {
//          strList.add(strTemp);
//          // add #11293 【標準帳票】水質検査帳票の課題対応 吉 start
//          jumpstrList.add(jumpStr);
//          // add #11293 【標準帳票】水質検査帳票の課題対応 吉 end
//        }
//      }
//    }
//    return strList;
//  }
//
//  // add #10857 帳票内に同項目が複数あると設定値を取り違える limingzhe start
//  public static List<ReportXmlParam> deepCopy(List<ReportXmlParam> originalList) {
//    List<ReportXmlParam> copiedList = new ArrayList<>();
//    for (ReportXmlParam param : originalList) {
//      copiedList.add(param);
//    }
//    return copiedList;
//  }
//  // add #10857 帳票内に同項目が複数あると設定値を取り違える limingzhe end
//}
//// mod 10546 複数集計出力時にサーバが高負荷になる gjn end
