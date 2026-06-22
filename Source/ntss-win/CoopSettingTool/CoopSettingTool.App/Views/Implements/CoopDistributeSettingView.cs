// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-14-2022
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-14-2022
// ***********************************************************************
// <copyright file="CoopDistributeSettingView.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************

using CoopSettingTool.App.Controllers;
using CoopSettingTool.App.Dialogues;
using CoopSettingTool.App.Models;
using CoopSettingTool.App.Properties;
using CoopSettingTool.Service.Models;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Windows.Forms;

namespace CoopSettingTool.App.Views
{
    /// <summary>
    /// Class CoopDistributeSettingView.
    /// Implements the <see cref="CoopSettingTool.App.Views.BaseView" />
    /// Implements the <see cref="CoopSettingTool.App.Views.ICoopDistributeSettingView" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Views.BaseView" />
    /// <seealso cref="CoopSettingTool.App.Views.ICoopDistributeSettingView" />
    public partial class CoopDistributeSettingView : BaseView, ICoopDistributeSettingView
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
        ICoopDistributeSettingController controller;

        /// <summary>
        /// The coop cd select dialogue
        /// </summary>
        JsonEditDialog jsonEditDialog;

        /// <summary>
        /// The open file dialog
        /// </summary>
        OpenFileDialog openFileDialog;

        /// <summary>
        /// Initializes a new instance of the <see cref="CoopDistributeSettingView"/> class.
        /// </summary>
        /// <param name="model">The model.</param>
        public CoopDistributeSettingView(ICoopDistributeSettingModel model)
        {
            InitializeComponent(); 
            this.StartPosition = FormStartPosition.CenterParent;

            jsonEditDialog = new  JsonEditDialog();

            openFileDialog = new OpenFileDialog();
            openFileDialog.Title = "読み込む";
            openFileDialog.Filter = "Csv Files (*.csv)|*.csv";

            controller = new CoopDistributeSettingController(this, model);
            this.RegisterEvent();
        }

        /// <summary>
        /// Registers the event.
        /// </summary>
        private void RegisterEvent()
        {
            this.Shown += new EventHandler(OnFormShown);
            this.FormClosing += new FormClosingEventHandler(CoopDistributeSettingView_FormClosing);
            this.controller.Model.PropertyChanged += new PropertyChangedEventHandler(Model_PropertyChanged);

            this.btnSave.Click += new EventHandler(BtnSave_Click);
            this.btnCancel.Click += new EventHandler(BtnCancel_Click);
            this.btnFnwMerge.Click += new EventHandler(BtnFnwMerge_Click);
            this.dgvCoopDistribute.CellDoubleClick += new DataGridViewCellEventHandler(DgvCoopDistribute_CellDoubleClick);
            this.dgvCoopDistribute.ColumnHeaderMouseClick += new DataGridViewCellMouseEventHandler(DgvCoopDistribute_ColumnHeaderMouseClick);
            this.dgvCoopDistribute.CellEndEdit += new DataGridViewCellEventHandler(DgvCoopDistribute_CellEndEdit);
            this.dgvCoopDistribute.CellMouseClick += new DataGridViewCellMouseEventHandler(DgvCoopDistribute_CellMouseClick);
        }

        /// <summary>
        /// FNWからの連携配信設定を取り込む
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void BtnFnwMerge_Click(object sender, EventArgs e)
        {
            if (openFileDialog.ShowDialog(this) == DialogResult.OK)
            {
                string fileName = openFileDialog.FileName;
                this.controller.Import(fileName);
            }
        }

