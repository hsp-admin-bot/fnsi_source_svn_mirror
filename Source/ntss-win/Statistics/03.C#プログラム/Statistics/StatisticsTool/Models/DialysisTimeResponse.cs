using Fnw.StatisticsTool.Data;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Fnw.StatisticsTool.Models
{
    public class DialysisTimeResponse : ISysDataSetResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public List<DialysisTimeDataType> Data { get; set; } = new List<DialysisTimeDataType>();
    }

    public class DialysisTimeDataType
    {
        [JsonProperty("dialysis_time")]
        public decimal DIALYSIS_TIME { get; set; }

        public DialysisTimeDataType() { }

        public DialysisTimeDataType(decimal dialysisTime)
        {
            DIALYSIS_TIME = dialysisTime;
        }
    }
}
