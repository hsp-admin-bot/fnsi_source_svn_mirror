/**
 * 検査依頼用ルーティング設定
 */
// 機能名
import {
  FUNC_EXAM_REQUEST_JPN_NAME,
  FUNC_EXAM_REQUEST_DETAIL_JPN_NAME
} from "@/constants/function-code";
// パンくず特定キー
import {
  HISTORY_KEY_EXAM_REQUEST_LIST,
  HISTORY_KEY_EXAM_REQUEST_DETAIL
} from "@/router/exam-request/HistoryKeyConstants";

// 検査依頼
import ExamRequestMainView from "@/views/exam-request/ExamRequestMainView";
// 患者個別検査依頼
import ExamRequestListView from "@/views/exam-request/ExamRequestListView";
import ExamRequestDetailView from "@/views/exam-request/ExamRequestDetailView";

const EXAM_REQUEST_DETAIL = {
  path: "detail",
  name: "exam-request-detail",
  component: ExamRequestDetailView,
  meta: {
    title: FUNC_EXAM_REQUEST_DETAIL_JPN_NAME,
    depth: 2,
    historyKey: HISTORY_KEY_EXAM_REQUEST_DETAIL
  }
};
const EXAM_REQUEST_LIST = {
  path: "",
  name: "exam-request",
  component: ExamRequestListView,
  meta: {
    title: FUNC_EXAM_REQUEST_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_EXAM_REQUEST_LIST
  }
};
const EXAM_REQUEST = {
  path: "",
  component: ExamRequestMainView,
  meta: {
    title: FUNC_EXAM_REQUEST_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_EXAM_REQUEST_LIST
  },
  children: [EXAM_REQUEST_LIST, EXAM_REQUEST_DETAIL]
};

/* ----- 検査依頼 ルーティング設定 ------- */
export default [EXAM_REQUEST];
