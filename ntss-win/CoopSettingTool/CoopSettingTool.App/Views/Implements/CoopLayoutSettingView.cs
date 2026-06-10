// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-13-2022
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-13-2022
// ***********************************************************************
// <copyright file="CoopLayoutSettingView.cs" company="">
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
using System.Drawing;
using System.Collections.Generic;
using System.ComponentModel;
using System.Windows.Forms;

namespace CoopSettingTool.App.Views
{
    /// <summary>
    /// Class CoopLayoutSettingView.
    /// Implements the <see cref="CoopSettingTool.App.Views.BaseView" />
    /// Implements the <see cref="CoopSettingTool.App.Views.ICoopLayoutSettingView" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Views.BaseView" />
    /// <seealso cref="CoopSettingTool.App.Views.ICoopLayoutSettingView" />
    public partial class CoopLayoutSettingView : BaseView, ICoopLayoutSettingView
    {
        private const string CoopSettingColumnName = "CoopSetting";
        private const string CoopExtSettingColumnName = "CoopExtSetting";
        private const string IsDelColumnName = "IsDel";

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
        ICoopLayoutSettingController controller;

        /// <summary>
        /// The coop cd select dialogue
        /// </summary>
        JsonEditDialog jsonEditDialog;

        /// <summary>
        /// The XML edit dialog
        /// </summary>
        XmlEditDialog xmlEditDialog;

        /// <summary>
        /// Initializes a new instance of the <see cref="CoopLayoutSettingView"/> class.
        /// </summary>
        /// <param name="model">The model.</param>
        public CoopLayoutSettingView(ICoopLayoutSettingModel model)
        {
            InitializeComponent(); 
            this.StartPosition = FormStartPosition.CenterParent;

            jsonEditDialog = new  JsonEditDialog();
            xmlEditDialog = new XmlEditDialog();

            controller = new CoopLayoutSettingController(this, model);
            this.RegisterEvent();
        }

        /// <summary>
        /// Registers the event.
        /// </summary>
        private void RegisterEvent()
        {
            this.Shown += new EventHandler(OnFormShown);
            this.FormClosing += new FormClosingEventHandler(CoopLayoutSettingView_FormClosing);
            this.controller.Model.PropertyChanged += new PropertyChangedEventHandler(Model_PropertyChanged);

            this.btnSave.Click += new EventHandler(BtnSave_Click);
            this.btnCancel.Click += new EventHandler(BtnCancel_Click);
            this.dgvCoopLayout.CellDoubleClick += new DataGridViewCellEventHandler(DgvOrderSetting_CellDoubleClick);
            this.dgvCoopLayout.ColumnHeaderMouseClick += new DataGridViewCellMouseEventHandler(DgvCoopLayout_ColumnHeaderMouseClick);
            this.dgvCoopLayout.CellEndEdit += new DataGridViewCellEventHandler(DgvCoopLayout_CellEndEdit);
            this.dgvCoopLayout.CellMouseClick += new DataGridViewCellMouseEventHandler(DgvCoopLayout_CellMouseClick);
        }

        /// <summary>
        /// Handles the CellMouseClick event of the DgvCoopLayout control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="DataGridViewCellMouseEventArgs"/> instance containing the event data.</param>
        private void DgvCoopLayout_CellMouseClick(object sender, DataGridViewCellMouseEventArgs e)
        {
            if (e.RowIndex == -1 && e.ColumnIndex == -1)
            {
                if (e.Button == MouseButtons.Right)
                {
                    foreach (DataGridViewColumn column in this.dgvCoopLayout.Columns)
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
        /// Handles the CellEndEdit event of the DgvCoopLayout control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="DataGridViewCellEventArgs"/> instance containing the event data.</param>
        private void DgvCoopLayout_CellEndEdit(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex >= 0
                && e.ColumnIndex >= 0
                && this.dgvCoopLayout.Columns[e.ColumnIndex].DataPropertyName == IsDelColumnName)
            {
                string value = this.dgvCoopLayout.Rows[e.RowIndex].Cells[e.ColumnIndex].Value as string;
                if ("1".Equals(value))
                {
                    this.dgvCoopLayout.Rows[e.RowIndex].DefaultCellStyle.BackColor = Color.LightGray;
                }
                else
                {
                    this.dgvCoopLayout.Rows[e.RowIndex].DefaultCellStyle.BackColor = Color.White;
                }
            }
        }

        /// <summary>
        /// Handles the ColumnHeaderMouseClick event of the DgvCoopLayout control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="DataGridViewCellMouseEventArgs"/> instance containing the event data.</param>
        private void DgvCoopLayout_ColumnHeaderMouseClick(object sender, DataGridViewCellMouseEventArgs e)
        {
            sortIndex = e.ColumnIndex;
            sortAscending = !sortAscending;
            this.controller.Sort(this.dgvCoopLayout.Columns[this.sortIndex].DataPropertyName, sortAscending);
        }

        /// <summary>
        /// Handles the FormClosing event of the CoopLayoutSettingView control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="FormClosingEventArgs"/> instance containing the event data.</param>
        private void CoopLayoutSettingView_FormClosing(object sender, FormClosingEventArgs e)
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
            if (e.RowIndex < 0 || e.ColumnIndex < 0)
            {
                return;
            }

            string dataPropertyName = this.dgvCoopLayout.Columns[e.ColumnIndex].DataPropertyName;
            if (dataPropertyName == CoopSettingColumnName)
            {
                if (xmlEditDialog.ShowDialog(this, this.dgvCoopLayout.Rows[e.RowIndex].Cells[e.ColumnIndex].Value as string) == DialogResult.OK)
                {
                    this.controller.Model.CoopLayouts[e.RowIndex].CoopSetting = xmlEditDialog.OutputXml;
                }
            }

            if (dataPropertyName == CoopExtSettingColumnName)
            {
                if (jsonEditDialog.ShowDialog(this, this.dgvCoopLayout.Rows[e.RowIndex].Cells[e.ColumnIndex].Value as string) == DialogResult.OK)
                {
                    this.controller.Model.CoopLayouts[e.RowIndex].CoopExtSetting = jsonEditDialog.OutputJson;
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
            this.controller.LoadCoopLayouts();
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
                case "CoopLayouts":
                    {
                        UpdateCoopLayoutView();
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
        /// Delegate UpdateCoopLayoutViewCallback
        /// </summary>
        private delegate void UpdateCoopLayoutViewCallback();
        /// <summary>
        /// Updates the coop layout view.
        /// </summary>
        private void UpdateCoopLayoutView()
        {
            if (this.dgvCoopLayout.InvokeRequired)
            {
                UpdateCoopLayoutViewCallback calback = new UpdateCoopLayoutViewCallback(UpdateCoopLayoutView);
                this.Invoke(calback);
            }
            else
            {
                this.dgvCoopLayout.DataSource = new List<MstCoopLayoutEntity>();
                this.btnSave.Enabled = false;
                if (this.controller.Model.CoopLayouts != null)
                {
                    this.btnSave.Enabled = true;
                    this.dgvCoopLayout.DataSource =  this.controller.Model.CoopLayouts;

                    // 削除された行をグレーに表示される
                    for (int i = 0; i < this.controller.Model.CoopLayouts.Count; i++)
                    {
                        if (this.controller.Model.CoopLayouts[i].IsDel.Equals("1"))
                        {
                            this.dgvCoopLayout.Rows[i].DefaultCellStyle.BackColor = Color.LightGray;
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
