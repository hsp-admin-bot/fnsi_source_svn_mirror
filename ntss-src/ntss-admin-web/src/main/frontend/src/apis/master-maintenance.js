/**
 * マスタメンテナンス系API
 */
import moment from "moment";
import { ApiHelper } from "@/apis/AxiosHelper";

// add 5515 標準医薬品マスタ検索で検索できない 周安寧 start
/**
 * ストア系
 */
import store from "@/stores";
// add 5515 標準医薬品マスタ検索で検索できない 周安寧 end
/**
 * マスタ一覧取得.
 */
export function sendRequestFindMasterList() {
  return ApiHelper.get(`/master_maintenance/master_list`);
}

/**
 * データ一覧取得.
 * @param {*} masterName マスタ物理名
 */
export function sendRequestFindRecordList(masterName) {
  // 全件取得対象マスタリスト
  const masterNames = ["mst_facility", "sys_facility", "mst_device_edge", "sys_application"];
  if (masterNames.includes(masterName)) {
    // 施設/全施設/デバイスエッジマスタ/アプリケーションダウンロードは施設コードでフィルタせず全件取得
    return ApiHelper.get(`/master_maintenance/getAllMasterData/${masterName}`);
  } else {
    return ApiHelper.get(`/master_maintenance/${masterName}/data`);
  }
}

/**
 * データ一覧取得(引数指定した施設コードのデータ).
 * @param {*} masterName マスタ物理名
 * @param {*} facilityCd 施設コード
 */
export function sendRequestFindRecordListByFacilityCd(masterName, facilityCd) {
// mod 5515 標準医薬品マスタ検索で検索できない 周安寧 start
  //return ApiHelper.get(`/master_maintenance/${masterName}/data/${facilityCd}`);
  return getWithLoader(`/master_maintenance/${masterName}/data/${facilityCd}`);
// mod 5515 標準医薬品マスタ検索で検索できない 周安寧 end
}
// add 5515 標準医薬品マスタ検索で検索できない 周安寧 start
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
// add 5515 標準医薬品マスタ検索で検索できない 周安寧 end
/**
 * データ一覧取得(SQL指定).
 * @param {*} masterName マスタ物理名
 * @param {*} facilityCd 施設コード
 */
export function sendRequestFindRecordListByFacilityCdWithSql(masterName, facilityCd) {
  return ApiHelper.get(`/master_maintenance/${masterName}/data/sql/${facilityCd}`);
}

/**
 * カラム定義情報取得.
 * @param {*} masterName マスタ物理名
 */
export function sendRequestFindColumnInfo(masterName) {
  return ApiHelper.get(`/master_maintenance/${masterName}/column_info`);
}

/**
 * データ一覧更新.
 * @param {*} masterName マスタ物理名
 * @param {*} request リクエストデータ
 */
export function sendRequestUpdateRecordList(masterName, request) {
  // Date -> String 変換
  request.forEach(e => dateToString(e));
  // プロパティ"edited"除去
  const params = JSON.parse(JSON.stringify(request));
  params.filter(p => "edited" in p).forEach(p => delete p.edited);
  return ApiHelper.put(`/master_maintenance/${masterName}/data`, {
    data: params
  });
}

/**
 * データ一覧更新.
 * @param {*} masterName マスタ物理名
 * @param {*} facilityCd 施設コード
 * @param {*} request リクエストデータ
 */
export function sendRequestUpdateRecordListByFacilityCd(masterName, facilityCd, request) {
  // Date -> String 変換
  request.forEach(e => dateToString(e));
  // プロパティ"edited"除去
  const params = JSON.parse(JSON.stringify(request));
  params.filter(p => "edited" in p).forEach(p => delete p.edited);
  return ApiHelper.put(`/master_maintenance/${masterName}/data/${facilityCd}`, {
    data: params
  });
}

/**
 * 指定されたオブジェクトが持つDate型の値を文字列(YYYY-MM-DDTHH:mm:ss.SSS)に変換する.
 * リクエスト送信の際にDate型は、UTCとして文字列変換されてしまう.
 * 事前に文字列変換することで、意図しない日時に変換されることを回避する.
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
// add 治療方法マスタ 4・条件項目の対象を変更した場合の条件送信未実施治療予定および自動延長用パターンデータへの不足jsonキーの配布 孔s start
/**
 * ord_main,pat_treatment_pattern更新
 * @param {*} facilityCd 施設コード
 * @param {*} request リクエストデータ
 */
export function sendequestUpdateIndCondInfoByTreatmentCd(facilityCd, request) {
  // Date -> String 変換
  request.forEach(e => dateToString(e));
  // プロパティ"edited"除去
  let params = JSON.parse(JSON.stringify(request));
  params = params.filter(r => {return (r.operation === 1 && r.edited) || r.operation === 2})
  params.filter(p => "edited" in p).forEach(p => delete p.edited);
  return ApiHelper.put(`/mst_treatment/updateTreatment/${facilityCd}`, params);
}
// add 治療方法マスタ 4・条件項目の対象を変更した場合の条件送信未実施治療予定および自動延長用パターンデータへの不足jsonキーの配布 孔s end
