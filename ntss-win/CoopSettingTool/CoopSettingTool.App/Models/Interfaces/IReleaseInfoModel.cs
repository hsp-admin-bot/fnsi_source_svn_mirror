// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 06-14-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 06-14-2021
// ***********************************************************************
// <copyright file="IReleaseInfoModel.cs" company="">
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
    /// Interface IReleaseInfoModel
    /// Implements the <see cref="CoopSettingTool.App.Models.IBaseModel" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Models.IBaseModel" />
    public interface IReleaseInfoModel : IBaseModel
    {
        List<SysReleaseInfoEntity> ReleaseInfos { get; set; }
    }
}
