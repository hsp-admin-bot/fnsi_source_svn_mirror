/**
 * 治療状況リスト系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";
import store from "@/stores";

/**
 * 治療状況リスト用URL
 */
const URL_MST = "/mstInfo";
const URL_BASE_STATUS_LIST = "/status_list";
const URL_BASE_STATUS_LIST_LARGE = "/status_list_large";

/**
 * クール情報を取得
 * /mstInfo/mstKur
 */
export function sendRequestGetKur(facilityCd, selectedPatId) {
  const params = {
    facility_cd: facilityCd,
    is_del: "0"
  };
  if (selectedPatId !== null && selectedPatId !== undefined && selectedPatId !== "") {
    params.selectedPatId = selectedPatId;
  }
  return getWithLoader(`${URL_MST}/mstKur`, params);
}

/**
 * 治療状況レイアウト表示項目マスタを取得
 * /mstInfo/mstTreatmentStatusDispItem
 */
export function sendRequestGetMstTreatmentStatusDispItem() {
  return getWithLoader(`${URL_MST}/mstTreatmentStatusDispItem`);
}

/**
 * ベッド+装置情報を取得
 * /mstInfo/mstKur
 */
export function sendRequestGetBedMachine() {
  return getWithLoader(`${URL_BASE_STATUS_LIST}/bed_machine`);
}

/**
 * 装置マスタ取得.
 * @param {string|number} ordNo オーダ番号
 */
export function sendRequestGetMstMachineByOrdNoRst(ordNo) {
  return ApiHelper.get(`/treatment-record/${ordNo}/mst-machine-rst`);
}

/**
 * 治療状況レイアウトマスタの取得
 * @param {string} [facilityCd] 施設コード指定
 */
export function sendRequestGetStatusLayout(facilityCd = "") {
  return getWithLoader(`${URL_BASE_STATUS_LIST}/layout`, { facilityCd });
}

// mod 画面リロードの修正 付 start
/**
 * 装置状態管理リストを取得
 */
export function sendRequestGetMntMachineState(facilityCd) {
  // mod bug 8514 修正 chen start
  // return ApiHelper.get(`${URL_BASE_STATUS_LIST}/machine_state/${facilityCd}`);
  return ApiHelper.get(`${URL_BASE_STATUS_LIST}/machine_state/${facilityCd}?__background_call__=true`);
  // mod bug 8514 修正 chen end
}
// mod 画面リロードの修正 付 end

// mod FNSI-実績確定修正 徐 start
/**
 * リスト表示用データリストの取得
 * @param {Record<string, unknown>} params 施設コード、治療日付、レイアウトマスタの番号
 * @param {number} createColumnCount 列作成数
 */
export function sendRequestGetTreatmentStatusList(params, createColumnCount) {
  /* mod #8872 by zhangruixue 2023-06-21 --start */
  /* modify by chamaojia 2024-03-27 [10303、10304] add interface input parameters 【isShowMain】、【nextPat】 --start */
  const baseUrl = `${URL_BASE_STATUS_LIST}/treatment_status_list/${params.facilityCd}/${params.treatDate}/${params.layoutNo}/${params.bedGroupCd}/${params.kurCdS}/${params.isShowMain}/${params.nextPat}`;
  if (createColumnCount === 0) {
    // mod bug 8514 修正 chen start
    // return ApiHelper.get(
    //   `${URL_BASE_STATUS_LIST}/treatment_status_list/${params.facilityCd}/${params.treatDate}/${params.layoutNo}`
    // );
    // 自動更新サインアウトON/OFFチェック
    const forceSignOutFlag = store.getters["status-list/list/getForceSignOutFlag"];
    const queryParams = forceSignOutFlag == 0 ? "?__background_call__=true" : "";
    return ApiHelper.get(`${baseUrl}${queryParams}`);
    // mod bug 8514 修正 chen end
  }
  return getWithLoader(`${baseUrl}`);
  /* modify by chamaojia 2024-03-27 [10303、10304] add interface input parameters 【isShowMain】、【nextPat】 --end */
  /* mod #8872 by zhangruixue 2023-06-21 --end */
}
// mod FNSI-実績確定修正 徐 end

/**
 * 警報・注意一覧情報取得
 * @param {Record<string, unknown>} params 施設コード、治療日付、自動更新フラグ
 */
export async function sendRequestGetAlarmList(params) {
  const url = `${URL_BASE_STATUS_LIST}/alarm_record/${params.facilityCd}/${params.occurDate}`;
  if (params.autoRefreshFlag) {
    return ApiHelper.get(`${url}?__background_call__=true`);
  }
  return getWithLoader(`${url}`);
}

/*
 * 投薬情報の取得
 * 後体重測定後の確認前の投薬未実施チェック
 * @param {unknown} params 確認対象のオーダー番号配列
 */
export function sendRequestCheckMediDone(params) {
  return getWithLoader(`${URL_BASE_STATUS_LIST}/check_medi_done/${params}`);
}

// mod FNSI-実績確定修正 徐 start
/**
 * 後体重測定後の確認時のデータ更新
 * @param {unknown} params 確認対象のオーダー番号配列
 */
export function sendRequestUpdateCheckAfterWeight(params) {
  return ApiHelper.put(`${URL_BASE_STATUS_LIST}/check_after_weight`, params);
}
// mod FNSI-実績確定修正 徐 end

// add FNSI-画面で外部連携APIを呼び出すさい-538 付 start
/**
 * facilityCdより全患者の習得
 * @param {string} params facilityCd
 */
export function getPatPersonMainData(params) {
  return ApiHelper.get(`/pat_group/pat_facility_cd`, {
    facility_cd: params
  });
}
// add FNSI-画面で外部連携APIを呼び出すさい-538 付 end

/**
 * 大画面表示データリストの取得
 * @param {Record<string, unknown>} params 治療日付、自動更新フラグ
 */
export function sendRequestGetEntryList(params) {
  const url = `${URL_BASE_STATUS_LIST_LARGE}/info/${params.treatDate}`;
  if (params.autoRefreshFlag) {
    // 自動更新サインアウトON/OFFチェック
    const forceSignOutFlag = store.getters["status-list/large-display/getForceSignOutFlag"];
    const queryParams = forceSignOutFlag == 0 ? "?__background_call__=true" : "";
    return ApiHelper.get(`${url}${queryParams}`);
  }
  return ApiHelper.get(url);
}

/**
 * レイアウトマスタ装置設定の表示項目リストの取得
 */
export function sendRequestGetDispItemList() {
  return getWithLoader(`${URL_BASE_STATUS_LIST}/master/get/disp_items`);
}

/**
 * 穿刺者・返血者・担当者の利用者情報リストの取得
 */
export function sendRequestGetMstPersonalUser() {
  return getWithLoader(`${URL_BASE_STATUS_LIST}/staff`);
}

/**
 * データ一覧更新.
 * @param {unknown} request リクエストデータ
 */
export function sendRequestUpdateTreatmentStatus(request) {
  return putWithLoader(`${URL_BASE_STATUS_LIST}/treatment_status_record/data`, {
    data: request
  });
}

/**
 * ？？？？患者削除
 * @param {string|number} ordNo オーダー番号
 */
export function sendRequestDeleteUnknownPatRecord(ordNo) {
  return putWithLoader(`${URL_BASE_STATUS_LIST}/delete/unknown-record`, {
    ordNo
  });
}

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
