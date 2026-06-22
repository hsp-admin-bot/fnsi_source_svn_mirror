// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 04-20-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-20-2021
// ***********************************************************************
// <copyright file="GetAllMstCoopFacilityResponse.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using System.Collections.Generic;

namespace CoopSettingTool.Service.Models
{
    /// <summary>
    /// Class GetAllMstCoopFacilityResponse.
    /// Implements the <see cref="CoopSettingTool.Service.Models.BaseResponse{CoopSettingTool.Service.Models.BaseContent{System.Collections.Generic.List{CoopSettingTool.Service.Models.MstCoopFacilityEntity}}}" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.Models.BaseResponse{CoopSettingTool.Service.Models.BaseContent{System.Collections.Generic.List{CoopSettingTool.Service.Models.MstCoopFacilityEntity}}}" />
    public class GetAllMstCoopFacilityResponse : BaseResponse<BaseContent<List<MstCoopFacilityEntity>>>
    {
    }
}
