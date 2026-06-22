// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 05-25-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-27-2021
// ***********************************************************************
// <copyright file="IfEdgeSettingView.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.App.Controllers;
using CoopSettingTool.App.Enums;
using CoopSettingTool.App.Models;
using CoopSettingTool.Log;
using CoopSettingTool.Service.Models;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Linq;
using System.Windows.Forms;

namespace CoopSettingTool.App.Views
{
    /// <summary>
    /// Class IfEdgeSettingView.
    /// Implements the <see cref="CoopSettingTool.App.Views.BaseView" />
    /// Implements the <see cref="CoopSettingTool.App.Views.IIfEdgeSettingView" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Views.BaseView" />
    /// <seealso cref="CoopSettingTool.App.Views.IIfEdgeSettingView" />
    public partial class IfEdgeSettingView : BaseView, IIfEdgeSettingView
    {
        /// <summary>
        /// The controller
        /// </summary>
        IIfEdgeSettingController controller;

        /// <summary>
        /// The IF edge binding source
        /// </summary>
        private readonly BindingSource ifEdgeBindingSource = new BindingSource();

        /// <summary>
        /// Initializes a new instance of the <see cref="IfEdgeSettingView"/> class.
        /// </summary>
        /// <param name="model">The model.</param>
        public IfEdgeSettingView(IIfEdgeSettingModel model)
        {
            InitializeComponent();
            this.StartPosition = FormStartPosition.CenterParent;
            this.dgvIfEdgeSetting.DataSource = this.ifEdgeBindingSource;

            controller = new IfEdgeSettingController(this, model);
            this.RegisterEvent();
            this.UpdateAddButtonState();
        }

        /// <summary>
        /// Registers the event.
        /// </summary>
        private void RegisterEvent()
        {
            this.Shown += new EventHandler(OnFormShown);
            this.controller.Model.PropertyChanged += new PropertyChangedEventHandler(Model_PropertyChanged);

            this.btnSave.Click += new EventHandler(BtnSave_Click);
            this.btnCancel.Click += new EventHandler(BtnCancel_Click);
            this.btnAdd.Click += new EventHandler(BtnAdd_Click);
            this.FormClosing += new FormClosingEventHandler(IfEdgeSettingView_FormClosing);
            this.dgvIfEdgeSetting.CellMouseClick += new DataGridViewCellMouseEventHandler(DgvIfEdgeSetting_CellMouseClick);
            this.dgvIfEdgeSetting.DataError += new DataGridViewDataErrorEventHandler(DgvIfEdgeSetting_DataError);
            this.dgvIfEdgeSetting.DataBindingComplete += new DataGridViewBindingCompleteEventHandler(DgvIfEdgeSetting_DataBindingComplete);
        }

        /// <summary>
        /// Handles the CellMouseClick event of the DgvIfEdgeSetting control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="DataGridViewCellMouseEventArgs"/> instance containing the event data.</param>
        private void DgvIfEdgeSetting_CellMouseClick(object sender, DataGridViewCellMouseEventArgs e)
        {
            if (e.RowIndex == -1 && e.ColumnIndex == -1)
            {
                if (e.Button == MouseButtons.Right)
                {
                    foreach (DataGridViewColumn column in this.dgvIfEdgeSetting.Columns)
                    {
                        if (!column.Visible)
                        {
                            continue;
                        }

                        column.AutoSizeMode = DataGridViewAutoSizeColumnMode.AllCells;
                        int colw = column.Width;
                        column.AutoSizeMode = DataGridViewAutoSizeColumnMode.None;
                        column.Width = colw;
                    }
                }
            }
        }

        /// <summary>
        /// Determines whether the specified IF edge setting is valid.
        /// </summary>
        /// <param name="ifEdge">The IF edge setting.</param>
        /// <returns><c>true</c> if the setting is valid; otherwise, <c>false</c>.</returns>
        private bool IsValidIfEdgeSetting(MstIfEdgeEntity ifEdge)
        {
            return ifEdge != null && ifEdge.IsDel != "1" && ifEdge.IsDisp != "0";
        }

        /// <summary>
        /// Determines whether the current model has a valid IF edge setting.
        /// </summary>
        /// <returns><c>true</c> if the model has a valid IF edge setting; otherwise, <c>false</c>.</returns>
        private bool HasValidIfEdgeSetting()
        {
            return this.controller?.Model?.IfEdgeList?.Any(this.IsValidIfEdgeSetting) == true;
        }

