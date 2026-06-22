using Fnw.StatisticsTool.Data;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Fnw.StatisticsTool.Models
{
    public class FacilityDataResponse : ISysDataSetResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public List<FacilityDataType> Data { get; set; } = new List<FacilityDataType>();
    }

    public class FacilityDataType
    {
        [JsonProperty("col_fnw_code")]
        public string COL_FNW_CODE { get; set; }

        [JsonProperty("col_fnw_name")]
        public string COL_FNW_NAME { get; set; }

        public FacilityDataType() { }

        public FacilityDataType(string colFnwCode, string colFnwName)
        {
            COL_FNW_CODE = colFnwCode;
            COL_FNW_NAME = colFnwName;
        }
    }
}
