package jp.co.nikkiso.ntss.device_edge.response.checkList;

import jp.co.nikkiso.ntss.device_edge.response.FlagAndMessageBaseResponse;
import lombok.NoArgsConstructor;

/**
 * ユーザ設定のResponse.
 */
@NoArgsConstructor
public class MediUpdateResponse extends FlagAndMessageBaseResponse {

  /**
   * コンストラクタ.
   * @param errorMessage エラーメッセージ
   */
  public MediUpdateResponse(String errorMessage) {
    super(errorMessage);
  }

  /**
   * 応答情報.
   */
  public String errorDataList;
}
