using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Fnw.StatisticsTool.Models
{
    public class SysDataSetRequest
    {
        public long? SqlCd { get; set; } 
        public long? PatId { get; set; }
        public long? OrdNo { get; set; } 
        public string MstName { get; set; }
        public string FromDate { get; set; } 
        public string ToDate { get; set; }
        public int? Days { get; set; }
        public string CtlNo { get; set; }
        public string OrderClass { get; set; }
        public long? ExamCd { get; set; }
        public long? ExamCdBun { get; set; }
        public long? ExamCdCre { get; set; }
        public long? ExamCdBunAfter { get; set; }
        public long? ExamCdCreAfter { get; set; }


        public SysDataSetRequest(
        long? sqlCd = null,
        long? patId = null,
        long? ordNo = null,
        string mstName = null,
        string fromDate = null,
        string toDate = null,
        int? days = null,
        string ctlNo = null,
        string orderClass = null,
        long? examCd = null,
        long? examCdBun = null,
        long? examCdCre = null,
        long? examCdBunAfter = null,
        long? examCdCreAfter = null)
        {
            SqlCd = sqlCd;
            PatId = patId;
            OrdNo = ordNo;
            MstName = mstName ?? string.Empty;
            FromDate = fromDate;
            ToDate = toDate;
            Days = days;
            CtlNo = ctlNo ?? string.Empty;
            OrderClass = orderClass ?? string.Empty;
            ExamCd = examCd;
            ExamCdBun = examCdBun;
            ExamCdCre = examCdCre;
            ExamCdBunAfter = examCdBunAfter;
            ExamCdCreAfter = examCdCreAfter;
        }
    }
}
