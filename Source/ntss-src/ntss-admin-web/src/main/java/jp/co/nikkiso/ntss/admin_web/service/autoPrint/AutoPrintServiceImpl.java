package jp.co.nikkiso.ntss.admin_web.service.autoPrint;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.StringJoiner;

import jp.co.nikkiso.ntss.admin_web.service.reportMenu.ReportMenuDataKeyService;
import jp.co.nikkiso.ntss.api.constant.ReportConstant;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.dao.MstBedDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.MstReportDao;
import jp.co.nikkiso.ntss.core.dao.MstTreatmentDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.entity.MstBed;
import jp.co.nikkiso.ntss.core.entity.MstReport;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.FlagType;
import jp.co.nikkiso.ntss.admin_web.service.print.PrinterService;
import jp.co.nikkiso.ntss.api.service.report.ReportService;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainForWeightInd;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import org.springframework.util.StringUtils;

@Service
public class AutoPrintServiceImpl implements AutoPrintService {

  @Autowired
  private ReportService reportService;
  @Autowired
  private PrinterService printerService;

  // add #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
  @Autowired
  ReportMenuDataKeyService reportMenuDataKeyService;
  // add #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end

  @Autowired
  private MstBedDao mstBedDao;
  @Autowired
  private OrdMainDao ordMainDao;
  @Autowired
  private MstTreatmentDao mstTreatmentDao;
  @Autowired
  private MstReportDao mstReportDao;
 /**
 * ロギングのServiceインタフェース.
 */
  @Autowired
  private LogService logService;

  // add 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 start
  @Autowired
  private MstFacilitySettingDao mstFacilitySettingDao;
  // add 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 end

