/**
 * Vuex - Store 定義
 */
import MeasureHistoryStore from "@/stores/measure-history/MeasureHistoryStore";

export const MEASURE_HISTORY_STORES = {
  "measure-history": {
    namespaced: true,
    modules: {
      list: MeasureHistoryStore
    }
  }
};
