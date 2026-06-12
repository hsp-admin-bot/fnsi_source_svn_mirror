/**
 * 標準医薬品マスタ用API
 */
import { ApiHelper } from "@/apis/AxiosHelper";
import store from "@/stores";

/**
 * 標準医薬品マスタAPIのベースURL
 */
const URL_BASE = "/sys_medicine";

/**
 * 共通ローダを実行するGETリクエスト
 * @param {string} url URL
 * @param {unknown} [params] パラメータ
 */
function getWithLoader(url, params = undefined) {
  store.dispatch("loading-screen/setLoadingScreenMessage", "処理中・・・");
  store.dispatch("loading-screen/setLoadingScreenVisible", true);
  return ApiHelper.get(url, params).finally(() =>
    store.dispatch("loading-screen/setLoadingScreenVisible", false)
  );
}

/**
 * 標準医薬品マスタを取得する.
 * @returns {Promise} 標準医薬品マスタのリスト
 */
export function sendRequestGetSysMedicineAll() {
  return getWithLoader(`${URL_BASE}/getSysMedicineAll`);
}