  /**
   * {@inheritDoc}
   */
  @Override
  public AutoPrintResult reportAutoPrint(Long ordNo, TimingEnum timing, Long userId, String userName) throws Exception {
    OrdMainForWeightInd ord = ordMainDao.selectForWeightIndByOrdNo(ordNo);

    if (ord == null) {
      // 自動印刷用情報取得失敗
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("自動印刷対象実績取得失敗 ord_no=[ " + ordNo + "]");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      AutoPrintResult res = new AutoPrintResult();
      res.isAutoPrint = false;
      res.isSuccessAutoPrint = false;
      res.autoPrintErrorMessage = "パラメータエラー";
      return res;
    }

    // mod 9616 テンプレート繰返し時に元々値があるセルは上書きしないようにすること　吉 start
    // if (!Objects.equals(ord.getRstInputClass(), 1)) {
    if ( Objects.equals(ord.getRstInputClass(), 2)) {
      // mod 9616 テンプレート繰返し時に元々値があるセルは上書きしないようにすること　吉 end
      // 手動実績は自動印刷しない
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("手動実績なので自動印刷しない");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      AutoPrintResult res = new AutoPrintResult();
      res.isAutoPrint = false;
      res.isSuccessAutoPrint = false;
      res.autoPrintErrorMessage = "手動実績なので自動印刷しない";
      return res;
    }

    if (timing == TimingEnum.beforeWeight) {
      return reportAutoPrint(ord.getPatId(), ordNo, ord.getIndTreatmentCd(), ord.getIndBedCd(), timing, userId, userName, false);
    } else {
      return reportAutoPrint(ord.getPatId(), ordNo, ord.getRstTreatmentCd(), ord.getRstBedCd(), timing, userId, userName, false);
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public AutoPrintResult reportAutoPrint(Long patId, Long ordNo, Integer treatmentCd, Long bedCd, TimingEnum timing,
      Long userId, String userName, boolean mustCheckInputClass)
      throws Exception {

    AutoPrintResult res = new AutoPrintResult();
    res.isAutoPrint = false;
    res.isSuccessAutoPrint = false;

    if (Objects.isNull(ordNo) || Objects.isNull(treatmentCd) || Objects.isNull(bedCd)) {
      // 自動印刷用情報取得失敗
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("自動印刷設定取得用パラメータエラー ord_no=[ " + ordNo + "] bed_cd=[" + bedCd + "], treatment_cd=[" + treatmentCd + "]");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      res.autoPrintErrorMessage = "パラメータエラー";
      return res;
    }

    // mod #7641 自動印刷で値が入らない項目がある。 徐博 start
    // add #7641 自動印刷で値が入らない項目がある。 王永吉 start
    // OrdMainForWeightInd ord = null;
    OrdMainForWeightInd ord = ordMainDao.selectForWeightIndByOrdNo(ordNo);
    // add #7641 自動印刷で値が入らない項目がある。 王永吉 end
    // mod #7641 自動印刷で値が入らない項目がある。 徐博 end

    // 手動実績かどうかのチェックを実施
    if (mustCheckInputClass) {

      // mod #7641 自動印刷で値が入らない項目がある。 王永吉 start
      // 手動実績以外(input_class=1)を印刷対象とする
      // OrdMainForWeightInd ord = ordMainDao.selectForWeightIndByOrdNo(ordNo);
      // del #7641 自動印刷で値が入らない項目がある。 徐博 start
      // ord = ordMainDao.selectForWeightIndByOrdNo(ordNo);
      // del #7641 自動印刷で値が入らない項目がある。 徐博 end

      if (ord == null) {
        // 自動印刷用実績情報取得失敗
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("自動印刷対象実績取得失敗 ord_no=[ " + ordNo + "]");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        res.autoPrintErrorMessage = "パラメータエラー";
        return res;
      }
      // mod 7204 【デグレ】レポートの自動印刷がされない  吉 start
      // if (!Objects.equals(ord.getRstInputClass(), 1)) {
      if (Objects.equals(ord.getRstInputClass(), 2)) {
        // mod 7204 【デグレ】レポートの自動印刷がされない  吉 end
        // 手動実績は自動印刷しない
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("手動実績なので自動印刷しない");
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        res.autoPrintErrorMessage = "手動実績なので自動印刷しない";
        return res;
      }
    }

    MstBed mstBed = mstBedDao.selectByBedCd(bedCd, FlagType.FLAG_ON, FlagType.FLAG_OFF);
    if (Objects.isNull(mstBed)) {
      // ベッド取得失敗
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("ベッド取得失敗 bed_cd=[" + bedCd + "]");
      eventLogMessage.setSqlIdentification("(bedCd = "+ bedCd  +", FLAG_ON = "+ FlagType.FLAG_ON +", FLAG_OFF = "+ FlagType.FLAG_OFF +")");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, "MstBedDao/selectByBedCd");
      res.autoPrintErrorMessage = "ベッド情報なし";
      return res;
    }
    MstTreatment mstTreatment = mstTreatmentDao.selectByCd(treatmentCd);
    if (Objects.isNull(mstTreatment)) {
      // 治療方法取得失敗
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("治療方法取得失敗 treatment_cd=[" + treatmentCd + "]");
      eventLogMessage.setSqlIdentification("(treatmentCd = "+ treatmentCd +")");
      logService.log(LogLevel.ERROR, eventLogMessage,null, SERVICE_NAME.FNSI, "MstTreatmentDao/selectByCd");
      res.autoPrintErrorMessage = "治療方法情報なし";
      return res;
    }
    Long reportCd = null;
    // add #9616 帳票印刷失敗通知がされない 高 2024/02/08　start
    Long reportCdOne = null;
    // add #9616 帳票印刷失敗通知がされない 高 2024/02/08　end
    switch (timing) {
    case beforeWeight:
      if (FlagType.FLAG_OFF.equals(mstBed.getIsAutoprintBefore())) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("前体重自動印刷不要");
        logService.log(LogLevel.INFO, eventLogMessage,null, SERVICE_NAME.FNSI, null);
        return res;
      }
      res.isAutoPrint = true;
      if (Objects.isNull(mstTreatment.getReportIdBw())) {
        // add #9616 帳票印刷失敗通知がされない 高 2024/02/08　start
        // GET 117 ReportName
        FacilitySettingInfo facilitySettingInfo = mstFacilitySettingDao.getBySettingNoAndCd(ord.getFacilityCd(), CoreConstant.FacilitySettingNo.DEFAULT_REPORT_TEMPLATE);
        if (!StringUtils.isEmpty(facilitySettingInfo.getValue())) {
          reportCdOne = Long.parseLong(facilitySettingInfo.getValue());
        }
        if (Objects.isNull(reportCdOne)) {
          // add #9616 帳票印刷失敗通知がされない 高 2024/02/08　end
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("前体重自動印刷対象帳票未設定");
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        res.autoPrintErrorMessage = "自動印刷帳票が未設定です。";
        return res;
          // add #9616 帳票印刷失敗通知がされない 高 2024/02/08　start
        } else {
          reportCd = reportCdOne;
        }
        // add #9616 帳票印刷失敗通知がされない 高 2024/02/08　end
      }
      // add #9616 帳票印刷失敗通知がされない 高 2024/02/08　start
      else {
        reportCd = (long) mstTreatment.getReportIdBw();
      }
      // add #9616 帳票印刷失敗通知がされない 高 2024/02/08　end
      // del #9616 帳票印刷失敗通知がされない 高 2024/02/08　start
//      reportCd = (long) mstTreatment.getReportIdBw();
      // del #9616 帳票印刷失敗通知がされない 高 2024/02/08　end
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("前体重自動印刷 レポートID:[" + reportCd + "]");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      break;
    case afterWeight:
      if (FlagType.FLAG_OFF.equals(mstBed.getIsAutoprintAfter())) {
        eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("後体重自動印刷不要");
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        return res;
      }
      res.isAutoPrint = true;
      if (Objects.isNull(mstTreatment.getReportIdAw())) {
        // add #9616 帳票印刷失敗通知がされない 高 2024/02/08　start
        // GET 117 ReportName
        FacilitySettingInfo facilitySettingInfo = mstFacilitySettingDao.getBySettingNoAndCd(ord.getFacilityCd(), CoreConstant.FacilitySettingNo.DEFAULT_REPORT_TEMPLATE);
        if (!StringUtils.isEmpty(facilitySettingInfo.getValue())) {
          reportCdOne = Long.parseLong(facilitySettingInfo.getValue());
        }
        if (Objects.isNull(reportCdOne)) {
          // add #9616 帳票印刷失敗通知がされない 高 2024/02/08　end
        eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("後体重自動印刷対象帳票未設定");
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        res.autoPrintErrorMessage = "自動印刷帳票が未設定です。";
        return res;
          // add #9616 帳票印刷失敗通知がされない 高 2024/02/08　start
        } else {
          reportCd = reportCdOne;
        }
        // add #9616 帳票印刷失敗通知がされない 高 2024/02/08　end
      }
      // add #9616 帳票印刷失敗通知がされない 高 2024/02/08　start
      else {
        reportCd = (long) mstTreatment.getReportIdAw();
      }
      // add #9616 帳票印刷失敗通知がされない 高 2024/02/08　end
      // del #9616 帳票印刷失敗通知がされない 高 2024/02/08　start
//      reportCd = (long) mstTreatment.getReportIdAw();
      // del #9616 帳票印刷失敗通知がされない 高 2024/02/08　end
      eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("後体重自動印刷 レポートID:[ " + reportCd + "]");
      // mod 7204 【デグレ】レポートの自動印刷がされない 吉 start
      // logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // mod 7204 【デグレ】レポートの自動印刷がされない 吉 end
      break;
    case commitEdition:
      if (FlagType.FLAG_OFF.equals(mstBed.getIsAutoprintCommit())) {
        eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("実績確定時自動印刷不要");
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        return res;
      }
      res.isAutoPrint = true;
      //mod FNSI-redmine5096 房 start
//      if (Objects.isNull(mstTreatment.getReportId())) {
      // mod #9616 帳票印刷失敗通知がされない 高 2024/02/08　start
//      if (Objects.isNull(mstTreatment.getReportIdAct())) {
      // mod #9616 帳票印刷失敗通知がされない 高 2024/02/08　end
      if (Objects.isNull(mstTreatment.getReportIdAct()) || mstTreatment.getReportIdAct() == 0) {
        // add #9616 帳票印刷失敗通知がされない 高 2024/02/08　start
        // GET 117 ReportName
        FacilitySettingInfo facilitySettingInfo = mstFacilitySettingDao.getBySettingNoAndCd(ord.getFacilityCd(), CoreConstant.FacilitySettingNo.DEFAULT_REPORT_TEMPLATE);
        if (!StringUtils.isEmpty(facilitySettingInfo.getValue())) {
          reportCdOne = Long.parseLong(facilitySettingInfo.getValue());
        }
        if (Objects.isNull(reportCdOne)) {
          // add #9616 帳票印刷失敗通知がされない 高 2024/02/08　end
        eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("実績確定時自動印刷対象帳票未設定");
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        res.autoPrintErrorMessage = "自動印刷帳票が未設定です。";
        return res;
          // add #9616 帳票印刷失敗通知がされない 高 2024/02/08　start
        } else {
          reportCd = reportCdOne;
        }
        // add #9616 帳票印刷失敗通知がされない 高 2024/02/08　end
      }
      // add #9616 帳票印刷失敗通知がされない 高 2024/02/08　start
      else {
        reportCd = (long) mstTreatment.getReportIdAct();
      }
      // add #9616 帳票印刷失敗通知がされない 高 2024/02/08　end
//      reportCd = (long) mstTreatment.getReportId();
      // del #9616 帳票印刷失敗通知がされない 高 2024/02/08　start
//      reportCd = (long) mstTreatment.getReportIdAct();
      // del #9616 帳票印刷失敗通知がされない 高 2024/02/08　end
      //mod FNSI-redmine5096 房 end
      eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("実績確定時自動印刷 レポートID:["+ reportCd + "]");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // add FNSI-実績確定時自動印刷の修正 徐 start
      break;
      // add FNSI-実績確定時自動印刷の修正 徐 end
    default:
      eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("自動印刷タイミングエラー");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return res;
    }
    Long printerCd = null;
    if (!Objects.isNull(mstBed.getOutputPrinter())) {
      try {
        // add # 9616 帳票印刷失敗通知がされない 高 2024/02/08 start
        reportCd = autoPrintGetReportCd(reportCd, ord.getFacilityCd());
        // add # 9616 帳票印刷失敗通知がされない 高 2024/02/08 end
        printerCd = Long.valueOf(mstBed.getOutputPrinter());
      } catch (NumberFormatException ex) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("自動印刷使用プリンタ値が異常です");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        res.autoPrintErrorMessage = "帳票印刷プリンタ設定値エラー";
        return res;
      }
    } else {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("自動印刷プリンタ未設定,標準プリンタ取得");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      //del #9616 帳票印刷失敗通知がされない 李 start
      //MstReport mr = mstReportDao.selectByCd(reportCd);
      //del #9616 帳票印刷失敗通知がされない 李 start
      // add #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
      // del #9616 帳票印刷失敗通知がされない 高 2024/02/08　start
//      boolean getReportNameFlag = true;
      // del #9616 帳票印刷失敗通知がされない 高 2024/02/08　end
      MstReport mr = new MstReport();
      // add #9616 帳票印刷失敗通知がされない 高 2024/01/25　end
      try {
        //add #9616 帳票印刷失敗通知がされない 李 start
        // mod #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
//        MstReport mr = mstReportDao.selectByCd(reportCd);
        mr = mstReportDao.selectByCd(reportCd);
        // mod #9616 帳票印刷失敗通知がされない 高 2024/01/25　end
        //add #9616 帳票印刷失敗通知がされない 李 start
        printerCd = mr.getDefaultPrinter();
        // add 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 start
        // del #9616 帳票印刷失敗通知がされない 高 2024/02/08　start
//        if(StringUtils.isEmpty(printerCd)){
//          // add #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
//          getReportNameFlag = false;
//          // GET 117 ReportName
//          FacilitySettingInfo facilitySettingInfo = mstFacilitySettingDao.getBySettingNoAndCd(ord.getFacilityCd(), CoreConstant.FacilitySettingNo.DEFAULT_REPORT_TEMPLATE);
//          if (!StringUtils.isEmpty(facilitySettingInfo.getValue())) {
//            Long reportCdOne = Long.parseLong(facilitySettingInfo.getValue());
//            if (reportCdOne != 0) {
//              mr = mstReportDao.selectByCd(reportCdOne);
//            }
//            if (!StringUtils.isEmpty(mr) && !StringUtils.isEmpty(mr.getReportName())) {
//              printerCd = mr.getDefaultPrinter();
//              List<FacilitySettingInfo> settingInfoList = mstFacilitySettingDao.selectFacilitySetting(ord.getFacilityCd(), CoreConstant.FacilitySettingNo.DEFAULT_PRINTER);
//              if(null != settingInfoList && settingInfoList.size()>0 && null != settingInfoList.get(0).getValue()){
//                printerCd = Long.valueOf(settingInfoList.get(0).getValue());
//              }
//            }
//          }
        // del #9616 帳票印刷失敗通知がされない 高 2024/02/08　end
          // add #9616 帳票印刷失敗通知がされない 高 2024/01/25　end
          // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
//          List<FacilitySettingInfo> settingInfoList = mstFacilitySettingDao.selectFacilitySetting(ord.getFacilityCd(), CoreConstant.FacilitySettingNo.DEFAULT_PRINTER);
//          if(null != settingInfoList && settingInfoList.size()>0 && null != settingInfoList.get(0).getValue()){
//            printerCd = Long.valueOf(settingInfoList.get(0).getValue());
//          }
          // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　end
        // del #9616 帳票印刷失敗通知がされない 高 2024/02/08　start
//        }
        // del #9616 帳票印刷失敗通知がされない 高 2024/02/08　end
        // add 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 end
      } catch (Exception ex) {
        // add #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
        // 400 ReportCd Get ReportName Error
        // del #9616 帳票印刷失敗通知がされない 高 2024/02/08　start
//        if (getReportNameFlag) {
        // del #9616 帳票印刷失敗通知がされない 高 2024/02/08　end
          try {
            // GET 117 ReportName
            FacilitySettingInfo facilitySettingInfo = mstFacilitySettingDao.getBySettingNoAndCd(ord.getFacilityCd(), CoreConstant.FacilitySettingNo.DEFAULT_REPORT_TEMPLATE);
            if (!StringUtils.isEmpty(facilitySettingInfo.getValue())) {
              // mod #9616 帳票印刷失敗通知がされない 高 2024/02/08　start
//              Long reportCdOne = Long.parseLong(facilitySettingInfo.getValue());
              reportCdOne = Long.parseLong(facilitySettingInfo.getValue());
              // mod #9616 帳票印刷失敗通知がされない 高 2024/02/08　end
              // add #9616 帳票印刷失敗通知がされない 高 2024/02/08　start
              reportCd = reportCdOne;
              // add #9616 帳票印刷失敗通知がされない 高 2024/02/08　end
              if (reportCdOne != 0) {
                mr = mstReportDao.selectByCd(reportCdOne);
              }
              // del #9616 帳票印刷失敗通知がされない 高 2024/02/08　start
//              if (!StringUtils.isEmpty(mr) && !StringUtils.isEmpty(mr.getReportName())) {
//                printerCd = mr.getDefaultPrinter();
//                List<FacilitySettingInfo> settingInfoList = mstFacilitySettingDao.selectFacilitySetting(ord.getFacilityCd(), CoreConstant.FacilitySettingNo.DEFAULT_PRINTER);
//                if(null != settingInfoList && settingInfoList.size()>0 && null != settingInfoList.get(0).getValue()){
//                  printerCd = Long.valueOf(settingInfoList.get(0).getValue());
//                }
//              }
              // del #9616 帳票印刷失敗通知がされない 高 2024/02/08　end
            }
          } catch (Exception exception) {
            eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage("標準プリンタ取得失敗");
            logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            res.autoPrintErrorMessage = "帳票印刷で使用するプリンタが異常です。";
            return res;
          }
        // del #9616 帳票印刷失敗通知がされない 高 2024/02/08　start
//        } else {
//          eventLogMessage = new EventLogMessage();
//          eventLogMessage.setLogMessage("標準プリンタ取得失敗");
//          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
//          res.autoPrintErrorMessage = "帳票印刷で使用するプリンタが異常です。";
//          return res;
//        }
        // del #9616 帳票印刷失敗通知がされない 高 2024/02/08　end
        // add #9616 帳票印刷失敗通知がされない 高 2024/01/25　end
        // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
//        eventLogMessage = new EventLogMessage();
//        eventLogMessage.setLogMessage("標準プリンタ取得失敗");
//        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
//        res.autoPrintErrorMessage = "帳票印刷で使用するプリンタが異常です。";
//        return res;
        // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　end
      }
      // add #9616 帳票印刷失敗通知がされない 高 2024/02/08　start
      if (!StringUtils.isEmpty(mr) && !StringUtils.isEmpty(mr.getReportName())) {
        if(StringUtils.isEmpty(printerCd)){
          List<FacilitySettingInfo> settingInfoList = mstFacilitySettingDao.selectFacilitySetting(ord.getFacilityCd(), CoreConstant.FacilitySettingNo.DEFAULT_PRINTER);
          if(null != settingInfoList && settingInfoList.size()>0 && null != settingInfoList.get(0).getValue()){
            printerCd = Long.valueOf(settingInfoList.get(0).getValue());
          }
        }
      }
      // add #9616 帳票印刷失敗通知がされない 高 2024/02/08　end
    }
    if (Objects.isNull(printerCd)) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("標準プリンタなし");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      res.autoPrintErrorMessage = "帳票印刷で使用するプリンタが未設定です。";
      return res;
    }
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("自動印刷プリンタ プリンタCD:[" + printerCd + "]");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    Map<String, Object> dataKey = new HashMap<>();
    dataKey.put("ordNo", ordNo);
    dataKey.put("patId", patId);
    dataKey.put("login", userName);
    // add #7641 自動印刷で値が入らない項目がある。 王永吉 start
    dataKey.put("fromDate", ord.getTreatDate());
    // add #7641 自動印刷で値が入らない項目がある。 王永吉 end
    // add 8889 【デグレ】実績確定ができない治療実績がある　吉 start
    dataKey.put("toDate", ord.getTreatDate());
    // add 8889 【デグレ】実績確定ができない治療実績がある　吉 end
    // add #8140 【デグレ】ベッドマスタにて自動印刷を「印刷しない」にしていた場合、印刷失敗通知が発生する 商 start
    dataKey.put("facilityCd", ord.getFacilityCd());
    // add #8140 【デグレ】ベッドマスタにて自動印刷を「印刷しない」にしていた場合、印刷失敗通知が発生する 商 end
    // mod #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
