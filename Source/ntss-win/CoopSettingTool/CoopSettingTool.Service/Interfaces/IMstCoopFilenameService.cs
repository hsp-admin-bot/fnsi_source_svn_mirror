// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 08-04-2023
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 08-04-2023
// ***********************************************************************
// <copyright file="IMstCoopFilenameService.cs" company="">
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
    /// Interface IMstCoopFilenameService
    /// Implements the <see cref="CoopSettingTool.Service.IBaseService{CoopSettingTool.Service.Models.MstCoopFilenameEntity}" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.IBaseService{CoopSettingTool.Service.Models.MstCoopFilenameEntity}" />
    public interface IMstCoopFilenameService : IBaseService<MstCoopFilenameEntity>
    {
        /// <summary>
        /// Gets the newest MST coop filename control no list.
        /// </summary>
        /// <param name="facilityCd">The facility cd.</param>
        /// <returns>BaseResponse&lt;List&lt;System.String&gt;&gt;.</returns>
        Task<BaseResponse<List<string>>> GetNewestMstCoopFilenameCtlNoList(string facilityCd);

        /// <summary>
        /// Gets the current MST coop filename list.
        /// </summary>
        /// <param name="facilityCd">The facility cd.</param>
        /// <returns>Task&lt;BaseResponse&lt;List&lt;MstCoopFilenameEntity&gt;&gt;&gt;.</returns>
        Task<BaseResponse<List<MstCoopFilenameEntity>>> GetCurrentMstCoopFilenameList(string facilityCd);

        /// <summary>
        /// Gets the MST coop filename by control no.
        /// </summary>
        /// <param name="ctlNo">The control no.</param>
        /// <returns>Task&lt;BaseResponse&lt;List&lt;MstCoopFilenameEntity&gt;&gt;&gt;.</returns>
        Task<BaseResponse<MstCoopFilenameEntity>> GetMstCoopFilenameByCtlNo(string ctlNo);

        /// <summary>
        /// Gets the source MST coop filename.
        /// </summary>
        /// <param name="condition">The condition.</param>
        /// <returns>Task&lt;BaseResponse&lt;List&lt;MstCoopFilenameEntity&gt;&gt;&gt;.</returns>
        Task<BaseResponse<List<MstCoopFilenameEntity>>> GetSourceMstCoopFilename(MstCoopFilenameEntity condition);

        /// <summary>
        /// Creates the or update MST coop filename.
        /// </summary>
        /// <param name="mstCoopFilenameEntity">The MST coop filename entity.</param>
        /// <returns>Task&lt;SubmitMstCoopFilenameResponse&gt;.</returns>
        Task<BaseResponse<bool>> CreateOrUpdateMstCoopFilename(MstCoopFilenameEntity mstCoopFilenameEntity);
    }
}
