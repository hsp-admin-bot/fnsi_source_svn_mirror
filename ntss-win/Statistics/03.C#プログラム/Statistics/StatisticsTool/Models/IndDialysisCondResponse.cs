using Fnw.StatisticsTool.Data;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Fnw.StatisticsTool.Models
{
    public class IndDialysisCondResponse : ISysDataSetResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public List<IndDialysisCondDataType> Data { get; set; } = new List<IndDialysisCondDataType>();
    }

    public class IndDialysisCondDataType
    {
        [JsonProperty("value")]
        public string VALUE { get; set; }

        public IndDialysisCondDataType(string value)
        {
            VALUE = value;
        }
    }
}
