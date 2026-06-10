/**
 * LocalStorage用の定数ファイル
 */
export const LOCAL_STORAGE_KEY = {
  /**
   * サインイン時刻
   */
  SIGN_IN_TIME: "s-time",
  /**
   * 端末固有ID
   */
  TERMINAL_UNIQUE_STRING: "terminalUniqueString",
  /**
   * 施設コードハッシュ値
   * ※facilityHashとしていない理由は、名称から推測されない様にする為です.
   */
  FACILITY_HASH : "hash",
  /**
   * サインインカウント
   */
  SIGN_IN_COUNT : "count",
  /**
   * 他のタブでサインイン処理を発火させるトリガー用のkey
   */
  SIGN_IN_TRIGGER : "signInTrigger",
  /**
   * 他のタブでサインアウト処理を発火させるトリガー用のkey
   */
  SIGN_OUT_TRIGGER : "signOutTrigger",
  /**
   * 体重測定画面の倍率用のkey
   */
   WEIGHT_SCALE_ZOOM : "weightScaleZoom",
  /**
   * 全画面メッセージ表示のkey
   */
   FULL_SCREEN_MSG_SHOW : "fullScreenMsgShow"
};