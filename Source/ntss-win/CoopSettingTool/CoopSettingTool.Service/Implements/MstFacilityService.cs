// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 04-19-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-20-2021
// ***********************************************************************
// <copyright file="MstFacilityService.cs" company="">
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
    /// Class MstFacilityService.
    /// Implements the <see cref="CoopSettingTool.Service.BaseService{CoopSettingTool.Service.Models.MstFacilityEntity}" />
    /// Implements the <see cref="CoopSettingTool.Service.IMstFacilityService" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.BaseService{CoopSettingTool.Service.Models.MstFacilityEntity}" />
    /// <seealso cref="CoopSettingTool.Service.IMstFacilityService" />
    public class MstFacilityService : BaseService<MstFacilityEntity>, IMstFacilityService
    {
        /// <summary>
        /// Gets the MST facility.
        /// </summary>
        /// <param name="facilityCd">The facility cd.</param>
        /// <returns>GetMstFacilityResponse.</returns>
        public async Task<GetMstFacilityResponse> GetMstFacility(string facilityCd)
        {
            GetMstFacilityResponse res = (await ServerAccess.GetInstance().GetAsync<MstFacilityEntity>(Constant.GET_ALL_FACILITY + "/" + facilityCd, null)).ToClass<MstFacilityEntity, GetMstFacilityResponse>();
            return res;
        }

        /// <summary>
        /// Gets all MST facility.
        /// </summary>
        /// <returns>GetAllMstFacilityResponse.</returns>
        public async Task<GetAllMstFacilityResponse> GetAllMstFacility()
        {
            GetAllMstFacilityResponse res = (await ServerAccess.GetInstance().GetAsync<List<MstFacilityEntity>>(Constant.GET_ALL_FACILITY, null)).ToClass<List<MstFacilityEntity>, GetAllMstFacilityResponse>();
            return res;
        }
    }
}
