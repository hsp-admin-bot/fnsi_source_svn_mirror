using Fnw.StatisticsTool.Data;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Fnw.StatisticsTool.Models
{
    public class MovingOutInfoResponse : ISysDataSetResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public List<MovingOutInfoDataType> Data { get; set; } = new List<MovingOutInfoDataType>();
    }

    public class MovingOutInfoDataType
    {
        [JsonProperty("reg_date")]
        public string REG_DATE { get; set; }

        [JsonProperty("facility_name")]
        public string FACILITY_NAME { get; set; }

        [JsonProperty("inout_cd")]
        public string INOUT_CD { get; set; }

        public MovingOutInfoDataType() { }

        public MovingOutInfoDataType(string regDate, string facilityName, string inoutCd)
        {
            REG_DATE = regDate;
            FACILITY_NAME = facilityName;
            INOUT_CD = inoutCd;
        }
    }
}
