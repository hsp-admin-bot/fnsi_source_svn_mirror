package jp.co.nikkiso.ntss.admin_web.response;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.NoArgsConstructor;

/**
 * ユーザーID重複チェックレスポンス.
 */
@NoArgsConstructor
public class UserIdDuplicateCheckResponse {
  /**
   * チェック結果.
   */
  public boolean result = false;

  /**
   * エラーメッセージ.
   */
  @JsonProperty("errorMessage")
  public String errorMessage;

  /**
   * コンストラクタ.
   * @param errorMessage エラーメッセージ
   */
  public UserIdDuplicateCheckResponse(String errorMessage) {
    this.result = true;
    this.errorMessage = errorMessage;
  }
}
