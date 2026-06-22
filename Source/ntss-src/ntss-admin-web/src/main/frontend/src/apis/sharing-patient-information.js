/**
 * 患者情報共有リスト系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

/**
 * URL
 */
const URL_BASE = "/pat_name_identification";

/**
 * 他施設へ開示する患者情報を取得
 * @param {Record<string, unknown>} [param] 検索患者一覧など
 */
export function requestGetPublicPatient(param = {}) {
  return ApiHelper.post(`${URL_BASE}/sharePatientInfo/getPublicPatient`, param);
}

/**
 * 他施設から受理した患者一覧を取得
 * @param {Record<string, unknown>} [param] 検索患者一覧など
 */
export function requestGetReceivePatient(param = {}) {
  return ApiHelper.post(`${URL_BASE}/sharePatientInfo/getReceivePatient`, param);
}

/**
 * 開示先施設を取得する
 * @param {Record<string, unknown>} [param] facilityCd, selectedPatId など
 */
export function requestGetDstFacilities(param = {}) {
  return ApiHelper.post(`${URL_BASE}/sharingPatientInfo/getDstFacilities`, param);
}

/**
 * 開示先情報を更新
 * @param {Record<string, unknown>} param facilityCd, selectedPatId, dstFacilities, updateRecord など
 */
export function updateDstFacilities(param) {
  return ApiHelper.put(`${URL_BASE}/sharingPatientInfo/updateDstFacilities`, param);
}

/**
 * 患者を自施設に開示した元の施設IDを取得
 * @param {Record<string, unknown>} [param] facilityCd, PatIdDst, PatIdSrc など
 */
export function requestGetSrcFacilities(param = {}) {
  return ApiHelper.post(`${URL_BASE}/sharingPatientInfo/getSrcFacilities`, param);
}

/**
 * 医師かどうかチェック機能
 */
export function requestGetIsDoctor() {
  return ApiHelper.get(`${URL_BASE}/sharePatientInfo/checkDoctor`);
}
