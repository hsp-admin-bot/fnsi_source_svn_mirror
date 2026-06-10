using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using Fnw.IOControl.DB;
using System.IO;
using System.Xml.Linq;
using ConvertCommon.Const;
using ConvertCommon.Dto;
using ConvertCommon.Common;

namespace ConvertCommon
{
    public class ConvertControl
    {
        /// <summary>[FNWテーブル名]SCH_DIALYSIS_PLAN</summary>
        public const string FNW_TABLE_SCH_DIALYSIS_PLAN = "SCH_DIALYSIS_PLAN";
        /// <summary>[FNWテーブル名]IND_DEVELOP_PLAN</summary>
        public const string FNW_TABLE_IND_DEVELOP_PLAN = "IND_DEVELOP_PLAN";
        /// <summary>[FNWテーブル名]IND_DEVELOP_COND</summary>
        public const string FNW_TABLE_IND_DEVELOP_COND = "IND_DEVELOP_COND";
        /// <summary>[FNWテーブル名]IND_DEVELOP_MEDI</summary>
        public const string FNW_TABLE_IND_DEVELOP_MEDI = "IND_DEVELOP_MEDI";
        /// <summary>[FNWテーブル名]IND_DEVELOP_EQUIP</summary>
        public const string FNW_TABLE_IND_DEVELOP_EQUIP = "IND_DEVELOP_EQUIP";
        /// <summary>[FNWテーブル名]IND_DEVELOP_ADD</summary>
        public const string FNW_TABLE_IND_DEVELOP_ADD = "IND_DEVELOP_ADD";
        /// <summary>[FNWテーブル名]IND_DIALYSIS_PLAN</summary>
        public const string FNW_TABLE_IND_DIALYSIS_PLAN = "IND_DIALYSIS_PLAN";
        /// <summary>RST_DIALYSIS_PLAN</summary>
        public const string FNW_TABLE_RST_DIALYSIS_PLAN = "RST_DIALYSIS_PLAN";
        /// <summary>[FNWテーブル名]IND_DIALYSIS_COND</summary>
        public const string FNW_TABLE_IND_DIALYSIS_COND = "IND_DIALYSIS_COND";
        /// <summary>[FNWテーブル名]IND_DIALYSIS_MEDI</summary>
        public const string FNW_TABLE_IND_DIALYSIS_MEDI = "IND_DIALYSIS_MEDI";
        /// <summary>[FNWテーブル名]IND_DIALYSIS_EQUIP</summary>
        public const string FNW_TABLE_IND_DIALYSIS_EQUIP = "IND_DIALYSIS_EQUIP";
        /// <summary>[FNWテーブル名]IND_DIALYSIS_ADD</summary>
        public const string FNW_TABLE_IND_DIALYSIS_ADD = "IND_DIALYSIS_ADD";
        /// <summary>[FNWテーブル名]RST_DIALYSIS</summary>
        public const string FNW_TABLE_RST_DIALYSIS = "RST_DIALYSIS";
        /// <summary>[FNWテーブル名]RST_DIALYSIS_WEIGHT</summary>
        public const string FNW_TABLE_RST_DIALYSIS_WEIGHT = "RST_DIALYSIS_WEIGHT";
        /// <summary>[FNWテーブル名]RST_DIALYSIS_COND</summary>
        public const string FNW_TABLE_RST_DIALYSIS_COND = "RST_DIALYSIS_COND";
        /// <summary>[FNWテーブル名]RST_DIALYSIS_MEDICATION</summary>
        public const string FNW_TABLE_RST_DIALYSIS_MEDICATION = "RST_DIALYSIS_MEDICATION";
        /// <summary>[FNWテーブル名]RST_DIALYSIS_EQUIP</summary>
        public const string FNW_TABLE_RST_DIALYSIS_EQUIP = "RST_DIALYSIS_EQUIP";
        /// <summary>[FNWテーブル名]RST_DIALYSIS_ADDITION</summary>
        public const string FNW_TABLE_RST_DIALYSIS_ADDITION = "RST_DIALYSIS_ADDITION";
        /// <summary>[FNWテーブル名]RST_DIALYSIS_VITAL</summary>
        public const string FNW_TABLE_RST_DIALYSIS_VITAL = "RST_DIALYSIS_VITAL";
        /// <summary>[FNWテーブル名]RST_DIALYSIS_TARE</summary>
        public const string FNW_TABLE_RST_DIALYSIS_TARE = "RST_DIALYSIS_TARE";
        /// <summary>[FNWテーブル名]RST_DIALYSIS_TARE</summary>
        public const string FNW_TABLE_RST_DIALYSIS_TARE_BEFORE = "RST_DIALYSIS_TARE_BEFORE";
        /// <summary>[FNWテーブル名]RST_DIALYSIS_TARE</summary>
        public const string FNW_TABLE_RST_DIALYSIS_TARE_AFTER = "RST_DIALYSIS_TARE_AFTER";
        /// <summary>[FNWテーブル名]RST_DIALYSIS_WATER_REMOVE</summary>
        public const string FNW_TABLE_RST_DIALYSIS_WATER_REMOVE = "RST_DIALYSIS_WATER_REMOVE";
        /// <summary>[FNWテーブル名]RST_DIALYSIS_DEVICE</summary>
        public const string FNW_TABLE_RST_DIALYSIS_DEVICE = "RST_DIALYSIS_DEVICE";
        /// <summary>[FNWテーブル名]RST_DIALYSIS_TREATMENT</summary>
        public const string FNW_TABLE_RST_DIALYSIS_TREATMENT = "RST_DIALYSIS_TREATMENT";
        /// <summary>[FNWテーブル名]RST_DIALYSIS_COMPLAINT</summary>
        public const string FNW_TABLE_RST_DIALYSIS_COMPLAINT = "RST_DIALYSIS_COMPLAINT";
        /// <summary>[FNWテーブル名]RST_DIALYSIS_TREAT_PERSON</summary>
        public const string FNW_TABLE_RST_DIALYSIS_TREAT_PERSON = "RST_DIALYSIS_TREAT_PERSON";
        /// <summary>[FNWテーブル名]RST_RECEIPT_MEMO</summary>
        public const string FNW_TABLE_RST_RECEIPT_MEMO = "RST_RECEIPT_MEMO";
        /// <summary>[FNWテーブル名]PAT_DEVICE_SET</summary>
        public const string FNW_TABLE_PAT_DEVICE_SET = "PAT_DEVICE_SET";
        /// <summary>[FNWテーブル名]PAT_REVISE_OFFWATER</summary>
        public const string FNW_TABLE_PAT_REVISE_OFFWATER = "PAT_REVISE_OFFWATER";
        /// <summary>[FNWテーブル名]PAT_REVISE_TARE</summary>
        public const string FNW_TABLE_PAT_REVISE_TARE = "PAT_REVISE_TARE";
        ///<summary>[FNWテーブル名]PAT_LIFE_LIST</summary>
        public const string FNW_TABLE_PAT_LIFE_LIST = "PAT_LIFE_LIST";
        ///<summary>指示の最新更新者情報</summary>
        public const string FNW_TABLE_IND_DIALYSIS_UPD_INFO = "IND_DIALYSIS_UPD_INFO";
        ///<summary>実際指示の最新更新者情報</summary>
        public const string FNW_TABLE_RST_DIALYSIS_UPD_INFO = "RST_DIALYSIS_UPD_INFO";
        ///<summary>指示</summary>
        public const string FNW_ORD_MAIN_IND = "ORD_MAIN_IND";
        ///<summary>実際</summary>
        public const string FNW_ORD_MAIN_RST = "ORD_MAIN_RST";
        ///<summary>[FNWテーブル名]COP_EVENT_MANAGE</summary>
        public const string FNW_TABLE_COP_EVENT_MANAGE = "COP_EVENT_MANAGE";
        ///<summary>[FNWテーブル名]IND_RECEIVE</summary>
        public const string FNW_TABLE_IND_RECEIVE = "IND_RECEIVE";
        /// <summary>[FNWテーブル名]IND_DEVELOP_ADD_MANUAL</summary>
        public const string FNW_TABLE_IND_DEVELOP_ADD_MANUAL = "IND_DEVELOP_ADD_MANUAL";
        /// <summary>[FNWテーブル名]IND_DEVELOP_COND_MANUAL</summary>
        public const string FNW_TABLE_IND_DEVELOP_COND_MANUAL = "IND_DEVELOP_COND_MANUAL";
        /// <summary>[FNWテーブル名]IND_DEVELOP_EQUIP_MANUAL</summary>
        public const string FNW_TABLE_IND_DEVELOP_EQUIP_MANUAL = "IND_DEVELOP_EQUIP_MANUAL";
        /// <summary>[FNWテーブル名]IND_DEVELOP_MEDI_MANUAL</summary>
        public const string FNW_TABLE_IND_DEVELOP_MEDI_MANUAL = "IND_DEVELOP_MEDI_MANUAL";
        /// <summary>[FNWテーブル名]IND_DEVELOP_PLAN_MANUAL</summary>
        public const string FNW_TABLE_IND_DEVELOP_PLAN_MANUAL = "IND_DEVELOP_PLAN_MANUAL";

