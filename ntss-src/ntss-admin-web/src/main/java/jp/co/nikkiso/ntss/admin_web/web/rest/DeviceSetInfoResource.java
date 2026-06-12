package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.net.URISyntaxException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.request.patientCapture.JournalCreateRequestPayload;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.DeviceSetInfoService;
import jp.co.nikkiso.ntss.admin_web.service.IndHistoryMakeService;
import jp.co.nikkiso.ntss.admin_web.service.JournalService;
import jp.co.nikkiso.ntss.admin_web.service.MstInfoService;
import jp.co.nikkiso.ntss.admin_web.service.OrdMainService;
import jp.co.nikkiso.ntss.admin_web.service.PatInfoService;
import jp.co.nikkiso.ntss.admin_web.service.SelectHistoryUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.nextpat.NextPatService;
// del #11004 連携イベント発生部分不正 piao start
// import jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.TreatmentRecordService;
import jp.co.nikkiso.ntss.admin_web.service.access.FacilityAccessService;
// del #11004 連携イベント発生部分不正 piao end
//add #10632 装置設定画面の更新時にpat_main_historyがインサートされない 20240530 ztc start
import jp.co.nikkiso.ntss.api.service.PatMainDeviceSetInfo.PatMainDeviceSetInfoService;
//add #10632 装置設定画面の更新時にpat_main_historyがインサートされない 20240530 ztc end
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.MstDialyzerDao;
import jp.co.nikkiso.ntss.core.dao.MstTreatmentDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.logger.LogLevel;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;
import org.springframework.validation.BindingResult;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.admin_web.web.rest.validation.ApiEntityDeviceSetInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PatInfoRemovalWater;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.PatTreatmentPatternUtils;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.PatTreatmentPatternUtils.PatTreatmentPatternEditData;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;


import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;
import org.apache.commons.lang3.ObjectUtils;
import java.util.Collections;
import java.util.Set;

@RestController
@RequestMapping(Uri.DEVICE_SET_INFO)
public class DeviceSetInfoResource {
  @Autowired
  DeviceSetInfoService deviceSetInfoService;

  @Autowired
  OrdMainService ordMainService;

  @Autowired
  IndHistoryMakeService indHistoryMakeService;

  @Autowired
  PatTreatmentPatternUtils patTreatmentPatternUtils;

  @Autowired
  OrdMainResource ordMainResource;

  @Autowired
  MntMachineStateDao mntMachineStateDao;

  @Autowired
  PatPersonalMainDao patPersonalMainDao;

  @Autowired
	LogService logService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  @Autowired
  private FacilityAccessService facilityAccessService;

  // wp アプリケーションログの適正化 Add End

  // add FNSi6002-補液速度操作範囲上限を超えて設定できる 周 start
  @Autowired
  MstInfoService mstInfoService;
  // add FNSi6002-補液速度操作範囲上限を超えて設定できる 周 end

  @Autowired
  private MstTreatmentDao mstTreatmentDao;

  // del #11004 連携イベント発生部分不正 piao start
  // add #10553 ④装置設定＞風袋・除水補正にて指示への展開保存をした場合には、変更された治療予定毎の連携イベントが必要 piao start
  // @Autowired
  // private TreatmentRecordService treatmentRecordService;
  // add #10553 ④装置設定＞風袋・除水補正にて指示への展開保存をした場合には、変更された治療予定毎の連携イベントが必要 piao end
  // del #11004 連携イベント発生部分不正 piao end

  @Autowired
  JournalService journalService;
  @Autowired
  MstDialyzerDao mstDialyzerDao;

  //add #10412 次患者更新関連全体見直し対応 朴 start
  @Autowired
  private PatMainDao patMainDao;

  @Autowired
  private OrdMainDao ordMainDao;

  /**
   * 次患者更新関連
   */
  @Autowired
  private NextPatService nextPatService;
  //add #10412 次患者更新関連全体見直し対応 朴 end

  //add #10632 装置設定画面の更新時にpat_main_historyがインサートされない 20240530 ztc start
  @Autowired
  PatInfoService patInfoService;
  //add #10632 装置設定画面の更新時にpat_main_historyがインサートされない 20240530 ztc end

  //add #10632 装置設定画面の更新時にpat_main_historyがインサートされない 20240530 ztc start
  @Autowired
  PatMainDeviceSetInfoService patMainDeviceSetInfoService;
  //add #10632 装置設定画面の更新時にpat_main_historyがインサートされない 20240530 ztc end

  //add 11119 by kangjie 20241009 start
  @Autowired
  private SelectHistoryUtils selectHistoryUtils;
  //add 11119 by kangjie 20241009 end

  /**
   * 装置設定(マスタ)取得
   * @return 装置設定JSON
   */
  @GetMapping("/getDeviceSetInfoMst/{facility_cd}")
  public ResponseEntity<String> getDeviceSetInfoMst(@PathVariable String facility_cd,
                                                    @RequestParam(required = false) Long selectedPatId,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                    @AuthenticationPrincipal NtssUser ntssUser
                                                    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    if (!facilityAccessService.hasFacilityOrSelectedPatShareAccess(ntssUser, facility_cd, selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_SET_INFO + "/getDeviceSetInfoMst";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, BEFORE_LOG_FLG_INFO, mappingUrl, facility_cd,
      null);
    // wp アプリケーションログの適正化 Add End

    String deviceSetInfo = null;
    try {
      deviceSetInfo = deviceSetInfoService.getDeviceSetInfoMst(facility_cd);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);
      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_ERROR, mappingUrl, facility_cd, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_INFO, mappingUrl, facility_cd,
     null);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(deviceSetInfo, HttpStatus.OK);
  }

