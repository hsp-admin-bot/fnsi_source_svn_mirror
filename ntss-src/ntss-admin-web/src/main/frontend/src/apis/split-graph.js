/**
 * P-Ca9分割グラフリスト系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

/**
 * 一時的ストア
 */
import store from "@/stores";
const uriCa9Graph = "/ca9_graph";
const uriSelectorExamItem = "/mstInfo/mst_exam_item/mstSelector";

/**
 * 経過グラフのデータを取得する。
 * @param {*} params
 * @param { String } params.patId 患者ID
 * @param { Object } params.body
 * @param { String } params.body.examItemX X軸に出力する検査項目コード
 * @param { String } params.body.examItemX Y軸に出力する検査項目コード
 * @param { String } params.body.resultExamDateFrom 検査結果開始日
 * @param { String } params.body.resultExamDateTo 検査結果終了日
 * @param { String } params.body.facilityCd 施設コード
 */
export function sendRequestGetProgressGraph(params) {
  const patId = params.patId;
  const body = params.body;
  return postWithLoader(`${uriCa9Graph}/progressGraph/${patId}`, body);
}
/**
 * 分布グラフのデータを取得する。
 * @param { String } examItemX X軸に出力する検査項目コード
 * @param { String } examItemX Y軸に出力する検査項目コード
 * @param { String } resultExamDateFrom 検査結果開始日
 * @param { String } resultExamDateTo 検査結果終了日
 * @param { String } facilityCd 施設コード
 * @param { String } patList 患者IDリスト
 */
export function sendRequestGetDistributionGraph(params) {
  return postWithLoader(`${uriCa9Graph}/distributionGraph`, params);
}
/**
 * 指定された施設コードに一致するグラフ設定データを取得する。
 * @param { String } facilityCd 施設コード
 */
export function getGraphSettings(facilityCd) {
  return getWithLoader(`${uriCa9Graph}/setting/${facilityCd}`);
}

/**
 * 指定された施設コードに一致する検査項目マスターを取得する。
 * @param {*} facilityCd 施設コード
 */
export function sendRequestGetMstExamItem(facilityCd) {
  return getWithLoader(uriSelectorExamItem, { facilityCd: facilityCd });
}
/**
 * 患者グループを更新する。
 * @param {*} params
 * @param { String } params.facilityCd 施設コード
 * @param { Array } params.body
 */
export function sendRequestUpdatePatientGroup(params) {
  const facilityCd = params.facilityCd;
  const body = params.body;
  return putWithLoader(`${uriCa9Graph}/update/patGroup/${facilityCd}`, body);
}
// add bug 7940 修正 chen start
export function sendRequestUpdatePatientGroupByGroup(params) {
  const facilityCd = params.facilityCd;
  const body = params.body;
  const groupIdList = params.groupIdList;
  return putWithLoader(`${uriCa9Graph}/update/patGroup/${facilityCd}/${groupIdList}`, body);
}
// add bug 7940 修正 chen end
/**
 * 共通ローダを実行するGETリクエスト
 * @param { String } url URL
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
 * 共通ローダを実行するPOSTリクエスト
 * @param { String } url URL
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
 * 共通ローダを実行するPUTリクエスト
 * @param { String } url URL
 * @param {any} params パラメータ
 */
function putWithLoader(url, params) {
  store.dispatch("loading-screen/setLoadingScreenMessage", "処理中・・・");
  store.dispatch("loading-screen/setLoadingScreenVisible", true);
  return ApiHelper.put(url, params).finally(() =>
    store.dispatch("loading-screen/setLoadingScreenVisible", false)
  );
}
