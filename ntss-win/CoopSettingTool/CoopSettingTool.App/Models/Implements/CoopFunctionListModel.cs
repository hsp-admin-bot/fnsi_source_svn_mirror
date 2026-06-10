// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-23-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-24-2021
// ***********************************************************************
// <copyright file="CoopFunctionListModel.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.Service.Models;
using System.Collections.Generic;

namespace CoopSettingTool.App.Models
{
    /// <summary>
    /// Class CoopFunctionListModel.
    /// Implements the <see cref="CoopSettingTool.App.Models.BaseModel" />
    /// Implements the <see cref="CoopSettingTool.App.Models.ICoopFunctionListModel" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Models.BaseModel" />
    /// <seealso cref="CoopSettingTool.App.Models.ICoopFunctionListModel" />
    public class CoopFunctionListModel : BaseModel, ICoopFunctionListModel
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
        /// The selected coop function index
        /// </summary>
        private int selectedCoopFunctionIndex;

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
        /// Gets or sets the index of the selected coop function.
        /// </summary>
        /// <value>The index of the selected coop function.</value>
        public int SelectedCoopFunctionIndex
        {
            get
            {
                return selectedCoopFunctionIndex;
            }
            set
            {
                selectedCoopFunctionIndex = value;
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
            SelectedCoopFunctionIndex = -1;
        }
    }
}
