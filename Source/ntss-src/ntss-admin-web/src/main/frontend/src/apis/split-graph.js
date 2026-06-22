/**
 * P-Ca9分割グラフリスト系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";
import store from "@/stores";

const URI_CA9_GRAPH = "/ca9_graph";
const URI_SELECTOR_EXAM_ITEM = "/mstInfo/mst_exam_item/mstSelector";

function selectedPatIdParams(selectedPatId) {
  return selectedPatId === null || selectedPatId === undefined || selectedPatId === ""
    ? undefined
    : { selectedPatId };
}

/**
 * 経過グラフのデータを取得する。
 * @param {Record<string, unknown>} params リクエスト
 * @param {string} params.patId 患者ID
 * @param {Record<string, unknown>} params.body ボディ
 * @param {string} params.body.examItemX X軸に出力する検査項目コード
 * @param {string} params.body.examItemY Y軸に出力する検査項目コード
 * @param {string} params.body.resultExamDateFrom 検査結果開始日
 * @param {string} params.body.resultExamDateTo 検査結果終了日
 * @param {string} params.body.facilityCd 施設コード
 */
export function sendRequestGetProgressGraph(params) {
  const patId = params.patId;
  const body = params.body;
  return postWithLoader(`${URI_CA9_GRAPH}/progressGraph/${patId}`, body);
}

/**
 * 分布グラフのデータを取得する。
 * @param {Record<string, unknown>} params 検索条件（examItemX, examItemY, resultExamDateFrom など）
 */
export function sendRequestGetDistributionGraph(params, selectedPatId) {
  return postWithLoader(`${URI_CA9_GRAPH}/distributionGraph`, params, selectedPatId);
}

/**
 * 指定された施設コードに一致するグラフ設定データを取得する。
 * @param {string} facilityCd 施設コード
 */
export function getGraphSettings(facilityCd, selectedPatId) {
  return getWithLoader(`${URI_CA9_GRAPH}/setting/${facilityCd}`, selectedPatIdParams(selectedPatId));
}

/**
 * 指定された施設コードに一致する検査項目マスターを取得する。
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetMstExamItem(facilityCd) {
  return getWithLoader(URI_SELECTOR_EXAM_ITEM, { facilityCd });
}

/**
 * 患者グループを更新する。
 * @param {Record<string, unknown>} params facilityCd, body
 * @param {string} params.facilityCd 施設コード
 * @param {unknown[]} params.body 更新ボディ
 */
export function sendRequestUpdatePatientGroup(params) {
  const facilityCd = params.facilityCd;
  const body = params.body;
  return putWithLoader(`${URI_CA9_GRAPH}/update/patGroup/${facilityCd}`, body);
}

// add bug 7940 修正 chen start
/**
 * 患者グループを更新（グループID指定）
 * @param {Record<string, unknown>} params facilityCd, body, groupIdList
 */
export function sendRequestUpdatePatientGroupByGroup(params) {
  const facilityCd = params.facilityCd;
  const body = params.body;
  const groupIdList = params.groupIdList;
  return putWithLoader(`${URI_CA9_GRAPH}/update/patGroup/${facilityCd}/${groupIdList}`, body);
}
// add bug 7940 修正 chen end

/**
 * 共通ローダを実行するGETリクエスト
 * @param {string} url URL
 * @param {unknown} [params] パラメータ
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
 * @param {string} url URL
 * @param {unknown} params パラメータ
 */
function postWithLoader(url, params, selectedPatId) {
  store.dispatch("loading-screen/setLoadingScreenMessage", "処理中・・・");
  store.dispatch("loading-screen/setLoadingScreenVisible", true);
  const queryParams = selectedPatIdParams(selectedPatId);
  const request = queryParams
    ? ApiHelper.configPost(url, params, { params: queryParams })
    : ApiHelper.post(url, params);
  return request.finally(() =>
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
