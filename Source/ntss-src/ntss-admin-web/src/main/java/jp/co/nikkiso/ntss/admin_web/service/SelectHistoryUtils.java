package jp.co.nikkiso.ntss.admin_web.service;

import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.ordMainHst.OrdMainHst;
import jp.co.nikkiso.ntss.admin_web.service.ordMainHst.OrdMainHstService;
import jp.co.nikkiso.ntss.api.utils.DateTimeFormatUtil;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatUniqueDao;
import jp.co.nikkiso.ntss.core.dto.patUnique.PatDWEffectsTimeLineDTO;
import jp.co.nikkiso.ntss.core.entity.DWForMongo;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatUnique;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.utils.MongoHealthCheckService;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessResourceFailureException;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Component
public class SelectHistoryUtils {

  @Autowired
  private OrdMainDao ordMainDao;

  @Autowired
  private OrdMainHstService ordMainHstService;
  @Autowired
  private PatInfoService patInfoService;

  @Autowired(required = false)
  private MongoTemplate mongoTemplate;

  @Autowired
  private PatUniqueDao patUniqueDao;

  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;

  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
  @Autowired
  private LogService logService;
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end

  private static final String FORMAT_DATE = "yyyyMMddHHmmssSSS";

  public boolean insertMangoDbHistory (Integer mode, Long ordNo, Long patId, List<Long> ordNoList, List<Long> kurList,
                                       String facilityCd, Boolean isOnline, String updateTargetIsConfirm,
                                       String startDate, String endDate, List<Integer> week, List<Integer> treatMethod,
                                       String condTreatDate, String treatDate, Integer treatWeek,
                                       List<Long> treatmentCdList, String dialysisDateFrom, String dialysisDateTo
                                       ) {
    // ordMainDao.selectHistory
    List<OrdMain> ordMains= ordMainDao.selectHistory(mode, ordNo, patId, ordNoList, kurList, facilityCd, isOnline, updateTargetIsConfirm
    , startDate, endDate, week, treatMethod, condTreatDate, treatDate, treatWeek, treatmentCdList, dialysisDateFrom
    , dialysisDateTo);
    // ordMains.size()
   if (ordMains.size() > 0) {
      List<OrdMainHst> OrdMainHstList = new ArrayList<>();
      for (OrdMain ordMain : ordMains) {
        OrdMainHst ordMainHst = getOrdMainHstData(ordMain);
        OrdMainHstList.add(ordMainHst);
//        ordMainHstService.create(ordMainHst);
      }
      ordMainHstService.bulkOpsCreate(OrdMainHstList);
    }
//    else if (ordMains.size() == 1) {
//      OrdMainHst ordMainHst = getOrdMainHstData(ordMains.get(0));
//      ordMainHstService.create(ordMainHst);
//    }

    return true;
  }

  public boolean insertMangoDbHistoryBatch (List<Long> ordNoList) {
    List<OrdMainHst> ordMainHsts = new ArrayList<>();
    List<OrdMain> ordMains= ordMainDao.selectHistory(3, null, null, ordNoList, new ArrayList<>(), null, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
      new ArrayList<>(), null, null);
    if (ordMains.size() > 0) {
      for (OrdMain ordMain : ordMains) {
        OrdMainHst ordMainHst = getOrdMainHstData(ordMain);
        ordMainHsts.add(ordMainHst);
      }
      ordMainHstService.bulkOpsCreate(ordMainHsts);
    }
    return true;
  }
  /* add by shiyw 2023-02-21 [#8101] --start */
  public boolean insertMangoDbHistoryBatchByOrdMainList (List<OrdMain> ordMainList) {
    List<OrdMainHst> ordMainHsts = new ArrayList<>();
    if (ordMainList.size() > 0) {
      for (OrdMain ordMain : ordMainList) {
        OrdMainHst ordMainHst = getOrdMainHstData(ordMain);
        ordMainHsts.add(ordMainHst);
      }
      ordMainHstService.bulkOpsCreate(ordMainHsts);
    }
    return true;
  }
  /* add by shiyw 2023-02-21 [#8101] --end */

  public boolean insertMangoDbHistory (Integer mode, Long ordNo, Long patId, List<Long> ordNoList, List<Long> kurList,
                                       String facilityCd, Boolean isOnline, String updateTargetIsConfirm,
                                       String startDate, String endDate, List<Integer> week, List<Integer> treatMethod,
                                       String condTreatDate, String treatDate, Integer treatWeek,
                                       List<Long> treatmentCdList, String dialysisDateFrom, String dialysisDateTo,
                                       int flag
  ) {
    // ordMainDao.selectHistory
    List<OrdMain> ordMains= ordMainDao.selectHistory(mode, ordNo, patId, ordNoList, kurList, facilityCd, isOnline, updateTargetIsConfirm
      , startDate, endDate, week, treatMethod, condTreatDate, treatDate, treatWeek, treatmentCdList, dialysisDateFrom
      , dialysisDateTo);
    // ordMains.size()
    if (ordMains.size() > 0) {
      for (OrdMain ordMain : ordMains) {
        if (flag == 1) {
          ordMain.setIsDel("1");
        }
        OrdMainHst ordMainHst = getOrdMainHstData(ordMain);
        ordMainHstService.create(ordMainHst);
      }
    }
//    else if (ordMains.size() == 1) {
//      OrdMainHst ordMainHst = getOrdMainHstData(ordMains.get(0));
//      ordMainHstService.create(ordMainHst);
//    }

    return true;
  }

