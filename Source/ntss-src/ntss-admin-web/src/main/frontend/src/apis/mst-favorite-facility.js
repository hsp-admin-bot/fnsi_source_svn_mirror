/**
 * よく使う施設マスタ系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

const URL_BASE = "/master_maintenance/mst_favorite_facility";


// add FNSI-よく使う施設の変更 関 start
/**
 * よく使う施設一覧取得
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetFavoriteFacility(facilityCd) {
  return ApiHelper.get(`${URL_BASE}/getFacilityFavoriteFacility/${facilityCd}`);
}
// add FNSI-よく使う施設の変更 関 end
