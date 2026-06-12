/**
 * デバイスエッジ稼働監視用ルーティング設定
 */
// 機能名
import { FUNC_DEVICE_EDGE_OPERATION_JPN_NAME, FUNC_DEVICE_EDGE_MANAGE_JPN_NAME } from "@/constants/function-code";
// パンくず特定キー
import { HISTORY_KEY_DEVICE_EDGE_OPERATION, HISTORY_KEY_DEVICE_EDGE_MANAGE } from "@/router/device-edge-operation/HistoryKeyConstants";

// デバイスエッジ稼働監視
import DeviceEdgeOperationView from "@/views/device-edge-operation/DeviceEdgeOperationView";
// デバイスエッジ遠隔保守
import DeviceEdgeManageView from "@/views/device-edge-operation/DeviceEdgeManageView";

const DEVICE_EDGE_MANAGE = {
  path: "manage",
  name: "device-edge-manage",
  component: DeviceEdgeManageView,
  meta: {
    title: FUNC_DEVICE_EDGE_MANAGE_JPN_NAME,
    depth: 2,
    historyKey: HISTORY_KEY_DEVICE_EDGE_MANAGE
  }
}

const DEVICE_EDGE_OPERATION = {
  path: "list",
  name: "device-edge-operation",
  component: DeviceEdgeOperationView,
  meta: {
    title: FUNC_DEVICE_EDGE_OPERATION_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_DEVICE_EDGE_OPERATION
  },
  children: [DEVICE_EDGE_MANAGE]
};

/* ----- デバイスエッジ稼働監視 ルーティング設定 --- */
export default [DEVICE_EDGE_OPERATION];
