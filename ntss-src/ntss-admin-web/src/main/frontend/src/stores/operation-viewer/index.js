/**
 * Vuex - Store 定義（稼働ビューア用Module分割取りまとめ）
 */
import FacilityStore from "@/stores/operation-viewer/FacilityStore";
import MachineStore from "@/stores/operation-viewer/MachineStore";
import MotionRecordStore from "@/stores/operation-viewer/MotionRecordStore";
import MotionRecordDetailStore from "@/stores/operation-viewer/MotionRecordDetailStore";

export const OPERATION_VIEWER_STORES = {
  "operation-viewer": {
    namespaced: true,
    modules: {
      facility: FacilityStore,
      machine: MachineStore,
      "motion-record": MotionRecordStore,
      "motion-record-detail": MotionRecordDetailStore
    }
  }
};
