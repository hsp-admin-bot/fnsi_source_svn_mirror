import Vue from "vue";
import Router from "vue-router";
import store from "@/stores";
import _ from "underscore";

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
import { HISTORY_KEY_OPERATION_VIEWER_MACHINE } from "@/router/operation-viewer/HistoryKeyConstants";
import { HISTORY_KEY_MASTER_MAINTENANCE_RECORD } from "@/router/master-maintenance/HistoryKeyConstants";

import RoutingDefs from "@/router/json/routing-defs.json";
/* add by chamaojia 2022-12-06 [5958] 定数ファイル参照の追加 --start */
import {persistStorePaths} from "@/constants/persistStorePaths";
import {SESSION_STORAGE_KEY} from "@/constants/sessionStorageConstants";
/* add by chamaojia 2022-12-06 [5958] 定数ファイル参照の追加 --end */
// add #10359、#10331 編集権限について、対応する。 dengshen start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
import VueOnsen from "vue-onsenui";
// add #10359、#10331 編集権限について、対応する。 dengshen end
// mod #10371 編集権限について、対応する。 dengshen start
// add #10371 BVMS/加算情報の権限がないメッセージが表示され遷移できない 20241012 ztc start
import {
  FUNC_STATUS_LIST_LARGEDISP, FUNC_TREATMENT_RECORD_LIST_ADDITIONINFO,
  FUNC_TREATMENT_RECORD_lIST_BVMS,
  transAuthorityList
} from "@/constants/function-code";
// mod #10371 編集権限について、対応する。 dengshen end
import {ADVANCED_SETTINGS} from "@/constants/advancedSettings";
// add #10371 BVMS/加算情報の権限がないメッセージが表示され遷移できない 20241012 ztc end

Vue.use(Router);

