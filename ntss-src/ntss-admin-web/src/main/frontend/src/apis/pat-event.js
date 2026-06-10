/**
 * 患者イベント系API
 */
import {ApiHelper} from "@/apis/AxiosHelper";
import store from "@/stores";

/**
 * 患者イベント用URL
 */
const URL_BASE_PAT_EVENT = "/pat_event";


/**
 * sys_data_set項目の取得
 */
export function sendRequestGetSysDataSetList() {
  return getWithLoader(`${URL_BASE_PAT_EVENT}/dataset-list`);
}

/**
 * sys_data_set項目の取得
 */
export function sendRequestGetSysDataSetText() {
  return getWithLoader(`${URL_BASE_PAT_EVENT}/dataset-text`);
}

/**
 * sys_data_Setの結果を取得
 * @param {Object} params
 */
export function sendRequestGetSysDataSetResult(params){
  return getWithLoader(`${URL_BASE_PAT_EVENT}/dataset-result`, params);
}
// add マスタ一覧 1･施設切替を可能とする 孔s start
export function sendRequestGetSysDataSetResultByFacilityCd(params, facilityCd){
  return getWithLoader(`${URL_BASE_PAT_EVENT}/dataset-result/${facilityCd}`, params);
}
// add マスタ一覧 1･施設切替を可能とする 孔s end

// add 10409 曜日パターン変更の患者イベント修正 関  start
export function sendRequestGetLinkageMessageConfirm(params){
  return getWithLoader(`${URL_BASE_PAT_EVENT}/linkageMessageConfirm`, params);
}
// add 10409 曜日パターン変更の患者イベント修正 関  end
/**
 * 添付ファイルのアップロード
 * @param {*} params
 */
export function sendRequestPostUpload(params, file) {
  return postWithLoader(`${URL_BASE_PAT_EVENT}/files/${params.facilityCd}&${params.patId}&${params.eventDate}&${params.patEventCd}&${params.fieldName}`, file);
}
/**
 * 画像ファイルのアップロード
 * @param {*} params
 */
export function sendRequestPostImageUpload(params, file) {
  return postWithLoader(`${URL_BASE_PAT_EVENT}/images/${params.facilityCd}&${params.patId}&${params.eventDate}&${params.patEventCd}&${params.fieldName}&${params.imageNo}`, file);
}

/**
 * 添付ファイルのダウンロード
 * @param {*} params
 */
export function sendRequestGetDownload(filepath) {
  return getWithLoader(`${URL_BASE_PAT_EVENT}/files`, { filepath });
}

/**
 * 添付ファイルのダウンロード
 * @param {*} params
 */
export function sendRequestGetImageDownload(filepath) {
  return getWithLoader(`${URL_BASE_PAT_EVENT}/images`, { filepath });
}

/**
 * 添付ファイルの削除
 * @param {*} params
 */
export function sendRequestPostDelete(params) {
  const removedFiles = params.removedFiles;
  return postWithLoader(`${URL_BASE_PAT_EVENT}/deleteEventFileAttachment/${params.patId}`,
    removedFiles);
}

/**
 * 画像ファイルの削除
 * @param {*} params
 */
export function sendRequestPostImageDelete(params) {
  const removedFiles = params.removedFiles;
  return postWithLoader(`${URL_BASE_PAT_EVENT}/deleteEventImageAttachment/${params.patId}`,
    removedFiles);
}

/**
 * カテゴリ項目の取得
 */
export function sendRequestGetMstCategoryList() {
  return getWithLoader(`${URL_BASE_PAT_EVENT}/mst-category-list`);
}

/**
 * 患者イベント：テンプレート,カテゴリ，サブカテゴリ項目の取得
 * @param {string} facilityCd 施設コード指定
 */
export function sendRequestGetPatEventMaster(facilityCd = "") {
  return getWithLoader(`${URL_BASE_PAT_EVENT}/collect-master`,{facilityCd:facilityCd});
}

/**
 * 患者イベント情報取得
 * @param {*} params 患者ID、開始日、終了日
 */
export function sendRequestGetPatEventRecordList(params) {
  const getParams = {};
  if (params.patEventCd != null) {
    getParams.patEventCd = params.patEventCd;
  }
  getParams.patShareMode = params.patShareMode;
  getParams.otherFacilityCd = params.otherFacilityCd;
  return getWithLoader(
    `${URL_BASE_PAT_EVENT}/${params.patId}/${params.startDate}/${params.endDate}`,
    getParams
  );
}

/**
 * 開示元の施設と開示先施設両方のエベント情報を取得する
 * @param {*} params 患者ID、開始日、終了日
 */
export function sendRequestGetPatEventRecordListSharing(params) {
  return getWithLoader(
    `${URL_BASE_PAT_EVENT}/sharingInfo/${params.patId}/${params.startDate}/${
    params.endDate}`
  );
}

/**
 * 患者イベント情報取得
 * @param {*} params イベントコード
 */
export function sendRequestGetPatEventRecord(params) {
  return getWithLoader(
    `${URL_BASE_PAT_EVENT}/${params.patEventCd}`
  );
}

/**
 * 開示元の施設と開示先施設両方の患者エベント情報を取得する
 * @param {*} params イベントコード
 */
