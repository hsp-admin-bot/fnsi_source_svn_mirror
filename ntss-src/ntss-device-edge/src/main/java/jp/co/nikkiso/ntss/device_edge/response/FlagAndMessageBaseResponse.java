package jp.co.nikkiso.ntss.device_edge.response;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.NoArgsConstructor;

/**
 *　成功フラグとエラーメッセージの共通Response.
 */
@NoArgsConstructor
public abstract class FlagAndMessageBaseResponse {

  /**
   * 成功/失敗フラグ.
   */
  public boolean isSuccess = true;

  /**
   * エラーメッセージ.
   */
  @JsonProperty("errorMessage")
  public String errorMessage;

  /**
   * コンストラクタ.
   * @param errorMessage エラーメッセージ
   */
  public FlagAndMessageBaseResponse(String errorMessage) {
    this.isSuccess = false;
    this.errorMessage = errorMessage;
  }
}
