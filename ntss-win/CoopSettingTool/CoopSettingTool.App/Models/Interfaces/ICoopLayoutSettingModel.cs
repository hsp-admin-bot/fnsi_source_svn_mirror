// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-13-2022
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-13-2022
// ***********************************************************************
// <copyright file="ICoopLayoutSettingModel.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************


using CoopSettingTool.Service.Models;
using System.Collections.Generic;

namespace CoopSettingTool.App.Models
{
    /// <summary>
    /// Interface ICoopLayoutSettingModel
    /// Implements the <see cref="CoopSettingTool.App.Models.IBaseModel" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Models.IBaseModel" />
    public interface ICoopLayoutSettingModel : IBaseModel
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
        List<MstCoopLayoutEntity> CoopLayouts { get; set; }
    }
}
