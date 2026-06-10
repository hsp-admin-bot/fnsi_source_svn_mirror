// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 05-17-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-31-2021
// ***********************************************************************
// <copyright file="IMstCoopDistributeService.cs" company="">
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
    /// Interface IMstCoopDistributeService
    /// Implements the <see cref="CoopSettingTool.Service.IBaseService{CoopSettingTool.Service.Models.MstCoopDistributeEntity}" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.IBaseService{CoopSettingTool.Service.Models.MstCoopDistributeEntity}" />
    public interface IMstCoopDistributeService : IBaseService<MstCoopDistributeEntity>
    {
        /// <summary>
        /// Gets the newest MST coop distribute control no list.
        /// </summary>
        /// <param name="facilityCd">The facility cd.</param>
        /// <returns>BaseResponse&lt;List&lt;System.String&gt;&gt;.</returns>
        Task<BaseResponse<List<string>>> GetNewestMstCoopDistributeCtlNoList(string facilityCd);

        /// <summary>
        /// Gets the MST coop distribute by control no.
        /// </summary>
        /// <param name="ctlNo">The control no.</param>
        /// <returns>Task&lt;BaseResponse&lt;List&lt;MstCoopDistributeEntity&gt;&gt;&gt;.</returns>
        Task<BaseResponse<MstCoopDistributeEntity>> GetMstCoopDistributeByCtlNo(string ctlNo);

        /// <summary>
        /// Creates the or update MST coop distribute.
        /// </summary>
        /// <param name="mstCoopDistributeEntity">The MST coop distribute entity.</param>
        /// <returns>Task&lt;SubmitMstCoopDistributeResponse&gt;.</returns>
        Task<BaseResponse<bool>> CreateOrUpdateMstCoopDistribute(MstCoopDistributeEntity mstCoopDistributeEntity);
    }
}
