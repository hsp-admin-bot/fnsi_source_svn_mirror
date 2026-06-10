package jp.co.nikkiso.ntss.coop_api.utils;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.HashSet;
import java.util.Arrays;
/**
 * ジャーナル変換で使用する定数を定義するクラス
 */
public class JournalConvertConstants {

  /**
   * 作成区分。
   */
  public enum CreationDiv {

    /**
     * 新規
     */
    CREATE("cre"),

    /**
     * 変更
     */
    UPDATE("upd"),

    /**
     * 削除
     */
    DELETE("del");

    private static final Map<String, CreationDiv> map = new HashMap<>();

    static {
      for (CreationDiv cd : values()) {
        map.put(cd.getName(), cd);
      }
    }
    private String name;

    private CreationDiv(String name) {
      this.name = name;
    }

    public String getName() {
      return name;
    }

    public static CreationDiv getByName(String s) {
      return map.get(s);
    }
  }

  public enum VendorMode {
    /**
     * 富士通
     */
    FUJITSU("FUJITSU_PROFILE"),

    /**
     * NEC
     */
    NEC("NEC_INIDIAL"),

    /**
     * Panasonic
     */
    PANA("PANA_PAT");

    private String name;

    private static final Map<String, VendorMode> map = new HashMap<>();

    static {
      for (VendorMode cd : values()) {
        map.put(cd.getName(), cd);
      }
    }

    private VendorMode(String name) {
      this.name = name;
    }

    public String getName() {
      return name;
    }

    public static VendorMode getByName(String s) {
      return map.get(s);
    }
  }

  /**
   * 電文のエンコーディング
   */
  public static final String TELEGRAM_ENCODING_BY_SJIS = "SJIS";

  //add 7713 富士通指摘：PC上で使用している文字で判読不能になるものがある。張 start
  /**
   * 電文のエンコーディング MS932
   */
  public static final String TELEGRAM_ENCODING_BY_MS932 = "MS932";
  //add 7713 富士通指摘：PC上で使用している文字で判読不能になるものがある。張 end

	/**
   * 電文のエンコーディング JIS
   */
  public static final String TELEGRAM_ENCODING_BY_JIS = "x-JIS0208";


  /**
   * 電文フォーマット: 固定長テキスト
   */
  public static final String FORMAT_TEXT = "text";

  /**
   * 電文フォーマット: CSV形式
   */
  public static final String FORMAT_CSV = "csv";

  /**
   * 電文フォーマット: XML形式
   */
  public static final String FORMAT_XML = "xml";

  /**
   * 電文フォーマット: XML形式
   */
  public static final String FORMAT_LIST_XML = "listxml";

  /**
   * 電文フォーマット: PDF形式
   */
  public static final String FORMAT_PDF = "pdf";

  /**
   * 電文種別補足コード（詳細補足コード）: プレロジック
   */
  public static final String AUX_CODE_PRELOGIC = "pre";

  /**
   * 電文種別補足コード（詳細補足コード）: プレロジック&抽出レイアウト兼用
   */
  public static final String AUX_CODE_ALL = "all";

  /**
   * 変換レイアウトマスタのitem.value属性で指定される特殊値: 定数指定
   */
  public static final String EVAL_LABEL_CONST = "const";

  /**
   * 変換レイアウトマスタのitem.value属性で指定される特殊値: JSON置換指定
   */
  public static final String EVAL_LABEL_JSON = "json";

  /**
   * 変換レイアウトマスタのitem.value属性で指定される特殊値: dataset置換指定
   */
  public static final String EVAL_LABEL_DATASET = "dataset";

  /**
   * 変換レイアウトマスタのitem.value属性で指定される特殊値: タグなしの場合の置換指定
   */
  public static final String EVAL_LABEL_DEFAULT = "default";

  /**
   * 拡張設定のトップレベルキー: key属性置換用
   */
  public static final String EXT_SETTING_TOP_KEY_KEY = "key";

  /**
   * 拡張設定のトップレベルキー: value="json:～"属性置換用
   */
  public static final String EXT_SETTING_TOP_KEY_VALUE_JSON = "json-key";

