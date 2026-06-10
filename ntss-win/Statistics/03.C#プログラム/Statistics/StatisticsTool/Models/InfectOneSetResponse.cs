using Fnw.StatisticsTool.Data;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using System.Threading.Tasks;

namespace Fnw.StatisticsTool.Models
{
    public class InfectOneSetResponse : ISysDataSetResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public List<InfectOneSetDataType> Data { get; set; } = new List<InfectOneSetDataType>();
    }

    public class InfectOneSetDataType
    {
        [JsonProperty("infect")]
        public string INFECT { get; set; }

        [JsonProperty("infection_cd")]
        public int INFECTION_CD { get; set; }

        public InfectOneSetDataType() { }

        public InfectOneSetDataType(string infect, int infectionCd)
        {
            INFECT = infect;
            INFECTION_CD = infectionCd;
        }
    }
}
