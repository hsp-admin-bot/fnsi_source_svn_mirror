using Fnw.StatisticsTool.Data;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Fnw.StatisticsTool.Models
{
    public class PatDieDataResponse : ISysDataSetResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public List<PatDieDataType> Data { get; set; } = new List<PatDieDataType>();
    }

    public class PatDieDataType
    {
        [JsonProperty("col_fnw_code")]
        public string COL_FNW_CODE { get; set; }

        [JsonProperty("col_fnw_name")]
        public string COL_FNW_NAME { get; set; }

        public PatDieDataType() { }

        public PatDieDataType(string colFnwCode, string colFnwName)
        {
            COL_FNW_CODE = colFnwCode;
            COL_FNW_NAME = colFnwName;
        }
    }
}
