// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-19-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-27-2021
// ***********************************************************************
// <copyright file="MainMenuView.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.App.Controllers;
using CoopSettingTool.App.DI;
using CoopSettingTool.App.Models;
using CoopSettingTool.Service;
using System;
using System.ComponentModel;
using System.Windows.Forms;

namespace CoopSettingTool.App.Views
{
    /// <summary>
    /// Class MainMenuView.
    /// Implements the <see cref="CoopSettingTool.App.Views.BaseView" />
    /// Implements the <see cref="CoopSettingTool.App.Views.IMainMenuView" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Views.BaseView" />
    /// <seealso cref="CoopSettingTool.App.Views.IMainMenuView" />
    public partial class MainMenuView : BaseView, IMainMenuView
    {
        /// <summary>
        /// The select facility view
        /// </summary>
        private ISelectFacilityView selectFacilityView;

        /// <summary>
        /// The coop install view
        /// </summary>
        private ICoopInstallView coopInstallView;

        ///// <summary>
        ///// The coop function ListView
        ///// </summary>
        //private ICoopFunctionListView coopFunctionListView;

        /// <summary>
        /// The coop facility setting view
        /// </summary>
        private ICoopFacilitySettingView coopFacilitySettingView;

        /// <summary>
        /// The coop distribute setting view
        /// </summary>
        private ICoopDistributeSettingView coopDistributeSettingView;

        /// <summary>
        /// The coop layout setting view
        /// </summary>
        private ICoopLayoutSettingView coopLayoutSettingView;

        /// <summary>
        /// The coop layout detail setting view
        /// </summary>
        private ICoopLayoutDetailSettingView coopLayoutDetailSettingView;

        /// <summary>
        /// The order number setting view
        /// </summary>
        private IOrderNumberSettingView orderNumberSettingView;

        /// <summary>
        /// If edge setting view
        /// </summary>
        private IIfEdgeSettingView ifEdgeSettingView;

        /// <summary>
        /// The coop setting view
        /// </summary>
        private ICoopSettingView coopSettingView;

        /// <summary>
        /// The release information view
        /// </summary>
        private IReleaseInfoView releaseInfoView;

        /// <summary>
        /// The controller
        /// </summary>
        private IMainMenuController controller;

        /// <summary>
        /// Initializes a new instance of the <see cref="MainMenuView"/> class.
        /// </summary>
        /// <param name="model">The model.</param>
        public MainMenuView(IMainMenuModel model)
        {
            InitializeComponent();

            this.StartPosition = FormStartPosition.CenterScreen;

            // 施設選択画面
            selectFacilityView = CompositionRoot.Resolve<ISelectFacilityView>();

            // 連携インストール画面
            coopInstallView = CompositionRoot.Resolve<ICoopInstallView>();

            //// 連携一覧
            //coopFunctionListView = CompositionRoot.Resolve<ICoopFunctionListView>();

            // 連携マスタ設定画面
            coopFacilitySettingView = CompositionRoot.Resolve<ICoopFacilitySettingView>();

            // 連携配信設定マスタ画面
            coopDistributeSettingView = CompositionRoot.Resolve<ICoopDistributeSettingView>();

            // 連携電文レイアウトマスタ画面
            coopLayoutSettingView = CompositionRoot.Resolve<ICoopLayoutSettingView>();

            // 変換レイアウト詳細マスタ画面
            coopLayoutDetailSettingView = CompositionRoot.Resolve<ICoopLayoutDetailSettingView>();

            // オーダ番号設定画面
            orderNumberSettingView = CompositionRoot.Resolve<IOrderNumberSettingView>();

            // エッジ設定画面
            ifEdgeSettingView = CompositionRoot.Resolve<IIfEdgeSettingView>();

            // 連携設定画面
            coopSettingView = CompositionRoot.Resolve<ICoopSettingView>();

            // リリース情報画面
            releaseInfoView = CompositionRoot.Resolve<IReleaseInfoView>();

            IMainMenuController cont = new MainMenuController(this, model);
            this.SetController(cont);
            this.RegisterEvent();
        }

