// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 04-26-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-26-2021
// ***********************************************************************
// <copyright file="GetMstCoopFacilityResponse.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using System.Collections.Generic;

namespace CoopSettingTool.Service.Models
{
    /// <summary>
    /// Class GetMstCoopFacilityResponse.
    /// Implements the <see cref="CoopSettingTool.Service.Models.BaseResponse{CoopSettingTool.Service.Models.BaseContent{System.Collections.Generic.List{CoopSettingTool.Service.Models.MstCoopFacilityEntity}}}" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.Models.BaseResponse{CoopSettingTool.Service.Models.BaseContent{System.Collections.Generic.List{CoopSettingTool.Service.Models.MstCoopFacilityEntity}}}" />
    public class GetMstCoopFacilityResponse : BaseResponse<BaseContent<List<MstCoopFacilityEntity>>>
    {
    }
}
