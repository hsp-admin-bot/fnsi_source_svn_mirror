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
//  名前空間:NKKWebSocketLib
//----------------------------------------------------------------------------------------------------
using NKKWebSocketLib;
using System.Runtime.InteropServices;
using System.Linq;
using System.Text.RegularExpressions;
using NKKCommon;
// add #9728,9601 start
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
// add #9728,9601 end
using PdfiumViewer;
//----------------------------------------------------------------------------------------------------
//  名前空間:NKKWeightLib
//----------------------------------------------------------------------------------------------------
namespace NKKPrintServer
{

    /// <summary>
    /// 印刷サーバーアプリ メイン処理クラス
    /// </summary>
    public class NKKPrint
    {

        /// <summary>
        /// WebSocketのID
        /// </summary>
        private const string StrWebSocketId = "PRINTS";
        /// <summary>
        /// The printer driver supports the Microsoft XPS format described
        /// </summary>
        public const int PRINTER_DRIVER_XPS = 0x00000002;
        /// <summary>
        /// The printer driver is intended for use with fax printers.
        /// </summary>
        public const int PRINTER_DRIVER_CATEGORY_FAX = 0x00000040;
        /// <summary>
        /// The printer driver is intended for use with file printers.
        /// </summary>
        public const int PRINTER_DRIVER_CATEGORY_FILE = 0x00000080;
        /// <summary>
        /// The printer driver is intended for use with virtual printers.
        /// </summary>
        public const int PRINTER_DRIVER_CATEGORY_VIRTUAL = 0x00000100;

        #region プライベート定義

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サービス名称
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly string SERVICE_NAME = System.Reflection.Assembly.GetExecutingAssembly().GetName().Name;

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ログファイル識別子
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        // mod #9696 アプリケーションログのパスとファイル名の修正。 limingzhe start
        private readonly string LOG_FILE_EXT = "Print";
        // mod #9696 アプリケーションログのパスとファイル名の修正。 limingzhe end
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 設定ファイル名
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly string CONFIG_FILE_NAME = "NKKPrint.config";

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 設定ファイル内共通設定セッション識別子
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly string CONFIG_COMMON_SECTION = "Settings\\Common";

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 設定ファイル内WebSocket設定セッション識別子
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly string CONFIG_WEBSOCKET_SECTION = "Settings\\WebSocket";

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 設定ファイル内ログ設定セッション識別子
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly string CONFIG_LOG_SECTION = "Settings\\Log";

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 設定ファイル内GUI設定セッション識別子
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly string CONFIG_GUI_SECTION = "Settings\\Tool";

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 設定ファイル内アプリケーション設定セッション識別子
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly string CONFIG_APPLICATION_SECTION = "Settings\\Application";

        // add 2020-11-19 No.321:印刷後にダウンロードした帳票PDFを削除していないために、ローカルストレージを圧迫する。 孫 start
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 設定ファイル内帳票PDFファイル設定セッション識別子
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly string CONFIG_PDF_SECTION = "Settings\\PdfFile";
        // add 2020-11-19 No.321:印刷後にダウンロードした帳票PDFを削除していないために、ローカルストレージを圧迫する。 孫 end

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ダウンロードZIPファイルの解凍パスワード
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly string DOWNLOAD_FILE_PASSWORD = "nkk";

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 直前で発生したエラーオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private Exception m_Exception = null;

        /// <summary>
        /// アップデート実施時刻 既定値02:00
        /// </summary>
        private string m_strCheckUpdateTime = "02:00";

        // add 2020-11-19 No.321:印刷後にダウンロードした帳票PDFを削除していないために、ローカルストレージを圧迫する。 孫 start
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 帳票PDFファイル保持日数[既定：20日]
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly int m_nPdfFileKeepNumberDays = 20;

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 帳票PDFファイルの保存先
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private string m_strPdfFileFolder = string.Empty;
        // add 2020-11-19 No.321:印刷後にダウンロードした帳票PDFを削除していないために、ローカルストレージを圧迫する。 孫 end

        /// <summary>
        /// ログアップローダーオブジェクト
        /// </summary>
        private NKKCommon.NKKLogUploader m_LogUploader = new NKKCommon.NKKLogUploader();

        /// <summary>
        /// ログアップロード実施間隔
        /// </summary>
        private TimeSpan m_LogUploadCycle;

        /// <summary>
        /// 前回ログファイルアップロード日時
        /// </summary>
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
        private readonly string m_strGUIIPAddressOnly = string.Empty;

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
        private readonly Dictionary<string, string> m_GUIInformation = new Dictionary<string, string>();

        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 不要ログ削除実施日付
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private DateTime dtDeleteDate = DateTime.Now.Date;

        /// <summary>
        /// 表示用プリンター名に付加するサフィックス.無しの場合、プリンター名と表示用プリンター名は同一で登録される
        /// </summary>
        private string PrinterNameSuffix;

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// スレッド終了用シグナル
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly ManualResetEvent m_evFinish = new ManualResetEvent(false);

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
        private readonly NKKWebSocket m_WebSocket = new NKKWebSocket(StrWebSocketId);

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// Felicaカードリーダーオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly NKKWeightLib.NKKFalica m_Felica = new NKKWeightLib.NKKFalica();

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 体重計クラスオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly NKKWeightLib.NKKWeightScale m_WeightScale = new NKKWeightLib.NKKWeightScale();

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// レシートプリンタクラスオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly NKKWeightLib.NKKPrinter m_Printer = new NKKWeightLib.NKKPrinter();

        //----------------------------------------------------------------------------------------------------

        // add 2020-09-29 FNSI-仕様追加 印刷アプリを複数登録する 夏 start
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// GUI用クライアントソケット接続/切断時List
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private List<MstPrinterData> wList = new List<MstPrinterData>();
        // add 2020-09-29 FNSI-仕様追加 印刷アプリを複数登録する 夏 end

        #endregion プライベート定義

        #region コンストラクタ

