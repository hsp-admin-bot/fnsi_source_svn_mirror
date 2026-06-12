package jp.co.nikkiso.ntss.admin_web.web.rest;

import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.request.creatingReport.ReportByCdRequest;
import jp.co.nikkiso.ntss.admin_web.request.creatingReport.ReportRequest;
import jp.co.nikkiso.ntss.admin_web.response.creatingReport.MstReportResponse;
import jp.co.nikkiso.ntss.admin_web.response.creatingReport.PrinterInfo;
import jp.co.nikkiso.ntss.admin_web.response.creatingReport.ReportHtmlResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.print.PrinterService;
import jp.co.nikkiso.ntss.admin_web.service.reportMenu.ReportMenuDataKeyService;
import jp.co.nikkiso.ntss.admin_web.service.reportMenu.ReportMenuService;
import jp.co.nikkiso.ntss.admin_web.service.access.FacilityAccessService;
import jp.co.nikkiso.ntss.api.constant.ReportConstant;
import jp.co.nikkiso.ntss.api.service.report.ReportForOnePatientService;
import jp.co.nikkiso.ntss.api.service.report.ReportForIntroductionReportService;
import jp.co.nikkiso.ntss.api.service.report.ReportForDistributionListService;
import jp.co.nikkiso.ntss.api.service.report.ReportForMachineReportService;
import jp.co.nikkiso.ntss.api.service.report.ReportForLabelReportService;
import jp.co.nikkiso.ntss.api.service.report.ReportForTotalService;
import jp.co.nikkiso.ntss.api.service.report.ReportService;
import jp.co.nikkiso.ntss.api.service.utils.AsposeCellsUtils;
import jp.co.nikkiso.ntss.api.service.utils.TmpFileService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.DevMenteMainDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstReportDao;
import jp.co.nikkiso.ntss.core.dao.MstTreatmentDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.OrdPrescriptionDao;
import jp.co.nikkiso.ntss.core.dao.ReportMenuDao;
import jp.co.nikkiso.ntss.core.entity.MstMachineReportList;
import jp.co.nikkiso.ntss.core.entity.MstReport;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.OrdPrescription;
import jp.co.nikkiso.ntss.core.entity.PatEvent;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.math.NumberUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ResourceLoader;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.BufferedInputStream;
import java.io.ByteArrayInputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;

/**
 * 帳票作成のResourceクラス.
 */
@RestController
@Slf4j
@RequestMapping(Uri.CREATING_REPORT)
public class ReportResource {
  /**
   * スケジュール表
   */
  private static final long REPORT_CD_SCHEDULE = -1L;

  /**
   * 水質調査一覧
   */
  private static final long REPORT_CD_WATER_SURVEY = -2L;

  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;

  @Autowired
  ReportForTotalService reportForTotalService;

  @Autowired
  private DevMenteMainDao devMenteMainDao;

  /**
   * 帳票作成Service.
   */
  @Autowired
  private ReportService reportService;

  @Autowired
  private ReportForOnePatientService reportForOnePatientService;

  // add #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe start
  @Autowired
  private ReportForDistributionListService reportForDistributionListService;
  // add #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe end

  @Autowired
  ReportForMachineReportService reportForMachineReportService;

  // add #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe start
  @Autowired
  private ReportForLabelReportService reportForLabelReportService;
  // add #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe end

  @Autowired
  ReportForIntroductionReportService reportForIntroductionReportService;

  @Autowired
	LogService logService;

  /**
   * プリンターService.
   */
  @Autowired
  private PrinterService printerService;

  @Autowired
  private MstTreatmentDao mstTreatmentDao;
  @Autowired
  private OrdMainDao ordMainDao;
  @Autowired
  private MstReportDao mstReportDao;
  @Autowired
  ReportMenuService reportMenuService;

  @Autowired
  ReportMenuDataKeyService reportMenuDataKeyService;

  @Autowired
  LogEventUtils logEventUtils;
  @Autowired
  private FacilityAccessService facilityAccessService;

  /**
   * S3バケット名(紹介状ファイル取得先)
   */
  @Value("${ntss.pat-event.s3-bucket}")
  private String s3Bucket;
  @Autowired
  private ReportMenuDao reportMenuDao;
  // #10959 システム内でstatic変数を使っている箇所の洗い出し 20260428 mod yangxuewang start
//  private boolean changeCd = false;
  private final ConcurrentMap<Long, Boolean> changeCdByUser = new ConcurrentHashMap<>();
  // #10959 システム内でstatic変数を使っている箇所の洗い出し 20260428 mod yangxuewang end

  @Autowired
  MstFacilitySettingDao mstFacilitySettingDao;

  @Autowired
  ResourceLoader resourceLoader;

  @Value("${ntss.report.createTmpDir}")
  private String createTmpDir;

  /**
   * 一時ファイル作成のインタフェース.
   */
  @Autowired
  private TmpFileService tmpFileService;

  @Autowired
  private OrdPrescriptionDao ordPrescriptionDao;

  /**
   * 帳票マスタ取得.
   *
   * @param funcCd 機能コード
   * @param ntssUser NTSS認証ユーザ
   * @return 帳票マスタのResponse
   */
  @GetMapping("/mst-report/{funcCd}/{printFlag}")
  public ResponseEntity<?> getMstReport(
    @PathVariable("funcCd") String funcCd,
    @PathVariable("printFlag") String printFlag,
    @RequestParam(required = false) Long selectedPatId,
    @AuthenticationPrincipal NtssUser ntssUser) {
    if (!facilityAccessService.hasFacilityOrSelectedPatShareAccess(ntssUser, ntssUser.getFacilityCd(), selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }



    // #10959 システム内でstatic変数を使っている箇所の洗い出し 20260428 mod yangxuewang start
    Long userId = ntssUser.getUserId();
    boolean changeCd = Boolean.TRUE.equals(changeCdByUser.get(userId));
    if (changeCd && "1".equals(printFlag)) {
      printFlag = "2";
      changeCdByUser.remove(userId);
    }
    // #10959 システム内でstatic変数を使っている箇所の洗い出し 20260428 mod yangxuewang end
    String mappingUrl = Uri.CREATING_REPORT + "/mst-report";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
      "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(funcCd, printFlag));

    // 帳票マスタの取得
    List<MstReport> mstReports = new ArrayList<MstReport>();
    // プリンタ情報の取得
    List<PrinterInfo> printerInfos = new ArrayList<PrinterInfo>();
    // プレビューフラグの定義
    String isPreview = "1";

    // 機能帳票に割り当てられた帳票マスタを取得する
    if (funcCd.equals("02301") || funcCd.equals("02901") || funcCd.equals("03001")) {
      printFlag = "1";
    } else if (funcCd.equals("00801") || funcCd.equals("00901")
      || funcCd.equals("01101") || funcCd.equals("01201")
      || funcCd.equals("01401") || funcCd.equals("01501") || funcCd.equals("03101")
      || funcCd.equals("03701") || funcCd.equals("01801") || funcCd.equals("02201")
      || funcCd.equals("02801")
    ) {
      printFlag = "0";
    }
    if (funcCd.equals("01802")) {
      // #10959 システム内でstatic変数を使っている箇所の洗い出し 20260428 mod yangxuewang start
      changeCdByUser.put(userId, true);
      // #10959 システム内でstatic変数を使っている箇所の洗い出し 20260428 mod yangxuewang end
      funcCd = "01801";
    }
    if (funcCd.equals("02102")) {
      funcCd = "02101";
    }
    if (funcCd.equals("02202")) {
      funcCd = "02201";
    }
    if (funcCd.equals("02804") || funcCd.equals("02805")) {
      funcCd = "02801";
    }
    if (funcCd.equals("01802")) {
      funcCd = "01801";
    }
    if (funcCd.equals("02303")) {
      funcCd = "02301";
    }
    if (funcCd.equals("01302")) {
      funcCd = "01301";
    }
    if (funcCd.equals("01303")) {
      funcCd = "01301";
    }
    // add #12152 治療記録の各詳細画面で機能帳票が無効化する 高 start
    if (funcCd.startsWith("006")) {
      funcCd = "00601";
    }
    // add #12152 治療記録の各詳細画面で機能帳票が無効化する 高 end

    // add #12419 各画面の機能帳票リストが機能帳票マスタの表示順になっていない limingzhe start
    if (funcCd.length() == 3) {
      funcCd = funcCd + "01";
    }
    mstReports = reportService.getAllMstFunctionReportForFixedAndNormal(ntssUser.getFacilityCd(), funcCd, printFlag);
    // add #12419 各画面の機能帳票リストが機能帳票マスタの表示順になっていない limingzhe end

    // プリンタ情報の再取得
    printerInfos = printerService.getPrinterInfos(ntssUser.getFacilityCd());

    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
      "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(funcCd, printFlag));

    // レスポンス生成
    return new ResponseEntity<>(new MstReportResponse(mstReports, isPreview, printerInfos), HttpStatus.OK);
  }

  /**
   * 帳票情報（HTML）取得.
   *
   * @param request 帳票作成Request
   * @param ntssUser NTSS認証ユーザ
   * @return 帳票情報（HTML）データと抽出キーのResponse
   */
  @PostMapping("/creating-report")
  public ResponseEntity<?> getReportHtml(
    @RequestBody ReportRequest request,
    @AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.CREATING_REPORT + "/creating-report";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

//    // ログ出力
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage("REST request to get creating report");
//    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    MstReport mstReport = reportService.getMstReport(request.getReportClass(),
      request.getReportType(), ntssUser.getFacilityCd());

    // Excelファイル格納先パスが指定されている場合は、Excelテンプレートファイルに値を埋め込んでS3にアップロードする
    final Map<String, Object> dataKey = request.getDataKey();
    // mod #11775 【因島】印刷情報.共通情報.ログイン者が紹介状画面ではスタッフIDになる sunsy start
//    dataKey.put("login", ntssUser.getUsername());
    String name = mstPersonalUserDao.selectUserNameById(ntssUser.getUserId());
    dataKey.put("login", name);
    // mod #11775 【因島】印刷情報.共通情報.ログイン者が紹介状画面ではスタッフIDになる sunsy end

    // 帳票作成サービスの呼び出し
    String reportHtml = reportService.getReportHtml(mstReport.getReportCd(),
      dataKey, request.getTargetPrinter(), ntssUser.getUserId());




    // PDF格納先パスが指定されている場合は、HTMLをPDFに変換してS3にアップロードし、印刷要求を投げる
    if (!StringUtils.isEmpty(request.getPdfPath())) {
      reportService.convertHtmlToPdf(reportHtml, request.getPdfPath());
      printerService.sendPrintRequest(request.getTargetPrinter(), request.getPdfPath());
    }

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    // レスポンス生成
    return new ResponseEntity<>(new ReportHtmlResponse(reportHtml, dataKey), HttpStatus.OK);
  }

