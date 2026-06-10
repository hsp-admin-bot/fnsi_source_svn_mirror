/**
 * 施設設定マスタ系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

/**
 * 参照先URL
 */
const URL_BASE = "/facilitySetting";

/**
 * 施設設定データ取得
 * @param {*} facilityCd
 * @param {*} facilitySettingNo
 */
export function sendRequestGetMstFacilitySettingValue(facilityCd,facilitySettingNo) {
  return ApiHelper.get(`${URL_BASE}/getFacilitySettingValue/${facilityCd}/${facilitySettingNo}`);
}

// add FNSI-7217 バッチ操作インターフェイスを追加します 查 start
/**
 * 施設設定データ取得(バッチ)
 * @param {*} facilityCd
 * @param {*} facilitySettingNos
 */
 export function sendRequestGetMstFacilitySettingValueMap(facilityCd,facilitySettingNos) {
  return ApiHelper.get(`${URL_BASE}/getFacilitySettingValueMap/${facilityCd}/${facilitySettingNos}`);
}
// add FNSI-7217 バッチ操作インターフェイスを追加します 查 end

