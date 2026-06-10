/**
 * 予実リスト機能用のAPI.
 */
import { ApiHelper } from "@/apis/AxiosHelper";

/**
 * 指定された患者IDから予実リストを取得する.
 * @param {*} patId 患者ID
 * @param {*} condition 検索条件（治療開始日と治療終了日）
 */
/* eslint-disable no-unused-vars */
export function sendRequestGetIndicationResultList(patId, condition) {
  /* eslint-enable no-unused-vars */
  return ApiHelper.get("/indication-result/" + patId + "/list", condition);
}
// add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start
/**
 * ログインユーザの個人設定に表示形式を設定する(患者イベント)
 * @param {*} condition 検索条件（患者ID、施設コード、治療開始日、治療終了日）
 */
export function sendRequestGetPatientEventResultList(condition) {
  return ApiHelper.get("/indication-result/pat_event/list", condition);
}

/**
 * 検査セットIDで、チェック項目数取得
 * @param {*} condition 検索条件 検査セットID
 */
export function sendRequestGetObtainedInspectionItems(condition) {
  return ApiHelper.get("/indication-result/" + condition);
}

/**
 * ログインユーザの個人設定に表示形式を設定する(検査結果)
 * @param {*} condition 検索条件（患者ID、施設コード、治療開始日、治療終了日）
 */
export function sendRequestGetInspectionResultList(condition) {
  return ApiHelper.get("/indication-result/ins_result/list", condition);
}

/**
 * ログインユーザの個人設定に表示形式を設定する(一般撮影検査予定)
 * @param {*} condition 検索条件（患者ID、施設コード、治療開始日、治療終了日）
 */
export function sendRequestGetGenPhotoInsResultList(condition) {
  return ApiHelper.get("/indication-result/photo/list", condition);
}

/**
 * ログインユーザの個人設定に表示形式を設定する(処方)
 * @param {*} condition 検索条件（患者ID、施設コード、治療開始日、治療終了日）
 */
export function sendRequestGetPrescriptionResultList(condition) {
  return ApiHelper.get("/indication-result/prescription/list", condition);
}
// add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end

