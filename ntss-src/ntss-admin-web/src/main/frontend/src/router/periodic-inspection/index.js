import { FUNC_PERIODIC_INSPECTION_JPN_NAME } from "@/constants/function-code";
import { HISTORY_KEY_PERIODIC_INSPECTION } from "@/router/periodic-inspection/HistoryKeyConstants";
import PeriodicInspectionView from "@/views/periodic-inspection/PeriodicInspectionView";

const PERIODIC_INSPECTION = {
  path: "",
  name: "periodic-inspection",
  component: PeriodicInspectionView,
  meta: {
    title: FUNC_PERIODIC_INSPECTION_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_PERIODIC_INSPECTION
  }
};

export default [PERIODIC_INSPECTION];
