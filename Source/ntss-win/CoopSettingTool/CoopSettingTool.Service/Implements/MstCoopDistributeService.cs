// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 05-17-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-27-2022
// ***********************************************************************
// <copyright file="MstCoopDistributeService.cs" company="">
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
    /// Class MstCoopDistributeService.
    /// Implements the <see cref="CoopSettingTool.Service.BaseService{CoopSettingTool.Service.Models.MstCoopDistributeEntity}" />
    /// Implements the <see cref="CoopSettingTool.Service.IMstCoopDistributeService" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.BaseService{CoopSettingTool.Service.Models.MstCoopDistributeEntity}" />
    /// <seealso cref="CoopSettingTool.Service.IMstCoopDistributeService" />
    public class MstCoopDistributeService : BaseService<MstCoopDistributeEntity>, IMstCoopDistributeService
    {
        /// <summary>
        /// Gets the newest MST coop distribute control no list.
        /// </summary>
        /// <param name="facilityCd">The facility cd.</param>
        /// <returns>BaseResponse&lt;List&lt;System.String&gt;&gt;.</returns>
        public async Task<BaseResponse<List<string>>> GetNewestMstCoopDistributeCtlNoList(string facilityCd)
        {
            var res = (await ServerAccess.GetInstance().GetAsync<List<string>>(Constant.GET_NEWEST_MST_COOP_DISTRIBUTE_CTL_NO_BY_FACILITY + "/" + facilityCd, null, true, false));

            return res;
        }

        /// <summary>
        /// Gets the current MST coop distribute list.
        /// </summary>
        /// <param name="facilityCd">The facility cd.</param>
        /// <returns>Task&lt;BaseResponse&lt;List&lt;MstCoopDistributeEntity&gt;&gt;&gt;.</returns>
        public async Task<BaseResponse<List<MstCoopDistributeEntity>>> GetCurrentMstCoopDistributeList(string facilityCd)
        {
            var res = (await ServerAccess.GetInstance().GetAsync<List<MstCoopDistributeEntity>>(Constant.GET_CURRENT_MST_COOP_DISTRIBUTE_BY_FACILITY + "/" + facilityCd, null, true, false));

            return res;
        }

        /// <summary>
        /// Gets the MST coop distribute by control no.
        /// </summary>
        /// <param name="ctlNo">The control no.</param>
        /// <returns>Task&lt;BaseResponse&lt;List&lt;MstCoopDistributeEntity&gt;&gt;&gt;.</returns>
        public async Task<BaseResponse<MstCoopDistributeEntity>> GetMstCoopDistributeByCtlNo(string ctlNo)
        {
            var res = (await ServerAccess.GetInstance().PostAsync<MstCoopDistributeEntity>(Constant.GET_MST_COOP_DISTRIBUTE_BY_CTL_NO + "/" + ctlNo, null, true, false));

            return res;
        }

        /// <summary>
        /// Gets the source MST coop distribute.
        /// </summary>
        /// <param name="condition">The condition.</param>
        /// <returns>Task&lt;BaseResponse&lt;List&lt;MstCoopDistributeEntity&gt;&gt;&gt;.</returns>
        public async Task<BaseResponse<List<MstCoopDistributeEntity>>> GetSourceMstCoopDistribute(MstCoopDistributeEntity condition)
        {
            var res = (await ServerAccess.GetInstance().PostAsync<List<MstCoopDistributeEntity>>(Constant.GET_SOURCE_MST_COOP_DISTRIBUTE, condition, true, true));

            return res;
        }

        /// <summary>
        /// Creates the or update MST coop distribute.
        /// </summary>
        /// <param name="mstCoopDistributeEntity">The MST coop distribute entity.</param>
        /// <returns>Task&lt;SubmitMstCoopDistributeResponse&gt;.</returns>
        public async Task<BaseResponse<bool>> CreateOrUpdateMstCoopDistribute(MstCoopDistributeEntity mstCoopDistributeEntity)
        {
            BaseResponse<bool> res = (await ServerAccess.GetInstance().PostAsync<bool>(Constant.SUBMIT_MST_COOP_DISTRIBUTE, mstCoopDistributeEntity, true, true));

            return res;
        }
    }
}
