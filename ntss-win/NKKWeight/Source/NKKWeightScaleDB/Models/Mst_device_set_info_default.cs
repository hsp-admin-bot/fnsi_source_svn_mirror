namespace NKKWeightScaleDB.Models
{
    using Newtonsoft.Json;

    public class Mst_device_set_info_default : BaseEntity
    {
        [JsonProperty(PropertyName = "facilityCd")]
        public string facility_cd { get; set; }

        [JsonProperty(PropertyName = "deviceInfo")]
        public string device_set_info { get; set; }

        [JsonProperty(PropertyName = "tare_info")]
        public string tare_info { get; set; }

        [JsonProperty(PropertyName = "off_water_info")]
        public string off_water_info { get; set; }

        [JsonProperty(PropertyName = "regDate")]
        public string reg_date { get; set; }

        [JsonProperty(PropertyName = "upDate")]
        public string up_date { get; set; }
    }
}