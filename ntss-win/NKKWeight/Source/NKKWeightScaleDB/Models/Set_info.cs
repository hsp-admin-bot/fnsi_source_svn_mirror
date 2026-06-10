using Newtonsoft.Json;

namespace NKKWeightScaleDB.Models
{
    public class Set_info : BaseEntity
    {
        [JsonProperty(PropertyName = "patient_id")]
        public string patient_id { get; set; }

        [JsonProperty(PropertyName = "target_weight")]
        public string target_weight { get; set; }

        [JsonProperty(PropertyName = "water_removal_restriction")]
        public string water_removal_restriction { get; set; }

        [JsonProperty(PropertyName = "tare_info")]
        public string tare_info { get; set; }

        [JsonProperty(PropertyName = "off_water_info")]
        public string off_water_info { get; set; }
    }
}