  private OrdMainHst getOrdMainHstData(OrdMain ordMain) {
    OrdMainHst ordMainHst = new OrdMainHst();
    ordMainHst.setOrdNo(StringUtils.isEmpty(ordMain.getOrdNo()) ? null : String.valueOf(ordMain.getOrdNo()));
    ordMainHst.setPatId(StringUtils.isEmpty(ordMain.getPatId()) ? null : String.valueOf(ordMain.getPatId()));
    ordMainHst.setFnPatId(StringUtils.isEmpty(ordMain.getFnPatId()) ? null : ordMain.getFnPatId());
    ordMainHst.setTreatDate(StringUtils.isEmpty(ordMain.getTreatDate()) ? null : ordMain.getTreatDate());
    ordMainHst.setTreatWeek(StringUtils.isEmpty(ordMain.getTreatWeek()) ? null : String.valueOf(ordMain.getTreatWeek()));
    ordMainHst.setFacilityCd(StringUtils.isEmpty(ordMain.getFacilityCd()) ? null : ordMain.getFacilityCd());
    ordMainHst.setFacilityName(StringUtils.isEmpty(ordMain.getFacilityName()) ? null : ordMain.getFacilityName());
    ordMainHst.setIndVaCd(StringUtils.isEmpty(ordMain.getIndVaCd()) ? null : String.valueOf(ordMain.getIndVaCd()));
    ordMainHst.setIndTreatmentCd(StringUtils.isEmpty(ordMain.getIndTreatmentCd()) ? null : String.valueOf(ordMain.getIndTreatmentCd()));
    ordMainHst.setIndTreatmentName(StringUtils.isEmpty(ordMain.getIndTreatmentName()) ? null : ordMain.getIndTreatmentName());
    ordMainHst.setIndKurCd(StringUtils.isEmpty(ordMain.getIndKurCd()) ? null : String.valueOf(ordMain.getIndKurCd()));
    ordMainHst.setIndKurName(StringUtils.isEmpty(ordMain.getIndKurName()) ? null : ordMain.getIndKurName());
    ordMainHst.setIndTreatStartTime(StringUtils.isEmpty(ordMain.getIndTreatStartTime()) ? null : ordMain.getIndTreatStartTime());
    ordMainHst.setIndBedCd(StringUtils.isEmpty(ordMain.getIndBedCd()) ? null : String.valueOf(ordMain.getIndBedCd()));
    ordMainHst.setIndBedName(StringUtils.isEmpty(ordMain.getIndBedName()) ? null : ordMain.getIndBedName());
    ordMainHst.setIndScheduleUserInfo(StringUtils.isEmpty(ordMain.getIndScheduleUserInfo()) ? null : ordMain.getIndScheduleUserInfo());
    ordMainHst.setIndCondInfo(StringUtils.isEmpty(ordMain.getIndCondInfo()) ? null : ordMain.getIndCondInfo());
    ordMainHst.setIndMediInfo(StringUtils.isEmpty(ordMain.getIndMediInfo()) ? null : ordMain.getIndMediInfo());
    ordMainHst.setIndEquipInfo(StringUtils.isEmpty(ordMain.getIndEquipInfo()) ? null : ordMain.getIndEquipInfo());
    ordMainHst.setIndIndCommentInfo(StringUtils.isEmpty(ordMain.getIndIndCommentInfo()) ? null : ordMain.getIndIndCommentInfo());
    ordMainHst.setIndTareInfo(StringUtils.isEmpty(ordMain.getIndTareInfo()) ? null : ordMain.getIndTareInfo());
    ordMainHst.setIndOffWaterInfo(StringUtils.isEmpty(ordMain.getIndOffWaterInfo()) ? null : ordMain.getIndOffWaterInfo());
    ordMainHst.setIndDeviceSetInfo(StringUtils.isEmpty(ordMain.getIndDeviceSetInfo()) ? null : ordMain.getIndDeviceSetInfo());
    ordMainHst.setRstFnDialysisNo(StringUtils.isEmpty(ordMain.getRstFnDialysisNo()) ? null : String.valueOf(ordMain.getRstFnDialysisNo()));
    ordMainHst.setRstRelationDialysisNo(StringUtils.isEmpty(ordMain.getRstRelationDialysisNo()) ? null : String.valueOf(ordMain.getRstRelationDialysisNo()));
    ordMainHst.setRstEdition(StringUtils.isEmpty(ordMain.getRstEdition()) ? null : String.valueOf(ordMain.getRstEdition()));
    ordMainHst.setRstIsUpdateEdition(StringUtils.isEmpty(ordMain.getRstIsUpdateEdition()) ? null : ordMain.getRstIsUpdateEdition());
    ordMainHst.setRstInputClass(StringUtils.isEmpty(ordMain.getRstInputClass()) ? null : String.valueOf(ordMain.getRstInputClass()));
    ordMainHst.setRstDialysisState(StringUtils.isEmpty(ordMain.getRstDialysisState()) ? null : ordMain.getRstDialysisState());
    ordMainHst.setRstTreatmentCd(StringUtils.isEmpty(ordMain.getRstTreatmentCd()) ? null : String.valueOf(ordMain.getRstTreatmentCd()));
    ordMainHst.setRstTreatmentName(StringUtils.isEmpty(ordMain.getRstTreatmentName()) ? null : ordMain.getRstTreatmentName());
    ordMainHst.setRstKurCd(StringUtils.isEmpty(ordMain.getRstKurCd()) ? null : String.valueOf(ordMain.getRstKurCd()));
    ordMainHst.setRstKurName(StringUtils.isEmpty(ordMain.getRstKurName()) ? null : ordMain.getRstKurName());
    ordMainHst.setRstBedCd(StringUtils.isEmpty(ordMain.getRstBedCd()) ? null : String.valueOf(ordMain.getRstBedCd()));
    ordMainHst.setRstBedName(StringUtils.isEmpty(ordMain.getRstBedName()) ? null : ordMain.getRstBedName());
    ordMainHst.setRstMachineNo(StringUtils.isEmpty(ordMain.getRstMachineNo()) ? null : String.valueOf(ordMain.getRstMachineNo()));
    ordMainHst.setRstMachineName(StringUtils.isEmpty(ordMain.getRstMachineName()) ? null : ordMain.getRstMachineName());
    ordMainHst.setRstCondSendDate(StringUtils.isEmpty(ordMain.getRstCondSendDate()) ? null : String.valueOf(ordMain.getRstCondSendDate()));
    ordMainHst.setRstAcceptDate(StringUtils.isEmpty(ordMain.getRstAcceptDate()) ? null : String.valueOf(ordMain.getRstAcceptDate()));
    ordMainHst.setRstStartDate(StringUtils.isEmpty(ordMain.getRstStartDate()) ? null : String.valueOf(ordMain.getRstStartDate()));
    ordMainHst.setRstEndDate(StringUtils.isEmpty(ordMain.getRstEndDate()) ? null : String.valueOf(ordMain.getRstEndDate()));
    ordMainHst.setRstReturnHomeDate(StringUtils.isEmpty(ordMain.getRstReturnHomeDate()) ? null : String.valueOf(ordMain.getRstReturnHomeDate()));
    ordMainHst.setRstInOutClass(StringUtils.isEmpty(ordMain.getRstInOutClass()) ? null : String.valueOf(ordMain.getRstInOutClass()));
    ordMainHst.setRstDialysisCnt(StringUtils.isEmpty(ordMain.getRstDialysisCnt()) ? null : String.valueOf(ordMain.getRstDialysisCnt()));
    ordMainHst.setRstWardCd(StringUtils.isEmpty(ordMain.getRstWardCd()) ? null : String.valueOf(ordMain.getRstWardCd()));
    ordMainHst.setRstWardName(StringUtils.isEmpty(ordMain.getRstWardName()) ? null : ordMain.getRstWardName());
    ordMainHst.setRstCourseCd(StringUtils.isEmpty(ordMain.getRstCourseCd()) ? null : String.valueOf(ordMain.getRstCourseCd()));
    ordMainHst.setRstCourseName(StringUtils.isEmpty(ordMain.getRstCourseName()) ? null : ordMain.getRstCourseName());
    ordMainHst.setRstDw(StringUtils.isEmpty(ordMain.getRstDw()) ? null : String.valueOf(ordMain.getRstDw()));
    ordMainHst.setRstPunctureUserInfo(StringUtils.isEmpty(ordMain.getRstPunctureUserInfo()) ? null : ordMain.getRstPunctureUserInfo());
    ordMainHst.setRstReturnUserInfo(StringUtils.isEmpty(ordMain.getRstReturnUserInfo()) ? null : ordMain.getRstReturnUserInfo());
    ordMainHst.setRstChargeUserInfo(StringUtils.isEmpty(ordMain.getRstChargeUserInfo()) ? null : ordMain.getRstChargeUserInfo());
    ordMainHst.setRstBloodCirculateTotal(StringUtils.isEmpty(ordMain.getRstBloodCirculateTotal()) ? null : String.valueOf(ordMain.getRstBloodCirculateTotal()));
    ordMainHst.setRstRunningTime(StringUtils.isEmpty(ordMain.getRstRunningTime()) ? null : String.valueOf(ordMain.getRstRunningTime()));
    ordMainHst.setRstKtV(StringUtils.isEmpty(ordMain.getRstKtV()) ? null : String.valueOf(ordMain.getRstKtV()));
    ordMainHst.setRecSetDate(StringUtils.isEmpty(ordMain.getRecSetDate()) ? null : String.valueOf(ordMain.getRecSetDate()));
    ordMainHst.setSendCtlNo(StringUtils.isEmpty(ordMain.getSendCtlNo()) ? null : String.valueOf(ordMain.getSendCtlNo()));
    ordMainHst.setBloodPurifierName(StringUtils.isEmpty(ordMain.getBloodPurifierName()) ? null : ordMain.getBloodPurifierName());
    ordMainHst.setPullLeaveAmount(StringUtils.isEmpty(ordMain.getPullLeaveAmount()) ? null : String.valueOf(ordMain.getPullLeaveAmount()));
    ordMainHst.setRstCondInfo(StringUtils.isEmpty(ordMain.getRstCondInfo()) ? null :ordMain.getRstCondInfo());
    ordMainHst.setRstMediInfo(StringUtils.isEmpty(ordMain.getRstMediInfo()) ? null : ordMain.getRstMediInfo());
    ordMainHst.setRstEquipInfo(StringUtils.isEmpty(ordMain.getRstEquipInfo()) ? null : ordMain.getRstEquipInfo());
    ordMainHst.setRstIndCommentInfo(StringUtils.isEmpty(ordMain.getRstIndCommentInfo()) ? null : ordMain.getRstIndCommentInfo());
    ordMainHst.setRstTareInfo(StringUtils.isEmpty(ordMain.getRstTareInfo()) ? null : ordMain.getRstTareInfo());
    ordMainHst.setRstOffWaterInfo(StringUtils.isEmpty(ordMain.getRstOffWaterInfo()) ? null : ordMain.getRstOffWaterInfo());
    /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --start */
    //ordMainHst.setRstDeviceSetInfo(StringUtils.isEmpty(ordMain.getRstDeviceSetInfo()) ? null : ordMain.getRstDeviceSetInfo());
    /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --end */
    ordMainHst.setWeightScaleNo(StringUtils.isEmpty(ordMain.getWeightScaleNo()) ? null : String.valueOf(ordMain.getWeightScaleNo()));
    ordMainHst.setRstWeightInfo(StringUtils.isEmpty(ordMain.getRstWeightInfo()) ? null : ordMain.getRstWeightInfo());
    /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --start */
    //ordMainHst.setRstVitalInfo(StringUtils.isEmpty(ordMain.getRstVitalInfo()) ? null : ordMain.getRstVitalInfo());
    /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --end */
    ordMainHst.setRstComplaintInfo(StringUtils.isEmpty(ordMain.getRstComplaintInfo()) ? null : ordMain.getRstComplaintInfo());
    ordMainHst.setRstTreatmentInfo(StringUtils.isEmpty(ordMain.getRstTreatmentInfo()) ? null : ordMain.getRstTreatmentInfo());
    ordMainHst.setRstTreatStaffInfo(StringUtils.isEmpty(ordMain.getRstTreatStaffInfo()) ? null : ordMain.getRstTreatStaffInfo());
    ordMainHst.setRstRoundsInfo(StringUtils.isEmpty(ordMain.getRstRoundsInfo()) ? null : ordMain.getRstRoundsInfo());
    ordMainHst.setIsDel(StringUtils.isEmpty(ordMain.getIsDel()) ? null : ordMain.getIsDel());
    ordMainHst.setUpDate(StringUtils.isEmpty(ordMain.getUpDate()) ? null : String.valueOf(ordMain.getUpDate()));
    ordMainHst.setRegDate(StringUtils.isEmpty(ordMain.getRegDate()) ? null : String.valueOf(ordMain.getRegDate()));
    // mod 11467 【たくしん会】H12条件送信ができない。患者経過総合ビューアのDW表示が不正。 zkm start
//    ordMainHst.setFnPlural(null);
    ordMainHst.setFnPlural(StringUtils.isEmpty(ordMain.getFnPlural()) ? null : String.valueOf(ordMain.getFnPlural()));
    ordMainHst.setBvmsPath(StringUtils.isEmpty(ordMain.getBvmsPath()) ? null : ordMain.getBvmsPath());
    ordMainHst.setCurEditionDate(StringUtils.isEmpty(ordMain.getCurEditionDate()) ? null : String.valueOf(ordMain.getCurEditionDate()));
    ordMainHst.setIndDeviceMode(StringUtils.isEmpty(ordMain.getIndDeviceMode()) ? null : String.valueOf(ordMain.getIndDeviceMode()));
    ordMainHst.setIndDwUserInfo(StringUtils.isEmpty(ordMain.getIndDwUserInfo()) ? null : ordMain.getIndDwUserInfo());
    ordMainHst.setRstDeviceMode(StringUtils.isEmpty(ordMain.getRstDeviceMode()) ? null : String.valueOf(ordMain.getRstDeviceMode()));
    ordMainHst.setRstEditionDate(StringUtils.isEmpty(ordMain.getRstEditionDate()) ? null : String.valueOf(ordMain.getRstEditionDate()));
    ordMainHst.setUpIndUserId(StringUtils.isEmpty(ordMain.getUpIndUserId()) ? null : String.valueOf(ordMain.getUpIndUserId()));
    ordMainHst.setUpUserId(StringUtils.isEmpty(ordMain.getUpUserId()) ? null : String.valueOf(ordMain.getUpUserId()));
    // mod 11467 【たくしん会】H12条件送信ができない。患者経過総合ビューアのDW表示が不正。 zkm end
    ordMainHst.setTreatType(StringUtils.isEmpty(ordMain.getTreatType()) ? null : String.valueOf(ordMain.getTreatType()));
    ordMainHst.setIsConfirm(StringUtils.isEmpty(ordMain.getIsConfirm()) ? null : ordMain.getIsConfirm());
    ordMainHst.setIndDw(StringUtils.isEmpty(ordMain.getIndDw()) ? null : String.valueOf(ordMain.getIndDw()));
    ordMainHst.setRstPurificationCnt(StringUtils.isEmpty(ordMain.getRstPurificationCnt()) ? null : String.valueOf(ordMain.getRstPurificationCnt()));
    ordMainHst.setAdditionInfo(StringUtils.isEmpty(ordMain.getAdditionInfo()) ? null : ordMain.getAdditionInfo());
    ordMainHst.setInsDate(new SimpleDateFormat("yyyyMMddHHmmssSSS").format(new Date()));
    return ordMainHst;
  }

