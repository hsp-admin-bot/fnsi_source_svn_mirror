using NKKLoggingLib;
using TdcLib;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.IO;
using System.Xml;
using System.Collections;
using System.Net;
using System.Reflection;
using System.Text.RegularExpressions;
using jp.co.nikkiso.fn3.Cooperation.CoopComPlugIn;

namespace FNSiCSILogicLib
{
    /// <summary>
    /// FNSi 連携用DB同期ロジック
    /// </summary>
    public class FNSiCSILogic
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
        private readonly String LOG_FILE_EXT = "CSI";

        #region Config定義

        /// <summary>
        /// 設定ファイル名
        /// </summary>
        private readonly String CONFIG_FILE_NAME = "FNSiCSI.config";

        /// <summary>
        /// 設定ファイル内[共通設定]セッション識別子
        /// </summary>
        public static String CONFIG_COMMON_SECTION = "Settings\\Common";

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
        /// ログ送信スレッド
        /// </summary>
        private readonly Thread m_SendLogThread = null;

        /// <summary>
        /// ポーリング周期(秒)
        /// </summary>
        public int PollingPeriod = 30 * 1000;

        /// <summary>
        /// 不要ログ削除実施日付
        /// </summary>
        private DateTime dtLogDeleteDate = DateTime.Now.Date;

        /// <summary>
        /// FNSiSocketServiceオブジェクト
        /// </summary>
        private readonly FNSiSocketService m_socketFnsiService = null;

        private String path = AppDomain.CurrentDomain.BaseDirectory;

        /// <summary>
        /// CSIDllInfoFile情報配列
        /// </summary>
        private ArrayList m_CSIDllInfoFiles = new ArrayList();

        /// <summary>
        /// 32ビットモード
        /// </summary>
        public static bool Is32Mode { get { return (IntPtr.Size == 4); } }
        #endregion


        #region パブリックメソッド

        /// <summary>
        /// コンストラクタ
        /// <param name="strFolder">設定ファイル格納先フォルダ名</param>
        /// </summary>
        public FNSiCSILogic(String strFolder)
        {
            try
            {
                // 初期化成功フラグ
                bool initSuccess = true;
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

                // Configログ設定:ログ格納先フォルダ(既定：直下のLOGフォルダ)
                FNSiCSISetting.LogFolder = sys.GetSingleLineValue(CONFIG_LOG_SECTION, "LogFolder", String.Empty).Trim();

                // ログ送信時刻(HHMM)
                FNSiCSISetting.SendLogToBox = sys.GetSingleLineValue(CONFIG_LOG_SECTION, "SendLogToBox", string.Empty).Trim();
                FNSiCSISetting.SendLogToBoxPath = sys.GetSingleLineValue(CONFIG_LOG_SECTION, "SendLogToBoxPath", string.Empty).Trim();
                if (FNSiCSISetting.SendLogToBoxPath.Length > 0 && FNSiCSISetting.SendLogToBoxPath[FNSiCSISetting.SendLogToBoxPath.Length - 1] != '/')
                {
                    FNSiCSISetting.SendLogToBoxPath += "/";
                }

                // ログ設定
                NKKLogging log = NKKLogging.GetInstance();
                log.LogFolder = FNSiCSISetting.LogFolder;
                log.LogExt = this.LOG_FILE_EXT;

                // ログ記録：APPモード
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "32ビットモード:" + Is32Mode.ToString());

                // ログ記録：初期化処理開始
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "初期化処理開始");

