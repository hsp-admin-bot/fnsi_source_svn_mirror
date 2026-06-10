using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Text;
using Fnw.IOControl.DB;
using Fnw.IOControl.Log;
using System.Xml.Linq;
using System.Text.RegularExpressions;
using ConvertCommon.parts;
using ConvertCommon.Const;
using ConvertCommon.dto;
using ConvertCommon.Common;
using ConvertCommon.Dto;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Collections;
using static ConvertCommon.Common.CommonConfig;
using static ConvertCommon.Common.CacheInformation;
using System.Globalization;

namespace ConvertCommon
{
    public abstract class ConvertBase
    {
        public const string IND_MEDI_INFO = "ind_medi_info";
        public const string IND_EQUIP_INFO = "ind_equip_info";
        public const string IND_IND_COMMENT_INFO = "ind_ind_comment_info";
        public const string RST_MEDI_INFO = "rst_medi_info";
        public const string RST_EQUIP_INFO = "rst_equip_info";
        public const string RST_IND_COMMENT_INFO = "rst_ind_comment_info";
        private static readonly Regex ConditionRegex =
              new Regex(@"(\s)([A-Za-z\._]*\s*=\s*'\{SERIES_CD\}')", RegexOptions.Compiled);
        public int _chunkSize;
        // Add #8111、#8109 趙 End
        /// <summary>
        /// NTSSテーブルのカラムを表す構造体
        /// </summary>
        public class NtssColumn
        {
            /// <summary>カラム名</summary>
            public string name;
            /// <summary>値</summary>
            public object value;
            /// <summary>データ型</summary>
            public string colType;
            /// <summary>バインドデータ型</summary>
            public DbBindType bindParamType;
            /// <summary>既存レコード削除キーフラグ</summary>
            public bool isDeleteKey;
            /// <summary>JSON値 
            /// 文字列展開方法１
            /// [{key1:value,key2:value},{key1:value,key2:value}]
            /// 文字列展開方法２
            /// {key1:value,key2:value}
            /// </summary>
            public List<List<JsonElement>> jsonArray;

            /// <summary>対象の列・JSON項目をSQL作成の対象にするしないを切り替えるフラグ。
            /// TRUE:作成対象にしない FALSE:作成対象にする
            /// </summary>
            public bool sqlCreationExclusionFlg;

            /// <summary>
            /// 暗号化の対象列かのフラグ
            /// TRUE:対象列である FALSE:対象列でない
            /// </summary>
            public bool encryptionFlg;
        }

        /// <summary>
        /// 処理対象テーブルの設定XML
        /// </summary>
        protected ConfigInfoDto _configInfoDto;

        /// <summary>
        /// NTSSテーブルのレコードを表す構造体
        /// </summary>
        public class NtssRecord
        {
            /// <summary>カラムリスト</summary>
            public List<NtssColumn> columns;
        }

        /// <summary>
        /// JSON要素を表すクラス
        /// </summary>
        public class JsonElement
        {
            /// <summary>キー名</summary>
            public string keyName;
            /// <summary>値</summary>
            public object value;
            /// <summary>Jsonデータフォーマット</summary>
            public JsonDataFormat jsonDataFormat;
            /// <summary>Json値の型</summary>
            public string jsonValueType;
            /// <summary>JSON要素として取得した値をSQL作成の対象にするしないを切り替えるフラグ。
            /// カスタム値変換の際、JSON要素として出力したくないが、置換変数として
            /// 使用したい場合に利用する
            /// TRUE:作成対象にしない FALSE:作成対象にする
            /// </summary>
            public bool sqlCreationExclusionFlg;

            /// <summary>
            /// DELAY_BOUND_TARGET_FLGがオンになっている項目へ設定する値として使用し、
            /// SQL出力対象にしない場合に使用するフラグ
            /// TRUE:遅延バインド変数の設定値として使用する
            /// FALSE:通常のJSON要素として使用する
            /// </summary>
            public bool delayBoundVariableFlg;

            public string getKeyNameDeleteEscape()
            {
                return keyName.Replace(@"""", "");
            }

            public string getValueDeleteEscape()
            {
                {
                    // mod #10191 djy start
                    //return value.ToString().Replace(@"""", "");
                    return value.ToString();
                    // mod #10191 djy end
                }
            }
        }

        /// <summary>コンバート失敗データ(テーブル名：{0} カラム名：{1} 値：{2})</summary>
        protected const string MSG_ERR_FAILED_DATA = "コンバート失敗データ(テーブル名：{0} カラム名：{1} 値：{2})";
        /// <summary>character varying</summary>
        protected const string NTSS_DATA_TYPE_CHARACTER_VARYING = "character varying";
        /// <summary>smallint</summary>
        protected const string NTSS_DATA_TYPE_SMALLINT = "smallint";
        /// <summary>integer</summary>
        protected const string NTSS_DATA_TYPE_INTEGER = "integer";
        /// <summary>bigint</summary>
        protected const string NTSS_DATA_TYPE_BIGINT = "bigint";
        /// <summary>numeric</summary>
        protected const string NTSS_DATA_TYPE_NUMERIC = "numeric";
        /// <summary>timestamp(3)</summary>
        protected const string NTSS_DATA_TYPE_TIMESTAMP = "timestamp(3)";
        /// <summary>jsonb</summary>
        protected const string NTSS_DATA_TYPE_JSONB = "jsonb";
        /// <summary>jsonb</summary>
        protected const string NTSS_DATA_TYPE_SERIAL = "serial";
        /// <summary>costom（埋め込みSQL）</summary>
        protected const string NTSS_DATA_TYPE_CUSTOM = "custom";
        /// <summary>character</summary>
        protected const string NTSS_DATA_TYPE_CHARACTER = "character";
        /// <summary>bigserial</summary>
        protected const string NTSS_DATA_TYPE_BIGSERIAL = "bigserial";
        /// <summary>string</summary>
        protected const string NTSS_DATA_TYPE_STRING = "string";
        /// <summary>number</summary>
        protected const string NTSS_DATA_TYPE_NUMBER = "number";
        /// <summary>inet</summary>
        protected const string NTSS_DATA_TYPE_INET = "inet";
        /// <summary>inet</summary>
        protected const string NTSS_DATA_TYPE_BOOLEAN = "boolean";
        /// <summary>inet</summary>
        protected const string NTSS_DATA_TYPE_BOOL = "bool";
        /// <summary>DBコントロール</summary>
        protected DBCtrl db;
        /// <summary>コンバート対象テーブル</summary>
        protected string convertTableName;
        /// <summary>コンバート元テーブル</summary>
        protected string fnwTableName;
        /// <summary>施設コード</summary>
        protected string facilityCd;
        /// <summary>系列施設コード</summary>
        protected string seriesCd;
        /// <summary>NTSS用施設コード</summary>
        protected string ntssFacilityCd;
        /// <summary>紐付けテーブル</summary>
        protected DataTable dtRelation;
        /// <summary>子テーブル名</summary>
        protected string childTableName;
        /// <summary>元データ取得用SQL格納フォルダパス(...\SQL\(convertTableName))</summary>
        protected string sqlDirectory;
        /// <summary>子テーブルフラグ</summary>
        protected bool isChild;
        /// <summary>コンバート元データテーブル</summary>
        protected DataTable dtFnwData;
        // add 10378-24-4 PatTreatmentPattern再構築対応 zkm start
        /// <summary>透析系コンバート元データ(key: テーブル名, value: データテーブル)</summary>
        protected Dictionary<string, DataTable> mapFnwDataPatTreatmentPattern;
        // add 10378-24-4 PatTreatmentPattern再構築対応 zkm end
        /// <summary>透析系コンバート元データ(key: テーブル名, value: データテーブル)</summary>
        protected Dictionary<string, DataTable> mapFnwDataOrd;
        /// <summary>透析系コンバート元データ(key: テーブル名, value: データテーブル)</summary>
        protected Dictionary<string, Dictionary<string, DataRow[]>> mapFnwDataOrdNew;
        /// <summary>コンバート元データ(JSON形式)(key: テーブル名, value: データテーブル)</summary>
        protected Dictionary<string, DataTable> mapFnwDataJson;
        /// <summary>コンバート元データ(マスタ)(key: テーブル名, value: データテーブル)</summary>
        protected Dictionary<string, DataTable> mapFnwDataMst;
        /// <summary>コンバート元レコード(key: 患者ID, value: レコードの配列)</summary>
        protected Dictionary<string, DataRow[]> mapFnwData;
        /// <summary>子テーブル主キー(key: 患者ID, value: 主キーのリスト)</summary>
        protected Dictionary<string, List<string>> childPrimaryKey;
        /// <summary>マスタ情報定義XML</summary>
        protected XDocument xml;
        /// <summary>紐付けテーブル名</summary>
        protected string m_relationTableName;
        //add  #6886   鄭 start
        protected ArrayList PatMongoarrayList;
        //add  #6886   鄭 end
        // 透析条件設定
        protected List<string> listBloodCircuit;
        protected List<string> listNeedleA;
        protected List<string> listNeedleV;
        protected List<string> listNeedleSN;

        // mod #11355 たくしん会】コンバートされる治療情報セットマスタの初期セットで投薬と医材に空レコードが登録されている limingyang start
        // jsonb型項目について、nullの場合、[]を転換しない
        //private List<string> listNoConvWhenNullTbl = new List<string>() { "mst_treatment_set", "ord_main", "pat_treatment_pattern" };
        private List<string> listNoConvWhenNullTbl = new List<string>() { "ord_main", "pat_treatment_pattern" };
        // mod #11355 たくしん会】コンバートされる治療情報セットマスタの初期セットで投薬と医材に空レコードが登録されている limingyang end

        // add #10671 save_2, 3, 4の値が全てnull→save_2～10で値が全てnullの場合はnull zkm start
        private List<string> listPatCoopDetailSave234 = new List<string>() { "save_2", "save_3", "save_4" };
        // add #10671 save_2, 3, 4の値が全てnull→save_2～10で値が全てnullの場合はnull zkm end

        /// <summary>
        /// 透析系コンバート元データにアクセスする際の対応するキー名
        /// （テーブル毎に違うため、定義する）
        /// </summary>
        public static Dictionary<string, string> mapTableNameToKey = new Dictionary<string, string>()
        {
            { "SCH_DIALYSIS_PLAN","IND_ID" },
            { "IND_DEVELOP_PLAN","IND_ID" },
            { "IND_DEVELOP_COND","IND_ID" },
            { "IND_DEVELOP_MEDI","IND_ID" },
            { "IND_DEVELOP_EQUIP","IND_ID" },
            { "IND_DEVELOP_ADD","IND_ID" },
            { "IND_DIALYSIS_PLAN","IND_ID" },
            { "IND_DIALYSIS_COND","IND_ID" },
            { "IND_DIALYSIS_MEDI","IND_ID" },
            { "IND_DIALYSIS_EQUIP","IND_ID" },
            { "IND_DIALYSIS_ADD","IND_ID" },
            { "PAT_DEVICE_SET","PATID" },
            { "PAT_REVISE_OFFWATER","PATID" },
            { "PAT_REVISE_TARE","PATID" },
            { "RST_DIALYSIS","DIALYSIS_NO" },
            { "RST_DIALYSIS_WEIGHT","DIALYSIS_NO" },
            { "RST_DIALYSIS_COND","DIALYSIS_NO" },
            { "RST_DIALYSIS_MEDICATION","DIALYSIS_NO" },
            { "RST_DIALYSIS_EQUIP","DIALYSIS_NO" },
            { "RST_DIALYSIS_ADDITION","DIALYSIS_NO" },
            { "RST_DIALYSIS_VITAL","DIALYSIS_NO" },
            { "RST_DIALYSIS_TARE_BEFORE","DIALYSIS_NO" },
            { "RST_DIALYSIS_TARE_AFTER","DIALYSIS_NO" },
            { "RST_DIALYSIS_WATER_REMOVE","DIALYSIS_NO" },
            { "RST_DIALYSIS_DEVICE","DIALYSIS_NO" },
            { "RST_DIALYSIS_TREATMENT","DIALYSIS_NO" },
            { "RST_DIALYSIS_COMPLAINT","DIALYSIS_NO" },
            { "RST_RECEIPT_MEMO","DIALYSIS_NO" },
            { "RST_DIALYSIS_TREAT_PERSON","DIALYSIS_NO" },
            { "PAT_LIFE_LIST","DIALYSIS_NO" },
            { "IND_DIALYSIS_UPD_INFO","IND_ID" },
            { "RST_DIALYSIS_UPD_INFO","IND_ID" }
        };

        // add FNSI-差分コンバート対応 楊 start
        /// <summary>
        /// コンバート元データにアクセスする際の対応するキー名
        /// （テーブル毎に違うため、定義する）
        /// </summary>
        public static Dictionary<string, string> mapTableToKey = new Dictionary<string, string>()
        {
            { "ord_main", "{fn_plural}{fn_pat_id}{treat_date}"},
            { "mst_addition", "{fn_add_cd}"},
            { "mst_bbs_kind", "{fn_category_id}"},
            { "mst_bed", "{fn_bed_no}"},
            { "mst_com_fixed_phrase", "{fn_addition_cd}"},
            { "mst_disease", "{fn_disease_cd}"},
            { "mst_dialysis_difficulty", "{fn_dialysis_difficulty_cd}"},
            { "mst_severity", "{fn_severity_cd}"},
            { "mst_transport", "{fn_transport_cd}"},
            { "mst_course", "{fn_course_cd}"},
            { "mst_ward", "{fn_ward_cd}"},
            { "mst_medicine_class", "{fn_class_cd}"},
            { "mst_medicine", "{fn_medicine_cd}"},
            { "mst_medicine_mix", "{fn_set_medicine_cd}"},
            { "mst_equipment_class", "{fn_class_cd}"},
            { "mst_equipment", "{fn_equipment_cd}"},
            { "mst_dialyzer", "{fn_dialyzer_cd}"},
            { "mst_taboo_allergy", "{fn_taboo_allergy_cd}"},
            { "mst_infection", "{fn_infection_cd}"},
            { "mst_treatment", "{fn_treatment_cd}"},
            { "mst_va", "{fn_va_cd}"},
            { "mst_procedure", "{fn_procedure_cd}"},
            { "mst_medicate_timing", "{fn_medicate_timing_cd}"},
            { "mst_kur", "{fn_kur_cd}"},
            { "mst_machine", "{fn_device_no}{fn_class_cd}"},
            { "mst_room_bed_group", "{fn_room_bed_group_no}{group_class}"},
            { "mst_job", "{fn_job_class_cd}"},
            { "mst_complaint", "{fn_complaint_cd}"},
            { "mst_comp_treatment", "{fn_comp_treatment_cd}"},
            { "mst_take_medicine", "{list_class}"},
            { "mst_water_survey_point", "{fn_survey_point_cd}"},
            { "mst_water_survey_type", "{fn_survey_type_cd}"},
            { "mst_personal_user", "{fn_staff_cd}"},
            { "mst_wheel_chair", "{fn_wheel_chair_cd}"},
            { "mst_exam_item", "{fn_exam_item_cd}"},
            { "mst_exam_set", "{fn_exam_set_cd}"},
            { "mst_rad_set", "{fn_exam_set_cd}"},
            { "mst_spitz", "{fn_exam_set_cd}"},
            { "mst_pat_event_category", "{fn_event_category_cd_1}"},
            { "mst_pat_event_sub_category", "{fn_event_category_cd_2}{fn_event_category_class}"},
            { "mst_obs_kind", "{fn_kind_id}"},
            { "mst_user_authentication", "{user_id}"},
            { "mst_user", "{user_id}"},
            { "mst_device_set_info_default", "{facility_cd}"},
            { "mst_weight_scale", "{facility_cd}"},
            { "mst_weight", "{weight_no}"},
            // mod #12230 差分コンバートにより元に戻ってしまう項目がある limingzhe start
            //{ "mst_comsv_setting", "{facility_cd}"},
            { "mst_comsv_setting", "{fn_comsv_no}"},
            // mod #12230 差分コンバートにより元に戻ってしまう項目がある limingzhe end
            { "mst_checklist", "{facility_cd}"},
            { "pat_personal_main", "{fn_pat_id}"},
            { "pat_unique", "{pat_id}"},
            { "pat_main", "{pat_id}"},
            { "bbs_info", "{fn_seq_id}{is_disp_bbs}"},
            { "pat_event", "{pat_id}{fn_ctl_no}"},
            { "pat_obs_rec", "{fn_seq_id}"},
            { "mni_monitor", "{ord_no}"},
            { "ord_checklist", "{ord_no}"},
            { "pat_rad_main", "{fn_pat_id}{reg_rad_date}"},
            { "pat_exam_main", "{fn_pat_id}{reg_exam_date}{exam_status}{reg_order_class}"},
            { "pat_treatment_pattern", "{pat_id}"},
            { "mst_medicine_group", "{fn_medicine_group_cd}"},
            { "ord_exception_period", "{facility_cd}"},
            { "ord_material_save", "{pat_id}"},
            { "mst_medicine_support", "{fn_medicine_support_cd}"},
            { "mst_pat_viewer_layout", "{fn_layout_cd}"},
            //mod 11576 pat_coop_detailのsave_1がGX固定でコンバートされる start
            { "pat_coop_detail", "{ord_no}{pat_id}"},
            //mod 11576 pat_coop_detailのsave_1がGX固定でコンバートされる end
            { "sys_coop_no", "{cur_coop_ord_no}"},
            { "ord_prescription", "{fn_ord_prescription_no}"},
            { "ord_personal_prescription", "{fn_ord_prescription_no}"},
            { "pat_ind_approve", "{pat_id}{treat_date}{plural}"},
            { "pat_ind_approve_history", "{pat_id}{treat_date}{plural}"},
            { "mst_vital_graph", "{fn_vital_graph_cd}"},
            { "mst_treatment_set", "{treatment_set_name}{facility_cd}"},
            { "mst_treatment_status_layout", "{fn_layout_no}"},
            { "pat_insurance", "{fn_pat_id}{fn_ctl_no}"},
            { "mst_self_measure_result", "{fn_self_measure_result_cd}"},
            { "mst_monitor_graph", "{fn_monitor_graph_cd}"},
            { "pat_group", "{fn_pat_group_cd}"},
            { "pat_group_detail", "{pat_group_cd}{pat_id}"},
            { "mst_holiday", "{facility_cd}{holiday_y}{class}"},
            { "mst_add_monitor", "{facility_cd}{fn_vital_monitor_item_cd}"},
            { "mst_trend_graph_template", "{fn_template_cd}"},
            { "mst_facility_setting", "{facility_setting_no}"},
            { "mst_pat_event_data_template", "{fn_template_cd}"},
            { "mnt_water_survey", "{facility_cd}{inspection_date}"},
            { "mst_machine_record_control", "{machine_record_cd}" },
            { "mst_graph_setting", "{facility_cd}{graph_setting_no}"},
            { "mnt_mainte_main", "{facility_cd}{mainte_class}{machine_no}{fn_checkplan_no}"},
            { "mst_mainte_detail", "{facility_cd}{fn_mainte_detail_cd}"},
            { "mst_mainte_category", "{facility_cd}{fn_mainte_category_cd}"},
            { "mst_trend_graph_monitor_set", "{facility_cd}{model}{fn_monitor_set_cd}"},
            { "medicine_latest_no", "{pat_id}"},

        };
        // add FNSI-差分コンバート対応 楊 end


        // add #10153 djy start
        /// <summary>
        /// CSV_TABLES
        /// </summary>
        public static List<string> CSV_TABLES = new List<string>
        {
            "mni_monitor",
            "ord_checklist",
            "ord_treat_condition",
            "ord_coop_no",
            //"ord_weight_scale",
            "pat_unique_history",
            "mnt_motion_record",
            "pat_exam_main",
            //add #12173 start
            "mst_favorite_facility"
            //add #12173 end
        };
        // add #10153 djy end

        // add #10191 djy start
        /// <summary>
        /// SQL_DATA:SQLファイルのデータにアウトポート
        /// CSV_DATA:CSVファイルのデータにアウトポート
        /// CSV_JSON_DATA:CSVファイルのjsonデータにアウトポート
        /// BR_NEWLINE_DATA:改行はbrのデータに転換
        /// P_TAG_NEWLINE_DATA:改行はpタグのデータに転換
        /// WIN_NEWLINE_DATA:改行は\r\nのデータに転換
        /// </summary>
        public enum ConvertValueType
        {
            SQL_DATA = 0,
            CSV_DATA = 1,
            CSV_JSON_DATA = 2,
            BR_NEWLINE_DATA = 3,
            P_TAG_NEWLINE_DATA = 4,
            //add #10291 djy start
            WIN_NEWLINE_DATA = 5
            //add #10291 djy end

        }

        /// <summary>
        /// SQL_STRING:SQL中の文字列（''が付き）
        /// NORMAL_STRING:通常文字列（''が付かない）
        /// ENCRYPT_STRING:暗号化の文字列が必要
        /// </summary>
        public enum SpecialColumnType
        {
            SQL_STRING = 0,
            NORMAL_STRING = 1,
            ENCRYPT_STRING = 2
        }
        // add #10191 djy end

        /// <summary>
        /// Postgresql日付登録用フォーマット
        /// </summary>
        protected const string NTSS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
        /// <summary>
        /// NTSS登録日付列名
        /// </summary>
        protected const string NTSS_COLUMN_NAME_TOUROKU_HIDUKE = "reg_date";
        /// <summary>
        /// NTSS更新日付列名
        /// </summary>
        protected const string NTSS_COLUMN_NAME_KOUSHIN_HIDUKE = "up_date";
        /// <summary>
        /// 施設コードの列が無いテーブル名のリスト
        /// </summary>
        protected List<string> _NoFacilityCdTableNameList;

        /// <summary>
        /// Jsonデータフォーマット
        /// 1:値の配列
        /// 2:配列なし
        /// 3:JSONの配列
        /// 4:入れ子
        /// </summary>
        public enum JsonDataFormat
        {
            ValueArray = 1,
            JsonNoArray = 2,
            JsonArray = 3,
            JsonNest = 4,
            //add 7271  zc start
            JsonManyArray = 5,
            //add 7271  zc end
            //add 12029  zc start
            JsonDisItemInfo = 6
            //add 12029  zc end
        }

        // 数値型をまとめた配列
        public static string[] NumericType = new string[] { NTSS_DATA_TYPE_SMALLINT,
                                                        NTSS_DATA_TYPE_INTEGER,
                                                        NTSS_DATA_TYPE_BIGINT,
                                                        NTSS_DATA_TYPE_NUMERIC};


        //#12539 ツールから直接postgresqlに接続する必要がないため削除すること start
        public enum DbBindType
        {
            Bigint,
            Varchar,
            Smallint,
            Integer,
            Numeric,
            Timestamp,
            Json,
            Char,
            Inet
        }

        public static Dictionary<string, DbBindType> mapDbBindParamDataType =
            new Dictionary<string, DbBindType>()
        {
            { NTSS_DATA_TYPE_BIGSERIAL, DbBindType.Bigint },
            { NTSS_DATA_TYPE_CHARACTER_VARYING, DbBindType.Varchar },
            { NTSS_DATA_TYPE_SMALLINT, DbBindType.Smallint },
            { NTSS_DATA_TYPE_INTEGER, DbBindType.Integer },
            { NTSS_DATA_TYPE_BIGINT, DbBindType.Bigint },
            { NTSS_DATA_TYPE_NUMERIC, DbBindType.Numeric },
            { NTSS_DATA_TYPE_TIMESTAMP, DbBindType.Timestamp },
            { NTSS_DATA_TYPE_JSONB, DbBindType.Json },
            { NTSS_DATA_TYPE_CHARACTER, DbBindType.Char },
            { NTSS_DATA_TYPE_INET, DbBindType.Inet }
        };
        //#12539 ツールから直接postgresqlに接続する必要がないため削除すること end
        /// <summary>
        /// 子テーブル主キー
        /// </summary>
        public Dictionary<string, List<string>> ChildPrimaryKey
        {
            get { return childPrimaryKey; }
            set { childPrimaryKey = value; }
        }

        /// <summary>
        /// マスタ
        /// </summary>
        public Dictionary<string, DataTable> MapFnwDataMst
        {
            set { mapFnwDataMst = value; }
        }

        //add  #6886 鄭  start
        /// <summary>
        /// 患者情报（Mongo）初期化処理  鄭 
        /// </summary>
        /// <param name="db">DBコントロール</param>
        /// <param name="facilityCd">施設コード</param>
        /// <param name="convertTableName">コンバート先テーブル名</param>
        /// <remarks>
        /// 各テーブルのコンバート処理開始時に呼び出し、データの初期化と紐付けテーブルの取得を行う
        /// </remarks>
        /// <returns>成功：true、失敗：false</returns>
        public bool PatMonGoInit(DBCtrl db, string facilityCd, string convertTableName, string sqlRootDirectory)
        {
            WriteTraceLog("===== 初期化処理開始 =====");

            this.db = db;
            this.facilityCd = facilityCd;
            this.convertTableName = convertTableName;
            this.sqlDirectory = Path.Combine(sqlRootDirectory, convertTableName);

            int pos = convertTableName.IndexOf("-");
            if (pos > -1)
            {
                this.convertTableName = convertTableName.Substring(pos + 1);
                this.fnwTableName = convertTableName.Substring(0, pos);
            }

            if (db != null)
            {
                // FNW接続が行われる場合(コンバートまたはエクスポート時)
                dtFnwData = new DataTable();
                mapFnwDataOrd = new Dictionary<string, DataTable>();
                // add 10378-24-4 PatTreatmentPattern再構築対応 zkm start
                mapFnwDataPatTreatmentPattern = new Dictionary<string, DataTable>();
                // add 10378-24-4 PatTreatmentPattern再構築対応 zkm end
                mapFnwDataJson = new Dictionary<string, DataTable>();
                mapFnwDataMst = new Dictionary<string, DataTable>();
                mapFnwData = new Dictionary<string, DataRow[]>();

            }

            listBloodCircuit = CommonConfig.Boold[CommonConfig.seriesCd];
            listNeedleA = CommonConfig.p_A[CommonConfig.seriesCd];
            listNeedleV = CommonConfig.p_V[CommonConfig.seriesCd];
            listNeedleSN = CommonConfig.p_SN[CommonConfig.seriesCd];

            WriteTraceLog("===== 初期化処理完了 =====");
            return true;
        }
        //add   #6886 鄭  end
        #region メソッド

        /// <summary>
        /// 初期化処理
        /// </summary>
        /// <param name="db">DBコントロール</param>
        /// <param name="facilityCd">施設コード</param>
        /// <param name="convertTableName">コンバート先テーブル名</param>
        /// <remarks>
        /// 各テーブルのコンバート処理開始時に呼び出し、データの初期化と紐付けテーブルの取得を行う
        /// </remarks>
        /// <returns>成功：true、失敗：false</returns>
        public bool Init(DBCtrl db, string facilityCd, string convertTableName, string sqlRootDirectory)
        {
            WriteTraceLog("===== 初期化処理開始 =====");

            this.db = db;
            this.facilityCd = facilityCd;
            this.convertTableName = convertTableName;
            this.sqlDirectory = Path.Combine(sqlRootDirectory, convertTableName);
            if (!Directory.Exists(sqlDirectory))
            {
                // フォルダなし
                WriteErrorLog("コンバート元データ取得用SQLフォルダが存在しません。(フォルダ：{0})", sqlDirectory);
                return false;
            }
            // fnwTableName-ntssTableNameの形式の場合、分解してクラス変数に設定する
            int pos = convertTableName.IndexOf("-");
            if (pos > -1)
            {
                this.convertTableName = convertTableName.Substring(pos + 1);
                this.fnwTableName = convertTableName.Substring(0, pos);
            }

            if (db != null)
            {
                // FNW接続が行われる場合(コンバートまたはエクスポート時)
                dtFnwData = new DataTable();
                mapFnwDataOrd = new Dictionary<string, DataTable>();
                // add 10378-24-4 PatTreatmentPattern再構築対応 zkm start
                mapFnwDataPatTreatmentPattern = new Dictionary<string, DataTable>();
                // add 10378-24-4 PatTreatmentPattern再構築対応 zkm end
                mapFnwDataJson = new Dictionary<string, DataTable>();
                mapFnwDataMst = new Dictionary<string, DataTable>();
                mapFnwData = new Dictionary<string, DataRow[]>();

                dtRelation = GetRelationTable();
                if (dtRelation == null)
                {
                    return false;
                }
            }

            listBloodCircuit = CommonConfig.Boold[CommonConfig.seriesCd];
            listNeedleA = CommonConfig.p_A[CommonConfig.seriesCd];
            listNeedleV = CommonConfig.p_V[CommonConfig.seriesCd];
            listNeedleSN = CommonConfig.p_SN[CommonConfig.seriesCd];

            WriteTraceLog("===== 初期化処理完了 =====");
            return true;
        }

        /// <summary>
        /// 初期化処理(マスタ用)
        /// </summary>
        /// <param name="db">DBコントロール</param>
        /// <param name="facilityCd">施設コード</param>
        /// <param name="seriesCd">系列施設コード</param>
        /// <param name="dto">テーブル情報（移行元FNWテーブル名、移行先次世代FNWテーブル名）</param>
        /// <remarks>
        /// 各テーブルのコンバート処理開始時に呼び出し、データの初期化と紐付けテーブルの取得を行う
        /// </remarks>
        /// <returns>成功：true、失敗：false</returns>
        public bool InitForMst(DBCtrl db, string facilityCd, string seriesCd, DgvPatRowDto dto, XDocument xml, DataTable dtRelation)
        {
            this.fnwTableName = dto.fnwTableName;
            return InitForMst(db, facilityCd, seriesCd, dto.ntssTableName, xml, dtRelation);
        }

        /// <summary>
        /// 初期化処理(マスタ用)
        /// </summary>
        /// <param name="db">DBコントロール</param>
        /// <param name="facilityCd">施設コード</param>
        /// <param name="seriesCd">系列施設コード</param>
        /// <param name="convertTableName">コンバート先テーブル名</param>
        /// <remarks>
        /// 各テーブルのコンバート処理開始時に呼び出し、データの初期化と紐付けテーブルの取得を行う
        /// </remarks>
        /// <returns>成功：true、失敗：false</returns>
        public bool InitForMst(DBCtrl db, string facilityCd, string seriesCd, string convertTableName, XDocument xml, DataTable dtRelation)
        {
            this.db = db;
            this.facilityCd = facilityCd;
            this.seriesCd = seriesCd;
            this.convertTableName = convertTableName;
            this.xml = xml;
            this.dtRelation = dtRelation;
            dtFnwData = new DataTable();
            mapFnwDataJson = new Dictionary<string, DataTable>();

            return true;
        }

        /// <summary>
        /// 紐付けテーブル取得
        /// </summary>
        /// <returns>成功：紐付けテーブル、失敗：null</returns>
        protected DataTable GetRelationTable()
        {
            string ntssTableName;
            int pos = convertTableName.IndexOf("-");
            if (pos > -1)
            {
                ntssTableName = convertTableName.Substring(pos + 1);
            }
            else
            {
                ntssTableName = convertTableName;
            }

            var dt = ConvertTss.Get(ntssTableName);

            if (dt == null)
            {
                // 紐付けテーブルなし
                WriteErrorLog("{0}に対応する紐付けテーブルが存在しません。", convertTableName);
                return null;
            }
            else if (dt.Rows.Count == 0)
            {
                // 紐付けレコードなし
                WriteErrorLog("{0}に対応する紐付けテーブルに紐付け情報が存在しません。", convertTableName);
                return null;
            }
            dt.TableName = m_relationTableName;
            return dt;
        }

        protected bool IsIgonreColumn(string fnwTableName, string fnwColName)
        {
            var isIgnore = false;
            if (fnwColName == "SERIES_CD")
            {
                // 系列施設コードはどのテーブルだろうが不要(のはず)
                isIgnore = true;
            }
            else if (fnwTableName == ConvertControl.FNW_TABLE_SCH_DIALYSIS_PLAN)
            {
                switch (fnwColName)
                {
                    case "IND_ID":
                    case "RESULT_DIALYSISNO":
                        isIgnore = true;
                        break;
                }
            }
            else if (fnwTableName == ConvertControl.FNW_TABLE_IND_DEVELOP_PLAN)
            {
                switch (fnwColName)
                {
                    case "IND_ID":
                        isIgnore = true;
                        break;
                }
            }
            else if (fnwTableName == ConvertControl.FNW_TABLE_IND_DEVELOP_COND)
            {
                switch (fnwColName)
                {
                    case "IND_ID":
                        isIgnore = true;
                        break;
                }
            }
            else if (fnwTableName == ConvertControl.FNW_TABLE_IND_DEVELOP_MEDI)
            {
                switch (fnwColName)
                {
                    case "IND_ID":
                        isIgnore = true;
                        break;
                }
            }
            else if (fnwTableName == ConvertControl.FNW_TABLE_IND_DEVELOP_EQUIP)
            {
                switch (fnwColName)
                {
                    case "IND_ID":
                        isIgnore = true;
                        break;
                }
            }
            else if (fnwTableName == ConvertControl.FNW_TABLE_IND_DEVELOP_ADD)
            {
                switch (fnwColName)
                {
                    case "IND_ID":
                        isIgnore = true;
                        break;
                }
            }
            else if (fnwTableName == ConvertControl.FNW_TABLE_RST_DIALYSIS)
            {
                switch (fnwColName)
                {
                    // DIALYSIS_NOは予定に紐付く実績、または手動実績の場合で個別に加工するためスルー
                    case "DIALYSIS_NO":
                        isIgnore = true;
                        break;
                }
            }
            else if (fnwTableName == ConvertControl.FNW_TABLE_RST_DIALYSIS_WEIGHT)
            {
                switch (fnwColName)
                {
                    case "DIALYSIS_NO":
                        isIgnore = true;
                        break;
                }
            }
            else if (fnwTableName == ConvertControl.FNW_TABLE_RST_DIALYSIS_COND)
            {
                switch (fnwColName)
                {
                    case "DIALYSIS_NO":
                        isIgnore = true;
                        break;
                }
            }
            else if (fnwTableName == ConvertControl.FNW_TABLE_RST_RECEIPT_MEMO)
            {
                switch (fnwColName)
                {
                    case "DIALYSIS_NO":
                        isIgnore = true;
                        break;
                }
            }
            else if (fnwTableName == ConvertControl.FNW_TABLE_RST_DIALYSIS_MEDICATION)
            {
                switch (fnwColName)
                {
                    case "DIALYSIS_NO":
                        isIgnore = true;
                        break;
                }
            }
            else if (fnwTableName == ConvertControl.FNW_TABLE_RST_DIALYSIS_EQUIP)
            {
                switch (fnwColName)
                {
                    case "DIALYSIS_NO":
                        isIgnore = true;
                        break;
                }
            }
            else if (fnwTableName == ConvertControl.FNW_TABLE_RST_DIALYSIS_ADDITION)
            {
                switch (fnwColName)
                {
                    case "DIALYSIS_NO":
                        isIgnore = true;
                        break;
                }
            }
            else if (fnwTableName == "MST_MEDICINE")
            {
                switch (fnwColName)
                {
                    case "SET_MEDICINE_CD":
                        isIgnore = true;
                        break;
                }
            }
            else if (fnwTableName == ConvertControl.FNW_TABLE_RST_DIALYSIS_TREATMENT)
            {
                switch (fnwColName)
                {
                    case "DIALYSIS_NO":
                        isIgnore = true;
                        break;
                }
            }
            else if (fnwTableName == ConvertControl.FNW_TABLE_RST_DIALYSIS_COMPLAINT)
            {
                switch (fnwColName)
                {
                    case "DIALYSIS_NO":
                        isIgnore = true;
                        break;
                }
            }
            else if (fnwTableName == ConvertControl.FNW_TABLE_RST_DIALYSIS_TREAT_PERSON)
            {
                switch (fnwColName)
                {
                    case "DIALYSIS_NO":
                        isIgnore = true;
                        break;
                }
            }
            return isIgnore;
        }

        /// <summary>
        /// 指定した元テーブル名とカラム名に対応する紐付け情報を取得
        /// </summary>
        /// <param name="fnwTableName">元テーブル名</param>
        /// <param name="fnwColName">元カラム名</param>
        /// <remarks>
        /// 元テーブル名と元カラム名の指定で一意に紐付く場合はこちらを使用
        /// </remarks>
        /// <returns>紐付け情報(失敗時はnull)</returns>
        protected DataRow GetRelation(string fnwTableName, string fnwColName)
        {
            return GetRelation(fnwTableName, fnwColName, null);
        }

