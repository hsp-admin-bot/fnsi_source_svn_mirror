/**
 * 通知一覧系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

/**
 * 通知取得（未通知）.
 */
export function sendRequestGetNotificationMessage() {
  // UPD #8224 2023/02 BY HandsomeLin Start
  return ApiHelper.get("notification-message?__background_call__=true");
  // UPD #8224 2023/02 BY HandsomeLin End
}

// add bug 6531 修正 chen start
/**
 * 通知取得（未通知）.
 */
export function sendRequestGetNotificationMessageForLogin() {
  return ApiHelper.get("notification-message/login");
}
// add bug 6531 修正 chen end

/**
 * 通知取得（全件）.
 */
// mod FNSI-通知表示が遅いを修正 江 start
// export function sendRequestGetNotificationMessageAll() {
//   return ApiHelper.get("notification-message/all/");
// }
export function sendRequestGetNotificationMessageAll(payload) {
  return ApiHelper.get("notification-message/all/"+payload);
}
// mod FNSI-通知表示が遅いを修正 江 end

// del #10110 通知一覧から既読にした通知以外も消える dengshen start
// // add FNSI redmine 4893 修正 鄧シン start
// export function sendRequestGetNotificationMessageAllAfterChange(payload) {
//   return ApiHelper.get("notification-message/allAfterChange/"+payload);
// }
// // add FNSI redmine 4893 修正 鄧シン end
// del #10110 通知一覧から既読にした通知以外も消える dengshen end

/**
 * 未読/既読更新.
 * @param {*} payload 未読/既読情報
 */
export function sendRequestUpdateNotificationMessageStatus(payload) {
  return ApiHelper.put("notification-message/status", payload);
}

// add FNSI-通知既読更新を修正 江 start
/**
 * 既読更新.
 */
export function sendRequestUpdateAllNotificationMessageisRead() {
  return ApiHelper.put("notification-message/allIsRead");
}
// add FNSI-通知既読更新を修正 江 end

/**
 * 通知メッセージ登録.
 * @param {*} payload 通知メッセージ情報
 */
export function sendRequestRegisterNotificationMessage(payload) {
  // mod FNSI-コードをマージ 江 start
  // return ApiHelper.post("notification-message", payload);
  return ApiHelper.put("notification-message", payload);
  // mod FNSI-コードをマージ 江 end
}
