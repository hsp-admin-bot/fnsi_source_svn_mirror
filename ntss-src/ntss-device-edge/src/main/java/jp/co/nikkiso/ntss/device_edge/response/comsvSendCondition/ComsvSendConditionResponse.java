package jp.co.nikkiso.ntss.device_edge.response.comsvSendCondition;

import jp.co.nikkiso.ntss.device_edge.response.FlagAndMessageBaseResponse;
import lombok.NoArgsConstructor;

/**
 * 条件送信処理更新のResponse.
 */
@NoArgsConstructor
public class ComsvSendConditionResponse extends FlagAndMessageBaseResponse {

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
  public ComsvSendConditionResponse(String errorMessage) {
    super(errorMessage);
  }

}
