/**
 * 治療状況マップ系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";
import store from "@/stores";

/**
 * 治療状況マップ用URL
 */
const URL_BASE_STATUS_MAP = "/status_map";
const URL_BASE_STATUS_LIST = "/status_list";
const URL_BASE_DEVICE_EDGE_ORDER = "/device_edge_order";

/**
 * クール情報を取得
 * /mstInfo/mstKur
 */
export function sendRequestGetKur(facilityCd) {
  return getWithLoader(
    `/mstInfo/mstKur`, {
      facility_cd: facilityCd,
      is_del: "0"
    }
  );
}

/* modify by chamaojia 2022-11-26 [6746] loading判定パラメータの追加要否  --start */
// mod 画面リロードの修正 付 start
/**
 * 治療状況データを取得
 * /treatment_status_next_patient/{facilityCd}/{treatDate}/{layoutNo}
 * @param {Record<string, unknown>} params 検索条件
 * @param {boolean} autoRefreshFlag 自動更新にloadingは必要ありません  true:loadingは不要
 */
export function sendRequestGetTreatmentStatusMapMachine(params, autoRefreshFlag) {
  const URL_SUB_TREATMENT_STATUS = "treatment_status_map";
  // mod bug 8514 修正 chen start
  /* mod #8872 by zhangruixue 2023-06-21 --start */
  /* modify by chamaojia 2024-03-27 [10303、10304] add interface input parameters 【nextPat】、【bedLayoutId】 --start */
  const url = `${URL_BASE_STATUS_LIST}/${URL_SUB_TREATMENT_STATUS}/${params.facilityCd}/${params.layoutNo}/${params.bedGroupCd}/${params.nextPat}/${params.bedLayoutId}`;
  if (autoRefreshFlag) {
    // 自動更新サインアウトON/OFFチェック
    const forceSignOutFlag = store.getters["status-map/map/getForceSignOutFlag"];
    const queryParams = forceSignOutFlag == 0 ? "?__background_call__=true" : "";
    return ApiHelper.get(`${url}${queryParams}`);
    // return ApiHelper.get(`${URL_BASE_STATUS_LIST}/${URL_SUB_TREATMENT_STATUS}/${params.facilityCd}/${params.layoutNo}`);
  }
  return getWithLoader(url);
  // return getWithLoader(`${URL_BASE_STATUS_LIST}/${URL_SUB_TREATMENT_STATUS}/${params.facilityCd}/${params.layoutNo}`);
  /* modify by chamaojia 2024-03-27 [10303、10304] add interface input parameters 【nextPat】、【bedLayoutId】 --end */
  /* mod #8872 by zhangruixue 2023-06-21 --end */
  // mod bug 8514 修正 chen end
}

/**
 * スケジュールデータを取得
 * @param {Record<string, unknown>} params 施設コード、治療日付、レイアウトマスタの番号
 * @param {boolean} autoRefreshFlag 自動更新にloadingは必要ありません  true:loadingは不要
 */
export function sendRequestGetOnscheduleTreatmentStatusList(params, autoRefreshFlag) {
  const URL_SUB_ONSCHEDULE_TREATMEND_STATUS = "treatment_status_map_onschedule";
  /* modify by chamaojia 2024-03-27 [10303、10304] add interface input parameters 【bedLayoutId】、【kurCd】 --start */
  const normalizedBedLayoutId = params.bedLayoutId === "" || params.bedLayoutId === null || typeof params.bedLayoutId === "undefined" ? -1 : params.bedLayoutId;
  const normalizedKurCd = params.kurCd === "" || params.kurCd === null || typeof params.kurCd === "undefined" ? -1 : params.kurCd;
  const url = `${URL_BASE_STATUS_LIST}/${URL_SUB_ONSCHEDULE_TREATMEND_STATUS}/${params.facilityCd}/${params.treatDate}/${params.layoutNo}/${params.bedGroupCd}/${normalizedBedLayoutId}/${normalizedKurCd}`;
  if (autoRefreshFlag) {
    // 自動更新サインアウトON/OFFチェック
    const forceSignOutFlag = store.getters["status-map/map/getForceSignOutFlag"];
    const queryParams = forceSignOutFlag == 0 ? "?__background_call__=true" : "";
    return ApiHelper.get(`${url}${queryParams}`);
  }
  return getWithLoader(url);
  /* modify by chamaojia 2024-03-27 [10303、10304] add interface input parameters 【bedLayoutId】、【kurCd】 --end */
}
/* modify by chamaojia 2022-11-26 [6746] loading判定パラメータの追加要否  --end */

