package jp.co.nikkiso.ntss.admin_web.response;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.NoArgsConstructor;

import java.util.List;

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
   * エラーメッセージリスト
   */
  public List<String> errorMessagelist;

  /**
   * コンストラクタ.
   * @param errorMessage エラーメッセージ
   */
  public FlagAndMessageBaseResponse(String errorMessage) {
    this.isSuccess = false;
    this.errorMessage = errorMessage;
  }
}
