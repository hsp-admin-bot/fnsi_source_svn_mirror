/**
 * 治療状況ベッドレイアウトAPI
 */
import { ApiHelper } from "@/apis/AxiosHelper";
import store from "@/stores";

/**
 * 治療状況ベッドレイアウト用URL
 */
const URL_BASE_BED_LAYOUT = "/bed_layout";

/**
 * ベッドレイアウトリストの取得
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetBedLayoutList(facilityCd) {
  return getWithLoader(`${URL_BASE_BED_LAYOUT}/${facilityCd}`);
}

/**
 * ベッドリストの取得
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetMstBed(facilityCd) {
  const URL_BASE_MST_BED = "mst_bed";
  return getWithLoader(
    `${URL_BASE_BED_LAYOUT}/${URL_BASE_MST_BED}/${facilityCd}`
  );
}

/**
 * ベッドレイアウト一件の取得
 * @param {string} facilityCd 施設コード
 * @param {string|number} layoutId レイアウトID
 */
export function sendRequestGetBedLayout(facilityCd, layoutId) {
  return getWithLoader(`${URL_BASE_BED_LAYOUT}/${facilityCd}/${layoutId}`);
}

/**
 * ベッドレイアウトの新規登録
 * @param {Record<string, unknown>} params 登録データ
 */
export function sendRequestInsertBedLayout(params) {
  return postWithLoader(`${URL_BASE_BED_LAYOUT}/insert`, params);
}

/**
 * ベッドレイアウトの更新
 * @param {Record<string, unknown>} params 更新データ
 */
export function sendRequestUpdateBedLayout(params) {
  return putWithLoader(`${URL_BASE_BED_LAYOUT}/update`, params);
}

/**
 * 装置リストの取得（ベッドレイアウト配下）
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetMstMachine(facilityCd) {
  return getWithLoader(`${URL_BASE_BED_LAYOUT}/mst_machine/${facilityCd}`);
}

/**
 * 型式マスタの取得
 */
export function sendRequestGetMachineType() {
  const uri = "/master_maintenance/mst_machine/mst_machine_type";
  return getWithLoader(uri);
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

/**
 * 共通ローダを実行するPOSTリクエスト
 * @param {string} url URL
 * @param {unknown} params パラメータ
 */
function postWithLoader(url, params) {
  store.dispatch("loading-screen/setLoadingScreenMessage", "処理中・・・");
  store.dispatch("loading-screen/setLoadingScreenVisible", true);
  return ApiHelper.post(url, params).finally(() =>
    store.dispatch("loading-screen/setLoadingScreenVisible", false)
  );
}
