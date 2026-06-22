// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : PHan Hai Thach
// Created          : 04-14-2022
//
// Last Modified By : PHan Hai Thach
// Last Modified On : 04-14-2022
// ***********************************************************************
// <copyright file="ICoopDistributeSettingController.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved
// </copyright>
// <summary></summary>
// ***********************************************************************

using CoopSettingTool.App.Models;
using CoopSettingTool.App.Views;

namespace CoopSettingTool.App.Controllers
{
    /// <summary>
    /// Interface ICoopDistributeSettingController
    /// Implements the <see cref="CoopSettingTool.App.Controllers.IBaseController{CoopSettingTool.App.Views.ICoopDistributeSettingView, CoopSettingTool.App.Models.ICoopDistributeSettingModel}" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Controllers.IBaseController{CoopSettingTool.App.Views.ICoopDistributeSettingView, CoopSettingTool.App.Models.ICoopDistributeSettingModel}" />
    public interface ICoopDistributeSettingController : IBaseController<ICoopDistributeSettingView, ICoopDistributeSettingModel>
    {
        /// <summary>
        /// Loads the coop distributes.
        /// </summary>
        void LoadCoopDistributes();

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

        /// <summary>
        /// ファイルをインポートする
        /// </summary>
        /// <param name="filePath"></param>
        void Import(string filePath);
    }
}
