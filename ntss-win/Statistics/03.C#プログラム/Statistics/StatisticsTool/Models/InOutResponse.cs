using Fnw.StatisticsTool.Data;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Fnw.StatisticsTool.Models
{
    public class InOutResponse : ISysDataSetResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public List<InOutDataType> Data { get; set; } = new List<InOutDataType>();
    }

    public class InOutDataType
    {
        [JsonProperty("patid")]
        public long PATID { get; set; }

        [JsonProperty("inout_cd")]
        public int INOUT_CD { get; set; }

        [JsonProperty("reg_date")]
        public string  REG_DATE { get; set; }

        public InOutDataType() { }

        public InOutDataType(long patid, int inoutCd, string regDate)
        {
            PATID = patid;
            INOUT_CD = inoutCd;
            REG_DATE = regDate;
        }
    }
}
