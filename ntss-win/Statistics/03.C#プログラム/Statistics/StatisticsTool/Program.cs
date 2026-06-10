using System;
using System.Diagnostics;
using System.Threading;
using System.Windows.Forms;
using Fnw.StatisticsTool;
using Fnw.StatisticsTool.Properties;
using Fnw.StatisticsTool.FrmLogin;
using System.Collections.Generic;
using NKKLoggingLib;
using NKKWebAccessLib;

namespace StatisticsTool
{
    static class Program
    {
        static private readonly string STATIC_CLASS_NAME = "Program";
        /// <summary>
        /// アプリケーションのメイン エントリ ポイントです。
        /// </summary>
        [STAThread]
        static void Main()
        {
            NKKWebAccess.StartCheckConnection();

            // ログ出力オブジェクトを取得
            NKKLogging wLogging = NKKLogging.GetInstance();

            // アプリケーション初期化処理実行
            if (!StatisticsLib.PreAppStartUp())
            {
                StatisticsUtility.RecordException(
                    new System.Exception("アプリケーション初期化処理に失敗しました。"));
                return;
            }

            // ログ記録
            wLogging.AddLogInfo(DateTime.Now, Application.ProductName, STATIC_CLASS_NAME, NKKLogging.LOGGING_CLASS.INFO, "起動");


            // 全ての例外を補足するように設定
            Application.SetUnhandledExceptionMode(UnhandledExceptionMode.ThrowException);
            // イベントハンドラ割り当て
            AppDomain.CurrentDomain.UnhandledException += CurrentDomain_UnhandledException;

            // アプリケーションの外観・描画方法を設定
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            // 画面の表示を開始
            new Startup().Start();

            // ログ出力クラス破棄
            wLogging.AddLogInfo(DateTime.Now, Application.ProductName, STATIC_CLASS_NAME, NKKLogging.LOGGING_CLASS.INFO, "終了");
            NKKWebAccessLib.NKKWebAccess.StopCheckConnection();
            // ログ記録
            NKKLogging.DeleteInstance();

        }

        #region カスタムイベントハンドラ定義

        /// <summary>
        /// アプリケーションドメイン内で発生した例外を補足します。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private static void CurrentDomain_UnhandledException(object sender, UnhandledExceptionEventArgs e)
        {
            try
            {
                StatisticsUtility.RecordException(new System.ApplicationException("想定外の例外が発生しました。", e.ExceptionObject as Exception));
            }
            finally
            {
            }
        }

        #endregion
    }
}
