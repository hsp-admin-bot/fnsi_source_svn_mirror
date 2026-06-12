/**
 * 種別系API
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
 * 種別取得.
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetRoundTypeNameAndContent(facilityCd, patId, selectedPatId) {
  if (patId) {
    return ApiHelper.get(
      `/round-type/${facilityCd}/name-and-content/${patId}`,
      withSelectedPatId(undefined, selectedPatId)
    );
  }
  return ApiHelper.get(
    `/round-type/${facilityCd}/name-and-content`,
    withSelectedPatId(undefined, selectedPatId)
  );
}
