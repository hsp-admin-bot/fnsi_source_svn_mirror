// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-14-2022
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-14-2022
// ***********************************************************************
// <copyright file="ICoopDistributeSettingView.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved
// </copyright>
// <summary></summary>
// ***********************************************************************

using CoopSettingTool.Service.Models;
using System.Windows.Forms;

namespace CoopSettingTool.App.Views
{

    /// <summary>
    /// Interface ICoopDistributeSettingView
    /// Implements the <see cref="CoopSettingTool.App.Views.IBaseView" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Views.IBaseView" />
    public interface ICoopDistributeSettingView : IBaseView
    {
        /// <summary>
        /// Shows the dialog.
        /// </summary>
        /// <param name="parent">The parent.</param>
        /// <param name="selectedFacility">The selected facility.</param>
        /// <returns>DialogResult.</returns>
        DialogResult ShowDialog(IWin32Window parent, MstFacilityEntity selectedFacility);
    }
}
