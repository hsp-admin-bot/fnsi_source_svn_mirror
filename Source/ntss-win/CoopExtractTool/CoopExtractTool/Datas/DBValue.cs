using System.Collections.Generic;
using System.ComponentModel;

namespace CoopExtractTool.Datas
{

    public class DBDataItem
    {
        public string INI_CLASS { get; set; }
        public string INI_SECTION { get; set; }
        public string INI_KEY { get; set; }
        public string UP_DATE { get; set; }
        public string SECTION_TITLE { get; set; }
        public string KEY_TITLE { get; set; }
        [Browsable(false)]
        public string DATA_TYPE { get; set; }
        public string INI_VALUE { get; set; }
        [Browsable(false)]
        public string MAX_VALUE { get; set; }
        [Browsable(false)]
        public string MIN_VALUE { get; set; }
        public string DEFAULT_VALUE { get; set; }
        public string MEMO { get; set; }
        [Browsable(false)]
        public string SERIES_CD { get; set; }
        public string SHORT_NAME { get; set; }
    }

    public class DBFacilityDataItem
    {
        public string SERIES_CD { get; set; }
        public string SHORT_NAME { get; set; }
    }

    public static class DBDataManager
    {
        public static List<DBDataItem> DBDataList;

        public static List<DBFacilityDataItem> DBFacilityList;

    }
}
