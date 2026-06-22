using Newtonsoft.Json;

namespace NKKWeightScaleDB.Models
{
    public class Weight_measurement : BaseEntity
    {
        [JsonProperty(PropertyName = "patient_id")]
        public string patient_id { get; set; }

        [JsonProperty(PropertyName = "body_weight")]
        public string body_weight { get; set; }

        [JsonProperty(PropertyName = "measurement_value")]
        public string measurement_value { get; set; }

        [JsonProperty(PropertyName = "wheelchair_weight")]
        public string wheelchair_weight { get; set; }

        [JsonProperty(PropertyName = "tare_info")]
        public string tare_info { get; set; }

        [JsonProperty(PropertyName = "off_water_info")]
        public string off_water_info { get; set; }

        [JsonProperty(PropertyName = "target_weight")]
        public string target_weight { get; set; }

        [JsonProperty(PropertyName = "water_removal_restriction")]
        public string water_removal_restriction { get; set; }

        [JsonProperty(PropertyName = "target_water_removal")]
        public string target_water_removal { get; set; }

        [JsonProperty(PropertyName = "dw")]
        public string dw { get; set; }

        [JsonProperty(PropertyName = "after_last_time")]
        public string after_last_time { get; set; }

        [JsonProperty(PropertyName = "bed_cd")]
        public string bed_cd { get; set; }

        [JsonProperty(PropertyName = "measurement_date")]
        public string measurement_date { get; set; }
    }
}