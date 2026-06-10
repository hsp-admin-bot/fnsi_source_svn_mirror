package jp.co.nikkiso.ntss.admin_web.service.master.report;

import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.master.MasterEditService;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.api.service.report.ReportS3Service;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.dao.MstFunctionReportDao;
import jp.co.nikkiso.ntss.core.dao.MstPatEventSubCategoryDao;
import jp.co.nikkiso.ntss.core.dao.MstReportDao;
import jp.co.nikkiso.ntss.core.dao.MstTreatmentDao;
import jp.co.nikkiso.ntss.core.dao.PatEventDao;
import jp.co.nikkiso.ntss.core.dao.SysSystemDefineDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.entity.MstFacilitySetting;
import jp.co.nikkiso.ntss.core.entity.MstFunctionReport;
import jp.co.nikkiso.ntss.core.entity.MstReport;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;


import lombok.extern.slf4j.Slf4j;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@Slf4j
public class MstReportServiceImpl implements MstReportService {

  @Autowired
  MstReportDao mstReportDao;

  @Autowired
  MasterEditService mstEditService;

  @Autowired
  private ReportS3Service reportS3Service;

  /**
   * 機能帳票マスタのDaoインタフェース.
   */
  @Autowired
  private MstFunctionReportDao mstFunctionReportDao;

  /**
   * システム設定のDaoインタフェース.
   */
  @Autowired
  private SysSystemDefineDao sysSystemDefineDao;

  /*
    * 利用者マスタのDaoインタフェース.
    */
  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;

  // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
  /**
   * 施設設定マスタのDaoインターフェース.
   */
  @Autowired
  private MstFacilitySettingDao mstFacilitySettingDao;
  // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end

  // add #12589 どこかで使用している帳票も削除出来てしまう sunsy start
  /**
   * 治療方法マスタのDaoインターフェース.
   */
  @Autowired
  private MstTreatmentDao mstTreatmentDao;

  /**
   * 患者イベントサブカテゴリマスタのDaoインターフェース.
   */
  @Autowired
  private MstPatEventSubCategoryDao mstPatEventSubCategoryDao;
  // add #12589 どこかで使用している帳票も削除出来てしまう sunsy end

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstReport> selectAll(String facilityCd) {
    return mstReportDao.selectAll(facilityCd);
  }
  //add 6502 6498 5984 定期・日常が分離されていない 吉 start
  @Override
  public List<MstReport> selectByFlag(String facilityCd,String vorcFlag) {
    return mstReportDao.selectByFlag(facilityCd,vorcFlag);
  }
  //add 6502 6498 5984 定期・日常が分離されていない 吉 end

  // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
  private static List<String> getFixedFacilitySettingNoList(){
    return List.of(
      CoreConstant.FacilitySettingNo.FIXED_DIALYSIS_REPORT_SETTING,
      CoreConstant.FacilitySettingNo.FIXED_DIALYSIS_REPORT_HANDWRITTEN_SETTING,
      CoreConstant.FacilitySettingNo.FIXED_DAILY_INSPECT_RECORD_BOOK_SETTING,
      CoreConstant.FacilitySettingNo.FIXED_PERIODIC_INSPECT_RECORD_BOOK_SETTING,
      // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe start
      CoreConstant.FacilitySettingNo.FIXED_WATER_SURVEY_RECORD_BOOK_SETTING
      // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe end
    );
  }

  private static String getFacilitySettingNoForFixedReportSet(Long reportCd){
    String facilitySettingNo = "";
    if(reportCd == CoreConstant.FixedReportCd.DIALYSIS_REPORT) {
      facilitySettingNo = CoreConstant.FacilitySettingNo.FIXED_DIALYSIS_REPORT_SETTING;
    } else if(reportCd == CoreConstant.FixedReportCd.DIALYSIS_REPORT_HANDWRITTEN) {
      facilitySettingNo = CoreConstant.FacilitySettingNo.FIXED_DIALYSIS_REPORT_HANDWRITTEN_SETTING;
    } else if(reportCd == CoreConstant.FixedReportCd.DAILY_INSPECT_RECORD_BOOK) {
      facilitySettingNo = CoreConstant.FacilitySettingNo.FIXED_DAILY_INSPECT_RECORD_BOOK_SETTING;
    } else if(reportCd == CoreConstant.FixedReportCd.PERIODIC_INSPECT_RECORD_BOOK) {
      facilitySettingNo = CoreConstant.FacilitySettingNo.FIXED_PERIODIC_INSPECT_RECORD_BOOK_SETTING;
    }
    // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe start
    else if(reportCd == CoreConstant.FixedReportCd.WATER_SURVEY_RECORD_BOOK) {
      facilitySettingNo = CoreConstant.FacilitySettingNo.FIXED_WATER_SURVEY_RECORD_BOOK_SETTING;
    }
    // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe end
    return facilitySettingNo;
  }

