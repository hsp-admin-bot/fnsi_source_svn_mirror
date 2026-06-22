/**
 * 患者/スケジュール割り当て系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";
import store from "@/stores";
import { getCurrentRoutePath } from "@/compat/vue/router-facade.js";

/**
 * 患者/スケジュール割り当てURL
 */
const SCHEDULE_ASSIGNMENT = "/schedule-assignment";

/**
 * 指定オーダー番号のスケジュール情報取得
 * @param {string|number} ordNo オーダー番号
 */
export function sendRequestGetOrdMainByOrdNo(ordNo) {
  return getWithLoader(`${SCHEDULE_ASSIGNMENT}/getorder/${ordNo}`);
}

/**
 * 患者一覧情報取得
 */
export function sendRequestGetPatList() {
  return getWithLoader(`${SCHEDULE_ASSIGNMENT}/getpatlist`);
}

/**
 * 対象のスケジュール一覧情報取得
 * @param {{ startDate: string, endDate: string, bedCd: string }} param 検索条件
 */
export function sendRequestGetScheduleList(param) {
  return getWithLoader(
    `${SCHEDULE_ASSIGNMENT}/getschedulelist/${param.startDate}/${param.endDate}/${param.bedCd}`
  );
}

/**
 * 患者割り当て
 * @param {{ patId: string|number, ordNo: string|number }} param 患者ID・オーダー番号
 */
export function sendRequestPatAssignment(param) {
  return postWithLoader(
    `${SCHEDULE_ASSIGNMENT}/patassignment/${param.patId}/${param.ordNo}`
  );
}

/**
 * スケジュール割り当て
 * @param {{ baseOrdNo: string|number, ordNo: string|number, rstInputClass: string }} param 割当パラメータ
 */
export function sendRequestScheduleAssignment(param) {
  const path = getCurrentRoutePath();
  let flg = "list";
  if (path) {
    flg = /status-list/.test(path) ? "list" : "map";
  }

  return postWithLoader(
    `${SCHEDULE_ASSIGNMENT}/scheduleassignment/${param.baseOrdNo}/${
      param.ordNo
      // mod FNSI-？？？？患者割り当て 徐 start
      // }`
      }/${
      param.rstInputClass
      // mod FNSI-外部連携api呼び出対応 陳 start
      // }`
      }/${
        // param.flg
        flg
      }`
      // mod FNSI-外部連携api呼び出対応 陳 end
      // mod FNSI-？？？？患者割り当て 徐 end
  );
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
 * 共通ローダを実行するPOSTリクエスト
 * @param {string} url URL
 * @param {unknown} [params] パラメータ
 */
function postWithLoader(url, params) {
  store.dispatch("loading-screen/setLoadingScreenMessage", "処理中・・・");
  store.dispatch("loading-screen/setLoadingScreenVisible", true);
  return ApiHelper.post(url, params).finally(() =>
    store.dispatch("loading-screen/setLoadingScreenVisible", false)
  );
}
