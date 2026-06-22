using Fnw.StatisticsTool.Data;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Fnw.StatisticsTool.Models
{
    public class PatUniqueInitDateResponse : ISysDataSetResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public List<PatUniqueInitDateDataType> Data { get; set; } = new List<PatUniqueInitDateDataType>();
    }

    public class PatUniqueInitDateDataType
    {
        [JsonProperty("reg_date")]
        public string REG_DATE { get; set; }

        [JsonProperty("from_facility")]
        public string FROM_FACILITY { get; set; }

        public PatUniqueInitDateDataType() { }

        public PatUniqueInitDateDataType(string reg_date, string from_facility)
        {
            REG_DATE = reg_date;
            FROM_FACILITY = from_facility;
        }
    }
}
