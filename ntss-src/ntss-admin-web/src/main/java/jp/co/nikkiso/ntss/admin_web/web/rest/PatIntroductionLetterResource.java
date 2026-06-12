package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.introductionLetterCreation.PatIntroductionLetterService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.reportMenu.ReportMenuService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.dao.MstReportDao;
import jp.co.nikkiso.ntss.core.entity.MstReport;
import jp.co.nikkiso.ntss.core.entity.ShrPatInfo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ResourceLoader;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Arrays;
import java.util.List;
import java.util.Map;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * 紹介状画面のResourceクラス.
 */
@RestController
@RequestMapping(Uri.PAT_INTRODUCTION_LETTER)
public class PatIntroductionLetterResource {

	@Autowired
	private PatIntroductionLetterService patIntroductionLetterService;

  /* del by gaojuncheng  2023-02-01 [CodeOptimization]  start */
//	@Autowired
//	private ObjectMapper objectMapper;
//
//	@Autowired
//	private ReportS3Service reportS3Service;
  /* del by gaojuncheng  2023-02-01 [CodeOptimization]  end */

	@Autowired
	private MstReportDao mstReportDao;

  /* del by gaojuncheng  2023-02-01 [CodeOptimization]  start */
//	@Autowired
//	private OrdMainDao ordMainDao;
//
//	@Autowired
//	private ReportService reportService;
  /* del by gaojuncheng  2023-02-01 [CodeOptimization]  end */

	@Autowired
	LogService logService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;

  /* del by gaojuncheng  2023-02-01 [CodeOptimization]  start */
  // wp アプリケーションログの適正化 Add End
  // add 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 start
//  @Autowired
//  private MstFacilitySettingDao mstFacilitySettingDao;
  // add 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 end
  // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
//  @Autowired
//  private MstEquipmentClassDao mstEquipmentClassDao;
//  @Autowired
//  private MstMedicineClassDao mstMedicineClassDao;
//  @Autowired
//  private MstInfoService mstInfoService;
//  @Autowired
//  private ReportMenuDao reportMenuDao;
  // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
  //add  Aspose.cells plug-in integration  吉 start
  /* del by gaojuncheng  2023-02-01 [CodeOptimization]  end */

