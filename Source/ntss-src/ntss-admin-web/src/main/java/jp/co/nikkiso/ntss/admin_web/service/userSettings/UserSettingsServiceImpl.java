package jp.co.nikkiso.ntss.admin_web.service.userSettings;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstUser;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.FontSize;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.IsDispMenu;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.IsSplitFrame;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Theme;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage;
import jp.co.nikkiso.ntss.admin_web.response.UserSettingsResponse;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstUserDao;
import org.springframework.transaction.annotation.Transactional;
import tools.jackson.databind.ObjectMapper;
import tools.jackson.databind.JsonNode;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.sysSignManager.SysSigninManagerService;
import jp.co.nikkiso.ntss.admin_web.service.sysSignManager.SysSigninManagerService.ForceSignOutReason;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import static java.util.Collections.emptyList;
import static org.springframework.util.CollectionUtils.isEmpty;

/**
 * ユーザー設定Serviceの実装クラス.
 */
@Service
@Slf4j
public class UserSettingsServiceImpl implements UserSettingsService {

  /**
   * 利用者マスタのDaoインタフェース.
   */
  @Autowired
  private MstUserDao mstUserDao;

  /**
   * ユーザマスタのDaoインタフェース.
   */
  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;

  /**
   * サインイン管理のServiceインターフェース.
   */
  @Autowired
  private SysSigninManagerService sysSigninManagerService;

