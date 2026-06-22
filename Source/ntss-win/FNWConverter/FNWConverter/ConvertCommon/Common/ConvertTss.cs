using Fnw.IOControl.DB;
using System.Collections.Concurrent;
using System.Data;
using System.Linq;


namespace ConvertCommon.Common
{
    public static class ConvertTss
    {
        private static readonly ConcurrentDictionary<string, DataTable> _cache =
        new ConcurrentDictionary<string, DataTable>();

        private static bool _initialized = false;
        private static readonly object _lock = new object();

        public static void Initialize(DBCtrl db)
        {
            if (_initialized) return;

            lock (_lock)
            {
                if (_initialized) return;

                string sql = @"
                select * from (
                    select * from tss_mst
                    union
                    select * from tss_pat
                    union
                    select * from tss_ord
                )
                order by ntss_table_name, ntss_column_no
            ";

                var dtAll = db.SelectTable(sql);

                var groups = dtAll.AsEnumerable()
                    .GroupBy(r => r.Field<string>("NTSS_TABLE_NAME"));

                foreach (var g in groups)
                {
                    var dt = g.CopyToDataTable();
                    _cache[g.Key] = dt;
                }

                _initialized = true;
            }
        }

        public static DataTable Get(string ntssTableName)
        {
            if (_cache.TryGetValue(ntssTableName, out var dt))
                return dt.Copy();

            return null;
        }
    }
}