  @PostMapping("/creating-report/{reportCd}")
  public ResponseEntity<?> getReportHtmlByCd(
    @PathVariable("reportCd") Long reportCd,
    @RequestBody ReportByCdRequest request,
    @RequestParam(required = false) Long selectedPatId,
    @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
    if (!ntssUser.isNkkAdminUser()) {
      MstReport mstReport = mstReportDao.selectByCd(reportCd);
      if (mstReport != null && mstReport.getFacilityCd() != null
        && !facilityAccessService.hasFacilityOrSelectedPatShareAccess(
          ntssUser, mstReport.getFacilityCd(), selectedPatId)) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + mstReport.getFacilityCd() + " " + "reportCd=" + reportCd + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 end


    String mappingUrl = Uri.CREATING_REPORT + "/creating-report";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      reportCd);
    // mod #12107 帳票印刷失敗通知が行われない limingzhe start
    //String reportType = "";
    String reportClassName = "";
    // mod #12107 帳票印刷失敗通知が行われない limingzhe end
    String reportName = "";
    String facilityCd = "";
    try{
      String path = "";
      if (!StringUtils.isEmpty(request.getPdfPath())) {
        path = request.getPdfPath();
        if(reportCd.equals(REPORT_CD_WATER_SURVEY)){
          path = path.replace("dialysisReport","Device");
        }else if(
          // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
          //reportCd == -5 || reportCd == -6
          reportCd == CoreConstant.FixedReportCd.DAILY_INSPECT_RECORD_BOOK
            || reportCd == CoreConstant.FixedReportCd.PERIODIC_INSPECT_RECORD_BOOK
          // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
          // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe start
            || reportCd == CoreConstant.FixedReportCd.WATER_SURVEY_RECORD_BOOK
          // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe end
        ){
          path = path.replace("dialysisReport","Device");
          // add #12107 帳票印刷失敗通知が行われない limingzhe start
          facilityCd = String.valueOf(request.getDataKey().getOrDefault("facilityCd",""));
          reportClassName = reportMenuDataKeyService.getReportClassName(7);
          // add #12107 帳票印刷失敗通知が行われない limingzhe end
          // mod #11232 #10515で入れた制限の見直し 房 start
        }else if(
          // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
          //reportCd != -3
          reportCd != CoreConstant.FixedReportCd.DIALYSIS_REPORT
          // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
        ){
          // mod #11232 #10515で入れた制限の見直し 房 end
          MstReport report = mstReportDao.selectByCd(reportCd);
          String jumpPath = report.getReportPath().getXlsxZip();
          jumpPath = jumpPath.split("_")[0];
          path = path.replace("dialysisReport",jumpPath);
          // add #12107 帳票印刷失敗通知が行われない limingzhe start
          reportClassName = reportMenuDataKeyService.getReportClassName(report.getReportClass());
          // add #12107 帳票印刷失敗通知が行われない limingzhe end
        }
        request.setPdfPath(path);
        reportName = path.substring(path.lastIndexOf("/")+1, path.lastIndexOf("."));
      }

      Map<String, Object> dataKey = request.getDataKey();
      if(null != dataKey.get("ordNo")){
        OrdMain ordMain = ordMainDao.selectByOrdNo(Long.valueOf(dataKey.get("ordNo").toString()));
        facilityCd = ordMain.getFacilityCd();
        dataKey.put("patId",ordMain.getPatId());
      }else{
        facilityCd = ntssUser.getFacilityCd();
      }



      // add #11103 カテゴリ「印刷情報」の項目追加と修正 sunsy start
      dataKey.put(ReportConstant.ReportDataKey.currentPage,"");
      dataKey.put(ReportConstant.ReportDataKey.totalPages,"");
      // add #11103 カテゴリ「印刷情報」の項目追加と修正 sunsy end
      // add #11152 検査結果(個別)で機能帳票のパラメータに「検査セット」を追加 limingzhe start
      SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
      dataKey.put("prt_dt", sdf.format(new Date()));
      String name = mstPersonalUserDao.selectUserNameById(ntssUser.getUserId());
      dataKey.put("login", name);
      // add #11152 検査結果(個別)で機能帳票のパラメータに「検査セット」を追加 limingzhe end
      // add #11256 機能帳票の印刷情報対応① limingzhe start
      // 1日指定日
      if (dataKey.containsKey(ReportConstant.ReportDataKey.DATE) && !StringUtils.isEmpty(dataKey.get(ReportConstant.ReportDataKey.DATE))) {
        dataKey.put("specifyDate", dataKey.get(ReportConstant.ReportDataKey.DATE).toString().replace("/", "").replace("-", ""));
      }
      // 期間
      if (dataKey.containsKey(ReportConstant.ReportDataKey.DATE_FROM) && !StringUtils.isEmpty(dataKey.get(ReportConstant.ReportDataKey.DATE_FROM))) {
        String fromDate = dataKey.get(ReportConstant.ReportDataKey.DATE_FROM).toString().replace("/", "").replace("-", "");
        if(dataKey.containsKey(ReportConstant.ReportDataKey.DATE_TO) && !StringUtils.isEmpty(dataKey.get(ReportConstant.ReportDataKey.DATE_TO))){
          String toDate = dataKey.get(ReportConstant.ReportDataKey.DATE_TO).toString().replace("/", "").replace("-", "");
          String start = fromDate.substring(0,4) + "年" + fromDate.substring(4,6) + "月" + fromDate.substring(6)+ "日";
          String end =  toDate.substring(0,4) + "年" + toDate.substring(4,6) + "月" + toDate.substring(6)+ "日";
          dataKey.put(ReportConstant.ReportDataKey.period,start+"～"+end);
        }
      }
      // 週数
      String dateCalWeek = "";
      if (dataKey.containsKey("baseDate") && !StringUtils.isEmpty(dataKey.get("baseDate"))) {
        dateCalWeek = dataKey.get("baseDate").toString().replace("/","").replace("-","");
      }
      if(dateCalWeek.equals("") && dataKey.containsKey(ReportConstant.ReportDataKey.treatDate) && !StringUtils.isEmpty(dataKey.get(ReportConstant.ReportDataKey.treatDate))){
        if(dataKey.containsKey("functionCd") && (dataKey.get("functionCd").toString().equals("00601") || dataKey.get("functionCd").toString().equals("00901"))){
          dateCalWeek = dataKey.get(ReportConstant.ReportDataKey.treatDate).toString().replace("/","").replace("-","");
        }
      }
      if(dateCalWeek.equals("") && dataKey.containsKey(ReportConstant.ReportDataKey.DATE) && !StringUtils.isEmpty(dataKey.get(ReportConstant.ReportDataKey.DATE))){
        dateCalWeek = dataKey.get(ReportConstant.ReportDataKey.DATE).toString().replace("/","").replace("-","");
      }
      if(dateCalWeek.length()>0){
        String year = dateCalWeek.substring(0, 4);
        String month = dateCalWeek.substring(4, 6);
        String day = dateCalWeek.substring(6,8);
        Calendar calendar =Calendar.getInstance();
        calendar.setFirstDayOfWeek(Calendar.MONDAY);
        calendar.set(Calendar.YEAR, Integer.valueOf(year));
        calendar.set(Calendar.MONTH, Integer.valueOf(month) - 1);
        calendar.set(Calendar.DAY_OF_MONTH, Integer.valueOf(day));
        int week = calendar.get(Calendar.WEEK_OF_MONTH);
        dataKey.put(ReportConstant.ReportDataKey.weeks,week+"週目");
      }
      // add #11256 機能帳票の印刷情報対応① limingzhe end
      // del #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
//      Map<String, List> searchList = this.searchMap(ntssUser.getFacilityCd());
//      dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS, searchList.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
//      dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS, searchList.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
//      dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS, searchList.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
//      // add #11603 検査予定のラベル出力とフィルタ機能 高 start
//      dataKey.put(ReportConstant.ReportDataKey.EXAMSET_IDS, searchList.get(ReportConstant.ReportDataKey.EXAMSET_IDS));
//      // add #11603 検査予定のラベル出力とフィルタ機能 高 end
//      // add #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe start
//      dataKey.put(ReportConstant.ReportDataKey.INSPECT_IDS, searchList.get(ReportConstant.ReportDataKey.INSPECT_IDS));
//      // add #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe end
      // del #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end
      String reportHtml = "";
      if (reportCd.equals(REPORT_CD_SCHEDULE)) {
        reportHtml = reportService.getReportHtmlSchedule(dataKey, request.getTargetPrinter(), ntssUser.getUserId());
      }
      else if (reportCd.equals(REPORT_CD_WATER_SURVEY)) {
        reportHtml = reportService.getReportHtmlWaterSurvey(dataKey, request.getTargetPrinter(), ntssUser.getUserId());
      }
      else if (
        // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
        //reportCd == -3 || reportCd == -4
        reportCd == CoreConstant.FixedReportCd.DIALYSIS_REPORT
          || reportCd == CoreConstant.FixedReportCd.DIALYSIS_REPORT_HANDWRITTEN
        // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
      ) {
        //透析レポート 治療経過表（自動選択）        治療経過表（手書き：自動選択）
        long ordNo = 0;
        String patId = "";
        String baseDate = "";
        MstTreatment treatment = new MstTreatment();
        if (null == dataKey.get("ordNo")) {
          if (null != dataKey.get("patId") && null == dataKey.get("baseDate")) {
            Optional<OrdMain> ordMain = ordMainDao.selectNearByPatId(Long.valueOf(dataKey.get("patId").toString()), dataKey.get("date").toString());
            // mod #9558 機能帳票で正しく変数が引き渡されていない 高 start
            if (!ordMain.isEmpty()) {
              ordNo = Math.toIntExact(ordMain.get().getOrdNo());
            }
//            ordNo = Math.toIntExact(ordMain.get().getOrdNo());
            // mod #9558 機能帳票で正しく変数が引き渡されていない 高 end
          } else {
            Map<String, Object> map = (Map<String, Object>) dataKey.get("patId");
            map = (Map<String, Object>) map.get("pat_personal_main");
            patId = map.get("pat_id").toString();
            baseDate = dataKey.get("baseDate").toString();
            OrdMain ordMain = ordMainDao.selectByPatIdAndDate(Long.valueOf(patId), baseDate, facilityCd);
            // mod #9558 機能帳票で正しく変数が引き渡されていない 高 start
            if (ordMain != null) {
              ordNo = ordMain.getOrdNo();
            }
//            ordNo = ordMain.getOrdNo();
            // mod #9558 機能帳票で正しく変数が引き渡されていない 高 end
            // add #9558 機能帳票で正しく変数が引き渡されていない 高 start
            dataKey.put("patId", patId);
            dataKey.put("date", baseDate);
            // add #9558 機能帳票で正しく変数が引き渡されていない 高 end
          }
          // del #9558 機能帳票で正しく変数が引き渡されていない 高 start
//          dataKey.put("patId", patId);
          // del #9558 機能帳票で正しく変数が引き渡されていない 高 end
          dataKey.put("ordNo", ordNo);
          // del #9558 機能帳票で正しく変数が引き渡されていない 高 start
//          dataKey.put("date", baseDate);
          // del #9558 機能帳票で正しく変数が引き渡されていない 高 end
          treatment = mstTreatmentDao.selectByOrdNo(ordNo);
        } else {
          treatment = mstTreatmentDao.selectByOrdNo(Long.valueOf(dataKey.get("ordNo").toString()));
        }

        if (treatment == null) {
          // mod #9558 機能帳票で正しく変数が引き渡されていない 高 start
          FacilitySettingInfo facilitySettingInfo = mstFacilitySettingDao.getBySettingNoAndCd(facilityCd, CoreConstant.FacilitySettingNo.DEFAULT_REPORT_TEMPLATE);
          if (!StringUtils.isEmpty(facilitySettingInfo.getValue())) {
            reportCd = Long.parseLong(facilitySettingInfo.getValue());
          }
          if (Objects.isNull(reportCd) || reportCd == 0) {
            return new ResponseEntity<>("レイアウトがありません", HttpStatus.OK);
          }
          if (dataKey.containsKey("functionCd")) {
            MstReport report = mstReportDao.selectReportByReportCd(reportCd);
            List<OrdMain> ordNosList = new ArrayList<>();
            dataKey = reportMenuDataKeyService.setDataKeyMeth(reportCd,report,request,ntssUser, ordNosList);

          }
          // mod #9558 機能帳票で正しく変数が引き渡されていない 2024.8.23 高 start
//          reportHtml = reportService.getReportHtml(reportCd, dataKey, request.getTargetPrinter(), ntssUser.getUserId());
          try {
            reportHtml = reportService.getReportHtml(reportCd, dataKey, request.getTargetPrinter(), ntssUser.getUserId());
          } catch (Exception e){
          } finally {
            return new ResponseEntity<>(new ReportHtmlResponse(reportHtml, dataKey), HttpStatus.OK);
          }
          // mod #9558 機能帳票で正しく変数が引き渡されていない 2024.8.23 高 end
//          reportCd = 0L;
          // mod #9558 機能帳票で正しく変数が引き渡されていない 高 end
        } else {
          // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
          //if (reportCd == -3L)
          if(reportCd == CoreConstant.FixedReportCd.DIALYSIS_REPORT)
          // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
          {
            // mod #9558 機能帳票で正しく変数が引き渡されていない 2024.8.23 高 start
//            if (null != treatment.getReportId()) {
            if (null != treatment.getReportId() && treatment.getReportId() != 0) {
              // mod #9558 機能帳票で正しく変数が引き渡されていない 2024.8.23 高 end
              reportCd = Long.valueOf(treatment.getReportId());
            } else {
              // mod #9558 機能帳票で正しく変数が引き渡されていない 2024.8.23 高 start
//              return new ResponseEntity<>(new ReportHtmlResponse(reportHtml, dataKey), HttpStatus.OK);
              FacilitySettingInfo facilitySettingInfo = mstFacilitySettingDao.getBySettingNoAndCd(facilityCd, CoreConstant.FacilitySettingNo.DEFAULT_REPORT_TEMPLATE);
              if (!StringUtils.isEmpty(facilitySettingInfo.getValue())) {
                reportCd = Long.parseLong(facilitySettingInfo.getValue());
              }
              if (Objects.isNull(reportCd) || reportCd == 0) {
                return new ResponseEntity<>("レイアウトがありません", HttpStatus.OK);
              }
              // add #9558 機能帳票で正しく変数が引き渡されていない 2024.9.20 高 start
              if (dataKey.containsKey("functionCd")) {
                MstReport report = mstReportDao.selectReportByReportCd(reportCd);
                List<OrdMain> ordNosList = new ArrayList<>();
                dataKey = reportMenuDataKeyService.setDataKeyMeth(reportCd,report,request,ntssUser, ordNosList);
              }
              // add #9558 機能帳票で正しく変数が引き渡されていない 2024.9.20 高 end
              try {
                reportHtml = reportService.getReportHtml(reportCd, dataKey, request.getTargetPrinter(), ntssUser.getUserId());
              } catch (Exception e){
              } finally {
                return new ResponseEntity<>(new ReportHtmlResponse(reportHtml, dataKey), HttpStatus.OK);
              }
              // mod #9558 機能帳票で正しく変数が引き渡されていない 2024.8.23 高 end
            }
          } else {
            // mod #9558 機能帳票で正しく変数が引き渡されていない 2024.8.23 高 start
//            if (null != treatment.getReportIdHw()) {
            if (null != treatment.getReportIdHw() && treatment.getReportIdHw() != 0) {
              // mod #9558 機能帳票で正しく変数が引き渡されていない 2024.8.23 高 end
              reportCd = Long.valueOf(treatment.getReportIdHw());
            } else {
              // mod #9558 機能帳票で正しく変数が引き渡されていない 2024.8.23 高 start
//              return new ResponseEntity<>(new ReportHtmlResponse(reportHtml, dataKey), HttpStatus.OK);
              FacilitySettingInfo facilitySettingInfo = mstFacilitySettingDao.getBySettingNoAndCd(facilityCd, CoreConstant.FacilitySettingNo.DEFAULT_REPORT_TEMPLATE);
              if (!StringUtils.isEmpty(facilitySettingInfo.getValue())) {
                reportCd = Long.parseLong(facilitySettingInfo.getValue());
              }
              if (Objects.isNull(reportCd) || reportCd == 0) {
                return new ResponseEntity<>("レイアウトがありません", HttpStatus.OK);
              }
              // add #9558 機能帳票で正しく変数が引き渡されていない 2024.9.20 高 start
              if (dataKey.containsKey("functionCd")) {
                MstReport report = mstReportDao.selectReportByReportCd(reportCd);
                List<OrdMain> ordNosList = new ArrayList<>();
                dataKey = reportMenuDataKeyService.setDataKeyMeth(reportCd,report,request,ntssUser, ordNosList);
              }
              // add #9558 機能帳票で正しく変数が引き渡されていない 2024.9.20 高 end
              try {
                reportHtml = reportService.getReportHtml(reportCd, dataKey, request.getTargetPrinter(), ntssUser.getUserId());
              } catch (Exception ex) {
              } finally {
                return new ResponseEntity<>(new ReportHtmlResponse(reportHtml, dataKey), HttpStatus.OK);
              }
              // mod #9558 機能帳票で正しく変数が引き渡されていない 2024.8.23 高 end
            }
          }
          // add #9558 機能帳票で正しく変数が引き渡されていない 高 start
          if (dataKey.containsKey("functionCd")) {
            MstReport report = mstReportDao.selectReportByReportCd(reportCd);
            List<OrdMain> ordNosList = new ArrayList<>();
            dataKey = reportMenuDataKeyService.setDataKeyMeth(reportCd,report,request,ntssUser, ordNosList);
          }
          // add #9558 機能帳票で正しく変数が引き渡されていない 高 end
          // mod #9558 機能帳票で正しく変数が引き渡されていない 2024.8.23 高 start
//          reportHtml = reportService.getReportHtml(reportCd, dataKey, request.getTargetPrinter(), ntssUser.getUserId());
          try {
            reportHtml = reportService.getReportHtml(reportCd, dataKey, request.getTargetPrinter(), ntssUser.getUserId());
          } catch (Exception e){
            return new ResponseEntity<>(new ReportHtmlResponse(reportHtml, dataKey), HttpStatus.OK);
          }
          // mod #9558 機能帳票で正しく変数が引き渡されていない 2024.8.23 高 end
        }
      }
      else if (
        // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
        //reportCd == -5 || reportCd == -6
        reportCd == CoreConstant.FixedReportCd.DAILY_INSPECT_RECORD_BOOK
          || reportCd == CoreConstant.FixedReportCd.PERIODIC_INSPECT_RECORD_BOOK
        // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
        // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe start
          || reportCd == CoreConstant.FixedReportCd.WATER_SURVEY_RECORD_BOOK
        // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe end
      ) {
        // mod #11100 【総合検証NG】装置帳票＞定期点検（日常点検記録簿、定期点検記録簿）のプレビューができない。 limingzhe start
//        List<Long> reportCdList = new ArrayList<>();
//        List<Integer> machineNos = new ArrayList<>();
//        List<Integer> list = (List<Integer>) dataKey.get("selectNos");
//        if (null != list && list.size() > 0) {
//          machineNos = list;
//        } else {
//          machineNos = (List<Integer>) dataKey.get("machineNos");
//        }
//        if (null != machineNos && machineNos.size() > 0) {
//          List<Map<String, Object>> machines = new ArrayList<>();
//          for (int i = 0; i < machineNos.size(); i++) {
//            Map<String, Object> machine = new HashMap<>();
//            if (null == dataKey.get("fromDate") && null != dataKey.get("date")) {
//              dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, dataKey.get("date").toString());
//            }
//            if (null == dataKey.get("toDate") && null != dataKey.get("date")) {
//              dataKey.put(ReportConstant.ReportDataKey.DATE_TO, dataKey.get("date").toString());
//            }
//            machine.put(ReportConstant.ReportDataKey.DATE_FROM, dataKey.get("fromDate").toString());
//            machine.put(ReportConstant.ReportDataKey.DATE_TO, dataKey.get("toDate").toString());
//            machine.put(ReportConstant.ReportDataKey.DATE, null != dataKey.get("date") ? dataKey.get("date").toString() : null);
//            machine.put(ReportConstant.ReportDataKey.MACHINE_NO, machineNos.get(i));
//            machines.add(machine);
//            dataKey.put(ReportConstant.ReportDataKey.MACHINE_NO, machineNos.get(i));
//            List<Long> reportCds = new ArrayList<>();
//
//            if (reportCd == -5) {
//              reportCds = devMenteMainDao.selectLayoutCdByMainteClass(Long.valueOf(machineNos.get(i).toString()), dataKey.get("fromDate").toString().replace("-", "/"), null, null, null, null, null, null, "1");
//            } else {
//              reportCds = devMenteMainDao.selectLayoutCdByMainteClass(Long.valueOf(machineNos.get(i).toString()), dataKey.get("fromDate").toString().replace("-", "/"), null, null, null, null, null, null, "2");
//            }
//            if (null != reportCds && reportCds.size() > 0) {
//              reportHtml += reportService.getReportHtml(reportCds.get(0), dataKey, request.getTargetPrinter(), ntssUser.getUserId());
//            }
//          }
//        }
        // mod #11117 日常点検記録簿が1ページ1装置で出力される limingzhe start
//        List<Integer> machineNos = dataKey.get("machineNos") != null ? (List<Integer>) dataKey.get("machineNos") : new ArrayList<>();
//        for (int i = 0; i < machineNos.size(); i++) {
//          List<Long> reportCds = new ArrayList<>();
//          if (reportCd == -5) {
//            reportCds = devMenteMainDao.selectLayoutCdByMainteClass(Long.valueOf(machineNos.get(i).toString()), dataKey.get("fromDate").toString().replace("-", "/"), null, null, null, null, null, null, "1");
//          } else {
//            reportCds = devMenteMainDao.selectLayoutCdByMainteClass(Long.valueOf(machineNos.get(i).toString()), dataKey.get("fromDate").toString().replace("-", "/"), null, null, null, null, null, null, "2");
//          }
//          if (dataKey.containsKey("date") && !StringUtils.isEmpty(dataKey.containsKey("date"))) {
//            // 対象日
//            dataKey.put("date", dataKey.get("date").toString().replace("/", "").replace("-", ""));
//          }
//          if (dataKey.containsKey("fromDate") && !StringUtils.isEmpty(dataKey.containsKey("fromDate"))) {
//            // 対象期間始
//            dataKey.put("fromDate", dataKey.get("fromDate").toString().replace("/", "").replace("-", ""));
//          }
//          if (dataKey.containsKey("toDate") && !StringUtils.isEmpty(dataKey.containsKey("toDate"))) {
//            // 対象期間終
//            dataKey.put("toDate", dataKey.get("toDate").toString().replace("/", "").replace("-", ""));
//          }
//          if (null != reportCds && reportCds.size() > 0) {
//            byte[] excelBytes = reportService.getReportExcelFileForMachineReport(reportCds.get(0), dataKey);
//            reportHtml += reportMenuService.convertBtyesToHtml(excelBytes);
//          }
//        }
//        if(reportHtml.length() == 0){
//          return new ResponseEntity<>("テンプレートがない", HttpStatus.OK);
//        }
        List<Long> machineNos = new ArrayList<>();
        if (dataKey.get(ReportConstant.ReportDataKey.MACHINE_NOS) != null) {
          List<Long> mNos = (List<Long>) dataKey.get(ReportConstant.ReportDataKey.MACHINE_NOS);
          for (int i = 0; i < mNos.size(); i++) {
            if (!StringUtils.isEmpty(mNos.get(i))) {
              machineNos.add(Long.parseLong(String.valueOf(mNos.get(i))));
            } else {
              machineNos.add(mNos.get(i));
            }
          }
        }
        // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
//        List<MstMachineReportList> machineReportList = devMenteMainDao.selectReportCdandMachineNoListByMainte(reportCd == -6 ? "2" : "1", machineNos, ntssUser.getFacilityCd(),
//          dataKey.get(ReportConstant.ReportDataKey.DATE_FROM).toString(), dataKey.get(ReportConstant.ReportDataKey.DATE_TO).toString());
        List<MstMachineReportList> machineReportList = new ArrayList<>();
        if(reportCd == CoreConstant.FixedReportCd.DAILY_INSPECT_RECORD_BOOK){
          // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
//          machineReportList = devMenteMainDao.selectReportCdandMachineNoListByMainte("1", machineNos, ntssUser.getFacilityCd(),
//            dataKey.get(ReportConstant.ReportDataKey.DATE_FROM).toString(), dataKey.get(ReportConstant.ReportDataKey.DATE_TO).toString());
          machineReportList = mstReportDao.selectReportCdandMachineNoListByMachineTypeCd("1", ntssUser.getFacilityCd(), machineNos);
          // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
        }
        else if(reportCd == CoreConstant.FixedReportCd.PERIODIC_INSPECT_RECORD_BOOK){
          // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
//          machineReportList = devMenteMainDao.selectReportCdandMachineNoListByMainte("2", machineNos, ntssUser.getFacilityCd(),
//            dataKey.get(ReportConstant.ReportDataKey.DATE_FROM).toString(), dataKey.get(ReportConstant.ReportDataKey.DATE_TO).toString());
          machineReportList = mstReportDao.selectReportCdandMachineNoListByMachineTypeCd("2", ntssUser.getFacilityCd(), machineNos);
          // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
        }
        // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
        // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe start
        else if(reportCd == CoreConstant.FixedReportCd.WATER_SURVEY_RECORD_BOOK) {
          machineReportList = mstReportDao.selectReportCdandMachineNoListByMachineTypeCd("3", ntssUser.getFacilityCd(), machineNos);
        }
        // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe end
        if(machineReportList == null || machineReportList.size() == 0){
          throw new Exception("テンプレートがない");
        }
        Map<Long, List<Long>> machineReportMap = new HashMap<>();
        for(int i =0; i < machineReportList.size(); i++){
          List<Long> machineList = new ArrayList<Long>();
          if(machineReportMap.get(machineReportList.get(i).getReportCd()) != null){
            machineList = machineReportMap.get(machineReportList.get(i).getReportCd());
          }
          machineList.add(machineReportList.get(i).getMachineNo());
          Set<Long> machineSet = new LinkedHashSet<Long>(machineList);
          machineList = new ArrayList<Long>(machineSet);
          machineReportMap.put(machineReportList.get(i).getReportCd(), machineList);
        }
        for (Long rCd : machineReportMap.keySet()) {
          MstReport report = mstReportDao.selectReportByReportCd(rCd);
          List<OrdMain> ordNosList = new ArrayList<>();
          dataKey = reportMenuDataKeyService.setDataKeyMeth(rCd, report, request, ntssUser, ordNosList);
          dataKey.put(ReportConstant.ReportDataKey.MACHINE_NOS, machineReportMap.get(rCd));
          byte[] excelBytes = reportForMachineReportService.getReportExcelFileForMachineReport(rCd, dataKey);
          reportHtml += reportMenuService.convertBtyesToHtml(excelBytes);
        }
        // mod #11117 日常点検記録簿が1ページ1装置で出力される limingzhe end
        // mod #11100 【総合検証NG】装置帳票＞定期点検（日常点検記録簿、定期点検記録簿）のプレビューができない。 limingzhe end
      }
      else if (null == reportCd || 0 == reportCd) {
        FacilitySettingInfo facilitySettingInfo = mstFacilitySettingDao.getBySettingNoAndCd(facilityCd, CoreConstant.FacilitySettingNo.DEFAULT_REPORT_TEMPLATE);
        reportCd = Long.parseLong(facilitySettingInfo.getValue());
      }
      else {
        MstReport report = mstReportDao.selectReportByReportCd(reportCd);
        if (report == null) {
          FacilitySettingInfo info = mstFacilitySettingDao.getBySettingNoAndCd(facilityCd, CoreConstant.FacilitySettingNo.DEFAULT_REPORT_TEMPLATE);
          Long rtnValue = 0L;
          if (null != info) {
            String value = info.getValue();
            if (NumberUtils.isCreatable(value)) {
              rtnValue = Long.parseLong(value);
            }
          }
          if (rtnValue.equals(0L)) {
            String error = "テンプレートが設定されていません。";
            outputErrorLog(facilityCd, error);
            throw new NtssException(error);
          }
          reportCd = rtnValue;
          report = mstReportDao.selectByCd(reportCd);
        }

        reportName = report.getReportName();
        facilityCd = report.getFacilityCd();
        List<OrdMain> ordNosList = new ArrayList<>();

        if (dataKey.containsKey("functionCd")) {
          dataKey = reportMenuDataKeyService.setDataKeyMeth(reportCd,report,request,ntssUser, ordNosList);
          // add #11285 機能帳票の印刷情報対応② 高 start
          // del #11775 【因島】印刷情報.共通情報.ログイン者が紹介状画面ではスタッフIDになる sunsy start
//          dataKey.put("login", ntssUser.getUsername());
          // del #11775 【因島】印刷情報.共通情報.ログイン者が紹介状画面ではスタッフIDになる sunsy end
          // add #11285 機能帳票の印刷情報対応② 高 end
          if (dataKey.containsKey("mas")) {
            // mod #9558 機能帳票で正しく変数が引き渡されていない 高 start
//            return new ResponseEntity<>("選択中のレイアウト用ではありません", HttpStatus.NOT_IMPLEMENTED);
            return new ResponseEntity<>("選択中のレイアウト用ではありません", HttpStatus.OK);
            // mod #9558 機能帳票で正しく変数が引き渡されていない 高 end
          }

        } else {
          if (dataKey.get("ordNo") != null) {
            Long or = Long.valueOf(dataKey.get("ordNo").toString());
            List<Long> ordNoList = new ArrayList<>();
            ordNoList.add(or);
            ordNosList=ordMainDao.selectAllByOrdNoList(ordNoList);
            // add #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
            dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD, ntssUser.getFacilityCd());
            dataKey.putAll(reportMenuDataKeyService.searchReportSettingForDataKey(String.valueOf(dataKey.getOrDefault(ReportConstant.ReportDataKey.FACILITY_CD, "")), reportCd, dataKey));
            // add #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end
            // add #10526 クラス「処方情報」の「保険者番号」等に一桁づつ出力するデータセットを追加 sunsy start
            // del #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
//            List<String> prescriptionClassList = new ArrayList<String>(Arrays.asList("1", "2"));
//            dataKey.put("prescriptionClassList", prescriptionClassList);
            // del #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end
            // mod #10526 クラス「処方情報」の「保険者番号」等に一桁づつ出力するデータセットを追加 20260528 sunsy start
//            if (ordNosList.size() > 0 && !StringUtils.isEmpty(ordNosList)) {
            if (ordNosList.size() > 0 && !StringUtils.isEmpty(ordNosList) && !StringUtils.isEmpty(dataKey.get(ReportConstant.ReportDataKey.PAT_ID))) {
            // mod #10526 クラス「処方情報」の「保険者番号」等に一桁づつ出力するデータセットを追加 20260528 sunsy end
              List<OrdPrescription> ordPrescriptionList = ordPrescriptionDao.selectResultByPatIdAndDateFromTo(
                Long.parseLong(String.valueOf(dataKey.get(ReportConstant.ReportDataKey.PAT_ID))),
                facilityCd,
                ordNosList.get(0).getTreatDate().toString().replace("/", "").replace("-", ""),
                ordNosList.get(0).getTreatDate().toString().replace("/", "").replace("-", ""),
                // mod #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
                //prescriptionClassList
                (List<String>)dataKey.get("prescriptionClassList")
                // mod #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end
              );
              List<Long> ordPrescriptionNos = new ArrayList<>();
              for (OrdPrescription rx : ordPrescriptionList) {
                ordPrescriptionNos.add(rx.getOrdPrescriptionNo());
              }
              dataKey.put(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NOS, ordPrescriptionNos);
            }
            // add #10526 クラス「処方情報」の「保険者番号」等に一桁づつ出力するデータセットを追加 sunsy end
          }
          // add #11299 「##=」型の計算式で「[##データ項目]」を参照するとエラーになる 高 start
          dataKey.put("reportClass",report.getReportClass());
          // add #11299 「##=」型の計算式で「[##データ項目]」を参照するとエラーになる 高 end
        }

        if (report.getReportClass().equals(ReportConstant.ReportClass.DIALYSIS_REPORT)) {
          // ◎帳票種別：01：治療経過表
          if (dataKey.get("reportOneFlag") != null) {
            // 機能帳票
            byte[] excelResult = reportService.getReportExcelFileForDialysisReport(reportCd, dataKey);
            // add #12107 帳票印刷失敗通知が行われない limingzhe start
            if (!StringUtils.isEmpty(request.getPdfPath())) {
              reportMenuService.engineryReportPdfPrint(excelResult, request.getPdfPath(), request.getTargetPrinter());
            }
            // add #12107 帳票印刷失敗通知が行われない limingzhe end
            try {
              if (!(excelResult == null || excelResult.length == 0)) {
                ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(excelResult);
                URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
                reportHtml += AsposeCellsUtils.excelToSvg(byteArrayInputStream, url);
                // del #12107 帳票印刷失敗通知が行われない limingzhe start
//                if (!StringUtils.isEmpty(request.getPdfPath())) {
//                  reportMenuService.engineryReportPdfPrint(excelResult, request.getPdfPath(), request.getTargetPrinter());
//                }
                // del #12107 帳票印刷失敗通知が行われない limingzhe end
              }
            } catch (Exception e) {
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
              EventLogMessage eventLogMessage = new EventLogMessage();
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
              eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
              if (ntssUser != null && ntssUser.getFacilityCd() != null) {
                eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
              }
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
              String funcCd = dataKey.get("functionCd") != null ? dataKey.get("functionCd").toString() : "";
              logService.log(LogLevel.ERROR, eventLogMessage, funcCd, SERVICE_NAME.FNSI, null);
              throw e;
            }
          } else {
            // 治療記録画面
            for (int i = 0; i < ordNosList.size(); i++) {
              dataKey.put(ReportConstant.ReportDataKey.ORD_NO, ordNosList.get(i).getOrdNo());
              dataKey.put(ReportConstant.ReportDataKey.PAT_ID, ordNosList.get(i).getPatId());
              dataKey.put(ReportConstant.ReportDataKey.DATE, ordNosList.get(i).getTreatDate());
              dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, ordNosList.get(i).getTreatDate());
              dataKey.put(ReportConstant.ReportDataKey.DATE_TO, ordNosList.get(i).getTreatDate());
              // del #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
//              dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD, ntssUser.getFacilityCd());
              // del #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end
              // del #11152 検査結果(個別)で機能帳票のパラメータに「検査セット」を追加 limingzhe start
              //dataKey.put("login", ntssUser.getUsername());
              // del #11152 検査結果(個別)で機能帳票のパラメータに「検査セット」を追加 limingzhe end
              dataKey.put("fromGlag", true);
              byte[] excelResult = reportService.getReportExcelFileForDialysisReport(reportCd, dataKey);
              try {
                if (!(excelResult == null || excelResult.length == 0)) {
                  ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(excelResult);
                  URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
                  reportHtml += AsposeCellsUtils.excelToSvg(byteArrayInputStream, url);
                }
              } catch (Exception e) {
                // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
                // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
                EventLogMessage eventLogMessage = new EventLogMessage();
                // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
                eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
                if (ntssUser != null && ntssUser.getFacilityCd() != null) {
                  eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
                }
                // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
                String funcCd = dataKey.get("functionCd") != null ? dataKey.get("functionCd").toString() : "";
                logService.log(LogLevel.ERROR, eventLogMessage, funcCd, SERVICE_NAME.FNSI, null);
              }
            }
          }
        }
        else if (report.getReportClass().equals(ReportConstant.ReportClass.ONE_PATIENT_REPORT)) {
          // 帳票種別：02：単患者帳票
          Map<String, Object> searchInfo = new HashMap<>();
          List<Map<Long, byte[]>> excelReportList = new ArrayList<>();
          List<Long> patIdsFor = new ArrayList<>();
          if (dataKey.get("patIds") == null) {
            patIdsFor.add((Long) dataKey.get("patId"));
          } else {
            patIdsFor = (List<Long>) dataKey.get("patIds");
          }
          for (int index = 0; index < patIdsFor.size(); index++) {
            // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
            //byte[] excelBytes = reportService.getReportExcelFileForOnePatient(reportCd, dataKey, searchInfo);
            byte[] excelBytes = reportForOnePatientService.getReportExcelFileForOnePatient(reportCd, dataKey, searchInfo);
            // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
            Map<Long, byte[]> reportMap = new HashMap<>();
            reportMap.put(Long.parseLong(String.valueOf(patIdsFor.get(index))), excelBytes);
            excelReportList.add(reportMap);
          }
          if (!StringUtils.isEmpty(request.getPdfPath())) {
            List<Map<Long, List<byte[]>>> excePrintlList = new ArrayList<>();
            Map<Long, List<byte[]>> request_map = null;
            List<byte[]> request_list = null;
            byte[] request_item = null;

            for (Map<Long, byte[]> map_item : excelReportList) {
              request_map = new HashMap<>();
              for (Long key : map_item.keySet()) {
                request_list = new ArrayList<>();
                request_item = map_item.get(key);
                request_list.add(request_item);
                request_map.put(key, request_list);
              }
              excePrintlList.add(request_map);
            }
            reportMenuService.engineryReportPdfPrintBatch(excePrintlList, request.getPdfPath(), request.getTargetPrinter());
          }
          // 常にAsposeを使用します
          int index = 0;
          try {
            for (int i = 0; i < excelReportList.size(); i++) {
              for (Long key : excelReportList.get(i).keySet()) {
                byte[] bytesList = excelReportList.get(i).get(key);
                String onePatientByteHtml = "";
                if (bytesList.length > 0) {
                  ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(bytesList);
                  URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
                  // Excel Convert To Svg
                  // mod #12445 差戻1 【因島】帳票に出力されない画像がある sunsy start
//                  onePatientByteHtml = AsposeCellsUtils.excelToSvg(byteArrayInputStream, url).replace("CLIP", "CLIP-" + index + "-");
                  onePatientByteHtml = AsposeCellsUtils.excelToSvg(byteArrayInputStream, url);
                  // mod #12445 差戻1 【因島】帳票に出力されない画像がある sunsy end
                  index++;
                }
                // 同じ患者に複数のデータがある場合、帳票htmlを加算する
                reportHtml += onePatientByteHtml;

              }
            }
          } catch (Exception e) {
            EventLogMessage eventLogMessage = new EventLogMessage();
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
            if (ntssUser != null && ntssUser.getFacilityCd() != null) {
              eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
            }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
            String funcCd = dataKey.get("functionCd") != null ? dataKey.get("functionCd").toString() : "";
            logService.log(LogLevel.ERROR, eventLogMessage, funcCd, SERVICE_NAME.FNSI, null);

            if (!StringUtils.isEmpty(request.getPdfPath())) {
              throw e;
            }
          }
        }
        else if (report.getReportClass().equals(ReportConstant.ReportClass.MULTIPLE_PATIENT_REPORT)) {
          // 帳票種別：03：複数患者帳票
          byte[] excelResult = reportService.getReportExcelFileForMultiPatient(reportCd, dataKey);
          // add #12107 帳票印刷失敗通知が行われない limingzhe start
          if (!StringUtils.isEmpty(request.getPdfPath())) {
            reportMenuService.engineryReportPdfPrint(excelResult, request.getPdfPath(), request.getTargetPrinter());
          }
          // add #12107 帳票印刷失敗通知が行われない limingzhe end
          try {
            if (!(excelResult == null || excelResult.length == 0)) {
              ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(excelResult);
              URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
              reportHtml = AsposeCellsUtils.excelToSvg(byteArrayInputStream, url);
              // del #12107 帳票印刷失敗通知が行われない limingzhe start
//              if (!StringUtils.isEmpty(request.getPdfPath())) {
//                reportMenuService.engineryReportPdfPrint(excelResult, request.getPdfPath(), request.getTargetPrinter());
//              }
              // del #12107 帳票印刷失敗通知が行われない limingzhe end
            }
          } catch (Exception e) {
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
            EventLogMessage eventLogMessage = new EventLogMessage();
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
            eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
            if (ntssUser != null && ntssUser.getFacilityCd() != null) {
              eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
            }
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
            String funcCd = dataKey.get("functionCd") != null ? dataKey.get("functionCd").toString() : "";
            logService.log(LogLevel.ERROR, eventLogMessage, funcCd, SERVICE_NAME.FNSI, null);

            throw e;
          }
        }
        else if (report.getReportClass().equals(ReportConstant.ReportClass.PREPARATION_LIST_REPORT)) {
          // 帳票種別：04：準備リスト
          byte[] excelResult = reportService.getReportExcelFileForPreparationList(reportCd, dataKey);
          // add #12107 帳票印刷失敗通知が行われない limingzhe start
          if (!StringUtils.isEmpty(request.getPdfPath())) {
            reportMenuService.engineryReportPdfPrint(excelResult, request.getPdfPath(), request.getTargetPrinter());
          }
          // add #12107 帳票印刷失敗通知が行われない limingzhe end
          try {
            if (!(excelResult == null || excelResult.length == 0)) {
              ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(excelResult);
              URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
              reportHtml = AsposeCellsUtils.excelToSvg(byteArrayInputStream, url);
              // del #12107 帳票印刷失敗通知が行われない limingzhe start
//              if (!StringUtils.isEmpty(request.getPdfPath())) {
//                reportMenuService.engineryReportPdfPrint(excelResult, request.getPdfPath(), request.getTargetPrinter());
//              }
              // del #12107 帳票印刷失敗通知が行われない limingzhe end
            }
          } catch (Exception e) {
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
            EventLogMessage eventLogMessage = new EventLogMessage();
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
            eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
            if (ntssUser != null && ntssUser.getFacilityCd() != null) {
              eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
            }
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
            String funcCd = dataKey.get("functionCd") != null ? dataKey.get("functionCd").toString() : "";
            logService.log(LogLevel.ERROR, eventLogMessage, funcCd, SERVICE_NAME.FNSI, null);

            throw e;
          }
        }
        else if (report.getReportClass().equals(ReportConstant.ReportClass.DISTRIBUTION_LIST_BED_REPORT)) {
          // 帳票種別：05:配布リスト(ベッド)
          // del #12107 帳票印刷失敗通知が行われない limingzhe start
//          byte[] excelBytes = reportService.getReportExcelFileForDistributionListBed(reportCd, dataKey);
//          if (!StringUtils.isEmpty(request.getPdfPath())) {
//            reportMenuService.engineryReportPdfPrint(excelBytes, request.getPdfPath(), request.getTargetPrinter());
//          }
//          reportHtml = reportMenuService.convertBtyesToHtml(excelBytes);
          // del #12107 帳票印刷失敗通知が行われない limingzhe end
          // mod #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe start
          //byte[] excelResult = reportService.getReportExcelFileForDistributionListBed(reportCd, dataKey);
          byte[] excelResult = reportForDistributionListService.getReportExcelFileForDistributionListBed(reportCd, dataKey);
          // mod #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe end
          // add #12107 帳票印刷失敗通知が行われない limingzhe start
          if (!StringUtils.isEmpty(request.getPdfPath())) {
            reportMenuService.engineryReportPdfPrint(excelResult, request.getPdfPath(), request.getTargetPrinter());
          }
          // add #12107 帳票印刷失敗通知が行われない limingzhe end
          try {
            if (!(excelResult == null || excelResult.length == 0)) {
              ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(excelResult);
              URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
              reportHtml = AsposeCellsUtils.excelToSvg(byteArrayInputStream, url);
              // del #12107 帳票印刷失敗通知が行われない limingzhe start
//              if (!StringUtils.isEmpty(request.getPdfPath())) {
//                reportMenuService.engineryReportPdfPrint(excelResult, request.getPdfPath(), request.getTargetPrinter());
//              }
              // del #12107 帳票印刷失敗通知が行われない limingzhe end
            }
          } catch (Exception e) {
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
            EventLogMessage eventLogMessage = new EventLogMessage();
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
            eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
            if (ntssUser != null && ntssUser.getFacilityCd() != null) {
              eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
            }
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
            String funcCd = dataKey.get("functionCd") != null ? dataKey.get("functionCd").toString() : "";
            logService.log(LogLevel.ERROR, eventLogMessage, funcCd, SERVICE_NAME.FNSI, null);

            throw e;
          }
        }
        else if (report.getReportClass().equals(ReportConstant.ReportClass.DISTRIBUTION_LIST_GOODS_REPORT)) {
          // 帳票種別：06:配布リスト（物品）
          // mod #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe start
          //byte[] excelResult = reportService.getReportExcelFileForDistributionListGoods(reportCd, dataKey);
          byte[] excelResult = reportForDistributionListService.getReportExcelFileForDistributionListGoods(reportCd, dataKey);
          // mod #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe end
          // add #12107 帳票印刷失敗通知が行われない limingzhe start
          if (!StringUtils.isEmpty(request.getPdfPath())) {
            reportMenuService.engineryReportPdfPrint(excelResult, request.getPdfPath(), request.getTargetPrinter());
          }
          // add #12107 帳票印刷失敗通知が行われない limingzhe end
          try {
            if (!(excelResult == null || excelResult.length == 0)) {
              ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(excelResult);
              URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
              reportHtml = AsposeCellsUtils.excelToSvg(byteArrayInputStream, url);
              // del #12107 帳票印刷失敗通知が行われない limingzhe start
//              if (!StringUtils.isEmpty(request.getPdfPath())) {
//                reportMenuService.engineryReportPdfPrint(excelResult, request.getPdfPath(), request.getTargetPrinter());
//              }
              // del #12107 帳票印刷失敗通知が行われない limingzhe end
            }
          } catch (Exception e) {
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
            EventLogMessage eventLogMessage = new EventLogMessage();
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
            eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
            if (ntssUser != null && ntssUser.getFacilityCd() != null) {
              eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
            }
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
            String funcCd = dataKey.get("functionCd") != null ? dataKey.get("functionCd").toString() : "";
            logService.log(LogLevel.ERROR, eventLogMessage, funcCd, SERVICE_NAME.FNSI, null);

            throw e;
          }
        }
        else if (report.getReportClass().equals(ReportConstant.ReportClass.LABEL_REPORT)) {
          // 帳票種別：08:ラベル
          // mod #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe start
          //byte[] excelResult = reportService.getReportExcelFileForLabelReport(reportCd, dataKey);
          byte[] excelResult = reportForLabelReportService.getReportExcelFileForLabelReport(reportCd, dataKey);
          // mod #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe end
          // add #12107 帳票印刷失敗通知が行われない limingzhe start
          if (!StringUtils.isEmpty(request.getPdfPath())) {
            reportMenuService.engineryReportPdfPrint(excelResult, request.getPdfPath(), request.getTargetPrinter());
          }
          // add #12107 帳票印刷失敗通知が行われない limingzhe end
          try {
            if (!(excelResult == null || excelResult.length == 0)) {
              ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(excelResult);
              URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
              reportHtml = AsposeCellsUtils.excelToSvg(byteArrayInputStream, url);
              // del #12107 帳票印刷失敗通知が行われない limingzhe start
//              if (!StringUtils.isEmpty(request.getPdfPath())) {
//                reportMenuService.engineryReportPdfPrint(excelResult, request.getPdfPath(), request.getTargetPrinter());
//              }
              // del #12107 帳票印刷失敗通知が行われない limingzhe end
            }
          } catch (Exception e) {
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
            EventLogMessage eventLogMessage = new EventLogMessage();
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
            eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
            if (ntssUser != null && ntssUser.getFacilityCd() != null) {
              eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
            }
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
            String funcCd = dataKey.get("functionCd") != null ? dataKey.get("functionCd").toString() : "";
            logService.log(LogLevel.ERROR, eventLogMessage, funcCd, SERVICE_NAME.FNSI, null);

            throw e;
          }
        }
        else if (report.getReportClass().equals(ReportConstant.ReportClass.INTRODUCTION_REPORT)) {
          // add #12324 紹介状の出力時にpat_eventを参照する zhao start
          List<PatEvent> patEventList = reportMenuService.getPatEvent(reportCd, dataKey);
          if(patEventList != null && patEventList.size() > 0){
            Map<String, List<Object>> ctlNoGroup = reportMenuService.getCtlNoGroup(patEventList);
            // 機能帳票から遷移場合、moveFlag = 1
            dataKey.put("moveFlag", "1");
            List<Map<Long, List<byte[]>>> excelReportList = new ArrayList<>();
            List<byte[]> reportList = new ArrayList<>();
            for (Map.Entry<String, List<Object>> entry : ctlNoGroup.entrySet()) {
              dataKey.put("ctlNo", entry.getKey());
              dataKey.put("letterDataList", entry.getValue());
              // 帳票種別：09:紹介状
              if (null != report.getReportType() && report.getReportType() == 1) {
                byte[] file = null;
                int indexNum = 0;
                String onePatientByteHtml = "";
                file = reportForTotalService.getReportExcelFileForIntroductionReport(reportCd, dataKey);
                if (!(file == null || file.length == 0)) {
                  ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(file);
                  URL url = null;
                  try {
                    url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
                    onePatientByteHtml = AsposeCellsUtils.excelToSvg(byteArrayInputStream, url);
                    indexNum++;

                    reportList.add(file);
                  } catch (IOException e) {
                    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang start
//      e.printStackTrace();
                    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang end
                    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 add yangxuewang start
                    EventLogMessage eventLogMessage = new EventLogMessage();
                    eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
                    logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
                    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 add yangxuewang end
                  } catch (Exception e) {
                    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang start
//      e.printStackTrace();
                    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang end
                    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 add yangxuewang start
                    EventLogMessage eventLogMessage = new EventLogMessage();
                    eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
                    logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
                    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 add yangxuewang end
                  }
                  reportHtml += onePatientByteHtml;
                }
              } else {
                byte[] excelResult = reportForIntroductionReportService.getReportExcelFileForIntroductionReport(reportCd, dataKey);
                reportList.add(excelResult);
                try {
                  if (!(excelResult == null || excelResult.length == 0)) {
                    ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(excelResult);
                    URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
                    reportHtml += AsposeCellsUtils.excelToSvg(byteArrayInputStream, url);
                  }
                } catch (Exception e) {
                  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang start
//      e.printStackTrace();
                  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang end
                  EventLogMessage eventLogMessage = new EventLogMessage();
                  eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
                  String funcCd = dataKey.get("functionCd") != null ? dataKey.get("functionCd").toString() : "";
                  logService.log(LogLevel.ERROR, eventLogMessage, funcCd, SERVICE_NAME.FNSI, null);
                  throw e;
                }
              }
            }
            if(reportList.size() > 0){
              Map<Long, List<byte[]>> reportMap = new HashMap<>();
              reportMap.put(Long.parseLong(String.valueOf(dataKey.get("patId"))), reportList);
              excelReportList.add(reportMap);
            }
            if (!StringUtils.isEmpty(request.getPdfPath())) {
              reportMenuService.engineryReportPdfPrintBatch(excelReportList, request.getPdfPath(), request.getTargetPrinter());
            }
          } else {
            dataKey.keySet().removeIf(key -> key.startsWith("moveFlag"));
            dataKey.keySet().removeIf(key -> key.startsWith("ctlNo"));
            dataKey.keySet().removeIf(key -> key.startsWith("letterDataList"));
            // add #12324 紹介状の出力時にpat_eventを参照する zhao end
            // 帳票種別：09:紹介状
            if (null != report.getReportType() && report.getReportType() == 1) {
              // del #12107 帳票印刷失敗通知が行われない limingzhe start
  //             try {
              // del #12107 帳票印刷失敗通知が行われない limingzhe end
              byte[] file = null;
              int indexNum = 0;
              String onePatientByteHtml = "";
              List<Map<Long, List<byte[]>>> excelReportList = new ArrayList<>();
              Map<Long, List<byte[]>> reportMap = new HashMap<>();
              List<byte[]> reportList = new ArrayList<>();
              // mod #10857 帳票内に同項目が複数あると設定値を取り違える limingzhe start
              //file = reportService.getReportExcelFileForIntroductionReport(reportCd, dataKey);
              // mod #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe start
              //file = reportForIntroductionReportService.getReportExcelFileForIntroductionReport(reportCd, dataKey);
              file = reportForTotalService.getReportExcelFileForIntroductionReport(reportCd, dataKey);
              // mod #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe end
              // mod #10857 帳票内に同項目が複数あると設定値を取り違える limingzhe end
              if (!(file == null || file.length == 0)) {
                ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(file);
                URL url = null;
                try {
                  url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
                  // mod #12445 差戻1 【因島】帳票に出力されない画像がある sunsy start
  //                onePatientByteHtml = AsposeCellsUtils.excelToSvg(byteArrayInputStream, url).replace("CLIP", "CLIP-" + indexNum + "-");
                  onePatientByteHtml = AsposeCellsUtils.excelToSvg(byteArrayInputStream, url);
                  // mod #12445 差戻1 【因島】帳票に出力されない画像がある sunsy end
                  indexNum++;

                  reportList.add(file);
                  reportMap.put(Long.parseLong(String.valueOf(dataKey.get("patId"))), reportList);
                  excelReportList.add(reportMap);
                } catch (IOException e) {
                  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
  //      e.printStackTrace();
                  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
                  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
                  EventLogMessage eventLogMessage = new EventLogMessage();
                  eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
                  if (!StringUtils.isEmpty(facilityCd)) {
                    eventLogMessage.setFacilityCd(facilityCd);
                  }
                  logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
                  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
                } catch (Exception e) {
                  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
  //      e.printStackTrace();
                  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
                  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
                  EventLogMessage eventLogMessage = new EventLogMessage();
                  eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
                  if (!StringUtils.isEmpty(facilityCd)) {
                    eventLogMessage.setFacilityCd(facilityCd);
                  }
                  logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
                  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
                }
                reportHtml += onePatientByteHtml;
              }
              if (!StringUtils.isEmpty(request.getPdfPath())) {
                reportMenuService.engineryReportPdfPrintBatch(excelReportList, request.getPdfPath(), request.getTargetPrinter());
              }
              // del #12107 帳票印刷失敗通知が行われない limingzhe start
  //            } catch (Exception e) {
  //              e.printStackTrace();
  //
  //              throw e;
  //            }
              // del #12107 帳票印刷失敗通知が行われない limingzhe end
            } else {
              // mod #10857 帳票内に同項目が複数あると設定値を取り違える limingzhe start
              //byte[] excelResult = reportService.getReportExcelFileForIntroductionReport(reportCd, dataKey);
              byte[] excelResult = reportForIntroductionReportService.getReportExcelFileForIntroductionReport(reportCd, dataKey);
              // mod #10857 帳票内に同項目が複数あると設定値を取り違える limingzhe end
              // add #12107 帳票印刷失敗通知が行われない limingzhe start
              if (!StringUtils.isEmpty(request.getPdfPath())) {
                reportMenuService.engineryReportPdfPrint(excelResult, request.getPdfPath(), request.getTargetPrinter());
              }
              // add #12107 帳票印刷失敗通知が行われない limingzhe end
              try {
                if (!(excelResult == null || excelResult.length == 0)) {
                  ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(excelResult);
                  URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
                  reportHtml = AsposeCellsUtils.excelToSvg(byteArrayInputStream, url);
                  // del #12107 帳票印刷失敗通知が行われない limingzhe start
  //                if (!StringUtils.isEmpty(request.getPdfPath())) {
  //                  reportMenuService.engineryReportPdfPrint(excelResult, request.getPdfPath(), request.getTargetPrinter());
  //                }
                  // del #12107 帳票印刷失敗通知が行われない limingzhe end
                }
              } catch (Exception e) {
                // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
  //      e.printStackTrace();
                // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
                EventLogMessage eventLogMessage = new EventLogMessage();
                // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
                eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
                if (ntssUser != null && ntssUser.getFacilityCd() != null) {
                  eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
                }
                // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
                String funcCd = dataKey.get("functionCd") != null ? dataKey.get("functionCd").toString() : "";
                logService.log(LogLevel.ERROR, eventLogMessage, funcCd, SERVICE_NAME.FNSI, null);

                throw e;
              }
            }
            // add #12324 紹介状の出力時にpat_eventを参照する zhao start
          }
          // add #12324 紹介状の出力時にpat_eventを参照する zhao end
        }
        else if (report.getReportClass().equals(ReportConstant.ReportClass.ONE_TOTAL_REPORT)) {
          // 帳票種別：10:単集計
          // mod #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe start
          // byte[] excelBytes = reportService.getReportExcelFileForOneTotal(reportCd, dataKey);
          byte[] excelBytes = reportForTotalService.getReportExcelFileForOneTotal(reportCd, dataKey);
          // mod #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe end
          if (!StringUtils.isEmpty(request.getPdfPath())) {
            reportMenuService.engineryReportPdfPrint(excelBytes, request.getPdfPath(), request.getTargetPrinter());
          }
          reportHtml += reportMenuService.convertBtyesToHtml(excelBytes);
        }
        else if (report.getReportClass().equals(ReportConstant.ReportClass.MULTI_TOTAL_REPORT)) {
          // 帳票種別：11:複数集計

          // del #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe start
//          List<Map<String, Object>> tmplParams = new ArrayList<Map<String, Object>>();
//          Map<String, Object> tmplParam = new HashMap<>();
//          // add #9558 機能帳票で正しく変数が引き渡されていない 高 start
//          tmplParam.put(ReportConstant.ReportDataKey.ORD_NOS, dataKey.get(ReportConstant.ReportDataKey.ORD_NOS));
//          // add #9558 機能帳票で正しく変数が引き渡されていない 高 end
//          tmplParam.put(ReportConstant.ReportDataKey.FACILITY_CD, dataKey.get(ReportConstant.ReportDataKey.FACILITY_CD));
//          tmplParam.put(ReportConstant.ReportDataKey.DATE, dataKey.get(ReportConstant.ReportDataKey.DATE));
//          tmplParam.put(ReportConstant.ReportDataKey.DATE_FROM, dataKey.get(ReportConstant.ReportDataKey.DATE_FROM));
//          tmplParam.put(ReportConstant.ReportDataKey.DATE_TO, dataKey.get(ReportConstant.ReportDataKey.DATE_TO));
//          tmplParam.put(ReportConstant.ReportDataKey.MACHINE_NOS, dataKey.get(ReportConstant.ReportDataKey.MACHINE_NOS));
//          tmplParam.put(ReportConstant.ReportDataKey.DIALYZER_IDS, dataKey.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
//          tmplParam.put(ReportConstant.ReportDataKey.MEDICINE_IDS, dataKey.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
//          tmplParam.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS, dataKey.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
//          // add #11973 日常点検一覧帳票が正常に出せない limingzhe start
//          tmplParam.put(ReportConstant.ReportDataKey.PAT_ID, dataKey.get(ReportConstant.ReportDataKey.PAT_ID));
//          tmplParam.put(ReportConstant.ReportDataKey.PAT_IDS, dataKey.get(ReportConstant.ReportDataKey.PAT_IDS));
//          tmplParam.put(ReportConstant.ReportDataKey.ORD_NO, dataKey.get(ReportConstant.ReportDataKey.ORD_NO));
//          tmplParam.put(ReportConstant.ReportDataKey.KUR_CDS, dataKey.get(ReportConstant.ReportDataKey.KUR_CDS));
//          tmplParam.put(ReportConstant.ReportDataKey.BED_CDS, dataKey.get(ReportConstant.ReportDataKey.BED_CDS));
//          // add #11973 日常点検一覧帳票が正常に出せない limingzhe end
//          tmplParams.add(tmplParam);
//          dataKey.put(ReportConstant.ReportDataKey.TEMPLATE_PARAMS, tmplParams);
          // del #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe end

          // mod 10546 複数集計出力時にページ数の制限 gjn start
//          byte[] excelBytes = reportForMultiTotalService.getReportExcelFileForMultiTotal(reportCd, dataKey);
//
//          if (!StringUtils.isEmpty(request.getPdfPath())) {
//            reportMenuService.engineryReportPdfPrint(excelBytes, request.getPdfPath(), request.getTargetPrinter());
//          }
//          reportHtml += reportMenuService.convertBtyesToHtml(excelBytes);
          // del #12107 帳票印刷失敗通知が行われない limingzhe start
//          try {
          // del #12107 帳票印刷失敗通知が行われない limingzhe end
            // mod #11973 日常点検一覧帳票が正常に出せない limingzhe start
            // byte[] excelBytes = reportForMultiTotalService.getReportExcelFileForMultiTotal(reportCd, dataKey);
            byte[] excelBytes = reportForTotalService.getReportExcelFileForMultiTotal(reportCd, dataKey);
            // mod #11973 日常点検一覧帳票が正常に出せない limingzhe end
            if (!StringUtils.isEmpty(request.getPdfPath())) {
              reportMenuService.engineryReportPdfPrint(excelBytes, request.getPdfPath(), request.getTargetPrinter());
            }
            reportHtml += reportMenuService.convertBtyesToHtml(excelBytes);
          // del #12107 帳票印刷失敗通知が行われない limingzhe start
//          } catch (NtssException e) {
//            return new ResponseEntity<>(e.getMessage(), HttpStatus.OK);
//          } catch (Exception exception) {
//            exception.printStackTrace();
//          }
          // del #12107 帳票印刷失敗通知が行われない limingzhe end
          // mod 10546 複数集計出力時にページ数の制限 gjn end
        }
        else {
          // 装置帳票
          // mod #11117 日常点検記録簿が1ページ1装置で出力される limingzhe start
          //byte[] excelBytes = reportService.getReportExcelFileForMachineReport(reportCd, dataKey);
          byte[] excelBytes = reportForMachineReportService.getReportExcelFileForMachineReport(reportCd, dataKey);
          // mod #11117 日常点検記録簿が1ページ1装置で出力される limingzhe end
          if (!StringUtils.isEmpty(request.getPdfPath())) {
            reportMenuService.engineryReportPdfPrint(excelBytes, request.getPdfPath(), request.getTargetPrinter());
          }
          reportHtml = reportMenuService.convertBtyesToHtml(excelBytes);
        }
      }

      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        reportCd);

      if (reportHtml != null) {
        if (reportHtml.contains("layout-flow:vertical-ideographic;")) {
          reportHtml = reportHtml.replaceAll("layout-flow:vertical-ideographic;", "writing-mode: vertical-rl;");
        }
      }
      // レスポンス生成
      return new ResponseEntity<>(new ReportHtmlResponse(reportHtml, dataKey), HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (!StringUtils.isEmpty(facilityCd)) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
      if (!StringUtils.isEmpty(request.getPdfPath())) {
        // mod #12107 帳票印刷失敗通知が行われない limingzhe start
        //printerService.saveNotiMessage(reportType, reportName, facilityCd);
        printerService.saveNotiMessage(reportClassName, reportName, facilityCd);
        if(!request.getIsPreview()){
          return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
        // mod #12107 帳票印刷失敗通知が行われない limingzhe end
      }
      // mod #12107 帳票印刷失敗通知が行われない limingzhe start
      //return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
      if(e.getMessage().indexOf("ExceedingMaxPageSetting") !=-1) {
        return new ResponseEntity<>(e.getMessage(), HttpStatus.OK);
      }
      if(e.getMessage().equals("テンプレートがない")) {
        return new ResponseEntity<>(e.getMessage(), HttpStatus.OK);
      }
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // mod #12107 帳票印刷失敗通知が行われない limingzhe end
    }
  }

  /**
   * 例外処理ハンドラー.
   * NotExistExceptionがthrowされた場合のみ処理
   *
   * @param e 例外クラス
   * @return 例外時のResponse
   */
  @ExceptionHandler(NotExistException.class)
  public ResponseEntity<?> handleNotExistException(final NotExistException e) {
    return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.BAD_REQUEST);
  }

  /**
   * 施設CDで全ての帳票の習得
   * @param facilityCd
   * @return List<MstReport>
   */
  @GetMapping("/getMstReportByFacilityCd/{facilityCd}")
  public ResponseEntity<List<MstReport>> getMstReportByFacilityCd(@PathVariable String facilityCd,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260512 start
    @AuthenticationPrincipal NtssUser ntssUser
    // #11205 -ペンテスト2－4認可制御の不備  add 20260512 end
) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260512 start
    if (!ntssUser.isNkkAdminUser() && facilityCd != null && !facilityCd.equals(ntssUser.getFacilityCd())) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260512 end


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.CREATING_REPORT + "/getMstReportByFacilityCd";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      null);
    // wp アプリケーションログの適正化 Add End

    try {
      List<MstReport> mstReports = reportService.getMstReportByFacilityCd(facilityCd);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(mstReports, HttpStatus.OK);
    } catch (Exception e) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, facilityCd, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  // add #12326 【因島】帳票マスタの「非表示」設定が意図せぬ動作をしている sunsy start
  /**
   * is_dispの表示/非表示と関係なく、施設CDにより帳票を取得
   * @param facilityCd
   * @return List<MstReport>
   */
  @GetMapping("/getMstReportByFacilityCdNoIsDisp/{facilityCd}")
  public ResponseEntity<List<MstReport>> getMstReportByFacilityCdNoIsDisp(@PathVariable String facilityCd,
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260512 start
    @AuthenticationPrincipal NtssUser ntssUser
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260512 end
) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260512 start
    if (!ntssUser.isNkkAdminUser() && facilityCd != null && !facilityCd.equals(ntssUser.getFacilityCd())) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260512 end


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.CREATING_REPORT + "/getMstReportByFacilityCdNoIsDisp";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      null);
    // wp アプリケーションログの適正化 Add End

    try {
      List<MstReport> mstReports = reportService.getMstReportByFacilityCdNoIsDisp(facilityCd);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(mstReports, HttpStatus.OK);
    } catch (Exception e) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, facilityCd, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  // add #12326 【因島】帳票マスタの「非表示」設定が意図せぬ動作をしている sunsy end
  /*add FNSI-改修内容転入時の紹介状取込ができない 任 start*/
  @PostMapping("/upload/{patEvent}")
  public ResponseEntity<?> uploadHtml(
    @RequestParam("file") MultipartFile file,
    @PathVariable("patEvent") String patEvent,
// #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    @AuthenticationPrincipal NtssUser ntssUser
// #11205 -ペンテスト2－4認可制御の不備  mod 20260421 end
) throws Exception {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
    try{
      if (!ntssUser.isNkkAdminUser()) {
        String[] split = patEvent.split("&");
        String facilityCo = split[0];
        if (facilityCo != null && !facilityCo.equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCo + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        }
      }
    } catch (Exception e) {
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 end


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.CREATING_REPORT + "/upload";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    Map<String, String> resp = new HashMap<String, String>();
    resp.put("htmlTemplate",printerService.uploadHtml(file, patEvent));

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(resp, HttpStatus.OK);
  }
  /*add FNSI-改修内容転入時の紹介状取込ができない 任 end*/
  //add オンプレミスの場合、転入患者さんの紹介状が取込できない 吉 start
  @RequestMapping(value = "/getPdf", method = {RequestMethod.GET, RequestMethod.POST})
  public void getPdf(String pdfUrl, HttpServletRequest req, HttpServletResponse resp, @AuthenticationPrincipal NtssUser ntssUser)  throws Exception{

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.CREATING_REPORT + "/getPdf";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      pdfUrl);
    // wp アプリケーションログの適正化 Add End
    Map<String, String> mapResult = printerService.getLocalStoreAndStatus();
    if (pdfUrl == null) {
      pdfUrl = "";
    }
    resp.setContentType("application/pdf");
    OutputStream sos = null;
    BufferedInputStream bis = null;
    String destUrl = "";
    try {
      sos = resp.getOutputStream();
      String s3BucketInFcd = String.format(s3Bucket, ntssUser.getFacilityCd());
      if(mapResult.get("status").equals("off")){
        // S3にから紹介状を取得
        destUrl = printerService.getCacheFilePath(s3BucketInFcd, pdfUrl);
      } else {
        // オンプレミスON(S3を使わない)
        destUrl = mapResult.get("localStore") + "/" +  s3BucketInFcd + "/" + pdfUrl;
      }
      InputStream in = new FileInputStream(destUrl);
      bis = new BufferedInputStream(in);
      int b;
      while ((b = bis.read()) != -1) {
        sos.write(b);
      }
    } catch (IOException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessageNew = new EventLogMessage();
      eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    } finally {
      try {
        sos.close();
      } catch (IOException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
        EventLogMessage eventLogMessageNew = new EventLogMessage();
        eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      }
      try {
        bis.close();
      } catch (IOException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
        EventLogMessage eventLogMessageNew = new EventLogMessage();
        eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      }
    }
  }
  //add オンプレミスの場合、転入患者さんの紹介状が取込できない 吉 end

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

  // add #9347 治療方法マスタに紐づけられているレポートレイアウトが削除されていると帳票作成に失敗する jiang start
  private void outputErrorLog(String facilityCd, String message) {
    outputLog(LogLevel.ERROR, facilityCd, message);
  }
  private void outputLog(LogLevel level, String facilityCd, String message) {
    EventLogMessage elm = new EventLogMessage();
    elm.setFacilityCd(facilityCd);
    elm.setLogMessage(message);
    elm.setInvokeClass(this.getClass().getName());
    logService.log(level, elm, null, SERVICE_NAME.FNSI, null);
  }
  // #9347 治療方法マスタに紐づけられているレポートレイアウトが削除されていると帳票作成に失敗する jiang end
  // add #12650 登録済み紹介状が帳票マスタ削除の影響を受けるのは不適切 zhao start
  /**
   * is_dispの表示/非表示と関係なく、施設CDにより帳票を取得
   * @param facilityCd
   * @return List<MstReport>
  */
  @GetMapping("/getMstReportByFacilityCdNoIsDel/{facilityCd}")
  public ResponseEntity<List<MstReport>> getMstReportByFacilityCdNoIsDel(@PathVariable String facilityCd,
                                                                         @RequestParam(required = false) Long selectedPatId,
    @AuthenticationPrincipal NtssUser ntssUser) {
    if (!facilityAccessService.hasFacilityOrSelectedPatShareAccess(ntssUser, facilityCd, selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }



    String mappingUrl = Uri.CREATING_REPORT + "/getMstReportByFacilityCdNoIsDel";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO,
      mappingUrl, facilityCd,
      null);

    try {
      List<MstReport> mstReports = reportService.getMstReportByFacilityCdNoIsDel(facilityCd);

      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO,
        mappingUrl, facilityCd,
        null);
      return new ResponseEntity<>(mstReports, HttpStatus.OK);
    } catch (Exception e) {

      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR,
        mappingUrl, facilityCd, e.getMessage());
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  // add #12650 登録済み紹介状が帳票マスタ削除の影響を受けるのは不適切 zhao end
}
