namespace NKKWeightScaleDB.Models
{
    using Newtonsoft.Json;

    public class Mst_bed : BaseEntity
    {
        [JsonProperty(PropertyName = "bedCd")]
        public string bed_cd { get; set; }

        [JsonProperty(PropertyName = "facilityCd")]
        public string facility_cd { get; set; }

        [JsonProperty(PropertyName = "bedNo")]
        public string bed_no { get; set; }

        [JsonProperty(PropertyName = "bedName")]
        public string bed_name { get; set; }

        [JsonProperty(PropertyName = "shuntPosition")]
        public string shunt_position { get; set; }

        [JsonProperty(PropertyName = "isInfection")]
        public string is_infection { get; set; }

        [JsonProperty(PropertyName = "emergencyClass")]
        public string emergency_class { get; set; }

        [JsonProperty(PropertyName = "machineNo")]
        public string machine_no { get; set; }

        [JsonProperty(PropertyName = "outputPrinter")]
        public string output_printer { get; set; }

        [JsonProperty(PropertyName = "isAutoprintBefore")]
        public string is_autoprint_before { get; set; }

        [JsonProperty(PropertyName = "isAutoprintAfter")]
        public string is_autoprint_after { get; set; }

        [JsonProperty(PropertyName = "isAutoprintCommit")]
        public string is_autoprint_commit { get; set; }

        [JsonProperty(PropertyName = "fnBedNo")]
        public string fn_bed_no { get; set; }

        [JsonProperty(PropertyName = "isDisp")]
        public string is_disp { get; set; }

        [JsonProperty(PropertyName = "isDel")]
        public string is_del { get; set; }

        [JsonProperty(PropertyName = "regDate")]
        public string reg_date { get; set; }

        [JsonProperty(PropertyName = "upDate")]
        public string up_date { get; set; }

        [JsonProperty(PropertyName = "isHomeDialysis")]
        public string is_home_dialysis { get; set; }
    }
}