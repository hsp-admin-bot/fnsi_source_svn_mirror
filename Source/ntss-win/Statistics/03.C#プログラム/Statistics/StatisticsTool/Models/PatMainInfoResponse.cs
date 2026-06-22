using Fnw.StatisticsTool.Data;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Fnw.StatisticsTool.Models
{
    public class PatMainInfoResponse : ISysDataSetResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public List<PatMainInfoDataType> Data { get; set; } = new List<PatMainInfoDataType>();
    }

    public class PatMainInfoDataType
    {
        [JsonProperty("patid")]
        public long PATID { get; set; }

        [JsonProperty("institution_cd")]
        public string INSTITUTION_CD { get; set; }

        [JsonProperty("dial_start_date")]
        public string DIAL_START_DATE { get; set; }

        [JsonProperty("diabetes")]
        public string DIABETES { get; set; }

        public PatMainInfoDataType() { }

        public PatMainInfoDataType(long patId, string institutionCd, string dialStartDate,string diabetes)
        {
            PATID = patId;
            INSTITUTION_CD = institutionCd;
            DIAL_START_DATE = dialStartDate;
            DIABETES = diabetes;
        }
    }
}
