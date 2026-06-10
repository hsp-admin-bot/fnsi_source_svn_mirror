using Fnw.StatisticsTool.Data;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Fnw.StatisticsTool.Models
{
    public class HeightResponse : ISysDataSetResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public List<HeightDataType> Data { get; set; } = new List<HeightDataType>();
    }

    public class HeightDataType
    {
        [JsonProperty("stature")]
        public decimal STATURE { get; set; }

        public HeightDataType() { }

        public HeightDataType(decimal stature)
        {
            STATURE = stature;
        }
    }
}