//    // add 8171 デグレ】透析装置の治療記録用紙に表示されない項目がある　再発 吉 start
//    Map<String,List> searchList =this.searchMap(ord.getFacilityCd());
//    dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS,searchList.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
//    dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS,searchList.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
//    dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,searchList.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
//    // add 8171 デグレ】透析装置の治療記録用紙に表示されない項目がある　再発 吉 end
    dataKey.putAll(reportMenuDataKeyService.searchReportSettingForDataKey(String.valueOf(dataKey.getOrDefault(ReportConstant.ReportDataKey.FACILITY_CD, "")), reportCd, dataKey));
    // mod #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end
    // add 8188 【デグレ】自動印刷で文字化けが発生する 夏 start
    // del 9316 施設設定マスタ125番の削除について　吉 start
//    boolean isUseAsposeCells = true;
//    FacilitySettingInfo settingValue = mstFacilitySettingDao.getBySettingNoAndCd(ord.getFacilityCd(),CoreConstant.FacilitySettingNo.PREVIEW_MODE);
//    if(settingValue != null && settingValue.getValue().equals("1")){
//      isUseAsposeCells = false;
//    }
    // del 9316 施設設定マスタ125番の削除について　吉 end
    byte[] excelBytes = new byte[]{};
    String reportHtml = "";
    // del 9316 施設設定マスタ125番の削除について　吉 start
