using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

using Excel = Microsoft.Office.Interop.Excel;

using RldUtility = LayoutDesignerUtilityLib.LayoutDesignerUtility;

namespace LayoutDesigner
{
    /// <summary>
    /// デザイナーウィンドウ内グループ編集画面
    /// </summary>
    public partial class frmDesignChildLayoutGroup : LayoutDesignerUtilityLib.Controls.frmRldBase, IRldDesignRecvOnlyColleague, IRldDesignSendOnlyColleague
    {
        #region メンバ定数定義

        /// <summary>
        /// 下部プロパティウィンドウの列インデックス(プロパティ名)
        /// </summary>
        private const int DETAIL_COL_INDEX_NAME = 0;
        /// <summary>
        /// 下部プロパティウィンドウの列インデックス(プロパティ値)
        /// </summary>
        private const int DETAIL_COL_INDEX_VALUE = 1;

        #endregion

        #region メンバイベント定義

        /// <summary>
        /// 通知用イベント
        /// </summary>
        public event EventHandler<RldDesignNotifyInfoEventArgs> NotifyInfo;

        #endregion

        #region 生成と破棄

        /// <summary>
        /// デザイナーウィンドウ内グループ編集画面の新しいインスタンスを初期化します。
        /// </summary>
        public frmDesignChildLayoutGroup()
        {
            InitializeComponent();

            // データグリッドビューの列を自動生成しないようにする
            this.dgvGroupList.AutoGenerateColumns = false;
            // データグリッドビューの表示を調整する
            RldGridRCAttributeReflector.ApplyToColumn(this.dgvGroupList, typeof(DesignGroupData).GetProperties());

            // イベントハンドラ割り当て
            this.dgvGroupList.CellClick += new DataGridViewCellEventHandler(this.dgvGroupList_CellClick);
            this.dgvGroupList.CurrentCellDirtyStateChanged += new EventHandler(this.dgvGroupList_CurrentCellDirtyStateChanged);
            this.dgvGroupList.DataBindingComplete += new DataGridViewBindingCompleteEventHandler(this.dgvGroupList_DataBindingComplete);
            this.dgvGroupList.RowEnter += new DataGridViewCellEventHandler(this.dgvGroupList_RowEnter);

            this.dgvGroupDetail.CellClick += new DataGridViewCellEventHandler(this.dgvGroupDetail_CellClick);
            this.dgvGroupDetail.CellEndEdit += new DataGridViewCellEventHandler(this.dgvGroupDetail_CellEndEdit);
            this.dgvGroupDetail.CurrentCellDirtyStateChanged += new EventHandler(this.dgvGroupDetail_CurrentCellDirtyStateChanged);

            // グループリストデータの変更受信
            RldLib.CurrentLayoutData.DesignGroupList.ListChanged += new ListChangedEventHandler(this.DesignGroupList_ListChanged);

            // add #11501 レイアウトデザイナのユーザビリティ改善 高 start
            RldLib.CurrentLayoutData.DesignGroupList.RequestRefreshGroupUI += RefreshButtonColumns;
            // add #11501 レイアウトデザイナのユーザビリティ改善 高 end
        }

        #endregion

        #region メンバ関数定義(override)

        /// <summary>
        /// Form.Load イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);

            if (base.DesignMode) return;

            // 画面をクリア
            this.DataClear(true);
        }

        /// <summary>
        /// Form.Shown イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnShown(EventArgs e)
        {
            base.OnShown(e);

            // 画面にデータを読み込む
            this.DataRead();
        }

        #endregion

        #region メンバ関数定義

        /// <summary>
        /// 画面の入力内容をクリアします。
        /// </summary>
        /// <param name="aIsKeyClear">(未使用)</param>
        private void DataClear(Boolean aIsKeyClear)
        {
            if (aIsKeyClear)
            {
                this.dgvGroupList.DataMember = null;
                this.dgvGroupList.DataSource = null;
            }
            this.dgvGroupDetail.RowCount = 0;
        }

