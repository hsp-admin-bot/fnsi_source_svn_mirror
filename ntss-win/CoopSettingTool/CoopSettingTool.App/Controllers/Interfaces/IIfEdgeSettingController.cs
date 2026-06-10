// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 05-25-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-27-2021
// ***********************************************************************
// <copyright file="IIfEdgeSettingController.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.App.Models;
using CoopSettingTool.App.Views;


namespace CoopSettingTool.App.Controllers
{
    /// <summary>
    /// Interface IIfEdgeSettingController
    /// Implements the <see cref="CoopSettingTool.App.Controllers.IBaseController{CoopSettingTool.App.Views.IIfEdgeSettingView, CoopSettingTool.App.Models.IIfEdgeSettingModel}" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Controllers.IBaseController{CoopSettingTool.App.Views.IIfEdgeSettingView, CoopSettingTool.App.Models.IIfEdgeSettingModel}" />
    public interface IIfEdgeSettingController : IBaseController<IIfEdgeSettingView, IIfEdgeSettingModel>
    {
        /// <summary>
        /// Loads if edge list.
        /// </summary>
        void LoadIfEdgeList();
        /// <summary>
        /// Saves this instance.
        /// </summary>
        void Save();
        void AddNewIfEdge();
    }
}
