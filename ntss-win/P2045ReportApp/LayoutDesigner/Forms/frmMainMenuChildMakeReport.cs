using LayoutDesignerUtilityLib;
using NKKWebAccessLib;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

using RldMsgBox = LayoutDesignerUtilityLib.RldMessageBox;
using RldUtility = LayoutDesignerUtilityLib.LayoutDesignerUtility;


namespace LayoutDesigner
{
    /// <summary>
    /// メインメニュー画面(新規作成)
    /// </summary>
    public partial class frmMainMenuChildMakeReport : LayoutDesignerUtilityLib.Controls.frmRldBase, IRldMainMenuChild
    {
        #region 内部使用クラス定義

        /// <summary>
        /// DataGridView 表示用データクラス
        /// </summary>
        private class GridBindData : ReportTypeData
        {
            #region メンバ列挙体定義

            public enum EnumDataIndex
            {
                /// <summary>
                /// 帳票種別名
                /// </summary>
                ReportTypeName = 0,
                /// <summary>
                /// 説明
                /// </summary>
                Description,
                /// <summary>
                /// サンプルレイアウトファイルかどうか
                /// </summary>
                IsSampleFile,
                /// <summary>
                /// サンプルレイアウトファイルへのフルパス
                /// </summary>
                ModelFilePath,
                /// <summary>
                /// サムネイル画像ファイルへのフルパス
                /// </summary>
                ThumbnailFilePath
            }

            #endregion

            #region 生成と破棄

            /// <summary>
            /// DataGridView 表示データクラスの新しいインスタンスを初期化します。
            /// </summary>
            /// <param name="aSrcData"></param>
            public GridBindData(ReportTypeData aSrcData) : base()
            {
                base.ReportClass = aSrcData.ReportClass;
                base.ReportClassName = aSrcData.ReportClassName;
                base.IsSupportTempleteRepeat = aSrcData.IsSupportTempleteRepeat;
            }

            #endregion

            #region メンバプロパティ定義

            /// <summary>
            /// 帳票種別名の取得及び設定を行います。
            /// </summary>
            [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
            [RldGridRCBehavior()]
            [RldGridRCLayout(Width = 100)]
            [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.ReportTypeName, HeaderText = "帳票種別")]
            public new String ReportClassName
            {
                [System.Diagnostics.DebuggerStepThrough()]
                get
                {
                    return base.ReportClassName;
                }
                [System.Diagnostics.DebuggerStepThrough()]
                set
                {
                    base.ReportClassName = value;
                }
            }

            /// <summary>
            /// 説明の取得及び設定を行います。
            /// </summary>
            [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
            [RldGridRCBehavior()]
            [RldGridRCLayout(AutoSizeMode = DataGridViewAutoSizeColumnMode.Fill)]
            [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.Description, HeaderText = "白紙から作成/サンプルレイアウト")]
            public String Description { get; set; } = String.Empty;

            /// <summary>
            /// サンプルレイアウトファイルかどうかの取得及び設定を行います。
            /// </summary>
            [RldGridRCBehavior()]
            [RldGridRCLayout()]
            [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.IsSampleFile)]
            public Boolean IsModelFile { get; set; } = false;

            /// <summary>
            /// サンプルレイアウトファイルへのフルパスの取得及び設定を行います。
            /// </summary>
            [RldGridRCBehavior()]
            [RldGridRCLayout()]
            [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.ModelFilePath)]
            public String ModelFilePath { get; set; } = String.Empty;

