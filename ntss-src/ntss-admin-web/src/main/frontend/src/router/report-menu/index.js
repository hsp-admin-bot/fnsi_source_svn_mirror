import {
  HISTORY_KEY_REPORT_MENU_LIST,
} from "./HistoryKeyConstants";
import {
  FUNC_REPORT_MENU_JPN_NAME
} from "@/constants/function-code";
import ReportMenuListView from "@/views/report-menu/ReportMenuListView";

export default [
  {
    path: "/",
    name: "report-menu",
    component: ReportMenuListView,
    meta: {
      title: FUNC_REPORT_MENU_JPN_NAME,
      depth: 1,
      historyKey: HISTORY_KEY_REPORT_MENU_LIST
    },
    children: [
    ]
  }
];
