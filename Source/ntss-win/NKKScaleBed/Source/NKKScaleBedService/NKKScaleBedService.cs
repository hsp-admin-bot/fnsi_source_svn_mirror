//----------------------------------------------------------------------------------------------------
//
//----------------------------------------------------------------------------------------------------
using System;
using System.Text;
using System.Data;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics;
using System.ServiceProcess;

//----------------------------------------------------------------------------------------------------
// 名前空間:NKKLoggingLib
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
namespace NKKScaleBedService
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// NKKScaleBedServiceクラス定義
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public partial class NKKScaleBed : ServiceBase
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
        /// NKKScaleBedクラスオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private NKKScaleBedLib.NKKScaleBed m_NKKScaleBed = null;
        ////----------------------------------------------------------------------------------------------------
        ///// <summary>
        ///// 表示用処理ログ通知サーバーオブジェクト
        ///// </summary>
        ////----------------------------------------------------------------------------------------------------
        //private TdcViewLogServer m_ViewLogServer = null;
        ////----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// コンストラクタ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public NKKScaleBed()
        {
            InitializeComponent();

            // ログオブジェクト取得
            NKKLogging log = NKKLogging.GetInstance();

            // 各オブジェクト構築
            this.m_NKKScaleBed = new NKKScaleBedLib.NKKScaleBed(AppDomain.CurrentDomain.BaseDirectory);
            //this.m_ViewLogServer = new TdcViewLogServer(TdcViewLogModule.GetInstance().ViewLog);
            //this.m_ViewLogServer.LogExt = "VIEW";

            // ログ記録
            log.AddLogInfo(DateTime.Now, NKKScaleBed.SERVICE_NAME, NKKLogging.LOGGING_CLASS.INFO, "サービス構築完了");
        }
        //----------------------------------------------------------------------------------------------------


        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サービス開始処理
        /// </summary>
        /// <param name="args"></param>
        //----------------------------------------------------------------------------------------------------
        protected override void OnStart(string[] args)
        {
            // TODO: サービスを開始するためのコードをここに追加します。

            // ログオブジェクト取得
            NKKLogging log = NKKLogging.GetInstance();

            try
            {
                // OnStart処理開始
                log.AddLogInfo(DateTime.Now, NKKScaleBed.SERVICE_NAME, NKKLogging.LOGGING_CLASS.INFO, "OnStart処理開始");

                // 以下の処理で失敗した場合はthrowされる

                // NKKScaleBed初期化処理
                if (this.m_NKKScaleBed.Start() == true)
                {
                    
                }
                else
                {
                    throw (new Exception("NKKScaleBed初期化、待ち受け失敗"));
                }

                // OnStart処理終了
                log.AddLogInfo(DateTime.Now, NKKScaleBed.SERVICE_NAME, NKKLogging.LOGGING_CLASS.INFO, "OnStart処理終了");
            }
            catch (Exception ex)
            {
                // ログ記録：エラー
                log.AddLogInfo(DateTime.Now, NKKScaleBed.SERVICE_NAME, NKKLogging.LOGGING_CLASS.ERROR, String.Format("Error,{0}", ex.Message));

                throw;
            }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サービス停止処理
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        protected override void OnStop()
        {
            // TODO: サービスを停止するのに必要な終了処理を実行するコードをここに追加します。

            // ログオブジェクト取得
            NKKLogging log = NKKLogging.GetInstance();

            try
            {
                // OnStop処理開始
                log.AddLogInfo(DateTime.Now, NKKScaleBed.SERVICE_NAME, NKKLogging.LOGGING_CLASS.INFO, "OnStop処理開始");

                //// Tool待ち受け処理停止
                //this.m_ViewLogServer.StopListner();

                // NKKScaleBed終了
                this.m_NKKScaleBed.Stop();

                // OnStop処理終了
                log.AddLogInfo( DateTime.Now, NKKScaleBed.SERVICE_NAME, NKKLogging.LOGGING_CLASS.INFO, "OnStop処理終了");
            }
            catch (Exception ex)
            {
                // ログ記録：エラー
                log.AddLogInfo(DateTime.Now, NKKScaleBed.SERVICE_NAME, NKKLogging.LOGGING_CLASS.ERROR, String.Format("Error,{0}", ex.Message));

                throw;
            }
        }
        //----------------------------------------------------------------------------------------------------
    }
    //----------------------------------------------------------------------------------------------------
}
//----------------------------------------------------------------------------------------------------
