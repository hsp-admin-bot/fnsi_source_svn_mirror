/**
 * 日付関係ユーティリティ
 */

/**
 * エラーメッセージ
 * @param {String} dateString 日付文字列(yyyy-MM-dd or yyyy/MM/dd)
 * @param {String} timeString 時刻文字列(HH:mm)
 */
import { ApiHelper } from "@/apis/AxiosHelper";

export function getErrorMessage(fileName, methodName, err) {
  var tmpMessage = '';
  if (err.response) {
    if (err.response.data.errorMessage == undefined) {
      tmpMessage = err.response.status + ' ' + err.response.statusText;
    } else {
      tmpMessage = err.response.data.errorMessage;
    }
  } else {
    tmpMessage = err;
  }
  var message = "VUE: " + fileName + " メソッド: " + methodName + " エラーメッセージ: " + tmpMessage;

  //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
  let eventLogMessage = {"logMessage": message};
  ApiHelper.put("/logging/vue/applog/error", eventLogMessage).catch(error => {});
}


