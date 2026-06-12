import {
  createRouter,
  createWebHashHistory,
  hydrateLegacyRouteParams,
  normalizeLegacyNamedRouteLocation
} from "@/compat/vue/router";
import store from "@/stores";

import LoginView from "@/views/LoginView";
import LoginViewHomeDialysis from "@/views/LoginViewHomeDialysis";
import Root from "@/views/RootView";
import OperationViewerRoutes from "@/router/operation-viewer";
import BioMonitoringRoutes from "@/router/bio-monitoring";
import DeviceEdgeOperationRoutes from "@/router/device-edge-operation";
import PatViewerRoutes from "@/router/pat-viewer";
import MasterMaintenanceRoutes from "@/router/master-maintenance";
import WeightModeRoutes from "@/router/send-condition-weight";
import SendConditionRoutes from "@/router/send-condition";
import TreatmentRecordRoutes from "@/router/treatment-record";
import MeasureHistoryRoutes from "@/router/measure-history";
import CheckListRoutes from "@/router/check-list";
import ObserveRecordRoutes from "@/router/observe-record";
import StatusMapRoutes from "@/router/status-map";
import StatusListRoutes from "@/router/status-list";
import StatusListRoutesLarge from "@/router/status-list-large";
import StatusListTrendGraphRoutes from "@/router/trend-graph";
import PatInfoRoutes from "@/router/pat-info";
import PatInfoCreateRoutes from "@/router/pat-info-create";
import ScheduleListRoutes from "@/router/schedule-list";
import ProvisionalAccountEditView from "@/views/ProvisionalAccountEditView";
import DeviceSetInfoRoutes from "@/router/deviceset-info";
import MultiPatListRoutes from "@/router/multi-pat-list";
import ExamRecordRoutes from "@/router/exam-record";
import BbsInfoRoutes from "@/router/bbs-info";
import CacheTestRoutes from "@/router/cache-test";
import PatCalendarRoutes from "@/router/pat-calendar";
import PatGroupRoutes from "./pat-group";
import RadRequestRoutes from "@/router/rad-request";
import ReportMenuRoutes from "@/router/report-menu";
import ExamRequestRoutes from "@/router/exam-request";
import PatEventRoutes from "@/router/pat-event";
import PatIntroLetterRoutes from "@/router/pat-intro-letter";
import IndicationRoutes from "./indication";
import FacilityHomeDialysisRoutes from "@/router/facility-home-dialysis";
import PatHomeDialysisRoutes from "@/router/pat-home-dialysis";
import PatPrescriptionRoutes from "@/router/prescription";
// import PatPrescriptionRoutes from "@/router/pat-prescription";
import UsageSubscriptionRoutes from "@/router/usage-subscription";
import ApplicationListRoutes from "@/router/application-list";
import PatInfoSharingRoutes from "@/router/pat-info-sharing";
import FacilityCalendarRoutes from "@/router/facility-calendar";
import ViewLogRoutes from "@/router/view-log";
import PeriodicInspectionRoutes from "@/router/periodic-inspection";
import DailyCheckRoutes from "@/router/daily-check";
import WaterQualitySurveyRoutes from "@/router/water-quality-survey";
import ExternalCoopRoutes from "@/router/external-coop";
import SplitGraphRoutes from "@/router/split-graph";
import ScaleBedRoutes from "@/router/scale-bed";

import { getInitialRouterName, getCurrentFunctionCd } from "@/router/routing-helper";
import { setRouterInstance } from "@/compat/vue/router-facade.js";
import { HISTORY_KEY_OPERATION_VIEWER_MACHINE } from "@/router/operation-viewer/HistoryKeyConstants";
import { HISTORY_KEY_MASTER_MAINTENANCE_RECORD } from "@/router/master-maintenance/HistoryKeyConstants";
import { HISTORY_KEY_INDICATION_LIST } from "@/router/indication/HistoryKeyConstants";

