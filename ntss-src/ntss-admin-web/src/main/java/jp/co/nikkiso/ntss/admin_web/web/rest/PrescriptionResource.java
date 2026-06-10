package jp.co.nikkiso.ntss.admin_web.web.rest;


import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import javax.validation.Valid;

import jp.co.nikkiso.ntss.admin_web.request.patientCapture.JournalCreateRequestPayload;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.JournalService;
import jp.co.nikkiso.ntss.admin_web.service.journal.JournalCreatePayloadService;
import jp.co.nikkiso.ntss.core.dao.OrdPrescriptionDao;
import org.apache.commons.collections.CollectionUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.util.ObjectUtils;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Authority;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.request.prescription.MedicineSelectionRequest;
import jp.co.nikkiso.ntss.admin_web.request.prescription.OrdPrescriptionDTO;
import jp.co.nikkiso.ntss.admin_web.request.prescription.OrdPrescriptionRequest;
import jp.co.nikkiso.ntss.admin_web.request.prescription.PrescriptionListRequest;
import jp.co.nikkiso.ntss.admin_web.response.prescription.PrescriptionDetailsResponse;
import jp.co.nikkiso.ntss.admin_web.service.MstInfoService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.patInsurance.PatInsuranceService;
import jp.co.nikkiso.ntss.admin_web.service.prescription.PrescriptionService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.entity.OrdPersonalPrescription;
import jp.co.nikkiso.ntss.core.entity.OrdPrescription;
import jp.co.nikkiso.ntss.core.entity.custom.InsuInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PatInsuranceName;
import jp.co.nikkiso.ntss.core.entity.custom.PrescriptionCount;
import jp.co.nikkiso.ntss.core.entity.custom.PrescriptionList;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * 処方箋画面のResourceクラス
 */
@RestController
@RequestMapping(Uri.PRESCRIPTION)
public class PrescriptionResource {

  @Autowired
  PrescriptionService service;

  @Autowired
  MstInfoService mstInfoService;

  @Autowired
  PatInsuranceService patInsuranceService;
  //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
  @Autowired
  private LogService logService;
  //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  // add #10553 処方連携 piao start
  @Autowired
  OrdPrescriptionDao ordPrescriptionDao;

  @Autowired
  private JournalCreatePayloadService journalCreatePayloadService;

  @Autowired
  private JournalService journalService;
  // add #10553 処方連携 piao end

  /**
   * 薬剤選択で処方検索.
   *
   * @param request 処方薬剤選択条件
   * @return 処方薬剤選択条件
   */
  @PostMapping("/search_medicine_selection")
  public ResponseEntity<?> searchMedicineSelection(@Valid @RequestBody MedicineSelectionRequest request) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.PRESCRIPTION + "/search_medicine_selection";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(service.searchMedicineSelection(request), HttpStatus.OK);
  }

  /**
   * 処方歴検索.
   *
   * @param request 処方歴検索.
   * @return 処方歴
   */
  //mod #12666 #12667 securify】SQLインジェクション(High) まとめ zrx start
  @PostMapping("/search_ord_prescription")
  public ResponseEntity<?> searchOrdPrescription(@Valid @RequestBody OrdPrescriptionRequest request,
                                                 BindingResult validationResult) {
    if (validationResult.hasErrors()) {
      return new ResponseEntity<>(validationResult.getAllErrors().get(0).getDefaultMessage(), HttpStatus.BAD_REQUEST);
    }
    //mod #12666 #12667 securify】SQLインジェクション(High) まとめ zrx end

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.PRESCRIPTION + "/search_ord_prescription";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(service.searchOrdPrescription(request), HttpStatus.OK);
  }

  /**
   * 用法・用語マスタ取得する.
   *
   * @param facilityCd リスト種別
   * @param listClass  施設コード
   * @return 処方
   */
  @GetMapping("/take_medicine/{facilityCd}")
  public ResponseEntity<?> getTakeMedicine(@PathVariable(name = "facilityCd", required = true) String facilityCd,
                                           @RequestParam(name = "listClass", required = false) String listClass) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.PRESCRIPTION + "/take_medicine";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      listClass);
    // wp アプリケーションログの適正化 Add End

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
      listClass);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(mstInfoService.getTakeMedicine(listClass, facilityCd), HttpStatus.OK);
  }

  /**
   * 保存.
   *
   * @param input
   * @return
   */
  @PostMapping("/save")
  // mod #10553 処方連携 piao start
  public ResponseEntity<?> save(@RequestBody OrdPrescriptionDTO input, @AuthenticationPrincipal NtssUser user) {
  // mod #10553 処方連携 piao end

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.PRESCRIPTION + "/save";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    // mod #10553 処方連携 piao start
//    return new ResponseEntity<>(service.save(input), HttpStatus.OK);
    OrdPrescriptionDTO ordPrescriptionDTO = service.save(input);
    List<OrdPrescription> ordRps = new ArrayList<>();
    if(ordPrescriptionDTO !=null && ordPrescriptionDTO.getOrdPrescription() != null){
      ordRps.add(ordPrescriptionDTO.getOrdPrescription());
    }
    if(ordRps.size() > 0){
      String facilityCd = ordRps.get(0).getFacilityCd();
      // 連携関連呼出
      try {
        String actionMode = "ORD_PRESCRIPTION_SAVE";
        List<Long> patIdList = new ArrayList<>();
        patIdList.addAll(ordRps.stream().map(o -> o.getPatId()).collect(Collectors.toList()));
        List<JournalCreateRequestPayload> journalList = journalCreatePayloadService.createJournalPayloadForOrdPrescription(facilityCd, ordRps, null, patIdList, user.getUserId(), actionMode);
        if (!CollectionUtils.isEmpty(journalList)) {
          journalService.callCreateJournalForCtrNo(journalList);
        }
      } catch (Exception e) {
        //エラー
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("連携関連呼出 " + e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_SCHEDULE_LIST, LoggingConstant.SERVICE_NAME.FNSI, null);
      }
    }
    return new ResponseEntity<>(ordPrescriptionDTO, HttpStatus.OK);
    // mod #10553 処方連携 piao end
  }

  /**
   * 削除.
   *
   * @param ordPrescriptionNo 処方オーダー番号
   * @return
   */
  @DeleteMapping("/{ordPrescriptionNo}")
  @PreAuthorize("hasAuthority('" + Authority.DEL_PRESCRIPTION + "')")
  // mod #10553 処方連携 piao start
  public ResponseEntity<?> delete(@PathVariable(name = "ordPrescriptionNo", required = true) Long ordPrescriptionNo, @AuthenticationPrincipal NtssUser user) {
  // mod #10553 処方連携 piao end

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.PRESCRIPTION;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      ordPrescriptionNo);
    // wp アプリケーションログの適正化 Add End

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      ordPrescriptionNo);
    // wp アプリケーションログの適正化 Add End
    // mod #10553 処方連携 piao start
