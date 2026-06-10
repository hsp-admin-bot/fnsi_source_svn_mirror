using System;

namespace ConvertCommon.dto
{
    public class BatchConvertTableStatusDto
    {
        public int order_no { get; set; }
        public int convert_proc_id { get; set; }
        public int job_instance_id { get; set; }
        public string table_name { get; set; }
        public string sql_file_path { get; set; }
        public string status { get; set; }
        public string proc_name { get; set; }
        public string facility_cd { get; set; }
        public string content { get; set; }
        private string _reg_date;
        public string reg_date
        {
            get { return DateTime.Parse(_reg_date, null, System.Globalization.DateTimeStyles.RoundtripKind).ToString(); }
            set { this._reg_date = value; }
        }
    }
}