const router = new Router({
  mode: "hash",
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

// redmine 4242 マスタ表示時、デベロッパーツールに"Uncaught (in promise) TypeError"と表示される 宋qy start
const originalPush = Router.prototype.push;
Router.prototype.push = function push(location) {
  return originalPush.call(this, location).catch(err => err);
}
// redmine 4242 マスタ表示時、デベロッパーツールに"Uncaught (in promise) TypeError"と表示される 宋qy end

/**
 * サインイン済かどうか
 */
function isLoggedIn() {
  const dispUserId = store.getters["user/getDispUserId"];
  return dispUserId !== null && dispUserId !== "";
}

// ナビゲーションガード
router.beforeEach((to, from, next) => {
  /* add by chamaojia 2022-12-06 [5958] vuexstoreへの永続的なデータの書き込みが必要 --start */
  const refreshFlag = sessionStorage.getItem(SESSION_STORAGE_KEY.REFRESH_FLAG)
  if (refreshFlag === "1") {
    for (const storePath of persistStorePaths) {
      const storeStr = sessionStorage.getItem(storePath);
      // 読みだしたらセッションストレージからは削除しておく
      sessionStorage.removeItem(storePath);
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
    sessionStorage.setItem(SESSION_STORAGE_KEY.REFRESH_FLAG, "9")
  }
  /* add by chamaojia 2022-12-06 [5958] vuexstoreへの永続的なデータの書き込みが必要 --end */
  // サインイン未済アクセス対策
  if (to.name !== "signin" && to.name !== "signinhome" && !isLoggedIn()) {
    // サインイン画面へ遷移
    next({ name: "signin" });
    return;
  }
  // 機能コードがない場合、権限処理 何 start
  const ROUTING_ITEMS = RoutingDefs.routing_defs.routing_items;
  const url = to.path.split("/");
  if (url) {
    // mod #10371 編集権限について、対応する。 dengshen start
    // const routerName = url[1];
    let routerName = url[1];
    if (routerName == "operation-viewer") {
      if (to.path == "/operation-viewer/machines") {
        routerName = "operation-viewer-general-machines";
      } else if (to.path == "/operation-viewer/facilities") {
        routerName = "operation-viewer-admin-facilities";
      } else {
        routerName = "operation-viewer-specified-motion-record";
      }
    }
    // add #10371 使用許可機能権限OFF時に動作不正 20240528 ztc start
    if (routerName == "treatment-record" && to.path == "/treatment-record/list/observation") {
      routerName = "observe-record";
    }
    // add #10371 使用許可機能権限OFF時に動作不正 20240528 ztc end
    // mod #10371 編集権限について、対応する。 dengshen end
    const item = ROUTING_ITEMS.find(e => {
      return (e.router_name === routerName ||
        (e.routes && e.routes.includes(routerName)));
    });
    // add #10359、#10331 編集権限について、対応する。 dengshen start
    // const userFuncs = store.getters["account-edit/getUseFunctions"];
    const userFuncs = store.getters["account-edit/getAuthorizedFunctions"];
    // add #10359、#10331 編集権限について、対応する。 dengshen start
    if (item && userFuncs) {
      if (userFuncs.indexOf(item.function_cd) == -1) {
        // add #10359、#10331 編集権限について、対応する。 dengshen start
        // 指定されたコードから機能名を取得
        const functionObj = Object.values(transAuthorityList).find(e => e.code === item.function_cd);
        Vue.use(VueOnsen);
        // add #10371 使用許可機能権限OFF時に動作不正 20240528 ztc start
        if(routerName == 'observe-record'){
          to.meta.depth = 2 && VueOnsen.notification.alert({
            title: DIALOG_MESSAGES[12000315].title,
            message: messageFormat(DIALOG_MESSAGES[12000315].message, functionObj.label)
          });
          next({ name: getInitialRouterName() });
          store.dispatch("bread-crumb/resetKeepHistory");
          return;
        } else{
          // add #10371 使用許可機能権限OFF時に動作不正 20240528 ztc end
          to.meta.depth < 2 && VueOnsen.notification.alert({
            // title: "権限エラー",
            // message: functionName+"を操作する権限がありません。管理者に確認してください。"
            title: DIALOG_MESSAGES[12000315].title,
            message: messageFormat(DIALOG_MESSAGES[12000315].message, functionObj.label)
          });
          // add #10359、#10331 編集権限について、対応する。 dengshen start
          //前URL戻る
          next({ name: from.name });
          return;
        }
      }
    }
    // add #10371 使用許可機能権限OFF時に動作不正 20240528 ztc start
    const advcdValuesList = [];
    const advancedSettings = store.getters["user/getAdvancedSettings"];
    if(advancedSettings) {
      Object.keys(advancedSettings).length && advancedSettings.func_advcds.forEach(item => {
        advcdValuesList.push(item.func_advcd);
      });
    }
    // mod #10371 BVMS/加算情報の権限がないメッセージが表示され遷移できない 20241012 ztc start
    const largedispUrl = '/status-list-large/largedisp';
    const bvmsUrl = '/treatment-record/list/bvms';
    const additionInfoUrl = '/treatment-record/list/addition-info';
    const advancedCorrespondences = {
      [largedispUrl]: ADVANCED_SETTINGS.ENABLE_ZOOM,
      [bvmsUrl]: ADVANCED_SETTINGS.BVMS,
      [additionInfoUrl]: ADVANCED_SETTINGS.ADDITION_INFO
    };
    const advancedCorrespondName = {
      // 拡張機能: 穿刺返血大画面表示
      [ADVANCED_SETTINGS.ENABLE_ZOOM]: FUNC_STATUS_LIST_LARGEDISP,
      // 拡張機能: BVMS
      [ADVANCED_SETTINGS.BVMS]: FUNC_TREATMENT_RECORD_lIST_BVMS,
      // 拡張機能: 加算情報
      [ADVANCED_SETTINGS.ADDITION_INFO]: FUNC_TREATMENT_RECORD_LIST_ADDITIONINFO
    };
    const advcdValues = advancedCorrespondences[to.path];
    if (advcdValues && !advcdValuesList.includes(advcdValues)) {
      Vue.use(VueOnsen);
      to.meta.depth = 2 && VueOnsen.notification.alert({
        title: DIALOG_MESSAGES[12000315].title,
        message: messageFormat(DIALOG_MESSAGES[12000315].message, advancedCorrespondName[advcdValues])
      });
      next({name: getInitialRouterName()});
      store.dispatch("bread-crumb/resetKeepHistory");
      return;
    }
    // mod #10371 BVMS/加算情報の権限がないメッセージが表示され遷移できない 20241012 ztc end
  }
  // add #10371 使用許可機能権限OFF時に動作不正 20240528 ztc end
  // 機能コードがない場合、権限処理 何 end
  next();
});
router.beforeEach((to, from, next) => {
  // WhitePage対策（不正URLアクセス検出）
  if (!to.matched.length) {
    // ナビゲーション停止 ＆ 初期画面へ遷移
    next({ name: getInitialRouterName() });
    return;
  }
  next();
});
router.beforeEach((to, from, next) => {
  // アクセス履歴管理
  if (to.meta.depth) {
    // ブラウザバック時にアクセス保持履歴から除外するための遷移元名を保持
    store.dispatch("bread-crumb/setFromName",{fromName: from.name});
    // 階層リセット＆設定
    store.dispatch("window-size/resetCurrentDepth");
    store.dispatch("window-size/setCurrentDepth", to.meta.depth);

    let accessKey = "footer";
    let hasSameName = true;
    if (!_.has(to.params, "footer")) {
      // footer以外から遷移なら
      const keepHistoryList = store.getters["bread-crumb/getKeepHistory"].map(
        item => item.routerName
      );
      hasSameName = false;
      if (!keepHistoryList.includes(to.name)) {
        // 重複していないならアクセス保持履歴追加
        accessKey = null;
        hasSameName = true;
      }
    }

    if (hasSameName) {
      store.dispatch("bread-crumb/addKeepHistory", {
        depth: to.meta.depth,
        title: to.meta.title,
        routerName: to.name,
        historyKey: to.meta.historyKey,
        accessKey
      });
    }

    // アクセス履歴追加
    store.dispatch("bread-crumb/addHistory", {
      depth: to.meta.depth,
      title: to.meta.title,
      routerName: to.name,
      historyKey: to.meta.historyKey
    });
  } else {
    // アクセス履歴リセット
    store.dispatch("bread-crumb/resetHistory");
  }
  next();
});
router.beforeEach((to, from, next) => {
  if (to.name === "signin") {
    // テーマリセット
    store.dispatch("account-edit/resetTheme");
  }
  // モーダル画面リセット
  store.dispatch("multi-modal/hideModal");
  // サブモーダル画面リセット
  store.dispatch("multi-sub-modal/hideModal");
  next();
});
router.afterEach(to => {
  const isAdminUser = store.getters["user/isAdminUser"];
  if (
    isAdminUser &&
    to.meta.historyKey === HISTORY_KEY_OPERATION_VIEWER_MACHINE
  ) {
    // パンくずに施設名を付加
    const facilityName =
      store.getters["operation-viewer/machine/getFacilityName"];
    store.dispatch("bread-crumb/resetTitle", {
      depth: to.meta.depth,
      newTitle: `${to.meta.title}(${facilityName})`
    });
  }
});
router.afterEach(to => {
  if (to.meta.historyKey === HISTORY_KEY_MASTER_MAINTENANCE_RECORD) {
    // マスタ編集：パンくずにマスタ名を付加
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
router.beforeResolve(async (to, from, next) => {
  const funcCd = getCurrentFunctionCd();
  if (funcCd) {
    await store.dispatch("report/getMstReport", { funcCd: funcCd, printFlag: 0 });
  }
  next();
});
// mod #12152 治療記録の各詳細画面で機能帳票が無効化する 高 end

// ルーター定義
export default router;
