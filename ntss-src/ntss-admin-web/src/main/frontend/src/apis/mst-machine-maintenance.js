/**
 * 装置マスタ系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

function withSelectedPatId(params = undefined, selectedPatId) {
  if (selectedPatId === null || selectedPatId === undefined || selectedPatId === "") {
    return params;
  }
  return {
    ...(params || {}),
    selectedPatId
  };
}

/**
 * 参照先URL
 */
const URL_BASE = "/master_maintenance/mst_machine";

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
  //mod 9871デバイスエッジが並び順の通りに表示しない zhao start
  // return ApiHelper.get(`${URL_BASE}/combos/${facilityCd}`);
  return ApiHelper.get(`${URL_BASE}/combos1/${facilityCd}`);
  //mod 9871デバイスエッジが並び順の通りに表示しない zhao start
}

/**
 * 装置マスタ同期
 */
export function sendRequestSynchroMstMachine(deviceEdgeNo, facilityCd) {
  return ApiHelper.post(`${URL_BASE}/synchro/${deviceEdgeNo}/${facilityCd}`);
}

/**
 * オンライン装置とオフライン装置を切り替えた装置の工程状態を更新
 * @param {String} facilityCd 施設コード
 * @param {number[]} newOfflineCodeList オンライン->オフライン装置に変更した装置番号
 * @param {number[]} newOnlineCodeList オフライン->オンライン装置に変更した装置番号
 */
export function sendRequestUpdateMstOfflineMachine(
  facilityCd,
  newOfflineCodeList,
  newOnlineCodeList
) {
  return ApiHelper.put(`${URL_BASE}/state/offline`, {
    facilityCd: facilityCd,
    newOfflineCodeList: newOfflineCodeList,
    newOnlineCodeList: newOnlineCodeList
  });
}

/**
 * 装置自動登録処理用ワークテーブル取得
 * @param {*} facilityCd
 */
export function sendRequestGetMntFindMachineByFacility(facilityCd){
  return ApiHelper.get(`${URL_BASE}/list/${facilityCd}`);
}

/**
 * 装置自動登録の通知指示
 * @param {*} facilityCd
 */
export function sendRequestPostNotificationMachine(procMode,facilityCd){
  return ApiHelper.post(`${URL_BASE}/notification/${procMode}/${facilityCd}`);
}

/**
 * 装置工程状態の取得
 * @param {String} facilityCd
 */
export function sendRequestGetDialysisState(facilityCd) {
  return ApiHelper.get(`${URL_BASE}/dialysis-entry/${facilityCd}`);
}

/**
 * 通信フォーマットがオンライン/通信共通装置になった装置と装置シリアル・型式・通信フォーマットを切り替えた装置の状態を更新
 * @param {String} facilityCd 施設コード
 * @param {number[]} newOfflineAndCommonCodeList オフライン装置または通信共通に変更した装置番号
 * @param {number[]} changeMachineCodeList 装置シリアル・型式・通信フォーマットを切り替えた装置番号
 */
export function sendRequestUpdateChangeMachine(
  facilityCd,
  newOfflineAndCommonCodeList,
  changeMachineCodeList
) {
  return ApiHelper.put(`${URL_BASE}/change-machine`, {
    facilityCd: facilityCd,
    newOfflineAndCommonCodeList: newOfflineAndCommonCodeList,
    changeMachineCodeList: changeMachineCodeList
  });
}

// #11124 2025.08.26 add 酸素飽和度対応 TDC高村 start
/**
 * ΔSO2を使用する装置件数取得
 * @param {String} facilityCd
 */
export function getMachineSo2OptCount(facilityCd, selectedPatId) {
  return ApiHelper.get(
    `${URL_BASE}/So2OptCount/${facilityCd}`,
    withSelectedPatId(undefined, selectedPatId)
  );
}
// #11124 2025.08.26 add 酸素飽和度対応 TDC高村 end
