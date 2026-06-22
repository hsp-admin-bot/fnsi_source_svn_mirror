// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-13-2022
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-13-2022
// ***********************************************************************
// <copyright file="CoopFacilitySettingModel.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************

using CoopSettingTool.Service.Models;
using System.Collections.Generic;

namespace CoopSettingTool.App.Models
{
    /// <summary>
    /// Class CoopFacilitySettingModel.
    /// Implements the <see cref="CoopSettingTool.App.Models.BaseModel" />
    /// Implements the <see cref="CoopSettingTool.App.Models.ICoopFacilitySettingModel" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Models.BaseModel" />
    /// <seealso cref="CoopSettingTool.App.Models.ICoopFacilitySettingModel" />
    public class CoopFacilitySettingModel : BaseModel, ICoopFacilitySettingModel
    {
        /// <summary>
        /// The facility
        /// </summary>
        private MstFacilityEntity facility;

        /// <summary>
        /// The coop facility
        /// </summary>
        private MstCoopFacilityEntity coopFacility;

        /// <summary>
        /// Gets or sets the facility.
        /// </summary>
        /// <value>The facility.</value>
        public MstFacilityEntity Facility
        {
            get
            {
                return facility;
            }
            set
            {
                facility = value;
                NotifyPropertyChanged();
            }
        }

        /// <summary>
        /// Gets or sets the coop facility.
        /// </summary>
        /// <value>The coop facility.</value>
        public MstCoopFacilityEntity CoopFacility
        {
            get
            {
                return coopFacility;
            }
            set
            {
                coopFacility = value;
                NotifyPropertyChanged();
            }
        }

        /// <summary>
        /// Clears the data.
        /// </summary>
        public override void ClearData()
        {
            Facility = null;
            CoopFacility = null;
        }
    }
}
