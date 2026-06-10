/**
 * 患者新規登録用ルーティング設定
 */
// 機能名
import { FUNC_PAT_INFO_CREATE_JPN_NAME } from "@/constants/function-code";

// パンくず特定キー
import { HISTORY_KEY_PAT_INFO_CREATE } from "@/router/pat-info-create/HistoryKeyConstants";

// 患者新規登録
import PatInfoCreateView from "@/views/pat-info-create/PatInfoCreateView";

// 患者新規登録
const PAT_INFO_CREATE = {
  path: "create",
  name: "pat-info-create",
  component: PatInfoCreateView,
  meta: {
    title: FUNC_PAT_INFO_CREATE_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_PAT_INFO_CREATE
  }
};

/* -----患者新規登録 ルーティング設定 --- */
export default [PAT_INFO_CREATE];
