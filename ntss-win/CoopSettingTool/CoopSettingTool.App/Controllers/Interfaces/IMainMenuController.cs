// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-19-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 06-18-2021
// ***********************************************************************
// <copyright file="IMainMenuController.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.App.Models;
using CoopSettingTool.App.Views;

namespace CoopSettingTool.App.Controllers
{
    /// <summary>
    /// Interface IMainMenuController
    /// Implements the <see cref="CoopSettingTool.App.Controllers.IBaseController{CoopSettingTool.App.Views.IMainMenuView, CoopSettingTool.App.Models.IMainMenuModel}" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Controllers.IBaseController{CoopSettingTool.App.Views.IMainMenuView, CoopSettingTool.App.Models.IMainMenuModel}" />
    public interface IMainMenuController : IBaseController<IMainMenuView, IMainMenuModel>
    {
        /// <summary>
        /// Shows the view.
        /// </summary>
        void ShowView();
        /// <summary>
        /// Loads the facility data.
        /// </summary>
        void LoadFacilityData();

        /// <summary>
        /// Shows the manual.
        /// </summary>
        void ShowManual();
    }
}
