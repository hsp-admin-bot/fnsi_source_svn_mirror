// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 05-19-2022
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-19-2022
// ***********************************************************************
// <copyright file="HashCodeByPropertyExtensions.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using System.Collections.Generic;
using System.Linq;

namespace CoopSettingTool.Service.Extendsions
{
    /// <summary>
    /// Class HashCodeByPropertyExtensions.
    /// </summary>
    public static class HashCodeByPropertyExtensions
    {
        /// <summary>
        /// Gets the hash code on properties.
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="inspect">The inspect.</param>
        /// <returns>System.Int32.</returns>
        public static int GetHashCodeOnProperties<T>(this T inspect)
        {
            return inspect.GetType().GetProperties( System.Reflection.BindingFlags.Instance 
                | System.Reflection.BindingFlags.Public 
                | System.Reflection.BindingFlags.NonPublic 
                | System.Reflection.BindingFlags.DeclaredOnly)
                .Select(o => o.GetValue(inspect)).GetListHashCode();
        }

        /// <summary>
        /// Gets the list hash code.
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="sequence">The sequence.</param>
        /// <returns>System.Int32.</returns>
        public static int GetListHashCode<T>(this IEnumerable<T> sequence)
        {
            return sequence
            .Where(item => item != null)
            .Select(item => item.GetHashCode())
            .Aggregate((total, nextCode) => total ^ nextCode);
        }
    }
}
