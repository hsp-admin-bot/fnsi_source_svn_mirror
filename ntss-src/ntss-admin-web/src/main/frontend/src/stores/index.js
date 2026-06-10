/**
 * Vuex - Store 定義（Module分割取りまとめ）
 */
import Vue from "vue";
import Vuex from "vuex";

import ApplicationStore from "@/stores/ApplicationStore";
import BreadCrumbStore from "@/stores/BreadCrumbStore";
import WindowSizeStore from "@/stores/WindowSizeStore";
import UserStore from "@/stores/UserStore";
import ReferenceComboStore from "@/stores/ReferenceComboStore";
import WebSocketStore from "@/stores/WebSocketStore";
import WebSocketCardStore from "@/stores/WebSocketCardStore";
import ReportStore from "@/stores/ReportStore";
import LoadingScreenStore from "@/stores/LoadingScreenStore";

import { OPERATION_VIEWER_STORES } from "@/stores/operation-viewer";
import { BIO_MONITORING_STORES } from "@/stores/bio-monitoring";
import { DEVICE_EDGE_OPERATION_STORES } from "@/stores/device-edge-operation";
import { PAT_VIEWER_STORES } from "@/stores/pat-viewer";
import { MASTER_MAINTENANCE_STORES } from "@/stores/master-maintenance";
import { SEND_CONDITION_STORES } from "@/stores/send-condition";
import { MEASURE_HISTORY_STORES } from "@/stores/measure-history";
import { CHECK_LIST_STORES } from "@/stores/check-list";
import { OBSERVE_RECORD_STORES } from "@/stores/observe-record";
import { STATUS_MAP_STORES } from "@/stores/status-map";
import { STATUS_LIST_STORES } from "@/stores/status-list";
import { TREND_GRAPH_STORES } from "@/stores/trend-graph";
import { MODALS_STORES } from "@/stores/modals";
//import { MASTER_STORES } from "@/stores/master";
import { PAT_INFO_STORES } from "@/stores/pat-info";
import { SCHEDULE_LIST_STORES } from "@/stores/schedule-list";
import { SCHEDULE_ASSIGNMENT_STORES } from "@/stores/schedule-assignment";

import { TREATMENT_RECORD_STORES } from "@/stores/treatment-record";
import { EXAM_RECORD_STORES } from "@/stores/exam-record";
import { RAD_REQUEST_STORES } from "@/stores/rad-request";
import { EXAM_REQUEST_STORES } from "@/stores/exam-request";
import { INDICATION_RESULT_STORES } from "@/stores/indication-result";
import { BBS_INFO_STORES } from "@/stores/bbs-info";
import { MULTI_CALENDAR } from "@/stores/multi-calendar";
// add FNSI-No.530 処理が遅い。非同期処理となっているが、別機能遷移でサーバー側の処理をとめる dou start
import { MULTI_PAT_LIST } from "@/stores/multi-pat-list";
// add FNSI-No.530 処理が遅い。非同期処理となっているが、別機能遷移でサーバー側の処理をとめる dou end
import { PAT_EVENT_STORES } from "@/stores/pat-event";
import { REPORT_MENU_STORES } from "@/stores/report-menu";
import { INDICATION_STORE } from "./indication";
import { PAT_GROUP_STORE } from "./pat-group";
// add 9941 患者カレンダーで内容保持がされていない。 関 start
import { PAT_CALENDAR_STORE } from "@/stores/pat-calendar";
// add 9941 患者カレンダーで内容保持がされていない。 関 end
import { INTRODUCTION_LETTER_STORES } from "@/stores/introduction-letter";
import { PAT_INSURANCE_STORES } from "@/stores/pat-insurance";
import { FACILITY_STORE } from "@/stores/facility";
import { URL_LINK_REGISTER } from "@/stores/url-link-register";
import { EXTERNAL_COOP_STORE } from "@/stores/external-coop";
import { PAT_PRESCRIPTION_STORES } from "@/stores/pat-prescription";
import { PRESCRIPTION_STORES } from "@/stores/prescription";
import { FACILITY_CALENDAR_STORES } from "@/stores/facility-calendar";
import { VIEW_LOG_STORE } from "@/stores/view-log";
import { PERIODIC_INSPECTION } from "@/stores/periodic-inspection";
import { DAILY_CHECK } from "@/stores/daily-check";
import { WATER_QUALITY_SURVEY_STORES } from "@/stores/water-quality-survey";
import { ORD_ADDITION_STORE } from "@/stores/ord-addition";
import { TOGGLE_DEV_TOOL_STORE } from "@/stores/toggle-dev-tool";
import { SHARING_PATIENT_INFORMATION_STORES } from "@/stores/sharing-patient-information";
import { NOTIFICATION_STORES } from "@/stores/notification";
import { SPLIT_GRAPH } from "@/stores/split-graph";
import { USAGE_SUBSCRIPTION_STORES } from "@/stores/usage-subscription";
import { APPLICATION_LIST_STORES } from "@/stores/application-list";
import { DATA_LIST_STORE } from "@/stores/data-list";
import { PAT_LIST_LAYOUT_STORES } from "@/stores/pat-list-layout";
import { USER_SELECTOR_POPOVER } from "@/stores/pop-over/user-selector";
import { SYS_FACILITY_STORE } from "@/stores/sys-facility";
import { PAT_INFO_SHARING_STORES } from "@/stores/pat-info-sharing";
// #11987 2026.01.11 add スケールベッド対応 スケールベッド測定用Stores追加 TDC渡辺 start
import { SCALE_BED_STORES } from "@/stores/scale-bed";
// #11987 2026.01.11 add スケールベッド対応 スケールベッド測定用Stores追加 TDC渡辺 edit

