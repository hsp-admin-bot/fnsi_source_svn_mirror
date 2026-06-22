// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 06-14-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 06-14-2021
// ***********************************************************************
// <copyright file="GetAllSysReleaseInfoResponse.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using System.Collections.Generic;

namespace CoopSettingTool.Service.Models.Responses
{
    /// <summary>
    /// Class GetAllSysReleaseInfoResponse.
    /// Implements the <see cref="CoopSettingTool.Service.Models.BaseResponse{System.Collections.Generic.List{CoopSettingTool.Service.Models.SysReleaseInfoEntity}}" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.Models.BaseResponse{System.Collections.Generic.List{CoopSettingTool.Service.Models.SysReleaseInfoEntity}}" />
    public class GetAllSysReleaseInfoResponse :  BaseResponse<List<SysReleaseInfoEntity>>
    {
    }
}
