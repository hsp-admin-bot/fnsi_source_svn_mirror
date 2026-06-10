// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 05-26-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-27-2021
// ***********************************************************************
// <copyright file="CoopSettingView.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************

using CoopSettingTool.App.Controllers;
using CoopSettingTool.App.Models;
using CoopSettingTool.Service.Models;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Linq;
using System.Linq.Dynamic;
using System.Windows.Forms;

namespace CoopSettingTool.App.Views
{
    /// <summary>
    /// Class CoopSettingView.
    /// Implements the <see cref="CoopSettingTool.App.Views.BaseView" />
    /// Implements the <see cref="CoopSettingTool.App.Views.ICoopSettingView" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Views.BaseView" />
    /// <seealso cref="CoopSettingTool.App.Views.ICoopSettingView" />
    public partial class CoopSettingView : BaseView, ICoopSettingView
    {
        /// <summary>
        /// The sort index
        /// </summary>
        int sortIndex = 1;

        /// <summary>
        /// The sort ascending
        /// </summary>
        bool sortAscending = false;

        /// <summary>
        /// The search pattern
        /// </summary>
        string searchPattern = string.Empty;

        /// <summary>
        /// The key0 filter all text
        /// </summary>
        const string Key0FilterAllText = "すべて";

        /// <summary>
        /// The key0 filter pattern
        /// </summary>
        string key0FilterPattern = string.Empty;

        /// <summary>
        /// The key0 filter update flag
        /// </summary>
        bool updatingKey0FilterItems = false;

        /// <summary>
        /// The controller
        /// </summary>
        ICoopSettingController controller;

        /// <summary>
        /// The file dialog
        /// </summary>
        SaveFileDialog saveFileDialog;

        /// <summary>
        /// The open file dialog
        /// </summary>
        OpenFileDialog openFileDialog;

        /// <summary>
        /// Initializes a new instance of the <see cref="CoopSettingView" /> class.
        /// </summary>
        /// <param name="model">The model.</param>
        public CoopSettingView(ICoopSettingModel model)
        {
            InitializeComponent();
            this.StartPosition = FormStartPosition.CenterParent;

            saveFileDialog = new SaveFileDialog();
            saveFileDialog.Title = "保存";
            saveFileDialog.Filter = "Csv Files (*.csv)|*.csv" ;

            openFileDialog = new OpenFileDialog();
            openFileDialog.Title = "読み込む";
            openFileDialog.Filter = "Csv Files (*.csv)|*.csv";

            controller = new CoopSettingController(this, model);
            this.RegisterEvent();
        }

        /// <summary>
        /// Registers the event.
        /// </summary>
        private void RegisterEvent()
        {
            this.Shown += new EventHandler(OnFormShown);
            this.FormClosing += new FormClosingEventHandler(CoopSettingView_FormClosing);
            this.controller.Model.PropertyChanged += new PropertyChangedEventHandler(Model_PropertyChanged);

            this.dgvCoopIni.SelectionChanged += new EventHandler(DgvCoopIni_SelectionChanged);
            this.dgvCoopIni.ColumnHeaderMouseClick += new DataGridViewCellMouseEventHandler(DgvCoopIni_ColumnHeaderMouseClick);
            this.dgvCoopIni.RowLeave += new DataGridViewCellEventHandler(DgvCoopIni_RowLeave);
            this.dgvCoopIni.CellMouseClick += new DataGridViewCellMouseEventHandler(DgvCoopIni_CellMouseClick);
            this.btnSave.Click += new EventHandler(BtnSave_Click);
            this.btnCancel.Click += new EventHandler(BtnCancel_Click);
            this.btnAdd.Click += new EventHandler(BtnAdd_Click);
            this.btnOnOff.Click += new EventHandler(BtnOnOff_Click);
            this.btnFilter.Click += new EventHandler(BtnFilter_Click);
            this.cmbKey0Filter.SelectedIndexChanged += new EventHandler(CmbKey0Filter_SelectedIndexChanged);
            this.txtFilter.KeyDown += new KeyEventHandler(TxtFilter_KeyDown);
            this.btnExport.Click += new EventHandler(BtnExport_Click);
            this.btnImport.Click += new EventHandler(BtnImport_Click);
        }

