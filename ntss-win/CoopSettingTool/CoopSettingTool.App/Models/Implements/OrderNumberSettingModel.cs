// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 05-24-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-25-2021
// ***********************************************************************
// <copyright file="OrderNumberSettingModel.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.Service.Models;
using System.Collections.Generic;

namespace CoopSettingTool.App.Models
{
    /// <summary>
    /// Class OrderNumberSettingModel.
    /// Implements the <see cref="CoopSettingTool.App.Models.BaseModel" />
    /// Implements the <see cref="CoopSettingTool.App.Models.IOrderNumberSettingModel" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Models.BaseModel" />
    /// <seealso cref="CoopSettingTool.App.Models.IOrderNumberSettingModel" />
    public class OrderNumberSettingModel : BaseModel, IOrderNumberSettingModel
    {
        /// <summary>
        /// The facility
        /// </summary>
        private MstFacilityEntity facility;

        /// <summary>
        /// The system coop no list
        /// </summary>
        private List<SysCoopNoEntity> sysCoopNoList;

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
        /// Gets or sets the system coop no list.
        /// </summary>
        /// <value>The system coop no list.</value>
        public List<SysCoopNoEntity> SysCoopNoList
        {
            get
            {
                return sysCoopNoList;
            }
            set
            {
                sysCoopNoList = value;
                NotifyPropertyChanged();
            }
        }

        /// <summary>
        /// Adds the blank order number setting.
        /// </summary>
        public void AddBlankOrderNumberSetting()
        {
            sysCoopNoList.Add(new SysCoopNoEntity(this.facility.FacilityCd));
            NotifyPropertyChanged("SysCoopNoList");
        }

        /// <summary>
        /// Clears the data.
        /// </summary>
        public override void ClearData()
        {
            SysCoopNoList = null;
            Facility = null;
        }
    }
}
