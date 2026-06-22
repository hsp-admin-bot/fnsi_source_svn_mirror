// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-19-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-23-2021
// ***********************************************************************
// <copyright file="ISelectFacilityController.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.App.Models;
using CoopSettingTool.App.Views;

namespace CoopSettingTool.App.Controllers
{
    /// <summary>
    /// Interface ISelectFacilityController
    /// Implements the <see cref="CoopSettingTool.App.Controllers.IBaseController{CoopSettingTool.App.Views.ISelectFacilityView, CoopSettingTool.App.Models.ISelectFacilityModel}" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Controllers.IBaseController{CoopSettingTool.App.Views.ISelectFacilityView, CoopSettingTool.App.Models.ISelectFacilityModel}" />
    public interface ISelectFacilityController : IBaseController<ISelectFacilityView, ISelectFacilityModel>
    {
        /// <summary>
        /// Loads all facilities data.
        /// </summary>
        void LoadAllFacilitiesData();
    }
}
