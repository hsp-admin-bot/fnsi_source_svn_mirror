// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 04-16-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-16-2021
// ***********************************************************************
// <copyright file="LoginResponseEntity.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using Newtonsoft.Json;

namespace CoopSettingTool.Service.Models
{
    /// <summary>
    /// Class LoginResponseEntity.
    /// Implements the <see cref="CoopSettingTool.Service.Models.BaseEntity" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.Models.BaseEntity" />
    public class LoginResponseEntity : BaseEntity
    {
        /// <summary>
        /// Gets or sets the facility code.
        /// </summary>
        /// <value>The facility code.</value>
        [JsonProperty("facilityCd")]
        public string FacilityCode { get; set; }

        /// <summary>
        /// Gets or sets the user identifier.
        /// </summary>
        /// <value>The user identifier.</value>
        [JsonProperty("userId")]
        public long UserId { get; set; }

        /// <summary>
        /// Gets or sets the type of the user.
        /// </summary>
        /// <value>The type of the user.</value>
        [JsonProperty("userType")]
        public long UserType { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether [sign inrestriction].
        /// </summary>
        /// <value><c>true</c> if [sign inrestriction]; otherwise, <c>false</c>.</value>
        [JsonProperty("signInRestriction")]
        public bool SignInrestriction { get; set; }
    }
}
