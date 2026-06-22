package jp.co.nikkiso.ntss.admin_web.request.statusMap;

/**
 * 治療状況マップ {@code updateIndSchedule2} 統合 API の操作種別
 */
public enum StatusMapIndSchedule2Operation {
  /** 単一オーダのベッド移動 */
  MOVE,
  /** 二オーダ間のベッド入替 */
  SWAP
}
