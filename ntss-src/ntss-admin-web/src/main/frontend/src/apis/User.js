/**
 * ユーザー系API
 */
import qs from "qs";
import {ApiHelper} from "@/apis/AxiosHelper";
/**
 * ストア系
 */
import store from "@/stores";
/**
 * アクセスが許可されているメソッド用
 */
import axios from "axios";

/**
 * ログイン
 * @param {*} params 認証情報
 */
export function sendRequestLogin(params) {
  /* modify by chamaojia 2025-03-18 [11587] add automatic login calls and add API logic --start */
  if (params.autoSignInFlag && params.autoSignInFlag == true) {
    const autoSignInParams = {
      userId: params.userId,
      facilityCd: params.facilityCd
    };
    // Add a new calling interface and use session information shared by different tabs to complete login
    return ApiHelper.get("/sign-in/autoLogin", autoSignInParams);
  } else {
    return ApiHelper.post("/login", qs.stringify(params));
  }
  /* modify by chamaojia 2025-03-18 [11587] add automatic login calls and add API logic --end */
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
export function sendRequestUserAccountInfo() {
  return ApiHelper.get(`/user`);
}

/**
 * 指定ユーザ情報取得.
 */
export function sendRequestUserInfo(params) {
  return ApiHelper.get(`/user/get_by_id/${params.userId}`);
}

/**
 * ユーザー情報更新処理.
 * @param {*} params ユーザー情報
 */
export function sendRequestRegistUserAccount(params) {
  return ApiHelper.put("/user", params);
}

/**
 * 初回ログイン用のユーザ情報更新処理.
 * @param {*} params ユーザー情報
 */
export function sendRequestRegistProvisionalUserAccount(params) {
  return ApiHelper.put("/user/provisional", params);
}

/**
 * ID重複チェック.
 * @param {*} userId ユーザーID
 * @param {*} dispUserId 表示用ユーザーID
 */
export function sendRequestCheckDuplication(userId, dispUserId) {
  return ApiHelper.get(`/user/check/${userId}/${dispUserId}`);
}

/**
 * 文字サイズ更新処理.
 * @param {*} params 文字サイズリクエスト
 */
export function sendRequestUpdateFontSize(params) {
  return ApiHelper.put("/user_settings/font_size", params);
}

/**
 * テーマ更新処理.
 * @param {*} params テーマ更新リクエスト
 */
export function sendRequestUpdateTheme(params) {
  return ApiHelper.put("/user_settings/theme", params);
}

/**
 * メニューバー設定更新処理.
 * @param {*} params メニューバー設定更新リクエスト
 */
export function sendRequestUpdateMenuBar(params) {
  return ApiHelper.put("/user_settings/menu_bar", params);
}

// mod #12462 患者情報共有 関 start
/**
 * 患者共有設定更新処理.
 * @param {*} params 患者共有設定更新リクエスト
 */
export function sendRequestUpdatePatShareMode(params) {
  return ApiHelper.put("/user_settings/pat_share_mode", params);
}
// mod #12462 患者情報共有 関 end

/**
 * ユーザー使用可能機能設定更新処理.
 * @param {*} params ユーザー使用可能機能設定更新リクエスト
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
 * @param {*} params ユーザー権限更新リクエスト
 */
export function sendRequestUpdateAuthority(params) {
  return ApiHelper.put("/user-authority/list", params);
}

/**
 * 画面フレーム分割設定更新処理.
 * @param {*} params 画面フレーム分割設定更新リクエスト
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
 * @param {*} params 個人設定 - デフォルト設定更新リクエスト
 */
export function sendRequestUpdateDefaultSetting(params) {
  return ApiHelper.put("/user_settings/default_setting", params);
}

/**
 * 端末固有文字列に該当するサインイン管理情報取得する.
 * ※認証不要
 *
 * @param {String} terminalUniqueString 端末固有文字列
 * @returns 端末固有文字列に該当するサインイン管理情報のリスト
 */
export function sendRequestGetSignin(terminalUniqueString) {
  // 認証不要URL：サインインしていない状態でも発火する為、こちらのメソッドでアクセスする
  return axios.get(`/ntss-admin-web/api/sign-in/select/term/${terminalUniqueString}`);
}
/**
 * 利用者ID(内部)に該当するサインイン管理情報を取得する.
 * ※認証不要
 *
 * @param {Long} userId 利用者ID(内部)
 * @returns 利用者ID(内部)に該当するサインイン管理情報リスト
 */
export function sendRequestGetSigninByUserId(userId) {
  return ApiHelper.get(`/sign-in/select/user/${userId}`);
}
/**
 * 与えられた条件に合致するサインイン管理情報を取得する.
 *
 * @param {*} params 検索要件
 *                   {
 *                     terminalUniqueString: 端末固有文字列,
 *                     facilityCd: 施設コード,
 *                     userId: 利用者ID(内部)
 *                   }
 * @returns 検索条件に合致するサインイン管理情報リスト
 */
export function sendRequestRegistSignin(params) {
  return ApiHelper.put(`/sign-in/insert`, params);
}
/**
 * 端末固有文字列に該当するサインイン管理情報を削除する.
 * ※認証不要
 *
 * @param {String} terminalUniqueString 端末固有文字列
 * @returns 削除成功した場合、trueを返却する.
 */
export function sendRequestDeleteSignin(terminalUniqueString) {
  // 認証不要URL：サインインしていない状態でも発火する為、こちらのメソッドでアクセスする
  return axios.put(`/ntss-admin-web/api/sign-in/delete/${terminalUniqueString}`);
}

/**
 * 自分自身以外のセッション情報を破棄する.
 */
export function sendRequestLogoutAnother(params) {
  return ApiHelper.put("/user/logoutAnother", params);
}

/**
 * 入力された現在のパスワードをチェックする.
 */
export function sendRequestCheckMatchCurrentPassword(params) {
  return ApiHelper.get("/user/checkMatchCurrentPassword", params);
}

/**
 * パスワードが利用できるかチェック.
 */
export function sendRequestIsAvailablePassword(params) {
  return ApiHelper.get("/user/isAvailablePassword", params);
}
/*add FNSI-改修内容全体の合否が俯瞰できるように修正 任 start*/
export function sendRequestUserAccountInfoAll(facilityCd) {
  return ApiHelper.get(`/user/getAllUser/${facilityCd}`);
}
/*add FNSI-改修内容全体の合否が俯瞰できるように修正 任 end*/
