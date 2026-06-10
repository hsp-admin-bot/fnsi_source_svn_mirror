/**
 * 施設設定マスタ系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

/**
 * 参照先URL
 */
const URL_BASE = "/master_maintenance/mst_facility_setting";

/**
 * 施設設定一覧の取得
 * @param {*} facilityCd
 */
export function sendRequestGetMstFacilitySettingData(facilityCd) {
  return ApiHelper.get(`${URL_BASE}/${facilityCd}`);
}

/**
 * 施設設定データ取得
 */
export function sendRequestGetMstFacility() {
  return ApiHelper.get(`${URL_BASE}/mst_facility`);
}

/**
 * sendRequestGetValueSignInByFacilityCd
 * @param {*} facilityCd 
 */
export function sendRequestGetValueSignInByFacilityCd(facilityCd) {
  return ApiHelper.get(`${URL_BASE}/get_value_signin/${facilityCd}`);
}


