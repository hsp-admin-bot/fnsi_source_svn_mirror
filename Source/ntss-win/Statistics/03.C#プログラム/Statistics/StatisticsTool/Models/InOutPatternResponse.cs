using Fnw.StatisticsTool.Data;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Fnw.StatisticsTool.Models
{
    public class InOutPatternResponse : ISysDataSetResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public List<InOutPatternDataType> Data { get; set; } = new List<InOutPatternDataType>();
    }

    public class InOutPatternDataType
    {
        [JsonProperty("patid")]
        public long PATID { get; set; }

        [JsonProperty("inout_cd")]
        public int INOUT_CD { get; set; }

        [JsonProperty("reg_date")]
        public string  REG_DATE { get; set; }

        [JsonProperty("facility_name")]
        public string FACILITY_NAME { get; set; }

        [JsonProperty("ctl_no")]
        public int CTL_NO { get; set; }

        public InOutPatternDataType() { }

        public InOutPatternDataType(long patid, int inoutCd, string regDate, string facilityName, int ctlNo)
        {
            PATID = patid;
            INOUT_CD = inoutCd;
            REG_DATE = regDate;
            FACILITY_NAME = facilityName;
            CTL_NO = ctlNo;
        }
    }
}
