//----------------------------------------------------------------------------------------------------
//  NKKScaleBedクラス定義
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
using ComScaleBed;

using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

//  名前空間:NKKCommon
//----------------------------------------------------------------------------------------------------
using NKKCommon;
//----------------------------------------------------------------------------------------------------
//  名前空間:NKKLoggingLib
//----------------------------------------------------------------------------------------------------
using NKKLoggingLib;
//----------------------------------------------------------------------------------------------------
//  名前空間:NKKWebAccessLib
//----------------------------------------------------------------------------------------------------
using NKKWebAccessLib;
//----------------------------------------------------------------------------------------------------
//  名前空間:NKKWebSocketLib
//----------------------------------------------------------------------------------------------------
using NKKWebSocketLib;

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Reflection;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Web.Script.Serialization;
//----------------------------------------------------------------------------------------------------
//  名前空間:TdcLib
//----------------------------------------------------------------------------------------------------
using TdcLib;
//----------------------------------------------------------------------------------------------------
//  名前空間:TdcSocketLib
//----------------------------------------------------------------------------------------------------
using TdcSocketLib;
//----------------------------------------------------------------------------------------------------
//  名前空間:TdcVersionInfoLib
//----------------------------------------------------------------------------------------------------
using TdcVersionInfoLib;
//----------------------------------------------------------------------------------------------------