        /// <summary>
        /// 指定した元テーブル名とカラム名に対応する紐付け情報を取得
        /// </summary>
        /// <param name="xmlConfigName">検索するXMLConfigName</param>
        /// <param name="fnwColumnName">元カラム名</param>
        /// <param name="ntssColNo">コンバート先カラムNo.</param>
        /// <remarks>
        /// 元テーブル名と元カラム名の指定で一意に紐付かない場合はこちらを使用
        /// (コンバート先カラムNo.を与えて一意に紐付ける)
        /// </remarks>
        /// <returns>紐付けレコード(失敗時はnull)</returns>
        public virtual DataRow GetRelation(string xmlConfigName, string fnwColName, string ntssColNo)
        {
            //var str = string.Format("FNW_TABLE_NAME = '{0}' AND FNW_COLUMN_NAME = '{1}' AND NTSS_TABLE_NAME = '{2}'", fnwTableName, fnwColName, this.convertTableName);
            /*var str = string.Format("XML_CONFIG_NAME = '{0}' AND FNW_COLUMN_NAME = '{1}' AND NTSS_TABLE_NAME = '{2}'", xmlConfigName, fnwColName, this.convertTableName);
            if (string.IsNullOrEmpty(ntssColNo) == false)
            {
                // ntssColNoが指定された場合は条件を追加
                str += string.Format(" AND NTSS_COLUMN_NO = '{0}'", ntssColNo);
            }
            */
            var relation = this.dtRelation.AsEnumerable().Where(row => row.Field<string>("XML_CONFIG_NAME") == xmlConfigName
                                                            && row.Field<string>("FNW_COLUMN_NAME") == fnwColName
                                                            && row.Field<string>("NTSS_TABLE_NAME") == this.convertTableName
                                                            && (!string.IsNullOrEmpty(ntssColNo) ? row.Field<string>("NTSS_COLUMN_NO") == ntssColNo : true)).ToArray();
            //DataView dv = new DataView(this.dtRelation);
            //var relation = dv.ToTable(true, new string[] { "FNW_TABLE_NAME", "FNW_COLUMN_NAME", "NTSS_TABLE_NAME", "NTSS_COLUMN_NO", "NTSS_COLUMN_NAME", "NTSS_COLUMN_TYPE", "JSON_KEY", "JSON_VALUE_TYPE", "JSON_DATA_FORMAT", "PK_FLG" }).Select(str);
            //var relation = dv.ToTable(true, new string[] { "*" }).Select(str);
            if (relation.Length == 1)
            {
                return relation[0];
            }
            else if (relation.Length > 1)
            {
                // FNWのカラム１に対して紐付け先のNTSSのカラムが２以上ある場合に対応していないため、
                // エラーにしない。
                return relation[0];
            }
            else
            {
                // 紐付けレコードが存在しない場合はエラー
                //WriteErrorLog("紐付けテーブル情報取得に失敗しました。(紐付けテーブル：{0} 元テーブル名：{1} 元カラム名：{2})", dtRelation.TableName, fnwTableName, fnwColName);
                // 紐付けレコードが存在しない場合はエラーにせず次のレコードへ処理を移す
                return null;
            }
        }

        /// <summary>
        /// 指定した元テーブル名とカラム名に対応する紐付け情報を配列で取得
        /// </summary>
        /// <param name="xmlConfigName">検索するXMLConfigName</param>
        /// <param name="fnwColumnName">元カラム名</param>
        /// <param name="ntssColNo">コンバート先カラムNo.</param>
        /// <remarks>
        /// </remarks>
        /// <returns>紐付けレコード(失敗時はnull)</returns>
        public virtual DataRow[] GetRelationArray(string xmlConfigName, string fnwColName, string ntssColNo)
        {
            /*
            var str = string.Format("FNW_TABLE_NAME = '{0}' AND FNW_COLUMN_NAME = '{1}' AND NTSS_TABLE_NAME = '{2}'", fnwTableName, fnwColName, this.convertTableName);
            if (string.IsNullOrEmpty(ntssColNo) == false)
            {
                // ntssColNoが指定された場合は条件を追加
                str += string.Format(" AND NTSS_COLUMN_NO = '{0}'", ntssColNo);
            }
            // 重複レコードを除外
            DataView dv = new DataView(this.dtRelation);
            var relation = dv.ToTable(true, new string[] { "FNW_TABLE_NAME", "FNW_COLUMN_NAME", "NTSS_TABLE_NAME", "NTSS_COLUMN_NO", "NTSS_COLUMN_NAME", "NTSS_COLUMN_TYPE", "JSON_KEY", "JSON_VALUE_TYPE", "JSON_DATA_FORMAT" ,"PK_FLG" }).Select(str);
             * */
            var relation = this.dtRelation.AsEnumerable().Where(row => row.Field<string>("XML_CONFIG_NAME") == xmlConfigName
                                                            && row.Field<string>("FNW_COLUMN_NAME") == fnwColName
                                                            && row.Field<string>("NTSS_TABLE_NAME") == this.convertTableName
                                                            && (!string.IsNullOrEmpty(ntssColNo) ? row.Field<string>("NTSS_COLUMN_NO") == ntssColNo : true)).ToArray();
            return relation;
        }

        /// <summary>
        /// 指定したNTSSのテーブル名とカラム名に対応する紐付け情報を配列で取得
        /// （検索条件にNTSSのカラム名を使用、JSONB型の情報のみ取得）
        /// </summary>
        /// <param name="ntssTableName">紐付け先のNTSSテーブル名</param>
        /// <param name="ntssColName">紐付け先のNTSSカラム名</param>
        /// <remarks>
        /// </remarks>
        /// <returns>紐付けレコード(失敗時はnull)</returns>
        public virtual DataRow[] GetRelationArrayByNtssInfo(string ntssTableName, string ntssColName)
        {
            var relation = this.dtRelation.AsEnumerable().Where(row => row.Field<string>("NTSS_COLUMN_NAME") == ntssColName
                                                            && row.Field<string>("NTSS_TABLE_NAME") == ntssTableName
                                                            && row.Field<string>("NTSS_COLUMN_TYPE") == NTSS_DATA_TYPE_JSONB
                                                            ).ToArray();
            return relation;
        }

        /// <summary>
        /// 指定したNTSSのテーブル名とカラム名に対応する紐付け情報を配列で取得
        /// （検索条件にNTSSのカラム名を使用、JSONB型の情報のみ取得）
        /// </summary>
        /// <param name="ntssTableName">紐付け先のNTSSテーブル名</param>
        /// <param name="ntssColName">紐付け先のNTSSカラム名</param>
        /// <remarks>
        /// </remarks>
        /// <returns>紐付けレコード(失敗時はnull)</returns>
        public virtual DataRow[] GetRelationArrayByFnwTableNtssInfo(string fnwTableName, string ntssTableName, string ntssColName)
        {
            var relation = this.dtRelation.AsEnumerable().Where(row => row.Field<string>("NTSS_COLUMN_NAME") == ntssColName
                                                            && row.Field<string>("NTSS_TABLE_NAME") == ntssTableName
                                                            && row.Field<string>("FNW_TABLE_NAME") == fnwTableName
                                                            && row.Field<string>("NTSS_COLUMN_TYPE") == NTSS_DATA_TYPE_JSONB
                                                            ).ToArray();
            return relation;
        }

        /// <summary>
        /// 指定したNTSSのテーブル名とカラム名に対応する紐付け情報を配列で取得
        /// （検索条件にNTSSのカラム名を使用、JSONB型の情報のみ取得）
        /// </summary>
        /// <param name="ntssTableName">紐付け先のNTSSテーブル名</param>
        /// <param name="ntssColName">紐付け先のNTSSカラム名</param>
        /// <remarks>
        /// </remarks>
        /// <returns>紐付けレコード(失敗時はnull)</returns>
        public virtual DataRow GetRelationByFnwInfoNtssInfo(string fnwTableName, string fnwColName, string ntssTableName, string ntssColName)
        {
            var relation = this.dtRelation.AsEnumerable().Where(row => row.Field<string>("NTSS_COLUMN_NAME") == ntssColName
                                                            && row.Field<string>("NTSS_TABLE_NAME") == ntssTableName
                                                            && row.Field<string>("FNW_TABLE_NAME") == fnwTableName
                                                            && row.Field<string>("FNW_COLUMN_NAME") == fnwColName
                                                            && row.Field<string>("NTSS_COLUMN_TYPE") == NTSS_DATA_TYPE_JSONB
                                                            ).FirstOrDefault();
            return relation;
        }

        /// <summary>
        /// NTSSカラムを作成
        /// </summary>
        /// <param name="ntssColName">コンバート先カラム名</param>
        /// <param name="ntssColType">コンバート先カラムのデータ型</param>
        /// <param name="value">値</param>
        /// <param name="isDeleteKey">既存レコード削除時にキーとなるかどうかのフラグ</param>
        /// <returns>NTSSカラム(失敗時はvalueがnull)</returns>
        protected NtssColumn CreateNtssColumn(string ntssColName, string ntssColType, string value, bool isDeleteKey)
        {
            var ntss = new NtssColumn();
            ntss.name = ntssColName;
            ntss.colType = ntssColType;
            ntss.bindParamType = mapDbBindParamDataType[ntssColType];
            ntss.isDeleteKey = isDeleteKey;
            // データ型変換
            ConvertDataType(value, ntssColType, ref ntss.value);

            if (ntss.value == null)
            {
                WriteErrorLog("コンバートデータの型変換に失敗しました。");
            }
            return ntss;
        }

        protected NtssColumn CreateNtssColumnNoConvert(string ntssColName, string ntssColType, string value, bool isDeleteKey)
        {
            var ntss = CreateNtssColumn(ntssColName, ntssColType, value, isDeleteKey);
            ntss.sqlCreationExclusionFlg = true;
            return ntss;
        }

        /// <summary>
        /// NTSSカラムを作成
        /// </summary>
        /// <param name="relation">紐付けデータ</param>
        /// <param name="value">値</param>
        /// <returns>NTSSカラム(失敗時はvalueがnull)</returns>
        protected NtssColumn CreateNtssColumn(DataRow relation, string value)
        {
            var ntss = new NtssColumn();
            ntss.name = relation["NTSS_COLUMN_NAME"].ToString();
            ntss.colType = relation["NTSS_COLUMN_TYPE"].ToString();
            ntss.bindParamType = mapDbBindParamDataType[ntss.colType];
            ntss.isDeleteKey = relation["PK_FLG"].ToString() == "1";
            ntss.sqlCreationExclusionFlg = relation["SQL_CREATION_EXCLUSION_FLG"].ToString().Equals("1");
            ntss.encryptionFlg = relation["ENCRYPTION_FLG"].ToString().Equals("1");
            //add  7271  zc start
            if (relation["NTSS_COLUMN_NAME"].ToString().Equals("remarks_free"))
            {
                // mod #10191 djy start
                ntss.value = SpecialDataFormat(value, ConvertValueType.SQL_DATA);
                // mod #10191 djy end
                return ntss;
            }
            //add  7271  zc end
            //add  8332  zc start
            if ((relation["NTSS_COLUMN_NAME"].ToString().Contains("detail") || relation["NTSS_COLUMN_NAME"].ToString().Contains("result_value_1")) && convertTableName.Equals("pat_event"))
            {
                // mod #10191 djy start
                ntss.value = SpecialDataFormat(value, ConvertValueType.P_TAG_NEWLINE_DATA);
                // mod #10191 djy end
                return ntss;
            }
            //add  8332  zc end
            //add  7407  zc start
            if (relation["NTSS_COLUMN_NAME"].ToString().Equals("contents"))
            {
                ntss.value = value;
                return ntss;
            }
            //add  7407  zc end

            //add #10291 djy start
            if (relation["NTSS_COLUMN_NAME"].ToString().Equals("list_details") && convertTableName.Equals("mst_take_medicine"))
            {
                ntss.value = SpecialDataFormat(value, ConvertValueType.WIN_NEWLINE_DATA);
                return ntss;
            }
            //add #10291 djy end

            //add #10739 zc end
            if (relation["NTSS_COLUMN_NAME"].ToString().Equals("check_content") && convertTableName.Equals("pat_ind_approve"))
            {
                ntss.value = value;
                return ntss;
            }
            //add #10739 zc end
            // データ型変換
            ConvertDataType(value, ntss.colType, ref ntss.value);

            if (ntss.value == null)
            {
                WriteErrorLog("コンバートデータの型変換に失敗しました。");
            }
            return ntss;
        }

        /// <summary>
        /// NTSSカラムを作成（JSON項目用）
        /// </summary>
        /// <param name="ntssColName">コンバート先カラム名</param>
        /// <param name="ntssColType">コンバート先カラムのデータ型</param>
        /// <param name="jsonElementListLists">Json項目のリストのリスト</param>
        /// <param name="isDeleteKey">既存レコード削除時にキーとなるかどうかのフラグ</param>
        /// <returns>NTSSカラム(失敗時はvalueがnull)</returns>
        protected NtssColumn CreateNtssColumnForJson(string ntssColName, string ntssColType, List<List<JsonElement>> jsonElementListLists, bool isDeleteKey)
        {
            var ntss = new NtssColumn();
            ntss.name = ntssColName;
            ntss.colType = ntssColType;
            ntss.bindParamType = mapDbBindParamDataType[ntssColType];
            ntss.isDeleteKey = isDeleteKey;
            ntss.jsonArray = jsonElementListLists;
            return ntss;
        }

        protected string GetXmlElementValue(string elementName)
        {
            // 対象テーブルの要素を取得
            List<XElement> elementList = xml.Element("rootNode").Elements("tableInfo").Where(element => element.Element("ntssTableName").Value.Equals(convertTableName)).ToList();
            XElement targetElement;
            if (elementList.Count >= 2)
            {
                // ２件以上ある場合は移行元テーブルで絞り込みを行う
                targetElement = elementList.Where(x => x.Element("fnwTableName").Value.Equals(fnwTableName)).FirstOrDefault();
            }
            else
            {
                targetElement = elementList[0];
            }

            return GetXmlElementValue(targetElement, elementName);
        }

        protected string GetXmlElementValue(XElement xml, string elementName)
        {
            // 要素の値を取得
            string value = null;
            var targetElement = xml.Element(elementName);
            if (targetElement != null)
            {
                value = targetElement.Value;
            }
            else
            {
                WriteErrorLog("マスタ情報定義XMLに要素が存在しません。(テーブル名：{0} 要素名：{1})", convertTableName, elementName);
            }

            return value;
        }

        protected List<XElement> GetXmlElements(string elementName)
        {
            // 修正後、PATテーブルの処理に影響がないか要確認
            //// 対象テーブルの要素を取得
            //var targetElement = xml.Element("rootNode").Elements("tableInfo").Where(element => element.Element("ntssTableName").Value.Equals(convertTableName)).ToList()[0];
            //return targetElement.Elements(elementName).ToList();

            // 対象テーブルの要素を取得
            List<XElement> elementList = xml.Element("rootNode").Elements("tableInfo").Where(element => element.Element("ntssTableName").Value.Equals(convertTableName)).ToList();
            XElement targetElement;
            if (elementList.Count >= 2)
            {
                // ２件以上ある場合は移行元テーブルで絞り込みを行う
                targetElement = elementList.Where(x => x.Element("fnwTableName").Value.Equals(fnwTableName)).FirstOrDefault();
            }
            else
            {
                targetElement = elementList[0];
            }

            return targetElement.Elements(elementName).ToList();
        }

        /// <summary>
        /// コンバートデータの型変換
        /// </summary>
        /// <param name="value">値</param>
        /// <param name="ntssColType">コンバート先カラムのデータ型</param>
        /// <param name="convertedValue">(戻り値)変換後の値(失敗時はnull)</param>
        protected void ConvertDataType(string value, string ntssColType, ref object convertedValue)
        {
            convertedValue = null;

            // データ型変換
            switch (ntssColType)
            {
                case NTSS_DATA_TYPE_CHARACTER_VARYING:
                    if (string.IsNullOrEmpty(value))
                    {
                        convertedValue = DBNull.Value;
                    }
                    else
                    {
                        // シングルクォートのエスケープ処理
                        // mod #10153 djy start
                        //value = value.Replace("'", "''");
                        if (CSV_TABLES.Contains(convertTableName))
                        {
                            //csv
                            // mod #10191 djy start
                            //value = value.Replace("\"", "\"\"");
                            value = SpecialDataFormat(value, ConvertValueType.CSV_DATA);
                            // mod #10191 djy end
                        }
                        else
                        {
                            //sql
                            // mod #10153,#10191,#10249 djy start
                            value = SpecialDataFormat(value, ConvertValueType.SQL_DATA);
                            // mod #10153,#10191,#10249 djy end
                        }
                        // mod #10153 djy end
                        convertedValue = value;
                    }
                    break;
                case NTSS_DATA_TYPE_TIMESTAMP:
                    if (string.IsNullOrEmpty(value))
                    {
                        convertedValue = DBNull.Value;
                    }
                    else
                    {
                        DateTime? date = GetFormatedDate(value);
                        if (date != null)
                        {
                            convertedValue = (DateTime)date;
                        }
                    }
                    break;

                case NTSS_DATA_TYPE_JSONB:
                    convertedValue = value;
                    break;

                default:
                    if (string.IsNullOrEmpty(value))
                    {
                        convertedValue = DBNull.Value;
                    }
                    else
                    {
                        // シングルクォートのエスケープ処理
                        // mod #10153 djy start
                        //value = value.Replace("'", "''");
                        if (CSV_TABLES.Contains(convertTableName))
                        {
                            //csv
                            // mod #10191 djy start
                            //value = value.Replace("\"", "\"\"");
                            value = SpecialDataFormat(value, ConvertValueType.CSV_DATA);
                            // mod #10191 djy end
                        }
                        else
                        {
                            //sql
                            // mod #10153,#10191,#10249 djy start

                            value = SpecialDataFormat(value, ConvertValueType.SQL_DATA);
                            // mod #10153,#10191,#10249 djy end
                        }
                        // mod #10153 djy end
                        convertedValue = value;
                    }
                    break;
            }
        }

        // add #10191 djy start
        /// <summary>
        /// 特殊文字エスケープ共通処理
        /// <param name="value">特殊文字列</param>
        /// <param name="convertType">変換型</param>
        /// </summary>
        /// <returns>エスケープ後文字列</returns>
        protected string SpecialDataFormat(string value, ConvertValueType convertType)
        {
            switch (convertType)
            {
                case ConvertValueType.SQL_DATA:
                    return value.Replace("'", "''").Replace("\\", "\\\\").Replace(Environment.NewLine, "\\n").Replace("\n", "\\n").Replace("\r", "\\n").Replace("\t", "\\t");
                case ConvertValueType.CSV_DATA:
                    return value.Replace("\"", "\"\"");
                case ConvertValueType.CSV_JSON_DATA:
                    return value.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace(Environment.NewLine, "\\n").Replace("\n", "\\n").Replace("\r", "\\n").Replace("\t", "\\t");
                case ConvertValueType.BR_NEWLINE_DATA:
                    return value.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace(Environment.NewLine, "<br>").Replace("\n", "<br>").Replace("\r", "<br>").Replace("\t", "\\t");
                case ConvertValueType.P_TAG_NEWLINE_DATA:
                    if (value.IndexOf("/") > 0)
                    {
                        value = value.Replace("/", "|.-.|");
                    }
                    value = value.Replace("'", "''").Replace("\\", "\\\\").Replace(Environment.NewLine, "/").Replace("\n", "\\n").Replace("\r", "\\n").Replace("\t", "\\t");
                    if (value.IndexOf("\n") > 0)
                    {
                        value = value.Replace("\n", "/");
                    }
                    if (value.IndexOf("\r") > 0)
                    {
                        value = value.Replace("\r", "/");
                    }
                    var pvalues = value.Split('/');
                    // mod #10191 limingyang start
                    //string pvalue = string.Empty;
                    //for (int i = 0; i < pvalues.Length; i++)
                    //{
                    //pvalue += "<p id=\"text-p-2\" style=\"font-size: 14pt; font-family: メイリオ;\">" + pvalues[i].Replace("|.-.|", "/") + "﻿</p>";
                    //}
                    StringBuilder sb = new StringBuilder();
                    for (int i = 0; i < pvalues.Length; i++)
                    {
                        string processedValue = pvalues[i].Replace("|.-.|", "/");
                        sb.Append("<p id=\"text-p-2\" style=\"font-size: 14pt; font-family: メイリオ;\">");
                        sb.Append(processedValue);
                        sb.Append("</p>");
                    }
                    string pvalue = sb.ToString();
                    // mod #10191 limingyang end
                    return pvalue;
                //add #10291 djy start
                case ConvertValueType.WIN_NEWLINE_DATA:
                    return value.Replace("'", "''").Replace("\\", "\\\\").Replace(Environment.NewLine, "\\r\\n").Replace("\r", "\\r\\n").Replace("\n", "\\r\\n").Replace("\t", "\\t");
                //add #10291 djy end
                default:
                    return value;
            }
        }
        /// <summary>
        /// ファイル作成時カラム共通処理
        /// </summary>
        /// <param name="replaceSql">sql切替前</param>
        /// <param name="column">カラム名</param>
        /// <param name="value">文字列</param>
        /// <param name="columnType">カラム型</param>
        /// <param name="isSingleString">単純文字列かどうか</param>
        /// <returns>処理後の文字列</returns>
        protected string MakeColumnSpecialFormat(string replaceSql, string column, string value, SpecialColumnType columnType, bool isSingleString)
        {
            if (replaceSql == null)
            {
                if (column == null)
                {
                    switch (columnType)
                    {
                        case SpecialColumnType.SQL_STRING:
                            if (value.Contains("\\"))
                            {
                                return "E" + value;
                            }
                            return value;
                        case SpecialColumnType.NORMAL_STRING:
                            if (value.Contains("\\"))
                            {
                                return "E'" + value + "'";
                            }
                            return "'" + value + "'";
                        case SpecialColumnType.ENCRYPT_STRING:
                            if (isSingleString)
                            {
                                if (value.Contains("\\"))
                                {
                                    return "personal_info_encrypt(E'" + value.Replace("\\\\", "\\\\\\\\") + "')";
                                }
                                return "personal_info_encrypt('" + value + "')";
                            }
                            else
                            {
                                if (value.Contains("\\"))
                                {
                                    return "personal_info_encrypt(E'" + value.Replace("\\\\", "\\\\\\\\") + "::character varying)";
                                }
                                return "personal_info_encrypt(" + value + "::character varying)";
                            }
                        default:
                            return value;
                    }
                }
                else
                {
                    switch (columnType)
                    {
                        case SpecialColumnType.NORMAL_STRING:
                            if (value.Contains("\\"))
                            {
                                return column + "=E'" + value + "'";
                            }
                            return column + "='" + value + "'";
                        case SpecialColumnType.ENCRYPT_STRING:
                            if (value.Contains("\\"))
                            {
                                return column + "=personal_info_encrypt(E'" + value.Replace("\\\\", "\\\\\\\\") + "')";
                            }
                            return column + "=personal_info_encrypt('" + value + "')";
                        default:
                            return column + "='" + value + "'";
                    }

                }
            }
            else
            {
                if (value.Contains("\\"))
                {
                    if (replaceSql.Contains("personal_info_encrypt('{" + column + "}')"))
                    {
                        replaceSql = replaceSql.Replace("personal_info_encrypt('{" + column + "}')", "personal_info_encrypt(E'" + value.Replace("\\\\", "\\\\\\\\") + "')");
                    }
                    replaceSql = replaceSql.Replace("'{" + column + "}'", "E'" + value + "'");
                }
                replaceSql = replaceSql.Replace("{" + column + "}", value);

                return replaceSql;
            }
        }
        // add #10191 djy end

        /// <summary>
        /// 日時文字列をDateTime型に変換
        /// </summary>
        /// <param name="value">日時文字列</param>
        /// <remarks>
        /// 戻り値はnull許容型なのでDateTime型にキャストすること
        /// </remarks>
        /// <returns>成功：日時、失敗：null</returns>
        protected DateTime? GetFormatedDate(string value)
        {
            DateTime? date = null;

            // フォーマットパターン
            string[] formats = {
                                   "yyyy/MM/dd HH:mm:ss",
                                   "yyyy/M/dd HH:mm:ss",
                                   "yyyy/MM/d HH:mm:ss",
                                   "yyyy/M/d HH:mm:ss",

                                   "yyyy/MM/dd H:mm:ss",
                                   "yyyy/M/dd H:mm:ss",
                                   "yyyy/MM/d H:mm:ss",
                                   "yyyy/M/d H:mm:ss",

                                   "yyyy/MM/dd HH:mm",
                                   "yyyy/M/dd HH:mm",
                                   "yyyy/MM/d HH:mm",
                                   "yyyy/M/d HH:mm",

                                   "yyyy/MM/dd H:mm",
                                   "yyyy/M/dd H:mm",
                                   "yyyy/MM/d H:mm",
                                   "yyyy/M/d H:mm",

                                   "yyyy/MM/dd",
                                   "yyyy/M/dd",
                                   "yyyy/MM/d",
                                   "yyyy/M/d",

                                   "yyyyMMddHHmmss",
                                   "yyyyMMddHHmm",
                                   "yyyyMMdd",
                                   "yyyyMM"
                               };

            var tmpDate = DateTime.MinValue;
            if (DateTime.TryParseExact(value, formats, null, 0, out tmpDate))
            {
                date = (DateTime)tmpDate;
            }
            else
            {
                WriteErrorLog("日時フォーマットに失敗しました。(値：{0})", value);
            }

            return date;
        }

        /// <summary>
        /// JSON要素作成
        /// </summary>
        /// <param name="relation">紐付けレコード</param>
        /// <param name="value">値</param>
        /// <returns>JSON要素(日付フォーマット失敗時はキーがnull)</returns>
        protected JsonElement CreateJsonElement(DataRow relation, string value)
        {
            var jsonElement = new JsonElement();

            // 紐付けレコードからJSON要素のキーとデータ型を取得
            var key = relation["JSON_KEY"].ToString();
            var valueType = relation["JSON_VALUE_TYPE"].ToString();

            // キーを設定
            jsonElement.keyName = string.Format("\"{0}\"", key);

            // JSONデータフォーマットを設定
            int num = int.Parse(relation["JSON_DATA_FORMAT"].ToString());
            jsonElement.jsonDataFormat = (JsonDataFormat)Enum.ToObject(typeof(JsonDataFormat), num);

            // JSONデータタイプを設定
            jsonElement.jsonValueType = valueType;

            // 置換用の要素として利用するかのフラグ
            string sqlCreatiomExclusion = relation["SQL_CREATION_EXCLUSION_FLG"].ToString();
            bool isSqlCreatiomExclusionFlg = sqlCreatiomExclusion.Equals("1");
            jsonElement.sqlCreationExclusionFlg = isSqlCreatiomExclusionFlg;

            // 遅延バインド変数として使用するかどうかフラグ
            // フラグが１つでも1のJSON項目は遅延バインド対象のJSON項目に設定される用途とみなし、
            // SQL作成対象外になる。
            // ※未使用
            string delayBoundVariable = relation["DELAY_BOUND_VARIABLE_FLG"].ToString();
            bool delayBoundVariableFlg = delayBoundVariable.Equals("1");
            jsonElement.delayBoundVariableFlg = delayBoundVariableFlg;

            // 遅延バイント対象の要素の場合、数値型にする
            // （シングルクォートでくくらないようにするため）
            string delayBoundTarget = relation["DELAY_BOUND_TARGET_FLG"].ToString();
            bool delayBoundTargetFlg = delayBoundTarget.Equals("1");
            if (delayBoundTargetFlg)
            {
                jsonElement.jsonValueType = NTSS_DATA_TYPE_SMALLINT;
            }

            List<string> userFirstName = new List<string>()
            {
                "upd_user_first_name",
                "ind_user_first_name"
            };
            //add 7980 zc start
            if (string.IsNullOrWhiteSpace(value) && "indicator_start_date".Equals(key))
            {
                jsonElement.value = "";
            }
            else
                //add 7980 zc end
                // mod FNSI_Json空データの修正 楊 start
                // if (string.IsNullOrEmpty(value))
                if (string.IsNullOrWhiteSpace(value) && relation[0].ToString().Contains("SYS_COMSVR_SETTING_MENU") && "NAME".Equals(relation[1].ToString()))
            //#7761で、comsvの装置メニューのJSONはnullにしない処理を追加
            {
                jsonElement.value = "";
            }
            else if (userFirstName.Contains(key) && string.IsNullOrWhiteSpace(value))
            {
                jsonElement.value = "";
            }
            else if (string.IsNullOrWhiteSpace(value) && (!"first_name".Equals(key)))
            // mod FNSI_Json空データの修正 楊 end
            {
                // 空はnull
                jsonElement.value = "null";
            }
            else
            {
                // mod #10153 djy start
                // mod #10191 djy start
                //jsonElement.value = value.Trim();
                //jsonElement.value = value.Trim().Replace("'", "''");
                // mod #10191 djy end
                if (CSV_TABLES.Contains(convertTableName))
                {
                    // mod #10191 djy start

                    jsonElement.value = SpecialDataFormat(value.Trim(), ConvertValueType.CSV_JSON_DATA);
                    // mod #10191 djy end
                }
                else
                {
                    //sql
                    // mod #10153,#10191,#10249 djy start
                    jsonElement.value = SpecialDataFormat(value.Trim(), ConvertValueType.SQL_DATA);
                    // mod #10153,#10191,#10249 djy end
                }
                // mod #10153 djy end
            }
            return jsonElement;
        }

        /// <summary>
        /// 紐付けDBには存在するが、マップに存在しないJsonElementを作成し、
        /// マップに追加する
        /// </summary>
        /// <param name="drRelationArray">対象のJSONカラムの紐付け設定</param>
        /// <param name="mapJsonTmp">処理対象のマップ</param>
        /// <param name="jsonName">対象のJSONカラム名</param>
        /// <returns>true:空要素を作成した false:空要素を作成していない</returns>
        protected void AddNotExistsThenEmptyJsonElement(DataRow[] drRelationArray,
                                        Dictionary<string, List<JsonElement>> mapJsonTmp,
                                        string jsonName)
        {
            // 対象のJSON要素が存在しない場合作成。
            foreach (DataRow drRelation in drRelationArray)
            {
                if (int.Parse(drRelation["JSON_DATA_FORMAT"].ToString()) != (int)JsonDataFormat.JsonNoArray
                    && mapJsonTmp.Count() == 0)
                {
                    // JSONデータ形式が配列なし以外かつ値が格納されているJSON要素が無いの場合
                    // 不足分のJSON要素を作成しない
                    break;
                }

                // マップにキーが存在しない場合、JSON要素を作成
                if (!mapJsonTmp.ContainsKey(jsonName))
                {
                    // 遅延バインド対象か判定する
                    if (drRelation["DELAY_BOUND_TARGET_FLG"].ToString().Equals("1"))
                    {
                        // 対象の場合、値に置換変数を埋め込む
                        // 例：beforeというJSONキー名の場合
                        // valueに{before}が設定され、SQL作成時にbeforeの項目値に置換される
                        CollectJsonElement("{" + drRelation["JSON_KEY"].ToString() + "}", jsonName, drRelation, mapJsonTmp);
                    }
                    else
                    {
                        // 存在しない場合空データのJSON要素を作成
                        CollectJsonElement("", jsonName, drRelation, mapJsonTmp);
                    }
                    continue;
                }
                // DBの紐付け情報が存在し、Json要素として作成されていないものを検索
                if (!mapJsonTmp[jsonName].Any(jsonElememt =>
                {
                    return drRelation["JSON_KEY"].ToString().Equals(jsonElememt.getKeyNameDeleteEscape());
                }))
                {
                    // 遅延バインド対象か判定する
                    if (drRelation["DELAY_BOUND_TARGET_FLG"].ToString().Equals("1"))
                    {
                        // 対象の場合、値に置換変数を埋め込む
                        // 例：beforeというJSONキー名の場合
                        // valueに{before}が設定され、SQL作成時にbeforeの項目値に置換される
                        CollectJsonElement("{" + drRelation["JSON_KEY"].ToString() + "}", jsonName, drRelation, mapJsonTmp);
                    }
                    else
                    {
                        // 存在しない場合空データのJSON要素を作成
                        CollectJsonElement("", jsonName, drRelation, mapJsonTmp);
                    }
                }
            }
        }
        //add 10534 start
        protected void ConvertJsonArrayDataPatMemoInfo(DataRow[] jsonRecords, string jsonName, List<NtssColumn> ntssColumns, ref bool isCriticalError, ref bool isConvertError)
        {

            // JSONデータのリスト(配列化用)
            var listJsonArrayElement = new List<string>();
            // JSONデータのリスト
            List<List<JsonElement>> jsonElementListList = new List<List<JsonElement>>();

            // JSONデータ全格納完了後、紐付け項目ではないが、JSON要素が存在しなければならない場合
            // 要素を作成し、値をnullに設定する。
            // 紐付け情報取得
            DataRow[] drRelationArray = GetRelationArrayByNtssInfo(this.convertTableName,
                                                                    jsonName);
            Dictionary<string, List<JsonElement>> mapJsonTmp;

            if (jsonRecords.Length > 0)
            {

                HashSet<int> existingCtlNos = new HashSet<int>();
                foreach (DataRow row in jsonRecords)
                {
                    int ctlNo = int.Parse(row["CTL_NO"].ToString());
                    existingCtlNos.Add(ctlNo);
                }
                List<DataRow> allRows = new List<DataRow>(jsonRecords);
                DataTable table = jsonRecords[0].Table;
                for (int i = 1; i <= 20; i++)
                {
                    if (!existingCtlNos.Contains(i))
                    {
                        DataRow dataRow = table.NewRow();
                        dataRow["CTL_NO"] = i;
                        dataRow["PATID"] = DBNull.Value;
                        dataRow["CONTENT"] = DBNull.Value;
                        dataRow["TITLE"] = DBNull.Value;
                        if ("pat_main_history".Equals(convertTableName))
                        {
                            dataRow["UP_DATE"] = DBNull.Value;
                        }
                        allRows.Add(dataRow);
                    }
                }
                DataRow[] completedRows = allRows.ToArray();
                foreach (DataRow dr in completedRows)
                {
                    mapJsonTmp = new Dictionary<string, List<JsonElement>>();
                    ConvertRecord(dr, ntssColumns, mapJsonTmp, ref isConvertError);
                    if (isCriticalError || isConvertError)
                    {
                        return;
                    }

                    // 紐付け対象外の空のJSON要素を追加
                    this.AddNotExistsThenEmptyJsonElement(drRelationArray,
                                                        mapJsonTmp,
                                                        jsonName);
                    //add 2020-11/27 FNSI-改修内容 空データを作成した場合のみJSONリストへ追加  う  start
                    if (mapJsonTmp.ContainsKey(jsonName))
                    {
                        jsonElementListList.Add(mapJsonTmp[jsonName]);
                    }
                }

                var sortedList = jsonElementListList
                    .OrderBy(list =>
                    {
                        var ctlNo = list.FirstOrDefault(e => e.keyName == "\"ctl_no\"");
                        return ctlNo == null ? int.MaxValue : int.Parse(ctlNo.value.ToString());
                    })
                    .ToList();
                ntssColumns.Add(CreateNtssColumnForJson(jsonName, NTSS_DATA_TYPE_JSONB, sortedList, false));

            }
        }
        //add 10534 end
        /// <summary>
        /// JSON配列となるレコードをNTSSレコードに加工
        /// </summary>
        /// <param name="jsonRecords">元データレコード</param>
        /// <param name="jsonName">JSONデータ名</param>
        /// <param name="ntssColumns">NTSSカラムのリスト</param>
        /// <param name="isCriticalError">続行不可エラーフラグ</param>
        /// <param name="isConvertError">データ加工エラーフラグ</param>
        protected void ConvertJsonArrayData(DataRow[] jsonRecords, string jsonName, List<NtssColumn> ntssColumns, ref bool isCriticalError, ref bool isConvertError)
        {
            // JSONデータのリスト(配列化用)
            var listJsonArrayElement = new List<string>();
            // JSONデータのリスト
            List<List<JsonElement>> jsonElementListList = new List<List<JsonElement>>();

            // JSONデータ全格納完了後、紐付け項目ではないが、JSON要素が存在しなければならない場合
            // 要素を作成し、値をnullに設定する。
            // 紐付け情報取得
            DataRow[] drRelationArray = GetRelationArrayByNtssInfo(this.convertTableName,
                                                                    jsonName);
            // add 10870 zkm start
            if ("mnt_mainte_main".Equals(this.convertTableName) && ("detail_mainte".Equals(jsonName) || "detail_parts".Equals(jsonName)))
            {
                drRelationArray = GetRelationArrayByFnwTableNtssInfo(this.fnwTableName, this.convertTableName, jsonName);
            }
            // add 10870 zkm end

            // add 12339  start
            if ("mst_pat_viewer_layout".Equals(this.convertTableName) && "disp_item_info".Equals(jsonName))
            {

                drRelationArray = GetRelationArrayByFnwTableNtssInfo(this.fnwTableName, this.convertTableName, jsonName);
            }
            // add 12339  start
            Dictionary<string, List<JsonElement>> mapJsonTmp;
            //add #9801 djy start
            if ("pat_event".Equals(this.convertTableName) && "result_value_2".Equals(jsonName))
            {
                var imageCount = 1;
                List<NtssColumn> image = ntssColumns.Where(n => "image_count".Equals(n.name)).ToList();
                if (image != null && image.Count > 0)
                {
                    try
                    {
                        imageCount = int.Parse(image[0].value.ToString());
                    }
                    catch (Exception e)
                    {
                        WriteErrorLog("ConvertJsonArrayData:{0}", e.Message);
                        imageCount = 1;
                    }
                    if (jsonRecords.Length > 0 && jsonRecords.Length < imageCount)
                    {
                        DataTable tmp = jsonRecords[0].Table.Clone();
                        var title = jsonRecords[0]["DESCRIPTION"];
                        for (var i = 1; i <= imageCount; i++)
                        {
                            bool addFlg = false;
                            foreach (DataRow dr in jsonRecords)
                            {
                                if (i == (DBNull.Value.Equals(dr["PHOTO_NO"]) || "".Equals(dr["PHOTO_NO"]) ? 0 : int.Parse(dr["PHOTO_NO"].ToString())))
                                {
                                    DataRow newRow1 = tmp.NewRow();
                                    newRow1.ItemArray = dr.ItemArray;
                                    tmp.Rows.Add(newRow1);
                                    addFlg = true;
                                }
                            }
                            if (!addFlg)
                            {
                                DataRow newRow = tmp.NewRow();
                                newRow["DESCRIPTION"] = title;
                                tmp.Rows.Add(newRow);
                            }
                        }
                        jsonRecords = tmp.Rows.Cast<DataRow>().ToArray();
                    }
                }
            }
            //add #9801 djy end
            if (jsonRecords.Length > 0)
            {

                foreach (DataRow dr in jsonRecords)
                {
                    mapJsonTmp = new Dictionary<string, List<JsonElement>>();
                    ConvertRecord(dr, ntssColumns, mapJsonTmp, ref isConvertError);
                    if (isCriticalError || isConvertError)
                    {
                        return;
                    }

                    // 紐付け対象外の空のJSON要素を追加
                    this.AddNotExistsThenEmptyJsonElement(drRelationArray,
                                                        mapJsonTmp,
                                                        jsonName);
                    //add 2020-11/27 FNSI-改修内容 空データを作成した場合のみJSONリストへ追加  う  start
                    if (mapJsonTmp.ContainsKey(jsonName))
                    {
                        jsonElementListList.Add(mapJsonTmp[jsonName]);
                        //listJsonArrayElement.Add(CreateJsonString(mapJsonTmp[jsonName]));
                    }
                }

                // add #10671 save_2, 3, 4の値が全てnull→save_2～10で値が全てnullの場合はnull zkm start
                if ("pat_coop_detail".Equals(this.convertTableName) && listPatCoopDetailSave234.Contains(jsonName))
                {
                    int CountValueNotNull = jsonElementListList[0].Where(json => !"null".Equals(json.getValueDeleteEscape())).Count();
                    if (1 > CountValueNotNull)
                    {
                        jsonElementListList = null;
                    }
                }
                // add #10671 save_2, 3, 4の値が全てnull→save_2～10で値が全てnullの場合はnull zkm end

                ntssColumns.Add(CreateNtssColumnForJson(jsonName, NTSS_DATA_TYPE_JSONB, jsonElementListList, false));
                //ntssColumns.Add(CreateNtssColumn(jsonName, NTSS_DATA_TYPE_JSONB, CreateJsonArrayString(listJsonArrayElement), false));
            }
            else
            {
                mapJsonTmp = new Dictionary<string, List<JsonElement>>();
                // 紐付け対象外の空のJSON要素を追加
                this.AddNotExistsThenEmptyJsonElement(drRelationArray,
                                                        mapJsonTmp,
                                                        jsonName);

                // 空データを作成した場合のみJSONリストへ追加
                if (mapJsonTmp.ContainsKey(jsonName))
                {
                    jsonElementListList.Add(mapJsonTmp[jsonName]);
                }

                // JSON項目変換対象のレコードが０件でも空のデータを挿入する
                // （SQL作成対象のカラムにするため）
                ntssColumns.Add(CreateNtssColumnForJson(jsonName, NTSS_DATA_TYPE_JSONB, jsonElementListList, false));
            }
        }

