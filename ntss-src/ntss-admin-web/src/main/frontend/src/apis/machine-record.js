/**
 * 装置記録系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

/**
 * 装置記録用URL
 */
const URL_BASE = "/machine_record";

/**
 * 装置記録の全データを取得
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetMachineRecord(facilityCd) {
  return ApiHelper.get(`${URL_BASE}/${facilityCd}`);
}
