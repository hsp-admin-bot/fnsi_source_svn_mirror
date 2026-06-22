// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-20-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-21-2021
// ***********************************************************************
// <copyright file="CoopInstallModel.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.Service.Models;
using System.Collections.Generic;
using System.Windows.Forms;

namespace CoopSettingTool.App.Models
{
    /// <summary>
    /// Class CoopInstallModel.
    /// Implements the <see cref="CoopSettingTool.App.Models.BaseModel" />
    /// Implements the <see cref="CoopSettingTool.App.Models.ICoopInstallModel" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Models.BaseModel" />
    /// <seealso cref="CoopSettingTool.App.Models.ICoopInstallModel" />
    public class CoopInstallModel : BaseModel, ICoopInstallModel
    {
        /// <summary>
        /// The selected facility
        /// </summary>
        private MstFacilityEntity selectedFacility;

        /// <summary>
        /// The coop facility artifacts
        /// </summary>
        private List<MstCoopFacilityEntity> coopFacilityArtifacts;

        /// <summary>
        /// The selected artifact indices
        /// </summary>
        private List<int> selectedArtifactIndices;

        /// <summary>
        /// Gets or sets the selected facility.
        /// </summary>
        /// <value>The selected facility.</value>
        public MstFacilityEntity Facility
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
        /// Gets or sets the coop facility artifacts.
        /// </summary>
        /// <value>The coop facility artifacts.</value>
        public List<MstCoopFacilityEntity> CoopFacilityArtifacts
        {
            get
            {
                return coopFacilityArtifacts;
            }
            set
            {
                coopFacilityArtifacts = value;
                NotifyPropertyChanged();
            }
        }

        /// <summary>
        /// Gets or sets the selected artifact indices.
        /// </summary>
        /// <value>The selected artifact indices.</value>
        public List<int> SelectedArtifactIndices
        {
            get
            {
                return selectedArtifactIndices;
            }
            set
            {
                selectedArtifactIndices = value; NotifyPropertyChanged();
            }
        }

        /// <summary>
        /// Clears the data.
        /// </summary>
        public override void ClearData()
        {
            Facility = null;
            CoopFacilityArtifacts = null;
            SelectedArtifactIndices = null;
        }
    }
}