        /// <summary>
        /// JSON配列となるレコードをNTSSレコードに加工（装置設定用）
        /// JSONの１階層目と、アドレス値と値のJsonElementを作成する
        /// 
        /// ※最終的なJSON完成イメージと本処理の担当箇所（rst_device_set_infoの場合、作成方法の概要は他も同じ）
        /// {
        ///  "urf":{            // １階層目のJsonElementとして作成
        ///   "dev":{           
        ///    "A":{
        ///     "290":【値】,   // アドレス値と値のセットのJsonElementとして作成
        ///     "311":【値】... // アドレス値と値のセットのJsonElementとして作成
        ///    }.
        ///  "na":{...          // １階層目のJsonElementとして作成
        ///  "dc":{...          // １階層目のJsonElementとして作成
        ///  "qnqd":{...        // １階層目のJsonElementとして作成
        ///  "ihdf":{...        // １階層目のJsonElementとして作成
        ///  "bvufc":{...       // １階層目のJsonElementとして作成
        ///  "dia":{            // １階層目のJsonElementとして作成
        ///  }
        /// }
        /// 
        /// urfのJsonElementを作成（値はこの時点ではnull）
        /// アドレス値と値のセットのJsonElementを取得データより作成。
        /// --本処理ではここまで--
        ///
        /// 後の処理でurfの値としてSYNC_CUSTOM_CONVERT_VALUEより取得した文字列（以下）を設定し
        /// ※SYNC_CUSTOM_CONVERT_VALUEより取得した値
        ///   "dev":{           
        ///    "A":{
        ///     "290":{置換変数１}
        ///     "311":{置換変数２}...
        ///    }.
        /// 置換変数１と２を本処理で作成したアドレス値と値のセットの値を使い置換していく。
        /// 
        ///  
        /// </summary>
        /// <param name="jsonRecords"></param>
        /// <param name="jsonName"></param>
        /// <param name="ntssColumns"></param>
        /// <param name="isCriticalError"></param>
        /// <param name="isConvertError"></param>
        protected void ConvertJsonArrayDeviceSetInfoData(DataRow[] jsonRecords, string jsonName, List<NtssColumn> ntssColumns, ref bool isCriticalError, ref bool isConvertError)
        {
            // JSONデータのリスト(配列化用)
            var listJsonArrayElement = new List<string>();
            // JSONデータのリスト
            List<List<JsonElement>> jsonElementListList = new List<List<JsonElement>>();
            var mapJsonTmp = new Dictionary<string, List<JsonElement>>();

            // JSONデータ全格納完了後、紐付け項目ではないが、JSON要素が存在しなければならない場合
            // 要素を作成し、値をnullに設定する。
            // 紐付け情報取得
            DataRow[] drRelationArray = GetRelationArrayByNtssInfo(this.convertTableName,
                                                                    jsonName);

            // 移行先列名で取得した紐づけ情報をjsonb型のデータに更に絞る
            drRelationArray = drRelationArray.ToList().Where(row => row.Field<string>("NTSS_COLUMN_TYPE") == "jsonb").ToArray();

            //Dictionary<string, List<JsonElement>> mapJsonTmp;
            if (jsonRecords.Length > 0)
            {

                foreach (DataRow dr in jsonRecords)
                {
                    mapJsonTmp = new Dictionary<string, List<JsonElement>>();
                    ConvertRecord(dr, ntssColumns, mapJsonTmp, ref isConvertError);
                    if (isCriticalError || isConvertError)
                    {
                        return;
                    }

                    // １階層目のJsonElementを作成する。
                    this.AddNotExistsThenEmptyJsonElement(drRelationArray,
                                                        mapJsonTmp,
                                                        jsonName);

                    // アドレス値と値のセット（装置設定値）をJsonリストに追加
                    if (this.convertTableName.Equals("pat_main_history"))
                    {
                        AddDeviceSetJsonElementPat(dr, jsonName, mapJsonTmp);
                    }
                    else
                    {
                        AddDeviceSetJsonElement(dr, jsonName, mapJsonTmp);
                    }


                    jsonElementListList.Add(mapJsonTmp[jsonName]);
                }

                ntssColumns.Add(CreateNtssColumnForJson(jsonName, NTSS_DATA_TYPE_JSONB, jsonElementListList, false));
            }
        }


        /// <summary>
        /// elementNameListForExistsCheckの名前の要素がJsonElementListに存在しているかチェックし
        /// 存在しない場合、空の要素として作成する
        /// </summary>
        /// <param name="mapJson">JsonElementList</param>
        /// <param name="elementNameListForExistsCheck"></param>
        private void MakeEmptyJsonElementForDeviceInfo(
            Dictionary<string, List<JsonElement>> mapJson,
            List<string> elementNameListForExistsCheck,
            string jsonName)
        {
            // 不足している要素チェックし、存在しない場合、空のJsonElementを作成する
            foreach (string elementName in elementNameListForExistsCheck)
            {
                if (!mapJson[jsonName].Any(je => je.getKeyNameDeleteEscape().Equals(elementName)))
                {
                    // 存在しない場合、追加
                    var jsonElement = new JsonElement();

                    // キーを設定
                    jsonElement.keyName = string.Format("\"{0}\"", elementName);
                    // JSONデータフォーマットを設定
                    int num = 2;
                    jsonElement.jsonDataFormat = (JsonDataFormat)Enum.ToObject(typeof(JsonDataFormat), num); //　とりあえず固定
                    // JSONデータタイプを設定
                    jsonElement.jsonValueType = "character varying";
                    // mod #10267 limingyang start
                    if (elementName.Equals("c_00") || elementName.Equals("c_01") || elementName.Equals("c_02") ||
                        elementName.Equals("c_03"))
                    {
                        jsonElement.value = "";
                    }
                    else
                    {
                        jsonElement.value = "null";
                    }
                    //jsonElement.value = "null";
                    // mod #10267 limingyang end
                    jsonElement.sqlCreationExclusionFlg = true;

                    mapJson[jsonName].Add(jsonElement);
                }
            }
        }

        /// <summary>
        /// 装置設定のJsonElementのリストを作成する
        /// ConvertOrdMainから移動
        /// </summary>
        /// <param name="targetRecord"></param>
        /// <param name="jsonName"></param>
        /// <param name="mapJson"></param>
        /// 
        /// 
        /// 
        protected void AddDeviceSetJsonElement(DataRow targetRecord, string jsonName, Dictionary<string, List<JsonElement>> mapJson)
        {
            if ("treat_condition".Equals(jsonName))
            {
                // 治療条件
                ProcessingDataForDeviceSetJson(targetRecord["SET_DATA"] as string,
                                        "DEVICE_DATA",
                                        "c_",
                                        mapJson,
                                        ConvertCommon.Const.CommonConstants.TREAT_CONDITION_ELEMENT_NAME_LIST_DEV,
                                        "treat_condition");
            }
            else
            {
                // 装置設定
                if (targetRecord.Table.Columns.Contains("SET_DATA"))
                {
                    ProcessingDataForDeviceSetJson(targetRecord["SET_DATA"] as string,
                                           "DEVICE_DATA",
                                           "dev_",
                                           mapJson,
                                           ConvertCommon.Const.CommonConstants.DEVICE_SET_INFO_ELEMENT_NAME_LIST_DEV,
                                           jsonName);
                }
            }

            if (targetRecord.Table.Columns.Contains("NEXT_DATA"))
            {
                // 次患者情報
                ProcessingDataForDeviceSetJson(targetRecord["NEXT_DATA"] as string,
                                        "NEXT_DATA",
                                        "pat_",
                                        mapJson,
                                        ConvertCommon.Const.CommonConstants.DEVICE_SET_INFO_ELEMENT_NAME_LIST_PAT,
                                        jsonName);
            }
            //add 7995  zc start
            if (targetRecord.Table.Columns.Contains("HOST_WATCH"))
            {
                // ホスト監視
                ProcessingDataForDeviceSetJson(targetRecord["HOST_WATCH"] as string,
                                        "HOST_WATCH",
                                        "host_",
                                        mapJson,
                                        ConvertCommon.Const.CommonConstants.DEVICE_HOST_WATCH_ELEMENT_NAME_LIST_PAT,
                                        jsonName);
            }
            //add 7995  zc end

            return;
        }
        protected void AddDeviceSetJsonElementPat(DataRow targetRecord, string jsonName, Dictionary<string, List<JsonElement>> mapJson)
        {
            if ("device_set_info".Equals(jsonName))
            {
                ProcessingDataForDeviceSetJson(targetRecord["SET_DATA"] as string,
                                           "DEVICE_DATA",
                                           "dev_",
                                           mapJson,
                                           ConvertCommon.Const.CommonConstants.DEVICE_SET_INFO_ELEMENT_NAME_LIST_DEV,
                                           jsonName);
                ProcessingDataForDeviceSetJson(targetRecord["NEXT_DATA"] as string,
                                       "NEXT_DATA",
                                       "pat_",
                                       mapJson,
                                       ConvertCommon.Const.CommonConstants.DEVICE_SET_INFO_ELEMENT_NAME_LIST_PAT,
                                       jsonName);
            }
            else if ("host_notification_info".Equals(jsonName))
            {
                ProcessingDataForDeviceSetJson(targetRecord["HOST_WATCH"] as string,
                                            "HOST_WATCH",
                                            "host_",
                                            mapJson,
                                            ConvertCommon.Const.CommonConstants.DEVICE_HOST_WATCH_ELEMENT_NAME_LIST_PAT,
                                            jsonName);
            }


            return;
        }
        /// <summary>
        /// 元データレコードをNTSSレコードに加工
        /// </summary>
        /// <param name="targetRecord">元データレコード</param>
        /// <param name="ntssColumns">NTSSカラムのリスト</param>
        /// <param name="mapJson">JSONデータ作成用連想配列</param>
        /// <param name="isConvertError">データ加工エラーフラグ</param>
        /// 
        /// <remarks>
        /// ・JSON要素でないデータはntssColumnsに格納される
        /// ・JSON要素となるデータはmapJsonに格納される
        /// ・mapJsonの中身は最終的にJSONデータに加工する必要がある
        /// </remarks>
        protected void ConvertRecord(DataRow targetRecord, List<NtssColumn> ntssColumns, Dictionary<string, List<JsonElement>> mapJson, ref bool isConvertError)
        {
            // 元テーブル名
            var fnwTableName = targetRecord.Table.TableName;
            var columns = targetRecord.Table.Columns;
            for (int i = 0; i < columns.Count; i++)
            {
                // 元カラム名
                var fnwColName = columns[i].Caption;

                // 無視カラム判定は不要なので削除
                if (IsIgonreColumn(fnwTableName, fnwColName))
                {
                    // コンバート対象外カラム
                    continue;
                }

                // 元データ
                var fnwValue = targetRecord[i].ToString();

                // 紐付けテーブルからコンバート先の情報を取得
                // 配列を取得するように変更
                DataRow[] relations = GetRelationArray(fnwTableName, fnwColName, null);
                if (relations.Length == 0)
                {
                    // コンバート先の情報が取得できない場合、コンバート対象外にして、次のカラムを判定する
                    continue;
                }
                foreach (DataRow relation in relations)
                {
                    // add FNSI-患者経過総合ビューアレイアウトマスタ修正 楊 start
                    var befOutFlg = relation[13];
                    if ("SYS_MUL_GRAPH_DETAIL-mst_pat_viewer_layout-subCategoryItem".Equals(fnwTableName))
                    {
                        if (targetRecord[1].ToString().Equals("2"))
                        {
                            switch (fnwColName)
                            {
                                case "ITEMNAME":
                                    relation[13] = "1";
                                    break;
                            }
                        }
                        else
                        {
                            switch (fnwColName)
                            {
                                case "ITEMDATE":
                                case "GRAPH":
                                    relation[13] = "1";
                                    break;
                            }
                        }
                    }
                    // add FNSI-患者経過総合ビューアレイアウトマスタ修正 楊 end
                    if (ConvertColumn(fnwValue, relation, ntssColumns, mapJson) == false)
                    {
                        WriteErrorLog(MSG_ERR_FAILED_DATA, fnwTableName, fnwColName, fnwValue);
                        isConvertError = true;
                        return;
                    }
                    // add FNSI-患者経過総合ビューアレイアウトマスタ修正 楊 start
                    relation[13] = befOutFlg;
                    // add FNSI-患者経過総合ビューアレイアウトマスタ修正 楊 end
                }
            }

        }

        /// <summary>
        /// 元データレコードのカラムをNTSSカラムに加工
        /// </summary>
        /// <param name="fnwValue">元データ値</param>
        /// <param name="relation">紐付け定義レコード</param>
        /// <param name="ntssColumns">NTSSカラムのリスト</param>
        /// <param name="mapJson">JSONデータ作成用連想配列</param>
        /// <returns>成功：true、失敗：false</returns>
        protected bool ConvertColumn(string fnwValue, DataRow relation, List<NtssColumn> ntssColumns, Dictionary<string, List<JsonElement>> mapJson)
        {
            // コンバート先カラム名・データ型
            var ntssColName = relation["NTSS_COLUMN_NAME"].ToString();
            if (relation["NTSS_COLUMN_TYPE"].ToString() == NTSS_DATA_TYPE_JSONB)
            {
                // JSON要素の場合は加工してJSONデータ作成用連想配列に格納
                var isSuccess = CollectJsonElement(fnwValue, ntssColName, relation, mapJson);
                if (isSuccess == false)
                {
                    return false;
                }
            }
            else
            {

                // JSON以外の場合はNTSSカラムに加工
                //NtssColumn ntssCol = CreateNtssColumn(ntssColName, relation["NTSS_COLUMN_TYPE"].ToString(), fnwValue, relation["PK_FLG"].ToString() == "1");
                NtssColumn ntssCol = CreateNtssColumn(relation, fnwValue);
                //add #7757  鄭 start 
                if (ntssColName.Equals("user_settings"))
                {
                    ntssCol.value = fnwValue;
                }
                //add #7757  鄭 end 
                if (ntssCol.value == null)
                {
                    return false;
                }
                ntssColumns.Add(ntssCol);
            }

            return true;
        }

        /// <summary>
        /// 元データをJSON要素に加工してJSONデータ作成用連想配列に格納する
        /// </summary>
        /// <param name="value">元データ値</param>
        /// <param name="jsonName">JSONデータ名</param>
        /// <param name="keyName">JSONキー名</param>
        /// <param name="valueType">JSONデータ型</param>
        /// <param name="mapJson">JSONデータ作成用連想配列</param>
        /// <returns>成功：true、失敗：false</returns>
        protected bool CollectJsonElement(string value, string jsonName, DataRow relation, Dictionary<string, List<JsonElement>> mapJson)
        {
            var jsonElement = CreateJsonElement(relation, value);

            if (jsonElement.keyName == null)
            {
                return false;
            }
            // JSONごとの連想配列に追加
            if (!mapJson.ContainsKey(jsonName))
            {
                mapJson[jsonName] = new List<JsonElement>();
            }
            mapJson[jsonName].Add(jsonElement);
            return true;
        }

        /// <summary>
        /// コンバートデータエクスポート
        /// TSV出力機能は廃止したためObsolete属性を設定
        /// </summary>
        /// <param name="mapConvertData">コンバートデータ</param>
        /// <param name="exportFolderPath">フォルダパス</param>
        /// <param name="facilityCd">施設コード</param>
        /// <param name="extraInfo">付加情報</param>
        /// <param name="encoding">エンコード文字種</param>
        /// <remarks>
        /// </remarks>
        /// <returns>成功：true、失敗：false</returns>
        [Obsolete]
        public bool Export(Dictionary<string, List<NtssRecord>> mapConvertData, string exportFolderPath, string extraInfo, Encoding encoding)
        {
            var tsvFilePath = string.Format(@"{0}\{1}-{2}-{3}.tsv", exportFolderPath, convertTableName, facilityCd, extraInfo);
            return ExportMain(mapConvertData, tsvFilePath, encoding);
        }

        /// <summary>
        /// コンバートデータエクスポート
        /// </summary>
        /// <param name="mapConvertData">コンバートデータ</param>
        /// <param name="exportFolderPath">フォルダパス</param>
        /// <param name="encoding">エンコード文字種</param>
        /// <param name="isInsertOnly">True:Insert文作成 False:Upsert文作成</param>
        /// <param name="outputFormat">出力形式</param>
        /// <param name="chunkSize">ファイル分割時の行数</param>
        /// <returns>成功：true、失敗：false</returns>
        public bool Export(Dictionary<string, List<NtssRecord>> mapConvertData,
            string exportFolderPath,
            Encoding encoding,
            bool isInsertOnly,
            bool isMakePatidFolder,
            CommonConstants.OutputFormat outputFormat,
            int chunkSize)
        {

            if (outputFormat.Equals(CommonConstants.OutputFormat.SQL))
            {
                var sqlFilePath = string.Format(@"{0}\{1}.sql", exportFolderPath, convertTableName);
                return MakeSqlFile(mapConvertData, sqlFilePath, isInsertOnly, isMakePatidFolder, chunkSize);
            }
            else if (outputFormat.Equals(CommonConstants.OutputFormat.CSV))
            {
                var csvFilePath = string.Format(@"{0}\{1}.csv", exportFolderPath, convertTableName);
                // 7341 AWS側アプリの処理が遅い start
                // return MakeCsvFile(mapConvertData, csvFilePath, encoding, false);
                return MakeCsvFile(mapConvertData, csvFilePath, encoding, isMakePatidFolder);
                // 7341 AWS側アプリの処理が遅い end
            }
            else if (outputFormat.Equals(CommonConstants.OutputFormat.JSON))
            {
                var jsonFilePath = string.Format(@"{0}\{1}", exportFolderPath, convertTableName);
                //add #12229 ord_weight_scale start
                if ("ord_weight_scale".Equals(System.IO.Path.GetFileNameWithoutExtension(jsonFilePath)))
                {
                    var sqlFilePath = string.Format(@"{0}\{1}.sql", exportFolderPath, convertTableName);
                    return MakeJsonFile(mapConvertData, sqlFilePath);
                }
                //add #12229 ord_weight_scale end
                return MakeJsonFile(jsonFilePath);
            }

            return false;
        }

        /// <summary>
        /// コンバートデータエクスポート（CSV）
        /// </summary>
        /// <param name="mapConvertData">コンバートデータ</param>
        /// <param name="exportFolderPath">フォルダパス</param>
        /// <param name="encoding">エンコード文字種</param>
        /// <param name="isInsertOnly">True:Insert文作成 False:Upsert文作成</param>
        /// <returns>成功：true、失敗：false</returns>
        public bool ExportCsv(Dictionary<string, List<NtssRecord>> mapConvertData, string exportFolderPath, Encoding encoding)
        {
            var csvFilePath = string.Format(@"{0}\{1}.csv", exportFolderPath, convertTableName);
            return MakeCsvFile(mapConvertData, csvFilePath, encoding, false);
        }

        /// <summary>
        /// 予定削除同期用コンバートデータエクスポート
        /// </summary>
        /// <param name="exportFolderPath">出力フォルダパス</param>
        /// <param name="addFileName">付加情報</param>
        /// <param name="fnwPatId">FNW患者ID</param>
        /// <param name="startDate">指示開始日</param>
        /// <param name="endDate">指示終了日</param>
        /// <param name="plural">同日複数回</param>
        /// <param name="opeIndPlan">予定作成区分</param>
        /// <param name="encoding">エンコード文字種</param>
        /// <remarks>
        /// [概要]
        /// 通常のエクスポートファイルと同様のファイルを作成(Import()を使用可能)
        /// </remarks>
        /// <returns>成功：true、失敗：false</returns>
        public bool ExportForSchDelete(string exportFolderPath, string extraInfo, string fnwPatId, DateTime startDate, DateTime endDate, string plural, string opeIndPlan, Encoding encoding)
        {
            var tsvFilePath = string.Format(@"{0}\{1}-{2}-{3}.tsv", exportFolderPath, convertTableName, facilityCd, extraInfo);

            var ntssRecord = new List<NtssColumn>();
            ntssRecord.Add(CreateNtssColumn("fn_pat_id", NTSS_DATA_TYPE_CHARACTER_VARYING, fnwPatId, true));
            ntssRecord.Add(CreateNtssColumn("dialysis_date", NTSS_DATA_TYPE_CHARACTER_VARYING, string.Format("{0}-{1}", startDate.ToString("yyyyMMdd"), endDate.ToString("yyyyMMdd")), true));
            ntssRecord.Add(CreateNtssColumn("plural", NTSS_DATA_TYPE_CHARACTER_VARYING, plural, true));
            ntssRecord.Add(CreateNtssColumn("ope_ind_plan", NTSS_DATA_TYPE_CHARACTER_VARYING, opeIndPlan, true));
            //ntssRecord.Add(CreateNtssColumn("facility_cd", NTSS_DATA_TYPE_CHARACTER_VARYING, "", true));
            ntssRecord.Add(CreateNtssColumn("facility_cd", NTSS_DATA_TYPE_CHARACTER_VARYING, facilityCd, true));
            ntssRecord.Add(CreateNtssColumn("up_date", NTSS_DATA_TYPE_TIMESTAMP, DateTime.Now.ToString(), true));
            var mapConvertData = new Dictionary<string, List<NtssRecord>>();
            mapConvertData[fnwPatId] = new List<NtssRecord>();
            mapConvertData[fnwPatId].Add(new NtssRecord() { columns = ntssRecord });

            return ExportMain(mapConvertData, tsvFilePath, encoding);
        }

        /// <summary>
        /// コンバートデータエクスポート
        /// </summary>
        /// <param name="mapConvertData">コンバートデータ</param>
        /// <param name="tsvFilePath">TSVファイルパス</param>
        /// <param name="encoding">エンコード文字種</param>
        /// <remarks>
        /// [概要]
        /// 作成したコンバートデータをTSVファイルとして出力する
        /// 
        /// [備考]
        /// ・4行のデータで1つのレコードを表す(1～4行目：レコード1、5～8行目：レコード2、...)
        /// ・各データの意味は以下の通り
        /// 　1行目：カラム名
        /// 　2行目：削除キー(コンバート先テーブルにおける主キーかどうかを表すフラグ。既存レコード削除処理時(DeleteNtssRecord())に参照する)
        /// 　3行目：NTSSDBのデータ型(バインドデータ型設定に必要なデータ型の名称。コンバートデータ作成時(CreateConvertDataFromTsvFile())に参照する)
        /// 　4行目：値
        /// </remarks>
        /// <returns>成功：true、失敗：false</returns>
        private bool ExportMain(Dictionary<string, List<NtssRecord>> mapConvertData, string tsvFilePath, Encoding encoding)
        {
            WriteTraceLog("===== コンバートデータエクスポート処理開始 =====");

            try
            {
                using (var sw = new StreamWriter(tsvFilePath, false, encoding))
                {
                    foreach (var listConvertData in mapConvertData)
                    {
                        foreach (var ntssRecord in listConvertData.Value)
                        {
                            // コンバート先カラム名を1行目に出力
                            var columnNames = string.Join("\t", ntssRecord.columns.Select(ntsscol => ntsscol.name).ToArray());
                            sw.WriteLine(columnNames);
                            // 削除キーフラグを2行目に出力
                            var deleteKeys = string.Join("\t", ntssRecord.columns.Select(ntsscol => ntsscol.isDeleteKey.ToString()).ToArray());
                            sw.WriteLine(deleteKeys);
                            // コンバート先データ型を3行目に出力
                            var dataTypes = string.Join("\t", ntssRecord.columns.Select(ntsscol => ntsscol.colType).ToArray());
                            sw.WriteLine(dataTypes);
                            // コンバートデータを4行目に出力
                            var values = string.Join("\t", ntssRecord.columns.Select(ntsscol => ntsscol.value.ToString()).ToArray());
                            sw.WriteLine(values);
                        }
                    }
                }
            }
            catch (Exception e)
            {
                WriteErrorLog(e, "コンバートデータのエクスポートに失敗しました。");
                return false;
            }

            WriteTraceLog("===== コンバートデータエクスポート処理完了 =====");
            WriteTraceLog("出力ファイル：{0}", tsvFilePath);
            return true;
        }

        /// <summary>
        /// ntssのテーブルにUpsert文を発行する際に使用するユニーク制約名を取得
        /// </summary>
        /// <param name="ntssTableName"></param>
        /// <returns></returns>
        private DataRow[] GetUniqueConstraint(string ntssTableName)
        {
            string tableName = "SYNC_UNIQUE";
            string sql = "select CONSTRAINT_NAME,UNIQUE_COLUMNS,NTSS_SEQ_COLUMN_NAME from " + tableName + " where NTSS_TABLE_NAME = '" + ntssTableName + "'";
            DataRow[] dr = db.SelectTable(sql).Select();
            if (dr.Count() == 0)
            {
                WriteErrorLog(string.Format("ユニーク制約情報テーブル{0}にテーブル名{1}の設定がありません。", tableName, ntssTableName));
                return null;
            }
            else
            {
                return dr;
            }
        }

        /// <summary>
        /// FNWの列値を元にNTSSの外部キーを検索するSQLのマップ
        /// キー：対象列名
        /// 値：検索SQLのテンプレート
        /// </summary>
        /// <param name="ntssTableName"></param>
        /// <returns></returns>
        private Dictionary<string, string> MakeFkConvertValueMap(string ntssTableName)
        {
            Dictionary<string, string> dic = new Dictionary<string, string>();
            //mod #10418 start 
            var param = db.GetIMakeSqlParameters();
            param.AddParam(":NTSS_TABLE_NAME", ntssTableName);
            string sql = "select * from SYNC_FK_CONV_INFO where NTSS_TABLE_NAME=:NTSS_TABLE_NAME";
            DataTable dt = db.SelectTable(sql, param.GetParam());
            //mod #10418 end
            string templeteSql = "(select {0} from {1} where {2})";
            if (dt.Rows.Count > 0)
            {
                foreach (DataRow dr in dt.Rows)
                {
                    string itemName;
                    string selectColumnName;
                    if (!dr["NTSS_JSON_NAME"].ToString().Equals(""))
                    {

                        itemName = dr["NTSS_COLUMN_NAME"].ToString() + dr["NTSS_JSON_NAME"].ToString();
                        // JSON項目の場合、取得した値を文字列変換するようにする
                        // （JSON項目の値には文字列しか入らない想定のため）
                        //selectColumnName = dr["SELECT_COLUMN_NAME"].ToString() + "::character varying";

                        // 取得した列の型をそのまま使用するように変更
                        selectColumnName = dr["SELECT_COLUMN_NAME"].ToString();
                    }
                    else
                    {
                        itemName = dr["NTSS_COLUMN_NAME"].ToString();
                        selectColumnName = dr["SELECT_COLUMN_NAME"].ToString();
                    }

                    string selectTableName = dr["SELECT_TABLE_NAME"].ToString();
                    string condition = "";


                    if (dr["IS_FACILITY_CD"].ToString().Equals("y"))
                    {
                        condition = "facility_cd='" + this.facilityCd + "' AND ";
                    }

                    condition += dr["CONDITION_COLUMN_NAME"].ToString() + "::character varying='{0}'";

                    // 追加の主キー取得条件がある場合、追加する
                    if (!dr["OTHER_CONDITION"].ToString().Equals(""))
                    {
                        condition += " AND " + dr["OTHER_CONDITION"].ToString();
                    }

                    try
                    {
                        // add FNSI-class_cd設定対応 楊 start
                        // class_cd設定なしの場合、-1を設定
                        if ("mst_medicine_mix".Equals(ntssTableName) && "class_cd".Equals(itemName))
                        {
                            dic.Add(itemName, string.Format("(select COALESCE((select {0} from {1} where {2}), -1))",
                                                    selectColumnName,
                                                    selectTableName,
                                                    condition));
                        }
                        else
                        {
                            dic.Add(itemName, string.Format(templeteSql,
                                                        selectColumnName,
                                                        selectTableName,
                                                        condition));
                        }
                        //dic.Add(itemName, string.Format(templeteSql,
                        //                            selectColumnName,
                        //                            selectTableName,
                        //                            condition));
                        // add FNSI-class_cd設定対応 楊 end
                    }
                    catch (System.ArgumentException e)
                    {
                        WriteErrorLog("対象のキーは既に登録されています。キー名称:" + itemName);
                        throw e;
                    }
                }
            }
            return dic;
        }

        /// <summary>
        /// カラムに設定されているJson項目のリストのリストを受け取り、SQL文を返す
        /// </summary>
        /// <param name="jsonElementListList">Json項目のリストのリスト</param>
        /// <param name="jsonArrayType">Json配列タイプ</param>
        /// <param name="simpleConvertValueInfo">Case文SQLまたは値変換情報</param>
        /// <param name="fkConvertSqlMap">外部キー取得SQLマップ</param>
        /// <param name="customCovertValueSqlMap">カスタム値変換マップ</param>
        /// <param name="ntssRecord">カスタム値変換マップの置換文字列置換用の１レコード</param>
        /// <returns>SQL文</returns>
        private string MakeSqlBlockForJson(string ntssColumnName,
                                            List<List<JsonElement>> jsonElementListList,
                                            ConvertValueInfoBase simpleConvertValueInfo,
                                            Dictionary<string, string> fkConvertSqlMap,
                                            Dictionary<string, string> customCovertValueSqlMap,
                                            NtssRecord ntssRecord)
        {
            JsonDataFormat jsonDataFormat;
            // JSON項目が配列の場合のデフォルト値を[]に設定する
            if (jsonElementListList == null || jsonElementListList.Count == 0)
            {
                // JSON項目の値が無い場合、紐付け情報を元に挿入する値を判定する
                var relation = this.dtRelation.AsEnumerable().Where(row => row.Field<string>("NTSS_COLUMN_NAME") == ntssColumnName
                                                            && row.Field<string>("NTSS_TABLE_NAME") == this.convertTableName
                                                            && row.Field<string>("NTSS_COLUMN_TYPE") == NTSS_DATA_TYPE_JSONB
                                                            ).First();
                // JSONデータフォーマットを設定
                int num = int.Parse(relation["JSON_DATA_FORMAT"].ToString());
                jsonDataFormat = (JsonDataFormat)Enum.ToObject(typeof(JsonDataFormat), num);

                // nullの場合の設定値判定
                if (jsonDataFormat == JsonDataFormat.JsonArray)
                {
                    if (ntssColumnName.Equals("type_info") && convertTableName.Equals("mst_mainte_layout"))
                    {
                        return "json_build_array(" + ntssRecord.columns.Where(col => col.name.Equals("machine_type_cd")).First().value.ToString().Replace("''", "'") + ")";
                    }
                    // add 10378-24-4 PatTreatmentPattern再構築対応 zkm start
                    if (listNoConvWhenNullTbl.Contains(convertTableName))
                    // add 10378-24-4 PatTreatmentPattern再構築対応 zkm end
                    {
                        return "null";
                    }
                    return "json_build_array()";
                }
                else
                {
                    return "null";
                }
            }
            else
            {
                // JSONデータフォーマットの取得
                // 全JsonElementの１件目だけ取得
                jsonDataFormat = jsonElementListList[0][0].jsonDataFormat;
            }


            switch (jsonDataFormat)
            {
                case JsonDataFormat.ValueArray:
                    // 値の配列
                    // 例：[1,2,3,4]
                    return JsonSqlBuilder.BuildJsonArraySql(ntssColumnName,
                                                     jsonElementListList,
                                                        simpleConvertValueInfo,
                                                        fkConvertSqlMap,
                                                        customCovertValueSqlMap,
                                                        ntssRecord, convertTableName
                                                        );
                case JsonDataFormat.JsonNoArray:
                    // キーと値のセットのみ
                    // 例：{"A":1,"B":2,"C":3}

                    return JsonSqlBuilder.BuildJsonNoArray(ntssColumnName,
                                                    jsonElementListList,
                                                       simpleConvertValueInfo,
                                                       fkConvertSqlMap,
                                                       customCovertValueSqlMap,
                                                       ntssRecord, convertTableName
                                                       );



                //add 12029 zc start
                case JsonDataFormat.JsonDisItemInfo:

                    return JsonSqlBuilder.BuildJsonDisItemInfo(jsonElementListList, fnwTableName);
                //add 12029 zc end

                case JsonDataFormat.JsonManyArray:
                    // JSON配列
                    // 例：{[{"A":1,"B":2,"C":3},{"A":1,"B":2,"C":3}]}
                    return JsonSqlBuilder.BuildJsonManyArray(ntssColumnName,
                                                    jsonElementListList,
                                                       simpleConvertValueInfo,
                                                       fkConvertSqlMap,
                                                       customCovertValueSqlMap,
                                                       ntssRecord, convertTableName
                                                       );
                //add 7271 zc start
                case JsonDataFormat.JsonArray:
                    // JSON配列
                    // 例：{[{"A":1,"B":2,"C":3},{"A":1,"B":2,"C":3}]}
                    return JsonSqlBuilder.BuildJsonArray(ntssColumnName,
                                                    jsonElementListList,
                                                       simpleConvertValueInfo,
                                                       fkConvertSqlMap,
                                                       customCovertValueSqlMap,
                                                       ntssRecord, this.convertTableName
                                                       );

                case JsonDataFormat.JsonNest:
                    // 入れ子
                    // 例：{"a":{"A":1,"B":2,"C":3},"b":{"A":1,"B":2,"C":3}}
                    return JsonSqlBuilder.BuildJsonNest(ntssColumnName,
                                                    jsonElementListList,
                                                       simpleConvertValueInfo,
                                                       fkConvertSqlMap,
                                                       customCovertValueSqlMap,
                                                       ntssRecord, this.convertTableName
                                                       );

                default:
                    // エクセプション
                    return "";
            }

        }



