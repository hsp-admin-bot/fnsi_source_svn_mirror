/**
 * デバイスエッジ通知系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

// #10518 2024.04.19 add 共通ローダーを使用するリクエストメソッドを追加 TDC米沢 start
import store from "@/stores";

/**
 * 共通ローダを実行するGETリクエスト
 * @param {*} url URL
 * @param {*} params パラメータ
 */
function getWithLoader(url, params) {
  store.dispatch("loading-screen/startLoadingScreen", null);
  return ApiHelper.get(url, params).finally(() =>
    store.dispatch("loading-screen/finishLoadingScreen")
  );
}
/**
 * 共通ローダを実行するPUTリクエスト
 * @param {*} url URL
 * @param {*} params パラメータ
 */
function putWithLoader(url, params) {
  store.dispatch("loading-screen/startLoadingScreen", null);
  return ApiHelper.put(url, params).finally(() =>
    store.dispatch("loading-screen/finishLoadingScreen")
  );
}
/**
 * 共通ローダを実行するPOSTリクエスト
 * @param { String } url URL
 * @param {any} params パラメータ
 */
function postWithLoader(url, params) {
  store.dispatch("loading-screen/startLoadingScreen", null);
  return ApiHelper.post(url, params).finally(() =>
    store.dispatch("loading-screen/finishLoadingScreen")
  );
}
// #10518 2024.04.19 add 共通ローダーを使用するリクエストメソッドを追加 TDC米沢 end

/**
 * デバイスエッジ通知用URL
 */
const DEVICE_EDGE_ORDER = "/device_edge_order";

/**
 * 施設内のデバイスエッジリストを取得
 */
export function sendRequestMstDeviceEdgeNo() {
  return ApiHelper.get(`${DEVICE_EDGE_ORDER}/device-edge-list`);
}
// ADD マスタ一覧 1･施設切替を可能とする 孔 START
export function sendRequestMstDeviceEdgeNoByFacilityCd(facilityCd) {
  return ApiHelper.get(`${DEVICE_EDGE_ORDER}/device-edge-list/${facilityCd}`);
}
// ADD マスタ一覧 1･施設切替を可能とする 孔 END

/**
 * 患者割り当て通知
 * @param {object} param
 * @param {number} param.ordNo オーダー番号
 * @param {number} param.machineNo 装置マスタ.装置番号
 * @param {number} param.deviceEdgeNo デバイスエッジ番号
 * @param {string} param.facilityCd 施設コード
 */
export function sendRequestPatAssignmentDeviceEdges(param) {
  return ApiHelper.post(`${DEVICE_EDGE_ORDER}/set_unknown_pat`, param);
}
/**
 * 愁訴処置マスタ同期
 * @param {object} param
 * @param {number} param.ordNo オーダー番号
 * @param {number} param.machineNo 装置マスタ.装置番号
 * @param {number} param.deviceEdgeNo デバイスエッジ番号
 * @param {string} param.facilityCd 施設コード
 */
export function sendRequestMstComplaintSync(param) {
  return ApiHelper.post(`${DEVICE_EDGE_ORDER}/reload_complaint_master`, param);
}
/**
 * チェックリストマスタ同期
 * @param {object} param
 * @param {number} param.ordNo オーダー番号
 * @param {number} param.machineNo 装置マスタ.装置番号
 * @param {number} param.deviceEdgeNo デバイスエッジ番号
 * @param {string} param.facilityCd 施設コード
 */
export function sendRequestMstChecklistSync(param) {
  return ApiHelper.post(`${DEVICE_EDGE_ORDER}/reload_checklist_master`, param);
}
/**
 * 検査項目マスタ同期
 * @param {object} param
 * @param {number} param.ordNo オーダー番号
 * @param {number} param.machineNo 装置マスタ.装置番号
 * @param {number} param.deviceEdgeNo デバイスエッジ番号
 * @param {string} param.facilityCd 施設コード
 */
export function sendRequestMstExamItemSync(param) {
  return ApiHelper.post(`${DEVICE_EDGE_ORDER}/reload_exam_master`, param);
}

/**
 * オフライン運転開始
 * @param {object} params
 * @param {number} params.ordNo オーダー番号
 * @param {number} params.machineNo 装置マスタ.装置番号
 * @param {number} params.deviceEdgeNo デバイスエッジ番号
 * @param {string} params.facilityCd 施設コード
 */
