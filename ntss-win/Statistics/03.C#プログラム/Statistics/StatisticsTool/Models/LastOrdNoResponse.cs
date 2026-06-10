using Fnw.StatisticsTool.Data;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Fnw.StatisticsTool.Models
{
    public class LastOrdNoResponse : ISysDataSetResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public List<LastOrdNoDataType> Data { get; set; } = new List<LastOrdNoDataType>();
    }

    public class LastOrdNoDataType
    {
        [JsonProperty("dialysis_no")]
        public long? DIALYSIS_NO { get; set; }

        public LastOrdNoDataType() { }

        public LastOrdNoDataType(long? dialysisNo)
        {
            DIALYSIS_NO = dialysisNo;
        }
    }
}