        /// <summary>
        /// Hides internal IF edge columns from the grid.
        /// </summary>
        private void HideInternalIfEdgeColumns()
        {
            foreach (DataGridViewColumn column in this.dgvIfEdgeSetting.Columns)
            {
                if (column == null)
                {
                    continue;
                }

                if (column.DataPropertyName == nameof(MstIfEdgeEntity.IfEdgeNo)
                    || column.Name == nameof(MstIfEdgeEntity.IfEdgeNo)
                    || column.HeaderText == "IFエッジ番号")
                {
                    column.Visible = false;
                    column.ReadOnly = true;
                }
            }
        }

        /// <summary>
        /// Gets IF edge list status.
        /// </summary>
        /// <returns>IF edge list status.</returns>
        private string GetIfEdgeListStatus()
        {
            int modelCount = this.controller?.Model?.IfEdgeList?.Count ?? 0;
            int validCount = this.controller?.Model?.IfEdgeList?.Count(this.IsValidIfEdgeSetting) ?? 0;
            int gridRowCount = this.dgvIfEdgeSetting?.Rows?.Count ?? 0;
            int bindingCount = this.ifEdgeBindingSource?.Count ?? 0;
            int bindingPosition = this.ifEdgeBindingSource?.Position ?? -1;

            return $"ModelCount={modelCount}, ValidCount={validCount}, GridRowCount={gridRowCount}, BindingCount={bindingCount}, BindingPosition={bindingPosition}, AddEnabled={this.btnAdd.Enabled}, Visible={this.Visible}, IsDisposed={this.IsDisposed}";
        }

        /// <summary>
        /// Updates add button state.
        /// </summary>
        private void UpdateAddButtonState()
        {
            bool canAdd = !this.HasValidIfEdgeSetting();

            if (!canAdd)
            {
                this.MoveFocusFromAddButton();
            }

            this.btnAdd.Enabled = canAdd;
            this.btnAdd.Primary = canAdd;
            this.btnAdd.UseVisualStyleBackColor = canAdd;
            this.btnAdd.BackColor = canAdd ? SystemColors.Control : Color.Gray;
            this.btnAdd.ForeColor = canAdd ? SystemColors.ControlText : SystemColors.ControlDarkDark;
        }

        /// <summary>
        /// Moves focus from add button before disabling it.
        /// </summary>
        private void MoveFocusFromAddButton()
        {
            if (!this.btnAdd.Focused)
            {
                return;
            }

            if (this.btnSave.Enabled && this.btnSave.CanSelect)
            {
                this.btnSave.Select();
                return;
            }

            if (this.btnCancel.CanSelect)
            {
                this.btnCancel.Select();
            }
        }

        /// <summary>
        /// Schedules IF edge list state update after data binding is completed.
        /// </summary>
        private void BeginUpdateIfEdgeListViewState()
        {
            if (this.IsDisposed || this.Disposing || !this.IsHandleCreated)
            {
                return;
            }

            LogHelper.LogInfo($"IFEdge list state update scheduled. {this.GetIfEdgeListStatus()}");
            this.BeginInvoke(new Action(() =>
            {
                try
                {
                    if (this.IsDisposed || this.Disposing)
                    {
                        return;
                    }

                    this.EnsureIfEdgeBindingPosition();
                    this.UpdateAddButtonState();
                    LogHelper.LogInfo($"IFEdge list state update completed. {this.GetIfEdgeListStatus()}");
                }
                catch (Exception ex)
                {
                    LogHelper.LogError($"IFEdge list state update failed. {this.GetIfEdgeListStatus()}", ex);
                }
            }));
        }

        /// <summary>
        /// Ensures IF edge binding source has a valid current item.
        /// </summary>
        private void EnsureIfEdgeBindingPosition()
        {
            if (this.ifEdgeBindingSource.Count <= 0)
            {
                return;
            }

            if (this.ifEdgeBindingSource.Position < 0 || this.ifEdgeBindingSource.Position >= this.ifEdgeBindingSource.Count)
            {
                this.ifEdgeBindingSource.Position = this.ifEdgeBindingSource.Count - 1;
            }
        }

        /// <summary>
        /// Handles the FormClosing event of the IfEdgeSettingView control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="FormClosingEventArgs"/> instance containing the event data.</param>
        private void IfEdgeSettingView_FormClosing(object sender, FormClosingEventArgs e)
        {
            this.controller.ClearData();
        }

