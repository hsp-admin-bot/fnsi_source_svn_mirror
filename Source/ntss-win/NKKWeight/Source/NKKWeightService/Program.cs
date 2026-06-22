//----------------------------------------------------------------------------------------------------
//
//----------------------------------------------------------------------------------------------------
using System;
using System.ServiceProcess;
using System.Threading;

//----------------------------------------------------------------------------------------------------
//  名前空間:TdcViewLogLib
//----------------------------------------------------------------------------------------------------
//using TdcViewLogLib;
//----------------------------------------------------------------------------------------------------
//  名前空間:NKKLoggingLib
//----------------------------------------------------------------------------------------------------
using NKKLoggingLib;
//----------------------------------------------------------------------------------------------------


//----------------------------------------------------------------------------------------------------
//
//----------------------------------------------------------------------------------------------------
namespace NKKWeightService
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// メインプログラムクラス
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
        static void Main()
        {
            ServiceBase[] ServicesToRun;

            // 複数のユーザー サービスが同じプロセスで実行されている可能性があります。
            // このプロセスにもう 1 つサービスを追加するには、次の行を変更して 2 番目の
            // サービス オブジェクトを作成してください。たとえば、以下のとおりです。
            //
            //   ServicesToRun = new ServiceBase[] {new Service1(), new MySecondUserService()};
            //

            // ログオブジェクト取得
            NKKLogging log = NKKLogging.GetInstance();

            // try～catchされていない例外発生の受け取り
            Thread.GetDomain().UnhandledException += new UnhandledExceptionEventHandler(Program.UnhandledExceptionEventHandler);

            try
            {
                // NKKWeightサービスクラス構築
                NKKWeightService service = new NKKWeightService();

                // ログ記録：サービス開始
                log.AddLogInfo(DateTime.Now, Program.SERVICE_NAME, NKKLogging.LOGGING_CLASS.INFO, "サービス開始");

                // サービス実行
                ServicesToRun = new ServiceBase[] { service };
                ServiceBase.Run(ServicesToRun);
            }
            catch (Exception Ex)
            {
                // ログ記録
                log.AddLogInfo(DateTime.Now, Program.SERVICE_NAME, NKKLogging.LOGGING_CLASS.ERROR, String.Format("Error,{0}", Ex.Message));
            }
            finally
            {
                try
                {
                    // ログ記録：サービス終了
                    log.AddLogInfo(DateTime.Now, Program.SERVICE_NAME, NKKLogging.LOGGING_CLASS.INFO, "サービス停止");

                    // ログ記録クラス破棄
                    NKKLogging.DeleteInstance();
                }
                finally
                {
                }
            }
        }
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 例外イベントハンドラー
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="args"></param>
        //----------------------------------------------------------------------------------------------------
        static void UnhandledExceptionEventHandler(object sender, UnhandledExceptionEventArgs args)
        {
            // ログオブジェクト取得
            NKKLogging log = NKKLogging.GetInstance();

            try
            {
                Exception ex = (Exception)args.ExceptionObject;

                // ログ記録：エラー
                log.AddLogInfo(DateTime.Now, Program.SERVICE_NAME, NKKLogging.LOGGING_CLASS.ERROR, String.Format("Error,UnhandledExceptionEventHandler,{0}", ex.ToString()));

                // ログ記録クラス破棄
                NKKLogging.DeleteInstance();
            }
            finally
            {
            }
        }
        //----------------------------------------------------------------------------------------------------
    }
    //----------------------------------------------------------------------------------------------------
}
//----------------------------------------------------------------------------------------------------
