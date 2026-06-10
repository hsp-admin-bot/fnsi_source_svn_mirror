using CsvHelper.Configuration.Attributes;
using System.Collections.Generic;

namespace CoopExtractXMLMaker
{
    /// <summary>
    /// FNWのCSVファイル読み込み用
    /// </summary>
    public class FNWDataItem
    {
        [Index(0)]
        public string INI_CLASS { get; set; }
        public string INI_SECTION { get; set; }
        public string INI_KEY { get; set; }
        public string UP_DATE { get; set; }
        public string SECTION_TITLE { get; set; }
        public string KEY_TITLE { get; set; }
        public string DATA_TYPE { get; set; }
        public string INI_VALUE { get; set; }
        public string MAX_VALUE { get; set; }
        public string MIN_VALUE { get; set; }
        public string DEFAULT_VALUE { get; set; }
        public string MEMO { get; set; }
        public string SERIES_CD { get; set; }
    }

    public static class FNWDataManager
    {
        // データ実体
        public static List<FNWDataItem> FNWDataList;

        // ソート用
        public static int CompareFNWData(FNWDataItem a, FNWDataItem b)
        {
            int result = string.Compare(a.INI_SECTION, b.INI_SECTION);
            if (result == 0)
            {
                result = string.Compare(a.INI_KEY, b.INI_KEY);
            }


            return result;
        }
    }

    public class ComparerFNWData : IComparer<FNWDataItem>
    {
        /// <summary>
        /// ソート用関数　数値を数値として比較する
        /// </summary>
        /// <param name="a"></param>
        /// <param name="b"></param>
        /// <returns></returns>
        public int Compare(FNWDataItem a, FNWDataItem b)
        {
            int result = Commons.StrCmpLogicalW(a.INI_SECTION, b.INI_SECTION);
            if (result == 0)
            {
                result = Commons.StrCmpLogicalW(a.INI_KEY, b.INI_KEY);
            }

            return result;
        }
    }

}
