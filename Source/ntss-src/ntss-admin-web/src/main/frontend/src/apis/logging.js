/**
 * ログ出力用API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

/**
 * ログ出力APIのベースURL
 */
const URL_BASE = "/logging";

/**
 * ログを出力する.
 * @param {string} logClass ログ区分(app or event)
 * @param {string} logLevel ログレベル(info or warn or error or debug)
 * @param {Record<string, unknown>} param ログ出力内容(LogMessage)
 * @returns {Promise} 出力結果
 */
export function outputLog(logClass, logLevel, param) {
  return ApiHelper.put(`${URL_BASE}/${logClass}/${logLevel}`, param);
}
