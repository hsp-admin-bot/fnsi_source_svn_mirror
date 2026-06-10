/**
 * 送信先グループ系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

/**
 * 送信先グループ系用URL
 */
const URL_BASE = "/destination_group";

/**
 * 送信先グループ名を取得
 */
export function sendRequestGetDestinationGroupName(destinationGroupCd) {
  return ApiHelper.get(`${URL_BASE}/${destinationGroupCd}/name`);
}
