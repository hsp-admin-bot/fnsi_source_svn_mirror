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
 * @param {*} param { searchedPatList } - 検索患者一覧
 */
export function requestGetPublicPatient(param = {}) {
  return ApiHelper.post(`${URL_BASE}/sharePatientInfo/getPublicPatient`, param);
}

/**
 * 他施設から受理した患者一覧を取得
 * @param {*} param { searchedPatList } - 検索患者一覧 
 */
export function requestGetReceivePatient(param = {}) {
  return ApiHelper.post(`${URL_BASE}/sharePatientInfo/getReceivePatient`, param);
}

/**
 * 開示先施設を取得する
 * @param {*} param { facilityCd, selectedPatId } 以下全てパラメータを含む
 * @param {*} facilityCd - 施設ID
 * @param {*} selectedPatId - 選択した患者ID
 */
export function requestGetDstFacilities(param = {}) {
  return ApiHelper.post(`${URL_BASE}/sharingPatientInfo/getDstFacilities`, param);
}

/**
 * 開示先情報を更新
 * @param {*} param { facilityCd, selectedPatId, dstFacilities + updateRecord } 以下全てパラメータを含む
 * @param {*} facilityCd - 施設ID
 * @param {*} selectedPatId - 選択した患者
 * @param {*} dstFacilities - 開示先施設
 */
export function updateDstFacilities(param) {
  return ApiHelper.put(`${URL_BASE}/sharingPatientInfo/updateDstFacilities`, param);
}

/**
 * 患者を自施設に開示した元の施設IDを取得
 * @param {*} param 以下全てパラメータを含む
 * @param {*} facilityCd 自施設CD
 * @param {*} PatIdDst 開示先患者ID
 * @param {*} PatIdSrc 元の患者ID
 */
export function requestGetSrcFacilities(param = {}) {
  return ApiHelper.post(`${URL_BASE}/sharingPatientInfo/getSrcFacilities`, param)
}

/**
 * 医師かどうかチェック機能
 * @param {*} param
 */
export function requestGetIsDoctor() {
  return ApiHelper.get(`${URL_BASE}/sharePatientInfo/checkDoctor`)
}
