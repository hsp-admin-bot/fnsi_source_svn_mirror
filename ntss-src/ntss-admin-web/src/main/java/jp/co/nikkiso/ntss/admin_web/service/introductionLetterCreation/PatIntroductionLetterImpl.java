package jp.co.nikkiso.ntss.admin_web.service.introductionLetterCreation;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStreamReader;
import java.net.URL;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

import tools.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.reportMenu.ReportMenuDataKeyService;
import jp.co.nikkiso.ntss.api.constant.ReportConstant;
import jp.co.nikkiso.ntss.api.domain.report.ReportXmlParam;
import jp.co.nikkiso.ntss.api.service.report.ReportForOnePatientService;
import jp.co.nikkiso.ntss.api.service.report.ReportForLabelReportService;
import jp.co.nikkiso.ntss.api.service.report.ReportForIntroductionReportService;
import jp.co.nikkiso.ntss.api.service.report.ReportForTotalService;
import jp.co.nikkiso.ntss.api.service.report.ReportS3Service;
import jp.co.nikkiso.ntss.api.service.report.ReportService;
import jp.co.nikkiso.ntss.api.service.utils.AsposeCellsUtils;
import jp.co.nikkiso.ntss.api.service.utils.ReportUtils;
import jp.co.nikkiso.ntss.api.service.utils.ReportZipFile;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstReportDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.OrdPrescriptionDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.ReportMenuDao;
import jp.co.nikkiso.ntss.core.dao.ShrPatInfoDao;
import jp.co.nikkiso.ntss.core.entity.MstReport;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.OrdPrescription;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.ShrPatInfo;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import jp.co.nikkiso.ntss.core.entity.custom.ReportMenuSortContainer;

import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.json.JSONArray;
import org.json.JSONObject;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ResourceLoader;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import jp.co.nikkiso.ntss.admin_web.service.print.PrinterService;
import jp.co.nikkiso.ntss.api.service.onPremise.OnPremiseService;
import jp.co.nikkiso.ntss.api.service.utils.TmpFileService;
import jp.co.nikkiso.ntss.admin_web.service.reportMenu.ReportMenuService;
import org.springframework.util.StringUtils;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;


@Service
public class PatIntroductionLetterImpl implements PatIntroductionLetterService {

  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
  @Autowired
  private LogService logService;
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end

	@Value("${ntss.report.printTmpDir}")
	private String printTmpDir;

	@Value("${ntss.report.createTmpDir}")
	private String createTmpDir;

	@Autowired
	private PrinterService printerService;

	@Autowired
	private ReportMenuService reportMenuService;

  // add #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
  @Autowired
  ReportMenuDataKeyService reportMenuDataKeyService;
  // add #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end

	@Autowired
    private OnPremiseService onPremiseService;

	@Autowired
    private TmpFileService tmpFileService;

  @Autowired
  private PatPersonalMainDao patPersonalMainDao;

  /* add by gaojuncheng  2023-02-01 [CodeOptimization]  start */
  @Autowired
  private ReportService reportService;

  // add #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
  @Autowired
  private ReportForOnePatientService reportForOnePatientService;
  // add #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end

  // add #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe start
  @Autowired
  private ReportForLabelReportService reportForLabelReportService;
  // add #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe end

  // add #10857 帳票内に同項目が複数あると設定値を取り違える limingzhe start
  @Autowired
  ReportForIntroductionReportService reportForIntroductionReportService;
  // add #10857 帳票内に同項目が複数あると設定値を取り違える limingzhe end

  // add #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe start
  @Autowired
  ReportForTotalService reportForTotalService;
  // add #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe end

  @Autowired
  private OrdMainDao ordMainDao;

  @Autowired
  private MstFacilitySettingDao mstFacilitySettingDao;

  @Autowired
  private MstReportDao mstReportDao;

  @Autowired
  private ReportMenuDao reportMenuDao;

  @Autowired
  ResourceLoader resourceLoader;

  @Autowired
  LogEventUtils logEventUtils;

  @Autowired
  private ObjectMapper objectMapper;

  @Autowired
  private ReportS3Service reportS3Service;
  /* add by gaojuncheng  2023-02-01 [CodeOptimization]  end */
  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;

  // add #10526 クラス「処方情報」の「保険者番号」等に一桁づつ出力するデータセットを追加 sunsy start
  @Autowired
  private OrdPrescriptionDao ordPrescriptionDao;
  // add #10526 クラス「処方情報」の「保険者番号」等に一桁づつ出力するデータセットを追加 sunsy end

