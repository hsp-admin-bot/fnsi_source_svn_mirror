package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage;
import jp.co.nikkiso.ntss.admin_web.response.exceptionPeriod.ExceptionPeriodResponse;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterUpdateResponse;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.master.supportSetting.MstSupportSettingService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.PatExamMainDao;
import jp.co.nikkiso.ntss.core.entity.ExceptionPeriod;
import jp.co.nikkiso.ntss.core.entity.MntMedicineSupport;
import jp.co.nikkiso.ntss.core.entity.custom.CheckAvgData;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;



/**
 * 投薬支援マスタ画面のResourceクラス.
 */
@RestController
@Slf4j
@RequestMapping(Uri.MASTER_MAINTENANCE)
public class MstSupportSettingResource {

  /**
   * 投薬支援一覧Service
   */
  @Autowired
  private MstSupportSettingService mstSupportSettingService;

  @Autowired
  LogService logService;

  @Autowired
  PatExamMainDao patExamMainDao;
  @Autowired
  private jp.co.nikkiso.ntss.admin_web.service.exceptionPeriod.ExceptionPeriodService ExceptionPeriodService;

  /**
   * 投薬支援一覧データ取得.
   *
   * @param facilityCd 施設コード
   *
   */
  @GetMapping("/mst_support_setting/{facilityCd}")
  public HttpEntity<? extends Object> getMasterData(@PathVariable String facilityCd) {
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get master : mst_support_setting & sys_support_setting");
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, SERVICE_NAME.FNSI, null);

