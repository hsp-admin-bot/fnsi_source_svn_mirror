using Fnw.StatisticsTool.Data;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Fnw.StatisticsTool.Models
{
    public class DialysisCountInRangeResponse : ISysDataSetResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public List<DialysisCountInRangeDataType> Data { get; set; } = new List<DialysisCountInRangeDataType>();
    }

    public class DialysisCountInRangeDataType
    {
        [JsonProperty("count")]
        public long COUNT { get; set; }

        public DialysisCountInRangeDataType() { }

        public DialysisCountInRangeDataType(long count)
        {
            COUNT = count;
        }
    }
}
