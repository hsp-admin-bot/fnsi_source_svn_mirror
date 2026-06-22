// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 05-25-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-25-2021
// ***********************************************************************
// <copyright file="IIfEdgeSettingModel.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.Service.Models;
using System.Collections.Generic;

namespace CoopSettingTool.App.Models
{
    /// <summary>
    /// Interface IIfEdgeSettingModel
    /// Implements the <see cref="CoopSettingTool.App.Models.IBaseModel" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Models.IBaseModel" />
    public interface IIfEdgeSettingModel : IBaseModel
    {
        /// <summary>
        /// Gets or sets the facility.
        /// </summary>
        /// <value>The facility.</value>
        MstFacilityEntity Facility { get; set; }

        /// <summary>
        /// Gets or sets if edge list.
        /// </summary>
        /// <value>If edge list.</value>
        List<MstIfEdgeEntity> IfEdgeList { get; set; }

        void AddNewIfEdge();
    }
}
