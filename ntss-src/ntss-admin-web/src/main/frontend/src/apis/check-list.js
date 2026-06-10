/**
 * チェックリスト系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";
/**
 * ストア系
 */
import store from "@/stores";

/**
 * チェックリスト用URL
 */
const CHECK_LIST = "/check-list";

// add FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 start
/**
 * 治療中のスケジュール情報取得
 * @param {*} facilityCd 施設コード
 * @param {*} nextPat 次患者[0:次クール, 1:当日, 2:次クール以降](※無効)
 * @param {*} autoRefreshFlag 自動更新フラグ
 */
export function sendRequestGetOrdMainChiryouchuu(param) {
  // 自動更新サインアウトON/OFFチェック
  const forceSignOutFlag = store.getters["check-list/list/getForceSignOutFlag"];
  const queryParams = forceSignOutFlag == 0 ? "?__background_call__=true" : "";
  const baseUrl = `${CHECK_LIST}/ordermainchiryouchuu/${param.facilityCd}/${param.nextPat}`;
  const requestUrl = param.autoRefreshFlag ? `${baseUrl}${queryParams}` : baseUrl;
  return getWithLoader(requestUrl);
}

/**
 * 指定日のスケジュール情報取得
 * @param {*} facilityCd 施設コード
 * @param {*} treatDate 治療日
 */
export function sendRequestGetOrdMainShiteibi(param) {
  // 自動更新サインアウトON/OFFチェック
  const forceSignOutFlag = store.getters["check-list/list/getForceSignOutFlag"];
  const queryParams = forceSignOutFlag == 0 ? "?__background_call__=true" : "";
  const baseUrl = `${CHECK_LIST}/ordermainshiteibi/${param.facilityCd}/${param.treatDate}`;
  const requestUrl = param.autoRefreshFlag ? `${baseUrl}${queryParams}` : baseUrl;
  return getWithLoader(requestUrl);
}

/**
 * 指定のオーダー番号のチェックリスト情報「条件送信前」
 * チェック済み項目数取得「チェックリスト実績⇒チェック済み」
 * チェック項目数取得「治療指示情報とチェックリストマスト情報」
 * @param {*} ordNo オーダー番号
 * @param {*} listCd リストコード
 */
export function sendRequestGetOrdCheckListZen(param) {
  return ApiHelper.get(
    `${CHECK_LIST}/orderchecklistzen/${param.ordNo}/${param.listCd}`
  );
}

/**
 * 指定のオーダー番号のチェックリスト情報「条件送信以降」
 * チェック済み項目数取得「チェックリスト実績⇒チェック済み」
 * チェック項目数取得「チェックリスト実績⇒ダミーデータは含まれない」
 * @param {*} ordNo オーダー番号
 * @param {*} listCd リストコード
 */
export function sendRequestGetOrdCheckListIcou(param) {
  return ApiHelper.get(
    `${CHECK_LIST}/orderchecklisticou/${param.ordNo}/${param.listCd}`
  );
}
// add FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 end

/**
 * 自動更新のインターバル情報取得
 */
export function sendRequestGetReloadInterval(autoRefreshFlag) {
  if (autoRefreshFlag) {
    // 自動更新サインアウトON/OFFチェック
    const forceSignOutFlag = store.getters["check-list/list/getForceSignOutFlag"];
    const queryParams = forceSignOutFlag == 0 ? "?__background_call__=true" : "";
    return ApiHelper.get(`${CHECK_LIST}/get-reload-interval${queryParams}`);
  } else {
    return getWithLoader(`${CHECK_LIST}/get-reload-interval`);
  }
}

/**
 * 治療中のスケジュール情報取得
 * @param {*} facilityCd 施設コード
 * @param {*} nextPat 次患者[0:次クール, 1:当日, 2:次クール以降](※無効)
 */
export function sendRequestGetOrdMainTreatment(param) {
  return getWithLoader(
    `${CHECK_LIST}/ordertreaement/${param.facilityCd}/${param.nextPat}`
  );
}

/**
 * 指定日のスケジュール情報取得
 * @param {*} facilityCd 施設コード
 * @param {*} treatDate 治療日
 */
export function sendRequestGetOrdMainByTreatDate(param) {
  return getWithLoader(
    `${CHECK_LIST}/order/${param.facilityCd}/${param.treatDate}`
  );
}

/**
 * 指定オーダー番号のスケジュール情報取得
 * @param {*} ordNo オーダー番号
 */
export function sendRequestGetOrdMainByOrdNo(ordNo) {
  return getWithLoader(`${CHECK_LIST}/getorder/${ordNo}`);
}

/**
 * 指定チェックリストコードのチェックリストマスタ設定情報取得
 * @param {*} checklistCd チェックリストコード
 */
export function sendRequestGetMstChecklistByChecklistCd(checklistCd) {
  return getWithLoader(`${CHECK_LIST}/getmstchecklist/${checklistCd}`);
}

