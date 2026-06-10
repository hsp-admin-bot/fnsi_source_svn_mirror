/**
 * 投薬支援マスタ系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

/**
 * 参照先URL
 */
const URL_BASE = "/master_maintenance";

/**
 * 投薬支援一覧の取得
 * @param {*} facilityCd
 */
export function sendRequestGetMstSupportSettingData(facilityCd) {
  return ApiHelper.get(`${URL_BASE}/mst_support_setting/${facilityCd}`);
}

/**
 * 結果値の取得
 * @param {*} cycLingParameter
 */
export function sendRequestGetMasterData(cycLingParameter) {
  return ApiHelper.get(`${URL_BASE}/mst_support_result_value/${cycLingParameter}`);
}

/**
 * 検査平均値の取得
 * @param {*} checkAvgParameter
 */
export function sendRequestGetCheckAvgData(checkAvgParameter) {
  return ApiHelper.get(`${URL_BASE}/mst_support_checkAvg_value/${checkAvgParameter}`);
}

/**
 * 初期レンジの取得
 * @param {*} cd
 */
export function sendRequestGetRange(cd) {
  return ApiHelper.get(`${URL_BASE}/mst_support_range_value/${cd}`);
}

/**
 * 薬剤平均投与量取得
 * @param {*} cd
 */
 export function sendRequestGetAvgInvestData(cd) {
  return ApiHelper.get(`${URL_BASE}/mst_support_avgInvest_value/${cd}`);
}

/**
 * 検査項目の単位取得
 * @param {*} investmentSupportParameter
 */
 export function sendRequestGetInvestmentSupport(investmentSupportParameter) {
  return ApiHelper.get(`${URL_BASE}/mst_support_investment_value/${investmentSupportParameter}`);
}

/**
 * 保存処理
 * @param {*} saveParameter
 */
 export function sendRequestSaveRecord(saveParameter) {
  return ApiHelper.post(`${URL_BASE}/mst_support_save_value/${saveParameter}`);
}