        /// <summary>[NTSSテーブル名]pat_main</summary>
        public const string NTSS_TABLE_PAT_MAIN = "pat_main";
        /// <summary>[NTSSテーブル名]pat_event</summary>
        public const string NTSS_TABLE_PAT_EVENT = "pat_event";
        /// <summary>[NTSSテーブル名]pat_obs_rec</summary>
        public const string NTSS_TABLE_PAT_OBS_REC = "pat_obs_rec";
        /// <summary>[NTSSテーブル名]pat_prescription</summary>
        public const string NTSS_TABLE_PAT_PRESCRIPTION = "pat_prescription";
        /// <summary>[NTSSテーブル名]pat_prescription_detail</summary>
        public const string NTSS_TABLE_PAT_PRESCRIPTION_DETAIL = "pat_prescription_detail";
        /// <summary>[NTSSテーブル名]ord_main</summary>
        public const string NTSS_TABLE_ORD_MAIN = "ord_main";
        // add FNSI-FN本体_データマッピング (進捗管理更新) supply_coop対応 楊 start
        /// <summary>[NTSSテーブル名]ord_material_save</summary>
        public const string NTSS_TABLE_ORD_MATERIAL_SAVE = "ord_material_save";
        // add FNSI-FN本体_データマッピング (進捗管理更新) supply_coop対応 楊 end
        /// <summary>[NTSSテーブル名]mni_monitor</summary>
        public const string NTSS_TABLE_MNI_MONITOR = "mni_monitor";
        /// <summary>[NTSSテーブル名]ord_checklist</summary>
        public const string NTSS_TABLE_ORD_CHECKLIST = "ord_checklist";
        /// <summary>[NTSSテーブル名]pat_rad_main</summary>
        public const string NTSS_TABLE_PAT_RAD_MAIN = "pat_rad_main";
        /// <summary>[NTSSテーブル名]pat_rad_main</summary>
        public const string NTSS_TABLE_PAT_EXAM_MAIN = "pat_exam_main";
        /// <summary>[NTSSテーブル名]pat_treatment_pattern</summary>
        public const string NTSS_TABLE_PAT_TREATMENT_PATTERN = "pat_treatment_pattern";
        /// <summary>[NTSSテーブル名]pat_treatment_pattern</summary>
        public const string NTSS_TABLE_ORD_WEIGHT_SCALE = "ord_weight_scale";
        // add #7407 コンバートした施設で遠隔監視画面に過去の装置記録が表示されない 歴程 start
        /// <summary>[NTSSテーブル名]mnt_motion_record</summary>
        public const string NTSS_TABLE_MNT_MOTION_RECORD = "mnt_motion_record";
        // add #7407 コンバートした施設で遠隔監視画面に過去の装置記録が表示されない 歴程 end
        // add #8038 コンバート施設で一部の情報が表示されない 楊 start
        /// <summary>[NTSSテーブル名]ord_treat_condition</summary>
        public const string NTSS_TABLE_ORD_TREAT_CONDITION = "ord_treat_condition";
        // add #8038 コンバート施設で一部の情報が表示されない 楊 end

       
        /// <summary>施設コード</summary>
        private string facilityCd;
        /// <summary>系列施設コード</summary>
        private string seriesCd;
        /// <summary>コンバート処理クラス</summary>
        private ConvertBase procConvert;
        /// <summary>コンバート処理クラス(子テーブル用)</summary>
        private ConvertBase procConvertChild;
        private bool isParent;
        /// <summary>全てのコンバートデータ(key: 患者ID, value: コンバートデータリスト)</summary>
        private Dictionary<string, List<ConvertBase.NtssRecord>> mapConvertData;
        /// <summary>全てのコンバートデータ(key: 患者ID, value: コンバートデータリスト)(子テーブル用)</summary>
        private Dictionary<string, List<ConvertBase.NtssRecord>> mapConvertDataChild;

