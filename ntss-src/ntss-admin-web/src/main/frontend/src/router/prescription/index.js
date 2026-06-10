/**
 * 処方箋用ルーティング設定
 */
// 機能名
import {
  FUNC_PRESCRIPTION_LIST_JPN_NAME,
  FUNC_PRESCRIPTION_DETAIL_JPN_NAME
} from "@/constants/function-code";
// パンくず特定キー
import {
  HISTORY_KEY_PRESCRIPTION_LIST,
  HISTORY_KEY_PRESCRIPTION_DETAIL
} from "@/router/prescription/HistoryKeyConstants";

// 処方一覧
import PrescriptionMainView from "@/views/prescription/PrescriptionMainView";
import PrescriptionListView from "@/views/prescription/PrescriptionListView";
// 処方
import PatPrescriptionView from "@/views/prescription/PatPrescriptionView";

const PRESCRIPTION_DETAIL = {
  path: "detail",
  name: "pat-prescription",
  component: PatPrescriptionView,
  meta: {
    title: FUNC_PRESCRIPTION_DETAIL_JPN_NAME,
    depth: 2,
    historyKey: HISTORY_KEY_PRESCRIPTION_DETAIL
  }
};
const PRESCRIPTION_LIST = {
  path: "",
  name: "prescription",
  component: PrescriptionListView,
  meta: {
    title: FUNC_PRESCRIPTION_LIST_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_PRESCRIPTION_LIST
  }
};
const PRESCRIPTION = {
  path: "",
  component: PrescriptionMainView,
  children: [PRESCRIPTION_LIST, PRESCRIPTION_DETAIL]
};

/* ----- 処方箋 ルーティング設定 ------- */
export default [PRESCRIPTION];
