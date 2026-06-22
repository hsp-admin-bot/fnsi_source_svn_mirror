// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-23-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-24-2021
// ***********************************************************************
// <copyright file="CoopFunctionListView.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************

using CoopSettingTool.App.Controllers;
using CoopSettingTool.App.DI;
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
    /// Class CoopFunctionListView.
    /// Implements the <see cref="CoopSettingTool.App.Views.BaseView" />
    /// Implements the <see cref="CoopSettingTool.App.Views.ICoopFunctionListView" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Views.BaseView" />
    /// <seealso cref="CoopSettingTool.App.Views.ICoopFunctionListView" />
    public partial class CoopFunctionListView : BaseView, ICoopFunctionListView
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
        /// The controller
        /// </summary>
        ICoopFunctionListController controller;

        /// <summary>
        /// The coop function setting view
        /// </summary>
        ICoopFunctionSettingView coopFunctionSettingView;
        
        /// <summary>
        /// Initializes a new instance of the <see cref="CoopFunctionListView"/> class.
        /// </summary>
        /// <param name="model">The model.</param>
        public CoopFunctionListView(ICoopFunctionListModel model)
        {
            InitializeComponent();
            this.StartPosition = FormStartPosition.CenterParent;

            // 機能設定画面
            coopFunctionSettingView = CompositionRoot.Resolve<ICoopFunctionSettingView>();

            controller = new CoopFunctionListController(this, model);
            this.RegisterEvent();
        }

        /// <summary>
        /// Registers the event.
        /// </summary>
        private void RegisterEvent()
        {
            this.Shown += new EventHandler(OnFormShown);
            this.FormClosing += new FormClosingEventHandler(CoopFunctionListView_FormClosing);
            this.controller.Model.PropertyChanged += new PropertyChangedEventHandler(Model_PropertyChanged);

            this.dgvCoopFunction.SelectionChanged += new EventHandler(DgvCoopFunction_SelectionChanged);
            this.dgvCoopFunction.ColumnHeaderMouseClick += new DataGridViewCellMouseEventHandler(DgvCoopFunction_ColumnHeaderMouseClick);
            this.dgvCoopFunction.CellMouseDoubleClick += new DataGridViewCellMouseEventHandler(DgvCoopFunction_CellMouseDoubleClick);

            this.btnEdit.Click += new EventHandler(BtnEdit_Click);
            this.btnFinish.Click += new EventHandler(BtnFinish_Click);
        }

        /// <summary>
        /// Handles the FormClosing event of the CoopFunctionListView control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="FormClosingEventArgs"/> instance containing the event data.</param>
        private void CoopFunctionListView_FormClosing(object sender, FormClosingEventArgs e)
        {
            this.controller.ClearData();
        }

        /// <summary>
        /// Handles the DgvCoopFunction_CellMouseDoubleClick
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void DgvCoopFunction_CellMouseDoubleClick(object sender, DataGridViewCellMouseEventArgs e)
        {
            if(e.Button == MouseButtons.Left && e.RowIndex >= 0)
            {
                BtnEdit_Click(sender, new EventArgs());
            }
        }

        /// <summary>
        /// Handles the ColumnHeaderMouseClick event of the DgvCoopFunction control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="DataGridViewCellMouseEventArgs"/> instance containing the event data.</param>
        /// <exception cref="NotImplementedException"></exception>
        private void DgvCoopFunction_ColumnHeaderMouseClick(object sender, DataGridViewCellMouseEventArgs e)
        {
            sortIndex = e.ColumnIndex;
            sortAscending = !sortAscending;
            UpdateCoopFunctionListView();
        }

        /// <summary>
        /// Handles the Click event of the BtnFinish control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void BtnFinish_Click(object sender, EventArgs e)
        {
            this.CloseView(System.Windows.Forms.DialogResult.OK);
        }

        /// <summary>
        /// Handles the Click event of the BtnEdit control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void BtnEdit_Click(object sender, EventArgs e)
        {
            this.HideView();

            var rs = coopFunctionSettingView.ShowDialog(this, this.controller.Model.Facility, this.controller.Model.CoopFacility, this.controller.Model.SelectedCoopFunctionIndex);

            if(rs == DialogResult.Abort)
            {
                this.CloseView(DialogResult.Abort);
            }

            LoadView();
            this.ShowView();
        }

        /// <summary>
        /// Handles the SelectionChanged event of the DgvCoopFunction control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void DgvCoopFunction_SelectionChanged(object sender, EventArgs e)
        {
            if(this.dgvCoopFunction.SelectedRows.Count == 1)
            {
                this.controller.Model.SelectedCoopFunctionIndex = this.dgvCoopFunction.CurrentCell.RowIndex;
                this.btnEdit.Enabled = true;
            }
            else
            {
                this.btnEdit.Enabled = false;
            }
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
                case "CoopFacility":
                    {

                        UpdateCoopFunctionListView();

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
                }
            }
        }

        /// <summary>
        /// Delegate UpdateCoopFunctionListViewCallback
        /// </summary>
        private delegate void UpdateCoopFunctionListViewCallback();
        /// <summary>
        /// Updates the coop function ListView.
        /// </summary>
        private void UpdateCoopFunctionListView()
        {
            if (this.dgvCoopFunction.InvokeRequired)
            {
                UpdateCoopFunctionListViewCallback calback = new UpdateCoopFunctionListViewCallback(UpdateCoopFunctionListView);
                this.Invoke(calback);
            }
            else
            {
                if (this.controller.Model.CoopFacility != null)
                {
                    this.dgvCoopFunction.DataSource = new List<OrdCd>();
                    var dataList = this.controller.Model.CoopFacility.CommonSetting.CoopOrdCds;

                    // ソートする
                    if (sortAscending)
                        dataList = dataList.OrderBy(this.dgvCoopFunction.Columns[this.sortIndex].DataPropertyName).ToList();
                    else
                        dataList = dataList.OrderBy(this.dgvCoopFunction.Columns[this.sortIndex].DataPropertyName).Reverse().ToList();
                    this.dgvCoopFunction.DataSource = dataList;

                    // 無効アイテムをグレーにする
                    for (int i = 0; i < this.controller.Model.CoopFacility.CommonSetting.CoopOrdCds.Count; i++)
                    {
                        if (!this.controller.Model.CoopFacility.CommonSetting.CoopOrdCds[i].Enable)
                        {
                            this.dgvCoopFunction.Rows[i].DefaultCellStyle.BackColor = Color.LightGray;
                        }
                    }
                    this.dgvCoopFunction.Refresh();  
                }
            }
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
            this.controller.LoadCoopFacility(); 
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
