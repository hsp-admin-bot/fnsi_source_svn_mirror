package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.request.patEvent.PatEventRequest;
import jp.co.nikkiso.ntss.admin_web.response.patEvent.PatEventMasterResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.ScheduleListService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.patEvent.PatEventService;
import jp.co.nikkiso.ntss.admin_web.service.utils.StrUtils;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.PatEventUtils;
import jp.co.nikkiso.ntss.admin_web.web.service.MaterialsSharingPatientInformation.MaterialsSharingPatientInfomationService;
import jp.co.nikkiso.ntss.api.service.SysDataSetService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.entity.*;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainPatEventRecCombo;
import jp.co.nikkiso.ntss.core.entity.custom.PatEventCoopInfo;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.net.URISyntaxException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;

/**
 * 患者イベント系のRestクラス
 */
@RestController
@RequestMapping(Uri.PAT_EVENT)
public class PatEventResource {

  @Autowired
  private PatEventService patEventRecService;

  @Autowired
  ScheduleListService scheduleListService;

  @Autowired
  LogService logService;

  // add FNSi5712アプリケーションログが出力しない 周 start
  @Autowired
  LogEventUtils logEventUtils;
  // add FNSi5712アプリケーションログが出力しない 周 end

  @Autowired
  MaterialsSharingPatientInfomationService materialsSharingPatientInfomationService;

  @Autowired
  private SysDataSetService sysDataSetService;
  /**
   * データ取得
   * @param patId
   * @param startDate
   * @param endDate
   * @return
   */
  @GetMapping("/{patId}/{startDate}/{endDate}")
  /*mod FNSI-改修内容患者イベント患者情報共有より改修 任 start*/
  /*public ResponseEntity<?> getPatEventRecAll(
    @PathVariable(name = "patId", required = true) String patId,
    @PathVariable(name = "startDate", required = true) String startDate,
    @PathVariable(name = "endDate", required = true) String endDate) {
    List<PatEvent> res = new ArrayList<PatEvent>();
    Timestamp dateFrom =  toTimestampStart(startDate, Timestamp.valueOf("1970-01-01 00:00:00"));
    Timestamp dateTo = toTimestampEnd(endDate, Timestamp.valueOf("9999-01-01 00:00:00"));
    if (patId != null && StrUtils.isNumber(patId)) {
      //患者ID、起票日時で検索
      res = patEventRecService.selectByPatIdNewest(Long.parseLong(patId),
        dateFrom,
        dateTo);
      List<Long> srcPatIds = materialsSharingPatientInfomationService.getListPatIdSrcFromPatDst(Long.parseLong(patId));
      for (Long srcPatId : srcPatIds) {
        //患者ID、起票日時で検索
        List<PatEvent> newList = patEventRecService.selectByPatIdNewest(srcPatId,
          dateFrom,
          dateTo);
        if(!newList.isEmpty()){
          res.addAll(newList);
        }

      }
    } else {
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
    return new ResponseEntity<>(res, HttpStatus.OK);
  }*/
  public ResponseEntity<?> getPatEventRecAll(
      @PathVariable(name = "patId", required = true) String patId,
      @PathVariable(name = "startDate", required = true) String startDate,
      @PathVariable(name = "endDate", required = true) String endDate,
      @RequestParam(name = "patEventCd", required = false) Long patEventCd,
      @AuthenticationPrincipal NtssUser ntssUser) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_EVENT + "/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId, startDate, endDate, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end

    List<PatEventShare> res = new ArrayList<PatEventShare>();
    Timestamp dateFrom =  toTimestampStart(startDate, Timestamp.valueOf("1970-01-01 00:00:00"));
    Timestamp dateTo = toTimestampEnd(endDate, Timestamp.valueOf("9999-01-01 00:00:00"));
    String facilityCd = ntssUser.getFacilityCd();
    List<Long> patEventCdArrayList = new ArrayList<Long>();
    if (patEventCd != null) {
      patEventCdArrayList.add(patEventCd);
    }
    Long[] patEventCdList = new Long[patEventCdArrayList.size()];
    patEventCdArrayList.toArray(patEventCdList);
    if (patId != null && StrUtils.isNumber(patId)) {
      //患者ID、起票日時で検索
      res = patEventRecService.selectByPatIdNewestShare(
        Long.parseLong(patId), dateFrom, dateTo, facilityCd, patEventCdList);
    } else {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId, startDate, endDate, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId, startDate, endDate, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(res, HttpStatus.OK);
  }
  /*mod FNSI-改修内容患者イベント患者情報共有より改修 任 end*/

  /**
   * データ取得
   * @param patEventCd
   * @return
   */
  @GetMapping("/{patEventCd}")
  public ResponseEntity<?> getPatEventRec(
      @PathVariable(name = "patEventCd", required = true) String patEventCd) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_EVENT + "/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patEventCd));
    // add FNSi5712アプリケーションログが出力しない 周 end
    List<PatEvent> res = new ArrayList<PatEvent>();
    if (patEventCd != null && StrUtils.isNumber(patEventCd)) {
      //患者ID、起票日時で検索
      res = patEventRecService.selectByCd(Long.parseLong(patEventCd));
    } else {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patEventCd));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patEventCd));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(res, HttpStatus.OK);
  }

  // add FNSI-観察記録を追加 楊 start
  /**
   * 患者経過総合ビューア取得用、観察記録データ取得
   * @param pat_id 患者ID
   * @param date_from 表示開始日(YYYYMMDD)
   * @param date_to 表示終了日(YYYYMMDD)
   * @return 観察記録データ
   * @throws Exception Exception
   */
  @PostMapping("/PatEventList/{pat_id}/{date_from}/{date_to}")
  public ResponseEntity<List<PatEvent>> getPatEventData(
    @PathVariable long pat_id,
    @PathVariable String date_from,
    @PathVariable String date_to
  ) throws Exception {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_EVENT + "/PatEventList";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id, date_from, date_to));
    // add FNSi5712アプリケーションログが出力しない 周 end
    List<PatEvent> res = new ArrayList<PatEvent>();
    String dateFrom = ((null != date_from) && (false == "".equals(date_from))) ? date_from.replaceAll("-", "") : null;
    String dateTo = ((null != date_to) && (false == "".equals(date_to))) ? date_to.replaceAll("-", "") : null;
    res = patEventRecService.FindPatEventByDateCd(pat_id, dateFrom, dateTo);
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id, date_from, date_to));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(res, HttpStatus.OK);
  }
  // add FNSI-観察記録を追加 楊 end

  // add FNSI-患者イベント（仮）を追加 李 start
  /**
   * 患者経過総合ビューア取得用、患者イベント（仮）データ取得
   * @param pat_id 患者ID
   * @param date_from 表示開始日(YYYYMMDD)
   * @param date_to 表示終了日(YYYYMMDD)
   * @return 患者イベント（仮）データ
   * @throws Exception Exception
   */
  @PostMapping("/PatientList/{pat_id}/{date_from}/{date_to}")
  public ResponseEntity<List<PatEvent>> getPatientData(
    @PathVariable long pat_id,
    @PathVariable String date_from,
    @PathVariable String date_to,
    @AuthenticationPrincipal NtssUser ntssUser
  ) throws Exception {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_EVENT + "/PatientList";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id, date_from, date_to, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    List<PatEvent> res = new ArrayList<PatEvent>();
    String dateFrom = ((null != date_from) && (false == "".equals(date_from))) ? date_from.replaceAll("-", "") : null;
    String dateTo = ((null != date_to) && (false == "".equals(date_to))) ? date_to.replaceAll("-", "") : null;
    res = patEventRecService.FindPatientByDateCd(pat_id, dateFrom, dateTo, ntssUser.getFacilityCd());
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id, date_from, date_to, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(res, HttpStatus.OK);
  }
  // add FNSI-患者イベント（仮）を追加 李 end
  //7342 add 紹介状のイベント日付が登録日になる 張 start
  /**
   * 患者経過総合ビューア取得用、患者イベント（仮）データ取得
   * @param pat_id 患者ID
   * @param date_from 表示開始日(YYYYMMDD)
   * @param date_to 表示終了日(YYYYMMDD)
   * @return 紹介状
   * @throws Exception Exception
   */
  @PostMapping("/selectByLetterDate/{pat_id}/{date_from}/{date_to}")
  public ResponseEntity<List<PatEvent>> selectByLetterDate(
    @PathVariable long pat_id,
    @PathVariable String date_from,
    @PathVariable String date_to,
    @AuthenticationPrincipal NtssUser ntssUser
  ) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_EVENT + "/selectByLetterDate";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id, date_from, date_to, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    List<PatEvent> res = new ArrayList<PatEvent>();
    String dateFrom = ((null != date_from) && (false == "".equals(date_from))) ? date_from.replaceAll("-", "") : null;
    String dateTo = ((null != date_to) && (false == "".equals(date_to))) ? date_to.replaceAll("-", "") : null;
    res = patEventRecService.selectByLetterDate(pat_id, dateFrom, dateTo, ntssUser.getFacilityCd());
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(pat_id, date_from, date_to, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(res, HttpStatus.OK);
  }
  //7342 add 紹介状のイベント日付が登録日になる 張 start

  /**
   * 日付をTimestampへ変換(yyyyMMddからTimestampへ)
   * @param dt  日付文字列(yyyyMMdd)
   * @param def デフォルト
   * @return
   */
  private Timestamp toTimestampStart(String dt, Timestamp def) {
    if (dt != null && dt.length() == 8 && StrUtils.isNumber(dt)) {
      return Timestamp.valueOf(dt.substring(0, 4) + "-" +
          dt.substring(4, 6) + "-" +
          dt.substring(6, 8) + " " +
          "00:00:00");
    } else {
      return def;
    }
  };

  /**
   * 日付をTimestampへ変換(yyyyMMddからTimestampへ)
   * @param dt  日付文字列(yyyyMMdd)
   * @param def デフォルト
   * @return
   */
  private Timestamp toTimestampEnd(String dt, Timestamp def) {
    if (dt != null && dt.length() == 8 && StrUtils.isNumber(dt)) {
      return Timestamp.valueOf(dt.substring(0, 4) + "-" +
          dt.substring(4, 6) + "-" +
          dt.substring(6, 8) + " " +
          "23:59:59");
    } else {
      return def;
    }
  };

  /**
   * 新規登録
   * @param patEvent
   * @return
   * @throws URISyntaxException
   * @throws ParseException
   */
  @PostMapping({ "/create" })
  /*mod FNSI-改修内容一括で複数イベントを登録された時、一括登録された２番目からのデータが削除できない。任 start*/
  /*public ResponseEntity<Long> createPatEventRec(*/
  public ResponseEntity<List<PatEvent>> createPatEventRec(
    /*mod FNSI-改修内容一括で複数イベントを登録された時、一括登録された２番目からのデータが削除できない。任 end*/
      @AuthenticationPrincipal NtssUser ntssUser,
      @RequestBody PatEventRequest request) throws ParseException {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_EVENT + "/create";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser, request));
    // add FNSi5712アプリケーションログが出力しない 周 end
    // delete by YangYongzhuang  2023-02-01 [CodeOptimization]  start /
