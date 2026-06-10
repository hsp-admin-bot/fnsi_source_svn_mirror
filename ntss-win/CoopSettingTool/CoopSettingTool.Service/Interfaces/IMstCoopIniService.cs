// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 05-26-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-27-2021
// ***********************************************************************
// <copyright file="IMstCoopIniService.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.Service.Models;
using System.Threading.Tasks;

namespace CoopSettingTool.Service
{
    /// <summary>
    /// Interface IMstCoopIniService
    /// Implements the <see cref="CoopSettingTool.Service.IBaseService{CoopSettingTool.Service.Models.MstCoopIniEntity}" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.IBaseService{CoopSettingTool.Service.Models.MstCoopIniEntity}" />
    public interface IMstCoopIniService : IBaseService<MstCoopIniEntity>
    {
        /// <summary>
        /// Gets the MST coop ini.
        /// </summary>
        /// <param name="facilityCd">The facility cd.</param>
        /// <returns>Task&lt;GetMstCoopIniResponse&gt;.</returns>
        Task<GetMstCoopIniResponse> GetMstCoopIni(string facilityCd);

        /// <summary>
        /// Submits the MST coop ini.
        /// </summary>
        /// <param name="inputEntity">The input entity.</param>
        /// <returns>Task&lt;UpdateMstCoopIniResponse&gt;.</returns>
        Task<UpdateMstCoopIniResponse> SubmitMstCoopIni(MstCoopIniEntity inputEntity);
    }
}
