/**
 * Vuex - Store 定義
 */
import surveyStore from "@/stores/water-quality-survey/SurveyStore";
import surveyResultStore from "@/stores/water-quality-survey/SurveyResultStore";
import waterChart from "@/stores/water-quality-survey/WaterChart";

export const WATER_QUALITY_SURVEY_STORES = {
  "water-quality-survey": {
    namespaced: true,
    modules: {
      list: surveyStore,
      result: surveyResultStore,
      chart: waterChart
    }
  }
};
