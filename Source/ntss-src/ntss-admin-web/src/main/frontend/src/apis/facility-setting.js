/**
 * 施設設定マスタ系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

function withSelectedPatId(params = undefined, selectedPatId) {
  if (selectedPatId === null || selectedPatId === undefined || selectedPatId === "") {
    return params;
  }
  return {
    ...(params || {}),
    selectedPatId
  };
}

/**
 * 参照先URL
 */
const URL_BASE = "/facilitySetting";

/**
 * 施設設定データ取得
 * @param {string} facilityCd 施設コード
 * @param {string|number} facilitySettingNo 設定番号
 */
export function sendRequestGetMstFacilitySettingValue(facilityCd, facilitySettingNo, selectedPatId) {
  return ApiHelper.get(
    `${URL_BASE}/getFacilitySettingValue/${facilityCd}/${facilitySettingNo}`,
    withSelectedPatId(undefined, selectedPatId)
  );
}

// add FNSI-7217 バッチ操作インターフェイスを追加します 查 start
/**
 * 施設設定データ取得(バッチ)
 * @param {string} facilityCd 施設コード
 * @param {string} facilitySettingNos 設定番号（カンマ区切り等、API 仕様に従う）
 */
export function sendRequestGetMstFacilitySettingValueMap(facilityCd, facilitySettingNos) {
  return ApiHelper.get(`${URL_BASE}/getFacilitySettingValueMap/${facilityCd}/${facilitySettingNos}`);
}
// add FNSI-7217 バッチ操作インターフェイスを追加します 查 end
