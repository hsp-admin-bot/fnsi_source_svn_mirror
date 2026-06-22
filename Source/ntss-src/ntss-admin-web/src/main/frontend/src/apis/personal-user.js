/**
 * 利用者系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

const URL_BASE = "/personal_user";

/**
 * 利用者名とメールアドレス登録有無を取得
 */
export function sendRequestGetNameAndHasEmailAddress() {
  return ApiHelper.get(`${URL_BASE}/has_email`);
}

/**
 * 利用者名とメールアドレス登録有無を取得（施設コード指定）
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetNameAndHasEmailAddressByFacilityCd(facilityCd) {
  return ApiHelper.get(`${URL_BASE}/has_email/data/${facilityCd}`);
}

/**
 * 個人設定一覧を取得
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetPersonalUserSettingList(facilityCd) {
  return ApiHelper.get(`${URL_BASE}/list/${facilityCd}`);
}
