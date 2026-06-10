/**
 * 定型文系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

/**
 * 定型文取得.
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetFixedPhrase(facilityCd) {
  return ApiHelper.get(`/mstInfo/mstComFixedPhrase`, { facilityCd });
}
