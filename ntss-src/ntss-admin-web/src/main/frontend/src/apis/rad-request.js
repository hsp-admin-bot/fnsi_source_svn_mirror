/**
 * 放射線オーダー系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

const URL_BASE = "/rad_request";

/** 検査依頼・スケジュール等で使用する従来エンドポイント（vue2 互換） */
const URL_LEGACY_RAD_REQUEST = "/rad/radRequest";

function selectedPatIdParams(selectedPatId) {
  return selectedPatId === null || selectedPatId === undefined || selectedPatId === ""
    ? undefined
    : { selectedPatId };
}

/**
 * 放射線オーダー一覧を取得
 * @param {string} patId 患者ID
 * @param {string} facilityCd 施設コード
 * @param {Record<string, unknown>} payload 検索条件
 */
export function sendRequestGetRadRequestList(patId, facilityCd, payload) {
  return ApiHelper.post(`${URL_BASE}/list/${patId}/${facilityCd}`, payload);
}

/**
 * 放射線オーダー詳細を取得
 * @param {string} patId 患者ID
 * @param {string} facilityCd 施設コード
 * @param {Record<string, unknown>} payload 検索条件
 */
export function sendRequestGetRadRequestDetail(patId, facilityCd, payload) {
  return ApiHelper.post(`${URL_BASE}/detail/${patId}/${facilityCd}`, payload);
}

/**
 * 検査依頼一覧（患者の検査依頼一覧）vue2 互換
 * @param {*} reqData 患者IDのリスト、表示開始日、表示終了日
 */
export function sendRequestPatRadMain(reqData) {
  return ApiHelper.post(`${URL_LEGACY_RAD_REQUEST}`, reqData);
}

/**
 * 検査依頼保存（vue2 互換）
 * @param {*} request リクエストデータ
 */
export function sendRequestUpdateRecordList(request) {
  return ApiHelper.put(`${URL_LEGACY_RAD_REQUEST}/save`, request);
}

/**
 * 指定施設検査セットデータ取得（vue2 互換）
 * @param {*} facilityCd 施設コード
 */
export function sendRequestGetMstRadSetList(facilityCd, selectedPatId) {
  return ApiHelper.get(`${URL_LEGACY_RAD_REQUEST}/radSet/${facilityCd}`, selectedPatIdParams(selectedPatId));
}

/**
 * 患者情報取得（vue2 互換）
 * @param {*} patIdList 患者IDリスト
 */
export function sendRequestGetPatInfoList(patIdList, selectedPatId) {
  const payload = {
    patIdList: JSON.stringify(patIdList)
  };
  const params = selectedPatIdParams(selectedPatId);
  if (params) {
    return ApiHelper.configPost(`${URL_LEGACY_RAD_REQUEST}/getPatInfoList`, payload, { params });
  }
  return ApiHelper.post(`${URL_LEGACY_RAD_REQUEST}/getPatInfoList`, payload);
}
