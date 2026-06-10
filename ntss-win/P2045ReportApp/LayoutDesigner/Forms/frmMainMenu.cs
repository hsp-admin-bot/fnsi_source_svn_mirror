using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

using System.IO.Compression;

using RldMsgBox = LayoutDesignerUtilityLib.RldMessageBox;
using RldUtility = LayoutDesignerUtilityLib.LayoutDesignerUtility;
using NKKWebAccessLib;
using NKKCommon;

namespace LayoutDesigner
{
    /// <summary>
    /// メインメニュー画面
    /// </summary>
    public partial class frmMainMenu : LayoutDesignerUtilityLib.Controls.frmRldSizableBase
    {
        #region メンバ変数定義

        /// <summary>
        /// イベント通知先格納用リスト
        /// </summary>
        private Dictionary<TabPage, IRldMainMenuChild> m_Children = null;

        #endregion

        #region メンバイベント定義

        /// <summary>
        /// 通知用イベント
        /// </summary>
        private event EventHandler<RldMainMenuNotifyInfoEventArgs> NotifyInfo;

        #endregion

        #region 生成と破棄

        /// <summary>
        /// メインメニューウィンドウクラスの新しいインスタンスを初期化します。
        /// </summary>
        public frmMainMenu()
        {
            InitializeComponent();

            // アイコンの設定
            this.Icon = Properties.Resources.LayoutDesigner;

            // サブフォーム格納用リスト生成
            this.m_Children = new Dictionary<TabPage, IRldMainMenuChild>();

            // 新規作成画面を初期化
            LFunc_AddFormToTabPage(this.tbpAddNew, new frmMainMenuChildMakeReport());
            // 編集画面を初期化
            LFunc_AddFormToTabPage(this.tbpEdit, new frmMainMenuChildEditReport());

            // イベントハンドラ割り当て
            this.tabControl.Selecting += new TabControlCancelEventHandler(this.tabControl_Selecting);

            /// <summary>
            /// (ローカル関数) 指定した System.Windows.Forms.TabPage 内に指定した System.Windows.Forms.Form をセットします。
            /// </summary>
            /// <param name="aPage"></param>
            /// <param name="aForm"></param>
            void LFunc_AddFormToTabPage(System.Windows.Forms.TabPage aPage, LayoutDesignerUtilityLib.Controls.frmRldBase aForm)
            {
                // フォームのプロパティを設定
                aForm.TopLevel = false;
                aForm.FormBorderStyle = FormBorderStyle.None;
                aForm.Dock = DockStyle.Fill;
                aForm.CloseEscapeKey = false;
                aForm.MoveNextEnterKey = false;

                // タブページにフォームを追加
                aPage.Controls.Add(aForm);

                // 表示して最前面へ移動
                aForm.Show();
                aForm.BringToFront();

                if( aForm is IRldMainMenuChild wChild ) {
                    wChild.NotifyInfo += new EventHandler<RldMainMenuNotifyInfoEventArgs>(this.ChildNotifyInfoHandler);
                    this.m_Children.Add(aPage, wChild);
                }
            }
        }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// 作業用 Excel ファイルを削除するかどうかの取得及び設定を行います。
        /// 既定値は 削除しない(False) です。
        /// </summary>
        [System.ComponentModel.Browsable(false)]
        public Boolean IsDeleteWorkXlsxFile { get; set; } = false;

        #endregion

        #region メンバ関数定義

        /// <summary>
        /// 接続のメッセージを処理する
        /// </summary>
        /// <param name="strServiceName"></param>
        /// <param name="strStatus"></param>
        /// <param name="dtNow"></param>
        /// <param name="strMessage"></param>
        private void HandleAccessMessage(string strServiceName, string strStatus, DateTime dtNow, string strMessage)
        {
            switch (strStatus)
            {
                case "Disconnected":
                    {
                        string wMsg = "接続が切断しました。オンラインモードに移動しますか？";
                        if (RldMsgBox.Show(wMsg.ToString(), @"確認してください", System.Windows.Forms.MessageBoxButtons.YesNo, System.Windows.Forms.MessageBoxIcon.Warning) == System.Windows.Forms.DialogResult.Yes)
                        {
                            SignInLib.SignIn.SignInInfo.IsOnline = false;
                            SwitchMode();
                        }
                        break;
                    }
                case "Connected":
                    {
                        break;
                    }
                default:
                    {
                        break;
                    }
            }
        }

