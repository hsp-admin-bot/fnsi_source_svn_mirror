using System;
using System.Threading;
using System.Windows.Forms;

namespace NKKWeightTool
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
            bool createdNew;
            _singleInstanceMutex = new Mutex(true, @"Local\NIKKISO_FNWSiScaleTool_SingleInstance", out createdNew);
            if (!createdNew)
            {
                return;
            }

            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            // NKSConverter.Program と同順序。タスクバー固定表示名用（AssemblyTitle は変更しない）
            TaskbarAppIdentity.SetProcessAppUserModelId();
            try
            {
                Application.Run(new FormGUI());
            }
            finally
            {
                try
                {
                    _singleInstanceMutex.ReleaseMutex();
                }
                catch
                {
                }
                _singleInstanceMutex.Dispose();
            }
        }
    }
}