//    if(isUseAsposeCells){
      // del 9316 施設設定マスタ125番の削除について　吉 end
      excelBytes = reportService.getReportExcelFileForDialysisReport(reportCd, dataKey);
      // del 9316 施設設定マスタ125番の削除について　吉 start
//    }else {
//    // add 8188 【デグレ】自動印刷で文字化けが発生する 夏 end
//      // 帳票HTMLの作成
//      reportHtml = reportService.getReportHtml(reportCd, dataKey, printerCd, userId);
//    // add 8188 【デグレ】自動印刷で文字化けが発生する 夏 start
//    }
    // del 9316 施設設定マスタ125番の削除について　吉 end
    // add 8188 【デグレ】自動印刷で文字化けが発生する 夏 end
    // PDF保存ファイル名を作成
    LocalDateTime nowDate = LocalDateTime.now();
    String today = nowDate.format(DateTimeFormatter.ofPattern("uuuuMMddHHmmss"));
    StringJoiner sjSuffix = new StringJoiner("_");
    String suffix = sjSuffix.add(Objects.isNull(patId) ? "0" : patId.toString()).add(ordNo.toString()).add(today)
        .toString();
    String pdfPath = (new StringBuilder()).append("pdf/dialysisReport_").append(suffix).append(".pdf").toString();
    // HTMLをPDFに変換してS3にアップロードし、印刷要求を投げる
    // add 8188 【デグレ】自動印刷で文字化けが発生する 夏 start
    // del 9316 施設設定マスタ125番の削除について　吉 start
