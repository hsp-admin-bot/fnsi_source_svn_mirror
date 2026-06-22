package jp.co.nikkiso.ntss.api.service.report;

import com.aspose.cells.SaveFormat;
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
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstReportDao;
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
import java.util.ArrayList;
import java.util.Arrays;
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

/**
 * 帳票の配布リスト出力Service実装クラス.
 */
@Service
@Slf4j
public class ReportForDistributionListServiceImpl implements ReportForDistributionListService {

  /**
   * 帳票出力情報のKey項目に使用する複数ページ区切り文字列.
   */
  private static final String MULTIPLE_PAGES_SEPARATOR = "#";

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
  ReportServiceImpl reportServiceImpl;

  /**
   * SysDataSetから帳票出力情報を取得するServiceインタフェース.
   */
  @Autowired
  private SysDataSetService sysDataSetService;

  @Autowired
  private LogService logService;

  @Autowired
  private ReportWithAsposeApiService reportWithAsposeApiService;

  /**
   * {@inheritDoc}
   */
  @Override
  public byte[] getReportExcelFileForDistributionListBed(Long reportCd, Map<String, Object> dataKey) {
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

    // データキーを取得する.
    complementDataKey(dataKey);
    // 帳票に出力する情報を取得します.
    Map<Long, List<Map<String, Object>>> reportInfo = new HashMap<>();
    // カテゴリ「印刷情報」出力する情報を取得します.
    List<Map<String, Object>> rec = reportServiceImpl.getPrintedInfo(params, dataKey, reportInfo);
    //
    Map<String, List<ReportXmlParam>> paramsGroup = getParamsGroup(params);
    selectReportInfo(paramsGroup, dataKey, reportInfo);
    reportInfo.put(PRINT_INFO_CODE, rec);
    // 帳票内に同項目が複数あると設定値 区分
    params = reportServiceImpl.paramsReplaceTmpValue(params, reportInfo);
    // 表示文字列長の設定 -> フィールド改行
    reportInfo = reportServiceImpl.getChangeList(reportInfo, params);

    boolean fileFlag = false;
    List<Long> ordNos = (List<Long>) dataKey.get("ordNos");
    for (Long key : reportInfo.keySet()) {
      if (reportInfo.get(key) != null && reportInfo.get(key).size() != 0) {
        fileFlag = false;
        break;
      }else if(ordNos == null){
        fileFlag = false;
        break;
      }else {
        fileFlag = true;
      }
    }
    if (fileFlag) {
      byte[] file = null;
      return file;
    }

    // sql実行結果(reportInfo) のデータを Excelに割り当てられるデータリスト(セル：データのリスト)に変換して、reportOutputInfo に格納
    Map<String, String> reportOutputInfo = new HashMap<>();
    dataKey.put("report", mstReport);
    reportOutputInfo = convertDataCodeToId(params, reportInfo, mstReport.getReportClass(), mstReport.getReportType(), dataKey);
    // セル順にソート ( ページなし、1ページ目、2ページ目のようにソートされます )
    reportOutputInfo = sortByKeyB(sortByKeyA(reportOutputInfo));

    // 計算項目
    Map<String, String> calcResult = new HashMap<>();
    reportServiceImpl.formulaCalculateForParams(params, reportInfo, reportInfo, reportOutputInfo, calcResult);

    try{
      com.aspose.cells.Workbook wb = reportWithAsposeApiService.getReportExcelWorkbook(mstReport, reportZipFile, params, reportOutputInfo, calcResult, null, dataKey, getColWidth, getRowHeight);
      wb.calculateFormula(true);
      // 一時ファイルに出力
      ByteArrayOutputStream o = new ByteArrayOutputStream();
      wb.save(o, SaveFormat.XLSX);

      wb.dispose();
      return o.toByteArray();
    } catch (Exception e) {
      // エラーメッセージ
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("帳票Excelファイルの出力に失敗しました。：" + NtssUtils.ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      throw new NtssException("帳票Excelファイルの出力に失敗しました。");
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public byte[] getReportExcelFileForDistributionListGoods(Long reportCd, Map<String, Object> dataKey) {
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

    // データキーを取得する.
    complementDataKey(dataKey);
    // 帳票に出力する情報を取得します.
    Map<Long, List<Map<String, Object>>> reportInfo = new HashMap<>();
    // カテゴリ「印刷情報」出力する情報を取得します.
    List<Map<String, Object>> rec = reportServiceImpl.getPrintedInfo(params, dataKey, reportInfo);
    Map<String, List<ReportXmlParam>> paramsGroup = getParamsGroup(params);
    selectReportInfo(paramsGroup, dataKey, reportInfo);
    reportInfo.put(PRINT_INFO_CODE, rec);
    // 帳票内に同項目が複数あると設定値 区分
    params = reportServiceImpl.paramsReplaceTmpValue(params, reportInfo);
    // 表示文字列長の設定 -> フィールド改行
    reportInfo = reportServiceImpl.getChangeList(reportInfo, params);

    // sql実行結果(reportInfo) のデータを Excelに割り当てられるデータリスト(セル：データのリスト)に変換して、reportOutputInfo に格納
    Map<String, String> reportOutputInfo = new HashMap<>();
    dataKey.put("report", mstReport);
    reportOutputInfo = convertDataCodeToId(params, reportInfo, mstReport.getReportClass(), mstReport.getReportType(), dataKey);
    // セル順にソート ( ページなし、1ページ目、2ページ目のようにソートされます )
    reportOutputInfo = sortByKeyB(sortByKeyA(reportOutputInfo));

    // 計算項目
    Map<String, String> calcResult = new HashMap<>();
    reportServiceImpl.formulaCalculateForParams(params, reportInfo, reportInfo, reportOutputInfo, calcResult);

    try{
      com.aspose.cells.Workbook wb = reportWithAsposeApiService.getReportExcelWorkbook(mstReport, reportZipFile, params, reportOutputInfo, calcResult, null, dataKey, getColWidth, getRowHeight);
      wb.calculateFormula(true);
      // 一時ファイルに出力
      ByteArrayOutputStream o = new ByteArrayOutputStream();
      wb.save(o, SaveFormat.XLSX);

      wb.dispose();
      return o.toByteArray();
    } catch (Exception e) {
      // エラーメッセージ
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("帳票Excelファイルの出力に失敗しました。：" + NtssUtils.ExcetionStackTraceToString(e));
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

  private void complementDataKey(Map<String, Object> dataKey) {
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

    if (!dataKey.containsKey("prescriptionClassList")){
      dataKey.put("prescriptionClassList", new ArrayList<String>(Arrays.asList("1", "2")));
    }

    if (!dataKey.containsKey("regOrderClassList")){
      dataKey.put("regOrderClassList", new ArrayList<String>(Arrays.asList("1", "2", "0")));
    }

    if(dataKey.containsKey("reportClass") && Integer.parseInt(String.valueOf(dataKey.get("reportClass"))) == ReportConstant.ReportClass.DISTRIBUTION_LIST_GOODS_REPORT){
      String sortState = "";
      StringBuilder sb = new StringBuilder();
      sb.append(" ORDER BY\n" +
        "\t\t\tdisp_order");
      if (dataKey.get(ReportConstant.ReportDataKey.SORT_CONDITIONS) != null) {
        List<Map<String, String>> sortCondition = (List<Map<String, String>>)dataKey.get(ReportConstant.ReportDataKey.SORT_CONDITIONS);
        List tmpSortKey = new ArrayList();
        List tmpSortKeyAndtmpSortDirection = new ArrayList();
        List tmpSortDirection = new ArrayList();
        DistributionListGoodsReportCompareCan (tmpSortKey,tmpSortDirection,tmpSortKeyAndtmpSortDirection, sortCondition);
        for (int index = 0;index < tmpSortKey.size();index++) {
          if (tmpSortKey.get(index).equals("data_type_order")) {
            sortState = tmpSortDirection.get(index).toString();
            tmpSortKey.remove(index);
            tmpSortDirection.remove(index);
            tmpSortKeyAndtmpSortDirection.remove(index);
          }
        }
        for (int index = 0;index < tmpSortKeyAndtmpSortDirection.size();index++) {
          sb.append(tmpSortKeyAndtmpSortDirection.get(index));
        }
      }
      dataKey.put("orderBy",sb.toString());

      Map<String, Integer> sortMap = reportServiceImpl.getFacilitySettingInfoBySettingNoAndCd(
        dataKey.get("facilityCd").toString(),
        CoreConstant.FacilitySettingNo.DATA_KIND_SORT_SETTING,
        sortState
      );
      dataKey.put("equsort", sortMap.get("equsort"));
      dataKey.put("medsort", sortMap.get("medsort"));
    }
  }

  /**
   * order byソートパッケージです
   *
   */
  private void DistributionListGoodsReportCompareCan (List tmpSortKey,List tmpSortDirection,List tmpSortKeyAndtmpSortDirection, List<Map<String, String>> sortConditions) {
    for (int index = 0; index < sortConditions.size(); index++) {
      Map<String, String> item = sortConditions.get(sortConditions.size() - (index+1));
      if (item.keySet().contains(CoreConstant.ReportMenu.EQUIPMENT_MEDICINE_NAME)) {
        // 名称
        tmpSortKey.add(index,"name");
        tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.EQUIPMENT_MEDICINE_NAME));
        tmpSortKeyAndtmpSortDirection.add(index,"\n,res.name " + item.get(CoreConstant.ReportMenu.EQUIPMENT_MEDICINE_NAME) + " NULLS LAST");
      }
      else if (item.keySet().contains(CoreConstant.ReportMenu.MEDICINE_EQUIPMENT_CODE)) {
        // データ種別順
        tmpSortKey.add(index,"data_type_order");
        tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.MEDICINE_EQUIPMENT_CODE));
        tmpSortKeyAndtmpSortDirection.add(index,"\n,res.data_type_order " + item.get(CoreConstant.ReportMenu.MEDICINE_EQUIPMENT_CODE) + " NULLS LAST");
      }
      else if (item.keySet().contains(CoreConstant.ReportMenu.EQUIPMENT_MEDICINE_CLASS)) {
        // 分類名称順
        tmpSortKey.add(index, "kind_order");
        tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.MEDICINE_EQUIPMENT_CLASS));
        if (sortConditions.size() - (index+1) == 0) {
          tmpSortKeyAndtmpSortDirection.add(index,"\n,kind_order " + item.get(CoreConstant.ReportMenu.MEDICINE_EQUIPMENT_CLASS) + " NULLS LAST"
            // mod #11623 ord_material_saveに薬剤や医材の登録順情報がない sunsy start
//            +"\n,res.dia_order " + item.get(CoreConstant.ReportMenu.MEDICINE_EQUIPMENT_CLASS) + " NULLS LAST"
            +"\n,res.dia_order " + "ASC" + " NULLS LAST"
            // mod #11623 ord_material_saveに薬剤や医材の登録順情報がない sunsy end
            +"\n,res.medic_order " + item.get(CoreConstant.ReportMenu.MEDICINE_EQUIPMENT_CLASS) + " NULLS LAST"
            +"\n,res.equic_order " + item.get(CoreConstant.ReportMenu.MEDICINE_EQUIPMENT_CLASS) + " NULLS LAST"
            +"\n,res.medi_mix_order " + item.get(CoreConstant.ReportMenu.MEDICINE_EQUIPMENT_CLASS) + " NULLS LAST");
        }
        else {
          tmpSortKeyAndtmpSortDirection.add(index,"\n,kind_order " + item.get(CoreConstant.ReportMenu.MEDICINE_EQUIPMENT_CLASS) + " NULLS LAST"
            +"\n,res.medic_order " + item.get(CoreConstant.ReportMenu.MEDICINE_EQUIPMENT_CLASS) + " NULLS LAST"
            +"\n,res.equic_order " + item.get(CoreConstant.ReportMenu.MEDICINE_EQUIPMENT_CLASS) + " NULLS LAST"
            +"\n,res.medi_mix_order " + item.get(CoreConstant.ReportMenu.MEDICINE_EQUIPMENT_CLASS) + " NULLS LAST");
        }
      }
      else if (item.keySet().contains(CoreConstant.ReportMenu.MEDICINE_EQUIPMENT_DATA_GROUP)) {
        // 治療条件順
        tmpSortKey.add(index,"class_data_order");
        tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.MEDICINE_EQUIPMENT_DATA_GROUP));
        tmpSortKeyAndtmpSortDirection.add(index,"\n,class_data_order " + item.get(CoreConstant.ReportMenu.MEDICINE_EQUIPMENT_DATA_GROUP) + " NULLS LAST");
      }
    }
  }

  private Map<String, List<ReportXmlParam>> getParamsGroup(List<ReportXmlParam> params){
    List<String> sqlCodes = getSqlCode(params);
    Map<String, List<String>> sqlCodesGroup = new HashMap<>();
    sqlCodesGroup.put("multiple", new ArrayList<String>());
    sqlCodesGroup.put("patId", new ArrayList<String>());
    sqlCodesGroup.put("ordNo", new ArrayList<String>());
    sqlCodesGroup.put("Other", new ArrayList<String>());
    for(String sqlCode: sqlCodes){
      if(sysDataSetService.distinParaOnlybyParam(Long.parseLong(sqlCode), "patIds"))
        sqlCodesGroup.get("multiple").add(sqlCode);
      else if(sysDataSetService.distinParaOnlybyParam(Long.parseLong(sqlCode), "ordNos"))
        sqlCodesGroup.get("multiple").add(sqlCode);
      else if(sysDataSetService.distinParaOnlybyParam(Long.parseLong(sqlCode), "ordNo"))
        sqlCodesGroup.get("ordNo").add(sqlCode);
      else if(sysDataSetService.distinParaOnlybyPatId(Long.parseLong(sqlCode)))
        sqlCodesGroup.get("patId").add(sqlCode);
      else
        sqlCodesGroup.get("Other").add(sqlCode);
    }
    Map<String, List<ReportXmlParam>> paramsGroup = new HashMap<>();
    paramsGroup.put("multiple", new ArrayList<ReportXmlParam>());
    paramsGroup.put("patId", new ArrayList<ReportXmlParam>());
    paramsGroup.put("ordNo", new ArrayList<ReportXmlParam>());
    for (ReportXmlParam reParam: params){
      if(sqlCodesGroup.get("patId").contains(reParam.getSqlCode())) {
        paramsGroup.get("patId").add(reParam);
      }
      else if(sqlCodesGroup.get("ordNo").contains(reParam.getSqlCode())) {
        paramsGroup.get("ordNo").add(reParam);
      }
      else
        paramsGroup.get("multiple").add(reParam);
    }
    return paramsGroup;
  }

  private void selectReportInfo(
    Map<String, List<ReportXmlParam>> paramsGroup,
    Map<String, Object> dataKey,
    Map<Long, List<Map<String, Object>>> reportInfo
  ){
    if(paramsGroup.get("multiple").size()>0){
      Map<Long, List<Map<String, Object>>> reportInfoIndex = getReportInfo(paramsGroup.get("multiple"), dataKey);
      reportInfo.putAll(reportInfoIndex);
    }
    if(paramsGroup.get("patId").size()>0) {
      List<Long> patIds = (List<Long>)dataKey.getOrDefault(ReportConstant.ReportDataKey.PAT_IDS, new ArrayList<>());
      for (int i = 0; i < patIds.size(); i++) {
        dataKey.put("patId", patIds.get(i));
        Map<Long, List<Map<String, Object>>> reportInfoIndex = getReportInfo(paramsGroup.get("patId"), dataKey);
        for (Long key : reportInfoIndex.keySet()) {
          if (reportInfo.containsKey(key)) {
            reportInfo.get(key).addAll(reportInfoIndex.get(key));
          } else {
            reportInfo.put(key, reportInfoIndex.get(key));
          }
        }
      }
    }
    if(paramsGroup.get("ordNo").size()>0) {
      List<Long> ordNos = (List<Long>)dataKey.getOrDefault(ReportConstant.ReportDataKey.ORD_NOS, new ArrayList<>());
      for (int i = 0; i < ordNos.size(); i++) {
        dataKey.put("ordNo", ordNos.get(i));
        Map<Long, List<Map<String, Object>>> reportInfoIndex = getReportInfo(paramsGroup.get("ordNo"), dataKey);
        for (Long key : reportInfoIndex.keySet()) {
          if (reportInfo.containsKey(key)) {
            reportInfo.get(key).addAll(reportInfoIndex.get(key));
          } else {
            reportInfo.put(key, reportInfoIndex.get(key));
          }
        }
      }
    }
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

  private Map<String, String> convertDataCodeToId(
    List<ReportXmlParam> params,
    Map<Long, List<Map<String, Object>>> reportOutputInfo,
    Integer type,
    Integer reportType,
    Map<String, Object> dataKey
  ) {
    Map<String, String> result = new HashMap<>();

    // sqlCode属性値でグループ化したParam要素情報を取得する
    Map<String, List<ReportXmlParam>> groupedParams = params.stream()
      .filter(p -> !StringUtils.isEmpty(p.getId()))
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

        // テンプレート繰り返しに対する処理を行う
        // グループ項目に対する処理を行う
        if (type == ReportConstant.ReportClass.DISTRIBUTION_LIST_BED_REPORT){
          convertDataCodeToTmplGroupForDistributionListBed(
            result,
            groupedParam.getValue().stream()
              .filter(param -> !StringUtils.isEmpty(param.getGroupId()) && param.isTmplRepeat())
              .collect(toList()),
            tmpList
          );
        }
        else {
          convertDataCodeToTmplGroup(
            result,
            groupedParam.getValue().stream()
              .filter(param -> !StringUtils.isEmpty(param.getGroupId()) && param.isTmplRepeat())
              .collect(toList()),
            tmpList
          );
        }

        // テンプレート繰り返しに対する処理を行う
        // パラメータ項目に対する処理を行う
        convertDataCodeToTmplParam(
          result,
          groupedParam.getValue().stream()
            .filter(param -> StringUtils.isEmpty(param.getGroupId()) && param.isTmplRepeat())
            .collect(toList()),
          tmpList
        );
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
          if(tempValue.length() > 0) {
            tempValue = reportServiceImpl.convertValue(param, tempValue);
            result.put(key, reportServiceImpl.addLineBreak(tempValue, param));
          }
        });
      }
    });

    // 繰返しでない項目&グループ改頁OFFの項目がテンプレート繰返し時に全て領域で出力されること
    convertRepeatToTmpl(result, newGroupe);

    ReportCommonUtil.pageAndPageCount(result, params, dataKey);
    return  result;
  }

  private String getParamRepeatTypeForDistributionListBed(ReportXmlParam param) {
    String strRepeatType = "";
    if(param.getReportXmlGroup() == null) return strRepeatType;
    if(param.getGroupId().contains("配布リスト(ベッド).ベッド情報")){
      if(param.getDataCode().contains("pat")){
        strRepeatType = "repeat_pat_id";
      }
      else {
        strRepeatType = "repeat_ord_no";
      }
    }
    return strRepeatType;
  }

  // グループ繰り返し
  // テンプレート内
  // 帳票種別[配布リスト(ベッド)]
  private void convertDataCodeToTmplGroupForDistributionListBed(Map<String, String> result, List<ReportXmlParam> params, List<Map<String, Object>> tmpList){
    Map<String, Object> pageInfoMap = new HashMap<>();
    pageInfoMap.put("MAX_REPEATMAX", 1);
    pageInfoMap.put("GROUP_REPEAT_KEY", "");
    pageInfoMap.put("GROUP_REPEAT_MAX", 1);
    params.stream()
      .forEach(param -> {
        ReportXmlGroup group = param.getReportXmlGroup();
        Integer repeatMax = (group != null && group.getRepeatMax() != null) ? group.getRepeatMax() : 1;
        if (repeatMax > Integer.parseInt(pageInfoMap.get("MAX_REPEATMAX").toString())) {
          pageInfoMap.put("MAX_REPEATMAX", repeatMax);
        }
        String tmplKey = getParamRepeatTypeForDistributionListBed(param);
        if(tmplKey.equals("repeat_ord_no")) pageInfoMap.put("GROUP_REPEAT_KEY", tmplKey);
        else if(tmplKey.equals("repeat_pat_id") && pageInfoMap.get("GROUP_REPEAT_KEY").toString().length() == 0) {
          pageInfoMap.put("GROUP_REPEAT_KEY", tmplKey);
        }

        // フィルタ処理を行う
        List<Map<String, Object>> filteredList = reportServiceImpl.filterReportInfo(param, tmpList);
        // フィルタ処理の結果がEmptyの場合
        if (filteredList.isEmpty()) {
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("帳票：フィルタ結果した結果が空");
          logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
          return;
        }
        Integer groupMax = 0;
        if(tmplKey.length()>0) {
          Map<Long, List<Map<String, Object>>> ordInfoList = filteredList.stream()
            .collect(Collectors.groupingBy(map -> (Long) map.get(tmplKey), LinkedHashMap::new, Collectors.toCollection(ArrayList::new)));
          groupMax = ordInfoList.size();
        }else{
          groupMax = filteredList.size();
        }
        if (groupMax > Integer.parseInt(pageInfoMap.get("GROUP_REPEAT_MAX").toString())) {
          pageInfoMap.put("GROUP_REPEAT_MAX", groupMax);
        }
      });

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

        String tmplKey = getParamRepeatTypeForDistributionListBed(param);
        Map<Long, List<Map<String, Object>>> ordInfoList = new LinkedHashMap<>();
        if(tmplKey.length()>0) {
          ordInfoList = filteredList.stream()
            .collect(Collectors.groupingBy(map -> (Long) map.get(tmplKey), LinkedHashMap::new, Collectors.toCollection(ArrayList::new)));
        }else if(pageInfoMap.get("GROUP_REPEAT_KEY").toString().length() > 0){
          ordInfoList = filteredList.stream()
            .collect(Collectors.groupingBy(map -> (Long) map.get(pageInfoMap.get("GROUP_REPEAT_KEY").toString()), LinkedHashMap::new, Collectors.toCollection(ArrayList::new)));
        }else{
          ordInfoList.put(-1l, filteredList);
        }

        Integer groupMax = Integer.valueOf(pageInfoMap.get("GROUP_REPEAT_MAX").toString());
        if(pageInfoMap.get("GROUP_REPEAT_KEY").toString().length() > 0 && groupMax < filteredList.size()){
          for(Long keyNo : ordInfoList.keySet()){
            List<Map<String, Object>> outputInfos = ordInfoList.get(keyNo);
            Integer listCount = 1;
            if(!pageInfoMap.get("GROUP_REPEAT_KEY").toString().equals(tmplKey)) {
              Map<Long, List<Map<String, Object>>> ordInfoListbyGroup = outputInfos.stream()
                .collect(Collectors.groupingBy(map -> (Long) map.get(pageInfoMap.get("GROUP_REPEAT_KEY").toString()), LinkedHashMap::new, Collectors.toCollection(ArrayList::new)));
              listCount = ordInfoListbyGroup.size();
            }
            outputInfos = ordInfoList.get(keyNo).stream().limit(listCount).collect(toList());
            ordInfoList.put(keyNo, outputInfos);
          }
        }

        ReportXmlTmplRepeat tmplRepeat = param.getReportXmlTmplRepeat();
        ReportXmlGroup group = param.getReportXmlGroup();
        int pageStart = 0;
        int tmplLoopStart = 0;
        // add #12497 テンプレート繰返しがグループ改頁設定の影響を受けるのは不適切 高 start
        int countNum = 1;
        // add #12497 テンプレート繰返しがグループ改頁設定の影響を受けるのは不適切 高 end
        for (Long keyNo : ordInfoList.keySet()) {
          // add #12497 テンプレート繰返しがグループ改頁設定の影響を受けるのは不適切 高 start
          if (tmplRepeat.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_NO && countNum >= tmplRepeat.getRepeatMax()) break;
          // add #12497 テンプレート繰返しがグループ改頁設定の影響を受けるのは不適切 高 end
          List<Map<String, Object>> outputInfos = ordInfoList.get(keyNo);
          Integer repeatOfPage;
          int groupRepeatMax = (tmplKey.length()>0) ? Integer.valueOf(pageInfoMap.get("MAX_REPEATMAX").toString()) : group != null ? group.getRepeatMax() : 1;
          int tmplLoop = 1;
          if (groupRepeatMax > 1) {
            repeatOfPage = (outputInfos.size() > groupRepeatMax * tmplRepeat.getRepeatMax()) ? groupRepeatMax * tmplRepeat.getRepeatMax() : outputInfos.size();
            // mod #12497 テンプレート繰返しがグループ改頁設定の影響を受けるのは不適切 高 start
//            if((tmplRepeat.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_NO || (group != null && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_NO))) {
            if(group != null && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_NO) {
              // mod #12497 テンプレート繰返しがグループ改頁設定の影響を受けるのは不適切 高 end
              repeatOfPage = group.getRepeatMax();
            }
            tmplLoop = outputInfos.size() / groupRepeatMax + ((outputInfos.size() % groupRepeatMax > 0) ? 1 : 0);
            // add #12497 テンプレート繰返しがグループ改頁設定の影響を受けるのは不適切 高 start
            if (tmplRepeat.getIsNewPage() == ReportXmlTmplRepeat.IS_NEW_PAGE_NO && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_YES) {
              countNum = tmplLoop > tmplRepeat.getRepeatMax() ? tmplRepeat.getRepeatMax() : tmplLoop;
            }
            // add #12497 テンプレート繰返しがグループ改頁設定の影響を受けるのは不適切 高 end
          }else{
            repeatOfPage = (tmplRepeat.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_YES) ? tmplRepeat.getRepeatMax() : 1;
            tmplLoop = outputInfos.size();
          }
          if((tmplRepeat.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_NO || (group != null && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_NO))) {
            if(outputInfos.size() > 0) tmplLoop = 1;
          }

          boolean bShow = false;
          int limitCount = repeatOfPage;
          int pageTmplMax = (tmplRepeat.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_NO || (group != null && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_NO)) ? 0 : outputInfos.size() / repeatOfPage;
          for (Integer pageCount = 0; pageCount <= pageTmplMax; pageCount++) {
            pageStart = tmplLoopStart / tmplRepeat.getRepeatMax();
            int skipCount = pageCount * limitCount;
            List<Map<String, Object>> outputInfo = outputInfos.stream().skip(skipCount).limit(limitCount).collect(toList());
            int count = 1;
            int tmplLoopCount = 1 + tmplLoopStart % tmplRepeat.getRepeatMax();
            for (Integer i = 0; i < outputInfo.size(); i++) {
              String pageStr = String.format("%d%s", pageStart + pageCount + 1, MULTIPLE_PAGES_SEPARATOR);
              String keyTmpl = String.format("%s-%d", tmplRepeat.getId(), tmplLoopCount);
              String keyParam = String.format("%s-%s", param.getId(), count++);

              if(group != null && count > group.getRepeatMax()){
                count = 1;
                tmplLoopCount++;
                if(tmplLoopCount > tmplRepeat.getRepeatMax()) {
                  if(tmplLoopStart % tmplRepeat.getRepeatMax() > 0) pageStart += 1;
                  tmplLoopCount = 1;
                }
              }
              if(bShow) continue;

              String key = String.format("%s%s.%s",pageStr, keyTmpl, keyParam);
              String value = reportServiceImpl.formatValue(param, outputInfo.get(i).get(param.getDataCode()));
              value = reportServiceImpl.convertValue(param, value);
              if (value != null && !"null".equals(value)) {
                result.put(key, reportServiceImpl.addLineBreak(value, param));
              } else {
                result.put(key, "");
              }
              if((tmplKey.length()>0)) bShow = true;
            }
          }
          tmplLoopStart += tmplLoop;
        }
      });
  }

  // グループ繰り返し
  // テンプレート内
  private void convertDataCodeToTmplGroup(Map<String, String> result, List<ReportXmlParam> params, List<Map<String, Object>> tmpList){
    for (ReportXmlParam param : params) {
      // フィルタ処理を行う
      List<Map<String, Object>> filteredList = reportServiceImpl.filterReportInfo(param, tmpList);
      // フィルタ処理の結果がEmptyの場合
      if (filteredList.isEmpty()) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("帳票：フィルタ結果した結果が空");
        logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
        return;
      }

      ReportXmlGroup group = param.getReportXmlGroup();
      Integer repeatMax = (group != null && group.getRepeatMax() != null) ? group.getRepeatMax() : 1;
      Integer tmplRepeatMax = (group != null && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_YES) ? param.getReportXmlTmplRepeat().getRepeatMax() : 1;
      Integer repeatOfPage;
      if (repeatMax > 1) {
        repeatOfPage = (filteredList.size() > repeatMax * tmplRepeatMax) ? repeatMax * tmplRepeatMax : filteredList.size();
      }else{
        repeatOfPage = (filteredList.size() > tmplRepeatMax) ? tmplRepeatMax : filteredList.size();
      }

      int limitCount = repeatOfPage;
      int pageTmplMax = (param.getReportXmlTmplRepeat().getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_NO || (group != null && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_NO)) ? 0 : filteredList.size() / repeatOfPage;
      for (Integer pageCount = 0; pageCount <= pageTmplMax; pageCount++) {
        int skipCount = pageCount * limitCount;
        List<Map<String, Object>> outputInfos = filteredList.stream().skip(skipCount).limit(limitCount).collect(toList());
        int count = 1;
        int tmplLoopCount = 1;
        for (Integer i = 0; i < outputInfos.size(); i++) {
          String pageStr = String.format("%d%s", pageCount + 1, MULTIPLE_PAGES_SEPARATOR);
          ReportXmlTmplRepeat tmplRepeat = param.getReportXmlTmplRepeat();
          String keyTmpl = String.format("%s-%d", tmplRepeat.getId(), tmplLoopCount);
          String keyParam = String.format("%s-%s", param.getId(), count++);
          String key = String.format("%s%s.%s",pageStr, keyTmpl, keyParam);
          String value = reportServiceImpl.formatValue(param, outputInfos.get(i).get(param.getDataCode()));
          value = reportServiceImpl.convertValue(param, value);
          if (value != null && !"null".equals(value)) {
            result.put(key, reportServiceImpl.addLineBreak(value, param));
          } else {
            result.put(key, "");
          }
          if(count>repeatMax){
            count = 1;
            tmplLoopCount++;
          }
        }
      }
    }
  }

  // パラメータ繰り返し
  // テンプレート内
  private void convertDataCodeToTmplParam(Map<String, String> result, List<ReportXmlParam> params, List<Map<String, Object>> tmpList) {
    params.stream()
      .forEach(param -> {
        ReportXmlTmplRepeat tmplRepeat = param.getReportXmlTmplRepeat();
        int pageMax = tmpList.size();
        if((tmplRepeat.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_NO || !"1".equals(param.getIsNewPage())) && tmpList.size() > 0) pageMax = 1;
        int count = 1;
        for (int i = 0; i < pageMax; i++) {
          Map<String, Object> tmpMap = tmpList.get(i);
          // 出力する内容を取得する
          String value = reportServiceImpl.formatValue(param, tmpMap.get(param.getDataCode()));
          value = reportServiceImpl.convertValue(param, value);

          String pageStr = String.format("%d%s", i + 1, MULTIPLE_PAGES_SEPARATOR);
          String keyTmpl = String.format("%s-%d", tmplRepeat.getId(), count);
          String key = String.format("%s%s.%s",pageStr, keyTmpl, param.getId());

          if (value != null && !"null".equals(value)) {
            result.put(key, reportServiceImpl.addLineBreak(value, param));
          } else {
            result.put(key, "");
          }
        }
      });
  }

  // 繰返しでない項目&グループ改頁OFFの項目がテンプレート繰返し時に全て領域で出力されること
  private void convertRepeatToTmpl(Map<String, String> result, LinkedHashMap<String, List<ReportXmlParam>> newGroupe){
    Integer tmplPage = reportServiceImpl.getTmplPageCount(result);
    newGroupe.entrySet().forEach(groupedParam ->{
      groupedParam.getValue().stream()
        .filter(param -> param.isTmplRepeat())
        .forEach(param -> {
          ReportXmlTmplRepeat tmplRepeat = param.getReportXmlTmplRepeat();
          if(tmplRepeat.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_YES){
            ReportXmlGroup group = param.getReportXmlGroup();
            if ((group != null && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_NO) || (StringUtils.isEmpty(param.getGroupId()) && !"1".equals(param.getIsNewPage()))) {
              List<String> repeatKey = result.keySet().stream()
                .filter(r -> r.indexOf(MULTIPLE_PAGES_SEPARATOR) >= 0 && r.indexOf(".") >= 0 && r.substring(r.indexOf("-")+1).indexOf(param.getId()) >= 0)
                .collect(toList());
              for(Integer i = 1; i < tmplPage; i++){
                for(String key : repeatKey){
                  int index = key.indexOf(MULTIPLE_PAGES_SEPARATOR);
                  String keyNew = String.format("%d%s", i + 1, key.substring(index));
                  result.put(keyNew, result.get(key));
                }
              }
            }
          }
        });
    });
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
            value = reportServiceImpl.convertValue(param, value);
            if (param.getIsImage().equals("true") && null != value && !value.equals("") && !value.equals("null"))
            {
              value = "(place)" + value;
            }

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
}

