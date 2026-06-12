/**
 * Vuex - Store 定義（生体モニタ用Module分割取りまとめ）
 */
import appitemStore from "@/stores/modules/appItem";
import listGraphStore from "@/stores/modules/listGraph";

export const BIO_MONITORING_STORES = {
  appitem: appitemStore,
  listGraph: listGraphStore
};
