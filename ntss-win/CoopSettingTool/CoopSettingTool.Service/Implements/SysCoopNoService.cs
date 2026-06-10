// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 05-24-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-25-2021
// ***********************************************************************
// <copyright file="SysCoopNoService.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.Service.Configuration;
using CoopSettingTool.Service.Extendsions;
using CoopSettingTool.Service.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading.Tasks;

namespace CoopSettingTool.Service
{
    /// <summary>
    /// Class SysCoopNoService.
    /// Implements the <see cref="CoopSettingTool.Service.BaseService{CoopSettingTool.Service.Models.SysCoopNoEntity}" />
    /// Implements the <see cref="CoopSettingTool.Service.ISysCoopNoService" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.BaseService{CoopSettingTool.Service.Models.SysCoopNoEntity}" />
    /// <seealso cref="CoopSettingTool.Service.ISysCoopNoService" />
    public class SysCoopNoService : BaseService<SysCoopNoEntity>, ISysCoopNoService
    {
        /// <summary>
        /// Gets the system coop no.
        /// </summary>
        /// <param name="facilityCd">The facility cd.</param>
        /// <returns>GetSysCoopNoResponse.</returns>
        public async Task<GetSysCoopNoResponse> GetSysCoopNo(string facilityCd)
        {
            GetSysCoopNoResponse res = (await ServerAccess.GetInstance().GetAsync<List<SysCoopNoEntity>>(Constant.GET_SYS_COOP_NO_BY_FACILITY + "/" + facilityCd, null)).ToClass<List<SysCoopNoEntity>, GetSysCoopNoResponse>();
            return res;
        }

        /// <summary>
        /// Updates the system coop no.
        /// </summary>
        /// <param name="inputEntity">The input entity.</param>
        /// <returns>Task&lt;UpdateSysCoopNoResponse&gt;.</returns>
        public async Task<UpdateSysCoopNoResponse> SubmitSysCoopNo(SysCoopNoEntity inputEntity)
        {
            BaseResponse<bool> res = (await ServerAccess.GetInstance().PostAsync<bool>(Constant.SUBMIT_SYS_COOP_NO, inputEntity, true, true));
            UpdateSysCoopNoResponse result = new UpdateSysCoopNoResponse()
            {
                Data = res.Data,
                Error = res.Error,
                Exception = res.Exception,
                StatusCode = res.StatusCode
            };
            return result;
        }
    }
}
