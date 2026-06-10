using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Forms;
using LayoutDesignerUtilityLib;
using Microsoft.Win32;
using NKKLoggingLib;
using NKKWebAccessLib;
using RldUtility = LayoutDesignerUtilityLib.LayoutDesignerUtility;

namespace CoopEventCreateOrStopTool
{
    static class Program
    {
        static private readonly string STATIC_CLASS_NAME = "Program";

        // 20210908 #5967 識別子  鄭  start
        static private readonly string LOG_FILE_EXT = "CoopEventCreateTool";
        // 20210908 #5967  識別子 鄭 end

        //
        /// <summary>
        /// アプリケーションのメイン エントリ ポイントです。
        /// </summary>
        [STAThread]
        static void Main()
        {
            //Mutex名を決める（必ずアプリケーション固有の文字列に変更すること！）
            string mutexName = "CoopEventCreateTool";
            //Mutexオブジェクトを作成する
            bool createdNew;
            System.Threading.Mutex mutex =
                new System.Threading.Mutex(true, mutexName, out createdNew);

            //ミューテックスの初期所有権が付与されたか調べる
            if (createdNew == false)
            {
                //されなかった場合は、すでに起動していると判断して終了
                MessageBox.Show("このアプリケーションはすでに起動しています。", "多重起動禁止", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                mutex.Close();
                return;
            }

            try
            {
                // ログ出力オブジェクトを取得
                NKKLogging wLogging = NKKLogging.GetInstance();

                // 20210908 #5967 識別子  鄭  start
                // ログ識別子
                wLogging.LogExt = $"{LOG_FILE_EXT}_{System.Net.Dns.GetHostName()}";
                wLogging.ErrorLogExt = $"ERR";
                // 20210908 #5967  識別子 鄭 end
                // アプリケーション初期化処理実行
                MyConfig.Init();

                // サインインダイアログ表示のために必要なことを実施
                LayoutDesignerUtility.BaseUri = MyConfig.BaseUri;
                SignInLib.SignIn.SignInInfo = new SignInLib.SignInInfo();
                if (false == string.IsNullOrWhiteSpace(MyConfig.FacilityHash))
                {
                    SignInLib.SignIn.SignInInfo.FacilityHashText = MyConfig.FacilityHash;
                }

                // add 2021-08-27 #6137:BaseNameに値を割り当てます 鄭 start
                if (false == string.IsNullOrWhiteSpace(MyConfig.BaseName))
                {
                    LayoutDesignerUtility.BaseName = MyConfig.BaseName;
                }
                // add 2021-08-27 #6137:BaseNameに値を割り当てます 鄭 end




                // ログ記録
                wLogging.AddLogInfo(DateTime.Now, Application.ProductName, STATIC_CLASS_NAME, NKKLogging.LOGGING_CLASS.INFO, "起動");
                wLogging.AddLogInfo(DateTime.Now, Application.ProductName, STATIC_CLASS_NAME, NKKLogging.LOGGING_CLASS.INFO, string.Format("起動フォルダ,{0}", RldUtility.AppDirPath));

                // エラーログ記録
                wLogging.AddErrorLogInfo(DateTime.Now, Application.ProductName, STATIC_CLASS_NAME, NKKLogging.LOGGING_CLASS.INFO, "起動");
                wLogging.AddErrorLogInfo(DateTime.Now, Application.ProductName, STATIC_CLASS_NAME, NKKLogging.LOGGING_CLASS.INFO, string.Format("起動フォルダ,{0}", RldUtility.AppDirPath));

                // add 2022-10-24 bug #6834 資源内に不要なモジュールが含まれている 孫 start
                // .Net Verのチェック
                const string subKey = @"SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\";
                var dotNetFWVer = new Version(0, 0);
                try
                {
                    using (var sub = RegistryKey.OpenBaseKey(RegistryHive.LocalMachine, RegistryView.Registry32).OpenSubKey(subKey))
                    {
                        if ((sub?.GetValue("Release") is int key))
                        {
                            if (key >= 528040)
                            {
                                dotNetFWVer = new Version(4, 8);
                            }
                            else if (key >= 461808)
                            {
                                dotNetFWVer = new Version(4, 7, 2);
                            }
                            else if (key >= 461308)
                            {
                                dotNetFWVer = new Version(4, 7, 1);
                            }
                            else if (key >= 460798)
                            {
                                dotNetFWVer = new Version(4, 7);
                            }
                            else if (key >= 394802)
                            {
                                dotNetFWVer = new Version(4, 6, 2);
                            }
                            else if (key >= 394254)
                            {
                                dotNetFWVer = new Version(4, 6, 1);
                            }
                            else if (key >= 393295)
                            {
                                dotNetFWVer = new Version(4, 6);
                            }
                            else if (key >= 379893)
                            {
                                dotNetFWVer = new Version(4, 5, 2);
                            }
                            else if (key >= 378675)
                            {
                                dotNetFWVer = new Version(4, 5, 1);
                            }
                            else if (key >= 378389)
                            {
                                dotNetFWVer = new Version(4, 5);
                            }
                        }
                    }
                }
                catch
                {

                }

                // ログ記録
                wLogging.AddLogInfo(DateTime.Now, Application.ProductName, STATIC_CLASS_NAME, NKKLogging.LOGGING_CLASS.INFO, string.Format(".NET Framework {0}", dotNetFWVer.ToString()));

                // add 2022-10-24 bug #6834 資源内に不要なモジュールが含まれている 孫 End 

                try
                {
                    // アプリケーションの外観・描画方法を設定
                    Application.EnableVisualStyles();
                    Application.SetCompatibleTextRenderingDefault(false);

                    // add 2021-03-25 クライアント証明書検索キーを追加 孫 start
                    // サインイン前にサインインを行ってくれるクラスに[クライアント証明書を検索するためのキー値]をセット
                    NKKWebAccess.ClientCertificateSearchValue1 = MyConfig.ClientCertificateSearchValue1.Trim();
                    NKKWebAccess.ClientCertificateSearchValue2 = MyConfig.ClientCertificateSearchValue2.Trim();
                    // add 2021-03-25 クライアント証明書検索キーを追加 孫 end

                    // 画面の表示を開始
                    // サインインに成功するとメソッド内部でNKKWebAccessに各種の必要パラメータがセットされます
                    // mod #12243 連携イベント作成ツール　アイコン差し替え 高 start
                    //var ret = SignInLib.FrmSignIn.ShowSignInDialog(Properties.Resources.LayoutDesigner, MyConfig.SaveFacilityHash);
                    var ret = SignInLib.FrmSignIn.ShowSignInDialog(Properties.Resources.CoopEventCreateTool, MyConfig.SaveFacilityHash);
                    // mod #12243 連携イベント作成ツール　アイコン差し替え 高 end
                    //if (DialogResult.Cancel == ret)
                    //{
                    //    MessageBox.Show("サインインをキャンセルしました。\nオフラインモードで動作します。", "アプリ起動", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    //}

                    if (NKKWebAccess.Login)
                    {

                        if (SignInLib.SignIn.SignInInfo.FacilityCode != string.Empty)
                        {
                            using (var wDlg = new CoopEventCreatOrStopForm())
                            {
                                wDlg.ShowDialog();
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    RldUtility.RecordException(ex);
                }
                finally
                {
                    try
                    {
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
                    finally
                    {
                    }
                }
            }
            finally
            {
                //ミューテックスを解放する
                mutex.ReleaseMutex();
                mutex.Close();
            }

        }
    }
}