        /// <summary>
        /// コンストラクタ
        /// </summary>
        /// <param name="strFolder">設定ファイル格納先フォルダ名</param>
        public NKKPrint(string strFolder)
        {
            try
            {

                // 設定ファイル名作成
                string strfile = strFolder;
                if (strfile.EndsWith("\\") == false)
                {
                    strfile += "\\";
                }
                strfile += this.CONFIG_FILE_NAME;

                // mod #9696 アプリケーションログのパスとファイル名の修正。 limingzhe start
                // ログ設定
                var log = NKKLogging.GetInstance();
                // 識別子
                log.LogExt = $"{this.LOG_FILE_EXT}_{System.Net.Dns.GetHostName()}";
                // mod #9696 アプリケーションログのパスとファイル名の修正。 limingzhe end

                // システム共通設定クラス初期化
                var sys = SystemSettingInfo.GetInstance();
                if (sys.Load(strfile) == false)
                {
                    // 設定読み込み失敗

                    throw (new Exception(String.Format("Config,{0}", SystemSettingInfo.GetInstance().Error.ToString())));
                }

                // 印刷サーバーアプリ番号
                NKKWeightLib.NKKWeightInformation.WeightNo = sys.GetSingleLineValue(this.CONFIG_APPLICATION_SECTION, "AppNo", "1").Trim();

                // ログ設定
                // mod #9696 アプリケーションログのパスとファイル名の修正。 limingzhe start
                //var log = NKKLogging.GetInstance();
                // mod #9696 アプリケーションログのパスとファイル名の修正。 limingzhe end
                // 識別子
                // mod #9696 アプリケーションログのパスとファイル名の修正。 donghao start
                //log.LogExt = $"{this.LOG_FILE_EXT}_{NKKWeightLib.NKKWeightInformation.WeightNo}";
                log.LogExt = $"{this.LOG_FILE_EXT}_{System.Net.Dns.GetHostName()}_{NKKWeightLib.NKKWeightInformation.WeightNo}";
                // mod #9696 アプリケーションログのパスとファイル名の修正。 donghao end

                // バージョン情報記録用処理登録(ログが変わった場合にログの先頭に記録するため)
                log.FirstWriteEvent = VersionInfos.GetVersionInfo;

                // ログ格納先フォルダ
                log.LogFolder = sys.GetSingleLineValue(CONFIG_LOG_SECTION, "Folder", String.Empty).Trim();
                // ログ保持日数[既定：20日]
                if (int.TryParse(sys.GetSingleLineValue(CONFIG_LOG_SECTION, "KeepNumberOfDays", string.Empty).Trim(), out int nwork) && 0 <= nwork)
                {
                    // ログ保持日数
                    this.m_nLogFileKeepNumberDays = nwork;
                }

                // ログ記録：初期化処理開始
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "初期化処理開始");

                // サーバー設定
                NKKWebAccess.UserId = sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "UserId", String.Empty).Trim();
                NKKWebAccess.Password = sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "UserPW", String.Empty).Trim();
                NKKWebAccess.UrlEncodeFacilityHash = sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "FacilityHash", String.Empty).Trim();
                // mod 2022-04-22 #6860 最後のスラッシュを除く Thach start
                NKKWebAccess.BaseUri = sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "BaseUri", String.Empty).Trim(' ', '/');
                // mod 2022-04-22 #6860 最後のスラッシュを除く Thach end
                // add 2021-03-25 クライアント証明書検索キーを追加 孫 start
                NKKWebAccess.ClientCertificateSearchValue1 = sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "ClientCertificateSearchValue1", String.Empty).Trim();
                NKKWebAccess.ClientCertificateSearchValue2 = sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "ClientCertificateSearchValue2", String.Empty).Trim();
                // add 2021-03-25 クライアント証明書検索キーを追加 孫 end

                // 最新ファイルダウンロード先フォルダ
                DownloadSourceFolder = sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "DownloadFolder", string.Empty).Trim();

                // add オンプレでの自己アップデートに対応 孫 start
                // 最新ファイル取得先ファイル名
                DownloadSourceFileName = sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "DownloadFileName", "NKKPrintServer.zip").Trim();
                // add オンプレでの自己アップデートに対応 孫 end

                // 印刷サーバーアプリ番号
                log.DeviceNo = NKKWeightLib.NKKWeightInformation.WeightNo;
                // ログ記録：印刷サーバーアプリ番号
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, $"印刷サーバーアプリ番号:{NKKWeightLib.NKKWeightInformation.WeightNo}");
                // アップデート実施日時
                this.m_strCheckUpdateTime = sys.GetSingleLineValue(this.CONFIG_APPLICATION_SECTION, "UpdateTime", this.m_strCheckUpdateTime).Trim();
                if (this.UpdateDateTime == DateTime.MaxValue)
                {
                    // ログ記録：設定無効
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "設定されているアップデート時刻が無効, 設定値：" + this.m_strCheckUpdateTime);
                }

                // ログアップロード実施日時
                var m_strLogUploadCycle = sys.GetSingleLineValue(this.CONFIG_APPLICATION_SECTION, "LogUploadTime", "01:00").Trim();
                try
                {
                    this.m_LogUploadCycle = DateTime.ParseExact(m_strLogUploadCycle, "HH:mm", System.Globalization.DateTimeFormatInfo.InvariantInfo, System.Globalization.DateTimeStyles.None).TimeOfDay;
                }
                catch (Exception ex)
                {
                    // ログ記録：設定無効
                    Debug.Print(ex.ToString());
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "設定されているログアップロード時刻が無効, 設定値：" + m_strLogUploadCycle);
                    this.m_LogUploadCycle = TimeSpan.MaxValue;
                }

                // 表示用プリンター名 接尾語
                PrinterNameSuffix = sys.GetSingleLineValue(CONFIG_APPLICATION_SECTION, "PrinterNameSuffix", "").Trim();

                // WebSocket

                // 識別子番号(印刷サーバーアプリ番号)
                m_WebSocket.IdentityNo = NKKWeightLib.NKKWeightInformation.WeightNo;

                // URI
                m_WebSocket.Uri = sys.GetSingleLineValue(CONFIG_WEBSOCKET_SECTION, "URI", string.Empty).Trim();
                // KeepAlive間隔
                if (uint.TryParse(sys.GetSingleLineValue(CONFIG_WEBSOCKET_SECTION, "KeepAlive", string.Empty).Trim(), out uint keepalive) && 0 < keepalive)
                {
                    m_WebSocket.KeepAlive = keepalive;
                }

                // GUI用待受IPアドレス制限
                this.m_strGUIIPAddressOnly = sys.GetSingleLineValue(CONFIG_GUI_SECTION, "IPAddress", String.Empty).Trim();
                // GUI用待受ポート番号
                if (int.TryParse(sys.GetSingleLineValue(CONFIG_GUI_SECTION, "PortNo", string.Empty).Trim(), out nwork) && 0 < nwork)
                {
                    this.m_nGUISocketPortNo = nwork;
                }

                // add 2020-11-19 No.321:印刷後にダウンロードした帳票PDFを削除していないために、ローカルストレージを圧迫する。 孫 start
                // 帳票PDFファイルの格納先フォルダ
                PdfFolder = sys.GetSingleLineValue(CONFIG_PDF_SECTION, "Folder", String.Empty).Trim();
                // 帳票PDFファイル保持日数[既定：20日]
                if (int.TryParse(sys.GetSingleLineValue(CONFIG_PDF_SECTION, "KeepNumberOfDays", string.Empty).Trim(), out int npdf_work) && 0 <= npdf_work)
                {
                    // 帳票PDFファイル保持日数
                    this.m_nPdfFileKeepNumberDays = npdf_work;
                }
                // add 2020-11-19 No.321:印刷後にダウンロードした帳票PDFを削除していないために、ローカルストレージを圧迫する。 孫 end

                // クライアント接続時
                this.m_GUISocketServer.ClientConnectedHandler = this.ClientConnected;
                this.m_GUISocketServer.DebugMode = 2;

                // GUI通知用関数登録
                this.m_WebSocket.SendMessageToGUIHandler = this.SendLogMessageToGUI;
                // 受信用関数登録
                this.m_WebSocket.ReceiveMessage = this.WebSocketReceiveMessageAsync;

                // GUI通知用関数登録
                NKKWebAccess.SendMessageHandler = this.SendLogMessageToGUI;

                // GUI通知用関数登録
                this.m_WeightScale.SendMessageToGUIHandler = this.SendLogMessageToGUI;

                // GUI通知用関数登録
                this.m_Felica.SendMessageToGUIHandler = this.SendLogMessageToGUI;

                // GUI通知関数登録
                this.m_Printer.SendMessageToGUIHandler = this.SendLogMessageToGUI;

                // スレッド構築
                this.m_Thread = new Thread(this.DoWork)
                {
                    Name = "NKKWeight処理スレッド",
                    IsBackground = false
                };

                // ログ記録：初期化処理終了
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "初期化処理終了");

            }
            catch (Exception ex)
            {
                // ログ記録：エラー
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, string.Format("初期化処理,{0}", ex.Message));
            }
        }

        #endregion

        /// <summary>
        /// デストラクタ
        /// </summary>
        ~NKKPrint()
        {
            if (this.m_Thread != null)
            {
                // スレッド停止
                this.m_evFinish.Set();
            }
        }

        #region パブリックプロパティ

        /// <summary>
        /// 直前に発生したエラーオブジェクト取得/設定用プロパティ
        /// </summary>
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
                    String strlogdata = String.Format("{0}", this.GetType().Name);

                    // 履歴作成
                    strlogdata += String.Format("{0}", value.ToString().Replace("\r\n", "{CRLF}"));

                    // 履歴に追記
                    this.AddLogInfo(dtlog, NKKLogging.LOGGING_CLASS.ERROR, strlogdata);
