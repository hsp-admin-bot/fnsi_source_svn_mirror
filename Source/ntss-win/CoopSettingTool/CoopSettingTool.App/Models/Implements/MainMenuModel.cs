// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-19-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-19-2021
// ***********************************************************************
// <copyright file="MainMenuModel.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.Service.Models;

namespace CoopSettingTool.App.Models
{
    /// <summary>
    /// Class MainMenuModel.
    /// Implements the <see cref="CoopSettingTool.App.Models.BaseModel" />
    /// Implements the <see cref="CoopSettingTool.App.Models.IMainMenuModel" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Models.BaseModel" />
    /// <seealso cref="CoopSettingTool.App.Models.IMainMenuModel" />
    public class MainMenuModel : BaseModel, IMainMenuModel
    {
        /// <summary>
        /// The selected facility
        /// </summary>
        private MstFacilityEntity selectedFacility;

        /// <summary>
        /// Is installed flag
        /// </summary>
        private bool isInstalled;

        /// <summary>
        /// Gets or sets the selected facility.
        /// </summary>
        /// <value>The selected facility.</value>
        public MstFacilityEntity SelectedFacility
        {
            get => selectedFacility;
            set
            {
                selectedFacility = value;
                NotifyPropertyChanged();
            }
        }

        /// <summary>
        /// Is installed flag
        /// </summary>
        public bool IsInstalled
        {
            get 
            {
                return isInstalled; 
            }
            set
            {
                isInstalled = value;
                NotifyPropertyChanged();
            }
        }

        /// <summary>
        /// Clears the data.
        /// </summary>
        public override void ClearData()
        {
            IsInstalled = false;
            SelectedFacility = null;
        }
    }
}