        /// <summary>
        /// Handles the CellMouseClick event of the DgvCoopIni control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="DataGridViewCellMouseEventArgs"/> instance containing the event data.</param>
        private void DgvCoopIni_CellMouseClick(object sender, DataGridViewCellMouseEventArgs e)
        {
            if (e.RowIndex == -1 && e.ColumnIndex == -1)
            {
                if (e.Button == MouseButtons.Right)
                {
                    foreach (DataGridViewColumn column in this.dgvCoopIni.Columns)
                    {
                        column.AutoSizeMode = DataGridViewAutoSizeColumnMode.AllCells;
                        int colw = column.Width;
                        column.AutoSizeMode = DataGridViewAutoSizeColumnMode.None;
                        column.Width = colw;
                    }
                }
            }
        }

        /// <summary>
        /// Handles the FormClosing event of the CoopSettingView control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="FormClosingEventArgs"/> instance containing the event data.</param>
        private void CoopSettingView_FormClosing(object sender, FormClosingEventArgs e)
        {
            this.controller.ClearData();
        }

        /// <summary>
        /// Handles the RowLeave event of the DgvCoopIni control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="DataGridViewCellEventArgs"/> instance containing the event data.</param>
        private void DgvCoopIni_RowLeave(object sender, DataGridViewCellEventArgs e)
        {
            if(this.dgvCoopIni.IsCurrentRowDirty)
            {
                CoopIniInfo data = (CoopIniInfo)this.dgvCoopIni.Rows[e.RowIndex].DataBoundItem;
            }
        }

        /// <summary>
        /// ColumnHeaderMouseClick
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="DataGridViewCellMouseEventArgs"/> instance containing the event data.</param>
        private void DgvCoopIni_ColumnHeaderMouseClick(object sender, DataGridViewCellMouseEventArgs e)
        {
            sortIndex = e.ColumnIndex;
            sortAscending = !sortAscending;
            this.controller.SortSettings(this.dgvCoopIni.Columns[this.sortIndex].DataPropertyName, sortAscending);
        }

        /// <summary>
        /// Handles the Click event of the BtnImport control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs" /> instance containing the event data.</param>
        private void BtnImport_Click(object sender, EventArgs e)
        {
            if (openFileDialog.ShowDialog(this) == DialogResult.OK)
            {
                string fileName = openFileDialog.FileName;
                this.controller.ImportCoopIni(fileName);
            }
        }

        /// <summary>
        /// Handles the Click event of the BtnExport control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs" /> instance containing the event data.</param>
        private void BtnExport_Click(object sender, EventArgs e)
        {
            saveFileDialog.FileName = string.Format("FNSi連携設定_{0}_{1}.csv", this.controller.Model.Facility.FacilityCd, DateTime.Now.ToString("yyyyMMdd"));
            if (saveFileDialog.ShowDialog(this) == DialogResult.OK)
            {
                string fileName = saveFileDialog.FileName;
                this.controller.ExportCoopIni(fileName);
            }
        }

        /// <summary>
        /// Closes the view.
        /// </summary>
        /// <param name="dialogResult">The dialog result.</param>
        public override void CloseView(DialogResult dialogResult)
        {
            this.controller.ClearData();
            base.CloseView(dialogResult);
        }

