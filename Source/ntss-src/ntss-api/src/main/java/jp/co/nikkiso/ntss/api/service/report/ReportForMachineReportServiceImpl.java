package jp.co.nikkiso.ntss.api.service.report;
// add #11117 日常点検記録簿が1ページ1装置で出力される limingzhe start

import com.aspose.cells.SaveFormat;
import jp.co.nikkiso.ntss.api.constant.ReportConstant;
import jp.co.nikkiso.ntss.api.domain.report.ReportXmlFilterTable;
import jp.co.nikkiso.ntss.api.domain.report.ReportXmlGroup;
import jp.co.nikkiso.ntss.api.domain.report.ReportXmlParam;
import jp.co.nikkiso.ntss.api.domain.report.ReportXmlTmplRepeat;
import jp.co.nikkiso.ntss.api.service.LogService;
import jp.co.nikkiso.ntss.api.service.SysDataSetService;
import jp.co.nikkiso.ntss.api.service.utils.ReportUtils;
import jp.co.nikkiso.ntss.api.service.utils.ReportZipFile;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstReportDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.entity.MstReport;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.utils.NtssUtils;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutionException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import static java.util.stream.Collectors.toList;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * 帳票の装置帳票出力Service実装クラス.
 */
@Service
@Slf4j
public class ReportForMachineReportServiceImpl implements ReportForMachineReportService {

  /**
   * 帳票出力情報のKey項目に使用する複数ページ区切り文字列.
   */
  private static final String MULTIPLE_PAGES_SEPARATOR = "#";

  /**
   * 複数セットの計上票の出力最大ページ数
   */
  private static final Integer SET_MAX_PAGE = 100;

  private static final Long PRINT_INFO_CODE = 0L;

  /**
   * 帳票マスタのDaoインタフェース.
   */
  @Autowired
  private MstReportDao mstReportDao;

  /**
   * 帳票ファイル取得のServiceインタフェース.
   */
  @Autowired
  private ReportS3Service reportS3Service;

  @Autowired
  ReportService reportService;

  @Autowired
  ReportServiceImpl reportServiceImpl;

  @Autowired
  private ReportWithAsposeApiService reportWithAsposeApiService;

  /**
   * SysDataSetから帳票出力情報を取得するServiceインタフェース.
   */
  @Autowired
  private SysDataSetService sysDataSetService;

  // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
  /**
   * 装置マスタのDaoインタフェース.
   */
  @Autowired
  private MstMachineDao mstMachineDao;
  // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end

  @Autowired
  private LogService logService;