        private string FormatJsonValueByValueType(JsonElement je)
        {
            // データ型に合わせて値を整形
            if (je.getValueDeleteEscape().Equals("null"))
            {
                // 空はnull
                return "null";
            }
            else if (je.jsonValueType == NTSS_DATA_TYPE_SMALLINT ||
                     je.jsonValueType == NTSS_DATA_TYPE_INTEGER ||
                     je.jsonValueType == NTSS_DATA_TYPE_BIGINT ||
                     je.jsonValueType == NTSS_DATA_TYPE_NUMERIC ||
                     je.jsonValueType == NTSS_DATA_TYPE_NUMBER)
            {
                if (je.getValueDeleteEscape().Length >= 2 &&
                    je.getValueDeleteEscape().Substring(0, 1).Equals("0"))
                {
                    // SQL→CSV形式でのコード変換時、コード変換前とコード変換後の型不一致対応
                    // ２文字以上で１文字目が0の場合、文字列として扱う
                    // mod #10191 djy start
                    return string.Format("'{0}'", je.getValueDeleteEscape());
                    // mod #10191 djy end
                }
                else
                {
                    //// 数値はそのまま(""で囲まない)
                    return je.getValueDeleteEscape();
                }
            }
            // add FNSI-exam_dateフォーマット対応 楊 start
            //else if (je.jsonValueType == "yyyyMMddHHmmss" || je.jsonValueType == "yyyyMMdd")
            else if (je.jsonValueType == "yyyyMMddHHmmss" || je.jsonValueType == "yyyyMMdd" || je.jsonValueType == "yyyy-MM-ddTHH:mm:sszzz" || je.jsonValueType == "yyyy-MM-ddTHH:mm:ss.fffzzz")
            // add FNSI-exam_dateフォーマット対応 楊 end
            {
                // 日付型はフォーマット
                var date = GetFormatedDate(je.getValueDeleteEscape());
                if (date == null)
                {
                    string errMsg = "JSON要素の値の日付型変換に失敗しました。key:" + je.getKeyNameDeleteEscape() + " value:" + je.getValueDeleteEscape();
                    WriteErrorLog(errMsg);
                    throw new Exception(errMsg);
                }
                else if (je.jsonValueType == "yyyyMMddHHmmss")
                {
                    return string.Format("'{0}'", ((DateTime)date).ToString("yyyyMMddHHmmss"));
                }
                // add FNSI-exam_dateフォーマット対応 楊 start
                //else
                else if (je.jsonValueType == "yyyyMMdd")
                // add FNSI-exam_dateフォーマット対応 楊 end
                {
                    return string.Format("'{0}'", ((DateTime)date).ToString("yyyyMMdd"));
                }
                // add FNSI-exam_dateフォーマット対応 楊 start
                else if (je.jsonValueType == "yyyy-MM-ddTHH:mm:sszzz")
                // add FNSI-exam_dateフォーマット対応 楊 end
                {
                    return string.Format("'{0}'", ((DateTime)date).ToString("yyyy-MM-ddTHH:mm:sszzz"));
                }
                else
                {
                    // ISO8601形式に変換
                    return string.Format("'{0}'", ((DateTime)date).ToString("yyyy-MM-ddTHH:mm:ss.fffzzz"));
                }
                // add FNSI-exam_dateフォーマット対応 楊 end
            }
            else if (je.jsonValueType == NTSS_DATA_TYPE_NUMBER)
            {
                // 文字列型は文字列('で囲む)(改行コード→\n、\→\\、ダブルクオーテーション→\"、タブ文字→\tに置換)
                // mod #10191 djy start
                return string.Format("'{0}'", je.getValueDeleteEscape());
                // mod #10191 djy end
            }
            else if (je.jsonValueType == NTSS_DATA_TYPE_BOOLEAN)
            {
                // booleanはそのまま(""で囲まない)
                return je.getValueDeleteEscape();
            }
            else if (je.jsonValueType == NTSS_DATA_TYPE_BOOL)
            {
                if (je.getValueDeleteEscape().Equals("1"))
                {
                    return "true";
                }
                else
                {
                    return "false";
                }

            }
            else
            {
                // 型が不明な場合は文字列型として扱う
                // mod #10191 djy start
                return string.Format("'{0}'", je.getValueDeleteEscape());
                // mod #10191 djy end
            }
        }

        /// <summary>
        /// ユニークキーの内訳のカラムと１レコードをチェックし、
        /// 内訳のカラムの値が全て設定されているユニークキーの名称を返す
        /// </summary>
        /// <param name="drConstraintInfo">制約情報のDataRowの配列</param>
        /// <param name="ntssRecord">１レコード</param>
        /// <returns>制約名</returns>
        private DataRow JudgementUniqueConstraint(DataRow[] drConstraintInfo,
                                                NtssRecord ntssRecord)
        {
            if (drConstraintInfo.Count() == 1)
            {
                // 判定不要
                return drConstraintInfo[0];
            }
            else
            {
                // 必要な列項目に値が設定されているかチェックし
                // ユニーク制約の内訳の列に値が格納されているものを使用する
                drConstraintInfo = drConstraintInfo.Where(dr =>
                {
                    return dr["UNIQUE_COLUMNS"].ToString().Split(',').All(s =>
                    {
                        return ntssRecord.columns.Any(ntsscol =>
                        {
                            if (ntsscol.name.Equals(s))
                            {
                                if (ntsscol.value == null)
                                {
                                    return false;
                                }
                                return !String.IsNullOrEmpty(ntsscol.value.ToString());
                            }
                            else
                            {
                                return false;
                            }
                        });
                    });
                }).ToArray();

                if (drConstraintInfo.Count() == 0)
                {
                    WriteErrorLog("使用しようとしたユニークキーに値が設定されていませんでした。");
                    throw new Exception("使用しようとしたユニークキーに値が設定されていませんでした。");
                }
                else
                {
                    // 複数件条件を満たす場合、１件目を設定する
                    return drConstraintInfo[0];
                }
            }
        }

        /// <summary>
        /// UPSERT文発行時にUPDATEが選択された際にシーケンスが採番されないようにCASE文で
        /// シーケンス取得を判定するためのCASE文生成
        /// </summary>
        /// <param name="drConstraintInfo"></param>
        /// <param name="ntssRecord"></param>
        /// <param name="ntssTableName"></param>
        /// <returns></returns>
        private string GetJudgeDoNextvalSql(DataRow drConstraintInfo,
                                                NtssRecord ntssRecord,
                                                string ntssTableName)
        {

            string sqlTemplete = "CASE (SELECT COUNT(*) FROM {0} WHERE {1})"
                    + " WHEN 0 THEN NEXTVAL('{2}')"
                    + " ELSE (SELECT {3} FROM {0} WHERE {1}) END";

            string whereBlock;
            string seqName;
            string seqColumnName;
            try
            {
                whereBlock = String.Join(" AND ", drConstraintInfo["UNIQUE_COLUMNS"].ToString().Split(',').Select(colName =>
                {
                    object colValue = ntssRecord.columns.Where(col => col.name.Equals(colName)).First().value;
                    // NULLチェック
                    if (colValue == null || string.IsNullOrEmpty(colValue.ToString()))
                    {
                        WriteErrorLog("GetJudgeDoNextvalSql実行時:ユニーク制約対象のカラム値がNULLです。（colName=" + colName + ")");
                        throw new Exception("GetJudgeDoNextvalSql実行時:ユニーク制約対象のカラム値がNULLです。（colName=" + colName + ")");
                    }
                    return colName + "::character varying='" + colValue.ToString() + "'";
                }).ToArray());
            }
            catch (Exception e)
            {
                throw new Exception(
                    "シーケンス対象カラム取得SQL作成に失敗しました。\r\n" +
                    "SYNC_UNIQUEに対象テーブルの設定が存在するか、\r\n" +
                    "またはSQLでユニークキー対象列を取得して紐づけ設定がされているか確認してください。\r\n" +
                    e.StackTrace);
            }
            seqColumnName = drConstraintInfo["NTSS_SEQ_COLUMN_NAME"].ToString();
            seqName = ntssTableName + "_" + drConstraintInfo["NTSS_SEQ_COLUMN_NAME"].ToString() + "_seq";
            return string.Format(sqlTemplete,
                ntssTableName,
                whereBlock,
                seqName,
                seqColumnName);
        }

        private Dictionary<string, string> MakeCustomCovertValueSqlMap(string ntssTableName)
        {
            return this.MakeCustomCovertValueSqlMap(ntssTableName, false);
        }
        /// <summary>
        /// カスタム値変換のための列名とSQLのマップを作成
        /// </summary>
        /// <param name="ntssTableName">テーブル名</param>
        /// <param name="isValueOnly">取得対象を変換設定VALUEのみに絞る</param>
        /// <returns>キー：対象列名、値：検索SQLのテンプレート のマップ</returns>
        private Dictionary<string, string> MakeCustomCovertValueSqlMap(string ntssTableName,
                                                                    bool isValueOnly)
        {
            Dictionary<string, string> dic = new Dictionary<string, string>();
            //mod #10418 start
            var param = db.GetIMakeSqlParameters();
            param.AddParam(":NTSS_TABLE_NAME", ntssTableName);
            // mod #9852 チェックリストマスタの種別：医療材料のコンバートについて zkm start
            string sql = "select NTSS_COLUMN_NAME,NTSS_JSON_NAME,CONV_VALUE_1,CONV_VALUE_2,CONV_VALUE_3  from  SYNC_CUSTOM_CONVERT_VALUE "
            // mod #9852 チェックリストマスタの種別：医療材料のコンバートについて zkm end
            + " where NTSS_TABLE_NAME = :NTSS_TABLE_NAME "
               + (isValueOnly ? " and CONVERSION_TYPE='VALUE' " : " and CONVERSION_TYPE='SQL' ")
               + " ORDER BY NTSS_COLUMN_NAME";
            DataTable dt = db.SelectTable(sql, param.GetParam());
            //mod #10418 end
            if (dt.Rows.Count > 0)
            {
                foreach (DataRow dr in dt.Rows)
                {
                    string itemName;
                    if (!dr["NTSS_JSON_NAME"].ToString().Equals(""))
                    {
                        itemName = dr["NTSS_COLUMN_NAME"].ToString() + dr["NTSS_JSON_NAME"].ToString();
                    }
                    else
                    {
                        itemName = dr["NTSS_COLUMN_NAME"].ToString();
                    }

                    // mod #9852 チェックリストマスタの種別：医療材料のコンバートについて zkm start
                    // string customSql = dr["CONV_VALUE_1"].ToString() + dr["CONV_VALUE_2"].ToString();
                    string customSql = dr["CONV_VALUE_1"].ToString() + dr["CONV_VALUE_2"].ToString() + dr["CONV_VALUE_3"].ToString();
                    // mod #9852 チェックリストマスタの種別：医療材料のコンバートについて zkm end

                    dic.Add(itemName, customSql);
                }
            }
            return dic;
        }

        /// <summary>
        /// SQLの置換変数を列の値およびJSON各キーの値に置き換える
        /// </summary>
        /// <param name="sql"></param>
        /// <param name="ntssRecord"></param>
        /// <param name="jsonElementList"></param>
        /// <param name="isNullReplacement">いずれかの置換変数がNullの場合、置換変数の置き換え処理を行わずにNullを返すか</param>
        /// <returns></returns>
        private string ReplaceSubstitutionVariablesToColumnValue(string sql,
                                                            NtssRecord ntssRecord,
                                                            List<JsonElement> jsonElementList,
                                                            bool isNullReplacement)
        {
            string replaceSql = sql;
            foreach (NtssColumn col in ntssRecord.columns)
            {
                // 置換変数が存在する場合
                if (replaceSql.Contains("{" + col.name + "}"))
                {
                    // 値がnullの項目が１つでもある場合、置換変数の置き換えを行わない
                    if (isNullReplacement && col.value == null)
                    {
                        return "null";
                    }
                    // mod #10191 djy start
                    //replaceSql = replaceSql.Replace("{" + col.name + "}", col.value.ToString());
                    replaceSql = MakeColumnSpecialFormat(replaceSql, col.name, col.value.ToString(), SpecialColumnType.SQL_STRING, true);
                    // mod #10191 djy end
                }
            }

            // JSONリストがある場合はこちらも置換する
            if (jsonElementList != null)
            {
                foreach (JsonElement e in jsonElementList)
                {
                    // 置換変数が存在する場合
                    if (replaceSql.Contains("{" + e.getKeyNameDeleteEscape() + "}"))
                    {
                        // 値がnullの項目が１つでもある場合、置換変数の置き換えを行わない
                        if (isNullReplacement && "null".Equals(e.getValueDeleteEscape()) && !(e.keyName.Contains("value_name_1") && this.convertTableName.Equals("ord_main")))
                        {
                            return "null";
                        }
                        // mod #10191 djy start
                        //replaceSql = replaceSql.Replace("{" + e.getKeyNameDeleteEscape() + "}", e.getValueDeleteEscape());
                        replaceSql = MakeColumnSpecialFormat(replaceSql, e.getKeyNameDeleteEscape(), e.getValueDeleteEscape().ToString(), SpecialColumnType.SQL_STRING, true);
                        // mod #10191 djy end
                    }
                }

                // add #9852 チェックリストマスタの種別：医療材料のコンバートについて zkm start
                var funcFlagRecord = jsonElementList.Where(e => e.getKeyNameDeleteEscape().StartsWith("FUNK_FLAG_") && "null" != e.getValueDeleteEscape());
                var funcFlags = string.Join(",", funcFlagRecord.Select(f => f.getValueDeleteEscape()).ToList());
                var classCdRecord = jsonElementList.Where(e => e.getKeyNameDeleteEscape().StartsWith("CLASS_CD_") && "null" != e.getValueDeleteEscape());
                var classCds = string.Join(",", classCdRecord.Select(f => f.getValueDeleteEscape()).ToList());
                if (replaceSql.Contains("{CLASS_CD_LIST}"))
                {
                    replaceSql = replaceSql.Replace("{CLASS_CD_LIST}", string.IsNullOrWhiteSpace(classCds) ? "0000" : classCds);
                }
                if (replaceSql.Contains("{FUNK_FLAG_LIST}"))
                {
                    replaceSql = replaceSql.Replace("{FUNK_FLAG_LIST}", string.IsNullOrWhiteSpace(funcFlags) ? "0000" : funcFlags);
                }
                List<string> classCdDefaultList = new List<string> { "201", "001", "002" };
                var keyRecord = classCdRecord.FirstOrDefault(cd => classCdDefaultList.Contains(cd.getValueDeleteEscape()));
                for (int i = 1; i < 11; i++)
                {
                    var classCdKey = "CLASS_CD_REPEAT_FLG_" + i;
                    if (keyRecord != null)
                    {
                        if (replaceSql.Contains("{" + classCdKey + "}"))
                        {
                            replaceSql = replaceSql.Replace("{" + classCdKey + "}", ("CLASS_CD_" + i) == keyRecord.getKeyNameDeleteEscape() ? "0" : "1");
                        }
                    }
                    else
                    {
                        if (replaceSql.Contains("{" + classCdKey + "}"))
                        {
                            replaceSql = replaceSql.Replace("{" + classCdKey + "}", "0");
                        }
                    }
                }

                // add #9852 チェックリストマスタの種別：医療材料のコンバートについて zkm end
            }
            //add 8332 zc start
            replaceSql = replaceSql.Replace("{name_3}", "");
            //add 8332 zc end

            // 未処理の置換変数が残っていないかチェック
            // del #10191 djy start
            //MatchCollection matche = Regex.Matches(replaceSql, @"(?<=\{).*?(?=\})");
            //var match2 = matche.Cast<Match>().Select(m => m.Groups[0].Value).Distinct();
            // del #10191 djy end
            //add  #7626  2022-05-16 鄭  start
            if (sql.Equals("json_build_object('telegram_format','ST,+{0:00000.00} kg[CR][LF]')"))
            {
                return replaceSql;
            }
            // add 7406  ReMS利用施設をコンバートすると送信先グループマスタや警報通知マスタなどのデータが消えている start
            if (sql.Equals("telegram_format=json_build_object('telegram_format','ST,+{0:00000.00} kg[CR][LF]')"))
            {
                return replaceSql;
            }
            // add 7406  ReMS利用施設をコンバートすると送信先グループマスタや警報通知マスタなどのデータが消えている end
            // del #10191 djy start
            //if (match2.Count() > 0)
            //{
            //    WriteErrorLog("置換処理に失敗した置換変数が残っています。変数リスト:[" + string.Join(",", match2.ToArray()) + "]");
            //    WriteErrorLog("置換後SQL:[" + replaceSql + "]");
            //    throw new Exception("置換処理に失敗した置換変数が残っています。変数リスト:[" + string.Join(",", match2.ToArray()) + "]");
            //}
            // del #10191 djy end
            return replaceSql;
        }

        // add FNSI-差分コンバート対応 楊 start
        /// <summary>
        /// SQLの置換変数を列の値おに置き換える
        /// </summary>
        /// <param name="sql"></param>
        /// <param name="col"></param>
        /// <param name="simpleConvertValueInfo"></param>
        /// <param name="ntssRecord"></param>
        /// <returns></returns>
        private string ReplaceVariablesToColumnValue(string sql, NtssColumn col, ConvertValueInfoBase simpleConvertValueInfo, NtssRecord ntssRecord)
        {
            string replaceSql = sql;
            // 置換変数が存在する場合
            if (replaceSql.Contains("{" + col.name + "}"))
            {
                var newValue = col.value.ToString();
                // 値変換対象のカラムの場合
                if (simpleConvertValueInfo.ContainsKey(col.name))
                {
                    string convertValue = simpleConvertValueInfo.GetConvertValue(col.name, col.value.ToString(),
                        ntssRecord, null);
                    newValue = ReplaceSubstitutionVariablesToColumnValue(convertValue, ntssRecord, null, true);
                }

                replaceSql = replaceSql.Replace("{" + col.name + "}", newValue);
            }
            if (this.convertTableName.Equals("mnt_mainte_main") || this.convertTableName.Equals("pat_coop_detail"))
            {
                return replaceSql;
            }
            return replaceSql.Replace("'", "");
        }

        /// <summary>
        /// SQLの置換変数を列の値およびJSON各キーの値に置き換える
        /// （JSONの全リストから置換するため、JSONの値が一意になっているとき以外使用しないこと）
        /// </summary>
        /// <param name="sql"></param>
        /// <param name="ntssRecord"></param>
        /// <param name="jsonElementList"></param>
        /// <returns></returns>
        private string ReplaceSubstitutionVariablesToColumnValueWithJsonData(string sql,
                                                            NtssRecord ntssRecord,
                                                            List<List<JsonElement>> jsonElementListList)
        {
            string replaceSql = sql;
            //ntssRecord.columns.ForEach(col => replaceSql = replaceSql.Replace("{" + col.name + "}", col.value == null ? "" : col.value.ToString()));

            // JSONリストがある場合はこちらも置換する
            if (jsonElementListList != null)
            {
                var nameStr = string.Empty;

                // name以外項目置換
                foreach (JsonElement e in jsonElementListList[0])
                {
                    if (e.keyName.Contains("env_name"))
                    {
                        if (!"null".Equals(e.getValueDeleteEscape()))
                        {
                            nameStr += ", json_build_object('name:', '" + e.getValueDeleteEscape() + "')";
                        }
                    }
                    else
                    {

                        replaceSql = replaceSql.Replace("{" + e.getKeyNameDeleteEscape() + "}", e.getValueDeleteEscape());
                        //add  8332  zc start
                        string colValue = ntssRecord.columns.Where(col => col.name.Equals("va_flg")).First().value.ToString();
                        int imageNum = int.Parse(ntssRecord.columns.Where(col => col.name.Equals("env_imageNum")).First().value.ToString());

                        string names = string.Empty;
                        if (colValue.Equals("1"))
                        {
                            if (imageNum == 0)
                            {
                                // MOD 8604 周トウ ADLについて: 1. VA管理のVA　→ドロップダウンを削除して 2.VA管理の「造設日」追加 START
                                /*replaceSql = "json_build_array (VARIADIC ARRAY [json_build_object ( 'item_json', json_build_object('sql_cd', 135,'values',{mst_va},'source_field','mst_va' ), 'field_name', 'VA名', 'is_rst_copy', '0', 'format_class', 3, 'is_field_display', '1' ),json_build_object ( 'item_json', json_build_object('sql_cd','','html_value','<p id=\"text-p-2\" style=\"font-size: 14pt; font-family: メイリオ;\">﻿</p>','max_length',1000,'source_field',0,'default_value','','is_formatting','1'), 'field_name', 'コメント', 'is_rst_copy', '0', 'format_class', 1 , 'is_field_display', '1' ),json_build_object ( 'item_json', json_build_object('max_size', '200'), 'field_name', '添付ファイル', 'is_rst_copy', 0, 'format_class', 7,'is_field_display', 1 ) ] ) :: jsonb";*/
                                replaceSql = "json_build_array (VARIADIC ARRAY [json_build_object ( 'item_json', json_build_object('sql_cd','','html_value','<p id=\"text-p-2\" style=\"font-size: 14pt; font-family: メイリオ;\">﻿</p>','max_length','1000','source_field',0,'default_value','','is_formatting','1'), 'field_name', 'コメント', 'is_rst_copy', '0', 'format_class', 1 , 'is_field_display', '1' ),json_build_object('item_json', json_build_object(), 'field_name', '造設日', 'is_rst_copy', '1', 'format_class', 5, 'is_field_display', '1'),json_build_object ( 'item_json', json_build_object('max_size', '20480'), 'field_name', '添付ファイル', 'is_rst_copy', '0', 'format_class', 7,'is_field_display', 1 ) ] ) :: jsonb";
                                // MOD 8604 周トウ ADLについて END
                            }
                            else
                            {
                                for (int i = 1; i < imageNum + 1; i++)
                                {
                                    string photo = ntssRecord.columns.Where(col => col.name.Equals("photo" + i)).First().value == null ? "" : ntssRecord.columns.Where(col => col.name.Equals("photo" + i)).First().value.ToString();
                                    names += "json_build_object('name', '" + photo + "'),";
                                }
                                names = names.Substring(0, names.Length - 1);
                                // MOD 8604 周トウ ADLについて: 1. VA管理のVA　→ドロップダウンを削除して 2.VA管理の「造設日」追加 START
                                /*replaceSql = "json_build_array (VARIADIC ARRAY [json_build_object ( 'item_json', json_build_object('sql_cd', 135,'values',{mst_va},'source_field','mst_va' ), 'field_name', 'VA名', 'is_rst_copy', '0', 'format_class', 3, 'is_field_display', '1' ),json_build_object ('item_json',json_build_object ( 'values', json_build_array ( VARIADIC ARRAY [ " + names + " ] ), 'image_num', '{env_imageNum}', 'image_col_num', '{env_imageColNum}' ),'field_name','VA画像','is_rst_copy','0','format_class',2,'is_field_display','0' ),json_build_object ( 'item_json', json_build_object('sql_cd','','html_value','<p id=\"text-p-2\" style=\"font-size: 14pt; font-family: メイリオ;\">﻿</p>','max_length',1000,'source_field',0,'default_value','','is_formatting','1'), 'field_name', 'コメント', 'is_rst_copy', '0', 'format_class', 1 , 'is_field_display', '1' ),json_build_object ( 'item_json', json_build_object('max_size', '200'), 'field_name', '添付ファイル', 'is_rst_copy', 0, 'format_class', 7,'is_field_display', '1' ) ] ) :: jsonb";*/
                                replaceSql = "json_build_array (VARIADIC ARRAY [json_build_object ('item_json',json_build_object ( 'values', json_build_array ( VARIADIC ARRAY [ " + names + " ] ), 'image_num', '{env_imageNum}', 'image_col_num', '{env_imageColNum}' ),'field_name','VA画像','is_rst_copy','0','format_class',2,'is_field_display','0' ),json_build_object ( 'item_json', json_build_object('sql_cd','','html_value','<p id=\"text-p-2\" style=\"font-size: 14pt; font-family: メイリオ;\">﻿</p>','max_length','1000','source_field',0,'default_value','','is_formatting','1'), 'field_name', 'コメント', 'is_rst_copy', '0', 'format_class', 1 , 'is_field_display', '1' ),json_build_object('item_json', json_build_object(), 'field_name', '造設日', 'is_rst_copy', '1', 'format_class', 5, 'is_field_display', '1'),json_build_object ( 'item_json', json_build_object('max_size', '20480'), 'field_name', '添付ファイル', 'is_rst_copy', '0', 'format_class', 7,'is_field_display', '1' ) ] ) :: jsonb";
                                // MOD 8604 周トウ ADLについて END
                            }
                        }
                        else
                        {
                            if (imageNum == 0)
                            {
                                replaceSql = "json_build_array (VARIADIC ARRAY [json_build_object ( 'item_json', json_build_object('sql_cd', '','max_length','128','source_field',0 ,'default_value',''), 'field_name', 'タイトル', 'is_rst_copy', '0', 'format_class', 0, 'is_field_display', '1' ),json_build_object ( 'item_json', json_build_object('sql_cd','','html_value','<p id=\"text-p-2\" style=\"font-size: 14pt; font-family: メイリオ;\">﻿</p>','max_length',4000,'source_field',0,'default_value','','is_formatting','1'), 'field_name', 'コメント', 'is_rst_copy', '0', 'format_class', 1 , 'is_field_display', '1' ),json_build_object ( 'item_json', json_build_object('max_size', '20480'), 'field_name', '添付ファイル', 'is_rst_copy', '0', 'format_class', 7,'is_field_display', 1 ) ] ) :: jsonb";

                            }
                            else
                            {
                                for (int i = 1; i < imageNum + 1; i++)
                                {
                                    string photo = ntssRecord.columns.Where(col => col.name.Equals("photo" + i)).First().value == null ? "" : ntssRecord.columns.Where(col => col.name.Equals("photo" + i)).First().value.ToString();
                                    names += "json_build_object('name', '" + photo + "'),";
                                }
                                names = names.Substring(0, names.Length - 1);
                                replaceSql = "json_build_array (VARIADIC ARRAY [json_build_object ( 'item_json', json_build_object('sql_cd', '','max_length','128','source_field',0,'default_value','' ), 'field_name', 'タイトル', 'is_rst_copy', '0', 'format_class', 0, 'is_field_display', '1' ),json_build_object ('item_json',json_build_object ( 'values', json_build_array ( VARIADIC ARRAY [" + names + "] ), 'image_num', '{env_imageNum}', 'image_col_num', '{env_imageColNum}' ),'field_name','画像','is_rst_copy','0','format_class',2,'is_field_display','0' ),json_build_object ( 'item_json', json_build_object('sql_cd','','html_value','<p id=\"text-p-2\" style=\"font-size: 14pt; font-family: メイリオ;\">﻿</p>','max_length',4000,'source_field',0,'default_value','','is_formatting','1'), 'field_name', 'コメント', 'is_rst_copy', '0', 'format_class', 1 , 'is_field_display', '1' ),json_build_object ( 'item_json', json_build_object('max_size', '20480'), 'field_name', '添付ファイル', 'is_rst_copy', '0', 'format_class', 7,'is_field_display', '1' ) ] ) :: jsonb";

                            }

                        }
                        ntssRecord.columns.ForEach(col => replaceSql = replaceSql.Replace("{" + col.name + "}", col.value == null ? "" : col.value.ToString()));
                        //add  8332  zc end
                    }
                }
                // name置換
                if (string.IsNullOrWhiteSpace(nameStr))
                {
                    replaceSql = replaceSql.Replace("{env_name}", "json_build_object()");
                }
                else
                {
                    if (nameStr.Contains("SOAP"))
                    {
                        //mod  #8248 患者イベントが一部コンバートされていない 楊  start 
                        return "json_build_array (VARIADIC ARRAY [json_build_object ( 'item_json', json_build_object('sql_cd', '','html_value', '<p id=\"text-p-0\" style=\"font-size: 14pt; font-family: メイリオ;\">﻿</p>','max_length', '500','source_field', 0,'default_value', '','is_formatting', '1'), 'field_name', 'S', 'is_rst_copy', '0', 'format_class', 1, 'is_field_display', '1' ),json_build_object ( 'item_json', json_build_object('sql_cd', '','html_value', '<p id=\"text-p-1\" style=\"font-size: 14pt; font-family: メイリオ;\">﻿</p>','max_length', '500','source_field', 0,'default_value', '','is_formatting', '1'), 'field_name', 'O', 'is_rst_copy', '0', 'format_class', 1, 'is_field_display', '1' ),json_build_object ( 'item_json', json_build_object('sql_cd', '','html_value', '<p id=\"text-p-2\" style=\"font-size: 14pt; font-family: メイリオ;\">﻿</p>','max_length', '500','source_field', 0,'default_value', '','is_formatting', '1'), 'field_name', 'A', 'is_rst_copy', '0', 'format_class', 1, 'is_field_display', '1' ),json_build_object ( 'item_json', json_build_object('sql_cd', '','html_value', '<p id=\"text-p-3\" style=\"font-size: 14pt; font-family: メイリオ;\">﻿</p>','max_length', '500','source_field', 0,'default_value', '','is_formatting', '1'), 'field_name', 'P', 'is_rst_copy', '0', 'format_class', 1, 'is_field_display', '1' ),json_build_object ( 'item_json', json_build_object(),'field_name', '実績リンク', 'is_rst_copy', '0', 'format_class', 9, 'is_field_display', '1' ),json_build_object ( 'item_json', json_build_object('kind_no', (SELECT kind_no FROM mst_bbs_kind WHERE kind_name='観察記録（SOAP）' AND facility_cd='" + this.facilityCd + "' LIMIT 1 )),'field_name', 'bbs5" + DateTime.Now.ToString("yyyyMMddhhmmss") + "', 'is_rst_copy', '0', 'format_class', 10, 'is_field_display', '0' ) ] ) :: jsonb";
                        //mod  #8248 患者イベントが一部コンバートされていない 楊  end 
                    }
                    else if (nameStr.Contains("TEXT"))
                    {
                        //mod  10164 djy start
                        //return "json_build_array (VARIADIC ARRAY [json_build_object ( 'item_json', json_build_object('sql_cd', '','html_value', '<p id=\"text-p-0\" style=\"font-size: 14pt; font-family: メイリオ;\">﻿</p>','max_length', '2000','source_field', 0,'default_value', '','is_formatting', '1'), 'field_name', 'TEXT', 'is_rst_copy', '0', 'format_class', 1, 'is_field_display', '1' ),json_build_object ( 'item_json', json_build_object(),'field_name', '実績リンク', 'is_rst_copy', '0', 'format_class', 9, 'is_field_display', '1' ),json_build_object ( 'item_json', json_build_object('kind_no', (SELECT kind_no FROM mst_bbs_kind WHERE kind_name='観察記録' AND facility_cd='" + this.facilityCd + "' LIMIT 1 )),'field_name', 'bbs1" + DateTime.Now.ToString("yyyyMMddhhmmss") + "', 'is_rst_copy', '0', 'format_class', 10, 'is_field_display', '0' ) ] ) :: jsonb";
                        return "json_build_array (VARIADIC ARRAY [json_build_object ( 'item_json', json_build_object('sql_cd', '','html_value', '<p id=\"text-p-0\" style=\"font-size: 14pt; font-family: メイリオ;\">﻿</p>','max_length', '2000','source_field', 0,'default_value', '','is_formatting', '1'), 'field_name', 'TEXT', 'is_rst_copy', '0', 'format_class', 1, 'is_field_display', '0' ),json_build_object ( 'item_json', json_build_object(),'field_name', '実績リンク', 'is_rst_copy', '0', 'format_class', 9, 'is_field_display', '1' ),json_build_object ( 'item_json', json_build_object('kind_no', (SELECT kind_no FROM mst_bbs_kind WHERE kind_name='観察記録' AND facility_cd='" + this.facilityCd + "' LIMIT 1 )),'field_name', 'bbs1" + DateTime.Now.ToString("yyyyMMddhhmmss") + "', 'is_rst_copy', '0', 'format_class', 10, 'is_field_display', '0' ) ] ) :: jsonb";
                        //mod  10164 djy end
                    }
                   

                    // Add 8604 周トウ ADLについて START
                    else if (nameStr.Contains("ADL"))
                    {
                        return CommonConstants.PAT_ADL_INPUT_PARAM;
                    }
                    else if (nameStr.Contains("心身状況"))
                    {
                        return CommonConstants.PAT_PHY_STAT_INPUT_PARAM;
                    }
                    // Add 8604 周トウ ADLについて END

                    replaceSql = replaceSql.Replace("{env_name}", nameStr.Substring(2));
                }
            }
            //add  8332  zc start
            replaceSql = replaceSql.Replace("'null'", "null");
           
            return replaceSql;
        }
        // add FNSI-差分コンバート対応 楊 end

        /// <summary>
        /// SQLの置換変数を列の値およびJSON各キーの値に置き換える
        /// （JSONの全リストから置換するため、JSONの値が一意になっているとき以外使用しないこと）
        /// </summary>
        /// <param name="sql"></param>
        /// <param name="ntssRecord"></param>
        /// <param name="jsonElementList"></param>
        /// <returns></returns>
        private string ReplaceSubstitutionVariablesToColumnValueWithJsonAllData(string sql,
                                                            NtssRecord ntssRecord,
                                                            List<List<JsonElement>> jsonElementListList)
        {
            //add  2022-03-28 データが空でnullを返す 鄭  start  
            if (jsonElementListList.Count == 0)
            {

                return "NULL";
            }
            //add  2022-03-28 データが空でnullを返す 鄭  end  
            string replaceSql = sql;
            if (this.convertTableName.Equals("ord_treat_condition"))
            {
                ntssRecord.columns.ForEach(col => replaceSql = replaceSql.Replace("{" + col.name + "}", (DBNull.Value.Equals(col.value) || col.value == null || col.value.Equals("")) ? "null" : col.value.ToString()));
            }
            else
            {
                ntssRecord.columns.ForEach(col => replaceSql = replaceSql.Replace("{" + col.name + "}", col.value == null ? "" : col.value.ToString()));
            }

            // JSONリストがある場合はこちらも置換する
            if (jsonElementListList != null)
            {
                jsonElementListList.ForEach(list =>
                    list.ForEach(e =>
                        replaceSql = replaceSql.Replace("{" + e.getKeyNameDeleteEscape() + "}", e.getValueDeleteEscape())));
            }


            // 'null' の文字列を null に変換する
            replaceSql = replaceSql.Replace("'null'", "null");
            
            return replaceSql;
        }


        // add FNSI-差分コンバート対応 楊 end

        //add 7800 鄭晨 start
        /// <summary>
        /// SQLの置換変数を列の値およびJSON各キーの値に置き換える
        /// （JSONの全リストから置換するため、JSONの値が一意になっているとき以外使用しないこと）
        /// </summary>
        /// <param name="data_type"></param>
        /// <param name="sql"></param>
        /// <param name="ntssRecord"></param>
        /// <param name="jsonElementList"></param>
        /// <returns></returns>
        private string ReplaceSubstitutionVariablesToColumnValueWithJsonMonitorData(string data_type, string sql,
                                                            NtssRecord ntssRecord,
                                                            List<List<JsonElement>> jsonElementListList)
        {

            if (jsonElementListList.Count == 0)
            {
                return "NULL";
            }

            string replaceSql = sql;
            ntssRecord.columns.ForEach(col => replaceSql = replaceSql.Replace("{" + col.name + "}", col.value == null ? "" : col.value.ToString()));

            // JSONリストがある場合はこちらも置換する
            if (jsonElementListList != null)
            {
                jsonElementListList.ForEach(list =>
                    list.ForEach(e =>
                        replaceSql = replaceSql.Replace("{" + e.getKeyNameDeleteEscape() + "}", e.getValueDeleteEscape())));
            }

            // 'null' の文字列を null に変換する
            replaceSql = replaceSql.Replace("'null'", "null");
            //add 7966 周 start
            replaceSql = "{" + replaceSql.Replace("'", "\"") + "}";
            var str = replaceSql;
            var obj = JsonConvert.DeserializeObject(str);
            List<string> JSONLIST = new List<string>();
            foreach (var x in obj as JObject)
            {
                //mod #12448 start
                if (!string.IsNullOrEmpty(x.Value.ToString()) && !"null".Equals(x.Value.ToString()))
                {
                    // 1：モニタ(キーは89のデータを追加しない) 3：再循環率(89のキーのみ)
                    if ((data_type.Equals("1") && x.Key == "89") || (data_type.Equals("3") && x.Key != "89"))
                    {
                        continue;
                    }
                    JSONLIST.Add($"\"{ x.Key}\":\"{x.Value}\"");

                }
                //mod #12448 end
            }
            if (JSONLIST.Count > 0)
            {
                replaceSql = "'{" + string.Join(",", JSONLIST) + "}'::jsonb";
            }
            else
            {
                replaceSql = "json_build_object()::jsonb";
            }

            //add 7966 周 end　
            return replaceSql;
        }
        //add 7800 鄭晨 end


        private void MakeSimpleConvertValueMapForDirectValue(ConvertValueInfoBase convertValueInfoBase,
                                                            string ntssTableName)
        {
            this.MakeSimpleConvertValueMapForDirectValue(convertValueInfoBase,
                                                        ntssTableName,
                                                        false);
        }

