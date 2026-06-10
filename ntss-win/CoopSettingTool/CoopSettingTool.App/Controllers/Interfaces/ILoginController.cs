// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-16-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-19-2021
// ***********************************************************************
// <copyright file="ILoginController.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.App.Models;
using CoopSettingTool.App.Views;
using System.Threading.Tasks;

namespace CoopSettingTool.App.Controllers
{
    /// <summary>
    /// Interface ILoginController
    /// Implements the <see cref="CoopSettingTool.App.Controllers.IBaseController{CoopSettingTool.App.Views.ILoginView, CoopSettingTool.App.Models.ILoginModel}" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Controllers.IBaseController{CoopSettingTool.App.Views.ILoginView, CoopSettingTool.App.Models.ILoginModel}" />
    public interface ILoginController : IBaseController<ILoginView, ILoginModel>
    {
        /// <summary>
        /// Logins the asynchronous.
        /// </summary>
        /// <returns>Task.</returns>
        Task LoginAsync();

        /// <summary>
        /// Shows the view.
        /// </summary>
        void ShowView();
    }
}