        /// <summary>
        /// SwitchModeCallback
        /// </summary>
        private delegate void SwitchModeCallback();

        /// <summary>
        /// オンライン・オフラインを変更する
        /// </summary>
        private void SwitchMode()
        {
            if (this.InvokeRequired)
            {
                SwitchModeCallback calback = new SwitchModeCallback(SwitchMode);
                this.Invoke(calback);
            }
            else
            {
                if (SignInLib.SignIn.SignInInfo.IsOnline)
                {
                }
                else
                {
                    if (this.tabControl.SelectedIndex != 0)
                    {
                        this.tabControl.SelectedIndex = 0;
                    }
                }
            }
        }

        /// <summary>
        /// 新規作成処理を行います。
        /// </summary>
        /// <param name="e"></param>
        /// <returns></returns>
        private Boolean ActionOfMakeReport(RldMainMenuNotifyInfoRequestNewReportEventArgs e)
        {
            Boolean wRet = !e.IsModelFile;

            // サンプルレイアウトファイルから作成する場合はサンプルレイアウトファイルを開いてワークファイルとして保存する
            if( e.IsModelFile ) {
                //System.IO.File.Copy(e.ModelFilePath, RldLib.WorkXlsxFilePath);
                using( var wXlsHelper = new RldExcelHelper() ) {
                    if( wXlsHelper.Open(e.ModelFilePath) )
                        if( wXlsHelper.Save(RldLib.WorkXlsxFilePath) )
                            wRet = true;
                }

                // サンプルレイアウトファイルのコピーに失敗した場合は抜ける
                if( !wRet ) return false;
            }

            using( var wXlsHelper = new RldExcelHelper() ) {

                // ワークファイルを開いていない場合は開く(失敗時は抜ける)
                if( !(wRet = wXlsHelper.Open(RldLib.WorkXlsxFilePath)) ) return false;

                // 初期設定情報を作成
                var wSettingData = new DesignSettingData() {
                    ReportClass = e.ReportType,
                    ReportCode = String.Empty,
                    HasTemplete = RldConst.SettingData.VAL_HAS_TEMPLETE_NO
                };

                // 初期設定情報を書き込み
                if( !(wRet = wXlsHelper.SetSettingData(wSettingData)) ) return false;
                // 保存
                if( !(wRet = wXlsHelper.Save()) ) return false;
            }

            return wRet;
        }

        /// <summary>
        /// 編集時処理を行います。
        /// </summary>
        /// <param name="e"></param>
        /// <returns></returns>
        private Boolean ActionOfEditReport(RldMainMenuNotifyInfoRequestEditReportEventArgs e)
        {
            Boolean wRet = false;

            var wReportData = e.ReportData;

            try {
                // 一時ファイル保存用ディレクトリをクリア
                RldLib.ClearTempXlsDirPath();

                String wTempDirPath = RldLib.GetTempXlsDirPath();

                // 選択された帳票を一時フォルダへダウンロード
                if( !(wRet = Task<Boolean>.Run(async () => await this.ActionOfEditReport_DownloadFile(wTempDirPath, wReportData)).Result) ) {
                    // ダウンロード失敗
                    return false;
                }

                // ダウンロードファイルを一時帳票ファイルとして解凍
                if (!(wRet = this.ActionOfEditReport_ExtractFile(wTempDirPath, wReportData.ReportPath, RldLib.WorkXlsxFilePath)))
                {
                    // 解凍失敗
                    return false;
                }

                // ワークファイル内にレポートCDを書き込む
                using( var wXlsHelper = new RldExcelHelper() ) {

                    // ワークファイルを開く
                    if( !(wRet = wXlsHelper.Open(RldLib.WorkXlsxFilePath)) ) return false;

                    // 設定情報を取得
                    var wSettingData = wXlsHelper.GetSettingData();

                    // 一時保存に備えてレポートCDをセットしておく
                    wSettingData.ReportCode = wReportData.ReportCode.ToString();

                    // 設定情報を書き込み
                    if( !(wRet = wXlsHelper.SetSettingData(wSettingData)) ) return false;
                    // 保存
                    if( !(wRet = wXlsHelper.Save()) ) return false;
                }
            }
            catch(Exception ex) {
                // TODO:
            }

            return wRet;
        }

