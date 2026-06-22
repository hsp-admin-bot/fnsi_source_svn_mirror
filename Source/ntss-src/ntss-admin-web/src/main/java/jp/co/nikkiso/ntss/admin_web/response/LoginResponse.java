package jp.co.nikkiso.ntss.admin_web.response;

import lombok.AllArgsConstructor;

/**
 *　ログイン成功時Response.
 */
@AllArgsConstructor
public class LoginResponse {

  /**
   * 施設コード.
   */
  public String facilityCd;

  /**
   * ユーザーID(内部用).
   */
  public final Long userId;

  /**
   * 利用者種別.
   */
  public final Integer userType;

}
