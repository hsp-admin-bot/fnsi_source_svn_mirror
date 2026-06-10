package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.request.userSettings.AlterPatShareModeRequest;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.core.entity.MstUser;
import jp.co.nikkiso.ntss.core.entity.SysFunction;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage;
import jp.co.nikkiso.ntss.admin_web.request.userSettings.AlterFontSizeRequest;
import jp.co.nikkiso.ntss.admin_web.request.userSettings.AlterMenuBarRequest;
import jp.co.nikkiso.ntss.admin_web.request.userSettings.AlterSplitFrameRequest;
import jp.co.nikkiso.ntss.admin_web.request.userSettings.AlterThemeRequest;
import jp.co.nikkiso.ntss.admin_web.request.userSettings.AlterUseAuthFunctionsRequest;
import jp.co.nikkiso.ntss.admin_web.response.UserSettingsResponse;
import jp.co.nikkiso.ntss.admin_web.service.MstInfoService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.userSettings.UserSettingsService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;


/**
 * ユーザ設定のResourceクラス.
 */
@RestController
@RequestMapping(Uri.USER_SETTINGS)
@Slf4j
public class UserSettingsResource {

  /**
   * ユーザー設定Service.
   */
  @Autowired
  private UserSettingsService userSettingsService;

  /**
   * マスタ系のResourceクラス
   */
  @Autowired
  MstInfoService mstInfoService;

  @Autowired
  LogService logService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End
  /**
   * 文字サイズ変更.
   *
   * @param request 文字サイズ変更のRequest
   * @return response
   */
  @PutMapping("/font_size")
  public ResponseEntity<?>  alterFontSize(
    @RequestBody AlterFontSizeRequest request) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.USER_SETTINGS + "/font_size";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),"", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    // 更新処理
    UserSettingsResponse response = userSettingsService.updateFontSize(request.getUserId(), request.getFontSize());

    // Httpステータスコード振分け
    HttpStatus httpStatus = HttpStatus.OK;
    String errorMessage = response.errorMessage;
    if (errorMessage != null) {
      // エラーメッセージに紐づくHttpステータスコード取得
      httpStatus = AdminWebMessage.Error.getHttpStatus(errorMessage);
    }

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(response, httpStatus);

  }

  /**
   * テーマ切替.
   *
   * @param request テーマ切替のRequest
   * @return response
   */
  @PutMapping("/theme")
  public ResponseEntity<?>  alterTheme(@RequestBody AlterThemeRequest request) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.USER_SETTINGS + "/theme";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),"", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    // ログ出力
    // 更新処理
    UserSettingsResponse response = userSettingsService.updateTheme(request.getUserId(), request.getTheme());

    // Httpステータスコード振分け
    HttpStatus httpStatus = HttpStatus.OK;
    String errorMessage = response.errorMessage;
    if (errorMessage != null) {
      // エラーメッセージに紐づくHttpステータスコード取得
      httpStatus = AdminWebMessage.Error.getHttpStatus(errorMessage);
    }

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(response, httpStatus);
  }

  /**
   * メニューバー表示設定.
   *
   * @param request メニューバー表示設定のRequest
   * @return response
   */
  @PutMapping("/menu_bar")
  public ResponseEntity<?> alterMenuBar(@RequestBody AlterMenuBarRequest request) {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.USER_SETTINGS + "/menu_bar";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),"", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    // ログ出力
    // 更新処理
    UserSettingsResponse response = userSettingsService.updateMenuBar(request.getUserId(), request.getIsDispMenu(), request.getUseFunctions(), request.getInitialFunction());

    // Httpステータスコード振分け
    HttpStatus httpStatus = HttpStatus.OK;
    String errorMessage = response.errorMessage;
    if (errorMessage != null) {
      // エラーメッセージに紐づくHttpステータスコード取得
      httpStatus = AdminWebMessage.Error.getHttpStatus(errorMessage);
    }

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(response, httpStatus);
  }

  /**
   * 患者共有設定変更.
   *
   * @param request 患者共有設定変更のRequest
   * @return response
   */
  @PutMapping("/pat_share_mode")
  public ResponseEntity<?>  alterPatShareMode(
    @RequestBody AlterPatShareModeRequest request,
    @AuthenticationPrincipal NtssUser ntssUser) {

    String mappingUrl = Uri.USER_SETTINGS + "/pat_share_mode";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),"", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);

    // 更新処理
    UserSettingsResponse response = userSettingsService.updatePatShareMode(request.getUserId(), request.getPatShareMode());

    // Httpステータスコード振分け
    HttpStatus httpStatus = HttpStatus.OK;
    String errorMessage = response.errorMessage;
    if (errorMessage != null) {
      // エラーメッセージに紐づくHttpステータスコード取得
      httpStatus = AdminWebMessage.Error.getHttpStatus(errorMessage);
    }

    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);

    return new ResponseEntity<>(response, httpStatus);

  }


  /**
   * 使用可能機能設定.
   *
   * @param request 使用可能機能設定のRequest
   * @return response
   */
  @PutMapping("/use_auth_functions")
  public ResponseEntity<?> alterUseAuthFunctions(@RequestBody AlterUseAuthFunctionsRequest request) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.USER_SETTINGS + "/use_auth_functions";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),"", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    // ログ出力
    // 更新処理
    UserSettingsResponse response = userSettingsService.updateUseAuthFunctions(request.getUserId(), request.getUseAuthFunctions(), request.getInitialFunction(), request.getJobCd(), request.getSignoutFlg());

    // Httpステータスコード振分け
    HttpStatus httpStatus = HttpStatus.OK;
    String errorMessage = response.errorMessage;
    if (errorMessage != null) {
      // エラーメッセージに紐づくHttpステータスコード取得
      httpStatus = AdminWebMessage.Error.getHttpStatus(errorMessage);
    }

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(response, httpStatus);
  }

  /**
   * 共通設定タブの個人設定値を取得.
   *
   * @param ntssUser NTSS認証ユーザ
   * @return 表示形式パターンのResponse
   */
  @GetMapping("/personal_settings/{tab_define_cd}")
  public ResponseEntity<?> getPersonalSettings(
    @PathVariable("tab_define_cd") Integer tabDefineCd,
    @AuthenticationPrincipal NtssUser ntssUser) {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.USER_SETTINGS + "/personal_settings";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),"", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      tabDefineCd);
    // wp アプリケーションログの適正化 Add End
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get personal settings");
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    // 表示形式パターンの取得
    List<MstUser.SettingValue> response = userSettingsService.getPersonalSettings(ntssUser.getUserId(), tabDefineCd);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      tabDefineCd);
    // wp アプリケーションログの適正化 Add End

    // レスポンス生成
    return new ResponseEntity<>(response, HttpStatus.OK);
  }


  /**
   * 共通設定タブの個人設定値を更新.
   *
   * @param ntssUser NTSS認証ユーザ
   * @return 表示形式パターンのResponse
   */
  @PutMapping("/personal_settings")
  public ResponseEntity<?> updatePersonalSettings(
    @RequestBody MstUser.PersonalSetting setting,
    @AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.USER_SETTINGS + "/personal_settings";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),"", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
