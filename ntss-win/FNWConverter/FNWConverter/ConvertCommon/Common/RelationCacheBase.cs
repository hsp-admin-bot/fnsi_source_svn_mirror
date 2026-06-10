using System;
using System.Collections.Generic;
using System.Data;

namespace ConvertCommon.Common
{
 
    public class RelationCacheBase
    {
        private readonly Lazy<Dictionary<string, List<DataRow>>> _cache;
        private readonly DataTable _rowTemplate;

        public RelationCacheBase(Func<string> getConvertTableName)
        {
            _cache = new Lazy<Dictionary<string, List<DataRow>>>(() =>
            {
                var tableName = getConvertTableName();
                return Build(tableName);
            }, true);

            var dt = ConvertTss.Get(getConvertTableName());
            _rowTemplate = dt?.Clone(); 
        }

        private Dictionary<string, List<DataRow>> Build(string convertTableName)
        {
            var dict = new Dictionary<string, List<DataRow>>(StringComparer.Ordinal);

            var dt = ConvertTss.Get(convertTableName);
            if (dt == null || dt.Rows.Count == 0)
            {
                return dict;
            }

            foreach (DataRow row in dt.Rows)
            {
                string key = $"{row["FNW_TABLE_NAME"]}|{row["FNW_COLUMN_NAME"]}|";

                if (!dict.TryGetValue(key, out var list))
                {
                    list = new List<DataRow>();
                    dict[key] = list;
                }
                var newRow = _rowTemplate.NewRow();
                newRow.ItemArray = row.ItemArray.Clone() as object[];

                list.Add(newRow);
            }

            return dict;
        }


        public DataRow[] GetRelationArray(string fnwTableName, string fnwColName)
        {
            string key = $"{fnwTableName}|{fnwColName}|";

            return _cache.Value.TryGetValue(key, out var list)
                ? list.ToArray() 
                : new DataRow[0];
        }
    }

}
