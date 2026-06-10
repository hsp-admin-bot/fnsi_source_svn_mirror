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
//add FNSI-8013 定期点検でマスタで設定した機種に該当しない定期点検が作成できる 2022/10/27　周安寧 start
/**
 * 対象機種のレイアウトグループ情報取得
 */
export function sendRequestLayoutGroupByMachineType() {
  return ApiHelper.get(`mente-layout-group/get-layout-machineType`);
}
//add FNSI-8013 定期点検でマスタで設定した機種に該当しない定期点検が作成できる 2022/10/27　周安寧 end
//add 吉 start
export function sendRequestGetAllLayout() {
  return ApiHelper.get(`mente-layout-group/get-layout-all`);
}
//add 吉 end
/**
 * 指定した日付範囲の検査結果リストを取得する
 * （引数の値が空文字列の場合、それぞれの条件は未指定であることを表す）
 * @param {string} dateStart 点検日範囲開始（下限）（YYYY-MM-DD）
 * @param {string} dateEnd 点検日範囲終了（上限）（YYYY-MM-DD）
 */
export function sendRequestGetResultByDateSpan(dateStart, dateEnd) {
  return ApiHelper.get(
    `${DAILY_CHECK}/results/date-span`, {
      mainteClass: MainteClass.Periodic,
      mainteDateStart: dateStart,
      mainteDateEnd: dateEnd,
    }
  );
}

/**
 * @description 検索条件に対応する装置リストの検索
 * @param {Object} params 検索条件
 * @param {number} param.bedGroupCd ベッドグループコード
 * @param {String[]} param.machineTypeList 装置型式リスト
 * @param {String} params.startDate 表示期間開始日
 * @param {String} params.endDate 表示期間終了日
 * @return {Promise<Object[]>} 装置リスト
 */
export function sendRequestGetMachineSearchResult(params) {
  return ApiHelper.post(
    `${DAILY_CHECK}/getMachineSearchResult`,
    {
      bed_group_cd: params.bedGroupCd,
      machine_type_list: params.machineTypeList,
      start_date: params.startDate,
      end_date: params.endDate,
    }
  );
}

/**
 * 一時的に機器保守レコードを登録する。
 * @param {Object} params
 * @param {String | number} params.layoutGroupId 点検レイアウトグループコードの文字列（数値でも可）
 * @param {Object} params.body 登録内容
 * @param {Object[]} params.body.machineInfoList マシン情報リスト
 * @param {String[]} params.body.menteDateList 日付リスト（YYYY-MM-DD）
 * @param {String[]} [params.body.oldDate] 移動元日付リスト（YYYY-MM-DD）
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
 * @param {String} userIDList ユーザーIDリスト
 */
export function sendRequestGetAllUserInforMation(facilityCd) {
  return ApiHelper.get(`mstInfo/mstPersonalUser`, { facility_cd: facilityCd });
}

/**
 * 点検予定を登録する。
 * @param {String} userIDList ユーザーIDリスト
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
 * @param {date} params.date 現在の日付
 * @param {String} params.menteClass 保守区分
 * @param {number} param.menteLayoutCd 点検レイアウトコード
 * @param {number} param.machineNo 装置番号
 * @param {number} param.numOfYear 過去年数
 */
export function sendRequestGetHistory(params) {
  return ApiHelper.get(`mente-main/history/peri`, params);
}
