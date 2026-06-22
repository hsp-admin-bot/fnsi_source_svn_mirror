package jp.co.nikkiso.ntss.admin_web.request.userAccount;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * ログイン可能な施設APIのRequestクラス
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public class UserAuthenticationRequest {

  /**
   * ハッシュ値
   */
  private  String  facilityHash;
  private  String  facilityName;

  /**
   * 施しの名前
   */
  private  String  username;

//  /**
//   * 施しパスワード
//   */
//  private  String  password;

  private String optStatus;

  private Long switchId;
}