  @Override
  public byte[] getReportExcelFileForMachineReport(Long reportCd, Map<String, Object> dataKey) {
    MstReport mstReport = mstReportDao.selectByCd(reportCd);

    // S3から帳票定義XML、帳票デザインExcelが格納されたZipファイルを取得する
    ReportZipFile reportZipFile = getReportZip(mstReport);

    // SqlCodeをもとに帳票に出力する情報を取得する
    String reportXml = getReportXml(mstReport, reportZipFile);
    List<ReportXmlParam> params = ReportUtils.getParamElements(reportXml);
    String getColWidth = "";
    String getRowHeight = "";
    if(params.size() > 0){
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
    // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
    filterReportInfobyExtractionCondition(mstReport.getExtractionCondition(), dataKey);
    // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end

    // mod #12529 機器保守カテゴリの装置情報項目が足りていない limingzhe start
    List<Long> keyfilteredList = new ArrayList<>();
    keyfilteredList = (List<Long>)dataKey.getOrDefault(ReportConstant.ReportDataKey.MACHINE_NOS, new ArrayList<>());
    // 取得キーの重複除去とソート処理
    if (keyfilteredList.size() >= 1) {
      // keyNoList の重複除去
      keyfilteredList = keyfilteredList.stream().distinct().collect(Collectors.toList());
    }

    List<ReportXmlParam> paramEnd = new ArrayList<>();
    long startTimegetReportInfoOutTmpl = System.currentTimeMillis();
    Map<Long, List<Map<String, Object>>> reportInfo = new HashMap<>();
    List<Map<String, Object>> rec = reportServiceImpl.getPrintedInfo(params, dataKey, reportInfo);
    List<ReportXmlParam> paramsOutTmpl = params.stream().filter(p -> !p.isTmplRepeat()).collect(toList());
    if(paramsOutTmpl != null && paramsOutTmpl.size() > 0) {
      reportInfo = getReportInfo(paramsOutTmpl, dataKey);
      // del #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
      //filterReportInfobyExtractionCondition(mstReport.getExtractionCondition(), reportInfo);
      // del #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end

      reportInfo.put(PRINT_INFO_CODE, rec);
      // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
      //paramsOutTmpl = reportServiceImpl.paramsReplaceSqlCode(paramsOutTmpl, reportInfo);
      paramsOutTmpl = reportServiceImpl.paramsReplaceSqlCodebyGroup(paramsOutTmpl, reportInfo);
      reportServiceImpl.filterReportInfobyParam(paramsOutTmpl, reportInfo);
      // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
      reportInfo = reportServiceImpl.getChangeList(reportInfo, paramsOutTmpl);
      reportServiceImpl.reportFilterOutUnusedData(paramsOutTmpl,reportInfo);

      // add #12513 定期点検固定帳票でグループ改頁をONにするとシステムエラー limingzhe start
      // テンプレート外 テンプレート無しの最大ページ数
      int pageOtherNum = 0; // ページあたりに表示される最大数
      for (ReportXmlParam param : paramsOutTmpl) {
        int pNumByPage = 0;
        Long sqlCode;
        if(param.getSqlCode() != null && param.getSqlCode().equals("")){
          sqlCode=Long.valueOf(0);
        }else{
          sqlCode = Long.valueOf(param.getSqlCode());
        }
        // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
        //List<Map<String, Object>> filteredList = reportServiceImpl.filterReportInfo(param, reportInfo.get(sqlCode));
        List<Map<String, Object>> tmpList = reportInfo.get(sqlCode);
        List<Map<String, Object>> filteredList = new ArrayList<>();
        try {
          if (StringUtils.isEmpty(param.getFilterType())){
            filteredList = tmpList;
          }
          else {
            filteredList = reportServiceImpl.filterReportInfo(param, reportServiceImpl.deepCopyList(tmpList));
          }
        } catch (IOException e) {
          e.printStackTrace();
        } catch (ClassNotFoundException e) {
          e.printStackTrace();
        }
        // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
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
      System.err.println("テンプレート外のページング数の計算：" + pageOtherNum);
      System.err.println("***********************************************");
      // 最大ページ数判定
      if (pageOtherNum > SET_MAX_PAGE) {
        // 指定例外のスロー、メッセージの指定を促す
        throw new NtssException("ExceedingMaxPageSetting," + pageOtherNum);
      }
      // add #12513 定期点検固定帳票でグループ改頁をONにするとシステムエラー limingzhe end
      paramEnd.addAll(paramsOutTmpl);
    }
    long endTimegetReportInfoOutTmpl = System.currentTimeMillis();
    long executionTimegetReportInfoOutTmpl = (endTimegetReportInfoOutTmpl - startTimegetReportInfoOutTmpl);
    System.err.println("getReportInfoOutTmpl: " + executionTimegetReportInfoOutTmpl + " （ms）");

    long startTimegetReportInfoInTempl = System.currentTimeMillis();
    Map<Long, List<Map<String, Object>>> reportInTmplInfo = new HashMap<>();
    List<ReportXmlParam> paramsInTmpl = params.stream().filter(p -> p.isTmplRepeat()).collect(toList());
    if(paramsInTmpl != null && paramsInTmpl.size() > 0) {
      reportInTmplInfo = getReportInfo(paramsInTmpl, dataKey);
      // del #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
      //filterReportInfobyExtractionCondition(mstReport.getExtractionCondition(), reportInTmplInfo);
      // del #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end

      // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
      //paramsInTmpl = reportServiceImpl.paramsReplaceSqlCode(paramsInTmpl, reportInTmplInfo);
      paramsInTmpl = reportServiceImpl.paramsReplaceSqlCodebyGroup(paramsInTmpl, reportInTmplInfo);
      reportServiceImpl.filterReportInfobyParam(paramsInTmpl, reportInTmplInfo);
      // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
      reportInTmplInfo = reportServiceImpl.getChangeList(reportInTmplInfo, paramsInTmpl);
      reportServiceImpl.reportFilterOutUnusedData(paramsInTmpl,reportInTmplInfo);

      // add #12513 定期点検固定帳票でグループ改頁をONにするとシステムエラー limingzhe start
      // テンプレート内の最大ページ数
      int pageOtherNum = 0; // ページあたりに表示される最大数
      for (ReportXmlParam param : paramsInTmpl) {
        int pNumByPage = 0;
        Long sqlCode;
        if(param.getSqlCode() != null && param.getSqlCode().equals("")){
          sqlCode=Long.valueOf(0);
        }else{
          sqlCode = Long.valueOf(param.getSqlCode());
        }
        // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
        //List<Map<String, Object>> filteredList = reportServiceImpl.filterReportInfo(param, reportInTmplInfo.get(sqlCode));
        List<Map<String, Object>> tmpList = reportInTmplInfo.get(sqlCode);
        List<Map<String, Object>> filteredList = new ArrayList<>();
        try {
          if (StringUtils.isEmpty(param.getFilterType())){
            filteredList = tmpList;
          }
          else {
            filteredList = reportServiceImpl.filterReportInfo(param, reportServiceImpl.deepCopyList(tmpList));
          }
        } catch (IOException e) {
          e.printStackTrace();
        } catch (ClassNotFoundException e) {
          e.printStackTrace();
        }
        // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
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
      System.err.println("テンプレート内のページング数の計算：" + pageOtherNum);
      System.err.println("***********************************************");
      // 最大ページ数判定
      if (pageOtherNum > SET_MAX_PAGE) {
        // 指定例外のスロー、メッセージの指定を促す
        throw new NtssException("ExceedingMaxPageSetting," + pageOtherNum);
      }
      // add #12513 定期点検固定帳票でグループ改頁をONにするとシステムエラー limingzhe end
      paramEnd.addAll(paramsInTmpl);
    }
    long endTimegetReportInfoInTempl = System.currentTimeMillis();
    long executionTimegetReportInfoInTempl = (endTimegetReportInfoInTempl - startTimegetReportInfoInTempl);
    System.err.println("getReportInfoInTempl: " + executionTimegetReportInfoInTempl + " （ms）");
    params = paramEnd;

    long startTimegetKeyValueInTempl = System.currentTimeMillis();
    dataKey.put("report", mstReport);
    Map<String, String> reportOutputInfo = new HashMap<>();
    reportOutputInfo = convertDataCodeToId(params, reportInfo, reportInTmplInfo, keyfilteredList, dataKey);
    // mod #12529 機器保守カテゴリの装置情報項目が足りていない limingzhe end
    reportOutputInfo = sortByKeyB(sortByKeyA(reportOutputInfo));

    // 計算項目
    Map<String, String> calcResult = new HashMap<>();
    // mod #10446 テンプレート繰返しでの計算式繰返しの制限事項対応②（「=」で始まる計算式） limingzhe start
    reportServiceImpl.formulaCalculateForParams(params, reportInfo, reportInTmplInfo, reportOutputInfo, calcResult);
    // mod #10446 テンプレート繰返しでの計算式繰返しの制限事項対応②（「=」で始まる計算式） limingzhe end
    long endTimegetKeyValueInTempl = System.currentTimeMillis();

    long executionTimegetKeyValueInTempl = (endTimegetKeyValueInTempl - startTimegetKeyValueInTempl);
    System.err.println("getKeyValue总耗时: " + executionTimegetKeyValueInTempl + " （ms）");

    long endTime = System.currentTimeMillis();
    long executionTime = (endTime - startTime);
    System.err.println("convertDataCodeToId总耗时: （秒）" + executionTime / 1000 + " milli");

    try{
      long startTimeWorkbook = System.currentTimeMillis();
      com.aspose.cells.Workbook wb = reportWithAsposeApiService.getReportExcelWorkbook(mstReport, reportZipFile, params, reportOutputInfo, calcResult, null, dataKey, getColWidth, getRowHeight);
      wb.calculateFormula(true);
      ByteArrayOutputStream o = new ByteArrayOutputStream();
      wb.save(o, SaveFormat.XLSX);
      wb.dispose();
      long endTimeWorkbook = System.currentTimeMillis();

      long executionTimeWorkbook = (endTimeWorkbook - startTimeWorkbook);
      System.err.println("getReportExcelWorkbook总耗时 total: " + executionTimeWorkbook + " （ms）");

      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setFacilityCd(mstReport.getFacilityCd());

      eventLogMessage.setLogMessage("装置帳票 getReportInfoOutTmpl: " + executionTimegetReportInfoOutTmpl + " （ms）");
      logService.log(LogLevel.INFO, eventLogMessage,LoggingConstant.FUNCTION_CODE.FUNC_REPORT_MENU, LoggingConstant.SERVICE_NAME.FNSI, null);

      eventLogMessage.setLogMessage("装置帳票 getReportInfoInTempl: " + executionTimegetReportInfoInTempl + " （ms）");
      logService.log(LogLevel.INFO, eventLogMessage,LoggingConstant.FUNCTION_CODE.FUNC_REPORT_MENU, LoggingConstant.SERVICE_NAME.FNSI, null);

      eventLogMessage.setLogMessage("装置帳票 getKeyValue总耗时: " + executionTimegetKeyValueInTempl + " （ms）");
      logService.log(LogLevel.INFO, eventLogMessage,LoggingConstant.FUNCTION_CODE.FUNC_REPORT_MENU, LoggingConstant.SERVICE_NAME.FNSI, null);

      eventLogMessage.setLogMessage("装置帳票 convertDataCodeToId总耗时: " + executionTime + " （ms）");
      logService.log(LogLevel.INFO, eventLogMessage,LoggingConstant.FUNCTION_CODE.FUNC_REPORT_MENU, LoggingConstant.SERVICE_NAME.FNSI, null);

      eventLogMessage.setLogMessage("装置帳票 getReportExcelWorkbook总耗时: " + executionTimeWorkbook + " （ms）");
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

  /**
   * 帳票定義XMLを取得します.
   *
   * @param mstReport 帳票マスタEntity
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
   * Param要素情報からsqlCodeの値を取得します.
   *
   * @param params Param要素情報
   * @return SQLCODEのリスト
   */
  private List<String> getSqlCode(List<ReportXmlParam> params){
    // sqlCodeの値を取得する
    List<String> sqlCodes = params.stream()
      .filter(p -> !StringUtils.isEmpty(p.getSqlCode()))
      .map(p -> p.getSqlCode())
      .collect(Collectors.toList())
      ;

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
   * 計算式から <code>[SqlCode.データ項目コード]</code>を取得します.
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
   * 帳票に出力する情報を取得します.
   *
   * @param params Param要素情報
   * @param dataKey データ抽出キー
   * @return 帳票出力情報
   */
  private Map<Long, List<Map<String, Object>>> getReportInfo(List<ReportXmlParam> params, Map<String, Object> dataKey) {
    // SqlCodeをもとに帳票に出力する情報を取得する
    List<String> sqlCodes = getSqlCode(params);
    // final Result
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

  private Map<String, String> sortByKeyA(Map<String, String> map) {
    Map<String, String> result = new LinkedHashMap<>(map.size());
    map.entrySet().stream()
      .sorted(Map.Entry.comparingByKey())
      .forEachOrdered(e -> result.put(e.getKey(), e.getValue()));
    return result;
  }

  private Map<String, String> sortByKeyB(Map<String, String> map) {
    Map<String, String> treeMap = new TreeMap<String, String>(new Comparator<String>() {
      @Override
      public int compare(String o1, String o2) {
        if (o1.length() > o2.length()){
          return 1;
        } else if (o1.length() < o2.length()){
          return -1;
        } else{
          return o1.compareTo(o2);
        }
      }
    });
    treeMap.putAll(map);
    return treeMap;
  }

  // mod #12529 機器保守カテゴリの装置情報項目が足りていない limingzhe start
//  private Map<String, String> convertDataCodeToId(List<ReportXmlParam> params, Map<Long, List<Map<String, Object>>> reportOutputInfo, Integer type, Integer reportType,
//                                                  Map<String, Long> patIdToCMap, Map<String, Object> dataKey, MstReport.Extraction extractionCondition) {
  private Map<String, String> convertDataCodeToId(
    List<ReportXmlParam> params,
    Map<Long, List<Map<String, Object>>> reportOutputInfo,
    Map<Long, List<Map<String, Object>>> reportInTmplInfo, List<Long> keyNoList,
    Map<String, Object> dataKey
  ) {
  // mod #12529 機器保守カテゴリの装置情報項目が足りていない limingzhe end
    Map<String, String> result = new HashMap<>();

    // sqlCode属性値でグループ化したParam要素情報を取得する
    Map<String, List<ReportXmlParam>> groupedParams = params.stream()
      // mod #12529 機器保守カテゴリの装置情報項目が足りていない limingzhe start
      //.filter(p -> !StringUtils.isEmpty(p.getId()))
      .filter(p -> !StringUtils.isEmpty(p.getId()) && !p.isTmplRepeat())
      // mod #12529 機器保守カテゴリの装置情報項目が足りていない limingzhe end
      .collect(Collectors.groupingBy(p -> p.getSqlCode()))
      ;
    List<String> sqlCodes = getSqlCode(params);
    List<Long> sqlCode1 = new ArrayList<Long>();
    for(String sql : sqlCodes){
      sqlCode1.add(Long.valueOf(sql));
    }
    Collections.sort(sqlCode1);
    LinkedHashMap<String, List<ReportXmlParam>> newGroupe = new LinkedHashMap<>();
    for(Long sql : sqlCode1){
      if (groupedParams.get(sql.toString()) != null) {
        newGroupe.put(sql.toString(),groupedParams.get(sql.toString()));
      }
    }
    // データ項目コード -> id属性値 に変換した情報を設定する
    newGroupe.entrySet().forEach(groupedParam -> {
      //各ループ開始resultで追加されたデータ数を記録する
      int resultSize=result.size();

      Long sqlCode;
      if(null != groupedParam.getKey() && groupedParam.getKey().equals("")){
        sqlCode=Long.valueOf(0);
      }else{
        sqlCode = Long.valueOf(groupedParam.getKey());
      }
      // sqlCodeをもとに出力情報を取得する
      List<Map<String, Object>> tmpList = reportOutputInfo.get(sqlCode);
      if (tmpList!=null && !tmpList.isEmpty()) {
        // mod #12529 機器保守カテゴリの装置情報項目が足りていない limingzhe start
        // パラメータ項目に対する処理を行う
        convertDataCodeToParam(
          result,
          groupedParam.getValue().stream()
            .filter(param -> StringUtils.isEmpty(param.getGroupId()) && !param.isTmplRepeat())
            .collect(toList()),
          tmpList
        );

        // グループ項目に対する処理を行う
        convertDataCodeToGroup(
          result,
          groupedParam.getValue().stream()
            .filter(param -> !StringUtils.isEmpty(param.getGroupId()) && !param.isTmplRepeat())
            .collect(toList()),
          tmpList
        );
        // mod #12529 機器保守カテゴリの装置情報項目が足りていない limingzhe end
      }
      //sqlCodeが空ではないが、データを書き込めない場合の解決 (適切な修正案が見つかった場合は、このセグメントコードを削除できます)
      //今回のサイクルでデータが何も書き込まれていない場合は、
      // ①reportOutputInfo、②dataKeyから、
      //本来書き込む可能性のあるデータを見つけて書き込むことを順番に試みます
      if(resultSize==result.size()){
        groupedParam.getValue().forEach(param->{
          List<Map<String, Object>> info = reportOutputInfo.get(Long.valueOf(param.getSqlCode()));
          info = reportServiceImpl.filterReportInfo(param, info);
          String key=param.getId();
          if(!param.getSqlCode().equals("")){
            key+="-1";
          }
          String tempValue = "";
          if(info!=null&&info.size()>0){
            //reportOutputInfoの最初のデータから優先的に検索
            tempValue = reportServiceImpl.formatValue(param,info.get(0).get(param.getDataCode()));
          }else if(dataKey.containsKey(param.getDataCode()) && (param.getSqlCode().equals("0") || param.getSqlCode().equals(""))){
            //dataKeyのデータを追加しようとします
            tempValue = reportServiceImpl.formatValue(param,dataKey.get(param.getDataCode()));
          }
          // add #12194 機器保守項目のフィルタ設定が帳票出力時に反映しない limingzhe start
          if(tempValue.length() > 0) {
          // add #12194 機器保守項目のフィルタ設定が帳票出力時に反映しない limingzhe end
            tempValue = reportServiceImpl.convertValue(param, tempValue);
            result.put(key, reportServiceImpl.addLineBreak(tempValue, param));
          // add #12194 機器保守項目のフィルタ設定が帳票出力時に反映しない limingzhe start
          }
          // add #12194 機器保守項目のフィルタ設定が帳票出力時に反映しない limingzhe end
        });
      }
    });

    // mod #12529 機器保守カテゴリの装置情報項目が足りていない limingzhe start
    // テンプレート繰り返しに対する処理を行う
    convertDataCodeToTmplForMachine(
      result,
      params.stream()
        .filter(p -> !StringUtils.isEmpty(p.getId()) && p.isTmplRepeat())
        .collect(toList()),
      reportInTmplInfo,
      keyNoList
    );
    // mod #12529 機器保守カテゴリの装置情報項目が足りていない limingzhe end
    // mod #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
//    int totalPages = 0;
//    Map<String,String> jumpMap = new HashMap<>();
//    for (String key : result.keySet()) {
//      if (key.contains("#")) {
//        if(key.contains(".")){
//          String cell = key.split("\\.")[1];
//          jumpMap.put(cell,key);
//        }
//        int resultPageCount = Integer.parseInt(key.split("#")[0]);
//        totalPages = resultPageCount > totalPages ? resultPageCount : totalPages;
//      }
//    }
//    for (ReportXmlParam reportXmlParam : params) {
//      if (ReportConstant.ReportDataKey.currentPage.equals(reportXmlParam.getDataCode())) {
//        if(jumpMap.containsKey(reportXmlParam.getId())){
//          result.remove(jumpMap.get(reportXmlParam.getId()));
//        }
//        for (int i = 1; i <= totalPages ; i++) {
//          result.put(String.format("%d%s%s-%s",i,MULTIPLE_PAGES_SEPARATOR,reportXmlParam.getId(),"1"),String.valueOf(i));
//        }
//      } else if (ReportConstant.ReportDataKey.totalPages.equals(reportXmlParam.getDataCode())) {
//        if(jumpMap.containsKey(reportXmlParam.getId())){
//          result.remove(jumpMap.get(reportXmlParam.getId()));
//        }
//        for (int i = 1; i <= totalPages ; i++) {
//          result.put(String.format("%d%s%s-%s",i,MULTIPLE_PAGES_SEPARATOR,reportXmlParam.getId(),"1"),String.valueOf(totalPages));
//        }
//      }
//    }
    ReportCommonUtil.pageAndPageCount(result, params, dataKey);
    // mod #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
    return result;
  }

  // add #12529 機器保守カテゴリの装置情報項目が足りていない limingzhe start
  // グループ繰り返し & パラメータ繰り返し
  // テンプレート内
  private void convertDataCodeToTmplForMachine(Map<String, String> result, List<ReportXmlParam> params, Map<Long, List<Map<String, Object>>> reportInTmplInfo, List<Long> keyNoList){
    Map<String, List<ReportXmlParam>> groupedParamsInTmpl = params.stream()
      .filter(p -> !StringUtils.isEmpty(p.getId()) && p.isTmplRepeat())
      .collect(Collectors.groupingBy(p -> p.getSqlCode()))
      ;

    // 帳票の設定抽出条件
    String tmplKeySet = "machine_no";

    ReportXmlTmplRepeat tmplRepeatSet = null;
    if(groupedParamsInTmpl != null && groupedParamsInTmpl.size() > 0) {
      tmplRepeatSet = groupedParamsInTmpl.values().stream().findFirst().get().get(0).getReportXmlTmplRepeat();
    }
    boolean tmplEndFlag = false;
    boolean bHaveGroupIsNewPage = false;
    // mod #12497 テンプレート繰返しがグループ改頁設定の影響を受けるのは不適切 高 start
//    List<ReportXmlParam> paramsGroupIsNewPageInTmpl = params.stream()
//      .filter(p -> !StringUtils.isEmpty(p.getGroupId()) && p.isTmplRepeat() && p.getReportXmlGroup().getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_YES)
//      .collect(toList());
    List<ReportXmlParam> paramsGroupIsNewPageInTmpl = params.stream()
      .filter(p -> !StringUtils.isEmpty(p.getGroupId()) && p.isTmplRepeat() && p.getReportXmlGroup() != null)
      .collect(toList());
    // mod #12497 テンプレート繰返しがグループ改頁設定の影響を受けるのは不適切 高 end
    if(paramsGroupIsNewPageInTmpl != null && paramsGroupIsNewPageInTmpl.size() > 0) bHaveGroupIsNewPage = true;

    int pageStart = 0;
    int tmplLoopStart = 0;
    for (Long keyNo : keyNoList) {
      int tmplMaxCount = 1;
      for(int tmplIndex = 0; tmplIndex < tmplMaxCount; tmplIndex++){
        int tmplLoopMax = 0;
        Integer startPagebyKeyNo = 0;
        Integer startTmplbyKeyNo = 0;
        Map<String, String> resultTmpl = new HashMap<>();
        // データ項目コード -> id属性値 に変換した情報を設定する
        for(String cel : groupedParamsInTmpl.keySet()) {
          Long sqlCode;
          if(null != cel && cel.equals("")){
            sqlCode=Long.valueOf(0);
          }else{
            sqlCode = Long.valueOf(cel);
          }
          // sqlCodeをもとに出力情報を取得する
          List<Map<String, Object>> tmpList = reportInTmplInfo.get(sqlCode);

          // キーの値に一致するデータを応答データに格納
          if (tmpList!=null && !tmpList.isEmpty()) {
            String keyNamebyNo = tmplKeySet;
            Long keyNobyNo = keyNo;

            List<Map<String, Object>> filteredListTemp = new ArrayList<>();
            for (Map<String, Object> sqlData : tmpList) {

              if (sqlData.get(keyNamebyNo) != null && !StringUtils.isEmpty(sqlData.get(keyNamebyNo).toString())) {
                Long dataKeyNo = Long.valueOf(sqlData.get(keyNamebyNo).toString());
                if (keyNobyNo.equals(dataKeyNo)) {
                  filteredListTemp.add(sqlData);
                }
              }
            }
            tmpList = filteredListTemp;
          }

          if (tmpList!=null && !tmpList.isEmpty()) {
            for (ReportXmlParam param : groupedParamsInTmpl.get(cel)) {
              if (!(!StringUtils.isEmpty(param.getGroupId()) && param.isTmplRepeat())) {
                continue;
              }
              // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
              //List<Map<String, Object>> filteredList = reportServiceImpl.filterReportInfo(param, tmpList);
              List<Map<String, Object>> filteredList = new ArrayList<>();
              try {
                // add #12513 定期点検固定帳票でグループ改頁をONにするとシステムエラー limingzhe start
                if (StringUtils.isEmpty(param.getFilterType())){
                  filteredList = tmpList;
                }
                else {
                // add #12513 定期点検固定帳票でグループ改頁をONにするとシステムエラー limingzhe end
                  filteredList = reportServiceImpl.filterReportInfo(param, reportServiceImpl.deepCopyList(tmpList));
                // add #12513 定期点検固定帳票でグループ改頁をONにするとシステムエラー limingzhe start
                }
                // add #12513 定期点検固定帳票でグループ改頁をONにするとシステムエラー limingzhe end
              } catch (IOException e) {
                e.printStackTrace();
              } catch (ClassNotFoundException e) {
                e.printStackTrace();
              }
              // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
              if (filteredList.isEmpty()) continue;
              ReportXmlGroup group = param.getReportXmlGroup();
              ReportXmlTmplRepeat tmplRepeat = param.getReportXmlTmplRepeat();
              Integer repeatMax = (group != null && group.getRepeatMax() != null) ? group.getRepeatMax() : 1;
              Integer tmplRepeatMax = (group != null && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_YES) ? tmplRepeat.getRepeatMax() : 1;
              Integer repeatOfPage;
              int tmplLoop = 1;
              if (group != null && group.getRepeatMax() > 1) {
                repeatOfPage = (filteredList.size() > repeatMax * tmplRepeatMax) ? repeatMax * tmplRepeatMax : filteredList.size();
                tmplLoop = filteredList.size() / group.getRepeatMax() + ((filteredList.size() % group.getRepeatMax() > 0) ? 1 : 0);
              }else{
                repeatOfPage = filteredList.size() > tmplRepeatMax ? tmplRepeatMax : filteredList.size();
                tmplLoop = filteredList.size();
              }
              if((group != null && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_NO)) {
                if(filteredList.size() > 0) tmplLoop = 1;
              }
              else {
                if(tmplRepeat.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_NO){
                  // mod #12497 テンプレート繰返しがグループ改頁設定の影響を受けるのは不適切 高 start
//                  if(filteredList.size() > 0) tmplLoop = (filteredList.size() > tmplRepeat.getRepeatMax()) ? tmplRepeat.getRepeatMax() : filteredList.size();
                  if(filteredList.size() > 0) tmplLoop = (filteredList.size() > group.getRepeatMax()) ? filteredList.size()%group.getRepeatMax()== 0 ?
                    filteredList.size()/group.getRepeatMax() : filteredList.size()/group.getRepeatMax() +1 : 1 ;
                  // mod #12497 テンプレート繰返しがグループ改頁設定の影響を受けるのは不適切 高 end
                  if(tmplLoop > tmplRepeat.getRepeatMax() - tmplLoopStart) tmplLoop = tmplRepeat.getRepeatMax();
                }
              }
              if(tmplLoop > tmplLoopMax) tmplLoopMax = tmplLoop;

              int limitCount = repeatOfPage;
              int pageTmplMax = (tmplRepeat.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_NO || (group != null && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_NO)) ? 0 : filteredList.size() / repeatOfPage;
              for (Integer pageCount = 0; pageCount <= pageTmplMax; pageCount++) {
                int skipCount = pageCount * limitCount;
                List<Map<String, Object>> outputInfos = filteredList.stream().skip(skipCount).limit(limitCount).collect(toList());
                int count = 1;
                pageStart = tmplLoopStart / tmplRepeat.getRepeatMax();
                int tmplLoopCount = 1 + tmplLoopStart % tmplRepeat.getRepeatMax();
                for (Integer i = 0; i < outputInfos.size(); i++) {
                  String pageStr = String.format("%d%s", pageStart + pageCount + 1, MULTIPLE_PAGES_SEPARATOR);
                  String keyTmpl = String.format("%s-%d", tmplRepeat.getId(), tmplLoopCount);
                  String keyParam = String.format("%s-%s", param.getId(), count++);
                  String key = String.format("%s%s.%s",pageStr, keyTmpl, keyParam);

                  String value = reportServiceImpl.formatValue(param, outputInfos.get(i).get(param.getDataCode()));
                  // add #12538 日常点検／定期点検のデータ項目補完 limingzhe start
                  if(param.getDataCode().equals("layout_group_ans") && value.length() >= 1){
                    String convValue = reportServiceImpl.convertValue(param, value.substring(0,1));
                    value = convValue.concat(value.substring(1));
                  }
                  else {
                  // add #12538 日常点検／定期点検のデータ項目補完 limingzhe end
                    value = reportServiceImpl.convertValue(param, value);
                  // add #12538 日常点検／定期点検のデータ項目補完 limingzhe start
                  }
                  // add #12538 日常点検／定期点検のデータ項目補完 limingzhe end
                  if (value != null && !"null".equals(value)) {
                    resultTmpl.put(key, reportServiceImpl.addLineBreak(value, param));
                  } else {
                    resultTmpl.put(key, "");
                  }
                  if(startPagebyKeyNo == 0) startPagebyKeyNo = pageStart + pageCount + 1;
                  if(startTmplbyKeyNo == 0) startTmplbyKeyNo = tmplLoopCount;
                  if(group != null && count > group.getRepeatMax()){
                    count = 1;
                    tmplLoopCount++;
                    if(tmplRepeat.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_NO){
                      // mod #12497 テンプレート繰返しがグループ改頁設定の影響を受けるのは不適切 高 start
//                      if(tmplLoopCount > tmplLoopMax) break;
                      if(tmplLoopCount > tmplRepeat.getRepeatMax()) break;
                      // mod #12497 テンプレート繰返しがグループ改頁設定の影響を受けるのは不適切 高 end
                    }
                    if(tmplLoopCount > tmplRepeat.getRepeatMax()) {
                      if(tmplLoopStart % tmplRepeat.getRepeatMax() > 0) pageStart += 1;
                      tmplLoopCount = 1;
                    }
                  }
                }
              }
            }

            // sqlCodeをもとに出力情報を取得する
            List<Map<String, Object>> oldTmpList = new ArrayList<>();
            oldTmpList.addAll(tmpList);

            // テンプレート繰り返しに対する処理を行う
            for (ReportXmlParam param : groupedParamsInTmpl.get(cel)) {
              if (!(StringUtils.isEmpty(param.getGroupId()) && param.isTmplRepeat())) {
                continue;
              }
              ReportXmlTmplRepeat tmplRepeat = param.getReportXmlTmplRepeat();
              int pageMax = tmpList.size();
              if ((tmplRepeat.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_NO || !"1".equals(param.getIsNewPage())) && tmpList.size() > 0)
                pageMax = 1;
              int tmplLoop = 1;
              if(tmplLoop > tmplLoopMax) tmplLoopMax = tmplLoop;
              pageStart = tmplLoopStart / tmplRepeat.getRepeatMax();
              int count = 1 + tmplLoopStart % tmplRepeat.getRepeatMax();
              for (int i = 0; i < pageMax; i++) {
                Map<String, Object> tmpMap = tmpList.get(i);
                // 出力する内容を取得する
                String value = reportServiceImpl.formatValue(param, tmpMap.get(param.getDataCode()));
                value = reportServiceImpl.convertValue(param, value);

                String pageStr = String.format("%d%s", pageStart + i + 1, MULTIPLE_PAGES_SEPARATOR);
                String keyTmpl = String.format("%s-%d", tmplRepeat.getId(), count);
                String key = String.format("%s%s.%s", pageStr, keyTmpl, param.getId());

                if (value != null && !"null".equals(value)) {
                  resultTmpl.put(key, reportServiceImpl.addLineBreak(value, param));
                } else {
                  resultTmpl.put(key, "");
                }
                if(startPagebyKeyNo == 0) startPagebyKeyNo = pageStart + i + 1;
                if(startTmplbyKeyNo == 0) startTmplbyKeyNo = count;
              }
            }
          }
        }
        if(resultTmpl.size() > 0)
          tmplLoopStart += tmplLoopMax;

        Integer endPagebyKeyNo = reportServiceImpl.getTmplPageCount(resultTmpl);
        Integer endTmplbyKeyNo = reportServiceImpl.getTmplCount(resultTmpl, endPagebyKeyNo);
        result.putAll(resultTmpl);
        if(startPagebyKeyNo != 0){
          if((startPagebyKeyNo != endPagebyKeyNo) || (startTmplbyKeyNo != endTmplbyKeyNo)) {
            List<ReportXmlParam> paramsInTmpl = params.stream()
              .filter(p -> !StringUtils.isEmpty(p.getId()) && p.isTmplRepeat())
              .collect(Collectors.toList())
              ;
            for (ReportXmlParam param : paramsInTmpl){
              ReportXmlTmplRepeat tmplRepeat = param.getReportXmlTmplRepeat();
              if(tmplRepeat.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_YES){
                ReportXmlGroup group = param.getReportXmlGroup();
                if ((group != null && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_NO) || (StringUtils.isEmpty(param.getGroupId()) && !"1".equals(param.getIsNewPage()))) {
                  List<String> repeatKey = resultTmpl.keySet().stream()
                    .filter(r -> r.indexOf(MULTIPLE_PAGES_SEPARATOR) >= 0 && r.indexOf(".") >= 0 && r.substring(r.indexOf("-")+1).indexOf(param.getId()) >= 0)
                    .collect(toList());
                  for(Integer i = (startTmplbyKeyNo < tmplRepeat.getRepeatMax() ? startPagebyKeyNo - 1 : startPagebyKeyNo); i < endPagebyKeyNo; i++){
                    for(Integer j = 0; j < tmplRepeat.getRepeatMax(); j++) {
                      if(i + 1 == startPagebyKeyNo && j + 1 <= startTmplbyKeyNo) continue;
                      if(i + 1 == endPagebyKeyNo && j + 1 > endTmplbyKeyNo) continue;
                      for (String key : repeatKey) {
                        String pageStr = String.format("%d%s", i + 1, MULTIPLE_PAGES_SEPARATOR);
                        String keyTmpl = String.format("%s-%d", tmplRepeat.getId(), j + 1);
                        String keyNew = String.format("%s%s.%s",pageStr, keyTmpl, key.substring(key.indexOf(".") + 1));
                        result.put(keyNew, resultTmpl.get(key));
                      }
                    }
                  }
                }
              }
            }
          }
        }
        startPagebyKeyNo = 0;
        startTmplbyKeyNo = 0;

        if(bHaveGroupIsNewPage){
          if(!StringUtils.isEmpty(tmplRepeatSet) && tmplRepeatSet.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_NO) {
            if(tmplLoopStart >= tmplRepeatSet.getRepeatMax()) {
              tmplEndFlag = true;
              break;
            }
          }
        }
        else {
          if(tmplLoopStart >= 1) {
            tmplEndFlag = true;
            break;
          }
        }
      }
      if(tmplEndFlag) break;
    }
  }

  // グループ繰り返し
  // テンプレート外 テンプレート無し
  private void convertDataCodeToGroup(Map<String, String> result, List<ReportXmlParam> params, List<Map<String, Object>> tmpList) {
    params.stream()
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

          int skipCount = pageCount * limitCount;

          // id属性値をkey、出力値をvalue に設定する（複数項目の場合、id属性値に連番を付加する）
          List<Map<String, Object>> outputInfos = filteredList.stream().skip(skipCount).limit(limitCount).collect(toList());
          int n=0;
          for (Integer i = 0; i < outputInfos.size(); i++) {
            if (n >= repeatMax) {
              // 帳票定義XMLで指定されている繰り返し回数を超えた場合、残りのデータは出力しない
              break;
            }

            String pageStr = "";
            if (group != null && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_YES) {
              pageStr = String.format("%d%s", pageCount + 1, MULTIPLE_PAGES_SEPARATOR);
            }
            String key = String.format("%s%s-%d", pageStr, param.getId(), n + 1);
            String value = reportServiceImpl.formatValue(param, outputInfos.get(i).get(param.getDataCode()));
            // add #12538 日常点検／定期点検のデータ項目補完 limingzhe start
            if(param.getDataCode().equals("layout_group_ans") && value.length() >= 1){
              String convValue = reportServiceImpl.convertValue(param, value.substring(0,1));
              value = convValue.concat(value.substring(1));
            }
            else {
              // add #12538 日常点検／定期点検のデータ項目補完 limingzhe end
              value = reportServiceImpl.convertValue(param, value);
              // add #12538 日常点検／定期点検のデータ項目補完 limingzhe start
            }
            // add #12538 日常点検／定期点検のデータ項目補完 limingzhe end
            if (value != null && !"null".equals(value)) {
              if(!result.containsKey(key)){
                result.put(key, reportServiceImpl.addLineBreak(value, param));
              }
            } else {
              if(!result.containsKey(key)){
                result.put(key, "");
              }
            }
            n = n + 1;
          }
        }
      });
  }

  // パラメータ繰り返し
  // テンプレート外 テンプレート無し
  private void convertDataCodeToParam(Map<String, String> result, List<ReportXmlParam> params, List<Map<String, Object>> tmpList) {
    List<ReportXmlParam> list = params.stream()
      .filter(param -> "1".equals(param.getIsNewPage()))
      .collect(toList());

    if (tmpList.size() > 1 && list!= null && list.size() > 0) {
      params.stream()
        .forEach(param -> {
          for (int i = 0; i < tmpList.size(); i++) {
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
      params.stream()
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
  }
  // add #12529 機器保守カテゴリの装置情報項目が足りていない limingzhe end

  // add #12194 機器保守項目のフィルタ設定が帳票出力時に反映しない limingzhe start
  // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
//  private void filterReportInfobyExtractionCondition(MstReport.Extraction extractionCondition, Map<Long, List<Map<String, Object>>> reportInfo){
//    if(extractionCondition == null) return;
//    String mainteUseCd = extractionCondition.getUseCD();
//    String mainteRecordCd = extractionCondition.getRecordCD();
//    String mainteLayoutCd = extractionCondition.getLayoutCD();
//    if(mainteUseCd.length() == 0) return;
//    if(mainteUseCd.equals("1")) {
//      if(mainteLayoutCd.length() == 0) return;
//    }
//    else if(mainteUseCd.equals("2")){
//      if(mainteLayoutCd.length() == 0 || mainteRecordCd.length() == 0) return;
//    }
//    else {
//      return;
//    }
//    String layoutkey = "mainte_layout_cd";
//    String Recordkey = "tabindex";
//    for(Long sqlCode : reportInfo.keySet()) {
//      if(reportInfo.get(sqlCode) == null || reportInfo.get(sqlCode).size() == 0) continue;
//      List<Map<String, Object>> filteredList = reportInfo.get(sqlCode);
//      if(!filteredList.get(0).containsKey(layoutkey)) continue;
//
//      List<Map<String, Object>> layoutfilteredList = new ArrayList<>();
//      for (Integer i = 0; i < filteredList.size(); i++) {
//        if(filteredList.get(i).get(layoutkey) != null){
//          if(!String.valueOf(filteredList.get(i).get(layoutkey)).equals(mainteLayoutCd)) {
//            continue;
//          }
//        }
//        if(mainteUseCd.equals("2")){
//          if(filteredList.get(i).get(Recordkey) != null){
//            if(!String.valueOf(filteredList.get(i).get(Recordkey)).equals(mainteRecordCd)) {
//              continue;
//            }
//          }
//        }
//        layoutfilteredList.add(filteredList.get(i));
//      }
//      reportInfo.put(sqlCode, layoutfilteredList);
//    }
//  }

  private void filterReportInfobyExtractionCondition(MstReport.Extraction extractionCondition, Map<String, Object> dataKey){
    if(extractionCondition == null) return;
    String mainteUseCd = extractionCondition.getUseCD();
    String machineTypeCd = extractionCondition.getMachineTypeCD();
    if(mainteUseCd.length() == 0) return;
    if(machineTypeCd.length() == 0 || machineTypeCd.equals("0")) return;

    List<Long> keyfilteredList = (List<Long>)dataKey.getOrDefault(ReportConstant.ReportDataKey.MACHINE_NOS, new ArrayList<>());

    List<Long> mstMachineList = mstMachineDao.selectByMachineTypeCd(
      dataKey.get(ReportConstant.ReportDataKey.FACILITY_CD).toString(),
      machineTypeCd
    );

    List<Long> machineNos = mstMachineList.stream().filter(e -> keyfilteredList.contains(e)).collect(toList());
    dataKey.put(ReportConstant.ReportDataKey.MACHINE_NOS, machineNos);
  }
  // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
  // add #12194 機器保守項目のフィルタ設定が帳票出力時に反映しない limingzhe end
}
// add #11117 日常点検記録簿が1ページ1装置で出力される limingzhe end
