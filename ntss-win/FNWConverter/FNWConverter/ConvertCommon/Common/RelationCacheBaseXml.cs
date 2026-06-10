using System;
using System.Collections.Generic;
using System.Data;

namespace ConvertCommon.Common
{
    class RelationCacheBaseXml
    {
        private readonly Lazy<Dictionary<string, List<DataRow>>> _cache;
        private static readonly Dictionary<string, Lazy<Dictionary<string, List<DataRow>>>> _globalCache
    = new Dictionary<string, Lazy<Dictionary<string, List<DataRow>>>>();

        public RelationCacheBaseXml(Func<string> getConvertTableName)
        {
            string tableName = getConvertTableName();

            if (!_globalCache.TryGetValue(tableName, out var lazy))
            {
                lazy = new Lazy<Dictionary<string, List<DataRow>>>(() => Build(tableName), true);
                _globalCache[tableName] = lazy;
            }

            _cache = lazy;
        }

        private Dictionary<string, List<DataRow>> Build(string convertTableName)
        {
            var dict = new Dictionary<string, List<DataRow>>(StringComparer.Ordinal);

            var dt = ConvertTss.Get(convertTableName);

            if (dt == null || dt.Rows.Count == 0)
            {
                return null;
            }

            foreach (DataRow row in dt.Rows)
            {
                string key = $"{row["XML_CONFIG_NAME"]}|{row["FNW_COLUMN_NAME"]}|";

                if (!dict.TryGetValue(key, out var list))
                {
                    list = new List<DataRow>();
                    dict[key] = list;
                }

                list.Add(row);
            }

            return dict;
        }

        public DataRow[] GetRelationArray(string xmlName, string fnwColName)
        {
            string key = $"{xmlName}|{fnwColName}|";
            return _cache.Value.TryGetValue(key, out var list)
                ? list.ToArray()
                : new DataRow[0];
        }
    }
}
