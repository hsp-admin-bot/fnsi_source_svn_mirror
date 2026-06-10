using Fnw.IOControl.DB;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;



namespace ConvertCommon.Common
{
    public  class CacheInformation
    {

        private static readonly CacheInformation _instance = new CacheInformation();
        public static CacheInformation Instance => _instance;
        private  readonly DBCtrl db = ConvertControl.DBConnectFnw();
        private  object _lock = new object();
        private readonly  Dictionary<string, object> _cache = new Dictionary<string, object>();

        // 透析計画開始日キャッシュ
        public DateTime DialysisPlanStartDate
        {
            get => GetOrAdd("DialysisPlanStartDate", () =>
            {
                string sql = @"select TO_DATE(min(IND_START_DATE), 'yyyyMMdd' ) FROMDATE from IND_DIALYSIS_PLAN";
                var result = db.SelectTable(sql);
                return result.Rows.Count > 0 ?
                    DateTime.Parse(result.Rows[0]["FROMDATE"].ToString()) :
                    DateTime.Now;
            });
        }

        // 施設タイプキャッシュ（単一または複数施し）
        public string FacilityCd
        {
            get => GetOrAdd($"FacilityCd_{CommonConfig.seriesCd}", () =>
            {
                string sql_cd = "SELECT VALUE FROM SYS_SYSTEM_DEFINE WHERE ID=450";
                var result = db.SelectTable(sql_cd);
                return result.Rows.Count > 0 ? result.Rows[0]["VALUE"].ToString() : string.Empty;
            });
        }

        //add #122229  前回convertを実行した時刻 start
        public ConvertDatetimeResult GetEffectiveConvertDatetime(string typeKind)
        {
            string typeKey = $"TypeKind_{CommonConfig.FacilityCd}_{typeKind}";

            return GetOrAdd(typeKey, () =>
            {
                string sSql = @"SELECT
                            MIN(convert_datetime) AS MIN_CONVERT_DATETIME,
                            MAX(
                                CASE
                                    WHEN table_name = 'diff' THEN convert_datetime
                                END
                            ) AS MAX_DIFF_CONVERT_DATETIME,
                          COUNT(CASE WHEN table_name = 'diff' THEN 1 END) AS DIFF_CNT
                        FROM sync_convert_history
                        WHERE facility_cd = :facilityCd
                          AND table_kind = :tableKind";
                IMakeSqlParameters param = db.GetIMakeSqlParameters();
                param.AddParam(":tableKind", typeKind);
                param.AddParam(":facilityCd", CommonConfig.FacilityCd);
                DataTable dt = db.SelectTable(sSql, param.GetParam());

                DataRow row = dt.Rows[0];

                DateTime? maxDiffDate = row["MAX_DIFF_CONVERT_DATETIME"] == DBNull.Value
                    ? (DateTime?)null
                    : Convert.ToDateTime(row["MAX_DIFF_CONVERT_DATETIME"]);

                DateTime? minDate = row["MIN_CONVERT_DATETIME"] == DBNull.Value
                     ? (DateTime?)null
                     : Convert.ToDateTime(row["MIN_CONVERT_DATETIME"]);


                DateTime resultDate;
                if (minDate == null && maxDiffDate == null)
                {
                    resultDate = DateTime.Now;
                }
                else {
                    resultDate = maxDiffDate ?? minDate.Value;
                }

                //DateTime resultDate = maxDiffDate ?? minDate.Value;

                bool hasDiff = Convert.ToInt32(row["DIFF_CNT"]) > 0;

                return new ConvertDatetimeResult
                {
                   
                    ConvertDatetime= resultDate,
                    HasDiff = hasDiff
                };

            });
            
        }

        public class ConvertDatetimeResult
        {
            /// <summary>
            ///  前回convertを実行した時刻
            /// </summary>
            public DateTime ConvertDatetime { get; set; }

            /// <summary>
            /// table_name = 『diff』 のレコードは存在しますか？
            /// </summary>
            public bool HasDiff { get; set; }
        }
        //add #122229  前回convertを実行した時刻 end


        public DataTable GetTableKind(string seriesCd)
        {
            string cacheKey = $"TableKind_{seriesCd}";

            return GetOrAdd(cacheKey, () =>
            {
                string sql = @"
            SELECT DISTINCT TABLE_KIND, SERIES_CD
            FROM SYNC_CONVERT_HISTORY c
            INNER JOIN SYNC_FACILITY_CD f
                ON f.FACILITY_CD = c.FACILITY_CD
            WHERE TABLE_KIND IN ('MST','PAT','HIS')";
                return db.SelectTable(sql);
            });
        }

        // <summary>
        /// キャッシュを削除する
        /// </summary>
        public void RefreshAllTableKind()
        {
            lock (_lock)
            {
                var keys = _cache.Keys
                    .Where(k => k.StartsWith("TableKind_"))
                    .ToList();

                foreach (var key in keys)
                {
                    _cache.Remove(key);
                }
            }
        }



        private  T GetOrAdd<T>(string key, Func<T> factory)
        {
            lock (_lock)
            {
                if (!_cache.ContainsKey(key))
                {
                    _cache[key] = factory();
                }
                return (T)_cache[key];
            }
        }
    
    }
}
