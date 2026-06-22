/**
 * Vuex - Store 定義
 */
import CheckListStore from "@/stores/check-list/CheckListStore";
import CheckListModalStore from "@/stores/check-list/CheckListModalStore";
import MedicineModalStore from "@/stores/check-list/MedicineModalStore";

export const CHECK_LIST_STORES = {
  "check-list": {
    namespaced: true,
    modules: {
      list: CheckListStore,
      modal: CheckListModalStore,
      medimodal: MedicineModalStore
    }
  }
};
