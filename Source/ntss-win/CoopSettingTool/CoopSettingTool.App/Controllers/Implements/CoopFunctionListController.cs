// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-23-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-24-2021
// ***********************************************************************
// <copyright file="CoopFunctionListController.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.App.DI;
using CoopSettingTool.App.Models;
using CoopSettingTool.App.Properties;
using CoopSettingTool.App.Views;
using CoopSettingTool.Service;
using CoopSettingTool.Service.Models;
using System.Linq;
using System.Net;
using System.Threading;
using System.Threading.Tasks;

namespace CoopSettingTool.App.Controllers
{
    /// <summary>
    /// Class CoopFunctionListController.
    /// Implements the <see cref="CoopSettingTool.App.Controllers.BaseController{CoopSettingTool.App.Views.ICoopFunctionListView, CoopSettingTool.App.Models.ICoopFunctionListModel}" />
    /// Implements the <see cref="CoopSettingTool.App.Controllers.ICoopFunctionListController" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Controllers.BaseController{CoopSettingTool.App.Views.ICoopFunctionListView, CoopSettingTool.App.Models.ICoopFunctionListModel}" />
    /// <seealso cref="CoopSettingTool.App.Controllers.ICoopFunctionListController" />
    public class CoopFunctionListController : BaseController<ICoopFunctionListView, ICoopFunctionListModel>, ICoopFunctionListController
    {
        /// <summary>
        /// The MST coop facility service
        /// </summary>
        IMstCoopFacilityService mstCoopFacilityService;

        /// <summary>
        /// Initializes a new instance of the <see cref="CoopFunctionListController"/> class.
        /// </summary>
        /// <param name="view">The view.</param>
        /// <param name="model">The model.</param>
        public CoopFunctionListController(ICoopFunctionListView view, ICoopFunctionListModel model) : base(view, model)
        {
            mstCoopFacilityService = CompositionRoot.Resolve<IMstCoopFacilityService>();
        }

        /// <summary>
        /// Loads the coop facility.
        /// </summary>
        public async void LoadCoopFacility()
        {
            this.View.ShowLoading();

            bool result = await Task.Run(() =>
            {
                // リクェストを初期化する
                var param = new GetMstCoopFacilityRequest()
                {
                    FacilityCd = this.Model.Facility.FacilityCd,

                };

                // APIでMstCoopFacilityを取得する
                var res = mstCoopFacilityService.GetMstCoopFacility(param).Result;
                if (res != null && res.StatusCode == HttpStatusCode.OK)
                {
                    this.Model.CoopFacility = res.Data.Content.FirstOrDefault();
                    if (this.Model.CoopFacility == null)
                    {
                        this.View.ShowMessage(Resources.WARNING_COOP_NOT_INSTALLED, Resources.WARNING, Enums.MessageTypeEnum.WARNING);
                    }
                }
                else
                {
                    if (this.View.ShowAskMessage(Resources.ERROR_GET_DATA + "\r\n" + Resources.ASK_ABORT, Resources.ERROR, Enums.MessageTypeEnum.ERROR))
                    {
                        return false;
                    }
                }

                return true;
            });

            this.View.HideLoading();

            if (!result)
            {
                this.View.CloseView(System.Windows.Forms.DialogResult.Abort);
            }
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
