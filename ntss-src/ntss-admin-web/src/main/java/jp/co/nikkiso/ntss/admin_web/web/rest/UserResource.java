package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage;
import jp.co.nikkiso.ntss.admin_web.request.userAccount.AlterProvisionalInfoRequest;
import jp.co.nikkiso.ntss.admin_web.request.userAccount.UpdateUserAccountInfoRequest;
import jp.co.nikkiso.ntss.admin_web.request.userAccount.UserAuthenticationRequest;
import jp.co.nikkiso.ntss.admin_web.response.ProvisionalUserResponse;
import jp.co.nikkiso.ntss.admin_web.response.UserIdDuplicateCheckResponse;
import jp.co.nikkiso.ntss.admin_web.response.error.ErrorResponse;
import jp.co.nikkiso.ntss.admin_web.response.userAccount.UserAccountResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.sysSignManager.SysSigninManagerService;
import jp.co.nikkiso.ntss.admin_web.service.sysSignManager.SysSigninManagerService.ForceSignOutReason;
import jp.co.nikkiso.ntss.admin_web.service.userAccount.ProvisionalUserService;
import jp.co.nikkiso.ntss.admin_web.service.userAccount.UserAccountService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.UserAuthentication;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.session.SessionRegistry;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpSession;
import javax.validation.Valid;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

/**
 * アカウント編集画面のResourceクラス.
 * <p>
 * アカウント編集画面から呼び出されるDB処理
 * <p>
 */
@RestController
@Slf4j
@RequestMapping(Uri.USER)
public class UserResource {

  //add #12657 【securify】SQLインジェクション(High) zrx start
  private static final Pattern FACILITY_CD_PATTERN = Pattern.compile("^[A-Za-z0-9]{6}$");
  private static final Pattern NUMERIC_PATTERN = Pattern.compile("^\\d+$");
  //add #12657 【securify】SQLインジェクション(High) zrx end

  /**
   * アカウント情報Service.
   */
  @Autowired
  private UserAccountService userAccountService;

  /**
   * 仮ユーザー情報Service.
   */
  @Autowired
  private ProvisionalUserService provisionalUserService;

  /**
   * サインイン管理Service.
   */
  @Autowired
  private SysSigninManagerService sysSigninManagerService;

  @Autowired
  LogService logService;
  /**
   * 仮ユーザー情報変更.
   *
   * @param request 仮ユーザー情報変更のRequest
   * @return response
   */
  @PutMapping("/provisional")
  public ResponseEntity<?> alterProvisionalInfo(@RequestBody AlterProvisionalInfoRequest request, @AuthenticationPrincipal NtssUser ntssUser) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to alter provisional user info : "+ request.getDispUserIdPre());
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    // service呼び出し
    ProvisionalUserResponse response = provisionalUserService.updateProvisionalUser(
      request.getDispUserIdPre(), request.getDispUserIdNew(), request.getUserPasswordNew(),
      request.getFacilityCd(), ntssUser.getUserId(), request.getUserLastName(),
      request.getUserFirstName(),request.getIsProvisional(),request.getIsConsent());