        // add 2021-02-19 No.517:FNW帳票レイアウトコンバート 趙 start
        /// <summary>
        /// レイアウトコンバート処理を行います。
        /// </summary>
        /// <param name="e"></param>
        /// <returns></returns>
        private Boolean ActionOfConvertReport(RldMainMenuNotifyInfoRequestConvertReportEventArgs e)
        {
            Boolean wRet = false;

            using (var wXlsHelper = new RldExcelHelper())
            {
                if (wXlsHelper.Open(e.ConvertFilePath))
                {
                    if (!wXlsHelper.Save(RldLib.WorkXlsxFilePath)) 
                        wRet = true;
                }
            }

            using (var wXlsHelper = new RldExcelHelper())
            {

                // ワークファイルを開いていない場合は開く(失敗時は抜ける)
                if (!(wRet = wXlsHelper.Open(RldLib.WorkXlsxFilePath))) return false;

                // add #8335 FNW帳票取込みの動作に問題あり 夏 start
                // 帳票種別取得
                using (var wXlRange = new ExcelRangeEx(wXlsHelper.XlSheetSetting, RldConst.SettingData.CELLADDR_REPORT_TYPE))
                {
                    e.ReportType = wXlRange.GetValue2() as string;
                }
                // add #8335 FNW帳票取込みの動作に問題あり 夏 end

                // 初期設定情報を作成
                var wSettingData = new DesignSettingData()
                {
                    ReportClass = e.ReportType,
                    ReportCode = String.Empty,
                    HasTemplete = RldConst.SettingData.VAL_HAS_TEMPLETE_NO
                };

                // 初期設定情報を書き込み
                if (!(wRet = wXlsHelper.SetSettingData(wSettingData))) return false;
                // 保存
                if (!(wRet = wXlsHelper.Save())) return false;
            }

            return wRet;
        }
        // add 2021-02-19 No.517:FNW帳票レイアウトコンバート 趙 end

        // add #11502 レイアウトデザイナに2件の管理者用機能を追加 高 start
        /// <summary>
        /// レイアウト一時ファイル処理を行います。
        /// </summary>
        /// <param name="e"></param>
        /// <returns></returns>
        private Boolean ActionOfTempReport(RldMainMenuNotifyInfoRequestTempReportEventArgs e)
        {
            Boolean wRet = true;

            // temp file name
            string fileName = e.TempFilePath;


            // copy temp file to work.xlsx
            // add #12477 管理者モード起動時に一時ファイルを検知すると日機装施設で開いてしまう 高 start
            if(fileName != RldLib.WorkXlsxFilePath)
            // add #12477 管理者モード起動時に一時ファイルを検知すると日機装施設で開いてしまう 高 end
                System.IO.File.Copy(fileName, RldLib.WorkXlsxFilePath);

            // add #12026 帳票移植時にフィルタ設定が無効化する（初期対応） 高 start
            RldLib.IsWorkXlsx = true;
            // add #12026 帳票移植時にフィルタ設定が無効化する（初期対応） 高 end

            return wRet;
        }
        // add #11502 レイアウトデザイナに2件の管理者用機能を追加 高 end

        /// <summary>
        /// 編集時処理(ファイルダウンロード)を行います。
        /// </summary>
        /// <param name="aDownloadDirPath"></param>
        /// <param name="aReportData"></param>
        /// <returns></returns>
        private async Task<Boolean> ActionOfEditReport_DownloadFile(String aDownloadDirPath, MstReportData aReportData)
        {
            Boolean wRet = false;

            try {
                // Amazon S3 ヘルパークラスを生成
                var wHelper = new RldAmazonS3Helper() {
                    UseS3Bucket = RldUtility.UseS3Bucket,
                    S3Bucket = aReportData.ReportPath.S3Bucket,
                    FacilityCode = SignInLib.SignIn.SignInInfo.FacilityCode
                };

                // ダウンロードを実行
                // add #7922 新規施設のデフォルト帳票に作成者・更新者が登録されている / デフォルト帳票が編集できない 商 start
                if (aReportData.ReportPath.ZipReportFileName.StartsWith("_"))
                {
                    aReportData.ReportPath.ZipReportFileName = aReportData.ReportPath.ZipReportFileName.Substring(1);
                }
                // add #7922 新規施設のデフォルト帳票に作成者・更新者が登録されている / デフォルト帳票が編集できない 商 end
                var wResValue = await wHelper.DownloadFile(aReportData.ReportCode, aReportData.ReportPath.ZipReportFileName, aDownloadDirPath);
                var wResText = wHelper.LastErrorMessage;

                wRet = wResValue;
            }
            catch( Exception ex ) {
                // TODO:
            }

            return wRet;
        }

