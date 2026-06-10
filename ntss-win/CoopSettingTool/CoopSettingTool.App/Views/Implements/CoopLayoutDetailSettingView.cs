// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 05-24-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-14-2022
// ***********************************************************************
// <copyright file="CoopLayoutDetailSettingView.cs" company="">
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
    /// Class CoopLayoutDetailSettingView.
    /// Implements the <see cref="CoopSettingTool.App.Views.BaseView" />
    /// Implements the <see cref="CoopSettingTool.App.Views.ICoopLayoutDetailSettingView" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Views.BaseView" />
    /// <seealso cref="CoopSettingTool.App.Views.ICoopLayoutDetailSettingView" />
    public partial class CoopLayoutDetailSettingView : BaseView, ICoopLayoutDetailSettingView
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
        ICoopLayoutDetailSettingController controller;

        /// <summary>
        /// The coop cd select dialogue
        /// </summary>
        JsonEditDialog jsonEditDialog;

        /// <summary>
        /// The XML edit dialog
        /// </summary>
        XmlEditDialog xmlEditDialog;

        /// <summary>
        /// Initializes a new instance of the <see cref="CoopLayoutDetailSettingView" /> class.
        /// </summary>
        /// <param name="model">The model.</param>
        public CoopLayoutDetailSettingView(ICoopLayoutDetailSettingModel model)
        {
            InitializeComponent(); 
            this.StartPosition = FormStartPosition.CenterParent;

            jsonEditDialog = new  JsonEditDialog();
            xmlEditDialog = new XmlEditDialog();

            controller = new CoopLayoutDetailSettingController(this, model);
            this.RegisterEvent();
        }

        /// <summary>
        /// Registers the event.
        /// </summary>
        private void RegisterEvent()
        {
            this.Shown += new EventHandler(OnFormShown);
            this.FormClosing += new FormClosingEventHandler(CoopLayoutDetailSettingView_FormClosing);
            this.controller.Model.PropertyChanged += new PropertyChangedEventHandler(Model_PropertyChanged);

            this.btnSave.Click += new EventHandler(BtnSave_Click);
            this.btnCancel.Click += new EventHandler(BtnCancel_Click);
            this.dgvCoopLayoutDetail.CellDoubleClick += new DataGridViewCellEventHandler(DgvCoopLayoutDetail_CellDoubleClick);
            this.dgvCoopLayoutDetail.ColumnHeaderMouseClick += new DataGridViewCellMouseEventHandler(DgvCoopLayoutDetail_ColumnHeaderMouseClick);
            this.dgvCoopLayoutDetail.CellEndEdit += new DataGridViewCellEventHandler(DgvCoopLayoutDetail_CellEndEdit);
            this.dgvCoopLayoutDetail.CellMouseClick += new DataGridViewCellMouseEventHandler(DgvCoopLayoutDetail_CellMouseClick);
        }

        /// <summary>
        /// Handles the CellMouseClick event of the DgvCoopLayoutDetail control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="DataGridViewCellMouseEventArgs"/> instance containing the event data.</param>
        private void DgvCoopLayoutDetail_CellMouseClick(object sender, DataGridViewCellMouseEventArgs e)
        {
            if (e.RowIndex == -1 && e.ColumnIndex == -1)
            {
                if (e.Button == MouseButtons.Right)
                {
                    foreach (DataGridViewColumn column in this.dgvCoopLayoutDetail.Columns)
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
        /// Handles the CellEndEdit event of the DgvCoopLayoutDetail control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="DataGridViewCellEventArgs"/> instance containing the event data.</param>
        private void DgvCoopLayoutDetail_CellEndEdit(object sender, DataGridViewCellEventArgs e)
        {
            if (e.ColumnIndex == 10)
            {
                if (this.dgvCoopLayoutDetail.CurrentCell.Value.ToString().Equals("1"))
                {
                    this.dgvCoopLayoutDetail.CurrentRow.DefaultCellStyle.BackColor = Color.LightGray;
                }
                else
                {
                    this.dgvCoopLayoutDetail.CurrentRow.DefaultCellStyle.BackColor = Color.White;
                }
            }
        }

        /// <summary>
        /// Handles the CellDoubleClick event of the DgvCoopLayoutDetail control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="DataGridViewCellEventArgs"/> instance containing the event data.</param>
        private void DgvCoopLayoutDetail_CellDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
            if ((e.ColumnIndex == 8) && e.RowIndex >= 0)
            {
                if (xmlEditDialog.ShowDialog(this, this.dgvCoopLayoutDetail.Rows[e.RowIndex].Cells[e.ColumnIndex].Value as string) == DialogResult.OK)
                {
                    this.controller.Model.CoopLayoutDetails[e.RowIndex].CoopSetting = xmlEditDialog.OutputXml;
                }
            }

            if ((e.ColumnIndex == 9) && e.RowIndex >= 0)
            {
                if (jsonEditDialog.ShowDialog(this, this.dgvCoopLayoutDetail.Rows[e.RowIndex].Cells[e.ColumnIndex].Value as string) == DialogResult.OK)
                {
                    this.controller.Model.CoopLayoutDetails[e.RowIndex].CoopExtSetting = jsonEditDialog.OutputJson;
                }
            }
        }

        /// <summary>
        /// Handles the ColumnHeaderMouseClick event of the DgvCoopLayoutDetail control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="DataGridViewCellMouseEventArgs"/> instance containing the event data.</param>
        private void DgvCoopLayoutDetail_ColumnHeaderMouseClick(object sender, DataGridViewCellMouseEventArgs e)
        {
            sortIndex = e.ColumnIndex;
            sortAscending = !sortAscending;
            this.controller.Sort(this.dgvCoopLayoutDetail.Columns[this.sortIndex].DataPropertyName, sortAscending);
        }

        /// <summary>
        /// Handles the FormClosing event of the CoopLayoutDetailSettingView control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="FormClosingEventArgs" /> instance containing the event data.</param>
        private void CoopLayoutDetailSettingView_FormClosing(object sender, FormClosingEventArgs e)
        {
            this.controller.ClearData();
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
            this.controller.LoadCoopLayoutDetails();
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
                case "CoopLayoutDetails":
                    {
                        UpdateCoopLayoutDetailView();
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
        /// Delegate UpdateCoopLayoutDetailViewCallback
        /// </summary>
        private delegate void UpdateCoopLayoutDetailViewCallback();
        /// <summary>
        /// Updates the coop layout detail view.
        /// </summary>
        private void UpdateCoopLayoutDetailView()
        {
            if (this.dgvCoopLayoutDetail.InvokeRequired)
            {
                UpdateCoopLayoutDetailViewCallback calback = new UpdateCoopLayoutDetailViewCallback(UpdateCoopLayoutDetailView);
                this.Invoke(calback);
            }
            else
            {
                this.dgvCoopLayoutDetail.DataSource = new List<MstCoopLayoutDetailEntity>();
                this.btnSave.Enabled = false;
                if (this.controller.Model.CoopLayoutDetails != null)
                {
                    this.btnSave.Enabled = true;
                    this.dgvCoopLayoutDetail.DataSource =  this.controller.Model.CoopLayoutDetails;

                    // 削除された行をグレーに表示される
                    for (int i = 0; i < this.controller.Model.CoopLayoutDetails.Count; i++)
                    {
                        if (this.controller.Model.CoopLayoutDetails[i].IsDel.Equals("1"))
                        {
                            this.dgvCoopLayoutDetail.Rows[i].DefaultCellStyle.BackColor = Color.LightGray;
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