  @Autowired
  ReportMenuService reportMenuService;
  //add  Aspose.cells plug-in integration  吉 end
  @Autowired
  ResourceLoader resourceLoader;
	/**
	 * 紹介状テンプレートの習得
	 *
	 * @param patId
	 * @param reportCd
	 * @return
	 */
  // mod 11488 紹介状登録内容保存時に帳票の版も記憶する　1.1A  吉 start
//  @GetMapping("/get-intro-letter-template/{patId}/{reportCd}")
//  public ResponseEntity<?> getIntroLetterTemplate(@PathVariable Long patId, @PathVariable Long reportCd, @AuthenticationPrincipal NtssUser ntssUser) {
// mod #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao start
//  @GetMapping("/get-intro-letter-template/{patId}/{reportCd}/{ctlNo}/{isUpdate}")
//  public ResponseEntity<?> getIntroLetterTemplate(@PathVariable Long patId, @PathVariable Long reportCd, @PathVariable String ctlNo,@PathVariable String isUpdate, @AuthenticationPrincipal NtssUser ntssUser) {
    @GetMapping("/get-intro-letter-template/{patId}/{reportCd}/{ctlNo}/{isUpdate}/{reportStartDate}")
    public ResponseEntity<?> getIntroLetterTemplate(@PathVariable Long patId, @PathVariable Long reportCd,
                                                    @PathVariable String ctlNo,@PathVariable String isUpdate,
                                                    @PathVariable String reportStartDate,
                                                    @AuthenticationPrincipal NtssUser ntssUser) {
// mod #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao end
// mod 11488 紹介状登録内容保存時に帳票の版も記憶する　1.1A  吉 end

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.PAT_INTRODUCTION_LETTER + "/get-intro-letter-template";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INTRO_LETTER, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(patId, reportCd));
    // wp アプリケーションログの適正化 Add End
	  try {
			MstReport mstReport = mstReportDao.selectByReportCd(reportCd);
			if (mstReport != null) {

        /* del by gaojuncheng  2023-02-01 [CodeOptimization]  start */
//				Optional<OrdMain> ordMain = ordMainDao.selectItemByPatId(patId);
//				Map<String, Object> dataKey = new HashMap<>();
//
//				if (ordMain.isPresent()) {
//					dataKey.put("ordNo", Math.toIntExact(ordMain.get().getOrdNo()));
//				} else {
//					dataKey.put("ordNo", 0);
//				}
////        add 紹介状に指示内容が表示されない 6371  関 start
//        Date date = new Date();
//        String today = new SimpleDateFormat("yyyyMMdd").format(date);
////        mod 7939 7163 紹介状に患者情報が表示されない 関 start
////        dataKey.put("date", today);
//        dataKey.put("fromDate", today);
////        mod 7939 7163 紹介状に患者情報が表示されない 関 end
////        add 紹介状に指示内容が表示されない 6371  関 end
//				dataKey.put("patId", patId);
//				dataKey.put("login", ntssUser.getUsername());
//        // add 7939 紹介状に患者情報が表示されない 吉 start
//        dataKey.put("date", today);
//        dataKey.put("facilityCd", ntssUser.getFacilityCd());
//        // add 7939 紹介状に患者情報が表示されない 吉 end
//
//        // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
//        Map<String,List> searchList =this.searchMap(ntssUser.getFacilityCd());
//        dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS,searchList.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
//        dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS,searchList.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
//        dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,searchList.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
//        // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
//
//				String html = reportService.getIntroLetterReportHtml(reportCd, dataKey, null, null);
//				Map<String, Object> responseData = new HashMap<String, Object>();
//				responseData.put("htmlTemplate", html.toString());
        /* del by gaojuncheng  2023-02-01 [CodeOptimization]  end */

        /* add by gaojuncheng  2023-02-01 [CodeOptimization]  start */
        // add #12462 患者情報共有 zhao start
        Long realPatId = patId;
        // 施設が一致していない場合、他施設の患者IDを取得する
        if(!ntssUser.getFacilityCd().equals(mstReport.getFacilityCd())){
          List<ShrPatInfo> shrPatInfoList = patIntroductionLetterService.getShrPatInfoForPatId(patId, ntssUser.getFacilityCd());
          if (shrPatInfoList != null && !shrPatInfoList.isEmpty()) {
            for(ShrPatInfo shrPatInfo: shrPatInfoList){
              if(mstReport.getFacilityCd().equals(shrPatInfo.getFromFacilityCd())){
                realPatId = shrPatInfo.getFromPatId();
                break;
              }
            }
          }
        }
        // add #12462 患者情報共有 zhao end
        // mod 11488 紹介状登録内容保存時に帳票の版も記憶する　1.1A  吉 start
        // Map<String, Object> responseData = patIntroductionLetterService.getIntroLetterTemplate(mstReport, patId, reportCd, ntssUser);
        // mod #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao start
        // Map<String, Object> responseData = patIntroductionLetterService.getIntroLetterTemplate(mstReport, patId, reportCd, ntssUser,ctlNo,isUpdate);
        // mod #12462 患者情報共有 zhao start
        //Map<String, Object> responseData = patIntroductionLetterService.getIntroLetterTemplate(mstReport, patId, reportCd, ntssUser,ctlNo,isUpdate, reportStartDate);
        Map<String, Object> responseData = patIntroductionLetterService.getIntroLetterTemplate(mstReport, realPatId, reportCd, ntssUser,ctlNo,isUpdate, reportStartDate);
        // mod #12462 患者情報共有 zhao end
        // mod #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao end
        boolean isHaveCtl = true;
        if("1".equals(isUpdate)){
          MstReport.ReportHstInfo hstInfo = mstReport.getReportHstInfo();
          MstReport.Item item = hstInfo.getItems().get(hstInfo.getItems().size()-1);
          responseData.put("ctlNo",item.getCtlNo());
          isHaveCtl = false;
        }
        if(!"".equals(ctlNo) && !"undefined".equals(ctlNo)){
          responseData.put("ctlNo",ctlNo);
          isHaveCtl = false;
        }
        if(isHaveCtl){
          MstReport.ReportHstInfo rph = mstReport.getReportHstInfo();
          for(MstReport.Item item : rph.getItems()){
            if("1".equals(item.getIsSelect())){
              responseData.put("ctlNo", item.getCtlNo());
            }
          }
        }
        // mod 11488 紹介状登録内容保存時に帳票の版も記憶する　1.1A  吉 end
        /* add by gaojuncheng  2023-02-01 [CodeOptimization]  end */

        // wp アプリケーションログの適正化 Add Start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INTRO_LETTER, AFTER_LOG_FLG_INFO, mappingUrl, null,
          Arrays.asList(patId, reportCd));
        // wp アプリケーションログの適正化 Add End
        // add #12650 登録済み紹介状が帳票マスタ削除の影響を受けるのは不適切 zhao start
        responseData.put("reportIsDel", mstReport.getIsDel());
        // add #12650 登録済み紹介状が帳票マスタ削除の影響を受けるのは不適切 zhao end

				return new ResponseEntity<>(responseData, HttpStatus.OK);

			}
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INTRO_LETTER, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(patId, reportCd));
      // wp アプリケーションログの適正化 Add End
			return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.BAD_REQUEST);
		} catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
