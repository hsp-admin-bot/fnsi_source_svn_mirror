// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-13-2022
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-14-2022
// ***********************************************************************
// <copyright file="CoopLayoutSettingModel.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************

using CoopSettingTool.Service.Models;
using System.Collections.Generic;

namespace CoopSettingTool.App.Models
{

    /// <summary>
    /// Class CoopLayoutSettingModel.
    /// Implements the <see cref="CoopSettingTool.App.Models.BaseModel" />
    /// Implements the <see cref="CoopSettingTool.App.Models.ICoopLayoutSettingModel" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Models.BaseModel" />
    /// <seealso cref="CoopSettingTool.App.Models.ICoopLayoutSettingModel" />
    public class CoopLayoutSettingModel : BaseModel, ICoopLayoutSettingModel
    {
        /// <summary>
        /// The facility
        /// </summary>
        private MstFacilityEntity facility;

        /// <summary>
        /// The coop facility
        /// </summary>
        private List<MstCoopLayoutEntity> coopLayouts;

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
        public List<MstCoopLayoutEntity> CoopLayouts
        {
            get
            {
                return coopLayouts;
            }
            set
            {
                coopLayouts = value;
                NotifyPropertyChanged();
            }
        }

        /// <summary>
        /// Clears the data.
        /// </summary>
        public override void ClearData()
        {
            Facility = null;
            CoopLayouts = null;
        }
    }
}
