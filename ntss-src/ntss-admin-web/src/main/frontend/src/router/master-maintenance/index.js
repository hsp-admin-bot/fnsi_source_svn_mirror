/**
 * マスタメンテナンス用ルーティング設定
 */
// 機能名
import {
  FUNC_MASTER_MAINTENANCE_JPN_NAME,
  FUNC_MASTER_MAINTENANCE_RECORD_JPN_NAME,
  FUNC_MASTER_MAINTENANCE_BED_LAYOUT_JPN_NAME
} from "@/constants/function-code";
// パンくず特定キー
import {
  HISTORY_KEY_MASTER_MAINTENANCE_LIST,
  HISTORY_KEY_MASTER_MAINTENANCE_RECORD,
  HISTORY_KEY_MASTER_MAINTENANCE_EX_WEIGHT,
  HISTORY_KEY_MASTER_MAINTENANCE_EX_MAP_BED_LAYOUT
} from "@/router/master-maintenance/HistoryKeyConstants";

import MasterMainView from "@/views/master-maintenance/MasterMainView";
// マスタ一覧
import MasterListView from "@/views/master-maintenance/MasterListView";
// マスターレコード
import MasterRecordView from "@/views/master-maintenance/MasterRecordView";
// 個別マスタ
import IndividualMasterView from "@/views/master-maintenance/IndividualMasterView";

// 体重計マスタ子画面
import IndividualMasterExWeightView from "@/views/master-maintenance/mst-weight/MstWeightSubView";
// ベッドレイアウトメンテナンス子画面
import IndividualMasterExMapBedLayoutView from "@/views/master-maintenance/mst-status-map-bed-layout/MstStatusMapBedLayoutSubView";

const INDIVIDUAL_MASTER_EX_MAP_BED_LAYOUT = {
  path: "weight",
  name: "individual-master-ex-map-bed-layout",
  component: IndividualMasterExMapBedLayoutView,
  meta: {
    title: FUNC_MASTER_MAINTENANCE_BED_LAYOUT_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_MASTER_MAINTENANCE_EX_MAP_BED_LAYOUT
  }
};

const INDIVIDUAL_MASTER_EX_WEIGHT = {
  path: "weight",
  name: "individual-master-ex-weight",
  component: IndividualMasterExWeightView,
  meta: {
    title: FUNC_MASTER_MAINTENANCE_RECORD_JPN_NAME,
    depth: 2,
    historyKey: HISTORY_KEY_MASTER_MAINTENANCE_EX_WEIGHT
  }
};

const MASTER_RECORD = {
  path: "record",
  name: "master-record",
  component: MasterRecordView,
  meta: {
    title: FUNC_MASTER_MAINTENANCE_RECORD_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_MASTER_MAINTENANCE_RECORD
  }
};
const INDIVIDUAL_MASTER = {
  path: "records",
  name: "individual-master",
  component: IndividualMasterView,
  meta: {
    title: FUNC_MASTER_MAINTENANCE_RECORD_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_MASTER_MAINTENANCE_RECORD
  },
  children: [INDIVIDUAL_MASTER_EX_WEIGHT]
};
const MASTER_LIST = {
  path: "",
  name: "master-maintenance",
  component: MasterListView,
  meta: {
    title: FUNC_MASTER_MAINTENANCE_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_MASTER_MAINTENANCE_LIST
  }
};
const MASTER_MAIN = {
  path: "list",
  component: MasterMainView,
  meta: {
    title: FUNC_MASTER_MAINTENANCE_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_MASTER_MAINTENANCE_LIST
  },
  children: [MASTER_LIST, MASTER_RECORD, INDIVIDUAL_MASTER, INDIVIDUAL_MASTER_EX_MAP_BED_LAYOUT]
};

/* ----- マスタメンテナンス ルーティング設定 ------- */
export default [MASTER_MAIN];
