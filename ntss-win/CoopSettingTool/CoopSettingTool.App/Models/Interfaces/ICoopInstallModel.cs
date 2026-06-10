// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-20-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-21-2021
// ***********************************************************************
// <copyright file="ICoopInstallModel.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.Service.Models;
using System.Collections.Generic;

namespace CoopSettingTool.App.Models
{
    /// <summary>
    /// Interface ICoopInstallModel
    /// Implements the <see cref="CoopSettingTool.App.Models.IBaseModel" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Models.IBaseModel" />
    public interface ICoopInstallModel : IBaseModel
    {
        /// <summary>
        /// Gets or sets the selected facility.
        /// </summary>
        /// <value>The selected facility.</value>
        MstFacilityEntity Facility { get; set; }

        /// <summary>
        /// Gets or sets the coop facility artifacts.
        /// </summary>
        /// <value>The coop facility artifacts.</value>
        List<MstCoopFacilityEntity> CoopFacilityArtifacts { get; set; }
        /// <summary>
        /// Gets or sets the selected artifact indices.
        /// </summary>
        /// <value>The selected artifact indices.</value>
        List<int> SelectedArtifactIndices { get; set; }
    }
}
