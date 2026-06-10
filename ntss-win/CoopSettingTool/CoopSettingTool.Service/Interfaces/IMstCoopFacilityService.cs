// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 04-20-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-31-2021
// ***********************************************************************
// <copyright file="IMstCoopFacilityService.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.Service.Models;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace CoopSettingTool.Service
{
    /// <summary>
    /// Interface IMstCoopFacilityService
    /// Implements the <see cref="CoopSettingTool.Service.IBaseService{CoopSettingTool.Service.Models.MstCoopFacilityEntity}" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.IBaseService{CoopSettingTool.Service.Models.MstCoopFacilityEntity}" />
    public interface IMstCoopFacilityService : IBaseService<MstCoopFacilityEntity>
    {
        /// <summary>
        /// Gets the newest MST coop facility control no list.
        /// </summary>
        /// <returns></returns>
        Task<BaseResponse<List<string>>> GetNewestMstCoopFacilityCtlNoList();

        /// <summary>
        /// Gets the MST coop facility.
        /// </summary>
        /// <param name="param">The parameter.</param>
        /// <returns>Task&lt;GetMstCoopFacilityResponse&gt;.</returns>
        Task<GetMstCoopFacilityResponse> GetMstCoopFacility(GetMstCoopFacilityRequest param);

        /// <summary>
        /// Submits the MST coop facility.
        /// </summary>
        /// <param name="inputEntity">The input entity.</param>
        /// <returns>Task&lt;SubmitMstCoopFacilityResponse&gt;.</returns>
        Task<SubmitMstCoopFacilityResponse> SubmitMstCoopFacility(MstCoopFacilityEntity inputEntity);

        /// <summary>
        /// Uninstalls the coop.
        /// </summary>
        /// <param name="facilityCd">The facility cd.</param>
        /// <returns>Task&lt;UninstallCoopResponse&gt;.</returns>
        Task<UninstallCoopResponse> UninstallCoop(string facilityCd);
    }
}
