// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 05-26-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-26-2021
// ***********************************************************************
// <copyright file="MstCoopIniService.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.Service.Configuration;
using CoopSettingTool.Service.Extendsions;
using CoopSettingTool.Service.Models;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace CoopSettingTool.Service
{
    /// <summary>
    /// Class MstCoopIniService.
    /// Implements the <see cref="CoopSettingTool.Service.BaseService{CoopSettingTool.Service.Models.MstCoopIniEntity}" />
    /// Implements the <see cref="CoopSettingTool.Service.IMstCoopIniService" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.BaseService{CoopSettingTool.Service.Models.MstCoopIniEntity}" />
    /// <seealso cref="CoopSettingTool.Service.IMstCoopIniService" />
    public class MstCoopIniService : BaseService<MstCoopIniEntity>, IMstCoopIniService
    {
        /// <summary>
        /// Gets the MST coop ini.
        /// </summary>
        /// <param name="facilityCd">The facility cd.</param>
        /// <returns>GetMstCoopIniResponse.</returns>
        public async Task<GetMstCoopIniResponse> GetMstCoopIni(string facilityCd)
        {
            GetMstCoopIniResponse res = (await ServerAccess.GetInstance().GetAsync<List<MstCoopIniEntity>>(Constant.GET_MST_COOP_INI + "/" + facilityCd, null)).ToClass<List<MstCoopIniEntity>, GetMstCoopIniResponse>();
            return res;
        }

        /// <summary>
        /// Submits the MST coop ini.
        /// </summary>
        /// <param name="inputEntity">The input entity.</param>
        /// <returns>Task&lt;UpdateMstCoopIniResponse&gt;.</returns>
        public async Task<UpdateMstCoopIniResponse> SubmitMstCoopIni(MstCoopIniEntity inputEntity)
        {
            BaseResponse<bool> res = (await ServerAccess.GetInstance().PostAsync<bool>(Constant.SUBMIT_MST_COOP_INI, inputEntity, true, true));
            UpdateMstCoopIniResponse result = new UpdateMstCoopIniResponse()
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
