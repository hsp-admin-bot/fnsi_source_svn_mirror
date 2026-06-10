/**
 * ローグ系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";
/**
 * ストア系
 */
import store from "@/stores";

/**
 * 参照先URL
 */
const URL_BASE = "/logs";
const SEARCH_CONDITION = "searchCondition";
const UPDATE_CONDITION = "updateSearchCondition";
const GET_FILTER_LOG = "getFilterLog";
// add 変更履歴画面追加 陳 start
const GET_CHANGE_LOG = "getChangeLog";
// add 変更履歴画面追加 陳 end
const READ_LOG = "readLog";
const URL_MST_INFO = "/mstInfo";
const GET_DIRECTORY = "get-directory";
const DOWNLOAD_LOG = "download-log";
/**
 * すべての機能を取得する
 * @param {String} facilityCd
 */
export function getSysAllFunction(facilityCd) {
  return getWithLoader(`${URL_MST_INFO}/sysAllFunction/${facilityCd}`);
}

/**
 *
 */
export function getListModule() {
  return {
    data: [
      {
        moduleCd: 0,
        moduleName: "ntss-admin-web"
      },
      {
        moduleCd: 1,
        moduleName: "ntss-alive-moni"
      },
      {
        moduleCd: 2,
        moduleName: "ntss-alive-moni-auto"
      },
      {
        moduleCd: 3,
        moduleName: "ntss-api"
      },
      {
        moduleCd: 4,
        moduleName: "ntss-client-comm"
      },
      {
        moduleCd: 5,
        moduleName: "ntss-coop-api"
      },
      {
        moduleCd: 6,
        moduleName: "ntss-core"
      },
      {
        moduleCd: 7,
        moduleName: "ntss-data-gathering"
      },
      {
        moduleCd: 8,
        moduleName: "ntss-data-gathering-auto"
      },
      {
        moduleCd: 9,
        moduleName: "ntss-develop-tdc"
      },
      {
        moduleCd: 10,
        moduleName: "ntss-device-edge"
      },
      {
        moduleCd: 11,
        moduleName: "ntss-device-edge-updater"
      },
      {
        moduleCd: 12,
        moduleName: "ntss-device-edge-updater-front"
      },
      {
        moduleCd: 13,
        moduleName: "ntss-m-notice"
      },
      {
        moduleCd: 14,
        moduleName: "ntss-monitoring"
      },
      {
        moduleCd: 15,
        moduleName: "ntss-web-api"
      }
    ],
    status: 200
  };
}

/**
 * 検索条件取得
 * @param {number} userId ユーザーID
 */
export function sendRequestGetSearchCondition(userId) {
  return getWithLoader(`${URL_BASE}/${SEARCH_CONDITION}/${userId}`);
}

export function sendRequestGetDownloadPath(path) {
  return getWithLoader(`${URL_BASE}/${GET_DIRECTORY}`, path);
}

export function sendRequestGetDownloadLog(path) {
  return getWithLoader(`${URL_BASE}/${GET_DIRECTORY}/${DOWNLOAD_LOG}`, path, {
    responseType: "blob"
  });
}

/**
 * ログ設定反映ボタン処理
 */
export function sendRequestLoggerSetFlgUpddate() {
  return putWithLoader(`${URL_BASE}/loggerSetFlg/update`, null, false);
}

/**
 * 検索条件を更新する。
 * @param {number} userId ユーザーID
 * @param {Array} conditionList 検索条件リスト
 */
export function sendRequestUpdateCondition(params) {
  const userId = params.userId;
  const conditionList = params.conditionList;
  return putWithLoader(
    `${URL_BASE}/${UPDATE_CONDITION}/${userId}`,
    conditionList
  );
}

/**
 * 検索条件のローグ取得
 * @param {String} folderName フォルダ名
 * @param {Object} condition 検索条件
 */
//update FNSI-mongoDBに挿入、検索できることの対応 start
export function sendRequestGetFilterLog(params,scrollSelect) {
  const folderName = params.folderName;
  const condition = params.condition;
  return putWithLoader(
    `${URL_BASE}/${GET_FILTER_LOG}/${folderName}`,
    condition,
    scrollSelect
  );
}
//update FNSI-mongoDBに挿入、検索できることの対応 end

// add 変更履歴画面追加 陳 start
/**
 * 検索条件のローグ取得
 * @param {String} folderName フォルダ名
 * @param {Object} condition 検索条件
 */
export function sendRequestGetChangeLog(params) {
  const folderName = params.folderName;
  const condition = params.condition;
  store.dispatch("loading-screen/setLoadingScreenMessage", "処理中・・・");
  store.dispatch("loading-screen/setLoadingScreenVisible", true);
  return ApiHelper.put(`${URL_BASE}/${GET_CHANGE_LOG}/${folderName}`, condition).finally(() =>
    store.dispatch("loading-screen/setLoadingScreenVisible", false)
  );
}
// add 変更履歴画面追加 陳 end

/**
 * 施設コードのローグ取得
 * @param {String} folderName フォルダ名
 * @param {String} facilityCd 施設コード
 */
export function sendRequestReadLog(params) {
  const folderName = params.folderName;
  const facilityCd = params.facilityCd;
  return putWithLoader(`${URL_BASE}/${READ_LOG}/${folderName}/${facilityCd}`);
}

/**
 * 共通ローダを実行するGETリクエスト
 * @param {String} url URL
 * @param {*} params パラメータ
 * @param {*} config 設定
 */
function getWithLoader(url, params = undefined, config = undefined) {
  store.dispatch("loading-screen/setLoadingScreenMessage", "処理中・・・");
  store.dispatch("loading-screen/setLoadingScreenVisible", true);
  return ApiHelper.configGet(url, params, config).finally(() =>
    store.dispatch("loading-screen/setLoadingScreenVisible", false)
  );
}

/**
 * 共通ローダを実行するPUTリクエスト
 * @param {String} url URL
 * @param {*} params パラメータ
 */
//update FNSI-mongoDBに挿入、検索できることの対応 start
function putWithLoader(url, params,scrollSelect) {
  if (scrollSelect == false) {
    store.dispatch("loading-screen/setLoadingScreenMessage", "処理中・・・");
    store.dispatch("loading-screen/setLoadingScreenVisible", true);
  }

  return ApiHelper.put(url, params).finally(() =>
    store.dispatch("loading-screen/setLoadingScreenVisible", false)
  );
}
//update FNSI-mongoDBに挿入、検索できることの対応 end
