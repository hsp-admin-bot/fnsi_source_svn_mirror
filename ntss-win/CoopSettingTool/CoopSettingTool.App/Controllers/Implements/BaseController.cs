// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-16-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-19-2021
// ***********************************************************************
// <copyright file="BaseController.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
namespace CoopSettingTool.App.Controllers
{
    /// <summary>
    /// Class BaseController.
    /// Implements the <see cref="CoopSettingTool.App.Controllers.IBaseController{TView, TModel}" />
    /// </summary>
    /// <typeparam name="TView">The type of the t view.</typeparam>
    /// <typeparam name="TModel">The type of the t model.</typeparam>
    /// <seealso cref="CoopSettingTool.App.Controllers.IBaseController{TView, TModel}" />
    public class BaseController<TView, TModel> : IBaseController<TView, TModel>
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="BaseController{TView, TModel}"/> class.
        /// </summary>
        /// <param name="view">The view.</param>
        /// <param name="model">The model.</param>
        public BaseController(TView view, TModel model)
        {
            View = view;
            Model = model;
        }

        /// <summary>
        /// Gets or sets the view.
        /// </summary>
        /// <value>The view.</value>
        public virtual TView View { get; set; }
        /// <summary>
        /// Gets or sets the model.
        /// </summary>
        /// <value>The model.</value>
        public virtual TModel Model { get; set; }

        /// <summary>
        /// Clears the data.
        /// </summary>
        public virtual void ClearData()
        {

        }
    }
}
