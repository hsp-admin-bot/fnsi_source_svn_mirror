using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FNSiCSILogicLib
{
    /// <summary>
    /// 設定クラス
    /// </summary>
    public class FNSiCSISetting
    {

        /// <summary>
        /// データの保存先(既定：直下のDataフォルダ)
        /// </summary>
        public static string DataFolder = "";

        // Socket設定
        /// <summary>
        /// IFエッジサービスのIP
        /// </summary>
        public static string IFEdgeIPAddress = "";

        /// <summary>
        /// IFエッジサービスのポートNo
        /// </summary>
        public static int IFEdgePatientPortNo = 0;

        /// <summary>
        /// IFエッジサービスのポートNo
        /// </summary>
        public static int IFEdgeExaminPortNo = 0;

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
        /// SysCoopIniFileName
        /// </summary>
        public static string SysCoopIniFileName = "";

        /// <summary>
        /// InitCoopXmlData
        /// </summary>
        public static string DebugMode = "";

        /// <summary>
        /// ログ送信時刻(HHMM)
        /// </summary>
        public static string SendLogToBox = string.Empty;

        /// <summary>
        /// ログ送信パス
        /// </summary>
        public static string SendLogToBoxPath = string.Empty;
    }
}
