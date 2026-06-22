/**
 * 定型文系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

function withSelectedPatId(params = undefined, selectedPatId) {
  if (selectedPatId === null || selectedPatId === undefined || selectedPatId === "") {
    return params;
  }
  return {
    ...(params || {}),
    selectedPatId
  };
}

/**
 * 定型文取得.
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetFixedPhrase(facilityCd, selectedPatId) {
  return ApiHelper.get(
    `/mstInfo/mstComFixedPhrase`,
    withSelectedPatId({ facilityCd }, selectedPatId)
  );
}
