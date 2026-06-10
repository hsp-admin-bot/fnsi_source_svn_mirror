package jp.co.nikkiso.ntss.admin_web.request.authority;

import lombok.Data;

import java.util.List;

/**
 * 利用者権限APIのRequestクラス.
 */
@Data
public class UserAuthorityRequest {

  /**
   * ユーザーID.
   */
  private Long userId;

  /**
   * 権限コードのリスト.
   */
  private List<String> authorities;

  /**
   * サインアウトフラグ(権限変更時に対象利用者をサインアウトさせる).
   */
  private Boolean signoutFlg;

}