  /**
   * 拡張設定を参照する時のデフォルト値指定キー
   */
  public static final String EXT_SETTING_KEY_DEFAULT = "_DEFAULT";

  /**
   * 特殊値の種類を示すラベルと特殊値本体を分けるデリミタ
   */
  public static final String EVAL_LABEL_DELIM = ":";

  /**
   * col属性の指定において、テーブル名、カラム名、JSONキー名を分けるデリミタ（正規表現）
   */
  public static final String TABLE_COLUMN_REGEXP_DELIM = "\\.";

  /**
   * データセット変換のリクエストURI
   */
  public static final String EVAL_DATASET_URI = "/ntss-api/api/data-set";

  /**
   * データセット変換でリクエストパラメータに施設コードを指定するキー
   */
  public static final String EVAL_DATASET_PARAM_FACILITY_CD = "%FACILITYCD%";

  /**
   * データセット変換でリクエストパラメータに電文項目を指定するキー
   */
  public static final String EVAL_DATASET_PARAM_ITEM_VALUE = "%VALUE%";

  /**
   * データセット変換でリクエストパラメータ全体を取得するためのキー
   */
  public static final String EVAL_DATASET_PARAM_KEY = "dataKey";

  /**
   * 電文変換の型チェック指定: 文字列型
   */
  public static final String TYPE_STRING = "string";

  /**
   * 文字列チェックのための正規表現
   */
  public static final String REGEXP_STRING = "^.*$";

  /**
   * 電文変換の型チェック指定: 数値型
   */
  public static final String TYPE_NUMERIC = "numeric";

  /**
   * 数値チェックのための正規表現
   */
  public static final String REGEXP_NUMERIC = "^[+-]?\\d+(\\.\\d*)?$";

  /**
   * 電文変換の型チェック指定: 日付型
   */
  public static final String TYPE_DATE = "date";

  /**
   * 日付チェックのためのフォーマット
   */
  public static final String PATTERN_DATE = "yyyy-MM-dd";

  /**
   * 電文変換の型チェック指定: 時間型
   */
  public static final String TYPE_TIME = "time";

  /**
   * 時間チェックのためのフォーマット
   */
  public static final String PATTERN_TIME = "HH:mm:ss";

  /**
   * 処理区分を切り出すためのkey属性指定値
   */
  public static final String KEY_SHORI_KUBUN = "shori_kbn";

  /**
   * ジャーナルの管理番号をResultMapから取得するための名称
   */
  public static final String KEY_JOURNAL_CTL_NO = "journal_ctl_no";

  // add 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 start
  /**
   * ジャーナルの電文種別をResultMapから取得するための名称
   */
  public static final String COOP_CD = "coop_cd";

  /**
   * ジャーナルの付帯情報（電文）をResultMapから取得するための名称
   */
  public static final String COOP_CD_INDEX = "coop_cd_index";

// add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  /**
   * ジャーナルの連携版番号をResultMapから取得するための名称
   */
  public static final String COOP_VERSION = "coop_version";
// add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
// add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  /**
   * ジャーナルの電子カルテ種別をResultMapから取得するための名称
   */
  public static final String KEY0 = "key0";
// add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

  /**
   * ジャーナルの向き（送受信）をResultMapから取得するための名称
   */
  public static final String DIRECTION = "direction";

  /**
   * ジャーナルの向き（送受信）をResultMapから取得するための名称
   */
  public static final String USER_ID = "user_id";

  /**
   * ジャーナルの電文種別をResultMapから取得するための名称
   */
  public static final String CRUD = "crud";
  // add 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 end

  /**
   * 患者IDを示すカラム名
   */
  public static final String COLUMN_PAT_ID = "pat_id";

  /**
   * CSV電文のデフォルトデリミタ
   */
  public static final char CSV_DELIM_DEFAULT = ',';

  /**
   * CSV電文のデリミタを設定するキー
   */
  public static final String CSV_DELIM_KEY = "csv.delim";

