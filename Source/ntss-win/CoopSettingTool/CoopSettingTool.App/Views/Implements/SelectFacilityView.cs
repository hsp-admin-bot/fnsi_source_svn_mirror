// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-19-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-23-2021
// ***********************************************************************
// <copyright file="SelectFacilityView.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************

using CoopSettingTool.App.Controllers;
using CoopSettingTool.App.Models;
using CoopSettingTool.Service.Enums;
using CoopSettingTool.Service.Models;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Windows.Forms;
using System.Linq.Dynamic;

namespace CoopSettingTool.App.Views
{
    /// <summary>
    /// Class SelectFacilityView.
    /// Implements the <see cref="CoopSettingTool.App.Views.BaseView" />
    /// Implements the <see cref="CoopSettingTool.App.Views.ISelectFacilityView" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Views.BaseView" />
    /// <seealso cref="CoopSettingTool.App.Views.ISelectFacilityView" />
    public partial class SelectFacilityView : BaseView, ISelectFacilityView
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
        /// The controller
        /// </summary>
        ISelectFacilityController controller;

        /// <summary>
        /// Gets the selected facility.
        /// </summary>
        /// <value>The selected facility.</value>
        public MstFacilityEntity SelectedFacility
        {
            get
            {
                return this.controller.Model.SelectedFacility;
            }
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="SelectFacilityView"/> class.
        /// </summary>
        /// <param name="model">The model.</param>
        public SelectFacilityView(ISelectFacilityModel model)
        {
            InitializeComponent();
            this.StartPosition = FormStartPosition.CenterParent;

            this.cbbPrefecture.DataSource = Enum.GetValues(typeof(Prefecture));

            ISelectFacilityController cont = new SelectFacilityController(this, model);
            this.SetController(cont);
            this.RegisterEvent();
        }

        /// <summary>
        /// Registers the event.
        /// </summary>
        private void RegisterEvent()
        {
            this.Shown += new EventHandler(OnFormShown);
            this.controller.Model.PropertyChanged += new PropertyChangedEventHandler(Model_PropertyChanged);

            this.btnOk.Click += new EventHandler(BtnOk_Click);
            this.btnCancel.Click += new EventHandler(BtnCancel_Click);
            this.btnFilter.Click += new EventHandler(BtnFilter_Click);
            this.dgvFacility.SelectionChanged += new EventHandler(DgvFacility_SelectionChanged);
            this.dgvFacility.ColumnHeaderMouseClick += new DataGridViewCellMouseEventHandler(DgvFacility_ColumnHeaderMouseClick);
            this.txtFilter.KeyDown += new KeyEventHandler(TxtFilter_KeyDown);
            this.cbbPrefecture.SelectedIndexChanged += new EventHandler(CbbPrefecture_SelectedIndexChanged);
        }

        /// <summary>
        /// Handles the ColumnHeaderMouseClick event of the DgvFacility control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="DataGridViewCellMouseEventArgs"/> instance containing the event data.</param>
        /// <exception cref="NotImplementedException"></exception>
        private void DgvFacility_ColumnHeaderMouseClick(object sender, DataGridViewCellMouseEventArgs e)
        {
            sortIndex = e.ColumnIndex;
            sortAscending = !sortAscending;
            UpdateFacilitiesView();
        }

        private void CbbPrefecture_SelectedIndexChanged(object sender, EventArgs e)
        {
            BtnFilter_Click(null, null);
        }

        /// <summary>
        /// TxtFilter_KeyDown
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void TxtFilter_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                BtnFilter_Click(null, null);
            }
        }

        /// <summary>
        /// Handles the Click event of the BtnFilter control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void BtnFilter_Click(object sender, EventArgs e)
        {
            searchPattern = txtFilter.Text;
            UpdateFacilitiesView();
        }

        /// <summary>
        /// Handles the SelectionChanged event of the DgvFacility control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void DgvFacility_SelectionChanged(object sender, EventArgs e)
        {
            if (dgvFacility.SelectedRows.Count == 1)
            {
                this.controller.Model.SelectedFacility = dgvFacility.SelectedRows[0].DataBoundItem as MstFacilityEntity;
                this.btnOk.Enabled = true;
            }
            else
            {
                this.btnOk.Enabled = false;
            }
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
        /// Handles the Click event of the BtnOk control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void BtnOk_Click(object sender, EventArgs e)
        {
            this.CloseView(System.Windows.Forms.DialogResult.OK);
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
                case "Facilities":
                    {
                        if (this.controller.Model.Facilities != null)
                        {
                            UpdateFacilitiesView();
                        }
                        break;
                    }
            }
        }

        /// <summary>
        /// Delegate UpdateFacilitiesViewCallback
        /// </summary>
        private delegate void UpdateFacilitiesViewCallback();
        /// <summary>
        /// Updates the facilities view.
        /// </summary>
        private void UpdateFacilitiesView()
        {
            if (dgvFacility.InvokeRequired)
            {
                UpdateFacilitiesViewCallback calback = new UpdateFacilitiesViewCallback(UpdateFacilitiesView);
                this.Invoke(calback);
            }
            else
            {
                dgvFacility.DataSource = new List<MstFacilityEntity>();

                if (this.controller.Model.Facilities != null)
                {
                    List<MstFacilityEntity> dataList = this.controller.Model.Facilities;

                    // 都道府県で探す
                    if (this.cbbPrefecture.SelectedIndex != 0)
                    {
                        dataList = dataList.FindAll(x => !string.IsNullOrEmpty(x.PrefecturesCd) && x.PrefecturesCd.Equals(this.cbbPrefecture.SelectedIndex.ToString().PadLeft(2, '0')));
                    }

                    // 検索パターンを適用する
                    if (!string.IsNullOrEmpty(this.searchPattern))
                    {
                        dataList = dataList.FindAll(x => x.FacilityCd.Contains(this.searchPattern) 
                        || (!string.IsNullOrEmpty(x.FacilityName) && x.FacilityName.Contains(this.searchPattern))
                        || (!string.IsNullOrEmpty(x.DepartmentCd) && x.DepartmentCd.Contains(this.searchPattern)));
                    }

                    // ソートする
                    if (sortAscending)
                        dataList = dataList.OrderBy(this.dgvFacility.Columns[this.sortIndex].DataPropertyName).ToList();
                    else
                        dataList = dataList.OrderBy(this.dgvFacility.Columns[this.sortIndex].DataPropertyName).Reverse().ToList();

                    dgvFacility.DataSource = dataList;
                }

                foreach (DataGridViewColumn column in dgvFacility.Columns)
                {
                    column.SortMode = DataGridViewColumnSortMode.Automatic;
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
            this.controller.LoadAllFacilitiesData();

            //this.ShowLoanding();
            //await Task.Run(() => this.controller.LoadAllFacilitiesData());
            //this.HideLoaing();
        }

        /// <summary>
        /// Sets the controller.
        /// </summary>
        /// <param name="controller">The controller.</param>
        private void SetController(ISelectFacilityController controller)
        {
            this.controller = controller;
        }
    }
}
