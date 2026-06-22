package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage;
import jp.co.nikkiso.ntss.admin_web.request.facility.SetStaffFacilityRequest;
import jp.co.nikkiso.ntss.admin_web.response.StaffFacilitySettingsResponse;
import jp.co.nikkiso.ntss.admin_web.response.facilities.FacilitiesResponse;
import jp.co.nikkiso.ntss.admin_web.response.facilities.StaffFacility;
import jp.co.nikkiso.ntss.admin_web.response.facilities.StaffFacilityResponse;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterUpdateResponse;
import jp.co.nikkiso.ntss.admin_web.response.personalUser.UserIdAndUserName;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.MstFacilityService;
import jp.co.nikkiso.ntss.admin_web.service.PersonalTabDefineService;
import jp.co.nikkiso.ntss.admin_web.service.PersonalUserService;
import jp.co.nikkiso.ntss.admin_web.service.facilities.FacilitiesService;
import jp.co.nikkiso.ntss.admin_web.service.master.user.MstUserService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallFacilityCancelManage;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstFacilityHashDao;
import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.MstFacilityHash;
import jp.co.nikkiso.ntss.core.entity.MstUser;
import jp.co.nikkiso.ntss.core.entity.TabDisplayNameAndContentsId;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.entity.MntFacilityCancelManage;


import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.util.ObjectUtils;
import org.springframework.util.StringUtils;

import java.util.Arrays;
import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.access.FacilityAccessService;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;

/**
 * 施設系のResourceクラス.
 */
@RestController
@RequestMapping(Uri.FACILITIES)
public class FacilityResource {

  /**
   * 稼働ビューア施設一覧Service.
   */
  @Autowired
  private FacilitiesService facilityService;

  /**
   * ログService.
   */
  @Autowired
  LogService logService;

  // add FNSi5712アプリケーションログが出力しない 周 start
  @Autowired
  LogEventUtils logEventUtils;
  @Autowired
  private FacilityAccessService facilityAccessService;

  // add FNSi5712アプリケーションログが出力しない 周 end

  /**
   * 個人設定タブ定義Service.
   */
  @Autowired
  private PersonalTabDefineService personalTabDefineService;

  /**
   * 利用者のService.
   */
  @Autowired
  private PersonalUserService personalUserService;

  /**
   * 施設マスタService
   */
  @Autowired
  private MstFacilityService mstFacilityService;

  @Autowired
  private MstUserService mstUserService;

  @Autowired
  private MstFacilityHashDao mstFacilityHashDao;

  /**
   * 施設解約API処理インタフェース
   */
  @Autowired
  private WebApiCallFacilityCancelManage webApiCallFacilityCancelManage;

