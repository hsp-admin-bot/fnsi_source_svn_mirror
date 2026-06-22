// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 04-16-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-16-2021
// ***********************************************************************
// <copyright file="ResponseConvert.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.Service.Models;
using Newtonsoft.Json;

namespace CoopSettingTool.Service.Extendsions
{
    /// <summary>
    /// Class ResponseConvert.
    /// </summary>
    public static class ResponseConvert
    {
        /// <summary>
        /// Converts to class.
        /// </summary>
        /// <typeparam name="TEntity">The type of the t entity.</typeparam>
        /// <typeparam name="TResult">The type of the t result.</typeparam>
        /// <param name="obj">The object.</param>
        /// <returns>TResult.</returns>
        public static TResult ToClass<TEntity, TResult>(this BaseResponse<TEntity> obj) where TEntity : class
        {
            var settings = new JsonSerializerSettings
            {
                NullValueHandling = NullValueHandling.Ignore,
                MissingMemberHandling = MissingMemberHandling.Ignore
            };
            var json = JsonConvert.SerializeObject(obj, settings);
            var outData = JsonConvert.DeserializeObject<TResult>(json, settings);
            return outData;
        }

        /// <summary>
        /// Asssigns the specified object.
        /// </summary>
        /// <typeparam name="TEntity">The type of the t entity.</typeparam>
        /// <typeparam name="TResult">The type of the t result.</typeparam>
        /// <param name="obj">The object.</param>
        /// <returns>TResult.</returns>
        public static TResult Asssign<TEntity, TResult>(this TEntity obj) where TEntity : class
        {
            var settings = new JsonSerializerSettings
            {
                NullValueHandling = NullValueHandling.Ignore,
                MissingMemberHandling = MissingMemberHandling.Ignore
            };
            var json = JsonConvert.SerializeObject(obj, settings);
            var outData = JsonConvert.DeserializeObject<TResult>(json, settings);
            return outData;
        }
    }
}