//    if(isUseAsposeCells) {
      // del 9316 施設設定マスタ125番の削除について　吉 end
      reportService.convertBytesToPdf(excelBytes, pdfPath);
      // del 9316 施設設定マスタ125番の削除について　吉 start
//    }else {
//    // add 8188 【デグレ】自動印刷で文字化けが発生する 夏 end
//      reportService.convertHtmlToPdf(reportHtml, pdfPath);
//    // add 8188 【デグレ】自動印刷で文字化けが発生する 夏 start
//    }
    // del 9316 施設設定マスタ125番の削除について　吉 end
    // add 8188 【デグレ】自動印刷で文字化けが発生する 夏 end
    printerService.sendPrintRequest(printerCd, pdfPath);

    eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("自動印刷処理終了");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    res.isSuccessAutoPrint = true;
    return res;
  }

  // add # 9616 帳票印刷失敗通知がされない 高 2024/02/08 start
  private Long autoPrintGetReportCd(Long reportCd, String facilityCd){
    Long reportCdNo = null;
    MstReport mr = new MstReport();
    try {
      // 400
      mr = mstReportDao.selectByCd(reportCd);
      reportCdNo = mr.getReportCd();
    } catch (Exception ex) {
      try {
        // 117
        FacilitySettingInfo facilitySettingInfo = mstFacilitySettingDao.getBySettingNoAndCd(facilityCd, CoreConstant.FacilitySettingNo.DEFAULT_REPORT_TEMPLATE);
        if (!StringUtils.isEmpty(facilitySettingInfo.getValue())) {
          Long reportCdOne = Long.parseLong(facilitySettingInfo.getValue());
          reportCdNo = reportCdOne;
        }
      } catch (Exception ex1){
      }
    }
    return reportCdNo;
  }
  // add # 9616 帳票印刷失敗通知がされない 高 2024/02/08 end
}
