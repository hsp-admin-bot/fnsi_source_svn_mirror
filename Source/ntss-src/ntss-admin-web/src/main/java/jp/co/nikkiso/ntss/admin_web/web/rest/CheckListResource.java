package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.core.entity.MstChecklist;
import jp.co.nikkiso.ntss.core.entity.MstDialyzer;
import jp.co.nikkiso.ntss.core.entity.MstEquipment;
import jp.co.nikkiso.ntss.core.entity.MstMedicine;
import jp.co.nikkiso.ntss.core.entity.OrdCheckListParams;
import jp.co.nikkiso.ntss.core.entity.OrdChecklist;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.response.checkList.CheckListScheduleResponse;
import jp.co.nikkiso.ntss.admin_web.response.checkList.ChecklistUpdateResponse;
import jp.co.nikkiso.ntss.admin_web.response.checkList.MediUpdateResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.checkList.CheckListService;
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.WebSocketNotifyService;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import lombok.extern.slf4j.Slf4j;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;

import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@RestController
@Slf4j
@RequestMapping(Uri.CHECK_LIST)
public class CheckListResource {

  @Autowired
  WebSocketNotifyService sendWsMsg;
  @Autowired
  CheckListService checkListService;
  @Autowired
  OrdMainDao    ordMainDao;
	@Autowired
	LogService logService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  // add FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 start
  /**
   * ord_main情報を取得「治療中」
   * @param ntssUser, nextPat
   * @return
   */
  @GetMapping("ordermainchiryouchuu/{facilityCd}/{nextPat}")
  public ResponseEntity<?> getOrdMainChiryouchuu(
    @AuthenticationPrincipal NtssUser ntssUser,
    @PathVariable Short nextPat) {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.CHECK_LIST + "/ordermainchiryouchuu";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    // NOTE: ord_mainをfacilityCdとnextPat(次患者)で取得する

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(checkListService.getOrdMainChiryouchuu(ntssUser.getFacilityCd(), nextPat), HttpStatus.OK);


  }

