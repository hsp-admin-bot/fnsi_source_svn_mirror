import {
  HISTORY_KEY_PAT_GROUP_LIST,
  HISTORY_KEY_PAT_GROUP_EDIT,
  HISTORY_KEY_PAT_GROUP_NEW
} from "./HistoryKeyConstants";
import {
  FUNC_PAT_GROUP_JPN_NAME,
  FUNC_PAT_GROUP_EDIT_JPN_NAME
} from "@/constants/function-code";
import PatGroupListView from "@/views/pat-group/PatGroupListView";
import PatGroupEditView from "@/views/pat-group/PatGroupEditView";

export default [
  {
    path: "list",
    name: "pat-group",
    component: PatGroupListView,
    meta: {
      title: FUNC_PAT_GROUP_JPN_NAME,
      depth: 1,
      historyKey: HISTORY_KEY_PAT_GROUP_LIST
    },
    children: [
      {
        path: "new",
        name: "pat-group-new",
        component: PatGroupEditView,
        meta: {
          title: FUNC_PAT_GROUP_EDIT_JPN_NAME,
          depth: 2,
          historyKey: HISTORY_KEY_PAT_GROUP_NEW
        }
      },
      {
        path: "edit/:patGroupCd",
        name: "pat-group-edit",
        component: PatGroupEditView,
        meta: {
          title: FUNC_PAT_GROUP_EDIT_JPN_NAME,
          depth: 2,
          historyKey: HISTORY_KEY_PAT_GROUP_EDIT
        }
      }
    ]
  }
];
