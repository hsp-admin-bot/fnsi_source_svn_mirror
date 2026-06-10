package jp.co.nikkiso.ntss.admin_web.service.mstSynchro;

public interface DeviceEdgeConnectService {
  
  /**
   * デバイスエッジ通知アプリへの通知RestAPI実施.
   * 接続先は本APIで取得
   * 
   * @param facilityCd 施設コード
   * @param deviceEdgeNo デバイスエッジ番号
   * @param topic トピック
   * @param payload ペイロード
   * @return
   */
  boolean sendToDeviceEdge(String facilityCd, Integer deviceEdgeNo, String topic, String payload);
}
