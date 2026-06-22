// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-26-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-20-2021
// ***********************************************************************
// <copyright file="CoopFunctionSettingView.cs" company="">
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
using System.Drawing;
using System.Linq;
using System.Windows.Forms;

namespace CoopSettingTool.App.Views
{
    /// <summary>
    /// Class CoopFunctionSettingView.
    /// Implements the <see cref="CoopSettingTool.App.Views.BaseView" />
    /// Implements the <see cref="CoopSettingTool.App.Views.ICoopFunctionSettingView" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Views.BaseView" />
    /// <seealso cref="CoopSettingTool.App.Views.ICoopFunctionSettingView" />
    public partial class CoopFunctionSettingView : BaseView, ICoopFunctionSettingView
    {
        /// <summary>
        /// The controller
        /// </summary>
        ICoopFunctionSettingController controller;
        /// <summary>
        /// Initializes a new instance of the <see cref="CoopFunctionSettingView"/> class.
        /// </summary>
        /// <param name="model">The model.</param>
        public CoopFunctionSettingView(ICoopFunctionSettingModel model)
        {
            InitializeComponent();
            this.StartPosition = FormStartPosition.CenterParent;

            cbbProtocol.DataSource = Enum.GetValues(typeof(ReceiveProtocol));

            controller = new CoopFunctionSettingController(this, model);
            this.RegisterEvent();
        }

        /// <summary>
        /// Registers the event.
        /// </summary>
        private void RegisterEvent()
        {
            this.Shown += new EventHandler(OnFormShown);
            this.FormClosing += new FormClosingEventHandler(CoopFunctionSettingView_FormClosing);
            this.controller.Model.PropertyChanged += new PropertyChangedEventHandler(Model_PropertyChanged);
            this.cbIsUse.CheckedChanged += new EventHandler(CbIsUse_CheckedChanged);
            this.btnSave.Click += new EventHandler(BtnSave_Click);
            this.btnCancel.Click += new EventHandler(BtnCancel_Click);
            this.cbbProtocol.SelectedIndexChanged += new EventHandler(CbbProtocol_SelectedIndexChanged);
        }

