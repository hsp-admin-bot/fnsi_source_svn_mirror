// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 04-19-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-20-2021
// ***********************************************************************
// <copyright file="GetAllMstFacilityResponse.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using System.Collections.Generic;

namespace CoopSettingTool.Service.Models
{
    /// <summary>
    /// Class GetAllMstFacilityResponse.
    /// Implements the <see cref="CoopSettingTool.Service.Models.BaseResponse{System.Collections.Generic.List{CoopSettingTool.Service.Models.MstFacilityEntity}}" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.Models.BaseResponse{System.Collections.Generic.List{CoopSettingTool.Service.Models.MstFacilityEntity}}" />
    public class GetAllMstFacilityResponse : BaseResponse<List<MstFacilityEntity>>
    {
    }
}
