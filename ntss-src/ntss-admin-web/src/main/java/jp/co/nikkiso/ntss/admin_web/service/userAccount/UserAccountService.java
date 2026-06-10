package jp.co.nikkiso.ntss.admin_web.service.userAccount;

import jp.co.nikkiso.ntss.admin_web.request.userAccount.UpdateUserAccountInfoRequest;
import jp.co.nikkiso.ntss.admin_web.response.userAccount.UserAccountResponse;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.UserAuthentication;
import org.json.JSONArray;

import java.util.List;

/**
 * アカウント編集画面のServiceインタフェース.
 */
public interface UserAccountService {

  /**
   * アカウント編集画面のResponse作成.
   *
   * @param userId ユーザーID
   * @return アカウント編集画面のResponse.
   */
  UserAccountResponse createUserAccountResponse(Long userId);

  /**
   * アカウント情報更新処理.
   *
   * @param request APIリクエストボディ
   */
  void updateUserAccountInfo(UpdateUserAccountInfoRequest request);

  /**
   * 指定されたユーザーIDが属する施設内において、指定された表示用ユーザIDと同一表示用ユーザIDを持つレコード数をカウントする.
   * ただし、指定されたユーザーIDと同一レコードに関してはカウント対象外とする.
   *
   * @param dispUserId 表示用ユーザーID
   * @param userId ユーザーID
   * @return レコード件数
   */
  long selectDuplicateCount(String dispUserId, Long userId);

  /**
   * 入力された「現在のパスワード」がDB上のパスワードと合っているか確認する.
   * @param CurrentPassword 更新件数
   * @param userId ユーザーID
   * @return 合っていればtrue
   */
  Boolean isMatchCurrentPassword(String CurrentPassword, Long userId);

  /**
   * パスワード履歴の更新.
   * @param encordedPassword エンコードされたパスワード
   * @param userId ユーザーID
   * @return パスワード履歴(JSON配列)
   */
  JSONArray updatePasswordHistory(String encordedPassword, Long userId);

  /**
   * パスワードが利用できるかチェックする.
   *
   * @param userId ユーザID
   * @param newPassword 入力された新しいパスワード
   * @param facilityCd 施設コード
   * @return 利用可能であればtrue
   */
  Boolean isAvailablePassword(Long userId, String newPassword, String facilityCd);
  /*add FNSI-改修内容全体の合否が俯瞰できるように修正 任 start*/
  List<MstPersonalUser> selectAllUser(String facilityCd);
  /*add FNSI-改修内容全体の合否が俯瞰できるように修正 任 end*/
  /* del by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
  // // add #6587 利用者マスタで使用許可機能を編集した時にメッセージが出る場合とでない場合がある 王永吉 start
  // void doInginSoming(boolean loginFlag, MstUser userMiddle, Long userId);
  // MstUser getUserMiddle(Long userId);
  // // add #6587 利用者マスタで使用許可機能を編集した時にメッセージが出る場合とでない場合がある 王永吉 end
  /* del by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
  // add #12587 スタッフ切替 start
  /**
   * ログイン可能な施設取得
   * @param userId
   * @return
   */
  List<UserAuthentication> getCanLoginFacilities(Long userId);

  String getHashByCd(String facilityCd);

  void updateOptStatus(String status,long userId);

  String getGroupId(long userId);
  // add #12587 スタッフ切替 end
}
