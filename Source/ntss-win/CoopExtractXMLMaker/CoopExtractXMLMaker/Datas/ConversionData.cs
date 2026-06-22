using System.ComponentModel;

namespace CoopExtractXMLMaker
{
    /// <summary>
    /// FNSiリストの表示データ
    /// </summary>
    public class ConversionDataItem
    {
        [DisplayName("変換対象")]
        public string ConvTarget { get; set; }

        public string key1 { get; set; }
        public string key2 { get; set; }
        public string value { get; set; }
        public string default_v { get; set; } = "";
        public string comment { get; set; } = "";
        [DisplayName("")]
        public string To { get; set; } = "◀";
        public string INI_SECTION { get; set; }
        public string INI_KEY { get; set; }
        public string INI_VALUE { get; set; }
        public string DEFAULT_VALUE { get; set; }
        public string KEY_TITLE { get; set; }
        public string MEMO { get; set; }

        [Browsable(false)]
        public int FnwPos { get; set; } = -1;
        [Browsable(false)]
        public bool Is_TempAdd { get; set; } = false;
    }

    public static class ConversionDataManager
    {
        // データ実体
        public static BindingList<ConversionDataItem> ConversionDataList;
    }


}
