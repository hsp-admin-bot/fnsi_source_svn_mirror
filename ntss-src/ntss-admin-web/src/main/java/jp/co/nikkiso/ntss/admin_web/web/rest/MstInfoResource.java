package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.ResponseKind;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage;
import jp.co.nikkiso.ntss.admin_web.request.masterMaintenance.job.MstJobRequest;
import jp.co.nikkiso.ntss.admin_web.request.mstInfo.MstInfoRequest;
import jp.co.nikkiso.ntss.admin_web.response.MedicineResponse;
import jp.co.nikkiso.ntss.admin_web.response.MedicineResponseExtends;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterUpdateResponse;
import jp.co.nikkiso.ntss.admin_web.response.mstDialyzer.DialyzerSharingInfoResponse;
import jp.co.nikkiso.ntss.admin_web.response.mstEquipment.EquipmentSharingInfoResponse;
import jp.co.nikkiso.ntss.admin_web.response.mstMedicine.MedicineSharingInfoResponse;
import jp.co.nikkiso.ntss.admin_web.response.mstMedicineMix.MedicineMixSharingInfoResponse;
import jp.co.nikkiso.ntss.admin_web.response.mstMedicineMix.MstMedicineMixDto;
import jp.co.nikkiso.ntss.admin_web.response.sysFunction.SysFunctionResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.FacilitySettingService;
import jp.co.nikkiso.ntss.admin_web.service.MongoService;
import jp.co.nikkiso.ntss.admin_web.service.MstInfoService;
import jp.co.nikkiso.ntss.admin_web.service.exam.ExamRequestService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.statusList.TreatmentStatusListService;
import jp.co.nikkiso.ntss.admin_web.service.statusList.dto.condInfo.CondInfoService;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.PaginationUtils;
import jp.co.nikkiso.ntss.admin_web.web.rest.validation.ApiEntityMstInfo;
import jp.co.nikkiso.ntss.admin_web.web.service.MaterialsSharingPatientInformation.MaterialsSharingPatientInfomationService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MstCourseDao;
import jp.co.nikkiso.ntss.core.dao.MstEquipmentClassDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineClassDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dto.mstDisease.MstDiseaseCN;
import jp.co.nikkiso.ntss.core.dto.mstDisease.MstDiseaseCNF;
import jp.co.nikkiso.ntss.core.entity.MstAddMonitor;
import jp.co.nikkiso.ntss.core.entity.MstAddition;
import jp.co.nikkiso.ntss.core.entity.MstAlarmNotification;
import jp.co.nikkiso.ntss.core.entity.MstBbsKind;
import jp.co.nikkiso.ntss.core.entity.MstBed;
import jp.co.nikkiso.ntss.core.entity.MstBedIndex;
import jp.co.nikkiso.ntss.core.entity.MstComFixedPhrase;
import jp.co.nikkiso.ntss.core.entity.MstCourse;
import jp.co.nikkiso.ntss.core.entity.MstDialysisDifficulty;
import jp.co.nikkiso.ntss.core.entity.MstDialyzer;
import jp.co.nikkiso.ntss.core.entity.MstDialyzerDto;
import jp.co.nikkiso.ntss.core.entity.MstDisease;
import jp.co.nikkiso.ntss.core.entity.MstEquipment;
import jp.co.nikkiso.ntss.core.entity.MstEquipmentClass;
import jp.co.nikkiso.ntss.core.entity.MstEquipmentDto;
import jp.co.nikkiso.ntss.core.entity.MstEquipmentExtends;
import jp.co.nikkiso.ntss.core.entity.MstEquipmentSet;
import jp.co.nikkiso.ntss.core.entity.MstExamItem;
import jp.co.nikkiso.ntss.core.entity.MstExamMatome;
import jp.co.nikkiso.ntss.core.entity.MstExamSet;
import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.MstFacilityCalendarLayout;
import jp.co.nikkiso.ntss.core.entity.MstFavoriteFacility;
import jp.co.nikkiso.ntss.core.entity.MstIfEdge;
import jp.co.nikkiso.ntss.core.entity.MstImplant;
import jp.co.nikkiso.ntss.core.entity.MstInfection;
import jp.co.nikkiso.ntss.core.entity.MstJob;
import jp.co.nikkiso.ntss.core.entity.MstKur;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.MstMedicateTiming;
import jp.co.nikkiso.ntss.core.entity.MstMedicine;
import jp.co.nikkiso.ntss.core.entity.MstMedicineClass;
import jp.co.nikkiso.ntss.core.entity.MstMedicineDto;
import jp.co.nikkiso.ntss.core.entity.MstMedicineExtendsDto;
import jp.co.nikkiso.ntss.core.entity.MstMedicineGroup;
import jp.co.nikkiso.ntss.core.entity.MstMedicineMix;
import jp.co.nikkiso.ntss.core.entity.MstMedicineMixExtendsDto;
import jp.co.nikkiso.ntss.core.entity.MstMedicineSet;
import jp.co.nikkiso.ntss.core.entity.MstMenuGroup;
import jp.co.nikkiso.ntss.core.entity.MstObsKind;
import jp.co.nikkiso.ntss.core.entity.MstPatCalendarLayout;
import jp.co.nikkiso.ntss.core.entity.MstPatEventSubCategory;
import jp.co.nikkiso.ntss.core.entity.MstPatListLayout;
import jp.co.nikkiso.ntss.core.entity.MstPatMemo;
import jp.co.nikkiso.ntss.core.entity.MstPatViewerLayout;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstProcedure;
import jp.co.nikkiso.ntss.core.entity.MstRadSet;
import jp.co.nikkiso.ntss.core.entity.MstRelationship;
import jp.co.nikkiso.ntss.core.entity.MstRoomBedGroup;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import jp.co.nikkiso.ntss.core.entity.MstSeverity;
import jp.co.nikkiso.ntss.core.entity.MstSpitz;
import jp.co.nikkiso.ntss.core.entity.MstTabooAllergy;
import jp.co.nikkiso.ntss.core.entity.MstTransport;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.MstTreatmentSet;
import jp.co.nikkiso.ntss.core.entity.MstTreatmentStatusDispItem;
import jp.co.nikkiso.ntss.core.entity.MstUrlLinkRegister;
import jp.co.nikkiso.ntss.core.entity.MstVa;
import jp.co.nikkiso.ntss.core.entity.MstWard;
import jp.co.nikkiso.ntss.core.entity.MstWaterSurveyType;
import jp.co.nikkiso.ntss.core.entity.SysAddress;
import jp.co.nikkiso.ntss.core.entity.SysCountry;
import jp.co.nikkiso.ntss.core.entity.SysFacility;
import jp.co.nikkiso.ntss.core.entity.SysFunction;
import jp.co.nikkiso.ntss.core.entity.SysFunctionAdvanced;
import jp.co.nikkiso.ntss.core.entity.SysGenericMedicine;
import jp.co.nikkiso.ntss.core.entity.SysSubscriptionPlan;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;
import jp.co.nikkiso.ntss.core.entity.custom.BedMachine;
import jp.co.nikkiso.ntss.core.entity.custom.HolidayDetail;
import jp.co.nikkiso.ntss.core.entity.custom.MstPatViewerLayoutMonitorItem;
import jp.co.nikkiso.ntss.core.entity.custom.WaterSurveyPoint;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import lombok.extern.slf4j.Slf4j;

import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.validation.BindingResult;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * マスタ系のResourceクラス.
 */
@RestController
@Slf4j
@RequestMapping(Uri.MST_INFO)
public class MstInfoResource {

  /**
   * {@link MstInfoService}
   */
  @Autowired
  MstInfoService mstInfoService;
  @Autowired
  ExamRequestService examRequestService;
  @Autowired
  private MstCourseDao mstCourseDao;

  /**
   * {@link FacilitySettingService}
   */
  @Autowired
  FacilitySettingService facilitySettingService;
  @Autowired
  LogService logService;
  @Autowired
  MaterialsSharingPatientInfomationService materialsSharingPatientInfomationService;
  @Autowired
  PatPersonalMainDao patPersonalMainDao;
  @Autowired
  CondInfoService condInfoService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  @Autowired
  MstMedicineClassDao mstMedicineClassDao;

  @Autowired
  MstEquipmentClassDao mstEquipmentClassDao;
  /**
   * 治療状況リスト情報の取得
   */
  @Autowired
  private TreatmentStatusListService treatmentStatusListService;

  //add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 start
  @Autowired
  MongoService mongoService;
  //add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 end

  @GetMapping("/mstBed")
  /**
   * ベッドマスタ一覧取得
   */
  public ResponseEntity<List<MstBed>> getaFindByFacilityCd(
      @RequestParam(value = "facility_cd", required = true) String facility_cd,
      @RequestParam(value = "is_disp", required = true) String is_disp,
      @RequestParam(value = "is_del", required = true) String is_del,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit
      ) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstBed> page = mstInfoService.findMstBedByFacilityCd(pageable, facility_cd, is_disp, is_del);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstBed/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

// FNSI-修正 マスタ削除の対応 chen add start
  @GetMapping("/mstBedDel")
  /**
   * ベッドマスタ一覧取得
   */
  public ResponseEntity<List<MstBed>> getaFindByFacilityCdDel(
    @RequestParam(value = "facility_cd", required = true) String facility_cd,
    @RequestParam(value = "page", required = false) Integer offset,
    @RequestParam(value = "per_page", required = false) Integer limit
  ) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstBed> page = mstInfoService.findMstBedByFacilityCdDel(pageable, facility_cd);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstBed/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }
// FNSI-修正 マスタ削除の対応 chen add end

  @GetMapping("/mstBed/getBedName")
  /**
   *  ベッドマスター名
   */
  public ResponseEntity<String> getMstBedNameByCd(Long bedCd) throws URISyntaxException {
    String bedName = mstInfoService.findBedNameByBedCd(bedCd);
    return new ResponseEntity<>(bedName, HttpStatus.OK);
  }
  //add 5619 装置と紐づいていないベッドも表示 張 start
  @GetMapping("/getByFacilityCd")
  /**
   * ベッドマスタ一覧取得
   */
  public ResponseEntity<List<BedMachine>> getByFacilityCd(
    @RequestParam(value = "facility_cd", required = true) String facility_cd
  ) throws URISyntaxException {
    List<BedMachine> list = treatmentStatusListService.getBedMachineList(facility_cd);
    return new ResponseEntity<>(list, HttpStatus.OK);
  }
  //add 5619 装置と紐づいていないベッドも表示 張 end
  //add no4878 メイン画面と編集画面で削除済み、期限切れ、分類不一致、禁忌アレルギーの接頭付けが一致していない 張 start
  @GetMapping("/selectAllByFacilityCd")
  /**
   * ベッドマスタ一覧取得
   */
  public ResponseEntity<List<MstBed>> getaFindByFacilityCd(
    @RequestParam(value = "facility_cd", required = true) String facility_cd
  ) throws URISyntaxException {
    List<MstBed> mstBedList = mstInfoService.selectAllByFacilityCd(facility_cd);
    return new ResponseEntity<>(mstBedList, HttpStatus.OK);
  }

  @GetMapping("/mstBed/getBedNameIncludeDel")
  /**
   *  ベッドマスター名
   */
  public ResponseEntity<String> getMstBedNameByCdIncludeDel(@RequestParam Long bedCd) throws URISyntaxException {
    String bedName = mstInfoService.findBedNameByBedCdIncludeDel(bedCd);
    return new ResponseEntity<>(bedName, HttpStatus.OK);
  }
  //add no4878 メイン画面と編集画面で削除済み、期限切れ、分類不一致、禁忌アレルギーの接頭付けが一致していない 張 end
  @PostMapping("/getSelectForSearchFreeBeds")
  /**
   * ベッドマスタ一覧取得(空きベッド検索)
   * @param facility_cd 検索施設コード
   * @param pat_id 検索対象外患者ID(ベッド割り当て予定の患者ID)
   * @param kur_cd 検索クールコード
   * @param treat_week_list 検索曜日リスト
   * @param search_start_date 検索開始日(形式:yyyyMMdd)
   * @param search_end_date 検索終了日(形式:yyyyMMdd)
   * @param isAll 全ベッド取得フラグ(true:全ベッド取得、false:空きベッドのみ取得)
   * @return 正常終了:検索にヒットしたスケジュールのリスト、異常終了:null
   */
