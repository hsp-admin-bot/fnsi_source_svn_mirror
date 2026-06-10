/**
 * API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

const URL_BASE = "/external_coop_oper_viewer";

/**
 *
 * @param {*} param
 */
export function sendRequestIconStartStop(param) {
  return ApiHelper.post(`${URL_BASE}/coop`, param);
}

/**
 *
 * @param {*} param
 * @param {*} facilityCd
 */
export function sendRequestGetExternalCoop(facilityCd, param) {
  return ApiHelper.post(`${URL_BASE}/sys_coop_journal/${facilityCd}`, param);
}
// add 5615 IFエッジコマンド実行 関 start
/**
 *
 * @param {*} param
 */
export function sendRequestGetEdgeCommandState(param) {
  return ApiHelper.post(`${URL_BASE}/if_edge_command`, param);
}
/**
 *
 * @param {*} param
 */
export function sendRequestCommandKeyCoop(param) {
  return ApiHelper.post(`${URL_BASE}/commandKey/coop`, param);
}
// add 5615 IFエッジコマンド実行 関 end

/**
 *
 * @param {*} facilityCd
 */
export function sendRequestGetEdgeState(facilityCd) {
  return ApiHelper.get(`${URL_BASE}/if_edge_healmon/${facilityCd}`);
}
// add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
export function sendRequestGetIfEdgeConn(facilityCd) {
  return ApiHelper.get(`${URL_BASE}/if_edge_client_connect/${facilityCd}`);
}

export function getRequestGetIfEdgeConnCount(facilityCd) {
  return ApiHelper.get(`${URL_BASE}/if_edge_client_connect_count/${facilityCd}`);
}
// add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end

/**
 *
 * @param {*} param
 */
export function sendRequestResetEdgeStatus(param) {
  return ApiHelper.post(`${URL_BASE}/reset_edge_status`, param);
}

// add FNSI-連携情報を追加 李 start
/**
 *
 * @param {*} facilityCd
 * @param {*} coopVersion
 * @param {*} selectedPatId
 */
// mod 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
// export function searchConIntelligenceState(facilityCd, selectedPatId) {
//   return ApiHelper.get(`${URL_BASE}/pat_coop_detail/${facilityCd}/${selectedPatId}`);
// }
export function searchConIntelligenceState(facilityCd, coopVersion, selectedPatId) {
  return ApiHelper.get(`${URL_BASE}/pat_coop_detail/${facilityCd}/${coopVersion}/${selectedPatId}`);
}
// mod 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
// add FNSI-連携情報を追加 李 end

/**
 *
 * @param {*} facilityCd
 */
export function getSysCoopJournal(facilityCd) {
  return ApiHelper.get(`${URL_BASE}/if_edge_healmon/${facilityCd}`);
}

/**
 *
 * @param {*} params
 */
export function updateSysCoopJournal(params) {
  return ApiHelper.put(`${URL_BASE}/update_sys_coop_journal/`, params);
}
// add FNSI-6085 ljx start
/**
 * 該当施設がIFエッジある施設であるかの判断
 * @param facilityCd
 * @returns {*}
 */
export function sendRequestGetHasIfEdge(facilityCd) {
  return ApiHelper.get(`${URL_BASE}/has_if_edge/${facilityCd}`);
}
// add FNSI-6085 ljx end
