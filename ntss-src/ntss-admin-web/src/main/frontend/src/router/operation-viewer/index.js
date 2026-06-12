/**
 * 稼働ビューア用ルーティング設定
 */
// 機能名
import {
  FUNC_OPERATION_VIEWER_WITH_FACILITY_JPN_NAME,
  FUNC_OPERATION_VIEWER_JPN_NAME,
  FUNC_MOTION_RECORD_JPN_NAME,
  FUNC_MOTION_RECORD_DETAIL_JPN_NAME
} from "@/constants/function-code";
// パンくず特定キー
import {
  HISTORY_KEY_OPERATION_VIEWER_FACILITY,
  HISTORY_KEY_OPERATION_VIEWER_MACHINE,
  HISTORY_KEY_OPERATION_VIEWER_RECORD,
  HISTORY_KEY_OPERATION_VIEWER_DETAIL
} from "@/router/operation-viewer/HistoryKeyConstants";

// 稼働ビューア（施設一覧）
import FacilitiesView from "@/views/operation-viewer/FacilitiesView";
// 稼働ビューア
import MachinesView from "@/views/operation-viewer/MachinesView";
// 装置記録
import MotionRecordView from "@/views/operation-viewer/MotionRecordsView";
// 装置記録詳細
import MotionRecordDetailView from "@/views/operation-viewer/MotionRecordDetailsView";
// 装置記録詳細（分割表示なし）
import MotionRecordDetailsNonSplitView from "@/views/operation-viewer/MotionRecordDetailsNonSplitView";

/* ----- 稼働ビューア（管理ユーザ用） ---------------- */
const OPERATION_VIEWER_ADMIN_MOTION_RECORD_DETAIL = {
  path: "detail",
  name: "operation-viewer-admin-motion-record-detail",
  component: MotionRecordDetailView,
  meta: {
    title: FUNC_MOTION_RECORD_DETAIL_JPN_NAME,
    depth: 4,
    historyKey: HISTORY_KEY_OPERATION_VIEWER_DETAIL
  }
};
const OPERATION_VIEWER_ADMIN_MOTION_RECORD = {
  path: "motion-record",
  name: "operation-viewer-admin-motion-record",
  component: MotionRecordView,
  meta: {
    title: FUNC_MOTION_RECORD_JPN_NAME,
    depth: 3,
    historyKey: HISTORY_KEY_OPERATION_VIEWER_RECORD
  },
  children: [OPERATION_VIEWER_ADMIN_MOTION_RECORD_DETAIL]
};
const OPERATION_VIEWER_ADMIN_MACHINES = {
  path: "machines",
  name: "operation-viewer-admin-machines",
  component: MachinesView,
  meta: {
    title: FUNC_OPERATION_VIEWER_JPN_NAME,
    depth: 2,
    historyKey: HISTORY_KEY_OPERATION_VIEWER_MACHINE
  },
  children: [OPERATION_VIEWER_ADMIN_MOTION_RECORD]
};
const OPERATION_VIEWER_ADMIN_FACILITIES = {
  path: "facilities",
  name: "operation-viewer-admin-facilities",
  component: FacilitiesView,
  meta: {
    title: FUNC_OPERATION_VIEWER_WITH_FACILITY_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_OPERATION_VIEWER_FACILITY
  },
  children: [OPERATION_VIEWER_ADMIN_MACHINES]
};

/* ----- 稼働ビューア（一般ユーザ用） ---------------- */
const OPERATION_VIEWER_GENERAL_MOTION_RECORD_DETAIL = {
  path: "detail",
  name: "operation-viewer-general-motion-record-detail",
  component: MotionRecordDetailView,
  meta: {
    title: FUNC_MOTION_RECORD_DETAIL_JPN_NAME,
    depth: 3,
    historyKey: HISTORY_KEY_OPERATION_VIEWER_DETAIL
  }
};
const OPERATION_VIEWER_GENERAL_MOTION_RECORD = {
  path: "motion-record",
  name: "operation-viewer-general-motion-record",
  component: MotionRecordView,
  meta: {
    title: FUNC_MOTION_RECORD_JPN_NAME,
    depth: 2,
    historyKey: HISTORY_KEY_OPERATION_VIEWER_RECORD
  },
  children: [OPERATION_VIEWER_GENERAL_MOTION_RECORD_DETAIL]
};
const OPERATION_VIEWER_GENERAL_MACHINES = {
  path: "machines",
  name: "operation-viewer-general-machines",
  component: MachinesView,
  meta: {
    title: FUNC_OPERATION_VIEWER_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_OPERATION_VIEWER_MACHINE
  },
  children: [OPERATION_VIEWER_GENERAL_MOTION_RECORD]
};

/* ----- 稼働ビューア（施設コード、型式コード、製造番号指定用） ----- */
const OPERATION_VIEWER_SPECIFIED_MOTION_RECORD_DETAIL = {
  path: "detail",
  name: "operation-viewer-specified-motion-record-detail",
  component: MotionRecordDetailView,
  meta: {
    title: FUNC_MOTION_RECORD_DETAIL_JPN_NAME,
    depth: 2,
    historyKey: HISTORY_KEY_OPERATION_VIEWER_DETAIL
  }
};
const OPERATION_VIEWER_SPECIFIED_MOTION_RECORD = {
  path: "motion-record",
  name: "operation-viewer-specified-motion-record",
  component: MotionRecordView,
  meta: {
    title: FUNC_MOTION_RECORD_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_OPERATION_VIEWER_RECORD
  },
  children: [OPERATION_VIEWER_SPECIFIED_MOTION_RECORD_DETAIL]
};

/* ----- 稼働ビューア（分割表示なし、治療状況リスト/マップからの遷移用） ----- */
const OPERATION_VIEWER_NON_SPLIT_MOTION_RECORD_DETAIL = {
  path: "detail",
  name: "operation-viewer-non-split-motion-record-detail",
  component: MotionRecordDetailsNonSplitView,
  meta: {
    title: FUNC_MOTION_RECORD_DETAIL_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_OPERATION_VIEWER_DETAIL
  }
};

/* ----- 稼働ビューア ルーティング設定 --------------- */
export default [
  // 管理ユーザ用
  OPERATION_VIEWER_ADMIN_FACILITIES,
  // 一般ユーザ用
  OPERATION_VIEWER_GENERAL_MACHINES,
  // 施設コード、型式コード、製造番号指定用
  OPERATION_VIEWER_SPECIFIED_MOTION_RECORD,
  // 分割表示なし
  OPERATION_VIEWER_NON_SPLIT_MOTION_RECORD_DETAIL
];
