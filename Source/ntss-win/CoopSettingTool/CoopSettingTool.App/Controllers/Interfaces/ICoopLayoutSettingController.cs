// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-13-2022
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-14-2022
// ***********************************************************************
// <copyright file="ICoopLayoutSettingController.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved
// </copyright>
// <summary></summary>
// ***********************************************************************

using CoopSettingTool.App.Models;
using CoopSettingTool.App.Views;

namespace CoopSettingTool.App.Controllers
{
    /// <summary>
    /// Interface ICoopLayoutSettingController
    /// Implements the <see cref="CoopSettingTool.App.Controllers.IBaseController{CoopSettingTool.App.Views.ICoopLayoutSettingView, CoopSettingTool.App.Models.ICoopLayoutSettingModel}" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Controllers.IBaseController{CoopSettingTool.App.Views.ICoopLayoutSettingView, CoopSettingTool.App.Models.ICoopLayoutSettingModel}" />
    public interface ICoopLayoutSettingController : IBaseController<ICoopLayoutSettingView, ICoopLayoutSettingModel>
    {
        /// <summary>
        /// Loads the coop layouts.
        /// </summary>
        void LoadCoopLayouts();

        /// <summary>
        /// Saves this instance.
        /// </summary>
        void Save();

        /// <summary>
        /// Sorts by the specified sort field.
        /// </summary>
        /// <param name="sortField">The sort field.</param>
        /// <param name="isReverse">if set to <c>true</c> [is reverse].</param>
        void Sort(string sortField, bool isReverse);
    }
}