import RoutingDefs from "@/router/json/routing-defs.json";
import { persistStorePaths } from "@/constants/persistStorePaths";
import { SESSION_STORAGE_KEY } from "@/constants/sessionStorageConstants";
import { messageFormat } from "@/functions/common/MessageFormat";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { showAlertDialog } from "@/functions/common/OnsenFunctions";
import {
  FUNC_INDICATION_JPN_NAME,
  FUNC_STATUS_LIST_LARGEDISP,
  FUNC_TREATMENT_RECORD_LIST_ADDITIONINFO,
  FUNC_TREATMENT_RECORD_lIST_BVMS,
  transAuthorityList
} from "@/constants/function-code";
import { ADVANCED_SETTINGS } from "@/constants/advancedSettings";

const router = createRouter({
  history: createWebHashHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: "/",
      name: "signin",
      component: LoginView,
      meta: {
        description: "ログイン"
      }
    },
    {
      path: "/home-dialysis",
      name: "signinhome",
      component: LoginViewHomeDialysis,
      meta: {
        description: "ログイン"
      }
    },
    {
      path: "/operation-viewer",
      component: Root,
      redirect: { name: OperationViewerRoutes[0].name },
      meta: {
        description: "稼働ビューア"
      },
      children: OperationViewerRoutes
    },
    {
      path: "/bio-monitoring",
      component: Root,
      redirect: { name: BioMonitoringRoutes[0].name },
      meta: {
        description: "生体モニタリング"
      },
      children: BioMonitoringRoutes
    },
    {
      path: "/device-edge-operation",
      component: Root,
      redirect: { name: DeviceEdgeOperationRoutes[0].name },
      meta: {
        description: "デバイスエッジ稼働監視"
      },
      children: DeviceEdgeOperationRoutes
    },
    {
      path: "/pat-viewer",
      component: Root,
      redirect: { name: PatViewerRoutes[0].name },
      meta: {
        description: "患者経過総合ビューア"
      },
      children: PatViewerRoutes
    },
    {
      path: "/master-maintenance",
      component: Root,
      redirect: { name: MasterMaintenanceRoutes[0].name },
      meta: {
        description: "マスタメンテナンス"
      },
      children: MasterMaintenanceRoutes
    },
    {
      path: "/treatment-record",
      component: Root,
      redirect: { name: TreatmentRecordRoutes[0].name },
      meta: {
        description: "治療記録"
      },
      children: TreatmentRecordRoutes
    },
    {
      path: "/provisional-account-edit",
      name: "provisional-account-edit",
      component: ProvisionalAccountEditView,
      meta: {
        description: "初回ログイン時アカウント登録"
      }
    },
    {
      path: "/weight-mode",
      component: Root,
      redirect: { name: WeightModeRoutes[0].name },
      meta: {
        description: "体重計"
      },
      children: WeightModeRoutes
    },
    {
      path: "/send-condition",
      component: Root,
      redirect: { name: SendConditionRoutes[0].name },
      meta: {
        description: "体重測定・入室"
      },
      children: SendConditionRoutes
    },
    {
      path: "/measure-history",
      component: Root,
      redirect: { name: MeasureHistoryRoutes[0].name },
      meta: {
        description: "体重計測定記録"
      },
      children: MeasureHistoryRoutes
    },
    {
      path: "/check-list",
      component: Root,
      redirect: { name: CheckListRoutes[0].name },
      meta: {
        description: "チェックリスト"
      },
      children: CheckListRoutes
    },
    {
      path: "/observe-record",
      component: Root,
      redirect: { name: ObserveRecordRoutes[0].name },
      meta: {
        description: "観察記録"
      },
      children: ObserveRecordRoutes
    },
    {
      path: "/status-map",
      component: Root,
      redirect: { name: StatusMapRoutes[0].name },
      meta: {
        description: "治療状況マップ"
      },
      children: StatusMapRoutes
    },
    {
      path: "/status-list",
      component: Root,
      redirect: { name: StatusListRoutes[0].name },
      meta: {
        description: "治療状況リスト"
      },
      children: StatusListRoutes
    },
    {
      path: "/status-list-large",
      component: Root,
      redirect: { name: StatusListRoutesLarge[0].name },
      meta: {
        description: "治療状況リスト大画面表示"
      },
      children: StatusListRoutesLarge
    },
    {
      path: "/trend-graph",
      component: Root,
      redirect: { name: StatusListTrendGraphRoutes[0].name },
      meta: {
        description: "透析液調製装置トレンドグラフ"
      },
      children: StatusListTrendGraphRoutes
    },
    {
      path: "/schedule-list",
      component: Root,
      redirect: { name: ScheduleListRoutes[0].name },
      meta: {
        description: "スケジュール表"
      },
      children: ScheduleListRoutes
    },
    {
      path: "/deviceset-info",
      component: Root,
      redirect: { name: DeviceSetInfoRoutes[0].name },
      meta: {
        description: "装置設定"
      },
      children: DeviceSetInfoRoutes
    },
    {
      path: "/pat-info",
      component: Root,
      redirect: { name: PatInfoRoutes[0].name },
      meta: {
        description: "患者情報"
      },
      children: PatInfoRoutes
    },
    {
      path: "/multi-pat-list",
      component: Root,
      redirect: { name: MultiPatListRoutes[0].name },
      meta: {
        description: "データリスト"
      },
      children: MultiPatListRoutes
    },
    {
      path: "/pat-info-create",
      component: Root,
      redirect: { name: PatInfoCreateRoutes[0].name },
      meta: {
        description: "新規患者登録"
      },
      children: PatInfoCreateRoutes
    },
    {
      path: "/exam-record",
      component: Root,
      redirect: { name: ExamRecordRoutes[0].name },
      meta: {
        description: "検査結果"
      },
      children: ExamRecordRoutes
    },
    {
      path: "/bbs-info",
      component: Root,
      redirect: { name: PatInfoCreateRoutes[0].name },
      meta: {
        description: "掲示板一覧情報"
      },
      children: BbsInfoRoutes
    },
    {
      path: "/cache-test",
      component: Root,
      redirect: { name: CacheTestRoutes[0].name },
      meta: {
        description: "テストページ"
      },
      children: CacheTestRoutes
    },
    {
      path: "/pat-calendar",
      component: Root,
      redirect: { name: PatCalendarRoutes[0].name },
      meta: {
        description: "患者カレンダ"
      },
      children: PatCalendarRoutes
    },
    {
      path: "/pat-group",
      component: Root,
      redirect: { name: PatGroupRoutes[0].name },
      meta: {
        description: "患者グループ"
      },
      children: PatGroupRoutes
    },
    {
      path: "/rad-request",
      component: Root,
      redirect: { name: RadRequestRoutes[0].name },
      meta: {
        description: "放射線検査依頼"
      },
      children: RadRequestRoutes
    },
    {
      path: "/report-menu",
      component: Root,
      redirect: { name: ReportMenuRoutes[0].name },
      meta: {
        description: "帳票"
      },
      children: ReportMenuRoutes
    },
    {
      path: "/exam-request",
      component: Root,
      redirect: { name: ExamRequestRoutes[0].name },
      meta: {
        description: "検査依頼"
      },
      children: ExamRequestRoutes
    },
    {
      path: "/pat-event",
      component: Root,
      redirect: { name: PatEventRoutes[0].name },
      meta: {
        description: "患者イベント"
      },
      children: PatEventRoutes
    },
    {
      path: "/indication",
      component: Root,
      redirect: { name: IndicationRoutes[0].name },
      meta: {
        description: "指示受け・指示承認"
      },
      children: IndicationRoutes
    },
    {
      path: "/facility-home-dialysis",
      component: Root,
      redirect: { name: FacilityHomeDialysisRoutes[0].name },
      meta: {
        description: "在宅透析"
      },
      children: FacilityHomeDialysisRoutes
    },
    {
      path: "/pat-home-dialysis",
      component: Root,
      redirect: { name: PatHomeDialysisRoutes[0].name },
      meta: {
        description: "在宅透析患者用"
      },
      children: PatHomeDialysisRoutes
    },
    {
      path: "/pat-info-sharing",
      component: Root,
      redirect: { name: PatInfoSharingRoutes[0].name },
      meta: {
        description: "患者情報共有"
      },
      children: PatInfoSharingRoutes
    },
    {
      path: "/facility-calendar",
      component: Root,
      redirect: { name: FacilityCalendarRoutes[0].name },
      meta: {
        description: "施設カレンダー"
      },
      children: FacilityCalendarRoutes
    },
    {
      path: "/pat-intro-letter",
      component: Root,
      redirect: { name: PatIntroLetterRoutes[0].name },
      meta: {
        description: "患者イベント"
      },
      children: PatIntroLetterRoutes
    },
    {
      path: "/prescription",
      component: Root,
      redirect: { name: PatPrescriptionRoutes[0].name },
      meta: {
        // mod FNSI-改修内容「処方箋」を「処方」に変更 dou start
        // description: "処方箋"
        description: "処方"
        // mod FNSI-改修内容 「処方箋」を「処方」に変更 dou end
      },
      children: PatPrescriptionRoutes
    },
    {
      path: "/view-log",
      component: Root,
      redirect: { name: ViewLogRoutes[0].name },
      meta: {
        description: "ログ参照"
      },
      children: ViewLogRoutes
    },
    {
      path: "/periodic-inspection",
      component: Root,
      redirect: { name: PeriodicInspectionRoutes[0].name },
      meta: {
        description: "機器保守（定期点検) "
      },
      children: PeriodicInspectionRoutes
    },
    {
      path: "/daily-check",
      component: Root,
      redirect: { name: DailyCheckRoutes[0].name },
      meta: {
        description: "機器保守（日常点検）"
      },
      children: DailyCheckRoutes
    },
    {
      path: "/water-quality-survey",
      component: Root,
      redirect: { name: WaterQualitySurveyRoutes[0].name },
      meta: {
        description: "水質検査"
      },
      children: WaterQualitySurveyRoutes
    },
    {
      path: "/external-coop",
      component: Root,
      redirect: { name: ExternalCoopRoutes[0].name },
      meta: {
        description: "連携稼働ビューア"
      },
      children: ExternalCoopRoutes
    },
    {
      path: "/usage-subscription",
      component: Root,
      redirect: { name: UsageSubscriptionRoutes[0].name },
      meta: {
        description: "利用申込"
      },
      children: UsageSubscriptionRoutes
    },
    {
      path: "/application-list",
      component: Root,
      redirect: { name: ApplicationListRoutes[0].name },
      meta: {
        description: "申込一覧"
      },
      children: ApplicationListRoutes
    },
    {
      path: "/split-graph",
      component: Root,
      redirect: { name: SplitGraphRoutes[0].name },
      meta: {
        description: "P-Ca9分割グラフ"
      },
      children: SplitGraphRoutes
    },
    // #11987 2026.01.30 add スケールベッド対応 TDC伊東 start
    {
      path: "/scale-bed",
      component: Root,
      redirect: { name: ScaleBedRoutes[0].name },
      meta: {
        description: "スケールベッド"
      },
      children: ScaleBedRoutes
    }
    // #11987 2026.01.30 add スケールベッド対応 TDC伊東 end
  ]
});

