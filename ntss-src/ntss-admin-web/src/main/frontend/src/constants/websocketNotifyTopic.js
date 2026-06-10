/**
 * WebSocket経由で飛んでくる通知のトピック部を宣言
 */

/**
 * カード読取通知のトピック識別子
 */
export const NOTIFY_TOPIC_WEIGHT_CARD_READ = "WEIGHT/CARD_READ";

/**
 * 体重測定通知のトピック識別子
 */
export const NOTIFY_TOPIC_WEIGHT_SCALE_VALUE = "WEIGHT/SCALE_VALUE";
/**
 * カード書き込み結果通知のトピック識別子
 */
export const NOTIFY_TOPIC_WEIGHT_CARD_WRITE_RESULT = "WEIGHT/CARD_WRITE_RESULT";
/**
 * 体重計装置接続状態通知の識別子
 */
export const NOTIFY_TOPIC_WEIGHT_CONNECT = "WEIGHT/CONNECT";
/**
 * 条件送信結果通知
 */
export const NOTIFY_TOPIC_SEND_CONDITION_RESULT = "WEIGHT/SEND_RESULT";

/**
 * 通知メッセージのトピック識別子
 */
export const NOTIFY_TOPIC_NOTIFICATION_MESSAGE = "NOTIFICATION/MESSAGE";
// add FNSI-画面リロードの修正 徐 start
/**
 * 警報、報知情報通知
 */
export const NOTIFY_TOPIC_MACHINE_RESULT = "MACHINE/MACHINE_RESULT";
// add FNSI-画面リロードの修正 徐 end
/**
 * 強制サインアウト通知のトピック識別子
 */
export const NOTIFY_TOPIC_FORCE_SIGNOUT = "SYSTEM/FORCE_SIGNOUT";
