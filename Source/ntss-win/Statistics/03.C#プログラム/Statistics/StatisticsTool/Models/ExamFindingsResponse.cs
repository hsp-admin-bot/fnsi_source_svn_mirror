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
    public class ExamFindingsResponse : ISysDataSetResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public List<ExamFindingsDataType> Data { get; set; } = new List<ExamFindingsDataType>();
    }

    public class ExamFindingsDataType
    {
        [JsonProperty("weight_before")]
        public decimal? WEIGHT_BEFORE { get; set; }

        [JsonProperty("weight_after")]
        public decimal? WEIGHT_AFTER { get; set; }

        [JsonProperty("rst_bun_before")]
        public string RST_BUN_BEFORE { get; set; }

        [JsonProperty("rst_bun_after")]
        public string RST_BUN_AFTER { get; set; }

        [JsonProperty("rst_cre_before")]
        public string RST_CRE_BEFORE { get; set; }

        [JsonProperty("rst_cre_after")]
        public string RST_CRE_AFTER { get; set; }

        [JsonProperty("exam_day")]
        public string  EXAM_DAY { get; set; }

        [JsonProperty("exam_date")]
        public DateTime EXAM_DATE { get; set; }

        [JsonProperty("dialysis_no")]
        public int DIALYSIS_NO { get; set; }

        public ExamFindingsDataType() { }

        public ExamFindingsDataType(decimal? weight_before, decimal? weight_after, string rst_bun_before, string rst_bun_after, string rst_cre_before, string rst_cre_after, string exam_day, DateTime exam_date, int dialysis_no)
        {
            WEIGHT_BEFORE = weight_before;
            WEIGHT_AFTER = weight_after;
            RST_BUN_BEFORE = rst_bun_before;
            RST_BUN_AFTER = rst_bun_after;
            RST_CRE_BEFORE = rst_cre_before;
            RST_CRE_AFTER = rst_cre_after;
            EXAM_DAY = exam_day;
            EXAM_DATE = exam_date;
            DIALYSIS_NO = dialysis_no;
        }
    }
}
