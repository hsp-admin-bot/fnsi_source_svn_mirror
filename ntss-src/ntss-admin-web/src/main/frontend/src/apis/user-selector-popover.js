import { ApiHelper } from "@/apis/AxiosHelper";
import store from "@/stores";

/**
 * 共通ローダを実行するGETリクエスト
 * @param {*} url URL
 * @param {*} param パラメータ
 */
function getWithLoader(url, params) {
  store.dispatch("loading-screen/setLoadingScreenMessage", "処理中・・・");
  store.dispatch("loading-screen/setLoadingScreenVisible", true);
  return ApiHelper.get(url, params).finally(() =>
    store.dispatch("loading-screen/setLoadingScreenVisible", false)
  );
}

/**
 * 職種マスタ情報取得.
 * @param {*} facilityCd 施設コード
 */
export function sendRequestMstGetJobs(facilityCd) {
  return getWithLoader(`/master_maintenance/mst_user/mst_job/${facilityCd}`);
}

/**
 * 利用者マスタ取得.
 * @param {*} facilityCd 施設コード
 */
export function sendRequestGetMstPersonalUser(facilityCd) {
  return getWithLoader("/mstInfo/mstPersonalUser", { facility_cd: facilityCd });
}
