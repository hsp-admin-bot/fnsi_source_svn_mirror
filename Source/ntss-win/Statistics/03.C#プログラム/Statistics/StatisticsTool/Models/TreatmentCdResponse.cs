using Fnw.StatisticsTool.Data;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Fnw.StatisticsTool.Models
{
    public class TreatmentCdResponse : ISysDataSetResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public List<TreatmentCdDataType> Data { get; set; } = new List<TreatmentCdDataType>();
    }

    public class TreatmentCdDataType
    {
        [JsonProperty("value")]
        public string VALUE { get; set; }

        public TreatmentCdDataType() { }

        public TreatmentCdDataType(string value)
        {
            VALUE = value;
        }
    }
}
