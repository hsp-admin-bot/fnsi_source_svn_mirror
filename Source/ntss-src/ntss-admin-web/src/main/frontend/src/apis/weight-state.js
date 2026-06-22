/**
 * 院内アプリ通信系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

/**
 * 院内アプリ通信用URL
 */
const URL_BASE_WEIGHT_STATE = "/weight_state";

/**
 * 情報取得
 * @param {number|string} weightCd 体重計識別コード
 */
export function sendRequestGetWeightState(weightCd) {
  return ApiHelper.get(`${URL_BASE_WEIGHT_STATE}/state/${weightCd}`);
}

/**
 * 印刷指示
 * @param {Record<string, unknown>} params 印刷パラメータ
 * @param {number} params.weightScaleNo 測定記録番号
 * @param {number} params.printStatus 印刷状態
 * @param {number} params.weightCd 体重計識別コード
 * @param {string} params.facilityCd 施設コード
 * @param {number} params.weightNo 体重計番号
 */
export function sendRequestPostPrintSheet(params) {
  return ApiHelper.post(`${URL_BASE_WEIGHT_STATE}/print`, params);
}

// add FNSI-田中衡機の追加 徐 start
/**
 * 体重Appに「受信開始OK」という通知を送る
 * @param {Record<string, unknown>} weightApp 体重Appパラメータ
 * @param {number} weightApp.weightCd 体重計識別コード
 * @param {string} weightApp.facilityCd 施設コード
 * @param {number} weightApp.weightNo 体重計番号
 */
export function sendRequestWeightAppOk(weightApp) {
  return ApiHelper.post(`${URL_BASE_WEIGHT_STATE}/weightAppOk`, weightApp);
}
// add FNSI-田中衡機の追加 徐 end
