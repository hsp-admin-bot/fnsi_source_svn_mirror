/**
 * 治療状況リスト用ルーティング設定
 */
// 機能名
import { FUNC_TREND_GRAPH_JPN_NAME } from "@/constants/function-code";
// パンくず特定キー
import { HISTORY_KEY_TREND_GRAPH } from "@/router/trend-graph/HistoryKeyConstants";

// 治療状況リスト：透析液調製装置トレンドグラフ
import TrendGraphView from "@/views/trend-graph/TrendGraphView";

const TREND_GRAPH = {
  path: "trend-graph",
  name: "trend-graph",
  component: TrendGraphView,
  meta: {
    title: FUNC_TREND_GRAPH_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_TREND_GRAPH
  }
};

/* ----- 治療状況リスト ルーティング設定 ------- */
export default [TREND_GRAPH];
