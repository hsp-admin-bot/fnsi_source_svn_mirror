/**
 * デバイスエッジ稼働監視系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

/**
 * 利用者IDが管理する施設のデバイスエッジ稼働一覧取得
 * @param {string|number} userId ユーザーID
 */
export function sendRequestFindDeviceEdges(userId) {
  return ApiHelper.get(`/device_edge/${userId}`);
}
