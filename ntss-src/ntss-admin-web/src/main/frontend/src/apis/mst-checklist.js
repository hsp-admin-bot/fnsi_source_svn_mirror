/**
 * チェックリストリストマスタ設定系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";
import store from "@/stores";

/**
 * チェックリストマスタ設定用URL
 */
const URL_BASE_MST_CHECKLIST = "checklist_setting";

/**
 * 自動更新時のバックグラウンド呼び出し用クエリ（check-list と同様）
 * @returns {string} 空文字 or "?__background_call__=true"
 */
function getMstChecklistBackgroundQuery() {
  const forceSignOutFlag = store.getters["check-list/list/getForceSignOutFlag"];
  return forceSignOutFlag === 0 ? "?__background_call__=true" : "";
}

/**
 * チェックリストマスタ設定情報取得
 * @param {{ facilityCd: string; autoRefreshFlag?: boolean }} param 施設コード、自動更新フラグ
 */
export function sendRequestGetMstChecklist(param) {
  const baseUrl = `${URL_BASE_MST_CHECKLIST}/get/${param.facilityCd}`;
  const requestUrl = param.autoRefreshFlag
    ? `${baseUrl}${getMstChecklistBackgroundQuery()}`
    : baseUrl;
  return ApiHelper.get(requestUrl);
}

/**
 * 医療材料分類マスタ情報取得
 * @param {{ facilityCd: string }} param 施設コード
 */
export function sendRequestGetMstEquipClass(param) {
  return ApiHelper.get(
    `${URL_BASE_MST_CHECKLIST}/get/equip-class/${param.facilityCd}`
  );
}

/**
 * チェックリストマスタ設定の新規登録
 * @param {Record<string, unknown>} params 登録データ
 */
export function sendRequestInsertMstChecklist(params) {
  return ApiHelper.post(`${URL_BASE_MST_CHECKLIST}/insert`, params);
}

/**
 * チェックリストマスタ設定の更新登録
 * @param {Record<string, unknown>} params 登録データ
 */
export function sendRequestUpdateMstChecklist(params) {
  return ApiHelper.put(`${URL_BASE_MST_CHECKLIST}/update`, params);
}
