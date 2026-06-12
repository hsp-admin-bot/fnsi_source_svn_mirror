/**
 * 利用者マスタ系API
 */
import dayjs from "@/compat/date/dayjs";
import { ApiHelper } from "@/apis/AxiosHelper";
/**
 * ストア系
 */
import store from "@/stores";

/**
 * 参照先URL
 */
const URL_BASE = "/master_maintenance/mst_user";

/**
 * 参照先URL
 */
const URL_REG_OTP = "/register_otp";

/**
 * ユーザ一覧の取得
 * @param {*} facilityCd
 */
export function sendRequestGetMstUserData(facilityCd) {
  return getWithLoader(`${URL_BASE}/${facilityCd}`);
}

/**
 * ユーザ一覧の取得
 * @param {*} facilityCd
 */
export function sendRequestGetMstPersonalUserData(facilityCd) {
  return getWithLoader(`${URL_BASE}/mst_personal_user/${facilityCd}`);
}

/**
 * ユーザ一覧の取得(ソート順用)
 * @param {*} facilityCd
 */
export function sendRequestGetMstUserDataSort(facilityCd) {
  return getWithLoader(`${URL_BASE}/sortList/${facilityCd}`);
}

/**
 * 新規ユーザの登録
 * @param {*} params
 */
export function sendRequestAddNewUser(params) {
  return getWithLoader(`${URL_BASE}/add_user/${params.facilityCd}`);
}

/**
 * 新規ユーザの登録
 * @param {*} params
 */
export function sendRequestAddNewPatUser(params) {
  return ApiHelper.put(`${URL_BASE}/add_pat_user`, params);
}

/**
 * 管理者フラグの更新
 * @param {*} userId
 * @param {*} adminFlg
 */
export function sendRequestUpdateAdministratorFlg(userId, adminFlg) {
  return putWithLoader(`${URL_BASE}/administrator/${userId}/${adminFlg}`);
}

/**
 * 患者共有フラグの更新
 * @param {*} userId
 * @param {*} patientSharedFlg
 */
export function sendRequestUpdatePatientSharedFlg(userId, patientSharedFlg) {
  return putWithLoader(`${URL_BASE}/patientShared/${userId}/${patientSharedFlg}`);
}

// add FNSI-メニューに共有ON／共有OFFを追加する。 江 start
/**
 * 患者共有フラグ取得
 */
export function sendRequestGetPatientSharedFlg(userId) {
  return getWithLoader(`${URL_BASE}/patientShared/${userId}`);
}
// add FNSI-メニューに共有ON／共有OFFを追加する。 江 end

/**
 * ID/PWの更新
 * @param {*} facilityCd
 * @param {*} userId
 */
export function sendRequestUpdatePassword(facilityCd, userId, patFlg) {
  // 通常の利用者向け/患者利用者向けでURLを分ける
  const exeUrl = patFlg ? "pat_password" : "password";
  return getWithLoader(`${URL_BASE}/${exeUrl}/${facilityCd}/${userId}`);
}

/**
 * ログイン失敗回数のリセット
 * @param {*} userId
 */
export function sendRequestUpdateFailureCnt(userId) {
  return putWithLoader(`${URL_BASE}/failure_cnt/${userId}`);
}

/**
 * ユーザの削除
 * @param {*} userId
 */
export function sendRequestDeleteUser(userId) {
  return putWithLoader(`${URL_BASE}/delete/${userId}`);
}

/**
 * 施設マスタ一覧取得
 */
export function sendRequestGetMstFacility() {
  return getWithLoader(`${URL_BASE}/mst_facility`);
}

/**
 * 削除対象メールアドレスリストの取得
 * @param {*} userEmailAddress
 */
export function sendRequestGetDeleteTargetEmailAddress(userEmailAddress) {
  return getWithLoader(`${URL_BASE}/user_email_address/${userEmailAddress}`);
}

/**
 * 削除対象メールアドレスの削除
 * @param {*} emailAddressList
 */
export function sendRequestDeleteEmailAddress(emailAddressList) {
  return putWithLoader(
    `${URL_BASE}/user_email_address/delete`,
    emailAddressList
  );
}

/**
 * 職種マスタ一覧取得
 */
export function sendRequestGetMstJob(facilityCd) {
  return getWithLoader(`${URL_BASE}/mst_job/${facilityCd}`);
}

/**
 * 職種の変更
 * @param {*} userId
 * @param {*} jobCd
 */
export function sendRequestUpdateJobCd(userId, jobCd) {
  return putWithLoader(`${URL_BASE}/chg_job/${userId}/${jobCd}`);
}

/**
 * 利用者個人情報の変更
 * @param {*} userId
 * @param {*} jobCd
 */
export function sendRequestUpdateUserPersonalInfo(userInfo) {
  return putWithLoader(
    `${URL_BASE}/updatePersonalInfo`,
    userInfo
  );
}

