/**
 * WebSoket接続関連の定数ファイル
 */

/**
 * WebSoket再接続インターバル(ms)
 */
export const WS_RECONNECT_INTERVAL = 3000;

/**
 * WebSoket接続状態
 */
export const READYSTATE = {
  /**
   * 接続を開始して、未接続の状態
   */
  CONNECTING: 0,
  /**
   * 接続が確立して、通信中の状態
   */
  OPEN: 1,
  /**
   * 切断を開始して、切断が完了していない状態
   */
  CLOSING : 2,
  /**
   * 切断が完了して、未接続の状態
   */
  CLOSED : 3
};
