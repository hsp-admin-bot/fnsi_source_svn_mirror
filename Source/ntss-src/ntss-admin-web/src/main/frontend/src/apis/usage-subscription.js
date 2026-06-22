/**
 * 利用申込系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";
import store from "@/stores";

/**
 * 利用申込用URL
 */
const URL_MST_INFO = "/mstInfo";
const URL_SAL_SUBSCRIPTION_MANAGE = "/salSubscriptionManage";

/**
 * すべての機能を取得する
 * @param {string} facilityCd 施設コード
 */
export function getSysAllFunction(facilityCd) {
  return getWithLoader(`${URL_MST_INFO}/sysAllFunction/${facilityCd}`);
}

/**
 * すべてのサブスクリプション注文を取得する
 * @param {string} facilityCd 施設コード
 */
export function getSalSubscriptionManage(facilityCd) {
  return getWithLoader(`${URL_SAL_SUBSCRIPTION_MANAGE}/getSalSubscriptionManage/${facilityCd}`);
}

/**
 * プランを取得
 */
export function sendRequestGetPlan() {
  return getWithLoader(`${URL_MST_INFO}/sysSubscriptionPlan`);
}

/**
 * 申請受付
 * @param {string|number} subscriptionNo サブスクリプション番号
 */
export function sendRequestUpdateReception(subscriptionNo) {
  const param = {
    subscriptionStatus: "1"
  };
  return putWithLoader(`${URL_SAL_SUBSCRIPTION_MANAGE}/updateReception/${subscriptionNo}`, param);
}

/**
 * 申し込み完了
 * @param {string|number} subscriptionNo サブスクリプション番号
 */
export function sendRequestUpdateCompletion(subscriptionNo) {
  const param = {
    subscriptionStatus: "2"
  };
  return putWithLoader(`${URL_SAL_SUBSCRIPTION_MANAGE}/updateCompletion/${subscriptionNo}`, param);
}

/**
 * アプリケーションのキャンセル
 * @param {string|number} subscriptionNo サブスクリプション番号
 */
export function sendRequestUpdateCancel(subscriptionNo) {
  const param = {
    subscriptionStatus: "9"
  };
  return putWithLoader(`${URL_SAL_SUBSCRIPTION_MANAGE}/updateCancel/${subscriptionNo}`, param);
}

/**
 * クライアントで作成したアプリケーション
 * @param {Record<string, unknown>} param 登録内容
 */
export function createSalSubscriptionManage(param) {
  return postWithLoader(`${URL_SAL_SUBSCRIPTION_MANAGE}`, param);
}

/**
 * nkkによるアプリケーションの作成
 * @param {Record<string, unknown>} param 登録内容
 */
export function createByAdmin(param) {
  return postWithLoader(`${URL_SAL_SUBSCRIPTION_MANAGE}/createByAdmin`, param);
}

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