  /**
  * ロギングのServiceインタフェース.
  */
  @Autowired
  private LogService logService;
  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public UserSettingsResponse updateFontSize(Long userId, Integer fontSize) {

    // 数値チェック
    boolean isCorrect = Arrays.asList(
      FontSize.SMALL,
      FontSize.MEDIUM,
      FontSize.LARGE,
      FontSize.EXTRA_LARGE).stream().anyMatch(i -> i == fontSize);
    // 不正な値が指定された場合、エラーメッセージを設定したレスポンスを返却
    if (!isCorrect) {
      return new UserSettingsResponse(AdminWebMessage.Error.FONT_SIZE_INCORRECT.getMessage());
    }

    // ユーザー情報取得Dao呼び出し
    MstUser user = mstUserDao.selectById(userId);
    // ユーザーを取得できなかった場合、エラーメッセージを設定したレスポンスを返却
    if (user == null) {
      return new UserSettingsResponse(AdminWebMessage.Error.USER_ID_NOT_FOUND.getMessage());
    }

    // 指定された文字サイズを設定
    MstUser.UserSettings settings = user.getUserSettings();
    // ユーザー設定カラムがnullだった場合は新たに設定する
    if (settings == null) {
      settings = new MstUser.UserSettings();
    }
    settings.setFontSize(fontSize);
    user.setUserSettings(settings);

    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(user,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    // 更新Dao呼び出し
    int updateResult = mstUserDao.updateUserSettings(user);
    // 更新結果=1件以外の場合、エラーメッセージを設定したレスポンスを返却
    if (updateResult != 1) {
      return new UserSettingsResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage());
    }

    // 成功レスポンス返却
    return new UserSettingsResponse();
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public UserSettingsResponse updateTheme(Long userId, Integer theme) {
    // 数値チェック
    boolean isCorrect = Arrays.asList(
      Theme.WHITE,
      Theme.BLACK).stream().anyMatch(i -> i == theme);
    // 不正な値が指定された場合、エラーメッセージを設定したレスポンスを返却
    if (!isCorrect) {
      return new UserSettingsResponse(AdminWebMessage.Error.THEME_INCORRECT.getMessage());
    }

    // ユーザー情報取得Dao呼び出し
    MstUser user = mstUserDao.selectById(userId);
    // ユーザーを取得できなかった場合、エラーメッセージを設定したレスポンスを返却
    if (user == null) {
      return new UserSettingsResponse(AdminWebMessage.Error.USER_ID_NOT_FOUND.getMessage());
    }

    // 指定されたテーマを設定
    MstUser.UserSettings settings = user.getUserSettings();
    // ユーザー設定カラムがnullだった場合は新たに設定する
    if (settings == null) {
      settings = new MstUser.UserSettings();
    }
    settings.setTheme(theme);
    user.setUserSettings(settings);

    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(user,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    // 更新Dao呼び出し
    int updateResult = mstUserDao.updateUserSettings(user);
    // 更新結果=1件以外の場合、エラーメッセージを設定したレスポンスを返却
    if (updateResult != 1) {
      return new UserSettingsResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage());
    }

    // 成功レスポンス返却
    return new UserSettingsResponse();
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public UserSettingsResponse updateMenuBar(Long userId, Integer isDispMenu, List<String> useFunctions, String initialFunction) {
    // 数値チェック
    boolean isCorrectDispMenu = Arrays.asList(
      IsDispMenu.HIDDEN,
      IsDispMenu.VISIBLE).stream().anyMatch(i -> i == isDispMenu);

    // 使用機能コードが空もしくはNullの場合は、空リストにする
    // 重複した使用機能コードは排除する
    List<String> distinctFunctions = isEmpty(useFunctions) ? emptyList() : useFunctions.stream().distinct().collect(Collectors.toList());

    // 初期表示機能コードが規定の値かチェック（nullまたは空文字列は許容）
    initialFunction = Optional.ofNullable(initialFunction).orElse(MstUser.UserSettings.INITIAL_FUNCTION_DEFAULT);

    // 不正な値が指定された場合、エラーメッセージを設定したレスポンスを返却
    // メニュー表示フラグの不正
    if (!isCorrectDispMenu) {
      return new UserSettingsResponse(AdminWebMessage.Error.IS_DISP_MENU_INCORRECT.getMessage());
    }

    // ユーザー情報取得Dao呼び出し
    MstUser user = mstUserDao.selectById(userId);
    // ユーザーを取得できなかった場合、エラーメッセージを設定したレスポンスを返却
    if (user == null) {
      return new UserSettingsResponse(AdminWebMessage.Error.USER_ID_NOT_FOUND.getMessage());
    }

    // 指定されたメニューバー表示フラグを設定
    MstUser.UserSettings settings = user.getUserSettings();
    // ユーザー設定カラムがnullだった場合は新たに設定する
    if (settings == null) {
      settings = new MstUser.UserSettings();
    }
    settings.setIsDispMenu(isDispMenu);
    settings.setUseFunctions(distinctFunctions);
    settings.setInitialFunction(initialFunction);

    user.setUserSettings(settings);

    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(user,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    // 更新Dao呼び出し
    int updateResult = mstUserDao.updateUserSettings(user);
    // 更新結果=1件以外の場合、エラーメッセージを設定したレスポンスを返却
    if (updateResult != 1) {
      return new UserSettingsResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage());
    }

    // 成功レスポンス返却
    return new UserSettingsResponse();
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public UserSettingsResponse updateDefaultSetting(Long userId, String defaultSettingStr) {
    // ユーザー情報取得Dao呼び出し
    MstUser user = mstUserDao.selectById(userId);
    // ユーザーを取得できなかった場合、エラーメッセージを設定したレスポンスを返却
    if (user == null) {
      return new UserSettingsResponse(AdminWebMessage.Error.USER_ID_NOT_FOUND.getMessage());
    }

    // デフォルト設定データを適用
    MstUser.UserSettings settings = user.getUserSettings();
    // ユーザー設定カラムがnullだった場合は新たに設定する
    if (settings == null) {
      settings = new MstUser.UserSettings();
    }
    ObjectMapper mapper = new ObjectMapper();
    JsonNode defautSetting = mapper.createObjectNode();
    try {
      defautSetting = mapper.readTree(defaultSettingStr);
    } catch (Exception e) {
      return new UserSettingsResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage());
    }
    settings.setDefaultSetting(defautSetting);
    user.setUserSettings(settings);

    // 更新Dao呼び出し
    int updateResult = mstUserDao.updateUserSettings(user);
    // 更新結果=1件以外の場合、エラーメッセージを設定したレスポンスを返却
    if (updateResult != 1) {
      return new UserSettingsResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage());
    }

    // 成功レスポンス返却
    return new UserSettingsResponse();
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public UserSettingsResponse updateUseAuthFunctions(Long userId, List<String> useAuthFunctions, String initialFunction, String jobCd, Boolean signoutFlg) {
    // 使用可能機能コードが空もしくはNullの場合は、空リストにする
    // 重複した使用可能機能コードは排除する
    List<String> distinctFunctions = isEmpty(useAuthFunctions) ? emptyList() : useAuthFunctions.stream().distinct().collect(Collectors.toList());

    // 初期表示機能コードが規定の値かチェック（nullまたは空文字列は許容）
    initialFunction = Optional.ofNullable(initialFunction).orElse(MstUser.UserSettings.INITIAL_FUNCTION_DEFAULT);

    // ユーザー情報取得Dao呼び出し
    MstUser user = mstUserDao.selectById(userId);
    // ユーザーを取得できなかった場合、エラーメッセージを設定したレスポンスを返却
    if (user == null) {
      return new UserSettingsResponse(AdminWebMessage.Error.USER_ID_NOT_FOUND.getMessage());
    }

    // 指定されたメニューバー表示フラグを設定
    MstUser.UserSettings settings = user.getUserSettings();
    // ユーザー設定カラムがnullだった場合は新たに設定する
    if (settings == null) {
      settings = new MstUser.UserSettings();
    }
    // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou start
    if (signoutFlg) {
      List<String> authorizedFunctions = settings.getAuthorizedFunctions();
      if (authorizedFunctions == null) {
        authorizedFunctions = new ArrayList<String>();
      }
      boolean isAdd = distinctFunctions.containsAll(authorizedFunctions);
      // 許可機能・拡張機能が増えた場合はサインアウトさせない。
      if (isAdd) {
        signoutFlg = false;
      }
    }
    // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou end
    // 利用者マスタ＞使用許可機能では authorized_functions のみ更新する。
    // use_functions はメニューバー設定の保存値なので、ここでは変更しない。
    settings.setAuthorizedFunctions(distinctFunctions);
    settings.setInitialFunction(initialFunction);

    user.setUserSettings(settings);

    // 更新Dao呼び出し
    int updateResult = mstUserDao.updateUserSettings(user);
    // 更新結果=1件以外の場合、エラーメッセージを設定したレスポンスを返却
    if (updateResult != 1) {
      return new UserSettingsResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage());
    }

    // 職種を更新する
    MstPersonalUser mstPersonalUser = new MstPersonalUser()
    {
      {
        setUserId(userId);
        setJobCd(jobCd);
      }
    };
    updateResult = mstPersonalUserDao.updateUserJob(mstPersonalUser);
    // 更新結果=1件以外の場合、エラーメッセージを設定したレスポンスを返却
    if (updateResult != 1) {
      return new UserSettingsResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage());
    }

    if (signoutFlg) {
      // 権限を変更した利用者をサインアウトさせる
      // mod #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou start
      // sysSigninManagerService.signOutUser(userId);
      sysSigninManagerService.signOutUserForMultiServer(user.getFacilityCd(), userId,
        ForceSignOutReason.USE_AUTH_FUNCTION_CHANGED);
      // mod #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou end
    }

    // 成功レスポンス返却
    return new UserSettingsResponse();
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstUser.SettingValue> getPersonalSettings(Long userId, Integer tabDefineCd) {
    // ユーザー情報取得Dao呼び出し
    MstUser user = mstUserDao.selectById(userId);

    if (user == null) {
    	EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There is no MstUser.");
      eventLogMessage.setSqlIdentification("(userId = "+ userId +")");
      logService.log(LogLevel.DEBUG, eventLogMessage,null ,SERVICE_NAME.REMS, "MstUserDao/selectById");
      throw new NotExistException("存在しない利用者マスタのユーザーIDを指定されています。");
    }

    // 指定の共通設定タブコードの設定値情報をフィルタリング
    MstUser.PersonalSetting personalSetting =
      user.getUserSettings().getPersonalSettings().stream()
        .filter(e -> e.getTabDefineCd().equals(tabDefineCd))
        .findFirst()
        .orElse(new MstUser.PersonalSetting());
    return personalSetting.getValues();
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public boolean updatePersonalSettings(Long userId, MstUser.PersonalSetting setting) throws NotExistException {
    // ユーザー情報取得Dao呼び出し
    MstUser user = mstUserDao.selectById(userId);

    if (user == null) {
    	EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There is no MstUser.");
      eventLogMessage.setSqlIdentification("(userId = "+ userId +")");
      logService.log(LogLevel.DEBUG, eventLogMessage,null,SERVICE_NAME.REMS, "MstUserDao/selectById");
      throw new NotExistException("存在しない利用者マスタのユーザーIDを指定されています。");
    }

    // 指定されたタブ定義コードの設定値情報を取得
    MstUser.UserSettings userSettings = user.getUserSettings();
    if (userSettings == null) {
      // ユーザー設定カラムがnullだった場合は新たに設定する
      userSettings = new MstUser.UserSettings();
    }
    List<MstUser.PersonalSetting> personalSettings = userSettings.getPersonalSettings();
    MstUser.PersonalSetting personalSetting = personalSettings.stream()
        .filter(e -> e.getTabDefineCd().equals(setting.getTabDefineCd()))
        .findFirst()
        .orElse(null);
    if (personalSetting == null) {
      personalSetting = new MstUser.PersonalSetting() {
        {
          setTabDefineCd(setting.getTabDefineCd());
        }
      };
      personalSettings.add(personalSetting);
    }
    personalSetting.setValues(setting.getValues());
    userSettings.setPersonalSettings(personalSettings);

    // 更新Dao呼び出し
    return mstUserDao.updateUserSettings(user) == 1;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public UserSettingsResponse updateSplitFrame(Long userId, Integer splitFrame) {
    // 数値チェック
    boolean isCorrect = Arrays.asList(
      IsSplitFrame.OFF,
      IsSplitFrame.ON).stream().anyMatch(i -> i == splitFrame);
    // 不正な値が指定された場合、エラーメッセージを設定したレスポンスを返却
    if (!isCorrect) {
      return new UserSettingsResponse(AdminWebMessage.Error.SPLIT_FRAME_INCORRECT.getMessage());
    }

    // ユーザー情報取得Dao呼び出し
    MstUser user = mstUserDao.selectById(userId);
    // ユーザーを取得できなかった場合、エラーメッセージを設定したレスポンスを返却
    if (user == null) {
      return new UserSettingsResponse(AdminWebMessage.Error.USER_ID_NOT_FOUND.getMessage());
    }

    // 指定されたテーマを設定
    MstUser.UserSettings settings = user.getUserSettings();
    // ユーザー設定カラムがnullだった場合は新たに設定する
    if (settings == null) {
      settings = new MstUser.UserSettings();
    }
    settings.setIsSplitFrame(splitFrame);
    user.setUserSettings(settings);

    // 更新Dao呼び出し
    int updateResult = mstUserDao.updateUserSettings(user);
    // 更新結果=1件以外の場合、エラーメッセージを設定したレスポンスを返却
    if (updateResult != 1) {
      return new UserSettingsResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage());
    }

    // 成功レスポンス返却
    return new UserSettingsResponse();
  }
  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public UserSettingsResponse updatePatShareMode(Long userId, Integer patShareMode) {

    // 値チェック
    boolean isCorrect = patShareMode != null && (patShareMode == 0 || patShareMode == 1);

    // 不正な値が指定された場合、エラーメッセージを設定したレスポンスを返却
    if (!isCorrect) {
      return new UserSettingsResponse(AdminWebMessage.Error.PAT_SHARE_SETTING_INCORRECT.getMessage());
    }

    // ユーザー情報取得Dao呼び出し
    MstUser user = mstUserDao.selectById(userId);
    // ユーザーを取得できなかった場合、エラーメッセージを設定したレスポンスを返却
    if (user == null) {
      return new UserSettingsResponse(AdminWebMessage.Error.USER_ID_NOT_FOUND.getMessage());
    }

    // 指定された文字サイズを設定
    MstUser.UserSettings settings = user.getUserSettings();
    // ユーザー設定カラムがnullだった場合は新たに設定する
    if (settings == null) {
      settings = new MstUser.UserSettings();
    }
    settings.setPatShareMode(patShareMode);
    user.setUserSettings(settings);

    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(user,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // 更新Dao呼び出し
    int updateResult = mstUserDao.updateUserSettings(user);
    // 更新結果=1件以外の場合、エラーメッセージを設定したレスポンスを返却
    if (updateResult != 1) {
      return new UserSettingsResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage());
    }

    // 成功レスポンス返却
    return new UserSettingsResponse();
  }
}
