// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-16-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-16-2021
// ***********************************************************************
// <copyright file="CompositionRoot.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using Ninject;
using Ninject.Modules;

namespace CoopSettingTool.App.DI
{
    /// <summary>
    /// Class CompositionRoot.
    /// </summary>
    public static class CompositionRoot
    {
        /// <summary>
        /// The ninject kernel
        /// </summary>
        private static IKernel _ninjectKernel;

        /// <summary>
        /// Wires the specified module.
        /// </summary>
        /// <param name="module">The module.</param>
        public static void Wire(INinjectModule module)
        {
            _ninjectKernel = new StandardKernel(module);
        }

        /// <summary>
        /// Resolves this instance.
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <returns>T.</returns>
        public static T Resolve<T>()
        {
            return _ninjectKernel.Get<T>();
        }
    }
}
