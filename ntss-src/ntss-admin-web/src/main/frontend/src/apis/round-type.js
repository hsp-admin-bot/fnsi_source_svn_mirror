/**
 * 種別系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

/**
 * 種別取得.
 * @param {string} facilityCd 施設コード
 */
 // mod #12462 患者情報共有 Ji start
export function sendRequestGetRoundTypeNameAndContent(facilityCd, patId) {
  // return ApiHelper.get(`/round-type/${facilityCd}/name-and-content`);
  if (patId) {
    return ApiHelper.get(`/round-type/${facilityCd}/name-and-content/${patId}`);
  }
  // mod #12462 患者情報共有 Ji end
  return ApiHelper.get(`/round-type/${facilityCd}/name-and-content`);
}