                // Config共通設定:データの保存先(既定：直下のDataフォルダ)
                DataFolder = sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "DataFolder", String.Empty).Trim();
                // Config共通設定:データ保持日数[既定：20日]
                if (Int32.TryParse(sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "DataKeepNumberOfDays", String.Empty).Trim(), out int nwork0) && 0 <= nwork0)
                {
                    // ログ保持日数
                    FNSiCSISetting.LogKeepNumberOfDays = nwork0;
                }

                // Config共通設定:SysCoopIniFileName
                FNSiCSISetting.SysCoopIniFileName = sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "SysCoopIniFileName", String.Empty).Trim();

                // Config Socket設定:IFエッジサービスのIP
                FNSiCSISetting.IFEdgeIPAddress = sys.GetSingleLineValue(CONFIG_SOCKET_SECTION, "IFEdgeIPAddress", "").Trim();
                if (String.IsNullOrEmpty(FNSiCSISetting.IFEdgeIPAddress))
                {
                    initSuccess = false;

                    // ログ記録：設定無し
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "[" + this.CONFIG_FILE_NAME + "]:IFエッジサービスのIPは設定されていません。");
                }
                else
                {
                    IPAddress ip = null;
                    if (!IPAddress.TryParse(FNSiCSISetting.IFEdgeIPAddress, out ip))
                    {
                        initSuccess = false;

                        // ログ記録：設定無効
                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + this.CONFIG_FILE_NAME + "]:設定されているIFエッジサービスのIPが無効, 設定値：" + FNSiCSISetting.IFEdgeIPAddress);
                    }
                }

                // Config Socket設定:IFエッジサービスのポートNo
                if (Int32.TryParse(sys.GetSingleLineValue(CONFIG_SOCKET_SECTION, "IFEdgePatientPortNo", String.Empty).Trim(), out int nwork1))
                {
                    FNSiCSISetting.IFEdgePatientPortNo = nwork1;
                    if (FNSiCSISetting.IFEdgePatientPortNo > 65535 || FNSiCSISetting.IFEdgePatientPortNo <= 0)
                    {
                        initSuccess = false;

                        // ログ記録：設定無効
                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + this.CONFIG_FILE_NAME + "]:設定されているIFエッジサービスのポートNoが無効, 設定値：" + FNSiCSISetting.IFEdgePatientPortNo);
                    }
                }

                // Config Socket設定:IFエッジサービスのポートNo
                if (Int32.TryParse(sys.GetSingleLineValue(CONFIG_SOCKET_SECTION, "IFEdgeExaminPortNo", String.Empty).Trim(), out int nwork2))
                {
                    FNSiCSISetting.IFEdgeExaminPortNo = nwork2;
                    if (FNSiCSISetting.IFEdgeExaminPortNo > 65535 || FNSiCSISetting.IFEdgeExaminPortNo <= 0)
                    {
                        initSuccess = false;

                        // ログ記録：設定無効
                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + this.CONFIG_FILE_NAME + "]:設定されているIFエッジサービスのポートNoが無効, 設定値：" + FNSiCSISetting.IFEdgeExaminPortNo);
                    }
                }

                // Config Socket設定:ローカルサービスのポートNo
                if (Int32.TryParse(sys.GetSingleLineValue(CONFIG_SOCKET_SECTION, "LocalPortNo", String.Empty).Trim(), out int nwork4))
                {
                    FNSiCSISetting.LocalPortNo = nwork4;
                    if (FNSiCSISetting.LocalPortNo > 65535 || FNSiCSISetting.LocalPortNo <= 0)
                    {
                        initSuccess = false;

                        // ログ記録：設定無効
                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + this.CONFIG_FILE_NAME + "]:設定されているローカルサービスのポートNoが無効, 設定値：" + FNSiCSISetting.LocalPortNo);
                    }
                }

                // Config FTP設定:FTPのIP
                FNSiCSISetting.FtpIPAddress = sys.GetSingleLineValue(CONFIG_FTP_SECTION, "FtpIPAddress", "").Trim();
                if (String.IsNullOrEmpty(FNSiCSISetting.FtpIPAddress))
                {
                    initSuccess = false;

                    // ログ記録：設定無し
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "[" + this.CONFIG_FILE_NAME + "]:FTPのIPは設定されていません。");
                }
                else
                {
                    IPAddress ip = null;
                    if (!IPAddress.TryParse(FNSiCSISetting.FtpIPAddress, out ip))
                    {
                        initSuccess = false;

                        // ログ記録：設定無効
                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + this.CONFIG_FILE_NAME + "]:設定されているFTPのIPが無効, 設定値：" + FNSiCSISetting.FtpIPAddress);
                    }
                }
                // Config FTP設定:FTPのポートNo
                if (Int32.TryParse(sys.GetSingleLineValue(CONFIG_FTP_SECTION, "FtpPortNo", String.Empty).Trim(), out int nwork5))
                {
                    FNSiCSISetting.FtpPortNo = nwork5;
                    if (FNSiCSISetting.FtpPortNo > 65535 || FNSiCSISetting.FtpPortNo <= 0)
                    {
                        initSuccess = false;

                        // ログ記録：設定無効
                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + this.CONFIG_FILE_NAME + "]:設定されているFTPのポートNoが無効, 設定値：" + FNSiCSISetting.FtpPortNo);
                    }
                }
                // Config FTP設定:FTPのUserId
                FNSiCSISetting.FtpUserId = sys.GetSingleLineValue(CONFIG_FTP_SECTION, "FtpUserId", "").Trim();
                // Config FTP設定:FTPのパスワード
                FNSiCSISetting.FtpPW = sys.GetSingleLineValue(CONFIG_FTP_SECTION, "FtpPW", "").Trim();

                // Config DebugMode設定
                FNSiCSISetting.DebugMode = sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "DebugMode", "").Trim();
                if (String.IsNullOrEmpty(FNSiCSISetting.DebugMode))
                {
                    FNSiCSISetting.DebugMode = "false";
                }

                // 初期化に失敗しました
                if (!initSuccess)
                {
                    throw (new Exception(String.Format("Config error.")));
                }

                // CSIDllFiles読み込み
                this.loadCSIDllFiles();

                m_socketFnsiService = new FNSiSocketService();

                //  ローカルサービスのポートNo を設定する
                this.m_socketFnsiService.PortNo = FNSiCSISetting.LocalPortNo;
                this.m_socketFnsiService.CSIDllInfoList = m_CSIDllInfoFiles;

                // スレッド構築
                this.m_Thread = new Thread(this.DoWork)
                {
                    Name = "FNSiCSI処理スレッド",
                    IsBackground = false
                };

                // ログ送信とServiceリスニング処理(初回実行)
                // ローカルログをデバイスに送信
                this.m_SendLogThread = new Thread(this.DoSendLog)
                {
                    Name = "ログ送信スレッド",
                    IsBackground = false
                };

                // ログ記録：初期化処理終了
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "初期化処理終了");
            }
            catch (Exception ex)
            {
                // ログ記録：エラー
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("初期化処理,{0}", ex.Message));

                throw ex;
            }
        }

        /// <summary>
        /// デストラクタ
        /// </summary>
        ~FNSiCSILogic()
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
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "Start処理開始");

                // 各種処理用オブジェクト処理開始

                // 処理開始成功時
                if (this.m_Thread != null)
                {
                    // スレッド開始
                    this.m_Thread.Start();
                }

                if (this.m_SendLogThread != null)
                {
                    this.m_SendLogThread.Start();
                }

                // ログ記録：Start処理終了
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "Start処理終了");
            }
            catch (Exception ex)
            {
                bret = false;

                // ログ記録：エラー
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("Start処理,{0}", ex.Message));
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
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "Stop処理開始");

                // FNSiSocketService
                if (this.m_socketFnsiService != null)
                {
                    // 処理終了
                    this.m_socketFnsiService.Stop();

                    // 処理終了成功
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "FNSiSocketService処理終了");
                }

                // メインスレッド停止
                if (this.m_Thread != null)
                {
                    // カウンタ値初期化
                    uint dwtickcount = (uint)System.Environment.TickCount;

                    // スレッド停止
                    this.m_evFinish.Set();

                    // スレッドが終了するか10秒間待つ
                    while (!TdcLib.TdcLib.CheckTickCount(10 * 1000, dwtickcount, (uint)System.Environment.TickCount))
                    {
                        // スレッドが終了した場合
                        if (this.m_Thread.IsAlive == false && this.m_SendLogThread.IsAlive == false)
                        {
                            // 処理を抜ける
                            break;
                        }
                    };
                }

                // ログ削除
                this.DeleteLogFiles();

                // Serviceリスニング
                this.SendLog();

                // ログ記録：Stop処理終了
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "Stop処理終了");
            }
            catch (Exception ex)
            {
                // ログ記録：エラー
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("Stop処理,{0}", ex.Message));
            }

            // 自プロセス情報を取得
            var pro = System.Diagnostics.Process.GetCurrentProcess();

            // 稼働時間
            this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, $"稼働時間：{DateTime.Now - pro.StartTime}, (処理開始時刻：{pro.StartTime})");
        }

        #endregion


        #region プライベートメソッド

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
                    if (bFirst == true)
                    {
                        // FNSiSocketService：処理開始
                        if (this.m_socketFnsiService.Start())
                        {
                            // ログ記録：処理開始成功
                            this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "FNSiSocketService処理開始");
                        }

                        // 初回処理終了
                        bFirst = false;
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

                    // ポーリング周期(秒)、又はシグナル待ち
                    if (this.m_evFinish.WaitOne(PollingPeriod) == true)
                    {
                        // スレッド終了
                        break;
                    }
                }
                catch (Exception ex)
                {
                    this.m_evFinish.Close();
                    this.Error = ex;
                }
            };
        }

        /// <summary>
        /// ローカルログをデバイスに送信
        /// </summary>
        private void DoSendLog()
        {
            this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "ログ送信スレッド");

            string date = DateTime.Now.ToString("yyyyMMdd");

            while (true)
            {               
                string dateTime = date + FNSiCSISetting.SendLogToBox;
                string endDate = DateTime.Now.ToString("yyyyMMddHHmm");
                if (dateTime.CompareTo(endDate) <= 0)
                {
                    this.SendLog();
                    date = DateTime.Now.AddDays(1).ToString("yyyyMMdd");
                }

                // ポーリング周期(秒)、又はシグナル待ち
                if (this.m_evFinish.WaitOne(PollingPeriod) == true)
                {
                    // スレッド終了
                    break;
                }
            }
        }

        /// <summary>
        /// ローカルログをデバイスに送信
        /// </summary>
        public void SendLog()
        {
            FNSiFtpClient fNSiFtpClient = new FNSiFtpClient(FNSiCSISetting.FtpIPAddress, FNSiCSISetting.FtpPortNo,
                        FNSiCSISetting.FtpUserId, FNSiCSISetting.FtpPW);

            List<FileInfo> logFileInfs = null;
            List<FileInfo> dumpFileInfs = null;
            List<FileInfo> dataFileInfs = null;
            if(!this.CreateZip(out logFileInfs, out dumpFileInfs, out dataFileInfs))
            {
                return;
            }

            // ログを送信する
            foreach (FileInfo fileInf in logFileInfs)
            {
                if (fileInf != null && fileInf.Exists)
                {
                    // zipファイルのアップロード
                    if (fNSiFtpClient.SendLogToDevice(fileInf))
                    {
                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "zipアップロードに成功");
                    }
                    else
                    {
                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "zipアップロードに失敗");
                    }
                }
            }

            // ダンプを送信する
            foreach (FileInfo fileInf in dumpFileInfs)
            {
                if (fileInf != null && fileInf.Exists)
                {
                    // zipファイルのアップロード
                    if (fNSiFtpClient.SendDumpToDevice(fileInf))
                    {
                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "zipアップロードに成功");
                    }
                    else
                    {
                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "zipアップロードに失敗");
                    }
                }
            }

            // データを送信する
            foreach (FileInfo fileInf in dataFileInfs)
            {
                if (fileInf != null && fileInf.Exists)
                {
                    // zipファイルのアップロード
                    if (fNSiFtpClient.SendDataToDevice(fileInf))
                    {
                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "zipアップロードに成功");
                    }
                    else
                    {
                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "zipアップロードに失敗");
                    }
                }
            }
        }

        /// <summary>
        /// デバイスに送信するファイルをZipにする
        /// </summary>
        private bool CreateZip(out List<FileInfo> logZipFiles, out List<FileInfo> dumpZipFiles, out List<FileInfo> dataZipFiles)
        {
            logZipFiles = new List<FileInfo>();
            dumpZipFiles = new List<FileInfo>();
            dataZipFiles = new List<FileInfo>();
            bool res = true;
            string zipfilePath = string.Empty;

            #region LOG

            // ログのパス
            string basePath = string.IsNullOrEmpty(FNSiCSISetting.LogFolder) ? AppDomain.CurrentDomain.BaseDirectory + "LOG" : FNSiCSISetting.LogFolder;
            //// 今日のログ
            string todayCSILog = basePath + "\\CSI_" + DateTime.Now.ToString("yyyyMMdd") + ".LOG";

            // ファイルリストを取得する
            List<string> logFilePaths = new List<string>();
            if (this.IsValidFolderPath(basePath) && Directory.Exists(basePath))
            {
                logFilePaths.AddRange(Directory.GetFiles(basePath));
            }

            foreach (string filePath in logFilePaths)
            {
                // ZIPファイルならZIPにする必要ないので、送るようのリストに追加する。
                if (filePath.Contains(".zip"))
                {
                    logZipFiles.Add(new FileInfo(filePath));
                }
                else
                {
                    // ZIPにする
                    zipfilePath = filePath.Substring(0, filePath.Length - 4) + ".zip";
                    res = TdcLib.TdcLib.CompressZipFile(System.Text.Encoding.GetEncoding("UTF-8"), zipfilePath, filePath, String.Empty, String.Empty);

                    if (!res)
                    {
                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "圧縮(zip形式)を実行するとエラーが発生しました。");
                    }
                    else
                    {

                        logZipFiles.Add(new FileInfo(zipfilePath));

                        // 今日のログではないなら削除する
                        if (filePath.CompareTo(todayCSILog) != 0)
                        {
                            File.Delete(filePath);
                        }
                    }
                }
            }

            #endregion

            #region DUMP

            // Dumpのパス
            string lastMonthPath = basePath + "\\" + DateTime.Now.AddMonths(-1).ToString("yyyyMM");
            string thisMonthPath = basePath + "\\" + DateTime.Now.ToString("yyyyMM");

            res = true;
            zipfilePath = string.Empty;
            List<string> dumpFilePaths = new List<string>();

            // Dumpファイルリストを取得する
            if (this.IsValidFolderPath(lastMonthPath) && Directory.Exists(lastMonthPath))
            {
                dumpFilePaths.AddRange(Directory.GetFiles(lastMonthPath));
            }
            if (this.IsValidFolderPath(thisMonthPath) && Directory.Exists(thisMonthPath))
            {
                dumpFilePaths.AddRange(Directory.GetFiles(thisMonthPath));
            }

            foreach (string filePath in dumpFilePaths)
            {
                // ZIPファイルならZIPにする必要ないので、送るようのリストに追加する。
                if (filePath.Contains(".zip"))
                {
                    dumpZipFiles.Add(new FileInfo(filePath));
                }
                else
                {
                    // ZIPにする
                    zipfilePath = filePath.Substring(0, filePath.Length - 4) + ".zip";
                    res = TdcLib.TdcLib.CompressZipFile(System.Text.Encoding.GetEncoding("UTF-8"), zipfilePath, filePath, String.Empty, String.Empty);

                    if (!res)
                    {
                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "圧縮(zip形式)を実行するとエラーが発生しました。");
                    }
                    else
                    {

                        dumpZipFiles.Add(new FileInfo(zipfilePath));

                        // ZIPした後に、元のファイルを削除する
                        File.Delete(filePath);
                    }
                }
            }

            #endregion

            #region DATA

            // Dataのパス
            string dataPath = AppDomain.CurrentDomain.BaseDirectory + "Data";

            res = true;
            zipfilePath = string.Empty;
            List<string> dataFilePaths = new List<string>();

            // Dataファイルリストを取得する
            if (this.IsValidFolderPath(dataPath) && Directory.Exists(dataPath))
            {
                dataFilePaths.AddRange(Directory.GetFiles(dataPath));
            }

            foreach (string filePath in dataFilePaths)
            {
                // ZIPファイルならZIPにする必要ないので、送るようのリストに追加する。
                if (filePath.Contains(".zip"))
                {
                    dataZipFiles.Add(new FileInfo(filePath));
                }
                else
                {
                    // ZIPにする
                    zipfilePath = filePath.Substring(0, filePath.Length - 4) + ".zip";
                    res = TdcLib.TdcLib.CompressZipFile(System.Text.Encoding.GetEncoding("UTF-8"), zipfilePath, filePath, String.Empty, String.Empty);

                    if (!res)
                    {
                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "圧縮(zip形式)を実行するとエラーが発生しました。");
                    }
                    else
                    {

                        dataZipFiles.Add(new FileInfo(zipfilePath));

                        // ZIPした後に、元のファイルを削除する
                        File.Delete(filePath);
                    }
                }
            }

            #endregion

            return true;
        }

        /// <summary>
        /// パスをチェックする
        /// </summary>
        private bool IsValidFolderPath(string val)
        {
            Regex regex = new Regex(@"^([a-zA-Z]:\\)([-\u4e00-\u9fa5\w\s.()~!@#$%^&()\[\]{}+=]+\\?)*$");
            Match result = regex.Match(val);
            return result.Success;
        }


        /// <summary>
        /// CSIDllFiles読み込み
        /// </summary>
        private void loadCSIDllFiles()
        {
            try
            {
                //.dllファイルを探す
                string[] dlls = System.IO.Directory.GetFiles(path, "*.dll");

                string ipluginName = typeof(IFn3ComPlugIn).FullName;

                foreach (string dll in dlls)
                {
                    try
                    {
                        //アセンブリとして読み込む
                        System.Reflection.Assembly asm = System.Reflection.Assembly.LoadFrom(dll);
                        Fn3ComPlugIn iPlugin = null;
                        foreach (Type t in asm.GetTypes())
                        {
                            //アセンブリ内のすべての型について、
                            //プラグインとして有効か調べる
                            if (t.IsClass && t.IsPublic && !t.IsAbstract &&
                                t.GetInterface(ipluginName) != null)
                            {
                                iPlugin = Activator.CreateInstance(t, BindingFlags.CreateInstance, null, null, null) as Fn3ComPlugIn;
                                m_CSIDllInfoFiles.Add(iPlugin);

                                break;
                            }
                        }
                    }
                    catch
                    {
                    }
                }
            }
            catch (Exception ex)
            {
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("loadCSIDllFiles,{0}", ex.Message));
            }
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
                    this.AddLogInfo(dtlog, NKKLogging.LOGGING_CLASS.ERROR, strlogdata);
                }
            }
        }

        /// <summary>
        /// 更新データファイル格納先フォルダの参照/設定用プロパティ
        /// </summary>
        private String DataFolder
        {
            get { return (FNSiCSISetting.DataFolder); }
            set
            {
                String strfolder = value;

                // 更新データ保存先フォルダの指定チェック
                if (String.IsNullOrEmpty(strfolder) == true)
                {
                    // 未指定

                    // 未指定の場合は実行ファイルの格納先\Dataフォルダとする
                    strfolder = AppDomain.CurrentDomain.BaseDirectory;
                    strfolder += "Data";
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
                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("DeleteDataFiles(),Failed to create path:{0},{1}", strfolder, ex.ToString()));

                        // 更新データファイル格納先フォルダはベースディレクトリを設定する
                        strfolder = AppDomain.CurrentDomain.BaseDirectory;
                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("DeleteDataFiles(),Using path:{0}", strfolder));
                    }
                }

                // 更新データファイル保存先を設定する
                FNSiCSISetting.DataFolder = strfolder;
            }
        }

        /// <summary>
        /// ログ記録
        /// </summary>
        /// <param name="dtNow">発生日時</param>
        /// <param name="LoggingClass">ログ区分</param>
        /// <param name="strMesssage">記録メッセージ</param>
        private void AddLogInfo(DateTime dtNow, NKKLogging.LOGGING_CLASS LoggingClass, String strMesssage)
        {
            // ログオブジェクト取得
            NKKLogging log = NKKLogging.GetInstance();

            // ログ記録
            log.AddLogInfo(dtNow, SERVICE_NAME, LoggingClass, strMesssage);
        }

        /// <summary>
        /// 指定日以前のログファイルを削除
        /// </summary>
        private void DeleteLogFiles()
        {
            // ログオブジェクト取得
            NKKLogging log = NKKLogging.GetInstance();

            // ログ削除
            log.DeleteLogFiles(this.SERVICE_NAME, FNSiCSISetting.LogKeepNumberOfDays, true);

            // データファイルを削除
            this.DeleteDataFiles();
        }

        /// <summary>
        /// 指定日以前のデータファイルを削除
        /// </summary>
        private void DeleteDataFiles()
        {
            // データファイル名のフォーマット(例えば：CSI_20210908150937314_profile_filesocket.dmp)
            const String strSearchPattern = ".*\\d{4}\\d{2}\\d{2}.*.(DMP|dmp)$";

            try
            {
                // 保持するデータファイルの日数が1以上の場合
                if (0 < FNSiCSISetting.LogKeepNumberOfDays)
                {
                    int ndelcount = 0;
                    String strfilename;

                    // 削除対象基準日時を作成
                    DateTime dtdelbase = DateTime.Now.AddDays(-1 * FNSiCSISetting.LogKeepNumberOfDays);

                    // 正規表現によるファイル名マッチングパターン登録
                    Regex reg = new Regex(strSearchPattern, RegexOptions.IgnoreCase);

                    // データファイル格納先に格納されているファイルを全て取得する
                    String[] datafiles = System.IO.Directory.GetFiles(path + "/Data", "*.*", System.IO.SearchOption.TopDirectoryOnly);
                    foreach (String strfile in datafiles)
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
                            this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("DeleteDataFiles(),File:{0},{1}", strfile, ex.ToString()));
                        }
                    }

                    // ログ記録
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("データファイル削除,{0:yyyy/MM/dd HH:mm:ss}以前,{1}件削除", dtdelbase, ndelcount));
                }
            }
            catch (Exception ex)
            {
                // ログ記録
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("DeleteDataFiles(),SearchPattern:{0},StorageData:{1},{2}", strSearchPattern, FNSiCSISetting.LogKeepNumberOfDays, ex.ToString()));
            }
        }
        #endregion
    }
}