//			EventLogMessage eventLogMessage = new EventLogMessage();
//			eventLogMessage.setLogMessage(e.getMessage());
//			logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_PAT_INTRO_LETTER,SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INTRO_LETTER, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
			return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.BAD_REQUEST);
		}
	}

	/**
	 * 紹介状の印刷
	 *
	 * @param payload
	 * @return
	 */
	@PostMapping("/print-report")
  /*mod FNSI-改修内容マスタ画面の修正に伴い、紐付ける帳票を一括印刷するように修正 任 start*/
  /*public ResponseEntity<?> printReport(@RequestBody Map<String, Object> payload) {
    String introductionHtml = String.valueOf(payload.get("htmlTemplate").toString());
    if (introductionHtml.equals("")) {*/
	public ResponseEntity<?> printReport(@RequestBody Map<String, Object> payload,@AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.PAT_INTRODUCTION_LETTER + "/print-report";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INTRO_LETTER, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    /* del by gaojuncheng  2023-02-01 [CodeOptimization]  start */
//    //add  Aspose.cells plug-in integration  吉 start
//    FacilitySettingInfo settingValue = mstFacilitySettingDao.getBySettingNoAndCd(ntssUser.getFacilityCd(),CoreConstant.FacilitySettingNo.PREVIEW_MODE);
//    if(settingValue != null && settingValue.getValue().equals("0")){
//      // new
//      Map<String, String> outPutHtml = new HashMap<>();
//      org.jsoup.nodes.Document document = Jsoup.parse(String.valueOf(payload.get("htmlTemplate").toString()));
//      Elements links = document.getElementsByTag("tbody").first().getElementsByTag("td");
//      for (Element link : links) {
//        String linkHref = link.attr("id");
//        String linkText = link.text();
//        if(!linkHref.isEmpty()){
//          outPutHtml.put(linkHref,linkText);
//        }
//      }
//      Long reportCd = Long.parseLong(payload.get("reportCd").toString());
//      MstReport mstReport = mstReportDao.selectByCd(reportCd);
//      ReportMenuSortContainer dakeMap = new ReportMenuSortContainer();
//      Map<String, Object> dataKey =  new HashMap<>();
//      dataKey.put("IntroLetterReportPrinte",true);
//      dataKey.put("htmlTemplate",outPutHtml);
//      SimpleDateFormat sdf  = new SimpleDateFormat("yyyyMMdd");
//      //add  Aspose.cells plug-in integration  吉 start
//      Map<String,List> searchList =this.searchMap(ntssUser.getFacilityCd());
//      dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD,ntssUser.getFacilityCd());
//      dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,searchList.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
//      dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS,searchList.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
//      dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS,searchList.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
//      dataKey.put(ReportConstant.ReportDataKey.PAT_ID,Long.valueOf(payload.get("patId").toString()));
//      LocalDate nowDate = LocalDate.now();
//      dataKey.put(ReportConstant.ReportDataKey.DATE_FROM,nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
//      dataKey.put(ReportConstant.ReportDataKey.DATE_TO,nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
//      dataKey.put(ReportConstant.ReportDataKey.treatDate,nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
//      dataKey.put(ReportConstant.ReportDataKey.treatDate,reportCd);
//      Optional<OrdMain> ordMain = ordMainDao.selectItemByPatId(Long.valueOf(payload.get("patId").toString()));
//      if (ordMain.isPresent()) {
//        dataKey.put("ordNo", Long.valueOf(Math.toIntExact(ordMain.get().getOrdNo())));
//      } else {
//        dataKey.put("ordNo", 0L);
//      }
//      dataKey.put("reportClass",mstReport.getReportClass());
//      try {
//        Map<String,byte[]> byteMap = new HashMap<>();
//        byte[] excelBytes = reportService.getReportExcelFile(reportCd, dataKey);
//        byteMap.put("ReferralLetter",excelBytes);
//        if(payload.get("dispItemInfo")!=null){
//          JSONArray jsonArray = new JSONArray(payload.get("dispItemInfo").toString());
//          if(jsonArray.length() > 0){
//            for(int i = 0;i < jsonArray.length();i++){
//              JSONObject jsonObj = jsonArray.getJSONObject(i);
//              if(jsonObj.has("reportCd") || ( jsonObj.has("times") && !StringUtils.isEmpty(jsonObj.getString("times")) && jsonObj.getInt("times") > 0) ){
//                StringBuilder html = new StringBuilder();
//                dataKey = new HashMap<>();
//                dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS,searchList.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
//                dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS,searchList.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
//                dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,searchList.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
//                Integer itemNo = jsonObj.getInt("itemNo");
//                dataKey.put("login", ntssUser.getUsername());
//                dataKey.put("facilityCd", ntssUser.getFacilityCd());
//                if(itemNo.equals(ReportConstant.ReportClass.DIALYSIS_REPORT)){
//                  dataKey.put("patId", payload.get("patId").toString());
//                }else if(itemNo.equals(ReportConstant.ReportClass.LABEL_REPORT) ||
//                  itemNo.equals(ReportConstant.ReportClass.DISTRIBUTION_LIST_BED_REPORT) ||
//                  itemNo.equals(ReportConstant.ReportClass.PREPARATION_LIST_REPORT)){
//                  dataKey.put(ReportConstant.ReportDataKey.treatDate, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
//                  String nowYYYYMMDD = nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd"));
//                  OrdMain near = reportMenuDao.selectNearOrdPlan(Long.valueOf(payload.get("patId").toString()), nowYYYYMMDD);
//                  dataKey.put(ReportConstant.ReportDataKey.ORD_NOS,Collections.singletonList(near == null ? 0 : near.getOrdNo()));
//                  List<Long> list = new ArrayList();
//                  list.add(Long.parseLong(payload.get("patId").toString()));
//                  dataKey.put("patIds", list);
//                }else{
//                  Calendar c =Calendar.getInstance();
//                  c.setTime(new Date());
//                  c.add(Calendar.DATE , -7);
//                  Date d = c.getTime();
//                  dataKey.put(ReportConstant.ReportDataKey.treatDate, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
//                  dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
//                  dataKey.put(ReportConstant.ReportDataKey.DATE_TO, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
//                  dataKey.put(ReportConstant.ReportDataKey.DATE, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
//                  dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD, ntssUser.getFacilityCd());
//                  List<OrdMain>ordList = reportMenuDao.selectResultByTreatDate(Long.valueOf(payload.get("patId").toString()),null, sdf.format(d) , nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
//                  List<Map<String, Object>> tmplParams = new ArrayList<Map<String, Object>>();
//                  if(null != ordList && ordList.size()>0){
//                    for(OrdMain om : ordList){
//                      Map<String, Object> tmplParam = new HashMap<>();
//                      tmplParam.put(ReportConstant.ReportDataKey.MEDICINE_IDS,searchList.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
//                      tmplParam.put(ReportConstant.ReportDataKey.DIALYZER_IDS,searchList.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
//                      tmplParam.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,searchList.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
//                      tmplParam.put(ReportConstant.ReportDataKey.treatDate, om.getTreatDate());
//                      tmplParam.put(ReportConstant.ReportDataKey.DATE_FROM, sdf.format(d));
//                      tmplParam.put(ReportConstant.ReportDataKey.DATE_TO, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
//                      tmplParam.put(ReportConstant.ReportDataKey.DATE, om.getTreatDate());
//                      tmplParam.put(ReportConstant.ReportDataKey.PAT_ID, payload.get("patId").toString());
//                      tmplParam.put(ReportConstant.ReportDataKey.ORD_NO,om.getOrdNo());
//                      tmplParam.put(ReportConstant.ReportDataKey.FACILITY_CD, ntssUser.getFacilityCd());
//                      tmplParams.add(tmplParam);
//                    }
//                  }
//                  dataKey.put(ReportConstant.ReportDataKey.TEMPLATE_PARAMS, tmplParams);
//                }
//                if(itemNo == 1){
//                  List<Long> reportCds = ordMainDao.selectReportCd(ntssUser.getFacilityCd(),Long.parseLong(payload.get("patId").toString()), jsonObj.has("times") ? jsonObj.getInt("times") : null);
//                  List<Long> orderNo = ordMainDao.selectOrdnoByPatIdNear(ntssUser.getFacilityCd(),Long.parseLong(payload.get("patId").toString()), jsonObj.has("times") ? jsonObj.getInt("times") : null);
//                  if(reportCds.size()>0){
//                    dataKey.put(ReportConstant.ReportDataKey.treatDate, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
//                    dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
//                    dataKey.put(ReportConstant.ReportDataKey.DATE_TO, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
//                    dataKey.put(ReportConstant.ReportDataKey.DATE, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
//                    for(int k = 0;k<reportCds.size();k++){
//                      dataKey.put(ReportConstant.ReportDataKey.ORD_NO,orderNo.get(k));
//                      excelBytes= reportService.getReportExcelFile(reportCds.get(k), dataKey);
//                      String reportName= reportNameChange(itemNo);
//                      byteMap.put(reportName,excelBytes);
//                    }
//                  }
//                }else{
//                  Long reportCds = jsonObj.getLong("reportCd");
//                  excelBytes = reportService.getReportExcelFile(reportCds, dataKey);
//                  String reportName= reportNameChange(itemNo);
//                  byteMap.put(reportName,excelBytes);
//                }
//              }
//            }
//          }
//        }
//        for (Map.Entry<String,byte[]> entry : byteMap.entrySet()) {
//          if (entry.getValue().length > 0) {
//            ByteArrayInputStream excelByesIS = new ByteArrayInputStream(entry.getValue());
//            ByteArrayOutputStream excelBytesOS = new ByteArrayOutputStream();
//            URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
//            AsposeCellsUtils.excelToPdf(excelByesIS,excelBytesOS,url);
//            byteMap.put(entry.getKey(),excelBytesOS.toByteArray());
//          }
//        }
//        String reportName = "IntroductionLetter";
//        if (!StringUtils.isEmpty(mstReport)) {
//          if(StringUtils.isEmpty(mstReport.getDefaultPrinter())){
//            List<FacilitySettingInfo> settingInfoList = mstFacilitySettingDao.selectFacilitySetting(ntssUser.getFacilityCd(), CoreConstant.FacilitySettingNo.DEFAULT_PRINTER);
//            if(null != settingInfoList && settingInfoList.size()>0 && null != settingInfoList.get(0).getValue()){
//              String defaulPrinter = settingInfoList.get(0).getValue();
//              mstReport.setDefaultPrinter(Long.valueOf(defaulPrinter));
//            }
//          }
//        }
//        reportMenuService.IntroductionLetterPrintPdfReport(byteMap,reportName, mstReport.getDefaultPrinter());
//        return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
//      } catch (Exception e) {
//        e.printStackTrace();
//      }
//      return new ResponseEntity<>("", HttpStatus.INTERNAL_SERVER_ERROR);
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
//          if(jsonObj.has("reportCd") || ( jsonObj.has("times") && !StringUtils.isEmpty(jsonObj.getString("times")) && jsonObj.getInt("times") > 0) ){
//            StringBuilder html = new StringBuilder();
//            Map<String, Object> dataKey = new HashMap<>();
//            // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
//            dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS,searchList.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
//            dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS,searchList.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
//            dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,searchList.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
//            // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
//            Integer itemNo = jsonObj.getInt("itemNo");
//            dataKey.put("login", ntssUser.getUsername());
//            dataKey.put("facilityCd", ntssUser.getFacilityCd());
//            // mod 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 start
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
//            if(itemNo.equals(ReportConstant.ReportClass.DIALYSIS_REPORT)){
//              dataKey.put("patId", payload.get("patId").toString());
//            }else if(itemNo.equals(ReportConstant.ReportClass.LABEL_REPORT) ||
//              itemNo.equals(ReportConstant.ReportClass.DISTRIBUTION_LIST_BED_REPORT) ||
//                itemNo.equals(ReportConstant.ReportClass.PREPARATION_LIST_REPORT)){
//              LocalDate nowDate = LocalDate.now();
//              dataKey.put(ReportConstant.ReportDataKey.treatDate, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
//              String nowYYYYMMDD = nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd"));
//              OrdMain near = reportMenuDao.selectNearOrdPlan(Long.valueOf(payload.get("patId").toString()), nowYYYYMMDD);
//              dataKey.put(ReportConstant.ReportDataKey.ORD_NOS,Collections.singletonList(near == null ? 0 : near.getOrdNo()));
//              List<Long> list = new ArrayList();
//              list.add(Long.parseLong(payload.get("patId").toString()));
//              dataKey.put("patIds", list);
//            }else{
//              Calendar c =Calendar.getInstance();
//              c.setTime(new Date());
//              c.add(Calendar.DATE , -7);
//              Date d = c.getTime();
//              LocalDate nowDate = LocalDate.now();
//              dataKey.put(ReportConstant.ReportDataKey.treatDate, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
//              dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
//              dataKey.put(ReportConstant.ReportDataKey.DATE_TO, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
//              dataKey.put(ReportConstant.ReportDataKey.DATE, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
//              dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD, ntssUser.getFacilityCd());
//              SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd ");
//              List<OrdMain>ordList = reportMenuDao.selectResultByTreatDate(Long.valueOf(payload.get("patId").toString()),null, sdf.format(d) , nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
//              List<Map<String, Object>> tmplParams = new ArrayList<Map<String, Object>>();
//              if(null != ordList && ordList.size()>0){
//                for(OrdMain om : ordList){
//                  Map<String, Object> tmplParam = new HashMap<>();
//                  tmplParam.put(ReportConstant.ReportDataKey.MEDICINE_IDS,searchList.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
//                  tmplParam.put(ReportConstant.ReportDataKey.DIALYZER_IDS,searchList.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
//                  tmplParam.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,searchList.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
//                  // mod 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 start
//                  // tmplParam.put(ReportConstant.ReportDataKey.treatDate, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
//                  tmplParam.put(ReportConstant.ReportDataKey.treatDate, om.getTreatDate());
//                  // mod 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 end
//                  tmplParam.put(ReportConstant.ReportDataKey.DATE_FROM, sdf.format(d));
//                  tmplParam.put(ReportConstant.ReportDataKey.DATE_TO, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
//                  // mod 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 start
//                  // tmplParam.put(ReportConstant.ReportDataKey.DATE, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
//                  tmplParam.put(ReportConstant.ReportDataKey.DATE, om.getTreatDate());
//                  // mod 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 end
//                  tmplParam.put(ReportConstant.ReportDataKey.PAT_ID, payload.get("patId").toString());
//                  tmplParam.put(ReportConstant.ReportDataKey.ORD_NO,om.getOrdNo());
//                  tmplParam.put(ReportConstant.ReportDataKey.FACILITY_CD, ntssUser.getFacilityCd());
//                  tmplParams.add(tmplParam);
//                }
//              }
//              dataKey.put(ReportConstant.ReportDataKey.TEMPLATE_PARAMS, tmplParams);
//            }
//            // mod 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 end
//            if(itemNo == 1){
//              // mod FNSI-改修内容#6023 周 start
//              //List<Long> reportCd = ordMainDao.selectReportCd(Long.parseLong(payload.get("patId").toString()),jsonObj.getInt("times"));
//              // mod 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 start
//              // List<Long> reportCd = ordMainDao.selectReportCd(Long.parseLong(payload.get("patId").toString()), jsonObj.has("times") ? jsonObj.getInt("times") : null);
//              List<Long> reportCd = ordMainDao.selectReportCd(ntssUser.getFacilityCd(),Long.parseLong(payload.get("patId").toString()), jsonObj.has("times") ? jsonObj.getInt("times") : null);
//              // add 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 start
//              List<Long> orderNo = ordMainDao.selectOrdnoByPatIdNear(ntssUser.getFacilityCd(),Long.parseLong(payload.get("patId").toString()), jsonObj.has("times") ? jsonObj.getInt("times") : null);
//              // add 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 end
//              // mod 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 end
//              // mod FNSI-改修内容#6023 周 end
//              if(reportCd.size()>0){
//                // add 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 start
//                LocalDate nowDate = LocalDate.now();
//                dataKey.put(ReportConstant.ReportDataKey.treatDate, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
//                dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
//                dataKey.put(ReportConstant.ReportDataKey.DATE_TO, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
//                dataKey.put(ReportConstant.ReportDataKey.DATE, nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")));
//                // add 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 end
//                for(int k = 0;k<reportCd.size();k++){
//                  // add 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 start
//                  dataKey.put(ReportConstant.ReportDataKey.ORD_NO,orderNo.get(k));
//                  // add 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 end
//                  html.append(reportService.getReportHtml(reportCd.get(k), dataKey, null, null));
//                }
//              }
//            }else{
//              Long reportCd = jsonObj.getLong("reportCd");
//              html = new StringBuilder(reportService.getReportHtml(reportCd, dataKey, null, null));
//            }
//            /*mod FNSI-改修内容4608 任 end*/
//            introductionHtml.append(html);
//          }
//        }
//      }
//    }
//		String htmlResult = "";
//    if(introductionHtml.toString()!=null){
//      String htmlString[] = introductionHtml.toString().split("<tbody>");
//      if(htmlString.length>2){
//        htmlResult = htmlString[0] + "<tbody>";
//        for(int i = 1 ;i < htmlString.length;i++){
//          if(i<htmlString.length-1){
//            htmlResult += htmlString[i] + "<div style=\"page-break-after: always;\"></div><tbody>";
//          }else{
//            htmlResult += htmlString[i];
//          }
//        }
//      }else{
//        htmlResult = introductionHtml.toString();
//      }
//    }
//		if (introductionHtml.toString().equals("")) {
//      /*mod FNSI-改修内容マスタ画面の修正に伴い、紐付ける帳票を一括印刷するように修正 任 end*/
//
//      // wp アプリケーションログの適正化 Add Start
//      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INTRO_LETTER, AFTER_LOG_FLG_INFO, mappingUrl, null,
//        null);
//      // wp アプリケーションログの適正化 Add End
//			return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.BAD_REQUEST);
//		}
//		String reportName = "IntroductionLetter";
//		Long reportCd = Long.parseLong(payload.get("reportCd").toString());
//		Long patId = Long.parseLong(payload.get("patId").toString());
//		MstReport mstReport = mstReportDao.selectByCd(reportCd);
//		try {
//			if (!StringUtils.isEmpty(mstReport)) {
//        // add 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 start
//			  if(StringUtils.isEmpty(mstReport.getDefaultPrinter())){
//          List<FacilitySettingInfo> settingInfoList = mstFacilitySettingDao.selectFacilitySetting(ntssUser.getFacilityCd(), CoreConstant.FacilitySettingNo.DEFAULT_PRINTER);
//          if(null != settingInfoList && settingInfoList.size()>0 && null != settingInfoList.get(0).getValue()){
//            String defaulPrinter = settingInfoList.get(0).getValue();
//            mstReport.setDefaultPrinter(Long.valueOf(defaulPrinter));
//          }
//        }
//        // add 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 end
//        /*mod FNSI-改修内容マスタ画面の修正に伴い、紐付ける帳票を一括印刷するように修正 任 start*/
//        /*patIntroductionLetterService.printReport(introductionHtml, reportName, mstReport, patId);*/
//				patIntroductionLetterService.printReport(htmlResult, reportName, mstReport, patId);
//        /*mod FNSI-改修内容マスタ画面の修正に伴い、紐付ける帳票を一括印刷するように修正 任 end*/
//			}
//
//      // wp アプリケーションログの適正化 Add Start
//      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INTRO_LETTER, AFTER_LOG_FLG_INFO, mappingUrl, null,
//        null);
//      // wp アプリケーションログの適正化 Add End
//			return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
//		} catch (Exception e) {
//
//      // wp アプリケーションログの適正化 Add Start
//      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INTRO_LETTER, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
//      // wp アプリケーションログの適正化 Add End
//
//        return new ResponseEntity<>(e.toString(), HttpStatus.INTERNAL_SERVER_ERROR);
//      }
//      //add  Aspose.cells plug-in integration  吉 start
//    }
//    //add  Aspose.cells plug-in integration  吉 end
    /* del by gaojuncheng  2023-02-01 [CodeOptimization]  end */

    /* add by gaojuncheng  2023-02-01 [CodeOptimization]  start */
    return patIntroductionLetterService.printReport(payload, ntssUser, mappingUrl);
    /* add by gaojuncheng  2023-02-01 [CodeOptimization]  start */

  }


  /* del by gaojuncheng  2023-02-01 [CodeOptimization]  start */