        /// <summary>
        /// 編集時処理(解凍処理)を行います。
        /// </summary>
        /// <param name="aDownloadDirPath"></param>
        /// <param name="reportPath"></param>
        /// <param name="aExtractedFilePath"></param>
        /// <returns></returns>
        private Boolean ActionOfEditReport_ExtractFile(String aDownloadDirPath, MstReportData.Path reportPath, String aExtractedFilePath)
        {
            Boolean wRet = false;

            try {
                // 圧縮ファイルを開く
                using (var wFile = ZipFile.OpenRead($"{aDownloadDirPath}\\{reportPath.ZipReportFileName}"))
                {
                    if (wFile.GetEntry(reportPath.ExcelFileName) is ZipArchiveEntry wEntry)
                    {
                        wEntry.ExtractToFile(aExtractedFilePath, true);
                    }
                }

                wRet = true;
            }
            catch( Exception ex ) {
                // TODO:
            }

            return wRet;
        }

        /// <summary>
        /// モーダルダイアログで表示する
        /// </summary>
        /// <param name="selectedIndex">表示するタブページ</param>
        /// <returns></returns>
        public DialogResult ShowDialog(int selectedIndex)
        {
            NKKWebAccess.GetInstance().SendMessageToGUIHandler += new ToGUILib.ToGUI.dgtSendMessageToGUI(HandleAccessMessage);

            // アクティブなページを変更する
            if (this.tabControl.SelectedIndex != selectedIndex)
            {
                this.tabControl.SelectedIndex = selectedIndex;
            }

            // ダイアログを表示する
            return ShowDialog();

        }

        #endregion

        #region コントロールイベントハンドラ定義

        /// <summary>
        /// タブコントロールの Selecting イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void tabControl_Selecting(object sender, TabControlCancelEventArgs e)
        {
            // 新しいタブを選択中ではない場合は抜ける
            if( e.Action != TabControlAction.Selecting ) return;

            // 帳票を編集タブにタブの切り替えを行ってもよいか確認する
            if( e.TabPage == this.tbpAddNew ) {     // 新規作成タブを選択しようとしているため、このif文となる
                // add #11501 レイアウトデザイナのユーザビリティ改善 高 start
                saveEditReportData();
                // add #11501 レイアウトデザイナのユーザビリティ改善 高 end

                var wEventData = new RldMainMenuNotifyInfoCheckDeactiveEventArgs() { Cancel = false };

                // イベント発行
                var wChild = this.m_Children[this.tbpEdit];
                this.NotifyInfo += new EventHandler<RldMainMenuNotifyInfoEventArgs>(wChild.ReceiveNotifyInfo);
                this.NotifyInfo.Invoke(this, wEventData);
                this.NotifyInfo -= new EventHandler<RldMainMenuNotifyInfoEventArgs>(wChild.ReceiveNotifyInfo);

                e.Cancel = wEventData.Cancel;
                // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 start
                // 新規作成画面を初期化
                LFunc_InitFormToTabPage(this.tbpAddNew, new frmMainMenuChildMakeReport());
                // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 end
            }
            else if( e.TabPage == this.tbpEdit ) {  // 編集タブを選択しようとしているため、このif文となる
                if( !SignInLib.SignIn.SignInInfo.IsOnline ) {
                    
                    e.Cancel = true;
                }
                // add #11501 レイアウトデザイナのユーザビリティ改善 高 start
                saveMakeReportData();
                // add #11501 レイアウトデザイナのユーザビリティ改善 高 end

                // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 start
                // 編集画面を初期化
                LFunc_InitFormToTabPage(this.tbpEdit, new frmMainMenuChildEditReport());
                // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 end
            }
        }

        #endregion

        #region カスタムイベントハンドラ定義

