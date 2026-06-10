// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 04-21-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-11-2021
// ***********************************************************************
// <copyright file="MstCoopLayoutEntity.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
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
    public class MstCoopLayoutDetailEntity : BaseEntity
    {
        public MstCoopLayoutDetailEntity()
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
        /// Gets or sets the direction.
        /// </summary>
        /// <value>The direction.</value>
        [JsonProperty("direction")]
        [ReadOnly(true)]
        [DisplayName("向き（送受信）")]
        public string Direction { get; set; }

        /// <summary>
        /// Gets or sets the coop cd detail.
        /// </summary>
        /// <value>The coop cd detail.</value>
        [JsonProperty("coopCdDetail")]
        [ReadOnly(true)]
        [DisplayName("電文種別詳細コード")]
        public string CoopCdDetail { get; set; }

        /// <summary>
        /// Gets or sets the coop cd sub.
        /// </summary>
        /// <value>The coop cd sub.</value>
        [JsonProperty("coopCdDetailSub")]
        [ReadOnly(true)]
        [DisplayName("電文種別詳細補足コード")]
        public string CoopCdDetailSub { get; set; }

        /// <summary>
        /// Gets or sets the name of the coop.
        /// </summary>
        /// <value>The name of the coop.</value>
        [JsonProperty("coopName")]
        [ReadOnly(true)]
        [DisplayName("レイアウト名称")]
        public string CoopName { get; set; }

        /// <summary>
        /// Gets or sets the description.
        /// </summary>
        /// <value>The description.</value>
        [JsonProperty("description")]
        [ReadOnly(true)]
        [DisplayName("説明")]
        public string Description { get; set; }

        /// <summary>
        /// Gets or sets the is editable.
        /// </summary>
        /// <value>The is editable.</value>
        [JsonProperty("isEditable")]
        [Browsable(false)]
        public string IsEditable { get; set; }

        /// <summary>
        /// Gets or sets the coop setting string.
        /// </summary>
        /// <value>The coop setting string.</value>
        [JsonProperty("coopSetting")]
        [DisplayName("連携設定")]
        public string CoopSetting { get; set; }

        /// <summary>
        /// Gets or sets the coop ext setting.
        /// </summary>
        /// <value>The coop ext setting.</value>
        [JsonProperty("coopExtSetting")]
        [Browsable(false)]
        public object CoopExtSettingObject { get; set; }

        /// <summary>
        /// Gets or sets the coop ext setting.
        /// </summary>
        /// <value>The coop ext setting.</value>
        [DisplayName("拡張設定")]
        [ReadOnly(true)]
        public string CoopExtSetting
        {
            get
            {
                string rs = string.Empty;
                var settings = new JsonSerializerSettings
                {
                    NullValueHandling = NullValueHandling.Ignore,
                    MissingMemberHandling = MissingMemberHandling.Ignore
                };
                rs = JsonConvert.SerializeObject(this.CoopExtSettingObject, settings);

                return rs;
            }

            set
            {
                if (!string.IsNullOrEmpty(value))
                {
                    var settings = new JsonSerializerSettings
                    {
                        NullValueHandling = NullValueHandling.Ignore,
                        MissingMemberHandling = MissingMemberHandling.Ignore,
                        TypeNameHandling = TypeNameHandling.Auto
                    };
                    this.CoopExtSettingObject = JsonConvert.DeserializeObject(value, settings);
                }
            }
        }

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
            return (this.CoopSetting + this.CoopExtSetting + this.IsDel).GetHashCode();
        }
    }
}
