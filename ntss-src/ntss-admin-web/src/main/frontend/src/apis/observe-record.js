/**
 * 観察記録系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";
import store from "@/stores";

/**
 * 観察記録用URL
 */
const URL_BASE_PAT_OBS_REC = "/pat_obs_rec";

/**
 * 治療情報の取得
 * @param {*} params  患者ID、治療日、オーダ番号
 */
export function sendRequestGetOrdMainRecordList(params) {
  const URL_SUB_ORD_MAIN = "ord_main_combo";
  return getWithLoader(
    `${URL_BASE_PAT_OBS_REC}/${URL_SUB_ORD_MAIN}/${params.patId}/${
      params.treatDate
    }/${params.ordNo}`
  );
}

/**
 * 観察記録情報取得
 * @param {*} params 患者ID、開始日、終了日
 * @param {string} patObsRecNotIsDel 0:削除されてないもののみ取得
 * @param {string} patObsRecIsNewest 1:最新のデータのみ取得
 */
export function sendRequestGetObserveRecordList(
  params,
  patObsRecNotIsDel,
  patObsRecIsNewest
) {
  return getWithLoader(
    `${URL_BASE_PAT_OBS_REC}/${params.patId}/${params.startDate}/${
      params.endDate
    }/${patObsRecNotIsDel}/${patObsRecIsNewest}`
  );
}
/**
 * 観察記録情報取得
 * @param {*} params オーダ番号
 * @param {string} patObsRecNotIsDel 0:削除されてないもののみ取得
 * @param {string} patObsRecIsNewest 1:最新のデータのみ取得
 */
export function sendRequestGetObserveRecordListByOrdNo(
  params,
  patObsRecNotIsDel,
  patObsRecIsNewest
) {
  const URL_SUB_ORDNO = "ordno";
  return getWithLoader(
    `${URL_BASE_PAT_OBS_REC}/${URL_SUB_ORDNO}/${params.ordNo}/${patObsRecNotIsDel}/${patObsRecIsNewest}`
  );
}
/**
 * 観察記録情報取得
 * @param {*} params 患者ID、主キー
 */
export function sendRequestGetObserveRecord(params) {
  return getWithLoader(
    `${URL_BASE_PAT_OBS_REC}/${params.patId}/${params.obsRecNo}`
  );
}
/**
 * 観察記録情報取得
 * @param {*} location 読込先
 */
export function sendRequestGetObserveRecordEx(location) {
  return getWithLoader(location);
}

/**
 * 観察記録データの新規登録
 * @param {*} params 登録データ
 */
export function sendRequestPostObserveRecord(params) {
  return postWithLoader(`${URL_BASE_PAT_OBS_REC}/renew`, params);
}

/**
 * 観察記録データの更新登録
 * @param {*} obsRecNo 主キー
 * @param {*} params 登録データ
 */
export function sendRequestPutObserveRecord(obsRecNo, params) {
  return putWithLoader(`${URL_BASE_PAT_OBS_REC}/${obsRecNo}`, params);
}

/**
 * 観察記録マスタ情報取得
 * @param {*} facilityCd 施設コード
 */
export function sendRequestGetObserveRecordMasterAll(facilityCd) {
  return getWithLoader(`${URL_BASE_PAT_OBS_REC}/mst/kind-all/${facilityCd}`);
}

/**
 * 観察記録マスタ情報取得
 * @param {string|number} kindNo 観察記録種別コード
 */
export function sendRequestGetObserveRecordMaster(kindNo) {
  return getWithLoader(`${URL_BASE_PAT_OBS_REC}/mst/kind/${kindNo}`);
}


/**
 * 共通ローダを実行するGETリクエスト
 * @param {string} url URL
 * @param {Record<string, unknown>} [params] パラメータ
 */
function getWithLoader(url, params = undefined) {
  store.dispatch("loading-screen/setLoadingScreenMessage", "処理中・・・");
  store.dispatch("loading-screen/setLoadingScreenVisible", true);
  return ApiHelper.get(url, params).finally(() =>
    store.dispatch("loading-screen/setLoadingScreenVisible", false)
  );
}

/**
 * 共通ローダを実行するPUTリクエスト
 * @param {string} url URL
 * @param {unknown} params パラメータ
 */
function putWithLoader(url, params) {
  store.dispatch("loading-screen/setLoadingScreenMessage", "処理中・・・");
  store.dispatch("loading-screen/setLoadingScreenVisible", true);
  return ApiHelper.put(url, params).finally(() =>
    store.dispatch("loading-screen/setLoadingScreenVisible", false)
  );
}

/**
 * 共通ローダを実行するPOSTリクエスト
 * @param {string} url URL
 * @param {unknown} params パラメータ
 */
function postWithLoader(url, params) {
  store.dispatch("loading-screen/setLoadingScreenMessage", "処理中・・・");
  store.dispatch("loading-screen/setLoadingScreenVisible", true);
  return ApiHelper.post(url, params).finally(() =>
    store.dispatch("loading-screen/setLoadingScreenVisible", false)
  );
}
