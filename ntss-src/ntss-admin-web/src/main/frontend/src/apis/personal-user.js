/**
 * 利用者系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

/**
 * 利用者用URL
 */
const URL_BASE = "/personal_user";

/**
 * 利用者名とメールアドレス登録有無を取得
 */
export function sendRequestGetNameAndHasEmailAddress() {
  return ApiHelper.get(`${URL_BASE}/has_email`);
}

/**
 * 利用者名とメールアドレス登録有無を取得
 */
export function sendRequestGetNameAndHasEmailAddressByFacilityCd(facilityCd) {
  return ApiHelper.get(`${URL_BASE}/has_email/data/${facilityCd}`);
}