        /// <summary>
        /// TxtFilter_KeyDown
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="KeyEventArgs"/> instance containing the event data.</param>
        private void TxtFilter_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                BtnFilter_Click(null, null);
            }
        }

        /// <summary>
        /// Handles the Click of BtnFilter
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void BtnFilter_Click(object sender, EventArgs e)
        {
            searchPattern = txtFilter.Text;
            UpdateCoopSettingListView();
        }

        /// <summary>
        /// Handles the SelectedIndexChanged event of the CmbKey0Filter control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void CmbKey0Filter_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (updatingKey0FilterItems)
            {
                return;
            }

            key0FilterPattern = this.cmbKey0Filter.SelectedIndex > 0 ? this.cmbKey0Filter.SelectedItem as string : string.Empty;
            UpdateCoopSettingListView();
        }

        /// <summary>
        /// Handles the Click event of the BtnRemove control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs" /> instance containing the event data.</param>
        private void BtnOnOff_Click(object sender, EventArgs e)
        {
            List<CoopIniInfo> removeList = new List<CoopIniInfo>();
            foreach(DataGridViewRow row in this.dgvCoopIni.SelectedRows)
            {
                removeList.Add(row.DataBoundItem as CoopIniInfo);
            }

            this.controller.OnOffSetting(removeList);
        }

        /// <summary>
        /// Handles the Click event of the BtnAdd control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs" /> instance containing the event data.</param>
        private void BtnAdd_Click(object sender, EventArgs e)
        {
            int rowIndex = this.dgvCoopIni.CurrentRow.Index;
            CoopIniInfo dataItem = (CoopIniInfo)this.dgvCoopIni.CurrentRow.DataBoundItem;
            int itemIndex = this.controller.Model.CoopIniInfos.IndexOf(dataItem);

            this.controller.AddBlankSetting(itemIndex);
            this.dgvCoopIni.CurrentCell = this.dgvCoopIni.Rows[rowIndex].Cells[0];
        }

        /// <summary>
        /// Handles the SelectionChanged event of the DgvCoopIni control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs" /> instance containing the event data.</param>
        /// <exception cref="NotImplementedException"></exception>
        private void DgvCoopIni_SelectionChanged(object sender, EventArgs e)
        {
            if(this.dgvCoopIni.SelectedRows.Count > 0)
            {
                this.btnOnOff.Visible = true;
            }
            else
            {
                this.btnOnOff.Visible = false;
            }
        }

        /// <summary>
        /// Handles the Click event of the BtnCancel control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs" /> instance containing the event data.</param>
        private void BtnCancel_Click(object sender, EventArgs e)
        {
            this.CloseView(System.Windows.Forms.DialogResult.Cancel);
        }

        /// <summary>
        /// Handles the Click event of the BtnSave control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs" /> instance containing the event data.</param>
        private void BtnSave_Click(object sender, EventArgs e)
        {
            this.controller.Save();
        }

        /// <summary>
        /// Handles the <see cref="E:FormShown" /> event.
        /// </summary>
        /// <param name="sender">The sender.</param>
        /// <param name="e">The <see cref="EventArgs" /> instance containing the event data.</param>
        private void OnFormShown(object sender, EventArgs e)
        {
            LoadView();
        }

        /// <summary>
        /// Loads the view.
        /// </summary>
        private void LoadView()
        {
            this.controller.LoadCoopIni();
        }

        /// <summary>
        /// Handles the PropertyChanged event of the Model control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="PropertyChangedEventArgs" /> instance containing the event data.</param>
        private void Model_PropertyChanged(object sender, PropertyChangedEventArgs e)
        {
            switch (e.PropertyName)
            {
                case "CoopIniInfos":
                    {
                        UpdateKey0FilterItems();
                        UpdateCoopSettingListView();
                        break;
                    }
                case "Facility":
                    {
                        UpdateViewByFacility();
                        break;
                    }
            }
        }

        /// <summary>
        /// Delegate UpdateViewByFacilityCallback
        /// </summary>
        private delegate void UpdateViewByFacilityCallback();
        /// <summary>
        /// Updates the view by facility.
        /// </summary>
        private void UpdateViewByFacility()
        {
            if (this.lbFacName.InvokeRequired)
            {
                UpdateViewByFacilityCallback calback = new UpdateViewByFacilityCallback(UpdateViewByFacility);
                this.Invoke(calback);
            }
            else
            {
                if (this.controller.Model.Facility != null)
                {
                    this.lbFacName.Text = this.controller.Model.Facility.DisplayMember;
                    this.Refresh();
                }
            }
        }

        /// <summary>
        /// Delegate UpdateKey0FilterItemsCallback
        /// </summary>
        private delegate void UpdateKey0FilterItemsCallback();
        /// <summary>
        /// Updates the key0 filter items.
        /// </summary>
        private void UpdateKey0FilterItems()
        {
            if (this.cmbKey0Filter.InvokeRequired)
            {
                UpdateKey0FilterItemsCallback calback = new UpdateKey0FilterItemsCallback(UpdateKey0FilterItems);
                this.Invoke(calback);
            }
            else
            {
                string selectedKey0 = key0FilterPattern;
                updatingKey0FilterItems = true;

                try
                {
                    this.cmbKey0Filter.Items.Clear();
                    this.cmbKey0Filter.Items.Add(Key0FilterAllText);

                    if (this.controller.Model.CoopIniInfos != null)
                    {
                        List<string> key0List = this.controller.Model.CoopIniInfos
                            .Where(x => !string.IsNullOrEmpty(x.Key0))
                            .Select(x => x.Key0)
                            .Distinct()
                            .OrderBy(x => x)
                            .ToList();

                        foreach (string key0 in key0List)
                        {
                            this.cmbKey0Filter.Items.Add(key0);
                        }
                    }

                    if (!string.IsNullOrEmpty(selectedKey0) && this.cmbKey0Filter.Items.Contains(selectedKey0))
                    {
                        this.cmbKey0Filter.SelectedItem = selectedKey0;
                        key0FilterPattern = selectedKey0;
                    }
                    else
                    {
                        this.cmbKey0Filter.SelectedIndex = 0;
                        key0FilterPattern = string.Empty;
                    }
                }
                finally
                {
                    updatingKey0FilterItems = false;
                }
            }
        }

        /// <summary>
        /// Delegate UpdateCoopSettingListViewCallback
        /// </summary>
        private delegate void UpdateCoopSettingListViewCallback();
        /// <summary>
        /// Updates the coop setting ListView.
        /// </summary>
        private void UpdateCoopSettingListView()
        {
            if (this.dgvCoopIni.InvokeRequired)
            {
                UpdateCoopSettingListViewCallback calback = new UpdateCoopSettingListViewCallback(UpdateCoopSettingListView);
                this.Invoke(calback);
            }
            else
            {
                // スクロールポジション
                int firstDisplayedScrollingRowIndex = this.dgvCoopIni.FirstDisplayedScrollingRowIndex;
                int currentRowIndex = (this.dgvCoopIni.CurrentRow != null) ? this.dgvCoopIni.CurrentRow.Index : -1;
                int currentColumnIndex = (this.dgvCoopIni.CurrentCell != null) ? this.dgvCoopIni.CurrentCell.ColumnIndex : -1;

                this.dgvCoopIni.DataSource = new List<CoopIniInfo>();
                if (this.controller.Model.CoopIniInfos != null)
                {
                    List<CoopIniInfo> dataList = this.controller.Model.CoopIniInfos;

                    // key0フィルタを適用する
                    if (!string.IsNullOrEmpty(this.key0FilterPattern))
                    {
                        dataList = dataList.FindAll(x => !string.IsNullOrEmpty(x.Key0) && x.Key0.Equals(this.key0FilterPattern));
                    }

                    // 検索パターンを適用する
                    if (!string.IsNullOrEmpty(this.searchPattern))
                    {
                        dataList = dataList.FindAll(x => (!string.IsNullOrEmpty(x.Key0) && x.Key0.Contains(this.searchPattern))
                        || (!string.IsNullOrEmpty(x.Key1) && x.Key1.Contains(this.searchPattern))
                        || (!string.IsNullOrEmpty(x.Key2) && x.Key2.Contains(this.searchPattern))
                        || (!string.IsNullOrEmpty(x.Value) && x.Value.Contains(this.searchPattern))
                        || (!string.IsNullOrEmpty(x.DefaultValue) && x.DefaultValue.Contains(this.searchPattern))
                        || (!string.IsNullOrEmpty(x.Comment) && x.Comment.Contains(this.searchPattern))
                        || (!string.IsNullOrEmpty(x.Value) && x.Value.Contains(this.searchPattern))
                        || (string.IsNullOrEmpty(x.Key0) && !x.IsModified));
                    }

                    // データをセットする
                    this.dgvCoopIni.DataSource = dataList;

                    // 削除された行をグレーに表示される
                    for (int i = 0; i < dataList.Count; i++)
                    {
                        if (dataList[i].IsEffect.Equals("0"))
                        {
                            this.dgvCoopIni.Rows[i].DefaultCellStyle.BackColor = Color.LightGray;
                        }
                    }

                    // スクロール復元
                    if (firstDisplayedScrollingRowIndex >= 0 && firstDisplayedScrollingRowIndex < this.dgvCoopIni.Rows.Count)
                    {
                        this.dgvCoopIni.FirstDisplayedScrollingRowIndex = firstDisplayedScrollingRowIndex;
                    }

                    // 選択復元
                    if (currentRowIndex >= 0 && currentRowIndex < this.dgvCoopIni.Rows.Count &&
                        currentColumnIndex >= 0 && currentColumnIndex < this.dgvCoopIni.Columns.Count)
                    {
                        this.dgvCoopIni.CurrentCell = this.dgvCoopIni.Rows[currentRowIndex].Cells[currentColumnIndex];
                    }
                }
            }
        }

        /// <summary>
        /// Shows the dialog.
        /// </summary>
        /// <param name="parent">The parent.</param>
        /// <param name="selectedFacility">The selected facility.</param>
        /// <returns>DialogResult.</returns>
        public DialogResult ShowDialog(IWin32Window parent, MstFacilityEntity selectedFacility)
        {
            this.controller.Model.Facility = selectedFacility;

            return this.ShowDialog(parent);
        }
    }
}
