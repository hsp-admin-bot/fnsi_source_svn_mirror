package jp.co.nikkiso.ntss.web_api.util;

/**
 * 施設解約で使用する定数を定義するクラス。
 */
public class FacilityCancelConstants {
  // 特別な処理を必要とするテーブル
  /** テーブル名: mnt_facility_cancel_manage */
  public static final String TABLE_NAME_MNT_FACILITY_CANCEL_MANAGE = "mnt_facility_cancel_manage";

  /** テーブル名: mst_user_authentication */
  public static final String TABLE_NAME_MST_USER_AUTHENTICATION = "mst_user_authentication";

  /** テーブル名: mst_facility_hash */
  public static final String TABLE_NAME_MST_FACILITY_HASH = "mst_facility_hash";

  /** テーブル名: sys_signin_manager */
  public static final String TABLE_NAME_SYS_SIGNIN_MANAGER = "sys_signin_manager";

  /** テーブル名: mst_pat_hash */
  public static final String TABLE_NAME_MST_PAT_HASH = "mst_pat_hash";

  /** テーブル名: mst_machine */
  public static final String TABLE_NAME_MST_MACHINE = "mst_machine";

  /** テーブル名: ind_history (MongoDB) */
  public static final String TABLE_NAME_IND_HISTORY = "ind_history";

  /** テーブル名: mst_selector */
  public static final String TABLE_NAME_MST_SELECTOR = "mst_selector";

  // 定数
  /** 分をミリ秒に換算する単位 */
  public static final Integer MILLIS_IN_MINUTE = 60 * 1000;

  /** 設定: sys_system_defineのアクセス番号(施設解約) */
  public static final Integer FACILITY_CANSEL_SETTING_NO = 29;

  /** 設定: sys_system_defineのアクセス番号(施設解約のテーブル管理) */
  public static final Integer FACILITY_CANCEL_TARGET_TABLE = 30;

  /** 設定: sys_system_defineのアクセス番号(期間外削除対象テーブル・REMSのみ) */
  public static final Integer EXPIRE_TARGET_TABLE_REMS_ONLY = 31;

  /** 設定: sys_system_defineのアクセス番号(期間外削除対象テーブル・FNSI) */
  public static final Integer EXPIRE_TARGET_TABLE_FNSI = 33;

  /** 一度に削除するレコードのデフォルト値 */
  public static final Integer DEFAULT_MAX_DELETE_LIMIT = 1000;

  /** 実行時間上限のデフォルト値 */
  public static final Long DEFAULT_EXPIRATION = 1L * MILLIS_IN_MINUTE;

  // 設定キー
  /** 設定キー: 一度に削除するレコード数の上限 */
  public static final String CONF_KEY_MAX_DELETE_LIMIT = "max_delete_limit";

  /** 設定キー: 除外テーブルリスト */
  public static final String CONF_KEY_EXCLUDE_TABLE_LIST = "exclude_table_list";

  /** 設定キー: 別名の施設解約テーブルリスト */
  public static final String CONF_KEY_INCLUDE_TABLE_LIST = "include_table_list";

  /** 設定キー: 削除優先順位テーブルリスト */
  public static final String CONF_KEY_PRIORITY_TABLE_LIST = "priority_table_list";

  /** 設定キー: ReMSのみ解約対象テーブルリスト */
  public static final String CONF_KEY_REMS_CANCEL_TARGET_TABLE_LIST = "rems_cancel_target_table_list";

  /** 設定キー: FNSiのみ解約対象外テーブルリスト */
  public static final String CONF_KEY_FNSI_CANCEL_EXCLUDE_TABLE_LIST = "fnsi_cancel_exclude_table_list";

  /** 設定キー: バックアップファイルのパスのテンプレート(施設解約向け) */
  public static final String CONF_KEY_FILE_PATH_TEMPLATE_CANCEL = "backup_path_template_cancel";

  /** 設定キー: バックアップファイルのパスのテンプレート(期間外削除向け) */
  public static final String CONF_KEY_FILE_PATH_TEMPLATE_EXPIRE = "backup_path_template_expire";

  /** 設定キー: バックアップ日時のフォーマット */
  public static final String CONF_KEY_FILE_PATH_DATE_FORMAT = "backup_path_date_format";

  /** 設定キー: バックアップ時のフェッチサイズ */
  public static final String CONF_KEY_BACKUP_FETCH_SIZE = "backup_fetch_size";

  // 統計情報キー
  /** 統計情報キー: データベース名 */
  public static final String STAT_KEY_DB_NAME = "db_name";

  /** 統計情報キー: データベース種別 */
  public static final String STAT_KEY_DB_CLASS = "db_class";

  /** 統計情報キー: テーブル名 */
  public static final String STAT_KEY_TABLE_NAME = "table_name";

  /** 統計情報キー: 日時比較対象カラム名 */
  public static final String STAT_KEY_TIME_COLUMN_NAME = "time_column_name";

  /** 統計情報キー: 施設コード別名のカラム名 */
  public static final String STAT_KEY_ALIAS_COLUMN_NAME = "alias_column_name";

  /** 統計情報キー: 処理開始日時 */
  public static final String STAT_KEY_START = "start";

