// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-26-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-20-2021
// ***********************************************************************
// <copyright file="ICoopFunctionSettingModel.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.Service.Models;
using System.Collections.Generic;

namespace CoopSettingTool.App.Models
{
    /// <summary>
    /// Interface ICoopFunctionSettingModel
    /// Implements the <see cref="CoopSettingTool.App.Models.IBaseModel" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Models.IBaseModel" />
    public interface ICoopFunctionSettingModel : IBaseModel
    {
        /// <summary>
        /// Gets or sets the coop facility.
        /// </summary>
        /// <value>The coop facility.</value>
        MstCoopFacilityEntity CoopFacility { get; set; }
        /// <summary>
        /// Gets or sets if egde setting.
        /// </summary>
        /// <value>If egde setting.</value>
        IfEgdeSetting IfEgdeSetting { get; set; }

        /// <summary>
        /// Gets or sets the watch information.
        /// </summary>
        /// <value>The watch information.</value>
        WatchInfo WatchInfo { get; set; }

        /// <summary>
        /// Gets or sets the index of the coop function.
        /// </summary>
        /// <value>The index of the coop function.</value>
        int CoopFunctionIndex { get; set; }
        /// <summary>
        /// Gets or sets the coop layout list.
        /// </summary>
        /// <value>The coop layout list.</value>
        List<MstCoopLayoutEntity> CoopLayoutList { get; set; }
        /// <summary>
        /// Gets or sets the coop distribute list.
        /// </summary>
        /// <value>The coop distribute list.</value>
        List<MstCoopDistributeEntity> CoopDistributeList { get; set; }
        /// <summary>
        /// Gets or sets the send protocol.
        /// </summary>
        /// <value>The send protocol.</value>
        ProtocolInfo SendProtocol { get; set; }
        MstFacilityEntity Facility { get; set; }
    }
}