setRouterInstance(router);

/**
 * Vue Router 4 が破棄する Vue2 の未宣言 params 文脈を、各ガード・画面の参照前に復元する。
 */
router.beforeEach((to, from) => {
  hydrateLegacyRouteParams(to);
  hydrateLegacyRouteParams(from);
  return true;
});

/**
 * サインイン済かどうか
 */
function isLoggedIn() {
  const dispUserId = store.getters["user/getDispUserId"];
  return dispUserId !== null && dispUserId !== "";
}

/**
 * 永続化データ復元
 */
function restorePersistStoreFromSession() {
  const scopedSessionStorage = globalThis?.sessionStorage;
      const refreshFlag = scopedSessionStorage?.getItem(SESSION_STORAGE_KEY.REFRESH_FLAG);
  if (refreshFlag !== "1") return;

  for (const storePath of persistStorePaths) {
    const storeStr = scopedSessionStorage?.getItem(storePath);
    scopedSessionStorage?.removeItem(storePath);

    if (storeStr !== null && storeStr !== "null") {
      const storeNameArr = storePath.split(".");
      if (storeNameArr.length === 1) {
        store.state[storeNameArr[0]] = JSON.parse(storeStr);
      } else if (storeNameArr.length === 2) {
        store.state[storeNameArr[0]][storeNameArr[1]] = JSON.parse(storeStr);
      } else if (storeNameArr.length === 3) {
        store.state[storeNameArr[0]][storeNameArr[1]][storeNameArr[2]] = JSON.parse(storeStr);
      }
    }
  }

  globalThis?.sessionStorage?.setItem(SESSION_STORAGE_KEY.REFRESH_FLAG, "9");
}

