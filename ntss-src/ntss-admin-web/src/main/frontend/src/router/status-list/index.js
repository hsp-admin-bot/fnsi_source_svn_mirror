/**
 * 治療状況リスト用ルーティング設定
 */
// 機能名
import {
  FUNC_STATUS_LIST_MAIN_JPN_NAME,
  FUNC_STATUS_LIST_ALARM_JPN_NAME
} from "@/constants/function-code";
// パンくず特定キー
import {
  HISTORY_KEY_STATUS_LIST_MAIN,
  HISTORY_KEY_STATUS_LIST_ALARM
} from "@/router/status-list/HistoryKeyConstants";

// 治療状況リスト
import StatusListComponent from "@/views/status-list/StatusListView";
// 警報・報知履歴ページ
import StatusListAlarmView from "@/views/status-list/StatusListAlarmView";

const STATUS_LIST_ALARM = {
  path: "alarm",
  name: "status-list-alarm",
  component: StatusListAlarmView,
  meta: {
    title: FUNC_STATUS_LIST_ALARM_JPN_NAME,
    depth: 2,
    historyKey: HISTORY_KEY_STATUS_LIST_ALARM
  }
};
const STATUS_LIST_MAIN = {
  path: "main",
  name: "status-list",
  component: StatusListComponent,
  meta: {
    title: FUNC_STATUS_LIST_MAIN_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_STATUS_LIST_MAIN
  },
  children: [STATUS_LIST_ALARM]
};

/* ----- 治療状況リスト ルーティング設定 ------- */
export default [STATUS_LIST_MAIN];
