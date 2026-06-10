/**
 * 患者経過総合ビューア用ルーティング設定
 */
// 機能名
import { FUNC_PAT_VIEWER_JPN_NAME } from "@/constants/function-code";

// パンくず特定キー
import { HISTORY_KEY_PAT_VIEWER } from "@/router/pat-viewer/HistoryKeyConstants";

// 患者経過総合ビューア
import PatViewerView from "@/views/pat-viewer/PatViewerView";

// 患者経過総合ビューア
const PAT_VIEWER = {
  path: "list",
  name: "pat-viewer",
  component: PatViewerView,
  meta: {
    title: FUNC_PAT_VIEWER_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_PAT_VIEWER
  }
};

/* ----- 患者経過総合ビューア ルーティング設定 ------- */
export default [PAT_VIEWER];
