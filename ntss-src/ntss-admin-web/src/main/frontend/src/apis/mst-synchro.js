/**
 * マスタ同期系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

/**
 * マスタ同期用URL
 */
const URL_BASE = "/mst_synchro";

/**
 * 施設マスタ情報取得
 */
export function sendRequestGetMstFacilityList() {
  return ApiHelper.get(`${URL_BASE}/mst_facility`);
}

/**
 * 選択施設のデバイスエッジ情報取得
 * @param {*} facilityCd 施設コード
 */
export function sendRequestGetMstDeviceEdgeList(facilityCd) {
  return ApiHelper.get(`${URL_BASE}/mst_device_edge/${facilityCd}`);
}

/**
 * 同期開始要求
 * @param {*} params 同期対象情報
 */
export function sendRequestStartMstSynchro(params) {
  return ApiHelper.post(`${URL_BASE}/synchro/start`, params);
}

/**
 * 同期開始要求(マスタ同期(隠し画面))
 * @param {*} params 同期対象情報
 */
export function sendRequestStartMstSynchroProc(params) {
  return ApiHelper.post(`${URL_BASE}/synchro/start_proc`, params);
}
