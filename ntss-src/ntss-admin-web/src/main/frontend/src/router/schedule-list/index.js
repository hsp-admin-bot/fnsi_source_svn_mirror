/**
 * スケジュール表用ルーティング設定
 */
// 機能名
import { FUNC_SCHEDULE_LIST_JPN_NAME } from "@/constants/function-code";
// パンくず特定キー
import { HISTORY_KEY_SCHEDULE_LIST } from "@/router/schedule-list/HistoryKeyConstants";

// 患者情報
import ScheduleListView from "@/views/schedule-list/ScheduleListView";

// スケジュール表情報
const SCHEDULE_LIST = {
  path: "list",
  name: "schedule-list",
  component: ScheduleListView,
  meta: {
    title: FUNC_SCHEDULE_LIST_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_SCHEDULE_LIST
  }
};

/* ----- スケジュール表情報 ルーティング設定 --- */
export default [SCHEDULE_LIST];
