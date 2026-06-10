/**
 * よく使う施設マスタ系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

/**
 * 参照先URL
 */
const URL_BASE = "/master_maintenance/mst_favorite_facility";

// add FNSI-よく使う施設の変更 関 start
export function sendRequestGetFavoriteFacility(facilityCd) {
  return ApiHelper.get(`${URL_BASE}/getFacilityFavoriteFacility/${facilityCd}`);
}
// add FNSI-よく使う施設の変更 関 start


