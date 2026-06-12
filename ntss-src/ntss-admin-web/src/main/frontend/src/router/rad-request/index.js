/**
 * 検査依頼用ルーティング設定
 */
// 機能名
import {
  FUNC_RAD_REQUEST_JPN_NAME,
  FUNC_RAD_REQUEST_DETAIL_JPN_NAME
} from "@/constants/function-code";
// パンくず特定キー
import {
  HISTORY_KEY_RAD_REQUEST_LIST,
  HISTORY_KEY_RAD_REQUEST_DETAIL
} from "@/router/rad-request/HistoryKeyConstants";

// 検査依頼
import RadRequestMainView from "@/views/rad-request/RadRequestMainView";
// 患者個別検査依頼
import RadRequestListView from "@/views/rad-request/RadRequestListView";
import RadRequestDetailView from "@/views/rad-request/RadRequestDetailView";

const RAD_REQUEST_DETAIL = {
  path: "detail",
  name: "rad-request-detail",
  component: RadRequestDetailView,
  meta: {
    title: FUNC_RAD_REQUEST_DETAIL_JPN_NAME,
    depth: 2,
    historyKey: HISTORY_KEY_RAD_REQUEST_DETAIL
  }
};
const RAD_REQUEST_LIST = {
  path: "",
  name: "rad-request",
  component: RadRequestListView,
  meta: {
    title: FUNC_RAD_REQUEST_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_RAD_REQUEST_LIST
  }
};
const RAD_REQUEST = {
  path: "",
  component: RadRequestMainView,
  meta: {
    title: FUNC_RAD_REQUEST_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_RAD_REQUEST_LIST
  },
  children: [RAD_REQUEST_LIST, RAD_REQUEST_DETAIL]
};

/* ----- 検査依頼 ルーティング設定 ------- */
export default [RAD_REQUEST];
