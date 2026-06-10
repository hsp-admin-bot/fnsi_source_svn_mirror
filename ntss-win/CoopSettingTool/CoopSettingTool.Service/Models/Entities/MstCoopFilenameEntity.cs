// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 08-04-2023
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 08-04-2023
// ***********************************************************************
// <copyright file="MstCoopFilenameEntity.cs" company="">
//     Copyright©2023 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoopSettingTool.Service.Models
{
    /// <summary>
    /// Class MstCoopLayoutEntity.
    /// Implements the <see cref="CoopSettingTool.Service.Models.BaseEntity" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.Models.BaseEntity" />
    public class MstCoopFilenameEntity : BaseEntity
    {
        public MstCoopFilenameEntity()
        {
            this.Initialize();
        }

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
        /// Gets or sets the control no.
        /// </summary>
        /// <value>The control no.</value>
        [JsonProperty("ctlNo")]
        [ReadOnly(true)]
        [DisplayName("管理番号")]
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
        /// Gets or sets the coop cd.
        /// </summary>
        /// <value>The coop cd.</value>
        [JsonProperty("coopCd")]
        [ReadOnly(true)]
        [DisplayName("電文種別")]
        public string CoopCd { get; set; }

        /// <summary>
        /// Gets or sets the coop cd index.
        /// </summary>
        /// <value>The coop cd index.</value>
        [JsonProperty("coopCdIndex")]
        [ReadOnly(true)]
        [DisplayName("付帯情報（電文）")]
        public string CoopCdIndex { get; set; }

        /// <summary>
        /// Gets or sets the pdf name.
        /// </summary>
        /// <value>The pdf name.</value>
        [JsonProperty("pdfName")]
        [ReadOnly(true)]
        [DisplayName("PDFファイル名")]
        public string PdfName { get; set; }

        /// <summary>
        /// Gets or sets the dump name.
        /// </summary>
        /// <value>The dump name.</value>
        [JsonProperty("dumpName")]
        [ReadOnly(true)]
        [DisplayName("電文パス名")]
        public string DumpName { get; set; }

        /// <summary>
        /// Gets or sets the compression name.
        /// </summary>
        /// <value>The compression name.</value>
        [JsonProperty("compressionName")]
        [ReadOnly(true)]
        [DisplayName("圧縮ファイル名")]
        public string CompressionName { get; set; }

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
        [DisplayName("削除フラグ")]
        public string IsDel { get; set; }

        /// <summary>
        /// Gets or sets the user identifier.
        /// </summary>
        /// <value>The user identifier.</value>
        [JsonProperty("userId")]
        [Browsable(false)]
        public string UserId { get; set; }

        /// <summary>
        /// Returns a hash code for this instance.
        /// </summary>
        /// <returns>A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.</returns>
        public override int GetHashCode()
        {
            return (this.PdfName + this.DumpName + this.CompressionName + this.IsDel).GetHashCode();
        }
    }
}
