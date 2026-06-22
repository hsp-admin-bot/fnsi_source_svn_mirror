using CoopSettingTool.App.Controllers;
using CoopSettingTool.App.Models;
using System;
using System.ComponentModel;
using System.Windows.Forms;

namespace CoopSettingTool.App.Views
{
    public partial class ReleaseInfoView : BaseView, IReleaseInfoView
    {
        /// <summary>
        /// The controller
        /// </summary>
        IReleaseInfoController controller;

        public ReleaseInfoView(IReleaseInfoModel model)
        {
            InitializeComponent();
            this.StartPosition = FormStartPosition.CenterParent;

            controller = new ReleaseInfoController(this, model);
            this.RegisterEvent();
        }

        /// <summary>
        /// Registers the event.
        /// </summary>
        private void RegisterEvent()
        {
            this.Shown += new EventHandler(OnFormShown);
            this.controller.Model.PropertyChanged += new PropertyChangedEventHandler(Model_PropertyChanged);

            this.btnClose.Click += new EventHandler(BtnClose_Click);
        }

        /// <summary>
        /// Handles the Click event of the BtnClose control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void BtnClose_Click(object sender, EventArgs e)
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
                case "ReleaseInfos":
                    {
                        UpdateReleaseInfoView();
                        break;
                    }
            }
        }

        /// <summary>
        /// Delegate UpdateFacilitiesViewCallback
        /// </summary>
        private delegate void UpdateReleaseInfoViewCallback();
        /// <summary>
        /// Updates the facilities view.
        /// </summary>
        private void UpdateReleaseInfoView()
        {
            if (dgvReleaseInfo.InvokeRequired)
            {
                UpdateReleaseInfoViewCallback calback = new UpdateReleaseInfoViewCallback(UpdateReleaseInfoView);
                this.Invoke(calback);
            }
            else
            {
                dgvReleaseInfo.DataSource = this.controller.Model.ReleaseInfos;
                dgvReleaseInfo.Refresh();
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
            this.controller.LoadAllReleaseInfo();
        }
    }
}
