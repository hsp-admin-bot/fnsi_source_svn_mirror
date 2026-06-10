// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-14-2022
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-14-2022
// ***********************************************************************
// <copyright file="CoopDistributeSettingModel.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved
// </copyright>
// <summary></summary>
// ***********************************************************************

using CoopSettingTool.Service.Models;
using System.Collections.Generic;

namespace CoopSettingTool.App.Models
{

    /// <summary>
    /// Class CoopDistributeSettingModel.
    /// Implements the <see cref="CoopSettingTool.App.Models.BaseModel" />
    /// Implements the <see cref="CoopSettingTool.App.Models.ICoopDistributeSettingModel" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Models.BaseModel" />
    /// <seealso cref="CoopSettingTool.App.Models.ICoopDistributeSettingModel" />
    public class CoopDistributeSettingModel : BaseModel, ICoopDistributeSettingModel
    {
        /// <summary>
        /// The facility
        /// </summary>
        private MstFacilityEntity facility;


        /// <summary>
        /// The coop distributes
        /// </summary>
        private List<MstCoopDistributeEntity> coopDistributes;


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
        /// Gets or sets the coop distributes.
        /// </summary>
        /// <value>The coop distributes.</value>
        public List<MstCoopDistributeEntity> CoopDistributes
        {
            get
            {
                return coopDistributes;
            }
            set
            {
                coopDistributes = value;
                NotifyPropertyChanged();
            }
        }


        /// <summary>
        /// Clears the data.
        /// </summary>
        public override void ClearData()
        {
            Facility = null;
            CoopDistributes = null;
        }
    }
}
