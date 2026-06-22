// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 04-21-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-27-2022
// ***********************************************************************
// <copyright file="MstCoopLayoutService.cs" company="">
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
    /// Class MstCoopLayoutService.
    /// Implements the <see cref="CoopSettingTool.Service.BaseService{CoopSettingTool.Service.Models.MstCoopLayoutEntity}" />
    /// Implements the <see cref="CoopSettingTool.Service.IMstCoopLayoutService" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.BaseService{CoopSettingTool.Service.Models.MstCoopLayoutEntity}" />
    /// <seealso cref="CoopSettingTool.Service.IMstCoopLayoutService" />
    public class MstCoopLayoutService : BaseService<MstCoopLayoutEntity>, IMstCoopLayoutService
    {
        /// <summary>
        /// Gets the newest MST coop layout control no list.
        /// </summary>
        /// <param name="facilityCd">The facility cd.</param>
        /// <returns>Task&lt;BaseResponse&lt;List&lt;System.String&gt;&gt;&gt;.</returns>
        public async Task<BaseResponse<List<string>>> GetNewestMstCoopLayoutCtlNoList(string facilityCd)
        {
            var res = (await ServerAccess.GetInstance().GetAsync<List<string>>(Constant.GET_NEWEST_MST_COOP_LAYOUT_CTL_NO_BY_FACILITY + "/" + facilityCd, null, true, false));

            return res;
        }

        /// <summary>
        /// Gets the current MST coop layout list.
        /// </summary>
        /// <param name="facilityCd">The facility cd.</param>
        /// <returns>Task&lt;BaseResponse&lt;List&lt;MstCoopLayoutEntity&gt;&gt;&gt;.</returns>
        public async Task<BaseResponse<List<MstCoopLayoutEntity>>> GetCurrentMstCoopLayoutList(string facilityCd)
        {
            var res = (await ServerAccess.GetInstance().GetAsync<List<MstCoopLayoutEntity>>(Constant.GET_CURRENT_MST_COOP_LAYOUT_BY_FACILITY + "/" + facilityCd, null, true, false));

            return res;
        }

        /// <summary>
        /// Gets the MST coop layou by control no.
        /// </summary>
        /// <param name="ctlNo">The control no.</param>
        /// <returns>Task&lt;BaseResponse&lt;MstCoopLayoutEntity&gt;&gt;.</returns>
        public async Task<BaseResponse<MstCoopLayoutEntity>> GetMstCoopLayoutByCtlNo(string ctlNo)
        {
            var res = (await ServerAccess.GetInstance().PostAsync<MstCoopLayoutEntity>(Constant.GET_MST_COOP_LAYOUT_BY_CTL_NO + "/" + ctlNo, null, true, false));

            return res;
        }

        /// <summary>
        /// Gets the source MST coop layout.
        /// </summary>
        /// <param name="condition">The condition.</param>
        /// <returns>Task&lt;BaseResponse&lt;List&lt;MstCoopLayoutEntity&gt;&gt;&gt;.</returns>
        public async Task<BaseResponse<List<MstCoopLayoutEntity>>> GetSourceMstCoopLayout(MstCoopLayoutEntity condition)
        {
            var res = (await ServerAccess.GetInstance().PostAsync<List<MstCoopLayoutEntity>>(Constant.GET_SOURCE_MST_COOP_LAYOUT, condition, true, true));

            return res;
        }

        /// <summary>
        /// Creates the or update MST coop layout detail.
        /// </summary>
        /// <param name="mstCoopLayoutEntity">The MST coop layout entity.</param>
        /// <returns>Task&lt;BaseResponse&lt;System.Boolean&gt;&gt;.</returns>
        public async Task<BaseResponse<bool>> CreateOrUpdateMstCoopLayout(MstCoopLayoutEntity mstCoopLayoutEntity)
        {
            BaseResponse<bool> res = (await ServerAccess.GetInstance().PostAsync<bool>(Constant.SUBMIT_MST_COOP_LAYOUT, mstCoopLayoutEntity, true, true));

            return res;
        }

        /// <summary>
        /// Gets the newest MST coop layout detail control no list.
        /// </summary>
        /// <param name="facilityCd">The facility cd.</param>
        /// <returns>Task&lt;BaseResponse&lt;List&lt;System.String&gt;&gt;&gt;.</returns>
        public async Task<BaseResponse<List<string>>> GetNewestMstCoopLayoutDetailCtlNoList(string facilityCd)
        {
            var res = (await ServerAccess.GetInstance().GetAsync<List<string>>(Constant.GET_NEWEST_MST_COOP_LAYOUT_DETAIL_CTL_NO_BY_FACILITY + "/" + facilityCd, null, true, false));

            return res;
        }

        /// <summary>
        /// Gets the current MST coop layout detail list.
        /// </summary>
        /// <param name="facilityCd">The facility cd.</param>
        /// <returns>Task&lt;BaseResponse&lt;List&lt;MstCoopLayoutDetailEntity&gt;&gt;&gt;.</returns>
        public async Task<BaseResponse<List<MstCoopLayoutDetailEntity>>> GetCurrentMstCoopLayoutDetailList(string facilityCd)
        {
            var res = (await ServerAccess.GetInstance().GetAsync<List<MstCoopLayoutDetailEntity>>(Constant.GET_CURRENT_MST_COOP_LAYOUT_DETAIL_BY_FACILITY + "/" + facilityCd, null, true, false));

            return res;
        }

        /// <summary>
        /// Gets the MST coop layou detail by control no.
        /// </summary>
        /// <param name="ctlNo">The control no.</param>
        /// <returns>Task&lt;BaseResponse&lt;MstCoopLayoutDetailEntity&gt;&gt;.</returns>
        public async Task<BaseResponse<MstCoopLayoutDetailEntity>> GetMstCoopLayoutDetailByCtlNo(string ctlNo)
        {
            var res = (await ServerAccess.GetInstance().GetAsync<MstCoopLayoutDetailEntity>(Constant.GET_MST_COOP_LAYOUT_DETAIL_BY_CTL_NO + "/" + ctlNo, null, true, false));

            return res;
        }

        /// <summary>
        /// Gets the source MST coop layout detail.
        /// </summary>
        /// <param name="condition">The condition.</param>
        /// <returns>Task&lt;BaseResponse&lt;List&lt;MstCoopLayoutDetailEntity&gt;&gt;&gt;.</returns>
        public async Task<BaseResponse<List<MstCoopLayoutDetailEntity>>> GetSourceMstCoopLayoutDetail(MstCoopLayoutDetailEntity condition)
        {
            var res = (await ServerAccess.GetInstance().PostAsync<List<MstCoopLayoutDetailEntity>>(Constant.GET_SOURCE_MST_COOP_LAYOUT_DETAIL, condition, true, true));

            return res;
        }

        /// <summary>
        /// Creates the or update MST coop layout detail.
        /// </summary>
        /// <param name="mstCoopLayoutDetailEntity">The MST coop layout detail entity.</param>
        /// <returns>Task&lt;BaseResponse&lt;System.Boolean&gt;&gt;.</returns>
        public async Task<BaseResponse<bool>> CreateOrUpdateMstCoopLayoutDetail(MstCoopLayoutDetailEntity mstCoopLayoutDetailEntity)
        {
            BaseResponse<bool> res = (await ServerAccess.GetInstance().PostAsync<bool>(Constant.SUBMIT_MST_COOP_LAYOUT_DETAIL, mstCoopLayoutDetailEntity, true, true));

            return res;
        }
    }
}
