// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 05-25-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-25-2021
// ***********************************************************************
// <copyright file="MstIfEdgeEntity.cs" company="">
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
    /// Class MstIfEdgeEntity.
    /// Implements the <see cref="CoopSettingTool.Service.Models.BaseEntity" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.Models.BaseEntity" />
    public class MstIfEdgeEntity : BaseEntity
    {
        public MstIfEdgeEntity(string facilityCd)
        {
            FacilityCd = facilityCd;
            IsDel = "0";
            IsDisp = "1";

            this.Initialize();
        }
        
        /// <summary>
        /// Gets or sets the serial no.
        /// </summary>
        /// <value>The serial no.</value>
        [JsonProperty("serialNo")]
        [DisplayName("製造番号")]
        public string SerialNo { get; set; }

        /// <summary>
        /// Gets or sets the facility cd.
        /// </summary>
        /// <value>The facility cd.</value>
        [JsonProperty("facilityCd")]
        [Browsable(false)]
        public string FacilityCd { get; set; }

        /// <summary>
        /// Gets or sets if edge no.
        /// </summary>
        /// <value>If edge no.</value>
        [JsonProperty("ifEdgeNo")]
        [DisplayName("IFエッジ番号")]
        public string IfEdgeNo { get; set; }

        /// <summary>
        /// Gets or sets the name of if edge.
        /// </summary>
        /// <value>The name of if edge.</value>
        [JsonProperty("ifEdgeName")]
        [DisplayName("IFエッジ名")]
        public string IfEdgeName { get; set; }

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
        /// Gets or sets the setting date.
        /// </summary>
        /// <value>The setting date.</value>
        [JsonProperty("settingDate")]
        [Browsable(false)]
        public DateTime? SettingDate { get; set; }

        /// <summary>
        /// Gets or sets the delete date.
        /// </summary>
        /// <value>The delete date.</value>
        [JsonProperty("deleteDate")]
        [Browsable(false)]
        public DateTime? DeleteDate { get; set; }

        /// <summary>
        /// Gets or sets the memo.
        /// </summary>
        /// <value>The memo.</value>
        [JsonProperty("memo")]
        [DisplayName("メモ")]
        public string Memo { get; set; }

        /// <summary>
        /// Gets or sets the reg date.
        /// </summary>
        /// <value>The reg date.</value>
        [JsonProperty("regDate")]
        [Browsable(false)]
        public DateTime? RegDate { get; set; }

        /// <summary>
        /// Gets or sets up date.
        /// </summary>
        /// <value>Up date.</value>
        [JsonProperty("upDate")]
        [Browsable(false)]
        public DateTime? UpDate { get; set; }

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