/**
 * ダイアライザマスタの情報取得
 * @param {*} list ダイアライザコードリスト
 */
export function sendRequestGetMstDialyzerList(param) {
  return getWithLoader(`${CHECK_LIST}/getdialyzer/${param.list}`);
}

/**
 * 薬剤マスタの情報取得
 * @param {*} list 薬剤コードリスト
 */
export function sendRequestGetMstMedicineList(param) {
  return getWithLoader(`${CHECK_LIST}/getmedicine/${param.list}`);
}

/**
 * 調整薬剤マスタの情報取得
 * @param {*} list 調整薬剤コードリスト
 */
export function sendRequestGetMstMedicineMixList(param) {
  return getWithLoader(`${CHECK_LIST}/get-medicine-mix/${param.list}`);
}

/**
 * 医療材料マスタの情報取得
 * @param {*} list 医療材料コードリスト
 */
export function sendRequestGetMstEquipList(param) {
  return getWithLoader(`${CHECK_LIST}/getequip/${param.list}`);
}

/**
 * 指定のオーダー番号のチェックリスト実績
 * チェック済み項目数取得, 項目数取得
 * @param {*} ordNo オーダー番号
 */
export function sendRequestGetOrdCheckListByOrdNo(param) {
  //return getWithLoader(`${CHECK_LIST}/getorderchecklist-ordno/${param.ordNo}`);
  return ApiHelper.get(`${CHECK_LIST}/getorderchecklist-ordno/${param.ordNo}`);
}
/**
 * 指定のオーダー番号、リストコードのチェックリスト実績取得
 * @param {*} ordNo オーダー番号
 * @param {*} listCd リストコード
 */
export function sendRequestGetOrdCheckListByListCd(param) {
  return getWithLoader(
    `${CHECK_LIST}/getorderchecklist-listcd/${param.ordNo}/${param.listCd}`
  );
}

/**
 * チェックリスト実績登録
 * @param {*} 登録情報
 */
export function sendRequestUpdateOrdChecklist(param) {
  return postWithLoader(`${CHECK_LIST}/update`, param);
}

/**
 * スタッフマスタの情報取得
 * @param {*} facilityCd 施設コード
 */
export function sendRequestGetMstPersonalUser(facilityCd) {
  return getWithLoader(`${CHECK_LIST}/getstaff/${facilityCd}`);
}

/**
 * 投与薬剤実績登録
 * @param {*} 登録情報
 */
export function sendRequestUpdateOrdMainMediInfo(param) {
  return postWithLoader(`${CHECK_LIST}/updatemediinfo/`, param);
}

/**
 * 指定のオーダー番号のチェックリスト実績作成
 * @param {*} ordNo オーダー番号
 */
export function sendRequestUpdateSendCondition(ordNo) {
  return postWithLoader(`${CHECK_LIST}/updateSendCondition/${ordNo}`);
}

/**
 * 共通ローダを実行するGETリクエスト
 * @param {String} url URL
 * @param {any} params パラメータ
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
 * @param {String} url URL
 * @param {any} params パラメータ
 */
//function putWithLoader(url, params) {
//  store.dispatch("loading-screen/setLoadingScreenMessage", "処理中・・・");
//  store.dispatch("loading-screen/setLoadingScreenVisible", true);
//  return ApiHelper.put(url, params).finally(() =>
//    store.dispatch("loading-screen/setLoadingScreenVisible", false)
//  );
//}

/**
 * 共通ローダを実行するPOSTリクエスト
 * @param {String} url URL
 * @param {any} params パラメータ
 */
function postWithLoader(url, params) {
  store.dispatch("loading-screen/setLoadingScreenMessage", "処理中・・・");
  store.dispatch("loading-screen/setLoadingScreenVisible", true);
  return ApiHelper.post(url, params).finally(() =>
    store.dispatch("loading-screen/setLoadingScreenVisible", false)
  );
}
// add チェックリストマスタ 指示変更、実績変更に伴うチェックリストの反映 孔 start
/**
 * チェックリスト実績削除
 * @param {*} 登録情報
 */
export function sendRequestDeleteOrdChecklist(param) {
  return postWithLoader(`${CHECK_LIST}/deleteOrdChecklist`, param);
}
// add チェックリストマスタ 指示変更、実績変更に伴うチェックリストの反映 孔 end
export function sendRequestGetOrdCheckListAll(params, autoRefreshFlag) {
  // 自動更新サインアウトON/OFFチェック
  const forceSignOutFlag = store.getters["check-list/list/getForceSignOutFlag"];
  const queryParams = forceSignOutFlag == 0 ? "?__background_call__=true" : "";
  const baseUrl = `${CHECK_LIST}/orderchecklistallinfo`;
  const requestUrl = autoRefreshFlag ? `${baseUrl}${queryParams}` : baseUrl;
  return ApiHelper.post(requestUrl, params);
}