/**
 * ルーティング定義から機能権限対象を取得
 */
function resolveRoutingItem(to) {
  const ROUTING_ITEMS = RoutingDefs.routing_defs.routing_items;
  const url = to.path.split("/");
  if (!url) return null;

  let routerName = url[1];

  if (routerName === "operation-viewer") {
    if (to.path === "/operation-viewer/machines") {
      routerName = "operation-viewer-general-machines";
    } else if (to.path === "/operation-viewer/facilities") {
      routerName = "operation-viewer-admin-facilities";
    } else {
      routerName = "operation-viewer-specified-motion-record";
    }
  }

  if (routerName === "treatment-record" && to.path === "/treatment-record/list/observation") {
    routerName = "observe-record";
  }

  return ROUTING_ITEMS.find((e) => {
    return e.router_name === routerName || (e.routes && e.routes.includes(routerName));
  });
}

/**
 * 権限メッセージ表示
 */
function showPermissionAlert(label) {
  showAlertDialog({
    title: DIALOG_MESSAGES[12000315].title,
    message: messageFormat(DIALOG_MESSAGES[12000315].message, label)
  });
}

const pendingReportRequests = new Map();

function fetchMstReportOnce(funcCd, printFlag = 0) {
  const requestKey = `${funcCd}:${printFlag}`;
  if (pendingReportRequests.has(requestKey)) {
    return pendingReportRequests.get(requestKey);
  }

  const promise = store.dispatch("report/getMstReport", {
    funcCd,
    printFlag
  }).finally(() => {
    pendingReportRequests.delete(requestKey);
  });

  pendingReportRequests.set(requestKey, promise);
  return promise;
}


