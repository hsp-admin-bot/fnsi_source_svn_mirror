/**
 * ユーザー系API
 */
import qs from "qs";
import { ApiHelper } from "@/apis/AxiosHelper";

/**
 * ログイン
 * @param {*} params 認証情報
 */
export function sendRequestLogin(params) {
  return ApiHelper.post("/login", qs.stringify(params));
}

/**
 * ログアウト
 */
export function sendRequestLogout() {
  return ApiHelper.post("/logout");
}
