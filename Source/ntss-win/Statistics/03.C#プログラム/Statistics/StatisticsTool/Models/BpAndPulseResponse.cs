using Fnw.StatisticsTool.Data;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Fnw.StatisticsTool.Models
{
    public class BpAndPulseResponse : ISysDataSetResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public List<BpAndPulseDataType> Data { get; set; } = new List<BpAndPulseDataType>();
    }

    public class BpAndPulseDataType
    {
        [JsonProperty("bp_before")]
        public decimal? BP_BEFORE { get; set; }

        [JsonProperty("bp_after")]
        public decimal? BP_AFTER { get; set; }

        [JsonProperty("pulse")]
        public decimal? PULSE { get; set; }

        public BpAndPulseDataType() { }

        public BpAndPulseDataType(decimal? bpBefore, decimal? bpAfter, decimal? pulse)
        {
            BP_BEFORE = bpBefore;
            BP_AFTER = bpAfter;
            PULSE = pulse;
        }
    }
}