//    List<PatEvent> datas = new ArrayList<PatEvent>();
//    String startDateTime = "";
//    String endDateTime = "";
//    int mode = 0;
//    int interval = 0;
//    String[] intervalClass = null;
//    int dateClass = 0;
//    int weekNo = 0;
//    int dayOfWeekNo = 0;
//    Calendar calendarFrom = Calendar.getInstance();
//    Calendar calendarTo = Calendar.getInstance();
//    String startTime = request.getStartTime();
//    String formatStartTime = StringUtils.isEmpty(startTime) ? null : startTime.replace(":", "");
//    String endTime = request.getEndTime();
//    String formatEndTime = StringUtils.isEmpty(endTime) ? null : endTime.replace(":", "");
//    if (request.getMode() != null) {
//      mode = Integer.parseInt(request.getMode());
//    }
//    if (request.getStartDate() != null) {
//      SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");
//      Date date = df.parse(request.getStartDate());
//      startDateTime = new SimpleDateFormat("yyyyMMddHHmmss").format(date);
//      int sYear = Integer.parseInt(startDateTime.substring(0, 4));
//      int sMonth = Integer.parseInt(startDateTime.substring(4, 6)) - 1;
//      int sDays = Integer.parseInt(startDateTime.substring(6, 8));
//      int sHour = Integer.parseInt("00");
//      int sMinute = Integer.parseInt("00");
//      int sSecond = Integer.parseInt("00");
//      calendarFrom.set(sYear, sMonth, sDays, sHour, sMinute, sSecond);
//    }
//    if (request.getEndDate() != null) {
//      SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");
//      Date date = df.parse(request.getEndDate());
//      endDateTime = new SimpleDateFormat("yyyyMMddHHmmss").format(date);
//      int eYear = Integer.parseInt(endDateTime.substring(0, 4));
//      int eMonth = Integer.parseInt(endDateTime.substring(4, 6)) - 1;
//      int eDays = Integer.parseInt(endDateTime.substring(6, 8));
//      int eHour = Integer.parseInt("23");
//      int eMinute = Integer.parseInt("59");
//      int eSecond = Integer.parseInt("59");
//      calendarTo.set(eYear, eMonth, eDays, eHour, eMinute, eSecond);
//    }
//    if (request.getInterval() != null) {
//      if (mode == 2 || mode == 3) {
//        interval = Integer.parseInt(request.getInterval()) + 1;
//      } else {
//        if (mode == 5) {
//          weekNo = Integer.parseInt(request.getInterval().substring(0, 1)) + 1;
//          dayOfWeekNo = Integer.parseInt(request.getInterval().substring(2, 3)) + 1;
//        } else {
//          interval = Integer.parseInt(request.getInterval());
//        }
//      }
//    }
//    if (request.getIntervalClass() != null) {
//      intervalClass = request.getIntervalClass();
//    }
//    if (request.getDateClass() != null) {
//      dateClass = Integer.parseInt(request.getDateClass());
//    }
//
//    Timestamp rangeStart = new Timestamp(calendarFrom.getTimeInMillis());
//    Timestamp rangeEnd = new Timestamp(calendarTo.getTimeInMillis());
//
//    String eventStartDate = null;
//    String eventEndDate = null;
//    boolean secondTime = false;
    // delete by YangYongzhuang  2023-02-01 [CodeOptimization]  End /
    try {

      /*add FNSI-改修内容redmine4763 任 start*/
     /* int k = 1;*/
      /*add FNSI-改修内容redmine4763 任 end*/
      // delete by YangYongzhuang  2023-02-01 [CodeOptimization]  start /
//      switch (mode) {
//      case 1:
//        PatEvent patEventRec = new PatEvent();
//        patEventRec = request.getPatEventParam();
//        eventStartDate = generateEventDate(calendarFrom, startTime, 0);
//        eventEndDate = generateEventDate(calendarFrom, endTime, dateClass);
//        patEventRec.setEventStartDate(eventStartDate);
//        patEventRec.setEventEndDate(eventEndDate);
//        patEventRec.setEventStartTime(formatStartTime);
//        patEventRec.setEventEndTime(formatEndTime);
//        patEventRec.setEventStatus("1");
//        datas.add(patEventRec);
//        break;
//      case 2:
//        while (calendarFrom.before(calendarTo) || calendarFrom.equals(calendarTo)) {
//          PatEvent rec = this.copyPatEventRec(request.getPatEventParam());
//          /*add FNSI-改修内容redmine4763 任 start*/
//          /*String inputParam = rec.getInputParams();
//          JSONArray jsonArray = new JSONArray(inputParam);
//          for(int i = 0;i < jsonArray.length();i++){
//            String isRstCopy = (String)((JSONObject)jsonArray.get(i)).get("is_rst_copy");
//            if("0".equals(isRstCopy) && k != 1){
//              jsonArray.remove(i);
//              i = i - 1;
//            }
//          }
//          rec.setInputParams(jsonArray.toString());*/
//          /*add FNSI-改修内容redmine4763 任 end*/
//          eventStartDate = generateEventDate(calendarFrom, startTime, 0);
//          eventEndDate = generateEventDate(calendarFrom, endTime, dateClass);
//          if (secondTime) {
//            rec.setResultParams(jsonGenerate(rec.getInputParams(), rec.getResultParams()).toString());
//            rec.setScoreTotal(0);
//            rec.setOrdNo(null);
//            rec.setEventStatus("0");
//          } else {
//            rec.setEventStatus("1");
//          }
//          rec.setEventStartDate(eventStartDate);
//          rec.setEventEndDate(eventEndDate);
//          rec.setEventStartTime(formatStartTime);
//          rec.setEventEndTime(formatEndTime);
//          datas.add(rec);
//          secondTime = true;
//          calendarFrom.add(Calendar.DAY_OF_MONTH, interval);
//          /*add FNSI-改修内容redmine4763 任 start*/
//         /* k++;*/
//          /*add FNSI-改修内容redmine4763 任 end*/
//        }
//        break;
//      case 3:
//        while (calendarFrom.before(calendarTo) || calendarFrom.equals(calendarTo)) {
//          Calendar cal = (Calendar) calendarFrom.clone();
//          cal.add(Calendar.DAY_OF_WEEK,
//              cal.getFirstDayOfWeek() - cal.get(Calendar.DAY_OF_WEEK));
//          for (int i = 0; i < 7; i++) {
//            int week = cal.get(Calendar.DAY_OF_WEEK) - 1;
//            if (intervalClass[week].endsWith("1")) {
//              Timestamp eventDate = new Timestamp(cal.getTimeInMillis());
//              eventStartDate = generateEventDate(cal, startTime, 0);
//              eventEndDate = generateEventDate(cal, endTime, dateClass);
//              int diff1 = rangeStart.compareTo(eventDate);
//              int diff2 = rangeEnd.compareTo(eventDate);
//
//              if (diff1 <= 0 && diff2 >= 0) {
//                PatEvent rec = this.copyPatEventRec(request.getPatEventParam());
//                /*add FNSI-改修内容redmine4763 任 start*/
//               /* String inputParam = rec.getInputParams();
//                JSONArray jsonArray = new JSONArray(inputParam);
//                for(int j = 0;j < jsonArray.length();j++){
//                  String isRstCopy = (String)((JSONObject)jsonArray.get(j)).get("is_rst_copy");
//                  if("0".equals(isRstCopy) && k != 1){
//                    jsonArray.remove(j);
//                    j = j - 1;
//                  }
//                }
//                rec.setInputParams(jsonArray.toString());*/
//                /*add FNSI-改修内容redmine4763 任 end*/
//                if (secondTime) {
//                  rec.setResultParams(jsonGenerate(rec.getInputParams(), rec.getResultParams()).toString());
//                  rec.setScoreTotal(0);
//                  rec.setOrdNo(null);
//                  rec.setEventStatus("0");
//                } else {
//                  rec.setEventStatus("1");
//                }
//                rec.setEventStartDate(eventStartDate);
//                rec.setEventEndDate(eventEndDate);
//                rec.setEventStartTime(formatStartTime);
//                rec.setEventEndTime(formatEndTime);
//                datas.add(rec);
//                secondTime = true;
//              }
//            }
//            cal.add(Calendar.DAY_OF_MONTH, 1);
//          }
//          calendarFrom.add(Calendar.WEEK_OF_MONTH, interval);
//          /*add FNSI-改修内容redmine4763 任 start*/
//         /* k++;*/
//          /*add FNSI-改修内容redmine4763 任 end*/
//        }
//        break;
//      case 4:
//        Calendar ccalFrom = (Calendar) calendarFrom.clone();
//        while (calendarFrom.before(calendarTo) || calendarFrom.equals(calendarTo)) {
//          Calendar cal = (Calendar) calendarFrom.clone();
//          cal.set(Calendar.DATE, interval);
//          int month = cal.get(Calendar.MONTH);
//          if (intervalClass[month].endsWith("1")) {
//            if (cal.after(ccalFrom) && cal.before(calendarTo)) {
//              PatEvent rec = this.copyPatEventRec(request.getPatEventParam());
//              /*add FNSI-改修内容redmine4763 任 start*/
//              /*String inputParam = rec.getInputParams();
//              JSONArray jsonArray = new JSONArray(inputParam);
//              for(int i = 0;i < jsonArray.length();i++){
//                String isRstCopy = (String)((JSONObject)jsonArray.get(i)).get("is_rst_copy");
//                if("0".equals(isRstCopy) && k != 1){
//                  jsonArray.remove(i);
//                  i = i - 1;
//                }
//              }
//              rec.setInputParams(jsonArray.toString());*/
//              /*add FNSI-改修内容redmine4763 任 end*/
//              if (secondTime) {
//                rec.setResultParams(jsonGenerate(rec.getInputParams(), rec.getResultParams()).toString());
//                rec.setScoreTotal(0);
//                rec.setOrdNo(null);
//                rec.setEventStatus("0");
//              } else {
//                rec.setEventStatus("1");
//              }
//              eventStartDate = generateEventDate(cal, startTime, 0);
//              eventEndDate = generateEventDate(cal, endTime, dateClass);
//              rec.setEventStartDate(eventStartDate);
//              rec.setEventEndDate(eventEndDate);
//              rec.setEventStartTime(formatStartTime);
//              rec.setEventEndTime(formatEndTime);
//              datas.add(rec);
//              secondTime = true;
//            }
//          }
//          calendarFrom.add(Calendar.MONTH, 1);
//          /*add FNSI-改修内容redmine4763 任 start*/
//         /* k++;*/
//          /*add FNSI-改修内容redmine4763 任 end*/
//        }
//        break;
//      case 5:
//        Calendar calFrom = (Calendar) calendarFrom.clone();
//        while (calendarFrom.before(calendarTo) || calendarFrom.equals(calendarTo)) {
//          Calendar cal = (Calendar) calendarFrom.clone();
//
//          int month = cal.get(Calendar.MONTH);
//          if (intervalClass[month].endsWith("1")) {
//            //第何週の曜日より日付を算出
//            SimpleDateFormat format = new SimpleDateFormat("yyyy/MM/dd");
//            Calendar calInfo = Calendar.getInstance();
//            calInfo.set(cal.get(Calendar.YEAR), cal.get(Calendar.MONTH), 1);
//            calInfo.set(Calendar.DAY_OF_WEEK_IN_MONTH, weekNo);
//            calInfo.set(Calendar.DAY_OF_WEEK, dayOfWeekNo);
//            System.out.println(format.format(calInfo.getTime())); // => 2015/01/19
//            //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
//            EventLogMessage eventLogMessage = new EventLogMessage();
//            eventLogMessage.setLogMessage(format.format(calInfo.getTime()));
//            logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_EVENT, SERVICE_NAME.FNSI, null);
//            //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
//
//            if (calInfo.after(calFrom) && calInfo.before(calendarTo)) {
//              PatEvent rec = this.copyPatEventRec(request.getPatEventParam());
//              /*add FNSI-改修内容redmine4763 任 start*/
//              /*String inputParam = rec.getInputParams();
//              JSONArray jsonArray = new JSONArray(inputParam);
//              for(int i = 0;i < jsonArray.length();i++){
//                String isRstCopy = (String)((JSONObject)jsonArray.get(i)).get("is_rst_copy");
//                if("0".equals(isRstCopy) && k != 1){
//                  jsonArray.remove(i);
//                  i = i - 1;
//                }
//              }
//              rec.setInputParams(jsonArray.toString());*/
//              /*add FNSI-改修内容redmine4763 任 end*/
//              if (secondTime) {
//                rec.setResultParams(jsonGenerate(rec.getInputParams(), rec.getResultParams()).toString());
//                rec.setScoreTotal(0);
//                rec.setOrdNo(null);
//                rec.setEventStatus("0");
//              } else {
//                rec.setEventStatus("1");
//              }
//              eventStartDate = generateEventDate(calInfo, startTime, 0);
//              eventEndDate = generateEventDate(calInfo, endTime, dateClass);
//              rec.setEventStartDate(eventStartDate);
//              rec.setEventEndDate(eventEndDate);
//              rec.setEventStartTime(formatStartTime);
//              rec.setEventEndTime(formatEndTime);
//              datas.add(rec);
//              secondTime = true;
//            }
//          }
//          calendarFrom.add(Calendar.MONTH, 1);
//          /*add FNSI-改修内容redmine4763 任 start*/
//         /* k++;*/
//          /*add FNSI-改修内容redmine4763 任 end*/
//        }
//        break;
//      default:
//        // 式の値がどのcaseの値とも一致しなかったときの処理
//      }
      // delete by YangYongzhuang  2023-02-01 [CodeOptimization]  End /
      // add by YangYongzhuang  2023-02-03 [CodeOptimization]  start /
      List<PatEvent> patEventList = patEventRecService.create(request);
      // add by YangYongzhuang  2023-02-03 [CodeOptimization]  start /
      if (patEventList.isEmpty()) {
        /*mod FNSI-改修内容一括で複数イベントを登録された時、一括登録された２番目からのデータが削除できない。任 start*/
        /*return new ResponseEntity<>(0L, HttpStatus.OK);
      } else {
        PatEvent rec = patEventList.get(0);
        return new ResponseEntity<>(rec.getPatEventCd(), HttpStatus.OK);*/
        PatEvent rec = new PatEvent();
        rec.setPatEventCd(0L);
        patEventList.add(rec);
        // add FNSi5712アプリケーションログが出力しない 周 start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
          AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser, request));
        // add FNSi5712アプリケーションログが出力しない 周 end
        return new ResponseEntity<>(patEventList, HttpStatus.OK);
      } else {
        // add FNSi5712アプリケーションログが出力しない 周 start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
          AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser, request));
        // add FNSi5712アプリケーションログが出力しない 周 end
        return new ResponseEntity<>(patEventList, HttpStatus.OK);
        /*mod FNSI-改修内容一括で複数イベントを登録された時、一括登録された２番目からのデータが削除できない。任 end*/
      }
    } catch (DuplicateKeyException e) {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser, request));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
