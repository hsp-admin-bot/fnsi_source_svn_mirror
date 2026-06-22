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
import java.util.Objects;
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
public class ReportForLabelReportServiceImpl implements ReportForLabelReportService {

  /**
   * 帳票出力情報のKey項目に使用する複数ページ区切り文字列.
   */
  private static final String MULTIPLE_PAGES_SEPARATOR = "#";

  private static final Long PRINT_INFO_CODE = 0L;

  private static final String LABEL_OUTPUT_COUNT = "labelOutputCount";

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
  public byte[] getReportExcelFileForLabelReport(Long reportCd, Map<String, Object> dataKey) {
    MstReport mstReport = mstReportDao.selectByCd(reportCd);

    // S3から帳票定義XML、帳票デザインExcelが格納されたZipファイルを取得する
    ReportZipFile reportZipFile = getReportZip(mstReport);

    // SqlCodeをもとに帳票に出力する情報を取得する
    String reportXml = getReportXml(mstReport, reportZipFile);
    List<ReportXmlParam> params = ReportUtils.getParamElements(reportXml);

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

    // add #12626 ラベル帳票で静的テキストが繰り返されない 高 start
    // 改ページ制御対象項目を取得する。
    // isNewPageが空文字の場合は「改ページ時に引き継ぐ項目」として扱う。
    // また、dataCode未設定項目は処理対象外とする。
    List<ReportXmlParam> newPageList = params.stream()
      .filter(param -> "".equals(param.getIsNewPage())
        && !"".equals(param.getDataCode()))
      .collect(Collectors.toList());

    List<Map<String, Object>> detailList = reportInfo.get(16L);

    // pat_id + code単位で、改ページ制御項目の値を保持するためのMap。
    // 同一患者・同一コード内で、改ページ制御対象項目がすべて設定されている
    // 最初のレコードを保持する。
    Map<String, Map<String, Object>> patCodeMap = new LinkedHashMap<>();

    for (Map<String, Object> row : detailList) {

      // 改ページ制御対象項目がすべて設定されているか判定する。
      // 1項目でも未設定(nullまたは空文字)の場合は対象外とする。
      boolean containsAllFields = true;

      for (ReportXmlParam param : newPageList) {

        String dataCode = param.getDataCode();
        Object value = row.get(dataCode);

        // 値が存在しない場合、
        // 当該レコードは引き継ぎ元データとして利用しない。
        if (value == null || String.valueOf(value).trim().isEmpty()) {
          containsAllFields = false;
          break;
        }
      }

      // すべての改ページ制御項目が設定されている場合のみ保持する。
      if (containsAllFields) {

        String patId = String.valueOf(row.get("pat_id"));
        String code = String.valueOf(row.get("code"));

        // 患者ID + コード単位で管理する。
        String key = patId + "_" + code;

        // 最初に取得したレコードを採用する。
        // 同一キーの後続レコードは上書きしない。
        patCodeMap.putIfAbsent(key, row);
      }
    }

    if (!newPageList.isEmpty()) {

      // XML出力対象患者一覧を取得する。
      List<Long> patIdList = (List<Long>) dataKey.get("patIds");

      // 患者単位で処理する。
      for (int index = 0; index < patIdList.size(); index++) {

        String targetPatId = String.valueOf(patIdList.get(index));

        // 明細データを順番に走査する。
        for (Map<String, Object> row : detailList) {

          String patId = String.valueOf(row.get("pat_id"));

          // 対象患者以外のデータは処理対象外。
          if (!Objects.equals(patId, targetPatId)) {
            continue;
          }

          String code = String.valueOf(row.get("code"));

          // 患者ID + コード単位で引き継ぎ元レコードを取得する。
          String key = targetPatId + "_" + code;
          Map<String, Object> firstRow = patCodeMap.get(key);

          // 引き継ぎ元データが存在しない場合は何もしない。
          if (firstRow == null) {
            continue;
          }

          // 同一患者・同一コード内で、
          // 改ページ制御対象項目の値を引き継ぎ元レコードから補完する。
          //
          // これにより、後続ページのレコードに値が存在しない場合でも、
          // 最初に取得した値を利用して帳票出力を行うことができる。
          for (ReportXmlParam param : newPageList) {

            String dataCode = param.getDataCode();

            row.put(dataCode, firstRow.get(dataCode));
          }
        }
      }
    }
    // add #12626 ラベル帳票で静的テキストが繰り返されない 高 end

    // sql実行結果(reportInfo) のデータを Excelに割り当てられるデータリスト(セル：データのリスト)に変換して、reportOutputInfo に格納
    Map<String, String> reportOutputInfo = new HashMap<>();
    dataKey.put("report", mstReport);
    reportOutputInfo = convertDataCodeToId(params, reportInfo, mstReport.getReportClass(), mstReport.getReportType(), dataKey);
    // セル順にソート ( ページなし、1ページ目、2ページ目のようにソートされます )
    reportOutputInfo = sortByKeyB(sortByKeyA(reportOutputInfo));
    // 紹介状画面印刷
    if(null != dataKey.get("IntroLetterReportPrinte") && (Boolean)dataKey.get("IntroLetterReportPrinte")){
      Map<String,Object> htmlCheckMap = (Map<String,Object>)dataKey.get("htmlTemplate");
      for (Map.Entry<String,Object> entry : htmlCheckMap.entrySet()) {
        reportOutputInfo.put(entry.getKey(),entry.getValue().toString());
      }
    }

    // 計算項目
    Map<String, String> calcResult = new HashMap<>();
    reportServiceImpl.formulaCalculateForParams(params, reportInfo, reportInfo, reportOutputInfo, calcResult);

    if(dataKey.get("newPageCountFlag") == null && dataKey.get("functionCd") == null){
      if(!reportServiceImpl.isHaveInfotoShow(reportOutputInfo)){
        byte[] bytes = new byte[]{};
        return bytes;
      }
    }

    try{
      com.aspose.cells.Workbook wb = reportWithAsposeApiService.getReportExcelWorkbookToLabel(mstReport, reportZipFile, params, reportOutputInfo, calcResult, dataKey);
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

    String sortState = "";
    StringBuilder sb = new StringBuilder();
    sb.append(" ORDER BY\n" +
      "\t\t\tdisp_order");
    if (dataKey.get(ReportConstant.ReportDataKey.SORT_CONDITIONS) != null) {
      List<Map<String, String>> sortCondition = (List<Map<String, String>>)dataKey.get(ReportConstant.ReportDataKey.SORT_CONDITIONS);
      List tmpSortKey = new ArrayList();
      List tmpSortKeyAndtmpSortDirection = new ArrayList();
      List tmpSortDirection = new ArrayList();
      LabelReportCompareCan (tmpSortKey,tmpSortDirection,tmpSortKeyAndtmpSortDirection, sortCondition);
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
    dataKey.put("examsort", sortMap.get("examsort"));
  }

  /**
   * order byソートパッケージです
   *
  */
  private void LabelReportCompareCan (List tmpSortKey,List tmpSortDirection,List tmpSortKeyAndtmpSortDirection, List<Map<String, String>> sortConditions) {
    for (int index = 0; index < sortConditions.size(); index++) {
      Map<String, String> item = sortConditions.get(sortConditions.size() - (index+1));
      // 並び替えに使用する項目を取得
      if (item.keySet().contains(CoreConstant.ReportMenu.PATIENT_COOL)) {
        // クール順
        tmpSortKey.add(index,"kur_cd");
        tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.PATIENT_COOL));
        tmpSortKeyAndtmpSortDirection.add(index,"\n,res.kur_cd " + item.get(CoreConstant.ReportMenu.PATIENT_COOL) + " NULLS LAST");
      }
      else if (item.keySet().contains(CoreConstant.ReportMenu.BED_NAME)) {
        // ベッド表示順
        tmpSortKey.add(index,"bed_cd");
        tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.BED_NAME));
        tmpSortKeyAndtmpSortDirection.add(index,"\n,res.bed_order " + item.get(CoreConstant.ReportMenu.BED_NAME) + " NULLS LAST");
      }
      else if (item.keySet().contains(CoreConstant.ReportMenu.MEDICINE_EQUIPMENT_CODE)) {
        // 医材/薬剤
        tmpSortKey.add(index, "data_type_order");
        tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.MEDICINE_EQUIPMENT_CODE));
        tmpSortKeyAndtmpSortDirection.add(index,"\n,data_type_order " + item.get(CoreConstant.ReportMenu.MEDICINE_EQUIPMENT_CODE) + " NULLS LAST");
      }
      else if (item.keySet().contains(CoreConstant.ReportMenu.MEDICINE_EQUIPMENT_CLASS)) {
        // 分類順
        tmpSortKey.add(index, "kind_order");
        tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.MEDICINE_EQUIPMENT_CLASS));
        if (sortConditions.size() - (index+1) == 0) {
          tmpSortKeyAndtmpSortDirection.add(index,"\n,kind_order " + item.get(CoreConstant.ReportMenu.MEDICINE_EQUIPMENT_CLASS) + " NULLS LAST"
            +"\n,res.dia_order " + item.get(CoreConstant.ReportMenu.MEDICINE_EQUIPMENT_CLASS) + " NULLS LAST"
            +"\n,res.medic_order " + item.get(CoreConstant.ReportMenu.MEDICINE_EQUIPMENT_CLASS) + " NULLS LAST"
            +"\n,res.equic_order " + item.get(CoreConstant.ReportMenu.MEDICINE_EQUIPMENT_CLASS) + " NULLS LAST"
            +"\n,res.medic_mix_order " + item.get(CoreConstant.ReportMenu.MEDICINE_EQUIPMENT_CLASS) + " NULLS LAST");
        }
        else {
          tmpSortKeyAndtmpSortDirection.add(index,"\n,kind_order " + item.get(CoreConstant.ReportMenu.MEDICINE_EQUIPMENT_CLASS) + " NULLS LAST"
            +"\n,res.medic_order " + item.get(CoreConstant.ReportMenu.MEDICINE_EQUIPMENT_CLASS) + " NULLS LAST"
            +"\n,res.equic_order " + item.get(CoreConstant.ReportMenu.MEDICINE_EQUIPMENT_CLASS) + " NULLS LAST"
            +"\n,res.medic_mix_order " + item.get(CoreConstant.ReportMenu.MEDICINE_EQUIPMENT_CLASS) + " NULLS LAST");
        }
      }
      else if (item.keySet().contains(CoreConstant.ReportMenu.ROOM_BED_GROUP)) {
        // ベッドグループ表示順
        tmpSortKey.add(index,"room_bed_group");
        tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.ROOM_BED_GROUP));
        tmpSortKeyAndtmpSortDirection.add(index,"\n,res.room_bed_group " + item.get(CoreConstant.ReportMenu.ROOM_BED_GROUP) + " NULLS LAST");
      }
      else if (item.keySet().contains(CoreConstant.ReportMenu.MEDICINE_EQUIPMENT_NAME)) {
        // 名称順
        tmpSortKey.add(index,"name");
        tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.MEDICINE_EQUIPMENT_NAME));
        tmpSortKeyAndtmpSortDirection.add(index,"\n,res.NAME " + item.get(CoreConstant.ReportMenu.MEDICINE_EQUIPMENT_NAME) + " NULLS LAST");
      }
      else if (item.keySet().contains(CoreConstant.ReportMenu.DIALYSIS_ROOM_GROUP)) {
        // 透析室表示順
        tmpSortKey.add(index,"dialysis_room_group");
        tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.DIALYSIS_ROOM_GROUP));
        tmpSortKeyAndtmpSortDirection.add(index,"\n,res.dialysis_room_group " + item.get(CoreConstant.ReportMenu.DIALYSIS_ROOM_GROUP) + " NULLS LAST");
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
      List<Long> patIdList = (List<Long>)dataKey.getOrDefault(ReportConstant.ReportDataKey.PAT_IDS, new ArrayList<>());
      for (int i = 0; i < patIdList.size(); i++) {
        dataKey.put("patId", patIdList.get(i));
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
      List<Long> patIdList = (List<Long>)dataKey.getOrDefault(ReportConstant.ReportDataKey.ORD_NOS, new ArrayList<>());
      for (int i = 0; i < patIdList.size(); i++) {
        dataKey.put("ordNo", patIdList.get(i));
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

    List<Map<String, Object>> labelList = new ArrayList<>();
    if (reportInfo.containsKey(16l) && reportInfo.get(16l) != null) {
      labelList = reportInfo.get(16l);
    }
    List<Map<String, Object>> tmpList = reportInfo.get(159L);
    List<Map<String, Object>> reportInfoOrder = new ArrayList<Map<String, Object>>();
    if (null != labelList && tmpList != null) {
      for (int x = 0; x < labelList.size(); x++) {
        for (int k = 0; k < tmpList.size(); k++) {
          if (labelList.get(x).get("pat_id").toString().equals(tmpList.get(k).get("pat_id").toString())) {
            reportInfoOrder.add(tmpList.get(k));
            continue;
          }
        }
      }

      if(labelList.size()>0) {
        dataKey.put(LABEL_OUTPUT_COUNT, labelList.size());
        tmpList = reportInfoOrder;
        reportInfo.put(Long.valueOf("159"), tmpList);
      }
    }

    for (Long key : reportInfo.keySet()) {
      if (key == 16l || key == 159l) {
        List<Map<String, Object>> info = reportInfo.get(key);
        if (dataKey.get(LABEL_OUTPUT_COUNT) == null) {
          dataKey.put(LABEL_OUTPUT_COUNT, info.size());
        } else if (dataKey.get(LABEL_OUTPUT_COUNT) != null && info.size() > Integer.parseInt(String.valueOf(dataKey.get(LABEL_OUTPUT_COUNT)))) {
          dataKey.put(LABEL_OUTPUT_COUNT, info.size());
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
    if (sqlCodes.contains("16")||sqlCodes.contains(159)) {
      dataKey.remove("patId");
    }
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
        // パラメータ項目に対する処理を行う
        convertDataCodeToParam(
          result,
          groupedParam.getValue().stream()
            .filter(param -> StringUtils.isEmpty(param.getGroupId()) && !param.isTmplRepeat())
            .collect(toList()),
          tmpList
        );

        // テンプレート繰り返しに対する処理を行う
        int startPrintPos = 1;
        if(reportOutputInfo.containsKey(PRINT_INFO_CODE) && reportOutputInfo.get(PRINT_INFO_CODE).size() > 0 && reportOutputInfo.get(PRINT_INFO_CODE).get(0).get("stPos")!=null){
          startPrintPos = (int)reportOutputInfo.get(PRINT_INFO_CODE).get(0).get("stPos");
        }
        convertDataCodeToTmplForLabel(
          result,
          groupedParam.getValue().stream()
            .filter(param -> param.isTmplRepeat())
            .collect(toList()),
          tmpList,
          startPrintPos
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

    ReportCommonUtil.pageAndPageCount(result, params, dataKey);
    return  result;
  }

  // テンプレート内
  // 帳票種別[ラベル]
  private void convertDataCodeToTmplForLabel(Map<String, String> result, List<ReportXmlParam> params, List<Map<String, Object>> tmpList, int startPrintPos){
    params.stream()
      .forEach(param -> {
        ReportXmlTmplRepeat tmplRepeat = param.getReportXmlTmplRepeat();
        ReportXmlGroup group = param.getReportXmlGroup();
        Integer repeatMax = (group != null && group.getRepeatMax() != null) ? group.getRepeatMax() : 1;
        Integer tmplRepeatMax = tmplRepeat.getRepeatMax();
        Integer repeatOfPage;
        if (repeatMax > 1) {
          repeatOfPage = (tmpList.size() > repeatMax * tmplRepeatMax) ? repeatMax * tmplRepeatMax : tmpList.size();
        }else{
          repeatOfPage = (tmpList.size() > tmplRepeatMax) ? tmplRepeatMax : tmpList.size();
        }

        // ページ数分、以下の処理を行う
        int limitCount = repeatOfPage;
        int pageTmplMax = (tmplRepeat.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_NO || (group != null && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_NO)) ? 0 : (tmpList.size() + startPrintPos) / repeatOfPage;

        int startPos = startPrintPos;
        for (Integer pageCount = 0; pageCount <= pageTmplMax; pageCount++) {
          int skipCount = pageCount * limitCount;
          // (key構成：tmplRepeatタグのid属性値 + 連番 + "." + paramタグのid属性値 + "-1"(※))
          // (※ paramタグのgroupId属性値が設定されている場合のみ付与する)
          if(startPrintPos != 1 && pageCount > 0 && startPrintPos + tmpList.size() > tmplRepeatMax){
            skipCount = tmplRepeatMax * pageCount - startPrintPos+1;
          }

          List<Map<String, Object>> outputInfos = tmpList.stream().skip(skipCount).limit(limitCount).collect(toList());
          for (Integer i = 0; i < outputInfos.size(); i++) {
            if (i + startPos > tmplRepeatMax) {
              // 帳票定義XMLで指定されている繰り返し回数を超えた場合、残りのデータは出力しない
              // 印刷開始位置を指定して呼び出されている場合、2ページ目以降は先頭のテンプレートから印刷するために印刷開始位置を1にする
              startPos = 1;
              break;
            }
            String keyPage = "";
            if (("1".equals(param.getIsInTmpl()) && param.getReportXmlGroup() != null) || param.getReportXmlGroup() == null ) {
              keyPage = String.format("%d%s", pageCount + 1, MULTIPLE_PAGES_SEPARATOR);
            }
            String keyTmpl = String.format("%s-%d", tmplRepeat.getId(), i + startPos);
            String keyParam = String.format("%s%s", param.getId(), StringUtils.isEmpty(param.getGroupId()) ? "" : "-1");
            String key = "";
            if ("1".equals(param.getIsInTmpl())) {
              key = String.format("%s%s.%s", keyPage, keyTmpl, keyParam);
            } else {
              key = String.format("%s%s", keyPage, keyParam);
            }
            String value;
            String dataCode;

            if (outputInfos.get(i).size() == 0) {
              result.put(key, "");
              continue;
            }
            if(!StringUtils.isEmpty(param.getParticular()) && param.getParticular().equals("Label") && null != outputInfos.get(i).get("class_name") && null != outputInfos.get(i).get("class_ename"))
            {
              // 分類別情報の場合に読むSQLコードを変える
              // 分類別情報
              final String classNo = outputInfos.get(i).get("class_ename").toString();
              final ReportXmlClassificationDataCode reportXmlClassificationDataCode = param.getReportXmlClassificationDataCodes().get(classNo);
              if(reportXmlClassificationDataCode!=null) {
                dataCode = reportXmlClassificationDataCode.getDataCode();
                if (dataCode.isEmpty()) {
                  // 固定文字列
                  value = reportXmlClassificationDataCode.getFixString();
                } else {
                  // dataCode指定
                  value = reportServiceImpl.formatValue(param, outputInfos.get(i).get(dataCode));
                  value = reportServiceImpl.convertValue(param, value);
                }
              }else{
                value = "";
              }
            }
            else
            {
              value = reportServiceImpl.formatValue(param, outputInfos.get(i).get(param.getDataCode()));
              value = reportServiceImpl.convertValue(param, value);
            }
            if ("null".equals(value)) {
              value = "";
            }

            result.put(key, reportServiceImpl.addLineBreak(value, param));
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

