using Fnw.IOControl.DB;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;

namespace ConvertCommon.Common
{
    public static class TreatItemCacheExtensions
    {

        private static readonly DBCtrl db = ConvertControl.DBConnectFnw(); 
        public readonly struct TreatItem
        {
            public string TreatItemCd { get; }
            public string DeviceMode { get; }
            public DateTime? RegDate { get; }
            public string TreatItemName { get; }

            public TreatItem(string treatItemCd, string deviceMode, DateTime? regDate, string treatItemName)
            {
                TreatItemCd = treatItemCd;
                DeviceMode = deviceMode;
                RegDate = regDate;
                TreatItemName = treatItemName;
            }

            public static TreatItem FromDataRow(DataRow row)
            {
                return new TreatItem(
                    treatItemCd: row["TREAT_ITEM_CD"]?.ToString(),
                    deviceMode: row["DEVICE_MODE"]?.ToString(),
                    treatItemName: row["TREAT_ITEM_NAME"]?.ToString(),
                    regDate: row["REG_DATE"] as DateTime?
                );
            }
           

        }

        private static readonly Lazy<Dictionary<string, List<TreatItem>>> _cache = new Lazy<Dictionary<string, List<TreatItem>>>(() =>
        {
            string sql = "SELECT TREAT_ITEM_CD, DEVICE_MODE,TREAT_ITEM_NAME, REG_DATE FROM MST_TREAT_ITEM ORDER BY REG_DATE DESC";
            DataTable dt = db.SelectTable(sql);

            var dict = new Dictionary<string, List<TreatItem>>();

            foreach (DataRow row in dt.Rows)
            {
                string treatItemCd = row["TREAT_ITEM_CD"]?.ToString();
                if (!string.IsNullOrEmpty(treatItemCd))
                {
                    var item = TreatItem.FromDataRow(row);
                    if (!dict.ContainsKey(treatItemCd))
                    {
                        dict[treatItemCd] = new List<TreatItem>();
                    }
                    dict[treatItemCd].Add(item);
                }
            }

            return dict;
        });

        public static TreatItem GetCachedTreatItem(this string treatItemCd, DateTime upDate)
        {
            if (_cache.Value.TryGetValue(treatItemCd, out var items))
            {
                var matchedItem = items
                    .Where(item => item.RegDate < upDate)
                    .OrderByDescending(item => item.RegDate)
                    .FirstOrDefault();

                return matchedItem;
            }
            return new TreatItem();
        }

        /// <summary>
        /// デバイスモードを取得する
        /// </summary>
        public static string GetCachedDeviceMode(this string treatItemCd, DateTime upDate)
        {
            var item = treatItemCd.GetCachedTreatItem(upDate);
            return item.DeviceMode;
        }

        /// <summary>
        /// 治療プログラム名を取得する
        /// </summary>
        public static string GetCachedTreatItemName(this string treatItemCd, DateTime upDate)
        {
            var item = treatItemCd.GetCachedTreatItem(upDate);
            return item.TreatItemName;
        }

        


    }
}