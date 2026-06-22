using Fnw.StatisticsTool.Data;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Fnw.StatisticsTool.Models
{
    public class PatPersonalDataResponse : ISysDataSetResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public List<PatPersonalDataType> Data { get; set; } = new List<PatPersonalDataType>();
    }

    public class PatPersonalDataType
    {
        [JsonProperty("patid")]
        public long PATID { get; set; }

        [JsonProperty("disp_patid")]
        public string DISP_PATID { get; set; }
        
        [JsonProperty("name")]
        public string NAME { get; set; }
        
        [JsonProperty("sex_cd")]
        public short  SEX_CD { get; set; }

        [JsonProperty("birthday")]
        public string BIRTHDAY { get; set; }

        public PatPersonalDataType() { }

        public PatPersonalDataType(long patId, string dispPatid,string name , short sexCd ,string birthday)
        {
            PATID = patId;
            DISP_PATID = dispPatid;
            NAME = name;
            SEX_CD = sexCd;
            BIRTHDAY = birthday;
        }
    }
}
