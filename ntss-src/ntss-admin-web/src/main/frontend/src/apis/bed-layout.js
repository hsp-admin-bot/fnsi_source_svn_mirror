/**
 * 治療状況マップベッドレイアウト系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

/**
 * 治療状況リスト用URL
 */
const URL_BASE_BED_LAYOUT = "/bed_layout";

export function sendRequestGetBedLayoutList(facilityCd) {
  return ApiHelper.get(`${URL_BASE_BED_LAYOUT}/${facilityCd}`);
}

export function sendRequestGetBedLayout(facilityCd, layoutId) {
  return ApiHelper.get(`${URL_BASE_BED_LAYOUT}/${facilityCd}/${layoutId}`);
}
