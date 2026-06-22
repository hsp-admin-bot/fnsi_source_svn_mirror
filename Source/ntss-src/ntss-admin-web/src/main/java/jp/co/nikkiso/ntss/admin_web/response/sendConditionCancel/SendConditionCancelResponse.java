package jp.co.nikkiso.ntss.admin_web.response.sendConditionCancel;

import jp.co.nikkiso.ntss.admin_web.response.FlagAndMessageBaseResponse;
import lombok.NoArgsConstructor;

/**
 * 条件送信キャンセルのResponse.
 */
@NoArgsConstructor
public class SendConditionCancelResponse extends FlagAndMessageBaseResponse {

  /**
   * 例外情報
   */
  public Exception ex;
  /**
   * エラーメッセージ（ログ記録用）
   */
  public String exMessage;
  /**
   * コンストラクタ.
   * @param errorMessage エラーメッセージ
   */
  public SendConditionCancelResponse(String errorMessage) {
    super(errorMessage);
  }

}
