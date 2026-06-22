/**
 * 施設カレンダー／患者イベントカテゴリマスタ系 API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

function withSelectedPatId(params = undefined, selectedPatId) {
  if (selectedPatId === null || selectedPatId === undefined || selectedPatId === "") {
    return params;
  }
  return {
    ...(params || {}),
    selectedPatId
  };
}

/**
 * 患者イベントカテゴリマスタ取得
 */
export function sendRequestGetPatEventCateMst(selectedPatId) {
  return ApiHelper.get(
    "/master_maintenance/mst_pat_event_category/data",
    withSelectedPatId(undefined, selectedPatId)
  );
}

/**
 * 患者イベントサブカテゴリマスタ取得
 */
export function sendRequestGetPatSubEventCateMst(selectedPatId) {
  return ApiHelper.get(
    "/master_maintenance/mst_pat_event_sub_category/data",
    withSelectedPatId(undefined, selectedPatId)
  );
}
