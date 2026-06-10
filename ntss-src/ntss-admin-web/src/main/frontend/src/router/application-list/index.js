// 機能名
import { FUNC_APPLICATION_LIST_JPN_NAME } from "@/constants/function-code";
// パンくず特定キー
import { HISTORY_KEY_APPLICATION_LIST } from "@/router/application-list/HistoryKeyConstants";
// 申込一覧
import ApplicationListView from "@/views/application-list/ApplicationListView";

const APPLICATION_LIST = {
  path: "",
  name: "application-list",
  component: ApplicationListView,
  meta: {
    title: FUNC_APPLICATION_LIST_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_APPLICATION_LIST
  }
};

// 
export default [APPLICATION_LIST];
