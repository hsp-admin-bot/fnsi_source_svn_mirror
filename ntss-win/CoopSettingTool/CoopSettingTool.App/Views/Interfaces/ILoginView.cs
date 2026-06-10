// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-16-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-20-2021
// ***********************************************************************
// <copyright file="ILoginView.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.App.Controllers;
using System.Windows.Forms;

namespace CoopSettingTool.App.Views
{
    /// <summary>
    /// Interface ILoginView
    /// Implements the <see cref="CoopSettingTool.App.Views.IBaseView" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Views.IBaseView" />
    public interface ILoginView : IBaseView
    {
        /// <summary>
        /// Sets the controller.
        /// </summary>
        /// <param name="loginController">The login controller.</param>
        void SetController(ILoginController loginController);

        /// <summary>
        /// Gets the user identifier.
        /// </summary>
        /// <value>The user identifier.</value>
        string UserID { get; }
        /// <summary>
        /// Gets the password.
        /// </summary>
        /// <value>The password.</value>
        string Password { get; }
        /// <summary>
        /// Gets the otp.
        /// </summary>
        /// <value>The otp.</value>
        string Otp { get; }

        /// <summary>
        /// Registers the event.
        /// </summary>
        void RegisterEvent();


        /// <summary>
        /// Shows the otp dialogue.
        /// </summary>
        /// <returns>DialogResult.</returns>
        DialogResult ShowOtpDialogue();

        /// <summary>
        /// Shows the main menu view.
        /// </summary>
        void ShowMainMenuView();
    }
}
