namespace NKKWeightScaleDB.Models
{
    using Newtonsoft.Json;

    public class Mst_Wheel_Chair : BaseEntity
    {
        [JsonProperty(PropertyName = "wheelChairCd")]
        public string wheel_chair_cd { get; set; }

        [JsonProperty(PropertyName = "facilityCd")]
        public string facility_cd { get; set; }

        [JsonProperty(PropertyName = "fnWheelChairCd")]
        public string fn_wheel_chair_cd { get; set; }

        [JsonProperty(PropertyName = "wheelChairName")]
        public string wheel_chair_name { get; set; }

        [JsonProperty(PropertyName = "wheelChairWeight")]
        public string wheel_chair_weight { get; set; }

        [JsonProperty(PropertyName = "scaleDate")]
        public string scale_date { get; set; }

        [JsonProperty(PropertyName = "scaleUserId")]
        public string scale_user_id { get; set; }

        [JsonProperty(PropertyName = "isPersonal")]
        public string is_personal { get; set; }

        [JsonProperty(PropertyName = "patId")]
        public string pat_id { get; set; }

        [JsonProperty(PropertyName = "isDisp")]
        public string is_disp { get; set; }

        [JsonProperty(PropertyName = "isDel")]
        public string is_del { get; set; }

        [JsonProperty(PropertyName = "regDate")]
        public string reg_date { get; set; }

        [JsonProperty(PropertyName = "upDate")]
        public string up_date { get; set; }
    }
}