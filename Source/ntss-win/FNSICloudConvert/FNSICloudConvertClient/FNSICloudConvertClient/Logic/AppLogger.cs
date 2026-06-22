using System;
using System.IO;
using System.Text;
using System.Windows.Forms;

namespace FNSICloudConvertClient.Logic
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// アプリケーションログ出力クラス（NKKLogging の代替）
    /// シングルトン。日付ごとに LOG フォルダへファイルを出力する。
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public sealed class AppLogger
    {
        private static AppLogger _instance;
        private static readonly object _instanceLock = new object();

        private readonly object _writeLock = new object();
        private StreamWriter _writer;
        private string _currentLogFilePath;
        private string _logFolder;

        public enum LOGGING_CLASS { INFO, WARNING, ERROR }

        private AppLogger() { }

        public static AppLogger GetInstance()
        {
            if (_instance == null)
                lock (_instanceLock)
                    if (_instance == null)
                        _instance = new AppLogger();
            return _instance;
        }

        public static void DeleteInstance()
        {
            lock (_instanceLock)
            {
                if (_instance != null)
                {
                    _instance.CloseWriter();
                    _instance = null;
                }
            }
        }

        public void ReleaseFileHandle()
        {
            lock (_writeLock)
            {
                CloseWriter();
            }
        }

        /// <summary>ログ格納先フォルダ。空の場合はアプリ起動フォルダ直下の LOG を使用する。</summary>
        public string LogFolder
        {
            get => _logFolder;
            set
            {
                lock (_writeLock)
                {
                    _logFolder = value;
                    CloseWriter(); // 次回書き込み時に再オープン
                }
            }
        }

        /// <summary>現在のログファイルパスを返す（ファイルが存在しない場合は空文字）。</summary>
        public string CurrentLogFilePath => _currentLogFilePath ?? string.Empty;

        public void AddLogInfo(DateTime time, string appName, LOGGING_CLASS cls, string message)
        {
            try
            {
                lock (_writeLock)
                {
                    EnsureWriter(time);
                    string line = string.Format("[{0}] [{1}] [{2}] {3}",
                        time.ToString("yyyy-MM-dd HH:mm:ss"),
                        cls,
                        appName,
                        message);
                    _writer?.WriteLine(line);
                    _writer?.Flush();
                }
            }
            catch { /* ログ出力失敗はサイレント無視 */ }
        }

        public void AddRawLine(DateTime time, string line)
        {
            try
            {
                lock (_writeLock)
                {
                    EnsureWriter(time);
                    _writer?.WriteLine(line);
                    _writer?.Flush();
                }
            }
            catch { /* ログ出力失敗はサイレント無視 */ }
        }

        public void AddDetachedLogInfo(DateTime time, string appName, LOGGING_CLASS cls, string message)
        {
            try
            {
                string line = string.Format("[{0}] [{1}] [{2}] {3}",
                    time.ToString("yyyy-MM-dd HH:mm:ss"),
                    cls,
                    appName,
                    message);
                AppendDetachedLine(time, line);
            }
            catch { /* ログ出力失敗はサイレント無視 */ }
        }

        public void AddDetachedRawLine(DateTime time, string line)
        {
            try
            {
                AppendDetachedLine(time, line);
            }
            catch { /* ログ出力失敗はサイレント無視 */ }
        }

        private void EnsureWriter(DateTime time)
        {
            string expected = GetExpectedLogFilePath(time);
            string folder = Path.GetDirectoryName(expected);

            if (_writer != null && _currentLogFilePath == expected)
                return;

            CloseWriter();
            if (!string.IsNullOrEmpty(folder))
                Directory.CreateDirectory(folder);
            _currentLogFilePath = expected;
            var fileStream = new FileStream(
                expected,
                FileMode.Append,
                FileAccess.Write,
                FileShare.ReadWrite);
            _writer = new StreamWriter(fileStream, new UTF8Encoding(false));
        }

        private void AppendDetachedLine(DateTime time, string line)
        {
            string expected = GetExpectedLogFilePath(time);
            string folder = Path.GetDirectoryName(expected);
            if (!string.IsNullOrEmpty(folder))
                Directory.CreateDirectory(folder);

            using (var fileStream = new FileStream(
                expected,
                FileMode.Append,
                FileAccess.Write,
                FileShare.ReadWrite))
            using (var writer = new StreamWriter(fileStream, new UTF8Encoding(false)))
            {
                writer.WriteLine(line);
                writer.Flush();
            }
        }

        private string GetExpectedLogFilePath(DateTime time)
        {
            string folder = string.IsNullOrEmpty(_logFolder)
                ? Path.Combine(Application.StartupPath, "LOG")
                : _logFolder;

            return Path.Combine(folder,
                string.Format("FNSICloudConvertClient_{0}.log", time.ToString("yyyyMMdd")));
        }

        private void CloseWriter()
        {
            try { _writer?.Close(); } catch { }
            _writer = null;
            _currentLogFilePath = null;
        }
    }
}
