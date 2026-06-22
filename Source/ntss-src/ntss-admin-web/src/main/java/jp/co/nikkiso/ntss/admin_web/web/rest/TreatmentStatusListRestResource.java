package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage;
import jp.co.nikkiso.ntss.admin_web.response.statusList.AlarmRecordResponse;
import jp.co.nikkiso.ntss.admin_web.response.statusList.AllConfirmResponse;
import jp.co.nikkiso.ntss.admin_web.response.statusList.CheckMediDoneResponse;
import jp.co.nikkiso.ntss.admin_web.response.statusList.TreatmentStatusListResponse;
import jp.co.nikkiso.ntss.admin_web.response.statusList.TreatmentStatusUpdateResponse;
import jp.co.nikkiso.ntss.admin_web.service.OrdMainService;
import jp.co.nikkiso.ntss.admin_web.service.statusList.DialysisConfirmThread;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.request.statusList.CheckAfterWeightRequest;
import jp.co.nikkiso.ntss.admin_web.request.statusList.DeleteRecordRequest;
import jp.co.nikkiso.ntss.admin_web.request.statusList.TreatmentStatusUpdateRequest;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.autoPrint.AutoPrintService;
import jp.co.nikkiso.ntss.admin_web.service.deviceEdgeOrder.DeviceEdgeOrderService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.statusList.AlarmRecordService;
import jp.co.nikkiso.ntss.admin_web.service.statusList.TreatmentStatusListService;
import jp.co.nikkiso.ntss.admin_web.service.utils.StrUtils;
import jp.co.nikkiso.ntss.admin_web.service.access.FacilityAccessService;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.MniMonitorCalendr;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.MstTreatmentStatusLayout;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.entity.custom.BedMachine;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.concurrent.DelegatingSecurityContextRunnable;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.sql.Timestamp;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;

@RestController
@RequestMapping(Uri.TREAT_STATUS_LIST)
public class TreatmentStatusListRestResource {
  @Autowired
  private FacilityAccessService facilityAccessService;


  /**
   * 通信サーバ指示出しサービス
   */
  @Autowired
  DeviceEdgeOrderService deviceEdgeOrderService;

  /**
   * 治療状況リスト情報の取得
   */
  @Autowired
  private TreatmentStatusListService treatmentStatusListService;

  /**
   * {@link OrdMainDao}
   */
  @Autowired
  private OrdMainDao ordMainDao;

  /**
   * {@link MntMachineState}
   */
  @Autowired
  MntMachineStateDao mntMachineStateDao;

  @Autowired
  PatMainDao patMainDao;

  @Autowired
  OrdMainService ordMainService;

  /**
   * 自動レポート印刷サービス
   */
  @Autowired
  private AutoPrintService autoPrintService;

  @Autowired
	LogService logService;

  // #10338 2024.03.28 mod 実績確定処理updateCheckAfterWeightを改修 TDC片口 start
//  //add 9480 後体重測定確認時の更新処理 guan start
//  @Autowired
//  private WebApiCallCommonUtil webApiCallCommonUtil;
//  //add 9480 後体重測定確認時の更新処理 guan end

  @Autowired
  private ApplicationContext applicationContext;
  // #10338 2024.03.28 mod 実績確定処理updateCheckAfterWeightを改修 TDC片口 end

