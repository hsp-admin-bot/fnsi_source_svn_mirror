/**
 * 患者情報用ルーティング設定
 */
// 機能名
import { FUNC_PAT_INFO_JPN_NAME } from "@/constants/function-code";

// パンくず特定キー
import { HISTORY_KEY_PAT_INFO } from "@/router/pat-info/HistoryKeyConstants";

// 患者情報
import PatInfoView from "@/views/pat-info/PatInfoView";

// 患者情報
const PAT_INFO = {
  path: "info",
  name: "pat-info",
  component: PatInfoView,
  meta: {
    title: FUNC_PAT_INFO_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_PAT_INFO
  }
};

/* ----- 患者情報 ルーティング設定 --- */
export default [PAT_INFO];
