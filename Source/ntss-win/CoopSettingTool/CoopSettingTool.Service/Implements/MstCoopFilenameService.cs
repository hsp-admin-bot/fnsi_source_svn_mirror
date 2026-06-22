// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 08-04-2023
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 08-04-2023
// ***********************************************************************
// <copyright file="MstCoopFilenameService.cs" company="">
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
    /// Class MstCoopFilenameService.
    /// Implements the <see cref="CoopSettingTool.Service.BaseService{CoopSettingTool.Service.Models.MstCoopFilenameEntity}" />
    /// Implements the <see cref="CoopSettingTool.Service.IMstCoopFilenameService" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.BaseService{CoopSettingTool.Service.Models.MstCoopFilenameEntity}" />
    /// <seealso cref="CoopSettingTool.Service.IMstCoopFilenameService" />
    public class MstCoopFilenameService : BaseService<MstCoopFilenameEntity>, IMstCoopFilenameService
    {
        /// <summary>
        /// Gets the newest MST coop filename control no list.
        /// </summary>
        /// <param name="facilityCd">The facility cd.</param>
        /// <returns>BaseResponse&lt;List&lt;System.String&gt;&gt;.</returns>
        public async Task<BaseResponse<List<string>>> GetNewestMstCoopFilenameCtlNoList(string facilityCd)
        {
            var res = (await ServerAccess.GetInstance().GetAsync<List<string>>(Constant.GET_NEWEST_MST_COOP_FILENAME_CTL_NO_BY_FACILITY + "/" + facilityCd, null, true, false));

            return res;
        }

        /// <summary>
        /// Gets the current MST coop filename list.
        /// </summary>
        /// <param name="facilityCd">The facility cd.</param>
        /// <returns>Task&lt;BaseResponse&lt;List&lt;MstCoopFilenameEntity&gt;&gt;&gt;.</returns>
        public async Task<BaseResponse<List<MstCoopFilenameEntity>>> GetCurrentMstCoopFilenameList(string facilityCd)
        {
            var res = (await ServerAccess.GetInstance().GetAsync<List<MstCoopFilenameEntity>>(Constant.GET_CURRENT_MST_COOP_FILENAME_BY_FACILITY + "/" + facilityCd, null, true, false));

            return res;
        }

        /// <summary>
        /// Gets the MST coop filename by control no.
        /// </summary>
        /// <param name="ctlNo">The control no.</param>
        /// <returns>Task&lt;BaseResponse&lt;List&lt;MstCoopFilenameEntity&gt;&gt;&gt;.</returns>
        public async Task<BaseResponse<MstCoopFilenameEntity>> GetMstCoopFilenameByCtlNo(string ctlNo)
        {
            var res = (await ServerAccess.GetInstance().GetAsync<MstCoopFilenameEntity>(Constant.GET_MST_COOP_FILENAME_BY_CTL_NO + "/" + ctlNo, null, true, false));

            return res;
        }

        /// <summary>
        /// Gets the source MST coop filename.
        /// </summary>
        /// <param name="condition">The condition.</param>
        /// <returns>Task&lt;BaseResponse&lt;List&lt;MstCoopFilenameEntity&gt;&gt;&gt;.</returns>
        public async Task<BaseResponse<List<MstCoopFilenameEntity>>> GetSourceMstCoopFilename(MstCoopFilenameEntity condition)
        {
            var res = (await ServerAccess.GetInstance().PostAsync<List<MstCoopFilenameEntity>>(Constant.GET_SOURCE_MST_COOP_FILENAME, condition, true, true));

            return res;
        }

        /// <summary>
        /// Creates the or update MST coop filename.
        /// </summary>
        /// <param name="mstCoopFilenameEntity">The MST coop filename entity.</param>
        /// <returns>Task&lt;SubmitMstCoopFilenameResponse&gt;.</returns>
        public async Task<BaseResponse<bool>> CreateOrUpdateMstCoopFilename(MstCoopFilenameEntity mstCoopFilenameEntity)
        {
            BaseResponse<bool> res = (await ServerAccess.GetInstance().PostAsync<bool>(Constant.SUBMIT_MST_COOP_FILENAME, mstCoopFilenameEntity, true, true));

            return res;
        }
    }
}
