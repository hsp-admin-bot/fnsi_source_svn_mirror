package jp.co.nikkiso.ntss.admin_web.service.userAccount;

import jp.co.nikkiso.ntss.admin_web.response.ProvisionalUserResponse;

/**
 * 仮ユーザー画面のServiceインターフェース.
 */
public interface ProvisionalUserService {
  /**
   * 仮ユーザーを本ユーザーに更新する処理.
   *
   * @param dispUserIdPre 表示用ユーザーID
   * @param dispUserIdNew 新規表示用ユーザーID
   * @param userPasswordNew 新規パスワード
   * @param facilityCd 施設コード
   * @param userId ユーザーID
   * @param userLastName ユーザー姓
   * @param userFirstName ユーザー名
   * @param isProvisional 仮登録時フラグ
   * @param isConsent 個人情報取扱い承認フラグ
   * @return
   */
  ProvisionalUserResponse updateProvisionalUser(
    String dispUserIdPre, String dispUserIdNew, String userPasswordNew, 
    String facilityCd, Long userId, String userLastName, String userFirstName,
    Boolean isProvisional, Boolean isConsent);
}
