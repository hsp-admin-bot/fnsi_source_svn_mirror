// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 06-14-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 06-14-2021
// ***********************************************************************
// <copyright file="IReleaseInfoController.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.App.Models;
using CoopSettingTool.App.Views;

namespace CoopSettingTool.App.Controllers
{
    /// <summary>
    /// Interface IReleaseInfoController
    /// Implements the <see cref="CoopSettingTool.App.Controllers.IBaseController{CoopSettingTool.App.Views.IReleaseInfoView, CoopSettingTool.App.Models.IReleaseInfoModel}" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Controllers.IBaseController{CoopSettingTool.App.Views.IReleaseInfoView, CoopSettingTool.App.Models.IReleaseInfoModel}" />
    interface IReleaseInfoController : IBaseController<IReleaseInfoView, IReleaseInfoModel>
    {
        /// <summary>
        /// Loads all release information.
        /// </summary>
        void LoadAllReleaseInfo();
    }
}
