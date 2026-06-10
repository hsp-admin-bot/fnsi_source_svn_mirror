// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-19-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-14-2022
// ***********************************************************************
// <copyright file="IMainMenuModel.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.Service.Models;

namespace CoopSettingTool.App.Models
{
    /// <summary>
    /// Interface IMainMenuModel
    /// Implements the <see cref="CoopSettingTool.App.Models.IBaseModel" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Models.IBaseModel" />
    public interface IMainMenuModel : IBaseModel
    {
        /// <summary>
        /// Gets or sets the selected facility.
        /// </summary>
        /// <value>The selected facility.</value>
        MstFacilityEntity SelectedFacility { get; set; }
       
        /// <summary>
        /// Gets or sets a value indicating whether this instance is installed.
        /// </summary>
        /// <value><c>true</c> if this instance is installed; otherwise, <c>false</c>.</value>
        bool IsInstalled { get; set; }

    }
}
