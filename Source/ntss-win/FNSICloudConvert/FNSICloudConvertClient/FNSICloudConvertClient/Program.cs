using System;
using System.Windows.Forms;
using FNSICloudConvertClient.Forms;
using FNSICloudConvertClient.Logic;

namespace FNSICloudConvertClient
{
    static class Program
    {
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            bool restoredUserSettings = false;

            // アプリケーション共通設定ファイル読み込み
            try
            {
                AppConfigLoader.Load();
            }
            catch (Exception ex)
            {
                MessageBox.Show(
                    string.Format("設定ファイルの読み込みに失敗しました。\n{0}", ex.Message),
                    "起動エラー",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
                return;
            }

            // ユーザー設定（接続情報）をファイルから復元する
            {
                var saved = Logic.UserSettingsStore.Load();
                if (saved != null)
                {
                    saved.ApplyTo(AppState.Instance.Settings);
                    restoredUserSettings = true;
                }
            }

            AppLogger log = AppLogger.GetInstance();
            log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.INFO, "起動");
            log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.INFO,
                string.Format("設定ファイル読込完了: {0}", AppConfigLoader.ConfigFilePath));
            log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.INFO,
                restoredUserSettings ? "ユーザー設定を復元" : "ユーザー設定は未保存");

            try
            {
                Application.Run(new FormLogin());
            }
            finally
            {
                try
                {
                    log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.INFO, "終了");

                    // ログイン済みかつコンバーター認証済みの場合、ログをコンバーターサーバーへアップロードする
                    if (BusinessApiClient.IsLoggedIn)
                    {
                        log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.INFO, "ログアップロードを実施");
                        try
                        {
                            log.ReleaseFileHandle();
                            string appName = System.IO.Path.GetFileNameWithoutExtension(
                                System.Reflection.Assembly.GetExecutingAssembly().Location);
                            var converterClient = new ConverterApiClient(AppConfigLoader.ConverterBaseUri);
                            converterClient.UploadLogAsync(appName).GetAwaiter().GetResult();
                        }
                        catch (Exception uploadEx)
                        {
                            log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.WARNING,
                                string.Format("ログアップロード失敗（無視）: {0}", uploadEx.Message));
                        }
                    }
                    else
                    {
                        log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.INFO, "未ログインのためログアップロードをスキップ");
                    }
                }
                finally
                {
                    AppLogger.DeleteInstance();
                }
            }
        }
    }
}
