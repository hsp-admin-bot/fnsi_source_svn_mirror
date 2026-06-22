/**
 * チェックリスト用ルーティング設定
 */
// 機能名
import { FUNC_CHECK_LIST_JPN_NAME } from "@/constants/function-code";

// パンくず特定キー
import { HISTORY_KEY_CHECK_LIST } from "@/router/check-list/HistoryKeyConstants";

// チェックリスト
import CheckListView from "@/views/check-list/CheckListView";

// チェックリスト
const CHECK_LIST = {
  path: "list",
  name: "check-list",
  component: CheckListView,
  meta: {
    title: FUNC_CHECK_LIST_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_CHECK_LIST
  }
};

/* -----測定履歴 ルーティング設定 --- */
export default [CHECK_LIST];
