// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-13-2022
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-13-2022
// ***********************************************************************
// <copyright file="ICoopFacilitySettingController.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************

using CoopSettingTool.App.Models;
using CoopSettingTool.App.Views;

namespace CoopSettingTool.App.Controllers
{
    /// <summary>
    /// Interface ICoopFacilitySettingController
    /// Implements the <see cref="CoopSettingTool.App.Controllers.IBaseController{CoopSettingTool.App.Views.ICoopFacilitySettingView, CoopSettingTool.App.Models.ICoopFacilitySettingModel}" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Controllers.IBaseController{CoopSettingTool.App.Views.ICoopFacilitySettingView, CoopSettingTool.App.Models.ICoopFacilitySettingModel}" />
    public interface ICoopFacilitySettingController : IBaseController<ICoopFacilitySettingView, ICoopFacilitySettingModel>
    {
        /// <summary>
        /// Loads the coop facility.
        /// </summary>
        void LoadCoopFacility();

        /// <summary>
        /// Saves this instance.
        /// </summary>
        void Save();

        /// <summary>
        /// ファイルをインポートする
        /// </summary>
        /// <param name="filePath"></param>
        void Import(string filePath);
    }
}
