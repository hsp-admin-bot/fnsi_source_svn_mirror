using Fnw.StatisticsTool.Data;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Fnw.StatisticsTool.Models
{
    public class OrdMainOtherPatDataResponse : ISysDataSetResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public List<OrdMainOtherPatDataType> Data { get; set; } = new List<OrdMainOtherPatDataType>();
    }

    public class OrdMainOtherPatDataType
    {
        [JsonProperty("patid")]
        public long PATID { get; set; }

        [JsonProperty("dial_start_date")]
        public string DIAL_START_DATE { get; set; }

        [JsonProperty("institution_cd")]
        public string INSTITUTION_CD { get; set; }

        public OrdMainOtherPatDataType() { }

        public OrdMainOtherPatDataType(long patId, string dialStartDate, string institutionCd)
        {
            PATID = patId;
            DIAL_START_DATE = dialStartDate;
            INSTITUTION_CD = institutionCd;
        }
    }
}
