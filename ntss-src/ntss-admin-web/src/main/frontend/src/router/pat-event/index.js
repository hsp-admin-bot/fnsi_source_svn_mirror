/**
 * 患者イベント用ルーティング設定
 */
// 機能名
import {
  FUNC_PAT_EVENT_JPN_NAME,
 } from "@/constants/function-code";
// パンくず特定キー
import {
  HISTORY_KEY_PAT_EVENT,
 } from "@/router/pat-event/HistoryKeyConstants"
// 一覧
import PatEventView from "@/views/pat-event/PatEventView";

const PAT_EVENT = {
  path: "",
  name: "pat-event",
  component: PatEventView,
  meta: {
    title: FUNC_PAT_EVENT_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_PAT_EVENT
  },
};

/* ----- 患者イベント ルーティング設定 ------- */
export default [PAT_EVENT];
