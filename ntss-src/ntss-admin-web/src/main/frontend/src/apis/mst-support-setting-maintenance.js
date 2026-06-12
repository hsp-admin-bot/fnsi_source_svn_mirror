/**
 * 投薬支援マスタ系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

const URL_BASE = "/master_maintenance";

function toPathParam(parameter) {
  return Array.isArray(parameter) ? parameter.join(",") : parameter;
}

/**
 * 投薬支援一覧の取得
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetMstSupportSettingData(facilityCd) {
  return ApiHelper.get(`${URL_BASE}/mst_support_setting/${facilityCd}`);
}

/**
 * 結果値の取得
 * @param {string} cycLingParameter URL パス用パラメータ
 */
export function sendRequestGetMasterData(cycLingParameter) {
  return ApiHelper.get(`${URL_BASE}/mst_support_result_value/${toPathParam(cycLingParameter)}`);
}

/**
 * 検査平均値の取得
 * @param {string} checkAvgParameter URL パス用パラメータ
 */
export function sendRequestGetCheckAvgData(checkAvgParameter) {
  return ApiHelper.get(`${URL_BASE}/mst_support_checkAvg_value/${toPathParam(checkAvgParameter)}`);
}

/**
 * 初期レンジの取得
 * @param {string} cd URL パス用パラメータ
 */
export function sendRequestGetRange(cd) {
  return ApiHelper.get(`${URL_BASE}/mst_support_range_value/${cd}`);
}

/**
 * 薬剤平均投与量取得
 * @param {string} cd URL パス用パラメータ
 */
export function sendRequestGetAvgInvestData(cd) {
  return ApiHelper.get(`${URL_BASE}/mst_support_avgInvest_value/${toPathParam(cd)}`);
}

/**
 * 検査項目の単位取得
 * @param {string} investmentSupportParameter URL パス用パラメータ
 */
export function sendRequestGetInvestmentSupport(investmentSupportParameter) {
  return ApiHelper.get(
    `${URL_BASE}/mst_support_investment_value/${toPathParam(investmentSupportParameter)}`
  );
}

/**
 * 保存処理
 * @param {string} saveParameter URL パス用パラメータ
 */
export function sendRequestSaveRecord(saveParameter) {
  return ApiHelper.post(`${URL_BASE}/mst_support_save_value/${toPathParam(saveParameter)}`);
}
