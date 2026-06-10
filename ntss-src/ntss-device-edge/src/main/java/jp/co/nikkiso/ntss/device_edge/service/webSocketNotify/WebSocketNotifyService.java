package jp.co.nikkiso.ntss.device_edge.service.webSocketNotify;

public interface WebSocketNotifyService {

  /**
   * 通知対象列挙
   *
   */
  public static enum SendTarget {
  main, updater, browser, weightApp
  }

  /**
   * WebSocket通知機能
   * @param target 通知対象
   * @param facilityCd 施設コード
   * @param deviceEdgeNo デバイスエッジ番号
   * @param topic トピック部
   * @param payload 電文
   * @return
   */
  public boolean sendMsg(SendTarget target, String facilityCd, Integer deviceEdgeNo, String topic, String payload);
}