        /// <summary>
        /// Handles the FormClosing event of the CoopFunctionSettingView control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="FormClosingEventArgs"/> instance containing the event data.</param>
        private void CoopFunctionSettingView_FormClosing(object sender, FormClosingEventArgs e)
        {
            this.controller.ClearData();
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
        /// Handles the SelectedIndexChanged event of the CbbProtocol control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void CbbProtocol_SelectedIndexChanged(object sender, EventArgs e)
        {
            if ("R".Equals(this.controller.Model.CoopFacility.CommonSetting.CoopOrdCds[this.controller.Model.CoopFunctionIndex].Direction))
            {
                string coopCd = this.controller.Model.CoopFacility.CommonSetting.CoopOrdCds[this.controller.Model.CoopFunctionIndex].CoopCd;
                string coopCdIndex = this.controller.Model.CoopFacility.CommonSetting.CoopOrdCds[this.controller.Model.CoopFunctionIndex].CoopCdIndex;

                if (ReceiveProtocol.socket.CompareTo(this.cbbProtocol.SelectedItem) == 0)
                {
                    List<SocketWatchInfo> watchInfos = new List<SocketWatchInfo>();

                    watchInfos.Add(new SocketWatchInfo() { DataType = coopCd, CoopCdIndex = coopCdIndex });
                    this.dgvSendProtocol.DataSource = watchInfos;
                }
                else if (ReceiveProtocol.file.CompareTo(this.cbbProtocol.SelectedItem) == 0)
                {
                    List<FileWatchInfo> watchInfos = new List<FileWatchInfo>();
                    watchInfos.Add(new FileWatchInfo() { DataType = coopCd, CoopCdIndex = coopCdIndex });
                    this.dgvSendProtocol.DataSource = watchInfos;
                }
                else if (ReceiveProtocol.headsocket.CompareTo(this.cbbProtocol.SelectedItem) == 0)
                {
                    List<HeadSocketWatchInfo> watchInfos = new List<HeadSocketWatchInfo>();
                    watchInfos.Add(new HeadSocketWatchInfo() { DataType = coopCd, CoopCdIndex = coopCdIndex });
                    this.dgvSendProtocol.DataSource = watchInfos;
                }
            }
            else
            {
                if (SendProtocol.socket.CompareTo(this.cbbProtocol.SelectedItem) == 0)
                {
                    List<SocketProtocolInfo> protocolInfos = new List<SocketProtocolInfo>();

                    protocolInfos.Add(new SocketProtocolInfo() { });
                    this.dgvSendProtocol.DataSource = protocolInfos;
                }
                else if (SendProtocol.file.CompareTo(this.cbbProtocol.SelectedItem) == 0)
                {
                    List<FileProtocolInfo> protocolInfos = new List<FileProtocolInfo>();
                    protocolInfos.Add(new FileProtocolInfo());
                    this.dgvSendProtocol.DataSource = protocolInfos;
                }
                else if (SendProtocol.filesocket.CompareTo(this.cbbProtocol.SelectedItem) == 0)
                {
                    List<FileSocketProtocolInfo> protocolInfos = new List<FileSocketProtocolInfo>();
                    protocolInfos.Add(new FileSocketProtocolInfo());
                    this.dgvSendProtocol.DataSource = protocolInfos;
                }
            }
        }

        /// <summary>
        /// Handles the Click event of the BtnSave control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void BtnSave_Click(object sender, EventArgs e)
        {
            if (this.dgvSendProtocol.DataSource != null)
            {
                if ("R".Equals(this.controller.Model.CoopFacility.CommonSetting.CoopOrdCds[this.controller.Model.CoopFunctionIndex].Direction))
                {

                    if (ReceiveProtocol.file.Equals(this.cbbProtocol.SelectedItem))
                    {
                        this.controller.Model.WatchInfo = (this.dgvSendProtocol.DataSource as List<FileWatchInfo>)[0];
                    }
                    else if (ReceiveProtocol.socket.Equals(this.cbbProtocol.SelectedItem))
                    {
                        this.controller.Model.WatchInfo = (this.dgvSendProtocol.DataSource as List<SocketWatchInfo>)[0];
                    }
                    else if (ReceiveProtocol.headsocket.Equals(this.cbbProtocol.SelectedItem))
                    {
                        this.controller.Model.WatchInfo = (this.dgvSendProtocol.DataSource as List<HeadSocketWatchInfo>)[0];
                    }
                }
                else if ("S".Equals(this.controller.Model.CoopFacility.CommonSetting.CoopOrdCds[this.controller.Model.CoopFunctionIndex].Direction))
                {
                    if (this.controller.Model.CoopDistributeList.Count > 0)
                    {
                        if (SendProtocol.file.Equals(this.cbbProtocol.SelectedItem))
                        {
                            this.controller.Model.SendProtocol = (this.dgvSendProtocol.DataSource as List<FileProtocolInfo>)[0];
                        }
                        else if (SendProtocol.socket.Equals(this.cbbProtocol.SelectedItem))
                        {
                            this.controller.Model.SendProtocol = (this.dgvSendProtocol.DataSource as List<SocketProtocolInfo>)[0];
                        }
                        else if (SendProtocol.filesocket.Equals(this.cbbProtocol.SelectedItem))
                        {
                            this.controller.Model.SendProtocol = (this.dgvSendProtocol.DataSource as List<FileSocketProtocolInfo>)[0];
                        }
                    }
                }
            }

            this.controller.Submit();
        }

        /// <summary>
        /// Handles the CheckedChanged event of the CbIsUse control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void CbIsUse_CheckedChanged(object sender, EventArgs e)
        {
            this.btnSave.Enabled = true;
            if(this.cbIsUse.Checked)
            {
               this.cbIsUse.BackColor = Color.Lime;
                this.controller.TurnOnCoopFunction();
                this.cbbProtocol.Enabled = true;
                this.dgvSendProtocol.Enabled = true;
            }
            else
            {
               this.cbIsUse.BackColor = Color.Gray;
                this.controller.TurnOffCoopFunction();
                this.cbbProtocol.Enabled = false;
                this.dgvSendProtocol.Enabled = false;
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
            // Update protocol
            if ("R".Equals(this.controller.Model.CoopFacility.CommonSetting.CoopOrdCds[this.controller.Model.CoopFunctionIndex].Direction))
            {
                string coopCd = this.controller.Model.CoopFacility.CommonSetting.CoopOrdCds[this.controller.Model.CoopFunctionIndex].CoopCd;
                string coopCdIndex = this.controller.Model.CoopFacility.CommonSetting.CoopOrdCds[this.controller.Model.CoopFunctionIndex].CoopCdIndex;
                var watchInfo = this.controller.Model.IfEgdeSetting.Receive.WatchInfos.FirstOrDefault(x => x.DataType == coopCd && x.CoopCdIndex == coopCdIndex);

                if (watchInfo != null)
                {
                    if (watchInfo.Protocol == ReceiveProtocol.file.ToString())
                    {
                        this.cbbProtocol.SelectedItem = ReceiveProtocol.file;
                        this.dgvSendProtocol.DataSource = new List<FileWatchInfo>() { watchInfo as FileWatchInfo };

                    }
                    else if (watchInfo.Protocol == ReceiveProtocol.socket.ToString())
                    {
                        this.cbbProtocol.SelectedItem = ReceiveProtocol.socket;
                        this.dgvSendProtocol.DataSource = new List<SocketWatchInfo>() { watchInfo as SocketWatchInfo };
                    }
                    else if (watchInfo.Protocol == ReceiveProtocol.headsocket.ToString())
                    {
                        this.cbbProtocol.SelectedItem = ReceiveProtocol.headsocket;
                        this.dgvSendProtocol.DataSource = new List<HeadSocketWatchInfo>() { watchInfo as HeadSocketWatchInfo };
                    }
                    else
                    { }
                }
                else
                {
                    this.dgvSendProtocol.DataSource = null;
                }
            }
            else if ("S".Equals(this.controller.Model.CoopFacility.CommonSetting.CoopOrdCds[this.controller.Model.CoopFunctionIndex].Direction))
            {
                this.controller.LoadCoopDistribute();
            }
            else
            {
            }


            // Update enable button
            if (this.controller.Model.CoopFacility.CommonSetting.CoopOrdCds[this.controller.Model.CoopFunctionIndex].Enable)
            {
                this.cbIsUse.BackColor = Color.Lime;
                this.cbIsUse.Checked = true;
                this.cbbProtocol.Enabled = true;
                this.dgvSendProtocol.Enabled = true;
            }
            else
            {               
                this.cbIsUse.BackColor = Color.Gray;
                this.cbIsUse.Checked = false;
                this.cbbProtocol.Enabled = false;
                this.dgvSendProtocol.Enabled = false;
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
                case "SendProtocol":
                    {
                        UpdateViewByProtocol();

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
        /// Delegate UpdateFacilityCallback
        /// </summary>
        private delegate void UpdateViewByProtocolCallback();
        /// <summary>
        /// Updates the view by facility.
        /// </summary>
        private void UpdateViewByProtocol()
        {
            if (this.InvokeRequired)
            {
                UpdateViewByProtocolCallback calback = new UpdateViewByProtocolCallback(UpdateViewByProtocol);
                this.Invoke(calback);
            }
            else
            {
                var protocolInfo = this.controller.Model.SendProtocol;
                if (protocolInfo != null)
                {
                    if (protocolInfo.Protocol == SendProtocol.file.ToString())
                    {
                        this.cbbProtocol.SelectedItem = SendProtocol.file;
                        this.dgvSendProtocol.DataSource = new List<FileProtocolInfo>() { protocolInfo as FileProtocolInfo };

                    }
                    else if (protocolInfo.Protocol == SendProtocol.socket.ToString())
                    {
                        this.cbbProtocol.SelectedItem = SendProtocol.socket;
                        this.dgvSendProtocol.DataSource = new List<SocketProtocolInfo>() { protocolInfo as SocketProtocolInfo };
                    }
                    else if (protocolInfo.Protocol == SendProtocol.filesocket.ToString())
                    {
                        this.cbbProtocol.SelectedItem = SendProtocol.filesocket;
                        this.dgvSendProtocol.DataSource = new List<FileSocketProtocolInfo>() { protocolInfo as FileSocketProtocolInfo };
                    }
                    else
                    { }
                }
                else
                {
                    this.dgvSendProtocol.DataSource = false;
                }
            }
        }


        /// <summary>
        /// Shows the dialog.
        /// </summary>
        /// <param name="parent">The parent.</param>
        /// <param name="coopFacilityEntity">The coop facility entity.</param>
        /// <param name="selectedCoopFunction">The selected coop function.</param>
        /// <returns>DialogResult.</returns>
        public DialogResult ShowDialog(IWin32Window parent, MstFacilityEntity facility, MstCoopFacilityEntity coopFacilityEntity, int selectedCoopFunction)
        {
            this.controller.Model.Facility = facility;
            this.controller.Model.CoopFacility = coopFacilityEntity;
            this.controller.Model.IfEgdeSetting = coopFacilityEntity.GetIfEdgeSetting();
            this.controller.Model.CoopFunctionIndex = selectedCoopFunction;

            if ("R".Equals(this.controller.Model.CoopFacility.CommonSetting.CoopOrdCds[this.controller.Model.CoopFunctionIndex].Direction))
            {
                cbbProtocol.DataSource = Enum.GetValues(typeof(ReceiveProtocol));
            }
            else
            {
                cbbProtocol.DataSource = Enum.GetValues(typeof(SendProtocol));
            }

            return this.ShowDialog(parent);
        }
    }
}
