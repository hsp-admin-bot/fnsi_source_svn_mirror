//@ts-check

/**
 * 条件送信系API
 */
// @ts-ignore
import { ApiHelper } from "@/apis/AxiosHelper";
// @ts-ignore
import store from "@/stores";

/**
 * 条件送信用URL
 */
const URL_BASE_SEND_CONDITION = "/weight";
const URL_BASE_WEIGHT_SETTING = "/weight_setting";

/**
 * 院内患者idから患者ID取得
 * @param {Object} params 施設コード、治療日
 * @param {String} params.hospPatId 院内患者ID
 */
export function sendRequestGetPatId(params) {
  return getWithLoader(
    `${URL_BASE_SEND_CONDITION}/find_pat_id/${params.hospPatId}`
  );
}
// add FNSI-次回同じ患者を検索する場合測定値保存する 徐 start
/**
 * 患者IDから患者体重測定値取得
 * @param {Object} params 
 * @param {String} params.patId 患者ID
 */
export function sendRequestGetMeasuredValue(params) {
  return getWithLoader(
    `${URL_BASE_SEND_CONDITION}/find_measured_value/${params.patId}`
  );
}
// add FNSI-次回同じ患者を検索する場合測定値保存する 徐 end
/**
 * 非体重計モード時の体重計選択可能フラグ取得
 */
export function sendRequestGetEnableWeightSelect() {
  return getWithLoader(`${URL_BASE_SEND_CONDITION}/enable-weight-select`);
}

/**
 * クールとベッドグループの一覧取得
 * @param {number} excludeDialysisRoom 1：ベッドグループで透析室を除いたデータを取得 / -1：デフォルト、透析室も含むデータを取得
 * @param {string} facilityCd 施設コード指定
 */
export function sendRequestGetKurSelector(excludeDialysisRoom = -1,facilityCd = "") {
  return getWithLoader(`${URL_BASE_SEND_CONDITION}/kur-bed-list/${excludeDialysisRoom}`,{facilityCd:facilityCd});
}

/**
 * 治療日からスケジュール情報取得
 * @param {Object} params 施設コード、治療日
 * @param {String} params.treatDate 治療日
 * @param {boolean} params.isPast 過去日フラグ
 * @returns {Promise}
 */
export function sendRequestGetSchedule(params) {
  return getWithLoader(
    `${URL_BASE_SEND_CONDITION}/schedule/${params.treatDate}/${
      params.isPast ? "1" : "0"
    }`
  );
}
/**
 * 院内患者IDからスケジュール情報取得
 * @param {Object} params 施設コード、治療日
 * @param {String} params.treatDate 治療日
 * @param {String} params.hospPatId 院内患者ID
 * @param {boolean} params.isPast 過去日フラグ
 * @returns {Promise}
 */
export function sendRequestGetScheduleByHospPatId(params) {
  return getWithLoader(
    `${URL_BASE_SEND_CONDITION}/schedule/${params.treatDate}/${
      params.isPast ? "1" : "0"
    }/${params.hospPatId}`
  );
}

/**
 * ordNoから指示・実績情報取得
 * @param {*} ordNo 主キー
 */
export function sendRequestGetOrderMain(ordNo) {
  return getWithLoader(`${URL_BASE_SEND_CONDITION}/order/${ordNo}`);
}

/**
 * 患者idから情報取得
 * @param {*} patId 主キー
 */
export function sendRequestGetNoOrderMain(patId) {
  return getWithLoader(`${URL_BASE_SEND_CONDITION}/no_order/${patId}`);
}

/**
 * 患者未設定情報取得
 */
export function sendRequestGetNoPatOrder() {
  return getWithLoader(`${URL_BASE_SEND_CONDITION}/no_pat_order`);
}
/**
 * 前回測定履歴取得
 * @param {Object} params
 * @param {number} params.ordNo オーダー番号
 * @param {number} params.scaleClass 測定区分
 */
export function sendRequestLastScale(params) {
  return getWithLoader(
    `${URL_BASE_SEND_CONDITION}/last/history/${params.ordNo}/${params.scaleClass}`
  );
}
/**
 * 前回測定履歴取得 スケジュールなし
 * @param {Object} params
 * @param {number} params.patId 患者ID
 */
