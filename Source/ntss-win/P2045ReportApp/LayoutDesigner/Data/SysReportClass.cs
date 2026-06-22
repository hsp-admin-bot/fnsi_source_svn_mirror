using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner.Data
{
    /// <summary>
    /// 帳票種別定義
    /// </summary>
    [System.Runtime.Serialization.DataContract()]
    class SysReportClass
    {
        /// <summary>
        /// 帳票種別
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "reportClassCd")]
        public string ReportClassCd { get; set; }

        /// <summary>
        /// 帳票種別名
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "reportClassName")]
        public string ReportClassName { get; set; }

        /// <summary>
        /// 帳票区分
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "reportType")]
        public string ReportType { get; set; }

        /// <summary>
        /// 表示フラグ
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "isDisp")]
        public string IsDisp { get; set; }

        /// <summary>
        /// 削除フラグ
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "isDel")]
        public string IsDel { get; set; }

        /// <summary>
        /// 更新日時
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "regDate")]
        public string UpDate { get; set; }

        /// <summary>
        /// 登録日時
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "upDate")]
        public string RegDate { get; set; }
    }
}