//----------------------------------------------------------------------------------------------------
//  名前空間:NKKScaleBedLib
//----------------------------------------------------------------------------------------------------
namespace NKKScaleBedLib
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// NKKScaleBed
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public class NKKScaleBed
    {

#region プライベート定義

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サービス名称
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String SERVICE_NAME = System.Reflection.Assembly.GetExecutingAssembly().GetName().Name;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ログファイル識別子
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        // #11987 2025.12.02 mod 体重計からスケールベッドに変更 TDC石井 start
        //private readonly String LOG_FILE_EXT = "Weight";
        private readonly String LOG_FILE_EXT = "ScaleBed";
        // #11987 2025.12.02 mod 体重計からスケールベッドに変更 TDC石井 end
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 設定ファイル名
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String CONFIG_FILE_NAME = "NKKScaleBed.config";
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 設定ファイル内共通設定セッション識別子
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String CONFIG_COMMON_SECTION = "Settings\\Common";
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 設定ファイル内WebSocket設定セッション識別子
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String CONFIG_WEBSOCKET_SECTION = "Settings\\WebSocket";
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 設定ファイル内ログ設定セッション識別子
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String CONFIG_LOG_SECTION = "Settings\\Log";
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 設定ファイル内GUI設定セッション識別子
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String CONFIG_GUI_SECTION = "Settings\\Tool";
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 設定ファイル内体重計設定セッション識別子
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String CONFIG_SCALEBED_SECTION = "Settings\\ScaleBed";
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 体重計設定取得URI
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public readonly String GET_CONFIG_URI = "/api/weight_setting/weight/get2/";
        //----------------------------------------------------------------------------------------------------
        // #11987 2026.2.12 add 施設マスタの設定取得 TDC石井 start
        /// <summary>
        /// 施設マスタ設定取得URI
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String GET_FACILITY_INFO_URI = "/api/facilities/getFacilityInfoByCd/";
        // #11987 2026.2.12 add 施設マスタの設定取得 TDC石井 end
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// レシート印刷情報取得URI
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String GET_PRINT_CONTENT_URI = "/api/weight_state/print_content/";
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// レシート印刷状態通知URI
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String PUT_PRINT_STATUS_URI = "/api/weight_state/print_status";
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 測定値通知URI
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String PUT_SCALEBED_VALUE_URI = "/api/scale_bed_state/scale_value";
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 接続状況通知URI
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String PUT_SCALEBED_CONNECT_URI = "/api/scale_bed_state/scale_bed_connect";
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 接続状況初期化URI
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String PUT_SCALEBED_CONNECT_RESET_URI = "/api/scale_bed_state/scale_bed_connect_reset";

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 直前で発生したエラーオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private Exception m_Exception = null;

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// システム設定：sys_system_defineテーブルの「スケールベッドアプリケーション最新バージョン」レコードを指すCTL_NO
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly int GET_SYSTEM_DEFINE_VERSION_NO = 40;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// アップデーターオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private Updater m_Updater = new Updater();
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// アップデート実施時刻
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private String m_strCheckUpdateTime = "02:00";
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// アップデート実施日時
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private DateTime m_dtCheckUpdate = DateTime.Now;
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ログアップローダーオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private NKKLogUploader m_LogUploader = new NKKLogUploader();
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ログアップロード実施間隔
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private String m_strLogUploadCycle = "01:00";
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ログアップロード実施日時
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private DateTime m_dtLogUpload = DateTime.Now;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ログ保持日数[既定：20日] 
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly int m_nLogFileKeepNumberDays = 20;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 外部GUI用ソケット待受IPアドレス制限
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String m_strGUIIPAddressOnly = String.Empty;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 外部GUI用ソケット待受ポート番号
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly int m_nGUISocketPortNo = 0;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 外部GUI用Socketサーバーソケットクラスオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly TdcBaseSocketServer m_GUISocketServer = new TdcBaseSocketServer();
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 外部GUI用情報保持オブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly Dictionary<String, String> m_GUIInformation = new Dictionary<String, String>();
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 不要ログ削除実施日付
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private DateTime dtDeleteDate = DateTime.Now.Date;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// スレッド終了用シグナル
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly System.Threading.ManualResetEvent m_evFinish = new ManualResetEvent(false);
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// スレッドオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly Thread m_Thread = null;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// WebSocketオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly NKKWebSocket m_WebSocket = new NKKWebSocket("WSCALE");
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// レシートプリンタクラスオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly NKKPrinter m_Printer = new NKKPrinter();
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// スケールベッド通信用クラスオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private ComScaleBedConnection m_csbc = new ComScaleBedConnection();
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// メインスレッドにおけるループ処理で初回処理を実施済みかどうか
        /// (0:実施済でループ処理を実施中の状態, 1:アプリ起動後に初回処理を完全未実施の状態,
        ///  2:アプリ起動中の設定変更などで再度の初回処理が必要になった状態, 3:施設設定が機能OFF等でアプリを動作させたくないので初期化処理実施済としている状態)
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private int m_bFirstFlag = 1;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// スケールベッドとの通信を担うクラスに渡す各スケールベッド毎の通信パラメータのリスト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        List<ComScaleBedConnectionParam> m_paramList = new List<ComScaleBedConnectionParam>();

        #endregion

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 外部GUI用ソケット待受ポート番号を取得する
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public int GetGUISocketPortNo()
        {
            return m_nGUISocketPortNo;
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// コンストラクタ
        /// <param name="strFolder">設定ファイル格納先フォルダ名</param>
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public NKKScaleBed( String strFolder )
        {
            try
            {
                // 起動時のdll一覧としてログに記載するdllを事前読み込み
                AppDomain.CurrentDomain.Load("Ionic.Zip");
                AppDomain.CurrentDomain.Load("VBBarCode4.BarCode.4");


                // 設定ファイル名作成
                String strfile = strFolder;
                if (strfile.EndsWith("\\") == false)
                {
                    strfile += "\\";
                }
                strfile += this.CONFIG_FILE_NAME;

                // システム共通設定クラス初期化
                SystemSettingInfo sys = SystemSettingInfo.GetInstance();
                if (sys.Load(strfile) == false)
                {
                    // 設定読み込み失敗

                    throw (new Exception(String.Format("Config,{0}", SystemSettingInfo.GetInstance().Error.ToString())));
                }

                // ログ設定
                NKKLogging log = NKKLogging.GetInstance();
                //  バージョン情報記録用処理登録(ログが変わった場合にログの先頭に記録するため)
                log.FirstWriteEvent = VersionInfos.GetVersionInfo;
                //  識別子
                log.LogExt = this.LOG_FILE_EXT+"_"+System.Net.Dns.GetHostName()+ String.Format("_{0}", sys.GetSingleLineValue(CONFIG_SCALEBED_SECTION, "WeightNo", "1").Trim());

                // ログ格納先フォルダ
                log.LogFolder = sys.GetSingleLineValue(CONFIG_LOG_SECTION, "Folder", String.Empty).Trim();
                // ログ保持日数[既定：20日]
                if (Int32.TryParse(sys.GetSingleLineValue(CONFIG_LOG_SECTION, "KeepNumberOfDays", String.Empty).Trim(), out int nwork) && 0 <= nwork)
                {
                    // ログ保持日数
                    this.m_nLogFileKeepNumberDays = nwork;
                }

                // ログ記録：初期化処理開始
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "初期化処理開始");


                // サーバー設定
                NKKWebAccess.ClientCertificateSearchValue1 = sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "ClientCertificateSearchValue1", String.Empty).Trim();
                NKKWebAccess.ClientCertificateSearchValue2 = sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "ClientCertificateSearchValue2", String.Empty).Trim();
                NKKWebAccess.UserId = sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "UserId", String.Empty).Trim();
                NKKWebAccess.Password = sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "UserPW", String.Empty).Trim();
                NKKWebAccess.UrlEncodeFacilityHash = sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "FacilityHash", String.Empty).Trim();
                NKKWebAccess.BaseUri = sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "BaseUri", String.Empty).Trim(' ', '/');
                // 最新ファイルダウンロード先フォルダ
                //NKKScaleBedInformation.DownloadSourceFolder = sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "DownloadFolder", String.Empty).Trim();

                // 最新ファイル取得先ファイル名
                //NKKScaleBedInformation.DownloadFileName = sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "DownloadFileName", "NKKScaleBed.zip").Trim();

                // 体重計番号
                NKKScaleBedInformation.WeightNo = sys.GetSingleLineValue(CONFIG_SCALEBED_SECTION, "WeightNo", "1").Trim();
                log.DeviceNo = NKKScaleBedInformation.WeightNo;
                // ログ記録：体重計番号
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("体重計番号:{0}", NKKScaleBedInformation.WeightNo));
                // アップデート実施日時
                this.m_strCheckUpdateTime = sys.GetSingleLineValue(CONFIG_SCALEBED_SECTION, "UpdateTime", this.m_strCheckUpdateTime).Trim();
                if( this.UpdateDateTime == DateTime.MaxValue)
                {
                    // ログ記録：設定無効
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "設定されているアップデート時刻が無効, 設定値：" + this.m_strCheckUpdateTime);
                }
                // ログアップロード実施日時
                this.m_strLogUploadCycle = sys.GetSingleLineValue(CONFIG_SCALEBED_SECTION, "LogUploadTime", this.m_strLogUploadCycle).Trim();
                if (this.LogUploadDateTime == DateTime.MaxValue)
                {
                    // ログ記録：設定無効
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "設定されているログアップロード時刻が無効, 設定値：" + this.m_strLogUploadCycle);
                }

                // WebSocket
                // 識別子番号(体重系番号)
                this.m_WebSocket.IdentityNo = NKKScaleBedInformation.WeightNo;
                // URI
                this.m_WebSocket.Uri = sys.GetSingleLineValue(CONFIG_WEBSOCKET_SECTION, "URI", String.Empty).Trim();
                // KeepAlive間隔
                if (UInt32.TryParse(sys.GetSingleLineValue(CONFIG_WEBSOCKET_SECTION, "KeepAlive", String.Empty).Trim(), out uint keepalive) && 0 < keepalive)
                {
                    this.m_WebSocket.KeepAlive = keepalive;
                }

                // GUI用待受IPアドレス制限
                this.m_strGUIIPAddressOnly = sys.GetSingleLineValue(CONFIG_GUI_SECTION, "IPAddress", String.Empty).Trim();
                // GUI用待受ポート番号
                if (Int32.TryParse(sys.GetSingleLineValue(CONFIG_GUI_SECTION, "PortNo", String.Empty).Trim(), out nwork) && 0 < nwork)
                {
                    this.m_nGUISocketPortNo = nwork;
                }
                // クライアント接続時
                this.m_GUISocketServer.ClientConnectedHandler = this.ClientConnected;


                // GUI通知用関数登録
                this.m_WebSocket.SendMessageToGUIHandler = this.SendLogMessageToGUI;
                // 受信用関数登録
                this.m_WebSocket.ReceiveMessage = this.WebSocketReceiveMessage;

                // GUI通知用関数登録
                NKKWebAccess.SendMessageHandler = this.SendLogMessageToGUI; 

                // GUI通知関数登録
                this.m_Printer.SendMessageToGUIHandler = this.SendLogMessageToGUI;


                // アップデーターオブジェクト初期化
                // ログ記録
                this.m_Updater.LoggingMethod = this.AddLogInfoUpdate;
                // プロセス種類
                this.m_Updater.ProcType = 0;
                // システム設定項目番号
                this.m_Updater.SystemDefineVersionNo = GET_SYSTEM_DEFINE_VERSION_NO;
                //// バケット名(ダウンロード先フォルダ)
                //this.m_Updater.Bucket = NKKScaleBedInformation.DownloadSourceFolder;
                //// ダウンロードファイル名
                //this.m_Updater.DownloadFileName = NKKScaleBedInformation.DownloadFileName;
                //// ダウンロードファイルのパスワード
                //this.m_Updater.Bucket = NKKScaleBedInformation.DownloadSourceFolder;
                // ダウンロードファイルのパスワード
                this.m_Updater.DownloadFilePassword = NKKScaleBedInformation.DownloadFilePassword;


                // スレッド構築
                this.m_Thread = new Thread(this.DoWork)
                {
                    Name = "NKKScaleBed処理スレッド",
                    IsBackground = false
                };

                // ログ記録：初期化処理終了
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "初期化処理終了");
            }
            catch ( Exception ex )
            {
                // ログ設定
                NKKLogging log = NKKLogging.GetInstance();
                //  バージョン情報記録用処理登録(ログが変わった場合にログの先頭に記録するため)
                log.FirstWriteEvent = VersionInfos.GetVersionInfo;
                //  識別子
                log.LogExt = this.LOG_FILE_EXT + "_" + System.Net.Dns.GetHostName();
                // ログ記録：エラー
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("初期化処理,{0}", ex.Message));
            }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// デストラクタ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        ~NKKScaleBed()
        {
            if( this.m_Thread != null )
            {
                // スレッド停止
                this.m_evFinish.Set();
            }
        }
        //----------------------------------------------------------------------------------------------------


