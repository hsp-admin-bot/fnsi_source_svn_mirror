/**
 * 観察記録用ルーティング設定
 */
// 機能名
import { FUNC_EXAM_RECORD_JPN_NAME } from "@/constants/function-code";
import { FUNC_EXAM_RECORD_DETAIL_JPN_NAME } from "@/constants/function-code";
// パンくず特定キー
import {
  HISTORY_KEY_EXAM_RECORD_LIST,
  HISTORY_KEY_EXAM_RECORD_DETAIL
} from "@/router/exam-record/HistoryKeyConstants";

// 一覧
import ExamRecordView from "@/views/exam-record/ExamRecordView";
// 詳細
import ExamRecordListView from "@/components/exam-record/ExamRecordComponent";
import ExamRecordDetailView from "@/components/exam-record/ExamRecordDetailComponent";

const EXAM_RECORD_DETAIL = {
  path: "detail",
  name: "exam-record-detail",
  component: ExamRecordDetailView,
  meta: {
    title: FUNC_EXAM_RECORD_DETAIL_JPN_NAME,
    depth: 2,
    historyKey: HISTORY_KEY_EXAM_RECORD_DETAIL
  }
};
const EXAM_RECORD_LIST = {
  path: "",
  name: "exam-record",
  component: ExamRecordListView,
  meta: {
    title: FUNC_EXAM_RECORD_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_EXAM_RECORD_LIST
  }
};
const EXAM_RECORD = {
  path: "",
  component: ExamRecordView,
  meta: {
    title: FUNC_EXAM_RECORD_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_EXAM_RECORD_LIST
  },
  children: [EXAM_RECORD_LIST,EXAM_RECORD_DETAIL]
};

/* ----- 観察記録 ルーティング設定 ------- */
export default [EXAM_RECORD];
