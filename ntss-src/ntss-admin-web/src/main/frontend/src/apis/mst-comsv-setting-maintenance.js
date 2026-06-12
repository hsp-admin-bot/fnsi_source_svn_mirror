/**
 * 通信サーバー設定マスタ同期など（装置マスタ／device_edge_order 連携）
 */
import { ApiHelper } from "@/apis/AxiosHelper";

const URL_MST_MACHINE = "/master_maintenance/mst_machine";
const URL_DEVICE_EDGE_ORDER = "/device_edge_order";

/**
 * 装置型式、デバイスエッジマスタ情報取得
 */
export function sendRequestGetMstMachineComboList() {
  return ApiHelper.get(`${URL_MST_MACHINE}/combos`);
}

/**
 * 装置型式、デバイスエッジマスタ情報取得(施設コード指定)
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetMstMachineComboListFacility(facilityCd) {
  return ApiHelper.get(`${URL_MST_MACHINE}/combos/${facilityCd}`);
}

/**
 * 通信サーバー設定マスタ同期
 * @param {string} facilityCd 施設コード
 * @param {string|number} deviceEdgeNo デバイスエッジ番号
 */
export function sendRequestSynchroMstComSvSetting(facilityCd, deviceEdgeNo) {
  return ApiHelper.post(`${URL_DEVICE_EDGE_ORDER}/reload_comsv_setting`, {
    facilityCd,
    deviceEdgeNo
  });
}
