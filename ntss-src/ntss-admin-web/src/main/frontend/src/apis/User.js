/**
 * ユーザー系API
 */
import qs from "@/compat/http/qs";
import axios from "@/compat/http/axios";
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
 * ログイン
 * @param {Record<string, unknown>} params 認証情報
 */
export function sendRequestLogin(params) {
  /* modify by chamaojia 2025-03-18 [11587] add automatic login calls and add API logic --start */
  if (params.autoSignInFlag && params.autoSignInFlag === true) {
    const autoSignInParams = {
      userId: params.userId,
      facilityCd: params.facilityCd
    };
    // Add a new calling interface and use session information shared by different tabs to complete login
    return ApiHelper.get("/sign-in/autoLogin", autoSignInParams);
  }
  /* modify by chamaojia 2025-03-18 [11587] add automatic login calls and add API logic --end */
  return ApiHelper.post("/login", qs.stringify(params));
}

/**
 * ログアウト
 */
export function sendRequestLogout() {
  const facilityCd = store.getters["user/getFacilityCd"];
  const userId = store.getters["user/getUserId"];
  return ApiHelper.post("/logout?facilityCd=" + facilityCd + "&userId=" + userId);
}

/**
 * アカウント情報取得.
 */
export function sendRequestUserAccountInfo(selectedPatId) {
  return ApiHelper.get(`/user`, withSelectedPatId(undefined, selectedPatId));
}

/**
 * 指定ユーザ情報取得.
 * @param {{ userId: string|number }} params ユーザー識別子
 */
export function sendRequestUserInfo(params) {
  return ApiHelper.get(`/user/get_by_id/${params.userId}`);
}

/**
 * ユーザー情報更新処理.
 * @param {Record<string, unknown>} params ユーザー情報
 */
export function sendRequestRegistUserAccount(params) {
  return ApiHelper.put("/user", params);
}

/**
 * 初回ログイン用のユーザ情報更新処理.
 * @param {Record<string, unknown>} params ユーザー情報
 */
export function sendRequestRegistProvisionalUserAccount(params) {
  return ApiHelper.put("/user/provisional", params);
}

/**
 * ID重複チェック.
 * @param {string|number} userId ユーザーID
 * @param {string} dispUserId 表示用ユーザーID
 */
export function sendRequestCheckDuplication(userId, dispUserId) {
  return ApiHelper.get(`/user/check/${userId}/${dispUserId}`);
}

/**
 * 文字サイズ更新処理.
 * @param {Record<string, unknown>} params 文字サイズリクエスト
 */
export function sendRequestUpdateFontSize(params) {
  return ApiHelper.put("/user_settings/font_size", params);
}

/**
 * テーマ更新処理.
 * @param {Record<string, unknown>} params テーマ更新リクエスト
 */
export function sendRequestUpdateTheme(params) {
  return ApiHelper.put("/user_settings/theme", params);
}

/**
 * メニューバー設定更新処理.
 * @param {Record<string, unknown>} params メニューバー設定更新リクエスト
 */
export function sendRequestUpdateMenuBar(params) {
  return ApiHelper.put("/user_settings/menu_bar", params);
}

/**
 * 患者共有設定更新処理.
 * @param {Record<string, unknown>} params 患者共有設定更新リクエスト
 */
export function sendRequestUpdatePatShareMode(params) {
  return ApiHelper.put("/user_settings/pat_share_mode", params);
}

/**
 * ユーザー使用可能機能設定更新処理.
 * @param {Record<string, unknown>} params ユーザー使用可能機能設定更新リクエスト
 */
export function sendRequestUpdateUseAuthFunctions(params) {
  return ApiHelper.put("/user_settings/use_auth_functions", params);
}

/**
 * ログインユーザの利用者権限情報取得.
 */
export function sendRequestGetUserAuthorityCds() {
  return ApiHelper.get("/user-authority/login/list");
}

/**
 * ユーザー権限更新処理.
 * @param {Record<string, unknown>} params ユーザー権限更新リクエスト
 */
