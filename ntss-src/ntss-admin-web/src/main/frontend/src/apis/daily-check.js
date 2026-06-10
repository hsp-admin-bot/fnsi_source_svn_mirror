/**
 * 日常点検系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";
import { MainteClass } from "@/constants/mainteConstants";

/**
 * 日常点検系用URL
 */
const DAILY_CHECK = "/mente-main";
/**
 * 点検レイアウトマスタ系用URL
 */
const LAYOUT_MST = "/mente-layout";

/**
 * 指定日の日常点検情報取得
 * @param {string} date 点検日（YYYY-MM-DD）
 */
export function sendRequestGetCheckResult(date) {
  return ApiHelper.get(`${DAILY_CHECK}/results/${MainteClass.Daily}/${date}`);
}

/**
 * 日常点検画面のレイアウトポップアップで表示する情報を取得
 * @param {number} mainteLayoutCd 点検レイアウトコード
 */
export function sendRequestGetLayoutDetail(mainteLayoutCd) {
  return ApiHelper.get(`${LAYOUT_MST}/details/${mainteLayoutCd}`);
}

/**
 * 点検レイアウト単位で点検結果を更新
 * @param {Object} params
 * @param {number} params.devMenteNo 点検結果コード
 * @param {number} params.machineNo 装置番号
 * @param {string} params.menteDate 点検日（YYYY-MM-DD）
 * @param {number} params.menteLayoutCd 点検レイアウトコード
 * @param {string} params.menteAns1 結果入力パターン
 */
export function sendRequestUpdateCheckResult(params) {
  return ApiHelper.post(`${DAILY_CHECK}/daily/changeStatus`, params);
}

/**
 * 点検項目ごとの点検結果を更新
 * @param {Object} params
 * @param {number} params.devMenteNo 点検結果コード
 * @param {number} params.machineNo 装置番号
 * @param {string} params.menteDate 点検日（YYYY-MM-DD）
 * @param {number} params.menteLayoutCd 点検レイアウトコード
 * @param {string} params.menteAns1 結果入力パターン
 * @param {string} params.detail 内容（JSON文字列）
 */
export function sendRequestUpdateCheckResultList(params) {
  return ApiHelper.post(`${DAILY_CHECK}/daily/changeStatusList`, params);
}

/**
 * 点検日と点検レイアウトコードによる全台合格処理を行う
 * @param {Object} params
 * @param {string} params.params.menteDate 点検日（YYYY-MM-DD）
 * @param {number} params.params.menteLayoutCd 点検レイアウトコード
 * @param {number[]} params.machineNoList 全台合格処理の対象とする装置番号のリスト
 */
export function sendRequestUpdateAllCheckResult(params) {
  return ApiHelper.post(`${DAILY_CHECK}/daily/passAll`, params);
}

/**
 * ユーザーIDのユーザーリスト情報取得
 * @param {string[]} userIDList ユーザーIDリスト
 */
export function sendRequestGetUerByListID(userIDList) {
  return ApiHelper.get(`${DAILY_CHECK}/users-info`, {
    userIdList: userIDList.join(","),
  });
}

/**
 * 装置番号と点検日による点検項目入力画面用レイアウトマスタ情報取得
 * @param {number} machineNo 装置番号
 * @param {string} date 点検日（YYYY-MM-DD）
 */
export function sendRequestGetDetailOfMachine(machineNo, date) {
  return ApiHelper.get(
    `${DAILY_CHECK}/result-detail/${machineNo}/${MainteClass.Daily}/${date}`
  );
}

/**
 * 日常点検用のレイアウト情報取得
 * @param {string} mainteDate 点検日（YYYY-MM-DD）
 */
export function sendRequestGetLayoutForDailyCheck(mainteDate) {
  return ApiHelper.get(`${LAYOUT_MST}/daily/show-layout`, {
    mainteDate,
  });
}

/**
 * 指定のグループを持つ日常点検用レイアウトリストを取得
 * @param {number} mainteCategoryCd 点検グループコード
 */
export function sendRequestGetLayoutWithCategoryCd(mainteCategoryCd) {
  return ApiHelper.get(`${LAYOUT_MST}/daily/category-layout`, {
    mainteCategoryCd,
  });
}

/**
 * 装置情報取得
 * @param {number} machineNo 装置番号
 * @param {string} menteDate 点検日（YYYY-MM-DD）
 */
export function sendRequestGetLayoutDetailOfMachine(machineNo, menteDate) {
  return ApiHelper.get(
    `${LAYOUT_MST}/daily/show-detail?machineNo=${machineNo}&menteDate=${menteDate}`
  );
}

/**
 * 装置番号と点検日による点検履歴画面用レイアウトマスタ情報取得
 * @param {number} machineNo 装置番号
 * @param {string} menteDate 点検日（YYYY-MM-DD）
 * @param {number} numOfMonth 点検日を起点とした取得期間の月数
 */
export function sendRequestGetLayoutDetailOfMachineHistory(machineNo, menteDate, numOfMonth) {
  return ApiHelper.get(
    `${LAYOUT_MST}/daily/show-detail-history?machineNo=${machineNo}&menteDate=${menteDate}&numOfMonth=${numOfMonth}`
  );
}

/**
 * 点検結果レコードの状況を削除済に更新
 * @param {Object} params
 * @param {number[]} params.listMainNo 点検結果コードリスト
 */
export function sendRequestDeleteDevMenteNo(params) {
  return ApiHelper.post(`${DAILY_CHECK}/delete`, params);
}

/**
 * 点検履歴画面用の点検結果の情報を取得
 * @param {Object} params
 * @param {number} params.machineNo 装置番号
 * @param {string} params.startDate 点検日範囲上限（YYYY-MM-DD）
 * @param {string} params.endDate 点検日範囲下限（YYYY-MM-DD）
 * @param {string} params.facilityCd 施設コード
 */
export function sendRequestGetMachineResult(params) {
  const { machineNo, startDate, endDate, facilityCd } = params;
  return ApiHelper.get(`${DAILY_CHECK}/getLayout/${machineNo}/${startDate}/${endDate}/${facilityCd}`);
}

/**
 * 日常点検画面用の装置リストを取得
 * @param {Object} params
 * @param {number} params.bedGroupCd ベッドグループコード
 * @param {string[]} params.machineTypeList 型式リスト
 * @param {string} params.keyword フリーワード
 */
export function sendRequestGetMachinesConditionRes(params) {
  return ApiHelper.post(`${DAILY_CHECK}/get-condition-machines`, params);
}
