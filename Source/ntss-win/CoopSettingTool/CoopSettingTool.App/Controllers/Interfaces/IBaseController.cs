// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-16-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-19-2021
// ***********************************************************************
// <copyright file="IBaseController.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
namespace CoopSettingTool.App.Controllers
{
    /// <summary>
    /// Interface IBaseController
    /// </summary>
    /// <typeparam name="TView">The type of the t view.</typeparam>
    /// <typeparam name="TModel">The type of the t model.</typeparam>
    public interface IBaseController<TView, TModel>
    {
        /// <summary>
        /// Gets or sets the view.
        /// </summary>
        /// <value>The view.</value>
        TView View { get; set; }
        /// <summary>
        /// Gets or sets the model.
        /// </summary>
        /// <value>The model.</value>
        TModel Model { get; set; }

        /// <summary>
        /// Clears the data.
        /// </summary>
        void ClearData();
    }
}
