/**
 * ユーザー選択ポップオーバー系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";
import store from "@/stores";

function withSelectedPatId(params = undefined, selectedPatId) {
  if (selectedPatId === null || selectedPatId === undefined || selectedPatId === "") {
    return params;
  }
  return {
    ...(params || {}),
    selectedPatId
  };
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
 * 職種マスタ情報取得.
 * @param {string} facilityCd 施設コード
 */
export function sendRequestMstGetJobs(facilityCd, selectedPatId) {
  return getWithLoader(
    `/master_maintenance/mst_user/mst_job/${facilityCd}`,
    withSelectedPatId(undefined, selectedPatId)
  );
}

/**
 * 利用者マスタ取得.
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetMstPersonalUser(facilityCd, selectedPatId) {
  return getWithLoader(
    "/mstInfo/mstPersonalUser",
    withSelectedPatId({ facility_cd: facilityCd }, selectedPatId)
  );
}