        /// <summary>元データ取得用SQLフォルダルートパス(...\SQL)</summary>
        private string sqlRootDirectory;

        /// <summary>マスタのキャッシュ</summary>
        private Dictionary<string, DataTable> mapFnwMstCache;
        /// <summary>紐付けテーブル</summary>
        protected DataTable dtRelation;
        /// <summary>コンバートテーブル情報定義XML</summary>
        protected XDocument xml;
        /// <summary>紐付けテーブル名</summary>
        protected string relationTableName;

        private CONV_TYPE convType;

        /// <summary>テーブルの親子関係</summary>
        public static Dictionary<string, string> mapParentChild = new Dictionary<string, string>();
       

        /// <summary>移行元FNWテーブル名と移行先NTSSテーブル名</summary>
        public static Dictionary<string, string> mapFnwNtssTable = new Dictionary<string, string>()
        {
            { FNW_TABLE_SCH_DIALYSIS_PLAN, NTSS_TABLE_ORD_MAIN },
            { FNW_TABLE_IND_DEVELOP_PLAN, NTSS_TABLE_ORD_MAIN },
            { FNW_TABLE_RST_DIALYSIS, NTSS_TABLE_ORD_MAIN },
        };

      

        /// <summary>
        /// ConvertControl動作設定
        /// ALL:未使用
        /// PAT_SPECIFY_PERIOD:患者ID、期間指定
        /// ALL_RECORD：全レコード処理
        /// SPECIFY_PERIOD:期間指定
        /// </summary>
        public enum CONV_TYPE
        {
            ALL = 0,
            PAT_SPECIFY_PERIOD,
            ALL_RECORD,
            SPECIFY_PERIOD,
            // add #7407 コンバートした施設で遠隔監視画面に過去の装置記録が表示されない 歴程 start
            MOTION,
            // add #7407 コンバートした施設で遠隔監視画面に過去の装置記録が表示されない 歴程 end
        }