        /// <summary>
        /// Registers the event.
        /// </summary>
        private void RegisterEvent()
        {
            this.Shown += new EventHandler(OnFormShown);
            this.FormClosing += new FormClosingEventHandler(MainMenuView_FormClosing);
            this.controller.Model.PropertyChanged += Model_PropertyChanged;

            this.btnChangeFacility.Click += new EventHandler(BtnChangeFacility_Click);
            this.btnCoopInstall.Click += new EventHandler(BtnCoopInstall_Click);
            this.btnCoopFacility.Click += new EventHandler(BtnCoopFacility_Click);
            this.btnCoopDistribute.Click += new EventHandler(BtnCoopDistribute_Click);
            this.btnCoopLayout.Click += new EventHandler(BtnCoopLayout_Click);
            this.btnCoopLayoutDetail.Click += new EventHandler(BtnCoopLayoutDetail_Click);
            this.btnOrderNumber.Click += new EventHandler(BtnOrderNumber_Click);
            this.btnIfEdge.Click += new EventHandler(BtnIfEdge_Click);
            this.btnCoopSetting.Click += new EventHandler(BtnCoopSetting_Click);
            this.btnLogOut.Click += new EventHandler(BtnLogOut_Click);
            this.btnHelp.Click += new EventHandler(BtnHelp_Click);
        }

        /// <summary>
        /// Handles the Click event of the BtnCoopLayoutDetail control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void BtnCoopLayoutDetail_Click(object sender, EventArgs e)
        {
            this.HideView();
            if (this.coopLayoutDetailSettingView.ShowDialog(this, this.controller.Model.SelectedFacility) == DialogResult.Abort)
            {
                this.CloseView(DialogResult.Abort);
            }
            else
            {
                this.ShowView();
            }
        }

        /// <summary>
        /// Handles the Click event of the BtnCoopLayout control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void BtnCoopLayout_Click(object sender, EventArgs e)
        {
            this.HideView();
            if (this.coopLayoutSettingView.ShowDialog(this, this.controller.Model.SelectedFacility) == DialogResult.Abort)
            {
                this.CloseView(DialogResult.Abort);
            }
            else
            {
                this.ShowView();
            }
        }

        /// <summary>
        /// Handles the Click event of the BtnCoopDistribute control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void BtnCoopDistribute_Click(object sender, EventArgs e)
        {
            this.HideView();
            if (this.coopDistributeSettingView.ShowDialog(this, this.controller.Model.SelectedFacility) == DialogResult.Abort)
            {
                this.CloseView(DialogResult.Abort);
            }
            else
            {
                this.ShowView();
            }
        }

        /// <summary>
        /// Handles the FormClosing event of the MainMenuView control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="FormClosingEventArgs"/> instance containing the event data.</param>
        private void MainMenuView_FormClosing(object sender, FormClosingEventArgs e)
        {
            this.controller.ClearData();
        }

        /// <summary>
        /// Handles the ItemClicked event of the Release control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void Release_ItemClicked(object sender, EventArgs e)
        {
            this.HideView();
            if (this.releaseInfoView.ShowDialog(this) == DialogResult.Abort)
            {
                this.CloseView(DialogResult.Abort);
            }
            else
            {
                this.ShowView();
            }
        }

        /// <summary>
        /// Handles the Click event of the BtnHelp control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void BtnHelp_Click(object sender, EventArgs e)
        {
            this.controller.ShowManual();
        }

        /// <summary>
        /// Handles the Click event of the BtnLogOut control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        /// <exception cref="NotImplementedException"></exception>
        private void BtnLogOut_Click(object sender, EventArgs e)
        {
            this.CloseView(System.Windows.Forms.DialogResult.Cancel);
        }

        /// <summary>
        /// Handles the Click event of the BtnCoopSetting control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void BtnCoopSetting_Click(object sender, EventArgs e)
        {
            this.HideView();
            if(this.coopSettingView.ShowDialog(this, this.controller.Model.SelectedFacility) == DialogResult.Abort)
            {
                this.CloseView(DialogResult.Abort);
            }
            else
            {
                this.ShowView();
            }
        }

        /// <summary>
        /// Handles the Click event of the BtnIfEdge control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void BtnIfEdge_Click(object sender, EventArgs e)
        {
            this.HideView();
            if (this.ifEdgeSettingView.ShowDialog(this, this.controller.Model.SelectedFacility) == DialogResult.Abort)
            {
                this.CloseView(DialogResult.Abort);
            }
            else
            {
                this.ShowView();
            }
        }

        /// <summary>
        /// Handles the Click event of the BtnOrderNumber control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void BtnOrderNumber_Click(object sender, EventArgs e)
        {
            this.HideView();
            if (this.orderNumberSettingView.ShowDialog(this, this.controller.Model.SelectedFacility) == DialogResult.Abort)
            {
                this.CloseView(DialogResult.Abort);
            }
            else
            {
                this.ShowView();
            }
        }

        /// <summary>
        /// Handles the Click event of the BtnCoopOnOff control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void BtnCoopFacility_Click(object sender, EventArgs e)
        {
            this.HideView();
            if (this.coopFacilitySettingView.ShowDialog(this, this.controller.Model.SelectedFacility) == DialogResult.Abort)
            {
                this.CloseView(DialogResult.Abort);
            }
            else
            {
                this.ShowView();
            }
        }

