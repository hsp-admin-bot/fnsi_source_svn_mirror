using Fnw.IOControl.DB;
using System;
using System.Collections.Generic;
using System.Data;


namespace ConvertCommon.Common
{
    public static class TreatCondSettingCacheExtensions
    {
        
        private static readonly DBCtrl db = ConvertControl.DBConnectFnw();

        public readonly struct TreatCondSetting
        {
            public string TreatItemCd { get; }
            public string CondCtlNo { get; }

            public TreatCondSetting(string treatItemCd, string condCtlNo)
            {
                TreatItemCd = treatItemCd;
                CondCtlNo = condCtlNo;
            }

            public static TreatCondSetting FromDataRow(DataRow row)
            {
                return new TreatCondSetting(
                    treatItemCd: row["TREAT_ITEM_CD"]?.ToString(),
                    condCtlNo: row["COND_CTL_NO"]?.ToString()
                );
            }
        }

        private static readonly Lazy<Dictionary<string, HashSet<string>>> _cache = new Lazy<Dictionary<string, HashSet<string>>>(() =>
        {
            string sql = @"SELECT TREAT_ITEM_CD, COND_CTL_NO FROM SYS_TREAT_COND_SETTING WHERE USE_FLG = '0'";
            DataTable dt = db.SelectTable(sql);

            var dict = new Dictionary<string, HashSet<string>>();

            foreach (DataRow row in dt.Rows)
            {
                string treatItemCd = row["TREAT_ITEM_CD"]?.ToString();
                string condCtlNo = row["COND_CTL_NO"]?.ToString();

                if (!string.IsNullOrEmpty(treatItemCd) && !string.IsNullOrEmpty(condCtlNo))
                {
                    if (!dict.ContainsKey(treatItemCd))
                    {
                        dict[treatItemCd] = new HashSet<string>();
                    }
                    dict[treatItemCd].Add(condCtlNo);
                }
            }

            return dict;
        });

        /// <summary>
        /// 検査治療項目コードと管理番号が条件設定に存在するか確認する
        /// </summary>
        public static bool ContainsCondCtlNo(this string treatItemCd, string ctlNo)
        {
            if (string.IsNullOrEmpty(treatItemCd) || string.IsNullOrEmpty(ctlNo))
                return false;

            return _cache.Value.TryGetValue(treatItemCd, out var ctlNos) && ctlNos.Contains(ctlNo);
        }

        
    }
}