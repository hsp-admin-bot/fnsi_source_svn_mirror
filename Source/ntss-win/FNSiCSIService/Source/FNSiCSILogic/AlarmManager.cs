using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Management;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;
using jp.co.nikkiso.fn3.Cooperation.StdLinkage.CoopCommonDefine;

namespace FNSiCSILogicLib
{
    /// <summary>
    /// アラーム通知管理クラス
    /// </summary>
    public class AlarmManager : MarshalByRefObject
    {
        #region "共通定義"
        /// <summary>
        /// メッセージ種別列挙体
        /// </summary>
        public enum CONFIRMINFO
        {
            NO = 0,
            YES,
            ALARM,
        }

        /// <summary>
        /// 初期設定-区分-共通
        /// </summary>
        private static readonly string NAME_INI_DATA_CATEGORY = "0";

        /// <summary>
        /// 初期設定-セクション-アラーム
        /// </summary>
        private static readonly string NAME_INI_DATA_SECTION = "ALARM";

        /// <summary>
        /// 初期設定-キー-アラーム出力
        /// </summary>
        private static readonly string NAME_INI_DATA_ONOFF = "OUTPUT";

        /// <summary>
        /// 初期設定-キー-送信IP
        /// </summary>
        private static readonly string NAME_INI_DATA_SENDIP = "SENDIP";

        /// <summary>
        /// 初期設定-キー-エンドポイント
        /// </summary>
        private static readonly string NAME_INI_DATA_ENDPOINT = "ENDPOINT";

        /// <summary>
        /// 初期設定-キー-ローカルエンドポイント
        /// </summary>
        private static readonly string NAME_INI_DATA_LOCALENDPOINT = "LOCALENDPOINT";

        /// <summary>
        /// SendAlarmManagerクラスの唯一のインスタンス
        /// </summary>
        private static AlarmManager m_instance;

        /// <summary>
        /// マルチキャストメッセージ送信IP
        /// </summary>
        private string multicastIP = "224.0.1.1";   //初期設定から取得/既定値

        /// <summary>
        /// マルチキャストメッセージ送信ポート番号
        /// </summary>
        private int multicastPortNum = 9051;    //初期設定から取得/既定値
        private int multicastPortNumLocal   = 9050; //初期設定から取得/既定値


        /// <summary>
        /// 送信可否設定/初期設定より
        /// </summary>
        private bool SendFlg = true;

        /// <summary>
        /// 送信可否設定/送信する
        /// </summary>
        private static readonly string SEND_FLG = "1";

        /// <summary>
        /// 送信可否設定/送信しない
        /// </summary>
        private static readonly string SEND_FLG_NO = "0";

        //自PCのローカルIPアドレス
        private static string m_LocalIPAddress = string.Empty;

        private static ArrayList m_sendList;

        //ブロードキャスト比較文字列
        private static string BroadCastAddr = "255";

        /// <summary>系列施設運用モード</summary>
        private SeriesPracticeModeType m_SeriesPracticeMode;

        /// <summary>系列施設コード</summary>
        private string m_LocalSeriesCode;

        /// <summary>系列施設運用モード</summary>
        public SeriesPracticeModeType SeriesPracticeMode
        {
            set { m_SeriesPracticeMode = value; }
        }

        /// <summary>系列施設コード</summary>
        public string LocalSeriesCode
        {
            set { m_LocalSeriesCode = value; }
        }

        /// <summary>系列施設対応フラグ</summary>
        public bool IsSeriesSupported
        {
            get
            {
                if (m_SeriesPracticeMode == SeriesPracticeModeType.NOTSUPPORTED)
                {
                    return false;
                }
                else
                {
                    return true;
                }
            }
        }

        /// <summary>連携初期設定情報の処理対象とする系列施設コード(カルテが稼動している系列施設コード)</summary>
        private string m_TargetSeriesCode;

        /// <summary>連携初期設定情報の処理対象とする系列施設コード(カルテが稼動している系列施設コード)</summary>
        public string TargetSeriesCode
        {
            set { m_TargetSeriesCode = value; }
            get { return m_TargetSeriesCode; }
        }
        #endregion

        #region "初期設定用デリゲート"
        /// <summary>
        /// 初期設定取得用デリゲート

        /// </summary>
        /// <param name="Category">初期設定[区分]</param>
        /// <param name="Session">初期設定[セクション]</param>
        /// <param name="Key">初期設定[キー]</param>
        /// <param name="ValueTable">取得内容</param>
        public delegate ResultCode dgtGetInitialData(string Category, string Session, string Key, ref Hashtable ValueTable);
        private dgtGetInitialData m_dgtGetInitialData = null;

        public dgtGetInitialData setdgtGetInitialData
        {
            set
            {
                this.m_dgtGetInitialData = value;
            }
        }
        #endregion

        #region "ログ出力デリゲート"
        /// <summary>
        /// ログ用デリゲート

        /// </summary>
        /// <param name="Category">初期設定[区分]</param>
        /// <param name="Session">初期設定[セクション]</param>
        /// <param name="Key">初期設定[キー]</param>
        /// <param name="ValueTable">取得内容</param>
        public delegate void dgtOutLog(CoopLogLevel LogLevel,string ErrorCode,LogParameter parameter);
        private dgtOutLog m_dgtOutLog = null;

        public dgtOutLog setdgtOutLog
        {
            set
            {
                this.m_dgtOutLog = value;
            }
        }
        #endregion

        #region "コンストラクタ"
        /// <summary>
        /// コンストラクタ
        /// </summary>
        private AlarmManager()
        {
        }
        #endregion

        #region "パブリックメソッド"
        /// <summary>
        /// SendAlarmManagerクラスの唯一のインスタンスを取得する

