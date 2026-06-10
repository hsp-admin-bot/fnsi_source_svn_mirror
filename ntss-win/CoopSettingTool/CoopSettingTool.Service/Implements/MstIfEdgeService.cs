// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 05-25-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-25-2021
// ***********************************************************************
// <copyright file="MstIfEdgeService.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.Service.Configuration;
using CoopSettingTool.Service.Extendsions;
using CoopSettingTool.Service.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoopSettingTool.Service
{
    /// <summary>
    /// Class MstIfEdgeService.
    /// Implements the <see cref="CoopSettingTool.Service.BaseService{CoopSettingTool.Service.Models.MstIfEdgeEntity}" />
    /// Implements the <see cref="CoopSettingTool.Service.IMstIfEdgeService" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.BaseService{CoopSettingTool.Service.Models.MstIfEdgeEntity}" />
    /// <seealso cref="CoopSettingTool.Service.IMstIfEdgeService" />
    public class MstIfEdgeService : BaseService<MstIfEdgeEntity>, IMstIfEdgeService
    {
        /// <summary>
        /// Gets the MST if edge.
        /// </summary>
        /// <param name="facilityCd">The facility cd.</param>
        /// <returns>GetMstIfEdgeResponse.</returns>
        public async Task<GetMstIfEdgeResponse> GetMstIfEdge(string facilityCd)
        {
            GetMstIfEdgeResponse res = (await ServerAccess.GetInstance().GetAsync<List<MstIfEdgeEntity>>(Constant.GET_MST_IF_EDGE + "/" + facilityCd, null)).ToClass<List<MstIfEdgeEntity>, GetMstIfEdgeResponse>();
            return res;
        }

        /// <summary>
        /// Updates the MST if edge.
        /// </summary>
        /// <param name="inputEntity">The input entity.</param>
        /// <returns>Task&lt;UpdateSysCoopNoResponse&gt;.</returns>
        public async Task<UpdateSysCoopNoResponse> SubmitMstIfEdge(MstIfEdgeEntity inputEntity)
        {
            BaseResponse<bool> res = (await ServerAccess.GetInstance().PostAsync<bool>(Constant.SUBMIT_MST_IF_EDGE, inputEntity, true, true));
            UpdateSysCoopNoResponse result = new UpdateSysCoopNoResponse()
            {
                Data = res.Data,
                Error = res.Error,
                Exception = res.Exception,
                StatusCode = res.StatusCode
            };
            return result;
        }
    }
}
