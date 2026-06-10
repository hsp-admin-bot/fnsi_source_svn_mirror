// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 04-16-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-16-2021
// ***********************************************************************
// <copyright file="LoginRequest.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using Newtonsoft.Json;

namespace CoopSettingTool.Service.Models
{
    /// <summary>
    /// Class LoginRequest.
    /// Implements the <see cref="CoopSettingTool.Service.Models.BaseRequest" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.Models.BaseRequest" />
    public class LoginRequest : BaseRequest
    {
        /// <summary>
        /// Gets or sets the user identifier.
        /// </summary>
        /// <value>The user identifier.</value>
        [JsonProperty("userId")]
        public string UserId { get; set; }

        /// <summary>
        /// Gets or sets the password.
        /// </summary>
        /// <value>The password.</value>
        [JsonProperty("password")]
        public string Password { get; set; }

        /// <summary>
        /// Gets or sets the facility cd.
        /// </summary>
        /// <value>The facility cd.</value>
        [JsonProperty("facilityCd")]
        public string FacilityCd { get; set; }

        /// <summary>
        /// Gets or sets the otp cd.
        /// </summary>
        /// <value>The otp cd.</value>
        [JsonProperty("otpCd")]
        public string OtpCd { get; set; }
    }
}
