// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 06-14-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 06-14-2021
// ***********************************************************************
// <copyright file="SysReleaseInfoEntity.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using Newtonsoft.Json;
using System;
using System.ComponentModel;

namespace CoopSettingTool.Service.Models
{
    /// <summary>
    /// Class SysReleaseInfoEntity.
    /// Implements the <see cref="CoopSettingTool.Service.Models.BaseEntity" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.Models.BaseEntity" />
    public class SysReleaseInfoEntity : BaseEntity
    {
        /// <summary>
        /// Gets or sets the control no.
        /// </summary>
        /// <value>The control no.</value>
        [JsonProperty("ctlNo")]
        [Browsable(false)]
        public string CtlNo { get; set; }

        /// <summary>
        /// Gets or sets the release date.
        /// </summary>
        /// <value>The release date.</value>
        [JsonProperty("releaseDate")]
        [DisplayName("リリース日")]
        public string ReleaseDate { get; set; }

        /// <summary>
        /// Gets or sets the title.
        /// </summary>
        /// <value>The title.</value>
        [JsonProperty("title")]
        [DisplayName("タイトル")]
        public string Title { get; set; }

        /// <summary>
        /// Gets or sets the type of the system.
        /// </summary>
        /// <value>The type of the system.</value>
        [JsonProperty("systemType")]
        [DisplayName("システムタイプ")]
        public string SystemType { get; set; }

        /// <summary>
        /// Gets or sets the path URL.
        /// </summary>
        /// <value>The path URL.</value>
        [JsonProperty("pathUrl")]
        [DisplayName("URL")]
        public string PathUrl { get; set; }

        /// <summary>
        /// Gets or sets the is disp.
        /// </summary>
        /// <value>The is disp.</value>
        [JsonProperty("isDisp")]
        [Browsable(false)]
        public string IsDisp { get; set; }

        /// <summary>
        /// Gets or sets the is delete.
        /// </summary>
        /// <value>The is delete.</value>
        [JsonProperty("isDel")]
        [Browsable(false)]
        public string IsDel { get; set; }
    }
}
