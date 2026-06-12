

/**
 *  デバイスエッジ指示用トピック
 */
export const DEVICE_EDGE_MANAGE_CLASS = {
  /**
   *  ソフト更新指示用トピック
   */
  UPDATE: 0,
  /**
   * レストア用トピック
   */
  RESTORE: 1,
  /**
   * ログ収集命令トピック
   */
  LOG_GATHER: 2,
  /**
   * NTSSサービス再起動トピック
   */
  APP_REBOOT: 3,
  /**
   * NTSSサービス停止トピック
   */
  APP_STOP: 4,
  /**
   * NTSSサービス開始トピック
   */
  APP_START: 5,
  /**
   * デバイス再起動トピック
   */
  DEVICE_REBOOT: 6,
  /**
   * 設定収集トピック
   */
  CONF_GATHER: 7,
  /**
   * 設定適用トピック
   */
  CONF_UPDATE: 8,
  /**
   * 予定キャンセルトピック
   */
  PLAN_CANCEL: 9
};

/**
 * 通知を受信するアプリ
 */
export const DEVICE_EDGE_MANAGE_TARGET = {
  APP: 0,
  UPDATER: 1
}
/**
 * 更新対象アプリ
 */
export const DEVICE_EDGE_MANAGE_APP_TYPE = {
  APP: 0,
  UPDATER: 1,
  ALL: 2
}
// add #8403 【デグレ】デバイスエッジマスタで新規レコードが保存できない dou start
/**
 * Message
 */
export const ERROR_DEVICE_EDGE_SAVE = "デバイスエッジマスタの保存に失敗しました。";
// add #8403 【デグレ】デバイスエッジマスタで新規レコードが保存できない dou end
