using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Security.Cryptography.X509Certificates;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using LayoutDesignerUtilityLib;
using NKKCommon;
using SignInLib;
using RldUtility = LayoutDesignerUtilityLib.LayoutDesignerUtility;

namespace LayoutDesigner
{
    /// <summary>
    /// フォーム表示制御用クラス
    /// </summary>
    internal sealed class RldStartupFormDisplayer
    {
        #region 生成と破棄

        /// <summary>
        /// フォーム表示制御用クラスの新しいインスタンスを生成します。
        /// </summary>
        public RldStartupFormDisplayer() { }

        /// <summary>
        /// デストラクタ
        /// </summary>
        ~RldStartupFormDisplayer() { }

        #endregion

        #region メンバ関数定義

        /// <summary>
        /// 表示処理を開始します。
        /// </summary>
        public void Start()
        {
            // サインイン画面を表示
            var ret = SignInLib.FrmSignIn.ShowSignInDialog(Properties.Resources.LayoutDesigner, RldUtility.SaveFacilityInfo);
            if (ret == DialogResult.Abort
                || ret == DialogResult.Cancel)
            {
                return;
            }

            // ログ記録するローカル関数
            void addLogInfo(NKKLoggingLib.NKKLogging.LOGGING_CLASS loggingClass, string strMesssage)
            {
                NKKLoggingLib.NKKLogging.GetInstance().AddLogInfo(DateTime.Now, Application.ProductName, GetType().Name, loggingClass, strMesssage);
            }

            // add mongodbに転載、サーバー起動ログ。 陳 start
            LogManagement.LogMessage = "帳票レイアウトデザイナーアプリサーバーが起動しました。";
            LogManagement.SetLogingProperties();
            // add mongodbに転載、サーバー起動ログ。 陳 end

            var updater = new NKKCommon.Updater
            {
                SystemDefineVersionNo = 7,
                ProcType = 1,
                // mod サンプルレイアウトをサーバからダウンロードして、編集できる機能。 陳 start
                //DownloadFileName = "LayoutDesigner.zip",
                DownloadFileName = RldUtility.DownloadFileName,
                ModelFileName = RldUtility.ModelFileName,
                BucketModel = RldUtility.ModelFolder,
                // mod サンプルレイアウトをサーバからダウンロードして、編集できる機能。 陳 end
                Bucket = RldUtility.DownloadSourceFolder,
                DownloadFilePassword = RldUtility.DOWNLOAD_FILE_PASSWORD,
                LoggingMethod = addLogInfo
            };

            // 新しいバージョンが公開されているか確認
            // 公開されている場合、バージョンアップするかダイアログを表示する
            if (SignInLib.SignIn.SignInInfo.IsOnline &&
                updater.IsPublishedNewVersion(System.Reflection.Assembly.GetExecutingAssembly()) &&
                RldMessageBox.Show("新しいバージョンが公開されています。プログラムを更新しますか？", "更新", System.Windows.Forms.MessageBoxButtons.YesNo,
                                   System.Windows.Forms.MessageBoxIcon.Question) == System.Windows.Forms.DialogResult.Yes)
            {

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
                    RldMessageBox.Show("更新されたプログラムファイルを取得することができませんでした", "更新", System.Windows.Forms.MessageBoxButtons.OK, System.Windows.Forms.MessageBoxIcon.Exclamation);

                }

            }

            // add サンプルレイアウトをサーバからダウンロードして、編集できる機能。 陳 start