  /**
   * ジャーナル→JSON変換の設定のトップレベルキー
   */
  public static final String SETTING_TOP_KEY = "journal-converter";

  /**
   * JSON文字列において、配列を開始する記号。
   */
  public static final char JSON_START_ARRAY = '[';

  /**
   * JSON文字列において、マップを開始する記号。
   */
  public static final char JSON_START_OBJECT = '{';

  /**
   * ジャーナル連携対象テーブル名: pat_personal_main
   */
  public static final String TABLE_PAT_PERSONAL_MAIN = "pat_personal_main";

  /**
   * ジャーナル連携対象テーブル名: pat_main
   */
  public static final String TABLE_PAT_MAIN = "pat_main";

  /**
   * ジャーナル連携対象テーブル名: pat_exam_main
   */
  public static final String TABLE_PAT_EXAM_MAIN = "pat_exam_main";

  /**
   * ジャーナル連携対象テーブル名: pat_unique
   */
  public static final String TABLE_PAT_UNIQUE = "pat_unique";

  /**
   * ジャーナル連携対象テーブル名: pat_cop_detail
   */
  public static final String TABLE_PAT_COOP_DETAIL = "pat_coop_detail";

  /**
   * ジャーナル連携対象テーブル名: pat_obs_rec
   */
  public static final String TABLE_PAT_OBS_REC = "pat_obs_rec";

  /**
   * ジャーナル連携対象テーブル名: pat_insurance
   */
  public static final String TABLE_PAT_INSURANCE = "pat_insurance";

  public static final String TABLE_MST_PERSONAL_USER = "mst_personal_user";

  public static final String TABLE_MST_USER_AUTHENTICATION = "mst_user_authentication";

  public static final String TABLE_MST_USER = "mst_user";

  public static final String TABLE_ORD_MAIN = "ord_main";

  public static final String TABLE_ORD_COOP_NO = "ord_coop_no";

  /**
   * pat_insurance登録前のベンダー依存情報を表す仮カラム名
   */
  public static final String PAT_INSURANCE_TMP_COLUMN = "TMP_INS";

  /**
   * pat_insuranceテーブル、開始日のデフォルト値（start_dateカラムに設定する固定値）
   */
  public static final String PAT_INSURANCE_DEFAULT_START_DATE = "00010101";

  /**
   * pat_insuranceテーブル、終了日のデフォルト値（end_dateカラムに設定する固定値）
   */
  public static final String PAT_INSURANCE_DEFAULT_END_DATE = "99991231";

  /**
   * pat_insuranceテーブルの場合、RegisterServiceImplでの登録を抑制するフラグのキー
   */
  public static final String IS_ALREADY_REGISTERED = "registered";

  /**
   * 論理削除フラグ: オン
   */
  public static final String LOGICAL_DELETE_FLAG_ON = "1";

  /**
   * 論理削除フラグ: オフ
   */
  public static final String LOGICAL_DELETE_FLAG_OFF = "0";

  /**
   * 向き（送受信）: 受信
   */
  public static final String DIRECTION_RECEIVE = "R";

  /**
   * 向き（送受信）: 送信
   */
  public static final String DIRECTION_SEND = "S";

  /**
   * 日付フォーマット: yyyyMMdd形式
   */
  public static final String DATE_FORMAT_YYYYMMDD = "yyyyMMdd";

  /**
   * 日付の時刻(初期値)
   */
  public static final String MIDNIGHT = " 00:00:00";

  /**
   * pat_personal_mainの死亡日の特殊値: 存命
   */
  public static final String DIE_DATE_ALIVE = "0000-00-00";

  /** エンコード(UTF-8) */
  public static final String ENCODING_BY_UTF8 = "UTF-8";

  // add 2021-02-22 No.741:連携イベント作成・中止ツール 孫 start
  /** 操作番号:連携イベント作成・中止ツール */
  public static final String OPE_CD_COOP_EVENT_CREAT_OR_STOP = "900004";

