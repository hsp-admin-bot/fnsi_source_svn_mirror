package jp.co.nikkiso.ntss.admin_web.response.userAccount;

import com.fasterxml.jackson.annotation.JsonProperty;

import jp.co.nikkiso.ntss.core.entity.custom.UserAccountInfo;
import lombok.AllArgsConstructor;

/**
 * アカウント情報のResponse.
 */
@AllArgsConstructor
public class UserAccountResponse {

  /**
   * アカウント情報のEntity.
   */
  @JsonProperty("userAccountInfo")
  public UserAccountInfo userAccountInfo;

  /**
   * アカウント情報取得失敗時のレスポンスを返却するコンストラクタ.
   */
  public UserAccountResponse() {
    this.userAccountInfo = null;
  }

}