            // オンラインの時モデルのバージョンを取得する
            if (SignInLib.SignIn.SignInInfo.IsOnline)
            {
                // add FNSI-仕様追加 帳票モデルのバージョン判定 夏 start
                // データベースから帳票モデルのバージョンを取得する
                string strModelVersion = NKKCommon.Updater.GetSystemDefineValue(36);
                if (!string.IsNullOrEmpty(strModelVersion))
                {
                    var dVer = new NKKCommon.VersionValue();
                    using (var ms = new System.IO.MemoryStream(Encoding.UTF8.GetBytes(strModelVersion)))
                    {
                        var ser = new System.Runtime.Serialization.Json.DataContractJsonSerializer(dVer.GetType());
                        dVer = ser.ReadObject(ms) as NKKCommon.VersionValue;
                        ms.Close();
                    }

                    // 帳票モデルのバージョンをプロファイルに保存する
                    if (!string.IsNullOrEmpty(dVer.version)
                        && !string.IsNullOrEmpty(LayoutDesignerUtilityLib.LayoutDesignerUtility.ModelVersion)
                        && new Version(dVer.version).Equals(new Version(LayoutDesignerUtilityLib.LayoutDesignerUtility.ModelVersion)))
                    {
                        LayoutDesignerUtilityLib.LayoutDesignerUtility.ModelVersion = String.Empty;
                    }
                    else
                    {
                        LayoutDesignerUtilityLib.LayoutDesignerUtility.ModelVersion = dVer.version;
                    }
                }
                else
                {
                    LayoutDesignerUtilityLib.LayoutDesignerUtility.ModelVersion = String.Empty;
                }
                // add FNSI-仕様追加 帳票モデルのバージョン判定 夏 end

                // 新しいサンプルレイアウトを表示する
                // mod FNSI-仕様追加 帳票モデルのバージョン判定 夏 start
                //if (SignInLib.SignIn.SignInInfo.IsOnline)
                if (!String.IsNullOrEmpty(LayoutDesignerUtilityLib.LayoutDesignerUtility.ModelVersion))
                // mod FNSI-仕様追加 帳票モデルのバージョン判定 夏 end
                {
                    // Amazon S3から新しいファイルをダウンロードし、自己アップデートする
                    if (updater.GetS3ModelFile())
                    {
                        // 解凍成功

                        // 自己アップデート
                        updater.ModelFileUpdate();

                        // add FNSI-仕様追加 帳票モデルのバージョン判定 夏 start
                        LayoutDesignerUtilityLib.LayoutDesignerUtility.SaveConfigInfo("ModelVersion", LayoutDesignerUtilityLib.LayoutDesignerUtility.ModelVersion);
                        // add FNSI-仕様追加 帳票モデルのバージョン判定 夏 end
                    }
                    else
                    {
                        // ダウンロードに失敗したことを表示する
                        RldMessageBox.Show("更新されたサンプルレイアウトファイルを取得することができませんでした", "更新", System.Windows.Forms.MessageBoxButtons.OK,
                            System.Windows.Forms.MessageBoxIcon.Exclamation);

                    }
                }
                // add サンプルレイアウトをサーバからダウンロードして、編集できる機能。 陳 end
            }

            // アプリケーション初期化処理実行
            if (!RldLib.AppStartUp())
            {
                return;
            }

            // メインメニューを表示せずに直接デザイン画面を表示するかどうか確認
            bool wIsByPassMainMenu = RldLib.CheckContinueEditWorkFile();

            // add #11501 レイアウトデザイナのユーザビリティ改善 高 start
            RldStartUpInit();
            // add #11501 レイアウトデザイナのユーザビリティ改善 高 end

            // add #12026 帳票移植時にフィルタ設定が無効化する（初期対応） 高 start
            if(wIsByPassMainMenu)
                RldLib.IsWorkXlsx = true;
            else
                RldLib.IsWorkXlsx = false;
            // add #12026 帳票移植時にフィルタ設定が無効化する（初期対応） 高 end

            var wResult = System.Windows.Forms.DialogResult.OK;

