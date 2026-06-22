using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using LayoutDesignerUtilityLib;
using NKKWebAccessLib;

using RldMsgBox = LayoutDesignerUtilityLib.RldMessageBox;
using RldUtility = LayoutDesignerUtilityLib.LayoutDesignerUtility;

namespace LayoutDesigner
{
    /// <summary>
    /// メインメニュー画面(編集)
    /// </summary>
    public partial class frmMainMenuChildEditReport : LayoutDesignerUtilityLib.Controls.frmRldBase, IRldMainMenuChild
    {
        #region 内部使用クラス定義

        /// <summary>
        /// DataGridView 表示用データクラス
        /// </summary>
        private class GridBindData : ReportTypeData
        {
            #region メンバ定数定義

            public const String VAL_IS_DISPLAY_OFF = "0";
            public const String VAL_IS_DISPLAY_ON = "1";
            public const String VAL_IS_DELETED_OFF = "0";
            public const String VAL_IS_DELETED_ON = "1";

            #endregion

            #region メンバ列挙体定義

            /// <summary>
            /// データ項目インデックス
            /// </summary>
            public enum EnumDataIndex
            {
                /// <summary>
                /// 帳票種別名
                /// </summary>
                ReportTypeName = 0,
                /// <summary>
                /// 帳票名
                /// </summary>
                ReportName,
                /// <summary>
                /// 既定のプリンター
                /// </summary>
                DefaultPrinter,
                /// <summary>
                /// 表示するかどうか
                /// </summary>
                IsDisplay,
                /// <summary>
                /// 削除された帳票かどうか
                /// </summary>
                IsDeleted,
                /// <summary>
                /// 作成日時
                /// </summary>
                CreateDate,
                /// <summary>
                /// 更新日時
                /// </summary>
                UpdateDate,
                // add 2020-09-29 FNSI-仕様追加 帳票更新者情報を追加する 李 start
                /// <summary>
                /// 更新者
                /// </summary>
                UpdateUser,
                // add 2020-09-29 FNSI-仕様追加 帳票更新者情報を追加する 李 end
                // add redmain #5608 「作成者」を追加する。 鄧シン start
                /// <summary>
                /// 作成者
                /// </summary>
                CreateUser,
                // add redmain #5608 「作成者」を追加する。 鄧シン end
                // add 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 start
                /// <summary>
                /// 帳票更新履歴
                /// </summary>
                ButtonLayoutHistoryText,
                // add 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 end
                /// <summary>
                /// 帳票マスタデータ
                /// </summary>
                ReportData
                // add FNSI-「帳票マスタ」にソート機能が必要:各列でソートができるようにする 孫 start
                /// <summary>
                /// 表示順
                /// </summary>
                , DispOrder
                // add FNSI-「帳票マスタ」にソート機能が必要:各列でソートができるようにする 孫 end
            }

            #endregion

            #region メンバ変数定義

            /// <summary>
            /// 全プロパティ
            /// </summary>
            private static System.Reflection.PropertyInfo[] m_Properties = typeof(GridBindData).GetProperties();

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
            /// 全てのプロパティを取得します。
            /// </summary>
            public static System.Reflection.PropertyInfo[] Properties
            {
                [System.Diagnostics.DebuggerStepThrough()]
                get => m_Properties;
            }

            /// <summary>
            /// プロパティ名のキャッシュ
            /// </summary>
            private static Dictionary<EnumDataIndex, String> PropertyNameCache { get; set; } = new Dictionary<EnumDataIndex, String>();

            #endregion

            #region メンバプロパティ定義(データ定義)

