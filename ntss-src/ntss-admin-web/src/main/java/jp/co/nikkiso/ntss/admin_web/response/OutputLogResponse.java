package jp.co.nikkiso.ntss.admin_web.response;

import lombok.NoArgsConstructor;

/**
 * ログ出力のレスポンス情報
 */
@NoArgsConstructor
public class OutputLogResponse extends FlagAndMessageBaseResponse {

  /**
   * コンストラクタ.
   *
   * @param isSuccess 成功/失敗フラグ.
   * @param errorMessage エラーメッセージ
   */
  public OutputLogResponse(boolean isSuccess, String errorMessage) {
    this.isSuccess = isSuccess;
    this.errorMessage = errorMessage;
  }

  /**
   * コンストラクタ.
   *
   * @param errorMessage エラーメッセージ
   */
  public OutputLogResponse(String errorMessage) {
    super(errorMessage);
  }
}
