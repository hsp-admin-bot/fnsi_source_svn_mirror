/**
 * 測定履歴用ルーティング設定
 */
// 機能名
import { FUNC_MEASURE_HISTORY_JPN_NAME } from "@/constants/function-code";

// パンくず特定キー
import { HISTORY_KEY_MEASURE_HISTORY } from "@/router/measure-history/HistoryKeyConstants";

// 測定履歴
import MeasureHistoryView from "@/views/measure-history/MeasureHistoryView";

// 測定履歴
const MEASURE_HISTORY = {
  path: "list",
  name: "measure-history",
  component: MeasureHistoryView,
  meta: {
    title: FUNC_MEASURE_HISTORY_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_MEASURE_HISTORY
  }
};

/* -----測定履歴 ルーティング設定 --- */
export default [MEASURE_HISTORY];
