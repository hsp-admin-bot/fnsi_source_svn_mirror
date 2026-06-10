// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-23-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-10-2021
// ***********************************************************************
// <copyright file="ICoopFunctionListModel.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************

using CoopSettingTool.Service.Models;
using System.Collections.Generic;

namespace CoopSettingTool.App.Models
{
    /// <summary>
    /// Interface ICoopFunctionListModel
    /// Implements the <see cref="CoopSettingTool.App.Models.IBaseModel" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Models.IBaseModel" />
    public interface ICoopFunctionListModel : IBaseModel
    {
        /// <summary>
        /// Gets or sets the facility.
        /// </summary>
        /// <value>The facility.</value>
        MstFacilityEntity Facility { get; set; }

        /// <summary>
        /// Gets or sets the coop facility.
        /// </summary>
        /// <value>The coop facility.</value>
        MstCoopFacilityEntity CoopFacility { get; set; }

        /// <summary>
        /// Gets or sets the index of the selected coop function.
        /// </summary>
        /// <value>The index of the selected coop function.</value>
        int SelectedCoopFunctionIndex { get; set; }
    }
}
