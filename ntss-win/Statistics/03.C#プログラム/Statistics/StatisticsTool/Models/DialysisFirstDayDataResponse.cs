using Fnw.StatisticsTool.Data;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Fnw.StatisticsTool.Models
{
    public class DialysisFirstDayDataResponse : ISysDataSetResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public List<DialysisFirstDayDataType> Data { get; set; } = new List<DialysisFirstDayDataType>();
    }

    public class DialysisFirstDayDataType
    {
        [JsonProperty("dialysis_date")]
        public string DIALYSIS_DATE { get; set; }

        public DialysisFirstDayDataType() { }

        public DialysisFirstDayDataType(string dialysis_date)
        {
            DIALYSIS_DATE = dialysis_date;
        }
    }
}
