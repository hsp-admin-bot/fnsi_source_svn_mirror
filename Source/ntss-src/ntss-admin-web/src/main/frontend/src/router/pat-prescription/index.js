/**
 * 処方箋用ルーティング設定
 */
// 機能名
import {
  //FUNC_PRESCRIPTION_JPN_NAME,
  // add FNSI-改修内容 処方個別画面に処方一覧画面のリンクを追加する dou start
  FUNC_PRESCRIPTION_DETAIL_JPN_NAME,
  // add FNSI-改修内容 処方個別画面に処方一覧画面のリンクを追加する dou end
} from "@/constants/function-code";
// パンくず特定キー
import {
  HISTORY_KEY_PAT_PRES,
} from "@/router/pat-prescription/HistoryKeyConstants"
  // add FNSI-改修内容 処方個別画面に処方一覧画面のリンクを追加する dou start
// import {
//   HISTORY_KEY_PRESCRIPTION_DETAIL
// } from "@/router/prescription/HistoryKeyConstants";
  // add FNSI-改修内容 処方個別画面に処方一覧画面のリンクを追加する dou end
// 一覧
  // mod FNSI-改修内容 処方個別画面に処方一覧画面のリンクを追加する dou start
// import PatPrescriptionView from "@/views/pat-prescription/PatPrescriptionView";
//import PatPrescriptionView from "@/views/pat-prescription/PatPrescriptionListView";
import PatPrescriptionDetailView from "@/views/pat-prescription/PatPrescriptionView";
  // mod FNSI-改修内容 処方個別画面に処方一覧画面のリンクを追加する dou end

// const PAT_PRES = {
//   // mod FNSI-改修内容 処方個別画面に処方一覧画面のリンクを追加する dou start
//   // path: "",
//   path: "prescription",
//   // mod FNSI-改修内容 処方個別画面に処方一覧画面のリンクを追加する dou end
//   name: "pat-prescription",
//   component: PatPrescriptionView,
//   meta: {
//     title: FUNC_PRESCRIPTION_JPN_NAME,
//     depth: 1,
//     historyKey: HISTORY_KEY_PAT_PRES
//   },
// };
  // add FNSI-改修内容 処方個別画面に処方一覧画面のリンクを追加する dou start
// const PREPRESCRIPTION_DETAIL = {
//   path: "prescriptionDetail",
//   name: "pat-prescription-detail",
//   component: PatPrescriptionDetailView,
//   meta: {
//     title: FUNC_PRESCRIPTION_DETAIL_JPN_NAME,
//     depth: 2,
//     historyKey: HISTORY_KEY_PRESCRIPTION_DETAIL
//   },
// };
  // add FNSI-改修内容 処方個別画面に処方一覧画面のリンクを追加する dou end
  //add FNSI-NO515 処方画面に処方一覧画面のリンクを削減する 劉全航 start
  const PAT_PRES = {
    path: "prescription",
    name: "pat-prescription",
    component: PatPrescriptionDetailView,
    meta: {
      title: FUNC_PRESCRIPTION_DETAIL_JPN_NAME,
      depth: 2,
      historyKey: HISTORY_KEY_PAT_PRES
    },
  };
  //add FNSI-NO515 処方画面に処方一覧画面のリンクを削減する 劉全航 end

/* ----- 処方箋 ルーティング設定 ------- */
  // mod FNSI-改修内容 処方個別画面に処方一覧画面のリンクを追加する dou start
// export default [PAT_PRES];
//export default [PAT_PRES, PREPRESCRIPTION_DETAIL];
  // mod FNSI-改修内容 処方個別画面に処方一覧画面のリンクを追加する dou end

//add FNSI-NO515 処方画面に処方一覧画面のリンクを削減する 劉全航 start
export default [PAT_PRES];
//add FNSI-NO515 処方画面に処方一覧画面のリンクを削減する 劉全航 end
