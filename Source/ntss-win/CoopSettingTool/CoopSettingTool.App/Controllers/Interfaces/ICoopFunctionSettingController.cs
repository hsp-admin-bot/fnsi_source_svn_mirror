// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-26-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-18-2021
// ***********************************************************************
// <copyright file="ICoopFunctionSettingController.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.App.Models;
using CoopSettingTool.App.Views;

namespace CoopSettingTool.App.Controllers
{
    /// <summary>
    /// Interface ICoopFunctionSettingController
    /// Implements the <see cref="CoopSettingTool.App.Controllers.IBaseController{CoopSettingTool.App.Views.ICoopFunctionSettingView, CoopSettingTool.App.Models.ICoopFunctionSettingModel}" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Controllers.IBaseController{CoopSettingTool.App.Views.ICoopFunctionSettingView, CoopSettingTool.App.Models.ICoopFunctionSettingModel}" />
    public interface ICoopFunctionSettingController : IBaseController<ICoopFunctionSettingView, ICoopFunctionSettingModel>
    {
        /// <summary>
        /// Turns the off coop function.
        /// </summary>
        void TurnOffCoopFunction();
        /// <summary>
        /// Turns the on coop function.
        /// </summary>
        void TurnOnCoopFunction();
        /// <summary>
        /// Submits this instance.
        /// </summary>
        void Submit();
        /// <summary>
        /// Loads the coop distribute.
        /// </summary>
        void LoadCoopDistribute();
    }
}
