// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-19-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-19-2021
// ***********************************************************************
// <copyright file="SelectFacilityModel.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.Service.Models;
using System.Collections.Generic;

namespace CoopSettingTool.App.Models
{
    /// <summary>
    /// Class SelectFacilityModel.
    /// Implements the <see cref="CoopSettingTool.App.Models.BaseModel" />
    /// Implements the <see cref="CoopSettingTool.App.Models.ISelectFacilityModel" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Models.BaseModel" />
    /// <seealso cref="CoopSettingTool.App.Models.ISelectFacilityModel" />
    public class SelectFacilityModel : BaseModel, ISelectFacilityModel
    {
        /// <summary>
        /// The selected facility
        /// </summary>
        private MstFacilityEntity selectedFacility;

        /// <summary>
        /// The facilities
        /// </summary>
        private List<MstFacilityEntity> facilities;

        /// <summary>
        /// Gets or sets the selected facility.
        /// </summary>
        /// <value>The selected facility.</value>
        public MstFacilityEntity SelectedFacility
        {
            get
            {
                return selectedFacility;
            }
            set
            {
                selectedFacility = value;
                NotifyPropertyChanged();
            }
        }

        /// <summary>
        /// Gets or sets the facilities.
        /// </summary>
        /// <value>The facilities.</value>
        public List<MstFacilityEntity> Facilities
        {
            get
            {
                return facilities;
            }
            set
            {
                facilities = value;
                NotifyPropertyChanged();
            }
        }

        /// <summary>
        /// Clears the data.
        /// </summary>
        public override void ClearData()
        {
            Facilities = null;
            SelectedFacility = null;
        }
    }
}
