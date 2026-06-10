package jp.co.nikkiso.ntss.api.service.report;
// mod #10857 帳票内に同項目が複数あると設定値を取り違える limingzhe start

import com.aspose.cells.SaveFormat;
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
import jp.co.nikkiso.ntss.api.service.utils.TmpFileService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstReportDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.OrdPrescriptionDao;
import jp.co.nikkiso.ntss.core.dao.PatEventDao;
import jp.co.nikkiso.ntss.core.dto.FacilitySettingNo.FacilitySettingNoDisplayOrder;
import jp.co.nikkiso.ntss.core.entity.MstReport;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainTreatDate;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.utils.NtssUtils;
import lombok.extern.slf4j.Slf4j;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;
import org.jsoup.Jsoup;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.text.ParseException;
import java.text.ParsePosition;
import java.text.SimpleDateFormat;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Base64;
import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.OptionalDouble;
import java.util.Optional;
import java.util.Set;
import java.util.TreeMap;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.atomic.AtomicReference;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import static java.util.stream.Collectors.toList;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * 帳票の紹介状出力Service実装クラス.
 */
@Service
@Slf4j
public class ReportForIntroductionReportServiceImpl implements ReportForIntroductionReportService {

  /**
   * 帳票出力情報のKey項目に使用する複数ページ区切り文字列.
   */
  private static final String MULTIPLE_PAGES_SEPARATOR = "#";

  // add #11103 カテゴリ「印刷情報」の項目追加と修正 sunsy start
  private static final String DOLLAR_SEPARATOR = "$";
  // add #11103 カテゴリ「印刷情報」の項目追加と修正 sunsy end

  private static final String TMP_SKIP_COUNT = "tmpSkipCount";

  private static final String PAT_ID_TO_C = "patIdToC";

  private static final Long PRINT_INFO_CODE = 0L;

  /**getReportHtml
   * エラー時に帳票デザインHTMLへ出力する文字列.
   */
  private static final String DISPLAY_HTML_ERROR = "ｴﾗｰ";

  /**
   * 計算式に基づく計算が失敗した場合に設定する文字列.
   */
  private static final String FAILED_CALC = "failed calc";

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

  /**
   * SysDataSetから帳票出力情報を取得するServiceインタフェース.
   */
  @Autowired
  private SysDataSetService sysDataSetService;

  @Autowired
  private TmpFileService tmpFileService;

  /**
   * 印刷ファイル作成の為の一時保存Path.
   */
  @Value("${ntss.report.createTmpDir}")
  private String createTmpDir;

  @Autowired
  private PatEventDao patEventDao;

  @Autowired
  private OrdMainDao ordMainDao;

  @Autowired
  private LogService logService;

  // add #11260 テンプレート設定した帳票の出力で高負荷になることがある 房 start
  @Autowired
  private ReportWithAsposeApiService reportWithAsposeApiService;
  // add #11260 テンプレート設定した帳票の出力で高負荷になることがある 房 end

  // add #10988 データ項目「処方.処方箋情報.QRコード」を追加　V1.1A 吉 start
  @Autowired
  private ReportCommonUtil reportCommonUtil;
  // add #10988 データ項目「処方.処方箋情報.QRコード」を追加　V1.1A 吉 end
  // add #12402 紹介状の編集で画像の追加や差し替えができない zhao start
  /**
   * イメージ
   */
  @Value("${ntss.pat-event.s3-bucket:#{null}}")
  private String s3BucketForImage;
  // add #12402 紹介状の編集で画像の追加や差し替えができない zhao end
  // add #11276 キー日付に対するデータ引き当て仕様対応 高　start
  @Autowired
  private OrdMainDao rdMainDao;

  @Autowired
  private OrdPrescriptionDao ordPrescriptionDao;
  // add #11276 キー日付に対するデータ引き当て仕様対応 高　end

  @Override
  public byte[] getReportExcelFileForIntroductionReport(Long reportCd, Map<String, Object> dataKey) {
    // mod #12650 登録済み紹介状が帳票マスタ削除の影響を受けるのは不適切 zhao start
    //MstReport mstReport = mstReportDao.selectByCd(reportCd);
    MstReport mstReport = mstReportDao.selectByReportCd(reportCd);
    // mod #12650 登録済み紹介状が帳票マスタ削除の影響を受けるのは不適切 zhao end
    // add 11488 紹介状登録内容保存時に帳票の版も記憶する　1.1A  吉 start
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
    // add 11488 紹介状登録内容保存時に帳票の版も記憶する　1.1A  吉 end
    // S3から帳票定義XML、帳票デザインExcelが格納されたZipファイルを取得する
    ReportZipFile reportZipFile = getReportZip(mstReport);

    Long ordNo = null;
    if(null != dataKey.get("ordNo")){
      ordNo = Long.valueOf(dataKey.get("ordNo").toString());
    }
    List<Long> or = new ArrayList<>();
    if (dataKey.get("ordNos") == null) {
      if(dataKey.get("ordNo") != null) {
        or.add(Long.valueOf(dataKey.get("ordNo").toString()));
      }
    } else {
      or = (List<Long>) dataKey.get("ordNos");
    }
    List<Long> patId = new ArrayList<>();
    if (dataKey.get("patIds") == null) {
      if(dataKey.get("patId") != null) {
        patId.add(Long.valueOf(dataKey.get("patId").toString()));
      }
    } else {
      patId = (List<Long>) dataKey.get("patIds");
    }

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
    Map<Long, List<Map<String, Object>>> reportInfo = new HashMap<>();
    List<Map<Long, List<Map<String, Object>>>> reportInfosList = new ArrayList<>();
    // add #11226 患者情報系historyの取得条件見直し② limingzhe start
    Map<Long, List<Map<String, Object>>> reportInTmplInfo = new HashMap<>();
    List<Long> keyfilteredList = new ArrayList<>();
    // add #11226 患者情報系historyの取得条件見直し② limingzhe end
    List<String> sqlCodes = getSqlCode(params);
    Map<String, Long> patIdToCMap = new HashMap<>();
    // add #11381 【たくしん会】指示.VA情報.画像が日付によって2件目以降表示されないことがある　V1.0B limingzhe start
    String specifyFromDate = "";
    String specifyToDate = "";
    // add #11381 【たくしん会】指示.VA情報.画像が日付によって2件目以降表示されないことがある　V1.0B limingzhe end
    // mod #11226 患者情報系historyの取得条件見直し② limingzhe start
    //if (mstReport.getReportType() == 1 && params.get(0).getReportXmlTotalTable() != null) {
    if (mstReport.getReportType() == 1 && params.get(0).getReportXmlTotalTable() != null
      && params.get(0).getReportXmlTotalTable().getUnitDate() != null && !params.get(0).getReportXmlTotalTable().getUnitDate().equals("")) {
    // mod #11226 患者情報系historyの取得条件見直し② limingzhe end
      if ("曜日".equals(params.get(0).getReportXmlTotalTable().getUnitDate())){
        List<Long> patIds = new ArrayList<>();
        try {
          patIds = patId.stream()
            .distinct().collect(Collectors.toList());
        } catch (Exception e) {
        }
        List<OrdMainTreatDate> ordMainTreatDates;
        List<Long> ordNoList;
        String fromDate = "";
        String toDate = "";
        if(null!=dataKey.get("fromDate")) {
          fromDate = String.valueOf(dataKey.get("fromDate")).replace("-", "");
        }
        dataKey.put("fromDate",fromDate);
        if(null!=dataKey.get("toDate")) {
          toDate = String.valueOf(dataKey.get("toDate")).replace("-", "");
        }
        dataKey.put("toDate",toDate);
        // add #11136 紹介状の集計範囲修正 高　start
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
        LocalDate date = LocalDate.parse(dataKey.get("fromDate").toString().replace("/","").replace("-",""), formatter);
        LocalDate monday = date.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
        LocalDate sunday = date.with(TemporalAdjusters.nextOrSame(DayOfWeek.SUNDAY));
        DateTimeFormatter outputFormatter = DateTimeFormatter.ofPattern("yyyyMMdd");
        String mondayStr = monday.format(outputFormatter);
        String sundayStr = sunday.format(outputFormatter);
        // add #11136 紹介状の集計範囲修正 高　end

        // add #11249 患者情報系historyの取得条件見直し（集計有り紹介状）高 start
        List<ReportXmlParam> paramsSelectbyMongDB = new ArrayList<>();
        List<String> sqlCodesSelectbyMongDB = new ArrayList<>();
        List<ReportXmlParam> paramsOther = new ArrayList<>();

        List<String> sqlCodesOther = new ArrayList<>();
        for(String sqlCode: sqlCodes){
          if(sysDataSetService.isMongDBSqlSearch(Long.parseLong(sqlCode)))
            sqlCodesSelectbyMongDB.add(sqlCode);
          else
            sqlCodesOther.add(sqlCode);
        }

        // add #11951 紹介状画面でカテゴリ「処方(最新)」が出力されなくなっている 高 start
        Map<String, List<String>> sqlCodesGroup = new HashMap<>();
        sqlCodesGroup.put("ordPrescriptionNo", new ArrayList<String>());
        sqlCodesGroup.put("Other", new ArrayList<String>());
        for(String sqlCode: sqlCodesOther){
          if(sysDataSetService.distinParaOnlybyParam(Long.parseLong(sqlCode), "ordPrescriptionNo"))
            sqlCodesGroup.get("ordPrescriptionNo").add(sqlCode);
          else
            sqlCodesGroup.get("Other").add(sqlCode);
        }

        Map<String, List<ReportXmlParam>> paramsInTmplGroup = new HashMap<>();
        paramsInTmplGroup.put("ordPrescriptionNo", new ArrayList<ReportXmlParam>());
        paramsInTmplGroup.put("Other", new ArrayList<ReportXmlParam>());
        // テンプレート外 テンプレート無し データ項目
        Map<String, List<ReportXmlParam>> paramsGroup = new HashMap<>();
        paramsGroup.put("ordPrescriptionNo", new ArrayList<ReportXmlParam>());
        paramsGroup.put("Other", new ArrayList<ReportXmlParam>());
        for (ReportXmlParam reParam: params){
          ReportXmlTmplRepeat tmplRepeat = reParam.getReportXmlTmplRepeat();
          if(sqlCodesGroup.get("ordPrescriptionNo").contains(reParam.getSqlCode())) {
            if(tmplRepeat != null && !tmplRepeat.getId().equals("")){
              if(reParam.isTmplRepeat()){
                paramsInTmplGroup.get("ordPrescriptionNo").add(reParam);
                continue;
              }
            }
            paramsGroup.get("ordPrescriptionNo").add(reParam);
          }
          else {
            if(tmplRepeat != null && !tmplRepeat.getId().equals("")){
              if(reParam.isTmplRepeat()){
                paramsInTmplGroup.get("Other").add(reParam);
                continue;
              }
            }
            paramsGroup.get("Other").add(reParam);
          }
        }
        // add #11951 紹介状画面でカテゴリ「処方(最新)」が出力されなくなっている 高 end

        for(int i=0;i<patIds.size();i++){
          Map<Long, List<Map<String, Object>>> reportInfos= new HashMap<>();
          ordMainTreatDates = ordMainDao.selectByPatIdAndTreatDate(dataKey.get("facilityCd").toString(),patIds.get(i),fromDate,toDate);
          ordNoList = getOrdNoList(ordMainTreatDates);
          dataKey.put("patId",patIds.get(i));
          dataKey.put("ordNos",ordNoList);
          params = ReportUtils.getParamElements(reportXml);
          for (ReportXmlParam reParam: params){
            if(sqlCodesSelectbyMongDB.contains(reParam.getSqlCode())) {
              paramsSelectbyMongDB.add(reParam);
            }
            else {
              paramsOther.add(reParam);
            }
          }
          // mod #11951 紹介状画面でカテゴリ「処方(最新)」が出力されなくなっている 高 start
//          Map<Long, List<Map<String, Object>>> reportInfoIndex = getReportInfo(paramsOther, dataKey);
//          for (Long key : reportInfoIndex.keySet()) {
//            reportInfos.put(key, reportInfoIndex.get(key));
//          }
          List<Long> ordPrescriptionNos = new ArrayList<>();
          if (dataKey.get("ordPrescriptionNos") == null) {
            if(dataKey.get("ordPrescriptionNo") != null) {
              ordPrescriptionNos.add(Long.valueOf(dataKey.get("ordPrescriptionNo").toString()));
            }
          } else {
            ordPrescriptionNos = (List<Long>) dataKey.get("ordPrescriptionNos");
          }
          Map<Long, List<Map<String, Object>>> reportInfoIndex = new HashMap<>();
          if(paramsGroup.get("ordPrescriptionNo").size() != 0 && ordPrescriptionNos.size()>0) {
            for (Long ordPrescriptionNo : ordPrescriptionNos) {
              dataKey.put("ordPrescriptionNo", ordPrescriptionNo);
              reportInfoIndex = getReportInfo(paramsGroup.get("ordPrescriptionNo"), dataKey);
              for (Long key : reportInfoIndex.keySet()) {
                if (reportInfos.containsKey(key)) {
                  reportInfos.get(key).addAll(reportInfoIndex.get(key));
                } else {
                  reportInfos.put(key, reportInfoIndex.get(key));
                }
              }
            }
          }
          if (paramsGroup.get("Other").size() != 0) {
            reportInfoIndex = getReportInfo(paramsGroup.get("Other"), dataKey);
            for (Long key : reportInfoIndex.keySet()) {
              reportInfos.put(key, reportInfoIndex.get(key));
            }
          }
          // mod #11951 紹介状画面でカテゴリ「処方(最新)」が出力されなくなっている 高 end

          if (!StringUtils.isEmpty(dataKey.get("specifyDate"))) {
            String reportXmlTmplRepeatId = paramsOther.get(0).getReportXmlTmplRepeat().getId();
            String unitVAddress = paramsOther.get(0).getReportXmlTotalTable().getUnitVAddress();
            String unitHAddress = paramsOther.get(0).getReportXmlTotalTable().getUnitHAddress();
            List<ReportXmlParam> paramsList = new ArrayList<>();
            for (int index = 0; index < paramsOther.size();index++){
              if (paramsOther.get(index).getId().equals(reportXmlTmplRepeatId) ||
                paramsOther.get(index).getId().equals(unitVAddress) ||
                paramsOther.get(index).getId().equals(unitHAddress)) {
                paramsList.add(paramsOther.get(index));
              }
            }

            ordMainTreatDates = ordMainDao.selectByPatIdAndTreatDate(dataKey.get("facilityCd").toString(),patIds.get(i),mondayStr,sundayStr);
            ordNoList = getOrdNoList(ordMainTreatDates);
            dataKey.put("ordNos",ordNoList);
            Map<Long, List<Map<String, Object>>> reportInfoIndexNew = getReportInfo(paramsList, dataKey);
            for (Long key : reportInfoIndexNew.keySet()) {
              reportInfos.put(key, reportInfoIndexNew.get(key));
            }
          }
          if (StringUtils.isEmpty(dataKey.get("specifyDate"))) {
            Map<String, Object> dataKeyNew = new HashMap<>();
            try {
              dataKeyNew = deepCopyMap(dataKey);
            } catch (IOException e) {
              throw new RuntimeException(e);
            } catch (ClassNotFoundException e) {
              throw new RuntimeException(e);
            }
            dataKeyNew.put("toDate",dataKey.get("fromDate"));
            Map<Long, List<Map<String, Object>>> reportInfoIndexNewHistory = getReportInfo(paramsSelectbyMongDB, dataKeyNew);
            for (Long key : reportInfoIndexNewHistory.keySet()) {
              reportInfos.put(key, reportInfoIndexNewHistory.get(key));
            }
          } else {
            Map<Long, List<Map<String, Object>>> reportInfoIndexNewHistory = getReportInfo(paramsSelectbyMongDB, dataKey);
            for (Long key : reportInfoIndexNewHistory.keySet()) {
              reportInfos.put(key, reportInfoIndexNewHistory.get(key));
            }
          }
          // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
          //List<Map<String, Object>> rec = getPrintedInfo(params, dataKey, reportInfos);
          List<Map<String, Object>> rec = reportServiceImpl.getPrintedInfo(params, dataKey, reportInfos);
          // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
          reportInfos.put(PRINT_INFO_CODE, rec);
          params = reportServiceImpl.paramsReplaceTmpValue(params, reportInfos);
          // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
          //reportInfos = getChangeList(reportInfos, params);
          reportInfos = reportServiceImpl.getChangeList(reportInfos, params);
          // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
          // add #11127 グループ除外処理の残対応（モニタ、身体情報）2025/07/17　高　start
          reportServiceImpl.reportFilterOutUnusedData(params,reportInfos);
          // add #11127 グループ除外処理の残対応（モニタ、身体情報）2025/07/17　高　end
          // add #10224 集計紹介状、集計表の出力順について再精査 高 start
          sortMedicationsAndEquipmentsByFacilitySetting(reportInfos,mstReport);
          // add #10224 集計紹介状、集計表の出力順について再精査 高 end
          reportInfosList.add(reportInfos);
        }
        // add #11249 患者情報系historyの取得条件見直し（集計有り紹介状）高 end

        // del #11249 患者情報系historyの取得条件見直し（集計有り紹介状）高 start
//        for(int i=0;i<patIds.size();i++){
//          Map<Long, List<Map<String, Object>>> reportInfos= new HashMap<>();
//          ordMainTreatDates = ordMainDao.selectByPatIdAndTreatDate(dataKey.get("facilityCd").toString(),patIds.get(i),fromDate,toDate);
//          ordNoList = getOrdNoList(ordMainTreatDates);
//          dataKey.put("patId",patIds.get(i));
//          dataKey.put("ordNos",ordNoList);
//          params = ReportUtils.getParamElements(reportXml);
//          Map<Long, List<Map<String, Object>>> reportInfoIndex = getReportInfo(params, dataKey);
//          for (Long key : reportInfoIndex.keySet()) {
//            reportInfos.put(key, reportInfoIndex.get(key));
//          }
//
//          // add #11136 紹介状の集計範囲修正 高　start
//          if (!StringUtils.isEmpty(dataKey.get("specifyDate"))) {
//            String reportXmlTmplRepeatId = params.get(0).getReportXmlTmplRepeat().getId();
//            String unitVAddress = params.get(0).getReportXmlTotalTable().getUnitVAddress();
//            String unitHAddress = params.get(0).getReportXmlTotalTable().getUnitHAddress();
//            List<ReportXmlParam> paramsList = new ArrayList<>();
//            for (int index = 0; index < params.size();index++){
//              if (params.get(index).getId().equals(reportXmlTmplRepeatId) ||
//                params.get(index).getId().equals(unitVAddress) ||
//                params.get(index).getId().equals(unitHAddress)) {
//                paramsList.add(params.get(index));
//              }
//            }
//
//            ordMainTreatDates = ordMainDao.selectByPatIdAndTreatDate(dataKey.get("facilityCd").toString(),patIds.get(i),mondayStr,sundayStr);
//            ordNoList = getOrdNoList(ordMainTreatDates);
//            dataKey.put("ordNos",ordNoList);
//            Map<Long, List<Map<String, Object>>> reportInfoIndexNew = getReportInfo(paramsList, dataKey);
//            for (Long key : reportInfoIndexNew.keySet()) {
//              reportInfos.put(key, reportInfoIndexNew.get(key));
//            }
//          }
//          // add #11136 紹介状の集計範囲修正 高　end
//
//          List<Map<String, Object>> rec = getPrintedInfo(params, dataKey, reportInfos);
//          reportInfos.put(PRINT_INFO_CODE, rec);
//          params = reportServiceImpl.paramsReplaceTmpValue(params, reportInfos);
//          reportInfos = getChangeList(reportInfos, params);
//          reportInfosList.add(reportInfos);
//        }
        // del #11249 患者情報系historyの取得条件見直し（集計有り紹介状）高 end
        // add #11136 紹介状の集計範囲修正 高　start
        if (!StringUtils.isEmpty(dataKey.get("specifyDate"))) {
          // mod #11381 【たくしん会】指示.VA情報.画像が日付によって2件目以降表示されないことがある　V1.0B limingzhe start
//          dataKey.put("fromDate",mondayStr);
//          dataKey.put("toDate",sundayStr);
          specifyFromDate = mondayStr;
          specifyToDate = sundayStr;
          // mod #11381 【たくしん会】指示.VA情報.画像が日付によって2件目以降表示されないことがある　V1.0B limingzhe end
        }
        // add #11136 紹介状の集計範囲修正 高　end
      } else if ("日".equals(params.get(0).getReportXmlTotalTable().getUnitDate())) {
        List<Long> patIds = new ArrayList<>();
        try {
          patIds = patId.stream()
            .distinct().collect(Collectors.toList());
        } catch (Exception e) {
        }
        List<OrdMainTreatDate> ordMainTreatDates;
        List<Long> ordNoList;
        String fromDate = "";
        String toDate = "";
        if(null!=dataKey.get("fromDate")) {
          fromDate = String.valueOf(dataKey.get("fromDate")).replace("-", "");
        }
        dataKey.put("fromDate",fromDate);
        if(null!=dataKey.get("toDate")) {
          toDate = String.valueOf(dataKey.get("toDate")).replace("-", "");
        }
        dataKey.put("toDate",toDate);
        // add #11136 紹介状の集計範囲修正 高　start
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
        LocalDate date = LocalDate.parse(dataKey.get("fromDate").toString().replace("/","").replace("-",""), formatter);
        LocalDate monday = date.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
        LocalDate sunday = date.with(TemporalAdjusters.nextOrSame(DayOfWeek.SUNDAY));
        DateTimeFormatter outputFormatter = DateTimeFormatter.ofPattern("yyyyMMdd");
        String mondayStr = monday.format(outputFormatter);
        String sundayStr = sunday.format(outputFormatter);
        // add #11136 紹介状の集計範囲修正 高　end

        // add #11249 患者情報系historyの取得条件見直し（集計有り紹介状）高 start
        List<ReportXmlParam> paramsSelectbyMongDB = new ArrayList<>();
        List<String> sqlCodesSelectbyMongDB = new ArrayList<>();
        List<ReportXmlParam> paramsOther = new ArrayList<>();

        List<String> sqlCodesOther = new ArrayList<>();
        for(String sqlCode: sqlCodes){
          if(sysDataSetService.isMongDBSqlSearch(Long.parseLong(sqlCode)))
            sqlCodesSelectbyMongDB.add(sqlCode);
          else
            sqlCodesOther.add(sqlCode);
        }

        // add #11951 紹介状画面でカテゴリ「処方(最新)」が出力されなくなっている 高 start
        Map<String, List<String>> sqlCodesGroup = new HashMap<>();
        sqlCodesGroup.put("ordPrescriptionNo", new ArrayList<String>());
        sqlCodesGroup.put("Other", new ArrayList<String>());
        for(String sqlCode: sqlCodesOther){
          if(sysDataSetService.distinParaOnlybyParam(Long.parseLong(sqlCode), "ordPrescriptionNo"))
            sqlCodesGroup.get("ordPrescriptionNo").add(sqlCode);
          else
            sqlCodesGroup.get("Other").add(sqlCode);
        }

        Map<String, List<ReportXmlParam>> paramsInTmplGroup = new HashMap<>();
        paramsInTmplGroup.put("ordPrescriptionNo", new ArrayList<ReportXmlParam>());
        paramsInTmplGroup.put("Other", new ArrayList<ReportXmlParam>());
        // テンプレート外 テンプレート無し データ項目
        Map<String, List<ReportXmlParam>> paramsGroup = new HashMap<>();
        paramsGroup.put("ordPrescriptionNo", new ArrayList<ReportXmlParam>());
        paramsGroup.put("Other", new ArrayList<ReportXmlParam>());
        for (ReportXmlParam reParam: params){
          ReportXmlTmplRepeat tmplRepeat = reParam.getReportXmlTmplRepeat();
          if(sqlCodesGroup.get("ordPrescriptionNo").contains(reParam.getSqlCode())) {
            if(tmplRepeat != null && !tmplRepeat.getId().equals("")){
              if(reParam.isTmplRepeat()){
                paramsInTmplGroup.get("ordPrescriptionNo").add(reParam);
                continue;
              }
            }
            paramsGroup.get("ordPrescriptionNo").add(reParam);
          }
          else {
            if(tmplRepeat != null && !tmplRepeat.getId().equals("")){
              if(reParam.isTmplRepeat()){
                paramsInTmplGroup.get("Other").add(reParam);
                continue;
              }
            }
            paramsGroup.get("Other").add(reParam);
          }
        }
        // add #11951 紹介状画面でカテゴリ「処方(最新)」が出力されなくなっている 高 end

        for (int i = 0; i < patIds.size(); i++) {
          ordMainTreatDates = ordMainDao.selectByPatIdAndTreatDate(dataKey.get("facilityCd").toString(),patIds.get(i),fromDate,toDate);
          ordNoList = getOrdNoList(ordMainTreatDates);
          dataKey.put("patId",patIds.get(i));
          dataKey.put("ordNos",ordNoList);
          params = ReportUtils.getParamElements(reportXml);
          for (ReportXmlParam reParam: params){
            if(sqlCodesSelectbyMongDB.contains(reParam.getSqlCode())) {
              paramsSelectbyMongDB.add(reParam);
            }
            else {
              paramsOther.add(reParam);
            }
          }
          // mod #11951 紹介状画面でカテゴリ「処方(最新)」が出力されなくなっている 高 start
//          Map<Long, List<Map<String, Object>>> reportInfoIndex = getReportInfo(paramsOther, dataKey);
//          for (Long key : reportInfoIndex.keySet()) {
//            reportInfo.put(key, reportInfoIndex.get(key));
//          }
          List<Long> ordPrescriptionNos = new ArrayList<>();
          if (dataKey.get("ordPrescriptionNos") == null) {
            if(dataKey.get("ordPrescriptionNo") != null) {
              ordPrescriptionNos.add(Long.valueOf(dataKey.get("ordPrescriptionNo").toString()));
            }
          } else {
            ordPrescriptionNos = (List<Long>) dataKey.get("ordPrescriptionNos");
          }
          Map<Long, List<Map<String, Object>>> reportInfoIndex = new HashMap<>();
          if(paramsGroup.get("ordPrescriptionNo").size() != 0 && ordPrescriptionNos.size()>0) {
            for (Long ordPrescriptionNo : ordPrescriptionNos) {
              dataKey.put("ordPrescriptionNo", ordPrescriptionNo);
              reportInfoIndex = getReportInfo(paramsGroup.get("ordPrescriptionNo"), dataKey);
              for (Long key : reportInfoIndex.keySet()) {
                if (reportInfo.containsKey(key)) {
                  reportInfo.get(key).addAll(reportInfoIndex.get(key));
                } else {
                  reportInfo.put(key, reportInfoIndex.get(key));
                }
              }
            }
          }

          if (paramsGroup.get("Other").size() != 0) {
            reportInfoIndex = getReportInfo(paramsGroup.get("Other"), dataKey);
            for (Long key : reportInfoIndex.keySet()) {
              reportInfo.put(key, reportInfoIndex.get(key));
            }
          }
          // mod #11951 紹介状画面でカテゴリ「処方(最新)」が出力されなくなっている 高 end
          if (!StringUtils.isEmpty(dataKey.get("specifyDate"))) {
            String reportXmlTmplRepeatId = paramsOther.get(0).getReportXmlTmplRepeat().getId();
            String unitVAddress = paramsOther.get(0).getReportXmlTotalTable().getUnitVAddress();
            String unitHAddress = paramsOther.get(0).getReportXmlTotalTable().getUnitHAddress();
            List<ReportXmlParam> paramsList = new ArrayList<>();
            for (int index = 0; index < paramsOther.size();index++){
              if (paramsOther.get(index).getId().equals(reportXmlTmplRepeatId) ||
                paramsOther.get(index).getId().equals(unitVAddress) ||
                paramsOther.get(index).getId().equals(unitHAddress)) {
                paramsList.add(paramsOther.get(index));
              }
            }

            ordMainTreatDates = ordMainDao.selectByPatIdAndTreatDate(dataKey.get("facilityCd").toString(),patIds.get(i),mondayStr,sundayStr);
            ordNoList = getOrdNoList(ordMainTreatDates);
            dataKey.put("ordNos",ordNoList);
            Map<Long, List<Map<String, Object>>> reportInfoIndexNew = getReportInfo(paramsList, dataKey);
            for (Long key : reportInfoIndexNew.keySet()) {
              reportInfo.put(key, reportInfoIndexNew.get(key));
            }
          }
          if (StringUtils.isEmpty(dataKey.get("specifyDate"))) {
            Map<String, Object> dataKeyNew = new HashMap<>();
            try {
              dataKeyNew = deepCopyMap(dataKey);
            } catch (IOException e) {
              throw new RuntimeException(e);
            } catch (ClassNotFoundException e) {
              throw new RuntimeException(e);
            }
            dataKeyNew.put("toDate",dataKey.get("fromDate"));
            Map<Long, List<Map<String, Object>>> reportInfoIndexNewHistory = getReportInfo(paramsSelectbyMongDB, dataKeyNew);
            for (Long key : reportInfoIndexNewHistory.keySet()) {
              reportInfo.put(key, reportInfoIndexNewHistory.get(key));
            }
          } else {
            Map<Long, List<Map<String, Object>>> reportInfoIndexNewHistory = getReportInfo(paramsSelectbyMongDB, dataKey);
            for (Long key : reportInfoIndexNewHistory.keySet()) {
              reportInfo.put(key, reportInfoIndexNewHistory.get(key));
            }
          }
          // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
          //List<Map<String, Object>> rec = getPrintedInfo(params, dataKey, reportInfo);
          List<Map<String, Object>> rec = reportServiceImpl.getPrintedInfo(params, dataKey, reportInfo);
          // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
          reportInfo.put(PRINT_INFO_CODE, rec);
          params = reportServiceImpl.paramsReplaceTmpValue(params, reportInfo);
          // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
          //reportInfo = getChangeList(reportInfo, params);
          reportInfo = reportServiceImpl.getChangeList(reportInfo, params);
          // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
          // add #11127 グループ除外処理の残対応（モニタ、身体情報）2025/07/17　高　start
          reportServiceImpl.reportFilterOutUnusedData(params,reportInfo);
          // add #11127 グループ除外処理の残対応（モニタ、身体情報）2025/07/17　高　end
          // add #10224 集計紹介状、集計表の出力順について再精査 高 start
          sortMedicationsAndEquipmentsByFacilitySetting(reportInfo,mstReport);
          // add #10224 集計紹介状、集計表の出力順について再精査 高 end
          // add #11733 紹介状の集計内訳で縦の単位を複数列にすると正しく繰り返しされない limingzhe start
          reportInfosList.add(reportInfo);
          // add #11733 紹介状の集計内訳で縦の単位を複数列にすると正しく繰り返しされない limingzhe end
        }
        // add #11249 患者情報系historyの取得条件見直し（集計有り紹介状）高 end

        // del #11249 患者情報系historyの取得条件見直し（集計有り紹介状）高 start
//        for (int i = 0; i < patIds.size(); i++) {
//          ordMainTreatDates = ordMainDao.selectByPatIdAndTreatDate(dataKey.get("facilityCd").toString(),patIds.get(i),fromDate,toDate);
//          ordNoList = getOrdNoList(ordMainTreatDates);
//          dataKey.put("patId",patIds.get(i));
//          dataKey.put("ordNos",ordNoList);
//          params = ReportUtils.getParamElements(reportXml);
//          Map<Long, List<Map<String, Object>>> reportInfoIndex = getReportInfo(params, dataKey);
//          for (Long key : reportInfoIndex.keySet()) {
//            reportInfo.put(key, reportInfoIndex.get(key));
//          }
//
//          // add #11136 紹介状の集計範囲修正 高　start
//          if (!StringUtils.isEmpty(dataKey.get("specifyDate"))) {
//            String reportXmlTmplRepeatId = params.get(0).getReportXmlTmplRepeat().getId();
//            String unitVAddress = params.get(0).getReportXmlTotalTable().getUnitVAddress();
//            String unitHAddress = params.get(0).getReportXmlTotalTable().getUnitHAddress();
//            List<ReportXmlParam> paramsList = new ArrayList<>();
//            for (int index = 0; index < params.size();index++){
//              if (params.get(index).getId().equals(reportXmlTmplRepeatId) ||
//                params.get(index).getId().equals(unitVAddress) ||
//                params.get(index).getId().equals(unitHAddress)) {
//                paramsList.add(params.get(index));
//              }
//            }
//
//            ordMainTreatDates = ordMainDao.selectByPatIdAndTreatDate(dataKey.get("facilityCd").toString(),patIds.get(i),mondayStr,sundayStr);
//            ordNoList = getOrdNoList(ordMainTreatDates);
//            dataKey.put("ordNos",ordNoList);
//            Map<Long, List<Map<String, Object>>> reportInfoIndexNew = getReportInfo(paramsList, dataKey);
//            for (Long key : reportInfoIndexNew.keySet()) {
//              reportInfo.put(key, reportInfoIndexNew.get(key));
//            }
//          }
//          // add #11136 紹介状の集計範囲修正 高　end
//
//          List<Map<String, Object>> rec = getPrintedInfo(params, dataKey, reportInfo);
//          reportInfo.put(PRINT_INFO_CODE, rec);
//          params = reportServiceImpl.paramsReplaceTmpValue(params, reportInfo);
//          reportInfo = getChangeList(reportInfo, params);
//        }
        // del #11249 患者情報系historyの取得条件見直し（集計有り紹介状）高 end
        // add #11136 紹介状の集計範囲修正 高　start
        if (!StringUtils.isEmpty(dataKey.get("specifyDate"))) {
          // mod #11381 【たくしん会】指示.VA情報.画像が日付によって2件目以降表示されないことがある　V1.0B limingzhe start
//          dataKey.put("fromDate",mondayStr);
//          dataKey.put("toDate",sundayStr);
          specifyFromDate = mondayStr;
          specifyToDate = sundayStr;
          // mod #11381 【たくしん会】指示.VA情報.画像が日付によって2件目以降表示されないことがある　V1.0B limingzhe end
        }
        // add #11136 紹介状の集計範囲修正 高　end
      }
      else {
        for (int i = 0; i < patId.size(); i++) {
          if(or.size() != 0) {
            dataKey.put("ordNo", or.get(i));
          }
          dataKey.put("patId", patId.get(i));
          params = ReportUtils.getParamElements(reportXml);
          Map<Long, List<Map<String, Object>>> reportInfoIndex = getReportInfo(params, dataKey);
          // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
          //List<Map<String, Object>> rec = getPrintedInfo(params, dataKey, reportInfoIndex);
          List<Map<String, Object>> rec = reportServiceImpl.getPrintedInfo(params, dataKey, reportInfoIndex);
          // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
          reportInfoIndex.put(PRINT_INFO_CODE, rec);
          params = reportServiceImpl.paramsReplaceTmpValue(params, reportInfoIndex);
          // add #11127 グループ除外処理の残対応（モニタ、身体情報）2025/07/17　高　start
          reportServiceImpl.reportFilterOutUnusedData(params,reportInfoIndex);
          // add #11127 グループ除外処理の残対応（モニタ、身体情報）2025/07/17　高　end
          // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
          //reportInfoIndex = getChangeList(reportInfoIndex, params);
          reportInfoIndex = reportServiceImpl.getChangeList(reportInfoIndex, params);
          // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
          for (Long key : reportInfoIndex.keySet()) {
            if (reportInfo.containsKey(key)) {
              reportInfo.get(key).addAll(reportInfoIndex.get(key));
            } else {
              reportInfo.put(key, reportInfoIndex.get(key));
            }
          }
          List<Map<String, Object>> reportIndicateResult = reportInfo.get(Long.valueOf("4"));
          List<Map<String, Object>> reportRealityResult = reportInfo.get(Long.valueOf("74"));
          List<Map<String, Object>> reportIndicate = reportInfo.get(Long.valueOf("8"));
          List<Map<String, Object>> reportReality = reportInfo.get(Long.valueOf("97"));
          // add #10042 カテゴリ「指示」の出力不正 03 sunsy start
          List<Map<String, Object>> reportFutureActive = reportInfo.get(Long.valueOf("141"));
          List<Map<String, Object>> reportRealityMedDeg = reportInfo.get(Long.valueOf("190"));
          // add #10042 カテゴリ「指示」の出力不正 03 sunsy end
          if (reportIndicateResult != null && reportIndicateResult.size() > 0){
            List<Map<String, Object>> midList = reportInfo.get(Long.valueOf("4"));
            // 施設設定マスタNo.107 投与薬剤表示順 設定値
            List<FacilitySettingNoDisplayOrder> listDisplayOrder = new ArrayList<>();
            listDisplayOrder = ordMainDao.selectMedEquipDisplayOrder(mstReport.getFacilityCd());
            String displayValue = null;
            String[] keyList = new String[]{};
            List<String> displayOrderList = new ArrayList<>();
            for (int x = 0; x < listDisplayOrder.size(); x++) {
              if ("3007".equals(listDisplayOrder.get(x).getFacilitySettingNo())) {
                displayValue = listDisplayOrder.get(x).getValue();
              }
            }
            if (displayValue != null) {
              keyList = displayValue.replace("[","").replace("]","").replace("\"","").split(",");
            }
            for(int x = 0;x < keyList.length; x++){
              switch (keyList[x]){
                // 登録順
                case "0":
                  displayOrderList.add("json_idx");
                  break;
                // 薬剤分類順
                case "1":
                  displayOrderList.add("med_cls_cd");
                  break;
                // 薬剤区分
                case "2":
                  displayOrderList.add("medicine_type");
                  break;
                // 薬剤マスタ表示順
                case "3":
                  displayOrderList.add("med_cd");
                  displayOrderList.add("med_mix_cd");
                  break;
                // 投与時間帯
                case "4":
                  displayOrderList.add("med_timing_cd");
                  break;
                // 手技
                case "5":
                  displayOrderList.add("med_pro_cd");
                  break;
                // 投薬パターンコード
                case "6":
                  displayOrderList.add("date_interval");
                  break;
                default:
                  break;
              }
            }

            int sortSize = displayOrderList.size();
            int[] compareResultArr = new int[sortSize];
            String[] colArr = new String[sortSize];
            for(int x = 0; x < sortSize; x++) {
              compareResultArr[x]= 0;
              colArr[x] = displayOrderList.get(x);
            }
            // 施設設定マスタNo.107に設定された順番で薬剤を表示する
            Collections.sort(midList, new Comparator<Map<String, Object>>() {
              public int compare(Map<String, Object> o1, Map<String, Object> o2) {
                for (int x = 0, len = sortSize; x < len; x++) {
                  Integer v1 = (o1.get(colArr[x]) == null || o1.get(colArr[x]) == "") ? 9999999 : Integer.parseInt(o1.get(colArr[x]).toString());
                  Integer v2 = (o2.get(colArr[x]) == null || o2.get(colArr[x]) == "") ? 9999999 : Integer.parseInt(o2.get(colArr[x]).toString());
                  compareResultArr[x] = v1.compareTo(v2);
                  if (compareResultArr[x] != 0){
                    return compareResultArr[x];
                  }
                }
                return 0;
              }
            });
            reportInfo.put(Long.valueOf("4"), midList);
          }
          if (reportIndicate != null && reportIndicate.size() > 0){
            List<Map<String, Object>> midList = reportInfo.get(Long.valueOf("8"));
            // 施設設定マスタNo.107 投与薬剤表示順 設定値
            List<FacilitySettingNoDisplayOrder> listDisplayOrder = new ArrayList<>();
            listDisplayOrder = ordMainDao.selectMedEquipDisplayOrder(mstReport.getFacilityCd());
            String displayValue = null;
            String[] keyList = new String[]{};
            List<String> displayOrderList = new ArrayList<>();
            for (int x = 0; x < listDisplayOrder.size(); x++) {
              if ("3007".equals(listDisplayOrder.get(x).getFacilitySettingNo())) {
                displayValue = listDisplayOrder.get(x).getValue();
              }
            }
            if (displayValue != null) {
              keyList = displayValue.replace("[","").replace("]","").replace("\"","").split(",");
            }
            for(int x = 0;x < keyList.length; x++){
              switch (keyList[x]){
                // 登録順
                case "0":
                  displayOrderList.add("json_idx");
                  break;
                // 薬剤分類順
                case "1":
                  displayOrderList.add("med_cls_cd");
                  break;
                // 薬剤区分
                case "2":
                  displayOrderList.add("medicine_type");
                  break;
                // 薬剤マスタ表示順
                case "3":
                  displayOrderList.add("med_cd");
                  displayOrderList.add("med_mix_cd");
                  break;
                // 投与時間帯
                case "4":
                  displayOrderList.add("med_timing_cd");
                  break;
                // 手技
                case "5":
                  displayOrderList.add("med_pro_cd");
                  break;
                // 投薬パターンコード
                case "6":
                  displayOrderList.add("date_interval");
                  break;
                default:
                  break;
              }
            }

            int sortSize = displayOrderList.size();
            int[] compareResultArr = new int[sortSize];
            String[] colArr = new String[sortSize];
            for(int x = 0; x < sortSize; x++) {
              compareResultArr[x]= 0;
              colArr[x] = displayOrderList.get(x);
            }
            // 施設設定マスタNo.107に設定された順番で薬剤を表示する
            Collections.sort(midList, new Comparator<Map<String, Object>>() {
              public int compare(Map<String, Object> o1, Map<String, Object> o2) {
                for (int x = 0, len = sortSize; x < len; x++) {
                  Integer v1 = (o1.get(colArr[x]) == null || o1.get(colArr[x]) == "") ? 9999999 : Integer.parseInt(o1.get(colArr[x]).toString());
                  Integer v2 = (o2.get(colArr[x]) == null || o2.get(colArr[x]) == "") ? 9999999 : Integer.parseInt(o2.get(colArr[x]).toString());
                  compareResultArr[x] = v1.compareTo(v2);
                  if (compareResultArr[x] != 0){
                    return compareResultArr[x];
                  }
                }
                return 0;
              }
            });
            reportInfo.put(Long.valueOf("8"), midList);
          }
          if (reportRealityResult != null && reportRealityResult.size() > 0) {
            List<Map<String, Object>> midList = reportInfo.get(Long.valueOf("74"));
            // 施設設定マスタNo.106 医材表示順 設定値
            List<FacilitySettingNoDisplayOrder> listDisplayOrder = new ArrayList<>();
            listDisplayOrder = ordMainDao.selectMedEquipDisplayOrder(mstReport.getFacilityCd());
            String displayValue = null;
            String[] keyList = new String[]{};
            List<String> displayOrderList = new ArrayList<>();
            for (int x = 0; x < listDisplayOrder.size(); x++) {
              if ("3006".equals(listDisplayOrder.get(x).getFacilitySettingNo())) {
                displayValue = listDisplayOrder.get(x).getValue();
              }
            }
            if (displayValue != null) {
              keyList = displayValue.replace("[","").replace("]","").replace("\"","").split(",");
            }
            for(int x = 0; x < keyList.length; x++){
              switch (keyList[x]){
                // 登録順
                case "0":
                  displayOrderList.add("json_idx");
                  break;
                // 医材分類順
                case "1":
                  displayOrderList.add("class_order");
                  break;
                // 医材マスタ表示順
                case "2":
                  displayOrderList.add("code_order");
                  break;
                default:
                  break;
              }
            }

            int sortSize = displayOrderList.size();
            int[] compareResultArr = new int[sortSize];
            String[] colArr = new String[sortSize];
            for(int x = 0; x < sortSize; x++) {
              compareResultArr[x]= 0;
              colArr[x] = displayOrderList.get(x);
            }
            // 施設設定マスタNo.106に設定された順番で医材を表示する
            Collections.sort(midList, new Comparator<Map<String, Object>>() {
              public int compare(Map<String, Object> o1, Map<String, Object> o2) {
                for (int x = 0, len = sortSize; x < len; x++) {
                  Integer v1 = (o1.get(colArr[x]) == null || o1.get(colArr[x]) == "") ? 999999 : Integer.parseInt(o1.get(colArr[x]).toString());
                  Integer v2 = (o2.get(colArr[x]) == null || o2.get(colArr[x]) == "") ? 999999 : Integer.parseInt(o2.get(colArr[x]).toString());
                  compareResultArr[x] = v1.compareTo(v2);
                  if (compareResultArr[x] != 0){
                    return compareResultArr[x];
                  }
                }
                return 0;
              }
            });
            reportInfo.put(Long.valueOf("74"), midList);
          }
          if (reportReality != null && reportReality.size() > 0) {
            List<Map<String, Object>> midList = reportInfo.get(Long.valueOf("97"));
            // 施設設定マスタNo.106 医材表示順 設定値
            List<FacilitySettingNoDisplayOrder> listDisplayOrder = new ArrayList<>();
            listDisplayOrder = ordMainDao.selectMedEquipDisplayOrder(mstReport.getFacilityCd());
            String displayValue = null;
            String[] keyList = new String[]{};
            List<String> displayOrderList = new ArrayList<>();
            for (int x = 0; x < listDisplayOrder.size(); x++) {
              if ("3006".equals(listDisplayOrder.get(x).getFacilitySettingNo())) {
                displayValue = listDisplayOrder.get(x).getValue();
              }
            }
            if (displayValue != null) {
              keyList = displayValue.replace("[","").replace("]","").replace("\"","").split(",");
            }
            for(int x = 0; x < keyList.length; x++){
              switch (keyList[x]){
                // 登録順
                case "0":
                  displayOrderList.add("json_idx");
                  break;
                // 医材分類順
                case "1":
                  displayOrderList.add("class_order");
                  break;
                // 医材マスタ表示順
                case "2":
                  displayOrderList.add("code_order");
                  break;
                default:
                  break;
              }
            }

            int sortSize = displayOrderList.size();
            int[] compareResultArr = new int[sortSize];
            String[] colArr = new String[sortSize];
            for(int x = 0; x < sortSize; x++) {
              compareResultArr[x]= 0;
              colArr[x] = displayOrderList.get(x);
            }
            // 施設設定マスタNo.106に設定された順番で医材を表示する
            Collections.sort(midList, new Comparator<Map<String, Object>>() {
              public int compare(Map<String, Object> o1, Map<String, Object> o2) {
                for (int x = 0, len = sortSize; x < len; x++) {
                  Integer v1 = (o1.get(colArr[x]) == null || o1.get(colArr[x]) == "") ? 999999 : Integer.parseInt(o1.get(colArr[x]).toString());
                  Integer v2 = (o2.get(colArr[x]) == null || o2.get(colArr[x]) == "") ? 999999 : Integer.parseInt(o2.get(colArr[x]).toString());
                  compareResultArr[x] = v1.compareTo(v2);
                  if (compareResultArr[x] != 0){
                    return compareResultArr[x];
                  }
                }
                return 0;
              }
            });
            reportInfo.put(Long.valueOf("97"), midList);
          }
          // add #10042 カテゴリ「指示」の出力不正 03 sunsy start
          if (reportFutureActive != null && reportFutureActive.size() > 0){
            List<Map<String, Object>> midList = reportInfo.get(Long.valueOf("141"));
            // 施設設定マスタNo.107 投与薬剤表示順 設定値
            List<FacilitySettingNoDisplayOrder> listDisplayOrder = new ArrayList<>();
            listDisplayOrder = ordMainDao.selectMedEquipDisplayOrder(mstReport.getFacilityCd());
            String displayValue = null;
            String[] keyList = new String[]{};
            List<String> displayOrderList = new ArrayList<>();
            for (int x = 0; x < listDisplayOrder.size(); x++) {
              if ("3007".equals(listDisplayOrder.get(x).getFacilitySettingNo())) {
                displayValue = listDisplayOrder.get(x).getValue();
              }
            }
            if (displayValue != null) {
              keyList = displayValue.replace("[","").replace("]","").replace("\"","").split(",");
            }
            for(int x = 0;x < keyList.length; x++){
              switch (keyList[x]){
                // 登録順
                case "0":
                  displayOrderList.add("json_idx");
                  break;
                // 薬剤分類順
                case "1":
                  displayOrderList.add("med_cls_cd");
                  break;
                // 薬剤区分
                case "2":
                  displayOrderList.add("medicine_type");
                  break;
                // 薬剤マスタ表示順
                case "3":
                  displayOrderList.add("med_cd");
                  displayOrderList.add("med_mix_cd");
                  break;
                // 投与時間帯
                case "4":
                  displayOrderList.add("med_timing_cd");
                  break;
                // 手技
                case "5":
                  displayOrderList.add("med_pro_cd");
                  break;
                // 投薬パターンコード
                case "6":
                  displayOrderList.add("date_interval");
                  break;
                default:
                  break;
              }
            }

            int sortSize = displayOrderList.size();
            int[] compareResultArr = new int[sortSize];
            String[] colArr = new String[sortSize];
            for(int x = 0; x < sortSize; x++) {
              compareResultArr[x]= 0;
              colArr[x] = displayOrderList.get(x);
            }
            // 施設設定マスタNo.107に設定された順番で薬剤を表示する
            Collections.sort(midList, new Comparator<Map<String, Object>>() {
              public int compare(Map<String, Object> o1, Map<String, Object> o2) {
                for (int x = 0, len = sortSize; x < len; x++) {
                  Integer v1 = (o1.get(colArr[x]) == null || o1.get(colArr[x]) == "") ? 9999999 : Integer.parseInt(o1.get(colArr[x]).toString());
                  Integer v2 = (o2.get(colArr[x]) == null || o2.get(colArr[x]) == "") ? 9999999 : Integer.parseInt(o2.get(colArr[x]).toString());
                  compareResultArr[x] = v1.compareTo(v2);
                  if (compareResultArr[x] != 0){
                    return compareResultArr[x];
                  }
                }
                return 0;
              }
            });
            reportInfo.put(Long.valueOf("141"), midList);
          }
          if (reportRealityMedDeg != null && reportRealityMedDeg.size() > 0){
            List<Map<String, Object>> midList = reportInfo.get(Long.valueOf("190"));
            // 施設設定マスタNo.107 投与薬剤表示順 設定値
            List<FacilitySettingNoDisplayOrder> listDisplayOrder = new ArrayList<>();
            listDisplayOrder = ordMainDao.selectMedEquipDisplayOrder(mstReport.getFacilityCd());
            String displayValue = null;
            String[] keyList = new String[]{};
            List<String> displayOrderList = new ArrayList<>();
            for (int x = 0; x < listDisplayOrder.size(); x++) {
              if ("3007".equals(listDisplayOrder.get(x).getFacilitySettingNo())) {
                displayValue = listDisplayOrder.get(x).getValue();
              }
            }
            if (displayValue != null) {
              keyList = displayValue.replace("[","").replace("]","").replace("\"","").split(",");
            }
            for(int x = 0;x < keyList.length; x++){
              switch (keyList[x]){
                // 登録順
                case "0":
                  displayOrderList.add("json_idx");
                  break;
                // 薬剤分類順
                case "1":
                  displayOrderList.add("med_cls_cd");
                  break;
                // 薬剤区分
                case "2":
                  displayOrderList.add("medicine_type");
                  break;
                // 薬剤マスタ表示順
                case "3":
                  displayOrderList.add("med_cd");
                  displayOrderList.add("med_mix_cd");
                  break;
                // 投与時間帯
                case "4":
                  displayOrderList.add("med_timing_cd");
                  break;
                // 手技
                case "5":
                  displayOrderList.add("med_pro_cd");
                  break;
                // 投薬パターンコード
                case "6":
                  displayOrderList.add("date_interval");
                  break;
                default:
                  break;
              }
            }

            int sortSize = displayOrderList.size();
            int[] compareResultArr = new int[sortSize];
            String[] colArr = new String[sortSize];
            for(int x = 0; x < sortSize; x++) {
              compareResultArr[x]= 0;
              colArr[x] = displayOrderList.get(x);
            }
            // 施設設定マスタNo.107に設定された順番で薬剤を表示する
            Collections.sort(midList, new Comparator<Map<String, Object>>() {
              public int compare(Map<String, Object> o1, Map<String, Object> o2) {
                for (int x = 0, len = sortSize; x < len; x++) {
                  Integer v1 = (o1.get(colArr[x]) == null || o1.get(colArr[x]) == "") ? 9999999 : Integer.parseInt(o1.get(colArr[x]).toString());
                  Integer v2 = (o2.get(colArr[x]) == null || o2.get(colArr[x]) == "") ? 9999999 : Integer.parseInt(o2.get(colArr[x]).toString());
                  compareResultArr[x] = v1.compareTo(v2);
                  if (compareResultArr[x] != 0){
                    return compareResultArr[x];
                  }
                }
                return 0;
              }
            });
            reportInfo.put(Long.valueOf("190"), midList);
          }
          // add #10042 カテゴリ「指示」の出力不正 03 sunsy end
        }
      }
    }
    else {
      // mod #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe start
//      // add #11172 患者情報系historyの取得条件見直し limingzhe start
//      // テンプレート外 テンプレート無し データ項目
//      List<ReportXmlParam> paramsSelectbyMongDB = new ArrayList<>();
//      List<String> sqlCodesSelectbyMongDB = new ArrayList<>();
//      boolean bHavetmpl = false;
//      // add #11172 患者情報系historyの取得条件見直し limingzhe end
//      // add #11226 患者情報系historyの取得条件見直し② limingzhe start
//      // テンプレート内 データ項目
//      List<ReportXmlParam> paramsInTmplbyMongDB = new ArrayList<>();
//      List<ReportXmlParam> paramsInTmplbyPatId = new ArrayList<>();
//      List<ReportXmlParam> paramsInTmplbyOrdNos = new ArrayList<>();
//      List<ReportXmlParam> paramsInTmplbyOther = new ArrayList<>();
//      // add #11226 患者情報系historyの取得条件見直し② limingzhe end
//      // テンプレート外 テンプレート無し データ項目
//      List<ReportXmlParam> paramsonlybyPatId = new ArrayList<>();
//      List<ReportXmlParam> paramsonlybyOrdNos = new ArrayList<>();
//      List<ReportXmlParam> paramsOther = new ArrayList<>();
//
//      List<String> sqlCodesonlybyPatId = new ArrayList<>();
//      List<String> sqlCodesonlybyOrdNos = new ArrayList<>();
//      List<String> sqlCodesOther = new ArrayList<>();
//      for(String sqlCode: sqlCodes){
//        // add #11172 患者情報系historyの取得条件見直し limingzhe start
//        if(sysDataSetService.isMongDBSqlSearch(Long.parseLong(sqlCode)))
//          sqlCodesSelectbyMongDB.add(sqlCode);
//          // add #11172 患者情報系historyの取得条件見直し limingzhe end
//        else if(sysDataSetService.distinParaOnlybyPatId(Long.parseLong(sqlCode)))
//          sqlCodesonlybyPatId.add(sqlCode);
//        else if(sysDataSetService.distinParaOnlybyOrdNos(Long.parseLong(sqlCode)))
//          sqlCodesonlybyOrdNos.add(sqlCode);
//        else
//          sqlCodesOther.add(sqlCode);
//      }
//      for (ReportXmlParam reParam: params){
//        // add #11226 患者情報系historyの取得条件見直し② limingzhe start
//        ReportXmlTmplRepeat tmplRepeat = reParam.getReportXmlTmplRepeat();
//        // add #11226 患者情報系historyの取得条件見直し② limingzhe start
//        // add #11172 患者情報系historyの取得条件見直し limingzhe start
//        if(sqlCodesSelectbyMongDB.contains(reParam.getSqlCode())) {
//          // del #11226 患者情報系historyの取得条件見直し② limingzhe start
//          //ReportXmlTmplRepeat tmplRepeat = reParam.getReportXmlTmplRepeat();
//          // del #11226 患者情報系historyの取得条件見直し② limingzhe start
//          if(tmplRepeat != null && !tmplRepeat.getId().equals("")){
//            bHavetmpl = true;
//            if(!reParam.isTmplRepeat()) {
//              paramsSelectbyMongDB.add(reParam);
//              continue;
//            }
//            // add #11226 患者情報系historyの取得条件見直し② limingzhe start
//            else {
//              paramsInTmplbyMongDB.add(reParam);
//              continue;
//            }
//            // add #11226 患者情報系historyの取得条件見直し② limingzhe end
//          }
//          else {
//            paramsSelectbyMongDB.add(reParam);
//            continue;
//          }
//        }
//        // add #11172 患者情報系historyの取得条件見直し limingzhe end
//        // mod #11226 患者情報系historyの取得条件見直し② limingzhe start
//        //if(sqlCodesonlybyPatId.contains(reParam.getSqlCode())) paramsonlybyPatId.add(reParam);
//        //else if(sqlCodesonlybyOrdNos.contains(reParam.getSqlCode())) paramsonlybyOrdNos.add(reParam);
//        //else paramsOther.add(reParam);
//        else if(sqlCodesonlybyPatId.contains(reParam.getSqlCode())) {
//          if(tmplRepeat != null && !tmplRepeat.getId().equals("")){
//            bHavetmpl = true;
//            if(reParam.isTmplRepeat()){
//              paramsInTmplbyPatId.add(reParam);
//              continue;
//            }
//          }
//          paramsonlybyPatId.add(reParam);
//        }
//        else if(sqlCodesonlybyOrdNos.contains(reParam.getSqlCode())) {
//          if(tmplRepeat != null && !tmplRepeat.getId().equals("")){
//            bHavetmpl = true;
//            if(reParam.isTmplRepeat()){
//              paramsInTmplbyOrdNos.add(reParam);
//              continue;
//            }
//          }
//          paramsonlybyOrdNos.add(reParam);
//        }
//        else {
//          if(tmplRepeat != null && !tmplRepeat.getId().equals("")){
//            bHavetmpl = true;
//            if(reParam.isTmplRepeat()){
//              paramsInTmplbyOther.add(reParam);
//              continue;
//            }
//          }
//          paramsOther.add(reParam);
//        }
//        // mod #11226 患者情報系historyの取得条件見直し② limingzhe end
//      }
      boolean bHavetmpl = false;
      Map<String, List<String>> sqlCodesGroup = new HashMap<>();
      sqlCodesGroup.put("MongDB", new ArrayList<String>());
      sqlCodesGroup.put("patId", new ArrayList<String>());
      sqlCodesGroup.put("ordNos", new ArrayList<String>());
      sqlCodesGroup.put("ordPrescriptionNo", new ArrayList<String>());
      sqlCodesGroup.put("Other", new ArrayList<String>());
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
      for(String sqlCode: sqlCodes){
        // add #10740 指示.修正内容の出力不正 sunsy start
        if (sysDataSetService.isIndHistorySqlSearch(Long.parseLong(sqlCode)))
          sqlCodesGroup.get("Other").add(sqlCode);
        else
        // add #10740 指示.修正内容の出力不正 sunsy start
        if(sysDataSetService.isMongDBSqlSearch(Long.parseLong(sqlCode)))
          sqlCodesGroup.get("MongDB").add(sqlCode);
        else if(sysDataSetService.distinParaOnlybyPatId(Long.parseLong(sqlCode)))
          sqlCodesGroup.get("patId").add(sqlCode);
        else if(sysDataSetService.distinParaOnlybyParam(Long.parseLong(sqlCode), "ordNos"))
          sqlCodesGroup.get("ordNos").add(sqlCode);
        else if(sysDataSetService.distinParaOnlybyParam(Long.parseLong(sqlCode), "ordPrescriptionNo"))
          sqlCodesGroup.get("ordPrescriptionNo").add(sqlCode);
        else
          sqlCodesGroup.get("Other").add(sqlCode);
      }
      // テンプレート内 データ項目
      Map<String, List<ReportXmlParam>> paramsInTmplGroup = new HashMap<>();
      paramsInTmplGroup.put("MongDB", new ArrayList<ReportXmlParam>());
      paramsInTmplGroup.put("patId", new ArrayList<ReportXmlParam>());
      paramsInTmplGroup.put("ordNos", new ArrayList<ReportXmlParam>());
      paramsInTmplGroup.put("ordPrescriptionNo", new ArrayList<ReportXmlParam>());
      paramsInTmplGroup.put("Other", new ArrayList<ReportXmlParam>());
      // テンプレート外 テンプレート無し データ項目
      Map<String, List<ReportXmlParam>> paramsGroup = new HashMap<>();
      paramsGroup.put("MongDB", new ArrayList<ReportXmlParam>());
      paramsGroup.put("patId", new ArrayList<ReportXmlParam>());
      paramsGroup.put("ordNos", new ArrayList<ReportXmlParam>());
      paramsGroup.put("ordPrescriptionNo", new ArrayList<ReportXmlParam>());
      paramsGroup.put("Other", new ArrayList<ReportXmlParam>());
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
        else if(sqlCodesGroup.get("patId").contains(reParam.getSqlCode())) {
          if(tmplRepeat != null && !tmplRepeat.getId().equals("")){
            bHavetmpl = true;
            if(reParam.isTmplRepeat()){
              paramsInTmplGroup.get("patId").add(reParam);
              continue;
            }
          }
          // mod #11276 キー日付に対するデータ引き当て仕様対応 高　start
          if (!reParam.getDataPath().contains("指示") && !reParam.getDataPath().contains("実績") && !reParam.getDataPath().contains("処方") && !reParam.getDataPath().contains("処方(最新)")) {
            paramsGroup.get("patId").add(reParam);
          } else {
            // mod #10740 指示.修正内容の出力不正 sunsy start
            if (reParam.getDataPath().contains("指示.修正内容") || reParam.getDataPath().contains("指示.指示履歴")) {
              paramsGroup.get("Other").add(reParam);
            }else {
              groupInfoIntroductionReportParam(reParam, paramsGroupInd, paramsGroupRst, paramsGroupIsu, paramsGroupIsuNew);
            }
            // mod #10740 指示.修正内容の出力不正 sunsy end
          }
//          paramsGroup.get("patId").add(reParam);
          // mod #11276 キー日付に対するデータ引き当て仕様対応 高　end
        }
        else if(sqlCodesGroup.get("ordNos").contains(reParam.getSqlCode())) {
          if(tmplRepeat != null && !tmplRepeat.getId().equals("")){
            bHavetmpl = true;
            if(reParam.isTmplRepeat()){
              paramsInTmplGroup.get("ordNos").add(reParam);
              continue;
            }
          }
          // mod #11276 キー日付に対するデータ引き当て仕様対応 高　start
          if (!reParam.getDataPath().contains("指示") && !reParam.getDataPath().contains("実績") && !reParam.getDataPath().contains("処方") && !reParam.getDataPath().contains("処方(最新)")) {
            paramsGroup.get("ordNos").add(reParam);
          } else {
            groupInfoIntroductionReportParam(reParam, paramsGroupInd, paramsGroupRst, paramsGroupIsu, paramsGroupIsuNew);
          }
//          paramsGroup.get("ordNos").add(reParam);
          // mod #11276 キー日付に対するデータ引き当て仕様対応 高　end
        }
        else if(sqlCodesGroup.get("ordPrescriptionNo").contains(reParam.getSqlCode())) {
          if(tmplRepeat != null && !tmplRepeat.getId().equals("")){
            bHavetmpl = true;
            if(reParam.isTmplRepeat()){
              paramsInTmplGroup.get("ordPrescriptionNo").add(reParam);
              continue;
            }
          }
          // mod #11276 キー日付に対するデータ引き当て仕様対応 高　start
          if (!reParam.getDataPath().contains("指示") && !reParam.getDataPath().contains("実績") && !reParam.getDataPath().contains("処方") && !reParam.getDataPath().contains("処方(最新)")) {
            paramsGroup.get("ordPrescriptionNo").add(reParam);
          } else {
            groupInfoIntroductionReportParam(reParam, paramsGroupInd, paramsGroupRst, paramsGroupIsu, paramsGroupIsuNew);
          }
//          paramsGroup.get("ordPrescriptionNo").add(reParam);
          // mod #11276 キー日付に対するデータ引き当て仕様対応 高　end
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
            groupInfoIntroductionReportParam(reParam, paramsGroupInd, paramsGroupRst, paramsGroupIsu, paramsGroupIsuNew);
          }
//          paramsGroup.get("Other").add(reParam);
          // mod #11276 キー日付に対するデータ引き当て仕様対応 高　end
        }
      }
      // mod #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe end
      // add #11226 患者情報系historyの取得条件見直し② limingzhe start
      // データ抽出条件の「基準日」
      String tmplKey = "ord_no";
      if(dataKey.get("dateKind") != null){
        tmplKey = dataKey.get("dateKind").toString().equals("exam_date") ? "exam_main_cd" : dataKey.get("dateKind").toString().equals("issue_date") ? "ord_prescription_no" : "ord_no";
      }
      // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
      //Map<String, String> sortKey = getSortKey(tmplKey);
      Map<String, String> sortKey = reportServiceImpl.getSortKey(tmplKey);
      // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
      // mod #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe start
      List<Map<String, Object>> results = reportServiceImpl.getGroupKeyNoList(tmplKey, dataKey, null);
//      List<Map<String, Object>> results = new ArrayList<>();
//      if(tmplKey.length()>0){
//        // mod #11584 テンプレート「処方箋交付日」抽出のとき処方箋区分指定で空ページが出力される limingzhe start
////        String sql = "select " + sortKey.get("tmplKey") + "," + sortKey.get("tmplSortKey") + " from " + sortKey.get("sortDb") +
////          " where " + " pat_id = " + dataKey.get("patId") + " and " + " facility_cd = '" + dataKey.get("facilityCd")
////          + "' and " + sortKey.get("tmplSortKey") + " between '" + String.valueOf(dataKey.get("fromDate")).replace("/","").replace("-","") + "' and '" + String.valueOf(dataKey.get("toDate")).replace("/","").replace("-","") + " 235959'"
////          // add #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe start
////          + " and is_del = '0'"
////          // add #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe end
////          + " order by " + sortKey.get("tmplSortKey");
////        results = sysDataSetService.sqlDB5Search(sql);
//        StringBuilder sqlBuilder = new StringBuilder();
//        sqlBuilder.append("select ").append(sortKey.get("tmplKey")).append(",").append(sortKey.get("tmplSortKey"));
//        sqlBuilder.append(" from ").append(sortKey.get("sortDb"));
//        sqlBuilder.append(" where pat_id = ").append(dataKey.get("patId")).append(" and facility_cd = '").append(dataKey.get("facilityCd")).append("'");
//        sqlBuilder.append(" and ").append(sortKey.get("tmplSortKey")).append(" between '");
//        sqlBuilder.append(String.valueOf(dataKey.get("fromDate")).replace("/","").replace("-",""));
//        sqlBuilder.append("' and '").append(String.valueOf(dataKey.get("toDate")).replace("/","").replace("-","")).append(" 235959'");
//        if(tmplKey.equals("ord_prescription_no")){
//          sqlBuilder.append(" and prescription_type in (");
//          List<String> prescriptionTypeList = new ArrayList<>();
//          if(dataKey.get("prescriptionClassList") != null){
//            prescriptionTypeList = (List<String>) dataKey.get("prescriptionClassList");
//          } else {
//            prescriptionTypeList.add("-1");
//          }
//          for(String t : prescriptionTypeList){
//            sqlBuilder.append("'").append(t).append("',");
//          }
//          sqlBuilder.deleteCharAt(sqlBuilder.length() - 1);
//          sqlBuilder.append(")");
//        }
//        sqlBuilder.append(" and is_del = '0'");
//        sqlBuilder.append(" order by ").append(sortKey.get("tmplSortKey"));
//        results = sysDataSetService.sqlDB5Search(sqlBuilder.toString());
//        // mod #11584 テンプレート「処方箋交付日」抽出のとき処方箋区分指定で空ページが出力される limingzhe end
//      }
      // mod #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe end

      // 帳票の設定抽出条件
      // mod #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe start
      //String tmplKeySet = params.get(0).getReportXmlTmplRepeat().getKey();
      String tmplKeySet = params.get(0).getReportXmlTmplRepeat() != null ? params.get(0).getReportXmlTmplRepeat().getKey() : "";
      // mod #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe end
      // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
      //Map<String, String> sortKeySet = getSortKey(tmplKeySet);
      Map<String, String> sortKeySet = reportServiceImpl.getSortKey(tmplKeySet);
      // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
      // mod #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe start
      List<Map<String, Object>> resultSets = reportServiceImpl.getGroupKeyNoList(tmplKeySet, dataKey, null);
//      List<Map<String, Object>> resultSets = new ArrayList<>();
//      if(tmplKeySet.length()>0) {
//        // mod #11584 テンプレート「処方箋交付日」抽出のとき処方箋区分指定で空ページが出力される limingzhe start
////        String sqlSet = "select " + sortKeySet.get("tmplKey") + "," + sortKeySet.get("tmplSortKey") + " from " + sortKeySet.get("sortDb") +
////          " where " + " pat_id = " + dataKey.get("patId") + " and " + " facility_cd = '" + dataKey.get("facilityCd")
////          + "' and " + sortKeySet.get("tmplSortKey") + " between '" + String.valueOf(dataKey.get("fromDate")).replace("/", "").replace("-", "") + "' and '" + String.valueOf(dataKey.get("toDate")).replace("/", "").replace("-", "") + " 235959'"
////          // add #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe start
////          + " and is_del = '0'"
////          // add #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe end
////          + " order by " + sortKeySet.get("tmplSortKey");
////        resultSets = sysDataSetService.sqlDB5Search(sqlSet);
//        StringBuilder sqlBuilder = new StringBuilder();
//        sqlBuilder.append("select ").append(sortKeySet.get("tmplKey")).append(",").append(sortKeySet.get("tmplSortKey"));
//        sqlBuilder.append(" from ").append(sortKeySet.get("sortDb"));
//        sqlBuilder.append(" where pat_id = ").append(dataKey.get("patId")).append(" and facility_cd = '").append(dataKey.get("facilityCd")).append("'");
//        sqlBuilder.append(" and ").append(sortKeySet.get("tmplSortKey")).append(" between '");
//        sqlBuilder.append(String.valueOf(dataKey.get("fromDate")).replace("/","").replace("-",""));
//        sqlBuilder.append("' and '").append(String.valueOf(dataKey.get("toDate")).replace("/","").replace("-","")).append(" 235959'");
//        if(tmplKeySet.equals("ord_prescription_no")){
//          sqlBuilder.append(" and prescription_type in (");
//          List<String> prescriptionTypeList = new ArrayList<>();
//          if(dataKey.get("prescriptionClassList") != null){
//            prescriptionTypeList = (List<String>) dataKey.get("prescriptionClassList");
//          } else {
//            prescriptionTypeList.add("-1");
//          }
//          for(String t : prescriptionTypeList){
//            sqlBuilder.append("'").append(t).append("',");
//          }
//          sqlBuilder.deleteCharAt(sqlBuilder.length() - 1);
//          sqlBuilder.append(")");
//        }
//        sqlBuilder.append(" and is_del = '0'");
//        sqlBuilder.append(" order by ").append(sortKeySet.get("tmplSortKey"));
//        resultSets = sysDataSetService.sqlDB5Search(sqlBuilder.toString());
//        // mod #11584 テンプレート「処方箋交付日」抽出のとき処方箋区分指定で空ページが出力される limingzhe end
//      }
      // mod #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe end

      // テンプレート内項目用のsql取得結果から、ordNo等の繰り返しの基準となるNoを集計する
      boolean bHaveSame = false;
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

      for(int i = 0; i < resultEnd.size(); i++){
        // mod #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe start
        //keyfilteredList.add(Long.parseLong(resultEnd.get(i).get(sortKeySet.get("tmplKey")).toString()));
        keyfilteredList.add(Long.parseLong(reportServiceImpl.getGroupKeybyDateType(resultEnd.get(i).get(sortKeySet.get("tmplSortKey")).toString())));
        // mod #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe end
      }
      // 取得キーの重複除去とソート処理
      if (keyfilteredList.size() >= 1) {
        // keyNoList の重複除去
        keyfilteredList = keyfilteredList.stream().distinct().collect(Collectors.toList());
      }
      // mod #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe start
      //if(paramsInTmplbyMongDB.size()>0 && patId.size()>0){
      if(paramsInTmplGroup.get("MongDB").size()>0 && patId.size()>0){
      // mod #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe end
        dataKey.put("patId", patId.get(0));
        Map<String, Object> dataKeyTemp = new LinkedHashMap<>();
        for(String key: dataKey.keySet()){
          dataKeyTemp.put(key, dataKey.get(key));
        }

        // mod #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe start
        //for(int i = 0; i < resultEnd.size(); i++){
        for(int i = 0; i < keyfilteredList.size(); i++){
        // mod #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe end
          //テンプレート内
          //　　　1日指定：　開始と終了を同日として、範囲に含むデータの日付（複数）
          //　　　範囲指定：　開始と終了の範囲に含むデータの日付（複数）
          // mod #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe start
          //dataKeyTemp.put(ReportConstant.ReportDataKey.DATE_TO, resultEnd.get(i).get(sortKeySet.get("tmplSortKey")));
          dataKeyTemp.put(ReportConstant.ReportDataKey.DATE_TO, keyfilteredList.get(i));
          // mod #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe end
          params = ReportUtils.getParamElements(reportXml);
          // mod #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe start
          //Map<Long, List<Map<String, Object>>> reportInfoIndex = getReportInfo(paramsInTmplbyMongDB, dataKeyTemp);
          Map<Long, List<Map<String, Object>>> reportInfoIndex = getReportInfo(paramsInTmplGroup.get("MongDB"), dataKeyTemp);
          // mod #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe end
          for (Long key : reportInfoIndex.keySet()) {
            for(int j = 0; j < reportInfoIndex.get(key).size(); j++){
              // mod #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe start
              //reportInfoIndex.get(key).get(j).put(sortKeySet.get("tmplKey"), resultEnd.get(i).get(sortKeySet.get("tmplKey")));
              reportInfoIndex.get(key).get(j).put("pat_info_date_key", keyfilteredList.get(i));
              // mod #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe end
            }
          }
          params = reportServiceImpl.paramsReplaceTmpValue(params, reportInfoIndex);
          // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
          //reportInfoIndex = getChangeList(reportInfoIndex, params);
          reportInfoIndex = reportServiceImpl.getChangeList(reportInfoIndex, params);
          // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
          for (Long key : reportInfoIndex.keySet()) {
            if (reportInTmplInfo.containsKey(key)) {
              reportInTmplInfo.get(key).addAll(reportInfoIndex.get(key));
            } else {
              reportInTmplInfo.put(key, reportInfoIndex.get(key));
            }
          }
        }
      }
      // mod #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe start
      //selectReportInfo(reportXml, paramsInTmplbyPatId, paramsInTmplbyOrdNos, paramsInTmplbyOther, patId, or, dataKey, mstReport.getFacilityCd(), reportInTmplInfo);
      // mod #11127 グループ除外処理の残対応（モニタ、身体情報）　高　start
//      selectReportInfo(reportXml, paramsInTmplGroup, patId, or, dataKey, mstReport.getFacilityCd(), reportInTmplInfo);
      selectReportInfo(reportXml, paramsInTmplGroup, patId, or, dataKey, mstReport.getFacilityCd(), reportInTmplInfo,params);
      // mod #11127 グループ除外処理の残対応（モニタ、身体情報）　高　end
      // mod #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe end
      // add #11226 患者情報系historyの取得条件見直し② limingzhe end
      // add #11172 患者情報系historyの取得条件見直し limingzhe start
      // mod #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe start
      //if(paramsSelectbyMongDB.size()>0 && patId.size()>0){
      if(paramsGroup.get("MongDB").size()>0 && patId.size()>0){
      // mod #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe end
        dataKey.put("patId", patId.get(0));
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
        params = ReportUtils.getParamElements(reportXml);
        // mod #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe start
        //Map<Long, List<Map<String, Object>>> reportInfoIndex = getReportInfo(paramsSelectbyMongDB, dataKeyTemp);
        Map<Long, List<Map<String, Object>>> reportInfoIndex = getReportInfo(paramsGroup.get("MongDB"), dataKeyTemp);
        // mod #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe end
        params = reportServiceImpl.paramsReplaceTmpValue(params, reportInfoIndex);
        // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
        //reportInfoIndex = getChangeList(reportInfoIndex, params);
        reportInfoIndex = reportServiceImpl.getChangeList(reportInfoIndex, params);
        // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
        for (Long key : reportInfoIndex.keySet()) {
          if (reportInfo.containsKey(key)) {
            reportInfo.get(key).addAll(reportInfoIndex.get(key));
          } else {
            reportInfo.put(key, reportInfoIndex.get(key));
          }
        }
        // add #11127 グループ除外処理の残対応（モニタ、身体情報）　高　start
        reportServiceImpl.reportFilterOutUnusedData(params,reportInfo);
        // add #11127 グループ除外処理の残対応（モニタ、身体情報）　高　end
      }
      // add #11172 患者情報系historyの取得条件見直し limingzhe end
      // mod #11226 患者情報系historyの取得条件見直し② limingzhe start
//      if(paramsonlybyPatId.size()>0 && patId.size()>0){
//        dataKey.put("patId", patId.get(0));
//        params = ReportUtils.getParamElements(reportXml);
//        Map<Long, List<Map<String, Object>>> reportInfoIndex = getReportInfo(paramsonlybyPatId, dataKey);
//        params = reportServiceImpl.paramsReplaceTmpValue(params, reportInfoIndex);
//        reportInfoIndex = getChangeList(reportInfoIndex, params);
//        for (Long key : reportInfoIndex.keySet()) {
//          if (reportInfo.containsKey(key)) {
//            reportInfo.get(key).addAll(reportInfoIndex.get(key));
//          } else {
//            reportInfo.put(key, reportInfoIndex.get(key));
//          }
//        }
//      }
//      if(paramsonlybyOrdNos.size()>0 && patId.size()>0 && or.size()>0){
//        Map<Long, List<Long>> patIdOrdList = new HashMap<>();
//        List<Long> ordNos = new ArrayList<>();
//        for (int i = 0; i < patId.size(); i++){
//          if (patId.get(i) == null || or.get(i) == null || or.get(i) == -1) {
//            continue;
//          }
//          ordNos.clear();
//          if(patIdOrdList.containsKey(patId.get(i))) {
//            ordNos = patIdOrdList.get(patId.get(i));
//          }
//          ordNos.add(or.get(i));
//          patIdOrdList.put(patId.get(i), new ArrayList<Long>(new LinkedHashSet<>(ordNos)));
//        }
//        for (Long pId : patIdOrdList.keySet()) {
//          dataKey.put("patId", pId);
//          dataKey.put("ordNos", patIdOrdList.get(pId));
//          params = ReportUtils.getParamElements(reportXml);
//          Map<Long, List<Map<String, Object>>> reportInfoIndex = getReportInfo(paramsonlybyOrdNos, dataKey);
//          params = reportServiceImpl.paramsReplaceTmpValue(params, reportInfoIndex);
//          reportInfoIndex = getChangeList(reportInfoIndex, params);
//          for (Long key : reportInfoIndex.keySet()) {
//            if (reportInfo.containsKey(key)) {
//              reportInfo.get(key).addAll(reportInfoIndex.get(key));
//            } else {
//              reportInfo.put(key, reportInfoIndex.get(key));
//            }
//          }
//          List<Map<String, Object>> reportIndicateResult = reportInfo.get(Long.valueOf("4"));
//          List<Map<String, Object>> reportRealityResult = reportInfo.get(Long.valueOf("74"));
//          List<Map<String, Object>> reportIndicate = reportInfo.get(Long.valueOf("8"));
//          List<Map<String, Object>> reportReality = reportInfo.get(Long.valueOf("97"));
//          if (reportIndicateResult != null && reportIndicateResult.size() > 0){
//            List<Map<String, Object>> midList = reportInfo.get(Long.valueOf("4"));
//            // 施設設定マスタNo.107 投与薬剤表示順 設定値
//            List<FacilitySettingNoDisplayOrder> listDisplayOrder = new ArrayList<>();
//            listDisplayOrder = ordMainDao.selectMedEquipDisplayOrder(mstReport.getFacilityCd());
//            String displayValue = null;
//            String[] keyList = new String[]{};
//            List<String> displayOrderList = new ArrayList<>();
//            for (int x = 0; x < listDisplayOrder.size(); x++) {
//              if ("3007".equals(listDisplayOrder.get(x).getFacilitySettingNo())) {
//                displayValue = listDisplayOrder.get(x).getValue();
//              }
//            }
//            if (displayValue != null) {
//              keyList = displayValue.replace("[","").replace("]","").replace("\"","").split(",");
//            }
//            for(int x = 0;x < keyList.length; x++){
//              switch (keyList[x]){
//                // 登録順
//                case "0":
//                  displayOrderList.add("json_idx");
//                  break;
//                // 薬剤分類順
//                case "1":
//                  displayOrderList.add("med_cls_cd");
//                  break;
//                // 薬剤区分
//                case "2":
//                  displayOrderList.add("medicine_type");
//                  break;
//                // 薬剤マスタ表示順
//                case "3":
//                  displayOrderList.add("med_cd");
//                  displayOrderList.add("med_mix_cd");
//                  break;
//                // 投与時間帯
//                case "4":
//                  displayOrderList.add("med_timing_cd");
//                  break;
//                // 手技
//                case "5":
//                  displayOrderList.add("med_pro_cd");
//                  break;
//                // 投薬パターンコード
//                case "6":
//                  displayOrderList.add("date_interval");
//                  break;
//                default:
//                  break;
//              }
//            }
//
//            int sortSize = displayOrderList.size();
//            int[] compareResultArr = new int[sortSize];
//            String[] colArr = new String[sortSize];
//            for(int x = 0; x < sortSize; x++) {
//              compareResultArr[x]= 0;
//              colArr[x] = displayOrderList.get(x);
//            }
//            // 施設設定マスタNo.107に設定された順番で薬剤を表示する
//            Collections.sort(midList, new Comparator<Map<String, Object>>() {
//              public int compare(Map<String, Object> o1, Map<String, Object> o2) {
//                for (int x = 0, len = sortSize; x < len; x++) {
//                  Integer v1 = (o1.get(colArr[x]) == null || o1.get(colArr[x]) == "") ? 9999999 : Integer.parseInt(o1.get(colArr[x]).toString());
//                  Integer v2 = (o2.get(colArr[x]) == null || o2.get(colArr[x]) == "") ? 9999999 : Integer.parseInt(o2.get(colArr[x]).toString());
//                  compareResultArr[x] = v1.compareTo(v2);
//                  if (compareResultArr[x] != 0){
//                    return compareResultArr[x];
//                  }
//                }
//                return 0;
//              }
//            });
//            reportInfo.put(Long.valueOf("4"), midList);
//          }
//          if (reportIndicate != null && reportIndicate.size() > 0){
//            List<Map<String, Object>> midList = reportInfo.get(Long.valueOf("8"));
//            // 施設設定マスタNo.107 投与薬剤表示順 設定値
//            List<FacilitySettingNoDisplayOrder> listDisplayOrder = new ArrayList<>();
//            listDisplayOrder = ordMainDao.selectMedEquipDisplayOrder(mstReport.getFacilityCd());
//            String displayValue = null;
//            String[] keyList = new String[]{};
//            List<String> displayOrderList = new ArrayList<>();
//            for (int x = 0; x < listDisplayOrder.size(); x++) {
//              if ("3007".equals(listDisplayOrder.get(x).getFacilitySettingNo())) {
//                displayValue = listDisplayOrder.get(x).getValue();
//              }
//            }
//            if (displayValue != null) {
//              keyList = displayValue.replace("[","").replace("]","").replace("\"","").split(",");
//            }
//            for(int x = 0;x < keyList.length; x++){
//              switch (keyList[x]){
//                // 登録順
//                case "0":
//                  displayOrderList.add("json_idx");
//                  break;
//                // 薬剤分類順
//                case "1":
//                  displayOrderList.add("med_cls_cd");
//                  break;
//                // 薬剤区分
//                case "2":
//                  displayOrderList.add("medicine_type");
//                  break;
//                // 薬剤マスタ表示順
//                case "3":
//                  displayOrderList.add("med_cd");
//                  displayOrderList.add("med_mix_cd");
//                  break;
//                // 投与時間帯
//                case "4":
//                  displayOrderList.add("med_timing_cd");
//                  break;
//                // 手技
//                case "5":
//                  displayOrderList.add("med_pro_cd");
//                  break;
//                // 投薬パターンコード
//                case "6":
//                  displayOrderList.add("date_interval");
//                  break;
//                default:
//                  break;
//              }
//            }
//
//            int sortSize = displayOrderList.size();
//            int[] compareResultArr = new int[sortSize];
//            String[] colArr = new String[sortSize];
//            for(int x = 0; x < sortSize; x++) {
//              compareResultArr[x]= 0;
//              colArr[x] = displayOrderList.get(x);
//            }
//            // 施設設定マスタNo.107に設定された順番で薬剤を表示する
//            Collections.sort(midList, new Comparator<Map<String, Object>>() {
//              public int compare(Map<String, Object> o1, Map<String, Object> o2) {
//                for (int x = 0, len = sortSize; x < len; x++) {
//                  Integer v1 = (o1.get(colArr[x]) == null || o1.get(colArr[x]) == "") ? 9999999 : Integer.parseInt(o1.get(colArr[x]).toString());
//                  Integer v2 = (o2.get(colArr[x]) == null || o2.get(colArr[x]) == "") ? 9999999 : Integer.parseInt(o2.get(colArr[x]).toString());
//                  compareResultArr[x] = v1.compareTo(v2);
//                  if (compareResultArr[x] != 0){
//                    return compareResultArr[x];
//                  }
//                }
//                return 0;
//              }
//            });
//            reportInfo.put(Long.valueOf("8"), midList);
//          }
//          if (reportRealityResult != null && reportRealityResult.size() > 0) {
//            List<Map<String, Object>> midList = reportInfo.get(Long.valueOf("74"));
//            // 施設設定マスタNo.106 医材表示順 設定値
//            List<FacilitySettingNoDisplayOrder> listDisplayOrder = new ArrayList<>();
//            listDisplayOrder = ordMainDao.selectMedEquipDisplayOrder(mstReport.getFacilityCd());
//            String displayValue = null;
//            String[] keyList = new String[]{};
//            List<String> displayOrderList = new ArrayList<>();
//            for (int x = 0; x < listDisplayOrder.size(); x++) {
//              if ("3006".equals(listDisplayOrder.get(x).getFacilitySettingNo())) {
//                displayValue = listDisplayOrder.get(x).getValue();
//              }
//            }
//            if (displayValue != null) {
//              keyList = displayValue.replace("[","").replace("]","").replace("\"","").split(",");
//            }
//            for(int x = 0; x < keyList.length; x++){
//              switch (keyList[x]){
//                // 登録順
//                case "0":
//                  displayOrderList.add("json_idx");
//                  break;
//                // 医材分類順
//                case "1":
//                  displayOrderList.add("class_order");
//                  break;
//                // 医材マスタ表示順
//                case "2":
//                  displayOrderList.add("code_order");
//                  break;
//                default:
//                  break;
//              }
//            }
//
//            int sortSize = displayOrderList.size();
//            int[] compareResultArr = new int[sortSize];
//            String[] colArr = new String[sortSize];
//            for(int x = 0; x < sortSize; x++) {
//              compareResultArr[x]= 0;
//              colArr[x] = displayOrderList.get(x);
//            }
//            // 施設設定マスタNo.106に設定された順番で医材を表示する
//            Collections.sort(midList, new Comparator<Map<String, Object>>() {
//              public int compare(Map<String, Object> o1, Map<String, Object> o2) {
//                for (int x = 0, len = sortSize; x < len; x++) {
//                  Integer v1 = (o1.get(colArr[x]) == null || o1.get(colArr[x]) == "") ? 999999 : Integer.parseInt(o1.get(colArr[x]).toString());
//                  Integer v2 = (o2.get(colArr[x]) == null || o2.get(colArr[x]) == "") ? 999999 : Integer.parseInt(o2.get(colArr[x]).toString());
//                  compareResultArr[x] = v1.compareTo(v2);
//                  if (compareResultArr[x] != 0){
//                    return compareResultArr[x];
//                  }
//                }
//                return 0;
//              }
//            });
//            reportInfo.put(Long.valueOf("74"), midList);
//          }
//          if (reportReality != null && reportReality.size() > 0) {
//            List<Map<String, Object>> midList = reportInfo.get(Long.valueOf("97"));
//            // 施設設定マスタNo.106 医材表示順 設定値
//            List<FacilitySettingNoDisplayOrder> listDisplayOrder = new ArrayList<>();
//            listDisplayOrder = ordMainDao.selectMedEquipDisplayOrder(mstReport.getFacilityCd());
//            String displayValue = null;
//            String[] keyList = new String[]{};
//            List<String> displayOrderList = new ArrayList<>();
//            for (int x = 0; x < listDisplayOrder.size(); x++) {
//              if ("3006".equals(listDisplayOrder.get(x).getFacilitySettingNo())) {
//                displayValue = listDisplayOrder.get(x).getValue();
//              }
//            }
//            if (displayValue != null) {
//              keyList = displayValue.replace("[","").replace("]","").replace("\"","").split(",");
//            }
//            for(int x = 0; x < keyList.length; x++){
//              switch (keyList[x]){
//                // 登録順
//                case "0":
//                  displayOrderList.add("json_idx");
//                  break;
//                // 医材分類順
//                case "1":
//                  displayOrderList.add("class_order");
//                  break;
//                // 医材マスタ表示順
//                case "2":
//                  displayOrderList.add("code_order");
//                  break;
//                default:
//                  break;
//              }
//            }
//
//            int sortSize = displayOrderList.size();
//            int[] compareResultArr = new int[sortSize];
//            String[] colArr = new String[sortSize];
//            for(int x = 0; x < sortSize; x++) {
//              compareResultArr[x]= 0;
//              colArr[x] = displayOrderList.get(x);
//            }
//            // 施設設定マスタNo.106に設定された順番で医材を表示する
//            Collections.sort(midList, new Comparator<Map<String, Object>>() {
//              public int compare(Map<String, Object> o1, Map<String, Object> o2) {
//                for (int x = 0, len = sortSize; x < len; x++) {
//                  Integer v1 = (o1.get(colArr[x]) == null || o1.get(colArr[x]) == "") ? 999999 : Integer.parseInt(o1.get(colArr[x]).toString());
//                  Integer v2 = (o2.get(colArr[x]) == null || o2.get(colArr[x]) == "") ? 999999 : Integer.parseInt(o2.get(colArr[x]).toString());
//                  compareResultArr[x] = v1.compareTo(v2);
//                  if (compareResultArr[x] != 0){
//                    return compareResultArr[x];
//                  }
//                }
//                return 0;
//              }
//            });
//            reportInfo.put(Long.valueOf("97"), midList);
//          }
//        }
//        dataKey.put("ordNos", or);
//      }
//      if(paramsOther.size()>0) {
//        for (int i = 0; i < patId.size(); i++) {
//          dataKey.put("ordNo", or.get(i));
//          dataKey.put("patId", patId.get(i));
//          params = ReportUtils.getParamElements(reportXml);
//          Map<Long, List<Map<String, Object>>> reportInfoIndex = getReportInfo(paramsOther, dataKey);
//          List<Map<String, Object>> rec = getPrintedInfo(params, dataKey, reportInfoIndex);
//          reportInfoIndex.put(PRINT_INFO_CODE, rec);
//          params = reportServiceImpl.paramsReplaceTmpValue(params, reportInfoIndex);
//          reportInfoIndex = getChangeList(reportInfoIndex, params);
//          for (Long key : reportInfoIndex.keySet()) {
//            if (reportInfo.containsKey(key)) {
//              reportInfo.get(key).addAll(reportInfoIndex.get(key));
//            } else {
//              reportInfo.put(key, reportInfoIndex.get(key));
//            }
//          }
//        }
//      }
      // mod #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe start
      //selectReportInfo(reportXml, paramsonlybyPatId, paramsonlybyOrdNos, paramsOther, patId, or, dataKey, mstReport.getFacilityCd(), reportInfo);
      // mod #11127 グループ除外処理の残対応（モニタ、身体情報）　高　start
//      selectReportInfo(reportXml, paramsGroup, patId, or, dataKey, mstReport.getFacilityCd(), reportInfo);
      selectReportInfo(reportXml, paramsGroup, patId, or, dataKey, mstReport.getFacilityCd(), reportInfo,params);
      // mod #11276 キー日付に対するデータ引き当て仕様対応 高　start
      // 指示 (paramsGroupInd)
      selectReportInfoIntroductionReportTmplOut(reportXml, paramsGroupInd, dataKey, mstReport.getFacilityCd(), reportInfo);
      // 実績 (paramsGroupRst)
      selectReportInfoIntroductionReportTmplOut(reportXml, paramsGroupRst, dataKey, mstReport.getFacilityCd(), reportInfo);
      // 処方 (paramsGroupIsu)
      selectReportInfoIntroductionReportTmplOut(reportXml, paramsGroupIsu, dataKey, mstReport.getFacilityCd(), reportInfo);
      // 処方(最新) (paramsGroupIsuNew)
      selectReportInfoIntroductionReportTmplOut(reportXml, paramsGroupIsuNew, dataKey, mstReport.getFacilityCd(), reportInfo);
      // mod #11276 キー日付に対するデータ引き当て仕様対応 高　end
      // mod #11127 グループ除外処理の残対応（モニタ、身体情報）　高　end
      // mod #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe end
      // mod #11226 患者情報系historyの取得条件見直し② limingzhe end
    }

    // del #10224 集計紹介状、集計表の出力順について再精査 高 start
//    if(mstReport.getReportType() == 1) {
//      if(reportInfosList != null && reportInfosList.size() > 0){
//        for(Map<Long, List<Map<String, Object>>> reportInfos:reportInfosList) {
//          List<Map<String, Object>> reportInfoList = reportInfos.get(4L);
//          if(null == reportInfoList){
//            reportInfoList = new ArrayList<>();
//          }
//          List<List<Map<String, Object>>> itemList = new ArrayList<>();
//          if ("曜日".equals(params.get(0).getReportXmlTotalTable().getUnitDate())) {
//            Collections.sort(reportInfoList, new Comparator<Map<String, Object>>() {
//              public int compare(Map<String, Object> o1, Map<String, Object> o2) {
//                Integer v1 = Integer.parseInt(o1.get("no").toString());
//                Integer v2 = Integer.parseInt(o2.get("no").toString());
//                int cp1 = v1.compareTo(v2);
//                if (cp1 == 0) {
//                  return 0;
//                } else {
//                  return cp1;
//                }
//              }
//            });
//            List<FacilitySettingNoDisplayOrder> listDisplayOrder = new ArrayList<>();
//            listDisplayOrder = ordMainDao.selectMedEquipDisplayOrder(mstReport.getFacilityCd());
//            String displayValue = null;
//            String[] keyList = new String[]{};
//            List<String> displayOrderList = new ArrayList<>();
//            for (int i = 0; i < listDisplayOrder.size(); i++) {
//              if ("3007".equals(listDisplayOrder.get(i).getFacilitySettingNo())) {
//                displayValue = listDisplayOrder.get(i).getValue();
//              }
//            }
//            if (displayValue != null) {
//              keyList = displayValue.replace("[", "").replace("]", "").replace("\"", "").split(",");
//            }
//            for (int i = 0; i < keyList.length; i++) {
//              switch (keyList[i]) {
//                case "0":
//                  displayOrderList.add("no");
//                  break;
//                case "1":
//                  displayOrderList.add("med_cls_cd");
//                  break;
//                case "2":
//                  displayOrderList.add("medicine_type");
//                  break;
//                case "3":
//                  displayOrderList.add("medicine_type");
//                  displayOrderList.add("med_cd");
//                  break;
//                // 投与時間帯
//                case "4":
//                  displayOrderList.add("med_timing_cd");
//                  break;
//                // 手技
//                case "5":
//                  displayOrderList.add("med_pro_cd");
//                  break;
//                // 投薬パターンコード
//                case "6":
//                  displayOrderList.add("date_interval");
//                  break;
//                default:
//                  break;
//              }
//            }
//            int sortSize = displayOrderList.size();
//            int[] compareResultArr = new int[sortSize];
//            String[] colArr = new String[sortSize];
//            for (int i = 0; i < sortSize; i++) {
//              compareResultArr[i] = 0;
//              colArr[i] = displayOrderList.get(i);
//            }
//            Collections.sort(reportInfoList, new Comparator<Map<String, Object>>() {
//              public int compare(Map<String, Object> o1, Map<String, Object> o2) {
//                for (int i = 0, len = sortSize; i < len; i++) {
//                  Integer v1 = (o1.get(colArr[i]) == null || o1.get(colArr[i]) == "") ? 0 : Integer.parseInt(o1.get(colArr[i]).toString());
//                  Integer v2 = (o2.get(colArr[i]) == null || o2.get(colArr[i]) == "") ? 0 : Integer.parseInt(o2.get(colArr[i]).toString());
//                  compareResultArr[i] = v1.compareTo(v2);
//                  if (compareResultArr[i] != 0) {
//                    return compareResultArr[i];
//                  }
//                }
//                return 0;
//              }
//            });
//          }
//          reportInfos.put(4L, reportInfoList);
//        }
//      }
//    }
    // del #10224 集計紹介状、集計表の出力順について再精査 高 end
    // add ##11152 検査結果(個別)で機能帳票のパラメータに「検査セット」を追加 limingzhe start
    // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
    //List<Map<String, Object>> tmpParm = getPrintedInfo(params, dataKey, new HashMap<>());
    List<Map<String, Object>> tmpParm = reportServiceImpl.getPrintedInfo(params, dataKey, new HashMap<>());
    // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
    // add ##11152 検査結果(個別)で機能帳票のパラメータに「検査セット」を追加 limingzhe end
    Map<String, String> reportOutputInfo = new HashMap<>();
    if ("曜日".equals(params.get(0).getReportXmlTotalTable().getUnitDate()) && mstReport.getReportType() == 1 && !StringUtils.isEmpty(params.get(0).getReportXmlTotalTable().getUnitH())
      && !StringUtils.isEmpty(params.get(0).getReportXmlTotalTable().getUnitV())){
      // mod #11381 【たくしん会】指示.VA情報.画像が日付によって2件目以降表示されないことがある　V1.0B limingzhe start
//      reportOutputInfo = ConvertDataForIntroductionLetterNew(params, reportInfosList, mstReport.getReportType(),dataKey);
      Map<String, Object> dataKeyNew = new HashMap<>();
      try {
        dataKeyNew = deepCopyMap(dataKey);
        if(!StringUtils.isEmpty(specifyFromDate) && !StringUtils.isEmpty(specifyToDate)){
          dataKeyNew.put("fromDate",specifyFromDate);
          dataKeyNew.put("toDate",specifyToDate);
        }
      } catch (IOException e) {
        throw new RuntimeException(e);
      } catch (ClassNotFoundException e) {
        throw new RuntimeException(e);
      }
      // mod #11733 紹介状の集計内訳で縦の単位を複数列にすると正しく繰り返しされない limingzhe start
      //reportOutputInfo = ConvertDataForIntroductionLetterNew(params, reportInfosList, mstReport.getReportType(), dataKeyNew);
      reportOutputInfo = ConvertDataForIntroductionTotal(params, reportInfosList, mstReport.getReportType(), dataKeyNew);
      // mod #11733 紹介状の集計内訳で縦の単位を複数列にすると正しく繰り返しされない limingzhe end
      // mod #11381 【たくしん会】指示.VA情報.画像が日付によって2件目以降表示されないことがある　V1.0B limingzhe end
    }
    else if ("日".equals(params.get(0).getReportXmlTotalTable().getUnitDate()) && mstReport.getReportType() == 1) {
      // del #11103 カテゴリ「印刷情報」の項目追加と修正 sunsy start
      //dataKey.put("report", mstReport);
      // del #11103 カテゴリ「印刷情報」の項目追加と修正 sunsy end
      // mod #11381 【たくしん会】指示.VA情報.画像が日付によって2件目以降表示されないことがある　V1.0B limingzhe start
//      reportOutputInfo = convertDataCodeToIdNew(params, reportInfo, mstReport.getReportClass(), mstReport.getReportType(),
//        patIdToCMap, dataKey, mstReport.getExtractionCondition());
      Map<String, Object> dataKeyNew = new HashMap<>();
      try {
        dataKeyNew = deepCopyMap(dataKey);
        if(!StringUtils.isEmpty(specifyFromDate) && !StringUtils.isEmpty(specifyToDate)){
          dataKeyNew.put("fromDate",specifyFromDate);
          dataKeyNew.put("toDate",specifyToDate);
        }
      } catch (IOException e) {
        throw new RuntimeException(e);
      } catch (ClassNotFoundException e) {
        throw new RuntimeException(e);
      }
      // mod #11733 紹介状の集計内訳で縦の単位を複数列にすると正しく繰り返しされない limingzhe start
      //reportOutputInfo = convertDataCodeToIdNew(params, reportInfo, mstReport.getReportClass(), mstReport.getReportType(),
      //  patIdToCMap, dataKeyNew, mstReport.getExtractionCondition());
      reportOutputInfo = ConvertDataForIntroductionTotal(params, reportInfosList, mstReport.getReportType(), dataKeyNew);
      // mod #11733 紹介状の集計内訳で縦の単位を複数列にすると正しく繰り返しされない limingzhe end
      // mod #11381 【たくしん会】指示.VA情報.画像が日付によって2件目以降表示されないことがある　V1.0B limingzhe end
    }
    else {
      dataKey.put("report", mstReport);
      // mod #11226 患者情報系historyの取得条件見直し② limingzhe start
      //reportOutputInfo = convertDataCodeToId(params, reportInfo, mstReport.getReportClass(), mstReport.getReportType(),
      //  patIdToCMap, dataKey, mstReport.getExtractionCondition());
      reportOutputInfo = convertDataCodeToId(params, reportInfo, reportInTmplInfo, keyfilteredList, mstReport.getReportClass(), mstReport.getReportType(),
        patIdToCMap, dataKey, mstReport.getExtractionCondition());
      // mod #11226 患者情報系historyの取得条件見直し② limingzhe end
    }
    reportOutputInfo = sortByKeyB(sortByKeyA(reportOutputInfo));
    if(null != dataKey.get("IntroLetterReportPrinte") && (Boolean)dataKey.get("IntroLetterReportPrinte")){
      Map<String,Object> htmlCheckMap = (Map<String,Object>)dataKey.get("htmlTemplate");
      Map<String,Object> jumpMap = new HashMap<>(htmlCheckMap);
      Map<String, String> groupIds =params.stream()
        .filter(param -> param.getRepeatAddress().split(",").length>1)
        .collect(Collectors.toMap(ReportXmlParam::getId,ReportXmlParam::getRepeatAddress));
      for (Map.Entry<String,String> repentry : reportOutputInfo.entrySet()) {
        String realyKey = "";
        if (repentry.getKey().contains("-")) {
          if (repentry.getKey().contains(".")) {
            Workbook wb = getReportWorkbook(mstReport, reportZipFile);
            Sheet wb2 = wb.getSheet("パラメータ");
            String key1 = repentry.getKey().split("\\.")[1];
            //  String key2 = key1.split("-")[0];
            Cell targetCell = ReportUtils.getFirstCell(wb2, key1);
            // String key3 = key1.split("-")[1];
            realyKey = targetCell.getAddress().toString();
          } else {
            String key1 = repentry.getKey().split("-")[0].split("#")[1];
            String key2 = repentry.getKey().split("-")[1];
            if (groupIds.containsKey(key1)) {
              realyKey = groupIds.get(key1).split(",")[Integer.valueOf(key2) - 1];
            }
          }
        }
        if (repentry.getKey().contains("$")) {
          realyKey = repentry.getKey().split("\\$")[0];
        }
        for (Map.Entry<String, Object> entry : htmlCheckMap.entrySet()) {
          if (realyKey.equals(entry.getKey())) {
            reportOutputInfo.put(repentry.getKey(), entry.getValue().toString());
          }
        }
      }
      for (Map.Entry<String,Object> entry : jumpMap.entrySet()) {
        reportOutputInfo.put(entry.getKey(),entry.getValue().toString());
      }
    }
    Map<String, String> calcResult = new HashMap<>();
    // mod #11951 紹介状画面でカテゴリ「処方(最新)」が出力されなくなっている 高 start
//    if(reportInfo.size() == 0){
    if(reportInfo.size() == 0 && reportInfosList.size() != 0){
      // mod #11951 紹介状画面でカテゴリ「処方(最新)」が出力されなくなっている 高 end
      reportInfo = reportInfosList.get(0);
    }
    // mod #10446 テンプレート繰返しでの計算式繰返しの制限事項対応②（「=」で始まる計算式） limingzhe start
    reportServiceImpl.formulaCalculateForParams(params, reportInfo, reportInTmplInfo, reportOutputInfo, calcResult);
    // mod #10446 テンプレート繰返しでの計算式繰返しの制限事項対応②（「=」で始まる計算式） limingzhe end
    // mod #11260 テンプレート設定した帳票の出力で高負荷になることがある 房 start
//    Path excelPath = null;
//    try(Workbook wb = reportService.getReportExcelWorkbook(mstReport, reportZipFile, params, reportOutputInfo, calcResult, ordNo, dataKey, getColWidth, getRowHeight)) {
//      wb.setForceFormulaRecalculation(true);
//      // 一時ファイルに出力
//      excelPath = tmpFileService.createTmpDirectoryAndFile(createTmpDir, "nkk-report", ".xlsx");
//      try (OutputStream os = new FileOutputStream(excelPath.toFile())) {
//        wb.write(os);
//      }
//      return Files.readAllBytes(excelPath);
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
    try{
      // mod #12324 紹介状の出力時にpat_eventを参照する zhao start
      //com.aspose.cells.Workbook wb = reportWithAsposeApiService.getReportExcelWorkbook(mstReport, reportZipFile, params, reportOutputInfo, calcResult, ordNo, dataKey, getColWidth, getRowHeight);
      com.aspose.cells.Workbook wb = new com.aspose.cells.Workbook();
      if(dataKey.containsKey("moveFlag")){
        List<Map<String, String>> reportOutputInfoList = new ArrayList<>();
        editLetterInfoForScreenDisplay(reportOutputInfoList, dataKey);
        wb = reportWithAsposeApiService.getReportExcelWorkbookForIntroductionReport(mstReport, reportZipFile, params,
          reportOutputInfoList, calcResult, null, dataKey, getColWidth, getRowHeight);
      } else {
        wb = reportWithAsposeApiService.getReportExcelWorkbook(mstReport, reportZipFile, params, reportOutputInfo,
          calcResult, ordNo, dataKey, getColWidth, getRowHeight);
      }
      // mod #12324 紹介状の出力時にpat_eventを参照する zhao end
      wb.calculateFormula(true);
      ByteArrayOutputStream o = new ByteArrayOutputStream();
      wb.save(o, SaveFormat.XLSX);
      wb.dispose();
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
//    finally {
//      // 一時ファイルを削除
//      Optional.ofNullable(excelPath).ifPresent(path -> path.toFile().delete());
//    }
    // mod #11260 テンプレート設定した帳票の出力で高負荷になることがある 房 end
  }
  // add #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe start
  @Override
  public byte[] getReportExcelFileForIntroductionReportbyHTMLPrint(Long reportCd, Map<String, Object> dataKey) {
    // mod #12650 登録済み紹介状が帳票マスタ削除の影響を受けるのは不適切 zhao start
    //MstReport mstReport = mstReportDao.selectByCd(reportCd);
    MstReport mstReport = mstReportDao.selectByReportCd(reportCd);
    // mod #12650 登録済み紹介状が帳票マスタ削除の影響を受けるのは不適切 zhao end
    // add #12650 登録済み紹介状が帳票マスタ削除の影響を受けるのは不適切 zhao start
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
    // add #12650 登録済み紹介状が帳票マスタ削除の影響を受けるのは不適切 zhao end

    // S3から帳票定義XML、帳票デザインExcelが格納されたZipファイルを取得する
    ReportZipFile reportZipFile = getReportZip(mstReport);

    // SqlCodeをもとに帳票に出力する情報を取得する
    String reportXml = getReportXml(mstReport, reportZipFile);
    List<ReportXmlParam> params = ReportUtils.getParamElements(reportXml);
    // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
    //List<Map<String, Object>> tmpParm = getPrintedInfo(params, dataKey, new HashMap<>());
    List<Map<String, Object>> tmpParm = reportServiceImpl.getPrintedInfo(params, dataKey, new HashMap<>());
    // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end

    Map<String, String> reportOutputInfo = new HashMap<>();
    if(null != dataKey.get("IntroLetterReportPrinte") && (Boolean)dataKey.get("IntroLetterReportPrinte")){
      Map<String,Object> htmlCheckMap = (Map<String,Object>)dataKey.get("htmlTemplate");
      Map<String,Object> jumpMap = new HashMap<>(htmlCheckMap);
      Map<String, List<ReportXmlParam>> mapParam = params.stream()
        .collect(Collectors.groupingBy(item -> item.getId()));
      for (Map.Entry<String,Object> entry : jumpMap.entrySet()) {
        String itemValue = entry.getValue().toString();
        if(mapParam.keySet().contains(entry.getKey()) && !itemValue.equals("")){
//          ReportXmlParam itemParam = mapParam.get(entry.getKey()).get(0);
//          if(!"1".equals(itemParam.getIsShrink())&& !itemParam.getDispLength().isEmpty() && !"0".equals(itemParam.getDispLength())){
//            if (itemValue != null && itemValue.contains("\uFEFF")) {
//              itemValue = itemValue.replace("\uFEFF", "");
//            }
//            if(itemValue.contains("\n")){
//              itemValue = itemValue.replace("\n","#b");
//            }
//            int dispLength = Integer.parseInt(itemParam.getDispLength());
//            String resultVal = "";
//            if(itemValue.contains("#b")){
//              String [] valArr = itemValue.split(("#b"));
//              String[] newArr ;
//              if("".equals(valArr[0])){
//                newArr = new String[valArr.length - 1];
//                System.arraycopy(valArr, 1, newArr, 0, newArr.length);
//              }else{
//                newArr = valArr;
//              }
//
//              for(int i = 0; i < newArr.length ; i++){
//                int itemByteLength = byteLength(newArr[i]);
//                if(i>0){
//                  resultVal += "#b";
//                }
//                if(itemByteLength < dispLength){
//                  resultVal += padStringToByteLength(newArr[i], itemByteLength, dispLength, ' ');
//                }else{
//                  if(itemByteLength/dispLength > 0 && itemByteLength%dispLength >0){
//                    resultVal += padStringToByteLength(newArr[i], itemByteLength,dispLength*(itemByteLength/dispLength+1) , ' ');
//                  }else{
//                    resultVal += newArr[i];
//                  }
//                }
//              }
//              itemValue = resultVal;
//            }
//            itemValue = itemValue.replace("\n","");
//            String jumpItemValue = itemValue.replaceAll("#b","");
//            int itemByteLength = byteLength(jumpItemValue);
//            if (itemValue != null && itemByteLength > Integer.parseInt(itemParam.getDispLength()) && null != itemParam.getRowCount() && !itemParam.getRowCount().equals("") && Integer.valueOf(itemParam.getRowCount()) > 0) {
//              StringBuffer stringBuffer = new StringBuffer();
//              stringBuffer.append(jumpItemValue.substring(0, strLentgh(jumpItemValue, dispLength)));
//              stringBuffer.append("\n");
//              itemValue = jumpItemValue.substring(0, strLentgh(jumpItemValue, dispLength));
//            }
//          }
        }
        reportOutputInfo.put(entry.getKey(), itemValue);
      }
    }
    try{
      com.aspose.cells.Workbook wb = reportWithAsposeApiService.getReportExcelWorkbookbyHTMLPrint(mstReport, reportZipFile, params, reportOutputInfo, dataKey);
      wb.calculateFormula(true);
      ByteArrayOutputStream o = new ByteArrayOutputStream();
      wb.save(o, SaveFormat.XLSX);
      wb.dispose();
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
  // add #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe end
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

  private  List<Long> getOrdNoList(List<OrdMainTreatDate> ordMainTreatDateList) {
    List<Long> listOrd = new ArrayList<>();
    for (OrdMainTreatDate ord : ordMainTreatDateList) {
      listOrd.add(ord.getOrdNo());
    }
    return  listOrd;
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
    if (sqlCodes.contains("16")||sqlCodes.contains(159)) {
      dataKey.remove("patId");
    }
    if (sqlCodes.contains("115") || sqlCodes.contains("116")){
      if (!dataKey.containsKey("ordNo")) {
        dataKey.put("ordNo", dataKey.get("ordNos"));
      }
    }
    // add ##11152 検査結果(個別)で機能帳票のパラメータに「検査セット」を追加 limingzhe start
    if (sqlCodes.contains("197")){
      if (!dataKey.containsKey("selectExamSetCd")) {
        dataKey.put("selectExamSetCd", -1);
      }
    }
    // add ##11152 検査結果(個別)で機能帳票のパラメータに「検査セット」を追加 limingzhe end
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

  /**
   * yyyyMMdd -> yyyy/MM/dd
   * @param yyyymmdd
   * @return
   */
  private String dateStr2dispDateStr(String yyyymmdd) {
    if (yyyymmdd.length() == 8) {
      String year = yyyymmdd.substring(0,4);
      String month = yyyymmdd.substring(4,6);
      String day = yyyymmdd.substring(6);
      String treatDateFormatted = year + "/" + month + "/" + day;
      return treatDateFormatted;
    } else {
      return yyyymmdd;
    }
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

  /**
   * 日付型の判定処理
   * @param value
   * @return
   */
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
  public static boolean isDate(String value, LogService logService){
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    SimpleDateFormat sdf = null;
    ParsePosition pos = new ParsePosition(0);

    if(value == null){
      return false;
    }
    try {
      value = value.replaceAll("[^0-9]","");
      if(value.length()>8){
        value = value.substring(0,8);
      }
      sdf = new SimpleDateFormat("yyyyMMdd");
      sdf.setLenient(false);
      Date date = sdf.parse(value,pos);
      if(date == null){
        return false;
      }else{
        if(pos.getIndex() > sdf.format(date).length()){
          return false;
        }
        return true;
      }
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      if (logService != null) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      return false;
    }
  }

  /**
   * 日付型のフォーマット処理
   * @param value
   * @return
   */
  public static String DateFormat(String value){
    value = value.replaceAll("[^0-9]","");
    if(value.length()>8) {
      value = value.substring(0, 8);
    }
    return value;
  }

  /**
   * 曜日取得
   * @param datetime
   * @return
   */
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
  public static String dateToWeek(String datetime, LogService logService) {
    if(!isDate(datetime,logService)){
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
      return datetime;
    }
    // add Aspose.cells関連問題対応 修正 商 start
    datetime = datetime.replace("-", "").replace("/", "");
    // add Aspose.cells関連問題対応 修正 商 end
    SimpleDateFormat f = new SimpleDateFormat("yyyyMMdd");
    String[] weekDays = {"日", "月", "火", "水", "木", "金", "土"};
    Calendar cal = Calendar.getInstance();
    Date date;
    try {
      date = f.parse(datetime);
      cal.setTime(date);
    } catch (ParseException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      if (logService != null) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    }

    int w = cal.get(Calendar.DAY_OF_WEEK) - 1;
    if (w < 0)
      w = 0;
    return weekDays[w];
  }

  private Map<String, String> ConvertDataForIntroductionLetterNew(List<ReportXmlParam> params, List<Map<Long, List<Map<String, Object>>>> reportOutputInfoList, Integer reportType, Map<String, Object> dataKey){
    Map<String, String> result = new HashMap<>();

    String unitH = params.get(0).getReportXmlTotalTable().getUnitH();

    String unitV = params.get(0).getReportXmlTotalTable().getUnitV();

    String conversion = params.get(0).getReportXmlTotalTable().getConversion();
    Integer repeatCountV = params.get(0).getReportXmlTmplRepeat().getRepeatCountV();

    Integer repeatCountH = params.get(0).getReportXmlTmplRepeat().getRepeatCountH();

    Integer isNewPage =  params.get(0).getReportXmlTmplRepeat().getIsNewPage();

    String tmplRepeatId = params.get(0).getReportXmlTmplRepeat().getId();

    String tmplRepeatDirection = params.get(0).getReportXmlTmplRepeat().getDirection();

    // add 11011 集計内訳タブ仕様変更 高 start
    String addressNewUnitV = params.get(0).getReportXmlTotalTable().getUnitVAddress();

    String addressNewUnitH = params.get(0).getReportXmlTotalTable().getUnitHAddress();
    // add 11011 集計内訳タブ仕様変更 高 end
    List<ReportXmlParam> tmplInfo = params.stream().filter(item -> tmplRepeatId.equals(item.getId())).collect( Collectors.toCollection(ArrayList::new));

    Map<String, List<ReportXmlParam>> groupedParams = params.stream()
      .filter(p -> !StringUtils.isEmpty(p.getId()))
      .collect(Collectors.groupingBy(p -> p.getSqlCode()));

    for(Map<Long, List<Map<String, Object>>> reportOutputInfo :reportOutputInfoList) {
      // filter data
      groupedParams.entrySet().forEach(groupedParam -> {
        Long sqlCode;
        if (null != groupedParam.getKey() && groupedParam.getKey().equals("")) {
          sqlCode = Long.valueOf(0);
        } else {
          sqlCode = Long.valueOf(groupedParam.getKey());
        }
        List<Map<String, Object>> tmpList = reportOutputInfo.get(sqlCode);
        if (null == tmpList) {
          tmpList = new ArrayList<>();
        }
        List<Map<String, Object>> finalTmpList = tmpList;
        groupedParam.getValue().stream()
          .filter(param -> !StringUtils.isEmpty(param.getGroupId()) && !param.isTmplRepeat())
          .forEach(param -> {
            // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
            //List<Map<String, Object>> filteredList = filterReportInfo(param, finalTmpList);
            List<Map<String, Object>> filteredList = reportServiceImpl.filterReportInfo(param, finalTmpList);
            // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
            reportOutputInfo.put(sqlCode, filteredList);
          });
      });

      List<String> mediCdNo = new ArrayList<>();
      int pageSizel = 0;
      if ("合　計".equals(tmplInfo.get(0).getReportXmlTotalTable().getContents()) || "平均値".equals(tmplInfo.get(0).getReportXmlTotalTable().getContents()) ||
        "最大値".equals(tmplInfo.get(0).getReportXmlTotalTable().getContents()) || "最小値".equals(tmplInfo.get(0).getReportXmlTotalTable().getContents())) {
        pageSizel = reportOutputInfo.get(Long.valueOf(tmplInfo.get(0).getSqlCode())).stream().mapToInt(map ->{
          if (!mediCdNo.contains(map.get(unitH))) {
            mediCdNo.add(map.get(unitH).toString());
            return 1;
          }
          return 0;
        }).sum();
      } else {
        pageSizel = reportOutputInfo.get(Long.valueOf(tmplInfo.get(0).getSqlCode())).stream().mapToInt(map ->{
          if (map.containsKey("no") ) {
            if (!mediCdNo.contains(map.get("no") + "z_z" + map.get(unitH))) {
              mediCdNo.add(map.get("no") + "z_z" + map.get(unitH));
              return 1;
            }
          } else {
            if (!mediCdNo.contains(map.get(unitH))) {
              mediCdNo.add(map.get(unitH).toString());
              return 1;
            }
          }
          return 0;
        }).sum();
      }

      Set<String> weeks = new HashSet<>();
      List<String> sortWeeks = new ArrayList<>();

      List<OrdMain> weekOrdMain = ordMainDao.selectPatOrdMainBetweenTreatDate(
        Long.parseLong(String.valueOf(dataKey.get("patId"))), dataKey.get("facilityCd").toString(),
        String.valueOf(dataKey.get("fromDate")).replace("/", "").replace("-", ""),
        String.valueOf(dataKey.get("toDate")).replace("/", "").replace("-", ""));
      for (OrdMain ordMain : weekOrdMain) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
        weeks.add(dateToWeek(ordMain.getTreatDate(),logService));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
      }
      if (weeks.contains("月")) {
        sortWeeks.add("月");
      }
      if (weeks.contains("火")) {
        sortWeeks.add("火");
      }
      if (weeks.contains("水")) {
        sortWeeks.add("水");
      }
      if (weeks.contains("木")) {
        sortWeeks.add("木");
      }
      if (weeks.contains("金")) {
        sortWeeks.add("金");
      }
      if (weeks.contains("土")) {
        sortWeeks.add("土");
      }
      if (weeks.contains("日")) {
        sortWeeks.add("日");
      }

      Integer page = 1;
      Integer pageH = 1;
      Integer pageV = 1;
      if(isNewPage == 1){
        if(weeks.size() > repeatCountH){
          if (weeks.size() % repeatCountH == 0) {
            pageH = weeks.size()/repeatCountH;
          } else {
            pageH = weeks.size()/repeatCountH + 1;
          }
        }
        if(pageSizel > repeatCountV){
          if (pageSizel % repeatCountV == 0) {
            pageV = pageSizel/repeatCountV;
          } else {
            pageV = pageSizel/repeatCountV + 1;
          }
        }
        page = pageH * pageV;
      }
      Integer finalPage = page <= 0 ? 1 : page;
      List<String> weekRepeatNames = new ArrayList<>();
      List<String> mediCdNoList = new ArrayList<>();
      if (pageSizel > repeatCountV) {
        // treat_date
        // N
        if ("0".equals(tmplRepeatDirection)) {
          for (int q = 0; q < pageH; q++) {
            List<String> subList = new ArrayList<>();
            if (((q + 1) * repeatCountH) > sortWeeks.size()) {
              subList.addAll(sortWeeks.subList(q * repeatCountH, sortWeeks.size()));
              int nullCount = subList.size();
              for (int e = 0; e < repeatCountH - nullCount; e++) {
                subList.add("null");
              }
            } else {
              subList = sortWeeks.subList(q * repeatCountH, (q + 1) * repeatCountH);
            }
            for (int l = 0; l < pageV; l++) {
              for (String a : subList) {
                weekRepeatNames.add(a);
              }
            }
          }
          // medi_name
          for (int l = 0; l < pageH; l++) {
            for (int q = 0; q < pageV; q++) {
              List<String> subList = new ArrayList<>();
              if (((q + 1) * repeatCountV) > mediCdNo.size()) {
                subList.addAll(mediCdNo.subList(q * repeatCountV, mediCdNo.size()));
                int nullCount = subList.size();
                for (int e = 0; e < repeatCountV - nullCount; e++) {
                  subList.add("null");
                }
              } else {
                subList = mediCdNo.subList(q * repeatCountV, (q + 1) * repeatCountV);
              }
              for (String a : subList) {
                mediCdNoList.add(a);
              }
            }
          }
        } else {
          // Z
          // treat_date
          for (int l = 0; l < pageV; l++) {
            for (int q = 0; q < pageH; q++) {
              List<String> subList = new ArrayList<>();
              if (((q + 1) * repeatCountH) > sortWeeks.size()) {
                subList.addAll(sortWeeks.subList(q * repeatCountH, sortWeeks.size()));
                int nullCount = subList.size();
                for (int e = 0; e < repeatCountH - nullCount; e++) {
                  subList.add("null");
                }
              } else {
                subList = sortWeeks.subList(q * repeatCountH, (q + 1) * repeatCountH);
              }
              for (String a : subList) {
                weekRepeatNames.add(a);
              }
            }
          }
          // medi_name
          for (int q = 0; q < pageV; q++) {
            List<String> subList = new ArrayList<>();
            if (((q + 1) * repeatCountV) > mediCdNo.size()) {
              subList.addAll(mediCdNo.subList(q * repeatCountV, mediCdNo.size()));
              int nullCount = subList.size();
              for (int e = 0; e < repeatCountV - nullCount; e++) {
                subList.add("null");
              }
            } else {
              subList = mediCdNo.subList(q * repeatCountV, (q + 1) * repeatCountV);
            }
            for (int l = 0; l < pageH; l++) {
              for (String a : subList) {
                mediCdNoList.add(a);
              }
            }
          }
        }
      } else {
        for (int l = 0; l < pageH; l++) {
          for (String a : mediCdNo) {
            mediCdNoList.add(a);
          }
          for (int i =0; i < repeatCountV - pageSizel; i++) {
            mediCdNoList.add("null");
          }
        }
        weekRepeatNames.addAll(sortWeeks);
      }
      int repeatH = 0;
      int repeatV = 0;
      if (mediCdNo.size() >= repeatCountV) {
        repeatV = repeatCountV;
      } else {
        repeatV = mediCdNo.size();
      }
      int  finalRepeatV = repeatV <= 0 ? 1 : repeatV;
      if (sortWeeks.size() > repeatCountH) {
        repeatH = repeatCountH;
      } else {
        repeatH = sortWeeks.size();
      }
      int finalRepeatH = repeatH <= 0 ? 1 : repeatH;
      List<String> finalSortWeeks = weekRepeatNames;
      List<String> finalmediCdNo = mediCdNoList;
      groupedParams.entrySet().forEach(groupedParam -> {
        Long sqlCode;
        if (null != groupedParam.getKey() && groupedParam.getKey().equals("")) {
          sqlCode = Long.valueOf(0);
        } else {
          sqlCode = Long.valueOf(groupedParam.getKey());
        }
        List<Map<String, Object>> tmpList = reportOutputInfo.get(sqlCode);
        if (null == tmpList) {
          tmpList = new ArrayList<>();
        }
        List<Map<String, Object>> tmpListItem = tmpList;
        Map<String, Object> tmpMap = new HashMap<>();
        if(!tmpList.isEmpty()) {
          tmpMap = tmpList.get(0);
        }
        Map<String, Object> finalTmpMap = tmpMap;

        // templ
        List<Map<String, Object>> finalTmpList = tmpList;
        groupedParam.getValue().stream()
          .filter(param -> param.isTmplRepeat())
          .forEach(param -> {
            int repeatHCount = 0;
            int repeatVCount = 0;
            for(int i = 0 ; i < finalPage ; i++){
              if (dataKey.get("newPageCountFlag") != null && (i + 1) > 1) {
                break;
              }
              for (int j = 0; j < finalRepeatH; j++) {
                if (repeatHCount >= finalSortWeeks.size()) {
                  break;
                }
                for (int k = 0; k < finalRepeatV; k++) {
                  String pageStr = String.format("%d%s", i + 1, MULTIPLE_PAGES_SEPARATOR);
                  String key = String.format("%s%s-%d.%s-%d", pageStr, param.getId() , j, param.getId(), k + 1);
                  if (j + repeatCountH * i >= finalSortWeeks.size() || k + repeatCountV * i >= finalmediCdNo.size()) {
                    break;
                  }
                  String week = finalSortWeeks.get(j + repeatCountH * i);
                  String mediCd = finalmediCdNo.get(k + repeatCountV * i);
                  if (null == week || "null".equals(week) || null == mediCd || "null".equals(mediCd)) {
                    break;
                  }
                  String value =  "";
                  if ("項目値".equals(param.getReportXmlTotalTable().getContents())) {
                    Map<String, Object> mapValue = finalTmpList.stream().filter(tmp ->
                      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
                      week.equals(dateToWeek(String.valueOf(tmp.get(unitV)),logService)) && (tmp.containsKey("no") ? mediCd.equals(tmp.get("no") + "z_z" + tmp.get(unitH)) : mediCd.equals(tmp.get(unitH)))
                      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
                    ).findFirst().orElse(null);
                    value = String.valueOf(mapValue == null ? "" : mapValue.get(tmplInfo.get(0).getDataCode()));
                  } else {
                    if ("合　計".equals(param.getReportXmlTotalTable().getContents())) {
                      double valueSum = 0D;
                      List<Map<String, Object>> sumList = finalTmpList.stream().filter(tmp ->
                          // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
                          week.equals(dateToWeek(String.valueOf(tmp.get(unitV)),logService)) && mediCd.equals(tmp.get(unitH))
                        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
                      ).collect(Collectors.toList());
                      if (null != sumList && sumList.size() > 0) {
                        valueSum = sumList.stream().mapToDouble(map -> Double.valueOf(map.get(tmplInfo.get(0).getDataCode()).toString())).sum();
                      }
                      value = String.valueOf(valueSum);
                    } else if ("平均値".equals(param.getReportXmlTotalTable().getContents())) {
                      double valueAvg = 0D;
                      String valueAvgStr = "";
                      List<Map<String, Object>> averageList = finalTmpList.stream().filter(tmp ->
                        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
                        week.equals(dateToWeek(String.valueOf(tmp.get(unitV)),logService)) && mediCd.equals(tmp.get(unitH))
                        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
                      ).collect(Collectors.toList());
                      if (null !=averageList && averageList.size() > 0) {
                        int count = 0;
                        for (Map<String, Object> map : averageList) {
                          valueAvg += Double.valueOf(map.get(tmplInfo.get(0).getDataCode()).toString());
                          count++;
                        }
                        DecimalFormat df = new DecimalFormat("#.##");
                        if (count > 0) {
                          valueAvgStr = df.format(valueAvg / count);
                        }
                      }
                      value = valueAvgStr;
                    } else if ("最大値".equals(param.getReportXmlTotalTable().getContents())) {
                      OptionalDouble valueMax = null;
                      List<Map<String, Object>> maxList = finalTmpList.stream().filter(tmp ->
                        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
                        week.equals(dateToWeek(String.valueOf(tmp.get(unitV)),logService)) && mediCd.equals(tmp.get(unitH))
                        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
                      ).collect(Collectors.toList());
                      if (null != maxList && maxList.size() > 0) {
                        valueMax = maxList.stream().mapToDouble(map -> Double.valueOf(map.get(tmplInfo.get(0).getDataCode()).toString())).max();
                      }
                      value = String.valueOf(valueMax == null ? "" : valueMax.getAsDouble());
                    } else if ("最小値".equals(param.getReportXmlTotalTable().getContents())) {
                      OptionalDouble valueMin = null;
                      List<Map<String, Object>> minList = finalTmpList.stream().filter(tmp ->
                        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
                        week.equals(dateToWeek(String.valueOf(tmp.get(unitV)),logService)) && mediCd.equals(tmp.get(unitH))
                        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
                      ).collect(Collectors.toList());
                      if (null != minList && minList.size() > 0) {
                        valueMin = minList.stream().mapToDouble(map -> Double.valueOf(map.get(tmplInfo.get(0).getDataCode()).toString())).min();
                      }
                      value = String.valueOf(valueMin == null ? "" : valueMin.getAsDouble());
                    }
                  }
                  if (!StringUtils.isEmpty(value) && !"0.0".equals(value)) {
                    if (!StringUtils.isEmpty(conversion) && "項目値".equals(param.getReportXmlTotalTable().getContents())) {
                      value = conversion;
                    }
                    result.put(key, value);
                  }
                  repeatVCount++;
                }
                repeatHCount ++;
              }
            }
          });

        // Group
        groupedParam.getValue().stream()
          .filter(param -> !StringUtils.isEmpty(param.getGroupId()) && !param.isTmplRepeat())
          .forEach(param -> {
            // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
            //List<Map<String, Object>> filteredList = filterReportInfo(param, tmpListItem);
            List<Map<String, Object>> filteredList = reportServiceImpl.filterReportInfo(param, tmpListItem);
            // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
            ReportXmlGroup group = param.getReportXmlGroup();
            // ページ数分、以下の処理を行う
            Integer repeatMax = (group != null && group.getRepeatMax() != null) ? group.getRepeatMax() : 1;
            int treateDateRepeat = 0;
            List<String> repeatCircle = new ArrayList<>();
            List<String> repeatCircleMedic = new ArrayList<>();
            repeatCircle.addAll(finalSortWeeks);
            repeatCircleMedic.addAll(finalmediCdNo);
            for (Integer pageCount = 0; pageCount < finalPage; pageCount++) {
              if (dataKey.get("newPageCountFlag") != null && (pageCount + 1) > 1) {
                break;
              }

              List<Map<String, Object>> outputInfos = filteredList;
              int n=0;
              List<ReportXmlFilterTable> filters = param.getReportXmlFilters();
              String value = "";
              String key = "";
              // mod 11011 集計内訳タブ仕様変更 高 start
//              if (unitV.equals(param.getDataCode())) {
              if (unitV.equals(param.getDataCode()) && param.getRepeatAddress().indexOf(addressNewUnitV) != -1) {
                // mod 11011 集計内訳タブ仕様変更 高 end
                for (int w = 0; w < repeatCountH; w++) {
                  int nullCount = repeatCircle.size();
                  boolean isNextPage = false;
                  for (int i = 0; i < nullCount; i++) {
                    if (!"null".equals(repeatCircle.get(0))) {
                      break;
                    }
                    repeatCircle.remove(0);
                    isNextPage = true;
                  }
                  if (repeatCircle.size() <= 0 || isNextPage) {
                    break;
                  }
                  String pageStr = String.format("%d%s", pageCount + 1, MULTIPLE_PAGES_SEPARATOR);
                  key = String.format("%s%s-%d", pageStr, param.getId(), w + 1);
                  value = repeatCircle.get(0);
                  result.put(key, value);
                  treateDateRepeat++;
                  repeatCircle.remove(0);
                }
              } else if (unitH.equals(param.getDataCode())) {
                for (int w = 0; w < repeatCountV; w++) {
                  int nullCount = repeatCircleMedic.size();
                  boolean isNextPage = false;
                  for (int i = 0; i < nullCount; i++) {
                    if (!"null".equals(repeatCircleMedic.get(0))) {
                      break;
                    }
                    repeatCircleMedic.remove(0);
                    isNextPage = true;
                  }
                  if (repeatCircleMedic.size() <= 0 || isNextPage) {
                    break;
                  }
                  String pageStr = String.format("%d%s", pageCount + 1, MULTIPLE_PAGES_SEPARATOR);
                  key = String.format("%s%s-%d", pageStr, param.getId(), w + 1);
                  if ("項目値".equals(param.getReportXmlTotalTable().getContents())) {
                    if (repeatCircleMedic.get(0).contains("z_z")) {
                      value = repeatCircleMedic.get(0).split("z_z")[1];
                    } else {
                      value = repeatCircleMedic.get(0);
                    }
                  } else {
                    value = repeatCircleMedic.get(0);
                  }
                  // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                  //value = convertValue(param, value);
                  value = reportServiceImpl.convertValue(param, value);
                  // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                  result.put(key, value);
                  repeatCircleMedic.remove(0);
                }
              }
            }
            // mod 11011 集計内訳タブ仕様変更 高 start
//            if (!unitV.equals(param.getDataCode()) && !unitH.equals(param.getDataCode())){
            if ((!unitV.equals(param.getDataCode()) && !unitH.equals(param.getDataCode())) || (unitV.equals(param.getDataCode()) &&  param.getRepeatAddress().indexOf(addressNewUnitV) == -1) || (unitH.equals(param.getDataCode()) &&  param.getRepeatAddress().indexOf(addressNewUnitH) == -1)){
              // mod 11011 集計内訳タブ仕様変更 高 end
              // 1ページの繰り返し件数を取得する
              Integer repeatOfPage;
              if (group != null && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_YES) {
                repeatOfPage = (filteredList.size() > group.getRepeatMax()) ? group.getRepeatMax() : filteredList.size();
              } else {
                repeatOfPage = filteredList.size();
              }
              Integer pageMAX = repeatOfPage > 0 ? filteredList.size() / repeatOfPage : 0;
              // ページ数分、以下の処理を行う
              int limitCount = repeatOfPage;
              for (Integer pageCount = 0; pageCount <= pageMAX; pageCount++) {
                if (dataKey.get("newPageCountFlag") != null && (pageCount + 1) > 1) {
                  break;
                }
                int skipCount = pageCount * limitCount;
                // id属性値をkey、出力値をvalue に設定する（複数項目の場合、id属性値に連番を付加する）
                List<Map<String, Object>> outputInfos = filteredList.stream().skip(skipCount).limit(repeatMax).collect(toList());
                int n=0;
                String value = "";
                String key = "";
                if (group != null && group.getRepeatMax() <= 1) {
                  for (Integer i = 0; i < outputInfos.size(); i++) {
                    key = param.getId();
                    // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                    //value = formatValue(param, outputInfos.get(i).get(param.getDataCode()));
                    //value = convertValue(param, value);
                    value = reportServiceImpl.formatValue(param, outputInfos.get(i).get(param.getDataCode()));
                    value = reportServiceImpl.convertValue(param, value);
                    // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                    // del #10385 患者イベント(画像)の出力が不正 高 start
//                    if (param.getIsImage().equals("true") && null != value && !value.equals("") && !value.equals("null")) {
//                      value = "(place)" + value;
//                    }
                    // del #10392 患者イベント(画像)の出力が不正 高 end
                    if (value != null && !"null".equals(value)) {
                      // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
                      // result.put(key, addLineBreak(value, param.getDispLength(), param.getDataType()));
                      // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                      //result.put(key, addLineBreak(value, param));
                      result.put(key, reportServiceImpl.addLineBreak(value, param));
                      // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                      // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
                    } else {
                      result.put(key, "");
                    }
                    n++;
                  }
                } else {
                  for (int j = 0; j < outputInfos.size(); j ++) {
                    String pageStr = String.format("%d%s", pageCount + 1, MULTIPLE_PAGES_SEPARATOR);
                    key = String.format("%s%s-%d", pageStr, param.getId(), n + 1);
                    // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                    //value = formatValue(param, outputInfos.get(j).get(param.getDataCode()));
                    //value = convertValue(param, value);
                    value = reportServiceImpl.formatValue(param, outputInfos.get(j).get(param.getDataCode()));
                    value = reportServiceImpl.convertValue(param, value);
                    // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                    // del #10385 患者イベント(画像)の出力が不正 高 start
//                    if (param.getIsImage().equals("true") && null != value && !value.equals("") && !value.equals("null")) {
//                      value = "(place)" + value;
//                    }
                    // del #10385 患者イベント(画像)の出力が不正 高 end
                    if (value != null && !"null".equals(value)) {
                      // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
                      // result.put(key, addLineBreak(value, param.getDispLength(), param.getDataType()));
                      // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                      //result.put(key, addLineBreak(value, param));
                      result.put(key, reportServiceImpl.addLineBreak(value, param));
                      // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                      // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
                    } else {
                      result.put(key, "");
                    }
                    n++;
                  }
                }
              }
            }
          });

        groupedParam.getValue().stream()
          .filter(param -> StringUtils.isEmpty(param.getGroupId()) && !param.isTmplRepeat())
          .forEach(param -> {
            // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
            //String value = formatValue(param, finalTmpMap.get(param.getDataCode()));
            //value = convertValue(param, value);
            String value = reportServiceImpl.formatValue(param, finalTmpMap.get(param.getDataCode()));
            value = reportServiceImpl.convertValue(param, value);
            // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
            if(finalPage > 1){
              for(int i = 0 ; i < finalPage ; i++){
                if (dataKey.get("newPageCountFlag") != null && (i + 1) > 1) {
                  break;
                }
                String key = String.format("%s%s%d", param.getId(), "$", i+1);
                if (value != null && !"null".equals(value)) {
                  // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
                  // result.put(key, addLineBreak(value, param.getDispLength(), param.getDataType()));
                  // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                  //result.put(key, addLineBreak(value, param));
                  result.put(key, reportServiceImpl.addLineBreak(value, param));
                  // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                  // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
                } else {
                  result.put(key, "");
                }
              }
            }else{
              String key = String.format("%s%s%d", param.getId(), "$", 1);
              if (value != null && !"null".equals(value)) {
                // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
                // result.put(key, addLineBreak(value, param.getDispLength(), param.getDataType()));
                // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                //result.put(key, addLineBreak(value, param));
                result.put(key, reportServiceImpl.addLineBreak(value, param));
                // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
              } else {
                result.put(key, "");
              }
            }
          });
      });
    }
    // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy start
    ReportCommonUtil.pageAndPageCount(result, params, dataKey);
    // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy end
    return result;
  }

  // テンプレート内の繰り返しで、枠内に収まらず次の項目に表示された場合に、位置補正を行う為に必要な値を格納するクラス
  private class TmplCorrectData {
    // key：元、value：補正後 / 形式：[ページ]#[ページ内のテンプレート位置] ( 例：1#2 )
    Map<String, String> repNumList = new HashMap<>();
    // 処理除外対象セルリスト
    List<String> cellList = new ArrayList<String>();
  }

  private Map<String, String> convertDataCodeToIdNew(List<ReportXmlParam> params, Map<Long, List<Map<String, Object>>> reportOutputInfo, Integer type, Integer reportType,
                                                     Map<String, Long> patIdToCMap, Map<String, Object> dataKey, MstReport.Extraction extractionCondition) {
    Map<String, String> paramIds = new HashMap<>();
    TmplCorrectData tmplCorrectData = new TmplCorrectData();
    AtomicReference<String> paramCode = new AtomicReference<>("");
    // add 11011 集計内訳タブ仕様変更 高 start
    paramCode.set(params.get(0).getReportXmlTotalTable().getUnitV());
    // add 11011 集計内訳タブ仕様変更 高 end

    Map<String, String> result = new HashMap<>();
    List<Long> ordDataList = new ArrayList<>();
    List<Object> ordNos = (List)dataKey.get("ordNos");
    String unitH = params.get(0).getReportXmlTotalTable().getUnitH();
    String unitV = params.get(0).getReportXmlTotalTable().getUnitV();
    String conversion = params.get(0).getReportXmlTotalTable().getConversion();
    String tmplRepeatId = params.get(0).getReportXmlTmplRepeat().getId();
    List<ReportXmlParam> tmplInfo = params.stream().filter(item -> tmplRepeatId.equals(item.getId())).collect( Collectors.toCollection(ArrayList::new));
    Integer repeatCountV = params.get(0).getReportXmlTmplRepeat().getRepeatCountV();
    Integer repeatCountH = params.get(0).getReportXmlTmplRepeat().getRepeatCountH();
    if(null !=ordNos&&ordNos.size()>0){
      for(int i=0;i<ordNos.size();i++){
        if( ordNos.get(i) instanceof  Long){
          Long ordNo = Long.parseLong(ordNos.get(i).toString());
          ordDataList.add(ordNo);
        }else if( ordNos.get(i) instanceof OrdMain){
          OrdMain ordMain = (OrdMain) ordNos.get(i);
          ordDataList.add(ordMain.getOrdNo());
        }
      }
    }
    Map<String, List<ReportXmlParam>> groupIdListInTmpl =
      params.stream()
        .filter(param -> param.isTmplRepeat())
        .collect(Collectors.groupingBy(ReportXmlParam::getGroupId));
    Integer repeatTMax = 0;
    String groupStr = "";
    List doReportName = new ArrayList();
    Map<String, Integer> tmpSkipCountMap = new HashMap<>();
    tmpSkipCountMap.put(TMP_SKIP_COUNT, 0);

    for (int count = 0; count < params.size(); count++){
      if ("medicine_name".equals(params.get(count).getDataCode())){
        repeatTMax = params.get(count).getReportXmlTmplRepeat().getRepeatMax();
        groupStr = params.get(count).getGroupId();
        break;
      }
    }
    for (String doStr : groupIdListInTmpl.keySet()){
      if (groupStr.equals(doStr)){
        List<ReportXmlParam> doReportParam = groupIdListInTmpl.get(doStr);
        for (int u = 0; u < doReportParam.size(); u++){
          doReportName.add(doReportParam.get(u).getDataCode());
        }
        break;
      }
    }
    // 複数項目のページ数より、単一項目のページ数を設定する
    Map<String, Integer> resultTemp = new HashMap<>();
    // 単一項目のページ数の標準値に1ページ数を設定する
    resultTemp.put("GROUP_DATA_PAGE_COUNT", 1);

    // sqlCode属性値でグループ化したParam要素情報を取得する
    Map<String, List<ReportXmlParam>> groupedParams = params.stream()
      .filter(p -> !StringUtils.isEmpty(p.getId()))
      .collect(Collectors.groupingBy(p -> p.getSqlCode()))
      ;
    List<String> sqlCodes = getSqlCode(params);
    // mod #10857 帳票内に同項目が複数あると設定値を取り違える 高 start
//    List<Integer> sqlCode1 = new ArrayList<Integer>();
//    for(String sql : sqlCodes){
//      sqlCode1.add(Integer.valueOf(sql));
//    }
//    Collections.sort(sqlCode1);
//    LinkedHashMap<String, List<ReportXmlParam>> newGroupe = new LinkedHashMap<>();
//    for(Integer sql : sqlCode1){
//      if (groupedParams.get(sql.toString()) != null) {
//        newGroupe.put(sql.toString(),groupedParams.get(sql.toString()));
//      }
//    }
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
    // mod #10857 帳票内に同項目が複数あると設定値を取り違える 高 end
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
      Map<String, Object> dataKeyValues = new HashMap<>();
      if (tmpList !=null && tmpList.size() > 0){
        if (tmpList.get(0).containsKey("pat_last_name_id")){
          for (int i = 0; i < tmpList.size(); i++){
            Long patIdToC = 0L;
            if (patIdToCMap.get(PAT_ID_TO_C) != null) {
              patIdToC = patIdToCMap.get(PAT_ID_TO_C);
            }
            if (patIdToC != null && patIdToC.equals(tmpList.get(i).get("patId"))){
              dataKeyValues = tmpList.get(i);
              break;
            }
          }
        }
      }
      if (tmpList!=null && !tmpList.isEmpty()) {
        // 複数項目のページ数より、単一項目のページ数を設定する
        groupedParam.getValue().stream()
          .filter(param -> !StringUtils.isEmpty(param.getGroupId()) && !param.isTmplRepeat())
          .forEach(param -> {

            // フィルタ処理を行う
            // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
            //List<Map<String, Object>> filteredList = filterReportInfo(param, tmpList);
            List<Map<String, Object>> filteredList = reportServiceImpl.filterReportInfo(param, tmpList);
            // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
            // フィルタ処理の結果がEmpty以外の場合
            if (!filteredList.isEmpty()) {
              // 1ページの繰り返し件数を取得する
              ReportXmlGroup group = param.getReportXmlGroup();
              Integer repeatOfPage;
              if (group != null && (group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_YES
                || type == ReportConstant.ReportClass.MULTI_TOTAL_REPORT)) {
                repeatOfPage = (filteredList.size() > group.getRepeatMax()) ? group.getRepeatMax() : filteredList.size();
              } else {
                repeatOfPage = filteredList.size();
              }

              // 複数項目のページ数より、単一項目のページ数を設定する
              int addPage = (filteredList.size() % repeatOfPage) > 0 ? 1 : 0;
              resultTemp.replace("GROUP_DATA_PAGE_COUNT", (filteredList.size() / repeatOfPage) + addPage);
            }
          });
        List<ReportXmlParam> list = groupedParam.getValue().stream()
          .filter(param -> StringUtils.isEmpty(param.getGroupId()) && "1".equals(param.getIsNewPage()) && !param.isTmplRepeat()).collect(toList());
        // 単一項目に対する処理を行う
        if (tmpList.size() > 1 && list!= null && list.size() > 0) {
          groupedParam.getValue().stream()
            .filter(param -> StringUtils.isEmpty(param.getGroupId()) && !param.isTmplRepeat())
            .forEach(param -> {
              for (int i = 0; i < tmpList.size(); i++) {
                Map<String, Object> tmpMap = tmpList.get(i);
                // 出力する内容を取得する
                // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                //String value = formatValue(param, tmpMap.get(param.getDataCode()));
                //value = convertValue(param, value);
                String value = reportServiceImpl.formatValue(param, tmpMap.get(param.getDataCode()));
                value = reportServiceImpl.convertValue(param, value);
                // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end

                if (value != null && !"null".equals(value)) {
                  // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
                  // result.put(String.format("%d%s", i + 1, MULTIPLE_PAGES_SEPARATOR) + param.getId(), addLineBreak(value, param.getDispLength(), param.getDataType()));
                  // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                  //result.put(String.format("%d%s", i + 1, MULTIPLE_PAGES_SEPARATOR) + param.getId(), addLineBreak(value, param));
                  result.put(String.format("%d%s", i + 1, MULTIPLE_PAGES_SEPARATOR) + param.getId(), reportServiceImpl.addLineBreak(value, param));
                  // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                  // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
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
              // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
              //String value = formatValue(param, tmpMap.get(param.getDataCode()));
              //value = convertValue(param, value);
              String value = reportServiceImpl.formatValue(param, tmpMap.get(param.getDataCode()));
              value = reportServiceImpl.convertValue(param, value);
              // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end

              if (value != null && !"null".equals(value)) {
                // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
                // result.put(param.getId(), addLineBreak(value, param.getDispLength(), param.getDataType()));
                // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                //result.put(param.getId(), addLineBreak(value, param));
                result.put(param.getId(), reportServiceImpl.addLineBreak(value, param));
                // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
              } else {
                result.put(param.getId(), "");
              }
            })
          ;
        }
        Map<String, Object> finalDataKeyValues = dataKeyValues;
        groupedParam.getValue().stream()
          .filter(param -> !StringUtils.isEmpty(param.getGroupId()) && !param.isTmplRepeat())
          .forEach(param -> {
            // フィルタ処理を行う
            // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
            //List<Map<String, Object>> filteredList = filterReportInfo(param, tmpList);
            List<Map<String, Object>> filteredList = reportServiceImpl.filterReportInfo(param, tmpList);
            // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
            // フィルタ処理の結果がEmptyの場合
            if (filteredList.isEmpty()) {
              EventLogMessage eventLogMessage = new EventLogMessage();
              eventLogMessage.setLogMessage("帳票：フィルタ結果した結果が空");
              logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
              return;
            }
            ReportXmlGroup group = param.getReportXmlGroup();
            // ページ数分、以下の処理を行う
            Integer repeatMax = (group != null && group.getRepeatMax() != null) ? group.getRepeatMax() : 1;
            boolean isNewPage = param.getReportXmlTmplRepeat().getIsNewPage() > 0;
            if(dataKey.get("newPageCountFlag") != null) isNewPage = false;
            // 1ページの繰り返し件数を取得する
            if (filteredList.size()!= 0) {
              // mod #11294 紹介状で集計部分がずれて出力される 高 start
//              if (filteredList.get(0).get(unitH) != null) {
              if (filteredList.get(0).get(unitH) != null &&
                (params.get(0).getReportXmlTotalTable().getUnitHAddress().equals(param.getId()) ||
                  params.get(0).getReportXmlTotalTable().getUnitVAddress().equals(param.getId()))) {
                // mod #11294 紹介状で集計部分がずれて出力される 高 end
                Integer repeatOfPage;
                List dateArr = new ArrayList();
                LocalDate beforeDate;
                LocalDate afterDate;
                LocalDate newDate;
                DateTimeFormatter formatter;
                if (String.valueOf(dataKey.get("fromDate")).length()<=8) {
                  formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
                  beforeDate = LocalDate.parse(String.valueOf(dataKey.get("fromDate")).replace("-","/"),formatter);
                  afterDate = LocalDate.parse(String.valueOf(dataKey.get("toDate")).replace("-","/"),formatter);
                } else {
                  beforeDate = LocalDate.parse(String.valueOf(dataKey.get("fromDate")));
                  afterDate = LocalDate.parse(String.valueOf(dataKey.get("toDate")));
                  formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
                }
                DateTimeFormatter formatterOne = DateTimeFormatter.ofPattern("yyyy-MM-dd");
                do {
                  dateArr.add(beforeDate.format(formatterOne));
                  beforeDate = beforeDate.plusDays(1);
                } while(!beforeDate.isAfter(afterDate));
                List dateOrd = new ArrayList();
                List newDateList = new ArrayList();
                List<OrdMain> weekOrdMain = ordMainDao.selectPatOrdMainBetweenTreatDate(
                  Long.parseLong(String.valueOf(dataKey.get("patId"))), dataKey.get("facilityCd").toString(),
                  String.valueOf(dataKey.get("fromDate")).replace("/", "").replace("-", ""),
                  String.valueOf(dataKey.get("toDate")).replace("/", "").replace("-", ""));
                for (int  index = 0;index < weekOrdMain.size();index++) {
                  if (!dateOrd.contains(weekOrdMain.get(index).getTreatDate())) {
                    formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
                    newDate = LocalDate.parse(String.valueOf(weekOrdMain.get(index).getTreatDate()),formatter);
                    dateOrd.add(newDate.format(formatterOne));
                  }
                }
                for (int num = 0;num < dateArr.size();num++) {
                  if (dateOrd.contains(dateArr.get(num))) {
                    newDateList.add(dateArr.get(num));
                  }
                }
                // N
                if (param.getReportXmlTmplRepeat().getDirection().equals("0")) {
                  List mediNameCount = new ArrayList();
                  List dateArr1 = new ArrayList();
                  List mediName = new ArrayList();
                  int dateArrCountNum = 1;
                  int pageCountNum = 0;
                  int mediPageCountNum = 0;
                  for (int b = 0;b<newDateList.size();b++) {
                    if (!dateArr1.contains(newDateList.get(b))) {
                      dateArr1.add(newDateList.get(b));
                    }

                    if(b < (param.getReportXmlTmplRepeat().getRepeatCountH()*dateArrCountNum)-1) {
                      if (b != newDateList.size()-1) {
                        continue;
                      }
                    }
                    if ("項目値".equals(param.getReportXmlTotalTable().getContents())) {
                      for (int a = 0;a <filteredList.size();a++) {
                        mediNameCount.add(filteredList.get(a).get(unitH).toString());
                      }
                    } else if ("合　計".equals(param.getReportXmlTotalTable().getContents())
                      ||"平均値".equals(param.getReportXmlTotalTable().getContents())
                      ||"最大値".equals(param.getReportXmlTotalTable().getContents())
                      ||"最小値".equals(param.getReportXmlTotalTable().getContents())){
                      for (int a = 0;a <filteredList.size();a++) {
                        if (!mediNameCount.contains(filteredList.get(a).get(unitH).toString())) {
                          mediNameCount.add(filteredList.get(a).get(unitH).toString());
                        }
                      }
                    }
                    dateArrCountNum++;
                    if (param.getDataCode().equals(unitH)) {
                      int mediCount = 0;
                      if (mediNameCount.size()!= 0&&param.getReportXmlTmplRepeat().getRepeatCountV()>=mediNameCount.size()) {
                        mediCount = mediPageCountNum+1;
                      } else if (mediNameCount.size()!= 0&&param.getReportXmlTmplRepeat().getRepeatCountV()<=mediNameCount.size()&&mediNameCount.size()%param.getReportXmlTmplRepeat().getRepeatCountV() == 0){
                        mediCount = mediPageCountNum+mediNameCount.size()/param.getReportXmlTmplRepeat().getRepeatCountV();
                      } else if (mediNameCount.size()!= 0&&param.getReportXmlTmplRepeat().getRepeatCountV()<=mediNameCount.size()&&mediNameCount.size()%param.getReportXmlTmplRepeat().getRepeatCountV() != 0) {
                        mediCount = mediPageCountNum+mediNameCount.size()/param.getReportXmlTmplRepeat().getRepeatCountV()+1;
                      } else if (dateArr1.size() != 0 &&param.getReportXmlTmplRepeat().getRepeatCountH()>=dateArr1.size()){
                        mediCount = mediPageCountNum+1;
                      } else if (dateArr1.size() != 0 &&param.getReportXmlTmplRepeat().getRepeatCountH()<=dateArr1.size()&&dateArr1.size()%param.getReportXmlTmplRepeat().getRepeatCountH() == 0){
                        mediCount = mediPageCountNum+dateArr1.size()/param.getReportXmlTmplRepeat().getRepeatCountH();
                      } else if (dateArr1.size()!= 0&&param.getReportXmlTmplRepeat().getRepeatCountH()<=dateArr1.size()&&dateArr1.size()%param.getReportXmlTmplRepeat().getRepeatCountH() != 0) {
                        mediCount = mediPageCountNum+dateArr1.size()/param.getReportXmlTmplRepeat().getRepeatCountH()+1;
                      }
                      int v = 0;
                      int oneCount = 0;
                      int pageNum = 0;
                      for (int num1 = mediPageCountNum;num1 < mediCount;num1++){
                        if (isNewPage == false && (num1 + 1) > 1) {
                          continue;
                        }
                        mediPageCountNum++;
                        pageNum++;
                        for(int num2 = v;num2<mediNameCount.size();num2++) {
                          if(num2>=param.getReportXmlTmplRepeat().getRepeatCountV()*pageNum){
                            oneCount = 0;
                            continue;
                          }
                          oneCount++;
                          v++;
                          String pageStr = String.format("%d%s", num1 + 1, MULTIPLE_PAGES_SEPARATOR);
                          String key = null;
                          key = String.format("%s%s-%d", pageStr, param.getId(), oneCount);
                          if (type == 9 && reportType == 1 && "日".equals(params.get(0).getReportXmlTotalTable().getUnitDate())) {
                            if (unitH.equals(param.getDataCode())) {
                              if (mediNameCount.size() != 0) {
                                result.put(key, String.valueOf(mediNameCount.get(num2)));
                                mediName.add(String.valueOf(mediNameCount.get(num2)));
                              }
                            }
                          }
                        }
                      }
                      mediName.clear();
                    }else if (param.getDataCode().equals(unitV)) {
                      int mediCount = 0;
                      if (mediNameCount.size()!= 0&&param.getReportXmlTmplRepeat().getRepeatCountV()>=mediNameCount.size()) {
                        mediCount = pageCountNum+1;
                      } else if (mediNameCount.size()!= 0&&param.getReportXmlTmplRepeat().getRepeatCountV()<=mediNameCount.size()&&mediNameCount.size()%param.getReportXmlTmplRepeat().getRepeatCountV() == 0){
                        mediCount = pageCountNum+mediNameCount.size()/param.getReportXmlTmplRepeat().getRepeatCountV();
                      } else if (mediNameCount.size()!= 0&&param.getReportXmlTmplRepeat().getRepeatCountV()<=mediNameCount.size()&&mediNameCount.size()%param.getReportXmlTmplRepeat().getRepeatCountV() != 0) {
                        mediCount = pageCountNum+mediNameCount.size()/param.getReportXmlTmplRepeat().getRepeatCountV()+1;
                      } else if (dateArr1.size() != 0 &&param.getReportXmlTmplRepeat().getRepeatCountH()>=dateArr1.size()){
                        mediCount = pageCountNum+1;
                      } else if (dateArr1.size() != 0 &&param.getReportXmlTmplRepeat().getRepeatCountH()<=dateArr1.size()&&dateArr1.size()%param.getReportXmlTmplRepeat().getRepeatCountH() == 0){
                        mediCount = pageCountNum+dateArr1.size()/param.getReportXmlTmplRepeat().getRepeatCountH();
                      } else if (dateArr1.size()!= 0&&param.getReportXmlTmplRepeat().getRepeatCountH()<=dateArr1.size()&&dateArr1.size()%param.getReportXmlTmplRepeat().getRepeatCountH() != 0) {
                        mediCount = pageCountNum+dateArr1.size()/param.getReportXmlTmplRepeat().getRepeatCountH()+1;
                      }
                      paramCode.set(param.getDataCode());
                      for (int num1 = pageCountNum;num1 < mediCount;num1++){
                        if (isNewPage == false && (num1 + 1) > 1) {
                          continue;
                        }
                        pageCountNum++;
                        for(int num2 = 0;num2<dateArr1.size();num2++) {
                          if (dateOrd.contains(dateArr1.get(num2))) {
                            String pageStr = String.format("%d%s", num1 + 1, MULTIPLE_PAGES_SEPARATOR);
                            String key = String.format("%s%s-%d", pageStr, param.getId(), num2 + 1);
                            // mod 11011 集計内訳タブ仕様変更 高 start
//                            if (type == 9 && reportType == 1 && tmplInfo.get(0).getSqlCode().equals(param.getSqlCode()) && "日".equals(params.get(0).getReportXmlTotalTable().getUnitDate())) {
                            if (type == 9 && reportType == 1&& "日".equals(params.get(0).getReportXmlTotalTable().getUnitDate())) {
                              // mod 11011 集計内訳タブ仕様変更 高 end
                              result.put(key, String.valueOf(dateArr1.get(num2)));
                            }
                          }
                        }
                      }
                    }
                    dateArr1.clear();
                    mediNameCount.clear();
                  }
                }
                // Z
                else if (param.getReportXmlTmplRepeat().getDirection().equals("1")){
                  List mediNameCount = new ArrayList();
                  List dateArr1 = new ArrayList();
                  List mediNameArr1 = new ArrayList();
                  List mediName = new ArrayList();
                  int dateArrCountNum = 1;
                  int pageCountNum = 0;
                  int mediPageCountNum = 0;
                  Map<Object, List<Map<String, Object>>> groupedByMediName;
                  List mediNameArrList = new ArrayList();
                  for (int index = 0;index <filteredList.size();index++) {
                    if (newDateList.contains(filteredList.get(index).get(unitV).toString())) {
                      mediNameArrList.add(filteredList.get(index).get(unitH).toString());
                    }
                  }
                  if ("項目値".equals(param.getReportXmlTotalTable().getContents())) {
                    for (int index = 0;index <filteredList.size();index++) {
                      if (newDateList.contains(filteredList.get(index).get(unitV).toString())) {
                        mediNameArr1.add(filteredList.get(index).get(unitH).toString());
                      }
                    }
                  } else if ("合　計".equals(param.getReportXmlTotalTable().getContents())
                    ||"平均値".equals(param.getReportXmlTotalTable().getContents())
                    ||"最大値".equals(param.getReportXmlTotalTable().getContents())
                    ||"最小値".equals(param.getReportXmlTotalTable().getContents())) {
                    groupedByMediName = filteredList.stream()
                      .collect(Collectors.groupingBy(map -> map.get(unitH).toString()));
                    for(Map.Entry<Object, List<Map<String, Object>>> entry : groupedByMediName.entrySet()){
                      if (mediNameArrList.contains(entry.getKey())) {
                        mediNameArr1.add(entry.getKey());
                      }
                    }
                    mediNameArr1.sort(Comparator.comparing(Object::toString, Collections.reverseOrder()));
                  }
                  if (mediNameArr1.size() == 0 && newDateList.size()!= 0) {
                    if (param.getDataCode().equals(unitV)) {
                      int mediCount = 0;
                      int forCountNum = 0;
                      int forBiCount = 0;
                      if (newDateList.size() != 0 &&param.getReportXmlTmplRepeat().getRepeatCountH()>=newDateList.size()){
                        mediCount = mediPageCountNum+1;
                      } else if (newDateList.size() != 0 &&param.getReportXmlTmplRepeat().getRepeatCountH()<=newDateList.size()&&newDateList.size()%param.getReportXmlTmplRepeat().getRepeatCountH() == 0){
                        mediCount = mediPageCountNum+newDateList.size()/param.getReportXmlTmplRepeat().getRepeatCountH();
                      } else if (newDateList.size()!= 0&&param.getReportXmlTmplRepeat().getRepeatCountH()<=newDateList.size()&&newDateList.size()%param.getReportXmlTmplRepeat().getRepeatCountH() != 0) {
                        mediCount = mediPageCountNum+newDateList.size()/param.getReportXmlTmplRepeat().getRepeatCountH()+1;
                      }
                      if (mediNameArr1.size()== 0){
                        forCountNum = 1;
                      }else if (mediNameArr1.size()!= 0&&param.getReportXmlTmplRepeat().getRepeatCountV()>=mediNameArr1.size()) {
                        forCountNum = 1;
                      } else if (mediNameArr1.size()!= 0&&param.getReportXmlTmplRepeat().getRepeatCountV()<=mediNameArr1.size()&&mediNameArr1.size()%param.getReportXmlTmplRepeat().getRepeatCountV() == 0){
                        forCountNum = mediNameArr1.size()/param.getReportXmlTmplRepeat().getRepeatCountV();
                      } else if (mediNameArr1.size()!= 0&&param.getReportXmlTmplRepeat().getRepeatCountV()<=mediNameArr1.size()&&mediNameArr1.size()%param.getReportXmlTmplRepeat().getRepeatCountV() != 0) {
                        forCountNum = mediNameArr1.size()/param.getReportXmlTmplRepeat().getRepeatCountV()+1;
                      }
                      paramCode.set(param.getDataCode());
                      for (int bi = 0;bi < forCountNum;bi++) {
                        int v = 0;
                        for (int num1 = pageCountNum;num1 < mediCount*(bi+1);num1++){
                          if (isNewPage == false && (num1 + 1) > 1) {
                            continue;
                          }
                          pageCountNum++;
                          forBiCount++;
                          for(int num2 = v;num2<newDateList.size();num2++) {
                            if (num2 == 0) {
                              forBiCount = 0;
                            }
                            if (num2 >= param.getReportXmlTmplRepeat().getRepeatCountH() * (forBiCount + 1)) {
                              break;
                            }
                            v++;
                            String pageStr = String.format("%d%s", num1 + 1, MULTIPLE_PAGES_SEPARATOR);
                            String key = null;
                            if (newDateList.size() >= param.getReportXmlTmplRepeat().getRepeatCountH()* forBiCount) {
                              key = String.format("%s%s-%d", pageStr, param.getId(), (num2 - (param.getReportXmlTmplRepeat().getRepeatCountH() * forBiCount)) + 1);
                            } else {
                              key = String.format("%s%s-%d", pageStr, param.getId(), num2 + 1);
                            }
                            // mod 11011 集計内訳タブ仕様変更 高 start
//                            if (type == 9 && reportType == 1 && tmplInfo.get(0).getSqlCode().equals(param.getSqlCode()) && "日".equals(params.get(0).getReportXmlTotalTable().getUnitDate())) {
                            if (type == 9 && reportType == 1 && "日".equals(params.get(0).getReportXmlTotalTable().getUnitDate())) {
                              // mod 11011 集計内訳タブ仕様変更 高 end
                              if (newDateList.size() != 0) {
                                result.put(key, String.valueOf(newDateList.get(num2)));
                                mediName.add(String.valueOf(newDateList.get(num2)));
                              }
                            }
                          }
                        }
                      }
                      mediName.clear();
                    } else{
                      for (Integer i = 0; i < filteredList.size(); i++) {
                        int n=0;
                        List<ReportXmlFilterTable> filters = param.getReportXmlFilters();
                        if (n >= repeatMax) {
                          break;
                        }
                        String outputData = "";
                        Set<String> keysSet = filteredList.get(i).keySet();
                        if (!keysSet.isEmpty()) {
                          String key1 = keysSet.toArray(new String[0])[0];
                          outputData = String.valueOf(filteredList.get(i).get(key1));
                        }
                        List<String> PatientEvents = new ArrayList<String>() {
                          {
                            for (int i = 84; i <= 94; i++) {
                              this.add(i + "");
                            }
                          }
                        };
                        if (filters == null || filters.size() == 0 || (outputData.equals(filters.get(0).getCode()) && !outputData.isEmpty()) || PatientEvents.contains(param.getSqlCode())) {
                          String key = "";
                          String value = "";
                          if (group != null && group.getRepeatMax() <= 1 && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_NO) {
                            // グループ設定が存在しない、またはグループ設定の繰り返し回数が1以下且つテンプレート外の項目は、後続処理でページ毎出力されるようにidを設定する
                            key = param.getId();
                          } else {
                            String pageStr = String.format("%d%s", i + 1, MULTIPLE_PAGES_SEPARATOR);
                            key = String.format("%s%s-%d", pageStr, param.getId(), n + 1);
                          }
                          // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                          //value = formatValue(param, filteredList.get(i).get(param.getDataCode()));
                          //value = convertValue(param, value);
                          value = reportServiceImpl.formatValue(param, filteredList.get(i).get(param.getDataCode()));
                          value = reportServiceImpl.convertValue(param, value);
                          // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                          // del #10385 患者イベント(画像)の出力が不正 高 start
//                          if (param.getIsImage().equals("true") && null != value && !value.equals("") && !value.equals("null")) {
//                            value = "(place)" + value;
//                          }
                          // del #10385 患者イベント(画像)の出力が不正 高 end
                          if (value != null && !"null".equals(value)) {
                            // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
                            // result.put(key, addLineBreak(value, param.getDispLength(), param.getDataType()));
                            // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                            //result.put(key, addLineBreak(value, param));
                            result.put(key, reportServiceImpl.addLineBreak(value, param));
                            // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                            // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
                          } else {
                            result.put(key, "");
                          }
                          n++;
                        }
                      }
                    }
                  } else {
                    for (int b =0;b <mediNameArr1.size();b++ ){
                      if ("項目値".equals(param.getReportXmlTotalTable().getContents())) {
                        mediNameCount.add(mediNameArr1.get(b));
                      } else if ("合　計".equals(param.getReportXmlTotalTable().getContents())
                        ||"平均値".equals(param.getReportXmlTotalTable().getContents())
                        ||"最大値".equals(param.getReportXmlTotalTable().getContents())
                        ||"最小値".equals(param.getReportXmlTotalTable().getContents())) {
                        if (!mediNameCount.contains(mediNameArr1.get(b))) {
                          mediNameCount.add(mediNameArr1.get(b));
                        }
                      }
                      if(b < (param.getReportXmlTmplRepeat().getRepeatCountV()*dateArrCountNum)-1) {
                        if (b != mediNameArr1.size()-1) {
                          continue;
                        }
                      }
                      dateArrCountNum++;
                      if (param.getDataCode().equals(unitH)) {
                        int mediCount = 0;
                        if (newDateList.size() != 0 &&param.getReportXmlTmplRepeat().getRepeatCountH()>=newDateList.size()){
                          mediCount = mediPageCountNum+1;
                        } else if (newDateList.size() != 0 &&param.getReportXmlTmplRepeat().getRepeatCountH()<=newDateList.size()&&newDateList.size()%param.getReportXmlTmplRepeat().getRepeatCountH() == 0){
                          mediCount = mediPageCountNum+newDateList.size()/param.getReportXmlTmplRepeat().getRepeatCountH();
                        } else if (newDateList.size()!= 0&&param.getReportXmlTmplRepeat().getRepeatCountH()<=newDateList.size()&&newDateList.size()%param.getReportXmlTmplRepeat().getRepeatCountH() != 0) {
                          mediCount = mediPageCountNum+newDateList.size()/param.getReportXmlTmplRepeat().getRepeatCountH()+1;
                        } else if (mediNameCount.size()!= 0&&param.getReportXmlTmplRepeat().getRepeatCountV()>=mediNameCount.size()) {
                          mediCount = mediPageCountNum+1;
                        } else if (mediNameCount.size()!= 0&&param.getReportXmlTmplRepeat().getRepeatCountV()<=mediNameCount.size()&&mediNameCount.size()%param.getReportXmlTmplRepeat().getRepeatCountV() == 0){
                          mediCount = mediPageCountNum+mediNameCount.size()/param.getReportXmlTmplRepeat().getRepeatCountV();
                        } else if (mediNameCount.size()!= 0&&param.getReportXmlTmplRepeat().getRepeatCountV()<=mediNameCount.size()&&mediNameCount.size()%param.getReportXmlTmplRepeat().getRepeatCountV() != 0) {
                          mediCount = mediPageCountNum+mediNameCount.size()/param.getReportXmlTmplRepeat().getRepeatCountV()+1;
                        }
                        for (int num1 = mediPageCountNum;num1 < mediCount;num1++){
                          if (isNewPage == false && (num1 + 1) > 1) {
                            continue;
                          }
                          mediPageCountNum++;
                          for(int num2 = 0;num2<mediNameCount.size();num2++) {
                            String pageStr = String.format("%d%s", num1 + 1, MULTIPLE_PAGES_SEPARATOR);
                            String key = String.format("%s%s-%d", pageStr, param.getId(), num2 + 1);
                            // mod 11011 集計内訳タブ仕様変更 高 start
//                            if (type == 9 && reportType == 1 && tmplInfo.get(0).getSqlCode().equals(param.getSqlCode()) && "日".equals(params.get(0).getReportXmlTotalTable().getUnitDate())) {
                            if (type == 9 && reportType == 1 && "日".equals(params.get(0).getReportXmlTotalTable().getUnitDate())) {
                              // mod 11011 集計内訳タブ仕様変更 高 end
                              result.put(key, String.valueOf(mediNameCount.get(num2)));
                            }
                          }
                        }
                      } else if (param.getDataCode().equals(unitV)) {
                        int mediCount = 0;
                        int forCountNum = 0;
                        int forBiCount = 0;
                        if (newDateList.size() != 0 &&param.getReportXmlTmplRepeat().getRepeatCountH()>=newDateList.size()){
                          mediCount = mediPageCountNum+1;
                        } else if (newDateList.size() != 0 &&param.getReportXmlTmplRepeat().getRepeatCountH()<=newDateList.size()&&newDateList.size()%param.getReportXmlTmplRepeat().getRepeatCountH() == 0){
                          mediCount = mediPageCountNum+newDateList.size()/param.getReportXmlTmplRepeat().getRepeatCountH();
                        } else if (newDateList.size()!= 0&&param.getReportXmlTmplRepeat().getRepeatCountH()<=newDateList.size()&&newDateList.size()%param.getReportXmlTmplRepeat().getRepeatCountH() != 0) {
                          mediCount = mediPageCountNum+newDateList.size()/param.getReportXmlTmplRepeat().getRepeatCountH()+1;
                        } else if (mediNameCount.size()!= 0&&param.getReportXmlTmplRepeat().getRepeatCountV()>=mediNameCount.size()) {
                          mediCount = mediPageCountNum+1;
                        } else if (mediNameCount.size()!= 0&&param.getReportXmlTmplRepeat().getRepeatCountV()<=mediNameCount.size()&&mediNameCount.size()%param.getReportXmlTmplRepeat().getRepeatCountV() == 0){
                          mediCount = mediPageCountNum+mediNameCount.size()/param.getReportXmlTmplRepeat().getRepeatCountV();
                        } else if (mediNameCount.size()!= 0&&param.getReportXmlTmplRepeat().getRepeatCountV()<=mediNameCount.size()&&mediNameCount.size()%param.getReportXmlTmplRepeat().getRepeatCountV() != 0) {
                          mediCount = mediPageCountNum+mediNameCount.size()/param.getReportXmlTmplRepeat().getRepeatCountV()+1;
                        }
                        if (mediNameArr1.size()== 0){
                          forCountNum = 1;
                        }else if (mediNameArr1.size()!= 0&&param.getReportXmlTmplRepeat().getRepeatCountV()>=mediNameArr1.size()) {
                          forCountNum = 1;
                        } else if (mediNameArr1.size()!= 0&&param.getReportXmlTmplRepeat().getRepeatCountV()<=mediNameArr1.size()&&mediNameArr1.size()%param.getReportXmlTmplRepeat().getRepeatCountV() == 0){
                          forCountNum = mediNameArr1.size()/param.getReportXmlTmplRepeat().getRepeatCountV();
                        } else if (mediNameArr1.size()!= 0&&param.getReportXmlTmplRepeat().getRepeatCountV()<=mediNameArr1.size()&&mediNameArr1.size()%param.getReportXmlTmplRepeat().getRepeatCountV() != 0) {
                          forCountNum = mediNameArr1.size()/param.getReportXmlTmplRepeat().getRepeatCountV()+1;
                        }
                        paramCode.set(param.getDataCode());
                        for (int bi = 0;bi < forCountNum;bi++) {
                          int v = 0;
                          for (int num1 = pageCountNum;num1 < mediCount*(bi+1);num1++){
                            if (isNewPage == false && (num1 + 1) > 1) {
                              continue;
                            }
                            pageCountNum++;
                            forBiCount++;
                            for(int num2 = v;num2<newDateList.size();num2++) {
                              if (num2 == 0) {
                                forBiCount = 0;
                              }
                              if (num2 >= param.getReportXmlTmplRepeat().getRepeatCountH() * (forBiCount + 1)) {
                                break;
                              }
                              v++;
                              String pageStr = String.format("%d%s", num1 + 1, MULTIPLE_PAGES_SEPARATOR);
                              String key = null;
                              if (newDateList.size() >= param.getReportXmlTmplRepeat().getRepeatCountH()* forBiCount) {
                                key = String.format("%s%s-%d", pageStr, param.getId(), (num2 - (param.getReportXmlTmplRepeat().getRepeatCountH() * forBiCount)) + 1);
                              } else {
                                key = String.format("%s%s-%d", pageStr, param.getId(), num2 + 1);
                              }
                              // mod 11011 集計内訳タブ仕様変更 高 start
//                              if (type == 9 && reportType == 1 && tmplInfo.get(0).getSqlCode().equals(param.getSqlCode()) && "日".equals(params.get(0).getReportXmlTotalTable().getUnitDate())) {
                              if (type == 9 && reportType == 1 && "日".equals(params.get(0).getReportXmlTotalTable().getUnitDate())) {
                                // mod 11011 集計内訳タブ仕様変更 高 end
                                if (newDateList.size() != 0) {
                                  result.put(key, String.valueOf(newDateList.get(num2)));
                                  mediName.add(String.valueOf(newDateList.get(num2)));
                                }
                              }
                            }
                          }
                        }
                        mediName.clear();
                      }
                      dateArr1.clear();
                      mediNameCount.clear();
                    }
                  }
                }
              } else{
                int n=0;
                int pageCount = 0;
                int num = 0;
                if (group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_NO) {
                  num = 1;
                }
                else if (dataKey.get("newPageCountFlag") != null) {
                  num = 1;
                }
                else {
                  if (filteredList.size() == repeatMax) {
                    num = filteredList.size()/repeatMax;
                  } else if (filteredList.size() >= repeatMax && filteredList.size()%repeatMax ==0) {
                    num = filteredList.size()/repeatMax;
                  } else if (filteredList.size() >= repeatMax && filteredList.size()%repeatMax !=0) {
                    num = filteredList.size()/repeatMax +1;
                  } else if (filteredList.size() <= repeatMax) {
                    num = 1;
                  }
                }
                for (int index = 0;index < num ;index++) {
                  for (Integer i = n; i < filteredList.size(); i++) {
                    List<ReportXmlFilterTable> filters = param.getReportXmlFilters();
                    if (n >= repeatMax*(index+1)) {
                      break;
                    }
                    n++;
                    String outputData = "";
                    Set<String> keysSet = filteredList.get(i).keySet();
                    if (!keysSet.isEmpty()) {
                      String key1 = keysSet.toArray(new String[0])[0];
                      outputData = String.valueOf(filteredList.get(i).get(key1));
                    }
                    List<String> PatientEvents = new ArrayList<String>() {
                      {
                        for (int i = 84; i <= 94; i++) {
                          this.add(i + "");
                        }
                      }
                    };
                    if (filters == null || filters.size() == 0 || (outputData.equals(filters.get(0).getCode()) && !outputData.isEmpty()) || PatientEvents.contains(param.getSqlCode())) {
                      String key = "";
                      String value = "";
                      String pageStr = String.format("%d%s", index + 1, MULTIPLE_PAGES_SEPARATOR);
                      key = String.format("%s%s-%d", pageStr, param.getId(), (n -(repeatMax*index)));
                      // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                      //value = formatValue(param, filteredList.get(i).get(param.getDataCode()));
                      //value = convertValue(param, value);
                      value = reportServiceImpl.formatValue(param, filteredList.get(i).get(param.getDataCode()));
                      value = reportServiceImpl.convertValue(param, value);
                      // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                      // del #10385 患者イベント(画像)の出力が不正 高 start
//                      if (param.getIsImage().equals("true") && null != value && !value.equals("") && !value.equals("null")) {
//                        value = "(place)" + value;
//                      }
                      // del #10385 患者イベント(画像)の出力が不正 高 end
                      if (value != null && !"null".equals(value)) {
                        // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
                        // result.put(key, addLineBreak(value, param.getDispLength(), param.getDataType()));
                        // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                        //result.put(key, addLineBreak(value, param));
                        result.put(key, reportServiceImpl.addLineBreak(value, param));
                        // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                        // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
                      } else {
                        result.put(key, "");
                      }
                    }
                  }
                }
              }
            }
          });

        for (ReportXmlParam param : groupedParam.getValue()) {
          if (!(!StringUtils.isEmpty(param.getGroupId()) && param.isTmplRepeat() && type != 3 && type != 8)) {
            continue;
          }
          if (sqlCode != 31L) {
            // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
            //List<Map<String, Object>> filteredList = filterReportInfo(param, tmpList);
            List<Map<String, Object>> filteredList = reportServiceImpl.filterReportInfo(param, tmpList);
            // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
            if (filteredList.isEmpty()) {
              EventLogMessage eventLogMessage = new EventLogMessage();
              eventLogMessage.setLogMessage("帳票：フィルタ結果した結果が空");
              logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
              return;
            }
            boolean isNewPage = param.getReportXmlTmplRepeat().getIsNewPage() > 0;
            if(dataKey.get("newPageCountFlag") != null) isNewPage = false;
            if (filteredList.size()!= 0) {
              if (filteredList.get(0).get(unitH) != null) {
                ReportXmlTmplRepeat group = param.getReportXmlTmplRepeat();
                List dateArr = new ArrayList();
                LocalDate beforeDate;
                LocalDate afterDate;
                LocalDate newDate;
                DateTimeFormatter formatter;
                if (String.valueOf(dataKey.get("fromDate")).length()<=8) {
                  formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
                  beforeDate = LocalDate.parse(String.valueOf(dataKey.get("fromDate")).replace("-","/"),formatter);
                  afterDate = LocalDate.parse(String.valueOf(dataKey.get("toDate")).replace("-","/"),formatter);
                } else {
                  beforeDate = LocalDate.parse(String.valueOf(dataKey.get("fromDate")));
                  afterDate = LocalDate.parse(String.valueOf(dataKey.get("toDate")));
                  formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
                }
                DateTimeFormatter formatterOne = DateTimeFormatter.ofPattern("yyyy-MM-dd");
                do {
                  dateArr.add(beforeDate.format(formatterOne));
                  beforeDate = beforeDate.plusDays(1);
                } while(!beforeDate.isAfter(afterDate));
                List dateOrd = new ArrayList();
                List newDateList = new ArrayList();
                List<OrdMain> weekOrdMain = ordMainDao.selectPatOrdMainBetweenTreatDate(
                  Long.parseLong(String.valueOf(dataKey.get("patId"))), dataKey.get("facilityCd").toString(),
                  String.valueOf(dataKey.get("fromDate")).replace("/", "").replace("-", ""),
                  String.valueOf(dataKey.get("toDate")).replace("/", "").replace("-", ""));
                for (int  index = 0;index < weekOrdMain.size();index++) {
                  if (!dateOrd.contains(weekOrdMain.get(index).getTreatDate())) {
                    formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
                    newDate = LocalDate.parse(String.valueOf(weekOrdMain.get(index).getTreatDate()),formatter);
                    dateOrd.add(newDate.format(formatterOne));
                  }
                }
                for (int num = 0;num < dateArr.size();num++) {
                  if (dateOrd.contains(dateArr.get(num))) {
                    newDateList.add(dateArr.get(num));
                  }
                }
                // N
                if (param.getReportXmlTmplRepeat().getDirection().equals("0")) {
                  List<ReportXmlFilterTable> filters = param.getReportXmlFilters();
                  List mediNameCount = new ArrayList();
                  List dateArr1 = new ArrayList();
                  List mediName = new ArrayList();
                  int dateArrCountNum = 1;
                  int mediPageCountNum = 0;
                  Map<Object, List<Map<String, Object>>> groupedByCategory = filteredList.stream()
                    .collect(Collectors.groupingBy(map -> map.get(unitH).toString() + "-" + map.get(paramCode.get()).toString()));
                  int pageCount = 0;
                  for (int b = 0;b<newDateList.size();b++) {
                    if (!dateArr1.contains(newDateList.get(b))) {
                      dateArr1.add(newDateList.get(b));
                    }
                    if(b < (param.getReportXmlTmplRepeat().getRepeatCountH()*dateArrCountNum)-1) {
                      if (b != newDateList.size()-1) {
                        continue;
                      }
                    }
                    if ("項目値".equals(param.getReportXmlTotalTable().getContents())) {
                      if (mediNameCount.size() == 0) {
                        for (int a = 0;a <filteredList.size();a++) {
                          if (filteredList.get(a) != null) {
                            mediNameCount.add(filteredList.get(a).get(unitH).toString());
                          }
                        }
                      }
                    } else if ("合　計".equals(param.getReportXmlTotalTable().getContents())
                      ||"平均値".equals(param.getReportXmlTotalTable().getContents())
                      ||"最大値".equals(param.getReportXmlTotalTable().getContents())
                      ||"最小値".equals(param.getReportXmlTotalTable().getContents())){
                      for (int a = 0;a <filteredList.size();a++) {
                        if (!mediNameCount.contains(filteredList.get(a).get(unitH).toString())) {
                          mediNameCount.add(filteredList.get(a).get(unitH).toString());
                        }
                      }
                    }
                    dateArrCountNum++;
                    int mediCount = 0;
                    int beforePage = 0;
                    mediPageCountNum = pageCount;
                    beforePage = mediPageCountNum;
                    if (mediNameCount.size()!= 0&&param.getReportXmlTmplRepeat().getRepeatCountV()>=mediNameCount.size()) {
                      mediCount = mediPageCountNum+1;
                    } else if (mediNameCount.size()!= 0&&param.getReportXmlTmplRepeat().getRepeatCountV()<=mediNameCount.size()&&mediNameCount.size()%param.getReportXmlTmplRepeat().getRepeatCountV() == 0){
                      mediCount = mediPageCountNum+mediNameCount.size()/param.getReportXmlTmplRepeat().getRepeatCountV();
                    } else if (mediNameCount.size()!= 0&&param.getReportXmlTmplRepeat().getRepeatCountV()<=mediNameCount.size()&&mediNameCount.size()%param.getReportXmlTmplRepeat().getRepeatCountV() != 0) {
                      mediCount = mediPageCountNum+mediNameCount.size()/param.getReportXmlTmplRepeat().getRepeatCountV()+1;
                    } else if (dateArr1.size() != 0 &&param.getReportXmlTmplRepeat().getRepeatCountH()>=dateArr1.size()){
                      mediCount = mediPageCountNum+1;
                    } else if (dateArr1.size() != 0 &&param.getReportXmlTmplRepeat().getRepeatCountH()<=dateArr1.size()&&dateArr1.size()%param.getReportXmlTmplRepeat().getRepeatCountH() == 0){
                      mediCount = mediPageCountNum+dateArr1.size()/param.getReportXmlTmplRepeat().getRepeatCountH();
                    } else if (dateArr1.size()!= 0&&param.getReportXmlTmplRepeat().getRepeatCountH()<=dateArr1.size()&&dateArr1.size()%param.getReportXmlTmplRepeat().getRepeatCountH() != 0) {
                      mediCount = mediPageCountNum+dateArr1.size()/param.getReportXmlTmplRepeat().getRepeatCountH()+1;
                    }
                    pageCount = mediCount;
                    int v = 0;
                    int  f = 0;
                    if(isNewPage == false) mediCount = 1;
                    if ("項目値".equals(param.getReportXmlTotalTable().getContents())) {
                      for (int c =0;c < dateArr1.size();c++) {
                        int num2If = 0;
                        for (int num1 = mediPageCountNum;num1 < mediCount;num1++) {
                          mediPageCountNum++;
                          int rCount = isNewPage == false && filteredList.size() > param.getReportXmlTmplRepeat().getRepeatCountV() ? param.getReportXmlTmplRepeat().getRepeatCountV() : filteredList.size();
                          for(int d = v;d<rCount;d++) {
                            if(d>=param.getReportXmlTmplRepeat().getRepeatCountV()*(num2If+1)){
                              num2If++;
                              break;
                            }
                            v++;
                            if (d >= rCount-1) {
                              v= 0;
                              mediPageCountNum = beforePage;
                            }
                            ReportXmlTmplRepeat tmplRepeat = param.getReportXmlTmplRepeat();
                            String compareDate = "";
                            if(dateArr1.get(c).toString().length() < filteredList.get(d).get(unitV).toString().length()){
                              compareDate = filteredList.get(d).get(unitV).toString().substring(0,dateArr1.get(c).toString().length());
                            }else{
                              compareDate = filteredList.get(d).get(unitV).toString();
                            }
                            if (dateArr1.get(c).equals(compareDate)) {
                              String mediCountStr = "";
                              if (!StringUtils.isEmpty(conversion)) {
                                mediCountStr = String.valueOf(conversion);
                              } else {
                                double mediAllNumDou = 0.0;
                                BigDecimal decimalValue = new BigDecimal(filteredList.get(d).get(param.getDataCode()).toString());
                                mediAllNumDou = decimalValue.doubleValue();
                                mediCountStr = String.valueOf(mediAllNumDou);
                              }
                              if (filters == null || filters.size() == 0 || (filteredList.equals(filters.get(0).getCode()) && !filteredList.isEmpty())) {
                                String pageStr = String.format("%d%s", num1 + 1, MULTIPLE_PAGES_SEPARATOR);
                                String key = null;
                                String keyTmpl = String.format("%s-%d", tmplRepeat.getId(), c);
                                String keyParam = "";
                                keyParam = String.format("%s-%s", param.getId(), (d + 1) - (param.getReportXmlTmplRepeat().getRepeatCountV() * num2If));
                                key = String.format("%s%s.%s", pageStr, keyTmpl, keyParam);
                                // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                                //String value = formatValue(param, mediCountStr);
                                //value = convertValue(param, value);
                                String value = reportServiceImpl.formatValue(param, mediCountStr);
                                value = reportServiceImpl.convertValue(param, value);
                                // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                                paramIds.put(param.getId(), param.getId());
                                if (value != null && !"null".equals(value)) {
                                  // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
                                  // result.put(key, addLineBreak(value, param.getDispLength(), param.getDataType()));
                                  // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                                  //result.put(key, addLineBreak(value, param));
                                  result.put(key, reportServiceImpl.addLineBreak(value, param));
                                  // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                                  // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
                                } else {
                                  result.put(key, "");
                                }
                                if (!mediName.contains(filteredList.get(d).get(unitH).toString())) {
                                  mediName.add(filteredList.get(d).get(unitH).toString());
                                }
                              }
                            }
                          }
                        }
                      }
                    } else {
                      for (int c =0;c < dateArr1.size();c++) {

                        int num2If = 0;
                        for (int num1 = mediPageCountNum;num1 < mediCount;num1++) {
                          mediPageCountNum++;
                          int rCount = isNewPage == false && filteredList.size() > param.getReportXmlTmplRepeat().getRepeatCountV() ? param.getReportXmlTmplRepeat().getRepeatCountV() : filteredList.size();
                          for(int num2 = v;num2<rCount;num2++) {
                            if(num2>=param.getReportXmlTmplRepeat().getRepeatCountV()*(num2If+1)){
                              num2If++;
                              break;
                            }
                            v++;
                            if (num2 >= rCount-1) {
                              v= 0;
                              mediPageCountNum = beforePage;
                            }
                            ReportXmlTmplRepeat tmplRepeat = param.getReportXmlTmplRepeat();
                            for (int d =0;d < filteredList.size();d++) {
                              int mediAllNum = 0;
                              if (filteredList.get(d) != null && filteredList.get(d).size()!= 0) {
                                if ("合　計".equals(param.getReportXmlTotalTable().getContents())){
                                  if (dateArr1.get(c).equals(filteredList.get(d).get(unitV).toString())&&mediNameCount.get(num2).equals(filteredList.get(d).get(unitH).toString())) {
                                    if (groupedByCategory.get(filteredList.get(d).get(unitH).toString()+"-"+filteredList.get(d).get(unitV).toString())!= null) {
                                      String mediCountStr = "";

                                      double mediAllNumDou = 0.0;
                                      for (int number1 = 0; number1 <groupedByCategory.get(filteredList.get(d).get(unitH).toString()+"-"+filteredList.get(d).get(unitV)).size();number1++) {
                                        BigDecimal decimalValue = new BigDecimal(groupedByCategory.get(filteredList.get(d).get(unitH).toString()+"-"+filteredList.get(d).get(unitV)).get(number1).get(param.getDataCode()).toString());
                                        mediAllNumDou += decimalValue.doubleValue();
                                      }
                                      mediCountStr = String.valueOf(mediAllNumDou);
                                      groupedByCategory.remove(filteredList.get(d).get(unitH).toString()+"-"+filteredList.get(d).get(unitV));
                                      if(filters == null || filters.size() ==0 || (filteredList.equals(filters.get(0).getCode()) && !filteredList.isEmpty())){
                                        String pageStr = String.format("%d%s", num1 + 1, MULTIPLE_PAGES_SEPARATOR);
                                        String key = null;
                                        String keyTmpl = String.format("%s-%d", tmplRepeat.getId(), c);
                                        String keyParam = "";
                                        keyParam = String.format("%s-%s", param.getId(), (num2+1)-(param.getReportXmlTmplRepeat().getRepeatCountV()*num2If));
                                        key = String.format("%s%s.%s",pageStr, keyTmpl, keyParam);
                                        // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                                        //String value = formatValue(param, mediCountStr);
                                        //value = convertValue(param, value);
                                        String value = reportServiceImpl.formatValue(param, mediCountStr);
                                        value = reportServiceImpl.convertValue(param, value);
                                        // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                                        paramIds.put(param.getId(),param.getId());
                                        if (value != null && !"null".equals(value)) {
                                          // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
                                          // result.put(key, addLineBreak(value, param.getDispLength(), param.getDataType()));
                                          // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                                          //result.put(key, addLineBreak(value, param));
                                          result.put(key, reportServiceImpl.addLineBreak(value, param));
                                          // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                                          // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
                                        } else {
                                          result.put(key, "");
                                        }
                                        if (!mediName.contains(filteredList.get(d).get(unitH).toString())){
                                          mediName.add(filteredList.get(d).get(unitH).toString());
                                        }
                                      }
                                    }
                                  }
                                } else if ("平均値".equals(param.getReportXmlTotalTable().getContents())) {
                                  if (dateArr1.get(c).equals(filteredList.get(d).get(unitV).toString())&&mediNameCount.get(num2).equals(filteredList.get(d).get(unitH).toString())) {
                                    if (groupedByCategory.get(filteredList.get(d).get(unitH).toString()+"-"+filteredList.get(d).get(unitV).toString())!= null) {
                                      String mediCountStr = "";

                                      double mediAllNumDou = 0.0;
                                      for (int number1 = 0; number1 <groupedByCategory.get(filteredList.get(d).get(unitH).toString()+"-"+filteredList.get(d).get(unitV)).size();number1++) {
                                        BigDecimal decimalValue = new BigDecimal(groupedByCategory.get(filteredList.get(d).get(unitH).toString()+"-"+filteredList.get(d).get(unitV)).get(number1).get(param.getDataCode()).toString());
                                        mediAllNumDou += decimalValue.doubleValue();
                                      }
                                      double mediAllNumDouble = mediAllNumDou / groupedByCategory.get(filteredList.get(d).get(unitH).toString() + "-" + filteredList.get(d).get(unitV)).size();
                                      DecimalFormat df = new DecimalFormat("#.##");
                                      mediCountStr = df.format(mediAllNumDouble);
                                      groupedByCategory.remove(filteredList.get(d).get(unitH).toString()+"-"+filteredList.get(d).get(unitV));
                                      if(filters == null || filters.size() ==0 || (filteredList.equals(filters.get(0).getCode()) && !filteredList.isEmpty())){
                                        String pageStr = String.format("%d%s", num1 + 1, MULTIPLE_PAGES_SEPARATOR);
                                        String key = null;
                                        String keyTmpl = String.format("%s-%d", tmplRepeat.getId(), c);
                                        String keyParam = "";
                                        keyParam = String.format("%s-%s", param.getId(), (num2+1)-(param.getReportXmlTmplRepeat().getRepeatCountV()*num2If));
                                        key = String.format("%s%s.%s",pageStr, keyTmpl, keyParam);
                                        // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                                        //String value = formatValue(param, mediCountStr);
                                        //value = convertValue(param, value);
                                        String value = reportServiceImpl.formatValue(param, mediCountStr);
                                        value = reportServiceImpl.convertValue(param, value);
                                        // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                                        paramIds.put(param.getId(),param.getId());
                                        if (value != null && !"null".equals(value)) {
                                          // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
                                          // result.put(key, addLineBreak(value, param.getDispLength(), param.getDataType()));
                                          // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                                          //result.put(key, addLineBreak(value, param));
                                          result.put(key, reportServiceImpl.addLineBreak(value, param));
                                          // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                                          // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
                                        } else {
                                          result.put(key, "");
                                        }
                                        if (!mediName.contains(filteredList.get(d).get(unitH).toString())){
                                          mediName.add(filteredList.get(d).get(unitH).toString());
                                        }
                                      }
                                    }
                                  }
                                } else if ("最大値".equals(param.getReportXmlTotalTable().getContents())) {
                                  if (dateArr1.get(c).equals(filteredList.get(d).get(unitV).toString())&&mediNameCount.get(num2).equals(filteredList.get(d).get(unitH).toString())) {
                                    if (groupedByCategory.get(filteredList.get(d).get(unitH).toString()+"-"+filteredList.get(d).get(unitV).toString())!= null) {
                                      String mediCountStr = "";
                                      List maxValue = new ArrayList();
                                      for (int number1 = 0; number1 <groupedByCategory.get(filteredList.get(d).get(unitH).toString()+"-"+filteredList.get(d).get(unitV)).size();number1++) {
                                        BigDecimal decimalValue = new BigDecimal(groupedByCategory.get(filteredList.get(d).get(unitH).toString()+"-"+filteredList.get(d).get(unitV)).get(number1).get(param.getDataCode()).toString());
                                        maxValue.add(decimalValue.doubleValue());
                                      }
                                      mediCountStr = String.valueOf(Collections.max(maxValue));
                                      groupedByCategory.remove(filteredList.get(d).get(unitH).toString()+"-"+filteredList.get(d).get(unitV));
                                      if(filters == null || filters.size() ==0 || (filteredList.equals(filters.get(0).getCode()) && !filteredList.isEmpty())){
                                        String pageStr = String.format("%d%s", num1 + 1, MULTIPLE_PAGES_SEPARATOR);
                                        String key = null;
                                        String keyTmpl = String.format("%s-%d", tmplRepeat.getId(), c);
                                        String keyParam = "";
                                        keyParam = String.format("%s-%s", param.getId(), (num2+1)-(param.getReportXmlTmplRepeat().getRepeatCountV()*num2If));
                                        key = String.format("%s%s.%s",pageStr, keyTmpl, keyParam);
                                        // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
//                                        String value = formatValue(param, mediCountStr);
//                                        value = convertValue(param, value);
                                        String value = reportServiceImpl.formatValue(param, mediCountStr);
                                        value = reportServiceImpl.convertValue(param, value);
                                        // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                                        paramIds.put(param.getId(),param.getId());
                                        if (value != null && !"null".equals(value)) {
                                          // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
                                          // result.put(key, addLineBreak(value, param.getDispLength(), param.getDataType()));
                                          // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                                          //result.put(key, addLineBreak(value, param));
                                          result.put(key, reportServiceImpl.addLineBreak(value, param));
                                          // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                                          // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
                                        } else {
                                          result.put(key, "");
                                        }
                                        if (!mediName.contains(filteredList.get(d).get(unitH).toString())){
                                          mediName.add(filteredList.get(d).get(unitH).toString());
                                        }
                                      }
                                    }
                                  }
                                } else if ("最小値".equals(param.getReportXmlTotalTable().getContents())) {
                                  if (dateArr1.get(c).equals(filteredList.get(d).get(unitV).toString())&&mediNameCount.get(num2).equals(filteredList.get(d).get(unitH).toString())) {
                                    if (groupedByCategory.get(filteredList.get(d).get(unitH).toString()+"-"+filteredList.get(d).get(unitV).toString())!= null) {
                                      String mediCountStr = "";
                                      List minValue = new ArrayList();
                                      for (int number1 = 0; number1 <groupedByCategory.get(filteredList.get(d).get(unitH).toString()+"-"+filteredList.get(d).get(unitV)).size();number1++) {
                                        BigDecimal decimalValue = new BigDecimal(groupedByCategory.get(filteredList.get(d).get(unitH).toString()+"-"+filteredList.get(d).get(unitV)).get(number1).get(param.getDataCode()).toString());
                                        minValue.add(decimalValue.doubleValue());
                                      }
                                      mediCountStr = String.valueOf(Collections.min(minValue));
                                      groupedByCategory.remove(filteredList.get(d).get(unitH).toString()+"-"+filteredList.get(d).get(unitV));
                                      if(filters == null || filters.size() ==0 || (filteredList.equals(filters.get(0).getCode()) && !filteredList.isEmpty())){
                                        String pageStr = String.format("%d%s", num1 + 1, MULTIPLE_PAGES_SEPARATOR);
                                        String key = null;
                                        String keyTmpl = String.format("%s-%d", tmplRepeat.getId(), c);
                                        String keyParam = "";
                                        keyParam = String.format("%s-%s", param.getId(), (num2+1)-(param.getReportXmlTmplRepeat().getRepeatCountV()*num2If));
                                        key = String.format("%s%s.%s",pageStr, keyTmpl, keyParam);
                                        // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                                        //String value = formatValue(param, mediCountStr);
                                        //value = convertValue(param, value);
                                        String value = reportServiceImpl.formatValue(param, mediCountStr);
                                        value = reportServiceImpl.convertValue(param, value);
                                        // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                                        paramIds.put(param.getId(),param.getId());
                                        if (value != null && !"null".equals(value)) {
                                          // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
                                          // result.put(key, addLineBreak(value, param.getDispLength(), param.getDataType()));
                                          // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                                          //result.put(key, addLineBreak(value, param));
                                          result.put(key, reportServiceImpl.addLineBreak(value, param));
                                          // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                                          // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
                                        } else {
                                          result.put(key, "");
                                        }
                                        if (!mediName.contains(filteredList.get(d).get(unitH).toString())){
                                          mediName.add(filteredList.get(d).get(unitH).toString());
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                    dateArr1.clear();
                  }
                } else if (param.getReportXmlTmplRepeat().getDirection().equals("1")) {
                  List<ReportXmlFilterTable> filters = param.getReportXmlFilters();
                  List mediNameCount = new ArrayList();
                  List dateArr1 = new ArrayList();
                  List mediNameArr1 = new ArrayList();
                  List mediName = new ArrayList();
                  int dateArrCountNum = 1;
                  int pageCountNum = 0;
                  int mediPageCountNum = 0;
                  Map<Object, List<Map<String, Object>>> groupedByCategory = filteredList.stream()
                    .collect(Collectors.groupingBy(map -> map.get(unitH).toString() + "-" + map.get(unitV).toString()));
                  Map<Object, List<Map<String, Object>>> groupedByMediName = filteredList.stream()
                    .collect(Collectors.groupingBy(map -> map.get(unitH).toString()));
                  List mediNameArrList = new ArrayList();
                  for (int index = 0;index <filteredList.size();index++) {
                    if (newDateList.contains(filteredList.get(index).get(unitV).toString())) {
                      mediNameArrList.add(filteredList.get(index).get(unitH).toString());
                    }
                  }
                  if ("項目値".equals(param.getReportXmlTotalTable().getContents())) {
                    for (int index = 0;index <filteredList.size();index++) {
                      if (newDateList.contains(filteredList.get(index).get(unitV).toString())) {
                        mediNameArr1.add(filteredList.get(index).get(unitH).toString());
                      }
                    }
                  }else if ("合　計".equals(param.getReportXmlTotalTable().getContents())
                    ||"平均値".equals(param.getReportXmlTotalTable().getContents())
                    ||"最大値".equals(param.getReportXmlTotalTable().getContents())
                    ||"最小値".equals(param.getReportXmlTotalTable().getContents())){
                    for(Map.Entry<Object, List<Map<String, Object>>> entry : groupedByMediName.entrySet()){
                      if (mediNameArrList.contains(entry.getKey())) {
                        mediNameArr1.add(entry.getKey());
                      }
                    }
                    mediNameArr1.sort(Comparator.comparing(Object::toString, Collections.reverseOrder()));
                  }
                  int pageCount = 0;
                  for (int b =0;b <mediNameArr1.size();b++ ){
                    if ("項目値".equals(param.getReportXmlTotalTable().getContents())) {
                      mediNameCount.add(mediNameArr1.get(b));
                    } else if ("合　計".equals(param.getReportXmlTotalTable().getContents())
                      ||"平均値".equals(param.getReportXmlTotalTable().getContents())
                      ||"最大値".equals(param.getReportXmlTotalTable().getContents())
                      ||"最小値".equals(param.getReportXmlTotalTable().getContents())){
                      if (!mediNameCount.contains(mediNameArr1.get(b))) {
                        mediNameCount.add(mediNameArr1.get(b));
                      }
                    }
                    if(b < (param.getReportXmlTmplRepeat().getRepeatCountV()*dateArrCountNum)-1) {
                      if (b != mediNameArr1.size()-1) {
                        continue;
                      }
                    }
                    dateArrCountNum++;
                    int mediCount = 0;
                    int forCountNum = 0;
                    int beforePage = 0;
                    int forBiCount = 0;
                    int numOne = mediPageCountNum;
                    mediPageCountNum = pageCount;
                    beforePage = mediPageCountNum;
                    if (newDateList.size() != 0 &&param.getReportXmlTmplRepeat().getRepeatCountH()>=newDateList.size()){
                      mediCount = mediPageCountNum+1;
                    } else if (newDateList.size() != 0 &&param.getReportXmlTmplRepeat().getRepeatCountH()<=newDateList.size()&&newDateList.size()%param.getReportXmlTmplRepeat().getRepeatCountH() == 0){
                      mediCount = mediPageCountNum+newDateList.size()/param.getReportXmlTmplRepeat().getRepeatCountH();
                    } else if (newDateList.size()!= 0&&param.getReportXmlTmplRepeat().getRepeatCountH()<=newDateList.size()&&newDateList.size()%param.getReportXmlTmplRepeat().getRepeatCountH() != 0) {
                      mediCount = mediPageCountNum+newDateList.size()/param.getReportXmlTmplRepeat().getRepeatCountH()+1;
                    } else if (mediNameCount.size()!= 0&&param.getReportXmlTmplRepeat().getRepeatCountV()>=mediNameCount.size()) {
                      mediCount = mediPageCountNum+1;
                    } else if (mediNameCount.size()!= 0&&param.getReportXmlTmplRepeat().getRepeatCountV()<=mediNameCount.size()&&mediNameCount.size()%param.getReportXmlTmplRepeat().getRepeatCountV() == 0){
                      mediCount = mediPageCountNum+mediNameCount.size()/param.getReportXmlTmplRepeat().getRepeatCountV();
                    } else if (mediNameCount.size()!= 0&&param.getReportXmlTmplRepeat().getRepeatCountV()<=mediNameCount.size()&&mediNameCount.size()%param.getReportXmlTmplRepeat().getRepeatCountV() != 0) {
                      mediCount = mediPageCountNum+mediNameCount.size()/param.getReportXmlTmplRepeat().getRepeatCountV()+1;
                    }
                    pageCount = mediCount;

                    int f = 0;
                    int n = 0;
                    if ("項目値".equals(param.getReportXmlTotalTable().getContents())) {
                      filteredList = filteredList.stream().filter(p->p!=null).collect(toList());
                      for (int d = n;d<mediNameCount.size();d++) {
                        boolean flag = false;
                        if ("項目値".equals(param.getReportXmlTotalTable().getContents())) {
                          n = f;
                        }
                        int v = 0;
                        int en = 1;
                        for(int num1 = mediPageCountNum;num1 < mediCount;num1++){
                          if (isNewPage == false && (num1 + 1) > 1) {
                            continue;
                          }
                          mediPageCountNum++;
                          forBiCount++;
                          for(int c =v;c < newDateList.size();c++) {
                            if ("項目値".equals(param.getReportXmlTotalTable().getContents())) {
                              if (flag) {
                                v = (param.getReportXmlTmplRepeat().getRepeatCountH() * en);
                                mediPageCountNum = beforePage;
                                flag = false;
                                en++;
                                break;
                              }
                            }

                            if (c == 0) {
                              forBiCount = 0;
                            }
                            if (c >= param.getReportXmlTmplRepeat().getRepeatCountH() * (forBiCount + 1)) {
                              break;
                            }
                            v++;
                            if (c >= newDateList.size()-1) {
                              v= 0;
                              mediPageCountNum = beforePage;
                            }
                            ReportXmlTmplRepeat tmplRepeat = param.getReportXmlTmplRepeat();
                            if (filteredList.get(d) != null && filteredList.get(d).size()!= 0) {
                              if (newDateList.get(c).equals(filteredList.get(d).get(unitV).toString())&&mediNameCount.get(d).equals(filteredList.get(d).get(unitH).toString())) {
                                String mediCountStr = "";
                                if (!StringUtils.isEmpty(conversion)) {
                                  mediCountStr = String.valueOf(conversion);
                                } else {
                                  double mediAllNumDou = 0.0;
                                  BigDecimal decimalValue = new BigDecimal(filteredList.get(d).get(param.getDataCode()).toString());
                                  mediAllNumDou = decimalValue.doubleValue();
                                  mediCountStr = String.valueOf(mediAllNumDou);
                                }
                                if(filters == null || filters.size() ==0 || (filteredList.equals(filters.get(0).getCode()) && !filteredList.isEmpty())){
                                  String pageStr = String.format("%d%s", num1+1, MULTIPLE_PAGES_SEPARATOR);
                                  String key = null;
                                  String keyTmpl = String.format("%s-%d", tmplRepeat.getId(), c-(param.getReportXmlTmplRepeat().getRepeatCountH()*forBiCount));
                                  String keyParam = "";
                                  keyParam = String.format("%s-%s", param.getId(), (d+1));
                                  key = String.format("%s%s.%s",pageStr, keyTmpl, keyParam);
                                  // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                                  //String value = formatValue(param, mediCountStr);
                                  //value = convertValue(param, value);
                                  String value = reportServiceImpl.formatValue(param, mediCountStr);
                                  value = reportServiceImpl.convertValue(param, value);
                                  // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                                  paramIds.put(param.getId(),param.getId());
                                  if (value != null && !"null".equals(value)) {
                                    // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
                                    // result.put(key, addLineBreak(value, param.getDispLength(), param.getDataType()));
                                    // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                                    //result.put(key, addLineBreak(value, param));
                                    result.put(key, reportServiceImpl.addLineBreak(value, param));
                                    // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                                    // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
//                                        filteredList.remove(d);
                                    filteredList.set(d,null);
                                    f++;
                                    flag = true;
                                  } else {
                                    result.put(key, "");
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    } else {
                      for (int num2 = n;num2<mediNameCount.size();num2++) {
                        boolean flag = false;
                        int v = 0;
                        int en = 1;
                        for(int num1 = mediPageCountNum;num1 < mediCount;num1++){
                          mediPageCountNum++;
                          forBiCount++;
                          for(int c =v;c < newDateList.size();c++) {
                            if (c == 0) {
                              forBiCount = 0;
                            }
                            if (c >= param.getReportXmlTmplRepeat().getRepeatCountH() * (forBiCount + 1)) {
                              break;
                            }
                            v++;
                            if (c >= newDateList.size()-1) {
                              v= 0;
                              mediPageCountNum = beforePage;
                            }
                            if (isNewPage == false && (num1 + 1) > 1) {
                              continue;
                            }
                            ReportXmlTmplRepeat tmplRepeat = param.getReportXmlTmplRepeat();
                            for (int d =0;d < filteredList.size();d++) {
                              int mediAllNum = 0;
                              if (filteredList.get(d) != null && filteredList.get(d).size()!= 0) {
                                if ("合　計".equals(param.getReportXmlTotalTable().getContents())){
                                  if (newDateList.get(c).equals(filteredList.get(d).get(unitV).toString())&&mediNameCount.get(num2).equals(filteredList.get(d).get(unitH).toString())) {
                                    if (groupedByCategory.get(filteredList.get(d).get(unitH).toString()+"-"+filteredList.get(d).get(unitV).toString())!= null) {
                                      String mediCountStr = "";
                                      double mediAllNumDou = 0.0;
                                      for (int number1 = 0; number1 <groupedByCategory.get(filteredList.get(d).get(unitH).toString()+"-"+filteredList.get(d).get(unitV)).size();number1++) {
                                        BigDecimal decimalValue = new BigDecimal(groupedByCategory.get(filteredList.get(d).get(unitH).toString()+"-"+filteredList.get(d).get(unitV)).get(number1).get(param.getDataCode()).toString());
                                        mediAllNumDou += decimalValue.doubleValue();
                                      }
                                      mediCountStr = String.valueOf(mediAllNumDou);
                                      groupedByCategory.remove(filteredList.get(d).get(unitH).toString()+"-"+filteredList.get(d).get(unitV));
                                      if(filters == null || filters.size() ==0 || (filteredList.equals(filters.get(0).getCode()) && !filteredList.isEmpty())){
                                        String pageStr = String.format("%d%s", num1+1, MULTIPLE_PAGES_SEPARATOR);
                                        String key = null;
                                        String keyTmpl = String.format("%s-%d", tmplRepeat.getId(), c-(param.getReportXmlTmplRepeat().getRepeatCountH()*forBiCount));
                                        String keyParam = "";
                                        keyParam = String.format("%s-%s", param.getId(), (num2+1));
                                        key = String.format("%s%s.%s",pageStr, keyTmpl, keyParam);
                                        // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                                        //String value = formatValue(param, mediCountStr);
                                        //value = convertValue(param, value);
                                        String value = reportServiceImpl.formatValue(param, mediCountStr);
                                        value = reportServiceImpl.convertValue(param, value);
                                        // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                                        paramIds.put(param.getId(),param.getId());
                                        if (value != null && !"null".equals(value)) {
                                          // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
                                          // result.put(key, addLineBreak(value, param.getDispLength(), param.getDataType()));
                                          // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                                          //result.put(key, addLineBreak(value, param));
                                          result.put(key, reportServiceImpl.addLineBreak(value, param));
                                          // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                                          // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
                                        } else {
                                          result.put(key, "");
                                        }
                                        if (!mediName.contains(filteredList.get(d).get(unitH).toString())){
                                          mediName.add(filteredList.get(d).get(unitH).toString());
                                        }
                                      }
                                    }
                                  }
                                } else if ("平均値".equals(param.getReportXmlTotalTable().getContents())) {
                                  if (newDateList.get(c).equals(filteredList.get(d).get(unitV).toString())&&mediNameCount.get(num2).equals(filteredList.get(d).get(unitH).toString())) {
                                    if (groupedByCategory.get(filteredList.get(d).get(unitH).toString()+"-"+filteredList.get(d).get(unitV).toString())!= null) {
                                      String mediCountStr = "";
                                      double mediAllNumDou = 0.0;
                                      for (int number1 = 0; number1 <groupedByCategory.get(filteredList.get(d).get(unitH).toString()+"-"+filteredList.get(d).get(unitV)).size();number1++) {
                                        BigDecimal decimalValue = new BigDecimal(groupedByCategory.get(filteredList.get(d).get(unitH).toString()+"-"+filteredList.get(d).get(unitV)).get(number1).get(param.getDataCode()).toString());
                                        mediAllNumDou += decimalValue.doubleValue();
                                      }
                                      double mediAllNumDouble = mediAllNumDou / groupedByCategory.get(filteredList.get(d).get(unitH).toString() + "-" + filteredList.get(d).get(unitV)).size();
                                      DecimalFormat df = new DecimalFormat("#.##");
                                      mediCountStr = df.format(mediAllNumDouble);
                                      groupedByCategory.remove(filteredList.get(d).get(unitH).toString()+"-"+filteredList.get(d).get(unitV));
                                      if(filters == null || filters.size() ==0 || (filteredList.equals(filters.get(0).getCode()) && !filteredList.isEmpty())){
                                        String pageStr = String.format("%d%s", num1+1, MULTIPLE_PAGES_SEPARATOR);
                                        String key = null;
                                        String keyTmpl = String.format("%s-%d", tmplRepeat.getId(), c-(param.getReportXmlTmplRepeat().getRepeatCountH()*forBiCount));
                                        String keyParam = "";
                                        keyParam = String.format("%s-%s", param.getId(), (num2+1));
                                        key = String.format("%s%s.%s",pageStr, keyTmpl, keyParam);
                                        // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                                        //String value = formatValue(param, mediCountStr);
                                        //value = convertValue(param, value);
                                        String value = reportServiceImpl.formatValue(param, mediCountStr);
                                        value = reportServiceImpl.convertValue(param, value);
                                        // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                                        paramIds.put(param.getId(),param.getId());
                                        if (value != null && !"null".equals(value)) {
                                          // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
                                          // result.put(key, addLineBreak(value, param.getDispLength(), param.getDataType()));
                                          // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                                          //result.put(key, addLineBreak(value, param));
                                          result.put(key, reportServiceImpl.addLineBreak(value, param));
                                          // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                                          // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
                                        } else {
                                          result.put(key, "");
                                        }
                                        if (!mediName.contains(filteredList.get(d).get(unitH).toString())){
                                          mediName.add(filteredList.get(d).get(unitH).toString());
                                        }
                                      }
                                    }
                                  }
                                } else if ("最大値".equals(param.getReportXmlTotalTable().getContents())) {
                                  if (newDateList.get(c).equals(filteredList.get(d).get(unitV).toString())&&mediNameCount.get(num2).equals(filteredList.get(d).get(unitH).toString())) {
                                    if (groupedByCategory.get(filteredList.get(d).get(unitH).toString()+"-"+filteredList.get(d).get(unitV).toString())!= null) {
                                      String mediCountStr = "";
                                      List maxValue = new ArrayList();
                                      for (int number1 = 0; number1 <groupedByCategory.get(filteredList.get(d).get(unitH).toString()+"-"+filteredList.get(d).get(unitV)).size();number1++) {
                                        BigDecimal decimalValue = new BigDecimal(groupedByCategory.get(filteredList.get(d).get(unitH).toString()+"-"+filteredList.get(d).get(unitV)).get(number1).get(param.getDataCode()).toString());
                                        maxValue.add(decimalValue.doubleValue());
                                      }
                                      mediCountStr = String.valueOf(Collections.max(maxValue));
                                      groupedByCategory.remove(filteredList.get(d).get(unitH).toString()+"-"+filteredList.get(d).get(unitV));
                                      if(filters == null || filters.size() ==0 || (filteredList.equals(filters.get(0).getCode()) && !filteredList.isEmpty())){
                                        String pageStr = String.format("%d%s", num1+1, MULTIPLE_PAGES_SEPARATOR);
                                        String key = null;
                                        String keyTmpl = String.format("%s-%d", tmplRepeat.getId(), c-(param.getReportXmlTmplRepeat().getRepeatCountH()*forBiCount));
                                        String keyParam = "";
                                        keyParam = String.format("%s-%s", param.getId(), (num2+1));
                                        key = String.format("%s%s.%s",pageStr, keyTmpl, keyParam);
                                        // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                                        //String value = formatValue(param, mediCountStr);
                                        //value = convertValue(param, value);
                                        String value = reportServiceImpl.formatValue(param, mediCountStr);
                                        value = reportServiceImpl.convertValue(param, value);
                                        // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                                        paramIds.put(param.getId(),param.getId());
                                        if (value != null && !"null".equals(value)) {
                                          // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
                                          // result.put(key, addLineBreak(value, param.getDispLength(), param.getDataType()));
                                          // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                                          //result.put(key, addLineBreak(value, param));
                                          result.put(key, reportServiceImpl.addLineBreak(value, param));
                                          // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                                          // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
                                        } else {
                                          result.put(key, "");
                                        }
                                        if (!mediName.contains(filteredList.get(d).get(unitH).toString())){
                                          mediName.add(filteredList.get(d).get(unitH).toString());
                                        }
                                      }
                                    }
                                  }
                                } else if ("最小値".equals(param.getReportXmlTotalTable().getContents())) {
                                  if (newDateList.get(c).equals(filteredList.get(d).get(unitV).toString())&&mediNameCount.get(num2).equals(filteredList.get(d).get(unitH).toString())) {
                                    if (groupedByCategory.get(filteredList.get(d).get(unitH).toString()+"-"+filteredList.get(d).get(unitV).toString())!= null) {
                                      String mediCountStr = "";
                                      List minValue = new ArrayList();
                                      for (int number1 = 0; number1 <groupedByCategory.get(filteredList.get(d).get(unitH).toString()+"-"+filteredList.get(d).get(unitV)).size();number1++) {
                                        BigDecimal decimalValue = new BigDecimal(groupedByCategory.get(filteredList.get(d).get(unitH).toString()+"-"+filteredList.get(d).get(unitV)).get(number1).get(param.getDataCode()).toString());
                                        minValue.add(decimalValue.doubleValue());
                                      }
                                      mediCountStr = String.valueOf(Collections.min(minValue));
                                      groupedByCategory.remove(filteredList.get(d).get(unitH).toString()+"-"+filteredList.get(d).get(unitV));
                                      if(filters == null || filters.size() ==0 || (filteredList.equals(filters.get(0).getCode()) && !filteredList.isEmpty())){
                                        String pageStr = String.format("%d%s", num1+1, MULTIPLE_PAGES_SEPARATOR);
                                        String key = null;
                                        String keyTmpl = String.format("%s-%d", tmplRepeat.getId(), c-(param.getReportXmlTmplRepeat().getRepeatCountH()*forBiCount));
                                        String keyParam = "";
                                        keyParam = String.format("%s-%s", param.getId(), (num2+1));
                                        key = String.format("%s%s.%s",pageStr, keyTmpl, keyParam);
                                        // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                                        //String value = formatValue(param, mediCountStr);
                                        //value = convertValue(param, value);
                                        String value = reportServiceImpl.formatValue(param, mediCountStr);
                                        value = reportServiceImpl.convertValue(param, value);
                                        // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                                        paramIds.put(param.getId(),param.getId());
                                        if (value != null && !"null".equals(value)) {
                                          // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
                                          // result.put(key, addLineBreak(value, param.getDispLength(), param.getDataType()));
                                          // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                                          //result.put(key, addLineBreak(value, param));
                                          result.put(key, reportServiceImpl.addLineBreak(value, param));
                                          // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                                          // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
                                        } else {
                                          result.put(key, "");
                                        }
                                        if (!mediName.contains(filteredList.get(d).get(unitH).toString())){
                                          mediName.add(filteredList.get(d).get(unitH).toString());
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                    mediName.clear();
                    dateArr1.clear();
                    mediNameCount.clear();
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
        groupedParam.getValue().stream()
          .filter(param -> (StringUtils.isEmpty(param.getGroupId()) && param.isTmplRepeat()) || ReportConstant.ReportClass.MULTIPLE_PATIENT_REPORT.equals(type) || ReportConstant.ReportClass.LABEL_REPORT.equals(type))
          .forEach(param -> {
              int startPrintPos = 1;
              if(reportOutputInfo.get(0l).get(0).get("stPos")!=null){
                startPrintPos = (int)reportOutputInfo.get(0l).get(0).get("stPos");
              }
              else {
                boolean isLabel = false;
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
                        convertDataCodeToIdRepeatTmpl(result, tmpList, param, startPrintPos, isLabel);
                      }
                    } else {
                      convertDataCodeToIdRepeatTmpl(result, tmpList, param, startPrintPos, isLabel);
                    }
                  } else {
                    convertDataCodeToIdRepeatTmpl(result, tmpList, param, startPrintPos, isLabel);
                  }
                } else {
                  convertDataCodeToIdRepeatTmpl(result, tmpList, param, startPrintPos, isLabel);
                }
              }
            });
      }
      else {
        List<Map<String, Object>> tmpListArr = reportOutputInfo.get(Long.parseLong(String.valueOf(tmplInfo.get(0).getSqlCode())));
        if (tmpListArr == null|| tmpListArr.size()==0) {
          List dateArr = new ArrayList();
          LocalDate beforeDate;
          LocalDate afterDate;
          LocalDate newDate;
          DateTimeFormatter formatter;
          if (String.valueOf(dataKey.get("fromDate")).length()<=8) {
            formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
            beforeDate = LocalDate.parse(String.valueOf(dataKey.get("fromDate")).replace("-","/"),formatter);
            afterDate = LocalDate.parse(String.valueOf(dataKey.get("toDate")).replace("-","/"),formatter);
          } else {
            beforeDate = LocalDate.parse(String.valueOf(dataKey.get("fromDate")));
            afterDate = LocalDate.parse(String.valueOf(dataKey.get("toDate")));
            formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
          }
          DateTimeFormatter formatterOne = DateTimeFormatter.ofPattern("yyyy-MM-dd");
          do {
            dateArr.add(beforeDate.format(formatterOne));
            beforeDate = beforeDate.plusDays(1);
          } while(!beforeDate.isAfter(afterDate));
          List<OrdMain> weekOrdMain = ordMainDao.selectPatOrdMainBetweenTreatDate(
            Long.parseLong(String.valueOf(dataKey.get("patId"))), dataKey.get("facilityCd").toString(),
            String.valueOf(dataKey.get("fromDate")).replace("/", "").replace("-", ""),
            String.valueOf(dataKey.get("toDate")).replace("/", "").replace("-", ""));
          List dateOrd = new ArrayList();
          List newDateList = new ArrayList();
          for (int  index = 0;index < weekOrdMain.size();index++) {
            if (!dateOrd.contains(weekOrdMain.get(index).getTreatDate())) {
              formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
              newDate = LocalDate.parse(String.valueOf(weekOrdMain.get(index).getTreatDate()),formatter);
              dateOrd.add(newDate.format(formatterOne));
            }
          }
          for (int num = 0;num < dateArr.size();num++) {
            if (dateOrd.contains(dateArr.get(num))) {
              newDateList.add(dateArr.get(num));
            }
          }
          List dateArr1 = new ArrayList();
          int dateArrCountNum = 1;
          int pageCountNum = 0;
          for (int b = 0;b<newDateList.size();b++) {
            if (!dateArr1.contains(newDateList.get(b))) {
              dateArr1.add(newDateList.get(b));
            }
            if(b < (repeatCountH*dateArrCountNum)-1) {
              if (b != newDateList.size()-1) {
                continue;
              }
            }
            dateArrCountNum++;
            int mediCount = 0;
            if (dateArr1.size() != 0 && repeatCountH >= dateArr1.size()) {
              mediCount = pageCountNum + 1;
            } else if (dateArr1.size() != 0 && repeatCountH <= dateArr1.size() && dateArr1.size() % repeatCountH == 0) {
              mediCount = pageCountNum + dateArr1.size() / repeatCountH;
            } else if (dateArr1.size() != 0 && repeatCountH <= dateArr1.size() && dateArr1.size() % repeatCountH != 0) {
              mediCount = pageCountNum + dateArr1.size() / repeatCountH + 1;
            }
            String dateD = null;
            for (int i =0;i < params.size();i++) {
              // mod #11294 紹介状で集計部分がずれて出力される 高 start
//              if (params.get(i).getSqlCode().equals(tmplInfo.get(0).getSqlCode())&&params.get(i).getDataCode().equals(unitV)) {
              if ((params.get(i).getId().equals(params.get(0).getReportXmlTotalTable().getUnitVAddress()) ||
                params.get(i).getId().equals(params.get(0).getReportXmlTotalTable().getUnitHAddress())) && params.get(i).getDataCode().equals(unitV)) {
                // mod #11294 紹介状で集計部分がずれて出力される 高 end
                dateD = params.get(i).getId();
              }
            }
            for (int num1 = pageCountNum; num1 < mediCount; num1++) {
              // add #11294 紹介状で集計部分がずれて出力される 高 start
              if((dataKey.get("newPageCountFlag") != null &&  (num1 + 1) > 1) ||
                (params.get(0).getReportXmlTmplRepeat() != null && params.get(0).getReportXmlTmplRepeat().getIsNewPage() == 0 && (num1 + 1) > 1)) continue;
              // add #11294 紹介状で集計部分がずれて出力される 高 end
              pageCountNum++;
              for (int num2 = 0; num2 < dateArr1.size(); num2++) {
                String pageStr = String.format("%d%s", num1 + 1, MULTIPLE_PAGES_SEPARATOR);
                String key = String.format("%s%s-%d", pageStr, dateD, num2 + 1);
                // mod #11294 紹介状で集計部分がずれて出力される 高 start
//                if (type == 9 && reportType == 1 && "4".equals(tmplInfo.get(0).getSqlCode()) && "日".equals(params.get(0).getReportXmlTotalTable().getUnitDate())) {
                if (type == 9 && reportType == 1 && "日".equals(params.get(0).getReportXmlTotalTable().getUnitDate())) {
                  // mod #11294 紹介状で集計部分がずれて出力される 高 end
                  result.put(key, String.valueOf(dateArr1.get(num2)));
                }
              }
              dateArr1.clear();
            }
          }
        }
      }
    });
    // 補正データが存在する場合に処理を実施
    if (tmplCorrectData.repNumList.size() > 0) {
      // 降順にソートし、番号の大きい方(ページの後ろ)から処理を実施する
      List<String> descKeyList = new ArrayList<>();
      for (String keyStr : tmplCorrectData.repNumList.keySet()) {
        descKeyList.add(keyStr);
      }
      Collections.sort(descKeyList, Collections.reverseOrder());
      // 変更前key、変更後key を格納するリスト
      Map<String, String> replaceKeyList = new HashMap<>();
      for (String keyStr : descKeyList) {
        // tmplCorrectData.repNumList の key と value が同じ場合は処理不要の為スキップ
        String valueStr = tmplCorrectData.repNumList.get(keyStr);
        if (keyStr.equals(valueStr)) {
          continue;
        }
        // 応答データから変更するkeyを取得し、replaceKeyList に格納する
        for (String resultKey : result.keySet()) {
          // 正規表現に該当しない場合は処理対象のkeyではないためスキップ ( 該当するkeyの例：1#B7:L11-2.D11 )
          if (!resultKey.matches("^[0-9]{1,}#.*-[0-9]{1,}\\..{2,}$")) {
            continue;
          }
          // ページが異なる場合は処理をスキップ
          String[] tmpKeyStr = keyStr.split(MULTIPLE_PAGES_SEPARATOR);
          String keyPage = tmpKeyStr[0];
          String keyNumber = tmpKeyStr[1];
          String[] splitKeys = resultKey.split("\\.");
          String[] splitPage = splitKeys[0].split(MULTIPLE_PAGES_SEPARATOR);
          if (!splitPage[0].equals(keyPage)) {
            continue;
          }
          // 「.」直前の -n が変更対象の番号ではなかった場合は処理をスキップ
          int clipPoint = splitPage[1].indexOf("-") + 1;
          String repeatNum = splitPage[1].substring(clipPoint);
          if (!repeatNum.equals(keyNumber)) {
            continue;
          }
          // 「.」より後ろのセルが、処理除外対象セルリストに含まれるものであった場合は処理をスキップ
          boolean skipFlg = false;
          for (String cellStr : tmplCorrectData.cellList) {
            if (splitKeys[1].startsWith(cellStr)) {
              skipFlg = true;
            }
          }
          if (skipFlg) {
            continue;
          }
          // 修正後のkey を　修正前のkey と合わせて格納
          String[] tmpValueStr = valueStr.split(MULTIPLE_PAGES_SEPARATOR);
          String valuePage = tmpValueStr[0];
          String valueNumber = tmpValueStr[1];
          String replaceKey = valuePage + MULTIPLE_PAGES_SEPARATOR + splitPage[1].substring(0, clipPoint) + valueNumber + "." + splitKeys[1];
          replaceKeyList.put(resultKey, replaceKey);
        }
      }
      // 格納データを退避し、key を変更して再登録
      for (String beforeKey : replaceKeyList.keySet()) {
        String tmpData = result.get(beforeKey);
        result.remove(beforeKey);
        result.put(replaceKeyList.get(beforeKey), tmpData);
      }
    }
    // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy start
    ReportCommonUtil.pageAndPageCount(result, params, dataKey);
    // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy end
    return  result;
  }


  // add #11733 紹介状の集計内訳で縦の単位を複数列にすると正しく繰り返しされない limingzhe start
  private Map<String, String> ConvertDataForIntroductionTotal(
    List<ReportXmlParam> params,
    List<Map<Long, List<Map<String, Object>>>> reportOutputInfoList,
    Integer reportType,
    Map<String, Object> dataKey
  ){
    Map<String, String> result = new HashMap<>();

    ReportXmlTmplRepeat reportXmlTmplRepeat = params.size() > 0 ? params.get(0).getReportXmlTmplRepeat() : null;
    String tmplRepeatId = reportXmlTmplRepeat == null ? "" : reportXmlTmplRepeat.getId();
    Integer repeatCountV = reportXmlTmplRepeat == null ? 0 : reportXmlTmplRepeat.getRepeatCountV();
    Integer repeatCountH = reportXmlTmplRepeat == null ? 0 : reportXmlTmplRepeat.getRepeatCountH();
    String tmplRepeatDirection = reportXmlTmplRepeat == null ? "" : reportXmlTmplRepeat.getDirection();
    Integer isNewPage =  reportXmlTmplRepeat == null ? 0 : reportXmlTmplRepeat.getIsNewPage();

    ReportXmlTotalTable reportXmlTotalTable = params.size() > 0 ? params.get(0).getReportXmlTotalTable() : null;
    String unitV = reportXmlTotalTable == null ? "" : reportXmlTotalTable.getUnitV();
    String addressNewUnitV = reportXmlTotalTable == null ? "" : reportXmlTotalTable.getUnitVAddress();
    String unitH = reportXmlTotalTable == null ? "" : reportXmlTotalTable.getUnitH();
    String addressNewUnitH = reportXmlTotalTable == null ? "" : reportXmlTotalTable.getUnitHAddress();
    String unitDate = reportXmlTotalTable == null ? "" : reportXmlTotalTable.getUnitDate();
    String contents = reportXmlTotalTable == null ? "" : reportXmlTotalTable.getContents();
    String conversion = reportXmlTotalTable == null ? "" : reportXmlTotalTable.getConversion();

    List<String> total_UnitVList = Arrays.asList(unitV.split(",")).stream().distinct().collect(Collectors.toList());
    List<String> total_UnitVAddrList = Arrays.asList(addressNewUnitV.split(",")).stream().distinct().collect(Collectors.toList());
    List<String> total_UnitHList = Arrays.asList(unitH.split(",")).stream().distinct().collect(Collectors.toList());
    List<String> total_UnitHAddrList = Arrays.asList(addressNewUnitH.split(",")).stream().distinct().collect(Collectors.toList());

    List<ReportXmlParam> tmplInfo = params.stream().filter(item -> tmplRepeatId.equals(item.getId())).collect(Collectors.toCollection(ArrayList::new));

    Map<String, List<ReportXmlParam>> groupedParams = params.stream()
      .filter(p -> !StringUtils.isEmpty(p.getId()))
      .collect(Collectors.groupingBy(p -> p.getSqlCode()));

    for(Map<Long, List<Map<String, Object>>> reportOutputInfo :reportOutputInfoList) {
      // filter data
      groupedParams.entrySet().forEach(groupedParam -> {
        Long sqlCode;
        if (null != groupedParam.getKey() && groupedParam.getKey().equals("")) {
          sqlCode = Long.valueOf(0);
        } else {
          sqlCode = Long.valueOf(groupedParam.getKey());
        }
        List<Map<String, Object>> tmpList = reportOutputInfo.get(sqlCode);
        if (null == tmpList) {
          tmpList = new ArrayList<>();
        }
        List<Map<String, Object>> finalTmpList = tmpList;
        groupedParam.getValue().stream()
          .filter(param -> !StringUtils.isEmpty(param.getGroupId()) && !param.isTmplRepeat())
          .forEach(param -> {
            List<Map<String, Object>> filteredList = reportServiceImpl.filterReportInfo(param, finalTmpList);
            reportOutputInfo.put(sqlCode, filteredList);
          });
      });

      // 縦の単位 データ排列H_Hを隔开
      List<String> mediCdNo = new ArrayList<>();
      int pageSizel = 0;
      int paramShowFlag = 0; // 0:各データ項目は別々に表示されます 1:同名データの統合 2:同じバッチで同名のデータを統合する
      if ("合　計".equals(contents) || "平均値".equals(contents) || "最大値".equals(contents) || "最小値".equals(contents)) {
        paramShowFlag = 1;
      }
      // mod #11564 集計の横の単位設定が「日付」のとき同一の薬剤が一行にならない 高 start
//      else if(unitDate.equals("曜日")) {
      else if(unitDate.equals("曜日") || unitDate.equals("日")) {
        // mod #11564 集計の横の単位設定が「日付」のとき同一の薬剤が一行にならない 高 end
        paramShowFlag = 2;
      }
      if(paramShowFlag == 2) {
        pageSizel = reportOutputInfo.get(Long.valueOf(tmplInfo.get(0).getSqlCode())).stream().mapToInt(map -> {
          if (total_UnitHList != null && total_UnitHList.size() > 0) {
            String strUnitHInfo = "";
            if (map.containsKey("no")) {
              strUnitHInfo = map.get("no") + "z_z";
            }
            for (int i = 0; i < total_UnitHList.size(); i++) {
              if (map.get(total_UnitHList.get(i)) != null) strUnitHInfo += map.get(total_UnitHList.get(i)).toString();
              if (i < total_UnitHList.size() - 1) {
                strUnitHInfo += "H_H";
              }
            }
            if (!mediCdNo.contains(strUnitHInfo)) {
              mediCdNo.add(strUnitHInfo);
              return 1;
            }
          }
          return 0;
        }).sum();
      }
      else if(paramShowFlag == 1) {
        pageSizel = reportOutputInfo.get(Long.valueOf(tmplInfo.get(0).getSqlCode())).stream().mapToInt(map -> {
          if (total_UnitHList != null && total_UnitHList.size() > 0) {
            String strUnitHInfo = "";
            for (int i = 0; i < total_UnitHList.size(); i++) {
              if (map.get(total_UnitHList.get(i)) != null) strUnitHInfo += map.get(total_UnitHList.get(i)).toString();
              if (i < total_UnitHList.size() - 1) {
                strUnitHInfo += "H_H";
              }
            }
            if (!mediCdNo.contains(strUnitHInfo)) {
              mediCdNo.add(strUnitHInfo);
              return 1;
            }
          }
          return 0;
        }).sum();
      }
      else {
        List<Map<String, Object>> tmplInfoList = reportOutputInfo.get(Long.valueOf(tmplInfo.get(0).getSqlCode()));
        if(tmplInfoList != null && total_UnitHList != null && total_UnitHList.size() > 0){
          for(int iIndex = 0; iIndex < tmplInfoList.size(); iIndex++){
            String strUnitHInfo = "";
            strUnitHInfo = String.valueOf(iIndex) + "z_z";
            Integer HKeyLength = 0;
            for (int i = 0; i < total_UnitHList.size(); i++) {
              if (tmplInfoList.get(iIndex).get(total_UnitHList.get(i)) != null) {
                strUnitHInfo += tmplInfoList.get(iIndex).get(total_UnitHList.get(i)).toString();
                HKeyLength += tmplInfoList.get(iIndex).get(total_UnitHList.get(i)).toString().length();
              }
              if (i < total_UnitHList.size() - 1) {
                strUnitHInfo += "H_H";
              }
            }
            if (HKeyLength != 0) {
              mediCdNo.add(strUnitHInfo);
            }
          }
          pageSizel = mediCdNo.size();
        }
      }

      // 横の単位 データ排列V_Vを隔开
      Set<String> weeks = new HashSet<>();
      List<String> sortWeeks = new ArrayList<>();
      if(unitDate.equals("曜日")) {
        List<OrdMain> weekOrdMain = ordMainDao.selectPatOrdMainBetweenTreatDate(
          Long.parseLong(String.valueOf(dataKey.get("patId"))), dataKey.get("facilityCd").toString(),
          String.valueOf(dataKey.get("fromDate")).replace("/", "").replace("-", ""),
          String.valueOf(dataKey.get("toDate")).replace("/", "").replace("-", ""));
        for (OrdMain ordMain : weekOrdMain) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
          weeks.add(dateToWeek(ordMain.getTreatDate(),logService));
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
        }
        if (weeks.contains("月")) {
          sortWeeks.add("月");
        }
        if (weeks.contains("火")) {
          sortWeeks.add("火");
        }
        if (weeks.contains("水")) {
          sortWeeks.add("水");
        }
        if (weeks.contains("木")) {
          sortWeeks.add("木");
        }
        if (weeks.contains("金")) {
          sortWeeks.add("金");
        }
        if (weeks.contains("土")) {
          sortWeeks.add("土");
        }
        if (weeks.contains("日")) {
          sortWeeks.add("日");
        }
      }
      else {
        List<OrdMain> weekOrdMain = ordMainDao.selectPatOrdMainBetweenTreatDate(
          Long.parseLong(String.valueOf(dataKey.get("patId"))), dataKey.get("facilityCd").toString(),
          String.valueOf(dataKey.get("fromDate")).replace("/", "").replace("-", ""),
          String.valueOf(dataKey.get("toDate")).replace("/", "").replace("-", ""));
        for (OrdMain ordMain : weekOrdMain) {
          weeks.add(reportServiceImpl.getGroupKeybyDateType(ordMain.getTreatDate()));
        }
        sortWeeks = weeks.stream().sorted().collect(Collectors.toList());
      }

      // ページング数を計算する
      Integer page = 1;
      Integer pageH = 1;
      Integer pageV = 1;
      if(isNewPage == 1){
        if(weeks.size() > repeatCountH){
          if (weeks.size() % repeatCountH == 0) {
            pageH = weeks.size()/repeatCountH;
          } else {
            pageH = weeks.size()/repeatCountH + 1;
          }
        }
        if(pageSizel > repeatCountV){
          if (pageSizel % repeatCountV == 0) {
            pageV = pageSizel/repeatCountV;
          } else {
            pageV = pageSizel/repeatCountV + 1;
          }
        }
        page = pageH * pageV;
      }
      Integer finalPage = page <= 0 ? 1 : page;
      List<String> weekRepeatNames = new ArrayList<>();
      List<String> mediCdNoList = new ArrayList<>();
      if (pageSizel > repeatCountV) {
        // N
        if ("0".equals(tmplRepeatDirection)) {
          // treat_date
          for (int q = 0; q < pageH; q++) {
            List<String> subList = new ArrayList<>();
            if (((q + 1) * repeatCountH) > sortWeeks.size()) {
              subList.addAll(sortWeeks.subList(q * repeatCountH, sortWeeks.size()));
              int nullCount = subList.size();
              for (int e = 0; e < repeatCountH - nullCount; e++) {
                subList.add("null");
              }
            } else {
              subList = sortWeeks.subList(q * repeatCountH, (q + 1) * repeatCountH);
            }
            for (int l = 0; l < pageV; l++) {
              for (String a : subList) {
                weekRepeatNames.add(a);
              }
            }
          }
          // medi_name
          for (int l = 0; l < pageH; l++) {
            for (int q = 0; q < pageV; q++) {
              List<String> subList = new ArrayList<>();
              if (((q + 1) * repeatCountV) > mediCdNo.size()) {
                subList.addAll(mediCdNo.subList(q * repeatCountV, mediCdNo.size()));
                int nullCount = subList.size();
                for (int e = 0; e < repeatCountV - nullCount; e++) {
                  subList.add("null");
                }
              } else {
                subList = mediCdNo.subList(q * repeatCountV, (q + 1) * repeatCountV);
              }
              for (String a : subList) {
                mediCdNoList.add(a);
              }
            }
          }
        } else {
          // Z
          // treat_date
          for (int l = 0; l < pageV; l++) {
            for (int q = 0; q < pageH; q++) {
              List<String> subList = new ArrayList<>();
              if (((q + 1) * repeatCountH) > sortWeeks.size()) {
                subList.addAll(sortWeeks.subList(q * repeatCountH, sortWeeks.size()));
                int nullCount = subList.size();
                for (int e = 0; e < repeatCountH - nullCount; e++) {
                  subList.add("null");
                }
              } else {
                subList = sortWeeks.subList(q * repeatCountH, (q + 1) * repeatCountH);
              }
              for (String a : subList) {
                weekRepeatNames.add(a);
              }
            }
          }
          // medi_name
          for (int q = 0; q < pageV; q++) {
            List<String> subList = new ArrayList<>();
            if (((q + 1) * repeatCountV) > mediCdNo.size()) {
              subList.addAll(mediCdNo.subList(q * repeatCountV, mediCdNo.size()));
              int nullCount = subList.size();
              for (int e = 0; e < repeatCountV - nullCount; e++) {
                subList.add("null");
              }
            } else {
              subList = mediCdNo.subList(q * repeatCountV, (q + 1) * repeatCountV);
            }
            for (int l = 0; l < pageH; l++) {
              for (String a : subList) {
                mediCdNoList.add(a);
              }
            }
          }
        }
      }
      else {
        for (int l = 0; l < pageH; l++) {
          for (String a : mediCdNo) {
            mediCdNoList.add(a);
          }
          for (int i =0; i < repeatCountV - pageSizel; i++) {
            mediCdNoList.add("null");
          }
        }
        weekRepeatNames.addAll(sortWeeks);
      }
      int repeatH = 0;
      int repeatV = 0;
      if (mediCdNo.size() >= repeatCountV) {
        repeatV = repeatCountV;
      } else {
        repeatV = mediCdNo.size();
      }
      int  finalRepeatV = repeatV <= 0 ? 1 : repeatV;
      if (sortWeeks.size() > repeatCountH) {
        repeatH = repeatCountH;
      } else {
        repeatH = sortWeeks.size();
      }
      int finalRepeatH = repeatH <= 0 ? 1 : repeatH;

      List<String> finalSortWeeks = weekRepeatNames;
      List<String> finalmediCdNo = mediCdNoList;
      groupedParams.entrySet().forEach(groupedParam -> {
        Long sqlCode;
        if (null != groupedParam.getKey() && groupedParam.getKey().equals("")) {
          sqlCode = Long.valueOf(0);
        } else {
          sqlCode = Long.valueOf(groupedParam.getKey());
        }
        List<Map<String, Object>> tmpList = reportOutputInfo.get(sqlCode);
        if (null == tmpList) {
          tmpList = new ArrayList<>();
        }
        List<Map<String, Object>> tmpListItem = tmpList;
        Map<String, Object> tmpMap = new HashMap<>();
        if(!tmpList.isEmpty()) {
          tmpMap = tmpList.get(0);
        }
        Map<String, Object> finalTmpMap = tmpMap;

        // テンプレート
        List<Map<String, Object>> finalTmpList = tmpList;
        groupedParam.getValue().stream()
          .filter(param -> param.isTmplRepeat())
          .forEach(param -> {
            int repeatHCount = 0;
            int repeatVCount = 0;
            for(int i = 0 ; i < finalPage ; i++){
              if (dataKey.get("newPageCountFlag") != null && (i + 1) > 1) {
                break;
              }
              for (int j = 0; j < finalRepeatH; j++) {
                if (repeatHCount >= finalSortWeeks.size()) {
                  break;
                }
                for (int k = 0; k < finalRepeatV; k++) {
                  String pageStr = String.format("%d%s", i + 1, MULTIPLE_PAGES_SEPARATOR);
                  String key = String.format("%s%s-%d.%s-%d", pageStr, param.getId() , j, param.getId(), k + 1);
                  if (j + repeatCountH * i >= finalSortWeeks.size() || k + repeatCountV * i >= finalmediCdNo.size()) {
                    break;
                  }
                  String week = finalSortWeeks.get(j + repeatCountH * i);
                  String mediCd = finalmediCdNo.get(k + repeatCountV * i);
                  if (null == week || "null".equals(week) || null == mediCd || "null".equals(mediCd)) {
                    break;
                  }
                  String value =  "";
                  if ("項目値".equals(contents)) {
                    Map<String, Object> mapValue = new HashMap<>();
                    for(int fIndex = 0; fIndex < finalTmpList.size(); fIndex++){
                      Map<String, Object> curInfo = finalTmpList.get(fIndex);
                      if(unitDate.equals("曜日")) {
                        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
                        if(!week.equals(dateToWeek(String.valueOf(curInfo.get(unitV)),logService))) continue;
                        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
                        if(curInfo.containsKey("no") && mediCd.contains("z_z")){
                          if(!curInfo.get("no").equals(mediCd.split("z_z")[0])) continue;
                        }
                      }
                      // add #11564 集計の横の単位設定が「日付」のとき同一の薬剤が一行にならない 高 start
                      else if (unitDate.equals("日")) {
                        if(!week.equals(String.valueOf(curInfo.get(unitV)).replace("-","").replace("/",""))) continue;
                        if(curInfo.containsKey("no") && mediCd.contains("z_z")){
                          if(!curInfo.get("no").equals(mediCd.split("z_z")[0])) continue;
                        }
                      }
                      // add #11564 集計の横の単位設定が「日付」のとき同一の薬剤が一行にならない 高 end
                      else {
                        if(!week.equals(reportServiceImpl.getGroupKeybyDateType(String.valueOf(curInfo.get(unitV))))) continue;
                        if(mediCd.contains("z_z")){
                          if(!String.valueOf(fIndex).equals(mediCd.split("z_z")[0])) continue;
                        }
                      }
                      // mod #10224 集計紹介状、集計表の出力順について再精査 高 start
//                      for(int hTIndex = 0; hTIndex < total_UnitHList.size(); hTIndex++){
//                        if(!mediCd.contains(String.valueOf(curInfo.get(total_UnitHList.get(hTIndex))))) continue;
//                      }
                      boolean skipOuter = false;
                      for(int hTIndex = 0; hTIndex < total_UnitHList.size(); hTIndex++){
                        if (mediCd.contains("z_z") || mediCd.contains("H_H")) {
                          if(!mediCd.contains(String.valueOf(curInfo.get(total_UnitHList.get(hTIndex))))) {
                            skipOuter = true;
                            continue;
                          } else {
                            skipOuter = false;
                            break;
                          }
                        } else {
                          if(!mediCd.equals(String.valueOf(curInfo.get(total_UnitHList.get(hTIndex))))) {
                            skipOuter = true;
                            continue;
                          } else {
                            skipOuter = false;
                            break;
                          }
                        }
                      }
                      if (skipOuter) continue;
                      // mod #10224 集計紹介状、集計表の出力順について再精査 高 end
                      mapValue = curInfo;
                      break;
                    }
                    value = String.valueOf(mapValue == null || mapValue.size() == 0 ? "" : mapValue.get(tmplInfo.get(0).getDataCode()));
                  }
                  else {
                    List<Map<String, Object>> infoList = new ArrayList<>();
                    for(int fIndex = 0; fIndex < finalTmpList.size(); fIndex++){
                      Map<String, Object> curInfo = finalTmpList.get(fIndex);
                      if(unitDate.equals("曜日")) {
                        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
                        if(!week.equals(dateToWeek(String.valueOf(curInfo.get(unitV)),logService))) continue;
                        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
                      }
                      else {
                        if(!week.equals(reportServiceImpl.getGroupKeybyDateType(String.valueOf(curInfo.get(unitV))))) continue;
                      }
                      for(int hTIndex = 0; hTIndex < total_UnitHList.size(); hTIndex++){
                        if(!mediCd.contains(String.valueOf(curInfo.get(total_UnitHList.get(hTIndex))))) continue;
                        // add #11564 集計の横の単位設定が「日付」のとき同一の薬剤が一行にならない 高 start
                        else infoList.add(curInfo);
                        // add #11564 集計の横の単位設定が「日付」のとき同一の薬剤が一行にならない 高 end
                      }
                      // del #11564 集計の横の単位設定が「日付」のとき同一の薬剤が一行にならない 高 start
//                      infoList.add(curInfo);
                      // del #11564 集計の横の単位設定が「日付」のとき同一の薬剤が一行にならない 高 end
                    }
                    if ("合　計".equals(contents)) {
                      double valueSum = 0D;
                      if (null != infoList && infoList.size() > 0) {
                        valueSum = infoList.stream().mapToDouble(map -> Double.valueOf(map.get(tmplInfo.get(0).getDataCode()).toString())).sum();
                      }
                      value = String.valueOf(valueSum);
                    }
                    else if ("平均値".equals(contents)) {
                      double valueAvg = 0D;
                      String valueAvgStr = "";
                      if (null != infoList && infoList.size() > 0) {
                        int count = 0;
                        for (Map<String, Object> map : infoList) {
                          valueAvg += Double.valueOf(map.get(tmplInfo.get(0).getDataCode()).toString());
                          count++;
                        }
                        DecimalFormat df = new DecimalFormat("#.##");
                        if (count > 0) {
                          valueAvgStr = df.format(valueAvg / count);
                        }
                      }
                      value = valueAvgStr;
                    }
                    else if ("最大値".equals(contents)) {
                      OptionalDouble valueMax = null;
                      if (null != infoList && infoList.size() > 0) {
                        valueMax = infoList.stream().mapToDouble(map -> Double.valueOf(map.get(tmplInfo.get(0).getDataCode()).toString())).max();
                      }
                      value = String.valueOf(valueMax == null ? "" : valueMax.getAsDouble());
                    }
                    else if ("最小値".equals(contents)) {
                      OptionalDouble valueMin = null;
                      if (null != infoList && infoList.size() > 0) {
                        valueMin = infoList.stream().mapToDouble(map -> Double.valueOf(map.get(tmplInfo.get(0).getDataCode()).toString())).min();
                      }
                      value = String.valueOf(valueMin == null ? "" : valueMin.getAsDouble());
                    }
                  }
                  if (!StringUtils.isEmpty(value) && !"0.0".equals(value)) {
                    if (!StringUtils.isEmpty(conversion) && "項目値".equals(contents)) {
                      value = conversion;
                    }
                    result.put(key, value);
                  }
                  repeatVCount++;
                }
                repeatHCount ++;
              }
            }
          });

        // グループ
        groupedParam.getValue().stream()
          .filter(param -> !StringUtils.isEmpty(param.getGroupId()) && !param.isTmplRepeat())
          .forEach(param -> {
            ReportXmlGroup group = param.getReportXmlGroup();
            // 横、縦の単位
            if (total_UnitHAddrList.contains(param.getId()) || total_UnitVAddrList.contains(param.getId())){
              List<String> repeatCircle = new ArrayList<>();
              List<String> repeatCircleMedic = new ArrayList<>();
              repeatCircle.addAll(finalSortWeeks);
              repeatCircleMedic.addAll(finalmediCdNo);
              for (Integer pageCount = 0; pageCount < finalPage; pageCount++) {
                if (dataKey.get("newPageCountFlag") != null && (pageCount + 1) > 1) {
                  break;
                }
                String value = "";
                String key = "";
                if (total_UnitVList.contains(param.getDataCode()) && total_UnitVAddrList.contains(param.getId())) {
                  for (int w = 0; w < repeatCountH; w++) {
                    int nullCount = repeatCircle.size();
                    boolean isNextPage = false;
                    for (int i = 0; i < nullCount; i++) {
                      if (!"null".equals(repeatCircle.get(0))) {
                        break;
                      }
                      repeatCircle.remove(0);
                      isNextPage = true;
                    }
                    if (repeatCircle.size() <= 0 || isNextPage) {
                      break;
                    }
                    String pageStr = String.format("%d%s", pageCount + 1, MULTIPLE_PAGES_SEPARATOR);
                    key = String.format("%s%s-%d", pageStr, param.getId(), w + 1);
                    value = repeatCircle.get(0);
                    result.put(key, value);
                    repeatCircle.remove(0);
                  }
                }
                else if (total_UnitHList.contains(param.getDataCode()) && total_UnitHAddrList.contains(param.getId())) {
                  for (int w = 0; w < repeatCountV; w++) {
                    int nullCount = repeatCircleMedic.size();
                    boolean isNextPage = false;
                    for (int i = 0; i < nullCount; i++) {
                      if (!"null".equals(repeatCircleMedic.get(0))) {
                        break;
                      }
                      repeatCircleMedic.remove(0);
                      isNextPage = true;
                    }
                    if (repeatCircleMedic.size() <= 0 || isNextPage) {
                      break;
                    }
                    String pageStr = String.format("%d%s", pageCount + 1, MULTIPLE_PAGES_SEPARATOR);
                    key = String.format("%s%s-%d", pageStr, param.getId(), w + 1);
                    if ("項目値".equals(contents)) {
                      if (repeatCircleMedic.get(0).contains("z_z")) {
                        value = repeatCircleMedic.get(0).split("z_z")[1];
                      } else {
                        value = repeatCircleMedic.get(0);
                      }
                    } else {
                      value = repeatCircleMedic.get(0);
                    }
                    String vArr[] = value.split("H_H");
                    for(int i = 0; i < total_UnitHList.size(); i++){
                      if(total_UnitHList.get(i).equals(param.getDataCode())){
                        // add #11733 紹介状の集計内訳で縦の単位を複数列にすると正しく繰り返しされない limingzhe 20250623 start
                        if(i >= vArr.length) {
                          value = "";
                          break;
                        }
                        // add #11733 紹介状の集計内訳で縦の単位を複数列にすると正しく繰り返しされない limingzhe 20250623 end
                        value = vArr[i];
                      }
                    }
                    value = reportServiceImpl.convertValue(param, value);
                    result.put(key, value);
                    repeatCircleMedic.remove(0);
                  }
                }
              }
            }
            else {
              List<Map<String, Object>> filteredList = reportServiceImpl.filterReportInfo(param, tmpListItem);
              // 1ページの繰り返し件数を取得する
              Integer repeatMax = (group != null && group.getRepeatMax() != null) ? group.getRepeatMax() : 1;
              Integer repeatOfPage;
              if (group != null && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_YES) {
                repeatOfPage = (filteredList.size() > group.getRepeatMax()) ? group.getRepeatMax() : filteredList.size();
              } else {
                repeatOfPage = filteredList.size();
              }
              Integer pageMAX = repeatOfPage > 0 ? filteredList.size() / repeatOfPage : 0;
              // ページ数分、以下の処理を行う
              int limitCount = repeatOfPage;
              for (Integer pageCount = 0; pageCount <= pageMAX; pageCount++) {
                if (dataKey.get("newPageCountFlag") != null && (pageCount + 1) > 1) {
                  break;
                }
                int skipCount = pageCount * limitCount;
                // id属性値をkey、出力値をvalue に設定する（複数項目の場合、id属性値に連番を付加する）
                List<Map<String, Object>> outputInfos = filteredList.stream().skip(skipCount).limit(repeatMax).collect(toList());
                int n=0;
                String value = "";
                String key = "";
                if (group != null && group.getRepeatMax() <= 1) {
                  for (Integer i = 0; i < outputInfos.size(); i++) {
                    // mod #12231 グループ繰り返しOFFの項目群が2ページ目に1ページ目と同じ内容にならない 高 start
                    if (!StringUtils.isEmpty(group) && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_YES){
                      String pageStr = String.format("%d%s", pageCount + 1, MULTIPLE_PAGES_SEPARATOR);
                      key = String.format("%s%s-%d", pageStr, param.getId(),1);
                    } else {
                      key = param.getId();
                    }
//                    key = param.getId();
                    // mod #12231 グループ繰り返しOFFの項目群が2ページ目に1ページ目と同じ内容にならない 高 end
                    value = reportServiceImpl.formatValue(param, outputInfos.get(i).get(param.getDataCode()));
                    value = reportServiceImpl.convertValue(param, value);
                    // del #10385 患者イベント(画像)の出力が不正 高 start
//                    if (param.getIsImage().equals("true") && null != value && !value.equals("") && !value.equals("null")) {
//                      value = "(place)" + value;
//                    }
                    // del #10385 患者イベント(画像)の出力が不正 高 end
                    if (value != null && !"null".equals(value)) {
                      result.put(key, reportServiceImpl.addLineBreak(value, param));
                    } else {
                      result.put(key, "");
                    }
                    n++;
                  }
                } else {
                  for (int j = 0; j < outputInfos.size(); j ++) {
                    // mod #12231 グループ繰り返しOFFの項目群が2ページ目に1ページ目と同じ内容にならない 高 start
//                    String pageStr = String.format("%d%s", pageCount + 1, MULTIPLE_PAGES_SEPARATOR);
                    String pageStr = "";
                    if (!StringUtils.isEmpty(group) && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_YES){
                      pageStr = String.format("%d%s", pageCount + 1, MULTIPLE_PAGES_SEPARATOR);
                    }
                    // mod #12231 グループ繰り返しOFFの項目群が2ページ目に1ページ目と同じ内容にならない 高 end
                    key = String.format("%s%s-%d", pageStr, param.getId(), n + 1);
                    value = reportServiceImpl.formatValue(param, outputInfos.get(j).get(param.getDataCode()));
                    value = reportServiceImpl.convertValue(param, value);
                    // del #10385 患者イベント(画像)の出力が不正 高 start
//                    if (param.getIsImage().equals("true") && null != value && !value.equals("") && !value.equals("null")) {
//                      value = "(place)" + value;
//                    }
                    // del #10385 患者イベント(画像)の出力が不正 高 end
                    if (value != null && !"null".equals(value)) {
                      result.put(key, reportServiceImpl.addLineBreak(value, param));
                    } else {
                      result.put(key, "");
                    }
                    n++;
                  }
                }
              }
            }
          });

        // パラメータ
        groupedParam.getValue().stream()
          .filter(param -> StringUtils.isEmpty(param.getGroupId()) && !param.isTmplRepeat())
          .forEach(param -> {
            if("1".equals(param.getIsNewPage())){
              for (int i = 0; i < tmpListItem.size(); i++) {
                if (dataKey.get("newPageCountFlag") != null && (i + 1) > 1) {
                  break;
                }
                Map<String, Object> tmp = tmpListItem.get(i);
                String key = String.format("%d%s", i + 1, MULTIPLE_PAGES_SEPARATOR) + param.getId();
                if(unitDate.equals("曜日")){
                  key = String.format("%s%s%d", param.getId(), "$", i + 1);
                }
                String value = reportServiceImpl.formatValue(param, tmp.get(param.getDataCode()));
                value = reportServiceImpl.convertValue(param, value);

                if (value != null && !"null".equals(value)) {
                  result.put(key, reportServiceImpl.addLineBreak(value, param));
                } else {
                  result.put(key, "");
                }
              }
            }
            else {
              String key = param.getId();
              if(unitDate.equals("曜日")){
                key =  String.format("%s%s%d", param.getId(), "$", 1);
              }
              String value = reportServiceImpl.formatValue(param, finalTmpMap.get(param.getDataCode()));
              value = reportServiceImpl.convertValue(param, value);

              if (value != null && !"null".equals(value)) {
                result.put(key, reportServiceImpl.addLineBreak(value, param));
              } else {
                result.put(key, "");
              }
            }
          });
      });
    }
    // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy start
    ReportCommonUtil.pageAndPageCount(result,params,dataKey);
    // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy end
    return result;
  }
  // add #11733 紹介状の集計内訳で縦の単位を複数列にすると正しく繰り返しされない limingzhe end

  // mod #11226 患者情報系historyの取得条件見直し② limingzhe start
  //private Map<String, String> convertDataCodeToId(List<ReportXmlParam> params, Map<Long, List<Map<String, Object>>> reportOutputInfo, Integer type, Integer reportType,
  //                                                Map<String, Long> patIdToCMap, Map<String, Object> dataKey, MstReport.Extraction extractionCondition) {
  private Map<String, String> convertDataCodeToId(List<ReportXmlParam> params, Map<Long, List<Map<String, Object>>> reportOutputInfo, Map<Long, List<Map<String, Object>>> reportInTmplInfo, List<Long> keyNoList, Integer type, Integer reportType,
                                                  Map<String, Long> patIdToCMap, Map<String, Object> dataKey, MstReport.Extraction extractionCondition) {
  // mod #11226 患者情報系historyの取得条件見直し② limingzhe end
    Map<String, String> paramIds = new HashMap<>();
    TmplCorrectData tmplCorrectData = new TmplCorrectData();

    Map<String, String> result = new HashMap<>();
    List<Long> ordDataList = new ArrayList<>();
    List<Object> ordNos = (List)dataKey.get("ordNos");
    if(null !=ordNos&&ordNos.size()>0){
      for(int i=0;i<ordNos.size();i++){
        if( ordNos.get(i) instanceof  Long){
          Long ordNo = Long.parseLong(ordNos.get(i).toString());
          ordDataList.add(ordNo);
        }else if( ordNos.get(i) instanceof OrdMain){
          OrdMain ordMain = (OrdMain) ordNos.get(i);
          ordDataList.add(ordMain.getOrdNo());
        }
      }
    }
    Map<String, List<ReportXmlParam>> groupIdListInTmpl =
      params.stream()
        .filter(param -> param.isTmplRepeat())
        .collect(Collectors.groupingBy(ReportXmlParam::getGroupId));
    Integer repeatTMax = 0;
    String groupStr = "";
    List doReportName = new ArrayList();
    Map<String, Integer> tmpSkipCountMap = new HashMap<>();
    tmpSkipCountMap.put(TMP_SKIP_COUNT, 0);

    for (int count = 0; count < params.size(); count++){
      if ("medicine_name".equals(params.get(count).getDataCode())){
        repeatTMax = params.get(count).getReportXmlTmplRepeat().getRepeatMax();
        groupStr = params.get(count).getGroupId();
        break;
      }
    }
    for (String doStr : groupIdListInTmpl.keySet()){
      if (groupStr.equals(doStr)){
        List<ReportXmlParam> doReportParam = groupIdListInTmpl.get(doStr);
        for (int u = 0; u < doReportParam.size(); u++){
          doReportName.add(doReportParam.get(u).getDataCode());
        }
        break;
      }
    }
    // 複数項目のページ数より、単一項目のページ数を設定する
    Map<String, Integer> resultTemp = new HashMap<>();
    // 単一項目のページ数の標準値に1ページ数を設定する
    resultTemp.put("GROUP_DATA_PAGE_COUNT", 1);

    // sqlCode属性値でグループ化したParam要素情報を取得する
    // mod #10650 検査結果（指定日以前）の仕様課題 2025/02/26 高 start
//    Map<String, List<ReportXmlParam>> groupedParams = params.stream()
//      // mod #11226 患者情報系historyの取得条件見直し② limingzhe start
//      //.filter(p -> !StringUtils.isEmpty(p.getId()))
//      .filter(p -> !StringUtils.isEmpty(p.getId()) && !p.isTmplRepeat())
//      // mod #11226 患者情報系historyの取得条件見直し② limingzhe end
//      .collect(Collectors.groupingBy(p -> p.getSqlCode()))
//      ;
    Map<String, List<ReportXmlParam>> groupedParams = params.stream()
      .filter(p -> !StringUtils.isEmpty(p.getId()) && !StringUtils.isEmpty(p.getSqlCode())
        || ("1".equals(p.getIsInTmpl()) && String.valueOf(p.getSqlCode()).matches(".*9999931$")))
      .collect(Collectors.groupingBy(p -> p.getSqlCode()));
    List<String> sqlCodes = getSqlCode(params);
    // mod #10650 検査結果（指定日以前）の仕様課題 2025/02/26 高 end
    // mod #10857 帳票内に同項目が複数あると設定値を取り違える 高 start
//    List<Integer> sqlCode1 = new ArrayList<Integer>();
//    for(String sql : sqlCodes){
//      sqlCode1.add(Integer.valueOf(sql));
//    }
//    Collections.sort(sqlCode1);
//    LinkedHashMap<String, List<ReportXmlParam>> newGroupe = new LinkedHashMap<>();
//    for(Integer sql : sqlCode1){
//      if (groupedParams.get(sql.toString()) != null) {
//        newGroupe.put(sql.toString(),groupedParams.get(sql.toString()));
//      }
//    }
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
    // mod #10857 帳票内に同項目が複数あると設定値を取り違える 高 end
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

      Map<String, Object> dataKeyValues = new HashMap<>();
      if (tmpList !=null && tmpList.size() > 0){
        if (tmpList.get(0).containsKey("pat_last_name_id")){
          for (int i = 0; i < tmpList.size(); i++){
            Long patIdToC = 0L;
            if (patIdToCMap.get(PAT_ID_TO_C) != null) {
              patIdToC = patIdToCMap.get(PAT_ID_TO_C);
            }
            if (patIdToC != null && patIdToC.equals(tmpList.get(i).get("patId"))){
              dataKeyValues = tmpList.get(i);
              break;
            }
          }
        }
      }
      if (tmpList!=null && !tmpList.isEmpty()) {
        // 複数項目のページ数より、単一項目のページ数を設定する
        groupedParam.getValue().stream()
          .filter(param -> !StringUtils.isEmpty(param.getGroupId()) && !param.isTmplRepeat())
          .forEach(param -> {
            // フィルタ処理を行う
            // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
            //List<Map<String, Object>> filteredList = filterReportInfo(param, tmpList);
            List<Map<String, Object>> filteredList = reportServiceImpl.filterReportInfo(param, tmpList);
            // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
            // フィルタ処理の結果がEmpty以外の場合
            if (!filteredList.isEmpty()) {
              // 1ページの繰り返し件数を取得する
              ReportXmlGroup group = param.getReportXmlGroup();
              Integer repeatOfPage;
              if (group != null && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_YES) {
                repeatOfPage = (filteredList.size() > group.getRepeatMax()) ? group.getRepeatMax() : filteredList.size();
              } else {
                repeatOfPage = filteredList.size();
              }

              // 複数項目のページ数より、単一項目のページ数を設定する
              int addPage = (filteredList.size() % repeatOfPage) > 0 ? 1 : 0;
              resultTemp.replace("GROUP_DATA_PAGE_COUNT", (filteredList.size() / repeatOfPage) + addPage);
            }
          });

        List<ReportXmlParam> list = groupedParam.getValue().stream()
          .filter(param -> StringUtils.isEmpty(param.getGroupId()) && "1".equals(param.getIsNewPage()) && !param.isTmplRepeat()).collect(toList());
        // 単一項目に対する処理を行う
        if (tmpList.size() > 1 && list!= null && list.size() > 0) {
          groupedParam.getValue().stream()
            .filter(param -> StringUtils.isEmpty(param.getGroupId()) && !param.isTmplRepeat())
            .forEach(param -> {
              for (int i = 0; i < tmpList.size(); i++) {
                // add #11813 紹介状出力時、手打ち入力した導入施設名が表示されない limingzhe start
                if (dataKey.get("newPageCountFlag") != null && (i + 1) > 1) continue;
                // add #11813 紹介状出力時、手打ち入力した導入施設名が表示されない limingzhe end
                Map<String, Object> tmpMap = tmpList.get(i);
                // 出力する内容を取得する
                // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                //String value = formatValue(param, tmpMap.get(param.getDataCode()));
                //value = convertValue(param, value);
                String value = reportServiceImpl.formatValue(param, tmpMap.get(param.getDataCode()));
                value = reportServiceImpl.convertValue(param, value);
                // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end

                if (value != null && !"null".equals(value)) {
                  // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
                  // result.put(String.format("%d%s", i + 1, MULTIPLE_PAGES_SEPARATOR) + param.getId(), addLineBreak(value, param.getDispLength(), param.getDataType()));
                  // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                  //result.put(String.format("%d%s", i + 1, MULTIPLE_PAGES_SEPARATOR) + param.getId(), addLineBreak(value, param));
                  result.put(String.format("%d%s", i + 1, MULTIPLE_PAGES_SEPARATOR) + param.getId(), reportServiceImpl.addLineBreak(value, param));
                  // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                  // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
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
              // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
              //String value = formatValue(param, tmpMap.get(param.getDataCode()));
              //value = convertValue(param, value);
              String value = reportServiceImpl.formatValue(param, tmpMap.get(param.getDataCode()));
              value = reportServiceImpl.convertValue(param, value);
              // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end

              if (value != null && !"null".equals(value)) {
                // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
                // result.put(param.getId(), addLineBreak(value, param.getDispLength(), param.getDataType()));
                // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                //result.put(param.getId(), addLineBreak(value, param));
                result.put(param.getId(), reportServiceImpl.addLineBreak(value, param));
                // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
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
            // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
            //List<Map<String, Object>> filteredList = filterReportInfo(param, tmpList);
            List<Map<String, Object>> filteredList = reportServiceImpl.filterReportInfo(param, tmpList);
            // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
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
            String mainteLayoutCd = "";
            String mainteRecordCd = "";
            String mainteUseCd = "";
            String mainteDate = "";
			// del #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
//            if (extractionCondition != null) {
//              mainteLayoutCd = extractionCondition.getLayoutCD();
//              mainteRecordCd = extractionCondition.getRecordCD();
//              mainteUseCd = extractionCondition.getUseCD();
//              mainteDate = (String) dataKey.get(ReportConstant.ReportDataKey.DATE);
//            }
			// del #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
            Integer repeatMax = (group != null && group.getRepeatMax() != null) ? group.getRepeatMax() : 1;
            for (Integer pageCount = 0; pageCount <= (filteredList.size() / repeatOfPage); pageCount++) {
              // add #11294 紹介状で集計部分がずれて出力される 高 start
              if (dataKey.get("newPageCountFlag") != null && (pageCount + 1) > 1) continue;
              // add #11294 紹介状で集計部分がずれて出力される 高 end
              int skipCount = pageCount * limitCount;

              // id属性値をkey、出力値をvalue に設定する（複数項目の場合、id属性値に連番を付加する）
              List<Map<String, Object>> outputInfos = filteredList.stream().skip(skipCount).limit(limitCount).collect(toList());
              int n=0;
              List<ReportXmlFilterTable> filters = param.getReportXmlFilters();
              Map<String,Object> showDataInfoTemp=  new LinkedHashMap<>();
              if(type != null && type == 9 && sqlCode == 29) {
                List<Map<String, Object>> newPutInfo = new ArrayList<>();
                outputInfos.stream().forEach(el -> {
                    if (!(showDataInfoTemp.containsKey(el.get("result_exam_date") + "_" + el.get("reg_order_class")))) {
                      showDataInfoTemp.put(el.get("result_exam_date") + "_" + el.get("reg_order_class"), el);
                    }
                  }
                );
                if(param.getDataCode().equals("result_exam_date") || param.getDataCode().equals("reg_order_class")){
                  for (String KeyItem : showDataInfoTemp.keySet()){
                    newPutInfo.add((Map<String, Object>) showDataInfoTemp.get(KeyItem));
                  }
                }else {
                  List<ReportXmlParam> paramResult= groupedParam.getValue().stream().filter(el -> el.getDataCode().equals("result")).collect(toList());

                  for (ReportXmlParam item:paramResult) {
                    for (String key:showDataInfoTemp.keySet()) {
                      boolean tag = true;
                      for (Integer i = 0; i < outputInfos.size(); i++) {
                        if(key.split("_")[0].equals(outputInfos.get(i).get("result_exam_date").toString())
                          && key.split("_")[1].equals(outputInfos.get(i).get("reg_order_class"))
                          && item.getReportXmlFilters().get(0).getCode().equals(outputInfos.get(i).get("item_cd"))){
                          newPutInfo.add(outputInfos.get(i));
                          tag = false;
                          break;
                        }
                      }
                      if(tag){
                        Map<String, Object> nullDateMap = new LinkedHashMap<>();
                        if(item.getReportXmlFilters() != null &&item.getReportXmlFilters().size() != 0){
                          nullDateMap.put("item_cd",item.getReportXmlFilters().get(0).getCode());
                        }else{
                          nullDateMap.put("item_cd","");
                        }
                        nullDateMap.put("reg_exam_date", "");
                        nullDateMap.put("in_hospital_cd1", "");
                        nullDateMap.put("in_hospital_cd2", "");
                        nullDateMap.put("in_hospital_cd3", "");
                        nullDateMap.put("sbt_cd1", "");
                        nullDateMap.put("sbt_cd2", "");
                        nullDateMap.put("sbt_cd3", "");
                        nullDateMap.put("item_name", "");
                        nullDateMap.put("result", "");
                        nullDateMap.put("unit", "");
                        nullDateMap.put("freememo", "");
                        nullDateMap.put("result_exam_date",key.split("_")[0]);
                        nullDateMap.put("reg_order_class",key.split("_")[1]);
                        nullDateMap.put("upper", "");
                        nullDateMap.put("lower", "");
                        newPutInfo.add(nullDateMap);
                      }
                    }

                  }
                }
                outputInfos.clear();
                outputInfos.addAll(newPutInfo);
              }
              if(outputInfos.size()>0 && "Category".equals(param.getFilterType())){
                // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                //outputInfos = filterReportInfo(param, outputInfos);
                outputInfos = reportServiceImpl.filterReportInfo(param, outputInfos);
                // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
              }
              String strDate = "";
              List mediName = new ArrayList();
              int page_offset = 0;
              int sum_offset = 1;
              for (Integer i = 0; i < outputInfos.size(); i++) {
                if (n >= repeatMax) {
                  break;
                }
                String outputData = "";
                if(!mainteLayoutCd.isEmpty()){
                  if (String.valueOf(outputInfos.get(i).get("mainte_layout_cd")).equals(mainteLayoutCd)) {
                    if(repeatMax > 1){
                      if("mainte_date".equals(param.getDataCode())){
                        if (DateFormat(String.valueOf(outputInfos.get(i).get("mainte_date"))).equals(strDate)) {
                          continue;
                        }
                        strDate = DateFormat(String.valueOf(outputInfos.get(i).get("mainte_date")));
                      }
                    }else{
                      if (!DateFormat(String.valueOf(outputInfos.get(i).get("mainte_date"))).equals(mainteDate)) {
                        continue;
                      }
                    }
                    if ("2".equals(mainteUseCd)) {
                      if (String.valueOf(outputInfos.get(i).get("tabindex")).equals(mainteRecordCd)) {
                        outputData = String.valueOf(outputInfos.get(i).get("mainte_detail_cd"));
                      }
                    }else {
                      outputData = String.valueOf(outputInfos.get(i).get("mainte_detail_cd"));
                    }
                  }
                  else{
                    continue;
                  }
                }else{
                  Set<String> keysSet = outputInfos.get(i).keySet();
                  if(!keysSet.isEmpty()){
                    String key = keysSet.toArray(new String[0])[0];
                    outputData = String.valueOf(outputInfos.get(i).get(key));
                  }
                }
                // del #10531 検査日と検査区分がフィルタを超えて繰り返される limingzhe start
//                List<String> PatientEvents = new ArrayList<String>(){
//                  {
//                    for (int i = 84;i <= 94;i++){
//                      this.add(i+"");
//                    }
//                  }
//                };
//                if(filters == null || filters.size() ==0 || (outputData.equals(filters.get(0).getCode()) && !outputData.isEmpty()) || PatientEvents.contains(param.getSqlCode())){
                // del #10531 検査日と検査区分がフィルタを超えて繰り返される limingzhe end
                  String key = "";
                  // del #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                  //if (group != null && group.getRepeatMax() <= 1 && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_NO) {
                  //  // グループ設定が存在しない、またはグループ設定の繰り返し回数が1以下且つテンプレート外の項目は、後続処理でページ毎出力されるようにidを設定する
                  //  key = param.getId();
                  //} else {
                  // del #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                  // mod #12231 グループ繰り返しOFFの項目群が2ページ目に1ページ目と同じ内容にならない 高 start
                  String pageStr = "";
                  if (group != null && group.getIsNewPage() == ReportXmlGroup.IS_NEW_PAGE_YES) {
                    pageStr = String.format("%d%s", pageCount + 1, MULTIPLE_PAGES_SEPARATOR);
                  }
//                  String pageStr = String.format("%d%s", pageCount + 1, MULTIPLE_PAGES_SEPARATOR);
                  // mod #12231 グループ繰り返しOFFの項目群が2ページ目に1ページ目と同じ内容にならない 高 end
                  key = String.format("%s%s-%d", pageStr, param.getId(), n + 1);
                  // del #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                  //}
                  // del #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                  if (type == 9 && reportType == 1 && "4".equals(param.getSqlCode()) && "曜日".equals(params.get(0).getReportXmlTotalTable().getUnitDate())) {
                    if ("medi_name".equals(param.getDataCode())) {
                      if (mediName.contains(String.valueOf(outputInfos.get(i).get("medi_name")))) {
                        result.put(key, "");
                        continue;
                      }
                      mediName.add(String.valueOf(outputInfos.get(i).get("medi_name")));
                    }
                  }

                  // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                  //String value = formatValue(param, outputInfos.get(i).get(param.getDataCode()));
                  //value = convertValue(param, value);
                  String value = reportServiceImpl.formatValue(param, outputInfos.get(i).get(param.getDataCode()));
                  value = reportServiceImpl.convertValue(param, value);
                  // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                // del #10385 患者イベント(画像)の出力が不正 高 start
//                  if (param.getIsImage().equals("true") && null != value && !value.equals("") && !value.equals("null"))
//                  {
//                    value = "(place)" + value;
//                  }
                // del #10385 患者イベント(画像)の出力が不正 高 end
                  String temp_str = "",key_str = "";
                  int offset = 0, key_offset = 0;
                  int max = param.getRepeatAddress().split(",").length;
                  if (value != null && !"null".equals(value) && !"".equals(value)) {
                    if(!result.containsKey(key)){
                      // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
                      // result.put(key, addLineBreak(value, param.getDispLength(), param.getDataType()));
                      // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                      //result.put(key, addLineBreak(value, param));
                      result.put(key, reportServiceImpl.addLineBreak(value, param));
                      // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                      // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
                    }
                  } else {
                    if(!result.containsKey(key)){
                      result.put(key, "");
                    }
                  }
                  n = n + 1;
                // del #10531 検査日と検査区分がフィルタを超えて繰り返される limingzhe start
//                }
                // del #10531 検査日と検査区分がフィルタを超えて繰り返される limingzhe end
              }
            }
          });

        // add #10650 検査結果（指定日以前）の仕様課題 2025/02/26 高 start
        groupedParam.getValue().stream()
          .filter(param -> param.isTmplRepeat())
          .forEach(param -> {

            // グループの繰り返し回数 / グループIDは、繰り返し可能な項目 ( sys_data_set.can_repeat = 1 ) にのみ付与されています
            Integer gRepeatMax = 1;
            if (!StringUtils.isEmpty(param.getGroupId()) && param.getReportXmlGroup() != null) {
              gRepeatMax = param.getReportXmlGroup().getRepeatMax() != null ? param.getReportXmlGroup().getRepeatMax() : 1;
            }

            // tmpl repeat上限
            int tRepeatMax = Optional.ofNullable(param.getReportXmlTmplRepeat().getRepeatMax())
              .filter(v -> v > 0)
              .orElse(Integer.MAX_VALUE);

            List<Map<String, Object>> filteredList = reportServiceImpl.filterReportInfo(param, tmpList);
            if (filteredList.isEmpty()) {
              return;
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
          });
        // mod #10650 検査結果（指定日以前）の仕様課題 2025/02/26 高 end
      }
      //sqlCodeが空ではないが、データを書き込めない場合の解決 (適切な修正案が見つかった場合は、このセグメントコードを削除できます)
      //今回のサイクルでデータが何も書き込まれていない場合は、
      // ①reportOutputInfo、②dataKeyから、
      //本来書き込む可能性のあるデータを見つけて書き込むことを順番に試みます
      if(resultSize==result.size()){
        groupedParam.getValue().forEach(param->{
          List<Map<String, Object>> info = reportOutputInfo.get(Long.valueOf(param.getSqlCode()));
          // mod #11226 患者情報系historyの取得条件見直し② limingzhe start
          if(info != null){
          // mod #11226 患者情報系historyの取得条件見直し② limingzhe end
            // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
            //info = filterReportInfo(param, info);
            info = reportServiceImpl.filterReportInfo(param, info);
            // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
            String key=param.getId();
            if(!param.getSqlCode().equals("")){
              key+="-1";
            }
            if(info!=null&&info.size()>0){
              //reportOutputInfoの最初のデータから優先的に検索
              // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
              //result.put(key,formatValue(param,info.get(0).get(param.getDataCode())));
              result.put(key,reportServiceImpl.formatValue(param,info.get(0).get(param.getDataCode())));
              // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
            }else if(dataKey.containsKey(param.getDataCode())){
              //dataKeyのデータを追加しようとします
              // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
              //result.put(key,formatValue(param,dataKey.get(param.getDataCode())));
              result.put(key,reportServiceImpl.formatValue(param,dataKey.get(param.getDataCode())));
              // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
            }
          // mod #11226 患者情報系historyの取得条件見直し② limingzhe start
          }
          // mod #11226 患者情報系historyの取得条件見直し② limingzhe end
        });
      }
    });

    // add #11226 患者情報系historyの取得条件見直し② limingzhe start
    // del #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe start
    //String tmplKey = params.get(0).getReportXmlTmplRepeat().getKey();
    // del #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe end
    // mod #10650 検査結果（指定日以前）の仕様課題 2025/02/26 高 start
//    Map<String, List<ReportXmlParam>> groupedParamsInTmpl = params.stream()
//      .filter(p -> !StringUtils.isEmpty(p.getId()) && p.isTmplRepeat())
//      .collect(Collectors.groupingBy(p -> p.getSqlCode()))
//      ;
    Map<String, List<ReportXmlParam>> groupedParamsInTmpl = params.stream()
      .filter(p -> !StringUtils.isEmpty(p.getId()) && p.isTmplRepeat() && !String.valueOf(p.getSqlCode()).matches(".*9999931$") && !String.valueOf(p.getSqlCode()).matches(".*99999327$"))
      .collect(Collectors.groupingBy(p -> p.getSqlCode()))
      ;
    // mod #10650 検査結果（指定日以前）の仕様課題 2025/02/26 高 end
    // add #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe start
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
              .filter(map -> String.valueOf(keyNo).equals(map.get("pat_info_date_key").toString()))
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
    // add #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe end

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
    for (Long keyNo : keyNoList) {
      // add #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe start
      int tmplMaxCount = 1;
      if(groupSortKeyNoMap != null && groupSortKeyNoMap.size() != 0 && groupSortKeyNoMap.get(keyNo) != null) {
        for (Long sCd : groupSortKeyNoMap.get(keyNo).keySet()) {
          // mod #10650 検査結果（指定日以前）の仕様課題 高　start
//          int count = groupSortKeyNoMap.get(keyNo).get(sCd).size();
          int count = String.valueOf(sCd).contains("31") || String.valueOf(sCd).contains("247") ? 1 : groupSortKeyNoMap.get(keyNo).get(sCd).size();
          // mod #10650 検査結果（指定日以前）の仕様課題 高　end
          if (tmplMaxCount < count) tmplMaxCount = count;
        }
      }
      for(int tmplIndex = 0; tmplIndex < tmplMaxCount; tmplIndex++){
      // add #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe end
        int tmplLoopMax = 0;
        // add #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
        Integer startPagebyKeyNo = 0;
        Integer startTmplbyKeyNo = 0;
        Map<String, String> resultTmpl = new HashMap<>();
        // add #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
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
            // add #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe start
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
            // add #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe end
            String mainteLayoutCd = "";
            String mainteRecordCd = "";
            String mainteUseCd = "";
            String mainteDate = "";
			// del #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
//            if (extractionCondition != null) {
//              mainteLayoutCd = extractionCondition.getLayoutCD();
//              mainteRecordCd = extractionCondition.getRecordCD();
//              mainteUseCd = extractionCondition.getUseCD();
//              mainteDate = (String) dataKey.get(ReportConstant.ReportDataKey.DATE);
//            }
			// del #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
            for (ReportXmlParam param : groupedParamsInTmpl.get(cel)) {
              if (!(!StringUtils.isEmpty(param.getGroupId()) && param.isTmplRepeat())) {
                continue;
              }
              if (sqlCode != 31L) {
                // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                //List<Map<String, Object>> filteredList = filterReportInfo(param, tmpList);
                List<Map<String, Object>> filteredList = reportServiceImpl.filterReportInfo(param, tmpList);
                // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                if(sqlCode != 205){
                  List<Map<String, Object>> filteredListTemp = new ArrayList<>();
                  for (Map<String, Object> sqlData : filteredList) {
                    // キーの値に一致するデータを応答データに格納
                    // mod #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe start
//                    if (sqlData.get(tmplKey) != null && !StringUtils.isEmpty(sqlData.get(tmplKey).toString())) {
//                      Long dataKeyNo = Long.valueOf(sqlData.get(tmplKey).toString());
//                      if (keyNo.equals(dataKeyNo)) {
//                        filteredListTemp.add(sqlData);
//                      }
//                    }
                    if (sqlData.get(keyNamebyNo) != null && !StringUtils.isEmpty(sqlData.get(keyNamebyNo).toString())) {
                      Long dataKeyNo = Long.valueOf(sqlData.get(keyNamebyNo).toString());
                      if (keyNobyNo.equals(dataKeyNo)) {
                        filteredListTemp.add(sqlData);
                      }
                    }
                    // mod #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe end
                  }
                  filteredList = filteredListTemp;
                }
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
                  // mod #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe start
                  //tmplLoop = filteredList.size() / group.getRepeatMax() + 1;
                  tmplLoop = filteredList.size() / group.getRepeatMax() + ((filteredList.size() % group.getRepeatMax() > 0) ? 1 : 0);
                  // mod #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe end
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
                  // add #11294 紹介状で集計部分がずれて出力される 高 start
                  if (dataKey.get("newPageCountFlag") != null && (pageCount + 1) > 1) continue;
                  // add #11294 紹介状で集計部分がずれて出力される 高 end
                  int skipCount = pageCount * limitCount;
                  List<Map<String, Object>> outputInfos = filteredList.stream().skip(skipCount).limit(limitCount).collect(toList());
                  List<ReportXmlFilterTable> filters = param.getReportXmlFilters();
                  int count = 1;
                  // add #12234 テンプレート改頁とグループ繰り返しの組合わせ時の出力結果がおかしい limingzhe start
                  pageStart = tmplLoopStart / tmplRepeat.getRepeatMax();
                  // add #12234 テンプレート改頁とグループ繰り返しの組合わせ時の出力結果がおかしい limingzhe end
                  int tmplLoopCount = 1 + tmplLoopStart % tmplRepeat.getRepeatMax();
                  for (Integer i = 0; i < outputInfos.size(); i++) {
                    String outputData = "";
                    if(!mainteLayoutCd.isEmpty()){
                      if(!DateFormat(String.valueOf(outputInfos.get(i).get("mainte_date"))).equals(mainteDate)){
                        continue;
                      }
                      if(String.valueOf(outputInfos.get(i).get("mainte_layout_cd")).equals(mainteLayoutCd)) {
                        if("2".equals(mainteUseCd)){
                          if(String.valueOf(outputInfos.get(i).get("tabindex")).equals(mainteRecordCd)){
                            outputData = String.valueOf(outputInfos.get(i).get("mainte_detail_cd"));
                          }
                        }else {
                          outputData = String.valueOf(outputInfos.get(i).get("mainte_detail_cd"));
                        }
                      }
                    }else{
                      Set<String> keysSet = outputInfos.get(i).keySet();
                      String key = keysSet.toArray(new String[0])[0];
                      outputData = String.valueOf(outputInfos.get(i).get(key));
                    }
                    // del #10650 検査結果（指定日以前）の仕様課題 高　start
//                    if(filters == null || filters.size() ==0 || (outputData.equals(filters.get(0).getCode()) && !outputData.isEmpty())){
                    // del #10650 検査結果（指定日以前）の仕様課題 高　end
                      String pageStr = String.format("%d%s", pageStart + pageCount + 1, MULTIPLE_PAGES_SEPARATOR);
                      String keyTmpl = String.format("%s-%d", tmplRepeat.getId(), tmplLoopCount);
                      String keyParam = String.format("%s-%s", param.getId(), count++);
                      String key = String.format("%s%s.%s",pageStr, keyTmpl, keyParam);

                      // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                      //String value = formatValue(param, outputInfos.get(i).get(param.getDataCode()));
                      //value = convertValue(param, value);
                      String value = reportServiceImpl.formatValue(param, outputInfos.get(i).get(param.getDataCode()));
                      value = reportServiceImpl.convertValue(param, value);
                      // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                      paramIds.put(param.getId(),param.getId());
                      if (value != null && !"null".equals(value)) {
                        // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
                        // result.put(key, addLineBreak(value, param.getDispLength(), param.getDataType()));
                        // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                        //result.put(key, addLineBreak(value, param));
                        resultTmpl.put(key, reportServiceImpl.addLineBreak(value, param));
                        // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                        // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
                      } else {
                        // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                        //result.put(key, "");
                        resultTmpl.put(key, "");
                        // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                      }
                      // add #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                      if(startPagebyKeyNo == 0) startPagebyKeyNo = pageStart + pageCount + 1;
                      if(startTmplbyKeyNo == 0) startTmplbyKeyNo = tmplLoopCount;
                      // add #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
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
                    // del #10650 検査結果（指定日以前）の仕様課題 高　start
//                    }
                    // del #10650 検査結果（指定日以前）の仕様課題 高　end
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
              if(sqlCode != 205) {
                List<Map<String, Object>> filteredListTemp = new ArrayList<>();
                for (Map<String, Object> sqlData : tmpList) {
                  // キーの値に一致するデータを応答データに格納
                  // mod #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe start
//                  if (sqlData.get(tmplKey) != null && !StringUtils.isEmpty(sqlData.get(tmplKey).toString())) {
//                    Long dataKeyNo = Long.valueOf(sqlData.get(tmplKey).toString());
//                    if (keyNo.equals(dataKeyNo)) {
//                      filteredListTemp.add(sqlData);
//                    }
//                  }
                  if (sqlData.get(keyNamebyNo) != null && !StringUtils.isEmpty(sqlData.get(keyNamebyNo).toString())) {
                    Long dataKeyNo = Long.valueOf(sqlData.get(keyNamebyNo).toString());
                    if (keyNobyNo.equals(dataKeyNo)) {
                      filteredListTemp.add(sqlData);
                    }
                  }
                  // mod #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe end
                }
                tmpList = filteredListTemp;
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
                // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                //String value = formatValue(param, tmpMap.get(param.getDataCode()));
                //value = convertValue(param, value);
                String value = reportServiceImpl.formatValue(param, tmpMap.get(param.getDataCode()));
                value = reportServiceImpl.convertValue(param, value);
                // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end

                String pageStr = String.format("%d%s", pageStart + i + 1, MULTIPLE_PAGES_SEPARATOR);
                String keyTmpl = String.format("%s-%d", tmplRepeat.getId(), count);
                String key = String.format("%s%s.%s", pageStr, keyTmpl, param.getId());

                if (value != null && !"null".equals(value)) {
                  // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
                  // result.put(key, addLineBreak(value, param.getDispLength(), param.getDataType()));
                  // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                  //result.put(key, addLineBreak(value, param));
                  resultTmpl.put(key, reportServiceImpl.addLineBreak(value, param));
                  // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                  // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
                } else {
                  // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                  //result.put(key, "");
                  resultTmpl.put(key, "");
                  // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                }
                // add #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                if(startPagebyKeyNo == 0) startPagebyKeyNo = pageStart + i + 1;
                if(startTmplbyKeyNo == 0) startTmplbyKeyNo = count;
                // add #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
              }
            }
          }
        }
        // add #12234 テンプレート改頁とグループ繰り返しの組合わせ時の出力結果がおかしい limingzhe start
        if(resultTmpl.size() > 0)
        // add #12234 テンプレート改頁とグループ繰り返しの組合わせ時の出力結果がおかしい limingzhe end
          tmplLoopStart += tmplLoopMax;

        // add #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
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
        // add #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
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
      // add #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe start
      }
      // add #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe end
      // add #12234 テンプレート改頁とグループ繰り返しの組合わせ時の出力結果がおかしい limingzhe start
      if(tmplEndFlag) break;
      // add #12234 テンプレート改頁とグループ繰り返しの組合わせ時の出力結果がおかしい limingzhe end
    }
    // add #11226 患者情報系historyの取得条件見直し② limingzhe end

    // 補正データが存在する場合に処理を実施
    if (tmplCorrectData.repNumList.size() > 0) {
      // 降順にソートし、番号の大きい方(ページの後ろ)から処理を実施する
      List<String> descKeyList = new ArrayList<>();
      for (String keyStr : tmplCorrectData.repNumList.keySet()) {
        descKeyList.add(keyStr);
      }
      Collections.sort(descKeyList, Collections.reverseOrder());
      // 変更前key、変更後key を格納するリスト
      Map<String, String> replaceKeyList = new HashMap<>();
      for (String keyStr : descKeyList) {
        // tmplCorrectData.repNumList の key と value が同じ場合は処理不要の為スキップ
        String valueStr = tmplCorrectData.repNumList.get(keyStr);
        if (keyStr.equals(valueStr)) {
          continue;
        }
        // 応答データから変更するkeyを取得し、replaceKeyList に格納する
        for (String resultKey : result.keySet()) {
          // 正規表現に該当しない場合は処理対象のkeyではないためスキップ ( 該当するkeyの例：1#B7:L11-2.D11 )
          if (!resultKey.matches("^[0-9]{1,}#.*-[0-9]{1,}\\..{2,}$")) {
            continue;
          }
          // ページが異なる場合は処理をスキップ
          String[] tmpKeyStr = keyStr.split(MULTIPLE_PAGES_SEPARATOR);
          String keyPage = tmpKeyStr[0];
          String keyNumber = tmpKeyStr[1];
          String[] splitKeys = resultKey.split("\\.");
          String[] splitPage = splitKeys[0].split(MULTIPLE_PAGES_SEPARATOR);
          if (!splitPage[0].equals(keyPage)) {
            continue;
          }
          // 「.」直前の -n が変更対象の番号ではなかった場合は処理をスキップ
          int clipPoint = splitPage[1].indexOf("-") + 1;
          String repeatNum = splitPage[1].substring(clipPoint);
          if (!repeatNum.equals(keyNumber)) {
            continue;
          }
          // 「.」より後ろのセルが、処理除外対象セルリストに含まれるものであった場合は処理をスキップ
          boolean skipFlg = false;
          for (String cellStr : tmplCorrectData.cellList) {
            if (splitKeys[1].startsWith(cellStr)) {
              skipFlg = true;
            }
          }
          if (skipFlg) {
            continue;
          }
          // 修正後のkey を　修正前のkey と合わせて格納
          String[] tmpValueStr = valueStr.split(MULTIPLE_PAGES_SEPARATOR);
          String valuePage = tmpValueStr[0];
          String valueNumber = tmpValueStr[1];
          String replaceKey = valuePage + MULTIPLE_PAGES_SEPARATOR + splitPage[1].substring(0, clipPoint) + valueNumber + "." + splitKeys[1];
          replaceKeyList.put(resultKey, replaceKey);
        }
      }
      // 格納データを退避し、key を変更して再登録
      for (String beforeKey : replaceKeyList.keySet()) {
        String tmpData = result.get(beforeKey);
        result.remove(beforeKey);
        result.put(replaceKeyList.get(beforeKey), tmpData);
      }
    }
    // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy start
    ReportCommonUtil.pageAndPageCount(result, params, dataKey);
    // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy start
    return result;
  }

  private void convertDataCodeToIdRepeatTmpl(Map<String, String> result, List<Map<String, Object>> tmpList, ReportXmlParam param, int startPrintPos, boolean isLabel) {
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
    int loopCnt = startPrintPos;
    Integer pageIndex = 1;
    for (Integer pageCount = 0; pageCount <= ((tmpList.size() + startPrintPos) / repeatOfPage); pageCount++) {
      int skipCount = pageCount * limitCount;
      // id属性値をkey、出力値をvalue に設定する
      // (key構成：tmplRepeatタグのid属性値 + 連番 + "." + paramタグのid属性値 + "-1"(※))
      // (※ paramタグのgroupId属性値が設定されている場合のみ付与する)
      if(startPrintPos != 1 && pageCount >0 && startPrintPos + tmpList.size() > repeatMax){
        skipCount = repeatMax*pageCount - startPrintPos+1;
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
        if(!StringUtils.isEmpty(param.getParticular()) && param.getParticular().equals("Label") && null != outputInfos.get(i).get("class_name"))
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
              // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
              //value = formatValue(param, outputInfos.get(i).get(dataCode));
              //value = convertValue(param, value);
              value = reportServiceImpl.formatValue(param, outputInfos.get(i).get(dataCode));
              value = reportServiceImpl.convertValue(param, value);
              // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
            }
          }else{
            value = "";
          }
        }
        else
        {
          // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
          //value = formatValue(param, outputInfos.get(i).get(param.getDataCode()));
          //value = convertValue(param, value);
          value = reportServiceImpl.formatValue(param, outputInfos.get(i).get(param.getDataCode()));
          value = reportServiceImpl.convertValue(param, value);
          // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
        }
        if ("null".equals(value)) {
          value = "";
        }
        // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 start
        // result.put(key, addLineBreak(value, param.getDispLength(), param.getDataType()));
        // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
        result.put(key, reportServiceImpl.addLineBreak(value, param));
        // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
        // mod 9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 吉 end
      }
    }
  }

  /**
   * 帳票デザインExcelを取得します.
   *
   * @param mstReport 帳票マスタEntity
   * @param reportZipFile 帳票Zipファイル
   * @return 帳票デザインExcel(POI Workbook)
   */
  private Workbook getReportWorkbook(MstReport mstReport, ReportZipFile reportZipFile) {
    // エクセルファイルを取得
    byte[] excelData = reportZipFile.getFile(mstReport.getReportPath().getXlsxFilename());
    if (Objects.isNull(excelData)) {
      throw new NotExistException("帳票デザインExcelファイルを取得できません。");
    }
    try (InputStream is = new ByteArrayInputStream(excelData)) {
      return WorkbookFactory.create(is);
    } catch (IOException e) {
      throw new NtssException("帳票デザインExcelファイルを取得できません。");
    }
  }

  // add #11226 患者情報系historyの取得条件見直し② limingzhe start
  // mod #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe start
  //private void selectReportInfo(String reportXml, List<ReportXmlParam> paramsbyPatId, List<ReportXmlParam> paramsbyOrdNos, List<ReportXmlParam> paramsbyOther,
  private void selectReportInfo(String reportXml, Map<String, List<ReportXmlParam>> paramsGroup,
  // mod #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe end
                                // mod #11127 グループ除外処理の残対応（モニタ、身体情報）　高　start
//                                List<Long> patIds, List<Long> or, Map<String, Object> dataKey, String facilityCd, Map<Long, List<Map<String, Object>>> reportInfo){
                                List<Long> patIds, List<Long> or, Map<String, Object> dataKey, String facilityCd, Map<Long, List<Map<String, Object>>> reportInfo,List<ReportXmlParam> paramsOld){
    // mod #11127 グループ除外処理の残対応（モニタ、身体情報）　高　end
    List<ReportXmlParam> params = ReportUtils.getParamElements(reportXml);
    // mod #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe start
    //if(paramsbyPatId.size()>0 && patIds.size()>0){
    if(paramsGroup.get("patId").size()>0 && patIds.size()>0){
    // mod #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe end
      dataKey.put("patId", patIds.get(0));
      params = ReportUtils.getParamElements(reportXml);
      // mod #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe start
      //Map<Long, List<Map<String, Object>>> reportInfoIndex = getReportInfo(paramsbyPatId, dataKey);
      Map<Long, List<Map<String, Object>>> reportInfoIndex = getReportInfo(paramsGroup.get("patId"), dataKey);
      // mod #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe end

      // add #10531 検査日と検査区分がフィルタを超えて繰り返される limingzhe start
      reportServiceImpl.filterReportInfobyParam(paramsGroup.get("patId"), reportInfoIndex);
      // add #10531 検査日と検査区分がフィルタを超えて繰り返される limingzhe end

      params = reportServiceImpl.paramsReplaceTmpValue(params, reportInfoIndex);
      // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
      //reportInfoIndex = getChangeList(reportInfoIndex, params);
      reportInfoIndex = reportServiceImpl.getChangeList(reportInfoIndex, params);
      // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
      for (Long key : reportInfoIndex.keySet()) {
        if (reportInfo.containsKey(key)) {
          reportInfo.get(key).addAll(reportInfoIndex.get(key));
        } else {
          reportInfo.put(key, reportInfoIndex.get(key));
        }
      }
    }
    // mod #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe start
    //if(paramsbyOrdNos.size()>0 && patIds.size()>0 && or.size()>0){
    if(paramsGroup.get("ordNos").size()>0 && patIds.size()>0 && or.size()>0){
    // mod #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe end
      Map<Long, List<Long>> patIdOrdList = new HashMap<>();
      List<Long> ordNos = new ArrayList<>();
      for (int i = 0; i < patIds.size(); i++){
        if (patIds.get(i) == null || or.get(i) == null || or.get(i) == -1) {
          continue;
        }
        ordNos.clear();
        if(patIdOrdList.containsKey(patIds.get(i))) {
          ordNos = patIdOrdList.get(patIds.get(i));
        }
        ordNos.add(or.get(i));
        patIdOrdList.put(patIds.get(i), new ArrayList<Long>(new LinkedHashSet<>(ordNos)));
      }
      for (Long pId : patIdOrdList.keySet()) {
        dataKey.put("patId", pId);
        dataKey.put("ordNos", patIdOrdList.get(pId));
        params = ReportUtils.getParamElements(reportXml);
        // mod #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe start
        //Map<Long, List<Map<String, Object>>> reportInfoIndex = getReportInfo(paramsbyOrdNos, dataKey);
        Map<Long, List<Map<String, Object>>> reportInfoIndex = getReportInfo(paramsGroup.get("ordNos"), dataKey);
        // mod #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe end
        // add #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe start
        List<Map<String, Object>> reportIndicateResult = reportInfoIndex.get(Long.valueOf("4"));
        if (reportIndicateResult != null && reportIndicateResult.size() > 0){
          List<Map<String, Object>> midList = reportInfoIndex.get(Long.valueOf("4"));
          // 施設設定マスタNo.107 投与薬剤表示順 設定値
          List<String> displayOrderList = reportServiceImpl.getFacilitySettingOrderListToMedicine2(facilityCd, "3007");
          midList = reportServiceImpl.sortReportInfo(midList, displayOrderList, 9999999);
          reportInfoIndex.put(Long.valueOf("4"), midList);
        }
        List<Map<String, Object>> reportIndicate = reportInfoIndex.get(Long.valueOf("8"));
        if (reportIndicate != null && reportIndicate.size() > 0){
          List<Map<String, Object>> midList = reportInfoIndex.get(Long.valueOf("8"));
          List<String> displayOrderList = reportServiceImpl.getFacilitySettingOrderListToMedicine2(facilityCd, "3007");
          midList = reportServiceImpl.sortReportInfo(midList, displayOrderList, 9999999);
          reportInfoIndex.put(Long.valueOf("8"), midList);
        }
        List<Map<String, Object>> reportRealityResult = reportInfoIndex.get(Long.valueOf("74"));
        if (reportRealityResult != null && reportRealityResult.size() > 0) {
          List<Map<String, Object>> midList = reportInfoIndex.get(Long.valueOf("74"));
          // 施設設定マスタNo.106 医材表示順 設定値
          List<String> displayOrderList = reportServiceImpl.getFacilitySettingOrderListToEquipment2(facilityCd, "3006");
          midList = reportServiceImpl.sortReportInfo(midList, displayOrderList, 9999999);
          reportInfoIndex.put(Long.valueOf("74"), midList);
        }
        List<Map<String, Object>> reportReality = reportInfoIndex.get(Long.valueOf("97"));
        if (reportReality != null && reportReality.size() > 0) {
          List<Map<String, Object>> midList = reportInfoIndex.get(Long.valueOf("97"));
          // 施設設定マスタNo.106 医材表示順 設定値
          List<String> displayOrderList = reportServiceImpl.getFacilitySettingOrderListToEquipment2(facilityCd, "3006");
          midList = reportServiceImpl.sortReportInfo(midList, displayOrderList, 9999999);
          reportInfoIndex.put(Long.valueOf("97"), midList);
        }
        // add #10042 カテゴリ「指示」の出力不正 03 sunsy start
        List<Map<String, Object>> reportFutureActive = reportInfoIndex.get(Long.valueOf("141"));
        if (reportFutureActive != null && reportFutureActive.size() > 0){
          List<Map<String, Object>> midList = reportInfoIndex.get(Long.valueOf("141"));
          // 施設設定マスタNo.107 投与薬剤表示順 設定値
          List<String> displayOrderList = reportServiceImpl.getFacilitySettingOrderListToMedicine2(facilityCd, "3007");
          midList = reportServiceImpl.sortReportInfo(midList, displayOrderList, 9999999);
          reportInfoIndex.put(Long.valueOf("141"), midList);
        }
        List<Map<String, Object>> reportRealityMedDeg = reportInfoIndex.get(Long.valueOf("190"));
        if (reportRealityMedDeg != null && reportRealityMedDeg.size() > 0){
          List<Map<String, Object>> midList = reportInfoIndex.get(Long.valueOf("190"));
          // 施設設定マスタNo.107 投与薬剤表示順 設定値
          List<String> displayOrderList = reportServiceImpl.getFacilitySettingOrderListToMedicine2(facilityCd, "3007");
          midList = reportServiceImpl.sortReportInfo(midList, displayOrderList, 9999999);
          reportInfoIndex.put(Long.valueOf("190"), midList);
        }
        // add #10042 カテゴリ「指示」の出力不正 03 sunsy end
        // add #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe end
        params = reportServiceImpl.paramsReplaceTmpValue(params, reportInfoIndex);
        // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
        //reportInfoIndex = getChangeList(reportInfoIndex, params);
        reportInfoIndex = reportServiceImpl.getChangeList(reportInfoIndex, params);
        // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
        for (Long key : reportInfoIndex.keySet()) {
          if (reportInfo.containsKey(key)) {
            reportInfo.get(key).addAll(reportInfoIndex.get(key));
          } else {
            reportInfo.put(key, reportInfoIndex.get(key));
          }
        }
        // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
//        List<Map<String, Object>> reportIndicateResult = sortIndicateResult(reportInfo.get(Long.valueOf("4")), facilityCd);
//        if (reportIndicateResult != null && reportIndicateResult.size() > 0) reportInfo.put(Long.valueOf("4"), reportIndicateResult);
//        List<Map<String, Object>> reportRealityResult = sortRealityResult(reportInfo.get(Long.valueOf("74")), facilityCd);
//        if (reportRealityResult != null && reportRealityResult.size() > 0) reportInfo.put(Long.valueOf("74"), reportRealityResult);
//        List<Map<String, Object>> reportIndicate = sortIndicate(reportInfo.get(Long.valueOf("8")), facilityCd);
//        if (reportIndicate != null && reportIndicate.size() > 0) reportInfo.put(Long.valueOf("8"), reportIndicate);
//        List<Map<String, Object>> reportReality = sortReality(reportInfo.get(Long.valueOf("97")), facilityCd);
//        if (reportReality != null && reportReality.size() > 0) reportInfo.put(Long.valueOf("97"), reportReality);
        // del #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe start
//        List<Map<String, Object>> reportIndicateResult = reportInfo.get(Long.valueOf("4"));
//        List<Map<String, Object>> reportRealityResult = reportInfo.get(Long.valueOf("74"));
//        List<Map<String, Object>> reportIndicate = reportInfo.get(Long.valueOf("8"));
//        List<Map<String, Object>> reportReality = reportInfo.get(Long.valueOf("97"));
//        if (reportIndicateResult != null && reportIndicateResult.size() > 0){
//          List<Map<String, Object>> midList = reportInfo.get(Long.valueOf("4"));
//          // 施設設定マスタNo.107 投与薬剤表示順 設定値
//          List<String> displayOrderList = reportServiceImpl.getFacilitySettingOrderListToMedicine2(facilityCd, "3007");
//          midList = reportServiceImpl.sortReportInfo(midList, displayOrderList, 9999999);
//          reportInfo.put(Long.valueOf("4"), midList);
//        }
//        if (reportIndicate != null && reportIndicate.size() > 0){
//          List<Map<String, Object>> midList = reportInfo.get(Long.valueOf("8"));
//          List<String> displayOrderList = reportServiceImpl.getFacilitySettingOrderListToMedicine2(facilityCd, "3007");
//          midList = reportServiceImpl.sortReportInfo(midList, displayOrderList, 9999999);
//          reportInfo.put(Long.valueOf("8"), midList);
//        }
//        if (reportRealityResult != null && reportRealityResult.size() > 0) {
//          List<Map<String, Object>> midList = reportInfo.get(Long.valueOf("74"));
//          // 施設設定マスタNo.106 医材表示順 設定値
//          List<String> displayOrderList = reportServiceImpl.getFacilitySettingOrderListToEquipment2(facilityCd, "3006");
//          midList = reportServiceImpl.sortReportInfo(midList, displayOrderList, 9999999);
//          reportInfo.put(Long.valueOf("74"), midList);
//        }
//        if (reportReality != null && reportReality.size() > 0) {
//          List<Map<String, Object>> midList = reportInfo.get(Long.valueOf("97"));
//          // 施設設定マスタNo.106 医材表示順 設定値
//          List<String> displayOrderList = reportServiceImpl.getFacilitySettingOrderListToEquipment2(facilityCd, "3006");
//          midList = reportServiceImpl.sortReportInfo(midList, displayOrderList, 9999999);
//          reportInfo.put(Long.valueOf("97"), midList);
//        }
        // del #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe end
        // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
      }
      dataKey.put("ordNos", or);
    }
    // add #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe start
    List<Long> ordPrescriptionNos = new ArrayList<>();
    if (dataKey.get("ordPrescriptionNos") == null) {
      if(dataKey.get("ordPrescriptionNo") != null) {
        ordPrescriptionNos.add(Long.valueOf(dataKey.get("ordPrescriptionNo").toString()));
      }
    } else {
      ordPrescriptionNos = (List<Long>) dataKey.get("ordPrescriptionNos");
    }
    if(paramsGroup.get("ordPrescriptionNo").size()>0 && ordPrescriptionNos.size()>0) {
      dataKey.put("patId", patIds.get(0));
      for (Long ordPrescriptionNo : ordPrescriptionNos) {
        dataKey.put("ordPrescriptionNo", ordPrescriptionNo);
        params = ReportUtils.getParamElements(reportXml);
        Map<Long, List<Map<String, Object>>> reportInfoIndex = getReportInfo(paramsGroup.get("ordPrescriptionNo"), dataKey);
        params = reportServiceImpl.paramsReplaceTmpValue(params, reportInfoIndex);
        // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
        //reportInfoIndex = getChangeList(reportInfoIndex, params);
        reportInfoIndex = reportServiceImpl.getChangeList(reportInfoIndex, params);
        // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
        for (Long key : reportInfoIndex.keySet()) {
          if (reportInfo.containsKey(key)) {
            reportInfo.get(key).addAll(reportInfoIndex.get(key));
          } else {
            reportInfo.put(key, reportInfoIndex.get(key));
          }
        }
      }
    }
    // add #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe end
    // mod #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe start
    //if(paramsbyOther.size()>0) {
    if(paramsGroup.get("Other").size()>0) {
    // mod #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe end
      for (int i = 0; i < patIds.size(); i++) {
        if(or.size() != 0) {
          dataKey.put("ordNo", or.get(i));
        }
        dataKey.put("patId", patIds.get(i));
        params = ReportUtils.getParamElements(reportXml);
        // mod #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe start
        //Map<Long, List<Map<String, Object>>> reportInfoIndex = getReportInfo(paramsbyOther, dataKey);
        Map<Long, List<Map<String, Object>>> reportInfoIndex = getReportInfo(paramsGroup.get("Other"), dataKey);
        // mod #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe end
        // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
        //List<Map<String, Object>> rec = getPrintedInfo(params, dataKey, reportInfoIndex);
        List<Map<String, Object>> rec = reportServiceImpl.getPrintedInfo(params, dataKey, reportInfoIndex);
        // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
        reportInfoIndex.put(PRINT_INFO_CODE, rec);
        params = reportServiceImpl.paramsReplaceTmpValue(params, reportInfoIndex);
        // add #11127 グループ除外処理の残対応（モニタ、身体情報）　高　start
        reportServiceImpl.reportFilterOutUnusedData(params,reportInfoIndex);
        // add #11127 グループ除外処理の残対応（モニタ、身体情報）　高　end
        // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
        //reportInfoIndex = getChangeList(reportInfoIndex, params);
        reportInfoIndex = reportServiceImpl.getChangeList(reportInfoIndex, params);
        // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
        for (Long key : reportInfoIndex.keySet()) {
          if (reportInfo.containsKey(key)) {
            reportInfo.get(key).addAll(reportInfoIndex.get(key));
          } else {
            reportInfo.put(key, reportInfoIndex.get(key));
          }
        }
      }
      // add #11127 グループ除外処理の残対応（モニタ、身体情報）　高　start
      paramsOld.clear();
      paramsOld.addAll(params);
      // add #11127 グループ除外処理の残対応（モニタ、身体情報）　高　end
    }
  }
  // add #11226 患者情報系historyの取得条件見直し② limingzhe end

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
   * ・集計なし紹介状（テンプレートなし）
   * ・集計なし紹介状（テンプレート外）
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
    }

    // SQL 実行
    Map<Long, List<Map<String, Object>>> reportInfoIndex = sysDataSetService.getSqlDataForOnePatient(sqlCodes, dataKeyNew);

    // 印字用情報の生成
    List<Map<String, Object>> rec = reportServiceImpl.getPrintedInfo(params, dataKey, reportInfoIndex);
    reportInfoIndex.put(PRINT_INFO_CODE, rec);
    // add #10042 カテゴリ「指示」の出力不正 03 sunsy start
    List<Map<String, Object>> reportIndicateResult = reportInfoIndex.get(Long.valueOf("4"));
    if (reportIndicateResult != null && reportIndicateResult.size() > 0){
      List<Map<String, Object>> midList = reportInfoIndex.get(Long.valueOf("4"));
      // 施設設定マスタNo.107 投与薬剤表示順 設定値
      List<String> displayOrderList = reportServiceImpl.getFacilitySettingOrderListToMedicine2(facilityCd, "3007");
      midList = reportServiceImpl.sortReportInfo(midList, displayOrderList, 9999999);
      reportInfoIndex.put(Long.valueOf("4"), midList);
    }
    List<Map<String, Object>> reportIndicate = reportInfoIndex.get(Long.valueOf("8"));
    if (reportIndicate != null && reportIndicate.size() > 0){
      List<Map<String, Object>> midList = reportInfoIndex.get(Long.valueOf("8"));
      List<String> displayOrderList = reportServiceImpl.getFacilitySettingOrderListToMedicine2(facilityCd, "3007");
      midList = reportServiceImpl.sortReportInfo(midList, displayOrderList, 9999999);
      reportInfoIndex.put(Long.valueOf("8"), midList);
    }
    List<Map<String, Object>> reportRealityResult = reportInfoIndex.get(Long.valueOf("74"));
    if (reportRealityResult != null && reportRealityResult.size() > 0) {
      List<Map<String, Object>> midList = reportInfoIndex.get(Long.valueOf("74"));
      // 施設設定マスタNo.106 医材表示順 設定値
      List<String> displayOrderList = reportServiceImpl.getFacilitySettingOrderListToEquipment2(facilityCd, "3006");
      midList = reportServiceImpl.sortReportInfo(midList, displayOrderList, 9999999);
      reportInfoIndex.put(Long.valueOf("74"), midList);
    }
    List<Map<String, Object>> reportReality = reportInfoIndex.get(Long.valueOf("97"));
    if (reportReality != null && reportReality.size() > 0) {
      List<Map<String, Object>> midList = reportInfoIndex.get(Long.valueOf("97"));
      // 施設設定マスタNo.106 医材表示順 設定値
      List<String> displayOrderList = reportServiceImpl.getFacilitySettingOrderListToEquipment2(facilityCd, "3006");
      midList = reportServiceImpl.sortReportInfo(midList, displayOrderList, 9999999);
      reportInfoIndex.put(Long.valueOf("97"), midList);
    }
    List<Map<String, Object>> reportFutureActive = reportInfoIndex.get(Long.valueOf("141"));
    if (reportFutureActive != null && reportFutureActive.size() > 0){
      List<Map<String, Object>> midList = reportInfoIndex.get(Long.valueOf("141"));
      // 施設設定マスタNo.107 投与薬剤表示順 設定値
      List<String> displayOrderList = reportServiceImpl.getFacilitySettingOrderListToMedicine2(facilityCd, "3007");
      midList = reportServiceImpl.sortReportInfo(midList, displayOrderList, 9999999);
      reportInfoIndex.put(Long.valueOf("141"), midList);
    }
    List<Map<String, Object>> reportRealityMedDeg = reportInfoIndex.get(Long.valueOf("190"));
    if (reportRealityMedDeg != null && reportRealityMedDeg.size() > 0){
      List<Map<String, Object>> midList = reportInfoIndex.get(Long.valueOf("190"));
      // 施設設定マスタNo.107 投与薬剤表示順 設定値
      List<String> displayOrderList = reportServiceImpl.getFacilitySettingOrderListToMedicine2(facilityCd, "3007");
      midList = reportServiceImpl.sortReportInfo(midList, displayOrderList, 9999999);
      reportInfoIndex.put(Long.valueOf("190"), midList);
    }
    // add #10042 カテゴリ「指示」の出力不正 03 sunsy end
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

    // add #11249 患者情報系historyの取得条件見直し（集計有り紹介状）高 start
  private static Map<String, Object> deepCopyMap(Map<String, Object> original)
    throws IOException, ClassNotFoundException {
    ByteArrayOutputStream bos = new ByteArrayOutputStream();
    ObjectOutputStream out = new ObjectOutputStream(bos);
    out.writeObject(original);

    ByteArrayInputStream bis = new ByteArrayInputStream(bos.toByteArray());
    ObjectInputStream in = new ObjectInputStream(bis);

    @SuppressWarnings("unchecked")
    Map<String, Object> copy = (Map<String, Object>) in.readObject();

    out.close();
    in.close();

    return copy;
  }
  // add #11249 患者情報系historyの取得条件見直し（集計有り紹介状）高 end

  // add #10224 集計紹介状、集計表の出力順について再精査 高 start
  public void sortMedicationsAndEquipmentsByFacilitySetting(Map<Long, List<Map<String, Object>>> reportInfo,MstReport mstReport){
    List<Map<String, Object>> reportIndicateResult = reportInfo.get(Long.valueOf("4"));
    List<Map<String, Object>> reportRealityResult = reportInfo.get(Long.valueOf("74"));
    List<Map<String, Object>> reportIndicate = reportInfo.get(Long.valueOf("8"));
    List<Map<String, Object>> reportReality = reportInfo.get(Long.valueOf("97"));
    if (reportIndicateResult != null && reportIndicateResult.size() > 0){
      List<Map<String, Object>> midList = reportInfo.get(Long.valueOf("4"));
      // 施設設定マスタNo.107 投与薬剤表示順 設定値
      List<FacilitySettingNoDisplayOrder> listDisplayOrder = new ArrayList<>();
      listDisplayOrder = ordMainDao.selectMedEquipDisplayOrder(mstReport.getFacilityCd());
      String displayValue = null;
      String[] keyList = new String[]{};
      List<String> displayOrderList = new ArrayList<>();
      for (int x = 0; x < listDisplayOrder.size(); x++) {
        if ("3007".equals(listDisplayOrder.get(x).getFacilitySettingNo())) {
          displayValue = listDisplayOrder.get(x).getValue();
        }
      }
      if (displayValue != null) {
        keyList = displayValue.replace("[","").replace("]","").replace("\"","").split(",");
      }
      for(int x = 0;x < keyList.length; x++){
        switch (keyList[x]){
          // 登録順
          case "0":
            displayOrderList.add("json_idx");
            break;
          // 薬剤分類順
          case "1":
            displayOrderList.add("med_cls_cd");
            break;
          // 薬剤区分
          case "2":
            displayOrderList.add("medicine_type");
            break;
          // 薬剤マスタ表示順
          case "3":
            displayOrderList.add("med_cd");
            displayOrderList.add("med_mix_cd");
            break;
          // 投与時間帯
          case "4":
            displayOrderList.add("med_timing_cd");
            break;
          // 手技
          case "5":
            displayOrderList.add("med_pro_cd");
            break;
          // 投薬パターンコード
          case "6":
            displayOrderList.add("date_interval");
            break;
          default:
            break;
        }
      }

      int sortSize = displayOrderList.size();
      int[] compareResultArr = new int[sortSize];
      String[] colArr = new String[sortSize];
      for(int x = 0; x < sortSize; x++) {
        compareResultArr[x]= 0;
        colArr[x] = displayOrderList.get(x);
      }
      // 施設設定マスタNo.107に設定された順番で薬剤を表示する
      Collections.sort(midList, new Comparator<Map<String, Object>>() {
        public int compare(Map<String, Object> o1, Map<String, Object> o2) {
          for (int x = 0, len = sortSize; x < len; x++) {
            Integer v1 = (o1.get(colArr[x]) == null || o1.get(colArr[x]) == "") ? 9999999 : Integer.parseInt(o1.get(colArr[x]).toString());
            Integer v2 = (o2.get(colArr[x]) == null || o2.get(colArr[x]) == "") ? 9999999 : Integer.parseInt(o2.get(colArr[x]).toString());
            compareResultArr[x] = v1.compareTo(v2);
            if (compareResultArr[x] != 0){
              return compareResultArr[x];
            }
          }
          return 0;
        }
      });
      reportInfo.put(Long.valueOf("4"), midList);
    }
    if (reportIndicate != null && reportIndicate.size() > 0){
      List<Map<String, Object>> midList = reportInfo.get(Long.valueOf("8"));
      // 施設設定マスタNo.107 投与薬剤表示順 設定値
      List<FacilitySettingNoDisplayOrder> listDisplayOrder = new ArrayList<>();
      listDisplayOrder = ordMainDao.selectMedEquipDisplayOrder(mstReport.getFacilityCd());
      String displayValue = null;
      String[] keyList = new String[]{};
      List<String> displayOrderList = new ArrayList<>();
      for (int x = 0; x < listDisplayOrder.size(); x++) {
        if ("3007".equals(listDisplayOrder.get(x).getFacilitySettingNo())) {
          displayValue = listDisplayOrder.get(x).getValue();
        }
      }
      if (displayValue != null) {
        keyList = displayValue.replace("[","").replace("]","").replace("\"","").split(",");
      }
      for(int x = 0;x < keyList.length; x++){
        switch (keyList[x]){
          // 登録順
          case "0":
            displayOrderList.add("json_idx");
            break;
          // 薬剤分類順
          case "1":
            displayOrderList.add("med_cls_cd");
            break;
          // 薬剤区分
          case "2":
            displayOrderList.add("medicine_type");
            break;
          // 薬剤マスタ表示順
          case "3":
            displayOrderList.add("med_cd");
            displayOrderList.add("med_mix_cd");
            break;
          // 投与時間帯
          case "4":
            displayOrderList.add("med_timing_cd");
            break;
          // 手技
          case "5":
            displayOrderList.add("med_pro_cd");
            break;
          // 投薬パターンコード
          case "6":
            displayOrderList.add("date_interval");
            break;
          default:
            break;
        }
      }

      int sortSize = displayOrderList.size();
      int[] compareResultArr = new int[sortSize];
      String[] colArr = new String[sortSize];
      for(int x = 0; x < sortSize; x++) {
        compareResultArr[x]= 0;
        colArr[x] = displayOrderList.get(x);
      }
      // 施設設定マスタNo.107に設定された順番で薬剤を表示する
      Collections.sort(midList, new Comparator<Map<String, Object>>() {
        public int compare(Map<String, Object> o1, Map<String, Object> o2) {
          for (int x = 0, len = sortSize; x < len; x++) {
            Integer v1 = (o1.get(colArr[x]) == null || o1.get(colArr[x]) == "") ? 9999999 : Integer.parseInt(o1.get(colArr[x]).toString());
            Integer v2 = (o2.get(colArr[x]) == null || o2.get(colArr[x]) == "") ? 9999999 : Integer.parseInt(o2.get(colArr[x]).toString());
            compareResultArr[x] = v1.compareTo(v2);
            if (compareResultArr[x] != 0){
              return compareResultArr[x];
            }
          }
          return 0;
        }
      });
      reportInfo.put(Long.valueOf("8"), midList);
    }
    if (reportRealityResult != null && reportRealityResult.size() > 0) {
      List<Map<String, Object>> midList = reportInfo.get(Long.valueOf("74"));
      // 施設設定マスタNo.106 医材表示順 設定値
      List<FacilitySettingNoDisplayOrder> listDisplayOrder = new ArrayList<>();
      listDisplayOrder = ordMainDao.selectMedEquipDisplayOrder(mstReport.getFacilityCd());
      String displayValue = null;
      String[] keyList = new String[]{};
      List<String> displayOrderList = new ArrayList<>();
      for (int x = 0; x < listDisplayOrder.size(); x++) {
        if ("3006".equals(listDisplayOrder.get(x).getFacilitySettingNo())) {
          displayValue = listDisplayOrder.get(x).getValue();
        }
      }
      if (displayValue != null) {
        keyList = displayValue.replace("[","").replace("]","").replace("\"","").split(",");
      }
      for(int x = 0; x < keyList.length; x++){
        switch (keyList[x]){
          // 登録順
          case "0":
            displayOrderList.add("json_idx");
            break;
          // 医材分類順
          case "1":
            displayOrderList.add("class_order");
            break;
          // 医材マスタ表示順
          case "2":
            displayOrderList.add("code_order");
            break;
          default:
            break;
        }
      }

      int sortSize = displayOrderList.size();
      int[] compareResultArr = new int[sortSize];
      String[] colArr = new String[sortSize];
      for(int x = 0; x < sortSize; x++) {
        compareResultArr[x]= 0;
        colArr[x] = displayOrderList.get(x);
      }
      // 施設設定マスタNo.106に設定された順番で医材を表示する
      Collections.sort(midList, new Comparator<Map<String, Object>>() {
        public int compare(Map<String, Object> o1, Map<String, Object> o2) {
          for (int x = 0, len = sortSize; x < len; x++) {
            Integer v1 = (o1.get(colArr[x]) == null || o1.get(colArr[x]) == "") ? 999999 : Integer.parseInt(o1.get(colArr[x]).toString());
            Integer v2 = (o2.get(colArr[x]) == null || o2.get(colArr[x]) == "") ? 999999 : Integer.parseInt(o2.get(colArr[x]).toString());
            compareResultArr[x] = v1.compareTo(v2);
            if (compareResultArr[x] != 0){
              return compareResultArr[x];
            }
          }
          return 0;
        }
      });
      reportInfo.put(Long.valueOf("74"), midList);
    }
    if (reportReality != null && reportReality.size() > 0) {
      List<Map<String, Object>> midList = reportInfo.get(Long.valueOf("97"));
      // 施設設定マスタNo.106 医材表示順 設定値
      List<FacilitySettingNoDisplayOrder> listDisplayOrder = new ArrayList<>();
      listDisplayOrder = ordMainDao.selectMedEquipDisplayOrder(mstReport.getFacilityCd());
      String displayValue = null;
      String[] keyList = new String[]{};
      List<String> displayOrderList = new ArrayList<>();
      for (int x = 0; x < listDisplayOrder.size(); x++) {
        if ("3006".equals(listDisplayOrder.get(x).getFacilitySettingNo())) {
          displayValue = listDisplayOrder.get(x).getValue();
        }
      }
      if (displayValue != null) {
        keyList = displayValue.replace("[","").replace("]","").replace("\"","").split(",");
      }
      for(int x = 0; x < keyList.length; x++){
        switch (keyList[x]){
          // 登録順
          case "0":
            displayOrderList.add("json_idx");
            break;
          // 医材分類順
          case "1":
            displayOrderList.add("class_order");
            break;
          // 医材マスタ表示順
          case "2":
            displayOrderList.add("code_order");
            break;
          default:
            break;
        }
      }

      int sortSize = displayOrderList.size();
      int[] compareResultArr = new int[sortSize];
      String[] colArr = new String[sortSize];
      for(int x = 0; x < sortSize; x++) {
        compareResultArr[x]= 0;
        colArr[x] = displayOrderList.get(x);
      }
      // 施設設定マスタNo.106に設定された順番で医材を表示する
      Collections.sort(midList, new Comparator<Map<String, Object>>() {
        public int compare(Map<String, Object> o1, Map<String, Object> o2) {
          for (int x = 0, len = sortSize; x < len; x++) {
            Integer v1 = (o1.get(colArr[x]) == null || o1.get(colArr[x]) == "") ? 999999 : Integer.parseInt(o1.get(colArr[x]).toString());
            Integer v2 = (o2.get(colArr[x]) == null || o2.get(colArr[x]) == "") ? 999999 : Integer.parseInt(o2.get(colArr[x]).toString());
            compareResultArr[x] = v1.compareTo(v2);
            if (compareResultArr[x] != 0){
              return compareResultArr[x];
            }
          }
          return 0;
        }
      });
      reportInfo.put(Long.valueOf("97"), midList);
    }
  }
  // add #10224 集計紹介状、集計表の出力順について再精査 高 end
  // add #12324 紹介状の出力時にpat_eventを参照する zhao start
  /**
   * 登録済みデータがあればpat_event.letter_infoを出力する。
   * @param reportOutputInfoList 帳票出力情報
   * @param dataKey データ抽出キー
   */
  private void editLetterInfoForScreenDisplay (List<Map<String, String>> reportOutputInfoList,
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
        reportOutputInfo.put(fieldName, value);
      }
      reportOutputInfoList.add(reportOutputInfo);
    }
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
// mod #10857 帳票内に同項目が複数あると設定値を取り違える limingzhe end
