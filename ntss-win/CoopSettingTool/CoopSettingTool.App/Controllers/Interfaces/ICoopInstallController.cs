// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-20-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-21-2021
// ***********************************************************************
// <copyright file="ICoopInstallController.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.App.Models;
using CoopSettingTool.App.Views;

namespace CoopSettingTool.App.Controllers
{
    /// <summary>
    /// Interface ICoopInstallController
    /// Implements the <see cref="CoopSettingTool.App.Controllers.IBaseController{CoopSettingTool.App.Views.ICoopInstallView, CoopSettingTool.App.Models.ICoopInstallModel}" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Controllers.IBaseController{CoopSettingTool.App.Views.ICoopInstallView, CoopSettingTool.App.Models.ICoopInstallModel}" />
    public interface ICoopInstallController : IBaseController<ICoopInstallView, ICoopInstallModel>
    {
        /// <summary>
        /// Loads the coop facility artifacts data.
        /// </summary>
        void LoadCoopFacilityArtifactsData(bool showOtherCopFac);
        /// <summary>
        /// Saves the data.
        /// </summary>
        void SaveData();
    }
}
