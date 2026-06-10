// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 06-14-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 06-14-2021
// ***********************************************************************
// <copyright file="ReleaseInfoModel.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.Service.Models;
using System.Collections.Generic;

namespace CoopSettingTool.App.Models
{
    /// <summary>
    /// Class ReleaseInfoModel.
    /// Implements the <see cref="CoopSettingTool.App.Models.BaseModel" />
    /// Implements the <see cref="CoopSettingTool.App.Models.IReleaseInfoModel" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Models.BaseModel" />
    /// <seealso cref="CoopSettingTool.App.Models.IReleaseInfoModel" />
    public class ReleaseInfoModel : BaseModel, IReleaseInfoModel
    {
        /// <summary>
        /// The release infos
        /// </summary>
        private List<SysReleaseInfoEntity> releaseInfos;

        /// <summary>
        /// Gets or sets the release infos.
        /// </summary>
        /// <value>The release infos.</value>
        public List<SysReleaseInfoEntity> ReleaseInfos
        {
            get
            {
             return releaseInfos;
            }
            set {
                releaseInfos = value;
                NotifyPropertyChanged();
            }
        }
    }
}
