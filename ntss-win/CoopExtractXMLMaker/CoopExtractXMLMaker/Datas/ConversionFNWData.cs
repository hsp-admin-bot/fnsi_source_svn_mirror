using System.ComponentModel;

namespace CoopExtractXMLMaker
{
    /// <summary>
    /// FNWリストの表示データ
    /// </summary>
    public class ConversionFNWDataItem
    {
        public string INI_SECTION { get; set; }
        public string INI_KEY { get; set; }
        public string INI_VALUE { get; set; }
        public string DEFAULT_VALUE { get; set; }
        public string KEY_TITLE { get; set; }
        public string MEMO { get; set; }

        [Browsable(false)]
        public int FnwPos { get; set; } = -1;
    }

    public static class ConversionFNWDataManager
    {
        // データ実体
        public static BindingList<ConversionFNWDataItem> ConversionFNWDataList;
    }
}
