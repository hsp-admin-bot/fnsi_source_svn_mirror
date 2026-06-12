/**
 * スケールベッド用ルーティング設定
 */
// 機能名
import { FUNC_SCALE_BED_JPN_NAME } from "@/constants/function-code";
// パンくず特定キー
import { HISTORY_KEY_SCALE_BED_LIST } from "@/router/scale-bed/HistoryKeyConstants";

// スケールベッド画面
import ScaleBedView from "@/views/scale-bed/ScaleBedView";
import WeightModeContentView from "@/components/send-condition/WeightModeComponent";

const SCALE_BED_MAIN = {
  path: "",
  name: "scale-bed",
  meta: {
    title: FUNC_SCALE_BED_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_SCALE_BED_LIST,
  },
  component: WeightModeContentView,
};

const SCALE_BED = {
  path: "",
  component: ScaleBedView,
  meta: {
    title: FUNC_SCALE_BED_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_SCALE_BED_LIST,
  },
  children: [SCALE_BED_MAIN],
};

/* ----- スケールベッド ルーティング設定 ------- */
export default [SCALE_BED];
