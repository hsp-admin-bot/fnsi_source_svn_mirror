/**
 * 体重計設定系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";
import dayjs from "@/compat/date/dayjs";

const URL_BASE_WEIGHT_SETTING = "/weight_setting";
const URL_BASE_MST_WEIGHT_SCALE = "scale";
const URL_BASE_MST_WEIGHT = "weight";

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
 * 体重測定マスタ情報取得
 * @param {{ facilityCd: string }} params 施設コード
 */
export function sendRequestGetMstWeightScale(params) {
  return ApiHelper.get(
    `${URL_BASE_WEIGHT_SETTING}/${URL_BASE_MST_WEIGHT_SCALE}/get/${params.facilityCd}`
  );
}

/**
 * 体重測定マスタメンテナンス用データ取得
 */
export function sendRequestGetMstWeightScaleEdit() {
  return ApiHelper.get(
    `${URL_BASE_WEIGHT_SETTING}/${URL_BASE_MST_WEIGHT_SCALE}/get-edit-data`
  );
}

// add マスタ一覧 1･施設切替を可能とする 孔 start
/**
 * @param {{ facilityCd: string }} params 施設コード
 */
export function sendRequestGetMstWeightScaleEditByFacilityCd(params) {
  return ApiHelper.get(
    `${URL_BASE_WEIGHT_SETTING}/${URL_BASE_MST_WEIGHT_SCALE}/get-edit-data/${params.facilityCd}`,
    withSelectedPatId(undefined, params.selectedPatId)
  );
}
// add マスタ一覧 1･施設切替を可能とする 孔 end

/**
 * 体重測定マスタメンテナンス用データ保存
 * @param {Record<string, unknown>[]} request 行データ
 */
export function sendRequestPutMstWeightScaleEdit(request) {
  request.forEach(e => dateToString(e));
  const params = JSON.parse(JSON.stringify(request));
  params.filter(p => "edited" in p).forEach(p => delete p.edited);
  return ApiHelper.put(
    `${URL_BASE_WEIGHT_SETTING}/${URL_BASE_MST_WEIGHT_SCALE}/put-edit-data`,
    { data: params }
  );
}

// add マスタ一覧 1･施設切替を可能とする 孔 start
/**
 * @param {Record<string, unknown>[]} request 行データ
 * @param {string} facilityCd 施設コード
 */
export function sendRequestPutMstWeightScaleEditByFacilityCd(request, facilityCd) {
  request.forEach(e => dateToString(e));
  const params = JSON.parse(JSON.stringify(request));
  params.filter(p => "edited" in p).forEach(p => delete p.edited);
  return ApiHelper.put(
    `${URL_BASE_WEIGHT_SETTING}/${URL_BASE_MST_WEIGHT_SCALE}/put-edit-data/${facilityCd}`,
    { data: params }
  );
}
// add マスタ一覧 1･施設切替を可能とする 孔 end

/**
 * @param {Record<string, unknown>} o オブジェクト
 */
function dateToString(o) {
  const toString = Object.prototype.toString;
  Object.keys(o)
    .filter(key => toString.call(o[key]).slice(8, -1) === "Date")
    .forEach(
      key => (o[key] = dayjs(o[key]).format("YYYY-MM-DDTHH:mm:ss.SSS"))
    );
}

/**
 * 体重計マスタ情報取得
 * @param {{ facilityCd: string }} params 施設コード
 */
export function sendRequestFindMstWeightList(params) {
  return ApiHelper.get(
    `${URL_BASE_WEIGHT_SETTING}/${URL_BASE_MST_WEIGHT}/find/${params.facilityCd}`
  );
}

/**
 * 体重計マスタ情報取得（番号指定）
 * @param {{ facilityCd: string; weightNo: number|string }} params
 */
export function sendRequestGetMstWeightByNo(params) {
  return ApiHelper.get(
    `${URL_BASE_WEIGHT_SETTING}/${URL_BASE_MST_WEIGHT}/get2/${params.facilityCd}/${params.weightNo}`
  );
}

/**
 * 検査マスタ情報取得
 */
export function sendRequestGetMstExamItem() {
  return ApiHelper.get(`${URL_BASE_WEIGHT_SETTING}/exam/find`);
}

// add マスタ一覧 1･施設切替を可能とする 孔s start
/**
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetMstExamItemByFacilityCd(facilityCd) {
  return ApiHelper.get(`${URL_BASE_WEIGHT_SETTING}/exam/find/${facilityCd}`);
}
// add マスタ一覧 1･施設切替を可能とする 孔s end

// #11987 2025.12.15 add スケールベッド対応 ベッドマスタ情報取得 TDC渡辺 start
export function sendRequestGetMstBedByFacilityCd(facilityCd) {
  return ApiHelper.get(`${URL_BASE_WEIGHT_SETTING}/bed/find/${facilityCd}`);
}
// #11987 2025.12.15 add スケールベッド対応 ベッドマスタ情報取得 TDC渡辺 end

// #11987 2026.05.08 add 体重計マスタの変更をアプリに通知 TDC片口 start
export function sendRequestMstChangedNotify(facilityCd, weightNoList) {
  return ApiHelper.post(`${URL_BASE_WEIGHT_SETTING}/notify-change/${facilityCd}`, {
    weightNoList: weightNoList
  });
}
// #11987 2026.05.08 add 体重計マスタの変更をアプリに通知 TDC片口 end

/**
 * 体重計マスタの内容を状態テーブルに反映させる
 */
export function sendRequestPostMstMntSynchro() {
  return ApiHelper.post("/weight_state/sync-master");
}

// add マスタ一覧 1･施設切替を可能とする 孔s start
/**
 * @param {string} facilityCd 施設コード
 */
export function sendRequestPostMstMntSynchroByFacilityCd(facilityCd) {
  return ApiHelper.post(`/weight_state/sync-master/${facilityCd}`);
}
// add マスタ一覧 1･施設切替を可能とする 孔s end
