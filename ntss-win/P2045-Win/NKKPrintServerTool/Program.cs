using System;
using System.Threading;
using System.Windows.Forms;

namespace NKKPrintServerTool
{
    static class Program
    {
        private static Mutex _singleInstanceMutex;

        /// <summary>
        /// アプリケーションのメイン エントリ ポイントです。
        /// </summary>
        [STAThread]
        static void Main()
        {
            // 多重起動防止（Mutex をプロセス終了まで保持。以前は try 内ローカル変数のため GC で解放され、二重トレイが発生し得た）
            string mutexName = "NKKPrintServerTool";
            OperatingSystem os = Environment.OSVersion;
            if (os.Platform == PlatformID.Win32NT && os.Version.Major >= 5)
            {
                mutexName = @"Global\" + mutexName;
            }

            bool createdNew;
            try
            {
                _singleInstanceMutex = new Mutex(true, mutexName, out createdNew);
            }
            catch
            {
                return;
            }

            if (!createdNew)
            {
                _singleInstanceMutex.Dispose();
                _singleInstanceMutex = null;
                return;
            }

            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            try
            {
                Application.Run(new FormGUI());
            }
            finally
            {
                try
                {
                    _singleInstanceMutex?.ReleaseMutex();
                }
                catch
                {
                }
                _singleInstanceMutex?.Dispose();
                _singleInstanceMutex = null;
            }
        }
    }
}