// delete by YangYongzhuang  2023-02-01 [CodeOptimization]  start /
//  private String generateEventDate(Calendar calendar, String time, Integer dateClass) {
//    Calendar calendarEventDate = (Calendar) calendar.clone();
//    int sHour = StringUtils.isEmpty(time) ? 0 : Integer.parseInt(time.substring(0, 2));
//    int sMinute = StringUtils.isEmpty(time) ? 0 : Integer.parseInt(time.substring(3, 5));
//    calendarEventDate.set(calendar.get(Calendar.YEAR), calendar.get(Calendar.MONTH),
//    calendar.get(Calendar.DATE), sHour, sMinute, 0);
//    calendarEventDate.add(Calendar.DATE, dateClass);
//    Date date = calendarEventDate.getTime();
//    SimpleDateFormat format = new SimpleDateFormat("yyyyMMdd");
//    String dateStr = format.format(date);
//    return dateStr;
//  }
//
//  private JSONArray jsonGenerate(String inputParams, String resultParams) {
//    List<Integer> formatClassList = new ArrayList<Integer>();
//    List<String> isRstCopyList = new ArrayList<String>();
//
//    JSONArray resultJsonArray = new JSONArray(resultParams);
//    JSONArray inputJsonArray = new JSONArray(inputParams);
//    for (int i = 0; i < inputJsonArray.length(); i++) {
//      JSONObject jsonObject = inputJsonArray.getJSONObject(i);
//      formatClassList.add((Integer) jsonObject.get("format_class"));
//      isRstCopyList.add(jsonObject.has("is_rst_copy") ? jsonObject.get("is_rst_copy").toString() : "0");
//    }
//    JSONArray jsonArr = new JSONArray();
//    int idx = 0;
//    for (Iterator<Integer> it = formatClassList.iterator(); it.hasNext();) {
//      int classNum = it.next();
//      JSONObject json = new JSONObject();
//      switch (classNum) {
//      case PatEventUtils.PAT_EVENT_TEXT:
//      case PatEventUtils.PAT_EVENT_TEXT_AREA:
//      case PatEventUtils.PAT_EVENT_DATE:
//      case PatEventUtils.PAT_EVENT_CALC_SOCORE:
//      case PatEventUtils.PAT_EVENT_ORDER_LINK:
//        if (isRstCopyList.get(idx).equals("1")) {
//          json = resultJsonArray.getJSONObject(idx);
//        } else {
//          json.put("format_class", classNum);
//          json.put("result_value", "");
//        }
//        break;
//      case PatEventUtils.PAT_EVENT_FILE:
//      case PatEventUtils.PAT_EVENT_IMAGE:
//      case PatEventUtils.PAT_EVENT_LIST:
//      case PatEventUtils.PAT_EVENT_RADIO:
//      case PatEventUtils.PAT_EVENT_CHECK:
//        if (isRstCopyList.get(idx).equals("1")) {
//          json = resultJsonArray.getJSONObject(idx);
//        } else {
//          json.put("format_class", classNum);
//          json.put("result_value", new JSONArray());
//        }
//        break;
//      }
//      jsonArr.put(json);
//      idx++;
//    }
//    return jsonArr;
//  }
//
//  private PatEvent copyPatEventRec(PatEvent bRec) {
//    PatEvent rec = new PatEvent();
//    rec.setPatId(bRec.getPatId());
//    rec.setFacilityCd(bRec.getFacilityCd());
//    rec.setFnCtlNo(bRec.getFnCtlNo());
//    rec.setEventStatus(bRec.getEventStatus());
//    rec.setTemplateCd(bRec.getTemplateCd());
//    rec.setTemplateName(bRec.getTemplateName());
//    rec.setCategoryCd(bRec.getCategoryCd());
//    rec.setCategoryName(bRec.getCategoryName());
//    rec.setUseType(bRec.getUseType());
//    rec.setOrdNo(bRec.getOrdNo());
//    rec.setInputParams(bRec.getInputParams());
//    rec.setSubCategoryCd(bRec.getSubCategoryCd());
//    rec.setSubCategoryName(bRec.getSubCategoryName());
//    rec.setResultParams(bRec.getResultParams());
//    rec.setScoreTotal(bRec.getScoreTotal());
//    rec.setRegStaffInfo(bRec.getRegStaffInfo());
//    rec.setUpStaffInfo(bRec.getUpStaffInfo());
//    rec.setBbsCtlNo(bRec.getBbsCtlNo());
//    rec.setIsNewest(bRec.getIsNewest());
//    rec.setIsDel(bRec.getIsDel());
//    /*add FNSI-改修内容転入転出の患者情報連動 任 start*/
//    rec.setReportUrl(bRec.getReportUrl());
//    rec.setReportDate(bRec.getReportDate());
//    /*add FNSI-改修内容転入転出の患者情報連動 任 end*/
//    return rec;
//  }
  // delete by YangYongzhuang  2023-02-01 [CodeOptimization]  End /

  /**
   * 更新
   * @param patEvent
   * @return
   */
  @PutMapping("/update")
  public ResponseEntity<Void> updatePatEventRec(
      @RequestBody PatEventRequest request) {

    PatEvent patObsRec = request.getPatEventParam();
    Boolean isNotification = request.getIsNotification();

    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_EVENT + "/update";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patObsRec));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      /*add FNSI-改修内容転入転出の患者情報連動 任 start*/
      if(patObsRec.getEventStartDate()!=null&&patObsRec.getEventEndDate()!=null){
        /*add FNSI-改修内容転入転出の患者情報連動 任 end*/
        patObsRec.setEventStartDate(patObsRec.getEventStartDate().replace("-", ""));
        patObsRec.setEventEndDate(patObsRec.getEventEndDate().replace("-", ""));
        /*add FNSI-改修内容転入転出の患者情報連動 任 start*/
      }
      /*add FNSI-改修内容転入転出の患者情報連動 任 end*/
      if (!StringUtils.isEmpty(patObsRec.getEventStartTime())) {
        patObsRec.setEventStartTime(patObsRec.getEventStartTime().replace(":", ""));
      }
      if (!StringUtils.isEmpty(patObsRec.getEventEndTime())) {
        patObsRec.setEventEndTime(patObsRec.getEventEndTime().replace(":", ""));
      }
      /*add FNSI-改修内容転入転出の患者情報連動 任 start*/
      if(patObsRec.getFacilityCd()==null){
        patEventRecService.updateLetterInfo(patObsRec);
      }else{
        /*add FNSI-改修内容転入転出の患者情報連動 任 end*/
        patEventRecService.update(patObsRec, isNotification);
        /*add FNSI-改修内容転入転出の患者情報連動 任 start*/
      }
      /*add FNSI-改修内容転入転出の患者情報連動 任 end*/
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patObsRec));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (DuplicateKeyException e) {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patObsRec));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 実績更新
   * @param patEvent
   * @return
   */
  @PutMapping("/updateResultParams")
  public ResponseEntity<Void> updatePatEventResultParams(
      @RequestBody PatEvent patObsRec) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_EVENT + "/updateResultParams";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patObsRec));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      patEventRecService.updateResultParams(patObsRec);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patObsRec));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (DuplicateKeyException e) {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patObsRec));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 実績更新
   * @param patEvent
   * @return
   */
  @PutMapping("/updateBbsCtlNo")
  public ResponseEntity<Void> updatPatEventeBbsCtlNo(
      @RequestBody PatEvent patObsRec) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_EVENT + "/updateBbsCtlNo";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patObsRec));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      patEventRecService.updateBbsCtlNo(patObsRec);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patObsRec));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (DuplicateKeyException e) {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patObsRec));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 削除
   */
  @PostMapping("/delete/{patEventCd}")
  public ResponseEntity<Void> deletePatEventRec(
      @PathVariable(name = "patEventCd", required = true) String patEventCd) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_EVENT + "/delete/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patEventCd));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      patEventRecService.delete(Long.parseLong(patEventCd));
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patEventCd));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patEventCd));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  @GetMapping("/collect-master")
  public ResponseEntity<?> patEventMasterData(
      @AuthenticationPrincipal NtssUser ntssUser) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_EVENT + "/collect-master";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get trendGraphMasterData : "+ ntssUser.getFacilityCd());
    logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_EVENT, SERVICE_NAME.FNSI, null);

    PatEventMasterResponse response = new PatEventMasterResponse();
    try {
      // レスポンス生成
      response = patEventRecService.findPatEventMaster(ntssUser.getFacilityCd());

      response.isSuccess = true;
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      eventLogMessage.setLogMessage("REST request error by get trendGraphMasterData : "+ e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_EVENT, SERVICE_NAME.FNSI, null);
      response.errorMessage = e.getMessage();
      response.isSuccess = false;
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
    }
  }

  @GetMapping("/mst-category-list")
  public ResponseEntity<?> getMstCategoryList(
      @AuthenticationPrincipal NtssUser ntssUser) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_EVENT + "/mst-category-list";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    List<MstPatEventCategory> response = new ArrayList<MstPatEventCategory>();
    try {
      // レスポンス生成
      response = patEventRecService.selectPatEventCategory(ntssUser.getFacilityCd());
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * データ取得
   * @param patId
   * @param startDate
   * @param endDate
   * @return
   */
  @GetMapping("/ordno/{ordNo}")
  public ResponseEntity<?> getPatEventRecByOrdNo(
      @PathVariable(name = "ordNo", required = true) String ordNo) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_EVENT + "/ordno/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ordNo));
    // add FNSi5712アプリケーションログが出力しない 周 end
    List<PatEvent> res = new ArrayList<PatEvent>();
    if (ordNo != null && StrUtils.isNumber(ordNo)) {
      /* mod #8620 by zhangruixue 2023-05-08 --start */
      NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
      //患者ID、起票日時で検索
      res = patEventRecService.selectByOrdNo(Long.parseLong(ordNo),user.getFacilityCd());
      /* mod #8620 by zhangruixue 2023-05-08 --end */
    } else {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ordNo));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ordNo));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(res, HttpStatus.OK);
  }

  /**
   * ファイルダウンロード
   * @param filename
   * @return 16進数文字列
   */
  @GetMapping("/files")
  public ResponseEntity<?> downloadFile(
      @RequestParam("filepath") String filepath,
      @AuthenticationPrincipal NtssUser ntssUser) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_EVENT + "/files";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(filepath, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      String encodedFiles = patEventRecService.downloadEventFileAttachment(filepath, ntssUser.getFacilityCd());
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(filepath, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(encodedFiles, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_EVENT, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(filepath, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * ファイルアップロード
   * @param file
   */
  @PostMapping("/files/{patEvent}")
  public ResponseEntity<Void> uploadFile(
      @RequestParam("files") MultipartFile file,
      @PathVariable("patEvent") String patEvent) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_EVENT + "/files/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(file, patEvent));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      patEventRecService.uploadEventFileAttachment(file, patEvent);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(file, patEvent));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_EVENT, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(file, patEvent));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);

    }
  }

  /**
   * ファイル削除
   * @param filename
   */
  @PostMapping("/deleteEventFileAttachment/{patId}")
  public ResponseEntity<?> deleteFile(
      @PathVariable("patId") long patId,
      @RequestBody List<Map<String, String>> fileInfo,
      @AuthenticationPrincipal NtssUser ntssUser) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_EVENT + "/deleteEventFileAttachment/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId, fileInfo, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      patEventRecService.deleteEventFileAttachment(fileInfo, patId, ntssUser.getFacilityCd());
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId, fileInfo, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_EVENT, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId, fileInfo, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * イメージファイルダウンロード
   * @param filename
   * @return 16進数文字列
   */
  @GetMapping("/images")
  public ResponseEntity<?> downloadImage(
      @RequestParam("filepath") String filepath,
      @AuthenticationPrincipal NtssUser ntssUser) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_EVENT + "/images";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(filepath, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      String encodedFiles = patEventRecService.downloadEventImageAttachment(filepath, null, ntssUser.getFacilityCd());
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(filepath, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(encodedFiles, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_EVENT, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(filepath, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * イメージファイルアップロード
   * @param file
   */
  @PostMapping("/images/{patEvent}")
  public ResponseEntity<Void> uploadImage(
      @RequestParam("files") MultipartFile file,
      @PathVariable("patEvent") String patEvent) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_EVENT + "/images/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(file, patEvent));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      patEventRecService.uploadEventImageAttachment(file, patEvent);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(file, patEvent));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_EVENT, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(file, patEvent));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);

    }
  }

  /**
   * イメージファイル削除
   * @param filename
   */
  @PostMapping("/deleteEventImageAttachment/{patId}")
  public ResponseEntity<?> deleteImage(
      @PathVariable("patId") long patId,
      @RequestBody List<Map<String, String>> fileInfo,
      @AuthenticationPrincipal NtssUser ntssUser) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_EVENT + "/deleteEventImageAttachment/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId, fileInfo, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      patEventRecService.deleteEventImageAttachment(fileInfo, patId, ntssUser.getFacilityCd());
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId, fileInfo, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_EVENT, SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId, fileInfo, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * コンボボックス用治療情報データ取得
   * @param patId
   * @param treatDate
   * @param dialysisState
   * @return
   */
  @GetMapping("/ord_main_combo/{patId}/{treatStartDate}/{treatEndDate}/{getClass}")
  public ResponseEntity<?> getOrdMainPatEventRecCombo(
      @PathVariable(name = "patId", required = true) String patId,
      @PathVariable(name = "treatStartDate", required = true) String treatStartDate,
      @PathVariable(name = "treatEndDate", required = true) String treatEndDate,
      @PathVariable(name = "getClass", required = true) String getClass,
      @AuthenticationPrincipal NtssUser ntssUser) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_EVENT + "/ord_main_combo/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId, treatStartDate, treatEndDate, getClass, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    List<OrdMainPatEventRecCombo> res;
    try {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST コンボボックス用治療情報データ取得 getOrdMainPatObsRecCombo : [" + patId + "][" + treatStartDate + "][" + treatEndDate + "]");
      logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      res = new ArrayList<OrdMainPatEventRecCombo>();
      if (getClass.equals("1")) {
        //未治療
       res = patEventRecService.selectPatEventRecCombo(ntssUser.getFacilityCd(), Long.parseLong(patId),
          toTimestampStart(treatStartDate, Timestamp.valueOf("1970-01-01 00:00:00")),
          toTimestampEnd(treatEndDate, Timestamp.valueOf("9999-01-01 00:00:00")), 1);
      } else if (getClass.equals("2")) {
        //治療開始
        res = patEventRecService.selectPatEventRecCombo(ntssUser.getFacilityCd(), Long.parseLong(patId),
          toTimestampStart(treatStartDate, Timestamp.valueOf("1970-01-01 00:00:00")), null, 3);
      } else {
        //治療終了
        res = patEventRecService.selectPatEventRecCombo(ntssUser.getFacilityCd(), Long.parseLong(patId),
          toTimestampStart(treatStartDate, Timestamp.valueOf("1970-01-01 00:00:00")),
          toTimestampEnd(treatEndDate, Timestamp.valueOf("9999-01-01 00:00:00")), 2);
      }
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST コンボボックス用治療情報データ取得 error getOrdMainPatObsRecCombot : " + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId, treatStartDate, treatEndDate, getClass, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
    }
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId, treatStartDate, treatEndDate, getClass, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(res, HttpStatus.OK);
  }

  /**
   * sys_data_set実行結果取得
   * @param ntssUser
   * @param sqlCd
   * @param patId
   * @param ordNo
   * @param fromDate
   * @param toDate
   * @return
   */
  @GetMapping("/dataset-result")
  public ResponseEntity<?> getSysDataSetResult(
      @AuthenticationPrincipal NtssUser ntssUser,
      @RequestParam(name = "cd", required = false) Long sqlCd,
      @RequestParam(name = "pat", required = false) Long patId,
      @RequestParam(name = "ord", required = false) Long ordNo,
      @RequestParam(name = "mstName", required = false) String mstName,
      @RequestParam(name = "from", required = false) String fromDate,
      @RequestParam(name = "to", required = false) String toDate) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_EVENT + "/dataset-result";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser, sqlCd, patId, ordNo, mstName, fromDate, toDate));
    // add FNSi5712アプリケーションログが出力しない 周 end
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST SysDataSetデータ取得 getSysDataSetResult : sqlCd[" + sqlCd + "]patId[" + patId + "]ordNo[" + ordNo + "]");
    logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
    // sys_data_setリストのレスポンス生成
    java.util.Map<String, Object> param = new java.util.HashMap<String, Object>();
    param.put("facilityCd", ntssUser.getFacilityCd());
    if (ordNo != null) {
      param.put("ordNo", ordNo);
    }
    if (patId != null) {
      param.put("patId", patId);
    }
    if (mstName != null) {
        param.put("mstName", mstName);
      }
    if (fromDate != null) {
      param.put("fromDate", fromDate);
      param.put("date", fromDate);
    }
    if (toDate != null) {
      param.put("fromDate", toDate);
    }
    try {
      List<Map<String, Object>> res = sysDataSetService.getDataList(sqlCd, param);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser, sqlCd, patId, ordNo, mstName, fromDate, toDate));
      // add FNSi5712アプリケーションログが出力しない 周 end

      // レスポンス作成
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
      eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST SysDataSetデータ取得 error getSysDataSetResult : " + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser, sqlCd, patId, ordNo, mstName, fromDate, toDate));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
    }

  }

  // add マスタ一覧 1･施設切替を可能とする 孔s start
  /**
   * sys_data_set実行結果取得
   * @param facilityCd
   * @param sqlCd
   * @param patId
   * @param ordNo
   * @param fromDate
   * @param toDate
   * @return
   */
  @GetMapping("/dataset-result/{facilityCd}")
  public ResponseEntity<?> getSysDataSetResultByFacilityCd(
    @PathVariable String facilityCd,
    @RequestParam(name = "cd", required = false) Long sqlCd,
    @RequestParam(name = "pat", required = false) Long patId,
    @RequestParam(name = "ord", required = false) Long ordNo,
    @RequestParam(name = "mstName", required = false) String mstName,
    @RequestParam(name = "from", required = false) String fromDate,
    @RequestParam(name = "to", required = false) String toDate) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_EVENT + "/dataset-result/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd, sqlCd, patId, ordNo, mstName, fromDate, toDate));
    // add FNSi5712アプリケーションログが出力しない 周 end
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST SysDataSetデータ取得 getSysDataSetResult : sqlCd[" + sqlCd + "]patId[" + patId + "]ordNo[" + ordNo + "]");
    logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    // sys_data_setリストのレスポンス生成
    java.util.Map<String, Object> param = new java.util.HashMap<String, Object>();
    param.put("facilityCd", facilityCd);
    if (ordNo != null) {
      param.put("ordNo", ordNo);
    }
    if (patId != null) {
      param.put("patId", patId);
    }
    if (mstName != null) {
      param.put("mstName", mstName);
    }
    if (fromDate != null) {
      param.put("fromDate", fromDate);
      param.put("date", fromDate);
    }
    if (toDate != null) {
      param.put("toDate", toDate);
    }
    try {
      List<Map<String, Object>> res = sysDataSetService.getDataList(sqlCd, param);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd, sqlCd, patId, ordNo, mstName, fromDate, toDate));
      // add FNSi5712アプリケーションログが出力しない 周 end

      // レスポンス作成
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
      eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST SysDataSetデータ取得 error getSysDataSetResult : " + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd, sqlCd, patId, ordNo, mstName, fromDate, toDate));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
    }
  }
  // add マスタ一覧 1･施設切替を可能とする 孔s end

  /**
   * sys_data_set実行結果取得
   * @param ntssUser
   * @param sqlCd
   * @param patId
   * @param ordNo
   * @param mstName
   * @param fromDate
   * @param toDate
   * @param days
   * @param ctlNo
   * @param orderClass
   * @param examCd
   * @param examCdBun
   * @param examCdCre
   * @param examCdBunAfter
   * @param examCdCreAfter
   * @return
   */
  @GetMapping("/dataset-statistics")
  public ResponseEntity<?> getSysDataSetResult(
      @AuthenticationPrincipal NtssUser ntssUser,
      @RequestParam(name = "cd", required = false) Long sqlCd,
      @RequestParam(name = "pat", required = false) Long patId,
      @RequestParam(name = "ord", required = false) Long ordNo,
      @RequestParam(name = "mstName", required = false) String mstName,
      @RequestParam(name = "from", required = false) String fromDate,
      @RequestParam(name = "to", required = false) String toDate,
      @RequestParam(name = "days", required = false) Integer days,
      @RequestParam(name = "ctl",required = false) String ctlNo,
      @RequestParam(name = "orderClass",required = false) String orderClass,
      @RequestParam(name = "examCd",required = false) Integer examCd,
      @RequestParam(name = "examCdBun",required = false) Integer examCdBun,
      @RequestParam(name = "examCdCre",required = false) Integer examCdCre,
      @RequestParam(name = "examCdBunAfter",required = false) Integer examCdBunAfter,
      @RequestParam(name = "examCdCreAfter",required = false) Integer examCdCreAfter) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_EVENT + "/dataset-statistics";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser, sqlCd, patId, ordNo, mstName, fromDate, toDate, days,  ctlNo, orderClass, examCd, examCdBun, examCdCre, examCdBunAfter, examCdBunAfter));
    // add FNSi5712アプリケーションログが出力しない 周 end
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST SysDataSetデータ取得 getSysDataSetResult : sqlCd[" + sqlCd + "]patId[" + patId + "]ordNo[" + ordNo + "]");
    logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
    // sys_data_setリストのレスポンス生成
    java.util.Map<String, Object> param = new java.util.HashMap<String, Object>();
    param.put("facilityCd", ntssUser.getFacilityCd());
    if (ordNo != null) {
      param.put("ordNo", ordNo);
    }
    if (patId != null) {
      param.put("patId", patId);
    }
    if (mstName != null) {
        param.put("mstName", mstName);
    }
    if (fromDate != null) { 
        param.put("fromDate", fromDate);
    }
    if (toDate != null) {
      param.put("toDate", toDate);
    }
    if (days != null) {
      param.put("days", days); 
    }
    if (ctlNo != null) {
      param.put("ctlNo", ctlNo);
    }
    if (orderClass != null) {
      param.put("orderClass", orderClass);
    }
    if (examCd != null) {
        param.put("examCd", examCd);
    }
    if (examCdBun != null) {
      param.put("cdBun", examCdBun);
    }
    if (examCdCre != null) {
      param.put("cdCre", examCdCre);
    }
    if (examCdBunAfter != null) {
        param.put("bunAfter", examCdBunAfter);
    }
    if (examCdCreAfter != null) {
      param.put("creAfter", examCdCreAfter);
    }
    try {
      List<Map<String, Object>> res = sysDataSetService.getDataList(sqlCd, param);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser, sqlCd, patId, ordNo, mstName, fromDate, toDate, days, ctlNo, orderClass, examCd, examCdBun, examCdCre, examCdBunAfter, examCdBunAfter));
      // add FNSi5712アプリケーションログが出力しない 周 end

      // レスポンス作成
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
      eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST SysDataSetデータ取得 error getSysDataSetResult : " + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser, sqlCd, patId, ordNo, mstName, fromDate, toDate, days, ctlNo, orderClass, examCd, examCdBun, examCdCre, examCdBunAfter, examCdBunAfter));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
    }

  }

  /**
   * リスト項目用sys_data_setリストの取得
   * @param ntssUser
   * @return
   */
  @GetMapping("/dataset-list")
  public ResponseEntity<?> getSysDataSetForList(
      @AuthenticationPrincipal NtssUser ntssUser) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_EVENT + "/dataset-list";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST リスト項目用SysDataSetデータ取得 getSysDataSetForList");
    logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
    List<SysDataSet> res;
    try {
      res = patEventRecService.getSysDataSet(0);
    } catch (Exception e) {
      eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST リスト項目用SysDataSetデータ取得 getSysDataSetForList error : " + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
    }
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(res, HttpStatus.OK);
  }

  /**
   * テキスト項目用sys_data_setリストの取得
   * @param ntssUser
   * @return
   */
  @GetMapping("/dataset-text")
  public ResponseEntity<?> getSysDataSetForText(
      @AuthenticationPrincipal NtssUser ntssUser) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_EVENT + "/dataset-text";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST テキスト項目用SysDataSetデータ取得 getSysDataSetForText");
    logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
    List<SysDataSet> res;
    try {
      res = patEventRecService.getSysDataSet(1);
    } catch (Exception e) {
      eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST テキスト項目用SysDataSetデータ取得 getSysDataSetForText error : " + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
    }
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(res, HttpStatus.OK);
  }

  /**
   * 選択済み治療情報データ取得
   * @param ordNo
   * @return
   */
  @GetMapping("/ord_main/{patId}/{ordNo}")
  public ResponseEntity<?> getOrdMain(
      @PathVariable(name = "patId", required = true) Long patId,
      @PathVariable(name = "ordNo", required = true) Long ordNo,
      @AuthenticationPrincipal NtssUser ntssUser) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_EVENT + "/ord_main/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId, ordNo, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    OrdMainPatEventRecCombo res;
    try {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST 選択済み治療情報データ取得 getOrdMain: prdNo[" + ordNo + "]");
      logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      res = patEventRecService.selectOrdMain(ordNo, patId);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST 択済み治療情報データ取得 getOrdMain error : " + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId, ordNo, ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
    }
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId, ordNo, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(res, HttpStatus.OK);
  }

  /**
   * シェーマ用テキスト文字情報取得
   * @param ntssUser
   * @return
   */
  @GetMapping("/text-stamp/collection")
  public ResponseEntity<?> getStampTextCollection(
      @AuthenticationPrincipal NtssUser ntssUser) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_EVENT + "/text-stamp/collection";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST シェーマ用テキスト文字情報取得 getStampTextCollection");
    logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
    List<String> res = new ArrayList<>();
    try {
      res = patEventRecService.fetchStampTextCollection(ntssUser.getFacilityCd());
    } catch (Exception e) {
      eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST シェーマ用テキスト文字情報取得 getStampTextCollection error : " + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
    }
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(res, HttpStatus.OK);
  }

  /*add FNSI-改修内容患者イベント患者情報共有より改修 任 start*/
  @GetMapping("/getPublicFlag/{userId}")
  public ResponseEntity<?> getPublicFlag( @PathVariable(name = "userId", required = true) Long userId) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_EVENT + "/getPublicFlag/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(userId));
    // add FNSi5712アプリケーションログが出力しない 周 end
    Map<String, Integer> resp = new HashMap<String, Integer>();
    resp.put("msg",patEventRecService.findPublicFlag(userId));
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(userId));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(resp, HttpStatus.OK);
  }
  /*add FNSI-改修内容患者イベント患者情報共有より改修 任 end*/