  /**
   * 施設一覧取得.
   * <code>isNkkFacility</code>に<code>true</code>を指定する事で戻り値に設定される
   * 最大イベント発生日時を取得する際の条件が異なる.
   *
   * <code>true</code>を指定した場合
   *  サービス対応区分が、'0':未受付、1:一次対応済み、<code>null</code>の最大イベント発生日時
   * <code>false</code>を指定した場合
   *  対処が'0':未対処、<code>null</code>の最大イベント発生日時
   *
   * @param userId ユーザID
   * @param isNkkFacility 日機装施設に属しているか否か
   *                      属している場合は<code>true</code>を指定する.
   * @return 稼働ビューア施設一覧のResponse
   */
  @GetMapping("/{userId}")
  public ResponseEntity<?> getFacilities(
      @PathVariable Long userId,
      @RequestParam(name = "isNkkFacility") boolean isNkkFacility,
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 start
      if(!ntssUser.isNkkAdminUser()) {
        MstUser mstUser = mstUserService.getByUserId(userId);
        if (mstUser != null) {
          String facilityCd = mstUser.getFacilityCd();
          if (facilityCd != null && !facilityCd.isEmpty() &&
            !facilityCd.equals(ntssUser.getFacilityCd())) {
            String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " +
                    "mstUser.getFacilityCd()=" + mstUser.getFacilityCd() + " ";
            InvestigateLogUtils.info("11205",msg_11205_FORBIDDEN,"11205-FORBIDDEN");
            return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
          }
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 end

    // ログ出力
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.FACILITIES + "";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
      LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(userId, isNkkFacility));
    // add FNSi5712アプリケーションログが出力しない 周 end
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get Facilities : " + userId);
    logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    // レスポンス生成
    FacilitiesResponse response = facilityService.createFacilitiesResponse(userId, isNkkFacility);
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
      LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(userId, isNkkFacility));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * 担当施設取得.
   *
   * @param userId ユーザーID(内部)
   * @return 担当施設取得のResponse
   */
  @GetMapping("/staff_facility/{userId}")
  public ResponseEntity<?> getStaffFacility(@PathVariable Long userId,
                                            // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                            @AuthenticationPrincipal NtssUser ntssUser
                                            // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
                                            ) {
    if(!ntssUser.isNkkAdminUser()) {
      MstUser mstUser = mstUserService.getByUserId(userId);
      if (mstUser != null) {
        String facilityCd = mstUser.getFacilityCd();
        if (facilityCd != null && !facilityCd.isEmpty() &&
                !facilityCd.equals(ntssUser.getFacilityCd())) {
          return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
      }
    }

    // ログ出力
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.FACILITIES + "/staff_facility/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
      LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(userId));
    // add FNSi5712アプリケーションログが出力しない 周 end
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get staff facilities : " + userId);
    logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI,
        null);
    // レスポンス生成
    StaffFacilityResponse response = facilityService.getStaffFacility(userId);

    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
      LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(userId));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  @GetMapping("/staff_facility_sharing/{userId}")
  public ResponseEntity<?> getStaffFSharingacility(@PathVariable Long userId,
                                                   // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                   @AuthenticationPrincipal NtssUser ntssUser
                                                   // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 start
      if(!ntssUser.isNkkAdminUser()) {
        MstUser mstUser = mstUserService.getByUserId(userId);
        if (mstUser != null) {
          String facilityCd = mstUser.getFacilityCd();
          if (facilityCd != null && !facilityCd.isEmpty() &&
            !facilityCd.equals(ntssUser.getFacilityCd())) {
            String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " +
                    "mstUser.getFacilityCd()=" + mstUser.getFacilityCd() + " ";
            InvestigateLogUtils.info("11205",msg_11205_FORBIDDEN,"11205-FORBIDDEN");
            return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
          }
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 end

    // ログ出力
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.FACILITIES + "/staff_facility_sharing/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
      LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(userId));
    // add FNSi5712アプリケーションログが出力しない 周 end
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get staff facilities : " + userId);
    logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI,
        null);
    // レスポンス生成
    StaffFacilityResponse response = facilityService.getStaffSharingFacility(userId);

    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
      LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(userId));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * 担当施設設定.
   *
   * @param userId ユーザーID(内部)
   * @param request 担当施設設定のrequest
   * @return response
   */
  @PutMapping("/staff_facility/{userId}")
  public ResponseEntity<?> setStaffFacility(@PathVariable Long userId, @RequestBody SetStaffFacilityRequest request,
                                            // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                            @AuthenticationPrincipal NtssUser ntssUser
                                            // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 start
    if(!ntssUser.isNkkAdminUser()) {
      MstUser mstUser = mstUserService.getByUserId(userId);
      if (mstUser != null) {
        String facilityCd = mstUser.getFacilityCd();
        if (facilityCd != null && !facilityCd.isEmpty() &&
          !facilityCd.equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " +
                  "mstUser.getFacilityCd()=" + mstUser.getFacilityCd() + " ";
          InvestigateLogUtils.info("11205",msg_11205_FORBIDDEN,"11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        }
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 end

    // ログ出力
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.FACILITIES + "/staff_facility/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
      LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(userId, request));
    // add FNSi5712アプリケーションログが出力しない 周 end
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to set staff facilities : " + userId);
    logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI,
        null);
    // 更新処理
    StaffFacilitySettingsResponse response = facilityService.updateStaffFacility(userId, request.getStaffFacilityCds());

    // Httpステータスコード振分け
    HttpStatus httpStatus = HttpStatus.OK;
    String errorMessage = response.errorMessage;
    if (errorMessage != null) {
      // エラーメッセージに紐づくHttpステータスコード取得
      httpStatus = AdminWebMessage.Error.getHttpStatus(errorMessage);
    }
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
      LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(userId, request));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(response, httpStatus);
  }

  /**
   * 使用可能機能取得.
   *
   * @param facilityCd 施設コード
   * @return 使用可能機能リスト
   */
  @GetMapping("/{facilityCd}/use-functions")
  public ResponseEntity<List<String>> getUseFunctions(@PathVariable String facilityCd,
                                                      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                      @AuthenticationPrincipal NtssUser ntssUser
                                                      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
        if (facilityCd != null && !facilityCd.isEmpty() &&
          !facilityCd.equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()" + ntssUser.getFacilityCd() + " " +
                  "@PathVariable String facilityCd=" + facilityCd + " ";
          InvestigateLogUtils.info("11205",msg_11205_FORBIDDEN,"11205-FORBIDDEN");
          return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // ログ出力
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.FACILITIES + "/use-functions";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
      LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(facilityCd));
    // add FNSi5712アプリケーションログが出力しない 周 end
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get UseFunction : " + facilityCd);
    logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI,
        null);
    List<String> useFunctions = facilityService.getUseFunctions(facilityCd);
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
      LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(facilityCd));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(useFunctions, HttpStatus.OK);
  }

  /**
   * 個人設定タブ定義取得.
   *
   * @param facilityCd 施設コード
   * @return 個人設定タブ定義リスト
   */
  @GetMapping("/{facilityCd}/personal-setting/tab/define")
  public ResponseEntity<?> getDisplayNameAndContentsIdByFacilityCd(
      @PathVariable String facilityCd,
      @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
        if (facilityCd != null && !facilityCd.isEmpty() &&
          !facilityCd.equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()" + ntssUser.getFacilityCd() + " " +
                  "@PathVariable String facilityCd=" + facilityCd + " ";
          InvestigateLogUtils.info("11205",msg_11205_FORBIDDEN,"11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // ログ出力
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.FACILITIES + "/personal-setting/tab/define";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
      LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(facilityCd, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get displayNameAndContentsId : " + facilityCd);
    logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI,
        null);
    List<TabDisplayNameAndContentsId> personalTabDefine = personalTabDefineService
        .getDisplayNameAndContentsIdByFacilityCd(ntssUser);
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
      LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(facilityCd, ntssUser));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(personalTabDefine, HttpStatus.OK);
  }

  /**
   * 指定された施設と処方番号に属する医師リストを取得する
   *
   * @param facilityCd 施設コード
   * @param ordPrescriptionNo 処方番号
   * @return 医師リスト
   */
  @GetMapping("/{facilityCd}/personal-user/job/doctor/prescription")
  public ResponseEntity<?> getDoctorsPrescriptionByFacilityCd(@PathVariable String facilityCd,
      @RequestParam(name = "ordPrescriptionNo", required = false) Long ordPrescriptionNo,
                                                              // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                              @AuthenticationPrincipal NtssUser ntssUser
                                                              // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
        if (facilityCd != null && !facilityCd.isEmpty() &&
          !facilityCd.equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()" + ntssUser.getFacilityCd() + " " +
                  "@PathVariable String facilityCd=" + facilityCd + " ";
          InvestigateLogUtils.info("11205",msg_11205_FORBIDDEN,"11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.FACILITIES + "/personal-user/job/doctor/prescription";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
      LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(facilityCd, ordPrescriptionNo));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      if (ObjectUtils.isEmpty(ordPrescriptionNo)) {
        ordPrescriptionNo = null;
      }
      List<UserIdAndUserName> doctors = personalUserService.getDoctorsPrescriptionByFacilityCd(facilityCd,
          ordPrescriptionNo);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(facilityCd, ordPrescriptionNo));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(doctors, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST request to get doctors medicin list : " + facilityCd);
      logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 医師リスト取得.
   *
   * @param facilityCd 施設コード
   * @return 医師リスト
  */
  @GetMapping("/{facilityCd}/personal-user/job/doctor")
  public ResponseEntity<?> getDoctorsByFacilityCd(@PathVariable String facilityCd,
                                                  @RequestParam(required = false) Long selectedPatId,
                                                  // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                  @AuthenticationPrincipal NtssUser ntssUser
                                                  // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    if (!facilityAccessService.hasFacilityOrSelectedPatShareAccess(ntssUser, facilityCd, selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }

    // ログ出力
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.FACILITIES + "/personal-user/job/doctor";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
      LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(facilityCd));
    // add FNSi5712アプリケーションログが出力しない 周 end
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get doctors list : " + facilityCd);
    logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI,
        null);
    List<UserIdAndUserName> doctors = personalUserService.getDoctorsByFacilityCd(facilityCd);
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
      LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(facilityCd));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(doctors, HttpStatus.OK);
  }

  // mod #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc start
  /**
   * 医師リスト取得.
   *
   * @param facilityCd 施設コード
   * @return 医師リスト
   */
  @GetMapping("/{facilityCd}/personal-user/job/doctorIncludeDel")
  public ResponseEntity<?> getDoctorsByFacilityCdIncludeDel(@PathVariable String facilityCd,
                                                            // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                            @AuthenticationPrincipal NtssUser ntssUser
                                                            // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
        if (facilityCd != null && !facilityCd.isEmpty() &&
          !facilityCd.equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()" + ntssUser.getFacilityCd() + " " +
                  "@PathVariable String facilityCd=" + facilityCd + " ";
          InvestigateLogUtils.info("11205",msg_11205_FORBIDDEN,"11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    String mappingUrl = Uri.FACILITIES + "/personal-user/job/doctorIncludeDel";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
      LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(facilityCd));
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get doctors list : " + facilityCd);
    logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI,
        null);
    List<UserIdAndUserName> doctors = personalUserService.getDoctorsByFacilityCdIncludeDel(facilityCd);
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
      LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(facilityCd));
    return new ResponseEntity<>(doctors, HttpStatus.OK);
  }
  // mod #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc end

  /**
  * 施設システム利用設定取得.
  *
  * @param hashValue 取得対象の施設コードハッシュ
  * @return 対象施設のシステム利用設定
  *
  */
  @GetMapping("/MstFacilityHash/UseSys/hash")
  public ResponseEntity<?> getSystemUseSettingByHashValue(
      @RequestParam Map<String, Object> req) {

    // ログ出力
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.FACILITIES + "/MstFacilityHash/UseSys/hash";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
      LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(req));
    // add FNSi5712アプリケーションログが出力しない 周 end
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage
        .setLogMessage("REST request to get systemUseSetting By MstFacilityHash:" + req.get("hashValue").toString());
    eventLogMessage.setSqlIdentification("MstFacilityHashDao/findByHashValue");
    logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI, null);

    try {
      // レスポンス生成
      String response = mstFacilityService.getSystemUseSettingByHashValue(req.get("hashValue").toString());
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(req));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      // マスタ定義が取得できなかった場合
      eventLogMessage.setLogMessage("Exception message : " + e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
          HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
  * 施設システム利用設定 - URLサインイン設定、URLサインイン秘密鍵取得(サインイン画面でサインイン前に設定を取得する).
  *
  * @param hashValue 取得対象の施設コードハッシュ
  * @return 対象施設のシステム利用設定
  */
  @GetMapping("/MstFacilityHash/getUrlSignin")
  public ResponseEntity<?> getUrlSignin(
      @RequestParam String hashValue,
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 start
      if(ntssUser != null && !ntssUser.isNkkAdminUser()) {
        MstFacilityHash mstFacilityHash = mstFacilityHashDao.findByHashValue(hashValue);
        if (mstFacilityHash != null) {
          String facilityCd = mstFacilityHash.getFacilityCd();
          if (facilityCd != null && !facilityCd.isEmpty() &&
            !facilityCd.equals(ntssUser.getFacilityCd())) {
            String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " +
                    "mstFacilityHash.getFacilityCd()=" + mstFacilityHash.getFacilityCd() + " ";
            InvestigateLogUtils.info("11205",msg_11205_FORBIDDEN,"11205-FORBIDDEN");
            return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
          }
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 end

    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.FACILITIES + "/MstFacilityHash/getUrlSignin";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
      LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(hashValue));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(hashValue));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(mstFacilityService.getUrlSignin(hashValue),
          HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();

      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI,
      null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
  * サインインIF表示設定取得(サインイン画面でサインイン前に設定を取得する).
  *
  * @param hashValue 取得対象の施設コードハッシュ
  * @return 対象施設のシステム利用設定
  */
  @GetMapping("/MstFacilityHash/getIsSigninDisp")
  public ResponseEntity<?> getIsSigninDisp(
      @RequestParam String hashValue) {
    String mappingUrl = Uri.FACILITIES + "/MstFacilityHash/getIsSigninDisp";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(hashValue));
    try {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
          LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
          Arrays.asList(hashValue));
      return new ResponseEntity<>(mstFacilityService.getIsSigninDisp(hashValue),
          HttpStatus.OK);
    } catch (Exception e) {
      e.printStackTrace();
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI,
          null);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
          LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
          Arrays.asList(e.getMessage()));
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
  * 施設マスタハッシュ取得.
  *
  * @param facilityCd 取得対象の施設コード
  * @return 対象施設の施設マスタハッシュテーブルのResponse
  *
  */
  @GetMapping("/MstFacilityHash/{facilityCd}")
  public ResponseEntity<?> getMstFacilityHashByFacilityCd(@PathVariable String facilityCd,
                                                          // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                          @AuthenticationPrincipal NtssUser ntssUser
                                                          // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
        if (facilityCd != null && !facilityCd.isEmpty() &&
          !facilityCd.equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()" + ntssUser.getFacilityCd() + " " +
                  "@PathVariable String facilityCd=" + facilityCd + " ";
          InvestigateLogUtils.info("11205",msg_11205_FORBIDDEN,"11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // ログ出力
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.FACILITIES + "/MstFacilityHash/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
      LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(facilityCd));
    // add FNSi5712アプリケーションログが出力しない 周 end
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get master : mst_facility_hash");
    logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    try {
      // レスポンス生成
      MstFacilityHash response = mstFacilityService.getMstFacilityHashByFacilityCd(facilityCd);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(facilityCd));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      // マスタ定義が取得できなかった場合
      eventLogMessage.setLogMessage("Exception message : " + e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
          HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
  * 施設マスタハッシュ取得(全て).
  *
  * @return 施設マスタハッシュテーブルのResponse
  *
  */
  @GetMapping("/MstFacilityHash/SelectAll")
  public ResponseEntity<?> getMstFacilityHash() {
    // ログ出力
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.FACILITIES + "/MstFacilityHash/SelectAll";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
      LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // add FNSi5712アプリケーションログが出力しない 周 end
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get master : mst_facility_hash");
    logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI,
        null);
    try {
      // レスポンス生成
      List<MstFacilityHash> response = mstFacilityService.getMstFacilityHash();
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      // マスタ定義が取得できなかった場合
      eventLogMessage.setLogMessage("Exception message : " + e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI,
          null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
          HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
  * 施設解約管理取得(処理区分:施設解約).
  *
  * @return 施設解約管理テーブルのResponse
  *
  */
  @GetMapping("/MntFacilityCancelManage/SelectAll")
  public ResponseEntity<?> getMntFacilityCancelManage() {
    // ログ出力
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.FACILITIES + "/MntFacilityCancelManage/SelectAll";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
      LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // add FNSi5712アプリケーションログが出力しない 周 end
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get master : mnt_facility_cancel_manage");
    logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.REMS, null);
    try {
      // レスポンス生成
      List<MntFacilityCancelManage> response = mstFacilityService.getMntFacilityCancelManage();
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      // マスタ定義が取得できなかった場合
      eventLogMessage.setLogMessage("Exception message : " + e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.REMS, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
          HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 解約施設を完全削除する
   *
   * @param payload リクエストパラメータ
   * @return ResponseEntity
   */
  @PostMapping("/completeDelete")
  public ResponseEntity<String> completeDelete(@RequestBody Map<String, String> payload,
                                               // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                               @AuthenticationPrincipal NtssUser ntssUser
                                               // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
        String facilityCd = payload.get("facilityCd");
        if (facilityCd != null && !facilityCd.isEmpty() &&
          !facilityCd.equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()" + ntssUser.getFacilityCd() + " " +
                  "payload.get(\"facilityCd\")=" + facilityCd + " ";
          InvestigateLogUtils.info("11205",msg_11205_FORBIDDEN,"11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.FACILITIES + "/MntFacilityCancelManage/SelectAll";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
      LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(payload));
    // add FNSi5712アプリケーションログが出力しない 周 end
    String facilityCd = payload.get("facilityCd");
    if (StringUtils.isEmpty(facilityCd)) {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(payload));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>("施設コードが指定されていません。", HttpStatus.BAD_REQUEST);
    }

    try {
      mstFacilityService.completeDeleteFacility(facilityCd);
      String okMsg = String.format("解約施設を完全削除しました。 施設コード:[%s]", facilityCd);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(payload));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(okMsg, HttpStatus.OK);
    } catch (NtssException e) {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
    } catch (Exception e) {
      String errMsg = String.format("施設解約の完全削除で内部エラーが発生しました。 施設コード:[%s]", facilityCd);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(errMsg, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * ReMS解約/FNSi解約施設のバックアップデータを削除する
   *
   * @param payload リクエストパラメータ
   * @return ResponseEntity
   */
  @PostMapping("/dataDelete")
  public ResponseEntity<String> dataDelete(@RequestBody Map<String, String> payload,
                                           // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                           @AuthenticationPrincipal NtssUser ntssUser
                                           // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
        String facilityCd = payload.get("facilityCd");
        if (facilityCd != null && !facilityCd.isEmpty() &&
          !facilityCd.equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()" + ntssUser.getFacilityCd() + " " +
                  "payload.get(\"facilityCd\")=" + facilityCd + " ";
          InvestigateLogUtils.info("11205",msg_11205_FORBIDDEN,"11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.FACILITIES + "/dataDelete";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
      LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(payload));
    // add FNSi5712アプリケーションログが出力しない 周 end
    String facilityCd = payload.get("facilityCd");
    if (StringUtils.isEmpty(facilityCd)) {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(payload));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>("施設コードが指定されていません。", HttpStatus.BAD_REQUEST);
    }

    try {
      mstFacilityService.deleteBackupFileFacility(facilityCd);
      String okMsg = String.format("バックアップデータを削除しました。 施設コード:[%s]", facilityCd);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(payload));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(okMsg, HttpStatus.OK);
    } catch (NtssException e) {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
    } catch (Exception e) {
      String errMsg = String.format("バックアップデータ削除で内部エラーが発生しました。 施設コード:[%s]", facilityCd);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(errMsg, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 解約施設のバックアップファイルをダウンロードする
   *
   * @param payload リクエストパラメータ
   * @return ResponseEntity
   */
  @PostMapping("/downloadBackup")
  public ResponseEntity<?> downloadBackup(@RequestBody Map<String, String> payload,
                                          // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                          @AuthenticationPrincipal NtssUser ntssUser
                                          // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
        String facilityCd = payload.get("facilityCd");
        if (facilityCd != null && !facilityCd.isEmpty() &&
          !facilityCd.equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()" + ntssUser.getFacilityCd() + " " +
                  "payload.get(\"facilityCd\")=" + facilityCd + " ";
          InvestigateLogUtils.info("11205",msg_11205_FORBIDDEN,"11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.FACILITIES + "/downloadBackup";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
      LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(payload));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      if (!payload.containsKey("facilityCd")) {
        // add FNSi5712アプリケーションログが出力しない 周 start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
          LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
          Arrays.asList(payload));
        // add FNSi5712アプリケーションログが出力しない 周 end
        String errMsg = String.format("施設コードが指定されていません。");
        return new ResponseEntity<>(errMsg, HttpStatus.INTERNAL_SERVER_ERROR);
      }

      if (!payload.containsKey("baseDate")) {
        // add FNSi5712アプリケーションログが出力しない 周 start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
          LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
          Arrays.asList(payload));
        // add FNSi5712アプリケーションログが出力しない 周 end
        String errMsg = String.format("解約基準日が指定されていません。");
        return new ResponseEntity<>(errMsg, HttpStatus.INTERNAL_SERVER_ERROR);
      }

      if (!payload.containsKey("procClass")) {
        // add FNSi5712アプリケーションログが出力しない 周 start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
          LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
          Arrays.asList(payload));
        // add FNSi5712アプリケーションログが出力しない 周 end
        String errMsg = String.format("処理区分が指定されていません。");
        return new ResponseEntity<>(errMsg, HttpStatus.INTERNAL_SERVER_ERROR);
      }

      JSONObject jsonBody = new JSONObject();
      jsonBody.put("facility_cd", payload.get("facilityCd"));
      jsonBody.put("base_date", payload.get("baseDate"));
      jsonBody.put("proc_class", payload.get("procClass"));
      ResponseEntity<byte[]> response = webApiCallFacilityCancelManage.getBackupBinary(jsonBody);

      if (response.getStatusCode().equals(HttpStatus.OK)) {
        byte[] downloadByteData = response.getBody();
        if (downloadByteData == null) {
          // add FNSi5712アプリケーションログが出力しない 周 start
          logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
            LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
            Arrays.asList(payload));
          // add FNSi5712アプリケーションログが出力しない 周 end
          String errMsg = String.format("ダウンロード対象が存在しません。");
          return new ResponseEntity<>(errMsg, HttpStatus.INTERNAL_SERVER_ERROR);
        }

        HttpHeaders header = new HttpHeaders();

        header.set("Content-Type", "application/octet-stream");
        header.set(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"download.zip\"");
        // add FNSi5712アプリケーションログが出力しない 周 start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
          LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
          Arrays.asList(payload));
        // add FNSi5712アプリケーションログが出力しない 周 end
        return new ResponseEntity<>(downloadByteData, header, HttpStatus.OK);
      }

      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(payload));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.INTERNAL_SERVER_ERROR);

    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.REMS, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
      String errorMessage = "ファイルダウンロードに失敗しました";
      return new ResponseEntity<>(errorMessage, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
  * 2要素認証失敗許容回数取得.
  *
  * @param hashValue 取得対象の施設コードハッシュ
  * @return 対象施設の2要素認証失敗許容回数
  *
  */
  @GetMapping("MstFacilityHash/OtpFailureCnt/hash")
  public ResponseEntity<?> getSystemOtpFailureCntByHashValue(@RequestParam Map<String, Object> req
) {
    // ログ出力
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.FACILITIES + "/MstFacilityHash/OtpFailureCnt/hash";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
      LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(req));
    // add FNSi5712アプリケーションログが出力しない 周 end
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage
        .setLogMessage("REST request to get otpFailureCnt By MstFacilityHash:" + req.get("hashValue").toString());
    eventLogMessage.setSqlIdentification("hashValue = " + req.get("hashValue").toString());
    logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI, null);

    try {
      // レスポンス生成
      Integer response = mstFacilityService.getSystemOtpFailureCntByHashValue(req.get("hashValue").toString());
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(req));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(response.toString(), HttpStatus.OK);
    } catch (Exception e) {
      // マスタ定義が取得できなかった場合
      eventLogMessage.setLogMessage("Exception message : " + e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI, "MstFacilityHashDao/findByHashValue");
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
          HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  // add FNSI-3922 投薬指示機能が施設拡張設定のON\OFF制御に反映していない liumx start
  /**
   * 施設マスタハッシュ取得.
   *
   * @param facilityCd 取得対象の施設コード
   * @return 対象施設のmst facilityテーブルのResponse
   *
  */
  @GetMapping("/getFacilityInfoByCd/{facilityCd}")
  public ResponseEntity<?> getFacilityInfoByCd(@PathVariable String facilityCd,
                                               @RequestParam(required = false) Long selectedPatId,
                                               // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                               @AuthenticationPrincipal NtssUser ntssUser
                                               // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    if (!facilityAccessService.hasFacilityOrSelectedPatShareAccess(ntssUser, facilityCd, selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }

    // ログ出力
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.FACILITIES + "/getFacilityInfoByCd/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
      LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(facilityCd));
    // add FNSi5712アプリケーションログが出力しない 周 end
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get master : mst_facility");
    logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    try {
      // レスポンス生成
      List<MstFacility> response = mstFacilityService.getFacilityInfoByCd(facilityCd);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(facilityCd));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      // マスタ定義が取得できなかった場合
      eventLogMessage.setLogMessage("Exception message : " + e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
        HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  // add FNSI-3922 投薬指示機能が施設拡張設定のON\OFF制御に反映していない liumx end

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
}