        private CONV_TYPE _convertType
        {
            get { return convType; }
            set { convType = value; }
        }

        

        /// <summary>
        /// コンストラクタ
        /// </summary>
        /// <param name="facilityCd">施設コード</param>
        /// <param name="seriesCd">系列施設コード</param>
        /// <param name="sqlDirectory">元データ取得SQLフォルダパス</param>
        /// <param name="targetTableInfo">処理対象のテーブルのコンバート設定</param>
        public ConvertControl(
            string facilityCd,
            string seriesCd,
            string sqlDirectory,
            CONV_TYPE convertType)
        {
            this.facilityCd = facilityCd;
            this.seriesCd = seriesCd;
            this.sqlRootDirectory = sqlDirectory.TrimEnd('\\');
            this._convertType = convertType;

            // mod #7407 コンバートした施設で遠隔監視画面に過去の装置記録が表示されない 歴程 start
            //ReadConfigXmlFile();
            if ("MOTION".Equals(convertType.ToString()))
            {
                ReadMotionConfigXmlFile();
            } 
            else
            {
                ReadConfigXmlFile();
            }
            // mod #7407 コンバートした施設で遠隔監視画面に過去の装置記録が表示されない 歴程 end
            mapFnwMstCache = new Dictionary<string, DataTable>();
        }

        /// <summary>
        /// コンバートテーブル設定ファイルを読み込みクラス変数へ格納する
        /// </summary>
        /// <returns>true:成功 false:失敗</returns>
        public bool ReadConfigXmlFile()
        {

            // add 2023-07-06 #8585 マルチスレッド start
            lock (Common.FileLock.config)
            {
                // add 2023-07-06 #8585 マルチスレッド end
                // マスタ定義XML読み込み
                var xmlFilePath = Path.Combine(sqlRootDirectory, @"config\ConvertInfo.xml");
                if (File.Exists(xmlFilePath) == false)
                {
                    // SQLファイルなし
                    ConvertBase.WriteErrorLog("マスタ情報定義XMLファイルが存在しません。(ファイルパス：{0})", xmlFilePath);
                    return false;
                }
                else
                {
                    xml = XDocument.Load(xmlFilePath);
                    return true;
                }
                // add 2023-07-06 #8585 マルチスレッド start
            }
            // add 2023-07-06 #8585 マルチスレッド end
        }

        // add #7407 コンバートした施設で遠隔監視画面に過去の装置記録が表示されない 歴程 start
        /// <summary>
        /// コンバートテーブル設定ファイルを読み込みクラス変数へ格納する
        /// </summary>
        /// <returns>true:成功 false:失敗</returns>
        public bool ReadMotionConfigXmlFile()
        {
            // add 2023-07-06 #8585 マルチスレッド start
            lock (Common.FileLock.config)
            {
                // add 2023-07-06 #8585 マルチスレッド end
                // マスタ定義XML読み込み
                var xmlFilePath = Path.Combine(sqlRootDirectory, @"config\ConvertMotionConfig.xml");
                if (File.Exists(xmlFilePath) == false)
                {
                    // SQLファイルなし
                    ConvertBase.WriteErrorLog("マスタ情報定義XMLファイルが存在しません。(ファイルパス：{0})", xmlFilePath);
                    return false;
                }
                else
                {
                    xml = XDocument.Load(xmlFilePath);
                    return true;
                }
                // add 2023-07-06 #8585 マルチスレッド start
            }
            // add 2023-07-06 #8585 マルチスレッド end
        }
        // add #7407 コンバートした施設で遠隔監視画面に過去の装置記録が表示されない 歴程 end

