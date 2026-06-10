package jp.co.nikkiso.ntss.admin_web.service.master.supportSetting;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.response.exceptionPeriod.ExceptionPeriodResponse;
import jp.co.nikkiso.ntss.admin_web.service.exceptionPeriod.ExceptionPeriodService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstSupportDao;
import jp.co.nikkiso.ntss.core.dao.OrdMaterialSaveDao;
import jp.co.nikkiso.ntss.core.dao.PatExamMainDao;
import jp.co.nikkiso.ntss.core.entity.ExceptionPeriod;
import jp.co.nikkiso.ntss.core.entity.MntMedicineSupport;
import jp.co.nikkiso.ntss.core.entity.OrdMaterialSave;
import jp.co.nikkiso.ntss.core.entity.PatExamMain;
import jp.co.nikkiso.ntss.core.entity.custom.CheckAvgData;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainExamResultInfo;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.apache.commons.collections4.CollectionUtils;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Map;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Service
public class MstSupportSettingServiceImpl implements MstSupportSettingService {

  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
  @Autowired
  private LogService logService;
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end

  /**
   * 施設マスタのDaoインタフェース.
   */
  @Autowired
  private MstSupportDao mstSupportDao;

  @Autowired
  private OrdMaterialSaveDao ordMaterialSaveDao;

  @Autowired
  private PatExamMainDao patExamMainDao;

