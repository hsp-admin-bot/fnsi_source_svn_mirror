// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 04-11-2022
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-11-2022
// ***********************************************************************
// <copyright file="CsvExtensions.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace CoopSettingTool.Service.Extendsions
{
    /// <summary>
    /// Class CsvExtensions.
    /// </summary>
    public static class CsvExtensions
    {
        /// <summary>
        /// The separator
        /// </summary>
        private static string separator = ",";
        /// <summary>
        /// Converts to csv.
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="objectlist">The objectlist.</param>
        /// <returns>System.String.</returns>
        public static string ToCsv<T>(this IEnumerable<T> objectlist)
        {
            Type t = typeof(T);
            PropertyInfo[] properties = t.GetProperties(System.Reflection.BindingFlags.Instance
                | System.Reflection.BindingFlags.Public
                | System.Reflection.BindingFlags.NonPublic
                | System.Reflection.BindingFlags.DeclaredOnly);

            string header = String.Join(separator, properties.Select(f => f.Name).ToArray());

            StringBuilder csvdata = new StringBuilder();
            csvdata.AppendLine(header);

            foreach (var o in objectlist)
                csvdata.AppendLine(ToCsvProperties(separator, properties, o));

            return csvdata.ToString();
        }

        /// <summary>
        /// Converts to csvproperties.
        /// </summary>
        /// <param name="separator">The separator.</param>
        /// <param name="properties">The properties.</param>
        /// <param name="o">The o.</param>
        /// <returns>System.String.</returns>
        public static string ToCsvProperties(string separator, PropertyInfo[] properties, object o)
        {
            StringBuilder linie = new StringBuilder();

            foreach (var f in properties)
            {
                if (linie.Length > 0)
                    linie.Append(separator);

                var x = f.GetValue(o);

                if (x != null)
                {
                    // RFC 4180: 値内のダブルクォートは "" にエスケープ
                    string value = x.ToString().Replace("\"", "\"\"");
                    linie.Append("\"");
                    linie.Append(value);
                    linie.Append("\"");
                }
            }

            return linie.ToString();
        }
    }
}
