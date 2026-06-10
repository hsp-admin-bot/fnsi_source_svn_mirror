// @ts-check

/**
 * 患者経過総合ビューア系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";


/**
 * 該当患者の身体情報取得
 * 施設コードに紐づく装置一覧取得
 * @param {*} patId 施設コード
 */
/* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
// export function sendRequestFindPhysicalInfo(patId) {
//   return ApiHelper.get(`/patInfo/physical-info/${patId}`);
export function sendRequestFindPhysicalInfo(patId, patShareMode=1) {
  return ApiHelper.get(`/patInfo/physical-info/${patId}/${patShareMode}`);
}
/* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --end */

/**
 * @param {*} patIdList
 */
export function sendRequestGetPatMain(patIdList) {
  const payload = {
    patIdList: patIdList
  }
  return ApiHelper.post(`/patInfo/getPatMainByIdList`, payload);
}