function isIndicationDetailRouteName(routeName) {
  return [
    "indication-receive-detail",
    "indication-approve-detail",
    "indication-receive-details",
    "indication-approve-details"
  ].includes(String(routeName || ""));
}

function isIndicationUnitDetailRouteName(routeName) {
  return ["indication-receive-details", "indication-approve-details"].includes(String(routeName || ""));
}

function getIndicationUnitDetailRouteName(routeName) {
  if (String(routeName || "").includes("approve")) {
    return "indication-approve-details";
  }
  return "indication-receive-details";
}

function getIndicationDetailPatId(to) {
  return to?.params?.patId ?? to?.params?.ordNo ?? null;
}

function getIndicationDetailIdsFromStore(patId) {
  if (patId == null) {
    return [];
  }
  const sourceLists = [
    store.getters["indication/sortedIndications"],
    store.getters["indication/sortedIndicationsList"],
    store.state?.indication?.indications,
    store.state?.indication?.sortedIndicationsList
  ];
  for (const sourceList of sourceLists) {
    const list = Array.isArray(sourceList) ? sourceList : [];
    const found = list.find((item) => String(item?.patId ?? item?.pat_id) === String(patId));
    if (Array.isArray(found?._id)) {
      return found._id;
    }
    if (found?._id != null) {
      return [found._id];
    }
  }
  return [];
}

function needsIndicationBreadcrumbReset(targetRouteName) {
  const histories = store.getters["bread-crumb/getHistory"] || [];
  if (!Array.isArray(histories) || histories.length === 0) {
    return true;
  }
  const hasIndicationParent = histories.some((item) => item?.routerName === "indication");
  const hasForeignHistory = histories.some((item) => {
    const routerName = String(item?.routerName || "");
    return routerName && !routerName.startsWith("indication");
  });
  const indicationDetailCount = histories.filter((item) => {
    return isIndicationDetailRouteName(item?.routerName);
  }).length;
  const currentTargetCount = histories.filter((item) => item?.routerName === targetRouteName).length;
  return !hasIndicationParent || hasForeignHistory || indicationDetailCount > 1 || currentTargetCount > 1;
}

