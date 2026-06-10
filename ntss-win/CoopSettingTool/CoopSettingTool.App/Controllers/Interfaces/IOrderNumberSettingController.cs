// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 05-24-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-25-2021
// ***********************************************************************
// <copyright file="IOrderNumberSettingController.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.App.Models;
using CoopSettingTool.App.Views;

namespace CoopSettingTool.App.Controllers
{
    /// <summary>
    /// Interface IOrderNumberSettingController
    /// Implements the <see cref="CoopSettingTool.App.Controllers.IBaseController{CoopSettingTool.App.Views.IOrderNumberSettingView, CoopSettingTool.App.Models.IOrderNumberSettingModel}" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Controllers.IBaseController{CoopSettingTool.App.Views.IOrderNumberSettingView, CoopSettingTool.App.Models.IOrderNumberSettingModel}" />
    public interface IOrderNumberSettingController : IBaseController<IOrderNumberSettingView, IOrderNumberSettingModel>
    {
        /// <summary>
        /// Loads the system coop no list.
        /// </summary>
        void LoadSysCoopNoList();
        /// <summary>
        /// Saves this instance.
        /// </summary>
        void Save();
        void AddBlankOrderNumberSetting();

        /// <summary>
        /// ファイルをインポートする
        /// </summary>
        /// <param name="filePath"></param>
        void Import(string filePath);
    }
}
