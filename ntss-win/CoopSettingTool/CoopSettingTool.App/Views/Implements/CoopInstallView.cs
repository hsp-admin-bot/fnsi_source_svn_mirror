// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-20-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-23-2021
// ***********************************************************************
// <copyright file="CoopInstallView.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.App.Controllers;
using CoopSettingTool.App.Dialogues;
using CoopSettingTool.App.Models;
using CoopSettingTool.Service.Models;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace CoopSettingTool.App.Views
{
    /// <summary>
    /// Class CoopInstallView.
    /// Implements the <see cref="CoopSettingTool.App.Views.BaseView" />
    /// Implements the <see cref="CoopSettingTool.App.Views.ICoopInstallView" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Views.BaseView" />
    /// <seealso cref="CoopSettingTool.App.Views.ICoopInstallView" />
    public partial class CoopInstallView : BaseView, ICoopInstallView
    {
        /// <summary>
        /// The controller
        /// </summary>
        ICoopInstallController controller;

        /// <summary>
        /// Initializes a new instance of the <see cref="CoopInstallView"/> class.
        /// </summary>
        /// <param name="model">The model.</param>
        public CoopInstallView(ICoopInstallModel model)
        {
            InitializeComponent();
            this.StartPosition = FormStartPosition.CenterParent;

            controller = new CoopInstallController(this, model);
            this.RegisterEvent();
        }

        /// <summary>
        /// Registers the event.
        /// </summary>
        private void RegisterEvent()
        {
            this.Shown += new EventHandler(OnFormShown);
            this.FormClosing += new FormClosingEventHandler(CoopInstallView_FormClosing);
            this.controller.Model.PropertyChanged += new PropertyChangedEventHandler(Model_PropertyChanged);

            this.btnCancel.Click += new EventHandler(BtnCancel_Click);
            this.btnSave.Click += new EventHandler(BtnSave_Click);

            this.clbCoopArtifact.SelectedIndexChanged += new EventHandler(ClbCoopArtifact_SelectedIndexChanged);

            this.cbShowFullCoop.CheckStateChanged += CbShowFullCoop_CheckStateChanged;
        }

        /// <summary>
        /// Handles the FormClosing event of the CoopInstallView control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="FormClosingEventArgs"/> instance containing the event data.</param>
        private void CoopInstallView_FormClosing(object sender, FormClosingEventArgs e)
        {
            this.controller.ClearData();
        }

        /// <summary>
        /// Handles the CheckStateChanged event of the CbShowFullCoop control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void CbShowFullCoop_CheckStateChanged(object sender, EventArgs e)
        {
            this.controller.LoadCoopFacilityArtifactsData(this.cbShowFullCoop.Checked);
        }

        /// <summary>
        /// Handles the SelectedIndexChanged event of the ClbCoopArtifact control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void ClbCoopArtifact_SelectedIndexChanged(object sender, EventArgs e)
        {
            List<int> temp = new List<int>();

            foreach(var item in  this.clbCoopArtifact.CheckedIndices)
            {
                temp.Add((int)item);
            }
            this.controller.Model.SelectedArtifactIndices = temp; 

            if(temp.Count > 0)
            {
                this.btnSave.Enabled = true;

            }
            else
            {
                this.btnSave.Enabled = false;
            }
        }

        /// <summary>
        /// Handles the Click event of the BtnSave control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void BtnSave_Click(object sender, EventArgs e)
        {
            this.controller.SaveData();
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
        /// Handles the PropertyChanged event of the Model control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="PropertyChangedEventArgs"/> instance containing the event data.</param>
        private void Model_PropertyChanged(object sender, PropertyChangedEventArgs e)
        {
            switch (e.PropertyName)
            {
                case "CoopFacilityArtifacts":
                    {
                        UpdateCoopFacilityArtifactsView();

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
        /// Delegate UpdateCoopFacilityArtifactsViewCallback
        /// </summary>
        private delegate void UpdateCoopFacilityArtifactsViewCallback();
        /// <summary>
        /// Updates the coop facility artifacts view.
        /// </summary>
        private void UpdateCoopFacilityArtifactsView()
        {
            if (this.clbCoopArtifact.InvokeRequired)
            {
                UpdateCoopFacilityArtifactsViewCallback calback = new UpdateCoopFacilityArtifactsViewCallback(UpdateCoopFacilityArtifactsView);
                this.Invoke(calback);
            }
            else
            {
                List<string> lstCoopFacilityArtifactView = new List<string>();

                if (this.controller.Model.CoopFacilityArtifacts != null)
                {
                    foreach (var item in this.controller.Model.CoopFacilityArtifacts)
                    {
                        lstCoopFacilityArtifactView.Add(item.Description);
                    }
                }

                this.clbCoopArtifact.DataSource = lstCoopFacilityArtifactView;
                for (int i = 0; i < this.clbCoopArtifact.Items.Count; i++)
                {
                    this.clbCoopArtifact.SetItemCheckState(i, CheckState.Unchecked);
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
            this.controller.LoadCoopFacilityArtifactsData(this.cbShowFullCoop.Checked);
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
