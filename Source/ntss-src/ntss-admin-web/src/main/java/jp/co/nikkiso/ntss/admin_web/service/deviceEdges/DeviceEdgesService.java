package jp.co.nikkiso.ntss.admin_web.service.deviceEdges;

import jp.co.nikkiso.ntss.admin_web.response.DeviceEdgesResponse;

/**
 * デバイスエッジ稼働監視のServiceインタフェース.
 */
public interface DeviceEdgesService {

  /**
   * デバイスエッジ稼働監視のResponse作成.
   *
   * @param userId ユーザID
   * @return デバイスエッジ稼働監視のResponse
   */
  DeviceEdgesResponse createDeviceEdgesResponse(Long userId);


}
