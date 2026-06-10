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
    public class ExamItemDataResponse : ISysDataSetResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public List<ExamItemDataType> Data { get; set; } = new List<ExamItemDataType>();
    }

    public class ExamItemDataType
    {
        [JsonProperty("col_fnw_code")]
        public long COL_FNW_CODE { get; set; }

        [JsonProperty("col_fnw_name")]
        public string COL_FNW_NAME { get; set; }

        public ExamItemDataType() { }

        public ExamItemDataType(long colFnwCode, string colFnwName)
        {
            COL_FNW_CODE = colFnwCode;
            COL_FNW_NAME = colFnwName;
        }
    }
}
