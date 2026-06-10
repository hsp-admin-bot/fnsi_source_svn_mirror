// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-19-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-23-2021
// ***********************************************************************
// <copyright file="SelectFacilityController.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.App.DI;
using CoopSettingTool.App.Models;
using CoopSettingTool.App.Properties;
using CoopSettingTool.App.Views;
using CoopSettingTool.Service;
using System.Net;
using System.Threading.Tasks;

namespace CoopSettingTool.App.Controllers
{
    /// <summary>
    /// Class SelectFacilityController.
    /// Implements the <see cref="CoopSettingTool.App.Controllers.BaseController{CoopSettingTool.App.Views.ISelectFacilityView, CoopSettingTool.App.Models.ISelectFacilityModel}" />
    /// Implements the <see cref="CoopSettingTool.App.Controllers.ISelectFacilityController" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Controllers.BaseController{CoopSettingTool.App.Views.ISelectFacilityView, CoopSettingTool.App.Models.ISelectFacilityModel}" />
    /// <seealso cref="CoopSettingTool.App.Controllers.ISelectFacilityController" />
    public class SelectFacilityController : BaseController<ISelectFacilityView, ISelectFacilityModel>, ISelectFacilityController
    {
        /// <summary>
        /// The MST facility service
        /// </summary>
        IMstFacilityService mstFacilityService;

        /// <summary>
        /// Initializes a new instance of the <see cref="SelectFacilityController"/> class.
        /// </summary>
        /// <param name="view">The view.</param>
        /// <param name="model">The model.</param>
        public SelectFacilityController(ISelectFacilityView view, ISelectFacilityModel model) : base(view, model)
        {
            mstFacilityService = CompositionRoot.Resolve<IMstFacilityService>();
        }

        /// <summary>
        /// Loads all facilities data.
        /// </summary>
        public async void LoadAllFacilitiesData()
        {
            this.View.ShowLoading();

            bool result = await Task.Run(() =>
            {
                var res = mstFacilityService.GetAllMstFacility().Result;

                if (res != null && res.StatusCode == HttpStatusCode.OK)
                {
                    this.Model.Facilities = res.Data;
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
