/**
 * Vuex - Store 定義（治療状況リスト用Module分割取りまとめ）
 */
import StatusListStore from "@/stores/status-list/StatusListStore";
import StatusListLargeDispStore from "@/stores/status-list/StatusListLargeDispStore";

export const STATUS_LIST_STORES = {
  "status-list": {
    namespaced: true,
    modules: {
      list: StatusListStore,
      "large-display": StatusListLargeDispStore
    }
  }
};
