package jp.co.nikkiso.ntss.admin_web.response.personalUser;


import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;

/**
 * 利用者ID（内部用ID）と利用者名_姓、利用者名_名、利用者姓名をもつEntity.
 */
@AllArgsConstructor
public class UserIdAndUserFullName {

  /**
   * 利用者ID（内部用ID）
   */
  private final Long userId;

  /**
   * 利用者名_姓
   */
  private final String userLastName;

  /**
   * 利用者名_名
   */
  private final String userFirstName;

  /**
   * 利用者名_姓名
   */
  private final String userName;

  @JsonProperty("user_id")
  public Long getUserId() {
    return userId;
  }

  @JsonProperty("user_last_name")
  public String getUserLastName() {
    return userLastName;
  }

  @JsonProperty("user_first_name")
  public String getUserFirstName() {
    return userFirstName;
  }

  @JsonProperty("user_name")
  public String getUserName() {
    return userName;
  }

}