// mod 7238 2023-03-29 予定コピー画面のベッドの並び順が不正 張 start
//  public ResponseEntity<List<MstBed>> getSelectForSearchFreeBeds(
  public ResponseEntity<List<MstBedIndex>> getSelectForSearchFreeBeds(
// mod 7238 2023-03-29 予定コピー画面のベッドの並び順が不正 張 end
      @Validated @RequestBody ApiEntityMstInfo.ValiSearchFreeBeds bodyData ,BindingResult validationResult
      ) throws URISyntaxException {
    // 受信データログ出力

    /* del by biangang  2023-01-31 CodeOptimization  start */
   /**
    //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("facility_cd:" + bodyData.getFacility_cd());
    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,null);
    eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("pat_id:" + bodyData.getPat_id());
    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,null);
    eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("kur_cd:" + bodyData.getKur_cd());
    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,null);
    eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("treat_week_list:" + bodyData.getTreat_week_list());
    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,null);
    eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("ind_start_date:" + bodyData.getInd_start_date());
    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,null);
    eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("ind_end_date:" + bodyData.getInd_end_date());
    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,null);
    eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("is_all:" + bodyData.getIs_all());
    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,null);
    eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("init_bed_cd:" + bodyData.getInit_bed_cd());
    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,null);
    //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end

    // 更新対象治療方法リスト
    List<Integer> indTreatmentCdList = this.getValueList(bodyData.getInd_treatment_cd());
    // 更新対象クールリスト
    List<Long> indKurCdList = this.getLongList(bodyData.getInd_kur_cd());

    // バリデーションエラーチェック
    if(validationResult.hasErrors()) {
      // バリデーションエラーが発生した場合はパラメータ異常扱い
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("result:" + validationResult);
      logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
      for (ObjectError error : validationResult.getFieldErrors()) {
        //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
        eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("error:" + error.getDefaultMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,null);
        //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
      }
      return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
    }

    // 曜日パターン情報加工
    List<Integer> weeksArray = IndicationUtils.getWeekPattern(bodyData.getTreat_week_list());
    if(null == weeksArray) {
      // 曜日パターン情報加工に発生した場合はパラメータ異常扱い
      return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
    }

    Long pat_id = Long.parseLong(bodyData.getPat_id());
    Long kur_cd = Long.parseLong(bodyData.getKur_cd());
    if (0 == kur_cd) kur_cd = null;
    String ind_start_date = bodyData.getInd_start_date().replaceAll("-", "");
    String ind_end_date = null;
    if (false == StringUtils.isEmpty(bodyData.getInd_end_date())) {
      ind_end_date = bodyData.getInd_end_date().replaceAll("-", "");
    }
    boolean is_all = false;
    try {
      is_all = Boolean.parseBoolean(bodyData.getIs_all());
    } catch (Exception e) {
      //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      //EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage = new EventLogMessage();
      //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
      eventLogMessage.setLogMessage(e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
      null);
      // 異常扱い
      return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
    }

    // 施設設定マスタより予定数しきい値を取得する。
    Long ms_max_treat = Long.parseLong(facilitySettingService.getFacilitySettingValue(
        bodyData.getFacility_cd(),
        FacilitySettingNo.MAX_BED_TREAT_COUNT
      ));

    // 空きベッド候補切替指示期間(日)を取得する。
    Long ms_bed_change_period = Long.parseLong(facilitySettingService.getFacilitySettingValue(
        bodyData.getFacility_cd(),
        FacilitySettingNo.BED_SEARCH_RESULT_CHANGE_PERIOD
      ));

    // 期間日数の取得
    Long periodDays = Long.MAX_VALUE;
    if (ind_end_date != null) {
      periodDays = DateTimeUtils.getDateDiff(ind_start_date, ind_end_date);
      //add 7211 曜日パターン変更のメッセージ表示や治療予定の移動動作がおかしい 張 start
    }else{
      is_all=true;
      //add 7211 曜日パターン変更のメッセージ表示や治療予定の移動動作がおかしい 張 end
    }

    // 期間日数が空きベッド候補切替指示期間(日)以上であるか判定
    boolean is_valid_period = false;
    //mod no5639 4676 施設設定No.39が機能していない。 張 start
//    if (periodDays.compareTo(ms_bed_change_period) >= 0) {
//      is_valid_period = true;
    if (ind_end_date != null) {
      if (periodDays.compareTo(ms_bed_change_period) >= 0) {
        is_valid_period = true;
      //mod 5619 装置と紐づいていないベッドも表示 張 start
//        is_all=true;
      }
      //mod no5639 4676 施設設定No.39が機能していない。 張 end
    }else{
      is_valid_period = true;
    }
    // 空きベッド検索
    List<MstBed> info = mstInfoService.selectForSearchFreeBeds(bodyData.getFacility_cd(), pat_id, kur_cd, weeksArray, ind_start_date, ind_end_date, is_all, ms_max_treat,
//        is_valid_period, indTreatmentCdList, indKurCdList);
        is_valid_period, indTreatmentCdList, indKurCdList,bodyData.getInit_bed_cd());
//mos 5619 装置と紐づいていないベッドも表示 張 end

    if (info.size() < 0) {
      // 異常扱い
      return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
    }

    return new ResponseEntity<>(info, HttpStatus.OK);
    **/
    /* del by biangang  2023-01-31 CodeOptimization  end */
    /* modify by biangang  2023-01-31 CodeOptimization  start */
    return mstInfoService.getSelectForSearchFreeBeds(bodyData, validationResult);
    /* modify by biangang  2023-01-31 CodeOptimization  end */
  }

  /* del by biangang  2023-01-31 CodeOptimization  start */
  /***
   * JSON配列データから値を取得し、Integer配列データを返す
   * @param stringList
   * @return
   */
  /**
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
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      return new ArrayList<Integer>();
    }
    return valueArry;
  }
  **/

  /**
   * JSON配列データをLong配列に変換して返す
   * @param stringList
   * @return
   */
  /**
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
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      return new ArrayList<Long>();
    }
    return longList;
  }
  **/
  /* del by biangang  2023-01-31 CodeOptimization  end */

  @GetMapping("/mstComFixedPhrase")
  /**
   * 共通定型文マスタ一覧取得
   */
  public ResponseEntity<List<MstComFixedPhrase>> getMstComFixedPhraseAll(
      MstComFixedPhrase params,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit
      ) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstComFixedPhrase> page = mstInfoService.findMstComFixedPhraseAll(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstComFixedPhrase/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  @GetMapping("/mstComFixedPhrase/{job_cd}")
  /**
   * 共通定型文マスタ一覧取得(職種コード指定)
   */
  public ResponseEntity<List<MstComFixedPhrase>> getMstComFixedPhraseJob(
      MstComFixedPhrase params,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit,
      @PathVariable String job_cd
      ) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstComFixedPhrase> page = mstInfoService.findMstComFixedPhraseByJobCd(pageable, params, job_cd);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstComFixedPhrase/" + job_cd, offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  @GetMapping("/mstCourse")
  /**
   * 診療科マスタ一覧取得
   */
  public ResponseEntity<List<MstCourse>> getMstCourseServiceAll(
      MstCourse params,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstCourse> page = mstInfoService.findMstCourseAll(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstCourse/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }


  @GetMapping("/mstAllCourse")
  /**
   * 診療科マスタ一覧取得
   */
  public ResponseEntity<List<MstCourse>> getMstAllCourse() {
    List<MstCourse> mstCourses = mstCourseDao.selectAllCourse();
    return new ResponseEntity<>(mstCourses, HttpStatus.OK);
  }

  /**
   * 診療科マスタ一覧取得,包含删除数据
   */
  @GetMapping("/mstCourseIncludeDel")
  public ResponseEntity<List<MstCourse>> getMstCourseServiceAllIncludDel(
    MstCourse params,
    @RequestParam(value = "page", required = false) Integer offset,
    @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstCourse> page = mstInfoService.findMstCourseAllIncludDelete(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstCourse/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  @GetMapping("/mstDialysisDifficulty")
  /**
   * 透析困難マスタ一覧取得
   */
  public ResponseEntity<List<MstDialysisDifficulty>> getMstDialysisDifficultyAll(
      MstDialysisDifficulty params,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstDialysisDifficulty> page = mstInfoService.findMstDialysisDifficultyAll(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstDialysisDifficulty/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  @GetMapping("/mstDialyzer")
  /**
   * ダイアライザマスタ一覧取得
   */
  public ResponseEntity<List<MstDialyzer>> getMstDialyzerAll(
      MstDialyzer params,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit
      ) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstDialyzer> page = mstInfoService.findMstDialyzerAll(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstDialyzer/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  // FNSI-修正 マスタ削除の対応 wangchen add start
  @GetMapping("/mstDialyzer/getByCd")
  /**
   * コードでダイアライザを取得
   */
  public ResponseEntity<MstDialyzer> getMstDialyzerByCd(String dialyzerCd) throws URISyntaxException {
    MstDialyzer dialyzer = mstInfoService.findMstDialyzerByCd(dialyzerCd);
    return new ResponseEntity<>(dialyzer, HttpStatus.OK);
  }
  // FNSI-修正 マスタ削除の対応 wangchen add end

// FNSI-修正 マスタ削除の対応 chen add start
  @GetMapping("/mstDialyzerDel")
  /**
   * ダイアライザマスタ一覧取得
   */
  public ResponseEntity<List<MstDialyzer>> getMstDialyzerAllNoDel(
    MstDialyzer params,
    @RequestParam(value = "page", required = false) Integer offset,
    @RequestParam(value = "per_page", required = false) Integer limit
  ) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstDialyzer> page = mstInfoService.findMstDialyzerAllNoDel(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstDialyzer/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }
// FNSI-修正 マスタ削除の対応 chen add end

  @GetMapping("/mstDialyzerIncludeDeleted")
  /**
   * ダイアライザマスタ一覧取得（削除済のデータも含む）
   */
  public ResponseEntity<List<MstDialyzer>> getMstDialyzerAllIncludeDeleted(
      MstDialyzer params,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit
      ) throws URISyntaxException {
    //#8484　医療材料選択IFのリスト不正(#9978対応)　Start
    // try catch対応追加
    try{
      Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
      //#8484　医療材料選択IFのリスト不正(#9978対応)　Start
      Page<MstDialyzer> page = mstInfoService.findMstDialyzerAllIncludeDeleted(pageable, params);
      //#8484　医療材料選択IFのリスト不正(#9978対応)　End
      HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstDialyzerIncludeDeleted/", offset, limit);
      return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (params != null && params.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(params.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
      null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
    //#8484　医療材料選択IFのリスト不正(#9978対応)　End
  }

  @GetMapping("/mstDialyzer/getDialyzerSharingInfo")
  /**
   * ダイアライザー名を取得
   */
  public ResponseEntity<DialyzerSharingInfoResponse> getMstDialyzerSharingInfoByCd(@RequestParam(value = "dialyzerCd") String dialyzerCd,
      @RequestParam(value = "patId") Long patId) throws URISyntaxException {
    /* del by biangang  2023-01-31 CodeOptimization  start */
   /**
    DialyzerSharingInfoResponse result = null;
    List<PatNameIdentification> patIdSrcList = materialsSharingPatientInfomationService.getListPatIdSrcFromPatDst(patId);
    MstDialyzer dialyzer = mstInfoService.findMstDialyzerByCd(dialyzerCd);
    if (dialyzer != null) {
      String facilityCd = dialyzer.getFacilityCd();
      for (PatNameIdentification patIdSrc : patIdSrcList) {
        PatPersonalMain patSrc = patPersonalMainDao.selectById(patIdSrc.getPatIdSrc());
        if (patSrc != null) {
          if (patSrc.getFacility_cd().equals(facilityCd)) {
            result = new DialyzerSharingInfoResponse();
            String prefix = "";
            String makerName = "";
            List<MstDialyzer> listDialyzerTaboos = mstInfoService.findMstDialyzerTabooAllergy(patSrc.getFacility_cd(),
                patIdSrc.getPatIdSrc());
            for (MstDialyzer dialyzerTaboo : listDialyzerTaboos) {
              if (dialyzerTaboo.getDialyzerCd().equals(Integer.parseInt(dialyzerCd))) {
                if(dialyzerTaboo.getModelNumber().equals(dialyzer.getModelNumber())) {
                  result.setIsTabooAllergy(false);
                } else {
                  prefix = dialyzerTaboo.getModelNumber().replace(dialyzer.getModelNumber(), "");
                  result.setIsTabooAllergy(true);
                }
                if(dialyzer.getMaker() != null) {
                  makerName = dialyzer.getMaker();
                }
              }
            }
            result.setPrefix(prefix);
            result.setDialyzerName(prefix + makerName + "[" + dialyzer.getModelNumber() + "]");
            result.setUseStartDate(dialyzer.getUseStartDate());
            result.setUseEndDate(dialyzer.getUseEndDate());
          }
        }
      }
    }
    return new ResponseEntity<>(result, HttpStatus.OK);
    **/
    /* del by biangang  2023-01-31 CodeOptimization  end */
    /* modify by biangang  2023-01-31 CodeOptimization  start */
   return mstInfoService.getMstDialyzerSharingInfoByCd(dialyzerCd, patId);
    /* modify by biangang  2023-01-31 CodeOptimization  end */
  }

  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
  @GetMapping("/mstDialyzer/{pat_id}")
  /**
   * 対象患者の禁忌・アレルギー情報を含めたダイアライザマスタ一覧を取得
   */
  public ResponseEntity<List<MstDialyzerDto>> getMstDialyzerTabooAllergy(
      @PathVariable Long pat_id,
      @AuthenticationPrincipal NtssUser ntssUser) {
    try {
      //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　Start
      return new ResponseEntity<>(mstInfoService.findMstDialyzerTabooAllergy(ntssUser.getFacilityCd(), pat_id, null), HttpStatus.OK);
      //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　End
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
      null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end

  //add #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
  /**
   * 対象患者の禁忌・アレルギー情報を含めたダイアライザマスタ一覧を取得
   */
  @GetMapping("/mstDialyzerIncludeDel/{pat_id}")
  public ResponseEntity<List<MstDialyzerDto>> getMstDialyzerTabooAllergyWithDel(
    @PathVariable Long pat_id,
    @AuthenticationPrincipal NtssUser ntssUser) {
    try {
      boolean is_del_flg = true;
      return new ResponseEntity<>(mstInfoService.findMstDialyzerTabooAllergy(ntssUser.getFacilityCd(), pat_id, null, is_del_flg), HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  //add #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end

  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
  //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　Start
  @GetMapping("/mstDialyzer/{pat_id}/{TreatDate}")
  /**
   * 対象患者の禁忌・アレルギー情報を含めた期限切れなしのダイアライザマスタ一覧を取得
   */
  public ResponseEntity<List<MstDialyzerDto>> getMstDialyzerTabooAllergyNoexpire(
      @PathVariable Long pat_id,
      @PathVariable String TreatDate,
      @AuthenticationPrincipal NtssUser ntssUser) {
    try {
      return new ResponseEntity<>(mstInfoService.findMstDialyzerTabooAllergy(ntssUser.getFacilityCd(), pat_id, TreatDate), HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
      null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　End
  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end

  //#8484　医療材料選択IFのリスト不正　Start
  @GetMapping("/mstDialyzerTabooAllergyIncludeDeleted/{pat_id}")
  /**
   * 対象患者の禁忌・アレルギー情報を含めたダイアライザマスタ一覧を取得
   */
  public ResponseEntity<List<MstDialyzer>> getMstDialyzerTabooAllergyIncludeDeleted(
      @PathVariable Long pat_id,
      @AuthenticationPrincipal NtssUser ntssUser) {
    try {
      return new ResponseEntity<>(mstInfoService.findMstDialyzerTabooAllergyIncludeDeleted(ntssUser.getFacilityCd(), pat_id), HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
      null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  //#8484　医療材料選択IFのリスト不正　End
  @GetMapping("/mstDisease")
  /**
   * 病名マスタ一覧取得
   */
  // mod 9482 患者情報画面/新規患者登録の表示が遅い。 関  start
  //  public ResponseEntity<List<MstDisease>> getMstDiseaseAll(
  //    MstDisease params,
  //    @RequestParam(value = "page", required = false) Integer offset,
  //    @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
  //    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
  //    Page<MstDisease> page = mstInfoService.findMstDiseaseAll(pageable, params);
  //    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstDisease/", offset, limit);
  //    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  //  }
  public ResponseEntity<List<MstDiseaseCN>> getMstDiseaseAll(
      MstDisease params,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit,
      // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie end
  ) throws URISyntaxException {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie start
    if (ntssUser != null && !ntssUser.isNkkAdminUser()) {
      if (!ntssUser.getFacilityCd().equals(params.getFacilityCd())) {
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie end
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstDisease> page = mstInfoService.findMstDiseaseAll(pageable, params);
    List<MstDiseaseCN> mstDiseaseListTmp = new ArrayList<MstDiseaseCN>();
    page.getContent().forEach(item -> {
      MstDiseaseCN itemMap = new MstDiseaseCN();
      itemMap.setCd(item.getDiseaseCd());
      itemMap.setNm(item.getDiseaseName());
      mstDiseaseListTmp.add(itemMap);
    });
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstDisease/", offset, limit);
    return new ResponseEntity<>(mstDiseaseListTmp, headers, HttpStatus.OK);
  }
  // mod 9482 患者情報画面/新規患者登録の表示が遅い。 関  end

  @GetMapping("/mstDiseaseIncludeDeleted")
  /**
   * 病名マスタ一覧取得（削除済み含む）
   */
  // mod 9482 患者情報画面/新規患者登録の表示が遅い。 関  start
  //  public ResponseEntity<List<MstDisease>> getMstDiseaseAllIncludeDeleted(
  //    MstDisease params,
  //    @RequestParam(value = "page", required = false) Integer offset,
  //    @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
  //    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
  //    Page<MstDisease> page = mstInfoService.findMstDiseaseAllIncludeDeleted(pageable, params);
  //    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstDisease/", offset, limit);
  //    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  //  }
  public ResponseEntity<List<MstDiseaseCNF>> getMstDiseaseAllIncludeDeleted(
    MstDisease params,
    @RequestParam(value = "page", required = false) Integer offset,
    @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstDisease> page = mstInfoService.findMstDiseaseAllIncludeDeleted(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstDisease/", offset, limit);
    List<MstDiseaseCNF> mstDiseaseListTmp = new ArrayList<MstDiseaseCNF>();
    page.getContent().forEach(item -> {
      MstDiseaseCNF itemMap = new MstDiseaseCNF();
      itemMap.setCd(item.getDiseaseCd());
      itemMap.setNm(item.getDiseaseName());
      itemMap.setIsDisp(item.getIsDisp());
      itemMap.setIsDel(item.getIsDel());
      mstDiseaseListTmp.add(itemMap);
    });
    return new ResponseEntity<>(mstDiseaseListTmp, headers, HttpStatus.OK);
  }
  // mod 9482 患者情報画面/新規患者登録の表示が遅い。 関  end

  /* add #9482 患者情報画面/新規患者登録の表示が遅い。2023-09-21 by liumx --start */
  @GetMapping("/getMstDiseaseByCds")
  /**
   * 病名取得
   * @param diseaseCds 病名CD
   */
  public ResponseEntity<List<MstDisease>> getMstDiseaseByCds(
    @RequestParam(value = "diseaseCds") Integer[] diseaseCds) throws URISyntaxException  {
    List<MstDisease> dataList = mstInfoService.getMstDiseaseByCds(diseaseCds);
    return new ResponseEntity<>(dataList, HttpStatus.OK);
  }
  /* add #9482 患者情報画面/新規患者登録の表示が遅い。2023-09-21 by liumx --end */

  @GetMapping("/mstEquipmentClass")
  /**
   * 医療材料分類マスタ一覧取得
   */
  public ResponseEntity<List<MstEquipmentClass>> getMstEquipmentClassAll(
      MstEquipmentClass params,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit
      ) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstEquipmentClass> page = mstInfoService.findMstEquipmentClassAll(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstEquipmentClass/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  @GetMapping("/mstEquipmentClassIncludeDeleted")
  /**
   * 医療材料分類マスタ一覧取得（削除済み含む）
   */
  public ResponseEntity<List<MstEquipmentClass>> getMstEquipmentClassAllIncludeDeleted(
    MstEquipmentClass params,
    @RequestParam(value = "page", required = false) Integer offset,
    @RequestParam(value = "per_page", required = false) Integer limit
  ) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstEquipmentClass> page = mstInfoService.findMstEquipmentClassAllIncludeDeleted(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstEquipmentClassIncludeDeleted/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  @GetMapping("/mstEquipment")
  /**
   * 医療材料マスタ一覧取得
   */
  public ResponseEntity<List<MstEquipment>> getMstEquipmentAll(
      MstEquipment params,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit
      ) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstEquipment> page = mstInfoService.findMstEquipmentAll(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstEquipment/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  // FNSI-修正 マスタ削除の対応 wangchen add start
  @GetMapping("/mstEquipment/getByCd")
  /**
   * コードで医療材料マスタを取得する
   */
  public ResponseEntity<MstEquipment> getMstEquipmentByCd(@RequestParam(value = "equipmentCd") String equipmentCd ) throws URISyntaxException {
    MstEquipment equipment = mstInfoService.findMstEquipmentByCd(equipmentCd);
    return new ResponseEntity<>(equipment,HttpStatus.OK);
  }
  // FNSI-修正 マスタ削除の対応 wangchen add end

// FNSI-修正 マスタ削除の対応 chen add start
  @GetMapping("/mstEquipmentDel")
  /**
   * 医療材料マスタ取得
   */
  public ResponseEntity<List<MstEquipment>> getMstEquipmentAllNoDel(
    MstEquipment params,
    @RequestParam(value = "page", required = false) Integer offset,
    @RequestParam(value = "per_page", required = false) Integer limit
  ) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstEquipment> page = mstInfoService.findMstEquipmentAllNoDel(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstEquipment/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }
// FNSI-修正 マスタ削除の対応 chen add end

  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240909 start
  @GetMapping("/mstEquipmentIncludeDeleted")
  /**
   * 医療材料マスタ一覧取得（削除済のデータも含む）
   */
  public ResponseEntity<List<MstEquipmentExtends>> getMstEquipmentAllIncludeDeleted(
      MstEquipment params,
      @RequestParam(value = "page", required = false) Integer offset,
      //#8484　医療材料選択IFのリスト不正(#9978対応)　Start
      @RequestParam(value = "per_page", required = false) Integer limit
      //#8484　医療材料選択IFのリスト不正(#9978対応)　End
      ) throws URISyntaxException {

     try{
        Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
        //#8484　医療材料選択IFのリスト不正(#9978対応)　Start
        Page<MstEquipmentExtends> page = mstInfoService.findMstEquipmentAllIncludeDeleted(pageable, params);
       //#8484　医療材料選択IFのリスト不正(#9978対応)　End
       HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstEquipmentIncludeDeleted/", offset, limit);
       return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
     } catch(Exception e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
       if (params != null && params.getFacilityCd() != null) {
         eventLogMessage.setFacilityCd(params.getFacilityCd());
       }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
        logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
     }
  }
  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240909 end

  @GetMapping("/mstEquipment/getEquipmentSharingInfo")
  /**
   * コードで機器を入手する
   */
  public ResponseEntity<EquipmentSharingInfoResponse> getMstEquipmentSharingInfoByCd(@RequestParam(value = "equipmentCd") String equipmentCd,
      @RequestParam(value = "patId") Long patId) throws URISyntaxException {
    /* del by biangang  2023-02-01 CodeOptimization  start */
    /**
    EquipmentSharingInfoResponse result = null;
    List<PatNameIdentification> patIdSrcList = materialsSharingPatientInfomationService.getListPatIdSrcFromPatDst(patId);
    MstEquipment equipment = mstInfoService.findMstEquipmentByCd(equipmentCd);
    if (equipment != null) {
      String facilityCd = equipment.getFacilityCd();
      for (PatNameIdentification patIdSrc : patIdSrcList) {
        PatPersonalMain patSrc = patPersonalMainDao.selectById(patIdSrc.getPatIdSrc());
        if (patSrc != null) {
          if (patSrc.getFacility_cd().equals(facilityCd)) {
            result = new EquipmentSharingInfoResponse();
            String prefix = "";
            List<Integer> typeCdList = new ArrayList<>();
            List<MstEquipment> listEquipmentTaboos = mstInfoService.findMstEquipmentTabooAllergy(patSrc.getFacility_cd(),
                patIdSrc.getPatIdSrc(), typeCdList);
            for (MstEquipment equipmentTaboo : listEquipmentTaboos) {
              if (equipmentTaboo.getEquipmentCd().equals(Integer.parseInt(equipmentCd))) {
                if(equipmentTaboo.getEquipmentName().equals(equipment.getEquipmentName())) {
                  result.setIsTabooAllergy(false);
                } else {
                  prefix = equipmentTaboo.getEquipmentName().replace(equipment.getEquipmentName(), "");
                  result.setIsTabooAllergy(true);
                }
              }
            }
            result.setPrefix(prefix);
            result.setEquipmentName(equipment.getEquipmentName());
            result.setUseStartDate(equipment.getUseStartDate());
            result.setUseEndDate(equipment.getUseEndDate());
          }
        }
      }
    }
    return new ResponseEntity<>(result, HttpStatus.OK);
    **/
    /* del by biangang  2023-02-01 CodeOptimization  end */

    /* modify by biangang  2023-02-01 CodeOptimization  start */
    return mstInfoService.getMstEquipmentSharingInfoByCd(equipmentCd, patId);
    /* modify by biangang  2023-02-01 CodeOptimization  end */
  }

  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
  @GetMapping("/mstEquipment/{pat_id}")
  /**
   * 対象患者の禁忌・アレルギー情報を含めた 医療材料マスタ一覧を取得
   */
  public ResponseEntity<List<MstEquipmentDto>> getMstEquipmentTabooAllergy(
      @PathVariable long pat_id,
      @AuthenticationPrincipal NtssUser ntssUser) {
    try {
      List<Integer> typeCdList = new ArrayList<Integer>();
      //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　Start
      return new ResponseEntity<>(mstInfoService.findMstEquipmentTabooAllergy(ntssUser.getFacilityCd(), pat_id, typeCdList, null), HttpStatus.OK);
      //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　End
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
      null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end

  //#8484　医療材料選択IFのリスト不正　Start
  @GetMapping("/mstEquipmentTabooAllergyIncludeDeleted/{pat_id}")
  /**
   * 対象患者の禁忌・アレルギー情報を含めた 医療材料マスタ一覧(削除済み・期限切れを含む)を取得
   */
  public ResponseEntity<List<MstEquipment>> getMstEquipmentTabooAllergyIncludeDeleted(
      @PathVariable long pat_id,
      @AuthenticationPrincipal NtssUser ntssUser) {
    try {
      List<Integer> typeCdList = new ArrayList<Integer>();
      return new ResponseEntity<>(mstInfoService.findMstEquipmentTabooAllergyIncludeDeleted(ntssUser.getFacilityCd(), pat_id, typeCdList), HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
      null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  //#8484　医療材料選択IFのリスト不正　End

  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
  // add FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 start
  @GetMapping("/mstEquipment/{pat_id}/{is_del_flg}")
  /**
   * 対象患者の禁忌・アレルギー情報を含めた 医療材料マスタ一覧を取得
   */
  public ResponseEntity<List<MstEquipmentDto>> getMstEquipmentTabooAllergy(
    @PathVariable long pat_id,
    @PathVariable boolean is_del_flg,
    @AuthenticationPrincipal NtssUser ntssUser) {
    try {
      List<Integer> typeCdList = new ArrayList<Integer>();
      //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　Start
      return new ResponseEntity<>(mstInfoService.findMstEquipmentTabooAllergy(
        ntssUser.getFacilityCd(),
        pat_id,
        typeCdList,
        null,
        is_del_flg
      ), HttpStatus.OK);
      //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　End
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
        null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  // add FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 end
  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end

  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
  @PutMapping("/mstEquipment/{pat_id}")
  /**
   * 対象患者の禁忌・アレルギー情報を含めた 医療材料マスタの指定分類一覧を取得
   */
  public ResponseEntity<List<MstEquipmentDto>> getMstEquipmentTabooAllergyByType(
      @RequestBody List<Integer> typeCdList,
      @PathVariable long pat_id,
      @AuthenticationPrincipal NtssUser ntssUser) {
    try {
      //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　Start
      return new ResponseEntity<>(mstInfoService.findMstEquipmentTabooAllergy(ntssUser.getFacilityCd(), pat_id, typeCdList, null), HttpStatus.OK);
      //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　End
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
      null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end

  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
  @PutMapping("/mstEquipment/{pat_id}/{TreatDate}")
  /**
   * 対象患者の禁忌・アレルギー情報を含めた 医療材料マスタの指定分類一覧を取得
   */
  public ResponseEntity<List<MstEquipmentDto>> getMstEquipmentTabooAllergyByTypeNoexpire(
      @RequestBody List<Integer> typeCdList,
      @PathVariable long pat_id,
      @PathVariable String TreatDate,
      @AuthenticationPrincipal NtssUser ntssUser) {
    try {
      //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　Start
      return new ResponseEntity<>(mstInfoService.findMstEquipmentTabooAllergy(ntssUser.getFacilityCd(), pat_id, typeCdList, TreatDate), HttpStatus.OK);
      //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　End
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
      null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end

  @GetMapping("/mstEquipmentSet")
  /**
   * 医療材料セットマスタ一覧取得
   */
  public ResponseEntity<List<MstEquipmentSet>> getMstEquipmentSetAll(
      MstEquipmentSet params,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit
      ) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstEquipmentSet> page = mstInfoService.findMstEquipmentSetAll(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstEquipmentSet/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  @GetMapping("/mstEquipmentSet/{patId}")
  /**
   * 医療材料セットマスタ一覧取得(禁忌・アレルギー情報込み)
   */
  public ResponseEntity<List<MstEquipmentSet>> getMstEquipmentSetAllTabooAllergy(
      @PathVariable Long patId,
      @AuthenticationPrincipal NtssUser ntssUser
      ) {
    List<MstEquipmentSet> result = mstInfoService.findMstEquipmentSetAllTabooAllergy(ntssUser.getFacilityCd(), patId);
    return new ResponseEntity<>(result, HttpStatus.OK);
  }

  // FNSI-修正 マスタ削除の対応 wangchen add start
  @GetMapping("/mstEquipmentSetWithDeleted/{patId}")
  /**
   * 医療材料セットマスタ一覧取得(禁忌・アレルギー情報込み)
   */
  public ResponseEntity<List<MstEquipmentSet>> getMstEquipmentSetWithDeleted(
    @PathVariable Long patId,
    @AuthenticationPrincipal NtssUser ntssUser
  ) {
    List<MstEquipmentSet> result = mstInfoService.findMstEquipmentSetWithDeleted(ntssUser.getFacilityCd(), patId);
    result.forEach(x->{
      if(org.apache.commons.lang3.StringUtils.equals(x.getIsDisp(),"0")){
        x.setEquipmentSetName(LoggingConstant.MASTER_DELETE.DELETED_INCLUDE+x.getEquipmentSetName());
      }
    });
    return new ResponseEntity<>(result, HttpStatus.OK);
  }
  // FNSI-修正 マスタ削除の対応 wangchen add end

  @GetMapping("/mstFacility")
  /**
   * 施設マスタ一覧取得
   */
  public ResponseEntity<List<MstFacility>> getMstFacilityAll(
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstFacility> page = mstInfoService.findMstFacilityAll(pageable);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstFacility/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  @PutMapping("/saveMstFacility")
  /**
   * 施設マスタ登録・更新
   */
  public ResponseEntity<?> saveMstFacility(@RequestBody Map<String, List<String>> payload, @AuthenticationPrincipal NtssUser ntssUser) {
    try {
      mstInfoService.saveMstFacility(payload, ntssUser);
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
      null);
      return new ResponseEntity<>(new MasterUpdateResponse(e.getMessage()), HttpStatus.BAD_REQUEST);
    }
  }


  @GetMapping("/mstFacility/{id}")
  /**
   * 指定IDの施設マスタ取得
   */
  public ResponseEntity<MstFacility> getMstFacilityByCd(@PathVariable String id) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get MstFacility : " + id);
    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
      null);
    return Optional.ofNullable(mstInfoService.findMstFacilityByCd(id))
        .map(mstFacility -> new ResponseEntity<>(
            mstFacility,
            HttpStatus.OK))
        .orElse(new ResponseEntity<>(HttpStatus.NOT_FOUND));
  }

  @GetMapping("/mstFacilityWithoutCancel")
  /**
   * 施設マスタ一覧取得(解約中施設を除く)
   */
  public ResponseEntity<List<MstFacility>> getMstFacilityAllWithoutCancelFacilities(
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstFacility> page = mstInfoService.findMstFacilityAllWithoutCancelFacilities(pageable);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstFacilityWithoutCancel/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  @GetMapping("/mstImplant")
  /**
   * インプラントマスタ一覧取得
   */
  public ResponseEntity<List<MstImplant>> getMstImplantAll(
      MstImplant params,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstImplant> page = mstInfoService.findMstImplantAll(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstImplant/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }
  /*add FNSI-改修内容5237 任 start*/
  @GetMapping("/mstImplantDel")
  /**
   * インプラントマスタ一覧取得
   */
  public ResponseEntity<List<MstImplant>> getMstImplantDelAll(
    MstImplant params,
    @RequestParam(value = "page", required = false) Integer offset,
    @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstImplant> page = mstInfoService.findMstImplantDelAll(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstImplantDel/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }
  /*add FNSI-改修内容5237 任 end*/

  @GetMapping("/mstImplantIncludeDel")
  /**
   * インプラントマスタ一覧取得
   */
  public ResponseEntity<List<MstImplant>> getMstImplantAllIncludeDel(
    MstImplant params,
    @RequestParam(value = "page", required = false) Integer offset,
    @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstImplant> page = mstInfoService.findMstImplantAllIncludeDel(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstImplant/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  @PostMapping("/implantNameByCdList")
  /**
   * コードでインプラントマスタを取得する
   */
  public ResponseEntity<List<MstImplant>> getImplantNameByCdList(
      @RequestBody List<Integer> implantCdList) {
    try {
      List<MstImplant> implants = mstInfoService.findMstImplantNameByCdList(implantCdList);
      return new ResponseEntity<>(implants, HttpStatus.OK);
    } catch (Exception e) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
      return new ResponseEntity(HttpStatus.BAD_REQUEST);
    }
  }

  @GetMapping("/mstInfection")
  /**
   * 感染症マスタ一覧取得
   */
  public ResponseEntity<List<MstInfection>> getMstInfectionAll(
      MstInfection params,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstInfection> page = mstInfoService.findMstInfectionAll(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstInfection/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  @GetMapping("/mstInfectionIncludeDel")
  /**
   * 感染症マスタ一覧取得（削除済み含む）
   */
  public ResponseEntity<List<MstInfection>> getMstInfectionAllIncludeDel(MstInfection params) throws URISyntaxException {
    List<MstInfection> infections = mstInfoService.findMstInfectionAllIncludeDel(params.getFacilityCd());
    return new ResponseEntity<>(infections, HttpStatus.OK);
  }

  @GetMapping("/mstKur")
  /**
   * クールマスタ一覧取得
   */
  public ResponseEntity<List<MstKur>> getFindByFacilityCd(
      @RequestParam(value = "facility_cd", required = true) String facility_cd,
      @RequestParam(value = "is_del", required = false) String is_del,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit
      ) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstKur> page = mstInfoService.findMstKurByFacilityCd(pageable, facility_cd, is_del);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstKur/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

// FNSI-修正 マスタ削除の対応 chen add start
  @GetMapping("/mstKurDel")
  /**
   * クールマスタ一覧取得
   */
  public ResponseEntity<List<MstKur>> getFindByFacilityCdDel(
    @RequestParam(value = "facility_cd", required = true) String facility_cd,
    @RequestParam(value = "page", required = false) Integer offset,
    @RequestParam(value = "per_page", required = false) Integer limit
  ) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstKur> page = mstInfoService.findMstKurByFacilityCdDel(pageable, facility_cd);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstKur/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }
// FNSI-修正 マスタ削除の対応 chen add end

  @PutMapping("/saveMstKur/{facility_cd}")
  /**
   * クールマスタ登録・更新
   */
  public ResponseEntity<List<MstKur>> saveMstKurByCd(
      @PathVariable String facility_cd,
      @RequestBody Map<String, List<String>> payload
    ) {
    try {
      List<MstKur> insertedRecode = mstInfoService.saveMstKur(facility_cd, payload);
      return new ResponseEntity<>(insertedRecode, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facility_cd != null) {
        eventLogMessage.setFacilityCd(facility_cd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
      null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 常勤医設定変更
   * @param mstKurList
   * @return
   */
  @PutMapping("/saveDoctorMstKur")
  public ResponseEntity<List<MstKur>> saveDoctorMstKur(
    @RequestBody List<MstKur> mstKurList) {
    try {
      for (MstKur kurItem: mstKurList) {
        mstInfoService.saveDoctorMstKur(kurItem);
      }
      return new ResponseEntity<>(mstKurList, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
        null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  @GetMapping("/mstKur/getKurName")
  /**
   * クールマスター名
   */
  public ResponseEntity<String> getMstKurNameByCd(String kurCd) throws URISyntaxException {
    String kurName = mstInfoService.findKurNameByKurCd(kurCd);
    return new ResponseEntity<>(kurName, HttpStatus.OK);
  }

  @PutMapping("/saveMstSelector/{facility_cd}")
  /**
   * 並び順管理マスタ登録・更新(クールマスタのみ)
   */
  public ResponseEntity<Void> saveMstSelector(
      @PathVariable String facility_cd,
      @RequestBody Map<String, String> payload
    ) {
    try {
      mstInfoService.saveMstSelector(facility_cd, payload);
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
      null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  @GetMapping("/mstMedicateTiming")
  /**
   * 投与タイミングマスタ一覧取得
   */
  public ResponseEntity<List<MstMedicateTiming>> getMstMedicateTimingAll(
      MstMedicateTiming params,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit
      ) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstMedicateTiming> page = mstInfoService.findMstMedicateTimingAll(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstMedicateTiming/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }
  // FNSI-修正 マスタ削除の対応 chen add start
  @GetMapping("/medicateTimingIncludeDeleted")
  /**
   * クールマスタ一覧取得
   */
  public ResponseEntity<List<MstMedicateTiming>> getMstMedicateTimingIncludeDeleted(
    MstMedicateTiming params,
    @RequestParam(value = "page", required = false) Integer offset,
    @RequestParam(value = "per_page", required = false) Integer limit
  ) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstMedicateTiming> page = mstInfoService.findMstMedicateTimingIncludeDeleted(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstMedicateTiming/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }
// FNSI-修正 マスタ削除の対応 chen add end

  @GetMapping("/mstMedicineClass")
  /**
   * 薬剤分類マスタ一覧取得
   */
  public ResponseEntity<List<MstMedicineClass>> getMstMedicineClassAll(
      MstMedicineClass params,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit
      ) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstMedicineClass> page = mstInfoService.findMstMedicineClassAll(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstMedicineClass/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }


  @GetMapping("/mstMedicineClassIncludeDeleted")
  /**
   * 薬剤分類マスタ一覧取得（削除済み含む）
   */
  public ResponseEntity<List<MstMedicineClass>> getMstMedicineClassAllIncludeDeleted(
    MstMedicineClass params,
    @RequestParam(value = "page", required = false) Integer offset,
    @RequestParam(value = "per_page", required = false) Integer limit
  ) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstMedicineClass> page = mstInfoService.findMstMedicineClassAllIncludeDeleted(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstMedicineClassIncludeDeleted/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  @GetMapping("/mstMedicine")
  /**
   * 薬剤マスタ一覧取得
   */
  public ResponseEntity<List<MstMedicine>> getMstMedicineAll(
      MstMedicine params,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstMedicine> page = mstInfoService.findMstMedicineAll(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstMedicine", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  // FNSI-修正 マスタ削除の対応 wangchen add start
  @GetMapping("/mstMedicine/getByCd")
  /**
   * コードで薬剤マスタか調製薬剤マスタを取得
   */
  // mod 8374 2023-02-20 15:20 薬剤分類が抗凝固剤の調製薬剤で指示を発行しても分類不一致と表示される 張 start
//  public ResponseEntity<Object> getMstMedicineByCd(@RequestParam(value = "medicineCd") String medicineCd) throws URISyntaxException {
  public ResponseEntity<Object> getMstMedicineByCd(@RequestParam(value = "medicineCd") String medicineCd, @RequestParam(value = "medicineType",defaultValue = "1") String medicineType) throws URISyntaxException {
    if ("1".equals(medicineType)) {
      MstMedicine medicine = mstInfoService.findMstMedicineByCd(medicineCd);
      return new ResponseEntity<>(medicine, HttpStatus.OK);
    } else {
      MstMedicineMix medicineMix = mstInfoService.findMstMedicineMixByCd(medicineCd);
      return new ResponseEntity<>(medicineMix, HttpStatus.OK);
    }
  }
  // mod 8374 2023-02-20 15:20 薬剤分類が抗凝固剤の調製薬剤で指示を発行しても分類不一致と表示される 張 end
  // FNSI-修正 マスタ削除の対応 wangchen add end

// FNSI-修正 マスタ削除の対応 chen add start
  @GetMapping("/mstMedicineByCdNoDel")
  /**
   * 薬剤マスタ一覧取得
   */
  public ResponseEntity<List<MstMedicine>> getMstMedicineByCdNoDel(
    MstMedicine params,
    @RequestParam(value = "page", required = false) Integer offset,
    @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    MstMedicine mstMedicine = mstInfoService.findMstMedicineByCd(params);
    return new ResponseEntity(mstMedicine, HttpStatus.OK);
  }
// FNSI-修正 マスタ削除の対応 chen add end

  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
  @GetMapping("/mstMedicineIncludeDeleted")
  /**
   * 薬剤マスタ一覧取得（削除済のデータも含む）
   */
  public ResponseEntity<List<MstMedicineExtendsDto>> getMstMedicineAllIncludeDeleted(
      MstMedicine params,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstMedicineExtendsDto> page = mstInfoService.findMstMedicineAllIncludeDeleted(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstMedicineIncludeDeleted", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }
  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end

  @GetMapping("/mstMedicine/getMedicineSharingInfo")
  /**
   * コードで薬を手に入れる
   */
  public ResponseEntity<MedicineSharingInfoResponse> getMstMedicineSharingInfoByCd(@RequestParam(value = "medicineCd") String medicineCd,
      @RequestParam(value = "patId") Long patId) throws URISyntaxException {
    /* del by biangang  2023-02-01 CodeOptimization  start */
    /**
    MedicineSharingInfoResponse result = null;
    List<PatNameIdentification> patIdSrcList = materialsSharingPatientInfomationService.getListPatIdSrcFromPatDst(patId);
    MstMedicine medicine = mstInfoService.findMstMedicineByCd(medicineCd);
    if (medicine != null) {
      String facilityCd = medicine.getFacilityCd();
      for (PatNameIdentification patIdSrc : patIdSrcList) {
        PatPersonalMain patSrc = patPersonalMainDao.selectById(patIdSrc.getPatIdSrc());
        if (patSrc != null) {
          if (patSrc.getFacility_cd().equals(facilityCd)) {
            result = new MedicineSharingInfoResponse();
            String prefix = "";
            List<MstMedicine> listMedicineTaboos = mstInfoService.findMstMedicineTabooAllergy(patSrc.getFacility_cd(),
                patIdSrc.getPatIdSrc());
            for (MstMedicine medicineTaboo : listMedicineTaboos) {
              if (medicineTaboo.getMedicineCd().equals(Integer.parseInt(medicineCd))) {
                if(medicineTaboo.getMedicineName().equals(medicine.getMedicineName())) {
                  result.setIsTabooAllergy(false);
                } else {
                  prefix = medicineTaboo.getMedicineName().replace(medicine.getMedicineName(), "");
                  result.setIsTabooAllergy(true);
                }
              }
            }
            result.setPrefix(prefix);
            result.setMedicineName(medicine.getMedicineName());
            result.setUseStartDate(medicine.getUseStartDate());
            result.setUseEndDate(medicine.getUseEndDate());
          }
        }
      }
    }
    return new ResponseEntity<>(result, HttpStatus.OK);
     **/
    /* del by biangang  2023-02-01 CodeOptimization  end */

    /* modify by biangang  2023-02-01 CodeOptimization  start */
    return mstInfoService.getMstMedicineSharingInfoByCd(medicineCd, patId);
    /* modify by biangang  2023-02-01 CodeOptimization  end */
  }

  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
  @GetMapping("/mstMedicine/{pat_id}")
  /**
   * 対象患者の禁忌・アレルギー情報を含めた薬剤一覧を取得
   */
  public ResponseEntity<List<MstMedicineDto>> getMstMedicineTabooAllergy(
      @PathVariable long pat_id,
      @AuthenticationPrincipal NtssUser ntssUser) {
    try {
      return new ResponseEntity<>(mstInfoService.findMstMedicineTabooAllergy(ntssUser.getFacilityCd(), pat_id, null), HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
      null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end

  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
  /* add by chamaojia 2024-02-28 [10196] Add an interface for querying "medicine_cd" --start */
  @GetMapping("/mstMedicineByCd/{pat_id}/{medicine_cd}")
  /**
   * 対象患者の禁忌・アレルギー情報を含めた薬剤一覧を取得
   */
  public ResponseEntity<List<MstMedicineDto>> getMstMedicineTabooAllergyByCd(
          @PathVariable long pat_id,
          @PathVariable Integer medicine_cd,
          @AuthenticationPrincipal NtssUser ntssUser) {
    try {
      return new ResponseEntity<>(mstInfoService.findMstMedicineTabooAllergy(ntssUser.getFacilityCd(), pat_id, medicine_cd), HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
              null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  /* add by chamaojia 2024-02-28 [10196] Add an interface for querying "medicine_cd" --end */
  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end

  //add #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
  /**
   * 対象患者の禁忌・アレルギー情報を含めた薬剤一覧を取得
   */
  @GetMapping("/mstMedicineByCd/{pat_id}/{medicine_cd}/{is_Del_Flg}")
  public ResponseEntity<List<MstMedicineDto>> getAllMstMedicineTabooAllergyByCd(
    @PathVariable long pat_id,
    @PathVariable Integer medicine_cd,
    @AuthenticationPrincipal NtssUser ntssUser) {
    try {
      return new ResponseEntity<>(mstInfoService.findMstMedicineTabooAllergy(ntssUser.getFacilityCd(), pat_id, medicine_cd), HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
        null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  //add #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end

  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
  // add FNSI-期限切れ削除済みと表示するの修正 start
  @GetMapping("/mstMedicine/{pat_id}/{is_Del_Flg}")
  /**
   * 対象患者の禁忌・アレルギー情報を含めた薬剤一覧を取得
   */
  public ResponseEntity<List<MstMedicineDto>> getMstMedicineAllergy(
    @PathVariable long pat_id,
    @PathVariable boolean is_Del_Flg,
    @AuthenticationPrincipal NtssUser ntssUser) {
    try {
      return new ResponseEntity<>(mstInfoService.findMstMedicineTabooAllergy(ntssUser.getFacilityCd(), pat_id, null, is_Del_Flg), HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
        null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  // add FNSI-期限切れ削除済みと表示するの修正 end
  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end

  @GetMapping("/mstMedicineSet")
  /**
   * 薬剤セットマスタ一覧取得
   */
  public ResponseEntity<List<MstMedicineSet>> getMstMedicineSetAll(
      MstMedicineSet params,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit
      ) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstMedicineSet> page = mstInfoService.findMstMedicineSetAll(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstMedicineSet/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  @GetMapping("/mstMedicineSet/{patId}")
  /**
   * 薬剤セットマスタ一覧取得(禁忌・アレルギー情報込み)
   */
  public ResponseEntity<List<MstMedicineSet>> getMstMedicineSetAllTabooAllergyWithMix(
    @PathVariable Long patId,
    @AuthenticationPrincipal NtssUser ntssUser,
    @RequestParam(value = "page", required = false) Integer offset,
    @RequestParam(value = "per_page", required = false) Integer limit
  ) throws URISyntaxException {
    List<MstMedicineSet> result = mstInfoService.findMstMedicineSetAllTabooAllergy(ntssUser.getFacilityCd(), patId);
    return new ResponseEntity<>(result, HttpStatus.OK);
  }

  // FNSI-修正 マスタ削除の対応 wangchen add start
  @GetMapping("/mstMedicineSetWithDeleted/{patId}")
  /**
   * 薬剤セットマスタ一覧取得(禁忌・アレルギー情報込み)
   */
  public ResponseEntity<List<MstMedicineSet>> getMstMedicineSetWithDeleted(
    @PathVariable Long patId,
    @AuthenticationPrincipal NtssUser ntssUser,
    @RequestParam(value = "page", required = false) Integer offset,
    @RequestParam(value = "per_page", required = false) Integer limit
  ) throws URISyntaxException {
    List<MstMedicineSet> result = mstInfoService.findMstMedicineSetWithDeleted(ntssUser.getFacilityCd(), patId);
    result.forEach(x->{
      if(org.apache.commons.lang3.StringUtils.equals(x.getIsDisp(),"0")){
        x.setMedicineSetName(LoggingConstant.MASTER_DELETE.DELETED_INCLUDE+x.getMedicineSetName());
      }
    });
    return new ResponseEntity<>(result, HttpStatus.OK);
  }
  // FNSI-修正 マスタ削除の対応 wangchen add end

  @GetMapping("/mstMedicineGroup")
  /**
   * 薬剤グループマスタ一覧取得
   */
  public ResponseEntity<List<MstMedicineGroup>> getMstMedicineGroupAll(
    MstMedicineGroup params,
    @RequestParam(value = "page", required = false) Integer offset,
    @RequestParam(value = "per_page", required = false) Integer limit
  ) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstMedicineGroup> page = mstInfoService.findMstMedicineGroupAll(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstMedicineGroup/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }


  // add 投薬支援マスタ 削除されたデータの処理 孔 start
  @GetMapping("/mstMedicineGroupIncludeDeleted")
  /**
   * 薬剤グループマスタ一覧取得（削除済のデータも含む）
   */
  public ResponseEntity<List<MstMedicineGroup>> getMstMedicineGroupAllIncludeDeleted(
    MstMedicineGroup params,
    @RequestParam(value = "page", required = false) Integer offset,
    @RequestParam(value = "per_page", required = false) Integer limit
  ) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstMedicineGroup> page = mstInfoService.findMstMedicineGroupAllIncludeDeleted(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstMedicineGroupIncludeDeleted/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }
  // add 投薬支援マスタ 削除されたデータの処理 孔 end

  @GetMapping("/sysGenericMedicine")
  /**
   * 一般名処方マスタ一覧取得
   */
  public ResponseEntity<List<SysGenericMedicine>> getSysGenericMedicineAll(
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<SysGenericMedicine> page = mstInfoService.findSysGenericMedicineAll(pageable);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/sysGenericMedicine", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  @GetMapping("/sysGenericMedicineIncludeDeleted")
  /**
   * 一般名処方マスタ一覧取得（削除済のデータも含む）
   */
  public ResponseEntity<List<SysGenericMedicine>> getSysGenericMedicineAllIncludeDeleted(
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<SysGenericMedicine> page = mstInfoService.findSysGenericMedicineAllIncludeDeleted(pageable);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/sysGenericMedicineIncludeDeleted", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  @GetMapping("/getPatCalendarLayout")
  /**
   * 患者カレンダーレイアウト取得
   */
  public ResponseEntity<List<MstPatCalendarLayout>> getPatCalendarLayout(
      MstPatCalendarLayout params,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstPatCalendarLayout> page = mstInfoService.findMstPatCalendarLayoutAll(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/getPatCalendarLayout/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  @GetMapping("/getPatListLayout")
  /**
   * マルチ患者一覧レイアウト取得
   */
  public ResponseEntity<List<MstPatListLayout>> getPatListLayout(
      MstPatListLayout params,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstPatListLayout> page = mstInfoService.findMstPatListLayoutAll(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/getPatListLayout/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  @PutMapping("/updatePatListLayoutByCd/{pat_list_layout_cd}")
  /**
   * マルチ患者一覧レイアウト更新
   */
  public ResponseEntity<Void> updatePatListLayoutByCd(@PathVariable long pat_list_layout_cd, @RequestBody String payload) {
    try {
      mstInfoService.updateMstPatListLayoutByCd(pat_list_layout_cd, payload);
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
      null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  @GetMapping("/mstPatMemo")
  /**
   * 患者メモマスタ一覧取得
   */
  public ResponseEntity<List<MstPatMemo>> getMstPatMemoAll(
      MstPatMemo params,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstPatMemo> page = mstInfoService.findMstPatMemoAll(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstPatMemo/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  /**
   * 患者経過総合ビューアレイアウトマスタの一覧を取得する.
   *
   * @param params 患者経過総合ビューアレイアウトマスタのエンティティ
   * @param offset オフセット
   * @param limit 取得上限件数
   * @return 指定した施設の患者経過総合ビューアレイアウトマスタ一覧
   * @throws URISyntaxException ヘッダに登録するURIの生成に失敗した場合にスローする.
   */
  @GetMapping("/mstPatViewerLayout")
  public ResponseEntity<List<MstPatViewerLayout>> getMstPatViewerLayoutAll(
      MstPatViewerLayout params,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstPatViewerLayout> page = mstInfoService.findMstPatViewerLayoutAll(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/MstPatViewerLayout/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  /* modify by chamaojia 2023-06-05 モニタレイアウトマスタ下拉框可以选择バイタル的项目  --start */
  /**
   * 患者経過総合ビューアレイアウトマスタのバイタルモニタ項目の選択肢を取得する.
   *
   * @param facilityCd 施設コード 必須
   * @param vitalMonitorClass バイタル・モニタクラス 任意
   * @param isAllDisp 全表示フラグ 任意
   * @return レスポンスエンティティ
   */
  @GetMapping("/mstPatViewerLayout/monitorItem")
  public ResponseEntity<List<MstPatViewerLayoutMonitorItem>> getMonitorItemForMstPatViewerLayout(
    @RequestParam(value = "facilityCd", required = true) String facilityCd,
    @RequestParam(value = "vitalMonitorClass", required = false) String vitalMonitorClass,
    @RequestParam(value = "isAllDisp", required = false) String isAllDisp) {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("患者経過総合ビューアレイアウトマスタ：バイタル・モニタ項目取得API 開始:施設コード[" + facilityCd + "]");
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    List<MstPatViewerLayoutMonitorItem> result = mstInfoService.selectMonitorItemForMstPatViewerLayout(facilityCd, vitalMonitorClass, isAllDisp);

    eventLogMessage.setLogMessage("患者経過総合ビューアレイアウトマスタ：バイタル・モニタ項目取得API 終了:検索結果[" + result.size() + "]");
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    return new ResponseEntity<>(result, HttpStatus.OK);
  }
  /* modify by chamaojia 2023-06-05 モニタレイアウトマスタ下拉框可以选择バイタル的项目  --end */

  @GetMapping("/mstProcedure")
  /**
   * 手技マスタ一覧取得
   */
  public ResponseEntity<List<MstProcedure>> getMstPatMemoAll(
      MstProcedure params,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstProcedure> page = mstInfoService.findMstProcedureAll(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstProcedure/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  @GetMapping("/mstProcedureIncludeDeleted")
  /**
   * 手技マスタ一覧取得（削除済み含む）
   */
  public ResponseEntity<List<MstProcedure>> getMstPatMemoAllIncludeDeleted(
    MstProcedure params,
    @RequestParam(value = "page", required = false) Integer offset,
    @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstProcedure> page = mstInfoService.findMstProcedureAllIncludeDeleted(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstProcedureIncludeDeleted/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }


  @GetMapping("/mstRelationship")
  /**
   * 続柄マスタ一覧取得
   */
  public ResponseEntity<List<MstRelationship>> getMstRelationshipAll(
      MstRelationship params,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstRelationship> page = mstInfoService.findMstRelationshipAll(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstRelationship/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  @GetMapping("/mstRelationshipIncludeDel")
  /**
   * 続柄マスタ一覧取得,包含删除
   */
  public ResponseEntity<List<MstRelationship>> getMstRelationshipAllIncludeDel(
    MstRelationship params,
    @RequestParam(value = "page", required = false) Integer offset,
    @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstRelationship> page = mstInfoService.findMstRelationshipAllIncludeDel(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstRelationship/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  @GetMapping("/mstRoomBedGroup")
  /**
   * 透析室・ベッドグループマスタ一覧取得
   */
  public ResponseEntity<List<MstRoomBedGroup>> getMstRoomBedGroupAll(
      MstRoomBedGroup params,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstRoomBedGroup> page = mstInfoService.findMstRoomBedGroupAll(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstRoomBedGroup/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  @GetMapping("/mstSeverity")
  /**
   * 重症度マスタ一覧取得
   */
  public ResponseEntity<List<MstSeverity>> getMstSeverityAll(
      MstSeverity params,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstSeverity> page = mstInfoService.findMstSeverityAll(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstSeverity/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  @GetMapping("/mstSeverityIncludeDel")
  /**
   * 重症度マスタ一覧取得
   */
  public ResponseEntity<List<MstSeverity>> getMstSeverityAllIncludeDel(
    MstSeverity params,
    @RequestParam(value = "page", required = false) Integer offset,
    @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstSeverity> page = mstInfoService.findMstSeverityAllIncludeDel(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstSeverity/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  @GetMapping("/mstTabooAllergy")
  /**
   * 禁忌・アレルギーマスタ一覧取得
   */
  public ResponseEntity<List<MstTabooAllergy>> getMstTabooAllergyAll(
      MstTabooAllergy params,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstTabooAllergy> page = mstInfoService.findMstTabooAllergyAll(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstTabooAllergy/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  @GetMapping("/mstTabooAllergyIncludeDeleted")
  /**
   * 禁忌・アレルギーマスタ一覧取得（削除済のデータも含む）
   */
  public ResponseEntity<List<MstTabooAllergy>> getMstTabooAllergyAllIncludeDeleted(
      MstTabooAllergy params,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstTabooAllergy> page = mstInfoService.findMstTabooAllergyAllIncludeDeleted(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstTabooAllergyIncludeDeleted/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  @GetMapping("/mstTransport")
  /**
   * 搬送区分マスタ一覧取得
   */
  public ResponseEntity<List<MstTransport>> getMstTransportAll(
      MstTransport params,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstTransport> page = mstInfoService.findMstTransportAll(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstTransport/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  @GetMapping("/mstTransportInclude")
  /**
   * 搬送区分マスタ一覧取得
   */
  public ResponseEntity<List<MstTransport>> getMstTransportAllIncludeDel(
    MstTransport params,
    @RequestParam(value = "page", required = false) Integer offset,
    @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstTransport> page = mstInfoService.findMstTransportAllIncludeDel(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstTransport/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  @GetMapping("/mstTreatment")
  /**
   * 治療方法マスタ一覧取得
   */
  public ResponseEntity<List<MstTreatment>> getMstTreatmentAll(
      MstTreatment params,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstTreatment> page = mstInfoService.findMstTreatmentAll(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstTreatment/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

// FNSI-修正 マスタ削除の対応 chen add start
  @GetMapping("/mstTreatmentDel")
  /**
   * 治療方法マスタ一覧取得
   */
  public ResponseEntity<List<MstTreatment>> getMstTreatmentAllDel(
    MstTreatment params,
    @RequestParam(value = "page", required = false) Integer offset,
    @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstTreatment> page = mstInfoService.findMstTreatmentAllDel(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstTreatment/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }
// FNSI-修正 マスタ削除の対応 chen add end

  @GetMapping("/mstTreatmentIncludeDeleted")
  /**mstKur
   * 治療方法マスタ一覧取得（削除済のデータも含む）
   */
  public ResponseEntity<List<MstTreatment>> getMstTreatmentAllIncludeDeleted(
      MstTreatment params,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstTreatment> page = mstInfoService.findMstTreatmentAllIncludeDeleted(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstTreatment/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  @GetMapping("/mstTreatment/getTreatmentName")
  /**
   *  治療マスター名
   */
  public ResponseEntity<String> getMstTreatmentNameByCd(Integer treatmentCd) throws URISyntaxException {
    String treatmentName = mstInfoService.findMstTreatmentNameByCd(treatmentCd);
    return new ResponseEntity<>(treatmentName, HttpStatus.OK);
  }

  @GetMapping("/mstTreatmentSet")
  /**
   * 治療方法セットマスタ一覧取得
   */
  public ResponseEntity<List<MstTreatmentSet>> getMstTreatmentSetAll(
      MstTreatmentSet params,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstTreatmentSet> page = mstInfoService.findMstTreatmentSetAll(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstTreatmentSet/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  @GetMapping("/mstPersonalUser")
  /**
   * 利用者マスタ一覧取得
   */
  public ResponseEntity<List<MstPersonalUser>> getMstPersonalUserAll(
      @RequestParam(value = "facility_cd", required = true) String facility_cd,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstPersonalUser> page = mstInfoService.findMstPersonalUserAll(pageable, facility_cd);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstPersonalUser/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  /**
   * 利用者マスタ一覧取得,有効利用者
   */
  @GetMapping("/mstPersonalUserInUse")
  public ResponseEntity<List<MstPersonalUser>> getMstPersonalUserInUse(
    @RequestParam(value = "facility_cd", required = true) String facility_cd,
    @RequestParam(value = "page", required = false) Integer offset,
    @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstPersonalUser> page = mstInfoService.findMstPersonalUserInUse(pageable, facility_cd);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstPersonalUser/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  @GetMapping("/mstPersonalUserIncludeDel")
  /**
   * 利用者マスタ一覧取得，包含删除
   */
  public ResponseEntity<List<MstPersonalUser>> getMstPersonalUserAllIncludeDel(
    @RequestParam(value = "facility_cd", required = true) String facility_cd,
    @RequestParam(value = "page", required = false) Integer offset,
    @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstPersonalUser> page = mstInfoService.findMstPersonalUserAllIncludeDel(pageable, facility_cd);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstPersonalUser/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  @PostMapping("/mstPersonalUserByIdList")
  /**
   * Get MstPersonalUserById
   */
  public ResponseEntity<List<MstPersonalUser>> getMstPersonalUserNameByIdList(
      @RequestBody List<Long> listUserId) {

      List<MstPersonalUser> listUser = mstInfoService.getMstPersonalUserNameByIdList(listUserId);
      return new ResponseEntity<>(listUser, HttpStatus.OK);
  }
  @GetMapping("/mstVa")
  /**
   * VAマスタ一覧取得
   */
  public ResponseEntity<List<MstVa>> getMstVaAll(
      MstVa params,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit
      ) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstVa> page = mstInfoService.findMstVaAll(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstVa/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

// FNSI-修正 マスタ削除の対応 chen add start
  @GetMapping("/mstVaDel")
  /**
   * VAマスタ一覧取得
   */
  public ResponseEntity<List<MstVa>> getMstVaAllNoDel(
    MstVa params,
    @RequestParam(value = "page", required = false) Integer offset,
    @RequestParam(value = "per_page", required = false) Integer limit
  ) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstVa> page = mstInfoService.findMstVaAllNoDel(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstVa/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }
// FNSI-修正 マスタ削除の対応 chen add end

  @GetMapping("/mstVaIncludeDel")
  /**
   * VAマスタ一覧取得（削除済み含む）
   */
  public ResponseEntity<List<MstVa>> getMstVaAllIncludeDel(MstVa params) throws URISyntaxException {
    List<MstVa> vas = mstInfoService.findMstVaAllIncludeDel(params.getFacilityCd());
    return new ResponseEntity<>(vas, HttpStatus.OK);
  }

  @GetMapping("/mstVa/getVaName")
  /**
   * VAマスター名
   */
  public ResponseEntity<String> getMstVaNameByCd(
    @RequestParam(value = "vaCd", required = true) String vaCd) throws URISyntaxException {

      // wp アプリケーションログの適正化 Add Start
      String mappingUrl="/mstVa/getVaName";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null, vaCd);
      // wp アプリケーションログの適正化 Add End

    String vaName = condInfoService.findVaName(vaCd);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(vaName, HttpStatus.OK);
  }

  @GetMapping("/mstWard")
  /**
   * 病棟マスタ一覧取得
   */
  public ResponseEntity<List<MstWard>> getMstWardAll(
      MstWard params,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstWard> page = mstInfoService.findMstWardAll(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstWard/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  @GetMapping("/mstWardIncludeDel")
  /**
   * 病棟マスタ一覧取得,包含已经删除
   */
  public ResponseEntity<List<MstWard>> getMstWardAllIncludeDel(
    MstWard params,
    @RequestParam(value = "page", required = false) Integer offset,
    @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstWard> page = mstInfoService.findMstWardAllIncludeDel(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstWard/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  @GetMapping("/sysAddress")
  /**
   * 住所マスタ取得
   */
  public ResponseEntity<Page<SysAddress>> getSysAddressAll(
      SysAddress params,
      Pageable pageable
      ) throws URISyntaxException {
    Page<SysAddress> page = mstInfoService.findSysAddressAll(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/sysAddress/", (int)pageable.getOffset(), pageable.getPageSize());
    return new ResponseEntity<>(page, headers, HttpStatus.OK);
  }

  @GetMapping("/sysCountry")
  /*
   * 国名マスタ
   */
  public ResponseEntity<List<SysCountry>> getAll(
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<SysCountry> page = mstInfoService.findSysCountryAll(pageable);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/sysCountry/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  @PutMapping("/saveMstDeviceEdge")
  /**
   * デバイスエッジマスタ登録・更新
   */
  public ResponseEntity<Void> saveMstDeviceEdge(@RequestBody Map<String, List<String>> payload) {
    try {
      mstInfoService.saveMstDeviceEdge(payload);
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
      null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  @GetMapping("/sysSystemDefine/{ctl_no}")
  /**
   * システム設定取得
   */
  public ResponseEntity<List<SysSystemDefine>> getSysSystemDefineByCtlNo(@PathVariable Integer ctl_no) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get SysSystemDefine : " + ctl_no);
    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
      null);
    return Optional.ofNullable(mstInfoService.findSysSystemDefineByCtlNo(ctl_no))
      .map(SysSystemDefine -> new ResponseEntity<>(
          SysSystemDefine,
          HttpStatus.OK))
      .orElse(new ResponseEntity<>(HttpStatus.NOT_FOUND));
  }
//  @GetMapping("/sysFunction")
//  /**
//   * 機能一覧取得
//   */
//  public ResponseEntity<List<SysFunction>> getSysFunctionDispOnly(
//      SysFunction params,
//      @RequestParam(value = "page", required = false) Integer offset,
//      @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
//    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
//    Page<SysFunction> page = mstInfoService.findSysFunctionDispOnly(pageable, params);
//    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/sysFunction/", offset, limit);
//    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
//  }

  @GetMapping("/sysFunction")
  /**
   * 機能一覧取得、ページング無し
   */
  public ResponseEntity<List<SysFunction>> getSelectByDelAndDisp() throws URISyntaxException {
    return new ResponseEntity<>(mstInfoService.findSelectByDelAndDisp(), HttpStatus.OK);
  }

  /**
   * 選択肢マスタデータ取得(マスタ名指定)
   * @param masterName マスタ名称(物理名)
   * @param facilityCd 開示先施設
   * @return 指定したマスタの選択肢データ
   */
  @GetMapping("/{masterName}/mstSharingSelector")
  public ResponseEntity<List<MstSelector>> findSharingMstSelectorByMstName(
      @PathVariable String masterName,
      @RequestParam(name = "facilityCd",required = false) String facilityCd
  ) throws Exception{

    try {
      // 選択肢マスタの取得
      List<MstSelector> sysMasterDefine = mstInfoService.findMstSelectListByMstName(facilityCd, masterName);
      return new ResponseEntity<>(sysMasterDefine, HttpStatus.OK);

    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
      null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 選択肢マスタデータ取得(マスタ名指定)
   * @param masterName マスタ名称(物理名)
   * @param facilityCd 施設コード
   * @return 指定したマスタの選択肢データ
   */
  @GetMapping("/{masterName}/mstSelector")
  public ResponseEntity<MstSelector> findMstSelectorByMstName(
      @PathVariable String masterName,
      @RequestParam(name = "facilityCd",required = false) String facilityCd
  ) throws Exception{

    try {
      // 選択肢マスタの取得
      MstSelector sysMasterDefine = mstInfoService.findMstSelectorByMstName(facilityCd, masterName);
      return new ResponseEntity<>(sysMasterDefine, HttpStatus.OK);

    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
      null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 掲示板種別情報タデータ取得
   *
   * @param params 掲示板種別情報のエンティティ
   * @param offset オフセット
   * @param limit 取得上限件数
   * @return 指定した施設の掲示板種別情報取得
   * @throws URISyntaxException ヘッダに登録するURIの生成に失敗した場合にスローする.
   */
  @GetMapping("/mstBbsKind")
  public ResponseEntity<List<MstBbsKind>> getMstBbsKindByFacilityCd(
      MstBbsKind params,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit
      ) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstBbsKind> page = mstInfoService.findMstBbsKindByFacilityCd(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstBbsKind/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

// add マスタ削除 対応 chen start
  /**
   * 掲示板種別情報タデータ取得
   *
   * @param params 掲示板種別情報のエンティティ
   * @param offset オフセット
   * @param limit 取得上限件数
   * @return 指定した施設の掲示板種別情報取得
   * @throws URISyntaxException ヘッダに登録するURIの生成に失敗した場合にスローする.
   */
  @GetMapping("/mstBbsKindAll")
  public ResponseEntity<List<MstBbsKind>> getMstBbsKindAll(
    MstBbsKind params,
    @RequestParam(value = "page", required = false) Integer offset,
    @RequestParam(value = "per_page", required = false) Integer limit
  ) throws URISyntaxException {
    List<MstBbsKind> mstBbsKindList = mstInfoService.findMstBbsKindAll(params);
    return new ResponseEntity<>(mstBbsKindList, HttpStatus.OK);
  }
// add マスタ削除 対応 chen end

  @GetMapping("/mstBbsKindIncludeDeleted")
  /**
   * 掲示板種別マスタ一覧取得（削除済み含む）
   */
  public ResponseEntity<List<MstBbsKind>> getMstMedicineMixIncludeDeleted(MstBbsKind params) {
      List<MstBbsKind> bbsKinds = mstInfoService.findMstBbsKindIncludeDeleted(params);
      return new ResponseEntity<>(bbsKinds, HttpStatus.OK);
  }

  @GetMapping("/mstObsKind")
  /**
   * 観察記録種別マスタ取得
   */
  public ResponseEntity<List<MstObsKind>> getMstObsKindByFacilityCd(
      MstObsKind params,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstObsKind> page = mstInfoService.selectMstObsKindByFacilityCd(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstObsKind/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  /**
   * 職種マスタ登録・更新
   */
  @PutMapping("/saveMstJob")
  public ResponseEntity<Void> saveMstJob(@RequestBody Map<String, List<String>> payload) {
    try {
      mstInfoService.saveMstJob(payload);
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
      null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 職種の更新時処理
   */
  @PutMapping("/updMstJobAuthorities")
  public ResponseEntity<Void> updMstJobAuthorities(@RequestBody List<MstJobRequest> request, @AuthenticationPrincipal NtssUser ntssUser ) {
    try {
      mstInfoService.updMstJobAuthorities(request,ntssUser);
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
      null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  @GetMapping("/mstMedicineMix")
  /**
   * 調製薬剤マスタ一覧取得
   */
  public ResponseEntity<List<MstMedicineMix>> getMstMedicineMix(
      MstMedicineMix params,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit
      ) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstMedicineMix> page = mstInfoService.findMstMedicineMixAll(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstMedicineMix/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

// FNSI-修正 マスタ削除の対応 chen add start
  @GetMapping("/mstMedicineMixByCdNoDel")
  /**
   * 調製薬剤マスタ一覧取得
   */
  public ResponseEntity<List<MstMedicineMix>> getMstMedicineMixByCdNoDel(
    MstMedicineMix params,
    @RequestParam(value = "page", required = false) Integer offset,
    @RequestParam(value = "per_page", required = false) Integer limit
  ) throws URISyntaxException {
    MstMedicineMix mstMedicineMix = mstInfoService.findMstMedicineMixByCdNoDel(params);
    return new ResponseEntity(mstMedicineMix, HttpStatus.OK);
  }
// FNSI-修正 マスタ削除の対応 chen add end

  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
  @GetMapping("/mstMedicineMixIncludeDeleted")
  /**
   * 調製薬剤マスタ一覧取得（削除済のデータも含む）
   */
  public ResponseEntity<List<MstMedicineMixExtendsDto>> getMstMedicineMixIncludeDeleted(
      MstMedicineMix params,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit
      ) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstMedicineMixExtendsDto> page = mstInfoService.findMstMedicineMixAllIncludeDeleted(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstMedicineMixIncludeDeleted/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }
  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end

  @GetMapping("/mstMedicineMix/getMedicineMixSharingInfo")
  /**
   * コードで薬を手に入れる
   */
  public ResponseEntity<MedicineMixSharingInfoResponse> getMstMedicineMixSharingInfoByCd(@RequestParam(value = "medicineMixCd") String medicineMixCd,
      @RequestParam(value = "patId") Long patId) throws URISyntaxException {
    MedicineMixSharingInfoResponse result = mstInfoService.getMstMedicineMixSharingInfoByCd(medicineMixCd, patId);
//    List<PatNameIdentification> patIdSrcList = materialsSharingPatientInfomationService.getListPatIdSrcFromPatDst(patId);
//    MstMedicineMix medicineMix = mstInfoService.findMstMedicineMixByCd(medicineMixCd);
//    if (medicineMix != null) {
//      String facilityCd = medicineMix.getFacilityCd();
//      for (PatNameIdentification patIdSrc : patIdSrcList) {
//        PatPersonalMain patSrc = patPersonalMainDao.selectById(patIdSrc.getPatIdSrc());
//        if (patSrc != null) {
//          if (patSrc.getFacility_cd().equals(facilityCd)) {
//            result = new MedicineMixSharingInfoResponse();
//            String prefix = "";
//            List<MstMedicineMix> listMedicineMixTaboos = mstInfoService.findMstMedicineMixTabooAllergy(patSrc.getFacility_cd(),
//                patIdSrc.getPatIdSrc());
//            for (MstMedicineMix medicineMixTaboo : listMedicineMixTaboos) {
//              if (medicineMixTaboo.getMedicineMixCd().equals(Integer.parseInt(medicineMixCd))) {
//                if(medicineMixTaboo.getMedicineMixName().equals(medicineMix.getMedicineMixName())) {
//                  result.setIsTabooAllergy(false);
//                } else {
//                  prefix = medicineMixTaboo.getMedicineMixName().replace(medicineMix.getMedicineMixName(), "");
//                  result.setIsTabooAllergy(true);
//                }
//              }
//            }
//            result.setPrefix(prefix);
//            result.setMedicineMixName(medicineMix.getMedicineMixName());
//            // 配下の薬剤の使用開始日、使用終了日を集計して取得
//            List<MstMedicineMixResponse> objList = mstInfoService.mstMedicineMixAddTerm(new ArrayList<MstMedicineMix>(Arrays.asList(medicineMix)), patSrc.getFacility_cd(), patId);
//            result.setUseStartDate(objList.get(0).getMaxUseStartDate());
//            result.setUseEndDate(objList.get(0).getMinUseEndDate());
//          }
//        }
//      }
//    }
    return new ResponseEntity<>(result, HttpStatus.OK);
  }

  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
  @GetMapping("/mstMedicineMix/{pat_id}")
  /**
   * 対象患者の禁忌・アレルギー情報を含めた調製薬剤一覧を取得
   */
  public ResponseEntity<List<MstMedicineMixDto>> getMstMedicineMixTabooAllergy(
      @PathVariable long pat_id,
      @AuthenticationPrincipal NtssUser ntssUser) {
    try {
      // 一旦調製薬剤のリストを取得後、それぞれ配下の薬剤の使用開始日、使用終了日を集計して応答に含める
      List<MstMedicineMixDto> mediMixList = mstInfoService.findMstMedicineMixTabooAllergy(ntssUser.getFacilityCd(), pat_id, null);
      return new ResponseEntity<>(mstInfoService.mstMedicineMixAddTerm(mediMixList, ntssUser.getFacilityCd(), pat_id), HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
      null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end

  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
  /* add by chamaojia 2024-02-28 [10196] Add an interface for querying "medicine_cd" --start */
  @GetMapping("/mstMedicineMixByCd/{pat_id}/{medicine_cd}")
  /**
   * 対象患者の禁忌・アレルギー情報を含めた調製薬剤一覧を取得
   */
  public ResponseEntity<List<MstMedicineMixDto>> getMstMedicineMixTabooAllergy(
          @PathVariable long pat_id,
          @PathVariable Integer medicine_cd,
          @AuthenticationPrincipal NtssUser ntssUser) {
    try {
      // 一旦調製薬剤のリストを取得後、それぞれ配下の薬剤の使用開始日、使用終了日を集計して応答に含める
      List<MstMedicineMixDto> mediMixList = mstInfoService.findMstMedicineMixTabooAllergy(ntssUser.getFacilityCd(), pat_id, medicine_cd);
      return new ResponseEntity<>(mediMixList, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
              null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  /* add by chamaojia 2024-02-28 [10196] Add an interface for querying "medicine_cd" --end */
  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end

  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
  // add FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 start
  @GetMapping("/mstMedicineMix/{pat_id}/{isDelFlg}")
  /**
   * 対象患者の禁忌・アレルギー情報を含めた調製薬剤一覧を取得
   */
  public ResponseEntity<List<MstMedicineMixDto>> getMstMedicineMixTabooAllergy(
    @PathVariable long pat_id,
    @PathVariable boolean isDelFlg,
    @AuthenticationPrincipal NtssUser ntssUser) {
    try {
      // 一旦調製薬剤のリストを取得後、それぞれ配下の薬剤の使用開始日、使用終了日を集計して応答に含める
      List<MstMedicineMixDto> mediMixList = mstInfoService.findMstMedicineMixTabooAllergy(ntssUser.getFacilityCd(), pat_id, null, isDelFlg);
      return new ResponseEntity<>(mstInfoService.mstMedicineMixAddTerm(mediMixList, ntssUser.getFacilityCd(), pat_id), HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
        null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  // add FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 end
  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end

  @GetMapping("/mstExamItem")
  /**
   * 検査項目マスタ取得
   */
  public ResponseEntity<List<MstExamItem>> getMstExamItemByFacilityCd(
      MstExamItem params,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstExamItem> page = mstInfoService.selectMstExamItemByFacilityCd(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstExamItem/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  @GetMapping("/mstExamItemForExamCalc")
  /**
   * 検査項目マスタ取得()
   */
  public ResponseEntity<?> getMstExamItemForExamCalc(@AuthenticationPrincipal NtssUser ntssUser) {
    try {
      return new ResponseEntity<>(mstInfoService.findExamItemListForExamCalc(ntssUser.getFacilityCd()), HttpStatus.OK);
    } catch (Exception e) {
      // マスタデータが取得できなかった場合
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("Exception message :" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
      null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
          HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  // #9477 2023.11.17 add 検査項目マスタで「仮想端末表示がONのもの」を100件まで取得 TDC山崎 start
  /**
   * 検査項目マスタデータ取得(通信SV用)
   * @param facilityCd 開示先施設
   * @return 検査項目マスタの選択肢データ
   */
  @GetMapping("/mstExamItemForComsv")
  public ResponseEntity<List<MstSelector>> getMstExamItemForComsvByFacilityCd(
    @RequestParam(name = "facilityCd",required = false) String facilityCd
  ) throws Exception {
    try {
      // 検査項目マスタで「仮想端末表示がONのもの」を100件まで取得
      List<MstSelector> sysMasterDefine = mstInfoService.findMstExamItemForComsvByFacilityCd(facilityCd);
      return new ResponseEntity<>(sysMasterDefine, HttpStatus.OK);

    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
        null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  // #9477 2023.11.17 add 検査項目マスタで「仮想端末表示がONのもの」を100件まで取得 TDC山崎 end

  @GetMapping("/mstSpitz")
  /**
   * 採血管マスタ取得
   */
  public ResponseEntity<List<MstSpitz>> getMstSpitzByFacilityCd(
      MstSpitz params,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstSpitz> page = mstInfoService.selectMstSpitzByFacilityCd(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstSpitz/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  @GetMapping("/mstRadSet")
  /**
   * 放射線検査セットマスタ取得
   */
  public ResponseEntity<List<MstRadSet>> getMstRadSetByFacilityCd(
      MstRadSet params,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstRadSet> page = mstInfoService.selectMstRadSetByFacilityCd(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstRadSet/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  @PutMapping("/saveSysFacility")
  /**
   * 全施設マスタ登録・更新
   */
  public ResponseEntity<?> saveSysFacility(@RequestBody Map<String, List<String>> payload) {
    try {
      mstInfoService.saveSysFacility(payload);

      //add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 start
      List<Map<String, Object>> data = new ArrayList<>();
      List<String> updStr = payload.get("updateRecord");
      if(updStr != null && !updStr.isEmpty()){
        for (String s : updStr) {
          JSONObject object = new JSONObject(s);
          Map<String, Object> map = new HashMap<>();
          Iterator<String> keys = object.keys();
          while (keys.hasNext()) {
            String key = keys.next();
            map.put(key, object.get(key));
          }
          data.add(map);
        }
      }

      List<String> delStr = payload.get("deleteCdRecord");
      if(delStr != null && !delStr.isEmpty()){
        for (String s : delStr) {
          JSONObject object = new JSONObject(s);
          Map<String, Object> map = new HashMap<>();
          Iterator<String> keys = object.keys();
          while (keys.hasNext()) {
            String key = keys.next();
            map.put(key, object.get(key));
          }
          data.add(map);
        }
      }

      if(!data.isEmpty()){
        mongoService.savePatDataToMongo(data, "sys_facility", null);
      }
      //add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 end

      return new ResponseEntity<>(HttpStatus.OK);
    } catch (DuplicateKeyException e) {
      /* 一意制約違反 */
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);

      // JSON構造をMapで直接構築
      Map<String, Object> errorBody = new HashMap<>();
      errorBody.put("errorCode", ResponseKind.CONFLICT_CUSTOM);
      errorBody.put("message", "一意制約違反");

      return new ResponseEntity<>(errorBody, HttpStatus.CONFLICT);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
      null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  @GetMapping("/mstFavoriteFacility")
  /**
   * よく使う施設マスタ取得
   */
  public ResponseEntity<List<MstFavoriteFacility>> getMstFavoriteFacilityByFacilityCd(
      @AuthenticationPrincipal NtssUser ntssUser,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstFavoriteFacility> page = mstInfoService.selectMstFavoriteFacilityByFacilityCd(pageable, ntssUser.getFacilityCd());
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstFavoriteFacility/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  /***
   * 施設マスタのパラメータ指定による検索
   *
   * @param prefecturesCd 都道府県コード
   * @param keyword キーワード
   * @param limit 1ページの件数
   * @param page 取得対象のページ
   * @return {@link SysFacility}のリスト
   */
  @GetMapping("/getSysFacilityBySearchConditions")
  public ResponseEntity<List<SysFacility>> getSysFacilityBySearchConditions(
    @RequestParam(name = "prefecturesCd", required = false) String prefecturesCd,
    @RequestParam(name = "keyword", required = false) String keyword,
    @RequestParam(name = "limit", required = false) Integer limit,
    @RequestParam(name = "page", required = false) Integer page
  ) {
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("パラメータ指定による施設マスタ取得のRestAPI実行");
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // レスポンス生成
    List<SysFacility> response = mstInfoService.findBySearchConditions(prefecturesCd, keyword, limit, page);
    // ログ出力
    eventLogMessage.setLogMessage("施設マスタ取得:取得件数[" +  response.size() + "]");
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * 与えられた施設コード及びバイタル・モニタ区分に該当する {@link MstAddMonitor} のリストを取得.
   * 該当するデータがない場合、空のリストを返す.
   *
   * @param facilityCd 施設コード
   * @param vitalMonitorClass バイタル・モニタ区分
   * @return 該当する {@link MstAddMonitor} のリスト
   */
  @GetMapping("/mstAddMonitorByClass")
  public ResponseEntity<List<MstAddMonitor>> getMstAddMonitorByVitalMonitorClass(
    @RequestParam(value = "facility_cd") String facilityCd,
    @RequestParam(value = "vital_monitor_class") String vitalMonitorClass
  ) {
    List<MstAddMonitor> result = mstInfoService.selectMstAddMonitorByVitalMonitorClass(facilityCd, vitalMonitorClass);
    return new ResponseEntity<>(result, HttpStatus.OK);
  }

  /**
   * 与えられた施設コードに該当する{@link MstAddMonitor}のリストを取得.
   * 該当するデータがない場合、空のリストを返す.
   * ※非表示及び削除のデータも含む.
   *
   * @param facilityCd 施設コード
   * @return 施設に該当する {@link MstAddMonitor} のリスト
   */
  @GetMapping("/mstAddMonitorByFacilityCd")
  public ResponseEntity<List<MstAddMonitor>> getMstAddMonitorByFacilityCd(
    @RequestParam(value = "facility_cd") String facilityCd
  ) {
    List<MstAddMonitor> result = mstInfoService.selectMstAddMonitorByFacilityCd(facilityCd);
    return new ResponseEntity<>(result, HttpStatus.OK);
  }

  /**
   *
   * @param facilityCd 施設コード
   * @param offset
   * @param limit
   * @return
   * @throws URISyntaxException
   */
  @GetMapping("/mstMedicineWithMix")
  public ResponseEntity<List<MedicineResponse>> getMstMedicineAllWithMix(
    String facilityCd,
    @RequestParam(value = "page", required = false) Integer offset,
    @RequestParam(value = "per_page", required = false) Integer limit) {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    List<MedicineResponse> result = mstInfoService.selectMedicineAllWithMix(pageable, facilityCd);
    return new ResponseEntity<>(result, HttpStatus.OK);
  }

  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
  /**
   * @param facilityCd 施設コード
   * @param patId 患者ID
   * @param offset
   * @param limit
   * @return
   * @throws URISyntaxException
   */
  @GetMapping("/mstMedicineWithMix/{patId}")
  public ResponseEntity<List<MedicineResponseExtends>> getMstMedicineAllTabooAllergyWithMix(
    String facilityCd,
    @PathVariable Long patId,
    @RequestParam(value = "page", required = false) Integer offset,
    @RequestParam(value = "per_page", required = false) Integer limit) {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    List<MedicineResponseExtends> result = mstInfoService.selectMedicineAllTabooAllergyWithMix(pageable, facilityCd, patId, -1);
    return new ResponseEntity<>(result, HttpStatus.OK);
  }

  /**
   * @param facilityCd 施設コード
   * @param patId 患者ID
   * @param offset
   * @param limit
   * @return
   * @throws URISyntaxException
   */
  @GetMapping("/mstMedicineWithMix/{patId}/{classType}")
  public ResponseEntity<List<MedicineResponseExtends>> getMstMedicineTabooAllergyWithMixFilterByType(
    String facilityCd,
    @PathVariable Long patId,
    @PathVariable Integer classType,
    @RequestParam(value = "page", required = false) Integer offset,
    @RequestParam(value = "per_page", required = false) Integer limit) {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    List<MedicineResponseExtends> result = mstInfoService.selectMedicineAllTabooAllergyWithMix(pageable, facilityCd, patId, classType);
    return new ResponseEntity<>(result, HttpStatus.OK);
  }
  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end

  /**
   * 患者カレンダーレイアウト取得
   * @param ntssUser
   * @param offset
   * @param limit
   * @param facilityCd 施設コード
   * @return
   */
  @GetMapping("/getFacilityCalendarLayout")
  public ResponseEntity<List<MstFacilityCalendarLayout>> getFacilityCalendarLayout(
	  @AuthenticationPrincipal NtssUser ntssUser,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit,
      @RequestParam(value = "facilityCd", required = false) String facilityCd) throws URISyntaxException {
    // 施設コードの指定なしの場合はユーザーの施設コードを使用
    // ※既存の動きに影響を与えないための保護措置
    if(org.apache.commons.lang3.StringUtils.isEmpty(facilityCd)) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("getFacilityCalendarLayout : not facilityCd param, use ntssUser facilityCd");
      logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
      facilityCd = ntssUser.getFacilityCd();
    }
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstFacilityCalendarLayout> page = mstInfoService.findMstFacilityCalendarLayoutAll(pageable, facilityCd);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/getFacilityCalendarLayout/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  /**
   * @param ntssUser
   * @param offset
   * @param limit
   * @return
   * @throws URISyntaxException
   */
  @GetMapping("/mstWaterSurveyPoint")
  public ResponseEntity<?> getAllWaterSurveyPoint(@AuthenticationPrincipal NtssUser ntssUser,
       @RequestParam(value = "page", required = false) Integer offset,
       @RequestParam(value = "per_page", required = false) Integer limit){
    try {
      Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
      List<WaterSurveyPoint> response = mstInfoService.selectALLWaterSurveyPoint(pageable, ntssUser.getFacilityCd());
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * @PathVariable surveyPointCd
   * @return
   * @throws URISyntaxException
   */
  @GetMapping("/mstWaterSurveyPoint/{surveyPointCd}")
  public ResponseEntity<?> getSurveyPointByCd(@PathVariable Long surveyPointCd){
    try {
      WaterSurveyPoint response = mstInfoService.selectWaterSurveyPointByCd(surveyPointCd);
      if(response != null) {
        return new ResponseEntity<>(response, HttpStatus.OK);
      }else {
        return new ResponseEntity<>(HttpStatus.NOT_FOUND);
      }

    } catch (Exception e) {
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * @param ntssUser
   * @param offset
   * @param limit
   * @param facilityCd 施設コード
   * @return
   * @throws URISyntaxException
   */
  @GetMapping("/mstWaterSurveyType")
  public ResponseEntity<?> getALLWaterSurveyType(@AuthenticationPrincipal NtssUser ntssUser,
      @RequestParam(value = "page", required = false) Integer offset,
       @RequestParam(value = "per_page", required = false) Integer limit,
       @RequestParam(value = "facilityCd", required = false) String facilityCd){
    try {
      // 施設コードの指定なしの場合はユーザーの施設コードを使用
      // ※既存の動きに影響を与えないための保護措置
      if(org.apache.commons.lang3.StringUtils.isEmpty(facilityCd)) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("getALLWaterSurveyType : not facilityCd param, use ntssUser facilityCd");
        logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
        facilityCd = ntssUser.getFacilityCd();
      }
      Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);

      List<MstWaterSurveyType> response = mstInfoService.selectALLWaterSurveyType(pageable, facilityCd);
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * @PathVariable surveyTypeCd
   * @return
   * @throws URISyntaxException
   */
  @GetMapping("/mstWaterSurveyType/{surveyTypeCd}")
  public ResponseEntity<?> getSurveyTypeByCd(@PathVariable Long surveyTypeCd){
    try {
      MstWaterSurveyType response = mstInfoService.selectWaterSurveyTypeByCd(surveyTypeCd);
      if(response != null) {
        return new ResponseEntity<>(response, HttpStatus.OK);
      }else {
        return new ResponseEntity<>(HttpStatus.NOT_FOUND);
      }

    } catch (Exception e) {
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 施設マスタ一覧取得
   */
  @GetMapping("/mstFacility/kanaSort")
  public ResponseEntity<List<MstFacility>> getMstFacilitySortByKana(
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstFacility> page = mstInfoService.findMstFacilitySortByKana(pageable);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page,
        Uri.MST_INFO + "/mstFacility/kanaSort", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

	/**
	 * 加算マスタ取得
	 */
  @GetMapping("/mstAddition")
	public ResponseEntity<List<MstAddition>> getMstAdditionAll(MstAddition params,
			@RequestParam(value = "page", required = false) Integer offset,
			@RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
		Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
		Page<MstAddition> page = mstInfoService.findMstAdditionByFacilityCd(pageable, params);
		HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstAddition/",
				offset, limit);
		return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
	}

  /**
	 * 患者イベントサブカテゴリを取得
	 * @param facilityCd
	 * @param offset
	 * @param limit
	 * @return
	 */
	@GetMapping("/mstPatEventSubCategory")
	public ResponseEntity<List<MstPatEventSubCategory>> getMstPatEventSubCategory(String facilityCd,
			@RequestParam(value = "page", required = false) Integer offset,
			@RequestParam(value = "per_page", required = false) Integer limit) {
		Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
		List<MstPatEventSubCategory> result = mstInfoService.selectPatEventSubCategory(pageable, facilityCd);
		return new ResponseEntity<>(result, HttpStatus.OK);
	}

	/**
	 * 患者イベントサブカテゴリを取得（削除済のデータも含む）
	 * @param facilityCd
	 * @param offset
	 * @param limit
	 * @return
	 */
	@GetMapping("/mstPatEventSubCategoryIncludeDeleted")
	public ResponseEntity<List<MstPatEventSubCategory>> getMstPatEventSubCategoryIncludeDeleted(String facilityCd,
	        @RequestParam(value = "page", required = false) Integer offset,
	        @RequestParam(value = "per_page", required = false) Integer limit) {
	    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
	    List<MstPatEventSubCategory> result = mstInfoService.selectPatEventSubCategoryIncludeDeleted(pageable, facilityCd);
	    return new ResponseEntity<>(result, HttpStatus.OK);
	}

  /**
	 * 祝日を取得
	 *
	 * @return
	 */
	@GetMapping("/mstHoliday/nkk")
	public ResponseEntity<List<HolidayDetail>> getMstHolidayByNkk(
			@RequestParam(value = "holidayY", required = true) Integer holidayY) {
		List<HolidayDetail> result = mstInfoService.selectMstHolidayByNkk(holidayY);
		return new ResponseEntity<>(result, HttpStatus.OK);
	}
	/**
	 * 拡張機能を取得
	 * @return
	 */
  @GetMapping("/sysFunctionAdvanced")
  public  ResponseEntity<List<SysFunctionAdvanced>> getAllSysFunctionAdvanceds() {
      return new ResponseEntity<>(mstInfoService.selectAllSysFunctionAdvanceds(), HttpStatus.OK);
  }

  /**
   * 外部リンク登録マスタを取得する
   * @param facilityCd 施設コード
   * @return 外部リンクリスト
   */
  @GetMapping("/mstUrlLinkRegister")
  public ResponseEntity<List<MstUrlLinkRegister>> getAllMstUrlLinkRegister(
    @RequestParam(name = "facilityCd", required = true) String facilityCd
  ) {
    return new ResponseEntity<List<MstUrlLinkRegister>>(mstInfoService.selectAllMstUrlLinkRegister(facilityCd), HttpStatus.OK);
  }

  /**
   * メニューグループマスタを取得する
   * @param facilityCd 施設コード
   * @return メニューグループリスト
   */
  @GetMapping("/mstMenuGroup")
  public ResponseEntity<List<MstMenuGroup>> getAllMstMenuGroup(
    @RequestParam(name = "facilityCd", required = true) String facilityCd
  ) {
    return new ResponseEntity<List<MstMenuGroup>>(mstInfoService.selectAllMstMenuGroup(facilityCd), HttpStatus.OK);
  }

  /**
   * 職種マスタを取得する
   * @param facilityCd 施設コード
   * @return 職種リスト
   */
  @GetMapping("/mstJob")
  public ResponseEntity<List<MstJob>> getAllMstJob(
    @RequestParam(name = "facilityCd", required = true) String facilityCd
  ) {
    return new ResponseEntity<List<MstJob>>(mstInfoService.selectAllMstJob(facilityCd), HttpStatus.OK);
  }

  /**
   * すべての装置マスタを取得する
   * @param ntssUser
   * @return 装置マスタリスト
   */
  @GetMapping("/mstMachine")
  public ResponseEntity<List<MstMachine>> getAllMstMachine(
    @RequestParam(name = "facility_cd", required = true) String facilityCd) {
    return new ResponseEntity<List<MstMachine>>(mstInfoService.selectAllMstMachine(facilityCd), HttpStatus.OK);
  }

  /**
   * 指定CDの警報通知マスタレコードを取得する
   * @param alarmNotificationCd 警報通知コード
   * @return 警報通知マスタレコード
   */
  @GetMapping("/mstAlarmNotification/detail")
  public ResponseEntity<MstAlarmNotification> getAlarmNotificationDetail(
    @RequestParam(value = "alarmNotificationCd", required = true) Long alarmNotificationCd) {
    return new ResponseEntity<>(mstInfoService.findAlarmNotificationDetail(alarmNotificationCd), HttpStatus.OK);
  }

  /**
   * 施設CDでシステム機能を取得
   * @param facilityCd
   * @return
   * @throws URISyntaxException
   */
  @GetMapping("/sysAllFunction/{facilityCd}")
  public ResponseEntity<List<SysFunctionResponse>> getSysFunctionByFacilityCd(
      @PathVariable String facilityCd) throws URISyntaxException {
    List<SysFunctionResponse> response = mstInfoService.findSysFuncAdvAndSysFuncByFacilityCd(facilityCd);
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * システム申込プランを取得
   * @param offset
   * @param limit
   * @return
   * @throws URISyntaxException
   */
  @GetMapping("/sysSubscriptionPlan")
  public ResponseEntity<List<SysSubscriptionPlan>> getSysSubscriptionPlanList(
    @RequestParam(value = "page", required = false) Integer offset,
    @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<SysSubscriptionPlan> page = mstInfoService.findSysSubscriptionPlan(pageable);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/sysSubscriptionPlan/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }

  /**
   * 連携設定マスタを取得
   * @param 施設コード
   * @return
   */
  @GetMapping("/mstCoopFacility")
  public ResponseEntity<?> getMstCoopFacility(
    @RequestParam(name = "facilityCd", required = true) String facilityCd
  ) {
    try {
      return new ResponseEntity<>(mstInfoService.getMstCoopFacility(facilityCd), HttpStatus.OK);
    } catch (Exception e) {
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * テンプレートコードによりデータリストカテゴリリストを取得
   * @param templateCd　テンプレートコード
   * @return　データリストカテゴリリスト
   */
  @GetMapping("/sysDataListCategory/getByTemplate/{templateCd}")
  public ResponseEntity<?> getSysDataListCategoryByTemplateCd(
	@PathVariable Integer templateCd
  ) {
    try {
      return new ResponseEntity<>(mstInfoService.findSysDataListCategoryByTemplateCd(templateCd), HttpStatus.OK);
    } catch (Exception e) {
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * ログ条件用の機能リストを取得
   * @return
   */
  @GetMapping("/log/sysFunction")
  public ResponseEntity<?> getSysFunctionForLogCondition() {
    try {
      return new ResponseEntity<>(mstInfoService.findSysFunctionForLogCondition(), HttpStatus.OK);
    } catch (Exception e) {
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  @GetMapping("/mstExamMatome")
  /**
   * 検査まとめ表一覧取得
   */
  public ResponseEntity<List<MstExamMatome>> getMstExamMatomeAll(
	    MstExamMatome params) throws URISyntaxException {
    Page<MstExamMatome> page = mstInfoService.findmstExamMatomeAll();
    return new ResponseEntity<>(page.getContent(), HttpStatus.OK);
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

// add FutreNetWeb+SI課題管理No4770対応 趙 start
  @GetMapping("/mstExamSet")
  /**
   * 搬送区分マスタ一覧取得
   */
  public ResponseEntity<List<MstExamSet>> getMstExamAll(
    MstExamSet params,
    @RequestParam(value = "page", required = false) Integer offset,
    @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstExamSet> page = mstInfoService.findMstExamAll(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstExamSet/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }
// add FutreNetWeb+SI課題管理No4770対応 趙 end

  /**
   * 連携エッジマスタを取得
   * @param facilityCd
   * @return
   * @throws URISyntaxException
   */
  @GetMapping("/mstIfEdge/{facilityCd}")
  public ResponseEntity<?> getMstIfEdgeByFacilityCd(
      @PathVariable String facilityCd) throws URISyntaxException {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.MST_INFO + "/mstIfEdge/" + facilityCd;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    try {
      List<MstIfEdge> mstIfEdges = mstInfoService.getMstIfEdgeByFacilityCd(facilityCd);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(mstIfEdges, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end

      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),"", AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 項目を登録する。
   * @param mstIfEdge
   * @return
   * @throws URISyntaxException
   */
  @PostMapping("/mstIfEdge/submit")
  public ResponseEntity<?> updateIfEdge(@RequestBody MstIfEdge mstIfEdge) throws URISyntaxException {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.MST_INFO + "/mstIfEdge/submit";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    try {
      Boolean result = mstInfoService.submitMstIfEdge(mstIfEdge);
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(result, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /*add FNSI-改修内容5204 任 start*/
  @GetMapping("/getMstMedicineUnit")
  public ResponseEntity<List<MstMedicine>> getMstMedicineUnit(
    MstMedicine params,
    @RequestParam(value = "page", required = false) Integer offset,
    @RequestParam(value = "per_page", required = false) Integer limit
  ) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstMedicine> page = mstInfoService.findMstMedicineUnit(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstMedicine/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }
  @GetMapping("/getMstMedicineMixUnit")
  public ResponseEntity<List<MstMedicineMix>> getMstMedicineMixUnit(
    MstMedicineMix params,
    @RequestParam(value = "page", required = false) Integer offset,
    @RequestParam(value = "per_page", required = false) Integer limit
  ) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstMedicineMix> page = mstInfoService.findMstMedicineMixUnit(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstMedicineMix/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }
  @GetMapping("/getMstEquipmentUnit")
  public ResponseEntity<List<MstEquipment>> getMstEquipmentUnit(
    MstEquipment params,
    @RequestParam(value = "page", required = false) Integer offset,
    @RequestParam(value = "per_page", required = false) Integer limit
  ) throws URISyntaxException {
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstEquipment> page = mstInfoService.findMstEquipmentUnit(pageable, params);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.MST_INFO + "/mstEquipment/", offset, limit);
    return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
  }
  /*add FNSI-改修内容5204 任 end*/
  //add FutreNetWeb+SI課題管理 NO.5323 劉全航 start
  @GetMapping("/getMstMedicineTypeByClass")
  public ResponseEntity<MstMedicineClass> getMstMedicineTypeByClass(@RequestParam(name = "classCd") Integer classCd){
    MstMedicineClass mstMedicineClass = mstMedicineClassDao.selectByCd(classCd);
    return new ResponseEntity<>(mstMedicineClass,HttpStatus.OK);
  }

  @GetMapping("/getMstEquipmentTypeByClass")
  public ResponseEntity<MstEquipmentClass> getMstEquipmentTypeByClass(@RequestParam(name="classCd")Integer classCd){
    MstEquipmentClass mstEquipmentClass = mstEquipmentClassDao.selectByCd(classCd);
    return new ResponseEntity<>(mstEquipmentClass,HttpStatus.OK);
  }
  //add FutreNetWeb+SI課題管理 NO.5323 劉全航 end
  //add #9009 ベッドマスタにおいて治療中のベッドに対して編集可能 張 start
  @GetMapping("/selectBedListByFacilityCd/{facilityCd}")
  public ResponseEntity<List<Long>> selectBedListByFacilityCd (@PathVariable String facilityCd){
    return new ResponseEntity<>(mstInfoService.selectBedListByFacilityCd(facilityCd).stream().map(item->item.getBedCd()).collect(Collectors.toList()),HttpStatus.OK);
  }
  //add #9009 ベッドマスタにおいて治療中のベッドに対して編集可能 張 end

  //add #10236 api要求をマージして、ブラウザ要求スレッドのスタックをできるだけ減らす shiyw start
  /**
   * Master情報一括取得, サポートされているマスター See {@link MstInfoRequest.ReqMstName}
   * @param mstInfoRequest
   * @return
   */
  @GetMapping("/getMstInfo")
  public ResponseEntity<Map> getMstInfo(MstInfoRequest mstInfoRequest) {
    Map<String, Object> response = mstInfoService.getMstInfo(mstInfoRequest);
    return new ResponseEntity<>(response, HttpStatus.OK);
  }
  //add #10236 api要求をマージして、ブラウザ要求スレッドのスタックをできるだけ減らす shiyw end

  /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
  @PostMapping("/getMstInfoByOrdNo")
  public ResponseEntity<Map> getMstInfoByOrdNo(@RequestBody List<Long> ordNoList) {
    Map<String, Object> response = mstInfoService.getMstInfoByOrdNo(ordNoList);
    return new ResponseEntity<>(response, HttpStatus.OK);
  }
  /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */

  /**
   * 削除されていない治療状況レイアウト表示項目マスタを全て取得する
   * @return 治療状況レイアウト表示項目マスタリスト
   */
  @GetMapping("/mstTreatmentStatusDispItem")
  public ResponseEntity<List<MstTreatmentStatusDispItem>> getAllMstTreatmentStatusDispItem() {
    return new ResponseEntity<List<MstTreatmentStatusDispItem>>(mstInfoService.getMstTreatmentStatusDispItemAll(), HttpStatus.OK);
  }
  //add #12462 患者情報共有- 患者カレンダー zrx start
  @GetMapping("/getShrMstInfoByPatId")
  public ResponseEntity<Map> getShrMstInfoByPatId(MstInfoRequest mstInfoRequest) {
    Map<String, Object> response = mstInfoService.getShrMstInfoByPatId(mstInfoRequest);
    return new ResponseEntity<>(response, HttpStatus.OK);
  }
  //add #12462 2026-04-23 共有施設マスタ取得対応 --end
}
