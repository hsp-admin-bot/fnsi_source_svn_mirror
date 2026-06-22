// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 04-21-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-13-2022
// ***********************************************************************
// <copyright file="IMstCoopLayoutService.cs" company="">
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
    /// Interface IMstCoopLayoutService
    /// Implements the <see cref="CoopSettingTool.Service.IBaseService{CoopSettingTool.Service.Models.MstCoopLayoutEntity}" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.IBaseService{CoopSettingTool.Service.Models.MstCoopLayoutEntity}" />
    public interface IMstCoopLayoutService : IBaseService<MstCoopLayoutEntity>
    {
        /// <summary>
        /// Gets the newest MST coop layout control no list.
        /// </summary>
        /// <param name="facilityCd">The facility cd.</param>
        /// <returns>Task&lt;BaseResponse&lt;List&lt;System.String&gt;&gt;&gt;.</returns>
        Task<BaseResponse<List<string>>> GetNewestMstCoopLayoutCtlNoList(string facilityCd);

        /// <summary>
        /// Gets the current MST coop layout list.
        /// </summary>
        /// <param name="facilityCd">The facility cd.</param>
        /// <returns>Task&lt;BaseResponse&lt;List&lt;MstCoopLayoutEntity&gt;&gt;&gt;.</returns>
        Task<BaseResponse<List<MstCoopLayoutEntity>>> GetCurrentMstCoopLayoutList(string facilityCd);

        /// <summary>
        /// Gets the MST coop layou by control no.
        /// </summary>
        /// <param name="ctlNo">The control no.</param>
        /// <returns>Task&lt;BaseResponse&lt;MstCoopLayoutEntity&gt;&gt;.</returns>
        Task<BaseResponse<MstCoopLayoutEntity>> GetMstCoopLayoutByCtlNo(string ctlNo);

        /// <summary>
        /// Gets the source MST coop layout.
        /// </summary>
        /// <param name="condition">The condition.</param>
        /// <returns>Task&lt;BaseResponse&lt;List&lt;MstCoopLayoutEntity&gt;&gt;&gt;.</returns>
        Task<BaseResponse<List<MstCoopLayoutEntity>>> GetSourceMstCoopLayout(MstCoopLayoutEntity condition);

        /// <summary>
        /// Creates the or update MST coop layout detail.
        /// </summary>
        /// <param name="mstCoopLayoutEntity">The MST coop layout entity.</param>
        /// <returns>Task&lt;BaseResponse&lt;System.Boolean&gt;&gt;.</returns>
        Task<BaseResponse<bool>> CreateOrUpdateMstCoopLayout(MstCoopLayoutEntity mstCoopLayoutEntity);

        /// <summary>
        /// Gets the newest MST coop layout detail control no list.
        /// </summary>
        /// <param name="facilityCd">The facility cd.</param>
        /// <returns>Task&lt;BaseResponse&lt;List&lt;System.String&gt;&gt;&gt;.</returns>
        Task<BaseResponse<List<string>>> GetNewestMstCoopLayoutDetailCtlNoList(string facilityCd);

        /// <summary>
        /// Gets the current MST coop layout detail list.
        /// </summary>
        /// <param name="facilityCd">The facility cd.</param>
        /// <returns>Task&lt;BaseResponse&lt;List&lt;MstCoopLayoutDetailEntity&gt;&gt;&gt;.</returns>
        Task<BaseResponse<List<MstCoopLayoutDetailEntity>>> GetCurrentMstCoopLayoutDetailList(string facilityCd);

        /// <summary>
        /// Gets the MST coop layou detail by control no.
        /// </summary>
        /// <param name="ctlNo">The control no.</param>
        /// <returns>Task&lt;BaseResponse&lt;MstCoopLayoutDetailEntity&gt;&gt;.</returns>
        Task<BaseResponse<MstCoopLayoutDetailEntity>> GetMstCoopLayoutDetailByCtlNo(string ctlNo);

        /// <summary>
        /// Gets the source MST coop layout detail.
        /// </summary>
        /// <param name="condition">The condition.</param>
        /// <returns>Task&lt;BaseResponse&lt;List&lt;MstCoopLayoutDetailEntity&gt;&gt;&gt;.</returns>
        Task<BaseResponse<List<MstCoopLayoutDetailEntity>>> GetSourceMstCoopLayoutDetail(MstCoopLayoutDetailEntity condition);

        /// <summary>
        /// Creates the or update MST coop layout detail.
        /// </summary>
        /// <param name="mstCoopLayoutDetailEntity">The MST coop layout detail entity.</param>
        /// <returns>Task&lt;BaseResponse&lt;System.Boolean&gt;&gt;.</returns>
        Task<BaseResponse<bool>> CreateOrUpdateMstCoopLayoutDetail(MstCoopLayoutDetailEntity mstCoopLayoutDetailEntity);
    }
}
