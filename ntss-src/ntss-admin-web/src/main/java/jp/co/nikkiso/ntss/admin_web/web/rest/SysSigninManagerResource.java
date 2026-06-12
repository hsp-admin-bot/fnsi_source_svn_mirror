package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.response.sysSigninManager.SysSigninManagerResponse;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.sysSignManager.SysSigninManagerService;
import jp.co.nikkiso.ntss.admin_web.service.userAccount.UserAccountServiceImpl;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.entity.SysSigninManager;
import jp.co.nikkiso.ntss.core.entity.SysSystemManager;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.utils.NtssUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import jp.co.nikkiso.ntss.core.dao.SysSystemManagerDao;
import java.util.regex.Pattern;
import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.ObjectMapper;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

import jakarta.servlet.http.HttpServletRequest;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;

/**
 * サインイン管理のリソースクラス
 */
@RestController
@RequestMapping(Uri.SIGN_IN_MANAGER)
public class SysSigninManagerResource {

  /**
   * {@link SysSigninManagerService}
   */
  @Autowired
  SysSigninManagerService sysSigninManagerService;

  /**
   * {@link LogService}
   */
  @Autowired
  LogService logService;
  // add #6587 利用者マスタで使用許可機能を編集した時にメッセージが出る場合とでない場合がある 王永吉 start
  @Autowired
  private UserAccountServiceImpl serAccountServiceImpl;
  // add #6587 利用者マスタで使用許可機能を編集した時にメッセージが出る場合とでない場合がある 王永吉 end
  @Autowired
  private SysSystemManagerDao sysSystemManagerDao;
  /**
  * サインイン管理を登録する.
   *
   * @param request リクエスト情報
  */
  @PutMapping("/insert")
  public ResponseEntity<?> insertSysSigninManager(@RequestBody SysSigninManager request) {
    // ログ出力
    outputLog(LogLevel.DEBUG, "サインイン管理登録API実行");

    try {
      // レスポンス生成
      sysSigninManagerService.insertSysSigninManager(request);
      return new ResponseEntity<>(new SysSigninManagerResponse(), HttpStatus.OK);
    } catch (Exception e) {
      String errorMessage = "サインイン管理の登録に失敗しました.";
      outputLog(LogLevel.ERROR, errorMessage + e.getLocalizedMessage());
      return new ResponseEntity<>(new SysSigninManagerResponse(errorMessage),
          HttpStatus.BAD_REQUEST);
    } finally {
      // ログ出力
      outputLog(LogLevel.DEBUG, "サインイン管理登録API終了");
    }
  }

  /* add by chamaojia 2025-03-18 [11587] add automatic logon --start */
  /**
   * automatic logon
   * @param userId
   * @param facilityCd
   * @return
   */
  @GetMapping("/autoLogin")
  public ResponseEntity<?> getLoginInfo(@RequestParam("userId") String userId
          , @RequestParam("facilityCd") String facilityCd,
          // #11205 -ペンテスト2－4認可制御の不備  add 20260512 start
          @AuthenticationPrincipal NtssUser ntssUser
          // #11205 -ペンテスト2－4認可制御の不備  add 20260512 end
) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260512 start
    // 施設越え抑止: 既に認証済みセッションがある場合のみ有効（未認証は Security 側で 401、本 if はスキップ）
    if (ntssUser != null && !ntssUser.isNkkAdminUser() && facilityCd != null
        && !facilityCd.equals(ntssUser.getFacilityCd())) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260512 end

