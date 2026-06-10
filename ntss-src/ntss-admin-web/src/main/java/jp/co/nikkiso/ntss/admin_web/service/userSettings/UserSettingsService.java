package jp.co.nikkiso.ntss.admin_web.service.userSettings;

import java.util.List;

import jp.co.nikkiso.ntss.admin_web.response.UserSettingsResponse;
import jp.co.nikkiso.ntss.core.entity.MstUser;
import jp.co.nikkiso.ntss.core.exception.NotExistException;

/**
 * ユーザー設定のServiceインタフェース.
 */
public interface UserSettingsService {

  /**
   * 文字サイズ更新処理.
   * @param userId ユーザーID
   * @param fontSize 文字サイズ
   * @return 成功フラグとエラーメッセージ
   */
  UserSettingsResponse updateFontSize(Long userId, Integer fontSize);

  /**
   * テーマ更新処理.
   * @param userId ユーザーID
   * @param theme テーマ
   * @return 成功フラグとエラーメッセージ
   */
  UserSettingsResponse updateTheme(Long userId, Integer theme);

  /**
   * メニューバー設定更新処理.
   * @param userId ユーザーID
   * @param isDispMenu メニューバー表示フラグ
   * @param useFunctions 使用機能コードリスト
   * @param initialFunction 初期表示機能コード
   * @return 成功フラグとエラーメッセージ
   */
  UserSettingsResponse updateMenuBar(Long userId, Integer isDispMenu, List<String> useFunctions, String initialFunction);

  /**
   * 個人設定 - デフォルト設定更新処理.
   * @param userId ユーザーID
   * @param defaultSettingStr デフォルト設定
   * @return 成功フラグとエラーメッセージ
   */
  UserSettingsResponse updateDefaultSetting(Long userId, String defaultSettingStr);

  /**
   * 使用可能機能更新処理.
   * @param userId ユーザーID
   * @param useAuthFunctions 使用可能機能コードリスト
   * @param initialFunction 初期表示機能コード
   * @param signoutFlg サインアウトフラグ
   * @return 成功フラグとエラーメッセージ
   */
  UserSettingsResponse updateUseAuthFunctions(Long userId, List<String> useAuthFunctions, String initialFunction, String jobCd, Boolean signoutFlg);

  /**
   * 指定のユーザの、指定の共通設定タブの個人設定値を取得します.
   * @param userId ユーザーID
   * @param tabDefineCd 共通設定タブ定義コード
   * @return 設定項目と設定値情報
   * @throws NotExistException ユーザーIDに該当するレコードが存在しない場合
   */
  List<MstUser.SettingValue> getPersonalSettings(Long userId, Integer tabDefineCd) throws NotExistException;

  /**
   * 指定のユーザの、指定の共通設定タブの個人設定値を更新します.
   * @param userId ユーザーID
   * @param setting 共通設定タブの個人設定値
   * @return 更新結果
   * @throws NotExistException
   */
  boolean updatePersonalSettings(Long userId, MstUser.PersonalSetting setting) throws NotExistException;

  /**
   * 画面フレーム分割更新処理.
   * @param userId ユーザーID
   * @param splitFrame 画面フレーム分割
   * @return 成功フラグとエラーメッセージ
   */
  UserSettingsResponse updateSplitFrame(Long userId, Integer splitFrame);

  UserSettingsResponse updatePatShareMode(Long userId, Integer patShareMode);
}
