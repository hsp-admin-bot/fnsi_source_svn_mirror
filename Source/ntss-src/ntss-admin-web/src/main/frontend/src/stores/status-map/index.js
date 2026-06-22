/**
 * Vuex - Store 定義（治療状況マップModule分割取りまとめ）
 */
import StatusMapStore from "@/stores/status-map/StatusMapStore";
import NotAssignedScheduleModalStore from "@/stores/status-map/NotAssignedScheduleModalStore";
import IndicationStore from "@/stores/status-map/IndicationStore";

export const STATUS_MAP_STORES = {
  "status-map": {
    namespaced: true,
    modules: {
      map: StatusMapStore,
      modal: NotAssignedScheduleModalStore,
      ind: IndicationStore
    }
  }
};
