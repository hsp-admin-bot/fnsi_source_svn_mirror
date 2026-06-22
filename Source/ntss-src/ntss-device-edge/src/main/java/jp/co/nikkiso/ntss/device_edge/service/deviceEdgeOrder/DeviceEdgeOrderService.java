package jp.co.nikkiso.ntss.device_edge.service.deviceEdgeOrder;

import jp.co.nikkiso.ntss.device_edge.request.deviceEdgeOrder.DeviceEdgeOrderRequest;

/**
 * 通信サーバー指示出しのServiceインタフェース.
 */
public interface DeviceEdgeOrderService {
  /**
   * request構造体の不足している情報をDBから取得（machineNoまたはordNoが必須）
   * @param request
   * @return
   */
  public DeviceEdgeOrderRequest findMissingData(DeviceEdgeOrderRequest request);
}
