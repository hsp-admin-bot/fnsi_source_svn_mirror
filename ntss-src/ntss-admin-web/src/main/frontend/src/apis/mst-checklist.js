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
 * チェックリストマスタ設定情報取得
 * @param {*} param 施設コード、自動更新フラグ
 */
export function sendRequestGetMstChecklist(param) {
  // 自動更新サインアウトON/OFFチェック
  const forceSignOutFlag = store.getters["check-list/list/getForceSignOutFlag"];
  const queryParams = forceSignOutFlag == 0 ? "?__background_call__=true" : "";
  const baseUrl = `${URL_BASE_MST_CHECKLIST}/get/${param.facilityCd}`;
  const requestUrl = param.autoRefreshFlag ? `${baseUrl}${queryParams}` : `${baseUrl}`;
  return ApiHelper.get(requestUrl);
}

/**
 * 医療材料分類マスタ情報取得
 * @param {*} param 施設コード
 */
export function sendRequestGetMstEquipClass(param) {
  return ApiHelper.get(
    `${URL_BASE_MST_CHECKLIST}/get/equip-class/${param.facilityCd}`
  );
}

/**
 * チェックリストマスタ設定の新規登録
 * @param {*} params 登録データ
 */
export function sendRequestInsertMstChecklist(params) {
  return ApiHelper.post(`${URL_BASE_MST_CHECKLIST}/insert`, params);
}

/**
 * チェックリストマスタ設定の更新登録
 * @param {*} weightCd 主キー
 * @param {*} params 登録データ
 */
export function sendRequestUpdateMstChecklist(params) {
  return ApiHelper.put(`${URL_BASE_MST_CHECKLIST}/update`, params);
}
