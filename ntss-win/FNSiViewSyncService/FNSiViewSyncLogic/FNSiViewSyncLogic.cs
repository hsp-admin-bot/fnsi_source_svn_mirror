using NKKLoggingLib;
using TdcLib;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading;
using System.IO;
using System.Net;
using System.Text.RegularExpressions;
using System.Runtime.InteropServices;
using FNSiViewSyncLogicLib.Services;
using FNSiViewSyncLogicLib.Common.Utilities;
using FNSiViewSyncLogicLib.Service;
using System.Linq;
using System.Diagnostics;
using System.Net.Sockets;


namespace FNSiViewSyncLogicLib
{
    /// <summary>
    /// FNSi View連携用DB同期ロジック
    /// </summary>
    public class FNSiViewSyncLogic
    {
        #region プライベート定義
        /// <summary>
        /// サービス名称
        /// </summary>
        private readonly String SERVICE_NAME = String.Format("{0,-20}", System.Reflection.Assembly.GetExecutingAssembly().GetName().Name);

        /// <summary>
        /// 直前で発生したエラーオブジェクト
        /// </summary>
        private Exception m_Exception = null;

        /// <summary>
        /// ログファイル識別子
        /// </summary>
        private readonly String LOG_FILE_EXT = "ViewSync";

        #region Config定義

        /// <summary>
        /// 設定ファイル名
        /// </summary>
        private readonly String CONFIG_FILE_NAME = "FNSiViewSync.config";
        /// <summary>
        /// ファイルノード名を設定する
        /// </summary>
        //private readonly String CONFIG_INITALUPDATEDDATE_SECTION = "Settings\\Common\\InitialUpdatedDate";
        /// <summary>
        /// 設定ファイル内[共通設定]セッション識別子
        /// </summary>
        private readonly String CONFIG_COMMON_SECTION = "Settings\\Common";

        /// <summary>
        /// 設定ファイル内[更新設定1]設定セッション識別子
        /// </summary>
        public static readonly String CONFIG_UPDATE_DEFINITION_1_SECTION = "Settings\\UpdateDefinition\\Definition1";

        /// <summary>
        /// 設定ファイル内[更新設定2]設定セッション識別子
        /// </summary>
        public static readonly String CONFIG_UPDATE_DEFINITION_2_SECTION = "Settings\\UpdateDefinition\\Definition2";

        /// <summary>
        /// 設定ファイル内[Socket設定]セッション識別子
        /// </summary>
        private readonly String CONFIG_SOCKET_SECTION = "Settings\\Socket";

        /// <summary>
        /// 設定ファイル内[FTP設定]セッション識別子
        /// </summary>
        private readonly String CONFIG_FTP_SECTION = "Settings\\Ftp";

        /// <summary>
        /// 設定ファイル内[ログ設定]セッション識別子
        /// </summary>
        private readonly String CONFIG_LOG_SECTION = "Settings\\Log";

        /// <summary>
        /// 設定ファイル内[同期結果設定]セッション識別子
        /// </summary>
        private readonly String CONFIG_SYNC_RESULT_SECTION = "Settings\\Result";

        #endregion

        #region XML定義
        /// <summary>
        /// XMLファイル名
        /// </summary>
        private readonly String XMLG_FILE_NAME = "FNSiViewSync.xml";

        /// <summary>
        /// 更新頻度1の出力先情報存在FLAG
        /// </summary>
        private bool m_viewTableInfo_1_Exists = false;

        /// <summary>
        /// 更新頻度2の出力先情報存在FLAG
        /// </summary>
        private bool m_viewTableInfo_2_Exists = false;

        #endregion

        /// <summary>
        /// スレッド終了用シグナル
        /// </summary>
        private readonly System.Threading.ManualResetEvent m_evFinish = new ManualResetEvent(false);

        /// <summary>
        /// スレッドオブジェクト
        /// </summary>
        private readonly Thread m_Thread = null;

        /// <summary>
        /// ポーリング周期(秒)
        /// </summary>
        public int PollingPeriod = 30 * 1000;

        /// <summary>
        /// 不要ログ削除実施日付
        /// </summary>
        private DateTime dtLogDeleteDate = DateTime.Now.Date;

        /// <summary>
        /// 不要データ削除実施日付
        /// </summary>
        private DateTime dtDataDeleteDate = DateTime.Now.Date;

        /// <summary>
        /// 同期結果の削除実施日付
        /// </summary>
        private DateTime dtResultDeleteDate = DateTime.Now.Date;

        /// <summary>
        /// FNSiSocketServiceオブジェクト
        /// </summary>
        private readonly FNSiSocketService m_socketFnsiService = new FNSiSocketService();

        /// <summary>
        /// FNSiSocketServiceオブジェクト
        /// </summary>
        private readonly FNSiLocalSocketService m_socketLocalService = new FNSiLocalSocketService();

        // 初期更新日付
        // public static String ConstInitialUpdatedDate = "";

        /// <summary>
        /// コマンド受付リスナー
        /// </summary>
        private ExternalCommandListener m_externalCommandListener;

		/// <summary>
        /// コマンド受付PORT
        /// </summary>
        // Configに出す
        private String Commandport = "";


        #endregion

        #region パブリックメソッド
        /// <summary>
        /// 32ビットモード
        /// </summary>
        public static bool Is32Mode { get { return (IntPtr.Size == 4); } }

        /// <summary>
        /// ユーザー対話モード
        /// </summary>
        public static bool IsUserMode { get { return Environment.UserInteractive; } }

