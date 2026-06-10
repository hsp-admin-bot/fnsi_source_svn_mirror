// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-13-2022
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-13-2022
// ***********************************************************************
// <copyright file="ICoopLayoutDetailSettingController.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************

using CoopSettingTool.App.Models;
using CoopSettingTool.App.Views;

namespace CoopSettingTool.App.Controllers
{
    /// <summary>
    /// Interface ICoopLayoutDetailSettingController
    /// Implements the <see cref="CoopSettingTool.App.Controllers.IBaseController{CoopSettingTool.App.Views.ICoopLayoutDetailSettingView, CoopSettingTool.App.Models.ICoopLayoutDetailSettingModel}" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Controllers.IBaseController{CoopSettingTool.App.Views.ICoopLayoutDetailSettingView, CoopSettingTool.App.Models.ICoopLayoutDetailSettingModel}" />
    public interface ICoopLayoutDetailSettingController : IBaseController<ICoopLayoutDetailSettingView, ICoopLayoutDetailSettingModel>
    {
        /// <summary>
        /// Loads the coop layout details.
        /// </summary>
        void LoadCoopLayoutDetails();

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