        /// <summary>
        /// Handles the Click event of the BtnCoopInstall control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void BtnCoopInstall_Click(object sender, EventArgs e)
        {
            this.HideView();
            if (this.coopInstallView.ShowDialog(this, this.controller.Model.SelectedFacility) == DialogResult.Abort)
            {
                this.CloseView(DialogResult.Abort);
            }
            else
            {
                this.ShowView();

                this.controller.LoadFacilityData();
            }
        }

        /// <summary>
        /// Handles the Click event of the BtnChangeFacility control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void BtnChangeFacility_Click(object sender, EventArgs e)
        {
            this.HideView();
            var rs = this.selectFacilityView.ShowDialog(this);
            if (rs == DialogResult.OK)
            {
                this.controller.Model.SelectedFacility = this.selectFacilityView.SelectedFacility;

                this.ShowView();

                this.controller.LoadFacilityData();
            }
            else if (rs == DialogResult.Abort)
            {
                this.CloseView(DialogResult.Abort);
            }
            else
            {
                this.ShowView();
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
                case "SelectedFacility":
                    {
                        UpdateViewByFacility();
                        
                        break;
                    }
                case "IsInstalled":
                    {
                        UpdateViewByIsInstalled();
                        
                        break;
                    }
            }
        }

        /// <summary>
        /// Delegate UpdateViewByIsInstalledCallback
        /// </summary>
        private delegate void UpdateViewByIsInstalledCallback();
        /// <summary>
        /// Updates the view by is installed.
        /// </summary>
        private void UpdateViewByIsInstalled()
        {
            if (this.InvokeRequired)
            {
                UpdateViewByIsInstalledCallback calback = new UpdateViewByIsInstalledCallback(UpdateViewByIsInstalled);
                this.Invoke(calback);
            }
            else
            {
                if (this.controller.Model.IsInstalled)
                {
                    MakeSettingVisible();
                }
                else
                {
                    MakeSettingInvisible();
                }
            }
        }

        /// <summary>
        /// Makes the setting visible.
        /// </summary>
        private void MakeSettingVisible()
        {
            this.btnCoopFacility.Visible = true;
            this.btnCoopLayout.Visible = true;
            this.btnCoopLayoutDetail.Visible = true;
            this.btnCoopDistribute.Visible = true;
            this.btnCoopSetting.Visible = true;
            this.btnIfEdge.Visible = true;
            this.btnOrderNumber.Visible = true;
        }

        /// <summary>
        /// Makes the setting invisible.
        /// </summary>
        private void MakeSettingInvisible()
        {
            this.btnCoopFacility.Visible = false;
            this.btnCoopLayout.Visible = false;
            this.btnCoopLayoutDetail.Visible = false;
            this.btnCoopDistribute.Visible = false;
            this.btnCoopSetting.Visible = false;
            this.btnIfEdge.Visible = false;
            this.btnOrderNumber.Visible = false;
        }

        /// <summary>
        /// Delegate UpdateFacilityCallback
        /// </summary>
        private delegate void UpdateFacilityCallback();
        /// <summary>
        /// Updates the view by facility.
        /// </summary>
        private void UpdateViewByFacility()
        {
            if (this.InvokeRequired)
            {
                UpdateFacilityCallback calback = new UpdateFacilityCallback(UpdateViewByFacility);
                this.Invoke(calback);
            }
            else
            {
                if (this.controller.Model.SelectedFacility != null)
                {
                    this.btnCoopInstall.Visible = true;
                    this.lbFacName.Text = this.controller.Model.SelectedFacility.DisplayMember;
                }
                else
                {
                    this.btnCoopInstall.Visible = false;
                    this.lbFacName.Text = string.Empty;
                }
            }
        }

        /// <summary>
        /// Handles the <see cref="E:FormShown" /> event.
        /// </summary>
        /// <param name="sender">The sender.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private  void OnFormShown(object sender, EventArgs e)
        {
             LoadView();
        }

        /// <summary>
        /// Loads the view.
        /// </summary>
        private void LoadView()
        {
            if (ServerAccess.GetInstance().FacilityCd == "nkknkk")
            {
                this.btnChangeFacility.Visible = true;
            }
            else
            {
                this.btnChangeFacility.Visible = false;
            }

            this.controller.LoadFacilityData();
        }

        /// <summary>
        /// Sets the controller.
        /// </summary>
        /// <param name="controller">The controller.</param>
        public void SetController(IMainMenuController controller)
        {
            this.controller = controller;
        }
    }
}
