import { HISTORY_KEY_EXTERNAL_COOP } from "@/router/external-coop/HistoryKeyConstants";
import { FUNC_EXTERNAL_COOP_JPN_NAME } from "@/constants/function-code";
import ExternalCoopView from "@/views/external-coop/ExternalCoopView";

export default [
  {
    path: "",
    name: "external-coop",
    component: ExternalCoopView,
    meta: {
      title: FUNC_EXTERNAL_COOP_JPN_NAME,
      depth: 1,
      historyKey: HISTORY_KEY_EXTERNAL_COOP
    },
    children: []
  }
];
