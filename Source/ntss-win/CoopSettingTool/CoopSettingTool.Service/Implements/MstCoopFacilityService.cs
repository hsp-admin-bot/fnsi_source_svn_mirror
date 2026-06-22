// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 04-20-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-25-2021
// ***********************************************************************
// <copyright file="MstCoopFacilityService.cs" company="">
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
    /// Class MstCoopFacilityService.
    /// Implements the <see cref="CoopSettingTool.Service.BaseService{CoopSettingTool.Service.Models.MstCoopFacilityEntity}" />
    /// Implements the <see cref="CoopSettingTool.Service.IMstCoopFacilityService" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.BaseService{CoopSettingTool.Service.Models.MstCoopFacilityEntity}" />
    /// <seealso cref="CoopSettingTool.Service.IMstCoopFacilityService" />
    public class MstCoopFacilityService : BaseService<MstCoopFacilityEntity>, IMstCoopFacilityService
    {
        /// <summary>
        /// Gets the newest MST coop facility control no list.
        /// </summary>
        /// <returns>CtlNo list</returns>
        public async Task<BaseResponse<List<string>>> GetNewestMstCoopFacilityCtlNoList()
        {
            var res = (await ServerAccess.GetInstance().GetAsync<List<string>>(Constant.GET_NEWEST_MST_COOP_FACILITY_CTL_NO, null, true, false));

            return res;
        }

        /// <summary>
        /// Gets the MST coop facility.
        /// </summary>
        /// <param name="param">The parameter.</param>
        /// <returns>GetMstCoopFacilityResponse.</returns>
        public async Task<GetMstCoopFacilityResponse> GetMstCoopFacility(GetMstCoopFacilityRequest param)
        {
            GetMstCoopFacilityResponse result = (await ServerAccess.GetInstance().PostAsync<BaseContent<List<MstCoopFacilityEntity>>>(Constant.GET_MST_COOP_FACILITY, param, true, true)).ToClass<BaseContent<List<MstCoopFacilityEntity>>, GetMstCoopFacilityResponse>();
            return result;
        }

        /// <summary>
        /// Submits the MST coop facility.
        /// </summary>
        /// <param name="inputEntity">The input entity.</param>
        /// <returns>Task&lt;SubmitMstCoopFacilityResponse&gt;.</returns>
        public async Task<SubmitMstCoopFacilityResponse> SubmitMstCoopFacility(MstCoopFacilityEntity inputEntity)
        {
            BaseResponse<bool> res = (await ServerAccess.GetInstance().PostAsync<bool>(Constant.SUBMIT_MST_COOP_FACILITY, inputEntity, true, true));
            SubmitMstCoopFacilityResponse result = new SubmitMstCoopFacilityResponse()
            {
                Data = res.Data,
                Error = res.Error,
                Exception = res.Exception,
                StatusCode = res.StatusCode
            };
            return result;
        }

        /// <summary>
        /// Uninstalls the coop.
        /// </summary>
        /// <param name="facilityCd">The facility cd.</param>
        /// <returns>Task&lt;UninstallCoopResponse&gt;.</returns>
        public async Task<UninstallCoopResponse> UninstallCoop(string facilityCd)
        {
            BaseResponse<bool> res = (await ServerAccess.GetInstance().DeleteAsync<bool>(Constant.UNINSTALL_COOP + "/" + facilityCd, null, true, false));
            UninstallCoopResponse result = new UninstallCoopResponse()
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