  /**
   * mod facility_cdパラメータを追加 #12462 患者情報共有 zrx
   * 装置設定(患者情報)取得
   * @return 装置設定JSON
   */
  @GetMapping({"/getDeviceSetInfoPat/{pat_id}","/getDeviceSetInfoPat/{pat_id}/{facility_cd}"})
  public ResponseEntity<String> getDeviceSetInfoPat(@PathVariable Long pat_id,@PathVariable(required = false) String facility_cd,
                                                    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                    @AuthenticationPrincipal NtssUser ntssUser
                                                    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
        PatMain patMain = patMainDao.selectById(pat_id);
        if (patMain != null && patMain.getFacility_cd() != null &&
          !patMain.getFacility_cd().equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facility_cd=" + patMain.getFacility_cd() + " " + "pat_id=" + pat_id + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_SET_INFO + "/getDeviceSetInfoPat";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      pat_id);
    // wp アプリケーションログの適正化 Add End
    String deviceSetInfo = null;
    try {
      // add facility_cdパラメータを追加 #12462 患者情報共有 zrx start
      if (StringUtils.hasText(facility_cd)) {
        deviceSetInfo = deviceSetInfoService.getDeviceSetInfoPat(pat_id,facility_cd);
      } else {
        // add facility_cdパラメータを追加 #12462 患者情報共有 zrx end
        deviceSetInfo = deviceSetInfoService.getDeviceSetInfoPat(pat_id);
      }
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_INFO, mappingUrl, null,
      pat_id);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(deviceSetInfo, HttpStatus.OK);
  }

  /**
   * 装置設定(指示)取得
   * @return 装置設定JSON
   */
  @GetMapping("/getDeviceSetInfoOrd/{ord_no}")
  public ResponseEntity<String> getDeviceSetInfoOrd(@PathVariable Long ord_no,
                                                    @RequestParam(required = false) Long selectedPatId,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                    @AuthenticationPrincipal NtssUser ntssUser
                                                    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    OrdMain ordMain = ordMainDao.selectByOrdNo(ord_no);
    if (ordMain != null && !facilityAccessService.hasFacilityOrSelectedPatShareAccessForFacilityCds(
        ntssUser, Collections.singletonList(ordMain.getFacilityCd()), selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_SET_INFO + "/getDeviceSetInfoOrd";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      ord_no);
    // wp アプリケーションログの適正化 Add End
    String deviceSetInfo = null;
    try {
      deviceSetInfo = deviceSetInfoService.getDeviceSetInfoOrd(ord_no);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_INFO, mappingUrl, null,
      ord_no);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(deviceSetInfo, HttpStatus.OK);
  }

  /**
   * 装置設定(マスタ)更新
   * @param facility_cd 施設コード
   * @return 装置設定JSON
   */
  @PostMapping("/updateDeviceSetInfoMst/{facility_cd}")
  public ResponseEntity<Void> updateDeviceSetInfoMst(@PathVariable String facility_cd, @RequestBody Map<String, String> payload,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                     @AuthenticationPrincipal NtssUser ntssUser
                                                     // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
        if (!ObjectUtils.isEmpty(facility_cd) &&
          !facility_cd.equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facility_cd=" + facility_cd + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_SET_INFO + "/updateDeviceSetInfoMst";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, BEFORE_LOG_FLG_INFO, mappingUrl, facility_cd,
      payload);
    // wp アプリケーションログの適正化 Add End

    String deviceSetInfo = payload.get("deviceSetInfo");
    try {
      deviceSetInfoService.updateDeviceSetInfoMst(facility_cd, deviceSetInfo);
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_INFO, mappingUrl, facility_cd,
        payload);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_ERROR, mappingUrl, facility_cd, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 装置設定(患者情報)更新
   * @param payload
   * @return 装置設定JSON
   */
  @PostMapping("/updateDeviceSetInfoPat")
  public ResponseEntity<?> updateDeviceSetInfoPat(@RequestBody Map<String, String> payload,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                  @AuthenticationPrincipal NtssUser ntssUser
                                                  // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
        String facilityCd = payload.get("facilityCd");
        if (facilityCd != null && !facilityCd.isEmpty() &&
          !facilityCd.equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end



    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_SET_INFO + "/updateDeviceSetInfoPat";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      payload);
    // wp アプリケーションログの適正化 Add End

    Long patId = null;
    if (payload.get("patId") != null) {
      patId = Long.parseLong(payload.get("patId"));
    }
    String facilityCd = payload.get("facilityCd");
    String deviceSetInfo = payload.get("deviceSetInfo");
    if (facilityCd == null && patId != null) {
      List<Long> patIdList = new ArrayList<Long>();
      patIdList.add(patId);
      List<PatPersonalMain> listPatPersonalMain = patPersonalMainDao.selectByIdList(patIdList);
      PatPersonalMain patPersonalMain = listPatPersonalMain.get(0);
      facilityCd = patPersonalMain.getFacility_cd();
      // #11205 -ペンテスト2－4認可制御の不備  add 20260420 start
      // patId 経由で解決した facilityCd がセッションの施設と一致するか確認
      if (!ntssUser.isNkkAdminUser()) {
        if (facilityCd != null && !facilityCd.isEmpty() &&
            !facilityCd.equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " " + "patId=" + patId + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
      }
      // #11205 -ペンテスト2－4認可制御の不備  add 20260420 end
    }

    //add #10412 次患者更新関連全体見直し対応 朴 start
    List<Long> patidListForCheckDoCallNextPat = new ArrayList<>();
    //add #10412 次患者更新関連全体見直し対応 朴 end

    try {
      // add #7188 2022/11/24 治療条件，装置設定を変更すると次患者が再送される dou start
      JSONObject dstDeviceSetInfoJsonObj = new JSONObject(deviceSetInfo);
      String dialyzer = "";
      String gridCell = "";
      // add #7188 2022/11/24 治療条件，装置設定を変更すると次患者が再送される dou end
      // add FNSi6002-補液速度操作範囲上限を超えて設定できる 周 start
////7810 mod 治療条件・装置設定変更時の動作不備（412.xlsx）張 start
// mod 10864 装置設定を編集して保存後に表示される注意喚起メッセージのOKを編集箇所の数だけ押下する必要がある 張玲 start
//       List<String> response = new ArrayList<>();
      HashSet<String> response = new HashSet<>();
// mod 10864 装置設定を編集して保存後に表示される注意喚起メッセージのOKを編集箇所の数だけ押下する必要がある 張玲 end

      // add #6566 職種マスタ編集時に既存利用者への反映を確認するメッセージがOK_Cancelの表現なので分かりづらい 王永吉 start
      // #8061-装置設定が保存出来ない 周 20221115 mod start
      // #8061-装置設定が保存出来ない 周 20221117 mod start
      //List<PatPersonalMain> patList = patPersonalMainDao.selectPatListByFacility(payload.get("facilityCd"));
      //if (patList.size() > 0){
      //  for (int i = 0; i < patList.size(); i++){
      //    if (patList.get(i).getPat_id() != null &&  !"".equals(patList.get(i).getPat_id())){
      //      patId = patList.get(i).getPat_id();
      List<PatPersonalMain> patList = patPersonalMainDao.selectPatListByFacility(payload.get("facilityCd"));
      if (patList.size() > 0){
        for (int i = 0; i < patList.size(); i++){
          if (patList.get(i).getPat_id() != null &&  !"".equals(patList.get(i).getPat_id())){
            Long loopPatId = patList.get(i).getPat_id();
            if(null != patId && !patId.equals(loopPatId)) { continue; }
      // #8061-装置設定が保存出来ない 周 20221117 mod end
      // #8061-装置設定が保存出来ない 周 20221115 mod end
            List<String> responseM = new ArrayList<>();
      // add #6566 職種マスタ編集時に既存利用者への反映を確認するメッセージがOK_Cancelの表現なので分かりづらい 王永吉 end
            // #8061-装置設定が保存出来ない 周 20221117 mod start
            //String orgDeviceSetInfo = deviceSetInfoService.getDeviceSetInfoPat(patId);
            String orgDeviceSetInfo = deviceSetInfoService.getDeviceSetInfoPat(loopPatId);
            // #8061-装置設定が保存出来ない 周 20221117 mod end
            // add #6566 職種マスタ編集時に既存利用者への反映を確認するメッセージがOK_Cancelの表現なので分かりづらい 王永吉 start
            // #8061-装置設定が保存出来ない 周 20221117 mod start
            //if ("[]".equals(orgDeviceSetInfo) || orgDeviceSetInfo == null || "".equals(orgDeviceSetInfo)){ continue; }
            if ("[]".equals(orgDeviceSetInfo) || orgDeviceSetInfo == null || "".equals(orgDeviceSetInfo)){ continue; }
            // #8061-装置設定が保存出来ない 周 20221117 mod end
            // add #6566 職種マスタ編集時に既存利用者への反映を確認するメッセージがOK_Cancelの表現なので分かりづらい 王永吉 end
            JSONObject orgDeviceSetInfoObj = new JSONObject(orgDeviceSetInfo);
            // mod #6566 職種マスタ編集時に既存利用者への反映を確認するメッセージがOK_Cancelの表現なので分かりづらい 王永吉 start
//            JSONObject orgOpeObj = orgDeviceSetInfoObj.getJSONObject("ope");
//            JSONObject orgDevJsonObj = orgOpeObj.getJSONObject("dev");
//            //liquidCalPriority
//            JSONObject orgAJsonObj = orgDevJsonObj.getJSONObject("A");
//            Double orgLiquidCalPriority = (null != orgAJsonObj.get("389")) ? Double.valueOf(orgAJsonObj.get("389").toString()) : 0;
//            Double orgLiquidRateBefore = (null != orgAJsonObj.get("379")) ? Double.valueOf(orgAJsonObj.get("379").toString()) : 0;
//            Double orgBeforeHDF = (null != orgAJsonObj.get("185")) ? Double.valueOf(orgAJsonObj.get("185").toString()) : 0;
//            Double orgBeforeHF = (null != orgAJsonObj.get("186")) ? Double.parseDouble(orgAJsonObj.get("186").toString()) : 0;
//            Double orgBeforeOHDF = (null != orgAJsonObj.get("396")) ? Double.parseDouble(orgAJsonObj.get("396").toString()) : 0;
//            Double orgBeforeOHF = (null != orgAJsonObj.get("397")) ? Double.parseDouble(orgAJsonObj.get("397").toString()) : 0;
//            JSONObject orgBJsonObj = orgDevJsonObj.getJSONObject("B");
//            //Double orgBeforeHDPlus = Double.parseDouble(orgBJsonObj.get("30").toString());
//            Double orgLiquidRateAfter = (null != orgBJsonObj.get("39")) ? Double.valueOf(orgBJsonObj.get("39").toString()) : 0;
//            Double orgAfterHDF = (null != orgBJsonObj.get("31")) ? Double.parseDouble(orgBJsonObj.get("31").toString()) : 0;
//            Double orgAfterHF = (null != orgBJsonObj.get("32")) ? Double.parseDouble(orgBJsonObj.get("32").toString()) : 0;
//            //Double orgAfterHDPlus = Double.parseDouble(orgBJsonObj.get("33").toString());
//            Double orgAfterOHDF = (null != orgBJsonObj.get("34")) ? Double.parseDouble(orgBJsonObj.get("34").toString()) : 0;
//            Double orgAfterOHF = (null != orgBJsonObj.get("35")) ? Double.parseDouble(orgBJsonObj.get("35").toString()) : 0;
            Double orgLiquidCalPriority = Double.valueOf(0);
            Double orgLiquidRateBefore = Double.valueOf(0);
            Double orgBeforeHDF = Double.valueOf(0);
            Double orgBeforeHF = Double.valueOf(0);
            Double orgBeforeOHDF = Double.valueOf(0);
            Double orgBeforeOHF = Double.valueOf(0);
            Double orgLiquidRateAfter = Double.valueOf(0);
            Double orgAfterHDF = Double.valueOf(0);
            Double orgAfterHF = Double.valueOf(0);
            Double orgAfterOHDF = Double.valueOf(0);
            Double orgAfterOHF = Double.valueOf(0);
            // add bug 7810 修正 start
            Double orgAuxiliaryLiquid=Double.valueOf(0);
            Double orgBloodFlow=Double.valueOf(0);
            Double dstBloodFlow=Double.valueOf(0);
            Double orgDialysisFluidTemperatureUp=Double.valueOf(0);
            Double dstDialysisFluidTemperatureUp=Double.valueOf(0);
            Double orgDialysisFluidTemperatureDown=Double.valueOf(0);
            Double dstDialysisFluidTemperatureDown=Double.valueOf(0);
            // add bug 7810 修正 end
            if(orgDeviceSetInfoObj.has("ope")) {
              JSONObject orgOpeObj = orgDeviceSetInfoObj.getJSONObject("ope");
              JSONObject orgDevJsonObj = (null != orgOpeObj && orgOpeObj.has("dev")) ? orgOpeObj.getJSONObject("dev") : null;
              JSONObject orgAJsonObj = (null != orgDevJsonObj && orgDevJsonObj.has("A")) ? orgDevJsonObj.getJSONObject("A") : null;
              JSONObject orgBJsonObj = (null != orgDevJsonObj && orgDevJsonObj.has("B")) ? orgDevJsonObj.getJSONObject("B") : null;
              if (orgAJsonObj != null){
                orgLiquidCalPriority = (orgAJsonObj.has("389")) ? ((null != orgAJsonObj.get("389")) ? Double.valueOf(orgAJsonObj.get("389").toString()) : 0) : 0;
                orgLiquidRateBefore = (orgAJsonObj.has("379")) ? ((null != orgAJsonObj.get("379")) ? Double.valueOf(orgAJsonObj.get("379").toString()) : 0) : 0;
                orgBeforeHDF = (orgAJsonObj.has("185")) ? ((null != orgAJsonObj.get("185")) ? Double.valueOf(orgAJsonObj.get("185").toString()) : 0) : 0;
                orgBeforeHF = (orgAJsonObj.has("186")) ? ((null != orgAJsonObj.get("186")) ? Double.valueOf(orgAJsonObj.get("186").toString()) : 0) : 0;
                orgBeforeOHDF = (orgAJsonObj.has("396")) ? ((null != orgAJsonObj.get("396")) ? Double.valueOf(orgAJsonObj.get("396").toString()) : 0) : 0;
                orgBeforeOHF = (orgAJsonObj.has("397")) ? ((null != orgAJsonObj.get("397")) ? Double.valueOf(orgAJsonObj.get("397").toString()) : 0) : 0;
                // add bug 7810 修正 start
                orgAuxiliaryLiquid = (orgAJsonObj.has("383")) ? ((null != orgAJsonObj.get("383")) ? Double.valueOf(orgAJsonObj.get("383").toString()) : 0) : 0;
                orgDialysisFluidTemperatureUp = (orgAJsonObj.has("182")) ? ((null != orgAJsonObj.get("182")) ? Double.valueOf(orgAJsonObj.get("182").toString()) : 0) : 0;
                orgDialysisFluidTemperatureDown = (orgAJsonObj.has("183")) ? ((null != orgAJsonObj.get("183")) ? Double.valueOf(orgAJsonObj.get("183").toString()) : 0) : 0;
                orgBloodFlow = (orgAJsonObj.has("179")) ? ((null != orgAJsonObj.get("179")) ? Double.valueOf(orgAJsonObj.get("179").toString()) : 0) : 0;
                // add bug 7810 修正 end
              }
              if (orgBJsonObj != null){
                orgLiquidRateAfter = (orgBJsonObj.has("39")) ? ((null != orgBJsonObj.get("39")) ? Double.valueOf(orgBJsonObj.get("39").toString()) : 0) : 0;
                orgAfterHDF = (orgBJsonObj.has("31")) ? ((null != orgBJsonObj.get("31")) ? Double.valueOf(orgBJsonObj.get("31").toString()) : 0) : 0;
                orgAfterHF = (orgBJsonObj.has("32")) ? ((null != orgBJsonObj.get("32")) ? Double.valueOf(orgBJsonObj.get("32").toString()) : 0) : 0;
                orgAfterOHDF = (orgBJsonObj.has("34")) ? ((null != orgBJsonObj.get("34")) ? Double.valueOf(orgBJsonObj.get("34").toString()) : 0) : 0;
                orgAfterOHF = (orgBJsonObj.has("35")) ? ((null != orgBJsonObj.get("35")) ? Double.valueOf(orgBJsonObj.get("35").toString()) : 0) : 0;
              }
            }
            // mod #6566 職種マスタ編集時に既存利用者への反映を確認するメッセージがOK_Cancelの表現なので分かりづらい 王永吉 end
            // del #7188 2022/11/24 治療条件，装置設定を変更すると次患者が再送される dou start
            // JSONObject dstDeviceSetInfoJsonObj = new JSONObject(deviceSetInfo);
            // del #7188 2022/11/24 治療条件，装置設定を変更すると次患者が再送される dou end
            // mod FNSi7137-装置設定が保存出来ない 周 start
            //boolean isNeedCheck = false;
            Double dstBeforeOHDF = Double.valueOf(0);
            Double dstAfterOHDF = Double.valueOf(0);
            Double dstBeforeHDF = Double.valueOf(0);
            Double dstAfterHDF = Double.valueOf(0);
            Double dstBeforeOHF = Double.valueOf(0);
            Double dstAfterOHF = Double.valueOf(0);
            Double dstBeforeHF = Double.valueOf(0);
            Double dstAfterHF = Double.valueOf(0);
            Double dstAuxiliaryLiquid=Double.valueOf(0);
            if(dstDeviceSetInfoJsonObj.has("ope")) {
              JSONObject dstOpeObj = dstDeviceSetInfoJsonObj.getJSONObject("ope");
              // mod #6566 職種マスタ編集時に既存利用者への反映を確認するメッセージがOK_Cancelの表現なので分かりづらい 王永吉 start
//              JSONObject dstDevJsonObj = dstOpeObj.getJSONObject("dev");
//              JSONObject dstAJsonObj = dstDevJsonObj.getJSONObject("A");
//              Double dstLiquidRateBefore = (null != dstAJsonObj.get("379")) ? Double.parseDouble(dstAJsonObj.get("379").toString()) : 0;
//              Double dstLiquidCalPriority = (null != dstAJsonObj.get("389")) ? Double.parseDouble(dstAJsonObj.get("389").toString()) : 0;
//              dstBeforeHDF = (null != dstAJsonObj.get("185")) ? Double.parseDouble(dstAJsonObj.get("185").toString()) : 0;
//              dstBeforeHF = (null != dstAJsonObj.get("186")) ? Double.parseDouble(dstAJsonObj.get("186").toString()) : 0;
//              dstBeforeOHDF = (null != dstAJsonObj.get("396")) ? Double.parseDouble(dstAJsonObj.get("396").toString()) : 0;
//              dstBeforeOHF = (null != dstAJsonObj.get("397")) ? Double.parseDouble(dstAJsonObj.get("397").toString()) : 0;
//              JSONObject dstBJsonObj = dstDevJsonObj.getJSONObject("B");
//              Double dstLiquidRateAfter = (null != dstBJsonObj.get("39")) ? Double.parseDouble(dstBJsonObj.get("39").toString()) : 0;
//              dstAfterHDF = (null != dstBJsonObj.get("31")) ? Double.parseDouble(dstBJsonObj.get("31").toString()) : 0;
//              dstAfterHF = (null != dstBJsonObj.get("32")) ? Double.parseDouble(dstBJsonObj.get("32").toString()) : 0;
//              dstAfterOHDF = (null != dstBJsonObj.get("34")) ? Double.parseDouble(dstBJsonObj.get("34").toString()) : 0;
//              dstAfterOHF = (null != dstBJsonObj.get("35")) ? Double.parseDouble(dstBJsonObj.get("35").toString()) : 0;
              JSONObject dstDevJsonObj = (null != dstOpeObj && dstOpeObj.has("dev")) ? dstOpeObj.getJSONObject("dev") : null;
              JSONObject dstAJsonObj = (null != dstDevJsonObj && dstDevJsonObj.has("A")) ? dstDevJsonObj.getJSONObject("A") : null;
              JSONObject dstBJsonObj = (null != dstDevJsonObj && dstDevJsonObj.has("B")) ? dstDevJsonObj.getJSONObject("B") : null;
              Double dstLiquidRateBefore = Double.valueOf(0);
              Double dstLiquidCalPriority = Double.valueOf(0);
              Double dstLiquidRateAfter = Double.valueOf(0);
              if (dstAJsonObj != null){
                dstLiquidRateBefore = (dstAJsonObj.has("379")) ? ((null != dstAJsonObj.get("379")) ? Double.valueOf(dstAJsonObj.get("379").toString()) : 0) : 0;
                dstLiquidCalPriority = (dstAJsonObj.has("389")) ? ((null != dstAJsonObj.get("389")) ? Double.valueOf(dstAJsonObj.get("389").toString()) : 0) : 0;
                dstBeforeHDF = (dstAJsonObj.has("185")) ? ((null != dstAJsonObj.get("185")) ? Double.valueOf(dstAJsonObj.get("185").toString()) : 0) : 0;
                dstBeforeHF = (dstAJsonObj.has("186")) ? ((null != dstAJsonObj.get("186")) ? Double.valueOf(dstAJsonObj.get("186").toString()) : 0) : 0;
                dstBeforeOHDF = (dstAJsonObj.has("396")) ? ((null != dstAJsonObj.get("396")) ? Double.valueOf(dstAJsonObj.get("396").toString()) : 0) : 0;
                dstBeforeOHF = (dstAJsonObj.has("397")) ? ((null != dstAJsonObj.get("397")) ? Double.valueOf(dstAJsonObj.get("397").toString()) : 0) : 0;
                // add bug 7810 修正 start
                dstAuxiliaryLiquid = (dstAJsonObj.has("383")) ? ((null != dstAJsonObj.get("383")) ? Double.valueOf(dstAJsonObj.get("383").toString()) : 0) : 0;
                dstDialysisFluidTemperatureUp = (dstAJsonObj.has("182")) ? ((null != dstAJsonObj.get("182")) ? Double.valueOf(dstAJsonObj.get("182").toString()) : 0) : 0;
                dstDialysisFluidTemperatureDown = (dstAJsonObj.has("183")) ? ((null != dstAJsonObj.get("183")) ? Double.valueOf(dstAJsonObj.get("183").toString()) : 0) : 0;
                dstBloodFlow = (dstAJsonObj.has("179")) ? ((null != dstAJsonObj.get("179")) ? Double.valueOf(dstAJsonObj.get("179").toString()) : 0) : 0;
                // add bug 7810 修正 end
              }
              if (dstBJsonObj != null){
                dstLiquidRateAfter = (dstBJsonObj.has("39")) ? ((null != dstBJsonObj.get("39")) ? Double.valueOf(dstBJsonObj.get("39").toString()) : 0) : 0;
                dstAfterHDF = (dstBJsonObj.has("31")) ? ((null != dstBJsonObj.get("31")) ? Double.valueOf(dstBJsonObj.get("31").toString()) : 0) : 0;
                dstAfterHF = (dstBJsonObj.has("32")) ? ((null != dstBJsonObj.get("32")) ? Double.valueOf(dstBJsonObj.get("32").toString()) : 0) : 0;
                dstAfterOHDF = (dstBJsonObj.has("34")) ? ((null != dstBJsonObj.get("34")) ? Double.valueOf(dstBJsonObj.get("34").toString()) : 0) : 0;
                dstAfterOHF = (dstBJsonObj.has("35")) ? ((null != dstBJsonObj.get("35")) ? Double.valueOf(dstBJsonObj.get("35").toString()) : 0) : 0;
              }
              // mod #6566 職種マスタ編集時に既存利用者への反映を確認するメッセージがOK_Cancelの表現なので分かりづらい 王永吉 end
              //add 7810 2022/11/30 変更した際にOHDF，OHFの予定があっても注意喚起メッセージが表示されない 張 start
              if(!orgLiquidCalPriority.equals(dstLiquidCalPriority)){
                List<OrdMain> ordMainList = ordMainService.selectByPatIdAndDeviceMode(facilityCd, loopPatId,AdminWebConstant.Treatment.DeviceMode.OHDF);
                List<OrdMain> OHFordMain = ordMainService.selectByPatIdAndDeviceMode(facilityCd, loopPatId,AdminWebConstant.Treatment.DeviceMode.OHF);
                ordMainList.addAll(OHFordMain);
                if (ordMainList.size() > 0) {
                  response.add("liquidCalPriorityChange");
                }
              }
              if(!orgAuxiliaryLiquid.equals(dstAuxiliaryLiquid)){
                List<OrdMain> ordMainList =ordMainService.selectByAuxiliaryLiquidAndDeviceMode(facilityCd, loopPatId, Arrays.asList(7,8),dstAuxiliaryLiquid);
               if (ordMainList.size()>0){
                 response.add("auxiliaryLiquid");
               }
              }
              if(!orgBloodFlow.equals(dstBloodFlow)) {
                List<OrdMain> ordMainList = ordMainService.selectByBloodFlowAndDeviceMode(facilityCd, loopPatId, dstBloodFlow);
                if (ordMainList.size() > 0) {
                  response.add("bloodFlow");
                }
              }
              if(!orgDialysisFluidTemperatureUp.equals(dstDialysisFluidTemperatureUp) || !orgDialysisFluidTemperatureDown.equals(dstDialysisFluidTemperatureDown)) {
                List<OrdMain> ordMainList = ordMainService.selectByDialysisFluidTemperatureAndDeviceMode(facilityCd, loopPatId, dstDialysisFluidTemperatureUp, dstDialysisFluidTemperatureDown);
                if (ordMainList.size() > 0) {
                  response.add("dialysisFluidTemperature");
                }
              }
              //add 7810  2022/11/30 変更した際にOHDF，OHFの予定があっても注意喚起メッセージが表示されない。張 end
              // add FNSi6442治療モードOHDF,OHFの補液速度が再計算されない 周 start
              if(2 == dstLiquidCalPriority.intValue()
                && ((0 != dstLiquidRateBefore.compareTo(orgLiquidRateBefore))
                || (0 != dstLiquidRateAfter.compareTo(orgLiquidRateAfter)))) {
                // mod #6566 職種マスタ編集時に既存利用者への反映を確認するメッセージがOK_Cancelの表現なので分かりづらい 王永吉 start
                response.add("liquidCalPriority");
//                responseM.add("liquidCalPriority");
                // mod #6566 職種マスタ編集時に既存利用者への反映を確認するメッセージがOK_Cancelの表現なので分かりづらい 王永吉 end
              }
              // add FNSi6442治療モードOHDF,OHFの補液速度が再計算されない 周 end

              if((orgBeforeHDF.compareTo(dstBeforeHDF) != 0) || (orgBeforeHF.compareTo(dstBeforeHF) != 0)
                || (orgBeforeOHDF.compareTo(dstBeforeOHDF) != 0) || (orgBeforeOHF.compareTo(dstBeforeOHF) != 0)
                || (orgAfterHDF.compareTo(dstAfterHDF) != 0) || (orgAfterHF.compareTo(dstAfterHF) != 0)
                || (orgAfterOHDF.compareTo(dstAfterOHDF) != 0) || (orgAfterOHF.compareTo(dstAfterOHF) != 0)) {
                //isNeedCheck = true;
                // mod #6566 職種マスタ編集時に既存利用者への反映を確認するメッセージがOK_Cancelの表現なので分かりづらい 王永吉 start
                response.add("replenisherSpeed");
//                responseM.add("replenisherSpeed");
                // mod #6566 職種マスタ編集時に既存利用者への反映を確認するメッセージがOK_Cancelの表現なので分かりづらい 王永吉 end
              }
            }
      //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 start

            if(dstDeviceSetInfoJsonObj.has("war")) {
              JSONObject warObj = dstDeviceSetInfoJsonObj.getJSONObject("war");
              // mod #6566 職種マスタ編集時に既存利用者への反映を確認するメッセージがOK_Cancelの表現なので分かりづらい 王永吉 start
//              JSONObject warDevJsonObj = warObj.getJSONObject("dev");
//              JSONObject warInfoJsonObj = warDevJsonObj.getJSONObject("A");
              JSONObject warDevJsonObj = (null != warObj && warObj.has("dev")) ? warObj.getJSONObject("dev") : null;
              JSONObject warInfoJsonObj = (null != warDevJsonObj && warDevJsonObj.has("A")) ? warDevJsonObj.getJSONObject("A") : null;
              // mod #6566 職種マスタ編集時に既存利用者への反映を確認するメッセージがOK_Cancelの表現なので分かりづらい 王永吉 end
              // add #6566 職種マスタ編集時に既存利用者への反映を確認するメッセージがOK_Cancelの表現なので分かりづらい 王永吉 start
              if (warInfoJsonObj != null){
              // add #6566 職種マスタ編集時に既存利用者への反映を確認するメッセージがOK_Cancelの表現なので分かりづらい 王永吉 end
                if (warInfoJsonObj.has("240") && "0".equals(warInfoJsonObj.get("240"))) {
                  List<OrdMain> ordMainList = ordMainService.selectByPatIdAndDeviceMode(facilityCd, loopPatId, AdminWebConstant.Treatment.DeviceMode.AFBF);
                  if (ordMainList.size() > 0) {
                    // mod #6566 職種マスタ編集時に既存利用者への反映を確認するメッセージがOK_Cancelの表現なので分かりづらい 王永吉 start
                  response.add("replenisherAFBF");
//                    responseM.add("replenisherAFBF");
                    // mod #6566 職種マスタ編集時に既存利用者への反映を確認するメッセージがOK_Cancelの表現なので分かりづらい 王永吉 end
                  }
                }
              // add #6566 職種マスタ編集時に既存利用者への反映を確認するメッセージがOK_Cancelの表現なので分かりづらい 王永吉 start
              }
              // add #6566 職種マスタ編集時に既存利用者への反映を確認するメッセージがOK_Cancelの表現なので分かりづらい 王永吉 end
            }
            if(dstDeviceSetInfoJsonObj.has("bv")) {
              JSONObject bvObj = dstDeviceSetInfoJsonObj.getJSONObject("bv");
              // mod #6566 職種マスタ編集時に既存利用者への反映を確認するメッセージがOK_Cancelの表現なので分かりづらい 王永吉 start
//              JSONObject bvDevJsonObj = bvObj.getJSONObject("dev");
//              JSONObject bvInfoJsonObj = bvDevJsonObj.getJSONObject("A");
              JSONObject bvDevJsonObj = (null != bvObj && bvObj.has("dev")) ? bvObj.getJSONObject("dev") : null;
              JSONObject bvInfoJsonObj = (null != bvDevJsonObj && bvDevJsonObj.has("A")) ? bvDevJsonObj.getJSONObject("A") : null;
              // mod #6566 職種マスタ編集時に既存利用者への反映を確認するメッセージがOK_Cancelの表現なので分かりづらい 王永吉 end
              // add #6566 職種マスタ編集時に既存利用者への反映を確認するメッセージがOK_Cancelの表現なので分かりづらい 王永吉 start
              if (bvInfoJsonObj != null){
              // add #6566 職種マスタ編集時に既存利用者への反映を確認するメッセージがOK_Cancelの表現なので分かりづらい 王永吉 end
                if (bvInfoJsonObj.has("267") && "1".equals(bvInfoJsonObj.get("267"))) {
                  List<OrdMain> ordMainList = ordMainService.selectBySingleNeedle(facilityCd, loopPatId);
                  if (ordMainList.size() > 0) {
                    // mod #6566 職種マスタ編集時に既存利用者への反映を確認するメッセージがOK_Cancelの表現なので分かりづらい 王永吉 start
                  response.add("replenisherSingleNeedleBV");
//                    responseM.add("replenisherSingleNeedleBV");
                    // mod #6566 職種マスタ編集時に既存利用者への反映を確認するメッセージがOK_Cancelの表現なので分かりづらい 王永吉 end
                  }
                }
                if (bvInfoJsonObj.has("258") && "1".equals(bvInfoJsonObj.get("258"))) {
                  List<OrdMain> ordMainList = ordMainService.selectBySingleNeedle(facilityCd, loopPatId);
                  if (ordMainList.size() > 0) {
                    // mod #6566 職種マスタ編集時に既存利用者への反映を確認するメッセージがOK_Cancelの表現なので分かりづらい 王永吉 start
                  response.add("replenisherSingleNeedleCycle");
//                    responseM.add("replenisherSingleNeedleCycle");
                    // mod #6566 職種マスタ編集時に既存利用者への反映を確認するメッセージがOK_Cancelの表現なので分かりづらい 王永吉 end
                  }
                }
              // add #6566 職種マスタ編集時に既存利用者への反映を確認するメッセージがOK_Cancelの表現なので分かりづらい 王永吉 start
              }
              // add #6566 職種マスタ編集時に既存利用者への反映を確認するメッセージがOK_Cancelの表現なので分かりづらい 王永吉 end
            }
      //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 end
            // mod FNSi7137-装置設定が保存出来ない 周 end
            // add FNSi6002-補液速度操作範囲上限を超えて設定できる 周 end

            //add #10412 次患者更新関連全体見直し対応 朴 start
            PatMain beforePatMain = patMainDao.selectById(loopPatId);
            //add #10412 次患者更新関連全体見直し対応 朴 end

            deviceSetInfoService.updateDeviceSetInfoPat(loopPatId, facilityCd, deviceSetInfo);

            //add #10412 次患者更新関連全体見直し対応 朴 start
            PatMain afterPatMain = patMainDao.selectById(loopPatId);
            if(nextPatService.CheckDoCallNextPatChangeForPat(facilityCd, beforePatMain, afterPatMain, null, null)){
              patidListForCheckDoCallNextPat.add(loopPatId);
            }
            //add #10412 次患者更新関連全体見直し対応 朴 end

      // add #6566 職種マスタ編集時に既存利用者への反映を確認するメッセージがOK_Cancelの表現なので分かりづらい 王永吉 start
//            response.add(responseM);
//7810 mod 治療条件・装置設定変更時の動作不備（412.xlsx）張 end
      // #8061-装置設定が保存出来ない 周 20221115 del start
      // #8061-装置設定が保存出来ない 周 20221117 mod start
      //    }
      //  }
      //}
            //del #10412 次患者更新関連全体見直し対応 朴 start
//            //mod 7188 治療条件，装置設定を変更すると次患者が再送される start zhao
//            Double orgAfter5 = 0d;
//            Double orgAfter7 = 0d;
//            Double orgAfter8 = 0d;
//            Double orgAfter9 = 0d;
//            Double orgAfter10 = 0d;
//            Double orgAfter54 = 0d;
//            Double orgAfter55 = 0d;
//            Double orgAfter56 = 0d;
//            Double orgAfter57 = 0d;
//            Double orgAfter58 = 0d;
//            Double orgAfter59 = 0d;
//            Double dstBefore5 = 0d;
//            Double dstBefore7 = 0d;
//            Double dstBefore8 = 0d;
//            Double dstBefore9 = 0d;
//            Double dstBefore10 = 0d;
//            Double dstBefore54 = 0d;
//            Double dstBefore55 = 0d;
//            Double dstBefore56 = 0d;
//            Double dstBefore57 = 0d;
//            Double dstBefore58 = 0d;
//            Double dstBefore59 = 0d;
//            /* add #9684_#9690  by zhangruixue 2023-08-30 --start */
//            Double dstBefore1 = 0d;
//            Double orgAfter1 = 0d;
//            /* add #9684_#9690  by zhangruixue 2023-08-30 --end */
//
//            Double orgAfter32 = 0d;
//            Double orgAfter33 = 0d;
//            Double orgAfter51 = 0d;
//            Double orgAfter52 = 0d;
//            Double orgAfter53 = 0d;
//            Double dstBefore32 = 0d;
//            Double dstBefore33 = 0d;
//            Double dstBefore51 = 0d;
//            Double dstBefore52 = 0d;
//            Double dstBefore53 = 0d;
//            /* add #9684_#9690  by zhangruixue 2023-08-30 --start */
//            Double orgAfter219 = 0d;
//            Double orgAfter220 = 0d;
//            Double orgAfter221 = 0d;
//            Double orgAfter222 = 0d;
//            Double orgAfter223 = 0d;
//            Double orgAfter224 = 0d;
//            Double orgAfter225 = 0d;
//            Double orgAfter226 = 0d;
//            Double orgAfter227 = 0d;
//            Double orgAfter228 = 0d;
//            Double orgAfter229 = 0d;
//            Double orgAfter230 = 0d;
//            Double orgAfter231 = 0d;
//            Double orgAfter232 = 0d;
//            Double orgAfter233 = 0d;
//            Double orgAfter234 = 0d;
//            Double orgAfter235 = 0d;
//            Double orgAfter236 = 0d;
//            Double orgAfter237 = 0d;
//            Double orgAfter238 = 0d;
//
//            Double dstBefore219 = 0d;
//            Double dstBefore220 = 0d;
//            Double dstBefore221 = 0d;
//            Double dstBefore222 = 0d;
//            Double dstBefore223 = 0d;
//            Double dstBefore224 = 0d;
//            Double dstBefore225 = 0d;
//            Double dstBefore226 = 0d;
//            Double dstBefore227 = 0d;
//            Double dstBefore228 = 0d;
//            Double dstBefore229 = 0d;
//            Double dstBefore230 = 0d;
//            Double dstBefore231 = 0d;
//            Double dstBefore232 = 0d;
//            Double dstBefore233 = 0d;
//            Double dstBefore234 = 0d;
//            Double dstBefore235 = 0d;
//            Double dstBefore236 = 0d;
//            Double dstBefore237 = 0d;
//            Double dstBefore238 = 0d;
///*            219  プライミング補助　動脈充填液量
//            220  プライミング補助　動脈充填流速
//            225  プライミング補助　動脈充填後継続の有無
//            221  プライミング補助　静脈充填液量
//            222  プライミング補助　静脈充填流速
//            226  プライミング補助　静脈充填後継続の有無
//            223  プライミング補助　気泡抜き液量
//            224  プライミング補助　気泡抜き流速
//            227  プライミング補助　気泡抜き動作選択
//            228  プライミング補助　液交換量
//            229  プライミング補助　間欠動作動作時間
//            230  プライミング補助　間欠動作停止時間
//            231  自動プライミング　開始時刻
//            232  自動プライミング　落差時間
//            238  自動プライミング　総量
//            233  自動プライミング　送液流量
//            234  自動プライミング　送液流速（１回目）
//            235  自動プライミング　送液流速（２回目以降）
//            236  自動プライミング　循環流速
//            237  自動プライミング　循環時間
//            32    動脈チャンバ液面作成時間  前補液
//            33    循環洗浄時間  前補液
//            51    ダイアライザ気泡抜き時間 後補液
//            52    動脈チャンバ液面作成時間  後補液
//            53    循環洗浄時間 後補液*/
//            /* add #9684_#9690  by zhangruixue 2023-08-30 --end */
//
//            String dialyzerZ = "";
//            String dialyzerH = "";
//            //D-FAS
//            if (dstDeviceSetInfoJsonObj.has("dfas")) {
//              if (orgDeviceSetInfoObj.has("dfas")) {
//                JSONObject orgDfasObj = orgDeviceSetInfoObj.getJSONObject("dfas");
//                JSONObject orgDPatJsonObj = (null != orgDfasObj && orgDfasObj.has("pat")) ? orgDfasObj.getJSONObject("pat") : null;
//                JSONObject orgBJsonObj = (null != orgDPatJsonObj && orgDPatJsonObj.has("B")) ? orgDPatJsonObj.getJSONObject("B") : null;
//                if (orgBJsonObj != null) {
//                  /* add #9684_#9690  by zhangruixue 2023-08-30 --start */
//                  orgAfter1 = (orgBJsonObj.has("1")) ? ((null != orgBJsonObj.get("1")) ? Double.valueOf(orgBJsonObj.get("1").toString()) : 0) : 0;
//                  /* add #9684_#9690  by zhangruixue 2023-08-30 --end */
//                  orgAfter5 = (orgBJsonObj.has("5")) ? ((null != orgBJsonObj.get("5")) ? Double.valueOf(orgBJsonObj.get("5").toString()) : 0) : 0;
//                  orgAfter7 = (orgBJsonObj.has("7")) ? ((null != orgBJsonObj.get("7")) ? Double.valueOf(orgBJsonObj.get("7").toString()) : 0) : 0;
//                  orgAfter8 = (orgBJsonObj.has("8")) ? ((null != orgBJsonObj.get("8")) ? Double.valueOf(orgBJsonObj.get("8").toString()) : 0) : 0;
//                  orgAfter9 = (orgBJsonObj.has("9")) ? ((null != orgBJsonObj.get("9")) ? Double.valueOf(orgBJsonObj.get("9").toString()) : 0) : 0;
//                  orgAfter10 = (orgBJsonObj.has("10")) ? ((null != orgBJsonObj.get("10")) ? Double.valueOf(orgBJsonObj.get("10").toString()) : 0) : 0;
//                  orgAfter54 = (orgBJsonObj.has("54")) ? ((null != orgBJsonObj.get("54")) ? Double.valueOf(orgBJsonObj.get("54").toString()) : 0) : 0;
//                  orgAfter55 = (orgBJsonObj.has("55")) ? ((null != orgBJsonObj.get("55")) ? Double.valueOf(orgBJsonObj.get("55").toString()) : 0) : 0;
//                  orgAfter56 = (orgBJsonObj.has("56")) ? ((null != orgBJsonObj.get("56")) ? Double.valueOf(orgBJsonObj.get("56").toString()) : 0) : 0;
//                  orgAfter57 = (orgBJsonObj.has("57")) ? ((null != orgBJsonObj.get("57")) ? Double.valueOf(orgBJsonObj.get("57").toString()) : 0) : 0;
//                  orgAfter58 = (orgBJsonObj.has("58")) ? ((null != orgBJsonObj.get("58")) ? Double.valueOf(orgBJsonObj.get("58").toString()) : 0) : 0;
//                  orgAfter59 = (orgBJsonObj.has("59")) ? ((null != orgBJsonObj.get("59")) ? Double.valueOf(orgBJsonObj.get("59").toString()) : 0) : 0;
//                }
//              }
//
//              JSONObject dstPatObj = dstDeviceSetInfoJsonObj.getJSONObject("dfas");
//              JSONObject dstPatJsonObj = (null != dstPatObj && dstPatObj.has("pat")) ? dstPatObj.getJSONObject("pat") : null;
//              JSONObject dstBJsonObj = (null != dstPatJsonObj && dstPatJsonObj.has("B")) ? dstPatJsonObj.getJSONObject("B") : null;
//              if (dstBJsonObj != null) {
//                /* add #9684_#9690  by zhangruixue 2023-08-30 --start */
//                dstBefore1 = (dstBJsonObj.has("1")) ? ((null != dstBJsonObj.get("1")) ? Double.valueOf(dstBJsonObj.get("1").toString()) : 0) : 0;
//                /* add #9684_#9690  by zhangruixue 2023-08-30 --end */
//                dstBefore5 = (dstBJsonObj.has("5")) ? ((null != dstBJsonObj.get("5")) ? Double.valueOf(dstBJsonObj.get("5").toString()) : 0) : 0;
//                dstBefore7 = (dstBJsonObj.has("7")) ? ((null != dstBJsonObj.get("7")) ? Double.valueOf(dstBJsonObj.get("7").toString()) : 0) : 0;
//                dstBefore8 = (dstBJsonObj.has("8")) ? ((null != dstBJsonObj.get("8")) ? Double.valueOf(dstBJsonObj.get("8").toString()) : 0) : 0;
//                dstBefore9 = (dstBJsonObj.has("9")) ? ((null != dstBJsonObj.get("9")) ? Double.valueOf(dstBJsonObj.get("9").toString()) : 0) : 0;
//                dstBefore10 = (dstBJsonObj.has("10")) ? ((null != dstBJsonObj.get("10")) ? Double.valueOf(dstBJsonObj.get("10").toString()) : 0) : 0;
//                dstBefore54 = (dstBJsonObj.has("54")) ? ((null != dstBJsonObj.get("54")) ? Double.valueOf(dstBJsonObj.get("54").toString()) : 0) : 0;
//                dstBefore55 = (dstBJsonObj.has("55")) ? ((null != dstBJsonObj.get("55")) ? Double.valueOf(dstBJsonObj.get("55").toString()) : 0) : 0;
//                dstBefore56 = (dstBJsonObj.has("56")) ? ((null != dstBJsonObj.get("56")) ? Double.valueOf(dstBJsonObj.get("56").toString()) : 0) : 0;
//                dstBefore57 = (dstBJsonObj.has("57")) ? ((null != dstBJsonObj.get("57")) ? Double.valueOf(dstBJsonObj.get("57").toString()) : 0) : 0;
//                dstBefore58 = (dstBJsonObj.has("58")) ? ((null != dstBJsonObj.get("58")) ? Double.valueOf(dstBJsonObj.get("58").toString()) : 0) : 0;
//                dstBefore59 = (dstBJsonObj.has("59")) ? ((null != dstBJsonObj.get("59")) ? Double.valueOf(dstBJsonObj.get("59").toString()) : 0) : 0;
//                if ((orgAfter5.compareTo(dstBefore5) != 0) || (orgAfter7.compareTo(dstBefore7) != 0)
//                  || (orgAfter8.compareTo(dstBefore8) != 0) || (orgAfter9.compareTo(dstBefore9) != 0)
//                  || (orgAfter10.compareTo(dstBefore10) != 0)) {
//                  dialyzerZ = "p";
//                }
//                if ((orgAfter54.compareTo(dstBefore54) != 0) || (orgAfter55.compareTo(dstBefore55) != 0)
//                  || (orgAfter56.compareTo(dstBefore56) != 0) || (orgAfter57.compareTo(dstBefore57) != 0)
//                  || (orgAfter58.compareTo(dstBefore58) != 0) || (orgAfter59.compareTo(dstBefore59) != 0)) {
//                  dialyzerH = "d";
//                }
//                if (!"".equals(dialyzerZ) && !"".equals(dialyzerH)) {
//                  dialyzer = "pd";
//                } else if (!"".equals(dialyzerZ)) {
//                  dialyzer = "p";
//                } else if (!"".equals(dialyzerH)) {
//                  dialyzer = "d";
//                }
//                /* add #9684_#9690  by zhangruixue 2023-08-30 --start */
//                else if(orgAfter1.compareTo(dstBefore1) != 0){
//                  dialyzer = "pd";
//                }
//                /* add #9684_#9690  by zhangruixue 2023-08-30 --end */
//              }
//            }
//
//
//            //プライミング
//            if (dstDeviceSetInfoJsonObj.has("pri")) {
//              if (orgDeviceSetInfoObj.has("pri")) {
//                JSONObject orgPriObj = orgDeviceSetInfoObj.getJSONObject("pri");
//                JSONObject orgDPatJsonObj = (null != orgPriObj && orgPriObj.has("pat")) ? orgPriObj.getJSONObject("pat") : null;
//                JSONObject orgBJsonObj = (null != orgDPatJsonObj && orgDPatJsonObj.has("B")) ? orgDPatJsonObj.getJSONObject("B") : null;
//                JSONObject orgAJsonObj = (null != orgDPatJsonObj && orgDPatJsonObj.has("A")) ? orgDPatJsonObj.getJSONObject("A") : null;
//                if (orgBJsonObj != null) {
//                  orgAfter32 = (orgBJsonObj.has("32")) ? ((null != orgBJsonObj.get("32")) ? Double.valueOf(orgBJsonObj.get("32").toString()) : 0) : 0;
//                  orgAfter33 = (orgBJsonObj.has("33")) ? ((null != orgBJsonObj.get("33")) ? Double.valueOf(orgBJsonObj.get("33").toString()) : 0) : 0;
//                  orgAfter51 = (orgBJsonObj.has("51")) ? ((null != orgBJsonObj.get("51")) ? Double.valueOf(orgBJsonObj.get("51").toString()) : 0) : 0;
//                  orgAfter52 = (orgBJsonObj.has("52")) ? ((null != orgBJsonObj.get("52")) ? Double.valueOf(orgBJsonObj.get("52").toString()) : 0) : 0;
//                  orgAfter53 = (orgBJsonObj.has("53")) ? ((null != orgBJsonObj.get("53")) ? Double.valueOf(orgBJsonObj.get("53").toString()) : 0) : 0;
//                }
//                /* add #9684_#9690  by zhangruixue 2023-08-30 --start */
//                if(orgAJsonObj != null){
//                  orgAfter219 = (orgAJsonObj.has("219")) ? ((null != orgAJsonObj.get("219")) ? Double.valueOf(orgAJsonObj.get("219").toString()) : 0) : 0;
//                  orgAfter220 = (orgAJsonObj.has("220")) ? ((null != orgAJsonObj.get("220")) ? Double.valueOf(orgAJsonObj.get("220").toString()) : 0) : 0;
//                  orgAfter225 = (orgAJsonObj.has("225")) ? ((null != orgAJsonObj.get("225")) ? Double.valueOf(orgAJsonObj.get("225").toString()) : 0) : 0;
//                  orgAfter221 = (orgAJsonObj.has("221")) ? ((null != orgAJsonObj.get("221")) ? Double.valueOf(orgAJsonObj.get("221").toString()) : 0) : 0;
//                  orgAfter222 = (orgAJsonObj.has("222")) ? ((null != orgAJsonObj.get("222")) ? Double.valueOf(orgAJsonObj.get("222").toString()) : 0) : 0;
//                  orgAfter226 = (orgAJsonObj.has("226")) ? ((null != orgAJsonObj.get("226")) ? Double.valueOf(orgAJsonObj.get("226").toString()) : 0) : 0;
//                  orgAfter223 = (orgAJsonObj.has("223")) ? ((null != orgAJsonObj.get("223")) ? Double.valueOf(orgAJsonObj.get("223").toString()) : 0) : 0;
//                  orgAfter224 = (orgAJsonObj.has("224")) ? ((null != orgAJsonObj.get("224")) ? Double.valueOf(orgAJsonObj.get("224").toString()) : 0) : 0;
//                  orgAfter227 = (orgAJsonObj.has("227")) ? ((null != orgAJsonObj.get("227")) ? Double.valueOf(orgAJsonObj.get("227").toString()) : 0) : 0;
//                  orgAfter228 = (orgAJsonObj.has("228")) ? ((null != orgAJsonObj.get("228")) ? Double.valueOf(orgAJsonObj.get("228").toString()) : 0) : 0;
//                  orgAfter229 = (orgAJsonObj.has("229")) ? ((null != orgAJsonObj.get("229")) ? Double.valueOf(orgAJsonObj.get("229").toString()) : 0) : 0;
//                  orgAfter230 = (orgAJsonObj.has("230")) ? ((null != orgAJsonObj.get("230")) ? Double.valueOf(orgAJsonObj.get("230").toString()) : 0) : 0;
//                  orgAfter231 = (orgAJsonObj.has("231")) ? ((null != orgAJsonObj.get("231")) ? Double.valueOf(orgAJsonObj.get("231").toString()) : 0) : 0;
//                  orgAfter232 = (orgAJsonObj.has("232")) ? ((null != orgAJsonObj.get("232")) ? Double.valueOf(orgAJsonObj.get("232").toString()) : 0) : 0;
//                  orgAfter238 = (orgAJsonObj.has("238")) ? ((null != orgAJsonObj.get("238")) ? Double.valueOf(orgAJsonObj.get("238").toString()) : 0) : 0;
//                  orgAfter233 = (orgAJsonObj.has("233")) ? ((null != orgAJsonObj.get("233")) ? Double.valueOf(orgAJsonObj.get("233").toString()) : 0) : 0;
//                  orgAfter234 = (orgAJsonObj.has("234")) ? ((null != orgAJsonObj.get("234")) ? Double.valueOf(orgAJsonObj.get("234").toString()) : 0) : 0;
//                  orgAfter235 = (orgAJsonObj.has("235")) ? ((null != orgAJsonObj.get("235")) ? Double.valueOf(orgAJsonObj.get("235").toString()) : 0) : 0;
//                  orgAfter236 = (orgAJsonObj.has("236")) ? ((null != orgAJsonObj.get("236")) ? Double.valueOf(orgAJsonObj.get("236").toString()) : 0) : 0;
//                  orgAfter237 = (orgAJsonObj.has("237")) ? ((null != orgAJsonObj.get("237")) ? Double.valueOf(orgAJsonObj.get("237").toString()) : 0) : 0;
//                }
//                /* add #9684_#9690  by zhangruixue 2023-08-30 --end */
//              }
//              JSONObject dstPriObj = dstDeviceSetInfoJsonObj.getJSONObject("pri");
//              JSONObject dstPatJsonObj = (null != dstPriObj && dstPriObj.has("pat")) ? dstPriObj.getJSONObject("pat") : null;
//              JSONObject dstBJsonObj = (null != dstPatJsonObj && dstPatJsonObj.has("B")) ? dstPatJsonObj.getJSONObject("B") : null;
//              JSONObject dstAJsonObj = (null != dstPatJsonObj && dstPatJsonObj.has("A")) ? dstPatJsonObj.getJSONObject("A") : null;
//              /* add #9684_#9690  by zhangruixue 2023-08-30 --start */
//              if (dstAJsonObj != null) {
//                dstBefore219 = (dstAJsonObj.has("219")) ? ((null != dstAJsonObj.get("219")) ? Double.valueOf(dstAJsonObj.get("219").toString()) : 0) : 0;
//                dstBefore220 = (dstAJsonObj.has("220")) ? ((null != dstAJsonObj.get("220")) ? Double.valueOf(dstAJsonObj.get("220").toString()) : 0) : 0;
//                dstBefore225 = (dstAJsonObj.has("225")) ? ((null != dstAJsonObj.get("225")) ? Double.valueOf(dstAJsonObj.get("225").toString()) : 0) : 0;
//                dstBefore221 = (dstAJsonObj.has("221")) ? ((null != dstAJsonObj.get("221")) ? Double.valueOf(dstAJsonObj.get("221").toString()) : 0) : 0;
//                dstBefore222 = (dstAJsonObj.has("222")) ? ((null != dstAJsonObj.get("222")) ? Double.valueOf(dstAJsonObj.get("222").toString()) : 0) : 0;
//                dstBefore226 = (dstAJsonObj.has("226")) ? ((null != dstAJsonObj.get("226")) ? Double.valueOf(dstAJsonObj.get("226").toString()) : 0) : 0;
//                dstBefore223 = (dstAJsonObj.has("223")) ? ((null != dstAJsonObj.get("223")) ? Double.valueOf(dstAJsonObj.get("223").toString()) : 0) : 0;
//                dstBefore224 = (dstAJsonObj.has("224")) ? ((null != dstAJsonObj.get("224")) ? Double.valueOf(dstAJsonObj.get("224").toString()) : 0) : 0;
//                dstBefore227 = (dstAJsonObj.has("227")) ? ((null != dstAJsonObj.get("227")) ? Double.valueOf(dstAJsonObj.get("227").toString()) : 0) : 0;
//                dstBefore228 = (dstAJsonObj.has("228")) ? ((null != dstAJsonObj.get("228")) ? Double.valueOf(dstAJsonObj.get("228").toString()) : 0) : 0;
//                dstBefore229 = (dstAJsonObj.has("229")) ? ((null != dstAJsonObj.get("229")) ? Double.valueOf(dstAJsonObj.get("229").toString()) : 0) : 0;
//                dstBefore230 = (dstAJsonObj.has("230")) ? ((null != dstAJsonObj.get("230")) ? Double.valueOf(dstAJsonObj.get("230").toString()) : 0) : 0;
//                dstBefore231 = (dstAJsonObj.has("231")) ? ((null != dstAJsonObj.get("231")) ? Double.valueOf(dstAJsonObj.get("231").toString()) : 0) : 0;
//                dstBefore232 = (dstAJsonObj.has("232")) ? ((null != dstAJsonObj.get("232")) ? Double.valueOf(dstAJsonObj.get("232").toString()) : 0) : 0;
//                dstBefore238 = (dstAJsonObj.has("238")) ? ((null != dstAJsonObj.get("238")) ? Double.valueOf(dstAJsonObj.get("238").toString()) : 0) : 0;
//                dstBefore233 = (dstAJsonObj.has("233")) ? ((null != dstAJsonObj.get("233")) ? Double.valueOf(dstAJsonObj.get("233").toString()) : 0) : 0;
//                dstBefore234 = (dstAJsonObj.has("234")) ? ((null != dstAJsonObj.get("234")) ? Double.valueOf(dstAJsonObj.get("234").toString()) : 0) : 0;
//                dstBefore235 = (dstAJsonObj.has("235")) ? ((null != dstAJsonObj.get("235")) ? Double.valueOf(dstAJsonObj.get("235").toString()) : 0) : 0;
//                dstBefore236 = (dstAJsonObj.has("236")) ? ((null != dstAJsonObj.get("236")) ? Double.valueOf(dstAJsonObj.get("236").toString()) : 0) : 0;
//                dstBefore237 = (dstAJsonObj.has("237")) ? ((null != dstAJsonObj.get("237")) ? Double.valueOf(dstAJsonObj.get("237").toString()) : 0) : 0;
//              }
//              /* add #9684_#9690  by zhangruixue 2023-08-30 --end */
//              if (dstBJsonObj != null) {
//                dstBefore32 = (dstBJsonObj.has("32")) ? ((null != dstBJsonObj.get("32")) ? Double.valueOf(dstBJsonObj.get("32").toString()) : 0) : 0;
//                dstBefore33 = (dstBJsonObj.has("33")) ? ((null != dstBJsonObj.get("33")) ? Double.valueOf(dstBJsonObj.get("33").toString()) : 0) : 0;
//                dstBefore51 = (dstBJsonObj.has("51")) ? ((null != dstBJsonObj.get("51")) ? Double.valueOf(dstBJsonObj.get("51").toString()) : 0) : 0;
//                dstBefore52 = (dstBJsonObj.has("52")) ? ((null != dstBJsonObj.get("52")) ? Double.valueOf(dstBJsonObj.get("52").toString()) : 0) : 0;
//                dstBefore53 = (dstBJsonObj.has("53")) ? ((null != dstBJsonObj.get("53")) ? Double.valueOf(dstBJsonObj.get("53").toString()) : 0) : 0;
//                String gridCellQ = "";
//                String gridCellH = "";
//                if ((orgAfter32.compareTo(dstBefore32) != 0) || (orgAfter33.compareTo(dstBefore33) != 0)) {
//                  gridCellQ = "q";
//                }
//                if ((orgAfter51.compareTo(dstBefore51) != 0) || (orgAfter52.compareTo(dstBefore52) != 0)|| (orgAfter53.compareTo(dstBefore53) != 0)) {
//                  gridCellH = "h";
//                }
//                /* mod #9684_#9690  by zhangruixue 2023-08-30 --start */
//                if (!"".equals(gridCellQ) && !"".equals(gridCellH)) {
//                  gridCell = "hq";
//                } else if (!"".equals(gridCellQ)) {
//                  gridCell = "q";
//                } else if (!"".equals(gridCellH)) {
//                  gridCell = "h";
//                }
//                else if((orgAfter219.compareTo(dstBefore219) != 0) || (orgAfter220.compareTo(dstBefore220) != 0)
//                  || (orgAfter221.compareTo(dstBefore221) != 0) || (orgAfter222.compareTo(dstBefore222) != 0)
//                  || (orgAfter223.compareTo(dstBefore223) != 0) || (orgAfter224.compareTo(dstBefore224) != 0)
//                  || (orgAfter225.compareTo(dstBefore225) != 0) || (orgAfter226.compareTo(dstBefore226) != 0)
//                  || (orgAfter227.compareTo(dstBefore227) != 0) || (orgAfter228.compareTo(dstBefore228) != 0)
//                  || (orgAfter229.compareTo(dstBefore229) != 0) || (orgAfter230.compareTo(dstBefore230) != 0)
//                  || (orgAfter231.compareTo(dstBefore231) != 0) || (orgAfter232.compareTo(dstBefore232) != 0)
//                  || (orgAfter233.compareTo(dstBefore233) != 0) || (orgAfter234.compareTo(dstBefore234) != 0)
//                  || (orgAfter235.compareTo(dstBefore235) != 0) || (orgAfter236.compareTo(dstBefore236) != 0)
//                  || (orgAfter237.compareTo(dstBefore237) != 0) || (orgAfter238.compareTo(dstBefore238) != 0)){
//                  gridCell = "hq";
//                }
//                /* mod #9684_#9690  by zhangruixue 2023-08-30 --end */
//              }
//            }
//            //add 7188 治療条件，装置設定を変更すると次患者が再送される end zhao
            //del #10412 次患者更新関連全体見直し対応 朴 end
          }
        }
      }
      //add #10632 装置設定画面の更新時にpat_main_historyがインサートされない 20240530 ztc start
      patMainDeviceSetInfoService.insertPatMainHistoryByPatIdFacilityCd(facilityCd, patId);
      //add #10632 装置設定画面の更新時にpat_main_historyがインサートされない 20240530 ztc end
      // #8061-装置設定が保存出来ない 周 20221117 mod end
      // #8061-装置設定が保存出来ない 周 20221115 del end
      // add #6566 職種マスタ編集時に既存利用者への反映を確認するメッセージがOK_Cancelの表現なので分かりづらい 王永吉 end
      // mod #7188 2023/01/14 治療条件，装置設定を変更すると次患者が再送される dou start
      //mod 7188 治療条件，装置設定を変更すると次患者が再送される start zhao
      if (payload.containsKey("nextPatInfoType") && (dstDeviceSetInfoJsonObj.has("pri") || (dstDeviceSetInfoJsonObj.has("dfas")))) {
        //mod #10412 次患者更新関連全体見直し対応 朴 start
//        callDoCancelSetNextPatInfo(facilityCd, patId,dialyzer,gridCell);

        if (patidListForCheckDoCallNextPat != null && !patidListForCheckDoCallNextPat.isEmpty()) {
          List<MntMachineState> mntMachineStateList = mntMachineStateDao.selectByNextPatIdList(facilityCd, patidListForCheckDoCallNextPat);
          List<Long> ordNoList = mntMachineStateList.stream().map(item -> item.getNextOrdNo()).distinct().collect(Collectors.toList());
          List<OrdMain> ordMainList = ordMainDao.selectByOrdNoList(ordNoList);
          nextPatService.CallNextPatChange(facilityCd, ordMainList);
        }
        //mod #10412 次患者更新関連全体見直し対応 朴 end
      }
      //mod 7188 治療条件，装置設定を変更すると次患者が再送される end zhao
      // mod #7188 2023/01/14 治療条件，装置設定を変更すると次患者が再送される dou end

      // add FNSi6002-補液速度操作範囲上限を超えて設定できる 周 start
      // add FNSi7137-装置設定が保存出来ない 周 start
//      if(dstDeviceSetInfoJsonObj.has("ope")) {
//      // add FNSi7137-装置設定が保存出来ない 周 end
//        if(isNeedCheck) {
//          List<OrdMain> futureScheduleList = ordMainService.selectFutureScheduleByDateCd(facilityCd, patId);
//          if(null != futureScheduleList && !futureScheduleList.isEmpty()) {
//            boolean isOver = false;
//            for(OrdMain om : futureScheduleList) {
//              if(isOver) {
//                break;
//              }
//              int indTreatmentCd = om.getIndTreatmentCd();
//              String omIndCondInfo = om.getIndCondInfo();
//              JSONObject omDeviceSetInfoJsonObj = new JSONObject(omIndCondInfo);
//              JSONObject treatInfo = omDeviceSetInfoJsonObj.getJSONObject("24");
//              Double treatInfoValue = Double.parseDouble(treatInfo.get("value").toString());
//
//              List<MstTreatmentSet> mstTreatmentSetList = mstInfoService.findMstTreatmentSetByCd(indTreatmentCd);
//              if(null != mstTreatmentSetList && !mstTreatmentSetList.isEmpty()) {
//                for (MstTreatmentSet mts :mstTreatmentSetList) {
//                  if(null != mts.getTreatmentSetName()) {
//                    if(mts.getTreatmentSetName().contains("OHDF")
//                      && ((dstBeforeOHDF.compareTo(treatInfoValue) < 0) || (dstAfterOHDF.compareTo(treatInfoValue) < 0))) {
//                      response.add("replenisherSpeed");
//                      isOver = true;
//                      break;
//                    }else if(mts.getTreatmentSetName().contains("OHF")
//                      && ((dstBeforeOHF.compareTo(treatInfoValue) < 0) || (dstAfterOHF.compareTo(treatInfoValue) < 0))) {
//                      response.add("replenisherSpeed");
//                      isOver = true;
//                      break;
//                    }else if(mts.getTreatmentSetName().contains("HDF")
//                      && ((dstBeforeHDF.compareTo(treatInfoValue) < 0) || (dstAfterHDF.compareTo(treatInfoValue) < 0))) {
//                      response.add("replenisherSpeed");
//                      isOver = true;
//                      break;
//                    }else if(mts.getTreatmentSetName().contains("HF")
//                      && ((dstBeforeHF.compareTo(treatInfoValue) < 0) || (dstAfterHF.compareTo(treatInfoValue) < 0))) {
//                      response.add("replenisherSpeed");
//                      isOver = true;
//                      break;
//                    }
//                  }
//                }
//              }
//            }
//          }
//        }
//      }
      // add FNSi6002-補液速度操作範囲上限を超えて設定できる 周 end

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_INFO, mappingUrl, null,
        payload);
      // wp アプリケーションログの適正化 Add End

// mod 10864 装置設定を編集して保存後に表示される注意喚起メッセージのOKを編集箇所の数だけ押下する必要がある 張玲 start
      // return new ResponseEntity<>(response, HttpStatus.OK);
      return new ResponseEntity<>(new ArrayList<>(response), HttpStatus.OK);
// mod 10864 装置設定を編集して保存後に表示される注意喚起メッセージのOKを編集箇所の数だけ押下する必要がある 張玲 end
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(true, HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 装置設定(指示)更新
   * @param ord_no
   * @return 装置設定JSON
   */

  /*
  @PostMapping("/updateDeviceSetInfoOrd/{ord_no}")
  public ResponseEntity<Void> updateDeviceSetInfoOrd(@PathVariable Long ord_no, @RequestBody Map<String, String> payload) {
    String deviceSetInfo = payload.get("deviceSetInfo");
    try {
      deviceSetInfoService.updateDeviceSetInfoOrd(ord_no, deviceSetInfo);
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_BBS_INFO, SERVICE_NAME.FNW, null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  */

  /**
   * 装置設定(指示)更新
   * @return 装置設定JSON
   */
  @PostMapping("updateDeviceSetInfoOrd")
  public ResponseEntity<String> updateDeviceSetInfoOrd(
      @Validated @RequestBody ApiEntityDeviceSetInfo.ValiDeviceSetInfo bodyData ,BindingResult validationResult
  ,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) throws URISyntaxException,JSONException,ArrayIndexOutOfBoundsException,NullPointerException {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
        String facilityCd = bodyData.getFacility_cd();
        if (facilityCd != null && !facilityCd.isEmpty() &&
          !facilityCd.equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " " + "pat_id=" + bodyData.getPat_id() + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_SET_INFO + "/updateDeviceSetInfoOrd";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    // 患者ID
    Long patId = Long.parseLong(bodyData.getPat_id());
    // 施設コード
    String facilityCd = bodyData.getFacility_cd();
    // 治療開始日
    String startDate = bodyData.getStart_date().replaceAll("-", "");
    // 治療終了日
    String endDate = bodyData.getEnd_date().replaceAll("-", "");
    // 治療曜日リスト
    List<Integer> treatWeekList = this.getWeekPattern(bodyData.getWeeks());
    // 治療方法リスト
    List<Integer> treatmentList = this.getValueList(bodyData.getInd_treatment_cd());
    // クールリスト
    List<Long> kurList = this.getLongList(bodyData.getInd_kur_cd());

    List<OrdMain> ordMain = new ArrayList();

    Timestamp up_date = Timestamp.valueOf(LocalDateTime.now());
   //add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 start

    /* del by KongShuai  2023-02-01 CodeOptimization start */
//    List<MstTreatment> mstTreatList = treatmentList.stream().map(treatCd -> mstTreatmentDao.selectByCd(treatCd)).collect(Collectors.toList());
    /* del by KongShuai  2023-02-01 CodeOptimization end */
    // シングルニードル取得
    String singleNeedle = "";
    // 戻り値情報
    JSONObject responseData = new JSONObject("{}");
    String imageFlg = bodyData.getImage_flg();
    //7810 mod 治療条件・装置設定変更時の動作不備（412.xlsx）張 start
    JSONObject ordnewTmp = new JSONObject(bodyData.getInd_device_set_info());
   //add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 end
    // 更新対象の治療情報を取得
    try {
      ordMain = ordMainService.findUpdateTarget(
        patId,
        facilityCd,
        startDate,
        endDate,
        treatWeekList,
        treatmentList,
        kurList
      );
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
    }

    //add #10266  start
    if("2".equals(bodyData.getUpdate_flag())){
      ordMain = ordMain.stream().filter(ord -> "0".equals(ord.getRstDialysisState())).collect(Collectors.toList());
    }
    //add #10266  end

    // 治療情報の更新
    try {
      /* modify by KongShuai  2023-02-01 CodeOptimization start */
//      //add 7809 濃度プログラムとNa注入プログラムを同時にONにしようとした際の動作不正 張 start region
//      Set<String> msglist = new HashSet<>();
//      //add 7809 濃度プログラムとNa注入プログラムを同時にONにしようとした際の動作不正 張 start
//      for (int i = 0; i < ordMain.size(); i++) {
//        //add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 start
//        // 治療情報を取得
//        OrdMain ord= ordMain.get(i);
//        // 治療情報を取得
//        JSONObject indDeviceSetInfoDefault = new JSONObject();
//
//        // 装置設定情報を取得(装置設定デフォルトマスタ)
//        String bufDefault = deviceSetInfoService.getDeviceSetInfoOrd(ordMain.get(i).getOrdNo());
//        indDeviceSetInfoDefault = (bufDefault == null || bufDefault.isEmpty()) ?
//                new JSONObject() :
//                new JSONObject(bufDefault);
//        bodyData.setInd_device_set_info(ordnewTmp.toString());
//        // BV-UFC
//        JSONObject ordnew = new JSONObject(bodyData.getInd_device_set_info());
//        JSONObject bvufc = (!indDeviceSetInfoDefault.has("bvufc")) ? null : new JSONObject(indDeviceSetInfoDefault.get("bvufc").toString());
//        JSONObject bvufcDev = (bvufc == null || !bvufc.has("dev")) ? null : new JSONObject(bvufc.get("dev").toString());
//        JSONObject bvufcInfo = (bvufcDev == null || !bvufcDev.has("A")) ? null : new JSONObject(bvufcDev.get("A").toString());
//
//        // 除水プログラム
//        JSONObject ufr = (!indDeviceSetInfoDefault.has("ufr")) ? null : new JSONObject(indDeviceSetInfoDefault.get("ufr").toString());
//        JSONObject ufrDev = (ufr == null || !ufr.has("dev")) ? null : new JSONObject(ufr.get("dev").toString());
//        JSONObject ufrInfo = (ufrDev == null || !ufrDev.has("A")) ? null : new JSONObject(ufrDev.get("A").toString());
//        // 透析液濃度プログラム
//        JSONObject dc = (!indDeviceSetInfoDefault.has("dc")) ? null : new JSONObject(indDeviceSetInfoDefault.get("dc").toString());
//        JSONObject dcDev = (dc == null || !dc.has("dev")) ? null : new JSONObject(dc.get("dev").toString());
//        JSONObject dcInfo = (dcDev == null || !dcDev.has("A")) ? null : new JSONObject(dcDev.get("A").toString());
//        // Ｎａ注入プログラム
//        JSONObject na = (!indDeviceSetInfoDefault.has("na")) ? null : new JSONObject(indDeviceSetInfoDefault.get("na").toString());
//        JSONObject naDev = (na == null || !na.has("dev")) ? null : new JSONObject(na.get("dev").toString());
//        JSONObject naA = (naDev == null || !naDev.has("A")) ? null : new JSONObject(naDev.get("A").toString());
//        // 血流量・透析液流量プログラム
//        JSONObject qbqd = (!indDeviceSetInfoDefault.has("qbqd")) ? null : new JSONObject(indDeviceSetInfoDefault.get("qbqd").toString());
//        JSONObject qbqdDev = (qbqd == null || !qbqd.has("dev")) ? null : new JSONObject(qbqd.get("dev").toString());
//        JSONObject qbqdA = (qbqdDev == null || !qbqdDev.has("dev")) ? null : new JSONObject(qbqdDev.get("A").toString());
//        //add 7809 濃度プログラムとNa注入プログラムを同時にONにしようとした際の動作不正 張 start
//        if(mstTreatList.size()==0){
//          SelectOptions selectOptions = SelectOptions.get();
//          MstTreatment params = new MstTreatment();
//          params.setFacilityCd(facilityCd);
//          mstTreatList=mstTreatmentDao.selectAll(selectOptions,params);
//        }
//        //add 7809 濃度プログラムとNa注入プログラムを同時にONにしようとした際の動作不正 張 end
//        for (MstTreatment mstTreat : mstTreatList) {
//          if(mstTreat.getTreatmentCd().equals(ordMain.get(i).getIndTreatmentCd())){
//            if ("2".equals(imageFlg)  && ((AdminWebConstant.Treatment.DeviceMode.HDF.equals(mstTreat.getDeviceMode()) ||
//                    AdminWebConstant.Treatment.DeviceMode.HF.equals(mstTreat.getDeviceMode()) ||
//                    AdminWebConstant.Treatment.DeviceMode.OHDF.equals(mstTreat.getDeviceMode()) ||
//                    AdminWebConstant.Treatment.DeviceMode.OHF.equals(mstTreat.getDeviceMode()) ||
//                    AdminWebConstant.Treatment.DeviceMode.AFBF.equals(mstTreat.getDeviceMode())))) {
//              //HD/ECUMのECUMがある場合は切替をHDに強制変更。警告メッセージ
//              //    0: "HD",  1: "ECUM"
//              JSONObject ufrord =  (ordnew == null || !ordnew.has("ufr")) ? null : new JSONObject(ordnew.get("ufr").toString());
//              JSONObject ufrordDev = (ufrord == null || !ufrord.has("dev")) ? null : new JSONObject(ufrord.get("dev").toString());
//              JSONObject ufrordInfo = (ufrordDev == null || !ufrordDev.has("A")) ? null : new JSONObject(ufrordDev.get("A").toString());
//              for (int j = 291; j <= 300; j++) {
//                if (ufrordInfo != null && ufrordInfo.has(String.valueOf(j))) {
//                  if ("1".equals(ufrordInfo.get(String.valueOf(j)))) {
//                    msglist.add("12000032");
//                    indDeviceSetInfoDefault.put("ufr", ufr);
//                    //7810 add 治療条件・装置設定変更時の動作不備（412.xlsx）張 start
//                    ordnew.put("ufr",ufr);
//                    //7810 add 治療条件・装置設定変更時の動作不備（412.xlsx）張 end
//                    bodyData.setInd_device_set_info(indDeviceSetInfoDefault.toString());
//                    break;
//                  }
//                }
//              }
//            }
//            if (!msglist.contains("12000032")) {
//              if ("4".equals(imageFlg) && (AdminWebConstant.Treatment.DeviceMode.HD.equals(mstTreat.getDeviceMode()) ||
//                      AdminWebConstant.Treatment.DeviceMode.ECUM.equals(mstTreat.getDeviceMode()) ||
//                      AdminWebConstant.Treatment.DeviceMode.HDF.equals(mstTreat.getDeviceMode()) ||
//                      AdminWebConstant.Treatment.DeviceMode.HF.equals(mstTreat.getDeviceMode()) ||
//                      AdminWebConstant.Treatment.DeviceMode.OHDF.equals(mstTreat.getDeviceMode()) ||
//                      AdminWebConstant.Treatment.DeviceMode.OHF.equals(mstTreat.getDeviceMode()) ||
//                      AdminWebConstant.Treatment.DeviceMode.AFBF.equals(mstTreat.getDeviceMode()))) {
//                if (ufrInfo != null && ufrInfo.has("290")) {
//                  if (!"0".equals(ufrInfo.get("290").toString())) {
//                    //mod FNSI-7295 劉全航 start
//                    JSONObject bvufcJson = new JSONObject(ordnew.get("bvufc").toString());
//                    JSONObject devJson = new JSONObject(bvufcJson.get("dev").toString());
//                    JSONObject aJSON = new JSONObject(devJson.get("A").toString());
//                    if (!aJSON.get("196").equals("0")) {
//                      msglist.add("12000041");
//                      //mod 8053 患者経過総合ビューアにて除水プログラムとBV-UFCを両方入りに出来る 張 start
//                    }
//
//                    //mod 8053 患者経過総合ビューアにて除水プログラムとBV-UFCを両方入りに出来る 張 end
//                    //mod FNSI-7295 劉全航 end
////                msglist.add("12000041");
//                  }
//                }
//              }
//              if ("2".equals(imageFlg) && (AdminWebConstant.Treatment.DeviceMode.HD.equals(mstTreat.getDeviceMode()) ||
//                      AdminWebConstant.Treatment.DeviceMode.ECUM.equals(mstTreat.getDeviceMode()) ||
//                      AdminWebConstant.Treatment.DeviceMode.HDF.equals(mstTreat.getDeviceMode()) ||
//                      AdminWebConstant.Treatment.DeviceMode.HF.equals(mstTreat.getDeviceMode()) ||
//                      AdminWebConstant.Treatment.DeviceMode.OHDF.equals(mstTreat.getDeviceMode()) ||
//                      AdminWebConstant.Treatment.DeviceMode.OHF.equals(mstTreat.getDeviceMode()) ||
//                      AdminWebConstant.Treatment.DeviceMode.AFBF.equals(mstTreat.getDeviceMode()))) {
//                // 8.BV-UFC、ONの場合は強制的にOFFに変更する。
//                if (bvufcInfo != null && bvufcInfo.has("196")) {
//                  if (!"0".equals(bvufcInfo.get("196").toString())) {
//                    //mod 8053 患者経過総合ビューアにて除水プログラムとBV-UFCを両方入りに出来る 張 start
//                    JSONObject ufrJson = new JSONObject(ordnew.get("ufr").toString());
//                    JSONObject devJson = new JSONObject(ufrJson.get("dev").toString());
//                    JSONObject aJSON = new JSONObject(devJson.get("A").toString());
//                    if (ufrJson != null && aJSON.has("290")) {
//                      if (!"0".equals(aJSON.get("290").toString())) {
//                        msglist.add("12000031");
//                        //add 7295除水プログラムONの時にBV-UFCがONにできてしまう 張 start
//                        //mod 6925
////                if( AdminWebConstant.Treatment.DeviceMode.HDF.equals(mstTreat.getDeviceMode()) ||
////                  AdminWebConstant.Treatment.DeviceMode.HF.equals(mstTreat.getDeviceMode()) ||
////                  AdminWebConstant.Treatment.DeviceMode.OHDF.equals(mstTreat.getDeviceMode()) ||
////                  AdminWebConstant.Treatment.DeviceMode.OHF.equals(mstTreat.getDeviceMode()) ||
////                  AdminWebConstant.Treatment.DeviceMode.AFBF.equals(mstTreat.getDeviceMode())) {
////                  indDeviceSetInfoDefault.put("ufr", ufr.put("dev", ufrDev.put("A", ufrInfo.put("290", "1"))));
////                }else {
////                }
//                        //mod 6925
//                      }
//                      indDeviceSetInfoDefault.put("ufr", ufrJson);
//                      bodyData.setInd_device_set_info(indDeviceSetInfoDefault.toString());
//                    }
//                    //mod 8053 患者経過総合ビューアにて除水プログラムとBV-UFCを両方入りに出来る 張 end
//                    //add 7295除水プログラムONの時にBV-UFCがONにできてしまう 張 end
//                  }
//                }
//              }
//            }
//            if( "0".equals(imageFlg)  && ((AdminWebConstant.Treatment.DeviceMode.HD.equals(mstTreat.getDeviceMode()) ||
//                    AdminWebConstant.Treatment.DeviceMode.ECUM.equals(mstTreat.getDeviceMode()) ||
//                    AdminWebConstant.Treatment.DeviceMode.HDF.equals(mstTreat.getDeviceMode()) ||
//                    AdminWebConstant.Treatment.DeviceMode.HF.equals(mstTreat.getDeviceMode()) ||
//                    AdminWebConstant.Treatment.DeviceMode.OHDF.equals(mstTreat.getDeviceMode()) ||
//                    AdminWebConstant.Treatment.DeviceMode.OHF.equals(mstTreat.getDeviceMode()) ||
//                    AdminWebConstant.Treatment.DeviceMode.AFBF.equals(mstTreat.getDeviceMode()) ||
//                    AdminWebConstant.Treatment.DeviceMode.I_HDF.equals(mstTreat.getDeviceMode())))) {
//              JSONObject NAord = (ordnew == null || !ordnew.has("na")) ? null : new JSONObject(ordnew.get("na").toString());
//              JSONObject NADev = (NAord == null || !NAord.has("dev")) ? null : new JSONObject(NAord.get("dev").toString());
//              JSONObject NAa = (NADev == null || !NADev.has("A")) ? null : new JSONObject(NADev.get("A").toString());
//              if (dcInfo != null && dcInfo.has("340") && NAa != null && NAa.has("315")) {
//                if (!"0".equals(dcInfo.get("340").toString())
//                        && !"0".equals(NAa.get("315").toString())) {
//                  //mod FNSI-7287 劉全航 start
////                msglist.add("12000035");
//                  msglist.add("12000054");
//                }
//                indDeviceSetInfoDefault.put("na", NAord);
//                bodyData.setInd_device_set_info(indDeviceSetInfoDefault.toString());
//                //mod FNSI-7287 劉全航 end
//              }
//            }
//            if( "1".equals(imageFlg)  && (AdminWebConstant.Treatment.DeviceMode.HD.equals(mstTreat.getDeviceMode()) ||
//                    AdminWebConstant.Treatment.DeviceMode.ECUM.equals(mstTreat.getDeviceMode()) ||
//                    AdminWebConstant.Treatment.DeviceMode.HDF.equals(mstTreat.getDeviceMode()) ||
//                    AdminWebConstant.Treatment.DeviceMode.HF.equals(mstTreat.getDeviceMode()) ||
//                    AdminWebConstant.Treatment.DeviceMode.OHDF.equals(mstTreat.getDeviceMode()) ||
//                    AdminWebConstant.Treatment.DeviceMode.OHF.equals(mstTreat.getDeviceMode()) ||
//                    AdminWebConstant.Treatment.DeviceMode.I_HDF.equals(mstTreat.getDeviceMode()))) {
//              JSONObject dcord = !ordnew.has("dc") ? null : new JSONObject(ordnew.get("dc").toString());
//              JSONObject dcordDev = (dcord == null || !dcord.has("dev")) ? null : new JSONObject(dcord.get("dev").toString());
//              JSONObject dcordInfo = (dcordDev == null || !dcordDev.has("A")) ? null : new JSONObject(dcordDev.get("A").toString());
//              if (dcordInfo != null && dcordInfo.has("340") && naA != null && naA.has("315")) {
//                if (!"0".equals(dcordInfo.get("340").toString())
//                        && !"0".equals(naA.get("315").toString())) {
//                  //mod FNSI-7287 劉全航 start
////                msglist.add("12000036");
//                  msglist.add("12000053");
//                }
//                indDeviceSetInfoDefault.put("dc", dcord);
//                bodyData.setInd_device_set_info(indDeviceSetInfoDefault.toString());
//                //mod FNSI-7287 劉全航 end
//              }
//            }
//            JSONObject indCondInfo = null == ord.getIndCondInfo() ?
//                    new JSONObject() :
//                    new JSONObject(ord.getIndCondInfo());
//            singleNeedle = (null == indCondInfo.getJSONObject("12").get("value")) ? ""
//                    : indCondInfo.getJSONObject("12").get("value").toString();
//            //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 start
//            if(AdminWebConstant.Treatment.DeviceMode.HD.equals(mstTreat.getDeviceMode()) ||
//                    AdminWebConstant.Treatment.DeviceMode.ECUM.equals(mstTreat.getDeviceMode())){
//              // 透析量プログラム
//              JSONObject dia = (!ordnew.has("dia")) ? null :new JSONObject(ordnew.get("dia").toString());
//              JSONObject diaDev = (dia == null || !dia.has("dev")) ? null : new JSONObject(dia.get("dev").toString());
//              JSONObject diaInfo =(diaDev == null || !diaDev.has("A")) ? null :  new JSONObject(diaDev.get("A").toString());
//              //透析量プログラムを使用する予定が含まれている場合、シングルニードル使用するを展開する際は警告。警告。
//              if (diaInfo!=null&&! "0".equals(diaInfo.get("282").toString()) && "1".equals(singleNeedle)) {
//                msglist.add("12000083");
//              }
//            }
//            if(AdminWebConstant.Treatment.DeviceMode.HDF.equals(mstTreat.getDeviceMode()) ||
//                    AdminWebConstant.Treatment.DeviceMode.HF.equals(mstTreat.getDeviceMode()) ||
//                    AdminWebConstant.Treatment.DeviceMode.OHDF.equals(mstTreat.getDeviceMode()) ||
//                    AdminWebConstant.Treatment.DeviceMode.OHF.equals(mstTreat.getDeviceMode()) ||
//                    AdminWebConstant.Treatment.DeviceMode.AFBF.equals(mstTreat.getDeviceMode()) ||
//                    AdminWebConstant.Treatment.DeviceMode.I_HDF.equals(mstTreat.getDeviceMode())||
//                    AdminWebConstant.Treatment.DeviceMode.PURIFICATION.equals(mstTreat.getDeviceMode())){
//              // 透析量プログラム
//              JSONObject dia = (!ordnew.has("dia")) ? null :new JSONObject(ordnew.get("dia").toString());
//              JSONObject diaDev = (dia == null || !dia.has("dev")) ? null : new JSONObject(dia.get("dev").toString());
//              JSONObject diaInfo =(diaDev == null || !diaDev.has("A")) ? null :  new JSONObject(diaDev.get("A").toString());
//              //透析量プログラムを使用する予定が含まれている場合、シングルニードル使用するを展開する際は警告。警告。
//              if (diaInfo!=null&&!"0".equals(diaInfo.get("282").toString())) {
//                diaInfo.put("282","0");
//                diaDev.put("A",diaInfo);
//                dia.put("dev",diaDev);
//                ordnew.put("dia",dia);
//                msglist.add("12000044");
//              }
//              bodyData.setInd_device_set_info(ordnew.toString());
//            }
//            //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 end
//
//            if ( "4".equals(imageFlg)  &&(AdminWebConstant.Treatment.DeviceMode.HD.equals(mstTreat.getDeviceMode()) ||
//                    AdminWebConstant.Treatment.DeviceMode.ECUM.equals(mstTreat.getDeviceMode()) ||
//                    AdminWebConstant.Treatment.DeviceMode.HDF.equals(mstTreat.getDeviceMode()) ||
//                    AdminWebConstant.Treatment.DeviceMode.HF.equals(mstTreat.getDeviceMode()) ||
//                    AdminWebConstant.Treatment.DeviceMode.OHDF.equals(mstTreat.getDeviceMode()) ||
//                    AdminWebConstant.Treatment.DeviceMode.OHF.equals(mstTreat.getDeviceMode()) ||
//                    AdminWebConstant.Treatment.DeviceMode.AFBF.equals(mstTreat.getDeviceMode())) ||
//                    AdminWebConstant.Treatment.DeviceMode.PURIFICATION.equals(mstTreat.getDeviceMode())){
//              if (!"null".equals(singleNeedle) && "1".equals(singleNeedle)){
//                JSONObject ordnewbvufc = (ordnew == null || !ordnew.has("bvufc")) ? null : new JSONObject(ordnew.get("bvufc").toString());
//                JSONObject ordnewbvufcDev = (ordnewbvufc == null || !ordnewbvufc.has("dev")) ? null : new JSONObject(ordnewbvufc.get("dev").toString());
//                JSONObject ordnewbvufcInfo = (ordnewbvufcDev == null || !ordnewbvufcDev.has("A")) ? null : new JSONObject(ordnewbvufcDev.get("A").toString());
//                if (ordnewbvufcInfo != null && ordnewbvufcInfo.has("196") && ordnewbvufcDev != null && ordnewbvufc != null && ordnew != null) {
//                  if (!"0".equals(ordnewbvufcInfo.get("196").toString())) {
//                    msglist.add("12000042");
//                  }
//                }
//
//              }
//            }
//
//            if( "2".equals(imageFlg) && AdminWebConstant.Treatment.DeviceMode.I_HDF.equals(mstTreat.getDeviceMode())) {
//              JSONObject ordnewufr = (ordnew == null || !ordnew.has("ufr")) ? null : new JSONObject(ordnew.get("ufr").toString());
//              JSONObject ordnewufrDev = (ordnewufr == null || !ordnewufr.has("dev")) ? null : new JSONObject(ordnewufr.get("dev").toString());
//              JSONObject ordnewufrInfo = (ordnewufrDev == null || !ordnewufrDev.has("A")) ? null : new JSONObject(ordnewufrDev.get("A").toString());
//              if (ordnewufrInfo != null && ordnewufrInfo.has("290") && ordnewufrDev != null && ordnewufr != null && ordnew != null) {
//                if (!"0".equals(ordnewufrInfo.get("290").toString())) {
//                  ordnewufrInfo.put("290", "0");
//                  ordnewufrDev.put("A", ordnewufrInfo);
//                  ordnewufr.put("dev", ordnewufrDev);
//                  ordnew.put("ufr", ordnewufr);
//                  msglist.add("12000034");
//                }
//                indDeviceSetInfoDefault.put("ufr", ordnewufr);
//                bodyData.setInd_device_set_info(indDeviceSetInfoDefault.toString());
//              }
//
//            }
//            if( "1".equals(imageFlg) && AdminWebConstant.Treatment.DeviceMode.AFBF.equals(mstTreat.getDeviceMode())) {
//              JSONObject ordnewdc = (ordnew == null || !ordnew.has("dc")) ? null : new JSONObject(ordnew.get("dc").toString());
//              JSONObject ordnewdcDev = (ordnewdc == null || !ordnewdc.has("dev")) ? null : new JSONObject(ordnewdc.get("dev").toString());
//              JSONObject ordnewdcInfo = (ordnewdcDev == null || !ordnewdcDev.has("A")) ? null : new JSONObject(ordnewdcDev.get("A").toString());
//              if (ordnewdcInfo != null && ordnewdcInfo.has("340") && ordnewdcDev != null && ordnewdc != null && ordnew != null) {
//                //mod 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 start
//                //if ("1".equals(ordnewdcInfo.get("340").toString())) {
//                if (!"0".equals(ordnewdcInfo.get("340").toString())) {
//                  //mod 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 end
//                  ordnewdcInfo.put("340", "0");
//                  ordnewdcDev.put("A", ordnewdcInfo);
//                  ordnewdc.put("dev", ordnewdcDev);
//                  ordnew.put("dc", ordnewdc);
//                  //mod 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 start
////                msglist.add("12000034");
//                  msglist.add("12000037");
//                  //mod 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 end
//                }
//                //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 start
//                bodyData.setInd_device_set_info(ordnew.toString());
//                //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 end
//              }
//            }
//            if( "3".equals(imageFlg)  && AdminWebConstant.Treatment.DeviceMode.I_HDF.equals(mstTreat.getDeviceMode())) {
//              JSONObject ordnewqbqd = (ordnew == null || !ordnew.has("qbqd")) ? null : new JSONObject(ordnew.get("qbqd").toString());
//              JSONObject ordnewqbqdDev = (ordnewqbqd == null || !ordnewqbqd.has("dev")) ? null : new JSONObject(ordnewqbqd.get("dev").toString());
//              JSONObject ordnewqbqdA = (ordnewqbqdDev == null || !ordnewqbqdDev.has("A")) ? null : new JSONObject(ordnewqbqdDev.get("A").toString());
//              if (ordnewqbqdA != null && ordnewqbqdA.has("430") && ordnewqbqdDev != null && ordnewqbqd != null && ordnew != null) {
//                //mod 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 start
////              if ("1".equals(ordnewqbqdA.get("430").toString())) {
//                if (!"0".equals(ordnewqbqdA.get("430").toString())||!"0".equals(ordnewqbqdA.get("431").toString())) {
//                  //mod 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 end
//
//                  ordnewqbqdA.put("430", "0");
//                  ordnewqbqdA.put("431", "0");
//                  ordnewqbqdDev.put("A", ordnewqbqdA);
//                  ordnewqbqd.put("dev", ordnewqbqdDev);
//                  ordnew.put("qbqd", ordnewqbqd);
//                  //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 start
////                msglist.add("12000034");
//                  msglist.add("12000039");
//                  //mod 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 end
//                }
//                bodyData.setInd_device_set_info(ordnew.toString());
//              }
//            }
//            if( "4".equals(imageFlg)  && AdminWebConstant.Treatment.DeviceMode.I_HDF.equals(mstTreat.getDeviceMode())) {
//              JSONObject ordnewbvufc = (ordnew == null || !ordnew.has("bvufc")) ? null : new JSONObject(ordnew.get("bvufc").toString());
//              JSONObject ordnewbvufcDev = (ordnewbvufc == null || !ordnewbvufc.has("dev")) ? null : new JSONObject(ordnewbvufc.get("dev").toString());
//              JSONObject ordnewbvufcInfo = (ordnewbvufcDev == null || !ordnewbvufcDev.has("A")) ? null : new JSONObject(ordnewbvufcDev.get("A").toString());
//              if (ordnewbvufcInfo != null && ordnewbvufcInfo.has("196") && ordnewbvufcDev != null && ordnewbvufc != null && ordnew != null) {
//                if (!"0".equals(ordnewbvufcInfo.get("196").toString())) {
//                  ordnewbvufcInfo.put("196", "0");
//                  ordnewbvufcDev.put("A", ordnewbvufcInfo);
//                  ordnewbvufc.put("dev", ordnewbvufcDev);
//                  ordnew.put("bvufc", ordnewbvufc);
//                  msglist.add("12000034");
//                }
//                bodyData.setInd_device_set_info(ordnew.toString());
//              }
//            }
//          }
//        }
//        //7810 mod 治療条件・装置設定変更時の動作不備（412.xlsx）張 end
//        responseData.put("msglist",msglist);
//        //add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 end
//        deviceSetInfoService.updateDeviceSetInfoOrd(
//                ordMain.get(i).
//                        getOrdNo(),
//                bodyData.getInd_device_set_info()
//        );
//
//      } endregion

      /* mod #9355  by zhangruixue 2023-09-07 --start */
      deviceSetInfoService.updateDeviceSetInfoOrd(bodyData, facilityCd, treatmentList, ordMain, responseData, imageFlg, ordnewTmp,treatWeekList);
      /* mod #9355  by zhangruixue 2023-09-07 --end */
      /* modify by KongShuai  2023-02-01 CodeOptimization end */
    } catch (Exception e) {

//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }

    // 終了日が未設定の場合、患者治療パターンの更新
    if ("false".equals(bodyData.getIs_deadline())) {
      JSONObject editInfo = new JSONObject(bodyData.getInd_device_set_info());
      // 患者治療パターン更新処理
      this.updatePatTreatmentPattern(
            patId,
            facilityCd,
            treatmentList,
            this.getLongList(bodyData.getInd_kur_cd()),
            treatWeekList,
            up_date,
            editInfo.toString(),
            "DEVICE_SET_INFO"
          );
    }

// del #7188 2023/01/14 治療条件，装置設定を変更すると次患者が再送される dou start region
//    String message;
//    try {
//      LocalDateTime update = LocalDateTime.now();
//      Long skipCode = Long.parseLong("0");
//      // 次患者更新処理
//      for (OrdMain ord: ordMain) {
//        Long bedCd = Long.parseLong(ord.getIndBedCd().toString());
//        Long targetOrdNo = ord.getOrdNo();
//        // 登録されているベッド(ベッド移動なしのため変更後として処理※変更前は条件送信キャンセルとして処理されるため)
//        message = ordMainResource.callDoCancelSetNextPatInfo(facilityCd, skipCode, bedCd, targetOrdNo, true, update);
//      }
//    } catch (RuntimeException e) {
////      message = "「条件送信キャンセル」「次患者更新」処理失敗";
////
////      EventLogMessage eventLogMessage = new EventLogMessage();
////      eventLogMessage.setLogMessage(message );
////      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);
////      eventLogMessage.setLogMessage(e.getMessage());
////      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);
//
//
//      e.printStackTrace();
//      // wp アプリケーションログの適正化 Add Start
//      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
//      // wp アプリケーションログの適正化 Add End
//    }
// del #7188 2023/01/14 治療条件，装置設定を変更すると次患者が再送される dou end endregion
    //mod FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 start
    //return new ResponseEntity<>(HttpStatus.OK);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    // del 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou start
    //add by ztc 2023-02-27 [Optimize runtime No.5482] --start
//    List<OrdMain> dellistForJournal = ordMain.stream().filter(item->item.getIndKurCd() != null && item.getIndKurCd()!=0).distinct().collect(Collectors.toList());
//    List<JournalCreateRequestPayload> ctlNoList = new ArrayList<>();
//    if(!dellistForJournal.isEmpty()){
//      for (int i = 0; i < dellistForJournal.size(); i++) {
//        JournalCreateRequestPayload payload = new JournalCreateRequestPayload();
//        payload.setOpeCd(bodyData.getOpe_cd());
//        payload.setCrud(bodyData.getCrud());
//        payload.setFacilityCd(bodyData.getFacility_cd());
//        payload.setHospPatId(bodyData.getHosp_pat_id());
//        payload.setPatId(Long.valueOf(bodyData.getPat_id()));
//        payload.setOrdNo(dellistForJournal.get(i).getOrdNo());
//        payload.setBaseDate(dellistForJournal.get(i).getTreatDate());
//        payload.setUserId(Long.valueOf(bodyData.getInd_user()));
//        ctlNoList.add(payload);
//      }
//    }
//    if (!CollectionUtils.isEmpty(ctlNoList)){
//      journalService.callCreateJournalForCtrNo(ctlNoList);
//    }
    //add by ztc 2023-02-27 [Optimize runtime No.5482] --end
    // del 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou end
    return new ResponseEntity<>(responseData.toString(),HttpStatus.OK);
    //mod FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 end
  }

  /**
   *
   */

  /**
   * 装置設定データ取得
   * @param bodydata        必要パラメータの記載されたJson文字列
   * table_flag    テーブル区分  指定したテーブルから装置設定情報取得(0->システム、1->患者情報、2-> 治療情報)
   * facility_cd   施設コード(共通)
   * screen_key    画面キー(全画面のデータを取るときは0、画面ごとのデータをとるときは指定  共通)
   * pad_id        患者ID(患者情報、治療情報    必須)
   * ord_no        ord番号(なくてもOK  指定されてたら下のはいらない, なければ下の条件を見る)
   * start_date    開始日(ord_noがなければ必須)
   * end_date      終了日(なくてもOK)
   * week          曜日(全曜日はnull、あとは指定 List型)
   * treat_nethod  治療方法(指定されたものがあれば指定、なければ全治療方法 List型)
   * kur_cd        クール(指定されたものがあれば指定、なければ全クール 複数もある List型)
   */
  @PostMapping("getDeviceData")
  public ResponseEntity<List<String>> getDeviceSetInfoList(
      @Validated @RequestBody ApiEntityDeviceSetInfo.ValiDeviceSetInfo bodyData ,BindingResult validationResult
      ,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) throws URISyntaxException {


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_SET_INFO + "/getDeviceData";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    // 受信データチェック
    if (!this.checkDeviceSetInfo(
        bodyData.getTable_flag(),
        bodyData.getFacility_cd(),
        bodyData.getPat_id(),
        bodyData.getOrd_no(),
        bodyData.getStart_date(),
        bodyData.getWeek()
        )) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 start
    if(!ntssUser.isNkkAdminUser()) {
      if (bodyData != null && bodyData.getFacility_cd() != null &&
        !bodyData.getFacility_cd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " facility_cd=" + bodyData.getFacility_cd() + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 end

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

    List<String> deviceSetInfoJson = null;
    int table_flag = this.getIntPattern(bodyData.getTable_flag());
    // 施設コード
    String facility_cd = bodyData.getFacility_cd();
    // 画面コード
    String screen_key = bodyData.getScreen_key();
    // 患者ID
    Long pat_id = this.getLongPattern(bodyData.getPat_id());
    // ord番号
    Long ord_no = this.getLongPattern(bodyData.getOrd_no());;
    // 開始日
    String start_date = bodyData.getStart_date();
    // 終了日
    String end_date = bodyData.getEnd_date();
    // 曜日
    List<Integer> week = this.getIntListPattern((String)bodyData.getWeek());
    // 治療方法
    List<Integer> treat_method = this.getIntListPattern((String)bodyData.getTreat_method());
    // クールコード
    List<Integer> kur_cd = this.getIntListPattern((String)bodyData.getKur_cd());

    try {
      deviceSetInfoJson = deviceSetInfoService.selectDeviceInfo(table_flag, facility_cd, screen_key, pat_id, ord_no, start_date, end_date, week, treat_method, kur_cd);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(deviceSetInfoJson, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_BBS_INFO, SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 風袋・除水データ取得(装置設定デフォルトマスタ)
   * @param facility_cd 該当患者の患者ID
   * @return 対象患者の風袋・除水情報
   */
  @GetMapping("/getSysTareAndOffWaterById/{facility_cd}")
  public ResponseEntity<List<String>> getSysTareAndOffWaterById(@PathVariable String facility_cd,
                                                                @RequestParam(required = false) Long selectedPatId,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                                @AuthenticationPrincipal NtssUser ntssUser
                                                                // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    if (!facilityAccessService.hasFacilityOrSelectedPatShareAccess(ntssUser, facility_cd, selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_SET_INFO + "/getSysTareAndOffWaterById";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, BEFORE_LOG_FLG_INFO, mappingUrl, facility_cd,
      null);
    // wp アプリケーションログの適正化 Add End
    List<String> getTateAndOffWater = null;

    try {
      getTateAndOffWater = deviceSetInfoService.selectTareAndOffWater(facility_cd, null, null, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_INFO, mappingUrl, facility_cd,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(getTateAndOffWater, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_ERROR, mappingUrl, facility_cd, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }


  /**
   * mod facilityCdパラメータを追加 #12462 患者情報共有 zrx
   * 風袋・除水データ取得(患者情報)
   * @param pat_id 該当患者の患者ID
   * @return 対象患者の風袋・除水情報
   */
  @GetMapping({"/getPatTareAndOffWaterById/{pat_id}","/getPatTareAndOffWaterById/{pat_id}/{facilityCd}"})
  public ResponseEntity<List<String>> getPatTareAndOffWaterById(@PathVariable long pat_id,@PathVariable(required = false) String facilityCd,
                                                                // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                                @AuthenticationPrincipal NtssUser ntssUser
                                                                // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 start
    if(!ntssUser.isNkkAdminUser()) {
      PatMain patMain = patMainDao.selectById(pat_id);
      if (patMain != null && patMain.getFacility_cd() != null &&
        !patMain.getFacility_cd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " facility_cd=" + patMain.getFacility_cd() + " pat_id=" + pat_id + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 end
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_SET_INFO + "/getPatTareAndOffWaterById";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      pat_id);
    // wp アプリケーションログの適正化 Add End
    List<String> getTateAndOffWater = null;

    try {
      //mod facilityCdパラメータを追加 #12462 患者情報共有 zrx start
      getTateAndOffWater = deviceSetInfoService.selectTareAndOffWater(facilityCd, pat_id, null, null);
      //mod facilityCdパラメータを追加 #12462 患者情報共有 zrx end

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_INFO, mappingUrl, null,
        pat_id);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(getTateAndOffWater, HttpStatus.OK);

    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }


  /**
   * 風袋・除水データ取得(治療情報)
   */
  @PostMapping("/getIndTareAndOffWaterById")
  public ResponseEntity<List<String>> getIndTareAndOffWaterById(@RequestBody Map<String, String> payload,
                                                                @RequestParam(required = false) Long selectedPatId,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                                @AuthenticationPrincipal NtssUser ntssUser
                                                                // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    Long ordNo = Long.parseLong(payload.get("ordNo"));
    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    if (ordMain != null && !facilityAccessService.hasFacilityOrSelectedPatShareAccessForFacilityCds(
        ntssUser, Collections.singletonList(ordMain.getFacilityCd()), selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_SET_INFO + "/getIndTareAndOffWaterById";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      payload);
    // wp アプリケーションログの適正化 Add End
    List<String> getTateAndOffWater = null;
    Integer flgIndRst = Integer.parseInt(payload.get("flgIndRst"));
    try {
      getTateAndOffWater = deviceSetInfoService.selectTareAndOffWater(null, null, ordNo, flgIndRst);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_INFO, mappingUrl, null,
        payload);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(getTateAndOffWater, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }


  /**
   * 風袋・除水更新対象抽出(治療情報編集時)
   */
  @GetMapping("/getTareAndOffUpdateCondition/{pat_id}")
    public ResponseEntity<List<String>> getTareAndOffUpdateCondition(@PathVariable long pat_id,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                                     @AuthenticationPrincipal NtssUser ntssUser
                                                                     // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 start
    if (!ntssUser.isNkkAdminUser()) {
      long count = patMainDao.countByPatIdAndFacilityCd(pat_id, ntssUser.getFacilityCd());
      if (count == 0) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " pat_id=" + pat_id + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 end


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_SET_INFO + "/getTareAndOffUpdateCondition";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      pat_id);
    // wp アプリケーションログの適正化 Add End

      List<String> getTateAndOffWater = null;

    // 本日の日付取得
    Calendar todayDate = Calendar.getInstance();
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMdd");
    String toDate = dateFormat.format(todayDate.getTime());
    todayDate.add(Calendar.DATE, -1);
    String fromDate = dateFormat.format(todayDate.getTime());

    try {
      getTateAndOffWater = deviceSetInfoService.selectTareAndOffWaterByWeek(pat_id, fromDate, toDate);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_INFO, mappingUrl, null,
        pat_id);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(getTateAndOffWater, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * ホスト報知データ取得(装置設定デフォルトマスタ)
   * @param facility_cd 施設コード
   * @return 対象施設のホスト報知情報
   */
  @GetMapping("/getSysHostNoticeById/{facility_cd}")
  public ResponseEntity<List<String>> getSysHostNoticeById(@PathVariable String facility_cd,
                                                           @RequestParam(required = false) Long selectedPatId,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                           @AuthenticationPrincipal NtssUser ntssUser
                                                           // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    if (!facilityAccessService.hasFacilityOrSelectedPatShareAccess(ntssUser, facility_cd, selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_SET_INFO + "/getSysHostNoticeById";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, BEFORE_LOG_FLG_INFO, mappingUrl, facility_cd,
      null);
    // wp アプリケーションログの適正化 Add End

    List<String> getHostNotice = null;

    try {
      getHostNotice = deviceSetInfoService.selectHostNotice(facility_cd, null);
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_INFO, mappingUrl, facility_cd,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(getHostNotice, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_ERROR, mappingUrl, facility_cd, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * mod facility_cdパラメータを追加 #12462 患者情報共有 zrx
   * ホスト報知データ取得(患者情報)
   * @param pat_id 該当患者の患者ID
   * @return 対象患者のホスト報知情報
   */
  @GetMapping({"/getPatHostNoticeById/{pat_id}","/getPatHostNoticeById/{pat_id}/{facility_cd}"})
  public ResponseEntity<List<String>> getPatHostNoticeById(@PathVariable long pat_id,@PathVariable(required = false) String facility_cd) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_SET_INFO + "/getPatHostNoticeById";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      pat_id);
    // wp アプリケーションログの適正化 Add End

    List<String> getHostNotice = null;

    try {
      //mod facility_cdパラメータを追加 #12462 患者情報共有 zrx start
      getHostNotice = deviceSetInfoService.selectHostNotice(facility_cd, pat_id);
      //mod facility_cdパラメータを追加 #12462 患者情報共有 zrx end
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_INFO, mappingUrl, null,
        pat_id);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(getHostNotice, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 患者状況が「治療中」または「排液済み」でかつ、
   * 2日以上前の版が確定していない透析中以降の実績の抽出
   */
  @GetMapping("/getDisableUpdate/{pat_id}")
  public ResponseEntity<List<String>> getDisableUpdate(@PathVariable long pat_id,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                       @AuthenticationPrincipal NtssUser ntssUser
                                                       // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 start
    if (!ntssUser.isNkkAdminUser()) {
      long count = patMainDao.countByPatIdAndFacilityCd(pat_id, ntssUser.getFacilityCd());
      if (count == 0) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " pat_id=" + pat_id + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 end


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_SET_INFO + "/getDisableUpdate";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      pat_id);
    // wp アプリケーションログの適正化 Add End
    List<String> getTateAndOffWater = null;

  // 本日の日付取得
  Calendar todayDate = Calendar.getInstance();
  SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMdd");
  todayDate.add(Calendar.DATE, -2);
  String fromDate = dateFormat.format(todayDate.getTime());

  try {
    getTateAndOffWater = deviceSetInfoService.selectDisableUpdate(pat_id, fromDate);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_INFO, mappingUrl, null,
      pat_id);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(getTateAndOffWater, HttpStatus.OK);
  } catch (Exception e) {
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage(e.getMessage());
//    logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);

    // wp アプリケーションログの適正化 Add Start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
  }
}


  /**
   * 装置設定データの更新
   * @param bodydata        必要パラメータの記載されたJson文字列
   * update_data    更新するデータ(必須)
   * table_flag     テーブル区分(必須)   指定したテーブルから装置設定情報の更新(0->システム, 1->患者情報, 3->治療情報) <<配列>>
   * facility_cd    施設コード(必須)
   * pat_id         患者ID(必須)
   * ord_no         ord番号(なくてもOK  なければ以下の変数必要※必須ではない)
   * start_date     開始日(ord_noがなければ必須)
   * end_date       終了日(なくてもOK)
   * week           曜日(全曜日はnull、あとは指定 List型)
   * treat_nethod   治療方法(指定されたものがあれば指定、なければ全治療方法 List型)
   * kur_cd         クール(指定されたものがあれば指定、なければ全クール 複数もある List型)
   * @return
   * @throws URISyntaxException
   */
  @PostMapping("updateDeviceSetInfo")
  public ResponseEntity<Void> updateDeviceSetInfo(
      @Validated @RequestBody ApiEntityDeviceSetInfo.ValiDeviceSetInfo bodyData ,BindingResult validationResult
      ,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) throws URISyntaxException,JSONException,ArrayIndexOutOfBoundsException,NullPointerException {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 start
    if(!ntssUser.isNkkAdminUser()) {
      if (bodyData != null && bodyData.getFacility_cd() != null &&
        !bodyData.getFacility_cd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " facility_cd=" + bodyData.getFacility_cd() + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 end



    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_SET_INFO + "/updateDeviceSetInfo";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("table_flag" + bodyData.getTable_flag());
    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);
    eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("facility_cd" + bodyData.getFacility_cd());
    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);
    eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("pat_id" + bodyData.getPat_id());
    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);
    eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("ord_id" + bodyData.getOrd_no());
    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);
    eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("start_date" + bodyData.getStart_date());
    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);
    eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("week" + bodyData.getWeek());
    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);
    //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end


    // 受信データチェック
    if (!this.checkDeviceSetInfo(
        bodyData.getTable_flag(),
        bodyData.getFacility_cd(),
        bodyData.getPat_id(),
        bodyData.getOrd_no(),
        bodyData.getStart_date(),
        bodyData.getWeek()
        )) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.BAD_REQUEST);
    }

    // 更新するテーブルを配列で作成
    List<Integer> tableList = new ArrayList<Integer>();
    tableList.add(this.getIntPattern(bodyData.getTable_flag()));
    if (this.getIntPattern(bodyData.getSecond_table_flag()) > 0) {
      tableList.add(this.getIntPattern(bodyData.getSecond_table_flag()));
    }
    String facility_cd = bodyData.getFacility_cd();
    Long pat_id = this.getLongPattern(bodyData.getPat_id());
    Long ord_no = this.getLongPattern(bodyData.getOrd_no());
    String start_date = bodyData.getStart_date();
    String end_date = bodyData.getEnd_date();
    List<Integer> week = this.getIntListPattern(bodyData.getWeek());
    List<Integer> treat_method = this.getIntListPattern(bodyData.getTreat_method());
    List<Integer> kur_cd = this.getIntListPattern(bodyData.getKur_cd());
    /* add by KongShuai  2023-02-01 CodeOptimization start */
    String update_date = bodyData.getUpdate_data();
    /* add by KongShuai  2023-02-01 CodeOptimization end */

    //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
    eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("tableList");
    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);
    eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(tableList.toString());
    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);
    /* modify by KongShuai  2023-02-01 CodeOptimization start */
//    //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
//    for (int i = 0; i < tableList.size(); i++) {
//      JSONObject jobj = new  JSONObject();
//      // 更新データ
//      String deviceInfo;
//      try {
//        if (tableList.size() == 2) {
//          if (i == 0 && tableList.get(i) == 0) {
//            if (tableList.get(i + 1) == 1) {
//              jobj.put("pat", new JSONObject(bodyData.getUpdate_data()));
//              deviceInfo = jobj.toString();
//            } else {
//              jobj.put("ord", new JSONObject(bodyData.getUpdate_data()));
//              deviceInfo = jobj.toString();
//            }
//          } else {
//            deviceInfo = bodyData.getUpdate_data();
//          }
//        } else {
//          if (tableList.get(i) == 0) {
//            jobj.put("pat", new JSONObject(bodyData.getUpdate_data()));
//            deviceInfo = jobj.toString();
//          } else {
//            deviceInfo = bodyData.getUpdate_data();
//          }
//        }
//        deviceSetInfoService.updateDeviceInfo(tableList.get(i), facility_cd, pat_id, ord_no, start_date, end_date, week, treat_method, kur_cd, deviceInfo);
//      } catch (Exception e) {
//        e.printStackTrace();
////        //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
////        //EventLogMessage eventLogMessage = new EventLogMessage();
////        eventLogMessage = new EventLogMessage();
////        //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
////        eventLogMessage.setLogMessage(e.getMessage());
////        logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);
//
//        // wp アプリケーションログの適正化 Add Start
//        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
//        // wp アプリケーションログの適正化 Add End
//        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
//      }
//    }
    try {
      deviceSetInfoService.updateDeviceSetInfo(tableList, facility_cd, pat_id, ord_no, start_date, end_date, week, treat_method, kur_cd, update_date);
    } catch (Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
      }
    /* modify by KongShuai  2023-02-01 CodeOptimization end */
    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(HttpStatus.OK);
  }


  /**
   * 風袋・除水補正初回更新(患者情報)
   */
  @PostMapping("updateStartTareAndOffWater")
  public ResponseEntity<Void> updateStartTareAndOffWater(
      @Validated @RequestBody ApiEntityDeviceSetInfo.ValiTareAndOffWater bodyData ,BindingResult validationResult
      ,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) throws URISyntaxException,JSONException,ArrayIndexOutOfBoundsException,NullPointerException {


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_SET_INFO + "/updateStartTareAndOffWater";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    // 受信データチェック
    if (null == bodyData.getPat_id()) {
      // 患者情報異常
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage( "患者IDが指定されていません");
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);

      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

    // 患者ID(Long型に変換)
    Long patInfoCd = Long.parseLong(bodyData.getPat_id());
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 start
    if (!ntssUser.isNkkAdminUser()) {
      long count = patMainDao.countByPatIdAndFacilityCd(patInfoCd, ntssUser.getFacilityCd());
      if (count == 0) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " patInfoCd=" + patInfoCd + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 end

    try {
      deviceSetInfoService.updateStartTareAndOffWater(patInfoCd, bodyData.getOff_water_info(), bodyData.getTare_info());

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);
      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }


  /**
   * 風袋・除水補正初回更新(治療情報)
   */
  @PostMapping("updateIndStartTareAndOffWater")
  public ResponseEntity<Void> updateIndStartTareAndOffWater(
      @Validated @RequestBody ApiEntityDeviceSetInfo.ValiTareAndOffWater bodyData ,BindingResult validationResult
      ,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) throws URISyntaxException,JSONException,ArrayIndexOutOfBoundsException,NullPointerException {


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_SET_INFO + "/updateIndStartTareAndOffWater";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    // 受信データチェック
    if (null == bodyData.getOrd_no()) {
      // 治療情報異常
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage( "Ord番号が指定されていません");
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

    // Ord番号(Long型に変換)
    Long ordCd = Long.parseLong(bodyData.getOrd_no());
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 start
    if (!ntssUser.isNkkAdminUser()) {
      long count = deviceSetInfoService.countByOrdNoAndFacilityCd(ntssUser.getFacilityCd(), Collections.singletonList(ordCd));
      if (count == 0) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " ordCd=" + ordCd + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 end

    try {
      deviceSetInfoService.updateIndStartTareAndOffWater(ordCd, bodyData.getOff_water_info(), bodyData.getTare_info());

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);
      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }


  /**
   * 風袋・除水補正即時コミット(患者情報)
   * @param bodyData        必要パラメータの記載されたJson文字列
   *
   * @throws URISyntaxException
   */
  @PostMapping("updateImmediateTareAndOffWater")
  public ResponseEntity<String> updateImmediateTareAndOffWater(
      @Validated @RequestBody ApiEntityDeviceSetInfo.ValiTareAndOffWater bodyData ,BindingResult validationResult
      ,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) throws URISyntaxException,JSONException,ArrayIndexOutOfBoundsException,NullPointerException {


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_SET_INFO + "/updateImmediateTareAndOffWater";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    List<PatInfoRemovalWater> patInfoEntity = new ArrayList<PatInfoRemovalWater>();

    // 受信データチェック
    if (null == bodyData.getPat_id()) {
      // 患者情報異常
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage( "患者IDが指定されていません");
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);


      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

    // 患者ID(Long型に変換)
    Long patInfoCd = Long.parseLong(bodyData.getPat_id());
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 start
    if (!ntssUser.isNkkAdminUser()) {
      long count = patMainDao.countByPatIdAndFacilityCd(patInfoCd, ntssUser.getFacilityCd());
      if (count == 0) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " patInfoCd=" + patInfoCd + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 end

    try {
      if (bodyData.getOff_water_info() != null) {
        deviceSetInfoService.immediateCommitOffWater(patInfoCd, bodyData.getOff_water_info());
      } else {
        deviceSetInfoService.immediateCommitTare(patInfoCd, bodyData.getTare_info());
      }


      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }


  /**
   * 風袋・除水補正即時コミット(治療情報)
   * @param bodyData        必要パラメータの記載されたJson文字列
   *
   * @throws URISyntaxException
   */
  @PostMapping("updateIndImmediateTareAndOffWater")
  public ResponseEntity<Void> updateIndImmediateTareAndOffWater(
      @Validated @RequestBody ApiEntityDeviceSetInfo.ValiTareAndOffWater bodyData ,BindingResult validationResult
      ,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) throws URISyntaxException,JSONException,ArrayIndexOutOfBoundsException,NullPointerException {


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_SET_INFO + "/updateIndImmediateTareAndOffWater";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    List<PatInfoRemovalWater> patInfoEntity = new ArrayList<PatInfoRemovalWater>();

    // 受信データチェック
    if (null == bodyData.getOrd_no()) {
//      // 治療情報異常
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage( "患者IDが指定されていません");
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_INFO, mappingUrl, null,
        "患者IDが指定されていません");
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

    // Ord番号(Long型に変換)
    Long ordCd = Long.parseLong(bodyData.getOrd_no());
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 start
    if (!ntssUser.isNkkAdminUser()) {
      long count = deviceSetInfoService.countByOrdNoAndFacilityCd(ntssUser.getFacilityCd(), Collections.singletonList(ordCd));
      if (count == 0) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " ordCd=" + ordCd + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 end

    try {
      if (bodyData.getOff_water_info() != null) {
        deviceSetInfoService.immediateCommitIndOffWater(ordCd, bodyData.getOff_water_info());
      } else {
        deviceSetInfoService.immediateCommitIndTare(ordCd, bodyData.getTare_info());
      }

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }


  /**
   * 風袋・除水補正更新
   */
   @PostMapping("updateTareOffWaterInfo")
   public ResponseEntity<Void> updateTareOffWaterInfo(
       @Validated @RequestBody ApiEntityDeviceSetInfo.ValiTareAndOffWater bodyData ,BindingResult validationResult
       ,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
       @AuthenticationPrincipal NtssUser ntssUser
       // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) throws URISyntaxException,JSONException,ArrayIndexOutOfBoundsException,NullPointerException {


     // wp アプリケーションログの適正化 Add Start
     String mappingUrl = Uri.DEVICE_SET_INFO + "/updateTareOffWaterInfo";
     logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, BEFORE_LOG_FLG_INFO, mappingUrl, null,
       null);
     // wp アプリケーションログの適正化 Add End

     int tableFlag = Integer.parseInt(bodyData.getTable_flag());
     // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 start
     if (!ntssUser.isNkkAdminUser()) {
       if (tableFlag == 0) {
         String facilityCd = bodyData.getFacility_cd();
         if (facilityCd != null && !facilityCd.isEmpty() &&
           !facilityCd.equals(ntssUser.getFacilityCd())) {
           String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " facilityCd=" + facilityCd + " ";
           InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
           return new ResponseEntity<>(HttpStatus.FORBIDDEN);
         }
       } else if (tableFlag == 1) {
         Long patId = Long.parseLong(bodyData.getPat_id());
         long count = patMainDao.countByPatIdAndFacilityCd(patId, ntssUser.getFacilityCd());
         if (count == 0) {
           String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " patId=" + patId + " ";
           InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
           return new ResponseEntity<>(HttpStatus.FORBIDDEN);
         }
       } else {
         Long ordNo = Long.parseLong(bodyData.getOrd_no());
         long count = deviceSetInfoService.countByOrdNoAndFacilityCd(ntssUser.getFacilityCd(), Collections.singletonList(ordNo));
         if (count == 0) {
           String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " ordNo=" + ordNo + " ";
           InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
           return new ResponseEntity<>(HttpStatus.FORBIDDEN);
         }
       }
     }
     // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 end

     try {
       if (0 == tableFlag) {
         // 装置設定デフォルトマスタの更新
         deviceSetInfoService.updateTareAndOffWater(bodyData.getFacility_cd(), bodyData.getTare_info(), bodyData.getOff_water_info(), tableFlag);
       } else if (1 == tableFlag) {
         // 患者情報の更新
         deviceSetInfoService.updateTareAndOffWater(bodyData.getPat_id(), bodyData.getTare_info(), bodyData.getOff_water_info(), tableFlag);
       } else {
         // 治療情報の更新
         deviceSetInfoService.updateTareAndOffWater(bodyData.getOrd_no(), bodyData.getTare_info(), bodyData.getOff_water_info(), tableFlag);
       }

       // wp アプリケーションログの適正化 Add Start
       logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_INFO, mappingUrl, null,
         null);
       // wp アプリケーションログの適正化 Add End
       return new ResponseEntity<>(HttpStatus.OK);
     } catch (Exception e) {
       // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
//       EventLogMessage eventLogMessage = new EventLogMessage();
//       eventLogMessage.setLogMessage(e.getMessage());
//       logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);

       // wp アプリケーションログの適正化 Add Start
       // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
       // wp アプリケーションログの適正化 Add End
       return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
     }
   }


   /**
    * 装置設定デフォルトマスタ:風袋・除水補正更新
    */
    @PostMapping("updateSysTareOffWaterInfo")
    public ResponseEntity<Void> updateSysTareOffWaterInfo(
        @Validated @RequestBody ApiEntityDeviceSetInfo.ValiTareAndOffWater bodyData ,BindingResult validationResult
        ,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
        @AuthenticationPrincipal NtssUser ntssUser
        // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) throws URISyntaxException,JSONException,ArrayIndexOutOfBoundsException,NullPointerException {
      // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 start
      if(!ntssUser.isNkkAdminUser()) {
        String facilityCd = bodyData.getFacility_cd();
        if (facilityCd != null && !facilityCd.isEmpty() &&
          !facilityCd.equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " facilityCd=" + facilityCd + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
      }
      // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 end


      // wp アプリケーションログの適正化 Add Start
      String mappingUrl = Uri.DEVICE_SET_INFO + "/updateSysTareOffWaterInfo";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, BEFORE_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      // 施設コード
      String facilityCd = bodyData.getFacility_cd();
      // 風袋情報
      String tareInfo = bodyData.getTare_info();
      // 除水補正情報
      String offWaterInfo = bodyData.getOff_water_info();
      // 更新日時
      Timestamp upDate = Timestamp.valueOf(bodyData.getUp_date());
      Long patId = null;
      try {
        deviceSetInfoService.updateSysTareOffWaterInfo(
            facilityCd,
            tareInfo,
            offWaterInfo,
            upDate
            );
        // del #7188 2023/01/14 治療条件，装置設定を変更すると次患者が再送される dou start
        // callDoCancelSetNextPatInfo(facilityCd, patId);
        // del #7188 2023/01/14 治療条件，装置設定を変更すると次患者が再送される dou end
        // wp アプリケーションログの適正化 Add Start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_INFO, mappingUrl, null,
          null);
        // wp アプリケーションログの適正化 Add End
        return new ResponseEntity<>(HttpStatus.OK);
      } catch (Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
//        EventLogMessage eventLogMessage = new EventLogMessage();
//        eventLogMessage.setLogMessage(e.getMessage());
//        logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);

        // wp アプリケーションログの適正化 Add Start
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
        // wp アプリケーションログの適正化 Add End
        return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      }
    }

    /**
     * 患者情報:風袋・除水補正更新
     */
     @PostMapping("updatePatTareOffWaterInfo")
     public ResponseEntity<Void> updatePatTareOffWaterInfo(
         @Validated @RequestBody ApiEntityDeviceSetInfo.ValiTareAndOffWater bodyData ,BindingResult validationResult
         ,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
         @AuthenticationPrincipal NtssUser ntssUser
         // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) throws URISyntaxException,JSONException,ArrayIndexOutOfBoundsException,NullPointerException {



       // wp アプリケーションログの適正化 Add Start
       String mappingUrl = Uri.DEVICE_SET_INFO + "/updatePatTareOffWaterInfo";
       logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, BEFORE_LOG_FLG_INFO, mappingUrl, null,
         null);
       // wp アプリケーションログの適正化 Add End

       //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
//       EventLogMessage eventLogMessage = new EventLogMessage();
//       eventLogMessage.setLogMessage("患者情報を更新します");
//       logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);
       //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
       // 患者ID
       Long patId = this.getLongPattern(bodyData.getPat_id());
       // 施設コード
       String facilityCd = bodyData.getFacility_cd();
       // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 start
       if (!ntssUser.isNkkAdminUser()) {
         if (facilityCd != null && !facilityCd.isEmpty() &&
             !facilityCd.equals(ntssUser.getFacilityCd())) {
           String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " facilityCd=" + facilityCd + " ";
           InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
           return new ResponseEntity<>(HttpStatus.FORBIDDEN);
         }
       }
       // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 end
       //add #10632 装置設定画面の更新時にpat_main_historyがインサートされない 20240530 ztc start
       if (facilityCd == null && patId != null) {
         List<Long> patIdList = new ArrayList<Long>();
         patIdList.add(patId);
         List<PatPersonalMain> listPatPersonalMain = patPersonalMainDao.selectByIdList(patIdList);
         PatPersonalMain patPersonalMain = listPatPersonalMain.get(0);
         facilityCd = patPersonalMain.getFacility_cd();
         // #11205 -ペンテスト2－4認可制御の不備  add 20260420 start
         // patId 経由で解決した facilityCd がセッションの施設と一致するか確認
         if (!ntssUser.isNkkAdminUser()) {
           if (facilityCd != null && !facilityCd.isEmpty() &&
               !facilityCd.equals(ntssUser.getFacilityCd())) {
             String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " facilityCd=" + facilityCd + " patId=" + patId + " ";
             InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
             return new ResponseEntity<>(HttpStatus.FORBIDDEN);
           }
         }
         // #11205 -ペンテスト2－4認可制御の不備  add 20260420 end
       }
       //add #10632 装置設定画面の更新時にpat_main_historyがインサートされない 20240530 ztc end
       // 風袋情報
       String tareInfo = bodyData.getTare_info();
       // 除水補正情報
       String offWaterInfo = bodyData.getOff_water_info();
       // 更新日時
       Timestamp upDate = Timestamp.valueOf(bodyData.getUp_date());
       try {
         deviceSetInfoService.updatePatTareOffWaterInfo(
             patId,
             facilityCd,
             tareInfo,
             offWaterInfo,
             upDate
             );
         //add #10632 装置設定画面の更新時にpat_main_historyがインサートされない 20240530 ztc start
         patMainDeviceSetInfoService.insertPatMainHistoryByPatIdFacilityCd(facilityCd, patId);
         //add #10632 装置設定画面の更新時にpat_main_historyがインサートされない 20240530 ztc end
         // wp アプリケーションログの適正化 Add Start
         logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_INFO, mappingUrl, null,
           "患者情報を更新します");
         // wp アプリケーションログの適正化 Add End
         return new ResponseEntity<>(HttpStatus.OK);
       } catch (Exception e) {
         // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
         //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
         //EventLogMessage eventLogMessage = new EventLogMessage();
//         eventLogMessage = new EventLogMessage();
//         //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
//         eventLogMessage.setLogMessage(e.getMessage());
//         logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);

         // wp アプリケーションログの適正化 Add Start
         // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
         // wp アプリケーションログの適正化 Add End
         return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
       }
     }

    /**
     * 指示:風袋・除水補正更新
     */
    @PostMapping("updateIndTareOffWaterInfo")
    public ResponseEntity<Void> updateIndTareOffWaterInfo(
        @Validated @RequestBody ApiEntityDeviceSetInfo.ValiTareAndOffWater bodyData ,BindingResult validationResult
        // add #10553 ④装置設定＞風袋・除水補正にて指示への展開保存をした場合には、変更された治療予定毎の連携イベントが必要 piao start
      , @AuthenticationPrincipal NtssUser user
        // add #10553 ④装置設定＞風袋・除水補正にて指示への展開保存をした場合には、変更された治療予定毎の連携イベントが必要 piao end
        ) throws URISyntaxException,JSONException,ArrayIndexOutOfBoundsException,NullPointerException {
        // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 start
        if(!user.isNkkAdminUser()) {
          String facilityCd = bodyData.getFacility_cd();
          if (facilityCd != null && !facilityCd.isEmpty() &&
            !facilityCd.equals(user.getFacilityCd())) {
            String msg_11205_FORBIDDEN = "user.getFacilityCd()=" + user.getFacilityCd() + " facilityCd=" + facilityCd + " ";
            InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
            return new ResponseEntity<>(HttpStatus.FORBIDDEN);
          }
        }
        // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 end


      // wp アプリケーションログの適正化 Add Start
      String mappingUrl = Uri.DEVICE_SET_INFO + "/updateIndTareOffWaterInfo";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, BEFORE_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End

      // 患者ID
      Long patId = Long.parseLong(bodyData.getPat_id());
      // 施設コード
      String facilityCd = bodyData.getFacility_cd();
      // 治療開始日
      String startDate = bodyData.getStart_date().replaceAll("-", "");
      // 治療終了日
      String endDate = bodyData.getEnd_date().replaceAll("-", "");
      // 治療曜日リスト
      List<Integer> treatWeekList = this.getWeekPattern(bodyData.getWeeks());
      // 治療方法リスト
      List<Integer> treatmentList = this.getValueList(bodyData.getInd_treatment_cd());
      // クールリスト
      List<Long> kurList = this.getLongList(bodyData.getInd_kur_cd());
      // 更新日時
      Timestamp upDate = Timestamp.valueOf(bodyData.getUp_date());

      List<OrdMain> ordMain = new ArrayList();
      // 更新対象の治療情報を取得
      try {
        ordMain = ordMainService.findUpdateTarget(
          patId,
          facilityCd,
          startDate,
          endDate,
          treatWeekList,
          treatmentList,
          kurList
        );
      } catch (Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
//        EventLogMessage eventLogMessage = new EventLogMessage();
//        eventLogMessage.setLogMessage(e.getMessage());
//
//        logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_BBS_INFO, SERVICE_NAME.FNSI, null);

        // wp アプリケーションログの適正化 Add Start
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
        // wp アプリケーションログの適正化 Add End
      }
      // 治療情報の更新
      try {
        //upd by ztc 2023-02-23 [Optimize runtime No.5482] --start /
//        for (int i = 0; i < ordMain.size(); i++) {
//          deviceSetInfoService.updateIndTareOffWaterInfo(
//            ordMain.get(i).getOrdNo(),
//            bodyData.getTare_info(),
//            bodyData.getOff_water_info(),
//            upDate
//          );
//        }
        //add #10266  start
        if("2".equals(bodyData.getUpdate_flag())){
            ordMain = ordMain.stream().filter(ord -> "0".equals(ord.getRstDialysisState())).collect(Collectors.toList());
        }
        if(ordMain.size()<=0){
          return new ResponseEntity<>(HttpStatus.OK);
        }
        //add #10266  end
        // add 11119 by kangjie 20241009 start
        selectHistoryUtils.insertMangoDbHistoryBatchByOrdMainList(ordMain);
        // add 11119 by kangjie 20241009 end
        List<Long> ordNoList = ordMain.stream().map(OrdMain::getOrdNo).collect(Collectors.toList());
        deviceSetInfoService.updateIndTareOffWaterInfoList(
          ordNoList,
          bodyData.getTare_info(),
          bodyData.getOff_water_info(),
          upDate
          // add 10196 by kangjie 20240124 start
          ,bodyData.getInd_user()
          // add 10196 by kangjie 20240124 end
        );
        //upd by ztc 2023-02-23 [Optimize runtime No.5482] --end /
      } catch (Exception e) {
//    	  EventLogMessage eventLogMessage = new EventLogMessage();
//    	  eventLogMessage.setLogMessage(e.getMessage());
//    	  logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);
        // wp アプリケーションログの適正化 Add Start
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
        // wp アプリケーションログの適正化 Add End
        return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      }

      // 終了日が未設定の場合、患者治療パターンを更新する
      if ("false".equals(bodyData.getIs_deadline())) {
        String itemName = null != bodyData.getTare_info() ? "TARE" : "OFF_WATER";
        String editInfo = null != bodyData.getTare_info() ? bodyData.getTare_info() : bodyData.getOff_water_info();
        //mod 10813 無期限で治療予定を作成した際、pat_treatment_patternのreg_dateとup_dateが、選択した治療方法セットのreg_dateとup_dateの日時になる zhao start
//        this.updatePatTreatmentPattern(
//          patId,
//          facilityCd,
//          this.getValueList(bodyData.getInd_treatment_cd()),
//          this.getLongList(bodyData.getInd_kur_cd()),
//          treatWeekList,
//          upDate,
//          editInfo,
//          itemName
//        );
        Timestamp regDateNow = new Timestamp(System.currentTimeMillis());
        this.updatePatTreatmentPattern(
          patId,
          facilityCd,
          this.getValueList(bodyData.getInd_treatment_cd()),
          this.getLongList(bodyData.getInd_kur_cd()),
          treatWeekList,
          regDateNow,
          editInfo,
          itemName
        );
        //mod 10813 無期限で治療予定を作成した際、pat_treatment_patternのreg_dateとup_dateが、選択した治療方法セットのreg_dateとup_dateの日時になる zhao end
      }

// del #7188 2023/01/14 治療条件，装置設定を変更すると次患者が再送される dou start
//      String message;
//      try {
//        LocalDateTime update = LocalDateTime.now();
//        Long skipCode = Long.parseLong("0");
//        // 次患者更新処理
//        for (OrdMain ord : ordMain) {
//          Long bedCd = Long.parseLong(ord.getIndBedCd().toString());
//          Long targetOrdNo = ord.getOrdNo();
//          // 登録されているベッド(ベッド移動なしのため変更後として処理※変更前は条件送信キャンセルとして処理されるため)
//          message = ordMainResource.callDoCancelSetNextPatInfo(facilityCd, skipCode, bedCd, targetOrdNo, true, update);
//        }
//      } catch (RuntimeException e) {
////      message = "「条件送信キャンセル」「次患者更新」処理失敗";
////      EventLogMessage eventLogMessage = new EventLogMessage();
////      eventLogMessage.setLogMessage( message);
////      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);
////      eventLogMessage.setLogMessage(e.getMessage());
////      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);
//        e.printStackTrace();
//        // wp アプリケーションログの適正化 Add Start
//        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
//        // wp アプリケーションログの適正化 Add End
//      }
// del #7188 2023/01/14 治療条件，装置設定を変更すると次患者が再送される dou end

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      //add by ztc 2023-02-27 [Optimize runtime No.5482] --start
      // mod #10553 ④装置設定＞風袋・除水補正にて指示への展開保存をした場合には、変更された治療予定毎の連携イベントが必要 piao start
      List<OrdMain> dellistForJournal = ordMain.stream().distinct().collect(Collectors.toList());
      List<JournalCreateRequestPayload> ctlNoList = new ArrayList<>();
      if(!dellistForJournal.isEmpty()){
        int isFlag = null != bodyData.getTare_info() ? 0 : 1;
        String crud = "U";
        String opeCd = null;
        if (0 == isFlag) {
          opeCd = "004030"; // 風袋
        } else {
          opeCd = "004031"; // 除水
        }
        // del #11004 連携イベント発生部分不正 piao start
        // int modify_send_class = treatmentRecordService.getCoopIniSchModifySendClass(facilityCd);
        // del #11004 連携イベント発生部分不正 piao end
        String hospPatId = null;
        if (facilityCd == null && patId != null) {
          List<Long> patIdList = new ArrayList<Long>();
          patIdList.add(patId);
          List<PatPersonalMain> listPatPersonalMain = patPersonalMainDao.selectByIdList(patIdList);
          PatPersonalMain patPersonalMain = listPatPersonalMain.get(0);
          facilityCd = patPersonalMain.getFacility_cd();
          hospPatId = patPersonalMain.getHosp_pat_id();
        }
        for (int i = 0; i < dellistForJournal.size(); i++) {
          // del #11004 連携イベント発生部分不正 piao start
          // if (modify_send_class == 2) {
          //   JournalCreateRequestPayload deljournalCreateRequestPayload = new JournalCreateRequestPayload();
          //   deljournalCreateRequestPayload.setFacilityCd(facilityCd);
          //   deljournalCreateRequestPayload.setCrud("D");
          //   deljournalCreateRequestPayload.setHospPatId(hospPatId);
          //   deljournalCreateRequestPayload.setPatId(Long.valueOf(bodyData.getPat_id()));
          //   deljournalCreateRequestPayload.setUserId(user.getUserId());
          //   deljournalCreateRequestPayload.setOpeCd(opeCd);
          //   deljournalCreateRequestPayload.setOrdNo(dellistForJournal.get(i).getOrdNo());
          //   deljournalCreateRequestPayload.setBaseDate(dellistForJournal.get(i).getTreatDate());
          //   ctlNoList.add(deljournalCreateRequestPayload);
          // }
          // del #11004 連携イベント発生部分不正 piao end
          JournalCreateRequestPayload payload = new JournalCreateRequestPayload();
          payload.setOpeCd(opeCd);
          payload.setCrud(crud);
          // del #11004 連携イベント発生部分不正 piao start
          // if (modify_send_class == 2) {
          //   payload.setCrud("C");
          // }
          // del #11004 連携イベント発生部分不正 piao end
          payload.setFacilityCd(facilityCd);
          payload.setHospPatId(hospPatId);
          payload.setPatId(Long.valueOf(bodyData.getPat_id()));
          payload.setOrdNo(dellistForJournal.get(i).getOrdNo());
          payload.setBaseDate(dellistForJournal.get(i).getTreatDate());
          payload.setUserId(user.getUserId());
          ctlNoList.add(payload);
        }
      }
      // mod #10553 ④装置設定＞風袋・除水補正にて指示への展開保存をした場合には、変更された治療予定毎の連携イベントが必要 piao end
      if (!CollectionUtils.isEmpty(ctlNoList)){
        journalService.callCreateJournalForCtrNo(ctlNoList);
      }
      //add by ztc 2023-02-27 [Optimize runtime No.5482] --end
      //add 9355 ljx start
      //指示履歴を登録
      // del 11119 by kangjie 20241007 start
//      if(indHistoryMakeService.isToMongo()){
//        ApiEntityOrdMain.ValiCreateTreatPlan body =new ApiEntityOrdMain.ValiCreateTreatPlan();
//        BeanUtils.copyProperties(bodyData,body);
//        body.setInd_user_id(new BigInteger(bodyData.getInd_user()));
//        body.setUpd_user_id(new BigInteger(user.getUserId().toString()));
//        if(bodyData.getTare_info() != null){
//          indHistoryMakeService.createIndTareInfoHistory(body,ordMain.get(0),bodyData.getTare_info(),treatWeekList,"風袋","2");
//        }
//        if(bodyData.getOff_water_info() != null){
//          indHistoryMakeService.createIndTareInfoHistory(body,ordMain.get(0),bodyData.getOff_water_info(),treatWeekList,"除水補正","2");
//        }
//      }
      // del 11119 by kangjie 20241007 end
      //add 9355 ljx end
      return new ResponseEntity<>(HttpStatus.OK);
    }

    /**
     * 実績:風袋・除水補正更新
     */
    @PostMapping("updateRstTareOffWaterInfo")
    public ResponseEntity<Void> updateRstTareOffWaterInfo(
        @Validated @RequestBody ApiEntityDeviceSetInfo.ValiTareAndOffWater bodyData ,BindingResult validationResult
        ,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
        @AuthenticationPrincipal NtssUser ntssUser
        // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) throws URISyntaxException,JSONException,ArrayIndexOutOfBoundsException,NullPointerException {


      // wp アプリケーションログの適正化 Add Start
      String mappingUrl = Uri.DEVICE_SET_INFO + "/updateRstTareOffWaterInfo";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, BEFORE_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End

      // オーダー番号リスト
      List<Long> ordNoList = this.getLongValueList(bodyData.getOrd_no());
      // #11205 -ペンテスト2－4認可制御の不備  mod 20260416 start
      if (!ntssUser.isNkkAdminUser()) {
        long count = deviceSetInfoService.countByOrdNoAndFacilityCd(ntssUser.getFacilityCd(), ordNoList);
        if (count != ordNoList.size()) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " ordNoList=" + ordNoList + " count=" + count + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
      }
      // #11205 -ペンテスト2－4認可制御の不備  mod 20260416 end
      // 風袋情報
      String tareInfo = bodyData.getTare_info();
      // 除水補正情報
      String offWaterInfo = bodyData.getOff_water_info();
      // 更新日時
      Timestamp upDate = Timestamp.valueOf(bodyData.getUp_date());
      try {
        for (int i = 0; i < ordNoList.size(); i++) {
          int updateCount = deviceSetInfoService.updateRstTareOffWaterInfo(
              ordNoList.get(i),
              tareInfo,
              offWaterInfo,
              upDate
           );
        }
        } catch (Exception e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
//          EventLogMessage eventLogMessage = new EventLogMessage();
//          eventLogMessage.setLogMessage(e.getMessage());
//          logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);
        // wp アプリケーションログの適正化 Add Start
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
        // wp アプリケーションログの適正化 Add End
          return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.OK);
    }

    /**
     * 指示:風袋・除水補正(未来)
     * @description 患者情報を更新時に未来への指示へ更新を許可した際に行う処理
     */
    @PostMapping("updateFutureIndTareOffWaterInfo")
    public ResponseEntity<Void> updateFutureIndTareOffWaterInfo(
        @Validated @RequestBody ApiEntityDeviceSetInfo.ValiTareAndOffWater bodyData ,BindingResult validationResult
        // add #10553 ④装置設定＞風袋・除水補正にて指示への展開保存をした場合には、変更された治療予定毎の連携イベントが必要 piao start
      , @AuthenticationPrincipal NtssUser user
        // add #10553 ④装置設定＞風袋・除水補正にて指示への展開保存をした場合には、変更された治療予定毎の連携イベントが必要 piao end
        ) throws URISyntaxException,JSONException,ArrayIndexOutOfBoundsException,NullPointerException {
      // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 start
      if(!user.isNkkAdminUser()) {
        if (bodyData != null && bodyData.getFacility_cd() != null &&
          !bodyData.getFacility_cd().equals(user.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "user.getFacilityCd()=" + user.getFacilityCd() + " facility_cd=" + bodyData.getFacility_cd() + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
      }
      // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 end


      // wp アプリケーションログの適正化 Add Start
      String mappingUrl = Uri.DEVICE_SET_INFO + "/updateFutureIndTareOffWaterInfo";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, BEFORE_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End


      /* modify by KongShuai  2023-02-01 [Transaction,CodeOptimization] start */
//      // 患者情報
//      Long patId = this.getLongPattern(bodyData.getPat_id());
//      // 本日の日付け取得
//      LocalDateTime nowDate = LocalDateTime.now();
//      DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("yyyyMMdd");
//      String today = nowDate.format(dateTimeFormatter);
//      // 更新日時
//      Timestamp upDate = Timestamp.valueOf(bodyData.getUp_date());
//      List<String> getTateAndOffWater = null;
//      // 対象患者の風袋・除水補正情報を取得
//      try {
//        getTateAndOffWater = deviceSetInfoService.selectTareAndOffWater(null, patId, null, null);
//      } catch (Exception e) {
//        e.printStackTrace();
////        EventLogMessage eventLogMessage = new EventLogMessage();
////        eventLogMessage.setLogMessage(e.getMessage());
////        logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);
//
//        // wp アプリケーションログの適正化 Add Start
//        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
//        // wp アプリケーションログの適正化 Add End
//        return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
//      }
//      JSONObject tareAndOffWaterInfo = new JSONObject(getTateAndOffWater.get(0));
//      // 風袋もしくは除水補正情報(患者情報)
//      JSONObject patInfo = null;
//      // 風袋もしくは除水補正の反映曜日
//      JSONArray weeksArr = null;
//      // 風袋、除水補正反映フラグ(0->風袋、1->除水補正)
//      int isFlag = null != bodyData.getTare_info() ? 0 : 1;
//
//      // 風袋情報格納処理
//      if (0 == isFlag) {
//        patInfo = new JSONObject(tareAndOffWaterInfo.getString("tare_info"));
//        weeksArr = new JSONArray(bodyData.getTare_info());
//      // 除水補正情報格納処理
//      } else {
//        patInfo = new JSONObject(tareAndOffWaterInfo.getString("off_water_info"));
//        weeksArr = new JSONArray(bodyData.getOff_water_info());
//      }
//
//      for (int i = 0; i < weeksArr.length(); i++) {
//        String tareInfo = null;
//        String offWaterInfo = null;
//        if (0 == isFlag) {
//          tareInfo = patInfo.getJSONObject(weeksArr.getString(i)).toString();
//        } else {
//          offWaterInfo = patInfo.getJSONObject(weeksArr.getString(i)).toString();
//        }
//
//        // 更新処理(ord_main更新)
//        deviceSetInfoService.updateFutureIndTareAndOffWater(
//            patId,
//            today,
//            weeksArr.getInt(i),
//            tareInfo,
//            offWaterInfo,
//            upDate
//            );
//        String facilityCd = null;
//        if (facilityCd == null && patId != null) {
//          List<Long> patIdList = new ArrayList<Long>();
//          patIdList.add(patId);
//          List<PatPersonalMain> listPatPersonalMain = patPersonalMainDao.selectByIdList(patIdList);
//          PatPersonalMain patPersonalMain = listPatPersonalMain.get(0);
//          facilityCd = patPersonalMain.getFacility_cd();
//        }
//        // 次患者更新呼び出し
//        // del #7188 2023/01/14 治療条件，装置設定を変更すると次患者が再送される dou start
//        // callDoCancelSetNextPatInfo(facilityCd, patId);
//        // del #7188 2023/01/14 治療条件，装置設定を変更すると次患者が再送される dou end
//        // 更新処理(pat_treatment_pattern更新)
//        patTreatmentPatternUtils.updateIndTareAndOffWater(
//            tareInfo,
//            offWaterInfo,
//            patId,
//            facilityCd,
//            weeksArr.getInt(i)
//            );
//      }
      // add #10553 ④装置設定＞風袋・除水補正にて指示への展開保存をした場合には、変更された治療予定毎の連携イベントが必要 piao start
      // 患者ID
      Long patId = this.getLongPattern(bodyData.getPat_id());
      // 施設コード
      String facilityCd = null;
      String hospPatId = null;
      if (facilityCd == null && patId != null) {
        List<Long> patIdList = new ArrayList<Long>();
        patIdList.add(patId);
        List<PatPersonalMain> listPatPersonalMain = patPersonalMainDao.selectByIdList(patIdList);
        PatPersonalMain patPersonalMain = listPatPersonalMain.get(0);
        facilityCd = patPersonalMain.getFacility_cd();
        hospPatId = patPersonalMain.getHosp_pat_id();
      }
      // 治療開始日(本日の日付け取得) 治療終了日(null)
      LocalDateTime nowDate = LocalDateTime.now();
      DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("yyyyMMdd");
      String today = nowDate.format(dateTimeFormatter);

      // 風袋、除水補正反映フラグ(0->風袋、1->除水補正)
      int isFlag = null != bodyData.getTare_info() ? 0 : 1;

      // 風袋もしくは除水補正の反映曜日
      JSONArray weeksArr = null;
      // 風袋情報格納処理
      if (0 == isFlag) {
        weeksArr = new JSONArray(bodyData.getTare_info());
        // 除水補正情報格納処理
      } else {
        weeksArr = new JSONArray(bodyData.getOff_water_info());
      }
      // 治療曜日リスト
      List<Integer> treatWeekList = new ArrayList<>();
      for (int i = 0; i < weeksArr.length(); i++) {
        treatWeekList.add(weeksArr.getInt(i));
      }
      // 治療方法リスト(空List)
      List<Integer> treatmentList = new ArrayList<>();
      // クールリスト(空List)
      List<Long> kurList = new ArrayList<>();


      List<OrdMain> ordMain = new ArrayList();
      // 更新対象の治療情報を取得
      try {
        /* upd by chamaojia 2026-05-18 [12703] 【securify】API診断を実施するとntss-admin-webが落ちる --start */
        // ordMain = ordMainService.findUpdateTarget(
        ordMain = ordMainService.selectOrdMainForTareOrOffwaterJournal(
          patId,
          facilityCd,
          today,
          null,
          treatWeekList,
          treatmentList,
          kurList,
          "0"
        );
        /* upd by chamaojia 2026-05-18 [12703] 【securify】API診断を実施するとntss-admin-webが落ちる --end */
      } catch (Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end

        // wp アプリケーションログの適正化 Add Start
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
        // wp アプリケーションログの適正化 Add End
      }
      // add #10553 ④装置設定＞風袋・除水補正にて指示への展開保存をした場合には、変更された治療予定毎の連携イベントが必要 piao end
      try {

        deviceSetInfoService.updateFutureIndTareOffWaterInfo(bodyData);

      } catch (Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
        return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      }
      /* modify by KongShuai  2023-02-01 [Transaction,CodeOptimization] end */
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      // del 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou start
      // add by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --start
//      List<Map<String, Object>> dellistForJournal = bodyData.getOldOrdMainList();
//      List<JournalCreateRequestPayload> ctlNoList = new ArrayList<>();
//      if(dellistForJournal != null && !dellistForJournal.isEmpty()){
//        String editWeek = null;
//        if ("010001".equals(bodyData.getOpe_cd())) {
//          editWeek = bodyData.getTare_info();
//        } else if ("010002".equals(bodyData.getOpe_cd())) {
//          editWeek = bodyData.getOff_water_info();
//        }
//        Integer bodyTreatDate = 0;
//        if (bodyData.getTreatDate() != null) {
//          bodyTreatDate = Integer.parseInt(bodyData.getTreatDate());
//        }
//        for (int i = 0; i < dellistForJournal.size(); i++) {
//          Integer treatDate = 0;
//          if (dellistForJournal.get(i).get("treatDate") != null) {
//            treatDate = Integer.parseInt(dellistForJournal.get(i).get("treatDate").toString());
//          }
//          String treatWeek = null;
//          if (dellistForJournal.get(i).get("treatWeek") != null) {
//            treatWeek = dellistForJournal.get(i).get("treatWeek").toString();
//          }
//          if ("0".equals(dellistForJournal.get(i).get("rstDialysisState")) && treatDate > bodyTreatDate && editWeek.indexOf(treatWeek) != -1) {
//            JournalCreateRequestPayload payload = new JournalCreateRequestPayload();
//            payload.setOpeCd(bodyData.getOpe_cd());
//            payload.setCrud(bodyData.getCrud());
//            payload.setFacilityCd(bodyData.getFacility_cd());
//            payload.setHospPatId(bodyData.getHosp_pat_id());
//            if (bodyData.getPat_id() != null) {
//              payload.setPatId(Long.valueOf(bodyData.getPat_id()));
//            }
//            if (dellistForJournal.get(i).get("ordNo") != null) {
//              payload.setOrdNo(Long.valueOf(dellistForJournal.get(i).get("ordNo").toString()));
//            }
//            payload.setBaseDate(dellistForJournal.get(i).get("treatDate").toString());
//            if (bodyData.getInd_user() != null) {
//              payload.setUserId(Long.valueOf(bodyData.getInd_user()));
//            }
//            ctlNoList.add(payload);
//          }
//        }
//      }
//      if (!CollectionUtils.isEmpty(ctlNoList)){
//        journalService.callCreateJournalForCtrNo(ctlNoList);
//      }
      // add by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --end
      // del 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou end
      // add #10553 ④装置設定＞風袋・除水補正にて指示への展開保存をした場合には、変更された治療予定毎の連携イベントが必要 piao start
      List<OrdMain> dellistForJournal = ordMain.stream().distinct().collect(Collectors.toList());
      List<JournalCreateRequestPayload> ctlNoList = new ArrayList<>();
      if(!dellistForJournal.isEmpty()){
        String crud = "U";
        String opeCd = null;
        // del #11004 連携イベント発生部分不正 piao start
        // int modify_send_class = treatmentRecordService.getCoopIniSchModifySendClass(facilityCd);
        // del #11004 連携イベント発生部分不正 piao end
        for (int i = 0; i < dellistForJournal.size(); i++) {
          if(dellistForJournal.get(i).getIndKurCd() != 0){
            if (0 == isFlag) {
              opeCd = "010001"; // 風袋
            } else {
              opeCd = "010002"; // 除水
            }
          } else {
            if (0 == isFlag) {
              opeCd = "010012"; // 風袋
            } else {
              opeCd = "010013"; // 除水
            }
          }
          // del #11004 連携イベント発生部分不正 piao start
          // if (modify_send_class == 2) {
          //   JournalCreateRequestPayload deljournalCreateRequestPayload = new JournalCreateRequestPayload();
          //   deljournalCreateRequestPayload.setFacilityCd(facilityCd);
          //   deljournalCreateRequestPayload.setCrud("D");
          //   deljournalCreateRequestPayload.setHospPatId(hospPatId);
          //   deljournalCreateRequestPayload.setPatId(Long.valueOf(bodyData.getPat_id()));
          //   deljournalCreateRequestPayload.setUserId(user.getUserId());
          //   deljournalCreateRequestPayload.setOpeCd(opeCd);
          //   deljournalCreateRequestPayload.setOrdNo(dellistForJournal.get(i).getOrdNo());
          //   deljournalCreateRequestPayload.setBaseDate(dellistForJournal.get(i).getTreatDate());
          //   ctlNoList.add(deljournalCreateRequestPayload);
          // }
          // del #11004 連携イベント発生部分不正 piao end
          JournalCreateRequestPayload payload = new JournalCreateRequestPayload();
          payload.setOpeCd(opeCd);
          payload.setCrud(crud);
          // del #11004 連携イベント発生部分不正 piao start
          // if (modify_send_class == 2) {
          //   payload.setCrud("C");
          // }
          // del #11004 連携イベント発生部分不正 piao end
          payload.setFacilityCd(facilityCd);
          payload.setHospPatId(hospPatId);
          payload.setPatId(Long.valueOf(bodyData.getPat_id()));
          payload.setOrdNo(dellistForJournal.get(i).getOrdNo());
          payload.setBaseDate(dellistForJournal.get(i).getTreatDate());
          payload.setUserId(user.getUserId());
          ctlNoList.add(payload);
        }
      }
      if (!CollectionUtils.isEmpty(ctlNoList)){
        journalService.callCreateJournalForCtrNo(ctlNoList);
      }
      // add #10553 ④装置設定＞風袋・除水補正にて指示への展開保存をした場合には、変更された治療予定毎の連携イベントが必要 piao end

      return new ResponseEntity<>(HttpStatus.OK);
    }


  /**
   * 患者情報:ホスト報知更新
   */
  @PostMapping("updateHostNotificationInfo")
  public ResponseEntity<Void> updateHostNotificationInfo(
    @Validated @RequestBody ApiEntityDeviceSetInfo.ValiHostNotification bodyData ,BindingResult validationResult
    ,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    @AuthenticationPrincipal NtssUser ntssUser
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) throws URISyntaxException,JSONException,ArrayIndexOutOfBoundsException,NullPointerException {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 start
      if(!ntssUser.isNkkAdminUser()) {
        String facilityCd = bodyData.getFacility_cd();
        if (facilityCd != null && !facilityCd.isEmpty() &&
          !facilityCd.equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " facilityCd=" + facilityCd + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 end


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_SET_INFO + "/updateHostNotificationInfo";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    // 患者ID
    Long patId = this.getLongPattern(bodyData.getPat_id());
    // 施設コード
    String facilityCd = bodyData.getFacility_cd();
    // ホスト報知情報
    String hostNotificationInfo = bodyData.getHost_notification_info();
    // dataSourceタイプ
    String dataSourceType = bodyData.getData_source_type();
    // 更新日時
    Timestamp upDate = Timestamp.valueOf(bodyData.getUp_date());
    try {
      if (dataSourceType.equals("1")) {
        // 装置設定デフォルトマスタ
        deviceSetInfoService.updateSysHostNotificationInfo(facilityCd, hostNotificationInfo, upDate);
      } else if (dataSourceType.equals("2")) {
        // 患者情報
        deviceSetInfoService.updatePatHostNotificationInfo(patId, facilityCd, hostNotificationInfo, upDate);
      }

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_DEVICE_SET, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * List型の変更処理(JSONObject -> Integer)
   * @param listPattern
   * @return 選択数値INDEXの配列
   */
  private List<Integer> getIntListPattern(String listPattern)
  {
    int count = 0;
    JSONArray json;
    List<Integer> Array = new ArrayList<Integer>();
    if (listPattern  == null) {
      Array = new ArrayList<Integer>();
    } else {
      try {
        json = new JSONArray(listPattern);
        if (json.length() != 0) {
          // 指定されたString型の配列をInteger型に
          for (int i = 0; i < json.length(); i++) {
            JSONObject jobj = (JSONObject)(json.get(i));
            Array.add((int)(jobj.get("value")));
            count++;
          }
        } else {
          Array = new ArrayList<Integer>();
        }
      } catch (JSONException e) {
        //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
        EventLogMessage eventLogMessage = new EventLogMessage();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
eventLogMessage.setLogMessage("エラー発生："+ExcetionStackTraceToString(e));
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
        logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);
        //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
        return null;
      }
    }
    return Array;
  }

  /**
   * 患者治療パターンの更新処理
   */
  private Integer updatePatTreatmentPattern(
      Long patId,
      String facilityCd,
      List<Integer> treatmentCd,
      List<Long> kurCd,
      List<Integer> weeksArray,
      Timestamp upDate,
      String editInfo,
      String itemName
     ) {
    PatTreatmentPatternEditData editData = new PatTreatmentPatternEditData();
    List<PatTreatmentPatternUtils.IND_ITEM> updateIndItemList = Arrays.asList();
    switch (itemName) {
    // 装置設定情報
    case "DEVICE_SET_INFO":
      updateIndItemList = Arrays.asList(PatTreatmentPatternUtils.IND_ITEM.DEVICE_SET_INFO);
      editData.setIndDeviceSetInfo(editInfo);
      break;

    // 風袋情報
    case "TARE":
      updateIndItemList = Arrays.asList(PatTreatmentPatternUtils.IND_ITEM.TARE);
      editData.setIndTareInfo(editInfo);
      break;

    // 除水補正情報
    case "OFF_WATER":
      updateIndItemList = Arrays.asList(PatTreatmentPatternUtils.IND_ITEM.OFF_WATER);
      editData.setIndOffWaterInfo(editInfo);
      break;

    default:
      break;
    }
    // 患者治療パターン更新処理呼び出し
    int patPatternCount = patTreatmentPatternUtils.updatePatTreatmentPatternIndItem(
        patId,
        facilityCd,
        treatmentCd,
        kurCd,
        weeksArray,
        updateIndItemList,
        upDate,
        editData,
      // modify 9664 by kangjie 20240425 start
      new ArrayList<OrdMain>(),new ArrayList<MstTreatment>()
      // modify 9664 by kangjie 20240425 end
      // add 10150_9664 by kangjie 20240628 start
      ,null
      // add 10150_9664 by kangjie 20240628 end
      );

    return patPatternCount;
  }


  /**
   * List型の変更処理(JSONObject -> Long)
   * @param listPattern
   * @return Long型の配列
   */
  private List<Long> getLongListPattern(String listPattern) {
    int count = 0;
    JSONArray json;
    List<Long> Array = new ArrayList<Long>();
    if (listPattern  == null) {
      Array = new ArrayList<Long>();
    } else {
      try {
        json = new JSONArray(listPattern);
        if (json.length() != 0) {
          // 指定されたString型の配列をLong型に
          for (int i = 0; i < json.length(); i++) {
            JSONObject jobj = (JSONObject)(json.get(i));
            Long setData = Long.parseLong((String)(jobj.get("value")));
            Array.add(setData);
            count++;
          }
        } else {
          Array = new ArrayList<Long>();
        }
      } catch (JSONException e) {
        //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
        EventLogMessage eventLogMessage = new EventLogMessage();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
eventLogMessage.setLogMessage("エラー発生："+ExcetionStackTraceToString(e));
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
        logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);
        //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
        return null;
      }
    }
    return Array;
  }


  /**
   * List型の変更処理(JSONObject -> String)
   * @param listPattern
   * @return Long型の配列
   */
  private List<String> getStringListPattern(String listPattern) {
    int count = 0;
    JSONArray json;
    List<String> Array = new ArrayList<String>();
    if (listPattern  == null) {
      Array = new ArrayList<String>();
    } else {
      try {
        json = new JSONArray(listPattern);
        if (json.length() != 0) {
          // 指定されたString型の配列をLong型に
          for (int i = 0; i < json.length(); i++) {
            JSONObject jobj = (JSONObject)(json.get(i));
            String setData = (String)(jobj.get("value"));
            Array.add(setData);
            count++;
          }
        } else {
          Array = new ArrayList<String>();
        }
      } catch (JSONException e) {
        //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
        EventLogMessage eventLogMessage = new EventLogMessage();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
eventLogMessage.setLogMessage("エラー発生："+ExcetionStackTraceToString(e));
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
        logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);
        //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
        return null;
      }
    }
    return Array;
  }


  /**
   * String型 -> int型 変換
   * @param  intPattern
   * @return int型
   */
  private int getIntPattern(String intPattern){
    int intData = 0;
    if (intPattern == null) {
      return -1;
    } else {
      intData = Integer.parseInt(intPattern);
      return intData;
    }
  }

  /**
   * String型 -> Long型 変換
   * @param  longPattern
   * @return Long型
   */
  private Long getLongPattern(String longPattern){
    Long longData;
    if (longPattern == null) {
      return null;
    } else {
      longData = Long.parseLong(longPattern);
      return longData;
    }
  }

  /**
   * 装置設定受信データチェック処理
   * @param tableFlag
   */
  private Boolean checkDeviceSetInfo(String tableFlag, String facilityCd, String patId, String ordNo, String startDate, String week) {
    Boolean result = true;
    if (null == tableFlag) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("テーブル区分が指定されていません");
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);
      result = false;
    }

    int table_flag = this.getIntPattern(tableFlag);

    if (null == facilityCd) {
      // 施設情報異常
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage( "施設コードが指定されていません");
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);
      result = false;
    }

    if (table_flag == 1) {
      // 患者情報
      if (null == patId) {
        // 治療情報異常
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(  "患者IDが指定されていません");
        logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);
        result = false;
      }
    } else if (table_flag == 2) {
      // 治療情報
      if (null == ordNo) {
        // 治療情報異常
        if (null == startDate && null == week) {
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage( "Ord番号、開始日、曜日情報がいずれも指定されていません");
          logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);
          result = false;
        }
      }
    }
    return result;
  }

  /**
   * JSON配列データから値を取得し、Long型配列データを返す
   * @param stringList
   * @return
   */
  private List<Long> getLongValueList(String stringList)
  {
    JSONArray json;
    List<Long> valueArry = new ArrayList<Long>();
    try {
      if (null == stringList) return valueArry;
      json = new JSONArray(stringList);
      // 選択された値を配列に格納
      for (int i = 0; i < json.length(); i++) {
        int intDate = (int)(json.get(i));
        long l = intDate;
        valueArry.add(l);
      }
    } catch (JSONException e) {
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
eventLogMessage.setLogMessage("エラー発生："+ExcetionStackTraceToString(e));
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
      return null;
    }
    return valueArry;
  }


  /***
   * JSON配列データから値を取得し、Integer配列データを返す
   * @param stringList
   * @return
   */
  private List<Integer> getValueList(String stringList)
  {
    JSONArray json;
    List<Integer> valueArry = new ArrayList<Integer>();
    try {
      if (null == stringList) return valueArry;
      json = new JSONArray(stringList);
      // 選択された値を配列に格納
      for (int i = 0; i < json.length(); i++) {
        valueArry.add((int)(json.get(i)));
      }
    } catch (JSONException e) {
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
eventLogMessage.setLogMessage("エラー発生："+ExcetionStackTraceToString(e));
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
      return null;
    }
    return valueArry;
  }


  /**
   * 曜日パターン情報加工
   * @param weekPattern 選択曜日のJsonデータ
   * @return 選択曜日INDEXの配列
   */
  private List<Integer> getWeekPattern(String weekPattern)
  {
    int count = 0;
    //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
    EventLogMessage eventLogMessage = new EventLogMessage();
    //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
    JSONArray json;
    List<Integer> weeksArry = new ArrayList<Integer>();
    try {
      json = new JSONArray(weekPattern);
      // 選択された曜日を配列に格納
      JSONObject allWeek = (JSONObject)(json.get(0));
      // 曜日指定で全(1)が押されたらweeksArryに月(1),火曜(2),水(3),木(4),金(5),土(6),日(7)を格納
      if ((boolean)(allWeek.get("done")) == true) {
        //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
        eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("全曜日選択");
        logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);
        //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
        for (int i = 0; i < 7; i++) {
         weeksArry.add(i+1);
         count ++;
        }
      } else {
        // 指定された曜日をweeksArryに格納
        for (int i = 1; i < json.length(); i++) {
          JSONObject jObj = (JSONObject)(json.get(i));
          if ((boolean)(jObj.get("done")) == true) {
            weeksArry.add((int)(jObj.get("value")));
            count++;
            //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
            eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage("登録曜日："+i);
            logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);
            //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
          }
        }
      }
      // 曜日選択がされていない場合SQLでweeksArryを条件から外す
      if (count <= 0) {
        weeksArry.add(0);
      }
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("選択曜日：" + weeksArry.get(0));
      logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
    } catch (JSONException e) {
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
eventLogMessage.setLogMessage("エラー発生："+ExcetionStackTraceToString(e));
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
      return null;
    }

    return weeksArry;
  }

  /**
   * JSON配列データをLong配列に変換して返す
   * @param stringList
   * @return
   */
  private List<Long> getLongList(String stringList) {
    List<Long> longList = new ArrayList<Long>();
    try {
      // 値が入っていなければ、処理を終了して空の配列を返す
      if (null == stringList) return longList;
      JSONArray json = new JSONArray(stringList);
      // 選択された値を配列に格納
      for (int i = 0; i < json.length(); i++) {
        int intData = (int)(json.getInt(i));
        long l = intData;
        longList.add(l);
      }
    } catch (JSONException e) {
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
eventLogMessage.setLogMessage("エラー発生："+ExcetionStackTraceToString(e));
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
      return null;
    }
    return longList;
  }

  //del #10412 次患者更新関連全体見直し対応 朴 start
//  /**
//   * 次患者更新呼び出し
//   */
//  private void callDoCancelSetNextPatInfo(String facilityCd, Long patId,String dialyzer,String gridCell) {
//    String message;
//    try {
//      List<OrdMain> ordMainList = new ArrayList();
//      List<MntMachineState> mntMachineStateList = new ArrayList();
//      if (patId == null) {
//        mntMachineStateList = mntMachineStateDao.selectNextOrdNoByFacilityCd(facilityCd);
//      } else {
//        mntMachineStateList = mntMachineStateDao.selectByNextPatId(facilityCd, patId);
//      }
//      List<Long> ordNoList = mntMachineStateList.stream().map(item -> item.getNextOrdNo()).distinct().collect(Collectors.toList());
//      ordMainList = ordMainService.selectByOrdNoList(ordNoList);
//
//      LocalDateTime update = LocalDateTime.now();
//      Long skipCode = Long.parseLong("0");
//      // 次患者更新処理
//      for (OrdMain ord: ordMainList) {
//        Long bedCd = Long.parseLong(ord.getIndBedCd().toString());
//        Long targetOrdNo = ord.getOrdNo();
//        //add 7188 治療条件，装置設定を変更すると次患者が再送される start zhao
//        JSONObject indCondInfoJsonObj = new JSONObject(ord.getIndCondInfo());
//        //ダイアライザ -> 5
//        // mod #9973 Resolve null exception for key 20240117 ztc start
////        if(indCondInfoJsonObj.has("5")){
//        if(indCondInfoJsonObj.has("5") && !indCondInfoJsonObj.isNull("5")){
//        // mod #9973 Resolve null exception for key 20240117 ztc end
//          JSONObject dialyzerInfoJsonObj = new JSONObject(indCondInfoJsonObj.get("5").toString());
//          if(dialyzerInfoJsonObj.get("value")!=null){
//            Integer dialyzerCode = Integer.parseInt(dialyzerInfoJsonObj.get("value").toString()) ;
//            MstDialyzer mstDialyzer = mstDialyzerDao.selectByDialyzerCd(SelectOptions.get(),dialyzerCode);
//            if(("p".equals(dialyzer)&&"0".equals(mstDialyzer.getDialyzerType()))||("d".equals(dialyzer)&&"1".equals(mstDialyzer.getDialyzerType()))||"pd".equals(dialyzer)){
        //message = ordMainResource.callDoCancelSetNextPatInfo(facilityCd, skipCode, bedCd, ord, true, update);
//            }
//          }
//        }
//        //補液選択 -> 21
//        // mod #9973 Resolve null exception for key 20240117 ztc start
////        if(indCondInfoJsonObj.has("21")){
//        if(indCondInfoJsonObj.has("21") && !indCondInfoJsonObj.isNull("21")){
//        // mod #9973 Resolve null exception for key 20240117 ztc end
//          JSONObject gridCellInfoJsonObj = new JSONObject(indCondInfoJsonObj.get("21").toString());
//          if(indCondInfoJsonObj.get("21")!=null){
//            Integer gridCellCode = Integer.parseInt(gridCellInfoJsonObj.get("value").toString()) ;
//            /* mod #9684_#9690 by zhangruixue 2023-08-31  --start */
////            if(("h".equals(gridCell)&&"0".equals(gridCellCode))||(("q".equals(gridCell)&&"1".equals(gridCellCode)))||"hq".equals(gridCell)){
//            // 前補液 -> 1    後補液 -> 0
//            if(("h".equals(gridCell) && 0 == gridCellCode) || (("q".equals(gridCell) && 1== gridCellCode))
//              || "hq".equals(gridCell)){
//              /* mod #9684_#9690 by zhangruixue 2023-08-31  --end */
//              message = ordMainResource.callDoCancelSetNextPatInfo(facilityCd, skipCode, bedCd, ord, true, update);
//            }
//          }
//        }
//        //mod 7188 治療条件，装置設定を変更すると次患者が再送される end zhao
//        // 登録されているベッド(ベッド移動なしのため変更後として処理※変更前は条件送信キャンセルとして処理されるため)
//        /* mod #5482 by zhangruixue 2023-03-02 スケジュール --start */
////        message = ordMainResource.callDoCancelSetNextPatInfo(facilityCd, skipCode, bedCd, targetOrdNo, true, update);
//        //message = ordMainResource.callDoCancelSetNextPatInfo(facilityCd, skipCode, bedCd, ord, true, update);
//        /* mod #5482 by zhangruixue 2023-03-02 スケジュール --end */
//      }
//    } catch (RuntimeException e) {
//      message = "「条件送信キャンセル」「次患者更新」処理失敗";
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage( message);
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_DEVICE_SET, SERVICE_NAME.FNSI, null);
//      e.printStackTrace();
//    }
//  }
  //del #10412 次患者更新関連全体見直し対応 朴 end

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
}
