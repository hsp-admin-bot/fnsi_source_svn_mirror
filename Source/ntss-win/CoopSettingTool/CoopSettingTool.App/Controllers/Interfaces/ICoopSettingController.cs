// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 05-26-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-26-2021
// ***********************************************************************
// <copyright file="ICoopSettingController.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.App.Models;
using CoopSettingTool.App.Views;
using CoopSettingTool.Service.Models;
using System.Collections.Generic;

namespace CoopSettingTool.App.Controllers
{
    /// <summary>
    /// Interface ICoopSettingController
    /// Implements the <see cref="CoopSettingTool.App.Controllers.IBaseController{CoopSettingTool.App.Views.ICoopSettingView, CoopSettingTool.App.Models.ICoopSettingModel}" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Controllers.IBaseController{CoopSettingTool.App.Views.ICoopSettingView, CoopSettingTool.App.Models.ICoopSettingModel}" />
    interface ICoopSettingController : IBaseController<ICoopSettingView, ICoopSettingModel>
    {
        /// <summary>
        /// Loads the coop ini.
        /// </summary>
        void LoadCoopIni();

        /// <summary>
        /// Saves this instance.
        /// </summary>
        void Save();

        /// <summary>
        /// Adds the blank setting.
        /// </summary>
        void AddBlankSetting(int addIndex);

        /// <summary>
        /// Removes the setting.
        /// </summary>
        /// <param name="removeList">The remove list.</param>
        void OnOffSetting(List<CoopIniInfo> removeList);

        /// <summary>
        /// Exports the coop ini.
        /// </summary>
        /// <param name="fileName">Name of the file.</param>
        void ExportCoopIni(string fileName);

        /// <summary>
        /// Imports the coop ini.
        /// </summary>
        /// <param name="fileName">Name of the file.</param>
        void ImportCoopIni(string fileName);

        /// <summary>
        /// Sorts the settings.
        /// </summary>
        /// <param name="sortField">The sort field.</param>
        /// <param name="isReverse">if set to <c>true</c> [is reverse].</param>
        void SortSettings(string sortField, bool isReverse);
    }
}