  /**
   * ord_main情報を取得「指定日」
   * @param facilityCd, treatDate
   * @return
   */
  @GetMapping("ordermainshiteibi/{facilityCd}/{treatDate}")
  public ResponseEntity<?> getOrdMainShiteibi(
    @PathVariable String facilityCd,
    @PathVariable String treatDate,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    @AuthenticationPrincipal NtssUser ntssUser
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if (!hasFacilityAccess(ntssUser, facilityCd)) {
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.CHECK_LIST + "/ordermainshiteibi";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      treatDate);
    // wp アプリケーションログの適正化 Add End

    // NOTE: ord_mainをfacilityCdとtreatDateで取得する

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
      treatDate);
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(checkListService.getOrdMainShiteibi(facilityCd, treatDate), HttpStatus.OK);
  }

  /**
   * ord_checklist進度情報を取得「条件送信前」
   * @param orderNo オーダー番号
   * @param listCd リストコード
   * @return
   */
  @GetMapping("orderchecklistzen/{orderNo}/{listCd}")
  public ResponseEntity<?> getOrdCheckListZen(
    @PathVariable Long orderNo,
    @PathVariable Short listCd,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    @AuthenticationPrincipal NtssUser ntssUser
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
  ) throws IOException {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    OrdMain ordMain = ordMainDao.selectByOrdNo(orderNo);
    if (ordMain != null && !hasFacilityAccess(ntssUser, ordMain.getFacilityCd())) {
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + ordMain.getFacilityCd() + " " + "orderNo=" + orderNo + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.CHECK_LIST + "/orderchecklistzen";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(orderNo, listCd));
    // wp アプリケーションログの適正化 Add End

    // NOTE: ord_checklistをorderNoで取得する

    if (listCd == 0) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(orderNo, listCd));
      // wp アプリケーションログの適正化 Add End
      // 進度情報
      return new ResponseEntity<>(checkListService.getOrdCheckListShindoZen(orderNo), HttpStatus.OK);
    } else {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(orderNo, listCd));
      // wp アプリケーションログの適正化 Add End
      // 一覧情報
      return new ResponseEntity<>(checkListService.getOrdCheckListIchiranZen(orderNo, listCd), HttpStatus.OK);
    }
  }

  /**
   * ord_checklist進度情報を取得「条件送信以降」
   * @param orderNo オーダー番号
   * @param listCd リストコード
   * @return
   */
  @GetMapping("orderchecklisticou/{orderNo}/{listCd}")
  public ResponseEntity<?> getOrdCheckListIcou(
    @PathVariable Long orderNo,
    @PathVariable Short listCd,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    @AuthenticationPrincipal NtssUser ntssUser
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    OrdMain ordMain = ordMainDao.selectByOrdNo(orderNo);
    if (ordMain != null && !hasFacilityAccess(ntssUser, ordMain.getFacilityCd())) {
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + ordMain.getFacilityCd() + " " + "orderNo=" + orderNo + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
    // NOTE: ord_checklistをorderNoで取得する

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.CHECK_LIST + "/orderchecklisticou";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(orderNo, listCd));
    // wp アプリケーションログの適正化 Add End

    if (listCd == 0) {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(orderNo, listCd));
      // wp アプリケーションログの適正化 Add End
      // 進度情報
      return new ResponseEntity<>(checkListService.getOrdCheckListShindoIcou(orderNo), HttpStatus.OK);
    } else {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(orderNo, listCd));
      // wp アプリケーションログの適正化 Add End
      // 一覧情報
      return new ResponseEntity<>(checkListService.getOrdCheckListIchiranIcou(orderNo, listCd), HttpStatus.OK);
    }
  }
  // add FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 end

  /**
   * ord_main取得
   * @param ntssUser, nextPat
   * @return
   */
  @GetMapping("ordertreaement/{facilityCd}/{nextPat}")
  public ResponseEntity<?> getOrderByTreatDate(
      @AuthenticationPrincipal NtssUser ntssUser,
      @PathVariable Short nextPat) {


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.CHECK_LIST + "/ordertreaement";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      nextPat);
    // wp アプリケーションログの適正化 Add End

    // NOTE: ord_mainをfacilityCdとnextPat(次患者)で取得する
    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
      nextPat);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(checkListService.getOrderTreatment(ntssUser.getFacilityCd(), nextPat), HttpStatus.OK);
  }

  /**
   * ord_main取得
   * @param facilityCd, treatDate
   * @return
   */
  @GetMapping("order/{facilityCd}/{treatDate}")
  public ResponseEntity<?> getOrderByTreatDate(
      @PathVariable String facilityCd,
      @PathVariable String treatDate,
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if (!hasFacilityAccess(ntssUser, facilityCd)) {
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.CHECK_LIST + "/order";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      treatDate);
    // wp アプリケーションログの適正化 Add End
    // NOTE: ord_mainをfacilityCdとtreatDateで取得する

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
      treatDate);
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(checkListService.getOrderByTreatDate(facilityCd, treatDate), HttpStatus.OK);
  }

  /**
   * ord_main取得
   * @param orderNo
   * @return
   */
  @GetMapping("getorder/{orderNo}")
  public ResponseEntity<?> getOrderByOrderNo(
      @PathVariable Long orderNo,
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    OrdMain ordMain = ordMainDao.selectByOrdNo(orderNo);
    if (ordMain != null && !hasFacilityAccess(ntssUser, ordMain.getFacilityCd())) {
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + ordMain.getFacilityCd() + " " + "orderNo=" + orderNo + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.CHECK_LIST + "/order";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      orderNo);
    // wp アプリケーションログの適正化 Add End

    CheckListScheduleResponse res = new CheckListScheduleResponse();
    // NOTE: ord_mainをorderNoで取得する
    try {
      res = checkListService.getOrderByOrderNo(orderNo);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        orderNo);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);

    } catch (Exception e) {
//    	EventLogMessage eventLogMessage = new EventLogMessage();
//    	eventLogMessage.setLogMessage(e.getMessage());
//    	logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_CHECK_LIST, SERVICE_NAME.FNSI,
//    	null);
      //res.errorMessage = e.getMessage();
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * チェックリスト更新間隔取得
   * @param ntssUser チェックリストコード
   * @return
   */
  @GetMapping("get-reload-interval")
  public ResponseEntity<?> getIntervalTime(
      @AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.CHECK_LIST + "/get-reload-interval";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    // NOTE: ord_mainをfacilityCdとtreatDateで取得する

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(checkListService.getAutoReloadInterval(ntssUser.getFacilityCd()), HttpStatus.OK);
  }

  /**
   * チェックリストマスタ取得
   * @param checklistCd チェックリストコード
   * @return
   */
  @GetMapping("getmstchecklist/{checklistCd}")
  public ResponseEntity<?> getMstChecklistByChecklistCd(
      @PathVariable Long checklistCd,
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    MstChecklist mstChecklist = checkListService.getMstChecklistByChecklistCd(checklistCd);
    if (mstChecklist != null && !hasFacilityAccess(ntssUser, mstChecklist.getFacilityCd())) {
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + mstChecklist.getFacilityCd() + " " + "checklistCd=" + checklistCd + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.CHECK_LIST + "/getmstchecklist";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      checklistCd);
    // wp アプリケーションログの適正化 Add End
    // NOTE: ord_mainをfacilityCdとtreatDateで取得する

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
      checklistCd);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(checkListService.getMstChecklistByChecklistCd(checklistCd), HttpStatus.OK);
  }

  /**
   * ダイアライザリスト取得
   * @param dialyzerList ダイアライザコードリスト
   * @return
   */
  @GetMapping("getdialyzer/{dialyzerList}")
  public ResponseEntity<?> getMstDialyzerList(
      @PathVariable List<Integer> dialyzerList,
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    List<MstDialyzer> mstDialyzerList = checkListService.getDialyzerList(dialyzerList);
    for (MstDialyzer mstDialyzer : mstDialyzerList) {
      if (mstDialyzer != null && !hasFacilityAccess(ntssUser, mstDialyzer.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + mstDialyzer.getFacilityCd() + " " + "dialyzerList=" + dialyzerList + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.CHECK_LIST + "/getdialyzer";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      dialyzerList);
    // wp アプリケーションログの適正化 Add End
    // NOTE: ord_mainをfacilityCdとtreatDateで取得する

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
      dialyzerList);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(checkListService.getDialyzerList(dialyzerList), HttpStatus.OK);
  }

  /**
   * 薬剤リスト取得
   * @param medicineList 薬剤コードリスト
   * @return
   */
  @GetMapping("getmedicine/{medicineList}")
  public ResponseEntity<?> getMstMedicineList(
      @PathVariable List<Integer> medicineList,
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    List<MstMedicine> medicineList1 = checkListService.getMedicineList(medicineList);
    for (MstMedicine mstDialyzer : medicineList1) {
      if (mstDialyzer != null && !hasFacilityAccess(ntssUser, mstDialyzer.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + mstDialyzer.getFacilityCd() + " " + "medicineList=" + medicineList + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.CHECK_LIST + "/getmedicine";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      medicineList);
    // wp アプリケーションログの適正化 Add End
    // NOTE: ord_mainをfacilityCdとtreatDateで取得する

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
      medicineList);
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(checkListService.getMedicineList(medicineList), HttpStatus.OK);
  }

  /**
   * 調整薬剤リスト取得
   * @param medicineMixCdList 調整薬剤コードリスト
   * @return
   */
  @GetMapping("get-medicine-mix/{medicineMixCdList}")
  public ResponseEntity<?> getMstModifierList(
      @PathVariable List<Integer> medicineMixCdList,
      @AuthenticationPrincipal NtssUser ntssUser){

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.CHECK_LIST + "/get-medicine-mix";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      medicineMixCdList);
    // wp アプリケーションログの適正化 Add End
    // NOTE: ord_mainをfacilityCdとtreatDateで取得する

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
      medicineMixCdList);
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(checkListService.getMedicineMixList(ntssUser.getFacilityCd(), medicineMixCdList), HttpStatus.OK);
  }

  /**
   * 医療材料リスト取得
   * @param equipList  医療材料コードリスト
   * @return
   */
  @GetMapping("getequip/{equipList}")
  public ResponseEntity<?> getMstEquipList(
      @PathVariable List<Integer> equipList,
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    List<MstEquipment> mstDialyzerList = checkListService.getEquipList(equipList);
    for (MstEquipment mstDialyzer : mstDialyzerList) {
      if (mstDialyzer != null && !hasFacilityAccess(ntssUser, mstDialyzer.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + mstDialyzer.getFacilityCd() + " " + "equipList=" + equipList + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.CHECK_LIST + "/getequip";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      equipList);
    // wp アプリケーションログの適正化 Add End
    // NOTE: ord_mainをfacilityCdとtreatDateで取得する

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
      equipList);
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(checkListService.getEquipList(equipList), HttpStatus.OK);
  }

  /**
   * ord_checklist取得
   * @param orderNo オーダー番号
   * @return
   */
  @GetMapping("getorderchecklist-ordno/{orderNo}")
  public ResponseEntity<?> getOrdCheckListByListCd(
      @PathVariable Long orderNo,
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    OrdMain ordMain = ordMainDao.selectByOrdNo(orderNo);
    if (ordMain != null && !hasFacilityAccess(ntssUser, ordMain.getFacilityCd())) {
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + ordMain.getFacilityCd() + " " + "orderNo=" + orderNo + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
    // NOTE: ord_checklistをorderNoで取得する

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.CHECK_LIST + "/getorderchecklist-ordno";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      orderNo);
    // wp アプリケーションログの適正化 Add End
    // NOTE: ord_mainをfacilityCdとtreatDateで取得する

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
      orderNo);
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(checkListService.getOrdCheckListByOrdNo(orderNo), HttpStatus.OK);
  }

  /**
   * ord_checklist取得
   * @param orderNo オーダー番号
   * @param ListCd  リストコード
   * @return
   */
  @GetMapping("getorderchecklist-listcd/{orderNo}/{ListCd}")
  public ResponseEntity<?> getOrdCheckListByListCd(
      @PathVariable Long orderNo,
      @PathVariable Short ListCd,
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    OrdMain ordMain = ordMainDao.selectByOrdNo(orderNo);
    if (ordMain != null && !hasFacilityAccess(ntssUser, ordMain.getFacilityCd())) {
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + ordMain.getFacilityCd() + " " + "orderNo=" + orderNo + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
    // NOTE: ord_checklistをorderNoとlistCdで取得する
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.CHECK_LIST + "/getorderchecklist-listcd";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      orderNo);
    // wp アプリケーションログの適正化 Add End


    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
      orderNo);
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(checkListService.getOrdCheckListByListCd(orderNo, ListCd), HttpStatus.OK);
  }

  /**
   * ord_checklist情報更新
   * @param request
   * @return
   */
  @PostMapping("/update")
  public ResponseEntity<?> ordChecklistUpdate(
      @RequestBody List<OrdChecklist> request,
      @AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.CHECK_LIST + "/update";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      request);
    // wp アプリケーションログの適正化 Add End
    try {
      ChecklistUpdateResponse r = checkListService.ordChecklistUpdate(request, ntssUser.getFacilityCd());

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        request);
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(r, HttpStatus.OK);
    } catch (Exception e) {
//    	EventLogMessage eventLogMessage = new EventLogMessage();
//    	eventLogMessage.setLogMessage(e.getMessage());
//    	logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_CHECK_LIST, SERVICE_NAME.FNSI,
//    	null);
      ChecklistUpdateResponse r = new ChecklistUpdateResponse();
      r.errorMessage = e.getMessage();

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(r, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  // ***** 投与薬剤用 *****
  /**
   * スタッフ一覧情報取得
   * @param facilityCd 施設コード
   * @return
   */
  @GetMapping("getstaff/{facilityCd}")
  public ResponseEntity<?> getMstPersonalUser(
      @PathVariable String facilityCd,
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if (!hasFacilityAccess(ntssUser, facilityCd)) {
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
    // NOTE: ord_mainをorderNoで取得する

    // NOTE: ord_checklistをorderNoとlistCdで取得する
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.CHECK_LIST + "/getorderchecklist-listcd";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      null);
    // wp アプリケーションログの適正化 Add End


    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
      null);
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(checkListService.getMstPersonalUser(facilityCd), HttpStatus.OK);
  }

  /**
   * ord_main rst_medi_info情報更新
   * @param request
   * @return
   */
  @PostMapping("/updatemediinfo")
  public ResponseEntity<?> ordMainMediInfoUpdate(
      @RequestBody OrdMain request,
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    OrdMain ordMain = ordMainDao.selectByOrdNo(request.getOrdNo());
    if (ordMain != null && !hasFacilityAccess(ntssUser, ordMain.getFacilityCd())) {
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + ordMain.getFacilityCd() + " " + "orderNo=" + request.getOrdNo() + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.CHECK_LIST + "/updatemediinfo";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    try {
      MediUpdateResponse r = checkListService.ordMainMediInfoUpdate(request);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(r, HttpStatus.OK);
    } catch (Exception e) {
//    	EventLogMessage eventLogMessage = new EventLogMessage();
//    	eventLogMessage.setLogMessage(e.getMessage());
//    	logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_CHECK_LIST, SERVICE_NAME.FNSI,
//    	null);
      MediUpdateResponse r = new MediUpdateResponse();
      r.errorMessage = e.getMessage();

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(r, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 条件送信時
   * ord_checklist情報作成・更新
   * @param orderNo
   * @return
   */
  @PostMapping("/updateSendCondition/{orderNo}")
  public ResponseEntity<?> createOrdChecklistSendCondition(
      @PathVariable Long orderNo,
      @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    OrdMain ordMain = ordMainDao.selectByOrdNo(orderNo);
    if (ordMain != null && !hasFacilityAccess(ntssUser, ordMain.getFacilityCd())) {
      return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.CHECK_LIST + "/updateSendCondition";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      orderNo);
    // wp アプリケーションログの適正化 Add End

    try {
      ChecklistUpdateResponse r = checkListService.createOrdChecklistSendCondition(ntssUser.getFacilityCd(), orderNo);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        orderNo);
      // wp アプリケーションログの適正化 Add End
      /* add #8535 by zhangruixue 2023-04-27 --start */
      checkListService.indApprovedForStatusMap(orderNo);
      /* add #8535 by zhangruixue 2023-04-27 --end */

      // add#10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 start
      checkListService.indApprovedForContent(orderNo);
      // add#10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 end

      return new ResponseEntity<>(r, HttpStatus.OK);
    } catch (Exception e) {
//    	EventLogMessage eventLogMessage = new EventLogMessage();
//    	eventLogMessage.setLogMessage(e.getMessage());
//    	logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_CHECK_LIST, SERVICE_NAME.FNSI,
//    	null);
      ChecklistUpdateResponse r = new ChecklistUpdateResponse();
      r.errorMessage = e.getMessage();

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(r, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  // add チェックリストマスタ 指示変更、実績変更に伴うチェックリストの反映 孔 start
  /**
   * ord_checklist情報削除
   * @param delChecklist
   * @return
   */
  @PostMapping("/deleteOrdChecklist")
  public ResponseEntity<?> mstChecklistDeleteOrdChecklist(
    @RequestBody List<OrdChecklist> delChecklist,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    @AuthenticationPrincipal NtssUser ntssUser
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if (delChecklist != null && !delChecklist.isEmpty()) {
      for (OrdChecklist ordChecklist : delChecklist) {
        if (ordChecklist != null && !hasFacilityAccess(ntssUser, ordChecklist.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + ordChecklist.getFacilityCd() + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        }
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.CHECK_LIST + "/deleteOrdChecklist";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      delChecklist);
    // wp アプリケーションログの適正化 Add End

    try {
      int r = checkListService.deleteOrdChecklist(delChecklist);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        delChecklist);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(r, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_CHECK_LIST, SERVICE_NAME.FNSI,
        null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  // add チェックリストマスタ 指示変更、実績変更に伴うチェックリストの反映 孔 end

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


  @PostMapping("orderchecklistallinfo")
  public ResponseEntity<?> getOrdCheckListAll(
    @RequestBody List<OrdCheckListParams> ordCheckListParamsList,
    @AuthenticationPrincipal NtssUser ntssUser) throws IOException {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    List<OrdMain> ordMains = ordMainDao.selectByOrdNoList(ordCheckListParamsList.stream().map(OrdCheckListParams::getOrdNo).collect(Collectors.toList()));
    if (ordMains != null && !ordMains.isEmpty()) {
      for (OrdMain ordMain : ordMains) {
        if (ordMain != null && !hasFacilityAccess(ntssUser, ordMain.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + ordMain.getFacilityCd() + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        }
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    List<List<List<Long>>> resultList = new ArrayList<>();

    if (ordCheckListParamsList != null && ordCheckListParamsList.size() > 0) {
      List<OrdCheckListParams> ordCheckListParamsShindoZenList = ordCheckListParamsList.stream().filter(el->el.getRstDialysisState().equals("0")).collect(Collectors.toList());
      List<OrdCheckListParams> ordCheckListParamsShindoIcouList = ordCheckListParamsList.stream().filter(el->!el.getRstDialysisState().equals("0")).collect(Collectors.toList());
      //    modify by xuguojin,bug:5564
      List<List<List<Long>>> resultShindoZenList = checkListService.getOrdCheckListShindoZen(ordCheckListParamsShindoZenList, ntssUser.getFacilityCd());
      List<List<List<Long>>> resultShindoIcouList = checkListService.getOrdCheckListShindoIcou(ordCheckListParamsShindoIcouList);

      //FNSI-修正 #6079 チェックリスト画面が開けない対応、xugj add start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "orderchecklistallinfo", String.valueOf(ordCheckListParamsList.size()), String.valueOf(resultShindoZenList.size()), String.valueOf(resultShindoIcouList.size()),
        null);
      //FNSI-修正 #6079 チェックリスト画面が開けない対応、xugj add end
      int i = 0;
      int j = 0;
      for(OrdCheckListParams ordCheckListParams : ordCheckListParamsList) {
        if ("0".equals(ordCheckListParams.getRstDialysisState())) {
          resultList.add(resultShindoZenList.get(i));
          i++;
        } else {
          resultList.add(resultShindoIcouList.get(j));
          j++;
        }
      }
    }
    //    modify by xuguojin,bug:5564
    return new ResponseEntity<>(resultList, HttpStatus.OK);
  }

  private boolean hasFacilityAccess(NtssUser ntssUser, String facilityCd) {
    if (ntssUser == null) {
      return false;
    }
    if (ntssUser.isNkkAdminUser()) {
      return true;
    }
    return facilityCd != null && !facilityCd.isEmpty() && facilityCd.equals(ntssUser.getFacilityCd());
  }
}
