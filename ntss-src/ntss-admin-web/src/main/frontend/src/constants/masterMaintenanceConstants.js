/**
 * マスタメンテナンス用定数定義
 */

// --------------------------------------
// 表示モード（sys_master_define.modeで定義）
// --------------------------------------
export const MODE = {
  // モード1
  MODE1: "1",

  // モード2
  MODE2: "2"
};

export const MASTER_MAINTENANCE_CURRENT_ROUTE_NAME = "master-record";

// 利用者マスタ：使用許可機能で、機能が削除された場合、又は、権限の変更が行われた場合の確認メッセージ
export const MSG_SETTING_REFLECTION = "設定を反映するため、対象の利用者をサインアウトします。</br>よろしいですか？";
