using CsvHelper.Configuration.Attributes;
using System.Collections.Generic;

namespace CoopExtractXMLMaker
{
    /// <summary>
    /// FNSiのCSVファイル読み込み用
    /// </summary>
    public class FNSiDataItem
    {
        [Index(0)]
        public string coop_ini_cd { get; set; }
        public string facility_cd { get; set; }
        public string coop_ini_memo { get; set; }
        public string coop_ini_info { get; set; }
        public string is_disp { get; set; }
        public string is_del { get; set; }
        public string reg_date { get; set; }
        public string up_date { get; set; }
        public string key_mapping { get; set; }
    }

    public static class FNSiDataManager
    {
        // データ実体
        public static List<FNSiDataItem> FNSiDataList;

        // ソート用
        public static int CompareFNSiData(FNSiDataItem a, FNSiDataItem b)
        {
            int result = string.Compare(a.facility_cd, b.facility_cd);
            if (result == 0)
            {
                result = string.Compare(a.coop_ini_cd, b.coop_ini_cd);
            }

            return result;
        }
    }

    public class ComparerFNSiData : IComparer<FNSiDataItem>
    {
        /// <summary>
        /// ソート用関数　数値を数値として比較する
        /// </summary>
        /// <param name="a"></param>
        /// <param name="b"></param>
        /// <returns></returns>
        public int Compare(FNSiDataItem a, FNSiDataItem b)
        {
            int result = Commons.StrCmpLogicalW(a.facility_cd, b.facility_cd);
            if (result == 0)
            {
                result = Commons.StrCmpLogicalW(a.coop_ini_cd, b.coop_ini_cd);
            }

            return result;
        }
    }

}
