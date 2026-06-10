using System;

namespace ConvertCommon.dto
{
    public class BatchConvertStatusDto
    {
        public int convert_proc_id { get; set; }
        public string facility_cd { get; set; }
        public string status { get; set; }
        public int job_instance_id { get; set; }
        public string job_name { get; set; }

        private string _reg_date;
        public string reg_date {
            get {
                if (!string.IsNullOrEmpty(_reg_date))
                {
                    return DateTime.Parse(_reg_date, null, System.Globalization.DateTimeStyles.RoundtripKind).ToString();
                }else
                {
                    return "";
                }
            }
            set { this._reg_date = value; } }

        private string _up_date;
        public string up_date {
            get {
                if (!string.IsNullOrEmpty(_up_date))
                {
                    return DateTime.Parse(_up_date, null, System.Globalization.DateTimeStyles.RoundtripKind).ToString();
                }else
                {
                    return "";
                }
            }
            set { this._up_date = value; }
        }
    }
}