#region パブリックプロパティ

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 直前に発生したエラーオブジェクト取得/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public Exception Error
        {
            get { return (this.m_Exception); }
            set
            {
                m_Exception = value;

                if (value != null)
                {
                    // 履歴作成
                    DateTime dtlog = DateTime.Now;
                    String strlogdata = String.Format("{0}, {1}", this.GetType().Name, value.ToString().Replace("\r\n", "{CRLF}"));

                    // 履歴に追記
                    this.AddLogInfo(dtlog, NKKLogging.LOGGING_CLASS.ERROR, strlogdata);
#if DEBUG
                    Debug.WriteLine(this.SERVICE_NAME + " " + strlogdata);
#endif
                }
            }
        }
        //----------------------------------------------------------------------------------------------------

        ////----------------------------------------------------------------------------------------------------
        ///// <summary>
        ///// デバッグモード参照用プロパティ
        ///// </summary>
        ////----------------------------------------------------------------------------------------------------
        //public int DebugMode
        //{
        //    get 
        //    {
        //        // 各サービスの一番大きなデバッグモードを返す
        //        int nmode = 0;

        //        // DBReq
        //        if (nmode < this.m_DBReqWSServer.DebugMode)
        //        {
        //            nmode = this.m_DBReqWSServer.DebugMode;
        //        }

        //        return (nmode); 
        //    }
        //    set {}
        //}
        ////----------------------------------------------------------------------------------------------------
        /// <summary>
        /// アップデート実施日時参照用プロパティ
        /// </summary>
        ////----------------------------------------------------------------------------------------------------
        public DateTime UpdateDateTime
        {
            get
            {
                DateTime ret = DateTime.MaxValue;
                try
                {

                    String strwork = DateTime.Now.Date.ToString("yyyy/MM/dd ") + this.m_strCheckUpdateTime;
                    ret = DateTime.ParseExact(
                        strwork,
                        "yyyy/MM/dd HH:mm",
                        System.Globalization.DateTimeFormatInfo.InvariantInfo,
                        System.Globalization.DateTimeStyles.None );
                } catch ( Exception ex )
                {
                }
                return ret;
            }
        }
        ////----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ログ保持日数参照用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public int LogFileKeepNumberDays
        {
            get { return (this.m_nLogFileKeepNumberDays); }
        }
        ////----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ログアップロード実施日時参照用プロパティ
        /// </summary>
        ////----------------------------------------------------------------------------------------------------
        public DateTime LogUploadDateTime
        {
            get
            {
                DateTime ret = DateTime.MaxValue;
                try
                {
                    // 実施時刻(起動/前回実施日時 + 設定時間)
                    ret = this.m_dtLogUpload
                        + DateTime.ParseExact(
                            this.m_strLogUploadCycle,
                            "HH:mm",
                            System.Globalization.DateTimeFormatInfo.InvariantInfo,
                            System.Globalization.DateTimeStyles.None).TimeOfDay;
                }
                catch (Exception ex)
                {
                }
                //Debug.Print("次回ログアップロード日時:" + ret.ToString("yyyy/MM/dd HH:mm"));
                return ret;
            }
        }
        //----------------------------------------------------------------------------------------------------

#endregion

        #region パブリックメソッド

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 初期化処理
        /// </summary>
        /// <returns></returns>
        //----------------------------------------------------------------------------------------------------
        public Boolean Init()
        {
            Boolean bret = true;

            try
            {
                //
            }
            catch ( Exception ex )
            {

            }

            return (bret);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 処理開始
        /// </summary>
        /// <returns></returns>
        //----------------------------------------------------------------------------------------------------
        public Boolean Start()
        {
            bool bret = true;

            try
            {
                // ログ記録：Start処理開始
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "Start処理開始");


                // GUI用ソケットサーバー構築
                if (this.m_GUISocketServer.StartListener(this.m_strGUIIPAddressOnly, this.m_nGUISocketPortNo, 1) == true)
                {
                    // 待受成功
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "GUI待受成功");
                }
                else
                {
                    // 待受失敗

                    throw (new Exception("GUI待ち受け失敗"));
                }

                // 各種処理用オブジェクト処理開始

                // 処理開始成功時
                if (bret == true && this.m_Thread != null)
                {
                    // スレッド開始
                    this.m_Thread.Start();
                }

                // ログ記録：Start処理終了
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "Start処理終了");
            }
            catch ( Exception ex )
            {
                bret = false;

                // ログ記録：エラー
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("Start処理,{0}", ex.Message));
            }

            return (bret);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 処理終了
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public void Stop()
        {
            try
            {
                // ログ記録：Stop処理開始
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "Stop処理開始");

                // NKKWebSocket
                if (this.m_WebSocket != null)
                {
                    // 処理終了
                    this.m_WebSocket.Stop();

                    // 処理終了成功
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "NKKWebSocket処理終了");
                }

                if (m_csbc.GetStartedFlag)
                {
                    m_csbc.End();
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "ComScaleBedConnection処理終了 アプリ終了による通信終了処理");
                    ResetScaleBedResetConnectStatus(m_paramList, "アプリ終了による通信終了処理におけるスケールベッド接続状態の初期化");
                }
                m_csbc = null; // ここを通過する際に[アプリは終了状態]であることを示すために[null]をセット

                // GUI用ソケットサーバー処理終了
                this.m_GUISocketServer.StopListner();

                // 待受終了
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "GUI待受終了");

                // メインスレッド停止
                if (this.m_Thread != null)
                {
                    // カウンタ値初期化
                    uint dwtickcount = (uint)System.Environment.TickCount;
                    // スレッドが終了するか10秒間待つ
                    while (!TdcLib.TdcLib.CheckTickCount(10 * 1000, dwtickcount, (uint)System.Environment.TickCount))
                    {
                        // スレッド停止
                        this.m_evFinish.Set();

                        // スレッドが終了した場合
                        if (this.m_Thread.IsAlive == false)
                        {
                            // 処理を抜ける
                            break;
                        }
                    };
                }

                // ログ削除
                this.DeleteLogFiles();

                // ログ記録：Stop処理終了
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "Stop処理終了");
            }
            catch ( Exception ex )
            {
                // ログ記録：エラー
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("Stop処理,{0}", ex.Message));
            }

            // 自プロセス情報を取得
            var pro = System.Diagnostics.Process.GetCurrentProcess();

            // 稼働時間
            this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, $"稼働時間：{DateTime.Now - pro.StartTime}, (処理開始時刻：{pro.StartTime})");
        }
        //----------------------------------------------------------------------------------------------------

#endregion

