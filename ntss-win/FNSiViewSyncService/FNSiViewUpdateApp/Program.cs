using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace FNSiViewUpdateApp
{
    static class Program
    {

        // ミューテックスのインスタンスを保持する変数
        static Mutex mutex = new Mutex(false, "SingleInstanceApp");

        /// <summary>
        /// アプリケーションのメイン エントリ ポイントです。
        /// </summary>
        [STAThread]
        static void Main()
        {
            // アプリケーションの多重起動をチェック
            if (!mutex.WaitOne(TimeSpan.Zero, true))
            {
                MessageBox.Show("このアプリケーションはすでに起動しています。", "多重起動禁止", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return; // 既に起動しているのでアプリケーションを終了
            }

            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new FNSiViewUpdateApp());

            // アプリケーション終了時にミューテックスを解放
            mutex.ReleaseMutex();
        }
    }
}