  /**
   *指定した施設コードのベッド+装置情報一覧を取得
   * @param ntssUser 認証利用者情報
   * @return 利用者の属する施設に登録されいる {@link BedMachine} のリスト
   */
  @GetMapping("/bed_machine")
  public ResponseEntity<?> getBedMachineList(
      @AuthenticationPrincipal NtssUser ntssUser) {

    try {
      // ベッド+装置情報取得
      List<BedMachine> list = treatmentStatusListService.getBedMachineList(ntssUser.getFacilityCd());
      return new ResponseEntity<>(list, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST request error by get getBedMachineList : "+ e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 装置状態管理の一覧取得
   * @param facilityCd 施設コード
   * @return 施設コードに登録されいる {@link MntMachineState} のリスト
   */
  @GetMapping("/machine_state/{facilityCd}")
  public ResponseEntity<?> getMntMachineState(
      @PathVariable String facilityCd,
      @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 mod 20260421 start
    if (!hasFacilityAccess(ntssUser, facilityCd)) {
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }
    // #11205 mod 20260421 end

    long start = System.currentTimeMillis();
    try {
      // 装置状態管理のリストを取得
      List<MntMachineState> mntMachineState = treatmentStatusListService.machineSelectAllByFacilityCd(facilityCd);
      long end = System.currentTimeMillis();
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage((end - start) + "ms getMntMachineState");
      logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(mntMachineState, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST request error by get getMntMachineState : "+ e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   *指定した施設コードの治療状況レイアウト設定情報を取得
   * @param ntssUser 認証利用者情報
   * @param facilityCd 施設コード
   * @return 利用者の属する施設に登録されいる {@link MstTreatmentStatusLayout} のリスト
   */
  @GetMapping("/layout")
  public ResponseEntity<?> getTreatmentStatusLayout(
      @RequestParam(value = "facilityCd", required = false) String facilityCd,
      @AuthenticationPrincipal NtssUser ntssUser) {

    try {
      // 施設コードの指定なしの場合はユーザーの施設コードを使用
      // ※既存の動きに影響を与えないための保護措置
      if(StringUtils.isEmpty(facilityCd)) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("getTreatmentStatusLayout : not facilityCd param, use ntssUser facilityCd");
        logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
        facilityCd = ntssUser.getFacilityCd();
      } else if (!hasFacilityAccess(ntssUser, facilityCd)) {
        // #11205 mod 20260421 start
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        // #11205 mod 20260421 end
      }
      // レイアウト取得
      List<MstTreatmentStatusLayout> mstTreatmentStatusLayout = treatmentStatusListService
          .mstTreatmentStatusLayoutSelectByFacilityCd(facilityCd);
      return new ResponseEntity<>(mstTreatmentStatusLayout, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST request error by get getTreatmentStatusLayout : "+ e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 治療状況マップ表示用：指定した施設コード、治療状況レイアウト番号の情報を取得
   * @param facilityCd 施設コード
   * @param layoutNo レイアウト番号
   * @param nextPat 次患者表示   "0":表示しない  "1":現クール  "2": 次クール
   * @param bedLayoutId ベッドのレイアウト番号
   * @return
   */
  /* modify by chamaojia 2024-03-28 [10303、10304] add interface input parameters 【nextPat】【bedLayoutId】 --start */
  @GetMapping("/treatment_status_map/{facilityCd}/{layoutNo}/{bedGroupCd}/{nextPat}/{bedLayoutId}")
  public ResponseEntity<?> getTreatmentStatusListNextPatient(
          @PathVariable String facilityCd,
          @PathVariable String layoutNo,
          @PathVariable(required = false) String bedGroupCd,
          @PathVariable String nextPat,
          @PathVariable Long bedLayoutId,
          @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 mod 20260421 start
    if (!hasFacilityAccess(ntssUser, facilityCd)) {
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }
    // #11205 mod 20260421 end

  /* modify by chamaojia 2024-03-28 [10303、10304] add interface input parameters 【nextPat】【bedLayoutId】 --end */
    try {
      long start = System.currentTimeMillis();
      if (StrUtils.isNumber(layoutNo)) {
        /* modify by chamaojia 2024-03-28 [10303、10304] calling new methods --start */
        /* mod #8872 by zhangruixue 2023-06-21 --start */
//        TreatmentStatusListResponse res = treatmentStatusListService.getTreatmentStatusMapMachine(facilityCd, "00000000", layoutNo,bedGroupCd);
        /* mod #8872 by zhangruixue 2023-06-21 --end */
        TreatmentStatusListResponse res = treatmentStatusListService.getTreatmentStatusMapToBed(facilityCd, layoutNo, bedGroupCd,  nextPat, bedLayoutId);
        /* modify by chamaojia 2024-03-28 [10303、10304] calling new methods --end */
        long end = System.currentTimeMillis();
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage((end - start) + "ms getTreatmentStatusListNextPatient");
        logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);
        return new ResponseEntity<>(res, HttpStatus.OK);
      } else {
        throw new IllegalArgumentException("[layoutNo] is not number");
      }
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST request error by get getTreatmentStatusList : "+ e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 治療状況マップ表示用：指定した施設コード、日付以前、治療状況レイアウト番号のスケジュールの情報を取得
   * @param facilityCd 施設コード
   * @param treatDate 治療日
   * @param layoutNo レイアウト番号
   * @param bedLayoutId ベッドのレイアウト番号
   * @param kurCd クール
   * @return
   */
  /* modify by chamaojia 2024-03-28 [10303、10304] add interface input parameters 【bedLayoutId】【kurCd】 --start */
  @GetMapping("/treatment_status_map_onschedule/{facilityCd}/{treatDate}/{layoutNo}/{bedGroupCd}/{bedLayoutId}/{kurCd}")
  public ResponseEntity<?> getTreatmentStatusListOnSchedule(
          @PathVariable String facilityCd,
          @PathVariable String treatDate,
          @PathVariable String layoutNo,
          @PathVariable(required = false) String bedGroupCd,
          @PathVariable Long bedLayoutId,
          @PathVariable Long kurCd,
          @AuthenticationPrincipal NtssUser ntssUser
  ) {
    // #11205 mod 20260421 start
    if (!hasFacilityAccess(ntssUser, facilityCd)) {
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }
    // #11205 mod 20260421 end

  /* modify by chamaojia 2024-03-28 [10303、10304] add interface input parameters 【bedLayoutId】【kurCd】 --end */
    try {
      long start = System.currentTimeMillis();
      if (StrUtils.isNumber(layoutNo)) {
        /* modify by chamaojia 2024-03-28 [10303、10304] calling new methods --start */
        /* mod #8872 by zhangruixue 2023-06-21 --start */
//        TreatmentStatusListResponse res = treatmentStatusListService.getTreatmentStatusListOnSchedule(facilityCd,
//            treatDate, layoutNo ,bedGroupCd);
        /* mod #8872 by zhangruixue 2023-06-21 --end */
        TreatmentStatusListResponse res = treatmentStatusListService.getTreatmentStatusMapToSchedule(facilityCd,
                treatDate, layoutNo, bedGroupCd, bedLayoutId, kurCd);
        /* modify by chamaojia 2024-03-28 [10303、10304] calling new methods --end */
        long end = System.currentTimeMillis();
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage((end - start) + "ms getTreatmentStatusListOnSchedule");
        logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);
        return new ResponseEntity<>(res, HttpStatus.OK);
      } else {
        throw new IllegalArgumentException("[layoutNo] is not number");
      }
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST request error by get getTreatmentStatusListOnSchedule : "+ e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   *治療状況リスト表示用：指定した施設コード、治療状況レイアウト番号の情報を取得
   * @param facilityCd 施設コード
   * @param treatDate 治療日
   * @param layoutNo レイアウト番号
   * @param isShowMain  true:治療状況  false:装置一覧
   * @param nextPat 次患者表示   "0":表示しない  "1":現クール  "2": 次クール
   * @return
   */
  /* modify by chamaojia 2024-03-28 [10303、10304] add interface input parameters 【isShowMain】【nextPat】 --start */
  @GetMapping("/treatment_status_list/{facilityCd}/{treatDate}/{layoutNo}/{bedGroupCd}/{kurCdS}/{isShowMain}/{nextPat}")
  public ResponseEntity<?> getTreatmentStatusList(
          @PathVariable String facilityCd,
          @PathVariable String treatDate,
          @PathVariable String layoutNo,
          @PathVariable(required = false) String bedGroupCd,
          @PathVariable(required = false) String kurCdS,
          @PathVariable Boolean isShowMain,
          @PathVariable String nextPat,
          @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 mod 20260421 start
    if (!hasFacilityAccess(ntssUser, facilityCd)) {
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }
    // #11205 mod 20260421 end

  /* modify by chamaojia 2024-03-28 [10303、10304] add interface input parameters 【isShowMain】【nextPat】 --end */
    long start = System.currentTimeMillis();
    try {
      if (StrUtils.isNumber(layoutNo) &&
          Long.parseLong(layoutNo) < 1) {
        return new ResponseEntity<>("[layoutNo] is no data", HttpStatus.BAD_REQUEST);
      }
      if (StrUtils.isNumber(layoutNo) &&
          StrUtils.isNumber(treatDate) &&
          treatDate.length() == 8) {
        /* modify by chamaojia 2024-03-28 [10303、10304] calling new methods --start */
        /* mod #8872 by zhangruixue 2023-06-21 --start */
//        TreatmentStatusListResponse res = treatmentStatusListService.getUneditionTreatmentStatusList(facilityCd,
//                treatDate, layoutNo,bedGroupCd,kurCdS);
        TreatmentStatusListResponse res = null;
        if (isShowMain) {
          res = treatmentStatusListService.getTreatmentStatusListToOrdNo(facilityCd,
                  treatDate, layoutNo, bedGroupCd, kurCdS, nextPat);
        } else {
          res = treatmentStatusListService.getTreatmentStatusListToMachine(facilityCd,
                  treatDate, layoutNo, bedGroupCd, nextPat);
        }
        /* mod #8872 by zhangruixue 2023-06-21 --end */
        /* modify by chamaojia 2024-03-28 [10303、10304] calling new methods --end */
        return new ResponseEntity<>(res, HttpStatus.OK);
      } else {
        //        throw new IllegalArgumentException("[layoutNo] is not number");
        return new ResponseEntity<>("[layoutNo] is not number", HttpStatus.BAD_REQUEST);
      }
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST request error by get getUneditionTreatmentStatusList : "+ e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
    } finally {
      long end = System.currentTimeMillis();
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage((end - start) + "ms getUneditionTreatmentStatusList");
      logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);
    }
  }

  /**
  * 指定した施設コード、治療状況レイアウト番号、日付の情報と治療中の情報を取得
  * @param facilityCd 施設コード
  * @param treatDate 治療日
  * @param layoutNo レイアウト番号
  * @return
  */
  @GetMapping("/treatment_status_map_machine/{facilityCd}/{treatDate}/{layoutNo}")
  public ResponseEntity<?> getTreatmentStatusMapMachine(
      @PathVariable String facilityCd,
      @PathVariable String treatDate,
      @PathVariable String layoutNo,
      @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 mod 20260421 start
    if (!hasFacilityAccess(ntssUser, facilityCd)) {
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }
    // #11205 mod 20260421 end

    try {
      if (StrUtils.isNumber(layoutNo) &&
          Long.parseLong(layoutNo) < 1) {
        return new ResponseEntity<>("[layoutNo] is no data", HttpStatus.BAD_REQUEST);
      }
      if (StrUtils.isNumber(layoutNo) &&
          StrUtils.isNumber(treatDate) &&
          treatDate.length() == 8) {
        /* mod #8872 by zhangruixue 2023-06-21 --start */
        TreatmentStatusListResponse res = treatmentStatusListService.getTreatmentStatusMapMachine(facilityCd, treatDate,
            layoutNo,null);
        /* mod #8872 by zhangruixue 2023-06-21 --end */
        return new ResponseEntity<>(res, HttpStatus.OK);
      } else {
        //        throw new IllegalArgumentException("[layoutNo] is not number");
        return new ResponseEntity<>("[layoutNo] is not number", HttpStatus.BAD_REQUEST);
      }
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST request error by get getUneditionTreatmentStatusList : "+ e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
  * オーダー番号のリストからそれぞれの投薬実施有無を取得
  * @param ordNoArrayString 半角カンマで結合したオーダ番号
  * @return
  */
  @GetMapping("/check_medi_done/{ordNoArrayString}")
  public ResponseEntity<?> getCheckMediDone(
      @PathVariable String ordNoArrayString,
      @AuthenticationPrincipal NtssUser ntssUser) {
    if (!ordNoArrayString.isEmpty() && ordNoArrayString != null) {
      try {
        List<String> ordNoList = Arrays.asList(ordNoArrayString.split(","));
        List<Long> ordNos = ordNoList.stream().map(Long::valueOf).collect(Collectors.toList());
        // #11205 mod 20260421 start
        if (!hasOrdAccess(ntssUser, ordNos)) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "ordNoArrayString=" + ordNoArrayString + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
        // #11205 mod 20260421 end
        List<CheckMediDoneResponse> response = treatmentStatusListService.checkMediDone(ordNoList);
        return new ResponseEntity<>(response, HttpStatus.OK);
      } catch (Exception e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("REST request error by get CheckMediDone : "+ e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
        return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
      }
    } else {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST request error by get CheckMediDone : recieve data is Null or Empty.");
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  // FNSI-修正、#6484 NG再対応、5898の対応内容と競合するため、コメントアウトする、xugj add start
  //  //add FutreNetWeb+SI課題管理 no.5898 劉全航 start
  //  @GetMapping("/update_pat_dialysis_count/{patId}")
  //  public ResponseEntity<?> updatePatDialysisCount(@PathVariable Long patId){
  //    try {
  //      PatMain patMain = patMainDao.selectById(patId);
  //      LogEventUtils.setOperatorId(patMain);
  //      String medicalCareinfo = patMain.getMedical_care_info();
  //      JSONObject jsonObject = new JSONObject(medicalCareinfo);
  //      Object pat_dialysis_count = jsonObject.get("pat_dialysis_count");
  //      int newCount = 0;
  //      if(JSONObject.NULL != pat_dialysis_count){
  //        newCount = Integer.parseInt(pat_dialysis_count.toString());
  //        newCount = newCount + 1;
  //      }else{
  //        newCount = 1;
  //      }
  //      jsonObject.put("pat_dialysis_count", newCount);
  //      patMain.setMedical_care_info(jsonObject.toString());
  //      int row = patMainDao.updatePatMain(patMain);
  //      return new ResponseEntity<>(row, HttpStatus.OK);
  //    }catch (Exception e){
  //      EventLogMessage eventLogMessage = new EventLogMessage();
  //      eventLogMessage.setLogMessage("REST request error by get updatePatDialysisCount : "+ e.getMessage());
  //      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
  //      return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
  //    }
  //  }
  //  //add FutreNetWeb+SI課題管理 no.5898 劉全航 end
  // FNSI-修正、#6484 NG再対応、5898の対応内容と競合するため、コメントアウトする、xugj add end

  /**
   * 後体重測定確認時の更新処理
   * @param request リクエスト情報
   * @param ntssUser 認証利用者情報
   * @return
   */
  @PutMapping("/check_after_weight")
  public ResponseEntity<?> updateCheckAfterWeight(
      @RequestBody List<CheckAfterWeightRequest> request,
      @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if (ntssUser != null) {
      if(!ntssUser.isNkkAdminUser()) {
        List<OrdMain> ordMains = ordMainDao.selectListByOrdNo(request.stream().map(CheckAfterWeightRequest::getOrdNo).collect(Collectors.toList()));
        for (OrdMain ordMain : ordMains) {
          if (ordMain.getFacilityCd() != null && !ordMain.getFacilityCd().equals(ntssUser.getFacilityCd())) {
            // #11205 mod 20260421 start
            String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + ordMain.getFacilityCd() + " " + "ordNo=" + ordMain.getOrdNo() + " " + "patId=" + ordMain.getPatId() + " ";
            InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
            AllConfirmResponse allConfirmResponse = new AllConfirmResponse("");
            allConfirmResponse.isSuccess = false;
            allConfirmResponse.errorMessage = "セキュリティチェックの例外!";
            return new ResponseEntity<>(allConfirmResponse, HttpStatus.FORBIDDEN);
            // #11205 mod 20260421 end
          }
        }
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
    AllConfirmResponse allConfirmResponse = new AllConfirmResponse("");
    // #10338 2024.03.28 mod 実績確定処理updateCheckAfterWeightを改修 TDC片口 start
////mod 9480 後体重測定確認時の更新処理 guan start
//    ResponseEntity<?> re = treatmentStatusListService.updateCheckAfterWeight(request, ntssUser, allConfirmResponse);
//    for (CheckAfterWeightRequest ordInfo : request) {
//      webApiCallCommonUtil.doAutoCalculation(ordInfo.getOrdNo());
//    }
//    return re;
//    //mod 9480 後体重測定確認時の更新処理 guan end

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());

    if(request == null || request.isEmpty()) {
      // リクエスト内容がNullまたは空の場合、BAD_REQUESTを返す
      eventLogMessage.setLogMessage("REST request error by put updateCheckAfterWeight : receive data is Null or Empty.");
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      allConfirmResponse.errorMessage = "対象データなし";

      return new ResponseEntity<>(allConfirmResponse, HttpStatus.BAD_REQUEST);
    }

    // 後体重確認処理の早期リターン用先行処理
    TreatmentStatusUpdateResponse response = treatmentStatusListService.updateCheckAfterWeightConfirm(request, ntssUser.getFacilityCd());
    allConfirmResponse.isSuccess = response.isSuccess;
    allConfirmResponse.errorMessage = response.errorMessage;

    try {
      // DB登録処理用スレッドを生成
      DialysisConfirmThread trd = new DialysisConfirmThread(request, ntssUser);
      // newによりオブジェクト生成を行った場合、生成オブジェクト内のSpringによる@Autowired対象オブジェクトが自動生成されないため、アプリケーションコンテキストにて@Autowiredのオブジェクトの生成処理を行う
      applicationContext.getAutowireCapableBeanFactory().autowireBean(trd);
      // スレッドによるDB登録処理を実施(Security情報ごと渡す)
      SecurityContext context = SecurityContextHolder.getContext();
      DelegatingSecurityContextRunnable wrappedRunnable = new DelegatingSecurityContextRunnable(trd, context);
      new Thread(wrappedRunnable).start();

    } catch (Exception ex) {
      allConfirmResponse.isSuccess = false;
      allConfirmResponse.errorMessage = ex.getMessage();
      eventLogMessage.setLogMessage("後体重確認スレッド開始失敗：" + ex.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
    }

    return new ResponseEntity<>(allConfirmResponse, HttpStatus.OK);
    // #10338 2024.03.28 add 実績確定処理updateCheckAfterWeightを改修 TDC片口 end
  }

  /**
   * 治療状況リスト:装置一覧モニターデータ情報の取得
   *
   * @param ordNo オーダ番号
   * @return オーダ番号に該当する {@link MniMonitor} のリスト
  */
  @GetMapping("/mni_monitor/{ordNo}")
  public ResponseEntity<?> getTSMachineList(@PathVariable Long ordNo,
                                            @RequestParam(required = false) Long selectedPatId,
                                            @AuthenticationPrincipal NtssUser ntssUser) {
    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    if (ordMain != null && !facilityAccessService.hasFacilityOrSelectedPatShareAccessForFacilityCds(
        ntssUser, Collections.singletonList(ordMain.getFacilityCd()), selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get tSMachineList : "+ ordNo);
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    try {
      // レスポンス生成
      List<MniMonitor> response = treatmentStatusListService.monitorSelectByOrdNo(ordNo);

      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      eventLogMessage.setLogMessage("REST request error by get getTreatmentStatusList : "+ e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  // add bug 5482 修正 chen start
  /* upd by chamaojia 2026-03-14 [12462] 患者情報共有->患者経過総合ビューア --start */
  /**
   * 治療状況リスト:装置一覧モニターデータ情報の取得
   *
   * @param bodyDataList  (data: facility_cd、ord_no)
   * @return オーダ番号に該当する {@link MniMonitor} のリスト
  */
  @PostMapping("/mni_monitors")
  public ResponseEntity<?> getTSMachineLists(@Validated @RequestBody List<Map<String, Object>> bodyDataList,
                                             @RequestParam(required = false) Long selectedPatId,
                                             @AuthenticationPrincipal NtssUser ntssUser) {
    List<String> facilityCdList = bodyDataList.stream()
        .map(item -> (String) item.get("facility_cd"))
        .collect(Collectors.toList());
    if (!facilityAccessService.hasFacilityOrSelectedPatShareAccessForFacilityCds(ntssUser, facilityCdList, selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }

    // // #11205 mod 20260421 start
    // 与患者共有冲突
    // if (!hasFacilityAccess(ntssUser, facilityCd) || !hasOrdAccess(ntssUser, ordNo)) {
    //   if (InvestigateLogUtils.enable_log_for_11205) {
    //     String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " " + "ordNo=" + ordNo + " ";
    //     InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
    //   } else {
    //     return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    //   }
    // }
    // // #11205 mod 20260421 end

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get tSMachineList : "+ bodyDataList);
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    try {
      // レスポンス生成
      List<MniMonitorCalendr> response = treatmentStatusListService.monitorSelectByOrdNos(bodyDataList);

      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      eventLogMessage.setLogMessage("REST request error by get getTreatmentStatusList : "+ e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  /* upd by chamaojia 2026-03-14 [12462] 患者情報共有->患者経過総合ビューア --end */
  // add bug 5482 修正 chen end

  @Autowired
  private AlarmRecordService mntAlarmRecordService;

  /**
   * 開始日付から1週間分の警報注意履歴を取得
   * @param facilityCd 施設コード
   * @param startDate 開始日付yyyyMMdd
   * @return 1週間分の警報注意履歴
   */
  @GetMapping("alarm_record/{facilityCd}/{startDate}")
  public ResponseEntity<?> getAlarmRecord(@PathVariable String facilityCd, @PathVariable String startDate,
      @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 mod 20260421 start
    if (!hasFacilityAccess(ntssUser, facilityCd)) {
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }
    // #11205 mod 20260421 end


    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get AlarmRecords : "+ facilityCd+ startDate);
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    try {
      DateFormat df = new SimpleDateFormat("yyyyMMdd");
      // カレンダークラスのインスタンスを取得
      Calendar cal = Calendar.getInstance();
      // 開始時刻を設定
      cal.setTime(df.parse(startDate));
      Timestamp occurDateStart = new Timestamp(cal.getTimeInMillis());
      // 1週間後-1ミリ秒を設定
      cal.add(Calendar.DATE, 1);
      cal.add(Calendar.MILLISECOND, -1);
      Timestamp occurDateEnd = new Timestamp(cal.getTimeInMillis());

      // レスポンス生成
      List<AlarmRecordResponse> response = mntAlarmRecordService.selectByOccurDate(facilityCd, occurDateStart,
          occurDateEnd);

      return new ResponseEntity<>(response, HttpStatus.OK);

    } catch (Exception e) {
      eventLogMessage.setLogMessage("REST request error by get AlarmRecords : "+ e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * スタッフ一覧情報取得
   * @param ntssUser 認証利用者情報
   * @return
   */
  @GetMapping("staff")
  public ResponseEntity<?> getMstPersonalUser(
      @AuthenticationPrincipal NtssUser ntssUser) {
    // NOTE: ord_mainをorderNoで取得する

    return new ResponseEntity<>(treatmentStatusListService.getMstPersonalUser(ntssUser.getFacilityCd()), HttpStatus.OK);
  }

  /**
   *治療状況データ更新.
   *
   * @param request リクエスト情報
   * @param ntssUser 認証利用者情報
   * @return
   */
  @PutMapping("treatment_status_record/data")
  public ResponseEntity<?> updateTreatmentStatus(
      @RequestBody TreatmentStatusUpdateRequest request,
      @AuthenticationPrincipal NtssUser ntssUser) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to update records");
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);
    try {
      // 更新処理
      TreatmentStatusUpdateResponse response = treatmentStatusListService.updateTreatmentStatus(
          ntssUser.getFacilityCd(),
          request.getData());
      if (response.isSuccess) {
        return new ResponseEntity<>(response, HttpStatus.OK);
      } else {
        // 更新処理ができなかった場合
        eventLogMessage.setLogMessage("Exception message : " + response.errorMessage);
        logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);
        return new ResponseEntity<>(new TreatmentStatusUpdateResponse(response.errorMessage),
            HttpStatus.BAD_REQUEST);
      }

    } catch (Exception e) {

      // 更新処理ができなかった場合
      eventLogMessage.setLogMessage("Exception message : "+ e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(new TreatmentStatusUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()),
          HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * ？？？？患者実績削除
   *
   * @param request リクエスト情報
   * @param ntssUser 認証利用者情報
   * @return
   */
  @PutMapping("delete/unknown-record")
  public ResponseEntity<?> updateDeleteRecord(
      @RequestBody DeleteRecordRequest request,
      @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 mod 20260421 start
    if (!hasOrdAccess(ntssUser, request == null ? null : request.getOrdNo())) {
      OrdMain ordMain = ordMainDao.selectByOrdNo(request.getOrdNo());
      if (ordMain != null) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + ordMain.getFacilityCd() + " " + "ordNo=" + request.getOrdNo() + " " + "patId=" + ordMain.getPatId() + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      }
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }
    // #11205 mod 20260421 end

    /* add by sunmingyuan  2023-02-01 CodeOptimization  start */
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage("REST request to delete records");
//    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);
//    try {
//      // 更新処理
//      Long ordNo = request.getOrdNo();
//      String facilityCd = ntssUser.getFacilityCd();
//
//      // add FNSI-バグ #7161 通信サーバ 高 start
//      // オーダー番号から施設コード、デバイスエッジ番号を取得
//      DeviceEdgeOrderRequest req = new DeviceEdgeOrderRequest();
//      req.setDeviceEdgeNo(null);
//      req.setOrdNo(ordNo);
//      req.setMachineNo(null);
//      req.setFacilityCd(facilityCd);
//      DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
//      // 不足情報を補填
//      DeviceEdgeOrderRequest targetInfo = deviceEdgeOrderService.findMissingData(req);
//      // add FNSI-バグ #7161 通信サーバ 高 end
//
//      //mod FNSI 401対応 房 start
//      TreatmentStatusUpdateResponse response = treatmentStatusListService.deleteUnknownPatRecord(ordNo, facilityCd);
//      //mod FNSI 401対応 房 end
//      if (response.isSuccess) {
//        // 現患者チェック
//        List<MntMachineState> state = mntMachineStateDao.selectByOrdNo(facilityCd, ordNo);
//        if (!state.isEmpty()) {
//          // 現患者である場合
//          // オーダー番号から施設コード、デバイスエッジ番号を取得
//          // del FNSI-バグ #7161 通信サーバ 高 start
////          DeviceEdgeOrderRequest req = new DeviceEdgeOrderRequest();
////          req.setDeviceEdgeNo(null);
////          req.setOrdNo(ordNo);
////          req.setMachineNo(null);
////          req.setFacilityCd(facilityCd);
////          DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
//          try {
//            // 不足情報を補填
////            DeviceEdgeOrderRequest targetInfo = deviceEdgeOrderService.findMissingData(req);
//            // del FNSI-バグ #7161 通信サーバ 高 end
//            // 後体重測定指示(後体重測定)を通知
//            res = deviceEdgeOrderService.orderAfterWeight(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(), targetInfo.getMachineNo());
//            // 治療状況確認指示(後体重確認)を通知
//            res = deviceEdgeOrderService.orderCheckStatus(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(), targetInfo.getMachineNo());
//            // add FNSI-バグ #7161 通信サーバ 高 start
//            // 次患者情報転送指示を通知
//            res = deviceEdgeOrderService.orderSendNextPat(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(), targetInfo.getMachineNo(), targetInfo.getOrdNo());
//            // add FNSI-バグ #7161 通信サーバ 高 end
//          } catch (Exception e) {
//            eventLogMessage.setLogMessage(e.getMessage());
//            logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
//            res.isSuccess = false;
//            res.errorMessage = e.getMessage();
//          }
//        }
//        return new ResponseEntity<>(response, HttpStatus.OK);
//      } else {
//        // 更新処理ができなかった場合
//        eventLogMessage.setLogMessage("Exception message : "+ response.errorMessage);
//        logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);
//        return new ResponseEntity<>(new TreatmentStatusUpdateResponse(response.errorMessage),
//          HttpStatus.BAD_REQUEST);
//      }
//    } catch (Exception e) {
//
//      // 更新処理ができなかった場合
//      eventLogMessage.setLogMessage("Exception message : "+ e.getMessage());
//      logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);
//      return new ResponseEntity<>(new TreatmentStatusUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()),
//        HttpStatus.BAD_REQUEST);
//    }
    // ログ出力
    return treatmentStatusListService.updateDeleteRecord(request, ntssUser);
    /* add by sunmingyuan  2023-02-01 CodeOptimization  end */
  }
  private boolean hasFacilityAccess(NtssUser ntssUser, String facilityCd) {
    return ntssUser == null
      || ntssUser.isNkkAdminUser()
      || facilityCd == null
      || facilityCd.equals(ntssUser.getFacilityCd());
  }

  private boolean hasOrdAccess(NtssUser ntssUser, Long ordNo) {
    if (ntssUser == null || ntssUser.isNkkAdminUser() || ordNo == null) {
      return true;
    }

    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    return ordMain == null
      || ordMain.getFacilityCd() == null
      || ordMain.getFacilityCd().equals(ntssUser.getFacilityCd());
  }

  private boolean hasOrdAccess(NtssUser ntssUser, List<Long> ordNos) {
    if (ordNos == null) {
      return true;
    }

    for (Long ordNo : ordNos) {
      if (!hasOrdAccess(ntssUser, ordNo)) {
        return false;
      }
    }
    return true;
  }
}