  public static final Set<String> IGNORE_OPE_CDS = new HashSet<>(Arrays.asList(
      "901001", // 透析予定（新規）
      "901002", // 透析予定（削除）
      "901003", // 透析実績（新規）
      "901004", // 透析実績（削除）
      "901005", // 透析レポート（新規）
      "901006", // 透析レポート（削除）
      "901007", // 検査オーダー（新規）
      "901008", // 検査オーダー（削除）
      "901009", // 放射線オーダー（新規）
      "901010", // 放射線オーダー（削除）
      "901011", // 心電図検査オーダー（新規）
      "901012", // 心電図検査オーダー（削除）
      "901013", // 処方情報連携（新規）
      "901014", // バイタル連携（新規）
      "901015", // カルテ記載連携（新規）
      "901016", // カルテ記載連携（削除）
      "901017", // 医事連携（新規）
      "901018"  // 医事連携（削除）
  ));
  // add 2021-02-22 No.741:連携イベント作成・中止ツール 孫 end

  // add 2021-03-19 外部連携：定時一括送信機能の複数データの対応。 孫 start
  /** ステータス:有効(on) */
  public static final String STATUS_ON = "on";

  /** ステータス:無効(off) */
  public static final String STATUS_OFF = "off";

  /** 付帯情報（電文）:定時一括送信(send_time) */
  public static final String COOP_CD_INDEX_SEND_TIME = "send_time";
  // add 2021-03-19 外部連携：定時一括送信機能の複数データの対応。 孫 end

  // add 2021-03-24 No717,730：多重APIコールによる処理負荷増加回避対策 孫 start
  /** 施設ステータス:実行(start) */
  public static final String STATUS_START = "start";

  /** 施設ステータス:停止(stop) */
  public static final String STATUS_STOP = "stop";
  // add 2021-03-24 No717,730：多重APIコールによる処理負荷増加回避対策 孫 end

  // add 2021-12-03 #5888:NEC連携ができない(処方情報連携) 孫 start
  /** サブ詳細データ:レコード番号(recordNo) */
  public static final String RECORD_NO = "%%record_no%%";

  /** サブ詳細データ:上位レコード番号(upperRecordNo) */
  public static final String UPPER_RECORD_NO = "%%upper_record_no%%";
  // add 2021-12-03 #5888:NEC連携ができない(処方情報連携) 孫 end
  // 2020-05-13 #7352 #7353 profile連携（標準）の複数患者データ取り込みでエラー発生 孟堅　start
  /** 単複数患者取り込み標識 :単数患者　1　複数患者　2 **/
  public static final String PATPLURALTAG = "patpluraltag";
  /**　複数の患者情報　**/
  public static final String  PLURALPATLIST = "patplurallist";
  /**　単数患者　**/
  public static final Integer PLURALPAT = 2;
  /**　複数患者　**/
  public static final Integer ONEPAT = 1;
  // 2020-05-13 #7352 #7353 profile連携（標準）の複数患者データ取り込みでエラー発生 孟堅　end
  // add 2020-05-24 #7218  患者経過総合ビューアで手動実績作成しようとすると条件送信を実行できませんでしたと表示され実績作成ができない 孟堅 start
  /** 日時フォーマット: 2022-03-29T15:18:14.000+09:00 **/
  public static final String ZONED_DATE_TIME_ISO8601 = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX";
  // add 2020-05-24 #7218 患者経過総合ビューアで手動実績作成しようとすると条件送信を実行できませんでしたと表示され実績作成ができない  孟堅　end
  // add  #8292 exam_rst連携で受信した検査データの登録ができない 20230203 孟堅　start
  public static final String EXAMHOSPITALCD ="examHospitalCd";
  // add  #8292 exam_rst連携で受信した検査データの登録ができない 20230203 孟堅　end
 // add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 20231027  孟堅 start
  public static final String EXAMMAINCD="examMainCd";
  // add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 20231027  孟堅 end
  /**　jsonでエンコードが必要な文字正規表現**/
  public static final String  FORBIDDEN_CHAR = "[\"\\\\/\\\b\\f\\n\\r\\t]";

}
