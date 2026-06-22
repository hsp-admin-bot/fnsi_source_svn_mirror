/**
 * 体重計・条件送信用ルーティング設定
 */
// 機能名
import {
  FUNC_SEND_CONDITION_JPN_NAME,
  FUNC_WEIGHT_MODE_JPN_NAME,
  FUNC_WEIGHT_MODE_WHEEL_CHAIR_JPN_NAME,
  FUNC_MEASURE_HISTORY_JPN_NAME
} from "@/constants/function-code";
// パンくず特定キー
import {
  HISTORY_KEY_WEIGHT_MODE,
  HISTORY_KEY_WEIGHT_MODE_WHEEL_CHAIR,
  HISTORY_KEY_WEIGHT_MODE_SEND_CONDITION,
  HISTORY_KEY_WEIGHT_MODE_MEASURE_HISTORY
} from "@/router/send-condition-weight/HistoryKeyConstants";

// 体重計モード画面
import WeightModeView from "@/views/send-condition/WeightModeView";
import WeightModeContentView from "@/components/send-condition/WeightModeComponent";
import WeightModeSendConditionView from "@/components/send-condition/SendConditionMainComponent";
import WheelChairContentView from "@/components/master-maintenance/mst-wheel-chair/MstWheelChairMainComponent";
import WeightModeMeasureHistoryView from "@/components/measure-history/MeasureHistoryComponent";

// マスタ編集(車いすマスタ)
const WHEEL_CHAIR = {
  path: "wheelchair",
  name: "wheelchair",
  component: WheelChairContentView,
  meta: {
    title: FUNC_WEIGHT_MODE_WHEEL_CHAIR_JPN_NAME,
    depth: 2,
    historyKey: HISTORY_KEY_WEIGHT_MODE_WHEEL_CHAIR
  }
};

// 体重測定画面
const WEIGHT_MODE_SEND_CONDITION = {
  path: "scale",
  name: "weight-send-condition",
  component: WeightModeSendConditionView,
  meta: {
    title: FUNC_SEND_CONDITION_JPN_NAME,
    depth: 2,
    historyKey: HISTORY_KEY_WEIGHT_MODE_SEND_CONDITION
  }
};

// 測定患者選択画面
const WEIGHT_MODE_MAIN = {
  path: "",
  name: "weight-mode",
  meta: {
    title: FUNC_WEIGHT_MODE_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_WEIGHT_MODE
  },
  component: WeightModeContentView
};

// 体重計測定記録画面
const WEIGHT_MODE_MEASURE_HISTORY = {
  path: "measure-history",
  name: "weight-mode-measure-history",
  component: WeightModeMeasureHistoryView,
  meta: {
    title: FUNC_MEASURE_HISTORY_JPN_NAME,
    depth: 2,
    historyKey: HISTORY_KEY_WEIGHT_MODE_MEASURE_HISTORY
  }
};

const WEIGHT_MODE = {
  path: "",
  component: WeightModeView,
  meta: {
    title: FUNC_WEIGHT_MODE_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_WEIGHT_MODE
  },
  children: [WEIGHT_MODE_MAIN, WEIGHT_MODE_SEND_CONDITION, WHEEL_CHAIR, WEIGHT_MODE_MEASURE_HISTORY]
};

/* ----- 体重計・条件送信 ルーティング設定 ------- */
export default [WEIGHT_MODE];
