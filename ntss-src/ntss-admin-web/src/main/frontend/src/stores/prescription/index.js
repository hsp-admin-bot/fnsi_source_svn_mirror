/**
 * Vuex - Store 定義（処方箋分割取りまとめ）
 */
import PrescriptionStore from "@/stores/prescription/PrescriptionStore";

export const PRESCRIPTION_STORES = {
  "prescription": {
    namespaced: true,
    modules: {
      list: PrescriptionStore
    }
  }
};