/**
 * 利用者並び順マスタ：mst_selecterの更新
 * @param {*} facilityCd 施設コード
 * @param {*} request リクエストデータ
 */
export function sendRequestUpdateMstSelecterByFacilityCd(facilityCd, request) {
  // Date -> String 変換
  request.forEach(e => dateToString(e));
  // プロパティ"edited"除去
  const params = JSON.parse(JSON.stringify(request));
  params.filter(p => "edited" in p).forEach(p => delete p.edited);
  return putWithLoader(
    `${URL_BASE}/mstSelecter/UpdIns/${facilityCd}`,
    params
  );
}

/**
 * アクセスカードを無効にする
 * @param {*} userId ユーザーID
 */
export function sendRequestDisableAccessCard(userId) {
  return putWithLoader(`${URL_BASE}/disableAccessCard/${userId}`);
}


/**
 * 共通ローダを実行するGETリクエスト
 * @param {string} url URL
 * @param {Record<string, unknown>} [params] パラメータ
 */
function getWithLoader(url, params = undefined) {
  store.dispatch("loading-screen/setLoadingScreenMessage", "処理中・・・");
  store.dispatch("loading-screen/setLoadingScreenVisible", true);
  return ApiHelper.get(url, params).finally(() =>
    store.dispatch("loading-screen/setLoadingScreenVisible", false)
  );
}

/**
 * 共通ローダを実行するPUTリクエスト
 * @param {string} url URL
 * @param {unknown} params パラメータ
 */
function putWithLoader(url, params) {
  store.dispatch("loading-screen/setLoadingScreenMessage", "処理中・・・");
  store.dispatch("loading-screen/setLoadingScreenVisible", true);
  return ApiHelper.put(url, params).finally(() =>
    store.dispatch("loading-screen/setLoadingScreenVisible", false)
  );
}

/**
 * 共通ローダを実行するPOSTリクエスト
 * @param {String} url URL
 * @param {any} params パラメータ
 */
//function postWithLoader(url, params) {
//  store.dispatch("loading-screen/setLoadingScreenMessage", "処理中・・・");
//  store.dispatch("loading-screen/setLoadingScreenVisible", true);
//  return ApiHelper.post(url, params).finally(() =>
//    store.dispatch("loading-screen/setLoadingScreenVisible", false)
//  );
//}

/**
 * 指定されたオブジェクトが持つDate型の値を文字列(YYYY-MM-DDTHH:mm:ss.SSS)に変換する.
 * リクエスト送信の際にDate型は、UTCとして文字列変換されてしまう.
 * 事前に文字列変換することで、意図しない日時に変換されることを回避する.
 * @param {Record<string, unknown>} o オブジェクト
 */
function dateToString(o) {
  const toString = Object.prototype.toString;
  Object.keys(o)
    .filter(key => toString.call(o[key]).slice(8, -1) === "Date")
    .forEach(
      key => (o[key] = dayjs(o[key]).format("YYYY-MM-DDTHH:mm:ss.SSS"))
    );
}

/**
 * ユーザー秘密鍵を削除
 * @param {*} userId
 */
export function sendRequestDeleteSecretKey(userId) {
  return putWithLoader(`${URL_REG_OTP}/del_scret_key/${userId}`);
}

/**
 * ユーザーOTPを作成
 * @param {*} dispUserId
 * @param {*} facilityCd
 */
export function sendRequestCreateMstUserOTP(dispUserId, facilityCd) {
  return getWithLoader(`${URL_REG_OTP}/cre_mst_user_otp/${dispUserId}/${facilityCd}`);
}

/**
 * ユーザーOTPの更新
 * @param {*} userId
 * @param {*} facilityCd
 */
export function sendRequestUpdateSecretKey(userId, secretKey) {
  return putWithLoader(`${URL_REG_OTP}/upd_scret_key/${userId}/${secretKey}`);
}

/**
 * ユーザーのQRコード表示を更新
 * @param {*} userId
 * @param {*} isSetQrCode
 */
export function sendRequestUpdateIsSetQrCode(userId, isSetQrCode) {
  return putWithLoader(`${URL_REG_OTP}/upd_is_set_qr_code/${userId}/${isSetQrCode}`);
}

/**
 * ワンタイムパスワードが正しいかチェック
 * @param {*} userId
 * @param {*} isSetQrCode
 */
export function sendRequestCheckOtp(secretKey, otp) {
  return putWithLoader(`${URL_REG_OTP}/checkOTP/${otp}/${secretKey}`);
}

/**
 * ユーザーのサインイン日時を更新
 * @param {*} userId
 */
export function sendRequestUpdateSigninDate(userId) {
  return putWithLoader(`${URL_BASE}/upd_signin_date/${userId}`);
}