//    return new ResponseEntity<>(service.delete(ordPrescriptionNo), HttpStatus.OK);
    List<OrdPrescription> ordRps = service.delete(ordPrescriptionNo);
    int ret = 0;
    if(ordRps !=null){
      ret = ordRps.size();
    }
    if(ret > 0){
      String facilityCd = ordRps.get(0).getFacilityCd();
      // 連携関連呼出
      try {
        String actionMode = "ORD_PRESCRIPTION_DELETE";
        List<Long> patIdList = new ArrayList<>();
        patIdList.addAll(ordRps.stream().map(o -> o.getPatId()).collect(Collectors.toList()));
        List<JournalCreateRequestPayload> journalList = journalCreatePayloadService.createJournalPayloadForOrdPrescription(facilityCd, ordRps, null, patIdList, user.getUserId(), actionMode);
        if (!CollectionUtils.isEmpty(journalList)) {
          journalService.callCreateJournalForCtrNo(journalList);
        }
      } catch (Exception e) {
        //エラー
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("連携関連呼出 " + e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_SCHEDULE_LIST, LoggingConstant.SERVICE_NAME.FNSI, null);
      }
    }
    return new ResponseEntity<>(ret, HttpStatus.OK);
    // mod #10553 処方連携 piao end
  }

  /**
   * 処方の詳細.
   *
   * @param ordPrescriptionNo
   * @return 処方の詳細
   */
  @GetMapping("/prescription_details")
  public ResponseEntity<?> getPrescriptionDetails(@RequestParam Long ordPrescriptionNo) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.PRESCRIPTION + "/prescription_details";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      ordPrescriptionNo);
    // wp アプリケーションログの適正化 Add End
    OrdPrescription ordPrescription = service.selectOrdPrescriptionDetails(ordPrescriptionNo);
    OrdPersonalPrescription ordPersonalPrescription = service
      .selectOrdPersonalPrescriptionDetails(ordPrescriptionNo);
    PrescriptionDetailsResponse response = new PrescriptionDetailsResponse(ordPrescription,
      ordPersonalPrescription);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      ordPrescriptionNo);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * 患者の保険名を取得する.
   *
   * @param patId      患者ID
   * @param facilityCd 施設コード
   * @return 患者保険名のリスト
   */
  @GetMapping("/pat_insu_names")
  public ResponseEntity<List<PatInsuranceName>> getListPatInsuranceNameByIdAndCd(
    @RequestParam(value = "patId") Long patId,
    @RequestParam(value = "facilityCd") String facilityCd,
    @RequestParam(value = "ordPrescriptionNo", required = false) Long ordPrescriptionNo) {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.PRESCRIPTION + "/pat_insu_names";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      Arrays.asList(patId, ordPrescriptionNo));
    // wp アプリケーションログの適正化 Add End


    if (ObjectUtils.isEmpty(ordPrescriptionNo)) {
      ordPrescriptionNo = null;
    }

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
      Arrays.asList(patId, ordPrescriptionNo));
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<List<PatInsuranceName>>(patInsuranceService.getListPatInsuranceNameByIdAndCd(patId, facilityCd, ordPrescriptionNo), HttpStatus.OK);
  }

  /**
   * 患者の保険情報を取得します。
   *
   * @param insuranceCd 保険コード
   * @return 患者の保険情報
   */
  @GetMapping("/insu_info")
  public ResponseEntity<InsuInfo> getInsuInfoByCd(@RequestParam(value = "insuranceCd") Long insuranceCd) {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.PRESCRIPTION + "/insu_info";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      insuranceCd);
    // wp アプリケーションログの適正化 Add End

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      insuranceCd);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<InsuInfo>(patInsuranceService.getInsuInfoByCd(insuranceCd), HttpStatus.OK);
  }

  // add FNSI-処方を追加 姜  start