        /// <summary>
        /// 処理テーブル名を元に紐付きテーブルを取得しクラス変数に格納する
        /// </summary>
        /// <param name="fnwTableName">移行元のFNWテーブル名</param>
        /// <param name="ntssTableName">移行先の次世代FNテーブル名</param>
        /// <returns>true:成功 false:失敗</returns>
        public bool GetRelationTable(string ntssTableName)
        { 
            // 紐付けテーブル取得
             dtRelation = ConvertTss.Get(ntssTableName);
            if (dtRelation == null)
            {
                // 紐付けテーブルなし
                ConvertBase.WriteErrorLog(
                    "ntss_table_name=" + ntssTableName + "\r\n" +
                    " 紐付けテーブルが存在しません。");
                return false;
            }
            else if (dtRelation.Rows.Count == 0)
            {
                // 紐付けレコードなし
                ConvertBase.WriteErrorLog(
                    "ntss_table_name=" + ntssTableName + "\r\n" +
                    " 紐付けテーブルに紐付け情報が存在しません。");
                return false;
            }
            dtRelation.TableName = ntssTableName;
            return true;
        }

        
        /// <summary>
        /// 初期化処理
        /// </summary>
        /// <param name="convertTableName">コンバート先テーブル名</param>
        /// <remarks>
        /// コンバート処理クラスのインスタンス化を行う
        /// </remarks>
        /// <returns>成功：true、失敗：false</returns>
        public bool Init(DBCtrl db, string convertTableName)
        {
            var isSuccess = false;
            if (convType.Equals(CONV_TYPE.PAT_SPECIFY_PERIOD))
            {
                mapConvertData = new Dictionary<string, List<ConvertBase.NtssRecord>>();
                procConvert = CreateConvertInstance(convertTableName);
                isSuccess = procConvert.Init(db, facilityCd, convertTableName, sqlRootDirectory);
                if (isSuccess == false)
                {
                    return false;
                }

          

                isParent = mapParentChild.ContainsKey(convertTableName);
                if (isParent)
                {
                    // 親テーブルの場合は子テーブル用変数を初期化
                    procConvert.ChildPrimaryKey = new Dictionary<string, List<string>>();
                    mapConvertDataChild = new Dictionary<string, List<ConvertBase.NtssRecord>>();
                    procConvertChild = CreateConvertInstance(mapParentChild[convertTableName]);
                    isSuccess = procConvertChild.Init(db, facilityCd, mapParentChild[convertTableName], sqlRootDirectory);
                    if (isSuccess == false)
                    {
                        return false;
                    }

                }
            }
            else if (convType.Equals(CONV_TYPE.ALL_RECORD))
            {
                mapConvertData = new Dictionary<string, List<ConvertBase.NtssRecord>>();
                procConvert = CreateConvertInstance(convertTableName);
                isSuccess = procConvert.InitForMst(db, facilityCd, seriesCd, convertTableName, xml, dtRelation);
                if (isSuccess == false)
                {
                    return false;
                }
            }

            return true;
        }

        /// <summary>
        /// 初期化処理
        /// </summary>
        /// <param name="convertTableName">コンバート先テーブル名</param>
        /// <remarks>
        /// コンバート処理クラスのインスタンス化を行う
        /// </remarks>
        /// <returns>成功：true、失敗：false</returns>
        public bool Init(DBCtrl db, DgvPatRowDto dto)
        {
            var isSuccess = false;
            if (convType.Equals(CONV_TYPE.PAT_SPECIFY_PERIOD))
            {
                mapConvertData = new Dictionary<string, List<ConvertBase.NtssRecord>>();
                procConvert = CreateConvertInstance(dto.ntssTableName);
                isSuccess = procConvert.Init(db, facilityCd, dto.ntssTableName, sqlRootDirectory);
                if (isSuccess == false)
                {
                    return false;
                }

                isParent = mapParentChild.ContainsKey(dto.ntssTableName);
                if (isParent)
                {
                    // 親テーブルの場合は子テーブル用変数を初期化
                    procConvert.ChildPrimaryKey = new Dictionary<string, List<string>>();
                    mapConvertDataChild = new Dictionary<string, List<ConvertBase.NtssRecord>>();
                    procConvertChild = CreateConvertInstance(mapParentChild[dto.ntssTableName]);
                    isSuccess = procConvertChild.Init(db, facilityCd, mapParentChild[dto.ntssTableName], sqlRootDirectory);
                    if (isSuccess == false)
                    {
                        return false;
                    }
                }
            }
            // mod #7407 コンバートした施設で遠隔監視画面に過去の装置記録が表示されない 歴程 start
            //else if (convType.Equals(CONV_TYPE.ALL_RECORD)||convType.Equals(CONV_TYPE.SPECIFY_PERIOD))
            else if (convType.Equals(CONV_TYPE.ALL_RECORD) || convType.Equals(CONV_TYPE.SPECIFY_PERIOD) || convType.Equals(CONV_TYPE.MOTION))
            // mod #7407 コンバートした施設で遠隔監視画面に過去の装置記録が表示されない 歴程 end
            {
                mapConvertData = new Dictionary<string, List<ConvertBase.NtssRecord>>();
                procConvert = CreateConvertInstance(dto.ntssTableName);
                isSuccess = procConvert.InitForMst(db, facilityCd, seriesCd, dto, xml, dtRelation);
                if (isSuccess == false)
                {
                    return false;
                }
            }

            return true;
        }