    try {
      return new ResponseEntity<>(sysSigninManagerService.getAutoLoginInfo(userId, facilityCd), HttpStatus.OK);
    } catch (Exception e) {
      outputLog(LogLevel.ERROR, NtssUtils.ExcetionStackTraceToString(e));
      return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.BAD_REQUEST);
    }
  }
  /* add by chamaojia 2025-03-18 [11587] add automatic logon --end */

  /**
   * 端末固有文字列に該当するサインイン管理を取得する.
   *
   * @param terminalUniqueString 端末固有文字列
   * @return 端末固有文字列に該当するサインイン管理
   */
  @GetMapping("/select/term/{terminalUniqueString}")
  public ResponseEntity<?> getByTerminalUniqueString(@PathVariable("terminalUniqueString") String terminalUniqueString) {
    // ログ出力
    outputLog(LogLevel.DEBUG, "サインイン管理検索API実行(端末固有文字列):" + terminalUniqueString);
    try {
      // del #6587 利用者マスタで使用許可機能を編集した時にメッセージが出る場合とでない場合がある 王永吉 start
      // add #6587 利用者マスタで使用許可機能を編集した時にメッセージが出る場合とでない場合がある 王永吉 start
//      serAccountServiceImpl.doInginSoming(true, null);
      // add #6587 利用者マスタで使用許可機能を編集した時にメッセージが出る場合とでない場合がある 王永吉 end
      // del #6587 利用者マスタで使用許可機能を編集した時にメッセージが出る場合とでない場合がある 王永吉 end
      // エンティティ生成
      SysSigninManager sysSigninManager = new SysSigninManager();
      sysSigninManager.setTerminalUniqueString(terminalUniqueString);
      // レスポンス生成
      List<SysSigninManager> sysSigninManagerList = sysSigninManagerService.getByParam(sysSigninManager);
      return new ResponseEntity<>(sysSigninManagerList, HttpStatus.OK);
    } catch (Exception e) {
      String errorMessage = "サインイン管理検索API実行(端末固有文字列)に失敗しました.";
      outputLog(LogLevel.ERROR, errorMessage + e.getLocalizedMessage());
      return new ResponseEntity<>((org.springframework.http.HttpHeaders) null,
        HttpStatus.BAD_REQUEST);
    } finally {
      // ログ出力
      outputLog(LogLevel.DEBUG, "サインイン管理検索API終了(端末固有文字列)");
    }
  }

  /**
   * 利用者IDに該当するサインイン管理を取得する.
   *
   * @param userId 利用者ID
   * @return 利用者IDに該当するサインイン管理
   */
  @GetMapping("/select/user/{userId}")
  public ResponseEntity<?> getByUserId(@PathVariable("userId") Long userId,
      // #11205 -ペンテスト2－4認可制御の不備  mod 20260512 start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  mod 20260512 end
) {
    // ログ出力
    outputLog(LogLevel.DEBUG, "サインイン管理検索API実行(利用者ID):" + userId.toString());
    try {
      // エンティティ生成
      SysSigninManager sysSigninManager = new SysSigninManager();
      sysSigninManager.setUserId(userId);
      // レスポンス生成
      List<SysSigninManager> sysSigninManagerList = sysSigninManagerService.getByParam(sysSigninManager);
      // #11205 -ペンテスト2－4認可制御の不備  mod 20260512 start
      if (ntssUser == null) {
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
      if (!ntssUser.isNkkAdminUser()) {
        for (SysSigninManager signinManager : sysSigninManagerList) {
          if (signinManager.getFacilityCd() != null && !signinManager.getFacilityCd().equals(ntssUser.getFacilityCd())) {
            return new ResponseEntity<>(HttpStatus.FORBIDDEN);
          }
        }
      }
      // #11205 -ペンテスト2－4認可制御の不備  mod 20260512 end
      return new ResponseEntity<>(sysSigninManagerList, HttpStatus.OK);
    } catch (Exception e) {
      String errorMessage = "サインイン管理検索API実行(利用者ID)に失敗しました.";
      outputLog(LogLevel.ERROR, errorMessage + e.getLocalizedMessage());
      return new ResponseEntity<>((org.springframework.http.HttpHeaders) null,
        HttpStatus.BAD_REQUEST);
    } finally {
      // ログ出力
      outputLog(LogLevel.DEBUG, "サインイン管理検索API終了(利用者ID)");
    }
  }

  /**
   * サインイン画面表示時に、別タブで既にセッションがはられているかを確認する.
   * @return HttpStatus 200
   */
  @GetMapping("/check/sessiontimeout")
  public ResponseEntity<?> rtnResponse(HttpServletRequest request) {
    if (request.getRequestedSessionId() != null && !request.isRequestedSessionIdValid()) {
      // サインインされていない
      return new ResponseEntity<>(false, HttpStatus.OK);
    } else {
      // サインインされている
      return new ResponseEntity<>(true, HttpStatus.OK);
    }
  }

  /**
   * 端末固有文字列に該当するサインイン管理を削除する.
   *
   * @param terminalUniqueString 端末固有文字列
   * @return 削除した件数
   */
  @PutMapping("/delete/{terminalUniqueString}")
  public ResponseEntity<?> deleteByTerminalUniqueString(
    @PathVariable("terminalUniqueString") String terminalUniqueString
  ) {
    // ログ出力
    outputLog(LogLevel.DEBUG, "サインイン管理削除API実行");

    try {
      // エンティティ生成
      SysSigninManager sysSigninManager = new SysSigninManager();
      sysSigninManager.setTerminalUniqueString(terminalUniqueString);
      // レスポンス生成
      sysSigninManagerService.deleteByParam(sysSigninManager);
      return new ResponseEntity<>(new SysSigninManagerResponse(), HttpStatus.OK);
    } catch (Exception e) {
      String errorMessage = "サインイン管理の削除に失敗しました.";
      outputLog(LogLevel.ERROR, errorMessage + e.getLocalizedMessage());
      return new ResponseEntity<>(new SysSigninManagerResponse(errorMessage),
        HttpStatus.BAD_REQUEST);
    } finally {
      // ログ出力
      outputLog(LogLevel.DEBUG, "サインイン管理削除API終了");
    }
  }

  /**
   * サインイン画面、サイドコンテンツエリア展開IFの背景色のカラーコードを取得する
   *
   * @return 背景色のカラーコード
   */
  @GetMapping("/color_code")
  public ResponseEntity<?> getBackgroundColorCode() {
    // ログ出力
    outputLog(LogLevel.DEBUG, "背景色のカラーコード取得処理実行");
    try {
      String colorCode = null;
      List<SysSystemManager> systemDefine = sysSystemManagerDao.selectByCtlNo(2);
      if (systemDefine == null || systemDefine.size() == 0) {
        return new ResponseEntity<>(colorCode, HttpStatus.OK);
      }
      final String COLOR_CODE_WHITE = "#FFFFFF";
      String regex = "^#([A-Fa-f0-9]{6})$";
      Pattern pattern = Pattern.compile(regex);
      ObjectMapper objectMapper = new ObjectMapper();
      Map<String, String> colorInfoMap = objectMapper.readValue(systemDefine.get(0).getValue(), new TypeReference<Map<String, String>>() {});
      if(colorInfoMap.get("color") == null || !pattern.matcher(colorInfoMap.get("color")).matches()
      || COLOR_CODE_WHITE.equals(colorInfoMap.get("color").toUpperCase())) {
        return new ResponseEntity<>(colorCode, HttpStatus.OK);
      }
      colorCode = colorInfoMap.get("color");
      return new ResponseEntity<>(colorCode, HttpStatus.OK);
    } catch (Exception e) {
      outputLog(LogLevel.ERROR, NtssUtils.ExcetionStackTraceToString(e));
      return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.BAD_REQUEST);
    } finally {
      // ログ出力
      outputLog(LogLevel.DEBUG, "背景色のカラーコード取得処理終了");
    }
  }

  /**
   * ログ出力する
   * @param message 出力メッセージ
   */
  private void outputLog(LogLevel level, String message) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(message);
    logService.log(level, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
  }

}