  /** 統計情報キー: 処理終了日時 */
  public static final String STAT_KEY_END = "end";

  /** 統計情報キー: 削除前のレコード件数 */
  public static final String STAT_KEY_AMOUNT = "amount";

  /** 統計情報キー: 削除したレコード件数 */
  public static final String STAT_KEY_DELETED = "deleted";

  /** 統計情報キー: バックアップ開始日時 */
  public static final String STAT_KEY_BACKUP_START = "backup_start";

  /** 統計情報キー: バックアップ終了日時 */
  public static final String STAT_KEY_BACKUP_END = "backup_end";

  /** 統計情報キー: バックアップファイルパス */
  public static final String STAT_KEY_BACKUP_PATH = "backup_path";

  // 期間外削除テーブル管理キー
  /** 期間外削除テーブル管理キー: DBクラス */
  public static final String FACILITY_EXPIRE_KEY_DB_CLASS = "db_class";

  /** 期間外削除テーブル管理キー: テーブル名 */
  public static final String FACILITY_EXPIRE_KEY_TABLE_NAME = "table_name";

  /** 期間外削除テーブル管理キー: 日時比較対象カラム名 */
  public static final String FACILITY_EXPIRE_KEY_TIME_COLUMN_NAME = "time_column_name";

  /** 期間外削除テーブル管理キー: データ保持期間 */
  public static final String FACILITY_EXPIRE_KEY_RETENTION_PERIOD = "retention_period";

  /** 期間外削除テーブル管理キー: 例外施設指定 */
  public static final String FACILITY_EXPIRE_KEY_EXCEPTION = "exception";

  // 処理区分定数
  /** 処理区分: 施設解約 */
  public static final String PROC_CLASS_CANCEL = "1";

  /** 処理区分: 期間外削除 */
  public static final String PROC_CLASS_EXPIRE = "2";

  /** 処理区分: ReMSのみ解約 */
  public static final String PROC_CLASS_REMS_CANCEL = "3";

  /** 処理区分: FNSiのみ解約 */
  public static final String PROC_CLASS_FNSI_CANCEL = "4";

  // 処理ステータス定数
  /** ステータス: 処理待機 */
  public static final String PROC_STATUS_WAITING = "0";

  /** ステータス: バックアップ作成中 */
  public static final String PROC_STATUS_BACKUP_IN_PROGRESS = "1";

  /** ステータス: バックアップ作成済 */
  public static final String PROC_STATUS_BACKUP_COMPLETED = "2";

  /** ステータス: 処理中（delete） */
  public static final String PROC_STATUS_DELETING = "3";

  /** ステータス: 完了 */
  public static final String PROC_STATUS_COMPLETED = "9";

  /** ステータス: エラー */
  public static final String PROC_STATUS_ERROR = "E";

  /** ステータス: 解約取り消し */
  public static final String PROC_STATUS_CANCELED = "C";

  // データベース名定数
  /** データベース名の正規表現 */
  public static final String DB_NAME_PATTERN = "^.*(db[4-6])$";

  /** DB種別: 認証 */
  public static final String DB_KIND_AUTH = "db4";

  /** DB種別: 一般 */
  public static final String DB_KIND_DEFAULT = "db5";

  /** DB種別: 個人情報 */
  public static final String DB_KIND_PERSONAL = "db6";

  /** バックアップファイルのパスのパラメータ: 施設コード */
  public static final String PATH_PARAM_FACILITY_CD = "%FACILITY_CD%";

  /** バックアップファイルのパスのパラメータ: バックアップ作成日 */
  public static final String PATH_PARAM_DATE = "%DATE%";

  /** バックアップファイルのパスのパラメータ: データベース名 */
  public static final String PATH_PARAM_DB_NAME = "%DB_NAME%";

  /** バックアップファイルのパスのパラメータ: テーブル名 */
  public static final String PATH_PARAM_TABLE_NAME = "%TABLE_NAME%";

  // エンコーディング
  /** バックアップファイルのエンコーディング */
  public static final String BACKUP_FILE_ENCODING_BY_UTF_8 = "UTF-8";

  // 解約登録時の初期値
  /** 解約登録時の初期値: 表示フラグ（オン） */
  public static final String IS_DISP_INIT = "1";

  // 削除フラグ定数
  /** 削除フラグ: オフ、初期値 */
  public static final String IS_DEL_OFF = "0";

  /** 削除フラグ: オン */
  public static final String IS_DEL_ON = "1";

  // MongoDB関連
  /** MongoDB接続を有効にするprofile名 mongo */
  public static final String PROFILE_MONGO = "mongo";

  /** MongoDB バックアップ・削除対象検索キー名 */
  public static final String KEY_FACILITY_CD = "facility_cd";

  /** デバイスエッジへのマスタ同期通信におけるtopicの共通部分 */
  public static final String TOPIC_BASE = "NTSS/MST_SYNCHRO";

  /** デバイスエッジへのマスタ同期通信におけるデバイスエッジ通知アプリのURI(%sにIPアドレスを挿入すること). */
  public static final String CONNECT_URI_BASE = "http://%s:8080/ntss-client-comm/api/sendmessage";
}
