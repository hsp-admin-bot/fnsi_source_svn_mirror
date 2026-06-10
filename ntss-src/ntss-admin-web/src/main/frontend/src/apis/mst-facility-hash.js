/**
 * 施設マスタ系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

/**
 * 参照先URL
 */
const URL_BASE = "/facilities/MstFacilityHash";

/**
 * データ一覧取得(施設コード指定).
 */
export function sendRequestGetMstFacilityHashByFacilityCd(facilityCd) {
  return ApiHelper.get(`${URL_BASE}/${facilityCd}`);
}


/**
 * データ一覧取得(すべて).
 */
export function sendRequestGetMstFacilityHash() {
  return ApiHelper.get(`${URL_BASE}/SelectAll`);
}
