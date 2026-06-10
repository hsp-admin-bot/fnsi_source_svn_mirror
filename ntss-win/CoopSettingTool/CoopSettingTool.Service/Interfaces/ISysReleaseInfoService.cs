// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 06-14-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 06-14-2021
// ***********************************************************************
// <copyright file="ISysReleaseInfoService.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.Service.Models.Responses;
using System.Threading.Tasks;

namespace CoopSettingTool.Service
{
    /// <summary>
    /// Interface ISysReleaseInfoService
    /// </summary>
    public interface ISysReleaseInfoService
    {
        /// <summary>
        /// Gets all MST facility.
        /// </summary>
        /// <returns>Task&lt;GetAllSysReleaseInfoResponse&gt;.</returns>
        Task<GetAllSysReleaseInfoResponse> GetAllSysReleaseInfo();
    }
}