            /// <summary>
            /// 帳票種別名の取得及び設定を行います。
            /// </summary>
            [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
            [RldGridRCBehavior(ReadOnly = true)]
            [RldGridRCLayout(Width = 100)]
            [RldGridRCAppearance(DisplayIndex = (Int32)EnumDataIndex.ReportTypeName, HeaderText = "帳票種別")]
            public new String ReportClassName
            {
                [System.Diagnostics.DebuggerStepThrough()]
                get => base.ReportClassName;
                [System.Diagnostics.DebuggerStepThrough()]
                set => base.ReportClassName = value;
            }

            /// <summary>
            /// 帳票名の取得及び設定を行います。
            /// </summary>
            [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
            [RldGridRCBehaviorTextBox(MaxInputLength = 20)]
            [RldGridRCLayout(AutoSizeMode = DataGridViewAutoSizeColumnMode.Fill)]
            [RldGridRCAppearance(DisplayIndex = (Int32)EnumDataIndex.ReportName, HeaderText = "帳票名")]
            public String ReportName { get; set; } = String.Empty;

            /// <summary>
            /// 既定のプリンターの取得及び設定を行います。
            /// </summary>
            [RldGridRCDesign(typeof(DataGridViewComboBoxColumn))]
            [RldGridRCLayout(Width = 120)]
            [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.DefaultPrinter, HeaderText = "既定のプリンター")]
            public long? DefaultPrinter { get; set; }

            /// <summary>
            /// 表示状態かどうかの取得及び設定を行います。
            /// </summary>
            [RldGridRCDesign(typeof(DataGridViewCheckBoxColumn), IsDataBind = true)]
            [RldGridRCDataCheckBox(FalseValue = VAL_IS_DISPLAY_OFF, TrueValue = VAL_IS_DISPLAY_ON)]
            [RldGridRCBehavior(Resizable = DataGridViewTriState.False, SortMode = DataGridViewColumnSortMode.NotSortable)]
            [RldGridRCLayout(Width = 50)]
            [RldGridRCAppearanceCheckBox(DisplayIndex = (Int32)EnumDataIndex.IsDisplay, HeaderText = "表示")]
            [RldGridRCAppearanceDefaultCellStyle(DataNullValue = VAL_IS_DISPLAY_OFF, LayoutAlignment = DataGridViewContentAlignment.MiddleCenter)]
            public String IsDisplay { get; set; } = String.Empty;

            // add FNSI-「帳票マスタ」にソート機能が必要:各列でソートができるようにする 孫 start
            /// <summary>
            /// 表示順の取得及び設定を行います。
            /// </summary>
            [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
            [RldGridRCBehaviorTextBox(MaxInputLength = 5, Resizable = DataGridViewTriState.False, SortMode = DataGridViewColumnSortMode.Automatic)]
            [RldGridRCLayout(Width = 50)]
            [RldGridRCAppearance(DisplayIndex = (Int32)EnumDataIndex.DispOrder, HeaderText = "表示順")]
            [RldGridRCAppearanceDefaultCellStyle(DataNullValue = 0, LayoutAlignment = DataGridViewContentAlignment.MiddleCenter)]
            public Int32 DispOrder { get; set; } = 0;
            // add FNSI-「帳票マスタ」にソート機能が必要:各列でソートができるようにする 孫 end

            /// <summary>
            /// 削除状態かどうかの取得及び設定を行います。
            /// </summary>
            [RldGridRCDesign(typeof(DataGridViewCheckBoxColumn), IsDataBind = true)]
            [RldGridRCDataCheckBox(FalseValue = VAL_IS_DELETED_OFF, TrueValue = VAL_IS_DELETED_ON)]
            [RldGridRCBehavior(Resizable = DataGridViewTriState.False, SortMode = DataGridViewColumnSortMode.NotSortable)]
            [RldGridRCLayout(Width = 50)]
            [RldGridRCAppearanceCheckBox(DisplayIndex = (Int32)EnumDataIndex.IsDeleted, HeaderText = "削除")]
            [RldGridRCAppearanceDefaultCellStyle(DataNullValue = VAL_IS_DELETED_OFF, LayoutAlignment = DataGridViewContentAlignment.MiddleCenter)]
            public String IsDelete { get; set; } = String.Empty;

            /// <summary>
            /// 作成日時の取得及び設定を行います。
            /// </summary>
            [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
            [RldGridRCBehavior(ReadOnly = true)]
            [RldGridRCLayout(Width = 100)]
            [RldGridRCAppearance(DisplayIndex = (Int32)EnumDataIndex.CreateDate, HeaderText = "作成日時")]
            public String CreateDate { get; set; } = String.Empty;

            /// <summary>
            /// 最終更新日時の取得及び設定を行います。
            /// </summary>
            [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
            [RldGridRCBehavior(ReadOnly = true)]
            [RldGridRCLayout(Width = 100)]
            // mod 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 start
            //[RldGridRCAppearance(DisplayIndex = (Int32)EnumDataIndex.UpdateDate, HeaderText = "最終更新日時")]
            [RldGridRCAppearance(DisplayIndex = (Int32)EnumDataIndex.UpdateDate, HeaderText = "更新日時")]
            // mod 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 end
            public String UpdateDate { get; set; } = String.Empty;

            // add 2020-09-29 FNSI-仕様追加 帳票更新者情報を追加する 李 start
            /// <summary>
            /// 更新者。
            /// </summary>
            [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
            [RldGridRCBehavior(ReadOnly = true)]
            [RldGridRCLayout(Width = 100)]
            [RldGridRCAppearance(DisplayIndex = (Int32)EnumDataIndex.UpdateUser, HeaderText = "更新者")]
            public String UpdateUser { get; set; } = String.Empty;
            // add 2020-09-29 FNSI-仕様追加 帳票更新者情報を追加する 李 end

            // add redmain #5608 「作成者」を追加する。 鄧シン start
            /// <summary>
            /// 作成者。
            /// </summary>
            [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
            [RldGridRCBehavior(ReadOnly = true)]
            [RldGridRCLayout(Width = 100)]
            [RldGridRCAppearance(DisplayIndex = (Int32)EnumDataIndex.CreateUser, HeaderText = "作成者")]
            public String CreateUser { get; set; } = String.Empty;
            // add redmain #5608 「作成者」を追加する。 鄧シン end

            // add 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 start
            /// <summary>
            /// 帳票更新履歴ボタン列を表します。
            /// </summary>
            [RldGridRCDesign(typeof(DataGridViewButtonColumn), IsDataBind = false)]
            [RldGridRCBehavior(Resizable = DataGridViewTriState.False, SortMode = DataGridViewColumnSortMode.NotSortable)]
            [RldGridRCLayout(Width = 50)]
            [RldGridRCAppearanceButton(DisplayIndex = (Int32)EnumDataIndex.ButtonLayoutHistoryText, FlatStyle = FlatStyle.Flat, HeaderText = "版数", Text = "", UseColumnTextForButtonValue = false)]
            [RldGridRCAppearanceDefaultCellStyle(LayoutAlignment = DataGridViewContentAlignment.MiddleCenter)]
            public String ButtonLayoutHistoryText { get; set; } = String.Empty;
            // add 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 end

            /// <summary>
            /// 帳票マスタデータの取得及び設定を行います。
            /// </summary>
            [RldGridRCBehavior()]
            [RldGridRCLayout()]
            [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.ReportData)]
            public MstReportData ReportData { get; set; } = null;

            #endregion

            #region メンバ関数定義(公開部)

            /// <summary>
            /// 指定されたデータインデックスのプロパティを取得します。
            /// </summary>
            /// <param name="aIndex"></param>
            /// <returns></returns>
            public static System.Reflection.PropertyInfo GetProperty(EnumDataIndex aIndex)
            {
                System.Reflection.PropertyInfo wRet = null;

                foreach (var wProperty in GridBindData.Properties)
                {
                    var wAttribute = System.Attribute.GetCustomAttribute(wProperty, typeof(RldGridRCAppearanceAttribute), true) as RldGridRCAppearanceAttribute;
                    if (wAttribute != null && wAttribute.DisplayIndex == (Int32)aIndex)
                    {
                        wRet = wProperty; break;
                    }
                }

                return wRet;
            }

            /// <summary>
            /// 指定されたデータインデックスのプロパティ名を取得します。
            /// </summary>
            /// <param name="aIndex"></param>
            /// <returns></returns>
            public static String GetPropertyName(EnumDataIndex aIndex)
            {
                // キャッシュにない場合は取得してキャッシュ
                if (!PropertyNameCache.ContainsKey(aIndex))
                {
                    var wProp = GridBindData.GetProperty(aIndex);
                    GridBindData.PropertyNameCache.Add(aIndex, wProp.Name);
                }

                return PropertyNameCache[aIndex];
            }

            #endregion
        }

        #endregion

        #region メンバ変数定義

        private Boolean m_CanEditReportDesign = true;
        // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
        private Boolean m_ButtonEnableUpdate = true;
        // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end

        // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 start
        private List<MstFacilityData> allFacilitylist = null;
        // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 end

        // add 2021-02-19 No.517:FNW帳票レイアウトコンバート 趙 start
        // 帳票の種別
        private string reportType = "";
        // add 2021-02-19 No.517:FNW帳票レイアウトコンバート 趙 end

        // add #11502 レイアウトデザイナに2件の管理者用機能を追加 高 start
        string[] head_key =
        {
                "report_cd"
                ,"帳票種別"
                ,"帳票名"
                ,"既定のプリンター"
                ,"表示"
                ,"更新日時"
                ,"更新者"
                ,"作成者"
                ,"版数"
                ,"表示順"
                ,"最終版数"
                ,"最終版更新日時"
                ,"最終版更新者"
        };
        // add #11502 レイアウトデザイナに2件の管理者用機能を追加 高 end

        #endregion

        #region メンバイベント定義

        public event EventHandler<RldMainMenuNotifyInfoEventArgs> NotifyInfo;

        #endregion

        #region 生成と破棄

        /// <summary>
        /// メインメニュー画面(編集)の新しいインスタンスを初期化します。
        /// </summary>
        public frmMainMenuChildEditReport()
        {
            InitializeComponent();

            // イベントハンドラ割り当て
            //this.btnSearchClear.Click += new EventHandler(this.btnSearchClear_Click);
            //this.btnSearchOK.Click += new EventHandler(this.btnSearchOK_Click);

            //this.dgvData.CellValueChanged += new DataGridViewCellEventHandler(this.dgvData_CellValueChanged);
            //this.dgvData.CurrentCellDirtyStateChanged += new EventHandler(this.dgvData_CurrentCellDirtyStateChanged);

            //this.btnClear.Click += new EventHandler(this.btnClear_Click);
            //this.btnSave.Click += new EventHandler(this.btnSave_Click);

            //this.btnOK.Click += new EventHandler(this.btnOK_Click);

            // データグリッドビューの列を自動生成しないようにする
            this.dgvData.AutoGenerateColumns = false;
            // データグリッドビューの表示を調整する
            RldGridRCAttributeReflector.ApplyToColumn(this.dgvData, typeof(GridBindData).GetProperties());

            // デバッグ時のみ表示
            //if (!System.Diagnostics.Debugger.IsAttached)
            //{
            //    this.dgvData.Columns[GridBindData.GetPropertyName(GridBindData.EnumDataIndex.CreateDate)].Visible = false;
            //    this.dgvData.Columns[GridBindData.GetPropertyName(GridBindData.EnumDataIndex.UpdateDate)].Visible = false;
            //}
            this.dgvData.Columns[GridBindData.GetPropertyName(GridBindData.EnumDataIndex.CreateDate)].Visible = false;
            // add 2020-09-29 FNSI-仕様追加 帳票更新者情報を追加する 李 start
            //this.dgvData.Columns[GridBindData.GetPropertyName(GridBindData.EnumDataIndex.UpdateDate)].Visible = false;
            this.dgvData.Columns[GridBindData.GetPropertyName(GridBindData.EnumDataIndex.UpdateDate)].Visible = true;
            // add 2020-09-29 FNSI-仕様追加 帳票更新者情報を追加する 李 end
            // add redmain #5608 「作成者」を追加する。 鄧シン start
            this.dgvData.Columns[GridBindData.GetPropertyName(GridBindData.EnumDataIndex.CreateUser)].Visible = true;
            // add redmain #5608 「作成者」を追加する。 鄧シン end

            // [削除]列を非表示にする
            this.dgvData.Columns[GridBindData.GetPropertyName(GridBindData.EnumDataIndex.IsDeleted)].Visible = false;

            // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
            this.dgvData.DataBindingComplete += (s, e) => {
                updateCellsState();
            };
            // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
        }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// DataGridView に表示するすべてのデータを保持します。
        /// </summary>
        private BindingList<GridBindData> GridAllData { get; } = new BindingList<GridBindData>();

        /// <summary>
        /// デザイン画面で選択中の帳票のレイアウトを編集できるかどうかの取得及び設定を行います。
        /// </summary>
        private Boolean CanEditReportDesign
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                return this.m_CanEditReportDesign;
            }
            [System.Diagnostics.DebuggerStepThrough()]
            set {
                // ボタンの使用可否を切り替える
                this.pnlFooterSaveClear.Visible = !value;
                this.btnOK.Visible = value;
                this.rldDropDownButtonSearch.Enabled = value;

                this.m_CanEditReportDesign = value;

                // 削除ボタンの表示/非表示を切り替える
                this.BtnDelete.Visible = value;

                // add #11502 レイアウトデザイナに2件の管理者用機能を追加 高 start
                if ("1".Equals(SignInLib.SignIn.SignInInfo.UserType))
                {
                    this.btnCsvSave.Visible = value;
                    this.btnTemp.Visible = value;
                }
                // add #11502 レイアウトデザイナに2件の管理者用機能を追加 高 end

            }
        }

        // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
        private Boolean ButtonEnableUpdate
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get
            {
                return this.m_ButtonEnableUpdate;
            }
            [System.Diagnostics.DebuggerStepThrough()]
            set
            {
                // [選択した帳票を編集]の使用可否を切り替える
                bool openEnabled = true;
                // [選択した帳票を削除]の使用可否を切り替える
                bool delEnabled = true;
                if (this.dgvData.CurrentRow != null && this.dgvData.Rows[this.dgvData.CurrentRow.Index].DataBoundItem is GridBindData wData)
                {
                    // mod #11501 レイアウトデザイナのユーザビリティ改善 高 start
                    //openEnabled = wData.ReportData.ReportCode > 0;
                    openEnabled = (wData.IsDelete == GridBindData.VAL_IS_DELETED_OFF) && wData.ReportData.ReportCode > 0;
                    // mod #11501 レイアウトデザイナのユーザビリティ改善 高 end
                    // 削除されていない場合のみ削除ボタンを有効にする
                    delEnabled = (wData.IsDelete == GridBindData.VAL_IS_DELETED_OFF) && wData.ReportData.ReportCode > 0;
                }
                else
                {
                    // DataGridViewの行データが取得できない場合は削除させない.
                    openEnabled = false;
                    delEnabled = false;
                }

                this.btnOK.Enabled = openEnabled;
                this.BtnDelete.Enabled = delEnabled;

                this.m_ButtonEnableUpdate = value;
            }
        }
        // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
        #endregion

        #region メンバ関数定義(override)

        /// <summary>
        /// Form.Load イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnLoad(System.EventArgs e)
        {
            base.OnLoad(e);

            if( base.DesignMode ) return;

            // 編集内容保存用ボタンはデフォルトでは非表示
            this.CanEditReportDesign = true;

            // 画面をクリア
            this.DataClear(true);

            // オンラインの時施設リストを作成
            if (SignInLib.SignIn.SignInInfo.IsOnline)
            {
                do
                {
                    // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 start
                    // 施設リストを作成
                    if (!this.MakeFacilityData())
                    {
                        break;
                    }
                    // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 end

                    // 表示用データの基データを作成
                    if (!this.MakeGridData())
                    {
                        break;
                    }
                }
                while (false);
            }

            // 検索条件の帳票種別リストを作成
            this.MakeReportTypeTree();

            // 初期状態へ
            this.InitReportTypeTreeView();

            // ドロップダウンボタンを初期化
            this.rldDropDownButtonSearch.Init();

            // add #11501 レイアウトデザイナのユーザビリティ改善 高 start
            restoreEditColumns();
            restoreEditReportTreeView();
            restoreEditCurrentDisp();
            // add #11501 レイアウトデザイナのユーザビリティ改善 高 end

            // 画面にデータをセット
            this.DataRead();

            // add #11501 レイアウトデザイナのユーザビリティ改善 高 start
            // del #12460 「非表示の帳票を隠す」にチェックが入っている状態で編集画面から戻ると非表示設定の帳票が表示される 高 start
            //restoreEditCurrentPos();
            // del #12460 「非表示の帳票を隠す」にチェックが入っている状態で編集画面から戻ると非表示設定の帳票が表示される 高 end
            // add #11501 レイアウトデザイナのユーザビリティ改善 高 end
        }

        // add #12460 「非表示の帳票を隠す」にチェックが入っている状態で編集画面から戻ると非表示設定の帳票が表示される 高 start
        /// <summary>
        /// Form.OnShown イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnShown(EventArgs e)
        {
            base.OnShown(e);

            restoreEditCurrentDispChk();
            restoreEditCurrentPos();
            this.ButtonEnableUpdate = true;
        }
        // add #12460 「非表示の帳票を隠す」にチェックが入っている状態で編集画面から戻ると非表示設定の帳票が表示される 高 end

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
        private bool MakeGridData()
        {
            bool rt = false;
            String wSavedReportType = String.Empty;

            this.GridAllData.Clear();

            var wRestRet = Task.Run<RldRestResultData<List<MstReportData>>>(async () => await RldLib.GetMstReportList(true)).Result;
            // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 start
            if (!String.IsNullOrEmpty(this.lblFacilityCd.Text))
            {
                wRestRet = Task.Run<RldRestResultData<List<MstReportData>>>(async () => await RldLib.GetMstReportListOtherFacilityCd(true, this.lblFacilityCd.Text)).Result;
            }
            // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 end
            if ( wRestRet.IsSuccess ) {
            	// del 6156 帳票画面の帳票の表示順について 吉 start
               // foreach (var wReport in RldLib.ReportClassList)
               // {
               	// del 6156 帳票画面の帳票の表示順について 吉 end
               	// mod 6156 帳票画面の帳票の表示順について 吉 start
               		// foreach (var wMstData in wRestRet.Data.Where(ele => ele.ReportClass == RldLib.ConvertReportClassStringToInt32(wReport.ReportClass)))
                    foreach (var wMstData in wRestRet.Data)
                    // mod 6156 帳票画面の帳票の表示順について 吉 end
                    {
                        // add 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 start
                        String updateUser = String.Empty;
                        String updateDate = DateTime.Parse(wMstData.UpdateDate).ToString("yyyy/MM/dd HH:mm");
                        // mod #7922 新規施設のデフォルト帳票に作成者・更新者が登録されている / デフォルト帳票が編集できない 商 start
                        //String buttonLayoutHistoryText = "0";
                        String buttonLayoutHistoryText = "1";
                        // mod #7922 新規施設のデフォルト帳票に作成者・更新者が登録されている / デフォルト帳票が編集できない 商 end
                        // add redmain #5608 「作成者」を追加する。 鄧シン start
                        String createUser = String.Empty;
                        // add redmain #5608 「作成者」を追加する。 鄧シン end

                        // 帳票更新履歴が有りか？
                        if (wMstData.ReportHstInfo != null && wMstData.ReportHstInfo.ReportHstList != null && wMstData.ReportHstInfo.ReportHstList.Count > 0)
                        {
                            // 適用データを取得する
                            wMstData.ReportHstInfo.ReportHstList.Where(dl => dl.IsSelect == "1")
                                .Select(dl => (dl.CtlNo, dl.UpdDate, dl.UpdUserName)).Distinct().ToList().ForEach(dl =>
                                {
                                    if (!String.IsNullOrEmpty(dl.CtlNo))
                                    {
                                        buttonLayoutHistoryText = dl.CtlNo;
                                        DateTime dtDateTime = new DateTime();
                                        TdcLib.TdcLib.GetStringToDateTime("yyyyMMddHHmmss", dl.UpdDate, out dtDateTime);
                                        updateDate = dtDateTime.ToString("yyyy/MM/dd HH:mm");
                                        updateUser = dl.UpdUserName;
                                    }
                                });
                            // add redmain #5608 「作成者」を追加する。 鄧シン start
                            createUser = wMstData.ReportHstInfo.ReportHstList.Where(dl => dl.CtlNo == "1")
                                .Select(dl => (dl.CtlNo, dl.UpdUserName)).Distinct().ToList().First().UpdUserName;
                            // add redmain #5608 「作成者」を追加する。 鄧シン end
                        }
                        // add 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 end

                    // add 6156 帳票画面の帳票の表示順について 吉 start
                    foreach (var wReport in RldLib.ReportClassList)
                    {
                        if (wMstData.ReportClass == RldLib.ConvertReportClassStringToInt32(wReport.ReportClass))
                        {
                        	// add 6156 帳票画面の帳票の表示順について 吉 end
                            this.GridAllData.Add(new GridBindData(wReport)
                            {
                                // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
                                ReportClassName = wMstData.ReportCode < 0 ? wReport.ReportClassName + "(固定帳票)" : wReport.ReportClassName,
                                // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
                                ReportName = wMstData.ReportName,
                                IsDisplay = wMstData.IsDisplay,
                                // add FNSI-「帳票マスタ」にソート機能が必要:各列でソートができるようにする 孫 start
                                DispOrder = wMstData.DispOrder,
                                // add FNSI-「帳票マスタ」にソート機能が必要:各列でソートができるようにする 孫 end
                                IsDelete = wMstData.IsDelete,
                                CreateDate = DateTime.Parse(wMstData.CreateDate).ToString("yyyy/MM/dd HH:mm"),
                                // mod 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 start
                                //UpdateDate = DateTime.Parse(wMstData.UpdateDate).ToString("yyyy/MM/dd HH:mm"),
                                //// add 2020-10-07 FNSI-仕様追加 帳票更新者情報を追加する 李 start
                                //UpdateUser = wMstData.UpdateUser,
                                //// add 2020-10-07 FNSI-仕様追加 帳票更新者情報を追加する 李 end
                                UpdateDate = updateDate,
                                UpdateUser = updateUser,
                                // add redmain #5608 「作成者」を追加する。 鄧シン start
                                CreateUser = createUser,
                                // add redmain #5608 「作成者」を追加する。 鄧シン end
                                ButtonLayoutHistoryText = buttonLayoutHistoryText,
                                // mod 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 end
                                ReportData = wMstData,
                                DefaultPrinter = wMstData.DefaultPrinter
                            });
                            // add 6156 帳票画面の帳票の表示順について 吉 start
                            
                        }
                    }
                    // add 6156 帳票画面の帳票の表示順について 吉 end    

                        // add #7880 帳票：ラベル）正しく表示されないの保存時間の３回対応 夏 start
                        //Console.WriteLine();
                        // add #7880 帳票：ラベル）正しく表示されないの保存時間の３回対応 夏 end
                    }
                    // del 6156 帳票画面の帳票の表示順について 吉 start
                // }
                // del 6156 帳票画面の帳票の表示順について 吉 end

                rt = true;
            }
            else
            {
                //RldMsgBox.Show(this, "帳票マスタの取得が失敗しました。", "エラー", MessageBoxButtons.OK, MessageBoxIcon.Error);
                // 親へ通知
                this.NotifyInfo?.Invoke(this, new RldMainMenuNotifyInfoCannotAccess(){});
            }

            return rt;
        }

        /// <summary>
        /// 検索条件の帳票種別リストを作成します。
        /// </summary>
        /// <param name="aTarget"></param>
        private void MakeReportTypeTree()
        {
            RldTriStateTreeNode wRoot = null;

            try {
                this.rldTriStateTreeViewSearch.BeginUpdate();

                // ルートノードを作成して追加
                this.rldTriStateTreeViewSearch.Nodes.Add(
                    wRoot = new RldTriStateTreeNode() {
                        CheckboxVisible = true,
                        IsContainer = true,
                        Tag = "All",
                        Text = "全て"
                    });

                RldLib.ReportClassList.ForEach(
                    ele => wRoot.Nodes.Add(
                        new RldTriStateTreeNode() {
                            CheckboxVisible = true,
                            IsContainer = false,
                            Tag = ele.ReportClass,
                            Text = ele.ReportClassName
                        }));
            }
            catch( Exception ex ) {
                // TODO:
            }
            finally {
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
            if( this.rldTriStateTreeViewSearch.GetNodeCount(true) <= 0 ) return;

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
        private void DataClear(Boolean aIsKeyClear)
        {
            if( aIsKeyClear )
                this.rldTriStateTreeViewSearch.Nodes.Clear();

            this.dgvData.Rows.Clear();
        }

        /// <summary>
        /// 画面のデータを確認します。
        /// </summary>
        /// <returns></returns>
        private Boolean DataCheckForDeleteReport()
        {
            const String MSG_TITLE = "確認してください";

            // 未選択状態の場合はエラー
            if (this.dgvData.CurrentRow == null)
            {
                RldMsgBox.Show(this.ParentForm, @"編集対象の帳票を選択してください。", MSG_TITLE, MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                this.dgvData.Focus();

                return false;
            }

            return true;
        }

        /// <summary>
        /// 画面のデータを確認します。
        /// </summary>
        /// <returns></returns>
        private Boolean DataCheckForEditReport()
        {
            const String MSG_TITLE = "確認してください";

            // 未選択状態の場合はエラー
            if( this.dgvData.CurrentRow == null ) {
                RldMsgBox.Show(this.ParentForm, @"編集対象の帳票を選択してください。", MSG_TITLE, MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                this.dgvData.Focus();

                return false;
            }

            // 選択行のバインドデータを取得
            if( !(this.dgvData.CurrentRow.DataBoundItem is GridBindData wData) ) {
                RldMsgBox.Show(this.ParentForm, @"選択されたデータを特定できませんでした。", @"システム管理者に連絡してください", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                this.dgvData.Focus();

                return false;
            }

            return true;
        }

        /// <summary>
        /// 画面のデータを確認します。
        /// </summary>
        /// <returns></returns>
        private Boolean DataCheckForSaveReport()
        {
            const String MSG_TITLE = "確認してください";

            foreach( DataGridViewRow wRow in this.dgvData.Rows ) {

                // バインドデータを取得
                if( !(wRow.DataBoundItem is GridBindData wData) ) continue;

                // 帳票名チェック
                if( String.IsNullOrEmpty(wData.ReportName) ) {
                    RldMsgBox.Show(this.ParentForm, @"帳票名を入力してください。", MSG_TITLE, MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                    wRow.Selected = true;

                    return false;
                }
            }

            // add #12589 どこかで使用している帳票も削除出来てしまう 高 start
            var wList = new List<MstReportData>();

            // 変更されたバインドデータをwListへ追加する
            this.GetChangedDelGridBindDataList().ForEach(
                ele => wList.Add(
                    new MstReportData(ele.ReportData)
                    {
                        ReportName = ele.ReportName,
                        IsDisplay = ele.IsDisplay,
                        DispOrder = ele.DispOrder,
                        IsDelete = ele.IsDelete,
                        DefaultPrinter = ele.DefaultPrinter
                    }));

            if (wList.Count > 0)
            {
                bool bRet = canDelRepeat(wList);
                if (!bRet) return false;
            }
            // add #12589 どこかで使用している帳票も削除出来てしまう 高 end

            return true;
        }

        // add #12589 どこかで使用している帳票も削除出来てしまう 高 start
        private bool canDelRepeat(List<MstReportData> aList)
        {
            // 変更内容を一括で更新
            var wRestRet = Task<KeyValuePair<Boolean, String>>.Run(async () => await RldLib.checkDelRepeat(aList)).Result;
            if (!wRestRet.Key)
            {
                RldMsgBox.Show(this.ParentForm, wRestRet.Value, "帳票削除エラー", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return false;
            }

            return true;
        }
        // add #12589 どこかで使用している帳票も削除出来てしまう 高 end

        /// <summary>
        /// 画面の入力内容を破棄します。
        /// </summary>
        private void DataRollback()
        {
            // 変更前の値をセットし直す
            foreach( var wData in this.GetChangedGridBindDataList() ) {
                wData.ReportName = wData.ReportData.ReportName;
                // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
                wData.DefaultPrinter = wData.ReportData.DefaultPrinter;
                // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
                wData.IsDisplay = wData.ReportData.IsDisplay;
                // add FNSI-「帳票マスタ」にソート機能が必要:各列でソートができるようにする 孫 start
                wData.DispOrder = wData.ReportData.DispOrder;
                // add FNSI-「帳票マスタ」にソート機能が必要:各列でソートができるようにする 孫 end
                wData.IsDelete = wData.ReportData.IsDelete;
            }

            // 画面を更新
            this.dgvData.Refresh();
            // 画面下部のボタンを戻す
            this.CanEditReportDesign = true;
        }

        /// <summary>
        /// 画面にデータを表示します。
        /// </summary>
        private void DataRead()
        {
            try {
                this.dgvData.SuspendLayout();

                // 作業用リストを生成
                var wList = new List<GridBindData>(this.GridAllData);

                // 帳票種別ツリービューの全ノードを取得
                Func<TreeNodeCollection, List<RldTriStateTreeNode>> wFuncGetAllNodes = null;
                wFuncGetAllNodes = aCollection => {
                    var wNodeList = new List<RldTriStateTreeNode>();
                    foreach( TreeNode wNode in aCollection ) {
                        wNodeList.Add(wNode as RldTriStateTreeNode);
                        if( wNode.GetNodeCount(false) > 0 ) wNodeList.AddRange(wFuncGetAllNodes(wNode.Nodes));
                    }
                    return wNodeList;
                };

                // 帳票種別によるフィルタリングを適用
                foreach( var wNode in wFuncGetAllNodes(this.rldTriStateTreeViewSearch.Nodes).Where(ele => ele.CheckState == CheckState.Unchecked) )
                    wList.RemoveAll(ele => ele.ReportClass == wNode.Tag as String);

                // 削除帳票によるフィルタリングを適用
                if (!this.chkDispAll.Checked)
                {
                    // 削除フラグON のデータを除く
                    wList.RemoveAll(ele => ele.IsDelete == GridBindData.VAL_IS_DELETED_ON);
                }
                this.dgvData.Columns[GridBindData.GetPropertyName(GridBindData.EnumDataIndex.IsDeleted)].Visible = this.chkDispAll.Checked;

                // フリーワードによるフィルタリングを適用
                if (!string.IsNullOrEmpty(this.txtFree.Text))
                {

                    // 日本語用の検索パラメータ指定用データを取得
                    var wCompareInfo = System.Globalization.CultureInfo.CurrentCulture.CompareInfo;

                    System.Func<String, Int32> wFuncFindIndex = aTarget => wCompareInfo.IndexOf(
                        aTarget,
                        this.txtFree.Text,
                        System.Globalization.CompareOptions.IgnoreCase | System.Globalization.CompareOptions.IgnoreWidth);

                    wList = wList.FindAll(ele => wFuncFindIndex(ele.ReportClassName) >= 0 || wFuncFindIndex(ele.ReportName) >= 0);
                }

                // バインド用リストを生成してバインド
                this.dgvData.DataSource = new BindingList<GridBindData>(wList);

                // ボタンのテキストとツールチップテキストを更新
                this.UpdateUpDownButtonText();

                // add #11501 レイアウトデザイナのユーザビリティ改善 高 start
                chkDisp_changed();
                // add #11501 レイアウトデザイナのユーザビリティ改善 高 end
            }
            catch ( Exception ex ) {
                // TODO:
            }
            finally {
                this.dgvData.ResumeLayout();
            }
        }

        /// <summary>
        /// 画面の入力内容を保存します。
        /// </summary>
        /// <returns></returns>
        private Boolean DataUpdate()
        {
            Boolean wRet = false;

            try {
                var wList = new List<MstReportData>();

                // 変更されたバインドデータをwListへ追加する
                this.GetChangedGridBindDataList().ForEach(
                    ele => wList.Add(
                        new MstReportData(ele.ReportData) {
                            ReportName = ele.ReportName,
                            IsDisplay = ele.IsDisplay,
                            // add FNSI-「帳票マスタ」にソート機能が必要:各列でソートができるようにする 孫 start
                            DispOrder = ele.DispOrder,
                            // add FNSI-「帳票マスタ」にソート機能が必要:各列でソートができるようにする 孫 end
                            IsDelete = ele.IsDelete,
                            // del 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 start
                            //// add 2020-10-07 FNSI-仕様追加 帳票更新者情報を追加する 李 start
                            //UpdateUser = NKKWebAccess.UserId,
                            //// add 2020-10-07 FNSI-仕様追加 帳票更新者情報を追加する 李 end
                            // del 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 end
                            DefaultPrinter = ele.DefaultPrinter
                        }));

                if( wList.Count <= 0 ) return false;

                // 変更内容を一括で更新
                var wRestRet = Task<KeyValuePair<Boolean, String>>.Run(async () => await RldLib.PutMstReportList(wList)).Result;
                if( !wRestRet.Key ) 
                    throw new System.Net.Http.HttpRequestException(wRestRet.Value);

                wRet = wRestRet.Key;
            }
            catch( Exception ex ) {
                // 例外情報を生成
                var wEx = new System.ApplicationException("データ更新に失敗しました。", ex);
                // 例外情報を記録(画面にメッセージボックスを表示)
                RldUtility.RecordException(this.ParentForm, wEx, true);
            }

            return wRet;
        }

        /// <summary>
        /// ツリービューコントロール開閉用ボタンのテキストとツールチップテキストを更新します。
        /// </summary>
        private void UpdateUpDownButtonText()
        {
            String wText = String.Empty;

            String wKeyword = String.IsNullOrEmpty(this.txtFree.Text) ? "指定無し" : this.txtFree.Text;
            String wIsDispDeleted = this.chkDispAll.Checked ? "含む" : "除く";

            // ルートノードを取得
            var wRootNode = this.rldTriStateTreeViewSearch.Nodes[0] as RldTriStateTreeNode;

            switch( wRootNode.CheckState ) {
                case CheckState.Checked:
                    wText = String.Format("帳票種別:全て,キーワード:'{0}',削除帳票:'{1}'", wKeyword, wIsDispDeleted);
                    break;

                case CheckState.Unchecked:
                    wText = "帳票種別:未選択";
                    break;

                case CheckState.Indeterminate:
                    wText = String.Format("帳票種別:複数,キーワード:'{0}',削除帳票:'{1}'", wKeyword, wIsDispDeleted);
                    break;
            }

            this.rldDropDownButtonSearch.Text = wText;
            this.toolTipMainMenuChildEditReport.SetToolTip(this.rldDropDownButtonSearch, wText);
        }

        /// <summary>
        /// 変更されたバインドデータを取得します。
        /// </summary>
        /// <returns></returns>
        private List<GridBindData> GetChangedGridBindDataList()
        {
            var wRet = new List<GridBindData>();

            foreach (DataGridViewRow wRow in this.dgvData.Rows)
            {

                // 現在のデータを取得
                if (!(wRow.DataBoundItem is GridBindData wData))
                {
                    continue;
                }

                // 変更内容チェック
                if (wData.ReportData.ReportName != wData.ReportName ||
                    wData.ReportData.IsDisplay != wData.IsDisplay ||
                    // add FNSI-「帳票マスタ」にソート機能が必要:各列でソートができるようにする 孫 start
                    wData.ReportData.DispOrder != wData.DispOrder ||
                    // add FNSI-「帳票マスタ」にソート機能が必要:各列でソートができるようにする 孫 end
                    wData.ReportData.IsDelete != wData.IsDelete ||
                    wData.ReportData.DefaultPrinter != wData.DefaultPrinter)
                {
                    wRet.Add(wData);
                    continue;
                }

            }

            return wRet;
        }

        // add #12589 どこかで使用している帳票も削除出来てしまう 高 start
        /// <summary>
        /// 変更された delete バインドデータを取得します。
        /// </summary>
        /// <returns></returns>
        private List<GridBindData> GetChangedDelGridBindDataList()
        {
            var wRet = new List<GridBindData>();

            foreach (DataGridViewRow wRow in this.dgvData.Rows)
            {

                // 現在のデータを取得
                if (!(wRow.DataBoundItem is GridBindData wData))
                {
                    continue;
                }

                // 変更内容チェック
                if (wData.ReportData.IsDelete != wData.IsDelete && wData.IsDelete == "1")
                {
                    wRet.Add(wData);
                    continue;
                }

            }

            return wRet;
        }
        // add #12589 どこかで使用している帳票も削除出来てしまう 高 end

        #endregion

        #region コントロールイベントハンドラ定義

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

        // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
        /// <summary>
        /// DataGridView の SelectionChanged イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvData_SelectionChanged(object sender, EventArgs e)
        {
            this.ButtonEnableUpdate = true;
        }
        // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end

        /// <summary>
        /// DataGridView の CellValueChanged イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvData_CellValueChanged(object sender, DataGridViewCellEventArgs e)
        {
            // 変更内容を取得
            var wList = this.GetChangedGridBindDataList();
            // 画面下部のボタンの使用可否を切り替える
            this.CanEditReportDesign = wList.Count <= 0 ? true : false;
            // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
            this.ButtonEnableUpdate = wList.Count <= 0 ? false : true;
            // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
        }

        /// <summary>
        /// DataGridView の CurrentCellDirtyStateChanged イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvData_CurrentCellDirtyStateChanged(object sender, EventArgs e)
        {
            var wDataGridView = (DataGridView)sender;

            //if( wDataGridView.IsCurrentCellDirty )
            //{
            //}
            if (wDataGridView.IsCurrentCellDirty && ((wDataGridView.CurrentCell is DataGridViewCheckBoxCell) || (wDataGridView.CurrentCell is DataGridViewComboBoxCell)))
            {
                wDataGridView.EndEdit();
            }

        }

        /// <summary>
        /// 保存ボタンの Click イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnSave_Click(object sender, EventArgs e)
        {
            // データチェック(エラー時は抜ける)
            if( !this.DataCheckForSaveReport() ) return;

            // 更新処理実行
            if( this.DataUpdate() ) {
                // 成功した場合は RDS から読み直す
                // add #11501 レイアウトデザイナのユーザビリティ改善 高 start
                int savedSelectedRowIndex = -1;
                int firstDisplayedRowIndex = -1;

                if (this.dgvData.SelectedRows.Count > 0)
                {
                    savedSelectedRowIndex = this.dgvData.SelectedRows[0].Index;
                }
                else if (this.dgvData.CurrentCell != null)
                {
                    savedSelectedRowIndex = this.dgvData.CurrentCell.RowIndex;
                }

                if (this.dgvData.FirstDisplayedScrollingRowIndex >= 0)
                {
                    firstDisplayedRowIndex = this.dgvData.FirstDisplayedScrollingRowIndex;
                }
                // add #11501 レイアウトデザイナのユーザビリティ改善 高 end

                this.MakeGridData();
                this.DataRead();

                // add #11501 レイアウトデザイナのユーザビリティ改善 高 start
                setCurrentPos(savedSelectedRowIndex, firstDisplayedRowIndex);
                // add #11501 レイアウトデザイナのユーザビリティ改善 高 end
                // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
                this.ButtonEnableUpdate = true;
                // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
                // 画面下部のボタンを戻す
                this.CanEditReportDesign = true;
            }
            else {
                // 失敗

            }
        }

        /// <summary>
        /// クリアボタンの Click イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnClear_Click(object sender, EventArgs e)
        {
            // 確認メッセージ
            if( RldMsgBox.Show(
                this.ParentForm, 
                "編集内容を破棄します。よろしいですか？", 
                "確認してください", 
                MessageBoxButtons.YesNo, 
                MessageBoxIcon.Question, 
                MessageBoxDefaultButton.Button2) == DialogResult.No )
                return;

            // 戻す
            this.DataRollback();
            // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
            this.ButtonEnableUpdate = true;
            // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
        }

        /// <summary>
        /// 選択した帳票を編集ボタンの Click イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnOK_Click(object sender, EventArgs e)
        {

            // 画面のデータを確認する
            if( !this.DataCheckForEditReport() ) return;

            // 選択行のバインドデータを取得
            if( !(this.dgvData.CurrentRow.DataBoundItem is GridBindData wData) ) return;

            // add #12050 FNW帳票コンバートで維持されない設定がある 高 start
            RldLib.CurrentLayoutData.DataItemConvertList.Clear();
            // add #12050 FNW帳票コンバートで維持されない設定がある 高 end

            // 親へ通知
            this.NotifyInfo?.Invoke(this, new RldMainMenuNotifyInfoRequestEditReportEventArgs() {
                ReportData = wData.ReportData
            });
        }

        /// <summary>
        /// [選択した帳票を削除]ボタンの Click イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void BtnDelete_Click(object sender, EventArgs e)
        {
            try
            {
                // 画面のデータを確認する
                if (!this.DataCheckForDeleteReport()) return;

                // 選択された帳票を削除する

                // 選択行のバインドデータを取得
                // mod #12589 どこかで使用している帳票も削除出来てしまう 高 start
                //if ((this.dgvData.CurrentRow.DataBoundItem is GridBindData wData)
                //    && (RldMsgBox.Show(this, "削除します。よろしいですか。", "確認", MessageBoxButtons.YesNo, MessageBoxIcon.Exclamation) == DialogResult.Yes))
                if (this.dgvData.CurrentRow.DataBoundItem is GridBindData wData)
                {
                    
                    var wList = new List<MstReportData>();

                    // 変更されたバインドデータをwListへ追加する
                    wList.Add(
                            new MstReportData(wData.ReportData)
                            {
                                ReportName = wData.ReportName,
                                IsDisplay = wData.IsDisplay,
                                DispOrder = wData.DispOrder,
                                IsDelete = wData.IsDelete,
                                DefaultPrinter = wData.DefaultPrinter
                            });

                    if (wList.Count > 0)
                    {
                        bool bRet = canDelRepeat(wList);
                        if (!bRet) return;
                    }
                        
                    if (RldMsgBox.Show(this, "削除します。よろしいですか。", "確認", MessageBoxButtons.YesNo, MessageBoxIcon.Exclamation) == DialogResult.Yes)
                    {
                        // REST-APIを呼び出す
                        KeyValuePair<bool, string> wRestRet = Task.Run(async () => await PutMstReportIsDel(wData.ReportData.ReportCode)).Result;
                        if (wRestRet.Key)
                        {
                            // 成功した場合は RDS から読み直す
                            this.MakeGridData();
                            this.DataRead();
                        }
                        else
                        {
                            // 親へ通知
                            this.NotifyInfo?.Invoke(this, new RldMainMenuNotifyInfoCannotAccess() { });
                        }
                    }
                }
                // mod #12589 どこかで使用している帳票も削除出来てしまう 高 end
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(this, ex, true);
            }

        }

        /// <summary>
        /// mst_reportのis_delフラグを1に更新する
        /// </summary>
        /// <param name="reportCode">report_cd</param>
        /// <returns></returns>
        private static async Task<KeyValuePair<bool, string>> PutMstReportIsDel(long reportCode)
        {
            var wRet = new KeyValuePair<bool, string>(false, string.Empty);

            try
            {
                string wUri = $"{NKKWebAccess.BaseUri}{RldConst.Uri.WEB_APP}";

                // 編集の場合は PUT 処理
                NKKWebAccessResponse wRestRet = await NKKWebAccess.Put("帳票マスタデータ更新", $"{wUri}{RldConst.Uri.POST_MST_REPORT}/{reportCode.ToString()}/is_del", string.Empty, NKKWebAccess.SKIP_OTP);

                // 結果取得
                wRet = new KeyValuePair<bool, string>(
                    wRestRet.isLogin && wRestRet.response.IsSuccessStatusCode,
                    $"{wRestRet.response.StatusCode}:{wRestRet.response.ReasonPhrase}");

            }
            catch (Exception ex)
            {
                // 例外情報を生成
                var wEx = new ApplicationException("データ更新に失敗しました。", ex);
                // 例外情報を記録(画面にメッセージボックスを表示)
                RldUtility.RecordException(wEx, false);
            }

            return wRet;

        }

        // del #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
        //private void dgvData_RowEnter(object sender, DataGridViewCellEventArgs e)
        //{
        //    try
        //    {

        //        // 削除ボタンの使用可否を切り替える
        //        bool delEnabled = true;
        ////        if (!this.chkDispAll.Checked)
        //        {
        //            // 削除されたデータを表示していない場合はtrue
        //            delEnabled = true;
        //        }
        //        else if (this.dgvData.Rows[e.RowIndex].DataBoundItem is GridBindData wData)
        //        {
        //            // 削除されていない場合のみ削除ボタンを有効にする
        //            delEnabled = (wData.IsDelete == GridBindData.VAL_IS_DELETED_OFF);
        //        }
        //        else
        //        {
        //            // DataGridViewの行データが取得できない場合は削除させない.通常はこのコードに到達しない
        //            delEnabled = false;
        //        }

        //        // 変化したら削除ボタンの有効/無効を設定する
        //        if (this.BtnDelete.Enabled != delEnabled)
        //        {
        //            this.BtnDelete.Enabled = delEnabled;
        //        }

        //    }
        //    catch (Exception ex)
        //    {
        //        // 例外情報を記録(画面にメッセージボックスを表示)
        //        RldUtility.RecordException(ex, false);
        //    }

        //}
        // del #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end

        #endregion

        #region IRldMainMenuChild Implements

        /// <summary>
        /// 親フォームからのイベント受信用
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        public void ReceiveNotifyInfo(object sender, RldMainMenuNotifyInfoEventArgs e)
        {
            switch( e.InfoType ) {
                case RldMainMenuNotifyInfoEventArgs.EnumInfoType.Deactive:
                    this.ActionOfCheckDeactive((RldMainMenuNotifyInfoCheckDeactiveEventArgs)e);
                    break;

                default:
                    break;
            }
        }

        #endregion

        #region 非アクティブ化確認処理

        /// <summary>
        /// 非アクティブ化確認処理を行います。
        /// </summary>
        /// <param name="e"></param>
        private void ActionOfCheckDeactive(RldMainMenuNotifyInfoCheckDeactiveEventArgs e)
        {
            // 未保存の編集データがない場合は抜ける
            if( this.CanEditReportDesign ) return;

            // 確認
            var wRes = RldMsgBox.Show(
                this.ParentForm, 
                "新規作成モードに切り替えると編集内容が破棄されます。\r\n続行してよろしいですか？", 
                "確認してください", 
                MessageBoxButtons.YesNo, 
                MessageBoxIcon.Question, 
                MessageBoxDefaultButton.Button2);

            // 続行する場合
            if( wRes == DialogResult.Yes )
                this.DataRollback();
            // 続行しない場合
            else
                e.Cancel = true;
        }

        #endregion

        private void FrmMainMenuChildEditReport_Load(object sender, EventArgs e)
        {

            try
            {

                // マウスカーソルを待機状態にする
                Cursor.Current = Cursors.WaitCursor;

                // オンラインの時プリンター選択コンボボックスの定義
                if (SignInLib.SignIn.SignInInfo.IsOnline)
                {
                    // プリンター選択コンボボックスの定義
                    // mod #11502 レイアウトデザイナに2件の管理者用機能を追加 高 start
                    //SetPrinterComboBoxItems(this.dgvData);
                    SetPrinterComboBoxItems(this.dgvData, LayoutDesignerUtilityLib.LayoutDesignerUtility.CurrentFacilityCd);
                    // mod #11502 レイアウトデザイナに2件の管理者用機能を追加 高 end
                }

                // add 2021-02-19 No.517:FNW帳票レイアウトコンバート 趙 start
                // 帳票種別選択コンボボックスの初期値設定
                SetReportTypeComboBoxItems();
                // add 2021-02-19 No.517:FNW帳票レイアウトコンバート 趙 end

            }
            catch (Exception ex)
            {
                Cursor.Current = Cursors.Default;
                RldUtility.RecordException(this, ex, true);
            }
            finally
            {
                Cursor.Current = Cursors.Default;
            }

        }

        /// <summary>
        /// プリンターコンボボックスの項目を設定する
        /// </summary>
        /// <param name="dgvData">DataGridView</param>
        // mod #11502 レイアウトデザイナに2件の管理者用機能を追加 高 start
        private static async void SetPrinterComboBoxItems(DataGridView dgvData, string lblFacilityCd)
        // mod #11502 レイアウトデザイナに2件の管理者用機能を追加 高 end
        {
            // mod #11502 レイアウトデザイナに2件の管理者用機能を追加 高 start
            //string wUri = $"{NKKWebAccess.BaseUri}{RldConst.Uri.WEB_APP}/api/printers/{string.Empty}";
            if (string.IsNullOrEmpty(lblFacilityCd))
                return;

            String wUri = String.Format("{0}{1}/api/printers/{2}",
                NKKWebAccess.BaseUri,
                RldConst.Uri.WEB_APP, lblFacilityCd);
            // mod #11502 レイアウトデザイナに2件の管理者用機能を追加 高 end
            var wRestRet = await NKKWebAccess.Get("プリンターマスタ一覧取得", wUri, NKKWebAccess.SKIP_OTP);
            if (wRestRet.isLogin && wRestRet.response.IsSuccessStatusCode)
            {
                System.Diagnostics.Debug.Print(wRestRet.strContent);
                var mstPrinters = RldJsonDataSerializeHelper<List<Data.MstPrinterData>>.Deserialize(wRestRet.strContent);

                const string cnName = "Name";
                const string cnCd = "Cd";

                // mst_printerから取得する
                var dt = new DataTable();
                dt.Columns.Add(cnName, typeof(string));
                dt.Columns.Add(cnCd, typeof(long));

                // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe 1201 start
                DataRow rowNull = dt.NewRow();
                rowNull[cnName] = "";
                rowNull[cnCd] = -1;
                dt.Rows.Add(rowNull);
                // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe 1201 end

                // DataTableに1行追加する
                foreach (var item in mstPrinters)
                {
                    DataRow row = dt.NewRow();
                    row[cnName] = item.DispPrinterName;
                    row[cnCd] = item.PrinterCd;
                    dt.Rows.Add(row);
                }

                // プリンター選択コンボボックスの定義
                var column = new DataGridViewComboBoxColumn
                {
                    DataSource = dt,
                    HeaderText = "既定のプリンター",
                    DataPropertyName = "DefaultPrinter",
                    // add #11501 レイアウトデザイナのユーザビリティ改善 高 start
                    Name = "DefaultPrinter",
                    // add #11501 レイアウトデザイナのユーザビリティ改善 高 end
                    DisplayMember = cnName,
                    ValueMember = cnCd
                };

                // DataGridViewにプリンター選択コンボボックスをセットする
                dgvData.Columns.Remove(dgvData.Columns[2]);
                dgvData.Columns.Insert(2, column);

            }

        }

        private void dgvData_DataError(object sender, DataGridViewDataErrorEventArgs e)
        {
            System.Diagnostics.Debug.Print($"{e.Exception.ToString()} ColumnIndex:{e.ColumnIndex.ToString()} RowIndex:{e.RowIndex.ToString()}");
        }

        // add 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 start
        /// <summary>
        /// DataGridViewの Click イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvData_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {

            // ヘッダのクリック時は抜ける
            if (e.RowIndex < 0 || e.ColumnIndex < 0)
            {
                return;
            }

            // セルが読取専用の場合は抜ける
            if (dgvData[e.ColumnIndex, e.RowIndex].ReadOnly)
            {
                return;
            }

            // 該当行にバインドされているパラメータデータを取得
            if (!(this.dgvData.Rows[e.RowIndex].DataBoundItem is GridBindData wData))
            {
                return;
            }

            // 列チェック用
            bool wFuncEqualColumn(GridBindData.EnumDataIndex aIndex)
            {
                return e.ColumnIndex == dgvData.Columns[GridBindData.GetPropertyName(aIndex)].Index;
            }

            // ボタン[版数]クリック時
            if (wFuncEqualColumn(GridBindData.EnumDataIndex.ButtonLayoutHistoryText))
            {
                // 画面表示フラグ
                bool layoutHistoryDlgOpen = true;

                // 編集内容を取得
                var wList = this.GetChangedGridBindDataList();

                // 未保存の編集内容があり
                if (wList.Count > 0)
                {
                    // 確認メッセージを表示します。
                    var wRes = RldMsgBox.Show(
                        this.ParentForm,
                        "帳票履歴画面に切り替えると修正内容が破棄されます。\r\n続行してよろしいですか？",
                        "確認してください",
                        MessageBoxButtons.YesNo,
                        MessageBoxIcon.Question,
                        MessageBoxDefaultButton.Button2);

                    if (wRes == DialogResult.No)
                    {
                        // [いいえ]の場合、画面表示が表示されません
                        layoutHistoryDlgOpen = false;
                    }
                }

                // 画面表示する
                if (layoutHistoryDlgOpen)
                {
                    // 帳票更新履歴情報画面
                    using (var wDlg = new frmLayoutHistoryList())
                    {
                        // 必要なパラメータをセット
                        wDlg.SelectReportData = wData.ReportData;

                        // ダイアログの表示を要求
                        DialogResult dlgResult = wDlg.ShowDialog();

                        // OKボタン押下時は帳票更新履歴情報を更新
                        if (dlgResult == DialogResult.OK)
                        {
                            if (wDlg.UpdateResult)
                            {
                                // add #11501 レイアウトデザイナのユーザビリティ改善 高 start
                                int savedSelectedRowIndex = -1;
                                int firstDisplayedRowIndex = -1;

                                if (this.dgvData.SelectedRows.Count > 0)
                                {
                                    savedSelectedRowIndex = this.dgvData.SelectedRows[0].Index;
                                }
                                else if (this.dgvData.CurrentCell != null)
                                {
                                    savedSelectedRowIndex = this.dgvData.CurrentCell.RowIndex;
                                }

                                if (this.dgvData.FirstDisplayedScrollingRowIndex >= 0)
                                {
                                    firstDisplayedRowIndex = this.dgvData.FirstDisplayedScrollingRowIndex;
                                }
                                // add #11501 レイアウトデザイナのユーザビリティ改善 高 end
                                // 成功した場合は RDS から読み直す
                                this.MakeGridData();
                                this.DataRead();

                                // add #11501 レイアウトデザイナのユーザビリティ改善 高 start
                                LFunc_SelectionUpdate();

                                /// <summary>
                                /// (ローカル関数) パラメータリスト表示用データグリッドの選択状態を更新します。
                                /// </summary>
                                void LFunc_SelectionUpdate()
                                {
                                    if (this.dgvData.IsDisposed)
                                    {
                                        return;
                                    }

                                    if (this.dgvData.InvokeRequired)
                                    {
                                        this.Invoke((MethodInvoker)delegate
                                        {
                                            LFunc_SelectionUpdate();
                                        });
                                    }
                                    else
                                    {
                                        this.dgvData.Focus();

                                        if (savedSelectedRowIndex >= 0 && savedSelectedRowIndex < this.dgvData.Rows.Count)
                                        {
                                            this.dgvData.CurrentCell = this.dgvData.Rows[savedSelectedRowIndex].Cells[0];
                                            this.dgvData.Rows[savedSelectedRowIndex].Selected = true;

                                            if (firstDisplayedRowIndex >= 0 && firstDisplayedRowIndex < this.dgvData.Rows.Count)
                                            {
                                                this.dgvData.FirstDisplayedScrollingRowIndex = firstDisplayedRowIndex;
                                            }
                                            else
                                            {
                                                this.dgvData.FirstDisplayedScrollingRowIndex = savedSelectedRowIndex;
                                            }
                                        }
                                    }
                                }
                                // add #11501 レイアウトデザイナのユーザビリティ改善 高 end
                                // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
                                this.ButtonEnableUpdate = true;
                                // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
                                // 画面下部のボタンを戻す
                                this.CanEditReportDesign = true;
                            }
                        }
                    }

                }
            }
        }
        // add 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 end
        // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 start
        /// <summary>
        /// 施設リストを作成します。
        /// </summary>
        /// <param name="aTarget"></param>
        private bool MakeFacilityData()
        {
            bool rt = false;
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
                else {
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
                    LayoutDesignerUtility.CurrentFacilityName = this.rldFacillitySearch.Text;
                    // add #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 start
                    RldLib.FilterDataSet.ClearFilterData();
                    // add #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない 高 end
                }
                if ("1".Equals(SignInLib.SignIn.SignInInfo.UserType))
                {
                    this.rldFacillitySearch.Visible = true;
                }
                // add #11502 レイアウトデザイナに2件の管理者用機能を追加 高 start
                if ("1".Equals(SignInLib.SignIn.SignInInfo.UserType))
                {
                    this.btnCsvSave.Visible = true;
                    this.btnTemp.Visible = true;
                }
                // add #11502 レイアウトデザイナに2件の管理者用機能を追加 高 end

                rt = true;
            }
            else
            {
                // 親へ通知
                this.NotifyInfo?.Invoke(this, new RldMainMenuNotifyInfoCannotAccess() { });
            }

            return rt;
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
            if (String.IsNullOrEmpty(facilityName)) {
                this.dgvFacilityData.SuspendLayout();
                this.dgvFacilityData.DataSource = this.allFacilitylist;
                this.dgvFacilityData.Columns[0].Visible = false;
                this.dgvFacilityData.ResumeLayout();
            }
            List<MstFacilityData> list = new List<MstFacilityData>(); 
            list = this.allFacilitylist.Where(ele => ele.facilityName.Contains(facilityName)).ToList();
            if (list != null) {
                this.dgvFacilityData.SuspendLayout();
                this.dgvFacilityData.DataSource = list;
                this.dgvFacilityData.Columns[0].Visible = false;
                this.dgvFacilityData.ResumeLayout();
            }
        }

        /// <summary>
        /// rldFacillitySearchの TextChanged イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void rldFacillitySearch_TextChanged(object sender, EventArgs e)
        {
            // add #11501 レイアウトデザイナのユーザビリティ改善 高 start
            // 初期状態へ
            this.txtFree.Clear();
            this.InitReportTypeTreeView();
            // add #11501 レイアウトデザイナのユーザビリティ改善 高 end

            this.MakeGridData();
            this.DataRead();
            // add #11502 レイアウトデザイナに2件の管理者用機能を追加 高 start
            // オンラインの時プリンター選択コンボボックスの定義
            if (SignInLib.SignIn.SignInInfo.IsOnline)
            {
                // プリンター選択コンボボックスの定義
                SetPrinterComboBoxItems(this.dgvData, this.lblFacilityCd.Text);
            }
            // add #11502 レイアウトデザイナに2件の管理者用機能を追加 高 end
        }
        // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 end

        // add 2021-02-19 No.517:FNW帳票レイアウトコンバート 趙 start
        /// <summary>
        /// [FNWの帳票を取り込む]ボタンの Click イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnConvert_Click(object sender, EventArgs e)
        {
            // 画面の種別を確認する
            if (!this.TypeCheckForExchangeReport()) return;

            OpenFileDialog fileDialog = new OpenFileDialog();
            fileDialog.Multiselect = true;
            fileDialog.Title = "ファイルを選択してください";
            // mod #10476 取り込み機能で「FNW帳票」かどうかをチェックする 高 start
            //fileDialog.Filter = "すべてのファイル(*xls*)|*.xls*";
            fileDialog.Filter = "FNW帳票ファイル (*.xls)|*.xls";
            // mod #10476 取り込み機能で「FNW帳票」かどうかをチェックする 高 end
            if (fileDialog.ShowDialog() == DialogResult.OK)
            {
                // コンバート用データ項目リストを読み込む
                if (!this.ConvertLoadDataList()) return;

                // add #10476 取り込み機能で「FNW帳票」かどうかをチェックする 高 start
                // 選択し確定したファイルがFNSiの帳票ファイルであるかどうかをチェックし
                if (checkFNW(fileDialog.FileName) == false)
                {
                    const String MSG_TITLE = "エラー";

                    // エラー
                    RldMsgBox.Show(this.ParentForm, @"FNWの帳票ファイルではありません", MSG_TITLE, MessageBoxButtons.OK, MessageBoxIcon.Exclamation);

                    return;
                }
                // add #10476 取り込み機能で「FNW帳票」かどうかをチェックする 高 end

                // 親へ通知
                this.NotifyInfo?.Invoke(this, new RldMainMenuNotifyInfoRequestConvertReportEventArgs()
                {
                    ReportType = reportType,
                    ConvertFilePath = fileDialog.FileName
                });
                // add #8335 FNW帳票取込みの動作に問題あり 夏 start
                RldLib.StrOldFileName = System.IO.Path.GetFileNameWithoutExtension(fileDialog.FileName);
                // add #8335 FNW帳票取込みの動作に問題あり 夏 end

            }
            else
            {
                return;
            }
        }

        /// <summary>
        /// 帳票の種別を確認します。
        /// </summary>
        /// <returns></returns>
        private Boolean TypeCheckForExchangeReport()
        {
            const String MSG_TITLE = "確認してください";

            // del #8335 FNW帳票取込みの動作に問題あり 夏 start
            // 未選択帳票種別の場合はエラー
            // if (reportType == "")
            // {
            //     RldMsgBox.Show(this.ParentForm, @"帳票の種別を選択してください。", MSG_TITLE, MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
            //     this.combType.Focus();
               
            //     return false;
            // }
            // del #8335 FNW帳票取込みの動作に問題あり 夏 end
            return true;
        }

        /// <summary>
        /// ComboBoxItem コンボボックス用クラス定義
        /// </summary>
        public class ComboBoxItem
        {
            public string Text = "";
            public string Value = "";

            public ComboBoxItem(string _text, string _value)
            {
                Text = _text;
                Value = _value;
            }

            public override string ToString()
            {
                return Text;
            }
        }

        /// <summary>
        /// ComboBoxItem 帳票種別選択コンボボックスを初期化します。
        /// </summary>
        private void SetReportTypeComboBoxItems()
        {
            ComboBoxItem[] itemValue = new ComboBoxItem[11];
            itemValue[0] = new ComboBoxItem("透析レポート", "Dialysis");
            itemValue[1] = new ComboBoxItem("単患者帳票", "OnePatient");
            itemValue[2] = new ComboBoxItem("複数患者帳票", "MultiPatient");
            itemValue[3] = new ComboBoxItem("準備リスト", "EquipmentList");
            itemValue[4] = new ComboBoxItem("配布リスト(ベッド)", "DistributeListBed");
            itemValue[5] = new ComboBoxItem("配布リスト（物品）", "DistributeListEquipment");
            itemValue[6] = new ComboBoxItem("装置帳票", "Device");
            itemValue[7] = new ComboBoxItem("ラベル", "Label");
            itemValue[8] = new ComboBoxItem("紹介状", "ReferralLetter");
            itemValue[9] = new ComboBoxItem("単集計", "OneTotal");
            itemValue[10] = new ComboBoxItem("複数集計", "MultiTotal");

            // del #8335 FNW帳票取込みの動作に問題あり 夏 start
            // combType.Items.AddRange(itemValue);
            // del #8335 FNW帳票取込みの動作に問題あり 夏 end
        }

        /// <summary>
        /// 帳票種別の SelectedIndexChanged イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void combType_SelectedIndexChanged(object sender, EventArgs e)
        {
            // del #8335 FNW帳票取込みの動作に問題あり 夏 start
            // ComboBoxItem myItem = (ComboBoxItem)combType.Items[combType.SelectedIndex];
            // reportType = myItem.Value.ToString();
            // del #8335 FNW帳票取込みの動作に問題あり 夏 end
        }

        /// <summary>
        /// コンバート用データ項目リストを読み込みます。
        /// </summary>
        /// <returns></returns>
        private bool ConvertLoadDataList()
        {
            bool wRet = false;

            try
            {
                // リストをクリア
                RldLib.CurrentLayoutData.DataItemConvertList.Clear();

                // コンバート用データ項目リストファイル読込
                var wXmlDoc = new TdcLib.TdcXml();
                if (!wXmlDoc.Load(RldUtility.ConvertDataListFilePath))
                {
                    throw new System.ApplicationException(@"コンバート用データ項目リストファイルの読み込みに失敗しました。", wXmlDoc.Error);
                }

                // 指定された帳票種別の項目一覧を取得
                // @"reportTable/report[@type='Dialysis']/dataTable/data"
                string wXPathData = string.Format(@"{0}/{1}/{2}",
                    RldConst.ItemConvertList.TAG_REPORTTABLE,
                    RldConst.ItemConvertList.TAG_DATATABLE,
                    RldConst.ItemConvertList.TAG_DATA);

                foreach (System.Xml.XmlNode wXmlDataNode in wXmlDoc.Document.SelectNodes(wXPathData))
                {
                    var wData = new DesignItemConvertListData();

                    // 属性を列挙してプロパティをセット
                    foreach (System.Xml.XmlAttribute wAttribute in wXmlDataNode.Attributes)
                    {
                        if (RldLib.IsEqualXmlAttName(wAttribute.Name, RldConst.ItemConvertList.ATT_DATA_DATANAME))
                        {
                            wData.DataName = wAttribute.Value;
                        }
                        else if (RldLib.IsEqualXmlAttName(wAttribute.Name, RldConst.ItemConvertList.ATT_DATA_NEW_DATANAME))
                        {
                            wData.NewDataName = wAttribute.Value;
                        }
                    }

                    // リストへ追加
                    RldLib.CurrentLayoutData.DataItemConvertList.Add(wData);
                }

                wRet = true;
            }
            catch (Exception ex)
            {
                // 例外時処理はこの方法で統一する
                // 例外情報を生成
                var wEx = new System.ApplicationException("コンバート用データ項目一覧の読込に失敗しました。", ex);
                // 例外情報を記録(画面にメッセージボックスを表示)
                this.ActionOfRequestRecordException(this, new RldDesignNotifyInfoRequestRecordExceptionEventArgs(wEx, true));
            }

            return wRet;
        }

        /// <summary>
        /// 例外情報記録要求受信時処理を行います。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void ActionOfRequestRecordException(object sender, RldDesignNotifyInfoRequestRecordExceptionEventArgs e)
        {
            RldUtility.RecordException(this, e.Exception, e.IsShowMessage);
        }
        // add 2021-02-19 No.517:FNW帳票レイアウトコンバート 趙 end

        // add 8394 動作に関する指摘 吉 start
        private void dgvData_CellValidating(object sender, DataGridViewCellValidatingEventArgs e)
        {
            var wList = this.GetChangedGridBindDataList();
            var wDataGridView = (DataGridView)sender;
            if (null != wDataGridView.EditingControl)
            {
                var text = wDataGridView.EditingControl.Text;
                if (text.IndexOfAny(System.IO.Path.GetInvalidFileNameChars()) >= 0)
                {
                    const String MSG_TITLE = "確認してください";
                    RldMsgBox.Show(this, "帳票名に指定できない文字が含まれています。", MSG_TITLE, MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                    e.Cancel = true;
                    dgvData.CancelEdit();
                    System.Windows.Forms.SendKeys.Send("^a");
                    // this.CanEditReportDesign = true;
                }
                
            }
            
        }

        // add #11502 レイアウトデザイナに2件の管理者用機能を追加 高 start
        // read temp file. 
        private void btnTemp_Click(object sender, EventArgs e)
        {
            string fileName = string.Empty;

            // ファイル選択ダイアログを表示
            using (var wDlg = new OpenFileDialog())
            {

                wDlg.Title = "ファイルを選択してください";
                wDlg.Filter = "一時ファイル(*.xlsx) | *.xlsx";
                wDlg.InitialDirectory = Properties.Settings.Default.LastTempDirectory;

                if (wDlg.ShowDialog(this) == DialogResult.OK)
                {
                    fileName = wDlg.FileName;
                    Properties.Settings.Default.LastTempDirectory = Path.GetDirectoryName(wDlg.FileName);
                    Properties.Settings.Default.Save();
                }
            }

            if (string.IsNullOrEmpty(fileName))
                return;

            // 選択し確定したファイルがFNSiの帳票ファイルであるかどうかをチェックし
            if (checkFnis(fileName) == false)
            {
                const String MSG_TITLE = "エラー";

                // エラー
                RldMsgBox.Show(this.ParentForm, @"FNSiの帳票ファイルではありません。", MSG_TITLE, MessageBoxButtons.OK, MessageBoxIcon.Exclamation);

                return;
            }

            // add #12050 FNW帳票コンバートで維持されない設定がある 高 start
            RldLib.CurrentLayoutData.DataItemConvertList.Clear();
            // add #12050 FNW帳票コンバートで維持されない設定がある 高 end

            // send notify to main menu
            // 親へ通知
            this.NotifyInfo?.Invoke(this, new RldMainMenuNotifyInfoRequestTempReportEventArgs()
            {
                TempFilePath = fileName
            });
        }

        // when button(一覧をCSVに保存) is click, show dialog, and save csv file.
        private void btnCsvSave_Click(object sender, EventArgs e)
        {
            string csvFile = string.Empty;

            string fileName = string.Format("帳票マスタ_{0}_{1}.csv"
                                     , LayoutDesignerUtilityLib.LayoutDesignerUtility.CurrentFacilityCd
                                    , DateTime.Now.ToString("yyyyMMddHHmmss")
                                    );

            // ファイル保存ダイアログ表示
            using (var wDlg = new SaveFileDialog())
            {

                wDlg.FileName = fileName;
                wDlg.Filter = "CSVファイル(*.csv) | *.csv";
                wDlg.InitialDirectory = Properties.Settings.Default.LastCsvDirectory;

                if (wDlg.ShowDialog(this) == DialogResult.OK)
                {
                    csvFile = wDlg.FileName;
                    Properties.Settings.Default.LastCsvDirectory = Path.GetDirectoryName(wDlg.FileName);
                    Properties.Settings.Default.Save();
                }
            }

            if (string.IsNullOrEmpty(csvFile))
                return;

            // write csv file
            writeCsv(csvFile);
        }

        /// <summary>
        /// CSV出力用文字列エスケープ処理
        /// </summary>
        /// <param name="str">対象の文字列</param>
        private void EscapeForCsv(ref string str)
        {
            if (string.IsNullOrEmpty(str))
                return;

            // ダブルクオートは重ねてエスケープ
            str = str.Replace("\"", "\"\"");

            if ((0 <= str.IndexOfAny(new char[] { '\"', ',' })) || (0 <= str.IndexOf("\r\n")) || (0 <= str.IndexOf("\n")))
            {
                // データの中にダブルクオートまたはカンマまたは改行コードが入っている場合はダブルクオートで全体を囲む
                str = "\"" + str + "\"";
            }
        }

        // get printer name form ComboBoxCell of datagridview
        private string GetSelectedPrinterName(DataGridViewRow wRow)
        {
            if (wRow != null)
            {
                var comboBoxCell = wRow.Cells[(Int32)GridBindData.EnumDataIndex.DefaultPrinter] as DataGridViewComboBoxCell;

                if (comboBoxCell != null)
                {
                    // cd of printer
                    var selectedValue = comboBoxCell.Value;

                    // name of printer
                    var displayText = comboBoxCell.FormattedValue.ToString();

                    return displayText;

                }
            }
            return null;
        }

        // write main menu list to csv
        private void writeCsv(string fileName)
        {
            try
            {
                StringBuilder st = new StringBuilder();
                bool result;
                DateTime dateTime;

                // open csv file for write
                using (var writer = new StreamWriter(fileName, false, Encoding.GetEncoding("Shift_JIS")))
                {
                    // write head
                    st.Clear();
                    bool firstFlag = true;

                    // output header
                    foreach (var head in head_key)
                    {
                        if (!firstFlag)
                            st.Append(",");

                        st.Append(head);
                        firstFlag = false;
                    }

                    writer.WriteLine(st.ToString());

                    // loop, write csv record from main menu list
                    foreach (DataGridViewRow wRow in this.dgvData.Rows)
                    {
                        // バインドデータを取得
                        if (!(wRow.DataBoundItem is GridBindData wData)) continue;
                        if (wRow.Visible == false) continue;

                        st.Clear();
                        string field;

                        //report_cd
                        st.Append(wData.ReportData.ReportCode.ToString());
                        st.Append(",");

                        // 帳票種別
                        field = wData.ReportClassName;
                        EscapeForCsv(ref field);
                        st.Append(field);
                        st.Append(",");

                        // 帳票名
                        field = wData.ReportName;
                        EscapeForCsv(ref field);
                        st.Append(field);
                        st.Append(",");

                        // 既定のプリンター
                        field = GetSelectedPrinterName(wRow);
                        EscapeForCsv(ref field);
                        st.Append(field);
                        st.Append(",");

                        // 表示
                        field = wData.IsDisplay;
                        EscapeForCsv(ref field);
                        st.Append(field);
                        st.Append(",");

                        // 更新日時
                        field = wData.UpdateDate;
                        EscapeForCsv(ref field);
                        st.Append(field);
                        st.Append(",");

                        // 更新者
                        field = wData.UpdateUser;
                        EscapeForCsv(ref field);
                        st.Append(field);
                        st.Append(",");

                        // 作成者
                        field = wData.CreateUser;
                        EscapeForCsv(ref field);
                        st.Append(field);
                        st.Append(",");

                        // 版数
                        field = wData.ButtonLayoutHistoryText;
                        EscapeForCsv(ref field);
                        st.Append(field);
                        st.Append(",");

                        // 表示順
                        field = wData.DispOrder.ToString();
                        EscapeForCsv(ref field);
                        st.Append(field);
                        st.Append(",");

                        // 帳票更新履歴が有りか？
                        if (wData.ReportData.ReportHstInfo != null && wData.ReportData.ReportHstInfo.ReportHstList != null && wData.ReportData.ReportHstInfo.ReportHstList.Count > 0)
                        {
                            // 適用データを取得する
                            var lastRecord = wData.ReportData.ReportHstInfo.ReportHstList.FirstOrDefault(p => p.UpdDate == wData.ReportData.ReportHstInfo.ReportHstList.Max(x => x.UpdDate));

                            // 最終版数
                            field = lastRecord.CtlNo;
                            EscapeForCsv(ref field);
                            st.Append(field);
                            st.Append(",");

                            // 最終版更新日時
                            field = lastRecord.UpdDate;
                            result = DateTime.TryParseExact(field, "yyyyMMddHHmmss", CultureInfo.InvariantCulture, DateTimeStyles.None, out dateTime);
                            if (result)
                            {
                                field = dateTime.ToString("yyyy/MM/dd HH:mm:ss");
                                EscapeForCsv(ref field);
                                st.Append(field);
                            }
                            st.Append(",");

                            // 最終版更新者
                            field = lastRecord.UpdUserName;
                            EscapeForCsv(ref field);
                            st.Append(field);
                        }
                        else
                        {
                            // 最終版数
                            st.Append(",");

                            // 最終版更新日時
                            st.Append(",");

                            // 最終版更新者
                        }

                        writer.WriteLine(st.ToString());
                    }
                }
            }
            catch (Exception ex)
            {
                return;
            }
        }

        //  選択し確定したファイルがFNSiの帳票ファイルであるかどうかをチェック
        private bool checkFnis(string fileName)
        {
            bool bRet = true;

            try
            {
                // open execl file
                if (RldLib.XlHelper.Open(fileName) == false)
                {
                    return false;
                }

                // 設定データ読み込み
                DesignSettingData designSettingData = RldLib.XlHelper.GetSettingData();

                // 帳票種別
                if (string.IsNullOrEmpty(designSettingData.ReportClass))
                    return false;

                // check file is Fnsi format
                if (RldLib.XlHelper.checkFnsiParam() == false)
                    return false;
            }
            catch (Exception ex)
            {
            }
            finally
            {
                // close execl file
                RldLib.XlHelper.Close();

                // 後で使用される可能性があるため非表示にしておく
                RldLib.XlHelper.XlApp.Application.Visible = false;
            }

            return bRet;
        }

        // add #11501 レイアウトデザイナのユーザビリティ改善 高 start
        // process ctrl + c in form
        protected override bool ProcessCmdKey(ref Message msg, Keys keyData)
        {
            if (keyData == (Keys.Control | Keys.C))
            {
                // datagridview is focus
                if (this.dgvData.ContainsFocus)
                {
                    if (this.dgvData.CurrentCell != null)
                    {
                        if (this.dgvData.EditingControl != null)
                        {
                            // copy 帳票名 to Clipboard
                            CopySecondCellToClipboard();
                            return true;
                        }
                    }
                }
            }
            return base.ProcessCmdKey(ref msg, keyData);
        }

        // copy 帳票名 to Clipboard
        private void CopySecondCellToClipboard()
        {
            try
            {
                // select row
                if (this.dgvData.SelectedRows.Count > 0)
                {
                    DataGridViewRow row = this.dgvData.SelectedRows[0];

                    // 帳票名
                    if (row.Cells[(Int32)GridBindData.EnumDataIndex.ReportName].Value != null)
                    {
                        var currentEditingControl = this.dgvData.EditingControl as DataGridViewTextBoxEditingControl;
                        if (currentEditingControl != null)
                        {
                            // copy 帳票名 to Clipboard
                            string copyText = currentEditingControl.SelectedText;
                            if (string.IsNullOrEmpty(copyText))
                            {
                                Clipboard.Clear();
                            }
                            else
                                Clipboard.SetText(copyText);
                        }
                    }
                    else
                    {
                        Clipboard.Clear();
                    }
                }
            }
            catch(Exception)
            { }
        }

        // disp checkbox process
        private void chkDisp_CheckedChanged(object sender, EventArgs e)
        {
            // データグリッドを更新する
            LFunc_dgvUpdate();
            /// <summary>
            /// (ローカル関数) リスト表示用データグリッドを更新します。
            /// </summary>
            void LFunc_dgvUpdate()
            {
                if (this.dgvData.IsDisposed)
                {
                    return;
                }

                if (this.dgvData.InvokeRequired)
                {
                    this.Invoke((MethodInvoker)delegate
                    {
                        LFunc_dgvUpdate();
                    });
                }
                else
                {
                    this.dgvData.SuspendLayout();
                    chkDisp_changed();
                    this.dgvData.ResumeLayout();
                }
            }
        }

        // if disp checkbox is true, disp == "0", not display
        private void chkDisp_changed()
        {
            try
            {
                // clear current row
                this.dgvData.ClearSelection();
                this.dgvData.CurrentCell = null;

                if (chkDisp.Checked == true)
                {
                    // loop, not display recore for not check from main menu list
                    for (int i = this.dgvData.Rows.Count - 1; i >= 0; i--)
                    {
                        DataGridViewRow row = this.dgvData.Rows[i];

                        // new line
                        if (row.IsNewRow) continue;

                        // get disp value
                        var displayCell = row.Cells[(Int32)GridBindData.EnumDataIndex.IsDisplay];
                        if (displayCell?.Value == null) continue;

                        // not diaplay
                        if ("0".Equals(displayCell.Value.ToString()))
                        {
                            row.Visible = false;
                        }
                    }
                }
                else
                {
                    // loop, not display recore for not check from main menu list
                    for (int i = this.dgvData.Rows.Count - 1; i >= 0; i--)
                    {
                        DataGridViewRow row = this.dgvData.Rows[i];
                        row.Visible = true;
                    }
                }
            }
            catch (Exception)
            { }

        }

        // txtFree enter key down
        private void txtFree_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                e.SuppressKeyPress = true;
                btnSearchOK.PerformClick();
            }
        }

        // save window size to Properties.Settings, format is json.
        public void saveEditReport()
        {
            saveEditReportColumnst();
            saveEditReportTreeView();
            saveEditReportCurrentPos();
            saveEditReportDisp();
        }

        // save window size to Properties.Settings, format is json.
        private void saveEditReportColumnst()
        {
            StringBuilder outJson = new StringBuilder();
            outJson.Append("{")
                .AppendFormat("\"ReportTypeName\": \"{0}\",", this.dgvData.Columns[GridBindData.GetPropertyName(GridBindData.EnumDataIndex.ReportTypeName)].Width)
                .AppendFormat("\"DefaultPrinter\": \"{0}\",", this.dgvData.Columns[GridBindData.GetPropertyName(GridBindData.EnumDataIndex.DefaultPrinter)].Width)
                .AppendFormat("\"UpdateDate\": \"{0}\",", this.dgvData.Columns[GridBindData.GetPropertyName(GridBindData.EnumDataIndex.UpdateDate)].Width)
                .AppendFormat("\"UpdateUser\": \"{0}\",", this.dgvData.Columns[GridBindData.GetPropertyName(GridBindData.EnumDataIndex.UpdateUser)].Width)
                .AppendFormat("\"CreateUser\": \"{0}\"", this.dgvData.Columns[GridBindData.GetPropertyName(GridBindData.EnumDataIndex.CreateUser)].Width)
                .Append("}");
            Properties.Settings.Default.MainMenuEditColumns = outJson.ToString();
            Properties.Settings.Default.Save();

            outJson.Length = 0;
        }

        // save 帳票種別のチェック状態および、フリーワード to Properties.Settings, format is json.
        private void saveEditReportTreeView()
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

            Properties.Settings.Default.MainMenuEditNode = outJson.ToString();
            Properties.Settings.Default.Save();

            outJson.Length = 0;
        }

        // save current position and scroll position to Properties.Settings, format is json.
        private void saveEditReportCurrentPos()
        {
            StringBuilder outJson = new StringBuilder();
            int savedSelectedRowIndex = -1;
            int firstDisplayedRowIndex = -1;

            if (this.dgvData.SelectedRows.Count > 0)
            {
                savedSelectedRowIndex = this.dgvData.SelectedRows[0].Index;
            }
            else if (this.dgvData.CurrentCell != null)
            {
                savedSelectedRowIndex = this.dgvData.CurrentCell.RowIndex;
            }

            if (this.dgvData.FirstDisplayedScrollingRowIndex >= 0)
            {
                firstDisplayedRowIndex = this.dgvData.FirstDisplayedScrollingRowIndex;
            }

            outJson.Append("{")
                .AppendFormat("\"SelectedRowIndex\": \"{0}\",", savedSelectedRowIndex)
                .AppendFormat("\"FirstDisplayedRowIndex\": \"{0}\"", firstDisplayedRowIndex)
                .Append("}");
            Properties.Settings.Default.MainMenuEditCurrent = outJson.ToString();
            Properties.Settings.Default.Save();

            outJson.Length = 0;
        }

        // save 削除帳票フラグ and 非表示帳票フラグ to Properties.Settings, format is json.
        private void saveEditReportDisp()
        {
            StringBuilder outJson = new StringBuilder();
            outJson.Append("{")
                .AppendFormat("\"DispDelChk\": \"{0}\",", this.chkDispAll.Checked ? "1" : "0")
                .AppendFormat("\"DispChk\": \"{0}\"", (this.chkDisp.Checked) ? "1" : "0")
                .Append("}");
            Properties.Settings.Default.MainMenuEditDisp = outJson.ToString();
            Properties.Settings.Default.Save();

            outJson.Length = 0;
        }

        // restore Columns size
        private void restoreEditColumns()
        {
            bool bRet;

            try
            {
                this.dgvData.SuspendLayout();

                // restore width of Columns
                Dictionary<String, String> json = NKKWebAccess.GetJsonData(Properties.Settings.Default.MainMenuEditColumns);
                if (json.Count() > 0)
                {
                    // 帳票種別
                    if (json["ReportTypeName"] != "")
                    {
                        bRet = int.TryParse(json["ReportTypeName"], out int lNum);
                        if (bRet)
                            this.dgvData.Columns[GridBindData.GetPropertyName(GridBindData.EnumDataIndex.ReportTypeName)].Width = lNum;
                    }

                    // 既定のプリンター
                    if (json["DefaultPrinter"] != "")
                    {
                        bRet = int.TryParse(json["DefaultPrinter"], out int lNum);
                        if (bRet)
                            this.dgvData.Columns[GridBindData.GetPropertyName(GridBindData.EnumDataIndex.DefaultPrinter)].Width = lNum;
                    }

                    // 更新日時
                    if (json["UpdateDate"] != "")
                    {
                        bRet = int.TryParse(json["UpdateDate"], out int lNum);
                        if (bRet)
                            this.dgvData.Columns[GridBindData.GetPropertyName(GridBindData.EnumDataIndex.UpdateDate)].Width = lNum;
                    }

                    // 更新者
                    if (json["UpdateUser"] != "")
                    {
                        bRet = int.TryParse(json["UpdateUser"], out int lNum);
                        if (bRet)
                            this.dgvData.Columns[GridBindData.GetPropertyName(GridBindData.EnumDataIndex.UpdateUser)].Width = lNum;
                    }

                    // 作成者
                    if (json["CreateUser"] != "")
                    {
                        bRet = int.TryParse(json["CreateUser"], out int lNum);
                        if (bRet)
                            this.dgvData.Columns[GridBindData.GetPropertyName(GridBindData.EnumDataIndex.CreateUser)].Width = lNum;
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
        private void restoreEditReportTreeView()
        {
            bool bRet;

            try
            {
                string nodeText = string.Empty;
                CheckState wCheckState;

                this.dgvData.SuspendLayout();

                // restore 帳票種別
                Dictionary<String, String> json = NKKWebAccess.GetJsonData(Properties.Settings.Default.MainMenuEditNode);
                if (json.Count() > 0)
                {
                    foreach (RldTriStateTreeNode wChildNode in this.rldTriStateTreeViewSearch.Nodes)
                    {
                        nodeText = wChildNode.Text;
                        if (string.IsNullOrEmpty(nodeText) == false)
                        {
                            if(json.ContainsKey(nodeText))
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

        // restore current pos of scrollbar
        private void restoreEditCurrentPos()
        {
            bool bRet;
            int savedSelectedRowIndex = -1;
            int firstDisplayedRowIndex = -1;

            try
            {
                this.dgvData.SuspendLayout();

                Dictionary<String, String> json = NKKWebAccess.GetJsonData(Properties.Settings.Default.MainMenuEditCurrent);
                if (json.Count() > 0)
                {
                    // current
                    if (json["SelectedRowIndex"] != "")
                    {
                        bRet = int.TryParse(json["SelectedRowIndex"], out int lNum);
                        if (bRet)
                            savedSelectedRowIndex = lNum;
                    }

                    // scroll position
                    if (json["FirstDisplayedRowIndex"] != "")
                    {
                        bRet = int.TryParse(json["FirstDisplayedRowIndex"], out int lNum);
                        if (bRet)
                            firstDisplayedRowIndex = lNum;
                    }

                    setCurrentPos(savedSelectedRowIndex, firstDisplayedRowIndex);
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

        // restore  削除帳票フラグ from Properties.Settings, format is json.
        private void restoreEditCurrentDisp()
        {
            bool bRet;

            try
            {
                this.dgvData.SuspendLayout();

                Dictionary<String, String> json = NKKWebAccess.GetJsonData(Properties.Settings.Default.MainMenuEditDisp);
                if (json.Count() > 0)
                {
                    // 削除帳票フラグ
                    if (json["DispDelChk"] != "")
                    {
                        bRet = int.TryParse(json["DispDelChk"], out int lNum);
                        if (bRet)
                        {
                            if (lNum == 1)
                                chkDispAll.Checked = true;
                            else
                                chkDispAll.Checked = false;
                        }
                    }

                    // 非表示帳票フラグ
                    // del #12460 「非表示の帳票を隠す」にチェックが入っている状態で編集画面から戻ると非表示設定の帳票が表示される 高 start
                    //if (json["DispChk"] != "")
                    //{
                    //    bRet = int.TryParse(json["DispChk"], out int lNum);
                    //    if (bRet)
                    //    {
                    //        if (lNum == 1)
                    //            chkDisp.Checked = true;
                    //        else
                    //            chkDisp.Checked = false;
                    //    }
                    //}
                    // del #12460 「非表示の帳票を隠す」にチェックが入っている状態で編集画面から戻ると非表示設定の帳票が表示される 高 end
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

        // add #12460 「非表示の帳票を隠す」にチェックが入っている状態で編集画面から戻ると非表示設定の帳票が表示される 高 start
        // restore  非表示帳票フラグ from Properties.Settings, format is json.
        private void restoreEditCurrentDispChk()
        {
            bool bRet;

            try
            {
                this.dgvData.SuspendLayout();

                Dictionary<String, String> json = NKKWebAccess.GetJsonData(Properties.Settings.Default.MainMenuEditDisp);
                if (json.Count() > 0)
                {
                    // 非表示帳票フラグ
                    if (json["DispChk"] != "")
                    {
                        bRet = int.TryParse(json["DispChk"], out int lNum);
                        if (bRet)
                        {
                            if (lNum == 1)
                                chkDisp.Checked = true;
                            else
                                chkDisp.Checked = false;
                        }
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
        // add #12460 「非表示の帳票を隠す」にチェックが入っている状態で編集画面から戻ると非表示設定の帳票が表示される 高 end

        private void setCurrentPos(int savedSelectedRowIndex, int firstDisplayedRowIndex)
        {
            LFunc_Invoke();

            void LFunc_Invoke()
            {
                if (this.dgvData.IsDisposed)
                {
                    return;
                }

                if (this.dgvData.InvokeRequired)
                {
                    this.Invoke((MethodInvoker)delegate
                    {
                        LFunc_Invoke();
                    });
                }
                else
                {
                    this.dgvData.Focus();

                    if (savedSelectedRowIndex >= 0 && savedSelectedRowIndex < this.dgvData.Rows.Count)
                    {
                        var targetRow = this.dgvData.Rows[savedSelectedRowIndex];
                        if (targetRow.Visible)
                        {
                            if (firstDisplayedRowIndex >= 0 && firstDisplayedRowIndex < this.dgvData.Rows.Count)
                            {
                                var scrollRow = this.dgvData.Rows[firstDisplayedRowIndex];
                                if (scrollRow.Visible)
                                {
                                    this.dgvData.FirstDisplayedScrollingRowIndex = firstDisplayedRowIndex;
                                }
                            }
                            else
                            {
                                this.dgvData.FirstDisplayedScrollingRowIndex = savedSelectedRowIndex;
                            }

                            this.dgvData.CurrentCell = this.dgvData.Rows[savedSelectedRowIndex].Cells[0];
                            this.dgvData.Rows[savedSelectedRowIndex].Selected = true;
                        }
                        else
                        {
                            SelectFirstVisibleRow();
                        }
                    }
                    else
                    {
                        SelectFirstVisibleRow();
                    }
                }
            }
        }

        private void SelectFirstVisibleRow()
        {
            foreach (DataGridViewRow row in this.dgvData.Rows)
            {
                if (row.Visible)
                {
                    this.dgvData.ClearSelection();
                    row.Selected = true;
                    this.dgvData.CurrentCell = row.Cells[0];
                    this.dgvData.FirstDisplayedScrollingRowIndex = row.Index;
                    break;
                }
            }
        }
        // add #11501 レイアウトデザイナのユーザビリティ改善 高 end
        // add #11502 レイアウトデザイナに2件の管理者用機能を追加 高 end
        // add 8394 動作に関する指摘 吉 end

        // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
        private void updateCellsState()
        {
            try
            {
                //this.dgvData.SuspendLayout();
                for (int wRowIndex = 0; wRowIndex < this.dgvData.RowCount; wRowIndex++)
                {
                    DataGridViewRow wRow = this.dgvData.Rows[wRowIndex];

                    // 現在のデータを取得
                    if (!(wRow.DataBoundItem is GridBindData wData))
                    {
                        continue;
                    }

                    if (wData.ReportData.ReportCode < 0)
                    {
                        // 帳票名
                        wRow.Cells[(Int32)GridBindData.EnumDataIndex.ReportName].ReadOnly = true;

                        // 削除
                        wRow.Cells[(Int32)GridBindData.EnumDataIndex.IsDeleted].ReadOnly = true;
                        var deletedCell = wRow.Cells[(Int32)GridBindData.EnumDataIndex.IsDeleted];
                        if (deletedCell is DataGridViewCheckBoxCell checkBox)
                        {
                            checkBox.Selected = false;
                            checkBox.ReadOnly = true;
                            checkBox.FlatStyle = FlatStyle.Popup;
                        }
                        wData.IsDelete = "0";

                        // 版数
                        wRow.Cells[(Int32)GridBindData.EnumDataIndex.ButtonLayoutHistoryText].ReadOnly = true;
                        var historyButtonCell = wRow.Cells[(Int32)GridBindData.EnumDataIndex.ButtonLayoutHistoryText];
                        if (historyButtonCell is DataGridViewButtonCell button)
                        {
                            button.ReadOnly = true;
                            button.Style.ForeColor = System.Drawing.Color.DarkGray;
                        }
                        wData.ButtonLayoutHistoryText = "";
                    }
                }
            }
            catch (Exception)
            {
                // TODO:
            }
            finally
            {
                //this.dgvData.ResumeLayout();
            }
        }
        // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end

        // add #10476 取り込み機能で「FNW帳票」かどうかをチェックする 高 start
        private bool checkFNW(string fileName)
        {
            bool bRet = true;

            try
            {
                if (string.IsNullOrEmpty(fileName))
                    return false;

                // open execl file
                if (RldLib.XlHelper.Open(fileName) == false)
                {
                    return false;
                }

                // 設定データ読み込み
                DesignSettingData designSettingData = RldLib.XlHelper.GetSettingData();

                // 帳票種別
                if (string.IsNullOrEmpty(designSettingData.ReportClass))
                    return false;

                // check file is Fnsi format
                if (RldLib.XlHelper.checkFnwParam() == false)
                    return false;
            }
            catch (Exception ex)
            {
            }
            finally
            {
                // close execl file
                RldLib.XlHelper.Close();

                // 後で使用される可能性があるため非表示にしておく
                RldLib.XlHelper.XlApp.Application.Visible = false;
            }

            return bRet;
        }
        // add #10476 取り込み機能で「FNW帳票」かどうかをチェックする 高 end
    }
}
