// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-26-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-10-2021
// ***********************************************************************
// <copyright file="ICoopFunctionSettingView.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.Service.Models;
using System.Windows.Forms;

namespace CoopSettingTool.App.Views
{
    /// <summary>
    /// Interface ICoopFunctionSettingView
    /// Implements the <see cref="CoopSettingTool.App.Views.IBaseView" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Views.IBaseView" />
    public interface ICoopFunctionSettingView : IBaseView
    {
        /// <summary>
        /// Shows the dialog.
        /// </summary>
        /// <param name="parent">The parent.</param>
        /// <param name="coopFacilityEntity">The coop facility entity.</param>
        /// <param name="selectedCoopFunction">The selected coop function.</param>
        /// <returns>DialogResult.</returns>
        DialogResult ShowDialog(IWin32Window parent, MstFacilityEntity facility, MstCoopFacilityEntity coopFacilityEntity, int selectedCoopFunction);
    }
}
