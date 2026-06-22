package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.service.FacilitySettingService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.userAccount.UserAccountServiceImpl;
import jp.co.nikkiso.ntss.core.config.NtssSecurityPoricy;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.admin_web.request.authority.UserAuthorityRequest;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.authority.UserAuthorityService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.sysSignManager.SysSigninManagerService.ForceSignOutReason;
import jp.co.nikkiso.ntss.core.dao.MstUserDao;
import jp.co.nikkiso.ntss.core.entity.MstUser;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;

/**
 * 利用者権限のResourceクラス.
 */
@RestController
@Slf4j
@RequestMapping(AdminWebConstant.Uri.USER_AUTHORITY)
public class UserAuthorityResource {

  /**
   * 利用者権限Service.
   */
  @Autowired
  private UserAuthorityService userAuthorityService;

  @Autowired
  LogService logService;
  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  // add #6587 利用者マスタで使用許可機能を編集した時にメッセージが出る場合とでない場合がある 王永吉 start
  @Autowired
  private MstUserDao mstUserDao;
  @Autowired
  private UserAccountServiceImpl serAccountServiceImpl;
  // add #6587 利用者マスタで使用許可機能を編集した時にメッセージが出る場合とでない場合がある 王永吉 end

  // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou start
  /**
   * ロガー生成コンポーネント
   */
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  /* add by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
  @Autowired
  private FacilitySettingService facilitySettingService;
  /* add by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */

