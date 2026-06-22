// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 04-16-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-20-2021
// ***********************************************************************
// <copyright file="IMstFacilityService.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.Service.Models;
using System.Threading.Tasks;

namespace CoopSettingTool.Service
{
    /// <summary>
    /// Interface IMstFacilityService
    /// Implements the <see cref="CoopSettingTool.Service.IBaseService{CoopSettingTool.Service.Models.MstFacilityEntity}" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.IBaseService{CoopSettingTool.Service.Models.MstFacilityEntity}" />
    public interface IMstFacilityService : IBaseService<MstFacilityEntity>
    {
        /// <summary>
        /// Gets the MST facility.
        /// </summary>
        /// <param name="facilityCd">The facility cd.</param>
        /// <returns>Task&lt;GetMstFacilityResponse&gt;.</returns>
        Task<GetMstFacilityResponse> GetMstFacility(string facilityCd);
        /// <summary>
        /// Gets all MST facility.
        /// </summary>
        /// <returns>Task&lt;GetAllMstFacilityResponse&gt;.</returns>
        Task<GetAllMstFacilityResponse> GetAllMstFacility();
    }
}
