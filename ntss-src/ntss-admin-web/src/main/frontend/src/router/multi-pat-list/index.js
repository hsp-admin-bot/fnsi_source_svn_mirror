/**
 * マルチ患者一覧用ルーティング設定
 */
// 機能名
import { FUNC_MULTI_PAT_LIST_JPN_NAME } from "@/constants/function-code";
// パンくず特定キー
import { HISTORY_KEY_MULTI_PAT_LIST } from "@/router/multi-pat-list/HistoryKeyConstants";
// マルチ患者一覧
import MultiPatListView from "@/views/multi-pat-list/MultiPatListView";

const MULTI_PAT_LIST = {
  path: "list",
  name: "multi-pat-list",
  component: MultiPatListView,
  meta: {
    title: FUNC_MULTI_PAT_LIST_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_MULTI_PAT_LIST
  }
};

/* ----- マルチ患者一覧 ルーティング設定 --- */
export default [MULTI_PAT_LIST];
