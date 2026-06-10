// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-16-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-21-2021
// ***********************************************************************
// <copyright file="IBaseView.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.App.Enums;
using System.Windows.Forms;

namespace CoopSettingTool.App.Views
{
    /// <summary>
    /// Interface IBaseView
    /// </summary>
    public interface IBaseView
    {
        /// <summary>
        /// Shows the message.
        /// </summary>
        /// <param name="message">The message.</param>
        /// <param name="caption">The caption.</param>
        /// <param name="type">The type.</param>
        void ShowMessage(string message, string caption, MessageTypeEnum type);

        /// <summary>
        /// Shows the ask message.
        /// </summary>
        /// <param name="v">The v.</param>
        /// <param name="eRROR1">The e rro r1.</param>
        /// <param name="eRROR2">The e rro r2.</param>
        bool ShowAskMessage(string v, string eRROR1, MessageTypeEnum eRROR2);

        /// <summary>
        /// Hides the view.
        /// </summary>
        void HideView();

        /// <summary>
        /// Shows the view.
        /// </summary>
        /// <param name="parent">The parent.</param>
        /// <returns>Form.</returns>
        Form ShowView(IWin32Window parent = null);

        /// <summary>
        /// Closes the view.
        /// </summary>
        void CloseView(DialogResult dialogResult);

        /// <summary>
        /// Shows the dialog.
        /// </summary>
        /// <param name="parent">The parent.</param>
        /// <returns>DialogResult.</returns>
        DialogResult ShowDialog(IWin32Window parent);

        /// <summary>
        /// Shows the loading.
        /// </summary>
        void ShowLoading();

        /// <summary>
        /// Hides the loading.
        /// </summary>
        void HideLoading();
    }
}
