/**
 * 在宅透析患者用ルーティング設定
 */
// 機能名
import {
  FUNC_PAT_HOME_DIALYSIS_JPN_NAME,
  FUNC_PAT_HOME_DIALYSIS_WEIGHT_BEFORE_JPN_NAME,
  FUNC_PAT_HOME_DIALYSIS_STATUS_JPN_NAME,
  FUNC_PAT_HOME_DIALYSIS_WEIGHT_AFTER_JPN_NAME
} from "@/constants/function-code";
// パンくず特定キー
import {
  HISTORY_KEY_PAT_HOME_DIALYSIS,
  HISTORY_KEY_PAT_HOME_DIALYSIS_WEIGHT_BEFORE,
  HISTORY_KEY_PAT_HOME_DIALYSIS_STATUS,
  HISTORY_KEY_PAT_HOME_DIALYSIS_WEIGHT_AFTER
} from "@/router/pat-home-dialysis/HistoryKeyConstants";

// お知らせ画面
import PatHomeDialysisMainFrameView from "@/views/pat-home-dialysis/PatHomeDialysisView";
import PatHomeDialysisView from "@/components/pat-home-dialysis/PatHomeDialysisComponent";
// 前体重入力
import PatHomeDialysisWeightBeforeView from "@/components/pat-home-dialysis/PatHomeDialysisWeightBeforeComponent";
// 透析状況確認
import PatHomeDialysisStatusView from "@/components/pat-home-dialysis/PatHomeDialysisStatusComponent";
// 後体重入力
import PatHomeDialysisWeightAfterView from "@/components/pat-home-dialysis/PatHomeDialysisWeightAfterComponent";

// 後体重入力
const PAT_HOME_DIALYSIS_WEIGHT_AFTER = {
  path: "weight-after",
  name: "pat-home-dialysis-weight-after",
  component: PatHomeDialysisWeightAfterView,
  meta: {
    title: FUNC_PAT_HOME_DIALYSIS_WEIGHT_AFTER_JPN_NAME,
    depth: 4,
    historyKey: HISTORY_KEY_PAT_HOME_DIALYSIS_WEIGHT_AFTER
  }
};
// 透析状況確認
const PAT_HOME_DIALYSIS_STATUS = {
  path: "status",
  name: "pat-home-dialysis-status",
  component: PatHomeDialysisStatusView,
  meta: {
    title: FUNC_PAT_HOME_DIALYSIS_STATUS_JPN_NAME,
    depth: 3,
    historyKey: HISTORY_KEY_PAT_HOME_DIALYSIS_STATUS
  }
};
// 前体重入力
const PAT_HOME_DIALYSIS_WEIGHT_BEFORE = {
  path: "weight-before",
  name: "pat-home-dialysis-weight-before",
  component: PatHomeDialysisWeightBeforeView,
  meta: {
    title: FUNC_PAT_HOME_DIALYSIS_WEIGHT_BEFORE_JPN_NAME,
    depth: 2,
    historyKey: HISTORY_KEY_PAT_HOME_DIALYSIS_WEIGHT_BEFORE
  }
};
// お知らせ画面
const PAT_HOME_DIALYSIS = {
  path: "",
  name: "pat-home-dialysis",
  component: PatHomeDialysisView,
  meta: {
    title: FUNC_PAT_HOME_DIALYSIS_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_PAT_HOME_DIALYSIS
  }
};
// メインフレーム
const PAT_HOME_DIALYSIS_MAIN = {
  path: "",
  component: PatHomeDialysisMainFrameView,
  meta: {
    title: FUNC_PAT_HOME_DIALYSIS_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_PAT_HOME_DIALYSIS
  },
  children: [
    PAT_HOME_DIALYSIS,
    PAT_HOME_DIALYSIS_WEIGHT_BEFORE,
    PAT_HOME_DIALYSIS_STATUS,
    PAT_HOME_DIALYSIS_WEIGHT_AFTER
  ]
};

/* ----- 在宅透析患者用 ルーティング設定 ------- */
export default [PAT_HOME_DIALYSIS_MAIN];
