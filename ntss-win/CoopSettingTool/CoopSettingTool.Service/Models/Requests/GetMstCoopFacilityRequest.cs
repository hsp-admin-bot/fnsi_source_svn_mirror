// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 04-26-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-26-2021
// ***********************************************************************
// <copyright file="GetMstCoopFacilityRequest.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using Newtonsoft.Json;

namespace CoopSettingTool.Service.Models
{
    /// <summary>
    /// Class GetMstCoopFacilityRequest.
    /// Implements the <see cref="CoopSettingTool.Service.Models.BaseRequest" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.Models.BaseRequest" />
    public class GetMstCoopFacilityRequest : BaseRequest
    {
        /// <summary>
        /// Gets or sets the facility cd.
        /// </summary>
        /// <value>The facility cd.</value>
        [JsonProperty("facilityCd")]
        public string FacilityCd { get; set; }

        /// <summary>
        /// Gets or sets the control no.
        /// </summary>
        /// <value>The control no.</value>
        [JsonProperty("ctlNo")]
        public string CtlNo { get; set; }
    }
}
