/**
 * 担当施設設定系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

/**
 * 担当施設設定用URL
 */
const URL_BASE = "/facilities/staff_facility";

/**
 * ユーザーIDに紐づく担当施設選択用一覧取得
 * @param {*} userId ユーザーID（内部用）
 */
export function sendRequestFetchStaffFacilities(userId) {
  return ApiHelper.get(`${URL_BASE}/${userId}`);
}

export function sendRequestFetchStaffSharingFacilities(userId) {
  return ApiHelper.get(`${URL_BASE}_sharing/${userId}`);
}

/**
 * ユーザーIDに紐づく担当施設を設定（更新）
 * @param {*} userId ユーザーID（内部用）
 * @param {*} params 担当施設情報
 */
export function sendRequestSetStaffFacilities(userId, params) {
  return ApiHelper.put(`${URL_BASE}/${userId}`, params);
}
