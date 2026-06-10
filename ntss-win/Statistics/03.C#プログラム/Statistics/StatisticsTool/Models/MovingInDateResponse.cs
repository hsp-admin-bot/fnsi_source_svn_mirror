using Fnw.StatisticsTool.Data;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Fnw.StatisticsTool.Models
{
    public class MovingInDateResponse : ISysDataSetResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public List<MovingInDateDataType> Data { get; set; } = new List<MovingInDateDataType>();
    }

    public class MovingInDateDataType
    {
        [JsonProperty("reg_date")]
        public string REG_DATE { get; set; }

        [JsonProperty("from_facility_name")]
        public string FROM_FACILITY_NAME { get; set; }

        [JsonProperty("to_facility_name")]
        public string TO_FACILITY_NAME { get; set; }


        public MovingInDateDataType() { }

        public MovingInDateDataType(string reg_date, string from_facility_name, string to_facility_name)
        {
            REG_DATE = reg_date;
            FROM_FACILITY_NAME = from_facility_name;
            TO_FACILITY_NAME = to_facility_name;
        }
    }
}
