/**
 * 加算系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";
import store from "@/stores";

const MAIN_DATA = "/api/mainData";

/**
 * サインインしているユーザが所属する施設コードを取得.
 */
function getUserFacilityCd() {
  return store.getters["user/getFacilityCd"];
}

/**
 * マスターデータ取得.
 * @param {string} url マスター取得API用URL
 */
function getMaster(url) {
  return getWithLoader(url, {
    facilityCd: getUserFacilityCd()
  });
}

/**
 * 加算情報取得
 * @param {Record<string, unknown>} params クエリパラメータ
 */
export function sendRequestGetByTreatInfo(params) {
  return ApiHelper.get("/mainData/addition-info", {
    ...params,
    selectedPatId: params.selectedPatId ?? params.patId
  });
}

/**
 * 指定患者の加算情報取得
 * @param {{ facilityCd: string; patId: string|number }} params
 */
export function sendRequestGetPatAddInfo(params) {
  return getWithLoader(
    `/patInfo/pat-addition-info/${params.facilityCd}/${params.patId}`
  );
}

/**
 * 略称リスト取得
 * @param {Record<string, unknown>} params クエリパラメータ
 */
export function sendRequestGetShortNameList(params) {
  return getWithLoader(`${MAIN_DATA}/shortname-list`, params);
}

/**
 * 実績加算情報更新
 * @param {Record<string, unknown>} params 更新ペイロード
 */
export function sendRequestPutOrdAdditionList(params) {
  return putWithLoader("/mainData/updateOrdAdditionInfo", params);
}

/**
 * 加算マスター取得
 */
export function sendRequestGetMstAddition(facilityCd) {
  if (facilityCd) {
    return ApiHelper.get("/mstInfo/mstAddition", { facilityCd });
  }
  return getMaster("/mstInfo/mstAddition");
}

/**
 * 加算情報毎の前回算定日取得
 * @param {Record<string, unknown>} params クエリパラメータ
 */
export function sendRequestGetAdditionDateList(params) {
  return ApiHelper.get("/addition_info/calculationDateList", params);
}

/**
 * 共通ローダを実行するGETリクエスト
 * @param {string} url URL
 * @param {Record<string, unknown>} [params] パラメータ
 */
function getWithLoader(url, params = undefined) {
  store.dispatch("loading-screen/setLoadingScreenMessage", "処理中・・・");
  store.dispatch("loading-screen/setLoadingScreenVisible", true);
  return ApiHelper.get(url, params).finally(() =>
    store.dispatch("loading-screen/setLoadingScreenVisible", false)
  );
}

/**
 * 共通ローダを実行するPUTリクエスト
 * @param {string} url URL
 * @param {unknown} params パラメータ
 */
function putWithLoader(url, params) {
  store.dispatch("loading-screen/setLoadingScreenMessage", "処理中・・・");
  store.dispatch("loading-screen/setLoadingScreenVisible", true);
  return ApiHelper.put(url, params).finally(() =>
    store.dispatch("loading-screen/setLoadingScreenVisible", false)
  );
}
