/**
 * 患者情報共有API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

/**
 * 共有先施設と共有元施設情報を取得
 */
export function sendRequestGetShrFacilityList() {
  return ApiHelper.get("/shrPatInfo/facilityCdDown");
}

/**
 * 患者情報共有を取得
 */
export function sendRequestGetShrList(params) {
  return ApiHelper.post("/shrPatInfo/patientInformation/sharing", params);
}

/**
 * 患者情報共有詳細を取得
 */
export function sendRequestGetShrDetailsList(patId) {
  return ApiHelper.get(`/shrPatInfo/sharingDetails/${patId}`);
}

/**
 * 系列施設を取得
 */
export function sendRequestGetCorrespondingFacilities() {
  return ApiHelper.get(`/shrPatInfo/correspondingFacilities`);
}

/**
 * 患者情報を取得
 */
export function sendRequestGetOutPatList() {
  return ApiHelper.get(`/shrPatInfo/patientDetailsDown`);
}

/**
 * 患者情報共有を新規
 */
export function sendRequestAddShrPatInfo(params) {
  return ApiHelper.post("/shrPatInfo/saveShrPatInfo", params);
}

/**
 * 患者情報共有を編集
 */
export function sendRequestSaveShrPatInfo(params) {
  return ApiHelper.put("/shrPatInfo/updateShrPatInfo", params);
}

/**
 * 患者情報共有を削除
 */
export function sendRequestDeleteShrPatInfo(patId) {
  return ApiHelper.put(`/shrPatInfo/deleteShrPatInfo/${patId}`);
}

/**
 * ファイルをダウンロード
 */
export function sendRequestGetDownload(filepath) {
  return ApiHelper.get(`/shrPatInfo/files/?filepath=${filepath}`);
}