/**
 * 患者情報共有
 */
import {
  FUNC_PAT_INFO_SHARING_JPN_NAME,
  FUNC_PAT_INFO_SHARING_DETAIL_JPN_NAME,
} from "@/constants/function-code";
import {
  HISTORY_KEY_PAT_INFO_SHARING,
  HISTORY_KEY_PAT_INFO_SHARING_DETAIL,
} from "@/router/pat-info-sharing/HistoryKeyConstants";

import PatInfoSharingView from "@/views/pat-info-sharing/PatInfoSharingView";
import PatInfoSharingDetailView from "@/views/pat-info-sharing/PatInfoSharingDetailView";

const PAT_INFO_SHARING_DETAIL = {
  path: "detail",
  name: "pat-info-sharing-detail",
  component: PatInfoSharingDetailView,
  meta: {
    title: FUNC_PAT_INFO_SHARING_DETAIL_JPN_NAME,
    depth: 2,
    historyKey: HISTORY_KEY_PAT_INFO_SHARING_DETAIL
  },
};

const PAT_INFO_SHARING = {
  path: "sharing",
  name: "pat-info-sharing",
  component: PatInfoSharingView,
  meta: {
    title: FUNC_PAT_INFO_SHARING_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_PAT_INFO_SHARING
  },
  children: [PAT_INFO_SHARING_DETAIL]
};

export default [
  PAT_INFO_SHARING,
];
