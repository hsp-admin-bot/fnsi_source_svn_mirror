/**
 * 装置設定用ルーティング設定
 */
// 機能名
import { FUNC_PAT_DEVICE_SET_JPN_NAME } from "@/constants/function-code";

// パンくず特定キー
import { HISTORY_KEY_DEVICESET_INFO } from "@/router/deviceset-info/HistoryKeyConstants";

// 装置設定
import DeviceSetInfoView from "@/views/deviceset-info/DeviceSetInfoView";

// 装置設定情報
const DEVICESET_INFO = {
  path: "info",
  name: "deviceset-info",
  component: DeviceSetInfoView,
  meta: {
    title: FUNC_PAT_DEVICE_SET_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_DEVICESET_INFO
  }
};

/* ----- 装置設定情報 ルーティング設定 --- */
export default [DEVICESET_INFO];
