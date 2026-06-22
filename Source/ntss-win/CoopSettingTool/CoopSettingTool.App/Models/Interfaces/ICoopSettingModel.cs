// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 05-26-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-26-2021
// ***********************************************************************
// <copyright file="ICoopSettingModel.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.Service.Models;
using System.Collections.Generic;

namespace CoopSettingTool.App.Models
{
    /// <summary>
    /// Interface ICoopSettingModel
    /// Implements the <see cref="CoopSettingTool.App.Models.IBaseModel" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Models.IBaseModel" />
    public interface ICoopSettingModel : IBaseModel
    {
        /// <summary>
        /// Gets or sets the facility.
        /// </summary>
        /// <value>The facility.</value>
        MstFacilityEntity Facility { get; set; }

        /// <summary>
        /// Gets or sets the coop ini list.
        /// </summary>
        /// <value>The coop ini list.</value>
        MstCoopIniEntity CoopIni { get; set; }

        /// <summary>
        /// Gets or sets the coop ini list.
        /// </summary>
        /// <value>The coop ini list.</value>
        List<CoopIniInfo> CoopIniInfos { get; set; }

        /// <summary>
        /// Adds the blank setting.
        /// </summary>
        /// <param name="addIndex">Index of the add.</param>
        void AddBlankSetting(int addIndex);

        /// <summary>
        /// Called when [off setting].
        /// </summary>
        /// <param name="removeList">The remove list.</param>
        void OnOffSetting(List<CoopIniInfo> removeList);
    }
}