        /// <summary>
        /// コンストラクタ
        /// <param name="strFolder">設定ファイル格納先フォルダ名</param>
        /// </summary>
        public FNSiViewSyncLogic(String strFolder)
        {
            try
            {
                // 初期化成功フラグ
                bool initSuccess = true;

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
                if (!sys.Load(strfile))
                {
                    // 設定読み込み失敗
                    throw (new Exception(String.Format("Config,{0}", SystemSettingInfo.GetInstance().Error.ToString())));
                }

                // Configログ設定:ログ格納先フォルダ(既定：直下のLOGフォルダ)
                FNSiViewSyncSetting.LogFolder = sys.GetSingleLineValue(CONFIG_LOG_SECTION, "LogFolder", String.Empty).Trim();
                // Configログ設定:ログ保持日数[既定：20日]
                if (Int32.TryParse(sys.GetSingleLineValue(CONFIG_LOG_SECTION, "LogKeepNumberOfDays", String.Empty).Trim(), out int nwork1) && 0 <= nwork1)
                {
                    // ログ保持日数
                    FNSiViewSyncSetting.LogKeepNumberOfDays = nwork1;
                }

                // #6843 ログアップロード LL start
                // ログ送信時刻(HHMM)
                FNSiViewSyncSetting.SendLogToBox = sys.GetSingleLineValue(CONFIG_LOG_SECTION, "SendLogToBox", string.Empty).Trim();
                FNSiViewSyncSetting.SendLogToBoxPath = sys.GetSingleLineValue(CONFIG_LOG_SECTION, "SendLogToBoxPath", string.Empty).Trim();
                // #6843 ログアップロード LL end

                // ログ設定
                NKKLogging log = NKKLogging.GetInstance();
                log.LogFolder = FNSiViewSyncSetting.LogFolder;
                log.LogExt = this.LOG_FILE_EXT;
                // #6843 ログアップロード LL start
                //log.LogTime = FNSiViewSyncSetting.SendLogToBox;
                // #6843 ログアップロード LL end
                FNSiViewSyncSetting.LogFolder = log.LogFolder;

                // ログ記録：APPモード
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, "32ビットモード:" + Is32Mode.ToString());
                // ログ記録：ユーザー対話モード
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, "ユーザー対話モード:" + IsUserMode.ToString());

                // ログ記録：初期化処理開始
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "初期化処理開始");

                #region Configファイルを読みだします

