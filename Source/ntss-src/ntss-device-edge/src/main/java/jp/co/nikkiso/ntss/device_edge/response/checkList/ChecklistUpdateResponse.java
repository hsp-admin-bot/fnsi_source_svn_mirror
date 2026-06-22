package jp.co.nikkiso.ntss.device_edge.response.checkList;

import jp.co.nikkiso.ntss.device_edge.response.FlagAndMessageBaseResponse;
import lombok.NoArgsConstructor;

/**
 * ユーザ設定のResponse.
 */
@NoArgsConstructor
public class ChecklistUpdateResponse extends FlagAndMessageBaseResponse {

  /**
   * コンストラクタ.
   * @param errorMessage エラーメッセージ
   */
  public ChecklistUpdateResponse(String errorMessage) {
    super(errorMessage);
  }

  /**
   * 応答情報.
   */
  public String errorDataList;
}
