/**
 * 体重計設定系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";
import moment from "moment";

/**
 * 体重計設定用URL
 */
const URL_BASE_WEIGHT_SETTING = "/weight_setting";
const URL_BASE_MST_WEIGHT_SCALE = "scale";
const URL_BASE_MST_WEIGHT = "weight";

/**
 * 体重測定マスタ情報取得
 * @param {*} params 施設コード
 */
export function sendRequestGetMstWeightScale(params) {
  return ApiHelper.get(
    `${URL_BASE_WEIGHT_SETTING}/${URL_BASE_MST_WEIGHT_SCALE}/get/${
      params.facilityCd
    }`
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
export function sendRequestGetMstWeightScaleEditByFacilityCd(params) {
  return ApiHelper.get(
    `${URL_BASE_WEIGHT_SETTING}/${URL_BASE_MST_WEIGHT_SCALE}/get-edit-data/${
      params.facilityCd
    }`
  );
}
// add マスタ一覧 1･施設切替を可能とする 孔 end
/**
 * 体重測定マスタメンテナンス用データ保存
 */
export function sendRequestPutMstWeightScaleEdit(request) {
  // Date -> String 変換
  request.forEach(e => dateToString(e));
  // プロパティ"edited"除去
  const params = JSON.parse(JSON.stringify(request));
  params.filter(p => "edited" in p).forEach(p => delete p.edited);
  return ApiHelper.put(
    `${URL_BASE_WEIGHT_SETTING}/${URL_BASE_MST_WEIGHT_SCALE}/put-edit-data`,
    {
      data: params
    }
  );
}
// add マスタ一覧 1･施設切替を可能とする 孔 start
export function sendRequestPutMstWeightScaleEditByFacilityCd(request, facilityCd) {
  // Date -> String 変換
  request.forEach(e => dateToString(e));
  // プロパティ"edited"除去
  const params = JSON.parse(JSON.stringify(request));
  params.filter(p => "edited" in p).forEach(p => delete p.edited);
  return ApiHelper.put(
    `${URL_BASE_WEIGHT_SETTING}/${URL_BASE_MST_WEIGHT_SCALE}/put-edit-data/${facilityCd}`,
    {
      data: params
    }
  );
}
// add マスタ一覧 1･施設切替を可能とする 孔 end

/**
 * @param {*} o オブジェクト
 */
function dateToString(o) {
  const toString = Object.prototype.toString;
  Object.keys(o)
    .filter(key => toString.call(o[key]).slice(8, -1) === "Date")
    .forEach(
      key => (o[key] = moment(o[key]).format("YYYY-MM-DDTHH:mm:ss.SSS"))
    );
}

/**
 * 体重計マスタ情報取得
 * @param {*} params 施設コード
 */
export function sendRequestFindMstWeightList(params) {
  return ApiHelper.get(
    `${URL_BASE_WEIGHT_SETTING}/${URL_BASE_MST_WEIGHT}/find/${
      params.facilityCd
    }`
  );
}
/**
 * 体重計マスタ情報取得
 * @param {String} params.facilityCd 施設コード
 * @param {Number} params.weightNo 体重計番号
 */
export function sendRequestGetMstWeightByNo(params) {
  return ApiHelper.get(
    `${URL_BASE_WEIGHT_SETTING}/${URL_BASE_MST_WEIGHT}/get2/${
      params.facilityCd
    }/${params.weightNo}`
  );
}
/**
 * 検査マスタ情報取得
 */
export function sendRequestGetMstExamItem() {
  return ApiHelper.get(`${URL_BASE_WEIGHT_SETTING}/exam/find`);
}
// add マスタ一覧 1･施設切替を可能とする 孔s start
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
export function sendRequestPostMstMntSynchroByFacilityCd(facilityCd) {
  return ApiHelper.post(`/weight_state/sync-master/${facilityCd}`);
}
// add マスタ一覧 1･施設切替を可能とする 孔s end
