package jp.co.nikkiso.ntss.admin_web.response.personalUser;

import java.util.List;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class NameWithHasEmailResponse {

  @AllArgsConstructor
  public static class NameWithHasEmail {
    /**
     * 利用者ID
     */
    private final Long userId;

    /**
     * 姓
     */
    private final String lastName;

    /**
     * 名
     */
    private final String firstName;

    /**
     * メールアドレス1を設定しているか
     */
    private final boolean hasEmailAddress1;

    /**
     * メールアドレス2を設定しているか
     */
    private final boolean hasEmailAddress2;

    public Long getUserId() {
      return userId;
    }

    public String getLastName() {
      return lastName;
    }

    public String getFirstName() {
      return firstName;
    }

    @JsonProperty("hasEmailAddress1")
    public boolean hasEmailAddress1() {
      return hasEmailAddress1;
    }

    @JsonProperty("hasEmailAddress2")
    public boolean hasEmailAddress2() {
      return hasEmailAddress2;
    }
  }

  private final List<NameWithHasEmail> personalUsers;
}
