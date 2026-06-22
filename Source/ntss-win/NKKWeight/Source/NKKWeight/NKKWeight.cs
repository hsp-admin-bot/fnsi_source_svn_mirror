//----------------------------------------------------------------------------------------------------
//  NKKWeightクラス定義
//----------------------------------------------------------------------------------------------------
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading;
using System.Diagnostics;

//----------------------------------------------------------------------------------------------------
//  名前空間:TdcLib
//----------------------------------------------------------------------------------------------------
using TdcLib;
//----------------------------------------------------------------------------------------------------
//  名前空間:TdcSocketLib
//----------------------------------------------------------------------------------------------------
using TdcSocketLib;
//----------------------------------------------------------------------------------------------------
//  名前空間:NKKLoggingLib
//----------------------------------------------------------------------------------------------------
using NKKLoggingLib;
//----------------------------------------------------------------------------------------------------
//  名前空間:TdcVersionInfoLib
//----------------------------------------------------------------------------------------------------
using TdcVersionInfoLib;
//----------------------------------------------------------------------------------------------------
//  名前空間:NKKWebAccessLib
//----------------------------------------------------------------------------------------------------
using NKKWebAccessLib;
//----------------------------------------------------------------------------------------------------
//  名前空間:NKKFelicaLib
//----------------------------------------------------------------------------------------------------
using NKKFelicaLib;
//----------------------------------------------------------------------------------------------------
//  名前空間:NKKWebSocketLib
//----------------------------------------------------------------------------------------------------
using NKKWebSocketLib;
//----------------------------------------------------------------------------------------------------
using Newtonsoft.Json;
using NKKWeightScaleDB.Interfaces;
using NKKWeightScaleDB.Models;
using NKKWeightScaleDB.Services;
using System.Threading.Tasks;
using System.Web.Script.Serialization;
//  名前空間:NKKCommon
//----------------------------------------------------------------------------------------------------
using NKKCommon;
//----------------------------------------------------------------------------------------------------


//----------------------------------------------------------------------------------------------------
//  名前空間:NKKWeightLib
//----------------------------------------------------------------------------------------------------
namespace NKKWeightLib
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// NKKWeight
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public class NKKWeight
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
        // mod #9696 アプリケーションログのパスとファイル名の修正。 limingzhe start
        private readonly String LOG_FILE_EXT = "Weight";
        // mod #9696 アプリケーションログのパスとファイル名の修正。 limingzhe end
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 設定ファイル名
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String CONFIG_FILE_NAME = "NKKWeight.config";
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 設定ファイル内共通設定セッション識別子
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String CONFIG_COMMON_SECTION = "Settings\\Common";
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 設定ファイル内Felica設定セッション識別子
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String CONFIG_FELICA_SECTION = "Settings\\Felica";
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
        // add 2020-12-23 No.314:体重計との通信フォーマットの外部定義化 商 start
        /// <summary>
        /// 設定ファイル内ログ設定セッション識別子
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String CONFIG_WEIGHT_FORMAT_SECTION = "Settings\\WeightFormat";
        //----------------------------------------------------------------------------------------------------
        // add 2020-12-23 No.314:体重計との通信フォーマットの外部定義化 商 end
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
        private readonly String CONFIG_WEIGHT_SECTION = "Settings\\Weight";
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 体重計設定取得URI
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public readonly String GET_CONFIG_URI = "/api/weight_setting/weight/get2/";
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 体重計状態取得URI
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String GET_WEIGHT_STATUS_URI = "/api/weight_state/state/";
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 体重計カード書き込み結果通知URI
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String PUT_RESULT_CARD_WRITE_URI = "/api/weight_state/write_card_result";
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
        /// 装置情報取得URI
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String GET_MST_DEVICE_SET_INFO_URI = "/api/weight_scale_app/mst_device_set_info_export";
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ベッド情報取得URI
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String GET_MST_BED_INFO_URI = "/api/weight_scale_app/mst_bed_export";
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 車いす情報取得URI
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String GET_MST_WHEEL_CHAIR_INFO_URI = "/api/weight_scale_app/mst_wheel_chair_export";
        //----------------------------------------------------------------------------------------------------

        // #10833 2024.08.08 del 不要な処理削除 TDC米沢 start
        //// add #7189 【デグレ】条件送信時、サーマルプリンターで印字されない 王永吉 start
        //// 印刷執行フラグ
        //public static bool dFlag = false;
        //// 印刷処理前にステータスフラグ
        //private static bool doInFlag = false;
        //// ローグ出力フラグ
        //private static bool doCheck = false;
        //// add #7189 【デグレ】条件送信時、サーマルプリンターで印字されない 王永吉 end
        // #10833 2024.08.08 del 不要な処理削除 TDC米沢 end
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 直前で発生したエラーオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private Exception m_Exception = null;
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// システム設定：体重計アプリケーションバージョン情報
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly int GET_SYSTEM_DEFINE_VERSION_NO = 8;
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
        /// Felicaカードリーダーオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly NKKFalica m_Felica = new NKKFalica();
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 体重計クラスオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly NKKWeightScale m_WeightScale = new NKKWeightScale();
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// レシートプリンタクラスオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly NKKPrinter m_Printer = new NKKPrinter();
        //----------------------------------------------------------------------------------------------------