        /// <summary>
        /// コンバート処理インスタンス作成
        /// </summary>
        /// <param name="convertTableName">コンバート先テーブル名</param>
        /// <returns>コンバート処理インスタンス</returns>
        /// <remarks>固有のインスタンス生成が必要なテーブルは現在ハードコーディング
        /// </remarks>
        private ConvertBase CreateConvertInstance(string convertTableName)
        {
            // テーブル名に合わせてインスタンス化
            ConvertBase obj = null;

            switch (convType)
            {
                case CONV_TYPE.ALL_RECORD:
                    obj = new ConvertMst();
                    break;

                case CONV_TYPE.PAT_SPECIFY_PERIOD:
                    switch (convertTableName)
                    {
                        case NTSS_TABLE_ORD_MAIN:
                            obj = new ConvertOrdMain();
                            break;
                        case NTSS_TABLE_MNI_MONITOR:
                            obj = new ConvertMniMonitor();
                            break;
                        case NTSS_TABLE_ORD_CHECKLIST:
                            obj = new ConvertOrdChecklist();
                            break;
                        case NTSS_TABLE_PAT_TREATMENT_PATTERN:
                            obj = new ConvertPatTreatmentPattern();
                            break;
                        case NTSS_TABLE_ORD_WEIGHT_SCALE:
                            obj = new ConvertOrdWeightScale();
                            break;
                        // add #8038 コンバート施設で一部の情報が表示されない 楊 start
                        case NTSS_TABLE_ORD_TREAT_CONDITION:
                            obj = new ConvertOrdTreatCondition();
                            break;
                        // add #8038 コンバート施設で一部の情報が表示されない 楊 start
                        default:
                            obj = new ConvertSpecifyPeriod();
                            break;
                    }
                    break;            
                // add #7407 コンバートした施設で遠隔監視画面に過去の装置記録が表示されない 歴程 start
                case CONV_TYPE.MOTION:
                    obj = new ConvertMotion();
                    break;
                // add #7407 コンバートした施設で遠隔監視画面に過去の装置記録が表示されない 歴程 end
            }
            return obj;
        }

        /// <summary>
        /// コンバート元データ取得
        /// </summary>
        /// <param name="listSelectedPatId">選択した患者IDリスト</param>
        /// <param name="mstCd">マスタコード(バッチ処理時：null、同期処理時：対象のマスタコード)</param>
        /// <param name="startDate">データ取得期間(開始)</param>
        /// <param name="endDate">データ取得期間(終了)</param>
        /// <param name="isSync">同期処理フラグ</param>
        /// <remarks>
        /// テーブルの種類に応じた元データ取得処理を実行する
        /// </remarks>
        /// <returns>成功：true、失敗：false</returns>
        public bool SetFnwData(List<string> listSelectedPatId, string mstCd, DateTime startDate, DateTime endDate, bool isSync)
        {
            var isSuccess = false;
            if (convType.Equals(CONV_TYPE.PAT_SPECIFY_PERIOD))
            {
                if (endDate == DateTime.MaxValue.Date)
                {
                    // 期間終了日に9999/12/31が指定された場合、後のAddDays(1)でエラーになるので1日引いておく
                    // (終了日未指定の指示で出てくるだけであり、そんな日付の予定は存在しないので問題ない)
                    endDate = DateTime.MaxValue.Date.AddDays(-1);
                }

                // 元データ取得
                isSuccess = procConvert.SetFnwData(listSelectedPatId, startDate, endDate, isSync);
                if (isSuccess && isParent)
                {
                    // 親テーブルの場合は子テーブルの元データを同時に取得
                    // 子テーブル主キーは親テーブルの元データ取得時に設定されている
                    procConvertChild.ChildPrimaryKey = procConvert.ChildPrimaryKey;
                    isSuccess = procConvertChild.SetFnwDataChild(sqlRootDirectory, isSync);
                }
                // add FNSI-空判断追加 楊 start
                if (isSuccess)
                {
                    // add FNSI-空判断追加 楊 end
                    // マスタ取得
                    isSuccess = procConvert.SetFnwMst();
                    if (isSuccess && isParent)
                    {
                        isSuccess = procConvertChild.SetFnwMst();
                    }
                    // add FNSI-空判断追加 楊 start
                }
                // add FNSI-空判断追加 楊 end
            }
            else if (convType.Equals(CONV_TYPE.ALL_RECORD))
            {
                //mod  7403  2022-05-31 鄭 start
                isSuccess = procConvert.SetFnwDataForMst("",mstCd, isSync);
                //mod  7403  2022-05-31 鄭 end
            }
            else if (convType.Equals(CONV_TYPE.SPECIFY_PERIOD))
            {
                isSuccess = procConvert.SetFnwData(listSelectedPatId, startDate, endDate, isSync);
            }

            return isSuccess;
        }

    
        /// <summary>
        /// 期間を指定してFNWのデータを取得する
        /// </summary>
        /// <param name="startDate">期間開始日</param>
        /// <param name="endDate">期間終了日</param>
        /// <param name="isSync">同期フラグ</param>
        /// <returns></returns>
        public bool SetFnwDataSprcifyPeriod(
            DateTime startDate,
            DateTime endDate,
            bool isSync)
        {
            // 元データ取得
            var isSuccess = procConvert.SetFnwDataSpecifyPeriod(startDate, endDate, isSync, "");
            return isSuccess;
        }
        //mod  7403  2022-05-31 鄭 start 
        