        /// <summary>
        /// 画面にデータを読み込みます。
        /// </summary>
        private void DataRead()
        {
            try
            {
                this.dgvGroupList.SuspendLayout();

                this.dgvGroupList.DataMember = null;
                this.dgvGroupList.DataSource = RldLib.CurrentLayoutData.DesignGroupList;

                // add #11501 レイアウトデザイナのユーザビリティ改善 高 start
                var column = this.dgvGroupList.Columns[DesignGroupData.GetPropertyName(DesignGroupData.EnumDataIndex.DataCategory)];
                if (column != null)
                {
                    // データグリッドを更新する
                    LFunc_dgvUpdate();
                    /// <summary>
                    /// (ローカル関数) リスト表示用データグリッドを更新します。
                    /// </summary>
                    void LFunc_dgvUpdate()
                    {
                        if (this.dgvGroupList.IsDisposed)
                        {
                            return;
                        }

                        if (this.dgvGroupList.InvokeRequired)
                        {
                            this.Invoke((MethodInvoker)delegate
                            {
                                LFunc_dgvUpdate();
                            });
                        }
                        else
                        {
                            var direction = ListSortDirection.Ascending;
                            dgvGroupList.Sort(column, direction);
                        }
                    }
                }
                // add #11501 レイアウトデザイナのユーザビリティ改善 高 end
                //add 20211011 #5598 複数集計，単集計ページを変更して読み取り専用を追加する  鄭  start
                // del #11106 集計帳票で集計範囲外のグループ項目が出力されない 高 start
                //if ("OneTotal".Equals(RldLib.CurrentLayoutData.DesignSettingData.ReportClass) || "MultiTotal".Equals(RldLib.CurrentLayoutData.DesignSettingData.ReportClass))
                //{

                //    for (int i = 0; i < dgvGroupList.ColumnCount; i++)
                //    {
                //        var IsNewPage = this.dgvGroupList.Columns[i].Name;
                //        if (IsNewPage.Equals("IsNewPage"))
                //        {
                //            dgvGroupList.Columns[i].ReadOnly = true;
                //            //var wRow = this.dgvGroupList.Rows[i];
                //            //var wValueCell = wRow.Cells[(Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.ItemValue];
                //            //wValueCell.Style.ForeColor = System.Drawing.Color.Gray;
                //            DataGridViewCheckBoxColumn dgvc = (DataGridViewCheckBoxColumn)dgvGroupList.Columns[i];
                //            //dgvc.DefaultCellStyle.BackColor = Color.Gray;
                //            dgvc.FlatStyle = FlatStyle.Popup;
                //            dgvGroupList.Columns[i].Frozen = true;
                //        }

                //    }
                //}
                // del #11106 集計帳票で集計範囲外のグループ項目が出力されない 高 end

                // add #9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。 donghao start
                // mod #11106 集計帳票で集計範囲外のグループ項目が出力されない 高 start
                if (RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_ONE_TOTAL
                 || RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_MULTI_TOTAL
                 || (RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_REFERRAL_LETTER && "1".Equals(RldLib.totalLayoutData.ReportType)))
                {
                    // mod #11501 レイアウトデザイナのユーザビリティ改善 高 start
                    //if (!String.IsNullOrEmpty(frmDesignChildLayoutTotal.totalTotal))
                    if (RldLib.CurrentLayoutData.DesignSettingData.HasTemplete == RldConst.SettingData.VAL_HAS_TEMPLETE_YES)
                    // mod #11501 レイアウトデザイナのユーザビリティ改善 高 end
                    {
                        string totalAddress = RldLib.totalLayoutData.UnitVAddress.Trim() + "," + RldLib.totalLayoutData.UnitHAddress.Trim();
                        //List<string> totalTotalList = new List<string>(frmDesignChildLayoutTotal.totalTotal.Trim().Split(','));
                        List<string> totalAddressList = new List<string>(totalAddress.Split(','));
                        // mod #11106 集計帳票で集計範囲外のグループ項目が出力されない 高 end
                        List<DesignGroupData> groupList = RldLib.CurrentLayoutData.DesignGroupList.ToList();

                        for (int i = 0; i < dgvGroupList.Rows.Count; i++)
                        {
                            // mod #11501 レイアウトデザイナのユーザビリティ改善 高 start
                            //String groupName = this.dgvGroupList.Rows[i].Cells[2].Value.ToString();
                            String groupName = string.Empty;
                            if (this.dgvGroupList.Rows[i].Cells[2].Value != null)
                                groupName = this.dgvGroupList.Rows[i].Cells[2].Value.ToString();
                            // mod #11501 レイアウトデザイナのユーザビリティ改善 高 end
                            // mod #9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。 高 start
                            // mod #11106 集計帳票で集計範囲外のグループ項目が出力されない 高 start
                            String IsInTempleteName = this.dgvGroupList.Rows[i].Cells[6].Value.ToString();

                            if (IsInTempleteName == RldConst.ParamData.VAL_IS_IN_TEMPLETE_IN)
                            {
                                dgvGroupList.Rows[i].Cells[3].ReadOnly = true;
                                var wValueCell = dgvGroupList.Rows[i].Cells[3];
                                DataGridViewCheckBoxCell checkBox = wValueCell as DataGridViewCheckBoxCell;
                                checkBox.FlatStyle = FlatStyle.Popup;
                                if ((dgvGroupList.Rows[i].DataBoundItem is DesignGroupData wData))
                                    wData.CanEditNewPage = false;
                            }
                            else
                            {
                                foreach (var wList in totalAddressList)
                                {
                                    // mod #11106 集計帳票で集計範囲外のグループ項目が出力されない 高 start
                                    foreach (var wDataParam in RldLib.CurrentLayoutData.DesignParamList)
                                    {
                                        if (wDataParam.CellAddress.Equals(wList))
                                        {
                                            //if (wList.Contains(groupName))
                                            if (groupName == wDataParam.GroupName)
                                            {
                                                //if (IsInTempleteName == RldConst.ParamData.VAL_IS_IN_TEMPLETE_OUT)
                                                {
                                                    dgvGroupList.Rows[i].Cells[3].ReadOnly = true;
                                                    var wValueCell = dgvGroupList.Rows[i].Cells[3];
                                                    DataGridViewCheckBoxCell checkBox = wValueCell as DataGridViewCheckBoxCell;
                                                    checkBox.FlatStyle = FlatStyle.Popup;
                                                    // del #12059 グループリストのスクロールが不正 高 start
                                                    //dgvGroupList.Rows[i].Frozen = true;
                                                    // del #12059 グループリストのスクロールが不正 高 end
                                                    if ((dgvGroupList.Rows[i].DataBoundItem is DesignGroupData wData))
                                                        if (wData.CanEditNewPage != false)
                                                            wData.CanEditNewPage = false;
                                                    break;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            // mod #9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。 高 end
                        }
                    }
                }
                // mod #11106 集計帳票で集計範囲外のグループ項目が出力されない 高 end
                // add #9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。 donghao end
                // add 20211011 #5598 複数集計，単集計ページを変更して読み取り専用を追加する 鄭  end
                // add #8314 グループタブの表示不正 王占宇 start
                // del #11501 レイアウトデザイナのユーザビリティ改善 高 start
                //for (int i = 0; i < dgvGroupList.ColumnCount; i++)
                //{
                //    var GroupName = this.dgvGroupList.Columns[i].Name;
                //    if (GroupName.Equals("GroupName"))
                //    {
                //        dgvGroupList.Columns[i].ReadOnly = true;
                //    }

                //}
                // del #11501 レイアウトデザイナのユーザビリティ改善 高 end
                // add #8314 グループタブの表示不正 王占宇 end
                // 1行目を選択しておく
                if (this.dgvGroupList.RowCount > 0) this.dgvGroupList[0, 0].Selected = true;
            }
            catch (Exception ex)
            {
                this.SendNotifyInfo(new RldDesignNotifyInfoRequestRecordExceptionEventArgs(ex, true));
            }
            finally
            {
                this.dgvGroupList.ResumeLayout();
            }
        }

        /// <summary>
        /// グループ明細表示用グリッドの表示を更新します。
        /// </summary>
        private void UpdateGroupDetailGrid(DesignGroupData aData, Boolean aIsDataClear)
        {
            //add #9484 因島帳票の表示不具合（帳票種別：紹介状）dongzhaolong start
            List<string> readOnly = new List<string>();
            //add #9484 因島帳票の表示不具合（帳票種別：紹介状）dongzhaolong end

            // 画面を一旦クリア
            if (aIsDataClear) this.DataClear(false);

            // 選択中のデータがない場合は抜ける
            if (aData == null) return;

            // 明細表示するプロパティを取得(EoCを除外)
            var wProperties = DesignGroupData.Properties.Where(ele => ele.Name != DesignGroupData.GetPropertyName(DesignGroupData.EnumDataIndex.EoC)).ToArray();

            try
            {
                this.dgvGroupDetail.SuspendLayout();

                // グループ明細表示用データグリッドビューの内容をリセット
                if (aIsDataClear) RldGridRCAttributeReflector.ApplyToRow(this.dgvGroupDetail, wProperties);

                for (int wRowIndex = 0; wRowIndex < this.dgvGroupDetail.RowCount; wRowIndex++)
                {

                    var wRow = this.dgvGroupDetail.Rows[wRowIndex];
                    var wValueCell = wRow.Cells[(Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.ItemValue];

                    String wKeyCellValue = wRow.Cells[(Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.Property].Value as String;

                    // 選択された行のデータを配置する
                    {
                        /// <summary>
                        /// プロパティ名が一致するか確認します。
                        /// </summary>
                        /// <param name="aIndex"></param>
                        Boolean wFuncIsEqualPropName(DesignGroupData.EnumDataIndex aIndex) => wKeyCellValue == DesignGroupData.GetPropertyName(aIndex);

                        /// <summary>
                        /// セルを読取専用に設定します。
                        /// </summary>
                        void wFuncSetCellReadOnly(Boolean aIsSetReadOnly) =>
                            RldDataGridViewStaticMethods.SetCellReadOnly(
                                this.dgvGroupDetail,
                                wRowIndex,
                                (Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.ItemValue,
                                aIsSetReadOnly);

                        // カテゴリ
                        if (wFuncIsEqualPropName(DesignGroupData.EnumDataIndex.DataCategory))
                        {
                            wValueCell.Value = aData.DataCategory;
                        }
                        // クラス
                        else if (wFuncIsEqualPropName(DesignGroupData.EnumDataIndex.DataClass))
                        {
                            wValueCell.Value = aData.DataClass;
                        }
                        // グループ名
                        else if (wFuncIsEqualPropName(DesignGroupData.EnumDataIndex.GroupName))
                        {
                            wValueCell.Value = aData.GroupName;
                        }
                        // 改ページ
                        else if (wFuncIsEqualPropName(DesignGroupData.EnumDataIndex.IsNewPage))
                        {
                            //edit #9484 因島帳票の表示不具合（帳票種別：紹介状）dongzhaolong start
                            if (readOnly.Count == 0)
                            {
                                if (!aData.CanEditNewPage)
                                {
                                    readOnly.Add(aData.GroupName);
                                    DataGridViewCheckBoxCell checkBox = wValueCell as DataGridViewCheckBoxCell;
                                    checkBox.ReadOnly = !aData.CanEditNewPage;
                                    checkBox.FlatStyle = FlatStyle.Popup;
                                }
                                else
                                {
                                    DataGridViewCheckBoxCell checkBox = wValueCell as DataGridViewCheckBoxCell;
                                    checkBox.ReadOnly = !aData.CanEditNewPage;
                                    checkBox.FlatStyle = FlatStyle.Standard;
                                }
                                
                                wValueCell.Value = aData.IsNewPage;
                            }
                            else
                            {
                                if (!readOnly.Contains(aData.GroupName))
                                {
                                    if (!aData.CanEditNewPage)
                                    {
                                        readOnly.Add(aData.GroupName);
                                        DataGridViewCheckBoxCell checkBox = wValueCell as DataGridViewCheckBoxCell;
                                        checkBox.ReadOnly = !aData.CanEditNewPage;
                                        checkBox.FlatStyle = FlatStyle.Popup;
                                    }
                                    else
                                    {
                                        DataGridViewCheckBoxCell checkBox = wValueCell as DataGridViewCheckBoxCell;
                                        checkBox.ReadOnly = !aData.CanEditNewPage;
                                        checkBox.FlatStyle = FlatStyle.Standard;
                                    }
                                    wValueCell.Value = aData.IsNewPage;
                                }
                            }
                            //edit #9484 因島帳票の表示不具合（帳票種別：紹介状）dongzhaolong end
                            //add 20211011 #5598 複数集計，単集計ページを変更して読み取り専用を追加する 鄭  start
                            // del #11106 集計帳票で集計範囲外のグループ項目が出力されない 高 start
                            //if ("OneTotal".Equals(RldLib.CurrentLayoutData.DesignSettingData.ReportClass) || "MultiTotal".Equals(RldLib.CurrentLayoutData.DesignSettingData.ReportClass))
                            //{
                            //    wValueCell.ReadOnly = true;
                            //    DataGridViewCheckBoxCell dgvc = (DataGridViewCheckBoxCell)wValueCell;
                            //    dgvc.FlatStyle = FlatStyle.Popup;
                            //    //wValueCell.Frozen = true;

                            //}
                            // del #11106 集計帳票で集計範囲外のグループ項目が出力されない 高 end
                            // add 20211011 #5598 複数集計，単集計ページを変更して読み取り専用を追加する 鄭  end                          
                        }
                        // フィルタ(編集ボタン)
                        else if (wFuncIsEqualPropName(DesignGroupData.EnumDataIndex.ButtonEditFilterText))
                        {
                            if (aData.FilterType == RldConst.FilterType.Group.OBSKIND)
                                wFuncSetCellReadOnly(!aData.CanEditFilter);
                            // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 start
                            else if (aData.FilterType == RldConst.FilterType.Group.MEDICINE)    // 薬剤
                                wFuncSetCellReadOnly(!aData.CanEditFilter);
                            else if (aData.FilterType == RldConst.FilterType.Group.EQUIP)       // 医材
                                wFuncSetCellReadOnly(!aData.CanEditFilter);
                            else if (aData.FilterType == RldConst.FilterType.Group.CATEGORY)
                                wFuncSetCellReadOnly(!aData.CanEditFilter);
                            // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 end
                            // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe start
                            else if (aData.FilterType == RldConst.FilterType.Group.PECEIPT)    // レセプト
                                wFuncSetCellReadOnly(!aData.CanEditFilter);
                            // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe end
                            // add #11625 クラス「指示履歴」の仕様変更② 高 start
                            else if (aData.FilterType == RldConst.FilterType.Group.LOGTARGET)    // 指示履歴
                                wFuncSetCellReadOnly(!aData.CanEditFilter);
                            // add #11625 クラス「指示履歴」の仕様変更② 高 end
                            // add #12006 感染症がフィルタできない 高 start
                            else if (aData.FilterType == RldConst.FilterType.Group.INFECTION)    // 感染症
                                wFuncSetCellReadOnly(!aData.CanEditFilter);
                            // add #12006 感染症がフィルタできない 高 end
                            // add #10370 装置帳票向けの「水質管理」データ項目を検討する 高 start
                            // mod #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
                            else if (aData.FilterType == RldConst.FilterType.Group.WQTESTTYPE)    // 水質検査種別
                                wFuncSetCellReadOnly(!aData.CanEditFilter);
                            // mod #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end
                            // add #10370 装置帳票向けの「水質管理」データ項目を検討する 高 end
                            // add #11789 【因島】準備リストを医材と薬剤と分けて出力することができない limingzhe start
                            else if (aData.FilterType == RldConst.FilterType.Group.EQUIP_DIA)    // 器材
                                wFuncSetCellReadOnly(!aData.CanEditFilter);
                            // add #11789 【因島】準備リストを医材と薬剤と分けて出力することができない limingzhe end
                            else
                            {
                                wValueCell.ToolTipText = SignInLib.SignIn.SignInInfo.IsOnline ? String.Empty : "オフラインモードではフィルタを設定出来ません";
                                //update 8615-15 zhu start
                                //wFuncSetCellReadOnly(SignInLib.SignIn.SignInInfo.IsOnline ? !aData.CanEditFilter : true);
                                wFuncSetCellReadOnly(SignInLib.SignIn.SignInInfo.IsOnline ? !false : true);
                                //update 8615-15 zhu start
                            }
                        }
                        // フィルタ状態
                        else if (wFuncIsEqualPropName(DesignGroupData.EnumDataIndex.FilterState))
                        {
                            if (aData.FilterType == RldConst.FilterType.Group.OBSKIND)
                                wValueCell.Value = aData.FilterState;
                            // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 start
                            else if (aData.FilterType == RldConst.FilterType.Group.MEDICINE)    // 薬剤
                                wValueCell.Value = aData.FilterState;
                            else if (aData.FilterType == RldConst.FilterType.Group.EQUIP)       // 医材
                                wValueCell.Value = aData.FilterState;
                            else if (aData.FilterType == RldConst.FilterType.Group.CATEGORY)
                                wValueCell.Value = aData.FilterState;
                            // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 end
                            // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe start
                            else if (aData.FilterType == RldConst.FilterType.Group.PECEIPT)    //レセプト
                                wValueCell.Value = aData.FilterState;
                            // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe end
                            // add #11625 クラス「指示履歴」の仕様変更② 高 start
                            else if (aData.FilterType == RldConst.FilterType.Group.LOGTARGET)    // 指示履歴
                                wValueCell.Value = aData.FilterState;
                            // add #11625 クラス「指示履歴」の仕様変更② 高 end
                            // add #12006 感染症がフィルタできない 高 start
                            else if (aData.FilterType == RldConst.FilterType.Group.INFECTION)    // 感染症
                                wValueCell.Value = aData.FilterState;
                            // add #12006 感染症がフィルタできない 高 end
                            // add #10370 装置帳票向けの「水質管理」データ項目を検討する 高 start
                            // mod #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
                            else if (aData.FilterType == RldConst.FilterType.Group.WQTESTTYPE)    // 水質検査種別
                                wValueCell.Value = aData.FilterState;
                            // mod #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end
                            // add #10370 装置帳票向けの「水質管理」データ項目を検討する 高 end
                            // add #11789 【因島】準備リストを医材と薬剤と分けて出力することができない limingzhe start
                            else if (aData.FilterType == RldConst.FilterType.Group.EQUIP_DIA)    // 器材
                                wValueCell.Value = aData.FilterState;
                            // add #11789 【因島】準備リストを医材と薬剤と分けて出力することができない limingzhe end
                            //update 8615-15 zhu start
                            //else
                            //wValueCell.Value = SignInLib.SignIn.SignInInfo.IsOnline ? aData.FilterState : String.Empty;
                            //update 8615-15 zhu end
                        }
                        // テンプレート内外
                        else if (wFuncIsEqualPropName(DesignGroupData.EnumDataIndex.IsInTemplete))
                        {
                            wValueCell.Value = aData.IsInTemplete;
                        }
                    }

                    // セルを取得しなおす
                    wValueCell = wRow.Cells[(Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.ItemValue];

                    // 読取専用のセルの前景色を変更
                    {
                        if (wValueCell.ReadOnly)
                        {
                            wRow.Cells[(Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.ItemName].Style.ForeColor = System.Drawing.Color.DarkGray;
                            wValueCell.Style.ForeColor = System.Drawing.Color.DarkGray;
                        }
                    }
                }
            }
            catch
            {
                throw;
            }
            finally
            {
                this.dgvGroupDetail.ResumeLayout();
            }
        }

        /// <summary>
        /// 通知用イベントを発行します。
        /// </summary>
        /// <param name="e"></param>
        protected virtual void SendNotifyInfo(RldDesignNotifyInfoEventArgs e) => this.NotifyInfo?.Invoke(this, e);

        #endregion

        #region メンバ関数定義(Mediator)

        /// <summary>
        /// Mediator からのイベントを受信します。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        public void ReceiveNotifyInfo(Object sender, RldDesignNotifyInfoEventArgs e)
        {
            switch (e.InfoType)
            {
                case RldDesignNotifyInfoEventArgs.EnumInfoType.RequestRemoveAllParam:
                    // 全パラメータ編集データ削除要求受信
                    this.ActionOfRemoveAllParam(sender, (RldDesignNotifyInfoRequestRemoveAllParamEventArgs)e);
                    break;

                // add #11501 レイアウトデザイナのユーザビリティ改善 高 start
                case RldDesignNotifyInfoEventArgs.EnumInfoType.NotifySelectedParamChanged:
                    // 選択パラメータ変更通知受信
                    this.ActionOfNotifySelectedParamChanged((RldDesignNotifyInfoNotifySelectedParamChangedEventArgs)e);
                    break;
                // add #11501 レイアウトデザイナのユーザビリティ改善 高 end
                default:
                    break;
            }
        }

        #endregion

        /// <summary>
        /// 全パラメータ編集データ削除要求受信時処理を記述します。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void ActionOfRemoveAllParam(Object sender, RldDesignNotifyInfoRequestRemoveAllParamEventArgs e)
        {
            try
            {
                // 画面をクリア
                this.DataClear(true);
                // バインド対象データをすべて削除
                RldLib.CurrentLayoutData.DesignGroupList.Clear();
                // バインドし直す
                this.DataRead();
            }
            catch (Exception ex)
            {
                // TODO:
            }
        }

        #region コントロールイベントハンドラ定義

        /// <summary>
        /// グループリスト表示用 DataGridView の CellClick イベントハンドラ
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvGroupList_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            // ヘッダのクリック時は抜ける
            if (e.RowIndex < 0 || e.ColumnIndex < 0) return;

            // セルが読取専用の場合は抜ける
            if (this.dgvGroupList[e.ColumnIndex, e.RowIndex].ReadOnly) return;

            // 該当行にバインドされているパラメータデータを取得
            if (!(this.dgvGroupList.Rows[e.RowIndex].DataBoundItem is DesignGroupData wData)) return;

            // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 start
            if (RldLib.chkExeclDialog(2) == false)
                return;
            // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 end

            // 列チェック用
            Boolean wFuncEqualColumn(DesignGroupData.EnumDataIndex aIndex) =>
                e.ColumnIndex == this.dgvGroupList.Columns[DesignGroupData.GetPropertyName(aIndex)].Index;

            // フィルタ編集クリック時
            if (wFuncEqualColumn(DesignGroupData.EnumDataIndex.ButtonEditFilterText))
            {
                // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 start
                bool gorupData = true;
                // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 end
                switch (wData.FilterType)
                {

                    case RldConst.FilterType.Parameter.EXAMINE:
                    case RldConst.FilterType.Parameter.EXAM_SET:
					// del #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
                    //// add FNSI-699,700,751 装置帳票の記録簿対応 夏 start
                    //case RldConst.FilterType.Parameter.INSPECTION:
                    //// add FNSI-699,700,751 装置帳票の記録簿対応 夏 end
					// del #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
                    // add FNSI-5915 李 start
                    // del #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 start
                    // case RldConst.FilterType.Parameter.CATEGORY:
                    // del #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 end

                        // add FNSI-5915 李 end
                        // 検査項目・検査セット選択画面
                        using (var wDlg = new frmSelectExamFilter())
                        {
                            //del #8615 zhu start
                            //wDlg.Path = wData.DataPath;
                            //del #8615 zhu end
                            // add FNSI-699,700,751 装置帳票の記録簿対応 夏 start
                            if ("Inspection".Equals(wData.FilterType))
                            {
                                wDlg.FilterType = frmSelectExamFilter.EnumFilterType.Inspection;
                            }
                            // add FNSI-5915 李 start
                            else if ("Category".Equals(wData.FilterType))
                            {
                                wDlg.FilterType = frmSelectExamFilter.EnumFilterType.Category;
                            }
                            // add FNSI-5915 李 end
                            else
                            {
                                // add FNSI-699,700,751 装置帳票の記録簿対応 夏 end
                                wDlg.FilterType = wData.FilterType == RldConst.FilterType.Parameter.EXAMINE ? frmSelectExamFilter.EnumFilterType.ExaminItem : frmSelectExamFilter.EnumFilterType.ExaminSet;
                            }
                            wDlg.FilterData = wData.FilterData;

                            // ダイアログの表示を要求
                            SendNotifyInfo(new RldDesignNotifyInfoRequestOpenDialogEventArgs(wDlg)
                            {
                                IsAllWindowLock = true,
                                IsProtectLayoutSheet = true
                            });

                            // OKボタン押下時はフィルタを更新
                            if (wDlg.DialogResult == DialogResult.OK)
                            {
                                wData.FilterData = wDlg.FilterData;
                                wData.FilterState = RldConst.ParamData.VAL_FILTER_STATE_YES;

                                //// 同一グループへフィルタを適用する場合
                                //update #8615 zhu start
                                //if (wDlg.IsApplySameGroup)
                                //{
                                //update #8615 zhu end
                                //update #8615 zhu start
                                foreach (DesignParamData wElement in RldLib.CurrentLayoutData.DesignParamList.Where(ele => ele.GroupName == wData.GroupName))
                                //foreach (DesignParamData wElement in RldLib.CurrentLayoutData.DesignParamList.Where(ele => ele.FilterType == wData.FilterType && ele.GroupPath == wData.GroupPath && ele.CellAddress != wData.CellAddress))
                                {
                                    //update #8615 zhu end
                                    wElement.FilterData = wData.FilterData;
                                    wElement.FilterState = wData.FilterState;
                                }
                                //update #8615 zhu start
                                //}
                                //update #8615 zhu end
                            }
                        }
                        // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 start
                        gorupData = false;
                        // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 end
                        break;

					// add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
                    case RldConst.FilterType.Parameter.INSPECTION:
                        // 日常点検・定期点検選択画面
                        using (var wDlg = new frmSelectMainteFilter())
                        {
                            if ("Inspection".Equals(wData.FilterType))
                            {
                                wDlg.FilterType = frmSelectMainteFilter.EnumFilterType.Inspection;
                            }
                            wDlg.FilterData = wData.FilterData;

                            // ダイアログの表示を要求
                            SendNotifyInfo(new RldDesignNotifyInfoRequestOpenDialogEventArgs(wDlg)
                            {
                                IsAllWindowLock = true,
                                IsProtectLayoutSheet = true
                            });

                            // OKボタン押下時はフィルタを更新
                            if (wDlg.DialogResult == DialogResult.OK)
                            {
                                wData.FilterData = wDlg.FilterData;
                                wData.FilterState = RldConst.ParamData.VAL_FILTER_STATE_YES;

                                //// 同一グループへフィルタを適用する場合
                                foreach (DesignParamData wElement in RldLib.CurrentLayoutData.DesignParamList.Where(ele => ele.GroupName == wData.GroupName))
                                {
                                    wElement.FilterData = wData.FilterData;
                                    wElement.FilterState = wData.FilterState;
                                }
                            }
                        }
                        gorupData = false;
                        break;
					// add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end

                    // UNDONE: FNWベースで実装しコメントアウト
                    ////case RldConst.FilterType.Parameter.WATER_SURVEY:
                    ////    // 水質調査箇所選択画面
                    ////    using( var wDlg = new frmSelectWaterSurveyPointFilter() ) {
                    ////        wDlg.Path = wData.DataPath;
                    ////        wDlg.FilterData = wData.FilterData;

                    ////        // ダイアログの表示を要求
                    ////        SendNotifyInfo(new RldDesignNotifyInfoRequestOpenDialogEventArgs(wDlg) {
                    ////            IsAllWindowLock = true,
                    ////            IsProtectLayoutSheet = true
                    ////        });

                    ////        // OKボタン押下時はフィルタを更新
                    ////        if( wDlg.DialogResult == DialogResult.OK ) {
                    ////            wData.FilterData = wDlg.FilterData;
                    ////            wData.FilterState = RldConst.ParamData.VAL_FILTER_STATE_YES;

                    ////            // 同一グループへフィルタを適用する場合
                    ////            if( wDlg.IsApplySameGroup ) {
                    ////                foreach( DesignParamData wElement in RldLib.CurrentLayoutData.DesignParamList.Where(ele => ele.FilterType == wData.FilterType && ele.GroupPath == wData.GroupPath && ele.CellAddress != wData.CellAddress) ) {
                    ////                    wElement.FilterData = wData.FilterData;
                    ////                    wElement.FilterState = wData.FilterState;
                    ////                }
                    ////            }
                    ////        }
                    ////    }
                    ////    break;

                    default:
                        break;
                }
                if (gorupData)
                {
                    using (var wDlg = new frmSelectGenericFilter())
                    {
                        switch (wData.FilterType)
                        {
                            case RldConst.FilterType.Group.OBSKIND:
                                wDlg.Path = wData.GroupPath;
                                wDlg.FilterType = frmSelectGenericFilter.EnumFilterType.ObsKind;
                                wDlg.FilterData = wData.FilterData;
                                break;

                            case RldConst.FilterType.Group.MEDICINE:
                                wDlg.Path = wData.GroupPath;
                                wDlg.FilterType = frmSelectGenericFilter.EnumFilterType.Medicine;
                                wDlg.FilterData = wData.FilterData;
                                break;

                            case RldConst.FilterType.Group.EQUIP:
                                wDlg.Path = wData.GroupPath;
                                wDlg.FilterType = frmSelectGenericFilter.EnumFilterType.Equipment;
                                wDlg.FilterData = wData.FilterData;
                                break;

                            case RldConst.FilterType.Group.DIALDIFF:
                                wDlg.Path = wData.GroupPath;
                                wDlg.FilterType = frmSelectGenericFilter.EnumFilterType.DialDiff;
                                wDlg.FilterData = wData.FilterData;
                                break;

                            case RldConst.FilterType.Group.PATEVENT:
                                wDlg.Path = wData.GroupPath;
                                wDlg.FilterType = frmSelectGenericFilter.EnumFilterType.PatEvent;
                                wDlg.FilterData = wData.FilterData;
                                break;

                            case RldConst.FilterType.Group.ADDITION:
                                wDlg.Path = wData.GroupPath;
                                wDlg.FilterType = frmSelectGenericFilter.EnumFilterType.Addition;
                                wDlg.FilterData = wData.FilterData;
                                break;
                            //add #8615 zhu start
                            case RldConst.FilterType.Group.CATEGORY:
                                wDlg.Path = wData.GroupPath;
                                // mod #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 start
                                //wDlg.FilterType = frmSelectGenericFilter.EnumFilterType.Addition;
                                wDlg.FilterType = frmSelectGenericFilter.EnumFilterType.Category;
                                // mod #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 end
                                wDlg.FilterData = wData.FilterData;
                                break;
                            case RldConst.FilterType.Group.EXAMINE:
                                wDlg.Path = wData.GroupPath;
                                wDlg.FilterType = frmSelectGenericFilter.EnumFilterType.Addition;
                                wDlg.FilterData = wData.FilterData;
                                break;
                            case RldConst.FilterType.Group.EXAM_SET:
                                wDlg.Path = wData.GroupPath;
                                wDlg.FilterType = frmSelectGenericFilter.EnumFilterType.Addition;
                                wDlg.FilterData = wData.FilterData;
                                break;
                            case RldConst.FilterType.Group.WATER_SURVEY:
                                wDlg.Path = wData.GroupPath;
                                wDlg.FilterType = frmSelectGenericFilter.EnumFilterType.Addition;
                                wDlg.FilterData = wData.FilterData;
                                break;
                            case RldConst.FilterType.Group.INSPECTION:
                                wDlg.Path = wData.GroupPath;
                                wDlg.FilterType = frmSelectGenericFilter.EnumFilterType.Addition;
                                wDlg.FilterData = wData.FilterData;
                                break;
                            //add #8615 zhu end
                            //add #8489 start
                            case RldConst.FilterType.Group.DISTRIBUTION:
                                wDlg.Path = wData.GroupPath;
                                wDlg.FilterType = frmSelectGenericFilter.EnumFilterType.Distribution;
                                wDlg.FilterData = wData.FilterData;
                                break;
                            //add #8489 end 
                            // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe start
                            case RldConst.FilterType.Group.PECEIPT:
                                wDlg.Path = wData.GroupPath;
                                wDlg.FilterType = frmSelectGenericFilter.EnumFilterType.Receipt;
                                wDlg.FilterData = wData.FilterData;
                                break;
                            // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe end
                            // add #11625 クラス「指示履歴」の仕様変更② 高 start
                            case RldConst.FilterType.Group.LOGTARGET:
                                wDlg.Path = wData.GroupName;
                                wDlg.FilterType = frmSelectGenericFilter.EnumFilterType.logTarget;
                                wDlg.FilterData = wData.FilterData;
                                break;
                            // add #11625 クラス「指示履歴」の仕様変更② 高 end
                            // add #12006 感染症がフィルタできない 高 start
                            case RldConst.FilterType.Group.INFECTION:
                                wDlg.Path = wData.GroupName;
                                wDlg.FilterType = frmSelectGenericFilter.EnumFilterType.Infection;
                                wDlg.FilterData = wData.FilterData;
                                break;
                            // add #12006 感染症がフィルタできない 高 end
                            // add #10370 装置帳票向けの「水質管理」データ項目を検討する 高 start
                            // mod #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
                            case RldConst.FilterType.Group.WQTESTTYPE:
                                wDlg.Path = wData.GroupName;
                                wDlg.FilterType = frmSelectGenericFilter.EnumFilterType.WQTestType;
                                wDlg.FilterData = wData.FilterData;
                                break;
                            // mod #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end
                            // add #10370 装置帳票向けの「水質管理」データ項目を検討する 高 end
                            // add #11789 【因島】準備リストを医材と薬剤と分けて出力することができない limingzhe start
                            case RldConst.FilterType.Group.EQUIP_DIA:
                                wDlg.Path = wData.GroupPath;
                                wDlg.FilterType = frmSelectGenericFilter.EnumFilterType.EquipDia;
                                wDlg.FilterData = wData.FilterData;
                                break;
                            // add #11789 【因島】準備リストを医材と薬剤と分けて出力することができない limingzhe end
                        }

                        // ダイアログの表示を要求
                        this.SendNotifyInfo(new RldDesignNotifyInfoRequestOpenDialogEventArgs(wDlg)
                        {
                            IsAllWindowLock = true,
                            IsProtectLayoutSheet = true
                        });

                        // OKボタン押下時はフィルタを更新
                        if (wDlg.DialogResult == DialogResult.OK)
                        {
                            wData.FilterData = wDlg.FilterData;
                            wData.FilterState = wDlg.IsSelectPart ? RldConst.GroupData.VAL_FILTER_STATE_PART : RldConst.GroupData.VAL_FILTER_STATE_ALL;
                            //update #8615 邾 start

                            foreach (DesignParamData wd in RldLib.CurrentLayoutData.DesignParamList)
                            {
                                // mod #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 start
                                //if (wd.GroupName == wData.GroupName)
                                if (wd.GroupName == wData.GroupName && wd.IsInTemplete == wData.IsInTemplete)
                                // mod #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 end
                                {
                                    wd.FilterData = wDlg.FilterData;
                                    wd.FilterState = wDlg.IsSelectPart ? RldConst.GroupData.VAL_FILTER_STATE_PART : RldConst.GroupData.VAL_FILTER_STATE_ALL;
                                }
                            }
                            //update #8615 邾 end
                        }
                    }
                }
            }
        }

        /// <summary>
        /// グループリスト表示用 DataGridView の CurrentCellDirtyStateChanged イベントハンドラ
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvGroupList_CurrentCellDirtyStateChanged(object sender, EventArgs e)
        {
            var wDataGridView = (DataGridView)sender;

            if (wDataGridView.IsCurrentCellDirty)
                if (wDataGridView.CurrentCell is DataGridViewCheckBoxCell)
                    wDataGridView.EndEdit();
        }

        /// <summary>
        /// グループリスト表示用 DataGridView の DataBindingComplete イベントハンドラ
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvGroupList_DataBindingComplete(Object sender, DataGridViewBindingCompleteEventArgs e)
        {
            // add #9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。 高 start
            // mod #11106 集計帳票で集計範囲外のグループ項目が出力されない 高 start
            ////List<string> totalTotalList = null;

            //if (!String.IsNullOrEmpty(frmDesignChildLayoutTotal.totalTotal))
            //{
            //    totalTotalList = new List<string>(frmDesignChildLayoutTotal.totalTotal.Trim().Split(','));
            //}
            string totalAddress = RldLib.totalLayoutData.UnitVAddress.Trim() + "," + RldLib.totalLayoutData.UnitHAddress.Trim();
            List<string> totalAddressList = new List<string>(totalAddress.Split(','));
            // mod #11106 集計帳票で集計範囲外のグループ項目が出力されない 高 end
            // add #9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。 高 end
            foreach (DataGridViewRow wRow in this.dgvGroupList.Rows)
            {

                // 該当行にバインドされているデータを取得
                if (!(wRow.DataBoundItem is DesignGroupData wBindData)) continue;

                /// <summary>
                /// 指定されたデータインデックスのセルを読取専用に変更します。
                /// </summary>
                void wFuncSetCellReadOnly(DesignGroupData.EnumDataIndex aDataIndex, Boolean aIsSetReadOnly) =>
                    RldDataGridViewStaticMethods.SetCellReadOnly(
                        this.dgvGroupList,
                        wRow.Index,
                        DesignGroupData.GetPropertyName(aDataIndex),
                        aIsSetReadOnly);

                // 読取専用状態を更新
                if (wBindData.FilterType == RldConst.FilterType.Group.OBSKIND)
                {
                    // フィルタボタン
                    wFuncSetCellReadOnly(DesignGroupData.EnumDataIndex.ButtonEditFilterText, !wBindData.CanEditFilter);
                }
                // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 start
                else if (wBindData.FilterType == RldConst.FilterType.Group.MEDICINE)    // 薬剤
                {
                    // フィルタボタン
                    wFuncSetCellReadOnly(DesignGroupData.EnumDataIndex.ButtonEditFilterText, !wBindData.CanEditFilter);
                    if (string.Equals(wBindData.FilterData, "<SelectSetting><Item tag=\"Medicine\" checkState=\"Checked\" /></SelectSetting>"))
                    {
                        wBindData.FilterState = RldConst.GroupData.VAL_FILTER_STATE_ALL;
                    }
                    else
                    {
                        wBindData.FilterState = RldConst.GroupData.VAL_FILTER_STATE_PART;
                    }
                }
                else if (wBindData.FilterType == RldConst.FilterType.Group.EQUIP)       // 医材
                {
                    // フィルタボタン
                    wFuncSetCellReadOnly(DesignGroupData.EnumDataIndex.ButtonEditFilterText, !wBindData.CanEditFilter);
                    if (string.Equals(wBindData.FilterData, "<SelectSetting><Item tag=\"Equipment\" checkState=\"Checked\" /></SelectSetting>"))
                    {
                        wBindData.FilterState = RldConst.GroupData.VAL_FILTER_STATE_ALL;
                    }
                    else
                    {
                        wBindData.FilterState = RldConst.GroupData.VAL_FILTER_STATE_PART;
                    }
                }
                else if (wBindData.FilterType == RldConst.FilterType.Group.CATEGORY)
                {
                    // フィルタボタン
                    wFuncSetCellReadOnly(DesignGroupData.EnumDataIndex.ButtonEditFilterText, !wBindData.CanEditFilter);
                    //if(String.IsNullOrEmpty(wBindData.FilterData))
                    //{
                    //    wBindData.FilterState = RldConst.ParamData.VAL_FILTER_STATE_NO;
                    //}
                    //else
                    //{
                    //    wBindData.FilterState = RldConst.ParamData.VAL_FILTER_STATE_YES;
                    //}
                    if (string.Equals(wBindData.FilterData, "<SelectSetting><Item tag=\"Category\" checkState=\"Checked\" /></SelectSetting>"))
                    {
                        wBindData.FilterState = RldConst.GroupData.VAL_FILTER_STATE_ALL;
                    }
                    else
                    {
                        wBindData.FilterState = RldConst.GroupData.VAL_FILTER_STATE_PART;
                    }
                }
                // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 end
                // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe start
                else if (wBindData.FilterType == RldConst.FilterType.Group.PECEIPT)    // レセプト
                {
                    // フィルタボタン
                    wFuncSetCellReadOnly(DesignGroupData.EnumDataIndex.ButtonEditFilterText, !wBindData.CanEditFilter);
                    if (string.Equals(wBindData.FilterData, "<SelectSetting><Item tag=\"Receipt\" checkState=\"Checked\" /></SelectSetting>"))
                    {
                        wBindData.FilterState = RldConst.GroupData.VAL_FILTER_STATE_ALL;
                    }
                    else
                    {
                        wBindData.FilterState = RldConst.GroupData.VAL_FILTER_STATE_PART;
                    }
                }
                // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe end
                // add #11625 クラス「指示履歴」の仕様変更② 高 start
                else if (wBindData.FilterType == RldConst.FilterType.Group.LOGTARGET)    // 指示履歴
                {
                    // フィルタボタン
                    wFuncSetCellReadOnly(DesignGroupData.EnumDataIndex.ButtonEditFilterText, !wBindData.CanEditFilter);
                    if (string.Equals(wBindData.FilterData, "<SelectSetting><Item tag=\"logTarget\" checkState=\"Checked\" /></SelectSetting>"))
                    {
                        wBindData.FilterState = RldConst.GroupData.VAL_FILTER_STATE_ALL;
                    }
                    else
                    {
                        wBindData.FilterState = RldConst.GroupData.VAL_FILTER_STATE_PART;
                    }
                }
                // add #11625 クラス「指示履歴」の仕様変更② 高 end
                // add #12006 感染症がフィルタできない 高 start
                else if (wBindData.FilterType == RldConst.FilterType.Group.INFECTION)    // 感染症
                {
                    // フィルタボタン
                    wFuncSetCellReadOnly(DesignGroupData.EnumDataIndex.ButtonEditFilterText, !wBindData.CanEditFilter);
                    if (string.Equals(wBindData.FilterData, "<SelectSetting><Item tag=\"Infection\" checkState=\"Checked\" /></SelectSetting>"))
                    {
                        wBindData.FilterState = RldConst.GroupData.VAL_FILTER_STATE_ALL;
                    }
                    else
                    {
                        wBindData.FilterState = RldConst.GroupData.VAL_FILTER_STATE_PART;
                    }
                }
                // add #12006 感染症がフィルタできない 高 end
                // add #10370 装置帳票向けの「水質管理」データ項目を検討する 高 start
                // mod #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
                else if (wBindData.FilterType == RldConst.FilterType.Group.WQTESTTYPE)    // 水質検査種別
                {
                    // フィルタボタン
                    wFuncSetCellReadOnly(DesignGroupData.EnumDataIndex.ButtonEditFilterText, !wBindData.CanEditFilter);
                    if (string.Equals(wBindData.FilterData, "<SelectSetting><Item tag=\"WQTestType\" checkState=\"Checked\" /></SelectSetting>"))
                    {
                        wBindData.FilterState = RldConst.GroupData.VAL_FILTER_STATE_ALL;
                    }
                    else
                    {
                        wBindData.FilterState = RldConst.GroupData.VAL_FILTER_STATE_PART;
                    }
                }
                // mod #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end
                // add #10370 装置帳票向けの「水質管理」データ項目を検討する 高 end
                // add #11789 【因島】準備リストを医材と薬剤と分けて出力することができない limingzhe start
                else if (wBindData.FilterType == RldConst.FilterType.Group.EQUIP_DIA)    // 器材
                {
                    // フィルタボタン
                    wFuncSetCellReadOnly(DesignGroupData.EnumDataIndex.ButtonEditFilterText, !wBindData.CanEditFilter);
                    if (string.Equals(wBindData.FilterData, "<SelectSetting><Item tag=\"EquipDia\" checkState=\"Checked\" /></SelectSetting>"))
                    {
                        wBindData.FilterState = RldConst.GroupData.VAL_FILTER_STATE_ALL;
                    }
                    else
                    {
                        wBindData.FilterState = RldConst.GroupData.VAL_FILTER_STATE_PART;
                    }
                }
                // add #11789 【因島】準備リストを医材と薬剤と分けて出力することができない limingzhe end
                else
                {
                    // フィルタボタン
                    wRow.Cells[DesignGroupData.GetPropertyName(DesignGroupData.EnumDataIndex.ButtonEditFilterText)].ToolTipText = SignInLib.SignIn.SignInInfo.IsOnline ? String.Empty : "オフラインモードではフィルタを設定出来ません";
                    //update 8615-15 zhu start
                    //wFuncSetCellReadOnly(DesignGroupData.EnumDataIndex.ButtonEditFilterText, SignInLib.SignIn.SignInInfo.IsOnline ? !wBindData.CanEditFilter : true);
                    wFuncSetCellReadOnly(DesignGroupData.EnumDataIndex.ButtonEditFilterText, SignInLib.SignIn.SignInInfo.IsOnline ? !false : true);
                    // フィルタ状態
                    //wRow.Cells[DesignGroupData.GetPropertyName(DesignGroupData.EnumDataIndex.FilterState)].Value = SignInLib.SignIn.SignInInfo.IsOnline ? wBindData.FilterState : String.Empty;
                    //update 8615-15 zhu end
                }

                // add #9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。 高 start
                // mod #11106 集計帳票で集計範囲外のグループ項目が出力されない 高 start
                if (RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_ONE_TOTAL
                 || RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_MULTI_TOTAL
                 || (RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_REFERRAL_LETTER && "1".Equals(RldLib.totalLayoutData.ReportType)))
                {
                    if (totalAddressList != null)
                    {
                        String groupName = wRow.Cells[2].Value.ToString();
                        String IsInTempleteName = wRow.Cells[6].Value.ToString();
                        if (IsInTempleteName == RldConst.ParamData.VAL_IS_IN_TEMPLETE_IN)
                        {
                            wBindData.CanEditNewPage = false;
                        }
                        else
                        {
                            foreach (var wList in totalAddressList)
                            {
                                foreach (var wData in RldLib.CurrentLayoutData.DesignParamList)
                                {
                                    if (wData.CellAddress.Equals(wList))
                                    {
                                        //if (wList.Contains(groupName))
                                        if (groupName == wData.GroupName)
                                        {
                                            //if (IsInTempleteName == RldConst.ParamData.VAL_IS_IN_TEMPLETE_OUT)
                                            {
                                                wBindData.CanEditNewPage = false;
                                                break;
                                            }
                                        }
                                    }
                                }
                                // mod #11106 集計帳票で集計範囲外のグループ項目が出力されない 高 end
                            }
                        }
                    }
                }
                // add #9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。 高 end

                // 改ページ
                //edit #9484 因島帳票の表示不具合（帳票種別：紹介状）dongzhaolong start
                var wValueCell = wRow.Cells[DesignGroupData.GetPropertyName(DesignGroupData.EnumDataIndex.IsNewPage)];
                if (!wBindData.CanEditNewPage)
                {
                    DataGridViewCheckBoxCell checkBox = wValueCell as DataGridViewCheckBoxCell;
                    checkBox.ReadOnly = !wBindData.CanEditNewPage;
                    checkBox.FlatStyle = FlatStyle.Popup;
                }
                else
                {
                    DataGridViewCheckBoxCell checkBox = wValueCell as DataGridViewCheckBoxCell;
                    checkBox.ReadOnly = !wBindData.CanEditNewPage;
                    checkBox.FlatStyle = FlatStyle.Standard;
                }
                //wFuncSetCellReadOnly(DesignGroupData.EnumDataIndex.IsNewPage, !wBindData.CanEditNewPage);
                //edit #9484 因島帳票の表示不具合（帳票種別：紹介状）dongzhaolong end
            }
        }

        /// <summary>
        /// グループ一覧表示用 DataGridView の RowEnter イベントハンドラ
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvGroupList_RowEnter(Object sender, DataGridViewCellEventArgs e)
        {
            try
            {
                // 選択行のデータを取得
                if (!(this.dgvGroupList.Rows[e.RowIndex].DataBoundItem is DesignGroupData wData)) return;

                // 明細表示用グリッドの表示を更新
                this.UpdateGroupDetailGrid(wData, true);
            }
            catch (Exception ex)
            {
                this.SendNotifyInfo(new RldDesignNotifyInfoRequestRecordExceptionEventArgs(ex, true));
            }
        }

        /// <summary>
        /// グループ明細表示用 DataGridView の CellClick イベントハンドラ
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvGroupDetail_CellClick(Object sender, DataGridViewCellEventArgs e)
        {
            try
            {
                // add #7943 帳票レイアウトデザイナーが正しく動作しないの対応 夏 start
                // ヘッダのクリック時は抜ける
                if (e.RowIndex < 0 || e.ColumnIndex < 0) return;
                // add #7943 帳票レイアウトデザイナーが正しく動作しないの対応 夏 end

                //add 20211011 #5598 複数集計，単集計ページを変更して読み取り専用を追加する 鄭  start
                if (this.dgvGroupDetail[e.ColumnIndex, e.RowIndex].ReadOnly) return;
                //add 20211011 #5598 複数集計，単集計ページを変更して読み取り専用を追加する 鄭  end

                // 関係ない列のクリックの場合は抜ける
                if ((e.ColumnIndex == (int)RldGridRCAttributeReflector.EnumRowModeColumnIndex.ItemValue) && (e.RowIndex >= 0))
                {

                    // プロパティ名を取得(これが列名となるため)
                    string wPropName = this.dgvGroupDetail[(int)RldGridRCAttributeReflector.EnumRowModeColumnIndex.Property, e.RowIndex].Value as string;

                    // add #12545 グループタブ上で異なるグループ名を同じにし、該当セルを選択すると致命的なエラーが発生する 高 start
                    if (this.dgvGroupList.CurrentRow != null)
                    {
                    // add #12545 グループタブ上で異なるグループ名を同じにし、該当セルを選択すると致命的なエラーが発生する 高 end
                        // クリックさせる
                        this.dgvGroupList_CellClick(
                            this.dgvGroupList,
                            new DataGridViewCellEventArgs(
                                this.dgvGroupList.Columns[wPropName].Index,
                                this.dgvGroupList.CurrentRow.Index));
                    }
                }

            }
            catch (Exception ex)
            {
                // メッセージボックスを表示してログ記録する
                RldUtility.RecordException(this, ex, true);
            }
        }

        /// <summary>
        /// グループ明細表示用 DataGridView の CellEndEdit イベントハンドラ
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvGroupDetail_CellEndEdit(Object sender, DataGridViewCellEventArgs e)
        {
            try
            {
                // add #11501 レイアウトデザイナのユーザビリティ改善 高 start
                // 選択行がない場合は抜ける
                if (this.dgvGroupList.CurrentRow == null) return;
                // データをクリアの場合
                if (this.dgvGroupList.Rows.Count == 0) return;
                // add #11501 レイアウトデザイナのユーザビリティ改善 高 end

                // 選択行のデータを取得
                if (!(this.dgvGroupList.Rows[this.dgvGroupList.CurrentRow.Index].DataBoundItem is DesignGroupData wData)) return;

                // 編集を行った行のプロパティ名を取得
                String wPropName = this.dgvGroupDetail[(Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.Property, e.RowIndex].Value as String;
                String wValue = this.dgvGroupDetail[(Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.ItemValue, e.RowIndex].Value as String;

                // プロパティ名チェック用
                Boolean wFuncIsEqualPropName(DesignGroupData.EnumDataIndex aIndex) =>
                    wPropName == DesignGroupData.GetPropertyName(aIndex);

                // 改ページ
                if (wFuncIsEqualPropName(DesignGroupData.EnumDataIndex.IsNewPage))
                {
                    wData.IsNewPage = wValue;
                }
                // add #11501 レイアウトデザイナのユーザビリティ改善 高 start
                // グループ名
                else if (wFuncIsEqualPropName(DesignGroupData.EnumDataIndex.GroupName))
                {
                    // if group name is empty, set old detail group name
                    if (string.IsNullOrEmpty(wValue))
                    {
                        this.dgvGroupDetail[(Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.ItemValue, e.RowIndex].Value = wData.GroupName;
                    }
                    else if(GroupNameSame(wValue, wData.IsInTemplete, this.dgvGroupList.CurrentRow.Index))
                    {
                        if(this.dgvGroupDetail[(Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.ItemValue, e.RowIndex].Value != wData.GroupName)
                            this.dgvGroupDetail[(Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.ItemValue, e.RowIndex].Value = wData.GroupName;
                    }
                    else
                    {
                        GroupName_ParameUpdate(wData.GroupName, wData.IsInTemplete, wValue);
                        wData.GroupName = wValue;
                    }
                }
                // add #11501 レイアウトデザイナのユーザビリティ改善 高 end
            }
            catch (Exception ex)
            {
                this.SendNotifyInfo(new RldDesignNotifyInfoRequestRecordExceptionEventArgs(ex, true));
            }
        }

        /// <summary>
        /// グループ明細表示用 DataGridView の CurrentCellDirtyStateChanged イベントハンドラ
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvGroupDetail_CurrentCellDirtyStateChanged(object sender, EventArgs e)
        {
            var wDataGridView = (DataGridView)sender;
            if (wDataGridView.IsCurrentCellDirty)
                if (wDataGridView.CurrentCell is DataGridViewCheckBoxCell)
                    wDataGridView.EndEdit();
        }

        #endregion

        #region カスタムイベントハンドラ定義

        /// <summary>
        /// グループ編集データリストの ListChanged イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void DesignGroupList_ListChanged(Object sender, ListChangedEventArgs e)
        {
            try
            {
                //modify #8871 dongzhaolong start
                // 削除された場合は処理しない
                if (e.ListChangedType == ListChangedType.ItemDeleted)
                {
                    if (RldLib.CurrentLayoutData.DesignGroupList.Count == 0)
                    {
                        this.dgvGroupDetail.RowCount = 0;
                    }
                    return;
                }
                //modify #8871 dongzhaolong start
                // 選択行がない場合は抜ける
                if (this.dgvGroupList.CurrentRow == null) return;
                // データをクリアの場合
                if (this.dgvGroupList.Rows.Count == 0) return;
                // 選択行のデータを取得
                if (!(this.dgvGroupList.Rows[this.dgvGroupList.CurrentRow.Index].DataBoundItem is DesignGroupData wData)) return;

                // 明細表示用グリッドの表示を更新する
                LFunc_SelectionUpdate();
                /// <summary>
                /// (ローカル関数) 明細表示用グリッドの表示を更新。
                /// </summary>
                void LFunc_SelectionUpdate()
                {
                    if (this.dgvGroupList.IsDisposed)
                    {
                        return;
                    }

                    if (this.dgvGroupList.InvokeRequired)
                    {
                        this.Invoke((MethodInvoker)delegate
                        {
                            LFunc_SelectionUpdate();
                        });
                    }
                    else
                    {
                        // get current Detail group name
                        String wKeyCellValue = this.dgvGroupDetail.Rows[2].Cells[2].Value as String;

                        // if group name is empty, set old Detail group name
                        if (string.IsNullOrEmpty(wData.GroupName))
                        {
                            wData.GroupName = wKeyCellValue;
                        }
                        else if (GroupNameSame(wData.GroupName, wData.IsInTemplete, this.dgvGroupList.CurrentRow.Index))
                        {
                            if (wData.GroupName != wKeyCellValue)
                                wData.GroupName = wKeyCellValue;
                        }
                        else
                        {
                            if (wData.GroupName != wKeyCellValue)
                            {
                                GroupName_ParameUpdate(wKeyCellValue, wData.IsInTemplete, wData.GroupName);
                            }
                        }
                        // 表示データを更新する
                        this.UpdateGroupDetailGrid(wData, false);
                    }
                }
                // mod #11501 レイアウトデザイナのユーザビリティ改善 高 end
            }
            catch (Exception ex)
            {
                this.SendNotifyInfo(new RldDesignNotifyInfoRequestRecordExceptionEventArgs(ex, true));
            }
        }

        // add #11501 レイアウトデザイナのユーザビリティ改善 高 start
        /// <summary>
        /// 選択パラメータ変更通知受信時処理を行います。
        /// </summary>
        /// <param name="e"></param>
        private void ActionOfNotifySelectedParamChanged(RldDesignNotifyInfoNotifySelectedParamChangedEventArgs e)
        {
            LFunc_SelectionUpdate();

            /// <summary>
            /// (ローカル関数) パラメータリスト表示用データグリッドの選択状態を更新します。
            /// </summary>
            void LFunc_SelectionUpdate()
            {
                if (this.dgvGroupList.IsDisposed)
                {
                    return;
                }

                if (this.dgvGroupList.InvokeRequired)
                {
                    this.Invoke((MethodInvoker)delegate
                    {
                        LFunc_SelectionUpdate();
                    });
                }
                else
                {
                    // clear current select
                    this.dgvGroupList.ClearSelection();
                    this.dgvGroupList.CurrentCell = null;

                    // current cell address is not in param list
                    var list = RldLib.CurrentLayoutData.DesignParamList.Where(ele => ele.CellAddress == e.CellAddress).ToList();
                    if (list == null || list.Count == 0)
                    {
                        // add #12752 デザイナーウィンドウでグループタブ下部の属性編集欄の更新が不適切 高 start
                        this.DataClear(false);
                        // add #12752 デザイナーウィンドウでグループタブ下部の属性編集欄の更新が不適切 高 end
                        return;
                    }

                    // add #12752 デザイナーウィンドウでグループタブ下部の属性編集欄の更新が不適切 高 start
                    bool bFind = false;
                    // add #12752 デザイナーウィンドウでグループタブ下部の属性編集欄の更新が不適切 高 end

                    DesignParamData paramData = list[0];
                    if (paramData != null)
                    {
                        // find same group in param list and group list
                        for (int i = 0; i < dgvGroupList.Rows.Count; i++)
                        {
                            String groupName = string.Empty;
                            if(this.dgvGroupList.Rows[i].Cells[2].Value != null)
                                groupName = this.dgvGroupList.Rows[i].Cells[2].Value.ToString();
                            if (groupName.Equals(paramData.GroupName))
                            {
                                // select cell in group list
                                this.dgvGroupList.Rows[i].Selected = true;
                                this.dgvGroupList.CurrentCell = this.dgvGroupList.Rows[i].Cells[2];
                                this.dgvGroupList.FirstDisplayedScrollingRowIndex = i;
                                // add #12752 デザイナーウィンドウでグループタブ下部の属性編集欄の更新が不適切 高 start
                                bFind = true;
                                // add #12752 デザイナーウィンドウでグループタブ下部の属性編集欄の更新が不適切 高 end
                                break;
                            }
                        }
                    }
                    // add #12752 デザイナーウィンドウでグループタブ下部の属性編集欄の更新が不適切 高 start
                    if(bFind == false)
                    {
                        this.DataClear(false);
                    }
                    // add #12752 デザイナーウィンドウでグループタブ下部の属性編集欄の更新が不適切 高 end
                }
            }
        }

        // // set group name of all param data = Group
        private void GroupName_ParameUpdate(string wOldGroupName, string IsInTemplete, string wNewGroupName)
        {
            if(string.IsNullOrEmpty(wOldGroupName))
                return;

            // get all param data where address is same address of GroupPath
            foreach (var wParamDataSameGroup in RldLib.CurrentLayoutData.DesignParamList.Where(ele => ele.GroupName == wOldGroupName && ele.IsInTemplete == IsInTemplete))
            {
                // set group name of all param data = Group
                    wParamDataSameGroup.GroupName = wNewGroupName;
            }
        }

        // find group name is same in group list
        private bool GroupNameSame(string wGroupName, string IsInTemplete, int currentRow)
        {
            bool bRet = false;

            if (string.IsNullOrEmpty(wGroupName))
                return bRet;

            for(int i = 0; i < this.dgvGroupList.Rows.Count; i++)
            {
                if (i == currentRow)
                    continue;

                if (!(this.dgvGroupList.Rows[i].DataBoundItem is DesignGroupData wData)) continue;

                if (wGroupName == wData.GroupName && IsInTemplete == wData.IsInTemplete)
                {
                    // ServiceNotification だと主画面に出やすいため、現在編集中の画面を owner にする。
                    MessageBox.Show(this, "既存のグループ名に変更することはできません。", "グループ名を確認してください",
                            MessageBoxButtons.OK,
                            MessageBoxIcon.Warning,
                            MessageBoxDefaultButton.Button1);

                    return true;
                }
            }

            return bRet;
        }

        // when datagridview sort, reset DataSource, display of button is ok.
        private void RefreshButtonColumns()
        {
            LFunc_Invoke();

            void LFunc_Invoke()
            {
                if (this.dgvGroupList.IsDisposed)
                {
                    return;
                }

                if (this.dgvGroupList.InvokeRequired)
                {
                    dgvGroupList.Invoke((MethodInvoker)delegate
                    {
                        LFunc_Invoke();
                    });
                }
                else
                {
                    var currentDataSource = dgvGroupList.DataSource;
                    dgvGroupList.DataSource = null;
                    dgvGroupList.DataSource = currentDataSource;

                    dgvGroupList.CurrentCell = dgvGroupList[0, 0];
                    dgvGroupList.Focus();
                }
            }
        }
        // add #11501 レイアウトデザイナのユーザビリティ改善 高 end

        // add #12545 グループタブ上で異なるグループ名を同じにし、該当セルを選択すると致命的なエラーが発生する 高 start
        public void dgvGroupList_EndEdit()
        {
            // データグリッドビュー
            var wDataGridView = dgvGroupList;

            if (wDataGridView.IsCurrentCellInEditMode)
            {
                wDataGridView.EndEdit();
            }

            // グループ明細表示用 DataGridView
            wDataGridView = dgvGroupDetail;

            if (wDataGridView.IsCurrentCellInEditMode)
            {
                wDataGridView.EndEdit();
            }
        }
        // add #12545 グループタブ上で異なるグループ名を同じにし、該当セルを選択すると致命的なエラーが発生する 高 end

        #endregion
    }
}