    // Httpステータスコード振分け
    HttpStatus httpStatus = HttpStatus.OK;
    String errorMessage = response.errorMessage;
    if (errorMessage != null) {
      // エラーメッセージに紐づくHttpステータスコード取得
      httpStatus = AdminWebMessage.Error.getHttpStatus(errorMessage);
    }
    return new ResponseEntity<>(response, httpStatus);

  }

  /**
   * アカウント情報取得.
   *
   * @param ntssUser NTSS認証ユーザー
   * @return アカウント情報のResponse
   */
  @GetMapping("")
  public ResponseEntity<?> getUserAccountInfo(@AuthenticationPrincipal NtssUser ntssUser) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get user account info : "+ ntssUser.getUserId());
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);
    // service呼び出し
    UserAccountResponse response = userAccountService.createUserAccountResponse(ntssUser.getUserId());

    // レスポンス生成
    return new ResponseEntity<>(response, response.userAccountInfo == null ? HttpStatus.INTERNAL_SERVER_ERROR : HttpStatus.OK);

  }

  /**
   * ユーザ情報取得.
   *
   * @param userId ユーザーID
   * @return ユーザー情報のResponse
   */
  @GetMapping("/get_by_id/{userId}")
  public ResponseEntity<?> getUserInfoById(@PathVariable Long userId) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get user account info : "+ userId);
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    // service呼び出し
    UserAccountResponse response = userAccountService.createUserAccountResponse(userId);

    // レスポンス生成
    return new ResponseEntity<>(response, response.userAccountInfo == null ? HttpStatus.INTERNAL_SERVER_ERROR : HttpStatus.OK);

  }

  /*add FNSI-改修内容全体の合否が俯瞰できるように修正 任 start*/
  @GetMapping("/getAllUser/{facilityCd}")
  public ResponseEntity<?> getAllUser(@PathVariable String facilityCd) {
    List<MstPersonalUser> response = userAccountService.selectAllUser(facilityCd);
    return new ResponseEntity<>(response, response == null ? HttpStatus.INTERNAL_SERVER_ERROR : HttpStatus.OK);
  }
  /*add FNSI-改修内容全体の合否が俯瞰できるように修正 任 end*/
  /**
   * アカウント情報更新.
   *
   * @param request アカウント情報更新リクエスト
   * @return response
   */
  @PutMapping("")
  public ResponseEntity<?> editUserAccountInfo(@Valid @RequestBody UpdateUserAccountInfoRequest request) {
    //add #12657 【securify】SQLインジェクション(High) zrx start
    if (!isAlphanumericSixChars(request.getFacilityCd())) {
      return ResponseEntity.status(HttpStatus.BAD_REQUEST)
        .body("facilityCdは英数字6桁のみ指定可能です。");
    }
    if (!isNumericWithMaxLengthOrEmpty(request.getInfoDispToAdmin(), 1)) {
      return ResponseEntity.status(HttpStatus.BAD_REQUEST)
        .body("infoDispToAdminは1桁の数字のみ指定可能です。");
    }
    if (!isNumericWithMaxLengthOrEmpty(request.getInHospitalCd_1(), 20)) {
      return ResponseEntity.status(HttpStatus.BAD_REQUEST)
        .body("inHospitalCd_1は20桁以内の数字のみ指定可能です。");
    }
    if (!isNumericWithMaxLengthOrEmpty(request.getInHospitalCd_2(), 20)) {
      return ResponseEntity.status(HttpStatus.BAD_REQUEST)
        .body("inHospitalCd_2は20桁以内の数字のみ指定可能です。");
    }
    if (!isNumericOrEmpty(request.getJobCd())) {
      return ResponseEntity.status(HttpStatus.BAD_REQUEST)
        .body("jobCdは数字のみ指定可能です。");
    }
    //add #12657 【securify】SQLインジェクション(High) zrx end

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to update user account info : "+ request.getUserId());
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

	// add #12587 スタッフ切替 start
    List<UserAuthenticationRequest> canLoginFacilitiesList = request.getCanLoginFacilitiesList();

    List<UserAuthenticationRequest> canLoginFacilitiesListAll = new ArrayList<>();
    canLoginFacilitiesListAll.addAll(canLoginFacilitiesList);
    UserAuthenticationRequest request1 = new UserAuthenticationRequest();
    request1.setUsername(request.getDispUserId());
    request1.setFacilityHash(userAccountService.getHashByCd(request.getFacilityCd()));

    canLoginFacilitiesListAll.add(request1);
    for (UserAuthenticationRequest user : canLoginFacilitiesListAll) {
      int index = 0;
      for (UserAuthenticationRequest user1 : canLoginFacilitiesListAll) {
        if(user1.getFacilityHash().equals(user.getFacilityHash()) &&
          user1.getUsername().equals(user.getUsername())

        ){
          index++;
          if(index > 1){
            ErrorResponse errorResponse = new ErrorResponse("施舍中存在重复项，请修改后提交！");
            return new ResponseEntity<>(errorResponse, HttpStatus.OK);
          }
        }
      }
    }
	// add #12587 スタッフ切替 end
    // 更新処理
    userAccountService.updateUserAccountInfo(request);

    return new ResponseEntity<>(true, HttpStatus.OK);

  }

  //add #12657 【securify】SQLインジェクション(High) zrx start
  private boolean isAlphanumericSixChars(String value) {
    return value != null && FACILITY_CD_PATTERN.matcher(value).matches();
  }

  private boolean isNumericWithMaxLengthOrEmpty(String value, int maxLength) {
    if (value == null || value.trim().isEmpty()) {
      return true;
    }
    return value.length() <= maxLength && NUMERIC_PATTERN.matcher(value).matches();
  }

  private boolean isNumericOrEmpty(String value) {
    if (value == null || value.trim().isEmpty()) {
      return true;
    }
    return NUMERIC_PATTERN.matcher(value).matches();
  }
  //add #12657 【securify】SQLインジェクション(High) zrx end

  /**
   * 重複チェック<br>
   * チェック方法は以下の通りです.
   * <li>表示用ユーザIDに該当する利用者マスタを取得する.
   * <li>取得した利用者マスタ内に渡されたユーザIDと異なるユーザIDが存在している場合は重複ありと判断する.
   *
   * @param userId ユーザID
   * @param dispUserId 表示用ユーザID
   * @return 重複ありの場合trueを返す.重複がない場合はfalseを返す.
   */
  @GetMapping("/check/{userId}/{dispUserId}")
  public ResponseEntity<?> isDuplicateDispUserId(@PathVariable Long userId, @PathVariable String dispUserId) {
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get count of mst_user : "+ dispUserId);
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    // 渡されたユーザIDと異なる利用者マスタ情報が存在する場合、重複していると判断する。
    if (userAccountService.selectDuplicateCount(dispUserId, userId) > 0) {
      return new ResponseEntity<>(new UserIdDuplicateCheckResponse(AdminWebMessage.Error.USER_ID_EXISTED.getMessage()), HttpStatus.OK);
    }
    return new ResponseEntity<>(new UserIdDuplicateCheckResponse(), HttpStatus.OK);
  }

  /**
   * {@link SessionRegistry}
   */
  @Autowired
  private SessionRegistry sessionRegistry;

  /**
   * 自分自身以外のセッションを無効化（タイムアウト）する.
   * @param currentSession カレントセッション情報
   * @return レスポンス情報
   */
  @PutMapping("/logoutAnother")
  public ResponseEntity<?> logoutAnother(
      HttpSession currentSession,
      @RequestBody Map<String,String> params) {

    // アクセス元のcookie：JSESSIONIDを取得
    String sessionId = currentSession.getId();
    // mod #10160 複数端末同時サインイン無効時の強制サインアウトが動作しない。 dou start
//    // 自ログイン利用者の認証情報(Principal)を取得
//    Optional<Object> principal = Optional.ofNullable(SecurityContextHolder.getContext().getAuthentication())
//      .map(authentication -> authentication.getPrincipal());
//    if (principal.isPresent()) {
//      // 現行で接続されているセッションを取得するには false を引数に指定
//      List<SessionInformation> sessions = sessionRegistry.getAllSessions(principal.get(), false);
//      sessions.forEach(session -> {
//        if (sessionId.equals(session.getSessionId())) {
//          // 自身のセッションは処理しない
//          return;
//        }
//        // 他端末のセッションはタイムアウトさせる
//        session.expireNow();
//      });
//    }
//    // 自身以外の同じ利用者のサインイン管理情報を削除
//    Long userId = StrUtils.isNumber(params.get("userId")) ? Long.parseLong(params.get("userId")) : 0L;
//    sysSigninManagerService.deleteByUserId(userId, params.get("terminalUniqueString"));

    params.put("sessionId", sessionId);
    sysSigninManagerService.signOutAnotherForMultiServer(params,
      ForceSignOutReason.MULTI_BROWSER_SIGN_IN_PROHIBITED);
    // mod #10160 複数端末同時サインイン無効時の強制サインアウトが動作しない。 dou end
    return new ResponseEntity<>(HttpStatus.OK);
  }

  /**
   * 画面から入力された現在のパスワードとDB上のパスワードが一致するかチェック.
   *
   * @param userId ユーザID
   * @param CurrentPassword 入力された現在のパスワード
   * @return 現在のパスワードと一致する場合trueを返す.
   */
  @GetMapping("/checkMatchCurrentPassword")
  public ResponseEntity<?> checkMatchCurrentPassword(
      @RequestParam(value = "userId") Long userId,
      @RequestParam(value = "CurrentPassword") String CurrentPassword) {
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to Match current password with mst_user_authentication password : "+ userId);
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.REMS, null);
    // 現在のパスワードとDB上のパスワードの突合せ
    return new ResponseEntity<>(userAccountService.isMatchCurrentPassword(CurrentPassword, userId), HttpStatus.OK);
  }

  /**
   * パスワードが利用できるかチェック.
   * 過去に設定したパスワードは利用禁止.何世代前まで禁止するかは施設設定マスタ参照.
   *
   * @param userId ユーザID
   * @param newPassword 入力された新しいパスワード
   * @param facilityCd 施設コード
   * @return パスワードが利用できる場合はtrue.
   */
  @GetMapping("/isAvailablePassword")
  public ResponseEntity<?> isAvailablePassword(
      @RequestParam(value = "userId") Long userId,
      @RequestParam(value = "newPassword") String newPassword,
      @RequestParam(value = "facilityCd") String facilityCd) {
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to Check if password is available");
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.REMS, null);
    // 現在のパスワードとDB上のパスワードの突合せ
    return new ResponseEntity<>(userAccountService.isAvailablePassword(userId, newPassword, facilityCd), HttpStatus.OK);
  }
	
  // add #12587 スタッフ切替 start
  /**
   * ログイン可能な施設取得
   * @param userId 利用者ID
   * @return
   */
  @GetMapping("/getCanLoginFacilities/{userId}")
  public ResponseEntity<?> getCanLoginFacilities(@PathVariable Long userId) {
    return new ResponseEntity<List<UserAuthentication>> (userAccountService.getCanLoginFacilities(userId), HttpStatus.OK);
  }
  // add #12587 スタッフ切替 end
}
