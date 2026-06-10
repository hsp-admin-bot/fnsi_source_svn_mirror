/**
 * 条件送信用ルーティング設定
 */
// 機能名
import {
  FUNC_SEND_CONDITION_JPN_NAME
} from "@/constants/function-code";
// パンくず特定キー
import {
  HISTORY_KEY_SEND_CONDITION
} from "@/router/send-condition/HistoryKeyConstants";

// 条件送信画面
import SendConditionView from "@/views/send-condition/SendConditionView";

const SEND_CONDITION = {
  path: "main",
  name: "send-condition",
  component: SendConditionView,
  meta: {
    title: FUNC_SEND_CONDITION_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_SEND_CONDITION
  }
};

/* ----- 条件送信 ルーティング設定 ------- */
export default [SEND_CONDITION];