#endregion

        // add configから外部GUI用ソケット待受ポート番号を取得する 孫 start
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 外部GUI用ソケット待受ポート番号を取得する
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public int GetGUISocketPortNo()
        {
            return m_nGUISocketPortNo;
        }
        // add configから外部GUI用ソケット待受ポート番号を取得する 孫 end

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// コンストラクタ
        /// <param name="strFolder">設定ファイル格納先フォルダ名</param>
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public NKKWeight( String strFolder )
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

                // mod #9696 アプリケーションログのパスとファイル名の修正。 limingzhe start
                // ログ設定
                NKKLogging log = NKKLogging.GetInstance();
                //  バージョン情報記録用処理登録(ログが変わった場合にログの先頭に記録するため)
                log.FirstWriteEvent = VersionInfos.GetVersionInfo;
                // mod #9696 アプリケーションログのパスとファイル名の修正。 limingzhe end
                //  識別子
                // mod #9696 アプリケーションログのパスとファイル名の修正。 donghao start
                //log.LogExt = this.LOG_FILE_EXT + String.Format("_{0}", sys.GetSingleLineValue(CONFIG_WEIGHT_SECTION, "WeightNo", "1").Trim());
                log.LogExt = this.LOG_FILE_EXT+"_"+System.Net.Dns.GetHostName()+ String.Format("_{0}", sys.GetSingleLineValue(CONFIG_WEIGHT_SECTION, "WeightNo", "1").Trim());
                // mod #9696 アプリケーションログのパスとファイル名の修正。 donghao end

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
                // mod 2022-04-22 #6860 最後のスラッシュを除く Thach start
                NKKWebAccess.BaseUri = sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "BaseUri", String.Empty).Trim(' ', '/');
                // mod 2022-04-22 #6860 最後のスラッシュを除く Thach end
                // 最新ファイルダウンロード先フォルダ
                // del #11660 単体アプリの自己アップデート修正 高 start
                //NKKWeightInformation.DownloadSourceFolder = sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "DownloadFolder", String.Empty).Trim();
                // del #11660 単体アプリの自己アップデート修正 高 end

                // add オンプレでの自己アップデートに対応 孫 start
                // 最新ファイル取得先ファイル名
                // del #11660 単体アプリの自己アップデート修正 高 start
                //NKKWeightInformation.DownloadFileName = sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "DownloadFileName", "NKKWeight.zip").Trim();
                //NKKWeightInformation.DownloadFileName = "NKKWeightUpdate.zip";
                // del #11660 単体アプリの自己アップデート修正 高 end
                // add オンプレでの自己アップデートに対応 孫 end

                // 体重計番号
                NKKWeightInformation.WeightNo = sys.GetSingleLineValue(CONFIG_WEIGHT_SECTION, "WeightNo", "1").Trim();
                log.DeviceNo = NKKWeightInformation.WeightNo;
                // ログ記録：体重計番号
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("体重計番号:{0}", NKKWeightInformation.WeightNo));
                // アップデート実施日時
                this.m_strCheckUpdateTime = sys.GetSingleLineValue(CONFIG_WEIGHT_SECTION, "UpdateTime", this.m_strCheckUpdateTime).Trim();
                if( this.UpdateDateTime == DateTime.MaxValue)
                {
                    // ログ記録：設定無効
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "設定されているアップデート時刻が無効, 設定値：" + this.m_strCheckUpdateTime);
                }
                // ログアップロード実施日時
                this.m_strLogUploadCycle = sys.GetSingleLineValue(CONFIG_WEIGHT_SECTION, "LogUploadTime", this.m_strLogUploadCycle).Trim();
                if (this.LogUploadDateTime == DateTime.MaxValue)
                {
                    // ログ記録：設定無効
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "設定されているログアップロード時刻が無効, 設定値：" + this.m_strLogUploadCycle);
                }

                // Felica
                // フェリカカードシステムコード
                FelicaLibTdc.IcSystemCode = sys.GetSingleLineValue(CONFIG_FELICA_SECTION, "SystemCode", "88D5").Trim();
                // フェリカカードサービスコード１
                FelicaLibTdc.IcServiceCode1 = sys.GetSingleLineValue(CONFIG_FELICA_SECTION, "ServiceCode1", "0049").Trim();
                // フェリカカードサービスコード２
                FelicaLibTdc.IcServiceCode2 = sys.GetSingleLineValue(CONFIG_FELICA_SECTION, "ServiceCode2", "0089").Trim();


                // WebSocket
                // 識別子番号(体重系番号)
                this.m_WebSocket.IdentityNo = NKKWeightInformation.WeightNo;
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

                // GUI通知用関数登録
                this.m_WeightScale.SendMessageToGUIHandler = this.SendLogMessageToGUI;

                // GUI通知用関数登録
                this.m_Felica.SendMessageToGUIHandler = this.SendLogMessageToGUI;

                // GUI通知関数登録
                this.m_Printer.SendMessageToGUIHandler = this.SendLogMessageToGUI;


                // アップデーターオブジェクト初期化
                // ログ記録
                this.m_Updater.LoggingMethod = this.AddLogInfoUpdate;
                // プロセス種類
                this.m_Updater.ProcType = 0;
                // システム設定項目番号
                this.m_Updater.SystemDefineVersionNo = GET_SYSTEM_DEFINE_VERSION_NO;
                // バケット名(ダウンロード先フォルダ)
                this.m_Updater.Bucket = NKKWeightInformation.DownloadSourceFolder;
                // ダウンロードファイル名
                this.m_Updater.DownloadFileName = NKKWeightInformation.DownloadFileName;
                // ダウンロードファイルのパスワード
                this.m_Updater.Bucket = NKKWeightInformation.DownloadSourceFolder;
                // ダウンロードファイルのパスワード
                this.m_Updater.DownloadFilePassword = NKKWeightInformation.DownloadFilePassword;


                // スレッド構築
                this.m_Thread = new Thread(this.DoWork)
                {
                    Name = "NKKWeight処理スレッド",
                    IsBackground = false
                };

                // ログ記録：初期化処理終了
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "初期化処理終了");
            }
            catch ( Exception ex )
            {
                // mod #9696 アプリケーションログのパスとファイル名の修正。 limingzhe start
                // ログ設定
                NKKLogging log = NKKLogging.GetInstance();
                //  バージョン情報記録用処理登録(ログが変わった場合にログの先頭に記録するため)
                log.FirstWriteEvent = VersionInfos.GetVersionInfo;
                //  識別子
                log.LogExt = this.LOG_FILE_EXT + "_" + System.Net.Dns.GetHostName();
                // mod #9696 アプリケーションログのパスとファイル名の修正。 limingzhe end
                // ログ記録：エラー
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("初期化処理,{0}", ex.Message));
            }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// デストラクタ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        ~NKKWeight()
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

                // NKKWeightScale
                if (this.m_WeightScale != null)
                {
                    // 処理終了
                    this.m_WeightScale.Close();

                    // 処理終了成功
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO,  "NKKWeightScale処理終了");
                }

                // NKKFalica
                if( this.m_Felica != null )
                {
                    // 処理終了
                    this.m_Felica.Stop();

                    // 処理終了成功
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "NKKFalica処理終了");
                }

                // NKKWebSocket
                if (this.m_WebSocket != null)
                {
                    // 処理終了
                    this.m_WebSocket.Stop();

                    // 処理終了成功
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "NKKWebSocket処理終了");
                }

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

                    // GUIツール[FNWSiScaleTool.exe]を終了
                    try
                    {
                        this.m_GUISocketServer.AllSend(NKKWeightInformation.Encoding.GetBytes("EXIT"));
                        String taskkill = System.IO.Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.System), "taskkill.exe");

                        //
                        System.Diagnostics.Process[] ps = System.Diagnostics.Process.GetProcessesByName("FNWSiScaleTool");
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

            Boolean bFirst = true;
            String strlog = String.Empty;


            while (true)
            {
                try
                {
                    // 初回処理
                    if (bFirst == true)
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

                                //体重計App用のマスタデータを初期化
                                
                                // DEL #7221 2023/02/05 BY HandsomeLin Start
                                //   Oh, my god! The master API has not been implemented yet!!!
                                
                                // InitialMasterData();
                                
                                // DEL #7221 2023/02/05 BY HandsomeLin End
                                
                                
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

                            // ログアップロード
                            this.m_LogUploader.UploadLog(this.GetType().Name);

                            // 自動更新チェック
                            this.CheckUpdate();


                            // 設定取得
                            String strUri = String.Format("{0}{1}{2}{3}/{4}?_={5}"
                                , NKKWebAccess.BaseUri
                                , NKKWeightInformation.WEB_APP_URI
                                , this.GET_CONFIG_URI
                                , NKKWebAccess.FacilityCd
                                , NKKWeightInformation.WeightNo
                                , DateTime.Now.Ticks );
                            NKKWebAccessResponse res = NKKWebAccess.Get("体重計設定取得", strUri).Result;
                            String strConfig = String.Empty;
                            if ( res.response.IsSuccessStatusCode == true )
                            {
                                strConfig = res.strContent;
                            }
                            if (String.IsNullOrEmpty(strConfig) == false)
                            {
                                // 設定取得

                                // 初回処理終了
                                bFirst = false;

                                // 体重計設定が有効な場合

                                // ログ記録：設定値
                                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("体重計設定値:{0}", strConfig ));

                                // JSON分解
                                Dictionary<String, String> json = NKKWebAccess.GetJsonData(strConfig);

                                // 体重計管理番号
                                if( json.ContainsKey("weightCd") == true )
                                {
                                    NKKWeightInformation.WeightCd = json["weightCd"];
                                }
                                // 体重計名称
                                if( json.ContainsKey("weightName") == true )
                                {
                                    NKKWeightInformation.WeightName = json["weightName"];

                                    // GUI：体重計名称通知
                                    this.SendLogMessageToGUI("INFO", String.Empty, DateTime.Now, NKKWeightInformation.WeightName);
                                }
                                // 体重計機種
                                if (json.ContainsKey("deviceClass") == true)
                                {
                                    NKKWeightInformation.DeviceClass = json["deviceClass"];
                                }


                                // NKKFalica使用判定
                                if (json.ContainsKey("isHasCardReader") == true)
                                {
                                    // #12738 mod 2026.06.11 Felica使用設定処理を関数化 TDC米沢 start

                                    //if (json["isHasCardReader"] == "1")
                                    //{
                                    //    // カードあり

                                    //    // NKKFalica：処理開始
                                    //    this.m_Felica.Start();

                                    //    // ログ記録：処理開始成功
                                    //    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "NKKFalica処理開始");
                                    //}
                                    //else
                                    //{
                                    //    // ログ記録：Felica未使用
                                    //    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "Falica未使用");

                                    //    // GUI：Felica未使用
                                    //    this.SendLogMessageToGUI("FELICA", "未使用", DateTime.Now, String.Empty);
                                    //}

                                    // Felica使用設定
                                    this.FelicaUsageSetting(json["isHasCardReader"]);

                                    // #12738 mod 2026.06.11 Felica使用設定処理を関数化 TDC米沢 start
                                }

                                // プリンタ設定
                                if (json.ContainsKey("printerClass") == true)
                                {
                                    // #12738 mod 2026.06.10 プリンタ名取得/使用可能チェック処理を関数化 TDC米沢 start

                                    //// プリンター名設定
                                    //switch (json["printerClass"])
                                    //{
                                    //    case "0":   // TM-88Ⅳ
                                    //        NKKWeightInformation.PrinterName = NKKPrinter.PRINTER_NAME;
                                    //        break;

                                    //    case "1":   // TM-L90
                                    //        NKKWeightInformation.PrinterName = NKKPrinter.PRINTER_NAME;
                                    //        break;

                                    //    case "2":   // KIOSK
                                    //        NKKWeightInformation.PrinterName = NKKPrinter.PRINTER_NAME_KIOSK;
                                    //        break;
                                    //}

                                    //// プリンタの登録チェック
                                    //String strlog2 = "使用不可";
                                    //String strPrintStatusHex = String.Empty;
                                    //if (NKKPrinter.IsPrinterExist(NKKWeightInformation.PrinterName) == true)
                                    //{
                                    //    // 登録あり

                                    //    // プリンター状態を取得
                                    //    try
                                    //    {
                                    //        NKKPrinter.PRINTER_INFO_2 prtinfo;
                                    //        prtinfo = NKKPrinter.GetPrinterInfo(NKKWeightInformation.PrinterName );
                                    //        strPrintStatusHex = prtinfo.Status.ToString("X8");
                                    //        // プリンターオフライン：128[0x80]、利用不可：4096[0x1000]
                                    //        if (((prtinfo.Status & (uint)0x80) != (uint)0x80
                                    //           && (prtinfo.Status & (uint)0x1000) != (uint)0x1000))
                                    //        {
                                    //            strlog2 = "使用可";
                                    //        }
                                    //    }
                                    //    catch ( Exception ex )
                                    //    {
                                    //        //　プリンター状態取得失敗
                                    //        this.Error = ex;
                                    //        strlog2 = "未接続";
                                    //    }
                                    //}

                                    //// 
                                    //strlog = String.Format("プリンタ{0}, ( {1} ),{2}", strlog2, strPrintStatusHex, NKKWeightInformation.PrinterName);

                                    //// ログ記録
                                    //this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, strlog);

                                    //// GUI
                                    //this.SendLogMessageToGUI("PRINTER", strlog2, DateTime.Now, NKKWeightInformation.PrinterName + String.Format(",( {0} )", strPrintStatusHex));

                                    // プリンター名設定/使用可能チェック
                                    this.CheckPrinter(json["printerClass"]);

                                    // #12738 mod 2026.06.10 プリンタ名取得/使用可能チェック処理を関数化 TDC米沢 end
                                }
                                else
                                {
                                    // ログ記録：プリンタ未使用
                                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "プリンタ未使用");
                                }


                                // 通信設定
                                NKKWeightScale.SERIAL_INFO info = new NKKWeightScale.SERIAL_INFO();
                                if( json.ContainsKey("portName") == true )
                                {
                                    info.strPortName = json["portName"];
                                }
                                info.nBaudRate = 2400;
                                info.nDataBits = 7;
                                info.StopBits = System.IO.Ports.StopBits.One;
                                info.Parity = System.IO.Ports.Parity.Even;
                                info.Handshake = System.IO.Ports.Handshake.None;

                                // NKKWeightScale初期化
                                if (this.m_WeightScale.Init(info) == false)
                                {
                                    // 初期化失敗
                                    throw new Exception("NKKWeightScale初期化失敗");
                                }

                                // NKKWeightScale：処理開始
                                if (this.m_WeightScale.Open() == true)
                                {
                                    // ログ記録：処理開始成功
                                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "NKKWeightScale処理開始");
                                }
                                else
                                {
                                    // 処理開始失敗時
                                    throw (new Exception("NKKWeightScale処理開始失敗"));
                                }

                                // add 2020-08-24 FNSI-仕様追加 田中衡機処理 夏 start
                                if ("1".Equals(NKKWeightInformation.DeviceClass))
                                {
                                    // データ送信間隔（秒数）
                                    if (json.ContainsKey("dataSendInterval") == true)
                                    {
                                        if(String.IsNullOrEmpty(json["dataSendInterval"]) == false)
                                        {
                                            NKKWeightInformation.DataSendInterval = int.Parse(json["dataSendInterval"]);
                                        }
                                        else
                                        {
                                            NKKWeightInformation.DataSendInterval = 2;
                                        }                                        
                                    }
                                    else
                                    {
                                        NKKWeightInformation.DataSendInterval = 2;
                                    }
                                    // データ種類
                                    if (json.ContainsKey("dataSelectType") == true)
                                    {
                                        if (String.IsNullOrEmpty(json["dataSendInterval"]) == false)
                                        {
                                            NKKWeightInformation.DataSelectType = json["dataSelectType"];
                                        }
                                        else
                                        {
                                            NKKWeightInformation.DataSelectType = "0";
                                        }                                            
                                    }
                                    else
                                    {
                                        NKKWeightInformation.DataSelectType = "0";
                                    }
                                }
                                // add 2020-08-24 FNSI-仕様追加 田中衡機処理 夏 end

                                // add 2020-12-23 No.314:体重計との通信フォーマットの外部定義化 商 start
                                // 電文Unit
                                this.m_WeightScale.weightFormatUnit = "kg";
                                // 電文フォーマット
                                if (json.ContainsKey("telegramFormat") == true)
                                {
                                    if (String.IsNullOrEmpty(json["telegramFormat"]) == false)
                                    {
                                        
                                    }
                                    String configFormat = String.Empty;
                                    if (String.IsNullOrEmpty(json["telegramFormat"]) == false)
                                    {
                                        Dictionary<String, String> telegramFormat = NKKWebAccess.GetJsonData(json["telegramFormat"]);
                                        if (telegramFormat.ContainsKey("telegram_format") == true)
                                        {
                                            if (String.IsNullOrEmpty(telegramFormat["telegram_format"]) == false)
                                            {
                                                String weightFormat = telegramFormat["telegram_format"];
                                                configFormat = weightFormat;
                                                bool errFlg = false;
                                                if (String.IsNullOrEmpty(weightFormat))
                                                {
                                                    this.m_WeightScale.weightFormatData = String.Empty;
                                                }
                                                else
                                                {
                                                    String[] formats = weightFormat.Split(new String[] { "[CRLF]", "[CR]", "[LF]" }, StringSplitOptions.RemoveEmptyEntries);
                                                    String formatIndex = String.Empty;
                                                    String format = String.Empty;
                                                    format = formats[0];

                                                    // フォーマットチェック
                                                    List<int> list1 = new List<int>();
                                                    List<int> list2 = new List<int>();
                                                    int cnt = 0;
                                                    foreach (char c in format)
                                                    {
                                                        if ("{".Equals(c.ToString()))
                                                        {
                                                            list1.Add(cnt);
                                                        }
                                                        if ("}".Equals(c.ToString()))
                                                        {
                                                            list2.Add(cnt);
                                                        }
                                                        cnt++;
                                                    }
                                                    // 「{」、「}」なし
                                                    if ((list1 == null || list1.Count == 0) || (list2 == null || list2.Count == 0))
                                                    {
                                                        errFlg = true;
                                                    }
                                                    else
                                                    {
                                                        // 「{」、「}」個数不正
                                                        if (list1.Count != list2.Count)
                                                        {
                                                            errFlg = true;
                                                        }
                                                        else
                                                        {
                                                            // 「{」、「}」位置不正
                                                            List<int> list = new List<int>();
                                                            for (int i = 0; i < list1.Count; i++)
                                                            {
                                                                list.Add(list1[i]);
                                                                list.Add(list2[i]);
                                                            }
                                                            for (int i = 0; i < list.Count; i++) 
                                                            {
                                                                if (i < list.Count - 1)
                                                                {
                                                                    if (list[i + 1] < list[i])
                                                                    {
                                                                        errFlg = true;
                                                                        break;
                                                                    }
                                                                }
                                                            }

                                                            if (errFlg == false)
                                                            {
                                                                for (int i = 0; i < list1.Count; i++)
                                                                {
                                                                    // 「{」、「}」順序不正
                                                                    if (list1[i] > list2[i])
                                                                    {
                                                                        errFlg = true;
                                                                        break;
                                                                    }
                                                                    // {}中の内容サイズのチェック
                                                                    if (errFlg == false && (list2[i] - list1[i] <= 3))
                                                                    {
                                                                        errFlg = true;
                                                                        break;
                                                                    }
                                                                    // 「0:」が存在のチェック
                                                                    if (!"0:".Equals(format.Substring(list1[i] + 1, 2)))
                                                                    {
                                                                        errFlg = true;
                                                                        break;
                                                                    }
                                                                }
                                                            }  
                                                        }
                                                    }


                                                    // フォーマットエラー
                                                    if (errFlg == true)
                                                    {
                                                        // ログ記録：フォーマットエラー
                                                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("通信フォーマット不正。「{0}」", weightFormat));
                                                        this.m_WeightScale.weightFormatData = String.Empty;
                                                    }
                                                    else
                                                    {
                                                        this.m_WeightScale.weightFormatData = format;
                                                    }

                                                }
                                            }
                                        }

                                    }
                                    // システム共通設定クラス初期化
                                    // 設定ファイル名作成
                                    String strfile = AppDomain.CurrentDomain.BaseDirectory;
                                    if (strfile.EndsWith("\\") == false)
                                    {
                                        strfile += "\\";
                                    }
                                    strfile += this.CONFIG_FILE_NAME;

                                    // システム共通設定クラス初期化
                                    SystemSettingInfo sys = SystemSettingInfo.GetInstance();
                                    if (sys.Load(strfile) == true)
                                    {
                                        sys.SetValue(CONFIG_WEIGHT_FORMAT_SECTION, "FormatString", configFormat);
                                        sys.Save();
                                    }

                                    if (String.IsNullOrEmpty(json["telegramFormat"]) == false)
                                    {
                                        Dictionary<String, String> unit = NKKWebAccess.GetJsonData(json["telegramFormat"]);
                                        if (unit.ContainsKey("unit") == true)
                                        {
                                            if (String.IsNullOrEmpty(unit["unit"]) == false)
                                            {
                                                this.m_WeightScale.weightFormatUnit = unit["unit"];
                                            }
                                        }
                                    }       
                                }
                                // add 2020-12-23 No.314:体重計との通信フォーマットの外部定義化 商 end
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


                    // NKKWeightScale：処理状態確認
                    if( this.m_WeightScale.IsOpen == false && bFirst == false )
                    {
                        // 未接続で初回処理が終わっている場合

                        // NKKWeightScale初期化
                        this.m_WeightScale.Init(this.m_WeightScale.SerialInfomation);

                        strlog = "NKKWeightScale処理再開";
                        if (this.m_WeightScale.Open() == true)
                        {
                            // ログ記録：処理開始成功
                            this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, strlog);
                        }
                        else
                        {
                            // 処理開始失敗時
                            strlog += "失敗";
                            this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, strlog);
                        }
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
                    // #10833 2024.08.08 del 不要な処理削除 TDC米沢 start
                    //// add #7189 【デグレ】条件送信時、サーマルプリンターで印字されない 王永吉 start
                    //// 初回処理じゃないの場合
                    //if (!bFirst)
                    //{
                    //    dFlag = true;
                    //}
                    //// add #7189 【デグレ】条件送信時、サーマルプリンターで印字されない 王永吉 end
                    // #10833 2024.08.08 del 不要な処理削除 TDC米沢 end
                }
                catch (Exception ex)
                {
                    this.Error = ex;
                }
            };
        }
        //----------------------------------------------------------------------------------------------------

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
            String strlog = String.Empty;
            String[] strlines = strMessage.Split(new char[]{ '\t'}, StringSplitOptions.None);

            // トピック取得
            String strtopic = strlines[0];

            // add 2020-08-24 FNSI-仕様追加 田中衡機処理 夏 start
            // 田中衡機
            if (strtopic.StartsWith("WEIGHT/SCALE_CLEAR") == true)
            {
                // 体重計からの値を格納するバッファをクリアする
                NKKWeightScale.listvalues.Clear();
            }
            // add 2020-08-24 FNSI-仕様追加 田中衡機処理 夏 end

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
                    , NKKWeightInformation.WEB_APP_URI
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
                        , NKKWeightInformation.WEB_APP_URI
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
                    , NKKWeightInformation.WEB_APP_URI
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

            // カード書き込み
            if ( strtopic.StartsWith("WEIGHT/CARD_WRITE") == true )
            {
                // 書き込み指示取得
                String strUri = String.Format("{0}{1}{2}{3}?_={4}"
                    , NKKWebAccess.BaseUri
                    , NKKWeightInformation.WEB_APP_URI
                    , this.GET_WEIGHT_STATUS_URI
                    , NKKWeightInformation.WeightNo
                    , DateTime.Now.Ticks);
                NKKWebAccessResponse res = NKKWebAccess.Get("体重計接続状態取得", strUri).Result;
                if (res.response.IsSuccessStatusCode == true)
                {
                    String strstate = res.strContent;
                    if (String.IsNullOrEmpty(strstate) == false)
                {
                    // 処理成功

                    // ログ記録：状態値
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("体重計状態値:{0}", strstate));

                    int nret = 0;

                    // JSON分解
                    Dictionary<String, String> json = NKKWebAccess.GetJsonData(strstate);

                    // カード書き込み内容
                    if (json.ContainsKey("cardWriteValue") == true)
                    {
                        String carddata = json["cardWriteValue"];

                        // JSON分解
                        json = NKKWebAccess.GetJsonData(carddata);

                        // カード書き込み内容
                        if (json.ContainsKey("id") == true)
                        {
                            // カード書き込み内容取得
                            String strdata = json["id"];

                            // カード書き込み
                            if( this.m_Felica.WritePatCard( strdata ) == true )
                            {
                                // 書き込み成功
                                nret = 1;
                            }
                        }
                        else
                        {
                            // カード書き込み内容(id)なし

                            // ログ記録：カード書き込み情報(id)なし
                            strlog = "カード書き込み情報(id)なし";
                            this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, strlog);
                        }
                    }
                    else
                    {
                        // カード書き込み内容なし

                        // ログ記録：カード書き込み情報なし
                        strlog = "カード書き込み情報なし";
                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, strlog);
                    }

                    // 書き込み結果報告
                    //*@param request { weightCd: 体重計管理コード, facilityCd: 施設コード, weightNo: 体重計番号, writeResult: 書き込み結果 }
                    strUri = String.Format("{0}{1}{2}?_={3}"
                        , NKKWebAccess.BaseUri
                        , NKKWeightInformation.WEB_APP_URI
                        , this.PUT_RESULT_CARD_WRITE_URI
                        , DateTime.Now.Ticks);
                    String strbody = String.Format("{{\"weightCd\":{0}, \"facilityCd\":\"{1}\", \"weightNo\":{2}, \"writeResult\":{3}}}"
                        , NKKWeightInformation.WeightCd
                        , NKKWebAccess.FacilityCd
                        , NKKWeightInformation.WeightNo
                        , nret
                    );
                    res = NKKWebAccess.Put("カード書き込み結果通知", strUri, strbody).Result;
                    if (res.response.IsSuccessStatusCode == true)
                    {
                        // 処理成功

                        // ログ記録
                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("カード書き込み結果通知完了,{0}", strbody));
                    }
                }
                }
                else
                {
                    // 体重計状態取得失敗

                    // ログ記録：体重計状態取得失敗
                    strlog = "体重計状態取得失敗";
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, strlog);
                }
            }

            if (strtopic.StartsWith("WEIGHT_SCALE/MST_CHANGED") == true)
            {
                // #12738 mod 2026.06.08 体重計マスタの設定変更通知に対応する TDC米沢 start
                //// 体重測定記録番号を取得
                //String strChangedInfo = strlines[1];

                /////*@param request { weightCd: 体重計管理コード, facilityCd: 施設コード, weightNo: 体重計番号, isConnect: 接続状態 }
                //String strUri = String.Format("{0}{1}{2}?_={3}"
                //    , NKKWebAccess.BaseUri
                //    , NKKWeightInformation.WEB_APP_URI
                //    , getRequestExportUri(strChangedInfo)
                //    , DateTime.Now.Ticks);

                //String strbody = getRequestExportBody(strChangedInfo);

                //NKKWebAccessResponse res = NKKWebAccess.Post("体重計接続状態取得", strUri, strbody).Result;

                //if (res.response.IsSuccessStatusCode == true)
                //{
                //    String strstate = res.strContent;

                //    var serializer = new JavaScriptSerializer();

                //    // JSON分解
                //    Dictionary<String, String> json = NKKWebAccess.GetJsonData(strbody);
                //    // カード書き込み内容
                //    if (json.ContainsKey("table") == true)
                //    {
                //        String strtable = json["table"];
                //        if (strtable.EndsWith("mst_bed"))
                //        {
                //            syncMasterDataBed(strstate);
                //        }
                //        else if (strtable.EndsWith("mst_wheel_chair"))
                //        {
                //            syncMasterDataWheelChair(strstate);
                //        }
                //        else if (strtable.EndsWith("mst_device_set_info_default"))
                //        {
                //            syncMasterDataDeviceSetInfoDefault(strstate);
                //        }
                //    }
                //}

                // マスタ更新

                // 設定取得
                String strUri = String.Format("{0}{1}{2}{3}/{4}?_={5}"
                    , NKKWebAccess.BaseUri
                    , NKKWeightInformation.WEB_APP_URI
                    , this.GET_CONFIG_URI
                    , NKKWebAccess.FacilityCd
                    , NKKWeightInformation.WeightNo
                    , DateTime.Now.Ticks);
                NKKWebAccessResponse res = NKKWebAccess.Get("体重計設定取得", strUri).Result;
                String strConfig = String.Empty;
                if (res.response.IsSuccessStatusCode == true)
                {
                    strConfig = res.strContent;
                }
                if (String.IsNullOrEmpty(strConfig) == false)
                {
                    // 設定取得

                    // 体重計設定が有効な場合

                    // ログ記録：設定値
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("体重計設定値:{0}", strConfig));

                    // JSON分解
                    Dictionary<String, String> json = NKKWebAccess.GetJsonData(strConfig);

                    // NKKFalica使用判定
                    if (json.ContainsKey("isHasCardReader") == true)
                    {
                        // Felica使用設定
                        this.FelicaUsageSetting(json["isHasCardReader"]);
                    }
                    else
                    {
                        // ログ記録：プリンタ未使用
                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "Felica未使用");
                    }

                    // プリンタ設定
                    if (json.ContainsKey("printerClass") == true)
                    {
                        // プリンター名設定/使用可能チェック
                        this.CheckPrinter(json["printerClass"]);
                    }
                    else
                    {
                        // ログ記録：プリンタ未使用
                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "プリンタ未使用");
                    }
                }
                else
                {
                    // 設定取得失敗

                    // ログ記録：体重計設定取得失敗
                    strlog = "体重計設定取得失敗";
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, strlog);

                    // GUI：体重計設定取得失敗
                    this.SendLogMessageToGUI("INFO", String.Empty, DateTime.Now, "体重計設定未取得");
                    // GUI：体重計設定取得失敗
                    this.SendLogMessageToGUI("SERVER", String.Empty, DateTime.Now, strlog);
                }
                // #12738 mod 2026.06.08 体重計マスタの設定変更通知に対応する TDC米沢 start
            }
        }
        //----------------------------------------------------------------------------------------------------


        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// Get body request format
        /// </summary>
        /// <param name="strMessage">受信メッセージ</param>
        //----------------------------------------------------------------------------------------------------
        private String getRequestExportBody(String strMessage)
        {
            if (String.IsNullOrEmpty(strMessage) == false)
            {
                // ログ記録：状態値
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, String.Format("体重計状態値:{0}", strMessage));

                // JSON分解
                Dictionary<String, String> json = NKKWebAccess.GetJsonData(strMessage);

                // カード書き込み内容
                if (json.ContainsKey("table") == true)
                {
                    String strtable = json["table"];

                    if (json.ContainsKey("data") == true)
                    {
                        String strdata = json["data"];

                        // JSON分解
                        json = NKKWebAccess.GetJsonData(strdata);

                        if (json.ContainsKey("facility_cd") == true)
                        {
                            return String.Format("{{\"table\":\"{0}\", \"facilityCd\": \"{1}\"}}", strtable, json["facility_cd"]);
                        }
                    }
                }
            }
            return null;
        }

        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// Get table request export
        /// </summary>
        /// <param name="strMessage">受信メッセージ</param>
        //----------------------------------------------------------------------------------------------------
        private String getRequestExportUri(String strMessage)
        {
            if (String.IsNullOrEmpty(strMessage) == false)
            {
                // JSON分解
                Dictionary<String, String> json = NKKWebAccess.GetJsonData(strMessage);

                // カード書き込み内容
                if (json.ContainsKey("table") == true)
                {
                    String strtable = json["table"];
                    switch (strtable)
                    {
                        case "mst_bed":
                            return this.GET_MST_BED_INFO_URI;

                        case "mst_wheel_chair":
                            return this.GET_MST_WHEEL_CHAIR_INFO_URI;

                        case "mst_device_set_info_default":
                            return this.GET_MST_DEVICE_SET_INFO_URI;

                        default:
                            break;
                    }
                }
            }
            return this.GET_MST_BED_INFO_URI;
        }

        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// Sync master data of bed
        /// </summary>
        /// <param name="strMessage">受信メッセージ</param>
        //----------------------------------------------------------------------------------------------------
        private void syncMasterDataBed(String strMessage)
        {
            if (String.IsNullOrEmpty(strMessage) == false)
            {
                IMstBedService mstBedService = new MstBedService();
                List<Mst_bed> mst_bed_response = JsonConvert.DeserializeObject<List<Mst_bed>>(strMessage);

                if (mst_bed_response.Count > 0)
                {
                    bool mstBedIsClearSuccess = mstBedService.ClearAllDataAsync().Result;
                    if (mstBedIsClearSuccess)
                    {
                        mstBedService.AddRangeAsync(mst_bed_response);
                    }
                }
            }
        }

        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// Sync master data of wheel chair
        /// </summary>
        /// <param name="strMessage">受信メッセージ</param>
        //----------------------------------------------------------------------------------------------------
        private void syncMasterDataWheelChair(String strMessage)
        {
            if (String.IsNullOrEmpty(strMessage) == false)
            {
                IMstWheelChairService mstWheelChairService = new MstWheelChairService();
                List<Mst_Wheel_Chair> mstWheelChairData = JsonConvert.DeserializeObject<List<Mst_Wheel_Chair>>(strMessage);

                if (mstWheelChairData.Count > 0)
                {
                    bool mstWheelChairIsClearSuccess = mstWheelChairService.ClearAllDataAsync().Result;
                    if (mstWheelChairIsClearSuccess)
                    {
                        mstWheelChairService.AddRangeAsync(mstWheelChairData);
                    }
                }
            }
        }

        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// Sync master data of device set info default
        /// </summary>
        /// <param name="strMessage">受信メッセージ</param>
        //----------------------------------------------------------------------------------------------------
        private void syncMasterDataDeviceSetInfoDefault(String strMessage)
        {
            if (String.IsNullOrEmpty(strMessage) == false)
            {
                IMstDeviceSetInfoDefaultService mstDeviceSetInfoDefaultService = new MstDeviceSetInfoDefaultService();
                List<Mst_device_set_info_default> mstDeciveSetInfoData = JsonConvert.DeserializeObject<List<Mst_device_set_info_default>>(strMessage);

                if (mstDeciveSetInfoData.Count > 0)
                {
                    bool mstDeciveSetInfoIsClearSuccess = mstDeviceSetInfoDefaultService.ClearAllDataAsync().Result;
                    if (mstDeciveSetInfoIsClearSuccess)
                    {
                        mstDeviceSetInfoDefaultService.AddRangeAsync(mstDeciveSetInfoData);
                    }
                }
            }
        }

        private void InitialMasterData()
        {
            Dictionary<string, string> tables = new Dictionary<string, string>();
            tables.Add(GET_MST_BED_INFO_URI, "mst_bed");
            tables.Add(GET_MST_WHEEL_CHAIR_INFO_URI, "mst_wheel_chair");
            tables.Add(GET_MST_DEVICE_SET_INFO_URI, "mst_device_set_info_default");
            List<Task> tasks = new List<Task>();
            foreach (var item in tables)
            {
                var t = new Task(() =>
                {
                    String strUri = String.Format("{0}{1}{2}?_={3}"
                            , NKKWebAccess.BaseUri
                            , NKKWeightInformation.WEB_APP_URI
                            , item.Key
                            , DateTime.Now.Ticks);

                    String strbody = String.Format("{{\"table\":\"{0}\", \"facilityCd\": \"{1}\"}}", item.Value, NKKWebAccess.FacilityCd); ;
                    NKKWebAccessResponse res = NKKWebAccess.Post("体重計接続状態取得", strUri, strbody).Result;
                    if (res.response.IsSuccessStatusCode == true)
                    {
                        String strstate = res.strContent;
                        // JSON分解
                        Dictionary<String, String> json = NKKWebAccess.GetJsonData(strbody);
                        // カード書き込み内容
                        if (json.ContainsKey("table") == true)
                        {
                            String strtable = json["table"];
                            if (strtable.EndsWith("mst_bed"))
                            {
                                syncMasterDataBed(strstate);
                            }
                            else if (strtable.EndsWith("mst_wheel_chair"))
                            {
                                syncMasterDataWheelChair(strstate);
                            }
                            else if (strtable.EndsWith("mst_device_set_info_default"))
                            {
                                syncMasterDataDeviceSetInfoDefault(strstate);
                            }
                        }
                    }
                });
                tasks.Add(t);
                t.Start();
            }
            Task.WaitAll(tasks.ToArray());
        }

        // #10833 2024.08.08 del 不要な処理削除 TDC米沢 start
        //// add #7189 【デグレ】条件送信時、サーマルプリンターで印字されない 王永吉 start
        //// 印刷処理を呼び出す
        //public static void getWeightNewNo()
        //{
        //    String strUri = String.Format("{0}{1}{2}?_={3}"
        //                , NKKWebAccess.BaseUri
        //                , NKKWeightInformation.WEB_APP_URI
        //                , "/api/weight_state/print"
        //                , DateTime.Now.Ticks);
        //    String strbody = String.Format("{{\"weightCd\":{0}, \"facilityCd\":\"{1}\", \"weightNo\":{2}}}"
        //        , NKKWeightInformation.WeightCd
        //        , NKKWebAccess.FacilityCd
        //        , NKKWeightInformation.WeightNo
        //    );
        //    NKKWebAccessResponse res = NKKWebAccess.Post("体重計測定管理番号取得", strUri, strbody).Result;
        //    doCheck = true;
        //}
        //// 印刷処理前にステータスチェック
        //public static bool postPrintFalg()
        //{
        //    String strstate = String.Empty;
        //    String toMessage = "";
        //    if (doCheck)
        //    {
        //        toMessage = "体重計接続状態通知";
        //    }
        //    else
        //    {
        //        toMessage = "体重計接続状態通知+&&#false";
        //    }

        //    String strUri = String.Format("{0}{1}{2}?_={3}"
        //                , NKKWebAccess.BaseUri
        //                , NKKWeightInformation.WEB_APP_URI
        //                , "/api/weight_state/print_falg"
        //                , DateTime.Now.Ticks);
        //    NKKWebAccessResponse res = NKKWebAccess.Get(toMessage, strUri).Result;
        //    strstate = res.strContent;

        //    if (String.IsNullOrEmpty(strstate) == false)
        //    {
        //        Dictionary<String, String> printtbl = NKKWebAccess.GetJsonData(strstate);
        //        if (printtbl.ContainsKey("websocket_send_responce") == true)
        //        {
        //            String strwork = printtbl["websocket_send_responce"];
        //            if ("true".Equals(strwork))
        //            {
        //                doInFlag = true;
        //            }
        //            else
        //            {
        //                doInFlag = false;
        //            }
        //        }
        //    }
        //    doCheck = false;
        //    return doInFlag;
        //}
        //public static String getWriteCard()
        //{
        //    String strUri = String.Format("{0}{1}{2}?_={3}"
        //                , NKKWebAccess.BaseUri
        //                , NKKWeightInformation.WEB_APP_URI
        //                , "/api/weight_state/write_card"
        //                , DateTime.Now.Ticks);
        //    String strbody = String.Format("{{\"weightCd\":{0}, \"facilityCd\":\"{1}\", \"weightNo\":{2}}}"
        //        , NKKWeightInformation.WeightCd
        //        , NKKWebAccess.FacilityCd
        //        , NKKWeightInformation.WeightNo
        //    );
        //    NKKWebAccessResponse res = NKKWebAccess.Put("カード書き込み取得", strUri, strbody).Result;

        //    return " ";
        //}
        //// add #7189 【デグレ】条件送信時、サーマルプリンターで印字されない 王永吉 end
        // #10833 2024.08.08 del 不要な処理削除 TDC米沢 end

        // #12738 mod 2026.06.08 体重計マスタの設定変更通知に対応する TDC米沢 start
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// Felica使用設定
        /// </summary>
        /// <param name="strUse">使用有無["1"：使用/else：未使用]</param>
        //----------------------------------------------------------------------------------------------------
        private void FelicaUsageSetting(String strUse)
       {
            // 使用状態判定
            if (strUse == "1")
            {
                // カード使用

                // 動作中判定
                if (!this.m_Felica.IsRunning)
                {
                    // 未動作

                    // NKKFalica：処理開始
                    this.m_Felica.Start();

                    // ログ記録：処理開始成功
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "NKKFalica処理開始");
                }

                // ログ記録
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "NKKFalica動作中");
            }
            else
            {
                // カード未使用

                // 動作中判定
                if (this.m_Felica.IsRunning)
                {
                    // 動作中

                    // NKKFalica：処理終了
                    this.m_Felica.Stop();

                    // 処理終了成功
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "NKKFalica処理終了");
                }

                // ログ記録：Felica未使用
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "NKKFalica未使用");
            }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// プリンター使用可能チェック
        /// </summary>
        /// <param name="strPrintername">プリンターコード["0"～"2"]</param>
        //----------------------------------------------------------------------------------------------------
        private void CheckPrinter(String strCd)
        {
            // プリンター名設定
            switch (strCd)
            {
                case "0":   // TM-88Ⅳ
                case "1":   // TM-L90
                    NKKWeightInformation.PrinterName = NKKPrinter.PRINTER_NAME;
                    break;

                case "2":   // KIOSK
                    NKKWeightInformation.PrinterName = NKKPrinter.PRINTER_NAME_KIOSK;
                    break;

                default:    // 不明
                    NKKWeightInformation.PrinterName = "プリンタ未設定";
                    break;
            }

            // プリンタの登録チェック
            String strlog = String.Empty;
            String strlog2 = "未接続";
            String strPrintStatusHex = String.Empty;
            NKKLogging.LOGGING_CLASS logKind = NKKLogging.LOGGING_CLASS.ERROR;
            if (NKKPrinter.IsPrinterExist(NKKWeightInformation.PrinterName) == true)
            {
                // 登録あり

                strlog2 = "使用不可";

                // プリンター状態を取得
                try
                {
                    NKKPrinter.PRINTER_INFO_2 prtinfo;
                    prtinfo = NKKPrinter.GetPrinterInfo(NKKWeightInformation.PrinterName);
                    strPrintStatusHex = prtinfo.Status.ToString("X8");
                    // プリンターオフライン：128[0x80]、利用不可：4096[0x1000]
                    if (((prtinfo.Status & (uint)0x80) != (uint)0x80
                       && (prtinfo.Status & (uint)0x1000) != (uint)0x1000))
                    {
                        strlog2 = "使用可";
                        logKind = NKKLogging.LOGGING_CLASS.INFO;
                    }
                }
                catch (Exception ex)
                {
                    //　プリンター状態取得失敗
                    this.Error = ex;
                }
            }

            // 
            strlog = String.Format("プリンタ{0}, ( {1} ),{2}", strlog2, strPrintStatusHex, NKKWeightInformation.PrinterName);

            // ログ記録
            this.AddLogInfo(DateTime.Now, logKind, strlog);

            // GUI
            this.SendLogMessageToGUI("PRINTER", strlog2, DateTime.Now, NKKWeightInformation.PrinterName + String.Format(",( {0} )", strPrintStatusHex));
        }
        //----------------------------------------------------------------------------------------------------
        // #12738 mod 2026.06.08 体重計マスタの設定変更通知に対応する TDC米沢 end

    }
    //----------------------------------------------------------------------------------------------------

#endregion
}
//----------------------------------------------------------------------------------------------------