        /// </summary>
        public static AlarmManager GetInstance()
        {
            if (m_instance == null)
            {
                m_instance = new AlarmManager();
            }
            return m_instance;
        }
        

        /// <summary>
        /// 初期化処理

        /// </summary>
        public bool Initialize()
        {
            bool result = true;
            Hashtable ValueTable = new Hashtable();
            string MultiCastIp = string.Empty;

            //入出力設定の取得
            try
            {
                //this.m_dgtGetInitialData(NAME_INI_DATA_CATEGORY, NAME_INI_DATA_SECTION, NAME_INI_DATA_ONOFF, ref ValueTable);

                //if (ValueTable.Count > 0)
                //{
                //    if (ValueTable[NAME_INI_DATA_ONOFF].ToString() == SEND_FLG || ValueTable[NAME_INI_DATA_ONOFF].ToString() == SEND_FLG_NO)
                //    {
                //        switch (ValueTable[NAME_INI_DATA_ONOFF].ToString())
                //        {
                //            case "0":
                //                SendFlg = false;
                //                break;
                //            case "1":
                //                SendFlg = true;
                //                break;
                //            default:
                //                result = false;
                //                break;

                //        }
                //    }
                //    else
                //    {
                //        result = false;
                //    }

                //}
                //ValueTable.Clear();

                ////IPの取得

                //this.m_dgtGetInitialData(NAME_INI_DATA_CATEGORY, NAME_INI_DATA_SECTION, NAME_INI_DATA_SENDIP, ref ValueTable);

                //if (ValueTable.Count > 0 && result == true)
                //{
                //    MultiCastIp = ValueTable[NAME_INI_DATA_SENDIP].ToString();
                //}
                //else
                //{
                //    result = false;
                //}
                //ValueTable.Clear();
                
                //LogParameter logParatest = new LogParameter();
                //logParatest.SetProcessID(m_TargetSeriesCode, "00000", "0");
                //logParatest.TraceFlg = true;
                //logParatest.TraceMsg = "アラーム-IP:" + MultiCastIp;
                //m_dgtOutLog(CoopLogLevel.DEBUG, string.Empty, logParatest);

                

                ////エンドポイントの取得

                //this.m_dgtGetInitialData(NAME_INI_DATA_CATEGORY, NAME_INI_DATA_SECTION, NAME_INI_DATA_ENDPOINT, ref ValueTable);
                //if (ValueTable.Count > 0 && result == true)
                //{
                //    EndP = int.Parse(ValueTable[NAME_INI_DATA_ENDPOINT].ToString());
                //}
                //else
                //{
                //    result = false;
                //}
                //ValueTable.Clear();

                //logParatest.TraceMsg = "アラーム-EndPoint:" + EndP;
                //m_dgtOutLog(CoopLogLevel.DEBUG, string.Empty, logParatest);

                ////ローカルエンドポイントの取得

                //this.m_dgtGetInitialData(NAME_INI_DATA_CATEGORY, NAME_INI_DATA_SECTION, NAME_INI_DATA_LOCALENDPOINT, ref ValueTable);
                //if (ValueTable.Count > 0 && result == true)
                //{
                //    LEndP = int.Parse(ValueTable[NAME_INI_DATA_LOCALENDPOINT].ToString());
                //}
                //else
                //{
                //    result = false;
                //}
                //ValueTable.Clear();

                //logParatest.TraceMsg = "アラームLEndPoint:" + LEndP;
                //m_dgtOutLog(CoopLogLevel.DEBUG, string.Empty, logParatest);

                //if (result == true)
                //{
                //    multicastIP = MultiCastIp;
                //    multicastPortNum = EndP;
                //    multicastPortNumLocal = LEndP;
                //}


                //logParatest.TraceMsg = "アラーム-自IP取得:" + m_LocalIPAddress;
                //m_dgtOutLog(CoopLogLevel.DEBUG, string.Empty, logParatest);

                //////ブロードキャスト設定
                ////server2 = new UdpClient(multicastPortNumLocal);
                //logParatest.TraceMsg = "アラーム-ブロードキャスト";
                //m_dgtOutLog(CoopLogLevel.DEBUG, string.Empty, logParatest);

                //LogParameter logPara = new LogParameter();
                //logPara.SetProcessID(m_TargetSeriesCode, "00000", "0");
            }
            catch (Exception ex)
            {
                LogParameter parameter = new LogParameter();
                parameter.SetProcessID(m_TargetSeriesCode, "00000", "0");
                parameter.ErrorFlg = true;
                parameter.ErrorMsg = "アラームの初期化に失敗しました" + ex.Message;
                m_dgtOutLog(CoopLogLevel.ERROR, "0500000000", parameter);
                result = false;
            }
            return result;
        }

        /// <summary>
        /// メッセージ送信メソッドを別スレッドで実行する

        /// </summary>
        /// <param name="NotifyType">お知らせ種別</param>
        /// <param name="OutputParameter">出力パラメタ群</param>
        public void SendMessage(string NotifyType, string OutputParameter)
        {
            //LogParameter parameter = new LogParameter();
            //parameter.SetProcessID(m_TargetSeriesCode, "00000", "0");
            //parameter.Initialize();
            //parameter.TraceFlg = true;
            //parameter.TraceMsg = "[標準連携-アラーム発生]" + OutputParameter;
            //string msg = string.Empty;
            //msg = NotifyType + "," + CONFIRMINFO.NO.GetHashCode().ToString() + "," + OutputParameter; //確認無しメッセージ

            //this.m_dgtOutLog(CoopLogLevel.METHOD, "0", parameter);
        }
        #endregion

        #region "プライベートメソッド"
        #endregion

    }
}
