// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 06-14-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 06-14-2021
// ***********************************************************************
// <copyright file="SysReleaseInfoService.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.Service.Configuration;
using CoopSettingTool.Service.Extendsions;
using CoopSettingTool.Service.Models;
using CoopSettingTool.Service.Models.Responses;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace CoopSettingTool.Service
{
    /// <summary>
    /// Class SysReleaseInfoService.
    /// Implements the <see cref="CoopSettingTool.Service.BaseService{CoopSettingTool.Service.Models.SysReleaseInfoEntity}" />
    /// Implements the <see cref="CoopSettingTool.Service.ISysReleaseInfoService" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.BaseService{CoopSettingTool.Service.Models.SysReleaseInfoEntity}" />
    /// <seealso cref="CoopSettingTool.Service.ISysReleaseInfoService" />
    public class SysReleaseInfoService : BaseService<SysReleaseInfoEntity>, ISysReleaseInfoService
    {
        /// <summary>
        /// Gets all MST facility.
        /// </summary>
        /// <returns>Task&lt;GetAllSysReleaseInfoResponse&gt;.</returns>
        public async Task<GetAllSysReleaseInfoResponse> GetAllSysReleaseInfo()
        {
            GetAllSysReleaseInfoResponse res = (await ServerAccess.GetInstance().GetAsync<List<SysReleaseInfoEntity>>(Constant.GET_ALL_SYS_RELEASE_INFO, null)).ToClass<List<SysReleaseInfoEntity>, GetAllSysReleaseInfoResponse>();
            return res;
        }
    }
}
