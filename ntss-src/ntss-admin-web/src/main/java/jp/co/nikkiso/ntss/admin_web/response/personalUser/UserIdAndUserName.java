package jp.co.nikkiso.ntss.admin_web.response.personalUser;


import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;

/**
 * 利用者ID（内部用ID）と利用者名_姓、利用者名_名をもつEntity.
 */
@AllArgsConstructor
public class UserIdAndUserName {

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
   * 職種コード.
   */
  private final String jobCd;

  /**
   * 削除フラグ
   */
  private final String isDel;

  // add #10659 削除済み含むの接頭文字対応 ztc 20241022 ztc start
  /**
   * 表示フラグ
   */
  private final String isDisp;
  // add #10659 削除済み含むの接頭文字対応 ztc 20241022 ztc end

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

  @JsonProperty("job_cd")
  public String getJobCd() {
    return jobCd;
  }

  @JsonProperty("is_del")
  public String getIsDel() {
    return isDel;
  }

  // add #10659 削除済み含むの接頭文字対応 ztc 20241022 ztc start
  @JsonProperty("is_disp")
  public String getIsDisp() {
    return isDisp;
  }
  // add #10659 削除済み含むの接頭文字対応 ztc 20241022 ztc end
}