// 426 姜 start
  @PostMapping("/mainData/selectDateByCd/{facilityCd}/{patId}/{eventStartDate}")
  public ResponseEntity<List<PatEvent>> selectDateByCd(
    @PathVariable(name = "facilityCd", required = true) String facilityCd,
    @PathVariable(name = "patId", required = true) String patId,
    @PathVariable(name = "eventStartDate", required = true) String eventStartDate
  ) throws URISyntaxException {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_EVENT + "/mainData/selectDateByCd/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd, patId, eventStartDate));
    // add FNSi5712アプリケーションログが出力しない 周 end
    HttpStatus status = HttpStatus.OK;
    List<PatEvent> listRet = new ArrayList<>();

    try {
      listRet = scheduleListService.selectPatEventPeriod(facilityCd, patId, eventStartDate);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("selectDateByCd Exception: "+ e);
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      status = HttpStatus.INTERNAL_SERVER_ERROR;
      listRet = null;
    }
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd, patId, eventStartDate));
    // add FNSi5712アプリケーションログが出力しない 周 end

    return new ResponseEntity<>(listRet, status);
  }
  // add 9273 start
  @PostMapping("/mainData/selectDateByOrdNo/{facilityCd}/{patId}/{eventStartDate}/{ordNo}")
  public ResponseEntity<List<PatEvent>> selectPatEventByOrdNoWithOutStartDate(
    @PathVariable(name = "facilityCd", required = true) String facilityCd,
    @PathVariable(name = "patId", required = true) String patId,
    @PathVariable(name = "eventStartDate", required = true) String eventStartDate,
    @PathVariable(name = "ordNo", required = true) Long ordNo
  ) throws URISyntaxException {
    String mappingUrl = Uri.PAT_EVENT + "/mainData/selectPatEventByOrdNoWithOutStartDate/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd, patId, eventStartDate, ordNo));
    HttpStatus status = HttpStatus.OK;
    List<PatEvent> listRet = new ArrayList<>();

    try {
      listRet = scheduleListService.selectPatEventByOrdNoWithOutStartDate(facilityCd, patId, eventStartDate, ordNo);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("selectDateByCd Exception: "+ e);
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      status = HttpStatus.INTERNAL_SERVER_ERROR;
      listRet = null;
    }
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd, patId, eventStartDate, ordNo));

    return new ResponseEntity<>(listRet, status);
  }
  @PostMapping("/mainData/selectPatEventByOrdNoAndDate")
  public ResponseEntity<List<PatEvent>> selectPatEventByOrdNoAndDate(
    @RequestParam("facilityCd") String facilityCd,
    @RequestParam("patId") String patId,
    @RequestParam("eventStartDate") String eventStartDate,
    @RequestParam("eventEndDate") String eventEndDate,
    @RequestParam("ordNoList") ArrayList<Long> ordNoList
  ) throws URISyntaxException {
    String mappingUrl = Uri.PAT_EVENT + "/mainData/selectPatEventByOrdNoAndDate/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd, patId, eventStartDate, eventEndDate, ordNoList));
    HttpStatus status = HttpStatus.OK;
    List<PatEvent> listRet = new ArrayList<>();

    try {
      listRet = scheduleListService.selectPatEventByOrdNoAndDate(facilityCd, patId, eventStartDate, eventEndDate, ordNoList);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("selectDateByCd Exception: "+ e);
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      status = HttpStatus.INTERNAL_SERVER_ERROR;
      listRet = null;
    }
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd, patId, eventStartDate, eventEndDate, ordNoList));

    return new ResponseEntity<>(listRet, status);
  }
  // add 9273 end
  @PostMapping("/mainData/deletePaEventRec/{patEventCd}")
  public ResponseEntity<Void> deletePaEventRec(
    @PathVariable(name = "patEventCd", required = true) String patEventCd) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_EVENT + "/mainData/deletePaEventRec/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patEventCd));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      patEventRecService.deleteDateByCd(patEventCd);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patEventCd));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patEventCd));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  @PostMapping("/mainData/updateDateByCd/{patEventCd}/{dataNumber}")
  public ResponseEntity<Void> updateDateByCd(
    // mod FNSI-FutreNetWeb+SI課題管理No.4710 李 start
    // @PathVariable(name = "patEventCd", required = true) String patEventCd,
    @PathVariable(name = "patEventCd", required = true) ArrayList<String> patEventCd,
    // mod FNSI-FutreNetWeb+SI課題管理No.4710 李 end
    @PathVariable(name = "dataNumber", required = true) int dataNumber
  ) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_EVENT + "/mainData/updateDateByCd/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patEventCd, dataNumber));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      patEventRecService.updateDateByCd(patEventCd, dataNumber);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patEventCd, dataNumber));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patEventCd, dataNumber));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

