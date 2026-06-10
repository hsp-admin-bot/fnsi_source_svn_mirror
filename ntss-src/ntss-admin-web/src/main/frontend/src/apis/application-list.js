/**
 * 申し込みリスト系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

import { dateFormat } from "@/functions/common/DateTimeUtils.js";
/**
 * 一時的ストア
 */
import store from "@/stores";

const functionName = '/salSubscriptionManage';
const PAGE = 'page';
const PER_PAGE = 'per_page';

/**
 * すべての申込データ取得。
 * @param {Object} condition 検索条件
 */
export function sendRequestGetAll(condition, page = null, perPage = null) {
  const dataCondition = { ...condition };
  if (dataCondition.startDate === "") {
    dataCondition.startDate = null;
  } else {
    dataCondition.startDate = dateFormat.queueDate(new Date(dataCondition.startDate));
  }
  if (dataCondition.endDate === "") {
    dataCondition.endDate = null;
  } else {
    dataCondition.endDate = dateFormat.queueDate(new Date(dataCondition.endDate));
  }
  if (dataCondition.prefecturesCd === "すべて") dataCondition.prefecturesCd = null;
  if (dataCondition.departmentCd === "すべて") dataCondition.departmentCd = null;
  if (dataCondition.freeWord === "") dataCondition.freeWord = null;
  if (page === null || perPage === null) {
    return postWithLoader(`${functionName}/getSalSubSearchResult`, dataCondition);
  }
  return postWithLoader(`${functionName}/getSalSubSearchResult?${PAGE}=${page}&${PER_PAGE}=${perPage}`, dataCondition);
}

/**
 * 申し込みの状態を受付済に更新する。
 * @param {Object} subscriptionNo 申込番号
 */
export function sendUpdateReception(subscriptionNo) {
  let subscriptionStatus = {
    "subscriptionStatus": "1"
  };
  return putWithLoader(`${functionName}/updateReception/${subscriptionNo}`, subscriptionStatus);
}

/**
 * 申し込みの状態を完了済に更新する。
 * @param {Object} subscriptionNo 申込番号
 */
export function sendUpdateCompletion(subscriptionNo) {
  let subscriptionStatus = {
    "subscriptionStatus": "2"
  };
  return putWithLoader(`${functionName}/updateCompletion/${subscriptionNo}`, subscriptionStatus);
}

/**
 * 申し込みの状態をキャンセル済に更新する。
 * @param {Object} subscriptionNo 申込番号
 */
export function sendUpdateCancel(subscriptionNo) {
  let subscriptionStatus = {
    "subscriptionStatus": "9"
  };
  return putWithLoader(`${functionName}/updateCancel/${subscriptionNo}`, subscriptionStatus);
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

/**
 * 共通ローダを実行するPOSTリクエスト
 * @param {String} url URL
 * @param {any} params パラメータ
 */
function postWithLoader(url, params) {
  store.dispatch("loading-screen/setLoadingScreenMessage", "処理中・・・");
  store.dispatch("loading-screen/setLoadingScreenVisible", true);
  return ApiHelper.post(url, params).finally(() =>
    store.dispatch("loading-screen/setLoadingScreenVisible", false)
  );
}