#region プライベートメソッド

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ログ記録
        /// </summary>
        /// <param name="dtNow">発生日時</param>
        /// <param name="LoggingClass">ログ区分</param>
        /// <param name="strMesssage">記録メッセージ</param>
        //----------------------------------------------------------------------------------------------------
        private void AddLogInfo(DateTime dtNow, NKKLogging.LOGGING_CLASS LoggingClass, String strMesssage)
        {
            // ログオブジェクト取得
            NKKLogging log = NKKLogging.GetInstance();

            // ログ記録
            log.AddLogInfo(dtNow, this.SERVICE_NAME, LoggingClass, strMesssage);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// アップデート処理用ログ記録
        /// </summary>
        /// <param name="LoggingClass">ログ区分</param>
        /// <param name="strMessage">記録メッセージ</param>
        //----------------------------------------------------------------------------------------------------
        private void AddLogInfoUpdate( NKKLoggingLib.NKKLogging.LOGGING_CLASS LoggingClass, String strMessage )
        {
            // ログ記録
            this.AddLogInfo(DateTime.Now, LoggingClass, strMessage);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// アップデート処理
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private void CheckUpdate()
        {
            // アップデートバージョンチェック
            if ( this.m_Updater.IsPublishedNewVersion(System.Reflection.Assembly.GetExecutingAssembly())) 
            {
                // 最新バージョンがある

                // 最新ファイルを取得
                if( this.m_Updater.GetLatestProgramFile())
                {
                    // 最新ファイルを取得+解凍完了

                    // GUIツール[NKKScaleBedTool.exe]を終了
                    try
                    {
                        this.m_GUISocketServer.AllSend(NKKScaleBedInformation.Encoding.GetBytes("EXIT"));
                        String taskkill = System.IO.Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.System), "taskkill.exe");

                        //
                        System.Diagnostics.Process[] ps = System.Diagnostics.Process.GetProcessesByName("NKKScaleBedtool");
                        foreach (System.Diagnostics.Process p in ps)
                        {
                            // ログ記録：GUIツール終了
                            this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("GUIツールを強制終了, プロセス名:{0}, プロセスID:{1}", p.ProcessName, p.Id));

                            //
                            using (System.Diagnostics.Process killproc = new System.Diagnostics.Process())
                            {
                                killproc.StartInfo.Verb = "RunAs";
                                killproc.StartInfo.FileName = taskkill;
                                killproc.StartInfo.Arguments = String.Format("/PID {0} /T /F", p.Id);
                                killproc.StartInfo.CreateNoWindow = false;
                                killproc.StartInfo.UseShellExecute = false;
                                //
                                killproc.Start();
                                // プロセス終了待ち
                                killproc.WaitForExit(10000);
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        this.Error = ex;
                    }

                    // アップデートを実施
                    this.m_Updater.AppUpdate();
                }

            }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// スレッド実行処理
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private void DoWork()
        {
            // スレッド開始
            this.m_evFinish.Reset();

            String strlog = String.Empty;

            while (true)
            {
                try
                {
                    // 初回処理
                    if (m_bFirstFlag != 0)
                    {
                        // 初回処理が終わっていない場合

                        // ログイン判定
                        if (NKKWebAccess.Login == false)
                        {
                            // 未ログイン

                            // ログイン処理
                            if ("1" == NKKWebAccess.ServerLogin("").Result.strContent)
                            {
                                // ログイン完了

                                // 施設コード
                                NKKLogging.GetInstance().FacilityCd = NKKWebAccess.FacilityCd;

                                // ログ記録：施設コード
                                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("施設コード:{0}", NKKWebAccess.FacilityCd));

                                // NKKWebSocket：処理開始
                                this.m_WebSocket.Start();

                                // ログ記録：処理開始成功
                                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "NKKWebSocket処理開始");
                            }
                        }

                        // ログイン判定
                        if (NKKWebAccess.Login == true)
                        {
                            // ログイン済み

                            if (m_bFirstFlag == 1)
                            {
                                //// 以下は「アプリ起動後に初回処理を完全未実施の状態」でのみ実施

                                // ログアップロード
                                this.m_LogUploader.UploadLog(this.GetType().Name);
                                // 自動更新チェック
                                this.CheckUpdate();
                            }
                            // #11987 2026.2.12 add 施設マスタの設定取得 TDC石井 start
                            String strUri = String.Format("{0}{1}{2}{3}?_={4}"
                                , NKKWebAccess.BaseUri
                                , NKKScaleBedInformation.WEB_APP_URI
                                , this.GET_FACILITY_INFO_URI
                                , NKKWebAccess.FacilityCd
                                , DateTime.Now.Ticks);
                            NKKWebAccessResponse res = NKKWebAccess.Get("施設マスタの設定取得", strUri).Result;
                            String strMstFacilityRecord = String.Empty;
                            if (res.response.IsSuccessStatusCode == true)
                            {
                                strMstFacilityRecord = res.strContent;
                                // JSON分解
                                Dictionary<String, String> json = NKKWebAccess.GetJsonData(strMstFacilityRecord);
                                // 体重計管理番号
                                if (json.ContainsKey("useFunction"))
                                {
                                    bool useScaleBedFlag = false;
                                    try
                                    {
                                        // 文字列をJSONオブジェクトとして解析
                                        var useFunction = Newtonsoft.Json.Linq.JObject.Parse(json["useFunction"]);

                                        // "func_cds" 配列を取り出す
                                        var funcCds = useFunction["func_cds"] as Newtonsoft.Json.Linq.JArray;
                                        if (funcCds != null)
                                        {
                                            useScaleBedFlag = funcCds.Any(item => (item as JObject)?["func_cd"]?.ToString() == "040");
                                        }
                                    }
                                    catch
                                    {
                                        ; // 念のためcatchする(この際は useScaleBedFlag は false)
                                    }

                                    if (!useScaleBedFlag)
                                    {
                                        m_bFirstFlag = 3;
                                        this.SendLogMessageToGUI("INFO", String.Empty, DateTime.Now, "起動失敗(施設としてスケールベッド機能がOFF)");
                                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "起動失敗(施設としてスケールベッド機能がOFF)");

                                        // ループの頭に戻るのでDoWorkループの最下部で行っている「30秒ウェイト」を実施
                                        if (this.m_evFinish.WaitOne(30 * 1000) == true)
                                        {
                                            break;
                                        }
                                        continue;
                                    }
                                }
                            }
                            // #11987 2026.2.12 add 施設マスタの設定取得 TDC石井 end

                            // 設定取得
                            String strUri2 = String.Format("{0}{1}{2}{3}/{4}?_={5}"
                                , NKKWebAccess.BaseUri
                                , NKKScaleBedInformation.WEB_APP_URI
                                , this.GET_CONFIG_URI
                                , NKKWebAccess.FacilityCd
                                , NKKScaleBedInformation.WeightNo
                                , DateTime.Now.Ticks );
                            NKKWebAccessResponse res2 = NKKWebAccess.Get("体重計設定取得", strUri2).Result;
                            String strConfig = String.Empty;
                            if ( res2.response.IsSuccessStatusCode == true )
                            {
                                strConfig = res2.strContent;
                            }
                            if (String.IsNullOrEmpty(strConfig) == false)
                            {
                                // 設定取得

                                // 体重計設定が有効な場合

                                // ログ記録：設定値
                                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("体重計設定値:{0}", strConfig));

                                // JSON分解
                                Dictionary<String, String> json = NKKWebAccess.GetJsonData(strConfig);

                                // 体重計管理番号
                                if ( json.ContainsKey("weightCd") == true )
                                {
                                    NKKScaleBedInformation.WeightCd = json["weightCd"];
                                }
                                // 体重計名称
                                if( json.ContainsKey("weightName") == true )
                                {
                                    NKKScaleBedInformation.WeightName = json["weightName"];

                                    // GUI：体重計名称通知
                                    this.SendLogMessageToGUI("INFO", String.Empty, DateTime.Now, NKKScaleBedInformation.WeightName);
                                }

                                // プリンタ設定
                                if (json.ContainsKey("printerClass") == true)
                                {
                                    // プリンター名設定
                                    switch (json["printerClass"])
                                    {
                                        case "0":   // TM-88Ⅳ
                                            NKKScaleBedInformation.PrinterName = NKKPrinter.PRINTER_NAME;
                                            break;

                                        case "1":   // TM-L90
                                            NKKScaleBedInformation.PrinterName = NKKPrinter.PRINTER_NAME;
                                            break;

                                        case "2":   // KIOSK
                                            NKKScaleBedInformation.PrinterName = NKKPrinter.PRINTER_NAME_KIOSK;
                                            break;
                                    }


                                    // プリンタの登録チェック
                                    String strlog2 = "使用不可";
                                    String strPrintStatusHex = String.Empty;
                                    if (NKKPrinter.IsPrinterExist(NKKScaleBedInformation.PrinterName) == true)
                                    {
                                        // 登録あり


                                        // プリンター状態を取得
                                        try
                                        {
                                            NKKPrinter.PRINTER_INFO_2 prtinfo;
                                            prtinfo = NKKPrinter.GetPrinterInfo(NKKScaleBedInformation.PrinterName );
                                            strPrintStatusHex = prtinfo.Status.ToString("X8");
                                            // プリンターオフライン：128[0x80]、利用不可：4096[0x1000]
                                            if (((prtinfo.Status & (uint)0x80) != (uint)0x80
                                               && (prtinfo.Status & (uint)0x1000) != (uint)0x1000))
                                            {
                                                strlog2 = "使用可";
                                            }
                                        }
                                        catch ( Exception ex )
                                        {
                                            //　プリンター状態取得失敗
                                            this.Error = ex;
                                            strlog2 = "未接続";
                                        }
                                    }

                                    // 
                                    strlog = String.Format("プリンタ{0}, ( {1} ),{2}", strlog2, strPrintStatusHex, NKKScaleBedInformation.PrinterName);

                                    // ログ記録
                                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, strlog);

                                    // GUI
                                    this.SendLogMessageToGUI("PRINTER", strlog2, DateTime.Now, NKKScaleBedInformation.PrinterName + String.Format(",( {0} )", strPrintStatusHex));
                                } else
                                {
                                    // ログ記録：プリンタ未使用
                                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "プリンタ未使用");
                                }

                                // #11987 2026.01.06 add スケールベッド用に追加されたカラムから設定を読み出して処理 TDC石井 start
                                // Stopメソッドが呼ばれる前であれば(※メソッド内でm_csbcをnullにしている)「スケールベッドとの通信を開始」系処理を実施
                                if (m_csbc != null)
                                {
                                    // 体重計種別
                                    if (json.ContainsKey("weightType") == true)
                                    {
                                        if (json["weightType"] != "1")
                                        {
                                            // スケールベッドじゃない設定だった場合
                                            m_bFirstFlag = 3;
                                            this.SendLogMessageToGUI("INFO", String.Empty, DateTime.Now, NKKScaleBedInformation.WeightName + "：起動失敗(config記載の体重計番号の設定が非スケールベッド用)");
                                            this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "起動失敗(config記載の体重計番号の設定が非スケールベッド用)");

                                            // ループの頭に戻るのでDoWorkループの最下部で行っている「30秒ウェイト」を実施
                                            if (this.m_evFinish.WaitOne(30 * 1000) == true)
                                            {
                                                break;
                                            }
                                            continue;
                                        }
                                    }

                                    // スケールベッド設定(json文字列)
                                    if (json.ContainsKey("scaleBedSetting") == true)
                                    {
                                        // json構造を示すための「ひな形(匿名型)」を用意
                                        var def = new[] { new { ctl_no = 0, disp_order = 0, item_name = "", item_bed_cd = 0, item_ip = "", item_port = 0 } };
                                        // ＜「ひな形(匿名型)」が格納されているjson配列＞として処理
                                        try
                                        {
                                            var scaleBedSetting = JsonConvert.DeserializeAnonymousType(json["scaleBedSetting"], def);

                                            if (scaleBedSetting != null)
                                            {
                                                m_paramList.Clear();
                                                foreach (var oneJsonObj in scaleBedSetting)
                                                {
                                                    m_paramList.Add(new ComScaleBedConnectionParam(oneJsonObj.item_ip, oneJsonObj.item_port, oneJsonObj.disp_order, oneJsonObj.item_name, oneJsonObj.item_bed_cd));
                                                }

                                                // DispOrderで昇順ソートし、DispOrderを1,2,3,...と振り直す(DispOrderが1,3,10等と飛んでいる可能性を考慮)
                                                m_paramList.Sort((a, b) => a.DispOrder.CompareTo(b.DispOrder));
                                                int dispOrder = 1;
                                                foreach (var param in m_paramList)
                                                {
                                                    param.DispOrder = dispOrder++;
                                                }

                                                ResetScaleBedResetConnectStatus(m_paramList, "通信開始処理におけるスケールベッド接続状態の初期化");
                                            }
                                        }
                                        catch
                                        {
                                            m_paramList.Clear();
                                        }

                                        if (m_paramList.Count >= 1)
                                        {
                                            // GUIのListViewにカラム追加させるオリジナル電文を定義してGUI側に電文送信
                                            // (※フォームの受け側ではAppとToolの両方のShowListViewを修正することに注意)
                                            for (int i = 0; i < m_paramList.Count; i++)
                                            {
                                                this.SendLogMessageToGUI($"SCALEBED/{m_paramList[i].BedName}/{m_paramList[i].DispOrder}", "接続試行開始", DateTime.Now, $"[{m_paramList[i].IPAddress}:{m_paramList[i].PortNo}]");
                                            }

                                            // スケールベッドとの通信を開始
                                            string sendKeepAliveIntervalStr = SystemSettingInfo.GetInstance().GetSingleLineValue(CONFIG_SCALEBED_SECTION, "SendKeepAliveInterval", "30");
                                            if (int.TryParse(sendKeepAliveIntervalStr, out int sendKeepAliveIntervalMsec))
                                            {
                                                sendKeepAliveIntervalMsec *= 1000; // 秒→ミリ秒に変換

                                                // 最小値10000、最大値600000の範囲チェック(※範囲外は何もセットしないことで既定値のまま)
                                                if (10000 <= sendKeepAliveIntervalMsec && sendKeepAliveIntervalMsec <= 600000)
                                                {
                                                    m_csbc.SetSendDataInterval(sendKeepAliveIntervalMsec);
                                                }
                                            }

                                            if (m_csbc.Start(m_paramList) == 0)
                                            {
                                                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "ComScaleBedConnection処理開始 スケールベッドとの通信開始に成功");
                                                this.SendLogMessageToGUI("INFO", String.Empty, DateTime.Now, NKKScaleBedInformation.WeightName);

                                                m_csbc.OnConnected -= new ComScaleBedConnection.OnConnectedEventHandler(this.OnConnected);
                                                m_csbc.OnConnected += new ComScaleBedConnection.OnConnectedEventHandler(this.OnConnected);

                                                m_csbc.OnException -= new ComScaleBedConnection.OnExceptionEventHandler(this.OnException);
                                                m_csbc.OnException += new ComScaleBedConnection.OnExceptionEventHandler(this.OnException);

                                                m_csbc.OnDataReceived -= new ComScaleBedConnection.OnDataReceivedEventHandler(this.OnDataReceived);
                                                m_csbc.OnDataReceived += new ComScaleBedConnection.OnDataReceivedEventHandler(this.OnDataReceived);

                                                // 1台以上のスケールベッドと通信試行開始できたら「初回処理終了」とする
                                                m_bFirstFlag = 0;
                                            }
                                            else
                                            {
                                                // 通信開始に失敗した場合はTRACEログとGUIに出力し、PG的にはそのまま流すことでDoWorkのループをキープする
                                                // そうすれば、再度「初回処理」が行われるので「さっきは何かの事情で開始に失敗したが次は成功」と後から復旧することができる
                                                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "ComScaleBedConnection処理開始 エラー発生：スケールベッドとの通信開始に失敗");
                                                this.SendLogMessageToGUI("INFO", String.Empty, DateTime.Now, NKKScaleBedInformation.WeightName + "：スケールベッドとの通信開始に失敗");
                                            }
                                        }
                                        else
                                        {
                                            this.SendLogMessageToGUI("INFO", String.Empty, DateTime.Now, NKKScaleBedInformation.WeightName + "：マスタにスケールベッド登録なしの判定");
                                        }
                                    }
                                }
                                // #11987 2026.01.06 add スケールベッド用に追加されたカラムから設定を読み出して処理 TDC石井 end
                            }
                            else
                            {
                                // 設定取得失敗

                                // ログ記録：体重計設定取得失敗
                                strlog = "体重計設定取得失敗";
                                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, strlog);

                                // GUI：体重計設定取得失敗
                                this.SendLogMessageToGUI("INFO", String.Empty, DateTime.Now, "体重計設定未取得" );
                                // GUI：体重計設定取得失敗
                                this.SendLogMessageToGUI("SERVER", String.Empty, DateTime.Now, strlog);
                            }
                        }
                    }


                    // ログ削除(日が変化した場合に実行)
                    if (this.dtDeleteDate != DateTime.Now.Date)
                    {
                        // スレッドにてログ削除を行う
                        Thread trd = new Thread(this.DeleteLogFiles)
                        {
                            Name = "ログ削除スレッド"
                        };
                        trd.Start();

                        // 不要ログ削除実施日付再設定
                        this.dtDeleteDate = DateTime.Now.Date;
                    }
                    

                    // 設定時刻による更新確認
                    if( this.UpdateDateTime <= DateTime.Now )
                    {
                        // 実施日時日時判定
                        if( this.m_dtCheckUpdate < this.UpdateDateTime)
                        {
                            // ログ記録：処理開始成功
                            this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "設定時刻による更新確認, " + this.m_strCheckUpdateTime );

                            // 実施日時保持
                            this.m_dtCheckUpdate = DateTime.Now;

                            // 更新確認
                            this.CheckUpdate();
                        }
                    }

                    // 設定時間によるログアップロード
                    if (this.LogUploadDateTime <= DateTime.Now)
                    {
                        // 実施日時日時判定
                        if (this.m_dtLogUpload < this.LogUploadDateTime)
                        {
                            // ログ記録：処理開始成功
                            this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "設定時刻によるログアップロード, " + this.m_strLogUploadCycle);

                            // 実施日時保持
                            this.m_dtLogUpload = DateTime.Now;

                            // ログアップロード
                            this.m_LogUploader.UploadLog(this.GetType().Name);
                        }
                    }

                    // 30秒間、又はシグナル待ち
                    if (this.m_evFinish.WaitOne(30 * 1000) == true)
                    {
                        // スレッド終了
                        break;
                    }
                }
                catch (Exception ex)
                {
                    this.Error = ex; // 中の処理でTRACEログに出力
                }
            };
        }

        // #11987 2025.12.02 add シリアル通信→TCPソケット通信 TDC石井 start
        private void OnConnected(ComScaleBedConnectionParam param)
        {
            try
            {
                SendScaleBedConnectStatus(param, "1", "スケールベッドと通信接続"); // TRACEログ出力＋GUI更新＋WebAPIコールをTaskで実施
            }
            catch (Exception ex)
            {
                this.Error = ex; // 中の処理でTRACEログに出力
            }
        }

        private void OnException(ComScaleBedConnectionParam param, Exception ex)
        {
            try
            {
                SendScaleBedConnectStatus(param, "0", "スケールベッドと通信切断"); // TRACEログ出力＋GUI更新＋WebAPIコールをTaskで実施
            }
            catch (Exception)
            {
                this.Error = ex; // 中の処理でTRACEログに出力
            }
        }

        private void OnDataReceived(ComScaleBedReceivedData rcv)
        {
            Task.Run(() =>
            {
                try
                {
                    this.SendLogMessageToGUI($"SCALEBED/{rcv.BedName}/{rcv.DispOrder}", "接続中", DateTime.Now, $"[{rcv.IPAddress}:{rcv.PortNo}] 測定値:{rcv.Data}");
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO,
                        $"スケールベッドから測定値を受信 SCALEBED{rcv.DispOrder} [{rcv.IPAddress}:{rcv.PortNo}] {rcv.BedName} 測定値:{rcv.Data}");

                    // ord_weight_scale と mnt_sclae_bed_state への書き込み の 実施依頼
                    String strUri = String.Format("{0}{1}{2}?_={3}"
                                    , NKKWebAccess.BaseUri
                                    , NKKScaleBedInformation.WEB_APP_URI
                                    , this.PUT_SCALEBED_VALUE_URI
                                    , DateTime.Now.Ticks
                                    );
                    String strBody = String.Format(@"{{""bedCd"":{0},""weightCd"":{1},""facilityCd"":""{2}"",""weightNo"":{3},""scaleValue"":{4},""mdCd"":""{5}"",""userId"":{6}}}"
                                        , rcv.BedCd
                                        , NKKScaleBedInformation.WeightCd
                                        , NKKWebAccess.FacilityCd
                                        , NKKScaleBedInformation.WeightNo
                                        , Convert.ToDecimal(rcv.Data)
                                        , rcv.MDCode
                                        , NKKWebAccess.UserNo
                                        );
                    NKKWebAccessResponse res = NKKWebAccess.Put("スケールベッド測定値通知", strUri, strBody).Result; // 中の処理でListViewに結果を表示
                    if (res.response.IsSuccessStatusCode == true)
                    {
                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, $"スケールベッド測定値通知 成功,{strBody}");
                    }
                    else
                    {
                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, $"スケールベッド測定値通知 失敗,{strBody}");
                    }
                }
                catch (Exception ex)
                {
                    this.Error = ex; // 中の処理でTRACEログに出力
                }
            });
        }
        // #11987 2025.12.02 add シリアル通信→TCPソケット通信 TDC石井 end

        // #11987 2026.1.30 add スケールベッド接続状態通知 TDC石井 start
        /// <summary>
        /// スケールベッド接続状態通知
        /// </summary>
        /// <param name="param">スケールベッド接続パラメータ</param>
        /// <param name="isConnect">接続状態 {"0":"切断", "1":"接続"}</param>
        /// <param name="logMsg">TRACEログに出すメッセージ(※GUI(ListView)は状態列が「切断／接続中」と変わるので内容列には出さない)</param>
        private void SendScaleBedConnectStatus(ComScaleBedConnectionParam param, string isConnect, string logMsg)
        {
            Task.Run(() =>
            {
                try
                {
                    var isConnectStr = isConnect == "0" ? "切断" : "接続中";

                    this.SendLogMessageToGUI($"SCALEBED/{param.BedName}/{param.DispOrder}",
                        isConnectStr, DateTime.Now, $"[{param.IPAddress}:{param.PortNo}]");
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO,
                        $"{logMsg} SCALEBED{param.DispOrder} [{param.IPAddress}:{param.PortNo}] {param.BedName} {isConnectStr}");

                    string strUri = string.Format("{0}{1}{2}?_={3}",
                        NKKWebAccess.BaseUri,
                        NKKScaleBedInformation.WEB_APP_URI,
                        this.PUT_SCALEBED_CONNECT_URI,
                        DateTime.Now.Ticks
                    );
                    string strBody = string.Format(
                        @"{{""bedCd"":{0},""weightCd"":{1},""facilityCd"":""{2}"",""weightNo"":{3},""isConnect"":{4}}}",
                        param.BedCd,
                        NKKScaleBedInformation.WeightCd,
                        NKKWebAccess.FacilityCd,
                        NKKScaleBedInformation.WeightNo,
                        isConnect
                    );
                    NKKWebAccessResponse res = NKKWebAccess.Put("スケールベッド接続状態通知", strUri, strBody).Result; // 中の処理でListViewに結果を表示

                    if (res.response.IsSuccessStatusCode == true)
                    {
                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, $"スケールベッド接続状態通知 成功,{strBody}");
                    }
                    else
                    {
                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, $"スケールベッド接続状態通知 失敗,{strBody}");
                    }
                }
                catch (Exception ex)
                {
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, logMsg + "," + ex.Message);
                }
            });
        }
        // #11987 2026.1.30 add スケールベッド接続状態通知 TDC石井 end

        /// <summary>
        /// スケールベッド接続状態の初期化(全て切断にする)通知
        /// </summary>
        /// <param name="paramList">スケールベッド接続パラメータのリスト</param>
        /// <param name="logMsg">TRACEログに出すメッセージ</param>
        private void ResetScaleBedResetConnectStatus(List<ComScaleBedConnectionParam> paramList, string logMsg)
        {
            Task.Run(() =>
            {
                try
                {
                    var bedCdJsonAryStr = "[";
                    foreach (var one in paramList)
                    {
                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO,
                            $"{logMsg} SCALEBED{one.DispOrder} [{one.IPAddress}:{one.PortNo}] {one.BedName} 切断");
                        bedCdJsonAryStr += $@"{one.BedCd},";
                    }
                    bedCdJsonAryStr = bedCdJsonAryStr.TrimEnd(',') + "]";

                    string strUri = string.Format("{0}{1}{2}?_={3}",
                        NKKWebAccess.BaseUri,
                        NKKScaleBedInformation.WEB_APP_URI,
                        this.PUT_SCALEBED_CONNECT_RESET_URI,
                        DateTime.Now.Ticks
                    );
                    string strBody = string.Format(
                        @"{{""bedCdList"":{0},""weightCd"":{1},""facilityCd"":""{2}"",""weightNo"":{3}}}",
                        bedCdJsonAryStr,
                        NKKScaleBedInformation.WeightCd,
                        NKKWebAccess.FacilityCd,
                        NKKScaleBedInformation.WeightNo
                    );
                    NKKWebAccessResponse res = NKKWebAccess.Put("スケールベッド接続状態の初期化", strUri, strBody).Result; // 中の処理でListViewに結果を表示

                    if (res.response.IsSuccessStatusCode == true)
                    {
                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, $"スケールベッド接続状態の初期化 成功,{strBody}");
                    }
                    else
                    {
                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, $"スケールベッド接続状態の初期化 失敗,{strBody}");
                    }
                }
                catch (Exception ex)
                {
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, logMsg + "," + ex.Message);
                }
            });
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 指定日以前のログファイルを削除
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private void DeleteLogFiles()
        {
            // ログオブジェクト取得
            NKKLogging log = NKKLogging.GetInstance();

            // ログ削除
            log.DeleteLogFiles(this.SERVICE_NAME, this.m_nLogFileKeepNumberDays, true);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// GUIへのメッセージ通知
        /// </summary>
        /// <param name="strServiceName">サービス名</param>
        /// <param name="strStatus">状態</param>
        /// <param name="dtNow">発生日時</param>
        /// <param name="strMessage">送信するメッセージ</param>
        //----------------------------------------------------------------------------------------------------
        private void SendLogMessageToGUI(String strServiceName, String strStatus, DateTime dtNow, String strMessage)
        {
            // 電文作成
            String strdata = String.Format("{0}\t{1}\t{2:yyyy/MM/dd HH:mm:ss:ffff}\t{3}\r\n", strServiceName, strStatus, dtNow, strMessage);

            // 保持オブジェクトチェック
            if (this.m_GUIInformation.ContainsKey(strServiceName) == true)
            {
                // 該当あり

                // 更新
                this.m_GUIInformation[strServiceName] = strdata;
            }
            else
            {
                // 該当なし

                // 新規追加
                this.m_GUIInformation.Add(strServiceName, strdata);
            }

            // 全クライアントソケットに送信
            Byte[] bdata = Encoding.UTF8.GetBytes(strdata);
            this.m_GUISocketServer.AllSend(bdata);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// GUI用クライアントソケット接続/切断時
        /// </summary>
        /// <param name="Sender">ベースオブジェクト</param>
        /// <param name="Status">接続状態</param>
        //----------------------------------------------------------------------------------------------------
        private void ClientConnected(Object Sender, TdcBaseSocket.ConnectionStatus Status)
        {
            // 接続状態判定
            if( Status == TdcBaseSocket.ConnectionStatus.CONNECT )
            {
                // 接続完了時

                if ( Sender is TdcBaseSocketServerClient cl )
                {
                    // 保持情報送信

                    List<String> listvalues = new List<String>();
                    foreach(KeyValuePair<String, String> item in this.m_GUIInformation)
                    {
                        listvalues.Add(item.Value);
                    }

                    foreach( String item in listvalues)
                    {
                        Byte[] bdata = Encoding.UTF8.GetBytes(item);
                        cl.AsyncWrite(bdata);
                    }
                }
            }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// WebSocket受信処理
        /// </summary>
        /// <param name="dtDate">受信日時</param>
        /// <param name="strMessage">受信メッセージ</param>
        //----------------------------------------------------------------------------------------------------
        private void WebSocketReceiveMessage( DateTime dtDate, String strMessage )
        {
            // 施設設定が機能OFF等でアプリを動作させたくないので初期化処理実施済としている状態の場合は「WebSocketで流れてくることを無視」
            if (m_bFirstFlag == 3)
            {
                return;
            }

            String strlog = String.Empty;
            String[] strlines = strMessage.Split(new char[]{ '\t'}, StringSplitOptions.None);

            // トピック取得
            String strtopic = strlines[0];

            // レシート印刷
            if (strtopic.StartsWith("WEIGHT/PRINT") == true)
            {
                String strUri = String.Empty;
                String strstate = String.Empty;
                String strbody = String.Empty;
                String strerr = String.Empty;
                int nret = 4;

                // 体重測定記録番号を取得
                String strCtrlNo = strlines[1];

                // ログ記録：体重測定記録番号
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("印刷指示, 体重測定記録番号:{0}", strCtrlNo));

                // 印刷情報取得
                strUri = String.Format("{0}{1}{2}{3}?_={4}"
                    , NKKWebAccess.BaseUri
                    , NKKScaleBedInformation.WEB_APP_URI
                    , this.GET_PRINT_CONTENT_URI
                    , strCtrlNo
                    , DateTime.Now.Ticks);
                NKKWebAccessResponse res = NKKWebAccess.Get("印刷情報取得", strUri).Result;
                if( res.response.IsSuccessStatusCode == true )
                {
                    strstate = res.strContent;
                }
                if (String.IsNullOrEmpty(strstate) == false)
                {
                    // 処理成功

                    // ログ記録：状態値
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("印刷指示, 情報:{0}", strstate));

                    // prniterContent切り出し
                    Dictionary<String, String> printtbl = NKKWebAccess.GetJsonData(strstate);

                    // 印刷指示受諾
                    //*@param request { weightScaleNo: 体重測定記録番号, printStatus: 状態, printErrorMessage: 印刷エラーメッセージ }
                    strUri = String.Format("{0}{1}{2}?_={3}"
                        , NKKWebAccess.BaseUri
                        , NKKScaleBedInformation.WEB_APP_URI
                        , this.PUT_PRINT_STATUS_URI
                        , DateTime.Now.Ticks);
                    strbody = String.Format("{{\"weightScaleNo\":{0}, \"printStatus\":{1}, \"printErrorMessage\": null}}"
                        , strCtrlNo
                        , 2
                    );
                    strstate = String.Empty;
                    res = NKKWebAccess.Put("印刷指示受諾通知", strUri, strbody).Result;
                    if( res.response.IsSuccessStatusCode == true )
                    {
                        strstate = res.strContent;
                    }
                    if (String.IsNullOrEmpty(strstate) == false)
                    {
                        // 処理成功

                        // ログ記録：状態値
                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("印刷指示受諾通知:{0}", strstate));

                        // 印刷情報取得取得
                        if( printtbl.ContainsKey("printContent") == true )
                        {
                            String strwork = printtbl["printContent"];
                            printtbl = NKKWebAccess.GetJsonData(strwork);
                        }

                        // 印刷行数判定
                        if (printtbl.ContainsKey("row_size") == true)
                        {
                            // 印刷行数取得
                            int nRowSize = 0;
                            if (int.TryParse(printtbl["row_size"], out nRowSize) == true)
                            {

                                Dictionary<int, NKKPrinterInformation> infos = new System.Collections.Generic.Dictionary<int, NKKPrinterInformation>();
                                Dictionary<int, String> datas = new System.Collections.Generic.Dictionary<int, String>();

                                // 印刷データ分解
                                for (int intlop = 0; intlop < nRowSize; intlop++)
                                {
                                    NKKPrinterInformation info = new NKKPrinterInformation();
                                    String strData = String.Empty;
                                    try
                                    {

                                        // 印刷行データ取得
                                        Dictionary<String, String> printinfo = NKKWebAccess.GetJsonData(printtbl[String.Format("row_{0}", intlop + 1)]);
                                        info.nId = int.Parse(printinfo["class"]);
                                        info.nFontSize = int.Parse(printinfo["font_size"]);
                                        strData = printinfo["value"];
                                    }
                                    catch (Exception ex)
                                    {
                                    }
                                    //
                                    infos.Add(intlop, info);
                                    datas.Add(intlop, strData);
                                }

                                // 印刷
                                this.m_Printer.PrintInfomation = infos;
                                this.m_Printer.PrintData = datas;

                                //　印刷実施
                                if (this.m_Printer.PrintOut(NKKPrinter.PRINTER_NAME) == true)
                                {
                                    // 印刷成功
                                    nret = 3;
                                }
                                else
                                {
                                    // 印刷失敗

                                    // エラーメッセージ
                                    strerr = this.m_Printer.Error.Message;

                                    // ログ記録
                                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, strerr);
                                }
                            }
                            else
                            {
                                // 印刷失敗

                                // エラーメッセージ
                                strerr = "印刷行数が数字以外";

                                // ログ記録
                                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, strerr);
                            }
                        }
                        else
                        {
                            // 印刷失敗

                            // エラーメッセージ
                            strerr = "印刷行数なし";

                            // ログ記録
                            this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, strerr);
                        }
                    }
                    else
                    {
                        // 印刷失敗

                        // エラーメッセージ
                        strerr = "印刷指示受諾失敗";

                        // ログ記録
                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, strerr);
                    }
                }
                else
                {
                    // 印刷失敗

                    // エラーメッセージ
                    strerr = "印刷情報取得失敗";

                    // ログ記録
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, strerr);
                }

                // 印刷結果報告
                //*@param request { weightScaleNo: 体重測定記録番号, printStatus: 状態, printErrorMessage: 印刷エラーメッセージ }
                strUri = String.Format("{0}{1}{2}?_={3}"
                    , NKKWebAccess.BaseUri
                    , NKKScaleBedInformation.WEB_APP_URI
                    , this.PUT_PRINT_STATUS_URI
                    , DateTime.Now.Ticks);
                strbody = String.Format("{{\"weightScaleNo\":{0}, \"printStatus\":{1}, \"printErrorMessage\": \"{2}\"}}"
                    , strCtrlNo
                    , nret
                    , strerr
                );
                strstate = String.Empty;
                res = NKKWebAccess.Put("印刷結果通知", strUri, strbody).Result;
                if(res.response.IsSuccessStatusCode == true )
                {
                    strstate = res.strContent;
                }
                if (String.IsNullOrEmpty(strstate) == false)
                {
                    // 処理成功

                    // ログ記録：状態値
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("印刷結果通知:{0}", strstate));
                }
            }

            if (strtopic.StartsWith("WEIGHT_SCALE/MST_CHANGED") == true)
            {
                //// 体重測定記録番号を取得(NKKWeightのときに使用していたらしい)
                //String strChangedInfo = strlines[1];

                if (m_csbc.GetStartedFlag)
                {
                    m_csbc.OnConnected -= new ComScaleBedConnection.OnConnectedEventHandler(this.OnConnected);
                    m_csbc.OnException -= new ComScaleBedConnection.OnExceptionEventHandler(this.OnException);
                    m_csbc.OnDataReceived -= new ComScaleBedConnection.OnDataReceivedEventHandler(this.OnDataReceived);

                    // Endの処理は
                    // ・各スケールベッドへの接続試行の停止、および、「@ 0x40」定間隔送信の停止 → ほぼ即時に実施される
                    // ・管理ソケット群の破棄処理 → 少し遅れて例外発生する可能性があるが上記でイベント解除＋自ポート番号はランダムなのでこの後に即時レベルで再通信が開始しても問題なし
                    // なので「End後に何かの終了を待つ」ような仕組みは不要
                    m_csbc.End();

                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "ComScaleBedConnection処理終了 マスタ変更通知による通信終了処理");
                    ResetScaleBedResetConnectStatus(m_paramList, "マスタ変更通知による通信終了処理におけるスケールベッド接続状態の初期化");
                }

                this.SendLogMessageToGUI("MESSAGECLEAR", "", DateTime.Now, "");
                m_bFirstFlag = 2;
            }
        }
        //----------------------------------------------------------------------------------------------------
    }
    //----------------------------------------------------------------------------------------------------

    #endregion
}
//----------------------------------------------------------------------------------------------------
