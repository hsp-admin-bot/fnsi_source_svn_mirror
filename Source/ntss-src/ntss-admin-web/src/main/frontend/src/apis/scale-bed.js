/**
 * スケールベッド測定系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

import store from "@/stores";

/**
 * 一覧情報を取得
 * /scale_bed/view_list
 */
export function sendRequestGetScaleBedViewList(withLoader = true) {
  if (withLoader) {
    return getWithLoader(`/scale_bed/view_list`);
  }
  return ApiHelper.get(`/scale_bed/view_list`);
}
/**
 * 一覧情報を取得
 * /scale_bed/target_bed_list
 */
export function sendRequestGetScaleBedKeyList() {
  return getWithLoader(`/scale_bed/target_bed_list`);
}

/**
 * 条件送信
 * /scale_bed/send_condition
 * @param {Object} params
 * @param {Number} params.bedCd ベッドコード
 * @param {Number} params.weightCd 体重計管理コード
 * @param {Number} params.measureValue 測定値
 */
export function sendRequestPostSendConditionScaleBed(params) {
  return postWithLoader(`/scale_bed/send_condition`, params);
}

/**
 * 後体重送信
 * /scale_bed/send_after_weight
 * @param {Object} params
 * @param {Number} params.bedCd ベッドコード
 * @param {Number} params.weightCd 体重計管理コード
 * @param {Number} params.measureValue 測定値
 */
export function sendRequestPostSendAfterWeightScaleBed(params) {
  return postWithLoader(`/scale_bed/send_after_weight`, params);
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
 * 共通ローダを実行するPOSTリクエスト
 * @param {String} url URL
 * @param {any} params パラメータ
 */
function postWithLoader(url, params = undefined) {
  store.dispatch("loading-screen/setLoadingScreenMessage", "処理中・・・");
  store.dispatch("loading-screen/setLoadingScreenVisible", true);
  return ApiHelper.post(url, params).finally(() =>
    store.dispatch("loading-screen/setLoadingScreenVisible", false)
  );
}

