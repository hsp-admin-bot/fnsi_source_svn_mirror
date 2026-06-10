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
 * @param logClass ログ区分(app or event)
 * @param logLevel ログレベル(info or warn or error or debug)
 * @param param ログ出力内容(LogMessage)
 * @returns 出力結果
 */
export function outputLog(logClass, logLevel, param) {
  return ApiHelper.put(`${URL_BASE}/${logClass}/${logLevel}`, param);
}
