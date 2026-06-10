/**
 * 在宅透析指示書用ルーティング設定
 */
// 機能名
import {
  FUNC_FACILITY_HOME_DIALYSIS_JPN_NAME
} from "@/constants/function-code";
// パンくず特定キー
import {
  HISTORY_KEY_FACILITY_HOME_DIALYSIS
} from "@/router/facility-home-dialysis/HistoryKeyConstants";

// 在宅透析指示書
import FacilityHomeDialysisView from "@/views/facility-home-dialysis/FacilityHomeDialysisView";

const FACILITY_HOME_DIALYSIS = {
  path: "",
  name: "facility-home-dialysis",
  component: FacilityHomeDialysisView,
  meta: {
    title: FUNC_FACILITY_HOME_DIALYSIS_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_FACILITY_HOME_DIALYSIS
  },
};

/* ----- 在宅透析指示書 ルーティング設定 ------- */
export default [FACILITY_HOME_DIALYSIS];