export function sendRequestStartOfflineTreating(params) {
  return ApiHelper.post(`${DEVICE_EDGE_ORDER}/start_treat_offline`, params);
}
/**
 * オフライン運転終了
 * @param {object} params
 * @param {number} params.ordNo オーダー番号
 * @param {number} params.machineNo 装置マスタ.装置番号
 * @param {number} params.deviceEdgeNo デバイスエッジ番号
 * @param {string} params.facilityCd 施設コード
 */
export function sendRequestEndOfflineTreating(params) {
  return ApiHelper.post(`${DEVICE_EDGE_ORDER}/end_treat_offline`, params);
}

//add 次患者情報更新の追加 房 start
/**
 * 次患者情報
 * @param {object} params
 * @param {number} params.ordNo オーダー番号
 * @param {number} params.machineNo 装置マスタ.装置番号
 * @param {number} params.deviceEdgeNo デバイスエッジ番号
 * @param {string} params.facilityCd 施設コード
 */
export function sendRequestSendNextPatInfoRst(params) {
  return ApiHelper.post(`${DEVICE_EDGE_ORDER}/send_next_pat`, params);
}

//FNSI-修正 #5525 横展開対応、xugj add start
/**
 * 次患者情報更新
 * @param {object} params
 * @param {number} params.ordNo オーダー番号
 * @param {number} params.machineNo 装置マスタ.装置番号
 * @param {number} params.deviceEdgeNo デバイスエッジ番号
 * @param {string} params.facilityCd 施設コード
 */
export function sendRequestSendNextPatInfoRstViewer(params) {
  return ApiHelper.post(`${DEVICE_EDGE_ORDER}/send_next_pat_viewer`, params);
}

/**
 * レポート更新情報
 * @param {object} params
 * @param {number} params.ordNo オーダー番号
 * @param {number} params.machineNo 装置マスタ.装置番号
 * @param {number} params.deviceEdgeNo デバイスエッジ番号
 * @param {string} params.facilityCd 施設コード
 */
export function sendRequestSendReportUpdateInfoRst(params) {
  return ApiHelper.post(`${DEVICE_EDGE_ORDER}/send_report_update`, params);
}
//add 次患者情報更新の追加 房 end

//add FNSI内容修正 外部Api調用 房 start
/**
 * 治療終了日付情報
 * @param {object} params
 * @param {number} params.ordNo オーダー番号
 * @param {number} params.machineNo 装置マスタ.装置番号
 * @param {number} params.deviceEdgeNo デバイスエッジ番号
 * @param {string} params.facilityCd 施設コード
 */
export function sendRequestSendEndDateUpdateInfoRst(params) {
  return ApiHelper.post(`${DEVICE_EDGE_ORDER}/send_end_date_update`, params);
}

/**
 * お知らせ送信
 * @param {object} params
 * @param {number} params.ordNo オーダー番号
 * @param {number} params.machineNo 装置マスタ.装置番号
 * @param {number} params.deviceEdgeNo デバイスエッジ番号
 * @param {string} params.facilityCd 施設コード
 */
export function sendRequestChangeIndMediInfoRst(params) {
  return ApiHelper.post(`${DEVICE_EDGE_ORDER}/change_ind_medi`, params);
}
//add FNSI内容修正 外部Api調用 房 end
//add FNSI内容修正 外部Api調用 ljx start
/**
 * お知らせ送信
 * @param {object} params
 * @param {number} params.ordNo オーダー番号
 * @param {number} params.machineNo 装置マスタ.装置番号
 * @param {number} params.deviceEdgeNo デバイスエッジ番号
 * @param {string} params.facilityCd 施設コード
 */
export function sendRequestChangeTreatTime(params) {
  return ApiHelper.post(`${DEVICE_EDGE_ORDER}/change_treat_time`, params);
}
//add FNSI内容修正 外部Api調用 ljx end

// #10518 2024.04.19 add 対象患者が現患者のベッドに対して「実績確定・削除時装置レポート画像更新」通知を行うREST-APIリクエストを追加 TDC米沢 start
/**
 * 実績確定・削除時装置レポート画像更新
 * @param {object} params
 * @param {number} params.patId 患者Id
 * @param {string} params.facilityCd 施設コード
 */
export function sendRequestAllReportUpdateByPatId(params) {
  return postWithLoader(
    `${DEVICE_EDGE_ORDER}/send_all_report_update_by_pat_id`,
    params
  );
}
// #10518 2024.04.19 add 対象患者が現患者のベッドに対して「実績確定・削除時装置レポート画像更新」通知を行うREST-APIリクエストを追加 TDC米沢 end
