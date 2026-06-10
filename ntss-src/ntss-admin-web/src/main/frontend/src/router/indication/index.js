import {
  HISTORY_KEY_INDICATION_LIST,
  HISTORY_KEY_INDICATION_DETAIL
} from "./HistoryKeyConstants";
import {
  FUNC_INDICATION_JPN_NAME,
  FUNC_INDICATION_RECEIVE_JPN_NAME,
  FUNC_INDICATION_APPROVE_JPN_NAME
} from "@/constants/function-code";
import IndicationMainView from "@/views/indication/IndicationMainView";
import IndicationListView from "@/views/indication/IndicationListView";
import IndicationDetailView from "@/views/indication/IndicationDetailView";

export default [
  {
    path: "list",
    component: IndicationMainView,
    children: [
      {
        path: "",
        name: "indication",
        component: IndicationListView,
        meta: {
          title: FUNC_INDICATION_JPN_NAME,
          depth: 1,
          historyKey: HISTORY_KEY_INDICATION_LIST
        }
      },
      {
        path: "detail/receive/:ordNo",
        name: "indication-receive-detail",
        component: IndicationDetailView,
        meta: {
          title: FUNC_INDICATION_RECEIVE_JPN_NAME,
          depth: 2,
          historyKey: HISTORY_KEY_INDICATION_DETAIL
        }
      },
      {
        path: "detail/approve/:ordNo",
        name: "indication-approve-detail",
        component: IndicationDetailView,
        meta: {
          title: FUNC_INDICATION_APPROVE_JPN_NAME,
          depth: 2,
          historyKey: HISTORY_KEY_INDICATION_DETAIL
        }
      },
      {
        path: "detail/receive/:patId",
        name: "indication-receive-details",
        component: IndicationDetailView,
        meta: {
          title: FUNC_INDICATION_RECEIVE_JPN_NAME,
          depth: 2,
          historyKey: HISTORY_KEY_INDICATION_DETAIL
        }
      },
      {
        path: "detail/approve/:patId",
        name: "indication-approve-details",
        component: IndicationDetailView,
        meta: {
          title: FUNC_INDICATION_APPROVE_JPN_NAME,
          depth: 2,
          historyKey: HISTORY_KEY_INDICATION_DETAIL
        }
      },
    ]
  }
];
