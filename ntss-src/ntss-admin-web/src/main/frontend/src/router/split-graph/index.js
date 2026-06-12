/**
 * P-Ca9分割グラフ用ルーティング設定
 */
import { FUNC_SPLIT_GRAPH_JPN_NAME } from "@/constants/function-code";
// パンくず特定キー
import { HISTORY_KEY_SPLIT_GRAPH } from "@/router/split-graph/HistoryKeyConstants";
// P-Ca9分割グラフモード画面
import SplitGraphView from "@/views/split-graph/SplitGraphView";

const SPLIT_GRAPH = {
  path: "/",
  name: "split-graph",
  component: SplitGraphView,
  meta: {
    title: FUNC_SPLIT_GRAPH_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_SPLIT_GRAPH
  }
};

export default [ SPLIT_GRAPH ];
