using System.Collections.Generic;
using System.ComponentModel;

namespace CoopExtractTool.Datas
{

    public class CSVDataItem
    {
        public string key0 { get; set; }
        public string key1 { get; set; }
        public string key2 { get; set; }
        public string value { get; set; }
        public string comment { get; set; }
        public string default_v { get; set; }

        /// <summary>
        /// 除外されるか？
        /// </summary>
        [Browsable(false)]
        public bool isExclude { get; set; } = false;
    }

    public static class CSVDataManager
    {
        public static List<CSVDataItem> CSVDataList;

        public static string key0;

    }
}
