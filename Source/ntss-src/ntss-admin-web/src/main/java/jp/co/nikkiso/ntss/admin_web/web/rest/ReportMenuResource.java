package jp.co.nikkiso.ntss.admin_web.web.rest;

import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.PatInfoService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.print.PrinterService;
import jp.co.nikkiso.ntss.admin_web.service.reportMenu.ReportMenuService;
import jp.co.nikkiso.ntss.api.constant.ReportConstant;
import jp.co.nikkiso.ntss.api.service.report.ReportService;
import jp.co.nikkiso.ntss.api.service.report.ReportServiceImpl;
import jp.co.nikkiso.ntss.api.service.utils.AsposeCellsUtils;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.SysSystemDefineDao;
import jp.co.nikkiso.ntss.core.entity.MstReport;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import jp.co.nikkiso.ntss.core.entity.custom.ReportMenuSortContainer;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ResourceLoader;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.net.URL;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;

/**
 * 帳票出力
 *
 */
@RestController
@RequestMapping(Uri.REPORT_MENU)
public class ReportMenuResource {

	@Autowired
	ReportMenuService reportMenuService;

	@Autowired
	ReportService reportService;

	@Autowired
  LogService logService;

  //add IES因島）sql性能試験 後で削除 liuc start
  @Autowired
  private jp.co.nikkiso.ntss.api.service.LogService testLogService;
  //add IES因島）sql性能試験 後で削除 liuc end

  /*add FNSI-改修内容帳票保存の時のファイル名が重複してしまう 任 start*/
  @Autowired
  private PatPersonalMainDao patPersonalMainDao;
  /*add FNSI-改修内容帳票保存の時のファイル名が重複してしまう 任 end*/
  //add 4748 5269 5402治療方法ごとの治療経過表での出力ができない  吉 start
  @Autowired
  private PatInfoService patInfoService;
  //add 4748 5269 5402治療方法ごとの治療経過表での出力ができない  吉 end
  // add 2020-09-30 FNSI-改修 複数データ対象の帳票の場合の切替 夏 start
  // 患者IDのリスト
//  public List<Long> patIds = new ArrayList<Long>();
  //add 8507 2023-4-3 zhaoqj patIdグローバル変数方式をmapストレージkeyからuserIdに変更 start
//  public Map<Long,List<Long>> patIdsMap = new HashMap<>();
  //add 8507 2023-4-3 zhaoqj patIdグローバル変数方式をmapストレージkeyからuserIdに変更 end

  // 生成した帳票html
  //del 8507 2023-4-3 zhaoqj patIdグローバル変数方式をmapストレージkeyからuserIdに変更 start
//  public String reportHtmls = new String();
  //del 8507 2023-4-3 zhaoqj patIdグローバル変数方式をmapストレージkeyからuserIdに変更 end
  // add 2020-09-30 FNSI-改修 複数データ対象の帳票の場合の切替 夏 end

  // add 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 start
  @Autowired
  private MstFacilitySettingDao mstFacilitySettingDao;
  // add 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 end
  @Autowired
  ResourceLoader resourceLoader;
  // add 8542 紹介状（集計あり。因島様にて使用）にて出力できない項目がある 吉 start
  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;
  // add 8542 紹介状（集計あり。因島様にて使用）にて出力できない項目がある 吉 end

  //add #9616 帳票印刷失敗通知がされない 李 start
  @Autowired
  PrinterService printerService;
  //add #9616 帳票印刷失敗通知がされない 李 end

 // add #10633 【たくしん会】帳票のフォント問題 吉 start
  @Autowired
  private SysSystemDefineDao sysSystemDefineDao;
  // add #10633 【たくしん会】帳票のフォント問題 吉 end

