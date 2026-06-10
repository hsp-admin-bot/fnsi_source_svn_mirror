/**
 * 加算系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";
import store from "@/stores";

/**
 * 加算用URL
 */
const MAIN_DATA = "/api/mainData";

/**
 * サインインしているユーザが所属する施設コードを取得.
 */
function getUserFacilityCd() {
  return store.getters["user/getFacilityCd"];
}

/**
 * マスターデータ取得.
 * @param {*} url マスター取得API用URL
 */
function getMaster(url) {
  return getWithLoader(url, {
    facilityCd: getUserFacilityCd()
  });
}

/**
 * 加算情報取得
 * @param {*} params
 * @param {number} facilityCd 施設コード
 * @param {number} patId 患者ID
 * @param {number} ordNo オーダー番号
 */
export function sendRequestGetByTreatInfo(params) {
  return ApiHelper.get("/mainData/addition-info", params);
}

/**
 * 指定患者の加算情報取得
 * @param {number} facilityCd 施設コード
 * @param {number} patId 患者ID
 */
export function sendRequestGetPatAddInfo(params) {
  return getWithLoader(
    `/patInfo/pat-addition-info/${params.facilityCd}/${params.patId}`
  );
}

/**
 * 略称リスト取得
 * @param {number} facilityCd 施設コード
 * @param {number} patId 患者ID
 * @param {number} ordNo オーダー番号
 */
export function sendRequestGetShortNameList(params) {
  return getWithLoader(
    `${MAIN_DATA}/shortname-list`, params
  );
}

/**
 * 実績加算情報更新
 * @param {*} params 施設コード
 * @param {number} facilityCd 施設コード
 * @param {number} patId 患者ID
 * @param {number} ordNo オーダー番号
 */
export function sendRequestPutOrdAdditionList(params) {
  return putWithLoader(
    `/mainData/updateOrdAdditionInfo`, params
  );
}

/**
 * 加算マスター取得
 */
  // mod #12462 患者情報共有 Ji start
export function sendRequestGetMstAddition(facilityCd) {
  // return getMaster("/mstInfo/mstAddition");
  return ApiHelper.get("/mstInfo/mstAddition", { facilityCd });
  // mod #12462 患者情報共有 Ji end
}

/**
 * 加算情報毎の前回算定日取得
 * @param {*} params
 * @param {number} ordNo オーダー番号
 * @param {number} patId 患者ID
 * @param {String} treatDate 治療日 YYYYMMDD
 */
export function sendRequestGetAdditionDateList(params) {
  return ApiHelper.get("/addition_info/calculationDateList", params);
}

/**
 * 共通ローダを実行するGETリクエスト
 * @param {String} url URL
 * @param {any} params パラメータ
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
 * @param {String} url URL
 * @param {any} params パラメータ
 */
function putWithLoader(url, params) {
  store.dispatch("loading-screen/setLoadingScreenMessage", "処理中・・・");
  store.dispatch("loading-screen/setLoadingScreenVisible", true);
  return ApiHelper.put(url, params).finally(() =>
    store.dispatch("loading-screen/setLoadingScreenVisible", false)
  );
}
