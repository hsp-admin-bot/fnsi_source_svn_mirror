/**
 * 検査依頼用API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

/**
 * 参照先URL(examRequest)
 */
const URL_BASE = "/exam/examRequest";

/**
 * （検査依頼一覧）
 * 検索結果に表示されている患者の検査依頼一覧を取得.
 * @param {Record<string, unknown>} reqData 患者IDのリスト、表示開始日、表示終了日
 */
export function sendRequestPatExamMain(reqData) {
  return ApiHelper.post(URL_BASE, reqData);
}

function selectedPatIdParams(selectedPatId) {
  return selectedPatId === null || selectedPatId === undefined || selectedPatId === ""
    ? undefined
    : { selectedPatId };
}

/**
 * 検査依頼保存.
 * @param {Record<string, unknown>} request リクエストデータ
 */
export function sendRequestUpdateRecordList(request) {
  return ApiHelper.put(`${URL_BASE}/save`, request);
}

/**
 * 指定施設検査セットデータ取得
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetMstExamSetList(facilityCd, selectedPatId) {
  return ApiHelper.get(`${URL_BASE}/examSet/${facilityCd}`, selectedPatIdParams(selectedPatId));
}

/**
 * 指定施設検査セットデータ取得（削除済み含む）.
 * NOTE: 対象施設に紐づく検査セット（削除済み含む）
 * @param {string} facilityCd 施設コード
 */
export function sendRequestAllExamSetListByFacility(facilityCd, selectedPatId) {
  return ApiHelper.get(`${URL_BASE}/examSet/all/${facilityCd}`, selectedPatIdParams(selectedPatId));
}

/**
 * 透析予定の日付に検査依頼の日付を更新
 * @param {string|number} patId 患者ID
 * @param {string} beDt 変更前の透析予定日
 * @param {string} afDt 変更後の透析予定日
 */
export function sendRequestUpdateRegExamDate(patId, beDt, afDt) {
  const params = {
    patId,
    beforeDate: beDt,
    afterDate: afDt
  };
  return ApiHelper.put("/exam/updateRegExamDate", params);
}

/**
 * 透析予定削除に伴う検査依頼の更新
 * @param {string|number} patId 患者ID
 * @param {string} dt 削除対象の透析予定日
 */
export function sendRequestUpdateIsDel(patId, dt) {
  const params = {
    patId,
    date: dt
  };
  return ApiHelper.put("/exam/updateIsDel", params);
}

/**
 * 患者情報取得
 * @param {unknown[]} patIdList 患者ID配列
 */
export function sendRequestGetPatInfoList(patIdList, selectedPatId) {
  const payload = {
    patIdList: JSON.stringify(patIdList)
  };
  const params = selectedPatIdParams(selectedPatId);
  if (params) {
    return ApiHelper.configPost(`${URL_BASE}/getPatInfoList`, payload, { params });
  }
  return ApiHelper.post(`${URL_BASE}/getPatInfoList`, payload);
}

/**
 * スケジュール延長最終日の最小値を取得
 * @param {string} facilityCd 処理対象の施設コード
 * @param {number[]} patIdList 処理対象患者のID配列
 */
export function sendPostRequestGetMinSchExtEndDate(facilityCd, patIdList) {
  const payload = {
    facilityCd,
    patIdList: JSON.stringify(patIdList)
  };
  return ApiHelper.post(`${URL_BASE}/sch_ext_end_date_post`, payload);
}
