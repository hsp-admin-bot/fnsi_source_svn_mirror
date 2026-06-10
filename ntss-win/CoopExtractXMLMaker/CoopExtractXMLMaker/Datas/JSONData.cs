using System.Collections.Generic;

namespace CoopExtractXMLMaker
{
    /// <summary>
    /// FNSiのJSONデータ読み込み用
    /// </summary>
    public class JSONDataItem
    {
        public string key0 { get; set; }
        public string key1 { get; set; }
        public string key2 { get; set; }
        public string value { get; set; }
        public string comment { get; set; }
        public string default_v { get; set; }
        public string is_effect { get; set; }
    }

    public static class JSONDataManager
    {
        // データ実体
        public static List<JSONDataItem> JSONDataList;

        // ソート用
        public static int CompareJSONData(JSONDataItem a, JSONDataItem b)
        {
            int result = string.Compare(a.key1, b.key1);
            if (result == 0)
            {
                result = string.Compare(a.key2, b.key2);
            }

            return result;
        }
    }

    public class ComparerJSONData : IComparer<JSONDataItem>
    {
        /// <summary>
        /// ソート用関数　数値を数値として比較する
        /// </summary>
        /// <param name="a"></param>
        /// <param name="b"></param>
        /// <returns></returns>
        public int Compare(JSONDataItem a, JSONDataItem b)
        {

            int result = Commons.StrCmpLogicalW(a.key1, b.key1);
            if (result == 0)
            {
                result = Commons.StrCmpLogicalW(a.key2, b.key2);
            }

            return result;
        }
    }

}
