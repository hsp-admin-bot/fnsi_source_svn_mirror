using FNSiCSILogicLib;
using NKKLoggingLib;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.ServiceProcess;
using System.Text;
using System.Threading.Tasks;

namespace FNSiCSIService
{
    /// <summary>
    /// FNSi View連携用DB同期サービス
    /// </summary>
    public partial class FNSiCSIService : ServiceBase
    {
        /// <summary>
        /// サービス名称
        /// </summary>
        private static readonly string SERVICE_NAME = String.Format("{0,-20}", System.Reflection.Assembly.GetExecutingAssembly().GetName().Name);

        /// <summary>
        /// FNSiCSILogicクラスオブジェクト
        /// </summary>
        private FNSiCSILogic m_fvsl = null;

        public FNSiCSIService()
        {
            InitializeComponent();
        }

        protected override void OnStart(string[] args)
        {
            // 捕捉されない例外ハンドラを設定
            AppDomain.CurrentDomain.UnhandledException += CurrentDomain_UnhandledException;

            // ログオブジェクト取得
            NKKLogging log = NKKLogging.GetInstance();

            try
            {
                // 各オブジェクト構築
                this.m_fvsl = new FNSiCSILogic(AppDomain.CurrentDomain.BaseDirectory);

                // ログ記録
                log.AddLogInfo(DateTime.Now, SERVICE_NAME, NKKLogging.LOGGING_CLASS.INFO, "サービス構築完了\n");

                // OnStart処理開始
                log.AddLogInfo(DateTime.Now, SERVICE_NAME, NKKLogging.LOGGING_CLASS.INFO, "OnStart処理開始");

                // 以下の処理で失敗した場合はthrowされる
                // 初期化処理
                if (this.m_fvsl.Start() == true)
                {
                }
                else
                {
                    log.AddLogInfo(DateTime.Now, SERVICE_NAME, NKKLogging.LOGGING_CLASS.ERROR, "初期化、待ち受け失敗");
                    Stop();
                }

                // OnStart処理終了
                log.AddLogInfo(DateTime.Now, SERVICE_NAME, NKKLogging.LOGGING_CLASS.INFO, "OnStart処理終了");
            }
            catch (Exception ex)
            {
                // ログ記録：エラー
                log.AddLogInfo(DateTime.Now, SERVICE_NAME, NKKLogging.LOGGING_CLASS.ERROR, String.Format("Error,{0}", ex.Message));
                //throw;
            }
        }

        protected override void OnStop()
        {
            // ログオブジェクト取得
            NKKLogging log = NKKLogging.GetInstance();

            try
            {
                // OnStop処理開始
                log.AddLogInfo(DateTime.Now, SERVICE_NAME, NKKLogging.LOGGING_CLASS.INFO, "OnStop処理開始");

                // 終了
                this.m_fvsl.Stop();

                // OnStop処理終了
                log.AddLogInfo(DateTime.Now, SERVICE_NAME, NKKLogging.LOGGING_CLASS.INFO, "OnStop処理終了");
            }
            catch (Exception ex)
            {
                // ログ記録：エラー
                log.AddLogInfo(DateTime.Now, SERVICE_NAME, NKKLogging.LOGGING_CLASS.ERROR, string.Format("Error,{0}", ex.Message));
                //throw;
            }

            NKKLogging.DeleteInstance();
        }

        private void CurrentDomain_UnhandledException(object sender, UnhandledExceptionEventArgs e)
        {
            // ログオブジェクト取得
            NKKLogging log = NKKLogging.GetInstance();

            try
            {
                Exception ex = (Exception)e.ExceptionObject;

                // ログ記録：エラー
                log.AddLogInfo(DateTime.Now, System.Reflection.Assembly.GetExecutingAssembly().GetName().Name,
                    NKKLogging.LOGGING_CLASS.ERROR, string.Format("Error,UnhandledExceptionEventHandler,{0}", "\r\n" + ex.ToString()));

                // サービス停止
                Stop();
            }
            catch (Exception ex)
            {
                Trace.WriteLine(ex.Message);
            }
        }

        /// <summary>
        /// 起動時処理テスト用メソッド
        /// </summary>
        /// <param name="args">OnStartメソッドの引数</param>
        internal void TestStartupAndStop(string[] args)
        {
            this.OnStart(args);
            Console.ReadLine();
            //this.OnStop();
        }
    }
}
