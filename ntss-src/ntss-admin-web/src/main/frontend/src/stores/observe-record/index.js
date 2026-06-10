/**
 * Vuex - Store 定義（観察記録用Module分割取りまとめ）
 */
import ObserveRecordListStore from "@/stores/observe-record/ObserveRecordStore";
import ObserveRecordDetailStore from "@/stores/observe-record/ObserveRecordDetailStore";

export const OBSERVE_RECORD_STORES = {
  "observe-record": {
    namespaced: true,
    modules: {
      list: ObserveRecordListStore,
      detail: ObserveRecordDetailStore
    }
  }
};
