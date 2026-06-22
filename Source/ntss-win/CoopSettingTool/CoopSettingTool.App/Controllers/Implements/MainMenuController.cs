// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-19-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-20-2021
// ***********************************************************************
// <copyright file="MainMenuController.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.App.DI;
using CoopSettingTool.App.Models;
using CoopSettingTool.App.Properties;
using CoopSettingTool.App.Views;
using CoopSettingTool.Service;
using CoopSettingTool.Service.Configuration;
using CoopSettingTool.Service.Models;
using System.Linq;
using System.Net;
using System.Threading.Tasks;

namespace CoopSettingTool.App.Controllers
{
    /// <summary>
    /// Class MainMenuController.
    /// Implements the <see cref="CoopSettingTool.App.Controllers.BaseController{CoopSettingTool.App.Views.IMainMenuView, CoopSettingTool.App.Models.IMainMenuModel}" />
    /// Implements the <see cref="CoopSettingTool.App.Controllers.IMainMenuController" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Controllers.BaseController{CoopSettingTool.App.Views.IMainMenuView, CoopSettingTool.App.Models.IMainMenuModel}" />
    /// <seealso cref="CoopSettingTool.App.Controllers.IMainMenuController" />
    public class MainMenuController : BaseController<IMainMenuView, IMainMenuModel>, IMainMenuController
    {
        /// <summary>
        /// The MST facility service
        /// </summary>
        private IMstFacilityService mstFacilityService;

        /// <summary>
        /// The MST coop facility service
        /// </summary>
        private IMstCoopFacilityService mstCoopFacilityService;

        /// <summary>
        /// Initializes a new instance of the <see cref="MainMenuController"/> class.
        /// </summary>
        /// <param name="view">The view.</param>
        /// <param name="model">The model.</param>
        public MainMenuController(IMainMenuView view, IMainMenuModel model) : base(view, model)
        {
            mstFacilityService = CompositionRoot.Resolve<IMstFacilityService>() as MstFacilityService;

            mstCoopFacilityService = CompositionRoot.Resolve<IMstCoopFacilityService>();
        }

        /// <summary>
        /// Loads the facility data.
        /// </summary>
        public async void LoadFacilityData()
        {
            this.View.ShowLoading();

            bool result = await Task.Run(() =>
            {
                if (this.Model.SelectedFacility == null && !ServerAccess.GetInstance().FacilityCd.Equals("nkknkk"))
                {
                    var getMstFacilityRes = mstFacilityService.GetMstFacility(ServerAccess.GetInstance().FacilityCd).Result;

                    if (getMstFacilityRes != null && getMstFacilityRes.StatusCode == HttpStatusCode.OK)
                    {
                        this.Model.SelectedFacility = getMstFacilityRes.Data;
                    }
                    else
                    {
                        if (this.View.ShowAskMessage(Resources.ERROR_GET_DATA + "\r\n" + Resources.ASK_ABORT, Resources.ERROR, Enums.MessageTypeEnum.ERROR))
                        {
                            return false;
                        }
                    }
                }

                if (this.Model.SelectedFacility != null)
                {
                    bool isInstalled = false;
                    var param = new GetMstCoopFacilityRequest()
                    {
                        FacilityCd = this.Model.SelectedFacility.FacilityCd,
                    };
                    var getCoopFacilityRes = mstCoopFacilityService.GetMstCoopFacility(param).Result;
                    if (getCoopFacilityRes != null && getCoopFacilityRes.StatusCode == HttpStatusCode.OK)
                    {
                        var coopFacility = getCoopFacilityRes.Data.Content.FirstOrDefault();
                        if (coopFacility != null)
                        {
                            isInstalled = true;
                        }
                    }
                    else
                    {
                        if (this.View.ShowAskMessage(Resources.ERROR_GET_DATA + "\r\n" + Resources.ASK_ABORT, Resources.ERROR, Enums.MessageTypeEnum.ERROR))
                        {
                            return false;
                        }
                    }
                    this.Model.IsInstalled = isInstalled;
                }

                return true;
            });

            this.View.HideLoading();

            if(!result)
            {
                this.View.CloseView(System.Windows.Forms.DialogResult.Abort);
            }
        }

        /// <summary>
        /// Shows the view.
        /// </summary>
        public void ShowView()
        {
            this.View.ShowView();
        }

        /// <summary>
        /// Shows the help function si.
        /// </summary>
        public void ShowManual()
        {
            System.Diagnostics.Process.Start(Constant.MANUAL);
        }

        /// <summary>
        /// Clears the data.
        /// </summary>
        public override void ClearData()
        {
            this.Model.ClearData();
        }
    }
}
