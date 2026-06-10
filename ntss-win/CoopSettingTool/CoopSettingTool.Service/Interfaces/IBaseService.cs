// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 04-16-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-16-2021
// ***********************************************************************
// <copyright file="IBaseService.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Threading.Tasks;

namespace CoopSettingTool.Service
{
    /// <summary>
    /// Interface IBaseService
    /// Implements the <see cref="System.IDisposable" />
    /// </summary>
    /// <typeparam name="T"></typeparam>
    /// <seealso cref="System.IDisposable" />
    public interface IBaseService<T> : IDisposable where T : class
    {
        /// <summary>
        /// Gets all.
        /// </summary>
        /// <returns>IQueryable&lt;T&gt;.</returns>
        IQueryable<T> GetAll();

        /// <summary>
        /// Gets the by.
        /// </summary>
        /// <param name="condition">The condition.</param>
        /// <returns>IQueryable&lt;T&gt;.</returns>
        IQueryable<T> GetBy(Expression<Func<T, bool>> condition);

        /// <summary>
        /// Creates the specified model.
        /// </summary>
        /// <param name="model">The model.</param>
        /// <returns>T.</returns>
        T Create(T model);

        /// <summary>
        /// Updates the specified model.
        /// </summary>
        /// <param name="model">The model.</param>
        /// <returns>T.</returns>
        T Update(T model);

        /// <summary>
        /// Deletes the specified model.
        /// </summary>
        /// <param name="model">The model.</param>
        /// <returns>T.</returns>
        T Delete(T model);

        /// <summary>
        /// Creates the range.
        /// </summary>
        /// <param name="models">The models.</param>
        /// <returns>List&lt;T&gt;.</returns>
        List<T> CreateRange(List<T> models);

        /// <summary>
        /// Updates the range.
        /// </summary>
        /// <param name="models">The models.</param>
        /// <returns>List&lt;T&gt;.</returns>
        List<T> UpdateRange(List<T> models);

        /// <summary>
        /// Deletes the range.
        /// </summary>
        /// <param name="models">The models.</param>
        /// <returns>List&lt;T&gt;.</returns>
        List<T> DeleteRange(List<T> models);

        /// <summary>
        /// Gets all asynchronous.
        /// </summary>
        /// <returns>IQueryable&lt;T&gt;.</returns>
        IQueryable<T> GetAllAsync();

        /// <summary>
        /// Gets the by asynchronous.
        /// </summary>
        /// <param name="condition">The condition.</param>
        /// <returns>IQueryable&lt;T&gt;.</returns>
        IQueryable<T> GetByAsync(Expression<Func<T, bool>> condition);

        /// <summary>
        /// Creates the asynchronous.
        /// </summary>
        /// <param name="model">The model.</param>
        /// <returns>Task&lt;T&gt;.</returns>
        Task<T> CreateAsync(T model);

        /// <summary>
        /// Updates the asynchronous.
        /// </summary>
        /// <param name="model">The model.</param>
        /// <returns>Task&lt;T&gt;.</returns>
        Task<T> UpdateAsync(T model);

        /// <summary>
        /// Deletes the asynchronous.
        /// </summary>
        /// <param name="model">The model.</param>
        /// <returns>Task&lt;T&gt;.</returns>
        Task<T> DeleteAsync(T model);

        /// <summary>
        /// Creates the range asynchronous.
        /// </summary>
        /// <param name="models">The models.</param>
        /// <returns>Task&lt;List&lt;T&gt;&gt;.</returns>
        Task<List<T>> CreateRangeAsync(List<T> models);

        /// <summary>
        /// Updates the range asynchronous.
        /// </summary>
        /// <param name="models">The models.</param>
        /// <returns>Task&lt;List&lt;T&gt;&gt;.</returns>
        Task<List<T>> UpdateRangeAsync(List<T> models);

        /// <summary>
        /// Deletes the range asynchronous.
        /// </summary>
        /// <param name="models">The models.</param>
        /// <returns>Task&lt;List&lt;T&gt;&gt;.</returns>
        Task<List<T>> DeleteRangeAsync(List<T> models);
    }
}