        public bool SetFnwDataFromXmlConfig(string url,string mstCd, bool isSync)
        {
            // 元データ取得
            var isSuccess = procConvert.SetFnwDataForMst(url,mstCd, isSync);
            return isSuccess;
        }
        //mod  7403  2022-05-31 鄭 end 

        // add #7407 コンバートした施設で遠隔監視画面に過去の装置記録が表示されない 歴程 start
        /// <summary>
        /// 期間を指定してFNWのデータを取得する
        /// </summary>
        /// <param name="url">アドレス</param>
        /// <param name="startDate">期間開始日</param>
        /// <param name="endDate">期間終了日</param>
        /// <param name="tableName">テーブル名</param>
        /// <returns>成功：true、失敗：false</returns>
        public bool SetFnwDataFromXmlConfigForMotion(string url, DateTime startDate, DateTime endDate, string tableName)
        {
            // 元データ取得
            var isSuccess = procConvert.SetFnwDataForMotion(url, startDate, endDate, tableName);
            return isSuccess;
        }
        // add #7407 コンバートした施設で遠隔監視画面に過去の装置記録が表示されない 歴程 end

        /// <summary>
        /// データコンバート処理
        /// </summary>
        /// <param name="listErrorPat">失敗した患者ID(戻り値)</param>
        /// <remarks>
        /// 指定した患者の全レコードに対しコンバート処理を行う
        /// </remarks>
        /// <returns>成功：true、失敗：false</returns>
        public bool Convert(List<string> listErrorPat)
        {
            var isSuccess = procConvert.Convert(mapConvertData, listErrorPat);
            if (isSuccess && isParent)
            {
                // 親テーブルの場合は子テーブルを同時にコンバート
                isSuccess = procConvertChild.Convert(mapConvertDataChild, listErrorPat);
            }

            return isSuccess;
        }



        /// <summary>
        /// NTSSのデータを元に出力形式に沿ったデータを出力する
        /// </summary>
        /// <param name="exportFolderPath"></param>
        /// <param name="encoding"></param>
        /// <param name="isInsertOnly"></param>
        /// <param name="isMakePatidFolder"></param>
        /// <returns></returns>
        public bool Export(string exportFolderPath,
                            Encoding encoding,
                            bool isInsertOnly,
                            bool isMakePatidFolder,
                            CommonConstants.OutputFormat outputFormat,
                            int chunkSize)
        {
            //8400
            // mod #9797 差分コンバートでFNW側の指示内容を変更してもFNSiの指示履歴に反映されない zs start
            //if (mapConvertData.Count == 0 && CommonConfig.isDiff)
            if (mapConvertData.Count == 0 && CommonConfig.isDiff && !exportFolderPath.Contains("indicatorShoe[diff]"))
            // mod #9797 差分コンバートでFNW側の指示内容を変更してもFNSiの指示履歴に反映されない zs end
            {
                return false;
            }
            //8400
            var isSuccess = procConvert.Export(mapConvertData, exportFolderPath, encoding, isInsertOnly, isMakePatidFolder, outputFormat, chunkSize);
            return isSuccess;
        }

      



        /// <summary>
        /// コンバート元データ数取得
        /// </summary>
        public int GetFnwDataRowCount()
        {
            return procConvert.FnwDataRowCount();
        }

        /// <summary>
        /// コンバートデータ総数取得
        /// </summary>
        public int GetConvertRecordCount()
        {
            return mapConvertData.Count;
        }
  

        /// <summary>
        /// FNWDB接続
        /// </summary>
        /// <param name="oraConnStr">Oracle接続文字列</param>
        /// <returns>成功：DBコントロール、失敗：null</returns>
        public static DBCtrl DBConnectFnw()
        {
            //add 12338 start
            string oraConnStr = CommonConfig.oraConnStr;
            //add 12388 end

            DBCtrl db = null;
            ConvertBase.WriteTraceLog("FNWDBに接続します。");
            // add FNSI-Oracle接続文字列追加 楊 start
            ConvertBase.WriteTraceLog(oraConnStr);
            // add FNSI-Oracle接続文字列追加 楊 end
            // Oracle接続
            DBCtrl.Init(oraConnStr);
            if (DBCommon.IsConnection(null))
            {
                ConvertBase.WriteTraceLog("FNWDB接続に成功しました。");
                db = new DBCtrl(null);
            }
            else
            {
                ConvertBase.WriteErrorLog("FNWDB接続に失敗しました。");
            }

            return db;
        }




