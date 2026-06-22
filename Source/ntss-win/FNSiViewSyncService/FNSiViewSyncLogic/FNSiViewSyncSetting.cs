using System;
using System.Collections;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace FNSiViewSyncLogicLib
{
    /// <summary>
    /// 一回同期状態
    /// </summary>
    public class SyncCntStatus
    {
        /// <summary>
        /// 0:初期
        /// </summary>
        public const int INIT = 0;

        /// <summary>
        /// 1:継続データ開始
        /// </summary>
        public const int BEGIN = 1;

        /// <summary>
        /// 2:継続データ終了
        /// </summary>
        public const int END = 2;

        /// <summary>
        /// 3:最終データ開始
        /// </summary>
        public const int LAST_BEGIN = 3;

        /// <summary>
        /// 4:最終データ終了
        /// </summary>
        public const int LAST_END = 4;
    }

    /// <summary>
    /// 設定クラス
    /// </summary>
    public class FNSiViewSyncSetting
    {
        /// <summary>
        /// ODBCのDNS
        /// </summary>
        public static string ConnectionString = "";

        /// <summary>
        /// データの保存先(既定：直下のDataフォルダ)
        /// </summary>
        public static string DataFolder = "";

        /// <summary>
        /// データ保持日数(既定:20日)
        /// </summary>
        public static int DataKeepNumberOfDays = 20;

        /// <summary>
        /// 更新頻度設定1
        /// </summary>
        public static DefinitionSetting Definition1 = new DefinitionSetting();

        /// <summary>
        /// 更新頻度設定2
        /// </summary>
        public static DefinitionSetting Definition2 = new DefinitionSetting();

        // Socket設定
        /// <summary>
        /// IFエッジサービスのIP
        /// </summary>
        public static string IFEdgeIPAddress = "";

        /// <summary>
        /// IFエッジサービスのポートNo
        /// </summary>
        public static int IFEdgePortNo = 0;

        /// <summary>
        /// ローカルサービスのIP
        /// </summary>
        public static string LocalIPAddress = "";

        /// <summary>
        /// ローカルサービスのポートNo
        /// </summary>
        public static int LocalPortNo = 0;

        /// <summary>
        /// ログの保存先(既定：直下のLOGフォルダ)
        /// </summary>
        public static string LogFolder = "";

        /// <summary>
        /// ログ保持日数(既定:20日)
        /// </summary>
        public static int LogKeepNumberOfDays = 20;

        /// <summary>
        /// FTPのIPAddress
        /// </summary>
        public static string FtpIPAddress = "";

        /// <summary>
        /// FTPのポートNo
        /// </summary>
        public static int FtpPortNo = 0;

        /// <summary>
        /// FTPのUserId
        /// </summary>
        public static string FtpUserId = "";

        /// <summary>
        /// FTPのパスワード
        /// </summary>
        public static string FtpPW = "";

        /// <summary>
        /// 再同期のポートNo
        /// </summary>
        public static int ReSyncPortNo = 0;

        /// <summary>
        /// 一回同期ビュー数
        /// </summary>
        public static int ViewSyncCnt = 0;

        /// <summary>
        /// 一回同期日数
        /// </summary>
        public static int ViewSyncDay = 0;

        /// <summary>
        /// 更新間隔(秒)
        /// </summary>
        public static int ViewSyncTimeSpan = 0;

        /// <summary>
        /// 初期更新日時(yyyyMMddhhmmss)
        /// </summary>
        public static string InitialUpdatedDate = "";

        /// <summary>
        /// ログ送信時刻(HHMM)
        /// </summary>
        public static string SendLogToBox = string.Empty;

        /// <summary>
        /// ログ送信パス
        /// </summary>
        public static string SendLogToBoxPath = string.Empty;

        /// <summary>
        /// タイムアウト時間
        /// </summary>
        public static int TimeoutSeconds = 90;

        /// <summary>
        /// SQL実行タイムアウト時間
        /// </summary>
        public static int SqlExecuteTimeout = 90;

        /// <summary>
        /// ログデバックモード
        /// </summary>
        public static int LogDebugMode = 0;

        /// <summary>
        /// リトライ回数
        /// </summary>
        public static int XMLRetryCount = 30;

        /// <summary>
        /// リトライ間隔
        /// </summary>
        public static int XMLRetryInterval = 100;

        // グローバル変数

        /// <summary>
        /// グローバルロックオブジェクト
        /// </summary>
        public static readonly object lockFile = new object();

        /// <summary>
        /// タイマーリスト
        /// </summary>
        public static Dictionary<string ,Timer> Timers = new Dictionary<string, Timer>();

        /// <summary>
        /// ViewSyncスレッド管理
        /// </summary>
        public static Dictionary<string, JobStatus> JobStatusList  = new Dictionary<string, JobStatus>();

        /// <summary>
        /// キュー管理
        /// </summary>
        public static ConcurrentQueue<Action> Queue = new ConcurrentQueue<Action>();

        /// <summary>
        /// Viewテーブル情報
        /// </summary>
        public static List<ViewTableInfo> m_viewTableInfoListAll = new List<ViewTableInfo>();
        public static List<ViewTableInfo> m_intervalViewTableInfoList = new List<ViewTableInfo>();
        public static List<ViewTableInfo> m_fixViewTableInfoList = new List<ViewTableInfo>();
    }

    public class JobStatus
    {
        /// <summary>
        /// 開始時間
        /// </summary>
        public DateTime StartDate = new DateTime();

        /// <summary>
        /// 一回同期状態
        /// </summary>
        public int ViewSyncCntStatus = SyncCntStatus.INIT;

        /// <summary>
        /// エラーフラグ
        /// </summary>
        public bool ErrorFlag = false;

        /// <summary>
        /// 要求処理開始時間
        /// </summary>
        public DateTime RequestTimeStart = new DateTime();

        /// <summary>
        /// テーブル情報
        /// </summary>
        public ViewTableInfo ViewTableInfo = new ViewTableInfo();

        /// <summary>
        /// 送信情報
        /// </summary>
        public List<List<ViewTableInfo>> SendDataList = new List<List<ViewTableInfo>>();

        /// <summary>
        /// 一回同期データ
        /// </summary>
        public List<ViewTableInfo> ViewSyncList = new List<ViewTableInfo>();

        /// <summary>
        /// Datファイルパスリスト
        /// </summary>
        public List<String> FilePathList = new List<string>();

        /// <summary>
        /// 成功フラグ
        /// </summary>
        public bool Bret = true;

        /// <summary>
        /// OKメッセジリスト
        /// </summary>
        public List<string> OkMessageList = new List<string>();

        /// <summary>
        /// NGメッセージリスト
        /// </summary>
        public List<string> NgMessageList = new List<string>();

        /// <summary>
        /// OKファイル数
        /// </summary>
        public int OkFileCount = 0;

        /// <summary>
        /// NGファイル数
        /// </summary>
        public int NgFileCount = 0;

        /// <summary>
        /// ファイル名リスト
        /// </summary>
        public List<string> StrFileNameList = new List<string>();

        /// <summary>
        /// 更新データリスト
        /// </summary>
        public List<Dictionary<string, string>> TableData = new List<Dictionary<string, string>>();
    }

    /// <summary>
    /// 更新頻度設定クラス
    /// </summary>
    public class DefinitionSetting
    {
        /// <summary>
        /// 更新時刻(HH:SS)
        /// </summary>
        public string Time = "00:00";

        /// <summary>
        /// 月曜日更新フラグ(true:更新)
        /// </summary>
        public bool Monday = false;

        /// <summary>
        /// 火曜日更新フラグ(true:更新)
        /// </summary>
        public bool Tuesday = false;

        /// <summary>
        /// 水曜日更新フラグ(true:更新)
        /// </summary>
        public bool Wednesday = false;

        /// <summary>
        /// 木曜日更新フラグ(true:更新)
        /// </summary>
        public bool Thursday = false;

        /// <summary>
        /// 金曜日更新フラグ(true:更新)
        /// </summary>
        public bool Friday = false;

        /// <summary>
        /// 土曜日更新フラグ(true:更新)
        /// </summary>
        public bool Saturday = false;

        /// <summary>
        /// 日曜日更新フラグ(true:更新)
        /// </summary>
        public bool Sunday = false;
    }
}
