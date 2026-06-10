// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 05-31-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-31-2021
// ***********************************************************************
// <copyright file="CoopSettingModel.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.Service.Models;
using System.Collections.Generic;

namespace CoopSettingTool.App.Models
{
    /// <summary>
    /// Class CoopSettingModel.
    /// Implements the <see cref="CoopSettingTool.App.Models.BaseModel" />
    /// Implements the <see cref="CoopSettingTool.App.Models.ICoopSettingModel" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Models.BaseModel" />
    /// <seealso cref="CoopSettingTool.App.Models.ICoopSettingModel" />
    public class CoopSettingModel : BaseModel, ICoopSettingModel
    {
        /// <summary>
        /// The facility
        /// </summary>
        private MstFacilityEntity facility;

        /// <summary>
        /// The coop ini
        /// </summary>
        private MstCoopIniEntity coopIni;

        /// <summary>
        /// The coop ini infos
        /// </summary>
        private List<CoopIniInfo> coopIniInfos;

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
        /// Gets or sets the coop ini list.
        /// </summary>
        /// <value>The coop ini list.</value>
        public MstCoopIniEntity CoopIni
        {
            get
            {
                return coopIni;
            }
            set
            {
                coopIni = value;
                NotifyPropertyChanged();
            }
        }

        /// <summary>
        /// Gets or sets the coop ini list.
        /// </summary>
        /// <value>The coop ini list.</value>
        public List<CoopIniInfo> CoopIniInfos
        {
            get
            {
                return coopIniInfos;
            }
            set
            {
                coopIniInfos = value;
                NotifyPropertyChanged();
            }
        }

        /// <summary>
        /// AddBlankSetting
        /// </summary>
        public void AddBlankSetting(int addIndex)
        {
            this.coopIniInfos.Insert(addIndex, new CoopIniInfo());
            NotifyPropertyChanged("CoopIniInfos");
        }

        /// <summary>
        /// RemoveSetting
        /// </summary>
        /// <param name="removeList"></param>
        public void OnOffSetting(List<CoopIniInfo> removeList)
        {
            string s = removeList[0].IsEffect == "0" ? "1" : "0";

            for (int i = 0; i < removeList.Count; i++)
            {
                removeList[i].IsEffect = s;
            }

            NotifyPropertyChanged("CoopIniInfos");
        }

        /// <summary>
        /// Clears the data.
        /// </summary>
        public override void ClearData()
        {
            CoopIniInfos = null;
            CoopIni = null;
            Facility = null;
        }
    }
}