#if DEBUG
                    Debug.WriteLine(this.SERVICE_NAME + " " + strlogdata);
#endif
                }
            }
        }

        /// <summary>
        /// アップデート実施日時(例.今日の午前2時)参照用プロパティ
        /// </summary>
        private DateTime UpdateDateTime
        {
            get
            {
                DateTime ret = DateTime.MaxValue;
                try
                {

                    string strwork = DateTime.Now.Date.ToString("yyyy/MM/dd ") + this.m_strCheckUpdateTime;
                    ret = DateTime.ParseExact(
                        strwork,
                        "yyyy/MM/dd HH:mm",
                        System.Globalization.DateTimeFormatInfo.InvariantInfo,
                        System.Globalization.DateTimeStyles.None);
                }
                catch (Exception ex)
                {
                    Debug.Print(ex.ToString());
                }
                return ret;
            }
        }

        /// <summary>
        /// ログ保持日数参照用プロパティ
        /// </summary>
        public int LogFileKeepNumberDays
        {
            get { return (this.m_nLogFileKeepNumberDays); }
        }

        /// <summary>
        /// ログアップロード実施日時設定。次回ログファイルをアップロードする日時。
        /// </summary>
        public DateTime LogUploadDateTime
        {
            get
            {
                DateTime ret = DateTime.MaxValue;
                try
                {
                    // 実施時刻(起動/前回実施日時 + 設定時間)
                    // m_dtLogUpload: 前回アップロード日時
                    // m_LogUploadCycle: ログアップロード実施間隔(文字列)
                    ret = this.m_dtLogUpload + this.m_LogUploadCycle;

                }
                catch (Exception ex)
                {
                    Debug.Print(ex.ToString());
                }
                return ret;
            }
        }

        /// <summary>
        /// 最新ファイルダウンロード先フォルダ
        /// </summary>
        private string DownloadSourceFolder { get; set; }

        // add オンプレでの自己アップデートに対応 孫 start
        /// <summary>
        /// 最新ファイル取得先ファイル名
        /// </summary>
        private string DownloadSourceFileName { get; set; }
        // add オンプレでの自己アップデートに対応 孫 end

        #endregion パブリックプロパティ

        #region パブリックメソッド

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 初期化処理
        /// </summary>
        /// <returns></returns>
        //----------------------------------------------------------------------------------------------------
        public bool Init()
        {
            bool bret = true;

            try
            {
                //
            }
            catch (Exception ex)
            {
                Debug.WriteLine(ex.Message);
            }

            return (bret);
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 処理開始
        /// </summary>
        /// <returns></returns>
        //----------------------------------------------------------------------------------------------------
        public bool Start()
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

                    bret = false;

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
            catch (Exception ex)
            {

                bret = false;

                // ログ記録：エラー
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, string.Format("Start処理,{0}", ex.Message));
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
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "NKKWeightScale処理終了");
                }

                // NKKFalica
                if (this.m_Felica != null)
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

                // add 2020-11-19 No.321:印刷後にダウンロードした帳票PDFを削除していないために、ローカルストレージを圧迫する。 孫 start
                // 指定日以前の帳票PDFファイルを削除する
                this.DeletePdfFiles();
                // add 2020-11-19 No.321:印刷後にダウンロードした帳票PDFを削除していないために、ローカルストレージを圧迫する。 孫 end


                // ログ記録：Stop処理終了
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "Stop処理終了");
            }
            catch (Exception ex)
            {
                // ログ記録：エラー
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("Stop処理,{0}", ex.Message));
            }
        }

        //----------------------------------------------------------------------------------------------------

        #endregion パブリックメソッド

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
            var log = NKKLogging.GetInstance();

            // ログ記録
            log.AddLogInfo(dtNow, this.SERVICE_NAME, LoggingClass, strMesssage);
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

            // ログ記録するローカル関数
            void addLogInfo(NKKLogging.LOGGING_CLASS LoggingClass, string strMesssage)
            {
                // ログ記録
                this.AddLogInfo(DateTime.Now, LoggingClass, strMesssage);
            }
            var updater = new NKKCommon.Updater
            {
                SystemDefineVersionNo = 9,
                ProcType = 0,
                // mod オンプレでの自己アップデートに対応 孫 start
                // DownloadFileName = "NKKPrintServer.zip",
                DownloadFileName = DownloadSourceFileName,
                // mod オンプレでの自己アップデートに対応 孫 end
                Bucket = DownloadSourceFolder,
                DownloadFilePassword = DOWNLOAD_FILE_PASSWORD,
                LoggingMethod = addLogInfo
            };

            // ローカル関数: 新しいバージョンが公開されていたら、Amazon S3から取得する
            void checkUpdate()
            {
                // 新しいバージョンが公開されていたら、Amazon S3から取得する
                if (updater.IsPublishedNewVersion(System.Reflection.Assembly.GetExecutingAssembly())
                    && updater.GetLatestProgramFile())
                {

                    // 最新のプログラムファイルの取得に成功

                    // GUIツール[NKKWeightTool.exe]を終了
                    try
                    {
                        this.m_GUISocketServer.AllSend(NKKWeightLib.NKKWeightInformation.Encoding.GetBytes("EXIT"));
                        string taskkill = System.IO.Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.System), "taskkill.exe");

                        //
                        Process[] ps = Process.GetProcessesByName("FNWSiPrintServerTool");
                        foreach (Process p in ps)
                        {
                            // ログ記録：GUIツール終了
                            this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, string.Format("GUIツールを強制終了, プロセス名:{0}, プロセスID:{1}", p.ProcessName, p.Id));

                            //
                            using (var killproc = new Process())
                            {
                                killproc.StartInfo.Verb = "RunAs";
                                killproc.StartInfo.FileName = taskkill;
                                killproc.StartInfo.Arguments = string.Format("/PID {0} /T /F", p.Id);
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

                    // 自己アップデート
                    updater.AppUpdate();

                }

            }

            var lastCheckDate = DateTime.Now;

            while (true)
            {
                try
                {
                    // 初回処理
                    if (bFirst == true)
                    {
                        // 初回処理が終わっていない場合

                        // 現在ログインしていなければログイン処理
                        if (NKKWebAccess.Login == false && "1" == NKKWebAccess.ServerLogin("").Result.strContent)
                        {
                            // ログイン完了

                            // 施設コード
                            NKKLogging.GetInstance().FacilityCd = NKKWebAccess.FacilityCd;

                            // ログ記録：施設コード
                            this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, $"施設コード:{NKKWebAccess.FacilityCd}");

                            // NKKWebSocket：処理開始
                            this.m_WebSocket.Start();

                            // ログ記録：処理開始成功
                            this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "NKKWebSocket処理開始");

                        }

                        // ログイン判定
                        if (NKKWebAccess.Login == true)
                        {
                            // ログイン済み

                            // add mongodbに転載、サーバー起動ログ 黄 start
                            LogManagement.LogMessage = "印刷サーバーアプリが起動しました。";
                            LogManagement.SetLogingProperties();
                            // add mongodbに転載、サーバー起動ログ 黄 end

                            // ログアップロード
                            this.m_LogUploader.UploadLog(this.GetType().Name);

                            // add 2020-09-29 FNSI-仕様追加 印刷アプリを複数登録する 夏 start
                            string suffix = this.PrinterNameSuffix;

                            wList = CreateMstPrinterDatas(suffix, this);

                            // JSON データ生成
                            var wJsonData = LayoutDesigner.RldJsonDataSerializeHelper<List<MstPrinterData>>.Serialize(wList);
                            // 新規追加の場合は POST 処理
                            NKKWebAccessResponse wRestRet = null;
                            wRestRet = NKKWebAccess.Post("プリンターマスタデータ削除", NKKWebAccess.BaseUri + "/ntss-admin-web/api/printers/printDel/" + StrWebSocketId + m_WebSocket.IdentityNo.PadLeft(2, '0'), wJsonData).Result;
                            if (wRestRet.response.IsSuccessStatusCode == true)
                            {
                                // ログ記録：処理開始成功
                                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "印刷サーバーPCに登録されていないプリンターをプリンターマスタテーブルから削除しました。");
                            }
                            // add 2020-09-29 FNSI-仕様追加 印刷アプリを複数登録する 夏 end

                            // 自動更新チェック
                            checkUpdate();

                            // 初回処理終了
                            bFirst = false;

                        }

                    }

                    // ログ削除(日が変化した場合に実行)
                    if (this.dtDeleteDate != DateTime.Now.Date)
                    {
                        // スレッドにてログ削除を行う
                        var trd = new Thread(this.DeleteLogFiles)
                        {
                            Name = "ログ削除スレッド"
                        };
                        trd.Start();

                        // add 2020-11-19 No.321:印刷後にダウンロードした帳票PDFを削除していないために、ローカルストレージを圧迫する。 孫 start
                        // 指定日以前の帳票PDFファイルを削除する
                        var trdPdf = new Thread(this.DeletePdfFiles)
                        {
                            Name = "PDF削除スレッド"
                        };
                        trdPdf.Start();
                        // add 2020-11-19 No.321:印刷後にダウンロードした帳票PDFを削除していないために、ローカルストレージを圧迫する。 孫 end

                        // 不要ログ削除実施日付再設定
                        this.dtDeleteDate = DateTime.Now.Date;
                    }

                    // 設定時刻による更新確認
                    // 実施日時日時判定
                    // UpdateDateTimeは本日の設定日時を取得するためのプロパティ
                    if ((this.UpdateDateTime <= DateTime.Now) && (lastCheckDate < this.UpdateDateTime))
                    {
                        // 「現在時刻が設定されたアップデート確認時刻以降」
                        // かつ
                        // 「最後にアップデート確認したのは設定されたアップデート確認時刻より前」

                        // ログ記録：処理開始成功
                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "設定時刻による更新確認, " + this.m_strCheckUpdateTime);

                        // 実施日時保持
                        lastCheckDate = DateTime.Now;

                        // 更新確認
                        checkUpdate();

                    }

                    // 設定時間によるログアップロード
                    if ((this.LogUploadDateTime <= DateTime.Now) && (this.m_dtLogUpload < this.LogUploadDateTime))
                    {
                        // 「現在時刻が次回ログファイルアップロード設定日時以降」かつ「前回ログファイルアップロード日時が次回ログファイルアップロード設定日時より前」

                        // ログ記録：処理開始成功
                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, $"設定時刻によるログアップロード, {m_LogUploadCycle}");

                        // 実施日時保持
                        this.m_dtLogUpload = DateTime.Now;

                        // ログアップロード
                        this.m_LogUploader.UploadLog(this.GetType().Name);
                    }

                    // 60秒間、又はシグナル待ち
                    if (this.m_evFinish.WaitOne(60 * 1000) == true)
                    {
                        // スレッド終了
                        break;
                    }
                }
                catch (Exception ex)
                {
                    this.Error = ex;
                    bFirst = false;
                }
            };
        }

        /// <summary>
        /// 指定日以前のログファイルを削除
        /// </summary>
        private void DeleteLogFiles()
        {
            // ログオブジェクト取得
            var log = NKKLogging.GetInstance();

            // ログ削除
            log.DeleteLogFiles(this.SERVICE_NAME, this.m_nLogFileKeepNumberDays, true);
        }

        // add 2020-11-19 No.321:印刷後にダウンロードした帳票PDFを削除していないために、ローカルストレージを圧迫する。 孫 start
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 帳票PDFファイル格納先フォルダの参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public String PdfFolder
        {
            get { return (this.m_strPdfFileFolder); }
            set
            {
                String strfolder = value;

                // 帳票PDF保存先フォルダの指定チェック
                if (String.IsNullOrEmpty(strfolder) == true)
                {
                    // 未指定

                    // 未指定の場合は実行ファイルの格納先\LOGフォルダとする
                    //strfolder = Application.StartupPath;
                    strfolder = AppDomain.CurrentDomain.BaseDirectory;
                    strfolder += "\\PDF";
                }

                // 末尾の\付加
                if (strfolder.EndsWith("\\") == false)
                    strfolder += "\\";

                // 帳票PDF格納先が存在しない場合、パスを作成します。
                if (!System.IO.Directory.Exists(strfolder))
                {
                    try
                    {
                        System.IO.Directory.CreateDirectory(strfolder);
                    }
                    catch(Exception ex)
                    {
                        // ログ記録
                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("DeletePdfFiles(),Failed to create path:{0},{1}", strfolder, ex.ToString()));

                        // 帳票PDFファイル格納先フォルダはベースディレクトリを設定する
                        strfolder = AppDomain.CurrentDomain.BaseDirectory;
                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("DeletePdfFiles(),Using path:{0}", strfolder));
                    }
                }

                // 帳票PDFファイル保存先を設定する             
                this.m_strPdfFileFolder = strfolder;
            }
        }

        /// <summary>
        /// 指定日以前の帳票PDFファイルを削除する
        /// </summary>
        private void DeletePdfFiles()
        {
            const String strSearchPattern = ".*(\\d{6}|\\d{7}|\\d{8})*.(PDF|pdf)$";

            try
            {
                // 保持するログファイルの日数が1以上の場合
                if (0 < m_nPdfFileKeepNumberDays)
                {
                    int ndelcount = 0;
                    String strfilename;

                    // 削除対象基準日時を作成
                    DateTime dtdelbase = DateTime.Now.AddDays(-1 * m_nPdfFileKeepNumberDays);

                    // 正規表現によるファイル名マッチングパターン登録
                    Regex reg = new Regex(strSearchPattern, RegexOptions.IgnoreCase);

                    // PDFファイル格納先に格納されているファイルを全て取得する
                    String[] pdffiles = System.IO.Directory.GetFiles(PdfFolder, "*.*", System.IO.SearchOption.TopDirectoryOnly);
                    foreach (String strfile in pdffiles)
                    {
                        try
                        {
                            // ファイル名(+拡張子)のみ取得
                            strfilename = System.IO.Path.GetFileName(strfile);

                            // ファイル名チェック
                            if (reg.Match(strfilename).Success == true)
                            {
                                // 有効なファイル名の場合

                                // 取得ファイルから更新日時を取得する
                                DateTime dtlastwrite = System.IO.File.GetLastWriteTime(strfile);

                                // 削除基準日時より古い場合
                                if (dtlastwrite < dtdelbase)
                                {
                                    // ファイル削除
                                    System.IO.File.Delete(strfile);

                                    ndelcount++;
                                }
                            }
                        }
                        catch (Exception ex)
                        {
                            // ログ記録
                            this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("DeletePdfFiles(),File:{0},{1}", strfile, ex.ToString()));
                        }
                    }

                    // ログ記録
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("PDFファイル削除,{0:yyyy/MM/dd HH:mm:ss}以前,{1}件削除", dtdelbase, ndelcount));
                }
            }
            catch (Exception ex)
            {
                // ログ記録
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("DeletePdfFiles(),SearchPattern:{0},StorageData:{1},{2}", strSearchPattern, m_nPdfFileKeepNumberDays, ex.ToString()));
            }
        }
        // add 2020-11-19 No.321:印刷後にダウンロードした帳票PDFを削除していないために、ローカルストレージを圧迫する。 孫 end

        /// <summary>
        /// GUIへのメッセージ通知
        /// </summary>
        /// <param name="strServiceName">サービス名</param>
        /// <param name="strStatus">状態</param>
        /// <param name="dtNow">発生日時</param>
        /// <param name="strMessage">送信するメッセージ</param>
        public void SendLogMessageToGUI(string strServiceName, string strStatus, DateTime dtNow, string strMessage)
        {
            // 電文作成
            //string strdata = string.Format("{0}\t{1}\t{2:yyyy/MM/dd HH:mm:ss:ffff}\t{3}\r\n", strServiceName, strStatus, dtNow, strMessage);
            string strdata = $"{strServiceName}\t{strStatus}\t{dtNow:yyyy/MM/dd HH:mm:ss:ffff}\t{strMessage}\r\n";
            // add 2020-09-29 FNSI-仕様追加 印刷アプリを複数登録する 夏 start
            if (!strServiceName.Equals("PRINTERS"))
            {
                // add 2020-09-29 FNSI-仕様追加 印刷アプリを複数登録する 夏 end
                // 保持オブジェクトチェック
                if (m_GUIInformation.ContainsKey(strServiceName) == true)
                {
                    // 該当あり

                    // 更新
                    m_GUIInformation[strServiceName] = strdata;
                }
                else
                {
                    // 該当なし

                    // 新規追加
                    m_GUIInformation.Add(strServiceName, strdata);
                }
                // add 2020-09-29 FNSI-仕様追加 印刷アプリを複数登録する 夏 start
            }
            // add 2020-09-29 FNSI-仕様追加 印刷アプリを複数登録する 夏 end

            // 全クライアントソケットに送信
            byte[] bdata = Encoding.UTF8.GetBytes(strdata);
            m_GUISocketServer.AllSend(bdata);

        }

        /// <summary>
        /// GUI用クライアントソケット接続/切断時
        /// </summary>
        /// <param name="Sender">ベースオブジェクト</param>
        /// <param name="Status">接続状態</param>
        private void ClientConnected(Object Sender, TdcBaseSocket.ConnectionStatus Status)
        {
            // 接続状態判定
            if (Status == TdcBaseSocket.ConnectionStatus.CONNECT)
            {
                // 接続完了時

                if (Sender is TdcBaseSocketServerClient cl)
                {

                    async void onReceivedAsync(object socketSender, byte[] cData, int nRecieveSize)
                    {
                        // add 2020-09-29 FNSI-仕様追加 印刷アプリを複数登録する 黄 start
                        if (nRecieveSize ==1) {                      
                            if (cData[0] == 0)
                            {
                                // add 2020-09-29 FNSI-仕様追加 印刷アプリを複数登録する 黄 end
                                // イベント呼び出し
                                // プリンタ一覧を取得して、RDSに書き込む
                                Debug.WriteLine(nRecieveSize.ToString() + "バイト受信");

                                string suffix = this.PrinterNameSuffix;
                                // mod 2020-09-29 FNSI-仕様追加 印刷アプリを複数登録する 黄 start
                                //List<MstPrinterData> wList = CreateMstPrinterDatas(suffix, this);
                                wList = CreateMstPrinterDatas(suffix, this);
                                // mod 2020-09-29 FNSI-仕様追加 印刷アプリを複数登録する 黄 end
                                // JSON データ生成
                                var wJsonData = LayoutDesigner.RldJsonDataSerializeHelper<List<MstPrinterData>>.Serialize(wList);
                                // 新規追加の場合は POST 処理
                                NKKWebAccessResponse wRestRet = null;
                                wRestRet = await NKKWebAccess.Post("プリンターマスタデータ追加", NKKWebAccess.BaseUri + "/ntss-admin-web/api/printers/" + StrWebSocketId + m_WebSocket.IdentityNo.PadLeft(2, '0'), wJsonData);
                                // add 2020-09-29 FNSI-仕様追加 印刷アプリを複数登録する 黄 start
                            }

                            if (cData[0] == 1)
                            {
                                String strIdmUri = String.Empty;
                                String strstate = String.Empty;
                                strIdmUri = String.Format("{0}{1}{2}{3}?_={4}"
                                    , NKKWebAccess.BaseUri
                                    , "/ntss-admin-web/api/printers"
                                    , "/printer-date"
                                    , "/" + NKKWebAccess.FacilityCd
                                    , DateTime.Now.Ticks);
                                NKKWebAccessResponse wRestRet1 = NKKWebAccess.Get("DBにmst_printer取得", strIdmUri).Result;
                                if (wRestRet1.response.IsSuccessStatusCode == true)
                                {
                                    strstate = wRestRet1.strContent;
                                    String strPrinterName = String.Empty;
                                    string suffix = this.PrinterNameSuffix;
                                    wList = CreateMstPrinterDatas(suffix, this);
                                    for (int i=0;i< wList.Count;i++)
                                    {
                                        if (String.IsNullOrEmpty(strPrinterName))
                                        {
                                            strPrinterName = wList[i].PrinterName;
                                        }
                                        else
                                        {
                                            strPrinterName = strPrinterName + "," + wList[i].PrinterName;
                                        }
                                    }
                                    this.SendLogMessageToGUI("PRINTERS", StrWebSocketId + m_WebSocket.IdentityNo.PadLeft(2, '0')+";"+ strPrinterName, DateTime.Now, strstate);
                                }
                            }
                        }
                        else
                        {
                            String strUri = String.Format("{0}{1}{2}{3}?_={4}"
                            , NKKWebAccess.BaseUri
                            , "/ntss-admin-web/api/printers"
                            , "/clientKey/"
                            , StrWebSocketId + m_WebSocket.IdentityNo.PadLeft(2, '0')
                            , DateTime.Now.Ticks);
                            string strdata = Encoding.UTF8.GetString(cData, 0, nRecieveSize);
                            NKKWebAccessResponse res = NKKWebAccess.Put("DBにmst_printerセット", strUri, strdata).Result;
                            if (res.response.IsSuccessStatusCode == true)
                            {
                                Debug.WriteLine(strdata);
                            }
                        }
                        // add 2020-09-29 FNSI-仕様追加 印刷アプリを複数登録する 黄 end
                    }

                    cl.ReceivedHandler = onReceivedAsync;

                    // 保持情報送信

                    var listvalues = new List<string>();
                    foreach (KeyValuePair<string, string> item in m_GUIInformation)
                    {
                        listvalues.Add(item.Value);
                    }

                    foreach (string item in listvalues)
                    {
                        byte[] bdata = Encoding.UTF8.GetBytes(item);
                        cl.AsyncWrite(bdata);
                    }
                }
            }
        }

        [DllImport("winspool.drv", SetLastError = true, CharSet = CharSet.Unicode)]
        static extern int OpenPrinter(string pPrinterName, out IntPtr phPrinter, IntPtr pDefault);

        [DllImport("winspool.drv", SetLastError = true)]
        static extern int ClosePrinter(IntPtr hPrinter);

        [DllImport("winspool.drv", CharSet = CharSet.Unicode)]
        static extern bool GetPrinterDriver(IntPtr phPrinter,
                                      System.Text.StringBuilder pEnv,
                                      int Level,
                                      [Out] IntPtr pDriverInfo,
                                      int bufferSize,
                                      ref int Bytes);

        /// <summary>
        /// Contains printer driver information.
        /// </summary>
        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
        public struct DRIVER_INFO_8
        {

            /// <summary>
            /// The operating system version for which the driver was written. The supported value is 3.
            /// </summary>
            public uint cVersion;

            /// <summary>
            /// A pointer to a null-terminated string that specifies the name of the driver (for example, QMS 810).
            /// </summary>
            [MarshalAs(UnmanagedType.LPTStr)]
            public string pName;

            /// <summary>
            /// A pointer to a null-terminated string that specifies the environment for which the driver was written (for example, Windows x86, Windows IA64, and Windows x64.
            /// </summary>
            [MarshalAs(UnmanagedType.LPTStr)]
            public string pEnvironment;

            /// <summary>
            /// A pointer to a null-terminated string that specifies a file name or a full path and file name for the file that contains the device driver (for example, C:\DRIVERS\Pscript.dll).
            /// </summary>
            [MarshalAs(UnmanagedType.LPTStr)]
            public string pDriverPath;

            /// <summary>
            /// A pointer to a null-terminated string that specifies a file name or a full path and file name for the file that contains driver data (for example, C:\DRIVERS\Qms810.ppd).
            /// </summary>
            [MarshalAs(UnmanagedType.LPTStr)]
            public string pDataFile;

            /// <summary>
            /// A pointer to a null-terminated string that specifies a file name or a full path and file name for the device driver's configuration dynamic-link library (for example, C:\DRIVERS\Pscrptui.dll).
            /// </summary>
            [MarshalAs(UnmanagedType.LPTStr)]
            public string pConfigFile;

            /// <summary>
            /// A pointer to a null-terminated string that specifies a file name or a full path and file name for the device driver's help file (for example, C:\DRIVERS\Pscrptui.hlp).
            /// </summary>
            [MarshalAs(UnmanagedType.LPTStr)]
            public string pHelpFile;

            /// <summary>
            /// A pointer to a MultiSZ buffer that contains a sequence of null-terminated strings. Each null-terminated string in the buffer contains the name of a file the driver depends on. The sequence of strings is terminated by an empty, zero-length string. If pDependentFiles is not NULL and does not contain any file names, it will point to a buffer that contains two empty strings.
            /// </summary>
            [MarshalAs(UnmanagedType.LPTStr)]
            public string pDependentFiles;

            /// <summary>
            /// A pointer to a null-terminated string that specifies a language monitor (for example, "PJL monitor"). This member can be NULL and should be specified only for printers capable of bidirectional communication.
            /// </summary>
            [MarshalAs(UnmanagedType.LPTStr)]
            public string pMonitorName;

            /// <summary>
            /// A pointer to a null-terminated string that specifies the default data type of the print job (for example, "EMF").
            /// </summary>
            [MarshalAs(UnmanagedType.LPTStr)]
            public string pDefaultDataType;

            /// <summary>
            /// A pointer to a null-terminated string that specifies previous printer driver names that are compatible with this driver. For example, OldName1\0OldName2\0\0.
            /// </summary>
            [MarshalAs(UnmanagedType.LPTStr)]
            public string pszzPreviousNames;

            /// <summary>
            /// The date of the driver package, as coded in the driver files.
            /// </summary>
            [Obsolete]
            private FILETIME ftDriverDate;

            /// <summary>
            /// The version number of the driver. This comes from the version structure of the driver.
            /// </summary>
            ulong dwlDriverVersion;

            /// <summary>
            /// A pointer to a null-terminated string that specifies the manufacturer's name.
            /// </summary>
            [MarshalAs(UnmanagedType.LPTStr)]
            public string pszMfgName;

            /// <summary>
            /// A pointer to a null-terminated string that specifies the URL for the manufacturer.
            /// </summary>
            [MarshalAs(UnmanagedType.LPTStr)]
            public string pszOEMUrl;

            /// <summary>
            /// A pointer to a null-terminated string that specifies the hardware ID for the printer driver.
            /// </summary>
            [MarshalAs(UnmanagedType.LPTStr)]
            public string pszHardwareID;

            /// <summary>
            /// A pointer to a null-terminated string that specifies the provider of the printer driver (for example, "Microsoft Windows 2000").
            /// </summary>
            [MarshalAs(UnmanagedType.LPTStr)]
            public string pszProvider;

            /// <summary>
            /// A pointer to a null-terminated string that specifies the print processor (for example, "WinPrint").
            /// </summary>
            [MarshalAs(UnmanagedType.LPTStr)]
            public string pszPrintProcessor;

            /// <summary>
            /// A pointer to a null-terminated string that specifies the vendor's driver setup DLL and entry point.
            /// </summary>
            [MarshalAs(UnmanagedType.LPTStr)]
            public string pszVendorSetup;

            /// <summary>
            /// A pointer to a null-terminated string that specifies the color profiles associated with the driver.
            /// </summary>
            [MarshalAs(UnmanagedType.LPTStr)]
            public string pszzColorProfiles;

            /// <summary>
            /// A pointer to a null-terminated string that specifies the path to the driver's .inf file in the driver store. (See Remarks.) This must be NULL if the DRIVER_INFO_8 is being passed to AddPrinterDriver or AddPrinterDriverEx.
            /// </summary>
            [MarshalAs(UnmanagedType.LPTStr)]
            public string pszInfPath;

            /// <summary>
            /// Attribute flags for printer drivers. This must be 0 if the DRIVER_INFO_8 is being passed to AddPrinterDriver or AddPrinterDriverEx. Otherwise, it can be any combination of the following flags:
            /// </summary>
            public uint dwPrinterDriverAttributes;

            /// <summary>
            /// A pointer to a null-terminated multi-string that specifies all the core printer drivers that the driver depends on. This must be NULL if the DRIVER_INFO_8 is being passed to AddPrinterDriver or AddPrinterDriverEx.
            /// </summary>
            [MarshalAs(UnmanagedType.LPTStr)]
            public string pszzCoreDriverDependencies;

            /// <summary>
            /// The earliest allowed date of any drivers that shipped with Windows and on which this driver depends.
            /// </summary>
            [Obsolete]
            private FILETIME ftMinInboxDriverVerDate;

            /// <summary>
            /// The earliest allowed version of any drivers that shipped with Windows and on which this driver depends.
            /// </summary>
            private ulong dwlMinInboxDriverVerVersion;

        }

        /// <summary>
        /// MstPrinterDatasコレクションを生成する
        /// </summary>
        /// <param name="suffix">表示用プリンター名の末尾に付加する接尾語</param>
        /// <param name="print"></param>
        /// <returns>MstPrinterDatasコレクション</returns>
        public static List<MstPrinterData> CreateMstPrinterDatas(string suffix, NKKPrint print)
        {
            Func<string, MstPrinterData> createMstPrinterData;
            if (string.IsNullOrEmpty(suffix))
            {

                // 表示用プリンター名とプリンター名を同一にする匿名メソッド
                createMstPrinterData = delegate (string s)
                {
                    return new MstPrinterData
                    {
                        PrinterName = s,
                        DispPrinterName = s
                    };
                };

            }
            else
            {

                // 接尾語を追加
                createMstPrinterData = delegate (string s)
                {
                    return new MstPrinterData
                    {
                        PrinterName = s,
                        DispPrinterName = $"{s} {suffix}"
                    };
                };

            }

            var wList = new List<MstPrinterData>();
            IntPtr phPrinter = IntPtr.Zero;

            // インストールされたプリンターの中からOpenPrinter関数でハンドルを取得できたもののみを抽出する
            foreach (string s in from string s in System.Drawing.Printing.PrinterSettings.InstalledPrinters
                                 where OpenPrinter(s, out phPrinter, IntPtr.Zero) != 0
                                 select s)
            {

                try
                {
                    var pEnv = new StringBuilder();

                    //必要なバイト数を取得する
                    int needed = 0;
                    GetPrinterDriver(phPrinter, pEnv, 8, IntPtr.Zero, 0, ref needed);

                    if (needed <= 0)
                    {
                        throw new Exception("GetPrinterDriver関数 失敗");
                    }

                    //メモリを割り当てる
                    IntPtr pPrinterInfo = IntPtr.Zero;
                    pPrinterInfo = Marshal.AllocHGlobal(needed);

                    //プリンタ情報を取得する
                    int temp = 0;
                    if (!GetPrinterDriver(phPrinter, pEnv, 8, pPrinterInfo, needed, ref temp))
                    {
                        throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error());
                    }

                    // DRIVER_INFO_8型にマーシャリングする
                    var printerInfo =
                        (DRIVER_INFO_8)Marshal.PtrToStructure(pPrinterInfo,
                        typeof(DRIVER_INFO_8));

                    if ((printerInfo.dwPrinterDriverAttributes & (PRINTER_DRIVER_XPS | PRINTER_DRIVER_CATEGORY_FAX | PRINTER_DRIVER_CATEGORY_FILE | PRINTER_DRIVER_CATEGORY_VIRTUAL)) == 0)
                    {
                        wList.Add(createMstPrinterData(s));
                    }

                }
                catch (Exception ex)
                {
                    Debug.Print(ex.Message);
                    if (print != null)
                    {
                        print.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, ex.Message);
                    }
                }
                finally
                {
                    ClosePrinter(phPrinter);

                }
            }

            return wList;
        }

        /// <summary>
        /// 指定されたファイルをS3からダウンロードする
        /// </summary>
        /// <param name="fileName">ファイル名</param>
        /// <param name="bucket">バケット</param>
        /// <returns>非同期Task</returns>
        // mod #9728,9601 donghao start
        //private static async System.Threading.Tasks.Task Download(string fileName, string bucket, string baseUrl,
        //                                                  string baseDirectory)
        private static async System.Threading.Tasks.Task Download(string fileName, string bucket, string baseUrl,
                                                                  string baseDirectory, string serviceIp)
        // mod #9728,9601 donghao end
        {
            // mod #9728,9601 donghao start
            //string contentString = $"{{\"filename\": \"{fileName}\",\"bucket\": \"{bucket}\"}}";
            string contentString = $"{{\"filename\": \"{fileName}\",\"bucket\": \"{bucket}\",\"serviceIp\": \"{serviceIp}\"}}";
            // mod #9728,9601 donghao end
            string requestUri = $"{baseUrl}/ntss-admin-web/api/report_designer/forPrintServer/download";

            // mod #10977 インジェクション対応 高 start
            //System.Net.Http.HttpResponseMessage response = await PostAsync(contentString, requestUri);
            //_ = response.EnsureSuccessStatusCode();

            //string responseBodyAsText = await response.Content.ReadAsStringAsync();
            string responseBodyAsText = string.Empty;
            NKKWebAccessLib.NKKWebAccessResponse res = NKKWebAccessLib.NKKWebAccess.Post("指定されたファイルをウンロード", requestUri, contentString).Result;
            if (res.response.IsSuccessStatusCode == true)
            {
                responseBodyAsText = res.strContent;

                // 文字列をバイト配列に変換して、ファイルとして保存する
                try
                {
                    if (string.IsNullOrEmpty(responseBodyAsText) == false)
                    {
                        //string baseDirectory = AppDomain.CurrentDomain.BaseDirectory;
                        string zipFilePath = $"{baseDirectory}{fileName}";
                        WriteToFile(responseBodyAsText, zipFilePath);
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.Message);
                    NKKLogging.GetInstance().AddLogInfo(DateTime.Now, "Download", NKKLogging.LOGGING_CLASS.ERROR, ex.ToString());
                }
            }
            // mod #10977 インジェクション対応 高 end

            //fileName = "Dialysis_20190614150319_Excel.zip";
            //System.Net.Http.HttpResponseMessage response;
            //System.Net.ServicePointManager.SecurityProtocol |= System.Net.SecurityProtocolType.Tls12;

            //// ファイルダウンロード要求をPOSTする
            //using (System.Net.Http.HttpClient httpClient = new System.Net.Http.HttpClient())
            //{
            //    // Limit the max buffer size for the response so we don't get overwhelmed
            //    System.Net.Http.StringContent content = new System.Net.Http.StringContent(
            //        "{\"filename\": \"" + fileName + "\",\"bucket\": \"s3://ntss-s3-root/Report/999900\"}",
            //        Encoding.UTF8, "application/json");
            //    response = await httpClient.PostAsync("https://dev.nksfn.com/ntss-admin-web/api/motion_record/detail/gathering/download", content);
            //}
            //_ = response.EnsureSuccessStatusCode();
            //string responseBodyAsText = await response.Content.ReadAsStringAsync();

            //// 文字列をバイト配列に変換して、ZIPファイルとして保存する
            //try
            //{
            //    string zipFilePath = $"{AppDomain.CurrentDomain.BaseDirectory}\\{fileName}";
            //    WriteToFile(responseBodyAsText, zipFilePath);
            //}
            //catch (Exception ex)
            //{
            //    Console.WriteLine(ex.Message);
            //}

        }

        /// <summary>
        /// 指定された URI に POST 要求を非同期操作として送信します。
        /// </summary>
        /// <param name="contentString">StringContent の初期化に使用されるコンテンツ。</param>
        /// <param name="requestUri">要求の送信先 URI。</param>
        /// <returns>非同期操作を表すタスク オブジェクト。</returns>
        private static async System.Threading.Tasks.Task<System.Net.Http.HttpResponseMessage> PostAsync(string contentString, string requestUri)
        {
            HttpResponseMessage response;
            System.Net.ServicePointManager.SecurityProtocol |= System.Net.SecurityProtocolType.Tls12;

            // ファイルダウンロード要求をPOSTする
            //using (System.Net.Http.HttpClient httpClient = new System.Net.Http.HttpClient())
            //{
            //    // Limit the max buffer size for the response so we don't get overwhelmed
            //    //const string bucket = "s3://ntss-s3-root/LOG/999000";
            //    System.Net.Http.StringContent content = new System.Net.Http.StringContent(
            //        contentString,
            //        Encoding.UTF8, "application/json");
            //    //const string baseUrl = "https://dev.nksfn.com";
            //    response = await httpClient.PostAsync(requestUri, content);
            //}
            //using (System.Net.Http.HttpClientHandler clienthandler = NKKWebAccess.GetHttpClientHandler())
            //{
            //    using (System.Net.Http.HttpClient httpClient = new System.Net.Http.HttpClient(clienthandler))
            //    {
            //        // Limit the max buffer size for the response so we don't get overwhelmed
            //        //const string bucket = "s3://ntss-s3-root/LOG/999000";
            //        System.Net.Http.StringContent content = new System.Net.Http.StringContent(
            //            contentString,
            //            Encoding.UTF8, "application/json");
            //        //const string baseUrl = "https://dev.nksfn.com";
            //        response = await httpClient.PostAsync(requestUri, content);
            //    }
            //}

            // ファイルダウンロード要求をPOSTする
            // Limit the max buffer size for the response so we don't get overwhelmed
            //const string bucket = "s3://ntss-s3-root/LOG/999000";
            using (var content = new System.Net.Http.StringContent(
                contentString,
                Encoding.UTF8, "application/json"))
            {




                 //const string baseUrl = "https://dev.nksfn.com";
                response = await NKKWebAccess.HttpClient.PostAsync(requestUri, content);

            }

            return response;

        }

        /// <summary>
        /// WebSocket受信処理
        /// </summary>
        /// <param name="dtDate">受信日時</param>
        /// <param name="strMessage">受信メッセージ. 例.{"filename": "DE_999000_01_99999999999_20180907.ZIP","bucket": "s3://ntss-s3-root/LOG/999000","printerName": "EPSON LP-S950"}</param>
        private async void WebSocketReceiveMessageAsync(DateTime dtDate, string strMessage)
        {

            // 受信メッセージの例
            // {
            // 	   "filename": "DE_999000_01_99999999999_20180907.ZIP",
            //     "bucket": "s3://ntss-s3-root/LOG/999000",
            //     "printerName": "EPSON LP-S950"
            // }
            try
            {

                string[] messages = strMessage.Split('\t');
                if (messages.Length >= 2)
                {

                    var deserializedData = new PrintData();

                    // JSON文字列をデシリアライズする
                    using (var ms = new System.IO.MemoryStream(Encoding.UTF8.GetBytes(messages[1])))
                    {
                        var ser = new System.Runtime.Serialization.Json.DataContractJsonSerializer(deserializedData.GetType());
                        deserializedData = ser.ReadObject(ms) as PrintData;
                        ms.Close();
                    }

                    // TODO: S3からファイルをダウンロードする
                    Debug.WriteLine("filename:    " + deserializedData.filename);
                    Debug.WriteLine("bucket:      " + deserializedData.bucket);
                    Debug.WriteLine("printerName: " + deserializedData.printerName);

                   // PDFファイルをS3からダウンロードする
                    var pos = deserializedData.filename.LastIndexOf('/');
                    if (pos > 0)
                    {
                        // ファイル名に/が含まれていればbucketに繋げる
                        deserializedData.bucket = deserializedData.bucket + "/" + deserializedData.filename.Substring(0, pos);
                    }
                    if (pos >= 0)
                    {
                        // ファイル名に/が含まれていれば、/よる後ろをファイル名にする
                        deserializedData.filename = deserializedData.filename.Substring(pos + 1);
                    }
                    // add #9728,9601 start
                    string serviceIp = string.Empty;
                    if (!String.IsNullOrEmpty(deserializedData.serviceIp))
                    {
                        serviceIp = deserializedData.serviceIp;
                    } 
                    // add #9728,9601 end
                    // mod 2020-11-19 No.321:印刷後にダウンロードした帳票PDFを削除していないために、ローカルストレージを圧迫する。 孫 start
                    //await Download(deserializedData.filename, deserializedData.bucket, NKKWebAccess.BaseUri, AppDomain.CurrentDomain.BaseDirectory);
                    // mod #9728,9601 start
                    //await Download(deserializedData.filename, deserializedData.bucket, NKKWebAccess.BaseUri, PdfFolder);
                    await Download(deserializedData.filename, deserializedData.bucket, NKKWebAccess.BaseUri, PdfFolder, serviceIp);
                    // mod 2020-11-19 No.321:印刷後にダウンロードした帳票PDFを削除していないために、ローカルストレージを圧迫する。 孫 end
                    // mod #9728,9601 end
                    // 展開先フォルダ名
                    // ZIPファイル名と同じ名前のフォルダに展開する
                    //string destDirName = System.IO.Path.GetFileNameWithoutExtension(deserializedData.filename);
                    //string destinationDirectoryName = $"{AppDomain.CurrentDomain.BaseDirectory}\\{destDirName}";

                    //// フォルダ内のファイルを削除する
                    //if (System.IO.Directory.Exists(destinationDirectoryName))
                    //{
                    //    string[] fileNames = System.IO.Directory.GetFiles(destinationDirectoryName);
                    //    foreach (string fileName in fileNames)
                    //    {
                    //        System.IO.File.Delete(fileName);
                    //    }
                    //}

                    // ZIPファイルを展開する
                    //System.IO.Compression.ZipFile.ExtractToDirectory($"{AppDomain.CurrentDomain.BaseDirectory}\\{deserializedData.filename}",
                    //                                                 destinationDirectoryName);

                    // 展開したPDFファイル群を印刷する
                    //IEnumerable<string> files = System.IO.Directory.EnumerateFiles(destinationDirectoryName, "*.pdf");
                    //string[] files = { AppDomain.CurrentDomain.BaseDirectory + "\\血液透析記録.pdf" };
                    //foreach (string str in files)
                    //{
                    //    string fileName = encloseInDoubleQuotes(str);
                    //    string printerName = encloseInDoubleQuotes(deserializedData.printerName);
                    //    NativeMethods.LaunchProcess($"{location} /t {fileName} {printerName}");

                    //    // GUI：印刷履歴表示
                    //    SendLogMessageToGUI("印刷", "印刷", DateTime.Now, "[" + deserializedData.filename + "] [" + deserializedData.printerName + "]");
                    //}
                    // 印刷処理で使用するPrinterSettingオブジェクトを生成
                    var settings = new System.Drawing.Printing.PrinterSettings
                    {
                        PrinterName = deserializedData.printerName
                    };

                    // mod #11183 PDF印刷コンポーネントの変更対応 高 start
                    // C1PdfDocumentSourceを生成し、レポートを印刷する
                    //using (var c1PdfDocumentSource1 = new C1.Win.C1Document.C1PdfDocumentSource())
                    //{

                    //    // ファイルからドキュメントをロードします0
                    //    // mod 2020-11-19 No.321:印刷後にダウンロードした帳票PDFを削除していないために、ローカルストレージを圧迫する。 孫 start
                    //    //c1PdfDocumentSource1.LoadFromFile($"{AppDomain.CurrentDomain.BaseDirectory}{deserializedData.filename}");
                    //    c1PdfDocumentSource1.LoadFromFile($"{PdfFolder}{deserializedData.filename}");
                    //    // mod 2020-11-19 No.321:印刷後にダウンロードした帳票PDFを削除していないために、ローカルストレージを圧迫する。 孫 end

                    //    // 生成されたレポートを印刷します。
                    //    c1PdfDocumentSource1.Print(settings);
                    //}
                    using (var document = PdfDocument.Load($"{PdfFolder}{deserializedData.filename}"))
                    {
                        using (var printDocument = document.CreatePrintDocument())
                        {
                            printDocument.PrinterSettings = settings;

                            printDocument.Print();
                        }
                    }
                    // mod #11183 PDF印刷コンポーネントの変更対応 高 end

                    SendLogMessageToGUI("印刷", "印刷", DateTime.Now, "[" + deserializedData.printerName + "]");

                }

            }
            catch (Exception ex)
            {
                var log = NKKLogging.GetInstance();
                log.AddLogInfo(DateTime.Now, "NKKPrintServer", NKKLogging.LOGGING_CLASS.ERROR, ex.ToString());
            }

        }

        /// <summary>
        /// 16進文字列をバイトに変換してファイルに保存する
        /// </summary>
        /// <param name="responseBodyAsText">16進文字列</param>
        /// <param name="path">ファイル名</param>
        public static void WriteToFile(string responseBodyAsText, string path)
        {
            using (System.IO.FileStream fs = System.IO.File.Create(path))
            {
                for (int i = 0; i < (responseBodyAsText.Length / 2); i++)
                {
                    fs.WriteByte(Convert.ToByte(responseBodyAsText.Substring(i * 2, 2), 16));
                }

            }
        }

        #endregion プライベートメソッド

    }

}
