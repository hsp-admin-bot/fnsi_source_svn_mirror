/**
 * 検査依頼用API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

/**
 * 参照先URL(radRequest)
 */
const URL_BASE = "/rad/radRequest";

/**
 * （検査依頼一覧）
 * 検索結果に表示されている患者の検査依頼一覧を取得.
 * @param {*} reqData 患者IDのリスト、表示開始日、表示終了日
 */
export function sendRequestPatRadMain(reqData) {
  return ApiHelper.post(`${URL_BASE}`, reqData);
}

/**
 * 検査依頼保存.
 * @param {*} request リクエストデータ
 */
export function sendRequestUpdateRecordList(request) {
  return ApiHelper.put(`${URL_BASE}/save`, request);
}

/**
 * 指定施設検査セットデータ取得
 * @param {*} facilityCd
 */
export function sendRequestGetMstRadSetList(facilityCd) {
  return ApiHelper.get(`${URL_BASE}/radSet/${facilityCd}`);
}

/**
 * 患者情報取得
 * @param {*} patIdList
 */
export function sendRequestGetPatInfoList(patIdList) {
  const payload = {
    patIdList: JSON.stringify(patIdList)
  }
  return ApiHelper.post(`${URL_BASE}/getPatInfoList`, payload);
}
