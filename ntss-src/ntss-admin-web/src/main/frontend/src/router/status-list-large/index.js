/**
 * 治療状況リスト大画面表示用ルーティング設定
 */
/**
 * 治療状況リストからのみ呼び出される画面かつ、全体表示を行いたいため、
 * routerのみ治療状況リストと別に定義。
 * ViewやComponentはstats-list内に存在する。
 */
// 機能名
import { FUNC_STATUS_LIST_LARGEDISP_JPN_NAME } from "@/constants/function-code";
// パンくず特定キー
import { HISTORY_KEY_STATUS_LIST_LARGEDISP } from "@/router/status-list-large/HistoryKeyConstants";

// 大画面表示ページ
import StatusListLargeDispView from "@/views/status-list/StatusListLargeDispView";

const STATUS_LIST_LARGEDISP = {
  path: "largedisp",
  name: "status-list-largedisp",
  component: StatusListLargeDispView,
  meta: {
    title: FUNC_STATUS_LIST_LARGEDISP_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_STATUS_LIST_LARGEDISP
  }
};

/* ----- 治療状況リスト ルーティング設定 ------- */
export default [STATUS_LIST_LARGEDISP];