export function sendRequestLastScaleNoSchedule(params) {
  return getWithLoader(
    `${URL_BASE_SEND_CONDITION}/last/history/no_schedule/${params.patId}`
  );
}
/**
 * 対象測定履歴取得
 * @param {Object} params
 * @param {number} params.weightScaleNo 測定履歴番号
 */
export function sendRequestTargetScale(params) {
  return getWithLoader(
    `${URL_BASE_SEND_CONDITION}/target/history/${params.weightScaleNo}`
  );
}

/**
 * 前回体重実績取得
 * @param {Object} params
 * @param {Number} params.ordNo 現在オーダー番号
 * @param {Number} params.previousWeightSourceClass (0:透析・特殊浄化を区別する 1:区別しない)
 */
export function sendRequestGetLastRstWeight(params) {
  return getWithLoader(
    `${URL_BASE_SEND_CONDITION}/get_last_rst_weight/${params.ordNo}/${params.previousWeightSourceClass}`
  );
}
/**
 * 前回体重実績取得
 * @param {Object} params
 * @param {Number} params.patId 患者番号
 * @param {Number} params.previousWeightSourceClass (0:透析・特殊浄化を区別する 1:区別しない)
 */
export function sendRequestGetLastRstWeightPat(params) {
  return getWithLoader(
    `${URL_BASE_SEND_CONDITION}/get_last_rst_weight_pat/${params.patId}/${params.previousWeightSourceClass}`
  );
}
/**
 * 指定日の前回後体重を含む実績を取得
 * @param {Object} params
 * @param {Number} params.patId 患者番号
 * @param {Number} params.previousWeightSourceClass (0:透析・特殊浄化を区別する 1:区別しない)
 * @param {String} params.treatDate 検索基準日
 */
export function sendRequestGetWeightByTreatDate(params) {
  return getWithLoader(
    `${URL_BASE_SEND_CONDITION}/get_weight_by_treatdate/${params.patId}/${params.previousWeightSourceClass}/${params.treatDate}`
  );
}

export function getWeightByTreatDateAndOrdClass(params) {
  return getWithLoader(
    `${URL_BASE_SEND_CONDITION}/getWeightByTreatDateAndOrdClass/${params.facilityCd}`
    + `/${params.patId}/${params.ordClass}/${params.treatDate}/${params.treatTime}`
  );
}

/**
 * 条件送信
 * @param {Object} params 登録データ
 */
export function sendRequestPostSendCondition(params) {
  return postWithLoader(`${URL_BASE_SEND_CONDITION}/send_condition`, params);
}

/**
 * 条件送信せず実績のみ登録（ベッド未登録など）
 * @param {Object} params 登録データ
 */
export function sendRequestPostNoSendCondition(params) {
  return postWithLoader(`${URL_BASE_SEND_CONDITION}/no_send_condition`, params);
}

/**
 * 体重計から重量測定値受信時に行う測定値記録保存処理
 * @param {Object} params 登録データ
 */
export function sendRequestPostSaveMeasure(params) {
  return ApiHelper.post(`${URL_BASE_SEND_CONDITION}/save_measure`, params);
}

/**
 * 条件送信（体重＋車いす一時保存）
 * @param {Object} params 登録データ
 */
export function sendRequestPostSaveWeightAndChair(params) {
  return postWithLoader(
    `${URL_BASE_SEND_CONDITION}/save_weight_and_chair`,
    params
  );
}

/**
 * 条件送信（車いす一時保存）
 * @param {Object} params 登録データ
 */
export function sendRequestPostSaveWheelChair(params) {
  return postWithLoader(`${URL_BASE_SEND_CONDITION}/save_chair`, params);
}

/**
 * 後体重登録
 * @param {Object} params 登録データ
 */
export function sendRequestPostSendAfterWeight(params) {
  return postWithLoader(`${URL_BASE_SEND_CONDITION}/send_afterweight`, params);
}

/**
 * 後体重測定済み状態への遷移
 * @param {Object} params 登録データ
 * @param {Number} params.ordNo オーダ番号
 */
export function sendRequestPutStateSavedAfterWeight(params) {
  return putWithLoader(`${URL_BASE_SEND_CONDITION}/saved-after-weight`, params);
}