// 426 姜 end



  /*add FNSI-改修内容538 連携イベントの登録適正化 任 start*/
  @GetMapping("/getPatEventTreatDate/{ordNo}")
  public ResponseEntity<?> getPatEventTreatDate( @PathVariable(name = "ordNo", required = true) Long ordNo) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_EVENT + "/getPatEventTreatDate/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ordNo));
    // add FNSi5712アプリケーションログが出力しない 周 end
    Map<String, String> resp = new HashMap<String, String>();
    resp.put("msg",patEventRecService.getPatEventTreatDate(ordNo));
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(ordNo));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(resp, HttpStatus.OK);
  }
  /*add FNSI-改修内容538 連携イベントの登録適正化 任 end*/

  // add FNSI-連携イベント作成・中止ツールを追加 ウ start
  /**
   * 連携イベント作成・中止ツールデータ取得
   * @param facilitycd 施設コード
   * @param date_from 表示開始日(YYYYMMDD)
   * @param date_to 表示終了日(YYYYMMDD)
   * @param strSyubetu 表示種別
   * @param strkbn CRUD_CREATE表示作成CRUD_DELETE表示中止
   * @return 患者イベントデータ
   * @throws Exception Exception
   */
  @GetMapping("/PatientInfo/{facilityCd}/{date_from}/{date_to}/{strSyubetu}/{strkbn}")
  public ResponseEntity<List<PatEventCoopInfo>> getPatientInfoData(
    @PathVariable String facilityCd,
    @PathVariable String date_from,
    @PathVariable String date_to,
    @PathVariable String strSyubetu,
    @PathVariable String strkbn
  ) throws Exception {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_EVENT + "/PatientInfo/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd, date_from, date_to, strSyubetu, strkbn));
    // add FNSi5712アプリケーションログが出力しない 周 end
    List<PatEventCoopInfo> res = new ArrayList<PatEventCoopInfo>();
    String dateFrom = ((null != date_from) && (false == "".equals(date_from))) ? date_from.replaceAll("/", "") : null;
    String dateTo = ((null != date_to) && (false == "".equals(date_to))) ? date_to.replaceAll("/", "") : null;

    // mod 2021-08-16 #6142:カテゴリロジックを追加する 鄭 start
    // add 9989 種別単位の検索条件が正しくない　donghao start
    boolean phyFlg ;
    // add 9989 種別単位の検索条件が正しくない　donghao end
    //作成
    if(strkbn.equals("C")){
      if(strSyubetu.equals("exam_ord")){//検査オーダ
        // mod 9989 種別単位の検索条件が正しくない　donghao start
        phyFlg =false;
        //res = patEventRecService.searchPatExamInfo(facilityCd, dateFrom, dateTo);
        res = patEventRecService.searchPatExamInfo(facilityCd, dateFrom, dateTo,phyFlg);
        // mod 9989 種別単位の検索条件が正しくない　donghao end
      }else if(strSyubetu.equals("rad_ord")){//放射線検査オーダ
        // mod 9989 種別単位の検索条件が正しくない　donghao start
        //res = patEventRecService.searchPatRedInfo(facilityCd, dateFrom, dateTo);
        res = patEventRecService.searchPatRadInfo(facilityCd, dateFrom, dateTo);
        // mod 9989 種別単位の検索条件が正しくない　donghao end
      }else if(strSyubetu.equals("pre_ord")){//処方情報連携
        res = patEventRecService.searchOrdPrescriptionInfo(facilityCd, dateFrom, dateTo);

      }else if(strSyubetu.equals("phy_ord")){
        // mod 9989 種別単位の検索条件が正しくない　donghao start
        //心電図検査オーダ
        phyFlg=true;
        //res=new ArrayList<PatEventCoopInfo>();
        res=patEventRecService.searchPatExamInfo(facilityCd, dateFrom, dateTo,phyFlg);
        // mod 9989 種別単位の検索条件が正しくない　donghao end
      }else{
        // mod 9989 種別単位の検索条件が正しくない　donghao start
        //if(strSyubetu.equals("rep_dial")){//透析レポート
        //  strkbn="";
        //}else if(strSyubetu.equals("rst_dial") || strSyubetu.equals("vit_cop") || strSyubetu.equals("karte_ord")){
        // //透析実績,バイタル連携,カルテ記載連携
        // strkbn="R";
        //}
        if(strSyubetu.equals("ind_dial")){//透析予約
          strkbn="";
        }else if(strSyubetu.equals("rst_dial") || strSyubetu.equals("vit_cop") || strSyubetu.equals("karte_ord") ||strSyubetu.equals("rep_dial")){
          //透析実績,バイタル連携,カルテ記載連携,透析レポート
          // mod 9989 種別単位の検索条件が正しくない　donghao end
          strkbn="R";
        }
        res = patEventRecService.searchPatInfo(facilityCd, dateFrom, dateTo,strkbn);
      }

    }else{//中止

      res = patEventRecService.searchStopPatInfo(facilityCd, dateFrom, dateTo,strSyubetu);
    }

    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd, date_from, date_to, strSyubetu, strkbn));
    // add FNSi5712アプリケーションログが出力しない 周 end
    // mod 2022-10-26 bug #6153 イベント作成処理に失敗する（ord_mainとpat_personal_mainのデータ不整合問題への対応） 孫 start
