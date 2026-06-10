package jp.co.nikkiso.ntss.admin_web.request.userAccount;

import lombok.Data;

/**
 * 仮ユーザー情報変更APIのRequest.
 */
@Data
public class AlterProvisionalInfoRequest {

  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * 旧(仮)表示用ユーザーID.
   */
  private String dispUserIdPre;

  /**
   * 新表示用ユーザーID.
   */
  private String dispUserIdNew;

  /**
   * 新パスワード.
   */
  private String userPasswordNew;

  /**
   * 入力ユーザー姓
   */
  private String userLastName;

  /**
   * 入力ユーザー名
   */
  private String userFirstName;

  /**
   * 仮登録ユーザーフラグ
   */
  private Boolean isProvisional;

  /**
   * 個人情報取扱い同意フラグ
   */
  private Boolean isConsent;

}
