/**
 * 観察記録用ルーティング設定
 */
// 機能名
import {FUNC_OBSERVE_RECORD_DETAIL_JPN_NAME, FUNC_OBSERVE_RECORD_JPN_NAME} from "@/constants/function-code";
// パンくず特定キー
import {
  HISTORY_KEY_OBSERVE_RECORD_DETAIL,
  HISTORY_KEY_OBSERVE_RECORD_LIST
} from "@/router/observe-record/HistoryKeyConstants";
// 一覧
import ObserveRecordView from "@/views/observe-record/ObserveRecordView";
// 詳細
import ObserveRecordDetailView from "@/views/observe-record/ObserveRecordDetailView";
// 画面非分割用
import ObserveRecordMainView from "@/views/observe-record/ObserveRecordMainView";

const OBSERVE_RECORD_DETAIL = {
  path: "detail",
  name: "observe-record-detail",
  component: ObserveRecordDetailView,
  meta: {
    title: FUNC_OBSERVE_RECORD_DETAIL_JPN_NAME,
    depth: 3,
    historyKey: HISTORY_KEY_OBSERVE_RECORD_DETAIL
  }
};
const OBSERVE_RECORD_LIST = {
  path: "",
  name: "observe-record",
  component: ObserveRecordView,
  meta: {
    title: FUNC_OBSERVE_RECORD_JPN_NAME,
    /*mod FNSI-改修内容6265 任 start*/
    /*depth: 2,*/
    depth: 1,
    /*mod FNSI-改修内容6265 任 end*/
    historyKey: HISTORY_KEY_OBSERVE_RECORD_LIST
  }
};
const OBSERVE_RECORD = {
  path: "list",
  component: ObserveRecordMainView,
  meta: {
    title: FUNC_OBSERVE_RECORD_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_OBSERVE_RECORD_LIST
  },
  children: [OBSERVE_RECORD_LIST, OBSERVE_RECORD_DETAIL]
};

// *************************************************************
// NOTE: 分割表示に戻す際は、OBSERVE_RECORDの内容を以下のJSONに変更し、
//       参照されなくなったOBSERVE_RECORD_LIST関係の要素を削除する
//       また、Viewファイル側の<ntss-layout>タグを<ntss-layout-split>に変更する
// **************************************************************
//
// const OBSERVE_RECORD = {
//   path: "list",
//   name: "observe-record",
//   component: ObserveRecordMainView,
//   meta: {
//     title: FUNC_OBSERVE_RECORD_JPN_NAME,
//     depth: 1,
//     historyKey: HISTORY_KEY_OBSERVE_RECORD_LIST
//   },
//   children: [OBSERVE_RECORD_DETAIL]
// };

/* ----- 観察記録 ルーティング設定 ------- */
export default [OBSERVE_RECORD];
