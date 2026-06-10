// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 05-24-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-25-2021
// ***********************************************************************
// <copyright file="OrderNumberSettingView.cs" company="">
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
using System.Windows.Forms;

namespace CoopSettingTool.App.Views
{
    /// <summary>
    /// Class OrderNumberSettingView.
    /// Implements the <see cref="CoopSettingTool.App.Views.BaseView" />
    /// Implements the <see cref="CoopSettingTool.App.Views.IOrderNumberSettingView" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Views.BaseView" />
    /// <seealso cref="CoopSettingTool.App.Views.IOrderNumberSettingView" />
    public partial class OrderNumberSettingView : BaseView, IOrderNumberSettingView
    {
        /// <summary>
        /// The controller
        /// </summary>
        IOrderNumberSettingController controller;

        /// <summary>
        /// The coop cd select dialogue
        /// </summary>
        CoopCdSelectDialogue coopCdSelectDialogue;

        /// <summary>
        /// The open file dialog
        /// </summary>
        OpenFileDialog openFileDialog;

        /// <summary>
        /// Initializes a new instance of the <see cref="OrderNumberSettingView"/> class.
        /// </summary>
        /// <param name="model">The model.</param>
        public OrderNumberSettingView(IOrderNumberSettingModel model)
        {
            InitializeComponent(); 
            this.StartPosition = FormStartPosition.CenterParent;

            coopCdSelectDialogue = new CoopCdSelectDialogue();

            openFileDialog = new OpenFileDialog();
            openFileDialog.Title = "読み込む";
            openFileDialog.Filter = "Csv Files (*.csv)|*.csv";

            controller = new OrderNumberSettingController(this, model);
            this.RegisterEvent();
        }

        /// <summary>
        /// Registers the event.
        /// </summary>
        private void RegisterEvent()
        {
            this.Shown += new EventHandler(OnFormShown);
            this.FormClosing += new FormClosingEventHandler(OrderNumberSettingView_FormClosing);
            this.controller.Model.PropertyChanged += new PropertyChangedEventHandler(Model_PropertyChanged);

            this.btnSave.Click += new EventHandler(BtnSave_Click);
            this.btnCancel.Click += new EventHandler(BtnCancel_Click);
            this.btnAdd.Click += BtnAdd_Click;
            this.btnImport.Click += new EventHandler(BtnImport_Click);
            this.dgvOrderSetting.CellDoubleClick += new DataGridViewCellEventHandler(DgvOrderSetting_CellDoubleClick);
            this.dgvOrderSetting.CellMouseClick += new DataGridViewCellMouseEventHandler(DgvOrderSetting_CellMouseClick);
        }

        /// <summary>
        /// FNWからのオーダ番号設定を取り込む
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void BtnImport_Click(object sender, EventArgs e)
        {
            if (openFileDialog.ShowDialog(this) == DialogResult.OK)
            {
                string fileName = openFileDialog.FileName;
                this.controller.Import(fileName);
            }
        }

        /// <summary>
        /// Handles the CellMouseClick event of the DgvOrderSetting control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="DataGridViewCellMouseEventArgs"/> instance containing the event data.</param>
        private void DgvOrderSetting_CellMouseClick(object sender, DataGridViewCellMouseEventArgs e)
        {
            if (e.RowIndex == -1 && e.ColumnIndex == -1)
            {
                if (e.Button == MouseButtons.Right)
                {
                    foreach (DataGridViewColumn column in this.dgvOrderSetting.Columns)
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
        /// Handles the FormClosing event of the OrderNumberSettingView control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="FormClosingEventArgs"/> instance containing the event data.</param>
        private void OrderNumberSettingView_FormClosing(object sender, FormClosingEventArgs e)
        {
            this.controller.ClearData();
        }

        /// <summary>Handles the CellDoubleClick event of the DgvOrderSetting control.</summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="DataGridViewCellEventArgs" /> instance containing the event data.</param>
        private void DgvOrderSetting_CellDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.ColumnIndex == 0 && e.RowIndex >= 0)
            {
                if (coopCdSelectDialogue.ShowDialog(this, this.dgvOrderSetting.Rows[e.RowIndex].Cells[e.ColumnIndex].Value as string) == DialogResult.OK)
                {
                    this.controller.Model.SysCoopNoList[e.RowIndex].OrdCds = coopCdSelectDialogue.SelectedCoopCds;
                    UpdateOrderSettingListView();
                }
            }
        }

        /// <summary>Handles the Click event of the BtnAdd control.</summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs" /> instance containing the event data.</param>
        private void BtnAdd_Click(object sender, EventArgs e)
        {
            this.controller.AddBlankOrderNumberSetting();
            this.dgvOrderSetting.CurrentCell = this.dgvOrderSetting.Rows[this.dgvOrderSetting.Rows.Count - 1].Cells[0];
        }

        /// <summary>
        /// Handles the Click event of the BtnCancel control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void BtnCancel_Click(object sender, EventArgs e)
        {
            this.CloseView(System.Windows.Forms.DialogResult.OK);
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
            this.controller.LoadSysCoopNoList();
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
                case "SysCoopNoList":
                    {
                        UpdateOrderSettingListView();
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
        /// Delegate UpdateOrderSettingListViewCallback
        /// </summary>
        private delegate void UpdateOrderSettingListViewCallback();
        /// <summary>
        /// Updates the order setting ListView.
        /// </summary>
        private void UpdateOrderSettingListView()
        {
            if (this.dgvOrderSetting.InvokeRequired)
            {
                UpdateOrderSettingListViewCallback calback = new UpdateOrderSettingListViewCallback(UpdateOrderSettingListView);
                this.Invoke(calback);
            }
            else
            {
                this.dgvOrderSetting.DataSource = new List<SysCoopNoEntity>();
                this.btnSave.Enabled = false;
                if (this.controller.Model.SysCoopNoList != null)
                {
                    if (this.controller.Model.SysCoopNoList.Count > 0)
                    {
                        this.btnSave.Enabled = true;
                    }
                    
                    this.dgvOrderSetting.DataSource = this.controller.Model.SysCoopNoList;
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