  /**
   * サインアウト
   *
   * @param request
   * @param response
   * @param userId
   * @return
   */
  @PostMapping("sign-out")
  public ResponseEntity<?> signOut(
    HttpServletRequest request,
    HttpServletResponse response,
    @RequestBody String userId,
    @RequestHeader(value = "ForceSignOutReason", required = false) String forceSignOutReason,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    @AuthenticationPrincipal NtssUser ntssUser
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if (ntssUser != null && !ntssUser.isNkkAdminUser()) {
        MstUser mstUser = mstUserDao.selectById(Long.valueOf(userId));
        if (mstUser.getFacilityCd() != null && !mstUser.getFacilityCd().equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + mstUser.getFacilityCd() + " " + "userId=" + userId ;
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        }
      }
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    if (NtssSecurityPoricy.doAccessKeyCheck(request, response, eventLoggerFactory)) {
      ForceSignOutReason reason = ForceSignOutReason.fromName(forceSignOutReason,
        ForceSignOutReason.USER_AUTHORITY_CHANGED);
      userAuthorityService.signOut(Long.parseLong(userId), reason);
    } else {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("NtssSecurityPoricy.doAccessKeyCheck-Return Not Found!!");
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.FORBIDDEN);
    }
    // レスポンス生成
    return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
  }
  // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou end
  // add #10160 複数端末同時サインイン無効時の強制サインアウトが動作しない。 dou start
  /**
   * 自分自身以外のサインアウト
   *
   * @param request
   * @param response
   * @param params
   * @return
   */
  @PostMapping("sign-out-another")
  public ResponseEntity<?> signOutAnother(
    HttpServletRequest request,
    HttpServletResponse response,
    @RequestBody Map<String, String> params) {
    if (NtssSecurityPoricy.doAccessKeyCheck(request, response, eventLoggerFactory)) {
      userAuthorityService.signOutAnother(params);
    } else {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("NtssSecurityPoricy.doAccessKeyCheck-Return Not Found!!");
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.FORBIDDEN);
    }
    // レスポンス生成
    return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
  }
  // add #10160 複数端末同時サインイン無効時の強制サインアウトが動作しない。 dou end

  /**
   * 利用者権限取得.
   *
   * @param userId  ユーザーID
   * @return 利用者権限のResponse
   */
  @GetMapping("/{user_id}/list")
  public ResponseEntity<?> getUserAuthority(
    @PathVariable("user_id") Long userId,
    @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 start
    if (ntssUser != null && !ntssUser.isNkkAdminUser()) {
      MstUser mstUser = mstUserDao.selectById(userId);
      if (mstUser != null || mstUser.getFacilityCd() != null || !mstUser.getFacilityCd().equals(ntssUser.getFacilityCd()) ) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + mstUser.getFacilityCd() + " " + "userId=" + userId;
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 start

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = AdminWebConstant.Uri.USER_AUTHORITY + "/list";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      userId);
    // wp アプリケーションログの適正化 Add End

//    // ログ出力
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage("REST request to get user authority : "+ userId);
//    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    // 利用者権限を取得する
    List<String> response = userAuthorityService.getAuthorizedAuthorities(userId);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      userId);
    // wp アプリケーションログの適正化 Add End

    // レスポンス生成
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * ログインユーザーの利用者権限取得.
   *
   * @param ntssUser NTSS認証ユーザ
   * @return 利用者権限のResponse
   */
  @GetMapping("/login/list")
  public ResponseEntity<?> getLoginUserAuthority(
    @AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = AdminWebConstant.Uri.USER_AUTHORITY + "/login/list";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    Long userId = ntssUser.getUserId();

//    // ログ出力
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage("REST request to get login user authority : "+ userId);
//    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    // 利用者権限を取得する
    /* upd by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
    // add #6587 利用者マスタで使用許可機能を編集した時にメッセージが出る場合とでない場合がある 王永吉 start
    // List<String> response = userAuthorityService.getAuthorizedAuthorities(userId);
    // List<String> response = serAccountServiceImpl.getUserMiddle(userId).getUserSettings().getAuthorizedAuthorities();
    List<String> response = new ArrayList<>();
    String value = facilitySettingService.getFacilitySettingValue(ntssUser.getFacilityCd(),
            CoreConstant.FacilitySettingNo.AUTHORITY_CHANGE_SIGN_OUT);
    MstUser mstUser = new MstUser();
    if ("1".equals(value)) { // 施設マスタ 64 権限変更時サインアウト:   有効の場合
      mstUser = mstUserDao.selectById(userId);
    } else { // 施設マスタ 64 権限変更時サインアウト:   無効の場合
      mstUser = ntssUser.getMstUser();
    }
    if (mstUser != null) {
      response = mstUser.getUserSettings().getAuthorizedAuthorities();
    }
    // add #6587 利用者マスタで使用許可機能を編集した時にメッセージが出る場合とでない場合がある 王永吉 end
    /* upd by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      userId);
    // wp アプリケーションログの適正化 Add End

    // レスポンス生成
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * 利用者権限更新.
   *
   * @param request  利用者権限のRequest
   * @param ntssUser NTSS認証ユーザ
   * @return
   */
  @PutMapping("/list")
  public ResponseEntity<?> updateUserAuthority(
    @RequestBody List<UserAuthorityRequest> request,
    @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if (ntssUser != null && !ntssUser.isNkkAdminUser()) {
      for (UserAuthorityRequest userAuthorityRequest : request) {
        MstUser mstUser = mstUserDao.selectById(userAuthorityRequest.getUserId());
        if (mstUser != null && mstUser.getFacilityCd() != null && !mstUser.getFacilityCd().equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + mstUser.getFacilityCd() + " " + "userId=" + userAuthorityRequest.getUserId();
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = AdminWebConstant.Uri.USER_AUTHORITY + "/list";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

//    // ログ出力
//    List<Long> userIds = request.stream().map(u -> u.getUserId()).collect(Collectors.toList());
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage("REST request to put user authority : "+ userIds);
//    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    /* del by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
    // // add #6587 利用者マスタで使用許可機能を編集した時にメッセージが出る場合とでない場合がある 王永吉 start
    // if (request.size() > 0){
    //   MstUser userThisU = mstUserDao.selectById(request.get(0).getUserId());
    //   serAccountServiceImpl.doInginSoming(false, userThisU, request.get(0).getUserId());
    // }
    // // add #6587 利用者マスタで使用許可機能を編集した時にメッセージが出る場合とでない場合がある 王永吉 end
    /* del by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */

    // 利用者情報の更新
    request.forEach(
      u -> userAuthorityService.updateAuthorizedAuthorities(u.getUserId(), u.getAuthorities(), u.getSignoutFlg())
    );
    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    // レスポンス生成
    return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
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