function resetIndicationBreadcrumbRoot() {
  store.dispatch("bread-crumb/resetHistory");
  store.dispatch("bread-crumb/resetKeepHistory");
  store.dispatch("bread-crumb/addHistory", {
    depth: 1,
    title: FUNC_INDICATION_JPN_NAME,
    routerName: "indication",
    historyKey: HISTORY_KEY_INDICATION_LIST
  });
}

function normalizeIndicationDetailRoute(to) {
  if (!isIndicationDetailRouteName(to?.name)) {
    return null;
  }

  const isTreatmentUnit = store.getters["indication/isTreatmentUnit"];
  const targetRouteName = isTreatmentUnit === false
    ? getIndicationUnitDetailRouteName(to.name)
    : String(to.name || "");

  if (needsIndicationBreadcrumbReset(targetRouteName)) {
    resetIndicationBreadcrumbRoot();
  }

  if (isTreatmentUnit !== false || isIndicationUnitDetailRouteName(to.name)) {
    return null;
  }

  const patId = getIndicationDetailPatId(to);
  if (patId == null || patId === "") {
    return null;
  }

  const ids = getIndicationDetailIdsFromStore(patId);
  const method = String(to.name || "").includes("approve") ? "approve" : "receive";
  return normalizeLegacyNamedRouteLocation({
    name: targetRouteName,
    params: {
      patId,
      method,
      ...(ids.length > 0 ? { _id: ids } : {})
    },
    query: to.query || {}
  }, router);
}

/**
 * beforeEach 1
 * session restore / signin check / 権限チェック
 */
router.beforeEach((to, from) => {
  restorePersistStoreFromSession();

  if (to.name !== "signin" && to.name !== "signinhome" && !isLoggedIn()) {
    return { name: "signin" };
  }

  const indicationDetailRedirect = normalizeIndicationDetailRoute(to);
  if (indicationDetailRedirect) {
    return indicationDetailRedirect;
  }

  const item = resolveRoutingItem(to);
  const userFuncs = store.getters["account-edit/getAuthorizedFunctions"];

  if (item && userFuncs && userFuncs.indexOf(item.function_cd) === -1) {
    const functionObj = Object.values(transAuthorityList).find((e) => e.code === item.function_cd);

    if (to.path === "/treatment-record/list/observation") {
      if (to.meta) {
        to.meta.depth = 2;
      }
      showPermissionAlert(functionObj?.label || "");
      store.dispatch("bread-crumb/resetKeepHistory");
      return { name: getInitialRouterName() };
    }

    if (!to.meta || to.meta.depth < 2) {
      showPermissionAlert(functionObj?.label || "");
      return from?.name ? { name: from.name } : { name: getInitialRouterName() };
    }
  }

  const advcdValuesList = [];
  const advancedSettings = store.getters["user/getAdvancedSettings"];
  if (advancedSettings && Object.keys(advancedSettings).length) {
    advancedSettings.func_advcds.forEach((item) => {
      advcdValuesList.push(item.func_advcd);
    });
  }

  const largedispUrl = "/status-list-large/largedisp";
  const bvmsUrl = "/treatment-record/list/bvms";
  const additionInfoUrl = "/treatment-record/list/addition-info";

  const advancedCorrespondences = {
    [largedispUrl]: ADVANCED_SETTINGS.ENABLE_ZOOM,
    [bvmsUrl]: ADVANCED_SETTINGS.BVMS,
    [additionInfoUrl]: ADVANCED_SETTINGS.ADDITION_INFO
  };

  const advancedCorrespondName = {
    [ADVANCED_SETTINGS.ENABLE_ZOOM]: FUNC_STATUS_LIST_LARGEDISP,
    [ADVANCED_SETTINGS.BVMS]: FUNC_TREATMENT_RECORD_lIST_BVMS,
    [ADVANCED_SETTINGS.ADDITION_INFO]: FUNC_TREATMENT_RECORD_LIST_ADDITIONINFO
  };

  const advcdValues = advancedCorrespondences[to.path];
  if (advcdValues && !advcdValuesList.includes(advcdValues)) {
    if (to.meta) {
      to.meta.depth = 2;
    }
    showPermissionAlert(advancedCorrespondName[advcdValues]);
    store.dispatch("bread-crumb/resetKeepHistory");
    return { name: getInitialRouterName() };
  }

  return true;
});

