using Newtonsoft.Json;

namespace NKKWeightScaleDB.Models
{
    public class Patient : BaseEntity
    {
        [JsonProperty(PropertyName = "PatientID")]
        public string PatientID { get; set; }

        [JsonProperty(PropertyName = "PatientName")]
        public string PatientName { get; set; }
    }
}