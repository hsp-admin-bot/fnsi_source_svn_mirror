/**
 * 治療状況マップベッドレイアウト系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

/**
 * ベッドレイアウト用URL
 */
const URL_BASE_BED_LAYOUT = "/bed_layout";

/**
 * ベッドレイアウト一覧取得
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetBedLayoutList(facilityCd) {
  return ApiHelper.get(`${URL_BASE_BED_LAYOUT}/${facilityCd}`);
}

/**
 * ベッドレイアウト詳細取得
 * @param {string} facilityCd 施設コード
 * @param {string|number} layoutId レイアウトID
 */
export function sendRequestGetBedLayout(facilityCd, layoutId) {
  return ApiHelper.get(`${URL_BASE_BED_LAYOUT}/${facilityCd}/${layoutId}`);
}
