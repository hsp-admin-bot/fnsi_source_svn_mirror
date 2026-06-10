using System;
using System.Collections.Generic;
using System.IO;
using ConvertCommon.dto;
using System.Xml.Serialization;
using System.Collections.Concurrent;

namespace ConvertCommon.Common
{
 /// <summary>
 /// 設定ファイルなど永続化された情報を保持するクラス
 /// ここに格納される基準は一度設定されたら変更されない情報とする。
 /// ※変更される可能性のあるステータスなどといった情報は保持しない。
 /// </summary>
    public class CommonConfig
    {
        /// <summary>
        /// ConvertInfo.Xmlをデシリアライズし格納するクラス
        /// </summary>
        public static ConfigInfoDto configInfoDto { get; private set; }

        /// <summary>
        /// 更新日時
        /// </summary>
        public static DateTime UpDate;

        /// <summary>
        /// PostgreSQLのTimestamp型登録用に変換した文字列を返す
        /// </summary>
        /// <returns></returns>
        public string getTimestamp()
        {

            return "";
        }

        /// <summary>
        /// スタティックコンストラクタ
        /// </summary>
        static CommonConfig()
        {
            setConvertInfo();
        }
        //add 7997 start
        public class PatProcInfo
        {
            public string PatId { get; set; }
            public string ProcDate { get; set; }
            public string isFirst { get; set; }
        }
        //add 7997 end
        /// <summary>
        /// ConvertInfo.xmlを設定
        /// </summary>
        private static void setConvertInfo()
        {
            // add 2023-07-06 #8585 マルチスレッド start
            lock (FileLock.config)
            {
                // add 2023-07-06 #8585 マルチスレッド end
                if (false == File.Exists(@".\SQL\config\ConvertInfo.xml"))
                {
                    ConvertBase.WriteErrorLog("ConvertInfo.xmlの取得に失敗しました。");
                    return;
                }

                using (System.IO.FileStream fs = new System.IO.FileStream(@".\SQL\config\ConvertInfo.xml", System.IO.FileMode.Open))
                {
                    //System.Xml.Serialization.XmlSerializer serializer = new System.Xml.Serialization.XmlSerializer(typeof(ConfigInfoDto));
                    XmlSerializer serializer = XmlSerializer.FromTypes(new[] { typeof(ConfigInfoDto) })[0];
                    configInfoDto = (ConfigInfoDto)serializer.Deserialize(fs);
                }
                // add 2023-07-06 #8585 マルチスレッド start
            }
            // add 2023-07-06 #8585 マルチスレッド end
        }

        /// 透析条件設定
        public static Dictionary<string, List<string>> Boold { get; set; } = new Dictionary<string, List<string>>();
        public static Dictionary<string, List<string>> p_A { get; set; } = new Dictionary<string, List<string>>();
        public static Dictionary<string, List<string>> p_V { get; set; } = new Dictionary<string, List<string>>();
        public static Dictionary<string, List<string>> p_SN { get; set; } = new Dictionary<string, List<string>>();

        // コンバート履歴に存在する指示・実績データを除外するフラグ
        // （ord_main,mni_monitorに対応）
        public static Boolean isExclusion;

        // 画面で入力された系列施設コード
        public static string seriesCd;

        // add FNSI-差分コンバート対応 楊 start
        // 差分コンバート
        public static bool isDiff;
        // add FNSI-差分コンバート対応 楊 end
        // add 9778
        public static List<string> Mst_select;
        // add 9778

        // add 9862
        public static List<string> Mst_DEL;
        // add 9862

        // add 9815
        public static long  allLen;
        public static long schLen;
        //Add #7997 進捗バー 修正　start
        public static Dictionary<string, bool> CONVEND= new Dictionary<string, bool>();
        //Add #7997 進捗バー 修正　end
        // add 9815
        public static string DiffUser;

        public static string dialysisPlanHistTblSql;
        //add #10761 差分コンバートでFNWの治療項目マスタの内容が一部反映されない 孟堅　20240618 start　
        public static string MST_DIFF_DATETIME;
        public static DateTime appStartTime;
        //add #10761 差分コンバートでFNWの治療項目マスタの内容が一部反映されない 孟堅　20240618 end　
        public static string token;
        // add #7997  start
        public static Dictionary<string, string> HashValueSet = new Dictionary<string, string>();
        public static Dictionary<string, string> SelectedTypeByFacility = new Dictionary<string, string>();
        public static HashSet<string> dtSeriesCdAndFacilityCdSet= new HashSet<string>();
        public static string HashValue;
        public static string FacilityCd;
        public static string NoWITHIndTimePeriod;
        public static string LoginUrl;
        public static List<PatProcInfo> patProcInfoList = new List<PatProcInfo>();

        // add #9132 コンバート処理中にDBが高負荷となり停止 zkm start
        public const int MotionRecordFileSize = 10000;
        // add #9132 コンバート処理中にDBが高負荷となり停止 zkm end

        // add #10835 体重計測定記録の一部がFNWからコンバートされていない zkm start
        public static string WeightScaleNoPatConvertMark = "";
        // add #10835 体重計測定記録の一部がFNWからコンバートされていない zkm end

        // add #11161 出力完了後アップロードと送信を自動実行(1自動実行) zc start
        public static string AUTOMATIC;
        public static bool RUN;
        // add #11161 出力完了後アップロードと送信を自動実行(1自動実行) zc end

        // add #11383  
        public static bool diffPatMainAll =false;
        public static bool diffPatMainMongo = false;
        public static bool diffPatPersonalMainAll = false;
        public static bool diffPatPersonalMainMongo = false;
        // add #11383

        // add #10859_9
        public static string Ord_Addition="1";
        // add #10859_9

        // add #10739
        public static string ordListIndId;
        public static string ordListRst;
        // add #10739

        //add 11753 start
        public static string examinPatid;
        public static string dialysisPatidTblSql;
        //add 11753 end

        //add 12338 start
        public static string oraConnStr;
        public static string ZipFilePassword;
        public static string uploadServPathValue;
        public static string DefaultExportFolderPathLen;
        public static string ConvertRestWebServerIp;
        public static string ConvertRestWebServerPort;
        public static string LoadBalancing;
        //add 12338 end

        //add #12229 start
        public static List<string> targetYmList;
        //add #12229 end

        public static ConcurrentDictionary<string, SqlBatchFileWriter> writerMapType = new ConcurrentDictionary<string, SqlBatchFileWriter>();

        //add  #10840 COP_EVENT_MANAGEの最新連携種別を取得する start
        public static Dictionary<string, bool> HashCoopSet = new Dictionary<string, bool>();
        //add  #10840 COP_EVENT_MANAGEの最新連携種別を取得する end

        //add  #11576 pat_coop_detailのsave_1がGX固定でコンバートされる start
        public static Dictionary<string, bool> HashCoopSetSave_1 = new Dictionary<string, bool>();
        //add  #11576 pat_coop_detailのsave_1がGX固定でコンバートされる end
    }
}
