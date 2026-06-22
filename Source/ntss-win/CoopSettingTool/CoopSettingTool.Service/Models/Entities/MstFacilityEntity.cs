// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 04-16-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-20-2021
// ***********************************************************************
// <copyright file="MstFacilityEntity.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.Service.Enums;
using Newtonsoft.Json;
using System.Collections.Generic;
using System.ComponentModel;

namespace CoopSettingTool.Service.Models
{
    /// <summary>
    /// Class MstFacilityEntity.
    /// Implements the <see cref="CoopSettingTool.Service.Models.BaseEntity" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.Models.BaseEntity" />
    public class MstFacilityEntity : BaseEntity
    {
        /// <summary>
        /// Gets or sets the facility cd.
        /// </summary>
        /// <value>The facility cd.</value>
        [JsonProperty("facilityCd")]
        [DisplayName("施設コード")]
        public string FacilityCd { get; set; }

        /// <summary>
        /// Gets or sets the name of the facility.
        /// </summary>
        /// <value>The name of the facility.</value>
        [JsonProperty("facilityName")]
        [DisplayName("施設名")]
        public string FacilityName { get; set; }

        private string prefecturesCd;
        /// <summary>
        /// Gets or sets the prefectures cd.
        /// </summary>
        /// <value>The prefectures cd.</value>
        [JsonProperty("prefecturesCd")]
        [Browsable(false)]
        public string PrefecturesCd
        {
            get
            {
                return prefecturesCd;
            }
            set
            {
                prefecturesCd = value;
                int i = 0;
                int.TryParse(prefecturesCd, out i);

                if (i != 0)
                {
                    var prefecture = (Prefecture)i;
                    Prefecture = prefecture.ToString();
                }
                else
                {
                    Prefecture = string.Empty;
                }
            }
        }

        [JsonIgnore]
        [DisplayName("都道府県")]
        public string Prefecture { get; set; }


        [JsonProperty("departmentCd")]
        [DisplayName("部署符号")]
        public string DepartmentCd { get; set; }

        /// <summary>
        /// Gets the display member.
        /// </summary>
        /// <value>The display member.</value>
        [JsonIgnore]
        [Browsable(false)]
        public string DisplayMember => string.Join(" - ", new List<string>() { FacilityCd, FacilityName });
    }
}