  /**
   * 指定された条件で帳票htmlを取得する.
   *
   * @param option 操作種類
   * @param count 表示データ個数
   * @param payload 帳票生成の為に必要なパラメータ
   * @param ntssUser 利用者情報
   * @return 生成した帳票html
   */
  // upd 2020-09-30 FNSI-改修 複数データ対象の帳票の場合の切替 夏 start
  //@PostMapping("/getReportHtml")
  @PostMapping("/getReportHtml/{option}/{count}")
  // upd 2020-09-30 FNSI-改修 複数データ対象の帳票の場合の切替 夏 end
  public ResponseEntity<String> getReportHtml(
    @RequestBody ReportMenuSortContainer payload,
    // add 2020-09-30 FNSI-改修 複数データ対象の帳票の場合の切替 夏 start
    @PathVariable Integer option,
    @PathVariable Integer count,
    // add 2020-09-30 FNSI-改修 複数データ対象の帳票の場合の切替 夏 end
    @AuthenticationPrincipal NtssUser ntssUser
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
    if(!ntssUser.isNkkAdminUser()) {
      if (payload.getFacilityCd() != null && !payload.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + payload.getFacilityCd() + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 end

    //add IES因島）sql性能試験 後で削除 liuc start
    Date beginTime = new Date();
    String facilityCd_t = payload.getFacilityCd();
    String reportClass_t = String.valueOf(payload.getReportClass());
    String reportName_t = payload.getReportName();
    String sqlTimeStr_t = payload.getSqlTestTimeStr();
    String sqlTestSign = ">>>>>>>>>>>" + facilityCd_t + "-" + reportClass_t + "-" + reportName_t + "-" + sqlTimeStr_t + ">>>>>>>>>>";
    payload.setSqlTestTimeStr(sqlTestSign);
    EventLogMessage LogMessage = new EventLogMessage();
    LogMessage.setLogMessage(sqlTestSign + "リクエスト 開始<<<<<<<");
    testLogService.log(LogLevel.INFO, LogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI, null);
    //add IES因島）sql性能試験 後で削除 liuc end

    // add 8542 紹介状（集計あり。因島様にて使用）にて出力できない項目がある 吉 start
    String name = mstPersonalUserDao.selectUserNameById(ntssUser.getUserId());
    // add 8542 紹介状（集計あり。因島様にて使用）にて出力できない項目がある 吉 end
    // add 11009 カテゴリ「印刷情報」の仕様調整 房 start
    // パラメータの標準化
    requestParamEdit(payload, name);
    // add 11009 カテゴリ「印刷情報」の仕様調整 房 end
    String reportHtmls = "";
    List<Long> patIds = new ArrayList<>();
    //add #10504 一日複数回指示ある患者の治療経過表出力で空帳票が出力される 王永吉 start
    reportMenuService.getOption(false);
    //add #10504 一日複数回指示ある患者の治療経過表出力で空帳票が出力される 王永吉 end
    try {
      //add 8507 2023-4-3 zhaoqj patIdグローバル変数方式をmapストレージkeyからuserIdに変更 start

      patIds = payload.getPatIds();
      //add 8507 2023-4-3 zhaoqj patIdグローバル変数方式をmapストレージkeyからuserIdに変更 end
      // add 2020-09-30 FNSI-改修 複数データ対象の帳票の場合の切替 夏 start
      Integer reportClass = payload.getReportClass();
      Boolean disPlayFlg = false;
      // add #7672 【デグレ】透析装置に表示される治療記録画像が縦長になる 王永吉 start
      payload.setReportFromFlag(true);
      // add #7672 【デグレ】透析装置に表示される治療記録画像が縦長になる 王永吉 end
      if (reportClass < ReportConstant.ReportClass.MULTIPLE_PATIENT_REPORT
        || reportClass == ReportConstant.ReportClass.INTRODUCTION_REPORT)
      {
        // del by shangkuiwei 2023-02-05 [Variable,CodeOptimization] --start
        // ReportServiceImpl.tmpDataKeyList.clear();
        // del by shangkuiwei 2023-02-05 [Variable,CodeOptimization] --end
        // mod 6735 ホスト監視のプレビューに値が表示されない 吉 start
        //if(option == 0 && patIds.size() == 0){
        if(option == 0 && patIds.size() == 0 && reportClass != ReportConstant.ReportClass.DIALYSIS_REPORT){
          // mod 6735 ホスト監視のプレビューに値が表示されない 吉 end
          return new ResponseEntity<>("データ無", HttpStatus.OK);
        }
        List<Long> patIdList = new ArrayList<>();
        //mod FNSI-5605 李 start
        if (reportClass == ReportConstant.ReportClass.DIALYSIS_REPORT){
          if (option == 1){
            // mod #6962 「並び替えボタンが機能しない」について、対応する 鄧シン start
            // patIds = payload.getPatIds();
            // ソートされたOrdList取得
            List<OrdMain> ordMainSorted = reportMenuService.getOrdNoListSorted(payload);
            List<Long> patIdSorted = new ArrayList<>();
            // ソートされたOrdListのpatId取得
            for (OrdMain ordMain : ordMainSorted) {
              // add テストして問題を発見しました 吉 start
              if(!patIdSorted.contains(ordMain.getPatId())){
                // add テストして問題を発見しました 吉 end
                patIdSorted.add(ordMain.getPatId());
                // add テストして問題を発見しました 吉 start
              }
              // add テストして問題を発見しました 吉 end
            }
            patIds = patIdSorted;
            // #mod #6962 「並び替えボタンが機能しない」について、対応する 鄧シン end
          }
          //mod 8507 2023-4-6 zhaoqj  ローラデータローディング start
          for(int i =0;i<patIds.size();i++){
            patIdList.add(patIds.get(i));
          }
          //mod 8507 2023-4-6 zhaoqj  ローラデータローディング end
          //del 8507 2023-4-6 zhaoqj  ローラデータローディング start
//          if(patIds.size() <= count){
//            // mod 6735 ホスト監視のプレビューに値が表示されない 吉 start
//            // patIdList = patIds;
//            for(int i =0;patIds.size()>0;){
//              patIdList.add(patIds.get(0));
//              patIds.remove(patIds.get(0));
//            }
//            // mod 6735 ホスト監視のプレビューに値が表示されない 吉 end
//            disPlayFlg = true;
//          }else{
//            for(int i =0;i<count;i++){
//              patIdList.add(patIds.get(0));
//              patIds.remove(patIds.get(0));
//            }
//          }
          //del 8507 2023-4-6 zhaoqj  ローラデータローディング end
          payload.setPatIds(patIdList);
        }
		//mod FNSI-5605 李 end
      }
      // add FNSI-523 2次元帳票対応 夏 start
      else if(reportClass == ReportConstant.ReportClass.ONE_TOTAL_REPORT ||
        reportClass == ReportConstant.ReportClass.MULTI_TOTAL_REPORT){
        // 特殊二次元帳票「血液検査実績(２次元)」帳票レイアウトの対応 夏 start
//        patIds.clear();
        // 特殊二次元帳票「血液検査実績(２次元)」帳票レイアウトの対応 夏 end
        if(option == 1){
          reportHtmls = "";
        }
      }
      // add FNSI-523 2次元帳票対応 夏 end
      else{
        // mod by shangkuiwei 2023-02-05 [Variable,CodeOptimization] --start
        // if(option == 0 && ReportServiceImpl.tmpDataKeyList.size() == 0
        if(option == 0
          // mod by shangkuiwei 2023-02-05 [Variable,CodeOptimization] --end
          && (reportClass == ReportConstant.ReportClass.MULTIPLE_PATIENT_REPORT
          // add Aspose.cells関連問題対応 夏 start
          || reportClass == ReportConstant.ReportClass.DISTRIBUTION_LIST_GOODS_REPORT
          // add Aspose.cells関連問題対応 夏 end
          || reportClass == ReportConstant.ReportClass.DISTRIBUTION_LIST_BED_REPORT)){
          return new ResponseEntity<>("データ無", HttpStatus.OK);
        }
      }
      // add 2020-09-30 FNSI-改修 複数データ対象の帳票の場合の切替 夏 end
      // html生成
      // mod #8182 帳票出力時にasposeを経由しないで出力される帳票がある 鄭爽 start
      // String reportHtml = reportMenuService.getHtmlReportSorted(payload, ntssUser.getUserId(), ntssUser.getUsername());
      String reportHtml = "";
      // del 9316 施設設定マスタ125番の削除について　吉 start
//      boolean isUseAsposeCells = true;
//      FacilitySettingInfo settingValue = mstFacilitySettingDao.getBySettingNoAndCd(ntssUser.getFacilityCd(),CoreConstant.FacilitySettingNo.PREVIEW_MODE);
//      if(settingValue != null && settingValue.getValue().equals("1")){
//        isUseAsposeCells = false;
//      }
      // del 9316 施設設定マスタ125番の削除について　吉 end
      String reportType = payload.getReportType();
      // mod #8182 帳票出力時にasposeを経由しないで出力される帳票がある 日本指摘対応 鄭爽 start
      //      if(isUseAsposeCells && (reportClass == ReportConstant.ReportClass.MULTIPLE_PATIENT_REPORT ||
      //        reportClass == ReportConstant.ReportClass.MULTI_TOTAL_REPORT ||
      //        reportClass == ReportConstant.ReportClass.ONE_TOTAL_REPORT ||
      //        (reportClass == ReportConstant.ReportClass.INTRODUCTION_REPORT && reportType.equals("1")))) {
      //if(isUseAsposeCells && (reportClass == ReportConstant.ReportClass.MULTI_TOTAL_REPORT ||
      //  reportClass == ReportConstant.ReportClass.ONE_TOTAL_REPORT)) {
      //  // mod #8182 帳票出力時にasposeを経由しないで出力される帳票がある 日本指摘対応 鄭爽 end
      //  byte[] file = null;
      //  // mod 8542 紹介状（集計あり。因島様にて使用）にて出力できない項目がある 吉 start
      //  // file = reportMenuService.getExcelReportSorted(payload);
      //  // mod 8542 紹介状（集計あり。因島様にて使用）にて出力できない項目がある 吉 start
      //  // file = reportMenuService.getExcelReportSorted(payload, ntssUser.getUsername());
      //  file = reportMenuService.getExcelReportSorted(payload, name);
      //  // mod 8542 紹介状（集計あり。因島様にて使用）にて出力できない項目がある 吉 end
      //  // mod 8542 紹介状（集計あり。因島様にて使用）にて出力できない項目がある 吉 end
      //  if (!(file == null || file.length == 0)) {
      //    ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(file);
      //    URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
      //    reportHtml = AsposeCellsUtils.excelToSvg(byteArrayInputStream,url);
      //  }
      //  // add #8182 帳票出力時にasposeを経由しないで出力される帳票がある 日本指摘対応 鄭爽 start
      //  // 単患者帳票
      //}
      // mod 9316 施設設定マスタ125番の削除について　吉 start
//      if (isUseAsposeCells && (reportClass == ReportConstant.ReportClass.DIALYSIS_REPORT)) {
      if (reportClass == ReportConstant.ReportClass.DIALYSIS_REPORT) {
        // mod 9316 施設設定マスタ125番の削除について　吉 end
        // 帳票種別：1：治療経過表
        // ※ 常にAsposeを使用します

        List<Map<Long, List<byte[]>>> patFileList = new ArrayList<>();
        patFileList = reportMenuService.getExcelReportForDialysisReport(payload, name);

        for (int i = 0; i < patFileList.size(); i++) {
          for (Long key : patFileList.get(i).keySet()) {
            List<byte[]> bytesList = patFileList.get(i).get(key);
            for (int j = 0; j < bytesList.size(); j++) {
              byte[] data = bytesList.get(j);
              String tempReportHtml = "";
              if (data.length > 0) {
                ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(data);
                URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
                tempReportHtml = AsposeCellsUtils.excelToSvg(byteArrayInputStream,url);
              }
              reportHtml += tempReportHtml;
            }
          }
        }
        // mod 9316 施設設定マスタ125番の削除について　吉 start
//      } else if (isUseAsposeCells && (reportClass == ReportConstant.ReportClass.ONE_PATIENT_REPORT)) {
      } else if (reportClass == ReportConstant.ReportClass.ONE_PATIENT_REPORT) {
        // mod 9316 施設設定マスタ125番の削除について　吉 end
        // 帳票種別：2：単患者帳票
        // ※ 常にAsposeを使用します
        int index = 0;
        List<Map<Long, byte[]>> patFileList = new ArrayList<>();
        patFileList = reportMenuService.getReportExcelFilesForOnePatient(payload, name);

        for (int i = 0; i < patFileList.size(); i++) {
          String onePatientHtml = "";
          // 複数の患者を選択して繰り返し処理
          for (Long key : patFileList.get(i).keySet()) {
            byte[] bytesList = patFileList.get(i).get(key);
            String onePatientByteHtml = "";
            if (bytesList.length > 0) {
              ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(bytesList);
              URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
              // Excel Convert To Svg
              onePatientByteHtml = AsposeCellsUtils.excelToSvg(byteArrayInputStream, url);
              // del #12445 因島】帳票に出力されない画像がある 差戻1 sunsy start
//              // add #12245 【因島】帳票に出力されない画像がある  吉 start
//              String uuid = UUID.randomUUID().toString();
//              String clipPrefix = "CLIP-" + uuid + "-" + i + "-";
//              onePatientByteHtml = onePatientByteHtml.replaceAll("id=\"CLIP(.*?)\"", "id=\"" + clipPrefix + "$1\"");
//              onePatientByteHtml = onePatientByteHtml.replaceAll("url\\(#CLIP(.*?)\\)", "url(#" + clipPrefix + "$1)");
//              // add #12245 【因島】帳票に出力されない画像がある  吉 end
              // del #12445 因島】帳票に出力されない画像がある 差戻1 sunsy end
              index++;
            }
            // 同じ患者に複数のデータがある場合、帳票htmlを加算する
            onePatientHtml += onePatientByteHtml;
          }
          // 複数の患者の場合、帳票htmlを加算する
          reportHtml += onePatientHtml;
        }
        // mod 9316 施設設定マスタ125番の削除について　吉 start
//      } else if (isUseAsposeCells && (reportClass == ReportConstant.ReportClass.MULTIPLE_PATIENT_REPORT)) {
      } else if (reportClass == ReportConstant.ReportClass.MULTIPLE_PATIENT_REPORT) {
        // mod 9316 施設設定マスタ125番の削除について　吉 end
        // 帳票種別：3：複数患者帳票

        byte[] file = null;
        file = reportMenuService.getReportExcelFilesForMultiplePatient(payload, name);

        if (!(file == null || file.length == 0)) {
          ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(file);
          URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
          reportHtml = AsposeCellsUtils.excelToSvg(byteArrayInputStream,url);
        }
        // mod 9316 施設設定マスタ125番の削除について　吉 start
//      } else if (isUseAsposeCells && (reportClass == ReportConstant.ReportClass.PREPARATION_LIST_REPORT)) {
      } else if (reportClass == ReportConstant.ReportClass.PREPARATION_LIST_REPORT) {
        // mod 9316 施設設定マスタ125番の削除について　吉 end
        // 帳票種別：4：準備リスト

        byte[] file = null;
        file = reportMenuService.getExcelReportForPreparationList(payload, name);

        if (!(file == null || file.length == 0)) {
          ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(file);
          URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
          reportHtml = AsposeCellsUtils.excelToSvg(byteArrayInputStream,url);
        }
        // mod 9316 施設設定マスタ125番の削除について　吉 start
//      } else if (isUseAsposeCells && (reportClass == ReportConstant.ReportClass.DISTRIBUTION_LIST_BED_REPORT)) {
      } else if (reportClass == ReportConstant.ReportClass.DISTRIBUTION_LIST_BED_REPORT) {
        // mod 9316 施設設定マスタ125番の削除について　吉 end
        // 帳票種別：5：配布リスト（ベッド）

        byte[] file = null;
        file = reportMenuService.getExcelReportForDistributionListBed(payload, name);

        if (!(file == null || file.length == 0)) {
          ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(file);
          URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
          reportHtml = AsposeCellsUtils.excelToSvg(byteArrayInputStream,url);
        }
        // mod 9316 施設設定マスタ125番の削除について　吉 start
//      } else if (isUseAsposeCells && (reportClass == ReportConstant.ReportClass.MACHINE_REPORT)) {
      } else if (reportClass == ReportConstant.ReportClass.MACHINE_REPORT) {
        // mod 9316 施設設定マスタ125番の削除について　吉 end
        // 帳票種別：7：装置帳票

        List<Map<Long, List<byte[]>>> patFileList = new ArrayList<>();
        // mod #11100 【総合検証NG】装置帳票＞定期点検（日常点検記録簿、定期点検記録簿）のプレビューができない。 limingzhe start
        //patFileList = reportMenuService.getExcelReportForMachineReport(payload, name);
        // del #12107 帳票印刷失敗通知が行われない limingzhe start
//        try {
        // del #12107 帳票印刷失敗通知が行われない limingzhe end
          patFileList = reportMenuService.getExcelReportForMachineReport(payload, name);
        // del #12107 帳票印刷失敗通知が行われない limingzhe start
//        } catch (NtssException ntssException) {
//          return new ResponseEntity<>(ntssException.getMessage(), HttpStatus.OK);
//        } catch (Exception e) {
//          e.printStackTrace();
//        }
        // del #12107 帳票印刷失敗通知が行われない limingzhe end
        // mod #11100 【総合検証NG】装置帳票＞定期点検（日常点検記録簿、定期点検記録簿）のプレビューができない。 limingzhe end
        for (int i = 0; i < patFileList.size(); i++) {
          for (Long key : patFileList.get(i).keySet()) {
            List<byte[]> bytesList = patFileList.get(i).get(key);
            for (int j = 0; j < bytesList.size(); j++) {
              byte[] data = bytesList.get(j);
              String tempReportHtml = "";
              if (data.length > 0) {
                ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(data);
                URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
                tempReportHtml = AsposeCellsUtils.excelToSvg(byteArrayInputStream,url);
              }
              reportHtml += tempReportHtml;
            }
          }
        }
        // mod 9316 施設設定マスタ125番の削除について　吉 start
//      } else if (isUseAsposeCells && (reportClass == ReportConstant.ReportClass.DISTRIBUTION_LIST_GOODS_REPORT)) {
      } else if (reportClass == ReportConstant.ReportClass.DISTRIBUTION_LIST_GOODS_REPORT) {
        // mod 9316 施設設定マスタ125番の削除について　吉 end
        // 帳票種別：6：配布リスト（物品）

        byte[] file = null;
        file = reportMenuService.getExcelReportForDistributionListGoods(payload, name);

        if (!(file == null || file.length == 0)) {
          ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(file);
          URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
          reportHtml = AsposeCellsUtils.excelToSvg(byteArrayInputStream,url);
        }
        // mod 9316 施設設定マスタ125番の削除について　吉 start
        // } else if (isUseAsposeCells && (reportClass == ReportConstant.ReportClass.LABEL_REPORT)) {
      } else if (reportClass == ReportConstant.ReportClass.LABEL_REPORT) {
        // mod 9316 施設設定マスタ125番の削除について　吉 end
        // 帳票種別：8：ラベル

        byte[] file = null;
        file = reportMenuService.getExcelReportForLabelReport(payload, name);

        if (!(file == null || file.length == 0)) {
          ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(file);
          URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
          reportHtml = AsposeCellsUtils.excelToSvg(byteArrayInputStream,url);
        }
        // mod 9316 施設設定マスタ125番の削除について　吉 start
//      } else if (isUseAsposeCells && (reportClass == ReportConstant.ReportClass.INTRODUCTION_REPORT)) {
      } else if (reportClass == ReportConstant.ReportClass.INTRODUCTION_REPORT) {
        // mod 9316 施設設定マスタ125番の削除について　吉 end
        // 帳票種別：9：紹介状
        // mod 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 start
        List<Map<Long, List<byte[]>>> file = null;
//        byte[] file = null;
        // mod 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 end
        file = reportMenuService.getExcelReportForIntroductionReport(payload, name);

        // mod 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 start
//        if (!(file == null || file.length == 0)) {
//          ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(file);
//          URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
//          reportHtml = AsposeCellsUtils.excelToSvg(byteArrayInputStream,url);
//        }
        for (int i = 0; i < file.size(); i++) {
          for (Long key : file.get(i).keySet()) {
            List<byte[]> bytesList = file.get(i).get(key);
            for (int j = 0; j < bytesList.size(); j++) {
              byte[] data = bytesList.get(j);
              if (data.length > 0) {
                ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(data);
                URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
                reportHtml += AsposeCellsUtils.excelToSvg(byteArrayInputStream,url);
              }
            }
          }
          // mod 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 end
        }
        // mod 9316 施設設定マスタ125番の削除について　吉 start
//      } else if (isUseAsposeCells && (reportClass == ReportConstant.ReportClass.ONE_TOTAL_REPORT)) {
      } else if (reportClass == ReportConstant.ReportClass.ONE_TOTAL_REPORT) {
        // mod 9316 施設設定マスタ125番の削除について　吉 end
        // 帳票種別：10：単集計
        // mod 10432 出力対象患者が複数名の時「単集計」帳票が全員出力されない。　杜 start
        int index = 0;
        List<Map<Long, List<byte[]>>> fileList = new ArrayList<>();
        // mod 10546 単集計出力時にページ数の制限 gjn start
        // del #12107 帳票印刷失敗通知が行われない limingzhe start
//        try {
        // del #12107 帳票印刷失敗通知が行われない limingzhe end
          fileList = reportMenuService.getExcelReportForOneTotal(payload, name);
        // del #12107 帳票印刷失敗通知が行われない limingzhe start
//        } catch (NtssException ntssException) {
//          return new ResponseEntity<>(ntssException.getMessage(), HttpStatus.OK);
//        } catch (Exception e) {
//          e.printStackTrace();
//        }
        // del #12107 帳票印刷失敗通知が行われない limingzhe end
        // mod 10546 単集計出力時にページ数の制限 gjn end

        for (int i = 0; i < fileList.size(); i++) {
          String onePatientHtml = "";
          // 複数の患者を選択して繰り返し処理
          for (Long key : fileList.get(i).keySet()) {

            List<byte[]> bytesListNew = fileList.get(i).get(key);
            for (int j = 0; j < bytesListNew.size(); j++) {
              byte[] bytesList = bytesListNew.get(j);
              String onePatientByteHtml = "";
              if (bytesList.length > 0) {
                ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(bytesList);
                URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
                // Excel Convert To Svg
                // mod #12445 【因島】帳票に出力されない画像がある sunsy start
//                onePatientByteHtml = AsposeCellsUtils.excelToSvg(byteArrayInputStream, url).replace("CLIP", "CLIP-" + index + "-");
                onePatientByteHtml = AsposeCellsUtils.excelToSvg(byteArrayInputStream, url);
                // mod #12445 【因島】帳票に出力されない画像がある sunsy end
                index++;
              }
              // 同じ患者に複数のデータがある場合、帳票htmlを加算する
              onePatientHtml += onePatientByteHtml;
            }
          }
          // 複数の患者の場合、帳票htmlを加算する
          reportHtml += onePatientHtml;
         // mod 10432 出力対象患者が複数名の時「単集計」帳票が全員出力されない。　杜 end
        }
        // mod 9316 施設設定マスタ125番の削除について　吉 start
//      } else if (isUseAsposeCells && (reportClass == ReportConstant.ReportClass.MULTI_TOTAL_REPORT)) {
      } else if (reportClass == ReportConstant.ReportClass.MULTI_TOTAL_REPORT) {
        // mod 9316 施設設定マスタ125番の削除について　吉 end
        // 帳票種別：11：複数集計
        // mod 10546 複数集計出力時にページ数の制限 gjn start
        // del #12107 帳票印刷失敗通知が行われない limingzhe start
//        try {
        // del #12107 帳票印刷失敗通知が行われない limingzhe end
          byte[] file = reportMenuService.getExcelReportForMultiTotalHighPerformanceVersion(payload, name);
          //byte[] file = reportMenuService.getExcelReportForMultiTotal(payload, name);
          //if (!(file == null || file.length == 0)) {
          if (file != null && file.length > 0) {
            ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(file);
            URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
            reportHtml = AsposeCellsUtils.excelToSvg(byteArrayInputStream, url);
          }
        // del #12107 帳票印刷失敗通知が行われない limingzhe start
//        } catch (NtssException e) {
//          return new ResponseEntity<>(e.getMessage(), HttpStatus.OK);
//        } catch (Exception exception) {
//          exception.printStackTrace();
//        }
        // del #12107 帳票印刷失敗通知が行われない limingzhe end
        // mod 10546 複数集計出力時にページ数の制限 gjn end
      } else {
        // mod 8542 紹介状（集計あり。因島様にて使用）にて出力できない項目がある 吉 start
        // reportHtml = reportMenuService.getHtmlReportSorted(payload, ntssUser.getUserId(), ntssUser.getUsername());
        reportHtml = reportMenuService.getHtmlReportSorted(payload, ntssUser.getUserId(), name);
        // mod 8542 紹介状（集計あり。因島様にて使用）にて出力できない項目がある 吉 end
      }
      // mod #8182 帳票出力時にasposeを経由しないで出力される帳票がある 鄭爽 end

      // mod 8772【IES起票】SQL118検索条件が間違って実行エラーが発生する liuc start
      // add 6735 ホスト監視のプレビューに値が表示されない 吉 start
//      if (reportClass == ReportConstant.ReportClass.DIALYSIS_REPORT && StringUtils.isEmpty(reportHtml)){
//        while (StringUtils.isEmpty(reportHtml) && patIds.size() >0){
//          //del 8507 2023-4-6 zhaoqj  ローラデータローディング start
////          List<Long> patIdList = new ArrayList<>();
////          payload.setPatIds(patIdList);
////          if(patIds.size() <= count){
////            patIdList = patIds;
////            disPlayFlg = true;
////            patIds.clear();
////          }else{
////            for(int i =0;i<count;i++){
////              patIdList.add(patIds.get(0));
////              patIds.remove(patIds.get(0));
////            }
////          }
////          payload.setPatIds(patIdList);
//          //del 8507 2023-4-6 zhaoqj  ローラデータローディング end
//          // mod 8542 紹介状（集計あり。因島様にて使用）にて出力できない項目がある 吉 start
//          // reportHtml = reportMenuService.getHtmlReportSorted(payload, ntssUser.getUserId(), ntssUser.getUsername());
//          reportHtml = reportMenuService.getHtmlReportSorted(payload, ntssUser.getUserId(), name);
//          // mod 8542 紹介状（集計あり。因島様にて使用）にて出力できない項目がある 吉 end
//        }
//        if(StringUtils.isEmpty(reportHtml) && patIds.size() == 0 && option == 0){
//          return new ResponseEntity<>(reportHtmls, HttpStatus.OK);
//        }
//      }
      if(StringUtils.isEmpty(reportHtml) && patIds.size() == 0 && option == 0){
        return new ResponseEntity<>(reportHtmls, HttpStatus.OK);
      }
      // add 6735 ホスト監視のプレビューに値が表示されない 吉 end
      // mod 8772【IES起票】SQL118検索条件が間違って実行エラーが発生する liuc end

        // 帳票htmlがnullもしくは空文字の場合
      if (StringUtils.isEmpty(reportHtml)) {
        // add 2020-09-30 FNSI-改修 複数データ対象の帳票の場合の切替 夏 start
        reportHtmls = "";
        // del by shangkuiwei 2023-02-05 [Variable,CodeOptimization] --start
        // ReportServiceImpl.tmpDataKeyList.clear();
        // del by shangkuiwei 2023-02-05 [Variable,CodeOptimization] --end
        // add 2020-09-30 FNSI-改修 複数データ対象の帳票の場合の切替 夏 end
        // del  2022-1-10 #6589   鄭  start
       // return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
        // del  2022-1-10 #6589   鄭  end
      }
      // add 2020-09-30 FNSI-改修 複数データ対象の帳票の場合の切替 夏 start
      if (reportClass <= ReportConstant.ReportClass.MULTIPLE_PATIENT_REPORT
        || reportClass == ReportConstant.ReportClass.INTRODUCTION_REPORT
        || reportClass == ReportConstant.ReportClass.DISTRIBUTION_LIST_BED_REPORT) {
        //del 8507 2023-4-6 zhaoqj  ローラデータローディング start
//        if (disPlayFlg == true) {
//          patIds.clear();
//        }
        //del 8507 2023-4-6 zhaoqj  ローラデータローディング end
        if (option == 0) {
          reportHtmls = reportHtmls + reportHtml;
        } else {
          reportHtmls = reportHtml;
        }
      }
      // add FNSI-523 2次元帳票対応 夏 start
      else if(reportClass == ReportConstant.ReportClass.ONE_TOTAL_REPORT ||
        reportClass == ReportConstant.ReportClass.MULTI_TOTAL_REPORT){
        reportHtmls = reportHtmls + reportHtml;
      }
      // add FNSI-523 2次元帳票対応 夏 end
      else{
        if(option == 0 && reportHtmls.equals(reportHtml)){
          return new ResponseEntity<>("データ無", HttpStatus.OK);
        }else{
          reportHtmls = reportHtml;
        }
      }
      //add IES因島）sql性能試験 後で削除 liuc start
      Date endTime = new Date();
      EventLogMessage LogMessage2 = new EventLogMessage();
      LogMessage2.setLogMessage(sqlTestSign + "getReportHtmlリクエスト総使用時間:" + (endTime.getTime() - beginTime.getTime()) + "ms");
      testLogService.log(LogLevel.INFO, LogMessage2, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI, null);
      EventLogMessage LogMessage3 = new EventLogMessage();
      LogMessage3.setLogMessage(sqlTestSign + "リクエスト 終了<<<<<<");
      testLogService.log(LogLevel.INFO, LogMessage3, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI, null);
      //add IES因島）sql性能試験 後で削除 liuc end
      // add 2020-09-30 FNSI-改修 複数データ対象の帳票の場合の切替 夏 end
      return new ResponseEntity<>(reportHtmls, HttpStatus.OK);
    } catch (Exception e) {
      // add 2020-09-30 FNSI-改修 複数データ対象の帳票の場合の切替 夏 start
      //add 8507 2023-4-3 zhaoqj patIdグローバル変数方式をmapストレージkeyからuserIdに変更 start
//      patIdsMap.remove(ntssUser.getUserId());
      //add 8507 2023-4-3 zhaoqj patIdグローバル変数方式をmapストレージkeyからuserIdに変更 end
      // del by shangkuiwei 2023-02-05 [Variable,CodeOptimization] --start
      // ReportServiceImpl.tmpDataKeyList.clear();
      // del by shangkuiwei 2023-02-05 [Variable,CodeOptimization] --end
      // add 2020-09-30 FNSI-改修 複数データ対象の帳票の場合の切替 夏 end
      EventLogMessage eventLogMessage = new EventLogMessage();
			// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
			logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_REPORT_MENU,SERVICE_NAME.FNSI, null);
      // add 2020-09-17 FNSI-不良修正 レイアウトデザイナーで削除後エラー処理追加 夏 start
      if(e.toString().indexOf("存在しない帳票マスタのレポートコードを指定されています。") !=-1)
      {
        return new ResponseEntity<>("レポート無", HttpStatus.OK);
      }
      // add 2020-09-17 FNSI-不良修正 レイアウトデザイナーで削除後エラー処理追加 夏 end
      // add #8870 帳票画面にてデータ無しのエラーメッセージが規範的ではない 王 start
      if(e.toString().indexOf("テンプレートがない") !=-1)
      {
        return new ResponseEntity<>("テンプレートがない", HttpStatus.OK);
      }
      if(e.toString().indexOf("治療情報に紐づく治療方法の取得に失敗しました。") !=-1 || e.toString().indexOf("治療方法マスタの治療経過表IDが設定されていません、また施設設定マスタNo117 帳票未指定時のデフォルト帳票の設定もされておりません。") !=-1)
      {
        return new ResponseEntity<>("マスタに設定されていない", HttpStatus.OK);
      }
      // add #8870 帳票画面にてデータ無しのエラーメッセージが規範的ではない 王 end
      // add #12107 帳票印刷失敗通知が行われない limingzhe start
      if(e.getMessage().indexOf("ExceedingMaxPageSetting") !=-1) {
        return new ResponseEntity<>(e.getMessage(), HttpStatus.OK);
      }
      if(e.getMessage().equals("該当データが存在していません。")) {
        return new ResponseEntity<>(e.getMessage(), HttpStatus.OK);
      }
      // add #12107 帳票印刷失敗通知が行われない limingzhe end
      return new ResponseEntity<>(e.toString(), HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

	/**
	 * 帳票をダウンロードする.
	 *
	 * @param payload 帳票生成の為に必要なパラメータ
   * @param option ダウンロードオプション
   * @param ntssUser 利用者情報
	 * @return 帳票ファイル
	 */
	@PostMapping("/getReportFile/{option}")
	public ResponseEntity<?> getReportFile(
	  @RequestBody ReportMenuSortContainer payload,
    @PathVariable Integer option,
    @AuthenticationPrincipal NtssUser ntssUser
  ) {
    // add 8542 紹介状（集計あり。因島様にて使用）にて出力できない項目がある 吉 start
    String userNameStr = mstPersonalUserDao.selectUserNameById(ntssUser.getUserId());
    // add 8542 紹介状（集計あり。因島様にて使用）にて出力できない項目がある 吉 end
    // add 11009 カテゴリ「印刷情報」の仕様調整 房 start
    // パラメータの標準化
    requestParamEdit(payload, userNameStr);
    // add 11009 カテゴリ「印刷情報」の仕様調整 房 end
		List<Map<Long, List<String>>> patHtmls = new ArrayList<>();
		List<Map<Long, List<byte[]>>> patFileList = new ArrayList<>();
    // add 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 start
    List<Map<Long, List<byte[]>>> fileList = new ArrayList<>();
    // add 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 end
		Integer reportClass = payload.getReportClass();
		String reportName = payload.getReportName();
		// add  #5714 2020-12-8 紹介状が正しく出力できない 孟堅 start
        String reportType = payload.getReportType();
        // add  #5714 2020-12-8 紹介状が正しく出力できない　孟堅　 end
		String htmlMultiPat = "";
    // del 9316 施設設定マスタ125番の削除について　吉 start
//        boolean isUseAsposeCells = true;
//        FacilitySettingInfo settingValue = mstFacilitySettingDao.getBySettingNoAndCd(ntssUser.getFacilityCd(),CoreConstant.FacilitySettingNo.PREVIEW_MODE);
//        if(settingValue != null && settingValue.getValue().equals("1")){
//            isUseAsposeCells = false;
//        }
    // del 9316 施設設定マスタ125番の削除について　吉 end

    //add #10504 一日複数回指示ある患者の治療経過表出力で空帳票が出力される 王永吉 start
    reportMenuService.getOption(true);
    //add #10504 一日複数回指示ある患者の治療経過表出力で空帳票が出力される 王永吉 end
		try {
          /*mod FNSI-改修内容装置帳票の対応 任 start*/
          /*if (reportClass >= 3) {*/
          // mod #5714 2021-12-8 紹介状が正しく出力できない　孟堅 start

          if (reportClass >= 3 && reportClass!=9 && reportClass != 7 || (reportClass==9 && reportType.equals("1"))) {
		    // if (reportClass >= 3 && (reportClass==9 && reportType.equals("1")) && reportClass != 7) {
			//mod  #5714 2020-12-8 紹介状が正しく出力できない　孟堅 end
            /*mod FNSI-改修内容装置帳票の対応 任 end*/
            //mod Aspose.cells関連問題5の対応 王占宇 start
            //         htmlMultiPat = reportMenuService.getHtmlReportSorted(payload, ntssUser.getUserId(), ntssUser.getUsername());
            //         if (htmlMultiPat == null) {
            //           return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
            //         }
            //mod Aspose.cells関連問題5の対応 王占宇 start
            //         if(!(reportClass==9 || reportType.equals("1"))) {
            // mod Aspose.cells関連問題対応 修正 商 start
            //if(!(ReportConstant.ReportClass.INTRODUCTION_REPORT.equals(reportClass) && "1".equals(reportType))) {

            // mod 10546 複数集計ファイル保存時の分岐論理エラー修正の処理 gjn start
            if(!(ReportConstant.ReportClass.INTRODUCTION_REPORT.equals(reportClass) && "1".equals(reportType)) &&
              !(ReportConstant.ReportClass.ONE_TOTAL_REPORT.equals(reportClass))
              && !ReportConstant.ReportClass.MULTI_TOTAL_REPORT.equals(reportClass)) {
            // mod 10546 複数集計ファイル保存時の分岐論理エラー修正の処理 gjn end

              // mod Aspose.cells関連問題対応 修正 商 end
              //mod Aspose.cells関連問題5の対応 王占宇 end
              // mod 8542 紹介状（集計あり。因島様にて使用）にて出力できない項目がある 吉 start
              // htmlMultiPat = reportMenuService.getHtmlReportSorted(payload, ntssUser.getUserId(), ntssUser.getUsername());
              htmlMultiPat = reportMenuService.getHtmlReportSorted(payload, ntssUser.getUserId(), userNameStr);
              // mod 8542 紹介状（集計あり。因島様にて使用）にて出力できない項目がある 吉 end
              if (htmlMultiPat == null) {
                return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
              }
            }
            //mod Aspose.cells関連問題5の対応 王占宇 end
			byte[] file = null;
            // mod 10432 出力対象患者が複数名の時「単集計」帳票が全員出力されない。　杜 start
            List<Map<Long, List<byte[]>>> fileListFirst = new ArrayList<>();
            // mod 10432 出力対象患者が複数名の時「単集計」帳票が全員出力されない。　杜 end

			if (option == 1) {
			  // del 9316 施設設定マスタ125番の削除について　吉 start
//              if(isUseAsposeCells){
                // del 9316 施設設定マスタ125番の削除について　吉 end
                if (reportClass == ReportConstant.ReportClass.MULTIPLE_PATIENT_REPORT) {
                  // 帳票種別：3：複数患者帳票(PDF出力)
                  // ※ 常にAsposeを使用します
                  file = reportMenuService.getReportExcelFilesForMultiplePatient(payload, userNameStr);

                  if (!(file == null || file.length == 0)) {
                    ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(file);
                    ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                    URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
                    AsposeCellsUtils.excelToPdf(byteArrayInputStream,byteArrayOutputStream,url);
                    file = byteArrayOutputStream.toByteArray();
                  }
                } else if (reportClass == ReportConstant.ReportClass.PREPARATION_LIST_REPORT) {
                  // 帳票種別：4：準備リスト(PDF出力)
                  // ※ 常にAsposeを使用します

                  file = reportMenuService.getExcelReportForPreparationList(payload, userNameStr);

                  if (!(file == null || file.length == 0)) {
                    ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(file);
                    ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                    URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
                    AsposeCellsUtils.excelToPdf(byteArrayInputStream,byteArrayOutputStream,url);
                    file = byteArrayOutputStream.toByteArray();
                  }
                } else if (reportClass == ReportConstant.ReportClass.DISTRIBUTION_LIST_BED_REPORT) {
                  // 帳票種別：5：配布リスト（ベッド）(PDF出力)
                  // ※ 常にAsposeを使用します

                  file = reportMenuService.getExcelReportForDistributionListBed(payload, userNameStr);

                  if (!(file == null || file.length == 0)) {
                    ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(file);
                    ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                    URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
                    AsposeCellsUtils.excelToPdf(byteArrayInputStream,byteArrayOutputStream,url);
                    file = byteArrayOutputStream.toByteArray();
                  }
                } else if (reportClass == ReportConstant.ReportClass.DISTRIBUTION_LIST_GOODS_REPORT) {
                  // 帳票種別：6：配布リスト（物品）(PDF出力)
                  // ※ 常にAsposeを使用します

                  file = reportMenuService.getExcelReportForDistributionListGoods(payload, userNameStr);

                  if (!(file == null || file.length == 0)) {
                    ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(file);
                    ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                    URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
                    AsposeCellsUtils.excelToPdf(byteArrayInputStream,byteArrayOutputStream,url);
                    file = byteArrayOutputStream.toByteArray();
                  }
                } else if (reportClass == ReportConstant.ReportClass.LABEL_REPORT) {
                  // 帳票種別：8：ラベル(PDF出力)
                  // ※ 常にAsposeを使用します

                  file = reportMenuService.getExcelReportForLabelReport(payload, userNameStr);

                  if (!(file == null || file.length == 0)) {
                    ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(file);
                    ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                    URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
                    AsposeCellsUtils.excelToPdf(byteArrayInputStream,byteArrayOutputStream,url);
                    file = byteArrayOutputStream.toByteArray();
                  }
                  // mod 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 start
                } else if (reportClass == ReportConstant.ReportClass.INTRODUCTION_REPORT && reportType.equals("1")) {
//                } else if (reportClass == ReportConstant.ReportClass.LABEL_REPORT && reportType.equals("1")) {
                  // mod 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 end
                  // 帳票種別：9：紹介状 集計あり(PDF出力)
                  // ※ 常にAsposeを使用します

                  // mod 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 start
//                  file = reportMenuService.getExcelReportForIntroductionReport(payload, userNameStr);
                    fileList = reportMenuService.getExcelReportForIntroductionReport(payload, userNameStr);
                  // mod 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 end

                  // mod 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 start
//                  if (!(file == null || file.length == 0)) {
//                    ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(file);
//                    ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
//                    URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
//                    AsposeCellsUtils.excelToPdf(byteArrayInputStream,byteArrayOutputStream,url);
//                    file = byteArrayOutputStream.toByteArray();
//                  }
                  for (int i = 0; i < fileList.size(); i++) {
                    for (Long key : fileList.get(i).keySet()) {
                      List<byte[]> bytesList = fileList.get(i).get(key);
                      for (int j = 0; j < bytesList.size(); j++) {
                        byte[] data = bytesList.get(j);
                        if (data.length > 0) {
                          ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(data);
                          ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                          URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
                          AsposeCellsUtils.excelToPdf(byteArrayInputStream,byteArrayOutputStream,url);
                          bytesList.set(j,byteArrayOutputStream.toByteArray());
                        }
                        // del #12324 紹介状の出力時にpat_eventを参照する zhao start
                        //patFileList.add(fileList.get(i));
                        // del #12324 紹介状の出力時にpat_eventを参照する zhao end
                      }
                      // add #12324 紹介状の出力時にpat_eventを参照する zhao start
                      patFileList.add(fileList.get(i));
                      // add #12324 紹介状の出力時にpat_eventを参照する zhao end
                    }
                    // mod 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 end
                  }
                } else if (reportClass == ReportConstant.ReportClass.ONE_TOTAL_REPORT) {
                  // 帳票種別：10：単集計(PDF出力)
                  // ※ 常にAsposeを使用します
            // mod 10432 出力対象患者が複数名の時「単集計」帳票が全員出力されない。　杜 start
                  // mod 10546 単集計出力時にページ数の制限 gjn start
                  // del #12107 帳票印刷失敗通知が行われない limingzhe start
//                  try{
                  // del #12107 帳票印刷失敗通知が行われない limingzhe end
                    fileListFirst = reportMenuService.getExcelReportForOneTotal(payload, userNameStr);
                    // add #10982 データ抽出条件の医療材料／薬剤の動作不良 limingzhe start
                    if(fileListFirst != null && fileListFirst.size() != 0) {
                      // add #10982 データ抽出条件の医療材料／薬剤の動作不良 limingzhe end
                      file = fileListFirst.get(0).get(fileListFirst.get(0).keySet().iterator().next()).get(0);
                    }
                  // del #12107 帳票印刷失敗通知が行われない limingzhe start
//                  } catch (NtssException ntssException) {
//                    return new ResponseEntity<>(ntssException.getMessage(), HttpStatus.OK);
//                  }
                  // del #12107 帳票印刷失敗通知が行われない limingzhe end
                  // mod 10546 単集計出力時にページ数の制限 gjn end
                  if (!(file == null || file.length == 0)) {
                    ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(file);
                    ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                    URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
                    AsposeCellsUtils.excelToPdf(byteArrayInputStream,byteArrayOutputStream,url);
                    file = byteArrayOutputStream.toByteArray();
                  }
                  for (int i = 0; i < fileListFirst.size(); i++) {
                    for (Long key : fileListFirst.get(i).keySet()) {
                      List<byte[]> bytesList = fileListFirst.get(i).get(key);
                      for (int j = 0; j < bytesList.size(); j++) {
                        byte[] data = bytesList.get(j);
                        if (!(data == null || data.length == 0)) {
                          ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(data);
                          ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                          URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
                          AsposeCellsUtils.excelToPdf(byteArrayInputStream,byteArrayOutputStream,url);
                          bytesList.set(j,byteArrayOutputStream.toByteArray());
                        }
                        fileList.add(fileListFirst.get(i));
                      }
                    }
            // mod 10432 出力対象患者が複数名の時「単集計」帳票が全員出力されない。　杜 end
                  }
                } else if (reportClass == ReportConstant.ReportClass.MULTI_TOTAL_REPORT) {
                  // 帳票種別：11：複数集計(PDF出力)
                  // ※ 常にAsposeを使用します

                  // mod 10546 複数集計出力時にページ数の制限 gjn start
                  // del #12107 帳票印刷失敗通知が行われない limingzhe start
//                  try {
                  // del #12107 帳票印刷失敗通知が行われない limingzhe end
                    //file = reportMenuService.getExcelReportForMultiTotal(payload, userNameStr);
                    file = reportMenuService.getExcelReportForMultiTotalHighPerformanceVersion(payload, userNameStr);
                  // del #12107 帳票印刷失敗通知が行われない limingzhe start
//                  } catch (NtssException ntssException) {
//                    return new ResponseEntity<>(ntssException.getMessage(), HttpStatus.OK);
//                  }
                  // del #12107 帳票印刷失敗通知が行われない limingzhe end
                  // mod 10546 複数集計出力時にページ数の制限 gjn end

                  if (!(file == null || file.length == 0)) {
                    ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(file);
                    ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                    URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
                    AsposeCellsUtils.excelToPdf(byteArrayInputStream,byteArrayOutputStream,url);
                    file = byteArrayOutputStream.toByteArray();
                  }
                }
                // del 9316 施設設定マスタ125番の削除について　吉 start
//              } else {
//                file = reportMenuService.convertHtmlToPdf(htmlMultiPat);
//              }
        // del 9316 施設設定マスタ125番の削除について　吉 end

			} else {
			  if (reportClass == ReportConstant.ReportClass.MULTIPLE_PATIENT_REPORT) {
                file = reportMenuService.getReportExcelFilesForMultiplePatient(payload, userNameStr);

              } else if (reportClass == ReportConstant.ReportClass.PREPARATION_LIST_REPORT) {
                // 帳票種別：4：準備リスト
                file = reportMenuService.getExcelReportForPreparationList(payload, userNameStr);

              } else if (reportClass == ReportConstant.ReportClass.DISTRIBUTION_LIST_BED_REPORT) {
                // 帳票種別：5：配布リスト（ベッド）
                file = reportMenuService.getExcelReportForDistributionListBed(payload, userNameStr);

              } else if (reportClass == ReportConstant.ReportClass.DISTRIBUTION_LIST_GOODS_REPORT) {
                // 帳票種別：6：配布リスト（物品）
                file = reportMenuService.getExcelReportForDistributionListGoods(payload, userNameStr);

              } else if (reportClass == ReportConstant.ReportClass.LABEL_REPORT) {
                // 帳票種別：8：ラベル
                file = reportMenuService.getExcelReportForLabelReport(payload, userNameStr);

              } else if (reportClass == ReportConstant.ReportClass.INTRODUCTION_REPORT) {
                // 帳票種別：9：紹介状
                // mod 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 start
                // file = reportMenuService.getExcelReportForIntroductionReport(payload, userNameStr);
                patFileList = reportMenuService.getExcelReportForIntroductionReport(payload, userNameStr);
                // mod 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 end

              } else if (reportClass == ReportConstant.ReportClass.ONE_TOTAL_REPORT) {
                // 帳票種別：10：単集計
            // mod 10432 出力対象患者が複数名の時「単集計」帳票が全員出力されない。　杜 start
                // mod 10546 単集計出力時にページ数の制限 gjn start
                // del #12107 帳票印刷失敗通知が行われない limingzhe start
//                try{
                // del #12107 帳票印刷失敗通知が行われない limingzhe end
                  fileListFirst = reportMenuService.getExcelReportForOneTotal(payload, userNameStr);
                  // add #10982 データ抽出条件の医療材料／薬剤の動作不良 limingzhe start
                  if(fileListFirst != null && fileListFirst.size() !=0) {
                    // add #10982 データ抽出条件の医療材料／薬剤の動作不良 limingzhe end
                    file = fileListFirst.get(0).get(fileListFirst.get(0).keySet().iterator().next()).get(0);
                    fileList.addAll(fileListFirst);
                  }
                // del #12107 帳票印刷失敗通知が行われない limingzhe start
//                } catch (NtssException ntssException) {
//                  return new ResponseEntity<>(ntssException.getMessage(), HttpStatus.OK);
//                }
                // del #12107 帳票印刷失敗通知が行われない limingzhe end
                // mod 10546 単集計出力時にページ数の制限 gjn end
            // mod 10432 出力対象患者が複数名の時「単集計」帳票が全員出力されない。　杜 end
              } else if (reportClass == ReportConstant.ReportClass.MULTI_TOTAL_REPORT) {
                // 帳票種別：11：複数集計
                // mod 10546 複数集計出力時にページ数の制限 gjn start
                // del #12107 帳票印刷失敗通知が行われない limingzhe start
//                try{
                // del #12107 帳票印刷失敗通知が行われない limingzhe end
                  //file = reportMenuService.getExcelReportForMultiTotal(payload, userNameStr);
                  file = reportMenuService.getExcelReportForMultiTotalHighPerformanceVersion(payload, userNameStr);
                // del #12107 帳票印刷失敗通知が行われない limingzhe start
//                } catch (NtssException ntssException) {
//                  return new ResponseEntity<>(ntssException.getMessage(), HttpStatus.OK);
//                }
                // del #12107 帳票印刷失敗通知が行われない limingzhe end
                // mod 10546 複数集計出力時にページ数の制限 gjn end

              }
			}
            // add 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 start
            if (reportClass == ReportConstant.ReportClass.INTRODUCTION_REPORT) {
              String fileName = "";
              Date date = new Date();
              // mod #10616 選択患者分の帳票が出力されない 王永吉 start
              //SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
              SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmssSSS");
              // mod #10616 選択患者分の帳票が出力されない 王永吉 end
              String dateString = sdf.format(date);
              fileName = reportName;
              HttpHeaders header = new HttpHeaders();
              byte[] res = null;
              if (patFileList.size() == 1) {
                for (Long key : patFileList.get(0).keySet()) {
                  List<byte[]> bytesList = patFileList.get(0).get(key);
                  if (bytesList.size() == 1) {
                    res = bytesList.get(0);
                    if(reportClass == 7){
                      fileName += "_[" + dateString + "]";
                    }else{
                      PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(key);
                      String lastName = patPersonalMain.getPat_last_name();
                      String firstName = patPersonalMain.getPat_first_name();
                      String name = lastName + firstName;
                      fileName += "_[" + name + "]_[" + dateString + "]";
                    }
                    if (option == 1) {
                      header.set("Content-Type", "application/pdf");
                      fileName += ".pdf";
                    } else {
                      header.set("Content-Type", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
                      fileName += ".xlsx";
                    }
                  } else {
                    if (bytesList.size() > 1) {
                      res = reportMenuService.zipFile(patFileList, reportName, option,reportClass);
                      header.set("Content-Type", "application/octet-stream");
                      fileName += "_["+ dateString +"].zip";
                    }
                  }
                }
              } else if (patFileList.size() > 1) {
                res = reportMenuService.zipFile(patFileList, reportName, option,reportClass);
                header.set("Content-Type", "application/octet-stream");
                /*fileName += ".zip";*/
                fileName += "_["+ dateString +"].zip";
              } else {
                return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
              }
              // ファイル名に使用できない文字を置換
              fileName = fileName.replaceAll("[\\\\/:\\*\\?<>\\|]", "_");
              fileName = URLEncoder.encode(fileName, "UTF-8");
              header.set(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=" + fileName);

              if (res == null || res.length == 0) {
                return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
              }
              return new ResponseEntity<>(res, header, HttpStatus.OK);
            } else {
                // add 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 end
                // add 10432 出力対象患者が複数名の時「単集計」帳票が全員出力されない。　杜 start
                byte[] res = null;
                HttpHeaders header = new HttpHeaders();
                Date date = new Date();
                // mod #10616 選択患者分の帳票が出力されない 王永吉 start
                //SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
                SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmssSSS");
                // mod #10616 選択患者分の帳票が出力されない 王永吉 end
                String dateString = sdf.format(date);
                String fileName = reportName + "_[" + dateString + "]";
                if (fileListFirst != null && fileListFirst.size() == 1) {
                // add 10432 出力対象患者が複数名の時「単集計」帳票が全員出力されない。　杜 end
                  header.set("Content-Type", "application/pdf");
                  // mod 5776 ファイル出力した時のファイル名にある処理日時のフォーマットが正しくない 姜 start
                  //					LocalDate localDate = LocalDate.now();
                  //					int month = localDate.getMonthValue();
                  //					int dayOfMonth = localDate.getDayOfMonth();
                  //					int year = localDate.getYear();
                  //					String dateString = String.valueOf(year) + String.valueOf(month) + String.valueOf(dayOfMonth);
 // del 10432 出力対象患者が複数名の時「単集計」帳票が全員出力されない。　杜 start
//                      Date date = new Date();
//                      SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
//                      String dateString = sdf.format(date);
                  // mod 5776 ファイル出力した時のファイル名にある処理日時のフォーマットが正しくない 姜 end
                  /*mod FNSI-改修内容帳票保存の時のファイル名が重複してしまう 任 start*/
                  /*String fileName = "帳票_[" + dateString + "]";*/
//                String fileName = reportName +"_[" + dateString + "]";
                  /*mod FNSI-改修内容装置帳票の対応 任 start*/
                  /*if(payload.getPatIds().size()==1){*/
 // del 10432 出力対象患者が複数名の時「単集計」帳票が全員出力されない。　杜 end
// add 10432 出力対象患者が複数名の時「単集計」帳票が全員出力されない。　杜 start
                  if (payload.getPatIds().size() == 1) {
                    /*mod FNSI-改修内容装置帳票の対応 任 end*/
                    PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(payload.getPatIds().get(0));
                    String lastName = patPersonalMain.getPat_last_name();
                    String firstName = patPersonalMain.getPat_first_name();
                    String name = lastName + firstName;
                    fileName = reportName + "_[" + name + "]_[" + dateString + "]";
                  }
                  /*mod FNSI-改修内容帳票保存の時のファイル名が重複してしまう 任 end*/
                  if (option == 1) {
                    fileName += ".pdf";
                  } else {
                    fileName += ".xlsx";
                  }
                  fileName = URLEncoder.encode(fileName, "UTF-8");
                  header.set(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=" + fileName);
                  return new ResponseEntity<>(file, header, HttpStatus.OK);
                } else if (fileListFirst != null && fileListFirst.size() > 1) {
                  /*mod FNSI-改修内容装置帳票の対応 任 start*/
//                List<Map<Long, List<byte[]>>> patFile = new ArrayList<>();
//                for(int i = 0; i < fileListFirst.size(); i++){
//                  Map<Long, List<byte[]>> patFileMap = new HashMap<>();
//                  List<byte[]> patFileListNew = new ArrayList<>();
//                  patFileListNew.add(fileListFirst.get(i).get(fileListFirst.get(i).keySet().iterator().next()));
//                  patFileMap.put(fileListFirst.get(i).keySet().iterator().next(),patFileListNew);
//                  patFile.add(patFileMap);
//                }
                  res = reportMenuService.zipFile(fileList, reportName, option, reportClass);

                  header.set("Content-Type", "application/octet-stream");
                  // mod #10616 選択患者分の帳票が出力されない 王永吉 start
                  /*mod FNSI-改修内容帳票保存の時のファイル名が重複してしまう 任 start*/
                  /*fileName += ".zip";*/
                  //fileName += "_[" + dateString + "].zip";
                  fileName += ".zip";
                  /*mod FNSI-改修内容帳票保存の時のファイル名が重複してしまう 任 end*/
                  // mod #10616 選択患者分の帳票が出力されない 王永吉 end
                }else if (file != null && file.length > 0) {
                header.set("Content-Type", "application/pdf");
                // mod 5776 ファイル出力した時のファイル名にある処理日時のフォーマットが正しくない 姜 start
                //					LocalDate localDate = LocalDate.now();
                //					int month = localDate.getMonthValue();
                //					int dayOfMonth = localDate.getDayOfMonth();
                //					int year = localDate.getYear();
                //					String dateString = String.valueOf(year) + String.valueOf(month) + String.valueOf(dayOfMonth);
                // mod 5776 ファイル出力した時のファイル名にある処理日時のフォーマットが正しくない 姜 end
                /*mod FNSI-改修内容帳票保存の時のファイル名が重複してしまう 任 start*/
                /*String fileName = "帳票_[" + dateString + "]";*/
                /*mod FNSI-改修内容装置帳票の対応 任 start*/
                /*if(payload.getPatIds().size()==1){*/
// add 10432 出力対象患者が複数名の時「単集計」帳票が全員出力されない。　杜 end
                if (payload.getPatIds().size() == 1) {
                  /*mod FNSI-改修内容装置帳票の対応 任 end*/
                  PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(payload.getPatIds().get(0));
                  String lastName = patPersonalMain.getPat_last_name();
                  String firstName = patPersonalMain.getPat_first_name();
                  String name = lastName + firstName;
                  fileName = reportName +"_[" + name + "]_[" + dateString + "]";
                }
                /*mod FNSI-改修内容帳票保存の時のファイル名が重複してしまう 任 end*/
                if (option == 1) {
                  fileName += ".pdf";
                } else {
                  fileName += ".xlsx";
                }
                fileName = URLEncoder.encode(fileName, "UTF-8");
                header.set(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=" + fileName);
                return new ResponseEntity<>(file, header, HttpStatus.OK);
              }  else {
                  return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
                }
              // add 10432 出力対象患者が複数名の時「単集計」帳票が全員出力されない。　杜 start

                // ファイル名に使用できない文字を置換
                fileName = fileName.replaceAll("[\\\\/:\\*\\?<>\\|]", "_");
                fileName = URLEncoder.encode(fileName, "UTF-8");
                header.set(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=" + fileName);

                if (res == null || res.length == 0) {
                  return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
                }
                return new ResponseEntity<>(res, header, HttpStatus.OK);
              // add 10432 出力対象患者が複数名の時「単集計」帳票が全員出力されない。　杜 end
              // add 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 start
            }
            // add 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 end
		  } else {
				if (option == 1) {
          // del 9316 施設設定マスタ125番の削除について　吉 start
//                    if(isUseAsposeCells){
                      // del 9316 施設設定マスタ125番の削除について　吉 end
                      if (reportClass == ReportConstant.ReportClass.ONE_PATIENT_REPORT) {
                        // 帳票種別：2：単患者帳票(PDF出力)
                        // ※ 常にAsposeを使用します

                        List<Map<Long, byte[]>> patExcelFileList = new ArrayList<>();
                        patExcelFileList = reportMenuService.getReportExcelFilesForOnePatient(payload, userNameStr);
                        for (int i = 0; i < patExcelFileList.size(); i++) {
                          // 患者データ毎のループ
                          for (Long key : patExcelFileList.get(i).keySet()) {
                            byte[] bytesList = patExcelFileList.get(i).get(key);
                            if (bytesList.length > 0) {
                              ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(bytesList);
                              ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                              URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
                              AsposeCellsUtils.excelToPdf(byteArrayInputStream,byteArrayOutputStream,url);
                              bytesList = byteArrayOutputStream.toByteArray();

                              // 他の処理と合わせるため、型を合わせる
                              List<byte[]> tmpReportFile = new ArrayList<>();
                              tmpReportFile.add(bytesList);
                              Map<Long, List<byte[]>> tmpReportMap = new HashMap<>();
                              tmpReportMap.put(key, tmpReportFile);
                              patFileList.add(tmpReportMap);
                            }
                          }
                        }

                      } else if (reportClass == ReportConstant.ReportClass.INTRODUCTION_REPORT) {
                        // 帳票種別：9：紹介状 集計なし(PDF出力)
                        // ※ 常にAsposeを使用します

                        // mod 9993 紹介状でプレビューのみ全く値が出力されないことがある　吉 start
                        // patFileList = reportMenuService.getExcelReportForIntroductionReport2(payload, userNameStr);
                        patFileList = reportMenuService.getExcelReportForIntroductionReport(payload, userNameStr);
                        // mod 9993 紹介状でプレビューのみ全く値が出力されないことがある　吉 end

                        for (int i = 0; i < patFileList.size(); i++) {
                          for (Long key : patFileList.get(i).keySet()) {
                            List<byte[]> bytesList = patFileList.get(i).get(key);
                            for (int j = 0; j < bytesList.size(); j++) {
                              byte[] data = bytesList.get(j);
                              if (data.length > 0) {
                                ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(data);
                                ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                                URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
                                AsposeCellsUtils.excelToPdf(byteArrayInputStream,byteArrayOutputStream,url);
                                bytesList.set(j,byteArrayOutputStream.toByteArray());
                              }
                            }
                          }
                        }
                      } else if (reportClass == ReportConstant.ReportClass.DIALYSIS_REPORT) {
                        // 帳票種別：1：治療経過表(PDF出力)
                        // ※ 常にAsposeを使用します

                        patFileList = reportMenuService.getExcelReportForDialysisReport(payload, userNameStr);

                        for (int i = 0; i < patFileList.size(); i++) {
                          for (Long key : patFileList.get(i).keySet()) {
                            List<byte[]> bytesList = patFileList.get(i).get(key);
                            for (int j = 0; j < bytesList.size(); j++) {
                              byte[] data = bytesList.get(j);
                              if (data.length > 0) {
                                ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(data);
                                ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                                URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
                                AsposeCellsUtils.excelToPdf(byteArrayInputStream,byteArrayOutputStream,url);
                                bytesList.set(j,byteArrayOutputStream.toByteArray());
                              }
                            }
                          }
                        }
                      } else if (reportClass == ReportConstant.ReportClass.MACHINE_REPORT) {
                        // 帳票種別：7：装置帳票(PDF出力)
                        // ※ 常にAsposeを使用します
                        // mod #11100 【総合検証NG】装置帳票＞定期点検（日常点検記録簿、定期点検記録簿）のプレビューができない。 limingzhe start
                        //patFileList = reportMenuService.getExcelReportForMachineReport(payload, userNameStr);
                        // del #12107 帳票印刷失敗通知が行われない limingzhe start
//                        try{
                        // del #12107 帳票印刷失敗通知が行われない limingzhe end
                          patFileList = reportMenuService.getExcelReportForMachineReport(payload, userNameStr);
                        // del #12107 帳票印刷失敗通知が行われない limingzhe start
//                        } catch (NtssException ntssException) {
//                          return new ResponseEntity<>(ntssException.getMessage(), HttpStatus.OK);
//                        }
                        // del #12107 帳票印刷失敗通知が行われない limingzhe end
                        // mod #11100 【総合検証NG】装置帳票＞定期点検（日常点検記録簿、定期点検記録簿）のプレビューができない。 limingzhe end
                        for (int i = 0; i < patFileList.size(); i++) {
                          for (Long key : patFileList.get(i).keySet()) {
                            List<byte[]> bytesList = patFileList.get(i).get(key);
                            for (int j = 0; j < bytesList.size(); j++) {
                              byte[] data = bytesList.get(j);
                              if (data.length > 0) {
                                ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(data);
                                ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                                URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
                                AsposeCellsUtils.excelToPdf(byteArrayInputStream,byteArrayOutputStream,url);
                                bytesList.set(j,byteArrayOutputStream.toByteArray());
                              }
                            }
                          }
                        }
                      }
                      // del 9316 施設設定マスタ125番の削除について　吉 start
//                    }else {
//                      // mod 8542 紹介状（集計あり。因島様にて使用）にて出力できない項目がある 吉 start
//                      // patHtmls = reportMenuService.getHtmlReport(payload, ntssUser.getUsername());
//                      patHtmls = reportMenuService.getHtmlReport(payload, userNameStr);
//                      // mod 8542 紹介状（集計あり。因島様にて使用）にて出力できない項目がある 吉 end
//                        if (patHtmls == null) {
//                            return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
//                        }
//                        if (patHtmls.size() <= 0) {
//                            return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
//                        }
//                        for (int i = 0; i < patHtmls.size(); i++) {
//                            Map<Long, List<byte[]>> patReport = new HashMap<>();
//                            for (Long key : patHtmls.get(i).keySet()) {
//                                List<String> htmls = patHtmls.get(i).get(key);
//                                List<byte[]> htmlByteList = new ArrayList<>();
//                                for (int j = 0; j < htmls.size(); j++) {
//                                    String html = htmls.get(j);
//                                    if(html.contains("layout-flow:vertical-ideographic;")){
//                                        html=html.replaceAll("layout-flow:vertical-ideographic;","writing-mode: vertical-rl;");
//                                    }
//                                    byte[] data = reportMenuService.convertHtmlToPdf(html);
//                                    htmlByteList.add(data);
//                                }
//                                patReport.put(key, htmlByteList);
//                            }
//                            patFileList.add(patReport);
//                        }
//                    }
                      // del 9316 施設設定マスタ125番の削除について　吉 end
				} else {
				  if (reportClass == ReportConstant.ReportClass.DIALYSIS_REPORT) {
                    // 帳票種別：1：治療経過表(Excel出力)

				    patFileList = reportMenuService.getExcelReportForDialysisReport(payload, userNameStr);

                  } else if (reportClass == ReportConstant.ReportClass.ONE_PATIENT_REPORT) {
                    // 帳票種別：2：単患者帳票(Excel出力)

				    List<Map<Long, byte[]>> patExcelFileList = new ArrayList<>();
				    patExcelFileList = reportMenuService.getReportExcelFilesForOnePatient(payload, userNameStr);
				    // 他の処理と合わせるため、型を合わせる
		            for (int i = 0; i < patExcelFileList.size(); i++) {
		              // 患者データ毎のループ
		              for (Long key : patExcelFileList.get(i).keySet()) {
		                byte[] bytesList = patExcelFileList.get(i).get(key);
		                List<byte[]> tmpReportFile = new ArrayList<>();
		                tmpReportFile.add(bytesList);
		                Map<Long, List<byte[]>> tmpReportMap = new HashMap<>();
		                tmpReportMap.put(key, tmpReportFile);
		                patFileList.add(tmpReportMap);
		              }
		            }
				  } else if (reportClass == ReportConstant.ReportClass.MACHINE_REPORT) {
                    // 帳票種別：7：装置帳票(Excel出力)


            // mod #11100 【総合検証NG】装置帳票＞定期点検（日常点検記録簿、定期点検記録簿）のプレビューができない。 limingzhe start
            //patFileList = reportMenuService.getExcelReportForMachineReport(payload, userNameStr);
            // del #12107 帳票印刷失敗通知が行われない limingzhe start
//            try{
            // del #12107 帳票印刷失敗通知が行われない limingzhe end
              patFileList = reportMenuService.getExcelReportForMachineReport(payload, userNameStr);
            // del #12107 帳票印刷失敗通知が行われない limingzhe start
//            } catch (NtssException ntssException) {
//              return new ResponseEntity<>(ntssException.getMessage(), HttpStatus.OK);
//            }
            // del #12107 帳票印刷失敗通知が行われない limingzhe end
            // mod #11100 【総合検証NG】装置帳票＞定期点検（日常点検記録簿、定期点検記録簿）のプレビューができない。 limingzhe end
                  } else if (reportClass == ReportConstant.ReportClass.INTRODUCTION_REPORT) {
                    // 帳票種別：9：紹介状 集計なし(PDF出力)
                    // mod 9993 紹介状でプレビューのみ全く値が出力されないことがある　吉 start
                    // patFileList = reportMenuService.getExcelReportForIntroductionReport2(payload, userNameStr);
                    patFileList = reportMenuService.getExcelReportForIntroductionReport(payload, userNameStr);
                    // mod 9993 紹介状でプレビューのみ全く値が出力されないことがある　吉 end
                  }
				}

				String fileName = "";
                // mod 5776 ファイル出力した時のファイル名にある処理日時のフォーマットが正しくない 姜 start
//				LocalDate localDate = LocalDate.now();
//				int month = localDate.getMonthValue();
//				int dayOfMonth = localDate.getDayOfMonth();
//				int year = localDate.getYear();
//				String dateString = String.valueOf(year) + String.valueOf(month) + String.valueOf(dayOfMonth);
                Date date = new Date();
                // mod #10616 選択患者分の帳票が出力されない 王永吉 start
                //SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
                SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmssSSS");
                // mod #10616 選択患者分の帳票が出力されない 王永吉 end
                String dateString = sdf.format(date);
                // mod 5776 ファイル出力した時のファイル名にある処理日時のフォーマットが正しくない 姜 end
        /*mod FNSI-改修内容帳票保存の時のファイル名が重複してしまう 任 start*/
        /*fileName = "帳票_[" + dateString + "]";*/
				fileName = reportName;
        /*mod FNSI-改修内容帳票保存の時のファイル名が重複してしまう 任 end*/
				HttpHeaders header = new HttpHeaders();
				byte[] res = null;

				if (patFileList.size() == 1) {
					for (Long key : patFileList.get(0).keySet()) {
						List<byte[]> bytesList = patFileList.get(0).get(key);
						if (bytesList.size() == 1) {
							res = bytesList.get(0);
              /*add FNSI-改修内容帳票保存の時のファイル名が重複してしまう 任 start*/
              /*add FNSI-改修内容装置帳票の対応 任 start*/
              if(reportClass == 7){
                fileName += "_[" + dateString + "]";
              }else{
                /*add FNSI-改修内容装置帳票の対応 任 end*/
                PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(key);
                String lastName = patPersonalMain.getPat_last_name();
                String firstName = patPersonalMain.getPat_first_name();
                String name = lastName + firstName;
                fileName += "_[" + name + "]_[" + dateString + "]";
                /*add FNSI-改修内容装置帳票の対応 任 start*/
              }
              /*add FNSI-改修内容装置帳票の対応 任 end*/
              /*add FNSI-改修内容帳票保存の時のファイル名が重複してしまう 任 end*/
							if (option == 1) {
								header.set("Content-Type", "application/pdf");
								fileName += ".pdf";
							} else {
								header.set("Content-Type", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
								fileName += ".xlsx";
							}
						} else {
							if (bytesList.size() > 1) {
                /*mod FNSI-改修内容装置帳票の対応 任 start*/
                /*res = reportMenuService.zipFile(patFileList, reportName, option);*/
								res = reportMenuService.zipFile(patFileList, reportName, option,reportClass);
                /*mod FNSI-改修内容装置帳票の対応 任 end*/
								header.set("Content-Type", "application/octet-stream");
                /*mod FNSI-改修内容帳票保存の時のファイル名が重複してしまう 任 start*/
                /*fileName += ".zip";*/
								fileName += "_["+ dateString +"].zip";
                /*mod FNSI-改修内容帳票保存の時のファイル名が重複してしまう 任 end*/
							}
						}
					}
				} else if (patFileList.size() > 1) {
          /*mod FNSI-改修内容装置帳票の対応 任 start*/
          /*res = reportMenuService.zipFile(patFileList, reportName, option);*/
					res = reportMenuService.zipFile(patFileList, reportName, option,reportClass);
          /*mod FNSI-改修内容装置帳票の対応 任 end*/
					header.set("Content-Type", "application/octet-stream");
          /*mod FNSI-改修内容帳票保存の時のファイル名が重複してしまう 任 start*/
          /*fileName += ".zip";*/
					fileName += "_["+ dateString +"].zip";
          /*mod FNSI-改修内容帳票保存の時のファイル名が重複してしまう 任 end*/
				} else {
					return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
				}

        // ファイル名に使用できない文字を置換
        fileName = fileName.replaceAll("[\\\\/:\\*\\?<>\\|]", "_");
				fileName = URLEncoder.encode(fileName, "UTF-8");
				header.set(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=" + fileName);

				if (res == null || res.length == 0) {
					return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
				}
				return new ResponseEntity<>(res, header, HttpStatus.OK);
			}
		} catch (Exception e) {
			EventLogMessage eventLogMessage = new EventLogMessage();
			// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
			logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_REPORT_MENU,SERVICE_NAME.FNSI, null);
        // add 2020-09-17 FNSI-不良修正 レイアウトデザイナーで削除後エラー処理追加 夏 start
        if(e.toString().indexOf("存在しない帳票マスタのレポートコードを指定されています。") !=-1)
        {
          return new ResponseEntity<>("レポート無", HttpStatus.OK);
        }
          // add 2020-09-17 FNSI-不良修正 レイアウトデザイナーで削除後エラー処理追加 夏 end
  		String errorMessage = "ファイルダウンロードに失敗しました";
  		return new ResponseEntity<>(errorMessage, HttpStatus.INTERNAL_SERVER_ERROR);
  	  }
	}
  //add  検索条件ログ対応 吉 start*/
  @PostMapping("/setLogEven")
  public ResponseEntity<?> getReportFile(
    @AuthenticationPrincipal NtssUser ntssUser,
    @RequestBody String payload
  ) {
    try {
      return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_REPORT_MENU,SERVICE_NAME.FNSI, null);
      String errorMessage = "検索条件ログ対応失敗しました";
      return new ResponseEntity<>(errorMessage, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  //add  検索条件ログ対応 吉 end*/
  //add 5565 並び替えを実施してもその情報が保持されない 吉 start
  @PostMapping("/saveSortList")
  public ResponseEntity<?> saveSortList(
    @AuthenticationPrincipal NtssUser ntssUser,
    @RequestBody String payload
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
      if(!ntssUser.isNkkAdminUser()) {
        JSONObject receiveData = new JSONObject(payload);
        if (!ntssUser.getFacilityCd().equals(receiveData.get("facilityCd").toString())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + receiveData.get("facilityCd").toString() + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 end

    try {
      MstReport po = new MstReport();
      JSONObject receiveData = new JSONObject(payload);
      po.setFacilityCd(receiveData.get("facilityCd").toString());
      po.setReportCd(Long.valueOf(receiveData.get("reportCd").toString()));
      po.setReportSetting(receiveData.get("sortTargets").toString());
      reportMenuService.saveSortList(po);
      return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_REPORT_MENU,SERVICE_NAME.FNSI, null);
      String errorMessage = "保存帳票の並べ替え失敗";
      return new ResponseEntity<>(errorMessage, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  @PostMapping("/getSortList/{reportCd}")
  public ResponseEntity<?> getSortList(
    @AuthenticationPrincipal NtssUser ntssUser,
    @PathVariable Long reportCd
  ) {
    try {
      MstReport po = reportMenuService.getSortList(ntssUser.getFacilityCd(), reportCd);
      return new ResponseEntity<>(po.getReportSetting(), HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_REPORT_MENU,SERVICE_NAME.FNSI, null);
      String errorMessage = "帳票獲得ソート失敗";
      return new ResponseEntity<>(errorMessage, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
//add 5565 並び替えを実施してもその情報が保持されない 吉 end
 // add #10633 【たくしん会】帳票のフォント問題 吉 start
  @PostMapping("/getSysFontsConfig")
  public ResponseEntity<?> getSysFontsConfig(
    @AuthenticationPrincipal NtssUser ntssUser
  ) {
    try {
      SysSystemDefine sysSystemDefine = sysSystemDefineDao.selectOnPremise(1013);
      Map<String, List<String>> result = new LinkedHashMap<>();
      String json = sysSystemDefine.getValue();
      ObjectMapper mapper = new ObjectMapper();
      JsonNode root = mapper.readTree(json);
      JsonNode fontconfig = root.get("fontconfig");
      for (JsonNode aliasWrapper : fontconfig) {
        JsonNode alias = aliasWrapper.get("alias");
        String mainFont = alias.get("family").asText();
        List<String> prefers = new ArrayList<>();

        JsonNode preferArray = alias.get("prefer");
        if (preferArray != null && preferArray.isArray()) {
          for (JsonNode p : preferArray) {
            prefers.add(p.get("family").asText());
          }
        }
        result.put(mainFont, prefers);
      }
      return new ResponseEntity<>(result, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_REPORT_MENU,SERVICE_NAME.FNSI, null);
      String errorMessage = "フォント獲得ソート失敗";
      return new ResponseEntity<>(errorMessage, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  // add #10633 【たくしん会】帳票のフォント問題 吉 end

	/**
	 * 帳票を印刷する.
	 *
	 * @param payload 帳票生成の為に必要なパラメータ
   * @param ntssUser 利用者情報
	 * @return 印刷要求を正常に送信出来た場合に、{@link HttpStatus#OK}を格納した{@link ResponseEntity}を返却する.
	 */
	@PostMapping("/printReport")
	public ResponseEntity<?> printReport(
	  @RequestBody ReportMenuSortContainer payload,
    @AuthenticationPrincipal NtssUser ntssUser
    ) {
        // 毛　ログ改善対応 Add Start
        EventLogMessage eventLogMessage = new EventLogMessage();
        // 毛　ログ改善対応 Add End
    // add 8542 紹介状（集計あり。因島様にて使用）にて出力できない項目がある 吉 start
    String userNameStr = mstPersonalUserDao.selectUserNameById(ntssUser.getUserId());
    // add 8542 紹介状（集計あり。因島様にて使用）にて出力できない項目がある 吉 end
    // add 11009 カテゴリ「印刷情報」の仕様調整 房 start
    // パラメータの標準化
    requestParamEdit(payload, userNameStr);
    // add 11009 カテゴリ「印刷情報」の仕様調整 房 end
    // プリンタコードを取得.
		Long printerCd = payload.getPrinterCd();
		// 帳票名を取得.
		String reportName = payload.getReportName();
    // ファイル名に使用できない文字を置換
    reportName = reportName.replaceAll("[\\\\/:\\*\\?<>\\|]", "_");
		// 帳票種別を取得.
		Integer reportClass = payload.getReportClass();

    //add #9616 帳票印刷失敗通知がされない 李 start
    String reportType = "";
    if (reportClass.equals(ReportConstant.ReportClass.DIALYSIS_REPORT)) {
      reportType = "治療経過表";
    }else if (reportClass.equals(ReportConstant.ReportClass.ONE_PATIENT_REPORT)) {
      reportType = "単患者帳票";
    }else if (reportClass.equals(ReportConstant.ReportClass.MULTIPLE_PATIENT_REPORT)) {
      reportType = "複数患者帳票";
    }else if (reportClass.equals(ReportConstant.ReportClass.PREPARATION_LIST_REPORT)) {
      reportType = "準備リスト";
    }else if (reportClass.equals(ReportConstant.ReportClass.DISTRIBUTION_LIST_BED_REPORT)) {
      reportType = "配布リスト(ベッド)";
    }else if (reportClass.equals(ReportConstant.ReportClass.DISTRIBUTION_LIST_GOODS_REPORT)) {
      reportType = "配布リスト(物品)";
    }else if (reportClass.equals(ReportConstant.ReportClass.MACHINE_REPORT)) {
      reportType = "装置帳票";
    }else if (reportClass.equals(ReportConstant.ReportClass.LABEL_REPORT)) {
      reportType = "ラベル";
    }else if (reportClass.equals(ReportConstant.ReportClass.INTRODUCTION_REPORT)) {
      reportType = "紹介状";
    }else if (reportClass.equals(ReportConstant.ReportClass.ONE_TOTAL_REPORT)) {
      reportType = "単集計";
    }else if (reportClass.equals(ReportConstant.ReportClass.MULTI_TOTAL_REPORT)) {
      reportType = "複数集計";
    }
    //add #9616 帳票印刷失敗通知がされない 李 end
    //add #10504 一日複数回指示ある患者の治療経過表出力で空帳票が出力される 王永吉 start
    reportMenuService.getOption(true);
    //add #10504 一日複数回指示ある患者の治療経過表出力で空帳票が出力される 王永吉 end
    /*add FNSI-改修内容装置帳票の対応 任 start*/
    // mod #6426 2022-01-12 定期点検の帳票がシステムエラーとなる。孟堅　start
    // if(payload.getReportCd()){
    if(printerCd == null){
      try{
        printerCd = reportMenuService.getReportCd(payload);
        // add 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 start
        if(StringUtils.isEmpty(printerCd)){
          List<FacilitySettingInfo> settingInfoList = mstFacilitySettingDao.selectFacilitySetting(ntssUser.getFacilityCd(), CoreConstant.FacilitySettingNo.DEFAULT_PRINTER);
          if(null != settingInfoList && settingInfoList.size()>0 && null != settingInfoList.get(0).getValue()){
            String defaulPrinter = settingInfoList.get(0).getValue();
            printerCd = Long.valueOf(defaulPrinter);
          }
        }
        // add 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 end
      } catch (Exception e) {
        printerCd = null;
      }
    }
    // mod #6426 2022-01-12 定期点検の帳票がシステムエラーとなる。孟堅　end
    /*add FNSI-改修内容装置帳票の対応 任 end*/

        // 毛　ログ改善対応 Add Start
        eventLogMessage.setLogMessage("プリンタコード: " + printerCd + " 帳票名: " + reportName + " 帳票種別: " + reportClass);
        logService.log(LogLevel.INFO, eventLogMessage,FUNCTION_CODE.FUNC_REPORT_MENU,SERVICE_NAME.FNSI, null);
        // 毛　ログ改善対応 Add End

		try {
      //add  Aspose.cells plug-in integration  吉 start
      // del 9316 施設設定マスタ125番の削除について　吉 start
//      boolean isUseAsposeCells = true;
//      FacilitySettingInfo settingValue = mstFacilitySettingDao.getBySettingNoAndCd(ntssUser.getFacilityCd(),CoreConstant.FacilitySettingNo.PREVIEW_MODE);
//      if(settingValue != null && settingValue.getValue().equals("1")){
//        isUseAsposeCells = false;
//      }
      // del 9316 施設設定マスタ125番の削除について　吉 end
        //add  Aspose.cells plug-in integration  吉 end
		// 帳票種別が複数患者帳票以上の場合
        //mod 帳票印刷の命名規則が変更されました 吉 start
        //      if (reportClass.compareTo(ReportConstant.ReportClass.MULTIPLE_PATIENT_REPORT) >= 0) {
		if (reportClass.compareTo(ReportConstant.ReportClass.PREPARATION_LIST_REPORT) >= 0 && reportClass != ReportConstant.ReportClass.INTRODUCTION_REPORT) {
          //add  Aspose.cells plug-in integration  吉 start
  		  byte[] file = null;
          // mod Aspose.cells関連問題8の対応 夏 start
  		  //			  if(isUseAsposeCells && reportClass == ReportConstant.ReportClass.LABEL_REPORT){
          // del 9316 施設設定マスタ125番の削除について　吉 start
//          if(isUseAsposeCells){
            // del 9316 施設設定マスタ125番の削除について　吉 end
            if (reportClass.equals(ReportConstant.ReportClass.PREPARATION_LIST_REPORT)) {
              // 帳票種別：4：準備リスト
              // ※ 常にAsposeを使用します
              List<Map<Long, List<byte[]>>> patExcelFileList = new ArrayList<>();

              file = reportMenuService.getExcelReportForPreparationList(payload, userNameStr);
                // add #10982 データ抽出条件の医療材料／薬剤の動作不良 limingzhe start
              if(file == null || file.length == 0){
                return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
              }
              // add #10982 データ抽出条件の医療材料／薬剤の動作不良 limingzhe end
              if (file.length > 0) {
                ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(file);
                ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
                AsposeCellsUtils.excelToPdf(byteArrayInputStream,byteArrayOutputStream,url);
                file = byteArrayOutputStream.toByteArray();

                // 他の処理と合わせるため、型を合わせる
                List<byte[]> tmpReportFile = new ArrayList<>();
                tmpReportFile.add(file);
                Map<Long, List<byte[]>> tmpReportMap = new HashMap<>();
                tmpReportMap.put(0L, tmpReportFile);
                patExcelFileList.add(tmpReportMap);
              }

              //mod #9616 帳票印刷失敗通知がされない 李 start
//              reportMenuService.printPdfReportForMultiplePatient(patExcelFileList,reportName, printerCd);
              reportMenuService.printPdfReportForMultiplePatient(patExcelFileList,reportName, printerCd, reportType);
              //mod #9616 帳票印刷失敗通知がされない 李 start

            } else if (reportClass.equals(ReportConstant.ReportClass.DISTRIBUTION_LIST_BED_REPORT)) {
              // 帳票種別：5：配布リスト（ベッド）
              // ※ 常にAsposeを使用します
              List<Map<Long, List<byte[]>>> patExcelFileList = new ArrayList<>();

              file = reportMenuService.getExcelReportForDistributionListBed(payload, userNameStr);
              // add #10982 データ抽出条件の医療材料／薬剤の動作不良 limingzhe start
              if(file == null || file.length == 0){
                return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
              }
              // add #10982 データ抽出条件の医療材料／薬剤の動作不良 limingzhe end
              if (file.length > 0) {
                ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(file);
                ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
                AsposeCellsUtils.excelToPdf(byteArrayInputStream,byteArrayOutputStream,url);
                file = byteArrayOutputStream.toByteArray();

                // 他の処理と合わせるため、型を合わせる
                List<byte[]> tmpReportFile = new ArrayList<>();
                tmpReportFile.add(file);
                Map<Long, List<byte[]>> tmpReportMap = new HashMap<>();
                tmpReportMap.put(0L, tmpReportFile);
                patExcelFileList.add(tmpReportMap);
              }

              //mod #9616 帳票印刷失敗通知がされない 李 start
//              reportMenuService.printPdfReportForMultiplePatient(patExcelFileList,reportName, printerCd);
              reportMenuService.printPdfReportForMultiplePatient(patExcelFileList,reportName, printerCd, reportType);
              //mod #9616 帳票印刷失敗通知がされない 李 start

            } else if (reportClass.equals(ReportConstant.ReportClass.DISTRIBUTION_LIST_GOODS_REPORT)) {
              // 帳票種別：6：配布リスト（物品）
              // ※ 常にAsposeを使用します
              List<Map<Long, List<byte[]>>> patExcelFileList = new ArrayList<>();

              file = reportMenuService.getExcelReportForDistributionListGoods(payload, userNameStr);
              // add #10982 データ抽出条件の医療材料／薬剤の動作不良 limingzhe start
              if(file == null || file.length == 0){
                return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
              }
              // add #10982 データ抽出条件の医療材料／薬剤の動作不良 limingzhe end
              if (file.length > 0) {
                ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(file);
                ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
                AsposeCellsUtils.excelToPdf(byteArrayInputStream,byteArrayOutputStream,url);
                file = byteArrayOutputStream.toByteArray();

                // 他の処理と合わせるため、型を合わせる
                List<byte[]> tmpReportFile = new ArrayList<>();
                tmpReportFile.add(file);
                Map<Long, List<byte[]>> tmpReportMap = new HashMap<>();
                tmpReportMap.put(0L, tmpReportFile);
                patExcelFileList.add(tmpReportMap);
              }

              //mod #9616 帳票印刷失敗通知がされない 李 start
//              reportMenuService.printPdfReportForMultiplePatient(patExcelFileList,reportName, printerCd);
              reportMenuService.printPdfReportForMultiplePatient(patExcelFileList,reportName, printerCd, reportType);
              //mod #9616 帳票印刷失敗通知がされない 李 start

            } else if (reportClass.equals(ReportConstant.ReportClass.MACHINE_REPORT)) {
              // 帳票種別：7：装置帳票
              // ※ 常にAsposeを使用します

              // add #10982 データ抽出条件の医療材料／薬剤の動作不良 limingzhe start
              boolean bHavetoShow = false;
              // add #10982 データ抽出条件の医療材料／薬剤の動作不良 limingzhe end

              // mod #11100 【総合検証NG】装置帳票＞定期点検（日常点検記録簿、定期点検記録簿）のプレビューができない。 limingzhe start
              //List<Map<Long, List<byte[]>>> patExcelFileList = reportMenuService.getExcelReportForMachineReport(payload, userNameStr);
              List<Map<Long, List<byte[]>>> patExcelFileList = new ArrayList<>();
              // del #12107 帳票印刷失敗通知が行われない limingzhe start
//              try {
              // del #12107 帳票印刷失敗通知が行われない limingzhe end
                patExcelFileList = reportMenuService.getExcelReportForMachineReport(payload, userNameStr);
              // del #12107 帳票印刷失敗通知が行われない limingzhe start
//              } catch (NtssException ntssException) {
//                return new ResponseEntity<>(ntssException.getMessage(), HttpStatus.OK);
//              }
              // del #12107 帳票印刷失敗通知が行われない limingzhe end
              // mod #11100 【総合検証NG】装置帳票＞定期点検（日常点検記録簿、定期点検記録簿）のプレビューができない。 limingzhe end
              for (int i = 0; i < patExcelFileList.size(); i++) {
                for (Long key : patExcelFileList.get(i).keySet()) {
                  List<byte[]> bytesList = patExcelFileList.get(i).get(key);
                  for (int j = 0; j < bytesList.size(); j++) {
                    byte[] excelFileBytes = bytesList.get(j);
                    if (excelFileBytes.length > 0) {
                      ByteArrayInputStream excelByesIS = new ByteArrayInputStream(excelFileBytes);
                      ByteArrayOutputStream excelBytesOS = new ByteArrayOutputStream();
                      URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
                      AsposeCellsUtils.excelToPdf(excelByesIS,excelBytesOS,url);
                      bytesList.set(j,excelBytesOS.toByteArray());
                      // add #10982 データ抽出条件の医療材料／薬剤の動作不良 limingzhe start
                      bHavetoShow = true;
                      // add #10982 データ抽出条件の医療材料／薬剤の動作不良 limingzhe end
                    }
                  }
                }
              }
              // add #10982 データ抽出条件の医療材料／薬剤の動作不良 limingzhe start
              if(!bHavetoShow){
                return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
              }
              // add #10982 データ抽出条件の医療材料／薬剤の動作不良 limingzhe end
              //mod #9616 帳票印刷失敗通知がされない 李 start
//              reportMenuService.printPdfReportForMultiplePatient(patExcelFileList,reportName, printerCd);
              reportMenuService.printPdfReportForMultiplePatient(patExcelFileList,reportName, printerCd, reportType);
              //mod #9616 帳票印刷失敗通知がされない 李 start

            } else if (reportClass.equals(ReportConstant.ReportClass.LABEL_REPORT)) {
              // 帳票種別：8：ラベル
              // ※ 常にAsposeを使用します
              List<Map<Long, List<byte[]>>> patExcelFileList = new ArrayList<>();

              file = reportMenuService.getExcelReportForLabelReport(payload, userNameStr);

              if (file.length > 0) {
                ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(file);
                ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
                AsposeCellsUtils.excelToPdf(byteArrayInputStream,byteArrayOutputStream,url);
                file = byteArrayOutputStream.toByteArray();

                // 他の処理と合わせるため、型を合わせる
                List<byte[]> tmpReportFile = new ArrayList<>();
                tmpReportFile.add(file);
                Map<Long, List<byte[]>> tmpReportMap = new HashMap<>();
                tmpReportMap.put(0L, tmpReportFile);
                patExcelFileList.add(tmpReportMap);
              }
              // add #10982 データ抽出条件の医療材料／薬剤の動作不良 limingzhe start
              if(patExcelFileList == null || patExcelFileList.size() == 0){
                // mod #12107 帳票印刷失敗通知が行われない limingzhe start
                //return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
                throw new NtssException("該当データが存在していません。");
                // mod #12107 帳票印刷失敗通知が行われない limingzhe end
              }
              // add #10982 データ抽出条件の医療材料／薬剤の動作不良 limingzhe end
              //mod #9616 帳票印刷失敗通知がされない 李 start
//              reportMenuService.printPdfReportForMultiplePatient(patExcelFileList,reportName, printerCd);
              reportMenuService.printPdfReportForMultiplePatient(patExcelFileList,reportName, printerCd, reportType);
              //mod #9616 帳票印刷失敗通知がされない 李 start

            } else if (reportClass.equals(ReportConstant.ReportClass.ONE_TOTAL_REPORT)) {
              // 帳票種別：10：単集計
              // ※ 常にAsposeを使用します
              List<Map<Long, List<byte[]>>> patExcelFileList = new ArrayList<>();
            // mod 10432 出力対象患者が複数名の時「単集計」帳票が全員出力されない。　杜 start
              List<Map<Long, List<byte[]>>> patExcelFileListNew = new ArrayList<>();
              List<Map<Long, byte[]>> fileList = new ArrayList<>();
              // add 10546 単集計出力時にページ数の制限 gjn start
              // del #12107 帳票印刷失敗通知が行われない limingzhe start
//              try {
              // del #12107 帳票印刷失敗通知が行われない limingzhe end
                patExcelFileListNew = reportMenuService.getExcelReportForOneTotal(payload, userNameStr);
              // del #12107 帳票印刷失敗通知が行われない limingzhe start
//              } catch (NtssException ntssException) {
//                return new ResponseEntity<>(ntssException.getMessage(), HttpStatus.OK);
//              }
              // del #12107 帳票印刷失敗通知が行われない limingzhe end
              // add 10546 単集計出力時にページ数の制限 gjn end
              for (int i = 0; i < patExcelFileListNew.size(); i++) {
                for (Long key : patExcelFileListNew.get(i).keySet()) {
                  List<byte[]> bytesList = patExcelFileListNew.get(i).get(key);
                  for (int j = 0; j < bytesList.size(); j++) {
                    byte[] data = bytesList.get(j);
                    if (data.length > 0) {
                      ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(data);
                      ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                      URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
                      AsposeCellsUtils.excelToPdf(byteArrayInputStream,byteArrayOutputStream,url);
                      data = byteArrayOutputStream.toByteArray();

                      // 他の処理と合わせるため、型を合わせる
                      List<byte[]> tmpReportFile = new ArrayList<>();
                      tmpReportFile.add(data);
                      Map<Long, List<byte[]>> tmpReportMap = new HashMap<>();
                      // mod #10616 選択患者分の帳票が出力されない 王永吉 start
                      //tmpReportMap.put(0L, tmpReportFile);
                      tmpReportMap.put(key, tmpReportFile);
                      // mod #10616 選択患者分の帳票が出力されない 王永吉 end
                      patExcelFileList.add(tmpReportMap);
                    }
                  }
                }
            // mod 10432 出力対象患者が複数名の時「単集計」帳票が全員出力されない。　杜 end
              }
              // add #10982 データ抽出条件の医療材料／薬剤の動作不良 limingzhe start
              if(patExcelFileList == null || patExcelFileList.size() == 0){
                return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
              }
              // add #10982 データ抽出条件の医療材料／薬剤の動作不良 limingzhe end
              //mod #9616 帳票印刷失敗通知がされない 李 start
//              reportMenuService.printPdfReportForMultiplePatient(patExcelFileList,reportName, printerCd);
              // mod #10616 選択患者分の帳票が出力されない 王永吉 start
              //reportMenuService.printPdfReportForMultiplePatient(patExcelFileList,reportName, printerCd, reportType);
              reportMenuService.printPdfReport(patExcelFileList,reportName, printerCd);
              // mod #10616 選択患者分の帳票が出力されない 王永吉 end
              //mod #9616 帳票印刷失敗通知がされない 李 start

            } else if (reportClass.equals(ReportConstant.ReportClass.MULTI_TOTAL_REPORT)) {
              // 帳票種別：11：複数集計
              // ※ 常にAsposeを使用します
              List<Map<Long, List<byte[]>>> patExcelFileList = new ArrayList<>();

              // mod 10546 複数集計出力時にページ数の制限 gjn start
              // del #12107 帳票印刷失敗通知が行われない limingzhe start
//              try {
              // del #12107 帳票印刷失敗通知が行われない limingzhe end
                //file = reportMenuService.getExcelReportForMultiTotal(payload, userNameStr);
                file = reportMenuService.getExcelReportForMultiTotalHighPerformanceVersion(payload, userNameStr);
              // del #12107 帳票印刷失敗通知が行われない limingzhe start
//              } catch (NtssException ntssException) {
//                return new ResponseEntity<>(ntssException.getMessage(), HttpStatus.OK);
//              }
              // del #12107 帳票印刷失敗通知が行われない limingzhe end
              // mod 10546 複数集計出力時にページ数の制限 gjn end

              if (file.length > 0) {
                ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(file);
                ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
                AsposeCellsUtils.excelToPdf(byteArrayInputStream,byteArrayOutputStream,url);
                file = byteArrayOutputStream.toByteArray();

                // 他の処理と合わせるため、型を合わせる
                List<byte[]> tmpReportFile = new ArrayList<>();
                tmpReportFile.add(file);
                Map<Long, List<byte[]>> tmpReportMap = new HashMap<>();
                tmpReportMap.put(0L, tmpReportFile);
                patExcelFileList.add(tmpReportMap);
              }
              // add #10982 データ抽出条件の医療材料／薬剤の動作不良 limingzhe start
              if(patExcelFileList == null || patExcelFileList.size() == 0){
                return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
              }
              // add #10982 データ抽出条件の医療材料／薬剤の動作不良 limingzhe end
              //mod #9616 帳票印刷失敗通知がされない 李 start
//              reportMenuService.printPdfReportForMultiplePatient(patExcelFileList,reportName, printerCd);
              reportMenuService.printPdfReportForMultiplePatient(patExcelFileList,reportName, printerCd, reportType);
              //mod #9616 帳票印刷失敗通知がされない 李 start

            }
            // del 9316 施設設定マスタ125番の削除について　吉 start
//          }else{
//            //add  Aspose.cells plug-in integration  吉 end
//            //mod 帳票印刷の命名規則が変更されました 吉 end
//            // add FNSI-523 2次元帳票の印刷不良対応 夏 start
//            ReportServiceImpl.iLoop = 1;
//            // add FNSI-523 2次元帳票の印刷不良対応 夏 end
//            // html生成
//            // mod 8542 紹介状（集計あり。因島様にて使用）にて出力できない項目がある 吉 start
//            // String reportHtml = reportMenuService.getHtmlReportSorted(payload, ntssUser.getUserId(), ntssUser.getUsername());
//            String reportHtml = reportMenuService.getHtmlReportSorted(payload, ntssUser.getUserId(), userNameStr);
//            // mod 8542 紹介状（集計あり。因島様にて使用）にて出力できない項目がある 吉 end
//            // htmlがnullまたは空文字の場合
//            if (StringUtils.isEmpty(reportHtml)) {
//              // 毛　ログ改善対応 Add Start
//              eventLogMessage.setLogMessage("複数患者帳票印刷失敗");
//              logService.log(LogLevel.INFO, eventLogMessage,FUNCTION_CODE.FUNC_REPORT_MENU,SERVICE_NAME.FNSI, null);
//              // 毛　ログ改善対応 Add End
//              return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
//            }
//            //mod 帳票印刷の命名規則が変更されました 吉 start
//            //                reportMenuService.printReportMultiPat(reportHtml, printerCd);
//            reportMenuService.printReportMultiPat(reportHtml, printerCd,reportName);
//            //mod 帳票印刷の命名規則が変更されました 吉 end
//            // 毛　ログ改善対応 Add Start
//            eventLogMessage.setLogMessage("複数患者帳票出力成功");
//            logService.log(LogLevel.INFO, eventLogMessage,FUNCTION_CODE.FUNC_REPORT_MENU,SERVICE_NAME.FNSI, null);
//            // 毛　ログ改善対応 Add End
//            //add  Aspose.cells plug-in integration  吉 start
//          }
            // del 9316 施設設定マスタ125番の削除について　吉 start
        //add  Aspose.cells plug-in integration  吉 end
        } else if (reportClass.equals(ReportConstant.ReportClass.DIALYSIS_REPORT)) {
          // 帳票種別：1：治療経過表
          // ※ 常にAsposeを使用します

          List<Map<Long, List<byte[]>>> patExcelFileList = reportMenuService.getExcelReportForDialysisReport(payload, userNameStr);
          for (int i = 0; i < patExcelFileList.size(); i++) {
            for (Long key : patExcelFileList.get(i).keySet()) {
              List<byte[]> bytesList = patExcelFileList.get(i).get(key);
              for (int j = 0; j < bytesList.size(); j++) {
                byte[] excelFileBytes = bytesList.get(j);
                if (excelFileBytes.length > 0) {
                  ByteArrayInputStream excelByesIS = new ByteArrayInputStream(excelFileBytes);
                  ByteArrayOutputStream excelBytesOS = new ByteArrayOutputStream();
                  URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
                  AsposeCellsUtils.excelToPdf(excelByesIS,excelBytesOS,url);
                  bytesList.set(j,excelBytesOS.toByteArray());
                }
              }
            }
          }
          // add #10982 データ抽出条件の医療材料／薬剤の動作不良 limingzhe start
          if(patExcelFileList == null || patExcelFileList.size() == 0){
            return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
          }
          // add #10982 データ抽出条件の医療材料／薬剤の動作不良 limingzhe end
          reportMenuService.printPdfReport(patExcelFileList,reportName, printerCd);

        } else if (reportClass.equals(ReportConstant.ReportClass.ONE_PATIENT_REPORT)) {
          // 帳票種別：2：単患者帳票
          // ※ 常にAsposeを使用します

          List<Map<Long, List<byte[]>>> patExcelFileList = new ArrayList<>();
          List<Map<Long, byte[]>> tmpPatExcelFileList = reportMenuService.getReportExcelFilesForOnePatient(payload, userNameStr);
          for (int i = 0; i < tmpPatExcelFileList.size(); i++) {
            // 複数の患者を選択して繰り返し処理
            for (Long key : tmpPatExcelFileList.get(i).keySet()) {
              byte[] bytesList = tmpPatExcelFileList.get(i).get(key);
              if (bytesList.length > 0) {
                ByteArrayInputStream excelByesIS = new ByteArrayInputStream(bytesList);
                ByteArrayOutputStream excelBytesOS = new ByteArrayOutputStream();
                URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
                AsposeCellsUtils.excelToPdf(excelByesIS,excelBytesOS,url);

                // 他の処理と合わせるため、型を合わせる
                List<byte[]> tmpReportFile = new ArrayList<>();
                tmpReportFile.add(excelBytesOS.toByteArray());
                Map<Long, List<byte[]>> tmpReportMap = new HashMap<>();
                tmpReportMap.put(key, tmpReportFile);
                patExcelFileList.add(tmpReportMap);
              }

            }
          }
          // add #10982 データ抽出条件の医療材料／薬剤の動作不良 limingzhe start
          if(patExcelFileList == null || patExcelFileList.size() == 0){
            return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
          }
          // add #10982 データ抽出条件の医療材料／薬剤の動作不良 limingzhe end
          reportMenuService.printPdfReport(patExcelFileList,reportName, printerCd);

        } else if (reportClass.equals(ReportConstant.ReportClass.MULTIPLE_PATIENT_REPORT)) {
          // 帳票種別：3：複数患者帳票
          // ※ 常にAsposeを使用します
          List<Map<Long, List<byte[]>>> patExcelFileList = new ArrayList<>();

          byte[] file = null;

          file = reportMenuService.getReportExcelFilesForMultiplePatient(payload, userNameStr);

          if (file.length > 0) {
            ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(file);
            ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
            URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
            AsposeCellsUtils.excelToPdf(byteArrayInputStream,byteArrayOutputStream,url);
            file = byteArrayOutputStream.toByteArray();

            // 他の処理と合わせるため、型を合わせる
            List<byte[]> tmpReportFile = new ArrayList<>();
            tmpReportFile.add(file);
            Map<Long, List<byte[]>> tmpReportMap = new HashMap<>();
            tmpReportMap.put(0L, tmpReportFile);
            patExcelFileList.add(tmpReportMap);
          }
          // add #10982 データ抽出条件の医療材料／薬剤の動作不良 limingzhe start
          if(patExcelFileList == null || patExcelFileList.size() == 0){
            return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
          }
          // add #10982 データ抽出条件の医療材料／薬剤の動作不良 limingzhe end
      //mod #9616 帳票印刷失敗通知がされない 李 start
//              reportMenuService.printPdfReportForMultiplePatient(patExcelFileList,reportName, printerCd);
      reportMenuService.printPdfReportForMultiplePatient(patExcelFileList, reportName, printerCd, reportType);
      //mod #9616 帳票印刷失敗通知がされない 李 start

        } else if (reportClass.equals(ReportConstant.ReportClass.INTRODUCTION_REPORT)) {
          // 帳票種別：9：紹介状
          // ※ 常にAsposeを使用します
          List<Map<Long, List<byte[]>>> patExcelFileList = new ArrayList<>();
          // mod 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 start
          List<Map<Long, List<byte[]>>> file = null;
          // byte[] file = null;
          // mod 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 end

          file = reportMenuService.getExcelReportForIntroductionReport(payload, userNameStr);
// mod 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 start
//          if (file.length > 0) {
//            ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(file);
//            ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
//            URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
//            AsposeCellsUtils.excelToPdf(byteArrayInputStream,byteArrayOutputStream,url);
//            file = byteArrayOutputStream.toByteArray();
//
//            // 他の処理と合わせるため、型を合わせる
//            List<byte[]> tmpReportFile = new ArrayList<>();
//            tmpReportFile.add(file);
//            Map<Long, List<byte[]>> tmpReportMap = new HashMap<>();
//            tmpReportMap.put(0L, tmpReportFile);
//            patExcelFileList.add(tmpReportMap);
//          }


      Map<Long, List<byte[]>> tmpReportMap = new HashMap<>();
      for (int i = 0; i < file.size(); i++) {
        for (Long key : file.get(i).keySet()) {
          List<byte[]> bytesList = file.get(i).get(key);
          // add #12324 紹介状の出力時にpat_eventを参照する zhao start
          List<byte[]> tmpReportFile = new ArrayList<>();
          // add #12324 紹介状の出力時にpat_eventを参照する zhao end
          for (int j = 0; j < bytesList.size(); j++) {
            byte[] data = bytesList.get(j);
            if (data.length > 0) {
              ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(data);
              ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
              URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
              AsposeCellsUtils.excelToPdf(byteArrayInputStream,byteArrayOutputStream,url);

              // 他の処理と合わせるため、型を合わせる
              // del #12324 紹介状の出力時にpat_eventを参照する zhao start
              //List<byte[]> tmpReportFile = new ArrayList<>();
              // del #12324 紹介状の出力時にpat_eventを参照する zhao end
              tmpReportFile.add(byteArrayOutputStream.toByteArray());
              // mod #10616 選択患者分の帳票が出力されない 王永吉 start
              //tmpReportMap.put(Long.parseLong(String.valueOf(i)), tmpReportFile);
              // del #12324 紹介状の出力時にpat_eventを参照する zhao start
              //tmpReportMap.put(Long.parseLong(String.valueOf(key)), tmpReportFile);
              // del #12324 紹介状の出力時にpat_eventを参照する zhao end
              // mod #10616 選択患者分の帳票が出力されない 王永吉 end
              byteArrayOutputStream.close();
              byteArrayInputStream.close();
            }
          }
          // add #12324 紹介状の出力時にpat_eventを参照する zhao start
          if(bytesList.size() > 0){
            tmpReportMap.put(Long.parseLong(String.valueOf(key)), tmpReportFile);
          }
          // add #12324 紹介状の出力時にpat_eventを参照する zhao end
        }
      }
      // add #10982 データ抽出条件の医療材料／薬剤の動作不良 limingzhe start
      if(tmpReportMap == null || tmpReportMap.size() == 0){
        return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
      }
      // add #10982 データ抽出条件の医療材料／薬剤の動作不良 limingzhe end
      patExcelFileList.add(tmpReportMap);
      // mod 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 end



      //mod #9616 帳票印刷失敗通知がされない 李 start
      // mod 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 start
//              reportMenuService.printPdfReportForMultiplePatient(patExcelFileList,reportName, printerCd);
       // mod #10616 選択患者分の帳票が出力されない 王永吉 start
       //reportMenuService.printPdfReportForReferralLetter(patExcelFileList,reportName, printerCd, reportType);
       reportMenuService.printPdfReport(patExcelFileList,reportName, printerCd);
       // mod #10616 選択患者分の帳票が出力されない 王永吉 end
      // mod 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 end
      //mod #9616 帳票印刷失敗通知がされない 李 start

        }
		} catch (Exception e) {
          // add 2020-09-17 FNSI-不良修正 レイアウトデザイナーで削除後エラー処理追加 夏 start
          if(e.toString().indexOf("存在しない帳票マスタのレポートコードを指定されています。") !=-1)
            {
              return new ResponseEntity<>("レポート無", HttpStatus.OK);
            }
          // add 2020-09-17 FNSI-不良修正 レイアウトデザイナーで削除後エラー処理追加 夏 end
		  String message = "Error when print report";
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end

      //add #9616 帳票印刷失敗通知がされない 李 start
      // mod #12107 帳票印刷失敗通知が行われない limingzhe start
      //printerService.saveNotiMessage(reportType, reportName, printerCd.toString());
      printerService.saveNotiMessage(reportType, reportName, payload.getFacilityCd());
      // mod #12107 帳票印刷失敗通知が行われない limingzhe end
      //add #9616 帳票印刷失敗通知がされない 李 end

		  return new ResponseEntity<>(message, HttpStatus.INTERNAL_SERVER_ERROR);
  		}
    // UPD 2020-09-21 FNSI-仕様追加 出力データなしの場合に帳票も表示する 夏 start
		//return new ResponseEntity<>(HttpStatus.OK);
        return new ResponseEntity<>("OK",HttpStatus.OK);
    // UPD 2020-09-21 FNSI-仕様追加 出力データなしの場合に帳票も表示する 夏 end
	}
  // add FNSI-印刷失敗時の通知を追加 江 start
  @PutMapping("/registerNotification/{facilityCd}/{reportType}/{reportName}")
  public ResponseEntity<?> registerNotification(
    @PathVariable String facilityCd
   ,@PathVariable String reportType
   ,@PathVariable String reportName
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
   ,@AuthenticationPrincipal NtssUser ntssUser
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 end
    ) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
    if(ntssUser == null || (!ntssUser.isNkkAdminUser() && !facilityCd.equals(ntssUser.getFacilityCd()))) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 end

    try {
      reportMenuService.registerNotification(facilityCd,reportType,reportName);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_REPORT_MENU,SERVICE_NAME.FNSI, null);
    }
    return new ResponseEntity<>(HttpStatus.OK);
  }
  // add FNSI-印刷失敗時の通知を追加 江 end
  //add 4748 5269 5402治療方法ごとの治療経過表での出力ができない  吉 start
  @PostMapping("/getPatIdByCheckBox")
  public ResponseEntity<Object> getPatIdByCheckBox(
    @RequestBody ReportMenuSortContainer payload,
    @AuthenticationPrincipal NtssUser ntssUser
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
    if(!ntssUser.isNkkAdminUser()) {
      if (payload.getFacilityCd() != null && !payload.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + payload.getFacilityCd() + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 end

    try {
      List<Long> patIds = reportMenuService.getPatIdByPayLoad(payload);
      List<String>patIdList =  new ArrayList<>();
      for(Long str : patIds) {
        String i = str.toString();
        patIdList.add(i);
      }
      return new ResponseEntity<>(patIdList, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_REPORT_MENU,SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(e.toString(), HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  //add 4748 5269 5402治療方法ごとの治療経過表での出力ができない  吉 end
  // add 11009 カテゴリ「印刷情報」の仕様調整 房 start
  private void requestParamEdit(ReportMenuSortContainer payload, String userName) {
    if(payload != null) {
      // 週目の編集
      String day = null;
      if(payload.getSpecifyDate() != null && !"".equals(payload.getSpecifyDate())) {
        day = payload.getSpecifyDate().substring(6,8);
      } else if(payload.getFromDate() != null && !"".equals(payload.getFromDate())) {
        day = payload.getFromDate().substring(6,8);
      }
      if(day != null) {
        Calendar calendar = Calendar.getInstance();
        calendar.setFirstDayOfWeek(Calendar.MONDAY);
        calendar.set(Calendar.DAY_OF_MONTH, Integer.valueOf(day));
        int week = calendar.get(Calendar.WEEK_OF_MONTH);
        payload.setWeeks(week + "週目");
      }
      // 種別の編集
      // mod #11103 カテゴリ「印刷情報」の項目追加と修正 sunsy start
//      String kind = null;
//      if(!CollectionUtils.isEmpty(payload.getEquipmentCdList())) {
//        kind = "医療材料";
//      }
//      if(!CollectionUtils.isEmpty(payload.getMedicineCdList())) {
//        if(kind != null) {
//          kind += "・薬剤";
//        } else {
//          kind = "薬剤";
//        }
//      }
      // del #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
//      String kind ="";
//      String equip = (null != payload.getEquipmentCdList() && payload.getEquipmentCdList().size() > 0) ? "·医療材料" : "";
//      String medi = (null != payload.getMedicineCdList() && payload.getMedicineCdList().size() > 0) ? "·薬剤" : "";
//      String inspect = (null != payload.getInspectionCdList() && payload.getInspectionCdList().size() > 0 && payload.getInspectionCdList().get(0) == 1) ? "·検査" : "";
//      kind = equip + medi + inspect;
//      kind = kind.startsWith("·") ? kind.substring(1,kind.length()) : kind;
//      // add #11642 スケジュール表帳票がデータ抽出条件「指定日」で「一週間出力」になるのはNG limingzhe start
//      if(payload.getReportClass() == 11 && payload.getReportType().equals("3")) kind ="";
//      // add #11642 スケジュール表帳票がデータ抽出条件「指定日」で「一週間出力」になるのはNG limingzhe end
//      // mod #11103 カテゴリ「印刷情報」の項目追加と修正 sunsy end
//      payload.setKind(kind);
      // del #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
      //予定/実績
      if(!CollectionUtils.isEmpty(payload.getExpressCondCd())) {
        payload.setExpressCondCdStr(payload.getExpressCondCd().stream().collect(Collectors.joining("・")));
      } else {
        payload.setExpressCondCdStr("すべて");
      }
      //ログイン者
      payload.setLogin(userName);
    }
  }
  // add 11009 カテゴリ「印刷情報」の仕様調整 房 end
}
