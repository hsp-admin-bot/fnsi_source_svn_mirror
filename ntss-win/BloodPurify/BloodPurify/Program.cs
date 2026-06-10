using LayoutDesignerUtilityLib;
using NKK.BloodPurify.Properties;
using NKKCommon;
using NKKWebAccessLib;
using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using System.Threading.Tasks;
using System.Windows.Forms;
using LayoutDesignerUtilityLib;
using NKK.BloodPurify.Properties;
using NKKWebAccessLib;

namespace NKK.BloodPurify
{
    static class Program
    {
        static private readonly string STATIC_CLASS_NAME = "Program";

        // add #12685 単体アプリ、サービスの名称見直し limingzhe start
        // 多重起動禁止用のミューテックス（プロセス存続中は GC されないよう静的フィールドで保持）
        private static readonly System.Threading.Mutex _singleInstanceMutex
            = new System.Threading.Mutex(false, "FNWSiBloodPurify_SingleInstance");
        // add #12685 単体アプリ、サービスの名称見直し limingzhe end

        /// <summary>
        /// アプリケーションのメイン エントリ ポイントです。
        /// </summary>
        [STAThread]
        static void Main()
        {
            // add #12685 単体アプリ、サービスの名称見直し limingzhe start
            // ★ 多重起動禁止チェック（先頭で実施し、二重起動なら即終了）
            bool wHasMutex = false;
            try
            {
                wHasMutex = _singleInstanceMutex.WaitOne(TimeSpan.Zero, true);
            }
            catch (System.Threading.AbandonedMutexException)
            {
                // 直前のプロセスが ReleaseMutex せずに異常終了した場合は所有権を引き継ぐ
                wHasMutex = true;
            }
            if (!wHasMutex)
            {
                //MessageBox.Show(
                //    "FNWSiBloodPurify はすでに起動しています。",
                //    "多重起動禁止",
                //    MessageBoxButtons.OK,
                //    MessageBoxIcon.Exclamation);
                return;
            }
            // add #12685 単体アプリ、サービスの名称見直し limingzhe end

            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            NKKWebAccess.GetInstance().SendMessageToGUIHandler += new ToGUILib.ToGUI.dgtSendMessageToGUI(HandleAccessMessage);
            NKKWebAccess.StartCheckConnection();
            MyConfig.Init();
            MyLog.Init();

            //LogWriter.Init(Settings.Default.TraceFolder, Settings.Default.TraceFile, Settings.Default.TraceSize, Settings.Default.TraceNumber,
            //   Settings.Default.TraceSpan, Settings.Default.TraceIsZip, Settings.Default.ErrorFolder, Settings.Default.ErrorFile,
            //   Settings.Default.ErrorSize, Settings.Default.ErrorNumber, Settings.Default.ErrorSpan, Settings.Default.ErrorIsZip);

            MyLog.AddLogInfo(STATIC_CLASS_NAME, "アプリ起動");

            // 初のアプリ起動などでデータ格納用フォルダ階層が無ければ作る
            Directory.CreateDirectory(MyConfig.DataDir);

            // 初のアプリ起動などで「クール情報jsonファイル」が無い場合はデフォルトの「クール情報jsonファイル」を仮作成
            if (false == File.Exists(AppCmn.GetExeDir(true) + "kur.json"))
            {
                List<MyJson.KurInfo> listKur
                    = MyJson.Conv<List<MyJson.KurInfo>>.Deserialize(
                        @"[{""kurName"":""その他(0:00～)"",""kurStartTime"":""000000"",""kurEndTime"":""085959""}"
                        + @",{""kurName"":""午前(9:00～)"",""kurStartTime"":""090000"",""kurEndTime"":""125959""}"
                        + @",{""kurName"":""午後(13:00～)"",""kurStartTime"":""130000"",""kurEndTime"":""185959""}"
                        + @",{""kurName"":""夜間(19:00～)"",""kurStartTime"":""190000"",""kurEndTime"":""235959""]");
                MyJson.Conv<List<MyJson.KurInfo>>.SerializeToFile(listKur, AppCmn.GetExeDir(true) + "kur.json");
            }

            // サインインダイアログ表示のために必要なことを実施
            LayoutDesignerUtility.BaseUri = MyConfig.BaseUri;
            SignInLib.SignIn.SignInInfo = new SignInLib.SignInInfo();
            if (false == string.IsNullOrWhiteSpace(MyConfig.FacilityHash))
            {
                SignInLib.SignIn.SignInInfo.FacilityHashText = MyConfig.FacilityHash;
            }

            // サインイン前にサインインを行ってくれるクラスに[クライアント証明書を検索するためのキー値]をセット
            NKKWebAccess.ClientCertificateSearchValue1 = MyConfig.ClientCertificateSearchValue1.Trim();
            NKKWebAccess.ClientCertificateSearchValue2 = MyConfig.ClientCertificateSearchValue2.Trim();

            // サインインに成功するとメソッド内部でNKKWebAccessに各種の必要パラメータがセットされます
            // mod #12204 特殊浄化通信アプリ　アイコン差し替え 高 start
            //var ret = SignInLib.FrmSignIn.ShowSignInDialog(Resources.nkk, MyConfig.SaveFacilityHash);
            var ret = SignInLib.FrmSignIn.ShowSignInDialog(Resources.BloodPurify, MyConfig.SaveFacilityHash);
            // mod #12204 特殊浄化通信アプリ　アイコン差し替え 高 end

            if (DialogResult.Abort == ret)
            {
                MyLog.Fini();
                // add #12685 単体アプリ、サービスの名称見直し limingzhe start
                try { _singleInstanceMutex.ReleaseMutex(); } catch { /* 解放失敗は致命的ではないので握り潰す */ }
                // add #12685 単体アプリ、サービスの名称見直し limingzhe end
                return;
            }
            if (DialogResult.Cancel == ret)
            {
                MessageBox.Show("サインインをキャンセルしました。\nオフラインモードで動作します。", "アプリ起動", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }

            if (NKKWebAccess.Login)
            {
                // add mongodbに転載、サーバー起動ログ。 陳 start
                LogManagement.LogMessage = "特殊浄化通信アプリサーバーが起動しました。";
                LogManagement.SetLogingProperties();
                // add mongodbに転載、サーバー起動ログ。 陳 end

                // サインイン状態
                AppCmn.IsModeOnline = true;
                MyLog.AddLogInfo(STATIC_CLASS_NAME, "オンラインモードに遷移");

                // ログ記録するローカル関数
                void addLogInfo(NKKLoggingLib.NKKLogging.LOGGING_CLASS loggingClass, string strMesssage)
                {
                    MyLog.AddLogInfo(STATIC_CLASS_NAME, loggingClass, strMesssage);
                }

                // 自己アップデート

                var updater = new NKKCommon.Updater
                {
                    SystemDefineVersionNo = 11,
                    ProcType = 1,
                    // add オンプレでの自己アップデートに対応 孫 start
                    // DownloadFileName = "BloodPurify.zip",
                    DownloadFileName = MyConfig.DownloadSourceFileName,
                    // add オンプレでの自己アップデートに対応 孫 end
                    Bucket = MyConfig.DownloadSourceFolder,
                    DownloadFilePassword = "nkk",
                    LoggingMethod = addLogInfo
                };

                // 新しいバージョンが公開されているか確認
                // 公開されている場合、バージョンアップするかダイアログを表示する
                try
                {
                    if (SignInLib.SignIn.SignInInfo.IsOnline &&
                        updater.IsPublishedNewVersion(System.Reflection.Assembly.GetExecutingAssembly()) &&
                        RldMessageBox.Show("新しいバージョンが公開されています。プログラムを更新しますか？", "更新", MessageBoxButtons.YesNo,
                                           MessageBoxIcon.Question) == DialogResult.Yes)
                    {
                        MyLog.AddLogInfo(STATIC_CLASS_NAME, "プログラム更新の実施有無確認ダイアログで[はい]を選択");

                        // Amazon S3から新しいファイルをダウンロードし、自己アップデートする
                        if (updater.GetLatestProgramFile())
                        {
                            // 解凍成功

                            // 自己アップデート
                            updater.AppUpdate();

                        }
                        else
                        {
                            // ダウンロードに失敗したことを表示する
                            RldMessageBox.Show("更新されたプログラムファイルを取得することができませんでした", "更新", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);

                        }

                    }
                }
                catch (Exception updateEx)
                {
                    MyLog.AddLogInfo(STATIC_CLASS_NAME, NKKLoggingLib.NKKLogging.LOGGING_CLASS.ERROR,
                        $"[DEBUG] 自己アップデート処理で未捕捉例外, タイプ:{updateEx.GetType().FullName}, メッセージ:{updateEx.Message}, StackTrace:{updateEx.StackTrace}");
                    System.Threading.Thread.Sleep(2000);
                }

                // RESTでmst_kurテーブルのデータを読み出して「クール情報jsonファイル」に保存
                var restRes = Task.Run(async () => await MyRest.GetMstKur()).Result;
                if (false == restRes.isSuccess)
                {
                    MessageBox.Show($"クール情報の取得に失敗しました。\r\n\r\n[{restRes.errorReasonPhrase}]", "アプリ起動", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                }
                else
                {
                    List<MyJson.KurInfo> listDbData = MyJson.Conv<List<MyJson.KurInfo>>.Deserialize(restRes.getData);
                    MyJson.Conv<List<MyJson.KurInfo>>.SerializeToFile(listDbData, AppCmn.GetExeDir(true) + "kur.json");
                }
            }
            else
            {
                AppCmn.IsModeOnline = false;
                MyLog.AddLogInfo(STATIC_CLASS_NAME, "オフラインモードに遷移");
            }


            try
            {
                Application.Run(new FrmDeviceSelector());
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(STATIC_CLASS_NAME, "アプリケーション内でcatchされない例外発生", ex);
            }
            finally
            {
                MyLog.AddLogInfo(STATIC_CLASS_NAME, "アプリ終了");

                if (AppCmn.IsModeOnline)
                {
                    // TRACEログをログアップロード
                    MyLog.AddLogInfo(STATIC_CLASS_NAME, "オンラインモードのためログアップロードを実施");
                    new NKKLogUploader().UploadLog(Path.GetFileNameWithoutExtension(Assembly.GetExecutingAssembly().Location));
                }
                else
                {
                    MyLog.AddLogInfo(STATIC_CLASS_NAME, "オフラインモードのためログアップロードの実施をスキップ");
                }

                NKKWebAccess.StopCheckConnection();

                MyLog.Fini();

                // add #12685 単体アプリ、サービスの名称見直し limingzhe start
                // 多重起動禁止用ミューテックスの解放
                try { _singleInstanceMutex.ReleaseMutex(); } catch { /* 解放失敗は致命的ではないので握り潰す */ }
                // add #12685 単体アプリ、サービスの名称見直し limingzhe end

                //LogWriter.WriteLog(LogLevel.Debug, "0316000027", "浄化装置通信ソフト 終了");
            }
        }

        private static void HandleAccessMessage(string strServiceName, string strStatus, DateTime dtNow, string strMessage)
        {
            switch (strStatus)
            {
                case "Disconnected":
                    {
                        AppCmn.IsModeOnline = false;
                        break;
                    }
                case "Connected":
                    {
                        //AppCmn.IsModeOnline = true;
                        break;
                    }
                default:
                    {
                        break;
                    }
            }
        }
    }
}