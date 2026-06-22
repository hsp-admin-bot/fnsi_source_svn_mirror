// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-13-2022
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-13-2022
// ***********************************************************************
// <copyright file="CoopLayoutDetailSettingModel.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************

using CoopSettingTool.Service.Models;
using System.Collections.Generic;

namespace CoopSettingTool.App.Models
{
    /// <summary>
    /// Class CoopLayoutDetailSettingModel.
    /// Implements the <see cref="CoopSettingTool.App.Models.BaseModel" />
    /// Implements the <see cref="CoopSettingTool.App.Models.ICoopLayoutDetailSettingModel" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Models.BaseModel" />
    /// <seealso cref="CoopSettingTool.App.Models.ICoopLayoutDetailSettingModel" />
    public class CoopLayoutDetailSettingModel : BaseModel, ICoopLayoutDetailSettingModel
    {
        /// <summary>
        /// The facility
        /// </summary>
        private MstFacilityEntity facility;

        /// <summary>
        /// The coop layout details
        /// </summary>
        private List<MstCoopLayoutDetailEntity> coopLayoutDetails;

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
        public List<MstCoopLayoutDetailEntity> CoopLayoutDetails
        {
            get
            {
                return coopLayoutDetails;
            }
            set
            {
                coopLayoutDetails = value;
                NotifyPropertyChanged();
            }
        }

        /// <summary>
        /// Clears the data.
        /// </summary>
        public override void ClearData()
        {
            Facility = null;
            CoopLayoutDetails = null;
        }
    }
}
