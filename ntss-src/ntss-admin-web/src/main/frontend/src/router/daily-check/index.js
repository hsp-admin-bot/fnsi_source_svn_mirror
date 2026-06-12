import { FUNC_DAILY_CHECK_JPN_NAME } from "@/constants/function-code";
import { HISTORY_KEY_DAILY_CHECK } from "@/router/daily-check/HistoryKeyConstants";
import CheckListView from "@/views/daily-check/DailyCheckView";

const DAILY_CHECK = {
  path: "",
  name: "daily-check",
  component: CheckListView,
  meta: {
    title: FUNC_DAILY_CHECK_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_DAILY_CHECK
  }
};

export default [DAILY_CHECK];