                // Config共通設定:ODBCのDSN
                FNSiViewSyncSetting.ConnectionString = sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "ConnectionString", String.Empty).Trim();
                if (String.IsNullOrEmpty(FNSiViewSyncSetting.ConnectionString))
                {
                    // ログ記録：設定無し
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + this.CONFIG_FILE_NAME + "]:ODBCは設定されていません。");
                }
                // ODBCのDSNモード
                if (!string.IsNullOrEmpty(FNSiViewSyncSetting.ConnectionString))
                {
                    string[] odbcString = FNSiViewSyncSetting.ConnectionString.Split(';');
                    foreach (string item in odbcString)
                    {
                        if (item.ToUpper().StartsWith("DSN="))
                        {
                            string dsnStr = item.Substring(4);
                            if (!IsRightfulDSN(dsnStr, Is32Mode, IsUserMode))
                            {
                                //initSuccess = false;
                            }
                            break;
                        }
                    }
                }

                // Config共通設定:データの保存先(既定：直下のDataフォルダ)
                DataFolder = sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "DataFolder", String.Empty).Trim();
                // Config共通設定:データ保持日数[既定：20日]
                if (Int32.TryParse(sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "DataKeepNumberOfDays", String.Empty).Trim(), out int nwork2) && 0 <= nwork2)
                {
                    // ログ保持日数
                    FNSiViewSyncSetting.DataKeepNumberOfDays = nwork2;
                }

                // Config共通設定:一回同期ビュー数
                if (Int32.TryParse(sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "ViewSyncCnt", String.Empty).Trim(), out int nwork6) && 0 <= nwork6)
                {
                    // 一回同期ビュー数
                    FNSiViewSyncSetting.ViewSyncCnt = nwork6;
                }

                // Config Socket設定:IFエッジサービスのIP
                FNSiViewSyncSetting.IFEdgeIPAddress = sys.GetSingleLineValue(CONFIG_SOCKET_SECTION, "IFEdgeIPAddress", "").Trim();
                if (String.IsNullOrEmpty(FNSiViewSyncSetting.IFEdgeIPAddress))
                {
                    initSuccess = false;

                    // ログ記録：設定無し
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + this.CONFIG_FILE_NAME + "]:IFエッジサービスのIPは設定されていません。");
                }
                else
                {
                    IPAddress ip = null;
                    if (!IPAddress.TryParse(FNSiViewSyncSetting.IFEdgeIPAddress, out ip))
                    {
                        initSuccess = false;

                        // ログ記録：設定無効
                        LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + this.CONFIG_FILE_NAME + "]:設定されているIFエッジサービスのIPが無効, 設定値：" + FNSiViewSyncSetting.IFEdgeIPAddress);
                    }
                }
                // Config Socket設定:IFエッジサービスのポートNo
                if (Int32.TryParse(sys.GetSingleLineValue(CONFIG_SOCKET_SECTION, "IFEdgePortNo", String.Empty).Trim(), out int nwork3))
                {
                    FNSiViewSyncSetting.IFEdgePortNo = nwork3;
                    if (FNSiViewSyncSetting.IFEdgePortNo > 65535 || FNSiViewSyncSetting.IFEdgePortNo <= 0)
                    {
                        initSuccess = false;

                        // ログ記録：設定無効
                        LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + this.CONFIG_FILE_NAME + "]:設定されているIFエッジサービスのポートNoが無効, 設定値：" + FNSiViewSyncSetting.IFEdgePortNo);
                    }
                }
                // Config Socket設定:ローカルサービスのIP
                FNSiViewSyncSetting.LocalIPAddress = sys.GetSingleLineValue(CONFIG_SOCKET_SECTION, "LocalIPAddress", "").Trim();
                if (String.IsNullOrEmpty(FNSiViewSyncSetting.LocalIPAddress))
                {
                    initSuccess = false;

                    // ログ記録：設定無し
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + this.CONFIG_FILE_NAME + "]:ローカルサービスのIPは設定されていません。");
                }
                else
                {
                    IPAddress ip = null;
                    if (!IPAddress.TryParse(FNSiViewSyncSetting.LocalIPAddress, out ip))
                    {
                        initSuccess = false;

                        // ログ記録：設定無効
                        LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + this.CONFIG_FILE_NAME + "]:設定されているローカルサービスのIPが無効, 設定値：" + FNSiViewSyncSetting.LocalIPAddress);
                    }
                }
                // Config Socket設定:ローカルサービスのポートNo
                if (Int32.TryParse(sys.GetSingleLineValue(CONFIG_SOCKET_SECTION, "LocalPortNo", String.Empty).Trim(), out int nwork4))
                {
                    FNSiViewSyncSetting.LocalPortNo = nwork4;
                    if (FNSiViewSyncSetting.LocalPortNo > 65535 || FNSiViewSyncSetting.LocalPortNo <= 0)
                    {
                        initSuccess = false;

                        // ログ記録：設定無効
                        LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + this.CONFIG_FILE_NAME + "]:設定されているローカルサービスのポートNoが無効, 設定値：" + FNSiViewSyncSetting.LocalPortNo);
                    }
                }

                // Config FTP設定:FTPのIP
                FNSiViewSyncSetting.FtpIPAddress = sys.GetSingleLineValue(CONFIG_FTP_SECTION, "FtpIPAddress", "").Trim();
                if (String.IsNullOrEmpty(FNSiViewSyncSetting.FtpIPAddress))
                {
                    initSuccess = false;

                    // ログ記録：設定無し
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + this.CONFIG_FILE_NAME + "]:FTPのIPは設定されていません。");
                }
                else
                {
                    IPAddress ip = null;
                    if (!IPAddress.TryParse(FNSiViewSyncSetting.FtpIPAddress, out ip))
                    {
                        initSuccess = false;

                        // ログ記録：設定無効
                        LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + this.CONFIG_FILE_NAME + "]:設定されているFTPのIPが無効, 設定値：" + FNSiViewSyncSetting.FtpIPAddress);
                    }
                }
                // Config FTP設定:FTPのポートNo
                if (Int32.TryParse(sys.GetSingleLineValue(CONFIG_FTP_SECTION, "FtpPortNo", String.Empty).Trim(), out int nwork5))
                {
                    FNSiViewSyncSetting.FtpPortNo = nwork5;
                    if (FNSiViewSyncSetting.FtpPortNo > 65535 || FNSiViewSyncSetting.FtpPortNo <= 0)
                    {
                        initSuccess = false;

                        // ログ記録：設定無効
                        LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + this.CONFIG_FILE_NAME + "]:設定されているFTPのポートNoが無効, 設定値：" + FNSiViewSyncSetting.FtpPortNo);
                    }
                }
                // Config FTP設定:FTPのUserId
                FNSiViewSyncSetting.FtpUserId = sys.GetSingleLineValue(CONFIG_FTP_SECTION, "FtpUserId", "").Trim();
                // Config FTP設定:FTPのパスワード
                FNSiViewSyncSetting.FtpPW = sys.GetSingleLineValue(CONFIG_FTP_SECTION, "FtpPW", "").Trim();

                // Config Socket設定:IFエッジサービスのポートNo
                if (Int32.TryParse(sys.GetSingleLineValue(CONFIG_SYNC_RESULT_SECTION, "ReSyncPortNo", String.Empty).Trim(), out int nwork10))
                {
                    FNSiViewSyncSetting.ReSyncPortNo = nwork10;
                    if (FNSiViewSyncSetting.ReSyncPortNo > 65535 || FNSiViewSyncSetting.ReSyncPortNo <= 0)
                    {
                        initSuccess = false;

                        // ログ記録：設定無効
                        LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + this.CONFIG_FILE_NAME + "]:設定されている再同期のポートNoが無効, 設定値：" + FNSiViewSyncSetting.ReSyncPortNo);
                    }
                }

                // タイムアウト時間をコンフィグから読み出し
                FNSiViewSyncSetting.TimeoutSeconds = int.Parse(sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "TimeoutSeconds", "90"));

                // SQL実行タイムアウト時間をコンフィグから読み出し
                FNSiViewSyncSetting.SqlExecuteTimeout = int.Parse(sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "SqlExecuteTimeout", "120"));

                // ログデバックモード設定
                FNSiViewSyncSetting.LogDebugMode = int.Parse(sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "LogDebugMode", "0"));

                // リトライ回数
                FNSiViewSyncSetting.XMLRetryCount = int.Parse(sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "XMLRetryCount", "30"));

                // リトライ間隔
                FNSiViewSyncSetting.XMLRetryInterval = int.Parse(sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "XMLRetryInterval", "100"));

                // LogPortを取得できない場合はポート番号7014で起動する
                Commandport = sys.GetSingleLineValue(CONFIG_LOG_SECTION, "LogPort", string.Empty).Trim();
                Commandport = string.IsNullOrEmpty(Commandport) ? "7014": Commandport;

                #endregion

                #region  Xmlファイルを読みだします
                CommonUtil.ReadViewSyncXml(XMLG_FILE_NAME);

                // 有効テーブルが設定が有りか
                if (FNSiViewSyncSetting.m_viewTableInfoListAll.Count == 0)
                {
                    initSuccess = false;

                    // ログ記録：設定無効
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + this.XMLG_FILE_NAME + "] 有効テーブルが設定されていません。");
                }
                // ログ記録：有効テーブル
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "[" + this.XMLG_FILE_NAME + "] 有効テーブル[" + FNSiViewSyncSetting.m_viewTableInfoListAll.Count + "]件。");

                #endregion

                // 初期化に失敗しました
                if (!initSuccess)
                {
                    throw (new Exception(String.Format("Config/Xml error.")));
                }

                //  ローカルサービスのポートNo を設定する
                this.m_socketFnsiService.PortNo = FNSiViewSyncSetting.LocalPortNo;

                //  再のポートNo を設定する
                this.m_socketLocalService.PortNo = FNSiViewSyncSetting.ReSyncPortNo;

                // スレッド構築
                this.m_Thread = new Thread(this.DoWork)
                {
                    Name = "FNSiViewSync処理スレッド",
                    IsBackground = false
                };

                // ログ記録：初期化処理終了
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "初期化処理終了");
            }
            catch (Exception ex)
            {
                // ログ記録：エラー
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("初期化処理,{0}", ex.Message));
                throw ex;
            }
        }

        /// <summary>
        /// デストラクタ
        /// </summary>
        ~FNSiViewSyncLogic()
        {
            if (this.m_Thread != null)
            {
                // スレッド停止
                this.m_evFinish.Set();
            }
        }

        /// <summary>
        /// 開始処理
        /// </summary>
        /// <returns></returns>
        public bool Start()
        {
            bool bret = true;

            try
            {
                // ログ記録：Start処理開始
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "Start処理開始");

                // 各種処理用オブジェクト処理開始

                // 処理開始成功時
                if (bret == true && this.m_Thread != null)
                {
                    // スレッド開始
                    this.m_Thread.Start();
                }

                this.m_externalCommandListener =new ExternalCommandListener(int.Parse(Commandport),this.OnExternalCommandReceived);

                this.m_externalCommandListener.Start();

                // ログ記録：Start処理終了
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "Start処理終了");
            }
            catch (Exception ex)
            {
                bret = false;

                // ログ記録：エラー
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("Start処理,{0}", ex.Message));
            }

            return (bret);
        }

        /// <summary>
        /// 終了処理
        /// </summary>
        public void Stop()
        {
            try
            {
                // ログ記録：Stop処理開始
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "Stop処理開始");

                // 起動中のジョブの最後の終了日時を更新
                foreach (KeyValuePair<string, JobStatus> jobStatus in FNSiViewSyncSetting.JobStatusList)
                {
                    if ((SyncCntStatus.BEGIN == FNSiViewSyncSetting.JobStatusList[jobStatus.Key].ViewSyncCntStatus) ||
                        (SyncCntStatus.END == FNSiViewSyncSetting.JobStatusList[jobStatus.Key].ViewSyncCntStatus) ||
                        (SyncCntStatus.LAST_BEGIN == FNSiViewSyncSetting.JobStatusList[jobStatus.Key].ViewSyncCntStatus))
                    {
                        ViewTableInfo viewTableInfo = FNSiViewSyncSetting.JobStatusList[jobStatus.Key].ViewTableInfo;

                        String keyName = viewTableInfo.KeyName;
                        if (keyName == null) {

                            if (jobStatus.Key.StartsWith("init_"))
                            {
                                keyName = jobStatus.Key.Substring(5);
                            }
                            else if (jobStatus.Key.StartsWith("Manual_"))
                            {
                                keyName = jobStatus.Key.Substring(7);
                            }
                            else
                            {
                                keyName = jobStatus.Key;
                            }
                        }
                        XmlService.UpdateViewXmlTableLastEndDateByName(keyName);

                        LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"{jobStatus.Key}を中断しました。");
                    }
                }

                // Timerの停止
                StopAllTimersForShutdown();
                // 通知の停止
                m_socketFnsiService.StopAllClients();

                // FNSiSocketService
                if (this.m_socketFnsiService != null)
                {
                    // 処理終了
                    this.m_socketFnsiService.Stop();

                    // 処理終了成功
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "FNSiSocketService処理終了");
                }

                // FNSitLocalSocketService
                if (this.m_socketLocalService != null)
                {
                    // 処理終了
                    this.m_socketLocalService.Stop();

                    // 処理終了成功
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "FNSitLocalSocketService処理終了");
                }

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
                        Thread.Sleep(100);
                    };
                }

                if (this.m_externalCommandListener != null)
                {
                    this.m_externalCommandListener.Stop();
                    this.m_externalCommandListener = null;
                }

                // ログ削除
                this.DeleteLogFiles();

                // データ削除
                this.DeleteDataFiles();

                // Serviceリスニング
                this.FTPServiceListener();

                // ログ記録：Stop処理終了
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "Stop処理終了");
            }
            catch (Exception ex)
            {
                // ログ記録：エラー
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("Stop処理,{0}", ex.Message));
            }

            // 自プロセス情報を取得
            var pro = System.Diagnostics.Process.GetCurrentProcess();

            // 稼働時間
            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, $"稼働時間：{DateTime.Now - pro.StartTime}, (処理開始時刻：{pro.StartTime})");
        }

        #endregion


        #region プライベートメソッド

        /// <summary>
        /// ローカルログをデバイスに送信
        /// <param name="forceFlg">アップロード強制フラグ</param>
        /// </summary>
        private void SendLog(bool forceFlg)
        {
            string date = DateTime.Now.ToString("yyyyMMdd");
            while (true)
            {
                string dateTime = date + FNSiViewSyncSetting.SendLogToBox;
                string endDate = DateTime.Now.ToString("yyyyMMddHHmm");
                if (dateTime.CompareTo(endDate) <= 0 || forceFlg)
                {
                    FNSiFtpClient fNSiFtpClient = new FNSiFtpClient(FNSiViewSyncSetting.FtpIPAddress, FNSiViewSyncSetting.FtpPortNo,
                        FNSiViewSyncSetting.FtpUserId, FNSiViewSyncSetting.FtpPW);


                    FileInfo fileInf = this.CreateZip();
                    if (fileInf != null && fileInf.Exists)
                    {
                        // zipファイルのアップロード
                        if (fNSiFtpClient.SendLogToDevice(fileInf))
                        {
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "固定時間アップロードログzip成功");
                        }
                        else
                        {
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "固定時間アップロードログzipに失敗");
                        }
                    }

                    List<string> files = fNSiFtpClient.getFileList();
                    foreach (string fileName in files)
                    {
                        fNSiFtpClient.deleteFile(fileName);
                    }

                    // logファイルを作成してアップロード
                    FileInfo fileInf2 = this.Createlog("ViewSync_");
                    if (fileInf2 != null && fileInf2.Exists)
                    {
                        // logファイルのアップロード
                        if (fNSiFtpClient.SendLogToDevice(fileInf2))
                        {
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "固定時間アップロードlogに成功");
                        }
                        else
                        {
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "固定時間アップロードlogに失敗");
                        }
                    }

                    // 手動更新アプリのlogファイルを作成してアップロード
                    FileInfo fileInf3 = this.Createlog("FNSiViewUpdateApp_");
                    if (fileInf3 != null && fileInf3.Exists)
                    {
                        // logファイルのアップロード
                        if (fNSiFtpClient.SendLogToDevice(fileInf3))
                        {
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "固定時間アップロード手動更新アプリlogに成功");
                        }
                        else
                        {
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "固定時間アップロード手動更新アプリlogに失敗");
                        }
                    }
                    date = DateTime.Now.AddDays(1).ToString("yyyyMMdd");
                }
                if (forceFlg) {
                    break;
                }
                Thread.Sleep(60000);
            }
        }

        /// <summary>
        /// Serviceリスニング
        /// </summary>
        public void FTPServiceListener()
        {
            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "FNSiViewSyncService Stopped.");
            FNSiFtpClient fNSiFtpClient = new FNSiFtpClient(FNSiViewSyncSetting.FtpIPAddress, FNSiViewSyncSetting.FtpPortNo,
                        FNSiViewSyncSetting.FtpUserId, FNSiViewSyncSetting.FtpPW);

            FileInfo fileInf = this.CreateZip();
            if (fileInf != null && fileInf.Exists)
            {
                // zipファイルのアップロード
                if (fNSiFtpClient.SendLogToDevice(fileInf))
                {
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "終了時のzipアップロードに成功");
                }
                else
                {
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "終了時のzipアップロードに失敗");
                }
            }

            // ftp上のファイルを取得する
            List<string> files = fNSiFtpClient.getFileList();
            foreach (string fileName in files)
            {
                fNSiFtpClient.deleteFile(fileName);
            }

            // logファイルを作成してアップロード
            FileInfo fileInf2 = this.Createlog("ViewSync_");
            if (fileInf2 != null && fileInf2.Exists)
            {
                // zipファイルのアップロード
                if (fNSiFtpClient.SendLogToDevice(fileInf2))
                {
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "終了時のlogアップロードに成功");
                }
                else
                {
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "終了時のlogアップロードに失敗");
                }
            }

            // 手動更新アプリのlogファイルを作成してアップロード
            FileInfo fileInf3 = this.Createlog("FNSiViewUpdateApp_");
            if (fileInf3 != null && fileInf3.Exists)
            {
                // logファイルのアップロード
                if (fNSiFtpClient.SendLogToDevice(fileInf3))
                {
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "固定時間アップロード手動更新アプリlogに成功");
                }
                else
                {
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "固定時間アップロード手動更新アプリlogに失敗");
                }
            }
        }

        private FileInfo CreateZip()
        {
            string basePath = FNSiViewSyncSetting.LogFolder == null ? AppDomain.CurrentDomain.BaseDirectory + "LOG" : FNSiViewSyncSetting.LogFolder;
            // ファイルパスの検証
            bool checkPath = this.IsValidFolderPath(basePath);
            if (!checkPath)
            {
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "LogFolderの指定されたパスが無効です。" + checkPath);
                return null;
            }

            // ログデータ
            string[] files = new string[]
            {
                //　サービスログ
                // 昨日のログ
                Path.Combine(basePath, "ViewSync_" + DateTime.Now.AddDays(-1).ToString("yyyyMMdd") + ".log"),
                // 今日のログ
                Path.Combine(basePath, "ViewSync_" + DateTime.Now.ToString("yyyyMMdd") + ".log"),
                //　手動実行アプリログ
                // 昨日のログ
                Path.Combine(basePath, "FNSiViewUpdateApp_" + DateTime.Now.AddDays(-1).ToString("yyyyMMdd") + ".log"),
                // 今日のログ
                Path.Combine(basePath, "FNSiViewUpdateApp_" + DateTime.Now.ToString("yyyyMMdd") + ".log")
            };

            string zipfilePath = basePath + "ViewSync_" + DateTime.Now.ToString("yyyyMMdd") + ".zip";
            if (File.Exists(zipfilePath))
            {
                File.Delete(zipfilePath);
            }
            bool res = TdcLib.TdcLib.CompressZipFiles(System.Text.Encoding.GetEncoding("UTF-8"), zipfilePath, files, String.Empty, String.Empty);
            if (!res)
            {
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "圧縮(zip形式)を実行するとエラーが発生しました。");
                return null;
            }
            return new FileInfo(zipfilePath);
        }

        private FileInfo Createlog(String logName)
        {
            string basePath = FNSiViewSyncSetting.LogFolder == null ? AppDomain.CurrentDomain.BaseDirectory + "LOG" : FNSiViewSyncSetting.LogFolder;
            // ファイルパスの検証
            bool checkPath = this.IsValidFolderPath(basePath);
            if (!checkPath)
            {
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "LogFolderの指定されたパスが無効です。" + checkPath);
                return null;
            }
            // 今日の日誌
            string fileName = basePath + logName + DateTime.Now.ToString("yyyyMMdd") + ".log";

            return new FileInfo(fileName);
        }

        private bool IsValidFolderPath(string val)
        {
            Regex regex = new Regex(@"^([a-zA-Z]:\\)([-\u4e00-\u9fa5\w\s.()~!@#$%^&()\[\]{}+=]+\\?)*$");
            Match result = regex.Match(val);
            return result.Success;
        }

        /// <summary>
        /// スレッド実行処理
        /// </summary>
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
                    if (bFirst)
                    {
                        // FNSiSocketService：処理開始
                        if (this.m_socketFnsiService.Start())
                        {
                            // ログ記録：処理開始成功
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "FNSiSocketService処理開始");
                        }

                        // FNSiSocketService：処理開始
                        if (this.m_socketLocalService.Start())
                        {
                            // ログ記録：処理開始成功
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "FNSiLocalSocketService処理開始");
                            this.m_socketLocalService.m_viewSyncLogic = this;
                        }

                        // ログ送信とServiceリスニング処理(初回実行)
                        // ローカルログをデバイスに送信
                        Thread timerLog = new Thread(() => this.SendLog(false))
                        {
                            Name = "Viewログ送信スレッド",
                            IsBackground = false
                        };
                        timerLog.Start();
                        LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "Viewログ送信スレッド起動");

                        // サービス開始に成功したら、初回起動フラグはtrueに設定されます。
                        // そして、初回起動の同期処理を実行します。
                        bFirst = false;

                        try
                        {
                            // 起動時に更新データ操作を行うかどうか
                            // ログ記録：処理開始成功
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, string.Format("●●●●●●●●初回起動時による更新確認, {0}●●●●●●●●", DateTime.Now.ToString("yyyy/MM/dd HH:mm")));
                            DateTime startDate = DateTime.MinValue;

                            // 初回起動時のデータ更新
                            ViewSyncService viewSyncService = new ViewSyncService();
                            viewSyncService.InitialViewSync();

                            // 間隔処理サービス
                            viewSyncService.StartIntervalUpdateServices();

                            // 固定処理サービス
                            viewSyncService.StartUpdateFixService();

                            // XMLの変更監視を開始
                            var xmlFileWatcher = new XmlFileWatcher(XMLG_FILE_NAME);
                            xmlFileWatcher.XmlChanged += RestartViewSyncThread;

                        }
                        catch (Exception ex0)
                        {
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "同期処理で復帰不能なエラーが発生しました");
                            throw ex0;
                        }
                    }

                    // ログ削除(日が変化した場合に実行)
                    if (this.dtLogDeleteDate != DateTime.Now.Date)
                    {
                        // スレッドにてログ削除を行う
                        Thread trdLog = new Thread(this.DeleteLogFiles)
                        {
                            Name = "ログ削除スレッド"
                        };
                        trdLog.Start();

                        // 不要ログ削除実施日付再設定
                        this.dtLogDeleteDate = DateTime.Now.Date;
                    }

                    // データ削除(日が変化した場合に実行)
                    if (this.dtDataDeleteDate != DateTime.Now.Date)
                    {
                        // スレッドにてログ削除を行う
                        Thread trdData = new Thread(this.DeleteDataFiles)
                        {
                            Name = "データ削除スレッド"
                        };
                        trdData.Start();

                        // 不要データ削除実施日付再設定
                        this.dtDataDeleteDate = DateTime.Now.Date;
                    }

                    // ポーリング周期(秒)、又はシグナル待ち
                    if (this.m_evFinish.WaitOne(PollingPeriod) == true)
                    {
                        // スレッド終了
                        break;
                    }
                }
                catch (Exception ex)
                {
                    this.Error = ex;
                    throw ex;
                }
            };
        }

        private void RestartViewSyncThread(object sender, XmlChangedEventArgs e)
        {
            try
            {
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "同期処理の再起動開始");
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "同期処理の停止開始");
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, $"{FNSiViewSyncSetting.Timers.Count}件のタイマーを停止開始");
                foreach (var timer in FNSiViewSyncSetting.Timers.Values)
                {
                    timer.Dispose();
                }
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, $"タイマー停止完了");
                QueueProcessor.ClearQueue();
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "同期処理の停止完了");
                FNSiViewSyncSetting.Timers.Clear();
                CommonUtil.ReadViewSyncXml(XMLG_FILE_NAME);
                ViewSyncService viewSyncService = new ViewSyncService();
                viewSyncService.InitialViewSync();
                viewSyncService.StartIntervalUpdateServices();
                viewSyncService.StartUpdateFixService();
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "同期処理を再起動完了");
            }
            catch (Exception restartViewSyncThreadException)
            {
                throw restartViewSyncThreadException;
            }
        }

        /// <summary>
        /// 指定日以前のログファイルを削除
        /// </summary>
        private void DeleteLogFiles()
        {
            // ログオブジェクト取得
            NKKLogging log = NKKLogging.GetInstance();

            // ログ削除
            log.DeleteLogFiles(this.SERVICE_NAME, FNSiViewSyncSetting.LogKeepNumberOfDays, true);
        }

        /// <summary>
        /// 更新データファイル格納先フォルダの参照/設定用プロパティ
        /// </summary>
        private String DataFolder
        {
            get { return (FNSiViewSyncSetting.DataFolder); }
            set
            {
                String strfolder = value;

                // 更新データ保存先フォルダの指定チェック
                if (String.IsNullOrEmpty(strfolder) == true)
                {
                    // 未指定

                    // 未指定の場合は実行ファイルの格納先\Dataフォルダとする
                    strfolder = AppDomain.CurrentDomain.BaseDirectory;
                    strfolder += "\\Data";
                }

                // 末尾の\付加
                if (strfolder.EndsWith("\\") == false)
                    strfolder += "\\";

                // 更新データ格納先が存在しない場合、パスを作成します。
                if (!System.IO.Directory.Exists(strfolder))
                {
                    try
                    {
                        System.IO.Directory.CreateDirectory(strfolder);
                    }
                    catch (Exception ex)
                    {
                        // ログ記録
                        LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("DeleteDataFiles(),Failed to create path:{0},{1}", strfolder, ex.ToString()));

                        // 更新データファイル格納先フォルダはベースディレクトリを設定する
                        strfolder = AppDomain.CurrentDomain.BaseDirectory;
                        LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("DeleteDataFiles(),Using path:{0}", strfolder));
                    }
                }

                // 更新データファイル保存先を設定する
                FNSiViewSyncSetting.DataFolder = strfolder;
            }
        }

        /// <summary>
        /// 指定日以前のデータファイルを削除
        /// </summary>
        private void DeleteDataFiles()
        {
            // 削除対象基準日時を作成
            DateTime dtdelbase = DateTime.Now.AddDays(-1 * FNSiViewSyncSetting.DataKeepNumberOfDays);

            int ndelFoldercount = 0;
            foreach (var dir in System.IO.Directory.GetDirectories(DataFolder, "*", System.IO.SearchOption.TopDirectoryOnly))
            {
                string name = System.IO.Path.GetFileName(dir);
                if (name?.Length == 8 && System.Text.RegularExpressions.Regex.IsMatch(name, @"^\d{8}$"))
                {
                    if (DateTime.TryParseExact(name, "yyyyMMdd", System.Globalization.CultureInfo.InvariantCulture,
                                               System.Globalization.DateTimeStyles.None, out var folderDate))
                    {
                        if (folderDate < dtdelbase.Date)
                        {
                            try
                            {
                                System.IO.Directory.Delete(dir, true);
                                ndelFoldercount++;
                            }
                            catch (Exception ex)
                            {
                                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR,
                                    $"DeleteDataFiles():FolderDelete:{dir},{ex}");
                            }
                        }
                    }
                }
            }

            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO,
                $" データフォルダ削除,{dtdelbase:yyyy/MM/dd HH:mm:ss}以前,{ndelFoldercount}件削除");
        }

        /// <summary>
        /// 直前に発生したエラーオブジェクト取得/設定用プロパティ
        /// </summary>
        private Exception Error
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
                    LogService.AddLogInfo(dtlog, NKKLogging.LOGGING_CLASS.ERROR, strlogdata);
                }
            }
        }


        /// <summary>
        /// DNSが正しいかどうか判断します。
        /// </summary>
        /// <param name="dsnName">DSN名</param>
        /// <param name="is32Mode">32ビットモード</param>
        /// <param name="isUserMode">ユーザー対話モード</param>
        private bool IsRightfulDSN(String dsnName, bool is32Mode, bool isUserMode)
        {
            if (String.IsNullOrEmpty(dsnName))
            {
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + this.CONFIG_FILE_NAME + "]:ODBCのDSNが無し。");
                return false;
            }

            try
            {
                // APPは32ビット
                if (is32Mode)
                {

                    int SQL_FETCH_FIRST_USER = 31;
                    int SQL_FETCH_FIRST_SYSTEM = 32;

                    // ユーザー対話モード
                    if (isUserMode)
                    {
                        if (!IsRightfulDSN32(dsnName, SQL_FETCH_FIRST_USER))
                        {
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + this.CONFIG_FILE_NAME + "]:ODBCのDSN[" + dsnName + "]は32ビットのユーザDSNに設定されていない。");
                            return false;
                        }
                    }
                    else
                    {
                        if (!IsRightfulDSN32(dsnName, SQL_FETCH_FIRST_SYSTEM))
                        {
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + this.CONFIG_FILE_NAME + "]:ODBCのDSN[" + dsnName + "]は32ビットのシステムDSNに設定されていない。");
                            return false;
                        }
                    }
                }
                else
                {
                    // APPは64ビット
                    long SQL_FETCH_FIRST_USER = 31;
                    long SQL_FETCH_FIRST_SYSTEM = 32;

                    // ユーザー対話モード
                    if (isUserMode)
                    {
                        if (!IsRightfulDSN64(dsnName, SQL_FETCH_FIRST_USER))
                        {
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + this.CONFIG_FILE_NAME + "]:ODBCのDSN[" + dsnName + "]は64ビットのユーザDSNに設定されていない。");
                            return false;
                        }
                    }
                    else
                    {
                        if (!IsRightfulDSN64(dsnName, SQL_FETCH_FIRST_SYSTEM))
                        {
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + this.CONFIG_FILE_NAME + "]:ODBCのDSN[" + dsnName + "]は64ビットのシステムDSNに設定されていない。");
                            return false;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, ex.Message);
                return false;
            }
            return true;
        }

        private static class OdbcWrapper32
        {
            [DllImport("odbc32.dll")]
            public static extern int SQLDataSources(int EnvHandle, int Direction, StringBuilder ServerName, int ServerNameBufferLenIn,
                ref int ServerNameBufferLenOut, StringBuilder Driver, int DriverBufferLenIn, ref int DriverBufferLenOut);

            [DllImport("odbc32.dll")]
            public static extern int SQLAllocEnv(ref int EnvHandle);
        }

        private bool IsRightfulDSN32(String dsnName, int direction)
        {
            int SQL_FETCH_NEXT = 1;
            int envHandle = 0;

            if (OdbcWrapper32.SQLAllocEnv(ref envHandle) != -1)
            {
                int ret;
                StringBuilder serverName = new StringBuilder(1024);
                StringBuilder driverName = new StringBuilder(1024);
                int snLen = 0;
                int driverLen = 0;
                ret = OdbcWrapper32.SQLDataSources(envHandle, direction, serverName, serverName.Capacity, ref snLen,
                            driverName, driverName.Capacity, ref driverLen);
                while (ret == 0)
                {
                    // 有りか
                    if (dsnName.Equals(serverName.ToString()))
                    {
                        return true;
                    }
                    //LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "32ビット-" + (direction == 31 ? "ユーザーDSN" : "システムDSN") + " [" + serverName + "]:[" + driverName + "]");
                    ret = OdbcWrapper32.SQLDataSources(envHandle, SQL_FETCH_NEXT, serverName, serverName.Capacity, ref snLen,
                            driverName, driverName.Capacity, ref driverLen);
                }
            }
            return false;
        }

        public static class OdbcWrapper64
        {
            [DllImport("odbc32.dll")]
            internal static extern int SQLDataSources(long EnvHandle, long Direction, StringBuilder ServerName, long ServerNameBufferLenIn,
            ref long ServerNameBufferLenOut, StringBuilder Driver, long DriverBufferLenIn, ref long DriverBufferLenOut);

            [DllImport("odbc32.dll")]
            internal static extern int SQLAllocEnv(ref long EnvHandle);
        }

        private bool IsRightfulDSN64(String dsnName, long direction)
        {
            long SQL_FETCH_NEXT = 1;
            long envHandle = 0;

            if (OdbcWrapper64.SQLAllocEnv(ref envHandle) != -1)
            {
                long ret;
                StringBuilder serverName = new StringBuilder(1024);
                StringBuilder driverName = new StringBuilder(1024);
                long snLen = 0;
                long driverLen = 0;
                ret = OdbcWrapper64.SQLDataSources(envHandle, direction, serverName, serverName.Capacity, ref snLen,
                            driverName, driverName.Capacity, ref driverLen);

                while (ret == 0)
                {
                    // 有りか
                    if (dsnName.Equals(serverName.ToString()))
                    {
                        return true;
                    }
                    //LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "64ビット-" + (direction == 31? "ユーザーDSN" : "システムDSN") + " [" + serverName + "]:[" + driverName + "]");
                    ret = OdbcWrapper64.SQLDataSources(envHandle, SQL_FETCH_NEXT, serverName, serverName.Capacity, ref snLen,
                            driverName, driverName.Capacity, ref driverLen);
                }
            }
            return false;
        }
        #endregion
        /// <summary>
        /// timer停止メソッド
        /// </summary>
        public void StopAllTimersForShutdown()
        {
            if (FNSiViewSyncSetting.Timers.Count == 0)
                return;

            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO,
                $"Timer停止開始: {FNSiViewSyncSetting.Timers.Count}件");

            var keys = FNSiViewSyncSetting.Timers.Keys.ToList();

            foreach (var key in keys)
            {
                var timer = FNSiViewSyncSetting.Timers[key];
                if (timer == null) continue;
                
                try
                {
                    // 新規timerの停止
                    timer.Change(Timeout.Infinite, Timeout.Infinite);
                    // timerの解放
                    timer.Dispose();
                }
                catch (Exception ex)
                {
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR,
                        $"Timer停止中例外: {key} - {ex.Message}");

                }
            }
            // timerリストのクリア
            FNSiViewSyncSetting.Timers.Clear();
            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "Timer停止完了");
        }

        /// <summary>
        /// 外部コマンド受信
        /// </summary>
        private void OnExternalCommandReceived(string cmd)
        {
            //ログ強制アップロード
            if ("logUpload".Equals(cmd))
            {
                SendLog(true);
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO,
                string.Format("External command received: [{0}]", cmd));
            }

            
        }
    }
}