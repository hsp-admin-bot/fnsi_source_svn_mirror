/**
 * 施設ハッシュ（MstFacilityHash）系 API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

const URL_BASE = "/facilities/MstFacilityHash";

/**
 * データ一覧取得（施設コード指定）
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetMstFacilityHashByFacilityCd(facilityCd) {
  return ApiHelper.get(`${URL_BASE}/${facilityCd}`);
}

/**
 * データ一覧取得（全件）
 */
export function sendRequestGetMstFacilityHash() {
  return ApiHelper.get(`${URL_BASE}/SelectAll`);
}
