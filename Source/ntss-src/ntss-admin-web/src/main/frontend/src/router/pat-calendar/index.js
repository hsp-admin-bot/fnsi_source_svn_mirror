// 機能名
import { FUNC_PAT_CALENDAR_JPN_NAME } from "@/constants/function-code";
// パンくず特定キー
import { HISTORY_KEY_PAT_CALENDAR } from "@/router/pat-calendar/HistoryKeyConstants";
// ページコンポーネント
import PatCalendarView from "@/views/pat-calendar/PatCalendarView";

const PAT_CALENDAR = {
  path: "calendar",
  name: "pat-calendar",
  component: PatCalendarView,
  meta: {
    title: FUNC_PAT_CALENDAR_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_PAT_CALENDAR
  }
};

export default [PAT_CALENDAR];
