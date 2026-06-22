package jp.co.nikkiso.ntss.admin_web.response.weight;

import jp.co.nikkiso.ntss.admin_web.response.FlagAndMessageBaseResponse;
import lombok.NoArgsConstructor;

/**
 * ユーザ設定のResponse.
 */
@NoArgsConstructor
public class WeightPrintResponse extends FlagAndMessageBaseResponse {

  /**
   * コンストラクタ.
   * @param errorMessage エラーメッセージ
   */
  public WeightPrintResponse(String errorMessage) {
    super(errorMessage);
  }

  /**
   * 印刷内容.
   */
  public String printContent;

  /**
   * 応答情報.
   */
  public Long weightScaleNo;
}
