// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 05-24-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-24-2021
// ***********************************************************************
// <copyright file="ISysCoopNoService.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.Service.Models;
using System.Threading.Tasks;

namespace CoopSettingTool.Service
{
    /// <summary>
    /// Interface ISysCoopNoService
    /// Implements the <see cref="CoopSettingTool.Service.IBaseService{CoopSettingTool.Service.Models.SysCoopNoEntity}" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.IBaseService{CoopSettingTool.Service.Models.SysCoopNoEntity}" />
    public interface ISysCoopNoService : IBaseService<SysCoopNoEntity>
    {
        /// <summary>
        /// Gets the system coop no.
        /// </summary>
        /// <param name="facilityCd">The facility cd.</param>
        /// <returns>Task&lt;GetSysCoopNoResponse&gt;.</returns>
        Task<GetSysCoopNoResponse> GetSysCoopNo(string facilityCd);

        /// <summary>
        /// Gets the source system coop no.
        /// </summary>
        /// <param name="coopVersion">The coop version.</param>
        /// <returns>Task&lt;GetSysCoopNoResponse&gt;.</returns>
        Task<GetSysCoopNoResponse> GetSourceSysCoopNo(string coopVersion);

        /// <summary>
        /// Updates the system coop no.
        /// </summary>
        /// <param name="inputEntity">The input entity.</param>
        /// <returns>Task&lt;UpdateSysCoopNoResponse&gt;.</returns>
        Task<UpdateSysCoopNoResponse> SubmitSysCoopNo(SysCoopNoEntity inputEntity);
    }
}