// stores直下のSTORE(modules)定義
const MODULES = {
  app: ApplicationStore,
  "bread-crumb": BreadCrumbStore,
  "window-size": WindowSizeStore,
  user: UserStore,
  "reference-combo": ReferenceComboStore,
  websocket: WebSocketStore,
  "websocket-card": WebSocketCardStore,
  report: ReportStore,
  "loading-screen": LoadingScreenStore
};

// 機能別STORE定義の配列
const STORES = [
  OPERATION_VIEWER_STORES,
  BIO_MONITORING_STORES,
  DEVICE_EDGE_OPERATION_STORES,
  PAT_VIEWER_STORES,
  MASTER_MAINTENANCE_STORES,
  MODALS_STORES,
  STATUS_MAP_STORES,
  OBSERVE_RECORD_STORES,
  STATUS_LIST_STORES,
  // #11987 2026.01.11 add スケールベッド対応 スケールベッド測定用Stores追加 TDC渡辺 start
  SCALE_BED_STORES,
  // #11987 2026.01.11 add スケールベッド対応 スケールベッド測定用Stores追加 TDC渡辺 edit
  TREND_GRAPH_STORES,
  TREATMENT_RECORD_STORES,
  OBSERVE_RECORD_STORES,
  DATA_LIST_STORE,
  //  MASTER_STORES,
  PAT_INFO_STORES,
  SCHEDULE_LIST_STORES,
  SEND_CONDITION_STORES,
  MEASURE_HISTORY_STORES,
  CHECK_LIST_STORES,
  SCHEDULE_ASSIGNMENT_STORES,
  EXAM_RECORD_STORES,
  RAD_REQUEST_STORES,
  EXAM_REQUEST_STORES,
  INDICATION_RESULT_STORES,
  BBS_INFO_STORES,
  MULTI_CALENDAR,
  // add FNSI-No.530 処理が遅い。非同期処理となっているが、別機能遷移でサーバー側の処理をとめる dou start
  MULTI_PAT_LIST,
  // add FNSI-No.530 処理が遅い。非同期処理となっているが、別機能遷移でサーバー側の処理をとめる dou end
  PAT_EVENT_STORES,
  REPORT_MENU_STORES,
  INDICATION_STORE,
  PAT_GROUP_STORE,
  // add 9941 患者カレンダーで内容保持がされていない。 関 start
  PAT_CALENDAR_STORE,
  // add 9941 患者カレンダーで内容保持がされていない。 関 end
  INTRODUCTION_LETTER_STORES,
  FACILITY_STORE,
  URL_LINK_REGISTER,
  EXTERNAL_COOP_STORE,
  PAT_INSURANCE_STORES,
  PAT_PRESCRIPTION_STORES,
  PRESCRIPTION_STORES,
  FACILITY_CALENDAR_STORES,
  VIEW_LOG_STORE,
  PERIODIC_INSPECTION,
  DAILY_CHECK,
  WATER_QUALITY_SURVEY_STORES,
  ORD_ADDITION_STORE,
  TOGGLE_DEV_TOOL_STORE,
  USAGE_SUBSCRIPTION_STORES,
  APPLICATION_LIST_STORES,
  SHARING_PATIENT_INFORMATION_STORES,
  NOTIFICATION_STORES,
  PAT_LIST_LAYOUT_STORES,
  USER_SELECTOR_POPOVER,
  SPLIT_GRAPH,
  SYS_FACILITY_STORE,
  PAT_INFO_SHARING_STORES,
  SCALE_BED_STORES,
];

