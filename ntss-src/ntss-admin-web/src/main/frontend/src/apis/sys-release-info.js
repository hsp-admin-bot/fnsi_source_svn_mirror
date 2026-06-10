/**
 * リリース情報系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

/**
 * 参照先URL
 */
const URL_BASE = "/release_info";

/**
 * リリース情報データ取得
 */
export function sendRequestGetSySReleaseInfo() {
  return ApiHelper.get(`${URL_BASE}/getSysReleaseInfoAll/`);
}

/**
 * リリース情報データ取得
 */
export function sendRequestGetReleaseDetail(ctl_no) {
  return ApiHelper.get(`${URL_BASE}/getReleaseDetail/${ctl_no}`);
}