  // add #12462 患者情報共有 zhao start
  @Autowired
  private ShrPatInfoDao shrPatInfoDao;
  // add #12462 患者情報共有 zhao end
	/**
	 *
	 * {@inheritDoc}
	 */
	@Transactional
	@Override
	public int updatePatientInfo(Long patId, PatPersonalMain pat) throws Exception {
		SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
		Timestamp nowTimestamp = new java.sql.Timestamp(System.currentTimeMillis());
		String strDate = sdf.format(nowTimestamp);
		pat.setUp_date(strDate);

    // DB更新ログ出力ロジック wangzuo Start
    pat.setPat_id(patId);
    // DB更新ログ出力ロジック wangzuo End

    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(pat,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
		return patPersonalMainDao.updateByIdFromIntroductionLetter(patId, pat);
	}
	/**
	 *
	 * {@inheritDoc}
	 */
	@Override
	public void printReport(String introductionHtml, String reportName, MstReport mstReport, Long patId)
			throws Exception {
		Path htmlPath = null;
		Path pdfPath = null;
		try {
			if (introductionHtml.equals("")) {
				return;
			}
			if (!StringUtils.isEmpty(mstReport)) {
				String html = introductionHtml;
				// HTMLデータを一時ファイルに保存
				htmlPath = tmpFileService.createTmpDirectoryAndFile(createTmpDir, "nkk-introduction-letter", ".html");
				Files.write(htmlPath, html.getBytes(StandardCharsets.UTF_8));

				// 生成するPDFの一時ファイルを生成
				pdfPath = tmpFileService.createTmpDirectoryAndFile(createTmpDir, "nkk-introduction-letter", ".pdf");
				String[] command = { "wkhtmltopdf", htmlPath.toString(), pdfPath.toString() };

				Runtime rt = Runtime.getRuntime();
				int runCmd = rt.exec(command).waitFor();
				if (runCmd == 0) {
					String fileName = reportMenuService.getFileNameByPatId(patId, "IntroductionLetter");
          // mod 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 start
          // mod 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 start
          String destFilePath = "pdf/" + fileName;
					// String destFilePath = "pdf" + File.separator + fileName;
          // mod 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 end
          // mod 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 end
					// 印刷用一時ファイルはローカルに保存する
					onPremiseService.putFile(printTmpDir, destFilePath, pdfPath);
					printerService.sendPrintRequest(mstReport.getDefaultPrinter(), destFilePath);
				} else {
					return;
				}
			}
		} finally {
			// 一時ファイルを削除
			Optional.ofNullable(htmlPath).ifPresent(path -> path.toFile().delete());
			Optional.ofNullable(pdfPath).ifPresent(path -> path.toFile().delete());
		}
	}

  /* add by gaojuncheng  2023-02-01 [CodeOptimization]  start */
	@Override
  // mod 9795 紹介状画面の画面表示を帳票のプログラムに準拠させる　吉 start
  // public Map<String, Object> getIntroLetterTemplate(MstReport mstReport, Long patId, Long reportCd, NtssUser ntssUser){
  // mod 11488 紹介状登録内容保存時に帳票の版も記憶する　1.1A  吉 start
//  public Map<String, Object> getIntroLetterTemplate(MstReport mstReport, Long patId, Long reportCd, NtssUser ntssUser)  throws Exception{
  // mod #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao start
  // public Map<String, Object> getIntroLetterTemplate(MstReport mstReport, Long patId, Long reportCd, NtssUser ntssUser,String ctlNo,String isUpdate)  throws Exception{
  public Map<String, Object> getIntroLetterTemplate(MstReport mstReport, Long patId, Long reportCd, NtssUser ntssUser, String ctlNo, String isUpdate, String reportStartDate)  throws Exception{
  // mod #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao end
    // mod 11488 紹介状登録内容保存時に帳票の版も記憶する　1.1A  吉 end
  // mod 9795 紹介状画面の画面表示を帳票のプログラムに準拠させる　吉 end
    // mod #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao start
				//Optional<OrdMain> ordMain = ordMainDao.selectItemByPatId(patId);
        Optional<OrdMain> ordMain = Optional.empty();
        if(!StringUtils.isEmpty(reportStartDate) && !"undefined".equals(reportStartDate)){
          // mod #12462 患者情報共有 zhao start
          //ordMain = ordMainDao.selectItemByPatId(patId, reportStartDate.replace("-", "").replace("/", ""));
          ordMain = ordMainDao.selectItemByPatId(mstReport.getFacilityCd(), patId, reportStartDate.replace("-", "").replace("/", ""));
          // mod #12462 患者情報共有 zhao end
        } else {
          // mod #12462 患者情報共有 zhao start
          //ordMain = ordMainDao.selectItemByPatId(patId,null);
          ordMain = ordMainDao.selectItemByPatId(mstReport.getFacilityCd(), patId,null);
          // mod #12462 患者情報共有 zhao end
        }
    // mod #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao end
				Map<String, Object> dataKey = new HashMap<>();

				// mod #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe start
//				if (ordMain.isPresent()) {
//					dataKey.put("ordNo", Math.toIntExact(ordMain.get().getOrdNo()));
//				} else {
//					dataKey.put("ordNo", 0);
//				}
        if (ordMain.isPresent()) {
          dataKey.put("ordNo", ordMain.get().getOrdNo());
        } else {
          dataKey.put("ordNo", 0l);
        }
        // mod #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe end
//        add 紹介状に指示内容が表示されない 6371  関 start
        Date date = new Date();
        String today = new SimpleDateFormat("yyyyMMdd").format(date);
//        mod 7939 7163 紹介状に患者情報が表示されない 関 start
//        dataKey.put("date", today);
        dataKey.put("fromDate", today);
//        mod 7939 7163 紹介状に患者情報が表示されない 関 end
//        add 紹介状に指示内容が表示されない 6371  関 end
				dataKey.put("patId", patId);
        //mod #11775 【因島】印刷情報.共通情報.ログイン者が紹介状画面ではスタッフIDになる sunsy start
//				dataKey.put("login", ntssUser.getUsername());
        String name = mstPersonalUserDao.selectUserNameById(ntssUser.getUserId());
        dataKey.put("login", name);
        //mod #11775 【因島】印刷情報.共通情報.ログイン者が紹介状画面ではスタッフIDになる sunsy start
    // add 7939 紹介状に患者情報が表示されない 吉 start
        dataKey.put("date", today);
    // add #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao start
        if(!StringUtils.isEmpty(reportStartDate) && !"undefined".equals(reportStartDate)){
          String formattedDate = reportStartDate.replace("-", "").replace("/", "");
          dataKey.put("fromDate", formattedDate);
          dataKey.put("date", formattedDate);
        }
    // add #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao end
    // mod #12462 患者情報共有 zhao start
        //dataKey.put("facilityCd", ntssUser.getFacilityCd());
        dataKey.put("facilityCd", mstReport.getFacilityCd());
    // mod #12462 患者情報共有 zhao end
        // add 7939 紹介状に患者情報が表示されない 吉 end

        // del #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
//        // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
//        Map<String, List> searchList =this.searchMap(ntssUser.getFacilityCd());
//        dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS,searchList.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
//        dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS,searchList.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
//        dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,searchList.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
//        // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
        // del #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end
        // add 8417 【帳票】【紹介状（集計）】①薬剤の表示が不正　②患者情報の表示のずれが発生　③空白画面の出力問題  吉 start
        dataKey.put("reportClass",mstReport.getReportClass());
        // mod 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 start
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
        Date dt = sdf.parse(dataKey.get("fromDate").toString());
        Calendar rightNow = Calendar.getInstance();
        rightNow.setTime(dt);
        rightNow.add(Calendar.MONTH, 1);
        Date dt1 = rightNow.getTime();
        String reStr = sdf.format(dt1);
        dataKey.put(ReportConstant.ReportDataKey.DATE_TO, reStr);
        // add #10857 帳票内に同項目が複数あると設定値を取り違える 高　start
        dataKey.put("newPageCountFlag",false);
        // add #10857 帳票内に同項目が複数あると設定値を取り違える 高　end
        //    dataKey.put(ReportConstant.ReportDataKey.DATE_TO, today);
        // mod 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 end
        // add 8417 【帳票】【紹介状（集計）】①薬剤の表示が不正　②患者情報の表示のずれが発生　③空白画面の出力問題  吉 end

        // add #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
        dataKey.putAll(reportMenuDataKeyService.searchReportSettingForDataKey(String.valueOf(dataKey.getOrDefault(ReportConstant.ReportDataKey.FACILITY_CD, "")), reportCd, dataKey));
        // add #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end

        // mod 9795 紹介状画面の画面表示を帳票のプログラムに準拠させる　吉 start
        //　String html = reportService.getIntroLetterReportHtml(reportCd, dataKey, null, null);
        String html = "";
        // mod #10857 帳票内に同項目が複数あると設定値を取り違える limingzhe start
        //byte[] file  = reportService.getReportExcelFileForIntroductionReport(reportCd, dataKey);
        // add 11488 紹介状登録内容保存時に帳票の版も記憶する　1.1A  吉 start
        dataKey.put("ctlNo",ctlNo);
        dataKey.put("isUpdate",isUpdate);
        // add 11488 紹介状登録内容保存時に帳票の版も記憶する　1.1A  吉 end
        // add #10526 クラス「処方情報」の「保険者番号」等に一桁づつ出力するデータセットを追加 sunsy start
        // del #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
//        List<String> prescriptionClassList = new ArrayList<String>(Arrays.asList("1", "2"));
//        dataKey.put("prescriptionClassList", prescriptionClassList);
        // del #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end
        // mod #10526 クラス「処方情報」の「保険者番号」等に一桁づつ出力するデータセットを追加 20260528 sunsy start
        if (!StringUtils.isEmpty(dataKey.get("patId"))) {
          List<OrdPrescription> ordPrescriptionList = ordPrescriptionDao.selectResultByPatIdAndDateFromTo(
            Long.parseLong(String.valueOf(dataKey.get("patId")))
            // mod #12462 患者情報共有 zhao start
            //, ntssUser.getFacilityCd()
            , mstReport.getFacilityCd()
            // mod #12462 患者情報共有 zhao end
            , dataKey.get("fromDate").toString().replace("/", "").replace("-", "")
            , dataKey.get("toDate").toString().replace("/", "").replace("-", "")
            // mod #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
            //, prescriptionClassList
            , (List<String>)dataKey.get("prescriptionClassList")
            // mod #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end
          );
          List<Long> ordPrescriptionNos = new ArrayList<>();
          for (OrdPrescription rx : ordPrescriptionList) {
            ordPrescriptionNos.add(rx.getOrdPrescriptionNo());
          }
          dataKey.put(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NOS, ordPrescriptionNos);
        }
        // mod #10526 クラス「処方情報」の「保険者番号」等に一桁づつ出力するデータセットを追加 20260528 sunsy end
        // add #10526 クラス「処方情報」の「保険者番号」等に一桁づつ出力するデータセットを追加 sunsy end
        // mod #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe start
        //byte[] file  = reportForIntroductionReportService.getReportExcelFileForIntroductionReport(reportCd, dataKey);
        byte[] file = null;
        if(mstReport.getReportClass() == ReportConstant.ReportClass.INTRODUCTION_REPORT && mstReport.getReportType() == 1){
          file = reportForTotalService.getReportExcelFileForIntroductionReport(reportCd, dataKey);
        }
        else {
          file = reportForIntroductionReportService.getReportExcelFileForIntroductionReport(reportCd, dataKey);
        }
        // mod #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe end
        // mod #10857 帳票内に同項目が複数あると設定値を取り違える limingzhe end

        if (file.length > 0) {
          ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(file);
          URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
          html = AsposeCellsUtils.excelToHtml(byteArrayInputStream,url);
        }
        if(!"".equals(html)){
          byte[] zipFile = reportS3Service.getReportFile(mstReport.getReportPath().getBucket(),
            mstReport.getReportPath().getReportZip(), null);
          ReportZipFile reportZipFile = new ReportZipFile(zipFile);
          String reportXml = reportZipFile.getFileToString(mstReport.getReportPath().getXmlFilename());
          reportXml = reportXml.trim().replaceFirst("^([\\W]+)<", "<");
          List<ReportXmlParam> params = ReportUtils.getParamElements(reportXml);
          // del #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe start
//          // add 10381 紹介状の表示に時間がかかる 吉 start
//          StringBuilder cellKey = new StringBuilder();
//          // add 10381 紹介状の表示に時間がかかる 吉 end
//          for (ReportXmlParam key1 : params) {
//            if(null != key1.getGroupId() && !"".equals(key1.getGroupId())){
//              String[] cells=key1.getRepeatAddress().split(",");
//              if(null != cells && cells.length>0){
//                for(String cell : cells){
//                  if(html.contains(cell) && key1.getDataType() != "byte[]"){
//                    // mod 10381 紹介状の表示に時間がかかる 吉 start
////                    html = html.replaceAll("excelCoordinate='"+cell+"'","id='"+cell+"'");
//                    cellKey.append(cell + "|");
//                    // mod 10381 紹介状の表示に時間がかかる 吉 end
//                  }
                  // del 10381 紹介状の表示に時間がかかる 吉 start
//                  if(html.contains("td\n")){
//                    html = html.replaceAll("td\n","#content-html td\n");
//                  }
                  // del 10381 紹介状の表示に時間がかかる 吉 end
//                }
//              }
//            }else{
//              if(html.contains(key1.getId()) && !key1.getDataType().equals("byte[]")){
//                // mod 10381 紹介状の表示に時間がかかる 吉 start
////                html = html.replaceAll("excelCoordinate='"+key1.getId()+"'","id='"+key1.getId()+"'");
//                cellKey.append( key1.getId() + "|");
//                // mod 10381 紹介状の表示に時間がかかる 吉 end
//              }
              // del 10381 紹介状の表示に時間がかかる 吉 start
//              if(html.contains("td\n")){
//                html = html.replaceAll("td\n","#content-html td\n");
//              }
              // del 10381 紹介状の表示に時間がかかる 吉 end
//            }
//          }
          // add 10381 紹介状の表示に時間がかかる 吉 start
          // mod #11394 紹介状のフリー入力の拡張 高　start
//          if(!cellKey.isEmpty()){
//             String pattern = cellKey.substring(0,cellKey.length() -1);
//             pattern="excelCoordinate='("+ pattern +")'";
//             html = html.replaceAll(pattern,"id='$1'");
//          }
          // String pattern = "excelCoordinate=";
          // html = html.replaceAll(pattern,"id=");
          // del #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe end
          // mod #11394 紹介状のフリー入力の拡張 高　end
          if(html.contains("td\n")){
            html = html.replaceAll("td\n","#content-html td\n");
          }
          // add 10381 紹介状の表示に時間がかかる 吉 end
          html= html.replaceAll("margin-left:-10px","");
          // add 10499 紹介状画面でセルの縦配置設定が反映しない 吉 start
          html= html.replaceAll("vertical-align:middle;","");
          // add 10499 紹介状画面でセルの縦配置設定が反映しない 吉 end
          // add #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe start
          String pattern = "excelCoordinate=";
          BufferedReader br = new BufferedReader(new InputStreamReader(new ByteArrayInputStream(html.getBytes(Charset.forName("utf8"))), Charset.forName("utf8")));
          String line;
          List<String> paramIsShrinkList = new ArrayList<>();
          List<String> paramIsImageList = new ArrayList<>();
          List<String> paramAlignRList = new ArrayList<>();
          for (ReportXmlParam key1 : params) {
            if(key1.getIsShrink().equals("1")){
              if(null != key1.getGroupId() && !"".equals(key1.getGroupId())) {
                String[] cells = key1.getRepeatAddress().split(",");
                if (null != cells && cells.length > 0) {
                  for (String cell : cells) {
                    if(html.contains(cell))
                      paramIsShrinkList.add(pattern + "'" + cell + "'");
                  }
                }
              }else{
                if(html.contains(key1.getId()))
                  paramIsShrinkList.add(pattern + "'" + key1.getId() + "'");
              }
            }
            if(key1.getDataType().equals(ReportXmlParam.DATA_TYPE_DATE_TIME) || (key1.getDataType().equals(ReportXmlParam.DATA_TYPE_DECIMAL) && !key1.isFormulaToCalc())){
              if(null != key1.getGroupId() && !"".equals(key1.getGroupId())) {
                String[] cells = key1.getRepeatAddress().split(",");
                if (null != cells && cells.length > 0) {
                  for (String cell : cells) {
                    if(html.contains(cell))
                      paramAlignRList.add(pattern + "'" + cell + "'");
                  }
                }
              }else{
                if(html.contains(key1.getId()))
                  paramAlignRList.add(pattern + "'" + key1.getId() + "'");
              }
            }
            if(key1.getIsImage().equals("true")){
              if(null != key1.getGroupId() && !"".equals(key1.getGroupId())) {
                String[] cells = key1.getRepeatAddress().split(",");
                if (null != cells && cells.length > 0) {
                  for (String cell : cells) {
                    if(html.contains(cell))
                      paramIsImageList.add(pattern + "'" + cell + "'");
                  }
                }
              }else{
                if(html.contains(key1.getId()))
                  paramIsImageList.add(pattern + "'" + key1.getId() + "'");
              }
            }
          }
          StringBuffer strbuf = new StringBuffer();
          while ( (line = br.readLine()) != null ) {
            String strSign = "";
            for(String addr : paramIsShrinkList){
              if(line.contains(addr)){
                strSign = addr;
              }
            }
            if(strSign.length() > 0){
              line=line.replace(strSign, strSign + " isshrink='1'");
            }
            String strAlign = "";
            for(String addr : paramAlignRList){
              if(line.contains(addr)){
                strAlign = addr;
              }
            }
            if(strAlign.length() > 0){
              line=line.replace(strAlign, strAlign + " isalignr='1'");
            }
            String strSignIsImage = "";
            for(String addr : paramIsImageList){
              if(line.contains(addr)){
                strSignIsImage = addr;
              }
            }
            if(strSignIsImage.length() > 0){
              line=line.replace(strSignIsImage, strSignIsImage + " isimage='1'");
            }
            strbuf.append(line+System.lineSeparator());
          }
          html = strbuf.toString();
          // add #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe end
        }
        // mod 9795 紹介状画面の画面表示を帳票のプログラムに準拠させる　吉 end
        // add #11403 【たくしん会】iPad（safari）で紹介状画面を表示すると帳票の非表示列が見えてしまう　V1.0B　ー  吉 start
        if(null != html){
          BufferedReader br = new BufferedReader(new InputStreamReader(new ByteArrayInputStream(html.getBytes(Charset.forName("utf8"))), Charset.forName("utf8")));
          String line;
          String regex = "id='t\\d+";
          String searchChar1 = "overflow:hidden";
          Pattern pattern = Pattern.compile(regex);
          StringBuffer strbuf=new StringBuffer();
          while ( (line = br.readLine()) != null ) {
            Matcher matcher = pattern.matcher(line);
            if(matcher.find() && line.contains(searchChar1)){
              line=line.replace("overflow:hidden;","overflow:hidden;visibility: hidden;width: 0;");
              strbuf.append(line+System.lineSeparator());
            }else{
              strbuf.append(line+System.lineSeparator());
            }
          }
          html = strbuf.toString();
        }
        // add #11403【たくしん会】iPad（safari）で紹介状画面を表示すると帳票の非表示列が見えてしまう　V1.0B　ー  吉 end
				Map<String, Object> responseData = new HashMap<String, Object>();
				responseData.put("htmlTemplate", html.toString());

				return responseData;
  }

  @Override
  public ResponseEntity<?> printReport(Map<String, Object> payload, NtssUser ntssUser, String mappingUrl) {
    //add  Aspose.cells plug-in integration  吉 start
    // del 9316 施設設定マスタ125番の削除について　吉 start
//    FacilitySettingInfo settingValue = mstFacilitySettingDao.getBySettingNoAndCd(ntssUser.getFacilityCd(), CoreConstant.FacilitySettingNo.PREVIEW_MODE);
//    if(settingValue != null && settingValue.getValue().equals("0")){
      // del 9316 施設設定マスタ125番の削除について　吉 end
      // new
      Map<String, String> outPutHtml = new HashMap<>();
      org.jsoup.nodes.Document document = Jsoup.parse(String.valueOf(payload.get("htmlTemplate").toString()));
      Elements links = document.getElementsByTag("tbody").first().getElementsByTag("td");
      for (Element link : links) {
        // mod #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe start
        //String linkHref = link.attr("id");
        String linkHref = link.attr("excelCoordinate");
        String linkText = link.text();
        String result = link.html();
        if(result.contains("<br>")){
          result = result.replaceAll("(?i)<(?!br\\s*/?>).*?>", "").replaceAll("&nbsp;", "\u00A0");
          linkText = result.replaceAll("(?i)<br\\s*/?>", System.lineSeparator());
        }
        // mod #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe end
        if(!linkHref.isEmpty()){
          // mod #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe start
          // outPutHtml.put(linkHref,linkText);
          if(link.select("img").size()>0){
            for (Element img : link.select("img")) {
              String src = img.attr("src");
              if(src.contains("base64,")){
                outPutHtml.put(linkHref,src.split("base64,")[1]);
              }else{
                outPutHtml.put(linkHref,src);
              }
            }
          }else{
            if(!outPutHtml.containsKey(linkHref)){
              outPutHtml.put(linkHref,linkText);
            }
          }
          // mod #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe end
        }
      }
      Long reportCd = Long.parseLong(payload.get("reportCd").toString());
      // mod #12650 登録済み紹介状が帳票マスタ削除の影響を受けるのは不適切 zhao start
      //MstReport mstReport = mstReportDao.selectByCd(reportCd);
      MstReport mstReport = mstReportDao.selectByReportCd(reportCd);
      // mod #12650 登録済み紹介状が帳票マスタ削除の影響を受けるのは不適切 zhao end
      // add #9616 帳票印刷失敗通知がされない 高　start
      String reportName = mstReport.getReportName();
      String facilityCd = mstReport.getFacilityCd();
    // add #9616 帳票印刷失敗通知がされない 高　end
      ReportMenuSortContainer dakeMap = new ReportMenuSortContainer();
      Map<String, Object> dataKey =  new HashMap<>();
      dataKey.put("IntroLetterReportPrinte",true);
      dataKey.put("htmlTemplate",outPutHtml);
      SimpleDateFormat sdf  = new SimpleDateFormat("yyyyMMdd");
      //add  Aspose.cells plug-in integration  吉 start
      // del #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
//      Map<String,List> searchList =this.searchMap(ntssUser.getFacilityCd());
      // del #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end
      dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD,ntssUser.getFacilityCd());
      // del #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
//      dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,searchList.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
//      dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS,searchList.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
//      dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS,searchList.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
      // del #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end
      dataKey.put(ReportConstant.ReportDataKey.PAT_ID,Long.valueOf(payload.get("patId").toString()));
      LocalDate nowDate = LocalDate.now();
      dataKey.put(ReportConstant.ReportDataKey.DATE_FROM,nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
      dataKey.put(ReportConstant.ReportDataKey.DATE_TO,nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
      dataKey.put(ReportConstant.ReportDataKey.treatDate,nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
      // mod 9608 紹介状印刷時に同時に出力される透析レポートについて　吉 start
      // dataKey.put(ReportConstant.ReportDataKey.treatDate,reportCd);
      dataKey.put(ReportConstant.ReportDataKey.DATE,nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
      // mod 9608 紹介状印刷時に同時に出力される透析レポートについて　吉 end
      // add #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao start
//      Optional<OrdMain> ordMain = ordMainDao.selectItemByPatId(Long.valueOf(payload.get("patId").toString()));
      // mod #12462 患者情報共有 zhao start
      //Optional<OrdMain> ordMain = ordMainDao.selectItemByPatId(Long.valueOf(payload.get("patId").toString()), null);
      Optional<OrdMain> ordMain = ordMainDao.selectItemByPatId(facilityCd, Long.valueOf(payload.get("patId").toString()), null);
      // mod #12462 患者情報共有 zhao end
      // add #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao end
      if (ordMain.isPresent()) {
        dataKey.put("ordNo", Long.valueOf(Math.toIntExact(ordMain.get().getOrdNo())));
      } else {
        dataKey.put("ordNo", 0L);
      }
      dataKey.put("reportClass",mstReport.getReportClass());

    //add #9616 帳票印刷失敗通知がされない 李 start
    // del #9616 帳票印刷失敗通知がされない 高　start
//    String reportName= "";
//    String facilityCd= "";
    // del #9616 帳票印刷失敗通知がされない 高　end
    //add #9616 帳票印刷失敗通知がされない 李 end
      // add #12650 登録済み紹介状が帳票マスタ削除の影響を受けるのは不適切 zhao start
      String ctlNo = Optional.ofNullable(payload.get("ctlNo"))
        .map(Object::toString)
        .orElse("");
      dataKey.put("ctlNo", ctlNo);
      // add #12650 登録済み紹介状が帳票マスタ削除の影響を受けるのは不適切 zhao end
      try {
        // add #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
        dataKey.putAll(reportMenuDataKeyService.searchReportSettingForDataKey(String.valueOf(dataKey.getOrDefault(ReportConstant.ReportDataKey.FACILITY_CD, "")), reportCd, dataKey));
        // add #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end
        Map<String,byte[]> byteMap = new HashMap<>();
        // mod #10857 帳票内に同項目が複数あると設定値を取り違える limingzhe start
        //byte[] excelBytes = reportService.getReportExcelFileForIntroductionReport(reportCd, dataKey);
        // mod #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe start
        //byte[] excelBytes = reportForIntroductionReportService.getReportExcelFileForIntroductionReport(reportCd, dataKey);
        byte[] excelBytes = reportForIntroductionReportService.getReportExcelFileForIntroductionReportbyHTMLPrint(reportCd, dataKey);
        // mod #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe end
        // mod #10857 帳票内に同項目が複数あると設定値を取り違える limingzhe end

        byteMap.put("ReferralLetter",excelBytes);
        if(payload.get("dispItemInfo")!=null){
          JSONArray jsonArray = new JSONArray(payload.get("dispItemInfo").toString());
          if(jsonArray.length() > 0){
            for(int i = 0;i < jsonArray.length();i++){
              JSONObject jsonObj = jsonArray.getJSONObject(i);
              if(jsonObj.has("reportCd") || ( jsonObj.has("times") && !StringUtils.isEmpty(jsonObj.get("times").toString()) && jsonObj.getInt("times") > 0) ){
                StringBuilder html = new StringBuilder();
                dataKey = new HashMap<>();
                // del #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
//                dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS,searchList.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
//                dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS,searchList.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
//                dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,searchList.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
                // del #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end
                Integer itemNo = jsonObj.getInt("itemNo");
                // mod 9608 紹介状印刷時に同時に出力される透析レポートについて　吉 start
                // dataKey.put("login", ntssUser.getUsername());
                String userNameStr = mstPersonalUserDao.selectUserNameById(ntssUser.getUserId());
                dataKey.put("login", userNameStr);
                // mod 9608 紹介状印刷時に同時に出力される透析レポートについて　吉 end
                dataKey.put("facilityCd", facilityCd);
                if(itemNo.equals(ReportConstant.ReportClass.DIALYSIS_REPORT)){
                  // add #12480 紹介状印刷時に、"サブイベントカテゴリマスタ"の帳票種別で  吉 start
                  dataKey.put(ReportConstant.ReportDataKey.reportClass,ReportConstant.ReportClass.DIALYSIS_REPORT);
                  // add #12480 紹介状印刷時に、"サブイベントカテゴリマスタ"の帳票種別で  吉 end
                  dataKey.put("patId", payload.get("patId").toString());
                  List<Long> reportCds = ordMainDao.selectReportCd(ntssUser.getFacilityCd(),Long.parseLong(payload.get("patId").toString()), jsonObj.has("times") ? jsonObj.getInt("times") : null);
                  List<Long> orderNo = ordMainDao.selectOrdnoByPatIdNear(ntssUser.getFacilityCd(),Long.parseLong(payload.get("patId").toString()), jsonObj.has("times") ? jsonObj.getInt("times") : null);
                  if(reportCds.size()>0){
                    dataKey.put(ReportConstant.ReportDataKey.treatDate, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
                    dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
                    dataKey.put(ReportConstant.ReportDataKey.DATE_TO, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
                    dataKey.put(ReportConstant.ReportDataKey.DATE, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
                    for(int k = 0;k<reportCds.size();k++){
                      dataKey.put(ReportConstant.ReportDataKey.ORD_NO,orderNo.get(k));
                      // add #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
                      dataKey.putAll(reportMenuDataKeyService.searchReportSettingForDataKey(String.valueOf(dataKey.getOrDefault(ReportConstant.ReportDataKey.FACILITY_CD, "")), reportCds.get(k), dataKey));
                      // add #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end
                      excelBytes= reportService.getReportExcelFileForDialysisReport(reportCds.get(k), dataKey);
                      //mod #9616 帳票印刷失敗通知がされない 李 start
//                  String reportName= reportNameChange(itemNo) + k;
                      reportName= reportNameChange(itemNo) + k;
                      //mod #9616 帳票印刷失敗通知がされない 李 end
                      byteMap.put(reportName,excelBytes);
                    }
                  }
                }
                if(itemNo.equals(ReportConstant.ReportClass.LABEL_REPORT)){
                  // add #12480 紹介状印刷時に、"サブイベントカテゴリマスタ"の帳票種別で  吉 start
                  dataKey.put(ReportConstant.ReportDataKey.reportClass,ReportConstant.ReportClass.LABEL_REPORT);
                  // add #12480 紹介状印刷時に、"サブイベントカテゴリマスタ"の帳票種別で  吉 end
                  Long reportCds = jsonObj.getLong("reportCd");
                  dataKey.put(ReportConstant.ReportDataKey.treatDate, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
                  String nowYYYYMMDD = nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd"));
                  OrdMain near = reportMenuDao.selectNearOrdPlan(Long.valueOf(payload.get("patId").toString()), nowYYYYMMDD);
                  dataKey.put(ReportConstant.ReportDataKey.ORD_NOS, Collections.singletonList(near == null ? 0 : near.getOrdNo()));
                  List<Long> list = new ArrayList();
                  list.add(Long.parseLong(payload.get("patId").toString()));
                  dataKey.put("patIds", list);
                  // del #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
//                  // add #12480 紹介状印刷時に、"サブイベントカテゴリマスタ"の帳票種別で  吉 start
//                  dataKey.put("regOrderClass", new ArrayList<String>(Arrays.asList("1", "2", "0")));
//                  // add #12480 紹介状印刷時に、"サブイベントカテゴリマスタ"の帳票種別で  吉 end
                  // del #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end
                  // mod #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe start
                  //excelBytes = reportService.getReportExcelFileForLabelReport(reportCds, dataKey);
                  // add #12480 紹介状印刷時に、"サブイベントカテゴリマスタ"の帳票種別で  吉 start
                  dataKey.put(ReportConstant.ReportDataKey.DATE, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
                  // add #12480 紹介状印刷時に、"サブイベントカテゴリマスタ"の帳票種別で  吉 end
                  // add #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
                  dataKey.putAll(reportMenuDataKeyService.searchReportSettingForDataKey(String.valueOf(dataKey.getOrDefault(ReportConstant.ReportDataKey.FACILITY_CD, "")), reportCds, dataKey));
                  // add #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end
                  excelBytes = reportForLabelReportService.getReportExcelFileForLabelReport(reportCds, dataKey);
                  // mod #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe end
                  //mod #9616 帳票印刷失敗通知がされない 李 start
//                  String reportName= reportNameChange(itemNo);
                  reportName= reportNameChange(itemNo);
                  //mod #9616 帳票印刷失敗通知がされない 李 end
                  byteMap.put(reportName,excelBytes);
                }
                if(itemNo.equals(ReportConstant.ReportClass.ONE_PATIENT_REPORT)){
                  // add #12480 紹介状印刷時に、"サブイベントカテゴリマスタ"の帳票種別で  吉 start
                  dataKey.put(ReportConstant.ReportDataKey.reportClass,ReportConstant.ReportClass.ONE_PATIENT_REPORT);
                  // add #12480 紹介状印刷時に、"サブイベントカテゴリマスタ"の帳票種別で  吉 end
                  Long reportCds = jsonObj.getLong("reportCd");
                  Calendar c =Calendar.getInstance();
                  c.setTime(new Date());
                  c.add(Calendar.DATE , -7);
                  Date d = c.getTime();
                  dataKey.put(ReportConstant.ReportDataKey.treatDate, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
                  dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
                  dataKey.put(ReportConstant.ReportDataKey.DATE_TO, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
                  dataKey.put(ReportConstant.ReportDataKey.DATE, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
                  dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD, facilityCd);
                  List<OrdMain>ordList = reportMenuDao.selectResultByTreatDate(Long.valueOf(payload.get("patId").toString()),null, sdf.format(d) , nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
                  List<Long> patIds = new ArrayList<>();
                  List<Long> ordNos = new ArrayList<>();
                  if(null != ordList && ordList.size()>0){
                    for(OrdMain om : ordList){
                      ordNos.add(om.getOrdNo());
                      patIds.add(om.getPatId());
                    }
                    dataKey.put(ReportConstant.ReportDataKey.PAT_ID, ordList.get(0).getPatId());
                    dataKey.put(ReportConstant.ReportDataKey.ORD_NO, ordList.get(0).getOrdNo());
                    // add #12480 紹介状印刷時に、"サブイベントカテゴリマスタ"の帳票種別で  吉 start
                  }else{
                    dataKey.put(ReportConstant.ReportDataKey.PAT_ID, payload.get("patId").toString());
                  }

                  Long ordPrescription = ordPrescriptionDao.getOrdPrescriptionNoOne(Long.valueOf(payload.get("patId").toString()),
                    nowDate.format(DateTimeFormatter.ofPattern("yyyyMMdd")),facilityCd);
                  dataKey.put("ordPrescriptionNo",ordPrescription);

                  // add #12480 紹介状印刷時に、"サブイベントカテゴリマスタ"の帳票種別で  吉 end
                  dataKey.put(ReportConstant.ReportDataKey.ORD_NOS, ordNos);
                  dataKey.put(ReportConstant.ReportDataKey.PAT_IDS, patIds);
                  Map<String, Object> searchInfo = new HashMap<>();
                  searchInfo.put("login", userNameStr);
                  searchInfo.put(ReportConstant.ReportDataKey.freeWord,null);
                  searchInfo.put(ReportConstant.ReportDataKey.treatDate,dataKey.get(ReportConstant.ReportDataKey.DATE_FROM)); // 1日指定の日付を格納しているが問題ない
                  searchInfo.put(ReportConstant.ReportDataKey.kurCdList,null);
                  searchInfo.put(ReportConstant.ReportDataKey.bedCdListString,null);
                  searchInfo.put(ReportConstant.ReportDataKey.expressCondCd,null);
                  searchInfo.put(ReportConstant.ReportDataKey.DATE_FROM, dataKey.get(ReportConstant.ReportDataKey.DATE_FROM));
                  searchInfo.put(ReportConstant.ReportDataKey.DATE_TO, dataKey.get(ReportConstant.ReportDataKey.DATE_TO));
                  // add #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
                  dataKey.putAll(reportMenuDataKeyService.searchReportSettingForDataKey(String.valueOf(dataKey.getOrDefault(ReportConstant.ReportDataKey.FACILITY_CD, "")), reportCds, dataKey));
                  // add #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end
                  // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
                  //excelBytes = reportService.getReportExcelFileForOnePatient(reportCds, dataKey,searchInfo);
                  excelBytes = reportForOnePatientService.getReportExcelFileForOnePatient(reportCds, dataKey,searchInfo);
                  // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
                  //mod #9616 帳票印刷失敗通知がされない 李 start
//                  String reportName= reportNameChange(itemNo);
                  reportName= reportNameChange(itemNo);
                  //mod #9616 帳票印刷失敗通知がされない 李 end
                  byteMap.put(reportName,excelBytes);
                }
                if(itemNo.equals(ReportConstant.ReportClass.ONE_TOTAL_REPORT)){
                  // add #12480 紹介状印刷時に、"サブイベントカテゴリマスタ"の帳票種別で  吉 start
                  dataKey.put(ReportConstant.ReportDataKey.reportClass,ReportConstant.ReportClass.ONE_TOTAL_REPORT);
                  // add #12480 紹介状印刷時に、"サブイベントカテゴリマスタ"の帳票種別で  吉 end
                  Long reportCds = jsonObj.getLong("reportCd");
                  Calendar c =Calendar.getInstance();
                  c.setTime(new Date());
                  c.add(Calendar.DATE , -7);
                  Date d = c.getTime();
                  dataKey.put(ReportConstant.ReportDataKey.treatDate, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
                  dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
                  dataKey.put(ReportConstant.ReportDataKey.DATE_TO, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
                  dataKey.put(ReportConstant.ReportDataKey.DATE, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
                  dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD, ntssUser.getFacilityCd());
                  List<OrdMain>ordList = reportMenuDao.selectResultByTreatDate(Long.valueOf(payload.get("patId").toString()),null, sdf.format(d) , nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
                  List<Long> patIds = new ArrayList<>();
                  List<Long> ordNos = new ArrayList<>();
                  if(null != ordList && ordList.size()>0){
                    for(OrdMain om : ordList){
                      ordNos.add(om.getOrdNo());
                      patIds.add(om.getPatId());
                    }
                  }
                  // add #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
                  else{
                    patIds.add(Long.valueOf(payload.get("patId").toString()));
                  }
                  // add #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end
                  dataKey.put(ReportConstant.ReportDataKey.ORD_NOS, ordNos);
                  dataKey.put(ReportConstant.ReportDataKey.PAT_IDS, patIds);
                  // add #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
                  dataKey.putAll(reportMenuDataKeyService.searchReportSettingForDataKey(String.valueOf(dataKey.getOrDefault(ReportConstant.ReportDataKey.FACILITY_CD, "")), reportCds, dataKey));
                  // add #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end
                  // mod #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe start
                  // excelBytes = reportService.getReportExcelFileForOneTotal(reportCds, dataKey);
                  excelBytes = reportForTotalService.getReportExcelFileForOneTotal(reportCds, dataKey);
                  // mod #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe end
                  //mod #9616 帳票印刷失敗通知がされない 李 start
//                  String reportName= reportNameChange(itemNo);
                  reportName= reportNameChange(itemNo);
                  //mod #9616 帳票印刷失敗通知がされない 李 end
                  byteMap.put(reportName,excelBytes);
                }
                // mod 9608 紹介状印刷時に同時に出力される透析レポートについて　吉 end
              }
            }
          }
        }
        for (Map.Entry<String,byte[]> entry : byteMap.entrySet()) {
          if (entry.getValue().length > 0) {
            ByteArrayInputStream excelByesIS = new ByteArrayInputStream(entry.getValue());
            ByteArrayOutputStream excelBytesOS = new ByteArrayOutputStream();
            URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
            AsposeCellsUtils.excelToPdf(excelByesIS,excelBytesOS,url);
            byteMap.put(entry.getKey(),excelBytesOS.toByteArray());
          }
        }
        //del #9616 帳票印刷失敗通知がされない 李 start
//        String reportName = "IntroductionLetter";
        //del #9616 帳票印刷失敗通知がされない 李 end

        Long printerCd = -1L;
        // 画面から選択したプリンターのパラメータがわたっていない場合
        if(StringUtils.isEmpty(payload.get("printerCd"))){
          if (!StringUtils.isEmpty(mstReport)) {
            // 帳票マスタのプリンター初期値が設定されていない場合
            if(StringUtils.isEmpty(mstReport.getDefaultPrinter())){
              // 施設設定マスタの既定のプリンターを取得し、プリンター初期値とする
              List<FacilitySettingInfo> settingInfoList = mstFacilitySettingDao.selectFacilitySetting(ntssUser.getFacilityCd(), CoreConstant.FacilitySettingNo.DEFAULT_PRINTER);
              if(null != settingInfoList && settingInfoList.size()>0 && null != settingInfoList.get(0).getValue()){
                String defaulPrinter = settingInfoList.get(0).getValue();
                mstReport.setDefaultPrinter(Long.valueOf(defaulPrinter));
              }
            }
            // プリンター初期値を設定
            printerCd = mstReport.getDefaultPrinter();
          }
        }else {
          // 画面で選択したプリンターを設定
          printerCd = Long.parseLong(payload.get("printerCd").toString());
        }

        // mod 9608 紹介状印刷時に同時に出力される透析レポートについて　吉 start
        // reportMenuService.IntroductionLetterPrintPdfReport(byteMap,reportName, mstReport.getDefaultPrinter());
        //mod #9616 帳票印刷失敗通知がされない 李 start
        reportMenuService.IntroductionLetterPrintPdfReport(byteMap,reportName, printerCd,ntssUser.getFacilityCd(), "紹介状");
        //mod #9616 帳票印刷失敗通知がされない 李 end
        // mod 9608 紹介状印刷時に同時に出力される透析レポートについて　吉 end
        return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
      } catch (Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        if (!StringUtils.isEmpty(facilityCd)) {
          eventLogMessage.setFacilityCd(facilityCd);
        }
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end

        //add #9616 帳票印刷失敗通知がされない 李 start
      // mod #9616 帳票印刷失敗通知がされない 高　start
//      printerService.saveNotiMessage("紹介状", "紹介状", facilityCd);
        printerService.saveNotiMessage("紹介状", reportName, facilityCd);
      // mod #9616 帳票印刷失敗通知がされない 高　end
        //add #9616 帳票印刷失敗通知がされない 李 end

      }

      return new ResponseEntity<>("", HttpStatus.INTERNAL_SERVER_ERROR);
      // del 9316 施設設定マスタ125番の削除について　吉 start
//    }else{
//      //old
//      //add  Aspose.cells plug-in integration  吉 end
//      // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
//      Map<String,List> searchList =this.searchMap(ntssUser.getFacilityCd());
//      // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
//      StringBuilder introductionHtml = new StringBuilder(String.valueOf(payload.get("htmlTemplate").toString()));
//      if(payload.get("dispItemInfo")!=null){
//        JSONArray jsonArray = new JSONArray(payload.get("dispItemInfo").toString());
//        if(jsonArray.length() > 0){
//          for(int i = 0;i < jsonArray.length();i++){
//            JSONObject jsonObj = jsonArray.getJSONObject(i);
//            /*mod FNSI-改修内容4608 任 start*/
//          /*if(jsonObj.has("reportCd")){
//            Integer itemNo = jsonObj.getInt("itemNo");
//            Long reportCd = jsonObj.getLong("reportCd");
//            Map<String, Object> dataKey = new HashMap<>();
//            dataKey.put("login", ntssUser.getUsername());
//            if(itemNo.equals(ReportConstant.ReportClass.MULTIPLE_PATIENT_REPORT) || itemNo.equals(ReportConstant.ReportClass.DISTRIBUTION_LIST_BED_REPORT)){
//              List<Map<String, Object>> tmplParams = new ArrayList<Map<String, Object>>();
//              Map<String, Object> tmplParam = new HashMap<>();
//              tmplParam.put(ReportConstant.ReportDataKey.PAT_ID, payload.get("patId").toString());
//              tmplParams.add(tmplParam);
//              dataKey.put(ReportConstant.ReportDataKey.TEMPLATE_PARAMS, tmplParams);
//            }else if(itemNo.equals(ReportConstant.ReportClass.LABEL_REPORT)){
//              List<Long> list = new ArrayList();
//              list.add(Long.parseLong(payload.get("patId").toString()));
//              dataKey.put("patIds", list);
//            }else{
//              dataKey.put("patId", payload.get("patId").toString());
//            }
//            String html = reportService.getReportHtml(reportCd, dataKey, null, null);*/
//            if(jsonObj.has("reportCd") || ( jsonObj.has("times") && !StringUtils.isEmpty(jsonObj.getString("times")) && jsonObj.getInt("times") > 0) ){
//              StringBuilder html = new StringBuilder();
//              Map<String, Object> dataKey = new HashMap<>();
//              // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
//              dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS,searchList.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
//              dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS,searchList.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
//              dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,searchList.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
//              // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
//              Integer itemNo = jsonObj.getInt("itemNo");
//              dataKey.put("login", ntssUser.getUsername());
//              dataKey.put("facilityCd", ntssUser.getFacilityCd());
//              // mod 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 start
////            if(itemNo.equals(ReportConstant.ReportClass.MULTIPLE_PATIENT_REPORT) || itemNo.equals(ReportConstant.ReportClass.DISTRIBUTION_LIST_BED_REPORT)){
////              List<Map<String, Object>> tmplParams = new ArrayList<Map<String, Object>>();
////              Map<String, Object> tmplParam = new HashMap<>();
////              tmplParam.put(ReportConstant.ReportDataKey.PAT_ID, payload.get("patId").toString());
////              tmplParams.add(tmplParam);
////              dataKey.put(ReportConstant.ReportDataKey.TEMPLATE_PARAMS, tmplParams);
////            }else if(itemNo.equals(ReportConstant.ReportClass.LABEL_REPORT)){
////              List<Long> list = new ArrayList();
////              list.add(Long.parseLong(payload.get("patId").toString()));
////              dataKey.put("patIds", list);
////            }else{
////              dataKey.put("patId", payload.get("patId").toString());
////            }
//              if(itemNo.equals(ReportConstant.ReportClass.DIALYSIS_REPORT)){
//                dataKey.put("patId", payload.get("patId").toString());
//              }else if(itemNo.equals(ReportConstant.ReportClass.LABEL_REPORT) ||
//                itemNo.equals(ReportConstant.ReportClass.DISTRIBUTION_LIST_BED_REPORT) ||
//                itemNo.equals(ReportConstant.ReportClass.PREPARATION_LIST_REPORT)){
//                LocalDate nowDate = LocalDate.now();
//                dataKey.put(ReportConstant.ReportDataKey.treatDate, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
//                String nowYYYYMMDD = nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd"));
//                OrdMain near = reportMenuDao.selectNearOrdPlan(Long.valueOf(payload.get("patId").toString()), nowYYYYMMDD);
//                dataKey.put(ReportConstant.ReportDataKey.ORD_NOS,Collections.singletonList(near == null ? 0 : near.getOrdNo()));
//                List<Long> list = new ArrayList();
//                list.add(Long.parseLong(payload.get("patId").toString()));
//                dataKey.put("patIds", list);
//              }else{
//                Calendar c =Calendar.getInstance();
//                c.setTime(new Date());
//                c.add(Calendar.DATE , -7);
//                Date d = c.getTime();
//                LocalDate nowDate = LocalDate.now();
//                dataKey.put(ReportConstant.ReportDataKey.treatDate, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
//                dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
//                dataKey.put(ReportConstant.ReportDataKey.DATE_TO, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
//                dataKey.put(ReportConstant.ReportDataKey.DATE, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
//                dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD, ntssUser.getFacilityCd());
//                SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd ");
//                List<OrdMain>ordList = reportMenuDao.selectResultByTreatDate(Long.valueOf(payload.get("patId").toString()),null, sdf.format(d) , nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
//                List<Map<String, Object>> tmplParams = new ArrayList<Map<String, Object>>();
//                if(null != ordList && ordList.size()>0){
//                  for(OrdMain om : ordList){
//                    Map<String, Object> tmplParam = new HashMap<>();
//                    tmplParam.put(ReportConstant.ReportDataKey.MEDICINE_IDS,searchList.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
//                    tmplParam.put(ReportConstant.ReportDataKey.DIALYZER_IDS,searchList.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
//                    tmplParam.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,searchList.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
//                    // mod 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 start
//                    // tmplParam.put(ReportConstant.ReportDataKey.treatDate, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
//                    tmplParam.put(ReportConstant.ReportDataKey.treatDate, om.getTreatDate());
//                    // mod 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 end
//                    tmplParam.put(ReportConstant.ReportDataKey.DATE_FROM, sdf.format(d));
//                    tmplParam.put(ReportConstant.ReportDataKey.DATE_TO, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
//                    // mod 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 start
//                    // tmplParam.put(ReportConstant.ReportDataKey.DATE, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
//                    tmplParam.put(ReportConstant.ReportDataKey.DATE, om.getTreatDate());
//                    // mod 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 end
//                    tmplParam.put(ReportConstant.ReportDataKey.PAT_ID, payload.get("patId").toString());
//                    tmplParam.put(ReportConstant.ReportDataKey.ORD_NO,om.getOrdNo());
//                    tmplParam.put(ReportConstant.ReportDataKey.FACILITY_CD, ntssUser.getFacilityCd());
//                    tmplParams.add(tmplParam);
//                  }
//                }
//                dataKey.put(ReportConstant.ReportDataKey.TEMPLATE_PARAMS, tmplParams);
//              }
//              // mod 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 end
//              if(itemNo == 1){
//                // mod FNSI-改修内容#6023 周 start
//                //List<Long> reportCd = ordMainDao.selectReportCd(Long.parseLong(payload.get("patId").toString()),jsonObj.getInt("times"));
//                // mod 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 start
//                // List<Long> reportCd = ordMainDao.selectReportCd(Long.parseLong(payload.get("patId").toString()), jsonObj.has("times") ? jsonObj.getInt("times") : null);
//                List<Long> reportCd = ordMainDao.selectReportCd(ntssUser.getFacilityCd(),Long.parseLong(payload.get("patId").toString()), jsonObj.has("times") ? jsonObj.getInt("times") : null);
//                // add 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 start
//                List<Long> orderNo = ordMainDao.selectOrdnoByPatIdNear(ntssUser.getFacilityCd(),Long.parseLong(payload.get("patId").toString()), jsonObj.has("times") ? jsonObj.getInt("times") : null);
//                // add 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 end
//                // mod 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 end
//                // mod FNSI-改修内容#6023 周 end
//                if(reportCd.size()>0){
//                  // add 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 start
//                  LocalDate nowDate = LocalDate.now();
//                  dataKey.put(ReportConstant.ReportDataKey.treatDate, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
//                  dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
//                  dataKey.put(ReportConstant.ReportDataKey.DATE_TO, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
//                  dataKey.put(ReportConstant.ReportDataKey.DATE, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
//                  // add 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 end
//                  for(int k = 0;k<reportCd.size();k++){
//                    // add 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 start
//                    dataKey.put(ReportConstant.ReportDataKey.ORD_NO,orderNo.get(k));
//                    // add 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 end
//                    html.append(reportService.getReportHtml(reportCd.get(k), dataKey, null, null));
//                  }
//                }
//              }else{
//                Long reportCd = jsonObj.getLong("reportCd");
//                html = new StringBuilder(reportService.getReportHtml(reportCd, dataKey, null, null));
//              }
//              /*mod FNSI-改修内容4608 任 end*/
//              introductionHtml.append(html);
//            }
//          }
//        }
//      }
//      String htmlResult = "";
//      if(introductionHtml.toString()!=null){
//        String htmlString[] = introductionHtml.toString().split("<tbody>");
//        if(htmlString.length>2){
//          htmlResult = htmlString[0] + "<tbody>";
//          for(int i = 1 ;i < htmlString.length;i++){
//            if(i<htmlString.length-1){
//              htmlResult += htmlString[i] + "<div style=\"page-break-after: always;\"></div><tbody>";
//            }else{
//              htmlResult += htmlString[i];
//            }
//          }
//        }else{
//          htmlResult = introductionHtml.toString();
//        }
//      }
//      if (introductionHtml.toString().equals("")) {
//        /*mod FNSI-改修内容マスタ画面の修正に伴い、紐付ける帳票を一括印刷するように修正 任 end*/
//
//        // wp アプリケーションログの適正化 Add Start
//        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_PAT_INTRO_LETTER, AFTER_LOG_FLG_INFO, mappingUrl, null,
//          null);
//        // wp アプリケーションログの適正化 Add End
//        return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.BAD_REQUEST);
//      }
//      String reportName = "IntroductionLetter";
//      Long reportCd = Long.parseLong(payload.get("reportCd").toString());
//      Long patId = Long.parseLong(payload.get("patId").toString());
//      MstReport mstReport = mstReportDao.selectByCd(reportCd);
//      try {
//        if (!StringUtils.isEmpty(mstReport)) {
//          // add 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 start
//          if(StringUtils.isEmpty(mstReport.getDefaultPrinter())){
//            List<FacilitySettingInfo> settingInfoList = mstFacilitySettingDao.selectFacilitySetting(ntssUser.getFacilityCd(), CoreConstant.FacilitySettingNo.DEFAULT_PRINTER);
//            if(null != settingInfoList && settingInfoList.size()>0 && null != settingInfoList.get(0).getValue()){
//              String defaulPrinter = settingInfoList.get(0).getValue();
//              mstReport.setDefaultPrinter(Long.valueOf(defaulPrinter));
//            }
//          }
//          // add 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 end
//          /*mod FNSI-改修内容マスタ画面の修正に伴い、紐付ける帳票を一括印刷するように修正 任 start*/
//          /*patIntroductionLetterService.printReport(introductionHtml, reportName, mstReport, patId);*/
//          printReport(htmlResult, reportName, mstReport, patId);
//          /*mod FNSI-改修内容マスタ画面の修正に伴い、紐付ける帳票を一括印刷するように修正 任 end*/
//        }
//
//        // wp アプリケーションログの適正化 Add Start
//        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_PAT_INTRO_LETTER, AFTER_LOG_FLG_INFO, mappingUrl, null,
//          null);
//        // wp アプリケーションログの適正化 Add End
//        return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
//      } catch (Exception e) {
//
//        // wp アプリケーションログの適正化 Add Start
//        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_PAT_INTRO_LETTER, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
//        // wp アプリケーションログの適正化 Add End
//
//        return new ResponseEntity<>(e.toString(), HttpStatus.INTERNAL_SERVER_ERROR);
//      }
//      //add  Aspose.cells plug-in integration  吉 start
//    }
    // del 9316 施設設定マスタ125番の削除について　吉 end
    //add  Aspose.cells plug-in integration  吉 end
  }

  @Override
  public ResponseEntity<?> syncPatientInformation(Map<String, Object> payload, String mappingUrl) throws Exception {
    Long reportCd = Long.parseLong(payload.get("reportCd").toString());
    Long patId = Long.parseLong(payload.get("patId").toString());

    Map<String, String> mapKeyPatInfo = objectMapper.convertValue(payload.get("letterData"), Map.class);

    MstReport mstReport = mstReportDao.selectByCd(reportCd);
    if (!StringUtils.isEmpty(mstReport)) {

      byte[] zipFile = reportS3Service.getReportFile(mstReport.getReportPath().getBucket(),
        mstReport.getReportPath().getReportZip(), null);

      ReportZipFile reportZipFile = new ReportZipFile(zipFile);

      String reportXml = reportZipFile.getFileToString(mstReport.getReportPath().getXmlFilename());

      reportXml = reportXml.trim().replaceFirst("^([\\W]+)<", "<");

      List<ReportXmlParam> parserXml = ReportUtils.getParamElements(reportXml);
      Map<String, String> keyMapPatInfo = new HashMap<String, String>();

      for (int i = 0; i < parserXml.size(); i++) {
        for (Map.Entry<String, String> entryMapKeyPatInfo : mapKeyPatInfo.entrySet()) {
          if (parserXml.get(i).getId().equals(entryMapKeyPatInfo.getKey())) {
            keyMapPatInfo.put(parserXml.get(i).getDataCode(), entryMapKeyPatInfo.getValue());
          }
        }
      }
      /*add FNSI-改修内容紹介状登録と編集画面改修四つボタン改修 任 start*/
      for(Map.Entry<String, String> entry : keyMapPatInfo.entrySet()){
        String mapValue = entry.getValue();
        String mapKey = entry.getKey();
        if("pat_sex".equals(mapKey)){
          if(mapValue.contains("男")){
            entry.setValue("1");
          }else if(mapValue.contains("女")){
            entry.setValue("2");
          }else if(mapValue.contains("不明")||"".equals(mapValue)){
            entry.setValue("0");
          }else{
            Map<String, String> resp = new HashMap<String, String>();
            resp.put("msg","false");

            // wp アプリケーションログの適正化 Add Start
            logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_PAT_INTRO_LETTER, AFTER_LOG_FLG_INFO, mappingUrl, null,
              null);
            // wp アプリケーションログの適正化 Add End
            return new ResponseEntity<>(resp, HttpStatus.OK);
          }
        }
        if("pat_birthday".equals(mapKey)){
          SimpleDateFormat sm = new SimpleDateFormat("yyyyMMdd");
          if(mapValue.matches("\\d{4}\\d{2}\\d{2}")){
            entry.setValue(sm.format(sm.parse(mapValue)));
          }else if(mapValue.matches("\\d{4}[/]\\d{2}[/]\\d{2}")){
            SimpleDateFormat smFormat = new SimpleDateFormat("yyyy/MM/dd");
            entry.setValue(sm.format(smFormat.parse(mapValue)));
          }else if(!"".equals(mapValue)){
            Map<String, String> resp = new HashMap<String, String>();
            resp.put("msg","dateFalse");

            // wp アプリケーションログの適正化 Add Start
            logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_PAT_INTRO_LETTER, AFTER_LOG_FLG_INFO, mappingUrl, null,
              null);
            // wp アプリケーションログの適正化 Add End
            return new ResponseEntity<>(resp, HttpStatus.OK);
          }
        }
        /*add FNSI-改修内容患者イベント外结No.6 任 start*/
        if("in_out_class".equals(mapKey)){
          if(mapValue.contains("外来")){
            entry.setValue("0");
          }else if(mapValue.contains("入院")){
            entry.setValue("1");
          }else if(mapValue.contains("死亡")) {
            entry.setValue("2");
          }else if(mapValue.contains("不在")){
            entry.setValue("3");
          }else{
            Map<String, String> resp = new HashMap<String, String>();
            resp.put("msg","inOutClassFalse");
            logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_PAT_INTRO_LETTER, AFTER_LOG_FLG_INFO, mappingUrl, null,
              null);
            return new ResponseEntity<>(resp, HttpStatus.OK);
          }
        }
        /*add FNSI-改修内容患者イベント外结No.6 任 end*/
      }
      /*add FNSI-改修内容紹介状登録と編集画面改修四つボタン改修 任 end*/
      PatPersonalMain patPersonalMain = objectMapper.readValue(objectMapper.writeValueAsString(keyMapPatInfo),
        PatPersonalMain.class);

      updatePatientInfo(patId, patPersonalMain);
    }

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_PAT_INTRO_LETTER, AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
  }

  //add  Aspose.cells plug-in integration  吉 start
  public String reportNameChange(Integer reportClass){
    String reportName ="";
    switch (reportClass){
      case 1 :
        reportName="Dialysis";
        break;
      case 2 :
        reportName="OnePatient";
        break;
      case 3 :
        reportName="MultiPatient";
        break;
      case 4 :
        reportName="EquipmentList";
        break;
      case 5 :
        reportName="DistributeListBed";
        break;
      case 6 :
        reportName="DistributeListEquipment";
        break;
      case 7 :
        reportName="Device";
        break;
      case 8 :
        reportName="Label";
        break;
      case 9 :
        reportName="ReferralLetter";
        break;
      case 10 :
        reportName="OneTotal";
        break;
      case 11 :
        reportName="MultiTotal";
        break;
      default:
        reportName = "";
        break;
    }
    return reportName;
  }
  //add  Aspose.cells plug-in integration  吉 end

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
  /* add by gaojuncheng  2023-02-01 [CodeOptimization]  end */
  // add #12462 患者情報共有 zhao start
  /**
   * 患者共有情報を取得する
   * @param patId 患者ID
   * @param facilityCd 施設コード
   * @return 患者共有情報
   */
  public List<ShrPatInfo> getShrPatInfoForPatId(Long patId, String facilityCd){
    List<ShrPatInfo> shrPatInfoList = shrPatInfoDao.selectShrPatInfoByPatId(patId, facilityCd);
    return shrPatInfoList;
  }
  // add #12462 患者情報共有 zhao end
}
