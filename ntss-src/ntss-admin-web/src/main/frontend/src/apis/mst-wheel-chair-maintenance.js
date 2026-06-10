/**
 * 車いすマスタ系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

/**
 * 簡易条件による患者リストの情報取得
 * @param {*} facilityCd
 */
export function sendRequestGetPatPersonal(facilityCd) {
  let conditions = null;
  let ord_schedule = null;
  conditions = { ord_schedule, facilityCdList: [facilityCd] };
  return ApiHelper.post("/patInfo/getSimpleSearchResult", { ...conditions });
}

// add マスタ一覧 1･施設切替を可能とする 孔 start
export function sendRequestGetPatPersonalByFacilityCd(facilityCd) {
  let conditions = null;
  let ord_schedule = null;
  conditions = { ord_schedule, facilityCdList: [facilityCd] };
  return ApiHelper.post(`/patInfo/getSimpleSearchResult/${facilityCd}`, { ...conditions });
}
// add マスタ一覧 1･施設切替を可能とする 孔 end

/**
 * 施設コードに該当する利用者の情報取得
 * @param {*} facilityCd
 */
export function sendRequestGetMstPersonalUser(facilityCd) {
  return ApiHelper.get("/mstInfo/mstPersonalUser", { facility_cd: facilityCd });
}

/**
 * 施設コードに該当する利用者の情報取得(削除済み含む)
 */
export function sendRequestGetMstPersonalUserName() {
  return ApiHelper.get("/weight_setting/users/1");
}

// add マスタ一覧 1･施設切替を可能とする 孔 start
export function sendRequestGetMstPersonalUserNameByFacilityCd(facilityCd) {
  return ApiHelper.get(`/weight_setting/users/1/${facilityCd}`);
}
// add マスタ一覧 1･施設切替を可能とする 孔 end

/**
 * 施設コードに該当する利用者名の情報取得
 * @param {*} facilityCd
 */
export function sendRequestGetPatNameByFacilityCd(facilityCd) {
  return ApiHelper.get(`/patPersonalMain/getPatNameByFacilityCd/${facilityCd}`);
}

/**
 * 患者IDに該当する利用者名の情報取得
 * @param {*} patId
 */
export function sendRequestGetPatNameByPatId(patId) {
  return ApiHelper.get(`/patPersonalMain/getPatNameByPatId/${patId}`);
}