        /// <summary>
        /// Handles the Click event of the BtnAdd control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void BtnAdd_Click(object sender, EventArgs e)
        {
            try
            {
                LogHelper.LogInfo($"IFEdge add button clicked. {this.GetIfEdgeListStatus()}");

                if (this.HasValidIfEdgeSetting())
                {
                    this.BeginUpdateIfEdgeListViewState();
                    LogHelper.LogInfo($"IFEdge add skipped because valid setting already exists. {this.GetIfEdgeListStatus()}");
                    return;
                }

                this.controller.AddNewIfEdge();
                LogHelper.LogInfo($"IFEdge add model updated. {this.GetIfEdgeListStatus()}");
            }
            catch (Exception ex)
            {
                LogHelper.LogError($"IFEdge add button failed. {this.GetIfEdgeListStatus()}", ex);
                this.ShowMessage("IFエッジ設定の追加処理に失敗しました。ログを確認してください。", "エラー", MessageTypeEnum.ERROR);
            }
        }

        /// <summary>
        /// Handles the DataError event of the DgvIfEdgeSetting control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="DataGridViewDataErrorEventArgs"/> instance containing the event data.</param>
        private void DgvIfEdgeSetting_DataError(object sender, DataGridViewDataErrorEventArgs e)
        {
            LogHelper.LogError($"IFEdge grid data error. RowIndex={e.RowIndex}, ColumnIndex={e.ColumnIndex}, Context={e.Context}, {this.GetIfEdgeListStatus()}", e.Exception);
            e.ThrowException = false;
        }

        /// <summary>
        /// Handles the DataBindingComplete event of the DgvIfEdgeSetting control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="DataGridViewBindingCompleteEventArgs"/> instance containing the event data.</param>
        private void DgvIfEdgeSetting_DataBindingComplete(object sender, DataGridViewBindingCompleteEventArgs e)
        {
            this.HideInternalIfEdgeColumns();
        }

        /// <summary>
        /// Handles the Click event of the BtnCancel control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void BtnCancel_Click(object sender, EventArgs e)
        {
            this.CloseView(System.Windows.Forms.DialogResult.Cancel);
        }

        /// <summary>
        /// Handles the Click event of the BtnSave control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void BtnSave_Click(object sender, EventArgs e)
        {
            this.controller.Save();
        }

        /// <summary>
        /// Handles the <see cref="E:FormShown" /> event.
        /// </summary>
        /// <param name="sender">The sender.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void OnFormShown(object sender, EventArgs e)
        {
            LoadView();
        }

        /// <summary>
        /// Loads the view.
        /// </summary>
        private void LoadView()
        {
            this.controller.LoadIfEdgeList();
        }

        /// <summary>
        /// Handles the PropertyChanged event of the Model control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="PropertyChangedEventArgs"/> instance containing the event data.</param>
        private void Model_PropertyChanged(object sender, PropertyChangedEventArgs e)
        {
            switch (e.PropertyName)
            {
                case "IfEdgeList":
                    {
                        UpdateIfEdgeListView();
                        break;
                    }
                case "Facility":
                    {
                        UpdateViewByFacility();
                        break;
                    }
            }
        }

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
                }
            }
        }

        /// <summary>
        /// Delegate UpdateIfEdgeListViewCallback
        /// </summary>
        private delegate void UpdateIfEdgeListViewCallback();
        /// <summary>
        /// Updates if edge ListView.
        /// </summary>
        private void UpdateIfEdgeListView()
        {
            if (this.dgvIfEdgeSetting.InvokeRequired)
            {
                UpdateIfEdgeListViewCallback calback = new UpdateIfEdgeListViewCallback(UpdateIfEdgeListView);
                this.Invoke(calback);
            }
            else
            {
                List<MstIfEdgeEntity> ifEdgeList = this.controller.Model.IfEdgeList ?? new List<MstIfEdgeEntity>();
                this.btnSave.Enabled = false;
                if (ifEdgeList.Count > 0)
                {
                    this.btnSave.Enabled = true;
                }

                this.ifEdgeBindingSource.DataSource = ifEdgeList;
                this.ifEdgeBindingSource.ResetBindings(false);
                this.HideInternalIfEdgeColumns();
                this.EnsureIfEdgeBindingPosition();
                this.BeginUpdateIfEdgeListViewState();
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
