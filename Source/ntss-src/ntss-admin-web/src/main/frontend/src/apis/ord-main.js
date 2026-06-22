/**
 * 治療情報(ord_main)系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";
import store from "@/stores";

// mod FNSI-修正 redmine4683 房 start
/**
 * 指示：指示コメント更新.
 * @param {Record<string, unknown>} sendJson 更新条件
 */
export function sendUpdateIndComment(sendJson) {
  return postWithLoader("/mainData/updateIndComment", sendJson);
}
// mod FNSI-修正 redmine4683 房 end

/**
 * オーダー番号リスト取得
 * @param {string|number} pat_id 患者ID（API キー名に合わせる）
 * @param {number} page ページ
 * @param {number} per_page 件数
 */
export function getOrdNoList(pat_id, page, per_page) {
  return ApiHelper.get("/mainData/getOrdNoList", { pat_id, page, per_page });
}

// add FNSI-修正 共有設定 start
/**
 * オーダー番号リスト取得（共有フラグ付き）
 */
export function getOrdNoListWithShared(pat_id, page, per_page, shared_flag) {
  store.dispatch("loading-screen/startLoadingScreen");
  return ApiHelper
    .get("/mainData/getOrdNoListWithShared", {
      pat_id,
      page,
      per_page,
      shared_flag
    })
    .finally(() => {
      store.dispatch("loading-screen/finishLoadingScreen");
    });
}
// add FNSI-修正 共有設定 end

/**
 * 治療情報データを取得
 * @param {string|number} ordNo 透析番号
 */
export function sendRequestGetOrdMainByOrdNo(ordNo, selectedPatId) {
  store.dispatch("loading-screen/startLoadingScreen");
  const params = selectedPatId === null || selectedPatId === undefined || selectedPatId === ""
    ? undefined
    : { selectedPatId };
  return ApiHelper.get(`/mainData/getOrdMainByOrdNo/${ordNo}`, params).finally(() => {
    store.dispatch("loading-screen/finishLoadingScreen");
  });
}

// add FNSI-修正 redmine4683 房 start
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
// add FNSI-修正 redmine4683 房 end

/**
 * 治療日リスト取得
 * @param {Record<string, unknown>} params リクエストボディ
 * @param {string|number|null|undefined} [selectedPatId] 患者共有認可用
 */
export function sendRequestPostTreatDateList(params, selectedPatId) {
  const resolvedSelectedPatId = selectedPatId ?? params?.pat_id ?? params?.patId
    ?? store.getters["pat-info/selectedPatId"];
  const queryParams = resolvedSelectedPatId === null || resolvedSelectedPatId === undefined || resolvedSelectedPatId === ""
    ? undefined
    : { selectedPatId: resolvedSelectedPatId };
  return queryParams
    ? ApiHelper.configPost("/mainData/TreatDateList", params, { params: queryParams })
    : ApiHelper.post("/mainData/TreatDateList", params);
}