            /// <summary>
            /// サムネイルファイルへのフルパスの取得及び設定を行います。
            /// </summary>
            [RldGridRCBehavior()]
            [RldGridRCLayout()]
            [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.ThumbnailFilePath)]
            public String ThumbnailFilePath { get; set; } = String.Empty;

            #endregion
        }

        #endregion

        #region メンバイベント定義

        public event EventHandler<RldMainMenuNotifyInfoEventArgs> NotifyInfo;

        // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 start
        private List<MstFacilityData> allFacilitylist = null;
        // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 end

        // add #9398 「オンラインで保存」の通常保存時は「新規登録」の時のみ「帳票保存設定」が出るようにすること donghao start
        public static bool sinkiFlg { get; set; } = false;
        // add #9398 「オンラインで保存」の通常保存時は「新規登録」の時のみ「帳票保存設定」が出るようにすること donghao end

        #endregion

        #region 生成と破棄

        /// <summary>
        /// メインメニュー画面(新規作成)の新しいインスタンスを初期化します。
        /// </summary>
        public frmMainMenuChildMakeReport()
        {
            InitializeComponent();

            // イベントハンドラ割り当て
            //this.btnSearchClear.Click += new EventHandler(this.btnSearchClear_Click);
            //this.btnSearchOK.Click += new EventHandler(this.btnSearchOK_Click);

            //this.dgvData.RowEnter += dgvData_RowEnter;
            //this.dgvData.CellDoubleClick += dgvData_CellDoubleClick;

            //this.btnOK.Click += new EventHandler(this.btnOK_Click);

            // データグリッドビューの列を自動生成しないようにする
            this.dgvData.AutoGenerateColumns = false;
            // データグリッドビューの表示を調整する
            RldGridRCAttributeReflector.ApplyToColumn(this.dgvData, typeof(GridBindData).GetProperties());
        }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// DataGridView に表示するすべてのデータを保持します。
        /// </summary>
        private BindingList<GridBindData> GridAllData { get; } = new BindingList<GridBindData>();

        #endregion

        #region メンバ関数定義(override)

        /// <summary>
        /// Form.Load イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnLoad(System.EventArgs e)
        {
            base.OnLoad(e);

            if (base.DesignMode) return;

            // 画面をクリア
            this.DataClear(true);

            // オンラインの時施設リストを作成
            if (SignInLib.SignIn.SignInInfo.IsOnline)
            {
                // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 start
                // 施設リストを作成
                this.MakeFacilityData();
                // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 end
            }

            // 表示用データの基データを作成
            this.MakeGridData();

            // 検索条件の帳票種別リストを作成
            this.MakeReportTypeTree();

            // 初期状態へ
            this.InitReportTypeTreeView();

            // ドロップダウンボタンを初期化
            this.rldDropDownButtonSearch.Init();

            // add #11501 レイアウトデザイナのユーザビリティ改善 高 start
            restoreMakeColumns();
            restoreMakeReportTreeView();
            // add #11501 レイアウトデザイナのユーザビリティ改善 高 end

            // 画面にデータをセット
            this.DataRead();
        }

        #endregion

        #region メンバ関数定義

        /// <summary>
        /// イベントを通知します。
        /// </summary>
        /// <param name="e"></param>
        private void SendNotifyInfo(RldMainMenuNotifyInfoEventArgs e) => this.NotifyInfo?.Invoke(this, e);

        /// <summary>
        /// DataGridView に表示するデータの基データを作成します。
        /// </summary>
        private void MakeGridData()
        {
            String wSavedReportType = String.Empty;

            this.GridAllData.Clear();

            foreach (var wReport in RldLib.ReportClassList)
            {

                // 白紙から作成を追加
                if (wSavedReportType != wReport.ReportClass)
                {
                    this.GridAllData.Add(
                        new GridBindData(wReport)
                        {
                            Description = "白紙から作成",
                            IsModelFile = false
                        });
                    wSavedReportType = wReport.ReportClass;
                }

                // サンプルレイアウトファイルの格納先ディレクトリへのフルパスを取得
                String wDirPath = RldLib.GetModelDirPath(wReport.ReportClass);
                // 該当ディレクトリが存在しない場合はスキップ
                if (!System.IO.Directory.Exists(wDirPath)) continue;

                foreach (var wPath in System.IO.Directory.GetFiles(wDirPath, "*.xls", System.IO.SearchOption.TopDirectoryOnly))
                {

                    String wFileName = System.IO.Path.GetFileNameWithoutExtension(wPath);

                    this.GridAllData.Add(
                        new GridBindData(wReport)
                        {
                            Description = wFileName,
                            ModelFilePath = wPath,
                            ThumbnailFilePath = String.Format("{0}{2}{1}.jpg", wDirPath, wFileName, System.IO.Path.DirectorySeparatorChar),
                            IsModelFile = true
                        });
                }
            }
        }

        /// <summary>
        /// 検索条件の帳票種別リストを作成します。
        /// </summary>
        /// <param name="aTarget"></param>
        private void MakeReportTypeTree()
        {
            RldTriStateTreeNode wRoot = null;

            try
            {
                this.rldTriStateTreeViewSearch.BeginUpdate();

                // ルートノードを作成して追加
                this.rldTriStateTreeViewSearch.Nodes.Add(
                    wRoot = new RldTriStateTreeNode()
                    {
                        CheckboxVisible = true,
                        IsContainer = true,
                        Tag = "All",
                        Text = "全て"
                    });

                // mod #7297 初回リリース対象外の機能とその関連機能を隠す xiaosonglei start
                if (!string.IsNullOrEmpty(RldUtility.CreateDropCodeList))
                {
                    string[] showReportClassList = RldUtility.CreateDropCodeList.Split(',');
                    RldLib.ReportClassList.ForEach(
                        ele => {
                            if (showReportClassList.Contains(ele.ReportClass))
                            {
                                wRoot.Nodes.Add(
                                        new RldTriStateTreeNode()
                                        {
                                            CheckboxVisible = true,
                                            IsContainer = false,
                                            Tag = ele.ReportClass,
                                            Text = ele.ReportClassName
                                        });
                            }
                        }
                    );
                }
                //RldLib.ReportClassList.ForEach(
                //    ele => wRoot.Nodes.Add(
                //        new RldTriStateTreeNode() {
                //            CheckboxVisible = true,
                //            IsContainer = false,
                //            Tag = ele.ReportClass,
                //            Text = ele.ReportClassName
                //        }));
                // mod #7297 初回リリース対象外の機能とその関連機能を隠す xiaosonglei end
            }
            catch (Exception ex)
            {
                // TODO:
            }
            finally
            {
                this.rldTriStateTreeViewSearch.EndUpdate();
            }
        }

        /// <summary>
        /// 帳票種別表示用ツリービューコントロールを初期表示状態に設定します。
        /// </summary>
        /// <param name="aTarget"></param>
        private void InitReportTypeTreeView()
        {
            // ノードがない場合は抜ける
            if (this.rldTriStateTreeViewSearch.GetNodeCount(true) <= 0) return;

            var wFirstNode = (RldTriStateTreeNode)this.rldTriStateTreeViewSearch.Nodes[0];

            // 全選択状態へ
            wFirstNode.SetCheckedState(CheckState.Checked);

            // 展開しておく         
            wFirstNode.Collapse(false);
            wFirstNode.Expand();
        }

        /// <summary>
        /// 画面に表示中のデータをクリアします。
        /// </summary>
        /// <param name="aIsKeyClear"></param>
        private void DataClear(bool aIsKeyClear)
        {
            if (aIsKeyClear)
                this.rldTriStateTreeViewSearch.Nodes.Clear();

            this.dgvData.Rows.Clear();
            this.picThumb.Image = null;
        }

        /// <summary>
        /// 画面のデータを確認します。
        /// </summary>
        /// <returns></returns>
        private bool DataCheck()
        {
            const String MSG_TITLE = "確認してください";

            // 未選択状態の場合はエラー
            if (this.dgvData.CurrentRow == null)
            {
                RldMsgBox.Show(this.ParentForm, @"作成方法かサンプルレイアウトファイルを選択してください。", MSG_TITLE, MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                this.dgvData.Focus();

                return false;
            }

            // 選択行のバインドデータを取得
            if (!(this.dgvData.CurrentRow.DataBoundItem is GridBindData wData))
            {
                RldMsgBox.Show(this.ParentForm, @"選択されたデータを特定できませんでした。", @"システム管理者に連絡してください", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                this.dgvData.Focus();

                return false;
            }

            // サンプルレイアウトファイルから作成の場合はファイルが存在するか確認
            if (wData.IsModelFile && !System.IO.File.Exists(wData.ModelFilePath))
            {
                RldMsgBox.Show(this.ParentForm, @"選択されたサンプルレイアウトファイルが見つかりません。", MSG_TITLE, MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                this.dgvData.Focus();

                return false;
            }

            return true;
        }

        /// <summary>
        /// 画面にデータを表示します。
        /// </summary>
        private void DataRead()
        {
            try
            {
                this.dgvData.SuspendLayout();

                // 作業用リストを生成
                var wList = new List<GridBindData>(this.GridAllData);

                // 帳票種別ツリービューの全ノードを取得
                Func<TreeNodeCollection, List<RldTriStateTreeNode>> wFuncGetAllNodes = null;
                wFuncGetAllNodes = aCollection => {
                    var wNodeList = new List<RldTriStateTreeNode>();
                    foreach (TreeNode wNode in aCollection)
                    {
                        wNodeList.Add(wNode as RldTriStateTreeNode);
                        if (wNode.GetNodeCount(false) > 0) wNodeList.AddRange(wFuncGetAllNodes(wNode.Nodes));
                    }
                    return wNodeList;
                };

                // 帳票種別によるフィルタリングを適用
                foreach (var wNode in wFuncGetAllNodes(this.rldTriStateTreeViewSearch.Nodes).Where(ele => ele.CheckState == CheckState.Unchecked))
                    wList.RemoveAll(ele => ele.ReportClass == wNode.Tag as String);

                // フリーワードによるフィルタリングを適用
                if (!String.IsNullOrEmpty(this.txtFree.Text))
                {

                    // 日本語用の検索パラメータ指定用データを取得
                    var wCompareInfo = System.Globalization.CultureInfo.CurrentCulture.CompareInfo;

                    System.Func<String, Int32> wFuncFindIndex = aTarget => wCompareInfo.IndexOf(
                        aTarget,
                        this.txtFree.Text,
                        System.Globalization.CompareOptions.IgnoreCase | System.Globalization.CompareOptions.IgnoreWidth);

                    wList = wList.FindAll(ele => wFuncFindIndex(ele.ReportClassName) >= 0 || wFuncFindIndex(ele.Description) >= 0);
                }

                // バインド用リストを生成してバインド
                this.dgvData.DataSource = new BindingList<GridBindData>(wList);

                // ボタンのテキストとツールチップテキストを更新
                this.UpdateUpDownButtonText();
            }
            catch (Exception ex)
            {
                // TODO: 
            }
            finally
            {
                this.dgvData.ResumeLayout();
            }
        }

        /// <summary>
        /// ツリービューコントロール開閉用ボタンのテキストとツールチップテキストを更新します。
        /// </summary>
        private void UpdateUpDownButtonText()
        {
            String wText = String.Empty;

            String wKeyword = String.IsNullOrEmpty(this.txtFree.Text) ? "指定無し" : this.txtFree.Text;

            // ルートノードを取得
            var wRootNode = this.rldTriStateTreeViewSearch.Nodes[0] as RldTriStateTreeNode;

            switch (wRootNode.CheckState)
            {
                case CheckState.Checked:
                    wText = String.Format("帳票種別:全て,キーワード:'{0}'", wKeyword);
                    break;

                case CheckState.Unchecked:
                    wText = "帳票種別:未選択";
                    break;

                case CheckState.Indeterminate:
                    wText = String.Format("帳票種別:複数,キーワード:'{0}'", wKeyword);
                    break;
            }

            this.rldDropDownButtonSearch.Text = wText;
            this.toolTipMainMenuChildMakeReport.SetToolTip(this.rldDropDownButtonSearch, wText);
        }

        #endregion

        #region コントロールイベントハンドラ定義

        /// <summary>
        /// DataGridView の CellDoubleClick イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvData_CellDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
            // ヘッダの場合は抜ける
            if (e.RowIndex < 0 || e.ColumnIndex < 0) return;
            this.btnOK.PerformClick();
        }

        /// <summary>
        /// DataGridView の RowEnter イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvData_RowEnter(object sender, DataGridViewCellEventArgs e)
        {
            // 選択行のデータを取得
            if (!(this.dgvData.Rows[e.RowIndex].DataBoundItem is GridBindData wData)) return;

            this.lblSample.Visible = true;
            this.picThumb.Image = null;

            // サンプルレイアウトファイルを選択した場合
            if (wData.IsModelFile)
            {
                if (System.IO.File.Exists(wData.ThumbnailFilePath))
                {
                    this.picThumb.ImageLocation = wData.ThumbnailFilePath;
                    this.lblSample.Visible = false;
                }
            }
        }

        /// <summary>
        /// 検索用ドロップダウンパネル内の OK ボタンの Cilck イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnSearchOK_Click(object sender, EventArgs e)
        {
            // ドロップダウンパネルを閉じる
            this.rldDropDownButtonSearch.DroppedDown = false;
            // 画面を更新
            this.DataRead();
        }

        /// <summary>
        /// 検索用ドロップダウンパネル内の クリア ボタンの Cilck イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnSearchClear_Click(object sender, EventArgs e)
        {
            this.txtFree.Clear();
            this.InitReportTypeTreeView();
        }

        /// <summary>
        /// 選択した帳票を作成ボタンの Click イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnOK_Click(object sender, EventArgs e)
        {
            if (!this.DataCheck()) return;

            // add #9398 「オンラインで保存」の通常保存時は「新規登録」の時のみ「帳票保存設定」が出るようにすること donghao start
            sinkiFlg = true;
            // add #9398 「オンラインで保存」の通常保存時は「新規登録」の時のみ「帳票保存設定」が出るようにすること donghao end

            // 選択行のバインドデータを取得
            if (!(this.dgvData.CurrentRow.DataBoundItem is GridBindData wData)) return;

            // add #12050 FNW帳票コンバートで維持されない設定がある 高 start
            RldLib.CurrentLayoutData.DataItemConvertList.Clear();
            // add #12050 FNW帳票コンバートで維持されない設定がある 高 end

            // 親へ通知
            this.NotifyInfo?.Invoke(this, new RldMainMenuNotifyInfoRequestNewReportEventArgs()
            {
                ReportType = wData.ReportClass,
                IsSupportTempleteRepeat = wData.IsSupportTempleteRepeat,
                IsModelFile = wData.IsModelFile,
                ModelFilePath = wData.ModelFilePath
            });
        }

        #endregion

        #region IRldMainMenuChild Implements

        /// <summary>
        /// 親フォームからのイベント受信用
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        public void ReceiveNotifyInfo(object sender, RldMainMenuNotifyInfoEventArgs e)
        {
        }

        #endregion

        // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 start
        /// <summary>
        /// 施設リストを作成します。
        /// </summary>
        /// <param name="aTarget"></param>
        private void MakeFacilityData()
        {
            var wRestRet = Task.Run<RldRestResultData<List<MstFacilityData>>>(async () => await RldLib.GetMstFactilityList(true)).Result;
            if (wRestRet.IsSuccess)
            {
                // バインド用リストを生成してバインド
                List<MstFacilityData> list = wRestRet.Data;
                this.dgvFacilityData.SuspendLayout();
                this.dgvFacilityData.DataSource = list;
                this.dgvFacilityData.Columns[0].Visible = false;
                this.dgvFacilityData.ResumeLayout();
                this.allFacilitylist = list;
                if (!String.IsNullOrEmpty(LayoutDesignerUtility.CurrentFacilityCd))
                {
                    this.rldFacillitySearch.Text = LayoutDesignerUtility.CurrentFacilityName;
                    this.lblFacilityCd.Text = LayoutDesignerUtility.CurrentFacilityCd;
                }
                else
                {
                    foreach (var wMstData in wRestRet.Data)
                    {
                        if (SignInLib.SignIn.SignInInfo.FacilityCode.Equals(wMstData.facilityCd))
                        {
                            this.rldFacillitySearch.Text = wMstData.facilityName;
                            this.lblFacilityCd.Text = wMstData.facilityCd;
                            break;
                        }
                    }
                    LayoutDesignerUtility.CurrentFacilityCd = this.lblFacilityCd.Text;
                    LayoutDesignerUtility.CurrentFacilityName = this.rldFacillitySearch.Text.ToString();
                    // add #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 start
                    RldLib.FilterDataSet.ClearFilterData();
                    // add #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 end
                }
                if ("1".Equals(SignInLib.SignIn.SignInInfo.UserType))
                {
                    this.rldFacillitySearch.Visible = true;
                }
            }
            else
            {
                // 親へ通知
                this.NotifyInfo?.Invoke(this, new RldMainMenuNotifyInfoCannotAccess() { });
            }
        }

        /// <summary>
        /// DataGridViewの Click イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvFacilityData_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex < 0 || e.ColumnIndex < 0)
            {
                return;
            }

            this.lblFacilityCd.Text = this.dgvFacilityData.CurrentRow.Cells[0].Value.ToString();
            this.rldFacillitySearch.Text = this.dgvFacilityData.CurrentRow.Cells[1].Value.ToString();
            LayoutDesignerUtility.CurrentFacilityCd = this.lblFacilityCd.Text;
            LayoutDesignerUtility.CurrentFacilityName = this.rldFacillitySearch.Text;
            this.rldFacillitySearch.DroppedDown = false;
            // add #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 start
            RldLib.FilterDataSet.ClearFilterData();
            // add #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 end
        }

        /// <summary>
        /// txtFacilityの TextChanged イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void txtFacility_TextChanged(object sender, EventArgs e)
        {
            String facilityName = this.txtFacility.Text;
            if (String.IsNullOrEmpty(facilityName))
            {
                this.dgvFacilityData.SuspendLayout();
                this.dgvFacilityData.DataSource = this.allFacilitylist;
                this.dgvFacilityData.Columns[0].Visible = false;
                this.dgvFacilityData.ResumeLayout();
            }
            List<MstFacilityData> list = new List<MstFacilityData>();
            list = this.allFacilitylist.Where(ele => ele.facilityName.Contains(facilityName)).ToList();
            if (list != null)
            {
                this.dgvFacilityData.SuspendLayout();
                this.dgvFacilityData.DataSource = list;
                this.dgvFacilityData.Columns[0].Visible = false;
                this.dgvFacilityData.ResumeLayout();
            }
        }

        // add #11501 レイアウトデザイナのユーザビリティ改善 高 start
        private void txtFree_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                e.SuppressKeyPress = true;
                btnSearchOK.PerformClick();
            }
        }

        // save window size to Properties.Settings, format is json.
        public void saveMakeReport()
        {
            saveMakeReportColumns();
            saveMakeReportTreeView();
        }

        // save window size to Properties.Settings, format is json.
        private void saveMakeReportColumns()
        {
            StringBuilder outJson = new StringBuilder();
            outJson.Append("{")
                .AppendFormat("\"ReportTypeName\": \"{0}\"", this.dgvData.Columns[0].Width)
                .Append("}");
            Properties.Settings.Default.MainMenuMakeColumns = outJson.ToString();
            Properties.Settings.Default.Save();

            outJson.Length = 0;
        }

        // save 帳票種別のチェック状態および、フリーワード to Properties.Settings, format is json.
        private void saveMakeReportTreeView()
        {
            StringBuilder outJson = new StringBuilder();
            outJson.Append("{");

            //  帳票種別のチェック状態
            foreach (RldTriStateTreeNode wChildNode in this.rldTriStateTreeViewSearch.Nodes)
            {
                outJson.AppendFormat("\"{0}\": \"{1}\",", wChildNode.Text, Convert.ToString(wChildNode.CheckState));
                foreach (RldTriStateTreeNode wTreeNodeRecursive in wChildNode.Nodes)
                {
                    outJson.AppendFormat("\"{0}\": \"{1}\",", wTreeNodeRecursive.Text, Convert.ToString(wTreeNodeRecursive.CheckState));
                }
            }

            // フリーワード
            outJson.AppendFormat("\"{0}\": \"{1}\"", "txtFree", this.txtFree.Text);
            outJson.Append("}");

            Properties.Settings.Default.MainMenuMakeNode = outJson.ToString();
            Properties.Settings.Default.Save();

            outJson.Length = 0;
        }

        // restore Columns size
        private void restoreMakeColumns()
        {
            bool bRet;

            try
            {
                this.dgvData.SuspendLayout();

                // restore width of Columns
                Dictionary<String, String> json = NKKWebAccess.GetJsonData(Properties.Settings.Default.MainMenuMakeColumns);
                if (json.Count() > 0)
                {
                    // 帳票種別
                    if (json["ReportTypeName"] != "")
                    {
                        bRet = int.TryParse(json["ReportTypeName"], out int lNum);
                        if (bRet)
                            this.dgvData.Columns[0].Width = lNum;
                    }
                }
            }
            catch (Exception)
            {
                // TODO:
            }
            finally
            {
                this.dgvData.ResumeLayout();
            }

        }

        // restore 帳票種別のチェック状態および、フリーワード
        private void restoreMakeReportTreeView()
        {
            bool bRet;

            try
            {
                string nodeText = string.Empty;
                CheckState wCheckState;

                this.dgvData.SuspendLayout();

                // restore 帳票種別
                Dictionary<String, String> json = NKKWebAccess.GetJsonData(Properties.Settings.Default.MainMenuMakeNode);
                if (json.Count() > 0)
                {
                    foreach (RldTriStateTreeNode wChildNode in this.rldTriStateTreeViewSearch.Nodes)
                    {
                        nodeText = wChildNode.Text;
                        if (string.IsNullOrEmpty(nodeText) == false)
                        {
                            if (json.ContainsKey(nodeText))
                            {
                                wCheckState = (CheckState)Enum.Parse(typeof(CheckState), json[nodeText], false);
                                wChildNode.SetCheckedState(wCheckState);
                            }
                        }
                        foreach (RldTriStateTreeNode wTreeNodeRecursive in wChildNode.Nodes)
                        {
                            nodeText = wTreeNodeRecursive.Text;
                            if (string.IsNullOrEmpty(nodeText) == false)
                            {
                                if (json.ContainsKey(nodeText))
                                {
                                    wCheckState = (CheckState)Enum.Parse(typeof(CheckState), json[nodeText], false);
                                    wTreeNodeRecursive.SetCheckedState(wCheckState);
                                }
                            }
                        }
                    }

                    // restore フリーワード
                    nodeText = "txtFree";
                    if (json.ContainsKey(nodeText))
                    {
                        this.txtFree.Text = json[nodeText];
                    }
                }
            }
            catch (Exception)
            {
                // TODO:
            }
            finally
            {
                this.dgvData.ResumeLayout();
            }
        }

        private void rldFacillitySearch_TextChanged(object sender, EventArgs e)
        {
            this.txtFree.Clear();
            this.InitReportTypeTreeView();

            // 画面を更新
            this.DataRead();
        }

        // add #11501 レイアウトデザイナのユーザビリティ改善 高 end
        // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 end
    }
}
