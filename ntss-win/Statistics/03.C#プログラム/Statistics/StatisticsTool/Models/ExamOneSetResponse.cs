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
    public class ExamOneSetResponse : ISysDataSetResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public List<ExamOneSetDataType> Data { get; set; } = new List<ExamOneSetDataType>();
    }

    public class ExamOneSetDataType
    {
        [JsonProperty("exam_rst")]
        public decimal EXAM_RST { get; set; }

        [JsonProperty("exam_date")]
        public DateTime EXAM_DATE { get; set; }

        public ExamOneSetDataType() { }

        public ExamOneSetDataType(decimal examRst, DateTime examDate)
        {
            EXAM_RST = examRst;
            EXAM_DATE = examDate;
        }
    }
}
