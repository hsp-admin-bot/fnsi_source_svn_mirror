package jp.co.nikkiso.ntss.admin_web.service.authority;

import jp.co.nikkiso.ntss.admin_web.service.sysSignManager.SysSigninManagerService.ForceSignOutReason;
import jp.co.nikkiso.ntss.core.exception.NotExistException;

import java.util.List;
import java.util.Map;

/**
 * 利用者権限のServiceインタフェース.
 */
public interface UserAuthorityService {

  /**
   * 許可権限取得.
   *
   * @param userId ユーザーID
   * @return 許可権限のリスト
   * @throws NotExistException ユーザーIDに該当するレコードが存在しない場合
   */
  List<String> getAuthorizedAuthorities(Long userId) throws NotExistException;

  /**
   * 許可権限更新.
   *
   * @param userId      ユーザーID
   * @param authorities 許可権限のリスト
   * @param signoutFlg  サインアウトフラグ
   * @throws NotExistException ユーザーIDに該当するレコードが存在しない場合
   */
  void updateAuthorizedAuthorities(Long userId, List<String> authorities, Boolean signoutFlg) throws NotExistException;

  // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou start
  /**
   * サインアウト
   *
   * @param userId
   */
  void signOut(Long userId);

  /**
   * サインアウト
   *
   * @param userId
   * @param reason 強制サインアウト理由
   */
  void signOut(Long userId, ForceSignOutReason reason);
  // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou end
  // add #10160 複数端末同時サインイン無効時の強制サインアウトが動作しない。 dou start
  /**
   * 自分自身以外のサインアウト
   *
   * @param params
   */
  void signOutAnother(Map<String, String> params);
  // add #10160 複数端末同時サインイン無効時の強制サインアウトが動作しない。 dou end

}
