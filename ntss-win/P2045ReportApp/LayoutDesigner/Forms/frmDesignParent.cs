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

using NKKWebAccessLib;

using RldMsgBox = LayoutDesignerUtilityLib.RldMessageBox;
using RldUtility = LayoutDesignerUtilityLib.LayoutDesignerUtility;
using System.Threading;
using LayoutDesigner.Helpers;
using static LayoutDesigner.MstReportData;
using SignInLib;
using LayoutDesignerUtilityLib;
using System.IO;
using NKKCommon;
using System.Text.RegularExpressions;

using Excel = Microsoft.Office.Interop.Excel;

namespace LayoutDesigner
{
    /// <summary>
    /// デザイン親画面
    /// </summary>
    public partial class frmDesignParent
        : LayoutDesignerUtilityLib.Controls.frmRldBase, IRldDesignMediator

    {
        #region 内部使用クラス定義

        /// <summary>
        /// 別のフォームを表示するための抽象クラス
        /// </summary>
        private abstract class AbstructDesignOpenDialogForm : frmDesignChildBase
        {
            #region 生成と破棄

            /// <summary>
            /// 別のフォームを表示するための抽象クラスの新しいインスタンスを初期化します。
            /// </summary>
            /// <param name="aParent"></param>
            protected AbstructDesignOpenDialogForm(frmDesignParent aParent) : base()
            {
                this.ShowInTaskbar = false;
                this.ShowIcon = false;
                this.DesignerParent = aParent;
                base.Opacity = 0.7d;

                this.SetOwnAppearance();
            }

            #endregion

            #region メンバプロパティ定義

            /// <summary>
            /// 親フォームへの参照の取得を行います。
            /// 値の取得のみ可能です。
            /// </summary>
            protected frmDesignParent DesignerParent { get; private set; } = null;

            #endregion

            #region メンバ関数定義(override...)

            /// <summary>
            /// Form.Load イベントを発生させます。
            /// </summary>
            /// <param name="e"></param>
            protected override void OnLoad(EventArgs e)
            {
                base.OnLoad(e);

                if (base.DesignMode)
                {
                    return;
                }
            }

            /// <summary>
            /// Form.OnShown イベントを発生させます。
            /// </summary>
            /// <param name="e"></param>
            protected override void OnShown(EventArgs e)
            {
                base.OnShown(e);

                // 子ウィンドウの設定を変更する
                // del #8394 動作に関する指摘 董 start
                //this.ChangeColleagueFormSettings(false);
                // del #8394 動作に関する指摘 董 end
            }

            #endregion

            #region メンバ関数定義

            /// <summary>
            /// 自分自身の外観を変更します。
            /// </summary>
            private void SetOwnAppearance()
            {
                var wWorkingArea = System.Windows.Forms.Screen.FromPoint(Cursor.Position).WorkingArea;
                if (this.Owner != null)
                {
                    wWorkingArea = System.Windows.Forms.Screen.FromControl(this.Owner).WorkingArea;
                }

                var wLeftTop = new System.Drawing.Point(wWorkingArea.Right, wWorkingArea.Bottom);
                var wRightBottom = new System.Drawing.Point(wWorkingArea.Left, wWorkingArea.Top);

                foreach (var wColleague in this.DesignerParent.m_Colleagues)
                {
                    var wForm = wColleague as System.Windows.Forms.Form;
                    if (wForm != null)
                    {
                        if (wLeftTop.X > wForm.DesktopBounds.X)
                        {
                            wLeftTop.X = wForm.DesktopBounds.X;
                        }

                        if (wLeftTop.Y > wForm.DesktopBounds.Y)
                        {
                            wLeftTop.Y = wForm.DesktopBounds.Y;
                        }

                        if (wRightBottom.X < wForm.DesktopBounds.Right)
                        {
                            wRightBottom.X = wForm.DesktopBounds.Right;
                        }

                        if (wRightBottom.Y < wForm.DesktopBounds.Bottom)
                        {
                            wRightBottom.Y = wForm.DesktopBounds.Bottom;
                        }
                    }
                }
                this.SetDesktopBounds(wLeftTop.X, wLeftTop.Y, wRightBottom.X - wLeftTop.X, wRightBottom.Y - wLeftTop.Y);
            }

            /// <summary>
            /// 親ウィンドウの子ウィンドウの上下関係を変更します。
            /// </summary>
            /// <param name="aIsRollback"></param>
            private void ChangeColleagueFormSettings(bool aIsRollback)
            {
                this.DesignerParent.m_Colleagues.ForEach(ele =>
                {
                    var wForm = ele as System.Windows.Forms.Form;
                    if (wForm != null)
                    {
                        wForm.TopMost = aIsRollback ? true : false;
                    }
                });
            }

            #endregion

        }

        /// <summary>
        /// ダイアログウィンドウを表示するためのフォームクラス
        /// </summary>
        private class DesignDialogAdapterForm : AbstructDesignOpenDialogForm
        {
            #region 生成と破棄

            /// <summary>
            /// ダイアログウィンドウを表示するためのフォームクラスの新しいインスタンスを初期化します。
            /// </summary>
            /// <param name="aParent"></param>
            public DesignDialogAdapterForm(frmDesignParent aParent) : base(aParent) { }

            #endregion

            #region メンバプロパティ定義

            /// <summary>
            /// 表示するダイアログウィンドウへの参照の取得及び設定を行います。
            /// </summary>
            public Form TargetForm { get; set; } = null;

            /// <summary>
            /// 表示するダイアログウィンドウの表示結果の取得を行います。
            /// 値の取得のみ可能です。
            /// </summary>
            public DialogResult TargetFormDialogResult { get; private set; } = DialogResult.None;

            #endregion

            #region メンバ関数定義(override...)

            /// <summary>
            /// Form.Shown イベントを発生させます。
            /// </summary>
            /// <param name="e"></param>
            protected override void OnShown(EventArgs e)
            {
                base.OnShown(e);

                // ダイアログを表示する
                this.TargetFormDialogResult = this.TargetForm.ShowDialog(this);
                // 閉じる
                this.Close();
            }

            #endregion
        }

        /// <summary>
        /// メッセージボックスを表示するためのフォームクラス
        /// </summary>
        private class DesignMessageBoxAdapterForm : AbstructDesignOpenDialogForm
        {
            #region 生成と破棄

            /// <summary>
            /// メッセージボックスを表示するためのフォームクラスの新しいインスタンスを初期化します。
            /// </summary>
            /// <param name="aParent"></param>
            public DesignMessageBoxAdapterForm(frmDesignParent aParent) : base(aParent) { }

            #endregion

            #region メンバプロパティ定義

            /// <summary>
            /// メッセージボックスの表示に必要なデータの設定を行います。
            /// 値の設定のみ可能です。
            /// </summary>
            public RldDesignNotifyInfoRequestShowMessageEventArgs EventData { private get; set; } = null;

            #endregion

            #region メンバ関数定義(override...)

            /// <summary>
            /// Form.OnShown イベントを発生させます。
            /// </summary>
            /// <param name="e"></param>
            protected override void OnShown(EventArgs e)
            {
                base.OnShown(e);

                // メッセージボックスを表示する
                this.ShowMessageBox();
                // 閉じる
                this.Close();
            }

            #endregion

            #region メンバ関数定義

            /// <summary>
            /// メッセージボックスを表示します。
            /// </summary>
            private void ShowMessageBox()
            {
                string wCaption = this.EventData.Caption;

                if (string.IsNullOrEmpty(this.EventData.Caption))
                {
                    if (this.EventData.Icon == MessageBoxIcon.Error || this.EventData.Icon == MessageBoxIcon.Stop)
                    {
                        wCaption = "致命的なエラーが発生しました";
                    }
                }

                this.DialogResult = RldMsgBox.Show(
                     this, this.EventData.Text, wCaption, this.EventData.Buttons, this.EventData.Icon, this.EventData.DefaultButton);
            }

            #endregion
        }

        #endregion

        #region メンバ変数定義

        /// <summary>
        /// イベント通知先格納用リスト
        /// </summary>
        // mod #8559 動作に関する指摘２ 邾 start
        public List<IRldDesignColleague> m_Colleagues = null;
        // mod #8559 動作に関する指摘２ 邾 end
        // mod  2021-09-02 #6370:判定条件 鄭 start
        public bool ErrorMessage = false;
        // mod  2021-09-02 #6370:判定条件る 鄭 end
        // add #5964 プロンプトボックスの内容を変更する 王永吉 strat
        public bool DoFlag = false;
        // add #5964 プロンプトボックスの内容を変更する 王永吉 end
        #endregion
        //add #8559 動作に関する指摘２ 邾 start
        string sReportName = "";
        //add #8559 動作に関する指摘２ 邾 end
        // add #9398 「オンラインで保存」の通常保存時は「新規登録」の時のみ「帳票保存設定」が出るようにすること donghao start
        public static bool blCancel { get; set; } = false;

        public static bool blWes { get; set; } = false;
        // add #9398 「オンラインで保存」の通常保存時は「新規登録」の時のみ「帳票保存設定」が出るようにすること donghao end
        #region メンバイベント定義

        /// <summary>
        /// 通知用イベント
        /// </summary>
        private event EventHandler<RldDesignNotifyInfoEventArgs> NotifyInfo;

        #endregion

        #region 生成と破棄

        /// <summary>
        /// コンストラクタ
        /// </summary>
        public frmDesignParent()
        {
            InitializeComponent();

            // add #11574 編集中のタスクバーのアイコンがデフォルトになっている 高 start
            this.Icon = Properties.Resources.LayoutDesigner;
            // add #11574 編集中のタスクバーのアイコンがデフォルトになっている 高 end

            // 初期状態は見えない状態
            this.Opacity = 0d;
            //this.ShowInTaskbar = false;

            // Colleague リストを生成
            this.m_Colleagues = new System.Collections.Generic.List<IRldDesignColleague>();
        }

        #endregion

        #region メンバプロパティ定義

        private bool MustDeleteWorkFile { get; set; } = false;
        public Rectangle InitialWindowLayoutWorkingArea { get; set; } = Rectangle.Empty;

        #endregion

        #region メンバ関数定義(override)

        /// <summary>
        /// Form.FormClosing イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnFormClosing(FormClosingEventArgs e)
        {
            this.CloseExcel();

            // 終了時に削除する必要がある場合は削除する
            if (this.MustDeleteWorkFile)
            {
                RldUtility.DeleteFileIfExists(RldLib.WorkXlsxFilePath);
            }

            RldUtility.DeleteFileIfExists(RldLib.PreviewHtmlFilePath);
            RldUtility.DeleteDirectoryIfExists(RldLib.PreviewHtmlRelationDirPath);

            base.OnFormClosing(e);
        }

        /// <summary>
        /// Form.Load イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnLoad(System.EventArgs e)
        {
            base.OnLoad(e);

            // add 2020-08-06 FNSI-仕様追加 ロードページの追加 李 start
            // 起動直後のローディングも 4 画面を表示するモニタへ揃える。
            LoadingHelper.ShowLoadingDialog(this.GetVisibleDesignWindowOwner());
            // add 2020-08-06 FNSI-仕様追加 ロードページの追加 李 end

            if (base.DesignMode)
            {
                return;
            }

            // 施設コードがなければ、サインイン施設コードを扱う
            if (SignInLib.SignIn.SignInInfo.IsOnline)
            {
                if (String.IsNullOrEmpty(LayoutDesignerUtility.CurrentFacilityCd))
                {
                    LayoutDesignerUtility.CurrentFacilityCd = SignInLib.SignIn.SignInInfo.FacilityCode;
                    // add #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 start
                    RldLib.FilterDataSet.ClearFilterData();
                    // add #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 end
                }
            }

            // Excel ブックを非表示で開いて各種データを読み込む
            if (!this.LoadExcelFileData())
            {
                // 失敗時はメインメニューに戻る
                this.ActionOfRequestCloseApp(this, new RldDesignNotifyInfoRequestCloseEventArgs(CloseReason.UserClosing, false, DialogResult.OK));
                // add 2020-8-10 FNSI-仕様追加 ロードページの追加 李 start
                LoadingHelper.CloseLoadingDialog();
                // add 2020-8-10 FNSI-仕様追加 ロードページの追加 李 end
                return;
            }

            // オンラインの場合は現在編集中の帳票を特定する
            // mod #11116 単集計帳票の「レイアウト」タブの内容が保存されないことがある 高 start
            //bool wRes = Task<Boolean>.Run(async () => await this.GetEditingReportInfo()).Result;
            bool wRes = Task<Boolean>.Run(async () => await this.GetEditingReportInfo(true)).Result;
            // mod #11116 単集計帳票の「レイアウト」タブの内容が保存されないことがある 高 end

            // mod #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 start
            if(wRes ==  true && RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_DEVICE && RldLib.inspectionLayoutData.ReportType == "1")
            {
                // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
                //RldLib.inspectionLayoutData.UseCD = "0";
                //RldLib.inspectionLayoutData.RecordCD = "0";
                //RldLib.inspectionLayoutData.LayoutCD = "0";
                RldLib.inspectionLayoutData.MachineTypeCD = "";

                //foreach (var wData in RldLib.CurrentLayoutData.DesignParamList)
                //{
                //    if (wData.FilterType == RldConst.FilterType.Group.INSPECTION)
                //    {
                //        wData.FilterData = string.Empty;
                //        wData.FilterState = RldConst.ParamData.VAL_FILTER_STATE_NO;
                //    }
                //}
				// mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
            }
            // mod #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 end

            // add #12026 帳票移植時にフィルタ設定が無効化する（初期対応） 高 start
            if (RldLib.CurrentLayoutData.DesignParamList.Count > 0 && RldLib.IsWorkXlsx == true)
            {
                // mod #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 start
                //createExamItemFilterData();
                createItemFilterData();
                // mod #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 end
            }
            // add #12026 帳票移植時にフィルタ設定が無効化する（初期対応） 高 end

            // del 2021-02-19 No.517:FNW帳票レイアウトコンバート 趙 start
            //// データ項目リストファイルから選択された帳票種別分のアイテムを読み込む
            //if (!this.LoadDataList())
            //{
            //    // 失敗時はメインメニューに戻る
            //    this.ActionOfRequestCloseApp(this, new RldDesignNotifyInfoRequestCloseEventArgs(CloseReason.UserClosing, false, DialogResult.OK));
            //    return;
            //}
            // del 2021-02-19 No.517:FNW帳票レイアウトコンバート 趙 end

            // パラメータ編集データをデータ項目リストの内容に更新
            if (!RldLib.CurrentLayoutData.UpdateDesignParam(out List<DesignParamData> aChangedList))
            {
                // エラーメッセージを表示
                this.ActionOfRequestShowMsgBox(this, new RldDesignNotifyInfoRequestShowMessageEventArgs()
                {
                    Text = "パラメータ編集データの変換に失敗しました。",
                    Caption = "致命的なエラーが発生しました",
                    Icon = MessageBoxIcon.Error,
                    Buttons = MessageBoxButtons.OK
                });
                // 失敗時はメインメニューに戻る
                this.ActionOfRequestCloseApp(this, new RldDesignNotifyInfoRequestCloseEventArgs(CloseReason.UserClosing, false, DialogResult.OK));
                return;
            }
            // 変更されたパラメータ編集データがある場合はメッセージを表示
            if (aChangedList.Count > 0)
            {
                // エラーメッセージを表示
                this.ActionOfRequestShowMsgBox(this, new RldDesignNotifyInfoRequestShowMessageEventArgs()
                {
                    Text = $"データ項目リストが更新されたため{aChangedList.Count}件のパラメータを更新しました。",
                    Caption = "確認してください",
                    Icon = MessageBoxIcon.Information,
                    Buttons = MessageBoxButtons.OK
                });
            }

            // 表示位置を調整して各画面を表示(Excel も含む)
            this.InitWindowLayout();

            // add 2020-8-06 FNSI-仕様追加 ロードページの追加 李 start
            LoadingHelper.CloseLoadingDialog();
            // add 2020-8-06 FNSI-仕様追加 ロードページの追加 李 end

            if (!wRes)
            {
                // エラーメッセージを表示
                this.ActionOfRequestShowMsgBox(this, new RldDesignNotifyInfoRequestShowMessageEventArgs()
                {
                    Text = "この施設では新規帳票として登録されます。",
                    Caption = "他施設にアップロードした帳票を編集しています",
                    Icon = MessageBoxIcon.Exclamation,
                    Buttons = MessageBoxButtons.OK
                });
                // 失敗時はメインメニューに戻る
                //this.ActionOfRequestCloseApp(this, new RldDesignNotifyInfoRequestCloseEventArgs(CloseReason.UserClosing, false, DialogResult.OK));
                //return;
            }
            // add #10714 起動直後Excel画面がクリックできない 高 start
            ((frmDesignChildSelectedItem)m_Colleagues[0]).Focus();
            // add #10714 起動直後Excel画面がクリックできない 高 end
        }

        #endregion

        #region メンバ関数定義

        /// <summary>
        /// 全てのウィンドウの位置を初期化します。
        /// </summary>
        private void InitWindowLayout()
        {
            // 表示先を取得
            var wWorkingArea = System.Windows.Forms.Screen.FromPoint(Cursor.Position).WorkingArea;

            // 親フォームが指定されている場合は取得し直す
            if (this.Owner != null)
            {
                wWorkingArea = System.Windows.Forms.Screen.FromControl(this.Owner).WorkingArea;
            }

            wWorkingArea = this.GetInitialWindowLayoutWorkingArea();

            // 選択アイテムウィンドウを生成してリストへ追加
            var wSelectedItemForm = new frmDesignChildSelectedItem();
            AddHandlerAndAddList(wSelectedItemForm);
            wSelectedItemForm.DesignChildActivated += this.Form_DesignChildActivated;

            // データ項目リストウィンドウを生成してリストへ追加
            var wDataListForm = new frmDesignChildDataList();
            wDataListForm.Owner = this;
            wDataListForm.SetDesktopBounds(
                wWorkingArea.X,
                wSelectedItemForm.DesktopBounds.Y + wSelectedItemForm.DesktopBounds.Height,
                wDataListForm.Width,
                wWorkingArea.Height - (wSelectedItemForm.DesktopBounds.Y + wSelectedItemForm.DesktopBounds.Height));
            // add #11501 レイアウトデザイナのユーザビリティ改善 高 start
            if (string.IsNullOrEmpty(RldLib.CurrentLayoutData.DesignSettingData.ReportCode))
            {
                wDataListForm.editFileName = "編集中：(新規)" + RldLib.CurrentLayoutData.DesignSettingData.ReportClassName;
            }
            else
            {
                wDataListForm.editFileName = "編集中：" + RldLib.CurrentReport.ReportName;
            }
            // add #11501 レイアウトデザイナのユーザビリティ改善 高 end
            AddHandlerAndAddList(wDataListForm);
            wDataListForm.DesignChildActivated += this.Form_DesignChildActivated;

            // デザイナーウィンドウを生成してリストへ追加
            var wLayoutForm = new frmDesignChildLayout();
            wLayoutForm.SetDesktopBounds(
                wWorkingArea.X + wWorkingArea.Width - wLayoutForm.Width,
                wSelectedItemForm.DesktopBounds.Y + wSelectedItemForm.DesktopBounds.Height,
                wLayoutForm.Width,
                wWorkingArea.Height - (wSelectedItemForm.DesktopBounds.Y + wSelectedItemForm.DesktopBounds.Height));
            AddHandlerAndAddList(wLayoutForm);
            wLayoutForm.DesignChildActivated += this.Form_DesignChildActivated;

            // ウィンドウを通常サイズに変更
            if (RldLib.XlHelper.XlApp.Application.WindowState != Microsoft.Office.Interop.Excel.XlWindowState.xlNormal)
            {
                RldLib.XlHelper.XlApp.Application.WindowState = Microsoft.Office.Interop.Excel.XlWindowState.xlNormal;
            }

            double wRate = System.Math.Round(1.0 * 96 / 72, 2);
            double wValue = 0;

            // Excel のウィンドウサイズを変更して見えるようにする

            // 選択アイテムウインドウの高さをExcelのTopに設定
            wValue = wSelectedItemForm.DesktopBounds.Height / wRate;
            if (RldLib.XlHelper.XlApp.Application.Top != wValue)
            {
                RldLib.XlHelper.XlApp.Application.Top = wValue;
            }

            // データ項目リストの右端をExcelのLeftに設定
            wValue = wDataListForm.DesktopBounds.Right / wRate;
            if (RldLib.XlHelper.XlApp.Application.Left != wValue)
            {
                RldLib.XlHelper.XlApp.Application.Left = wValue;
            }

            // 「表示エリア幅 - データ項目リスト画面の幅 - レイアウト画面の幅」をExcelの幅にする
            wValue = (wWorkingArea.Width - wDataListForm.DesktopBounds.Width - wLayoutForm.DesktopBounds.Width) / wRate;
            if (RldLib.XlHelper.XlApp.Application.Width != wValue)
            {
                RldLib.XlHelper.XlApp.Application.Width = wValue;
            }

            // 「表示エリア高さ - 選択アイテムウインドウ高さ」をExcelの高さにする
            wValue = (wWorkingArea.Height - wSelectedItemForm.DesktopBounds.Height) / wRate;
            if (RldLib.XlHelper.XlApp.Application.Height != wValue)
            {
                RldLib.XlHelper.XlApp.Application.Height = wValue;
            }

            RldLib.XlHelper.XlApp.Application.Visible = true;

            // このフォームをオーナーにして各画面を表示する。オーナーにすることで最小化, 元の大きさに戻すが連動する
            wDataListForm.Show(this);
            wLayoutForm.Show(this);
            wSelectedItemForm.Show(this);
            // 初回表示時も編集開始元のモニタ基準で 4 画面を揃える。
            this.ApplyWindowLayout(this.GetInitialWindowLayoutWorkingArea(), wSelectedItemForm, wDataListForm, wLayoutForm);
            this.BringDesignChildFormsToFront(wSelectedItemForm, wDataListForm, wLayoutForm);

            /// <summary>
            /// (ローカル関数)
            /// 指定された Colleague のイベントを受信するように設定してリストへ追加します。
            /// <para name="aColleague"></para>
            /// </summary>
            void AddHandlerAndAddList(IRldDesignSendOnlyColleague aColleague)
            {
                aColleague.NotifyInfo += new EventHandler<RldDesignNotifyInfoEventArgs>(this.ColleagueMessageHandler);
                this.m_Colleagues.Add(aColleague);
            }
        }

        /// <summary>
        /// 4 画面の初期配置に使用する作業領域を取得します。
        /// </summary>
        /// <returns>
        /// 起動元画面の作業領域が設定されている場合はその値を返し、
        /// 未設定の場合は現在のカーソル位置の作業領域を返します。
        /// </returns>
        private Rectangle GetInitialWindowLayoutWorkingArea()
        {
            if (!this.InitialWindowLayoutWorkingArea.IsEmpty)
            {
                return this.InitialWindowLayoutWorkingArea;
            }

            return Screen.FromPoint(Cursor.Position).WorkingArea;
        }

        /// <summary>
        /// 表示中の 4 画面を、指定したモニタの作業領域へ再配置します。
        /// </summary>
        /// <param name="aWorkingArea">再配置先の作業領域。</param>
        internal void ResetWindowLayout(Rectangle aWorkingArea)
        {
            frmDesignChildSelectedItem wSelectedItemForm;
            frmDesignChildDataList wDataListForm;
            frmDesignChildLayout wLayoutForm;

            if (!this.TryGetDesignChildForms(out wSelectedItemForm, out wDataListForm, out wLayoutForm))
            {
                return;
            }

            // BUG #12556: 「画面配置初期化」は実行した画面が存在するモニタ上で並べ直す。
            this.ApplyWindowLayout(aWorkingArea, wSelectedItemForm, wDataListForm, wLayoutForm);
            this.BringDesignChildFormsToFront(wSelectedItemForm, wDataListForm, wLayoutForm);
            wDataListForm.Activate();
        }

        /// <summary>
        /// 4 画面配置の対象となる子画面を取得します。
        /// </summary>
        /// <param name="aSelectedItemForm">選択アイテム画面。</param>
        /// <param name="aDataListForm">データ項目リスト画面。</param>
        /// <param name="aLayoutForm">デザイナー画面。</param>
        /// <returns>必要な 3 画面を取得できた場合は true を返します。</returns>
        private bool TryGetDesignChildForms(
            out frmDesignChildSelectedItem aSelectedItemForm,
            out frmDesignChildDataList aDataListForm,
            out frmDesignChildLayout aLayoutForm)
        {
            aSelectedItemForm = this.m_Colleagues.OfType<frmDesignChildSelectedItem>().FirstOrDefault();
            aDataListForm = this.m_Colleagues.OfType<frmDesignChildDataList>().FirstOrDefault();
            aLayoutForm = this.m_Colleagues.OfType<frmDesignChildLayout>().FirstOrDefault();

            return aSelectedItemForm != null && aDataListForm != null && aLayoutForm != null;
        }

        /// <summary>
        /// 指定した作業領域を基準に、3 画面と Excel の配置を初期レイアウトへ揃えます。
        /// </summary>
        /// <param name="aWorkingArea">配置基準とするモニタの作業領域。</param>
        /// <param name="aSelectedItemForm">選択アイテム画面。</param>
        /// <param name="aDataListForm">データ項目リスト画面。</param>
        /// <param name="aLayoutForm">デザイナー画面。</param>
        private void ApplyWindowLayout(
            Rectangle aWorkingArea,
            frmDesignChildSelectedItem aSelectedItemForm,
            frmDesignChildDataList aDataListForm,
            frmDesignChildLayout aLayoutForm)
        {
            aSelectedItemForm.WindowState = FormWindowState.Normal;
            aDataListForm.WindowState = FormWindowState.Normal;
            aLayoutForm.WindowState = FormWindowState.Normal;

            aSelectedItemForm.SetDesktopBounds(
                aWorkingArea.X,
                aWorkingArea.Y,
                aWorkingArea.Width,
                aSelectedItemForm.Height);

            var wChildTop = aSelectedItemForm.DesktopBounds.Bottom;
            var wChildHeight = Math.Max(1, aWorkingArea.Bottom - wChildTop);

            aDataListForm.SetDesktopBounds(
                aWorkingArea.X,
                wChildTop,
                aDataListForm.Width,
                wChildHeight);

            aLayoutForm.SetDesktopBounds(
                aWorkingArea.Right - aLayoutForm.Width,
                wChildTop,
                aLayoutForm.Width,
                wChildHeight);

            if (RldLib.XlHelper.XlApp.Application.WindowState != Microsoft.Office.Interop.Excel.XlWindowState.xlNormal)
            {
                RldLib.XlHelper.XlApp.Application.WindowState = Microsoft.Office.Interop.Excel.XlWindowState.xlNormal;
            }

            var wExcelApp = RldLib.XlHelper.XlApp.Application;
            double wRate = System.Math.Round(1.0 * 96 / 72, 2);
            double wValue = aSelectedItemForm.DesktopBounds.Bottom / wRate;

            if (wExcelApp.Top != wValue)
            {
                wExcelApp.Top = wValue;
            }

            wValue = aDataListForm.DesktopBounds.Right / wRate;
            if (wExcelApp.Left != wValue)
            {
                wExcelApp.Left = wValue;
            }

            wValue = Math.Max(1d, aWorkingArea.Width - aDataListForm.DesktopBounds.Width - aLayoutForm.DesktopBounds.Width) / wRate;
            if (wExcelApp.Width != wValue)
            {
                wExcelApp.Width = wValue;
            }

            wValue = Math.Max(1d, aWorkingArea.Height - aSelectedItemForm.DesktopBounds.Height) / wRate;
            if (wExcelApp.Height != wValue)
            {
                wExcelApp.Height = wValue;
            }

            wExcelApp.Visible = true;
        }

        /// <summary>
        /// 4 画面再配置後に、子画面を Excel より手前へ並び直します。
        /// </summary>
        /// <param name="aSelectedItemForm">選択アイテム画面。</param>
        /// <param name="aDataListForm">データ項目リスト画面。</param>
        /// <param name="aLayoutForm">デザイナー画面。</param>
        private void BringDesignChildFormsToFront(
            frmDesignChildSelectedItem aSelectedItemForm,
            frmDesignChildDataList aDataListForm,
            frmDesignChildLayout aLayoutForm)
        {
            aLayoutForm.BringToFront();
            aDataListForm.BringToFront();
            aSelectedItemForm.BringToFront();
        }

        /// <summary>
        /// 親画面側からダイアログを表示する際の owner を取得します。
        /// </summary>
        /// <returns>
        /// 現在表示中の 4 画面から、フォーカス中の画面を優先して返します。
        /// owner を特定できない場合は親画面自身を返します。
        /// </returns>
        private IWin32Window GetVisibleDesignWindowOwner()
        {
            // BUG #12556: 親側から出す確認ダイアログも、表示中の4画面を owner にして別モニタへ飛ばさない。
            var wForms = this.m_Colleagues
                .OfType<Form>()
                .Where(wForm => wForm != null && !wForm.IsDisposed && wForm.Visible)
                .ToList();

            var wOwner = wForms.FirstOrDefault(wForm => wForm.ContainsFocus || wForm.Focused);
            if (wOwner != null)
            {
                return wOwner;
            }

            wOwner = wForms.FirstOrDefault(wForm => Form.ActiveForm == wForm);
            if (wOwner != null)
            {
                return wOwner;
            }

            return wForms.FirstOrDefault() ?? this;
        }

        /// <summary>
        /// 通知元に応じて、ダイアログ表示に使用する owner を取得します。
        /// </summary>
        /// <param name="sender">ダイアログ表示を要求した送信元。</param>
        /// <returns>
        /// 送信元の画面を優先して返し、判定できない場合は現在表示中の 4 画面から owner を返します。
        /// </returns>
        private IWin32Window GetRequestDialogOwner(object sender)
        {
            // IsAllWindowLock=false のダイアログは、通知元の画面に紐付けて現在の作業モニタへ表示する。
            if (sender is Form wSenderForm && !wSenderForm.IsDisposed && wSenderForm.Visible)
            {
                return wSenderForm;
            }

            if (sender is Control wSenderControl)
            {
                var wSenderOwner = wSenderControl.FindForm();
                if (wSenderOwner != null && !wSenderOwner.IsDisposed && wSenderOwner.Visible)
                {
                    return wSenderOwner;
                }
            }

            return this.GetVisibleDesignWindowOwner();
        }

        [System.Runtime.InteropServices.DllImport("user32.dll", SetLastError = true)]
        [return: System.Runtime.InteropServices.MarshalAs(System.Runtime.InteropServices.UnmanagedType.Bool)]
        private static extern bool SetWindowPos(IntPtr hWnd,
            int hWndInsertAfter, int x, int y, int cx, int cy, uint uFlags);

        /// <summary>
        /// 子ウインドウがアクティブになった時に呼び出されるイベントハンドラ
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Form_DesignChildActivated(object sender, EventArgs e)
        {

            const int HWND_TOP = 0;
            const uint SWP_NOSIZE = 0x0001;
            const uint SWP_NOMOVE = 0x0002;
            const uint SWP_NOACTIVATE = 0x0010;
            const uint SWP_SHOWWINDOW = 0x0040;
            const uint SWP_NOSENDCHANGING = 0x0400;

            if (!RldLib.IsStartDesignWindowClosing)
            {
                // 画面を閉じる時には処理しない

                var senderForm = (Form)sender;

                // 他の二つのフォームを前面に表示する
                // itemはForm型 かつ イベント生成元のフォームではない
                foreach (Form form in from item in this.m_Colleagues
                                      let form = item as Form
                                      where (form != null) && (item != sender)
                                      select form)
                {
                    // フォームを最上位フォームとして表示する
                    // ウィンドウを Z オーダーの先頭に置きます
                    // 対象フォームをアクティブにするとメニューがプルダウンできないためAPIでアクティブにせずにZオーダーを前面にする
                    SetWindowPos(form.Handle, HWND_TOP, 0, 0, 0, 0, SWP_NOACTIVATE | SWP_NOMOVE | SWP_NOSENDCHANGING | SWP_NOSIZE | SWP_SHOWWINDOW);
                    System.Diagnostics.Debug.Print(DateTime.Now.ToString() + " 前面に表示するフォーム:" + form.Name + " 要求元フォーム=" + senderForm.Name);
                }

                // 最後にクリックしたフォームを選択する. ここでイベントSenderを選択しないとクリックしたフォームが背面表示されるようになる.
                senderForm.TopMost = true;
                senderForm.TopMost = false;

            }

        }

        /// <summary>
        /// データ項目リストを読み込みます。
        /// </summary>
        /// <returns></returns>
        private bool LoadDataList()
        {
            bool wRet = false;

            try
            {
                // add #9651 帳票表示項目の並び順を変更する 高 start
                OrderLoadDataList();
                // add #9651 帳票表示項目の並び順を変更する 高 end

                // リストをクリア
                RldLib.CurrentLayoutData.DataItemList.Clear();

                // データ項目リストファイル読込
                var wXmlDoc = new TdcLib.TdcXml();
                if (!wXmlDoc.Load(RldUtility.DataListFilePath))
                {
                    throw new System.ApplicationException(@"データ項目リストファイルの読み込みに失敗しました。", wXmlDoc.Error);
                }

                // 指定された帳票種別の項目一覧を取得
                // @"reportTable/report[@type='Dialysis']/dataTable/data"
                string wXPathData = string.Format(@"{0}/{1}[@{2}='{3}']/{4}/{5}",
                    RldConst.ItemList.TAG_REPORTTABLE,
                    RldConst.ItemList.TAG_REPORT,
                    RldConst.ItemList.ATT_REPORT_TYPE,
                    RldLib.CurrentLayoutData.DesignSettingData.ReportClass,
                    RldConst.ItemList.TAG_DATATABLE,
                    RldConst.ItemList.TAG_DATA);

                foreach (System.Xml.XmlNode wXmlDataNode in wXmlDoc.Document.SelectNodes(wXPathData))
                {

                    // 自施設で使用できない場合はスキップ
                    if (!LFunc_IsUsableData())
                    {
                        continue;
                    }

                    var wData = new DesignItemListData();

                    // 属性を列挙してプロパティをセット
                    foreach (System.Xml.XmlAttribute wAttribute in wXmlDataNode.Attributes)
                    {
                        if (RldLib.IsEqualXmlAttName(wAttribute.Name, RldConst.ItemList.ATT_DATA_DATACODE))
                        {
                            wData.DataCode = wAttribute.Value;
                        }
                        else if (RldLib.IsEqualXmlAttName(wAttribute.Name, RldConst.ItemList.ATT_DATA_DATANAME))
                        {
                            wData.DataName = wAttribute.Value;
                        }
                        else if (RldLib.IsEqualXmlAttName(wAttribute.Name, RldConst.ItemList.ATT_DATA_DATACATEGORY))
                        {
                            wData.DataCategory = wAttribute.Value;
                        }
                        else if (RldLib.IsEqualXmlAttName(wAttribute.Name, RldConst.ItemList.ATT_DATA_DATACLASS))
                        {
                            wData.DataClass = wAttribute.Value;
                        }
                        else if (RldLib.IsEqualXmlAttName(wAttribute.Name, RldConst.ItemList.ATT_DATA_SQLCODE))
                        {
                            wData.SqlCode = wAttribute.Value;
                        }
                        else if (RldLib.IsEqualXmlAttName(wAttribute.Name, RldConst.ItemList.ATT_DATA_DATATYPE))
                        {
                            wData.DataType = wAttribute.Value;
                        }
                        else if (RldLib.IsEqualXmlAttName(wAttribute.Name, RldConst.ItemList.ATT_DATA_CANREPEAT))
                        {
                            if (int.TryParse(wAttribute.Value, out int wResult) && wResult != 0)
                            {
                                wData.CanRepeat = true;
                            }
                        }
                        else if (RldLib.IsEqualXmlAttName(wAttribute.Name, RldConst.ItemList.ATT_DATA_FILTERTYPE))
                        {
                            wData.FilterType = wAttribute.Value;
                        }
                        else if (RldLib.IsEqualXmlAttName(wAttribute.Name, RldConst.ItemList.ATT_DATA_DISPFORMAT))
                        {
                            wData.DisplayFormat = wAttribute.Value;
                        }
                        else if (RldLib.IsEqualXmlAttName(wAttribute.Name, RldConst.ItemList.ATT_DATA_CANCALC))
                        {
                            if (int.TryParse(wAttribute.Value, out int wResult) && wResult != 0)
                            {
                                wData.CanCalc = true;
                            }
                        }
                        else if (RldLib.IsEqualXmlAttName(wAttribute.Name, RldConst.ItemList.ATT_DATA_PREVIEW))
                        {
                            wData.PreviewData = wAttribute.Value;
                        }

                        // add 2020-09-27 FNSI-仕様追加 DataListデータリストにソート機能を追加 李 start
                        else if (RldLib.IsEqualXmlAttName(wAttribute.Name, RldConst.ItemList.DATA_SORT))
                        {
                            wData.DataSort = wAttribute.Value;
                        }
                        // add 2020-09-27 FNSI-仕様追加 DataListデータリストにソート機能を追加 李 end
                        // add 2021-08-30 6009画像 李 start
                        else if (RldLib.IsEqualXmlAttName(wAttribute.Name, "isImage"))
                        {
                            wData.IsImage = wAttribute.Value;
                        }
                        // add 2021-08-30 6009画像 李 end
                    }

                    // 変換リスト
                    // @"convTable"
                    string wXPathConvTable = string.Format(@"{0}", RldConst.ItemList.TAG_CONVTABLE);
                    var wXmlConvTableNodes = wXmlDataNode.SelectNodes(wXPathConvTable);
                    if (wXmlConvTableNodes.Count > 1)
                    {
                        throw new System.ApplicationException(string.Format("変換リストが複数登録されています。'{0}'", wXmlDataNode.InnerText));
                    }

                    foreach (System.Xml.XmlNode wXmlConvTableNode in wXmlDataNode.SelectNodes(wXPathConvTable))
                    {

                        if (!DesignConvertList.TryParse(wXmlConvTableNode, out DesignConvertList wResult))
                        {
                            throw new System.ApplicationException("変換リストの取得に失敗しました。");
                        }

                        wData.ConvertList = wResult;
                    }

                    // リストへ追加
                    RldLib.CurrentLayoutData.DataItemList.Add(wData);

                    /// <summary>
                    /// (ローカル関数) 自施設が現在のデータ項目を使用できるかどうかを取得します。
                    /// </summary>
                    /// <returns></returns>
                    bool LFunc_IsUsableData()
                    {
                        // 使用する施設指定か使用しない施設指定かを取得
                        string wFacilityFilterTypeAttrValue = RldConst.ItemList.VAL_DATA_FACILITYFILTERTYPE_DEFAULT;
                        var wXmlFacilityFilterTypeAttr = wXmlDataNode.Attributes[RldConst.ItemList.ATT_DATA_FACILITYFILTERTYPE];
                        if (wXmlFacilityFilterTypeAttr != null)
                        {
                            wFacilityFilterTypeAttrValue = wXmlFacilityFilterTypeAttr.Value;
                        }

                        // 自施設が含まれているか取得
                        // @"facilityTable/facility[@code='xxxxx']"
                        string wXPathFacilityCode = string.Format(@"{0}/{1}[@{2}='{3}']",
                            RldConst.ItemList.TAG_FACILITYTABLE,
                            RldConst.ItemList.TAG_FACILITY,
                            RldConst.ItemList.ATT_FACILITY_CODE,
                            NKKWebAccess.FacilityCd);
                        bool wIsFound = (wXmlDataNode.SelectSingleNode(wXPathFacilityCode) != null);

                        if (RldLib.IsEqualXmlAttName(wFacilityFilterTypeAttrValue, RldConst.ItemList.VAL_DATA_FACILITYFILTERTYPE_USE) && !wIsFound)
                        {
                            // 使用する施設指定で自施設が見つからなかった場合は使用不可
                            return false;
                        }
                        else if (RldLib.IsEqualXmlAttName(wFacilityFilterTypeAttrValue, RldConst.ItemList.VAL_DATA_FACILITYFILTERTYPE_DISUSE) && wIsFound)
                        {
                            // 使用しない施設指定で自施設が見つかった場合は使用不可
                            return false;
                        }

                        return true;
                    }
                }

                wRet = true;
            }
            catch (Exception ex)
            {
                // TODO: 例外時処理はこの方法で統一する
                // 例外情報を生成
                var wEx = new System.ApplicationException("データ項目一覧の読込に失敗しました。", ex);
                // 例外情報を記録(画面にメッセージボックスを表示)
                this.ActionOfRequestRecordException(this, new RldDesignNotifyInfoRequestRecordExceptionEventArgs(wEx, true));
            }

            return wRet;
        }


        /// <summary>
        /// Excel ブック内のデータを読み込みます。
        /// </summary>
        /// <returns></returns>
        private bool LoadExcelFileData()
        {
            bool wRet = false;

            // 帳票新旧判断用フラグ
            bool wFlag = false;

            try
            {
                // Excel ファイルを開く
                if (this.OpenExcel())
                {

                    // 設定データ読み込み
                    RldLib.CurrentLayoutData.DesignSettingData = RldLib.XlHelper.GetSettingData();

                    // 帳票種別データを取得
                    var wData = RldLib.ReportClassList.Single(ele => ele.ReportClass == RldLib.CurrentLayoutData.DesignSettingData.ReportClass);
                    RldLib.CurrentLayoutData.DesignSettingData.ReportClassName = wData.ReportClassName;
                    RldLib.CurrentLayoutData.DesignSettingData.IsSupportTempleteRepeat = wData.IsSupportTempleteRepeat;

                    // mod 2023-03-28 #8455 【デグレ】グループ情報がクリアされてしまう 鵬 start
                    RldLib.CurrentLayoutData.DesignParamList.Clear();
                    RldLib.CurrentLayoutData.DesignGroupList.Clear();
                    // mod 2023-03-28 #8455 鵬 end

                    // add 2021-02-19 No.517:FNW帳票レイアウトコンバート 趙 start
                    // データ項目リストファイルから選択された帳票種別分のアイテムを読み込む
                    if (!this.LoadDataList())
                    {
                        // 失敗時はメインメニューに戻る
                        this.ActionOfRequestCloseApp(this, new RldDesignNotifyInfoRequestCloseEventArgs(CloseReason.UserClosing, false, DialogResult.OK));
                        wRet = false;
                    }

                    if (RldLib.CurrentLayoutData.DataItemConvertList != null && RldLib.CurrentLayoutData.DataItemConvertList.Count > 0)
                    {
                        // FNW帳票レイアウトがコンバートします
                        if (!RldLib.XlHelper.SetTotalLayoutData())
                        {
                            return false;
                        }

                        // パラメータリスト保存
                        if (!RldLib.XlHelper.SetNewSheetParamDataList(RldLib.CurrentLayoutData.DesignParamList))
                        {
                            return false;
                        }

                        // グループリスト保存
                        if (!RldLib.XlHelper.SetNewSheetGroupDataList(RldLib.CurrentLayoutData.DesignGroupList))
                        {
                            return false;
                        }
                        wFlag = true;
                        RldLib.CurrentLayoutData.DataItemConvertList.Clear();
                    }
                    // add 2021-02-19 No.517:FNW帳票レイアウトコンバート 趙 end
                    // add #8335 FNW帳票取込みの動作に問題あり 夏 start
                    else
                    {
                        // add #8335 FNW帳票取込みの動作に問題あり 夏 end
                        // グループシート読み込み
                        // del #8314 グループタブの表示不正 王占宇 start
                        // RldLib.CurrentLayoutData.DesignGroupList.Clear();
                        // RldLib.XlHelper.GetSheetGroupDataList().ToList().ForEach(ele => RldLib.CurrentLayoutData.DesignGroupList.Add(ele));
                        // del #8314 グループタブの表示不正 王占宇 end

                        // add 2023-03-28 #8455 【デグレ】グループ情報がクリアされてしまう 鵬 start
                        RldLib.CurrentLayoutData.DesignGroupList.Clear();
                        RldLib.XlHelper.GetSheetGroupDataList().ToList().ForEach(ele => RldLib.CurrentLayoutData.DesignGroupList.Add(ele));
                        // add 2023-03-28 #8455 鵬 end
                        // パラメータシート読み込み
                        RldLib.CurrentLayoutData.DesignParamList.Clear();
                        RldLib.XlHelper.GetSheetParamDataList().ToList().ForEach(ele => RldLib.CurrentLayoutData.DesignParamList.Add(ele));
                        // RldLib.CurrentLayoutData.DesignParamListを並べ替える
                        RldLib.CurrentLayoutData.DesignParamList.Sort();
                        // add #8335 FNW帳票取込みの動作に問題あり 夏 start
                    }
                    // add #8335 FNW帳票取込みの動作に問題あり 夏 end
                    // テンプレート繰返しをサポートしている帳票種別の場合は該当データを読み込み
                    if (wData.IsSupportTempleteRepeat)
                    {
                        // upd 2021-02-19 No.517:FNW帳票レイアウトコンバート 趙 start
                        //RldLib.CurrentLayoutData.DesignTempleteData = RldLib.XlHelper.GetTempleteData();
                        if (wFlag)
                        {
                            RldLib.CurrentLayoutData.DesignTempleteData = RldLib.XlHelper.GetTempleteFromOldReportData();

                            // 設定データ(テンプレート繰返し)保存
                            RldLib.CurrentLayoutData.DesignSettingData.HasTemplete =
                                string.IsNullOrEmpty(RldLib.CurrentLayoutData.DesignTempleteData?.Range) ? RldConst.SettingData.VAL_HAS_TEMPLETE_NO : RldConst.SettingData.VAL_HAS_TEMPLETE_YES;
                            if (!RldLib.XlHelper.SetSettingData(RldLib.CurrentLayoutData.DesignSettingData))
                            {
                                return false;
                            }

                            // 全てのパラメータデータがテンプレート範囲に含まれているか更新
                            RldLib.UpdateDesignParamDataIsInTemplete();

                            // 旧帳票のグループシート読み込む処理により、グループリストを更新して保存する
                            RldLib.UpdateDesignGroupDataFromOldReport();
                        }
                        else
                        {
                            RldLib.CurrentLayoutData.DesignTempleteData = RldLib.XlHelper.GetTempleteData();
                        }
                        // upd 2021-02-19 No.517:FNW帳票レイアウトコンバート 趙 end
                    }

                    // del 2023-04-07 #8417 【IES起票】【帳票】【紹介状（集計）】①薬剤の表示が不正　②患者情報の表示のずれが発生　③空白画面の出力問題 鵬 start
                    // mod 2023-03-21 #8335 FNW帳票取込みの動作に問題あり 鵬 start
                    //if (wData.IsSupportTempleteRepeat)
                    //{
                    //    // add #8314 グループタブの表示不正 王占宇 start
                    //    FilterDesignGroupData();
                    //    // add #8314 グループタブの表示不正 王占宇 end
                    //}
                    // mod 2023-03-21 #8335 鵬 end
                    // del 2023-04-07 #8417 鵬 end

                    // add UT帳票No.122 再編集時、定期日常点検・交換部品記録簿のレイアウトデータ不正の対応 夏 start
                    RldLib.inspectionLayoutData = RldLib.XlHelper.GetDeviceData();
                    // add UT帳票No.122 再編集時、定期日常点検・交換部品記録簿のレイアウトデータ不正の対応 夏 end

                    // add FNSI-523 2次元帳票対応 夏 start
                    RldLib.totalLayoutData = RldLib.XlHelper.GetTotalData();
                    // add FNSI-523 2次元帳票対応 夏 end

                    // 履歴？

                    // レイアウトシートの保護を解除
                    RldLib.XlHelper.XlSheetLayout.IsProtected = false;

                    // ここまでくればOK
                    wRet = true;
                }
            }
            catch (Exception ex)
            {
                // 例外情報を記録
                this.ActionOfRequestRecordException(this, new RldDesignNotifyInfoRequestRecordExceptionEventArgs(ex, false));
                // エラーメッセージを表示
                this.ActionOfRequestShowMsgBox(
                    this,
                    new RldDesignNotifyInfoRequestShowMessageEventArgs()
                    {
                        Text = "Excel ファイルの読込に失敗しました。",
                        Caption = "致命的なエラーが発生しました",
                        Icon = MessageBoxIcon.Error,
                        Buttons = MessageBoxButtons.OK
                    });
            }

            return wRet;
        }

        // add #8314 グループタブの表示不正 王占宇 start
        private void FilterDesignGroupData()
        {
            // mod 2023-04-03 #8455 【デグレ】グループ情報がクリアされてしまう 鵬 start
            if (RldLib.CurrentLayoutData.DesignTempleteData == null)
            {
                return;
            }
            if (string.IsNullOrEmpty(RldLib.CurrentLayoutData.DesignTempleteData.Range))
            {
                return;
            }
            List<DesignGroupData> tempList = RldLib.XlHelper.GetSheetGroupDataList().ToList();
            List<DesignGroupData> addTempList = new List<DesignGroupData>();
            // mod #8314 グループタブの表示不正 王占宇 start
            // RldLib.CurrentLayoutData.DesignGroupList.Clear();
            List<DesignGroupData> itemList = new List<DesignGroupData>();
            itemList = RldLib.CurrentLayoutData.DesignGroupList.ToList();
            itemList.ForEach(p => RldLib.CurrentLayoutData.DesignGroupList.Remove(p));
            // mod #8314 グループタブの表示不正 王占宇 end
            //if (RldLib.CurrentLayoutData.DesignTempleteData == null)
            //{
            //    return;
            //}
            //if (string.IsNullOrEmpty(RldLib.CurrentLayoutData.DesignTempleteData.Range))
            //{
            //    return;
            //}
            // mod 2023-04-03 #8455 鵬 end

            try
            {
                using (var wXlRangeTemplete = new ExcelRangeEx(RldLib.XlHelper.XlSheetLayout, RldLib.CurrentLayoutData.DesignTempleteData.Range))
                {

                    // テンプレート領域を取得
                    var wTempleteArea = wXlRangeTemplete.GetRectangle();

                    for (int i = 0; i < RldLib.CurrentLayoutData.DesignParamList.Count; i++)
                    {

                        var wData = RldLib.CurrentLayoutData.DesignParamList[i];

                        // テンプレート内外状態を更新
                        using (var wXlRange = new ExcelRangeEx(RldLib.XlHelper.XlSheetLayout, wData.CellAddress))
                        {
                            if (RldLib.CurrentLayoutData.DesignSettingData.IsSupportTempleteRepeat)
                            {
                                // 帳票種別としてテンプレート繰返しをサポートしている場合は "外"

                                if (RldLib.CurrentLayoutData.DesignSettingData.HasTemplete == RldConst.SettingData.VAL_HAS_TEMPLETE_YES)
                                {
                                    // テンプレート繰返しの設定を行っている場合は範囲に入っているか確認
                                    if (wTempleteArea.Contains(wXlRange.GetRectangle()))
                                    {
                                        if (tempList.Where(p => p.GroupPath.Split(RldConst.PATH_SPLIT.ToCharArray()).AsQueryable().Last()
                                         == wData.CellAddress && p.IsInTemplete == RldConst.ParamData.VAL_IS_IN_TEMPLETE_IN).ToList().Count > 0)
                                        {
                                            addTempList.Add(tempList.FirstOrDefault(p => p.GroupPath.Split(RldConst.PATH_SPLIT.ToCharArray()).AsQueryable().Last()
                                            == wData.CellAddress && p.IsInTemplete == RldConst.ParamData.VAL_IS_IN_TEMPLETE_IN));
                                        }
                                        // add #8335 FNW帳票取込みの動作に問題あり 夏 start
                                        else
                                        {
                                            if (tempList.Where(p => p.GroupPath.Split(RldConst.PATH_SPLIT.ToCharArray()).AsQueryable().Last()
                                              == wData.CellAddress && p.IsInTemplete == RldConst.ParamData.VAL_IS_IN_TEMPLETE_NONE).ToList().Count > 0)
                                            {
                                                addTempList.Add(tempList.FirstOrDefault(p => p.GroupPath.Split(RldConst.PATH_SPLIT.ToCharArray()).AsQueryable().Last()
                                                == wData.CellAddress && p.IsInTemplete == RldConst.ParamData.VAL_IS_IN_TEMPLETE_NONE));
                                            }
                                        }
                                        // add #8335 FNW帳票取込みの動作に問題あり 夏 end
                                    }
                                    else
                                    {
                                        if (tempList.Where(p => p.GroupPath.Split(RldConst.PATH_SPLIT.ToCharArray()).AsQueryable().Last()
                                         == wData.CellAddress && p.IsInTemplete == RldConst.ParamData.VAL_IS_IN_TEMPLETE_OUT).ToList().Count > 0)
                                        {
                                            addTempList.Add(tempList.FirstOrDefault(p => p.GroupPath.Split(RldConst.PATH_SPLIT.ToCharArray()).AsQueryable().Last()
                                            == wData.CellAddress && p.IsInTemplete == RldConst.ParamData.VAL_IS_IN_TEMPLETE_OUT));
                                        }
                                        // add #8335 FNW帳票取込みの動作に問題あり 夏 start
                                        else
                                        {
                                            if (tempList.Where(p => p.GroupPath.Split(RldConst.PATH_SPLIT.ToCharArray()).AsQueryable().Last()
                                              == wData.CellAddress && p.IsInTemplete == RldConst.ParamData.VAL_IS_IN_TEMPLETE_NONE).ToList().Count > 0)
                                            {
                                                addTempList.Add(tempList.FirstOrDefault(p => p.GroupPath.Split(RldConst.PATH_SPLIT.ToCharArray()).AsQueryable().Last()
                                                == wData.CellAddress && p.IsInTemplete == RldConst.ParamData.VAL_IS_IN_TEMPLETE_NONE));
                                            }
                                        }
                                        // add #8335 FNW帳票取込みの動作に問題あり 夏 end
                                    }
                                }
                                else
                                {
                                    if (tempList.Where(p => p.GroupPath.Split(RldConst.PATH_SPLIT.ToCharArray()).AsQueryable().Last()
                                         == wData.CellAddress && p.IsInTemplete == RldConst.ParamData.VAL_IS_IN_TEMPLETE_NONE).ToList().Count > 0)
                                    {
                                        addTempList.Add(tempList.FirstOrDefault(p => p.GroupPath.Split(RldConst.PATH_SPLIT.ToCharArray()).AsQueryable().Last()
                                        == wData.CellAddress && p.IsInTemplete == RldConst.ParamData.VAL_IS_IN_TEMPLETE_NONE));
                                    }
                                }
                            }
                        }
                    }

                }
                var newList = addTempList.GroupBy(p => new { p.GroupName, p.IsInTemplete });
                List<DesignGroupData> newAddTempList = new List<DesignGroupData>();
                foreach (var item in newList)
                {
                    newAddTempList.Add(item.ToList()[0]);
                }
                // グループシート読み込み
                //RldLib.CurrentLayoutData.DesignGroupList.Clear();
                newAddTempList.ForEach(ele => RldLib.CurrentLayoutData.DesignGroupList.Add(ele));
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }
        }
        // add #8314 グループタブの表示不正 王占宇 end

        /// <summary>
        /// Excel ブックへデータを保存します。
        /// </summary>
        /// <returns></returns>
        private bool SaveExcelFileData()
        {
            bool wRet = false;

            try
            {
                // テンプレート繰返しデータ保存(テンプレート繰返しをサポートしている場合のみ)
                if (RldLib.CurrentLayoutData.DesignSettingData.IsSupportTempleteRepeat)
                {
                    if (!RldLib.XlHelper.SetTempleteData(RldLib.CurrentLayoutData.DesignTempleteData))
                    {
                        return false;
                    }
                }

                // パラメータリスト保存
                if (!RldLib.XlHelper.SetSheetParamDataList(RldLib.CurrentLayoutData.DesignParamList))
                {
                    return false;
                }

                // グループリスト保存
                if (!RldLib.XlHelper.SetSheetGroupDataList(RldLib.CurrentLayoutData.DesignGroupList))
                {
                    return false;
                }

                // 設定データ保存
                RldLib.CurrentLayoutData.DesignSettingData.HasTemplete =
                    string.IsNullOrEmpty(RldLib.CurrentLayoutData.DesignTempleteData?.Range) ? RldConst.SettingData.VAL_HAS_TEMPLETE_NO : RldConst.SettingData.VAL_HAS_TEMPLETE_YES;
                if (RldLib.CurrentReport.ReportCode != long.MinValue)
                {
                    RldLib.CurrentLayoutData.DesignSettingData.ReportCode = RldLib.CurrentReport.ReportCode.ToString();
                }
                if (!RldLib.XlHelper.SetSettingData(RldLib.CurrentLayoutData.DesignSettingData))
                {
                    return false;
                }

                // add UT帳票No.122 再編集時、定期日常点検・交換部品記録簿のレイアウトデータ不正の対応 夏 start
                // 装置データ保存
                if (!RldLib.XlHelper.SetDeviceData(RldLib.inspectionLayoutData))
                {
                    return false;
                }
                // add UT帳票No.122 再編集時、定期日常点検・交換部品記録簿のレイアウトデータ不正の対応 夏 end

                // add FNSI-523 2次元帳票対応 夏 start
                // 集計データ保存
                if (!RldLib.XlHelper.SetTotalData(RldLib.totalLayoutData))
                {
                    return false;
                }
                // add FNSI-523 2次元帳票対応 夏 end

                wRet = true;
            }
            catch (Exception ex)
            {
                // ログ出力
                this.ActionOfRequestRecordException(this, new RldDesignNotifyInfoRequestRecordExceptionEventArgs(ex, true));
            }

            return wRet;
        }

        /// <summary>
        /// Excel ブックを開きます。
        /// </summary>
        /// <returns></returns>
        private bool OpenExcel()
        {
            bool wRet = false;

            try
            {
                if (RldLib.XlHelper.Open(RldLib.WorkXlsxFilePath))
                {
                    if (!RldLib.XlHelper.XlBook.IsReadOnly)
                    {
                        wRet = true;
                    }
                    else
                    {
                        this.ActionOfRequestShowMsgBox(
                            this,
                            new RldDesignNotifyInfoRequestShowMessageEventArgs()
                            {
                                Text = string.Format("ファイルが読取専用になっています。{0}起動中の Excel がある場合は終了して下さい。", System.Environment.NewLine),
                                Buttons = MessageBoxButtons.OK,
                                Icon = MessageBoxIcon.Error
                            });
                    }
                }
                else
                {
                    this.ActionOfRequestShowMsgBox(
                        this,
                        new RldDesignNotifyInfoRequestShowMessageEventArgs()
                        {
                            Text = string.Format(@"Microsoft Excel の起動に失敗しました。{0}起動中の Excel がある場合は終了して下さい。", System.Environment.NewLine),
                            Buttons = MessageBoxButtons.OK,
                            Icon = MessageBoxIcon.Error
                        });
                }
            }
            catch (Exception ex)
            {
                // ログ出力
                this.ActionOfRequestRecordException(this, new RldDesignNotifyInfoRequestRecordExceptionEventArgs(ex, true));
            }

            return wRet;
        }

        /// <summary>
        /// Excel を閉じます。
        /// </summary>
        /// <returns></returns>
        private bool CloseExcel()
        {
            bool wRet = false;

            try
            {
                // ブックは閉じる
                RldLib.XlHelper.Close();
                // 後で使用される可能性があるため非表示にしておく
                RldLib.XlHelper.XlApp.Application.Visible = false;

                wRet = true;
            }
            catch (Exception ex)
            {
                // ログ出力
                this.ActionOfRequestRecordException(this, new RldDesignNotifyInfoRequestRecordExceptionEventArgs(ex, true));
            }

            return wRet;
        }

        /// <summary>
        /// 現在編集中の帳票を特定します。
        /// </summary>
        /// <returns></returns>
        // mod #11116 単集計帳票の「レイアウト」タブの内容が保存されないことがある 高 start
        //private async Task<bool> GetEditingReportInfo()
        private async Task<bool> GetEditingReportInfo(bool aIsReload)
        // mod #11116 単集計帳票の「レイアウト」タブの内容が保存されないことがある 高 end
        {
            string wReportClass = RldLib.CurrentLayoutData.DesignSettingData.ReportClass;
            string wReportCode = RldLib.CurrentLayoutData.DesignSettingData.ReportCode;

            // add #11116 単集計帳票の「レイアウト」タブの内容が保存されないことがある 高 start
            if (aIsReload)
            {
            // add #11116 単集計帳票の「レイアウト」タブの内容が保存されないことがある 高 end
                // 初期値を生成
                RldLib.CurrentReport = new MstReportData()
                {
                    ReportClass = RldLib.ConvertReportClassStringToInt32(wReportClass),
                    ReportName = RldLib.ReportClassList.Single(ele => ele.ReportClass == wReportClass).ReportClassName,
                    IsDisplay = MstReportData.VAL_IS_DISPLAY_DONE,
                    IsDelete = MstReportData.VAL_IS_DELETE_NONE
                };

                // add #8335 FNW帳票取込みの動作に問題あり 夏 start
                if (!String.IsNullOrEmpty(RldLib.StrOldFileName))
                {
                    RldLib.CurrentReport.ReportName = RldLib.StrOldFileName;
                    RldLib.StrOldFileName = String.Empty;
                }
                // add #8335 FNW帳票取込みの動作に問題あり 夏 end
            }

            // オフライン時は特定しない
            if (!SignInLib.SignIn.SignInInfo.IsOnline)
            {
                return true;
            }
            // 新規作成時は特定しない
            if (string.IsNullOrEmpty(wReportCode))
            {
                // add FNSI-699,700,751 装置帳票の記録簿対応 夏 start
                if ("Device".Equals(wReportClass))
                {
                    // add #11116 単集計帳票の「レイアウト」タブの内容が保存されないことがある 高 start
                    if (string.IsNullOrEmpty(RldLib.inspectionLayoutData.ReportType))
                    {
                    // add #11116 単集計帳票の「レイアウト」タブの内容が保存されないことがある 高 end
                        RldLib.inspectionLayoutData.ReportType = "1";
                    }
					// add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
                    if (string.IsNullOrEmpty(RldLib.inspectionLayoutData.UseCD))
                    {
                        RldLib.inspectionLayoutData.UseCD = "1";
                    }
					// add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
                }
                // add FNSI-699,700,751 装置帳票の記録簿対応 夏 end
                return true;
            }

            bool wRet = false;

            try
            {
                string wUri = $"{NKKWebAccess.BaseUri}{RldConst.Uri.WEB_APP}{RldConst.Uri.GET_MST_REPORT}/{wReportCode}";

                // データを取得
                var wRestRet = await NKKWebAccess.Get($"帳票マスタデータ取得 ReportCode='{wReportCode}'", wUri, NKKWebAccess.SKIP_OTP);

                if (!wRestRet.isLogin)
                {
                    // mod #10489 一時ファイルによる帳票移植時にレイアウトデザイナでエラー 高 start
                    //throw new System.ApplicationException();
                    if ("Device".Equals(wReportClass))
                    {
                        RldLib.inspectionLayoutData.ReportType = "1";
						// add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
                        RldLib.inspectionLayoutData.UseCD = "1";
						// add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
                    }
                    RldLib.CurrentLayoutData.DesignSettingData.ReportCode = null;
                    return false;
                    // mod #10489 一時ファイルによる帳票移植時にレイアウトデザイナでエラー 高 end
                }
                else if (wRestRet.response.IsSuccessStatusCode && RldJsonDataSerializeHelper<MstReportData>.Deserialize(wRestRet.strContent) is MstReportData wData)
                {
                    //add 6502 定期・日常が分離されていない 吉 start
                    MstReportData reportInfo = RldJsonDataSerializeHelper<MstReportData>.Deserialize(wRestRet.strContent);
                    // add #11158 テンプレート設定のない帳票でテンプレート繰返しエラーが出る 高 start
                    // mod #11430 日機装施設で編集を開始するとすべて新規帳票になる 高 start
                    //if (SignInLib.SignIn.SignInInfo.FacilityCode.Equals(reportInfo.FacilityCode) && RldLib.CurrentReport.ReportClass.Equals(reportInfo.ReportClass))
                    if (LayoutDesignerUtility.CurrentFacilityCd.Equals(reportInfo.FacilityCode) && RldLib.CurrentReport.ReportClass.Equals(reportInfo.ReportClass))
                    // mod #11430 日機装施設で編集を開始するとすべて新規帳票になる 高 end
                    {
                        wRet = true;
                    }
                    else
                    {
                        return false;
                    }
                    // add #11158 テンプレート設定のない帳票でテンプレート繰返しエラーが出る 高 end
                    // add #11116 単集計帳票の「レイアウト」タブの内容が保存されないことがある 高 start
                    if (aIsReload)
                    {
                    // add #11116 単集計帳票の「レイアウト」タブの内容が保存されないことがある 高 end
                        // add 7347 【デグレ】削除されていない帳票が帳票画面のリストに表示されない 吉 start
                        if (reportInfo.ReportClass == RldConst.MasterData.Report.VAL_TYPE_DEVICE)
                        {
                            // add 7347 【デグレ】削除されていない帳票が帳票画面のリストに表示されない 吉 end
                            if (null == reportInfo.ExtractionCondition)
                            {
                                // mod 7347 【デグレ】削除されていない帳票が帳票画面のリストに表示されない 吉 start
                                // RldLib.inspectionLayoutData.ReportType = "0";
                                // RldLib.inspectionLayoutData.UseCD = "0";
                                // RldLib.inspectionLayoutData.RecordCD = "0";
                                // RldLib.inspectionLayoutData.LayoutCD = "0";
                                RldLib.inspectionLayoutData.ReportType = "1";
								// add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
                                RldLib.inspectionLayoutData.UseCD = "1";
                                RldLib.inspectionLayoutData.MachineTypeCD = "";
								// add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
                                // mod 7347 【デグレ】削除されていない帳票が帳票画面のリストに表示されない 吉 end
                            }
                            else
                            {
                                // mod 7347 【デグレ】削除されていない帳票が帳票画面のリストに表示されない 吉 start
                                // RldLib.inspectionLayoutData.ReportType = "1";
								// mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
								//RldLib.inspectionLayoutData.ReportType = "0";
                                if (!string.IsNullOrEmpty(reportInfo.ExtractionCondition.MachineTypeCD) && !reportInfo.ExtractionCondition.MachineTypeCD.Equals("0"))
                                {
                                    RldLib.inspectionLayoutData.ReportType = "0";
                                }
                                else
                                {
                                    RldLib.inspectionLayoutData.ReportType = "1";
                                }
								// mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
                                RldLib.inspectionLayoutData.UseCD = reportInfo.ExtractionCondition.UseCD;
								// mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
                                //RldLib.inspectionLayoutData.RecordCD = reportInfo.ExtractionCondition.RecordCD;
                                //RldLib.inspectionLayoutData.LayoutCD = reportInfo.ExtractionCondition.LayoutCD;
                                RldLib.inspectionLayoutData.MachineTypeCD = reportInfo.ExtractionCondition.MachineTypeCD;
								// mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
                                // mod 7347 【デグレ】削除されていない帳票が帳票画面のリストに表示されない 吉 end
                            }
                            //add 6502 定期・日常が分離されていない 吉 end
                            // add 7347 【デグレ】削除されていない帳票が帳票画面のリストに表示されない 吉 start
                        }
                        // add 7347 【デグレ】削除されていない帳票が帳票画面のリストに表示されない 吉 end
                        RldLib.CurrentReport = wData;
                    }
                    // add FNSI-699,700,751 装置帳票の記録簿対応 夏 start
					// del #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
                    //if (RldLib.CurrentReport.ExtractionCondition == null)
                    //{
                    //    RldLib.CurrentReport.ExtractionCondition = new Extraction();
                    //}
					// del #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
                    // add FNSI-699,700,751 装置帳票の記録簿対応 夏 end
                    // del #11158 テンプレート設定のない帳票でテンプレート繰返しエラーが出る 高 start
                    //if (SignInLib.SignIn.SignInInfo.FacilityCode.Equals(reportInfo.FacilityCode))
                    //{
                    //    wRet = true;
                    //}
                    //else
                    //{
                    //    wRet = false;
                    //}
                    // del #11158 テンプレート設定のない帳票でテンプレート繰返しエラーが出る 高 end
                }
                else
                {
                    throw new System.ApplicationException();
                }
            }
            catch (Exception ex)
            {
                // 例外情報を生成
                var wEx = new System.ApplicationException("帳票マスタデータの取得に失敗しました。", ex);
                // 例外情報を記録(画面にメッセージボックスを表示)
                this.ActionOfRequestRecordException(this, new RldDesignNotifyInfoRequestRecordExceptionEventArgs(wEx, false));
            }

            return wRet;
        }

        #endregion

        #region メンバ関数定義(Mediator / Colleague)

        /// <summary>
        /// Colleague からのメッセージを受信するハンドラ関数
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void ColleagueMessageHandler(object sender, RldDesignNotifyInfoEventArgs e)
        {
            // 処理内容を確認し各処理を実行する。
            switch (e.InfoType)
            {
                case RldDesignNotifyInfoEventArgs.EnumInfoType.RequestCloseApp:
                    // 終了要求
                    this.ActionOfRequestCloseApp(sender, (RldDesignNotifyInfoRequestCloseEventArgs)e);
                    break;

                case RldDesignNotifyInfoEventArgs.EnumInfoType.RequestRecordException:
                    // 例外情報記録要求
                    this.ActionOfRequestRecordException(sender, (RldDesignNotifyInfoRequestRecordExceptionEventArgs)e);
                    break;

                case RldDesignNotifyInfoEventArgs.EnumInfoType.RequestShowMessage:
                    // メッセージボックス表示要求
                    this.ActionOfRequestShowMsgBox(sender, (RldDesignNotifyInfoRequestShowMessageEventArgs)e);
                    break;

                case RldDesignNotifyInfoEventArgs.EnumInfoType.RequestOpenDialog:
                    // ダイアログ表示要求
                    this.ActionOfRequestOpenDialog(sender, (RldDesignNotifyInfoRequestOpenDialogEventArgs)e);
                    break;

                //case RldDesignNotifyInfoEventArgs.EnumInfoType.NotifyDragDropStatusChanged:
                //    // ドラッグアンドドロップ状態変更通知
                //    this.ActionOfDragDropStatusChanged(sender, (RldDesignNotifyInfoNotifyDragDropStatusChangedEventArgs)e);
                //    break;

                case RldDesignNotifyInfoEventArgs.EnumInfoType.NotifyDragDropCompleted:
                    // ドラッグアンドドロップ完了通知
                    this.ActionOfDragDropCompleted(sender, (RldDesignNotifyInfoNotifyDragDropCompletedEventArgs)e);
                    break;

                case RldDesignNotifyInfoEventArgs.EnumInfoType.RequestRemoveAllParam:
                    // 全パラメータ編集データ削除要求通知
                    this.ActionOfRemoveAllParam(sender, (RldDesignNotifyInfoRequestRemoveAllParamEventArgs)e);
                    break;

                case RldDesignNotifyInfoEventArgs.EnumInfoType.NotifySelectedParamChanged:
                    // 選択中パラメータ変更通知
                    this.ActionOfSelectedParamChanged(sender, (RldDesignNotifyInfoNotifySelectedParamChangedEventArgs)e);
                    break;

                case RldDesignNotifyInfoEventArgs.EnumInfoType.RequestPreview:
                    // プレビュー表示要求
                    this.ActionOfPreview(sender, (RldDesignNotifyInfoRequestPreviewEventArgs)e);
                    break;

                case RldDesignNotifyInfoEventArgs.EnumInfoType.RequestSaveDropFile:
                    // ファイル保存/破棄要求
                    this.ActionOfSaveDropFile(sender, (RldDesignNotifyInfoRequestSaveDropFileEventArgs)e);
                    break;

                default:
                    break;
            }
        }

        /// <summary>
        /// Colleague にメッセージを送信します。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="aDestination"></param>
        /// <param name="e"></param>
        private void SendNotifyInfo(object sender, IRldDesignColleague aDestination, RldDesignNotifyInfoEventArgs e)
        {
            try
            {
                var wDestination = aDestination as IRldDesignRecvOnlyColleague;

                if (wDestination != null)
                {
                    this.NotifyInfo += new EventHandler<RldDesignNotifyInfoEventArgs>(wDestination.ReceiveNotifyInfo);
                    this.NotifyInfo(sender, e);
                    this.NotifyInfo -= new EventHandler<RldDesignNotifyInfoEventArgs>(wDestination.ReceiveNotifyInfo);
                }
            }
            finally
            {
            }
        }

        #region アプリケーション終了要求

        /// <summary>
        /// アプリケーション終了要求受信時処理を行います。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void ActionOfRequestCloseApp(object sender, RldDesignNotifyInfoRequestCloseEventArgs e)
        {
            //add 吉 装置帳票：定期・日常が分離されていない  start
            if (checkRepeat)
            {
                //add 吉 装置帳票：定期・日常が分離されていない  end
                RldLib.IsStartDesignWindowClosing = true;

                // 終了する
                this.m_Colleagues.ForEach(ele => (ele as Form)?.Close());

                this.DialogResult = e.DialogResult;

                this.Close();

                // add mongodbに転載、サーバー停止ログ。 陳 start
                if (NKKWebAccess.Login)
                {
                    LogManagement.LogMessage = "帳票レイアウトデザイナーアプリサーバーが停止しました。";
                    LogManagement.SetLogingProperties();
                }
                // add mongodbに転載、サーバー停止ログ。 陳 end
                RldLib.IsStartDesignWindowClosing = false;
                //add 吉 装置帳票：定期・日常が分離されていない  start
            }
            checkRepeat = true;
            //add 吉 装置帳票：定期・日常が分離されていない  end

        }

        #endregion

        #region 例外情報記録要求

        /// <summary>
        /// 例外情報記録要求受信時処理を行います。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void ActionOfRequestRecordException(object sender, RldDesignNotifyInfoRequestRecordExceptionEventArgs e)
        {
            RldUtility.RecordException(this, e.Exception, e.IsShowMessage);
        }

        #endregion

        #region メッセージボックス表示要求

        /// <summary>
        /// メッセージボックス表示要求受信時処理を行います。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void ActionOfRequestShowMsgBox(object sender, RldDesignNotifyInfoRequestShowMessageEventArgs e)
        {
            try
            {
                // レイアウトシートからのイベントを受けないようにする
                RldLib.XlHelper.IsHandleLayoutSheetEvent = false;

                using (var wModalForm = new DesignMessageBoxAdapterForm(this))
                {

                    // メッセージボックスに必要な情報をセット
                    wModalForm.EventData = e;
                    // 表示
                    e.DialogResult = wModalForm.ShowDialog();
                }
            }
            finally
            {
                // レイアウトシートからのイベントを受けるようにする
                RldLib.XlHelper.IsHandleLayoutSheetEvent = true;
            }
        }

        #endregion

        #region ダイアログ表示要求

        /// <summary>
        /// ダイアログ表示要求受信時処理を行います。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void ActionOfRequestOpenDialog(object sender, RldDesignNotifyInfoRequestOpenDialogEventArgs e)
        {

            const string ErrorMessage = "ダイアログの表示に失敗しました。\r\n編集途中の場合は編集を完了して下さい。";

            try
            {
                // レイアウトシートからのイベントを受けないようにする
                RldLib.XlHelper.IsHandleLayoutSheetEvent = false;

                if (e.IsProtectLayoutSheet)
                {
                    RldLib.XlHelper.XlSheetLayout.IsProtected = true;
                }

                if (e.TargetForm.Name == "frmEditRepeat")
                {
                    RldLib.XlHelper.XlSheetLayout.IsProtected = false;
                }

                // 画面全体をロックする場合は
                if (e.IsAllWindowLock)
                {
                    using (var wAdapter = new DesignDialogAdapterForm(this))
                    {
                        // 表示に必要な情報をセット
                        wAdapter.TargetForm = e.TargetForm;
                        // 表示
                        wAdapter.ShowDialog();
                    }
                }
                // 画面全体をロックしない場合はダイアログをそのまま表示
                else
                {
                    // BUG #12556: owner を付けて、サブモニタ作業中のダイアログが主画面へ飛ばないようにする。
                    e.TargetForm.ShowDialog(this.GetRequestDialogOwner(sender));
                }
            }
            catch (System.Runtime.InteropServices.COMException ex)
            {
                // 例外情報を生成
                // 例外情報を記録(画面にメッセージボックスを表示)
                var comEx = new RldDesignNotifyInfoRequestRecordExceptionEventArgs(new ApplicationException(ErrorMessage, ex), true);
                RldUtility.RecordException(this, comEx.Exception, true, "確認してください");
            }
            catch (Exception ex)
            {
                // 例外情報を生成
                var wEx = new System.ApplicationException(ErrorMessage, ex);
                // 例外情報を記録(画面にメッセージボックスを表示)
                this.ActionOfRequestRecordException(this, new RldDesignNotifyInfoRequestRecordExceptionEventArgs(wEx, true));
            }
            finally
            {
                if (e.IsProtectLayoutSheet && RldLib.XlHelper.XlSheetLayout.IsProtected)
                {
                    RldLib.XlHelper.XlSheetLayout.IsProtected = false;
                }
                // レイアウトシートからのイベントを受けるようにする
                RldLib.XlHelper.IsHandleLayoutSheetEvent = true;
            }
        }

        #endregion

        #region ドラッグアンドドロップ状態変更通知

        ///// <summary>
        ///// ドラッグアンドドロップ状態変更通知受信時処理を行います。
        ///// </summary>
        ///// <param name="sender"></param>
        ///// <param name="e"></param>
        //private void ActionOfDragDropStatusChanged(object sender, RldDesignNotifyInfoNotifyDragDropStatusChangedEventArgs e)
        //{
        //    // デザイナウィンドウへ通知する
        //    var wColleagues = this.m_Colleagues.SingleOrDefault(ele => ele.GetType() == typeof(frmDesignChildLayout));
        //    if( wColleagues != null )
        //        this.SendNotifyInfo(sender, wColleagues, e);
        //}

        #endregion

        #region ドラッグアンドドロップ操作完了

        /// <summary>
        /// ドラッグアンドドロップ操作完了受信時処理を行います。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void ActionOfDragDropCompleted(object sender, RldDesignNotifyInfoNotifyDragDropCompletedEventArgs e)
        {
            // レイアウトウィンドウへ通知する
            var wColleagues = this.m_Colleagues.SingleOrDefault(ele => ele.GetType() == typeof(frmDesignChildLayout));
            if (wColleagues != null)
            {
                this.SendNotifyInfo(sender, wColleagues, e);
            }
        }

        #endregion

        #region 選択中パラメータ変更通知

        /// <summary>
        /// 選択パラメータアイテム変更通知受信時処理を行います。
        /// </summary>
        private void ActionOfSelectedParamChanged(object sender, RldDesignNotifyInfoNotifySelectedParamChangedEventArgs e)
        {
            // 選択アイテムウィンドウへ通知する
            var wColleagues = this.m_Colleagues.SingleOrDefault(ele => ele.GetType() == typeof(frmDesignChildSelectedItem));
            if (wColleagues != null)
            {
                this.SendNotifyInfo(sender, wColleagues, e);
            }
            // add #11501 レイアウトデザイナのユーザビリティ改善 高 start
            wColleagues = this.m_Colleagues.SingleOrDefault(ele => ele.GetType() == typeof(frmDesignChildLayout));
            if (wColleagues != null)
            {
                // send nofity to group list
                this.SendNotifyInfo(sender, wColleagues, e);
            }
            // add #11501 レイアウトデザイナのユーザビリティ改善 高 end
        }

        #endregion

        #region 全パラメータ削除要求通知

        /// <summary>
        /// 全パラメータ削除要求通知受信時処理を行います。
        /// </summary>
        private void ActionOfRemoveAllParam(object sender, RldDesignNotifyInfoRequestRemoveAllParamEventArgs e)
        {
            // 先にレイアウトウィンドウへ通知する
            IRldDesignColleague wColleagues = this.m_Colleagues.SingleOrDefault(ele => ele.GetType() == typeof(frmDesignChildLayout));
            if (wColleagues != null)
            {
                this.SendNotifyInfo(sender, wColleagues, e);
            }

            // 続けて選択アイテムウィンドウへ通知する
            wColleagues = this.m_Colleagues.SingleOrDefault(ele => ele.GetType() == typeof(frmDesignChildSelectedItem));
            if (wColleagues != null)
            {
                this.SendNotifyInfo(sender, wColleagues, e);
            }
        }

        #endregion

        #region プレビュー表示要求通知

        /// <summary>
        /// プレビュー表示要求通知受信時処理を行います。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void ActionOfPreview(object sender, RldDesignNotifyInfoRequestPreviewEventArgs e)
        {
            switch (e.Mode)
            {
                case RldDesignNotifyInfoRequestPreviewEventArgs.EnumMode.Excel:
                    this.ActionOfPreview_Excel();
                    break;

                case RldDesignNotifyInfoRequestPreviewEventArgs.EnumMode.Html:
                    this.ActionOfPreview_Html();
                    break;
            }
        }

        /// <summary>
        /// Excel の印刷プレビュー機能を使用してプレビュー表示を行います。
        /// </summary>
        private void ActionOfPreview_Excel()
        {
            void wFuncSetVisible(bool aIsHide) =>
                this.m_Colleagues.ForEach(ele => ((Form)ele).Opacity = aIsHide ? 0d : 1d);

            try
            {
                // 子ウィンドウの表示状態を変更(非表示状態)
                wFuncSetVisible(true);
                // プレビュー表示を開始
                RldLib.XlHelper.PreviewLayout(RldLib.CurrentLayoutData);
            }
            finally
            {
                // 子ウィンドウの表示状態を復元
                wFuncSetVisible(false);
            }
        }

        /// <summary>
        /// ブラウザでプレビュー表示を行います。
        /// </summary>
        private void ActionOfPreview_Html()
        {
            try
            {
                // Excel を非表示に設定
                RldLib.XlHelper.XlApp.Application.Visible = false;
                // add #12557 レイアウトデザイナで開くExcelのワークシートが編集可能 高 start
                RldLib.XlHelper.XlBook.IsProtected = false;
                // add #12557 レイアウトデザイナで開くExcelのワークシートが編集可能 高 end

                // 現在のレイアウトシートの内容でプレビューシートを作成(失敗時は抜ける)
                if (!RldLib.XlHelper.MakePreviewSheet(RldLib.CurrentLayoutData))
                {
                    // add #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 start
                    // レイアウトシートを選択
                    RldLib.XlHelper.XlSheetLayout.Worksheet.Select();

                    // プレビューシートを非表示にしておく
                    RldLib.XlHelper.XlSheetPreview.Worksheet.Visible = Microsoft.Office.Interop.Excel.XlSheetVisibility.xlSheetVeryHidden;

                    // Excel を表示
                    RldLib.XlHelper.XlApp.Application.Visible = true;
                    // add #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 end
                    return;
                }

                // プレビュー表示用 html ファイルが存在する場合は削除
                RldUtility.DeleteFileIfExists(RldLib.PreviewHtmlFilePath);

                // mod #6435 プレビューがexcelとブラウザで異なる xiaosonglei start
                //string wDivID = string.Format("Preview_{0:yyyyMMddHHmmss}", DateTime.Now);

                //// プレビューシートを html ファイルで保存(失敗時は抜ける)
                //// mod #6061 エクセルで設定した倍率で印刷されない 歴程 start
                ////if (!RldLib.XlHelper.PublishHtmlFile(RldLib.XlHelper.XlSheetPreview, RldLib.PreviewHtmlFilePath, wDivID))
                //if (!RldLib.XlHelper.PublishHtmlFile(RldLib.XlHelper.XlSheetPreview, RldLib.PreviewHtmlFilePath, wDivID, "preview"))
                //// mod #6061 エクセルで設定した倍率で印刷されない 歴程 end
                //{
                //    return;
                //}

                FileInfo sourcePreviewFile = new FileInfo(RldLib.PreviewHtmlFilePath);
                string tempHtmlDataFilePath = string.Format("{0}ReportTempHtml_{1}{2}"
                    , sourcePreviewFile.Directory
                    , DateTime.Now.ToString("yyyyMMddHHmmss")
                    , ".xlsx");
                RldLib.XlHelper.XlBook.Workbook.SaveCopyAs(tempHtmlDataFilePath);

                FileStream fStream = new FileStream(tempHtmlDataFilePath, FileMode.Open);
                long size = fStream.Length;
                byte[] excelByte = new byte[size];
                fStream.Read(excelByte, 0, excelByte.Length);
                fStream.Close();

                string convertHtmlUri = $"{NKKWebAccessLib.NKKWebAccess.BaseUri}/ntss-admin-web/api/master_report/getHtml/1";
                string byteStr = RldJsonDataSerializeHelper<byte[]>.Serialize(excelByte);
                string paramData = "{ \"excelBytes\": " + byteStr + "}";
                NKKWebAccessLib.NKKWebAccessResponse res = NKKWebAccessLib.NKKWebAccess.Post("getHtmlTest", convertHtmlUri, paramData, NKKWebAccessLib.NKKWebAccess.SKIP_OTP).Result;

                if (res != null && !string.IsNullOrEmpty(res.strContent))
                {
                    StreamWriter htmlWriter = new StreamWriter(RldLib.PreviewHtmlFilePath);
                    StringBuilder htmlBuilder = new StringBuilder();                   
                    // add #9655 ブラウザプレビューで翻訳オプションが表示される donghao start
                    //htmlBuilder.Append("<html>");
                    htmlBuilder.Append("<html lang=\"ja\">");
                    // add #9655 ブラウザプレビューで翻訳オプションが表示される donghao end
                    htmlBuilder.Append("<head>");
                    htmlBuilder.Append("<meta charset=\"UTF-8\">");
                    htmlBuilder.Append(res.strContent);
                    htmlBuilder.Append("</head>");
                    htmlBuilder.Append("</html>");
                    htmlWriter.Write(htmlBuilder.ToString());
                    htmlWriter.Close();
                }

                File.Delete(tempHtmlDataFilePath);
                // mod #6435 プレビューがexcelとブラウザで異なる xiaosonglei end

                // レイアウトシートを選択
                RldLib.XlHelper.XlSheetLayout.Worksheet.Select();

                // プレビューシートを非表示にしておく
                RldLib.XlHelper.XlSheetPreview.Worksheet.Visible = Microsoft.Office.Interop.Excel.XlSheetVisibility.xlSheetVeryHidden;

                // Excel を表示
                RldLib.XlHelper.XlApp.Application.Visible = true;

                // ブラウザで表示
                System.Diagnostics.Process.Start(RldLib.PreviewHtmlFilePath);
            }
            catch (Exception ex)
            {
                // 例外情報を生成
                var wEx = new System.ApplicationException("プレビュー表示中にエラーが発生しました。\r\n編集途中の場合は編集を完了して下さい。", ex);
                // 例外情報を記録(画面にメッセージボックスを表示)
                this.ActionOfRequestRecordException(this, new RldDesignNotifyInfoRequestRecordExceptionEventArgs(wEx, true));
            }
            finally
            {
                // add #12557 レイアウトデザイナで開くExcelのワークシートが編集可能 高 start
                try { RldLib.XlHelper.XlBook.IsProtected = true; }
                catch { }
                // add #12557 レイアウトデザイナで開くExcelのワークシートが編集可能 高 end

                // Excel が非表示状態の場合は表示する
                if (!RldLib.XlHelper.XlApp.Application.Visible)
                {
                    RldLib.XlHelper.XlApp.Application.Visible = true;
                }
            }
        }

        #endregion

        #region ファイル保存/破棄要求通知
        //add 吉 装置帳票：定期・日常が分離されていない  start
        bool checkRepeat = true;
        //add 吉 装置帳票：定期・日常が分離されていない  end
        /// <summary>
        /// ファイル保存/破棄要求受信時処理を行います。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void ActionOfSaveDropFile(object sender, RldDesignNotifyInfoRequestSaveDropFileEventArgs e)
        {
            // add #11758 セルを編集中のまま、保存作業を行うと致命的なエラーが発生する 高 start
            RldLib.SendExeclTAB();
            // add #11758 セルを編集中のまま、保存作業を行うと致命的なエラーが発生する 高 end
            // 作業中ファイルとして保存する場合はここで抜ける
            // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 start
            string path = RldLib.XlHelper.XlBookFilePath;
            // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 end
            //add #8801 zhu start
            this.MustDeleteWorkFile = false;
            //add #8801 zhu end
            // 破棄する場合
            if (!e.IsSave)
            {
                // このタイミングでは削除出来ないためフォームが閉じるタイミングで削除するようにセット
                this.MustDeleteWorkFile = true;
                e.Result = true;
                return;
            }

            // add #8335 FNW帳票取込みの動作に問題あり 夏 start
            Dictionary<String, dynamic> wChangedRangeManagedCellValueList;
            Excel.Range aRangeAddress = RldLib.XlHelper.XlSheetLayout.Worksheet.UsedRange;
			// add #10399 【デグレ】出力時に非表示セルが処理されない limingzhe start
            RldLib.XlHelper.XlApp.Application.EnableEvents = false;
			// add #10399 【デグレ】出力時に非表示セルが処理されない limingzhe end
            using (var wXlSheetCells = new ExcelRangeEx(aRangeAddress))
            {
                // 変更された範囲内の管理対象セルのアドレスと値を取得
                // mod #10399 【デグレ】出力時に非表示セルが処理されない limingzhe start
                wChangedRangeManagedCellValueList = wXlSheetCells.FindCellAddrValue(RldConst.PATH_HEADER, Type.Missing, Excel.XlFindLookIn.xlValues, Excel.XlLookAt.xlPart, Excel.XlSearchOrder.xlByRows, Excel.XlSearchDirection.xlNext, false, Type.Missing, Type.Missing);
                // mod #10399 【デグレ】出力時に非表示セルが処理されない limingzhe end
                if (wChangedRangeManagedCellValueList.Count > 0)
                {
                    foreach (var wData in wChangedRangeManagedCellValueList)
                    {
                        if (RldConst.PATH_HEADER.Equals(wData.Value) || RldConst.CALC_HEADER.Equals(wData.Value))
                        {
                            e.Result = false;
                            // add #10399 【デグレ】出力時に非表示セルが処理されない limingzhe start
                            RldLib.XlHelper.XlApp.Application.EnableEvents = true;
                            // add #10399 【デグレ】出力時に非表示セルが処理されない limingzhe end
                            // BUG #12556: 親側からの警告表示も、現在の 4 画面モニタへ表示する。
                            MessageBox.Show(this.GetVisibleDesignWindowOwner(), "不正なパラメータの項目があります。", "不正パラメータがあります");
                            return;
                        }
                    }
                }
            }
			// add #10399 【デグレ】出力時に非表示セルが処理されない limingzhe start
            RldLib.XlHelper.XlApp.Application.EnableEvents = true;
			// add #10399 【デグレ】出力時に非表示セルが処理されない limingzhe end
            // add #8335 FNW帳票取込みの動作に問題あり 夏 end

            // 作業中ファイルのレイアウトデータを Excel ファイルへ保存する(失敗時は抜ける)
            if (!(e.Result = this.SaveExcelFileData()))
            {
                return;
            }

            // 作業中ファイルを保存する
            if (!(e.Result = RldLib.XlHelper.Save()))
            {
                return;
            }

            // add 2021-05-19 #4370:帳票データのアップロードに時間がかかる(ロードページの追加) 趙 start
                    // BUG #12556: 保存開始時のローディングは、操作中の 4 画面モニタへ表示する。
                    LoadingHelper.ShowLoadingDialog(this.GetVisibleDesignWindowOwner());
            // add 2021-05-19 #4370:帳票データのアップロードに時間がかかる(ロードページの追加) 趙 end

            try
            {
                if (e.IsWorkFile)
                {
                    // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 start
                    // upd 2021-04-14 #4105:帳票レイアウトデザイナーのレイアウト作成後の保存処理不正の修正 趙 start
                    //if (!SignInLib.SignIn.SignInInfo.FacilityCode.Equals(LayoutDesignerUtility.CurrentFacilityCd)) {
                    if (!string.IsNullOrEmpty(LayoutDesignerUtility.CurrentFacilityCd)
                        && "1".Equals(SignInLib.SignIn.SignInInfo.UserType)
                        && !SignInLib.SignIn.SignInInfo.FacilityCode.Equals(LayoutDesignerUtility.CurrentFacilityCd))
                    {
                        // upd 2021-04-14 #4105:帳票レイアウトデザイナーのレイアウト作成後の保存処理不正の修正 趙 end

                        string filePath = path.Replace(System.IO.Path.GetFileName(path), LayoutDesignerUtility.CurrentFacilityCd + "_" + LayoutDesignerUtility.CurrentFacilityName + ".temp");
                        if (!File.Exists(filePath))
                        {
                            FileStream fs = File.Create(filePath);
                            fs.Close();
                        }
                    }
                    // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 end
                    return;
                }

                // ワーク用帳票情報を作成
                var wTempReport = new MstReportData(RldLib.CurrentReport);
                // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
                if (e.IsSaveAs) wTempReport.ReportCode = long.MinValue;
                // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
                // add FNSI-699,700,751 装置帳票の記録簿対応 夏 start            
                if (wTempReport.ReportClass == 7)
                {
                    wTempReport.ReportType = RldLib.inspectionLayoutData.ReportType;
                    // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
                    if (wTempReport.ExtractionCondition == null)
                    {
                        wTempReport.ExtractionCondition = new Extraction();
                    }
                    wTempReport.ExtractionCondition.UseCD = RldLib.inspectionLayoutData.UseCD;
					// add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
                    if (wTempReport.ReportType == "0")
                    {
						// mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
                        //wTempReport.ExtractionCondition.UseCD = RldLib.inspectionLayoutData.UseCD;
                        //wTempReport.ExtractionCondition.RecordCD = RldLib.inspectionLayoutData.RecordCD;
                        //wTempReport.ExtractionCondition.LayoutCD = RldLib.inspectionLayoutData.LayoutCD;
                        wTempReport.ExtractionCondition.MachineTypeCD = RldLib.inspectionLayoutData.MachineTypeCD;
						// mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
                        //add 吉 装置帳票：定期・日常が分離されていない  start
                        var checkResult = Task.Run<Boolean>(async () => await this.ActionOfCheckpFile_InputReportInfo(wTempReport)).Result;
                        if (!checkResult)
                        {
                            checkRepeat = false;
                            // add #11116 単集計帳票の「レイアウト」タブの内容が保存されないことがある 高 start
                            e.Result = true;
                            e.IsCanceled = true;
                            // add #11116 単集計帳票の「レイアウト」タブの内容が保存されないことがある 高 end
                            return;
                        }
                        else
                        {
                            checkRepeat = true;
                        }
                        //add 吉 装置帳票：定期・日常が分離されていない  end
                    }
                    else
                    {
						// mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
                        //wTempReport.ExtractionCondition = null;
                        wTempReport.ExtractionCondition.MachineTypeCD = "";
						// mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
                    }
                }
                //add 2021-09-22 #6346 単一の患者の請求書を追加する 鄭 start
                else if (wTempReport.ReportClass == 2)
                {
                    if (RldLib.inspectionLayoutData.ReportType == "" || RldLib.inspectionLayoutData.ReportType == null)
                    {
                        wTempReport.ReportType = "1";
                    }
                    else
                    {
                        // mod #9967 治療記録画面では表示されるレポートが帳票プレビューではシステムエラーになる donghao start
                        //wTempReport.ReportType = RldLib.inspectionLayoutData.ReportType;
                        if (string.IsNullOrEmpty(RldLib.inspectionLayoutData.ReportType))
                        {
                            wTempReport.ReportType = "0";
                        }
                        else
                        {
                            wTempReport.ReportType = RldLib.inspectionLayoutData.ReportType;

                        }

                        // mod #9967 治療記録画面では表示されるレポートが帳票プレビューではシステムエラーになる donghao end

                    }

                }
                // add  #5714 紹介状が正しく出力できない 孟堅 start 
                else if (wTempReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_REFERRAL_LETTER)
                {
                    if (RldLib.totalLayoutData.ReportType == "" || RldLib.totalLayoutData.ReportType == null)
                    {
                        wTempReport.ReportType = "2";
                    }
                    else
                    {
                        // mod #9967 治療記録画面では表示されるレポートが帳票プレビューではシステムエラーになる donghao start
                        // mod #10092 新規作成した集計紹介状の集計設定がオンライン保存しても有効にならない 高 start
                        //wTempReport.ReportType = RldLib.inspectionLayoutData.ReportType;
                        //if (string.IsNullOrEmpty(RldLib.inspectionLayoutData.ReportType))
                        //{
                        //    wTempReport.ReportType = "0";
                        //}
                        //else
                        //{
                        //    wTempReport.ReportType = RldLib.inspectionLayoutData.ReportType;

                        //}
                        wTempReport.ReportType = RldLib.totalLayoutData.ReportType;
                        // mod #10092 新規作成した集計紹介状の集計設定がオンライン保存しても有効にならない 高 end

                        // mod #9967 治療記録画面では表示されるレポートが帳票プレビューではシステムエラーになる donghao end
                    }
                }
                // add #5714 紹介状が正しく出力できない 孟堅 end
                //add 2021-09-22 #6346 単一の患者の請求書を追加する 鄭 end
                // mod 単一集計帳票／複数集計帳票：帳票分類コンボボックスの追加 鄧シン  start
                //else
                else if (wTempReport.ReportClass != 10 && wTempReport.ReportClass != 11)
                // mod 単一集計帳票／複数集計帳票：帳票分類コンボボックスの追加 鄧シン  end
                {
                    // mod #9967 治療記録画面では表示されるレポートが帳票プレビューではシステムエラーになる donghao start
                    //wTempReport.ReportType = null;
                    wTempReport.ReportType = "0";
                    // mod #9967 治療記録画面では表示されるレポートが帳票プレビューではシステムエラーになる donghao end
                    wTempReport.ExtractionCondition = null;
                }
                //add 6608 2次元帳票excel エクスポート 吉 start
                else if (wTempReport.ReportClass == 10 || wTempReport.ReportClass == 11)
                {
                    // del #10983 mst_report の未使用カラム「multi_total_defaul」を廃止 limingzhe start
                    //wTempReport.MultiTotalDefaul = RldLib.totalLayoutData.MultiTotalDefaul;
                    // del #10983 mst_report の未使用カラム「multi_total_defaul」を廃止 limingzhe end
                    // add 2022-09-23 #7844 帳票（複数集計）：結合したセルに集計項目を設定すると、アップロードできない  孟堅 start
                    wTempReport.ReportType = RldLib.totalLayoutData.ReportType;
                    // add 2022-09-23 #7844 帳票（複数集計）：結合したセルに集計項目を設定すると、アップロードできない  孟堅  end
                    // add Aspose.cells関連問題8の対応 夏 start
                    if (wTempReport.ReportClass == 11 && string.IsNullOrEmpty(wTempReport.ReportType))
                    {
                        if (RldLib.totalLayoutData.UnitH.IndexOf("bed_name") >= 0)
                        {
                            wTempReport.ReportType = "1";
                        }
                        else if (RldLib.totalLayoutData.UnitH.IndexOf("supplies_name") >= 0)
                        {
                            wTempReport.ReportType = "2";
                        }
                        else if (RldLib.totalLayoutData.UnitH.IndexOf("point_name") >= 0)
                        {
                            wTempReport.ReportType = "3";
                        }
                        else
                        { 
                            // mod #9967 治療記録画面では表示されるレポートが帳票プレビューではシステムエラーになる donghao end
                            //wTempReport.ReportType = "";
                            wTempReport.ReportType = "0";
                            // mod #9967 治療記録画面では表示されるレポートが帳票プレビューではシステムエラーになる donghao end
                        }
                    }
                    // add Aspose.cells関連問題8の対応 夏 start
                }
                // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
                if ((wTempReport.ExtractionCondition is null) == false && (wTempReport.ExtractionCondition.UseCD.Equals("") || wTempReport.ExtractionCondition.UseCD.Equals("0")))
                {
                    wTempReport.ExtractionCondition = null;
                }
                // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
                //add 6608 2次元帳票excel エクスポート 吉 end
                // add FNSI-699,700,751 装置帳票の記録簿対応 夏 end
                //add 8579 【デグレ】レイアウトデザイナーにてアップロードができない 邾 start
                //LoadingHelper.CloseLoadingDialog();
                //add 8579 【デグレ】レイアウトデザイナーにてアップロードができない 邾 end
                // 帳票情報入力
                bool wIsCanceled = true;
                if (!(e.Result = this.ActionOfSaveDropFile_InputReportInfo(ref wTempReport, ref wIsCanceled)))
                {
                    return;
                }

                // キャンセルした場合は抜ける
                if (wIsCanceled)
                {
                    // add #9398 「オンラインで保存」の通常保存時は「新規登録」の時のみ「帳票保存設定」が出るようにすること donghao start
                    blCancel = true;
                    // add #9398 「オンラインで保存」の通常保存時は「新規登録」の時のみ「帳票保存設定」が出るようにすること donghao end
                    e.Result = true;
                    e.IsCanceled = true;
                    return;
                }
                //add 8579 【デグレ】レイアウトデザイナーにてアップロードができない 邾 start
                //LoadingHelper.ShowLoadingDialog();
                //add 8579 【デグレ】レイアウトデザイナーにてアップロードができない 邾 end
                // ここから正式な保存処理開始
                // TODO: 場合によってはステータスウィンドウの表示に切り替える

                // エクセルを非表示にする
                RldLib.XlHelper.XlApp.Application.Visible = false;


                // 一時帳票保存先ディレクトリを取得
                string wTempDirPath = RldLib.GetTempXlsDirPath() + System.IO.Path.DirectorySeparatorChar;
                // 前回作業時ファイルがある場合は削除
                RldLib.ClearTempXlsDirPath();

                // mod 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 start
                //// 新規作成帳票の場合
                //if (e.IsSaveAs)

                // 帳票更新履歴配列
                HstInfo reportHstInfo = new HstInfo();

                // 新しい帳票更新履歴の版数を初期化する
                long ctlNo = 0L;

                // 新しい帳票名(3ファイルのフルパス)を作成する
                // mod 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 end
                {

                    // オープン中のファイルパスから拡張子を取得(ファイルは作業用ディレクトリ内に保存されている)
                    string wFileExt = System.IO.Path.GetExtension(RldLib.XlHelper.XlBookFilePath);

                    // ファイル名を作成
                    var wFileName = $"{RldLib.ConvertReportClassInt32ToString(wTempReport.ReportClass)}_{DateTime.Now.ToString("yyyyMMddHHmmss")}";

                    // add #7922 新規施設のデフォルト帳票に作成者・更新者が登録されている / デフォルト帳票が編集できない 商 start
                    if (wFileName.StartsWith("_"))
                    {
                        wFileName = wFileName.Substring(1);
                    }
                    // add #7922 新規施設のデフォルト帳票に作成者・更新者が登録されている / デフォルト帳票が編集できない 商 end

                    // 帳票情報を更新
                    wTempReport.ReportPath.S3Bucket = "";
                    wTempReport.ReportPath.ExcelFileName = $"{wFileName}{wFileExt}";
                    wTempReport.ReportPath.HtmlFileName = $"{wFileName}.html";
                    wTempReport.ReportPath.XmlFileName = $"{wFileName}.xml";
                    wTempReport.ReportPath.ZipExcelFileName = $"{wFileName}_Excel.zip";
                    wTempReport.ReportPath.ZipReportFileName = $"{wFileName}_Report.zip";
                    if (!RldUtility.UseS3Bucket)
                    {
                        wTempReport.ReportPath.S3Bucket = wTempReport.ReportPath.S3Bucket.Replace('/', System.IO.Path.DirectorySeparatorChar);
                    }
                }

                // del 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 start
                //// add 2020-10-07 FNSI-仕様追加 帳票更新者情報を追加する 李 start
                //wTempReport.UpdateUser = NKKWebAccess.UserId;
                //// add 2020-10-07 FNSI-仕様追加 帳票更新者情報を追加する 李 end
                // del 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 end

                // Step.1 クライアント内保存帳票(Amazon S3用)として保存する(失敗時は抜ける)
                if (!(e.Result = RldLib.XlHelper.Save($"{wTempDirPath}{wTempReport.ReportPath.ExcelFileName}")))
                {
                    e.ResultMessage = "アップロード用 Excel ファイルの保存に失敗しました。";
                    return;
                }

                // セル幅を記録する
                foreach (var wData in RldLib.CurrentLayoutData.DesignParamList)
                {

                    using (var wXlRange = new ExcelRangeEx(RldLib.XlHelper.XlSheetLayout, wData.CellAddress))
                    {
                        // セル幅
                        wData.CellWidth = (int)wXlRange.GetWidth();
                        // add #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
                        // セル幅
                        wData.CellHeight = (int)wXlRange.GetHeight();
                        // add #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
                    }
                }

                // HTML ファイル生成処理
                {
                    // HTML ファイル操作ヘルパークラスを生成(現在開いている Excel ファイルは閉じる)
                    var wHtmlHelper = new RldExcelHtmlHelper(RldLib.XlHelper, RldLib.CurrentLayoutData);

                    // Step.2 HTML ファイルを生成(失敗した場合は抜ける)
                    if (!(e.Result = wHtmlHelper.Create($"{wTempDirPath}{wTempReport.ReportPath.HtmlFileName}")))
                    {
                        e.ResultMessage = "アップロード用 HTML ファイルの作成に失敗しました。";
                        return;
                    }

                    // Step.3 HTML ファイルを保存
                    if (!(e.Result = wHtmlHelper.Save()))
                    {
                        e.ResultMessage = "アップロード用 HTML ファイルの保存に失敗しました。";
                        return;
                    }
                }

                // 帳票定義ファイル生成処理
                {
                    // 帳票定義ファイル作成用ヘルパークラスを生成
                    var wRdfHelper = new RldReportDefineFileHelper();

                    // Step.4 帳票定義ファイル用データを作成
                    if (!(e.Result = wRdfHelper.CreateData(RldLib.CurrentLayoutData)))
                    {
                        e.ResultMessage = "アップロード用帳票定義ファイルの作成に失敗しました。";
                        return;
                    }

                    // Step.5 帳票定義ファイルを保存
                    if (!(e.Result = wRdfHelper.Save($"{wTempDirPath}{wTempReport.ReportPath.XmlFileName}")))
                    {
                        e.ResultMessage = "アップロード用帳票定義ファイルの保存に失敗しました。";
                        return;
                    }
                }

                // Step.6 Amazon S3 へのアップロード準備処理
                if (!(e.Result = this.ActionOfSaveDropFile_MakeUploadFiles(wTempDirPath, wTempReport.ReportPath)))
                {
                    e.ResultMessage = "アップロード用ファイルの作成・保存に失敗しました。";
                    return;
                }

                // Step.7 Amazon S3 へアップロード処理
                var wResUploadOtherFacilityCd = Task.Run<KeyValuePair<Boolean, String>>(async () => await this.ActionOfSaveDropFile_UploadFilesOtherFacilityCd(wTempDirPath, wTempReport.ReportPath, "")).Result;
                if (!(e.Result = wResUploadOtherFacilityCd.Key))
                {
                    e.ResultMessage = "アップロードに失敗しました。\r\n" + wResUploadOtherFacilityCd.Value;
                    return;
                }

                // Step.8 RDS 更新処理
                // テンプレート繰り返しありならば列数, 行数, 印刷方向をセットする
                if (RldLib.CurrentLayoutData.DesignSettingData.HasTemplete.Equals(RldConst.SettingData.VAL_HAS_TEMPLETE_YES))
                {

                    int result;
                    AdditionalInfo info;
                    if (wTempReport.AdditionalInfo is null)
                    {
                        // AdditionalInfoがNullならば生成する
                        info = new AdditionalInfo();
                        wTempReport.AdditionalInfo = info;
                    }
                    else
                    {
                        info = wTempReport.AdditionalInfo;
                    }

                    // 列数セット
                    if (int.TryParse(RldLib.CurrentLayoutData.DesignTempleteData.RepeatCountH, out result))
                    {
                        // 横方向への繰り返し回数をcol_countに設定する
                        info.ColCount = result;
                    }

                    // 行数セット
                    if (int.TryParse(RldLib.CurrentLayoutData.DesignTempleteData.RepeatCountV, out result))
                    {
                        // 縦方向への繰り返し回数をrow_countに設定する
                        info.RowCount = result;
                    }

                    // 印刷方向
                    // N型ならば0, Z型ならば1
                    info.PrintDirection = RldLib.CurrentLayoutData.DesignTempleteData.DirectionData.Equals(RldConst.TempleteData.VAL_DIRECTION_N) ? 0 : 1;

                }

                var wResUpdateRDSOtherFacilityCd = Task.Run(async () => await this.ActionOfSaveDropFile_DataUpdateOtherFacilityCd(wTempReport, e.IsSaveAs, "")).Result;
                if (!(e.Result = wResUpdateRDSOtherFacilityCd.Key))
                {
                    e.ResultMessage = "データ更新に失敗しました。\r\n" + wResUpdateRDSOtherFacilityCd.Value;
                    return;
                }

                // 作業用ファイルは削除してもよい                
                this.MustDeleteWorkFile = true;
                // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 start
                string[] name = Directory.GetFiles(path.Replace(System.IO.Path.GetFileName(path), ""), "*.temp");
                if (name.Length > 0)
                {
                    for (int i = 0; i < name.Length; i++)
                    {
                        if (!String.IsNullOrEmpty(name[i]))
                        {
                            File.Delete(name[i]);
                        }
                    }
                }
                // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 end
            }
            finally
            {
                // add 2021-05-19 #4370:帳票データのアップロードに時間がかかる(ロードページの追加) 趙 start
                LoadingHelper.CloseLoadingDialog();
                // add 2021-05-19 #4370:帳票データのアップロードに時間がかかる(ロードページの追加) 趙 end

                // 途中でエラーが発生した場合は エラーメッセージを表示する
                if (!e.Result && !e.IsWorkFile)
                {
                    var wText = new System.Text.StringBuilder() { Length = 0 };
                    wText.AppendLine("帳票デザインファイルの保存処理でエラーが発生しました。");
                    wText.AppendLine("今回の編集内容は一時帳票ファイルに保存されます。");
                    // mod #5964 ログインIDがタイムアウトになった場合の動作について 王永吉 start
                    // mod 2021-09-14 #5964:プロンプトボックスの内容を変更する 鄭 start
                    // wText.AppendFormat("({0})", e.ResultMessage);
                    // wText.AppendFormat("({0})", e.ResultMessage.Replace("<BR>", "\r\n").Replace("<br>", "\r\n"));
                    // mod 2021-09-14 #5964:プロンプトボックスの内容を変更する 鄭 end
                    string keyDoWord = "useResponseMessage =";
                    bool isContains = e.ResultMessage.ToLower().Contains(keyDoWord.ToLower());
                    if (isContains)
                    {
                        string doStr = e.ResultMessage.Replace("\r\n" + keyDoWord, "").Replace(" ", "").Replace("=", "").Replace("'", "")
                                                  .Replace("<BR>", "折-返").Replace("<br>", "折-返").Replace("\r\n", "折-返");
                        string doMStr = Regex.Replace(doStr, "[A-Za-z]", "", RegexOptions.IgnoreCase).Replace("折-返", "\r\n");
                        e.ResultMessage = doMStr;
                        wText.AppendFormat("({0})", e.ResultMessage);
                    }
                    else
                    {
                        wText.AppendFormat("({0})", e.ResultMessage.Replace("<BR>", "\r\n").Replace("<br>", "\r\n"));
                    }

                    // mod #5964 ログインIDがタイムアウトになった場合の動作について 王永吉 end
                    // del 2021-09-02 #6730: 鄭 start
                    //this.ActionOfRequestShowMsgBox(
                    //    this,
                    //    new RldDesignNotifyInfoRequestShowMessageEventArgs()
                    //    {
                    //        Text = wText.ToString(),
                    //        Caption = "確認してください",
                    //        Buttons = MessageBoxButtons.OK,
                    //        Icon = MessageBoxIcon.Error
                    //    });
                    // del 2021-09-02 #6730: 鄭 end

                    if (!string.IsNullOrEmpty(LayoutDesignerUtility.CurrentFacilityCd)
                    && "1".Equals(SignInLib.SignIn.SignInInfo.UserType)
                    && !SignInLib.SignIn.SignInInfo.FacilityCode.Equals(LayoutDesignerUtility.CurrentFacilityCd))
                    {
                        // upd 2021-04-14 #4105:帳票レイアウトデザイナーのレイアウト作成後の保存処理不正の修正 趙 end

                        string filePath = path.Replace(System.IO.Path.GetFileName(path), LayoutDesignerUtility.CurrentFacilityCd + "_" + LayoutDesignerUtility.CurrentFacilityName + ".temp");
                        if (!File.Exists(filePath))
                        {
                            FileStream fs = File.Create(filePath);
                            fs.Close();
                        }
                    }

                    // add 2021-09-02 #6730:プロンプトボックスを追加 鄭 start
                    // BUG #12556: 親画面からの確認メッセージも、編集中のモニタへ固定する。
                    MessageBox.Show(this.GetVisibleDesignWindowOwner(), wText.ToString(), "確認してください");
                    // add #5964 ログインIDがタイムアウトになった場合の動作について 王永吉 start
                    if (isContains)
                    {
                        DoFlag = true;
                    }
                    else
                    {
                        // add #5964 ログインIDがタイムアウトになった場合の動作について 王永吉 end
                        // BUG #12556: タイムアウト後の継続確認も現在の 4 画面モニタで応答させる。
                        if (RldMsgBox.Show(this.GetVisibleDesignWindowOwner(), "作業中のファイルがあります。続行しますか", @"確認してください", System.Windows.Forms.MessageBoxButtons.YesNo, System.Windows.Forms.MessageBoxIcon.Question) == System.Windows.Forms.DialogResult.Yes)
                        {
                            ErrorMessage = true;
                        }
                        // add #5964 ログインIDがタイムアウトになった場合の動作について 王永吉 start
                    }
                    // add #5964 ログインIDがタイムアウトになった場合の動作について 王永吉 end
                    // add  2021-09-02 #6730:プロンプトボックスを追加 鄭 end


                }
            }
        }

        ///// <summary>
        ///// ファイル保存/破棄要求受信時処理(整合性確認処理)を行います。
        ///// </summary>
        ///// <returns></returns>
        //private Boolean ActionOfSaveDropFile_DataCheck()
        //{
        //    Boolean wRet = false;

        //    LayoutDataSetChecker wChecker = null;
        //    try {
        //        // 対話モードを一時停止
        //        RldLib.XlHelper.XlApp.Application.Interactive = false;

        //        wChecker = new LayoutDataSetChecker(RldLib.CurrentLayoutData, RldLib.XlHelper);

        //        // エラーメッセージ受信用イベントハンドラ割り当て
        //        wChecker.NotifyInfo += new EventHandler<RldDesignNotifyInfoEventArgs>(this.ColleagueMessageHandler);
        //        // 整合性を確認
        //        wRet = wChecker.CheckConsistency();
        //    }
        //    catch( Exception ex ) {

        //    }
        //    finally {
        //        if( wChecker != null ) {
        //            // エラーメッセージ受信用イベントハンドラ割り当て解除
        //            wChecker.NotifyInfo -= new EventHandler<RldDesignNotifyInfoEventArgs>(this.ColleagueMessageHandler);
        //            wChecker = null;
        //        }

        //        // 対話モードを戻す
        //        if( !RldLib.XlHelper.XlApp.Application.Interactive )
        //            RldLib.XlHelper.XlApp.Application.Interactive = true;
        //    }

        //    return wRet;
        //}

        /// <summary>
        /// ファイル保存/破棄要求受信時処理(帳票設定入力処理)を行います。
        /// </summary>
        /// <param name="aData"></param>
        /// <param name="aIsCancel"></param>
        /// <returns></returns>
        private bool ActionOfSaveDropFile_InputReportInfo(ref MstReportData aData, ref bool aIsCancel)
        {
            bool wRet = false;
            // 帳票保存設定画面を表示
            using (var wForm = new frmInputSavingReportInfo())
            {
                //add #8559 動作に関する指摘２ 邾 start
                if (sReportName == "")
                {
                    wForm.InputReportName = aData.ReportName;
                }
                else
                {
                    wForm.InputReportName = sReportName;
                }
                //add #8559 動作に関する指摘２ 邾 end
                // mod #12481 非表示状態の帳票を編集して名前をつけて保存しても非表示のまま） 高 start
                //wForm.IsDisplay = aData.IsDisplay == MstReportData.VAL_IS_DISPLAY_NONE ? false : true;
                wForm.IsDisplay = true;
                // mod #12481 非表示状態の帳票を編集して名前をつけて保存しても非表示のまま） 高 end

                var wEventArgs = new RldDesignNotifyInfoRequestOpenDialogEventArgs(wForm)
                {
                    IsAllWindowLock = true,
                    IsProtectLayoutSheet = true
                };

                // add #9398 「オンラインで保存」の通常保存時は「新規登録」の時のみ「帳票保存設定」が出るようにすること donghao start
                // mod #11116 単集計帳票の「レイアウト」タブの内容が保存されないことがある 高 start
                //bool wRes = Task<Boolean>.Run(async () => await this.GetEditingReportInfo()).Result;
                bool wRes = Task<Boolean>.Run(async () => await this.GetEditingReportInfo(false)).Result;
                // mod #11116 単集計帳票の「レイアウト」タブの内容が保存されないことがある 高 end

                blWes = wRes;

                if (wRes && !string.IsNullOrEmpty(RldLib.CurrentLayoutData.DesignSettingData.ReportCode))
                {

                    if (!frmMainMenuChildMakeReport.sinkiFlg)
                    {
                        if (frmDesignChildDataList.blMnuFilesaveOnlineSave || frmDesignChildDataList.blMnuFileSaveOnlineReturn || frmDesignChildDataList.blMnuFileSaveOnlineExit)
                        {
                            // add #9398 「オンラインで保存」の通常保存時は「新規登録」の時のみ「帳票保存設定」が出るようにすること dongzhaolong end
                            if (!string.IsNullOrEmpty(sReportName))
                            {
                                aData.ReportName = sReportName;
                            }
                            // add #9398 「オンラインで保存」の通常保存時は「新規登録」の時のみ「帳票保存設定」が出るようにすること dongzhaolong end
                            aIsCancel = false;
                            return true;
                        }
                    }
                }
                // add #9398 「オンラインで保存」の通常保存時は「新規登録」の時のみ「帳票保存設定」が出るようにすること donghao end

                LoadingHelper.CloseLoadingDialog();
                // 画面を表示
                this.ActionOfRequestOpenDialog(this, wEventArgs);

                // OKボタンクリック時
                if (wForm.DialogResult == DialogResult.OK)
                {
                    // 入力内容を取得
                    aData.ReportName = wForm.InputReportName;
                    //add #8559 動作に関する指摘２ 邾 start
                    sReportName = wForm.InputReportName;
                    //add #8559 動作に関する指摘２ 邾 end
                    aData.IsDisplay = wForm.IsDisplay ? MstReportData.VAL_IS_DISPLAY_DONE : MstReportData.VAL_IS_DISPLAY_NONE;
                    // add #11501 レイアウトデザイナのユーザビリティ改善 高 start
                    string editFileName = "編集中：" + aData.ReportName;
                    setChildDataListFileName(editFileName);
                    // add #11501 レイアウトデザイナのユーザビリティ改善 高 end
                    // add #12481 非表示状態の帳票を編集して名前をつけて保存しても非表示のまま） 高 start
                    RldLib.CurrentReport.IsDisplay = aData.IsDisplay;
                    // add #12481 非表示状態の帳票を編集して名前をつけて保存しても非表示のまま） 高 end
                }

                // BUG #12556: 別施設コード保存時のローディングも、操作中モニタへ表示する。
                LoadingHelper.ShowLoadingDialog(this.GetVisibleDesignWindowOwner());

                wRet = true;
                aIsCancel = !(wForm.DialogResult == DialogResult.OK);
            }

            return wRet;
        }
        //add 吉 装置帳票：定期・日常が分離されていない  start
        private async Task<bool> ActionOfCheckpFile_InputReportInfo(MstReportData aData)
        {
            var result = await RldLib.checkRepeat(aData);
            MstReportData reportInfo = result;
            if (null != result)
            {
                // BUG #12556: 上書き確認は parent ではなく現在の 4 画面 owner に紐付けて表示する。
				// mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
                //DialogResult dialogResult = RldMessageBox.Show(this.GetVisibleDesignWindowOwner(), "すでに帳票が紐づいているレイアウトを指定しています。上書きしますか？", "レイアウト確認", MessageBoxButtons.YesNo, MessageBoxIcon.Question);
                DialogResult dialogResult = RldMessageBox.Show(
                    this.GetVisibleDesignWindowOwner(), 
                    "選択された型式で「固定帳票専用」に設定された帳票が既に存在します。既存帳票を「汎用帳票」に変更し、本帳票を固定帳票専用として保存しますか？",
                    "設定確認", 
                    MessageBoxButtons.YesNo, 
                    MessageBoxIcon.Question
                );
				// mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
                if (dialogResult == DialogResult.Yes)
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
            else
            {
                return true;
            }
        }
        //add 吉 装置帳票：定期・日常が分離されていない  end
        /// <summary>
        /// ファイル保存/破棄要求受信時処理(アップロード用ファイル作成処理)を行います。
        /// </summary>
        /// <param name="aTempDirPath">作業用フォルダ名</param>
        /// <param name="reportPath">3ファイルのパス</param>
        /// <returns></returns>
        private bool ActionOfSaveDropFile_MakeUploadFiles(string aTempDirPath, MstReportData.Path reportPath)
        {

            bool wRet = false;

            try
            {

                // xlsx ファイルを一つの圧縮ファイルへ
                // 指定したパスとモードで zip アーカイブを開きます。
                // 既にある帳票ファイルを編集で開いた時に3ファイルのパスにExcel圧縮ファイル名が指定されていなければ、reportPath.ZipExcelFileNameは空文字になる
                if (!string.IsNullOrEmpty(reportPath.ZipExcelFileName))
                {
                    // xlsx ファイルを一つの圧縮ファイルへ
                    // 指定したパスとモードで zip アーカイブを開きます。
                    using (var wFile = ZipFile.Open($"{aTempDirPath}{reportPath.ZipExcelFileName}", ZipArchiveMode.Update))
                    {
                        // 圧縮し、zip アーカイブに追加することでファイルをアーカイブします
                        wFile.CreateEntryFromFile($"{aTempDirPath}{reportPath.ExcelFileName}", reportPath.ExcelFileName);
                    }
                }

                // html 関連ファイルと xml ファイルを一つの圧縮ファイルへ
                // 指定したパスとモードで zip アーカイブを開きます。
                using (var wFile = ZipFile.Open($"{aTempDirPath}{reportPath.ZipReportFileName}", ZipArchiveMode.Update))
                {

                    // xlsx ファイルを追加
                    // 圧縮し、zip アーカイブに追加することでファイルをアーカイブします
                    _ = wFile.CreateEntryFromFile($"{aTempDirPath}{reportPath.ExcelFileName}", reportPath.ExcelFileName);

                    // xml ファイルを追加
                    // 圧縮し、zip アーカイブに追加することでファイルをアーカイブします
                    _ = wFile.CreateEntryFromFile($"{aTempDirPath}{reportPath.XmlFileName}", reportPath.XmlFileName);

                    // html ファイルを追加
                    // 圧縮し、zip アーカイブに追加することでファイルをアーカイブします
                    _ = wFile.CreateEntryFromFile($"{aTempDirPath}{reportPath.HtmlFileName}", reportPath.HtmlFileName);

                    // html 関連ファイルを追加
                    // "htmlファイル名" + ".files" というフォルダが生成される
                    var wHtmlDirPath = aTempDirPath + System.IO.Path.GetFileNameWithoutExtension(reportPath.HtmlFileName) + ".files";
                    if (System.IO.Directory.Exists(wHtmlDirPath))
                    {
                        foreach (var wFilePath in System.IO.Directory.GetFiles(wHtmlDirPath))
                        {
                            _ = wFile.CreateEntryFromFile(wFilePath, wFilePath.Replace(wHtmlDirPath + @"\", string.Empty));
                        }
                    }

                }

                // ここまでくればOK
                wRet = true;

            }
            catch (Exception ex)
            {
                // 例外情報を記録する
                RldUtility.RecordException(ex, false);
            }

            return wRet;

        }

        // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 start
        /// <summary>
        /// ファイル保存/破棄要求受信時処理(アップロード処理)を行います。
        /// </summary>
        /// <param name="aTempDirPath"></param>
        /// <param name="reportPath"></param>
        /// <returns></returns>
        private async Task<KeyValuePair<bool, string>> ActionOfSaveDropFile_UploadFilesOtherFacilityCd(string aTempDirPath, MstReportData.Path reportPath, String newS3Path)
        {
            var wRet = new KeyValuePair<bool, string>();
            var wFileList = new List<string>();

            try
            {
                // アップロードファイルリストを生成
                void addFileName(string fileName)
                {
                    if (!string.IsNullOrEmpty(fileName))
                    {
                        wFileList.Add($"{aTempDirPath}{fileName}");
                    }
                }
                addFileName(reportPath.ZipExcelFileName);
                addFileName(reportPath.ZipReportFileName);

                // アップロードを実行
                bool wResValue = true;
                string wResText = string.Empty;
                if (wFileList.Count > 0)
                {

                    // Amazon S3 ヘルパークラスを生成
                    var wHelper = new RldAmazonS3Helper()
                    {
                        UseS3Bucket = RldUtility.UseS3Bucket,
                        S3Bucket = newS3Path,
                        FacilityCode = LayoutDesignerUtility.CurrentFacilityCd
                    };

                    wResValue = await wHelper.UploadFileOtherFacilityCd(wFileList);
                    wResText = wHelper.LastErrorMessage;

                }

                // 処理結果を戻り値にセット
                wRet = new KeyValuePair<bool, string>(wResValue, wResText);

            }
            catch (Exception ex)
            {
                // TODO:
            }

            return wRet;

        }

        /// <summary>
        /// ファイル保存/破棄要求受信時処理(RDS更新処理)を行います。
        /// </summary>
        /// <param name="aData">帳票マスタに書き込むデータ</param>
        /// <param name="isSaveAs">名前を付けて保存する場合 True。そうでない場合 False。</param>
        /// <param name="newS3Path"></param>
        /// <returns></returns>
        private async Task<KeyValuePair<bool, string>> ActionOfSaveDropFile_DataUpdateOtherFacilityCd(MstReportData aData, bool isSaveAs, String newS3Path)
        {
            bool aIsAddNew = ((aData.ReportCode == long.MinValue) || isSaveAs) ? true : false;
            return await RldLib.PutMstReportDataOtherFacilityCd(aData, aIsAddNew, newS3Path);
        }

        #endregion

        #endregion

        private void FrmDesignParent_Resize(object sender, EventArgs e)
        {
            try
            {
                switch (this.WindowState)
                {
                    case FormWindowState.Normal:
                        RldLib.XlHelper.XlApp.Application.WindowState = Microsoft.Office.Interop.Excel.XlWindowState.xlNormal;
                        // このフォームをアクティブにする。Excelのサイズを元の大きさに戻すとExcelにフォーカスが移動し、結果タスクバーのアイコンをクリックしても1回目のクリックで最小化しなくなる。
                        this.Activate();
                        break;
                    case FormWindowState.Minimized:
                        RldLib.XlHelper.XlApp.Application.WindowState = Microsoft.Office.Interop.Excel.XlWindowState.xlMinimized;
                        break;
                    case FormWindowState.Maximized:
                        RldLib.XlHelper.XlApp.Application.WindowState = Microsoft.Office.Interop.Excel.XlWindowState.xlMaximized;
                        break;
                    default:
                        break;
                }

            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }
        }

        private void frmDesignParent_Load(object sender, EventArgs e)
        {

            try
            {

                // 自身のオーナーに設定してExcelの子ウインドウを開く
                var ownerForm = new Form
                {
                    Width = 0,
                    Height = 0,
                    Opacity = 0
                };
                var frm = (Form)sender;
                frm.Owner = ownerForm;

                // NativeWindowにExcelのハンドルを割り当てる
                var nw = new NativeWindow();
                nw.AssignHandle((IntPtr)RldLib.XlHelper.XlApp.Application.Hwnd);
                ownerForm.Show(nw);
                ownerForm.Visible = false;

            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }

        }

        private void frmDesignParent_FormClosed(object sender, FormClosedEventArgs e)
        {

            try
            {

                // Formを閉じる
                void closeForm(Form form)
                {
                    form.Close();
                }

                // 自身のオーナーフォームを非同期で閉じる
                // 非同期で閉じないとSystem.StackOverflowException例外が発生する
                var ownerForm = ((Form)sender).Owner;
                if (ownerForm != null)
                {
                    ownerForm.BeginInvoke(new Action<Form>(closeForm), new Form[] { ownerForm });
                }

            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }
        }
        // add #11501 レイアウトデザイナのユーザビリティ改善 高 start
        private void setChildDataListFileName(string editFileName)
        {
            var wColleagues = this.m_Colleagues.SingleOrDefault(ele => ele.GetType() == typeof(frmDesignChildDataList));
            if (wColleagues != null)
            {
                frmDesignChildDataList childDataList = (frmDesignChildDataList)wColleagues;
                if (childDataList != null)
                {
                    childDataList.setCurrentFileName(editFileName);
                }
            }
        }
        // add #11501 レイアウトデザイナのユーザビリティ改善 高 end

        // add #12026 帳票移植時にフィルタ設定が無効化する（初期対応） 高 start
        // mod #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 start
        // if code is not find, compare name and set code of same name in FilterData
        //private void createExamItemFilterData()
        private void createItemFilterData()
        {
            int cntErrTotal = 0;
            int cntCovert = 0;
            bool bOutMsg = false;

            // convert code, set code of same name to paramter list
            setParamItemCodeName(ref cntErrTotal, ref cntCovert, ref bOutMsg);

            // convert code, set code of same name to group list
            setGroupItemCodeName(ref cntErrTotal, ref cntCovert, ref bOutMsg);

            if (bOutMsg)
            {
                string MSG_TITLE = "フィルタコード補正完了";
                string Msg_Content = string.Format("{0}件のフィルタ設定で無効なコードを検知しました。名称一致によるコード置き換えまたは設定のクリアを行いました（置換{1}件）。設定を再確認し、有効にする場合はオンライン保存を行ってください。", cntErrTotal, cntCovert);
                RldMsgBox.Show(this, Msg_Content, MSG_TITLE, MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
            }
        }

        // set code in FilterData,
        // if not find same code, find name, if not exist, return, else set code
        private void setParamItemCodeName(ref int cntErrTotal, ref int cntCovert, ref bool bOutMsg)
        {
            int cntTotal = 0;
            int cntNotName = 0;
            bool IsInspection = false;

            // loop パラメータ編集データ
            foreach (var wData in RldLib.CurrentLayoutData.DesignParamList)
            {
                // フィルタが未設定の場合は抜ける
                if (String.IsNullOrEmpty(wData.FilterType) || String.IsNullOrEmpty(wData.FilterData)) continue;

                // フィルタ種別 - 検査項目
                if (wData.FilterType != RldConst.FilterType.Group.EXAMINE
                    && wData.FilterType != RldConst.FilterType.Group.EXAM_SET
                    && wData.FilterType != RldConst.FilterType.Group.INSPECTION
                    // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
                    && wData.FilterType != RldConst.FilterType.Group.WQTESTPOINT
                   // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end
                   )
                {
                    continue;
                }

                // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
                if (wData.FilterType == RldConst.FilterType.Group.INSPECTION)
                {
                    using (var wDlg = new frmSelectMainteFilter())
                    {
                        switch (wData.FilterType)
                        {
                            case RldConst.FilterType.Group.INSPECTION:
                                wDlg.FilterType = frmSelectMainteFilter.EnumFilterType.Inspection;
                                break;
                            default:
                                break;
                        }
                        wDlg.FilterData = wData.FilterData;
                        wDlg.clsFilterData = false;
                        wDlg.cntTotal = cntTotal;
                        wDlg.cntNotName = cntNotName;
                        wDlg.cntErrTotal = cntErrTotal;
                        wDlg.cntCovert = cntCovert;
                        wDlg.IsInspection = IsInspection;

                        wDlg.setItemCodeName();

                        if (wDlg.clsFilterData)
                        {
                            wData.FilterData = string.Empty;
                            wData.FilterState = RldConst.ParamData.VAL_FILTER_STATE_NO;
                        }
                        else
                        {
                            if (wData.FilterData != wDlg.FilterData)
                                wData.FilterData = wDlg.FilterData;
                        }

                        cntTotal = wDlg.cntTotal;
                        cntNotName = wDlg.cntNotName;
                        cntErrTotal = wDlg.cntErrTotal;
                        cntCovert = wDlg.cntCovert;
                        IsInspection = wDlg.IsInspection;
                    }
                }
                else
                {
                    // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
                    using (var wDlg = new frmSelectExamFilter())
                    {
                        switch (wData.FilterType)
                        {
                            case RldConst.FilterType.Group.EXAMINE:
                                wDlg.FilterType = frmSelectExamFilter.EnumFilterType.ExaminItem;
                                break;
                            case RldConst.FilterType.Group.EXAM_SET:
                                wDlg.FilterType = frmSelectExamFilter.EnumFilterType.ExaminSet;
                                break;
                            // del #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
                            //case RldConst.FilterType.Group.INSPECTION:
                            //    wDlg.FilterType = frmSelectExamFilter.EnumFilterType.Inspection;
                            //    break;
                            // del #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
                            // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
                            case RldConst.FilterType.Group.WQTESTPOINT:   // 水質検査
                                wDlg.FilterType = frmSelectExamFilter.EnumFilterType.WQTestPoint;
                                break;
                            // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end
                            default:
                                break;
                        }
                        wDlg.FilterData = wData.FilterData;
                        wDlg.clsFilterData = false;
                        wDlg.cntTotal = cntTotal;
                        wDlg.cntNotName = cntNotName;
                        wDlg.cntErrTotal = cntErrTotal;
                        wDlg.cntCovert = cntCovert;
                        wDlg.IsInspection = IsInspection;

                        wDlg.setItemCodeName();

                        if (wDlg.clsFilterData)
                        {
                            wData.FilterData = string.Empty;
                            wData.FilterState = RldConst.ParamData.VAL_FILTER_STATE_NO;
                        }
                        else
                        {
                            if (wData.FilterData != wDlg.FilterData)
                                wData.FilterData = wDlg.FilterData;
                        }

                        cntTotal = wDlg.cntTotal;
                        cntNotName = wDlg.cntNotName;
                        cntErrTotal = wDlg.cntErrTotal;
                        cntCovert = wDlg.cntCovert;
                        IsInspection = wDlg.IsInspection;
                    }
                }
            }

            if (cntTotal != cntNotName && cntErrTotal != 0)
            {
                bOutMsg = true;
            }

            return;
        }

        // set code in FilterData,
        // if not find same code, find name, if not exist, return, else set code
        private void setGroupItemCodeName(ref int cntErrTotal, ref int cntCovert, ref bool bOutMsg)
        {
            int cntTotal = 0;
            int cntNotName = 0;

            // loop パラメータ編集データ
            foreach (var wData in RldLib.CurrentLayoutData.DesignGroupList)
            {
                // フィルタが未設定の場合は抜ける
                if (String.IsNullOrEmpty(wData.FilterType) || String.IsNullOrEmpty(wData.FilterData)) continue;
                if (wData.FilterType == RldConst.FilterType.Group.LOGTARGET)    // 指示履歴
                {
                    continue;
                }

                using (var wDlg = new frmSelectGenericFilter())
                {
                    switch (wData.FilterType)
                    {
                        case RldConst.FilterType.Group.MEDICINE:    // 薬剤
                            wDlg.FilterType = frmSelectGenericFilter.EnumFilterType.Medicine;
                            break;
                        case RldConst.FilterType.Group.EQUIP:       // 医材
                            wDlg.FilterType = frmSelectGenericFilter.EnumFilterType.Equipment;
                            break;
                        case RldConst.FilterType.Group.CATEGORY:    // 患者イベント
                            wDlg.FilterType = frmSelectGenericFilter.EnumFilterType.Category;
                            break;
                        case RldConst.FilterType.Group.PECEIPT:     // レセプト
                            wDlg.FilterType = frmSelectGenericFilter.EnumFilterType.Receipt;
                            break;
                        case RldConst.FilterType.Group.INFECTION:   // 感染症
                            wDlg.FilterType = frmSelectGenericFilter.EnumFilterType.Infection;
                            break;
                        case RldConst.FilterType.Group.EQUIP_DIA:   // 器材
                            wDlg.FilterType = frmSelectGenericFilter.EnumFilterType.EquipDia;
                            break;
                        // add #10370 装置帳票向けの「水質管理」データ項目を検討する 高 start
                        // mod #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
                        case RldConst.FilterType.Group.WQTESTTYPE:   // 水質検査種別
                            wDlg.FilterType = frmSelectGenericFilter.EnumFilterType.WQTestType;
                            break;
                        // mod #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end
                        // add #10370 装置帳票向けの「水質管理」データ項目を検討する 高 end
                        default:
                            break;
                    }

                    wDlg.FilterData = wData.FilterData;
                    wDlg.clsFilterData = false;
                    wDlg.cntTotal = cntTotal;
                    wDlg.cntNotName = cntNotName;
                    wDlg.cntErrTotal = cntErrTotal;
                    wDlg.cntCovert = cntCovert;

                    wDlg.setItemCodeName();

                    if(wDlg.clsFilterData)
                    {
                        switch (wData.FilterType)
                        {
                            case RldConst.FilterType.Group.MEDICINE:
                                wData.FilterData = "<SelectSetting><Item tag=\"Medicine\" checkState=\"Checked\" /></SelectSetting>";
                                break;
                            case RldConst.FilterType.Group.EQUIP:
                                wData.FilterData = "<SelectSetting><Item tag=\"Equipment\" checkState=\"Checked\" /></SelectSetting>";
                                break;
                            case RldConst.FilterType.Group.CATEGORY:
                                wData.FilterData = "<SelectSetting><Item tag=\"Category\" checkState=\"Checked\" /></SelectSetting>";
                                break;
                            case RldConst.FilterType.Group.PECEIPT:
                                wData.FilterData = "<SelectSetting><Item tag=\"Receipt\" checkState=\"Checked\" /></SelectSetting>";
                                break;
                            case RldConst.FilterType.Group.INFECTION:
                                wData.FilterData = "<SelectSetting><Item tag=\"Infection\" checkState=\"Checked\" /></SelectSetting>";
                                break;
                            case RldConst.FilterType.Group.EQUIP_DIA:
                                wData.FilterData = "<SelectSetting><Item tag=\"EquipDia\" checkState=\"Checked\" /></SelectSetting>";
                                break;
                            // add #10370 装置帳票向けの「水質管理」データ項目を検討する 高 start
                            // mod #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
                            case RldConst.FilterType.Group.WQTESTTYPE:
                                wData.FilterData = "<SelectSetting><Item tag=\"WQTestType\" checkState=\"Checked\" /></SelectSetting>";
                                break;
                            // mod #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end
                            // add #10370 装置帳票向けの「水質管理」データ項目を検討する 高 end
                            default:
                                break;
                        }
                        wData.FilterState = RldConst.GroupData.VAL_FILTER_STATE_ALL;
                    }
                    else
                    {
                        if(wData.FilterData != wDlg.FilterData)
                            wData.FilterData = wDlg.FilterData;
                    }

                    cntTotal = wDlg.cntTotal;
                    cntNotName = wDlg.cntNotName;
                    cntErrTotal = wDlg.cntErrTotal;
                    cntCovert = wDlg.cntCovert;
                }
            }

            if (cntTotal != cntNotName && cntErrTotal != 0)
            {
                bOutMsg = true;
            }

            return;
        }
        // mod #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 end
        // add #12026 帳票移植時にフィルタ設定が無効化する（初期対応） 高 end

        // add #9651 帳票表示項目の並び順を変更する 高 start
        /// <summary>
        /// 帳票表示項目の並び順項目リストを読み込みます。
        /// </summary>
        /// <returns></returns>
        private bool OrderLoadDataList()
        {
            bool wRet = false;

            try
            {
                // リストをクリア
                RldLib.CurrentLayoutData.DataItemOrderList.Clear();

                // 帳票表示項目の並び順項目リストファイル読込
                var wXmlDoc = new TdcLib.TdcXml();
                if (!wXmlDoc.Load(RldUtility.DataOrderFilePath))
                {
                    throw new System.ApplicationException(@"帳票表示項目の並び順項目リストファイルの読み込みに失敗しました。", wXmlDoc.Error);
                }

                // 指定された帳票種別の項目一覧を取得
                // @"reportTable/report[@type='Dialysis']/dataTable/data"
                string wXPathData = string.Format(@"{0}/{1}/{2}",
                    RldConst.ItemOrderList.TAG_REPORTTABLE,
                    RldConst.ItemOrderList.TAG_DATATABLE,
                    RldConst.ItemOrderList.TAG_DATA);

                foreach (System.Xml.XmlNode wXmlDataNode in wXmlDoc.Document.SelectNodes(wXPathData))
                {
                    var wData = new DesignItemListDataOrder();

                    // 属性を列挙してプロパティをセット
                    foreach (System.Xml.XmlAttribute wAttribute in wXmlDataNode.Attributes)
                    {
                        if (RldLib.IsEqualXmlAttName(wAttribute.Name, RldConst.ItemOrderList.ATT_DATA_DATACATEGORY))
                        {
                            wData.DataCategory = wAttribute.Value;
                        }
                        else if (RldLib.IsEqualXmlAttName(wAttribute.Name, RldConst.ItemOrderList.ATT_DATA_DATACLASS))
                        {
                            wData.DataClass = wAttribute.Value;
                        }
                    }

                    // リストへ追加
                    RldLib.CurrentLayoutData.DataItemOrderList.Add(wData);
                }

                wRet = true;
            }
            catch (Exception ex)
            {
                RldUtility.WriteLog(NKKLoggingLib.NKKLogging.LOGGING_CLASS.INFO, String.Format("帳票表示項目の並び順項目一覧の読込に失敗しました: {0}", ex.ToString()));
            }

            return wRet;
        }

        // add #9651 帳票表示項目の並び順を変更する 高 end
    }
}