  //add mongodbにデータを加入するの方法　顔 start
  public void insertLogIntoMongo(Map<String, String> payload, long Pat_id, PatUnique patUniqueHaiTa, String logDate) throws ParseException, InterruptedException {
    //add #10532 mongoDBがダウン中の操作について（新患登録） zhao start
    try {
      if (MongoHealthCheckService.getMongoDBConnected()) {
    //add #10532 mongoDBがダウン中の操作について（新患登録） zhao end
    DWForMongo dwForMongo = new DWForMongo();
    boolean sigleInsert = true;
    DWForMongo dwForMongo1 = new DWForMongo();
    JSONObject dwLogInfo = new JSONObject(payload.get("dw_log_info"));
    int is_add = Integer.parseInt(dwLogInfo.get("is_add").toString());
    boolean is_delete = (Boolean) dwLogInfo.get("is_delete");
    boolean is_change = (Boolean) dwLogInfo.get("is_change");
    JSONArray physicalInfo = new JSONArray(patUniqueHaiTa.getPhysical_info());
    ArrayList<Map<String,String>> preDataList = new ArrayList();
    String dw_pre = dwLogInfo.get("dw_pre").toString();
    String dw_aft = dwLogInfo.get("dw_aft").toString();
    //mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zy start
//    String time_pre = dwLogInfo.get("examTime_pre").toString();
    String time_pre = dwLogInfo.has("examTime_pre")&&dwLogInfo.get("examTime_pre")!=null?dwLogInfo.get("examTime_pre").toString():"";
    //mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zy end
    String time_aft = dwLogInfo.get("examTime_aft").toString();
    //もし　dw　が変わらないた
    if((dwLogInfo.get("dw_pre").equals(dwLogInfo.get("dw_aft")) && dwLogInfo.get("dw_pre").equals("未登録"))
      || (dwLogInfo.get("dw_pre").equals(dwLogInfo.get("dw_aft")) && dwLogInfo.get("examTime_aft").equals(dwLogInfo.get("examTime_pre")))){
      return;
    }
    //時間点を抽出してたとソート処理 顔
    for (Object info : physicalInfo) {
      JSONObject data = new JSONObject(info.toString());
      Map<String, String> singleDate = new HashMap<>();
      singleDate.put("dw", data.get("dw").toString());
      singleDate.put("exam_date", (String) data.get("exam_date"));
      singleDate.put("indicator_cd", data.get("indicator_cd").toString());
      preDataList.add(singleDate);
    }
    //dw履歴の順序付け
    for (int j = 0; j < preDataList.size(); j++) {
      for (int i = 0; i < preDataList.size() - 1; i++) {
        if (!time(preDataList.get(i).get("exam_date").toString(), preDataList.get(i + 1).get("exam_date").toString())) {
          Map m = preDataList.get(i + 1);
          preDataList.set(i + 1, preDataList.get(i));
          preDataList.set(i, m);
        }
      }
    }

    //病人のデータを加えています　顔
    try {
      NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
      dwForMongo.setPat_id(String.valueOf(Pat_id));
      dwForMongo.setFacility_cd(user.getFacilityCd());
//      Calendar calendar = Calendar.getInstance();
//      mod  6458 2023-3-17 指示履歴の発行日の情報が正しく表示されない時がある。張 start
//      calendar = Calendar.getInstance();
//      dwForMongo.setLog_date(calendar.get(Calendar.YEAR) + "-" + calendar.get(Calendar.MONTH) + 1 +
//      dwForMongo.setLog_date(calendar.get(Calendar.YEAR) + "-" + (calendar.get(Calendar.MONTH) + 1) +
//      mod  6458 2023-3-17 指示履歴の発行日の情報が正しく表示されない時がある。張 end
//        "-" + calendar.get(Calendar.DATE) + " " + calendar.get(Calendar.HOUR) + ":" + calendar.get(Calendar.MINUTE) + ":" + calendar.get(Calendar.SECOND));

      dwForMongo.setLog_date(logDate);

      dwForMongo.setLog_target("DW");
      dwForMongo.setSort_no(80);

      String creator = dwLogInfo.get("creater").toString();
      dwForMongo.setCreated_user_id(StringUtils.hasText(creator) ? creator : String.valueOf(user.getUserId()));
      dwForMongo.setUpdated_user_id(user.getUserId().toString());
      dwForMongo.setUpdated_by(mstPersonalUserDao.selectUserNameById(user.getUserId()));
      if (dwLogInfo.get("creater").toString().equals("null")) {
        dwForMongo.setCreated_by(mstPersonalUserDao.selectUserNameById(Long.parseLong(preDataList.get(dwLogInfo.getInt("operation_order")).get("indicator_cd").toString())));
      } else {
        dwForMongo.setCreated_by(mstPersonalUserDao.selectUserNameById(Long.parseLong(dwLogInfo.get("creater").toString())));
      }
    } catch (Exception e) {
    }

    BeanUtils.copyProperties(dwForMongo,dwForMongo1);
//    del 6458 2023-3-17 指示履歴の発行日の情報が正しく表示されない時がある。張 start
//    if(is_add == 1){
//      sigleInsert = false;
//      String up_dw = "未登録";
//      String down_dw = "未登録";
//      String up_time = null;
//      String down_time = null;
//      for(Map m : preDataList){
//        if(time(time_aft,m.get("exam_date").toString())){
//          down_dw = m.get("dw").toString();
//          down_time = m.get("exam_date").toString();
//          if(!down_dw.equals("null")){
//            break;
//          }
//        } else{
//          up_dw = m.get("dw").toString();
//          if(!up_dw.equals("null")){
//            up_time = m.get("exam_date").toString();
//          }
//        }
//      }
//
//
//
//      dwForMongo.setTreatment_start_date(time_aft);
//      dwForMongo.setTreatment_end_date(up_time);
//      if (dw_aft.equals(null) || dw_aft.equals("null")) dw_aft = "未登録";
//      if (down_dw.equals(null) || down_dw.equals("null")) down_dw = "未登録";
//      dwForMongo.setLog_content(down_dw + "→" + dw_aft);
//      dwForMongo.setLog_class("新規");
//      Calendar calendar = Calendar.getInstance();
//      SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
//      calendar.setTime(sdf.parse(time_aft.substring(0,10)));
//      dwForMongo.setTreatment_weekday(toWeek(calendar.get(Calendar.DAY_OF_WEEK)));
//      mongoTemplate.insert(dwForMongo, "ind_history");
//    }
//   del 6458 2023-3-17 指示履歴の発行日の情報が正しく表示されない時がある。張 end

    /* #10443 ADD DW指示履歴追加 Start */
    if (is_add == 1) {

      if (payload.containsKey("save_physical_item")
        && StringUtils.hasText(payload.get("save_physical_item"))) {

        JSONObject savePhysicalItem = new JSONObject(payload.get("save_physical_item"));

        if (savePhysicalItem.has("exam_date") && !savePhysicalItem.isNull("exam_date") ) {

          String examDate = savePhysicalItem.getString("exam_date");
          LocalDateTime recordEffectTime = DateTimeFormatUtil.parseDateTime(examDate);

          List<PatDWEffectsTimeLineDTO> beforeModTimeLine = this.patUniqueDao.selectDwEffectsTimeLine(Pat_id);

          if (!CollectionUtils.isEmpty(beforeModTimeLine)) {
            beforeModTimeLine
              .stream()
              .filter(
                bm -> {
                  if (!StringUtils.hasText(bm.getEndDate())) bm.setEndDate("9999-12-31");
                  LocalDateTime startTime = DateTimeFormatUtil.parseDateTime(bm.getStartDate());
                  LocalDateTime endTime = DateTimeFormatUtil.parseDateTime(bm.getEndDate());

                  // newRecord's examDate ⊆ [startTime, endTime)
                  return (startTime.isBefore(recordEffectTime) || startTime.isEqual(recordEffectTime))
                    && endTime.isAfter(recordEffectTime);
                }
              )
              .findFirst()
              .ifPresent(
                record -> {
                  if ("9999-12-31".equals(record.getEndDate())) record.setEndDate(null);
                  dwForMongo.setTreatment_start_date(examDate);
                  dwForMongo.setTreatment_end_date(record.getEndDate());
                  dwForMongo.setLog_content(record.getDw() + "→" + dw_aft);
                  dwForMongo.setTreatment_weekday("月, 火, 水, 木, 金, 土, 日");

                  dwForMongo.setLog_target("DW");
                  dwForMongo.setSort_no(80);
                  dwForMongo.setLog_class("新規");

                  dwForMongo.setTreatment_method("すべて");
                  dwForMongo.setTreatment_course(null);

                  mongoTemplate.insert(dwForMongo, "ind_history");
                }
              );
          }
          else {
            dwForMongo.setTreatment_start_date(examDate);
            dwForMongo.setTreatment_end_date(null);
            dwForMongo.setLog_content("未登録→" + dw_aft);
            dwForMongo.setTreatment_weekday("月, 火, 水, 木, 金, 土, 日");

            dwForMongo.setLog_target("DW");
            dwForMongo.setSort_no(80);
            dwForMongo.setLog_class("新規");

            dwForMongo.setTreatment_method("すべて");
            dwForMongo.setTreatment_course(null);
            mongoTemplate.insert(dwForMongo, "ind_history");
          }
        }
      }
    }
    /* #10443 ADD DW指示履歴追加 End */

    if(is_delete || (is_change && (dw_aft.equals(null) || dw_aft.equals("未登録")) )){
      sigleInsert = false;
      String up_dw_pre = "未登録";
      String down_dw_pre = "未登録";
      String up_time_pre = null;
      String down_time_pre = null;
      int order = dwLogInfo.getInt("operation_order");
      if(preDataList.size() != order+1 && order != 0){
        up_dw_pre = preDataList.get(order - 1).get("dw");
        down_dw_pre = preDataList.get(order + 1).get("dw");
        up_time_pre = preDataList.get(order - 1).get("exam_date");
        down_time_pre = preDataList.get(order + 1).get("exam_date");
      }

      // #10443 Mod out of bounds 対応修正
      if(preDataList.size() == order+1 && order != 0){
        up_dw_pre = preDataList.get(order - 1).get("dw");
        up_time_pre = preDataList.get(order - 1).get("exam_date");
      }

      // #10443 Mod out of bounds 対応修正
      if(order == 0 && preDataList.size() > 1){
        down_dw_pre = preDataList.get(order + 1).get("dw");
        down_time_pre = preDataList.get(order + 1).get("exam_date");
      }

      if((down_dw_pre == null || down_dw_pre.equals("null"))&& order != (preDataList.size()-1))
      for(int i = order+1 ; i < preDataList.size() ; i ++){
        if(!preDataList.get(i).get("dw").equals("null")){
          down_dw_pre = preDataList.get(i).get("dw");
          break;
        }
      };

      if(up_dw_pre.equals("null") && order != 0)
        for(int i = order -1; i > 0 ; i --){
          if(!preDataList.get(i).get("dw").equals("null")){
            up_time_pre = preDataList.get(i).get("exam_date");
            break;
          }

      };


      dwForMongo.setTreatment_start_date(time_pre);
      dwForMongo.setTreatment_end_date(up_time_pre);
      if( dw_pre.equals(null) || dw_pre.equals("null")) dw_pre = "未登録";
      if( down_dw_pre.equals(null) || down_dw_pre.equals("null")) down_dw_pre = "未登録";
      dwForMongo.setLog_content(dw_pre + "→" + down_dw_pre);
      dwForMongo.setLog_class("削除");
      //mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zy start
//      Calendar calendar = Calendar.getInstance();
//      SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
//      calendar.setTime(sdf.parse(time_pre.substring(0,10)));
//      dwForMongo.setTreatment_weekday(toWeek(calendar.get(Calendar.DAY_OF_WEEK)));
      setTimePre(dwForMongo, time_pre);
      //mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zy end
      mongoTemplate.insert(dwForMongo, "ind_history");
      return;
    }

    if(is_change){
      String up_dw_pre = null;
      String down_dw_pre = null;
      String up_time_pre = null;
      String down_time_pre = null;
      String up_dw_aft = null;
      String down_dw_aft = "未登録";
      String up_time_aft = null;
      String down_time_aft = null;

      if(dw_pre.equals("未登録")){
        String up_dw = null;
        String down_dw = null;
        String up_time = null;
        String down_time = null;
        for(Map m : preDataList){
          if(time(time_aft,m.get("exam_date").toString())){
            down_dw = m.get("dw").toString();
            down_time = m.get("exam_date").toString();
            if(!down_dw.equals("null")){
              break;
            }
          } else{
            up_dw = m.get("dw").toString();
            if(!up_dw.equals("null")){
              up_time = m.get("exam_date").toString();
            }
          }
        }

        dwForMongo.setTreatment_start_date(time_aft);
        dwForMongo.setTreatment_end_date(up_time);
        dwForMongo.setLog_content(down_dw + "→" + dw_aft);
        dwForMongo.setLog_class("変更");
        //mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zy start
//      Calendar calendar = Calendar.getInstance();
//      SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
//      calendar.setTime(sdf.parse(time_aft.substring(0,10)));
//      dwForMongo.setTreatment_weekday(toWeek(calendar.get(Calendar.DAY_OF_WEEK)));
        setTimePre(dwForMongo, time_aft);
        //mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zy end
        mongoTemplate.insert(dwForMongo, "ind_history");
        return;
      }

      int order = dwLogInfo.getInt("operation_order");
      if(preDataList.size() != order+1 && order != 0){
        up_dw_pre = preDataList.get(order - 1).get("dw");
        down_dw_pre = preDataList.get(order + 1).get("dw");
        up_time_pre = preDataList.get(order - 1).get("exam_date");
        down_time_pre = preDataList.get(order + 1).get("exam_date");
      }

      // #10443 Mod out of bounds 対応修正
      if(preDataList.size() == order+1 && order != 0){
        up_dw_pre = preDataList.get(order - 1).get("dw");
        up_time_pre = preDataList.get(order - 1).get("exam_date");
      }

      // #10443 Mod out of bounds 対応修正
      if(order == 0 && preDataList.size() > 1){
        down_dw_pre = preDataList.get(order + 1).get("dw");
        down_time_pre = preDataList.get(order + 1).get("exam_date");
      }

      if(down_dw_pre != null)
      if(down_dw_pre.equals("null") && order != (preDataList.size()-1))
        if(order +1 > preDataList.size() )  {
          down_dw_pre = preDataList.get(order).get("dw");
          down_time_pre = preDataList.get(order).get("exam_date");
        }else{
          for(int i = order+1 ; i < preDataList.size() ; i ++){
            if(!preDataList.get(i).get("dw").equals("null")){
              down_dw_pre = preDataList.get(i).get("dw");
              down_time_pre = preDataList.get(i).get("exam_date");
              break;
            }
        }
        };

      if((up_dw_pre == null || up_dw_pre.equals("null"))&& order != 0)
        if(order -1 < 0 )  {
          up_time_pre = preDataList.get(order).get("exam_date");
          up_dw_pre = preDataList.get(order).get("dw");
        }else{
          for(int i = order-1 ; i >= 0 ; i --){
            if(!preDataList.get(i).get("dw").equals("null")){
              up_time_pre = preDataList.get(i).get("exam_date");
              up_dw_pre = preDataList.get(i).get("dw");
              break;
            }
        }
        }

      if(order+1 != preDataList.size() && order != 0)
      if(time(time_aft,time_pre) && !time(time_aft,up_time_pre)){
        if(dw_pre.equals(dw_aft)) sigleInsert = false;
        dwForMongo.setTreatment_start_date(time_pre);
        dwForMongo.setTreatment_end_date(time_aft);
        dwForMongo.setLog_content(dw_pre + "→" + down_dw_pre);
        dwForMongo.setLog_class("変更");
        //mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zy start
//      Calendar calendar = Calendar.getInstance();
//      SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
//      calendar.setTime(sdf.parse(time_pre.substring(0,10)));
//      dwForMongo.setTreatment_weekday(toWeek(calendar.get(Calendar.DAY_OF_WEEK)));
        setTimePre(dwForMongo, time_pre);
        //mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zy end
        mongoTemplate.insert(dwForMongo, "ind_history");
      }else

      if(!time(time_aft,time_pre) && time(time_aft,down_time_pre)){
        if(dw_pre.equals(dw_aft)) sigleInsert = false;
        dwForMongo.setTreatment_start_date(time_aft);
        dwForMongo.setTreatment_end_date(time_pre);
        dwForMongo.setLog_content(down_dw_pre + "→" + dw_aft);
        dwForMongo.setLog_class("変更");
        //mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zy start
//      Calendar calendar = Calendar.getInstance();
//      SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
//      calendar.setTime(sdf.parse(time_pre.substring(0,10)));
//      dwForMongo.setTreatment_weekday(toWeek(calendar.get(Calendar.DAY_OF_WEEK)));
        setTimePre(dwForMongo, time_pre);
        //mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zy end
        mongoTemplate.insert(dwForMongo, "ind_history");
      }else{
        dwForMongo.setTreatment_start_date(time_pre);
        dwForMongo.setTreatment_end_date(up_time_pre);
        dwForMongo.setLog_content(dw_pre + "→" + down_dw_pre);
        dwForMongo.setLog_class("変更");
        //mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zy start
//      Calendar calendar = Calendar.getInstance();
//      SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
//      calendar.setTime(sdf.parse(time_pre.substring(0,10)));
//      dwForMongo.setTreatment_weekday(toWeek(calendar.get(Calendar.DAY_OF_WEEK)));
        setTimePre(dwForMongo, time_pre);
        //mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zy end
        if(!time_aft.equals(time_pre)){
          mongoTemplate.insert(dwForMongo, "ind_history");
        }
      };

      if(order == 0)
        if(time(time_aft,down_time_pre)) {
        if(time(time_aft,time_pre)){
          if(dw_pre.equals(dw_aft)) sigleInsert = false;
          dwForMongo.setTreatment_start_date(time_pre);
          dwForMongo.setTreatment_end_date(time_aft);
          dwForMongo.setLog_content(dw_pre + "→" + down_dw_pre);
          dwForMongo.setLog_class("変更");
          //mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zy start
//          Calendar calendar = Calendar.getInstance();
//          SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
//          calendar.setTime(sdf.parse(time_pre.substring(0,10)));
//          dwForMongo.setTreatment_weekday(toWeek(calendar.get(Calendar.DAY_OF_WEEK)));
          setTimePre(dwForMongo, time_pre);
          //mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zy end
          if(!time_aft.equals(time_pre)) {
            mongoTemplate.insert(dwForMongo, "ind_history");
          }
        }else{
          if(dw_pre.equals(dw_aft)) sigleInsert = false;
          dwForMongo.setTreatment_start_date(time_aft);
          dwForMongo.setTreatment_end_date(time_pre);
          dwForMongo.setLog_content(down_dw_pre + "→" + dw_aft);
          dwForMongo.setLog_class("変更");
          //mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zy start
//          Calendar calendar = Calendar.getInstance();
//          SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
//          calendar.setTime(sdf.parse(time_pre.substring(0,10)));
//          dwForMongo.setTreatment_weekday(toWeek(calendar.get(Calendar.DAY_OF_WEEK)));
          setTimePre(dwForMongo, time_pre);
          //mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zy end
          mongoTemplate.insert(dwForMongo, "ind_history");
        }}else{
          dwForMongo.setTreatment_start_date(time_pre);
          dwForMongo.setTreatment_end_date(up_time_pre);
          dwForMongo.setLog_content(dw_pre + "→" + down_dw_pre);
          dwForMongo.setLog_class("変更");
          //mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zy start
//          Calendar calendar = Calendar.getInstance();
//          SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
//          calendar.setTime(sdf.parse(time_pre.substring(0,10)));
//          dwForMongo.setTreatment_weekday(toWeek(calendar.get(Calendar.DAY_OF_WEEK)));
          setTimePre(dwForMongo, time_pre);
          //mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zy end
          if(!time_aft.equals(time_pre)){
            mongoTemplate.insert(dwForMongo, "ind_history");
          }
        }

      // #10443 Mod out of bounds 対応修正
      if(order+1 == preDataList.size() && order != 0)
        if(!time(time_aft,up_time_pre)){
          if(dw_pre.equals(dw_aft)) sigleInsert = false;
          if(time(time_aft,time_pre)){
            dwForMongo.setTreatment_start_date(time_pre);
            dwForMongo.setTreatment_end_date(time_aft);
            dwForMongo.setLog_content(dw_pre + "→" + "未登録");
            //mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zy start
//            Calendar calendar = Calendar.getInstance();
//            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
//            calendar.setTime(sdf.parse(time_pre.substring(0,10)));
//            dwForMongo.setTreatment_weekday(toWeek(calendar.get(Calendar.DAY_OF_WEEK)));
            setTimePre(dwForMongo, time_pre);
            //mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zy end
            if(!time_aft.equals(time_pre)) {
              mongoTemplate.insert(dwForMongo, "ind_history");
            }
          }else{
            dwForMongo.setTreatment_start_date(time_aft);
            dwForMongo.setTreatment_end_date(time_pre);
            dwForMongo.setLog_content("未登録" + "→" + dw_aft);
            dwForMongo.setLog_class("変更");
            //mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zy start
//            Calendar calendar = Calendar.getInstance();
//            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
//            calendar.setTime(sdf.parse(time_pre.substring(0,10)));
//            dwForMongo.setTreatment_weekday(toWeek(calendar.get(Calendar.DAY_OF_WEEK)));
            setTimePre(dwForMongo, time_pre);
            //mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zy end
            mongoTemplate.insert(dwForMongo, "ind_history");
          }
        }else{
          dwForMongo.setTreatment_start_date(time_pre);
          dwForMongo.setTreatment_end_date(up_time_pre);
          dwForMongo.setLog_content( dw_pre + "→" + "未登録");
          dwForMongo.setLog_class("変更");
          //mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zy start
//          Calendar calendar = Calendar.getInstance();
//          SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
//          calendar.setTime(sdf.parse(time_pre.substring(0,10)));
//          dwForMongo.setTreatment_weekday(toWeek(calendar.get(Calendar.DAY_OF_WEEK)));
          setTimePre(dwForMongo, time_pre);
          //mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zy end
          if(!time_aft.equals(time_pre)) {
            mongoTemplate.insert(dwForMongo, "ind_history");
          }
        }



      String up_dw = "未登録";
      String down_dw = "未登録";
      String up_time = null;
      String down_time = null;
      for(Map m : preDataList){
        if(time(time_aft,m.get("exam_date").toString())){
          down_dw = m.get("dw").toString();
          down_time = m.get("exam_date").toString();
          if(!down_dw.equals("null")){
            break;
          }
        } else{
          up_dw = m.get("dw").toString();
          if(!up_dw.equals("null")){
            up_time = m.get("exam_date").toString();
          }
        }
      }

      if(sigleInsert)
      if(order+1 != preDataList.size()){
        for(Map m : preDataList){
          if(time(time_aft,m.get("exam_date").toString())){
            down_dw = m.get("dw").toString();
            down_time = m.get("exam_date").toString();
            if(!down_dw.equals("null")){
              break;
            }
          } else{
            up_dw = m.get("dw").toString();
            if(!up_dw.equals("null")){
              up_time = m.get("exam_date").toString();
            }
          }
        }
          if(!time(time_aft,time_pre) && time(time_aft,down_time_pre)) {
            dwForMongo1.setTreatment_start_date(time_pre);
            dwForMongo1.setTreatment_end_date(up_time_pre);
            dwForMongo1.setLog_content(dw_pre + "→" + dw_aft);
            dwForMongo1.setLog_class("変更");
            //mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zy start
//            Calendar calendar = Calendar.getInstance();
//            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
//            calendar.setTime(sdf.parse(time_aft.substring(0,10)));
//            dwForMongo1.setTreatment_weekday(toWeek(calendar.get(Calendar.DAY_OF_WEEK)));
            setTimePre(dwForMongo1, time_aft);
            //mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zy end
            mongoTemplate.insert(dwForMongo1, "ind_history");
          }else if(time(time_aft,time_pre) && !time(time_aft,up_time_pre)){
            dwForMongo1.setTreatment_start_date(time_aft);
            dwForMongo1.setTreatment_end_date(up_time);
            dwForMongo1.setLog_content(dw_pre + "→" + dw_aft);
            dwForMongo1.setLog_class("変更");
            //mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zy start
//            Calendar calendar = Calendar.getInstance();
//            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
//            calendar.setTime(sdf.parse(time_aft.substring(0,10)));
//            dwForMongo1.setTreatment_weekday(toWeek(calendar.get(Calendar.DAY_OF_WEEK)));
            setTimePre(dwForMongo1, time_aft);
            //mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zy end
            mongoTemplate.insert(dwForMongo1, "ind_history");
          }else{

            dwForMongo1.setTreatment_start_date(time_aft);
            dwForMongo1.setTreatment_end_date(up_time);
            dwForMongo1.setLog_content(down_dw + "→" + dw_aft);
            dwForMongo1.setLog_class("変更");
            //mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zy start
//            Calendar calendar = Calendar.getInstance();
//            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
//            calendar.setTime(sdf.parse(time_aft.substring(0,10)));
//            dwForMongo1.setTreatment_weekday(toWeek(calendar.get(Calendar.DAY_OF_WEEK)));
            setTimePre(dwForMongo1, time_aft);
            //mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zy end
            mongoTemplate.insert(dwForMongo1, "ind_history");
          }
      }else{
        for(int i = order-1 ; i >= 0 ; i --){
          if(!preDataList.get(i).get("dw").equals("null")){
            up_time_pre = preDataList.get(i).get("exam_date");
            up_dw_pre = preDataList.get(i).get("dw");
            break;
          }
        }

        if(time(time_aft,time_pre) && time(time_aft,up_time_pre)){
          dwForMongo1.setTreatment_start_date(time_aft);
          dwForMongo1.setTreatment_end_date(up_time);
          dwForMongo1.setLog_content(down_dw + "→" + dw_aft);
          dwForMongo1.setLog_class("変更");
          //mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zy start
//          Calendar calendar = Calendar.getInstance();
//          SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
//          calendar.setTime(sdf.parse(time_aft.substring(0,10)));
//          dwForMongo1.setTreatment_weekday(toWeek(calendar.get(Calendar.DAY_OF_WEEK)));
          setTimePre(dwForMongo1, time_aft);
          //mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zy end
          mongoTemplate.insert(dwForMongo1, "ind_history");
          return;
        }

        if(!time(time_aft,time_pre)){
          dwForMongo1.setTreatment_start_date(time_pre);
          dwForMongo1.setTreatment_end_date(up_time_pre);
          dwForMongo1.setLog_content(dw_pre + "→" + dw_aft);
          dwForMongo1.setLog_class("変更");
          //mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zy start
//          Calendar calendar = Calendar.getInstance();
//          SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
//          calendar.setTime(sdf.parse(time_aft.substring(0,10)));
//          dwForMongo1.setTreatment_weekday(toWeek(calendar.get(Calendar.DAY_OF_WEEK)));
          setTimePre(dwForMongo1, time_aft);
          //mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zy end
          mongoTemplate.insert(dwForMongo1, "ind_history");
        }

        if(time(time_aft,time_pre)){
          dwForMongo1.setTreatment_start_date(time_pre);
          dwForMongo1.setTreatment_end_date(up_time);
          dwForMongo1.setLog_content(dw_pre + "→" + dw_aft);
          dwForMongo1.setLog_class("変更");
          //mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zy start
//          Calendar calendar = Calendar.getInstance();
//          SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
//          calendar.setTime(sdf.parse(time_aft.substring(0,10)));
//          dwForMongo1.setTreatment_weekday(toWeek(calendar.get(Calendar.DAY_OF_WEEK)));
          setTimePre(dwForMongo1, time_aft);
          //mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zy end
          mongoTemplate.insert(dwForMongo1, "ind_history");
        }
      }



    }
    //add #10532 mongoDBがダウン中の操作について（新患登録） zhao start
      }
    } catch (DataAccessResourceFailureException exception) {
      MongoHealthCheckService.setMongoDBConnected(false);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//            exception.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(exception));
      if (patUniqueHaiTa != null && !StringUtils.isEmpty(patUniqueHaiTa.getFacility_cd())) {
        eventLogMessage.setFacilityCd(patUniqueHaiTa.getFacility_cd());
      }
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
    //add #10532 mongoDBがダウン中の操作について（新患登録） zhao end

  }

  // add #10210 帳票における患者情報の取得元について limingzhe start
  public void insertMongoPatHistoryInto(Long patId) throws ParseException, InterruptedException {
    try {
      // mod #10436 同姓同名フラグの更新時に対になる患者のpat_main_historyがinsertされていない zhao start
      patInfoService.isSameToMoGo(patId);
      // mod #10436 同姓同名フラグの更新時に対になる患者のpat_main_historyがinsertされていない zhao end
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
  }
  // add #10210 帳票における患者情報の取得元について limingzhe end

  //add 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zy start
  private void setTimePre(DWForMongo dwForMongo, String time_pre) throws ParseException {
    // #10443 Mod Start
//    if (time_pre.length() > 9) {
//      Calendar calendar = Calendar.getInstance();
//      SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
//      calendar.setTime(sdf.parse(time_pre.substring(0, 10)));
//      dwForMongo.setTreatment_weekday(toWeek(calendar.get(Calendar.DAY_OF_WEEK)));
//    }
    dwForMongo.setTreatment_weekday("月, 火, 水, 木, 金, 土, 日");
    dwForMongo.setTreatment_method("すべて");
    // #10443 Mod End
    dwForMongo.set_id(null);
  }
  //add 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zy end

  //時間の比較
  public boolean time(String time1, String time2) throws ParseException {
    if(time2 == null || time2.equals("null")){
      return false;
    }
    if(time1 == null || time1.equals("null")){
      return true;
    }
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXX");
    SimpleDateFormat sdf_other = new SimpleDateFormat("yyyy-MM-dd");
    Date date1 = null;
    Date date2 = null;
    if(time1.length() == 10){
      date1 = sdf_other.parse(time1);
    }else{
      date1 = sdf.parse(time1);
    }

    if(time2.length() == 10){
      date2 = sdf_other.parse(time2);
    }else{
      date2 = sdf.parse(time2);
    }

    if(date1.equals(date2)) return true;
    if(date1.after(date2)) return true;
    return false;
  }
  //add mongodbにデータを加入するの方法　顔 end

  /**
   * 曜日の判断
   */
  public static String toWeek(int cd) {
    switch (cd) {
      case 1:
        return "月";
      case 2:
        return "火";
      case 3:
        return "水";
      case 4:
        return "木";
      case 5:
        return "金";
      case 6:
        return "土";
      case 7:
        return "日";
    }
    return "";
  }

}
