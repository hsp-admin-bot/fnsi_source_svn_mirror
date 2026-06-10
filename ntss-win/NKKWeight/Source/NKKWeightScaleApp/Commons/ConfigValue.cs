namespace NKKWeightScaleApp.Commons
{
    public class ConfigValue
    {
        public static readonly string UNIT_KG = "kg";
        public static readonly string UNIT_G = "g";
        public static readonly string FORMAT = "{0:0.##}";
        public static readonly int MAX_VALUE = 300;
        public static readonly int MIN_VALUE = 0;
        public static readonly int COUNT_COMMON = 5;
        public static readonly string CONFIG_CSV = "Settings\\CSV";
        public static readonly string BED_NAME_DEFAULT = "ベッド選択";
        public static readonly string SAVE_NAME = "保存";
        public static readonly string SEND_NAME = "送信";
        public static readonly string NOT_DETERMINED = "未確定";
        public enum COMMON_STATUS
        {
            TARE_INFO = 1,
            OFF_WATER_INFO = 2,
        }
    }
}