        /// <summary>
        /// サブフォームからのイベントを受信します。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void ChildNotifyInfoHandler(object sender, RldMainMenuNotifyInfoEventArgs e)
        {
            Boolean wActionRet = false;

            // 作業用 Excel ファイルの削除指定時
            if (this.IsDeleteWorkXlsxFile)
            {
                // add #12477 管理者モード起動時に一時ファイルを検知すると日機装施設で開いてしまう 高 start
                if ("1".Equals(SignInLib.SignIn.SignInInfo.UserType) 
                    && e.InfoType == RldMainMenuNotifyInfoEventArgs.EnumInfoType.TempReport 
                    && ((RldMainMenuNotifyInfoRequestTempReportEventArgs)e).TempFilePath == RldLib.WorkXlsxFilePath)
                {
                    ;
                }
                else
                // add #12477 管理者モード起動時に一時ファイルを検知すると日機装施設で開いてしまう 高 end
                    // 作業用 Excel ファイルの削除試行(失敗時は抜ける)
                    if (!RldUtility.DeleteFileIfExists(RldLib.WorkXlsxFilePath)) return;
            }

            switch( e.InfoType ) {
                case RldMainMenuNotifyInfoEventArgs.EnumInfoType.NewReport:
                    // 新規作成
                    wActionRet = this.ActionOfMakeReport((RldMainMenuNotifyInfoRequestNewReportEventArgs)e);
                    break;

                case RldMainMenuNotifyInfoEventArgs.EnumInfoType.EditReport:
                    // 編集
                    wActionRet = this.ActionOfEditReport((RldMainMenuNotifyInfoRequestEditReportEventArgs)e);
                    break;

                // add 2021-02-19 No.517:FNW帳票レイアウトコンバート 趙 start
                case RldMainMenuNotifyInfoEventArgs.EnumInfoType.ConvertReport:
                    // コンバート
                    wActionRet = this.ActionOfConvertReport((RldMainMenuNotifyInfoRequestConvertReportEventArgs)e);
                    break;
                // add 2021-02-19 No.517:FNW帳票レイアウトコンバート 趙 end

                // add #11502 レイアウトデザイナに2件の管理者用機能を追加 高 start
                case RldMainMenuNotifyInfoEventArgs.EnumInfoType.TempReport:
                    // コンバート
                    wActionRet = this.ActionOfTempReport((RldMainMenuNotifyInfoRequestTempReportEventArgs)e);
                    break;
                // add #11502 レイアウトデザイナに2件の管理者用機能を追加 高 end

                default:
                    break;
            }

            // 該当処理が成功した場合は閉じる
            if (wActionRet)
                this.DialogResult = DialogResult.OK;
            else
            {
                if (SignInLib.SignIn.SignInInfo.IsOnline && !NKKWebAccess.Login)
                {
                    string wMsg = "接続が切断しました。オンラインモードに移動しますか？";
                    if (RldMsgBox.Show(wMsg.ToString(), @"確認してください", System.Windows.Forms.MessageBoxButtons.YesNo, System.Windows.Forms.MessageBoxIcon.Warning) == System.Windows.Forms.DialogResult.Yes)
                    {
                        SignInLib.SignIn.SignInInfo.IsOnline = false;
                        SwitchMode();
                    }
                }
            }
        }

        // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 start
        /// <summary>
        /// (ローカル関数) 指定した System.Windows.Forms.TabPage 内に指定した System.Windows.Forms.Form をセットします。
        /// </summary>
        /// <param name="aPage"></param>
        /// <param name="aForm"></param>
        private void LFunc_InitFormToTabPage(System.Windows.Forms.TabPage aPage, LayoutDesignerUtilityLib.Controls.frmRldBase aForm)
        {
            // フォームのプロパティを設定
            aPage.Controls.Remove(aForm);
            aForm.TopLevel = false;
            aForm.FormBorderStyle = FormBorderStyle.None;
            aForm.Dock = DockStyle.Fill;
            aForm.CloseEscapeKey = false;
            aForm.MoveNextEnterKey = false;
            // タブページにフォームを追加
            aPage.Controls.Add(aForm);
            // 表示して最前面へ移動
            aForm.Show();
            aForm.BringToFront();
            if (aForm is IRldMainMenuChild wChild)
            {
                this.m_Children.Remove(aPage);
                wChild.NotifyInfo += new EventHandler<RldMainMenuNotifyInfoEventArgs>(this.ChildNotifyInfoHandler);
                this.m_Children.Add(aPage, wChild);
            }
        }

        // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 end

        // add mongodbに転載、サーバー停止ログ。 陳 start
        private void frmMainMenu_FormClosed(object sender, FormClosedEventArgs e)
        {
            NKKWebAccess.SendMessageHandler -= this.HandleAccessMessage;

            if (NKKWebAccess.Login)
            {
                LogManagement.LogMessage = "帳票レイアウトデザイナーアプリサーバーが停止しました。";
                LogManagement.SetLogingProperties();
            }

            // add #11501 レイアウトデザイナのユーザビリティ改善 高 start
            saveReportData();
            // add #11501 レイアウトデザイナのユーザビリティ改善 高 end
        }
        // add mongodbに転載、サーバー停止ログ。 陳 end

        #endregion

        // add #11501 レイアウトデザイナのユーザビリティ改善 高 start
        // save edit report
        private void saveEditReportData()
        {
            try
            {
                // save edit report
                frmMainMenuChildEditReport childEditReport = null;

                foreach (Control control in tbpEdit.Controls)
                {
                    if (control is frmMainMenuChildEditReport tChildEditReport)
                    {
                        childEditReport = tChildEditReport;
                        break;
                    }
                }

                if (childEditReport != null)
                {
                    childEditReport.saveEditReport();
                }
            }
            catch (Exception)
            { }
        }

        // save make report
        private void saveMakeReportData()
        {
            try
            {
                // save make report
                frmMainMenuChildMakeReport childMakeReport = null;

                foreach (Control control in tbpAddNew.Controls)
                {
                    if (control is frmMainMenuChildMakeReport tChildMakeReport)
                    {
                        childMakeReport = tChildMakeReport;
                        break;
                    }
                }

                if (childMakeReport != null)
                {
                    childMakeReport.saveMakeReport();
                }
            }
            catch (Exception)
            { }
        }

        // save edit report and make report
        private void saveReportData()
        {
            // save window size to Properties.Settings
            saveWindow();

            // save report data
            saveEditReportData();
            saveMakeReportData();
        }

        // save window size to Properties.Settings, format is json.
        public void saveWindow()
        {
            try
            {
                // window form is normai
                if (this.WindowState == FormWindowState.Normal)
                {
                    StringBuilder outJson = new StringBuilder();

                    // save width and height of window
                    outJson.Append("{")
                        .AppendFormat("\"Width\": \"{0}\",", this.Width)
                        .AppendFormat("\"Height\": \"{0}\"", this.Height)
                        .Append("}");
                    Properties.Settings.Default.MainMenuWindowSize = outJson.ToString();

                    // save location of form
                    Properties.Settings.Default.MainMenuWindowLocation = this.Location;
                    Properties.Settings.Default.Save();

                    outJson.Length = 0;
                }
            }
            catch(Exception)
            { }
        }

        // check Location is valid
        private static bool IsValidLocation(Point location)
        {
            // check point is empty
            if (location == Point.Empty ||
                location == default(Point) ||
                location.X == 0 && location.Y == 0)
            {
                return false;
            }

            // range in screen
            foreach (Screen screen in Screen.AllScreens)
            {
                if (screen.WorkingArea.Contains(location))
                {
                    return true;
                }
            }

            return false;
        }

        // restore window size
        private void restoreWindow()
        {
            bool bRet;

            // restore width and height of window
            Dictionary<String, String> json = NKKWebAccess.GetJsonData(Properties.Settings.Default.MainMenuWindowSize);
            if (json.Count() > 0)
            {
                if (json["Width"] != "")
                {
                    bRet = int.TryParse(json["Width"], out int lNum);
                    if (bRet)
                        this.Width = lNum;
                }

                if (json["Height"] != "")
                {
                    bRet = int.TryParse(json["Height"], out int lNum);
                    if (bRet)
                        this.Height = lNum;
                }
            }

            // restore location of form
            Point savedLocation = Properties.Settings.Default.MainMenuWindowLocation;
            if (IsValidLocation(savedLocation))
            {
                this.Location = savedLocation;
            }
        }

        private void frmMainMenu_Load(object sender, EventArgs e)
        {
            // restore window size
            restoreWindow();
        }
        // add #11501 レイアウトデザイナのユーザビリティ改善 高 end
    }
}