//  //add  Aspose.cells plug-in integration  吉 start
//	public String reportNameChange(Integer reportClass){
//	  String reportName ="";
//	  switch (reportClass){
//      case 1 :
//        reportName="Dialysis";
//        break;
//      case 2 :
//        reportName="OnePatient";
//        break;
//      case 3 :
//        reportName="MultiPatient";
//        break;
//      case 4 :
//        reportName="EquipmentList";
//        break;
//      case 5 :
//        reportName="DistributeListBed";
//        break;
//      case 6 :
//        reportName="DistributeListEquipment";
//        break;
//      case 7 :
//        reportName="Device";
//        break;
//      case 8 :
//        reportName="Label";
//        break;
//      case 9 :
//        reportName="ReferralLetter";
//        break;
//      case 10 :
//        reportName="OneTotal";
//        break;
//      case 11 :
//        reportName="MultiTotal";
//        break;
//      default:
//        reportName = "";
//        break;
//    }
//    return reportName;
//  }
//  //add  Aspose.cells plug-in integration  吉 end
  /* del by gaojuncheng  2023-02-01 [CodeOptimization]  end */

	/**
	 * 患者情報の更新
	 *
	 * @param payload
	 * @return
	 */
	@PostMapping("/sync-patient-information")
	public ResponseEntity<?> syncPatientInformation(@RequestBody Map<String, Object> payload) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.PAT_INTRODUCTION_LETTER + "/sync-patient-information";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INTRO_LETTER, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

		try {

      /* del by gaojuncheng  2023-02-01 [CodeOptimization]  start */
//			Long reportCd = Long.parseLong(payload.get("reportCd").toString());
//			Long patId = Long.parseLong(payload.get("patId").toString());
//
//			Map<String, String> mapKeyPatInfo = objectMapper.convertValue(payload.get("letterData"), Map.class);
//
//			MstReport mstReport = mstReportDao.selectByCd(reportCd);
//			if (!StringUtils.isEmpty(mstReport)) {
//
//				byte[] zipFile = reportS3Service.getReportFile(mstReport.getReportPath().getBucket(),
//						mstReport.getReportPath().getReportZip(), null);
//
//				ReportZipFile reportZipFile = new ReportZipFile(zipFile);
//
//				String reportXml = reportZipFile.getFileToString(mstReport.getReportPath().getXmlFilename());
//
//				reportXml = reportXml.trim().replaceFirst("^([\\W]+)<", "<");
//
//				List<ReportXmlParam> parserXml = ReportUtils.getParamElements(reportXml);
//				Map<String, String> keyMapPatInfo = new HashMap<String, String>();
//
//				for (int i = 0; i < parserXml.size(); i++) {
//					for (Entry<String, String> entryMapKeyPatInfo : mapKeyPatInfo.entrySet()) {
//						if (parserXml.get(i).getId().equals(entryMapKeyPatInfo.getKey())) {
//							keyMapPatInfo.put(parserXml.get(i).getDataCode(), entryMapKeyPatInfo.getValue());
//						}
//					}
//				}
//        /*add FNSI-改修内容紹介状登録と編集画面改修四つボタン改修 任 start*/
//        for(Map.Entry<String, String> entry : keyMapPatInfo.entrySet()){
//          String mapValue = entry.getValue();
//          String mapKey = entry.getKey();
//          if("pat_sex".equals(mapKey)){
//            if(mapValue.contains("男")){
//              entry.setValue("1");
//            }else if(mapValue.contains("女")){
//              entry.setValue("2");
//            }else if(mapValue.contains("不明")||"".equals(mapValue)){
//              entry.setValue("0");
//            }else{
//              Map<String, String> resp = new HashMap<String, String>();
//              resp.put("msg","false");
//
//              // wp アプリケーションログの適正化 Add Start
//              logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INTRO_LETTER, AFTER_LOG_FLG_INFO, mappingUrl, null,
//                null);
//              // wp アプリケーションログの適正化 Add End
//              return new ResponseEntity<>(resp, HttpStatus.OK);
//            }
//          }
//          if("pat_birthday".equals(mapKey)){
//            SimpleDateFormat sm = new SimpleDateFormat("yyyyMMdd");
//            if(mapValue.matches("\\d{4}\\d{2}\\d{2}")){
//              entry.setValue(sm.format(sm.parse(mapValue)));
//            }else if(mapValue.matches("\\d{4}[/]\\d{2}[/]\\d{2}")){
//              SimpleDateFormat smFormat = new SimpleDateFormat("yyyy/MM/dd");
//              entry.setValue(sm.format(smFormat.parse(mapValue)));
//            }else if(!"".equals(mapValue)){
//              Map<String, String> resp = new HashMap<String, String>();
//              resp.put("msg","dateFalse");
//
//              // wp アプリケーションログの適正化 Add Start
//              logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INTRO_LETTER, AFTER_LOG_FLG_INFO, mappingUrl, null,
//                null);
//              // wp アプリケーションログの適正化 Add End
//              return new ResponseEntity<>(resp, HttpStatus.OK);
//            }
//          }
//          /*add FNSI-改修内容患者イベント外结No.6 任 start*/
//          if("in_out_class".equals(mapKey)){
//            if(mapValue.contains("外来")){
//              entry.setValue("0");
//            }else if(mapValue.contains("入院")){
//              entry.setValue("1");
//            }else if(mapValue.contains("死亡")) {
//              entry.setValue("2");
//            }else if(mapValue.contains("不在")){
//              entry.setValue("3");
//            }else{
//              Map<String, String> resp = new HashMap<String, String>();
//              resp.put("msg","inOutClassFalse");
//              logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INTRO_LETTER, AFTER_LOG_FLG_INFO, mappingUrl, null,
//                null);
//              return new ResponseEntity<>(resp, HttpStatus.OK);
//            }
//          }
//          /*add FNSI-改修内容患者イベント外结No.6 任 end*/
//        }
//        /*add FNSI-改修内容紹介状登録と編集画面改修四つボタン改修 任 end*/
//				PatPersonalMain patPersonalMain = objectMapper.readValue(objectMapper.writeValueAsString(keyMapPatInfo),
//						PatPersonalMain.class);
//
//				patIntroductionLetterService.updatePatientInfo(patId, patPersonalMain);
//			}
//
//      // wp アプリケーションログの適正化 Add Start
//      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INTRO_LETTER, AFTER_LOG_FLG_INFO, mappingUrl, null,
//        null);
//      // wp アプリケーションログの適正化 Add End
//			return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
      /* del by gaojuncheng  2023-02-01 [CodeOptimization]  end */

      /* add by gaojuncheng  2023-02-01 [CodeOptimization]  start */
      return patIntroductionLetterService.syncPatientInformation(payload, mappingUrl);
      /* add by gaojuncheng  2023-02-01 [CodeOptimization]  end */

		} catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