// mod #9738 患者経過総合ビューアで検査依頼、一般撮影検査依頼、招待状、処方、患者イベントのデータが正常に表示されない zy start
//  @PostMapping("/prescriptionDateList/{patId}/{facilityCd}")
//  public ResponseEntity<List<PrescriptionCount>> getPrescriptionList(@PathVariable String patId,
//                                                                     @PathVariable String facilityCd) {
  /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
  // @PostMapping("/prescriptionDateList/{patId}/{facilityCd}/{startDate}/{endDate}")
  @PostMapping("/prescriptionDateList/{patId}/{facilityCd}/{startDate}/{endDate}/{patShareMode}")
  public ResponseEntity<List<PrescriptionCount>> getPrescriptionList(@PathVariable String patId,
                                                                     @PathVariable String facilityCd,@PathVariable String startDate,@PathVariable String endDate,
                                                                     @PathVariable Integer patShareMode) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.PRESCRIPTION + "/prescriptionDateList";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      patId);
    // wp アプリケーションログの適正化 Add End


//    List<PrescriptionCount> list = service.getPrescriptionCount(patId, facilityCd);
    List<PrescriptionCount> list = service.getPrescriptionCount(patId, facilityCd,startDate,endDate, patShareMode);
    // mod #9738 患者経過総合ビューアで検査依頼、一般撮影検査依頼、招待状、処方、患者イベントのデータが正常に表示されない zy end
    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
      patId);
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(list, HttpStatus.OK);

  }
  /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --end */
