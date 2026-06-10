/**
 * 治療状況リスト系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

/**
 * 一時的ストア
 */
import store from "@/stores";

/**
 * トレンドグラフ用URL
 */
const URL_BASE_TREND_GRAPH = "/trend_graph";

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
 * トレンドグラフ：グラフテンプレート,モニタ項目の取得
 * @param {string} model 機種コード
 * @param {string} comFormatCd 通信フォーマット
 */
// mod FNSI-改修内容5702修正 xuty start
//export function sendRequestGetTrendGraphMaster(model) {
//  return getWithLoader(`${URL_BASE_TREND_GRAPH}/collect_master/${model}`);
export function sendRequestGetTrendGraphMaster(model, comFormatCd) {
  // add FNSI redmine 5702再修正 劉祥霖 start
  if(comFormatCd==""){
    comFormatCd="NN";
  }
  // add FNSI redmine 5702再修正 劉祥霖 end
  return getWithLoader(`${URL_BASE_TREND_GRAPH}/collect_master/${model}/${comFormatCd}`);
// mod FNSI-改修内容5702修正 xuty end
}

/**
 * トレンドグラフ情報取得
 * @param {Object} params
 * @param {String} params.typeCd 装置型式
 * @param {String} params.serial 製造番号
 * @param {String} param.model 装置種別
 * @param {String} param.startDate 開始日付
 * @param {String} param.endDate 終了日付
 */
export function sendRequestGetTrendGraphList(params) {
  return getWithLoader(
    `${URL_BASE_TREND_GRAPH}/collect_info/${params.typeCd}/${params.serial}/${params.model}/${
      params.startDate}/${params.endDate}/`
  );
}