        /// <summary>
        /// Handles the CellMouseClick event of the DgvCoopDistribute control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="DataGridViewCellMouseEventArgs"/> instance containing the event data.</param>
        private void DgvCoopDistribute_CellMouseClick(object sender, DataGridViewCellMouseEventArgs e)
        {
            if (e.RowIndex == -1 && e.ColumnIndex == -1)
            {
                if (e.Button == MouseButtons.Right)
                {
                    foreach (DataGridViewColumn column in this.dgvCoopDistribute.Columns)
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
        /// Handles the CellEndEdit event of the DgvCoopDistribute control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="DataGridViewCellEventArgs"/> instance containing the event data.</param>
        private void DgvCoopDistribute_CellEndEdit(object sender, DataGridViewCellEventArgs e)
        {
            if (IsColumn(e.ColumnIndex, "IsDel"))
            {
                if (Convert.ToString(this.dgvCoopDistribute.CurrentCell.Value).Equals("1"))
                {
                    this.dgvCoopDistribute.CurrentRow.DefaultCellStyle.BackColor = Color.LightGray;
                }
                else
                {
                    this.dgvCoopDistribute.CurrentRow.DefaultCellStyle.BackColor = Color.White;
                }
            }
        }

        /// <summary>
        /// Handles the ColumnHeaderMouseClick event of the DgvCoopDistribute control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="DataGridViewCellMouseEventArgs"/> instance containing the event data.</param>
        private void DgvCoopDistribute_ColumnHeaderMouseClick(object sender, DataGridViewCellMouseEventArgs e)
        {
            sortIndex = e.ColumnIndex;
            sortAscending = !sortAscending;
            this.controller.Sort(this.dgvCoopDistribute.Columns[this.sortIndex].DataPropertyName, sortAscending);
        }

        /// <summary>
        /// Handles the FormClosing event of the OrderNumberSettingView control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="FormClosingEventArgs" /> instance containing the event data.</param>
        private void CoopDistributeSettingView_FormClosing(object sender, FormClosingEventArgs e)
        {
            this.controller.ClearData();
        }

        /// <summary>
        /// Handles the CellDoubleClick event of the DgvOrderSetting control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="DataGridViewCellEventArgs" /> instance containing the event data.</param>
        private void DgvCoopDistribute_CellDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
            if (IsColumn(e.ColumnIndex, "DistributeSetting") && e.RowIndex >= 0)
            {
                if (jsonEditDialog.ShowDialog(this, this.dgvCoopDistribute.Rows[e.RowIndex].Cells[e.ColumnIndex].Value as string) == DialogResult.OK)
                {
                    this.controller.Model.CoopDistributes[e.RowIndex].DistributeSetting = jsonEditDialog.OutputJson;
                }
            }
        }

        /// <summary>
        /// Determines whether the specified column is bound to the data property.
        /// </summary>
        /// <param name="columnIndex">Index of the column.</param>
        /// <param name="dataPropertyName">Name of the data property.</param>
        /// <returns><c>true</c> if the column is bound to the data property; otherwise, <c>false</c>.</returns>
        private bool IsColumn(int columnIndex, string dataPropertyName)
        {
            return columnIndex >= 0
                && columnIndex < this.dgvCoopDistribute.Columns.Count
                && this.dgvCoopDistribute.Columns[columnIndex].DataPropertyName == dataPropertyName;
        }

        /// <summary>
        /// Handles the Click event of the BtnCancel control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs" /> instance containing the event data.</param>
        private void BtnCancel_Click(object sender, EventArgs e)
        {
            this.CloseView(System.Windows.Forms.DialogResult.OK);
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
            this.controller.LoadCoopDistributes();
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
                case "Facility":
                    {
                        UpdateViewByFacility();
                        break;
                    }
                case "CoopDistributes":
                    {
                        UpdateCoopDistributeView();
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
        /// Delegate UpdateCoopDistributeViewCallback
        /// </summary>
        private delegate void UpdateCoopDistributeViewCallback();
        /// <summary>
        /// Updates the coop distribute view.
        /// </summary>
        private void UpdateCoopDistributeView()
        {
            if (this.dgvCoopDistribute.InvokeRequired)
            {
                UpdateCoopDistributeViewCallback calback = new UpdateCoopDistributeViewCallback(UpdateCoopDistributeView);
                this.Invoke(calback);
            }
            else
            {
                this.dgvCoopDistribute.DataSource = new List<MstCoopDistributeEntity>();
                this.btnSave.Enabled = false;
                if (this.controller.Model.CoopDistributes != null)
                {
                    this.btnSave.Enabled = true;
                    this.dgvCoopDistribute.DataSource = this.controller.Model.CoopDistributes;

                    // 削除された行をグレーに表示される
                    for (int i = 0; i < this.controller.Model.CoopDistributes.Count; i++)
                    {
                        if (this.controller.Model.CoopDistributes[i].IsDel.Equals("1"))
                        {
                            this.dgvCoopDistribute.Rows[i].DefaultCellStyle.BackColor = Color.LightGray;
                        }
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
