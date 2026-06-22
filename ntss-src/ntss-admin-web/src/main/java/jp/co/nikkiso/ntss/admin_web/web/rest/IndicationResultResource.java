package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.indicationResult.IndicationResultService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.core.dao.MstExamSetDao;
import jp.co.nikkiso.ntss.core.entity.IndicationResult;
import jp.co.nikkiso.ntss.core.entity.ForecastInforResult;
import jp.co.nikkiso.ntss.core.entity.MstExamSet;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;

import java.util.Arrays;
import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;


/**
 * 予実リスト画面のResourceクラス.
 */
@RestController
@Slf4j
@RequestMapping(AdminWebConstant.Uri.INDICATION_RESULT)
public class IndicationResultResource {

  /**
   * 予実リストService.
   */
  @Autowired
  private IndicationResultService indicationResultService;
  @Autowired
	LogService logService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End
  // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
  @Autowired
  MstExamSetDao mstExamSetDao;
  // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

  /**
   * 予実リスト取得.
   *
   * @param patId 患者ID
   * @param ntssUser NTSS認証ユーザ
   * @return 予実リストデータのResponse
   */
  @GetMapping("/{pat_id}/list")
  public ResponseEntity<?> getList(
    @PathVariable(name = "pat_id", required = true) Long patId,
    @RequestParam(name = "treat_date_from", required = false) String treatDateFrom,
    @RequestParam(name = "treat_date_to", required = false) String treatDateTo,
    @AuthenticationPrincipal NtssUser ntssUser) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage( "REST request to get indication result list : "+ patId);
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_INDICATION, SERVICE_NAME.FNSI,
    null);
    // 予実リストの取得
    List<IndicationResult> response = indicationResultService.getList(patId, treatDateFrom, treatDateTo, ntssUser.getFacilityCd());

    // レスポンス生成
    return new ResponseEntity<>(response, HttpStatus.OK);
  }
  // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start
  /**
   * 予実リスト取得(患者イベント)
   *
   * @param treatDateFrom 治療日(From)
   * @param treatDateTo 治療日(To)
   * @param patId 患者ID
   * @return 予実リスト(患者イベント)データのResponse
   */
  @GetMapping("/pat_event/list")
  public ResponseEntity<?> getPatientEventResultList(
    @RequestParam(name = "treat_date_from", required = false) String treatDateFrom,
    @RequestParam(name = "treat_date_to", required = false) String treatDateTo,
    @RequestParam(name = "pat_id", required = true) Long patId,
    @AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = AdminWebConstant.Uri.INDICATION_RESULT + "/pat_event/list";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_INDICATION, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(treatDateFrom, treatDateTo,patId));
    // wp アプリケーションログの適正化 Add End

    // 予実リストの取得(患者イベント)
    List<ForecastInforResult> response = indicationResultService.getList(treatDateFrom, treatDateTo,
      patId, ntssUser.getFacilityCd(), 1);;

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_INDICATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(treatDateFrom, treatDateTo,patId));
    // wp アプリケーションログの適正化 Add End
    // レスポンス生成
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * 検査セットIDで、検査項目取得
   *
   * @param examSetCd 検査セットID
   * @return チェック項目数
   */
  @GetMapping("/{examSetCd}")
  public ResponseEntity<?> getObtainedInspectionItems(
    @PathVariable List<String> examSetCd,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    @AuthenticationPrincipal NtssUser ntssUser
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    // 与患者共有冲突，暂时注释掉
    /*if(!ntssUser.isNkkAdminUser()) {
      for (String examSetCdValue : examSetCd) {
        MstExamSet mstExamSet = mstExamSetDao.selectExamSetByCd(Long.valueOf(examSetCdValue));
        String facilityCd = mstExamSet.getFacilityCd();
        if (facilityCd != null && !facilityCd.isEmpty() &&
          !facilityCd.equals(ntssUser.getFacilityCd())) {
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        }
      }
    }*/
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = AdminWebConstant.Uri.INDICATION_RESULT;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_INDICATION, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      examSetCd);
    // wp アプリケーションログの適正化 Add End

    Map<String, String> examSetCdMap = indicationResultService.getCheckNum(ntssUser.getFacilityCd(), examSetCd);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_INDICATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
      examSetCd);
    // wp アプリケーションログの適正化 Add End
    // レスポンス生成
    return new ResponseEntity<>(examSetCdMap, HttpStatus.OK);
  }

  /**
   * 予実リスト取得(検査結果)
   *
   * @param treatDateFrom 治療日(From)
   * @param treatDateTo 治療日(To)
   * @param patId 患者ID
   * @return 予実リスト(患者イベント)データのResponse
   */
  @GetMapping("/ins_result/list")
  public ResponseEntity<?> getInspectionResultList(
    @RequestParam(name = "treat_date_from", required = false) String treatDateFrom,
    @RequestParam(name = "treat_date_to", required = false) String treatDateTo,
    @RequestParam(name = "pat_id", required = true) Long patId,
    @AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = AdminWebConstant.Uri.INDICATION_RESULT + "/ins_result/list";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_INDICATION, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(treatDateFrom, treatDateTo,patId));
    // wp アプリケーションログの適正化 Add End
    List<ForecastInforResult> response = indicationResultService.getList(treatDateFrom, treatDateTo,
      patId, ntssUser.getFacilityCd(), 3);;

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_INDICATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(treatDateFrom, treatDateTo,patId));
    // wp アプリケーションログの適正化 Add End
    // レスポンス生成
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * 予実リスト取得(一般撮影検査予定)
   *
   * @param treatDateFrom 治療日(From)
   * @param treatDateTo 治療日(To)
   * @param patId 患者ID
   * @return 予実リスト(一般撮影検査予定)データのResponse
   */
  @GetMapping("/photo/list")
  public ResponseEntity<?> getGenPhotoInsResultList(
    @RequestParam(name = "treat_date_from", required = false) String treatDateFrom,
    @RequestParam(name = "treat_date_to", required = false) String treatDateTo,
    @RequestParam(name = "pat_id", required = true) Long patId,
    @AuthenticationPrincipal NtssUser ntssUser) {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = AdminWebConstant.Uri.INDICATION_RESULT + "/photo/list";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_INDICATION, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(treatDateFrom, treatDateTo,patId));
    // wp アプリケーションログの適正化 Add End

    List<ForecastInforResult> response = indicationResultService.getList(treatDateFrom, treatDateTo,
      patId, ntssUser.getFacilityCd(), 4);;

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_INDICATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(treatDateFrom, treatDateTo,patId));
    // wp アプリケーションログの適正化 Add End

    // レスポンス生成
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * 予実リスト取得(処方)
   *
   * @param treatDateFrom 治療日(From)
   * @param treatDateTo 治療日(To)
   * @param patId 患者ID
   * @return 予実リスト(処方)データのResponse
   */
  @GetMapping("/prescription/list")
  public ResponseEntity<?> getPrescriptionResultList(
    @RequestParam(name = "treat_date_from", required = false) String treatDateFrom,
    @RequestParam(name = "treat_date_to", required = false) String treatDateTo,
    @RequestParam(name = "pat_id", required = true) Long patId,
    @AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = AdminWebConstant.Uri.INDICATION_RESULT + "/prescription/list";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_INDICATION, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(treatDateFrom, treatDateTo,patId));
    // wp アプリケーションログの適正化 Add End
    List<ForecastInforResult> response = indicationResultService.getList(treatDateFrom, treatDateTo,
      patId, ntssUser.getFacilityCd(), 5);;

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_INDICATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(treatDateFrom, treatDateTo,patId));
    // wp アプリケーションログの適正化 Add End
    // レスポンス生成
    return new ResponseEntity<>(response, HttpStatus.OK);
  }
  // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end

  // add FNSI-改修内容 治療単位の治療方法マスタの有効項目に応じた表示 dou start
  @GetMapping("/getTreatmentConditionSetting/{facilityCd}/{treatmentName}")
  public ResponseEntity<?> getTreatmentConditionSetting(@PathVariable String facilityCd,
                                                        @PathVariable String treatmentName,
                                                        // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                        @AuthenticationPrincipal NtssUser ntssUser
                                                        // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
        if (facilityCd != null && !facilityCd.isEmpty() &&
          !facilityCd.equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " " + "treatmentName=" + treatmentName + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    try{
      if(!ntssUser.isNkkAdminUser()) {
        if (facilityCd != null && !facilityCd.isEmpty() &&
          !facilityCd.equals(ntssUser.getFacilityCd())) {
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        }
      }
    }catch (Exception ignored) {
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = AdminWebConstant.Uri.INDICATION_RESULT + "/getTreatmentConditionSetting";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_INDICATION, BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      treatmentName);
    // wp アプリケーションログの適正化 Add End
    try {
      List<String> treatmentConditionSetting = indicationResultService.getTreatmentConditionSetting(facilityCd, treatmentName);
      if (treatmentConditionSetting.size() > 0) {

        // wp アプリケーションログの適正化 Add Start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_INDICATION, AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
          treatmentName);
        // wp アプリケーションログの適正化 Add End
        return new ResponseEntity<>(treatmentConditionSetting.get(0), HttpStatus.OK);
      }

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_INDICATION, AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
      treatmentName);
    // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>("", HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_INDICATION, AFTER_LOG_FLG_ERROR, mappingUrl, facilityCd, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  // add FNSI-改修内容 治療単位の治療方法マスタの有効項目に応じた表示 dou end

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