//    // ログ出力
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage("REST request to put personal settings");
//    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    // 表示形式パターンの取得
    boolean result = userSettingsService.updatePersonalSettings(ntssUser.getUserId(), setting);
    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    // レスポンス生成
    return new ResponseEntity<>(null, result ? HttpStatus.OK : HttpStatus.INTERNAL_SERVER_ERROR);
  }

  /**
   * 画面フレーム分割設定.
   *
   * @param request 画面フレーム分割設定のRequest
   * @return response
   */
  @PutMapping("/split_frame")
  public ResponseEntity<?> alterSplitFrame(@RequestBody AlterSplitFrameRequest request) {


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.USER_SETTINGS + "/split_frame";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),"", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    // ログ出力
    // 更新処理
    UserSettingsResponse response = userSettingsService.updateSplitFrame(request.getUserId(), request.getIsSplitFrame());

    // Httpステータスコード振分け
    HttpStatus httpStatus = HttpStatus.OK;
    String errorMessage = response.errorMessage;
    if (errorMessage != null) {
      // エラーメッセージに紐づくHttpステータスコード取得
      httpStatus = AdminWebMessage.Error.getHttpStatus(errorMessage);
    }

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(response, httpStatus);
  }

  /**
   * 個人設定 - デフォルト設定の表示順取得用.
   *
   * @return response
   */
  @PutMapping("/default_setting/disp_order")
  public ResponseEntity<?> getDefaultSettingDispOrder(
      @AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.USER_SETTINGS + "/default_setting/disp_order";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),"", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

//    // ログ出力
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage("REST request to get sys_function disp_order info");
//    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    // 更新処理
    List<SysFunction> sysFuncList = mstInfoService.findSysFunctionDispOnlyNoPaging();

    // Httpステータスコード振分け
    HttpStatus httpStatus = HttpStatus.OK;

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(sysFuncList, httpStatus);
  }

  /**
   * 個人設定 - デフォルト設定の更新処理.
   *
   * @param params 個人設定 - デフォルト設定のRequest
   * @return response
   */
  @PutMapping("/default_setting")
  public ResponseEntity<?> alterDefaultSetting(
      @RequestBody Map<String,String> params,
      @AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.USER_SETTINGS + "/default_setting";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),"", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    String defaultSettingStr = params.get("defaultSettingStr");
    // 更新処理
    UserSettingsResponse response = userSettingsService.updateDefaultSetting(ntssUser.getUserId(), defaultSettingStr);

    // Httpステータスコード振分け
    HttpStatus httpStatus = HttpStatus.OK;
    String errorMessage = response.errorMessage;
    if (errorMessage != null) {
      // エラーメッセージに紐づくHttpステータスコード取得
      httpStatus = AdminWebMessage.Error.getHttpStatus(errorMessage);
    }

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(response, httpStatus);
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


