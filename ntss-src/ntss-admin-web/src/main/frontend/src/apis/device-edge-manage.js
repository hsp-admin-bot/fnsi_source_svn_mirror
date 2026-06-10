/**
 * デバイスエッジ管理系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";
/**
 * ストア系
 */
import store from "@/stores";

/**
 * デバイスエッジ管理用URL
 */
const DEVICE_EDGE_MANAGE = "/device_edge_manage";

/**
 * エッジの状態取得
 */
export function sendRequestDeviceEdgeStateAll() {
  return getWithLoader(`${DEVICE_EDGE_MANAGE}/device-edge-info`);
}

/**
 * バージョン取得用・エッジの状態取得
 * @param {Object} param
 * @param {String} param.targetFacilityCd
 * @param {number | String} param.deviceEdgeNo
 */
export function sendRequestDeviceEdgeState(param) {
  return getWithLoader(`${DEVICE_EDGE_MANAGE}/device-edge-info/${param.targetFacilityCd}/${param.deviceEdgeNo}`);
}

/**
 * バケット情報取得
 */
export function sendRequestBaseBucket() {
  return getWithLoader(`${DEVICE_EDGE_MANAGE}/target-s3-bucket`);
}

/**
 * デバイスエッジアプリケーション起動・停止の指示
 */
export function sendRequestDeviceEdgeControl(param) {
  return postWithLoader(`${DEVICE_EDGE_MANAGE}/device-control`, param);
}
/**
 * デバイスエッジのログファイル、設定ファイルの収集指示
 */
export function sendRequestDeviceEdgeFileGather(param) {
  return postWithLoader(`${DEVICE_EDGE_MANAGE}/file-gather`, param);
}
/**
 * レストア指示
 * @param {object} param
 */
export function sendRequestDeviceEdgeRestore(param) {
  return postWithLoader(`${DEVICE_EDGE_MANAGE}/restore`, param);
}
/**
 * ファイル更新指示
 * @param {object} param
 */
export function sendRequestDeviceEdgeUpdate(param) {
  return postWithLoader(`${DEVICE_EDGE_MANAGE}/application-update`, param);
}
/**
 * conf更新指示
 * @param {object} param
 */
export function sendRequestDeviceEdgeConfUpdate(param) {
  return postWithLoader(`${DEVICE_EDGE_MANAGE}/conf-update`, param);
}
/**
 * 予約削除指示
 * @param {object} param
 */
export function sendRequestDeviceEdgePlanCancel(param) {
  return postWithLoader(`${DEVICE_EDGE_MANAGE}/plan-cancel`, param);
}
/**
 * ログファイルダウンロードの情報チェック
 * @param {object} param
 * @param {String} param.targetFacilityCd
 * @param {number | String} param.deviceEdgeNo
 * @param {String} param.dateStr
 */
export function sendRequestDeviceEdgeLogFileInfo(param) {
  return getWithLoader(`${DEVICE_EDGE_MANAGE}/target-log-file-info/${param.targetFacilityCd}/${param.deviceEdgeNo}/${param.dateStr}`);
}
/**
 * ログファイルダウンロード
 * @param {*} param リクエスト情報
 */
export function sendRequestDeviceEdgeLogFileDownload(param) {
  return postWithLoader(`${DEVICE_EDGE_MANAGE}/target-log-file/download`, param);
}
/**
 * confファイルダウンロードの情報チェック
 * @param {object} param
 * @param {String} param.targetFacilityCd
 * @param {number | String} param.deviceEdgeNo
 */
export function sendRequestDeviceEdgeConfFileInfo(param) {
  return getWithLoader(`${DEVICE_EDGE_MANAGE}/target-conf-file-info/${param.targetFacilityCd}/${param.deviceEdgeNo}`);
}
/**
 * confファイルアップロードの情報チェック
 * @param {object} param
 * @param {String} param.targetFacilityCd
 * @param {number | String} param.deviceEdgeNo
 */
export function sendRequestDeviceEdgeConfFileUploadInfo(param) {
  return getWithLoader(`${DEVICE_EDGE_MANAGE}/target-conf-upload-info/${param.targetFacilityCd}/${param.deviceEdgeNo}`);
}

export function sendRequestFileUpload(param) {
  return postWithLoader('/s3/upload', param);
}

/**
 * 共通ローダを実行するGETリクエスト
 * @param {String} url URL
 * @param {object} params パラメータ
 */
function getWithLoader(url, params = undefined) {
  store.dispatch("loading-screen/setLoadingScreenMessage", "処理中・・・");
  store.dispatch("loading-screen/setLoadingScreenVisible", true);
  return ApiHelper.get(url, params).finally(() =>
    store.dispatch("loading-screen/setLoadingScreenVisible", false)
  );
}
/**
 * 共通ローダを実行するPOSTリクエスト
 * @param {String} url URL
 * @param {object} params パラメータ
 */
function postWithLoader(url, params) {
  store.dispatch("loading-screen/setLoadingScreenMessage", "処理中・・・");
  store.dispatch("loading-screen/setLoadingScreenVisible", true);
  return ApiHelper.post(url, params).finally(() =>
    store.dispatch("loading-screen/setLoadingScreenVisible", false)
  );
}
