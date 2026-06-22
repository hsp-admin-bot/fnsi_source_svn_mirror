// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 04-16-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-16-2021
// ***********************************************************************
// <copyright file="Dictionnary.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using Newtonsoft.Json;
using System.Collections.Generic;

namespace CoopSettingTool.Service.Extendsions
{
    /// <summary>
    /// Class Dictionnary.
    /// </summary>
    public static class Dictionnary
    {
        /// <summary>
        /// Converts to dictionary.
        /// </summary>
        /// <typeparam name="TValue">The type of the t value.</typeparam>
        /// <param name="obj">The object.</param>
        /// <returns>Dictionary&lt;System.String, TValue&gt;.</returns>
        public static Dictionary<string, TValue> ToDictionary<TValue>(this object obj)
        {
            var settings = new JsonSerializerSettings
            {
                NullValueHandling = NullValueHandling.Ignore,
                MissingMemberHandling = MissingMemberHandling.Ignore
            };
            var json = JsonConvert.SerializeObject(obj, settings);
            var dictionary = JsonConvert.DeserializeObject<Dictionary<string, TValue>>(json, settings);
            return dictionary;
        }
    }
}
