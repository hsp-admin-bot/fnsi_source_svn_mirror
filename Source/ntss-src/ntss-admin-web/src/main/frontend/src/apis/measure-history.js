/**
 * 体重計測定記録系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";
import store from "@/stores";

/**
 * 体重計測定記録用URL
 */
const MEASURE_HISTORY = "/measure_history";

/**
 * 情報取得
 * @param {{ FacilityCd: string; startDate: string; endDate: string }} params 施設コード、開始日、終了日
 */
export function sendRequestGetMeasureHistory(params) {
  return getWithLoader(
    `${MEASURE_HISTORY}/order/${params.FacilityCd}/${params.startDate}/${params.endDate}`
  );
}

/**
 * 単体情報取得
 * @param {number} primaryKey
 */
export function sendRequestGetSingleHistory(primaryKey) {
  return getWithLoader(`${MEASURE_HISTORY}/get/${primaryKey}`);
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
