/**
 * Vuex - Store 定義（スケールベッド用Module分割取りまとめ）
 */
import ScaleBedListStore from "@/stores/scale-bed/ScaleBedStore";
import ScaleBedSendConditionStore from "./ScaleBedSendConditionStore";

export const SCALE_BED_STORES = {
  "scale-bed": {
    namespaced: true,
    modules: {
      "send-cond": ScaleBedSendConditionStore,
      "list": ScaleBedListStore,
    }
  }
};