        public static List<string> DiffPatidList(DateTime startDate,
            DateTime endDate, DBCtrl db)
        {
            ConvertOrdMain diffordmain =  new ConvertOrdMain();
            string syncConvertHistory = CommonConfig.dialysisPlanHistTblSql;

            string schDialysisPlanAddCond = "   exists(select * from " + syncConvertHistory + " ch where s.up_date > ch.CONVERT_DATETIME)";
            string rstDialysisAddCond = "   exists(select * from " + syncConvertHistory + " ch where  b.START_DATE >= to_char(ch.start_date,'yyyymmdd') and b.START_DATE <= ch.end_date + 1 and b.up_date > ch.CONVERT_DATETIME)";
            string rstDialysisDiffCond = " exists(select * from " + syncConvertHistory + " ch where RD.START_DATE >= to_char(ch.start_date,'yyyymmdd') and RD.START_DATE <= ch.end_date + 1 and b.up_date > ch.CONVERT_DATETIME)";
            string schDialysisPlanDeviceCond = "   exists(select * from " + syncConvertHistory + " ch where    b.REG_DATE > ch.CONVERT_DATETIME)";
            string rstDislysisPatLiftListCond = "  exists(select * from " + syncConvertHistory + " ch where to_date( p.reg_date || p.reg_time, 'YYYYMMDDHH24MISS' ) >= ch.start_date and to_date( p.reg_date || p.reg_time, 'YYYYMMDDHH24MISS' ) <= ch.end_date + 1 and p.up_date > ch.CONVERT_DATETIME)";
            string rstDialysisCond = "   exists(select * from " + syncConvertHistory + " ch where   b.UP_DATE > ch.CONVERT_DATETIME)";
            string ordCoopNoCond = "  exists( select * from " + syncConvertHistory + " ch where    a.START_DATE >= to_char(ch.start_date,'yyyymmdd')  AND   a.START_DATE<=  to_char(ch.end_date + 1,'yyyymmdd') and  EVENT_OCCUR_DATE > ch.CONVERT_DATETIME)";
            string patIndApproveCond = "  exists( select * from " + syncConvertHistory + " ch where  REG_DATE > ch.CONVERT_DATETIME and REG_DATE < ch.end_date + 1)";
            string ordTreatConditionCond = "  exists(select * from " + syncConvertHistory + " ch where nvl(RESEND_DATE, SEND_DATE) >= ch.start_date and nvl(RESEND_DATE, SEND_DATE) < ch.end_date + 1 and nvl(RESEND_DATE, SEND_DATE) > ch.CONVERT_DATETIME)";
            //add #10761 差分コンバートでFNWの治療項目マスタの内容が一部反映されない 孟堅　20240618 start　
            string mstSysTreatCond = "SELECT DISTINCT TREAT_ITEM_CD  FROM  SYS_TREAT_COND_SETTING STCS WHERE STCS.UP_DATE > TO_DATE('" + CommonConfig.MST_DIFF_DATETIME+ "', 'YYYY/MM/DD HH24:MI:SS')";
            //add #10761 差分コンバートでFNWの治療項目マスタの内容が一部反映されない 孟堅　20240618 end
            //mod #10761 差分コンバートでFNWの治療項目マスタの内容が一部反映されない 孟堅　20240618 start　
            //return diffordmain.GetPatIdList(startDate, endDate, rstDialysisDiffCond, rstDialysisAddCond, rstDislysisPatLiftListCond, schDialysisPlanDeviceCond, schDialysisPlanAddCond, db, rstDialysisCond, ordCoopNoCond, patIndApproveCond, ordTreatConditionCond);
            return diffordmain.GetPatIdList(startDate, endDate, rstDialysisDiffCond, rstDialysisAddCond, rstDislysisPatLiftListCond, schDialysisPlanDeviceCond, schDialysisPlanAddCond, db, rstDialysisCond, patIndApproveCond, ordTreatConditionCond, mstSysTreatCond);
            //mod #10761 差分コンバートでFNWの治療項目マスタの内容が一部反映されない 孟堅　20240618 end　
        }

        // add 10378-24-4 PatTreatmentPattern再構築対応 zkm start
        public static List<string> DiffPatTreatmentPatternPatidList(DBCtrl db)
        {
            ConvertPatTreatmentPattern diffConvert = new ConvertPatTreatmentPattern();

            string dialysisPlanAddTbl = CommonConfig.dialysisPlanHistTblSql;

            string schDialysisPlanAddCond = " exists(select * from " + dialysisPlanAddTbl + " ch where s.up_date > ch.CONVERT_DATETIME)";
            string schDialysisPlanDeviceCond = " exists(select * from " + dialysisPlanAddTbl + " ch where  b.REG_DATE > ch.CONVERT_DATETIME)";
            //mod #10761 差分コンバートでFNWの治療項目マスタの内容が一部反映されない 孟堅　20240618 start　
            string mstSysTreatCond = "SELECT DISTINCT TREAT_ITEM_CD  FROM  SYS_TREAT_COND_SETTING STCS WHERE STCS.UP_DATE > TO_DATE('" + CommonConfig.MST_DIFF_DATETIME + "', 'YYYY/MM/DD HH24:MI:SS')";
            return diffConvert.GetPatIdList(db, schDialysisPlanAddCond, schDialysisPlanDeviceCond, mstSysTreatCond);
            // mod #10761 差分コンバートでFNWの治療項目マスタの内容が一部反映されない 孟堅　20240618 end　
        }
        // add 10378-24-4 PatTreatmentPattern再構築対応 zkm end
    }
}
