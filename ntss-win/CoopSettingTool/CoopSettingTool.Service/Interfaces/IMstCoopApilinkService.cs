// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 06-09-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 06-09-2021
// ***********************************************************************
// <copyright file="IMstCoopApilinkService.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.Service.Models;
using System.Threading.Tasks;

namespace CoopSettingTool.Service
{
    /// <summary>
    /// Interface IMstCoopApilinkService
    /// Implements the <see cref="CoopSettingTool.Service.IBaseService{CoopSettingTool.Service.Models.MstCoopApilinkEntity}" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.IBaseService{CoopSettingTool.Service.Models.MstCoopApilinkEntity}" />
    public interface IMstCoopApilinkService : IBaseService<MstCoopApilinkEntity>
    {
        /// <summary>
        /// Gets the MST coop apilink.
        /// </summary>
        /// <param name="facilityCd">The facility cd.</param>
        /// <returns>Task&lt;GetMstCoopApilinkResponse&gt;.</returns>
        Task<GetMstCoopApilinkResponse> GetMstCoopApilink(string facilityCd);

        /// <summary>
        /// Gets the source MST coop apilink.
        /// </summary>
        /// <param name="coopVersion">The coop version.</param>
        /// <param name="coopCd">The coop cd.</param>
        /// <returns>Task&lt;GetMstCoopApilinkResponse&gt;.</returns>
        Task<GetMstCoopApilinkResponse> GetSourceMstCoopApilink(string coopVersion, string coopCd);

        /// <summary>
        /// Creates the or update MST coop apilink.
        /// </summary>
        /// <param name="inputEntity">The input entity.</param>
        /// <returns>Task&lt;CreateOrUpdateMstCoopApilinkResponse&gt;.</returns>
        Task<SubmitMstCoopApilinkResponse> SubmitMstCoopApilink(MstCoopApilinkEntity inputEntity);
    }
}
