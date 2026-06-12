/**
 * 定期点検系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";
import { MainteClass } from "@/constants/mainteConstants";

/**
 * 定期点検系用URL
 */
const DAILY_CHECK = "/mente-main";

/**
 * 全て装置情報取得
 */
export function sendRequestGetAllMachine() {
  return ApiHelper.get(`${DAILY_CHECK}/machines-inspection`);
}

/**
 * 全てレイアウトグループ情報取得
 */
export function sendRequestGetAllLayoutGroup() {
  return ApiHelper.get(`mente-layout-group/get-all`);
}
// add FNSI-8013 定期点検でマスタで設定した機種に該当しない定期点検が作成できる 2022/10/27 周安寧 start
/**
 * 対象機種のレイアウトグループ情報取得
 */
export function sendRequestLayoutGroupByMachineType() {
  return ApiHelper.get(`mente-layout-group/get-layout-machineType`);
}
// add FNSI-8013 定期点検でマスタで設定した機種に該当しない定期点検が作成できる 2022/10/27 周安寧 end
// add 吉 start
export function sendRequestGetAllLayout() {
  return ApiHelper.get(`mente-layout-group/get-layout-all`);
}
// add 吉 end
/**
 * 指定した日付範囲の検査結果リストを取得する
 * @param {string} dateStart 点検日範囲開始（下限）（YYYY-MM-DD）
 * @param {string} dateEnd 点検日範囲終了（上限）（YYYY-MM-DD）
 */
export function sendRequestGetResultByDateSpan(dateStart, dateEnd) {
  return ApiHelper.get(`${DAILY_CHECK}/results/date-span`, {
    mainteClass: MainteClass.Periodic,
    mainteDateStart: dateStart,
    mainteDateEnd: dateEnd,
  });
}

/**
 * @description 検索条件に対応する装置リストの検索
 * @param {Object} params 検索条件
 * @return {Promise<Object[]>} 装置リスト
 */
export function sendRequestGetMachineSearchResult(params) {
  return ApiHelper.post(`${DAILY_CHECK}/getMachineSearchResult`, {
    bed_group_cd: params.bedGroupCd,
    machine_type_list: params.machineTypeList,
    start_date: params.startDate,
    end_date: params.endDate,
  });
}

/**
 * 一時的に機器保守レコードを登録する。
 * @param {*} params
 * @param {*} layoutGroupId レイアウトグループコード
 * @param {Object} body
 */
export function sendRequestCreateMenteTemp(params) {
  return ApiHelper.post(
    `mente-layout/peri/tmp-main/${params.layoutGroupId}`,
    params.body
  );
}

/**
 * 機器保守詳細を取得する。
 * @param {*} params
 * @param {*} layoutGroupId レイアウトグループコード
 * @param {Object} body
 */
export function sendRequestGetDetailGetDetailResult(params) {
  return ApiHelper.get(`mente-main/peri/result-detail`, params);
}

/**
 * レイアウトマスター詳細を取得する。
 * @param {*} params
 * @param {number} menteLayoutGroupCd レイアウトグループコード
 * @param {number} machineTypeCd 適用型式コード
 * @param {number} menteLayoutCd レイアウトコード
 */
export function sendRequestGetDetailForMaster(params) {
  return ApiHelper.get(`mente-layout/peri/show-detail`, params);
}

/**
 * 全てユーザーマスターを取得する。
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetAllUserInforMation(facilityCd) {
  return ApiHelper.get(`mstInfo/mstPersonalUser`, { facility_cd: facilityCd });
}

/**
 * 点検予定を登録する。
 * @param {Record<string, unknown>} body 登録ボディ
 */
export function sendRequestCreateMentePlan(body) {
  return ApiHelper.post(`mente-main/plan`, body);
}

/**
 * 機器保守結果を更新する。
 * @param {Object} body 機器保守詳細
 */
export function sendRequestUpdateMente(body) {
  return ApiHelper.post(`mente-main/detail-update`, body);
}

/**
 * 定期点検の履歴取得
 * @param {Object} params
 * @param {Record<string, unknown>} params
 * @param {string} [params.date] 現在の日付
 * @param {string} [params.menteClass] 保守区分
 * @param {number} [params.menteLayoutCd] 点検レイアウトコード
 * @param {number} [params.machineNo] 装置番号
 * @param {number} [params.numOfYear] 過去年数
 */
export function sendRequestGetHistory(params) {
  return ApiHelper.get(`mente-main/history/peri`, params);
}

//del #9545(定期点検画面にて、定期点検の予定を中止した際、他の装置の予定も削除される) #9540(機器保守_定期点検画面にて、結果無し予定の中止操作で、結果あり時の削除確認メッセージが表示する) zhaoqi 20230921 start
// /**
//  * 点検レコードの状況を削除済に更新する。
//  * @param {Object} params 点検番号リスト
//  */
// export function sendRequestDeletePeriodicInspection(params) {
//   return ApiHelper.post(`mente-main/delete`, params);
// }
//del #9545(定期点検画面にて、定期点検の予定を中止した際、他の装置の予定も削除される) #9540(機器保守_定期点検画面にて、結果無し予定の中止操作で、結果あり時の削除確認メッセージが表示する) zhaoqi 20230921 end
