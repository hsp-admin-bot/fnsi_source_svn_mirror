using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner.Data
{

    /// <summary>
    /// 帳票種別マスタ
    /// </summary>
    [System.Runtime.Serialization.DataContract()]
    public class MstReportType
    {

        /// <summary>
        /// 帳票名称
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "report_name")]
        public string ReportName { get; set; }

        /// <summary>
        /// 帳票種別名
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "report_type")]
        public string ReportType { get; set; }

        /// <summary>
        /// 帳票種別コード
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "report_class")]
        public int ReportClass { get; set; }

        /// <summary>
        /// テンプレート繰り返しサポート有無
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "is_support_templete_repeat")]
        public bool IsSupportTempleteRepeat { get; set; }

    }
}
