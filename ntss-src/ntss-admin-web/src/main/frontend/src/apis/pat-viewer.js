/**
 * 患者経過総合ビューア系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

/**
 * 該当患者の身体情報取得
 * @param {string|number} patId 患者ID
 * @param {number} patShareMode 患者共有モード
 */
export function sendRequestFindPhysicalInfo(patId, patShareMode = 1) {
  return ApiHelper.get(`/patInfo/physical-info/${patId}/${patShareMode}`);
}

/**
 * 患者メイン情報を ID リストで取得
 * @param {Array<string|number>} patIdList 患者IDリスト
 */
export function sendRequestGetPatMain(patIdList) {
  const payload = { patIdList };
  return ApiHelper.post(`/patInfo/getPatMainByIdList`, payload);
}
