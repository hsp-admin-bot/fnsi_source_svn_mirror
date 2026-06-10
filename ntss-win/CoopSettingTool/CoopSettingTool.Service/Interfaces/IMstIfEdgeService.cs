// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 05-25-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-25-2021
// ***********************************************************************
// <copyright file="IMstIfEdgeService.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.Service.Models;
using System.Threading.Tasks;

namespace CoopSettingTool.Service
{
    /// <summary>
    /// Interface IMstIfEdgeService
    /// Implements the <see cref="CoopSettingTool.Service.IBaseService{CoopSettingTool.Service.Models.MstIfEdgeEntity}" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.IBaseService{CoopSettingTool.Service.Models.MstIfEdgeEntity}" />
    public interface IMstIfEdgeService : IBaseService<MstIfEdgeEntity>
    {
        /// <summary>
        /// Gets the MST if edge.
        /// </summary>
        /// <param name="facilityCd">The facility cd.</param>
        /// <returns>Task&lt;GetMstIfEdgeResponse&gt;.</returns>
        Task<GetMstIfEdgeResponse> GetMstIfEdge(string facilityCd);

        /// <summary>
        /// Updates the MST if edge.
        /// </summary>
        /// <param name="inputEntity">The input entity.</param>
        /// <returns>Task&lt;UpdateSysCoopNoResponse&gt;.</returns>
        Task<UpdateSysCoopNoResponse> SubmitMstIfEdge(MstIfEdgeEntity inputEntity);
    }
}
