// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 04-16-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-16-2021
// ***********************************************************************
// <copyright file="BaseRequest.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using Newtonsoft.Json;

namespace CoopSettingTool.Service.Models
{
    /// <summary>
    /// Class BaseRequest.
    /// </summary>
    public class BaseRequest
    {
        /// <summary>
        /// Gets or sets the page.
        /// </summary>
        /// <value>The page.</value>
        [JsonProperty("page")]
        public int? Page { get; set; }

        /// <summary>
        /// Gets or sets the per page.
        /// </summary>
        /// <value>The per page.</value>
        [JsonProperty("per_page")]
        public int? PerPage { get; set; }
    }
}
