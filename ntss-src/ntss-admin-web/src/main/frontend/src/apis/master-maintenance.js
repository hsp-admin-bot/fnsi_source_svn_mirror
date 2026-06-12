/**
 * マスタメンテナンス系API
 */
import dayjs from "@/compat/date/dayjs";
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
 * @param {string} masterName マスタ物理名
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
 * @param {string} masterName マスタ物理名
 * @param {string} facilityCd 施設コード
 */
export function sendRequestFindRecordListByFacilityCd(masterName, facilityCd, selectedPatId) {
  // mod 5515 標準医薬品マスタ検索で検索できない 周安寧 start
  // return ApiHelper.get(`/master_maintenance/${masterName}/data/${facilityCd}`);
  const params = selectedPatId === null || selectedPatId === undefined || selectedPatId === ""
    ? undefined
    : { selectedPatId };
  return getWithLoader(`/master_maintenance/${masterName}/data/${facilityCd}`, params);
  // mod 5515 標準医薬品マスタ検索で検索できない 周安寧 end
}

// #11205 -ペンテスト2－4認可制御の不備  mst_holiday日機装標準は専用GET（パスにnkknkkを載せない）  add 20260507 start
/**
 * 休日マスタ（日機装標準施設）。施設コードはAPI側で固定.
 */
export function sendRequestFindMstHolidayNikkisoCorporateData() {
  return getWithLoader(`/master_maintenance/mst_holiday/data/nikkiso-corporate`);
}
// #11205 -ペンテスト2－4認可制御の不備  add 20260507 end
// add 5515 標準医薬品マスタ検索で検索できない 周安寧 start
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
// add 5515 標準医薬品マスタ検索で検索できない 周安寧 end
/**
 * データ一覧取得(SQL指定).
 * @param {string} masterName マスタ物理名
 * @param {string} facilityCd 施設コード
 */
export function sendRequestFindRecordListByFacilityCdWithSql(masterName, facilityCd) {
  return ApiHelper.get(`/master_maintenance/${masterName}/data/sql/${facilityCd}`);
}

/**
 * カラム定義情報取得.
 * @param {string} masterName マスタ物理名
 */
export function sendRequestFindColumnInfo(masterName) {
  return ApiHelper.get(`/master_maintenance/${masterName}/column_info`);
}

/**
 * データ一覧更新.
 * @param {string} masterName マスタ物理名
 * @param {Record<string, unknown>[]} request リクエストデータ
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
 * @param {string} masterName マスタ物理名
 * @param {string} facilityCd 施設コード
 * @param {Record<string, unknown>[]} request リクエストデータ
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
// add 治療方法マスタ 4・条件項目の対象を変更した場合の条件送信未実施治療予定および自動延長用パターンデータへの不足jsonキーの配布 孔s start
/**
 * ord_main, pat_treatment_pattern 更新
 * @param {string} facilityCd 施設コード
 * @param {Record<string, unknown>[]} request リクエストデータ
 */
export function sendRequestUpdateIndCondInfoByTreatmentCd(facilityCd, request) {
  request.forEach(e => dateToString(e));
  let params = JSON.parse(JSON.stringify(request));
  params = params.filter(
    r => (r.operation === 1 && r.edited) || r.operation === 2
  );
  params.filter(p => "edited" in p).forEach(p => delete p.edited);
  return ApiHelper.put(`/mst_treatment/updateTreatment/${facilityCd}`, params);
}
// add 治療方法マスタ 4・条件項目の対象を変更した場合の条件送信未実施治療予定および自動延長用パターンデータへの不足jsonキーの配布 孔s end


/** @deprecated 旧名のタイポ互換。{@link sendRequestUpdateIndCondInfoByTreatmentCd} を使用 */
export const sendequestUpdateIndCondInfoByTreatmentCd = sendRequestUpdateIndCondInfoByTreatmentCd;
