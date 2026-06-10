// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-23-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-28-2021
// ***********************************************************************
// <copyright file="ICoopFunctionListController.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.App.Models;
using CoopSettingTool.App.Views;

namespace CoopSettingTool.App.Controllers
{
    /// <summary>
    /// Interface ICoopFunctionListController
    /// Implements the <see cref="CoopSettingTool.App.Controllers.IBaseController{CoopSettingTool.App.Views.ICoopFunctionListView, CoopSettingTool.App.Models.ICoopFunctionListModel}" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Controllers.IBaseController{CoopSettingTool.App.Views.ICoopFunctionListView, CoopSettingTool.App.Models.ICoopFunctionListModel}" />
    public interface ICoopFacilitySettingController : IBaseController<ICoopFacilitySettingView, ICoopFacilitySettingModel>
    {
        /// <summary>
        /// Loads the coop facility.
        /// </summary>
        void LoadCoopFacility();

        //void LoadCoopLayoutsData();
    }
}
