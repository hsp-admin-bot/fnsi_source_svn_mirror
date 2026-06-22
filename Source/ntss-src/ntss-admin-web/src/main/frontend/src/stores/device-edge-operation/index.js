/**
 * Vuex - Store 定義（デバイスエッジ稼働監視用Module分割取りまとめ）
 */
import DeviceEdgeOperationStore from "@/stores/device-edge-operation/DeviceEdgeOperationStore";
import DeviceEdgeManageStore from "@/stores/device-edge-operation/DeviceEdgeManageStore";
import MultiDeviceEdgeManageStore from "@/stores/device-edge-operation/MultiDeviceEdgeManageStore";

export const DEVICE_EDGE_OPERATION_STORES = {
  "device-edge-operation": DeviceEdgeOperationStore,
  "device-edge-manage": DeviceEdgeManageStore,
  "multi-device-edge-manage": MultiDeviceEdgeManageStore
};