/**
 * 指定したord_noの治療状況マップアイコン設定情報を取得
 * @param {unknown[]} ordNoArray オーダー番号配列
 * @param {boolean} autoRefreshFlag バックグラウンド取得
 */
export function sendRequestGetStatusMapInfo(ordNoArray, autoRefreshFlag) {
  if (autoRefreshFlag) {
    return ApiHelper.get(`${URL_BASE_STATUS_MAP}/${ordNoArray.join(",")}?__background_call__=true`);
  }
  return getWithLoader(`${URL_BASE_STATUS_MAP}/${ordNoArray.join(",")}`);
}

/** @deprecated 誤字。{@link sendRequestGetStatusMapInfo} を使用 */
export const sendRequestGerStatusMapInfo = sendRequestGetStatusMapInfo;
// mod 画面リロードの修正 付 end

export function sendRequestGetPersonalUserList(facilityCd) {
  return getWithLoader(`${URL_BASE_STATUS_MAP}/user/${facilityCd}`);
}

/**
 * 指定条件の治療スケジュールリストを取得
 * @param {string} treatDate 治療日
 * @param {string} kurCd クールコード
 * @param {string} bedCd ベッドコード
 * @param {string} [facilityCd] 施設コード
 * @param {string|number} [ordNo] オーダー番号
 * @param {string|number} [patId] 患者ID
 */
export function sendRequestGetOrdSchedule(
  treatDate,
  kurCd,
  bedCd,
  // add FNSI redmine 6588 劉祥霖 start
  facilityCd,
  ordNo,
  patId,
  indTreatmentCd
  // add FNSI redmine 6588 劉祥霖 end
) {
  return getWithLoader(
    // mod FNSI redmine 6588 劉祥霖 start
    `${URL_BASE_STATUS_MAP}/find-schedule/${treatDate}/${kurCd}/${bedCd}/${facilityCd}/${ordNo}/${patId}/${indTreatmentCd}`
    // mod FNSI redmine 6588 劉祥霖 end
  );
}

/**
 * 指定条件の治療スケジュールがあるか判断し、あれば治療状況を取得
 * @param {string} treatDate 治療日
 * @param {string} kurCd クールコード
 * @param {string} bedCd ベッドコード
 * @param {string|number} ordNo オーダー番号
 */
export function sendRequestGetLastestDialysisState(treatDate, kurCd, bedCd, ordNo) {
  return getWithLoader(
    `${URL_BASE_STATUS_MAP}/dial-state/${treatDate}/${kurCd}/${bedCd}/${ordNo}`
  );
}

/**
 * 治療予定のベッド移動前チェック結果を取得
 * @param {string|number} ordNo オーダー番号
 * @param {string} bedCd ベッドコード
 */
export function sendRequestCheckBeforeMoveOrdMain(ordNo, bedCd) {
  return getWithLoader(
    `${URL_BASE_STATUS_MAP}/check-before-move-ord/${ordNo}/${bedCd}`
  );
}

/**
 * ベッド未割当の治療情報の取得(モーダル向け)
 * @param {string} facilityCd 施設コード
 * @param {string} treatDate 治療日
 * @param {string} bedCd ベッドコード
 */
export function sendRequestGetNotAssignedOrdMain(facilityCd, treatDate, bedCd) {
  return getWithLoader(
    `${URL_BASE_STATUS_MAP}/notassigned/${facilityCd}/${treatDate}/${bedCd}`
  );
}