/**
 * 更新登録
 * @param {Number} ctlNo 主キー
 * @param {Object} params 登録データ
 */
export function sendRequestPutSendCondition(ctlNo, params) {
  return putWithLoader(`${URL_BASE_SEND_CONDITION}/${ctlNo}`, params);
}

/**
 * 指示除水補正登録
 * @param {Object} params
 * @param {Number} params.ordNo 主キー
 * @param {Object} params.data 登録データ
 */
export function sendRequestPutIndWater(params) {
  return putWithLoader(
    `${URL_BASE_SEND_CONDITION}/order/update/off_water`,
    params
  );
}

/**
 * 指示風袋登録
 * @param {Object} params
 * @param {Number} params.ordNo 主キー
 * @param {Object} params.data 登録データ
 */
export function sendRequestPutIndTare(params) {
  return putWithLoader(`${URL_BASE_SEND_CONDITION}/order/update/tare`, params);
}

/**
 * 車いす情報取得
 * @param {Object} params
 * @param {String} params.facilityCd 施設コード
 */
export function sendRequestGetWheelChairList(params) {
  return getWithLoader(
    `${URL_BASE_WEIGHT_SETTING}/wheel_chair/find/${params.facilityCd}`
  );
}
/**
 * 車いす情報取得
 * @param {Object} params
 * @param {Number} params.wheelChairCd 車いすコード
 */
export function sendRequestGetWheelChair(params) {
  return getWithLoader(
    `${URL_BASE_WEIGHT_SETTING}/wheel_chair/get/${params.wheelChairCd}`
  );
}
/**
 * 個人車いす情報取得
 * @param {Object} params
 * @param {Number} params.patId 患者ID
 */
export function sendRequestGetPersonalWheelChairList(params) {
  return getWithLoader(
    `${URL_BASE_WEIGHT_SETTING}/wheel_chair/personal/${params.patId}`
  );
}

/**
 * 患者idから測定履歴取得
 * @param {Object} params 施設コード、患者ID
 * @param {String} params.FacilityCd 施設コード
 * @param {String} params.patId 患者ID
 * @param {String} params.treatDate 治療日
 * @param {Number} params.previousWeightSourceClass (0:透析・特殊浄化を区別する 1:区別しない)
 */
export function sendRequestGetHistory(params) {
  return getWithLoader(
    `${URL_BASE_SEND_CONDITION}/history/${params.FacilityCd}/${params.patId}/${params.treatDate}/${params.previousWeightSourceClass}`
  );
}

/**
 * レシート印刷用の検査結果取得
 * @param {Object} params
 */
export function sendRequestGetExam(params) {
  // return ApiHelper.get(
  //   `${URL_BASE_SEND_CONDITION}/pat-exam/print/${params.patId}/${params.baseDate}/${params.itemCdList}`
  // );
  //  FNSI-add redmine4656 徐 start
  return postWithLoader(`${URL_BASE_SEND_CONDITION}/pat-exam/print`,params);
  //  FNSI-add redmine4656 徐 end
}
// add FNSI-分類不一致判断の追加 徐 start
/**
* 治療条件分類不一致判断
* @param {Object} params オーダ番号
* @param {Number} params.ordNo オーダ番号
* @param {Number} params.ordNos オーダ番号2
*/
export function getChkIndCondInfoData(params) {
  return ApiHelper.get(
    `${URL_BASE_SEND_CONDITION}/order/check/${params.ordNo}/${params.ordNos}`
  );
}
/**
* 校正切れチェック
* @param {Object} params オーダ番号
* @param {String} params.facilityCd 施設コード
* @param {Number} params.wheelChairCd 車いすコード
*/
export function checkCalibrationByCd(params) {
  return ApiHelper.get(
    `${URL_BASE_WEIGHT_SETTING}/wheel_chair/check/calibration/${params.facilityCd}/${params.wheelChairCd}`
  );
}
// add FNSI-分類不一致判断の追加 徐 end
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
function postWithLoader(url, params) {
  store.dispatch("loading-screen/setLoadingScreenMessage", "処理中・・・");
  store.dispatch("loading-screen/setLoadingScreenVisible", true);
  return ApiHelper.post(url, params).finally(() =>
    store.dispatch("loading-screen/setLoadingScreenVisible", false)
  );
}
