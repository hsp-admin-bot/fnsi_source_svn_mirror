/**
 * Vuex - Store 定義（検査依頼用Module分割取りまとめ）
 */
import RadRequestStore from "@/stores/rad-request/RadRequestStore";

export const RAD_REQUEST_STORES = {
  "rad-request": {
    namespaced: true,
    modules: {
      list: RadRequestStore
    }
  }
};
