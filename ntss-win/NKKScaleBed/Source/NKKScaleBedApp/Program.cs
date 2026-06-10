//----------------------------------------------------------------------------------------------------
//
//----------------------------------------------------------------------------------------------------
using System;
using System.Data;
using System.Collections.Generic;
using System.Windows.Forms;

#if DEBUG
    using System.Diagnostics;
#endif

//----------------------------------------------------------------------------------------------------
//  名前空間:TdcViewLogLib
//----------------------------------------------------------------------------------------------------
//using TdcViewLogLib;
//----------------------------------------------------------------------------------------------------
//  名前空間:NKKLoggingLib
//----------------------------------------------------------------------------------------------------
using NKKLoggingLib;
//----------------------------------------------------------------------------------------------------
//  名前空間:NKKScaleBedLib
//----------------------------------------------------------------------------------------------------
using NKKScaleBedLib;
//----------------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------
//
//----------------------------------------------------------------------------------------------------
namespace NKKScaleBedApp
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// メインプログラムクラス定義
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    static class Program
    {
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サービス名称
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static readonly String SERVICE_NAME = System.Reflection.Assembly.GetExecutingAssembly().GetName().Name;
        //----------------------------------------------------------------------------------------------------



        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// アプリケーションのメイン エントリ ポイントです。
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        [STAThread]
        static void Main()
        {
            // ログオブジェクト取得
            NKKLogging log = NKKLogging.GetInstance();


         

            try
            {
                Application.EnableVisualStyles();
                Application.SetCompatibleTextRenderingDefault(false);

                // NKKScaleBed構築
                NKKScaleBed NKKScaleBed = new NKKScaleBed(AppDomain.CurrentDomain.BaseDirectory);

                // ログ記録
                log.AddLogInfo( DateTime.Now, Program.SERVICE_NAME, NKKLogging.LOGGING_CLASS.INFO, "起動");

                // ログ記録
                log.AddLogInfo(DateTime.Now, Program.SERVICE_NAME, NKKLogging.LOGGING_CLASS.INFO,  String.Format("起動フォルダ,{0}", AppDomain.CurrentDomain.BaseDirectory));

                // 初期化処理
                if (NKKScaleBed.Init() == true)
                {
                    // 初期化成功

                    // 処理開始処理
                    if (NKKScaleBed.Start() == true)
                    {
                        // 初期化失敗

                        // アプリケーション起動
                        //Application.Run(new FormViewLog());
                        Application.Run(new FormViewLog(NKKScaleBed.GetGUISocketPortNo()));

                        // 終了
                        NKKScaleBed.Stop();
                    }
                }
            }
            catch (Exception Ex)
            {
                // ログ記録
                log.AddLogInfo( DateTime.Now, Program.SERVICE_NAME, NKKLogging.LOGGING_CLASS.ERROR, String.Format("{0}", Ex.Message));

                MessageBox.Show(null, "問題があるため\r\nプログラムを終了します。", Application.ProductName, MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
            finally
            {
                try
                {
                    // ログ記録
                    log.AddLogInfo(DateTime.Now, Program.SERVICE_NAME, NKKLogging.LOGGING_CLASS.INFO, "終了");

                    // ログ記録クラス破棄
                    NKKLogging.DeleteInstance();
                }
                finally
                {
                }
            }
        }
        //----------------------------------------------------------------------------------------------------
    }
    //----------------------------------------------------------------------------------------------------
}
//----------------------------------------------------------------------------------------------------
