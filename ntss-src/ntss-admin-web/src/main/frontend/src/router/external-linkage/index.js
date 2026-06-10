import { FUNC_EXTERNAL_COOP_OPERATION_VIEWER_JPN_NAME } from "@/constants/function-code";
import { HISTORY_KEY_EXTERNAL_COOP_LIST } from "@/router/external-coop/HistoryKeyConstants";
import ExternalCoopView from "@/views/external-coop/ExternalCoopView";

export default [
  {
    path: "/",
    name: "external-coop",
    component: ExternalCoopView,
    meta: {
      title: FUNC_EXTERNAL_COOP_OPERATION_VIEWER_JPN_NAME,
      depth: 1,
      historyKey: HISTORY_KEY_EXTERNAL_COOP_LIST
    }
  }
];
