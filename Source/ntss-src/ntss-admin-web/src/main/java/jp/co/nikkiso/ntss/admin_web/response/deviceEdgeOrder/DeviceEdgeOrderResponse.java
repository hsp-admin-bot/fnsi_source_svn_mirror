package jp.co.nikkiso.ntss.admin_web.response.deviceEdgeOrder;

import jp.co.nikkiso.ntss.admin_web.response.FlagAndMessageBaseResponse;
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
