// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 05-24-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-26-2021
// ***********************************************************************
// <copyright file="GetSysCoopNoResponse.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using System.Collections.Generic;

namespace CoopSettingTool.Service.Models
{
    /// <summary>
    /// Class GetSysCoopNoResponse.
    /// Implements the <see cref="CoopSettingTool.Service.Models.BaseResponse{System.Collections.Generic.List{CoopSettingTool.Service.Models.SysCoopNoEntity}}" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.Models.BaseResponse{System.Collections.Generic.List{CoopSettingTool.Service.Models.SysCoopNoEntity}}" />
    public class GetSysCoopNoResponse : BaseResponse<List<SysCoopNoEntity>>
    {
    }
}
