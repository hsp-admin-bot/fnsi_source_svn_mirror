/**
 * ログ参照用ルーティング設定
 */
// 機能名
import { FUNC_VIEW_LOG_JPN_NAME } from "@/constants/function-code";
// パンくず特定キー
import { HISTORY_KEY_VIEW_LOG } from "@/router/view-log/HistoryKeyConstants";
// ログ
import ViewLogView from "@/views/view-log/ViewLogView";

const VIEW_LOG = {
  path: "",
  name: "view-log",
  component: ViewLogView,
  meta: {
    title: FUNC_VIEW_LOG_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_VIEW_LOG
  }
};

export default [VIEW_LOG];
