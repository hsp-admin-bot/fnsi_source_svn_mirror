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
using CoopSettingTool.App.Models;
using CoopSettingTool.Service.Models;
using System;
using System.Collections.Generic;
using System.ComponentModel;
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
        /// Initializes a new instance of the <see cref="IfEdgeSettingView"/> class.
        /// </summary>
        /// <param name="model">The model.</param>
        public IfEdgeSettingView(IIfEdgeSettingModel model)
        {
            InitializeComponent();
            this.StartPosition = FormStartPosition.CenterParent;

            controller = new IfEdgeSettingController(this, model);
            this.RegisterEvent();
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
                        column.AutoSizeMode = DataGridViewAutoSizeColumnMode.AllCells;
                        int colw = column.Width;
                        column.AutoSizeMode = DataGridViewAutoSizeColumnMode.None;
                        column.Width = colw;
                    }
                }
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
            this.controller.AddNewIfEdge();
            this.dgvIfEdgeSetting.CurrentCell = this.dgvIfEdgeSetting.Rows[this.dgvIfEdgeSetting.Rows.Count - 1].Cells[0];
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
                this.dgvIfEdgeSetting.DataSource = new List<MstIfEdgeEntity>();
                this.btnSave.Enabled = false;
                if (this.controller.Model.IfEdgeList != null)
                {
                    if(this.controller.Model.IfEdgeList.Count > 0)
                    {
                        this.btnSave.Enabled = true;
                    }
                   
                    this.dgvIfEdgeSetting.DataSource = this.controller.Model.IfEdgeList;
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