export function sendRequestGetPatEventRecordSharing(params) {
  return getWithLoader(
    `${URL_BASE_PAT_EVENT}/sharingInfo/${params.patId}/${params.patEventCd}`
  );
}

/**
 * 患者イベント情報取得
 * @param {*} params オーダ番号
 */
export function sendRequestGetPatEventRecordByOrdNo(params) {
  const URL_SUB_ORDNO = "ordno";
  return getWithLoader(
    `${URL_BASE_PAT_EVENT}/${URL_SUB_ORDNO}/${params.ordNo}`,
    { facilityCd: params.facilityCd }
  );
}

/**
 * 患者イベント新規登録
 * @param {*} params
 */
export function sendRequestPostPatEventRecord(params) {
  return postWithLoader(
    `${URL_BASE_PAT_EVENT}/create/`, params
  );
}

/**
 * 患者イベント修正登録
 * @param {*} params
 */
export function sendRequestPutPatEventRecord(params) {
  return putWithLoader(
    `${URL_BASE_PAT_EVENT}/update`, params
  );
}

/**
 * 患者イベント修正登録
 * @param {*} params
 */
export function sendRequestPutPatEventResultParams(params) {
  return putWithLoader(
    `${URL_BASE_PAT_EVENT}/updateResultParams`, params
  );
}

/**
 * 患者イベント修正登録
 * @param {*} params
 */
export function sendRequestPutPatEventBbsCtlNo(params) {
  return putWithLoader(
    `${URL_BASE_PAT_EVENT}/updateBbsCtlNo`, params
  );
}

/**
 * 患者イベント削除登録
 * @param {*} params
 */
export function sendRequestPostPatEventRecordDelete(params) {
  return postWithLoader(
    `${URL_BASE_PAT_EVENT}/delete/${params.patId}/${params.patEventCd}`
  );
}

/**
 * 治療情報の取得
 * @param {*} params  患者ID、治療日、オーダ番号
 */
export function sendRequestGetOrdMainRecordList(params) {
  const URL_SUB_ORD_MAIN = "ord_main_combo";
  return getWithLoader(
    `${URL_BASE_PAT_EVENT}/${URL_SUB_ORD_MAIN}/${params.patId}/${params.treatStartDate}/${params.treatEndDate}/${params.patEventCd}/${params.getClass}`
  );
}
/**
 * 治療情報の取得
 * @param {*} params  患者ID、オーダ番号
 */
export function sendRequestGetOrdMainRecord(params) {
  return getWithLoader(
    `${URL_BASE_PAT_EVENT}/ord_main/${params.patId}/${params.ordNo}`
  );
}

/**
 * シェーマ用のスタンプ文字リスト取得
 */
export function sendRequestGetTextStampCollection() {
  return getWithLoader(
    `${URL_BASE_PAT_EVENT}/text-stamp/collection`
  );
}

/**
 * 共通ローダを実行するGETリクエスト
 * @param {String} url URL
 * @param {any} params パラメータ
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
 * @param {String} url URL
 * @param {any} params パラメータ
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
 * @param {String} url URL
 * @param {any} params パラメータ
 */
function postWithLoader(url, params) {
  store.dispatch("loading-screen/setLoadingScreenMessage", "処理中・・・");
  store.dispatch("loading-screen/setLoadingScreenVisible", true);
  return ApiHelper.post(url, params).finally(() =>
    store.dispatch("loading-screen/setLoadingScreenVisible", false)
  );
}

/**
 * 患者イベント情報取得(観察記録)
 * @param {*} params イベントコード
 */
 export function sendRequestGetPatEventObserveRecord(params) {
  return getWithLoader(
    `${URL_BASE_PAT_EVENT}/getObserveRecordByCd/${params.patEventCd}`
  );
}

/**
 * 患者イベント情報取得(紹介状)
 * @param {*} patEventCd イベントコード
 */
 export function sendRequestGetPatIntroLetter(patEventCd) {
  return getWithLoader(
    `${URL_BASE_PAT_EVENT}/getPatIntroLetterByCd/${patEventCd}`
  );
}

/**
 * 観察記録リスト取得 ※offset指定あり
 * @param {*} params URLパス => 患者ID、開始日、終了日
 *                   クエリパラメータ => カテゴリコード、サブカテゴリコード、起票者コード、編集者コード、offset
 */
export function sendRequestGetPatEventObserveRecordsByCondition(params) {
  const getParams = {};
  if (params.categoryCd != null) {
    getParams.categoryCd = params.categoryCd;
  }
  if (params.subCategoryCd != null) {
    getParams.subCategoryCd = params.subCategoryCd;
  }
  if (params.regStaffCd != null) {
    getParams.regStaffCd = params.regStaffCd;
  }
  if (params.upStaffCd != null) {
    getParams.upStaffCd = params.upStaffCd;
  }
  // スクロールした際の追加読込用
  if (params.offset != null) {
    getParams.offset = params.offset;
  }
  // add #12462 患者情報共有 20260330 start
  if (params.patShareMode != null) {
    getParams.patShareMode = params.patShareMode;
  }
  if (params.otherFacilityCd != null) {
    getParams.otherFacilityCd = params.otherFacilityCd;
  }
  // add #12462 患者情報共有 20260330 end
  return getWithLoader(
    `${URL_BASE_PAT_EVENT}/getObserveRecords/${params.patId}/${params.startDate}/${params.endDate}`,
    getParams
  );
}