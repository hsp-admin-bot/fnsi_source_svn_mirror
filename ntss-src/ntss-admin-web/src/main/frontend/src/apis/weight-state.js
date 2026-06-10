//@ts-check

/**
 * 院内アプリ通信系API
 */
// @ts-ignore
import { ApiHelper } from "@/apis/AxiosHelper";

/**
 * 院内アプリ通信用URL
 */
const URL_BASE_WEIGHT_STATE = "/weight_state";

/**
 * 情報取得
 * @param {Number} weightCd 体重計識別コード
 */
export function sendRequestGetWeightState(weightCd) {
  return ApiHelper.get(`${URL_BASE_WEIGHT_STATE}/state/${weightCd}`);
}

/**
 * 印刷指示
 * @param {Object} params
 * @param {Number} params.weightScaleNo 測定記録番号
 * @param {Number} params.printStatus 印刷状態
 * @param {Number} params.weightCd 体重計識別コード
 * @param {String} params.facilityCd 施設コード
 * @param {Number} params.weightNo 体重計番号
 */
export function sendRequestPostPrintSheet(params) {
  return ApiHelper.post(`${URL_BASE_WEIGHT_STATE}/print`, params);
}
// add FNSI-田中衡機の追加 徐 start
/**
 * 体重Appに「受信開始OK」という通知を送る
 * @param {Object} weightApp
 * @param {Number} weightApp.weightCd 体重計識別コード
 * @param {String} weightApp.facilityCd 施設コード
 * @param {Number} weightApp.weightNo 体重計番号
 */
export function sendRequestWeightAppOk(weightApp) {
  return ApiHelper.post(`${URL_BASE_WEIGHT_STATE}/weightAppOk`, weightApp);
// add FNSI-田中衡機の追加 徐 end
}
