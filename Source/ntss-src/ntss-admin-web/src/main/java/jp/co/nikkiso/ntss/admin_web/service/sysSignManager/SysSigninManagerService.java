package jp.co.nikkiso.ntss.admin_web.service.sysSignManager;

import jp.co.nikkiso.ntss.admin_web.response.LoginResponse;
import jp.co.nikkiso.ntss.core.entity.SysSigninManager;

import java.util.List;
import java.util.Map;

/**
 * サインイン管理のサービスインタフェース.
 */
public interface SysSigninManagerService {

  enum ForceSignOutReason {
    SESSION_TIMEOUT("セッションタイムアウト"),
    USER_AUTHORITY_CHANGED("利用者権限変更"),
    USE_AUTH_FUNCTION_CHANGED("使用許可機能変更"),
    MULTI_BROWSER_SIGN_IN_PROHIBITED("複数ブラウザ同時サインイン禁止"),
    ACCOUNT_LOCK("サインイン連続失敗によるアカウントロック"),
    USER_DELETED("アカウント削除");

    private final String logReason;

    ForceSignOutReason(String logReason) {
      this.logReason = logReason;
    }

    public String getLogReason() {
      return logReason;
    }

    public static ForceSignOutReason fromName(String name, ForceSignOutReason defaultReason) {
      if (name == null) {
        return defaultReason;
      }
      try {
        return ForceSignOutReason.valueOf(name);
      } catch (IllegalArgumentException e) {
        return defaultReason;
      }
    }
  }

  /**
   * 登録されているサインイン管理を全て出力する.
   * @return 登録されている全サインイン管理のリスト
   */
  List<SysSigninManager> getAll();

  /**
   * サインイン管理を登録する.
   *
   * @param sysSigninManager サインイン管理エンティティ
   * @return 登録件数（正常終了の場合、1が返却される.）
   */
  int insertSysSigninManager(SysSigninManager sysSigninManager);

  /**
   * 条件に該当するサインイン管理を取得する.
   *
   * @param sysSigninManager サインイン管理エンティティ
   * @return 該当するサインイン情報のリスト
   *         該当データがない場合には空のリストが返却される.
   */
  List<SysSigninManager> getByParam(SysSigninManager sysSigninManager);

  /**
   * 条件に該当するサインイン管理を削除する.
   *
   * @param sysSigninManager サインイン管理エンティティ
   * @return 削除件数
   */
  int deleteByParam(SysSigninManager sysSigninManager);

  /**
   * 条件に該当するサインイン管理を削除する(指定端末以外の同一利用者の情報を削除).
   *
   * @param userId 利用者ID
   * @param terminalUniqueString 端末固有ID
   * @return 削除件数
   */
  int deleteByUserId(Long userId, String terminalUniqueString);

  /**
   * 指定利用者のセッションを無効化（タイムアウト）し、該当するサインイン管理を削除する.
   *
   * @param userId 利用者ID
   */
  void signOutUser(Long userId);

  /**
   * 指定利用者のセッションを無効化（タイムアウト）し、強制サインアウト理由をイベントログに出力する.
   *
   * @param userId 利用者ID
   * @param reason 強制サインアウト理由
   */
  void signOutUser(Long userId, ForceSignOutReason reason);

  // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou start
  /**
   * サインアウト
   *
   * @param facilityCd
   * @param userId
   */
  void signOutUserForMultiServer(String facilityCd, Long userId);

  /**
   * サインアウト
   *
   * @param facilityCd
   * @param userId
   * @param reason 強制サインアウト理由
   */
  void signOutUserForMultiServer(String facilityCd, Long userId, ForceSignOutReason reason);
  // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou end
  // add #10160 複数端末同時サインイン無効時の強制サインアウトが動作しない。 dou start
  /**
   * 自分自身以外のサインアウト
   *
   * @param params
   */
  void signOutAnotherForMultiServer(Map<String, String> params);

  /**
   * 自分自身以外のサインアウト
   *
   * @param params
   * @param reason 強制サインアウト理由
   */
  void signOutAnotherForMultiServer(Map<String, String> params, ForceSignOutReason reason);
  // add #10160 複数端末同時サインイン無効時の強制サインアウトが動作しない。 dou end

  /* add by chamaojia 2025-03-18 [11587] add automatic logon --start */
  /**
   * obtain the login person information for automatic login
   * @param userId
   * @param facilityCd
   * @return
   */
  LoginResponse getAutoLoginInfo(String userId, String facilityCd);
  /* add by chamaojia 2025-03-18 [11587] add automatic logon --end */
}
