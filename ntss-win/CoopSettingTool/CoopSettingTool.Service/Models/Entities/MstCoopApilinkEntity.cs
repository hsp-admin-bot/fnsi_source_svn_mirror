// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 06-09-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 06-09-2021
// ***********************************************************************
// <copyright file="MstCoopApilink.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.ComponentModel;

namespace CoopSettingTool.Service.Models
{
    /// <summary>
    /// Class ContinueApiStatus.
    /// </summary>
    public class ContinueApiStatus
    {
        /// <summary>
        /// Gets or sets the continue code.
        /// </summary>
        /// <value>The continue code.</value>
        [JsonProperty("continue_code")]
        public List<long> ContinueCode { get; set; }

        /// <summary>
        /// Gets or sets the exit code.
        /// </summary>
        /// <value>The exit code.</value>
        [JsonProperty("exit_code")]
        public List<long> ExitCode { get; set; }

    }

    /// <summary>
    /// Class AfterApiStatus.
    /// </summary>
    public class AfterApiStatus
    {
        /// <summary>
        /// Gets or sets the ana result.
        /// </summary>
        /// <value>The ana result.</value>
        public long AnaResult { get; set; }

        /// <summary>
        /// Gets or sets the coop result.
        /// </summary>
        /// <value>The coop result.</value>
        [JsonProperty("coop_result")]
        public long CoopResult { get; set; }
    }


    /// <summary>
    /// Class MstCoopApilink.
    /// Implements the <see cref="CoopSettingTool.Service.Models.BaseEntity" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.Models.BaseEntity" />
    public class MstCoopApilinkEntity : BaseEntity
    {
        public MstCoopApilinkEntity()
        {
            this.Initialize();
        }

        /// <summary>
        /// Gets or sets the control no.
        /// </summary>
        /// <value>The control no.</value>
        [JsonProperty("ctlNo")]
        public string CtlNo { get; set; }

        /// <summary>
        /// Gets or sets the facility cd.
        /// </summary>
        /// <value>The facility cd.</value>
        [JsonProperty("facilityCd")]
        public string FacilityCd { get; set; }

        /// <summary>
        /// Gets or sets the coop cd.
        /// </summary>
        /// <value>The coop cd.</value>
        [JsonProperty("coopCd")]
        public string CoopCd { get; set; }

        /// <summary>
        /// Gets or sets the index of the coop cd.
        /// </summary>
        /// <value>The index of the coop cd.</value>
        [JsonProperty("coopCdIndex")]
        [Browsable(false)]
        public string CoopCdIndex { get; set; }

        /// <summary>
        /// Gets or sets the crud.
        /// </summary>
        /// <value>The crud.</value>
        [JsonProperty("crud")]
        [Browsable(false)]
        public string Crud { get; set; }

        /// <summary>
        /// Gets or sets the direction.
        /// </summary>
        /// <value>The direction.</value>
        [JsonProperty("direction")]
        [Browsable(false)]
        public string Direction { get; set; }

        /// <summary>
        /// Gets or sets the API timing io.
        /// </summary>
        /// <value>The API timing io.</value>
        [JsonProperty("apiTimingIo")]
        [Browsable(false)]
        public string ApiTimingIo { get; set; }

        /// <summary>
        /// Gets or sets the API timing ba.
        /// </summary>
        /// <value>The API timing ba.</value>
        [JsonProperty("apiTimingBa")]
        [Browsable(false)]
        public string ApiTimingBa { get; set; }

        /// <summary>
        /// Gets or sets the API timing seq.
        /// </summary>
        /// <value>The API timing seq.</value>
        [JsonProperty("apiTimingSeq")]
        [Browsable(false)]
        public long ApiTimingSeq { get; set; }

        /// <summary>
        /// Gets or sets the type of the API.
        /// </summary>
        /// <value>The type of the API.</value>
        [JsonProperty("apiType")]
        [Browsable(false)]
        public string ApiType { get; set; }

        /// <summary>
        /// Gets or sets the SQL setting.
        /// </summary>
        /// <value>The SQL setting.</value>
        [JsonProperty("sqlSetting")]
        [Browsable(false)]
        public string SqlSetting { get; set; }

        /// <summary>
        /// Gets or sets the API URI.
        /// </summary>
        /// <value>The API URI.</value>
        [JsonProperty("apiUri")]
        [Browsable(false)]
        public string ApiUri { get; set; }

        /// <summary>
        /// Gets or sets the API method.
        /// </summary>
        /// <value>The API method.</value>
        [JsonProperty("apiMethod")]
        [Browsable(false)]
        public string ApiMethod { get; set; }

        /// <summary>
        /// Gets or sets the API body.
        /// </summary>
        /// <value>The API body.</value>
        [JsonProperty("apiBody")]
        [Browsable(false)]
        public string ApiBody { get; set; }

        /// <summary>
        /// Gets or sets the continue API status.
        /// </summary>
        /// <value>The continue API status.</value>
        [JsonProperty("continueApiStatus")]
        [Browsable(false)]
        public object ContinueApiStatus { get; set; }

        /// <summary>
        /// Gets or sets the after API status.
        /// </summary>
        /// <value>The after API status.</value>
        [JsonProperty("afterApiStatus")]
        [Browsable(false)]
        public object AfterApiStatus { get; set; }

        /// <summary>
        /// Gets or sets the is delete.
        /// </summary>
        /// <value>The is delete.</value>
        [JsonProperty("isDel")]
        [Browsable(false)]
        public string IsDel { get; set; }

        /// <summary>
        /// Gets or sets the user identifier.
        /// </summary>
        /// <value>The user identifier.</value>
        [JsonProperty("userId")]
        [Browsable(false)]
        public string UserId { get; set; }

        /// <summary>
        /// Gets or sets the reg date.
        /// </summary>
        /// <value>The reg date.</value>
        [JsonProperty("regDate")]
        [Browsable(false)]
        public DateTime RegDate { get; set; }

        /// <summary>
        /// Gets or sets up date.
        /// </summary>
        /// <value>Up date.</value>
        [JsonProperty("upDate")]
        [Browsable(false)]
        public DateTime UpDate { get; set; }

        /// <summary>
        /// Determines whether the specified apilink is similar.
        /// </summary>
        /// <param name="apilink">The apilink.</param>
        /// <returns><c>true</c> if the specified apilink is similar; otherwise, <c>false</c>.</returns>
        public bool IsSimilar(MstCoopApilinkEntity apilink)
        {
            if (this.CoopCd.Equals(apilink.CoopCd)
                && this.CoopCdIndex.Equals(apilink.CoopCdIndex)
                && this.Crud.Equals(apilink.Crud)
                && this.Direction.Equals(apilink.Direction)
                && this.ApiTimingIo.Equals(apilink.ApiTimingIo)
                && this.ApiTimingBa.Equals(apilink.ApiTimingBa)
                && this.ApiTimingSeq.Equals(apilink.ApiTimingSeq))
            {
                return true;
            }
            else
            {
                return false;
            }
        }
    }
}
