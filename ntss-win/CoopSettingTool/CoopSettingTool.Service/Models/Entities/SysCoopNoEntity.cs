// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 05-21-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-21-2021
// ***********************************************************************
// <copyright file="SysCoopNoEntity.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.Service.Extendsions;
using Newtonsoft.Json;
using System;
using System.ComponentModel;

namespace CoopSettingTool.Service.Models
{
    /// <summary>
    /// Class CoopCdItem.
    /// </summary>
    public class CoopCdItem
    {
        /// <summary>
        /// Gets or sets the control no.
        /// </summary>
        /// <value>The control no.</value>
        [JsonProperty("ord_cd")]
        public string CoopCd { get; set; }
    }

    /// <summary>
    /// Class SysCoopNoEntity.
    /// Implements the <see cref="CoopSettingTool.Service.Models.BaseEntity" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.Models.BaseEntity" />
    public class SysCoopNoEntity : BaseEntity
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="SysCoopNoEntity"/> class.
        /// </summary>
        /// <param name="facilityCd">The facility cd.</param>
        public SysCoopNoEntity(string facilityCd)
        {
            this.FacilityCd = facilityCd;
            this.CurCoopOrdNo = "1";
            this.NoOfDigit = "8";
            this.PaddingChar = '0';
            this.RangeMin = "1";
            this.PaddingPos = "left";
            this.RangeMax = "99999999";
            this.IsDel = "0";
            this.IsDisp = "1";
            this.CoopCd = "";
            this.CoopCdIndex = "";
            this.CoopVersion = "1";

            this.Initialize();
        }

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
        /// Gets or sets the control no.
        /// </summary>
        /// <value>The control no.</value>
        [JsonProperty("ctlNo")]
        [Browsable(false)]
        public string CtlNo { get; set; }

        /// <summary>
        /// Gets or sets the facility cd.
        /// </summary>
        /// <value>The facility cd.</value>
        [JsonProperty("facilityCd")]
        [ReadOnly(true)]
        [DisplayName("施設コード")]
        public string FacilityCd { get; set; }

        /// <summary>
        /// Gets or sets the coop version.
        /// </summary>
        [JsonProperty("coopVersion")]
        [ReadOnly(true)]
        [DisplayName("連携名")]
        public string CoopVersion { get; set; }

        /// <summary>
        /// Gets or sets the ord CDS.
        /// </summary>
        /// <value>The ord CDS.</value>
        [JsonProperty("coopOrdCd")]
        [DisplayName("連携オーダ種別")]
        [ReadOnly(true)]
        public string OrdCds { get; set; }

        ///// <summary>
        ///// Gets or sets the ord CDS.
        ///// </summary>
        ///// <value>The ord CDS.</value>
        //[JsonProperty("coopOrdCd")]
        //public List<Dictionary<string, string>> OrdCds { get; set; }

        /// <summary>
        /// Gets or sets the current coop ord cd.
        /// </summary>
        /// <value>The current coop ord cd.</value>
        [JsonProperty("curCoopOrdNo")]
        [DisplayName("現在の連携オーダ番号")]
        public string CurCoopOrdNo { get; set; }

        /// <summary>
        /// Gets or sets the no of digit.
        /// </summary>
        /// <value>The no of digit.</value>
        [JsonProperty("noOfDigit")]
        [DisplayName("桁数")]
        public string NoOfDigit { get; set; }

        /// <summary>
        /// Gets or sets the padding character.
        /// </summary>
        /// <value>The padding character.</value>
        [JsonProperty("paddingChar")]
        [DisplayName("パディング文字")]
        public char PaddingChar { get; set; }

        /// <summary>
        /// Gets or sets the padding position.
        /// </summary>
        /// <value>The padding position.</value>
        [JsonProperty("paddingPos")]
        [DisplayName("パディング位置")]
        public string PaddingPos { get; set; }

        /// <summary>
        /// Gets or sets the range maximum.
        /// </summary>
        /// <value>The range maximum.</value>
        [JsonProperty("rangeMax")]
        [DisplayName("最大値")]
        public string RangeMax { get; set; }

        /// <summary>
        /// Gets or sets the range minimum.
        /// </summary>
        /// <value>The range minimum.</value>
        [JsonProperty("rangeMin")]
        [DisplayName("最小値")]
        public string RangeMin { get; set; }

        /// <summary>
        /// Gets or sets the prefix character.
        /// </summary>
        /// <value>The prefix character.</value>
        [JsonProperty("prefixChar")]
        [DisplayName("前置文字")]
        public string PrefixChar { get; set; }

        /// <summary>
        /// Gets or sets the suffix character.
        /// </summary>
        /// <value>The suffix character.</value>
        [JsonProperty("suffixChar")]
        [DisplayName("後置文字")]
        public string SuffixChar { get; set; }

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

        /// <summary>
        /// Gets or sets the user identifier.
        /// </summary>
        /// <value>The user identifier.</value>
        [JsonProperty("userId")]
        [Browsable(false)]
        public string UserId { get; set; }

        /// <summary>
        /// Gets or sets the coopCd.
        /// </summary>
        /// <value>The coopCd.</value>
        [JsonProperty("coopCd")]
        [DisplayName("連携種別")]
        public string CoopCd { get; set; }

        /// <summary>
        /// Gets or sets the coopCdIndex.
        /// </summary>
        /// <value>The coopCdIndex.</value>
        [JsonProperty("coopCdIndex")]
        [DisplayName("付帯情報（電文）")]
        public string CoopCdIndex { get; set; }

        /// <summary>
        /// Returns a hash code for this instance.
        /// </summary>
        /// <returns>A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.</returns>
        public override int GetHashCode()
        {
            int hashCode = this.GetHashCodeOnProperties();
            return hashCode;
        }

    }
}