/**
 * 治療情報にスケジュールを割り当て
 * @param {Record<string, unknown>} params 割当パラメータ
 */
export function sendRequestPutAssignScheduleOrdMain(params) {
  return putWithLoader(
    `${URL_BASE_STATUS_MAP}/assign/${params.facilityCd}/${params.ordNo}/${
      params.bedCd}/${params.treatDate}/${params.kurCd}/${params.userId}`,
    null
  );
}

/**
 * 治療情報をベッド未割当
 * @param {Record<string, unknown>} params パラメータ
 */
export function sendRequestPutUnassigmentScheduleOrdMain(params) {
  return putWithLoader(
    `${URL_BASE_STATUS_MAP}/unassigment/${params.facilityCd}/${params.ordNo}/${params.userId}`,
    null
  );
}

/**
 * 治療情報のスケジュールを別のベッドへ移動
 * @param {*} params facilityCd,ordNo,bedCd,userId,isSendCondition
 */
export function sendRequestPutMoveScheduleOrdMain(params) {
  return postWithLoader(`${URL_BASE_STATUS_MAP}/schedule/update`, {
    operation: "MOVE",
    facilityCd: params.facilityCd,
    ordNo: params.ordNo,
    bedCd: params.bedCd,
    userId: params.userId,
    isSendCondition: params.isSendCondition
  });
}

/**
 * ２つの治療情報のスケジュールを入れ替え
 * @param {*} params ordNo1,ordNo2,userId
 */
export function sendRequestPutSwapScheduleOrdMain(params) {
  return postWithLoader(`${URL_BASE_STATUS_MAP}/schedule/update`, {
    operation: "SWAP",
    ordNo1: params.ordNo1,
    ordNo2: params.ordNo2,
    userId: params.userId
  });
}

/**
 * 条件送信キャンセル[デバイスエッジへの通知]
 * @param {Record<string, unknown>} params パラメータ
 */
export function sendRequestPostCancelCondition(params) {
  return postWithLoader(
    `${URL_BASE_DEVICE_EDGE_ORDER}/cancel_condition`,
    params
  );
}

/**
 * 条件送信キャンセル[DB関連処理]
 * @param {string} bedCd ベッドコード
 */
export function sendRequestPutSendConditionCancel(bedCd) {
  return putWithLoader(
    `${URL_BASE_STATUS_MAP}/unassigment/send_condition_cancel/${bedCd}`,
    null
  );
}

/**
 * 指示確認OK更新
 * @param {number} ordNo 指示番号
 * @param {Record<string, unknown>} param 指示情報
 */
export function sendRequestPutCheckForMap(ordNo, param) {
  return putWithLoader(`${URL_BASE_STATUS_MAP}/check-ind/${ordNo}`, param);
}

// mod 画面リロードの修正 付 start
/**
 * 指定オーダー番号のスケジュール情報取得
 * @param {string|number} ordNo オーダー番号
 */
export function sendRequestGetOrdMainByOrdNo(ordNo) {
  return ApiHelper.get(`${URL_BASE_STATUS_MAP}/getOrdMainByOrdNo/${ordNo}`);
}
// mod 画面リロードの修正 付 end

// add FNSI-7217 バッチ操作インターフェイスを追加します 查 start
/**
 * 指定オーダー番号のスケジュール情報取得（複数）
 * @param {string} ordNos オーダー番号（カンマ区切り等）
 * @param {boolean} autoRefreshFlag バックグラウンド取得
 */
export function sendRequestGetOrdMainListByOrdNo(ordNos, autoRefreshFlag) {
  if (autoRefreshFlag) {
    return ApiHelper.get(`${URL_BASE_STATUS_MAP}/getOrdMainListByOrdNo/${ordNos}?__background_call__=true`);
  }
  return getWithLoader(`${URL_BASE_STATUS_MAP}/getOrdMainListByOrdNo/${ordNos}`);
}
// add FNSI-7217 バッチ操作インターフェイスを追加します 查 end

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
