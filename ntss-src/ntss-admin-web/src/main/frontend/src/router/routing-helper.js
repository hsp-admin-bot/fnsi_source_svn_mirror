/**
 * ルーティング補助機能
 */
import store from "@/stores";
import {
  FUNC_OPERATION_VIEWER,
  FUNC_OBSERVE_RECORD
} from "@/constants/function-code";
import { USER_TYPE_ADMIN } from "@/stores/UserStore";
import RoutingDefs from "@/router/json/routing-defs.json";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";

const ROUTING_ITEMS = RoutingDefs.routing_defs.routing_items;

/**
 * メニュー要素を取得
 * @param {*} functionCd 機能コード
 * @param {*} userType ユーザタイプ(省略可)
 */
export function getRouterItem(functionCd, userType) {
  if (functionCd === FUNC_OPERATION_VIEWER && userType) {
    const _userType = userType.toString();
    return ROUTING_ITEMS.find(item => {
      return item.function_cd === functionCd && item.user_type === _userType;
    });
  }
  return ROUTING_ITEMS.find(item => {
    return (
      item.function_cd === functionCd && item.user_type !== USER_TYPE_ADMIN
    );
  });
}

/**
 * ルート名を取得
 * @param {*} functionCd 機能コード
 * @param {*} userType ユーザタイプ(省略可)
 */
export function getRouterName(functionCd, userType) {
  const pattern = /^[0-9]{5}$/;
  if (pattern.test(functionCd)) {
    // functionCdが5桁の数値だった場合
    const funcCd = functionCd.slice(0, 3);
    const item = getRouterItem(funcCd, userType);
    const funcDetailCd = item.function_detail_cd.findIndex((element) => element === functionCd.slice(3, 5));
    return item ? item.routes[funcDetailCd] : "";
  } else {
    
    // メニューグループの場合は配下項目のfunction_cd取得
    const funcCd = getFunctionCdForMenuGroup(functionCd);
    
    // 既存処理
    const item = getRouterItem(funcCd, userType);
    return item ? item.router_name : "";
  }
}

/**
 * 指定された機能コードに該当する要素を取得する
 * @param {*} functionCd 機能コード
 */
export function getRouterItemsByFunctionCd(functionCd) {
  return ROUTING_ITEMS.filter(item => item.function_cd === functionCd);
}

/**
 * 初期設定画面(ルーター名)取得
 */
export function getInitialRouterName() {
  let initFuncCd = store.getters["account-edit/getInitialFunction"];
  
  // メニューグループの場合は配下項目のfunction_cd取得
  initFuncCd = getFunctionCdForMenuGroup(initFuncCd);
  
  const fCd =
    initFuncCd === "" || initFuncCd === null
      ? FUNC_OPERATION_VIEWER
      : initFuncCd;
  if (store.getters["user/isGeneralUser"] && fCd === FUNC_OPERATION_VIEWER) {
    // 顧客かつ稼働ビューアを初期表示メニューに設定しているユーザーの場合
    const facilityCd = store.getters["user/getFacilityCd"];
    store.dispatch("operation-viewer/machine/setFacilityCd", facilityCd);
  }
  return getRouterName(fCd, store.getters["user/getUserType"]);
}

export function getNameA(code) {
  let initFuncCd = code;
  // メニューグループの場合は配下項目のfunction_cd取得
  initFuncCd = getFunctionCdForMenuGroup(initFuncCd);

  const fCd =
    initFuncCd === "" || initFuncCd === null
      ? FUNC_OPERATION_VIEWER
      : initFuncCd;
  if (store.getters["user/isGeneralUser"] && fCd === FUNC_OPERATION_VIEWER) {
    // 顧客かつ稼働ビューアを初期表示メニューに設定しているユーザーの場合
    const facilityCd = store.getters["user/getFacilityCd"];
    store.dispatch("operation-viewer/machine/setFacilityCd", facilityCd);
  }
  return getRouterName(fCd, store.getters["user/getUserType"]);
}

/**
 * 現在表示中画面の機能コードを取得.
 */
