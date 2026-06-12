/**
 * リリース情報系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

/**
 * 参照先URL
 */
const URL_BASE = "/release_info";

/**
 * リリース情報データ取得（一覧）
 */
export function sendRequestGetSysReleaseInfo() {
  return ApiHelper.get(`${URL_BASE}/getSysReleaseInfoAll`);
}

/** @deprecated 旧名。{@link sendRequestGetSysReleaseInfo} を使用 */
export const sendRequestGetSySReleaseInfo = sendRequestGetSysReleaseInfo;

/**
 * リリース情報データ取得（明細）
 * @param {string|number} ctlNo 管理番号
 */
export function sendRequestGetReleaseDetail(ctlNo) {
  return ApiHelper.get(`${URL_BASE}/getReleaseDetail/${ctlNo}`);
}
