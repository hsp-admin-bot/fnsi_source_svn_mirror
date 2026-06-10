package jp.co.nikkiso.ntss.admin_web.request.userAccount;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * ログイン可能な施設APIのRequestクラス
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
public class UserAuthenticationRequest {

  /**
   * ハッシュ値
   */
  private  String  facilityHash;

  /**
   * 施しの名前
   */
  private  String  username;

//  /**
//   * 施しパスワード
//   */
//  private  String  password;

  private String optStatus;

  private long switchId;
}
