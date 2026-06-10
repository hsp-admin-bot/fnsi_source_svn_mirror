/**
 * 治療情報(ord_main)系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";
import store from "@/stores";

//mod FNSI-修正 redmine4683 房 start
/**
 * 指示：指示コメント更新.
 * @param {*} sendJson 更新条件
 */
export function sendUpdateIndComment(sendJson) {
  return postWithLoader("/mainData/updateIndComment/", sendJson);
}
//mod FNSI-修正 redmine4683 房 end

export function getOrdNoList(pat_id, page , per_page ) {
  return ApiHelper.get("/mainData/getOrdNoList/", {pat_id, page , per_page});
}

// add FNSI-修正 共有設定 start
export function getOrdNoListWithShared(pat_id, page, per_page, shared_flag) {
  store.dispatch("loading-screen/startLoadingScreen");
  return ApiHelper.get("/mainData/getOrdNoListWithShared/", {pat_id, page, per_page, shared_flag}).finally(() => {
    store.dispatch("loading-screen/finishLoadingScreen");
  });
}
// add FNSI-修正 共有設定 end

/**
 * 治療情報データを取得
 * @param ordNo 透析番号
 */
export function sendRequestGetOrdMainByOrdNo(ordNo) {
  store.dispatch("loading-screen/startLoadingScreen");
  return ApiHelper.get(`/mainData/getOrdMainByOrdNo/${ordNo}`).finally(() => {
    store.dispatch("loading-screen/finishLoadingScreen");
  });
}

//add FNSI-修正 redmine4683 房 start
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
//add FNSI-修正 redmine4683 房 end
