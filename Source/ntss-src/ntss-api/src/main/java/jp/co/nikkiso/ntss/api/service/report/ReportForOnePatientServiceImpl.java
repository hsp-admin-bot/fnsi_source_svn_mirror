package jp.co.nikkiso.ntss.api.service.report;
// add #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start

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
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstReportDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.OrdPrescriptionDao;
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
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.TreeMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;
import java.util.Optional;

import static java.util.stream.Collectors.toList;

/**
 * 帳票の装置帳票出力Service実装クラス.
 */
@Service
@Slf4j
public class ReportForOnePatientServiceImpl implements ReportForOnePatientService {

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

  @Autowired
  private LogService logService;

  // add #10988 データ項目「処方.処方箋情報.QRコード」を追加　V1.1A 吉 start
  @Autowired
  private ReportCommonUtil reportCommonUtil;
  // add #10988 データ項目「処方.処方箋情報.QRコード」を追加　V1.1A 吉 end

  // add #11276 キー日付に対するデータ引き当て仕様対応 高　start
  @Autowired
  private OrdMainDao rdMainDao;

  @Autowired
  private OrdPrescriptionDao ordPrescriptionDao;
  // add #11276 キー日付に対するデータ引き当て仕様対応 高　end

  @Override
  public byte[] getReportExcelFileForOnePatient(Long reportCd, Map<String, Object> dataKey, Map<String, Object> searchInfo) {
    MstReport mstReport = mstReportDao.selectByCd(reportCd);
    // S3から帳票定義XML、帳票デザインExcelが格納されたZipファイルを取得する
    ReportZipFile reportZipFile = getReportZip(mstReport);
    // 帳票定義XMLを params に格納
    String reportXml = getReportXml(mstReport, reportZipFile);
    List<ReportXmlParam> params = ReportUtils.getParamElements(reportXml);

    if(null == dataKey.get("ordNos") && null != dataKey.get("ordNo")){
      List<Long> ordNos = new ArrayList<>();
      ordNos.add(Long.valueOf(dataKey.get("ordNo").toString()));
      dataKey.put("ordNos", ordNos);
    }
    if(null == dataKey.get("patIds") && null != dataKey.get("patId")){
      List<Long> patIds = new ArrayList<>();
      patIds.add(Long.valueOf(dataKey.get("patId").toString()));
      dataKey.put("patIds", patIds);
    }

    // SqlCodeをもとに帳票に出力する情報を取得する
    Map<Long, List<Map<String, Object>>> reportInfo = new HashMap<>();
    // mod #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe start
    Map<Long, List<Map<String, Object>>> reportInTmplInfo = new HashMap<>();
//    List<ReportXmlParam> paramsMongoNoTmpl = new ArrayList<>();
//    List<ReportXmlParam> paramsMongoYesTmplIN = new ArrayList<>();
//    List<ReportXmlParam> paramsMongoYesTmplOUT = new ArrayList<>();
//    List<ReportXmlParam> paramsNoMongo = new ArrayList<>();
//    reportServiceImpl.paramsByMongoHistory(params,paramsMongoNoTmpl,paramsMongoYesTmplIN,paramsMongoYesTmplOUT,paramsNoMongo);
//    List<String> sqlCodes = getSqlCode(paramsNoMongo);
    // mod #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe end
    // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe start
    // 施設設定マスタNo.106 医材表示順 設定値
    List<String> orderListEqu = reportServiceImpl.getFacilitySettingOrderListToEquipment(mstReport.getFacilityCd(), "3006");
    dataKey.put("equsort", orderListEqu.toString().replace("[", "").replace("]", ""));
    // 施設設定マスタNo.107 投与薬剤表示順 設定値
    List<String> orderListMed = reportServiceImpl.getFacilitySettingOrderListToMedicine(mstReport.getFacilityCd(), "3007");
    dataKey.put("medsort", orderListMed.toString().replace("[", "").replace("]", ""));
    // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe end
    // mod #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe start
    // mod #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
    //String sortDirection = (String)searchInfo.get("tmpSortDirectionStr");
    String sortDirection = "";
    if(searchInfo.containsKey("tmpSortDirectionStr")) {
      sortDirection = (String)searchInfo.get("tmpSortDirectionStr");
    }
    else {
      List<Map<String, String>> sortConditions = (List<Map<String, String>>)dataKey.get(ReportConstant.ReportDataKey.SORT_CONDITIONS);
      if (sortConditions != null && sortConditions.size() > 0) {
        List<Map<String, String>> treatList = new ArrayList();
        treatList = sortConditions.stream().filter(p->p.containsKey(CoreConstant.ReportMenu.TREATMENT_DATE)).collect(Collectors.toList());
        for (int index = 0; index < treatList.size();index++) {
          Map<String, String> item = treatList.get(treatList.size() - (index+1));
          if (item.keySet().contains(CoreConstant.ReportMenu.TREATMENT_DATE)) {
            sortDirection = item.get(CoreConstant.ReportMenu.TREATMENT_DATE).toString();
            break;
          }
        }
      }
    }
    // mod #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end

    boolean bHavetmpl = false;
    List<String> sqlCodes = getSqlCode(params);
    Map<String, List<String>> sqlCodesGroup = new HashMap<>();
    sqlCodesGroup.put("MongDB", new ArrayList<String>());
    sqlCodesGroup.put("Other", new ArrayList<String>());
    for(String sqlCode: sqlCodes){
      // add #10740 指示.修正内容の出力不正 sunsy start
      if (sysDataSetService.isIndHistorySqlSearch(Long.parseLong(sqlCode)))
        sqlCodesGroup.get("Other").add(sqlCode);
      else
      // add #10740 指示.修正内容の出力不正 sunsy end
      if(sysDataSetService.isMongDBSqlSearch(Long.parseLong(sqlCode)))
        sqlCodesGroup.get("MongDB").add(sqlCode);
      else if(sqlCode.equals("239"))
        sqlCodesGroup.get("MongDB").add(sqlCode);
      else
        sqlCodesGroup.get("Other").add(sqlCode);
    }
    // テンプレート内 データ項目
    Map<String, List<ReportXmlParam>> paramsInTmplGroup = new HashMap<>();
    paramsInTmplGroup.put("MongDB", new ArrayList<ReportXmlParam>());
    paramsInTmplGroup.put("Other", new ArrayList<ReportXmlParam>());
    // テンプレート外 テンプレート無し データ項目
    Map<String, List<ReportXmlParam>> paramsGroup = new HashMap<>();
    paramsGroup.put("MongDB", new ArrayList<ReportXmlParam>());
    paramsGroup.put("Other", new ArrayList<ReportXmlParam>());
    // add #11276 キー日付に対するデータ引き当て仕様対応 高　start
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
    // add #11276 キー日付に対するデータ引き当て仕様対応 高　end

    for (ReportXmlParam reParam: params){
      ReportXmlTmplRepeat tmplRepeat = reParam.getReportXmlTmplRepeat();
      if(sqlCodesGroup.get("MongDB").contains(reParam.getSqlCode())) {
        if(tmplRepeat != null && !tmplRepeat.getId().equals("")){
          bHavetmpl = true;
          if(!reParam.isTmplRepeat()) {
            paramsGroup.get("MongDB").add(reParam);
            continue;
          }
          else {
            paramsInTmplGroup.get("MongDB").add(reParam);
            continue;
          }
        }
        else {
          paramsGroup.get("MongDB").add(reParam);
          continue;
        }
      }
      else {
        if(tmplRepeat != null && !tmplRepeat.getId().equals("")){
          bHavetmpl = true;
          if(reParam.isTmplRepeat()){
            paramsInTmplGroup.get("Other").add(reParam);
            continue;
          }
        }
        // mod #11276 キー日付に対するデータ引き当て仕様対応 高　start
        if (!reParam.getDataPath().contains("指示") && !reParam.getDataPath().contains("実績") && !reParam.getDataPath().contains("処方") && !reParam.getDataPath().contains("処方(最新)")) {
          paramsGroup.get("Other").add(reParam);
        } else {
          // mod #10740 指示.修正内容の出力不正 sunsy start
          if (reParam.getDataPath().contains("指示.修正内容") || reParam.getDataPath().contains("指示.指示履歴")) {
            paramsGroup.get("Other").add(reParam);
          }else {
            groupOnePatientReportParam(reParam, paramsGroupInd, paramsGroupRst, paramsGroupIsu, paramsGroupIsuNew);
          }
          // mod #10740 指示.修正内容の出力不正 sunsy end
        }
//        paramsGroup.get("Other").add(reParam);
        // mod #11276 キー日付に対するデータ引き当て仕様対応 高　end
      }
    }

    // データ抽出条件の「基準日」
    String tmplKey = "ord_no";
    if(dataKey.get("dateKind") != null){
      tmplKey = dataKey.get("dateKind").toString().equals("exam_date") ? "exam_main_cd" : dataKey.get("dateKind").toString().equals("issue_date") ? "ord_prescription_no" : "ord_no";
    }
    Map<String, String> sortKey = reportServiceImpl.getSortKey(tmplKey);
    List<Map<String, Object>> results = reportServiceImpl.getGroupKeyNoList(tmplKey, dataKey, null);

    // 帳票の設定抽出条件
    String tmplKeySet = params.get(0).getReportXmlTmplRepeat() != null ? params.get(0).getReportXmlTmplRepeat().getKey() : "";
    Map<String, String> sortKeySet = reportServiceImpl.getSortKey(tmplKeySet);
    List<Map<String, Object>> resultSets = reportServiceImpl.getGroupKeyNoList(tmplKeySet, dataKey, null);

    List<Map<String, Object>> resultEnd = new ArrayList<>();
    for(int i = 0; i < results.size(); i++){
      for(int j = 0; j < resultSets.size(); j++){
        String tmplSortKey = String.valueOf(results.get(i).get(sortKey.get("tmplSortKey"))).replace("/","").replace("-","").substring(0,8);
        String tmplSortKeySet = String.valueOf(resultSets.get(j).get(sortKeySet.get("tmplSortKey"))).replace("/","").replace("-","").substring(0,8);
        if(tmplSortKey.equals(tmplSortKeySet)){
          resultEnd.add(resultSets.get(j));
        }
      }
    }

    List<Long> keyfilteredList = new ArrayList<>();
    for(int i = 0; i < resultEnd.size(); i++){
      keyfilteredList.add(Long.parseLong(reportServiceImpl.getGroupKeybyDateType(resultEnd.get(i).get(sortKeySet.get("tmplSortKey")).toString())));
    }
    // 取得キーの重複除去とソート処理
    if (keyfilteredList.size() >= 1) {
      // keyNoList の重複除去
      keyfilteredList = keyfilteredList.stream().distinct().collect(Collectors.toList());
    }

    if(paramsInTmplGroup.get("MongDB").size()>0){
      Map<String, Object> dataKeyTemp = new LinkedHashMap<>();
      for(String key: dataKey.keySet()){
        dataKeyTemp.put(key, dataKey.get(key));
      }
      List<Long> ordNosAll = dataKeyTemp.get("ordNos") != null ? (List<Long>)dataKeyTemp.get("ordNos") : new ArrayList<>();
      for(int i = 0; i < keyfilteredList.size(); i++){
        dataKeyTemp.put(ReportConstant.ReportDataKey.DATE_FROM, keyfilteredList.get(i));
        dataKeyTemp.put(ReportConstant.ReportDataKey.DATE_TO, keyfilteredList.get(i));
        List<String> sqlCodesMongo = getSqlCode(paramsInTmplGroup.get("MongDB"));
        if(sqlCodesMongo.contains("239")){
          List<Map<String, Object>> result239 = reportServiceImpl.getGroupKeyNoList("ord_no", dataKeyTemp, null);
          List<Long> ordNosby239 = result239.stream().map(map -> Long.parseLong(map.get("ord_no").toString())).filter(Objects::nonNull).collect(toList());
          dataKeyTemp.put("ordNos", ordNosby239);
        }
        Map<Long, List<Map<String, Object>>> reportInfoIndex = sysDataSetService.getSqlDataForOnePatient(sqlCodesMongo, dataKeyTemp);
        for (Long key : reportInfoIndex.keySet()) {
          for(int j = 0; j < reportInfoIndex.get(key).size(); j++){
            reportInfoIndex.get(key).get(j).put("pat_info_date_key", keyfilteredList.get(i));
          }
        }
        for (Long key : reportInfoIndex.keySet()) {
          if (reportInTmplInfo.containsKey(key)) {
            reportInTmplInfo.get(key).addAll(reportInfoIndex.get(key));
          } else {
            reportInTmplInfo.put(key, reportInfoIndex.get(key));
          }
        }
        dataKeyTemp.put("ordNos", ordNosAll);
      }
    }
    selectReportInfo(reportXml, paramsInTmplGroup, dataKey, mstReport.getFacilityCd(), reportInTmplInfo);

    if(paramsGroup.get("MongDB").size()>0){
      Map<String, Object> dataKeyTemp = new LinkedHashMap<>();
      for(String key: dataKey.keySet()){
        dataKeyTemp.put(key, dataKey.get(key));
      }
      if(bHavetmpl){
        // テンプレート外
        //　　　1日指定：　キー日付＝当日（指定日によらず）
        //　　　範囲指定：　キー日付＝当日（指定範囲によらず）
        dataKeyTemp.put(ReportConstant.ReportDataKey.DATE_TO, LocalDate.now().toString().replace("/", "").replace("-", ""));
      }else{
        //テンプレート無し
        //1日指定：　キー日付＝指定日
        //範囲指定：　キー日付＝開始日
        dataKeyTemp.put(ReportConstant.ReportDataKey.DATE_TO, dataKey.get(ReportConstant.ReportDataKey.DATE_FROM));
      }
      List<String> sqlCodesMongo = getSqlCode(paramsGroup.get("MongDB"));
      Map<Long, List<Map<String, Object>>> reportInfoIndex = sysDataSetService.getSqlDataForOnePatient(sqlCodesMongo, dataKeyTemp);
      for (Long key : reportInfoIndex.keySet()) {
        if (reportInfo.containsKey(key)) {
          reportInfo.get(key).addAll(reportInfoIndex.get(key));
        } else {
          reportInfo.put(key, reportInfoIndex.get(key));
        }
      }
    }
    selectReportInfo(reportXml, paramsGroup, dataKey, mstReport.getFacilityCd(), reportInfo);
    // add #11276 キー日付に対するデータ引き当て仕様対応 高　start
    // 指示 (paramsGroupInd)
    selectReportInfoOnePatientReportTmplOut(reportXml, paramsGroupInd, dataKey, mstReport.getFacilityCd(), reportInfo);
    // 実績 (paramsGroupRst)
    selectReportInfoOnePatientReportTmplOut(reportXml, paramsGroupRst, dataKey, mstReport.getFacilityCd(), reportInfo);
    // 処方 (paramsGroupIsu)
    selectReportInfoOnePatientReportTmplOut(reportXml, paramsGroupIsu, dataKey, mstReport.getFacilityCd(), reportInfo);
    // 処方(最新) (paramsGroupIsuNew)
    selectReportInfoOnePatientReportTmplOut(reportXml, paramsGroupIsuNew, dataKey, mstReport.getFacilityCd(), reportInfo);
    // add #11276 キー日付に対するデータ引き当て仕様対応 高　end

    List<Map<String, Object>> tmpParm = reportServiceImpl.getPrintedInfo(params, dataKey, new HashMap<>());
    params = reportServiceImpl.paramsReplaceTmpValue(params, new HashMap<>());
    // mod #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe end

    // sql実行結果(reportInfo) のデータを Excelに割り当てられるデータリスト(セル：データのリスト)に変換して、reportOutputInfo に格納
    Map<String, String> reportOutputInfo = new HashMap<>();
    // add #11127 グループ除外処理の残対応（モニタ、身体情報）　高　start
    reportServiceImpl.reportFilterOutUnusedData(params,reportInfo);
    // add #11127 グループ除外処理の残対応（モニタ、身体情報）　高　end
    // mod #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe start
    //reportOutputInfo = convertDataForOnePatient(params, reportInfo, mstReport.getReportType() != null ? mstReport.getReportType() : 0, sortDirection);
    reportOutputInfo = convertDataForOnePatient(params, reportInfo, reportInTmplInfo, keyfilteredList, dataKey, mstReport.getReportType() != null ? mstReport.getReportType() : 0, sortDirection);
    // mod #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe end
    // セル順にソート ( ページなし、1ページ目、2ページ目のようにソートされます )
    reportOutputInfo = sortByKeyB(sortByKeyA(reportOutputInfo));

    // 計算項目
    Map<String, String> calcResult = new HashMap<>();
    // mod #10446 テンプレート繰返しでの計算式繰返しの制限事項対応②（「=」で始まる計算式） limingzhe start
    reportServiceImpl.formulaCalculateForParams(params, reportInfo, reportInTmplInfo, reportOutputInfo, calcResult);
    // mod #10446 テンプレート繰返しでの計算式繰返しの制限事項対応②（「=」で始まる計算式） limingzhe end

    // add #10988 データ項目「処方.処方箋情報.QRコード」を追加　V1.1A 吉 start
    // QR flag
    List<String> qrInfoList = params.stream()
      .filter(p -> null != p.getDataCode() && "qrCode".equals(p.getDataCode()) && "byte[]".equals(p.getDataType()))
      .map(p -> p.getId())
      .collect(Collectors.toList());
    List<String> qrnewOneInfoList = params.stream()
      .filter(p -> null != p.getDataCode() && "qrCodeForNewOne".equals(p.getDataCode()) && "byte[]".equals(p.getDataType()))
      .map(p -> p.getId())
      .collect(Collectors.toList());
    if(null != qrInfoList && qrInfoList.size()>0) {
      reportCommonUtil.getQRContentInfo(dataKey, reportOutputInfo, qrInfoList,false);
    }
    if(null != qrnewOneInfoList && qrnewOneInfoList.size()>0) {
      reportCommonUtil.getQRContentInfo(dataKey, reportOutputInfo, qrnewOneInfoList,true);
    }
    // add #10988 データ項目「処方.処方箋情報.QRコード」を追加　V1.1A 吉 end

    // 値とグラフを埋め込んだExcelワークブックを取得
    try {
      com.aspose.cells.Workbook wb = reportWithAsposeApiService.getReportExcelWbForOnePatient(mstReport, reportZipFile, params, reportOutputInfo, calcResult);
      wb.calculateFormula(true);
      ByteArrayOutputStream o = new ByteArrayOutputStream();
      wb.save(o, SaveFormat.XLSX);
      wb.dispose();
      return o.toByteArray();
    } catch (Exception e) {
      // エラーメッセージ
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("帳票Excelファイルの出力に失敗しました。" + NtssUtils.ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      throw new NtssException("帳票Excelファイルの出力に失敗しました。");
    }
  }

  // add #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe start
  private void selectReportInfo(String reportXml, Map<String, List<ReportXmlParam>> paramsGroup,
                                Map<String, Object> dataKey, String facilityCd, Map<Long, List<Map<String, Object>>> reportInfo){
    List<ReportXmlParam> params = ReportUtils.getParamElements(reportXml);
    List<String> sqlCodes = getSqlCode(paramsGroup.get("Other"));
    Map<Long, List<Map<String, Object>>> reportInfoIndex = sysDataSetService.getSqlDataForOnePatient(sqlCodes, dataKey);
    List<Map<String, Object>> rec = reportServiceImpl.getPrintedInfo(params, dataKey, reportInfoIndex);
    reportInfoIndex.put(PRINT_INFO_CODE, rec);

    // add #10531 検査日と検査区分がフィルタを超えて繰り返される limingzhe start
    reportServiceImpl.filterReportInfobyParam(paramsGroup.get("Other"), reportInfoIndex);
    // add #10531 検査日と検査区分がフィルタを超えて繰り返される limingzhe end

    // del #11760 【デグレード】処方箋帳票が正常に出なくなっている limingzhe start
//    params = reportServiceImpl.paramsReplaceTmpValue(params, reportInfoIndex);
//    reportInfoIndex = reportServiceImpl.getChangeList(reportInfoIndex, params);
    // del #11760 【デグレード】処方箋帳票が正常に出なくなっている limingzhe end
    for (Long key : reportInfoIndex.keySet()) {
      if (reportInfo.containsKey(key)) {
        reportInfo.get(key).addAll(reportInfoIndex.get(key));
      } else {
        reportInfo.put(key, reportInfoIndex.get(key));
      }
    }
    // add #11760 【デグレード】処方箋帳票が正常に出なくなっている limingzhe start
    params = reportServiceImpl.paramsReplaceTmpValue(params, reportInfo);
    reportInfo = reportServiceImpl.getChangeList(reportInfo, params);
    // add #11760 【デグレード】処方箋帳票が正常に出なくなっている limingzhe end
  }
  // add #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe end
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
  private void groupOnePatientReportParam(
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
   * ・単患者帳票（テンプレートなし）
   * ・単患者帳票（テンプレート外）
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
  private void selectReportInfoOnePatientReportTmplOut(String reportXml,
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
   * 出力する文字列の長さが設定より少ない場合の補充処理
   * @param original
   * @param originalLength
   * @param targetByteLength
   * @param padChar
   * @return
   */
  public static String padStringToByteLength(String original,int originalLength, int targetByteLength, char padChar) {
    int bytesNeeded = targetByteLength - originalLength;
    if (bytesNeeded <= 0) {
      return original;
    }
    StringBuilder sb = new StringBuilder(original);
    while (bytesNeeded > 0) {
      sb.append(padChar);
      bytesNeeded--;
    }
    return sb.toString();
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

  /**
   * 数字型の判定処理
   * @param str　文字列
   * @return true:数字型 false:非数字型
   */
  public static boolean isNumeric(String str) {
    if (str == null || str.isEmpty()) {
      return false;
    }
    int decimalCount = 0;
    boolean hasNegativeSign = false;
    for (int i = 0; i < str.length(); i++) {
      char c = str.charAt(i);
      // Check for negative sign only at the beginning
      if (i == 0 && c == '-') {
        hasNegativeSign = true;
      } else if (c == '.') {
        decimalCount++;
        // Ensure decimal point occurs only once
        if (decimalCount > 1) {
          return false;
        }
      } else if (!Character.isDigit(c)) {
        return false;
      }
    }
    // If there is a negative sign, string length should be greater than 1
    if (hasNegativeSign && str.length() == 1) {
      return false;
    }
    return true;
  }

  // del #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe start
//  private void onePatientDateEdit(List<ReportXmlParam> params, Map<Long, List<Map<String, Object>>> reportInfo, Map<String, Object> dataKey) {
//    // 帳票の設定抽出条件
//    List<String> keyList = new ArrayList<>();
//    String tmplKeySet = params.get(0).getReportXmlTmplRepeat().getKey();
//    if(reportInfo != null && reportInfo.size() > 0) {
//      Map<String, String> sortKey = reportServiceImpl.getSortKey(tmplKeySet);
//      List<Map<String, Object>> results = new ArrayList<>();
//      if(tmplKeySet.length()>0){
//        StringBuilder sqlBuilder = new StringBuilder();
//        sqlBuilder.append("select ").append(sortKey.get("tmplKey")).append(",").append(sortKey.get("tmplSortKey"));
//        sqlBuilder.append(" from ").append(sortKey.get("sortDb"));
//        sqlBuilder.append(" where pat_id = ").append(dataKey.get("patId")).append(" and facility_cd = '").append(dataKey.get("facilityCd")).append("'");
//        sqlBuilder.append(" and ").append(sortKey.get("tmplSortKey")).append(" between '");
//        sqlBuilder.append(String.valueOf(dataKey.get("fromDate")).replace("/","").replace("-","")).append("'");
//        sqlBuilder.append(" and '").append(String.valueOf(dataKey.get("toDate")).replace("/","").replace("-","")).append(" 235959'");
//        sqlBuilder.append(" order by ").append(sortKey.get("tmplSortKey"));
//        results = sysDataSetService.sqlDB5Search(sqlBuilder.toString());
//        if(results != null && results.size() > 0) {
//          keyList.addAll(results.stream().map(el -> el.get(tmplKeySet).toString()).collect(toList()));
//        }
//      }
//      for(Long tempKey : reportInfo.keySet()) {
//        if(!tempKey.toString().contains("11111") && !tempKey.toString().contains("22222")) {
//          List<Map<String, Object>> tempValueList = reportInfo.get(tempKey);
//          boolean isExist = tempValueList.stream().anyMatch(el -> el.containsKey(tmplKeySet) && el.get(tmplKeySet) != null);
//          if(isExist) {
//            List<Map<String, Object>> tempResultList = tempValueList.stream().filter(el -> keyList.contains(el.get(tmplKeySet).toString())).collect(toList());
//            reportInfo.put(tempKey, tempResultList);
//          }
//        }
//      }
//    }
//  }
//
//  private void mongoYesTmplIn(List<ReportXmlParam> paramsMongoYesTmplIn, Map<String, Object> dataKey, List<ReportXmlParam> params) {
//    // ・テンプレートあり ＞テンプレート内
//    // mod #11584 テンプレート「処方箋交付日」抽出のとき処方箋区分指定で空ページが出力される limingzhe start
//    //List<String> sqlCodesParamsMongoYesTmplIn = getSqlCode(paramsMongoYesTmplIn);
//    //if (paramsMongoYesTmplIn != null && paramsMongoYesTmplIn.size() > 0) {
//    List<String> sqlCodes = getSqlCode(params);
//    boolean bHavetmpl = false;
//    Map<String, List<String>> sqlCodesGroup = new HashMap<>();
//    sqlCodesGroup.put("ordPrescriptionNo", new ArrayList<String>());
//    for(String sqlCode: sqlCodes){
//      if(sysDataSetService.distinParaOnlybyParam(Long.parseLong(sqlCode), "ordPrescriptionNo"))
//        sqlCodesGroup.get("ordPrescriptionNo").add(sqlCode);
//    }
//    // テンプレート内 データ項目
//    Map<String, List<ReportXmlParam>> paramsInTmplGroup = new HashMap<>();
//    paramsInTmplGroup.put("ordPrescriptionNo", new ArrayList<ReportXmlParam>());
//    for (ReportXmlParam reParam: params){
//      ReportXmlTmplRepeat tmplRepeat = reParam.getReportXmlTmplRepeat();
//     if(sqlCodesGroup.get("ordPrescriptionNo").contains(reParam.getSqlCode())) {
//        if(tmplRepeat != null && !tmplRepeat.getId().equals("")){
//          bHavetmpl = true;
//          if(reParam.isTmplRepeat()){
//            paramsInTmplGroup.get("ordPrescriptionNo").add(reParam);
//            continue;
//          }
//        }
//      }
//    }
//    if ((paramsMongoYesTmplIn != null && paramsMongoYesTmplIn.size() > 0) || (paramsInTmplGroup.get("ordPrescriptionNo").size()>0)) {
//    // mod #11584 テンプレート「処方箋交付日」抽出のとき処方箋区分指定で空ページが出力される limingzhe end
//      if(dataKey.containsKey("prescriptionList")) {
//        List<OrdPrescription> prescriptionList = (ArrayList<OrdPrescription>)dataKey.get("prescriptionList");
//        if(prescriptionList != null && prescriptionList.size() > 0) {
//          // 帳票の設定抽出条件
//          String tmplKeySet = params.get(0).getReportXmlTmplRepeat().getKey();
//          Map<String, String> sortKey = reportServiceImpl.getSortKey(tmplKeySet);
//          List<Map<String, Object>> results = new ArrayList<>();
//          if(tmplKeySet.length()>0){
//            StringBuilder sqlBuilder = new StringBuilder();
//            sqlBuilder.append("select ").append(sortKey.get("tmplKey")).append(",").append(sortKey.get("tmplSortKey"));
//            sqlBuilder.append(" from ").append(sortKey.get("sortDb"));
//            sqlBuilder.append(" where pat_id = ").append(dataKey.get("patId")).append(" and facility_cd = '").append(dataKey.get("facilityCd")).append("'");
//            sqlBuilder.append(" and ").append(sortKey.get("tmplSortKey")).append(" between '");
//            sqlBuilder.append(String.valueOf(dataKey.get("fromDate")).replace("/","").replace("-","")).append("'");
//            sqlBuilder.append(" and '").append(String.valueOf(dataKey.get("toDate")).replace("/","").replace("-","")).append(" 235959'");
//            // add #11584 テンプレート「処方箋交付日」抽出のとき処方箋区分指定で空ページが出力される limingzhe start
//            if(tmplKeySet.equals("ord_prescription_no")){
//              sqlBuilder.append(" and prescription_type in (");
//              List<String> prescriptionTypeList = new ArrayList<>();
//              if(dataKey.get("prescriptionClassList") != null){
//                prescriptionTypeList = (List<String>) dataKey.get("prescriptionClassList");
//              } else {
//                prescriptionTypeList.add("-1");
//              }
//              for(String t : prescriptionTypeList){
//                sqlBuilder.append("'").append(t).append("',");
//              }
//              sqlBuilder.deleteCharAt(sqlBuilder.length() - 1);
//              sqlBuilder.append(")");
//            }
//            sqlBuilder.append(" and is_del = '0'");
//            // add #11584 テンプレート「処方箋交付日」抽出のとき処方箋区分指定で空ページが出力される limingzhe end
//            sqlBuilder.append(" order by ").append(sortKey.get("tmplSortKey"));
//            results = sysDataSetService.sqlDB5Search(sqlBuilder.toString());
//            if(results != null && results.size() > 0) {
//              List<String> handleDateList = results.stream().map(el -> el.get(sortKey.get("tmplSortKey")).toString()).collect(toList());
//              List<Long> ordPrescriptionNos = new ArrayList<>();
//              for(OrdPrescription ordPrescription : prescriptionList) {
//                if(handleDateList.contains(ordPrescription.getIssueDate())) {
//                  ordPrescriptionNos.add(ordPrescription.getOrdPrescriptionNo());
//                }
//              }
//              if(ordPrescriptionNos.size() > 0) {
//                dataKey.put(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NOS, ordPrescriptionNos);
//              }
//            }
//          }
//        }
//        // add #11646 基準日「処方日」で期間指定したときに透析予定がない日の処方が出力できないことがある 高 start
//        else {
//          dataKey.put(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NOS, new ArrayList<>());
//        }
//        // add #11646 基準日「処方日」で期間指定したときに透析予定がない日の処方が出力できないことがある 高 end
//      }
//    }
//  }
// del #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe end

  /**
   * sql実行結果をExcelに割り当てられるデータリスト(セル：データのリスト)に変換
   * ※帳票種別：02：単患者帳票 用の処理です
   *
   * @param params：帳票のxmlオブジェクト
   * @param reportOutputInfo：sys_data_set の取得データ { sqlcd : [データ,,,] } のリスト
   * @param reportType：レポートタイプ
   */
  private Map<String, String> convertDataForOnePatient(
    List<ReportXmlParam> params,
    Map<Long, List<Map<String, Object>>> reportOutputInfo,
    // add #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe start
    Map<Long, List<Map<String, Object>>> reportInTmplInfo, List<Long> keyNoList,
    Map<String, Object> dataKey,
    // add #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe end
    int reportType,
    String sortDirection
  ) {
    // sqlCode属性値でグループ化したParam要素情報を取得する ( id(セル指定)、sqlcd が存在しない項目は除外 )
    // mod #10650 検査結果（指定日以前）の仕様課題 2025/02/26 高 start
//    Map<String, List<ReportXmlParam>> groupedParams = params.stream()
//      .filter(p -> !StringUtils.isEmpty(p.getId()) && !StringUtils.isEmpty(p.getSqlCode()))
//      .collect(Collectors.groupingBy(p -> p.getSqlCode()));
    Map<String, List<ReportXmlParam>> groupedParams = params.stream()
      .filter(p -> !StringUtils.isEmpty(p.getId()) && !StringUtils.isEmpty(p.getSqlCode())
        || ("1".equals(p.getIsInTmpl()) && String.valueOf(p.getSqlCode()).matches(".*9999931$")))
      .collect(Collectors.groupingBy(p -> p.getSqlCode()));
    // mod #10650 検査結果（指定日以前）の仕様課題 2025/02/26 高 end
    // 応答データ格納用
    Map<String, String> result = new HashMap<>();
    // del #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe start
//    // テンプレート内項目用の集計オブジェクト ( Map<セル, ReportXmlParam> )
//    Map<String, ReportXmlParam> tmpOneData = new HashMap<>();
//    // テンプレート内の繰り返し項目用の集計オブジェクト ( Map<セル, ReportXmlParam> )
//    Map<String, ReportXmlParam> tmpRepData = new HashMap<>();
    // del #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe end

    // { 割当先セル：データ } のデータリストを作成
    //【01】テンプレート外項目の処理を実施 / テンプレート内項目の処理は項目の集計後、後続処理で実施します
    for (Map.Entry<String, List<ReportXmlParam>> groupedParam : groupedParams.entrySet()) {

      // sqlCodeをもとに出力情報を取得する
      Long sqlCode = Long.valueOf(groupedParam.getKey());
      List<Map<String, Object>> tmpList = reportOutputInfo.get(sqlCode);

      if (tmpList == null || tmpList.isEmpty()) {
        // sqlの取得値が空の場合は処理をスキップ
        continue;
      }

      // 項目毎、出力先の設定文字列と値を応答データに格納
      List<ReportXmlParam> paramList = groupedParam.getValue();
      for (ReportXmlParam param : paramList) {

        // グループの繰り返し回数 / グループIDは、繰り返し可能な項目 ( sys_data_set.can_repeat = 1 ) にのみ付与されています
        Integer gRepeatMax = 1;
        if (!StringUtils.isEmpty(param.getGroupId()) && param.getReportXmlGroup() != null) {
          gRepeatMax = param.getReportXmlGroup().getRepeatMax() != null ? param.getReportXmlGroup().getRepeatMax() : 1;
        }

        // add #10650 検査結果（指定日以前）の仕様課題 2025/02/26 高 start
        // tmpl repeat上限
        int tRepeatMax = Optional.ofNullable(param.getReportXmlTmplRepeat().getRepeatMax())
          .filter(v -> v > 0)
          .orElse(Integer.MAX_VALUE);
        // add #10650 検査結果（指定日以前）の仕様課題 2025/02/26 高 end

        if (gRepeatMax <= 1 && !param.isTmplRepeat()) {
          // 単一項目
          // グループ項目でない、もしくはグループ設定の繰り返し回数が1回以下、且つテンプレート外の項目を、単一項目とします

          // フィルタ処理
          List<Map<String, Object>> filteredList = reportServiceImpl.filterReportInfo(param, tmpList);
          if (filteredList.isEmpty()) {
            // フィルタ処理の結果、出力対象がなくなった場合は処理をスキップ
            continue;
          }

          // データをループ処理
          ReportXmlGroup group = param.getReportXmlGroup();
          int pageCount = 1;
          for (Map<String, Object> sqlData : filteredList) {
            // { key ： value } のデータに出力 ( key →「ページ + "#" + セル」)
            // mod #12231 グループ繰り返しOFFの項目群が2ページ目に1ページ目と同じ内容にならない 高 start
            String pageStr = "";
            // mod #10691 【デグレ】パラメータ改頁設定が機能していない 高 start
//            if (!StringUtils.isEmpty(group) && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_YES) {
            if ((!StringUtils.isEmpty(group) && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_YES) || (group == null && "1".equals(param.getIsNewPage()))) {
              // mod #10691 【デグレ】パラメータ改頁設定が機能していない 高 end
              pageStr = String.format("%d%s", pageCount, MULTIPLE_PAGES_SEPARATOR);
            }
//            String pageStr = String.format("%d%s", pageCount, MULTIPLE_PAGES_SEPARATOR);
            // mod #12231 グループ繰り返しOFFの項目群が2ページ目に1ページ目と同じ内容にならない 高 end
            String key = param.getId();
            // mod #10691 【デグレ】パラメータ改頁設定が機能していない 高 start
//            if(group != null) key = String.format("%s%s", pageStr, param.getId());
            if(group != null || (group == null && "1".equals(param.getIsNewPage()))) key = String.format("%s%s", pageStr, param.getId());
            // mod #10691 【デグレ】パラメータ改頁設定が機能していない 高 end
            String value = reportServiceImpl.formatValue(param, sqlData.get(param.getDataCode()));
            value = reportServiceImpl.convertValue(param, value);
            if (value != null && !"null".equals(value)) {
              result.put(key, reportServiceImpl.addLineBreak(value, param));
            } else {
              result.put(key, "");
            }
            // mod #10691 【デグレ】パラメータ改頁設定が機能していない 高 start
//            if (group != null && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_YES) {
            if ((group != null && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_YES) || (group == null && "1".equals(param.getIsNewPage()))) {
              // mod #10691 【デグレ】パラメータ改頁設定が機能していない 高 end
              // ページ切り替えが有効な場合は、カウントをリセットして処理続行
              pageCount++;
            } else {
              // ページ切り替えなしの場合
              // 帳票定義XMLで指定されている繰り返し回数を超えた場合、残りのデータは出力しない
              break;
            }
          }
        } else if (gRepeatMax >= 2 && !param.isTmplRepeat()) {
          // 繰り返し項目
          // グループ設定が存在し、グループ設定の繰り返し回数が2以上、且つ、テンプレート外の項目を、繰り返し項目とします

          // フィルタ処理
          List<Map<String, Object>> filteredList = reportServiceImpl.filterReportInfo(param, tmpList);
          if (filteredList.isEmpty()) {
            // フィルタ処理の結果、出力対象がなくなった場合は処理をスキップ
            continue;
          }

          // データをループ処理
          ReportXmlGroup group = param.getReportXmlGroup();
          int pageCount = 1;
          int dataCount = 1;
          for (Map<String, Object> sqlData : filteredList) {

            // { key ： value } のデータに出力 ( key →「ページ + "#" + セル + "-" + データNo」)
            // mod #12231 グループ繰り返しOFFの項目群が2ページ目に1ページ目と同じ内容にならない 高 start
            String pageStr = "";
            if (!StringUtils.isEmpty(group) && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_YES){
              pageStr = String.format("%d%s", pageCount, MULTIPLE_PAGES_SEPARATOR);
            }
//            String pageStr = String.format("%d%s", pageCount, MULTIPLE_PAGES_SEPARATOR);
            // mod #12231 グループ繰り返しOFFの項目群が2ページ目に1ページ目と同じ内容にならない 高 end
            String key = String.format("%s%s-%d", pageStr, param.getId(), dataCount);

            String value = reportServiceImpl.formatValue(param, sqlData.get(param.getDataCode()));
            value = reportServiceImpl.convertValue(param, value);
            if (value != null && !"null".equals(value)) {
              result.put(key, reportServiceImpl.addLineBreak(value, param));
            } else {
              result.put(key, "");
            }

            // 1ページの繰り返し回数を超えているか判定：超えている場合は、pageCount + 1 / ページ切り替え設定がない場合はそこで出力終了
            dataCount++;
            if (dataCount > gRepeatMax) {
              if (group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_YES) {
                // ページ切り替えが有効な場合は、カウントをリセットして処理続行
                dataCount = 1;
                pageCount++;
              } else {
                // ページ切り替えなしの場合
                // 帳票定義XMLで指定されている繰り返し回数を超えた場合、残りのデータは出力しない
                break;
              }
            }
          }
        }
        // add #10650 検査結果（指定日以前）の仕様課題 2025/02/26 高 start
        else if (param.isTmplRepeat()) {
          List<Map<String, Object>> filteredList = reportServiceImpl.filterReportInfo(param, tmpList);
          if (filteredList.isEmpty()) {
            continue;
          }

          ReportXmlGroup group = param.getReportXmlGroup();
          ReportXmlTmplRepeat tmpl = param.getReportXmlTmplRepeat();
          // 現在のページ番号（0開始、出力時は+1）
          int pageCount = 0;
          // 現在ページ内のtmpl連番
          int tmplCount = 1;
          // 現在group内のデータ連番
          int dataCount = 1;

          for (Map<String, Object> sqlData : filteredList) {

            // =========================
            // 1. key構造の生成
            // 形式： ページ番号@tmplId-連番.paramId-連番
            // =========================
            String pageStr = String.format("%d%s", pageCount + 1, MULTIPLE_PAGES_SEPARATOR);
            String keyTmpl = String.format("%s-%d", tmpl.getId(), tmplCount);
            String keyParam = String.format("%s-%s", param.getId(), dataCount);
            String key = String.format("%s%s.%s", pageStr, keyTmpl, keyParam);

            // =========================
            // 2. データのフォーマット処理
            // =========================
            String value = reportServiceImpl.formatValue(param, sqlData.get(param.getDataCode()));
            value = reportServiceImpl.convertValue(param, value);

            if (value != null && !"null".equals(value)) {
              result.put(key, reportServiceImpl.addLineBreak(value, param));
            } else {
              result.put(key, "");
            }

            // group内データ件数をインクリメント
            dataCount++;

            // =========================
            // 3. groupの繰返し上限に達したか判定
            // =========================
            if (dataCount > gRepeatMax) {

              // =========================
              // groupの繰返し上限超過判定
              // =========================

              // groupが流転（改ページ）不可の場合は、
              // 当該tmpl内でこれ以上出力できないため処理終了
              if (StringUtils.isEmpty(group) || group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_NO) {
                break;
              }

              // group単位で次の出力枠へ移動するため、
              // group内データ件数を初期化
              dataCount = 1;

              // tmpl内の次の表示位置へ移動
              tmplCount++;

              // =========================
              // tmplの繰返し上限超過判定
              // =========================
              if (tmplCount > tRepeatMax) {

                // tmplが改ページ不可の場合、
                // ページを増やせないため帳票出力を終了
                if (tmpl.getIsNewPage() == ReportXmlTmplRepeat.IS_NEW_PAGE_NO) {
                  break;
                }

                // tmplの上限に達したため改ページを実施
                pageCount++;

                // 次ページのtmpl出力開始位置へ初期化
                tmplCount = 1;
              }
            }
          }
        }
        // add #10650 検査結果（指定日以前）の仕様課題 2025/02/26 高 end
        // del #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe start
//        else if (gRepeatMax <= 1 && param.isTmplRepeat()) {
//          // テンプレート内の項目(繰り返し項目でない)
//          // groupId がない(グループ項目ではない)、もしくはグループ設定の繰り返し回数が1回 / isTmplRepeat：テンプレート繰り返し対象である
//          tmpOneData.put(param.getId(), param);
//        } else if (gRepeatMax >= 2 && param.isTmplRepeat()) {
//          // テンプレート内の繰り返し項目
//          // グループ設定が存在し、グループ設定の繰り返し回数が2以上、且つ、テンプレート内
//          tmpRepData.put(param.getId(), param);
//        }
        // del #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe end
      } // for (ReportXmlParam param : paramList) { (項目毎のループ) の終端

    } // for (Entry<String, List<ReportXmlParam>> groupedParam : groupedParams.entrySet()) { (sql毎のデータリスト)の終端

    //【02】 テンプレート繰り返し処理：テンプレート内項目(単一、繰り返し)用のsql取得結果から、テンプレート設定に設定されたキーを集計し、キー毎にデータを出力する
    // del #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe start
//    // テンプレート設定取得
//    ReportXmlTmplRepeat tmplRepeat = null;
//    boolean tmplNewPageFlg = false;
//    int tmplRepeatMax = 0;
//    // テンプレートの抽出条件設定 ( key：テンプレートキー (初期値は ord_no)、repeatMode：テンプレートキーのソートを行うキー(名称が不適切なのは以前からの引継ぎの為です )
//    String tmplKey = "ord_no";
//    Map<String, String> sortKey = new HashMap<>();
//    Map<String, ReportXmlParam> tmpParam = tmpOneData.size() > 0 ? tmpOneData : tmpRepData;
//    if (tmpParam != null && tmpParam.size() > 0) {
//      for(String cel : tmpParam.keySet()) {
//        ReportXmlParam targetParam = tmpParam.get(cel);
//        tmplRepeat = targetParam.getReportXmlTmplRepeat();
//        if (tmplRepeat != null) {
//          tmplNewPageFlg = tmplRepeat.getIsNewPage() == ReportXmlTmplRepeat.IS_NEW_PAGE_YES ? true : false;
//          tmplRepeatMax = tmplRepeat.getRepeatMax();
//          tmplKey = tmplRepeat.getKey();
//          sortKey = reportServiceImpl.getSortKey(tmplKey);
//        }
//        // テンプレート設定は帳票テンプレート内で1つのみの為、1件取得したら処理を抜ける
//        break;
//      }
//    }
//
//    // テンプレート内項目(単一、繰り返し)用のsql取得結果から、ordNo等の繰り返しの基準となるNoを集計する
//    List<Long> keyNoList = new ArrayList<>();
//    for(String cel : tmpOneData.keySet()) {
//      // テンプレート内の項目(繰り返し項目でない) の 項目からキーを集計
//      ReportXmlParam targetParam = tmpOneData.get(cel);
//      Long sqlCd = Long.valueOf(targetParam.getSqlCode());
//
//      List<Map<String, Object>> sqlResultData = reportOutputInfo.get(sqlCd);
//      if (sqlResultData == null) {
//        continue;
//      }
//
//      for (Map<String, Object> sqlData : sqlResultData) {
//        if (sqlData.get(tmplKey) != null && !StringUtils.isEmpty(sqlData.get(tmplKey).toString())) {
//          // キー項目が存在するデータからキーを集計する
//          Long keyNo = Long.valueOf(sqlData.get(tmplKey).toString());
//          keyNoList.add(keyNo);
//        }
//      }
//    }
//    for(String cel : tmpRepData.keySet()) {
//      // テンプレート内の項目(繰り返し項目) の 項目からキーを集計
//      ReportXmlParam targetParam = tmpRepData.get(cel);
//      Long sqlCd = Long.valueOf(targetParam.getSqlCode());
//
//      List<Map<String, Object>> sqlResultData = reportOutputInfo.get(sqlCd);
//      if (sqlResultData == null) {
//        continue;
//      }
//
//      for (Map<String, Object> sqlData : sqlResultData) {
//        if (sqlData.get(tmplKey) != null && !StringUtils.isEmpty(sqlData.get(tmplKey).toString())) {
//          // キー項目が存在するデータからキーを集計する
//          Long keyNo = Long.valueOf(sqlData.get(tmplKey).toString());
//          keyNoList.add(keyNo);
//        }
//      }
//    }
//
//    // 取得キーの重複除去とソート処理
//    if (keyNoList.size() >= 1) {
//      // keyNoList の重複除去
//      keyNoList = keyNoList.stream().distinct().collect(Collectors.toList());
//
//      // keyList の ソート処理
//      StringBuilder sqlBuilder = new StringBuilder();
//      sqlBuilder.append("select ").append(tmplKey);
//      sqlBuilder.append(" from ").append(sortKey.get("sortDb"));
//      sqlBuilder.append(" where ").append(tmplKey).append(" in (");
//      for (Long keyNo : keyNoList) {
//        sqlBuilder.append(String.valueOf(keyNo));
//        sqlBuilder.append(",");
//      }
//      sqlBuilder.deleteCharAt(sqlBuilder.length() - 1);
//      sqlBuilder.append(")");
//      sqlBuilder.append(" order by ").append(sortKey.get("tmplSortKey"));
//      if (!StringUtils.isEmpty(sortDirection)) {
//        sqlBuilder.append(" ").append(sortDirection);
//      }
//      List<Map<String, Object>> results = sysDataSetService.sqlDB5Search(sqlBuilder.toString());
//
//      List<Long> tmpKeyNoList = new ArrayList<>();
//      for (Map<String, Object> tmpMap : results) {
//        tmpKeyNoList.add(Long.valueOf(tmpMap.get(tmplKey).toString()));
//      }
//      keyNoList = tmpKeyNoList;
//    }
//    // keyNo毎にテンプレートにデータを割り当てていく処理 ( 設定ミス等でキーが取得できていない場合は処理がスキップされます )
//    int pageCount = 1;
//    int tmplCount = 1;
//    int dataCount = 0;
//    int dataOneCount = 0;
//    for (Long keyNo : keyNoList) {
//      Integer startPagebyKeyNo = 0;
//      Integer startTmplbyKeyNo = 0;
//      Map<String, String> resultTmpl = new HashMap<>();
//
//      // このループ1回が、テンプレートの1回分
//      int maxOneAddTmpl = 0; //ページ遷移で増えたテンプレート数の最大値
//      int addOneTmpl = 0; //ページ遷移で増えたテンプレート数
//      for(String cel : tmpOneData.keySet()) {
//        // カウントリセット
//        dataOneCount = 0;
//        addOneTmpl = 0;
//
//        // テンプレート内の繰り返し項目でない項目
//        ReportXmlParam targetParam = tmpOneData.get(cel);
//        ReportXmlGroup group = targetParam.getReportXmlGroup();
//        boolean groupNewPageFlg = false; // グループの改頁設定
//        int groupRepeatMax = 1; // グループの繰り返し回数
//        if (group != null) {
//          groupNewPageFlg = group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_YES ? true : false;
//          groupRepeatMax = group.getRepeatMax();
//        }
//        Long sqlCd = Long.valueOf(targetParam.getSqlCode());
//        List<Map<String, Object>> sqlResultData = reportOutputInfo.get(sqlCd);
//        // フィルタ処理(テンプレート項目内)
//        List<Map<String, Object>> filteredList = reportServiceImpl.filterReportInfo(targetParam, sqlResultData);
//        if (filteredList.isEmpty()) {
//          // フィルタ処理の結果、出力対象がなくなった場合は処理をスキップ
//          continue;
//        }
//
//        for (Map<String, Object> sqlData : filteredList) {
//          // キーの値に一致するデータを応答データに格納
//          if (sqlData.get(tmplKey) != null && !StringUtils.isEmpty(sqlData.get(tmplKey).toString())) {
//            Long dataKeyNo = Long.valueOf(sqlData.get(tmplKey).toString());
//            if (keyNo.equals(dataKeyNo)) {
//              // データカウントアップ
//              dataOneCount = dataOneCount + 1;
//              // 改ページ判定
//              if (dataOneCount > groupRepeatMax) {
//                if (groupNewPageFlg) {
//                  // グループにページ遷移がある場合
//                  addOneTmpl = addOneTmpl + 1;
//                  if (addOneTmpl > maxOneAddTmpl) {
//                    maxOneAddTmpl = addOneTmpl; // 最大値を確保
//                  }
//                  dataOneCount = 1; // データ回数リセット
//
//                  // ページ遷移判定
//                  if (!tmplNewPageFlg) {
//                    // ページ遷移がない場合、テンプレート繰り返し回数の最大値まで達したら処理を抜ける
//                    if (tmplCount + addOneTmpl > tmplRepeatMax) {
//                      break;
//                    }
//                  }
//
//                } else {
//                  // ページ遷移がない場合処理を抜ける
//                  break;
//                }
//              }
//              String keyPage = String.format("%d%s", pageCount + ((tmplCount + addOneTmpl - 1) / tmplRepeatMax), MULTIPLE_PAGES_SEPARATOR);
//              String keyTmpl = String.format("%s-%d", tmplRepeat.getId(), tmplCount + addOneTmpl - (((tmplCount + addOneTmpl - 1) / tmplRepeatMax) * tmplRepeatMax));
//              String key = String.format("%s%s.%s", keyPage, keyTmpl, targetParam.getId());
//              String value = reportServiceImpl.formatValue(targetParam, sqlData.get(targetParam.getDataCode()));
//              value = reportServiceImpl.convertValue(targetParam, value);
//              if (value != null && !"null".equals(value)) {
//                resultTmpl.put(key, reportServiceImpl.addLineBreak(value, targetParam));
//              } else {
//                resultTmpl.put(key, "");
//              }
//              if(startPagebyKeyNo == 0) startPagebyKeyNo = pageCount + ((tmplCount + addOneTmpl - 1) / tmplRepeatMax);
//              if(startTmplbyKeyNo == 0) startTmplbyKeyNo = tmplCount + addOneTmpl - (((tmplCount + addOneTmpl - 1) / tmplRepeatMax) * tmplRepeatMax);
//            }
//          }
//        }
//      } // テンプレート内の繰り返し項目でない項目の処理終端
//
//      int maxAddTmpl = 0; //ページ遷移で増えたテンプレート数の最大値
//      int addTmpl = 0; //ページ遷移で増えたテンプレート数
//      for(String cel : tmpRepData.keySet()) {
//        // テンプレート内の繰り返し項目
//
//        // カウントリセット
//        dataCount = 1;
//        addTmpl = 0;
//        // グループ設定取得
//        ReportXmlParam targetParam = tmpRepData.get(cel);
//        ReportXmlGroup group = targetParam.getReportXmlGroup();
//        boolean groupNewPageFlg = false; // グループの改頁設定
//        int groupRepeatMax = 0; // グループの繰り返し回数
//        if (group != null) {
//          groupNewPageFlg = group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_YES ? true : false;
//          groupRepeatMax = group.getRepeatMax();
//        }
//
//        Long sqlCd = Long.valueOf(targetParam.getSqlCode());
//        List<Map<String, Object>> sqlResultData = reportOutputInfo.get(sqlCd);
//        // フィルタ処理(テンプレート項目内の繰り返し項目)
//        List<Map<String, Object>> filteredList = reportServiceImpl.filterReportInfo(targetParam, sqlResultData);
//        if (filteredList.isEmpty()) {
//          // フィルタした結果、出力対象がなくなった場合は処理をスキップ
//          continue;
//        }
//        dataCount = 0;
//        for (Map<String, Object> sqlData : filteredList) {
//          // キーの値に一致するデータを応答データに格納
//          if (sqlData.get(tmplKey) != null && !StringUtils.isEmpty(sqlData.get(tmplKey).toString())) {
//            Long dataKeyNo = Long.valueOf(sqlData.get(tmplKey).toString());
//            if (keyNo.equals(dataKeyNo)) {
//              dataCount = dataCount + 1;
//              // 改ページ判定
//              if (dataCount > groupRepeatMax) {
//                if (groupNewPageFlg) {
//                  // グループにページ遷移がある場合
//                  addTmpl = addTmpl + 1;
//                  if (addTmpl > maxAddTmpl) {
//                    maxAddTmpl = addTmpl; // 最大値を確保
//                  }
//                  dataCount = 1; // データ回数リセット
//
//                  // ページ遷移判定
//                  if (!tmplNewPageFlg) {
//                    // ページ遷移がない場合、テンプレート繰り返し回数の最大値まで達したら処理を抜ける
//                    if (tmplCount + addTmpl > tmplRepeatMax) {
//                      break;
//                    }
//                  }
//
//                } else {
//                  // ページ遷移がない場合処理を抜ける
//                  break;
//                }
//              }
//              // { key ： value } のデータに出力 ( key →「ページ + "#" + テンプレート範囲 + "-" + テンプレートデータNo + "." + セル + "-" + データNo」)
//              String keyPage = String.format("%d%s", pageCount + ((tmplCount + addTmpl - 1) / tmplRepeatMax), MULTIPLE_PAGES_SEPARATOR);
//              String keyTmpl = String.format("%s-%d", tmplRepeat.getId(), tmplCount + addTmpl - (((tmplCount + addTmpl - 1) / tmplRepeatMax) * tmplRepeatMax));
//              String keyParam = String.format("%s%s", targetParam.getId() + "-", dataCount);
//              String key = String.format("%s%s.%s", keyPage, keyTmpl, keyParam);
//              String value = reportServiceImpl.formatValue(targetParam, sqlData.get(targetParam.getDataCode()));
//              value = reportServiceImpl.convertValue(targetParam, value);
//              if (value != null && !"null".equals(value)) {
//                resultTmpl.put(key, reportServiceImpl.addLineBreak(value, targetParam));
//              } else {
//                resultTmpl.put(key, "");
//              }
//              if(startPagebyKeyNo == 0) startPagebyKeyNo = pageCount + ((tmplCount + addTmpl - 1) / tmplRepeatMax);
//              if(startTmplbyKeyNo == 0) startTmplbyKeyNo = tmplCount + addTmpl - (((tmplCount + addTmpl - 1) / tmplRepeatMax) * tmplRepeatMax);
//            }
//          }
//        }
//      } // テンプレート内の繰り返し項目の終端
//
//      // 現在のテンプレート位置を補正
//      if(tmpRepData.isEmpty()){
//        pageCount = pageCount + ((tmplCount + maxOneAddTmpl - 1) / tmplRepeatMax);
//        tmplCount = tmplCount + maxOneAddTmpl - (((tmplCount + maxOneAddTmpl - 1) / tmplRepeatMax) * tmplRepeatMax);
//      }else{
//        pageCount = pageCount + ((tmplCount + maxAddTmpl - 1) / tmplRepeatMax);
//        tmplCount = tmplCount + maxAddTmpl - (((tmplCount + maxAddTmpl - 1) / tmplRepeatMax) * tmplRepeatMax);
//      }
//      if (tmplNewPageFlg) {
//        // ページ遷移がある場合
//        tmplCount = tmplCount + 1; // テンプレート回数をカウントアップ
//        if (tmplCount > tmplRepeatMax) {
//          pageCount = pageCount + 1; // ページカウントアップ
//          tmplCount = 1; // テンプレート回数リセット
//        }
//      } else {
//        // ページ遷移がない場合
//        tmplCount = tmplCount + 1; // テンプレート回数をカウントアップ
//        if (tmplCount > tmplRepeatMax) {
//          break; // ページ遷移しないので最大値まで達したら処理を抜ける
//        }
//      }
//
//      Integer endPagebyKeyNo = reportServiceImpl.getTmplPageCount(resultTmpl);
//      Integer endTmplbyKeyNo = reportServiceImpl.getTmplCount(resultTmpl, endPagebyKeyNo);
//      result.putAll(resultTmpl);
//      if(tmplNewPageFlg){
//        if(startPagebyKeyNo != 0){
//          if((startPagebyKeyNo != endPagebyKeyNo) || (startTmplbyKeyNo != endTmplbyKeyNo)) {
//            List<ReportXmlParam> paramsInTmpl = params.stream()
//              .filter(p -> !StringUtils.isEmpty(p.getId()) && p.isTmplRepeat())
//              .collect(Collectors.toList())
//              ;
//            for (ReportXmlParam param : paramsInTmpl){
//              ReportXmlGroup group = param.getReportXmlGroup();
//              if ((group != null && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_NO) || (StringUtils.isEmpty(param.getGroupId()) && !"1".equals(param.getIsNewPage()))) {
//                List<String> repeatKey = resultTmpl.keySet().stream()
//                  .filter(r -> r.indexOf(MULTIPLE_PAGES_SEPARATOR) >= 0 && r.indexOf(".") >= 0 && r.indexOf(param.getId()) >= 0)
//                  .collect(toList());
//                for(Integer i = (startTmplbyKeyNo < tmplRepeatMax ? startPagebyKeyNo - 1 : startPagebyKeyNo); i < endPagebyKeyNo; i++){
//                  for(Integer j = 0; j < tmplRepeatMax; j++) {
//                    if(i + 1 == startPagebyKeyNo && j + 1 <= startTmplbyKeyNo) continue;
//                    if(i + 1 == endPagebyKeyNo && j + 1 > endTmplbyKeyNo) continue;
//                    for (String key : repeatKey) {
//                      String pageStr = String.format("%d%s", i + 1, MULTIPLE_PAGES_SEPARATOR);
//                      String keyTmpl = String.format("%s-%d", tmplRepeat.getId(), j + 1);
//                      String keyNew = String.format("%s%s.%s",pageStr, keyTmpl, key.substring(key.indexOf(".") + 1));
//                      result.put(keyNew, resultTmpl.get(key));
//                    }
//                  }
//                }
//              }
//            }
//          }
//        }
//      }
//      startPagebyKeyNo = 0;
//      startTmplbyKeyNo = 0;
//    } // for (Long keyNo : keyNoList) { の終端
    // del #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe end

    // add #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe start
    // mod #10650 検査結果（指定日以前）の仕様課題 2025/02/26 高 start
//    Map<String, List<ReportXmlParam>> groupedParamsInTmpl = params.stream()
//      .filter(p -> !StringUtils.isEmpty(p.getId()) && p.isTmplRepeat())
//      .collect(Collectors.groupingBy(p -> p.getSqlCode()))
//      ;
    Map<String, List<ReportXmlParam>> groupedParamsInTmpl = params.stream()
      .filter(p -> !StringUtils.isEmpty(p.getId()) && p.isTmplRepeat() && !String.valueOf(p.getSqlCode()).matches(".*9999931$")  && !String.valueOf(p.getSqlCode()).matches(".*99999327$"))
      .collect(Collectors.groupingBy(p -> p.getSqlCode()))
      ;
    // mod #10650 検査結果（指定日以前）の仕様課題 2025/02/26 高 end
    Map<Long, Map<Long, Set<Long>>> groupSortKeyNoMap = new HashMap<>();
    Map<Long, String> groupKeyNameMap = new HashMap<>();
    for(String cel : groupedParamsInTmpl.keySet()) {
      Long sqlCode;
      if (null != cel && cel.equals("")) {
        sqlCode = Long.valueOf(0);
      } else {
        sqlCode = Long.valueOf(cel);
      }
      // sqlCodeをもとに出力情報を取得する
      List<Map<String, Object>> tmpList = reportInTmplInfo.get(sqlCode);
      String groupKey = reportServiceImpl.getContainsGroupKey(tmpList);
      groupKeyNameMap.put(sqlCode, groupKey);
      if(groupKey.length() > 0) {
        if(groupKey.equals("pat_info_date_key")){
          for (Long keyNo : keyNoList){
            Map<Long, List<Map<String, Object>>> filterGroupKeyNoList = tmpList.stream()
              // mod #11755 「##=」でstring型を参照すると空値のときにnullと出る start
//              .filter(map -> String.valueOf(keyNo).equals(map.get("pat_info_date_key").toString()))
              .filter(map -> map.get("pat_info_date_key") != null && String.valueOf(keyNo).equals(map.get("pat_info_date_key").toString()))
              // mod #11755 「##=」でstring型を参照すると空値のときにnullと出る end
              .collect(Collectors.groupingBy(map -> (Long)map.get(groupKey), LinkedHashMap::new, Collectors.toCollection(ArrayList::new)));
            Map<Long, Set<Long>> groupedDate = new HashMap<>();
            groupedDate.put(sqlCode, filterGroupKeyNoList.keySet());
            if (groupSortKeyNoMap.containsKey(keyNo)) {
              groupedDate.putAll(groupSortKeyNoMap.get(keyNo));
            }
            groupSortKeyNoMap.put(keyNo, groupedDate);
          }
        } else {
          Map<String, String> groupSortKey = reportServiceImpl.getSortKey(groupKey);
          List<Map<String, Object>> results = reportServiceImpl.getGroupKeyNoList(groupKey, dataKey, null);
          for (Long keyNo : keyNoList){
            Map<Long, List<Map<String, Object>>> filterGroupKeyNoList = results.stream()
              .filter(map -> String.valueOf(keyNo).equals(reportServiceImpl.getGroupKeybyDateType(map.get(groupSortKey.get("tmplSortKey")).toString())))
              .collect(Collectors.groupingBy(map -> (Long)map.get(groupKey), LinkedHashMap::new, Collectors.toCollection(ArrayList::new)));
            Map<Long, Set<Long>> groupedDate = new HashMap<>();
            groupedDate.put(sqlCode, filterGroupKeyNoList.keySet());
            if (groupSortKeyNoMap.containsKey(keyNo)) {
              groupedDate.putAll(groupSortKeyNoMap.get(keyNo));
            }
            groupSortKeyNoMap.put(keyNo, groupedDate);
          }
        }
      }
    }

    // add #12234 テンプレート改頁とグループ繰り返しの組合わせ時の出力結果がおかしい limingzhe start
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
    // add #12234 テンプレート改頁とグループ繰り返しの組合わせ時の出力結果がおかしい limingzhe end
    int pageStart = 0;
    int tmplLoopStart = 0;
    // add #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
    keyNoList = "desc".equals(sortDirection) ? keyNoList.stream()
      .sorted(Comparator.reverseOrder())
      .collect(Collectors.toList()) : keyNoList.stream()
      .sorted()
      .collect(Collectors.toList());
    // add #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
    for (Long keyNo : keyNoList) {
      int tmplMaxCount = 1;
      if(groupSortKeyNoMap != null && groupSortKeyNoMap.size() != 0 && groupSortKeyNoMap.get(keyNo) != null) {
        for (Long sCd : groupSortKeyNoMap.get(keyNo).keySet()){
          // mod #10650 検査結果（指定日以前）の仕様課題 高　start
//          int count = groupSortKeyNoMap.get(keyNo).get(sCd).size();
          int count = String.valueOf(sCd).contains("31") || String.valueOf(sCd).contains("247") ? 1 : groupSortKeyNoMap.get(keyNo).get(sCd).size();
          // mod #10650 検査結果（指定日以前）の仕様課題 高　end
          if(tmplMaxCount < count) tmplMaxCount = count;
        }
      }
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
          if (tmpList!=null && !tmpList.isEmpty()) {
            String keyNamebyNo = groupKeyNameMap.get(sqlCode);
            Long keyNobyNo = 0l;
            if(groupSortKeyNoMap != null && groupSortKeyNoMap.size() != 0 && groupSortKeyNoMap.get(keyNo) != null) {
              if(groupSortKeyNoMap.get(keyNo).containsKey(sqlCode)) {
                List<Long> KeyListbyNo = new ArrayList<>(groupSortKeyNoMap.get(keyNo).get(sqlCode));
                // mod #10446 テンプレート繰返しでの計算式繰返しの制限事項対応②（「=」で始まる計算式） limingzhe start
                //if(keyNamebyNo.equals("pat_info_date_key")) keyNobyNo = KeyListbyNo.get(0);
                if(keyNamebyNo.equals("pat_info_date_key") && KeyListbyNo.size() > 0) keyNobyNo = KeyListbyNo.get(0);
                // mod #10446 テンプレート繰返しでの計算式繰返しの制限事項対応②（「=」で始まる計算式） limingzhe end
                // add #10650 検査結果（指定日以前）の仕様課題 高　start
                else if ((String.valueOf(sqlCode).matches(".*9999931$") || String.valueOf(sqlCode).matches(".*99999247$"))&& KeyListbyNo.size() > 0) {keyNobyNo = KeyListbyNo.get(0);}
                // add #10650 検査結果（指定日以前）の仕様課題 高　end
                else if(tmplIndex < KeyListbyNo.size()) keyNobyNo = KeyListbyNo.get(tmplIndex);
              }
            }
            for (ReportXmlParam param : groupedParamsInTmpl.get(cel)) {
              if (!(!StringUtils.isEmpty(param.getGroupId()) && param.isTmplRepeat())) {
                continue;
              }
              if (sqlCode != 31L) {
                List<Map<String, Object>> filteredList = reportServiceImpl.filterReportInfo(param, tmpList);
                List<Map<String, Object>> filteredListTemp = new ArrayList<>();
                for (Map<String, Object> sqlData : filteredList) {
                  // キーの値に一致するデータを応答データに格納
                  if (sqlData.get(keyNamebyNo) != null && !StringUtils.isEmpty(sqlData.get(keyNamebyNo).toString())) {
                    Long dataKeyNo = Long.valueOf(sqlData.get(keyNamebyNo).toString());
                    if (keyNobyNo.equals(dataKeyNo)) {
                      filteredListTemp.add(sqlData);
                    }
                  }
                }
                filteredList = filteredListTemp;
                if (filteredList.isEmpty()) continue;
                ReportXmlGroup group = param.getReportXmlGroup();
                ReportXmlTmplRepeat tmplRepeat = param.getReportXmlTmplRepeat();
                // add #12234 テンプレート改頁とグループ繰り返しの組合わせ時の出力結果がおかしい limingzhe start
                Integer repeatMax = (group != null && group.getRepeatMax() != null) ? group.getRepeatMax() : 1;
                Integer tmplRepeatMax = (group != null && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_YES) ? tmplRepeat.getRepeatMax() : 1;
                // add #12234 テンプレート改頁とグループ繰り返しの組合わせ時の出力結果がおかしい limingzhe end
                Integer repeatOfPage;
                int tmplLoop = 1;
                if (group != null && group.getRepeatMax() > 1) {
                  // mod #12234 テンプレート改頁とグループ繰り返しの組合わせ時の出力結果がおかしい limingzhe start
//                  repeatOfPage = (filteredList.size() > group.getRepeatMax() * tmplRepeat.getRepeatMax()) ? group.getRepeatMax() * tmplRepeat.getRepeatMax() : filteredList.size();
//                  if((tmplRepeat.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_NO || (group != null && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_NO))) {
//                    repeatOfPage = group.getRepeatMax();
//                  }
                  repeatOfPage = (filteredList.size() > repeatMax * tmplRepeatMax) ? repeatMax * tmplRepeatMax : filteredList.size();
                  // mod #12234 テンプレート改頁とグループ繰り返しの組合わせ時の出力結果がおかしい limingzhe end
                  tmplLoop = filteredList.size() / group.getRepeatMax() + ((filteredList.size() % group.getRepeatMax() > 0) ? 1 : 0);
                }else{
                  // mod #12234 テンプレート改頁とグループ繰り返しの組合わせ時の出力結果がおかしい limingzhe start
//                  repeatOfPage = (tmplRepeat.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_YES) ? tmplRepeat.getRepeatMax() : 1;
                  repeatOfPage = filteredList.size() > tmplRepeatMax ? tmplRepeatMax : filteredList.size();
                  // mod #12234 テンプレート改頁とグループ繰り返しの組合わせ時の出力結果がおかしい limingzhe end
                  tmplLoop = filteredList.size();
                }
                // mod #12234 テンプレート改頁とグループ繰り返しの組合わせ時の出力結果がおかしい limingzhe start
//                if((tmplRepeat.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_NO || (group != null && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_NO))) {
//                  if(filteredList.size() > 0) tmplLoop = 1;
//                }
                if((group != null && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_NO)) {
                  if(filteredList.size() > 0) tmplLoop = 1;
                }
                else {
                  if(tmplRepeat.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_NO){
                    if(filteredList.size() > 0) tmplLoop = (filteredList.size() > tmplRepeat.getRepeatMax()) ? tmplRepeat.getRepeatMax() : filteredList.size();
                    if(tmplLoop > tmplRepeat.getRepeatMax() - tmplLoopStart) tmplLoop = tmplRepeat.getRepeatMax();
                  }
                }
                // mod #12234 テンプレート改頁とグループ繰り返しの組合わせ時の出力結果がおかしい limingzhe end
                if(tmplLoop > tmplLoopMax) tmplLoopMax = tmplLoop;

                int limitCount = repeatOfPage;
                int pageTmplMax = (tmplRepeat.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_NO || (group != null && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_NO)) ? 0 : filteredList.size() / repeatOfPage;
                // del #12234 テンプレート改頁とグループ繰り返しの組合わせ時の出力結果がおかしい limingzhe start
//                pageStart = tmplLoopStart / tmplRepeat.getRepeatMax();
                // del #12234 テンプレート改頁とグループ繰り返しの組合わせ時の出力結果がおかしい limingzhe end
                for (Integer pageCount = 0; pageCount <= pageTmplMax; pageCount++) {
                  int skipCount = pageCount * limitCount;
                  List<Map<String, Object>> outputInfos = filteredList.stream().skip(skipCount).limit(limitCount).collect(toList());
                  int count = 1;
                  // add #12234 テンプレート改頁とグループ繰り返しの組合わせ時の出力結果がおかしい limingzhe start
                  pageStart = tmplLoopStart / tmplRepeat.getRepeatMax();
                  // add #12234 テンプレート改頁とグループ繰り返しの組合わせ時の出力結果がおかしい limingzhe end
                  int tmplLoopCount = 1 + tmplLoopStart % tmplRepeat.getRepeatMax();
                  for (Integer i = 0; i < outputInfos.size(); i++) {
                    String pageStr = String.format("%d%s", pageStart + pageCount + 1, MULTIPLE_PAGES_SEPARATOR);
                    String keyTmpl = String.format("%s-%d", tmplRepeat.getId(), tmplLoopCount);
                    String keyParam = String.format("%s-%s", param.getId(), count++);
                    String key = String.format("%s%s.%s",pageStr, keyTmpl, keyParam);

                    String value = reportServiceImpl.formatValue(param, outputInfos.get(i).get(param.getDataCode()));
                    value = reportServiceImpl.convertValue(param, value);
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
                      // add #12234 テンプレート改頁とグループ繰り返しの組合わせ時の出力結果がおかしい limingzhe start
                      if(tmplRepeat.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_NO){
                        if(tmplLoopCount > tmplLoopMax) break;
                      }
                      // add #12234 テンプレート改頁とグループ繰り返しの組合わせ時の出力結果がおかしい limingzhe end
                      if(tmplLoopCount > tmplRepeat.getRepeatMax()) {
                        if(tmplLoopStart % tmplRepeat.getRepeatMax() > 0) pageStart += 1;
                        tmplLoopCount = 1;
                      }
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
              List<Map<String, Object>> filteredListTemp = new ArrayList<>();
              for (Map<String, Object> sqlData : tmpList) {
                // キーの値に一致するデータを応答データに格納
                if (sqlData.get(keyNamebyNo) != null && !StringUtils.isEmpty(sqlData.get(keyNamebyNo).toString())) {
                  Long dataKeyNo = Long.valueOf(sqlData.get(keyNamebyNo).toString());
                  if (keyNobyNo.equals(dataKeyNo)) {
                    filteredListTemp.add(sqlData);
                  }
                }
              }
              tmpList = filteredListTemp;
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
        // add #12234 テンプレート改頁とグループ繰り返しの組合わせ時の出力結果がおかしい limingzhe start
        if(resultTmpl.size() > 0)
        // add #12234 テンプレート改頁とグループ繰り返しの組合わせ時の出力結果がおかしい limingzhe end
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
              // del #12497 テンプレート繰返しがグループ改頁設定の影響を受けるのは不適切　高　start
//              if(tmplRepeat.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_YES){
              // del #12497 テンプレート繰返しがグループ改頁設定の影響を受けるのは不適切　高　end
                ReportXmlGroup group = param.getReportXmlGroup();
                if ((group != null && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_NO) || (StringUtils.isEmpty(param.getGroupId()) && !"1".equals(param.getIsNewPage()))) {
                  List<String> repeatKey = resultTmpl.keySet().stream()
                    // mod #12234 テンプレート改頁とグループ繰り返しの組合わせ時の出力結果がおかしい limingzhe start
                    //.filter(r -> r.indexOf(MULTIPLE_PAGES_SEPARATOR) >= 0 && r.indexOf(".") >= 0 && r.indexOf(param.getId()) >= 0)
                    .filter(r -> r.indexOf(MULTIPLE_PAGES_SEPARATOR) >= 0 && r.indexOf(".") >= 0 && r.substring(r.indexOf("-")+1).indexOf(param.getId()) >= 0)
                    // mod #12234 テンプレート改頁とグループ繰り返しの組合わせ時の出力結果がおかしい limingzhe end
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
              // del #12497 テンプレート繰返しがグループ改頁設定の影響を受けるのは不適切　高　start
//              }
              // del #12497 テンプレート繰返しがグループ改頁設定の影響を受けるのは不適切　高　end
            }
          }
        }
        startPagebyKeyNo = 0;
        startTmplbyKeyNo = 0;

        // add #12234 テンプレート改頁とグループ繰り返しの組合わせ時の出力結果がおかしい limingzhe start
        if(bHaveGroupIsNewPage){
          // mod #10650 検査結果（指定日以前）の仕様課題 2025/02/26 高 start
//          if(tmplRepeatSet.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_NO) {
          if(!StringUtils.isEmpty(tmplRepeatSet) && tmplRepeatSet.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_NO) {
            // mod #10650 検査結果（指定日以前）の仕様課題 2025/02/26 高 end
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
        // add #12234 テンプレート改頁とグループ繰り返しの組合わせ時の出力結果がおかしい limingzhe end
      }
      // add #12234 テンプレート改頁とグループ繰り返しの組合わせ時の出力結果がおかしい limingzhe start
      if(tmplEndFlag) break;
      // add #12234 テンプレート改頁とグループ繰り返しの組合わせ時の出力結果がおかしい limingzhe end
    }
    // add #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe end

    // mod #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
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
//          result.put(String.format("%d%s%s",i,MULTIPLE_PAGES_SEPARATOR,reportXmlParam.getId()),String.valueOf(i));
//        }
//      } else if (ReportConstant.ReportDataKey.totalPages.equals(reportXmlParam.getDataCode())) {
//        if(totalPages > 0) result.remove(reportXmlParam.getId());
//        for (int i = 1; i <= totalPages ; i++) {
//          result.put(String.format("%d%s%s",i,MULTIPLE_PAGES_SEPARATOR,reportXmlParam.getId()),String.valueOf(totalPages));
//        }
//      }
//    }
    ReportCommonUtil.pageAndPageCount(result, params, dataKey);
    // mod #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
    return result;
  }

}
// add #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