        /// <summary>
        /// 値変換のためのキーと対象値と変換値のマップを生成する
        /// キーは列名または列名＋JSON項目名
        /// </summary>
        /// <param name="simpleConvertValueMap">変換用オブジェクト</param>
        /// <param name="ntssTableName">NTSSテーブル名</param>
        /// <param name="isValueOnly">取得対象を変換設定VALUEのみに絞る</param>
        private void MakeSimpleConvertValueMapForDirectValue(ConvertValueInfoBase convertValueInfoBase,
                                                            string ntssTableName,
                                                            bool isValueOnly)
        {
            //mod #10418 start 
            var param = db.GetIMakeSqlParameters();
            param.AddParam(":NTSS_TABLE_NAME", ntssTableName);

            string sql = "select * "
                    + " from SYNC_CONV_VALUE where NTSS_TABLE_NAME = :NTSS_TABLE_NAME"
                    + (isValueOnly ? " and CONVERSION_TYPE='VALUE' " : "") // フラグ分岐
                    + " order by ntss_column_name,sort";
            DataTable dt = db.SelectTable(sql, param.GetParam());
            //mod #10418 end 
            string key;
            string oldValue;
            string newValue;
            foreach (DataRow dr in dt.Rows)
            {
                key = dr["NTSS_COLUMN_NAME"].ToString() + dr["NTSS_JSON_NAME"].ToString();
                oldValue = dr["TARGET_VALUE"].ToString();
                newValue = dr["CONV_VALUE"].ToString();
                // add 7661 周 start
                if (this.fnwTableName != null && this.fnwTableName.Equals("SYS_CUSTOM_KEY") && ntssTableName.Equals("pat_group"))
                {
                    continue;
                }
               
                convertValueInfoBase.AddConvertValueMap(key, oldValue, newValue);
            }

        }

        /// <summary>
        /// 値変換のための列名＋JSON名で参照しなければならない列名を取得するマップを作成し、インスタンス変数に設定する
        /// </summary>
        /// <param name="ntssTableName"></param>
        /// <returns></returns>
        private Dictionary<string, string> MakeItemNameToColumnNameMap(string ntssTableName)
        {
            //mod #10418 start 
            var param = db.GetIMakeSqlParameters();
            param.AddParam(":NTSS_TABLE_NAME", ntssTableName);

            string sql = "select NTSS_COLUMN_NAME,NTSS_JSON_NAME,DECISION_TARGET_COLUMN_NAME from SYNC_CONV_VALUE " +
                "where NTSS_TABLE_NAME =:NTSS_TABLE_NAME " +
                "and DECISION_TARGET_COLUMN_NAME is not null group by NTSS_COLUMN_NAME,NTSS_JSON_NAME,DECISION_TARGET_COLUMN_NAME";
            return this.db.SelectTable(sql, param.GetParam()).AsEnumerable().ToDictionary(row =>
                row["NTSS_COLUMN_NAME"].ToString() + row["NTSS_JSON_NAME"].ToString(),
                row => row["DECISION_TARGET_COLUMN_NAME"].ToString());
            //mod #10418 end 
        }

        /// <summary>
        /// マップに格納された文字列を元にSQLファイルへ書き込み
        /// </summary>
        /// <param name="sqlFilePath"></param>
        /// <param name="encoding"></param>
        private void WriteSqlFile(bool isMakePatidFolder,
            Dictionary<string, List<string>> sqlMap,
            string sqlFilePath,
            int chunkSize,
            Dictionary<string, List<string>> sqlKeyMap)
        {
            //add 6886 zc start
            if (sqlFilePath.IndexOf("pat_unique_history") > 0)
            {
                chunkSize = 200;
            }
            //add 6886 zc end
            if (isMakePatidFolder)
            {
                // 作成ルートディレクトリの取得
                string rootDirectory = Path.GetDirectoryName(sqlFilePath);

                // 施設コードでフォルダ作成
                string facilityCdDirectory = rootDirectory + "/" + facilityCd;
                if (!Directory.Exists(facilityCdDirectory))
                {
                    Directory.CreateDirectory(facilityCdDirectory);
                }

                // PatId毎に書き込む場所、ファイルを変更する
                foreach (KeyValuePair<string, List<string>> kvp in sqlMap)
                {
                    // 患者IDでフォルダ作成
                    string patidDirectory = facilityCdDirectory + "/" + kvp.Key;

                    //mod #12229 dialysis差分の場合 、患者フォルダを生成しない start
                    bool isDiffDialysisFile = !(CommonConfig.isDiff && sqlFilePath.Contains("dialysis[diff]"));
                    if (isDiffDialysisFile)
                    {
                        if (!Directory.Exists(patidDirectory))
                        {
                            Directory.CreateDirectory(patidDirectory);
                        }
                    }
                    //mod #12229 dialysis差分の場合 、患者フォルダを生成しない end

                    // add FNSI-差分コンバート対応 楊 start
                    // chunkSizeより、keyを作成
                    List<string> keyStrList = new List<string>();
                    var keyStrs = "";
                    var index = 0;
                    if (null != sqlKeyMap && sqlKeyMap.Count() > 0)
                    {
                        foreach (String keyStr in sqlKeyMap[kvp.Key])
                        {
                            if (index < chunkSize)
                            {
                                keyStrs += keyStr + ",";
                                index++;
                            }
                            else
                            {
                                keyStrList.Add(keyStrs.Substring(0, keyStrs.Length - 1));
                                keyStrs = "";
                                keyStrs += keyStr + ",";
                                index = 1;
                            }
                        }
                        if (!String.IsNullOrEmpty(keyStrs))
                        {
                            keyStrList.Add(keyStrs.Substring(0, keyStrs.Length - 1));
                        }
                    }
                    // add FNSI-差分コンバート対応 楊 end
                    string sqlFilePathPatid = patidDirectory + "/" + this.convertTableName + ".sql";
                    this.chunkAndWriteFile(kvp.Value, sqlFilePathPatid, chunkSize, keyStrList);
                }
            }
            else
            {
                List<String> sqlList = sqlMap.SelectMany(x => x.Value).ToList();
                // add FNSI-差分コンバート対応 楊 start
                // chunkSizeより、keyを作成
                List<string> keyStrList = new List<string>();
                var keyStrs = "";
                var index = 0;
                if (null != sqlKeyMap && sqlKeyMap.Count() > 0)
                {
                    foreach (String keyStr in sqlKeyMap["default"])
                    {
                        if (index < chunkSize)
                        {
                            keyStrs += keyStr + ",";
                            index++;
                        }
                        else
                        {
                            keyStrList.Add(keyStrs.Substring(0, keyStrs.Length - 1));
                            keyStrs = "";
                            keyStrs += keyStr + ",";
                            index = 1;
                        }
                    }
                    if (!String.IsNullOrEmpty(keyStrs))
                    {
                        keyStrList.Add(keyStrs.Substring(0, keyStrs.Length - 1));
                    }
                }
                this.chunkAndWriteFile(sqlList, sqlFilePath, chunkSize, keyStrList);
                // add FNSI-差分コンバート対応 楊 end
            }
        }


        private static readonly object sql_fileWriteLock = new object();

        private static int sql_fileIndex = 1;
        private static int sqlcurrentFileRowCount = 0;

        private const int sqlMaxRowsPerFile = 1000;
        private const int BufferLines = 500;

        private static void FlushBuffer(
            string directory,
            string fileNameWithoutExtension,
            string extension,
            List<string> buffer)
        {
            lock (sql_fileWriteLock)
            {
                // 現在のファイルが満杯の場合、新しいファイルを切り替える 如果当前文件已满,切新文件
                if (sqlcurrentFileRowCount >= sqlMaxRowsPerFile)
                {
                    sql_fileIndex++;
                    sqlcurrentFileRowCount = 0;
                }

                string path = Path.Combine(
                    directory,
                    $"{fileNameWithoutExtension}_{sql_fileIndex.ToString().PadLeft(4, '0')}{extension}"
                );

                using (FileStream fs = new FileStream(
                    path, FileMode.Append, FileAccess.Write, FileShare.Read))
                {
                    string data = string.Join("\r\n", buffer) + "\r\n";
                    byte[] bytes = Encoding.UTF8.GetBytes(data);
                    fs.Write(bytes, 0, bytes.Length);

                    sqlcurrentFileRowCount += buffer.Count;
                    CommonConfig.schLen += buffer.Count;
                }

                buffer.Clear();
            }
        }

