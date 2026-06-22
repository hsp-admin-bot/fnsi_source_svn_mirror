// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-13-2022
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-14-2022
// ***********************************************************************
// <copyright file="CoopFacilitySettingView.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************

using CoopSettingTool.App.Controllers;
using CoopSettingTool.App.Dialogues;
using CoopSettingTool.App.Models;
using CoopSettingTool.App.Properties;
using CoopSettingTool.Service.Models;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Windows.Forms;

namespace CoopSettingTool.App.Views
{
    /// <summary>
    /// Class CoopFacilitySettingView.
    /// Implements the <see cref="CoopSettingTool.App.Views.BaseView" />
    /// Implements the <see cref="CoopSettingTool.App.Views.ICoopFacilitySettingView" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Views.BaseView" />
    /// <seealso cref="CoopSettingTool.App.Views.ICoopFacilitySettingView" />
    public partial class CoopFacilitySettingView : BaseView, ICoopFacilitySettingView
    {
        /// <summary>
        /// The controller
        /// </summary>
        ICoopFacilitySettingController controller;

        /// <summary>
        /// The coop cd select dialogue
        /// </summary>
        JsonEditDialog jsonEditDialog;

        /// <summary>
        /// The open file dialog
        /// </summary>
        OpenFileDialog openFileDialog;

        /// <summary>
        /// Initializes a new instance of the <see cref="CoopFacilitySettingView"/> class.
        /// </summary>
        /// <param name="model">The model.</param>
        public CoopFacilitySettingView(ICoopFacilitySettingModel model)
        {
            InitializeComponent(); 
            this.StartPosition = FormStartPosition.CenterParent;

            jsonEditDialog = new  JsonEditDialog();

            openFileDialog = new OpenFileDialog();
            openFileDialog.Title = "読み込む";
            openFileDialog.Filter = "Csv Files (*.csv)|*.csv";

            controller = new CoopFacilitySettingController(this, model);
            this.RegisterEvent();
        }

        /// <summary>
        /// Registers the event.
        /// </summary>
        private void RegisterEvent()
        {
            this.Shown += new EventHandler(OnFormShown);
            this.FormClosing += new FormClosingEventHandler(CoopFacilitySettingView_FormClosing);
            this.controller.Model.PropertyChanged += new PropertyChangedEventHandler(Model_PropertyChanged);

            this.btnSave.Click += new EventHandler(BtnSave_Click);
            this.btnCancel.Click += new EventHandler(BtnCancel_Click);
            this.btnImport.Click += new EventHandler(BtnImport_Click);
            this.dgvCoopFacility.CellDoubleClick += new DataGridViewCellEventHandler(DgvOrderSetting_CellDoubleClick);
            this.dgvCoopFacility.CellValidating += new DataGridViewCellValidatingEventHandler(DgvCoopFacility_CellValidating);
            this.dgvCoopFacility.CellMouseClick += new DataGridViewCellMouseEventHandler(DgvCoopFacility_CellMouseClick);
            this.dgvCoopFacility.CellEndEdit += new DataGridViewCellEventHandler(DgvCoopFacility_CellEndEdit);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void DgvCoopFacility_CellEndEdit(object sender, DataGridViewCellEventArgs e)
        {
            if (e.ColumnIndex == 5)
            {
                if (this.dgvCoopFacility.CurrentCell.Value.ToString().Equals("1"))
                {
                    this.dgvCoopFacility.CurrentRow.DefaultCellStyle.BackColor = Color.LightGray;
                }
                else
                {
                    this.dgvCoopFacility.CurrentRow.DefaultCellStyle.BackColor = Color.White;
                }
            }
        }

        /// <summary>
        /// 
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
        /// Handles the CellMouseClick event of the DgvCoopFacility control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="DataGridViewCellMouseEventArgs"/> instance containing the event data.</param>
        private void DgvCoopFacility_CellMouseClick(object sender, DataGridViewCellMouseEventArgs e)
        {
            if (e.RowIndex == -1 && e.ColumnIndex == -1)
            {
                if(e.Button == MouseButtons.Right)
                {
                    foreach(DataGridViewColumn column in this.dgvCoopFacility.Columns)
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
        /// Handles the CellValidating event of the DgvCoopFacility control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="DataGridViewCellValidatingEventArgs"/> instance containing the event data.</param>
        private void DgvCoopFacility_CellValidating(object sender, DataGridViewCellValidatingEventArgs e)
        {
            if (e.ColumnIndex == 3 || e.ColumnIndex == 4)
            {
                string value = e.FormattedValue.ToString();
                bool isFailed = false;
                try
                {
                    var item = JsonConvert.DeserializeObject(value);
                    var json  = JsonConvert.SerializeObject(item, Formatting.None);
                }
                catch
                {
                    isFailed = true;
                }

                if (isFailed)
                {
                    this.dgvCoopFacility.Rows[e.RowIndex].ErrorText = "JSONデータの形式は正しくないです。";
                    e.Cancel = true;
                }
            }
        }

        /// <summary>
        /// Handles the FormClosing event of the CoopFacilitySettingView control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="FormClosingEventArgs"/> instance containing the event data.</param>
        private void CoopFacilitySettingView_FormClosing(object sender, FormClosingEventArgs e)
        {
            this.controller.ClearData();
        }

        /// <summary>
        /// Handles the CellDoubleClick event of the DgvOrderSetting control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="DataGridViewCellEventArgs" /> instance containing the event data.</param>
        private void DgvOrderSetting_CellDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
            if ((e.ColumnIndex == 3 || e.ColumnIndex == 4) && e.RowIndex >= 0)
            {
                if (jsonEditDialog.ShowDialog(this, this.dgvCoopFacility.Rows[e.RowIndex].Cells[e.ColumnIndex].Value as string) == DialogResult.OK)
                {
                    if (e.ColumnIndex == 3)
                    {
                        this.controller.Model.CoopFacility.IfEdgeSetting = jsonEditDialog.OutputJson;
                    }
                    else if (e.ColumnIndex == 4)
                    {
                        this.controller.Model.CoopFacility.CommonSetting = jsonEditDialog.OutputJson;
                    }
                }
            }
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
            this.controller.LoadCoopFacility();
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
                case "CoopFacility":
                    {
                        UpdateCoopFacilityView();
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
        /// Delegate UpdateCoopFacilityViewCallback
        /// </summary>
        private delegate void UpdateCoopFacilityViewCallback();
        /// <summary>
        /// Updates the coop facility view.
        /// </summary>
        private void UpdateCoopFacilityView()
        {
            if (this.dgvCoopFacility.InvokeRequired)
            {
                UpdateCoopFacilityViewCallback calback = new UpdateCoopFacilityViewCallback(UpdateCoopFacilityView);
                this.Invoke(calback);
            }
            else
            {
                this.dgvCoopFacility.DataSource = new List<MstCoopFacilityEntity>();
                this.btnSave.Enabled = false;
                if (this.controller.Model.CoopFacility != null)
                {
                    this.btnSave.Enabled = true;
                    this.dgvCoopFacility.DataSource = new List<MstCoopFacilityEntity>() { this.controller.Model.CoopFacility };

                    if (this.controller.Model.CoopFacility.IsDel.Equals("1"))
                    {
                        this.dgvCoopFacility.Rows[0].DefaultCellStyle.BackColor = Color.LightGray;
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