//			EventLogMessage eventLogMessage = new EventLogMessage();
//			eventLogMessage.setLogMessage(e.getMessage());
//			logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_PAT_INTRO_LETTER,SERVICE_NAME.FNSI, null);
      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INTRO_LETTER, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
			return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
		}
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

  /* del by gaojuncheng  2023-02-01 [CodeOptimization]  start */
//  // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
//  public Map<String,List> searchMap (String facilityCd){
//    Map<String,List>map= new HashMap<>();
//    // ダイアライザマスタ
//    List<MstDialyzer> dialyzerList = mstInfoService.findMstDialyzerAllByFacillityCd(facilityCd);
//    if(null != dialyzerList && dialyzerList.size()>0){
//      List<Integer>list =new ArrayList<>();
//      for(MstDialyzer dl : dialyzerList){
//        list.add(dl.getDialyzerCd());
//      }
//      map.put(ReportConstant.ReportDataKey.DIALYZER_IDS,list);
//    }else{
//      map.put(ReportConstant.ReportDataKey.DIALYZER_IDS,new ArrayList());
//    }
//    // 医療材料分類
//    MstEquipmentClass params = new MstEquipmentClass();
//    params.setFacilityCd(facilityCd);
//    List<MstEquipmentClass> mstEquipmentClassList = mstEquipmentClassDao.selectAll(SelectOptions.get(), params);
//    if(null != mstEquipmentClassList && mstEquipmentClassList.size()>0){
//      List<Integer>list =new ArrayList<>();
//      // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
//      list.add(-1);
//      // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
//      for(MstEquipmentClass mec : mstEquipmentClassList){
//        list.add(mec.getClassCd());
//      }
//      // mod 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
//      // map.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,mstEquipmentClassList);
//      map.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,list);
//      // mod 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
//    }else{
//      map.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,new ArrayList());
//    }
//
//    // 薬剤分類
//    MstMedicineClass medicineClass = new MstMedicineClass();
//    medicineClass.setFacilityCd(facilityCd);
//    List<MstMedicineClass> mstMedicineClassList = mstMedicineClassDao.selectAll(SelectOptions.get(),medicineClass);
//    if(null != mstEquipmentClassList && mstEquipmentClassList.size()>0){
//      List<Integer>list =new ArrayList<>();
//      // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
//      list.add(-1);
//      // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
//      for(MstMedicineClass mdc : mstMedicineClassList){
//        list.add(mdc.getClassCd());
//      }
//      // mod 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
//      // map.put(ReportConstant.ReportDataKey.MEDICINE_IDS,mstMedicineClassList);
//      map.put(ReportConstant.ReportDataKey.MEDICINE_IDS,list);
//      // mod 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
//    }else{
//      map.put(ReportConstant.ReportDataKey.MEDICINE_IDS,new ArrayList());
//    }
//    return map;
//  }
//  // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
  /* del by gaojuncheng  2023-02-01 [CodeOptimization]  end */

}
