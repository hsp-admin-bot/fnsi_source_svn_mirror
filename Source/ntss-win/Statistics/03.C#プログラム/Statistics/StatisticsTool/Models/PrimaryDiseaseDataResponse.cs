using Fnw.StatisticsTool.Data;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Fnw.StatisticsTool.Models
{
    public class PrimaryDiseaseDataResponse : ISysDataSetResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public List<PrimaryDiseaseDataType> Data { get; set; } = new List<PrimaryDiseaseDataType>();
    }

    public class PrimaryDiseaseDataType
    {
        [JsonProperty("col_fnw_code")]
        public int COL_FNW_CODE { get; set; }

        public PrimaryDiseaseDataType() { }

        public PrimaryDiseaseDataType(int colFnwCode)
        {
            COL_FNW_CODE = colFnwCode;
        }
    }
}