//    return new ResponseEntity<>(res, HttpStatus.OK);
    if (res == null) {
      return new ResponseEntity<>(new ArrayList<PatEventCoopInfo>(), HttpStatus.INTERNAL_SERVER_ERROR);
    } else {
      return new ResponseEntity<>(res, HttpStatus.OK);
    }
    // mod 2022-10-26 bug #6153 イベント作成処理に失敗する（ord_mainとpat_personal_mainのデータ不整合問題への対応） 孫 end
  }
  // add FNSI-連携イベント作成・中止ツールを追加 ウ end


  // add FNSI-施設のリストを取得する 鄭 start
  /*add FNSI-施設のリストを取得する 鄭 start*/
  @GetMapping("/FacilityCdInfo")
  public ResponseEntity<?> getFacilityCdInfo() {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_EVENT + "/FacilityCdInfo";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, null);
    // add FNSi5712アプリケーションログが出力しない 周 end
    List<String>  FacilityCd=patEventRecService.getFacilityCdInfo();
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      AFTER_LOG_FLG_INFO, mappingUrl, null, null);
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(FacilityCd, HttpStatus.OK);
  }
  /*add FNSI-施設のリストを取得する 鄭 end*/
// add FNSI-施設のリストを取得する 鄭 end
  /*add FNSI-改修内容患者イベント外结No.7 任 start*/
  @GetMapping("/getFacilityNameByCd")
  public ResponseEntity<?> getFacilityNameByCd() {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_EVENT + "/getFacilityNameByCd";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, null);
    // add FNSi5712アプリケーションログが出力しない 周 end
    Map<String, List<SysFacility>> resp = new HashMap<String, List<SysFacility>>();
    resp.put("msg",patEventRecService.getFacilityNameByCd());
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      AFTER_LOG_FLG_INFO, mappingUrl, null, null);
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(resp, HttpStatus.OK);
  }
  /*add FNSI-改修内容患者イベント外结No.7 任 end*/

  /**
   * 観察記録のデータのみ取得
   * @param patEventCd
   * @return
   */
  @GetMapping("/getObserveRecordByCd/{patEventCd}")
  public ResponseEntity<?> getObserveRecordByCd(
      @PathVariable(name = "patEventCd", required = true) String patEventCd) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_EVENT + "/getObserveRecordByCd/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patEventCd));
    // add FNSi5712アプリケーションログが出力しない 周 end
    List<PatEvent> res = new ArrayList<PatEvent>();
    if (patEventCd != null && StrUtils.isNumber(patEventCd)) {
      res = patEventRecService.selectObserveRecordByCd(Long.parseLong(patEventCd));
    } else {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patEventCd));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patEventCd));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(res, HttpStatus.OK);
  }

  /**
   * 紹介状のデータのみ取得
   * @param patEventCd
   * @return
   */
  @GetMapping("/getPatIntroLetterByCd/{patEventCd}")
  public ResponseEntity<?> getPatIntroLetterByCd(
      @PathVariable(name = "patEventCd", required = true) String patEventCd) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_EVENT + "/getPatIntroLetterByCd/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patEventCd));
    // add FNSi5712アプリケーションログが出力しない 周 end
    List<PatEvent> res = new ArrayList<PatEvent>();
    if (patEventCd != null && StrUtils.isNumber(patEventCd)) {
      res = patEventRecService.selectPatIntroLetterByCd(Long.parseLong(patEventCd));
    } else {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patEventCd));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patEventCd));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(res, HttpStatus.OK);
  }
  
  @GetMapping("/getObserveRecords/{patId}/{startDate}/{endDate}")
  public ResponseEntity<?> getObserveRecordByCondition(
      @PathVariable(name = "patId", required = true) String patId,
      @PathVariable(name = "startDate", required = true) String startDate,
      @PathVariable(name = "endDate", required = true) String endDate,
      @RequestParam(name = "subCategoryCd", required = false) String subCategoryCd,
      @RequestParam(name = "regStaffCd", required = false) String regStaffCd,
      @RequestParam(name = "upStaffCd", required = false) String upStaffCd,
      @RequestParam(name = "offset", required = false) Integer offset) {
    String mappingUrl = Uri.PAT_EVENT + "/getObserveRecords/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId, startDate, endDate));

    List<PatEventShare> res = new ArrayList<PatEventShare>();

    // サブカテゴリコードはカンマ区切りで設定されているためリストに変換
    List<Long> subCategoryCdList = new ArrayList<Long>();
    if (subCategoryCd != null && !subCategoryCd.isEmpty()) {
      subCategoryCdList = Stream.of(subCategoryCd.split(","))
                          .map(String::trim)
                          .map(Long::valueOf)
                          .collect(Collectors.toList());
    }
    
    if (patId != null && StrUtils.isNumber(patId)) {
      // 画面で表示期間指定なしの場合はstartDate、endDateにnull文字列がパスに設定されるためnullを設定
      String strStartDate = "null".equals(startDate) ? null : startDate;
      String strEndDate = "null".equals(endDate) ? null : endDate;
      // 患者ID、起票日時(開始～終了)、サブカテゴリ、起票者、編集者で検索
      res = patEventRecService.getObsRecByCondition(
        Long.parseLong(patId), strStartDate, strEndDate, subCategoryCdList, regStaffCd, upStaffCd, offset);

      // offset指定ありで初回データ取得の場合はトータル件数をレスポンスに設定
      if (offset != null && offset == 0) {
        int total = patEventRecService.countObsRecByCondition(Long.parseLong(patId), strStartDate, strEndDate, subCategoryCdList, regStaffCd, upStaffCd);
        if (res.size() > 0) {
          res.get(0).setTotal(total);
        }
      }
    } else {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId, startDate, endDate));
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_EVENT,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId, startDate, endDate));
    return new ResponseEntity<>(res, HttpStatus.OK);
  }

  // add FNSi5712アプリケーションログが出力しない 周 start
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
  // add FNSi5712アプリケーションログが出力しない 周 end

  // add 10409 曜日パターン変更の患者イベント修正 関  start
  /**
   * 予定連動選択メッセージ 締切り依頼保存確認メッセージ表示の確認
   *
   * @param bodyData 開始日 終了日
   * @return
   * @throws URISyntaxException
   */
  @GetMapping("/linkageMessageConfirm")
  public ResponseEntity<?> linkageMessageConfirm(
    @RequestParam(name = "from", required = false) String fromDate,
    @RequestParam(name = "to", required = false) String toDate,
    @RequestParam(name = "pat", required = false) Long patId,
    @RequestParam(name = "facility", required = false) String facilityCd
  ) throws Exception {

    fromDate = ((null != fromDate) && (false == "".equals(fromDate))) ? fromDate.replaceAll("-", "") : null;
    toDate = ((null != toDate) && (false == "".equals(toDate))) ? toDate.replaceAll("-", "") : null;

    boolean linkageFlag = patEventRecService.searchLinkage(facilityCd, fromDate, toDate, patId);

    return new ResponseEntity<>(linkageFlag, HttpStatus.OK);
  }
  // add 10409 曜日パターン変更の患者イベント修正 関  end
}