  @Autowired
  private ExceptionPeriodService ExceptionPeriodService;

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MntMedicineSupport> selectMedicineSupport(String facilityCd) {
    return mstSupportDao.selectMedicineSupport(facilityCd);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<Map<String,Object>> selectResultValue(String facilityCd, String cd, String patId, String startDate, String endDate, List<ExceptionPeriod> listExceptionPeriod) {
    return mstSupportDao.selectResultValue(facilityCd, cd, patId, startDate, endDate, listExceptionPeriod);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<CheckAvgData> selectCheckAvgData(String facilityCd, String patId, String startDate, String endDate, List<ExceptionPeriod> listExceptionPeriod,String cd) {
    return mstSupportDao.selectCheckAvgData(facilityCd, patId, startDate, endDate,listExceptionPeriod, cd);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<Map<String,Object>> selectExceptionPeriod(String facilityCd, String patId) {
    return mstSupportDao.selectExceptionPeriod(facilityCd, patId);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public Map<String,Object> selectRange(String cd) {
    return mstSupportDao.selectRange(cd);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<Map<String,Object>> selectDrugData(String facilityCd, String patId, String baseDate, String cd) {
    return mstSupportDao.selectDrugData(facilityCd, patId, baseDate, cd);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<Map<String,Object>> selectMedicineData(String cd) {
    return mstSupportDao.selectMedicineData(cd);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public String selectRstValueData(String facilityCd, String patId, String startDate,String endDate, String suppliesCd,String rstClass,List<ExceptionPeriod> listExceptionPeriod) {
    return mstSupportDao.selectRstValueData(facilityCd, patId, startDate,endDate,suppliesCd,rstClass,listExceptionPeriod);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<Object> selectDayOfMonth(String startDate, String endDate) {
    return mstSupportDao.selectDayOfMonth(startDate, endDate);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public String selectAvgData(String facilityCd, String patId, String startDate, String endDate, String cd,List<ExceptionPeriod> listExceptionPeriod) {
    return mstSupportDao.selectAvgData(facilityCd, patId, startDate, endDate, cd,listExceptionPeriod);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public String selectUnitOfCd(String cd, String type) {
    return mstSupportDao.selectUnitOfCd(cd, type);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public String selectWeekCountOfCd(String cd, String baseDate, String facilityCd, String patId) {
    return mstSupportDao.selectWeekCountOfCd(cd, baseDate, facilityCd, patId);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  // mod #7746 投与支援で薬剤に薬効換算マスタの薬剤グループを設定すると算出できない 鄭爽 start
//  public List<Map<String,Object>> selectMultiplicationData(String groupCd, String baseDate, String facilityCd, String patId) {
//    return mstSupportDao.selectMultiplicationData(groupCd, baseDate, facilityCd, patId);
  public List<Map<String,Object>> selectMultiplicationData(String groupCd, String startDate, String endDate, String facilityCd, String patId) {
    return mstSupportDao.selectMultiplicationData(groupCd, startDate, endDate, facilityCd, patId);
    // mod #7746 投与支援で薬剤に薬効換算マスタの薬剤グループを設定すると算出できない 鄭爽 end
  }

  /**
   *  {@inheritDoc}
   */
  @Override
  @Transactional
  public int saveOrdMaterialSave(List<String> saveParameter) {

    int total = 0;
    // 施設コード
    String facilityCd = saveParameter.get(0);
    // 患者ID
    Long patId = Long.valueOf(saveParameter.get(1));
    // 基準日
    String baseDate = saveParameter.get(2);
    // 対象の薬剤コード（ESA投与支援）
    String esaCd = saveParameter.get(3);
    // 対象の検査項目コード(cycling・予測値)
    String cyclingCd = saveParameter.get(4);
    // 目標投与量（週）
    String investment = saveParameter.get(5);
    // 予測値
    String prediction = saveParameter.get(6);

    // 物品区分
    List<String> itemList = new ArrayList<>();
    itemList.add("18");
    itemList.add("19");
    // 物品コード
    List<String> cdList = new ArrayList<>();
    cdList.add(esaCd);
    cdList.add(cyclingCd);
    // 指示・実績値
    List<String> actualList = new ArrayList<>();
    actualList.add(investment);
    actualList.add(prediction);
    List<String> ordNoList = mstSupportDao.selectOrdNo(baseDate, facilityCd, patId);

    int resultRow = mstSupportDao.deleteMaterial(baseDate, facilityCd, patId);
    if (resultRow >= 0 ) {
      for (int i = 0; i < itemList.size(); i++) {
        OrdMaterialSave ordMaterialSave = new OrdMaterialSave();
        ordMaterialSave.setFacilityCd(facilityCd);
        ordMaterialSave.setPatId(patId);
        ordMaterialSave.setSuppliesBaseDate(baseDate);
        if (ordNoList.size() > 0) {
          ordMaterialSave.setSuppliesBaseNo(Long.valueOf(ordNoList.get(0)));
        } else {
          ordMaterialSave.setSuppliesBaseNo(null);
        }
        ordMaterialSave.setSuppliesSourceClass("5");
        ordMaterialSave.setSuppliesClass(itemList.get(i));
        ordMaterialSave.setSuppliesCd(cdList.get(i));
        ordMaterialSave.setMedicineMixCd(null);
        ordMaterialSave.setClassCd(null);
        ordMaterialSave.setIndRstClass("2");
        ordMaterialSave.setIndRstValue(actualList.get(i));
        ordMaterialSave.setReceiptValue(null);
        ordMaterialSave.setIsConfirm("1");
        ordMaterialSave.setRegDate(new Timestamp(new Date().getTime()));
        ordMaterialSave.setUpDate(new Timestamp(new Date().getTime()));
        ordMaterialSaveDao.insert(ordMaterialSave);
        total++;
      }
    }
    return total;
  }

  /* add by zhouyingying  2023-02-02 [CodeOptimization] start */
  /**
   * 薬剤平均投与量取得.
   * @param avgInvestParameter
   * @return
   */
  public List<List<String>> getAvgInvestData(List<String> avgInvestParameter){
    try{
      List<List<String>> drugList = new ArrayList<>();
      String facilityCd = avgInvestParameter.get(0);
      String patId = avgInvestParameter.get(1);
      String indexCd = avgInvestParameter.get(2);
      String startDate = avgInvestParameter.get(3);
      String endDate = avgInvestParameter.get(4);
      String cyclingCd = avgInvestParameter.get(5);
      String baseDate = avgInvestParameter.get(6);
      String lastSunday = avgInvestParameter.get(7);
      //FNSI-修正 #6557 昨年と来年の取得 ljx add start
      String lastYearDate = this.getDateOfYear(baseDate).get(0);
      String nextYearDate = this.getDateOfYear(baseDate).get(1);
      //FNSI-修正 #6557 昨年と来年の取得 ljx add end

      int weekCount = getWeekCount(startDate, lastSunday, facilityCd, patId);
      List<Map<String,Object>> selectMedicineList = selectMedicineData(indexCd);
      for (Map<String,Object> selectMedicine : selectMedicineList) {
        String cd = selectMedicine.get("detail_info_value").toString();
        String name = selectMedicine.get("detail_info_text").toString();
        String type = selectMedicine.get("detail_info_type").toString();

        //FNSI-修正 #6557 年間投与数と投与指示数の取得 ljx add start
//      mod 5527 除外期間が適用されていない。張 start
//        String resultValue = mstSupportSettingService.selectRstValueData(facilityCd, patId, lastYearDate,baseDate, cd,"2");
//        String reserveValue = mstSupportSettingService.selectRstValueData(facilityCd, patId, baseDate,nextYearDate, cd,"1");
        List<ExceptionPeriod> listExceptionPeriod = getExceptionPeriods(facilityCd, patId);
        String resultValue = selectRstValueData(facilityCd, patId, lastYearDate,baseDate, cd,"2",listExceptionPeriod);
        String reserveValue = selectRstValueData(facilityCd, patId, baseDate,nextYearDate, cd,"1",listExceptionPeriod);
        //    mod 5527 除外期間が適用されていない。張 end
        //FNSI-修正 #6557 年間投与数と投与指示数の取得 ljx add end

        if ("1".equals(type)) {
          //    mod 5527 除外期間が適用されていない。張 start
//          String rstValue = mstSupportSettingService.selectRstValueData(facilityCd, patId, startDate,endDate, cd,"2");
          String rstValue = selectRstValueData(facilityCd, patId, startDate,endDate, cd,"2", listExceptionPeriod);
          //    mod 5527 除外期間が適用されていない。張 end
          if (rstValue == null || "".equals(rstValue)) {
            rstValue = "0";
          }
          List<String> itemList = new ArrayList<>();
          // 薬剤名
          itemList.add(name);
          itemList.add("");
          // 週平均値
          itemList.add(String.format("%.2f", Double.parseDouble(rstValue) / weekCount));
          // 項目名
          itemList.add(getExamItemAvgValue(patId,startDate,endDate,cyclingCd));
          // 年間投与数
          itemList.add(resultValue);
          // 投与指示数
          itemList.add(reserveValue);

          drugList.add(itemList);
        } else if ("2".equals(type)) {
          //    mod 5527 除外期間が適用されていない。張 start
//          String rstValue = mstSupportSettingService.selectRstValueData(facilityCd, patId, startDate,endDate, cd,"2");
          String rstValue = selectRstValueData(facilityCd, patId, startDate,endDate, cd,"2", listExceptionPeriod);
          //    mod 5527 除外期間が適用されていない。張 end
          if (rstValue == null || "".equals(rstValue)) {
            rstValue = "0";
          }
          List<String> itemList = new ArrayList<>();
          // 薬剤名
          itemList.add(name);
          itemList.add("");
          // 週平均値
          itemList.add(String.format("%.2f", Double.parseDouble(rstValue) / weekCount));
          // 項目名
          itemList.add(getExamItemAvgValue(patId,startDate,endDate,cyclingCd));
          // 年間投与数
          itemList.add("");
          // 投与指示数
          itemList.add("");

          drugList.add(itemList);

          List<Map<String, Object>> itemMapList = selectDrugData(facilityCd, patId, endDate, cd);
          for (Map<String, Object> item : itemMapList) {
            itemList = new ArrayList<>();
            // 薬剤名
            itemList.add("");
            itemList.add(item.get("medicine_name").toString());
            // 週平均値
            itemList.add("");
            // 項目名
            itemList.add("");
            // 年間投与数
            itemList.add(item.get("ind_rst_value").toString());
            // 投与指示数
            itemList.add(item.get("ind_rst_value").toString());

            drugList.add(itemList);
          }
        } else {
          // mod #7746 投与支援で薬剤に薬効換算マスタの薬剤グループを設定すると算出できない 鄭爽 start
          // List<Map<String,Object>> rstValueList = selectMultiplicationData(cd, endDate, facilityCd, patId);
          List<Map<String,Object>> rstValueList = selectMultiplicationData(cd, startDate, endDate, facilityCd, patId);
          // mod #7746 投与支援で薬剤に薬効換算マスタの薬剤グループを設定すると算出できない 鄭爽 end
          double groupValue = 0;
          List<List<String>> rstList = new ArrayList<>();
          for (Map<String,Object> rstMap : rstValueList) {
            double multiplication = 0;
            String rstFlg = "";
            String rstCd = "";
            String rstName = "";
            String rstValue = "";
            if (rstMap.get("multiplication") != null) {
              multiplication = Double.parseDouble(rstMap.get("multiplication").toString());
            }
            groupValue = groupValue + multiplication;
            if (rstMap.get("mediflg") != null) {
              rstFlg = rstMap.get("mediflg").toString();
            }
            if (rstMap.get("cd") != null) {
              rstCd = rstMap.get("cd").toString();
            }
            if (rstMap.get("medicine_name") != null) {
              rstName = rstMap.get("medicine_name").toString();
            }
            if (rstMap.get("sumvalue") != null) {
              rstValue = rstMap.get("sumvalue").toString();
            }
            if ("2".equals(rstFlg)) {
              List<Map<String, Object>> itemMapList = selectDrugData(facilityCd, patId, endDate, rstCd);
              for (Map<String, Object> item : itemMapList) {
                //    mod 5527 除外期間が適用されていない。張 start
//                String valueData = mstSupportSettingService.selectRstValueData(facilityCd, patId, startDate,endDate, item.get("medicine_cd").toString(),"2");
                String valueData = selectRstValueData(facilityCd, patId, startDate,endDate, item.get("medicine_cd").toString(),"2", listExceptionPeriod);
                //    mod 5527 除外期間が適用されていない。張 end
                if (valueData == null || "".equals(valueData)) {
                  valueData = "0";
                }
                List<String> itemList = new ArrayList<>();
                // 薬剤名
                itemList.add("");
                itemList.add(item.get("medicine_name").toString());
                // 週平均値
                itemList.add("");
                // 項目名
                itemList.add("");
                // 年間投与数
                itemList.add(valueData);
                // 投与指示数
                itemList.add(valueData);
                if (!rstList.contains(itemList)) {
                  rstList.add(itemList);
                }
              }
            } else if ("0".equals(rstFlg)) {
              if (rstValue == null || "".equals(rstValue)) {
                rstValue = "0";
              }
              List<String> itemList = new ArrayList<>();

              // 薬剤名
              itemList.add("");
              itemList.add(rstName);
              // 週平均値
              itemList.add("");
              // 項目名
              itemList.add("");
              // 年間投与数
              itemList.add(rstValue);
              // 投与指示数
              itemList.add(rstValue);
              if (!rstList.contains(itemList)) {
                rstList.add(itemList);
              }
            }
          }

          List<String> itemList = new ArrayList<>();

          // 薬剤名
          itemList.add(name);
          itemList.add("");
          // 週平均値
          itemList.add(String.format("%.2f", groupValue / weekCount));
          // 項目名

          itemList.add(getExamItemAvgValue(patId,startDate,endDate,cyclingCd));
          // 年間投与数
          itemList.add("");
          // 投与指示数
          itemList.add("");

          drugList.add(itemList);
          drugList.addAll(rstList);
        }
      }
      return drugList;
    }catch(Exception e){
      return new ArrayList<>();
    }
  }

  /**
   * 検査結果項目の平均値を計算する
   * @param patId
   * @param startDate
   * @param endDate
   * @param cyclingCd
   * @return
   * @throws IOException
   */
  private String getExamItemAvgValue(String patId, String startDate, String endDate, String cyclingCd) throws IOException {
    /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
    // List<PatExamMain> patExamMains = patExamMainDao.selectPatExamMainByDateCd(Integer.parseInt(patId), startDate, endDate);
    List<PatExamMain> patExamMains = patExamMainDao.selectPatExamMainByDateCd(Integer.parseInt(patId), startDate, endDate, 1);
    /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --end */

    Double sumValue = Double.valueOf("0");
    // mod bug 6558 修正 chen start
    // int patExamMainsSize = 1;
    int patExamMainsSize = 0;
    if (CollectionUtils.isNotEmpty(patExamMains)){
      // patExamMainsSize = patExamMains.size();
      for (PatExamMain patExamMain : patExamMains){
        List<PatExamMainExamResultInfo> examResultInfos =
          patExamMain.getExamResultInfo() == null || patExamMain.getExamResultInfo().isEmpty()
            ? new ArrayList<>()
            : new ObjectMapper().readValue(patExamMain.getExamResultInfo(), new TypeReference<List<PatExamMainExamResultInfo>>() {});
        for (PatExamMainExamResultInfo resultInfo : examResultInfos){
          if (cyclingCd.equals(resultInfo.getItem_cd())){
            sumValue = sumValue + Double.valueOf(resultInfo.getResult());
            patExamMainsSize++;
          }
        }
      }
    }
    if (patExamMainsSize == 0) {
      patExamMainsSize = 1;
    }
    // mod bug 6558 修正 chen end
    return String.format("%.2f", sumValue / patExamMainsSize);
  }

  /**
   * 週数取得
   *
   * @return 週数
   */
  private int getWeekCount(String startDate, String endDate, String facilityCd, String patId) {
    List<Object> dayList = selectDayOfMonth(startDate, endDate);
    List<Map<String,Object>> exceptionPeriodList =  selectExceptionPeriod(facilityCd, patId);
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
  private List<String> getDateOfYear(String baseDate){
    List<String> strings = new ArrayList<String>();
    String lastYear = "";
    String nextYear = "";
    SimpleDateFormat format = new SimpleDateFormat("yyyyMMdd");
    Calendar c = Calendar.getInstance();
    try {
      c.setTime(format.parse(baseDate));
      c.add(Calendar.YEAR, -1);
      c.add(Calendar.DAY_OF_MONTH, 1);
      lastYear = format .format(c.getTime());
      c.setTime(format.parse(baseDate));
      c.add(Calendar.YEAR, 1);
      c.add(Calendar.DAY_OF_MONTH, -1);
      nextYear = format .format(c.getTime());
      strings.add(lastYear);
      strings.add(nextYear);
    } catch (ParseException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
    return strings;
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
  /* add by zhouyingying  2023-02-02 [CodeOptimization] start */
}
