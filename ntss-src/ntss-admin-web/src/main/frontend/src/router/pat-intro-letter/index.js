/**
 * 患者イベント用ルーティング設定
 */
// 機能名
import {
  FUNC_PAT_INTRO_LETTER_JPN_NAME,
//  FUNC_PAT_EVENT_DETAIL_JPN_NAME
 } from "@/constants/function-code";
// パンくず特定キー
import {
  HISTORY_KEY_PAT_EVENT,
//  HISTORY_KEY_PAT_EVENT_DETAIL
 } from "@/router/pat-event/HistoryKeyConstants"
// 一覧
// mod FNSI-改修内容患者イベント紹介状画面と紹介状画面を切り替えするとき、画面が更新しない。任 start
/*import PatEventView from "@/views/pat-event/PatEventView";*/
import PatEventView from "@/views/pat-event/PatEventViewReport";
// mod FNSI-改修内容患者イベント紹介状画面と紹介状画面を切り替えするとき、画面が更新しない。任 end
// 詳細Component
//import PatEventDetailView from "@/components/pat-event/PatEventDetailComponent";

//const PAT_EVENT_DETAIL = {
//  path: "detail",
//  name: "pat-event-detail",
//  component: PatEventDetailView,
//  meta: {
//    title: FUNC_PAT_EVENT_DETAIL_JPN_NAME,
//    depth: 2,
//    historyKey: HISTORY_KEY_PAT_EVENT_DETAIL
//  }
//};
const PAT_INTRO_LETTER = {
  path: "",
  name: "pat-intro-letter",
  component: PatEventView,
  meta: {
    title: FUNC_PAT_INTRO_LETTER_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_PAT_EVENT
  },
//  children: [PAT_EVENT_DETAIL]
};

/* ----- 観察記録 ルーティング設定 ------- */
export default [PAT_INTRO_LETTER];