/**
 * beforeEach 2
 * WhitePage対策
 */
router.beforeEach((to) => {
  if (!to.matched.length) {
    return { name: getInitialRouterName() };
  }
  return true;
});

/**
 * beforeEach 3
 * アクセス履歴管理
 */
router.beforeEach((to, from) => {
  const toRoute = hydrateLegacyRouteParams(to);
  const toParams = toRoute?.params || {};
  const toQuery = toRoute?.query || {};
  if (toRoute.meta.depth) {
    store.dispatch("bread-crumb/setFromName", { fromName: from.name });
    store.dispatch("window-size/resetCurrentDepth");
    store.dispatch("window-size/setCurrentDepth", toRoute.meta.depth);

    let accessKey = "footer";
    let hasSameName = true;

    if (
      !Object.prototype.hasOwnProperty.call(toParams, "footer") &&
      !Object.prototype.hasOwnProperty.call(toQuery, "footer")
    ) {
      const keepHistoryList = store.getters["bread-crumb/getKeepHistory"].map(
        (item) => item.routerName
      );
      hasSameName = false;
      if (!keepHistoryList.includes(toRoute.name)) {
        accessKey = null;
        hasSameName = true;
      }
    }

    if (hasSameName) {
      store.dispatch("bread-crumb/addKeepHistory", {
        depth: toRoute.meta.depth,
        title: toRoute.meta.title,
        routerName: toRoute.name,
        historyKey: toRoute.meta.historyKey,
        accessKey
      });
    }

    store.dispatch("bread-crumb/addHistory", {
      depth: toRoute.meta.depth,
      title: toRoute.meta.title,
      routerName: toRoute.name,
      historyKey: toRoute.meta.historyKey
    });
  } else {
    store.dispatch("bread-crumb/resetHistory");
  }

  return true;
});

/**
 * beforeEach 4
 * ログイン画面・モーダル初期化
 */
router.beforeEach((to) => {
  if (to.name === "signin") {
    store.dispatch("account-edit/resetTheme");
  }

  store.dispatch("multi-modal/hideModal");
  store.dispatch("multi-sub-modal/hideModal");

  return true;
});

router.afterEach((to) => {
  const isAdminUser = store.getters["user/isAdminUser"];
  if (
    isAdminUser &&
    to.meta.historyKey === HISTORY_KEY_OPERATION_VIEWER_MACHINE
  ) {
    const facilityName = store.getters["operation-viewer/machine/getFacilityName"];
    store.dispatch("bread-crumb/resetTitle", {
      depth: to.meta.depth,
      newTitle: `${to.meta.title}(${facilityName})`
    });
  }
});

router.afterEach((to) => {
  if (to.meta.historyKey === HISTORY_KEY_MASTER_MAINTENANCE_RECORD) {
    const masterName = store.getters["master-maintenance/getLogicalMasterName"];
    store.dispatch("bread-crumb/resetTitle", {
      depth: to.meta.depth,
      newTitle: `${to.meta.title}(${masterName})`
    });
  }
});

// mod #12152 治療記録の各詳細画面で機能帳票が無効化する 高 start
// router.afterEach(() => {
//   // 機能コードから帳票マスタ情報を取得
//   const funcCd = getCurrentFunctionCd();
//   if (funcCd) {
//     // mod FNSI-#522、IES364 選択された機能により、対象の帳票を表示する。 夏 start
//     //store.dispatch("report/getMstReport", funcCd);
//     store.dispatch("report/getMstReport", {funcCd: funcCd,printFlag: 0});
//     // mod FNSI-#522、IES364 選択された機能により、対象の帳票を表示する。 夏 end
//   }
// });
router.beforeResolve(async () => {
  const funcCd = getCurrentFunctionCd();
  if (funcCd) {
    await fetchMstReportOnce(funcCd, 0);
  }
  return true;
});
// mod #12152 治療記録の各詳細画面で機能帳票が無効化する 高 end

// ルーター定義
export default router;
