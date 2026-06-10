/**
 * スケールベッド用ルーティング設定
 */
// 機能名
import {
  FUNC_SEND_CONDITION_JPN_NAME,
  FUNC_SCALE_BED_JPN_NAME,
} from "@/constants/function-code";
// パンくず特定キー
import {
  HISTORY_KEY_WEIGHT_MODE_SEND_CONDITION,
  HISTORY_KEY_SCALE_BED_LIST,
} from "@/router/scale-bed/HistoryKeyConstants";

// スケールベッド画面
import ScaleBedView from "@/views/scale-bed/ScaleBedView";
import WeightModeContentView from "@/components/send-condition/WeightModeComponent";
import WeightModeSendConditionView from "@/components/send-condition/SendConditionMainComponent";

const WEIGHT_MODE_SEND_CONDITION = {
  path: "scale",
  name: "weight-send-condition",
  component: WeightModeSendConditionView,
  meta: {
    title: FUNC_SEND_CONDITION_JPN_NAME,
    depth: 2,
    historyKey: HISTORY_KEY_WEIGHT_MODE_SEND_CONDITION,
  },
};

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
  children: [SCALE_BED_MAIN, WEIGHT_MODE_SEND_CONDITION],
};

/* ----- スケールベッド ルーティング設定 ------- */
export default [SCALE_BED];