// add FNSI-処方を追加 姜  end
  // add FNSI-改修内容 イベント一覧の日付直下に、施設名を表示する dou start

  /**
   * 施設名を取得。
   *
   * @param facilityCd 施設コード
   * @return 施設名
   */
  @GetMapping("/facility_name")
  public ResponseEntity<String> getFacilityNameByCd(@RequestParam(value = "facilityCd") String facilityCd) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.PRESCRIPTION + "/facility_name";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      null);
    // wp アプリケーションログの適正化 Add End

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
      null);
    return new ResponseEntity<>(service.getFacilityNameByCd(facilityCd), HttpStatus.OK);
  }

  /**
   * 処方対処件数を取得
   *
   * @return 一括交付済み変更
   */
  @PostMapping("/prescription-count")
  public int getPatPrescriptionCount(@RequestBody PrescriptionListRequest bodyData) {
    String mappingUrl = Uri.PRESCRIPTION + "/prescription-count";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null, null);

    if (null != bodyData.getPatIdList()) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("patIdList:" + bodyData.getPatIdList().toString());
      logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
    }
    int prescriptionCount = service.getPatPrescriptionCount(bodyData.getPatIdList(), bodyData.getIssueDate(), bodyData.getFacilityCd());
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null, null);
    return prescriptionCount;
  }

  /**
   * 交付状態変更対象を取得
   *
   * @return 一括交付済み変更
   */
  @PostMapping("/ord-prescription-no-list")
  public ResponseEntity<List<PrescriptionList>> getOrdPrescriptionNoList(
    @RequestBody PrescriptionListRequest bodyData) {

    String mappingUrl = Uri.PRESCRIPTION + "/ord-prescription-no-list";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);

    if (null != bodyData.getPatIdList()) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("patIdList:" + bodyData.getPatIdList().toString());
      logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
    }

    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    return new ResponseEntity<List<PrescriptionList>>(service.getOrdPrescriptionNoList(bodyData.getPatIdList(), bodyData.getIssueDate(), bodyData.getFacilityCd()), HttpStatus.OK);
  }

  /**
   * 交付状態変更.
   *
   * @param ordPrescriptionNoList
   * @param insuDrId
   * @param selectedPreDoctor
   * @return
   */
  @PostMapping("/update-issue-state")
  // mod #10553 処方連携 piao start
  public ResponseEntity<Void> updateIssueState(@RequestBody PrescriptionListRequest bodyData, @AuthenticationPrincipal NtssUser user) {
  // mod #10553 処方連携 piao end

    String mappingUrl = Uri.PRESCRIPTION + "/update-issue-state";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null, null);
    try {
      // mod #10553 処方連携 piao starts
      List<OrdPrescription> ordRps = service.updateIssueState(bodyData);
      if(ordRps != null && !ordRps.isEmpty()){
        String facilityCd = ordRps.get(0).getFacilityCd();
        // 連携関連呼出
        try {
          String actionMode = "ORD_PRESCRIPTION_UPDATE_STATE";
          List<Long> patIdList = new ArrayList<>();
          patIdList.addAll(ordRps.stream().map(o -> o.getPatId()).collect(Collectors.toList()));
          List<JournalCreateRequestPayload> journalList = journalCreatePayloadService.createJournalPayloadForOrdPrescription(facilityCd, ordRps, null, patIdList, user.getUserId(), actionMode);
          if (!CollectionUtils.isEmpty(journalList)) {
            journalService.callCreateJournalForCtrNo(journalList);
          }
        } catch (Exception e) {
          //エラー
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("連携関連呼出 " + e.getMessage());
          logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_SCHEDULE_LIST, LoggingConstant.SERVICE_NAME.FNSI, null);
        }
      }
      // mod #10553 処方連携 piao end

      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null, null);
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 処方一覧検索.
   *
   * @return 処方一覧
   */
  @PostMapping("/prescription-list")
  public ResponseEntity<List<PrescriptionList>> getPrescriptionList(
    @RequestBody PrescriptionListRequest bodyData,@AuthenticationPrincipal NtssUser user) {

    String mappingUrl = Uri.PRESCRIPTION + "/prescription-list";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null, null);

    if (null != bodyData.getPatIdList()) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("patIdList:" + bodyData.getPatIdList().toString());
      logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
    }

    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null, null);
    //mod #12462 患者共有情報 by zrx start
//    return new ResponseEntity<List<PrescriptionList>>(service.getPrescriptionList(bodyData.getPatIdList(), bodyData.getIssueDate(), bodyData.getPrescriptionTypeList()), HttpStatus.OK);
    return new ResponseEntity<List<PrescriptionList>>(service.getPrescriptionList(bodyData.getPatIdList(), bodyData.getIssueDate(),
      bodyData.getPrescriptionTypeList(), bodyData.getPatientShareMode(),user.getFacilityCd()), HttpStatus.OK);
    //mod #12462 患者共有情報 by zrx end
  }
  // add FNSI-改修内容イベント一覧の日付直下に、施設名を表示する dou end

  /**
   * 一括処理オーダー.
   *
   * @return
   */
  @PostMapping("/copy-prescription")
  // mod #10553 処方連携 piao start
  ResponseEntity<Void> copyPrescription(@RequestBody PrescriptionListRequest bodyData, @AuthenticationPrincipal NtssUser user
    ) {
  // mod #10553 処方連携 piao end
    String mappingUrl = Uri.PRESCRIPTION + "/copy-prescription";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    try {
      // mod #10553 処方連携 piao start
      List<OrdPrescription> ordRps = service.copyPrescription(bodyData);
      if(ordRps != null && !ordRps.isEmpty()){
        String facilityCd = ordRps.get(0).getFacilityCd();
        // 連携関連呼出
        try {
          String actionMode = "ORD_PRESCRIPTION_COPY";
          List<Long> patIdList = new ArrayList<>();
          patIdList.addAll(ordRps.stream().map(o -> o.getPatId()).collect(Collectors.toList()));
          List<JournalCreateRequestPayload> journalList = journalCreatePayloadService.createJournalPayloadForOrdPrescription(facilityCd, ordRps, null, patIdList, user.getUserId(), actionMode);
          if (!CollectionUtils.isEmpty(journalList)) {
            journalService.callCreateJournalForCtrNo(journalList);
          }
        } catch (Exception e) {
          //エラー
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("連携関連呼出 " + e.getMessage());
          logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_SCHEDULE_LIST, LoggingConstant.SERVICE_NAME.FNSI, null);
        }
      }
      // mod #10553 処方連携 piao end

      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null, null);
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
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
}
