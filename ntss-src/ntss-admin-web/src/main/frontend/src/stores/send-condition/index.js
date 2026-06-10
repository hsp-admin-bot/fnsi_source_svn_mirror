/**
 * Vuex - Store 定義
 */
import SendConditionStore from "@/stores/send-condition/SendConditionStore";
import WeightModeStore from "@/stores/send-condition/WeightModeStore";
import WeightStateStore from "@/stores/send-condition/WeightStateStore";
import patScheduleStore from "@/stores/send-condition/PatScheduleStore";

export const SEND_CONDITION_STORES = {
  "send-condition": {
    namespaced: true,
    modules: {
      weight: WeightModeStore,
      scale: SendConditionStore,
      state: WeightStateStore,
      schedule: patScheduleStore
    }
  }
};