    try {
      List<MntMedicineSupport> response = mstSupportSettingService.selectMedicineSupport(facilityCd);
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {

      // マスタ定義が取得できなかった場合
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
        HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 初期レンジ取得.
   *
   * @param cd 投薬支援コード
   *
   */
  @GetMapping("/mst_support_range_value/{cd}")
  public HttpEntity<? extends Object> getRange(@PathVariable String cd) {
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get master : mst_range_setting & mst_range_setting");
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, SERVICE_NAME.FNSI, null);

    try {
      Map<String,Object> response = mstSupportSettingService.selectRange(cd);
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {

      // マスタ定義が取得できなかった場合
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
        HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 結果値取得.
   *
   * @param cycLingParameter 取得対象のパラメータ
   *
   */
  @GetMapping("/mst_support_result_value/{cycLingParameter}")
  public HttpEntity<? extends Object> getSupportMasterData(@PathVariable List<String> cycLingParameter) {
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get master : resultValue & mst_medicine_support");
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, SERVICE_NAME.FNSI, null);

    try {
      String facilityCd = cycLingParameter.get(0);
      String patId = cycLingParameter.get(1);
      String nowYMDBegin = cycLingParameter.get(2);
      String nowYMDEnd = cycLingParameter.get(3);
      String lastYMDBegin = cycLingParameter.get(4);
      String lastYMDEnd = cycLingParameter.get(5);
      String cd = cycLingParameter.get(6);
//    mod 5527 除外期間が適用されていない。張 start
//      List<Map<String,Object>> exceptionPeriodList =  mstSupportSettingService.selectExceptionPeriod(facilityCd, patId);
//
//      List<Map<String,Object>> responseList = new ArrayList<>();
//      List<Map<String,Object>> responseNewList = mstSupportSettingService.selectResultValue(facilityCd, cd, patId, nowYMDBegin + " 00:00:00", nowYMDEnd + " 23:59:59");
//      List<Map<String,Object>> responseLastList = mstSupportSettingService.selectResultValue(facilityCd, cd, patId, lastYMDBegin + " 00:00:00", lastYMDEnd + " 23:59:59");
//      List<Map<String,Object>> newList = new ArrayList<>();
//      List<Map<String,Object>> lastList = new ArrayList<>();
//      if (exceptionPeriodList != null && exceptionPeriodList.size() > 0) {
//        newList = getExcludedPeriod(responseNewList, exceptionPeriodList);
//        lastList = getExcludedPeriod(responseLastList, exceptionPeriodList);
//      } else {
//        newList = responseNewList;
//        lastList = responseLastList;
//      }
//      List<Map<String,Object>> exceptionPeriodList =  mstSupportSettingService.selectExceptionPeriod(facilityCd, patId);
      List<ExceptionPeriod> listExceptionPeriod = getExceptionPeriods(facilityCd, patId);
      List<Map<String,Object>> responseList = new ArrayList<>();
      List<Map<String,Object>> responseNewList = mstSupportSettingService.selectResultValue(facilityCd, cd, patId, nowYMDBegin + " 00:00:00", nowYMDEnd + " 23:59:59", listExceptionPeriod);
      List<Map<String,Object>> responseLastList = mstSupportSettingService.selectResultValue(facilityCd, cd, patId, lastYMDBegin + " 00:00:00", lastYMDEnd + " 23:59:59", listExceptionPeriod);
      List<Map<String,Object>> newList = new ArrayList<>();
      List<Map<String,Object>> lastList = new ArrayList<>();
        newList = responseNewList;
        lastList = responseLastList;
//    mod 5527 除外期間が適用されていない。張 end
      if (newList.size() > 0) {
        Map<String, Object> responseNew = getCalculationValue(newList);
        double nowFrequency =  calcCountCycling(responseNew, newList);
        responseNew.put("nowFrequency", nowFrequency);
        responseList.add(responseNew);
      } else {
        responseList.add(null);
      }
      if (lastList.size() > 0) {
        Map<String,Object> responseLast = getCalculationValue(lastList);
        double lastFrequency =  calcCountCycling(responseLast, lastList);
        responseLast.put("lastFrequency", lastFrequency);
        responseList.add(responseLast);
      } else {
        responseList.add(null);
      }

      return new ResponseEntity<>(responseList, HttpStatus.OK);
    } catch (Exception e) {

      // マスタ定義が取得できなかった場合
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
        HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 検査平均値取得.
   *
   * @param checkAvgParameter 取得対象のパラメータ
   *
   */
  @GetMapping("/mst_support_checkAvg_value/{checkAvgParameter}")
  public HttpEntity<? extends Object> getCheckAvgData(@PathVariable List<String> checkAvgParameter) {
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get master : checkAvgData & pat_exam_main");
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, SERVICE_NAME.FNSI, null);

    try {
      String facilityCd = checkAvgParameter.get(0);
      String patId = checkAvgParameter.get(1);
      String startDate = checkAvgParameter.get(2);
      String endDate = checkAvgParameter.get(3);
      String cd = checkAvgParameter.get(4);
//    mod 5527 除外期間が適用されていない。張 start
//      List<CheckAvgData> responseList = mstSupportSettingService.selectCheckAvgData(facilityCd, patId, startDate + " 00:00:00", endDate + " 23:59:59", cd);
      List<ExceptionPeriod> listExceptionPeriod = getExceptionPeriods(facilityCd, patId);
      List<CheckAvgData> responseList = mstSupportSettingService.selectCheckAvgData(facilityCd, patId,startDate,endDate, listExceptionPeriod, cd);
//    mod 5527 除外期間が適用されていない。張 end
      return new ResponseEntity<>(responseList, HttpStatus.OK);
    } catch (Exception e) {

      // マスタ定義が取得できなかった場合
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
        HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 患者の除外期間
   * @param facilityCd
   * @param patId
   * @return
   */
  private List<ExceptionPeriod> getExceptionPeriods(String facilityCd, String patId) {
    List<ExceptionPeriodResponse> listExceptionPeriodResponse = ExceptionPeriodService.selectOrdExceptionPeriod(facilityCd, Long.valueOf(patId));
    List<ExceptionPeriod> listExceptionPeriod = new ArrayList<>();
    for (ExceptionPeriodResponse item : listExceptionPeriodResponse) {
      ExceptionPeriod exceptionPeriod = new ExceptionPeriod();
      BeanUtils.copyProperties(item, exceptionPeriod);
      exceptionPeriod.setExceptionPeriodFrom(exceptionPeriod.getExceptionPeriodFrom()+" 00:00:00");
      exceptionPeriod.setExceptionPeriodTo(exceptionPeriod.getExceptionPeriodTo()+" 23:59:59");
      listExceptionPeriod.add(exceptionPeriod);
    }
    return listExceptionPeriod;
  }

  /**
   * 投薬支援取得.
   *
   * @param investmentSupportParameter 取得対象のパラメータ
   *
   */
  @GetMapping("/mst_support_investment_value/{investmentSupportParameter}")
  public HttpEntity<? extends Object> getInvestmentSupport(@PathVariable List<String> investmentSupportParameter) {
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get master : checkAvgData & pat_exam_main");
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, SERVICE_NAME.FNSI, null);

    try {
      Map<String,Object> response = new HashMap<>();
      String cyclingCd = investmentSupportParameter.get(0);
      String esaCd = investmentSupportParameter.get(1);
      String type = investmentSupportParameter.get(2);
      // mod #7746 投与支援で薬剤に薬効換算マスタの薬剤グループを設定すると算出できない 鄭爽 start
      // String baseDate = investmentSupportParameter.get(3);
      String endDate = investmentSupportParameter.get(3);
      // mod #7746 投与支援で薬剤に薬効換算マスタの薬剤グループを設定すると算出できない 鄭爽 end
      String facilityCd = investmentSupportParameter.get(4);
      String patId = investmentSupportParameter.get(5);
      String startDate = investmentSupportParameter.get(6);
      // add #7746 投与支援で薬剤に薬効換算マスタの薬剤グループを設定すると算出できない 鄭爽 start
      String baseDate = investmentSupportParameter.get(7);
      // add #7746 投与支援で薬剤に薬効換算マスタの薬剤グループを設定すると算出できない 鄭爽 end
//    mod 5527 除外期間が適用されていない。張 start
//      String weekCycling = mstSupportSettingService.selectAvgData(facilityCd, patId, startDate + " 00:00:00", baseDate + " 23:59:59", cyclingCd);
      List<ExceptionPeriod> listExceptionPeriod = getExceptionPeriods(facilityCd, patId);
      String weekCycling = mstSupportSettingService.selectAvgData(facilityCd, patId, startDate + " 00:00:00", baseDate + " 23:59:59", cyclingCd, listExceptionPeriod);
//    mod 5527 除外期間が適用されていない。張 end
      String itemUnit = mstSupportSettingService.selectUnitOfCd(cyclingCd, "0");
      String esaUnit = mstSupportSettingService.selectUnitOfCd(esaCd, type);
      String countValue = mstSupportSettingService.selectWeekCountOfCd(esaCd, baseDate, facilityCd, patId);
      double countDouble = 0;
      if (countValue != null && !"".equals(countValue)) {
        countDouble = Double.parseDouble(countValue);
      }
      // mod #7746 投与支援で薬剤に薬効換算マスタの薬剤グループを設定すると算出できない 鄭爽 start
      // int weekCount = getWeekCount(startDate, baseDate, facilityCd, patId);
      int weekCount = getWeekCount(startDate, endDate, facilityCd, patId);
      // mod #7746 投与支援で薬剤に薬効換算マスタの薬剤グループを設定すると算出できない 鄭爽 end

      response.put("itemUnit", itemUnit);
      response.put("esaUnit", esaUnit);
      response.put("weekAvg",  String.format("%.2f", countDouble / weekCount));
      response.put("weekCycling", weekCycling);

      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {

      // マスタ定義が取得できなかった場合
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
        HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 薬剤平均投与量取得.
   *
   * @param avgInvestParameter 取得対象のパラメータ
   *
   */
  @GetMapping("/mst_support_avgInvest_value/{avgInvestParameter}")
  public HttpEntity<? extends Object> getAvgInvestData(@PathVariable List<String> avgInvestParameter) {
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get master : getAvgInvest & pat_exam_main");
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, SERVICE_NAME.FNSI, null);

    try {
      List<List<String>> drugList = new ArrayList<>();
      /* del by zhouyingying  2023-02-02 [CodeOptimization] start */
//      String facilityCd = avgInvestParameter.get(0);
//      String patId = avgInvestParameter.get(1);
//      String indexCd = avgInvestParameter.get(2);
//      String startDate = avgInvestParameter.get(3);
//      String endDate = avgInvestParameter.get(4);
//      String cyclingCd = avgInvestParameter.get(5);
//      String baseDate = avgInvestParameter.get(6);
//      String lastSunday = avgInvestParameter.get(7);
//      //FNSI-修正 #6557 昨年と来年の取得 ljx add start
//      String lastYearDate = this.getDateOfYear(baseDate).get(0);
//      String nextYearDate = this.getDateOfYear(baseDate).get(1);
//      //FNSI-修正 #6557 昨年と来年の取得 ljx add end
//
//      int weekCount = getWeekCount(startDate, lastSunday, facilityCd, patId);
//      List<Map<String,Object>> selectMedicineList = mstSupportSettingService.selectMedicineData(indexCd);
//      for (Map<String,Object> selectMedicine : selectMedicineList) {
//        String cd = selectMedicine.get("detail_info_value").toString();
//        String name = selectMedicine.get("detail_info_text").toString();
//        String type = selectMedicine.get("detail_info_type").toString();
//
//        //FNSI-修正 #6557 年間投与数と投与指示数の取得 ljx add start
////      mod 5527 除外期間が適用されていない。張 start
////        String resultValue = mstSupportSettingService.selectRstValueData(facilityCd, patId, lastYearDate,baseDate, cd,"2");
////        String reserveValue = mstSupportSettingService.selectRstValueData(facilityCd, patId, baseDate,nextYearDate, cd,"1");
//        List<ExceptionPeriod> listExceptionPeriod = getExceptionPeriods(facilityCd, patId);
//        String resultValue = mstSupportSettingService.selectRstValueData(facilityCd, patId, lastYearDate,baseDate, cd,"2",listExceptionPeriod);
//        String reserveValue = mstSupportSettingService.selectRstValueData(facilityCd, patId, baseDate,nextYearDate, cd,"1",listExceptionPeriod);
//  //    mod 5527 除外期間が適用されていない。張 end
//        //FNSI-修正 #6557 年間投与数と投与指示数の取得 ljx add end
//
//        if ("1".equals(type)) {
//          //    mod 5527 除外期間が適用されていない。張 start
////          String rstValue = mstSupportSettingService.selectRstValueData(facilityCd, patId, startDate,endDate, cd,"2");
//          String rstValue = mstSupportSettingService.selectRstValueData(facilityCd, patId, startDate,endDate, cd,"2", listExceptionPeriod);
//          //    mod 5527 除外期間が適用されていない。張 end
//          if (rstValue == null || "".equals(rstValue)) {
//            rstValue = "0";
//          }
//          List<String> itemList = new ArrayList<>();
//          // 薬剤名
//          itemList.add(name);
//          itemList.add("");
//          // 週平均値
//          itemList.add(String.format("%.2f", Double.parseDouble(rstValue) / weekCount));
//          // 項目名
//          itemList.add(getExamItemAvgValue(patId,startDate,endDate,cyclingCd));
//          // 年間投与数
//          itemList.add(resultValue);
//          // 投与指示数
//          itemList.add(reserveValue);
//
//          drugList.add(itemList);
//        } else if ("2".equals(type)) {
//          //    mod 5527 除外期間が適用されていない。張 start
////          String rstValue = mstSupportSettingService.selectRstValueData(facilityCd, patId, startDate,endDate, cd,"2");
//          String rstValue = mstSupportSettingService.selectRstValueData(facilityCd, patId, startDate,endDate, cd,"2", listExceptionPeriod);
//          //    mod 5527 除外期間が適用されていない。張 end
//          if (rstValue == null || "".equals(rstValue)) {
//            rstValue = "0";
//          }
//          List<String> itemList = new ArrayList<>();
//          // 薬剤名
//          itemList.add(name);
//          itemList.add("");
//          // 週平均値
//          itemList.add(String.format("%.2f", Double.parseDouble(rstValue) / weekCount));
//          // 項目名
//          itemList.add(getExamItemAvgValue(patId,startDate,endDate,cyclingCd));
//          // 年間投与数
//          itemList.add("");
//          // 投与指示数
//          itemList.add("");
//
//          drugList.add(itemList);
//
//          List<Map<String, Object>> itemMapList = mstSupportSettingService.selectDrugData(facilityCd, patId, endDate, cd);
//          for (Map<String, Object> item : itemMapList) {
//            itemList = new ArrayList<>();
//            // 薬剤名
//            itemList.add("");
//            itemList.add(item.get("medicine_name").toString());
//            // 週平均値
//            itemList.add("");
//            // 項目名
//            itemList.add("");
//            // 年間投与数
//            itemList.add(item.get("ind_rst_value").toString());
//            // 投与指示数
//            itemList.add(item.get("ind_rst_value").toString());
//
//            drugList.add(itemList);
//          }
//        } else {
//          List<Map<String,Object>> rstValueList = mstSupportSettingService.selectMultiplicationData(cd, endDate, facilityCd, patId);
//          double groupValue = 0;
//          List<List<String>> rstList = new ArrayList<>();
//          for (Map<String,Object> rstMap : rstValueList) {
//            double multiplication = 0;
//            String rstFlg = "";
//            String rstCd = "";
//            String rstName = "";
//            String rstValue = "";
//            if (rstMap.get("multiplication") != null) {
//              multiplication = Double.parseDouble(rstMap.get("multiplication").toString());
//            }
//            groupValue = groupValue + multiplication;
//            if (rstMap.get("mediflg") != null) {
//              rstFlg = rstMap.get("mediflg").toString();
//            }
//            if (rstMap.get("cd") != null) {
//              rstCd = rstMap.get("cd").toString();
//            }
//            if (rstMap.get("medicine_name") != null) {
//              rstName = rstMap.get("medicine_name").toString();
//            }
//            if (rstMap.get("sumvalue") != null) {
//              rstValue = rstMap.get("sumvalue").toString();
//            }
//            if ("2".equals(rstFlg)) {
//              List<Map<String, Object>> itemMapList = mstSupportSettingService.selectDrugData(facilityCd, patId, endDate, rstCd);
//              for (Map<String, Object> item : itemMapList) {
//                //    mod 5527 除外期間が適用されていない。張 start
////                String valueData = mstSupportSettingService.selectRstValueData(facilityCd, patId, startDate,endDate, item.get("medicine_cd").toString(),"2");
//                String valueData = mstSupportSettingService.selectRstValueData(facilityCd, patId, startDate,endDate, item.get("medicine_cd").toString(),"2", listExceptionPeriod);
//                //    mod 5527 除外期間が適用されていない。張 end
//                if (valueData == null || "".equals(valueData)) {
//                  valueData = "0";
//                }
//                List<String> itemList = new ArrayList<>();
//                // 薬剤名
//                itemList.add("");
//                itemList.add(item.get("medicine_name").toString());
//                // 週平均値
//                itemList.add("");
//                // 項目名
//                itemList.add("");
//                // 年間投与数
//                itemList.add(valueData);
//                // 投与指示数
//                itemList.add(valueData);
//                if (!rstList.contains(itemList)) {
//                  rstList.add(itemList);
//                }
//              }
//            } else if ("0".equals(rstFlg)) {
//              if (rstValue == null || "".equals(rstValue)) {
//                rstValue = "0";
//              }
//              List<String> itemList = new ArrayList<>();
//
//              // 薬剤名
//              itemList.add("");
//              itemList.add(rstName);
//              // 週平均値
//              itemList.add("");
//              // 項目名
//              itemList.add("");
//              // 年間投与数
//              itemList.add(rstValue);
//              // 投与指示数
//              itemList.add(rstValue);
//              if (!rstList.contains(itemList)) {
//                rstList.add(itemList);
//              }
//            }
//          }
//
//          List<String> itemList = new ArrayList<>();
//
//          // 薬剤名
//          itemList.add(name);
//          itemList.add("");
//          // 週平均値
//          itemList.add(String.format("%.2f", groupValue / weekCount));
//          // 項目名
//
//          itemList.add(getExamItemAvgValue(patId,startDate,endDate,cyclingCd));
//          // 年間投与数
//          itemList.add("");
//          // 投与指示数
//          itemList.add("");
//
//          drugList.add(itemList);
//          drugList.addAll(rstList);
//        }
//      }
      /* del by zhouyingying  2023-02-02 [CodeOptimization] end */
      /* add by zhouyingying  2023-02-02 [CodeOptimization] start */
      drugList = mstSupportSettingService.getAvgInvestData(avgInvestParameter);
      /* add by zhouyingying  2023-02-02 [CodeOptimization] end */
      return new ResponseEntity<>(drugList, HttpStatus.OK);
    } catch (Exception e) {

      // マスタ定義が取得できなかった場合
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
        HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  /* del by zhouyingying  2023-02-03 [CodeOptimization] start */
//  /**
//   * 検査結果項目の平均値を計算する
//   * @param patId
//   * @param startDate
//   * @param endDate
//   * @param cyclingCd
//   * @return
//   * @throws IOException
//   */
//  private String getExamItemAvgValue(String patId, String startDate, String endDate, String cyclingCd) throws IOException {
//    List<PatExamMain> patExamMains = patExamMainDao.selectPatExamMainByDateCd(Integer.parseInt(patId), startDate, endDate);
//
//    Double sumValue = Double.valueOf("0");
//    // mod bug 6558 修正 chen start
//    // int patExamMainsSize = 1;
//    int patExamMainsSize = 0;
//    if (CollectionUtils.isNotEmpty(patExamMains)){
//      // patExamMainsSize = patExamMains.size();
//      for (PatExamMain patExamMain : patExamMains){
//        List<PatExamMainExamResultInfo> examResultInfos =
//          patExamMain.getExamResultInfo() == null || patExamMain.getExamResultInfo().isEmpty()
//            ? new ArrayList<>()
//            : new ObjectMapper().readValue(patExamMain.getExamResultInfo(), new TypeReference<List<PatExamMainExamResultInfo>>() {});
//        for (PatExamMainExamResultInfo resultInfo : examResultInfos){
//          if (cyclingCd.equals(resultInfo.getItem_cd())){
//            sumValue = sumValue + Double.valueOf(resultInfo.getResult());
//            patExamMainsSize++;
//          }
//        }
//      }
//    }
//    if (patExamMainsSize == 0) {
//      patExamMainsSize = 1;
//    }
//    // mod bug 6558 修正 chen end
//    return String.format("%.2f", sumValue / patExamMainsSize);
//  }
  /* del by zhouyingying  2023-02-03 [CodeOptimization] end */
  /**
   * 除外期間チェック
   *
   * @return List型配列データ
   */
  private List<Map<String,Object>> getExcludedPeriod(List<Map<String,Object>> responseList, List<Map<String,Object>> exceptionPeriodList) {
    List<Map<String,Object>> resultList = new ArrayList<Map<String,Object>>();
    for (Map<String,Object> response : responseList) {
      boolean check = true;
      for (Map<String,Object> exceptionPeriod : exceptionPeriodList) {
        int regDate = Integer.parseInt(response.get("regdate").toString());
        int fromDate = Integer.parseInt(exceptionPeriod.get("fromdate").toString());
        int toDate = Integer.parseInt(exceptionPeriod.get("todate").toString());
        if ( regDate >= fromDate && regDate <= toDate ) {
          check = false;
        }
      }
      if (check) {
        resultList.add(response);
      }
    }
    return resultList;
  }

  /**
   * 保存処理.
   *
   * @param saveParameter 取得対象のパラメータ
   *
   */
  @PostMapping("/mst_support_save_value/{saveParameter}")
  public ResponseEntity<?> saveRecord(@PathVariable List<String> saveParameter){
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get master : checkAvgData & pat_exam_main");
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, SERVICE_NAME.FNSI, null);

    try {
      int r = mstSupportSettingService.saveOrdMaterialSave(saveParameter);
      if (r == 2) {
        return new ResponseEntity<>(saveParameter, HttpStatus.OK);
      } else {
        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
      }
    } catch (Exception e) {

      // マスタ定義が取得できなかった場合
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
        HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 投与支援値
   *
   * @return Map型配列データ
   */
  private Map<String,Object> getCalculationValue(List<Map<String,Object>> mapList) {
    Map<String,Object> returnMap = new HashMap<String,Object>();
    double maxValue = 0.0;
    double minValue = 0.0;
    int countValue = 0;
    double sumValue = 0.0;
    java.text.DecimalFormat df = new java.text.DecimalFormat("#.00");

    for (Map<String,Object> item : mapList) {
      double value = Double.parseDouble(item.get("resultvalue").toString());
      if (countValue == 0) {
        maxValue = value;
        minValue = value;
        sumValue = value;
      } else {
        if (maxValue < value) {
          maxValue = value;
        }
        if (minValue > value) {
          minValue = value;
        }
        sumValue = sumValue + value;
      }
      countValue ++;
    }

    double avgValue = Double.parseDouble(df.format(sumValue / countValue));
    double sumPowValue = 0.0;
    for (Map<String,Object> item : mapList) {
      double value = Double.parseDouble(item.get("resultvalue").toString());
      sumPowValue = sumPowValue + Math.pow(value - avgValue, 2);
    }
    returnMap.put("maxValue", Double.parseDouble(df.format(maxValue)));
    returnMap.put("minValue", Double.parseDouble(df.format(minValue)));
    returnMap.put("deviationValue", Double.parseDouble(df.format(Math.sqrt(sumPowValue / countValue))));
    return returnMap;
  }
  /**
   * 回数取得
   *
   * @return 回数
   */
  private double calcCountCycling(
    Map<String, Object> response,
    List<Map<String,Object>> udtExamList) throws ParseException {

    // 周期最低上下限差
    double gdblMULTIGRA_EXACYCLEVALDIFFMIN = 1.5;
    // 半周期最低期間(日)4週間
    double glngMULTIGRA_EXACYCLETERMMIN_HALF = 28;
    // 周期最低期間(日)8週間
    double glngMULTIGRA_EXACYCLETERMMIN = 56;

    double dblExaminCycling = 0.0;

    // データ異常の値
    double dblNODATA = 99999;

    SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyyMMdd");

    // 初期化
    Date dtmUpperCycleSDate = new Date();   // 盛り上がり側周期開始日[yyyy/mm/dd]
    Date dtmLowerCycleSDate = new Date();   // へこみ側周期開始日[yyyy/mm/dd]
    double dblMaxValue = (double)response.get("maxValue");   // 最大値
    double dblMinValue = (double)response.get("minValue");    // 最小値
    int lngCycleTermWk = 0;          // 周期間隔日数
    double dblValueDiffWk = 0;         // 検査値の上下限差

    // 中点獲得
    double dblAveValue = (dblMaxValue + dblMinValue) / 2;

    // 最大値と最小値の差が一定以上ない場合は処理終了
    dblValueDiffWk = dblMaxValue - dblMinValue;
    if (dblValueDiffWk < gdblMULTIGRA_EXACYCLEVALDIFFMIN) {
      // 正常終了
      return 0;
    }

    dblMaxValue = -dblNODATA;
    dblMinValue = dblNODATA;
    boolean blnFullCycle1stFlg = true;    // １周期フル初回フラグ(true:初回の周期、false:初回に続く周期)
    // 周期解析
    // 隣の値まで参照するので、1つ手前までループ
    // 件数分ループ
    for (int intCnt = 0; intCnt <= (udtExamList.size() - 2); intCnt++) {
      // 最大値？
      if (Double.parseDouble(udtExamList.get(intCnt).get("resultvalue").toString()) > dblMaxValue) {
        // 最大値を更新,
        dblMaxValue = Double.valueOf(udtExamList.get(intCnt).get("resultvalue").toString());
      }
      // 最小値？
      if (Double.parseDouble(udtExamList.get(intCnt).get("resultvalue").toString()) < dblMinValue) {
        // 最小値を更新
        dblMinValue = Double.parseDouble(udtExamList.get(intCnt).get("resultvalue").toString());
      }

      // 中点との交点検索
      // 中点未満と中点以上が隣り合っている箇所を探す
      // 中点未満→中点以上
      if (Double.parseDouble(udtExamList.get(intCnt).get("resultvalue").toString()) < dblAveValue
        && Double.parseDouble(udtExamList.get(intCnt + 1).get("resultvalue").toString()) >= dblAveValue) {
        // 盛り上がり側周期の始点が決定しているとき
        if (dtmUpperCycleSDate.compareTo(new Date()) != 0) {
          // 盛り上がりの時に盛り上がり側周期の始点が決定しているということは、
          // へこみ側周期の始点も決定している
          // へこみ側周期の始点との間隔を計算
          lngCycleTermWk = getLngCycleTermWk(dtmLowerCycleSDate, simpleDateFormat.parse(udtExamList.get(intCnt).get("regdate").toString()));

          // 半周期の長さ(4W)を満たしているとき
          if (lngCycleTermWk >= glngMULTIGRA_EXACYCLETERMMIN_HALF) {
            // 更に、それより前期間の盛り上がり周期始点との間隔を計算
            // 盛り上がり側周期の始点との間隔を計算
            lngCycleTermWk = getLngCycleTermWk(dtmUpperCycleSDate, simpleDateFormat.parse(udtExamList.get(intCnt).get("regdate").toString()));

            // １周期の長さ(8W)を満たしているとき
            if (lngCycleTermWk >= glngMULTIGRA_EXACYCLETERMMIN) {
              // 最大値と最小値の差が既定(1.5以上)を満たしているかチェック
              dblValueDiffWk = dblMaxValue - dblMinValue;
              if (dblValueDiffWk >= gdblMULTIGRA_EXACYCLEVALDIFFMIN) {
                // 周期を加算
                if (blnFullCycle1stFlg) {
                  // １周期フルの先頭なので、0.5+0.5を加算
                  dblExaminCycling = dblExaminCycling + 1;
                  // １周期初回フラグを落とす
                  blnFullCycle1stFlg = false;
                } else {
                  // 既にその前の周期から続いているので、0.5を加算
                  dblExaminCycling = dblExaminCycling + 0.5;
                }
              }
              // 最大値リセット
              dblMaxValue = -dblNODATA;
            }
            // 半周期の長さ(4W)を満たしていないとき
          } else {
            // へこみ側周期の始点をリセット
            dtmLowerCycleSDate = new Date();
            // 最大値、最小値リセット
            dblMaxValue = -dblNODATA;
            dblMinValue = dblNODATA;

            // １周期初回フラグを立てる
            blnFullCycle1stFlg = true;
          }
          // へこみ側周期の始点が決定しているとき
        } else if (dtmLowerCycleSDate.compareTo(new Date()) != 0) {
          // へこみ側周期の始点との間隔を計算
          lngCycleTermWk = getLngCycleTermWk(dtmLowerCycleSDate, simpleDateFormat.parse(udtExamList.get(intCnt).get("regdate").toString()));
          // 半周期の長さ(4W)を満たしているとき
          if (lngCycleTermWk >= glngMULTIGRA_EXACYCLETERMMIN_HALF) {
            // 満たしているので、盛り上がり側周期の始点とする
            dtmUpperCycleSDate = simpleDateFormat.parse(udtExamList.get(intCnt).get("regdate").toString());
            // 半周期の長さ(4W)を満たしていないとき
          } else {
            // へこみ側周期の始点をリセット
            dtmLowerCycleSDate = new Date();
            // 最大値、最小値リセット
            dblMaxValue = -dblNODATA;
            dblMinValue = dblNODATA;
            // １周期初回フラグを立てる
            blnFullCycle1stFlg = true;
          }
        }
        // 次の半周期の時の計算に使用する日付として記憶する
        dtmUpperCycleSDate = simpleDateFormat.parse(udtExamList.get(intCnt).get("regdate").toString());
        // 中点との交点検索
        // 中点未満と中点以上が隣り合っている箇所を探す
        // 中点以上→中点未満
      } else if (Double.parseDouble(udtExamList.get(intCnt).get("resultvalue").toString()) >= dblAveValue &&
        Double.parseDouble(udtExamList.get(intCnt + 1).get("resultvalue").toString()) < dblAveValue) {
        // へこみ側周期の始点が決定しているとき
        if (dtmLowerCycleSDate.compareTo(new Date()) != 0) {
          // へこみの時にへこみ側周期の始点が決定しているということは、
          // 盛り上がり側周期の始点も決定している
          // 盛り上がり側周期の始点との間隔を計算
          lngCycleTermWk = getLngCycleTermWk(dtmUpperCycleSDate, simpleDateFormat.parse(udtExamList.get(intCnt).get("regdate").toString()));

          // 半周期の長さ(4W)を満たしているとき
          if (lngCycleTermWk >= glngMULTIGRA_EXACYCLETERMMIN_HALF) {
            // 更に、それより前期間のへこみ側周期始点との間隔を計算
            // へこみ側周期の始点との間隔を計算
            lngCycleTermWk = getLngCycleTermWk(dtmLowerCycleSDate, simpleDateFormat.parse(udtExamList.get(intCnt).get("regdate").toString()));

            // １周期の長さ(8W)を満たしているとき
            if (lngCycleTermWk >= glngMULTIGRA_EXACYCLETERMMIN) {
              // 最大値と最小値の差が既定(1.5以上)を満たしているかチェック
              dblValueDiffWk = dblMaxValue - dblMinValue;
              if (dblValueDiffWk >= gdblMULTIGRA_EXACYCLEVALDIFFMIN) {
                // 周期を加算
                if (blnFullCycle1stFlg) {
                  // １周期フルの先頭なので、0.5+0.5を加算
                  dblExaminCycling = dblExaminCycling + 1;
                  // １周期初回フラグを落とす
                  blnFullCycle1stFlg = false;
                } else {
                  // 既にその前の周期から続いているので、0.5を加算
                  dblExaminCycling = dblExaminCycling + 0.5;
                }
              }
              // 最小値リセット
              dblMinValue = dblNODATA;
            }
            // 半周期の長さ(4W)を満たしていないとき
          }
          else
          {
            // 盛り上がり側周期の始点をリセット
            dtmLowerCycleSDate = new Date();
            // 最大値、最小値リセット
            dblMaxValue = -dblNODATA;
            dblMinValue = dblNODATA;
            // １周期初回フラグを立てる
            blnFullCycle1stFlg = true;
          }

          // 盛り上がり側周期の始点が決定しているとき
        } else if (dtmUpperCycleSDate.compareTo(new Date()) != 0) {
          // 盛り上がり側周期の始点との間隔を計算
          lngCycleTermWk = getLngCycleTermWk(dtmUpperCycleSDate, simpleDateFormat.parse(udtExamList.get(intCnt).get("regdate").toString()));
          // 半周期の長さ(4W)を満たしているとき
          if (lngCycleTermWk >= glngMULTIGRA_EXACYCLETERMMIN_HALF)
          {
            // 満たしているので、盛り上がり側周期の始点とする
            dtmLowerCycleSDate = simpleDateFormat.parse(udtExamList.get(intCnt).get("regdate").toString());
            // 半周期の長さ(4W)を満たしていないとき
          }
          else
          {
            // 盛り上がり側周期の始点をリセット
            dtmLowerCycleSDate = new Date();
            // 最大値、最小値リセット
            dblMaxValue = -dblNODATA;
            dblMinValue = dblNODATA;
            // １周期初回フラグを立てる
            blnFullCycle1stFlg = true;
          }
        }

        // 次の半周期の時の計算に使用する日付として記憶する
        dtmLowerCycleSDate = simpleDateFormat.parse(udtExamList.get(intCnt).get("regdate").toString());
      }
    }
    return dblExaminCycling;
  }
  /**
   * 周期間隔日数取得
   *
   * @return 周期間隔日数
   */
  private int getLngCycleTermWk(Date dtmLowerCycleSDate, Date regDate) {
    int lngCycleTermWk = (int)((dtmLowerCycleSDate.getTime() - regDate.getTime()) / (1000*3600*24));
    if (lngCycleTermWk < 0) {
      lngCycleTermWk = lngCycleTermWk * -1;
    }
    return lngCycleTermWk;
  }

  /**
   * 週数取得
   *
   * @return 週数
   */
  private int getWeekCount(String startDate, String endDate, String facilityCd, String patId) {
    List<Object> dayList = mstSupportSettingService.selectDayOfMonth(startDate, endDate);
    List<Map<String,Object>> exceptionPeriodList =  mstSupportSettingService.selectExceptionPeriod(facilityCd, patId);
    for (int i = 0 ; i < dayList.size(); i++) {
      int day = Integer.parseInt(dayList.get(i).toString());
      for (int j = 0 ; j < exceptionPeriodList.size(); j++) {
        int startDay = Integer.parseInt(exceptionPeriodList.get(j).get("fromdate").toString());
        int endDay = Integer.parseInt(exceptionPeriodList.get(j).get("todate").toString());
        if (day >= startDay && day <= endDay) {
          dayList.remove(i);
          i--;
          break;
        }
      }
    }
    return (int)Math.ceil((double)dayList.size() / 7);
  }
  /* del by zhouyingying  2023-02-03 [CodeOptimization] start */
//  private List<String> getDateOfYear(String baseDate){
//    List<String> strings = new ArrayList<String>();
//    String lastYear = "";
//    String nextYear = "";
//    SimpleDateFormat format = new SimpleDateFormat("yyyyMMdd");
//    Calendar c = Calendar.getInstance();
//    try {
//      c.setTime(format.parse(baseDate));
//      c.add(Calendar.YEAR, -1);
//      c.add(Calendar.DAY_OF_MONTH, 1);
//      lastYear = format .format(c.getTime());
//      c.setTime(format.parse(baseDate));
//      c.add(Calendar.YEAR, 1);
//      c.add(Calendar.DAY_OF_MONTH, -1);
//      nextYear = format .format(c.getTime());
//      strings.add(lastYear);
//      strings.add(nextYear);
//    } catch (ParseException e) {
//      e.printStackTrace();
//    }
//      return strings;
//  }
  /* del by zhouyingying  2023-02-03 [CodeOptimization] end */
}