// MODULESに機能別のSTORE定義を追加
STORES.forEach(store => {
  Object.keys(store).forEach(key => {
    MODULES[key] = store[key];
  });
});

// オブジェクト内の配列の内容を削除する
const deleteDataItem = (state, submoduleList = []) => {
  const keys = Object.keys(state).filter(key => !submoduleList.includes(key));
  keys.forEach(key => {
    const value = state[key];
    if (typeof value !== "object" || value === null) return;
    if (value instanceof Array) {
      if (value.length > 0) {
        value.splice(0);
      }
    } else {
      deleteDataItem(value);
    }
  });
};
// stateの配列内容削除用mutation関数名
const DeleterName = "deleteAllStateData";
// モジュールのmutationに追加するstate内の配列内容削除用関数を生成する
const makeStateDataItemDeleter = (submoduleList, modulePath) => {
  return (state) => {
    if (state) {
      deleteDataItem(state, submoduleList);
    } else {
      console.warn(`${DeleterName}: modulePath:${modulePath}, state:${state}.`);
    }
  };
};

// copyInitialStateで処理対象外とするモジュールパスのリスト
const ExcludePathList = [
  "app",
  "websocket",
  "websocket-card",
];
const modulePathList = [];
// 各モジュールにstateの配列内容削除用mutation関数を追加しつつモジュールパスリストを作成する
const modifyModules = (modules, path) => {
  Object.keys(modules).forEach(key => {
    const modulePath = path ? `${path}/${key}` : key;
    if (ExcludePathList.includes(modulePath)) return;

    const module = modules[key];
    if (module.state) {
      if (!module.mutations) {
        module.mutations = {};
      }
      if (!module.mutations[DeleterName]) {
        const submoduleList = [];
        if (module.modules) {
          submoduleList.push(
            ...Object.keys(module.modules).filter(submodule => module.modules[submodule].state)
          );
        }
        module.mutations[DeleterName] = makeStateDataItemDeleter(submoduleList, modulePath);
        if (!modulePathList.includes(modulePath)) {
          modulePathList.push(modulePath);
        } else {
          console.warn(`modifyModules: modulePath<${modulePath}> is already exists in modulePathList.`);
        }
      } else {
        console.warn(`modifyModules: module[${modulePath}].mutations.${DeleterName} is already exists.`);
      }
    }
    if (module.modules) {
      modifyModules(module.modules, modulePath);
    }
  });
};
modifyModules(MODULES, "");

// モジュール名リストを元にstateの配列内容削除用mutation関数を実行する
export const deleteAllStateDataItem = () => {
  modulePathList.forEach((path) => {
    vuexStore.commit(`${path}/${DeleterName}`);
  });
};

// STORE定義
Vue.use(Vuex);
const vuexStore = new Vuex.Store({
  namespaced: true,
  modules: MODULES,
  /* delete by chamaojia 2022-12-06 [5958] vuexでの持続化を必要としないデータ持続化方式の変更（パフォーマンスに影響） --start */
  // plugins: [
  //   createPersistedState({
  //     storage: window.sessionStorage,
  //     paths: persistStorePaths
  //   })
  // ]
  /* delete by chamaojia 2022-12-06 [5958] vuexでの持続化を必要としないデータ持続化方式の変更（パフォーマンスに影響） --end */
});
export default vuexStore;
