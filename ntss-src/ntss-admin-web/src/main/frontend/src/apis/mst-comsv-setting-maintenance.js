/**
 * 装置マスタ系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

/**
 * 参照先URL
 */
const URL_BASE = "/master_maintenance/mst_machine";

const URL_BASE1 = "/device_edge_order";

/**
 * 装置型式、デバイスエッジマスタ情報取得
 */
export function sendRequestGetMstMachineComboList() {
  return ApiHelper.get(`${URL_BASE}/combos`);
}

/**
 * 装置型式、デバイスエッジマスタ情報取得(施設コード指定)
 */
export function sendRequestGetMstMachineComboListFacility(facilityCd) {
  return ApiHelper.get(`${URL_BASE}/combos/${facilityCd}`);
}

/**
 * 通信サーバー設定マスタ同期
 */
export function sendRequestSynchroMstComSvSetting(facilityCd, deviceEdgeNo) {
  const URL_SUB_RELOAD_COMSV_SETTING = "reload_comsv_setting";
  return ApiHelper.post(`${URL_BASE1}/${URL_SUB_RELOAD_COMSV_SETTING}`, {
    facilityCd,
    deviceEdgeNo
  });
}
