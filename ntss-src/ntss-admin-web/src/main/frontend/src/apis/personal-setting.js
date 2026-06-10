/**
 * 共通設定タブ定義API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

/**
 * 指定のタブ定義コードの設定項目情報を取得する.
 * @param {*} tabDefineCd タブ定義コード
 */
export function sendRequestGetPersonalSettingsDefine(tabDefineCd) {
  return ApiHelper.get(`personal_setting_define/${tabDefineCd}`);
}

/**
 * 指定のタブ定義コードの個人設定値を取得する.
 * @param {*} tabDefineCd タブ定義コード
 */
export function sendRequestGetPersonalSettings(tabDefineCd) {
  return ApiHelper.get(`user_settings/personal_settings/${tabDefineCd}`);
}

/**
 * 指定のタブ定義コードの個人設定値を更新する.
 * @param {*} tabDefineCd タブ定義コード
 */
export function sendRequestUpdatePersonalSettings(params) {
  return ApiHelper.put("user_settings/personal_settings", params);
}
