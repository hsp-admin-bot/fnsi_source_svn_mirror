using Fnw.StatisticsTool.Data;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Fnw.StatisticsTool.Models
{
    public class RstDialysisCondResponse : ISysDataSetResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public List<RstDialysisCondDataType> Data { get; set; } = new List<RstDialysisCondDataType>();
    }

    public class RstDialysisCondDataType
    {
        [JsonProperty("value")]
        public string VALUE { get; set; }

        public RstDialysisCondDataType(string value)
        {
            VALUE = value;
        }
    }
}