  @Override
  public List<MstReport> selectAllForFixedAndNormal(String facilityCd, String is_disp, String is_del) {
    List<String> facilitySettingNos = getFixedFacilitySettingNoList();
    return mstReportDao.selectAllForFixedAndNormal(facilityCd, facilitySettingNos, is_disp, is_del);
  }
  // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end

  /**
   * ロギングのServiceインタフェース.
   */
  @Autowired
  private LogService logService;

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public int insert(MstReport rec, NtssUser ntssUser) {
    // add 単一集計帳票／複数集計帳票：帳票分類コンボボックスの追加 王 start
    // del Aspose.cells関連問題対応 商 start
    //if(rec.getReportClass() == 10 && (rec.getReportType() != null && rec.getReportType() == 1)){
    //  rec.setReportClass(9);
    //}
    // del Aspose.cells関連問題対応 商 end
    // add 単一集計帳票／複数集計帳票：帳票分類コンボボックスの追加 王 end
    //add 6502  装置帳票：定期・日常が分離されていない  吉 start
    if(rec.getReportClass() == 7 && rec.getReportType() == 0){
      List<MstReport>  list = mstReportDao.selectReports(7,0,rec.getFacilityCd());
      if(null != list){
        for(MstReport rp : list){
          // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
//          if(rec.getExtractionCondition().getUseCD().equals("1")){
//            if(null != rp.getExtractionCondition() && rp.getExtractionCondition().getLayoutCD().equals(rec.getExtractionCondition().getLayoutCD())){
//              rp.setExtractionCondition(null);
//              mstReportDao.update(rp);
//            }
//          }else{
//            if(null != rp.getExtractionCondition() && rp.getExtractionCondition().getLayoutCD().equals(rec.getExtractionCondition().getLayoutCD())
//            && rp.getExtractionCondition().getRecordCD().equals(rec.getExtractionCondition().getRecordCD())){
//              rp.setExtractionCondition(null);
//              mstReportDao.update(rp);
//            }
//          }
          if(rp.getExtractionCondition() != null
            && rp.getExtractionCondition().getUseCD().equals(rec.getExtractionCondition().getUseCD())
            && !rp.getExtractionCondition().getMachineTypeCD().equals("0")
            && rp.getExtractionCondition().getMachineTypeCD().equals(rec.getExtractionCondition().getMachineTypeCD())
          ){
            rp.getExtractionCondition().setMachineTypeCD("0");
            rp.setReportType(1);
            mstReportDao.update(rp);
          }
          // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
        }
      }
    }
    //add 6502  装置帳票：定期・日常が分離されていない  吉 end
    // add 8559 動作に関する指摘２　NG4　吉 start
    long reportCd = mstReportDao.selectMaxReport();
    rec.setReportCd(reportCd);
    // add 8559 動作に関する指摘２　NG4　吉 end

    // ADD #10637 2024/09/05 Thach Start
    try {
      // BucketをSysSystemDefineの39にする
      SysSystemDefine sSDefine = sysSystemDefineDao.selectOnPremise(CoreConstant.SysSystemDefine.REPORT_PATH);
      ObjectMapper objectMapper = new ObjectMapper();
      HashMap<String, String> rpPathHm = objectMapper.readValue(sSDefine.getValue(), new TypeReference<HashMap<String, String>>(){});
      String desRpPath = rpPathHm.get("path"); // 例：ntss-s3-root-service/%s/Report
      rec.getReportPath().setBucket(String.format("s3://" + desRpPath, rec.getFacilityCd()));
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("帳票マスタの追加: システム設定の取得に失敗[" + e.getMessage() + "]");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      return -1;
    }

    // 新規登録report_hst_infoを作成する
    MstReport.Item reportHstItem = new MstReport.Item();
    reportHstItem.setCtlNo("1");
    LocalDateTime now = LocalDateTime.now();
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
    String formattedNow = now.format(formatter);
    reportHstItem.setUpdDate(formattedNow);
    reportHstItem.setBucket(rec.getReportPath().getBucket());
    reportHstItem.setXlsxZip(rec.getReportPath().getXlsxZip());
    reportHstItem.setReportZip(rec.getReportPath().getReportZip());
    reportHstItem.setXlsxFilename(rec.getReportPath().getXlsxFilename());
    reportHstItem.setHtmlFilename(rec.getReportPath().getHtmlFilename());
    reportHstItem.setXmlFilename(rec.getReportPath().getXmlFilename());
    reportHstItem.setIsSelect("1");
    String userName = mstPersonalUserDao.selectUserNameById(ntssUser.getUserId());
    reportHstItem.setUpdUserId(ntssUser.getUsername());
    reportHstItem.setUpdUserName(userName);

    MstReport.ReportHstInfo reportHstInfo = new MstReport.ReportHstInfo();
    reportHstInfo.setItems(new ArrayList<>(Arrays.asList(reportHstItem)));
    rec.setReportHstInfo(reportHstInfo);

    // ADD #10637 2024/09/05 Thach End

    final int ret = mstReportDao.insert(rec);

    // マスタセレクタ作成
    createMstSelector(rec.getFacilityCd());

    return ret;

  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public int delete(MstReport rec) {
    return mstReportDao.delete(rec);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public int updateReportName(MstReport rec) {
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(rec,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    return mstReportDao.updateReportName(rec);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public int updateReportPath(MstReport rec) {
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(rec,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    return mstReportDao.updateReportPath(rec);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public int updateIsDisp(MstReport rec) {
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(rec,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    return mstReportDao.updateIsDisp(rec);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public MstReport getMstReport(Long reportCd) {
    try {
      return mstReportDao.selectByReportCd(reportCd);
    } catch (EmptyResultDataAccessException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There is no MstReport.");
      eventLogMessage.setSqlIdentification("(reportCd = " + reportCd + ")");
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI, "MstReportDao/selectByReportCd");
      throw new NotExistException("存在しない帳票マスタの帳票番号を指定されています。");
    }
  }

  // ADD #10637 2024/09/05 Thach Start

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public String updateSelectedHst(Long reportCd, String selectedHst) {
    MstReport dbRec = mstReportDao.selectByReportCd(reportCd);
    if(dbRec != null)
    {
      // 帳票パスを選択された履歴通りに変更する
      for (MstReport.Item item : dbRec.getReportHstInfo().getItems()) {
        if (item.getCtlNo().equals(selectedHst)) {
          item.setIsSelect("1");

          dbRec.getReportPath().setBucket(item.getBucket());
          dbRec.getReportPath().setXlsxZip(item.getXlsxZip());
          dbRec.getReportPath().setReportZip(item.getReportZip());
          dbRec.getReportPath().setXmlFilename(item.getXmlFilename());
          dbRec.getReportPath().setHtmlFilename(item.getHtmlFilename());
          dbRec.getReportPath().setXlsxFilename(item.getXlsxFilename());
        }
        else {
          item.setIsSelect("0");
        }
      }

      // 帳票存在チェック
      boolean flag= reportS3Service.getReportFileIsExist(
        dbRec.getReportPath().getBucket(),
        dbRec.getReportPath().getReportZip(),
        dbRec.getUpDate());
      if(!flag){
        return "noExist";
      }

      // 帳票マスタの変更
      mstReportDao.updateListData(dbRec);
    }

    return "";
  }

  // ADD #10637 2024/09/05 Thach End

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public void updateListData(List<MstReport> request, final String facilityCd, Boolean isReportChanged, NtssUser ntssUser) {
    // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
    boolean bHavaNormal = false;
    // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end

    // 帳票名, 表示非表示フラグ, 削除フラグを更新する
    for (MstReport rec : request) {

      // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
      LogEventUtils.setOperatorId(rec,logService);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
      // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end

      // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
      if(rec.getReportCd() < 0){

        MstFacilitySetting mstFacilitySetting = new MstFacilitySetting();
        // 施設設定番号
        String facilitySettingNo = getFacilitySettingNoForFixedReportSet(rec.getReportCd());
        mstFacilitySetting.setFacilitySettingNo(facilitySettingNo);
        // 施設コード
        mstFacilitySetting.setFacilityCd(facilityCd);
        // 値
        JSONObject jsonObject = new JSONObject();
        jsonObject.put("report_cd", rec.getReportCd());
        jsonObject.put("report_name", rec.getReportName());
        jsonObject.put("report_class", rec.getReportClass());
        jsonObject.put("is_disp", rec.getIsDisp());
        jsonObject.put("default_printer", rec.getDefaultPrinter());
        jsonObject.put("disp_order", rec.getDispOrder());
        mstFacilitySetting.setValue(jsonObject.toString());
        // 更新日時
        java.sql.Timestamp sysDate = new java.sql.Timestamp(System.currentTimeMillis());
        mstFacilitySetting.setUpDate(sysDate);
        int result = mstFacilitySettingDao.update(mstFacilitySetting);
        if(result == 0) {
          mstFacilitySetting.setRegDate(sysDate);
          result = mstFacilitySettingDao.insert(mstFacilitySetting);
        }
        continue;
      }
      bHavaNormal = true;
      // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end

      // 帳票名, 表示非表示フラグ, 削除フラグを更新する
      //mod 6502  装置帳票：定期・日常が分離されていない  吉 start
//      int updateCount = mstReportDao.updateListData(rec);
      int updateCount = 0;
      if(rec.getReportClass() == 7 && rec.getReportType() == 0){
        List<MstReport>  list = mstReportDao.selectReports(7,0,facilityCd);
        // add 7347 【デグレ】削除されていない帳票が帳票画面のリストに表示されない 吉 start
        if(null != list){
          // add 7347 【デグレ】削除されていない帳票が帳票画面のリストに表示されない 吉 end
          for(MstReport rp : list){
            // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
//            if(rec.getExtractionCondition().getUseCD().equals("1")){
//              if(null != rp.getExtractionCondition() && !rp.getReportCd().equals(rec.getReportCd())
//                && rp.getExtractionCondition().getLayoutCD().equals(rec.getExtractionCondition().getLayoutCD())){
//                rp.setExtractionCondition(null);
//                mstReportDao.update(rp);
//              }
//            }else{
//              if(null != rp.getExtractionCondition() && !rp.getReportCd().equals(rec.getReportCd())
//                && rp.getExtractionCondition().getLayoutCD().equals(rec.getExtractionCondition().getLayoutCD())
//                && rp.getExtractionCondition().getRecordCD().equals(rec.getExtractionCondition().getRecordCD())){
//                rp.setExtractionCondition(null);
//                mstReportDao.update(rp);
//              }
//            }
            if(rp.getExtractionCondition() != null && !rp.getReportCd().equals(rec.getReportCd())
              && rp.getExtractionCondition().getUseCD().equals(rec.getExtractionCondition().getUseCD())
              && !rp.getExtractionCondition().getMachineTypeCD().equals("0")
              && rp.getExtractionCondition().getMachineTypeCD().equals(rec.getExtractionCondition().getMachineTypeCD())
            ){
              rp.getExtractionCondition().setMachineTypeCD("0");
              rp.setReportType(1);
              mstReportDao.update(rp);
            }
            // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
          }
          // add 7347 【デグレ】削除されていない帳票が帳票画面のリストに表示されない 吉 start
        }
        // add 7347 【デグレ】削除されていない帳票が帳票画面のリストに表示されない 吉 end
      }
      //mod 6502  装置帳票：定期・日常が分離されていない  吉 end

      // MOD #10637 2024/09/05 Thach Start

      // DBから帳票マスタを取得する
      MstReport dbRec = mstReportDao.selectByReportCd(rec.getReportCd());

      if(dbRec != null) {
        if(isReportChanged) {
          // 帳票ファイルが変更された時、帳票パスと履歴を更新する
          try {
            // BucketをSysSystemDefineの39にする
            SysSystemDefine sSDefine = sysSystemDefineDao.selectOnPremise(CoreConstant.SysSystemDefine.REPORT_PATH);
            ObjectMapper objectMapper = new ObjectMapper();
            HashMap<String, String> rpPathHm = objectMapper.readValue(sSDefine.getValue(), new TypeReference<HashMap<String, String>>(){});
            String desRpPath = rpPathHm.get("path"); // 例：ntss-s3-root-service/%s/Report
            rec.getReportPath().setBucket(String.format("s3://" + desRpPath, facilityCd));
          } catch (Exception e) {
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage("帳票マスタの変更: システム設定の取得に失敗[" + e.getMessage() + "]");
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);

            return;
          }

          // 履歴選択なしにする
          for (MstReport.Item item : dbRec.getReportHstInfo().getItems()) {
            item.setIsSelect("0");
          }

          // 新規登録report_hst_infoを作成する
          MstReport.Item reportHstItem = new MstReport.Item();
          String curCtlNo = dbRec.getReportHstInfo().getItems().get(dbRec.getReportHstInfo().getItems().size() - 1).getCtlNo();
          reportHstItem.setCtlNo(Integer.parseInt(curCtlNo) + 1 + "");
          LocalDateTime now = LocalDateTime.now();
          DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
          String formattedNow = now.format(formatter);
          reportHstItem.setUpdDate(formattedNow);
          reportHstItem.setBucket(rec.getReportPath().getBucket());
          reportHstItem.setXlsxZip(rec.getReportPath().getXlsxZip());
          reportHstItem.setReportZip(rec.getReportPath().getReportZip());
          reportHstItem.setXlsxFilename(rec.getReportPath().getXlsxFilename());
          reportHstItem.setHtmlFilename(rec.getReportPath().getHtmlFilename());
          reportHstItem.setXmlFilename(rec.getReportPath().getXmlFilename());
          reportHstItem.setIsSelect("1");
          String userName = mstPersonalUserDao.selectUserNameById(ntssUser.getUserId());
          reportHstItem.setUpdUserId(ntssUser.getUsername());
          reportHstItem.setUpdUserName(userName);

          dbRec.getReportHstInfo().getItems().add(reportHstItem);
          dbRec.setReportPath(rec.getReportPath());
        }

        // 帳票マスタの属性を変更する
        dbRec.setReportName(rec.getReportName());
        dbRec.setReportType(rec.getReportType());
        dbRec.setIsDisp(rec.getIsDisp());
        dbRec.setDispOrder(rec.getDispOrder());
        dbRec.setDefaultPrinter(rec.getDefaultPrinter());
        dbRec.setExtractionCondition(rec.getExtractionCondition());
        dbRec.setReportSetting(rec.getReportSetting());
        dbRec.setAdditionalInfo(rec.getAdditionalInfo());
        // add #11501 レイアウトデザイナのユーザビリティ改善 limingzhe start
        dbRec.setIsDel(rec.getIsDel());
        // add #11501 レイアウトデザイナのユーザビリティ改善 limingzhe end
        // 帳票マスタの変更
        updateCount = mstReportDao.updateListData(dbRec);

        if (rec.getIsDel().equals("1")) {
          // mst_function_reportの削除フラグを1に更新する
          updateFunctionReportIsDel(rec.getReportCd());
        }
      }

      // MOD #10637 2024/09/05 Thach End
    }

    // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
    if(bHavaNormal){
    // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
      // マスタセレクタ作成
      createMstSelector(facilityCd);
    // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
    }
    // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
  }

  // add #12589 どこかで使用している帳票も削除出来てしまう sunsy start
  /**
   * 削除しようとする帳票が以下の箇所に配置しているかを確認
   * @param request mst_reportレコード
   * @param facilityCd
   */
  @Override
  @Transactional
  public String checkIsCanDelete(List<MstReport> request, final String facilityCd) {

    Long defaultReportCd = Long.parseLong(
      mstFacilitySettingDao.getDefaultReportByFacilityCd(facilityCd));

    List<Integer> reportCdsfacSet =
      mstFunctionReportDao.selectReportCdsByFacilityCd(facilityCd);

    List<Integer> reportCdsTreat =
      mstTreatmentDao.selectReportCdsByFacilityCd(facilityCd);

    List<Integer> reportCdsPatEventSubCategory =
      mstPatEventSubCategoryDao.selectReportCdsByFacilityCd(facilityCd);

    // 渡された各帳票をループ処理
    for (MstReport rec : request) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
      LogEventUtils.setOperatorId(rec,logService);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end

      Long reportCd = rec.getReportCd();

      boolean isHaveDefaultReport =
        defaultReportCd != null && defaultReportCd.equals(reportCd);

      boolean isHaveFunctionReport =
        reportCd != null && reportCdsfacSet != null &&
          reportCdsfacSet.contains(reportCd.intValue());

      boolean isHaveTreatmentReport =
        reportCd != null && reportCdsTreat != null &&
          reportCdsTreat.contains(reportCd.intValue());

      boolean isHavePatEventSubCategoryReport =
        reportCd != null && reportCdsPatEventSubCategory != null &&
          reportCdsPatEventSubCategory.contains(reportCd.intValue());

      StringBuilder tmp = new StringBuilder();

      if (isHaveDefaultReport) {
        tmp.append("・施設設定マスタ\n");
      }
      if (isHaveFunctionReport) {
        tmp.append("・機能帳票マスタ\n");
      }
      if (isHaveTreatmentReport) {
        tmp.append("・治療方法マスタ\n");
      }
      if (isHavePatEventSubCategoryReport) {
        tmp.append("・患者イベントサブカテゴリマスタ\n");
      }

      // すべての帳票を完了までループするではなく、一つでも見つかる場合、当該帳票の情報をリターン
      if (tmp.length() > 0) {
        return "選択した帳票「"
          + rec.getReportName()
          + "」は以下の機能で使用されているため削除できません。削除するには設定変更を行ってください。\n"
          + tmp.toString();
      }
    }

    return "";
  }
  // add #12589 どこかで使用している帳票も削除出来てしまう sunsy end
  /**
   * マスタセレクタ作成
   *
   * @param facilityCd
   */
  private void createMstSelector(final String facilityCd) {

    // mst_report を読み込んでMapのListを作る
    List<MstReport> resReport = selectAll(facilityCd);
    List<Map<String, Object>> data = new ArrayList<Map<String, Object>>();
    for (MstReport rec : resReport) {
      Map<String, Object> map = new HashMap<String, Object>();
      map.put(jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao.ALIAS_CODE, rec.getReportCd());
      map.put(jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao.ALIAS_NAME, rec.getReportName());
      data.add(map);
    }

    // mst_selectorに登録する
    mstEditService.createMstSelector(facilityCd, "mst_report", data);

  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public void updateIsDel(long reportCd, final String facilityCd) {

    // mst_reportの削除フラグを1に更新する
    MstReport request = new MstReport();
    request.setReportCd(reportCd);
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(request,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    mstReportDao.updateIsDel(
      request
    );

    // mst_function_reportの削除フラグを1に更新する
    updateFunctionReportIsDel(reportCd);

    // マストセレクタ作成
    createMstSelector(facilityCd);

  }

  /**
   * mst_function_reportの削除フラグを1に更新する
   *
   * @param reportCd レポートCD
   */
  private void updateFunctionReportIsDel(long reportCd) {

    // 機能帳票マスタの削除フラグを1に更新する
    MstFunctionReport rec = new MstFunctionReport();
    rec.setReportCd(reportCd);
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(rec,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    mstFunctionReportDao.updateIsDel(rec);
  }
  //add 6502  装置帳票：定期・日常が分離されていない  吉 start
  @Override
  public MstReport checkRepeat (MstReport record, String facilityCd) {
    List<MstReport> list = mstReportDao.selectReports(7, 0, facilityCd);
    // add 7347 【デグレ】削除されていない帳票が帳票画面のリストに表示されない 吉 start
    if(null != list){
      // add 7347 【デグレ】削除されていない帳票が帳票画面のリストに表示されない 吉 end
      for (MstReport rp : list) {
        // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
//        if(record.getExtractionCondition().getRecordCD().equals("1")){
//          if (rp.getExtractionCondition() != null && !rp.getReportCd().equals(record.getReportCd())
//            && rp.getExtractionCondition().getLayoutCD().equals(record.getExtractionCondition().getLayoutCD())
//            && rp.getExtractionCondition().getRecordCD().equals(record.getExtractionCondition().getRecordCD())) {
//            return rp;
//          }
//        }else{
//          if (rp.getExtractionCondition() != null && !rp.getReportCd().equals(record.getReportCd()) &&
//            rp.getExtractionCondition().getLayoutCD().equals(record.getExtractionCondition().getLayoutCD()) &&
//            rp.getExtractionCondition().getRecordCD().equals(record.getExtractionCondition().getRecordCD())) {
//            return rp;
//          }
//        }
        if (rp.getExtractionCondition() != null && !rp.getReportCd().equals(record.getReportCd())
          && rp.getExtractionCondition().getUseCD().equals(record.getExtractionCondition().getUseCD())
          && !rp.getExtractionCondition().getMachineTypeCD().equals("0")
          && rp.getExtractionCondition().getMachineTypeCD().equals(record.getExtractionCondition().getMachineTypeCD())
        ) {
          return rp;
        }
        // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
      }
      // add 7347 【デグレ】削除されていない帳票が帳票画面のリストに表示されない 吉 start
    }
    // add 7347 【デグレ】削除されていない帳票が帳票画面のリストに表示されない 吉 end
    return null;
  }
  //add 6502  装置帳票：定期・日常が分離されていない  吉 end
}
