// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 04-16-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-16-2021
// ***********************************************************************
// <copyright file="BaseService.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.Service;
using Microsoft.Win32.SafeHandles;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Runtime.InteropServices;
using System.Threading.Tasks;

namespace CoopSettingTool.Service
{
    /// <summary>
    /// Class BaseService.
    /// Implements the <see cref="CoopSettingTool.Service.IBaseService{TModel}" />
    /// </summary>
    /// <typeparam name="TModel">The type of the t model.</typeparam>
    /// <seealso cref="CoopSettingTool.Service.IBaseService{TModel}" />
    public class BaseService<TModel> : IBaseService<TModel> where TModel : class
    {
        // Flag: Has Dispose already been called?
        /// <summary>
        /// The disposed
        /// </summary>
        private bool disposed = false;

        // Instantiate a SafeHandle instance.
        /// <summary>
        /// The handle
        /// </summary>
        private SafeHandle handle = new SafeFileHandle(IntPtr.Zero, true);

        /// <summary>
        /// Initializes a new instance of the <see cref="BaseService{TModel}"/> class.
        /// </summary>
        public BaseService()
        {
        }

        /// <summary>
        /// Creates the specified model.
        /// </summary>
        /// <param name="model">The model.</param>
        /// <returns>TModel.</returns>
        /// <exception cref="NotImplementedException"></exception>
        public virtual TModel Create(TModel model)
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// Creates the asynchronous.
        /// </summary>
        /// <param name="model">The model.</param>
        /// <returns>Task&lt;TModel&gt;.</returns>
        /// <exception cref="NotImplementedException"></exception>
        public Task<TModel> CreateAsync(TModel model)
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// Creates the range.
        /// </summary>
        /// <param name="models">The models.</param>
        /// <returns>List&lt;TModel&gt;.</returns>
        /// <exception cref="NotImplementedException"></exception>
        public virtual List<TModel> CreateRange(List<TModel> models)
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// Creates the range asynchronous.
        /// </summary>
        /// <param name="models">The models.</param>
        /// <returns>Task&lt;List&lt;TModel&gt;&gt;.</returns>
        /// <exception cref="NotImplementedException"></exception>
        public Task<List<TModel>> CreateRangeAsync(List<TModel> models)
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// Deletes the specified model.
        /// </summary>
        /// <param name="model">The model.</param>
        /// <returns>TModel.</returns>
        /// <exception cref="NotImplementedException"></exception>
        public virtual TModel Delete(TModel model)
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// Deletes the asynchronous.
        /// </summary>
        /// <param name="model">The model.</param>
        /// <returns>Task&lt;TModel&gt;.</returns>
        /// <exception cref="NotImplementedException"></exception>
        public Task<TModel> DeleteAsync(TModel model)
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// Deletes the range.
        /// </summary>
        /// <param name="models">The models.</param>
        /// <returns>List&lt;TModel&gt;.</returns>
        /// <exception cref="NotImplementedException"></exception>
        public virtual List<TModel> DeleteRange(List<TModel> models)
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// Deletes the range asynchronous.
        /// </summary>
        /// <param name="models">The models.</param>
        /// <returns>Task&lt;List&lt;TModel&gt;&gt;.</returns>
        /// <exception cref="NotImplementedException"></exception>
        public Task<List<TModel>> DeleteRangeAsync(List<TModel> models)
        {
            throw new NotImplementedException();
        }

        // Public implementation of Dispose pattern callable by consumers.
        /// <summary>
        /// アンマネージ リソースの解放またはリセットに関連付けられているアプリケーション定義のタスクを実行します。
        /// </summary>
        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        // Protected implementation of Dispose pattern.
        /// <summary>
        /// Releases unmanaged and - optionally - managed resources.
        /// </summary>
        /// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
        protected virtual void Dispose(bool disposing)
        {
            if (disposed)
                return;

            if (disposing)
            {
                handle.Dispose();
                // Free any other managed objects here.
                //
            }

            disposed = true;
        }

        /// <summary>
        /// Gets all.
        /// </summary>
        /// <returns>IQueryable&lt;TModel&gt;.</returns>
        /// <exception cref="NotImplementedException"></exception>
        public virtual IQueryable<TModel> GetAll()
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// Gets all asynchronous.
        /// </summary>
        /// <returns>IQueryable&lt;TModel&gt;.</returns>
        /// <exception cref="NotImplementedException"></exception>
        public IQueryable<TModel> GetAllAsync()
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// Gets the by.
        /// </summary>
        /// <param name="condition">The condition.</param>
        /// <returns>IQueryable&lt;TModel&gt;.</returns>
        /// <exception cref="NotImplementedException"></exception>
        public virtual IQueryable<TModel> GetBy(Expression<Func<TModel, bool>> condition)
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// Gets the by asynchronous.
        /// </summary>
        /// <param name="condition">The condition.</param>
        /// <returns>IQueryable&lt;TModel&gt;.</returns>
        /// <exception cref="NotImplementedException"></exception>
        public IQueryable<TModel> GetByAsync(Expression<Func<TModel, bool>> condition)
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// Updates the specified model.
        /// </summary>
        /// <param name="model">The model.</param>
        /// <returns>TModel.</returns>
        /// <exception cref="NotImplementedException"></exception>
        public virtual TModel Update(TModel model)
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// Updates the asynchronous.
        /// </summary>
        /// <param name="model">The model.</param>
        /// <returns>Task&lt;TModel&gt;.</returns>
        /// <exception cref="NotImplementedException"></exception>
        public Task<TModel> UpdateAsync(TModel model)
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// Updates the range.
        /// </summary>
        /// <param name="models">The models.</param>
        /// <returns>List&lt;TModel&gt;.</returns>
        /// <exception cref="NotImplementedException"></exception>
        public virtual List<TModel> UpdateRange(List<TModel> models)
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// Updates the range asynchronous.
        /// </summary>
        /// <param name="models">The models.</param>
        /// <returns>Task&lt;List&lt;TModel&gt;&gt;.</returns>
        /// <exception cref="NotImplementedException"></exception>
        public Task<List<TModel>> UpdateRangeAsync(List<TModel> models)
        {
            throw new NotImplementedException();
        }
    }
}
