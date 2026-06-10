/**
 * マスタメンテナンス用パンくず履歴特定用キー定義
 */

// マスタメンテナンスのプレフィックス
const PREFIX = "MASTER_MAINTENANCE_";

// マスタ一覧
export const HISTORY_KEY_MASTER_MAINTENANCE_LIST = PREFIX + "LIST";

// マスタメンテナンス レコードページ
export const HISTORY_KEY_MASTER_MAINTENANCE_RECORD = PREFIX + "RECORD";

/********************************************/
/* 個別編集マスタメンテナンスから皿に遷移する子画面 */
/********************************************/

// 個別編集マスタメンテナンス子画面 体重計マスタ
export const HISTORY_KEY_MASTER_MAINTENANCE_EX_WEIGHT = "EX_WEIGHT";
// 治療状況マップベッドレイアウトマスタメンテナンス
export const HISTORY_KEY_MASTER_MAINTENANCE_EX_MAP_BED_LAYOUT = "EX_MAP_BED_LAYOUT";
