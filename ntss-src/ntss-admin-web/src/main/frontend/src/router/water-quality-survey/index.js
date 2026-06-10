import {
  HISTORY_KEY_WATER_QUALITY_SURVEY,
} from "@/router/water-quality-survey/HistoryKeyConstants";
import {
  FUNC_WATER_QUALITY_SURVEY_JPN_NAME
} from "@/constants/function-code";
import WaterQualitySurveyView from "@/views/water-quality-survey/WaterQualitySurveyView";

export default [
  {
    path: "/",
    name: "water-quality-survey",
    component: WaterQualitySurveyView,
    meta: {
      title: FUNC_WATER_QUALITY_SURVEY_JPN_NAME,
      depth: 1,
      historyKey: HISTORY_KEY_WATER_QUALITY_SURVEY
    },
    children: [
    ]
  }
];
