package jp.co.nikkiso.ntss.device_edge.response.deviceEdgeOrder;

import jp.co.nikkiso.ntss.device_edge.response.FlagAndMessageBaseResponse;
import lombok.NoArgsConstructor;

/**
 * ユーザ設定のResponse.
 */
@NoArgsConstructor
public class DeviceEdgeOrderResponse extends FlagAndMessageBaseResponse {

  /**
   * コンストラクタ.
   * @param errorMessage エラーメッセージ
   */
  public DeviceEdgeOrderResponse(String errorMessage) {
    super(errorMessage);
  }

}
