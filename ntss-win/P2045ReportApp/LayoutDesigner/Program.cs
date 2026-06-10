using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Forms;
using RldMsgBox = LayoutDesignerUtilityLib.RldMessageBox;
using RldUtility = LayoutDesignerUtilityLib.LayoutDesignerUtility;

using NKKLoggingLib;
using NKKWebAccessLib;

namespace LayoutDesigner
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
            System.Threading.Mutex wMutex = null;           // アプリケーション多重起動チェック用
            string wMutexName = RldUtility.PRODUCT_NAME;    // ミューテックス名は製品名を使用

            NKKWebAccessLib.NKKWebAccess.StartCheckConnection();

            // ログ出力オブジェクトを取得
            NKKLogging wLogging = NKKLogging.GetInstance();

            // コマンドライン引数を取得(バージョンアップ処理用)
            //Environment.CommandLine

            // アプリケーション初期化処理実行
            if( !RldLib.PreAppStartUp() ) {
                RldUtility.RecordException(
                    new System.Exception("アプリケーション初期化処理に失敗しました。"));
                return;
            }

            // ログ記録
            wLogging.AddLogInfo(DateTime.Now, Application.ProductName, STATIC_CLASS_NAME, NKKLogging.LOGGING_CLASS.INFO, "起動");

            // ログ記録
            wLogging.AddLogInfo(DateTime.Now, Application.ProductName, STATIC_CLASS_NAME, NKKLogging.LOGGING_CLASS.INFO, string.Format("起動フォルダ,{0}", RldUtility.AppDirPath));

            try {
                // 帳票レイアウトデザイナ用ミューテックスの生成
                wMutex = new System.Threading.Mutex(false, wMutexName);
            }
            catch( Exception ex ) {
                // ミューテックスの生成に失敗したら終了
                //RldUtility.RecordException(
                //    new System.Exception("このアプリケーションの多重起動は禁止されています。", ex));
                return;
            }

            bool wHasMutex = false;

            try {
                // ミューテックスの取得を試行
                try {
                    wHasMutex = wMutex.WaitOne(0, false);
                }
                catch( System.Threading.AbandonedMutexException ) {
                    wHasMutex = true;
                }

                if( !wHasMutex ) {
                    // ミューテックスを取得できなかった場合は終了
                    //RldUtility.RecordException(
                    //    new System.ApplicationException("このアプリケーションの多重起動は禁止されています。"));
                    return;
                }

                // 全ての例外を補足するように設定
                Application.SetUnhandledExceptionMode(UnhandledExceptionMode.ThrowException);
                // イベントハンドラ割り当て
                AppDomain.CurrentDomain.UnhandledException += CurrentDomain_UnhandledException;

                // アプリケーションの外観・描画方法を設定
                Application.EnableVisualStyles();
                Application.SetCompatibleTextRenderingDefault(false);

                // 画面の表示を開始
                new RldStartupFormDisplayer().Start();
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex);
            }
            finally
            {
                NKKWebAccessLib.NKKWebAccess.StopCheckConnection();

                // ミューテックスを取得している場合は解放
                if( wHasMutex ) wMutex.ReleaseMutex();
                wMutex.Close();

                try {
                    // ログ記録
                    wLogging.AddLogInfo(DateTime.Now, Application.ProductName, STATIC_CLASS_NAME, NKKLogging.LOGGING_CLASS.INFO, "終了");

                    // ログファイルをアップロードする
                    if (SignInLib.SignIn.SignInInfo.IsOnline)
                    {
                        // TRACEログをログアップロード
                        wLogging.AddLogInfo(DateTime.Now, Application.ProductName, STATIC_CLASS_NAME, NKKLogging.LOGGING_CLASS.INFO, "オンラインモードのためログアップロードを実施");
                        new NKKCommon.NKKLogUploader().UploadLog(System.IO.Path.GetFileNameWithoutExtension(System.Reflection.Assembly.GetExecutingAssembly().Location));
                    }
                    else
                    {
                        wLogging.AddLogInfo(DateTime.Now, Application.ProductName, STATIC_CLASS_NAME, NKKLogging.LOGGING_CLASS.INFO, "オフラインモードのためログアップロードの実施をスキップ");
                    }

                    // ログ出力クラス破棄
                    NKKLogging.DeleteInstance();
                }
                finally {
                }
            }

            /*
            try {
                // ミューテックスを取得
                if( wMutex.WaitOne(0, false) ) {

                    bool wCanContinue = true;

                    // サインイン処理実行
                    EnumSignInResult wSignInResult = SignIn();

                    if( wSignInResult == EnumSignInResult.OK ) {
                        // サインインに成功した場合

                        // アップデート直後の場合は以下は不要

                        // 最新ファイルをチェック
                        if( CheckUpdateFile() ) {

                            // 最新ファイルがあった場合はダウンロード
                            if( DownloadUpdateFile() ) {

                                // ダウンロードに成功した場合はアップデータを実行して終了する。

                                wCanContinue = false;
                            }
                            else {
                                // ダウンロードに失敗
                                // 古いバージョンで処理続行
                            }
                        }
                        else {
                            // 最新ファイルがないか(アクセス権不足等で)確認できなかった場合
                            // そのまま処理続行
                        }
                    }
                    else {
                        // サインインに失敗した場合
                        // オフラインで処理続行
                    }

                    // 処理続行可能な場合は画面の表示を開始
                    if( wCanContinue )
                        (new LayoutDesigner.Procs.FormDisplayer()).Start();
                }
                else {

                }
            }
            catch {

            }
            finally {
                // ミューテックス解放処理
                try {
                    wMutex.Close();
                    wMutex = null;
                }
                catch( Exception ex ) {
                    MessageBox.Show("ミューテックスの解放に失敗しました\r\n" + ex.Message, MSG_TITLE_ERROR, MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
            */
        }

        #region カスタムイベントハンドラ定義

        /// <summary>
        /// アプリケーションドメイン内で発生した例外を補足します。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private static void CurrentDomain_UnhandledException(object sender, UnhandledExceptionEventArgs e)
        {
            try {
                RldUtility.RecordException(new System.ApplicationException("想定外の例外が発生しました。", e.ExceptionObject as Exception));
            }
            finally {
            }
        }

        #endregion

    }
}
