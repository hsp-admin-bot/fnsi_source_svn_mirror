using Fnw.StatisticsTool.Data;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Fnw.StatisticsTool.Models
{
    public class PatInfoResponse : ISysDataSetResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public List<PatInfoDataType> Data { get; set; } = new List<PatInfoDataType>();
    }

    public class PatInfoDataType
    {
        [JsonProperty("patid")]
        public long PATID { get; set; }

        [JsonProperty("disp_patid")]
        public string DISP_PATID { get; set; }

        [JsonProperty("name")]
        public string NAME { get; set; }

        [JsonProperty("sex_cd")]
        public int SEX_CD { get; set; }

        [JsonProperty("die_cd")]
        public string DIE_CD { get; set; }

        [JsonProperty("die_date")]
        public string DIE_DATE { get; set; }

        [JsonProperty("birthday")]
        public string BIRTHDAY { get; set; }

        [JsonProperty("name_kana")]
        public string NAME_KANA { get; set; }

        [JsonProperty("base_disease_cd")]
        public string BASE_DISEASE_CD { get; set; }

        public PatInfoDataType() { }

        public PatInfoDataType(long patId, string dispPatId, string name,int sexCd, string dieCd, string dieDate, string birthday, string nameKana, string baseDiseaseCd)
        {
            PATID = patId;
            DISP_PATID = dispPatId;
            NAME = name;
            SEX_CD = sexCd;
            DIE_CD = dieCd;
            DIE_DATE = dieDate;
            BIRTHDAY = birthday;
            NAME_KANA = nameKana;
            BASE_DISEASE_CD = baseDiseaseCd;
        }
    }
}
