// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 05-25-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-25-2021
// ***********************************************************************
// <copyright file="IfEdgeSettingModel.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.Service.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoopSettingTool.App.Models
{
    /// <summary>
    /// Class IfEdgeSettingModel.
    /// Implements the <see cref="CoopSettingTool.App.Models.BaseModel" />
    /// Implements the <see cref="CoopSettingTool.App.Models.IIfEdgeSettingModel" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Models.BaseModel" />
    /// <seealso cref="CoopSettingTool.App.Models.IIfEdgeSettingModel" />
    public class IfEdgeSettingModel : BaseModel, IIfEdgeSettingModel
    {
        /// <summary>
        /// The facility
        /// </summary>
        private MstFacilityEntity facility;

        /// <summary>
        /// If edge list
        /// </summary>
        private List<MstIfEdgeEntity> ifEdgeList;

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
        /// Gets or sets if edge list.
        /// </summary>
        /// <value>If edge list.</value>
        public List<MstIfEdgeEntity> IfEdgeList
        {
            get
            {
                return ifEdgeList;
            }
            set
            {
                ifEdgeList = value;
                NotifyPropertyChanged();
            }
        }

        /// <summary>
        /// Adds the new if edge.
        /// </summary>
        public void AddNewIfEdge()
        {
            ifEdgeList.Add(new MstIfEdgeEntity(this.facility.FacilityCd));
            NotifyPropertyChanged("IfEdgeList");
        }

        /// <summary>
        /// Clears the data.
        /// </summary>
        public override void ClearData()
        {
            IfEdgeList = null;
            Facility = null;
        }
    }
}
