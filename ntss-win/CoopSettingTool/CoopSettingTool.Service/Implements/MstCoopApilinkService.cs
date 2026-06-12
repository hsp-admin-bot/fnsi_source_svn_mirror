// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 06-09-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 06-22-2021
// ***********************************************************************
// <copyright file="MstCoopApilinkService.cs" company="">
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
    /// Class MstCoopApilinkService.
    /// Implements the <see cref="CoopSettingTool.Service.BaseService{CoopSettingTool.Service.Models.MstCoopApilinkEntity}" />
    /// Implements the <see cref="CoopSettingTool.Service.IMstCoopApilinkService" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.BaseService{CoopSettingTool.Service.Models.MstCoopApilinkEntity}" />
    /// <seealso cref="CoopSettingTool.Service.IMstCoopApilinkService" />
    public class MstCoopApilinkService : BaseService<MstCoopApilinkEntity>, IMstCoopApilinkService
    {
        /// <summary>
        /// Creates the or update MST coop apilink.
        /// </summary>
        /// <param name="inputEntity">The input entity.</param>
        /// <returns>Task&lt;CreateOrUpdateMstCoopApilinkResponse&gt;.</returns>
        public async Task<SubmitMstCoopApilinkResponse> SubmitMstCoopApilink(MstCoopApilinkEntity inputEntity)
        {
            BaseResponse<bool> res = (await ServerAccess.GetInstance().PostAsync<bool>(Constant.SUBMIT_MST_COOP_APILINK, inputEntity, true, true));
            SubmitMstCoopApilinkResponse result = new SubmitMstCoopApilinkResponse()
            {
                Data = res.Data,
                Error = res.Error,
                Exception = res.Exception,
                StatusCode = res.StatusCode
            };
            return result;
        }

        /// <summary>
        /// Gets the MST coop apilink.
        /// </summary>
        /// <param name="facilityCd">The facility cd.</param>
        /// <returns>Task&lt;GetMstCoopApilinkResponse&gt;.</returns>
        public async Task<GetMstCoopApilinkResponse> GetMstCoopApilink(string facilityCd)
        {
            GetMstCoopApilinkResponse res = (await ServerAccess.GetInstance().GetAsync<List<MstCoopApilinkEntity>>(Constant.GET_MST_COOP_APILINK + "/" + facilityCd, null)).ToClass<List<MstCoopApilinkEntity>, GetMstCoopApilinkResponse>();
            return res;
        }

        /// <summary>
        /// Gets the source MST coop apilink.
        /// </summary>
        /// <param name="coopVersion">The coop version.</param>
        /// <param name="coopCd">The coop cd.</param>
        /// <returns>Task&lt;GetMstCoopApilinkResponse&gt;.</returns>
        public async Task<GetMstCoopApilinkResponse> GetSourceMstCoopApilink(string coopVersion, string coopCd)
        {
            MstCoopApilinkEntity condition = new MstCoopApilinkEntity()
            {
                CoopVersion = coopVersion,
                CoopCd = coopCd
            };

            GetMstCoopApilinkResponse res = (await ServerAccess.GetInstance().PostAsync<List<MstCoopApilinkEntity>>(Constant.GET_SOURCE_MST_COOP_APILINK, condition, true, true)).ToClass<List<MstCoopApilinkEntity>, GetMstCoopApilinkResponse>();
            return res;
        }
    }
}