        /// <summary>
        /// SQLファイルリストを分割して書き込み
        /// </summary>
        /// <param name="sqlList"></param>
        /// <param name="filePath"></param>
        /// <param name="chunkSize"></param>
        /// <param name="encoding"></param>
        private void chunkAndWriteFile(List<string> sqlList, string filePath, int chunkSize, List<String> sqlKeyList)
        {
            // リスト分割
            var chunkList = sqlList.Select((v, i) => new { v, i })
                .GroupBy(x => x.i / chunkSize)
                .Select(g => g.Select(x => x.v));

            // ディレクトリ名の取得
            string directory = System.IO.Path.GetDirectoryName(filePath);

            // 拡張子の取得
            string extension = System.IO.Path.GetExtension(filePath);

            // ファイル名（拡張子なし）の取得
            string fileNameWithoutExtension = System.IO.Path.GetFileNameWithoutExtension(filePath);

            // 分割数毎にファイル書き込み
            int index = 1;

            // ファイルが既に存在する場合、インデックスを加算する
            string sqlFilePathForExistsCheck = directory +
                    "/" + fileNameWithoutExtension +
                    "_" + index.ToString().PadLeft(4, '0')
                    + extension;

            while (File.Exists(sqlFilePathForExistsCheck))
            {
                index++;
                sqlFilePathForExistsCheck = directory +
                    "/" + fileNameWithoutExtension +
                    "_" + index.ToString().PadLeft(4, '0')
                    + extension;

            }

            //add 12229 すべての患者データを1つのファイルに保存し、1ファイルあたり最大1000件までとする  start
            if (CommonConfig.isDiff)
            {

                string sqlFilePath = System.IO.Path.GetDirectoryName(directory);
                if ("ord_weight_scale".Equals(fileNameWithoutExtension) || "ord_treat_condition".Equals(fileNameWithoutExtension)
                    || "ord_coop_no".Equals(fileNameWithoutExtension))
                {

                    List<string> buffer = new List<string>(BufferLines);

                    foreach (var chunk in chunkList)
                    {
                        foreach (var line in chunk)
                        {
                            buffer.Add(line);
                            if (buffer.Count >= BufferLines ||
                                sqlcurrentFileRowCount + buffer.Count >= sqlMaxRowsPerFile)
                            {
                                FlushBuffer(sqlFilePath, fileNameWithoutExtension, extension, buffer);
                            }
                        }
                    }

                    if (buffer.Count > 0)
                    {
                        FlushBuffer(sqlFilePath, fileNameWithoutExtension, extension, buffer);
                    }
                    return;
                }
                else if ("ord_main".Equals(fileNameWithoutExtension) || "mni_monitor".Equals(fileNameWithoutExtension)
                    || "pat_ind_approve".Equals(fileNameWithoutExtension) || "pat_ind_approve_history".Equals(fileNameWithoutExtension))
                {
                    var writer = CommonConfig.writerMapType[fileNameWithoutExtension];

                    List<string> keyList = sqlKeyList
                            .SelectMany(s => s.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
                            .Select(s => s.Trim())
                            .ToList();
                    for (int i = 0; i < sqlList.Count; i++)
                    {
                        writer.Add(keyList[i], sqlList[i]);
                    }
                    return;

                }

            }
            //add 12229 すべての患者データを1つのファイルに保存し、1ファイルあたり最大1000件までとする start

            // add FNSI-差分コンバート対応 楊 start
            var idx = 0;
            // add FNSI-差分コンバート対応 楊 end
            foreach (var chunk in chunkList)
            {
                string sqlFilePathWithIndex = directory +
                    "/" + fileNameWithoutExtension +
                    "_" + index.ToString().PadLeft(4, '0')
                    + extension;

                // mod FNSI-#7340 PC側アプリの出力が遅い limingyang start
                // 患者ID毎にSQLファイル書き込み
                /* using (var sw = new StreamWriter(sqlFilePathWithIndex, true, encoding))
                 {
                     // add FNSI-差分コンバート対応 楊 start
                     // 毎sqlにkeyを追加
                     if (null != sqlKeyList && sqlKeyList.Count > 0)
                     {
                         sw.WriteLine(sqlKeyList[idx].ToString());
                     }

                     // add FNSI-差分コンバート対応 楊 end
                     foreach (var sql in chunk)
                     {
                         sw.WriteLine(sql);
                     }
                 }*/
                // 患者ID毎にSQLファイル書き込み
                using (FileStream fsWrite = new FileStream(sqlFilePathWithIndex, FileMode.Append, FileAccess.Write))
                {
                    byte[] myByte = null;
                    if (null != sqlKeyList && sqlKeyList.Count > 0)
                    {
                        myByte = Encoding.UTF8.GetBytes(sqlKeyList[idx] + "\r\n");
                        fsWrite.Write(myByte, 0, myByte.Length);
                    }
                    myByte = Encoding.UTF8.GetBytes(String.Join("\r\n", chunk.ToList()));
                    fsWrite.Write(myByte, 0, myByte.Length);
                }
                // mod FNSI-#7340 PC側アプリの出力が遅い limingyang end
                // add FNSI-差分コンバート対応 楊 start
                idx++;
                // add FNSI-差分コンバート対応 楊 end
                index++;
                //add 9815 zc start
                CommonConfig.schLen += chunk.Count();
                //add 9815 zc end
            }

            // add 2022-11-15 bug #7882 患者イベントのVA画像がコンバートされていない 孫 start
            // 追加ファイルを取得する
            // mod #9801 zl start
            if (("pat_event".Equals(fileNameWithoutExtension) || "bbs_info".Equals(fileNameWithoutExtension)) && sqlList.Count > 0)
            {
                // mod #9801 zl end
                List<String> addFileList = new List<string>();
                foreach (String sqlTmp in sqlList)
                {
                    String[] sqlSplitList = sqlTmp.Split(',');
                    for (int k = 0; k < sqlSplitList.Length; k++)
                    {
                        // mod #9801 zl start
                        if (("pat_event".Equals(fileNameWithoutExtension) && "'old_full_file_name'".Equals(sqlSplitList[k]))
                             || ("bbs_info".Equals(fileNameWithoutExtension) && sqlSplitList[k].Contains("'path'")))
                        {
                            // mod #9801 zl end
                            String tmpAddFullFile = FormatPath(sqlSplitList[k + 1]);
                            if (!String.IsNullOrEmpty(tmpAddFullFile) && !addFileList.Contains(tmpAddFullFile) && tmpAddFullFile != "null")
                            {
                                addFileList.Add(tmpAddFullFile);
                            }
                        }
                    }
                }

                // コピー先パスの取得
                String addFileToPth = GetCopyToPath(directory);
                foreach (string addFileFrom in addFileList)
                {
                    string addFileAddress = addFileFrom;
                    if (addFileFrom.StartsWith("\\"))
                    {
                        addFileAddress = "\\" + addFileFrom;
                    }
                    //string addFileTo = addFileToPth + DelPathDiskMark(addFileFrom);
                    string addFileTo = addFileToPth + DelPathDiskMark(addFileAddress);

                    try
                    {
                        if (!File.Exists(addFileTo))
                        {
                            //if (File.Exists(addFileFrom))
                            if (File.Exists(addFileAddress))
                            {
                                //ReCreatePath(System.IO.Path.GetDirectoryName(addFileTo));
                                //System.IO.File.Copy(addFileAddress, addFileTo, true);
                                ReCreatePath(Path.GetDirectoryName(addFileTo));
                                File.Copy(addFileAddress, addFileTo, true);
                            }
                            else
                            {
                                //WriteErrorLog(String.Format("ファイルコピーに失敗しました。元ファイル[{0}]は存在しません。", addFileFrom));
                                //ConvertBase.WriteTraceLog(String.Format("ファイルコピーに失敗しました。元ファイル[{0}]は存在しません。", addFileFrom));
                                WriteTraceLog(string.Format("ファイルコピーに失敗しました。元ファイル[{0}]は存在しません。", addFileAddress));
                            }
                        }
                    }
                    catch (Exception)
                    {
                        //WriteErrorLog(String.Format("ファイルコピーに失敗しました。元ファイル[{0}]、先ファイル[{1}]", addFileFrom, addFileTo));
                        //ConvertBase.WriteTraceLog(String.Format("ファイルコピーに失敗しました。元ファイル[{0}]、先ファイル[{1}]", addFileFrom, addFileTo));
                        WriteTraceLog(string.Format("ファイルコピーに失敗しました。元ファイル[{0}]、先ファイル[{1}]", addFileAddress, addFileTo));
                    }
                }
            }
            // add 2022-11-15 bug #7882 患者イベントのVA画像がコンバートされていない 孫 end
        }

        // add 2022-11-15 bug #7882 患者イベントのVA画像がコンバートされていない 孫 start
        /// <summary>
        /// コピー先パスの取得
        /// </summary>
        /// <param name="basePath">フルパス</param>
        /// <returns>フルパス</returns>
        private string GetCopyToPath(string basePath)
        {
            String newFullPath = "";
            String[] pathList = basePath.Split(new char[] { '\\', '/' });
            for (int i = 0; i < pathList.Length; i++)
            {
                if (!String.IsNullOrEmpty(pathList[i]))
                {
                    if (String.IsNullOrEmpty(newFullPath))
                    {
                        newFullPath = pathList[i];
                    }
                    else
                    {
                        newFullPath = newFullPath + System.IO.Path.DirectorySeparatorChar + pathList[i];
                    }
                    //del 7997 start
                    //if (this.facilityCd.Equals(pathList[i]))
                    //{
                    //    break;
                    //}
                    //del 7997 start
                }
            }
            newFullPath = newFullPath + System.IO.Path.DirectorySeparatorChar + "AddedFiles";
            return newFullPath;
        }

        /// <summary>
        /// パスの区切り記号を整理する
        /// </summary>
        /// <param name="fullPath">フルパス</param>
        /// <returns>フルパス</returns>
        private string FormatPath(string fullPath)
        {
            String newFullPath = "";
            if (!String.IsNullOrEmpty(fullPath))
            {
                // パスの区切り記号を整理する
                String[] pathList = fullPath.Split(new char[] { '\\', '/' });
                for (int i = 0; i < pathList.Length; i++)
                {
                    if (!String.IsNullOrEmpty(pathList[i]))
                    {
                        if (String.IsNullOrEmpty(newFullPath))
                        {
                            newFullPath = pathList[i];
                        }
                        else
                        {
                            newFullPath = newFullPath + System.IO.Path.DirectorySeparatorChar + pathList[i];
                        }
                    }
                }

                // パスのNULLを整理する
                String[] pathList2 = newFullPath.Split(new char[] { '\'' });
                if (pathList2.Length > 1)
                {
                    newFullPath = pathList2[1];
                }
            }
            return newFullPath;
        }

        /// <summary>
        /// パス内のハードディスク記号を削除する
        /// </summary>
        /// <param name="fullPath">フルパス</param>
        /// <returns>フルパス</returns>
        private string DelPathDiskMark(string fullPath)
        {
            String[] pathList = fullPath.Split(':');
            if (pathList.Length > 1)
            {
                return pathList[1];
            }
            else
            {
                return fullPath;
            }
        }

        /// <summary>
        /// 再帰的作成パス
        /// </summary>
        /// <param name="fullPath">フルパス</param>
        private void ReCreatePath(string fullPath)
        {
            String newFullPath = "";
            String[] pathList = fullPath.Split(new char[] { '\\', '/' });
            for (int i = 0; i < pathList.Length; i++)
            {
                if (!String.IsNullOrEmpty(pathList[i]))
                {
                    if (String.IsNullOrEmpty(newFullPath))
                    {
                        newFullPath = pathList[i];
                    }
                    else
                    {
                        newFullPath = newFullPath + System.IO.Path.DirectorySeparatorChar + pathList[i];
                    }

                    if (!File.Exists(newFullPath))
                    {
                        System.IO.Directory.CreateDirectory(newFullPath);
                    }
                }
            }
        }
        // add 2022-11-15 bug #7882 患者イベントのVA画像がコンバートされていない 孫 end

        /// <summary>
        /// バインド変数として使われている列名のマップを取得する
        /// </summary>
        /// <param name="ntssTableName"></param>
        /// <returns></returns>
        private Dictionary<string, string> GetDelayVariableColumnMap(string ntssTableName)
        {
            return this.dtRelation.AsEnumerable().Where(row => row["NTSS_TABLE_NAME"].ToString() == ntssTableName
                                                            && row["DELAY_BOUND_VARIABLE_FLG"].ToString() == "1"
                                                            )
                                                            .Select(row => row["NTSS_COLUMN_NAME"].ToString())
                                                            .GroupBy(s => s)
                                                            .ToDictionary(s => s.Key,
                                                                s => s.Key
                                                            );
        }


        /// <summary>
        /// NTSSのレコード情報を元にSQLを作成する
        /// </summary>
        /// <param name="mapConvertData"></param>
        /// <param name="sqlFilePath"></param>
        /// <param name="encoding"></param>
        /// <returns></returns>
        private bool MakeSqlFile(Dictionary<string, List<NtssRecord>> mapConvertData,
            string sqlFilePath,
            bool isInsertOnly,
            bool isMakePatidFolder,
            int chunkSize)
        {
            WriteTraceLog("===== SQLファイル作成処理開始 =====");
            // 作成SQL格納マップ
            // キー：Patid 値：PatIdに対応する作成したSQL
            Dictionary<string, List<string>> sqlMap = new Dictionary<string, List<string>>();

            // add FNSI-差分コンバート対応 楊 start
            // キー：Patid 値：PatIdに対応するKey
            Dictionary<string, List<string>> sqlKeyMap = new Dictionary<string, List<string>>();
            //PatIdより、keyを取得
            List<string> keyStrs = new List<String>();
            var keyColNmStr = mapTableToKey.ContainsKey(this.convertTableName) ? mapTableToKey[this.convertTableName].ToString() : "";
            // add FNSI-差分コンバート対応 楊 end

            object patid = null;
            const string DEFALUT_KEY = "default";

            // ユニーク制約設定情報の取得
            DataRow[] drConstraintInfoArray = this.GetUniqueConstraint(this.convertTableName);

            // 遅延バインド変数列マップの取得
            Dictionary<string, string> delayVariableColumnMap = GetDelayVariableColumnMap(this.convertTableName);


            // add #11210 djy start
            // mod #11546 hyl start
            List<string> allTreatementKey = new List<string>();
            List<string> allTrendGraphKey = new List<string>();
            List<string> allTrendGraphKeyTYPE = new List<string>();
            // mod #11546 hyl end
            // add #11210 djy end
            try
            {

                // add FNSI-差分コンバート対応 楊 start
                string sqlTemplete = BuildInsertSqlTemplate();

                // 単純値変換マップ作成
                ConvertValueInfoBase simpleConvertValueInfo;
                simpleConvertValueInfo = new SimpleConvertValueHasDecisionItem(MakeItemNameToColumnNameMap(this.convertTableName));
                MakeSimpleConvertValueMapForDirectValue(simpleConvertValueInfo, this.convertTableName);

                // キー：列名と値：値変換用のSQL文のマップを取得
                //Dictionary<string, string> simpleConvertValueSqlMap = MakeSimpleConvertValueForCaseSqlMap(this.convertTableName);

                // キー：列名と値：FK変換用のSQL文（FNWの値→NTSSの値)のマップを取得
                Dictionary<string, string> fkConvertValueMap = MakeFkConvertValueMap(this.convertTableName);

                // キー：列名と値：カスタム値変換SQL文のマップを取得
                Dictionary<string, string> customCovertValueSqlMap = MakeCustomCovertValueSqlMap(this.convertTableName);

                // シーケンス判定用の列マップ
                Dictionary<string, Object> seqSearchConditionColumnMap = new Dictionary<string, Object>();

                // シーケンス判定用のCASE文をマップへ追加
                foreach (var listConvertData in mapConvertData)
                {

                    // シーケンスカラム生成判定
                    // SYNC_UNIQUEが複数行取得できた場合でも１行目で判定するので注意すること
                    string ntssSeqColumnName = drConstraintInfoArray[0]["NTSS_SEQ_COLUMN_NAME"].ToString();
                    NtssColumn seqColumn = new NtssColumn();
                    seqColumn.value = null;
                    seqColumn.name = ntssSeqColumnName;
                    seqColumn.colType = NTSS_DATA_TYPE_SERIAL;
                    seqColumn.bindParamType = DbBindType.Varchar;
                    seqColumn.isDeleteKey = false;
                    seqColumn.jsonArray = new List<List<JsonElement>>();
                    seqColumn.sqlCreationExclusionFlg = false;
                    bool isHasSeqColumn = false;
                    if (!string.IsNullOrEmpty(ntssSeqColumnName))
                    {
                        isHasSeqColumn = true;
                    }
                    // INSERT文作成時、シーケンス列は出力しない。
                    if (isInsertOnly)
                    {
                        seqColumn.sqlCreationExclusionFlg = true;
                    }

                    foreach (var ntssRecord in listConvertData.Value)
                    {
                        // add FNSI-差分コンバート対応 楊 start
                        // todo yanmgj facility_cd 追加
                        string keyColNm = keyColNmStr;
                        // add FNSI-差分コンバート対応 楊 end

                        //mod #10418 start
                        patid = GetPatIdIfRequired(isMakePatidFolder, ntssRecord);
                        //mod #10418 end
                        
                        // 使用するユニーク制約の取得
                        DataRow drUniqueConstraintInfo = this.JudgementUniqueConstraint(drConstraintInfoArray, ntssRecord);
                        string constraintName = drUniqueConstraintInfo["CONSTRAINT_NAME"].ToString();

                        // シーケンス対象のカラムがある場合、SQLをValueに設定しレコードの先頭に追加する
                        if (isHasSeqColumn)
                        {
                            seqColumn.value = GetJudgeDoNextvalSql(drUniqueConstraintInfo, ntssRecord, this.convertTableName);
                            ntssRecord.columns.Insert(0, seqColumn);
                        }

                        // バインド変数が存在するか検索
                        // JSON要素の１つでもバインド変数として使用されるカラムの場合、
                        // 該当するカラムはSQL出力対象から除外する
                        //mod #10418 start 
                        HandleSpecialColumnLogic(ntssRecord, delayVariableColumnMap,  allTreatementKey,  allTrendGraphKey,  allTrendGraphKeyTYPE);
                        //mod #10418 end 

                        // JSON項目の場合、SQLを作成し、Valueに格納する
                        ntssRecord.columns.Where(ntsscol =>
                            ntsscol.colType.Equals(NTSS_DATA_TYPE_JSONB)).ToList().ForEach(ntsscol =>
                            {
                                //mod #10418 start
                                HandleInsuranceAndJsonLogic(
                                    ntssRecord,
                                    ntsscol,
                                    simpleConvertValueInfo,
                                    fkConvertValueMap,
                                    customCovertValueSqlMap);
                                //mod #10418 end

                            });

                        // カラム名
                        var columnNames = string.Join(",", ntssRecord.columns.Where(ntsscol =>
                            ntsscol.sqlCreationExclusionFlg == false).Select(ntsscol => ntsscol.name).ToArray());

                        // add FNSI-差分コンバート対応 楊 start
                        // 差分コンバートの場合、keyを作成する
                        if (CommonConfig.isDiff && mapTableToKey.ContainsKey(this.convertTableName))
                        {
                            // add zl start
                            //mod #10418 starty
                            keyColNm = ResolveOrdMainKey(keyColNm, ntssRecord);
                            //mod #10418 end
                            // add zl end

                            ntssRecord.columns.Where(ntsscol => keyColNm.Contains(ntsscol.name)).ToList().ForEach(col =>

                            keyColNm = ReplaceVariablesToColumnValue(keyColNm, col, simpleConvertValueInfo, ntssRecord));
                        }
                        // add FNSI-差分コンバート対応 楊 end

                        // INSERTのVALUES句
                        var valuesBlock = string.Join(",", ntssRecord.columns.Where(ntsscol =>
                            ntsscol.sqlCreationExclusionFlg == false).Select(ntsscol =>
                        {
                            //add #10661 limingyang start
                            if (ntsscol.value == null)
                            {
                                return "null";
                            }
                            //add #10661 limingyang end
                            // 値変換対象のカラムの場合
                            if (simpleConvertValueInfo.ContainsKey(ntsscol.name))
                            {
                                string convertValue = simpleConvertValueInfo.GetConvertValue(ntsscol.name, ntsscol.value.ToString(),
                                    ntssRecord, null);
                                return ReplaceSubstitutionVariablesToColumnValue(convertValue, ntssRecord, null, true);
                            }

                            // FK変換対象の列の場合
                            if (fkConvertValueMap.ContainsKey(ntsscol.name) && !ntsscol.colType.Equals(NTSS_DATA_TYPE_JSONB))
                            {
                                // 値を元にSQLを生成し値に設定する
                                string fkValue = string.Format(fkConvertValueMap[ntsscol.name].ToString(), ntsscol.value);
                                // 暗号化対象の場合、暗号化する
                                if (ntsscol.encryptionFlg)
                                {
                                    // mod #10191 djy start
                                    fkValue = MakeColumnSpecialFormat(null, null, fkValue, SpecialColumnType.ENCRYPT_STRING, false);
                                    // mod #10191 djy end
                                }
                                return fkValue;
                            }

                            // カスタム値変換対象の列の場合
                            // add #10870 zkm start
                            if ("mnt_mainte_main".Equals(this.convertTableName) && "MNT_DAILY_CHECKLIST".Equals(this.fnwTableName))
                            {
                                customCovertValueSqlMap.Remove("detail");
                            }
                            // add #10870 zkm end

                            if (customCovertValueSqlMap.ContainsKey(ntsscol.name))
                            {
                                string customSql = customCovertValueSqlMap[ntsscol.name].ToString();

                                //mod #10418 start
                                return   BuildCustomColumnValue(customSql, ntssRecord, ntsscol, fnwTableName);
                                //mod #10418 end

                            }

                            // 通常処理対象のカラムの場合
                            switch (ntsscol.colType)
                            {
                                case NTSS_DATA_TYPE_CHARACTER_VARYING:
                                case NTSS_DATA_TYPE_INET:


                                    ntsscol.value = ntsscol.value.ToString();
                                    // mod #10191 djy end

                                    // 空文字の場合、nullに置き換える
                                    if (ntsscol.value.ToString().Equals(""))
                                    {
                                        //add  #11576 pat_coop_detailのsave_1がGX固定でコンバートされる start
                                        if (ntsscol.name.Equals("coop_version") && "pat_coop_detail".Equals(this.convertTableName))
                                        {

                                            return "''";
                                        }
                                        //add  #11576 pat_coop_detailのsave_1がGX固定でコンバートされる end
                                        return "null";
                                    }
                                    else
                                    {
                                        // 暗号化対象のカラムの場合、personal_info_decryptファンクションで囲む
                                        if (ntsscol.encryptionFlg)
                                        {
                                            // mod #10191 djy start
                                            return MakeColumnSpecialFormat(null, null, ntsscol.value.ToString(), SpecialColumnType.ENCRYPT_STRING, true);
                                            // mod #10191 djy end
                                        }
                                        else
                                        {

                                            //add 10739 start
                                            if (convertTableName.Equals("pat_ind_approve") && ntsscol.name.Equals("check_content"))
                                            {
                                                return ntsscol.value.ToString();
                                            }
                                            //add 10739 end
                                            return MakeColumnSpecialFormat(null, null, ntsscol.value.ToString(), SpecialColumnType.NORMAL_STRING, true);

                                            // mod #10153,#10191,#10249 djy end
                                        }
                                    }
                                case NTSS_DATA_TYPE_TIMESTAMP:
                                    // 空文字の場合、nullに置き換える
                                    if (ntsscol.value.ToString().Equals(""))
                                    {
                                        return "null";
                                    }
                                    else
                                    {
                                        return "TO_TIMESTAMP('" + ntsscol.value.ToString() + "','" + NTSS_DATE_FORMAT + "')";
                                    }

                                case NTSS_DATA_TYPE_JSONB:
                                    // JSONデータから登録用SQL文を生成する
                                    string jsonMakeSql = ntsscol.value.ToString();
                                    // 値の置換文字列を列の値に変換
                                    string jsonMakeSqlReplaced = ReplaceSubstitutionVariablesToColumnValue(jsonMakeSql, ntssRecord, null, false);
                                    return jsonMakeSqlReplaced;
                                default:
                                    // 文字列型でない型で空文字の場合、nullに置き換える
                                    if (ntsscol.value.ToString().Equals(""))
                                    {
                                        return "null";
                                    }
                                    else
                                    {
                                        return ntsscol.value.ToString();
                                    }
                            }
                        }).ToArray());

                        // UPDATE句
                        // シーケンス対象のカラムがある場合、レコードから除外しUPDATE文生成対象外にする
                        if (isHasSeqColumn)
                        {
                            seqColumn.sqlCreationExclusionFlg = true;
                        }
                        // UPDATEの場合、登録日付は更新しない。
                        ntssRecord.columns.Remove(ntssRecord.columns.Find(c => c.name.Equals("reg_date")));


                        //#mod #10418 UPDATE start
                        var updateBlock = BuildUpdateBlock(sqlTemplete, ntssRecord, simpleConvertValueInfo, fkConvertValueMap, customCovertValueSqlMap);
                        //#mod #10418 UPDATE end


                        string sql = string.Format(sqlTemplete, this.convertTableName, columnNames, valuesBlock, constraintName, updateBlock);

                        // add 8605 zs start
                        if ("mst_checklist".Equals(this.convertTableName))
                        {
                            // 'null' の文字列を null に変換する
                            sql = sql.Replace("'null'", "null");
                        }
                        // add 8605 zs end
                        if (isMakePatidFolder && patid != null)
                        {
                            if (!sqlMap.ContainsKey(patid.ToString()))
                            {
                                sqlMap.Add(patid.ToString(), new List<string>());
                            }
                            sqlMap[patid.ToString()].Add(sql);

                            // add FNSI-差分コンバート対応 楊 start
                            // 差分コンバートの場合、keyを作成する
                            if (CommonConfig.isDiff && mapTableToKey.ContainsKey(this.convertTableName))
                            {
                                // 未処理の置換変数が残っていないかチェック

                                //mod #10418 start
                                keyColNm= RemoveCurlyBracketsContent(keyColNm);
                                //mod #10418 end
                                if (!sqlKeyMap.ContainsKey(patid.ToString()))
                                {
                                    sqlKeyMap.Add(patid.ToString(), new List<string>());
                                }
                                sqlKeyMap[patid.ToString()].Add(keyColNm);
                            }
                            // add FNSI-差分コンバート対応 楊 end
                        }
                        else
                        {
                            if (!sqlMap.ContainsKey(DEFALUT_KEY))
                            {
                                sqlMap.Add(DEFALUT_KEY, new List<string>());
                            }
                            sqlMap[DEFALUT_KEY].Add(sql);
                            // add FNSI-差分コンバート対応 楊 start
                            // 差分コンバートの場合、keyを作成する
                            if (CommonConfig.isDiff && mapTableToKey.ContainsKey(this.convertTableName))
                            {
                                // 未処理の置換変数が残っていないかチェック
                                //mod #10418 start
                                keyColNm = RemoveCurlyBracketsContent(keyColNm);
                                //mod #10418 end

                                if (!sqlKeyMap.ContainsKey(DEFALUT_KEY))
                                {
                                    sqlKeyMap.Add(DEFALUT_KEY, new List<string>());
                                }
                                sqlKeyMap[DEFALUT_KEY].Add(keyColNm);
                            }
                            // add FNSI-差分コンバート対応 楊 end
                        }
                    }
                }
                // SQLファイルの作成
                // add FNSI-差分コンバート対応 楊 start
                this.WriteSqlFile(isMakePatidFolder, sqlMap, sqlFilePath, chunkSize, sqlKeyMap);
            }
            catch (Exception e)
            {
                WriteErrorLog(e, this.convertTableName + "SQLファイル作成に失敗しました。");
                return false;
            }

            // add #11210 djy start
            // mod #11546 hyl start
            //mod #10418 start
            HandleSyncTreatmentLayout(
                allTreatementKey,
                allTrendGraphKey,
                allTrendGraphKeyTYPE,
                sqlFilePath);
            //mod #10418 end
            // add #11210 djy end

            WriteTraceLog("===== SQLファイル作成処理完了 =====");
            WriteTraceLog("出力ファイル：{0}", sqlFilePath);
            return true;
        }

        /// <summary>
        /// add #12229  ord_weight_scale json作成
        /// <returns></returns>
        private bool MakeJsonFile(Dictionary<string, List<NtssRecord>> mapConvertData, string sqlFilePath)
        {
            WriteTraceLog("=====ord_weight_scale JSONファイル作成処理開始 =====");
           
            Dictionary<string, string> customCovertValueSqlMap = MakeCustomCovertValueSqlMap(this.convertTableName, true);

            try
            {
            
                // 作成ルートディレクトリの取得
                string rootDirectory = Path.GetDirectoryName(sqlFilePath);

                // 施設コードでフォルダ作成
                string facilityCdDirectory = rootDirectory + "/" + facilityCd;
                if (!Directory.Exists(facilityCdDirectory))
                {
                    Directory.CreateDirectory(facilityCdDirectory);
                }

                foreach (var listConvertData in mapConvertData)
                {
                    List<string> jsonlList = new List<string>();
                    // JSON形式の文字列の作成
                  
                    foreach (var ntssRecord in listConvertData.Value)
                    {
                        
                        foreach (var ntssColumn in ntssRecord.columns.Where(c => c.colType == NTSS_DATA_TYPE_JSONB))
                        {
                            ntssColumn.value = MakeJsonString(ntssRecord, ntssColumn, customCovertValueSqlMap);
                        }


                        //明細行を設定
                        string detailLine = string.Join(",", ntssRecord.columns.Where(ntsscol =>
                                    ntsscol.sqlCreationExclusionFlg == false)
                                    .Select(ntsscol =>
                                    {

                                        string returnString;
                                        if (ntsscol.value != null && ntsscol.value.ToString() != "")
                                        {
                                            if (ntsscol.colType.Equals(NTSS_DATA_TYPE_JSONB))
                                            {
                                                returnString = ntsscol.value.ToString().Replace("\"\"", "\"");
                                            } else if (ntsscol.colType.Equals(NTSS_DATA_TYPE_TIMESTAMP)) {
                                               
                                               string result = DateTime.ParseExact(
                                                                ntsscol.value.ToString(),
                                                                "yyyy/MM/dd H:mm:ss",
                                                                CultureInfo.InvariantCulture
                                                            ).ToString("yyyy/MM/dd HH:mm:ss");

                                                returnString = "\"" + result + "\"";
                                            }
                                            else
                                            {
                                                returnString = "\"" + ntsscol.value.ToString() + "\"";
                                            }

                                        }
                                        else
                                        {
                                            returnString = "null";
                                        }

                                        return $"\"{ntsscol.name.ToString()}\":{returnString}";
                                    }).ToArray());

                        jsonlList.Add("{" + detailLine + "}"); 
                    }

                    int batchSize = 1000;
                    int fileCount = (int)Math.Ceiling(jsonlList.Count / (double)batchSize);

                    string patidDirectory = facilityCdDirectory + "/" + listConvertData.Key;

                    if (!Directory.Exists(patidDirectory))
                    {
                        Directory.CreateDirectory(patidDirectory);
                    }

                    string sqlFilePathPatid = patidDirectory + "/" + this.convertTableName;

                    for (int i = 0; i < fileCount; i++)
                    {
                        var batch = jsonlList
                            .Skip(i * batchSize)
                            .Take(batchSize);

                        string fileNum = i.ToString().PadLeft(4, '0');

                        File.WriteAllText(
                            $"{sqlFilePathPatid}_{fileNum}.sql",
                            string.Join(Environment.NewLine, batch)
                        );
                    }
                    CommonConfig.schLen += jsonlList.Count;                 
                }
            }
            catch (Exception e)
            {
                WriteErrorLog(e, "ord_weight_scaleJSONファイル作成に失敗しました。");
                return false;
            }

            WriteTraceLog("===== ord_weight_scaleJSONファイル作成処理完了 =====");
            WriteTraceLog("ord_weight_scale出力ファイル：{0}", sqlFilePath);
            return true;
        }

        /// <summary>
        /// NTSSのレコード情報を元にSQLを作成する
        /// </summary>
        /// <param name="mapConvertData"></param>
        /// <param name="sqlFilePath"></param>
        /// <param name="encoding"></param>
        /// <returns></returns>
        private bool MakeJsonFile(string sqlFilePath)
        {
            WriteTraceLog("===== JSONファイル作成処理開始 =====");
            // 作成SQL格納マップ

            try
            {
                DataTable dt = dtFnwData;
                // add #9944指示確認の確認をチェックしても、FNSiに反映されない 肖 start
                if (this.convertTableName.Equals("ind_history"))
                {
                    GetSysIndHistorySql(dt);
                }
                // add #9944指示確認の確認をチェックしても、FNSiに反映されない 肖 end
                //mod 8333 zc start
                int listCount = dt.Rows.Count;
                DataTable listDateView = dt;
                DataTable dtRel = dtRelation;
                double fileCount = Math.Ceiling(listCount / 1000.00);

                for (int i = 0; i < fileCount; i++)
                {
                    // add FNSI-指示履歴のcsv作成修正 楊 start
                    var jsonBuilder = new StringBuilder();
                    // add FNSI-指示履歴のcsv作成修正 楊 end
                    int num = i * 1000 + 1;
                    for (int j = num - 1; j < num + 999; j++)
                    {
                        //add 8333 zc start
                        if (j >= listDateView.Rows.Count)
                        {
                            break;
                        }
                        //add 8333 zc start
                        var rowBuilder = new StringBuilder();
                        rowBuilder.Append("{");

                        foreach (DataRow drRel in dtRel.Rows)
                        {
                            string columnName = drRel["NTSS_COLUMN_NAME"].ToString().Trim();
                            string relColumnName = drRel["FNW_COLUMN_NAME"].ToString().Trim();
                            // mod FNSI-指示履歴のcsv作成修正 楊 start
                            // 8333 sichengbo start
                            string value = string.Empty;
                            if (columnName == "treatment_method")
                            {
                                value = string.Join(",", listDateView.Rows[j][relColumnName].ToString().Split(',').Distinct());
                            }
                            else
                            {
                                value = listDateView.Rows[j][relColumnName].ToString();
                            }
                            // 8333 sichengbo end
                            // mod FNSI-7942指示履歴の改行が置換の修正 楊 start
                            // mod #10153,#10191,#10249 djy start
                            value = SpecialDataFormat(value, ConvertValueType.BR_NEWLINE_DATA);
                            // mod #10153,#10191,#10249 djy end
                            // mod FNSI-7942指示履歴の改行が置換の修正 楊  end
                            // 複数の曜日を設定する場合、カンマ区切りとするので、文字列を1文字単位で分割して間にカンマを入れて格納
                            if ("treatment_weekday".Equals(columnName))
                            {
                                for (int idx = 1; idx < value.Length; idx += 2)
                                    value = value.Insert(idx, ",");
                            }
                            rowBuilder.Append($"\"{columnName}\":\"{value}\",");
                        }
                        rowBuilder.Append($"\"_class\":\"FNWConverter.ConvertCommon.ConvertBase.MakeJsonFile\"");
                        rowBuilder.Append("}");
                        jsonBuilder.AppendLine(rowBuilder.ToString());
                    }

                    string fileNum = i.ToString().PadLeft(4, '0');
                    File.WriteAllText($"{sqlFilePath}_{fileNum}.sql", jsonBuilder.ToString());
                }
                //mod #7997 進捗バー 修正　start
                CommonConfig.schLen += listCount;
                //mod #7997 進捗バー 修正　start
            }
            catch (Exception e)
            {
                WriteErrorLog(e, "JSONファイル作成に失敗しました。");
                return false;
            }

            WriteTraceLog("===== JSONファイル作成処理完了 =====");
            WriteTraceLog("出力ファイル：{0}", sqlFilePath);
            return true;
        }

        // add #9944指示確認の確認をチェックしても、FNSiに反映されない 肖 start
        private void GetSysIndHistorySql(DataTable dt)
        {
            string sqldel = "begin ";
            if (!CommonConfig.isDiff)
            {
                sqldel = @"delete from SYNC_IND_HISTORY_DETAIL";
                db.ExecuteSQL(sqldel);
            }
            string Sql = "begin ";
            int batchSize = 0;
            int deleSize = 0;
            //mod #10418 start
            var paramDel = db.GetIMakeSqlParameters();
            var paramIns= db.GetIMakeSqlParameters();

            foreach (DataRow item in dt.Select())
            {
                if (CommonConfig.isDiff)
                {
                    paramDel.AddParam(":CATEGORY_CD_"+ deleSize, item["CATEGORY_CD"].ToString());
                    paramDel.AddParam(":CONFIRM_ID_" + deleSize, item["CONFIRM_ID"]);
                    paramDel.AddParam(":MNG_NO_" + deleSize, item["MNG_NO"]);
                    paramDel.AddParam(":CATEGORY_SUB_NO_" + deleSize, item["CATEGORY_SUB_NO"].ToString());

                    sqldel += $@"delete from SYNC_IND_HISTORY_DETAIL where CATEGORY_CD= :CATEGORY_CD_{deleSize} and CONFIRM_ID=:CONFIRM_ID_{deleSize} 
                                  and MNG_NO =:MNG_NO_{deleSize} and CATEGORY_SUB_NO=:CATEGORY_SUB_NO_{deleSize};";
                    deleSize++;
                    if (deleSize >= 1000)
                    {
                        sqldel += " end;";
                        db.ExecuteSQL(sqldel, paramDel.GetParam());
                        sqldel = "begin ";
                        deleSize = 0;
                        paramDel = db.GetIMakeSqlParameters();
                    }
                }


                paramIns.AddParam(":CodeID_" + batchSize, item["CodeID"].ToString());
                paramIns.AddParam(":CATEGORY_CD_" + batchSize, item["CATEGORY_CD"]);
                paramIns.AddParam(":TAKER_CD_" + batchSize, item["TAKER_CD"]);
                paramIns.AddParam(":TAKER_NAME_" + batchSize, item["TAKER_NAME"].ToString());
                paramIns.AddParam(":CONFIRM_ID_" + batchSize, item["CONFIRM_ID"]);
                paramIns.AddParam(":MNG_NO_" + batchSize, item["MNG_NO"]);
                paramIns.AddParam(":CATEGORY_SUB_NO_" + batchSize, item["CATEGORY_SUB_NO"].ToString());
                paramIns.AddParam(":UP_DATE_" + batchSize, item["UP_DATE"]);

                Sql += $@"INSERT INTO SYNC_IND_HISTORY_DETAIL (PATID,CATEGORY_CD, TAKER_CD, TAKER_NAME,CONFIRM_ID,MNG_NO,CATEGORY_SUB_NO,UP_DATE) 
        VALUES(:CodeID_{batchSize},:CATEGORY_CD_{batchSize},:TAKER_CD_{batchSize},:TAKER_NAME_{batchSize},:CONFIRM_ID_{batchSize},:MNG_NO_{batchSize},:CATEGORY_SUB_NO_{batchSize},:UP_DATE_{batchSize});";
                batchSize++;

                if (batchSize >= 1000)
                {
                    Sql += " end;";
                    db.ExecuteSQL(Sql, paramIns.GetParam());
                    //mod #10418 end
                    Sql = "begin ";
                    batchSize = 0;
                    paramIns= db.GetIMakeSqlParameters();
                }
            }
            if (deleSize > 0)
            {
                sqldel += " end;";
                db.ExecuteSQL(sqldel, paramDel.GetParam());
            }
            if (batchSize > 0)
            {
                Sql += " end;";
                db.ExecuteSQL(Sql, paramIns.GetParam());
            }

        }
        // add #9944指示確認の確認をチェックしても、FNSiに反映されない 肖 end

        /// <summary>
        /// JSON文字列の作成
        /// </summary>
        /// <param name="ntssColumn">NTSSカラム</param>
        /// <returns>JSON文字列</returns>
        private string MakeJsonString(NtssRecord ntssRecord,
                                    NtssColumn ntssColumn,
                                    Dictionary<string, string> customCovertValueSqlMap)
        {
            List<List<JsonElement>> jsonElementListList = ntssColumn.jsonArray;
            JsonDataFormat jsonDataFormat;
            if (jsonElementListList == null || jsonElementListList.Count == 0)
            {
                // JSON項目の値が無い場合
                return "null";
            }
            else
            {
                // JSONデータフォーマットの取得
                // 全JsonElementの１件目だけ取得
                jsonDataFormat = jsonElementListList[0][0].jsonDataFormat;
            }

            if (customCovertValueSqlMap.ContainsKey("monitor_data"))
            {
                var replaceSql = customCovertValueSqlMap["monitor_data"];

                foreach (List<JsonElement> jsonElementList in jsonElementListList)
                {
                    foreach (JsonElement e in jsonElementList)
                    {
                        // 置換変数が存在する場合
                        if (replaceSql.Contains("{" + e.getKeyNameDeleteEscape() + "}"))
                        {
                            replaceSql = replaceSql.Replace("{" + e.getKeyNameDeleteEscape() + "}", e.getValueDeleteEscape());
                        }
                    }
                }

                // #7475 横展開 zl start
                // data_typeを取得
                NtssColumn dataType = ntssRecord.columns.Where(col => col.name.Equals("data_type")).FirstOrDefault();
                String dataTypeValue = dataType.value.ToString();
                replaceSql = "{" + replaceSql.Replace("'", "\"") + "}";
                var obj = JsonConvert.DeserializeObject(replaceSql);
                string sqlnew = string.Empty;
                foreach (var x in obj as JObject)
                {
                    //mod #12448 start
                    if (!string.IsNullOrEmpty(x.Value.ToString()) && !"null".Equals(x.Value.ToString()))
                    {
                        // 1：モニタ(キーは89のデータを追加しない) 　3：再循環率(89のキーのみ)
                        if ((dataTypeValue == "1" && x.Key == "89") || (dataTypeValue == "3" && x.Key != "89"))
                        {
                            continue;
                        }

                        sqlnew += "'" + x.Key + "':'" + x.Value + "',";
                    }
                    //mod #12448 start

                }

                if (sqlnew.Length == 0)
                {
                    return "{}";
                }
                else
                {
                    replaceSql = sqlnew.Substring(0, sqlnew.Length - 1);
                }
                // #7475 横展開 zl end
                return "{" + replaceSql.Replace("'", "\"\"") + "}";
            }
            else if (customCovertValueSqlMap.ContainsKey("treat_condition"))
            {

                var replaceSql = customCovertValueSqlMap["treat_condition"];
                //add 9460 zc start
                ntssRecord.columns.ForEach(col => replaceSql = replaceSql.Replace("{" + col.name + "}", (DBNull.Value.Equals(col.value) || col.value == null || col.value.Equals("")) ? "" : col.value.ToString()));
                //add 9460 zc end
                foreach (List<JsonElement> jsonElementList in jsonElementListList)
                {
                    foreach (JsonElement e in jsonElementList)
                    {
                        // 置換変数が存在する場合
                        if (replaceSql.Contains("{" + e.getKeyNameDeleteEscape() + "}"))
                        {
                            replaceSql = replaceSql.Replace("{" + e.getKeyNameDeleteEscape() + "}", e.getValueDeleteEscape());
                        }
                    }
                }
                if (string.IsNullOrEmpty(replaceSql))
                {
                    return "";
                }
                return "{" + replaceSql.Replace("'", "\"\"") + "}";
            }
            else
            {

                string jsonString = "";
                List<string> jsonStringList = new List<string>();

                switch (jsonDataFormat)
                {
                    case JsonDataFormat.ValueArray:
                        // 値の配列
                        // 例：[1,2,3,4]
                        List<JsonElement> jsonValueList = new List<JsonElement>();
                        // リストの詰め替え
                        jsonElementListList.ForEach(list => jsonValueList.AddRange(list));

                        jsonString = string.Join(",", jsonValueList.Where(je => je.sqlCreationExclusionFlg == false).Select(je =>
                        {
                            return FormatJsonValueByValueType(je).Replace("'", "\"");
                        }).ToArray());
                        // ダブルクォートをエスケープ
                        return "[" + jsonString.Replace("\"", "\"\"") + "]";
                    case JsonDataFormat.JsonNoArray:
                        // キーと値のセットのみ
                        // 例：{"A":1,"B":2,"C":3}
                        foreach (List<JsonElement> jsonElementList in jsonElementListList)
                        {
                            jsonString = string.Join(",", jsonElementList.Where(je => je.sqlCreationExclusionFlg == false).Select(je =>
                            {
                                // 7341 AWS側アプリの処理が遅い start
                                //return "\"" + je.getKeyNameDeleteEscape() + "\":" + FormatJsonValueByValueType(je).Replace("'", "\"");
                                //add 8585  ord_checklist CSV zc start
                                if ((this.convertTableName.Equals("ord_checklist") || this.convertTableName.Equals("ord_weight_scale")) && je.jsonValueType.Equals("string") && je.getValueDeleteEscape() != "null")
                                {

                                    return "\"" + je.getKeyNameDeleteEscape() + "\":\"" + je.getValueDeleteEscape() + "\"";
                                }
                                //add 8585 ord_checklist CSV zc end
                                return "\"" + je.getKeyNameDeleteEscape() + "\":" + je.getValueDeleteEscape();
                                // 7341 AWS側アプリの処理が遅い end
                            }).ToArray());
                        }
                        // ダブルクォートをエスケープ
                        return "{" + jsonString.Replace("\"", "\"\"").Replace("mni_", "") + "}";
                    case JsonDataFormat.JsonArray:
                        // JSON配列
                        // 例：{[{"A":1,"B":2,"C":3},{"A":1,"B":2,"C":3}]}
                        foreach (List<JsonElement> jsonElementList in jsonElementListList)
                        {
                            jsonString = string.Join(",", jsonElementList.Where(je => je.sqlCreationExclusionFlg == false).Select(je =>
                            {
                                //pat_unique_history変更csv
                                if ((this.convertTableName.Equals("pat_unique_history") || this.convertTableName.Equals("pat_exam_main")) && je.jsonValueType.Equals("string") && je.getValueDeleteEscape() != "null")
                                {
                                    // mod #10153,#10191,#10249 djy start
                                    //return "\"" + je.getKeyNameDeleteEscape() + "\":\"" + FormatJsonValueByValueType(je).Replace("'", "") + "\"";
                                    return "\"" + je.getKeyNameDeleteEscape() + "\":\"" + je.getValueDeleteEscape() + "\"";
                                    // mod #10153,#10191,#10249 djy end
                                }
                                //pat_unique_history変更csv
                                return "\"" + je.getKeyNameDeleteEscape() + "\":" + FormatJsonValueByValueType(je).Replace("'", "\"");
                            }).ToArray());
                            jsonStringList.Add("{" + jsonString + "}");
                        }
                        return "[" + string.Join(",", jsonStringList.ToArray()).Replace("\"", "\"\"") + "]";
                    case JsonDataFormat.JsonNest:
                        // 入れ子
                        // 例：{"a":{"A":1,"B":2,"C":3},"b":{"A":1,"B":2,"C":3}}
                        string parentKey = null;
                        foreach (List<JsonElement> jsonElementList in jsonElementListList)
                        {
                            // JSONキー名がkeyのものを親キーとして使用する
                            jsonString = string.Join(",", jsonElementList.Where(je => je.sqlCreationExclusionFlg == false).Select(je =>
                            {
                                if (je.getKeyNameDeleteEscape().Equals("key"))
                                {
                                    // キー項目の退避
                                    parentKey = je.getValueDeleteEscape();
                                    return "";
                                }
                                else
                                {
                                    return "\"" + je.getKeyNameDeleteEscape() + "\":" + FormatJsonValueByValueType(je).Replace("'", "\"");
                                }

                            }).Where(value => !value.Equals("")).ToArray());
                            jsonStringList.Add(string.Format("\"{0}\":{{{1}}}", parentKey, jsonString));
                        }
                        return "{" + string.Join(",", jsonStringList.ToArray()).Replace("\"", "\"\"") + "}";
                    default:
                        // エクセプション
                        return "";
                }
            }
        }

        /// <summary>
        /// CSVファイルを作成する
        /// </summary>
        /// <param name="mapConvertData"></param>
        /// <param name="csvFilePath"></param>
        /// <param name="encoding"></param>
        /// <param name="isMakePatidFolder"></param>
        /// <returns></returns>
        private bool MakeCsvFile(Dictionary<string, List<NtssRecord>> mapConvertData,
            string csvFilePath,
            Encoding encoding,
            bool isMakePatidFolder)
        {
            bool isHeaderSet = false;
            string headerColumns = "";

            List<string> detailList = new List<string>();

            WriteTraceLog("===== CSVファイル作成処理開始 =====");
            try
            {
                // 単純値変換マップ作成
                ConvertValueInfoBase simpleConvertValueInfo;
                simpleConvertValueInfo = new SimpleConvertValueHasDecisionItem(MakeItemNameToColumnNameMap(this.convertTableName));
                MakeSimpleConvertValueMapForDirectValue(simpleConvertValueInfo, this.convertTableName, true);

                // キー：列名と値：カスタム値変換SQL文のマップを取得
                Dictionary<string, string> customCovertValueSqlMap = MakeCustomCovertValueSqlMap(this.convertTableName, true);

                // 7341 AWS側アプリの処理が遅い start
                // キー：Patid 値：PatIdに対応する作成したSQL
                Dictionary<string, List<string>> sqlMap = new Dictionary<string, List<string>>();

                object patid = null;

                const string DEFALUT_KEY = "default";

                int chunkSize = 50000;
                //add 9067 zc start
                if (System.IO.Path.GetFileNameWithoutExtension(csvFilePath).Equals("pat_unique_history"))
                {
                    chunkSize = 200;
                }
                else if (System.IO.Path.GetFileNameWithoutExtension(csvFilePath).Equals("mnt_motion_record"))
                {
                    // add #9132 コンバート処理中にDBが高負荷となり停止 zkm start
                    chunkSize = CommonConfig.MotionRecordFileSize;
                    // add #9132 コンバート処理中にDBが高負荷となり停止 zkm end
                }
                //add 9067 zc end
                int len = 0;
                // 7341 AWS側アプリの処理が遅い end
                foreach (var listConvertData in mapConvertData)
                {
                    //add 8555 zc start
                    if (!System.IO.Path.GetFileNameWithoutExtension(csvFilePath).Equals("mnt_motion_record") && !System.IO.Path.GetFileNameWithoutExtension(csvFilePath).Equals("pat_unique_history") && !System.IO.Path.GetFileNameWithoutExtension(csvFilePath).Equals("mst_favorite_facility"))
                    {
                        detailList = new List<string>();
                    }
                    //add 8555 zc start
                    // JSON形式の文字列の作成
                    foreach (var ntssRecord in listConvertData.Value)
                    {
                        // JSON文字列を作成してValueに設定する
                        foreach (var ntssColumn in ntssRecord.columns)
                        {
                            if (ntssColumn.colType.Equals(NTSS_DATA_TYPE_JSONB))
                            {
                                // 単純値変換、カスタム値変換対象のJSON要素の場合は変換を実施する
                                foreach (List<JsonElement> jsonElementList in ntssColumn.jsonArray)
                                {
                                    foreach (JsonElement je in jsonElementList)
                                    {
                                        string convertValue;
                                        // string key = ntssColumn.name + je.getKeyNameDeleteEscape();
                                        string key = ntssColumn.name;
                                        // 値変換対象かチェック
                                        if (simpleConvertValueInfo.ContainsKey(key))
                                        {
                                            // 値変換対象の場合、値を置き換え、変換値内の置換変数を設定
                                            convertValue = simpleConvertValueInfo.GetConvertValue(key, je.getValueDeleteEscape(), ntssRecord, jsonElementList);
                                            je.value = ReplaceSubstitutionVariablesToColumnValue(convertValue, ntssRecord, jsonElementList, true);
                                        }
                                    }
                                }
                                ntssColumn.value = MakeJsonString(ntssRecord, ntssColumn, customCovertValueSqlMap);
                            }
                            // 7341 AWS側アプリの処理が遅い start
                            if (isMakePatidFolder)
                            {
                                // pat_idの存在チェック
                                if (!ntssRecord.columns.Any(ntsscol =>
                                     ntsscol.name.Equals("pat_id") || ntsscol.name.Equals("fn_pat_id")))
                                {
                                    throw new Exception("患者IDの列が存在しません。");
                                }
                                // patidの取得
                                patid = ntssRecord.columns
                                    .FirstOrDefault(ntsscol => ntsscol.name.Equals("pat_id") || ntsscol.name.Equals("fn_pat_id")).value;
                            }
                            // 7341 AWS側アプリの処理が遅い end
                        }
                    }

                    foreach (var ntssRecord in listConvertData.Value)
                    {
                        if (!isHeaderSet)
                        {
                            // 初回処理時、ヘッダーカラムを設定
                            headerColumns = string.Join(",", ntssRecord.columns.Where(ntsscol =>
                                ntsscol.sqlCreationExclusionFlg == false).Select(ntsscol => ntsscol.name).ToArray());
                            isHeaderSet = true;
                        }

                        // 明細行を設定
                        string detailLine = string.Join(",", ntssRecord.columns.Where(ntsscol =>
                                ntsscol.sqlCreationExclusionFlg == false)
                                .Select(ntsscol =>
                                    {
                                        //ntsscol.name.Equals("pat_id").ToString()..Equals(patid)
                                        string returnString;

                                        // 値変換対象のカラムの場合
                                        if (simpleConvertValueInfo.ContainsKey(ntsscol.name))
                                        {
                                            returnString = "\"" + simpleConvertValueInfo.GetConvertValue(ntsscol.name, ntsscol.value.ToString(),
                                                ntssRecord, null) + "\"";

                                            returnString = ReplaceSubstitutionVariablesToColumnValue(returnString, ntssRecord, null, true);
                                        }
                                        else
                                        {
                                            if (ntsscol.value != null)
                                            {
                                                returnString = "\"" + ntsscol.value.ToString() + "\"";
                                            }
                                            else
                                            {
                                                returnString = "";
                                            }
                                        }

                                        return returnString;
                                    }).ToArray());

                        // 7341 AWS側アプリの処理が遅い start
                        if (isMakePatidFolder && patid != null)
                        {
                            if (!sqlMap.ContainsKey(patid.ToString()))
                            {
                                sqlMap.Add(patid.ToString(), new List<string>());
                            }
                            sqlMap[patid.ToString()].Add(detailLine);

                        }
                        else
                        {
                            if (!sqlMap.ContainsKey(DEFALUT_KEY))
                            {
                                sqlMap.Add(DEFALUT_KEY, new List<string>());
                            }
                            sqlMap[DEFALUT_KEY].Add(detailLine);
                        }
                        // 7341 AWS側アプリの処理が遅い end

                        detailList.Add(detailLine);
                    }
                    len++;
                    //add 8555 zc start
                    if (detailList.Count > 0)
                    {
                        if (isMakePatidFolder)
                        {
                            // 作成ルートディレクトリの取得
                            string rootDirectory = Path.GetDirectoryName(csvFilePath);

                            // 拡張子の取得
                            string extension = System.IO.Path.GetExtension(csvFilePath);

                            // 施設コードでフォルダ作成
                            string facilityCdDirectory = rootDirectory + "/" + facilityCd;
                            if (!Directory.Exists(facilityCdDirectory))
                            {
                                Directory.CreateDirectory(facilityCdDirectory);
                            }
                            // 患者IDでフォルダ作成
                            string patidDirectory = facilityCdDirectory + "/" + patid;
                            //mod #12229 dialysis差分の場合 、患者フォルダを生成しない start
                            bool isDiffDialysisFile = !(CommonConfig.isDiff && rootDirectory.Contains("dialysis[diff]"));
                            if (isDiffDialysisFile)
                            {
                                if (!Directory.Exists(patidDirectory))
                                {
                                    Directory.CreateDirectory(patidDirectory);
                                }
                            }
                            //mod #12229 dialysis差分の場合 、患者フォルダを生成しない end
                            string sqlFilePathPatid = patidDirectory + "/" + this.convertTableName + extension;
                            chunkAndWriteFileForCsv(detailList, sqlFilePathPatid, chunkSize, encoding, headerColumns);
                        }
                        else
                        {
                            if (len == mapConvertData.Count)
                            {
                                List<String> sqlList = sqlMap.SelectMany(x => x.Value).ToList();
                                chunkAndWriteFileForCsv(detailList, csvFilePath, chunkSize, encoding, headerColumns);
                            }

                        }
                    }
                    else
                    {
                        WriteErrorLog("処理対象が０件です。テーブル名：" + this.convertTableName);
                    }
                    //add 8555 zc start
                }

            }
            catch (Exception e)
            {
                WriteErrorLog(e, "CSVファイル作成に失敗しました。");
                return false;
            }

            WriteTraceLog("===== CSVファイル作成処理完了 =====");
            WriteTraceLog("出力ファイル：{0}", csvFilePath);
            return true;
        }

        private static readonly object _fileWriteLock = new object();
        private static Dictionary<string, int> _fileIndexMap = new Dictionary<string, int>();
        private static Dictionary<string, int> _rowCountMap = new Dictionary<string, int>();
        private const int MaxRowsPerFile = 5000;

        // 7341 AWS側アプリの処理が遅い start
        /// <summary>
        /// CSVファイルリストを分割して書き込み
        /// </summary>
        /// <param name="sqlList"></param>
        /// <param name="filePath"></param>
        /// <param name="chunkSize"></param>
        /// <param name="encoding"></param>
        private void chunkAndWriteFileForCsv(List<String> sqlList, string filePath, int chunkSize, Encoding encoding,
            string headerColumns)
        {

            // ファイル名（拡張子なし）の取得           
            //add 8469 zc start
            string fileNameWithoutExtension = System.IO.Path.GetFileNameWithoutExtension(filePath);

            // リスト分割
            var chunkList = sqlList.Select((v, i) => new { v, i })
                .GroupBy(x => x.i / chunkSize)
                .Select(g => g.Select(x => x.v));

            // ディレクトリ名の取得
            string directory = System.IO.Path.GetDirectoryName(filePath);

            // 拡張子の取得
            string extension = System.IO.Path.GetExtension(filePath);
            //del  8469 zc start
            //// ファイル名（拡張子なし）の取得
            //string fileNameWithoutExtension = System.IO.Path.GetFileNameWithoutExtension(filePath);
            //del  8469 zc end

            // 分割数毎にファイル書き込み
            int index = 1;

            // ファイルが既に存在する場合、インデックスを加算する
            string sqlFilePathForExistsCheck = directory +
                    "/" + fileNameWithoutExtension +
                    "_" + index.ToString().PadLeft(4, '0')
                    + extension;

            while (File.Exists(sqlFilePathForExistsCheck))
            {
                index++;
                sqlFilePathForExistsCheck = directory +
                    "/" + fileNameWithoutExtension +
                    "_" + index.ToString().PadLeft(4, '0')
                    + extension;

            }
            //add  #12229 start
            if ((fileNameWithoutExtension.Equals("ord_checklist") || fileNameWithoutExtension.Equals("mni_monitor")) && CommonConfig.isDiff)
            {
                string sqlFilePath = Path.GetDirectoryName(directory);
                foreach (var chunk in chunkList)
                {
                    lock (_fileWriteLock)
                    {

                        if (!_fileIndexMap.ContainsKey(fileNameWithoutExtension))
                        {
                            _fileIndexMap[fileNameWithoutExtension] = 1;
                            _rowCountMap[fileNameWithoutExtension] = 0;
                        }

                        if (_rowCountMap[fileNameWithoutExtension] >= MaxRowsPerFile)
                        {
                            _fileIndexMap[fileNameWithoutExtension]++;
                            _rowCountMap[fileNameWithoutExtension] = 0;
                        }

                        int currentIndex = _fileIndexMap[fileNameWithoutExtension];
                        int currentRowCount = _rowCountMap[fileNameWithoutExtension];

                        string sqlFilePathWithIndex = Path.Combine(
                                 sqlFilePath,
                                 $"{fileNameWithoutExtension}_{currentIndex.ToString().PadLeft(4, '0')}{extension}"
                             );


                        using (var sw = new StreamWriter(sqlFilePathWithIndex, true, encoding))
                        {
                            if (currentRowCount == 0)
                            {
                                sw.WriteLine(headerColumns);
                            }

                            sw.WriteLine(string.Join("\r\n", chunk));
                        }

                        _rowCountMap[fileNameWithoutExtension] += chunk.Count();
                        CommonConfig.schLen += chunk.Count();
                    }
                }

                return;

            }
            //add  #12229  end

            foreach (var chunk in chunkList)
            {
                string sqlFilePathWithIndex = directory +
                    "/" + fileNameWithoutExtension +
                    "_" + index.ToString().PadLeft(4, '0')
                    + extension;

                // 患者ID毎にSQLファイル書き込み
                using (var sw = new StreamWriter(sqlFilePathWithIndex, true, encoding))
                {
                    // ヘッダー書き込み
                    sw.WriteLine(headerColumns);
                    sw.WriteLine(String.Join("\r\n", chunk));
                }
                index++;
                CommonConfig.schLen += chunk.Count();
            }
        }
        // 7341 AWS側アプリの処理が遅い end

      

        /// <summary>
        /// バインド変数作成
        /// </summary>
        /// <param name="columnName">カラム名</param>
        /// <param name="bindParamType">データ型</param>
        /// <param name="value">値</param>
        /// <returns>バインド変数</returns>
      

        public bool SetFnwMst()
        {
            return SetFnwMst(sqlDirectory, mapFnwDataMst);
        }

        public bool SetAllMst(string sqlRootDirectory, Dictionary<string, DataTable> mapFnwMstCache)
        {
            var sqlDirectories = Directory.GetDirectories(sqlRootDirectory);
            foreach (var sqlDirectory in sqlDirectories)
            {
                SetFnwMst(sqlDirectory, mapFnwMstCache);
                if (mapFnwMstCache == null)
                {
                    return false;
                }
            }

            return true;
        }

        public bool SetFnwMst(string sqlDirectory, Dictionary<string, DataTable> mapFnwDataMst)
        {
            var mstSqlDirectory = Path.Combine(sqlDirectory, "MST");
            if (Directory.Exists(mstSqlDirectory) == false)
            {
                // マスタを使わないテーブルもあるためエラーではない
                return true;
            }

            // MSTフォルダが存在する場合
            //var mstSqlFiles = Directory.GetFiles(mstSqlDirectory);
            var mstSqlFiles = Directory.GetFiles(mstSqlDirectory, "*.sql");
            foreach (var mstSqlFilePath in mstSqlFiles)
            {
                var mstTableName = Path.GetFileNameWithoutExtension(mstSqlFilePath);
                // 同じマスタは1回だけ取得(キャッシュ使用時のための判定)
                if (mapFnwDataMst.ContainsKey(mstTableName) == false)
                {
                    var dt = ProcSql(db, mstSqlFilePath);
                    WriteTraceLog("実行用SQL：{0}", mstSqlFilePath);
                    if (dt == null)
                    {
                        // SQL実行失敗
                        WriteErrorLog("マスタ取得に失敗しました。");
                        mapFnwDataMst = null;
                        return false;
                    }
                    else if (dt.Rows.Count == 0)
                    {
                        // マスタ0件
                        // 問題ないので処理続行
                        WriteTraceLog("マスタが存在しません。");
                        continue;
                    }
                    dt.TableName = mstTableName;
                    mapFnwDataMst[mstTableName] = dt;
                }
            }
            return true;
        }

       

        /// <summary>
        /// リスト内の文字列を結合し1つの文字列にする
        /// </summary>
        /// <param name="list">リスト</param>
        /// <param name="delimiter">区切り文字</param>
        /// <param name="bracket">囲み文字</param>
        /// <remarks>
        /// SQL用パラメータ文字列作成に使用
        /// </remarks>
        /// <returns>結合された文字列</returns>
        protected string JoinListValue(List<string> list, string delimiter, string bracket)
        {
            return string.Join(delimiter, list.Select(value => string.Format("{0}{1}{0}", bracket, value)).ToArray());
        }

        /// <summary>
        /// リスト内の文字列を1000個ずつ結合して分割する(SQLのIN句用に使用)
        /// </summary>
        /// <param name="list">リスト</param>
        /// <remarks>
        /// 例：{"1", "2", ..., "2000"} → {"'1','2',...,'1000'", "'1001','1002',...,'2000'"}
        /// </remarks>
        /// <returns>1000個ずつに分割された文字列のリスト</returns>
        protected List<string> SplitListValueForSqlInClause(List<string> list)
        {
            var splitList = new List<string>();
            // 引数のリストをコピーする(破壊されるため)
            var copyList = new List<string>(list);
            while (copyList.Count > 0)
            {
                var removeRange = 0;
                if (copyList.Count > 1000)
                {
                    // 値が1000個を超えている場合は1000個取り出す
                    removeRange = 1000;
                }
                else
                {
                    // 1000個ないなら個数分取り出す
                    removeRange = copyList.Count;
                }
                // 取り出す
                var listTmp = copyList.GetRange(0, removeRange);
                // リスト内の文字列を結合
                splitList.Add(JoinListValue(listTmp, ",", "'"));
                // 取り出した分削除
                copyList.RemoveRange(0, removeRange);
            }

            return splitList;
        }

        /// <summary>
        /// リスト内の文字列を1000個ずつ結合して分割する(SQLのIN句用に使用)
        /// </summary>
        /// <param name="list">リスト</param>
        /// <remarks>
        /// 例：{"\"000000000445","1"\","\"000000000445","2"\", ..., "\"00000000****","*"\"} → {(('000000000445','1'),('000000000445','2'),...,('00000000****','*'))}
        /// </remarks>
        /// <returns>1000個ずつに分割された文字列のリスト</returns>
        protected List<string> SplitListValueForSqlInClause2(List<string> list)
        {
            var splitList = new List<string>();
            // 引数のリストをコピーする(破壊されるため)
            var copyList = new List<string>(list);
            while (copyList.Count > 0)
            {
                var removeRange = 0;
                if (copyList.Count > 1000)
                {
                    // 値が1000個を超えている場合は1000個取り出す
                    removeRange = 1000;
                }
                else
                {
                    // 1000個ないなら個数分取り出す
                    removeRange = copyList.Count;
                }
                // 取り出す
                var listTmp = copyList.GetRange(0, removeRange);
                // リスト内の文字列を結合
                splitList.Add(string.Join(",", listTmp.Select(value => string.Format("{0}{1}{2}", "(", value.Replace("\"", "'"), ")")).ToArray()));
                // 取り出した分削除
                copyList.RemoveRange(0, removeRange);
            }

            return splitList;
        }

        protected static DataTable ProcSql(DBCtrl db, string sqlFilePath)
        {
            return ProcSql(db, sqlFilePath, "");
        }
        //add #10418 start
        protected static DataTable ProcSqlPatid(DBCtrl db, string sqlFilePath, string startDate, string endDate, params string[] param)
        {
            DataTable dt = null;

            WriteTraceLog("実行SQL：{0}", sqlFilePath);
            try
            {
                using (var sr = new StreamReader(sqlFilePath))
                {
                    // SQLファイル読込
                    var sql = sr.ReadToEnd().Replace(Environment.NewLine, " ").TrimEnd(';');
                    // パラメータをWHERE句に記述
                    //add  7997  zc start
                    if (CacheInformation.Instance.FacilityCd.Equals("0"))
                    {
                        sql = ConditionRegex.Replace(sql, "  1=1");
                    }
                    else
                    {
                        sql = sql.Replace("'{SERIES_CD}'", ":SERIES_CD");
                    }
                    sql = string.Format(sql, param);
                    //add  7997  zc end

                    // mod #10418 start 
                    IMakeSqlParameters Sqlparam = db.GetIMakeSqlParameters();
                    if (sql.Contains(":END_DATE"))
                    {
                        Sqlparam.AddParam(":END_DATE", endDate);
                    }
                    if (sql.Contains(":facility_cd"))
                        Sqlparam.AddParam(":facility_cd", CommonConfig.FacilityCd);

                    if (sql.Contains(":START_DATE"))
                    {
                        Sqlparam.AddParam(":START_DATE", startDate);
                    }

                    if (sql.Contains(":MST_DIFF_DATETIME"))
                    {
                        Sqlparam.AddParam(":MST_DIFF_DATETIME", CommonConfig.MST_DIFF_DATETIME.ToString());
                    }

                    dt = db.SelectTable(sql, Sqlparam.GetParam());
                    // mod #10418 end
                    if (dt == null)
                    {
                        // SQL実行失敗
                        WriteErrorLog("元データ取得SQL実行に失敗しました。(ファイル名：{0})", sqlFilePath);
                    }
                }
            }
            catch (Exception e)
            {
                WriteErrorLog(e, "コンバート元データ取得に失敗しました。" + sqlFilePath);
            }

            return dt;
        }
        protected static DataTable ProcSql(DBCtrl db, string sqlFilePath, params string[] param)
        {
            DataTable dt = null;

            string sVALUE = "1";
            if (!string.IsNullOrEmpty(CacheInformation.Instance.FacilityCd))
            {
                sVALUE = CacheInformation.Instance.FacilityCd;
            }
            WriteTraceLog("実行SQL：{0}", sqlFilePath);
            try
            {
                using (var sr = new StreamReader(sqlFilePath))
                {
                    // SQLファイル読込
                    var sql = sr.ReadToEnd().Replace(Environment.NewLine, " ").TrimEnd(';');
                    // パラメータをWHERE句に記述
                    //add  7997  zc start
                    if (sVALUE.Equals("0"))
                    {
                        sql = ConditionRegex.Replace(sql, "  1=1");
                       
                    }
                    else
                    {
                        sql = sql.Replace("'{SERIES_CD}'", ":SERIES_CD");
                    }

                    sql = string.Format(sql, param);
                    //add  7997  zc end

                    // mod #10418 start 
                    IMakeSqlParameters Sqlparam = db.GetIMakeSqlParameters();
                    if (sql.Contains(":facility_cd"))
                    {
                        Sqlparam.AddParam(":facility_cd", CommonConfig.FacilityCd);
                    }

                    if (sql.Contains(":SERIES_CD"))
                    {
                        Sqlparam.AddParam(":SERIES_CD", CommonConfig.seriesCd);
                    }
                    dt = db.SelectTable(sql, Sqlparam.GetParam());
                    // mod #10418 end
                    if (dt == null)
                    {
                        // SQL実行失敗
                        WriteErrorLog("元データ取得SQL実行に失敗しました。(ファイル名：{0})", sqlFilePath);
                    }
                }
            }
            catch (Exception e)
            {
                WriteErrorLog(e, "コンバート元データ取得に失敗しました。" + sqlFilePath);
            }

            return dt;
        }

        public static string CreateSqlPathString(string parentPath, string fileName)
        {
            var sqlFilePath = Path.Combine(parentPath, fileName + ".sql");
            if (File.Exists(sqlFilePath) == false)
            {
                // SQLファイルなし
                WriteErrorLog("元データ取得用SQLファイルが存在しません。(ファイルパス：{0})", sqlFilePath);
                sqlFilePath = null;
            }

            return sqlFilePath;
        }

       

        /// <summary>
        /// エラーログ出力(例外・付加情報なし)
        /// </summary>
        /// <param name="msg">メッセージ</param>
        public static void WriteErrorLog(string msg)
        {
            LogManager.WriteErrorLog(null, null, "[エラー]" + msg, null);
        }

        /// <summary>
        /// エラーログ出力(例外なし・付加情報あり)
        /// </summary>
        /// <param name="msg">メッセージ</param>
        /// <param name="option">付加情報の配列</param>
        public static void WriteErrorLog(string msg, params string[] option)
        {
            LogManager.WriteErrorLog(null, null, "[エラー]" + string.Format(msg, option), null);
        }

        /// <summary>
        /// エラーログ出力(例外あり・付加情報なし)
        /// </summary>
        /// <param name="e">例外</param>
        /// <param name="msg">メッセージ</param>
        public static void WriteErrorLog(Exception e, string msg)
        {
            LogManager.WriteErrorLog(null, null, "[エラー]" + msg, e);
        }

        /// <summary>
        /// エラーログ出力(例外・付加情報あり)
        /// </summary>
        /// <param name="e">例外</param>
        /// <param name="msg">メッセージ</param>
        /// <param name="option">付加情報の配列</param>
        public static void WriteErrorLog(Exception ex, string msg, params string[] option)
        {
            LogManager.WriteErrorLog(null, null, "[エラー]" + string.Format(msg, option), ex);
        }

        /// <summary>
        /// トレースログ出力(付加情報なし)
        /// </summary>
        /// <param name="msg">メッセージ</param>
        public static void WriteTraceLog(string msg)
        {
            LogManager.WriteTraceLog(null, null, "[情報]" + msg);
        }

        /// <summary>
        /// トレースログ出力(付加情報あり)
        /// </summary>
        /// <param name="msg">メッセージ</param>
        /// <param name="option">付加情報の配列</param>
        public static void WriteTraceLog(string msg, params string[] option)
        {
            LogManager.WriteTraceLog(null, null, "[情報]" + string.Format(msg, option));
        }

        /// <summary>
        /// XMLスキーマデータを処理する
        /// </summary>
        /// <param name="jsonName"></param>
        /// <param name="targetColumnName"></param>
        /// <param name="ignoreElementName"></param>
        /// <param name="keyPlefix"></param>
        /// <param name="jsonElementNameList"></param>
        /// <param name="jsonRecord"></param>
        /// <param name="ntssColumns"></param>
        /// 
        /// 
        protected void ConvertJsonArrayXmlData(
            string jsonName,
            string targetColumnName,
            string ignoreElementName,
            string keyPlefix,
            List<string> jsonElementNameList,
            DataRow jsonRecord, List<NtssColumn> ntssColumns)
        {
            //string jsonName = "monitor_data";
            // JSONデータのリスト(配列化用)
            var listJsonArrayElement = new List<string>();
            // JSONデータのリスト
            List<List<JsonElement>> jsonElementListList = new List<List<JsonElement>>();
            var mapJsonTmp = new Dictionary<string, List<JsonElement>>();

            // JSONデータ全格納完了後、紐付け項目ではないが、JSON要素が存在しなければならない場合
            // 要素を作成し、値をnullに設定する。
            mapJsonTmp = new Dictionary<string, List<JsonElement>>();
            //ConvertRecord(dr, ntssColumns, mapJsonTmp, ref isCriticalError, ref isConvertError);
            //if (isCriticalError || isConvertError)
            //{
            //    return;
            //}

            // １階層目のJsonElementを作成する。
            //this.AddNotExistsThenEmptyJsonElement(drRelationArray,
            //                                    mapJsonTmp,
            //                                    jsonName);

            // アドレス値と値のセット（モニターデータ）をJsonリストに追加
            ProcessingDataForDeviceSetJson(jsonRecord[targetColumnName] as string,
                                ignoreElementName,
                                keyPlefix,
                                mapJsonTmp,
                                jsonElementNameList,
                                jsonName);

            if (mapJsonTmp.Count > 0)
            {
                jsonElementListList.Add(mapJsonTmp[jsonName]);
                // 7341 AWS側アプリの処理が遅い start
                // ntssColumns.Add(CreateNtssColumnForJson(jsonName, NTSS_DATA_TYPE_JSONB, jsonElementListList, false));
                ntssColumns.Insert(5, CreateNtssColumnForJson(jsonName, NTSS_DATA_TYPE_JSONB, jsonElementListList, false));
                // 7341 AWS側アプリの処理が遅い end
            }

        }

        // add FNSI_患者イベント項目テンプレートマスタ追加 楊 start
        protected void ConvertJsonArrayEventData(
            string jsonName,
            List<string> jsonElementNameList,
            DataRow jsonRecord, List<NtssColumn> ntssColumns)
        {
            //string jsonName = "monitor_data";
            // JSONデータのリスト(配列化用)
            var listJsonArrayElement = new List<string>();
            // JSONデータのリスト
            List<List<JsonElement>> jsonElementListList = new List<List<JsonElement>>();
            var mapJsonTmp = new Dictionary<string, JsonElement>();

            // JSONデータ全格納完了後、紐付け項目ではないが、JSON要素が存在しなければならない場合
            // 要素を作成し、値をnullに設定する。
            mapJsonTmp = new Dictionary<string, JsonElement>();


            // アドレス値と値のセット（モニターデータ）をJsonリストに追加
            ProcessingDataForEventJson(jsonRecord,
                                mapJsonTmp,
                                jsonElementListList,
                                jsonElementNameList);

            if (mapJsonTmp.Count > 0)
            {
                //jsonElementListList.Add(mapJsonTmp);
                ntssColumns.Add(CreateNtssColumnForJson(jsonName, NTSS_DATA_TYPE_JSONB, jsonElementListList, false));
            }

        }

        protected void ProcessingDataForEventJson(DataRow targetData,
            Dictionary<string, JsonElement> mapJson,
            List<List<JsonElement>> jsonElementListList,
            List<string> elementNameListForExistsCheck)
        {
            // 列データの空白チェック
            if (null == targetData)
            {
                return;
            }

            var jsonList = new List<JsonElement>();

            // 画像名1
            string key = "env_name1";
            string value = targetData["PHOTO_TYTLE_01"].ToString();
            this.MakeEmptyJsonElementForEventInfo(mapJson, elementNameListForExistsCheck, key, value);
            jsonList.Add(mapJson[key]);
            // 画像名2
            key = "env_name2";
            value = targetData["PHOTO_TYTLE_02"].ToString();
            this.MakeEmptyJsonElementForEventInfo(mapJson, elementNameListForExistsCheck, key, value);
            jsonList.Add(mapJson[key]);
            // 画像名3
            key = "env_name3";
            value = targetData["PHOTO_TYTLE_03"].ToString();
            this.MakeEmptyJsonElementForEventInfo(mapJson, elementNameListForExistsCheck, key, value);
            jsonList.Add(mapJson[key]);
            // 画像名4
            key = "env_name4";
            value = targetData["PHOTO_TYTLE_04"].ToString();
            this.MakeEmptyJsonElementForEventInfo(mapJson, elementNameListForExistsCheck, key, value);
            jsonList.Add(mapJson[key]);
            // 画像名5
            key = "env_name5";
            value = targetData["PHOTO_TYTLE_05"].ToString();
            this.MakeEmptyJsonElementForEventInfo(mapJson, elementNameListForExistsCheck, key, value);
            jsonList.Add(mapJson[key]);
            // 画像名6
            key = "env_name6";
            value = targetData["PHOTO_TYTLE_06"].ToString();
            this.MakeEmptyJsonElementForEventInfo(mapJson, elementNameListForExistsCheck, key, value);
            jsonList.Add(mapJson[key]);
            //フィールド名称
            key = "env_fieldName";
            value = targetData["EVENT_CATEGORY_NAME_2"].ToString();
            this.MakeEmptyJsonElementForEventInfo(mapJson, elementNameListForExistsCheck, key, value);
            jsonList.Add(mapJson[key]);
            //画像数
            key = "env_imageNum";
            value = targetData["IMAGE_COUNT"].ToString();
            this.MakeEmptyJsonElementForEventInfo(mapJson, elementNameListForExistsCheck, key, value);
            jsonList.Add(mapJson[key]);
            // 画像列数
            key = "env_imageColNum";
            value = targetData["PHOTO_COL_COUNT"].ToString();
            this.MakeEmptyJsonElementForEventInfo(mapJson, elementNameListForExistsCheck, key, value);
            jsonList.Add(mapJson[key]);

            jsonElementListList.Add(jsonList);
        }

        private void MakeEmptyJsonElementForEventInfo(
          Dictionary<string, JsonElement> mapJson,
          List<string> elementNameListForExistsCheck,
          string jsonName,
          string jsonValue)
        {
            // 不足している要素チェックし、存在しない場合、空のJsonElementを作成する
            if (elementNameListForExistsCheck.Contains(jsonName))
            {
                // 存在しない場合、追加
                var jsonElement = new JsonElement();

                // キーを設定
                jsonElement.keyName = string.Format("\"{0}\"", jsonName);
                // JSONデータフォーマットを設定
                int num = 2;
                jsonElement.jsonDataFormat = (JsonDataFormat)Enum.ToObject(typeof(JsonDataFormat), num); //　とりあえず固定
                // JSONデータタイプを設定
                jsonElement.jsonValueType = "character varying";

                if (string.IsNullOrEmpty(jsonValue))
                {
                    // 空はnull
                    //mod  8332 zc start
                    //jsonElement.value = "null";
                    jsonElement.value = "";
                    //mod  8332 zc end
                }
                else
                {
                    jsonElement.value = jsonValue;
                }

                jsonElement.sqlCreationExclusionFlg = false;

                mapJson[jsonName] = jsonElement;
            }
        }
        // add FNSI_患者イベント項目テンプレートマスタ追加 楊 end

        /// <summary>
        /// 期間を指定してFNWのデータを取得する
        /// </summary>
        /// <param name="startDate">期間開始日</param>
        /// <param name="endDate">期間終了日</param>
        /// <param name="isSync">同期フラグ</param>
        /// <param name="pkeyValue">同期フラグがTrueの場合主キーの値を設定する</param>
        /// <returns></returns>
        public virtual bool SetFnwDataSpecifyPeriod(
            DateTime startDate,
            DateTime endDate,
            bool isSync,
            string pkeyValue)
        {
            return false;
        }

        /// <summary>
        /// SQLのin句を生成する
        /// </summary>
        /// <param name="columnName"></param>
        /// <param name="chunkSize"></param>
        /// <param name="list"></param>
        public string MakeInClause(string columnName, int chunkSize, List<string> list)
        {

            string inClause = "(" + string.Join(" OR ", list.Select((v, i) => new { v, i })
                .GroupBy(x => x.i / chunkSize)
                .Select(g => columnName + " in (" + string.Join(",", g.Select(x => "'" + x.v + "'").ToArray()) + ")")
                .ToArray()) + ")";

            return inClause;
        }

        /// <param name="list"></param>
        public string MakeInClauseAnd(string columnName, int chunkSize, List<string> list)
        {

            string inClause = "(" + string.Join(" and ", list.Select((v, i) => new { v, i })
                .GroupBy(x => x.i / chunkSize)
                .Select(g => columnName + " not in (" + string.Join(",", g.Select(x => "'" + x.v + "'").ToArray()) + ")")
                .ToArray()) + ")";

            return inClause;
        }
        // ADD 8604 周トウ ADLについて START
        /// <summary>
        /// ADLのデータを構築
        /// </summary>
        /// <param name="fnwRecord">fnwデータ</param>
        /// <returns>ADLのデータを構築</returns>
        public static List<string> BuildADLResult(string fnwRecord)
        {
            // 
            List<string> result = new List<string>();

            if (!string.IsNullOrWhiteSpace(fnwRecord))
            {
                // クエリ結果をDicに変換する
                Dictionary<string, Dictionary<string, string>> patDic = new Dictionary<string, Dictionary<string, string>>();
                // Loop1: category_cd
                string[] categoryArr = fnwRecord.Split(new char[] { ',' });
                foreach (string categoryCd in categoryArr)
                {
                    string[] categoryTmpArr = categoryCd.Split(new char[] { '@' });
                    // key: category_cd
                    string key = categoryTmpArr[0];

                    // Loop2: CTL_NO
                    Dictionary<string, string> cateDic = new Dictionary<string, string>();
                    string[] ctlNoArr = categoryTmpArr[1].Split(new char[] { '/' });
                    foreach (string ctlNo in ctlNoArr)
                    {
                        string[] ctlNoTmpArr = ctlNo.Split(new char[] { ':' });

                        string strTemp = ctlNoTmpArr[1];
                        // 文字列処理: "()"を削除
                        strTemp = strTemp.Replace("(", "").Replace(")", "");
                        strTemp = HexStringToBytes(strTemp);
                        strTemp = strTemp.Replace("'", "''").Replace("\\", "\\\\").Replace(Environment.NewLine, "\\n").Replace("\n", "\\n").Replace("\r", "\\n");
                        strTemp = strTemp.Replace("\"", "\\\"");
                        // 文字列処理: 有 -> 有り ; 無 -> 無し
                        strTemp = "有".Equals(strTemp) ? "有り" : strTemp;
                        strTemp = "無".Equals(strTemp) ? "無し" : strTemp;

                        strTemp = "介護保険有".Equals(strTemp) ? "介護保険有り" : strTemp;

                        // 心身状況:意識レベル ->文字列処理: I(半角) -> Ⅰ(全角)
                        //if ("101".Equals(key) && "001".Equals(ctlNoTmpArr[0]))
                        //{
                        //    strTemp = strTemp.Replace("III", "Ⅲ");
                        //    strTemp = strTemp.Replace("II", "Ⅱ");
                        //    strTemp = strTemp.Replace("I", "Ⅰ");
                        //}

                        // 食事摂取(ADL) ->FNW誤り文字列処理: 胃痩 -> 胃瘻
                        strTemp = "胃痩".Equals(strTemp) ? "胃瘻" : strTemp;

                        // 自歯本数 単位追加
                        if ("112".Equals(key) && "003".Equals(ctlNoTmpArr[0])) strTemp += " 本";
                        // 吸引回数 単位追加
                        if ("113".Equals(key) && "004".Equals(ctlNoTmpArr[0])) strTemp += " 回/日";
                        // 酸素吸入量 単位追加
                        if ("113".Equals(key) && "005".Equals(ctlNoTmpArr[0])) strTemp += " L";
                        // 受診科名 単位追加
                        if ("114".Equals(key) && "002".Equals(ctlNoTmpArr[0])) strTemp += " 科";
                        // 食事摂取回数 単位追加
                        if ("213".Equals(key) && "005".Equals(ctlNoTmpArr[0])) strTemp += " 回/日";
                        // 水分摂取量 単位追加
                        if ("213".Equals(key) && "007".Equals(ctlNoTmpArr[0])) strTemp += " ml/日";


                        cateDic.Add(ctlNoTmpArr[0], strTemp);
                    }

                    patDic.Add(key, cateDic);
                }

                // Regex文字列
                string jsonObjMatch = @"\@\S*\@";
                string jsonArrMatch = @"\#\S*\#";
                string normalStr = @"\$\S*\$";

                if (patDic.Count > 0)
                {
                    // category_cdから使用すべきテンプレートを判定する
                    string[] paramList
                        = patDic.Keys.ToArray()[0].StartsWith("1") ? CommonConstants.PAT_PHY_STAT_RESULT_PARAM : CommonConstants.PAT_ADL_RESULT_PARAM;

                    foreach (string line in paramList)
                    {
                        Match objMatch = Regex.Match(line, jsonObjMatch);
                        Match arrayMatch = Regex.Match(line, jsonArrMatch);
                        Match strMatch = Regex.Match(line, normalStr);

                        string bulidStr;
                        string[] codes;
                        // オブジェクト
                        if (objMatch.Success)
                        {
                            bulidStr = "";
                            string strMatchTmp = objMatch.ToString();
                            codes = strMatchTmp.Replace("@", "").Split(new char[] { '-' });
                            // codes[0] -> CATEGORY_CD  ||  codes[1] -> CTL_NO
                            if (patDic.ContainsKey(codes[0]) && patDic[codes[0]].ContainsKey(codes[1]))
                            {
                                bulidStr += "{\"name\":\"" + patDic[codes[0]][codes[1]] + "\",\"score\":\"\"}";
                            }

                            // 追加ADL「未選択」-> FNW「未選択」の場合、記録はなくなるで、コンバート時追加記録
                            else if (codes[0].StartsWith("2"))
                            {
                                bulidStr += "{\"name\": \"未選択\", \"score\":\"\"}";
                            }

                            else
                            {
                                bulidStr += "{}";
                            }
                            result.Add(line.Replace(strMatchTmp, bulidStr));
                        }
                        // レスト
                        else if (arrayMatch.Success)
                        {
                            bulidStr = "";
                            string strMatchTmp = arrayMatch.ToString();
                            codes = strMatchTmp.Replace("#", "").Split(new char[] { '-' });

                            // codes[0] -> CATEGORY_CD  ||  codes[1] -> CTL_NO
                            if (patDic.ContainsKey(codes[0]))
                            {
                                bulidStr += "[";
                                // CTL_NOのリスト
                                Dictionary<string, string> categoryDic = patDic[codes[0]];
                                string[] ctlNoArry = codes[1].Split(new char[] { '/' });

                                foreach (KeyValuePair<string, string> kv in categoryDic)
                                {
                                    if (ctlNoArry.Contains(kv.Key))
                                    {
                                        bulidStr += "{\"name\":\"" + kv.Value + "\",\"score\":\"\"},";
                                    }
                                }
                                if (bulidStr.EndsWith(",")) bulidStr = bulidStr.Substring(0, bulidStr.Length - 1);
                                bulidStr += "]";
                            }
                            else
                            {
                                bulidStr = "[]";
                            }

                            result.Add(line.Replace(strMatchTmp, bulidStr));

                        }
                        // 文字列
                        else if (strMatch.Success)
                        {
                            bulidStr = "";
                            string strMatchTmp = strMatch.ToString();
                            codes = strMatchTmp.Replace("$", "").Split(new char[] { '-' });

                            // codes[0] -> CATEGORY_CD  ||  codes[1] -> CTL_NO
                            if (patDic.ContainsKey(codes[0]) && patDic[codes[0]].ContainsKey(codes[1]))
                            {
                                bulidStr += patDic[codes[0]][codes[1]];
                            }
                            else
                            {
                                bulidStr = "";
                            }

                            result.Add(line.Replace(strMatchTmp, bulidStr));
                        }
                        // upDate
                        else
                        {
                            result.Add(line);
                        }
                    }
                }
            }
            return result;
        }
        // ADD 8604 周トウ ADLについて START
        public static string HexStringToBytes(string hex)
        {
            if (hex.Length % 2 != 0)
            {
                throw new ArgumentException("The binary key cannot have an odd number of digits");
            }
            byte[] bytes = new byte[hex.Length / 2];
            for (int i = 0; i < bytes.Length; i++)
            {
                string byteValue = hex.Substring(i * 2, 2);
                bytes[i] = System.Convert.ToByte(byteValue, 16);
            }
            return Encoding.GetEncoding("shift_jis").GetString(bytes);
            //return Encoding.UTF8.GetString(bytes);
        }
        #endregion

        #region 抽象メソッド

        /// <summary>
        /// コンバート元データ数
        /// </summary>
        public abstract int FnwDataRowCount();

        /// <summary>
        /// コンバート元データ取得
        /// </summary>
        /// <param name="listSelectedPatId">選択した患者IDリスト</param>
        /// <param name="startDate">データ取得期間(開始)</param>
        /// <param name="endDate">データ取得期間(終了)</param>
        /// <param name="isSync">同期処理フラグ</param>
        /// <remarks>
        /// ConvertControlXXX(Pat, Ord, ...)にて実装
        /// </remarks>
        /// <returns>成功：true、失敗：false</returns>
        public virtual bool SetFnwData(List<string> listlistSelectedPatId, DateTime startDate, DateTime endDate, bool isSync)
        {
            return false;
        }

        /// <summary>
        /// コンバート元データ取得(マスタ用)
        /// </summary>
        /// <remarks>
        /// マスタ系テーブル取得クラス作成時必ず実装
        /// </remarks>
        /// <returns>成功：true、失敗：false</returns>
        //mod  7403  2022-05-31 鄭 start
        //public virtual bool SetFnwDataForMst(string mstCd, bool isSync)
        //{
        //    return false;
        //}
        public virtual bool SetFnwDataForMst(string url, string mstCd, bool isSync)
        {
            return false;
        }
        //mod  7403  2022-05-31 鄭 end

        // add #7407 コンバートした施設で遠隔監視画面に過去の装置記録が表示されない 歴程 start
        /// <summary>
        /// コンバート元データ取得(装置記録用)
        /// </summary>
        /// <param name="url">アドレス</param>
        /// <param name="startDate">データ取得期間(開始)</param>
        /// <param name="endDate">データ取得期間(終了)</param>
        /// <param name="tableName">テーブル名</param>
        /// <remarks>
        /// 装置記録情報のテーブル取得クラス作成時必ず実装
        /// </remarks>
        /// <returns>成功：true、失敗：false</returns>
        public virtual bool SetFnwDataForMotion(string url, DateTime startDate, DateTime endDate, string tableName)
        {
            return false;
        }
        // add #7407 コンバートした施設で遠隔監視画面に過去の装置記録が表示されない 歴程 end
        /// <summary>
        /// コンバート元データテーブル取得(子テーブル)
        /// </summary>
        /// <param name="isSync">同期処理フラグ</param>
        /// <remarks>
        /// 子テーブル取得クラス作成時必ず実装
        /// </remarks>
        /// <returns>成功：true、失敗：false</returns>
        public virtual bool SetFnwDataChild(string sqlDirectory, bool isSync)
        {
            return false;
        }

        /// <summary>
        /// データコンバート処理
        /// </summary>
        /// <param name="patid">患者ID</param>
        /// <param name="listConvertData">コンバートデータ</param>
        /// <remarks>
        /// ConvertControlXXX(Pat, Ord, ...)YYY(Main, Event, ...)にて実装
        /// </remarks>
        /// <returns>成功：true、失敗：false</returns>
        public abstract bool Convert(Dictionary<string, List<NtssRecord>> mapConvertData, List<string> listErrorPat);

     

        #endregion
        //add 11138 start
        public string getOffWaterOrTare()
        {

            string list = "json_build_object (";

            for (int i = 1; i <= 7; i++)
            {
                list += "'" + i + "'" + ",json_build_object (";
                list += "'name_1','',";
                list += "'name_2','',";
                list += "'name_3','',";
                list += "'name_4','',";
                list += "'name_5','',";
                list += "'weight_1',0,";
                list += "'weight_2',0,";
                list += "'weight_3',0,";
                list += "'weight_4',0,";
                if (i != 7)
                {
                    list += "'weight_5',0 ),";
                }
                else
                {
                    list += "'weight_5',0 )";
                }

            }
            list += ")";
            return list;
        }
        //add 11138 end


        //mod #10418 start
        private static readonly Dictionary<string, string> ElementPrefixMap =
         new Dictionary<string, string>
        {
                {"0A", "10"} ,
                {"0B", "11"},
                {"0C", "12"},
                {"0D", "13"},
                {"0E", "14"},
                {"0F", "15"},
                {"0G", "16"},
                {"0H", "17"},
                {"0I", "18"},
                {"0J", "19"},
                {"0K", "20"},
                {"0L", "21"},
                {"0M", "22"},
                {"0N", "23"},
                {"0O", "24"},
                {"0P", "25"},
                {"0Q", "26"},
                {"0R", "27"},
                {"0S", "28"},
                {"0T", "29"},
                {"0U", "30"},
                {"0V", "31"},
                {"0W", "32"},
                {"0X", "33"},
                {"0Y", "34"},
                {"0a", "35"},
                {"0b", "36"},
                {"0c", "37"},
                {"1f", "38"},
                {"0e", "39"},
                {"0f", "40"},
                {"0g", "41"},
                {"0h", "42"},
                {"0i", "43"},
                {"0j", "44"},
                {"0k", "45"},
                {"0l", "46"},
                {"0m", "47"},
                {"0n", "48"},
                {"0o", "49"},
                {"0p", "50"},
                {"0q", "51"},
                {"0r", "52"},
                {"0s", "53"},
                {"0t", "54"},
                {"0u", "55"},
                {"0v", "56"},
                {"0w", "57"},
                {"0x", "58"},
                {"0y", "59"},
                {"10", "60"},
                {"11", "61"},
                {"12", "62"},
                {"13", "63"},
                {"14", "64"},
                {"15", "65"},
                {"16", "66"},
                {"17", "67"},
                {"18", "68"},
                {"19", "69"},
                {"1A", "70"},
                {"1B", "71"},
                {"1C", "72"},
                {"1D", "73"},
                {"1E", "74"},
                {"1F", "75"},
                {"1G", "76"},
                {"1H", "77"},
                {"1I", "78"},
                {"1g", "79"},
                {"1K", "80"},
                {"1L", "81"},
                {"1M", "82"},
                {"1N", "83"},
                {"1O", "84"},
                {"1P", "85"},
                {"1Q", "86"},
                {"1R", "87"},
                {"1S", "88"},
                {"1T", "89"},
                {"1U", "90"},
                {"1V", "91"},
                {"1W", "92"},
                {"1X", "93"},
                {"1Y", "94"},
                {"1a", "95"},
                {"1b", "96"},
                {"1h", "97"},
                {"1i", "98"}
        };
        private static readonly Dictionary<string, string> MniSpecialKeyMap =
         new Dictionary<string, string>
        {
            { "Gf", "100" },
            { "Gg", "101" },
            { "Gh", "102" },
            { "Gj", "104" },
            { "Gk", "105" }
        };
        private bool ShouldSkip(string targetData)
        {
            return string.IsNullOrEmpty(targetData) || targetData == "MONI_DATA";
        }

        private bool IsNeedConvertDev5f(string jsonName)
        {
            return jsonName == "device_set_info_ord"
                || jsonName == "ind_device_set_info"
                || jsonName == "ind_device_set_info_sub"
                || jsonName == "treat_condition";
        }

        private static readonly HashSet<string> CEmptyKeys =
                new HashSet<string>
            {
                "c_00","c_01","c_02","c_03","c_0k","c_0l","c_0m","c_0n",
                "c_0o","c_0p","c_0q","c_0r","c_0t","c_0u","c_0v","c_0w",
                "c_0x","c_0y","c_10","c_11","c_13","c_14","c_15","c_16",
                "c_17","c_18","c_19","c_1A","c_1C","c_1D","c_1E","c_1F",
                "c_1G","c_1H","c_1I","c_1J","c_1L","c_1M","c_1N","c_1O",
                "c_1P","c_1Q","c_1R","c_1S"
            };
        private static readonly HashSet<string> HostBooleanKeys = new HashSet<string>
        {
            "host_0Q","host_0N", "host_08","host_0X","host_0K",
            "host_0H", "host_0B", "host_0E","host_0Y","host_0T",
            "host_05", "host_02", "host_0W"
        };
        /// <summary>
        /// 取得した列データを加工して装置設定用のJsonElementを作成する
        /// </summary>
        /// <param name="targetData">対象データ</param>
        /// <param name="ignoreElementName">処理対象外の値（区きり文字で分割した後の値）</param>
        /// <param name="keyPrefix">作成するJsonElementの接頭辞</param>
        /// <param name="mapJson">処理対象のmapJson</param>
        /// <param name="elementNameListForExistsCheck">対象データ内に存在しない場合、空のJsonElementを作成するためのリスト        /// </param>
        /// <param name="jsonName">処理中のJson名</param>
        protected void ProcessingDataForDeviceSetJson(
            string targetData,
            string ignoreElementName,
            string keyPrefix,
            Dictionary<string, List<JsonElement>> mapJson,
            List<string> elementNameListForExistsCheck,
            string jsonName)
        {
            //mod #10418 start
            if (ShouldSkip(targetData))
                return;

            var elementList = targetData.Split('`').ToList();

            var dataSet = BuildDataSet(keyPrefix);

            PreProcessElementList(elementList, keyPrefix, jsonName);


            foreach (var element in elementList)
            {
                if (element == ignoreElementName)
                    continue;

                string selement = ConvertElementPrefix(element, dataSet);

                string key = BuildKey(selement, keyPrefix);

                string value = element.Length > 2 ? element.Substring(2) : "";

                value = ConvertValue(key, value, jsonName);

                var jsonElement = CreatJsonElement(key, value, keyPrefix);

                AddToMap(mapJson, jsonName, jsonElement);
            }
            //mod #10418 end
            this.MakeEmptyJsonElementForDeviceInfo(mapJson, elementNameListForExistsCheck, jsonName);
        }

        private void AddToMap(Dictionary<string, List<JsonElement>> mapJson, string jsonName, JsonElement jsonElement)
        {
            // JSONごとの連想配列に追加
            if (!mapJson.ContainsKey(jsonName))
            {
                mapJson[jsonName] = new List<JsonElement>();
            }
            mapJson[jsonName].Add(jsonElement);

        }
        private JsonElement CreatJsonElement(string key, string value, string keyPrefix)
        {
            var jsonElement = new JsonElement
            {
                keyName = $"\"{key}\"",
                jsonDataFormat = (JsonDataFormat)2,
                jsonValueType = "character varying",
                sqlCreationExclusionFlg = true
            };

            if (string.IsNullOrEmpty(value))
            {
                // 空はnull
                //mod  #7621 2022-05-18    鄭  end
                if (key.Equals("dev_VV") || key.Equals("dev_VW"))
                {
                    jsonElement.value = "-";
                }
                // 8038 コンバート施設で治療記録の装置設定、チェックリストが表示されない 楊 start
                else if (keyPrefix.Equals("c_") && CEmptyKeys.Contains(key))
                {
                    jsonElement.value = "";
                }
                else if (key.Equals("dev_4n"))
                {
                    jsonElement.value = "0.01";
                }
                else if (key.Equals("dev_4h"))
                {
                    jsonElement.value = "0";
                }
                // 8038 コンバート施設で治療記録の装置設定、チェックリストが表示されない 楊 end
                else
                {
                    jsonElement.value = "null";
                }
                //mod  #7621 2022-05-18    鄭  end
            }
            //add 7995 zc start
            else if (keyPrefix.Equals("host_") && HostBooleanKeys.Contains(key))
            {
                jsonElement.value = value == "0" ? false : true;

            }
            //add 7995 zc end
            else
            {
                // 7341 AWS側アプリの処理が遅い start
                if ("mni_monitor".Equals(this.convertTableName))
                {
                    jsonElement.sqlCreationExclusionFlg = false;
                }
                // 7341 AWS側アプリの処理が遅い end
                jsonElement.value = value;
                //10207 zc start
                if ("pat_main".Equals(this.convertTableName) || "pat_main_history".Equals(this.convertTableName))
                {
                    if (key.Equals("dev_1V"))
                    {
                        jsonElement.value = Math.Round(double.Parse(value));
                    }
                }
                //10207 zc end
            }
            //add 7995 zc end

            return jsonElement;
        }
        private string ConvertValue(
            string key,
            string value,
            string jsonName)
        {
            //add #7243 操作範囲」-「除水」-「動脈側気泡検出器」が切り/入りが逆になっている  鄭晨  start
            if ((jsonName == "device_set_info_pat" || jsonName == "device_set_info")
                && key == "dev_0d")
            {
                return value == "0" ? "1" : "0";
            }
            //add #7243 操作範囲」-「除水」-「動脈側気泡検出器」が切り/入りが逆になっている  鄭晨   end

            // #11543 add 差分コンバートで透析液濃度プログラムが更新されない zc start
            if (IsNeedConvertDev5f(jsonName) && (key == "dev_5f" || key == "c_5f"))
            {
                return value == "1" ? "2" : value;
            }
            //#11543 add 差分コンバートで透析液濃度プログラムが更新されない zc end

            return value;
        }
        private string BuildKey(string element, string keyPrefix)
        {
            if (element.Length < 2)
                return keyPrefix;

            string prefix = element.Substring(0, 2);
         
            if (keyPrefix == "mni_" && MniSpecialKeyMap.TryGetValue(prefix, out var specialKey))
            {
                return keyPrefix + specialKey;
            }
            return keyPrefix + prefix;
        }

        private string ConvertElementPrefix(string element, Dictionary<string, string> dataSet)
        {
            if (element.Length < 2)
                return element;

            string prefix = element.Substring(0, 2);

            return dataSet.ContainsKey(prefix)
                ? dataSet[prefix]
                : element;
        }

        private Dictionary<string, string> BuildDataSet(string keyPrefix)
        {
            if (keyPrefix != "mni_")
                return new Dictionary<string, string>();

            return ElementPrefixMap;
        }
        private void PreProcessElementList(List<string> elementList, string keyPrefix, string jsonName)
        {
            if (keyPrefix.Equals("dev_") && (jsonName.Equals("device_set_info") || jsonName.Equals("device_set_info_pat")))
            {
                if (!elementList.Contains("7v"))
                {
                    elementList.Add("7v0");
                }
                if (!elementList.Contains("7w"))
                {
                    elementList.Add("7w100");
                }
            }
        }

        private string BuildInsertSqlTemplate()
        {

            string sqlTemplete;
            if (!CommonConfig.isDiff)
            // add FNSI-差分コンバート対応 楊 end
            {
                // SQL文の雛形作成
                sqlTemplete = "INSERT INTO {0} ({1}) VALUES({2});";

            }
            else
            {

                // SQL文の雛形作成
                sqlTemplete = "INSERT INTO {0} ({1}) VALUES({2})"
                                + " ON CONFLICT ON CONSTRAINT {3}"
                                + " DO UPDATE SET {4};";
                // add 6886 差分追加 zc start
                if (CommonConstants.DIFF_NEW_TABLES.Contains(this.convertTableName))
                {
                    sqlTemplete = "INSERT INTO {0} ({1}) VALUES({2});";
                }

                if (CommonConstants.CUSTOM_UPDATE_CONDITION_TABLES.Contains(this.convertTableName))
                {
                    sqlTemplete = "INSERT INTO {0} ({1}) VALUES({2});"
                               + " @@@@@"
                               + " UPDATE {0} SET {4}";
                }
                // mod #12230 差分コンバートにより元に戻ってしまう項目がある limingzhe end
            }

            // add 7406  ReMS利用施設をコンバートすると送信先グループマスタや警報通知マスタなどのデータが消えている start
            if ("mst_user_authentication".Equals(this.convertTableName))
            {
                sqlTemplete = "INSERT INTO {0} ({1}) VALUES({2})"
                            + " ON CONFLICT ON CONSTRAINT {3}"
                            + " DO UPDATE SET {4} RETURNING xmax, disp_user_id, user_id;";
            }
            // add 7406  ReMS利用施設をコンバートすると送信先グループマスタや警報通知マスタなどのデータが消えている end

            return sqlTemplete;
        }

        private string BuildUpdateBlock(string sqlTemplete, NtssRecord ntssRecord, ConvertValueInfoBase simpleConvertValueInfo,
             Dictionary<string, string> fkConvertValueMap, Dictionary<string, string> customCovertValueSqlMap)
        {

            var updateBlock = "";
            if (sqlTemplete.Contains("{4}"))
            {
                
                Dictionary<string, List<string>> map = CommonConstants.UPDATE_NO_CHANGE_FIELDS;
                if (map.ContainsKey(this.convertTableName))
                {
                    ntssRecord.columns.RemoveAll(c => map[this.convertTableName].Contains(c.name));
                }
                // mod #12230 差分コンバートにより元に戻ってしまう項目がある limingzhe end

                updateBlock = string.Join(",", ntssRecord.columns.Where(ntsscol =>
                        ntsscol.sqlCreationExclusionFlg == false
                        // add 7406  ReMS利用施設をコンバートすると送信先グループマスタや警報通知マスタなどのデータが消えている start
                        && !("mst_user_authentication".Equals(this.convertTableName) && "user_id".Equals(ntsscol.name))).Select(ntsscol =>
                        // add 7406  ReMS利用施設をコンバートすると送信先グループマスタや警報通知マスタなどのデータが消えている end
                        {

                            // 値変換対象のカラムの場合
                            if (simpleConvertValueInfo.ContainsKey(ntsscol.name))
                            {
                                string convertValue = ntsscol.name + "=" + simpleConvertValueInfo.GetConvertValue(ntsscol.name, ntsscol.value.ToString(),
                                ntssRecord, null);
                                return ReplaceSubstitutionVariablesToColumnValue(convertValue, ntssRecord, null, true);
                            }

                            // FK変換対象の列の場合
                            if (fkConvertValueMap.ContainsKey(ntsscol.name) && !ntsscol.colType.Equals(NTSS_DATA_TYPE_JSONB))
                            {
                                // 値を元にSQLを生成し値に設定する
                                string fkValue = string.Format(fkConvertValueMap[ntsscol.name].ToString(), ntsscol.value);
                                // 暗号化対象の場合、暗号化する
                                if (ntsscol.encryptionFlg)
                                {
                                    // mod #10191 djy start
                                    fkValue = MakeColumnSpecialFormat(null, null, fkValue, SpecialColumnType.ENCRYPT_STRING, false);
                                    // mod #10191 djy end
                                }
                                return ntsscol.name + "=" + fkValue;
                            }

                            // add 7406  ReMS利用施設をコンバートすると送信先グループマスタや警報通知マスタなどのデータが消えている start
                            // カスタム値変換対象の列の場合
                            if (customCovertValueSqlMap.ContainsKey(ntsscol.name))
                            {
                                string customSql = ntsscol.name + "=" + customCovertValueSqlMap[ntsscol.name].ToString();
                                //add 12339 コンバート対象とコンバータの設定値見直し zc start
                                if (ntsscol.name.Equals("user_settings") && this.convertTableName.Equals("mst_user"))
                                {
                                    customSql = ntsscol.name + "=" + @"jsonb_set(mst_user.user_settings::jsonb,'{authorized_authorities}',jsonb_build_array({user_settings}),false)";
                                }
                                //add 12339 コンバート対象とコンバータの設定値見直し zc start
                                if (ntsscol.colType.Equals(NTSS_DATA_TYPE_JSONB))
                                {
                                    // 値の置換文字列を列の値に変換（JSONのリストのリストの全ての値を使用する。）
                                    if ("mst_pat_event_data_template".Equals(this.convertTableName))
                                    {
                                        return ntsscol.name + "=" + ReplaceSubstitutionVariablesToColumnValueWithJsonData(customSql, ntssRecord, ntsscol.jsonArray);
                                    }

                                    else if ("pat_personal_main".Equals(this.convertTableName) && "other_contact_info".Equals(ntsscol.name) && ntsscol.value.Equals("json_build_array()"))
                                    {
                                        return ntsscol.name + "=" + "json_build_array()";
                                    }
                                    // add FNSI_患者イベント項目テンプレートマスタ追加 楊 end
                                    //add 9825 zc start
                                    string res = ReplaceSubstitutionVariablesToColumnValueWithJsonAllData(customSql, ntssRecord, ntsscol.jsonArray);
                                    if (res.Equals("NULL"))
                                    {
                                        return ntsscol.name + "=" + res;
                                    }
                                    else
                                    {
                                        return res;
                                    }
                                    //add 9825 zc end
                                }
                                else
                                {
                                    // 値の置換文字列を列の値に変換
                                    
                                    if (null != fnwTableName && "PAT_LIFE_LIST".EndsWith(fnwTableName) && "result_params".Equals(ntsscol.name))
                                    {
                                        return BuildPatLifeResultParamsSql(ntssRecord);
                                    }

                                    // ADD 8604 PAT_ADL -> result_param処理 周トウ START
                                    else if (null != fnwTableName && "PAT_ADL".Equals(fnwTableName) && "result_params".Equals(ntsscol.name))
                                    {
                                        return BuildPatAdlParamsSql(ntssRecord);
                                    }
                                    // ADD 8604 PAT_ADL -> result_param処理 周トウ END
                                    else
                                    {
                                        return ReplaceSubstitutionVariablesToColumnValue(customSql, ntssRecord, null, false);
                                    }
                                }
                            }
                            // add 7406  ReMS利用施設をコンバートすると送信先グループマスタや警報通知マスタなどのデータが消えている end

                            switch (ntsscol.colType)
                            {
                                case NTSS_DATA_TYPE_CHARACTER_VARYING:
                                case NTSS_DATA_TYPE_INET:
                                    // 改行コードエスケープ文字を半角スペースに置き換える
                                    ntsscol.value = ntsscol.value.ToString();

                                    // mod #10153,#10191,#10249 djy end
                                    // 空文字の場合、nullに置き換える
                                    if (ntsscol.value.ToString().Equals(""))
                                    {
                                        //add 7688  鄭 start
                                        if (ntsscol.name.Equals("user_settings") && CommonConfig.isDiff)
                                        {
                                            string customSql = customCovertValueSqlMap[ntsscol.name].ToString();
                                            return ntsscol.name + "=" + ReplaceSubstitutionVariablesToColumnValue(customSql, ntssRecord, null, false);
                                        }
                                        //add  #11576 pat_coop_detailのsave_1がGX固定でコンバートされる start
                                        if (ntsscol.name.Equals("coop_version") && "pat_coop_detail".Equals(this.convertTableName))
                                        {

                                            return ntsscol.name + "=''";
                                        }
                                        //add  #11576 pat_coop_detailのsave_1がGX固定でコンバートされる end
                                        //add 7688  鄭 end
                                        return ntsscol.name + "=null";
                                    }
                                    else
                                    {
                                        // 暗号化対象のカラムの場合、personal_info_decryptファンクションで囲む
                                        if (ntsscol.encryptionFlg)
                                        {
                                            // mod #10191 djy start

                                            return MakeColumnSpecialFormat(null, ntsscol.name, ntsscol.value.ToString(), SpecialColumnType.ENCRYPT_STRING, true);
                                            // mod #10191 djy end
                                        }
                                        else
                                        {
                                            //add 7688  鄭 start
                                            if (ntsscol.name.Equals("user_settings") && CommonConfig.isDiff)
                                            {
                                                string customSql = customCovertValueSqlMap[ntsscol.name].ToString();
                                                return ntsscol.name + "=" + ReplaceSubstitutionVariablesToColumnValue(customSql, ntssRecord, null, false);
                                            }
                                            //end 7688  鄭 end
                                            //add 10739 start
                                            else if (convertTableName.Equals("pat_ind_approve") && ntsscol.name.Equals("check_content") && CommonConfig.isDiff)
                                            {
                                                return ntsscol.name + "=" + ntsscol.value.ToString();
                                            }
                                            //add 10739 end
                                            // mod #10191 djy start

                                            return MakeColumnSpecialFormat(null, ntsscol.name, ntsscol.value.ToString(), SpecialColumnType.NORMAL_STRING, true);
                                            // mod #10191 djy end
                                        }
                                    }
                                case NTSS_DATA_TYPE_TIMESTAMP:
                                    // 空文字の場合、nullに置き換える
                                    if (ntsscol.value.ToString().Equals(""))
                                    {
                                        return ntsscol.name + "=null";
                                    }
                                    else
                                    {
                                        return ntsscol.name + "=TO_TIMESTAMP('" + ntsscol.value.ToString() + "','" + NTSS_DATE_FORMAT + "')";
                                    }
                                case NTSS_DATA_TYPE_JSONB:
                                    //10661 start
                                    if (ntsscol.value == null)
                                    {
                                        return ntsscol.name + "=null";
                                    }
                                    else
                                    {
                                        //add #11667 日常点検コンバート修正 start
                                        string jsonMakeSql = ntsscol.value.ToString();
                                        // 値の置換文字列を列の値に変換
                                        string jsonMakeSqlReplaced = ReplaceSubstitutionVariablesToColumnValue(jsonMakeSql, ntssRecord, null, false);
                                        return ntsscol.name + "=" + jsonMakeSqlReplaced;
                                    }
                                //10661 end

                                default:
                                    // 文字列型でない型で空文字の場合、nullに置き換える
                                    if (ntsscol.value.ToString().Equals(""))
                                    {
                                        return ntsscol.name + "=null";
                                    }
                                    else
                                    {
                                        return ntsscol.name + "=" + ntsscol.value.ToString();
                                    }
                            }
                        }).ToArray());
            }
            return updateBlock;

        }

        private string BuildPatLifeResultParamsSql(NtssRecord ntssRecord) {

            // 観察記録情報の場合、result_paramを設定する
            const string templeteJBOSql = "json_build_object({0})";
            const string templeteJBASql = "result_params = json_build_array(VARIADIC ARRAY[{0}])";
            string jba = "";
            //add 8332 zc start
            string kind_id = ntssRecord.columns.Find(c => c.name.Equals("kind_id")).value.ToString();
            string disp_user_id = ntssRecord.columns.Find(c => c.name.Equals("disp_user_id")).value == null ? null : ntssRecord.columns.Find(c => c.name.Equals("disp_user_id")).value.ToString();
            string all_staff_flg = ntssRecord.columns.Find(c => c.name.Equals("all_staff_flg")).value == null ? null : ntssRecord.columns.Find(c => c.name.Equals("all_staff_flg")).value.ToString();
            //add 8332 zc end
            //add  8293 zc start
            string notice_start_date = string.IsNullOrEmpty(ntssRecord.columns.Find(c => c.name.Equals("notice_start_date")).value.ToString()) ? null : "'" + ntssRecord.columns.Find(c => c.name.Equals("notice_start_date")).value.ToString() + "'";
            string notice_end_date = string.IsNullOrEmpty(ntssRecord.columns.Find(c => c.name.Equals("notice_end_date")).value.ToString()) ? null : "'" + ntssRecord.columns.Find(c => c.name.Equals("notice_end_date")).value.ToString() + "'";
            string starget = ntssRecord.columns.Find(c => c.name.Equals("target")).value == null ? null : ntssRecord.columns.Find(c => c.name.Equals("target")).value.ToString();
            //add  8293 zc end
            foreach (NtssColumn col in ntssRecord.columns)
            {
                // 置換変数が存在する場合
                if (col.name.Contains("detail"))
                {
                    // 値がnullの項目が１つでもある場合、置換変数の置き換えを行わない
                    //mod 8332 zc start
                    string svalue = col.value == null ? "" : col.value.ToString();
                    if (svalue.IndexOf("</p>") > 0)
                    {
                        jba += ", " + string.Join(", ", string.Format(templeteJBOSql, "'format_class', 1 ,'result_value', '" + svalue + "'"));

                    }
                    else
                    {
                        jba += ", " + string.Join(", ", string.Format(templeteJBOSql, "'format_class', 1 ,'result_value', '<p id=\"text-p-0\" style=\"font-size:14pt;font-family:メイリオ;\">" + svalue + "</p>'"));

                    }
                    //mod 8332 zc end

                }
            }
            //mod 8332 zc strat

            jba += ", " + string.Join(", ", string.Format(templeteJBOSql, "'format_class', 9 ,'result_value', ''"));

            string sSql = string.Empty;
            if (all_staff_flg.Equals("1"))
            {
                sSql = "(select ARRAY_AGG( user_id :: int ) from mst_user_authentication where facility_cd='" + this.facilityCd + "')";
            }
            else
            {
                disp_user_id = disp_user_id.Replace("''", "'");
                sSql = "(select ARRAY_AGG( user_id :: int ) from mst_user_authentication where facility_cd='" + this.facilityCd + "' and disp_user_id in(" + disp_user_id + "))";
            }
            //mod  8293 zc start
            if (string.IsNullOrEmpty(notice_end_date) && string.IsNullOrEmpty(notice_start_date))
            {
                jba += ", " + string.Join(", ", string.Format(templeteJBOSql, "'format_class', 10 ,'result_value',json_build_object( 'staff_info',json_build_object('target','" + starget + "','staff_cd',json_build_array(VARIADIC ARRAY[" + sSql + "]) ),'notice_end_date',null,'notice_start_date',null)"));
            }
            else if (string.IsNullOrEmpty(notice_end_date) && !string.IsNullOrEmpty(notice_start_date))
            {
                jba += ", " + string.Join(", ", string.Format(templeteJBOSql, "'format_class', 10 ,'result_value',json_build_object( 'staff_info',json_build_object('target','" + starget + "','staff_cd',json_build_array(VARIADIC ARRAY[" + sSql + "]) ),'notice_end_date',null,'notice_start_date'," + notice_start_date + ")"));

            }
            else if (!string.IsNullOrEmpty(notice_end_date) && string.IsNullOrEmpty(notice_start_date))
            {
                jba += ", " + string.Join(", ", string.Format(templeteJBOSql, "'format_class', 10 ,'result_value',json_build_object( 'staff_info',json_build_object('target','" + starget + "','staff_cd',json_build_array(VARIADIC ARRAY[" + sSql + "]) ),'notice_end_date'," + notice_end_date + ",'notice_start_date',null)"));

            }
            else
            {
                jba += ", " + string.Join(", ", string.Format(templeteJBOSql, "'format_class', 10 ,'result_value',json_build_object( 'staff_info',json_build_object('target','" + starget + "','staff_cd',json_build_array(VARIADIC ARRAY[" + sSql + "]) ),'notice_end_date'," + notice_end_date + ",'notice_start_date'," + notice_start_date + ")"));
            }

            //mod  8293 zc end
            jba += ", " + string.Join(", ", string.Format(templeteJBOSql, "'upDate', '" + DateTime.Now.ToString("yyyy-MM-ddTHH:mm:ss.fffK") + "'"));
            //mod 8332 zc end
            string ret = "";
            if (jba.Equals("") == false)
            {
                ret = string.Format(templeteJBASql, jba.Substring(2));
                return ret;
            }
            return "null";
        }
       
        private string BuildPatAdlParamsSql(NtssRecord ntssRecord) {

            string record = ntssRecord.columns.Find(c => c.name.Equals("result_params")).value.ToString();
            List<string> resultRecords = BuildADLResult(record);
            string resultParam = "";
            foreach (string recLine in resultRecords)
            {
                // update置換処理
                if (recLine.Contains("{upDate}"))
                {
                    string dateChar = ntssRecord.columns.Find(c => c.name.Equals("up_date")).value.ToString();
                    resultParam += recLine.Replace("{upDate}", dateChar);
                }
                else
                {
                    resultParam += recLine;
                }
            }
            // 「"」を置換処理
            resultParam = "result_params='" + resultParam + "'";
            return resultParam;
        }

        public static string RemoveCurlyBracketsContent(string input)
        {
            RegexOptions ops = RegexOptions.Multiline;
            Regex r = new Regex(@"\{.*?\}", ops);

            if (r.IsMatch(input))
            {
                input = r.Replace(input, "");
            }
            return input;
        }
        private void HandleSpecialColumnLogic(
             NtssRecord ntssRecord,
             Dictionary<string, string> delayVariableColumnMap,  List<string> allTreatementKey,  List<string> allTrendGraphKey,  List<string> allTrendGraphKeyTYPE)
        {
            foreach (NtssColumn ntsscol in ntssRecord.columns)
            {
                if (delayVariableColumnMap.ContainsKey(ntsscol.name))
                {
                    ntsscol.sqlCreationExclusionFlg = true;
                };
                // add #11210 djy start
                if (this.convertTableName.Equals("mst_treatment_status_layout") && ntsscol.name.Equals("fn_layout_no"))
                {
                    // mod #11546 hyl start
                    allTreatementKey.Add(ntsscol.value.ToString());
                    // mod #11546 hyl end 
                }
                // add #11210 djy end
                // add #11546 hyl start
                if (this.convertTableName.Equals("mst_trend_graph_monitor_set"))
                {
                    if (ntsscol.name.Equals("fn_monitor_set_cd"))
                    {
                        allTrendGraphKey.Add(ntsscol.value.ToString());
                    }
                    else if (ntsscol.name.Equals("model"))
                    {
                        allTrendGraphKeyTYPE.Add(ntsscol.value.ToString());
                    }
                }
            }
            // add #11546 hyl end
        }

        private string BuildCustomColumnValue(
            string customSql,
            NtssRecord ntssRecord,
            NtssColumn ntsscol,
            string fnwTableName)
        {
  
            if (ntsscol.colType.Equals(NTSS_DATA_TYPE_JSONB))
            {
                return HandleJsonbColumn(customSql, ntssRecord, ntsscol);
            }
           
            return HandleNormalColumn(customSql, ntssRecord, ntsscol, fnwTableName);
        }

        private string HandleJsonbColumn(
           string customSql,
           NtssRecord ntssRecord,
           NtssColumn ntsscol)
        {
            // 値の置換文字列を列の値に変換（JSONのリストのリストの全ての値を使用する。）
            // add FNSI_患者イベント項目テンプレートマスタ追加 楊 start
            if ("mst_pat_event_data_template".Equals(this.convertTableName))
            {
                return ReplaceSubstitutionVariablesToColumnValueWithJsonData(customSql, ntssRecord, ntsscol.jsonArray);
            }

            //add 7800 鄭晨 start
            else if ("mni_monitor".Equals(this.convertTableName) && "monitor_data".Equals(ntsscol.name))
            {
                string data_type = ntssRecord.columns.FirstOrDefault(ntss => ntss.name.Equals("data_type")).value.ToString();
                return ReplaceSubstitutionVariablesToColumnValueWithJsonMonitorData(data_type, customSql, ntssRecord, ntsscol.jsonArray);
            }
            //add 8297 sichengbo start
            else if ("pat_personal_main".Equals(this.convertTableName) && "other_contact_info".Equals(ntsscol.name) && ntsscol.value.Equals("json_build_array()"))
            {
                return "json_build_array()";
            }
            //add 8297 sichengbo end
            //add 7800 鄭晨 end
            // add FNSI_患者イベント項目テンプレートマスタ追加 楊 end
            return ReplaceSubstitutionVariablesToColumnValueWithJsonAllData(customSql, ntssRecord, ntsscol.jsonArray);
        }

        private string HandleNormalColumn(
          string customSql,
          NtssRecord ntssRecord,
          NtssColumn ntsscol,string fnwTableName)
        {
            // mod FNSI-観察記録情報修正 楊 start
            // 値の置換文字列を列の値に変換
            if (null != fnwTableName && "PAT_LIFE_LIST".EndsWith(fnwTableName) && "result_params".Equals(ntsscol.name))
            {
                // 観察記録情報の場合、result_paramを設定する
                const string templeteJBOSql = "json_build_object({0})";
                const string templeteJBASql = "json_build_array(VARIADIC ARRAY[{0}])";
                string jba = "";
                //add 8332 zc start
                string kind_id = ntssRecord.columns.Find(c => c.name.Equals("kind_id")).value.ToString();
                string disp_user_id = ntssRecord.columns.Find(c => c.name.Equals("disp_user_id")).value == null ? null : ntssRecord.columns.Find(c => c.name.Equals("disp_user_id")).value.ToString();
                string all_staff_flg = ntssRecord.columns.Find(c => c.name.Equals("all_staff_flg")).value == null ? null : ntssRecord.columns.Find(c => c.name.Equals("all_staff_flg")).value.ToString();
                //add  8293 zc start
                string notice_start_date = string.IsNullOrEmpty(ntssRecord.columns.Find(c => c.name.Equals("notice_start_date")).value.ToString()) ? null : "'" + ntssRecord.columns.Find(c => c.name.Equals("notice_start_date")).value.ToString() + "'";
                string notice_end_date = string.IsNullOrEmpty(ntssRecord.columns.Find(c => c.name.Equals("notice_end_date")).value.ToString()) ? null : "'" + ntssRecord.columns.Find(c => c.name.Equals("notice_end_date")).value.ToString() + "'";
                string starget = ntssRecord.columns.Find(c => c.name.Equals("target")).value == null ? null : ntssRecord.columns.Find(c => c.name.Equals("target")).value.ToString();
                //add  8293 zc end
                //add 8332 zc end
                foreach (NtssColumn col in ntssRecord.columns)
                {
                    // 置換変数が存在する場合
                    if (col.name.Contains("detail"))
                    {
                        // 値がnullの項目が１つでもある場合、置換変数の置き換えを行わない
                        //mod 8332 zc strat
                        string svalue = col.value == null ? "" : col.value.ToString();
                        if (svalue.IndexOf("</p>") > 0)
                        {
                            jba += ", " + string.Join(", ", string.Format(templeteJBOSql, "'format_class', 1 ,'result_value', '" + svalue + "'"));

                        }
                        else
                        {
                            jba += ", " + string.Join(", ", string.Format(templeteJBOSql, "'format_class', 1 ,'result_value', '<p id=\"text-p-0\" style=\"font-size:14pt;font-family:メイリオ;\">" + svalue + "</p>'"));

                        }
                        //mod 8332 zc end
                        if (!kind_id.Equals("0"))
                        {
                            break;
                        }
                    }
                }
                //mod 8332 zc strat

                jba += ", " + string.Join(", ", string.Format(templeteJBOSql, "'format_class', 9 ,'result_value', ''"));
                string sSql = string.Empty;
                if (all_staff_flg.Equals("1"))
                {
                    sSql = "(select ARRAY_AGG( user_id :: int ) from mst_user_authentication where facility_cd='" + this.facilityCd + "')";
                }
                else
                {
                    disp_user_id = disp_user_id.Replace("''", "'");
                    sSql = "(select ARRAY_AGG( user_id :: int ) from mst_user_authentication where facility_cd='" + this.facilityCd + "' and disp_user_id in(" + disp_user_id + "))";
                }
                //mod  8293 zc start
                if (string.IsNullOrEmpty(notice_end_date) && string.IsNullOrEmpty(notice_start_date))
                {
                    jba += ", " + string.Join(", ", string.Format(templeteJBOSql, "'format_class', 10 ,'result_value',json_build_object( 'staff_info',json_build_object('target','" + starget + "','staff_cd',json_build_array(VARIADIC ARRAY[" + sSql + "]) ),'notice_end_date',null,'notice_start_date',null)"));
                }
                else if (string.IsNullOrEmpty(notice_end_date) && !string.IsNullOrEmpty(notice_start_date))
                {
                    jba += ", " + string.Join(", ", string.Format(templeteJBOSql, "'format_class', 10 ,'result_value',json_build_object( 'staff_info',json_build_object('target','" + starget + "','staff_cd',json_build_array(VARIADIC ARRAY[" + sSql + "]) ),'notice_end_date',null,'notice_start_date'," + notice_start_date + ")"));

                }
                else if (!string.IsNullOrEmpty(notice_end_date) && string.IsNullOrEmpty(notice_start_date))
                {
                    jba += ", " + string.Join(", ", string.Format(templeteJBOSql, "'format_class', 10 ,'result_value',json_build_object( 'staff_info',json_build_object('target','" + starget + "','staff_cd',json_build_array(VARIADIC ARRAY[" + sSql + "]) ),'notice_end_date'," + notice_end_date + ",'notice_start_date',null)"));

                }
                else
                {
                    jba += ", " + string.Join(", ", string.Format(templeteJBOSql, "'format_class', 10 ,'result_value',json_build_object( 'staff_info',json_build_object('target','" + starget + "','staff_cd',json_build_array(VARIADIC ARRAY[" + sSql + "]) ),'notice_end_date'," + notice_end_date + ",'notice_start_date'," + notice_start_date + ")"));
                }

                //mod  8293 zc end
                jba += ", " + string.Join(", ", string.Format(templeteJBOSql, "'upDate', '" + DateTime.Now.ToString("yyyy-MM-ddTHH:mm:ss.fffK") + "'"));

                //mod 8332 zc end
                string ret = "";
                if (jba.Equals("") == false)
                {
                    ret = string.Format(templeteJBASql, jba.Substring(2));
                    return ret;
                }
                return "null";
            }
            // ADD 8604 PAT_ADL -> result_param処理 周トウ START
            else if (null != fnwTableName && "PAT_ADL".Equals(fnwTableName) && "result_params".Equals(ntsscol.name))
            {
                string record = ntssRecord.columns.Find(c => c.name.Equals("result_params")).value.ToString();
                List<string> resultRecords = BuildADLResult(record);
                string resultParam = "";
                foreach (string recLine in resultRecords)
                {
                    // update置換処理
                    if (recLine.Contains("{upDate}"))
                    {
                        string dateChar = ntssRecord.columns.Find(c => c.name.Equals("up_date")).value.ToString();
                        resultParam += recLine.Replace("{upDate}", dateChar);
                    }
                    else
                    {
                        resultParam += recLine;
                    }
                }
                // 「"」を置換処理

                resultParam = "'" + resultParam + "'";
                return resultParam;
            }
            // ADD 8604 PAT_ADL -> result_param処理 周トウ END
            else
            {
                return ReplaceSubstitutionVariablesToColumnValue(customSql, ntssRecord, null, false);
            }


            // add FNSI-観察記録情報修正 楊 end
        }
        private void HandleSyncTreatmentLayout(
            List<string> allTreatementKey,
            List<string> allTrendGraphKey,
            List<string> allTrendGraphKeyTYPE,
            string sqlFilePath)
        {
            if (!IsTargetSyncTable()) return;

            List<string> allTreatementKeys = new List<string>();
            if (this.convertTableName.Equals("mst_treatment_status_layout"))
            {
                allTreatementKeys = allTreatementKey;
            }
            else
            {
                allTreatementKeys.Clear();
                for (int i = 0; i < allTrendGraphKey.Count; i++)
                {
                    allTreatementKeys.Add(allTrendGraphKey[i] + allTrendGraphKeyTYPE[i]);
                }
            }
            if (allTreatementKeys.Count > 0)
            {
                string type = string.Empty;
                if (this.convertTableName.Equals("mst_treatment_status_layout"))
                {
                    type = "TYPE = :TYPE  and ";
                }
                else
                {
                    type = "";
                }
                // mod #11546 hyl end
                if (CommonConfig.isDiff)
                {
                    //mod  #12229 前回convertを実行した時刻 start 
                    ConvertDatetimeResult result = CacheInformation.Instance.GetEffectiveConvertDatetime("MST");
                    DateTime convertDateTime = result.ConvertDatetime;
                    bool hasDiff = result.HasDiff;

                    IMakeSqlParameters param = db.GetIMakeSqlParameters();
                    param.AddParam(":CONVERT_DATETIME", convertDateTime);
                    param.AddParam(":FNW_TABLE_NAME", this.convertTableName);
                    if (type != "")
                    {
                        param.AddParam(":TYPE", allTreatementKeys[0][0].ToString());
                    }

                    // mod #11546 hyl start

                    var treatementSql = $"SELECT S.FNGROUP_CD,S.TYPE FROM SYNC_TREATEMENT_LAYOUT S where  S.CONVERT_DATETIME = :CONVERT_DATETIME and " + type + "  FNW_TABLE_NAME = :FNW_TABLE_NAME ";

                    List<string> oldTreatementList = new List<string>();
                    oldTreatementList = db.SelectTable(treatementSql, param.GetParam()).AsEnumerable().Select(r => r["FNGROUP_CD"].ToString()).ToList<string>();
                    //mod  #12229 前回convertを実行した時刻 end 

                    var delTreatementList = oldTreatementList.Except(allTreatementKeys).ToList();
                    // mod #11546 hyl end
                    if (delTreatementList.Count > 0)
                    {
                        int itemsPerLine = 1000;
                        string dPath = Path.GetDirectoryName(sqlFilePath);
                        // mod #11546 hyl start
                        //string outputPath = Path.Combine(dPath, "DelTreatement.txt");
                        string outputPath = string.Empty;
                        if (this.convertTableName.Equals("mst_treatment_status_layout"))
                        {
                            outputPath = Path.Combine(dPath, "DelTreatement.txt");
                        }
                        else
                        {
                            outputPath = Path.Combine(dPath, "DelTrendGraphMonitorSet.txt");
                        }
                        // mod #11546 hyl end
                        bool append = File.Exists(outputPath);
                        using (StreamWriter sw = new StreamWriter(outputPath, append))
                        {
                            for (int i = 0; i < delTreatementList.Count; i += itemsPerLine)
                            {
                                int end = Math.Min(i + itemsPerLine, delTreatementList.Count);
                                List<string> batch = delTreatementList.GetRange(i, end - i);
                                string commaSeparatedString = string.Join(",", batch);
                                sw.WriteLine(commaSeparatedString);
                            }
                        }
                    }
                }

                InsertSyncTreatmentLayoutBatchSafe(allTreatementKeys, allTrendGraphKeyTYPE);
                
            }
        }

        private void InsertSyncTreatmentLayoutBatchSafe(List<string> allTreatementKeys, List<string> allTrendGraphKeyTYPE) {

            StringBuilder sqlBuilder = new StringBuilder();
            var param = db.GetIMakeSqlParameters();

            sqlBuilder.Append("INSERT INTO SYNC_TREATEMENT_LAYOUT (FNGROUP_CD, TYPE, CONVERT_DATETIME, FNW_TABLE_NAME) ");
            sqlBuilder.Append("SELECT * FROM (");

            for (int j = 0; j < allTreatementKeys.Count; j++)
            {
                if (j > 0)
                    sqlBuilder.Append(" UNION ALL ");

                string typeValue = this.convertTableName.Equals("mst_treatment_status_layout")
                        ? allTreatementKeys[0][0].ToString()
                        : allTrendGraphKeyTYPE[j];

                string p1 = $":FNGROUP_CD_{j}";
                string p2 = $":TYPE_{j}";
                string p3 = $":CONVERT_DATETIME_{j}";
                string p4 = $":FNW_TABLE_NAME_{j}";

                sqlBuilder.Append("SELECT ");
                sqlBuilder.Append($"{p1}, ");
                sqlBuilder.Append($"{p2}, ");
                sqlBuilder.Append($"{p3}, ");
                sqlBuilder.Append($"{p4} ");
                sqlBuilder.Append("FROM DUAL");

                param.AddParam(p1, allTreatementKeys[j].ToString());
                param.AddParam(p2, typeValue);
                param.AddParam(p3, CommonConfig.UpDate);
                param.AddParam(p4, this.convertTableName);
            }

            sqlBuilder.Append(")");

            db.ExecuteSQL(sqlBuilder.ToString(), param.GetParam());

        }

        private bool IsTargetSyncTable()
        {
            return this.convertTableName.Equals("mst_treatment_status_layout")
                || this.convertTableName.Equals("mst_trend_graph_monitor_set");
        }
        private string ResolveOrdMainKey(string keyColNm, NtssRecord ntssRecord)
        {
            if (!"ord_main".Equals(this.convertTableName))
                return keyColNm;

            string fnPlural = ntssRecord.columns.FirstOrDefault(ntsscol => ntsscol.name.Equals("fn_plural")).value.ToString();

            if (fnPlural == "0")
            {
                return "{fn_plural}{rst_fn_dialysis_no}";
            }

            return "{fn_plural}{fn_pat_id}{treat_date}";
        }
        private string GetPatIdIfRequired(
            bool isMakePatidFolder,
            NtssRecord ntssRecord)
        {
            if (!isMakePatidFolder)
                return null;

            var patColumn = ntssRecord.columns
                .FirstOrDefault(c =>
                    c.name.Equals("pat_id") ||
                    c.name.Equals("fn_pat_id"));

            if (patColumn == null)
            {
                throw new Exception("患者IDの列が存在しません。");
            }

            return patColumn.value?.ToString();

        }

        private void HandleInsuranceAndJsonLogic(
            NtssRecord ntssRecord,
            NtssColumn ntsscol,
            ConvertValueInfoBase simpleConvertValueInfo,
            Dictionary<string, string> fkConvertValueMap,
            Dictionary<string, string> customCovertValueSqlMap)
        {
            int insuClass = -1;
            //add #9969 djy start
            // mod #11356 djy start
            bool is_va_flg = false;
            // mod #11356 djy end
            //add #9969 djy end
            foreach (NtssColumn ntsscol1 in ntssRecord.columns)
            {
                //add #9969 djy start
                // mod #11356 djy start
                if ("pat_event".Equals(this.convertTableName) && "result_value_2".Equals(ntsscol.name) && ntsscol1.name.Equals("va_flg"))
                // mod #11356 djy end
                {
                    is_va_flg = "1".Equals(ntsscol1.value.ToString());
                };
                //add #9969 djy end
                if (ntsscol1.name.Equals("insu_class"))
                {
                    insuClass = int.Parse(ntsscol1.value.ToString());
                    break;
                };
            }

            if (
            (insuClass == 0 && (ntsscol.name.Equals("insu_pub_info") || ntsscol.name.Equals("insu_set_info"))) == false
            && (insuClass == 1 && (ntsscol.name.Equals("insu_info") || ntsscol.name.Equals("insu_set_info"))) == false
            && (insuClass == 2 && (ntsscol.name.Equals("insu_info") || ntsscol.name.Equals("insu_pub_info"))) == false
            )
            {
                //add #9969 djy start
                // mod #11356 djy start
                if ("pat_event".Equals(this.convertTableName) && "result_value_2".Equals(ntsscol.name) && !is_va_flg)
                // mod #11356 djy end
                {
                    ntsscol.jsonArray.ForEach(item =>
                    {
                        var del = item.Where(i =>
                              "\"name\"".Equals(i.keyName) || "\"is_send_va\"".Equals(i.keyName)
                        ).ToList();

                        del.ForEach(d =>
                        {
                            item.Remove(d);
                        });
                    });
                }
                //add #9969 djy end
                // JSONデータから登録用SQL文を生成する
                ntsscol.value = MakeSqlBlockForJson(ntsscol.name,
                                    ntsscol.jsonArray,
                                    simpleConvertValueInfo,
                                    fkConvertValueMap,
                                    customCovertValueSqlMap,
                                    ntssRecord);
                //add 9666 #11138 start
                if (CommonConstants.NULL_REPLACE_EMPTY.Contains(this.convertTableName + "-" + ntsscol.name))
                {
                    if (this.convertTableName.Contains("pat_main") && ntsscol.value.ToString().Equals("null"))
                    {
                        ntsscol.value = getOffWaterOrTare();
                    }
                    else
                    {
                        ntsscol.value = ntsscol.value.ToString().Replace("null", "''");
                    }
                }
                //add 9666 #11138  end
            }
        }

        //mod #10418 end
    }
}