export function getCurrentFunctionCd() {
  // パンくずの一番右に表示されている機能を取得
  const history = store.getters["bread-crumb/getHistory"];
  const routerName = history.length > 0 ? history[history.length - 1].routerName : "";
  const item = ROUTING_ITEMS.find(e => {
    return (
      e.router_name === routerName ||
      (e.routes && e.routes.includes(routerName))
    );
  });

  if (item) {
    // 機能コード取得（3バイト）
    let funcCd = item.function_cd;
    // 子機能コード（5バイト）
    let funcDetailCd;

    // 特殊処理
    if (funcCd === FUNC_OPERATION_VIEWER) {
      // 遠隔監視の場合
      const postFixes = ["facilities", "machines", "record", "detail"];
      const subRouteIndex = postFixes.findIndex(e => routerName.endsWith(e)) + 1;
      funcDetailCd = funcCd + ("0" + subRouteIndex).slice(-2);
    } else if (routerName === "treatment-record-observation") {
      // 観察記録の場合
      funcDetailCd = FUNC_OBSERVE_RECORD + "01";
    } else {
      // 上記以外
      // routes要素があれば、routerNameに該当するインデックスを取得
      let subRouteIndex = item.routes ? item.routes.indexOf(routerName) : -1;
      // routes要素がない場合、3バイトに機能コードを返却
      if (subRouteIndex < 0) {
        return funcCd;
      }
      funcDetailCd = item.function_detail_cd ? funcCd + item.function_detail_cd[subRouteIndex] : funcCd;
    }
    // 5バイトの機能コードを返却
    return funcDetailCd;
  }

  // 機能コードが判別できなかった
  return null;
}

/**
 * 指定された機能名に該当する要素を取得する
 * @param {*} routerName 機能名
 */
export function getRouterItemByRouterName(routerName) {
  return ROUTING_ITEMS.find(item => {
    return item.router_name === routerName;
  });
}

/**
 * 機能コードを取得
 * @param {*} routerName 機能名
 */
export function getFunctionCd(routerName) {
  const item = getRouterItemByRouterName(routerName);
  return item ? item.function_cd : "";
}

/**
 *  機能コード取得
 *  メニューグループの場合、画面遷移は以下の仕様に準拠
 *    外部リンクメニュー・未許可メニューを除いた配下項目で並び順上方のものを優先に起動する。
 *    上記にもとづいた対象が存在しない場合は、メニュー設定最上位の外部リンクメニューとメニューグループを除いたメニューを対象とする。
 *    それも存在しない場合は、許可されているメニューが1つは存在するのでそれを表示する。
 */
function getFunctionCdForMenuGroup(funcCd) {
  
  if (!funcCd.startsWith("group")) {
    // メニューグループ以外は元の機能コードをそのままreturn
    return funcCd;
  }

  const authorizedFunctions = store.getters["account-edit/getAuthorizedFunctions"]; // 利用者マスタ＞許可機能
  const useFunctions = store.getters["account-edit/getUseFunctions"]; // メニューバー設定
  const menuGroupList = store.getters["mst-menu-group/getMenuGroupList"]; // メニューグループマスタ

  // 外部リンクメニュー・未許可メニューを除いた配下項目で並び順上方のものを優先に起動する。
  const menuGroupCd = +funcCd.split("-")[1];
  const menuGroup = menuGroupList.find(group => +group.menuGroupCd === menuGroupCd);
  if (!menuGroup) {
    getErrorMessage("routing-helper.js", "getFunctionCdForMenuGroup", `メニューグループマスタが見つかりません menuGroupCd: ${menuGroupCd}`);
    throw new Error(`メニューグループマスタが見つかりません menuGroupCd: ${menuGroupCd}`);
  }
  
  const filteredMenuList = menuGroup.menuList.filter(
    item =>
      authorizedFunctions.includes(item) &&
      useFunctions.includes(item) &&
      !item.startsWith("url")
  );
  if (filteredMenuList.length > 0) {
    return filteredMenuList[0];
  }

  // 上記にもとづいた対象が存在しない場合は、メニュー設定最上位の外部リンクメニューとメニューグループを除いたメニューを対象とする。
  const validMenuList = useFunctions.filter(
    item => authorizedFunctions.includes(item) && !item.startsWith("url") && !item.startsWith("group")
  );
  if (validMenuList.length > 0) {
    return validMenuList[0];
  }
  
  // それも存在しない場合は、許可されているメニューが1つは存在するのでそれを表示する。
  const fallbackMenu = authorizedFunctions.find(item => !item.startsWith("url") && !item.startsWith("group"));
  if (!fallbackMenu) {
    getErrorMessage("routing-helper.js", "getFunctionCdForMenuGroup", "許可されているメニューがありません");
    throw new Error("許可されているメニューがありません");
  }
  return fallbackMenu;
}