            int selectedTabIndex = 0;
            while (true)
            {
                Rectangle wInitialWindowLayoutWorkingArea = Rectangle.Empty;
                // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 start
                RldDataGridViewParamDataEditHelper.middleData = new Dictionary<object, string>();
                // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 end
                // メインメニューを表示する場合はメインメニューを表示する
                if (!wIsByPassMainMenu)
                {
                    // メインメニューを表示
                    using (var wDlg = new frmMainMenu() { IsDeleteWorkXlsxFile = true })
                    {
                        wResult = wDlg.ShowDialog(selectedTabIndex);
                        if (!wDlg.Bounds.IsEmpty)
                        {
                            wInitialWindowLayoutWorkingArea = Screen.FromRectangle(wDlg.Bounds).WorkingArea;
                        }
                    }
                }

                // 作業中ファイルフラグを Off
                wIsByPassMainMenu = false;

                // デザイン画面を表示する
                if (wResult == System.Windows.Forms.DialogResult.OK)
                {

                    // デザイン画面を表示する
                    using (var wDlg = new frmDesignParent())
                    {
                        if (!wInitialWindowLayoutWorkingArea.IsEmpty)
                        {
                            wDlg.InitialWindowLayoutWorkingArea = wInitialWindowLayoutWorkingArea;
                        }

                        wResult = wDlg.ShowDialog();
                        // add  2021-09-02 #6370:判定条件を変更する 鄭 start
                        if (wDlg.ErrorMessage)
                        {
                            wIsByPassMainMenu = true;
                        }
                        // add  2021-09-02 #6370:判定条件を変更する 鄭 end
                        // add #5964 ログインIDがタイムアウトになった場合の動作について 王永吉 start
                        if (wDlg.DoFlag)
                        {
                            using (var wDolg = new FrmSignIn())
                            {
                                wResult = wDolg.ShowDialog();
                                wIsByPassMainMenu = RldLib.CheckContinueEditWorkFile();
                                if (wIsByPassMainMenu)
                                {
                                    // add #12026 帳票移植時にフィルタ設定が無効化する（初期対応） 高 start
                                    RldLib.IsWorkXlsx = true;
                                    // add #12026 帳票移植時にフィルタ設定が無効化する（初期対応） 高 end
                                    continue;
                                }
                            }
                        }
                        // add #5964 ログインIDがタイムアウトになった場合の動作について 王永吉 end
                    }

                    // add #12026 帳票移植時にフィルタ設定が無効化する（初期対応） 高 start
                    RldLib.IsWorkXlsx = false;
                    // add #12026 帳票移植時にフィルタ設定が無効化する（初期対応） 高 end

                    // 戻るを選択した場合には、メインメニュー表示時に帳票マスタ(編集)を表示する
                    if (wResult == System.Windows.Forms.DialogResult.OK)
                    {
                        // オンラインの時モデルのバージョンを取得する
                        if (SignInLib.SignIn.SignInInfo.IsOnline)
                        {
                            // メインメニュー表示時に帳票マスタ(編集)を表示する
                            selectedTabIndex = 1;
                        }
                        else
                        {
                            selectedTabIndex = 0;
                        }
                    }

                }

                // キャンセル時は抜ける
                if (wResult == System.Windows.Forms.DialogResult.Cancel)
                {
                    break;
                }
            }
        }

        // add #11501 レイアウトデザイナのユーザビリティ改善 高 start
        // init
        private void RldStartUpInit()
        {
            if (Properties.Settings.Default.UpgradeRequired)
            {
                // version up
                Properties.Settings.Default.Upgrade();

                Properties.Settings.Default.UpgradeRequired = false;
                Properties.Settings.Default.Save();
            }

            // init Properties.Settings.Default
            Properties.Settings.Default.MainMenuMakeNode = "";
            Properties.Settings.Default.MainMenuEditNode = "";
            Properties.Settings.Default.MainMenuEditCurrent = "";
            Properties.Settings.Default.MainMenuEditDisp = "";
            Properties.Settings.Default.Save();
        }
        // add #11501 レイアウトデザイナのユーザビリティ改善 高 end

        #endregion
    }
}
