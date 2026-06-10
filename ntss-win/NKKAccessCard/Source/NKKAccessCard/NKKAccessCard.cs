

//----------------------------------------------------------------------------------------------------
//  Defination of AccessCard macro
//----------------------------------------------------------------------------------------------------
#define ACCESSCARD

//----------------------------------------------------------------------------------------------------
//  NKKAccessCardクラス定義
//----------------------------------------------------------------------------------------------------
using System;
using System.Collections.Generic;
using System.Security.AccessControl;
using System.Security.Principal;
using System.Text;
using System.Threading;
using System.Diagnostics;
using System.Collections;
using System.Net.NetworkInformation;
using System.Net;
using System.Management;

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
using NKKCommon;
//----------------------------------------------------------------------------------------------------


//----------------------------------------------------------------------------------------------------
//  名前空間:NKKAccessCardLib
//----------------------------------------------------------------------------------------------------
namespace NKKAccessCardLib
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// NKKAccessCard
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public class NKKAccessCard
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
        private readonly String LOG_FILE_EXT = "AccessCard";
        // mod #9696 アプリケーションログのパスとファイル名の修正。 limingzhe end
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ログファイル識別子
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        // mod #9696 アプリケーションログのパスとファイル名の修正。 limingzhe start
        private readonly String LOG_FILE_EXT_NG = "AccessCardNg";
        // mod #9696 アプリケーションログのパスとファイル名の修正。 limingzhe end
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 設定ファイル名
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String CONFIG_FILE_NAME = "NKKAccessCard.config";
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 設定ファイル内アプリケーション設定セッション識別子
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly string CONFIG_APPLICATION_SECTION = "Settings\\Application";
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
        /// システム設定取得URI
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String GET_SYSTEM_DEFINE_URI = "/api/mstInfo/sysSystemDefine";
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// S3からのファイルダウンロートURI
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String GET_FILE_DOWNLOAD_URI = "/api/motion_record/detail/gathering/download";
        //----------------------------------------------------------------------------------------------------
        // add FNSI-4200ポートを使用している 孫 start
        /// <summary>
        /// カードAPPのポート更新URI
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String CARD_APP_PORT_UPDATE_URL = "/api/card_state/update_card_app_port/";
        //----------------------------------------------------------------------------------------------------
        // add FNSI-4200ポートを使用している 孫 end

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// システム設定：体重計アプリケーションバージョン情報
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly int GET_SYSTEM_DEFINE_VERSION_NO = 15;
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
        /// <summary>
        /// 直前で発生したエラーオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private Exception m_Exception = null;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ログ保持日数[既定：20日] 
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly int m_nLogFileKeepNumberDays = 20;
        // add 2021-03-26 カードアプリのログをAWSにupする 孫 start
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ログアップローダーオブジェクト
        /// </summary>
        private NKKCommon.NKKLogUploader m_LogUploader = new NKKCommon.NKKLogUploader();
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ログアップロード実施間隔
        /// </summary>
        private TimeSpan m_LogUploadCycle;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 前回ログファイルアップロード日時
        /// </summary>
        private DateTime m_dtLogUpload = DateTime.Now;
        // add 2021-03-26 カードアプリのログをAWSにupする 孫 end
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
        /// Felicaカードリーダーオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly NKKFalica m_Felica = new NKKFalica();

