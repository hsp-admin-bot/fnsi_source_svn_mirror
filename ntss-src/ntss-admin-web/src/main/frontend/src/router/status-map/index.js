/**
 * 治療状況マップ用ルーティング設定
 */
// 機能名
import { FUNC_STATUS_MAP_JPN_NAME } from "@/constants/function-code";

// パンくず特定キー
import { HISTORY_KEY_STATUS_MAP } from "@/router/status-map/HistoryKeyConstants";

// マップ
import StatusMapView from "@/views/status-map/StatusMapView";

const STATUS_MAP = {
  path: "map",
  name: "status-map",
  component: StatusMapView,
  meta: {
    title: FUNC_STATUS_MAP_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_STATUS_MAP
  }
};
/* ----- 観察記録 ルーティング設定 ------- */
export default [STATUS_MAP];
