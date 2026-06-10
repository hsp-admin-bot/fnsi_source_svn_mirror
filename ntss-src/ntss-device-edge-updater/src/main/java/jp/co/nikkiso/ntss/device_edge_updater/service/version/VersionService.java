package jp.co.nikkiso.ntss.device_edge_updater.service.version;

/**
 * デバイスエッジアプリケーションバージョン設定サービス
 */
public interface VersionService {

  /**
   * デバイスエッジのバージョン情報を更新
   * @param facilityCd 施設コード
   * @param deviceEdgeNo デバイスエッジ番号
   * @param versionText デバイスエッジのバージョン情報文字列
   * @return
   */
  int saveDeviceEdgeVersion(String facilityCd, int deviceEdgeNo, String versionText);
}