export function sendRequestUpdateAuthority(params) {
  return ApiHelper.put("/user-authority/list", params);
}

/**
 * 画面フレーム分割設定更新処理.
 * @param {Record<string, unknown>} params 画面フレーム分割設定更新リクエスト
 */
export function sendRequestUpdateSplitFrame(params) {
  return ApiHelper.put("/user_settings/split_frame", params);
}

/**
 * 個人設定 - デフォルト設定の並び順を取得.
 */
export function sendRequestGetDefaultSettingDispOrder() {
  return ApiHelper.put("/user_settings/default_setting/disp_order");
}

/**
 * 個人設定 - デフォルト設定の更新処理.
 * @param {Record<string, unknown>} params 個人設定 - デフォルト設定更新リクエスト
 */
export function sendRequestUpdateDefaultSetting(params) {
  return ApiHelper.put("/user_settings/default_setting", params);
}

/**
 * 端末固有文字列に該当するサインイン管理情報取得する.
 * ※認証不要
 *
 * @param {string} terminalUniqueString 端末固有文字列
 * @returns {Promise} 端末固有文字列に該当するサインイン管理情報のリスト
 */
export function sendRequestGetSignin(terminalUniqueString) {
  // 認証不要URL：サインインしていない状態でも発火する為、こちらのメソッドでアクセスする
  return axios.get(`/ntss-admin-web/api/sign-in/select/term/${terminalUniqueString}`);
}

/**
 * 利用者ID(内部)に該当するサインイン管理情報を取得する.
 * ※認証不要
 *
 * @param {number|string} userId 利用者ID(内部)
 * @returns {Promise} 利用者ID(内部)に該当するサインイン管理情報リスト
 */
export function sendRequestGetSigninByUserId(userId) {
  return ApiHelper.get(`/sign-in/select/user/${userId}`);
}

/**
 * 与えられた条件に合致するサインイン管理情報を取得する.
 *
 * @param {Record<string, unknown>} params 検索要件
 *                   {
 *                     terminalUniqueString: 端末固有文字列,
 *                     facilityCd: 施設コード,
 *                     userId: 利用者ID(内部)
 *                   }
 * @returns {Promise} 検索条件に合致するサインイン管理情報リスト
 */
export function sendRequestRegistSignin(params) {
  return ApiHelper.put(`/sign-in/insert`, params);
}

/**
 * 端末固有文字列に該当するサインイン管理情報を削除する.
 * ※認証不要
 *
 * @param {string} terminalUniqueString 端末固有文字列
 * @returns {Promise} 削除成功した場合、trueを返却する.
 */
export function sendRequestDeleteSignin(terminalUniqueString) {
  // 認証不要URL：サインインしていない状態でも発火する為、こちらのメソッドでアクセスする
  return axios.put(`/ntss-admin-web/api/sign-in/delete/${terminalUniqueString}`);
}

/**
 * 自分自身以外のセッション情報を破棄する.
 * @param {Record<string, unknown>} params パラメータ
 */
export function sendRequestLogoutAnother(params) {
  return ApiHelper.put("/user/logoutAnother", params);
}

/**
 * 入力された現在のパスワードをチェックする.
 * @param {Record<string, unknown>} params パラメータ
 */
export function sendRequestCheckMatchCurrentPassword(params) {
  return ApiHelper.get("/user/checkMatchCurrentPassword", params);
}

/**
 * パスワードが利用できるかチェック.
 * @param {Record<string, unknown>} params パラメータ
 */
export function sendRequestIsAvailablePassword(params) {
  return ApiHelper.get("/user/isAvailablePassword", params);
}

// add FNSI-改修内容全体の合否が俯瞰できるように修正 任 start
/**
 * 施設に紐づく全ユーザー情報取得
 * @param {string} facilityCd 施設コード
 */
export function sendRequestUserAccountInfoAll(facilityCd) {
  return ApiHelper.get(`/user/getAllUser/${facilityCd}`);
}
// add FNSI-改修内容全体の合否が俯瞰できるように修正 任 end