#if !ACCESSCARD

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 体重計クラスオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly NKKWeightScale m_WeightScale = new NKKWeightScale();
#endif

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

        // add FNSI-4200ポートを使用している 孫 start
        #region ダイナミックポート番号
        /// <summary>
        /// クライアント識別子を取得します
        /// </summary>
        /// <returns></returns>
        public string GetClientKey()
        {
            // BOIS ID
            string biosId = "";
            // ベースボードID
            string baseboardId = "";
            // CPU ID
            string cpuId = "";

            // BOIS IDを取得する
            try
            {
                ManagementClass mc = new ManagementClass("Win32_BIOS");
                ManagementObjectCollection moc = mc.GetInstances();
                foreach (ManagementObject mo in moc)
                {
                    biosId = mo.Properties["SerialNumber"].Value.ToString();
                    break;
                }
            }
            catch (Exception)
            {
                biosId = "";
            }

            // ベースボードIDを取得する
            try
            {
                ManagementClass mc = new ManagementClass("Win32_BaseBoard");
                ManagementObjectCollection moc = mc.GetInstances();
                foreach (ManagementObject mo in moc)
                {
                    baseboardId = mo.Properties["SerialNumber"].Value.ToString();
                    break;
                }
            }
            catch (Exception)
            {
                baseboardId = "";
            }


            // CPU IDを取得する
            try
            {
                ManagementClass mc = new ManagementClass("Win32_Processor");
                ManagementObjectCollection moc = mc.GetInstances();
                foreach (ManagementObject mo in moc)
                {
                    cpuId = mo.Properties["ProcessorId"].Value.ToString();
                    break;
                }

            }
            catch (Exception)
            {
                cpuId = "";
            }


            return biosId + "-" + baseboardId + "-" + cpuId;
        }

        /// <summary>
        /// 最初の利用可能なポート番号を取得します
        /// </summary>
        /// <param name="port"></param>
        /// <returns></returns>
        public bool PortIsAvailable(int port)
        {
            bool isAvailable = true;

            IList portUsed = PortIsUsed();

            foreach (int p in portUsed)
            {
                if (p == port)
                {
                    isAvailable = false;
                    break;
                }
            }

            return isAvailable;
        }

        /// <summary>
        /// システムが使用しているポート番号を取得します
        /// </summary>
        /// <returns></returns>
        public static IList PortIsUsed()
        {
            // ネットワーク接続と通信統計データの情報を取得します
            IPGlobalProperties ipGlobalProperties = IPGlobalProperties.GetIPGlobalProperties();

            // すべてのTcpモニタプログラムを返します
            IPEndPoint[] ipsTCP = ipGlobalProperties.GetActiveTcpListeners();

            // すべてのUDP傍受プログラムを返します
            IPEndPoint[] ipsUDP = ipGlobalProperties.GetActiveUdpListeners();

            // Internetプロトコルバージョン4（IPV 4転送制御プロトコル（TCP）)接続の情報を返します
            TcpConnectionInformation[] tcpConnInfoArray = ipGlobalProperties.GetActiveTcpConnections();

            IList allPorts = new ArrayList();
            foreach (IPEndPoint ep in ipsTCP) allPorts.Add(ep.Port);
            foreach (IPEndPoint ep in ipsUDP) allPorts.Add(ep.Port);
            foreach (TcpConnectionInformation conn in tcpConnInfoArray) allPorts.Add(conn.LocalEndPoint.Port);

            return allPorts;
        }

        /// <summary>
        /// ダイナミックポート番号を取得します
        /// </summary>
        /// <returns></returns>
        public int GetFirstAvailablePort()
        {
            // ダイナミックポート番号である49152–65535を使用すること。
            int portFrom = 0;
            int portTo = 0;

            // ConfigFileから、Fromポート番号を取得します
            try
            {
                portFrom = Convert.ToInt32(FelicaLibTdc.IcPortFrom);
            }
            catch(Exception)
            {
                portFrom = 49152;
            }

            // ConfigFileから、Toポート番号を取得します
            try
            {
                portTo = Convert.ToInt32(FelicaLibTdc.IcPortTo);
            }
            catch (Exception)
            {
                portTo = 65535;
            }

            // ポート番号をチェックします
            if (portFrom> portTo)
            {
                int tmpPort = portFrom;
                portFrom = portTo;
                portTo = tmpPort;
            }

            for (int i = portFrom; i < portTo; i++)
            {
                if (PortIsAvailable(i)) return i;
            }

            return -1;
        }
        #endregion
        #region カードアプリポート管理TBを更新する
        private Boolean UpdateCardAppPort()
        {
            try
            {
                // クライアント識別子を取得する
                string clientKey = GetClientKey();

                String strUri = String.Format("{0}{1}{2}?_={3}"
                    , NKKWebAccess.BaseUri
                    , NKKAccessCardInfo.WEB_APP_URI
                    , this.CARD_APP_PORT_UPDATE_URL
                    , DateTime.Now.Ticks);
                String strbody = String.Format("{{\"guid\":\"{0}\", \"facilityCd\":\"{1}\", \"clientKey\":\"{2}\", \"port\":{3}, \"regDate\":\"\", \"upDate\":\"\"}}"
                    , FelicaLibTdc.IcGuId
                    , NKKWebAccess.FacilityCd
                    , clientKey
                    , NKKWebAppSocketConfig.WS_PORT
                );
                NKKWebAccessResponse res = NKKWebAccess.Put("カードAPPポート登録結果通知", strUri, strbody).Result;

                if (res.response.IsSuccessStatusCode == true)
                {
                    // 処理成功

                    // ログ記録
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("カードAPPポート登録結果通知,{0}", strbody));
                    return true;
                }
            }
            catch (Exception ex)
            {
                // ログ記録：エラー
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("カードAPPポート登録結果通知,{0}", ex.Message));
            }

            return false;
        }
        #endregion
        // add FNSI-4200ポートを使用している 孫 end

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// コンストラクタ
        /// <param name="strFolder">設定ファイル格納先フォルダ名</param>
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public NKKAccessCard( String strFolder )
        {
            try
            {

                // 起動時のdll一覧としてログに記載するdllを事前読み込み
                AppDomain.CurrentDomain.Load("Ionic.Zip");

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
                //  識別子
                log.LogExt = $"{LOG_FILE_EXT}_{System.Net.Dns.GetHostName()}";
                //  バージョン情報記録用処理登録(ログが変わった場合にログの先頭に記録するため)
                log.FirstWriteEvent = VersionInfos.GetVersionInfo;
                // mod #9696 アプリケーションログのパスとファイル名の修正。 limingzhe end

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

                // add 2021-03-26 カードアプリのログをAWSにupする 孫 start
                // ログアップロード実施日時
                var m_strLogUploadCycle = sys.GetSingleLineValue(this.CONFIG_LOG_SECTION, "LogUploadTime", "01:00").Trim();
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
                // add 2021-03-26 カードアプリのログをAWSにupする 孫 end

                // サーバー設定
                NKKWebAccess.UserId = sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "UserId", String.Empty).Trim();
                NKKWebAccess.Password = sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "UserPW", String.Empty).Trim();
                NKKWebAccess.UrlEncodeFacilityHash = sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "FacilityHash", String.Empty).Trim();
                // mod 2022-04-22 #6860 最後のスラッシュを除く Thach start
                NKKWebAccess.BaseUri = sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "BaseUri", String.Empty).Trim(' ', '/');
                // mod 2022-04-22 #6860 最後のスラッシュを除く Thach end
                // add 2021-03-25 クライアント証明書検索キーを追加 孫 end
                NKKWebAccess.ClientCertificateSearchValue1 = sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "ClientCertificateSearchValue1", String.Empty).Trim();
                NKKWebAccess.ClientCertificateSearchValue2 = sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "ClientCertificateSearchValue2", String.Empty).Trim();
                // add 2021-03-25 クライアント証明書検索キーを追加 孫 start

                // 最新ファイルダウンロード先フォルダ
                NKKAccessCardInfo.DownloadSourceFolder = sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "DownloadFolder", String.Empty).Trim();
                NKKWebAppSocketConfig.WS_URL = sys.GetSingleLineValue(CONFIG_WEBSOCKET_SECTION, "WEB_APP_URI", string.Empty);
                int.TryParse(
                sys.GetSingleLineValue(CONFIG_WEBSOCKET_SECTION, "WEB_APP_PORT", default(int).ToString()), out NKKWebAppSocketConfig.WS_PORT);

                // add オンプレでの自己アップデートに対応 孫 start
                // 最新ファイル取得先ファイル名
                NKKAccessCardInfo.DownloadFileName = sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "DownloadFileName", "NKKAccessCard.zip").Trim();
                // add オンプレでの自己アップデートに対応 孫 end

                // add FNSI-4200ポートを使用している 孫 start
                if (NKKWebAppSocketConfig.WS_PORT == 0 || !PortIsAvailable(NKKWebAppSocketConfig.WS_PORT))
                {
                    FelicaLibTdc.IcPortFrom = sys.GetSingleLineValue(CONFIG_FELICA_SECTION, "DynamicPortFrom", "49152").Trim();
                    FelicaLibTdc.IcPortTo = sys.GetSingleLineValue(CONFIG_FELICA_SECTION, "DynamicPortTo", "65535").Trim();

                    NKKWebAppSocketConfig.WS_PORT = GetFirstAvailablePort();
                    sys.SetValue(CONFIG_WEBSOCKET_SECTION, "WEB_APP_PORT", NKKWebAppSocketConfig.WS_PORT.ToString());
                    sys.Save();
                }
                // add FNSI-4200ポートを使用している 孫 end

                // アップデート実施日時
                this.m_strCheckUpdateTime = sys.GetSingleLineValue(CONFIG_APPLICATION_SECTION, "UpdateTime", this.m_strCheckUpdateTime).Trim();
                if (this.UpdateDateTime == DateTime.MaxValue)
                {
                    // ログ記録：設定無効
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "設定されているアップデート時刻が無効, 設定値：" + this.m_strCheckUpdateTime);

                }
                // Felica
                // フェリカカードシステムコード
                FelicaLibTdc.IcSystemCode = sys.GetSingleLineValue(CONFIG_FELICA_SECTION, "SystemCode", "88D5").Trim();
                // フェリカカードサービスコード１
                FelicaLibTdc.IcServiceCode1 = sys.GetSingleLineValue(CONFIG_FELICA_SECTION, "ServiceCode1", "0049").Trim();
                // フェリカカードサービスコード２
                FelicaLibTdc.IcServiceCode2 = sys.GetSingleLineValue(CONFIG_FELICA_SECTION, "ServiceCode2", "0089").Trim();

                // add FNSI-4200ポートを使用している 孫 start
                // カードアプリのGUID
                FelicaLibTdc.IcGuId = sys.GetSingleLineValue(CONFIG_FELICA_SECTION, "GUID", "").Trim();
                if (String.IsNullOrEmpty(FelicaLibTdc.IcGuId))
                {
                    FelicaLibTdc.IcGuId = System.Guid.NewGuid().ToString();
                    sys.SetValue(CONFIG_FELICA_SECTION, "GUID", FelicaLibTdc.IcGuId);
                    sys.Save();
                }
                // add FNSI-4200ポートを使用している 孫 end

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
                NKKWebAccess.SendMessageHandler = this.SendLogMessageToGUI;

                // GUI通知用関数登録
                this.m_Felica.SendMessageToGUIHandler = this.SendLogMessageToGUI;

                // GUI通知用関数登録
                NKKWebAppSocket.GetInstance().SendMessageToGUIHandler = this.SendLogMessageToGUI;

                // アップデーターオブジェクト初期化
                // ログ記録
                this.m_Updater.LoggingMethod = this.AddLogInfoUpdate;
                // プロセス種類
                this.m_Updater.ProcType = 0;
                // システム設定項目番号
                this.m_Updater.SystemDefineVersionNo = GET_SYSTEM_DEFINE_VERSION_NO;
                // バケット名(ダウンロード先フォルダ)
                this.m_Updater.Bucket = NKKAccessCardInfo.DownloadSourceFolder;
                // ダウンロードファイル名
                this.m_Updater.DownloadFileName = NKKAccessCardInfo.DownloadFileName;
                // ダウンロードファイルのパスワード
                this.m_Updater.Bucket = NKKAccessCardInfo.DownloadSourceFolder;
                // ダウンロードファイルのパスワード
                this.m_Updater.DownloadFilePassword = NKKAccessCardInfo.DownloadFilePassword;

                // スレッド構築
                this.m_Thread = new Thread(this.DoWork)
                {
                    Name = "NKKAccessCard処理スレッド",
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
                //  識別子
                log.LogExt = $"{LOG_FILE_EXT_NG}_{System.Net.Dns.GetHostName()}";
                //  バージョン情報記録用処理登録(ログが変わった場合にログの先頭に記録するため)
                log.FirstWriteEvent = VersionInfos.GetVersionInfo;
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
        ~NKKAccessCard()
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
                }
            }
        }
        //----------------------------------------------------------------------------------------------------

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
                        System.Globalization.DateTimeStyles.None);
                }
                catch (Exception ex)
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
        //----------------------------------------------------------------------------------------------------
        
        // add 2021-03-26 カードアプリのログをAWSにupする 孫 start
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
        // add 2021-03-26 カードアプリのログをAWSにupする 孫 end

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

                // NKKFalica
                if( this.m_Felica != null )
                {
                    // 処理終了
                    this.m_Felica.Stop();

                    // 処理終了成功
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "NKKFalica処理終了");
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
        private void AddLogInfoUpdate(NKKLoggingLib.NKKLogging.LOGGING_CLASS LoggingClass, String strMessage)
        {
            // ログ記録
            this.AddLogInfo(DateTime.Now, LoggingClass, strMessage);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// アップデート処理
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 再起動フラグを作成し、ログオン ユーザーが削除できるよう ACL を付与する（SYSTEM が作成すると既定では削除不可のため）
        /// </summary>
        private static void WriteGuiRestartFlagWithAcl(string restartFlagFolder, string restartFlagPath)
        {
            if (System.IO.Directory.Exists(restartFlagFolder) == false)
            {
                System.IO.Directory.CreateDirectory(restartFlagFolder);
            }

            SecurityIdentifier sidAuthUsers = new SecurityIdentifier(WellKnownSidType.AuthenticatedUserSid, null);
            DirectorySecurity dirSec = System.IO.Directory.GetAccessControl(restartFlagFolder);
            dirSec.AddAccessRule(new FileSystemAccessRule(
                sidAuthUsers,
                FileSystemRights.Modify | FileSystemRights.Delete | FileSystemRights.ReadAndExecute | FileSystemRights.Synchronize,
                InheritanceFlags.ContainerInherit | InheritanceFlags.ObjectInherit,
                PropagationFlags.None,
                AccessControlType.Allow));
            System.IO.Directory.SetAccessControl(restartFlagFolder, dirSec);

            if (System.IO.File.Exists(restartFlagPath))
            {
                System.IO.File.Delete(restartFlagPath);
            }

            System.IO.File.WriteAllText(restartFlagPath, DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss.fff"), Encoding.UTF8);

            FileSecurity fileSec = System.IO.File.GetAccessControl(restartFlagPath);
            fileSec.AddAccessRule(new FileSystemAccessRule(sidAuthUsers, FileSystemRights.FullControl, AccessControlType.Allow));
            System.IO.File.SetAccessControl(restartFlagPath, fileSec);
        }

        private void CheckUpdate()
        {
            // アップデートバージョンチェック
            // 最新ファイルを取得
            if (this.m_Updater.IsPublishedNewVersion(System.Reflection.Assembly.GetExecutingAssembly()) && this.m_Updater.GetLatestProgramFile())
            {
                // 最新ファイルを取得+解凍完了
                // GUIツール[FNWSiAccessCardTool.exe / NKKAccessCardTool.exe]を終了
                try
                {
                    // GUI 側に「更新後再起動が必要」であることを確実に伝えるため、フラグファイルを作成する。
                    string restartFlagFolder = System.IO.Path.Combine(
                        Environment.GetFolderPath(Environment.SpecialFolder.CommonApplicationData),
                        "NIKKISO",
                        "FNWSiAccessCard");
                    string restartFlagPath = System.IO.Path.Combine(restartFlagFolder, "FNWSiAccessCardTool.restart.flag");
                    try
                    {
                        WriteGuiRestartFlagWithAcl(restartFlagFolder, restartFlagPath);
                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "GUI再起動フラグ作成: " + restartFlagPath);
                    }
                    catch (Exception exFlag)
                    {
                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "GUI再起動フラグ作成失敗: " + exFlag.Message);
                    }

                    // 自動更新時は、GUI 側で再起動ウォッチャーを仕込んでから終了させる。
                    // GUI 側は CRLF 単位で受信解釈しているため、明示的に区切りを付与する。
                    this.m_GUISocketServer.AllSend(NKKAccessCardInfo.Encoding.GetBytes("RESTART\r\n"));
                    System.Threading.Thread.Sleep(200);
                    this.m_GUISocketServer.AllSend(NKKAccessCardInfo.Encoding.GetBytes("EXIT\r\n"));
                    String taskkill = System.IO.Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.System), "taskkill.exe");

                    System.Collections.Generic.List<System.Diagnostics.Process> killTargets = new System.Collections.Generic.List<System.Diagnostics.Process>();
                    killTargets.AddRange(System.Diagnostics.Process.GetProcessesByName("FNWSiAccessCardTool"));
                    killTargets.AddRange(System.Diagnostics.Process.GetProcessesByName("NKKAccessCardTool"));

                    foreach (System.Diagnostics.Process p in killTargets)
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
                            if (NKKWebAccess.ServerLogin().Result == 1)
                            {

                                // 施設コード
                                NKKLogging.GetInstance().FacilityCd = NKKWebAccess.FacilityCd;

                                // ログ記録：施設コード
                                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("施設コード:{0}", NKKWebAccess.FacilityCd));
                            }
                        }

                        // ログイン判定
                        if (NKKWebAccess.Login == true)
                        {
                            // ログイン済み

                            // add 2021-03-26 カードアプリのログをAWSにupする 孫 start
                            // ログアップロード
                            this.m_LogUploader.UploadLog(this.GetType().Name);
                            // add 2021-03-26 カードアプリのログをAWSにupする 孫 end

                            // 自動更新チェック
                            this.CheckUpdate();

                            // add FNSI-4200ポートを使用している 孫 start
                            // カードアプリポート管理TBを更新する
                            UpdateCardAppPort();
                            // add FNSI-4200ポートを使用している 孫 end

                            // 初回処理終了
                            bFirst = false;
                            this.m_Felica.Start();

                            // NKKFalica：処理開始

                            // ログ記録：処理開始成功
                            this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "NKKFalica処理開始");
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
                    // 実施日時日時判定
                    if (this.UpdateDateTime <= DateTime.Now && this.m_dtCheckUpdate < this.UpdateDateTime)
                    {
                        // ログ記録：処理開始成功
                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "設定時刻による更新確認, " + this.m_strCheckUpdateTime);

                        // 実施日時保持
                        this.m_dtCheckUpdate = DateTime.Now;

                        // 更新確認
                        this.CheckUpdate();
                    }

                    // add 2021-03-26 カードアプリのログをAWSにupする 孫 start
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
                    // add 2021-03-26 カードアプリのログをAWSにupする 孫 end

                    // 60秒間、又はシグナル待ち
                    if (this.m_evFinish.WaitOne(30 * 1000) == true)
                    {
                        // スレッド終了
                        break;
                    }
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
#endregion

    }
    //----------------------------------------------------------------------------------------------------
}
//----------------------------------------------------------------------------------------------------
